-- Review-only candidate: existing private read API, no table writes or new grants.
-- Apply only after isolated tests and separate rollout review. Preserve existing owner and ACL.
CREATE OR REPLACE FUNCTION v0_private.admin_media(p_conversation_id uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
DECLARE me uuid; result jsonb;
BEGIN
  me:=(v0_private.admin_read('session',null)->>'account_id')::uuid;
  IF NOT EXISTS (
    SELECT 1 FROM public.v21_conversations c JOIN public.v21_accounts a ON a.id=CASE WHEN c.member_a=me THEN c.member_b ELSE c.member_a END
    WHERE c.id=p_conversation_id AND me IN(c.member_a,c.member_b) AND a.role='user' AND a.deleted_at IS NULL AND a.locked_at IS NULL
  ) THEN RAISE EXCEPTION 'conversation_forbidden' USING errcode='42501'; END IF;
  SELECT coalesce(jsonb_agg(to_jsonb(x) ORDER BY x.message_id,x.sort_index,x.id),'[]'::jsonb) INTO result
  FROM (
    SELECT a.id,a.message_id,a.kind,a.mime_type,a.storage_key,a.width_px,a.height_px,a.file_name,a.sort_index,
      CASE WHEN r.status IN ('received','amount_read','review','duplicate') THEN jsonb_build_object(
        'asset_id',a.id,'message_id',a.message_id,'status',r.status,
        'has_ledger',EXISTS(SELECT 1 FROM public.taphoa_debt_ledger l WHERE l.id=r.ledger_id AND l.customer_account_id=r.customer_account_id AND l.entry_type='collection'),
        'amount_vnd',CASE WHEN r.amount_vnd>0 THEN r.amount_vnd::text ELSE legacy.amount_vnd END,
        'date_vn',CASE WHEN legacy.amount_vnd IS NOT NULL THEN to_char(r.transfer_at_vn,'DD/MM/YYYY') WHEN r.transfer_at_vn IS NOT NULL
          AND jsonb_typeof(r.raw_read->'transfer_date_printed_vn')='string'
          AND nullif(btrim(r.raw_read->>'transfer_date_printed_vn'),'') IS NOT NULL
          AND r.raw_read->>'transfer_date_vn'=to_char(r.transfer_at_vn,'YYYY-MM-DD')
          AND coalesce(r.raw_read->>'time_date_conflict','false')='false'
          AND coalesce(r.raw_read->>'printed_date_invalid','false')='false'
          AND coalesce(r.raw_read->>'date_swap_suspected','false')='false'
          AND coalesce(r.raw_read->>'ocr_iso_date_conflict','false')='false'
          THEN to_char(r.transfer_at_vn,'DD/MM/YYYY')
          WHEN r.transfer_at_vn IS NULL
          AND jsonb_typeof(r.raw_read->'transfer_date_printed_vn')='string'
          AND r.raw_read->>'transfer_date_printed_vn' ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
          AND r.raw_read->>'transfer_date_vn' ~ '^(19[789][0-9]|20[0-9]{2})-[0-9]{2}-[0-9]{2}$'
          AND coalesce(r.raw_read->>'time_date_conflict','false')='false'
          AND coalesce(r.raw_read->>'printed_date_invalid','false')='false'
          AND coalesce(r.raw_read->>'date_swap_suspected','false')='false'
          AND coalesce(r.raw_read->>'ocr_iso_date_conflict','false')='false'
          THEN CASE WHEN pg_input_is_valid(r.raw_read->>'transfer_date_vn','date') THEN
            CASE WHEN lpad(split_part(r.raw_read->>'transfer_date_printed_vn','/',1),2,'0')||'/'||lpad(split_part(r.raw_read->>'transfer_date_printed_vn','/',2),2,'0')||'/'||split_part(r.raw_read->>'transfer_date_printed_vn','/',3)=to_char((r.raw_read->>'transfer_date_vn')::date,'DD/MM/YYYY')
            THEN to_char((r.raw_read->>'transfer_date_vn')::date,'DD/MM/YYYY') END END END,
        'time_vn',CASE WHEN r.transfer_at_vn IS NOT NULL
          AND coalesce(r.raw_read->>'time_date_conflict','false')='false'
          AND coalesce(r.raw_read->>'clock_text_conflict','false')='false'
          AND r.raw_read->>'transaction_time_precision' IN ('minute','second')
          AND jsonb_typeof(r.raw_read->'transfer_time_printed_vn')='string'
          AND r.raw_read->>'transfer_time_printed_vn'=CASE WHEN r.raw_read->>'transaction_time_precision'='second' THEN to_char(r.transfer_at_vn,'HH24:MI:SS') ELSE to_char(r.transfer_at_vn,'HH24:MI') END
          THEN r.raw_read->>'transfer_time_printed_vn' END,
        'receiving_account',CASE WHEN memo_only.flag THEN NULL ELSE left(r.receiving_account,200) END,'receiving_name',CASE WHEN memo_only.flag THEN NULL ELSE left(r.receiving_name,200) END,
        'ocr_rechecked_account',CASE WHEN memo_only.flag THEN NULL WHEN regexp_replace(coalesce(r.receiving_account,''),'[[:space:]]','','g')='290118199999' AND ar.reviewed_account='2901181999999' THEN ar.reviewed_account WHEN regexp_replace(coalesce(r.receiving_account,''),'[[:space:]]','','g')='290118199999'
          AND r.raw_read->'account_digit_recheck'->>'source'='independent_focused_vision'
          AND regexp_replace(coalesce(r.raw_read->'account_digit_recheck'->>'first_visible',''),'[[:space:]]','','g')='290118199999'
          AND regexp_replace(coalesce(r.raw_read->'account_digit_recheck'->>'second_visible',''),'[[:space:]]','','g')='2901181999999'
          AND r.raw_read->'account_digit_recheck'->>'digit_count'='13'
          AND r.raw_read->'account_digit_recheck'->>'trailing_nines'='6'
          THEN '2901181999999' END,
        'bank_verified_account',CASE WHEN memo_only.flag THEN NULL WHEN r.status='received'
          AND regexp_replace(coalesce(r.receiving_account,''),'[[:space:]]','','g')='290118199999'
          AND EXISTS(SELECT 1 FROM public.chat_bank_app_collection_links k
            JOIN public.taphoa_agribank_notifications n ON n.id=k.notification_id
            JOIN public.taphoa_debt_ledger l ON l.id=k.ledger_id AND l.customer_account_id=r.customer_account_id AND l.entry_type='collection'
            WHERE k.receipt_id=r.id AND k.ledger_id=r.ledger_id
              AND n.package_name='com.vnpay.Agribank3g' AND n.status='credit_candidate'
              AND n.is_own_transfer=false AND n.bank_credit_account='2901181999999'
              AND n.amount_vnd=r.amount_vnd AND r.amount_vnd>0
              AND n.transfer_at AT TIME ZONE 'Asia/Ho_Chi_Minh'=r.transfer_at_vn)
          THEN '2901181999999' END,
        'transfer_content',coalesce(v.reviewed_memo,CASE WHEN jsonb_typeof(r.raw_read->'transfer_content')='string' THEN left(r.raw_read->>'transfer_content',1000) END),
        'transfer_reference',left(r.transfer_reference,200),'sending_bank',left(r.sending_bank,200),'receiving_bank',CASE WHEN memo_only.flag THEN NULL ELSE left(r.receiving_bank,200) END
      ) END AS bill_receipt
    FROM public.v21_media_assets a
    JOIN (SELECT id FROM public.v21_messages WHERE conversation_id=p_conversation_id AND deleted_at IS NULL ORDER BY created_at DESC,id DESC LIMIT 100) m ON m.id=a.message_id
    LEFT JOIN public.chat_bank_bill_receipts r ON r.media_asset_id=a.id AND r.message_id=a.message_id
      AND r.customer_account_id=a.owner_account_id AND r.customer_account_id<>me
      AND EXISTS(SELECT 1 FROM public.v21_conversations c WHERE c.id=p_conversation_id AND r.customer_account_id IN(c.member_a,c.member_b))
      AND auth.jwt()->>'aal'='aal2'
    LEFT JOIN v0_private.bill_memo_review v ON v.media_asset_id=r.media_asset_id AND v.message_id=r.message_id
      AND v.customer_account_id=r.customer_account_id AND v.raw_read_hash=md5(r.raw_read::text)
    LEFT JOIN v0_private.bill_account_review ar ON ar.media_asset_id=r.media_asset_id AND ar.message_id=r.message_id
      AND ar.customer_account_id=r.customer_account_id AND ar.raw_read_hash=md5(r.raw_read::text)
    -- Legacy OCR misclassified a sender debit as an incoming notification.
    -- Recover display only from the original explicit debit amount and agreeing
    -- short printed date/clock. Never change the receipt status or ledger.
    LEFT JOIN LATERAL (
      SELECT coalesce(r.status='review' AND r.ledger_id IS NULL
        AND r.raw_read->>'amount_role'='sender_debit'
        AND r.raw_read->>'image_type'='bank_credit_notification'
        AND r.raw_read->>'sending_bank'='BIDV'
        AND r.raw_read->>'transfer_content' ~* '^SMB-TkThe[[:space:]]*:',false) AS flag
    ) memo_only ON true
    LEFT JOIN LATERAL (
      SELECT CASE WHEN r.status='review' AND r.ledger_id IS NULL AND r.amount_vnd IS NULL
        AND r.raw_read->>'image_type'='bank_credit_notification'
        AND r.raw_read->>'amount_role'='sender_debit'
        AND r.raw_read->>'transaction_nature'='transfer'
        AND r.raw_read->>'amount_clear'='true' AND r.raw_read->>'transfer_success_visible'='true'
        AND r.raw_read->>'amount_text' ~ '^-[0-9]{1,3}(,[0-9]{3}){1,5}[[:space:]]*VND$'
        AND r.transfer_at_vn IS NOT NULL AND extract(year from r.transfer_at_vn) BETWEEN 2000 AND 2099
        AND ((r.raw_read->>'transfer_date_printed_raw_vn'=to_char(r.transfer_at_vn,'DD/MM/YY') AND r.raw_read->>'printed_date_invalid'='true') OR (memo_only.flag AND r.raw_read->>'transfer_date_printed_vn'=to_char(r.transfer_at_vn,'DD/MM/YYYY') AND coalesce(r.raw_read->>'printed_date_invalid','false')='false'))
        AND r.raw_read->>'transfer_date_vn'=to_char(r.transfer_at_vn,'YYYY-MM-DD')
        AND r.raw_read->>'transaction_time_precision'='minute'
        AND r.raw_read->>'transfer_time_printed_vn'=to_char(r.transfer_at_vn,'HH24:MI')
        AND coalesce(r.raw_read->>'time_date_conflict','false')='false'
        AND coalesce(r.raw_read->>'clock_text_conflict','false')='false'
        AND coalesce(r.raw_read->>'date_swap_suspected','false')='false'
        AND coalesce(r.raw_read->>'ocr_iso_date_conflict','false')='false'
        THEN nullif(ltrim(regexp_replace(r.raw_read->>'amount_text','[^0-9]','','g'),'0'),'')
      END AS amount_vnd
    ) legacy ON true
    WHERE a.conversation_id=p_conversation_id AND a.deleted_at IS NULL
  ) x;
  RETURN jsonb_build_object('account_id',me,'assets',result);
END;
$function$;
