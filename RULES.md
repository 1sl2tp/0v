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
