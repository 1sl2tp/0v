# COMPONENT API — danh mục cha/con và hợp đồng sử dụng
Phạm vi 0v v13.44; RULES.md là nguồn quy tắc chính. Không phải package dùng chung đã phát hành. Mỗi owner chỉ chịu trách nhiệm một nhóm hành vi; sửa một chỗ, các con dùng chung được hưởng. Không thay đổi baseline keyboard v13.27.

| Owner | API hiện có / cách dùng | Trách nhiệm | Không được sở hữu | Trạng thái |
|---|---|---|---|---|
| Input | Input.create({type,label,value,placeholder,rows}); Input.bind(node,{type}); Input.isComposing; Input.commitMessage; Input.searchKey | Sáu profile, IME, numeric commit, Unicode | vị trí keyboard, nền/viền riêng | v13.29 đã chuyển các ô mẫu; DOM stub đạt |
| Keyboard | InputController focus/blur + applyViewport/reconcileViewport + early-close | focus lifecycle, rect hiệu lực và root | tự định dạng chữ, transform riêng composer | baseline v13.27 user accepted; khóa |
| Typography | Typography.create({role,text,tag,weight,decoration}); Typography.bind(el,{role,weight,decoration}); CSS --font-ui / --type-* / --line-* / --weight-* | vai trò chữ hiển thị, họ font, size, weight, line-height, kiểu số | editable value, focus, bố cục màn | v13.34: role tĩnh danh bạ/header/chat, make() cho chữ động, Card/Table; computed style PENDING |
| Surface | data-glass, data-input-parent, --paint-* | nền, viền, kính, bóng | tọa độ/chiều cao keyboard | owner hiện hữu; giữ nguyên |
| Button / Icon | Button.create({kind,text,label,className,icon,type,disabled,onClick}); Button.bind(node); Icon.create(name); Icon.replace(button,name) | loại nút native, glyph registry, tên truy cập; controller hiện có đăng ký | hành động nghiệp vụ, focus/blur, viewport | v13.30 đã triển khai; 10 ca DOM stub đạt |
| Popup | Popup.open({type,title,content,description,onDispose,actions}); Popup.close(dialog,result) | vòng đời native modal, profile 1–4, cleanup, rect riêng | root viewport, nhập liệu | v13.31 đã triển khai; 12 ca DOM stub đạt |
| Media | MediaController.grid(count), .layout(grid,ratios), .rotate(source,target,angle) | bố cục ảnh, hướng ảnh | gửi dữ liệu thật | hiện hữu; chưa refactor |
| Card | CardController.create(kind), .header(), .row(), .business() | cấu trúc thẻ | tự tính nghiệp vụ | hiện hữu |
| Table | TableController.create({keys,rows,title,status,total}) | registry cột, căn trục, hiển thị | tự sửa số liệu | hiện hữu |
| Scroll | ScrollController.write(top,reason), .end(reason), .geometry(pinned) | vị trí đọc và cuối hội thoại | root rect, IME | hiện hữu; phụ thuộc KB-LOCK |
| Layout / Composer | Layout.create/bind/frame; Geometry.rect/inside/overlap/centerDelta/gap/squareError/equalInsets/columnCount; CSS grid + composerMode/resizeDraft | bố cục con, token gap/radius, đo rect chỉ đọc | viewport, keyboard, font, paint | v13.34: nhóm thao tác và fields dùng Layout; 22 ca logic/stub; shell/composer khóa, grid chuyên biệt PENDING |
 
## Quy trình phát triển
1. Xác định owner và các biến thể con trước khi thêm component. Gọi API hiện có nếu phù hợp, không tạo bản sao riêng.
2. Chuẩn hóa dần từng owner, chỉ khi có ít nhất một hành vi dùng chung rõ ràng. Input và Button/Icon đã có API. Popup đã có API v13.31. Typography đã có API v13.32. Geometry/Layout đã có API v13.33. Tiếp theo Media, Surface, Card/Table. Không refactor đồng thời Keyboard/Scroll.
3. Mỗi API mới ghi tham số, dữ liệu đầu vào/ra, phạm vi, điều cấm, nguồn tham khảo, test và phiên bản. Kiểm tra runtime thật; không coi source inspection là chứng nhận.
4. Chỉ tách thành package tái sử dụng giữa các repo sau khi có nhu cầu, API ổn định, giấy phép và release gate. Vòng hiện tại chỉ 0v.

## Cổng bắt buộc
Đọc AGENTS.md, RULES.md và danh mục này trước sửa. Ghi mã rule, lý do ngoại lệ, bằng chứng và trạng thái tại CHANGE-CHECK.md theo RULE-GATE-01–06. Không viết lại API cha ở con.

## Độ phủ v13.34
Input chat/search đã bind, input mẫu create; Button tĩnh scan, nút động create; Icon tĩnh scan, registry động copy/share/save/forward; Popup media/preview/form; Surface/Scroll/Keyboard giữ owner; Card/Table dùng chung. Typography role trước paint và dynamic adapter; Button text theo token Button, SVG ảnh chứng từ và debug ngoài scope. Avatar chưa có API riêng. Layout nhóm thao tác/fields, lab; grid danh bạ, shell, media/bill và table giữ owner chuyên biệt. Browser/computed style, F5, thay token, native IME, thiết bị và Pages PENDING.

## v13.35 API proof
?apicheck=1 đo computed style và khai báo owner theo màn hình; không đo glyph font thật hoặc native keyboard. Popup heading/detail có role. CI kiểm tra danh bạ, chat NV, draft, popup, đăng ký button/icon, contact geometry, F5, token chat và Layout lab. Registry icon tĩnh và Layout đặc thù chưa chuyển hoàn toàn; các module chưa đo PENDING. Không tăng cỡ font chuẩn.

## v13.36 Family Registry
FamilyRegistry.classify/mark/resolve/audit; static data-family/data-parent-api/data-family-status; API tạo node tự khai báo, factory phân loại. DECLARED/INHERITED không phải nghiệm thu; PROVISIONAL có owner tạm và study ID; NEEDS-STUDY báo lỗi. Avatar tạm Layout.frame+Typography; Surface/Scroll/Layout đặc thù/Card/Table/Media cần học thêm. Read-only window.familyAudit(), ?apicheck=1. Không đổi keyboard, không nhập dependency.

## v13.37 Parent runtime
Layout.bindProfile/applyProfile for named slots, static bindMainParents uses Layout/TYPOGRAPHY/Button/Icon. Profile selectors replace key contact/title/thread/message/field/avatar declarations. Button text role uses shared typography tokens. Trial type scale 10/16,13/18,14/20,16/22,18/24,18/27; Input unchanged. Legacy specialised layouts and paint remain provisional; no claim of complete CSS ownership. See PARENT-RUNTIME rules and FAMILY-STUDY.

## v13.38 owner runtime
OwnerRuntime resolves actual parent objects. KeyboardController façade delegates locked focus/viewport; Surface.bind sets existing glass profile; Avatar.bind uses Layout + Typography (provisional). Static and factory data-ui-slot contract drives migrated CSS, old class hooks retained for behavior/state and locked sections. window.ownerAudit() checks wrong/missing owner, slot and surface. No font-scale change. Remaining provisional specialized controller profiles and inline legacy still require study/measurement.

## v13.39 Main construction
Main.mount builds all three panels and rail via Layout.slot, Typography.create, Button.create, Input.create, Avatar.create, Surface.bind; Contact.create composes avatar/identity/status; Message.create builds thread text via parents. Removed original static tree and bindMainParents retrofit; preserve DOM IDs and event behavior. Specialized CSS, scroll/controller/Avatar provisional remain. No visual scale changes.

## v13.40 Surface API (independent lab)
Surface.create({variant,layout,children}), Surface.apply(el,variant), Surface.bind(el,glass). Variants plain/subtle/outlined/raised/selected, no mixing glass. Layout owns radius/geometry, Typography owns text. Main unchanged; lab demonstrates parent tokens. See SURFACE-API rules and source notes.

## v13.42 Avatar API
Avatar.create({text,name,src,id,size,shape}), bind, update, initials. Four size profiles, three shapes, image/fallback with fixed geometry, stale event guard. Contact list and header use API. LIST-PROOF checks every ID and token propagation, filter and conversation switch. Avatar lab 7 examples. Native/visual pending.

## v13.43 Media
MediaController.gallery(items), image, tile, openImage, fit; reuse grid/layout/rotate and Popup/Button/Layout/TYPOGRAPHY. Gallery sample calls API. Local preview remains legacy. Zoom inside viewer, cleanup observer; video/gestures/native pending.

## v13.44 Media gestures
MediaController.clampZoom/gesturePair and viewer-local Pointer Events. Pinch focal point, scroll-bounded pan, rebase and cancel, abort cleanup. Buttons share zoom state. No page gesture or keyboard modification. Native verification pending.

## v13.45 systems lab
Media gallery navigation, native video/release and local compress; CardController.panel, TableController density, ScrollController snapshot/restore/append, Motion.play, Responsive.grid, State.toggle/busy, Theme.apply. Scoped labs, no full Main migration. Astryx pinned study manifest and audit. See SYSTEMS-API rules.

Adobe source snapshot: Aria behavior, Stately state, localized numbers. Table density single inherited cell padding token, balanced unchanged. No Adobe runtime.

ReleaseUpdater restored from v13.41 into v13.45, independent polling and safe deferral, validated entry, bounded stale-cache retry, query preservation. Scroll lab uses exact end tolerance 2px, chat unchanged.

## v13.47 Collection
Collection.project, create, setView, visible, toggle, selectVisible, clear, status, selectedIds. Directory uses project; independent 8-item lab uses stable keys and selection. No virtualization or production changes.

Collection.searchKey is case/diacritic-insensitive Vietnamese projection only; Input.searchKey and source content remain unchanged. Hidden row pressed state always derives from model.

## v13.48 Virtualizer
Virtualizer.range(count,offset,height,rowHeight,overscan); mount(viewport,{rowHeight,overscan,renderRow,onRange}) → setItems,jump,status,dispose. Fixed-height bounded DOM, stable anchor and local ScrollController.writeLocal, passive scroll/ResizeObserver. Independent lab uses Collection; no Main/chat migration.

## v13.49 Dynamic Virtualizer
Same mount API with dynamic:true and estimate(item), prefix/dynamicRange, measured keyed size cache, capture/restore before batch, last-row edge follow, width invalidation and disposal. Independent 1000-item lab. No Main/chat migration.

Dynamic Virtualizer correction: pre-measurement model extent owns pinned state, stage clips overflow; last-row resize follows exact model end only if previously pinned. Fixed mode and chat/keyboard unchanged. Regression grow/shrink/away; CI pending.

## v13.50 ReleaseUpdater lifecycle correction
One foreground scheduler, online/pageshow/resume/focus/visibility triggers, idle recheck, per-target retry, explicit read-only actions, dirty protection remains for actual edits. releaseStatus() includes blockers. Vite client.ts and Workbox.ts reviewed; no service-worker runtime introduced. Native PWA pending.

ReleaseUpdater idle retry: after check completes and busy clears, deferred pending with only transient activity schedules exact idle deadline independently of additional interaction; durable blockers retain existing protection.

## v13.51 history/tail
Virtualizer.mount({followOnAppend:false by default}) exposes prepend(rows), append(rows), jumpEnd(); setItems(next,{followEnd:false}) retains existing replacement behavior. Append follows only if opt-in and previously pinned; prepend/away preserve key offset, stable references reuse DOM. Opt-in also follows measured/width changes when pinned. Independent dynamiclab with 20/3 batches, no main chat integration.

## v13.52 MessageStore
MessageStore.create() → apply(batch), get(id), ids(conversationId), latest(conversationId), subscribeMessage/subscribeConversation (return unsubscribe), status(), dispose(). Normalized immutable scalar records, revision and stable sequence, atomic validation, tombstones and changed-key events. MessageStore.label(record) shared projection. No backend/cache/read state or main migration. ?messagelab=1.

## v13.53 ConversationStore
ConversationStore.create(messages) → apply(metadataBatch), get(id), project(id), ids(), subscribeRow(id,fn), subscribeList(fn), status(), dispose(). Global activityOrder and latestMessageId are authoritative metadata; row projection resolves message by ID and checks room, missing is explicit. Separate stable sorted IDs and row notifications; no duplicate message text. Independent ?conversationlab=1; no Main migration.

## v13.54 Foundation
TimeAPI (zone, instant, day, parts, local, range/dayRange/monthRange/weekRange/shift/businessDate); DecimalAPI (canonical/add/subtract/multiply/divide/round/sum/compare, exact bounded string/BigInt); MoneyAPI (line/total/unitCost/allocate/compact); FormatAPI (decimal/date/time/weekday/stamp/contact); ParseAPI (source-specific amount, billDate precision); CalendarAPI.create(entries,{version,source}) returns on(date), not a verified calendar; ScheduleAPI.plan returns cron/window/idempotency key only. Independent ?foundationlab=1. No database, live schedule, lunar calculation, production or Main migration.

## v13.55 Runtime context
TimeAPI.current(instant?,clockSource='device') supplies one immutable Vietnam date snapshot and current-day/week/month/7-day windows. RuntimeContextAPI.derive/read/watch separates selected conversation vs actually visible regions, focus, visibility, device timezone, display mode and online hint; no location or lock inference, no remote presence. contextlab dynamic read-only status; window.runtimeContext() diagnostic, main date formatting delegates to existing Time/Format API. No read receipts, actual Push or server clock adapter.

RuntimeContextAPI.deviceZone normalizes verified Asia/Saigon alias to Asia/Ho_Chi_Minh; deviceZoneRaw preserves Intl result. Other zones unchanged; not a location inference.

## v13.56 SyncController
SyncController.create({messages,conversations,transport,stream,initialCursor=0,pageLimit=100,maxPages=20}) → wake(), setOnline(bool), subscribe(fn), status(), dispose(). Transport.pull({stream,after,limit,signal}) returns {stream,after,events:[{cursor,type,record}],nextCursor,more}. Numeric contiguous authorized stream is proposed contract; realtime wake only. Cursor advances after each applied event; errors preserve prefix, no durable persistence or cross-store atomic page. Mock ?synclab=1 only. No live network, backend, Push or Main migration.

## v13.57 NoticeDeliveryAPI
inspect(row,now) / summarize(rows,now): pure evidence projection for delivered order automatic image intent, keyed command/recipient/channel, stage chain intent/envelope/ticket/stored/attached/queued/accepted, expired ticket review, uncertain send reconcile, independent recipient/channel state. Mock ?noticelab=1. Provider acceptance not read receipt. No actual send, durable outbox, retry worker or DB migration.

## v13.58 NoticeRecoveryAPI
create(notice,now), claim(job,now,token), settle(job,now,token,outcome): pure state transitions, one stage/lease, stale token rejected, evidence success, known-no-effect bounded retry, ambiguous/expired review, permanent/dead. Fixture IndexedDB change(db,id,fn) commits readwrite atomically, isolated synthetic data only. ?recoverylab=1. No actual execution, server durable outbox, permission refresh or provider reconciliation.

## v13.59 CacheController
empty(scope,stream,now), hydrate(record), append(record,page,now), classify(record,scope,stream,now), open/read/commit/clear. Atomic cursor+bounded synthetic journal, CAS page.after, schema/scope/TTL checks, replay existing stores. ?cachelab=1; independent fixture, no real cache or live SyncController migration. Production incremental normalized checkpoint, auth and eviction pending.

## v13.60 CachedSyncSession
CachedSyncSession.open({db,scope,stream,now,transport,initialOnline=false,pageLimit,commitOptions,signal}) restores validated checkpoint before creating existing SyncController with initialCursor and optional persistPage. Adapter commits page/cursor then projects; cache abort keeps memory unchanged; projection failure requires restore. Session exposes source/messages/conversations/sync/durableCursor()/dispose(). Synthetic ?cachedsynclab=1; caller owns DB handle. No live account/server or Main migration. Memory-only SyncController unchanged by default.

## v13.61 DirectoryController
DirectoryController.mount(viewport,{store,onRange,rowHeight=64}) → jump/status/dispose. ConversationStore sorted IDs, stable virtual item refs, updateMounted patch only, fixed Virtualizer anchorMode='directory', setItems(next,{anchorSkip}) retains viewport key + offset or next non-promoted key, top stays zero. Default Virtualizer and chat followEnd unchanged. ?directorylab=1 200 synthetic rooms; no main migration or real selection/native proof.

## v13.62 ReadStateController
create({messages,actorId,conversationId,head,initialReceipt}) → sample(context,{visibleIds,monotonicMs}), status(), proposal(), acknowledge(receipt), setHead(n), reset(), dispose(). Conservative contiguous read proposal, server receipt distinct, unread null if coverage incomplete. 1000ms/750ms synthetic sampling policy; no actual IntersectionObserver or backend receipt, ?readstatelab=1 mock only.

## v13.63 PresenceController
create({actorId,ttlMs=45000}) → register({actorId,sessionId,generation},now), heartbeat({actorId,sessionId,generation,sequence,context},now), leave(...), status(now), candidates(room,now), dispose(). project(context) minimizes RuntimeContext data. Server-time fixture lease, stale generation and sequence rejected; expiry unknown vs explicit disconnect. Candidate is not read/suppression proof. ?presencelab=1 synthetic registry only; actual authorization, rate/heartbeat/transport and multi-device integration pending.

## v13.64 NotificationController
plan({actorId,installationId,message,origin,read,presence,sessionIds,permission,enabled,muted,allowForeground}) chooses none/thread/in-app/push/unavailable. create({actorId,installationId}) → offer(input), settle({id,attempt,surface,sessionId,generation,kind,proof}), get/status/dispose. In-memory intent dedupe; foreground offer not delivery evidence, known no-effect fallback, uncertain review, stable tag. No actual notification, durable ledger, auth or worker. ?notificationlab=1 synthetic only.

## v13.65 DurableAlertController
claim(old,input,{actorId,installationId,owner,token,now}), settle(old,{owner,token,now,outcome}), open/read/acquire/finish, exchange(row,mode,timeout). Shared NotificationController transitions; atomic synthetic IndexedDB lease, duplicate read, expired review, local MessageChannel timeout uncertain. ?durablealertlab=1. No registered Service Worker or actual notifications, server authorization/retention/reconciliation pending.

## v13.66 MultiDeviceController
fixture({actorId,conversationId,stream}) → incoming/send/read/transport/subscribe/status/dispose; connect({actorId,conversationId,stream,server,initialOnline}) → independent messages/conversations/read/sync/submitRead/dispose. SyncController optional onReceipt, incompatible with persistPage until receipt checkpoint supports it. Synthetic ?multidevicelab=1, no real network/account or cross-device Push guarantee.

## v13.67 OfflineCommandController
open(), create({db,scope,send,initialOnline,timeoutMs}) → enqueue(text), rows(), flush(), setOnline(), status(), dispose(). One scoped durable synthetic IndexedDB record; stable command IDs, explicit one-command flush, uncertain/timeout remains queued, generation fence. ?offlinecommandlab=1 uses existing MultiDevice fixture. No full page reload recovery, durable server ledger, cross-tab arbitration, backend, media or production integration.

## v13.68 OfflineCommandController reload
openFixtureServer({db,scope,conversationId,stream}) → send/transport/subscribe/status/dispose. Separate synthetic server journal in IndexedDB, atomic unique command lookup/append, replay through MultiDevice fixture; stable same-tab run in sessionStorage. Reload does not auto-send. No real server, durable real receipts, cross-tab coordination or closed-session recovery guarantee.

## v13.69 Store performance
MessageStore.metrics() → comparisons/appendBatches/prependBatches/mergeBatches. ConversationStore.metrics() → sorts/comparisons/projections. Existing APIs unchanged; projection refs reused while input refs unchanged. Deterministic work counters not millisecond latency. No Main migration or virtualizer changes.

## v13.70 Virtualizer performance
Virtualizer.mount(...).metrics() returns immutable counters: paints, stableFrames, created, removed, moves, attributeWrites, styleWrites. Stable DOM writes guarded; keyed overlapping rows retained. Existing range/anchor/resize/dispose API unchanged. Counters count Virtualizer writes only, not browser paint time or arbitrary consumer DOM changes.

## v13.71 Sync pointer index
ConversationStore.validateMessageScope(record) → boolean; metrics().pointerLookups. Shared by SyncController and CacheController, retains pending pointer conflict rejection. Index updated after validated batch, cleared on dispose. No cursor or storage protocol change.

## v13.72 PerformanceProbe
mount({root,doc,clock}) → report/reset/dispose; summarize(samples) nearest-rank p50/p95/max. ?perfcheck=1 exposes window.crmPerf and a local report panel. Fixed action labels, 100 samples/action, hidden cancellation, optional long task support. Approximate two-frame proxy only, no upload or normal-mode listener attachment. No Main migration.

## v13.73 Main owner phase 1
Contact.visibility(row,{visible,selected}), Contact.update(row,{preview,time,unread,typing}), Contact.typingLabel(label,typing,fallback). Message.create is common plain-text factory for initial/local sent/synthetic incoming messages. Main keeps fixture arrays; store/transport adoption not yet complete. Existing child Layout/Typography/Button owners unchanged.

## v13.74 MainDataController
create(people,seeds) → append/list/latest/checkpoint/restore/status. Local fixture-only normalized text records, original text/date/time metadata and conversation latest pointer. Existing seed projection and directory display remain unchanged; no live transport, cache, receipts or DB. Checkpoints restore isolated QA state only. Main no writable texts array.

## v13.75 BusinessProjectionAPI
amount/display/line/orderTotal/ledgerTotal/signed/noticeAmount. Safe integer fixture adapter or canonical decimal strings; all math delegates DecimalAPI/MoneyAPI. Explicit bank source format; unknown amount remains null; full and compact display separate. No posting, DB or reconciliation ownership. Date labels call FormatAPI.date.

## v13.76 BillEvidenceAPI
inspect({configured,original,reread,bank,posted}) returns matched/missingDate/canManual/canAuto/state/reasons. manual(state) returns posted fixture state or rejects. Exact-match fixture only, no persistent dedup or real posting. NoticeDeliveryAPI and NoticeRecoveryAPI registered as owners; notice labs unchanged.

## v13.77 OrderNoticeProjectionAPI
create({orderId,commandId,orderStatus,customerId,staffId,channel}), inspect(rows,now), advance(rows,recipientId,stage,proof,now,options). Pure fixture projection over NoticeDeliveryAPI, no network or storage. Main order card displays draft skipped; delivery progression tested only in fixture.

## v13.78 BankReconcileAPI / ParseAPI.billDate
match({configured,bills,banks,postedBillIds,postedBankIds}) returns immutable candidate results and unmatched bank evidence; bill/bank IDs independent, exact amount, date/time, normalized memo or reference, ambiguity review. All unresolved bills must be supplied by caller. `eligible-fixture` does not post receipts. Date parser accepts explicit Vietnamese textual dates, numeric dates and supported number words; time null if absent. ?bankreconcilelab=1 provides 3-bill next-day fixture. Production atomic posting and actual bank adapter not implemented.

## v13.79 BankRecheckController
create({configured,postedBillIds,postedBankIds}) returns dispatch({id,type,at,record,revision}), snapshot(), subscribe(), dispose(). In-memory fixture events only, match result via BankReconcileAPI. Monotonic OCR revisions and day watermark, conflict/replay guards. Reconnect/day are explicit simulated events; no actual scheduler or bank transport. ?bankreconcilelab=1 includes OCR reread, reconnect and day controls.

## v13.80 BankJournalAPI
empty(scope,configured), append(journal,entry), replay(journal), open/read/change. Versioned isolated fixture IndexedDB journal with max 200 entries, evidence and receipt replay, scoped unique bill/bank pair, transactional commit before projection. ?bankjournallab=1 exercises pending → matched → posted-demo and F5, duplicate/abort. No server persistence or real ledger.

## v13.81 BankReviewQueueAPI
project(snapshot,{configured,now,receipts}) returns immutable ordered rows, codes/labels/actions, hours, firstSeenAt, OCR revision, relevant evidence history and counts/sum excluding unknown amounts and posted receipts. Snapshot from BankRecheckController or BankJournalAPI replay. Does not infer true cause when bank is unmatched, or authorize receipts. Both bank labs show details. Fixture only.

## v13.82 BankJournalAPI manual evidence
New journal entries manual-receipt({id,billId,amount,operator,reason,at}) and manual-link({id,receiptId,billId,bankId,at}). Existing receipt remains one, bank link adds verification metadata; original amount/time immutable. Review projects manual-await-bank/manual-verified and OCR amount conflict. Same fixture-only journal and UI. No real posting or reversal.

## v13.83 BillDuplicateAPI
validate(bill), inspect(bills) returns peer conflicts Map; digest(Uint8Array) computes source SHA-256 in secure context; regionHash(Uint8Array(72)) computes 64-bit dHash from pre-sampled grayscale region. Controller retains metadata. Reconcile marks conflict review; journal blocks posting; queue exposes duplicateReview and excludes these rows from provisional total. Fixture metadata only; no image decoder, detector or actual OCR ingestion.

## v13.84 BillImageIntakeAPI
decode(file) returns local grayscale raster, original source SHA, bounded preview and dimensions; propose(p,w,h) suggests horizontal split rectangles; inspect(p,w,h,sha,regions,turn) yields unconfirmed normalized region identities, dHash, contrast/detail metrics and warnings. sample/normalized are pure. ?billimagelab=1 local file picker and preview. No OCR, automated bill count, ledger, real messages or network. Experimental heuristics only.

## v13.85 BillOCRFieldAPI
parse(text,{profile,configured,confidence}) returns immutable record, evidence (line provenance), unknown, ignored and issues; reuse ParseAPI for money/calendar. Explicit labels and next line only; quality review, canPost false. ?billocrlab=1 simulates OCR text input, not image recognition. No dispatch into financial journal.

## v13.86 BillOCREngineAPI
create({factory,profile}) returns run([{image,region}]), close(); sequential worker recognition, per-region BillOCRFieldAPI parse, review-only result. crop(canvas,region) produces rotated region canvas. loadDemo/demoFactory configure optional Tesseract.js CDN runtime; only synthetic images, no customer data. Real engine not bundled or validated; production self-hosting and corpus validation remain separate.

## v13.87 ten-field OCR
BillOCRFieldAPI.parse now exposes ten fields, including sendingBank, receivingBank and trace. fromStored accepts the CHAT bill_fields_v1 schema and adapts printed fields into explicit local parser input. Output review-only. No storage access, no automatic repair of historic data, no posting.

## v13.88 format normalization
Shared ParseAPI.billDate accepts Vietnamese abbreviated numeric month tokens with explicit year. BillOCRFieldAPI accepts digit-only groups with spaces, and numeric reference prefix #; raw line evidence retained. Review-only, no missing digit inference.

## v13.89 evidence tiers
BillOCRFieldAPI.parse returns accountPartial (visible prefix/suffix only, no reconstruction); BankReconcileAPI.destination and memoProof distinguish evidence levels. Explicit accountLast5/accountPrefix input is carried by recheck; candidate.reviewEvidence records proof types. Partial or date-only remains review. No production action.

## v13.90 memo evidence
BankReconcileAPI.memoDetails(billMemo,bankMemo,{billReference,bankReference}) returns normalized comparison forms, proof kind, embedded reference, digit conflict and known markers. Compact match is review-only. Original memo retained; no arbitrary code stripping.

## v13.91
ParseAPI.accountDigits(raw,{min=6,max=32}) returns digit string or null; sameAccount compares valid full identifiers. OCR, bank, duplicate, manual fixture and journal share this owner.

## v13.92
BankReconcileAPI.match accepts optional referenceScope='shared-transfer' only as explicit verified fixture metadata; strong distinct references can exclude cross-pairs. Results expose excludedCandidates separately. Recheck preserves scope. No automatic namespace inference or production authorization.

## v13.93
AgribankNoticeAPI.parse(raw,metadata) returns literal evidence, memo classification, exact VND and separate balance/interest, conflict flags. Always unverified, no shared reference scope or posting.

## v13.94
BankMemoEnvelopeAPI.inspect(raw,{account,transactionAt}) separates technical metadata and principal; compare(billMemo,bankMemo,context) returns diagnostic literal and principal proof types, sender binding and conflict flags. Always canPost=false; not wired to ledger or existing reconcile eligibility.

## v13.95
BankMemoEnvelopeAPI supports observed MCC prefix and short sourceIdentifier; compare adds senderMemoProof and compactLiteralProof as diagnostic flags, independent of existing eligibility. No authorization.

## v13.96
BankMemoEnvelopeAPI.diagnoseLiteral(a,b) yields diagnostic type, shared prefix/suffix and gap lengths, digit conflict, reviewOnly=true. compare exposes literalDiagnostic. MCC metadata adds signed clockDeltaSeconds and clockSameDay. No eligibility change.

## v13.97
BankReconcileAPI candidate missingClockProof and result.verification distinguish strict date/reference/memo review from posting. BankReviewQueueAPI exposes verification and missingClockVerified count, with separately printed Bank clock. Recheck retains ownTransfer flag. No eligibility relaxation.

## v13.98
BankReconcileAPI.billClock(record) returns present, missing, invalid, conflict or unverified-date. Missing/invalid/conflict requires review even with zero Bank candidates. Queue projects clockReviewRequired and a draft verification request, never sends it.

### BANK-RELATED (v13.98 revision 2)
BankReviewQueueAPI.project exposes immutable relatedCandidates (bankId, tier, bankPrintedTime, transactionDate, receivedDate, late, competing, memoProof, canPost:false) and possiblyRelated count; derived only, no receipt authority. Existing BankReconcileAPI computes evidence; no new owner.

## v13.99 BANK-FIELDS
Each relatedCandidates entry has immutable fields [{field,billValue,bankValue,proof}] derived by BankReconcileAPI; amount/date canonical, raw account/name/memo/reference, separate bank clock. No changes to receipt eligibility. CardController.business presents candidate-specific evidence.

## v13.100 BANK-COMPETE
BankReviewQueueAPI.project adds immutable competitionGroups with billIds, bankIds, billCount, bankRecordCount, billFaceTotal, relatedBankRecordTotal, sharedBankIds, canPost:false. Connected components use existing candidate graph; Bank record ID is not financial identity; no posting or new matching owner.

## v13.101 BANK-REPLAY
BankRecheckController carries sourcePackage/rawNotice. BankReconcileAPI returns immutable replayGroups (bankIds, recordCount, noticeAmount, hasPosted, canPost:false), derived from exact official notice + validated fields. Unposted aliases stay competing; posted exact aliases excluded. Queue shows replayGroups and suppresses misleading related Bank sum. No production adapter or financial authorization.

## v13.102 BANK-CROP
BillImageIntakeAPI.inspect adds cropHashes (null or comma-separated unique up to 3 inset dHashes). BillDuplicateAPI.validate/fields preserves this bounded immutable evidence; inspect emits possible-cropped-image-duplicate only with independent matching fields. Existing near-image hint suppressed on known distinct clock. No receipt or auto-merge authority.

## v13.103 BANK-REGION
BillImageIntakeAPI.propose(p,w,h,mode='auto') supports row/column/grid whitespace proposals (<=4). regionPlan(rows,selectedKeys) returns immutable sourceCount, regionCount, selectedCount, overlapCount and per-region stable key/selected/overlap/canRead/canPost=false. canRead means selected scope only, no actual OCR execution. Existing image lab resets selection on geometry/rotation changes.

## v13.104 BANK-REGION-OCR
BillOCREngineAPI.createRegionBatch({factory,profile}) -> run({rows,selected,makeImage}), close(). Uses existing regionPlan and sequential run; failed region returned with state:error and null parsed data, failed worker closed; next region independent. Stable regionKey, immutable review results, canPost:false. Sample-only OCR lab; no ledger adapter.

## v13.105 BANK-FIELD-REVISION
BillOCRFieldAPI.createFieldReview({regionKey,text,profile,confidence}) -> snapshot(), reread({regionKey,field,text,confidence,expectedRevision}), confirm({regionKey,field,expectedRevision,source:'initial'|'proposal'}). Immutable field rows and revision history, proposal independent of current value, verified lock; no automatic authorization. Text-lab only, no physical field crop or real OCR call.

## v13.106 BANK-FIELD-GEOMETRY
BillOCRFieldAPI.fieldGeometry({region,text,parsed,blocks,width,height}) -> aligned, regionKey, rotation, dimensions, immutable fields [{field,rect,state,lines?}], canPost:false. Full ordered text alignment required; line bounds are local to rotated OCR crop. BillOCREngineAPI.run requests blocks and returns geometry when dimensions exist; fieldCropPlan({region,geometry,field,manualRect}) validates scope; cropField(canvas,plan) copies bounded rectangle. No automatic field reread or manual picker yet.

## v13.107 BANK-FIELD-VARIANTS
BillOCRFieldAPI.compareFieldAttempts({regionKey,field,attempts,profile}) returns immutable original/contrast/scale2 attempts, state agreed-review/conflict/partial-review/unreadable, proposedValue only on agreement, requiresVerification=true, canPost=false. BillOCREngineAPI.contrastPixels/fieldVariants and createFieldReread({factory,profile}).run({decoded,region,geometry,field,manualRect}) use bounded same-source crop and sequential recognition. Sample-only UI; no auto confirm or field revision mutation.

## v13.108 BANK-LITERAL
BillOCRFieldAPI.literalDiagnostics(field,raw,profile,{valid}) returns immutable review-only glyph/presentation diagnostics at code-point positions; literalDifferences(a,b) returns literal conflict descriptions without repair. parse.evidence retains invalid raw/labelLine/diagnostics; compareFieldAttempts.differences retains per-method raw pair and canonicalEqual. Existing parser and posting rules unchanged.

## v13.109 BANK-MEMO-CODE
BankReconcileAPI.memoPresentation(a,b) -> immutable kind, billCodes, bankCodes, codeEqual, codeReview, reviewOnly. memoDetails.presentation applies after known wrapper/reference processing; reviewEvidence.memoPresentation exposes diagnostic. Unequal numeric-bearing tokens for otherwise matching memo adds memo-code-review; strong reference boundary rejects joined compound tokens. Existing review queue and posting guards retained; no production adapter.

## v13.110 BANK-MEMO-SPAN
BankMemoEnvelopeAPI.diagnoseLiteral adds alignment {state,segments:[{type,bill,bank}],reviewOnly}. Unique normalized compact match/containment/gap/letter spans only; ambiguous positions return no segments. BankReconcileAPI.reviewEvidence.memoDiagnostic and BankReviewQueueAPI.relatedCandidates.memoDiagnostic expose per-candidate diagnostics. Residual suggestions tightened for code conflicts and ambiguous alignment; no new posting eligibility.

## v13.111 BANK-PAYER
BillOCRFieldAPI record now eleven fields (senderName explicit, name remains recipient); fromStored adapts sender_name. BankReconcileAPI.payerRoles(bill,bank) returns immutable role evidence and possible-third-party/same-name-unverified; canAssignCustomer=false, canPost=false. Sender mismatch and customer-scoped allocation review add reasons. BankRecheckController carries senderName/customerId/customerName, locks customer context across OCR revisions. No actual customer allocation adapter.

## v13.112 BANK-ALLOC
BankJournalAPI.planAllocations({journal,obligations,plans}) replays fixture journal, validates unique linked bank receipts, explicit order/customer/revision, exact amounts and cumulative outstanding. Returns immutable plans, obligations with remaining amounts, received/allocated/unallocated, receiptCount/bankRecordCount, canPost=false. No persistence or real allocation. ?bankallocationlab=1 fixture input UI.
