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
