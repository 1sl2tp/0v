# Live integration map — 0v v13.172
Status is source-level, not physical-device acceptance. One parent owns each feature; fixture is reference contract, not real data. Update this table before each adapter change.

| Bài toán/mẫu | Owner hiện có | Dữ liệu thật/adapter | Trạng thái và bước bắt buộc |
|---|---|---|---|
| Shell, font, geometry, buttons | Main, Layout, Typography, Surface, Button, Icon | Main.mount(live) | PARTIAL; verify same DOM and token geometry on mobile/desktop |
| Đăng nhập, F5 | LiveAuthAPI, sessionStorage view | authenticated account/session | PARTIAL; fixture CI previous pass, real MFA backend enforcement pending |
| Danh bạ/tìm kiếm/nhóm | Contact, Collection, Input, Avatar | ChatReadAPI directory | PARTIAL; backend role currently generic user, business group/avatar source missing; do not infer |
| Nội dung chat một/nhiều dòng | Message, Typography | authorized message body | CONNECTED in patch; preserve text and ownership, regression |
| Ảnh/ghi âm/video/tệp | MediaController, Message | verified asset metadata, private storage | PARTIAL; actual RPC and storage verification pending; multi-image grid, audio/video and missing/error tests |
| Vùng gõ/keyboard/picker | Input, DraftMedia, KeyboardController, ScrollController | text send and local preview | PARTIAL; full keyboard owner and native device verification, upload not connected |
| Realtime/đã đọc/offline | MessageStore, ConversationStore, SyncController, CacheController, ReadStateController | server event/receipt contract | BLOCKED until API verified; no fake delivery |
| Push | RuntimeContextAPI, PresenceController, NotificationController, DurableAlertController | independent 0v subscription and server events | BLOCKED, no fake push |
| Bill OCR | BillRecognitionAPI, BillOCRFieldAPI, BillOCREngineAPI | single authorized image and configured recipient | BLOCKED until real input adapter verified; recognition not collection |
| Bank reconciliation | BankReconcileAPI, BankJournalAPI, BankReviewQueueAPI | verified bank notice + bill + receipt identity | BLOCKED until server contract; no auto-write from text/image inference |
| Đơn, nhập hàng, công nợ, báo giá | BusinessProjectionAPI, CardController, TableController, MoneyAPI, TimeAPI | typed authorized business record | BLOCKED, no synthetic customer figures in live |
| Công việc | Main CRM panel, existing module owners | authorized module data | PARTIAL shell only; backend pending |

## Release and evidence
Prior PR #143 CI success, publish #678 blocked by file allowlist. This candidate keeps the single v13.172 snapshot. The SQL proposal remains at [reviewed source](https://github.com/1sl2tp/0v/blob/da433e9f0dcf87b529f0f49e4eb89030b3881d6f/references/0v-admin-media.sql); separate backend review needed. ROADMAP not modified in this frontend-only release per gate. Keep rule IDs LIVE-INTEGRATE-01–04 in all subsequent PRs. No production records or real sends used for tests.

## v13.173 recovery
Shared runtime initialized before data branch; live swipe/input/scroll use existing owners. E1 only; synthetic browser and native acceptance pending. Media upload, business, realtime and server MFA still pending.

- v13.173 picker parity: shared native picker and DraftMedia lifecycle; live scoped decode and attachment send guard. E1, new CI and native device acceptance pending; no upload.
