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
