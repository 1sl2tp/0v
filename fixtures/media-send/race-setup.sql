\set ON_ERROR_STOP on
-- Fixed synthetic accounts: this is a fresh CI database only.
insert into public.v21_accounts values
 ('11111111-1111-4111-8111-111111111111','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','admin',null,null),
 ('22222222-2222-4222-8222-222222222222','bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','user',null,null);
insert into auth.sessions values('cccccccc-cccc-4ccc-8ccc-cccccccccccc','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',now()+interval '1 hour');
select set_config('fixture.uid','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',false);
select set_config('fixture.jwt','{"session_id":"cccccccc-cccc-4ccc-8ccc-cccccccccccc","aal":"aal2"}',false);
select v0_private.media_send_prepare('22222222-2222-4222-8222-222222222222','0v:dddddddd-dddd-4ddd-8ddd-dddddddddddd','eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee','',10,repeat('b',64));
insert into storage.objects(id,bucket_id,name,version,owner_id,metadata)
select 'ffffffff-ffff-4fff-8fff-ffffffffffff','v21-media',storage_key,'v1',auth_user::text,'{"size":10,"mimetype":"image/png"}'
from v0_private.media_send_ticket where client_id='0v:dddddddd-dddd-4ddd-8ddd-dddddddddddd';
update v0_private.media_send_ticket set verified_object_id='ffffffff-ffff-4fff-8fff-ffffffffffff',verified_object_version='v1',verified_width=40,verified_height=40 where client_id='0v:dddddddd-dddd-4ddd-8ddd-dddddddddddd';
