# P05.1 — Bài toán rà soát ảnh bill gốc và cải tiến bộ đọc dùng chung

Ngày 26/11/2026 (VN). Trạng thái E0: đã kiểm kê dữ liệu; BLOCKED phần đọc ảnh độc lập vì connector hiện tại chỉ đọc được metadata, không có đường tải ảnh private có xác thực. Đây là đặc tả nghiệm thu, không phải một reader mới. Nguồn cha: [BILL-FLOW-01–08](https://github.com/1sl2tp/chat/blob/main/docs/BILL_SINGLE_READER.md), [BILL-SAMPLE-REGIONS](BILL-SAMPLE-REGIONS.md). Không sửa nghiệp vụ thu/đối trừ.

## 1. Đầu vào và owner
- Kho private v21-media (2.618 objects tại lần kiểm kê); chỉ đọc ảnh gốc của receipt được phép. Không dùng ảnh thumbnail, kết quả OCR cũ, thông báo Agribank hay STK cấu hình để điền đáp án.
- Khóa: receipt_id + asset_id + message_id + SHA-256 ảnh gốc + reader/rule version. Bản ghi không phải bill, ảnh trùng và ảnh chưa rõ phân nhóm riêng; mỗi ảnh một giao dịch, không ghép dòng từ nhiều giao dịch.
- API lab hiện có v0-bill-vision-manual (v9 tại kiểm kê) đọc thử có admin/AAL2, không ghi sổ; live reader v21-bank-bill-event + bill-vision-reader.mjs + bill-amount-rules.mjs là owner canonical. Lab và live không được tự tạo hai bộ quy tắc nghiệp vụ. 0v chỉ hiển thị canonical receipt; đề xuất sửa gửi tới owner CHAT, không sửa repo CHAT trong PR này.

## 2. Số liệu E0 (SELECT chỉ đọc)
605 receipt: 374 received, 146 non_bill, 44 amount_read, 24 review, 17 duplicate. 459 ứng viên khác non_bill (bao gồm duplicate), 51 thiếu transfer_at_vn, 12 thiếu amount_vnd, 29 thiếu receiving_account, 28 thiếu receiving_name; số liệu có thể chồng nhau. Không coi trường có giá trị là đọc đúng. 9/10 VPBank thiếu timestamp vẫn có ngày đã lưu; chưa chứng minh trên ảnh có giờ. Không coi duplicate là mẫu độc lập.
| Ngân hàng chuẩn hóa cho báo cáo | Ứng viên | Thiếu timestamp | Thiếu tiền |
|---|---:|---:|---:|
| Techcombank | 81 | 6 | 0 |
| MB | 80 | 1 | 0 |
| VietinBank | 67 | 0 | 0 |
| BIDV | 58 | 0 | 2 |
| Vietcombank | 40 | 1 | 0 |
| VPBank | 11 | 10 | 0 |
| Agribank | 7 | 1 | 0 |
| Chưa rõ | 73 | 32 | 10 |

## 3. Luồng nghiệm thu
1. Từ /bill.html, chọn receipt đã được cấp quyền. Dùng loader hiện có, không công khai bucket, không lấy service role/token từ DB, không đưa ảnh khách hàng lên GitHub. Cần đường xuất ảnh gốc riêng tư có người dùng chủ động cấp quyền hoặc tải ảnh trực tiếp qua phiên admin; nếu không có, đánh dấu BLOCKED chứ không suy đoán. Không tạo endpoint bypass auth.
2. Xác định ảnh trùng bằng hash; phân loại bill/non_bill/unclassified; ngân hàng gửi, loại hình, biến thể giao diện, ảnh chụp màn hình/ảnh chụp lại/nhật ký; chọn duy nhất một giao dịch. Nhận diện suffix 4–6 số 9 chỉ là tín hiệu ứng viên, không là bằng chứng tiền về hay số TK đầy đủ.
3. Đọc độc lập ảnh gốc trước khi xem kết quả cũ. Theo vùng logo, số tiền, ngày, giờ, tên nhận, STK nhận, ngân hàng nhận, memo, mã giao dịch, mã tra soát. Mười trường theo BILL-FLOW-02. Với mỗi trường lưu observed literal, normalized value, vùng [ymin,xmin,ymax,xmax] (0..1000), nhãn, trạng thái readable/absent/unreadable/ambiguous. Không có hoặc mờ để null; giờ điện thoại và giờ gửi ảnh không phải giờ giao dịch. Nội dung giữ đủ dòng, nối một dòng để đối soát nhưng giữ bản gốc. Không tự bổ sung số 9. Không gán STK gửi hoặc số dư thành STK nhận/số tiền.
4. Người kiểm chứng xác nhận giá trị từ ảnh gốc (ground truth), sau đó so sánh độc lập với canonical và lab. Kết quả từng trường: đúng, sai, thiếu, thêm thừa, chưa xác minh. Phân biệt ảnh không in giờ với OCR bỏ sót giờ; không được đánh điểm đúng cho dữ liệu chưa xác minh.
5. Nhóm nguyên nhân theo bank + layout + field + failure class. Cập nhật rule chung bằng nhãn/vị trí tương đối/định dạng, không hardcode giá trị/mã bill hoặc nhãn mẫu chưa kiểm chứng. Mỗi biến thể phải có ít nhất 2 ảnh độc lập được xác minh trước khi đề xuất vị trí cố định; mẫu chỉ có một ảnh vẫn là giả thuyết. Giữ các ca ngoại lệ.
6. Chạy regression trên tập phát triển và tập giữ lại theo hash (không để ảnh trùng lọt qua hai tập). Thêm ca tổng hợp âm tính: sai người nhận, thiếu giờ, mờ, xoay, dấu trang trí, memo nhiều dòng, phí/số dư, nhiều dòng GD, STK che số. Kết quả đọc thử không ghi vào canonical.
7. Chỉ sau khi xác minh, owner backend xem xét revision có bằng chứng cũ/mới, người duyệt, rule version, lý do; không tự ghi thu, không thu lại bill đã thu. Nếu cần đối soát lại, đi qua BILL-FLOW-03–08 và matcher hiện tại. Không dùng lab để thay status tài chính.

## 4. Hàng đợi đầu tiên
| Nhóm | Mã | Điều cần xác minh |
|---|---|---|
| VPBank | BILL-53A01132, BILL-627F96E4, BILL-DDF8C135 | Ngày đã lưu, giờ không có trong dữ liệu; tìm giờ giao dịch thật hoặc xác nhận ảnh không in |
| Techcombank | BILL-0E58D02E | Có dữ liệu giờ in, thiếu ngày giao dịch |
| Techcombank | BILL-76CB1C09, BILL-13516026 | Thiếu timestamp, đọc ngày và giờ riêng |
| BIDV | 2 bản ghi thiếu tiền (chọn bằng SELECT) | GD, số dư, phí và chiều tiền |
| Chưa rõ | 73 ứng viên | Phân loại trước; ưu tiên 32 thiếu timestamp, 10 thiếu tiền |

Sau đợt ưu tiên, lấy mẫu đúng từ VietinBank, Vietcombank, MB, Co-opBank, MoMo, SHB, MSB và nhóm non_bill/duplicate làm hồi quy; không giả định dữ liệu cũ đúng.

## 5. Thước đo và cổng đóng
- Coverage = số ảnh gốc đã xác minh / số mẫu chọn; theo từng ngân hàng/biến thể. Field exact match = số giá trị chuẩn đúng / số trường có ground truth; tách precision với recall, số false-filled absent/unreadable và số trường chưa xác minh. Không báo % nếu mẫu số 0.
- Báo riêng độ chính xác ngày, giờ, tiền, STK và phân loại; không che lỗi quan trọng bằng trung bình. Điều kiện đề xuất: không có trường sai được điền tự tin trên tập regression quan trọng, 100% ca thiếu giờ/ảnh mờ chuyển xác minh, không regression trên mẫu đã đúng. Đây là cổng nghiệm thu đề xuất, không phải độ chính xác đã đo.
- E0 inventory; E1 có ảnh gốc và ground truth + bản sửa/test; E2 CI đúng head; E3 backend version/Pages tương ứng; E4 thử ảnh thật trong phiên admin; E5 xác nhận. Hiện E0 only. Không ghi thu thật, không chạy AI hàng loạt; tối đa 1 yêu cầu/ảnh trong lab mỗi lần chủ động, chỉ đọc lại có lý do, giới hạn nhóm ban đầu 6 ảnh và ghi chi phí/thời gian nếu có.

## 6. Bằng chứng và giới hạn
SELECT trực tiếp public.chat_bank_bill_receipts, storage.buckets/objects ngày 26/11; xem source v0-bill-vision-manual v9 và owner docs. Chưa lấy bytes ảnh, chưa có ground truth, không chạy mô hình mới, không sửa kết quả lưu hoặc quyền. Không đổi HTML hay version runtime. P05.1 độc lập về tài liệu, không chặn PR UI đang chạy.
