# RULE — CHAT CRM 0v
Nguồn chuẩn cho mọi quy tắc mới của CHAT CRM. Mốc bàn phím: v11.1, commit 8866ef41ffd8e7eb4a97858efd4d23bcaa6bb52e; người dùng phản hồi nhanh, mượt trên Safari. Chưa có phép đo độc lập.

## 01. Quản trị
- GOV-01: Mọi rule mới ghi tại RULES.md của 0v trước hoặc cùng commit triển khai. Không tạo nguồn rule song song cho dự án này.
- GOV-02: Mỗi rule có mã, phạm vi, chủ sở hữu, điều kiện nghiệm thu. Sửa rule phải ghi lịch sử.
- GOV-03: HTML/CSS/JS tĩnh trong index.html; không phụ thuộc app cũ. Chỉ tham khảo nguyên lý.
- GOV-04: Mỗi thay đổi giao diện tăng version hiển thị; phân biệt commit, kiểm tra cú pháp, Pages và nghiệm thu thiết bị.
- GOV-05: Không gửi tin thật, không tạo giao dịch thật, không sửa DB production trong demo.

## 02. Cha–con và hình học
- UI-01: Một thuộc tính hình học chỉ có một owner. Cha quản lý kích thước, lề, gap, typography; con bổ sung nghiệp vụ, không ghi đè tùy tiện.
- UI-02: InputController là cha quản lý focus/blur; input chat, tìm kiếm, chữ, số, tiền, nhiều dòng kế thừa.
- UI-03: Input chữ tối thiểu 16px trên mobile; vùng chạm độc lập tối thiểu 44px; input độc lập bo 12px; không tràn cha. Số căn phải; định dạng tiền là trách nhiệm nghiệp vụ.
- UI-04: Header, nội dung, composer là vùng riêng; ưu tiên diện tích nội dung khi bàn phím mở.

## 03. Bàn phím — khóa hồi quy v11.1
- KB-01: Khung chat ổn định, composer định vị theo phần viewport bị che; không resize toàn app liên tục khi bàn phím chuyển động.
- KB-02: Focus không tự ý dịch chuyển trang. Với input chat trên touch, dùng focus({preventScroll:true}) theo mốc v11.1; kiểm tra caret, chọn chữ và bàn phím thực tế trước khi mở rộng.
- KB-03: Composer phản ứng từ thay đổi viewport đầu tiên; ngưỡng 80px chỉ phân loại trạng thái bàn phím, không trì hoãn vị trí composer.
- KB-04: KeyboardController quản lý inset; composer reserve có một owner; không để nhiều handler tranh quyền.
- KB-05: ScrollController độc lập; FOLLOW_TAIL chỉ khi đang ở cuối, USER_AWAY giữ vị trí đọc. Không render lại hội thoại khi focus/blur.
- KB-06: Không thêm timer/animation để che lỗi hình học. Không quay lại các thử nghiệm v10.2–10.9 nếu chưa có bằng chứng.
- KB-07: Chạm ngoài đóng bàn phím; vuốt đọc tin không chủ động đóng; gửi giữ bàn phím; chuyển màn đóng; giữ draft.
- KB-08: Nghiệm thu Safari trực tiếp, trình duyệt trong ChatGPT, PWA; mở/đóng liên tục, input dài, chuyển input, đọc tin cũ, đổi hướng. Không tuyên bố đạt nếu chưa thử.

## 04. Kiểm thử và lịch sử
- QA-01: E0 tái hiện; E1 patch/test; E2 CI; E3 Pages; E4 thiết bị; E5 chấp nhận. Ghi rõ chưa kiểm tra.
- QA-02: Không sửa lan sang repo chat/taphoaxyz khi nhiệm vụ thuộc 0v.
- 2026-11-24: Khởi tạo nguồn rule 0v, ghi nhận v11.1 và quy tắc mới từ quá trình sửa bàn phím. Các rule lịch sử ở nguồn khác chưa được nhập toàn bộ; khi nhập phải đối chiếu, ghi nguồn và tránh xung đột.

## 05. Hệ thống vùng và token
- UI-05: Shell → panel (danh bạ, hội thoại, công việc) → region → scroll/control → nội dung. Mỗi vùng khai báo owner; vùng con không tự đặt kích thước màn hình.
- UI-06: Token chuẩn hiện có: gap 4/8/12/16px, avatar 40px, icon 22px, nét icon 1.7px, touch 44px. Ngoại lệ phải ghi rõ.
- UI-07: Typography theo vai trò: meta 11, phụ 12, chi tiết 13, nội dung 15, input 16, tiêu đề 17px. Không dùng cỡ chữ tùy ý để chữa tràn.
- UI-08: Header, hàng danh bạ, vùng gõ, popup và bảng phải kiểm tra trục ngang/dọc, lề quang học, baseline, không chồng lấn tại 320/375/390/430/768px và desktop.
- UI-09: Vùng cuộn có min-height:0, min-width:0; chỉ vùng được giao quyền cuộn mới overflow. Không dùng cuộn toàn trang để chữa lỗi bàn phím.
- UI-10: Popup là con của lớp overlay, giới hạn theo viewport; không tự sửa shell. Nút chính/phụ phân cấp theo hành động, icon có nhãn truy cập.
## 06. Bảng nghiệp vụ
- TB-01: Một bảng cha dùng cấu hình cột; cột con có key, nhãn, kiểu dữ liệu, độ rộng và căn lề. Không nhân bản bảng chỉ vì khác số cột.
- TB-02: STT và SL căn giữa; tên trái; đơn giá/thành tiền phải, chữ số tabular. Header và body cùng trục.
- TB-03: Tổng tiền tính từ dữ liệu dòng; footer dùng colspan đúng; không tràn ngang hoặc cắt số. Kiểm tra tên dài và số lớn.
- TB-04: Tổng hợp hàng theo ngày và khách/nhóm, chỉ tên + SL xác định được; không tự suy diễn. Không gộp khác đơn vị.
## 07. Hội thoại và dữ liệu
- CH-01: Tin đến chỉ cập nhật vùng liên quan, danh bạ preview/time/unread; không render lại toàn app, không mất draft/caret.
- CH-02: Đang đọc tin cũ giữ vị trí; mở hội thoại về cuối theo chính sách điều hướng; nút xuống cuối chỉ hiện khi cần.
- CH-03: Media giữ tỷ lệ, không xoay sai, không vượt vùng cha; kiểm tra 1–4 ảnh và ảnh ngang/dọc.
- CH-04: Phân biệt đang mở đúng hội thoại, hội thoại khác, danh bạ và nền/khóa khi thiết kế thông báo; không báo trùng.
## 08. Nghiệm thu rule
- QA-03: Mỗi nhóm UI/TB/CH có kiểm tra hình học và hành vi; kết quả chưa chạy ghi PENDING. Các rule trên là chuẩn triển khai, không khẳng định toàn bộ code hiện tại đã đạt.
- 2026-11-24: Bổ sung UI-05–10, TB-01–04, CH-01–04, QA-03. Giữ nguyên KB v11.1.

## 09. Button cha
- BTN-01: ButtonController phân loại kiểu text/icon/outline/primary, hình tròn/vuông bo góc và trạng thái native; không thay quyền xử lý click nghiệp vụ.
- BTN-02: Token chung touch 44px, icon 22px, stroke 1.7px, radius 12px; nút compact chỉ là ngoại lệ có chủ đích, không ép hàng danh bạ hoặc chip thành nút vuông.
- BTN-03: Nút icon có tên truy cập; disabled không kích hoạt; focus-visible rõ; aria-pressed chỉ dùng cho toggle.
- BTN-04: Nút tạo động và nút HTML tĩnh cùng đăng ký cha; không thay focus/blur, không render lại vùng gõ. Kiểm tra Safari và popup trước nghiệm thu.

## 10. Icon cha
- IC-01: Icon điều khiển SVG dùng token 22px, nét 1.7px, currentColor, đầu nét tròn; icon nhỏ 20px chỉ khi có vai trò riêng.
- IC-02: Icon cha quản lý hình học SVG; Button cha quản lý vùng chạm; vùng cha quản lý vị trí và gap 8px với chữ. Không ép SVG minh họa, bill, QR, ảnh vào icon.
- IC-03: Icon trang trí trong nút có aria-hidden; nút phải có tên truy cập độc lập. Không thay đổi viewBox/path để chữa lệch tâm tùy tiện.
- IC-04: Kiểm tra icon header, composer, danh bạ, công việc, popup, nút xuống cuối; không đổi hành vi focus/scroll. Nghiệm thu thiết bị riêng.

## 11. Popup cha
- POP-01: PopupController sở hữu mở/đóng, viewport riêng và vòng đời dialog; không ghi kích thước shell hoặc inset composer.
- POP-02: Dialog native modal, một popup hoạt động tại một thời điểm; đóng bằng nút hoặc Escape; giữ cơ chế focus native, không tự mở lại bàn phím.
- POP-03: Popup cách mép visual viewport tối thiểu 12px khi đủ chỗ; nội dung dài cuộn bên trong; ảnh contain, nút chạm 44px.
- POP-04: Dọn listener và tài nguyên ảnh khi đóng; popup input, menu và xác nhận tương lai kế thừa cha; kiểm tra Safari/PWA khi bàn phím mở, đóng, xoay màn hình. Không tuyên bố đã nghiệm thu nếu chưa chạy.

## 12. Media cha
- MED-01: MediaController quản lý nhóm 1–4 ảnh, tỷ lệ gốc và phân loại ngang/dọc/vuông; ảnh đơn contain, nhóm nhiều ảnh có thể crop thumbnail, xem đầy đủ trong popup.
- MED-02: Grid cha gap 4px, không chồng lấn; hai ảnh dọc chia đều, ba ảnh có ảnh dọc đầu dùng bố cục portrait-lead; không thay đổi kích thước shell.
- MED-03: Xoay ảnh xem trước bằng canvas từ ảnh gốc, đổi chiều rộng/cao theo góc; không sửa file gốc; giải phóng URL khi đóng.
- MED-04: Giữ 120 tổ hợp mẫu để kiểm tra hình học; decode bất đồng bộ; không tải ảnh thật lên mạng; kiểm tra ảnh lớn, ảnh lỗi và Safari/PWA trước nghiệm thu.

## 13. Card cha
- CARD-01: CardController sở hữu khung, header, row, footer; TableController sở hữu bảng bên trong; dữ liệu nghiệp vụ không sở hữu CSS.
- CARD-02: Card không vượt cha, min-width:0, radius 12px, border token; header/body/footer cùng trục; số căn phải, tên trường trái, không ép nút căn phải.
- CARD-03: Bill đối chiếu hai cột giữ layout chuyên biệt hiện có; ghi chú và thao tác không đổi trạng thái giao dịch thật; không thay quy tắc OCR/đối soát khi refactor UI.
- CARD-04: Kiểm tra card đơn, cặp bill, tên dài, số lớn, bảng tổng tiền và thao tác; giữ nguyên bàn phím; ghi PENDING nếu chưa nghiệm thu thiết bị.

## 14. Rà soát tích hợp
- QA-04: Kiểm tra owner CSS và thứ tự khởi tạo controller; icon thêm động phải đăng ký lại nút cha; ảnh nguồn phải decode trước khi xoay. Không xóa CSS fallback chưa có bằng chứng. Tách kiểm tra cú pháp khỏi runtime và thiết bị.
- 2026-11-24: v11.8 loại hai khai báo icon trùng, bổ sung đăng ký SVG động và bảo vệ xoay ảnh thật; giữ nguyên KeyboardController.

- QA-05: Rà soát cascade theo selector, phạm vi media và thứ tự; chỉ bỏ khai báo lặp khi có khai báo tương đương còn hiệu lực. Không gộp các override responsive hoặc bàn phím khi chưa kiểm thử computed style.
- 2026-11-24: v11.9 dọn 4 nhóm CSS lặp ngoài bàn phím; chưa kiểm thử computed style trên thiết bị.

## 15. Bảng mã màu cha
- COL-01: Light theme trung tính: paper #ffffff, ink #0d0d0d, muted #676767, line #e5e5e5, soft #f5f5f5, selected #f0f0f0, pressed #e8e8e8.
- COL-02: Avatar #ededed / #404040; hành động chính #171717; input border #dedede; header #fafafa. Thành phần dùng token semantic, không tự đặt mã màu.
- COL-03: Màu nghiệp vụ lỗi #b42318 giữ riêng; không đổi màu ảnh/bill gốc; trạng thái phải có chữ hoặc icon, không chỉ dựa vào màu.
- COL-04: Bảng màu lấy cảm hứng từ ảnh so sánh ChatGPT, không khẳng định mã chính thức; kiểm tra tương phản và thiết bị trước nghiệm thu. Không đổi hình học hoặc bàn phím khi chỉnh màu.

- COL-05: Hover chỉ cho thiết bị có hover và pointer fine; pressed dùng token riêng; nút chính hover #303030, pressed #404040; disabled không nhận hover/pressed. Không thêm animation hoặc đổi hình học.
- COL-06: Focus ring #737373; giữ cơ chế focus hiện tại; kiểm tra trạng thái chọn, nhấn, khóa và tương phản trên thiết bị. v12.1 bỏ opacity disabled cũ bị ghi đè.

## 16. Bề mặt và viền
- SUR-01: Viền điều khiển dùng rgba(0,0,0,.15), viền phụ .09; bóng nhẹ và highlight trong dùng token chung. Không tăng độ dày viền hoặc thay kích thước để tạo hiệu ứng.
- SUR-02: Composer dùng bóng nhẹ tĩnh, nền đặc; không blur vùng gõ hoặc shell trong lúc bàn phím chuyển động. Nút icon thường không đổ bóng hàng loạt.
- SUR-03: Popup thường có thể dùng nền bán trong suốt và backdrop-filter 12px khi hỗ trợ; fallback nền đặc. Popup ảnh giữ nền đặc. Không khẳng định giống native iOS tuyệt đối.
- SUR-04: Kiểm tra viền, góc, lề quang học và tốc độ Safari/PWA; không đổi focus/scroll/keyboard khi chỉ chỉnh bề mặt.

## 17. Hình học quang học
- OPT-01: Composer radius 29px, inset 6px, nút tròn 44px, viền 1px; tâm nút và đường cong cha đồng tâm ở chiều cao tối thiểu 58px. Lề ngoài 8px.
- OPT-02: Textarea giữ line-height 22px, padding dọc 11px, ngang 6px; icon căn tâm, không dùng translate để chữa lệch. Không đổi KeyboardController; kiểm tra reserve và bàn phím sau đổi chiều cao.

## 18. Glass cha
- GL-01: Material CSS data-glass: G0 đặc cho nghiệp vụ/ảnh; G1 phản chiếu viền và gradient đặc cho composer; G2 kính mờ cho popup thường. Không gọi G2 là khúc xạ thật.
- GL-02: Viền gradient dùng background-clip, bóng trong/ngoài token chung; không thêm lớp chặn thao tác hoặc đổi hình học.
- GL-03: Không WebGL, SVG displacement hay blur composer; fallback nền đặc khi giảm trong suốt; giữ KeyboardController. Nghiệm thu Safari trước mở rộng sang header.

- GL-04: v12.5 mở rộng viền kính CSS tĩnh sang nút header, input tìm kiếm, input độc lập và nút outline; không thay kích thước. Kiểm tra computed style bằng glasscheck; Pages và Safari thực tế vẫn cần xác nhận.

- GL-05: v12.6 thay hai khối glass cũ bằng một owner; viền quang học inset .5px, bóng mềm, bề mặt radial gradient; selector header bao gồm nút lồng nhau. Không blur composer; không đổi kích thước. Chưa xác minh nguồn ngoài, render Safari hoặc Pages.

- GL-06: v12.7 tách lớp viền phản sáng bằng mask .65px, tint bán trong, bóng mềm; tất cả button trong header cùng vật liệu, không blur composer. Tham khảo gentpan/liquidglass lib/components.js và Nordify README, không nhập engine khúc xạ. Kiểm tra pseudo-element không chặn thao tác; Safari thực tế còn pending.

- GL-07: v12.8 hiệu chỉnh mask viền .75px và tương phản phản sáng; chưa đạt native, không tuyên bố khúc xạ.
- QA-04: Nút mô phỏng typing chỉ tồn tại trên header khi có typingtest; nút mô phỏng danh bạ hidden ngay HTML, chỉ mở trong chế độ test. F5 mặc định không lộ công cụ thử.

- GL-08: v12.9 thử upstream MIT lucaperullo/simple-liquid-glass 6.0.0 qua CDN khóa phiên bản, API theo docs/frameworks/vanilla.md. Chỉ tải khi glasslab=1, nền văn bản giả, không đưa capture vào hội thoại thật. Không chỉnh engine hoặc composer; GL-03 tiếp tục áp dụng cho giao diện chính. CDN, khúc xạ và Safari chưa nghiệm thu.

- GL-09: v13.0 dùng Surface export nguyên bản gentpan/liquidglass (MIT, lib/components.js blob 47871d955f37324d654cef8ad3dacde59a8f91ff) và bộ optics LgButton nguyên bản cho nút icon header thực, giữ native button và hit target. Module hosted theo README, chưa khóa revision; lỗi tải giữ CSS cũ. Safari arbitrary DOM chỉ blur theo upstream. Không áp dụng vào composer; GL-03 giữ nguyên. Kiểm thử module, Pages, Safari còn pending.

- GL-10: v13.1 mặc định chỉ dùng CSS có sẵn trước first paint; Surface upstream chỉ bật bằng upstreamglass=1 để tránh đổi vật liệu sau tải. Nút/input tĩnh khai báo metadata cha ngay HTML, không chờ JS. Không đổi keyboard; kiểm tra F5 liên tục Safari còn pending.

## Apple Design — nguồn chuẩn tham chiếu, 2026-11-24
- APP-01: WWDC25 Meet Liquid Glass, https://developer.apple.com/videos/play/wwdc2025/219/ (đã đọc transcript): điều khiển thuộc lớp chức năng nổi, nội dung thuộc lớp riêng; hình cong lồng đồng tâm.
- APP-02: Cùng nguồn, chương Adaptivity: duy trì độ đọc khi nền thay đổi, chuyển tiếp mép cuộn mềm, bóng thích ứng.
- APP-03: Cùng nguồn, chương Principles: tránh kính chồng kính; bảng và danh sách thuộc content layer; ưu tiên Regular, Clear chỉ trong bối cảnh media thích hợp; hạn chế tint.
- APP-04: Cùng nguồn: phản hồi chạm tại thành phần; hỗ trợ giảm trong suốt, tăng tương phản và giảm chuyển động.
- APP-05: HIG Materials https://developer.apple.com/design/human-interface-guidelines/materials và Scroll views https://developer.apple.com/design/human-interface-guidelines/scroll-views là nguồn cần đọc bổ sung; lần này trang yêu cầu JS, chưa xác minh nội dung.
- FL-01: Web prototype v13.2: floating=1 mở lớp composer tuyệt đối trên vùng cuộn; nền frame trong; padding cuối nội dung dùng reserve hiện có. Không chuyển quyền keyboard.
- FL-02: Chỉ composer cha có blur trong chế độ thử; nút con không thêm kính; nền đặc khi giảm trong suốt. Blur 14px/tint .82 là lựa chọn web thử nghiệm, không phải thông số Apple. Ngoại lệ GL-03 chỉ ở floating=1.
- FL-03: Nghiệm thu idle, scroll, focus, press, F5, input nhiều dòng, cuối hội thoại, nút xuống cuối, Safari/PWA. G47/G48 chuyển sang kiểm tra overlay và reserve ở chế độ floating. Chưa nghiệm thu thiết bị; không bật mặc định trước khi đạt.

## 19. Floating Input v13.3 — ngoại lệ thử nghiệm, chưa phát hành mặc định
- APP-06: Đã đọc transcript WWDC25 Get to know the new design system, https://developer.apple.com/videos/play/wwdc2025/356/?time=726 ; scroll edge mềm phù hợp input, không xếp nhiều hiệu ứng; chỉ dùng tại mép giao nội dung với điều khiển nổi. Meet Liquid Glass https://developer.apple.com/videos/play/wwdc2025/219/ xác nhận phân lớp, tránh glass-on-glass và ưu tiên khả năng đọc.
- FL-04: Một owner vùng gõ: frame trong suốt và không chặn chạm; một composer cha có backdrop-filter 14px nếu trình duyệt hỗ trợ, không blur toàn shell hoặc nút con. Mép chuyển tiếp gradient nhẹ, không có listener scroll để đổi vật liệu. Mức tint .70 idle / .80 focus là lựa chọn web thử nghiệm, không phải thông số Apple; fallback nền đặc nếu không hỗ trợ, giảm trong suốt hoặc tăng tương phản.
- FL-05: Controller bàn phím hiện có sở hữu keyboard inset; selector floating không được ghi đè đáy khi bàn phím mở. Reserve lấy chiều cao frame thực, chỉ ghi khi thay đổi, giữ tin cuối nếu đang ở cuối và không đang cuộn; không kéo xuống khi đang đọc lịch sử.
- FL-06: G08 bỏ duy nhất cặp overlap có chủ ý (chat-view / composer-frame) khi floating; G47 kiểm đáy vùng cuộn cùng đáy frame, G48 reserve >= frame + 12px; G74 tin cuối không bị che, G75 nút xuống cuối không bị che. A06 và dynamic dùng cùng hợp đồng, S19–S21 kiểm tra reserve và vị trí ở cuối. Không đổi chuẩn non-floating.
- FL-07: Giữ chế độ opt-in floating=1 đến khi nghiệm thu Safari iPhone/PWA: idle, cuộn qua chữ/ảnh, nhấn, focus/blur, nhập 1–6 dòng, bàn phím mở/đóng, F5 liên tục, mở hội thoại và xem tin cuối. Kiểm tra thêm web desktop và fallback; không tuyên bố CSS blur là native lensing.
- 2026-11-24: v13.3 cập nhật index.html, kiểm tra cú pháp 5 script classic; module upstream không sửa. Chưa chạy runtime QA, CI/Pages hoặc thiết bị thật. Chỉ dữ liệu demo, không ảnh hưởng CHAT production. FL-04–07 bổ sung/ghi đè lựa chọn thử nghiệm FL-02–03; các quy tắc giao diện ổn định GL-03 và SUR-02 không đổi.

## 20. Floating Input v13.4 — ổn định vị trí và first paint
- FL-08: Reserve trước first paint dùng 58px desktop, 74px mobile, tính safe-area cho PWA standalone; ResizeObserver thay bằng chiều cao thực. Không dùng lớp kính tải sau hoặc animation hình học. Nút con chỉ phản hồi pressed bằng token màu, không thêm lớp blur.
- FL-09: Ở floating mobile, KeyboardController tính inset từ đáy visualViewport thực; khi blur mà bàn phím còn che, không ép inset về 0. Reset baseline khi chiều rộng thay đổi trên 32px (heuristic thử nghiệm). Không sửa chế độ non-floating.
- FL-10: Người dùng chạm/cuộn có quyền ưu tiên; wheel/pointerdown/touchmove hủy lệnh kéo cuối đang chờ; cả lúc xếp lịch lẫn khi thực thi đều kiểm tra trạng thái cuộn. Không tự kéo lịch sử.
- FL-11: E2 debug công nhận lớp nổi có chủ ý nếu reserve và đáy khớp; bổ sung S22–S24 kiểm tra đọc lịch sử khi input dài, giới hạn cao và tin cuối sau thu input. Không gọi kiểm tra cú pháp là runtime.
- 2026-11-24: v13.4 kiểm tra 5 script classic và 7/7 trường hợp logic thuần floatingViewportGeometry (idle, keyboard, blur, closing intermediate, closed, rotation, viewport offset). Pages không truy cập được từ môi trường kiểm tra; F5, scenario S22–S24, iPhone Safari/PWA, CI/Pages còn PENDING. Floating vẫn opt-in, không ảnh hưởng production.

## 21. Input cha — v13.5, chuẩn kích thước tham chiếu iOS
- IN-IOS-01 (Apple): https://developer.apple.com/design/human-interface-guidelines/typography — Body Regular 17pt, line height 22pt ở mức mặc định. https://developer.apple.com/design/human-interface-guidelines/accessibility — vùng chạm mặc định khuyến nghị 44×44pt trên iOS/iPadOS. https://developer.apple.com/design/human-interface-guidelines/text-fields và https://developer.apple.com/design/human-interface-guidelines/text-views — chiều rộng theo nội dung và text view nhiều dòng có thể cuộn.
- IN-IOS-02 (web tham chiếu): https://v7.framework7.io/docs/css-variables (iOS input 44px / font 17px), https://v8.framework7.io/docs/messagebar (iOS messagebar 44px / font 17px), https://framework7.io/docs/searchbar (iOS searchbar 44px / font 17px). Dự án nguồn https://github.com/framework7io/framework7; dùng thông số từ tài liệu công khai, chưa đọc được file LESS trên GitHub. Không chép engine. https://github.com/nathantannar4/InputBarAccessoryView tham khảo kiến trúc UITextView tự tăng chiều cao, không khẳng định giá trị padding theo thư viện.
- IN-IOS-03 (quyết định web nội bộ): 17 CSS px / line-height 22px, font system, input 44px, padding dọc (44−22)/2=11px; khi viền 1px trừ 1px mỗi phía. Không coi CSS px là pixel vật lý hoặc kích thước UIKit chính xác; chưa hỗ trợ đầy đủ Dynamic Type.
- IN-IOS-04: input chat 44/66/88/110/132px cho 1–5 dòng hiển thị, từ dòng 6 cuộn trong. Composer cha = input + 2×6px + 2×1px = 58/80/102/124/146px; radius cha lúc một dòng =29px; nút 44px. Search 44px/radius22px; text/number standalone 44px/radius12px; multiline nghiệp vụ mặc định 110px. Radius, padding, giới hạn dòng là lựa chọn thiết kế nội bộ, không phải quy định bắt buộc Apple.
- IN-IOS-05: Cha quy định rộng theo vùng: input width 100%, min-width 0, max-width 100%; composer max 760px, 2 nút 44px, gap 4px; chỉ vùng chữ co giãn. Không dùng kích thước theo độ phân giải ảnh chụp.
- IN-IOS-06: CSS tokens là nguồn duy nhất cho min/max, font và line height; JS đo chiều rộng/typography/wrapping thực và đọc computed min/max, không gắn cứng 44/132. Input động phải khai báo metadata ngay khi tạo. A11/A12 kiểm tra font, line-height, kích thước; S05 kiểm tra 3 dòng, S23 theo giới hạn computed style.
- 2026-11-24: đã commit index.html v13.5, cú pháp 5/5 classic scripts; bảng chiều cao tính theo công thức, chưa đo runtime Safari/PWA, CI/Pages chưa xác nhận. Không đổi KeyboardController hoặc mặc định floating. IN-IOS-03–06 thay thế kích thước input trùng trong các rule trước nếu khác nhau.

## 22. Input cha v13.6 — vòng kiểm tra tích hợp
- IN-IOS-07: vùng chat mobile giới hạn input theo visualViewport: dành chỗ header thực, 30px khung/padding ước tính và 96px nội dung; làm tròn theo line-height, 1–5 dòng, tối thiểu 44px. 30/96 là ngân sách web thử nghiệm, không phải Apple HIG; ở viewport cực thấp vẫn ưu tiên input tối thiểu, cần nghiệm thu.
- KB-16: tách keyboardOpen (ngưỡng 80px cho trạng thái hiển thị) khỏi keyboardOccluding (giữ đến khi inset <=1px); áp dụng nhánh floating mobile. Chuỗi mô phỏng 844→510→510 blur→790→810→844 cho inset 0→334→334→54→34→0. Chế độ ổn định chưa đổi thuật toán inset.
- SC-16: ScrollController là nơi duy nhất ghi scrollTop trong luồng sử dụng thông thường; lý do navigation/send/jump/incoming/geometry. Geometry tôn trọng touch, navigation và cuộn gần đây; kịch bản QA có quyền đặt vị trí trực tiếp. Chưa nghiệm thu các đua sự kiện thực tế.
- IN-IOS-08: giữ viền focus mảnh ở search và focus-visible ở composer; footer thêm danh bạ ẩn khi bàn phím mở trong danh bạ; nút thêm danh bạ mở dialog thông báo chưa kết nối, không giả làm search; đóng search khôi phục placeholder. Không can thiệp thanh phụ bàn phím native Safari.
- IN-IOS-09: inputlab=1 chỉ đổi nội dung Công việc thành mẫu cục bộ: chữ, số lượng 0–999999 với nút +/- và bàn phím numeric, tiền VND có phân nhóm, ghi chú nhiều dòng. Không lưu, không tạo đơn. InputController giữ semantic quantity/money. A11/A12 đọc token/computed style; S05 theo giới hạn thích ứng. Không tuyên bố đã hỗ trợ Dynamic Type.
- 2026-11-24: v13.6 commit index.html, 5/5 script classic parse; chuỗi 6 bước keyboard và 5 chiều cao input mô phỏng đạt. Chưa chạy browser runtime/CI/Pages/iPhone/PWA. Floating vẫn opt-in. Glass CSS không thay đổi; không có refactor engine kính, không tác động production.

## 23. APP-SHELL — v13.7, ưu tiên tỷ lệ ChatGPT iOS App
- APP-SHELL-01: Ảnh đối chiếu 832px rộng: composer CRM khoảng 796×110 pixel ảnh; ChatGPT iOS khoảng 684×95, lề 74 mỗi bên. Tỷ lệ rộng mục tiêu 82%, cao một dòng khoảng 48 CSS px theo phép quy đổi gần đúng; đây là đo ảnh, không phải thông số Apple hay mã nội bộ ChatGPT. Không tính thanh Safari vào bố cục app.
- APP-SHELL-02: mobile có một vùng nội dung cuộn liên tục; header và composer là lớp chức năng nổi, không chiếm hai track grid riêng. Reserve đầu bằng safe-area-top +52px +12px; reserve cuối bằng frame thực +12px; không che tin đầu/cuối. Header không có đường phân cách; gradient nhẹ, không chặn chạm xuyên qua vùng trống.
- APP-SHELL-03: composer rộng 82%, giữa, min-height 48px = 44px input + 2×1px padding + 2×1px border. Nút vẫn có hit target 44px. Lề mỗi bên 9%; đáy tính riêng safe-area và keyboard. Không đổi font 17/22, nội dung bill, nghiệp vụ, icon hoặc thiết kế màu ở vòng này. Tỷ lệ vùng cha trước, chi tiết con sau.
- APP-SHELL-04: demo mobile mặc định floating ở first paint; floating=0 giữ bố cục cũ để đối chiếu; desktop mặc định cũ. Không áp dụng CHAT production. G76–G79, A13–A16, E2 và G08 kiểm tra lớp nổi, reserve và tỷ lệ; không đánh dấu overlap chủ ý là lỗi.
- 2026-11-24: v13.7 commit, 5/5 classic script parse; tính lý thuyết kích thước tại 320/375/390/416/430 CSS px. Chưa đo browser runtime, CI, Pages, Safari/PWA, F5, keyboard thực tế. Chưa khẳng định giống 100%; các kích thước con sẽ đánh giá sau khi chốt shell.

## 24. APP-DETAIL — v13.8, tỷ lệ con trong khung ChatGPT iOS
- APP-DETAIL-01: giữ vùng cha v13.7: composer 82%, một dòng 48 CSS px, header và composer nổi; không sửa luồng bàn phím/scroll hay nghiệp vụ bill ở vòng này.
- APP-DETAIL-02: phân biệt vùng chạm và mặt nút: gửi 44×44 hit target, mặt 32×32, inset 6px; icon gửi 20px, icon thêm 22px; nút xuống cuối 44×44, mặt 36×36 (inset 4px), cách vùng gõ theo token 12px. Trạng thái disabled/pressed chỉ đổi màu mặt, không đổi kích thước. Đây là đo gần đúng từ ảnh đối chiếu, không phải đặc tả nội bộ ChatGPT.
- APP-DETAIL-03: header giữ đủ back/avatar/tên/vai trò/công việc, avatar 32px, tên 16/20px, vai trò 12/15px; lề header 20px (12px khi màn hình <=360px); lề nội dung 16px (12px khi <=360px). Nội dung tin nhắn 17px/1.55, composer 17/22px; nền hội thoại #f8f8f8 là màu tham chiếu gần đúng. Không sửa font riêng của thẻ nghiệp vụ.
- APP-DETAIL-04: A17–A19 và G80–G83 kiểm tra vùng chạm, mặt nút và trục đáy; v13.8 parse 5/5 classic scripts, tính hình học ở 320/375/390/416/430px. Chưa chạy browser runtime, CI/Pages, Safari/PWA; không khẳng định giống native 100%. Mobile demo floating mặc định, floating=0 đối chiếu, desktop không đổi.
