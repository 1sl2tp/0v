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

## v13.113 BANK-CYCLE
BankJournalAPI.planCycles({journal,obligations,plans,cycles}) calls planAllocations; cycles require customerId,cycleId,revision,complete,orderIds. Returns immutable per-order contributions and per-cycle exact opening/allocated/remaining, receipt IDs/counts, status; global unallocated separate. canPost=false, canCloseCycle=false, caller completeness only. Existing ?bankallocationlab=1 extends two receipt example.

## v13.113 correction — BANK-ROLLING
BankJournalAPI.planRollingDebt({journal,customer,openingAt,asOf,purchases,receiptIds}) is primary rolling debt fixture projection; signed balance = opening minus delivered purchases plus explicitly assigned replayed receipts. Exact debt/credit, per-event balance, projected cycle transitions, separate bank-backed and unlinked manual totals. No order allocation required; planAllocations/planCycles optional only. No actual authorization, persistence, global assignment or cycle closure.

## v13.114 BANK-ROLLING-BATCH
BankJournalAPI.planRollingBatch({journal,openingAt,asOf,customers:[{customer,purchases}],assignments:[{customerId,receiptId,expectedRevision}]}) reuses rollingProjection after one replay. Reject repeated receipt or known Bank alias across customers and repeated purchase IDs. Exact separate debt, credit, bankReceived, manualUnlinked and unassigned receipt totals. Read-only fixture, no persistent allocation lock. Manual linkage after asOf does not count as Bank-backed at earlier cutoff.

## v13.115 BANK-ROLLING-PERSIST
BankJournalAPI.persistentEmpty/persistentProof/applyPersistent and openPersistent/readPersistent/changePersistent implement one account-keyed synthetic fixture journal and immutable receipt ownership in one IndexedDB transaction. Retry exact entries and same owner is idempotent; conflicts reject; existing independent journals not migrated. Browser-only hook ?bankpersistlab=1. canPost=false; canCloseCycle=false. No production adapter or cross-device guarantee.

## v13.116 BANK-ROLLING-DB
Standalone SQL fixture at fixtures/bank-db/schema.sql; post_receipt(...) returns created/replay, link_manual(...) returns linked/replay. Account-scoped unique receipt/bill/Bank key; trusted inputs only, no browser RPC, no production migration, no real ledger or balance updates. CI test.sh uses disposable local PostgreSQL 16. Actual Bank canonical key resolver and authorization are prerequisite to integration.

## v13.117 BANK-IDENTITY
BankTransactionIdentityAPI.resolve({configured,banks,attestations}) groups separate verified fixture statement provider IDs; inspectNotice revalidates raw Agribank evidence and explicit clock. prepare({configured,bill,banks,attestations,bankId}) produces single-candidate diagnostic only, canPost=false. Existing bank replay, full-batch competition, DB keys and ledger integration remain separate. No real authority adapter.

## v13.118 BANK-IDENTITY-BATCH
BankIdentityBatchAPI.plan({configured,bills,banks,attestations,assignments,priorReceipts,asOf,complete}) produces conservative whole-batch fixture proposals, grouping notice aliases by canonical key and blocking competing candidates. Prior manual links preserve postedAt and contribute zero newCredit; exact per-customer totals. No authoritative ledger snapshot, real posting or persistent SQL integration. canPost=false and canCloseCycle=false.

## v13.119 BANK-ACCUMULATION
BankAccumulationAPI.empty(configured,openedAt), append(journal,event), replay(journal,{asOf}) manage bounded synthetic event history and compute BankIdentityBatchAPI proposals. New evidence invalidates completeness; scope event requires expectedRevision. OCR version, bank receipt time, manual postedAt and verifiedAt separate. Caller snapshots only, no persistent adapter or actual posting, canPost=false.

## v13.120 BANK-BACKLOG
BankBacklogAPI.project(journal,{asOf}) derives immutable bill/customer/Bank queues from BankAccumulationAPI. Exposes ageHours, daysWaiting, clockReviewRequired, open and manual counts, resolved no-bill Bank amount and separate new-credit/manual-link plans. No duplicate aliases counted as multiple resolved transactions; unresolved notices excluded from no-bill total. No UI, durable storage, sending or posting adapter.

## v13.121 BANK-BACKLOG-UI
renderBankBacklogLab(panel) in Bill module or ?bankbackloglab=1. Uses BankBacklogAPI.project and BankAccumulationAPI only with fixed synthetic sample, filter buttons, status, expandable detail and simulated manual verification; reset is local. No transport or storage; new credit remains zero. Uses existing Card, Button, Layout and Typography APIs.

## v13.122 BANK-FIELD-COMPARE
BankFieldCompareAPI.compare({configured,bill,bank,identity}) gives per-field literal values, diagnostic status/reason and clockReviewRequired; project(journal,{billId,bankId,asOf}) limits selection to candidate or linked notices. UI expands in backlog detail with explicit notice selection when multiple. No correction, identity assignment, message or receipt write. canPost=false and canSend=false.

## v13.123 BANK-OCR-CORRECTION
BankOCRCorrectionAPI.propose/apply(journal,command) uses existing field review API to validate one field from synthetic image-region text; replay validates ocr-verified event and retains old/new, reason, operator and raw evidence. Backlog sample previews and confirms clock from fixed synthetic source. No real image rerun, production authorization or posting.

## v13.124 BILL-SINGLE-IMAGE
BillImageIntakeAPI.single(p,w,h,sha,{kind,crop,rotation}) returns exactly one review-only region, source kind saved/photo/journal. Engine accepts only one selected region and manual crop coordinates; legacy partition helpers retained for regression, no collage UI. No automatic background segmentation or actual customer image OCR validation.

## v13.125 BILL-RECOGNITION
BillRecognitionAPI.classify(text,{configured,profile}) routes text to bill-candidate/account-review/account-conflict/not-recognized. Configured 13-digit receiver, full or matching 4–6 digit suffix with context, separate explicit and unlabelled evidence. Uses existing parser for context; does not authorize payment or change existing Bank match policy. Text lab uses synthetic receiver.

## v13.126–v13.133 — bill OCR recognition and field geometry
BillRecognitionAPI: fixed receiver account/name, adjacent unlabelled pair, wrapped digit review. BillOCRFieldAPI: scoped field reads, unlabelled suggestions, value-only word geometry. BillOCREngineAPI: one image source plan, crop/contrast, raw lines, typed read on exact value scope. All remain review-only and cannot post. Typed name uses unaccented Latin; memo and date words unrestricted. Real image acceptance and production integration remain pending.

## v13.134 — integration acceptance matrix
| Scope | Evidence / remaining work |
|---|---|
| UI parent components | Existing contracts and browser fixtures; actual device matrix incomplete |
| OCR text → recognition → Bank parse → match | Integrated synthetic text audit; verified notice explicitly simulated only |
| Image pixels → OCR | Real customer corpus pending; no private images copied |
| OCR → actual ledger | Adapter, authorization and authoritative identity evidence pending; no production writing |
| Duplicate, late notice, missing time | Existing fixtures plus cross-layer regression; actual ledger replay pending |
| Release | CI / main merge distinct from Pages and device acceptance |
| Device and user acceptance | E3–E5 not certified |

## v13.135 — native pixel stress and independent typed evidence
See [BILL-OCR-PIXEL-STRESS.md](BILL-OCR-PIXEL-STRESS.md). BillOCREngineAPI.combineTypedEvidence preserves baseline raw evidence; typed mismatch invalidates proposal, unavailable typed result downgrades agreement; no automatic override. Native test 31/35 known crops; customer and browser OCR pending.

## v13.136 — blur rescue
BillOCREngineAPI.sharpenPixels/rescueImage/rescueNeeded/attachRescue add bounded optional extra typed read without changing state or proposal. Exact value region only. Native benchmark and browser kernel are distinct; browser actual OCR accuracy pending. See [BILL-OCR-BLUR-RESCUE.md](BILL-OCR-BLUR-RESCUE.md).

## v13.137 — quality triage
BillOCREngineAPI.qualityPixels and qualityAdvice add uncalibrated pixel hints and review routing. No change to baseline OCR attempts or rescue gate. Only known value scope with unreadable critical data produces a request draft; never send/post. Corpus calibration, real device and production integration pending.

## v13.138 — composer attachments
Role font tokens retained; DraftMedia per-room local preview, removal, image-only local send. 94% width when attached; no transport or durable storage. Native device acceptance pending.

## v13.139 — composer media state
DraftMedia.begin/end/pending/busy isolate pending decode and protect local send/release. CSS consumes visible height without modifying viewport owner. Same-room rail scroll retained. Browser short-height and room-switch regression added; actual native keyboard acceptance pending.

## v13.140 — composer geometry
Input child inset 8px shared by text and attachment rail. Expanded radius 24px, single capsule unchanged. Surface retains paint and border; KeyboardController and resizeDraft unchanged. Sources: pinned Astryx TextInput/Stack; https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/box-sizing and https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/border-radius. Native acceptance pending.

## v13.141 — keyboard accessory
Keyboard family hosts a local accessory in the Input composer. Anchored gap 8px; focus-preserving pointer interaction; room-scoped selection; only explicit action invokes native file input. Native picker/camera routing remains browser-dependent. Sources: Astryx TextInput/Stack, https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/input/file, https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/capture, https://developer.mozilla.org/en-US/docs/Web/API/Pointer_events. No keyboard viewport writer.

## v13.142 — native picker handoff
Keyboard > composer frame > Input > accessory/file anchor. Native picker is external to DOM; location not controllable by CSS. Handoff suppresses only predictive blur recovery while picker is outstanding. No extra viewport writer or forced focus. Sources: pinned Astryx TextInput/Stack; https://github.com/adobe/react-spectrum/issues/9858 ; https://github.com/adobe/react-spectrum/issues/9172 ; https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement/cancel_event ; https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/input/file. Native acceptance required.

## v13.143 — keyboard frame accessory
Keyboard frame > accessory + composer siblings. Existing frame observer owns measured reserve. Focus synchronous; iOS opening transition settled read-only (120ms stable, 600ms fallback). No frozen viewport, no asynchronous refocus. Sources: pinned Astryx TextInput/Stack; https://github.com/adobe/react-spectrum/blob/main/packages/react-aria/src/utils/runAfterKeyboard.ts ; https://bugs.webkit.org/show_bug.cgi?id=195884. Native acceptance pending.

Candidate repair: preserve accessory pointer activation through blur; invoke native showPicker synchronously, unsupported fallback click. No change to frame reserve/viewport owner.

Candidate repair 2: actual native file input overlays each visible action row; no showPicker or programmatic click, native default activation, handoff before focus loss, shared room-owned decode. Prior + anchor superseded by actual selected action. Browser and physical iPhone acceptance pending.

Candidate repair 3: accessory declares input interaction boundary for the existing capture handler. Native file hit layer above non-interactive text/icon, min row 44px and constrained grid. Browser diagnostic logs actual rect and hit target; no changes to viewport code.

Test isolation: real accessory interaction must use normal URL. Opt-in apiProofPanel is a deliberate interactive diagnostic overlay, not normal UI. Keep separate API diagnostic coverage and actual hit/chooser assertions; no force click.

## v13.144 — exclusive native picker
CRM menu paints only before native activation; trusted click marks native presentation and removes menu paint/hit/tab stops while retaining frame size. Native WebKit owns its action sheet and anchor; no claim of CSS control. Cancel/change close menu without forced focus. Sources: https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/ios/forms/WKFileUploadPanel.mm and https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement/cancel_event . Native acceptance pending.

## v13.145 — direct native picker
Keyboard frame > composer > one native file control sharing + grid cell. No accessory menu or additional reserve. Native default activation exposes OS-supported choices. Keep room handoff and ordinary keyboard baseline. Source: https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/ios/forms/WKFileUploadPanel.mm (native action sheet, elementRect). Physical iPhone validation required.

## v13.146 — picker anchor geometry
Input/plus same 44×44 box; relative anchor follows composer/frame and visual viewport. `?pickerprobe=1` records activation and later rectangle drift, focus and viewport state locally; no geometry writes. Native popup rectangle is unavailable in DOM. Source: https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/ios/forms/WKFileUploadPanel.mm ; native implementation may differ by installed iOS. Native acceptance pending.

## v13.147 — Input-owned plus
Composer > attachment menu and action rows. Menu follows parent via CSS only, 8px above top. Native picker is separate after explicit action; local menu unpainted during handoff. No keyboard-state listener or viewport writer. iOS may require native source choice after selecting image; this is a platform tradeoff for controlled local menu geometry. Physical acceptance pending.

## v13.148 — one native chooser only
Revert v13.147 custom attachment menu. One direct native input in + cell; no intermediate source choice, no separate camera control. User prioritizes single chooser. Native positioning/dismissal cannot be guaranteed by web UI; do not reintroduce a second menu as a workaround. Keep read-only anchor probe and protected keyboard geometry.

## v13.149 — Input three-action trial
Local menu only: Thư viện ảnh / Chụp ảnh / Chọn tệp, relative to Input top by 8px. Native default file inputs, local menu hidden visually during handoff. File choice currently supports image attachments only; unsupported formats reported. Native source choices may still appear. Existing keyboard lifecycle signal may dismiss local menu, no geometry writer. Native trial not acceptance.

Candidate repair 1: defer local menu hide until after native default action, with epoch guard; actual hit target and event trace recorded by browser test. No geometry or keyboard writer. Native chooser timeout root cause not yet confirmed.

## v13.150 — Native touch handoff
User reports all three attachment actions fail on iPhone after v13.149 CI passed. Shared pointerup cleanup used zero-delay and may hide the native input before delayed compatibility click. Candidate: keep the real input unchanged, remove its mousedown cancellation, use touch-action manipulation and an epoch-guarded 1000ms abandoned-press cleanup only (never delay actual picker activation). No geometry writer or keyboard API change. Add real Chromium touch taps for all three actions, both focus states; native iPhone still required. WebKit WKFileUploadPanel.mm and WebKit bug 328902 support preserving direct user activation; they do not prove the reported root cause. File attachment still image-only.

## v13.151 — one native source chooser
User confirms duplicate source selection still occurs in v13.150. Revoke trial rules 174–175 and reinstate 173 single native chooser: one real input in + cell, accept=image/* multiple, no capture, no CRM source menu. Restore read-only anchor probe. Preserve direct native activation and do not cancel file-input mousedown. Browser tests verify no intermediate menu, one input, direct real chooser from mouse/touch, both focus states, cancel, image selection and anchor drift. WebKit WKFileUploadPanel.mm https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/ios/forms/WKFileUploadPanel.mm owns native source actions; https://stackoverflow.com/questions/64458887/html5-select-photos-directly-from-photo-library-on-safari-ios documents inability to bypass source menu reliably. Native menu position and dismissal remain OS-controlled; not accepted on iPhone. Only image attachments supported. No geometry writer, bill or production data change.

v13.151 CI repair 1: run 45595212167 failed before real chooser at hit assertion, 44×44 px and dx/dy=0 but hit=false. Candidate explicitly makes the decorative + and descendants noninteractive, layers native input above its visual face, and uses touch-action manipulation. No position or size changes. Test waits for actual hit after viewport reconciliation and logs elementsFromPoint stack and focus/touch context on failure; real chooser assertion remains required. Root cause of the intercepted hit not yet confirmed. DB 45595212121 passed. No keyboard, Surface, scrolling or bill changes.

## v13.152 — iOS keyboard-closed preflight
User screenshot v13.151 shows native Safari source menu at stale keyboard-open anchor after keyboard closure. WebKit WKFileUploadPanel.mm repositionContextMenuIfNeeded returns early on keyboard dismissal unless previously repositioned; menu bounds are not exposed. Source https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/ios/forms/WKFileUploadPanel.mm . Candidate prevention (not native dismissal): iOS only, block native default activation while existing keyboard state is open/occluding; first tap uses existing InputController.blur, second fresh tap when closed opens sole native picker. Closed keyboard remains one tap; no synthetic click, no extra source menu, no coordinate writer, no change to protected keyboard code. Explicit exception to single-tap rule 173 only when keyboard open/closing; tradeoff requires user acceptance. Tests use Chromium touch with iPhone UA for preflight, real chooser, preserved draft, and one tap with closed keyboard; not native iOS proof. No bill or production changes.

## v13.153 — source button focus ownership
User clarifies Input/Keyboard already correct; media is a child action only and should open above composer, one tap, no forced keyboard closure. Supersede v13.152 preflight rule 177. One + button calls a single co-located native file input synchronously (showPicker where supported, click fallback only if method absent). Preserve existing draft focus on button press; never force blur or focus. WebKit WKFileUploadPanel.mm main lines 2937–2948 and 3371–3378: native anchor uses input rectangle and may keep first responder if editable focused. https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/ios/forms/WKFileUploadPanel.mm . Native OS position/dismissal is still not controllable from DOM, and upstream behavior may differ on installed iOS. No forced coordinates, no custom menu, no additional tap. Browser tests use real button clicks/taps, one chooser, draft focus, co-located anchor and ordinary input regressions. Native acceptance pending; no Keyboard API or business logic changes.

Source study: [MEDIA-ATTACHMENT-SOURCES.md](MEDIA-ATTACHMENT-SOURCES.md). Single source button, native picker, draft media state, keyboard geometry remain separate owners.

## v13.154 — attachment focus transaction
User requests native media retain keyboard when initially open. Candidate only in attachment press: capture previous editable focus and selection, conditionally restore original draft synchronously before the one native request if focus moved to +/file/body, same conversation; never steal another input or refocus after chooser. No global focus suppression, no geometry changes, no keyboard forced open if originally closed. Clear pending press on unrelated pointer, cancellation and keyboard activation. Adobe preventFocus (utils.ts blob 70dcb6f5d52688bb68b6a18a5a0b78d0bd8e74e) and focusWithoutScrolling (460fab39f47de97af0981a2dec8f0cedce9f7e0a) motivate narrow restore; WebKit WKFileUploadPanel.mm blob eeb45bd4a7ff396311cf973ee7796c6593315386 lines 786–805 keep software-keyboard first responder, 837–868 may skip menu reposition. No claim actual native focus loss proven. Optional pickerprobe=1 records press-start, focus transitions, before-focus-check, before/after-native-request; no typed content in trace. Add real chooser test with injected focus transfer, mouse/touch, selection retained, existing normal/closed keyboard tests. This is controlled Chromium fault injection, not iOS acceptance. No production data, bill or protected keyboard code changes.

## v13.155 — native click then existing focus
User reports v13.154 still same on real iPhone; do not claim Chromium verifies native UI. New evidence: WebKit bug 241320 (https://bugs.webkit.org/show_bug.cgi?id=241320), actual regression fixture https://github.com/WebKit/WebKit/blob/main/LayoutTests/fast/forms/ios/show-file-upload-context-menu-above-keyboard.html blob 2c1bc77b67839ba71054cd7ef8f405975869d6fa explicitly calls fileInput.click() THEN textInput.focus() synchronously and tests native menu above keyboard, keyboard stays open during/after dismissal. Adobe FileTrigger.tsx blob 7564a8a500ed479862e03b7445d897b7607c6a1f uses input.click() and stops propagation. v13.155 adopts this ordering for the same press only if draft was already focused, retains co-located anchor (unlike zero-sized WebKit fixture), preserves selection, no second chooser, no timer, no keyboard geometry change. Closed keyboard stays closed, keyboard accessibility remains. Diagnostic records post-request focus. Update injected focus transfer test to verify ordering and one chooser; native iOS still pending. No bill, DB, production or protected Keyboard code changes.

## v13.156 — restore v13.27 Input ownership
User reports v13.155 reintroduced old Input falling bug. Reopened immutable user-accepted v13.27 blob 2b350f1522a6f11f955948d969fa0d5f11a3de1d. classifyKeyboard, applyViewport and close scheduling are byte-identical; focus owner differs by one media-specific pickerOwner===null guard; resizeDraft differs only in approved media presence/send state. Restore complete focus owner range byte-for-byte from v13.27; tighten audit-design.cjs to no longer normalize away the media guard. Remove cancelEarlyClose from beginPickerHandoff and remove conditional forced refocus trial v13.154/155, including attachment press global tracking. Keep single co-located native file input, synchronous input.click (Adobe FileTrigger and v13.27), local default prevention only for previously focused draft, no forced blur/focus, no second menu. Retain draft media preview/send behavior and release update blocker. Native menu keyboard persistence remains unresolved; prioritize stable Input closure. Add controlled delayed visualViewport resize + pending picker regression; no native iOS proof. No changes to baseline snapshot, root geometry, bill, DB or production.

## v13.157 — directory search state
Directory search review: existing showPeople hides all rows on no results but gives no feedback; Escape always collapses and focuses hidden desktop toggle. Adopt Adobe pinned useSearchField.ts (7743784aa065cd42bf0d144ddc5dd5e03e0e651f blob 6278919130f3c2ce6bf871cf32429a4c700991dc: Escape clears nonempty value, no action if empty) and Astryx pinned Button.tsx (d63c24970f9ab1dc5e3024a7123ec7edee2a0f11 blob f87eb657180a0de978fb3ba1c59c24909a9cc63d: stable button DOM and focus). Add persistent polite status in existing list; no occupied padding when results exist; distinguish no query results from no group contacts. Escape first clears query keeping existing focus, second collapses only visible mobile disclosure; desktop search remains visible and focused. No change to global Input/Keyboard/Media or data source. Add browser cases widths 320/390/1024 for no-match, clear, focus and mobile disclosure. User requested other issues; selected directory search based on actual source review, native validation pending. v13.156 merged; both CI 45605200490/45605200403 successful, native acceptance pending.

## v13.158 — unchanged conversation reopen
Reopening the same contact currently rebuilds all chat messages, sample bill cards, module controls and work panel even with unchanged state. Conservative same-room fast path: only skip full render when current room matches previously rendered room, immutable ConversationStore record reference is unchanged, and Vietnam business date unchanged. Different room, any append/revision, or day change retains full render. No persistent DOM cache across rooms, no message list reordering, no changes to scroll/keyboard or native picker. Existing navigate/scroll restore and contact update still run; same draft not reassigned. Reselect createSelectorCreator.ts blob 30b4a4b2d7bc43f52e43ce746998f6562864b92d motivates reference-based invalidation, Astryx pinned Button.tsx f87eb657180a0de978fb3ba1c59c24909a9cc63d stable DOM/focus, Adobe pinned useSearchField.ts 6278919130f3c2ce6bf871cf32429a4c700991dc keeps search behavior isolated. Test DOM identity, draft, hidden incoming invalidation and switching; no latency or real device claim. User asked next problem; choose same-room navigation, not broad optimization. v13.157 CI 45605877202/45605877415 passed, merged. No production data or bill changes.

## v13.159 — incoming scroll policy
KB-05/SC-16 review: receiveDemo unconditionally restores previous scrollTop even when reader was idle at tail; long incoming message can push the reader out of tail and show new-count. Snapshot existing nearBottom (48px), navigationPending, touchingMessages and scrollingUntil before append. Follow only idle tail via ScrollController.end; away restores previous top via ScrollController.write; active touch/navigation avoids extra position writes. Count set before scroll so syncJump clears at tail; other conversation stays isolated. No changes to protected Keyboard/Surface/resizeDraft or scroll controller itself. Sources: pinned Astryx Stack.tsx c56d72759ad2f6f86102228e22c3123530b32894 separates scroll container sizing, TanStack Virtual index.ts 4bd3531db01d98838db8bea9cfd8b5c62568b4c7 explicitly implements end anchor and followOnAppend. Adobe pinned useSearchField.ts 6278919130f3c2ce6bf871cf32429a4c700991dc consulted only for preserving unrelated input state; attempted old Virtualizer path 404, not evidence. Regression synthetic long incoming at top and tail, jump, count, draft, other room. v13.158 CI 45607414674/45607414779 passed, merged. No real messages, production data, DB or bill changes. Native gesture acceptance pending.


## v13.160 — MAIN-DATA-05 / incoming event identity (fixture)
E0: receiveDemo allocated a fresh per-room ID on every invocation, so replay of the same upstream event could increment unread/jump and append a duplicate. E1: optional stable synthetic eventId uses MessageStore's own ID lookup before mutations; same ID, room, sender and text is a no-op; conflicting room/content is rejected; distinct IDs with identical text remain distinct. No second event store; existing checkpoint restores the identity along with records. No changes to keyboard, scroll controller, notification delivery or production. Source reread: Redux Toolkit unsorted_state_adapter.ts blob 81d97994c84c491c2b19aedb3582f9d224d15cdb (add ignores existing key), Matrix event-timeline-set.ts blob 93c6ce4a8151aa3c93c2aef36d22cf3f7341904b (eventIdToTimeline, DuplicateStrategy); Adobe SelectionManager.ts blob d6ff15c5b5efd7f9be685f87f46c3ed251c093f5 (focus independent of key); Astryx Stack.tsx blob c56d72759ad2f6f86102228e22c3123530b32894 (scroll owner). No upstream code copied. Chromium regression: repeated ID in other/current room, same text different IDs, conflicting room, store/thread/preview/unread. E2 pending; E3 Pages and E4 native pending; actual read receipts, push and transport not integrated. v13.159 CI 45608317615/45608317584 passed, merged.


## v13.161 — MAIN-DATA-06 / READ-API fixture integration
E0: click immediately cleared unread, including unseen old-position and hidden chat; writable incomingCounts duplicated store state. E1: MainData owns per-room ReadStateController using shared MessageStore, seeded history acknowledged explicitly as fixture baseline, update head on append, preserve receipt in QA checkpoint. Contact reads unread from controller; no reset on click. Stable row IDs for nonseed messages; local adapter samples only active visible focused chat, excludes open dialog and composer/visual viewport clipping, requires whole row and hit tests, 250ms sampling and existing 1000ms dwell/contiguous prefix; local synthetic acknowledgment only. PendingLatest remains separate UI jump counter, not read receipt. Oversized rows, complex overlays, desktop multi-panel attention, native and real server receipt/Push remain pending; intentionally conservative. No protected keyboard changes or real messages/data. Sources reread: Matrix read-receipt.ts 3da1558b49f40937ee7eabae196d02c0a7ad6659, Element TimelinePanel.tsx d27836e126009d718a1c8cde9923dfeb4aece5bc, Adobe SelectionManager.ts d6ff15c5b5efd7f9be685f87f46c3ed251c093f5, Astryx Stack.tsx c56d72759ad2f6f86102228e22c3123530b32894, W3C IntersectionObserver index.bs c472c0c13323a2c1bd3a039c586a3dca50adf939. Source lesson: selection not receipt; separate synthetic/real, visibility/activity timing and clipping. Tests static fixture read/restore, Chromium immediate unread on open and dwell, away unread. v13.160 both CI passed and merged. E2 pending, E3/E4/E5 pending.


## v13.162 — READ-API-06 / oversized message coverage
E0: whole-row visibility rule never qualifies a row taller than viewport. E1: extend existing ReadStateController.sample with optional visibleParts, keyed per message/layout/revision, fixed equal-height segments for oversized rows (approx 80 CSS px, <=2048), one segment for short rows. Each fully visible segment must independently dwell 1000ms; skipped parts block proposal; reset on hidden/focus loss/navigation/sample gap and invalidate when layout changes; no scroll writes. Existing visibleIds remains for labs; receipt still contiguous and synthetic-only. Adapter clips to same viewport/composer and hit-tests three vertical points per segment; partial occlusion between sample points, oversized geometry >2048 parts, actual native keyboard/overlay and server receipts pending. Source reread: Element TimelinePanel.tsx d27836e126009d718a1c8cde9923dfeb4aece5bc (activity timer), W3C IntersectionObserver index.bs c472c0c13323a2c1bd3a039c586a3dca50adf939 (intersection rectangle), Adobe SelectionManager.ts d6ff15c5b5efd7f9be685f87f46c3ed251c093f5 (focus), Astryx Stack.tsx c56d72759ad2f6f86102228e22c3123530b32894 (scroll owner). Segment policy is local proposal, no upstream implementation copied. Static regression skipped middle, layout reset, fast pass, hidden reset; Chromium long row scroll coverage. v13.161 both CI 45610426289/45610426463 passed, merged; diagnostic overlay prevented real pointer action in previous CI, closed via existing control in test. E2/E3/E4/E5 pending. No protected keyboard or real data changes.


## v13.163 — NOTIFICATION-API-07 / Main fixture route projection
E0: MainData receives and renders fixture messages but did not invoke NotificationController. E1: MainData.notificationPlan reads canonical message and confirmed receipt, derives local view using PresenceController.project, calls existing NotificationController.plan. receiveDemo returns policy decision only after successful append and existing thread/directory update; duplicate returns null before any projection, no parallel message store. Actual RuntimeContextAPI.read supplies visible/focused route; no thread candidate on navigation, wrong rendered room, non-chat route or dialog. Fixture-local session is explicitly not server freshness proof. Browser permission read only, no request, no actual alert/OS Push/sound, no fake accepted settlement; in-app and push are candidates only, existing thread/badges remain; durable ledger/foreground delivery adapter/worker evidence and actual cross-device integration pending. Sources reread WHATWG notifications.bs aad8341ddb2a313ab203a1b33752dd410038450b (tag/renotify), Element Notifier.ts 0e9dcc2eff64a638dbd6eca461f6eceebbdbd807 (sound coalescing), Workbox.ts 568f4708c4d352c17a95d33075532f4b8f7baa5e (unbounded messageSW response), Adobe useToastState.ts 49817edce3e90abdb0f5970baa1cbd0115f91796 (key/queue), Astryx Stack.tsx c56d72759ad2f6f86102228e22c3123530b32894 (layout). Chromium fixture tests directory/thread/other/duplicate, hidden permission projection, history and confirmed read. No keyboard, media, scroll behavior, real data or messages changed. v13.162 CI 45610996078/45610995989 passed, merged. E2/E3/E4/E5 pending.


## P01 v13.164 — Typography usage
Chat role 17/26 plain/formatted; CardController.row both detail 14/20; TableController shared table header/data/footer detail 14/20. Typography owns size/line; Card/Table composition/alignment. Input untouched. TYPE-HARMONY-01–04, CI/native pending.


## v13.165 — Button type
Button.create textRole detail(default 14/20), body(16/22), caption(13/18). ButtonController registration owns bill medium profile, icon/composite excluded. Geometry independent. BUTTON-TYPE-01–03; CI/native pending.


## v13.166 — Type rhythm
Typography: version 11/16, contact name medium 16/22, preview detail 14/20, time 13/18, chat 17/24. Layout: contact preview track derives from detail, desktop thread gap 8. Input untouched. TYPE-RHYTHM-01–03; native pending.


## CHAT-READ — read-only integration boundary
ChatReadAPI.create({session,readContacts,readThread}) consumes host-authorized canonical CHAT data; exposes directory/thread/dispose only. No token, network, storage or business API. Fixture Popup `?chatread=fixture`, not live. Host must clear view on auth change and validate membership each call; see CHAT-READ-01–04 and CHAT-READ-BRIDGE.md.


## v13.172 LiveAuthAPI
inspect(client) distinguishes guest/enroll/challenge/ready; enroll and verify use Supabase MFA; UI boot/guest/mfa/ready mutually exclusive, view scoped to authenticated account and same tab. Network failure stays boot retry, not logout. View restoration is not proof of MFA backend enforcement. CI/real-device verification pending.

## Main live profile
Main.mount({live,onSearch}) creates same shell, no fixture contacts for live, returns hidden unmounted root until caller mounts. Live adapter binds server read/send, directory selection, search, navigation, DraftMedia preview; no upload or business API. Native keyboard integration pending.

## Live content projection
Real text routes through Message.create; authenticated media parts attach before metadata; unavailable media metadata is explicit unknown, not an invented file type. See LIVE-INTEGRATION-MAP.md and LIVE-INTEGRATE-01–04 for all existing owners and missing adapters.

## v13.173 shared interaction runtime
ScrollController, KeyboardController, InputController, resizeDraft, swipe and beginSharedNavigation execute before live/fixture data split; view uses canonical owners. liveCanSend adapter only restricts submit eligibility. Protected keyboard geometry unchanged. Native acceptance pending.

## Shared picker live/fixture
Same native picker before split. Live callbacks authorize capture/decode by session, track room cleanup and status only. Existing DraftMedia and composer geometry unchanged; upload unavailable, native OS menu acceptance pending.

## Live gallery adapter
liveMediaGroups groups ordered consecutive images within one message, up to four. mediaImageGroup decodes private blobs, passes natural sizes to MediaController.gallery, keeps successful images on partial failure, retry missing. Existing viewer supplies navigation/zoom/rotation; non-images stay in source order. No backend media guarantee or upload.

## v13.174 live geometry/media
ScrollController.replaceMedia(el,replace) owns media growth anchor; when tail and idle follow existing geometry; when entirely above visible area and idle compensate delta, otherwise preserve scroll. Live adapter accepts known image MIME under generic file/attachment and requires decoded supported image. Directory account actions use Layout grid 2 columns. Native acceptance pending.

## Main navigation position
Main.threadPosition(reason,saved): contact/send -> tail, restore/return -> saved. Main.finishNavigation(epoch,position,onDone) validates active room/screen/epoch, waits for layout and delegates scroll to ScrollController. Main is the common parent; no adapter-specific auto refresh.

## Media MIME parent
MediaController.normalizeMime, isImageMime, imageBlob: normalize supported aliases, retype only valid raster Blob without changing bytes, do not disguise explicit non-image. Decode remains mandatory before display. All live and picker image routing uses same parent.

ScrollController.finishNavigation(position): consumes epoch-validated Main position and clears prior navigation's scroll cooldown if not touching; hidden/loading scroll events do not start cooldown. Existing geometry/gesture policies otherwise remain.

Main.finishNavigation convergence: waits for stable measured scroll extent/height/composer reserve and pending layout frames, commits position through ScrollController once (max 12 frames), stops for a new navigation epoch or user gesture. No new keyboard writer or continuous observer.

## v13.175 media file parent
MediaController.assetType(kind,mime), playableBlob(blob,kind,declared), audio(), fileLink() share classification/renderer with video/gallery. Live adapter downloads only private assets by authorized key, validates scope, uses existing ScrollController; unsupported player falls back to download. No upload or public URL.

## v13.176 Media draft
MediaController.draftKind(blob,allowFiles), draftFileMimes(), draftPreview(item) delegate MIME/size/preview; existing DraftMedia keeps Blob alongside thumbnail metadata, scoped by contact; fixture image-only. A file is not sent just because selected. liveCanSend still blocks all pending attachments. Native picker behavior and independent upload backend pending.

## v13.177 live bill projection
CardController.billPair(leftLabel,rightLabel) is shared sample/live layout. BillReceiptProjection.read(asset) accepts only a server receipt bound to asset/message, filters non_bill, produces exact amount display and explicit missing fields, no mutation. BillReceiptProjection.render reuses CardController and the existing MediaController lazy group. Backend projection pending separate review.

ScrollController.followEnd/stopFollowing/userMoved: scoped navigation tail intent after Main final commit; shared content ResizeObserver watches current rows, repositions only when extent changes and user has not left target. Existing replaceMedia uses this intent, and jump re-arms it. No changes to KeyboardController; nonpinned restore stays nonpinned.

LIVE-BILL-02 backend candidate: existing private admin_media optional bill_receipt uses exact key join, AAL2 and same-customer collection ledger, strict printed time/date. Existing wrapper/ACL unchanged; production not yet activated.

LIVE-BILL-03: BillReceiptProjection.recipientDisplay returns proposed display and raw when a known prefix is detected; raw stays visible for review. Live bill preview uses existing MediaController.rotate from original, room-scoped, 24 MP cap; no automatic text orientation, persistence or financial authority.

LIVE-BILL-04: MediaController.printedOrientation(image) -> 0|90|180|270|null; conservative local glyph direction hint, only live bill preview consumes, original retained, manual override available, no semantic recognition or financial authority. Browser canvas required.

## v13.179 CONTENT-AB
Message.create sets data-content-party A/B from existing mine flag. ContentAPI.line/segments/create render limited explicit formatting through Typography (plain text, headings, bold, unit-bearing quantity, divider); no HTML, no business parsing or writes. Existing CardController/TableController/MediaController remain specialized owners. Live and fixture share Message.create. Native and full business-card migration pending.

## v13.180 CONTENT-FLOW
Message.flow(previous,row) is presentation-only, marks adjacent text rows with same known party/day/HH:mm. The prior row keeps metadata in DOM and aria-label but CSS visually hides its duplicate time. New minute, party, date, media, unknown, or card stops grouping. Live and fixture initial/append use same parent. No data mutation, business inference or keyboard changes.

## v13.181 LIVE-BILL-05
ParseAPI.billRecipientEvidence(raw) -> suffix|full|masked|null, literal receiver field with four to six nines; no arbitrary substring or cross-line assembly. BillReceiptProjection.read requires this and transaction evidence (positive amount or date/time shaped value), otherwise null -> standard media. Existing receipt/ledger state remains unchanged; no backend authority.

Missing projected receipt fields display “Không có”, not “Chưa đọc được”; ordinary images have no bill table. No assertion about physical original without evidence.

LIVE-BILL-06: exact full receiver; matching suffix/mask are recognition hints only. Name mismatch -> review, raw OCR preserved; missing name not fabricated. Date independent of clock. No ledger mutation.

LIVE-BILL-07: BillOCRFieldAPI.parse memo evidence may include endLine; readScoped accepts bounded multi-line memo in explicit region. Geometry spans label and value lines with no misleading single-line valueRect. Live BillReceiptProjection preserves returned line breaks in shared bill pair CSS. No mutation.

LIVE-BILL-08: BillOCRFieldAPI.identify(line) exposes existing typed label routing; BillRecognitionAPI consumes it rather than maintaining a separate recipient label regex. Journal unlabelled amount + date proposals are review-only contextual evidence. No server OCR, posting or image-corpus claims.

LIVE-BILL-09: ParseAPI.billRecipientEvidence returns truncated-tail for exact 12-digit target prefix ending in 4–6 nines. BillRecognitionAPI recognizes this as review-only; projection retains OCR digits and existing ledger evidence. LIVE-AVATAR-01: Avatar.publicSource(path,origin) constructs only existing public bucket object URLs, validated path; Contact and live header consume the shared owner and ChatReadAPI avatarPath. Backend directory projection required.

LIVE-DATA-PROJECTION-01: directory contact adds nullable avatar_path; existing private media projection can return date_vn with no transaction timestamp only when printed numeric date matches a valid normalized calendar date. No change to scope, clock, ledger or financial mutation.

LIVE-BILL-MEMO-REVIEW-01: admin_media transfer_content uses independently visually reviewed memo only for exact asset/message/customer and matching OCR snapshot. No new public endpoint or client grant; canonical financial OCR evidence unchanged.

LIVE-BILL-BANK-PROOF-01: nullable bank_verified_account is independent linked Agribank credit evidence for previously received truncated-tail OCR; original receiving_account is unchanged. Strict exact amount/time/account/linked collection/customer. UI must distinguish bank evidence from image OCR.

LIVE-BILL-DIGIT-RECHECK-01: admin_media ocr_rechecked_account is nullable display-only second vision reading; distinct from bank_verified_account.

LIVE-BILL-BANK-PROOF-UI-01: BillReceiptProjection uses bank_verified_account only for truncated-tail + received + has_ledger and exact configured account. Original OCR remains accessible; no change to recognition or collection.

LIVE-BILL-DIGIT-RECHECK-UI-01: BillReceiptProjection prefers strict linked bank proof; otherwise accepts exact focused OCR projection for truncated-tail only; retains original and displays no bank confirmation.

LIVE-BILL-MEMO-LINE-01: BillReceiptProjection converts runs of whitespace to one space for displayed memo only. Image transcription remains literal, business comparison retains existing normalization and guards.

LIVE-BILL-RECIPIENT-GATE-01: BillReceiptProjection.read returns null unless normalized beneficiary name matches and full configured account is supported by literal OCR or existing validated correction. Return main receipt fields first; optional source metadata remains in compactBillDetails. No new component or financial mutation.

LIVE-BILL-VISUAL-ACCOUNT-01: ocr_rechecked_account additionally accepts exact independently visually reviewed account tied to immutable raw snapshot. No bank proof implied. Existing UI consumes same field; no release version change for backend-only migration.

LIVE-BILL-REVIEW-REASONS-01: BillReceiptProjection.read(asset,now=ISO) returns flagged field labels and a reason row for receipt candidates; no hiding solely due to mismatched recipient; no write or payment authorization. TimeAPI.businessDate owns comparison. Explicit now supports boundary tests.

LIVE-BILL-HISTORY-DATE-01: BillReceiptProjection.read uses ParseAPI.billDate and FormatAPI.date, and TimeAPI.businessDate only as future-date upper bound; accepts historical dates and explicit mixed text, retains missing/invalid date/clock reasons. No ledger changes.

LIVE-BILL-LEGACY-DEBIT-01: admin_media returns recovered display-only amount_vnd/date_vn for tightly constrained legacy sender-debit OCR with matching literal short year and clock. Review status remains unchanged and has_ledger false. Same ACL and exact asset binding; no schema or financial mutation.

LIVE-BILL-JOURNAL-MEMO-01: legacy admin_media review-only BIDV SMB-TkThe notification masks falsely inferred recipient fields while keeping memo and recovering explicit negative transaction amount for a matching printed date/clock. No collection authority.

LIVE-BILL-AUDIT-WORKSPACE-01: v0_admin_bill_audit() -> {account_id,total,rows} read-only, max 1000, private AAL2 scope; BillAuditList.select derives sorting/filter/search, CardController and existing media loader render. No collection authority. Explicit missing data, account review separately.

LIVE-BILL-AUDIT-ANNOTATION-01: audit read adds raw_hash/review_state/review_revision/corrections/review_note; v0_save_bill_audit_annotation accepts per-field string/null, note, state, revision and raw hash. BillAuditList filters progress; existing CardController.billPair and Media loader. Financially inert annotations.

LIVE-BILL-STANDALONE-01: ?live=1&view=bills is a dedicated full-screen route of mountLiveChat; it skips directory/thread bootstrap, invokes existing audit API after authentication, uses same annotation RPC and CardController.billPair. Audit media loader root and URL lifecycle scoped to audit. No duplicate implementation.

LIVE-BILL-ENTRY-01: bill.html canonical alias activates the standalone Bill projection by pathname even with tracking parameters. Same original image, audit/annotation RPC and auth; no directory/thread bootstrap. All release entries share identical blob.

LIVE-BILL-CLASSIFICATION-01: admin_bill_audit returns audit_kind bill/non_bill/other_transfer/unverified; BillAuditList.kind and filters use it. Hash-only copies have no artificial missing-field flags. No collection authority.

LIVE-BILL-ID-01: BillAuditList.code derives a stable human-readable prefix from receipt id. Search indexes prefix, BILL-prefix and full UUID; copy full UUID. Prefix collision may return multiple records.

LIVE-BILL-CURRENT-RESULT-01: BillAuditList.effective derives latest visible values from stored correction keys; original_ocr preserves previous fields, affected data-gap flags recalculated. Audit source rows remain unchanged. No finance writes.

LIVE-BILL-FRESHNESS-01: fetchAudit({background}) uses existing RPC with single flight and scope guard; refreshAuditVisible skips active edits/dialogs/hidden; only changed rows rerender, stable search/page and scroll. No new API or financial writes.

LIVE-BILL-READ-TIME-01: scoped audit RPC adds ocr_scanned_at and result_saved_at (nullable timestamptz); Card formats Vietnam time, distinct from transaction and page-fetch timestamps.

## v13.194 BillAuditList.progress(rows)
Returns total/saved/pending/latest over loaded Bill scope, excludes non-bill, distinguishes annotation save from model completion; no new request or mutation. CardController keeps existing row layout.

## v13.195 — Batch controls
Existing CardController.panel and Button.create with native disabled; only existing fetchAudit is actionable. No duplicate runtime owner. No dispatch, no production changes.

## v13.196 — BillAuditList.batchPlan(pending)
Pure count projection (0..1000) at max 50 records; returns planned number/count, not actual jobs. Existing CardController rows and one disabled native Button; saved-result sync remains read-only. No endpoint calls added.

## v13.197 — standalone image review
Existing BillAuditList.effective/select, CardController.billPair and mediaImageGroup; two columns, all loaded records, search and read-only refresh. Existing integrated audit preserved. No new data API.

## v13.198 — BillAuditList.imageGroup / imageGroups
Pure display grouping based on stored audit_kind and sender-bank aliases, no OCR inference; groups contain every row exactly once. Native select with counts; standalone only, same CardController pair.

## v13.198 — BillAuditList.imageOnly / imageOnlySelect
Standalone ingress allowlist metadata only; search by image ID, sort by sent_at. No use of legacy fields. Bank-group helpers are dormant until an independently verified new-result source exists.

## v13.199 — BillAuditList.printedClassification
Pure OCR text classification with explicit recipient label from BillOCRFieldAPI.identify, numeric suffix, contextual printed-text proxy and confidence. Local single-image OCR reuses BillOCREngineAPI.loadDemo/demoFactory; single flight, bounded image size, session-only results. No verified handwriting classifier or production database persistence.


## v13.200 — LIVE-BILL-AUTO-LOCAL-01
User override of single-image start: after successful standalone audit fetch automatically enqueue all loaded eligible image metadata, independent of current filter or page. One worker per scan, sequential, no old OCR, no external AI or financial writes. Attempted failures remain unclassified; image errors continue, worker errors pause, explicit resume, manual reread after scan, hidden tab pauses after current image, logout invalidates scope. Progress is actual attempts and successful reads; redraw every three, preserve scroll. Session memory only; no cross-F5 persistence; no claim of handwriting accuracy. Integrated audit and keyboard unchanged.


## v13.200 — LIVE-BILL-CLASSICAL-01 (user override before release)
No generative AI, neural OCR/LSTM, or neural image classification in new Bill reading. Supersedes BANK-ENGINE-01/05 and LIVE-BILL-LOCAL-PRINT-01 only on OCR OEM and classification: pinned Tesseract.js 6.0.1 uses OEM 0, legacyCore/legacyLang true, cache none, no fallback. Legacy is a traditional trained/adaptive character classifier, not an untrained algorithm. Require actual transaction structure plus unique recipient-labelled suffix, support inline label without colon; no bare digits accepted, no sender/memo/code inference. Clear wrong account excluded from target bill group with reason; product/order positive lexical cues only, not visual or handwriting classification. Sparse, blurred, uncertain or conflicting input remains unclassified. No AI, old OCR, DB or collection write. Existing CDN dependency and real Vietnamese Legacy initialization unverified; no claim of new self-hosting or private-image network audit. Session-only as before. Source: https://github.com/naptha/tesseract.js/blob/v6.0.1/src/createWorker.js and src/worker-script/index.js, browser/getCore.js; https://github.com/tesseract-ocr/tessdoc/blob/main/Data-Files.md. Future classical image geometry study pending.


## v13.201 — LIVE-BILL-GROUP-STRIP-01 / LIVE-BILL-EXACT-INTAKE-01
Standalone audit only: replace hidden dropdown with five stable native buttons in horizontal flex wrap (all, exact duplicate, unclassified, bill, nonbill), counts and aria-pressed; selected group remains stable on updates. Before OCR use storage-object identity and SHA-256 via existing BillDuplicateAPI.digest on downloaded original bytes, session-scoped, no old OCR, no perceptual duplicate automatic decisions. Exact duplicates link to canonical row and never OCR again. Hash pass independent of OCR initialization; unique images need a second storage download, bounded memory, no persistent cache. Failed hash is not duplicate evidence. Legacy startup timeout and sanitized failure reason, no LSTM fallback. No bank grouping change, no finance/DB/keyboard writes. UI and live 600-image throughput pending.


## v13.202 — LIVE-BILL-INIT-01
Root cause: live path returns from the application IIFE before BillDuplicateAPI, BillOCRFieldAPI and BillOCREngineAPI const initialization. Move contiguous shared pure bank APIs and BusinessProjectionAPI ahead of the existing live mount/return, retain demo UI after return, preserve single owner and existing OEM 0. No extra AI or database mutation. Add source-order guard and authenticated standalone synthetic browser fixture with duplicate asset and injected classical worker; actual network language assets still require live verification. Existing static test extraction follows shared API boundary. No keyboard change.


## v13.203 — LIVE-BILL-VISUAL-PRIORITY-01 / LIVE-BILL-STORAGE-BUDGET-01
Classical 192px thumbnail triage on already downloaded original: grayscale histogram, neutral/saturated share, row foreground transitions/bands and edge density. Document-like is priority only, not bank/handwriting evidence or nonbill verdict. No neural inference or template library yet. One authenticated session RAM LRU (64 MiB/64 entries, 15 MiB per image) shares original Blob and single in-flight Promise between standalone image render, exact SHA and OCR; clears on logout, never persists private bytes, no new signed/public URL or storage schema. Full hash pass remains before OCR; evicted images may download again, no one-download guarantee. Refresh foreground/heartbeat audit RPC no more often than 5 min automatically; manual refresh unchanged, auth heartbeat unchanged. Show actual client download attempts and reuse counts, visual timing. No production data writes. Source OpenCV 4.10.0 threshold and morphology/lines docs, Supabase Storage egress and private serving docs. Actual CDN cache/egress/log quotas and throughput not measured.


## v13.203 — LIVE-BILL-NO-REPEAT-01 (before release)
No repeated automatic full-list scans: initial authenticated fetch and explicit refresh only (focus/heartbeat update UI, session auth heartbeat remains). New or incomplete image only, no automatic retry of a failed original; explicit single reread allowed. Same-tab sessionStorage checkpoint keyed by verified account and classical algorithm revision, matching current id/storage key, no raw OCR/account/bytes, no financial authority; duplicate labels rebuilt from current metadata and saved SHA. Persist pause/errors, clear on guest/signout; no cross-device/tab guarantee. No DOM rebuild every 3 OCR or 10 hash rows: update counts/status, rebuild list at phase boundary and completion or explicit filter. No unconditional finally restart. Original cache still bounded, eviction may require a second download. Actual Supabase usage pending. Supersedes 5-min background refresh rule. Synthetic browser reload/manual refresh regression added; CI pending.


## v13.204 — LIVE-BILL-MANUAL-VERIFY-01 (user override)
Supersedes standalone automatic scan/group UI. No automatic hash/visual/OCR run; single explicit read button and raw OCR text, editable correction, explicit type and verified save. No financial authorization. Same-tab sessionStorage raw/corrected result and timestamp (new namespace; erased on logout/guest), no database or cross-device persistence. Browser localStorage per verified account stores only ordered field-label signatures and type/count, no raw text or monetary values; matching signature hint after future manual read, not automatic template OCR or verified result propagation. No AI, no background bulk work. User can correct and save a nonbill even when OCR fails. Shared bounded original cache remains. Browser regression changes to zero automatic calls, one manual call, verify and reload. Actual language asset and real accuracy pending.

## v13.205 — LIVE-BILL-SIX-FIELDS-01
Standalone manual OCR displays amount, transaction date, time, recipient name/account and memo from fresh raw OCR (or explicitly verified correction). Reuse BillOCRFieldAPI.parse and suggestUnlabelled with both numeric profiles; conflicting candidates remain missing; exact known recipient name only proposed when literally present adjacent to observed configured account. Never populate missing fields from configuration. No automatic OCR, financial mutation or external AI. Raw/edit/verify preserved. Real image accuracy and deployment pending.

## v13.206 — LIVE-BILL-LSTM-01
User approves LSTM upgrade for standalone manual OCR, superseding OEM 0 only on this route. Existing BillOCREngineAPI.liveFactory uses Tesseract.js 6.0.1 OEM 1 vie+eng, LSTM-only flags, isolated language model cache (no image cache persistence). Explicit sequential clicks reuse one authenticated worker; terminate on scope reset or OCR failure/timeout. Upscale small originals up to 3x, longest side 2400 and max 4 million pixels; no old OCR reuse for new reads. Parse-only handling of literal account+bank, date/time+reference and memo inline; raw preserved, no default values. Existing legacy demo factory unchanged. No external AI or financial writes. Upstream: https://github.com/naptha/tesseract.js/blob/v6.0.1/docs/api.md, docs/performance.md, src/createWorker.js. Real accuracy/latency, CDN and device verification pending.

## v13.208 — LIVE-BILL-AI-MANUAL-01
User explicitly supersedes standalone classical/LSTM OCR: one explicit authenticated manual Gemini Vision request per click, original private image resolved server-side from existing v0_admin_bill_audit scope (active admin/session/AAL2), caller-scoped Storage, server-only key, no service role, no automatic retry/scan, no financial writes. Six literal fields and null for unreadable; no expected values in prompt, no confidence percentage fabricated. Separate tab checkpoint namespace, editable structured text and verify, no cross-device durability. New endpoint v0-bill-vision-manual; existing internal acceptance and financial functions unchanged. One internal audit RPC per click returns scoped metadata server-side; no new polling, but cost/latency not measured. Original selected image sent to Gemini on explicit click. Provider quota, privacy terms and actual image accuracy pending. Source Supabase Auth docs and existing v0-bill-audit-reread endpoint; no internal key exposed.

### v13.208 — standalone presentation revision
User requests removing raw OCR text. Only six structured values, image, ID, manual read, verification status, optional inline per-field edit and verify. No raw or duplicate AI transcript displayed; old local OCR checkpoint removed for current account on initial load. No old DB data or ledger deleted. Verified edits retain structured values, no reparsing. Browser regression checks no raw label/textarea. CI pending.

## v13.208 — backend hotfix 2: manual Vision timeout
Observed 502 at 33494 ms on 2026-11-26 04:36:42 UTC with ai_timeout. Keep Gemini 3.5 Flash, explicit MINIMAL thinking, 75s provider timeout instead of 30s, one model request only; retain original image and authorization. Log only model/status/duration/error class, never contents. Supabase idle limit 150s; Google Gemini thinking docs consulted. No frontend version or ledger change; actual successful read pending. Rollback prior function source.

## v13.209 — LIVE-BILL-AI-LITE-01
Production Gemini Flash logs show two provider HTTP 200 responses at 67987 and 69784ms and one timeout at 75002ms. Switch only manual bill Vision to gemini-3.5-flash-lite, supported MINIMAL thinking, original image, same single-call budget and 75s deadline; no automatic retry, no financial writes. Google Gemini thinking documentation consulted (https://ai.google.dev/gemini-api/docs/thinking). During retry show current in-flight state rather than stale timeout; retain prior successful fields if new request fails and show latest failure. Backend deploy and real-image accuracy/latency must be checked separately from CI.

## v13.210 — LIVE-BILL-VIETINBANK-LAYOUT-01
User confirms BILL-BEB34B9E as VietinBank sender layout. On each explicit manual Vision request, first identify sending bank from app header/logo, not beneficiary bank, then apply relative layout only if VietinBank matches: amount center, small date/time/reference under amount, recipient name and account below arrow, right-aligned one/two-line memo ending before Xem thêm. Never copy transaction values or infer missing digits. Add editable sending_bank alongside six existing fields; old AI results may lack bank until reread. One model call, no auto scan, no financial mutation. This is prompt guidance, not model training. Synthetic fixture verifies display; accuracy on new real images pending.

## v13.211 — LIVE-BILL-VIETCOMBANK-LAYOUT-02
User identifies BILL-70A42109 as VCB Digibank. Inspected enlarged screenshot: logo upper left, centered success/amount/small time line, two-column details with account ABOVE recipient name, bank next, memo right one/two lines before fees/method/reference. Exact fine print too blurry to independently validate all digits; prompt uses only positions/labels, no sample values. Apply layout conditionally and retain generic fallback; normalize sender bank aliases VCB Digibank to Vietcombank. One explicit AI call, no ledger writes, no automatic scanning. Existing VietinBank layout retained. Real-image accuracy not yet verified.

### v13.211 — Co-opBank sender recognition
User identifies BILL-2B8C7111 as Co-opBank; exact receipt record confirms stored sender COOPBANK. Original image pixels were not accessible in this session; no claim of verified field geometry. Add conditional sender-brand recognition and normalize aliases to Co-opBank, use actual labels with generic evidence-only reading until an image is visually reviewed. No hardcoded relative positions, no sample transaction values, no extra AI request. Existing VietinBank and VCB layouts remain. Actual read and CI pending.

## v13.212 — LIVE-BILL-BANK-TYPE-03
User provided ten sample IDs; matched database metadata for all, not original image pixels. Registry: 233071C7 Techcombank receipt; 207D5514 BIDV receipt; 53A01132 VPBank receipt; 95AF248A BIDV balance notice (stored sender_debit); 8268651D MoMo wallet transfer; 1C0AD231 MB balance notice (user identifies MB, stored sender null; sender_debit); 4CBFF2A9 MB receipt variant 1; AC4B545C MB receipt variant 2; 33B118A9 SHB receipt; 36652584 MSB receipt. No transaction values in prompt, no unverified fixed geometry. New type field separates transfer receipt, debit notice, credit notice, wallet transfer and unclear; sender aliases normalized. For notices distinguish GD from SD, read actual DEN/ND if present; do not infer recipient or credit confirmation. Keep both previous verified-position guides and Co-opBank label-based fallback. One explicit AI request, no scan or ledger mutation. Actual sample pixels unavailable; layout variants not visually verified. CI/live verification pending.

## v13.213 — LIVE-BILL-REGION-EVIDENCE-01
User requests analysis of all registered bank examples and rules by region. Prior inspected layouts: VietinBank, VCB and alternate Techcombank photo with notification above main receipt. Existing deployed rule source includes BIDV journal memo-only. Ten newly referenced originals cannot be visually opened with current connector; metadata is not image evidence. Do not invent fixed geometry for Co-opBank, VPBank, MB receipt variants, SHB, MSB, MoMo, BIDV receipt. Add conditional Techcombank and BIDV guidance and generic label-based field discovery. Same single manual Gemini call returns seven optional normalized field boxes [ymin,xmin,ymax,xmax] of original full image; backend/frontend validate bounds, invalid boxes omitted, non-bill boxes null. Optional button Xem vùng AI đọc shows estimated boxes on unrotated original using scoped image cache, not an independent verification. Session-only checkpoint; no training/automatic rule promotion, no extra AI calls, no financial or database writes. CI and accuracy pending; actual per-bank geometry requires owner review.

## v13.214 — LIVE-THREAD-BILL-AUTO-01 (0v only)
User corrects scope: /bill.html is the manual lab; live conversation must read automatically next to original image. Reuse the same v0-bill-vision-manual prompt/region rules through an exact conversation+asset+message request. Server verifies user, signed AAL2 claims, active admin conversation scope, inbound sender and exact media; no client storage key, service role, grants or writes. Previously recognized bill candidates plus single incoming image in last 48h become eligible when visible in opened 0v thread; old unrelated galleries and outgoing images unchanged. Sequential one-request-at-a-time queue, same image on 429 only, >=60s or Retry-After, max three retries; successful results cached in same tab/account (up to 100), cleared on signout. Fresh fields never backfilled from old OCR; only existing independent ledger state is retained, no financial writes or CHAT changes. Unknown/nonbill stays ordinary gallery. Image may be rotated and Techcombank Tới/Đến is a label, not part of recipient name. Scope change stops retries; when page closed/suspended no guaranteed background run. Existing old financial status is not proof of fresh OCR accuracy. No durable server queue or real-time delivery added; this is automatic foreground reading. Sources: https://supabase.com/docs/reference/javascript/auth-getclaims and existing v0_admin_read/v0_admin_media SQL; https://ai.google.dev/gemini-api/docs/rate-limits. E1 policy/syntax fixtures only; full CI, release, Edge deployment and physical/real-image verification pending. No keyboard or other repo change. Based on pending region PR #195, not competing with its version.

## v13.215 — LIVE-CHAT-CACHE-SYNC-01 / LIVE-DIRECTORY-GROUP-01
User reports 0v filters, refresh, read counters and local/new message priority. Live DB contact_group customer 62, cm 49, other 26, friend 11; role=user is authorization not grouping. Existing admin_read exposes boolean only. SQL candidate preserves exact live function auth/scope/avatar and adds contact_group + count; existing boolean displayed as dot, not fabricated 1. No mark-read RPC yet; no read ACK writes. SQL not applied. Authorized thread snapshots 12 rooms / 24h same tab/account, restored after validated directory; clear on signout, reuse existing bounded image RAM cache. Foreground Realtime wake (existing v21_messages publication, actual RLS delivery unverified), online/visibility, 30s fallback; coalesced, skip navigation/send; keyed message DOM reuse, retain scroll. New send appears after actual server ACK before refresh. Existing backend returns 100 latest snapshots, not true cursor delta; durable IndexedDB, realtime device tests and read ACK pending. No production or CHAT/keyboard changes. Source receipts: CACHE-API-SOURCES, SYNC-API-SOURCES, Adobe SelectionManager pinned. Provisional session snapshot rather than durable CacheController cursor because live cursor contract absent. Stacked on #196. Pure policy and JS syntax verified; full CI/Pages/device pending.

### v13.215 — vòng 2 / LIVE-CHAT-TEXT-FIRST-02, LIVE-READ-ACK-01
Same unreleased PR #197, no competing version. Prior head 0a913ee CI API application check 45761630745 passed. New candidate: text render from scoped thread result before media request, retained cached media, refresh open thread before directory; preserve server-acknowledged new message across temporarily stale snapshots by ID (memory only, server wins when present). Avoid full openThread on send for real room, retain draft/scroll owners. Read ACK gated by backend capability; visible focused current chat, full visible incoming node dwell 1000ms sampled 500ms, no dialog/hidden, scope check. SQL review-only adds own/peer receipt timestamps and exact count; verifies active admin+AAL2, conversation membership, exact inbound message IDs, never device time, advance only contiguous incoming timestamp prefix (ties block), monotonic upsert; no live read writes executed. Older unseen prefix and oversized items block advancement (no false read). Peer read shown only using server receipt and actual server message date. Existing CHAT uses same read state; no CHAT code changes, shared receipt effect only after approved deployment. Source existing READ-API-01–06, v21_mark_read live definition (uses now(), not reused), existing v0 scope, v21_read_states unique key and message time index. Full cursor-based delta, durable IndexedDB and multi-device verification remain pending. JS parse/pure merge/context tests passed in connector; CI, SQL isolation test, deployment, real device pending. Rollback prior branch head; no production change.

### v13.215 vòng 2 — hardening
Throttle identical read proposals to 30s even on network failure or directory refresh; remove acknowledged observed IDs. Partial text render knows media completeness only for cached message IDs, avoiding incorrect missing-attachment label and unnecessary unchanged-node replacement. SQL explicitly qualifies unnested requested IDs. Candidate only; exact-head CI and SQL integration pending.

### v13.215 vòng 3 — LIVE-INSTANT-CONTENT-01
User requests no loading/sending text in normal live chat. Existing LiveChatSnapshotPolicy projects cached data and optimistic message immediately using client key; clear composer at enqueue, reconcile exact id on ACK, preserve newer draft, retain error and original idempotency key on failure. Directory/thread no loading text; live media aria-busy without loading text, reuse blob cache for attachments. Bill audit remains unchanged. Cold cache must await real response; no prewarm in this patch, no durable offline queue. Existing authorization, keyboard and backend unchanged. Source receipts CACHE/SYNC-API-SOURCES, Astryx Button/Stack, Adobe SelectionManager (previously inspected). Added delayed-ACK browser regression; syntax and pure policy checked; CI/native pending. Same PR #197 unreleased.

### v13.215 vòng 3 — bounded text prewarm
After authorized login, once idle for 2.5 seconds, prewarm at most three other recent uncached authorized conversations, text only, sequential requests; no download of images, skip on navigation/send/hidden/live sync. Independent background thread reads validate account/session/contact and never increment foreground request token; do not overwrite a cache filled by foreground. This supersedes no-prewarm statement in preceding patch. Cold uncached rooms still wait on network. Syntax checked; real-device performance and full CI pending.

### v13.215 vòng 4 — LIVE-COMPOSER-TAIL-01 / CONTENT-UNICODE-01
User screenshot v13.213: composer 82%, last message under input when focused, directory latest and capitalization. Keep keyboard viewport owner and original baseline unchanged for fixture/non-live; live mobile floating composer width 94% on focus-within (rest 82%), focus explicitly follows latest, reuse ScrollController and measured composer reserve during keyboard occlusion only while anchor pinned; user scroll cancels anchor. No new viewport writer. Incoming append reestablishes tail observer when pinned. Directory parent uses latest server timestamp, transient local text preview for just-sent and fresh received messages (30s max, server wins on newer/equal timestamp, remove on failure); sort by recent activity and wake 150ms (existing coalescing). Contact and Content share capitalization, preserve emoji ZWJ/modifiers/flags and punctuation; preserve raw database text, no UTF-16 truncation in live projection; native emoji font fallback. Existing markup interpretation unchanged. Existing read counts not fabricated. Source: existing ScrollController/Main, INPUT-TEXT and KB-LOCK contracts, pinned Astryx Stack/Button and Adobe SelectionManager study. Tests added emoji/line casing and live composer width/tail geometry; syntax and pure text fixture checked, full exact-head CI and iOS physical keyboard pending. No DB, CHAT or bill changes. Same unreleased PR #197.

### v13.215 release repair
CI 45764922069 failed keyboardBaseline and textInputContract, all 12 input fixtures individually passed. Restore all four protected ranges byte-for-byte to last passing candidate 53b66a9; separate live-only tail adapter outside protected ranges uses existing ScrollController.end/followEnd, no viewport geometry writer. Explicit pointer/touch/wheel/blur cancels tail intent; room/epoch guard. Count 12 Unicode cases, do not remove assertions. Full exact-head CI pending, native iPhone pending.


## v13.216 ContentAPI
Existing line/segments/create extended with tableAt/appendInline/status; semantic display shared by live and demo. Scoped formatting, not new parallel owner. Input/keyboard and business data untouched. CI/native pending.


v13.216 follow-up: Contact.preview owns prefix cleanup; Message keeps date/time; visual rule hides them. ContentAPI owns dotted links. A/B paint updated, media and keyboard retained.


v13.216 Message.describe/latest/hint/follow/markLatest: shared latest projection for text, attachments and mixed; type-independent tail, parent delegates actual scroll to ScrollController. Media sending live not implemented. CI/native pending.


v13.217 Message.rhythm/newIncoming and LiveChatSnapshotPolicy.group/unread extend existing parents; Main/ScrollController unchanged. Deferred wake and fresh snapshot only.


v13.217 follow-up: explicit ContentAPI links marked data-content-link; numeric text not automatically decorated; Safari detector fallback and actual parent dependency in CI.


CONTENT-FORMAT-06: one dotted underline paint for Typography and ContentAPI; native detector links styled dotted as well. No custom conversion of ordinary numbers.


## v13.217 mobile glass optics
Surface.bind G1 consumers share mobile floating tint/edge/highlight/elevation; header and jump face, composer parent only (no nested glass). Header blur supported and keyboard closed, composer default remains static. Protected geometry and focus unchanged; desktop and accessibility fallback retained. See SURFACE-MOBILE-OPTICS.


## v13.218 Message palette
Message.palettes/paletteKey/storedPalette/applyPalette/choosePalette centralize outgoing bubble color choice, root token projection and local preference; Main mounts existing Button/Popup, no new geometry owner.


## v13.219 directory utilities
Contact.update retains unread badge and positions it with shared avatar grid; Main.directoryMenu delegates existing actions to Popup. Compact mobile live directory only. No separate menu lifecycle or keyboard owner.


### v13.219 Typography refinement
Shared --font-ui system sans stack and --type-chat 16/24, weight 400; no input/geometry change. All Message content uses Typography. Screenshot approximation; CI and Safari pending.


### v13.219 text case / unread
Shared normalizeLines handles t7, preserves long codes, URL and email. Contact.update projects actual unread state to parent data-contact-unread, preserving read authority. No new runtime owner.


### v13.219 Typography correction
--font-ui restored to accepted stack; --font-chat restricted to ContentAPI reading surfaces. Input font, sizing and protected code unchanged.


## v13.220 Foundation Vercel profile
Typography uses scoped --ux-font for Work/read and utility menu, input/chat unchanged. Card and Button consume scoped radius/glyph tokens; Scroll uses CSS native desktop rail tokens, no writer or event changes. See FOUNDATION-VERCEL-01–03 and linked Drive sources.


## CHATGPT-DRIVE — v13.220
User requests shared ChatGPT Drive profile + scrollbar + Web/PWA edges + single Enter. Supersedes conflicting FOUNDATION-VERCEL visual rules. Drive CSS 1ImNi8W0UGROtpsB1N41u1ENYK5I_5dRD and library 1ckwp6zF0bRZdlDG6n3VKLeM6cfVq2YI8: source scrollbar .mkt-style-scrollbars 16px rail, 6px transparent border, 4px optical thumb, light #0000001a/hover #0003 (corrected prior 10px estimate). Shared palette, font (accepted system stack, no remote font), chat 16/26, caption 12/16, icon 20, bubble 22 radius/70%/10x16 padding, neutral surfaces. Preserve existing 17/22 composer metrics, hit areas and keyboard geometry due 320px regression. Existing visibleSafeArea already subtracts clipped insets; keep single top/bottom owner, no new PWA offset. Enter calls existing form submit, Shift+Enter newline, IME/repeat ignored. Source Astryx tokens 7ca09a989079c26627462bfe50abbcb08ec1328c, Text da954186ff862485cbf0e1964cb2bec15f43b9bb, Button f87eb657180a0de978fb3ba1c59c24909a9cc63d. No DB change. CI/native pending; no claim full visual parity.


## LIVE-DIRECTORY-STABLE — v13.220 follow-up
- Actual live renderDirectory previously replaced every contact/avatar/name/time on each reload, latest hint, filter, ACK. Contact.reconcile now keys by account ID, delegates Collection.project, reuses Contact nodes, updates name/preview/time/unread via Contact.update and image via Avatar.update (unchanged source leaves existing image/fallback; changed URL replaces only image internals). Hidden filtered contacts retain node; removed accounts removed, onSelect resolves current row rather than captured stale record. Equal payload no full list reset; reorder only when necessary, preserve visible anchor via ScrollController. Header Avatar.update also idempotent. ChatReadAPI uses FormatAPI.time on normalized explicit instant. No read authority changes. Existing Message keyed reconciliation retained; media/signature and thread reopen not fixed in this pass. Top/bottom/keyboard protected ranges unchanged. Study pinned Adobe SelectionManager d6ff15c5b5efd7f9be685f87f46c3ed251c093f5, useSelectableCollection 739a9433b098c081ce872815f10fbc83ba07172c, Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1 (stable key and anchor). Add live fixture row/avatar/name/time identity regression; CI and native still pending. No production data.


## v13.221 — LIVE-THREAD-BILL-NEW-ONLY
Explicit user request supersedes v13.214 48h/known-receipt eligibility and quota retry. Authorized session starts at billNewAfter; valid incoming image/message/room IDs, strictly newer timestamp, no receipt/cache. One automatic attempt per asset reserved before model request, no automatic retry; quota cooldown and manual lab separate. New multiple images handled one image at a time; historical galleries grouped. Cache bill/nonbill/unclassified in existing scoped session storage. F5 skips previous timestamps, switching room does not reset attempts. Existing 64MB/64-item blob cache reused; object URLs may be recreated. Device clock cutoff can miss offline or skewed messages; no background scans or durable cross-device claim. No DB/Edge/financial writes, protected keyboard ranges unchanged apart from version labels. References prior CACHE-API-SOURCES/SYNC-API-SOURCES (stable scoped identity, stale guards), existing ThreadBillAutoPolicy; local policy fixture pass, CI/device pending. Release v13.220 merged separately after exact-head CI.


## v13.222 — BILL-ACCOUNT-DECORATION-01
Observed case: stored AI text contained 13 uninterrupted digits followed by a space and one bullet; normalized recipient was null. In 0v ParseAPI receiver evidence and v0-bill-vision-manual validation, remove only one separated terminal bullet after exactly 13 uninterrupted digits. No digit insertion, no masking substitution, no removal of interior bullet, no general punctuation stripping. Keep original OCR text in existing record. Recognition alone never authorizes collection. Exact synthetic regression verifies 13-digit terminal decoration, rejects shorter/longer and interior/repeated bullets as normalization candidates. The specific existing unposted record was separately corrected at user's request with original OCR and audit trail preserved; status remains review and ledger_id null; no model rerun or financial posting. Legacy v21 scan worker is separate and not changed in this 0v PR. Source and runtime Edge deployment not equivalent; verify full CI before release, deploy Edge separately only after verification. No keyboard changes beyond version labels.


## v13.223 — LIVE-BILL-SINGLE-READER-01
User request: one new authoritative reader writes bill facts; existing collection permissions/logic remain independent. CHAT PR #425 adapts the 0v regional guide to the existing inbound worker and shared receipt table; 0v live chat consumes v0_admin_media.bill_receipt only. Remove browser OCR queue, local result preference and all automatic conversation inference; old clients calling the previous conversation Edge path receive 409 before storage/model calls. Keep authorized explicit receipt-id lab preview non-authoritative for now; it does not update ledger or canonical receipt. Existing live media projection and scoped snapshot cache, image blob reuse, grouped galleries, new message sync and financial gates unchanged. The legacy session cache prefix remains only for signout cleanup. No database writes or new permissions. Coordinate CI and deployment of CHAT canonical worker and 0v Edge guard, then publish; no claim of live cutover yet. Historical lab migration to the same reader remains pending. Source inspected: 0v v0_admin_media/admin_bill_audit live definitions and CHAT #425, same bank region rules and 10-field evidence schema. No keyboard geometry change. Classic scripts parse and static no-browser-queue regression added; exact CI/device pending.


### v13.228 — LIVE-MEDIA-SCROLL-07 / explicit follow intent
E0: v13.227 PR #212 exact head 16a8f5a passed both workflows and merged f0e6d4c, but #213 same runtime CI 45850243816 failed growth cycle 1, before top=955 limit=955, after top=955 extent=2373 clientHeight=844. Thus intermittent reflow race remains. E1: live follow is an explicit navigation/jump intent, cancelled by existing wheel/touch/pointer/scroll-key handlers, not inferred from raw scrollTop or coalesced layout extent. Existing scheduled jump frame reconciles tail before publishing scroll state when follow is active and no interaction; covers resize coalescing. No new writer/timer, demo behavior unchanged. Two fixture script-only history scrolls now dispatch explicit wheel intent before scrolling; retain original assertions, three rapid grow/shrink cycles and no-pull tests. Accessibility scroll sources without these input events remain a device test risk; no guarantee of native stability. Read Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894 and Adobe Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1 (layout versus intent); four protected keyboard ranges byte-identical before version update; no financial/DB changes. Exact-head CI and repeat-run evidence pending; rollback v13.227. Bill PR #213 remains separate; do not merge on red CI.


### v13.229 — LIVE-READ-ACK-02 / monotonic confirmed receipt
E0 source inspection: directory response currently replaces rows wholesale and delayed ACK validates against request-start row, not current server-confirmed read marker. A stale response can regress readAt and reintroduce badge. E1: extend existing ReadStateController with pure reconcileLiveReceipt(previous,next), same contact+room and both server capability true only; preserve server-confirmed readAt/count/unread for strictly older marker, retain other fresh directory fields. Equal/newer marker accepts server aggregate; no guessed count, new store, or change to server contiguous-prefix authority. ACK verifies current scoped row and rejects earlier marker. Disabled capability/changed room/removal not retained. New server arrivals concurrent with stale receipt can temporarily leave prior confirmed count until fresh snapshot; equal-marker ordering lacks server revision and remains unresolved; no guarantee for OS Push, oversized-read coverage remains separate READ-API-06 task. Re-read pinned Matrix read-receipt.ts 3da1558b49f40937ee7eabae196d02c0a7ad6659 (separate receipts/order), Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894, Adobe SelectionManager d6ff15c5b5efd7f9be685f87f46c3ed251c093f5 (focus separate from selection). Four protected keyboard ranges byte-identical before version bump. Connector pure tests passed; static audit-design and Chromium pending, no DB/production writes. Rollback v13.228. Prior Bill #213 merged 5a7ca7e after all three CI green; batch synthetic only.


### v13.230 — LIVE-MEDIA-JUMP-01 / one explicit jump transaction
E0 user reports shaking after tapping down arrow. Source inspection: prior click wrote tail before pending prepared media paint; deferred batch, resize observer, focus-tail callback and scheduled frame could write again. Native jitter not independently reproduced. E1: move live click into ScrollController.jumpToLatest, cancel prior geometry/focus-tail intent, drain existing valid prepared image jobs synchronously before establishing tail intent and one clamped positioning write. Pending fetches remain asynchronous; normal follow repairs real geometry changes. Skip redundant live writes at same offset (explicit jump still writes); hide jump while follow active and no user interaction, actual bottom still controls pending count. Pointerdown on arrow with draft focused prevents incidental focus transfer without refocusing; no keyboard owner changes. Existing demo path unchanged, user scroll cancellation retained. Regression synthetic pending ready image + jump: one paint, one scrollTop write, no pending marker, hidden arrow, bottom after 4 frames; retain 3 grow/shrink and user history checks. Source reread Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894, Adobe Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1, TanStack virtual-core 4bd3531db01d98838db8bea9cfd8b5c62568b4c7 (offset reconciliation). No protected keyboard changes; no network/db/finance changes. CI and iOS native momentum/pointer/focus pending; cannot guarantee zero shift for future cold image sizes. Rollback v13.229.


### v13.231 — READ-API-06 / LIVE-READ-ACK-03 shared visible coverage
E0: live adapter requires whole row visible, never qualifies oversized rows; fixture already supports segmented coverage. E1: reuse existing ReadStateController via shared advanceParts and measureParts for fixture/live; live createCoverage tracks only currently loaded eligible UUID incoming rows, same 1000ms dwell/750ms gap, layout and rendered signature invalidation, clears on blur/visibility/navigation, drops removed rows. Clip viewport/header/composer and visual viewport; hit-test three points per segment; no scroll writes. Server v0_admin_mark_seen still authoritative for contiguous prefix and count; no local receipt advancement, no DB/Push changes. Synthetic pure regression passed (skipped middle, revision/layout reset, gap, removal); inline classic scripts parsed in connector; module/full audit-design and browser CI pending. Source reread W3C IntersectionObserver c472c0c13323a2c1bd3a039c586a3dca50adf939 (clipped intersection), Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894, Adobe SelectionManager d6ff15c5b5efd7f9be685f87f46c3ed251c093f5. Four keyboard ranges unchanged. Coverage between sample points, very tall geometry, server capability/native device remain limitations; rollback v13.230. Prior #216 CI and Pages 45858620412 success.


### v13.232 — LIVE-CACHE-MEDIA-01 / preserve confirmed media knowledge
E0 source inspection: text-first partial snapshot inherited knownIds, but final unsuccessful media RPC dropped knownIds; known-empty rows changed fallback/signature and directory hints lost confirmed knowledge. E1 extend existing LiveChatSnapshotPolicy cachedMedia/knowsMedia; intersect prior same-room cache assets and known IDs with current server message IDs, use identical knowledge for partial/final projection and directory preview. A new unknown ID remains unknown; successful media response authoritative, no extension of stale cache TTL, no persistence of failed media as confirmed. No new fetch, retry, storage or notification counter; no change to scroll/keyboard/DB. Pure cases pass for known empty, attached, removed, new, wrong room and partial reuse; full static/browser CI pending. Reread Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894, Adobe Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1, Matrix event-timeline-set 93c6ce4a8151aa3c93c2aef36d22cf3f7341904b (identity-based reuse). Four keyboard ranges unchanged before version bump. Actual remote media changes require successful refresh; Push and same-receipt count ordering remain pending. Rollback v13.231. Prior #217 CI both passed and merged 6ebffd0.


## v13.233 — DurableAlertController pre-effect permit
`authorize(row,input,options)` pure transition; `beginEffect(db,id,input,options)` atomic IndexedDB fixture transaction returns `{row,allowed}`; only `allowed:true` authorizes one attempt, `finish` requires permit. Changed route before effect allows replan with same identity, confirmed read cancels, uncertain never auto-replays. Existing NotificationController remains sole route policy. Production server and service worker pending.


## v13.234 — ScrollController tail frame
`imagePaint` queues late live paints during explicit follow; existing `scheduleJump` drains valid queued paints before clamped tail reconciliation. `renderLiveSnapshot` retains follow even when extent temporarily differs; no additional scroll owner. User away anchor unchanged. Native Safari pending.


## WebKit mobile tail regression (v13.234 test-only)
Existing synthetic live adapter reused with mobile WebKit tap, two late paints and reading-away check. No runtime API change. Physical Safari evidence pending.


## v13.235 candidate — ScrollController follow handoff
Existing jump frame hands queued work to scheduleImagePaint after loss of follow, including no-scroll cancellation. Mobile live scrollport edge bounce disabled where supported. No new owner, native acceptance pending.


## SCROLL-01 target parent contract (migration pending)
ScrollController is sole live intent/position owner; Layout and KeyboardController expose actual visible interval and existing reserves, Message supplies latest identity, MediaController immutable display slots, Realtime/Cache keyed payload only. See RULES.md SCROLL-01a–h; no new owner or claim of completed runtime migration. S0 CI first.


## v13.236 candidate — SCROLL-01 S1a
ScrollController.edgeMetrics(extent,height,rawTop) returns clamped top/max/gap, actual end vs near threshold. intentState and tailPolicy separate passive events from focus; live geometry only schedules existing frame, no recurring focus observer. S1b/CI/native pending.


## SCROLL-01 S1b candidate
ScrollController.beginManual/manualScroll/scheduleManualSettle tracks same-extent movement and quiet settlement; savedPosition and visualEdge expose intent/anchor and physical/visual geometry. Restore uses existing anchor fallback. No keyboard owner edits.


## v13.237 candidate — SCROLL-01 S2a
MediaController.fixedRatios/fixedGallery/fixedImageState reserve display geometry from trusted metadata/default and update stable slot contents only. Existing cache and deferred paint ownership retained; bill/audit path unchanged. S2b and CI/device pending.

- S2b candidate: mediaImageGroup delegates single live bill to MediaController.fixedGallery/fixedImageState; Layout retains paired frame at wide width and fixed portrait reservation at narrow width. Audit path remains separate.

## v13.238 S3a candidate
ScrollController.beginProjection(event,el) / finishProjection(tx,el,alias) owns passive live projection with room/epoch guard and reading anchor; explicitLocalSend owns send intent. ACK alias maps pending to confirmed ID. Cache replay and Realtime do not acquire follow. Browser/native pending.

## v13.239 S3b candidate
ScrollController.normalizeReadingAnchor/anchorCandidates bounds persisted neighbor offsets; restore tries primary and nearby surviving rows. MediaController.reservePart owns fixed attachment frame from declared type. Browser/native pending.

## S4 device diagnostic v13.240 candidate
mountScrollS4 reads ScrollController edge/visualEdge/intentState/writeSerial only; no layout or scroll writes. Local report with bounded sampling, settled 12 frames, no content or IDs; explicit opt-in query and dispose.

## S3d v13.241 candidate
LiveChatSnapshotPolicy.signature excludes only top-level dimension metadata; MediaController fixedRatios accepts dimensions at mount. Bill projection reuses media and prior expansion, ScrollController owns position.

## S3e v13.242 candidate
ScrollController.deferProjection / flushProjection / clearProjection own structural projection handoff; renderLiveSnapshot supplies scoped validity and media signature. Persisted pageshow reuses wakeLiveSync. No new scroll writer.

- SCROLL-01 S4: restore session pause/resume read-only; frameIntervals exclude discontinuous/hidden samples; restoreObserved requires foreground samples; anchor missing reported separately. No new scroll or keyboard owner.

- NOTIFY-01: ReadStateController.liveAck(current,ack,accountId,room) validates scope/count/monotonic receipt and projects confirmed unread only; liveDirectoryCurrent(request,latest,revision,currentRevision) rejects stale snapshot. Adapter owns transport, Contact owns rendering, NotificationController owns alert policy, not count. GEO-MOBILE-01 uses existing geometry owners; RULE-AUDIT-01 requires ownership/regression evidence before new feature acceptance.

- v13.245 candidate COMPOSER-01 #235: stable mobile live composer draft width across focus/blur using existing CSS selector, retain 82% empty and 94% active/nonempty; single/multiline browser regression at 735/390px. Native evidence and full CI pending; branch based on v13.244 candidate 021d25b, must integrate final release head before merge.


## v13.249 SNAPSHOT-01 candidate
LiveChatSnapshotPolicy.callbackIds / canProjectPartial retain scoped verified presentation metadata; no phone in cache. Prewarm complete media inventory + callback ID only. Message structural callback changes use existing ScrollController.deferProjection. Popup/Input/Button unchanged parent; explicit clipboard read on Dán số, manual fallback, defer live background projection while callback form open. All four KB ranges unchanged. Native paste/jitter and persistent image bytes still require acceptance.

## SNAPSHOT-01 S2 candidate
`auditBlobCache.get(key,owner,download,durable=false)` and `.image(key,owner,mime,bill,download,durable=false)` retain RAM dedup; durableImageCache is internal storage tier, not a rendering owner. Chat image only, excludes known bill/audit; storage.info authorization + revision required before read, encrypted bounded IDB; fallback to authorized download. Existing MediaController and ScrollController.imagePaint own projection. Four KB ranges remain unchanged.

## CACHE-LIFECYCLE-01 (v13.251 candidate)
Existing auditBlobCache owns binary reuse, in-flight dedup, max 2 active jobs, scope cancellation and encrypted durable tier for chat/bill/audit/export; renderer paints RAM-ready slots independently. Current snapshot writes dedup for 5 min, full network reconciliation remains. No changes to four protected keyboard ranges.

## CACHE-LIFECYCLE-01 B candidate v13.252
`ThreadDeltaPolicy` validates scoped authoritative revision maps and changed rows; `readDeltaThread` opt-in (`delta=1`) uses existing ChatReadAPI normalization and shares the media inventory. Explicit older button expands window by 20, up to 100. Stored verified snapshots preserve delta revisions; no new viewport/scroll writer. `cachecheck=1` enables aggregate counts and byte estimates via `crmCacheStats()`, no content. IndexedDB expiry sweep on activation and throttled LRU touch. Production SQL not deployed.

## SCROLL-01 S6 — Tail owner v13.253 candidate
ScrollController `edge().max` is the only live end target. `visualEdge()` is measurement only. `flushTailFrame()` drains pending projection (explicit arrow) and prepared media before one reconciliation. ResizeObserver and follow projection request shared frame, never write directly. Same target may retry twice; then release follow and trace conflict. Existing keyboard owners unchanged.

- v13.254 candidate: ScrollController.captureMovingJump owns early press acceptance, not a new scroll writer; auditBlobCache stats extend aggregate metrics, fixed gallery slots resolve independently through existing MediaController/ScrollController.

- S7 follow-up: keep existing jump button as sibling of #messages, isolate scroll root stacking context, center button without transform, touch-action:none only on explicit command. No viewport/overflow toggle, no new writer, same quiet handoff. Browser hit-test at command center plus synthetic both-direction early-event probe; cannot certify native iOS event delivery. Fixed-image audit updated to require per-slot ready/finished-error guards and retry only unresolved slots; existing geometry assertions retained. Avoid repeat error-state paints. Four protected ranges identical; index and bill identical. Exact-head CI and native cache/gesture acceptance pending.


## BANK-NOCLOCK-CURRENT-01 candidate
Existing server recovery owns eligibility and locked financial writer owns posting. BillReceiptProjection consumes verified status/ledger and separately sourced bank clock; raw printed clock remains absent. No client write or parallel owner. Contract proposed only; runtime/read schema unchanged.

- Narrow fallback is a server-only candidate. Use original immutable sent_at, independent verified bank clock, full account, exact substantive memo and global complete competition/consumption checks; existing locked RPC must validate under lock, not a client posting path. Specification fixture: references/bank-noclock-current-fixture.sql; no runtime implementation yet.


## LIVE-BILL-BANK-CLOCK-01
Private admin_media supplies optional bank_clock {source,date,time} from linked financial proof; BillReceiptProjection validates and renders via CardController. Printed time_vn remains original. No client reconciliation/writer, new grant, or duplicate API. Delta/cache consume existing receipt projection, no second fetch.

- v13.256 candidate: ReadStateController.tailReadIds validates a complete bounded unread window for settled visible tail read-through; existing live ACK remains sole server-confirmed projection. warmSnapshotImages calls existing auditBlobCache.image, no new cache/render owner. Native and CI pending.

- CACHE-RESOLVE-01 v13.257 candidate: auditBlobCache.get/image adds optional localOnly; local-only can resolve authorized RAM/IDB or null, foreground retries a joined local miss. durableImageCache owns encrypted IDB preflight/revision, raw cache retains existing byte caps and 256-entry bounds, rotated variants have independent 16 MiB estimated cap. Existing image paint/keyboard untouched. CI/native pending.

- CACHE-RESOLVE-02/03 v13.258 candidate: durableImageCache.batch(paths,owner,room,enabled) scoped short-lived revision proof; auditBlobCache.get/image consume optional proof, storage revision revalidated individually before persistent write. auditBlobCache.display/releaseDisplay lease stable decoded-source URL per screen; revoke on raw retirement+no lease, full scope clear. 24 MiB estimated decoded reference budget. SQL candidate/CI/native pending, metabatch opt-in.

- CACHE-RESOLVE-02b/03b v13.259 candidate: durableImageCache.roomBatch returns a path resolver over room inventory, chunks of 100 and shared short-lived proof; live projection owns context, not galleries. Stats include decode/prepare and image-load/next-frame readiness timings, existing S4 report can export aggregate cache metrics. No new scroll/keyboard/SQL owner; CI/native pending.

- v13.260 CACHE-RESOLVE-04c: durableImageCache.get / auditBlobCache.get/image optional onStage callback; MediaController.fixedImagePhase and fixedImageState own visual-only fixed tile transitions; cachecheck aggregate phases and activeImagePhases. Message.rhythm/flow and ContentAPI.presentation own 10-minute document/short grouping, Typography wrapping; no new geometry or keyboard owner. CI/native pending.

- v13.261 CACHE-RESOLVE-04a: durableImageCache.diagnose(paths,owner,room,valid) reuses sdkRevision tuple normalization and compares bounded read-only metadata. Expose only aggregate window.crmCacheParity() in explicit cacheparity=1 and existing S4 control; no external path arguments, no cache/scroll/keyboard owner change, no default enable. E2/E4 pending.

## v13.262 — RULE-AUDIT-01 / GEO-MOBILE-01 shared initialization candidate
- E0 exact #272 head 315cf8b cache-browser job 140388274217: 24/24 geometry checks no issues in the tested visible primary regions, but all 24 OwnerRuntime and FamilyRegistry calls ReferenceError; public audit functions absent; S4 0/7 controls in registry scope, 6/7 declared. No conclusion that all live geometry or native devices pass.
- E1 move existing pure TableController, Motion, Responsive, State, Theme and frozen OwnerRuntime declarations unchanged to shared boundary before live/demo dispatch. Demo initialization and existing detailed demo diagnostics remain; live explicit apicheck=1 exposes aggregate counts only, no IDs/classes/text or arbitrary element access. FamilyRegistry.auditNodes extends the same audit selector to S4 root/descendants. S4 buttons bind existing Button; native select, details/summary, report, option and container explicitly PROVISIONAL Diagnostic with roles, not fictitious Input profile. No new geometry, keyboard or scroll writer. Other undeclared/provisional nodes remain visible in counts, not suppressed. No production data/auth/SQL or cache policy changes.
- Test: 24 states on Chromium/WebKit, assert OwnerRuntime initialized, no MISSING-PARENT, S4 7/7 included and declared parent, zero geometry issues in existing checks, aggregate-only live diagnostics, wrong-parent negative control. Retain existing demo checks. Seven classic scripts parse, four KB-LOCK ranges byte-identical against v13.261. Sources reread Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894 and Adobe Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1 in preceding audit; reuse existing ownership. RULE-GATE, GEO-MOBILE-01a, RULE-AUDIT-01a, KB-LOCK apply. E2/E3/E4 pending; rollback v13.261. Cache metadata default stays off pending E4.


## QUICK-MESSAGE-01 (v13.263 candidate)
- QUICK-01: QuickMessageAPI owns template registry only; native Popup, Input and Button remain owners of controls. Slash at start opens one existing dialog, selection inserts draft only; never submit or bypass ACK/idempotency. No extra geometry, inset or focus calls. Native keyboard acceptance pending.
- QUICK-02: Template store and explicitly operator-confirmed account settings scoped to current session, not persisted or synchronized; no OCR-derived account, no external QR service. Missing verified settings block STK. QR disabled until real media transport and verified QR source; business templates unavailable until authorized reads. Recheck session, room and original draft before applying. Demo isolated.
- QUICK-03: Validate aliases, reserve business commands, cap templates and body, explicit create/edit/delete, preserve four KB-LOCK ranges. CI fixture only, no real messages or finance writes.

- QUICK-04: Per-tab sessionStorage envelope schema 1 keyed to approved account, validates template and recipient fields at restore, replaces old account envelope, clears on explicit logout. F5 in same session retains templates; never claim durable multi-device persistence. Storage errors degrade to memory only. Demo never uses live envelope. No media or finance mutation.


## v13.264 — LIVE-BILL-FOCUSED-01c
BillReceiptProjection uses 'Chưa xác định từ ảnh' for unestablished printed clock while displaying independent verified bank time separately. No changes to provenance, writes, geometry or keyboard ownership.


## v13.265 — SCROLL-01 S8 / INPUT-UNIFIED contract
ScrollController.jumpVisible({near,visible,moving,following,ready}) is a pure presentation predicate; beginManual hides immediately and shared settle reprojects. Hidden jump button has no early touch capture listener; existing internal pendingJump remains defensive. Native scrollend only schedules existing settle. No geometry/scroll writer change. INPUT-UNIFIED-01–03 proposed child adapters: Input profiles own typing traits; draft transaction owns validated room/session/revision, text selection or attachment operations; DraftMedia remains attachment store, QuickMessageAPI registry only, MediaController validates, Popup menu, KeyboardController exclusively focus/viewport, existing submit owns send/ACK. Phase-specific migration and native validation pending; no new public API yet.


### INPUT-UNIFIED-01a v13.266 candidate
Draft.bind(el,context) creates a text transaction adapter for each current QuickMessage attachment. capture() issues immutable session/room/navigation epoch/revision/original text/selection token. valid() rejects stale tokens, composition, disabled/read-only; insert(token,{text,mode}) uses native setRangeText, exact slash replacement or captured selection, max 8000, consumes successful token and emits one input event; applying guard blocks recursive slash triggers. No focus, resize, viewport, send, media, storage or financial writes. Existing native typing remains owner; no claim that native undo is preserved across programmatic setRangeText. QuickMessage uses adapter for templates and verified STK text only; QR stays blocked. Existing draft restore and send paths unchanged. Attachment migration, profile policy, undo/native E4 and full matrix remain pending.


## MEDIA-DISPLAY-01 — v13.267 candidate (user approved 2026-11-27)
- Preserve each message ID, original asset order, receipt, sender, timestamp and viewer boundary; never merge separate messages or resend them for display. Same-party consecutive ordinary image-only messages in the existing Message.rhythm run receive a compact 3px visual gap. Break on text, mixed media, bill, file, other party, date or existing >10-minute break. Existing 1–4 gallery layout within each original message stays intact.
- Ordinary single image fixed slots: metadata-derived profile (portrait <.85, landscape >1.2, balanced otherwise); portrait width <=260px and reserved height <=420px at bounded existing ratio; balanced <=280px; landscape uses existing <=320px. Single remains contain, full viewer unchanged. Missing metadata uses existing 4:3 fixed fallback, no post-decode dimension correction. Existing paired bank-bill card stays unchanged; long non-bank invoice images use single contain. No transport, DB, cache, scroll writer, keyboard or financial changes. Physical review required; these size caps are initial design choices, not a device measurement.

### BillRoot02Comparison / BILL-ROOT02-UI-01
Parent: BillAuditList, CardController, existing Admin client. baseline(row) projects old server OCR only; valid(data) gates v5 version, one request, no financial action, 10 fields and SHA-256; compare(old,data) returns literal differences, not truth labels. UI uses Button.create, CardController.row, existing ScrollController; results scoped to current session + source and never persisted. API: v0-bill-reader-root02, explicit conversation_id + asset_id only. No new input/popup/keyboard owner.


## MOBILE-CONTENT-01 — v13.269
- Scope mobile <=767px: Message owns A/B and rhythm; Typography/ContentAPI owns wrap and explicit quantity decoration. Incoming short text fits content, outgoing short bubble cap 86% (document cap retained), natural text wrapping without pretty balancing; same-party run gap 6px, turn 12px, existing day/time break unchanged. Original line breaks and IDs remain. Quantity with explicit unit or SL marker uses existing strong semantic node and dotted underline in mobile only; never infer bare numeric codes/amounts.
- Ordinary consecutive image-only messages retain identity, order and viewer. Message.flow projects runs of up to four independent messages, compact 3px within group and normal 6px gap at next group; break on text, bill, sender/day/time boundary. Media parent keeps fixed slots and existing cache/observer; visible connected mobile slots receive a single next-frame wake guarded by existing busy/current scope; idle text not painted, real errors retain retry. No promise of zero cold downloads; measure real warm cache and image readiness separately. No backend, cache policy, scroll writer or keyboard changes. Desktop CSS unchanged; shared metadata additive. E2/E3/E4 pending.

## MOBILE-DIRECTORY-01 — v13.270 / #287
- Live mobile <=767px: Main/Layout owns compact toolbar, horizontal filter overflow (all existing groups remain available), search disclosure and row profile. Contact row 64px, Avatar directory 44px, existing Typography roles, stable 72px time track and full remaining preview track; selected Surface retains separated inset. Initial design values, subject to browser and device evidence. No desktop geometry change, no new parent.
- Contact owns unread display and existing keyed reconciliation. Mobile shows 99+ while preserving full count/accessible label; badge clears via existing read state. If a visible reading anchor is promoted to the top, prefer a stationary visible neighbor using the existing ScrollController.writeLocal; never add another writer. Keep search focus, read state, IDs, sorting and backend unchanged.
- Test both engines 320/375/390/430, long text, stable row geometry, 0/1/123 unread, existing search, filter, realtime and scroll fixtures. Native E4 and direct Pages checks remain separate. Preserve 4 KB-LOCK ranges byte-identical. No financial/SQL/cache policy changes. Rollback v13.269.

## MOBILE-NAV-01 — v13.271 / #289
- Live mobile <=767px: Main keeps existing navigateLive/beginSharedNavigation/finishNavigation and epoch/scope guards. Repeated pending same-room contact activation is ignored; first contact opens latest, visited room uses saved intent (pinned stays latest; history retains reading anchor); send/restore paths remain distinct. Preserve existing cache projection/auth/room drafts, no new cache or auth policy.
- ScrollController captures directory ID+offset plus surviving neighbors only while visible; restores through writeLocal, falls back to saved clamped pixel if no row survives; top stays top. Keep directory position while chat/CRM hides list, including existing account-scoped route sessionStorage; older saved routes remain compatible. No new scroll writer. Back gesture on live mobile requires left edge <=24px, existing axis/media/input guards and shared routeBack; native browser gesture not intercepted. Desktop/demo unchanged.
- Candidate coverage: synthetic anchor reorder/removal both browser runs, Chromium edge/nonedge/vertical and reopen history/draft, existing cache, reload/resume, keyboard and scroll tests. Full 8-case ×4 width matrix and native device acceptance still pending. Keep four KB ranges identical; no backend, ledger, SQL, production writes. Rollback v13.270.

## MOBILE-MEDIA-VIEW-01 — v13.272 / #291
- Live mobile <=767px only: existing MediaController fixed slots retain size and ready identity; quiet RAM/revision/cache/decode/paint/queue labels visually, retain accessible labels and explicit network/error/retry. Do not change cache authorization, download or eviction. Only decoded ready tiles enter the viewer in existing asset order; a late/unready tile is not a wrong-image target.
- MediaController/Popup: widen viewer stage within existing popup viewport; horizontal single touch swipe at fit zoom=1 (48px, axis dominance, <=700ms), no swipe on vertical/pinch/zoom-pan/cancel. Existing buttons, zoom clamp and rotation remain. On close, same-room same-epoch history position restores only through ScrollController and only if not following/interacting; do not add scroll writer or modify KB.
- E1 candidate tests viewer width, navigation, zoom/pan and close room at 320/375/390/430 in both engines; retain existing fixed slot and cache tests. Session cumulative counters are synthetic, not a cold/warm benchmark; isolated cold/warm and native gesture/anchor/device tests remain to be completed. No backend, SQL, ledger or cache policy change. Rollback v13.271.



## MOBILE-POPUP-01 — v13.273
- Mobile <=767px: Popup parent sets explicit level width caps (300/320/360/640px), 12px inset/pad, 8px gap, min 44px button via existing touch token, one Surface edge, existing typography. Content wraps and scrolls; legitimate content/viewport height changes remain allowed. Directory anchor uses popup viewport, callback has reserved caption space. Media stage keeps its gesture/layout owner and existing cache.
- Popup.open optional validated profile directory/menu or callback/form assigned before showModal; PopupController primes its own rect before showing and retains one RAF/listener lifecycle and native close/focus. No new root/focus/scroll/keyboard writer, no new dialog owner or background mutation. Retain same room/draft and current ScrollController/media anchor. Four KB ranges unchanged.
- CI: 32 synthetic live parent cases, 4 widths × 4 levels × Chromium/WebKit; bounds, first/stable geometry, width on content change, touch targets, busy/close/focus, draft and scroll; retain actual directory/callback/viewer regression. Physical Safari/PWA/Android IME and paste/gesture acceptance separate. Rollback v13.272.
