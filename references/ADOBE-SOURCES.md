# Adobe React Spectrum — nguồn học hành vi và trạng thái
[Upstream pinned](https://github.com/adobe/react-spectrum/tree/7743784aa065cd42bf0d144ddc5dd5e03e0e651f) · [Manifest](upstream/adobe-react-spectrum/manifest.json). Apache-2.0, LICENSE/NOTICE giữ nguyên. 9 source + 2 license files, .txt nghiên cứu, không chạy. Đã mở file và đọc đoạn hợp đồng liên quan, chưa đọc hết mọi module.
| Chủ đề | File | Điều học | Trạng thái 0v |
|---|---|---|---|
| Nhập số | react-aria/numberfield/useNumberField.ts + react-stately/numberfield/useNumberFieldState.ts | text tạm vs parsed number, commit, step/min/max, buttons | Đối chiếu Input/Quantity tiếp |
| Chọn danh sách | useSelectableCollection.ts + SelectionManager.ts | focus tách selection, stable keys, all keys | Chưa làm Collection API chung |
| Search | useSearchField.ts | clear/submit, giữ focus mobile | Đối chiếu danh bạ, không sửa keyboard |
| Table | useTable.ts | grid semantics, row count, layout visible | Density sửa trong cha; chưa virtual table |
| Virtualizer | Virtualizer.ts | visible views, reuse, overscan, anchor | Chưa áp virtualization |
| Định dạng số | NumberParser.ts | locale-aware parse, partial number | Rà vi-VN, không tự diễn giải nội dung bill |
| Popup/scroll | usePreventScroll.ts | scroll lock đếm vòng đời, scrollbar gutter, iOS visual viewport | Chỉ tham khảo, KB-LOCK giữ nguyên |
Các đường dẫn @react-aria/*/src cũ không còn hợp lệ ở ref hiện tại; source đã chuyển packages/react-aria/src và packages/react-stately/src. Xem manifest cho đường dẫn/sha đầy đủ. Đề xuất bước kế tiếp Selection/Collection độc lập với nhiều dữ liệu, NumberField commit và Virtualizer; không tự nhận đã tích hợp Adobe.
