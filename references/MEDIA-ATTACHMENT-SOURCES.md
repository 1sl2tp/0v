# MEDIA-ATTACHMENT — nghiên cứu nguồn, 25/11/2026

Phạm vi: dấu + trong Input chat, Web/PWA iOS; không sửa KeyboardController. Chỉ học nguyên lý, không nhập mã nguồn runtime.

| Nguồn đã đọc | Bằng chứng | Áp dụng / giới hạn |
|---|---|---|
| [Adobe FileTrigger.tsx](https://github.com/adobe/react-spectrum/blob/main/packages/react-aria-components/src/FileTrigger.tsx) | blob 7564a8a500ed479862e03b7445d897b7607c6a1f, dòng 56–98 | PressResponder gọi input.click đồng bộ, reset value, ngăn click lan truyền, change trả FileList. Không chứng minh neo menu iOS; không dùng display:none cho neo 0v. |
| [WebKit WKFileUploadPanel.mm](https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/ios/forms/WKFileUploadPanel.mm) | source selection, willDisplayMenuForConfiguration, repositionContextMenuIfNeeded | iOS tạo source menu; editable focus có thể giữ first responder. Reposition có điều kiện, không có API DOM điều khiển vị trí/đóng native menu. Mã main không chứng minh bản Safari đã cài. |
| [Chatwoot ReplyBox.vue](https://github.com/chatwoot/chatwoot/blob/develop/app/javascript/dashboard/components/widgets/conversation/ReplyBox.vue) | blob 8895a13eeafa41cb06af2f9009a37b2e929d61b2, dòng 1522–1580 | AttachmentPreview và ReplyBottomPanel trong composer; state ảnh tách khỏi text. Không chứng minh behavior keyboard Safari. |
| [Mattermost file_upload.tsx](https://github.com/mattermost/mattermost/blob/master/webapp/channels/src/components/file_upload/file_upload.tsx) | blob 06b11a36386c1dd2c17df1e7290277e2d560abbc, dòng 96–170, 579–580, 628, 698–749 | input click, change, hooks, upload errors/progress phân trách nhiệm; không sao chép focus() của Mattermost vì KB-LOCK. |

## Rule áp dụng
Input cha giữ focus và hình học; Button dấu + chỉ kích hoạt một native picker; Media nhận FileList, kiểm tra loại/kích thước, tạo preview và xử lý cancel; không có menu nguồn CRM, không thêm bộ điều khiển keyboard. Native menu mong muốn phía trên Input nhưng không hứa tọa độ chính xác hoặc tự đóng khi OS không hỗ trợ. Nghiệm thu native riêng; Chromium mouse/touch chỉ chứng minh luồng web. Chọn tệp hiện chỉ hỗ trợ ảnh. Element Web không đọc được đường dẫn đã thử; không dùng làm bằng chứng. Chatwoot Mobile chỉ nghiên cứu tiếp cho APK, không dùng native API trong PWA.
