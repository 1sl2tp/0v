-- 0v private media access. No public bucket, no legacy session dependency, no media mutation.
create function v0_private.can_read_media(p_key text)
returns boolean language plpgsql stable security definer set search_path=''
as $$
declare me uuid;
begin
  me:=(v0_private.admin_read('session',null)->>'account_id')::uuid;
  return exists (
    select 1 from public.v21_media_assets a
    join public.v21_messages m on m.id=a.message_id and m.conversation_id=a.conversation_id
    join public.v21_conversations c on c.id=a.conversation_id
    join public.v21_accounts p on p.id=case when c.member_a=me then c.member_b else c.member_a end
    where a.storage_key=p_key and a.deleted_at is null and m.deleted_at is null
      and me in(c.member_a,c.member_b) and p.role='user' and p.deleted_at is null and p.locked_at is null
  );
exception when insufficient_privilege then return false;
end;
$$;
revoke all on function v0_private.can_read_media(text) from public,anon,authenticated,service_role;
grant execute on function v0_private.can_read_media(text) to authenticated;
create policy v0_admin_media_read on storage.objects for select to authenticated
using (bucket_id='v21-media' and v0_private.can_read_media(name));

create function v0_private.admin_media(p_conversation_id uuid)
returns jsonb language plpgsql stable security definer set search_path=''
as $$
declare me uuid; result jsonb;
begin
  me:=(v0_private.admin_read('session',null)->>'account_id')::uuid;
  if not exists (
    select 1 from public.v21_conversations c join public.v21_accounts a on a.id=case when c.member_a=me then c.member_b else c.member_a end
    where c.id=p_conversation_id and me in(c.member_a,c.member_b) and a.role='user' and a.deleted_at is null and a.locked_at is null
  ) then raise exception 'conversation_forbidden' using errcode='42501'; end if;
  select coalesce(jsonb_agg(to_jsonb(x) order by x.message_id,x.sort_index,x.id),'[]'::jsonb) into result
  from (select a.id,a.message_id,a.kind,a.mime_type,a.storage_key,a.width_px,a.height_px,a.file_name,a.sort_index
    from public.v21_media_assets a
    join (select id from public.v21_messages where conversation_id=p_conversation_id and deleted_at is null order by created_at desc,id desc limit 100) m on m.id=a.message_id
    where a.conversation_id=p_conversation_id and a.deleted_at is null) x;
  return jsonb_build_object('account_id',me,'assets',result);
end;
$$;
revoke all on function v0_private.admin_media(uuid) from public,anon,authenticated,service_role;
grant execute on function v0_private.admin_media(uuid) to authenticated;
create function public.v0_admin_media(p_conversation_id uuid)
returns jsonb language sql stable security invoker set search_path=''
as $$ select v0_private.admin_media(p_conversation_id) $$;
revoke all on function public.v0_admin_media(uuid) from public,anon,authenticated,service_role;
grant execute on function public.v0_admin_media(uuid) to authenticated;
