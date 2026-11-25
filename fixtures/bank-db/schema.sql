-- SYNTHETIC ONLY. Standalone CI database; not a Supabase migration.
BEGIN;
CREATE SCHEMA bank_fixture_v116;
REVOKE ALL ON SCHEMA bank_fixture_v116 FROM PUBLIC;
CREATE TABLE bank_fixture_v116.receipt (
 account text NOT NULL CHECK (account='fixture:123456789'),
 receipt_id text NOT NULL CHECK (length(receipt_id) BETWEEN 1 AND 128 AND receipt_id=btrim(receipt_id)),
 bill_id text NOT NULL CHECK (length(bill_id) BETWEEN 1 AND 128 AND bill_id=btrim(bill_id)),
 customer_id text NOT NULL CHECK (length(customer_id) BETWEEN 1 AND 128 AND customer_id=btrim(customer_id)),
 amount numeric NOT NULL CHECK (amount>0 AND amount<1000000000000000 AND scale(amount)<=6),
 method text NOT NULL CHECK (method IN ('manual','bank')),
 posted_at timestamptz NOT NULL CHECK (isfinite(posted_at)),
 bank_key text CHECK (length(bank_key) BETWEEN 1 AND 256 AND bank_key=btrim(bank_key)),
 transaction_at timestamptz CHECK (isfinite(transaction_at)),
 verified_at timestamptz CHECK (isfinite(verified_at)),
 PRIMARY KEY(account,receipt_id),
 UNIQUE(account,bill_id),
 UNIQUE(account,bank_key),
 CHECK ((bank_key IS NULL AND transaction_at IS NULL AND verified_at IS NULL AND method='manual')
 OR (bank_key IS NOT NULL AND transaction_at IS NOT NULL AND verified_at IS NOT NULL
 AND verified_at>=transaction_at AND verified_at>=posted_at
 AND (method='manual' OR posted_at=verified_at)))
);
ALTER TABLE bank_fixture_v116.receipt ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON bank_fixture_v116.receipt FROM PUBLIC;
-- Trusted fixture runner only. Key is a verified provider transaction identity,
-- NOT notification ID, amount, memo, arrival day or an OCR guess.
CREATE FUNCTION bank_fixture_v116.post_receipt(
 p_account text,p_receipt text,p_bill text,p_customer text,p_amount numeric,
 p_method text,p_posted timestamptz,p_bank text DEFAULT NULL,p_tx timestamptz DEFAULT NULL
) RETURNS text LANGUAGE plpgsql SECURITY INVOKER SET search_path=pg_catalog AS $$
DECLARE r bank_fixture_v116.receipt%ROWTYPE;
BEGIN
 IF p_account IS DISTINCT FROM 'fixture:123456789' OR p_method IS NULL OR p_method NOT IN ('manual','bank')
 OR (p_method='manual' AND (p_bank IS NOT NULL OR p_tx IS NOT NULL))
 OR (p_method='bank' AND (p_bank IS NULL OR p_tx IS NULL))
 THEN RAISE EXCEPTION 'invalid fixture evidence' USING ERRCODE='22023'; END IF;
 INSERT INTO bank_fixture_v116.receipt(account,receipt_id,bill_id,customer_id,amount,method,posted_at,bank_key,transaction_at,verified_at)
 VALUES(p_account,p_receipt,p_bill,p_customer,p_amount,p_method,p_posted,p_bank,p_tx,CASE WHEN p_method='bank' THEN p_posted END)
 ON CONFLICT(account,receipt_id) DO NOTHING;
 IF FOUND THEN RETURN 'created'; END IF;
 SELECT * INTO STRICT r FROM bank_fixture_v116.receipt WHERE account=p_account AND receipt_id=p_receipt FOR UPDATE;
 IF r.bill_id IS DISTINCT FROM p_bill OR r.customer_id IS DISTINCT FROM p_customer
 OR r.amount IS DISTINCT FROM p_amount OR r.method IS DISTINCT FROM p_method OR r.posted_at IS DISTINCT FROM p_posted
 OR (p_method='bank' AND (r.bank_key IS DISTINCT FROM p_bank OR r.transaction_at IS DISTINCT FROM p_tx))
 THEN RAISE EXCEPTION 'receipt payload conflict' USING ERRCODE='23505'; END IF;
 RETURN 'replay';
END $$;
CREATE FUNCTION bank_fixture_v116.link_manual(
 p_account text,p_receipt text,p_customer text,p_amount numeric,p_bank text,p_tx timestamptz,p_verified timestamptz
) RETURNS text LANGUAGE plpgsql SECURITY INVOKER SET search_path=pg_catalog AS $$
DECLARE r bank_fixture_v116.receipt%ROWTYPE;
BEGIN
 IF p_account IS DISTINCT FROM 'fixture:123456789' OR p_bank IS NULL OR p_tx IS NULL OR p_verified IS NULL
 OR NOT isfinite(p_verified) OR NOT isfinite(p_tx)
 THEN RAISE EXCEPTION 'invalid link evidence' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT r FROM bank_fixture_v116.receipt WHERE account=p_account AND receipt_id=p_receipt FOR UPDATE;
 IF r.method<>'manual' OR r.customer_id IS DISTINCT FROM p_customer OR r.amount IS DISTINCT FROM p_amount
 OR p_verified<r.posted_at OR p_verified<p_tx
 THEN RAISE EXCEPTION 'manual link conflict' USING ERRCODE='22023'; END IF;
 IF r.bank_key IS NOT NULL THEN
  IF r.bank_key IS DISTINCT FROM p_bank OR r.transaction_at IS DISTINCT FROM p_tx
  THEN RAISE EXCEPTION 'bank link conflict' USING ERRCODE='23505'; END IF;
  RETURN 'replay';
 END IF;
 UPDATE bank_fixture_v116.receipt SET bank_key=p_bank,transaction_at=p_tx,verified_at=p_verified
 WHERE account=p_account AND receipt_id=p_receipt;
 RETURN 'linked';
END $$;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA bank_fixture_v116 FROM PUBLIC;
DO $$ DECLARE role_name text; BEGIN
 FOR role_name IN SELECT rolname FROM pg_roles WHERE rolname IN ('anon','authenticated','service_role') LOOP
  EXECUTE format('REVOKE ALL ON SCHEMA bank_fixture_v116 FROM %I',role_name);
  EXECUTE format('REVOKE ALL ON ALL TABLES IN SCHEMA bank_fixture_v116 FROM %I',role_name);
  EXECUTE format('REVOKE ALL ON ALL FUNCTIONS IN SCHEMA bank_fixture_v116 FROM %I',role_name);
 END LOOP;
END $$;
COMMIT;
