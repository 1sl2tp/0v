-- Included inside the isolated bill-read fixture transaction. No production.
RESET ROLE;
UPDATE public.v21_accounts SET locked_at=NULL WHERE id='00000000-0000-0000-0000-000000000002';
\ir ../../references/0v-admin-media-prepare.sql
SET LOCAL ROLE authenticated;
SELECT set_config('fixture.uid','10000000-0000-0000-0000-000000000001',true),set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal2"}',true);
DO $$
DECLARE contact uuid:='00000000-0000-0000-0000-000000000002'; req text:='0vm:60000000-0000-0000-0000-000000000001'; m jsonb; a jsonb; b jsonb; bad jsonb;
BEGIN
 m:=jsonb_build_array(jsonb_build_object('id','70000000-0000-0000-0000-000000000001','kind','image','mime_type','image/jpeg','size_bytes',100,'file_name','fixture.jpg','sha256',repeat('a',64)));
 a:=public.v0_admin_media_prepare(contact,req,'fixture',m);b:=public.v0_admin_media_prepare(contact,req,'fixture',m);
 IF a IS DISTINCT FROM b OR a->'assets'->0->>'storage_key' IS DISTINCT FROM '00000000-0000-0000-0000-000000000001/30000000-0000-0000-0000-000000000001/70000000-0000-0000-0000-000000000001' THEN RAISE EXCEPTION 'retry or key mismatch'; END IF;
 BEGIN PERFORM public.v0_admin_media_prepare(contact,req,'changed',m);RAISE EXCEPTION 'accepted changed request';EXCEPTION WHEN invalid_parameter_value THEN NULL;END;
 FOR bad IN SELECT value FROM jsonb_array_elements(jsonb_build_array(m||m,jsonb_set(m,'{0,size_bytes}','15728641'),jsonb_set(m,'{0,mime_type}','"text/html"'),jsonb_set(m,'{0,sha256}','"x"'),jsonb_set(m,'{0,file_name}','"../x"'),'[]'::jsonb)) LOOP
  BEGIN PERFORM public.v0_admin_media_prepare(contact,'0vm:60000000-0000-0000-0000-000000000002','',bad);RAISE EXCEPTION 'accepted invalid manifest';EXCEPTION WHEN invalid_parameter_value THEN NULL;END;
 END LOOP;
 IF has_table_privilege(current_user,'v0_private.media_batches','SELECT') OR has_table_privilege(current_user,'v0_private.media_batches','INSERT') THEN RAISE EXCEPTION 'direct ticket access'; END IF;
 PERFORM set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal1"}',true);
 BEGIN PERFORM public.v0_admin_media_prepare(contact,req,'fixture',m);RAISE EXCEPTION 'accepted aal1';EXCEPTION WHEN insufficient_privilege THEN NULL;END;
 PERFORM set_config('fixture.uid','10000000-0000-0000-0000-000000000002',true);
 PERFORM set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000002","aal":"aal2"}',true);
 BEGIN PERFORM public.v0_admin_media_prepare(contact,req,'fixture',m);RAISE EXCEPTION 'accepted nonadmin';EXCEPTION WHEN insufficient_privilege THEN NULL;END;
END $$;
RESET ROLE;
DO $$ BEGIN IF (SELECT count(*) FROM v0_private.media_batches)<>1 OR (SELECT count(*) FROM public.v21_messages)<>7 OR (SELECT count(*) FROM public.v21_media_assets)<>7 OR (SELECT count(*) FROM public.v21_conversations)<>2 THEN RAISE EXCEPTION 'prepare produced business side effects'; END IF; END $$;
UPDATE v0_private.media_batches SET expires_at=now()-interval '1 second';
SET LOCAL ROLE authenticated;
SELECT set_config('fixture.uid','10000000-0000-0000-0000-000000000001',true),set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal2"}',true);
DO $$ DECLARE m jsonb:=jsonb_build_array(jsonb_build_object('id','70000000-0000-0000-0000-000000000001','kind','image','mime_type','image/jpeg','size_bytes',100,'file_name','fixture.jpg','sha256',repeat('a',64))); BEGIN
 BEGIN PERFORM public.v0_admin_media_prepare('00000000-0000-0000-0000-000000000002','0vm:60000000-0000-0000-0000-000000000001','fixture',m);RAISE EXCEPTION 'accepted expired ticket';EXCEPTION WHEN invalid_parameter_value THEN NULL;END;
END $$;
RESET ROLE;

-- Phase 2: global reservation, quotas and replay after quota. Expired ID stays reserved.
SET LOCAL ROLE authenticated;
SELECT set_config('fixture.uid','10000000-0000-0000-0000-000000000001',true),set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal2"}',true);
DO $$
DECLARE c uuid:='00000000-0000-0000-0000-000000000002'; m jsonb; q jsonb; k text; saved jsonb; retry jsonb;
BEGIN
 m:=jsonb_build_array(jsonb_build_object('id','70000000-0000-0000-0000-000000000001','kind','image','mime_type','image/jpeg','size_bytes',100,'file_name','fixture.jpg','sha256',repeat('a',64)));
 BEGIN PERFORM public.v0_admin_media_prepare(c,'0vm:60000000-0000-0000-0000-000000000010','',m);RAISE EXCEPTION 'expired asset reused';EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'asset_id_unavailable' THEN RAISE; END IF;END;
 q:=jsonb_set(m,'{0,id}','"50000000-0000-0000-0000-000000000001"');
 BEGIN PERFORM public.v0_admin_media_prepare(c,'0vm:60000000-0000-0000-0000-000000000010','',q);RAISE EXCEPTION 'canonical asset reused';EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'asset_id_unavailable' THEN RAISE; END IF;END;
 FOR i IN 1..4 LOOP
 k:='0vm:61000000-0000-0000-0000-'||lpad(i::text,12,'0');
 q:=jsonb_set(m,'{0,id}',to_jsonb('71000000-0000-0000-0000-'||lpad(i::text,12,'0')));
 saved:=public.v0_admin_media_prepare(c,k,'',q);
 END LOOP;
 retry:=public.v0_admin_media_prepare(c,k,'',q);IF retry IS DISTINCT FROM saved THEN RAISE EXCEPTION 'replay lost at quota';END IF;
 q:=jsonb_set(m,'{0,id}','"71000000-0000-0000-0000-000000000005"');
 BEGIN PERFORM public.v0_admin_media_prepare(c,'0vm:61000000-0000-0000-0000-000000000005','',q);RAISE EXCEPTION 'active quota bypass';EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'media_quota_exceeded' THEN RAISE; END IF;END;
 IF has_table_privilege(current_user,'v0_private.media_reservations','SELECT') OR has_table_privilege(current_user,'v0_private.media_reservations','INSERT') THEN RAISE EXCEPTION 'direct reservation access';END IF;
END $$;
RESET ROLE;
DO $$ BEGIN IF (SELECT count(*) FROM v0_private.media_batches)<>5 OR (SELECT count(*) FROM v0_private.media_reservations)<>5 OR (SELECT count(*) FROM public.v21_messages)<>7 THEN RAISE EXCEPTION 'failed batch not rolled back';END IF; END $$;
UPDATE v0_private.media_batches SET expires_at=now()-interval '1 second';
SET LOCAL ROLE authenticated;
DO $$
DECLARE c uuid:='00000000-0000-0000-0000-000000000002'; m jsonb; q jsonb;
BEGIN
 SELECT jsonb_agg(jsonb_build_object('id','72000000-0000-0000-0000-'||lpad(i::text,12,'0'),'kind','image','mime_type','image/jpeg','size_bytes',15728640,'file_name','fixture.jpg','sha256',repeat('a',64))) INTO m FROM generate_series(1,8) i;
 PERFORM public.v0_admin_media_prepare(c,'0vm:62000000-0000-0000-0000-000000000001','',m);
 q:=jsonb_build_array(jsonb_set(m->0,'{id}','"72000000-0000-0000-0000-000000000009"'));
 BEGIN PERFORM public.v0_admin_media_prepare(c,'0vm:62000000-0000-0000-0000-000000000002','',q);RAISE EXCEPTION 'byte quota bypass';EXCEPTION WHEN invalid_parameter_value THEN IF SQLERRM<>'media_quota_exceeded' THEN RAISE; END IF;END;
END $$;
RESET ROLE;
