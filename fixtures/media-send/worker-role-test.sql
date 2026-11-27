\set ON_ERROR_STOP on
\ir ../../references/0v-admin-media-qr-worker-candidate.sql
do $role$
begin
 if has_function_privilege('v0_qr_worker','v0_private.media_send_commit(text)','execute') or has_table_privilege('v0_qr_worker','v0_private.media_send_ticket','update') or has_table_privilege('v0_qr_worker','v0_private.media_qr_recipient','select') then raise exception 'worker direct grant';end if;
 if pg_has_role('authenticated','v0_qr_worker','member') or pg_has_role('anon','v0_qr_worker','member') or pg_has_role('service_role','v0_qr_worker','member') then raise exception 'worker role leaked';end if;
 if not has_function_privilege('v0_qr_worker','v0_private.media_qr_target(text)','execute') or not has_function_privilege('v0_qr_worker','v0_private.media_qr_attest(text,uuid,text,text,uuid,integer,integer)','execute') then raise exception 'worker missing grant';end if;
end $role$;
set role v0_qr_worker;
select set_config('fixture.uid','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',false);
select set_config('fixture.jwt','{"session_id":"cccccccc-cccc-4ccc-8ccc-cccccccccccc","aal":"aal1"}',false);
do $role$
begin
 begin perform v0_private.media_send_prepare('22222222-2222-4222-8222-222222222222','0v:dddddddd-dddd-4ddd-8ddd-dddddddddddf','eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee','',10,repeat('b',64));raise exception 'aal1 allowed';exception when insufficient_privilege then null;end;
end $role$;
reset role;
