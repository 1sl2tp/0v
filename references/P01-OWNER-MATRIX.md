# P01 — bản đồ owner và ma trận kiểm tra
Baseline index v13.163 blob 71461d93541241b9fa8b3aa365056582ee3c4c18, commit 35c868078dc19921813c47ae3dca698daa734371. Dòng trỏ [index.html](https://github.com/1sl2tp/0v/blob/35c868078dc19921813c47ae3dca698daa734371/index.html). Đây là bằng chứng source tĩnh, không phải coverage runtime. Các tên scan gồm factory, owner và helper, không coi tất cả là API công khai.
## Phân loại đường sử dụng đã kiểm tra
| Vùng | Đường gọi đã thấy | Giới hạn |
|---|---|---|
| Main shell | Main.mount → Layout.slot, View.text → Typography.create, View.button → Button.create/Surface.bind/Layout.applyProfile, Input.create, Contact.create/Avatar.create | Không đồng nghĩa mọi phần tử đã bỏ CSS cũ |
| Danh bạ | showPeople → Collection.project/Contact.visibility; Contact.update; Avatar.create | DirectoryController/Virtualizer hiện có đường lab/support, chưa chứng minh được Main dùng |
| Chat | renderDailyThread / submit / receiveDemo → Message.create; DraftMedia/MediaController; MainDataController → MessageStore, ConversationStore, ReadStateController | Dữ liệu mẫu; không có transport |
| Composer | Input, InputController, KeyboardController, ScrollController; native picker, DraftMedia | Không sửa; baseline v13.27, E4 pending |
| CRM | showModule → BusinessProjectionAPI, CardController/TableController qua wrapper; Bill gọi renderBankBacklogLab ngay trong Main (không phải chỉ opt-in lab); Đơn hàng gọi renderOrderNoticeSummary | Đều là fixture; không ghi thu/gửi thật |
| Notification | MainData.notificationPlan → PresenceController.project + NotificationController.plan | Chỉ projection |
| Opt-in labs/support | Cache/Sync, MultiDevice/Offline, durable alert/recovery, Virtualizer, OCR engine, systems/Theme | Chưa chứng minh live integration; CalendarAPI/ScheduleAPI không có lịch thật |
| Diagnostics | FamilyRegistry.audit/OwnerRuntime; apiProof.report/describe, Geometry | PROVISIONAL không phải lỗi hay DONE; phân biệt paint/geometry/typography và native |
## Kiểm kê chi tiết
Các cột ref chỉ liệt kê tối đa 8 dòng chứa chuỗi Owner.method, ngoài/ trong vùng định nghĩa các lab (3055–3770). Không phải call graph, có thể có comment, helper, alias không hiện; vùng lab có hàm được Main gọi. Phân loại candidate là định hướng xác minh, không coi chưa thấy ref là không sử dụng. Cần kiểm tra từng owner còn chưa xác định.
| Tên | Khai báo | Ref ngoài vùng lab | Ref trong vùng lab | Nhóm cần xác minh |
|---|---:|---|---|---|
| Input | 745 | 1075, 1912, 1913, 3048, 3866 | 3057, 3064, 3107, 3113, 3576, 3584, 3636, 3644 | Main / Main fixture candidate |
| MediaController | 783 | 1860, 1865, 3029 | 3151, 3557, 3609, 3610, 3611, 3616 | Main / Main fixture candidate |
| PopupController | 837 | 883, 885, 887 | — | Main / Main fixture candidate |
| Surface | 862 | 877, 1824, 1925, 1995 | 3121, 3122 | Main / Main fixture candidate |
| Popup | 870 | 829, 3896, 3938 | 3114, 3115 | Main / Main fixture candidate |
| IconController | 889 | 893, 927 | — | Main / Main fixture candidate |
| ButtonController | 892 | 933, 949, 950, 1942 | — | Main / Main fixture candidate |
| Icon | 897 | 943, 3034 | 3075 | Main / Main fixture candidate |
| Button | 931 | 790, 823, 825, 826, 827, 828, 882, 883 | 3077, 3087, 3112, 3140, 3173, 3174, 3175, 3176 | Main / Main fixture candidate |
| Typography | 952 | 799, 821, 1048, 1053, 1069, 1806, 1823, 1997 | 3069, 3070, 3071, 3074, 3086, 3105, 3106, 3107 | Main / Main fixture candidate |
| Geometry | 972 | 4196, 4197, 4396, 4400 | 3089, 3091, 3092, 3094, 3095, 3096, 3097, 3099 | Main / Main fixture candidate |
| Layout | 989 | 824, 867, 1048, 1064, 1069, 1746, 1806, 1824 | 3068, 3071, 3073, 3074, 3075, 3077, 3079, 3080 | Main / Main fixture candidate |
| FamilyRegistry | 1012 | 832, 1005, 1048, 1069, 1995, 4383, 4384, 4402 | 3321, 3551, 3571, 3610, 3614, 3621 | Main / Main fixture candidate |
| Avatar | 1044 | 1069, 1829, 1927, 1988 | 3077, 3129 | Main / Main fixture candidate |
| DecimalAPI | 1099 | 1134, 1147, 1956, 1961, 2064, 2136, 2444, 2446 | 3637, 3646 | Main / Main fixture candidate |
| TimeAPI | 1115 | 1135, 1136, 1137, 1138, 1164, 1165, 1178, 1182 | 3449, 3455, 3456 | Main / Main fixture candidate |
| FormatAPI | 1133 | 1171, 1957, 2005, 2006, 2007, 2587, 2589, 2765 | 3450, 3451, 3453, 3479, 3480, 3481, 3482, 3483 | Main / Main fixture candidate |
| ParseAPI | 1140 | 1962, 2055, 2057, 2060, 2063, 2072, 2087, 2090 | 3478, 3485 | Main / Main fixture candidate |
| MoneyAPI | 1169 | 1958, 1959, 1960, 2955, 2980 | 3478, 3482, 3483, 3484 | Main / Main fixture candidate |
| CalendarAPI | 1176 | — | — | Lab / supporting candidate |
| ScheduleAPI | 1181 | — | 3478 | Lab / supporting candidate |
| RuntimeContextAPI | 1187 | — | 3157, 3204, 3244, 3272, 3298, 3472 | Main / Main fixture candidate |
| PresenceController | 1210 | 1889 | 3242, 3270 | Main / Main fixture candidate |
| NotificationController | 1244 | 1291, 1300, 1305, 1310, 1889 | 3221, 3242 | Main / Main fixture candidate |
| DurableAlertController | 1288 | — | 3224, 3226, 3227, 3238 | Lab / supporting candidate |
| MessageStore | 1323 | 1395, 1547, 1695, 1872, 1896 | 3242, 3292, 3300, 3317, 3343, 3415, 3493, 3520 | Main / Main fixture candidate |
| ConversationStore | 1380 | 1547, 1695, 1872, 1896 | 3317, 3415, 3493 | Main / Main fixture candidate |
| ReadStateController | 1425 | 1547, 1887, 1896 | 3295 | Main / Main fixture candidate |
| SyncController | 1464 | 1548, 1722 | 3424 | Lab / supporting candidate |
| MultiDeviceController | 1526 | 1596 | 3189, 3196, 3197 | Lab / supporting candidate |
| OfflineCommandController | 1560 | — | 3165, 3187, 3188 | Lab / supporting candidate |
| NoticeDeliveryAPI | 1612 | 1640, 1642, 1650, 1655, 1671 | 3384, 3408 | Main / Main fixture candidate |
| OrderNoticeProjectionAPI | 1634 | — | 3629, 3630 | Main / Main fixture candidate |
| NoticeRecoveryAPI | 1648 | — | 3379, 3388, 3389, 3390, 3391, 3392, 3393 | Lab / supporting candidate |
| CacheController | 1689 | 1717, 1720, 1723 | 3357, 3361, 3364, 3368, 3369, 3370, 3371, 3372 | Lab / supporting candidate |
| DirectoryController | 1802 | — | 3323 | Lab / supporting candidate |
| Contact | 1827 | 1911, 1976, 4352, 4355 | — | Main / Main fixture candidate |
| Message | 1862 | 2006, 3866, 4353 | — | Main / Main fixture candidate |
| MainDataController | 1870 | 1948 | — | Main / Main fixture candidate |
| Main | 1903 | 1945 | — | Main / Main fixture candidate |
| BusinessProjectionAPI | 1955 | 1965, 2002, 2064, 2086, 2541, 2751, 2835, 2837 | — | Main / Main fixture candidate |
| CardController | 1994 | 2003, 3053 | 3182, 3214, 3238, 3266, 3288, 3313, 3333, 3355 | Main / Main fixture candidate |
| TableController | 2001 | 2005, 3050, 3054 | 3620 | Main / Main fixture candidate |
| BillEvidenceAPI | 2054 | 2989, 2990 | — | Main / Main fixture candidate |
| BillDuplicateAPI | 2079 | 2111, 2112, 2113, 2114, 2229, 2347, 2563, 2688 | — | Main / Main fixture candidate |
| BillImageIntakeAPI | 2100 | 2352, 2425 | 3677, 3680, 3701, 3708, 3709 | Lab / supporting candidate |
| BillOCRFieldAPI | 2119 | 2267, 2347, 2411, 2425, 2652, 2663 | 3690, 3697 | Lab / supporting candidate |
| BillRecognitionAPI | 2262 | — | 3690 | Lab / supporting candidate |
| BillOCREngineAPI | 2319 | — | 3697, 3706, 3708, 3710 | Lab / supporting candidate |
| AgribankNoticeAPI | 2438 | 2458, 2488, 2553 | — | Main / Main fixture candidate |
| BankMemoEnvelopeAPI | 2455 | 2581 | — | Main / Main fixture candidate |
| BankTransactionIdentityAPI | 2483 | 2614 | — | Main / Main fixture candidate |
| BankReconcileAPI | 2522 | 2477, 2515, 2615, 2624, 2725, 2754, 2757, 2761 | — | Main / Main fixture candidate |
| BankIdentityBatchAPI | 2599 | 2707 | — | Main / Main fixture candidate |
| BankOCRCorrectionAPI | 2647 | 2689 | 3749 | Main / Main fixture candidate |
| BankAccumulationAPI | 2671 | 2660, 2667, 2721, 2778 | — | Main / Main fixture candidate |
| BankBacklogAPI | 2715 | — | — | Main / Main fixture candidate |
| BankFieldCompareAPI | 2744 | — | 3738 | Main / Main fixture candidate |
| BankRecheckController | 2788 | 2828, 2850 | 3669 | Main / Main fixture candidate |
| BankJournalAPI | 2823 | — | 3635, 3637, 3642, 3646, 3657, 3660 | Main / Main fixture candidate |
| BankReviewQueueAPI | 2944 | — | 3656, 3670 | Main / Main fixture candidate |
| ScrollController | 3939 | 1757, 1782, 1787, 1788, 1974, 3858, 3866, 3950 | 3622 | Main / Main fixture candidate |
| InputController | 4114 | 1974, 4026, 4060, 4122, 4124, 4125, 4126, 4129 | — | Main / Main fixture candidate |
| KeyboardController | 4254 | 4256 | — | Main / Main fixture candidate |
| OwnerRuntime | 4255 | — | — | Main / Main fixture candidate |
| ReleaseUpdater | 4441 | 4490, 4491 | — | Main / Main fixture candidate |
| View | 1822 | 1828, 1830, 1831, 1839, 1864, 1866, 1905, 2006 | — | Main / Main fixture candidate |
| DraftMedia | 1846 | 1859, 1860, 3837, 3851, 3866, 3882, 3895, 3897 | — | Main / Main fixture candidate |
| Collection | 1073 | 1976 | 3571, 3583 | Main / Main fixture candidate |
| Virtualizer | 1732 | 1806 | 3554, 3573 | Lab / supporting candidate |
| Motion | 3133 | — | 3623 | Lab / supporting candidate |
| Responsive | 3136 | — | 3624 | Lab / supporting candidate |
| State | 3139 | — | 3625 | Lab / supporting candidate |
| Theme | 3143 | — | 3626 | Lab / supporting candidate |

## P01.3 — chuẩn font đang dùng
PARENT-RUNTIME-02 thay TYPE-01 và TYPE-API-03 về số liệu hiển thị; TYPE-02/03 và TYPE-API-01/02/04–06 giữ phạm vi còn hiệu lực. Giá trị :root v13.163 và test hiện hành:
| Role | Font/line CSS px |
|---|---|
| Version | 10/16 |
| Caption, label, giờ | 13/18 |
| Detail, note, number, money | 14/20 |
| Body | 16/22 |
| Title | 18/24 |
| Chat | 18/27 |
| Input | 17/22; floor 16 |
Không thay thiết kế; chỉ sửa chỉ mục để tránh đọc nhầm quy tắc lịch sử. CSS token là nguồn số; weight 400/500/600/700, legacy có phạm vi riêng.
## Ma trận
CI hiện có tại 320/375/390/430/768/1280: contact 4 dòng, popup, NV chat, input, font/gap/avatar token mutation/restoration, F5, negative wrong-parent. Mở rộng log đọc-only theo vùng: danh bạ, chat, công việc KH/Đơn hàng/Bill. Log role, font mismatch, registration, pending, rect, gap, radius, border, padding, overflow của vùng đã chọn. Kiểm tra có vùng render, không lấy log làm chứng nhận toàn bộ. Không log nội dung khách. CI mới pending. Chưa đo native glyph, zoom, Safari/PWA/Android, theme, tất cả module/lab, không dùng số đo Chromium thay thế E4.
## Nguồn học
- Astryx pinned Stack.tsx blob c56d72759ad2f6f86102228e22c3123530b32894: layout root sở hữu hướng, trục, gap, padding, overflow.
- Adobe pinned useTable.ts blob 6b9108e81fd8bce49ae22fcb5d374331b8a62e49: hành vi và layout delegate tách riêng; không lấy scroll/geometry làm bằng chứng nghiệp vụ.
- Chỉ dùng nguyên lý phân loại và kiểm thử; không nhập code hoặc dependency.


## P01.4 — bằng chứng sau PR #132
PR #132: [API PR CI](https://github.com/1sl2tp/0v/actions/runs/45684219123), [API push CI](https://github.com/1sl2tp/0v/actions/runs/45684203289), [DB CI](https://github.com/1sl2tp/0v/actions/runs/45684219109) đều thành công; merge a71a63a3537c307d96243a263ad9e783b49f4a70.
- Đọc 24 bản ghi P01 matrix từ job 139452352906: 6 viewport × directory/NV chat/KH order/KH Bill. Mọi font role/input đã đo khớp size/line/weight; không selector được đo có scrollWidth-clientWidth >1px; button/icon registration đều khớp. Không phải toàn bộ DOM đã nghiệm thu.
- Chat header floating 320px overflow dọc 18px phù hợp ::before gradient inset bottom -18px (index L430–439); không sửa dựa trên chỉ số này. Bill cuộn dọc là chủ ý.
- Pending 1.307 ở Bill gồm node ẩn và visible; không coi là lỗi. P01 pending groups phân nhóm region/family/parent/status/study, tối đa 3 mẫu tag/slot/profile mỗi loại, không text/ảnh khách; rendered box không đồng nghĩa nằm trong viewport (có thể ngoài vùng cuộn). Hidden/non-box vẫn trong audit tổng. Negative control visible+hidden, phục hồi nguyên trạng; CI mới pending. Không thay runtime hoặc nhãn PROVISIONAL.

### Sửa CI PR #133
CI PR #133 [45684897457](https://github.com/1sl2tp/0v/actions/runs/45684897457) và push [45684881030](https://github.com/1sl2tp/0v/actions/runs/45684881030) fail; job 139454727771: ReferenceError FamilyRegistry is not defined ở pendingEvidence. DB 45684897443 success. Biến FamilyRegistry nội bộ closure không tồn tại trong page.evaluate. Dùng public familyAudit() làm nguồn chính; ghép row qua ID tạm duy nhất chỉ trong test, giữ ID sẵn có nếu unique, restore trước đo; negative probe qua metadata đúng hợp đồng. Không bypass assert hoặc đổi runtime. CI mới pending.


## P01.4 PR #133 E2 and typography candidate
[PR CI](https://github.com/1sl2tp/0v/actions/runs/45685194614), [push CI](https://github.com/1sl2tp/0v/actions/runs/45685183442), [DB](https://github.com/1sl2tp/0v/actions/runs/45685194699) success, merged ca997da7da8cfc38c1ee5d045b0d0552c2a04bda. 24 pending groups: 390px directory 5 rendered/1073 hidden, chat 8/21, order 25/1062 (14 Table), Bill 38/1269 (28 Card). Rendered not viewport visible. v13.164 changes role assignments/token per TYPE-HARMONY, not pending labels. P01 DOING, CI/native pending.
