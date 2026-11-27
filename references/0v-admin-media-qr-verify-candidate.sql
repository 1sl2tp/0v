-- Private worker-only QR verification API candidate. Not deployed.
-- No grant to browser, authenticated, anon or service_role. Worker role and
-- validated JWT-to-DB session binding must be reviewed separately before deployment.
begin;
create table v0_private.media_qr_recipient(
 account_id uuid primary key, bank_bin text not null check(bank_bin ~ '^[0-9]{6}$'),
 recipient_number text not null check(recipient_number ~ '^[0-9]{1,19}$'),
 revision uuid not null default gen_random_uuid()
);
create function v0_private.media_qr_rotate_revision() returns trigger language plpgsql set search_path='' as $rotate$
begin
 new.revision:=gen_random_uuid();
 return new;
end $rotate$;
revoke all on function v0_private.media_qr_rotate_revision() from public,anon,authenticated,service_role;
create trigger media_qr_recipient_revision before update on v0_private.media_qr_recipient for each row execute function v0_private.media_qr_rotate_revision();
alter table v0_private.media_qr_recipient enable row level security;
revoke all on v0_private.media_qr_recipient from public,anon,authenticated,service_role;
alter table v0_private.media_send_ticket add column qr_recipient_revision uuid;
create function v0_private.media_qr_target(p_client text) returns jsonb
language plpgsql volatile security definer set search_path='' as $qr$
declare me uuid; t v0_private.media_send_ticket; r v0_private.media_qr_recipient; o storage.objects;
begin
 me:=v0_private.media_send_actor();
 select * into t from v0_private.media_send_ticket where account_id=me and client_id=p_client for update;
 if not found or t.auth_user<>auth.uid() or t.session_id::text<>(auth.jwt()->>'session_id') or t.message_id is not null or t.expires_at<=clock_timestamp() or not v0_private.media_send_contact(me,t.contact_id) then raise exception 'ticket_forbidden' using errcode='42501';end if;
 if not exists(select 1 from public.v21_conversations c where c.id=t.room_id and c.member_a=least(me,t.contact_id) and c.member_b=greatest(me,t.contact_id)) then raise exception 'room_forbidden' using errcode='42501';end if;
 select * into r from v0_private.media_qr_recipient where account_id=me;
 if not found then raise exception 'recipient_not_configured';end if;
 select * into o from storage.objects where bucket_id='v21-media' and name=t.storage_key and owner_id=t.auth_user::text and archived_at is null and not is_delete_marker;
 if not found or o.version is null or o.metadata->>'size' is distinct from t.size_bytes::text or o.metadata->>'mimetype' is distinct from 'image/png' then raise exception 'object_unavailable';end if;
 return jsonb_build_object('state','pending','account_id',me,'client_id',t.client_id,'storage_key',t.storage_key,'auth_user',t.auth_user,'size_bytes',t.size_bytes,'sha256',t.sha256,'object_id',o.id,'object_version',o.version,'bin',r.bank_bin,'account',r.recipient_number,'recipient_revision',r.revision);
end $qr$;
create function v0_private.media_qr_attest(p_client text,p_object uuid,p_version text,p_hash text,p_revision uuid,p_width integer,p_height integer) returns void
language plpgsql volatile security definer set search_path='' as $qr$
declare v jsonb;
begin
 v:=v0_private.media_qr_target(p_client);
 if p_object is null or p_version is null or p_hash is null or p_revision is null or p_width is null or p_height is null or p_width not between 1 and 4096 or p_height not between 1 and 4096 or p_width::bigint*p_height>4000000
 or p_object::text is distinct from v->>'object_id' or p_version is distinct from v->>'object_version' or p_hash is distinct from v->>'sha256' or p_revision::text is distinct from v->>'recipient_revision' then raise exception 'attestation_mismatch';end if;
 update v0_private.media_send_ticket set verified_object_id=p_object,verified_object_version=p_version,verified_width=p_width,verified_height=p_height,qr_recipient_revision=p_revision where account_id=(v->>'account_id')::uuid and client_id=p_client;
end $qr$;
create function v0_private.media_qr_commit(p_client text) returns jsonb
language plpgsql volatile security definer set search_path='' as $qr$
declare me uuid; t v0_private.media_send_ticket; r v0_private.media_qr_recipient;
begin
 me:=v0_private.media_send_actor();
 perform pg_advisory_xact_lock(hashtextextended(me::text||':'||coalesce(p_client,''),0));
 select * into t from v0_private.media_send_ticket where account_id=me and client_id=p_client for update;
 if not found or t.auth_user<>auth.uid() or t.session_id::text<>(auth.jwt()->>'session_id') or t.qr_recipient_revision is null then raise exception 'qr_not_verified' using errcode='42501';end if;
 if t.message_id is null then
  select * into r from v0_private.media_qr_recipient where account_id=me for share;
  if not found or r.revision<>t.qr_recipient_revision then raise exception 'recipient_changed';end if;
 end if;
 return v0_private.media_send_commit(p_client);
end $qr$;
revoke all on function v0_private.media_qr_target(text),v0_private.media_qr_attest(text,uuid,text,text,uuid,integer,integer),v0_private.media_qr_commit(text) from public,anon,authenticated,service_role;
commit;
