-- Independent 0v admin actions. Only authenticated, active admin can send to their own eligible contacts.
-- Existing message table triggers preserve synchronization and notification behavior.
-- No v21 device session or broad table grants.
create function v0_private.admin_send_text(p_contact_id uuid,p_client_id text,p_body text)
returns jsonb language plpgsql volatile security definer set search_path=''
as $$
declare
  me uuid;
  room uuid;
  mid uuid;
  existing public.v21_messages;
  body_text text:=btrim(coalesce(p_body,''));
begin
  me:=(v0_private.admin_read('session',null)->>'account_id')::uuid;
  if body_text='' or char_length(body_text)>8000 then raise exception 'invalid_message' using errcode='22023'; end if;
  if p_client_id is null or p_client_id !~ '^0v:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then raise exception 'invalid_client_id' using errcode='22023'; end if;
  if p_contact_id is null or p_contact_id=me or not exists (
    select 1 from public.v21_accounts a where a.id=p_contact_id and a.role='user' and a.deleted_at is null and a.locked_at is null
  ) then raise exception 'contact_forbidden' using errcode='42501'; end if;
  insert into public.v21_conversations(member_a,member_b)
    values(least(me,p_contact_id),greatest(me,p_contact_id))
    on conflict(member_a,member_b) do nothing returning id into room;
  if room is null then select c.id into room from public.v21_conversations c where c.member_a=least(me,p_contact_id) and c.member_b=greatest(me,p_contact_id); end if;
  if room is null then raise exception 'conversation_unavailable'; end if;
  insert into public.v21_messages(conversation_id,sender_account_id,client_id,body)
    values(room,me,p_client_id,body_text)
    on conflict on constraint v21_messages_sender_account_id_client_id_key do nothing returning id into mid;
  if mid is null then
    select * into existing from public.v21_messages m where m.sender_account_id=me and m.client_id=p_client_id;
    if existing.id is null or existing.conversation_id<>room or existing.body is distinct from body_text or existing.deleted_at is not null then raise exception 'client_id_conflict'; end if;
    mid:=existing.id;
  end if;
  return jsonb_build_object('account_id',me,'conversation_id',room,'message_id',mid);
end;
$$;
revoke all on function v0_private.admin_send_text(uuid,text,text) from public,anon,authenticated,service_role;
grant execute on function v0_private.admin_send_text(uuid,text,text) to authenticated;
create function public.v0_admin_send_text(p_contact_id uuid,p_client_id text,p_body text)
returns jsonb language sql volatile security invoker set search_path=''
as $$ select v0_private.admin_send_text(p_contact_id,p_client_id,p_body) $$;
revoke all on function public.v0_admin_send_text(uuid,text,text) from public,anon,authenticated,service_role;
grant execute on function public.v0_admin_send_text(uuid,text,text) to authenticated;
