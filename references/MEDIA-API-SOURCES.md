# MEDIA API — nguồn bài toán 10
- [MUI ImageList](https://github.com/mui/material-ui/blob/master/packages/mui-material/src/ImageList/ImageList.js) blob 7f23316ae7835965b28a38ccd0cf9bfcfaae14ce: cols/gap/rowHeight/variant thuộc cha, context xuống item.
- [MUI ImageListItem](https://github.com/mui/material-ui/blob/master/packages/mui-material/src/ImageListItem/ImageListItem.js) blob aeac6e4e7949b187ddad1815fc0bfff4973ba50c: cover, width/height, row/col spans. Học phân biệt layout và ảnh, không lấy nguyên CSS.
- [PhotoSwipe ZoomLevel](https://github.com/dimsemenov/PhotoSwipe/blob/master/src/js/slide/zoom-level.js) blob 45630eb2f27f473e210f2420e4dd4fb5b5aa6c64: fit phụ thuộc ảnh và viewport, secondary/max riêng, tính lại khi resize. 0v dùng zoom 1–4 lần fit và scroll trong viewer; không có gesture engine PhotoSwipe.
- Không nhập dependency. Video, pinch, EXIF và native iOS/PWA PENDING. 4 nhóm mẫu riêng, dữ liệu ảnh SVG tự tạo.
