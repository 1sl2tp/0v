# v13.136 — native OCR stress experiment

2026-11-25. Native Tesseract 5.5.0, vie+eng, PSM 7. Seven synthetic truth strings: 1234567 99999 9; NGUYEN VAN MAU; 400.000,8 VND; 24 tháng 11 năm 2026; 15:16:32; KH MAU DON A 123; FT123456789. Pillow grayscale 550×55, Noto Sans Regular 32px, text at (12,1). Whitelists account/name/amount/time as in fieldOCRProfile; other fields unrestricted. Exact NFC/whitespace comparison, account removes spaces. OMP_THREAD_LIMIT=1.

| Degradation | Original | Autocontrast | 2x bicubic | Autocontrast + 2x bicubic + UnsharpMask(2,150,2) |
|---|---:|---:|---:|---:|
| Gaussian blur radius 3 | 3/7 | 3/7 | 2/7 | 4/7 |
| Pixel remap int(100+0.22*x), blur 1.15 | 7/7 | 7/7 | 7/7 | 7/7 |
| 138×14 Lanczos downscale, 550×55 bicubic up, blur .9 | 7/7 | 7/7 | 7/7 | 7/7 |

84 native reads. Heavy blur original: name and amount empty; time 151632; reference FT123⁄4%4789. Combined method recovered name but amount remained blank, time remained 151632, reference FT1 23456789. Scale-only even lost account digits. Browser uses bounded cross-neighbor sharpening, not Pillow UnsharpMask, and has not been measured for accuracy. Treat as independent rescue only; no automatic promotion, no real customer image or ledger changes.
