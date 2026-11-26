-- Deployed 2026-11-26: v0_admin_read_ack_count_20261126. Additive directory fields; mark_seen writes shared read state only after auth and scope checks.
CREATE OR REPLACE FUNCTION v0_private.admin_read(p_kind text, p_conversation_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
      select a.id,a.display_name,a.role,a.contact_group,a.locked_at,c.id as conversation_id,
        case when length(a.avatar_path) between 1 and 300 and a.avatar_path ~ '^[A-Za-z0-9_./-]+$' and a.avatar_path !~ '(^|/)([.]|[.][.])(/|$)' and a.avatar_path !~ '(^/|//|/$)' and a.avatar_path ~* '[.](jpg|jpeg|png|webp)$' then a.avatar_path end as avatar_path,
        case when m.sender_account_id=me then 'Bạn: ' else '' end ||
          coalesce(case ma.kind when 'image' then 'Ảnh' when 'audio' then 'Ghi âm' when 'file' then 'Tệp' else null end,
            nullif(m.body,''),'') as preview_text,
        coalesce(ma.created_at,m.created_at) as latest_at,
        coalesce(ma.created_at,m.created_at,a.created_at) as activity,
        unread.total > 0 as has_unread, unread.total as unread_count,
        own_state.last_read_at, peer_state.last_read_at as peer_last_read_at,
        (coalesce(auth.jwt()->>'aal','')='aal2') as read_ack_supported
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
      left join public.v21_read_states own_state on own_state.conversation_id=c.id and own_state.account_id=me
      left join public.v21_read_states peer_state on peer_state.conversation_id=c.id and peer_state.account_id=a.id
      cross join lateral (
        select count(*)::integer as total from public.v21_messages u
        left join public.v21_read_states rs on rs.conversation_id=c.id and rs.account_id=me
        where u.conversation_id=c.id and u.sender_account_id<>me and u.deleted_at is null
          and u.created_at>coalesce(rs.last_read_at,'epoch'::timestamptz)
      ) unread
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
$function$;

-- Deployed together with directory count/feature flag. Device acceptance pending.
-- Shared read state is explicitly the existing v21_read_states; no message/ledger mutation.
CREATE OR REPLACE FUNCTION v0_private.admin_mark_seen(p_conversation_id uuid,p_message_ids uuid[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE me uuid; before_at timestamptz; boundary timestamptz; next_at timestamptz; confirmed timestamptz; total integer;
BEGIN
  me := (v0_private.admin_read('session',null)->>'account_id')::uuid;
  IF coalesce(auth.jwt()->>'aal','') <> 'aal2' THEN RAISE EXCEPTION 'mfa_required' USING errcode='42501'; END IF;
  IF p_conversation_id IS NULL OR p_message_ids IS NULL OR cardinality(p_message_ids) NOT BETWEEN 1 AND 100 OR array_position(p_message_ids,NULL) IS NOT NULL THEN RAISE EXCEPTION 'invalid_seen_ids' USING errcode='22023'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.v21_conversations c JOIN public.v21_accounts a ON a.id=CASE WHEN c.member_a=me THEN c.member_b ELSE c.member_a END WHERE c.id=p_conversation_id AND me IN(c.member_a,c.member_b) AND a.role='user' AND a.deleted_at IS NULL AND a.locked_at IS NULL) THEN RAISE EXCEPTION 'conversation_forbidden' USING errcode='42501'; END IF;
  IF EXISTS(SELECT 1 FROM unnest(p_message_ids) AS seen(message_id) WHERE NOT EXISTS(SELECT 1 FROM public.v21_messages m WHERE m.id=seen.message_id AND m.conversation_id=p_conversation_id AND m.sender_account_id<>me AND m.deleted_at IS NULL)) THEN RAISE EXCEPTION 'message_not_in_scope' USING errcode='42501'; END IF;
  SELECT coalesce((SELECT last_read_at FROM public.v21_read_states WHERE conversation_id=p_conversation_id AND account_id=me),'epoch'::timestamptz) INTO before_at;
  -- Stop at first unseen incoming timestamp. Equal timestamps are one atomic group.
  SELECT min(m.created_at) INTO boundary FROM public.v21_messages m WHERE m.conversation_id=p_conversation_id AND m.sender_account_id<>me AND m.deleted_at IS NULL AND m.created_at>before_at AND NOT (m.id=ANY(p_message_ids));
  SELECT max(m.created_at) INTO next_at FROM public.v21_messages m WHERE m.conversation_id=p_conversation_id AND m.sender_account_id<>me AND m.deleted_at IS NULL AND m.created_at>before_at AND m.id=ANY(p_message_ids) AND (boundary IS NULL OR m.created_at<boundary);
  IF next_at IS NOT NULL THEN
    INSERT INTO public.v21_read_states(conversation_id,account_id,last_read_at) VALUES(p_conversation_id,me,next_at)
    ON CONFLICT(conversation_id,account_id) DO UPDATE SET last_read_at=excluded.last_read_at,version=public.v21_read_states.version+1,updated_at=now() WHERE public.v21_read_states.last_read_at<excluded.last_read_at;
  END IF;
  SELECT coalesce((SELECT last_read_at FROM public.v21_read_states WHERE conversation_id=p_conversation_id AND account_id=me),'epoch'::timestamptz) INTO confirmed;
  SELECT count(*)::integer INTO total FROM public.v21_messages m WHERE m.conversation_id=p_conversation_id AND m.sender_account_id<>me AND m.deleted_at IS NULL AND m.created_at>confirmed;
  RETURN jsonb_build_object('account_id',me,'conversation_id',p_conversation_id,'last_read_at',confirmed,'unread_count',total);
END; $$;
REVOKE ALL ON FUNCTION v0_private.admin_mark_seen(uuid,uuid[]) FROM public,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION v0_private.admin_mark_seen(uuid,uuid[]) TO authenticated;
CREATE OR REPLACE FUNCTION public.v0_admin_mark_seen(p_conversation_id uuid,p_message_ids uuid[])
RETURNS jsonb LANGUAGE sql SECURITY INVOKER SET search_path TO '' AS $$ SELECT v0_private.admin_mark_seen(p_conversation_id,p_message_ids) $$;
REVOKE ALL ON FUNCTION public.v0_admin_mark_seen(uuid,uuid[]) FROM public,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.v0_admin_mark_seen(uuid,uuid[]) TO authenticated;
