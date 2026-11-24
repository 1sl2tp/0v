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
