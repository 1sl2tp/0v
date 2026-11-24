# COMPONENT API — danh mục cha/con và hợp đồng sử dụng
Phạm vi 0v v13.32; RULES.md là nguồn quy tắc chính. Không phải package dùng chung đã phát hành. Mỗi owner chỉ chịu trách nhiệm một nhóm hành vi; sửa một chỗ, các con dùng chung được hưởng. Không thay đổi baseline keyboard v13.27.

| Owner | API hiện có / cách dùng | Trách nhiệm | Không được sở hữu | Trạng thái |
|---|---|---|---|---|
| Input | Input.create({type,label,value,placeholder,rows}); Input.bind(node,{type}); Input.isComposing; Input.commitMessage; Input.searchKey | Sáu profile, IME, numeric commit, Unicode | vị trí keyboard, nền/viền riêng | v13.29 đã chuyển các ô mẫu; DOM stub đạt |
| Keyboard | InputController focus/blur + applyViewport/reconcileViewport + early-close | focus lifecycle, rect hiệu lực và root | tự định dạng chữ, transform riêng composer | baseline v13.27 user accepted; khóa |
| Typography | Typography.create({role,text,tag,weight,decoration}); Typography.bind(el,{role,weight,decoration}); CSS --font-ui / --type-* / --line-* / --weight-* | vai trò chữ hiển thị, họ font, size, weight, line-height, kiểu số | editable value, focus, bố cục màn | v13.32 đã triển khai; 11 ca DOM stub đạt; computed style PENDING |
| Surface | data-glass, data-input-parent, --paint-* | nền, viền, kính, bóng | tọa độ/chiều cao keyboard | owner hiện hữu; giữ nguyên |
| Button / Icon | Button.create({kind,text,label,className,icon,type,disabled,onClick}); Button.bind(node); Icon.create(name); Icon.replace(button,name) | loại nút native, glyph registry, tên truy cập; controller hiện có đăng ký | hành động nghiệp vụ, focus/blur, viewport | v13.30 đã triển khai; 10 ca DOM stub đạt |
| Popup | Popup.open({type,title,content,description,onDispose,actions}); Popup.close(dialog,result) | vòng đời native modal, profile 1–4, cleanup, rect riêng | root viewport, nhập liệu | v13.31 đã triển khai; 12 ca DOM stub đạt |
| Media | MediaController.grid(count), .layout(grid,ratios), .rotate(source,target,angle) | bố cục ảnh, hướng ảnh | gửi dữ liệu thật | hiện hữu; chưa refactor |
| Card | CardController.create(kind), .header(), .row(), .business() | cấu trúc thẻ | tự tính nghiệp vụ | hiện hữu |
| Table | TableController.create({keys,rows,title,status,total}) | registry cột, căn trục, hiển thị | tự sửa số liệu | hiện hữu |
| Scroll | ScrollController.write(top,reason), .end(reason), .geometry(pinned) | vị trí đọc và cuối hội thoại | root rect, IME | hiện hữu; phụ thuộc KB-LOCK |
| Layout / Composer | CSS grid + composerMode/resizeDraft | bố cục cha–con, giới hạn không gian | định dạng dữ liệu khi gõ | hiện hữu; khóa phần keyboard |
 
## Quy trình phát triển
1. Xác định owner và các biến thể con trước khi thêm component. Gọi API hiện có nếu phù hợp, không tạo bản sao riêng.
2. Chuẩn hóa dần từng owner, chỉ khi có ít nhất một hành vi dùng chung rõ ràng. Input và Button/Icon đã có API. Popup đã có API v13.31. Typography đã có API v13.32. Tiếp theo Media, Surface, Card/Table. Không refactor đồng thời Keyboard/Scroll.
3. Mỗi API mới ghi tham số, dữ liệu đầu vào/ra, phạm vi, điều cấm, nguồn tham khảo, test và phiên bản. Kiểm tra runtime thật; không coi source inspection là chứng nhận.
4. Chỉ tách thành package tái sử dụng giữa các repo sau khi có nhu cầu, API ổn định, giấy phép và release gate. Vòng hiện tại chỉ 0v.

## Cổng bắt buộc
Đọc AGENTS.md, RULES.md và danh mục này trước sửa. Ghi mã rule, lý do ngoại lệ, bằng chứng và trạng thái tại CHANGE-CHECK.md theo RULE-GATE-01–06. Không viết lại API cha ở con.
