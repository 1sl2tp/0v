-- Private display-only visual correction. No collection or matcher reads.
CREATE TABLE v0_private.bill_account_review (
 media_asset_id uuid PRIMARY KEY,
 message_id uuid NOT NULL,
 customer_account_id uuid NOT NULL,
 raw_read_hash text NOT NULL CHECK (raw_read_hash ~ '^[0-9a-f]{32}$'),
 reviewed_account text NOT NULL CHECK (reviewed_account='2901181999999'),
 evidence_kind text NOT NULL CHECK (evidence_kind='visual_review'),
 reviewed_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE v0_private.bill_account_review ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON v0_private.bill_account_review FROM PUBLIC,anon,authenticated,service_role;
