-- 0v independent admin read API; never enroll/approve a CHAT device or open a v21 app session.
-- No existing table, policy, grant or function is modified.
create schema v0_private;
revoke all on schema v0_private from public, anon, authenticated;
grant usage on schema v0_private to authenticated;

create function v0_private.admin_read(p_kind text, p_conversation_id uuid)
returns jsonb language plpgsql stable security definer set search_path = ''
as $$
declare
  me uuid;
  sid uuid;
  result jsonb;
begin
  if auth.uid() is null or coalesce(auth.jwt()->>'session_id','') = ''
     or coalesce(auth.jwt()->>'is_anonymous','false') = 'true' then
    raise exception 'authentication_required' using errcode='42501';
  end if;
  sid := (auth.jwt()->>'session_id')::uuid;
  select a.id into me from public.v21_accounts a
  join auth.sessions s on s.id=sid and s.user_id=a.auth_user_id
  where a.auth_user_id=auth.uid() and a.role='admin'
    and a.deleted_at is null and a.locked_at is null
    and (s.not_after is null or s.not_after>now())
  limit 1;
  if me is null then raise exception 'admin_required' using errcode='42501'; end if;
  if p_kind='session' and p_conversation_id is null then
    return jsonb_build_object('account_id',me,'role','admin');
  elsif p_kind='directory' and p_conversation_id is null then
    select coalesce(jsonb_agg(to_jsonb(x) order by x.activity desc,lower(x.display_name),x.id),'[]'::jsonb)
    into result
    from (
      select a.id,a.display_name,a.role,a.locked_at,c.id as conversation_id,
        case when m.sender_account_id=me then 'Bạn: ' else '' end ||
          coalesce(case ma.kind when 'image' then 'Ảnh' when 'audio' then 'Ghi âm' when 'file' then 'Tệp' else null end,
            nullif(m.body,''),'') as preview_text,
        coalesce(ma.created_at,m.created_at) as latest_at,
        coalesce(ma.created_at,m.created_at,a.created_at) as activity,
        c.id is not null and exists(
          select 1 from public.v21_messages u
          left join public.v21_read_states rs on rs.conversation_id=c.id and rs.account_id=me
          where u.conversation_id=c.id and u.sender_account_id<>me and u.deleted_at is null
            and u.created_at>coalesce(rs.last_read_at,'epoch'::timestamptz)
        ) as has_unread
      from public.v21_accounts a
      left join lateral (
        select vc.id from public.v21_conversations vc
        where me in(vc.member_a,vc.member_b) and a.id in(vc.member_a,vc.member_b) limit 1
      ) c on true
      left join lateral (
        select vm.id,vm.sender_account_id,vm.body,vm.created_at from public.v21_messages vm
        where vm.conversation_id=c.id and vm.deleted_at is null order by vm.created_at desc,vm.id desc limit 1
      ) m on true
      left join lateral (
        select vma.kind,vma.created_at from public.v21_media_assets vma
        where vma.conversation_id=c.id and vma.deleted_at is null
          and (m.id is null or vma.message_id=m.id)
        order by vma.created_at desc,vma.id desc limit 1
      ) ma on true
      where a.id<>me and a.role='user' and a.deleted_at is null and a.locked_at is null
    ) x;
    return jsonb_build_object('account_id',me,'contacts',result);
  elsif p_kind='thread' and p_conversation_id is not null then
    if not exists (
      select 1 from public.v21_conversations c
      join public.v21_accounts a on a.id=case when c.member_a=me then c.member_b else c.member_a end
      where c.id=p_conversation_id and me in(c.member_a,c.member_b)
        and a.role='user' and a.deleted_at is null and a.locked_at is null
    ) then raise exception 'conversation_forbidden' using errcode='42501'; end if;
    select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at,x.id),'[]'::jsonb) into result
    from (
      select m.id,m.conversation_id,m.sender_account_id,m.body,m.created_at
      from public.v21_messages m where m.conversation_id=p_conversation_id and m.deleted_at is null
      order by m.created_at desc,m.id desc limit 100
    ) x;
    return jsonb_build_object('account_id',me,'messages',result);
  else raise exception 'invalid_read_request' using errcode='22023';
  end if;
end;
$$;
revoke all on function v0_private.admin_read(text,uuid) from public,anon,authenticated,service_role;
grant execute on function v0_private.admin_read(text,uuid) to authenticated;

create function public.v0_admin_read(p_kind text, p_conversation_id uuid default null)
returns jsonb language sql stable security invoker set search_path = ''
as $$ select v0_private.admin_read(p_kind,p_conversation_id) $$;
revoke all on function public.v0_admin_read(text,uuid) from public,anon,authenticated,service_role;
grant execute on function public.v0_admin_read(text,uuid) to authenticated;
