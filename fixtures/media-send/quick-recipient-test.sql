\set ON_ERROR_STOP on
\ir ../../references/0v-admin-quick-recipient-candidate.sql
-- Synthetic values only. All production recipient provisioning remains private.
update v0_private.media_qr_recipient set recipient_name='FIXTURE ADMIN',institution='Fixture Bank' where account_id='11111111-1111-4111-8111-111111111111';
select set_config('fixture.uid','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',false);
select set_config('fixture.jwt','{"session_id":"cccccccc-cccc-4ccc-8ccc-cccccccccccc","aal":"aal2"}',false);
set role authenticated;
do $test$
declare v jsonb;
begin
 v:=public.v0_admin_quick_recipient();
 if v->>'name' is distinct from 'FIXTURE ADMIN' or v->>'number' is distinct from '00123456' or v->>'configured' is distinct from 'true' then raise exception 'recipient projection';end if;
 if has_table_privilege('authenticated','v0_private.media_qr_recipient','update') or has_function_privilege('anon','public.v0_admin_quick_recipient()','execute') then raise exception 'unsafe grant';end if;
 perform set_config('fixture.jwt','{"session_id":"cccccccc-cccc-4ccc-8ccc-cccccccccccc","aal":"aal1"}',true);
 begin perform public.v0_admin_quick_recipient();raise exception 'unexpected success';exception when insufficient_privilege then null;end;
end $test$;
reset role;
