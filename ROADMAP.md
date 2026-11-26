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

- v13.200 P05 E1: automatic sequential local OCR of all loaded original images; actual counts, pause/resume, single worker; session-only; CI/Pages/native pending.

- v13.200 before release: explicit Legacy OEM 0 and strict recipient/transaction context, lexical nonbill signals, 17 synthetic tests. Real image and classical visual classifier pending.

- v13.201 P05 E1: horizontal count groups and original-byte exact dedup before OCR; startup error detail. Bank hints, persistence, speed/device evidence pending.

- v13.202 P05 E1: shared Bill API initialization before live gate, synthetic standalone runtime regression added; CI/Pages and real OCR assets pending.

- v13.203 P05 E1: thumbnail priority and shared bounded session storage cache, throttled audit refresh. No visual exclusion, actual request metrics/CI/native pending.

- v13.203 revision: one pass and same-tab checkpoint; manual refresh only; no automatic retry or repeated card rebuild. CI/live pending.

- v13.204 revised: manual one-image read and explicit verify; session results and non-sensitive label signature local store. CI/live pending.

- v13.205 P05 E1: display six fresh OCR fields on explicit manual read; preserve raw/edit/verify. CI/Pages/device pending.

- v13.206 P05 E1: manual LSTM worker reuse, bounded upscale, six-field layout parsing. CI and real 600-image accuracy pending; PaddleOCR/RapidOCR benchmark separate.

- v13.208 P05 E1: replace standalone manual LSTM with one-shot authenticated Gemini Vision read, six fields; CI, endpoint tests and live accuracy pending.

- v13.208 presentation revision: remove raw OCR and duplicate AI text; six fields only, optional field edits; CI pending.

## v13.208 — backend hotfix 2: manual Vision timeout
Observed 502 at 33494 ms on 2026-11-26 04:36:42 UTC with ai_timeout. Keep Gemini 3.5 Flash, explicit MINIMAL thinking, 75s provider timeout instead of 30s, one model request only; retain original image and authorization. Log only model/status/duration/error class, never contents. Supabase idle limit 150s; Google Gemini thinking docs consulted. No frontend version or ledger change; actual successful read pending. Rollback prior function source.

## v13.209 — LIVE-BILL-AI-LITE-01
Production Gemini Flash logs show two provider HTTP 200 responses at 67987 and 69784ms and one timeout at 75002ms. Switch only manual bill Vision to gemini-3.5-flash-lite, supported MINIMAL thinking, original image, same single-call budget and 75s deadline; no automatic retry, no financial writes. Google Gemini thinking documentation consulted (https://ai.google.dev/gemini-api/docs/thinking). During retry show current in-flight state rather than stale timeout; retain prior successful fields if new request fails and show latest failure. Backend deploy and real-image accuracy/latency must be checked separately from CI.

## v13.210 — LIVE-BILL-VIETINBANK-LAYOUT-01
User confirms BILL-BEB34B9E as VietinBank sender layout. On each explicit manual Vision request, first identify sending bank from app header/logo, not beneficiary bank, then apply relative layout only if VietinBank matches: amount center, small date/time/reference under amount, recipient name and account below arrow, right-aligned one/two-line memo ending before Xem thêm. Never copy transaction values or infer missing digits. Add editable sending_bank alongside six existing fields; old AI results may lack bank until reread. One model call, no auto scan, no financial mutation. This is prompt guidance, not model training. Synthetic fixture verifies display; accuracy on new real images pending.

## v13.211 — LIVE-BILL-VIETCOMBANK-LAYOUT-02
User identifies BILL-70A42109 as VCB Digibank. Inspected enlarged screenshot: logo upper left, centered success/amount/small time line, two-column details with account ABOVE recipient name, bank next, memo right one/two lines before fees/method/reference. Exact fine print too blurry to independently validate all digits; prompt uses only positions/labels, no sample values. Apply layout conditionally and retain generic fallback; normalize sender bank aliases VCB Digibank to Vietcombank. One explicit AI call, no ledger writes, no automatic scanning. Existing VietinBank layout retained. Real-image accuracy not yet verified.

### v13.211 — Co-opBank sender recognition
User identifies BILL-2B8C7111 as Co-opBank; exact receipt record confirms stored sender COOPBANK. Original image pixels were not accessible in this session; no claim of verified field geometry. Add conditional sender-brand recognition and normalize aliases to Co-opBank, use actual labels with generic evidence-only reading until an image is visually reviewed. No hardcoded relative positions, no sample transaction values, no extra AI request. Existing VietinBank and VCB layouts remain. Actual read and CI pending.

## v13.212 — LIVE-BILL-BANK-TYPE-03
User provided ten sample IDs; matched database metadata for all, not original image pixels. Registry: 233071C7 Techcombank receipt; 207D5514 BIDV receipt; 53A01132 VPBank receipt; 95AF248A BIDV balance notice (stored sender_debit); 8268651D MoMo wallet transfer; 1C0AD231 MB balance notice (user identifies MB, stored sender null; sender_debit); 4CBFF2A9 MB receipt variant 1; AC4B545C MB receipt variant 2; 33B118A9 SHB receipt; 36652584 MSB receipt. No transaction values in prompt, no unverified fixed geometry. New type field separates transfer receipt, debit notice, credit notice, wallet transfer and unclear; sender aliases normalized. For notices distinguish GD from SD, read actual DEN/ND if present; do not infer recipient or credit confirmation. Keep both previous verified-position guides and Co-opBank label-based fallback. One explicit AI request, no scan or ledger mutation. Actual sample pixels unavailable; layout variants not visually verified. CI/live verification pending.

## v13.213 — LIVE-BILL-REGION-EVIDENCE-01
User requests analysis of all registered bank examples and rules by region. Prior inspected layouts: VietinBank, VCB and alternate Techcombank photo with notification above main receipt. Existing deployed rule source includes BIDV journal memo-only. Ten newly referenced originals cannot be visually opened with current connector; metadata is not image evidence. Do not invent fixed geometry for Co-opBank, VPBank, MB receipt variants, SHB, MSB, MoMo, BIDV receipt. Add conditional Techcombank and BIDV guidance and generic label-based field discovery. Same single manual Gemini call returns seven optional normalized field boxes [ymin,xmin,ymax,xmax] of original full image; backend/frontend validate bounds, invalid boxes omitted, non-bill boxes null. Optional button Xem vùng AI đọc shows estimated boxes on unrotated original using scoped image cache, not an independent verification. Session-only checkpoint; no training/automatic rule promotion, no extra AI calls, no financial or database writes. CI and accuracy pending; actual per-bank geometry requires owner review.

## v13.214 — LIVE-THREAD-BILL-AUTO-01 (0v only)
User corrects scope: /bill.html is the manual lab; live conversation must read automatically next to original image. Reuse the same v0-bill-vision-manual prompt/region rules through an exact conversation+asset+message request. Server verifies user, signed AAL2 claims, active admin conversation scope, inbound sender and exact media; no client storage key, service role, grants or writes. Previously recognized bill candidates plus single incoming image in last 48h become eligible when visible in opened 0v thread; old unrelated galleries and outgoing images unchanged. Sequential one-request-at-a-time queue, same image on 429 only, >=60s or Retry-After, max three retries; successful results cached in same tab/account (up to 100), cleared on signout. Fresh fields never backfilled from old OCR; only existing independent ledger state is retained, no financial writes or CHAT changes. Unknown/nonbill stays ordinary gallery. Image may be rotated and Techcombank Tới/Đến is a label, not part of recipient name. Scope change stops retries; when page closed/suspended no guaranteed background run. Existing old financial status is not proof of fresh OCR accuracy. No durable server queue or real-time delivery added; this is automatic foreground reading. Sources: https://supabase.com/docs/reference/javascript/auth-getclaims and existing v0_admin_read/v0_admin_media SQL; https://ai.google.dev/gemini-api/docs/rate-limits. E1 policy/syntax fixtures only; full CI, release, Edge deployment and physical/real-image verification pending. No keyboard or other repo change. Based on pending region PR #195, not competing with its version.

## v13.215 — LIVE-CHAT-CACHE-SYNC-01 / LIVE-DIRECTORY-GROUP-01
User reports 0v filters, refresh, read counters and local/new message priority. Live DB contact_group customer 62, cm 49, other 26, friend 11; role=user is authorization not grouping. Existing admin_read exposes boolean only. SQL candidate preserves exact live function auth/scope/avatar and adds contact_group + count; existing boolean displayed as dot, not fabricated 1. No mark-read RPC yet; no read ACK writes. SQL not applied. Authorized thread snapshots 12 rooms / 24h same tab/account, restored after validated directory; clear on signout, reuse existing bounded image RAM cache. Foreground Realtime wake (existing v21_messages publication, actual RLS delivery unverified), online/visibility, 30s fallback; coalesced, skip navigation/send; keyed message DOM reuse, retain scroll. New send appears after actual server ACK before refresh. Existing backend returns 100 latest snapshots, not true cursor delta; durable IndexedDB, realtime device tests and read ACK pending. No production or CHAT/keyboard changes. Source receipts: CACHE-API-SOURCES, SYNC-API-SOURCES, Adobe SelectionManager pinned. Provisional session snapshot rather than durable CacheController cursor because live cursor contract absent. Stacked on #196. Pure policy and JS syntax verified; full CI/Pages/device pending.

### v13.215 — vòng 2 / LIVE-CHAT-TEXT-FIRST-02, LIVE-READ-ACK-01
Same unreleased PR #197, no competing version. Prior head 0a913ee CI API application check 45761630745 passed. New candidate: text render from scoped thread result before media request, retained cached media, refresh open thread before directory; preserve server-acknowledged new message across temporarily stale snapshots by ID (memory only, server wins when present). Avoid full openThread on send for real room, retain draft/scroll owners. Read ACK gated by backend capability; visible focused current chat, full visible incoming node dwell 1000ms sampled 500ms, no dialog/hidden, scope check. SQL review-only adds own/peer receipt timestamps and exact count; verifies active admin+AAL2, conversation membership, exact inbound message IDs, never device time, advance only contiguous incoming timestamp prefix (ties block), monotonic upsert; no live read writes executed. Older unseen prefix and oversized items block advancement (no false read). Peer read shown only using server receipt and actual server message date. Existing CHAT uses same read state; no CHAT code changes, shared receipt effect only after approved deployment. Source existing READ-API-01–06, v21_mark_read live definition (uses now(), not reused), existing v0 scope, v21_read_states unique key and message time index. Full cursor-based delta, durable IndexedDB and multi-device verification remain pending. JS parse/pure merge/context tests passed in connector; CI, SQL isolation test, deployment, real device pending. Rollback prior branch head; no production change.

### v13.215 vòng 2 — hardening
Throttle identical read proposals to 30s even on network failure or directory refresh; remove acknowledged observed IDs. Partial text render knows media completeness only for cached message IDs, avoiding incorrect missing-attachment label and unnecessary unchanged-node replacement. SQL explicitly qualifies unnested requested IDs. Candidate only; exact-head CI and SQL integration pending.

### v13.215 vòng 3 — LIVE-INSTANT-CONTENT-01
User requests no loading/sending text in normal live chat. Existing LiveChatSnapshotPolicy projects cached data and optimistic message immediately using client key; clear composer at enqueue, reconcile exact id on ACK, preserve newer draft, retain error and original idempotency key on failure. Directory/thread no loading text; live media aria-busy without loading text, reuse blob cache for attachments. Bill audit remains unchanged. Cold cache must await real response; no prewarm in this patch, no durable offline queue. Existing authorization, keyboard and backend unchanged. Source receipts CACHE/SYNC-API-SOURCES, Astryx Button/Stack, Adobe SelectionManager (previously inspected). Added delayed-ACK browser regression; syntax and pure policy checked; CI/native pending. Same PR #197 unreleased.

### v13.215 vòng 3 — bounded text prewarm
After authorized login, once idle for 2.5 seconds, prewarm at most three other recent uncached authorized conversations, text only, sequential requests; no download of images, skip on navigation/send/hidden/live sync. Independent background thread reads validate account/session/contact and never increment foreground request token; do not overwrite a cache filled by foreground. This supersedes no-prewarm statement in preceding patch. Cold uncached rooms still wait on network. Syntax checked; real-device performance and full CI pending.

### v13.215 vòng 4 — LIVE-COMPOSER-TAIL-01 / CONTENT-UNICODE-01
User screenshot v13.213: composer 82%, last message under input when focused, directory latest and capitalization. Keep keyboard viewport owner and original baseline unchanged for fixture/non-live; live mobile floating composer width 94% on focus-within (rest 82%), focus explicitly follows latest, reuse ScrollController and measured composer reserve during keyboard occlusion only while anchor pinned; user scroll cancels anchor. No new viewport writer. Incoming append reestablishes tail observer when pinned. Directory parent uses latest server timestamp, transient local text preview for just-sent and fresh received messages (30s max, server wins on newer/equal timestamp, remove on failure); sort by recent activity and wake 150ms (existing coalescing). Contact and Content share capitalization, preserve emoji ZWJ/modifiers/flags and punctuation; preserve raw database text, no UTF-16 truncation in live projection; native emoji font fallback. Existing markup interpretation unchanged. Existing read counts not fabricated. Source: existing ScrollController/Main, INPUT-TEXT and KB-LOCK contracts, pinned Astryx Stack/Button and Adobe SelectionManager study. Tests added emoji/line casing and live composer width/tail geometry; syntax and pure text fixture checked, full exact-head CI and iOS physical keyboard pending. No DB, CHAT or bill changes. Same unreleased PR #197.

### v13.215 release repair
CI 45764922069 failed keyboardBaseline and textInputContract, all 12 input fixtures individually passed. Restore all four protected ranges byte-for-byte to last passing candidate 53b66a9; separate live-only tail adapter outside protected ranges uses existing ScrollController.end/followEnd, no viewport geometry writer. Explicit pointer/touch/wheel/blur cancels tail intent; room/epoch guard. Count 12 Unicode cases, do not remove assertions. Full exact-head CI pending, native iPhone pending.


- v13.216 P01 explicit user request: rich content display; E1 policy and source proof, CI/native pending, stacked on #197.

- v13.217 explicit screenshot follow-up: message rhythm, jump count, group/unread, sync. E1; CI/native pending.


## v13.221 — LIVE-THREAD-BILL-NEW-ONLY
Explicit user request supersedes v13.214 48h/known-receipt eligibility and quota retry. Authorized session starts at billNewAfter; valid incoming image/message/room IDs, strictly newer timestamp, no receipt/cache. One automatic attempt per asset reserved before model request, no automatic retry; quota cooldown and manual lab separate. New multiple images handled one image at a time; historical galleries grouped. Cache bill/nonbill/unclassified in existing scoped session storage. F5 skips previous timestamps, switching room does not reset attempts. Existing 64MB/64-item blob cache reused; object URLs may be recreated. Device clock cutoff can miss offline or skewed messages; no background scans or durable cross-device claim. No DB/Edge/financial writes, protected keyboard ranges unchanged apart from version labels. References prior CACHE-API-SOURCES/SYNC-API-SOURCES (stable scoped identity, stale guards), existing ThreadBillAutoPolicy; local policy fixture pass, CI/device pending. Release v13.220 merged separately after exact-head CI.


## v13.222 — BILL-ACCOUNT-DECORATION-01
Observed case: stored AI text contained 13 uninterrupted digits followed by a space and one bullet; normalized recipient was null. In 0v ParseAPI receiver evidence and v0-bill-vision-manual validation, remove only one separated terminal bullet after exactly 13 uninterrupted digits. No digit insertion, no masking substitution, no removal of interior bullet, no general punctuation stripping. Keep original OCR text in existing record. Recognition alone never authorizes collection. Exact synthetic regression verifies 13-digit terminal decoration, rejects shorter/longer and interior/repeated bullets as normalization candidates. The specific existing unposted record was separately corrected at user's request with original OCR and audit trail preserved; status remains review and ledger_id null; no model rerun or financial posting. Legacy v21 scan worker is separate and not changed in this 0v PR. Source and runtime Edge deployment not equivalent; verify full CI before release, deploy Edge separately only after verification. No keyboard changes beyond version labels.


## v13.223 — LIVE-BILL-SINGLE-READER-01
User request: one new authoritative reader writes bill facts; existing collection permissions/logic remain independent. CHAT PR #425 adapts the 0v regional guide to the existing inbound worker and shared receipt table; 0v live chat consumes v0_admin_media.bill_receipt only. Remove browser OCR queue, local result preference and all automatic conversation inference; old clients calling the previous conversation Edge path receive 409 before storage/model calls. Keep authorized explicit receipt-id lab preview non-authoritative for now; it does not update ledger or canonical receipt. Existing live media projection and scoped snapshot cache, image blob reuse, grouped galleries, new message sync and financial gates unchanged. The legacy session cache prefix remains only for signout cleanup. No database writes or new permissions. Coordinate CI and deployment of CHAT canonical worker and 0v Edge guard, then publish; no claim of live cutover yet. Historical lab migration to the same reader remains pending. Source inspected: 0v v0_admin_media/admin_bill_audit live definitions and CHAT #425, same bank region rules and 10-field evidence schema. No keyboard geometry change. Classic scripts parse and static no-browser-queue regression added; exact CI/device pending.

| 26/11/2026 | P01.4 / L02 media | PR #208 candidate: same-room lifecycle and image cache; real Chromium exposed bill frame cascade conflict, bank fixture passed. Corrected shared rule, exact-head CI pending. | Verify both CI; then CRM list/owner inventory. |


### LIVE-BILL-PAIR-01 — Single-image sizing cascade
Exact head 28234c6: API CI 45811305172 failed at photoHeight>0 after frame equality assertions passed; DB fixture 45811305166 passed. Existing single-gallery selectors have higher specificity than earlier bill image override and impose intrinsic auto height. Within the existing wide live bill container, explicitly size the single tile and contained image to the positioned gallery frame; no new owner, no !important, narrow layout unchanged. Fixture now supplies a real local SVG and intrinsic ratio; retains original assertions and adds image-to-frame height equality. Re-read Astryx Stack blob c56d72759ad2f6f86102228e22c3123530b32894 and MUI ImageListItem blob aeac6e4e7949b187ddad1815fc0bfff4973ba50c. No keyboard or production changes. Full CI and native Safari pending; no local full-repo audit.


## v13.225 — LIVE-THREAD-BOUNDARY-01
User reports contact-to-thread media jumps, unexpected composer activation and overlapping content. E0 source: partial text and final media can independently call Main.finishNavigation for the same epoch, final cold snapshot used preserve=false, and floating content viewport extends behind controls. E1 candidate: deduplicate live navigation settlement by room/epoch, preserve user scroll/follow state after first settlement, prevent independent media scroll write during navigation, make composer inert only during mobile route entry and release on settle/error/reset/route change. Use existing measured top and composer reserve to clip message paint/hit-testing (no extra viewport writer, no change to scroll padding or glass control geometry). Composer remains available for intentional focus after settlement. Existing KB-LOCK protected ranges byte-identical to v13.224. Sources re-read Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894, Adobe useSelectableCollection 739a9433b098c081ce872815f10fbc83ba07172c (focus separate from selection), MUI ImageListItem aeac6e4e7949b187ddad1815fc0bfff4973ba50c (frame sizing). Classic scripts parsed; added browser regression for unrequested focus and hit testing. Full CI/native iOS pending; no device reproduction of phantom focus, no claim cold media never shifts (server dimensions may be absent). No DB/finance/keyboard owner change. No intentional rule exception; source-only review not complete global runtime audit. Rollback prior main v13.224.


### v13.225 — LIVE-THREAD-STABILITY-02
Exact CI d1dee50: DB 45814411464 passed; API 45814411483 failed browser line 98. Fixture initially loaded desktop viewport (floating defaults to 0) before resize to mobile; explicitly select floating=1 in second login URL and add detailed diagnostics, keep all assertions. Source audit: live contact time uses max-content track; changing timestamp changes name width. Use fixed 72px live timestamp track and tabular numbers, preserve full-width preview and fixed row height. Wide bill pending/ready must share one card-driven image frame and border, loading/retry button positioned inside without affecting layout. Normal cold images without intrinsic metadata can still resize. Snapshot reconciliation preserves first visible stable message ID and relative offset rather than raw scrollTop when reading history. Do not adjust while touching; no new viewport/keyboard writer; preserve protected ranges. Re-read Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894, Adobe Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1 and MUI ImageListItem aeac6e4e7949b187ddad1815fc0bfff4973ba50c. Add directory geometry test; 7 classic scripts parsed; CI and physical Safari pending. No financial/DB changes. No claim of zero shift or complete device audit. Same PR #210 before release.


### v13.225 — CI fixture route correction
Head 6ad974c: DB fixture 45816373775 PASS; API 45816373707 passed static and snapshot, browser timed out at login line 73. Explicit floating query without live=1 selects demo by design (liveParams whitelist v/r/__build), not live login. Restore original v/r-only route coverage; set the mobile viewport before navigation so the genuine default mobile floating profile applies. Keep all focus, hit-test, directory geometry and downstream assertions unchanged. Test script syntax parsed; no runtime/HTML/snapshot/keyboard change. Rerun exact head CI; native pending.


### v13.225 — LIVE-THREAD-STABILITY-03: composer focus geometry
Exact head 3f7aa6f DB 45816661391 PASS; API 45816661517 static/snapshot PASS, browser progressed through boundary, directory, media and first native picker tests, then timed out opening the second native chooser at line 157 after removing all attachments. Source review: live mobile width expands on :focus-within, including plus/send buttons; that can move the pressed target on focus before click. Restrict width expansion to actual textarea focus (attachments retain their existing 94% profile), no protected keyboard changes. Add test that focus on plus cannot move its x or composer width; wait for single-mode state following attachment removal and retain native chooser count/cancel assertions with event diagnostics. Also avoid marking an already-open same-room send fallback as a new navigation; only settle cached room if pending. Sources Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894 and Adobe useSelectableCollection 739a9433b098c081ce872815f10fbc83ba07172c. Seven classic scripts and fixture syntax parsed; exact CI/native pending. Cause of chooser timeout is a hypothesis until test passes. No production/DB/finance writes.


## v13.226 — LIVE-RESUME-01–03: keep authenticated screen, no background reload
User reports white “Đang khôi phục phiên…” on reopen/resume/F5. E0: v13.225 boot awaits directory, thread and media RPC before showing root; any session heartbeat failure clears UI; ReleaseUpdater can replace live location during resume. E1: keep server-confirmed admin + AAL2 and fresh authorized directory before exposing cached content; cached thread renders before waiting for new media, preserve saved route/scroll via Main. On restored contacts do not fetch hidden conversation; CRM restores screen and back goes to contacts if no selection. Already-visible authorized screen survives recognized transient network failures, heartbeat skips hidden page, explicit denial/unknown errors still fail closed; no change to backend access/permissions. Do not force auto release navigation while live screen visible; retain version polling and pending version notice, manual refresh remains available. Save view on hide/pagehide. Genuine F5 or iOS process eviction still reconstructs document and requires authentication; no cached private UI before verified server scope, no promise zero loading. Existing cache metadata, not persistent image binaries. Re-read Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894 and Adobe Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1. Browser regression delays media RPC across reload and checks cached text/route visible before release; existing offline boot security assertions retained. Seven classic scripts + fixture parsed; E2 CI and native device pending. No DB or finance changes; protected keyboard ranges identical. This supersedes auto-navigation for active live screen only; demo release contract unchanged. Rollback v13.225.


## v13.227 — LIVE-MEDIA-SCROLL-01–03
User reports image loading/adjustment during scroll after v13.226. E0: IntersectionObserver starts scoped load near viewport; completed grouped image decoding immediately replaces DOM even while touching/momentum; existing scroll protection only gates scroll writes, not geometry change, and prepared blob gallery sets loading=lazy again. E1: keep existing scoped download/decode cache, eager display already-decoded blob, defer image group paint while touching or 180ms post user scroll, or hidden/non-chat, then batch queued paint in ScrollController with one stable reading-anchor/tail transaction. No parallel viewport writer. Pending callbacks are room/scope/connected guarded; clear on media teardown; schedule on route settlement/resume; no new download/retry policy or RPC. Guard snapshot scroll writes and tail ResizeObserver during momentum. Existing prepared media identity retained; audit image route uses existing independent behavior. Cold images lacking metadata can still change height after scrolling stops; not a universal fixed-size frame or guarantee of zero layout shift. Synthetic test holds initial image download, releases while touch active, verifies unchanged group height and no gallery replacement until touchend; existing cache/gallery/anchor/browser checks retained. Sources read Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894, Adobe Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1, MUI ImageListItem aeac6e4e7949b187ddad1815fc0bfff4973ba50c. Seven classic scripts and fixture syntax parsed; exact CI and native Safari pending. Protected keyboard ranges identical; no database/finance change. Rollback v13.226.


## v13.227 — P05.1.2 / BILL-ORIGINAL-EXPORT-01
User requests original image audit. Existing authenticated standalone lab strips prior OCR from list and loads raw private image Blob through auditOriginal/auditBlobCache. Add explicit per-image “Tải ảnh gốc” then native download link named by BILL code and actual MIME; raw Blob, never rotated display data, no new Storage/Edge/AI request path, reuse session cache and auditMediaUrls revocation, recheck scope+asset+storage key and connected view after await. No upload or automatic export, public URL, permission or financial changes. Search accepts multiple codes separated by whitespace/comma/semicolon, preserves single-code partial matching. Existing API bounded returned rows; missing code not fabricated. Native iOS Save to Files needs user click and verification. Six prioritized codes in P05.1 spec PR #213. User must attach downloaded images for independent review because connector lacks authenticated storage bytes access. Browser fixture checks multi-code filtering, original PNG magic/MIME/name and no AI call; static sample search 3/3 and seven classic scripts + fixture parsed. Prior PR #212 exact head 50102c4 passed DB 45821370814, API 45821370792 failed post-synthetic-touch tail check line 114 after paint deferral passed. Explicitly restore latest intent after newly introduced touch experiment before original tail regression; retain reopen and later tail/no-pull tests, add diagnostics. Test intent correction, not proof all scroll issues resolved. Combined in existing unreleased v13.227 to avoid competing UI release versions. Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894 and Adobe useSelectableCollection 739a9433b098c081ce872815f10fbc83ba07172c inspected; reuse Button/Media fileLink and scoped loader, no new parent UI geometry. CI/E3/E4 pending; rollback v13.226. No ground truth or AI accuracy claim.


- v13.227 PR #212 post-touch tail regression: E1 candidate LIVE-MEDIA-SCROLL-04; content resize observer independent of tail intent, explicit jump and no-follow test. CI/Pages/native pending; keep v13.226 until exact-head gates pass.

- v13.227 #212 E1 LIVE-MEDIA-SCROLL-05: reconcile clamped tail; three grow/shrink cycles; exact head CI pending.

- v13.227 #212 E1 LIVE-MEDIA-SCROLL-06: extent-aware follow intent; exact head CI pending.

- v13.227 E2 merged f0e6d4c; repeat #213 CI reproduced tail race. v13.228 E1 LIVE-MEDIA-SCROLL-07, explicit intent and coalesced reflow; exact-head and repeat CI required. E3/E4 pending.

- v13.228 #214: E1 repair active rule version index; prior static CI only version false; browser CI not reached. Repeat exact-head checks pending.

- L04 v13.229 E1: LIVE-READ-ACK-02 monotonic confirmed receipt; stale directory/ACK guard; CI pending. Bill P05.1 fixture merged 5a7ca7e, real image adapter remains blocked.

- L04 v13.229 E2: PR #215 CI 45856567686/45856567792 passed, merged a5e0549. v13.230 E1: user-reported jump arrow jitter prioritized over oversized read coverage; one scroll transaction; CI and native pending.

- v13.230 #216: E1 test-only correction of closure scope, no runtime change; prior Chromium CI 45857578005 failed before one-write assertion. New CI pending.

- L04 v13.231 E1: live uses shared READ-API-06 segment coverage; static pure test passed, CI pending; server prefix remains authoritative. v13.230 E3 Pages 45858620412 success, E4 pending.

- L04 v13.231 E2 merge 6ebffd0, both CI passed. v13.232 E1 LIVE-CACHE-MEDIA-01 preserves confirmed media knowledge on transient RPC failure; CI pending.


- L07 / v13.233 E1 — ALERT-DURABLE-06: add atomic single-use pre-effect permit to existing DurableAlertController. Revalidate same actor/installation/message/room/sender/sequence, lease token/time and latest supplied read/permission/route via NotificationController; suppressed/unavailable terminal, route change before effect releases lease to replan, same identity; known no-effect foreground stays push-only; started/unknown never blindly replay. Settlement requires permit. Lab uses beginEffect before MessageChannel. Static contract and classic-script compile passed in connector; full audit-design/browser CI pending. No production delivery, actual SW, subscriptions, server outbox, receipt freshness guarantee or iPhone evidence. Existing fixture records without new event identity fail closed; no reset of dedup storage. Source reread WHATWG notifications.bs aad8341ddb2a313ab203a1b33752dd410038450b (tag replacement not ledger), Workbox messageSW c4146e21c11434a75466a31263f94bd7798c82e6 (no reply unresolved), Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894 (layout independent), Adobe SelectionManager d6ff15c5b5efd7f9be685f87f46c3ed251c093f5 (focus separate). No copied upstream code. No keyboard/scroll source changes except version labels; rollback v13.232. Prior #218 exact head CI 45860124203 and 45860122790 passed, merge 862eee88; Pages unverified.


- v13.234 E1 / LIVE-MEDIA-JUMP-02: user reports mobile arrow still shakes after v13.230. Source E0: live snapshot restore uses physical nearBottom alone instead of explicit follow intent; late independent image completions immediately write tail; resize observer also writes before scheduled reconcile. E1: retain explicit same-room follow through snapshot refresh, no history anchor restoration during follow; enqueue late image completions under existing ScrollController while following, drain in existing jump frame before one clamped tail correction; resize and media follow schedule same frame. Explicit jump still drains ready jobs and writes once, user wheel/touch cancels as before; away-from-tail image anchor path unchanged. Added browser regression for two late image paints with one tail write, retained earlier tests. Seven classic scripts and browser test syntax compile in connector; full audit-design/browser CI pending; physical Safari momentum/compositor not reproduced, unknown cold image extent may still shift across frames. Read Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894, Adobe Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1, TanStack virtual-core 4bd3531db01d98838db8bea9cfd8b5c62568b4c7 (anchor and offset reconciliation). No keyboard/viewport owner edits, no Push/network/DB changes; rollback v13.233. Prior #219 CI 45860803340/45860803424 passed, merged 330372b4; Pages unverified.


- v13.234 test-only / LIVE-MEDIA-JUMP-03: #220 exact-head CI 45905482604 and 45905482603 passed; merged 5872063d. Add targeted Playwright WebKit mobile touch context using existing synthetic SDK, deny unmatched requests, locator.tap on jump arrow, late two-image batch exactly one scrollTop write, stable tail and away negative control. Chromium path retained. No runtime or version increment. Test syntax passed; actual CI pending, physical Safari momentum/compositor not simulated. Reread pinned Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894 and Adobe Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1; no new owner. Release gate unchanged for test-only PR.


- v13.235 candidate / LIVE-MEDIA-JUMP-04: source inspection shows queued image paint can become orphaned if explicit follow is cancelled before scheduled jump frame without a subsequent scroll event. Existing jump frame hands off queued media to existing deferred image scheduler when not following/interacting, not navigating; no new scheduler or scroll owner. Mobile live message scrollport only sets overscroll-behavior-y:none to reduce edge bounce where supported (MDN https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollTop; WebKit issue https://bugs.webkit.org/show_bug.cgi?id=187449 for historical momentum caveat; not proof of user's cause). Keep native scrolling, touch, keyboard and layout; four protected keyboard ranges byte-identical before version labels. Add synthetic queue/cancel-without-scroll regression in Chromium and WebKit, CSS computed assertion. Classic scripts and test syntax passed; no real WebKit/physical Safari test yet. Read pinned Astryx Stack c56d72759ad2f6f86102228e22c3123530b32894 and Adobe Virtualizer 3959c1cc7666f0384d31af2c770c6902662cdcb1. Depends on #221 test-only QA; do not merge this draft until #221 is accepted, main reconciled and exact-head CI passes. Rollback v13.234; no production data or Push changes.


## SCROLL-01 — approved priority migration (P02/P03/L04/L06)
- S0 DOING: resolve #221/#222 CI WebKit image failure, release only exact-head green.
- S1a E1 candidate: central physical edge metric, passive tail policy, one-shot focus; isolated checks pass, full CI pending.
- S1b E1 candidate: manual settle/rearm, saved intent and ID/offset, visual-edge diagnostic; exact CI, deleted-anchor fallback and native keyboard/history verification pending.
- S2a E1 candidate: ordinary live fixed slots and 1–4 geometry tests; CI pending.
- S2b E1 candidate: single live bill fixed state/portrait narrow frame and existing equal-height wide frame; wide/narrow CI proof pending. Audit geometry separately scoped. Verify real metadata availability and cold inventory changes.
- S3a E1 candidate: A/B projection/replay/ACK use shared scoped scroll transaction; explicit local send owns follow, delayed ACK history regression pending CI.
- S3b E1 candidate: bounded nearest surviving anchor and file/audio/video reservation; browser proof pending, actual Realtime subscription race and native keyboard/restore remain.
- S4 TODO: Chromium/WebKit and actual Safari/PWA/Android E4, no premature DONE.

- S3b retest: CI 45909511526 non-follow growth failure; preserve strict assertion and diagnostics; mock Realtime/viewport proof added, pending exact CI.

- S3b evidence: dc21898 Chromium 0px attachment/anchor drift; Realtime fixture locator ambiguity fixed, retest. S3c settled viewport trace and Realtime history assertions pending.
- S4 acceptance protocol: on actual iOS Safari and installed PWA, Android Chrome/PWA, test 3 cycles each of entry, jump, keyboard open/close at tail, manual history with incoming/ACK, slow/error/retry media, F5/restore; record browser/device/OS/build and frame/anchor evidence. Do not equate simulated viewport or headless WebKit with native keyboard/momentum/compositor. Targets: settled tail gap <=2px, visual gap >=0, stable anchor <=1px when not clamped, one owner write per batched jump, zero redundant writes after settle; no real customer messages modified by QA.

- S4 v13.240 candidate: opt-in device diagnostic implemented; exact CI and native device evidence pending. Reports are local, no messages/IDs exported. Use 3 cycles per scenario.

- S4 retest: scoped probe and utility entry, actual query test, native evidence pending.

- S3d v13.241 candidate: late dimensional metadata neutral projection; preserve bill expansion/media and anchor on receipt update. Native and CI pending. Full media inventory arrival and class change require separate acceptance, not fixed by this patch.

- v13.241 Pages success 45913172927. S3e v13.242 candidate: parent structural projection queue, late inventory / classification and persisted pageshow fixture. Actual device S4 pending.
