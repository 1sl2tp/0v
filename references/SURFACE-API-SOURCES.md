# SURFACE API — nguồn nghiên cứu v13.40

- [MUI Paper.js](https://github.com/mui/material-ui/blob/master/packages/mui-material/src/Paper/Paper.js), blob ac7ab3888de661f5165ebd92f1baf720270c12c1. Đọc trực tiếp: ownerState, outlined/elevation variant, theme tokens, shadow/overlay. 0v chỉ học phân loại paint; khác MUI, radius thuộc Layout.
- [Radix Card.tsx](https://github.com/radix-ui/themes/blob/main/packages/radix-ui-themes/src/components/card.tsx), blob 0cfd9183a9d555f8bf8344f66d6cd8f30a9cb6ba. Đọc trực tiếp: extractProps, Slot.Root, rt-BaseCard, composition. Học cách tách variant khỏi nội dung. Không nhập React hoặc dependency.

Giữ nguyên SURFACE-CONTEXT và KB-LOCK của 0v. 5 variant là thiết kế riêng, không khẳng định giống Apple native. Chưa hoàn thiện bài toán vật liệu động, Safari/PWA và chuyển Main. Lab ?surfacelab=1 trong Công việc.
