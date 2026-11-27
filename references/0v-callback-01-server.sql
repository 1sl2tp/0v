-- CALLBACK-01 proposed server contract. Review/fixture only; do not deploy from this file automatically.
-- Existing canonical ingress and outbound triggers remain the owners.
begin;
create table v0_private.missed_call_events(
 message_id uuid primary key references public.v21_messages(id),
 conversation_id uuid not null references public.v21_conversations(id),
 contact_id uuid not null references public.v21_accounts(id),
 admin_id uuid not null references public.v21_accounts(id),
 source text not null check(source='zalo_missed_call'),
 event_at timestamptz not null,
 auto_reply_id uuid references public.v21_messages(id),
 recorded_at timestamptz not null default now()
);
alter table v0_private.missed_call_events enable row level security;
revoke all on v0_private.missed_call_events from public,anon,authenticated,service_role;
create table v0_private.callback_settings(
 singleton boolean primary key default true check(singleton),
 enabled_at timestamptz
);
alter table v0_private.callback_settings enable row level security;
revoke all on v0_private.callback_settings from public,anon,authenticated,service_role;
insert into v0_private.callback_settings(singleton,enabled_at) values(true,null);

create function v0_private.zalo_missed_call_ingress(p_zalo_id text,p_zalo_message_id text,p_event_at timestamptz)
returns uuid language plpgsql volatile security definer set search_path='' as $$
declare
 mid uuid; rid uuid; msg public.v21_messages%rowtype; lk public.zalo_user_links%rowtype;
 enabled timestamptz; prior uuid; eligible boolean;
begin
 if p_event_at is null or p_event_at>now()+interval '1 minute' or nullif(btrim(p_zalo_id),'') is null or nullif(btrim(p_zalo_message_id),'') is null then return null; end if;
 perform pg_advisory_xact_lock(hashtextextended('callback:zalo:'||btrim(p_zalo_message_id),0));
 select * into lk from public.zalo_user_links where zalo_id=btrim(p_zalo_id);
 if lk.chat_account_id is null or p_event_at<lk.linked_at then return null; end if;
 select chat_message_id into prior from public.zalo_message_links where direction='inbound' and zalo_message_id=btrim(p_zalo_message_id);
 if prior is not null then
   -- A legacy text message is never promoted into a new callback event on replay.
   return prior;
 end if;
 mid:=public.v21_zalo_ingress(p_zalo_id,p_zalo_message_id,'Cuộc gọi nhỡ',p_event_at);
 if mid is null then return null; end if;
 select * into msg from public.v21_messages where id=mid and deleted_at is null;
 if msg.id is null or msg.sender_account_id<>lk.chat_account_id or msg.body<>'Cuộc gọi nhỡ' or msg.created_at is distinct from p_event_at
 or not exists(select 1 from public.zalo_message_links l where l.direction='inbound' and l.chat_message_id=mid and l.zalo_message_id=btrim(p_zalo_message_id) and l.zalo_id=btrim(p_zalo_id))
 or not exists(select 1 from public.v21_conversations c where c.id=msg.conversation_id and lk.chat_account_id in(c.member_a,c.member_b) and lk.linked_by_account_id in(c.member_a,c.member_b))
 then raise exception 'callback_scope_mismatch'; end if;
 insert into v0_private.missed_call_events(message_id,conversation_id,contact_id,admin_id,source,event_at)
 values(mid,msg.conversation_id,lk.chat_account_id,lk.linked_by_account_id,'zalo_missed_call',p_event_at)
 on conflict(message_id) do nothing;
 if not found then return mid; end if;
 select enabled_at into enabled from v0_private.callback_settings where singleton;
 select exists(select 1 from public.v21_accounts a where a.id=lk.chat_account_id and a.role='user' and a.contact_group='customer' and a.deleted_at is null and a.locked_at is null)
 and exists(select 1 from public.v21_accounts a where a.id=lk.linked_by_account_id and a.role='admin' and a.deleted_at is null and a.locked_at is null) into eligible;
 -- Fail closed until explicitly enabled. Do not auto-reply to delayed/history replay.
 if eligible and enabled is not null and p_event_at>=enabled and p_event_at>=now()-interval '5 minutes' then
  insert into public.v21_messages(conversation_id,sender_account_id,client_id,body)
  values(msg.conversation_id,lk.linked_by_account_id,'0v:'||mid::text,'Em sẽ gọi lại ngay ạ.')
  on conflict on constraint v21_messages_sender_account_id_client_id_key do nothing returning id into rid;
  if rid is null then
   select id into rid from public.v21_messages where sender_account_id=lk.linked_by_account_id and client_id='0v:'||mid::text and conversation_id=msg.conversation_id and body='Em sẽ gọi lại ngay ạ.' and deleted_at is null;
   if rid is null then raise exception 'callback_client_id_conflict'; end if;
  end if;
  update v0_private.missed_call_events set auto_reply_id=rid where message_id=mid;
 end if;
 return mid;
end $$;
revoke all on function v0_private.zalo_missed_call_ingress(text,text,timestamptz) from public,anon,authenticated,service_role;
grant usage on schema v0_private to service_role;
grant execute on function v0_private.zalo_missed_call_ingress(text,text,timestamptz) to service_role;
-- Service-only authenticated bridge ingress; never callable by browser.
create function public.v0_zalo_missed_call_ingress(p_zalo_id text,p_zalo_message_id text,p_event_at timestamptz)
returns uuid language plpgsql volatile security invoker set search_path='' as $$
 select v0_private.zalo_missed_call_ingress(p_zalo_id,p_zalo_message_id,p_event_at)
$$;
revoke all on function public.v0_zalo_missed_call_ingress(text,text,timestamptz) from public,anon,authenticated,service_role;
grant execute on function public.v0_zalo_missed_call_ingress(text,text,timestamptz) to service_role;

-- Reuse 0v admin session validation and the existing private phonebook.
create function v0_private.callback_contact(p_room uuid,p_add_primary text default null)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare me uuid; peer uuid; num text; phones public.v21_contact_private_phones%rowtype; events jsonb;
begin
 me:=(v0_private.admin_read('session',null)->>'account_id')::uuid;
 if coalesce(auth.jwt()->>'aal','')<>'aal2' then raise exception 'aal2_required' using errcode='42501'; end if;
 select a.id into peer from public.v21_conversations c join public.v21_accounts a on a.id=case when c.member_a=me then c.member_b else c.member_a end
 where c.id=p_room and me in(c.member_a,c.member_b) and a.role='user' and a.deleted_at is null and a.locked_at is null;
 if peer is null then raise exception 'conversation_forbidden' using errcode='42501'; end if;
 if p_add_primary is not null then
  num:=regexp_replace(btrim(p_add_primary),'[\s().-]','','g');
  if num !~ '^\+?[0-9]{9,15}$' then raise exception 'phone_invalid' using errcode='22023'; end if;
  insert into public.v21_contact_private_phones(contact_account_id,phone_primary,edited_by_account_id)
  values(peer,num,me) on conflict(contact_account_id) do update
  set phone_primary=excluded.phone_primary,edited_by_account_id=me,updated_at=now()
  where public.v21_contact_private_phones.phone_primary is null;
 end if;
 select * into phones from public.v21_contact_private_phones where contact_account_id=peer;
 select coalesce(jsonb_agg(to_jsonb(e) order by e.event_at,e.message_id),'[]'::jsonb) into events from
 (select message_id,event_at,source,auto_reply_id from v0_private.missed_call_events where conversation_id=p_room and admin_id=me and contact_id=peer order by event_at desc,message_id desc limit 100) e;
 return jsonb_build_object('account_id',me,'conversation_id',p_room,'contact_id',peer,'phone_primary',phones.phone_primary,'phone_secondary',phones.phone_secondary,'events',events);
end $$;
revoke all on function v0_private.callback_contact(uuid,text) from public,anon,authenticated,service_role;
grant execute on function v0_private.callback_contact(uuid,text) to authenticated;
create function public.v0_callback_contact(p_room uuid,p_add_primary text default null)
returns jsonb language sql volatile security invoker set search_path='' as $$ select v0_private.callback_contact(p_room,p_add_primary) $$;
revoke all on function public.v0_callback_contact(uuid,text) from public,anon,authenticated,service_role;
grant execute on function public.v0_callback_contact(uuid,text) to authenticated;
commit;
