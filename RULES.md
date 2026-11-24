# RULE — CHAT CRM 0v
Nguồn chuẩn cho mọi quy tắc mới của CHAT CRM. Mốc bàn phím: v11.1, commit 8866ef41ffd8e7eb4a97858efd4d23bcaa6bb52e; người dùng phản hồi nhanh, mượt trên Safari. Chưa có phép đo độc lập.

## 00. Chỉ mục rule đang có hiệu lực (v13.21)
Đọc theo owner và phạm vi, không theo thứ tự xuất hiện của CSS hoặc số version. Bảng dưới là nguồn lựa chọn rule hiện hành; các mục cũ có số liệu khác chỉ lưu lịch sử, không dùng để tạo CSS mới. Không áp dụng đồng thời hai rule thay thế nhau.

| Owner | Quy tắc hiện hành | Quy tắc lịch sử bị thay thế trong phạm vi tương ứng |
|---|---|---|
| Typography | TYPE-01–03 | số liệu font trong UI-07 cũ, APP-DETAIL-03, APP-RHYTHM-02, DESKTOP-03 |
| Composer geometry | COMP-01–04, BOTTOM-01–02, APP-SHELL-03 | OPT-01–02 và BOTTOM-03 cũ về chiều cao nhiều dòng; IN-IOS-04 giới hạn cũ chỉ giữ cho textarea |
| Keyboard / viewport | KB-01–08, VP-SAFE-01, KB-RESTORE-01–02 | KB-APP-02/05 bridge 120/180ms; lề theo data-keyboard trong rule cũ |
| Scroll | KB-05, SC-16, FL-10, KB-RESTORE-02 | các ghi scroll trực tiếp ngoài controller (trừ QA) |
| Material / edge | SURFACE-CONTEXT-01–04, SURFACE-01–02 (cấu trúc chung) | SUR-01–03, GL-01–08 và SURFACE-03 về lựa chọn vật liệu |
| Desktop layout | DESKTOP-01–04 | chiều rộng cột desktop trước v13.18 |
| Bill layout | GEO-ADAPT-01 | CARD-03 cũ bắt buộc hai cột |
| Geometry QA | GEO-ADAPT-03, DESKTOP-04, BOTTOM-04, COMP-04 | phép đo chỉ hợp với composer một hàng |
Các rule nghiệp vụ, bảo mật, thao tác không bị thay thế nếu không được nêu rõ. Khi sửa một owner, phải đối chiếu các owner khác và ghi kết quả chưa kiểm chứng.

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
- UI-07: Typography theo vai trò, lấy giá trị hiện hành tại TYPE-01–03. Không dùng cỡ chữ tùy ý để chữa tràn.
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
- CARD-03: Bill đối chiếu thích ứng một hoặc hai cột theo GEO-ADAPT-01; ghi chú và thao tác không đổi trạng thái giao dịch thật; không thay quy tắc OCR/đối soát khi refactor UI.
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
- QA-06: Nút mô phỏng typing chỉ tồn tại trên header khi có typingtest; nút mô phỏng danh bạ hidden ngay HTML, chỉ mở trong chế độ test. F5 mặc định không lộ công cụ thử.

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

## 25. KB-APP — v13.9, chống hồi quy lúc thoát input
- KB-APP-01: Phát hiện hồi quy v13.7–13.8: lề dưới frame phụ thuộc data-keyboard ngưỡng 80px (Safari 6→8px, PWA 0→safe-area), gây thay đổi chiều cao đồng thời với inset. Bỏ switch hình học đó trong app-shell. Safari giữ 8px; PWA dùng max(8px, safe-area-bottom − inset) để tránh nhảy bậc do trạng thái. Không đổi kích thước 82% / 48px / 32px của v13.8.
- KB-APP-02: VisualViewport vẫn là nguồn vị trí. Chỉ khi đang đóng mà viewport mở rộng đột ngột hơn 48px, dùng bridge tối đa 120ms (ease-out), không vượt đáy viewport thực; khi mở bàn phím/đảo chiều hoặc reduced-motion, theo viewport ngay. Đây là heuristic web nội bộ, không phải animation native Apple; cần đo trên thiết bị để loại trừ độ trễ.
- KB-APP-03: Khi closing giữ giới hạn chiều cao nhiều dòng đến khi hết che khuất và hết bridge. Giữ snapshot cuộn đến cuối closing; ResizeObserver và resizeDraft app-shell chuyển yêu cầu cuộn về viewport controller thay vì ghi vị trí trực tiếp. Người dùng cuộn vẫn được ưu tiên.
- KB-APP-04: Kiểm tra thoát bằng chạm ngoài, nút Done Safari, chuyển focus, nhập nhiều dòng, mở lại ngay, PWA safe-area, reduced-motion, F5. Debug hiển thị keyboard occluding/closing bridge. 5/5 classic scripts parse và 5/5 mô phỏng hàm closingBottomStep (bước lớn, bước nhỏ, mở, giảm chuyển động, đảo chiều). Chưa chạy runtime Safari/PWA, chưa xác nhận Pages; không coi mô phỏng là nghiệm thu thực tế. Chỉ sửa demo 0v.

## 26. IN-EDGE / KB-APP — v13.10–v13.11
- IN-EDGE-01: ảnh iPhone xác nhận composer có viền focus dày chồng viền glass. Một owner cho chat/search/standalone: border 1px, đổi màu khi focus, bỏ outline ngoài và masked rim riêng của composer, bỏ inset ring trùng của search/standalone. Focus keyboard của nút con vẫn giữ; forced-colors có ngoại lệ outline trong. Giữ nguyên kích thước và blur. A20/A21 đo viền/outline. v13.10 parse 5/5, chưa nghiệm thu Safari.
- KB-APP-05: v13.9 bridge thay đổi inset/margin từng frame gây layout lặp và có thể bỏ lỡ trường hợp viewport tăng trước blur. v13.11 thay bằng cập nhật layout theo visualViewport thực, không tạo vòng viewport nhân tạo. Nếu có bước tăng >48px trong phiên bàn phím hoặc animation đang chạy, lấy vị trí frame đang vẽ trước commit, rồi dùng Web Animations translate từ chênh lệch về 0 trong 180ms. Nút xuống cuối đi cùng nếu hiện. Hủy/retarget khi viewport đổi hướng, focus lại, chuyển màn hình hoặc xoay; reduced-motion không bù chuyển động. Đây là heuristic web, không bảo đảm đồng bộ native; nếu WAAPI không hỗ trợ, theo viewport thật.
- KB-APP-06: 5/5 classic script parse và 9/9 kiểm thử hàm quyết định bridge (blur trước, resize trước blur, bước nhỏ, retarget, mở, xoay, reduced-motion, resize không có focus, frame đầu). Chưa đo độ mượt, compositor, keyboard native hoặc runtime Safari/PWA/Pages. Không tăng version production, giữ tỷ lệ v13.8. Debug đo vị trí hiển thị có thể ghi nhận khoảng hở trong 180ms bù chuyển động; không gọi đây là lỗi hình học ổn định.

## 27. EDGE-APP — v13.12, safe-area và PWA standalone
- EDGE-01: WebKit https://webkit.org/blog/7929/designing-websites-for-iphone-x/ và Apple https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html : viewport-fit=cover, safe-area-inset, standalone, status-bar black-translucent. Nền/nội dung cuộn có thể chạy dưới vùng hệ thống nếu WebKit cấp viewport; nút và composer nằm trong safe area.
- EDGE-02: Demo 0v có manifest.webmanifest (scope/start_url tương đối ./, display standalone), apple-mobile-web-app-capable=yes, status-bar black-translucent, theme/background #f8f8f8. Không thêm service worker/cache hoặc icon tùy chỉnh ở vòng này. Không thể ép Safari bỏ thanh địa chỉ hoặc vẽ ngoài viewport hệ thống.
- EDGE-03: Không đổi KeyboardController, ScrollController, tỷ lệ 82%/48px, viền input. Không cộng screen.height hoặc safe-area vào viewport giả. edgecheck=1 chỉ đo display mode, screen/window/visualViewport, safe-area T/R/B/L và app rect; số chênh screen/window chỉ tham khảo khi bàn phím đóng.
- EDGE-04: WebKit bug 317153 và 313800 ghi nhận hồi quy standalone ở một số iOS 27 beta; không khẳng định đã sửa hoặc ảnh hưởng bản iOS hiện tại. Kiểm tra cài từ màn hình chính, màu/tương phản status bar, top/bottom, bàn phím mở/đóng, xoay và so với Safari. Nếu OS letterbox, giữ vùng hợp lệ, không hack viewport.
- v13.12: 6/6 classic script parse; manifest JSON tạo thành công; chưa nghiệm thu Safari/PWA/Pages/CI hoặc xác nhận tràn viền thực trên thiết bị. Chỉ demo, không đổi production.

## 28. VP-SAFE / KB-RESTORE — v13.13–v13.14
- VP-SAFE-01: Safari/PWA dùng cùng hàm visibleSafeArea. Lấy visualViewport rect, layout rect, env inset thực; phần an toàn còn dùng = phần giao với viewport, clamp 0..raw inset. Không cộng screen.height, không branch kích thước theo tên môi trường. Token --safe-visible-top/right/bottom/left; composer bottom max(8px, safe-visible-bottom). Chỉ một transaction viewport. Header/scroll reserve và vùng điều khiển ngang dùng token. 8/8 mô phỏng v13.13 đạt, chưa kiểm tra WebKit thực tế.
- KB-RESTORE-01: Người dùng báo vẫn rơi khi thoát. Đối chiếu v11.1 (a68cb4a01bf66d3d0e64bd20dbbc81fc5ef4fd30) và v13.6 (4660dda8cb7ed31a59d413d1973d76b00f6b33cc). KB-06 cấm animation/timer che lỗi được khôi phục, thay thế KB-APP-02/05: xóa bridge 120ms/180ms và WAAPI, không thêm vòng layout nhân tạo. Hàm floatingViewportGeometry giống nguyên văn v13.6, giữ inset khi blur. Adapter v13.13 vẫn dùng, không phải rollback nguyên file.
- KB-RESTORE-02: Bỏ ResizeObserver riêng của safe-area; chỉ ghi biến viewport khi giá trị đổi. Không lên lịch kéo cuối từ viewport trong khi keyboardOccluding. Mặc định composer tint tĩnh .94 không backdrop-filter, giữ tỷ lệ 82%/48px và viền 1px; liveglass=1 chỉ thử đối chiếu chi phí blur. Không khẳng định native glass hoặc độ mượt đã đạt.
- KB-RESTORE-03: Lưu keyboard-baseline-v13.6.html chính xác từ commit 4660dda để đối chiếu, không thay đổi trang chính bằng bản cũ. Kiểm tra mở/thoát lặp trong cùng Safari và PWA; đối chiếu baseline, v13.14, liveglass=1. Nếu baseline cũng lỗi, thu trace visualViewport/focus và không tiếp tục đoán animation. Nếu baseline mượt, tìm khác biệt CSS/app-shell. 6/6 script parse, kiểm tra hàm geometry trùng baseline, không còn bridge. Chưa xác nhận Pages, runtime hoặc thiết bị; không áp dụng production.

## 29. SURFACE-PARENT — v13.15, một chủ sở hữu vật liệu và viền
- SURFACE-01: Geometry (width/height/padding/radius/position), Material (background/backdrop-filter), Edge (border), Elevation (box-shadow) độc lập. Một khối khai báo paint dùng --paint-material, --paint-edge, --paint-elevation, --paint-filter cho composer, search, standalone input, header buttons, outline buttons, dialog. Không dùng lớp rim mask hoặc inset ring thứ hai; không gắn glass g1 vào nút media bên trong composer.
- SURFACE-02: Border vật lý 1px; input focus chỉ đổi token màu viền, không đổi độ dày, kích thước hay thêm outline ngoài. Forced-colors có ngoại lệ outline trong; nút vẫn giữ dấu hiệu focus-visible. Header/outline dùng cùng một viền thay rim gradient trước đó; giữ kích thước ngoài, có thể thay đổi diện tích trong nút 1px mỗi cạnh.
- SURFACE-03: Mặc định không blur trực tiếp trong composer, header, dialog; dùng vật liệu tĩnh. liveglass=1 bật blur thử nghiệm (14px composer, 12px header/dialog hỗ trợ); reduced-transparency/high contrast bắt buộc nền đặc và không blur. Không thay geometry từ chế độ vật liệu. upstreamglass=1 là thử nghiệm riêng cho header, thay paint bằng token transparent; chưa nghiệm thu thư viện bên ngoài.
- SURFACE-04: Xóa các khối paint cũ trùng nhau và token --glass-face/depth/rim, --input-edge-*; không thêm CSS vá đè viền. glasscheck=1 hiển thị border/radius/outline/blur/rim computed style; A20 chấp nhận pseudo-element không sinh (none/normal).
- SURFACE-05: v13.15 commit index.html; 6/6 classic scripts parse, đối chiếu KeyboardController và resizeDraft nguyên văn v13.14; CSS chính giảm 2494 ký tự. Không thay tỷ lệ 82%/48px hoặc cơ chế safe-area. Chưa chạy browser computed style, Pages, CI hay kiểm thử bàn phím Safari/PWA thật; không khẳng định lỗi giật đã hết. Mặc định ưu tiên ổn định, chỉ demo 0v. Các rule vật liệu cũ mâu thuẫn được thay thế bởi SURFACE-01–05.

## 30. APP-RHYTHM — v13.16, so sánh iPhone và web hẹp
- APP-RHYTHM-01: Ảnh 2026-11-24 21:10 cho thấy Chrome đang hiển thị v13.14; không coi đó là nghiệm thu v13.15. So sánh theo tỷ lệ chiều rộng cửa sổ nội dung, không theo pixel tuyệt đối của ảnh chụp desktop. Safari/Chrome chrome (thanh trình duyệt) nằm ngoài thiết kế app.
- APP-RHYTHM-02: Mobile/narrow floating dùng chữ chat 17px/26px, timestamp 12px/16px, cách bubble 2px, message gap 12px, bubble gửi 18px radius và padding 8/12px. Tin đơn không co chiều cao trong flex scrollport. Timestamp bên gửi căn phải theo mép bubble. Giữ 87% max-width tin thường và 100% mẫu nghiệp vụ. Safe area trái/phải là cạnh vật lý, tránh đảo khi hướng văn bản thay đổi.
- APP-RHYTHM-03: Phiên bản ở hàng phụ cạnh vai trò hội thoại, không thêm vùng header; tên/vai trò dài ellipsis, phiên bản không co. A22 kiểm đồng bộ nhãn/title, A23 kiểm vị trí trong hàng phụ.
- APP-RHYTHM-04: 6/6 classic scripts parse; KeyboardController, resizeDraft và Surface Parent đối chiếu nguyên văn v13.15. Giữ composer 82%/48px, vùng chạm 44px, blur mặc định tắt. Chưa đo computed layout trên browser hoặc nghiệm thu bàn phím iPhone. Pages v13.15 không truy cập được từ công cụ web; v13.16 đã commit, chưa xác nhận xuất bản. Chỉ demo 0v, không sửa production.

## 31. GEO-ADAPT — v13.17, kiểm tra lại hình học
- GEO-ADAPT-01: Bill dùng grid auto-fit với min 180px/cột và gap 8px; nếu vùng nội dung <368px thì xếp dọc, nếu đủ thì hai cột. Không dựa tên thiết bị. Ảnh giữ object-fit:contain, cao tối đa 320px, không cắt dữ liệu; giữ nghiệp vụ và kiểm tra chi tiết. 180/320 là quyết định layout nội bộ, chưa được người dùng nghiệm thu.
- GEO-ADAPT-02: Danh bạ không cho preview lấn sang cột trạng thái; tên/preview cùng trục trái/phải; giờ căn phải, ellipsis khi thiếu chỗ. E3 đọc gap thật và cạnh phải track, không giả định giờ luôn rộng hết cột.
- GEO-ADAPT-03: Đo độ chồng bằng min của chiều sâu giao theo x/y (CSS px), không dùng diện tích. G29/G69/G71 đọc computed gap; G49–G51/G69 nhận biết bill xếp dọc hoặc ngang; G42 dùng kích thước ảnh gốc nếu thiếu thuộc tính. G84–G91 bổ sung lề trong composer, chiều rộng chữ, trục đáy, viền, phiên bản và trục ngang tin. guides=1 xuất window.crmGeometry gồm viewport/checks/issues; không tuyên bố toàn bộ rule đã chạy.
- GEO-ADAPT-04: Kiểm tra Chromium headless cục bộ trên fixture rút gọn dùng CSS thành phần tương ứng (không phải tải nguyên trang): 8 chiều rộng vùng 320/375/390/416/430/469/768/1024px × 2 safe-area ngang (0/0 và 24/8), 11 phép đo mỗi trường hợp, 176/176 đạt. Fixture 768/1024 vẫn dùng profile thành phần hẹp để đo khả năng thích ứng vùng, không phải layout desktop nhiều panel thật. 6/6 classic scripts parse; KeyboardController, resizeDraft, Surface Parent nguyên văn v13.16. Chưa kiểm tra runtime toàn trang, Pages, Safari/PWA, bàn phím thật. Pages không truy cập được bằng web/container. Không sửa production.

## 32. DESKTOP-SHELL — v13.18, cân đối cột trên web
- DESKTOP-01: Ảnh Chrome v13.17 của người dùng xác nhận bản đã hiển thị trên Pages tại thời điểm chụp; danh bạ 250px làm tiêu đề bị ellipsis, search xuất hiện đồng thời nút và trường, bộ lọc tràn. Desktop từ 768px dùng cột danh bạ clamp(280px,28vw,340px); ẩn nút search vì trường tìm kiếm đã hiển thị, bộ lọc được xuống dòng thay vì mất mục, không đổi mobile.
- DESKTOP-02: Khi mở Công việc ở 768–1099px, tạm ẩn danh bạ để giữ không gian chat; 1100–1199px dùng danh bạ 280px và Công việc 290px; từ 1200px giữ chính sách ba panel sẵn có. Đây là ngân sách bố cục nội bộ, không phải tỷ lệ ChatGPT chính thức.
- DESKTOP-03: Vùng đọc giới hạn 700px, căn giữa, lề tối thiểu 16px; composer giới hạn cùng 700px, không kéo dài theo toàn màn hình; version nằm gần vai trò. Desktop chữ tin 17/26px, timestamp 12/16px, tin gửi radius18 padding8/12. Không đổi kích thước mobile, chức năng nghiệp vụ, Surface Parent, KeyboardController hoặc resizeDraft.
- DESKTOP-04: G92–G97 bổ sung kiểm tra title, nút search dư, bộ lọc nằm trong vùng, chiều rộng/tâm composer và vùng đọc. Tính toán lý thuyết 8 viewport 768/900/1099/1100/1199/1200/1440/1920, chat còn tối thiểu 424px trong các trường hợp tính; 6/6 classic script parse, đối chiếu nguyên văn 3 khối được bảo vệ. Chưa đo DOM thực hoặc xác nhận Pages v13.18, chưa nghiệm thu Windows scrollbar, Safari/PWA/bàn phím. Chỉ demo 0v.

## 33. SURFACE-CONTEXT — v13.19, phân biệt web desktop và mobile
- SURFACE-CONTEXT-01: mặc định Flat: nền đặc, border 1px màu --line, không blur, không gradient vật liệu, không shadow của surface. Dùng cho desktop kể cả cửa sổ hẹp có pointer fine, tìm kiếm, nhập liệu nghiệp vụ, nút nghiệp vụ, dialog. Không đổi hình học.
- SURFACE-CONTEXT-02: mobile glass chỉ khi viewport <=767px và (hover:none, pointer:coarse hoặc display-mode:standalone), floating=1. Chỉ áp dụng composer cha và nút header hội thoại nổi; không kính chồng nút con, không đổi kích thước. Một border 1px duy nhất dùng màu kính riêng (rgba 0/0/0/.14, focus .26) thay viền thường. Nền tint .86/.90; liveglass=1 bật blur14px thử nghiệm trên mobile hỗ trợ, không bật mặc định vì lỗi giật bàn phím chưa nghiệm thu. PWA màn rộng sử dụng profile desktop. Media query tự tính lại khi đổi kích thước.
- SURFACE-CONTEXT-03: giảm trong suốt/tăng tương phản/forced colors ưu tiên nền đặc, không blur. Upstream glass chỉ thử trên header chat mobile; không tự tải ở desktop. glasscheck=1 hiển thị --paint-profile, A24/A25 kiểm phạm vi vật liệu. Các rule vật liệu v13.15 xung đột được thay thế bởi mục này.
- SURFACE-CONTEXT-04: v13.19 đã commit, 6/6 script classic parse; đối chiếu nguyên văn KeyboardController, resizeDraft, khối FL layout so với v13.18. Chưa đo computed styles hoặc hiệu năng Safari/PWA/desktop thật, chưa xác nhận Pages. Không sửa production.

## 34. BOTTOM-INPUT — v13.20, chân vùng khả dụng và tăng chiều cao
- BOTTOM-01: Tách chân frame và chân composer. Desktop lấy đáy panel hội thoại, không lấy đáy màn hình vật lý; mobile lấy đáy visualViewport do KeyboardController quản lý. Frame kết thúc đúng đáy vùng khả dụng, composer nằm cao hơn bằng padding-bottom frame. Không cộng thanh trình duyệt hoặc chiều cao bàn phím lần thứ hai.
- BOTTOM-02: Một owner CSS --composer-frame-top/--composer-frame-bottom. Desktop top 8px/bottom 12px; mobile bottom max(8px, residual safe-area bottom), floating top 4px, non-floating top 8px. PWA không gán cứng 34px; nếu inset thực còn 34px thì lề 34px, nếu viewport đã tránh vùng đó thì 8px. Khi bàn phím mở hoặc đang đóng dùng cùng công thức, không đổi padding theo data-keyboard/blur. Xóa các rule cũ 6px/0px và --app-composer-bottom. Các con số lề là lựa chọn thiết kế nội bộ, không phải chuẩn Apple bắt buộc.
- BOTTOM-03: Chiều rộng không phình theo chữ: desktop tối đa 700px, mobile floating 82% vùng ngang an toàn. Chiều cao textarea tự tăng 44 + 22*(n-1) CSS px với 1–5 dòng hiển thị, giới hạn 132px, sau đó cuộn bên trong. Khung cha mobile floating thêm 4px, desktop thêm 14px. Mobile giữ giới hạn thích ứng viewport hiện có; desktop cửa sổ thấp giảm giới hạn theo nguyên dòng (110/88/66/44px tại ngưỡng cao 317/295/273/251px). Ở chiều cao cực thấp không bảo đảm đủ 96px đọc, vẫn ưu tiên input tối thiểu.
- BOTTOM-04: Reserve first paint cùng công thức khung + padding; ResizeObserver đo lại frame thực. G98–G102/E5–E6 đo đáy frame, đáy input, lề theo safe-area, giới hạn và cao khung; keyboardtest hiển thị riêng độ lệch frame và lề input. Kiểm tra 6/6 classic scripts parse và đối chiếu nguyên văn KeyboardController, resizeDraft và Surface Parent với v13.19; ví dụ lề và bảng chiều cao là tính toán lý thuyết. Chưa chạy DOM thực, chưa nghiệm thu Safari/PWA/keyboard native, chưa xác nhận Pages v13.20. Chỉ demo 0v, không sửa production.

## 35. TYPE / COMP — v13.21, typography và composer hai hàng
- TYPE-01: Một bảng token gốc --type-* và --line-*; version kỹ thuật 10px; chú thích/giờ/nhãn bảng 12/16px; chi tiết nghiệp vụ 13/18px; danh bạ và chữ thường 15/20px; tiêu đề 17/22px; chat 17/26px; input 17/22px. Version là metadata kỹ thuật, không dùng cho nội dung nghiệp vụ. Icon glyph dùng token icon riêng 22/20px; không trộn typography với hình học icon. Các số là quyết định thiết kế web dựa trên tham chiếu trước, không phải thông số chính thức ChatGPT.
- TYPE-02: Alias --text-*, --input-font-size, --input-line-height giữ tương thích, trỏ về token gốc, không định nghĩa số mới. Mobile và desktop cùng vai trò/cỡ chữ; chỉ thay vùng chứa. Bỏ font riêng theo mobile/desktop ở chat/title/input/meta; đồng bộ nhãn bill và bảng. Chưa chuẩn hóa toàn bộ line-height/gap CSS của mọi module; không coi toàn bộ cascade đã sạch.
- TYPE-03: CSS chính giảm 28 khai báo font-size số px trực tiếp xuống 0; 6/6 classic script parse. Không tính font shorthand của panel debug hoặc chữ nhúng trong ảnh/SVG; không thay đổi ảnh chứng từ. A11/A27 đọc token gốc; cần đo computed style toàn trang để xác minh.
- COMP-01: Một form, ba con DOM hiện tại, CSS grid areas: single "plus draft send"; expanded "draft draft draft" / "plus . send". Textarea giữ nguyên node/focus/caret, không dựng lại DOM, không đổi chiều rộng shell. Dấu + và nút gửi luôn cùng hàng đáy, vùng chữ expanded dùng toàn bộ chiều rộng trong.
- COMP-02: InputController đo chiều cao tự nhiên ở chiều rộng giả định single (luôn trừ hai nút và hai gap), chuyển expanded khi vượt minHeight+1px, kể cả wrap tự động hoặc xuống dòng. Đo lại ở chiều rộng expanded để tính chiều cao thực. Dùng ngưỡng single cả khi đang expanded để tránh dao động qua lại. Khi xóa về một dòng vừa chiều rộng single thì thu lại. ResizeObserver chỉ lên lịch đo khi chiều rộng form thay đổi, cùng rAF resizeDraft; không thêm timer hoặc animation. Ảnh hiện vẫn dùng popup preview, chưa có hàng file đính kèm trong composer.
- COMP-03: 1 dòng giữ mobile 48px / desktop 58px; expanded cộng thêm toolbar 44px + gap 4px ngoài chiều cao textarea. Textarea tối thiểu 44px, tối đa 132px (5 dòng), sau đó cuộn nội bộ. Ví dụ nội dung thực 2 dòng: mobile 118px / desktop 128px. Mobile giới hạn theo viewport dành sẵn 48px toolbar; desktop cửa sổ thấp dịch các ngưỡng giới hạn thêm 48px. Không đổi hàm floatingViewportGeometry, inset hoặc vật liệu. Khoảng dự phòng toolbar ở trạng thái một dòng có thể làm giới hạn số dòng thận trọng hơn, không đổi chiều cao thực một dòng.
- COMP-04: G86/G87/G102 theo mode, G103/G104 kiểm toolbar/trục chữ, A26/A27 kiểm hàng công cụ và font; S05 kiểm expanded. 6/6 classic scripts parse, 5 giá trị ngưỡng mode mô phỏng, hàm floatingViewportGeometry giống v13.20. Chưa chạy DOM thực, chưa đo caret/IME/scroll và bàn phím thật, chưa xác nhận Pages. Vòng này refactor trọng điểm typography/composer và chỉ mục rule, chưa refactor toàn bộ index.html. Chỉ demo 0v.
