-- CACHE-RESOLVE-02 candidate, do not apply until isolated role/RLS tests pass.
-- Only return current revision tuples for requested keys in authorized room inventory.
create or replace function public.v0_admin_media_revisions(p_conversation_id uuid,p_keys text[])
returns jsonb
language plpgsql stable security invoker set search_path=''
as $$
declare media jsonb; result jsonb;
begin
 if p_conversation_id is null or p_keys is null or cardinality(p_keys) not between 1 and 100
    or coalesce(array_ndims(p_keys),0)<>1
    or exists(select 1 from unnest(p_keys) k where k is null or length(k) not between 1 and 1024)
    or octet_length(to_jsonb(p_keys)::text)>100000 then
   raise exception 'invalid_revision_request' using errcode='22023';
 end if;
 media:=public.v0_admin_media(p_conversation_id);
 if media->>'account_id' is null or jsonb_typeof(media->'assets') is distinct from 'array' then
   raise exception 'invalid_media_scope' using errcode='42501';
 end if;
 -- Keep storage RLS in effect under the actual authenticated caller. No storage writes.
 with allowed as (
   select distinct a->>'storage_key' as path
   from jsonb_array_elements(media->'assets') a
   where a->>'storage_key'=any(p_keys)
 ), revisions as (
   select o.name as path,coalesce(nullif(o.metadata->>'eTag',''),nullif(o.metadata->>'etag',''),'') as etag,
          coalesce(o.version,'') as version
   from storage.objects o join allowed a on a.path=o.name
   where o.bucket_id='v21-media' and o.archived_at is null
 ), unique_current as (
   select path,min(etag) etag,min(version) version from revisions
   group by path having count(*)=1
 )
 select coalesce(jsonb_agg(jsonb_build_object('path',path,'etag',etag,'version',version) order by path),'[]'::jsonb)
 into result from unique_current where etag<>'' or version<>'';
 return jsonb_build_object('account_id',media->>'account_id','room',p_conversation_id,'revisions',result);
end $$;
revoke all on function public.v0_admin_media_revisions(uuid,text[]) from public,anon;
grant execute on function public.v0_admin_media_revisions(uuid,text[]) to authenticated;
