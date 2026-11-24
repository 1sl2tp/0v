# MEDIA API — nguồn bài toán 10
- [MUI ImageList](https://github.com/mui/material-ui/blob/master/packages/mui-material/src/ImageList/ImageList.js) blob 7f23316ae7835965b28a38ccd0cf9bfcfaae14ce: cols/gap/rowHeight/variant thuộc cha, context xuống item.
- [MUI ImageListItem](https://github.com/mui/material-ui/blob/master/packages/mui-material/src/ImageListItem/ImageListItem.js) blob aeac6e4e7949b187ddad1815fc0bfff4973ba50c: cover, width/height, row/col spans. Học phân biệt layout và ảnh, không lấy nguyên CSS.
- [PhotoSwipe ZoomLevel](https://github.com/dimsemenov/PhotoSwipe/blob/master/src/js/slide/zoom-level.js) blob 45630eb2f27f473e210f2420e4dd4fb5b5aa6c64: fit phụ thuộc ảnh và viewport, secondary/max riêng, tính lại khi resize. 0v dùng zoom 1–4 lần fit và scroll trong viewer; không có gesture engine PhotoSwipe.
- Không nhập dependency. Video, pinch, EXIF và native iOS/PWA PENDING. 4 nhóm mẫu riêng, dữ liệu ảnh SVG tự tạo.

## v13.44 gestures
- [PhotoSwipe zoom-handler.js](https://github.com/dimsemenov/PhotoSwipe/blob/master/src/js/gestures/zoom-handler.js) blob 4703733cdf9699b3350fdf14bef82993d1a9088e: distance ratio, midpoint and focal pan. [drag-handler.js](https://github.com/dimsemenov/PhotoSwipe/blob/master/src/js/gestures/drag-handler.js) blob b19723a545f2ddafbca2b2024f399f0d0d22e674: pan bounds and gesture transitions.
- [Panzoom panzoom.ts](https://github.com/timmywil/panzoom/blob/main/src/panzoom.ts) blob a1e74bd8d21002dd3dcb58ac9dbe2c961c6e98b7: local touchAction, bounded scale, element-level lifecycle. 0v uses native scroll rather than transform physics; no dependency, inertia, swipe-close or navigation. Simulated Chromium pointer test only, iOS/PWA pending.
