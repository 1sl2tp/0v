-- Review candidate only. No storage policy or message insert.
CREATE TABLE v0_private.media_batches (
  account_id uuid NOT NULL, session_id uuid NOT NULL, client_id text NOT NULL,
  contact_id uuid NOT NULL, conversation_id uuid NOT NULL, body text NOT NULL,
  manifest jsonb NOT NULL, reservations jsonb NOT NULL,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  total_bytes bigint NOT NULL CHECK(total_bytes BETWEEN 1 AND 125829120),
  PRIMARY KEY(account_id,client_id)
);
ALTER TABLE v0_private.media_batches ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON v0_private.media_batches FROM PUBLIC,anon,authenticated,service_role;

CREATE TABLE v0_private.media_reservations (
 asset_id uuid PRIMARY KEY, storage_key text NOT NULL UNIQUE,
 account_id uuid NOT NULL, client_id text NOT NULL,
 FOREIGN KEY(account_id,client_id) REFERENCES v0_private.media_batches(account_id,client_id)
);
ALTER TABLE v0_private.media_reservations ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON v0_private.media_reservations FROM PUBLIC,anon,authenticated,service_role;
CREATE INDEX media_batches_account_created ON v0_private.media_batches(account_id,created_at);
CREATE INDEX media_batches_account_expiry ON v0_private.media_batches(account_id,expires_at);

CREATE FUNCTION v0_private.admin_media_prepare(p_contact_id uuid,p_client_id text,p_body text,p_assets jsonb)
RETURNS jsonb LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path=''
AS $$
DECLARE
 me uuid; sid uuid; room uuid; item jsonb; ord bigint; asset uuid; mime text; kind text; bytes bigint;
 seen uuid[]:='{}'; manifest jsonb:='[]'; reservations jsonb:='[]'; body_text text:=btrim(coalesce(p_body,''));
 batch v0_private.media_batches%ROWTYPE; total_bytes bigint:=0; active_count bigint; active_bytes bigint; day_count bigint;
BEGIN
 me:=(v0_private.admin_read('session',null)->>'account_id')::uuid;
 IF auth.jwt()->>'aal' IS DISTINCT FROM 'aal2' THEN RAISE EXCEPTION 'mfa_required' USING errcode='42501'; END IF;
 sid:=(auth.jwt()->>'session_id')::uuid;
 IF p_contact_id IS NULL OR p_contact_id=me OR NOT EXISTS(SELECT 1 FROM public.v21_accounts a WHERE a.id=p_contact_id AND a.role='user' AND a.deleted_at IS NULL AND a.locked_at IS NULL) THEN RAISE EXCEPTION 'contact_forbidden' USING errcode='42501'; END IF;
 SELECT c.id INTO room FROM public.v21_conversations c WHERE c.member_a=least(me,p_contact_id) AND c.member_b=greatest(me,p_contact_id);
 IF room IS NULL THEN RAISE EXCEPTION 'existing_room_required' USING errcode='22023'; END IF;
 IF p_client_id IS NULL OR p_client_id !~ '^0vm:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' OR char_length(body_text)>8000 THEN RAISE EXCEPTION 'invalid_request' USING errcode='22023'; END IF;
 IF jsonb_typeof(p_assets) IS DISTINCT FROM 'array' OR pg_column_size(p_assets)>32768 THEN RAISE EXCEPTION 'invalid_manifest' USING errcode='22023'; END IF;
 IF jsonb_array_length(p_assets) NOT BETWEEN 1 AND 8 THEN RAISE EXCEPTION 'invalid_asset_count' USING errcode='22023'; END IF;
 FOR item,ord IN SELECT value,ordinality FROM jsonb_array_elements(p_assets) WITH ORDINALITY LOOP
  IF jsonb_typeof(item) IS DISTINCT FROM 'object' THEN RAISE EXCEPTION 'invalid_asset' USING errcode='22023'; END IF;
  IF (SELECT count(*) FROM jsonb_object_keys(item))<>6 OR NOT (item ?& ARRAY['id','kind','mime_type','size_bytes','file_name','sha256']) THEN RAISE EXCEPTION 'invalid_asset_fields' USING errcode='22023'; END IF;
  IF jsonb_typeof(item->'id') IS DISTINCT FROM 'string' OR coalesce(item->>'id','') !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' OR jsonb_typeof(item->'size_bytes') IS DISTINCT FROM 'number' OR coalesce(item->>'size_bytes','') !~ '^[0-9]{1,8}$' THEN RAISE EXCEPTION 'invalid_asset_identity' USING errcode='22023'; END IF;
  asset:=(item->>'id')::uuid; bytes:=(item->>'size_bytes')::bigint; kind:=item->>'kind'; mime:=item->>'mime_type';
  IF asset=ANY(seen) OR bytes NOT BETWEEN 1 AND 15728640 OR jsonb_typeof(item->'sha256') IS DISTINCT FROM 'string' OR coalesce(item->>'sha256','') !~ '^[0-9a-f]{64}$' THEN RAISE EXCEPTION 'invalid_asset_metadata' USING errcode='22023'; END IF;
  IF jsonb_typeof(item->'file_name') IS DISTINCT FROM 'string' OR char_length(btrim(item->>'file_name')) NOT BETWEEN 1 AND 255 OR item->>'file_name' ~ '[[:cntrl:]/]' THEN RAISE EXCEPTION 'invalid_file_name' USING errcode='22023'; END IF;
  IF NOT coalesce((kind='image' AND mime IN ('image/jpeg','image/png','image/webp','image/gif','image/avif','image/heic','image/heif')) OR (kind='audio' AND mime IN ('audio/wav','audio/x-wav','audio/mpeg','audio/mp4','audio/aac','audio/ogg','audio/webm','audio/flac','audio/x-m4a')) OR (kind='file' AND mime IN ('application/pdf','text/plain','text/csv','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.ms-excel','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')),false) THEN RAISE EXCEPTION 'unsupported_media' USING errcode='22023'; END IF;
  IF strpos(item->>'file_name',chr(92))>0 OR btrim(item->>'file_name') IN ('.','..') THEN RAISE EXCEPTION 'invalid_file_name' USING errcode='22023'; END IF;
  total_bytes:=total_bytes+bytes;
  seen:=array_append(seen,asset); manifest:=manifest||jsonb_build_array(item);
  reservations:=reservations||jsonb_build_array(jsonb_build_object('id',asset,'storage_key',me::text||'/'||room::text||'/'||asset::text,'sort_index',ord-1));
 END LOOP;
 -- Serialize prepare transactions per admin. Exact replay bypasses quota, but not session/expiry checks.
 -- The quota protocol assumes READ COMMITTED (PostgREST default); reject higher isolation.
 IF current_setting('transaction_isolation')<>'read committed' THEN RAISE EXCEPTION 'unsupported_isolation' USING errcode='22023'; END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('0v.media.prepare:'||me::text,0));
 SELECT * INTO batch FROM v0_private.media_batches b WHERE b.account_id=me AND b.client_id=p_client_id FOR UPDATE;
 IF FOUND THEN
  IF batch.session_id IS DISTINCT FROM sid OR batch.contact_id IS DISTINCT FROM p_contact_id OR batch.conversation_id IS DISTINCT FROM room OR batch.body IS DISTINCT FROM body_text OR batch.manifest IS DISTINCT FROM manifest THEN RAISE EXCEPTION 'request_conflict' USING errcode='22023'; END IF;
  IF batch.expires_at<=now() THEN RAISE EXCEPTION 'ticket_expired' USING errcode='22023'; END IF;
 ELSE
  SELECT count(*) FILTER(WHERE b.expires_at>now()),coalesce(sum(b.total_bytes) FILTER(WHERE b.expires_at>now()),0),count(*) FILTER(WHERE b.created_at>now()-interval '24 hours')
   INTO active_count,active_bytes,day_count FROM v0_private.media_batches b WHERE b.account_id=me;
  IF active_count>=4 OR active_bytes+total_bytes>125829120 OR day_count>=64 THEN RAISE EXCEPTION 'media_quota_exceeded' USING errcode='22023'; END IF;
  IF EXISTS(SELECT 1 FROM public.v21_media_assets a WHERE a.id=ANY(seen)) THEN RAISE EXCEPTION 'asset_id_unavailable' USING errcode='22023'; END IF;
  INSERT INTO v0_private.media_batches(account_id,session_id,client_id,contact_id,conversation_id,body,manifest,reservations,expires_at,total_bytes)
   VALUES(me,sid,p_client_id,p_contact_id,room,body_text,manifest,reservations,now()+interval '15 minutes',total_bytes) RETURNING * INTO batch;
  -- Global unique asset and path; insert sorted IDs to minimize cross-admin deadlocks.
  BEGIN
   INSERT INTO v0_private.media_reservations(asset_id,storage_key,account_id,client_id)
   SELECT (x->>'id')::uuid,x->>'storage_key',me,p_client_id FROM jsonb_array_elements(reservations) x ORDER BY (x->>'id')::uuid;
  EXCEPTION WHEN unique_violation THEN RAISE EXCEPTION 'asset_id_unavailable' USING errcode='22023'; END;
 END IF;
 RETURN jsonb_build_object('account_id',me,'conversation_id',room,'client_id',p_client_id,'expires_at',batch.expires_at,'assets',batch.reservations);
END;
$$;
REVOKE ALL ON FUNCTION v0_private.admin_media_prepare(uuid,text,text,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION v0_private.admin_media_prepare(uuid,text,text,jsonb) TO authenticated;
CREATE FUNCTION public.v0_admin_media_prepare(p_contact_id uuid,p_client_id text,p_body text,p_assets jsonb)
RETURNS jsonb LANGUAGE sql VOLATILE SECURITY INVOKER SET search_path=''
AS $$ SELECT v0_private.admin_media_prepare(p_contact_id,p_client_id,p_body,p_assets) $$;
REVOKE ALL ON FUNCTION public.v0_admin_media_prepare(uuid,text,text,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.v0_admin_media_prepare(uuid,text,text,jsonb) TO authenticated;
