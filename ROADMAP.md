# Tiến trình hoàn thiện CHAT CRM 0v

**Mốc gốc:** v13.163 — 335ee17249d061ebec9aa6656204572c1e70aecb; index blob 71461d93541241b9fa8b3aa365056582ee3c4c18. Ngày 26/11/2026 (VN).
**Mục tiêu:** hoàn thiện theo hệ thống cha–con; không tạo API mới nếu owner hiện có giải quyết được.
**Bước đang chạy:** P01.4 — phân loại thành phần chờ xác minh theo vùng/owner; [bản đồ P01](references/P01-OWNER-MATRIX.md).
**Tiếp theo:** đọc log P01 pending groups, chọn nhóm rendered lớn/có tác động thực; chứng minh hợp đồng cha bằng test hoặc sửa owner nếu tái hiện lỗi; P01.5 native pending.

## Bảng tiến trình duy nhất
Trạng thái: TODO → DOING → E1 → E2 → E3 → E4 → DONE (E5 nếu cần chấp nhận). BLOCKED có lý do, bằng chứng và điều kiện gỡ. E0 tái hiện/kiểm kê; E1 sửa + kiểm thử; E2 CI; E3 Pages; E4 thiết bị; E5 chấp nhận. Ký hiệu E chỉ dùng khi có bằng chứng tương ứng. PENDING thiết bị không được biến thành DONE vì Chromium đạt. Đếm hoàn thành theo từng giai đoạn đã nghiệm thu, không theo số commit.

| ID | Công việc | Trọng số | Trạng thái | Điều kiện đóng |
|---|---|---:|---|---|
| P01 | Thư viện cha, font, hình học, rule | 15 | DOING | Bảng owner/consumer cho Main, lab, token; test đổi token, layout 320/375/390/430/768/desktop; không owner trùng |
| P02 | Input, keyboard, media | 15 | TODO | v13.27 được giữ; một native picker; ảnh/tệp/hủy/đa ảnh, draft, Safari/iPhone/PWA/Android thực tế không rơi input |
| P03 | Chat, danh bạ, điều hướng | 10 | TODO | Tìm kiếm, mở phòng, giữ draft và anchor; tin mới/đọc cũ/ID trùng, media và hội thoại dài |
| P04 | Sync, offline, thông báo | 15 | TODO | Main dùng store/receipt/presence/notification; fixture delivery ledger và reconnect/replay/multi-device; không thông báo trùng; staging trước khi tích hợp thực |
| P05 | OCR và đối soát Agribank | 15 | TODO | Một ảnh một bill; OCR từng trường, thiếu giờ/ảnh mờ phải xác minh; ngân hàng đã xác minh, chống trùng, lệch ngày thông báo; DB fixture không thu hai lần |
| P06 | CRM: đơn hàng, công nợ, báo cáo | 15 | TODO | Đơn tạm/đã giao, giá riêng, nhập hàng, nợ đuổi, chu kỳ, tiền/thời gian VN, báo giá và receipt; dữ liệu mẫu có đối chiếu |
| P07 | Hiệu suất, bảo mật, PWA | 10 | TODO | Có baseline và phép đo trước/sau; kiểm thử quyền/phiên/cache, offline/update, không lộ thông tin; kiểm tra runtime |
| P08 | Nghiệm thu tổng thể | 5 | TODO | Hồi quy tất cả lỗi, CI/Pages/thiết bị/chấp nhận, rollback snapshot; không lỗi nghiêm trọng còn mở |

**Tiến độ nghiệm thu ban đầu: 0/8 giai đoạn; 0/100 trọng số.** Đây là điểm tiến trình mới, không phải điểm chất lượng của bản v13.163.

## P01 — các bước con
- P01.1 (E2, PR #131 merged; kiểm kê ban đầu): kiểm kê tĩnh owner và đối chiếu danh mục; ghi baseline.
- P01.2 (DOING, bản đồ source đã ghi; chưa chứng minh toàn bộ runtime): phân loại từng owner: Main trực tiếp/gián tiếp, lab-only, chưa chứng minh; dùng familyAudit/ownerAudit/apiProof, kiểm tra phạm vi thực.
- P01.3 (E2, 24 lượt đo font/geometry mẫu đã đọc, PR #132 merged): lập ma trận token/font/gap/viền/hình học theo vùng và kích thước, phát hiện chỗ con tự ghi đè.
- P01.4 (DOING, sửa CI đỏ của PR #133; tách pending rendered/hidden): đối chiếu active rule với lịch sử, sửa từng owner có test, nguồn upstream và bằng chứng.
- P01.5 (TODO): chạy audit-design, browser CI, Pages, ma trận thiết bị; ghi nhận ngoại lệ và E5 nếu cần.

## Kiểm kê tĩnh lần 1 — P01.1
Nguồn: [index.html tại baseline](https://github.com/1sl2tp/0v/blob/335ee17249d061ebec9aa6656204572c1e70aecb/index.html), [danh mục API](references/COMPONENT-API.md), [RULES](RULES.md), [nhật ký](CHANGE-CHECK.md).
- Phát hiện 66 tên khai báo const theo mẫu tên API/Controller/Store/Registry/Runtime/Updater và nhóm UI được chọn. Đây **không phải** tổng số API, không chứng minh độ phủ.
- Danh sách: Input, MediaController, PopupController, Surface, Popup, IconController, ButtonController, Icon, Button, Typography, Geometry, Layout, FamilyRegistry, Avatar, DecimalAPI, TimeAPI, FormatAPI, ParseAPI, MoneyAPI, CalendarAPI, ScheduleAPI, RuntimeContextAPI, PresenceController, NotificationController, DurableAlertController, MessageStore, ConversationStore, ReadStateController, SyncController, MultiDeviceController, OfflineCommandController, NoticeDeliveryAPI, OrderNoticeProjectionAPI, NoticeRecoveryAPI, CacheController, DirectoryController, Contact, Message, MainDataController, Main, BusinessProjectionAPI, CardController, TableController, BillEvidenceAPI, BillDuplicateAPI, BillImageIntakeAPI, BillOCRFieldAPI, BillRecognitionAPI, BillOCREngineAPI, AgribankNoticeAPI, BankMemoEnvelopeAPI, BankTransactionIdentityAPI, BankReconcileAPI, BankIdentityBatchAPI, BankOCRCorrectionAPI, BankAccumulationAPI, BankBacklogAPI, BankFieldCompareAPI, BankRecheckController, BankJournalAPI, BankReviewQueueAPI, ScrollController, InputController, KeyboardController, OwnerRuntime, ReleaseUpdater.
- Trong đoạn Main.mount được quét tĩnh, 7 tên có truy cập dạng Owner.method: Input, Surface, ButtonController, Layout, Avatar, Contact, Main. Không tính lời gọi qua wrapper, alias, event handler, factory hoặc phạm vi bên ngoài đoạn Main; không suy ra owner còn lại là lab-only.
- Runtime đã có các điểm kiểm tra familyAudit, ownerAudit, apiProof, mainDataAudit, mainReadAudit, mainNotificationAudit, auditGeometry, crmPerf, pickerAnchorProof. Dùng lại thay vì tạo controller thứ hai.
- Baseline release: [verified release](https://github.com/1sl2tp/0v/actions/runs/45611942994), [Pages](https://github.com/1sl2tp/0v/actions/runs/45611980527) thành công. E4 chưa đủ.
- Vướng đã biết: keyboard v13.27 đã được người dùng xác nhận, nhưng native picker giữ bàn phím trên iPhone chưa giải quyết dứt điểm (v13.156); v13.163 chỉ projection thông báo mẫu, chưa delivery thật; OCR và DB hiện là fixture, chưa có đo chất lượng corpus thực.
- Astryx upstream chuẩn theo audit manifest là https://github.com/meta/astryx (không dùng link suy đoán).

## Vận hành từng vòng
1. Đọc file này, AGENTS, RULES active index, COMPONENT-API và CHANGE-CHECK. Xem main/version/PR/CI hiện tại; nếu PR vòng trước chưa có kết quả, xử lý trước.
2. Chọn bước con chưa hoàn thành theo dependency. Chỉ một thay đổi có phạm vi rõ một vòng. Nếu bị chặn bởi thiết bị, ghi BLOCKED và chỉ chuyển sang nhánh độc lập có lý do, không đánh dấu đạt.
3. Học Astryx + nguồn thứ hai phù hợp; interaction đọc Adobe; ghi path, commit/blob, bài học, giới hạn. Không tạo owner trùng.
4. Cập nhật rule trước/cùng patch, test hồi quy và giữ mốc keyboard v13.27; ghi bằng chứng thật.
5. Mở PR, chạy CI; CI đỏ sửa cùng bài toán, không bỏ test. CI đạt mới merge theo cổng hiện hành. Phát hành tự động, không deploy tay. Chỉ tăng version giao diện khi runtime/UI thay đổi; cập nhật tài liệu không tạo bản app giả.
6. Cập nhật bảng và nhật ký: ID, trạng thái, phiên bản, PR/CI/Pages, E4/E5, blocker, bước kế. Không đánh dấu DONE thiếu bằng chứng.
7. Khi người dùng yêu cầu “làm tiếp”, tiếp tục bước kế trong file này. Không tự kích hoạt lịch nền; không gửi tin thật, thu thật, thay DB production, truy cập/copy ảnh riêng tư vào repo hoặc sửa repo khác. Tích hợp dữ liệu thật cần phạm vi/cho phép riêng.

## Nhật ký tiến trình
| Ngày VN | Bước | Kết quả | Tiếp theo |
|---|---|---|---|
| 26/11/2026 | P01.1 | E0 một phần: baseline và danh sách khai báo tĩnh; chưa chạy runtime trong vòng tài liệu | P01.2: kiểm kê trực tiếp/gián tiếp và lab, kiểm tra các diagnostic hiện có |

| 26/11/2026 | P01.1–P01.3 | PR #131 merged; [API CI](https://github.com/1sl2tp/0v/actions/runs/45683556620) và [DB CI](https://github.com/1sl2tp/0v/actions/runs/45683556625) đạt. Bản đồ owner + chỉnh chỉ mục + ma trận test, CI mới pending | Đọc log, xử lý mismatch, E4 pending |

| 26/11/2026 | P01.3–P01.4 | PR #132: [API PR CI](https://github.com/1sl2tp/0v/actions/runs/45684219123), [API push CI](https://github.com/1sl2tp/0v/actions/runs/45684203289), [DB CI](https://github.com/1sl2tp/0v/actions/runs/45684219109) đều thành công; merge a71a63a3537c307d96243a263ad9e783b49f4a70. 24/24 lượt đo khớp font trong mẫu; phân nhóm pending theo vùng/owner, negative control; CI mới pending | Đọc nhóm pending và xác minh từng owner; không hạ tiêu chuẩn |

| 26/11/2026 | P01.4 | CI PR #133 [45684897457](https://github.com/1sl2tp/0v/actions/runs/45684897457) và push [45684881030](https://github.com/1sl2tp/0v/actions/runs/45684881030) fail; job 139454727771: ReferenceError FamilyRegistry is not defined ở pendingEvidence. DB 45684897443 success. Sửa test qua public familyAudit; chưa xác nhận CI mới | Đọc log nhóm pending sau CI xanh |

Nguồn rule duy nhất vẫn là RULES.md. Tài liệu này chỉ theo dõi công việc và bằng chứng; không thay đổi hợp đồng API.
