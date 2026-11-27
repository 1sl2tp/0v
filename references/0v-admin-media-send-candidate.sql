-- MEDIA-SEND-01 stage A: PRIVATE SQL CANDIDATE. Never apply directly to production.
-- Single PNG image first; no public RPC or verifier credentials; candidate storage policy is not deployed.
begin;
create table v0_private.media_send_ticket (
 account_id uuid not null, client_id text not null, auth_user uuid not null, session_id uuid not null,
 contact_id uuid not null, room_id uuid not null, asset_id uuid not null unique,
 body text not null, size_bytes bigint not null check(size_bytes between 1 and 15728640),
 sha256 text not null check(sha256 ~ '^[0-9a-f]{64}$'), storage_key text not null unique,
 expires_at timestamptz not null, verified_object_id uuid, verified_object_version text,
 verified_width int, verified_height int, message_id uuid,
 primary key(account_id,client_id)
);
alter table v0_private.media_send_ticket enable row level security;
revoke all on v0_private.media_send_ticket from public,anon,authenticated,service_role;

create function v0_private.media_send_actor() returns uuid language plpgsql stable security definer set search_path='' as $$
begin
 if coalesce(auth.jwt()->>'aal','')<>'aal2' then raise exception 'aal2_required' using errcode='42501'; end if;
 return (v0_private.admin_read('session',null)->>'account_id')::uuid;
end $$;
create function v0_private.media_send_contact(me uuid,peer uuid) returns boolean language sql stable security definer set search_path='' as $$
 select peer is not null and peer<>me and exists(select 1 from public.v21_accounts a where a.id=peer and a.role='user' and a.deleted_at is null and a.locked_at is null)
$$;
create function v0_private.media_send_prepare(p_contact uuid,p_client text,p_asset uuid,p_body text,p_size bigint,p_hash text)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare me uuid; sid uuid; room uuid; t v0_private.media_send_ticket; body_text text:=btrim(coalesce(p_body,''));
begin
 me:=v0_private.media_send_actor(); sid:=(auth.jwt()->>'session_id')::uuid;
 if not v0_private.media_send_contact(me,p_contact) then raise exception 'contact_forbidden' using errcode='42501'; end if;
 if p_client is null or p_client !~ '^0v:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' or p_asset is null or p_size is null or p_size not between 1 and 15728640 or p_hash is null or p_hash !~ '^[0-9a-f]{64}$' or char_length(body_text)>8000 then raise exception 'invalid_manifest' using errcode='22023'; end if;
 perform pg_advisory_xact_lock(hashtextextended(me::text||':'||p_client,0));
 select * into t from v0_private.media_send_ticket where account_id=me and client_id=p_client for update;
 if found then
  if t.session_id<>sid or t.auth_user<>auth.uid() or t.contact_id<>p_contact or t.asset_id<>p_asset or t.body<>body_text or t.size_bytes<>p_size or t.sha256<>p_hash then raise exception 'manifest_conflict'; end if;
  if t.message_id is null and t.expires_at<=clock_timestamp() then raise exception 'ticket_expired'; end if;
 else
  if exists(select 1 from public.v21_messages where sender_account_id=me and client_id=p_client) then raise exception 'client_id_conflict'; end if;
  insert into public.v21_conversations(member_a,member_b) values(least(me,p_contact),greatest(me,p_contact)) on conflict(member_a,member_b) do nothing;
  select c.id into strict room from public.v21_conversations c where c.member_a=least(me,p_contact) and c.member_b=greatest(me,p_contact);
  insert into v0_private.media_send_ticket(account_id,client_id,auth_user,session_id,contact_id,room_id,asset_id,body,size_bytes,sha256,storage_key,expires_at)
  values(me,p_client,auth.uid(),sid,p_contact,room,p_asset,body_text,p_size,p_hash,me::text||'/'||room::text||'/0v-ticket/'||p_asset::text||'.png',clock_timestamp()+interval '15 minutes') returning * into t;
 end if;
 return jsonb_build_object('account_id',me,'conversation_id',t.room_id,'asset_id',t.asset_id,'storage_key',t.storage_key,'message_id',t.message_id,'expires_at',t.expires_at);
end $$;

-- Only a future trusted byte verifier may set the private verification fields.
-- It must download immutable object bytes, validate actual PNG decode, SHA-256, size,
-- dimensions, object id/version, owner and exact ticket; no metadata-only attestation.
create function v0_private.media_send_commit(p_client text)
returns jsonb language plpgsql volatile security definer set search_path='' as $$
declare me uuid; t v0_private.media_send_ticket; mid uuid; sid uuid; obj storage.objects;
begin
 me:=v0_private.media_send_actor();sid:=(auth.jwt()->>'session_id')::uuid;
 perform pg_advisory_xact_lock(hashtextextended(me::text||':'||coalesce(p_client,''),0));
 select * into t from v0_private.media_send_ticket where account_id=me and client_id=p_client for update;
 if not found or t.auth_user<>auth.uid() or t.session_id<>sid or not v0_private.media_send_contact(me,t.contact_id) then raise exception 'ticket_forbidden' using errcode='42501'; end if;
 if not exists(select 1 from public.v21_conversations c where c.id=t.room_id and c.member_a=least(me,t.contact_id) and c.member_b=greatest(me,t.contact_id)) then raise exception 'room_forbidden' using errcode='42501'; end if;
 if t.message_id is not null then
  if not exists(select 1 from public.v21_messages m join public.v21_media_assets a on a.message_id=m.id where m.id=t.message_id and m.deleted_at is null and m.sender_account_id=me and m.conversation_id=t.room_id and m.client_id=t.client_id and m.body=t.body and a.id=t.asset_id and a.deleted_at is null and a.storage_key=t.storage_key and a.content_hash=t.sha256 and a.owner_account_id=me and a.conversation_id=t.room_id and a.size_bytes=t.size_bytes and a.mime_type='image/png') then raise exception 'committed_message_changed'; end if;
  return jsonb_build_object('account_id',me,'conversation_id',t.room_id,'message_id',t.message_id,'asset_id',t.asset_id);
 end if;
 if t.expires_at<=clock_timestamp() then raise exception 'ticket_expired'; end if;
 if t.verified_object_id is null or t.verified_object_version is null or t.verified_width is null or t.verified_height is null or t.verified_width not between 1 and 20000 or t.verified_height not between 1 and 20000 then raise exception 'bytes_not_verified'; end if;
 select * into obj from storage.objects where bucket_id='v21-media' and name=t.storage_key and id=t.verified_object_id and version=t.verified_object_version and owner_id=t.auth_user::text and archived_at is null and not is_delete_marker for share;
 if not found or obj.metadata->>'size' is distinct from t.size_bytes::text or obj.metadata->>'mimetype' is distinct from 'image/png' then raise exception 'object_changed'; end if;
 insert into public.v21_messages(conversation_id,sender_account_id,client_id,body) values(t.room_id,me,t.client_id,t.body) returning id into mid;
 insert into public.v21_media_assets(id,conversation_id,message_id,owner_account_id,kind,mime_type,size_bytes,storage_key,content_hash,width_px,height_px,sort_index)
 values(t.asset_id,t.room_id,mid,me,'image','image/png',t.size_bytes,t.storage_key,t.sha256,t.verified_width,t.verified_height,0);
 update v0_private.media_send_ticket set message_id=mid where account_id=me and client_id=p_client;
 return jsonb_build_object('account_id',me,'conversation_id',t.room_id,'message_id',mid,'asset_id',t.asset_id);
end $$;
revoke all on function v0_private.media_send_actor(),v0_private.media_send_contact(uuid,uuid),v0_private.media_send_prepare(uuid,text,uuid,text,bigint,text),v0_private.media_send_commit(text) from public,anon,authenticated,service_role;

-- Candidate only: reserved third segment; existing legacy paths unaffected.
create function v0_private.media_send_upload_allowed(p_name text,p_owner text)
returns boolean language plpgsql stable security definer set search_path='' as $media$
declare me uuid;
begin
 if auth.uid() is null or p_owner is distinct from auth.uid()::text then return false; end if;
 begin me:=v0_private.media_send_actor(); exception when insufficient_privilege then return false; end;
 return exists(select 1 from v0_private.media_send_ticket t
 join public.v21_conversations c on c.id=t.room_id
 where t.account_id=me and t.auth_user=auth.uid() and t.session_id=(auth.jwt()->>'session_id')::uuid
 and t.storage_key=p_name and t.message_id is null and t.verified_object_id is null and t.expires_at>now()
 and c.member_a=least(me,t.contact_id) and c.member_b=greatest(me,t.contact_id)
 and v0_private.media_send_contact(me,t.contact_id));
end $media$1
create function v0_private.media_send_published(p_name text)
returns boolean language sql stable security definer set search_path='' as $media$
 select auth.uid() is not null and exists(select 1 from v0_private.media_send_ticket t join public.v21_media_assets a on a.id=t.asset_id and a.message_id=t.message_id and a.storage_key=t.storage_key and a.deleted_at is null join public.v21_messages m on m.id=t.message_id and m.deleted_at is null join public.v21_conversations c on c.id=t.room_id join public.v21_accounts viewer on viewer.id in(c.member_a,c.member_b) and viewer.auth_user_id=auth.uid() and viewer.deleted_at is null and viewer.locked_at is null join auth.sessions s on s.user_id=viewer.auth_user_id and s.id::text=auth.jwt()->>'session_id' and (s.not_after is null or s.not_after>now()) where t.storage_key=p_name and t.message_id is not null)
$media$;
revoke all on function v0_private.media_send_upload_allowed(text,text),v0_private.media_send_published(text) from public,anon,authenticated,service_role;
grant execute on function v0_private.media_send_upload_allowed(text,text),v0_private.media_send_published(text) to authenticated;
-- Restrictive guards matter: existing permissive CHAT policies must not bypass tickets.
create policy v0_media_ticket_insert on storage.objects for insert to authenticated
 with check(bucket_id='v21-media' and split_part(name,'/',3)='0v-ticket' and v0_private.media_send_upload_allowed(name,owner_id));
create policy v0_media_ticket_insert_guard on storage.objects as restrictive for insert to authenticated
 with check(bucket_id is distinct from 'v21-media' or split_part(name,'/',3)<>'0v-ticket' or v0_private.media_send_upload_allowed(name,owner_id));
create policy v0_media_ticket_read_guard on storage.objects as restrictive for select to authenticated
 using(bucket_id is distinct from 'v21-media' or split_part(name,'/',3)<>'0v-ticket' or v0_private.media_send_published(name));
create policy v0_media_ticket_update_guard on storage.objects as restrictive for update to authenticated
 using(bucket_id is distinct from 'v21-media' or split_part(name,'/',3)<>'0v-ticket')
 with check(bucket_id is distinct from 'v21-media' or split_part(name,'/',3)<>'0v-ticket');
create policy v0_media_ticket_delete_guard on storage.objects as restrictive for delete to authenticated
 using(bucket_id is distinct from 'v21-media' or split_part(name,'/',3)<>'0v-ticket');

commit;
