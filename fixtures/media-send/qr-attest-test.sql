\set ON_ERROR_STOP on
\ir ../../references/0v-admin-media-qr-verify-candidate.sql
select set_config('fixture.uid','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',false);
select set_config('fixture.jwt','{"session_id":"cccccccc-cccc-4ccc-8ccc-cccccccccccc","aal":"aal2"}',false);
do $test$
declare me uuid:='11111111-1111-4111-8111-111111111111'; peer uuid:='22222222-2222-4222-8222-222222222222'; key text:='0v:'||gen_random_uuid(); aid uuid:=gen_random_uuid(); obj uuid:=gen_random_uuid(); t jsonb; target jsonb; ack jsonb;
begin
 if has_function_privilege('authenticated','v0_private.media_qr_attest(text,uuid,text,text,uuid,integer,integer)','execute') or has_function_privilege('service_role','v0_private.media_qr_attest(text,uuid,text,text,uuid,integer,integer)','execute') then raise exception 'attestation grant';end if;
 insert into v0_private.media_qr_recipient(account_id,bank_bin,recipient_number) values(me,'970000','00123456');
 t:=v0_private.media_send_prepare(peer,key,aid,'',10,repeat('b',64));
 insert into storage.objects(id,bucket_id,name,version,owner_id,metadata) values(obj,'v21-media',t->>'storage_key','v1','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','{"size":10,"mimetype":"image/png"}');
 target:=v0_private.media_qr_target(key);
 begin perform v0_private.media_qr_commit(key);raise exception 'unexpected_success';exception when insufficient_privilege then null;end;
 begin perform v0_private.media_qr_attest(key,obj,'wrong-version',repeat('b',64),(target->>'recipient_revision')::uuid,40,40);raise exception 'unexpected_success';exception when raise_exception then if sqlerrm<>'attestation_mismatch' then raise;end if;end;
 -- Simulated trusted verifier result only, no claim actual storage bytes were read.
 perform v0_private.media_qr_attest(key,obj,'v1',repeat('b',64),(target->>'recipient_revision')::uuid,40,40);
 update v0_private.media_qr_recipient set recipient_number='00123457' where account_id=me;
 begin perform v0_private.media_qr_commit(key);raise exception 'unexpected_success';exception when raise_exception then if sqlerrm<>'recipient_changed' then raise;end if;end;
 if exists(select 1 from public.v21_messages where client_id=key) then raise exception 'unverified commit';end if;
 update v0_private.media_qr_recipient set recipient_number='00123456' where account_id=me;
 target:=v0_private.media_qr_target(key);
 perform v0_private.media_qr_attest(key,obj,'v1',repeat('b',64),(target->>'recipient_revision')::uuid,40,40);
 ack:=v0_private.media_qr_commit(key);
 if ack is distinct from v0_private.media_qr_commit(key) then raise exception 'replay mismatch';end if;
 raise notice 'MEDIA-SEND-01 QR private attestation and recipient revision fixture passed';
end $test$;
