# INPUT — Nguồn học tập cho zoom khi focus, IME và ellipsis
Ngày đọc: 2026-11-24. Liên kết này là thư viện tham chiếu, RULES.md là nguồn quy tắc duy nhất. Không nhập dependency hoặc sao chép implementation.

| Nguồn | File / blob đã đọc | Nguyên lý |
|---|---|---|
| Adobe React Aria | [useTextField.ts](https://github.com/adobe/react-spectrum/blob/main/packages/react-aria/src/textfield/useTextField.ts), df2819bc53b2500e05e3045a4ffe50e33f3420d4 | Giữ thuộc tính autocapitalize, inputMode, autocorrect, spellcheck theo mục đích; chuyển tiếp composition events. |
| ProseMirror | [src/input.ts](https://github.com/prosemirror/prosemirror-view/blob/master/src/input.ts), f1287863d0e0bfbf7f26a905565c6d83fecbf1ae | Phân biệt phím trong composition, lưu ý Safari có thứ tự Enter/compositionend bất thường. Là editor contenteditable, không bê timeout vào textarea. |
| W3C UI Events | [Composition Events](https://github.com/w3c/uievents/blob/main/sections/event-compositionevent.txt), dd6a74ef19884c6073f85ff7988524ea3991b6f6 | Phiên IME từ compositionstart qua update đến end; có thể dùng nhập dấu. |
| Tailwind | [utilities.ts](https://github.com/tailwindlabs/tailwindcss/blob/main/packages/tailwindcss/src/utilities.ts), fcca93166f9cc9d3158c85f132134896274027f6 | truncate là CSS overflow hidden / nowrap / ellipsis, không thay nội dung. |
| Flutter | [Web accessibility](https://docs.flutter.dev/ui/accessibility/web-accessibility) | Tài liệu khuyến nghị font input iOS tối thiểu 16 CSS px để tránh autozoom khi focus, vẫn hỗ trợ phóng to có chủ ý. |
| Rick Strahl | [Preventing iOS Safari Textbox Zooming](https://github.com/RickStrahl/BlogPosts/blob/master/2023-04/Preventing%20iOS%20Safari%20Textbox%20Zooming/IosTextboxZoomingAndViewportSizing.md) | Ưu tiên sửa cỡ chữ tất cả trường; viewport hack không phải cách sửa gốc. Đọc qua trang web lập chỉ mục. |
| MDN | [String.normalize](https://github.com/mdn/content/blob/main/files/en-us/web/javascript/reference/global_objects/string/normalize/index.md), [InputEvent.isComposing](https://github.com/mdn/content/blob/main/files/en-us/web/api/inputevent/iscomposing/index.md) | NFC cho so sánh chuẩn Unicode; không chỉnh value/caret trong IME. |

## Áp dụng v13.28
- Tất cả trường lấy font token tối thiểu 16px trước focus, mặc định 17px. Không đổi kích thước khi focus hay scale() để giả cỡ chữ.
- Bản hiện tại vốn đặt font 17px cho input và có chính sách khóa pinch zoom; không khẳng định autozoom đã xảy ra do font nhỏ. Giữ chính sách pinch hiện tại vì chưa có yêu cầu đổi hành vi này; phải rà soát riêng khả năng tiếp cận và zoom ảnh. Không dùng khóa pinch làm bằng chứng chống autozoom. Bỏ chặn double tap ở vùng nhập/đọc để không cản chọn chữ.
- Bỏ normalizeDraft viết lại value khi đang nhập. Theo dõi composition trên các trường; không submit khi composition đang diễn ra; tìm kiếm so sánh NFC, không bỏ dấu. Sau khi gửi lưu originalText, text hiển thị vẫn giữ quy tắc viết hoa đầu dòng hiện hành; NFC không đổi ba dấu chấm thành ký tự ellipsis hay ngược lại.
- Số lượng/tiền chỉ làm sạch và định dạng khi change/blur, không ghi lại value mỗi phím; các trường này thuộc inputlab demo.
- Ellipsis hiển thị CSS trên vùng tiêu đề/danh bạ; không cắt value hoặc dữ liệu. Vùng chat thật phải wrap. Chưa có bằng chứng flash F5 đã xảy ra ở bản này.
- Bảo vệ nguyên văn bốn đoạn code baseline v13.27: keyboard controller, focus handler, composer sizing, Surface Parent. Không coi so sánh source là nghiệm thu thiết bị.
- Test thực tế cần iOS Safari/PWA, Android, macOS/Windows bộ gõ Telex/VNI, gõ/sửa giữa từ, chọn chữ, dán, emoji, Enter trong IME, chuyển focus qua search/note/quantity/money, reload tiêu đề dài, scale trước/sau focus. Kiểm tra cả zoom cố ý/khả năng tiếp cận khi đổi chính sách pinch.
