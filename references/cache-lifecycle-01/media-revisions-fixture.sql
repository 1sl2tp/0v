\set ON_ERROR_STOP on
begin;
create role anon nologin;
create role authenticated nologin;
create schema storage;
create table storage.objects(name text,bucket_id text,metadata jsonb,version text,archived_at timestamptz,permitted boolean not null default true);
alter table storage.objects enable row level security;
grant usage on schema storage to authenticated;
grant select on storage.objects to authenticated;
create policy fixture_select on storage.objects for select to authenticated using (permitted and current_setting('fixture.mode',true)='allow');
insert into storage.objects(name,bucket_id,metadata,version,archived_at,permitted) values
 ('one','v21-media','{"eTag":"one-rev"}','1',null,true),
 ('two','v21-media','{}','2',null,true),
 ('denied','v21-media','{"eTag":"secret"}','3',null,false),
 ('foreign','v21-media','{"eTag":"other"}','4',null,true),
 ('archived','v21-media','{"eTag":"old"}','5',now(),true),
 ('wrongbucket','other','{"eTag":"bad"}','6',null,true),
 ('ambiguous','v21-media','{"eTag":"a"}','7',null,true),
 ('ambiguous','v21-media','{"eTag":"b"}','8',null,true),
 ('unknown-rev','v21-media','{}',null,null,true);
create function public.v0_admin_media(p_conversation_id uuid) returns jsonb
language plpgsql stable security invoker set search_path='' as $$
begin
 if current_setting('fixture.mode',true) is distinct from 'allow' or p_conversation_id<>'30000000-0000-4000-8000-000000000001'::uuid then raise exception 'forbidden' using errcode='42501';end if;
 return jsonb_build_object('account_id','actor','assets',(select jsonb_agg(jsonb_build_object('storage_key',k)) from unnest(array['one','two','denied','archived','wrongbucket','ambiguous','unknown-rev']) k));
end $$;
revoke all on function public.v0_admin_media(uuid) from public,anon;
grant execute on function public.v0_admin_media(uuid) to authenticated;
\ir media-revisions-candidate.sql
do $$ begin
 if has_function_privilege('anon','public.v0_admin_media_revisions(uuid,text[])','execute') then raise exception 'anon permission'; end if;
 if not has_function_privilege('authenticated','public.v0_admin_media_revisions(uuid,text[])','execute') then raise exception 'auth grant'; end if;
 if (select prosecdef from pg_proc where oid='public.v0_admin_media_revisions(uuid,text[])'::regprocedure) then raise exception 'must use invoker';end if;
end $$;
set local role authenticated;
select set_config('fixture.mode','allow',true);
do $$
declare room uuid:='30000000-0000-4000-8000-000000000001'; v jsonb;
begin
 v:=public.v0_admin_media_revisions(room,array['one','one','two','denied','foreign','archived','wrongbucket','ambiguous','unknown-rev','missing']);
 if v->>'account_id'<>'actor' or v->>'room'<>room::text or v->'revisions'<>'[{"path":"one","etag":"one-rev","version":"1"},{"path":"two","etag":"","version":"2"}]'::jsonb then raise exception 'scope/version/rls mismatch: %',v;end if;
 begin perform public.v0_admin_media_revisions('30000000-0000-4000-8000-000000000002',array['one']);raise exception 'wrong room accepted';exception when insufficient_privilege then null;end;
 begin perform public.v0_admin_media_revisions(room,array_fill('one'::text,array[101]));raise exception 'oversize accepted';exception when invalid_parameter_value then null;end;
 begin perform public.v0_admin_media_revisions(room,array['one',null]);raise exception 'null key accepted';exception when invalid_parameter_value then null;end;
 begin perform public.v0_admin_media_revisions(room,array[]::text[]);raise exception 'empty accepted';exception when invalid_parameter_value then null;end;
 perform set_config('fixture.mode','deny',true);
 begin perform public.v0_admin_media_revisions(room,array['one']);raise exception 'denied actor accepted';exception when insufficient_privilege then null;end;
 raise notice 'CACHE-RESOLVE-02 scoped invoker batch, RLS, foreign, missing, archived, duplicate, invalid input, denied actor passed';
end $$;
rollback;
