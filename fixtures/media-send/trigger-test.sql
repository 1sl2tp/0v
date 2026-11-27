\set ON_ERROR_STOP on
-- Isolated test DB; no HTTP dispatch. Exact trigger functions from read-only catalog.
create schema v21_private;
alter table public.v21_accounts add column contact_group text;
alter table public.v21_messages add column created_at timestamptz default now();
create table public.zalo_user_links(chat_account_id uuid, linked_by_account_id uuid,zalo_id text,linked_at timestamptz);
create table public.zalo_message_links(chat_message_id uuid,chat_account_id uuid,zalo_id text,direction text,state text,attempt_count int,delivery_part text,created_at timestamptz,updated_at timestamptz);
create unique index fixture_zalo_unique on public.zalo_message_links(chat_message_id,delivery_part) where direction='outbound' and chat_message_id is not null;
create table public.v21_push_outbox(message_id uuid,recipient_account_id uuid,sender_account_id uuid,conversation_id uuid,state text,available_at timestamptz,unique(message_id,recipient_account_id));
create table public.chat_bank_bill_receipts(media_asset_id uuid primary key,message_id uuid,customer_account_id uuid,sent_at timestamptz,status text,reason text);
-- No dispatch key, and no net extension in this fixture. Bank-positive delivery not tested.
create function public.chat_customer_summary_runtime_config() returns table(scan_key text) language sql as $fixture$ select null::text $fixture$;
CREATE OR REPLACE FUNCTION public.chat_bank_bill_queue_amount_image()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare v_sender uuid;v_sent timestamptz;v_dispatch_key text;
begin
 if new.kind<>'image' or new.deleted_at is not null or new.message_id is null then return new; end if;
 select m.sender_account_id,m.created_at into v_sender,v_sent
 from public.v21_messages m join public.v21_accounts a on a.id=m.sender_account_id
 where m.id=new.message_id and m.deleted_at is null
   and m.sender_account_id=new.owner_account_id
   and a.role='user' and a.contact_group='customer'
   and a.deleted_at is null and a.locked_at is null;
 if v_sender is null then return new; end if;
 insert into public.chat_bank_bill_receipts(media_asset_id,message_id,customer_account_id,sent_at,status,reason)
 values(new.id,new.message_id,v_sender,v_sent,'queued','waiting_for_bank_transaction_match')
 on conflict(media_asset_id) do nothing;
 select scan_key into v_dispatch_key from public.chat_customer_summary_runtime_config();
 if nullif(v_dispatch_key,'') is not null then
   perform net.http_post(
     url:='https://vtqhbhrkdxirqeqkgylo.supabase.co/functions/v1/v21-bank-bill-event',
     headers:=jsonb_build_object('content-type','application/json','x-internal-dispatch-key',v_dispatch_key),
     body:=jsonb_build_object('asset_id',new.id::text),timeout_milliseconds:=35000
   );
 end if;
 return new;
exception when others then
 raise warning 'bank169_customer_image_dispatch_error: %',sqlerrm;
 return new;
end
$function$;

CREATE OR REPLACE FUNCTION v21_private.enqueue_admin_push()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'v21_private', 'auth'
AS $function$
declare
  v_sender_role text;
  v_recipient_id uuid;
  v_recipient_role text;
begin
  if new.deleted_at is not null then return new; end if;

  select a.role into v_sender_role
  from public.v21_accounts a
  where a.id=new.sender_account_id
    and a.deleted_at is null
    and a.locked_at is null;
  if v_sender_role<>'user' then return new; end if;

  select case
    when c.member_a=new.sender_account_id then c.member_b
    when c.member_b=new.sender_account_id then c.member_a
    else null
  end
  into v_recipient_id
  from public.v21_conversations c
  where c.id=new.conversation_id;
  if v_recipient_id is null then return new; end if;

  select a.role into v_recipient_role
  from public.v21_accounts a
  where a.id=v_recipient_id
    and a.deleted_at is null
    and a.locked_at is null;
  if v_recipient_role<>'admin' then return new; end if;

  insert into public.v21_push_outbox(
    message_id,recipient_account_id,sender_account_id,conversation_id,state,available_at
  ) values(
    new.id,v_recipient_id,new.sender_account_id,new.conversation_id,'pending',now()
  )
  on conflict(message_id,recipient_account_id) do nothing;

  return new;
exception when others then
  -- Push is secondary delivery and must never block canonical message insertion.
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION v21_private.enqueue_zalo_outbound()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'v21_private', 'auth'
AS $function$
declare
  v_sender_role text;
  v_peer uuid;
  v_peer_role text;
  v_link public.zalo_user_links%rowtype;
begin
  if new.deleted_at is not null or btrim(coalesce(new.body,''))='' then
    return new;
  end if;
  select a.role into v_sender_role from public.v21_accounts a
  where a.id=new.sender_account_id and a.deleted_at is null;
  if v_sender_role <> 'admin' then return new; end if;

  select case when c.member_a=new.sender_account_id then c.member_b else c.member_a end
  into v_peer
  from public.v21_conversations c
  where c.id=new.conversation_id and new.sender_account_id in (c.member_a,c.member_b);
  if v_peer is null then return new; end if;

  select a.role into v_peer_role from public.v21_accounts a
  where a.id=v_peer and a.deleted_at is null;
  if v_peer_role <> 'user' then return new; end if;

  select * into v_link from public.zalo_user_links l
  where l.chat_account_id=v_peer and l.linked_by_account_id=new.sender_account_id;
  if v_link.chat_account_id is null or new.created_at < v_link.linked_at then return new; end if;

  insert into public.zalo_message_links(
    chat_message_id,chat_account_id,zalo_id,direction,state,attempt_count,
    delivery_part,created_at,updated_at
  ) values(
    new.id,v_peer,v_link.zalo_id,'outbound','pending',0,
    'text',now(),now()
  )
  on conflict(chat_message_id,delivery_part)
    where direction='outbound' and chat_message_id is not null
  do nothing;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION v21_private.enqueue_zalo_media_outbound()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'v21_private', 'auth'
AS $function$
declare
  v_message public.v21_messages%rowtype;
  v_sender_role text;
  v_peer uuid;
  v_peer_role text;
  v_link public.zalo_user_links%rowtype;
begin
  if new.deleted_at is not null or new.message_id is null
     or new.kind not in ('image','audio','file') then return new; end if;

  select * into v_message from public.v21_messages m
  where m.id=new.message_id and m.deleted_at is null;
  if v_message.id is null then return new; end if;

  select a.role into v_sender_role from public.v21_accounts a
  where a.id=v_message.sender_account_id and a.deleted_at is null;
  if v_sender_role <> 'admin' then return new; end if;

  select case when c.member_a=v_message.sender_account_id then c.member_b else c.member_a end
  into v_peer
  from public.v21_conversations c
  where c.id=v_message.conversation_id
    and v_message.sender_account_id in(c.member_a,c.member_b);
  if v_peer is null then return new; end if;

  select a.role into v_peer_role from public.v21_accounts a
  where a.id=v_peer and a.deleted_at is null;
  if v_peer_role <> 'user' then return new; end if;

  select * into v_link from public.zalo_user_links l
  where l.chat_account_id=v_peer
    and l.linked_by_account_id=v_message.sender_account_id;
  if v_link.chat_account_id is null or v_message.created_at<v_link.linked_at then return new; end if;

  insert into public.zalo_message_links(
    chat_message_id,chat_account_id,zalo_id,direction,state,attempt_count,
    delivery_part,created_at,updated_at
  ) values(
    v_message.id,v_peer,v_link.zalo_id,'outbound','pending',0,
    'media',now(),now()
  )
  on conflict(chat_message_id,delivery_part)
    where direction='outbound' and chat_message_id is not null
  do nothing;
  return new;
end;
$function$;

create trigger fixture_zalo_text after insert on public.v21_messages for each row execute function v21_private.enqueue_zalo_outbound();
create trigger fixture_push after insert on public.v21_messages for each row execute function v21_private.enqueue_admin_push();
create trigger fixture_zalo_media after insert on public.v21_media_assets for each row execute function v21_private.enqueue_zalo_media_outbound();
create trigger fixture_bank after insert on public.v21_media_assets for each row execute function public.chat_bank_bill_queue_amount_image();
insert into public.zalo_user_links values('22222222-2222-4222-8222-222222222222','11111111-1111-4111-8111-111111111111','fixture-zalo',now()-interval '1 day');
update public.v21_accounts set contact_group='customer' where id='22222222-2222-4222-8222-222222222222';
select set_config('fixture.uid','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',false);
select set_config('fixture.jwt','{"session_id":"cccccccc-cccc-4ccc-8ccc-cccccccccccc","aal":"aal2"}',false);
do $test$
declare t jsonb; ack jsonb; aid uuid:=gen_random_uuid(); obj uuid:=gen_random_uuid(); key text:='0v:'||gen_random_uuid(); mid uuid;
begin
 t:=v0_private.media_send_prepare('22222222-2222-4222-8222-222222222222',key,aid,'',10,repeat('b',64));
 insert into storage.objects(id,bucket_id,name,version,owner_id,metadata) values(obj,'v21-media',t->>'storage_key','v1','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','{"size":10,"mimetype":"image/png"}');
 update v0_private.media_send_ticket set verified_object_id=obj,verified_object_version='v1',verified_width=40,verified_height=40 where client_id=key;
 ack:=v0_private.media_send_commit(key);mid:=(ack->>'message_id')::uuid;
 if ack is distinct from v0_private.media_send_commit(key) then raise exception 'ack mismatch'; end if;
 if (select count(*) from public.zalo_message_links where chat_message_id=mid and delivery_part='media')<>1 or exists(select 1 from public.zalo_message_links where chat_message_id=mid and delivery_part='text') then raise exception 'zalo wrong part'; end if;
 if exists(select 1 from public.v21_push_outbox where message_id=mid) or exists(select 1 from public.chat_bank_bill_receipts where message_id=mid) then raise exception 'admin image routed to push/bank'; end if;
 -- Fail asset insertion after text outbox creation; transaction must roll back the outbox too.
 aid:=gen_random_uuid(); obj:=gen_random_uuid(); key:='0v:'||gen_random_uuid();
 t:=v0_private.media_send_prepare('22222222-2222-4222-8222-222222222222',key,aid,'fixture caption',10,repeat('c',64));
 insert into storage.objects(id,bucket_id,name,version,owner_id,metadata) values(obj,'v21-media',t->>'storage_key','v1','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','{"size":10,"mimetype":"image/png"}');
 update v0_private.media_send_ticket set verified_object_id=obj,verified_object_version='v1',verified_width=40,verified_height=40 where client_id=key;
 insert into public.v21_media_assets(id) values(aid);
 begin perform v0_private.media_send_commit(key);raise exception 'unexpected_success';exception when unique_violation then null;end;
 if exists(select 1 from public.v21_messages where client_id=key) or (select count(*) from public.zalo_message_links)<>1 then raise exception 'outbox rollback'; end if;
 raise notice 'MEDIA-SEND-01 actual trigger definitions: one media, no empty text, no admin Push/Bank, outbox rollback passed';
end $test$;
