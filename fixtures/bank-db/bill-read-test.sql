-- SYNTHETIC ONLY; run in ephemeral bank_fixture_ci, never production.
BEGIN;
CREATE ROLE anon NOLOGIN;
CREATE ROLE authenticated NOLOGIN;
CREATE ROLE service_role NOLOGIN;
CREATE SCHEMA auth;
CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('fixture.uid',true),'')::uuid $$;
CREATE FUNCTION auth.jwt() RETURNS jsonb LANGUAGE sql STABLE AS $$ SELECT coalesce(nullif(current_setting('fixture.jwt',true),''),'{}')::jsonb $$;
CREATE TABLE auth.sessions(id uuid PRIMARY KEY,user_id uuid,not_after timestamptz);
CREATE TABLE public.v21_accounts(id uuid PRIMARY KEY,auth_user_id uuid,role text,deleted_at timestamptz,locked_at timestamptz,display_name text,created_at timestamptz DEFAULT now());
CREATE TABLE public.v21_conversations(id uuid PRIMARY KEY,member_a uuid,member_b uuid);
CREATE TABLE public.v21_messages(id uuid PRIMARY KEY,conversation_id uuid,deleted_at timestamptz,created_at timestamptz,sender_account_id uuid,body text);
CREATE TABLE public.v21_media_assets(id uuid PRIMARY KEY,message_id uuid,conversation_id uuid,owner_account_id uuid,kind text,mime_type text,storage_key text,width_px integer,height_px integer,file_name text,sort_index integer,deleted_at timestamptz,created_at timestamptz DEFAULT now());
CREATE TABLE public.v21_read_states(conversation_id uuid,account_id uuid,last_read_at timestamptz);
CREATE TABLE public.taphoa_debt_ledger(id bigint PRIMARY KEY,customer_account_id uuid,entry_type text,amount_vnd numeric);
CREATE TABLE public.chat_bank_bill_receipts(media_asset_id uuid UNIQUE,message_id uuid,customer_account_id uuid,status text,amount_vnd bigint,ledger_id bigint REFERENCES public.taphoa_debt_ledger(id),raw_read jsonb,transfer_at_vn timestamp,receiving_account text,receiving_name text,transfer_reference text,sending_bank text,receiving_bank text);
ALTER TABLE public.chat_bank_bill_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taphoa_debt_ledger ENABLE ROW LEVEL SECURITY;
\ir ../../references/0v-admin-read.sql
-- Baseline callable wrapper; establish exact ACL before replacement.
CREATE FUNCTION v0_private.admin_media(p_conversation_id uuid) RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$ SELECT '{}'::jsonb $$;
REVOKE ALL ON FUNCTION v0_private.admin_media(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION v0_private.admin_media(uuid) TO authenticated;
CREATE FUNCTION public.v0_admin_media(p_conversation_id uuid) RETURNS jsonb LANGUAGE sql STABLE SECURITY INVOKER SET search_path='' AS $$ SELECT v0_private.admin_media(p_conversation_id) $$;
REVOKE ALL ON FUNCTION public.v0_admin_media(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.v0_admin_media(uuid) TO authenticated;
\ir ../../references/0v-admin-media-bill.sql
INSERT INTO public.v21_accounts(id,auth_user_id,role) VALUES
('00000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','admin'),
('00000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','user'),
('00000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000003','user');
INSERT INTO auth.sessions VALUES
('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001',now()+interval '1 hour'),
('20000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002',now()+interval '1 hour');
INSERT INTO public.v21_conversations VALUES
('30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002'),
('30000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003');
INSERT INTO public.v21_messages(id,conversation_id,created_at,sender_account_id,body) SELECT ('40000000-0000-0000-0000-'||lpad(i::text,12,'0'))::uuid,'30000000-0000-0000-0000-000000000001',now(),'00000000-0000-0000-0000-000000000002','' FROM generate_series(1,7) i;
INSERT INTO public.v21_media_assets(id,message_id,conversation_id,owner_account_id,kind,mime_type,sort_index) SELECT ('50000000-0000-0000-0000-'||lpad(i::text,12,'0'))::uuid,('40000000-0000-0000-0000-'||lpad(i::text,12,'0'))::uuid,'30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002','image','image/jpeg',0 FROM generate_series(1,7) i;
INSERT INTO public.taphoa_debt_ledger VALUES(1,'00000000-0000-0000-0000-000000000002','collection',-26),(2,'00000000-0000-0000-0000-000000000003','collection',-26);
INSERT INTO public.chat_bank_bill_receipts(media_asset_id,message_id,customer_account_id,status,amount_vnd,ledger_id,raw_read,transfer_at_vn) VALUES
('50000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002','received',26000,1,'{"transfer_date_printed_vn":"25/11/2026","transfer_date_vn":"2026-11-25","transfer_time_printed_vn":"21:52","transaction_time_precision":"minute","transfer_content":"fixture","private":"never-return"}','2026-11-25 21:52'),
('50000000-0000-0000-0000-000000000002','40000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000002','amount_read',445000,null,'{"transfer_date_printed_vn":"25/11/2026","transfer_date_vn":"2026-11-25"}','2026-11-25 00:00'),
('50000000-0000-0000-0000-000000000003','40000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000002','non_bill',null,null,'{}',null),
('50000000-0000-0000-0000-000000000004','40000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000002','received',26000,null,'{}',null),
('50000000-0000-0000-0000-000000000005','40000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000003','received',26000,null,'{}',null),
('50000000-0000-0000-0000-000000000006','40000000-0000-0000-0000-000000000006','00000000-0000-0000-0000-000000000002','received',26000,2,'{"transfer_time_printed_vn":"21:52","transaction_time_precision":"minute","clock_text_conflict":true}','2026-11-25 21:52');
SET LOCAL ROLE authenticated;
SELECT set_config('fixture.uid','10000000-0000-0000-0000-000000000001',true),set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal2"}',true);
DO $$
DECLARE result jsonb; a jsonb;
BEGIN
 result:=public.v0_admin_media('30000000-0000-0000-0000-000000000001');
 IF jsonb_array_length(result->'assets')<>7 THEN RAISE EXCEPTION 'asset count'; END IF;
 a:=result->'assets'->0->'bill_receipt';
 IF a->>'amount_vnd' IS DISTINCT FROM '26000' OR a->>'has_ledger' IS DISTINCT FROM 'true' OR a->>'time_vn' IS DISTINCT FROM '21:52' OR a->>'date_vn' IS DISTINCT FROM '25/11/2026' OR a->>'transfer_content' IS DISTINCT FROM 'fixture' THEN RAISE EXCEPTION 'valid projection'; END IF;
 IF a ? 'raw_read' OR a ? 'ledger_id' OR result::text LIKE '%never-return%' THEN RAISE EXCEPTION 'private fields leaked'; END IF;
 a:=result->'assets'->1->'bill_receipt';
 IF a->>'date_vn' IS DISTINCT FROM '25/11/2026' OR a->>'time_vn' IS NOT NULL OR a->>'has_ledger' IS DISTINCT FROM 'false' THEN RAISE EXCEPTION 'missing time'; END IF;
 FOR i IN 2..4 LOOP
 IF result->'assets'->i->'bill_receipt' IS DISTINCT FROM 'null'::jsonb THEN RAISE EXCEPTION 'incorrect asset join'; END IF;
 END LOOP;
 a:=result->'assets'->5->'bill_receipt';
 IF a->>'has_ledger' IS DISTINCT FROM 'false' OR a->>'time_vn' IS NOT NULL THEN RAISE EXCEPTION 'wrong ledger or conflicting time'; END IF;
 IF result->'assets'->6->'bill_receipt' IS DISTINCT FROM 'null'::jsonb THEN RAISE EXCEPTION 'absent receipt'; END IF;
 BEGIN PERFORM public.v0_admin_media('30000000-0000-0000-0000-000000000002'); RAISE EXCEPTION 'foreign room allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 IF has_table_privilege(current_user,'public.chat_bank_bill_receipts','SELECT') OR has_table_privilege(current_user,'public.taphoa_debt_ledger','SELECT') THEN RAISE EXCEPTION 'direct table access'; END IF;
END $$;
SELECT set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal1"}',true);
DO $$ BEGIN IF public.v0_admin_media('30000000-0000-0000-0000-000000000001')->'assets'->0->'bill_receipt' IS DISTINCT FROM 'null'::jsonb THEN RAISE EXCEPTION 'aal1 exposed bill'; END IF; END $$;
SELECT set_config('fixture.uid','10000000-0000-0000-0000-000000000002',true),set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000002","aal":"aal2"}',true);
DO $$ BEGIN BEGIN PERFORM public.v0_admin_media('30000000-0000-0000-0000-000000000001'); RAISE EXCEPTION 'nonadmin allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END; END $$;
SELECT set_config('fixture.uid','',true),set_config('fixture.jwt','{}',true);
DO $$ BEGIN BEGIN PERFORM public.v0_admin_media('30000000-0000-0000-0000-000000000001'); RAISE EXCEPTION 'unauthenticated allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END; END $$;
RESET ROLE;
UPDATE public.v21_accounts SET locked_at=now() WHERE id='00000000-0000-0000-0000-000000000002';
SET LOCAL ROLE authenticated;
SELECT set_config('fixture.uid','10000000-0000-0000-0000-000000000001',true),set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal2"}',true);
DO $$ BEGIN BEGIN PERFORM public.v0_admin_media('30000000-0000-0000-0000-000000000001'); RAISE EXCEPTION 'locked contact allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END; END $$;
RESET ROLE;
ROLLBACK;
