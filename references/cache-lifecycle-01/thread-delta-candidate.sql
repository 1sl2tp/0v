-- CACHE-LIFECYCLE-01 stage B candidate. Review and test in isolated DB before migration.
-- Uses existing authenticated, room-scoped read RPCs; no new SECURITY DEFINER.
-- Window growth: 30 -> 50 -> 70 -> 90 -> 100. Authoritative membership, not deletion proof.
create or replace function public.v0_admin_thread_delta(
  p_conversation_id uuid,
  p_limit integer default 30,
  p_known_messages jsonb default '{}'::jsonb,
  p_known_assets jsonb default '{}'::jsonb
) returns jsonb
language plpgsql stable security invoker set search_path = ''
as $$
declare
  msg jsonb; med jsonb; selected jsonb; result jsonb; lim integer;
begin
  if p_conversation_id is null or p_limit is null or p_limit not between 1 and 100
     or jsonb_typeof(p_known_messages) is distinct from 'object'
     or jsonb_typeof(p_known_assets) is distinct from 'object'
     or octet_length(p_known_messages::text)>20000
     or octet_length(p_known_assets::text)>100000 then
    raise exception 'invalid_delta_request' using errcode='22023';
  end if;
  lim:=p_limit;
  msg:=public.v0_admin_read('thread',p_conversation_id);
  med:=public.v0_admin_media(p_conversation_id);
  if msg->>'account_id' is null or msg->>'account_id' is distinct from med->>'account_id' then
    raise exception 'scope_mismatch' using errcode='42501';
  end if;
  select coalesce(jsonb_agg(x order by x->>'created_at',x->>'id'),'[]'::jsonb) into selected
  from (select x from jsonb_array_elements(msg->'messages') x
        order by (x->>'created_at')::timestamptz desc,x->>'id' desc limit lim) q;
  with m as (
    select x, x->>'id' as id, encode(sha256(convert_to(x::text,'UTF8')),'hex') as rev
    from jsonb_array_elements(selected) x
  ), a as (
    select x, x->>'id' as id, encode(sha256(convert_to(x::text,'UTF8')),'hex') as rev
    from jsonb_array_elements(med->'assets') x
    where exists(select 1 from m where m.id=x->>'message_id')
  )
  select jsonb_build_object(
    'account_id',msg->>'account_id','room',p_conversation_id,'limit',lim,
    'available',jsonb_array_length(msg->'messages'),
    'messages',jsonb_build_object(
      'revisions',coalesce((select jsonb_object_agg(id,rev) from m),'{}'::jsonb),
      'upserts',coalesce((select jsonb_agg(jsonb_build_object('id',id,'rev',rev,'row',x)) from m where p_known_messages->>id is distinct from rev),'[]'::jsonb)),
    'assets',jsonb_build_object(
      'revisions',coalesce((select jsonb_object_agg(id,rev) from a),'{}'::jsonb),
      'upserts',coalesce((select jsonb_agg(jsonb_build_object('id',id,'rev',rev,'row',x)) from a where p_known_assets->>id is distinct from rev),'[]'::jsonb))
  ) into result;
  return result;
end $$;
revoke all on function public.v0_admin_thread_delta(uuid,integer,jsonb,jsonb) from public,anon;
grant execute on function public.v0_admin_thread_delta(uuid,integer,jsonb,jsonb) to authenticated;
