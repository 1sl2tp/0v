# TYPOGRAPHY — nguồn học tập v13.32 (2026-11-24)

| Mã | File upstream đã đọc | Git blob SHA | Nguyên lý / giới hạn |
|---|---|---|---|
| TYPE-S01 | [Radix Themes typography.css](https://github.com/radix-ui/themes/blob/main/packages/radix-ui-themes/src/styles/tokens/typography.css) | 45b359c55b5d2c32a4913cd8ba0394cae0035632 | Tách font-family, font-size, weight, line-height, letter spacing và heading. Học cấu trúc token, không bê thang cỡ chữ hoặc scaling vào 0v. |
| TYPE-S02 | [Tailwind theme.css](https://github.com/tailwindlabs/tailwindcss/blob/main/packages/tailwindcss/theme.css) | 05364f5c201868b7dd957fdfde570fa6d17e575b | Cỡ chữ đi cùng line-height; weight token độc lập, font mặc định có alias. Không cài Tailwind. |

Primer path src/tokens/base/typography/typography.json trả 404; không coi là nguồn đã đọc. Adobe style-macro.ts truy cập được nhưng không trích được token typography liên quan trong vòng này; không dùng làm bằng chứng. Hai nguồn trên là cơ sở trực tiếp, không sao chép implementation, không tải font mới. Blob SHA là định danh nội dung đã đọc, không phải commit.

## Bảng cha và vai trò
| Vai trò | Cỡ chữ CSS px | Line-height CSS px | Độ đậm mặc định |
|---|---:|---:|---:|
| version (metadata) | 10 | 16 | 400 |
| caption / label | 12 | 16 | 400 |
| detail / note | 13 | 18 | 400 |
| body | 15 | 20 | 400 |
| title | 17 | 22 | 600 |
| chat | 17 | 26 | 400 |
| number / money (text) | 13 | 18 | 400 |
| input (Input API, không Typography.bind) | 17, sàn 16 | 22 | 400 |

Họ font: -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif. Weight 400/500/600/700; 550 và 650 là token tương thích ở nơi cũ. Number/money dùng tabular-nums nếu font hỗ trợ; căn trục là owner Table/Layout. Chữ hiển thị có biến thể underline/strike/italic; không thay văn bản. Các số trên là quyết định 0v, không phải thông số ChatGPT hoặc Apple chính thức.

## So sánh và phạm vi
v13.31 đã có size token, nhưng còn số trực tiếp cho weight/line-height và chưa có API chữ theo vai trò. v13.32 bổ sung --font-ui, --weight-*, CSS data-type-role, Typography.create/bind và lab. Các khai báo weight/line-height có trị số tương đương được thay bằng token ở CSS chính ngoài vùng Surface bảo vệ. Một số line-height hình học cũ (ví dụ module title 24px, caption header 18px) vẫn giữ; rule CSS role có specificity thấp để không tự ghi đè component. Table hiện dùng caption 12/16 theo hợp đồng cũ, không ép role money 13/18 vào cột tiền. Module và header/cell bảng được gọi API, không tuyên bố đã chuyển toàn bộ static markup. Input/Keyboard và các API cũ bảo vệ; chưa có đo computed style trên browser, glyph tiếng Việt, zoom/resize, Pages. Cần đo và duyệt trước khi bỏ các selector tương thích.
