-- Candidate role grants, isolated fixture first. Do not provision a login here.
-- A trusted server validates the caller's JWT via Auth and binds only verified
-- claims transaction-locally. Never grant this role to authenticator or browser roles.
begin;
create role v0_qr_worker nologin noinherit nosuperuser nocreatedb nocreaterole noreplication nobypassrls;
grant usage on schema v0_private to v0_qr_worker;
grant execute on function v0_private.media_send_prepare(uuid,text,uuid,text,bigint,text),
 v0_private.media_qr_target(text),
 v0_private.media_qr_attest(text,uuid,text,text,uuid,integer,integer),
 v0_private.media_qr_commit(text) to v0_qr_worker;
-- Explicitly prevent generic unverified media commit and direct private writes.
revoke all on v0_private.media_send_ticket,v0_private.media_qr_recipient from v0_qr_worker;
revoke execute on function v0_private.media_send_commit(text) from v0_qr_worker;
commit;
