# Tiến trình hoàn thiện CHAT CRM 0v

**Mốc gốc:** v13.163 — 335ee17249d061ebec9aa6656204572c1e70aecb; index blob 71461d93541241b9fa8b3aa365056582ee3c4c18. Ngày 26/11/2026 (VN).
**Mục tiêu:** hoàn thiện theo hệ thống cha–con; không tạo API mới nếu owner hiện có giải quyết được.
**Bước đang chạy:** P03-LIVE — 0v trở thành CHAT CRM thật (user xác nhận không quay lại CHAT cũ); P01 tiếp tục theo nhu cầu UI nhưng không chặn chức năng live.
**Tiếp theo:** phát hành gửi text thật; tiếp nhận realtime, lịch sử, sửa/thu hồi, ảnh/tệp/ghi âm, Push độc lập, OCR và nghiệp vụ CRM theo các bước bên dưới.

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
7. Khi người dùng yêu cầu “làm tiếp”, tiếp tục bước kế trong file này. Không tự kích hoạt lịch nền; không gửi tin thử thật, thu thử thật, truy cập/copy ảnh riêng tư vào repo hoặc sửa repo khác. User đã cho phép chức năng 0v thao tác dữ liệu thật khi admin trực tiếp sử dụng; API production mới phải giới hạn thao tác và có kiểm thử, không sửa dữ liệu khách để test.

## Nhật ký tiến trình
| Ngày VN | Bước | Kết quả | Tiếp theo |
|---|---|---|---|
| 26/11/2026 | P01.1 | E0 một phần: baseline và danh sách khai báo tĩnh; chưa chạy runtime trong vòng tài liệu | P01.2: kiểm kê trực tiếp/gián tiếp và lab, kiểm tra các diagnostic hiện có |

| 26/11/2026 | P01.1–P01.3 | PR #131 merged; [API CI](https://github.com/1sl2tp/0v/actions/runs/45683556620) và [DB CI](https://github.com/1sl2tp/0v/actions/runs/45683556625) đạt. Bản đồ owner + chỉnh chỉ mục + ma trận test, CI mới pending | Đọc log, xử lý mismatch, E4 pending |

| 26/11/2026 | P01.3–P01.4 | PR #132: [API PR CI](https://github.com/1sl2tp/0v/actions/runs/45684219123), [API push CI](https://github.com/1sl2tp/0v/actions/runs/45684203289), [DB CI](https://github.com/1sl2tp/0v/actions/runs/45684219109) đều thành công; merge a71a63a3537c307d96243a263ad9e783b49f4a70. 24/24 lượt đo khớp font trong mẫu; phân nhóm pending theo vùng/owner, negative control; CI mới pending | Đọc nhóm pending và xác minh từng owner; không hạ tiêu chuẩn |

| 26/11/2026 | P01.4 | CI PR #133 [45684897457](https://github.com/1sl2tp/0v/actions/runs/45684897457) và push [45684881030](https://github.com/1sl2tp/0v/actions/runs/45684881030) fail; job 139454727771: ReferenceError FamilyRegistry is not defined ở pendingEvidence. DB 45684897443 success. Sửa test qua public familyAudit; chưa xác nhận CI mới | Đọc log nhóm pending sau CI xanh |

Nguồn rule duy nhất vẫn là RULES.md. Tài liệu này chỉ theo dõi công việc và bằng chứng; không thay đổi hợp đồng API.


## Chuyển hẳn sang 0v — phạm vi user xác nhận 26/11/2026
| Bước | Chức năng live | Trạng thái |
|---|---|---|
| L01 | Admin login độc lập, danh bạ thật | E4: ảnh user v13.169, 148 liên hệ |
| L02 | Mở hội thoại và đọc nội dung | E2 fixture v13.169; thiết bị chưa xác nhận nội dung |
| L03 | Gửi tin text thật, mở phòng mới, chống gửi trùng | E1 v13.170 |
| L04 | Nhận tin realtime, đọc/đã đọc, phân trang lịch sử, offline | TODO |
| L05 | Sửa/thu hồi/trả lời/chuyển tiếp tin | TODO |
| L06 | Ảnh, video, tệp, ghi âm, camera, xem media | TODO |
| L07 | Push 0v độc lập, không phụ thuộc UI/phiên CHAT cũ | TODO |
| L08 | OCR bill, đối soát, đơn, hàng, công nợ, báo giá, báo cáo | TODO |
| L09 | Nghiệm thu thay thế hoàn toàn, giữ khả năng rollback | TODO |

Không đánh dấu các bước TODO là hoạt động chỉ vì quyền admin đã được cấp. CHAT cũ không bị tắt hoặc sửa trong quá trình chuyển. 

L08 / v13.184 E1: show bill exceptions (recipient, account, VN date, missing clock) using existing receipt projection. CI and device pending. Historical isolated OCR rerun remains TODO.

L08 / v13.185: historical transaction date display and explicit Vietnamese mixed dates; isolated date/projection tests passed, CI/device pending.

L08: legacy sender-debit display-only recovery candidate, DB fixture pending; no automatic collection or historic batch.

L08 / v13.186 E1: unified admin bill audit workspace, sort/filter/search, per-field stored evidence and original image on demand. CI/backend/device pending; batch isolated re-OCR separate, no collection.

L08 / v13.187: photo + original OCR, field-level explicit correction/not present, persistent review notes and progress. Full CI/backend/device pending. Not financial approval.

L08 / v13.188: standalone bill review route, same secure APIs, automatic load and audit image lifecycle. CI/Pages/device pending.

L08 / v13.189: dedicated /bill.html entry, source and version synchronized with canonical app; CI/Pages pending.

L08 v13.189 (before release): separate nonbill, wrong account, uncertain and target suffix; hash duplicate evidence not OCR error. CI/migration pending.

L08 / v13.190: stable bill identifiers and exact UUID copy for review feedback.

L08 / v13.191: latest saved OCR review result becomes primary audit display; original OCR expandable. Full CI and Pages pending.

L08 / v13.192: standalone Bill foreground/heartbeat refresh and current data timestamp; pending CI/Pages.

L08 / v13.193: persisted per-bill OCR and result save timestamps, Vietnam timezone; CI/RPC/Pages pending.

- v13.194 P05: scoped saved-review progress and honest AI completion label; E1 source and synthetic check; CI/Pages pending; production Batch invocation remains blocked.

- v13.195 P05: explicit unavailable Batch controls and read-only sync, E1 source and syntax; actual Batch production remains BLOCKED; CI/Pages pending.

- v13.196 P05 E1: single unavailable all-Bill control and estimated group counts; 7 tests; real Batch execution and durable campaign remain BLOCKED. CI/Pages pending.

- v13.197 P05 E1: standalone simple image/content review per user; remove Batch UI; existing stored results only, actual reread remains blocked. CI/Pages pending.

- v13.198 P05 E1: bank-group selector and headings in standalone review, unknown/nonbill distinct. Uses stored OCR only; CI/Pages pending.

- v13.198 E1 revision: user requires image-only baseline; all loaded images unclassified until new OCR; no prior fields or classification used in standalone. New-result backend remains unavailable.

- v13.199 P05 E1: local explicit single-image classification from original, printed-text heuristic and suffix rule, uncertain group; new OCR results in page memory only. No external AI or ledger; CI/Pages/native pending.
