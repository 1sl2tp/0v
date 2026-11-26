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
CREATE TABLE public.chat_bank_bill_receipts(id uuid DEFAULT gen_random_uuid() PRIMARY KEY,media_asset_id uuid UNIQUE,message_id uuid,customer_account_id uuid,status text,amount_vnd bigint,ledger_id bigint REFERENCES public.taphoa_debt_ledger(id),raw_read jsonb,transfer_at_vn timestamp,receiving_account text,receiving_name text,transfer_reference text,sending_bank text,receiving_bank text);
CREATE TABLE public.taphoa_agribank_notifications(id bigint PRIMARY KEY,package_name text,status text,is_own_transfer boolean,bank_credit_account text,amount_vnd bigint,transfer_at timestamptz);
CREATE TABLE public.chat_bank_app_collection_links(receipt_id uuid,notification_id bigint,ledger_id bigint);
ALTER TABLE public.chat_bank_bill_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taphoa_debt_ledger ENABLE ROW LEVEL SECURITY;
\ir ../../references/0v-admin-read.sql
ALTER TABLE public.v21_accounts ADD COLUMN avatar_path text;
\ir ../../references/0v-admin-directory-avatar.sql
-- Baseline callable wrapper; establish exact ACL before replacement.
CREATE FUNCTION v0_private.admin_media(p_conversation_id uuid) RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$ SELECT '{}'::jsonb $$;
REVOKE ALL ON FUNCTION v0_private.admin_media(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION v0_private.admin_media(uuid) TO authenticated;
CREATE FUNCTION public.v0_admin_media(p_conversation_id uuid) RETURNS jsonb LANGUAGE sql STABLE SECURITY INVOKER SET search_path='' AS $$ SELECT v0_private.admin_media(p_conversation_id) $$;
REVOKE ALL ON FUNCTION public.v0_admin_media(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.v0_admin_media(uuid) TO authenticated;
\ir ../../references/0v-bill-memo-review.sql
\ir ../../references/0v-bill-account-review.sql
\ir ../../references/0v-admin-media-bill.sql
ALTER TABLE public.chat_bank_bill_receipts ADD COLUMN reason text;
\ir ../../references/0v-admin-bill-audit.sql
\ir ../../references/0v-admin-bill-audit-annotations.sql
ALTER TABLE public.chat_bank_bill_receipts ADD COLUMN duplicate_of uuid, ADD COLUMN image_sha256 text;
ALTER TABLE public.chat_bank_bill_receipts ADD COLUMN scanned_at timestamptz;
\ir ../../references/0v-admin-bill-audit-classification.sql
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
INSERT INTO public.v21_messages(id,conversation_id,created_at,sender_account_id,body) SELECT ('40000000-0000-0000-0000-'||lpad(i::text,12,'0'))::uuid,'30000000-0000-0000-0000-000000000001',now(),'00000000-0000-0000-0000-000000000002','' FROM generate_series(1,10) i;
INSERT INTO public.v21_media_assets(id,message_id,conversation_id,owner_account_id,kind,mime_type,sort_index) SELECT ('50000000-0000-0000-0000-'||lpad(i::text,12,'0'))::uuid,('40000000-0000-0000-0000-'||lpad(i::text,12,'0'))::uuid,'30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002','image','image/jpeg',0 FROM generate_series(1,10) i;
INSERT INTO public.taphoa_debt_ledger VALUES(1,'00000000-0000-0000-0000-000000000002','collection',-26),(2,'00000000-0000-0000-0000-000000000003','collection',-26);
INSERT INTO public.chat_bank_bill_receipts(media_asset_id,message_id,customer_account_id,status,amount_vnd,ledger_id,raw_read,transfer_at_vn) VALUES
('50000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002','received',26000,1,'{"transfer_date_printed_vn":"25/11/2026","transfer_date_vn":"2026-11-25","transfer_time_printed_vn":"21:52","transaction_time_precision":"minute","transfer_content":"fixture","private":"never-return"}','2026-11-25 21:52'),
('50000000-0000-0000-0000-000000000002','40000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000002','amount_read',445000,null,'{"transfer_date_printed_vn":"25/11/2026","transfer_date_vn":"2026-11-25"}',null),
('50000000-0000-0000-0000-000000000003','40000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000002','non_bill',null,null,'{}',null),
('50000000-0000-0000-0000-000000000004','40000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000002','received',26000,null,'{}',null),
('50000000-0000-0000-0000-000000000005','40000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000003','received',26000,null,'{}',null),
('50000000-0000-0000-0000-000000000006','40000000-0000-0000-0000-000000000006','00000000-0000-0000-0000-000000000002','received',26000,2,'{"transfer_time_printed_vn":"21:52","transaction_time_precision":"minute","clock_text_conflict":true}','2026-11-25 21:52');
INSERT INTO public.chat_bank_bill_receipts(media_asset_id,message_id,customer_account_id,status,amount_vnd,ledger_id,raw_read,transfer_at_vn) VALUES
('50000000-0000-0000-0000-000000000008','40000000-0000-0000-0000-000000000008','00000000-0000-0000-0000-000000000002','review',null,null,'{"image_type":"bank_credit_notification","amount_role":"sender_debit","transaction_nature":"transfer","amount_clear":true,"transfer_success_visible":true,"amount_text":"-1,234,000VND","transfer_date_printed_raw_vn":"24/11/26","transfer_date_vn":"2026-11-24","printed_date_invalid":true,"transaction_time_precision":"minute","transfer_time_printed_vn":"15:16"}','2026-11-24 15:16'),
('50000000-0000-0000-0000-000000000009','40000000-0000-0000-0000-000000000009','00000000-0000-0000-0000-000000000002','review',null,null,'{"image_type":"bank_credit_notification","amount_role":"sender_debit","transaction_nature":"transfer","amount_clear":true,"transfer_success_visible":true,"amount_text":"-1,234,000VND","transfer_date_printed_raw_vn":"25/11/26","transfer_date_vn":"2026-11-24","printed_date_invalid":true,"transaction_time_precision":"minute","transfer_time_printed_vn":"15:16"}','2026-11-24 15:16');
INSERT INTO public.chat_bank_bill_receipts(media_asset_id,message_id,customer_account_id,status,amount_vnd,ledger_id,raw_read,transfer_at_vn,receiving_account,receiving_name,receiving_bank) VALUES
('50000000-0000-0000-0000-000000000010','40000000-0000-0000-0000-000000000010','00000000-0000-0000-0000-000000000002','review',null,null,'{"image_type":"bank_credit_notification","amount_role":"sender_debit","transaction_nature":"transfer","amount_clear":true,"transfer_success_visible":true,"amount_text":"-123,000 VND","sending_bank":"BIDV","transfer_content":"SMB-TkThe:1234567890123, tai MAU. KHACH MAU Chuyen tien","transfer_date_printed_vn":"23/11/2026","transfer_date_vn":"2026-11-23","printed_date_invalid":false,"transaction_time_precision":"minute","transfer_time_printed_vn":"19:56"}','2026-11-23 19:56','1234567890123','KHACH MAU','AGRIBANK');
UPDATE public.chat_bank_bill_receipts SET receiving_account='290118199999' WHERE media_asset_id IN ('50000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000006');
UPDATE public.chat_bank_bill_receipts SET raw_read=raw_read||'{"account_digit_recheck":{"source":"independent_focused_vision","first_visible":"290118199999","second_visible":"2901181999999","digit_count":13,"trailing_nines":6}}'::jsonb WHERE media_asset_id='50000000-0000-0000-0000-000000000001';
INSERT INTO public.taphoa_agribank_notifications VALUES(1,'com.vnpay.Agribank3g','credit_candidate',false,'2901181999999',26000,'2026-11-25 21:52:00+07');
INSERT INTO public.chat_bank_app_collection_links SELECT id,1,ledger_id FROM public.chat_bank_bill_receipts WHERE media_asset_id IN ('50000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000006');
INSERT INTO v0_private.bill_memo_review(media_asset_id,message_id,customer_account_id,raw_read_hash,reviewed_memo,evidence_kind)
 SELECT media_asset_id,message_id,customer_account_id,md5(raw_read::text),E'KHACH MAU\nChuyen tien','visual_review' FROM public.chat_bank_bill_receipts WHERE media_asset_id='50000000-0000-0000-0000-000000000001';
INSERT INTO v0_private.bill_memo_review(media_asset_id,message_id,customer_account_id,raw_read_hash,reviewed_memo,evidence_kind)
 SELECT media_asset_id,message_id,customer_account_id,md5('stale'),E'INVALID\nSTALE','visual_review' FROM public.chat_bank_bill_receipts WHERE media_asset_id='50000000-0000-0000-0000-000000000002';
UPDATE public.chat_bank_bill_receipts SET receiving_account='290118199999' WHERE media_asset_id='50000000-0000-0000-0000-000000000002';
INSERT INTO v0_private.bill_account_review(media_asset_id,message_id,customer_account_id,raw_read_hash,reviewed_account,evidence_kind)
 SELECT media_asset_id,message_id,customer_account_id,md5(raw_read::text),'2901181999999','visual_review' FROM public.chat_bank_bill_receipts WHERE media_asset_id='50000000-0000-0000-0000-000000000002';
INSERT INTO v0_private.bill_account_review(media_asset_id,message_id,customer_account_id,raw_read_hash,reviewed_account,evidence_kind)
 SELECT media_asset_id,message_id,customer_account_id,md5('stale'),'2901181999999','visual_review' FROM public.chat_bank_bill_receipts WHERE media_asset_id='50000000-0000-0000-0000-000000000006';
UPDATE public.v21_accounts SET avatar_path='fixture/avatar.jpg' WHERE id='00000000-0000-0000-0000-000000000002';
UPDATE public.v21_accounts SET avatar_path='../bad.jpg' WHERE id='00000000-0000-0000-0000-000000000003';
SET LOCAL ROLE authenticated;
SELECT set_config('fixture.uid','10000000-0000-0000-0000-000000000001',true),set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal2"}',true);
DO $$
DECLARE result jsonb; a jsonb;
BEGIN
 result:=public.v0_admin_read('directory',null);
 IF NOT EXISTS (SELECT 1 FROM jsonb_array_elements(result->'contacts') c WHERE c->>'id'='00000000-0000-0000-0000-000000000002' AND c->>'avatar_path'='fixture/avatar.jpg') OR EXISTS (SELECT 1 FROM jsonb_array_elements(result->'contacts') c WHERE c->>'id'='00000000-0000-0000-0000-000000000003' AND c->>'avatar_path' IS NOT NULL) THEN RAISE EXCEPTION 'avatar path projection'; END IF;
 result:=public.v0_admin_bill_audit();
 IF (result->>'total')::int<>7 OR jsonb_array_length(result->'rows')<>7 THEN RAISE EXCEPTION 'audit scoped count'; END IF;
 IF result::text LIKE '%never-return%' OR EXISTS (SELECT 1 FROM jsonb_array_elements(result->'rows') x WHERE x ? 'raw_read' OR x ? 'ledger_id') THEN RAISE EXCEPTION 'audit exposed internal fields'; END IF;
 IF NOT EXISTS (SELECT 1 FROM jsonb_array_elements(result->'rows') x WHERE x->>'status'='non_bill' AND x->>'audit_kind'='non_bill' AND jsonb_array_length(x->'flags')=0) THEN RAISE EXCEPTION 'audit nonbill classification'; END IF;
 IF NOT EXISTS (SELECT 1 FROM jsonb_array_elements(result->'rows') x WHERE x->>'asset_id'='50000000-0000-0000-0000-000000000001' AND x->>'audit_kind'='bill') THEN RAISE EXCEPTION 'target suffix classification'; END IF;
 IF NOT EXISTS (SELECT 1 FROM jsonb_array_elements(result->'rows') x WHERE x->>'asset_id'='50000000-0000-0000-0000-000000000010' AND x->>'audit_kind'='unverified') THEN RAISE EXCEPTION 'memo-only classification'; END IF;
 a:=(SELECT x FROM jsonb_array_elements(result->'rows') x WHERE x->>'asset_id'='50000000-0000-0000-0000-000000000001');
 IF a->>'review_state' IS DISTINCT FROM 'pending' THEN RAISE EXCEPTION 'initial review state'; END IF;
 PERFORM public.v0_save_bill_audit_annotation((a->>'id')::uuid,a->>'raw_hash',0,'needs_fix','{"account_raw":"1234567890123","clock":null}','fixture annotation');
 BEGIN PERFORM public.v0_save_bill_audit_annotation((a->>'id')::uuid,a->>'raw_hash',0,'checked','{}','stale'); RAISE EXCEPTION 'stale annotation allowed'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 BEGIN PERFORM public.v0_save_bill_audit_annotation((a->>'id')::uuid,repeat('0',32),1,'checked','{}','stale OCR'); RAISE EXCEPTION 'stale OCR allowed'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 result:=public.v0_admin_bill_audit();
 a:=(SELECT x FROM jsonb_array_elements(result->'rows') x WHERE x->>'asset_id'='50000000-0000-0000-0000-000000000001');
 IF a->>'review_state' IS DISTINCT FROM 'needs_fix' OR a->'corrections'->>'account_raw' IS DISTINCT FROM '1234567890123' OR a->>'account_raw' IS DISTINCT FROM '290118199999' OR a->>'review_revision' IS DISTINCT FROM '1' THEN RAISE EXCEPTION 'annotation isolation'; END IF;
 IF NOT (a ? 'ocr_scanned_at') OR a->>'result_saved_at' IS NULL THEN RAISE EXCEPTION 'audit read timestamps absent'; END IF;
 IF has_table_privilege(current_user,'v0_private.bill_audit_annotations','SELECT') OR has_table_privilege(current_user,'v0_private.bill_audit_annotations','INSERT') THEN RAISE EXCEPTION 'annotation table access'; END IF;
 result:=public.v0_admin_media('30000000-0000-0000-0000-000000000001');
 IF jsonb_array_length(result->'assets')<>10 THEN RAISE EXCEPTION 'asset count'; END IF;
 a:=result->'assets'->0->'bill_receipt';
 IF a->>'amount_vnd' IS DISTINCT FROM '26000' OR a->>'has_ledger' IS DISTINCT FROM 'true' OR a->>'time_vn' IS DISTINCT FROM '21:52' OR a->>'date_vn' IS DISTINCT FROM '25/11/2026' OR a->>'transfer_content' IS DISTINCT FROM E'KHACH MAU\nChuyen tien' THEN RAISE EXCEPTION 'valid projection'; END IF;
 IF a->>'ocr_rechecked_account' IS DISTINCT FROM '2901181999999' THEN RAISE EXCEPTION 'focused OCR projection'; END IF;
 IF a->>'bank_verified_account' IS DISTINCT FROM '2901181999999' OR a->>'receiving_account' IS DISTINCT FROM '290118199999' THEN RAISE EXCEPTION 'bank account proof or OCR preservation'; END IF;
 IF a ? 'raw_read' OR a ? 'ledger_id' OR result::text LIKE '%never-return%' THEN RAISE EXCEPTION 'private fields leaked'; END IF;
 a:=result->'assets'->1->'bill_receipt';
 IF a->>'ocr_rechecked_account' IS DISTINCT FROM '2901181999999' OR a->>'receiving_account' IS DISTINCT FROM '290118199999' OR a->>'bank_verified_account' IS NOT NULL THEN RAISE EXCEPTION 'visual account correction distinct from bank proof'; END IF;
 IF a->>'date_vn' IS DISTINCT FROM '25/11/2026' OR a->>'time_vn' IS NOT NULL OR a->>'has_ledger' IS DISTINCT FROM 'false' OR a->>'transfer_content' IS NOT NULL THEN RAISE EXCEPTION 'missing time or stale correction'; END IF;
 FOR i IN 2..4 LOOP
 IF result->'assets'->i->'bill_receipt' IS DISTINCT FROM 'null'::jsonb THEN RAISE EXCEPTION 'incorrect asset join'; END IF;
 END LOOP;
 a:=result->'assets'->5->'bill_receipt';
 IF a->>'has_ledger' IS DISTINCT FROM 'false' OR a->>'time_vn' IS NOT NULL OR a->>'bank_verified_account' IS NOT NULL OR a->>'ocr_rechecked_account' IS NOT NULL THEN RAISE EXCEPTION 'wrong ledger or conflicting time'; END IF;
 IF result->'assets'->6->'bill_receipt' IS DISTINCT FROM 'null'::jsonb THEN RAISE EXCEPTION 'absent receipt'; END IF;
 a:=result->'assets'->7->'bill_receipt';
 IF a->>'amount_vnd' IS DISTINCT FROM '1234000' OR a->>'date_vn' IS DISTINCT FROM '24/11/2026' OR a->>'time_vn' IS DISTINCT FROM '15:16' OR a->>'status' IS DISTINCT FROM 'review' OR a->>'has_ledger' IS DISTINCT FROM 'false' THEN RAISE EXCEPTION 'legacy debit display recovery'; END IF;
 a:=result->'assets'->8->'bill_receipt';
 IF a->>'amount_vnd' IS NOT NULL OR a->>'date_vn' IS NOT NULL THEN RAISE EXCEPTION 'conflicting short date accepted'; END IF;
 a:=result->'assets'->9->'bill_receipt';
 IF a->>'amount_vnd' IS DISTINCT FROM '123000' OR a->>'receiving_account' IS NOT NULL OR a->>'receiving_name' IS NOT NULL OR a->>'receiving_bank' IS NOT NULL OR a->>'transfer_content' IS DISTINCT FROM 'SMB-TkThe:1234567890123, tai MAU. KHACH MAU Chuyen tien' OR a->>'has_ledger' IS DISTINCT FROM 'false' THEN RAISE EXCEPTION 'BIDV memo-only field separation'; END IF;
 BEGIN PERFORM public.v0_admin_media('30000000-0000-0000-0000-000000000002'); RAISE EXCEPTION 'foreign room allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 IF has_table_privilege(current_user,'v0_private.bill_account_review','SELECT') OR has_table_privilege(current_user,'v0_private.bill_account_review','INSERT') OR has_table_privilege(current_user,'v0_private.bill_memo_review','SELECT') OR has_table_privilege(current_user,'v0_private.bill_memo_review','INSERT') OR has_table_privilege(current_user,'public.chat_bank_bill_receipts','SELECT') OR has_table_privilege(current_user,'public.taphoa_debt_ledger','SELECT') THEN RAISE EXCEPTION 'direct table access'; END IF;
END $$;
SELECT set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal1"}',true);
DO $$ BEGIN BEGIN PERFORM public.v0_save_bill_audit_annotation('00000000-0000-0000-0000-000000000001',repeat('0',32),0,'checked','{}',''); RAISE EXCEPTION 'annotation aal1 allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END; END $$;
DO $$ BEGIN BEGIN PERFORM public.v0_admin_bill_audit(); RAISE EXCEPTION 'audit aal1 allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END; END $$;
DO $$ BEGIN IF public.v0_admin_media('30000000-0000-0000-0000-000000000001')->'assets'->0->'bill_receipt' IS DISTINCT FROM 'null'::jsonb THEN RAISE EXCEPTION 'aal1 exposed bill'; END IF; END $$;
SELECT set_config('fixture.uid','10000000-0000-0000-0000-000000000002',true),set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000002","aal":"aal2"}',true);
DO $$ BEGIN BEGIN PERFORM public.v0_admin_bill_audit(); RAISE EXCEPTION 'audit nonadmin allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END; END $$;
DO $$ BEGIN BEGIN PERFORM public.v0_admin_media('30000000-0000-0000-0000-000000000001'); RAISE EXCEPTION 'nonadmin allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END; END $$;
SELECT set_config('fixture.uid','',true),set_config('fixture.jwt','{}',true);
DO $$ BEGIN BEGIN PERFORM public.v0_admin_media('30000000-0000-0000-0000-000000000001'); RAISE EXCEPTION 'unauthenticated allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END; END $$;
RESET ROLE;
UPDATE public.chat_bank_bill_receipts SET image_sha256=repeat('a',64) WHERE media_asset_id='50000000-0000-0000-0000-000000000003';
INSERT INTO public.chat_bank_bill_receipts(media_asset_id,message_id,customer_account_id,status,reason,raw_read,duplicate_of,image_sha256)
SELECT '50000000-0000-0000-0000-000000000007','40000000-0000-0000-0000-000000000007',customer_account_id,'duplicate','duplicate_exact_image_sha256_no_ai','{}',id,image_sha256 FROM public.chat_bank_bill_receipts WHERE media_asset_id='50000000-0000-0000-0000-000000000003';
SET LOCAL ROLE authenticated;
SELECT set_config('fixture.uid','10000000-0000-0000-0000-000000000001',true),set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal2"}',true);
DO $test$ BEGIN IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(public.v0_admin_bill_audit()->'rows') x WHERE x->>'asset_id'='50000000-0000-0000-0000-000000000007' AND x->>'status'='duplicate' AND x->>'audit_kind'='non_bill' AND jsonb_array_length(x->'flags')=0) THEN RAISE EXCEPTION 'duplicate nonbill origin classification'; END IF; END $test$;
RESET ROLE;
UPDATE public.v21_accounts SET locked_at=now() WHERE id='00000000-0000-0000-0000-000000000002';
SET LOCAL ROLE authenticated;
SELECT set_config('fixture.uid','10000000-0000-0000-0000-000000000001',true),set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal2"}',true);
DO $$ BEGIN BEGIN PERFORM public.v0_admin_media('30000000-0000-0000-0000-000000000001'); RAISE EXCEPTION 'locked contact allowed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END; END $$;
RESET ROLE;
DO $$ BEGIN IF (SELECT raw_read->>'transfer_content' FROM public.chat_bank_bill_receipts WHERE media_asset_id='50000000-0000-0000-0000-000000000001') IS DISTINCT FROM 'fixture' THEN RAISE EXCEPTION 'original receipt mutated'; END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM public.chat_bank_bill_receipts WHERE media_asset_id='50000000-0000-0000-0000-000000000008' AND (amount_vnd IS NOT NULL OR ledger_id IS NOT NULL OR status<>'review')) THEN RAISE EXCEPTION 'legacy recovery mutated financial record'; END IF; END $$;
ROLLBACK;
