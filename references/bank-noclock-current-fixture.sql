-- BANK-NOCLOCK-CURRENT-01: read-only specification fixture; not a posting RPC.
-- Narrow fallback for missing optional OCR sender/receiver-bank fields.
WITH cases(name,delta_s,changes,expected) AS (
 VALUES
 ('fresh exact memo',28,'{}'::jsonb,true),
 ('minute boundary',0,'{}',true),
 ('two-minute boundary',120,'{}',true),
 ('late server receipt',28,'{"late_arrival":true}',true),
 ('too early',-1,'{}',false),
 ('too late',121,'{}',false),
 ('different day',28,'{"same_day":false}',false),
 ('invalid printed clock',28,'{"clock_missing":false}',false),
 ('wrong account',28,'{"full_account":false}',false),
 ('wrong name',28,'{"receiver_name":false}',false),
 ('bank conflict',28,'{"bank_conflict":true}',false),
 ('amount mismatch',28,'{"amount_match":false}',false),
 ('memo mismatch',28,'{"exact_memo":false}',false),
 ('generic memo',28,'{"substantive_memo":false}',false),
 ('weak reference',28,'{"strong_ref":false}',false),
 ('own transfer',28,'{"independent_credit":false}',false),
 ('untrusted bank event',28,'{"verified_device":false}',false),
 ('unclear OCR',28,'{"clear_success":false}',false),
 ('second credit',28,'{"credit_count":2}',false),
 ('second bill other customer',28,'{"bill_count":2}',false),
 ('unknown nearby image',28,'{"unresolved_image":true}',false),
 ('duplicate image or reference',28,'{"duplicate_identity":true}',false),
 ('already linked bank',28,'{"used_credit":true}',false),
 ('already collected bill',28,'{"used_bill":true}',false),
 ('manual ledger',28,'{"manual_ledger":true}',false),
 ('replayed command',28,'{"command_exists":true}',false),
 ('incomplete scope',28,'{"complete_scope":false}',false),
 ('unknown customer',28,'{"customer_bound":false}',false),
 ('auto disabled',28,'{"enabled":false}',false)
), evaluated AS (
 SELECT name,expected,delta_s BETWEEN 0 AND 120
 AND (coalesce((changes->>'same_day')::boolean,true))
 AND coalesce((changes->>'clock_missing')::boolean,true)
 AND coalesce((changes->>'full_account')::boolean,true)
 AND coalesce((changes->>'receiver_name')::boolean,true)
 AND NOT coalesce((changes->>'bank_conflict')::boolean,false)
 AND coalesce((changes->>'amount_match')::boolean,true)
 AND coalesce((changes->>'exact_memo')::boolean,true)
 AND coalesce((changes->>'substantive_memo')::boolean,true)
 AND coalesce((changes->>'strong_ref')::boolean,true)
 AND coalesce((changes->>'independent_credit')::boolean,true)
 AND coalesce((changes->>'verified_device')::boolean,true)
 AND coalesce((changes->>'clear_success')::boolean,true)
 AND coalesce((changes->>'credit_count')::int,1)=1
 AND coalesce((changes->>'bill_count')::int,1)=1
 AND NOT coalesce((changes->>'unresolved_image')::boolean,false)
 AND NOT coalesce((changes->>'duplicate_identity')::boolean,false)
 AND NOT coalesce((changes->>'used_credit')::boolean,false)
 AND NOT coalesce((changes->>'used_bill')::boolean,false)
 AND NOT coalesce((changes->>'manual_ledger')::boolean,false)
 AND NOT coalesce((changes->>'command_exists')::boolean,false)
 AND coalesce((changes->>'complete_scope')::boolean,true)
 AND coalesce((changes->>'customer_bound')::boolean,true)
 AND coalesce((changes->>'enabled')::boolean,true) AS candidate
 FROM cases
)
SELECT count(*) AS tested,count(*) FILTER (WHERE expected=candidate) AS passed,
 coalesce(jsonb_agg(name) FILTER (WHERE expected IS DISTINCT FROM candidate),'[]'::jsonb) AS failures
FROM evaluated;
