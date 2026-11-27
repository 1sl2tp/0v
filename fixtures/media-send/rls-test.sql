\set ON_ERROR_STOP on
-- Real SET ROLE RLS, on fresh synthetic CI database after race fixture.
grant usage on schema storage to authenticated;
grant select,insert,update,delete on storage.objects to authenticated;
-- Simulate the existing broad permissive policies, restrictive guards must still win.
create policy fixture_legacy_all on storage.objects for all to authenticated using(true) with check(true);
select set_config('fixture.uid','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',false);
select set_config('fixture.jwt','{"session_id":"cccccccc-cccc-4ccc-8ccc-cccccccccccc","aal":"aal2"}',false);
select v0_private.media_send_prepare('22222222-2222-4222-8222-222222222222','0v:dddddddd-dddd-4ddd-8ddd-ddddddddddde','eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeef','',10,repeat('b',64));
select storage_key as pending_key from v0_private.media_send_ticket where client_id='0v:dddddddd-dddd-4ddd-8ddd-ddddddddddde' \gset
select storage_key as sent_key from v0_private.media_send_ticket where client_id='0v:dddddddd-dddd-4ddd-8ddd-dddddddddddd' \gset
select set_config('fixture.pending_key',:'pending_key',false);
select set_config('fixture.sent_key',:'sent_key',false);
set role authenticated;
do $rls$
declare pending text:=current_setting('fixture.pending_key'); sent text:=current_setting('fixture.sent_key'); n int;
begin
 insert into storage.objects(id,bucket_id,name,version,owner_id,metadata) values(gen_random_uuid(),'v21-media',pending,'v1','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','{"size":10,"mimetype":"image/png"}');
 if exists(select 1 from storage.objects where name=pending) then raise exception 'uncommitted_read'; end if;
 if not exists(select 1 from storage.objects where name=sent) then raise exception 'committed_read_denied'; end if;
 begin insert into storage.objects(id,bucket_id,name,owner_id) values(gen_random_uuid(),'v21-media','wrong/room/0v-ticket/fake.png','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'); raise exception 'wrong_path_allowed'; exception when insufficient_privilege then null; end;
 update storage.objects set version='tamper' where name=sent; get diagnostics n=row_count; if n<>0 then raise exception 'update_allowed'; end if;
 delete from storage.objects where name=sent; get diagnostics n=row_count; if n<>0 then raise exception 'delete_allowed'; end if;
 perform set_config('fixture.uid','bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',true);
 if exists(select 1 from storage.objects where name=sent) then raise exception 'foreign_session_read'; end if;
 raise notice 'MEDIA-SEND-01 actual authenticated RLS insert/read/update/delete passed';
end $rls$;
reset role;
