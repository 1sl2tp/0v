-- Synthetic CI only. Never apply to production. No existing schema, roles or triggers.
create schema forward_fixture;
create table forward_fixture.committed (
 actor text not null, client_key text not null, room text not null,
 sha text not null, bytes int not null check(bytes>0), mime text not null,
 message_id uuid not null default gen_random_uuid(), asset_id uuid not null default gen_random_uuid(),
 primary key(actor,client_key), unique(room,sha,bytes)
);
create table forward_fixture.receipt (
 actor text not null, client_key text not null, room text not null,
 sha text not null, bytes int not null check(bytes>0), mime text not null,
 result jsonb not null, primary key(actor,client_key)
);
create function forward_fixture.commit_mock(p_actor text,p_key text,p_room text,p_sha text,p_bytes int,p_mime text)
returns jsonb language plpgsql as $fixture$
declare r forward_fixture.committed; receipt forward_fixture.receipt; response jsonb;
begin
 -- Synthetic identity and bytes are already assumed verified. This is not an auth API.
 perform pg_advisory_xact_lock(hashtextextended('fixture-client:'||p_actor||':'||p_key,0));
 select * into receipt from forward_fixture.receipt where actor=p_actor and client_key=p_key;
 if found then
  if (receipt.room,receipt.sha,receipt.bytes,receipt.mime) is distinct from (p_room,p_sha,p_bytes,p_mime) then raise exception 'manifest_conflict'; end if;
  return receipt.result;
 end if;
 perform pg_advisory_xact_lock(hashtextextended('fixture-content:'||p_room||':'||p_sha||':'||p_bytes,0));
 select * into r from forward_fixture.committed where room=p_room and sha=p_sha and bytes=p_bytes;
 if found then
  -- Never return another actor's canonical ACK as this caller's own send.
  response:=jsonb_build_object('state','already_present','room',p_room,'sha256',p_sha,'size',p_bytes,'client_id',p_key);
 else
  insert into forward_fixture.committed(actor,client_key,room,sha,bytes,mime) values(p_actor,p_key,p_room,p_sha,p_bytes,p_mime) returning * into r;
  response:=jsonb_build_object('state','committed','account',r.actor,'client_id',r.client_key,'room',r.room,'sha256',r.sha,'size',r.bytes,'mime',r.mime,'message_id',r.message_id,'asset_id',r.asset_id);
 end if;
 -- Bind the key even when no new message is created. Transaction rollback
 -- removes both the synthetic message and receipt. Not a live deletion policy.
 insert into forward_fixture.receipt(actor,client_key,room,sha,bytes,mime,result) values(p_actor,p_key,p_room,p_sha,p_bytes,p_mime,response);
 return response;
end $fixture$;
