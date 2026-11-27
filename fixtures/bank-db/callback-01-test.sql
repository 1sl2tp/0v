-- Isolated CI PostgreSQL only. Previous bill fixture rolls back.
create role anon nologin;
create role authenticated nologin;
create role service_role nologin;
create schema auth;
create schema v21_private;
create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('fixture.uid',true),'')::uuid $$;
create function auth.jwt() returns jsonb language sql stable as $$ select coalesce(nullif(current_setting('fixture.jwt',true),''),'{}')::jsonb $$;
create table auth.sessions(id uuid primary key,user_id uuid,not_after timestamptz);
create table public.v21_accounts(id uuid primary key,auth_user_id uuid,role text,deleted_at timestamptz,locked_at timestamptz,display_name text,created_at timestamptz default now(),contact_group text);
create table public.v21_conversations(id uuid primary key default gen_random_uuid(),member_a uuid,member_b uuid,unique(member_a,member_b));
create table public.v21_messages(id uuid primary key default gen_random_uuid(),conversation_id uuid,sender_account_id uuid,client_id text,body text,created_at timestamptz default now(),deleted_at timestamptz, constraint v21_messages_sender_account_id_client_id_key unique(sender_account_id,client_id));
create table public.zalo_user_links(zalo_id text primary key,chat_account_id uuid,linked_by_account_id uuid,linked_at timestamptz);
create table public.zalo_message_links(chat_message_id uuid,zalo_message_id text,chat_account_id uuid,zalo_id text,direction text,state text,attempt_count int,created_at timestamptz,updated_at timestamptz);
create unique index callback_fixture_inbound on public.zalo_message_links(zalo_message_id) where direction='inbound' and zalo_message_id is not null;
create table public.v21_contact_private_phones(contact_account_id uuid primary key,phone_primary text,phone_secondary text,edited_by_account_id uuid,updated_at timestamptz default now());
-- Exact canonical ingress from chat @ 9dd0f98, with fixture schema only.
create or replace function public.v21_zalo_ingress(
  p_zalo_id text,
  p_zalo_message_id text,
  p_body text,
  p_event_at timestamptz
) returns uuid
language plpgsql
security definer
set search_path to 'public','v21_private','auth'
as $$
declare
  v_zalo_id text := btrim(coalesce(p_zalo_id,''));
  v_external_id text := btrim(coalesce(p_zalo_message_id,''));
  v_body text := btrim(coalesce(p_body,''));
  v_event_at timestamptz := coalesce(p_event_at,now());
  v_link public.zalo_user_links%rowtype;
  v_member_a uuid;
  v_member_b uuid;
  v_conversation_id uuid;
  v_client_id text;
  v_message_id uuid;
begin
  if v_zalo_id='' or v_external_id='' or v_body='' or char_length(v_body)>8000 then
    return null;
  end if;

  select * into v_link
  from public.zalo_user_links
  where zalo_id=v_zalo_id;

  if v_link.chat_account_id is null or v_event_at < v_link.linked_at then
    return null;
  end if;

  if not exists(
    select 1 from public.v21_accounts a
    where a.id=v_link.chat_account_id and a.role='user' and a.deleted_at is null
  ) or not exists(
    select 1 from public.v21_accounts a
    where a.id=v_link.linked_by_account_id and a.role='admin' and a.deleted_at is null
  ) then
    return null;
  end if;

  if v_link.linked_by_account_id::text < v_link.chat_account_id::text then
    v_member_a:=v_link.linked_by_account_id;
    v_member_b:=v_link.chat_account_id;
  else
    v_member_a:=v_link.chat_account_id;
    v_member_b:=v_link.linked_by_account_id;
  end if;

  insert into public.v21_conversations(member_a,member_b)
  values(v_member_a,v_member_b)
  on conflict(member_a,member_b)
  do update set member_a=excluded.member_a
  returning id into v_conversation_id;

  v_client_id := 'zalo:' || left(v_zalo_id,40) || ':' || left(v_external_id,72);

  insert into public.v21_messages(
    conversation_id,sender_account_id,client_id,body,created_at
  ) values(
    v_conversation_id,v_link.chat_account_id,v_client_id,v_body,v_event_at
  )
  on conflict on constraint v21_messages_sender_account_id_client_id_key
  do nothing
  returning id into v_message_id;

  if v_message_id is null then
    select m.id into v_message_id
    from public.v21_messages m
    where m.sender_account_id=v_link.chat_account_id
      and m.client_id=v_client_id
    limit 1;
  end if;

  insert into public.zalo_message_links(
    chat_message_id,zalo_message_id,chat_account_id,zalo_id,direction,state,attempt_count,created_at,updated_at
  ) values(
    v_message_id,v_external_id,v_link.chat_account_id,v_zalo_id,'inbound','received',0,now(),now()
  )
  on conflict(zalo_message_id)
    where direction='inbound' and zalo_message_id is not null
  do nothing;

  return v_message_id;
end;
$$;
\ir ../../references/0v-admin-read.sql
\ir ../../references/0v-callback-01-server.sql
insert into public.v21_accounts(id,auth_user_id,role,contact_group) values
('00000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','admin',null),
('00000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','user','customer'),
('00000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000003','user','other'),
('00000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000004','user','friend'),
('00000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000005','admin',null);
insert into auth.sessions values('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001',now()+interval '1 hour');
insert into public.zalo_user_links values
('fixture-a','00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000001',now()-interval '1 day'),
('fixture-b','00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000001',now()-interval '1 day');
do $$ declare a uuid;b uuid;room uuid; result jsonb; begin
 if has_function_privilege('authenticated','public.v0_zalo_missed_call_ingress(text,text,timestamptz)','execute') or has_function_privilege('anon','public.v0_callback_contact(uuid,text)','execute') then raise exception 'ACL'; end if;
 a:=public.v0_zalo_missed_call_ingress('fixture-a','disabled',now());
 if a is null or exists(select 1 from v0_private.missed_call_events where auto_reply_id is not null) then raise exception 'disabled gate'; end if;
 update v0_private.callback_settings set enabled_at=now()-interval '1 hour';
 a:=public.v0_zalo_missed_call_ingress('fixture-a','new-a',now());
 b:=public.v0_zalo_missed_call_ingress('fixture-b','new-b',now());
 if a is null or b is null or a= b then raise exception 'ingress'; end if;
 if public.v0_zalo_missed_call_ingress('fixture-a','new-a',now()) is distinct from a then raise exception 'replay'; end if;
 if public.v0_zalo_missed_call_ingress('fixture-b','new-a',now()) is not null then raise exception 'cross-link collision'; end if;
 if public.v0_zalo_missed_call_ingress('not-linked','unlinked',now()) is not null then raise exception 'unlinked'; end if;
 perform public.v21_zalo_ingress('fixture-a','plain','Cuộc gọi nhỡ',now());
 perform public.v0_zalo_missed_call_ingress('fixture-a','plain',now());
 perform public.v0_zalo_missed_call_ingress('fixture-a','old',now()-interval '10 minutes');
 if (select count(*) from public.v21_messages where body='Em sẽ gọi lại ngay ạ.')<>2 or (select count(*) from v0_private.missed_call_events where auto_reply_id is not null)<>2 then raise exception 'exactly one per active linked event'; end if;
 select conversation_id into room from v0_private.missed_call_events where message_id=a;
 perform set_config('fixture.uid','10000000-0000-0000-0000-000000000001',true);
 perform set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal2"}',true);
 insert into public.v21_contact_private_phones(contact_account_id,phone_secondary,edited_by_account_id) values('00000000-0000-0000-0000-000000000002','+84900000001','00000000-0000-0000-0000-000000000001');
 result:=public.v0_callback_contact(room,'090 000 0002');
 if result->>'phone_primary' is distinct from '0900000002' or result->>'phone_secondary' is distinct from '+84900000001' then raise exception 'phone save'; end if;
 result:=public.v0_callback_contact(room,'0900000003');
 if result->>'phone_primary' is distinct from '0900000002' then raise exception 'existing number overwrite'; end if;
 begin perform public.v0_callback_contact(room,'bad'); raise exception 'invalid phone accepted'; exception when sqlstate '22023' then null; end;
 begin perform public.v0_callback_contact('ffffffff-ffff-ffff-ffff-ffffffffffff'); raise exception 'other room accepted'; exception when insufficient_privilege then null; end;
 perform set_config('fixture.jwt','{"session_id":"20000000-0000-0000-0000-000000000001","aal":"aal1"}',true);
 begin perform public.v0_callback_contact(room); raise exception 'aal1 accepted'; exception when insufficient_privilege then null; end;
end $$;
