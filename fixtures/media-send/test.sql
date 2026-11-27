\set ON_ERROR_STOP on
-- Fresh isolated database, no production triggers or network.
create role anon nologin; create role authenticated nologin; create role service_role nologin;
create schema auth; create schema storage;
create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('fixture.uid',true),'')::uuid $$;
create function auth.jwt() returns jsonb language sql stable as $$ select coalesce(nullif(current_setting('fixture.jwt',true),''),'{}')::jsonb $$;
create table auth.sessions(id uuid primary key,user_id uuid,not_after timestamptz);
create table public.v21_accounts(id uuid primary key,auth_user_id uuid,role text,deleted_at timestamptz,locked_at timestamptz);
create table public.v21_conversations(id uuid primary key default gen_random_uuid(),member_a uuid,member_b uuid,unique(member_a,member_b));
create table public.v21_messages(id uuid primary key default gen_random_uuid(),conversation_id uuid,sender_account_id uuid,client_id text,body text,deleted_at timestamptz, unique(sender_account_id,client_id));
create table public.v21_media_assets(id uuid primary key,conversation_id uuid,message_id uuid,owner_account_id uuid,kind text,mime_type text,size_bytes bigint,storage_key text,content_hash text,width_px int,height_px int,sort_index int,deleted_at timestamptz);
create table storage.objects(id uuid primary key,bucket_id text,name text,version text,owner_id text,metadata jsonb,archived_at timestamptz,is_delete_marker boolean default false);
alter table storage.objects enable row level security;
\ir ../../references/0v-admin-read.sql
\ir ../../references/0v-admin-media-send-candidate.sql
do $$
declare me uuid:=gen_random_uuid(); peer uuid:=gen_random_uuid(); au uuid:=gen_random_uuid(); sid uuid:=gen_random_uuid(); asset uuid:=gen_random_uuid(); asset2 uuid:=gen_random_uuid(); key text:='0v:'||gen_random_uuid(); key2 text:='0v:'||gen_random_uuid(); h text:=repeat('a',64); t jsonb; ack jsonb; obj uuid:=gen_random_uuid(); obj2 uuid:=gen_random_uuid();
begin
 insert into public.v21_accounts values(me,au,'admin',null,null),(peer,gen_random_uuid(),'user',null,null);
 insert into auth.sessions values(sid,au,now()+interval '1 hour');
 perform set_config('fixture.uid',au::text,true);
 perform set_config('fixture.jwt',jsonb_build_object('session_id',sid,'aal','aal1')::text,true);
 begin perform v0_private.media_send_prepare(peer,key,asset,'',10,h); raise exception 'unexpected_success'; exception when insufficient_privilege then null; end;
 perform set_config('fixture.jwt',jsonb_build_object('session_id',sid,'aal','aal2')::text,true);
 if has_function_privilege('authenticated','v0_private.media_send_prepare(uuid,text,uuid,text,bigint,text)','execute') or has_table_privilege('authenticated','v0_private.media_send_ticket','select') then raise exception 'unsafe_grant'; end if;
 t:=v0_private.media_send_prepare(peer,key,asset,'',10,h);
 if not v0_private.media_send_upload_allowed(t->>'storage_key',au::text) or v0_private.media_send_upload_allowed(t->>'storage_key',peer::text) or v0_private.media_send_upload_allowed('wrong/path/0v-ticket/file.png',au::text) or v0_private.media_send_published(t->>'storage_key') then raise exception 'ticket_policy_failed'; end if;
 if t is distinct from v0_private.media_send_prepare(peer,key,asset,'',10,h) or exists(select 1 from public.v21_messages) then raise exception 'prepare_replay'; end if;
 begin perform v0_private.media_send_prepare(peer,key,asset,'changed',10,h); raise exception 'unexpected_success'; exception when raise_exception then if sqlerrm<>'manifest_conflict' then raise; end if; end;
 begin perform v0_private.media_send_commit(key); raise exception 'unexpected_success'; exception when raise_exception then if sqlerrm<>'bytes_not_verified' then raise; end if; end;
 -- Simulated trusted verifier only; no claim actual PNG byte verification tested.
 insert into storage.objects values(obj,'v21-media',t->>'storage_key','v1',au::text,'{"size":10,"mimetype":"image/png"}',null,false);
 update v0_private.media_send_ticket set verified_object_id=obj,verified_object_version='v1',verified_width=40,verified_height=40 where client_id=key;
 ack:=v0_private.media_send_commit(key);
 if v0_private.media_send_upload_allowed(t->>'storage_key',au::text) or not v0_private.media_send_published(t->>'storage_key') then raise exception 'published_policy_failed'; end if;
 if ack is distinct from v0_private.media_send_commit(key) or (select count(*) from public.v21_messages)<>1 or (select count(*) from public.v21_media_assets)<>1 then raise exception 'duplicate_send'; end if;
 t:=v0_private.media_send_prepare(peer,key2,asset2,'',10,h);
 insert into storage.objects values(obj2,'v21-media',t->>'storage_key','v1',au::text,'{"size":10,"mimetype":"image/png"}',null,false);
 update v0_private.media_send_ticket set verified_object_id=obj2,verified_object_version='v1',verified_width=40,verified_height=40 where client_id=key2;
 -- Inject failure after message insertion, before asset insert, verify atomic rollback.
 insert into public.v21_media_assets(id) values(asset2);
 begin perform v0_private.media_send_commit(key2); raise exception 'unexpected_success'; exception when unique_violation then null; end;
 if exists(select 1 from public.v21_messages where client_id=key2) or exists(select 1 from v0_private.media_send_ticket where client_id=key2 and message_id is not null) then raise exception 'rollback_failed'; end if;
 update public.v21_accounts set locked_at=now() where id=peer;
 begin perform v0_private.media_send_commit(key); raise exception 'unexpected_success'; exception when insufficient_privilege then null; end;
 raise notice 'MEDIA-SEND-01 private candidate permission, replay, rollback checks passed';
end $$;
