-- Display-only compatibility, no event inserts, replies, grants or table writes.
begin;
create or replace function v0_private.callback_contact(p_room uuid,p_add_primary text default null)
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
 (select q.message_id,q.event_at,q.source,q.auto_reply_id,q.provenance from (
   select message_id,event_at,source,auto_reply_id,'verified_event'::text as provenance
   from v0_private.missed_call_events where conversation_id=p_room and admin_id=me and contact_id=peer
   union all
   -- Presentation only: linked inbound legacy notice text, never an auto-reply trigger.
   select m.id,m.created_at,'zalo_missed_call',null::uuid,'linked_notice_text'
   from public.v21_messages m
   where m.conversation_id=p_room and m.sender_account_id=peer and m.deleted_at is null and m.body='Cuộc gọi nhỡ'
     and exists(select 1 from public.zalo_message_links l join public.zalo_user_links u on u.zalo_id=l.zalo_id and u.chat_account_id=l.chat_account_id
       where l.chat_message_id=m.id and l.direction='inbound' and l.chat_account_id=peer and u.linked_by_account_id=me and m.created_at>=u.linked_at)
     and not exists(select 1 from v0_private.missed_call_events e where e.message_id=m.id)
 ) q order by q.event_at desc,q.message_id desc limit 100) e;
 return jsonb_build_object('account_id',me,'conversation_id',p_room,'contact_id',peer,'phone_primary',phones.phone_primary,'phone_secondary',phones.phone_secondary,'events',events);
end $$;
commit;
