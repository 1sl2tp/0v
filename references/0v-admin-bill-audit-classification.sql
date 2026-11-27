-- Read-only audit classification. Never modify receipt status or collection.
CREATE OR REPLACE FUNCTION v0_private.admin_bill_audit()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $audit$
DECLARE me uuid; result jsonb; total bigint;
BEGIN
  me:=(v0_private.admin_read('session',null)->>'account_id')::uuid;
  IF coalesce(auth.jwt()->>'aal','')<>'aal2' THEN RAISE EXCEPTION 'mfa_required' USING errcode='42501'; END IF;
  WITH scoped AS (
    SELECT r.id,r.status,k.audit_kind,left(r.reason,150) reason,r.amount_vnd::text AS amount_vnd,
      md5(coalesce(r.raw_read::text,'')) AS raw_hash,
      coalesce(n.review_state,'pending') AS review_state,coalesce(n.revision,0) AS review_revision,
      coalesce(n.corrections,'{}'::jsonb) AS corrections,coalesce(n.note,'') AS review_note,
      r.scanned_at AS ocr_scanned_at,n.updated_at AS result_saved_at,
      (r.ledger_id IS NOT NULL AND EXISTS(SELECT 1 FROM public.taphoa_debt_ledger l WHERE l.id=r.ledger_id AND l.customer_account_id=r.customer_account_id AND l.entry_type='collection')) AS has_ledger,
      v0_private.bill_verified_bank_clock(r,m.created_at) AS bank_clock,
      a.id AS asset_id,a.message_id,a.conversation_id,a.kind,a.mime_type,a.storage_key,
      left(cust.display_name,150) AS customer,m.created_at AS sent_at,
      left(r.receiving_account,100) AS account_raw,left(ar.reviewed_account,100) AS account_reviewed,
      left(r.receiving_name,120) AS recipient,left(r.receiving_bank,100) AS receiving_bank,left(r.sending_bank,100) AS sending_bank,
      left(r.raw_read->>'transfer_content',1000) AS memo,left(r.raw_read->>'amount_text',80) AS amount_text,
      left(r.raw_read->>'transfer_date_printed_vn',120) AS date_raw,left(r.raw_read->>'transfer_date_vn',40) AS date_iso,
      left(r.raw_read->>'transfer_time_printed_vn',40) AS clock,left(r.transfer_reference,150) AS reference,left(r.raw_read->>'trace_code',100) AS trace,
      CASE WHEN k.audit_kind='non_bill' OR r.reason IN ('duplicate_exact_image_sha256_no_ai','duplicate_origin_bill_unverified','same_image_as_confirmed_non_bill') THEN ARRAY[]::text[] ELSE array_remove(ARRAY[
        CASE WHEN r.amount_vnd IS NULL OR r.amount_vnd<=0 THEN 'amount' END,
        CASE WHEN regexp_replace(coalesce(r.receiving_account,''),'[[:space:]]','','g')='290118199999' AND ar.reviewed_account IS NULL THEN 'short_account' END,
        CASE WHEN nullif(btrim(r.receiving_account),'') IS NULL THEN 'missing_account' END,
        CASE WHEN regexp_replace(coalesce(r.receiving_account,''),'[[:space:]]','','g') NOT IN ('','290118199999','2901181999999') THEN 'other_account' END,
        CASE WHEN nullif(btrim(r.receiving_name),'') IS NULL THEN 'missing_name' WHEN upper(btrim(r.receiving_name))<>'BUI XUAN TUNG' THEN 'other_name' END,
        CASE WHEN nullif(btrim(r.raw_read->>'transfer_date_printed_vn'),'') IS NULL OR r.raw_read->>'printed_date_invalid'='true' THEN 'date' END,
        CASE WHEN nullif(btrim(r.raw_read->>'transfer_time_printed_vn'),'') IS NULL AND v0_private.bill_verified_bank_clock(r,m.created_at) IS NULL THEN 'time' END,
        CASE WHEN nullif(btrim(r.raw_read->>'transfer_content'),'') IS NULL THEN 'memo' END,
        CASE WHEN r.raw_read->>'amount_role'='sender_debit' AND r.raw_read->>'image_type'='bank_credit_notification' THEN 'direction' END,
        CASE WHEN r.raw_read->>'sending_bank'='BIDV' AND r.raw_read->>'transfer_content' ~* '^SMB-TkThe[[:space:]]*:' AND (r.receiving_account IS NOT NULL OR r.receiving_name IS NOT NULL) THEN 'memo_recipient' END,
        CASE WHEN r.raw_read->>'time_date_conflict'='true' OR r.raw_read->>'clock_text_conflict'='true' OR r.raw_read->>'date_swap_suspected'='true' THEN 'time_conflict' END
      ],NULL) END AS flags
    FROM public.chat_bank_bill_receipts r
    JOIN public.v21_media_assets a ON a.id=r.media_asset_id AND a.message_id=r.message_id AND a.owner_account_id=r.customer_account_id
    JOIN public.v21_messages m ON m.id=a.message_id AND m.conversation_id=a.conversation_id AND m.deleted_at IS NULL
    JOIN public.v21_conversations c ON c.id=a.conversation_id AND me IN(c.member_a,c.member_b) AND r.customer_account_id IN(c.member_a,c.member_b)
    JOIN public.v21_accounts cust ON cust.id=r.customer_account_id AND cust.id<>me AND cust.role='user' AND cust.deleted_at IS NULL AND cust.locked_at IS NULL
    LEFT JOIN v0_private.bill_account_review ar ON ar.media_asset_id=r.media_asset_id AND ar.message_id=r.message_id AND ar.customer_account_id=r.customer_account_id AND ar.raw_read_hash=md5(r.raw_read::text)
    LEFT JOIN v0_private.bill_audit_annotations n ON n.receipt_id=r.id AND n.admin_account_id=me AND n.raw_hash=md5(coalesce(r.raw_read::text,''))
    LEFT JOIN public.chat_bank_bill_receipts o ON o.id=r.duplicate_of AND o.customer_account_id=r.customer_account_id AND o.image_sha256=r.image_sha256 AND nullif(r.image_sha256,'') IS NOT NULL
    CROSS JOIN LATERAL (
      SELECT regexp_replace(coalesce(ar.reviewed_account,r.receiving_account,''),'[[:space:]]','','g') AS acct,
             regexp_replace(coalesce(o.receiving_account,''),'[[:space:]]','','g') AS origin_acct,
             r.raw_read->>'image_type' AS image_type,
             coalesce(r.reason IN ('duplicate_exact_image_sha256_no_ai','duplicate_origin_bill_unverified','same_image_as_confirmed_non_bill'),false) AS hash_only,
             coalesce(r.raw_read->>'sending_bank'='BIDV' AND r.raw_read->>'transfer_content' ~* '^SMB-TkThe[[:space:]]*:' AND r.raw_read->>'amount_role'='sender_debit',false) AS memo_only
    ) ev
    CROSS JOIN LATERAL (
      SELECT CASE
       WHEN r.ledger_id IS NULL AND (r.status='non_bill' OR ev.image_type='not_transfer_receipt' OR (ev.hash_only AND o.status='non_bill')) THEN 'non_bill'
       WHEN ev.hash_only THEN CASE WHEN o.status IN ('received','amount_read','review','duplicate') AND ev.origin_acct ~ '^([0-9]*[0-8])?9{4,6}$' AND (o.raw_read->>'image_type' IN ('successful_transfer_receipt','bank_credit_notification') OR o.ledger_id IS NOT NULL) THEN 'bill' ELSE 'unverified' END
       WHEN NOT ev.memo_only AND ev.acct ~ '^([0-9]*[0-8])?9{4,6}$' THEN 'bill'
       WHEN NOT ev.memo_only AND ev.acct<>'' AND ev.image_type IN ('successful_transfer_receipt','bank_credit_notification') THEN 'other_transfer'
       ELSE 'unverified'
      END AS audit_kind
    ) k
    WHERE a.deleted_at IS NULL AND r.status IN ('received','review','amount_read','duplicate','non_bill')
  ), page AS (SELECT * FROM scoped ORDER BY sent_at DESC,id DESC LIMIT 1000)
  SELECT (SELECT count(*) FROM scoped),coalesce((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.sent_at DESC,p.id DESC) FROM page p),'[]'::jsonb)
  INTO total,result;
  RETURN jsonb_build_object('account_id',me,'total',total,'rows',result);
END;
$audit$;
