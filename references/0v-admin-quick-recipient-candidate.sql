-- Candidate shared recipient read API; private provisioning only.
-- Never commit a real account number or QR to the public repository.
begin;
alter table v0_private.media_qr_recipient add column recipient_name text check (recipient_name is null or char_length(btrim(recipient_name)) between 1 and 100);
alter table v0_private.media_qr_recipient add column institution text check (institution is null or char_length(btrim(institution)) between 1 and 100);
create function v0_private.quick_recipient() returns jsonb language plpgsql stable security definer set search_path='' as $read$
declare me uuid; r v0_private.media_qr_recipient;
begin
 me:=v0_private.media_send_actor();
 select * into r from v0_private.media_qr_recipient where account_id=me;
 if not found or r.recipient_name is null or r.institution is null then return jsonb_build_object('configured',false);end if;
 return jsonb_build_object('configured',true,'name',r.recipient_name,'number',r.recipient_number,'institution',r.institution,'bin',r.bank_bin,'revision',r.revision);
end $read$;
revoke all on function v0_private.quick_recipient() from public,anon,authenticated,service_role;
grant execute on function v0_private.quick_recipient() to authenticated;
create function public.v0_admin_quick_recipient() returns jsonb language sql stable security invoker set search_path='' as $read$
select v0_private.quick_recipient()
$read$;
revoke all on function public.v0_admin_quick_recipient() from public,anon,authenticated,service_role;
grant execute on function public.v0_admin_quick_recipient() to authenticated;
commit;
