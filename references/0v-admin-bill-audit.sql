-- Read-only authenticated admin bill audit. No financial writes, no public data.
CREATE FUNCTION v0_private.admin_bill_audit()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $audit$
DECLARE me uuid; result jsonb; total bigint;
BEGIN
  me:=(v0_private.admin_read('session',null)->>'account_id')::uuid;
  IF coalesce(auth.jwt()->>'aal','')<>'aal2' THEN RAISE EXCEPTION 'mfa_required' USING errcode='42501'; END IF;
  WITH scoped AS (
    SELECT r.id,r.status,left(r.reason,150) reason,r.amount_vnd::text AS amount_vnd,
      (r.ledger_id IS NOT NULL AND EXISTS(SELECT 1 FROM public.taphoa_debt_ledger l WHERE l.id=r.ledger_id AND l.customer_account_id=r.customer_account_id AND l.entry_type='collection')) AS has_ledger,
      a.id AS asset_id,a.message_id,a.conversation_id,a.kind,a.mime_type,a.storage_key,
      left(cust.display_name,150) AS customer,m.created_at AS sent_at,
      left(r.receiving_account,100) AS account_raw,left(ar.reviewed_account,100) AS account_reviewed,
      left(r.receiving_name,120) AS recipient,left(r.receiving_bank,100) AS receiving_bank,left(r.sending_bank,100) AS sending_bank,
      left(r.raw_read->>'transfer_content',1000) AS memo,left(r.raw_read->>'amount_text',80) AS amount_text,
      left(r.raw_read->>'transfer_date_printed_vn',120) AS date_raw,left(r.raw_read->>'transfer_date_vn',40) AS date_iso,
      left(r.raw_read->>'transfer_time_printed_vn',40) AS clock,left(r.transfer_reference,150) AS reference,left(r.raw_read->>'trace_code',100) AS trace,
      array_remove(ARRAY[
        CASE WHEN r.amount_vnd IS NULL OR r.amount_vnd<=0 THEN 'amount' END,
        CASE WHEN regexp_replace(coalesce(r.receiving_account,''),'[[:space:]]','','g')='290118199999' AND ar.reviewed_account IS NULL THEN 'short_account' END,
        CASE WHEN nullif(btrim(r.receiving_account),'') IS NULL THEN 'missing_account' END,
        CASE WHEN regexp_replace(coalesce(r.receiving_account,''),'[[:space:]]','','g') NOT IN ('','290118199999','2901181999999') THEN 'other_account' END,
        CASE WHEN nullif(btrim(r.receiving_name),'') IS NULL THEN 'missing_name' WHEN upper(btrim(r.receiving_name))<>'BUI XUAN TUNG' THEN 'other_name' END,
        CASE WHEN nullif(btrim(r.raw_read->>'transfer_date_printed_vn'),'') IS NULL OR r.raw_read->>'printed_date_invalid'='true' THEN 'date' END,
        CASE WHEN nullif(btrim(r.raw_read->>'transfer_time_printed_vn'),'') IS NULL THEN 'time' END,
        CASE WHEN nullif(btrim(r.raw_read->>'transfer_content'),'') IS NULL THEN 'memo' END,
        CASE WHEN r.raw_read->>'amount_role'='sender_debit' AND r.raw_read->>'image_type'='bank_credit_notification' THEN 'direction' END,
        CASE WHEN r.raw_read->>'sending_bank'='BIDV' AND r.raw_read->>'transfer_content' ~* '^SMB-TkThe[[:space:]]*:' AND (r.receiving_account IS NOT NULL OR r.receiving_name IS NOT NULL) THEN 'memo_recipient' END,
        CASE WHEN r.raw_read->>'time_date_conflict'='true' OR r.raw_read->>'clock_text_conflict'='true' OR r.raw_read->>'date_swap_suspected'='true' THEN 'time_conflict' END
      ],NULL) AS flags
    FROM public.chat_bank_bill_receipts r
    JOIN public.v21_media_assets a ON a.id=r.media_asset_id AND a.message_id=r.message_id AND a.owner_account_id=r.customer_account_id
    JOIN public.v21_messages m ON m.id=a.message_id AND m.conversation_id=a.conversation_id AND m.deleted_at IS NULL
    JOIN public.v21_conversations c ON c.id=a.conversation_id AND me IN(c.member_a,c.member_b) AND r.customer_account_id IN(c.member_a,c.member_b)
    JOIN public.v21_accounts cust ON cust.id=r.customer_account_id AND cust.id<>me AND cust.role='user' AND cust.deleted_at IS NULL AND cust.locked_at IS NULL
    LEFT JOIN v0_private.bill_account_review ar ON ar.media_asset_id=r.media_asset_id AND ar.message_id=r.message_id AND ar.customer_account_id=r.customer_account_id AND ar.raw_read_hash=md5(r.raw_read::text)
    WHERE a.deleted_at IS NULL AND r.status IN ('received','review','amount_read','duplicate','non_bill')
  ), page AS (SELECT * FROM scoped ORDER BY sent_at DESC,id DESC LIMIT 1000)
  SELECT (SELECT count(*) FROM scoped),coalesce((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.sent_at DESC,p.id DESC) FROM page p),'[]'::jsonb)
  INTO total,result;
  RETURN jsonb_build_object('account_id',me,'total',total,'rows',result);
END;
$audit$;
REVOKE ALL ON FUNCTION v0_private.admin_bill_audit() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION v0_private.admin_bill_audit() TO authenticated;
CREATE FUNCTION public.v0_admin_bill_audit()
RETURNS jsonb LANGUAGE sql STABLE SECURITY INVOKER SET search_path='' AS $audit$ SELECT v0_private.admin_bill_audit() $audit$;
REVOKE ALL ON FUNCTION public.v0_admin_bill_audit() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.v0_admin_bill_audit() TO authenticated;
