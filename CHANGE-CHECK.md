# CHANGE-CHECK — v13.30 (2026-11-24)
## Phạm vi
0v only. Bổ sung cổng tuân thủ RULE và API cha Button/Icon, không sửa CSS, Keyboard, Input API, production.
## Rule đối chiếu
AGENTS.md; RULES.md chỉ mục hiện hành; GOV-01–05, UI-01, BTN-01–04, KB-LOCK-01–05, INPUT-API-05, RULE-GATE-01–06, BUTTON-API-01–05; references/COMPONENT-API.md. AGENTS cũ nhắc v11.1 đã chỉnh thành v13.27 được người dùng duyệt.
## Ngoại lệ
Không có ngoại lệ chủ ý đối với rule hiện hành. Phạm vi BUTTON-API-04: HTML tĩnh và nút QA/upstream giữ nguyên; không coi là đã di chuyển toàn bộ SVG/nút. Không tự áp dụng thay đổi cho repo khác.
## Kiểm thử và bằng chứng
- Đã thực thi hàm auditDesign từ audit-design.cjs bằng JS sandbox trên index.html, RULES.md và snapshot v13.27; 12/12 nhóm đạt, trong đó Button/Icon 10/10 DOM stub, Input 9/9, text 11/11, viewport 12/12, fast path 8/8, early-close 15/15. 6 classic script parse.
- Lệnh CLI node audit-design.cjs chưa chạy trực tiếp trong checkout vì connector không có môi trường checkout; cùng hàm audit đã chạy, không coi là CI. Đây là giới hạn phương thức kiểm tra RULE-GATE-05, không phải bỏ kiểm tra. Browser/PWA/thiết bị, Pages: PENDING.
- So sánh 4 vùng bảo vệ v13.27 và Input API với v13.29 nguyên văn. Snapshot v13.30 trùng blob 68ae13fc24b681be915be6927d80c8ea6a70ad0c. Code commit e4d3d97e26dadbe6f18d7b918fc24dd3146d25c0.
## Rủi ro còn lại và hoàn nguyên
Kiểm tra native button click/submit, disabled, focus/blur, copy/share/save/forward, icon label và hình học trên Safari/PWA. Nếu hồi quy chỉ hoàn nguyên thay đổi Button/Icon về v13.29, không ghi đè snapshot v13.27. Chưa duyệt UX. Không thay thế baseline đã khóa.
