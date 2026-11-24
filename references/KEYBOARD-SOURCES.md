# KB — Thư viện học tập từ upstream

Ngày nghiên cứu: 2026-11-24. Phạm vi: Safari iOS, PWA, composer chat. Đây là tài liệu tham chiếu của RULES.md, không phải bộ RULE song song. Không cài dependency, không sao chép source upstream vào runtime. Các Git blob SHA ghi dưới đây là định danh nội dung file đã đọc, không phải commit SHA.

## A. Nguồn chính — đọc source trực tiếp

| ID | Kho và file | Git blob SHA tại lần đọc | Điều học được |
|---|---|---|---|
| KB-S01 | [Adobe / useViewportSize.ts](https://github.com/adobe/react-spectrum/blob/main/packages/react-aria/src/utils/useViewportSize.ts) | b0401dbd3379aa25ef4e6aa04e05ee14960b8338 | Resize từ visualViewport, bỏ qua zoom; xử lý blur riêng trên iOS WebKit để cập nhật kích thước layout sớm khi đóng bàn phím. |
| KB-S02 | [Adobe / runAfterKeyboard.ts](https://github.com/adobe/react-spectrum/blob/main/packages/react-aria/src/utils/runAfterKeyboard.ts) | 53b4c6f956d84220f3db61d31c0103ff9df4f8f4 | Đợi hai frame để xác định focus mới; phân biệt mở, đóng, chuyển input; đóng có thể xử lý sớm. Không hiểu tên hàm là luôn chờ hết animation. |
| KB-S03 | [Adobe / usePreventScroll.ts](https://github.com/adobe/react-spectrum/blob/main/packages/react-aria/src/overlays/usePreventScroll.ts) | 95421f55409cb51ab25998b3f6d0d54b74f32bf4 | Xử lý scroll và focus của WebKit riêng, bảo vệ thao tác chọn chữ, không mặc định chặn toàn bộ touch. Phạm vi gốc là overlay, không bê nguyên vào chat. |
| KB-S04 | [Ionic / scroll-assist.ts](https://github.com/ionic-team/ionic-framework/blob/main/core/src/utils/input-shims/hacks/scroll-assist.ts) | a5f3780741bcbf2d2f6e1af621004e4439e0dc3f | Phân biệt WebView có native resize hay không; chỉ scroll khi có đủ không gian; không coi mọi môi trường như nhau. |

## B. Nguồn tham khảo / giới hạn

| ID | Nguồn | Mức bằng chứng / giới hạn |
|---|---|---|
| KB-S05 | [Microsoft VS Code / window.ts](https://github.com/microsoft/vscode/blob/main/src/vs/workbench/browser/window.ts) | Đọc đoạn source được lập chỉ mục: lắng nghe visualViewport.resize trên iOS và xử lý document scroll. Không có bằng chứng đảm bảo animation bàn phím mượt. |
| KB-S06 | [mattpilott/ios-chat/main.js](https://github.com/mattpilott/ios-chat/blob/main/main.js), [style.css](https://github.com/mattpilott/ios-chat/blob/main/style.css) | Đã đọc source, blob 32b592a4e377b801199c3df9459b5e1e4d7e69bc / 62a309b94e7ce698cd0591fbff848635909091cd. Demo nhỏ dùng visualViewport.height, CSS top và transition; có ngưỡng 600px và blink animation. Không chọn các hằng số hoặc animation đó làm chuẩn. |
| KB-S07 | [Crscristi28 / useKeyboardHeight.ts](https://github.com/Crscristi28/ios-pwa-keyboard-fix/blob/main/demo/src/lib/useKeyboardHeight.ts), [useScrollLock.ts](https://github.com/Crscristi28/ios-pwa-keyboard-fix/blob/main/demo/src/lib/useScrollLock.ts) | Đã đọc source, blob 287abb615fea938124a03a60ca3553774aa9afdf / 84d82a2245199bddcbd025da595c6f33fdc3eb37. Demo dùng đo keyboard và pre-lift có điều kiện, lọc 80ms, scroll lock. Phạm vi thử nghiệm hẹp; không chọn timer/pre-lift làm mặc định. |
| KB-S08 | [WebKit Bug 265578](https://bugs.webkit.org/show_bug.cgi?id=265578), [Ionic issue 26702](https://github.com/ionic-team/ionic-framework/issues/26702) | Báo cáo viewport resize muộn và phân biệt layout/visual viewport. Không phải trace thiết bị của người dùng. |
| KB-S09 | [Ionic Capacitor Keyboard](https://github.com/ionic-team/capacitor-keyboard) | Native bridge khác web/PWA. Không áp dụng API native vào Safari thông thường. |
| KB-S10 | [Adobe issue 9172](https://github.com/adobe/react-spectrum/issues/9172), [issue 7131](https://github.com/adobe/react-spectrum/issues/7131) | Các ca hồi quy scroll/focus và dismiss. Không coi thư viện lớn là bằng chứng mọi môi trường đã ổn định. |

## C. So sánh với 0v v13.26

- applyViewport ghi rect thực; focusout vẫn gọi updateViewport() chỉ đọc visualViewport. Nếu API còn trả rect cũ, không có thay đổi vị trí cho tới resize sau.
- Adobe KB-S01/S02 có nhánh khôi phục layout sớm lúc blur sau khi xác định focus mới. Đây là khác biệt có bằng chứng source, chưa có kết quả thực nghiệm trong 0v.
- Cần phân biệt chuyển focus input A -> B, đóng bàn phím thật, hardware keyboard, zoom, đổi hướng, thanh công cụ Safari và PWA.
- Không ghép nhiều cách cùng lúc. Ưu tiên đánh giá nhánh early-close của Adobe với một writer root; không tạo offset riêng cho composer. Nếu chọn nhánh này phải cập nhật hợp đồng VIEW và test tương ứng, bởi rect hiệu lực tạm thời không còn bắt buộc bằng rect visualViewport đang cũ.
- Không thêm animation giả, không bê nguyên scroll lock hoặc hack focus của nguồn nhỏ. Không bảo đảm chuyển động native nếu API không cung cấp dữ liệu cần thiết.

## D. Cổng nghiệm thu

1. Đọc file thật, xác định giấy phép trước khi sử dụng mã; ghi path, blob và lý do lựa chọn. Chỉ học nguyên lý ở vòng này.
2. Thay đổi từng cơ chế, có test fail trước/sau cho hành vi liên quan, không lấy syntax pass làm chứng cứ hết giật.
3. Với early-close: test không chuyển focus, chuyển input A -> B, refocus nhanh, keyboard không mở, zoom, resize khi blur, xoay màn hình; đảm bảo không nhảy lên rồi xuống và không có hai writer.
4. Thiết bị thật: Safari thanh địa chỉ trên/dưới, PWA, Android, mỗi trường hợp mở/đóng liên tiếp; ghi raw viewport, root, composer, focus, document scroll và video khi có. Không khai báo PASS nếu chưa chạy.
5. Không tăng version ứng dụng nếu chỉ thêm thư viện học tập. Không sửa giao diện hoặc production trong vòng nghiên cứu.
