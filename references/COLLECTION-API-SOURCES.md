# Collection API — bài 18, v13.47
## Nguồn thực tế đã đọc
- [Adobe SelectionManager](https://github.com/adobe/react-spectrum/blob/7743784aa065cd42bf0d144ddc5dd5e03e0e651f/packages/react-stately/src/selection/SelectionManager.ts) blob d6ff15c5b5efd7f9be685f87f46c3ed251c093f5: selectedKeys, disabledKeys, selectionMode; focusedKey riêng. Bản pinned lưu trong repo.
- [Adobe useSelectableCollection](https://github.com/adobe/react-spectrum/blob/7743784aa065cd42bf0d144ddc5dd5e03e0e651f/packages/react-aria/src/selection/useSelectableCollection.ts) blob 739a9433b098c081ce872815f10fbc83ba07172c: focus navigation, selection, selectAll policy. Không sao chép roving focus/range/keyboard.
- [MUI X RowSelection](https://github.com/mui/mui-x/blob/master/packages/x-data-grid/src/hooks/features/rowSelection/useGridRowSelection.ts) blob a2ac468632e6e464a9c6243790a71a6cc4b25e6a: selection model bằng ID, selectable rows, controlled model. 0v dùng finite include-set, không có remote exclude model.
- [Radix ToggleGroup](https://github.com/radix-ui/primitives/blob/main/packages/react/toggle-group/src/toggle-group.tsx) blob f541158bb2473e64067d23745637f6cc4be5ff79: parent value array, pressed derive, disabled.
- Astryx Table.tsx pinned blob 9496cdd32ce30ad6d28707eef48dada3bf2033b4: đã mở lại, file wrapper không có selection contract trong đoạn tra; không dùng làm bằng chứng selection.
## Áp dụng
Collection.project cho danh bạ, create cho lab 8 hàng. Select visible khác toàn bộ, selection ẩn giữ lại, native pressed và disabled. Không dùng index làm key. Nguồn TanStack Table đường dẫn thử trả không có; dùng MUI X thay thế. Chưa dùng cho duyệt hàng thật, không virtual hóa hoặc async. Test Chromium pending, native pending.
