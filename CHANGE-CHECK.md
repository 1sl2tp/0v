# CHANGE-CHECK — v13.49
v13.48 CI 45497164881, publish 45497321816 and Pages 45497349674 success. Read AGENTS/RULES/COMPONENT-API and Adobe/TanStack/Astryx sources. DYNAMIC-VIRTUAL/KB-LOCK/SOURCE-GATE. Extended same Virtualizer, synthetic mixed text/image lab, measurement/anchor and edge test. Static 30 passed; source integrity/browser pending. Four protected keyboard ranges unchanged, no main chat changes, no production data. Native, momentum, variable-size real-world performance, interactive rows, actual chat integration pending. Blob 1efe9d1280268b1867545f0a0547f41b1448b96b.


## v13.49 — sửa CI đỏ, vòng 2
E0: PR #16 run 45497811343, job 138812833285, audit-api-browser.cjs:171 fails bottom <= 2 after last row growth. Absolute row overflow changes DOM scrollHeight before ResizeObserver; capture must use previous prefix extent. E1: dynamic stage clips overflow; capture uses old model extent and restores exact model bottom; existing fixed mode and edgeChanged policy preserved. Keep 2px threshold; add shrinking and away-from-bottom regression. RULES DYNAMIC-VIRTUAL-02, KB-LOCK, SOURCE-GATE. Read Adobe ScrollAnchor previousContentSize, TanStack resizeItem/getVirtualDistanceFromEnd, Astryx Stack. Same pending release v13.49; no new released version. No main/chat/keyboard or production change. E2 CI/E3 Pages/E4 native/E5 acceptance pending; no local full-repo runtime available in connector.


## v13.50 — ReleaseUpdater Web/PWA lifecycle
E0 code audit: arbitrary button click latches dirty indefinitely; r from older target suppresses later version; missing online/resume and idle recheck. Screenshot desktop already v13.49; mobile failure not reproduced on physical device. E1 scoped fix RELEASE-PROOF-02: explicit read-only allowlist, version-specific throttle, foreground lifecycle/online, pending idle and scroll guard, blocker diagnostics, tests for readonly, resume + previous r, and submitted sample data preservation. Read Vite client.ts blob 17fe70a1933247ba654b2a11be9a6f13a1e223fe visibility/reconnect; GoogleChrome Workbox.ts blob b43baeef3221763e5aa5e304f8a9147db7d52ca4 waiting/activation separation (no SW registration in 0v; no new SW). No keyboard/DB/production changes. Existing old clients may need one manual refresh to receive repaired updater. E2/E3 pending CI/Pages; E4 native untested. Bài 21 deferred to next version.

### v13.50 vòng 2 — resume idle deadline
E0 CI PR run 45499157386 job 138817483944: clean/dirty/stale/lab/readonly passed; resume timeout 10s, pending v13.51, deferred, dirty=false, blockers=[] at timeout. The previous fix only scheduled idle retry on activity *after* pending was known; early discovery without subsequent activity fell back to 15s interval. E1 schedule idle deadline in finally after releasing busy if only transient activity (or no blockers), preserve existing guards and same-target cooldown. Strengthen clean startup to 8s; keep resume 10s and existing mutation test. Same release v13.50, prior source receipts Vite/Workbox, RELEASE-PROOF-03, KB-LOCK unchanged. CI/Pages/native pending.


## v13.51 — bài toán 21 history/tail API
v13.50 PR #17 CI 45499739940 and push 45499730427 success; verified release 45499883262 logged Published and verified v13.50; Pages 45499913264 success. All seven ReleaseUpdater cases passed; dynamic anchor regression passed. E1: extend same Virtualizer prepend/append/jumpEnd, explicit followOnAppend profile, lab controls and browser tests. RULE HISTORY-API-01–04, SOURCE-GATE, KB-LOCK. Read pinned Adobe ScrollAnchor and TanStack setOptions key anchor/followOnAppend and Astryx Stack; no dependency. Existing chat, production data, keyboard and release updater unchanged (version strings only). Browser and static audit pending CI, native PWA/momentum/remote load pending. No manual deploy.


## v13.52 — bài toán 22 MessageStore
v13.51 PR #18 merged 8d384de348e6716185a5092585ce0ed8c2dbd87c; CI 45500301181/45500281350 success; Publish 45500471846 and Pages 45500496409 success. E1 normalized in-memory MessageStore + scoped subscriptions, atomic batch, revision/tombstone and stable ID order, independent synthetic lab, static and browser tests. MESSAGE-API-01–05, KB-LOCK, SOURCE-GATE. Read Redux Toolkit entity adapters, Matrix EventTimelineSet/MatrixEvent, Adobe SelectionManager, Astryx Stack; no runtime dependency. No Main, keyboard, network, server, DB, Push or real messages changed. CI, Pages for v13.52 and native pending. No manual deploy.


## v13.53 — bài toán 23 ConversationStore
v13.52 PR #19 merged b619cdb41f2858f8983dfdde4fdaa693e3c5b89f; CI 45501369055/45501353130, verified release 45501581473 and Pages 45501607342 success. E1: metadata/latest reference, explicit global activity order, row/list subscriptions, pending payload, lab with keyed DOM and tests. CONVERSATION-API-01–05, MESSAGE-API, SOURCE-GATE, KB-LOCK. Read Element room-list-v3/message-preview (old paths not found, located new paths), Matrix Room, Redux selectors, Adobe SelectionManager and Astryx Stack. No main, actual notifications, keyboard or production change. CI/Pages for v13.53 pending; native, sync, cache, large-scale scroll and server summary protocol pending.


## v13.54 — Foundation API 24A–E
v13.53 PR #20 merged aa823e822e2e532fc4c5db574b9429189a9971e6; CI 45502499598/45502479872 and release 45502720937, Pages 45502742253 success. E1: TimeAPI/DecimalAPI/MoneyAPI/FormatAPI/ParseAPI + CalendarAPI versioned dataset contract, ScheduleAPI plan (no actual cron). Independent foundationlab, static/browser timezone tests, RULE and source receipts. Source study PostgreSQL, tzdb, CLDR, Temporal, decimal.js, Adobe NumberParser, Odoo, ERPNext, pg_cron, date-holidays, LichTa, Astryx. Dinero path unavailable; no code copied. No DB schema/session/production/job/keyboard/Main migration, no legal holiday or lunar dataset activated. Financial precision proposed and implemented in lab only; existing real data review before migration. CI/Pages pending; E4 native pending. No manual deploy.


## v13.55 — runtime context and live business periods
v13.54 PR #21 merged e78cbb50340d9022a7df2e819d9b58c6e5e469a9; CI 45504209714/45504189465, Publish 45504353367, Pages 45504378173 success. E1 TimeAPI.current, RuntimeContextAPI derive/read/watch, dynamic contextlab and main date-format helper delegation; explicit device clock/source and no location/lock inference. Source Adobe queries, Element RoomViewStore, MDN visibility/focus, Astryx Stack. Failed old source paths date-fns and page-lifecycle source; substituted actual Adobe/MDN. Static and Chromium timezone/route/visibility tests pending. No production DB, real notification, scheduler, keyboard, financial changes. Native/authoritative clock/actual presence sync pending. SyncController deferred to next version. No manual deploy.

### v13.55 vòng 2 — timezone alias
E0 push 45504971405 and PR 45504989527 failed; job 138837770960 line 199 expected Asia/Ho_Chi_Minh, actual Asia/Saigon; Foundation both timezone profiles and runtime Los Angeles passed. E1 normalize only verified tzdb alias, expose raw separately, keep canonical assertion and add raw/other/null checks. No date calculation, scroll, keyboard, backend or release gate change. Same v13.55 pending CI/Pages.


## v13.56 — bài toán 24F SyncController
v13.55 PR #22 merged 057347f440aa8bfcefa271802e9f803a9d615167; CI 45506087768/45506075754 success, Publish 45506285973 and Pages 45506310473 success. E1 scoped pull log with contiguous cursor, envelope validation, per-event committed prefix, single-flight coalescing, offline generation guard, mock lab tests for pagination/backlog/duplicate/fetch failure/gap/retry/disposal. SYNC-API-01–05; SOURCE-GATE, KB-LOCK. Read Matrix sync, TanStack retryer, Adobe useAsyncList, Astryx Stack. No DB/credentials/real notification/keyboard/Main changes. No durable cursor, backoff/timeout, atomic page or live server guarantee. CI/Pages/native pending. No manual deploy.


## v13.57 — NoticeDelivery evidence contract
v13.56 PR #23 merged f7c5888151a069ad48d92852aeefc299ac307160; CI 45507628695/45507606548, publish 45507760744 and Pages 45507787679 success. E0 anonymized incident: delivered order committed, two image-only message envelopes/tickets/PNG objects exist; neither attached_at nor media rows nor Zalo/Push outbox evidence. Exact RPC error unavailable in queried log window. Bridge logs warning and returns false; no durable recovery in inspected path. E1 NoticeDeliveryAPI projection, per-recipient/channel unique key, expired/ambiguous review, synthetic lab, static/browser proof. NOTICE-API-01–06, SOURCE-GATE, KB-LOCK. No personal names, order IDs or account IDs committed. No real messages, DB changes, production repo changes or old order repair. Worker/server outbox migration pending; CacheController deferred. CI/Pages pending.


## v13.58 — NoticeRecovery state machine and synthetic persistence
v13.57 PR #24 merged 3e8af3b75030f793b63ae4448ec062aee71642a5; CI 45509006110/45508988457, Publish 45509131190, Pages 45509156318 success. E1 recovery claim/settle fencing, known-no-effect retry limit/backoff, unknown/expired review, proof stage progression, synthetic IndexedDB transactional adapter and reload browser tests. RECOVERY-API-01–05; NOTICE-API, SOURCE-GATE, KB-LOCK. No real order IDs, data, send, production repo/DB or keyboard changes. No live worker, server durability or provider reconciliation; no historical repair. CI/Pages pending.


## v13.59 — CacheController checkpoint fixture
v13.58 PR #25 merged 995f551d98203a24b2d770319872dfc12c5dc1ad; CI 45509539892/45509519656, publish 45509741979, Pages 45509764455 success. E1 bounded synthetic journal with atomic IndexedDB checkpoint/cursor, replay through existing stores, scope/schema/age validation, cursor CAS and abort tests; CACHE-API-01–05. Read Matrix IndexedDB backend, Dexie transaction, TanStack persist, Adobe and Astryx. No production data, true account cache, real transport/notification, keyboard or Main change. Lab full journal replay, not production performance; live sync adapter and native/CI/Pages pending.


## v13.60 — Cache + Sync integration
v13.59 PR #26 merged 5167ce3686c9c122562145925db055612f2a0bdd; CI 45512287755/45512271944 success, publish 45512502833, Pages 45512530415 success. E1 optional durable page adapter in existing SyncController, CachedSyncSession hydrate+initial cursor, committed-page projection even if offline mid-commit, restore-required guard on projection error, mock integration lab and Chromium proof. CACHE-SYNC-01–05, CACHE-API, SYNC-API, SOURCE-GATE, KB-LOCK. Re-read Matrix sync/backend, TanStack persist, Adobe/Astryx. No production, real network, auth, keyboard or actual notification changes. CI/Pages pending; full journal replay and separate store notifications still not production optimized. No manual deploy.


## v13.61 — DirectoryController stable scroll anchor
v13.60 PR #27 merged a20dc6435884921bcb740ecbb5cd0a65ccf7cf33; CI 45512892810/45512876382, publish 45513030814, Pages 45513052513 success. E1 opt-in fixed directory anchor profile in Virtualizer, key/offset and promoted-key fallback, scoped mounted patch, stable refs and local minimal DOM moves, 200 sample row lab. DIRECTORY-API-01–05, SOURCE-GATE, KB-LOCK. Read TanStack Virtual, Element RoomListStoreV3, Adobe SelectionManager, Astryx Stack. No keyboard/main scroll production or real data change. Native momentum/dynamic row/search/selection, large-scale perf and CI/Pages pending.

### v13.61 vòng 2 — browser audit lexical scope
E0 CI 45513598749/45513583663 failed before Chromium execution: duplicate const dv at audit-api-browser.cjs line 252. E1 isolate new directory test in block; all assertions retained. Add compile-only browser audit syntax gate before browser installation; both scripts compiled in connector JS without execution. DIRECTORY-API-06. Runtime, snapshot and version unchanged; no production or keyboard change. CI/Pages pending.


## v13.62 — ReadStateController
v13.61 PR #28 merged 8148ba11fe3ccb95f9bfcb5fdd77a7e3958a27fa; CI 45513916588/45513905998, publish 45514089948, Pages 45514118294 success. E1 scoped read proposal, synthetic dwell/context, contiguous prefix/gap, server receipt ack revision, unknown unread coverage, read-state lab. READ-API-01–05, SOURCE-GATE, KB-LOCK. Source Matrix read-receipt, Element TimelinePanel, W3C IntersectionObserver, Adobe SelectionManager, Astryx Stack. Browser test block and compile syntax checked; CI/Pages pending. No actual visibility adapter, backend receipt, production data, keyboard or notifications; no human reading proof. No manual deploy.


## v13.63 — PresenceController
v13.62 PR #29 merged 86a14b049ec888deb26ced23c5de6afeaec0686b; CI 45514538295/45514520417 success, Pages 45514709020 success. E1 scoped synthetic lease registry, context projection, stale generation/sequence, expiry unknown, explicit leave, two session lab. PRESENCE-API-01–05; SOURCE-GATE, KB-LOCK. Read Phoenix, Supabase realtime handler, MDN, Adobe and Astryx. Syntax compiled before commit. No actual presence transport, auth, notification, production, DB, keyboard or Main change. CI/Pages pending. Candidate is not read or suppression proof. No manual deploy.


## v13.64 — NotificationController
v13.63 PR #30 merged 2e038ae7589e5fd768098600f0d9c8ef4b0e1990; CI 45514986108/45514970063 success; Pages 45515164805 pending at initial check. E1 pure alert policy and in-memory ledger, scoped foreground offer, confirmed-read suppression, duplicate id, exact attempt settlement, known-no-effect fallback, uncertain review, tag and permission, synthetic lab. NOTIFICATION-API-01–06, SOURCE-GATE, KB-LOCK. Read WHATWG, Element, Workbox, Adobe and Astryx. Syntax compiled. No real send, worker, permission request, provider, backend, production or keyboard/Main changes. Durable atomic cross-tab claim, timeout/reconciliation, native user-visible requirements and actual delivery proof pending. No manual deploy.


## v13.65 — durable alert fixture
v13.64 PR #31 merged ca070a2b58a437ed48797ba885d4c5a28340f94a; CI 45515474679/45515456751, publish 45515634470, Pages 45515657928 success. E1 refactor shared alert transitions, atomic synthetic IDB claim, owner/token lease, expiry review and MessageChannel fixture ack/timeout, two-tab and reload tests. ALERT-DURABLE-01–05, SOURCE-GATE, KB-LOCK. Compile checked; CI/Pages pending. No actual Service Worker, real Push, production, DB/keyboard/Main change; no cross-device or exactly-once guarantee. No manual deploy.


## v13.66 — multi-device fixture
v13.65 PR #32 merged 5907ddda8c7dfe175dba5315e030582d1e073c71; CI 45516273288/45516250009, publish 45516410983, Pages 45516427368 success. E1 opt-in receipt events on memory-mode SyncController, independent device projections, canonical mock server log, idempotent command and monotonic receipt, offline catchup. MULTI-API-01–05, SOURCE-GATE, KB-LOCK. Syntax checked, CI/Pages pending. No actual devices, cache receipt persistence, real writes, backend, Push or keyboard/Main changes. No manual deploy.

## v13.67 — offline command fixture
v13.66 PR #33 merged 736c0ed0d0d183106af4561d60dd8675a064897f. E1 durable synthetic outbox scoped by actor/device/run, stable command ID, ACK validation and generation fencing, reuse MultiDevice fixture and SyncController. OFFLINE-API-01–05; test cases added, CI pending. No real reload/server persistence/cross-tab arbitration, production, backend, real send or keyboard changes. No manual deploy.

## v13.68 — offline reload fixture
v13.67 PR #34 merged 897bed90906e7f332128bba94c3832582ebe68c4; PR CI 45520236044 success. E1 stable lab session across reload, separate durable synthetic server journal, original command and message IDs, ordered replay and ACK-generation fence inside transaction. RELOAD-API-01–04; classic scripts/browser audit compiled; CI pending. Same-tab F5 only, no production/real message or keyboard change. No manual deploy.

## v13.69 — store performance phase 1
v13.68 PR #35 merged 49dd024bf88e2fd4ab7d8f04b2853ccf4ff4df6f; CI 45521541365 success. E1 incremental message ordering, metadata-only directory no sort, stable projection references. Measured synthetic 10,000-message append: one comparison; 1,000-room rename: zero sorts; late merge correct. PERF-API-01–05; classic scripts and audit syntax checked; CI pending. No Main/keyboard/production changes; no physical-device latency claim.

## v13.70 — virtual DOM performance phase 2
v13.69 PR #36 merged 9720a7252420ebdea8e645297a17d4a0aa237313; CI 45521974423 success. E1 guarded DOM style/attribute writes, keyed minimal insertion for both virtual modes, avoid fixed-list redundant map and directory revision writes. VIRTUAL-PERF-01–04; browser MutationObserver regression added; six classic scripts and audit syntax checked, CI pending. No Main/keyboard/production changes or real FPS claim.

## v13.71 — sync index phase 3
v13.70 PR #37 merged dc6bfe9eca9040b540746627b11f575c57bcc59f; CI 45522587547 success. E1 shared reverse pointer index removes per-message directory scan for Sync/Cache. Synthetic 10,000 rooms, one lookup per message, ambiguous pointer rejected and replacement correct, classic scripts syntax checked; static audit extended, CI pending. SYNC-PERF-01–04. No Main/keyboard/production changes; no network or device latency claim.

## v13.72 — local performance probe phase 4
v13.71 PR #38 merged 5398d8dcdd15ba7f3166572d7100592782bb2843; CI 45524924977 success. E1 opt-in local bounded interaction frame proxy, navigation timings, optional long tasks and lifecycle controls. MEASURE-PERF-01–05. Seven classic scripts and audit syntax compiled; percentile test passed; CI pending. No real device data, INP claim, production/keyboard change or manual deploy.

## v13.73 — Main owner phase 1
v13.72 PR #39 merged 6af775922629f8bf7857a5d65fce7bf506158a79; CI 45526405781 success. Route local sent/incoming text via Message.create, Contact owns visibility/preview/time/unread/typing. Preserve rich demo samples, scroll and keyboard. MAIN-OWNER-01–04. Classic scripts/audit syntax checked; browser assertions added; CI pending. No live stores or production integration, real send, DB or manual deploy.

## v13.74 — Main data phase 2
v13.73 PR #40 merged 08e2b51d1999b1391345a3086e9808ef63b143c8; CI 45526996155 success. Replace writable Main texts array with MainDataController over MessageStore/ConversationStore; retain fixture metadata and initial preview/order; scoped single-use QA checkpoint. Direct store smoke test and script syntax passed; added static/browser assertions; CI pending. MAIN-DATA-01–04. No live transport, DB, keyboard, production or manual deploy.

## v13.75 — Main business foundation phase 3a
v13.74 PR #41 merged 403c35c594c15f0b50aa5eaf19d68c5ca3c4f508; CI 45527316410 success. BusinessProjectionAPI delegates exact line/total/ledger/format/bank amount to existing Foundation APIs. Direct tests: order 350000, ledger -650000, bank 1000000.8, compact remainder 0.8, line rounding, malformed input. Seven classic scripts and audit syntax checked; browser assertions added; CI pending. MAIN-BIZ-01–04. No real receipts, reconciliation policy change, DB, keyboard or production.

## v13.76 — bill evidence phase 3b
v13.75 PR #42 merged 7af501d0e53361f33c99d47d63dd72cb872baf83; CI 45528009392 success. BillEvidenceAPI shared guard in Main fixture; exact decimal comparison, valid date, manual-only, repeated transition blocked; payment/debt cards derive amounts; register existing notice APIs without live integration. Direct tests and script syntax passed; static/browser checks added, CI pending. BILL-EVIDENCE-01–04. No real receipt, notice, DB, keyboard or production change.

## v13.77 — order notice phase 3c
Shared OrderNoticeProjectionAPI and Main read-only order notice card. Direct tests: draft skipped, delivered two required recipients, partial then complete, repeat/skip/out-of-order blocked. Seven classic scripts and audits syntax checked. Added browser draft projection assertion; CI pending. Based on PR #43 head a7931fcc5281dbabe79ccdc9b701bda385570010; require its CI and merge before release. No real sending or production changes.

## v13.78 — cross-day bank evidence and Vietnamese dates
Extend ParseAPI.billDate; new BankReconcileAPI pure batch candidates, no day cut-off, unique bill↔bank, verified credit, exact amount, date/time ±60 seconds, memo/reference and quality gates; carry missing time to review and bank-only to pending; duplicate/conflict guard. 3-bill fixture lab. Direct tests, static bank contract and syntax passed; browser assertions added, CI pending. BANK-RECON-01–05. No production, ledger, actual customer data, real notifications or keyboard change. Based on v13.77 PR #44 head c4dd49dd547d6ccaa3520b0c23575f477adecfad; require CI and merge before release.

## v13.79 — event-driven bank recheck
v13.78 PR #45 merged bb482b7b9660d5a2391ed286923c97666b2c9dab; CI 45529221225 success. BankRecheckController owns local event state, OCR revision, replay and day watermark, no external effects. Direct smoke and static contract passed; browser lab assertions added; CI pending. BANK-RECHECK-01–05. No real posting, scheduling, bank ingress, DB or keyboard changes.

## v13.80 — durable fixture bank journal
v13.79 PR #46 merged 1ec34abb68700d3d0c47e3bc0c7a7b0830c5b89c; CI 45530554763 success. BankJournalAPI replay, isolated IndexedDB transaction, receipt pair uniqueness, event replay and rollback; same-tab F5 lab. Direct smoke and exact static contract passed; Chromium F5/abort tests added, CI pending. BANK-JOURNAL-01–05. No production ledger, real bank, real message, server or keyboard changes.

## v13.81 — bill review queue
v13.80 PR #47 merged b75a6ab5342af61ad1cdbc237c8159b6673b4760; CI 45532746509 success. Read-only BankReviewQueueAPI projects multiple evidence gaps, actions, first-seen age, current evidence event history and receipt status. No matching/receipt-policy change. Direct smoke and exact static contract passed; browser assertions added, CI pending. BANK-QUEUE-01–05. No production writes, actual customer data or keyboard change.

## v13.82 — manual receipt and late Bank evidence
v13.81 PR #48 merged a3d2bb3920eb3870ba886faa179c45d40a4007f4; CI 45535546559 success. Manual fixture receipt and separate Bank link, immutable amount/time, duplicate guards, OCR amount conflict and Vietnamese labels. Direct smoke and exact static contract passed; Chromium F5 assertions added, CI pending. BANK-MANUAL-01–05. Image dedup/region handling not yet implemented. No real posting, production DB or keyboard change.

## v13.83 — duplicate bill evidence guard
Based on PR #49 head 5b979a7f32a74a7334316d0196a276f8adb06016; CI pending when work started. Exact image/region, reference and conservative near-hash review; immutable metadata; journal blocks duplicate manual/automatic fixture posting, preserves prior receipts. Separate duplicate count and provisional sum. No actual image decoding, region detection, production or keyboard change. BANK-DUP-01–05. CI required before release.

## v13.84 — local image intake and candidate regions
v13.83 PR #50 merged d3152981cf9686d1bbc81bf636a568c544bbdbb7; CI 45536570509 success. Local file decode and original digest, horizontal region proposals, preview, rotation of fingerprint samples, unconfirmed quality warnings. Static raster contract added; Chromium PNG test added, CI pending. BANK-IMAGE-01–05. No real OCR, perspective recovery, real ledger/DB, messages or keyboard changes.

## v13.85 — OCR text field extraction
Based on PR #51 head cbc93a13fc824d98254658360f97c9601e8d2d01; CI pending at work start. Explicit label/next-line extraction with field provenance, date words, exact source-profile amounts, excluded balance and send clock, conflicts/missing/low confidence review. Static contract passed; browser assertions added, CI required. BANK-OCR-01–05. No actual image OCR engine, posting, production DB or keyboard changes.

### v13.85 CI correction
CI 45538091181: static and version gates passed; browser timed out on OCR lab. Root cause: DOMStringMap billOCRStatus maps to data-bill-o-c-r-status, not data-bill-ocr-status. Normalize camelCase billOcrInput/Status/Field; assert actual state with error text. Re-run full CI; do not waive test. No business or keyboard change.

## v13.86 — OCR engine adapter and synthetic demo
Based on corrected v13.85 head 6e34441d1ff4ab78c9d5f6f804b9304ca750e99e; parent CI pending when work started. Explicit Tesseract.js 6.0.1/CDN demo, per-region worker session, OCR text pipeline and cancel guards. Static configuration contract passed; injected worker Chromium test added; actual CDN/recognition quality not validated. BANK-ENGINE-01–05. No real data, production ledger/DB, messages or keyboard change. External assets not bundled; private bills prohibited in demo.

### v13.86 CI correction and corpus-derived cases
CI static/version gates passed; Chromium worker test failed because the API lives in the application closure. Expose only a fixture self-test callback on explicit ocrfixture lab query, not the engine or customer data. Add synthetic cases based on existing private CHAT reason categories, with no private records copied. Test missing time, mismatched account, conflicting amounts, negative amount, fee/balance, invalid date and non-bill; no actual OCR model validation. Re-run CI. No production or keyboard change.

## v13.87 — ten-field OCR contract
Align ten independent fields with existing CHAT structured schema, support printed date and clock variants, add local stored-structured adapter. Static regression added; real image and browser validation pending. Private storage remains private. No production modification, no bill rescan or keyboard change.

## v13.88 — format normalization
Prior v13.87 CI passed and merged. Added narrow shared date formats, grouped account and numeric reference marker normalization. Raw evidence retained. Static regressions, private metadata comparison in read-only session; no private data committed or production changes.

## v13.89 — partial account and bank evidence tiers
v13.88 verified CI and merged. Masked account parsing, separate partial evidence fields, token-boundary memo and candidate proof levels. No relaxed posting policy; partial/missing clock remain review. Static regression executed before commit. No private data/production/keyboard changes.

## v13.90 — memo formatting and attached references
Prior v13.89 CI passed and merged. Added explicit comparison forms, bounded known wrappers and independently printed reference suffix, digit conflict and compact spacing review. Raw bank identity retained. Updated IBFT expectation from contained to exact after explicit prefix separation; retained standalone containment case. Direct regression suite executed; no real bank/customer data, financial write or keyboard change.

## v13.91
Shared account whitespace normalization, raw evidence retained, partial evidence still review. Existing image fixture now imports ParseAPI dependency. Direct regression suite run; no production changes.

## v13.92
Batch fixture matching distinguishes explicit disproven cross-pairs from plausible competitors, preserves excluded candidates and referenceScope. Three equal-amount bill regression, out-of-order credit and replay tests. No production action, real bank namespace adapter or customer data. Parent v13.91 CI in progress at start.

## v13.93
v13.92 CI passed and merged. Add independent Agribank notice parser, exact amount and explicit direction/date/clock, memo classification and balance/overdraft separation. Direct regression tested. No production trust adapter.

## v13.94
v13.93 CI passed and merged. Added diagnostic bank memo envelope parser and comparison. Unknown wrappers preserve raw memo; independent account and clock checks, sender binding, no posting policy change. Static regression executed. No production modification.

## v13.95
v13.94 CI passed and merged. MCC variant grammar, sender-bound generic memo and compact literal evidence. Diagnostic only; unchanged production and fixture eligibility. Direct regression run.

## v13.96
v13.95 CI passed and merged. Add literal residual diagnostics and signed MCC clock delta/day evidence. No new matching eligibility or production changes. Direct regression executed.
