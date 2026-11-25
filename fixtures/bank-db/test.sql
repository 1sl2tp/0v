\set ON_ERROR_STOP on
DO $$
DECLARE a constant text:='fixture:123456789'; t constant timestamptz:='2026-11-24 15:16+07'; p constant timestamptz:='2026-11-24 15:20+07'; l constant timestamptz:='2026-11-25 08:00+07';
BEGIN
 IF bank_fixture_v116.post_receipt(a,'m','bill-m','A',400000.8,'manual',p)<>'created' THEN RAISE EXCEPTION 'manual create'; END IF;
 IF bank_fixture_v116.post_receipt(a,'m','bill-m','A',400000.8,'manual',p)<>'replay' THEN RAISE EXCEPTION 'manual retry'; END IF;
 IF bank_fixture_v116.link_manual(a,'m','A',400000.8,'bank:tx-1',t,l)<>'linked' THEN RAISE EXCEPTION 'manual link'; END IF;
 IF bank_fixture_v116.link_manual(a,'m','A',400000.8,'bank:tx-1',t,l+interval '1 hour')<>'replay' THEN RAISE EXCEPTION 'late retry'; END IF;
 IF bank_fixture_v116.post_receipt(a,'m','bill-m','A',400000.8,'manual',p)<>'replay' THEN RAISE EXCEPTION 'manual replay after link'; END IF;
 BEGIN PERFORM bank_fixture_v116.post_receipt(a,'m','bill-m','B',400000.8,'manual',p); RAISE EXCEPTION 'owner conflict accepted'; EXCEPTION WHEN unique_violation THEN NULL; END;
 BEGIN PERFORM bank_fixture_v116.post_receipt(a,'r2','bill-m','A',400000.8,'manual',p); RAISE EXCEPTION 'bill duplicate accepted'; EXCEPTION WHEN unique_violation THEN NULL; END;
 BEGIN PERFORM bank_fixture_v116.post_receipt(a,'r3','bill-3','B',400000.8,'bank',l,'bank:tx-1',t); RAISE EXCEPTION 'bank duplicate accepted'; EXCEPTION WHEN unique_violation THEN NULL; END;
 BEGIN PERFORM bank_fixture_v116.post_receipt(a,'bad','bill-bad','B',400000.8,'bank',l,'bank:tx-bad',NULL); RAISE EXCEPTION 'missing time accepted'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 BEGIN PERFORM bank_fixture_v116.post_receipt('production','bad','bill-bad','B',1,'manual',p); RAISE EXCEPTION 'real scope accepted'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 IF bank_fixture_v116.post_receipt(a,'r4','bill-4','B',400000.8,'bank',l,'bank:tx-2',t)<>'created' THEN RAISE EXCEPTION 'different transaction rejected'; END IF;
 IF bank_fixture_v116.post_receipt(a,'r4','bill-4','B',400000.8,'bank',l,'bank:tx-2',t)<>'replay' THEN RAISE EXCEPTION 'bank retry'; END IF;
 IF (SELECT count(*) FROM bank_fixture_v116.receipt)<>2 OR (SELECT sum(amount) FROM bank_fixture_v116.receipt)<>800001.6 THEN RAISE EXCEPTION 'duplicate amount'; END IF;
 IF NOT EXISTS(SELECT FROM bank_fixture_v116.receipt WHERE receipt_id='m' AND posted_at=p AND verified_at=l AND method='manual') THEN RAISE EXCEPTION 'manual history changed'; END IF;
END $$;
BEGIN;
SELECT bank_fixture_v116.post_receipt('fixture:123456789','rollback','bill-rollback','A',1,'manual','2026-11-25T09:00:00+07');
ROLLBACK;
DO $$ BEGIN IF EXISTS(SELECT FROM bank_fixture_v116.receipt WHERE receipt_id='rollback') THEN RAISE EXCEPTION 'rollback failed'; END IF; END $$;
