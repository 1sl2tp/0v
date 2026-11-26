-- Private presentation-only evidence. Never consumed by bank matching or ledger.
-- No client write API. Reviewed transcription must be tied to the exact asset,
-- message, customer and immutable OCR snapshot; stale evidence is ignored.
CREATE TABLE v0_private.bill_memo_review (
 media_asset_id uuid PRIMARY KEY,
 message_id uuid NOT NULL,
 customer_account_id uuid NOT NULL,
 raw_read_hash text NOT NULL CHECK (raw_read_hash ~ '^[0-9a-f]{32}$'),
 reviewed_memo text NOT NULL CHECK (length(btrim(reviewed_memo)) BETWEEN 1 AND 1000),
 evidence_kind text NOT NULL CHECK (evidence_kind IN ('visual_review')),
 reviewed_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE v0_private.bill_memo_review ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON v0_private.bill_memo_review FROM PUBLIC,anon,authenticated,service_role;
