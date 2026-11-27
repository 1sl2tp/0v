\set ON_ERROR_STOP on
begin;
create role anon nologin;
create role authenticated nologin;
create schema fixture;
create table fixture.messages(id text primary key, body text, created_at timestamptz, conversation_id uuid, sender_account_id uuid, deleted boolean default false);
create table fixture.assets(id text primary key,message_id text,storage_key text,sort_index integer);
insert into fixture.messages select 'm'||lpad(n::text,3,'0'),repeat('fixture text ',60), '2026-01-01'::timestamptz+n*interval '1 minute','00000000-0000-4000-8000-000000000001','00000000-0000-4000-8000-000000000002',false from generate_series(1,50)n;
insert into fixture.assets select 'a'||lpad(n::text,3,'0'),'m'||lpad(n::text,3,'0'),'fixture/'||n||'.png',0 from generate_series(10,50,5)n;
grant usage on schema fixture to authenticated;
grant select,insert,update,delete on all tables in schema fixture to authenticated;
create function public.v0_admin_read(p_kind text,p_conversation_id uuid) returns jsonb language plpgsql stable security invoker set search_path='' as $$
begin
 if current_setting('fixture.mode',true) is distinct from 'allow' or p_kind<>'thread' or p_conversation_id<>'00000000-0000-4000-8000-000000000001'::uuid then raise exception 'forbidden' using errcode='42501';end if;
 return jsonb_build_object('account_id','00000000-0000-4000-8000-000000000003','messages',(select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at,x.id),'[]') from (select id,body,created_at,conversation_id,sender_account_id from fixture.messages where not deleted and conversation_id=p_conversation_id order by created_at desc,id desc limit 100)x));
end $$;
create function public.v0_admin_media(p_conversation_id uuid) returns jsonb language plpgsql stable security invoker set search_path='' as $$
begin
 perform public.v0_admin_read('thread',p_conversation_id);
 return jsonb_build_object('account_id','00000000-0000-4000-8000-000000000003','assets',(select coalesce(jsonb_agg(to_jsonb(a) order by a.message_id,a.sort_index,a.id),'[]') from fixture.assets a join fixture.messages m on m.id=a.message_id where not m.deleted and m.conversation_id=p_conversation_id));
end $$;
revoke all on function public.v0_admin_read(text,uuid), public.v0_admin_media(uuid) from public,anon;
grant execute on function public.v0_admin_read(text,uuid),public.v0_admin_media(uuid) to authenticated;
\ir thread-delta-candidate.sql
do $$ begin
 if has_function_privilege('anon','public.v0_admin_thread_delta(uuid,integer,jsonb,jsonb)','execute') then raise exception 'anon execute'; end if;
 if not has_function_privilege('authenticated','public.v0_admin_thread_delta(uuid,integer,jsonb,jsonb)','execute') then raise exception 'authenticated execute'; end if;
end $$;
set local role authenticated;
select set_config('fixture.mode','allow',true);
do $$
declare room uuid:='00000000-0000-4000-8000-000000000001'; cold jsonb; warm jsonb; edited jsonb; older jsonb; removed jsonb; km jsonb; ka jsonb; legacy integer; delta_bytes integer; request_bytes integer;
begin
 cold:=public.v0_admin_thread_delta(room,30);
 if jsonb_array_length(cold#>'{messages,upserts}')<>30 or (cold->>'available')::int<>50 or not (cold#>'{messages,revisions}' ? 'm050') or cold#>'{messages,revisions}' ? 'm020' then raise exception 'cold window';end if;
 km:=cold#>'{messages,revisions}';ka:=cold#>'{assets,revisions}';
 warm:=public.v0_admin_thread_delta(room,30,km,ka);
 if jsonb_array_length(warm#>'{messages,upserts}')<>0 or jsonb_array_length(warm#>'{assets,upserts}')<>0 then raise exception 'warm retransmission';end if;
 legacy:=octet_length(public.v0_admin_read('thread',room)::text)+octet_length(public.v0_admin_media(room)::text);
 delta_bytes:=octet_length(warm::text);request_bytes:=octet_length(jsonb_build_object('p_conversation_id',room,'p_limit',30,'p_known_messages',km,'p_known_assets',ka)::text);
 raise notice 'FIXTURE_BYTES legacy_response=% warm_delta_response=% warm_delta_request=%',legacy,delta_bytes,request_bytes;
 if delta_bytes+request_bytes>=legacy then raise exception 'fixture expected smaller total bytes';end if;
 update fixture.messages set body='edited fixture' where id='m050';
 insert into fixture.assets values('late','m049','fixture/late.png',1);
 edited:=public.v0_admin_thread_delta(room,30,km,ka);
 if jsonb_array_length(edited#>'{messages,upserts}')<>1 or jsonb_array_length(edited#>'{assets,upserts}')<>1 then raise exception 'edited/late media';end if;
 km:=edited#>'{messages,revisions}';ka:=edited#>'{assets,revisions}';
 older:=public.v0_admin_thread_delta(room,50,km,ka);
 if jsonb_array_length(older#>'{messages,upserts}')<>20 then raise exception 'history batch';end if;
 update fixture.messages set deleted=true where id='m050';
 removed:=public.v0_admin_thread_delta(room,50,older#>'{messages,revisions}',older#>'{assets,revisions}');
 if removed#>'{messages,revisions}' ? 'm050' or removed#>'{assets,revisions}' ? 'a050' then raise exception 'deleted membership';end if;
 begin perform public.v0_admin_thread_delta(room,101);raise exception 'accepted invalid limit';exception when invalid_parameter_value then null;end;
 begin perform public.v0_admin_thread_delta('00000000-0000-4000-8000-000000000099'::uuid,30);raise exception 'accepted other room';exception when insufficient_privilege then null;end;
 perform set_config('fixture.mode','deny',true);
 begin perform public.v0_admin_thread_delta(room,30,km,ka);raise exception 'accepted revoked access';exception when insufficient_privilege then null;end;
 raise notice 'SQL DELTA PASS: cold, warm, edits, late media, history, delete, access and bounds';
end $$;
reset role;
rollback;
