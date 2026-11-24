# Astryx — nguồn học của 0v
[Upstream pinned](https://github.com/meta/astryx/tree/d63c24970f9ab1dc5e3024a7123ec7edee2a0f11); [manifest](upstream/astryx/manifest.json), MIT. 18 file bản sao .txt chỉ để đọc. Không nhập React/StyleX. Đã đọc AGENTS/knowledge map/public API, Avatar, Button, Text, Stack, tokens và các đoạn liên quan Card/Table. Spec/test còn lưu để đọc sâu, không khẳng định toàn bộ đã học.

| Bài | Astryx | Nguồn thứ hai đã đọc, blob | Bài học áp dụng |
|---|---|---|---|
| 10 Media | Chưa xác định nguồn media phù hợp | Plyr src/js/plyr.js c1378986661798a921294aa3c176591b4eb4222e; blueimp/JavaScript-Load-Image js/load-image-orientation.js c3d53c4513d0466530ea454108034715115b57e6; fengyuanchen/compressorjs src/index.js 82079cbe5d494203da4fc331e5b5804be302a698; PhotoSwipe trước đó | vòng đời video, orientation native, canvas encode; nav ảnh |
| 11 Card | Card.tsx 32208a1cca96f5c7bf11c2a34be07e0aca7ae83a | MUI Card.js b8d19527bcc8ec03a58ddeb1cedd47ead57e036b | paint từ Surface, layout riêng |
| 12 Table | Table.tsx 9496cdd32ce30ad6d28707eef48dada3bf2033b4 | MUI Table.js 4d7561a888574b55ab6ac66385346db7441a60d3 | density và padding thuộc cha |
| 13 Scroll | Stack.tsx c56d72759ad2f6f86102228e22c3123530b32894 | TanStack/virtual packages/virtual-core/src/index.ts 4bd3531db01d98838db8bea9cfd8b5c62568b4c7 | follow on append, scroll anchor |
| 14 Motion | tokens.stylex.ts 7ca09a989079c26627462bfe50abbcb08ec1328c | motiondivision/motion packages/framer-motion/src/utils/reduced-motion/use-reduced-motion.ts 765ddd0db187fb27e80cdc739cb1c3cc067968bd | reduced motion |
| 15 Responsive | Stack.tsx | Radix themes get-responsive-styles.ts f6305730f444da1bc3df4a1fa3e529b512855e41 | profile hợp lệ, adaptive layout |
| 16 State | Button.tsx f87eb657180a0de978fb3ba1c59c24909a9cc63d | Radix toggle.tsx 69b3861bc16b80eaf5a6bbc078b996e31e555ea5 | state độc lập, aria-pressed/busy |
| 17 Theme | tokens.stylex.ts | Radix themes theme.tsx b980aa5217c5d50290e7856d735d126d631d6314 | light/dark/system scoped |

Video.js, TanStack Table và MUI createBreakpoints đường dẫn thử không mở; dùng nguồn thay thế. Source refs: https://github.com/sampotts/plyr ; https://github.com/blueimp/JavaScript-Load-Image ; https://github.com/fengyuanchen/compressorjs ; https://github.com/mui/material-ui ; https://github.com/TanStack/virtual ; https://github.com/motiondivision/motion ; https://github.com/radix-ui/themes ; https://github.com/radix-ui/primitives . Học nguyên lý, không sao chép runtime. Các bài 1–9 cần rà lại từ snapshot theo owner; không đổi keyboard. Chưa nghiệm thu codec, EXIF tất cả orientation, dữ liệu lớn, Safari/PWA, Main theme, virtualization hoặc production. ?systemslab=1.