# Lesson 33 phase 1
- https://github.com/adobe/react-spectrum/tree/main/packages/%40react-stately/collections — collection ownership and stable item identity.
- https://react.dev/learn/keeping-components-pure — separate rendering from state updates.
- https://github.com/1sl2tp/0v/blob/main/references/COMPONENT-API.md — existing parent contracts.
Decision: migrate plain-text and contact presentation through existing parents first; do not replace fixture state or keyboard at the same time. No upstream code copied.

## v13.74 phase 2
- https://redux.js.org/usage/structuring-reducers/normalizing-state-shape — single normalized source for related entities.
- https://redux.js.org/toolkit/api/createEntityAdapter — stable IDs and derived selectors.
- https://matrix-org.github.io/matrix-js-sdk/classes/matrix.Room.html — room-scoped ordered timelines.
Decision: keep existing Store APIs, use MainDataController as fixture adapter, retain legacy seed display and QA rollback; no runtime dependency or copied upstream code.

## v13.75 phase 3a
- https://github.com/dinerojs/dinero.js/blob/main/README.md — immutable money, bigint and explicit precision.
- https://github.com/tc39/proposal-temporal/blob/main/docs/timezone.md — distinguish instant, local calendar/time and zone.
Decision: retain exact Foundation APIs, use narrow fixture boundary adapter, no new dependency. Do not infer short date year or change reconciliation policy.

## v13.76 phase 3b
- https://github.com/statelyai/xstate — explicit state transitions and guards.
- https://github.com/stripe/stripe-node/blob/master/README.md — idempotency keys and safe retry.
- https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Webhook_Security_Cheat_Sheet.md — verify event and persist processed IDs before suppressing duplicate delivery.
Decision: narrow local fixture guard only; durable idempotency remains a production adapter responsibility. Do not loosen real bill matching or send notices.

## v13.77 phase 3c
- https://github.com/aws-samples/transactional-outbox-pattern/blob/main/README.md — separate committed write and relay, duplicate handling.
- https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html — atomic intent and idempotent consumer.
Decision: reuse existing evidence owner, expose read-only order projection, do not implement real outbox transport in UI.

## v13.78 phase 3d
- https://www.unicode.org/cldr/charts/50/verify/dates/vi.html — Vietnamese date patterns.
- https://github.com/unicode-org/cldr/blob/main/docs/site/translation/date-time/date-time-patterns.md — locale date fields.
- https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Webhook_Security_Cheat_Sheet.md — verify and persist processed event IDs for duplicate handling.
Decision: explicit calendar dates, conservative fixture-only candidate matching; no date inference or durable posting claim.

## v13.79 phase 3e
- https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing — replay, immutable event history and idempotent consumers.
- https://github.com/matrix-org/matrix-js-sdk/blob/develop/src/client.ts — sync reconnect states and retry.
Decision: bounded local event dispatcher, deterministic recompute, no production event store or transport.

## v13.80 phase 3f
- https://github.com/w3c/IndexedDB — IndexedDB transaction atomicity and completion.
- https://developer.mozilla.org/en-US/docs/Web/API/IDBTransaction/complete_event — publish only on transaction completion.
- https://github.com/postgres/postgres/blob/master/doc/src/sgml/ddl.sgml — unique constraints and durable relational design (future production adapter only).
Decision: isolated bounded journal for fixtures; no server/database migration or real posting.

## v13.81 phase 3g
- https://github.com/TanStack/table — separate row projection, sorting and presentation.
- https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing — derive read models from events.
Decision: read-only projection over existing fixture API, explicit clock and multiple reasons; no new production dependency.

## v13.82 phase 3h
- https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/coding/data-modeling.md — immutable financial transfers and idempotent IDs.
- https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/reference/transfer.md — stable financial transaction identity.
Decision: attach verification evidence to original fixture receipt, no additional posting and no silent amount change. Production implementation separate.

## v13.83 phase 3i
- https://github.com/JohannesBuchner/imagehash — difference and crop-resistant hashing.
- https://github.com/thorn-oss/perception/blob/main/docs/examples/deduplication.rst — similarity thresholds.
- https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/coding/data-modeling.md — idempotent transaction identity.
Decision: source digest + normalized regions, conservative dHash candidates, no automatic merge. No upstream code copied or dependency added.

## v13.84 phase 3j
- https://github.com/opencv/opencv/blob/5.x/doc/tutorials/imgproc/shapedescriptors/find_contours/find_contours.markdown — region segmentation concepts; current lightweight horizontal projection is not OpenCV contour detection.
- https://github.com/JohannesBuchner/imagehash/blob/master/README.rst — luminance hashes vs cryptographic digests.
- https://github.com/naptha/tesseract.js/blob/master/README.md — reusable OCR worker interface; not installed in this phase.
Decision: local browser decode and review-only region proposals. No upstream code copied, no external dependency.

## v13.85 phase 3k
- https://github.com/naptha/tesseract.js/blob/master/docs/api.md — reusable worker, recognize and language assets. No engine installed.
- https://github.com/PaddlePaddle/PaddleOCR/blob/main/README.md — OCR/document understanding toolkit, separation of recognition and extraction.
Decision: deterministic text-to-field contract ahead of OCR engine; preserve provenance, no inferred payment data, no new dependency.

## v13.86 phase 3l
- https://github.com/naptha/tesseract.js/blob/v6.0.1/docs/api.md — worker lifecycle, recognize, output and language options.
- https://github.com/naptha/tesseract.js/blob/v6.0.1/src/worker-script/index.js — language download/cache behavior.
- https://github.com/naptha/tesseract.js/blob/v6.0.1/package.json — exact version/core compatibility.
Decision: opt-in demo CDN only; no real customer image until self-hosted verified assets. No copied upstream code, no dependency committed.

## v13.87
Internal CHAT reference: docs/bank-bill-ocr-casebook.md (BANK-286/317), bill-amount-rules.mjs (BANK-357/358) and test_bank269_bill_literal_date_clock_20261110.mjs. Reused field semantics and conservative literal date/clock rules only; no private source examples or data copied. Tesseract.js integration unchanged.

## v13.88
Internal CHAT bill-amount-rules.mjs printed date parser supports abbreviated Vietnamese month labels. Private structured corpus analysis yielded grouped account, abbreviated date and numeric reference prefix patterns; only format categories were used, no record values copied. Existing shared ParseAPI remains date owner.

## v13.89
Internal CHAT bill-app-preview.mjs and bill-transfer-identity.mjs: full bank destination, literal memo and competing-credit safeguards, independent transaction clock and late notice. Adopted conservative review-only partial account evidence and token-boundary memo checks; no customer constants copied.

## v13.90
CHAT supabase/functions/v21-bank-bill-event/bill-app-preview.mjs: bank-side QR/IBFT/MB envelopes, exact delimited sharedBankReference, contiguous memo containment; retained independent proof guards, no customer constants copied. Compact matching restricted to review in 0v.

## v13.91
CHAT bill-amount-rules.mjs account cleaning reviewed; stricter horizontal-space-only removal adopted. No customer constants copied.

## v13.92
CHAT bill-transfer-identity.mjs BANK-214: equal amounts do not establish identity; separate reliable references and competing credit guards. 0v adds conservative explicit shared-reference namespace gating and exclusion audit. No customer constants copied.

## v13.93
CHAT bill-app-preview.mjs bankEventTime, creditAccountFromEvent, bankMemo and wrapper formats. Aggregate private notice format analysis informed strict anchored parser; no private records or customer constants committed.

## v13.94
CHAT bill-app-preview.mjs verifiedMccMemo, verifiedMbvcbMemo, verifiedTwelveCharRoutingMemo and verifiedIbftMemo. Adopt anchored layouts and independent account/clock/sender checks, no customer-specific constants. Read-only aggregate notification shape analysis.

## v13.95
CHAT bill-app-preview.mjs sender-bound QR logic and observed private aggregate MCC shape variants; independently known recipient required for generic sender proof, not copied account/name constants. No private record payload committed.

## v13.96
CHAT bill-app-preview.mjs verifiedMbvcbTransferSuffixOcr and contiguousMemoContains studied. Private aggregate residual shapes informed diagnostic-only gap, short equality and cross-day clock conflict. No raw values copied.

## v13.97
CHAT bill-app-preview.mjs previewBillReferenceMatch and sharedBankReference: date-only alternative proof remains review pending financial guard. 0v adds conservative full recipient, explicit non-own-transfer and unique batch evidence without current-day expiry. No private constants copied.

## v13.98
User clarification: missing bill clock requires verification. CHAT previewBillReferenceMatch remains review-only; no automatic collection from alternative reference proof. Explicit manual history is unchanged.

## v13.98 revision 2
CHAT bill-app-preview.mjs blob 3fb53ea99124ed673a588281787a2e135a8a5e26, existing reference/memo and competing evidence path; reuse 0v memo residual diagnostics and review projection. No external UI dependency or private constants copied.

## v13.99
Astryx Card.tsx pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a (container owns spacing), Table.tsx 9496cdd32ce30ad6d28707eef48dada3bf2033b4 (density/wrap at parent); CHAT bill-app-preview.mjs 3fb53ea99124ed673a588281787a2e135a8a5e26 (independent evidence, competing transactions). Reuse CardController and FormatAPI; no upstream runtime copied, no customer values. No new selection or interaction state.

## v13.100
CHAT bill-transfer-identity.mjs blob 72a8bed404e47aa137d7a83df982b914d74620fc: equal amount is not transfer identity and distinct bills may compete for one credit. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a: parent container owns spacing. Reuse existing candidate edges and CardController; no new financial authority or source code copied.

## v13.101
CHAT credit-duplicate-identity.mjs blob 2b9f7c4231ba762dfdb80ad3e1bf7e2cb9b0d536: exact entire official body including final balance, independent printed minute, verified source/amount/account; received timestamp is transport metadata. 0v requires explicit non-own flag and independent parsed memo consistency; preserves competing unposted aliases. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a, parent geometry. No upstream runtime or customer constants copied.

## v13.102
ImageHash https://github.com/JohannesBuchner/imagehash/blob/master/imagehash/__init__.py ImageMultiHash matches/region_cutoff/Hamming distance: compare multiple region fingerprints; 0v uses bounded fixed inset candidates instead of segmentation, stricter independent bill evidence, no upstream code copied. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a, existing parent layout. No private image or customer values.

## v13.103
Adobe React Stately SelectionManager.ts pinned blob d6ff15c5b5efd7f9be685f87f46c3ed251c093f5: selected keys are separate from focused key and collection rendering. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a: existing parent layout. Reuse 0v normalized region identity and whitespace projection, not Adobe runtime. No transaction identity inferred from geometry.

## v13.104
Tesseract.js v6.0.1 src/createWorker.js blob 89b53b89b27f6579155ed2a0ef372fa8c2a8b8e6: per-image recognize job and terminate lifecycle; reuse current adapter, separate region job data, close failed worker. Astryx Button pinned blob f87eb657180a0de978fb3ba1c59c24909a9cc63d: separate interaction/loading state; no upstream code copied. No real bill samples.

## v13.105
Adobe react-stately useNumberFieldState.ts pinned blob eed17a1d22715cf92ece7156c661c026deb53acc: draft input distinct from commit/validation. Tesseract.js v6.0.1 docs/api.md blob cc3f82d7d0eacd6df825b4c50ad19357fdca557c: recognize supports rectangle; not used until field bounding geometry exists. Astryx Button pinned blob f87eb657180a0de978fb3ba1c59c24909a9cc63d. Reuse 0v parse and Card/Button; no upstream code or private values copied.

## v13.106
Tesseract.js v6.0.1 src/index.d.ts blob 1f5a9c8094fe4de7983467f9efb43bdb4de535f2: OutputFormats.blocks, Page.blocks, Block.paragraphs, Paragraph.lines, Line.text/bbox. Adobe SelectionManager pinned blob d6ff15c5b5efd7f9be685f87f46c3ed251c093f5: stable selection identity; Astryx Card blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a. Reuse parser provenance and crop geometry, no upstream code copied or private values.

## v13.107
Tesseract tessdoc ImproveQuality.md blob 522d6369143d4c17cda2b4ad18d133d2f5bbf975: rescaling, binarisation and preprocessing may help or hurt recognition; compare variants instead of claiming improved accuracy. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a: reuse existing card layout. Existing Tesseract adapter and field parser reused; no upstream code or private data copied.

## v13.108
Adobe NumberParser.ts pinned blob 66e59aff3510121ca373c0b8e39dacd3a8e1e0: explicit locale separators, reject incompatible punctuation. Tesseract.js v6.0.1 docs/api.md blob cc3f82d7d0eacd6df825b4c50ad19357fdca557c: whitelist restricts recognition output; deliberately not applied as it could hide letter/digit uncertainty. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a. 0v diagnostic groups are experimental, not measured error probabilities. No upstream code or private values copied.

## v13.109
CHAT bill-app-preview.mjs blob 3fb53ea99124ed673a588281787a2e135a8a5e26: contiguousMemoContains length floor, sharedBankReference explicit boundaries, wrapper context guards. 0v retains existing parser and adds conservative numeric token punctuation and compound reference boundary; no upstream runtime or private constants copied. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a, existing review card.

## v13.110
Google diff-match-patch javascript/diff_match_patch_uncompressed.js blob 88a702c2e232a2b8158f176a4cee9be845def2a2: common prefix/suffix concept. CHAT bill-app-preview.mjs blob 3fb53ea99124ed673a588281787a2e135a8a5e26: contiguousMemoContains and sender-bound QR/suffix guards. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a. No generic edit-distance proof or upstream runtime/private values copied.

## v13.111
CHAT bill-app-preview.mjs blob 3fb53ea99124ed673a588281787a2e135a8a5e26: explicit sender_name independent of receiving account/name. ERPNext erpnext/accounts/doctype/payment_entry/payment_entry.py blob 57dd7c862089e9342b43db6da0d426eb3c2dade4: party and paid_from/paid_to are distinct fields. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a. No upstream runtime or private constants copied.

## v13.112
ERPNext erpnext/accounts/doctype/payment_entry/payment_entry.py blob 57dd7c862089e9342b43db6da0d426eb3c2dade4: allocated/unallocated totals, latest outstanding check and aggregate reference allocation. 0v uses existing exact DecimalAPI, not ERPNext float arithmetic. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a. Existing BankJournal owner, no upstream runtime/private values copied.

## v13.113
ERPNext payment_entry.py blob 57dd7c862089e9342b43db6da0d426eb3c2dade4: latest outstanding and cumulative allocated reference validation. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a. Reuse 0v BankJournal allocation and DecimalAPI; cycle grouping is local explicit fixture policy, not copied ERPNext workflow.

## v13.113 correction
ERPNext accounts_receivable.py blob 8698a69d27c80015364faf2211174174e0b594a8: party subtotal and balance projection; local rolling signed-balance/cycle policy follows user's clarified business model, no upstream code or float arithmetic copied. Existing Astryx Card and 0v DecimalAPI used.

## v13.114
PostgreSQL doc/src/sgml/ddl.sgml blob d78d986756ebd1fe76aa778516fc0a3246a17491: uniqueness across rows, eventual server constraint not implemented. ERPNext accounts_receivable.py blob 8698a69d27c80015364faf2211174174e0b594a8: party subtotals kept separate. Astryx Card pinned blob 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a. Reuse existing owner, no upstream code or private values copied.

## v13.115 persistent fixture references
- [MDN IndexedDB basic terminology](https://github.com/mdn/content/blob/main/files/en-us/web/api/indexeddb_api/basic_terminology/index.md): overlapping readwrite scopes cannot run concurrently.
- [PostgreSQL unique index checks](https://www.postgresql.org/docs/current/index-unique-checks.html): server-side unique index needed for real cross-device guarantees; not implemented in this fixture.

## v13.116 database references
- https://www.postgresql.org/docs/current/index-unique-checks.html — concurrent uniqueness at index insertion.
- https://www.postgresql.org/docs/current/transaction-iso.html — concurrent conflict visibility in Read Committed.
- https://github.com/supabase/supabase/blob/master/apps/docs/content/guides/database/functions.mdx — security invoker, restricted function execution.
- https://supabase.com/docs/guides/database/postgres/row-level-security — RLS defense in depth.

## v13.117 identity references
- https://plaid.com/core-exchange/docs/reference/6.3/ — transaction IDs account-scoped and not reset per day/statement cycle.
- https://plaid.com/docs/transactions/transactions-data/ — explicit linkage when identity changes between pending and posted states.
These are reference models, not documentation of Agribank's actual identity format.
