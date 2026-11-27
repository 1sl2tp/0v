-- BANK-ACCOUNT-PROOF-MINUTE-01: display-only correction; no financial writes.
-- Patch precisely the bank_verified_account projection, not bank_clock or OCR.
DO $patch$
DECLARE src text := pg_get_functiondef('v0_private.admin_media(uuid)'::regprocedure);
 old_fragment text := $old$AND n.amount_vnd=r.amount_vnd AND r.amount_vnd>0
              AND n.transfer_at AT TIME ZONE 'Asia/Ho_Chi_Minh'=r.transfer_at_vn)
          THEN '2901181999999' END,$old$;
 new_fragment text := $new$AND n.amount_vnd=r.amount_vnd AND r.amount_vnd>0
              AND l.amount_vnd=-(r.amount_vnd::numeric/1000)
              AND (n.transfer_at AT TIME ZONE 'Asia/Ho_Chi_Minh'=r.transfer_at_vn
                OR (n.transfer_at AT TIME ZONE 'Asia/Ho_Chi_Minh'=date_trunc('minute',n.transfer_at AT TIME ZONE 'Asia/Ho_Chi_Minh')
                  AND date_trunc('minute',r.transfer_at_vn)=n.transfer_at AT TIME ZONE 'Asia/Ho_Chi_Minh')))
          THEN '2901181999999' END,$new$;
 acl_before aclitem[]; owner_before oid; sec_before boolean; cfg_before text[];
BEGIN
 SELECT proacl,proowner,prosecdef,proconfig INTO acl_before,owner_before,sec_before,cfg_before FROM pg_proc WHERE oid='v0_private.admin_media(uuid)'::regprocedure;
 IF (length(src)-length(replace(src,old_fragment,'')))<>length(old_fragment) OR position('''bank_verified_account'',CASE' in src)=0 THEN RAISE EXCEPTION 'unexpected admin_media baseline'; END IF;
 EXECUTE replace(src,old_fragment,new_fragment);
 IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE oid='v0_private.admin_media(uuid)'::regprocedure AND proacl IS NOT DISTINCT FROM acl_before AND proowner=owner_before AND prosecdef=sec_before AND proconfig IS NOT DISTINCT FROM cfg_before) THEN RAISE EXCEPTION 'admin_media ACL or ownership drift'; END IF;
END $patch$;
