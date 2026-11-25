# BILL OCR pixel stress — v13.135

Executed 2026-11-25, native Tesseract 5.5.0, languages vie+eng. Synthetic account/name only. Not browser WASM and not customer corpus. Pillow generated a 1100×620 white image with Noto Sans Regular 32 px, title 40 px; seven labelled lines at x=45 and values x=370, y=100+i×70. Known value crops x=360..1060, y-4..y+47. Full image PSM 6, field crop PSM 7; whitelists copied from fieldOCRProfile for account/name/amount/time. Other fields unrestricted. Exact NFC and whitespace comparison; account ignores presentation spaces. No font or customer image committed.

| Condition | Account | Name | Amount | Date | Time | Memo | Ref | Exact |
|---|---|---|---|---|---|---|---|---|
| Saved clean | pass | pass | pass | pass | pass | pass | pass | 7/7 |
| Downsample 550×310, upscale, blur 0.7 | pass | pass | pass | pass | pass | pass | pass | 7/7 |
| Simulated background, crop, blur 1.15 + 0.3 | pass | pass | pass | pass | pass | pass | pass | 7/7 |
| Downsample 275×155, upscale, blur 0.9 | pass | pass | pass | pass | pass | pass | pass | 7/7 |
| Heavy blur 3.0 + 0.3 background/crop | pass | fail | fail | pass | fail | pass | fail | 3/7 |

Known field crops: 31/35 exact, not a general accuracy estimate. Full-image low-resolution OCR incorrectly returned amount 400.090,8 VND rather than 400.000,8 VND, name NGUYÊN VAN MAU and label Ngày giao địch. The value-only amount pass correctly read 400.000,8 VND. Heavy blur typed output name='', amount='', time='151632', reference='FT123⁄4%4789'; no correction or inferred value. Synthetic truth: account 1234567 99999 9; name NGUYEN VAN MAU; amount 400.000,8 VND; date 24 tháng 11 năm 2026; time 15:16:32; memo KH MAU DON A 123; reference FT123456789. The native run did not exercise automatic crop selection or browser worker lifecycle. Real journal screenshot and customer photos still pending.
