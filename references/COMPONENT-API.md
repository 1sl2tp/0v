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
