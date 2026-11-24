# FAMILY STUDY — danh sách bài học chưa hoàn thành v13.36

| Study ID | Cha tạm | Bài học cần bổ sung | Trạng thái |
|---|---|---|---|
| STUDY-AVATAR | Layout.frame + Typography | MUI/Fluent avatar, size, image fallback, tròn vuông | PROVISIONAL |
| STUDY-LAYOUT-SLOTS | Layout/CSS legacy | profile riêng shell/header/contact/message/grid; ownership gap/padding | PROVISIONAL |
| STUDY-SCROLL | ScrollController | scroll anchoring, bảo vệ Keyboard | PROVISIONAL |
| STUDY-MEDIA | MediaController | grid, ảnh/video, viewer | PROVISIONAL |
| STUDY-CARD | CardController | slots, surface, heading | PROVISIONAL |
| STUDY-TABLE | TableController | semantic table, số, căn trục | PROVISIONAL |
| STUDY-DIAGNOSTIC | Audit | UI debug tách khỏi runtime | PROVISIONAL |
| STUDY-CLASSIFY | Review | xác định họ/cha, không tự tạo style | NEEDS-STUDY |
| STUDY-SURFACE | Surface CSS hiện hữu | paint, trạng thái tương tác, glass, radius ownership | PENDING |

Mỗi bài học cần source GitHub trực tiếp, hợp đồng owner, test cha–con và đo browser. Không tự coi nhãn là đạt.

## v13.38
Avatar now has provisional API bind; study remains. Surface.bind uses existing CSS, not new paint engine. Layout slot selectors migrated outside protected ranges; specialized geometry/state, composer/keyboard and protected surface remain unchanged. Do not remove PROVISIONAL without proof.

## v13.39
Main tree is built through parent factories instead of hand-written UI tags. Existing provisional specialized layout, Scroll, Media, Card, Table and Surface study still required; source migration is not a native-device or visual approval.

## v13.40 — STUDY-SURFACE
Read MUI Paper and Radix Card source, added five paint variants, standalone Surface lab and CI. Legacy glass and Main unchanged. Browser CI and native/visual validation pending at commit; integration decision deferred.

## v13.42 — STUDY-AVATAR
API implementation and 7 lab cases; every four contact rows tested by ID, header update and image/fallback. Browser CI pending at commit; native/visual and remote-image policy pending. v13.41 release automation remains separate unverified branch.

## v13.43
Reopened Avatar MUI/Radix sources; Fluent path not found. Media learned MUI ImageList and PhotoSwipe; gallery and viewer API implemented, lab/browser test pending at commit. Video, gestures, local preview migration and native still provisional.
