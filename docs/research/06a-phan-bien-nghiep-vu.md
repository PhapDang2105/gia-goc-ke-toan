# 06a — Phản biện nghiệp vụ (góc nhìn kế toán trưởng DN sản xuất)

> Ngày: 2026-10-04 · Đối tượng rà soát: `research/01-nghiep-vu-ke-toan.md` (504 dòng), `KE-HOACH-DU-AN.md` v0.1, `research/04-phan-tich-misa.md` §6.
> Phương pháp: tính lại mọi ví dụ số bằng Python `decimal` (ROUND_HALF_UP, tiền làm tròn đồng); đối chiếu định khoản với TT200/TT99/TT133 và VAS 02.
> Mức độ: **Cao** = sai số/sai định khoản sẽ thành golden test sai hoặc chặn chạy song song MISA; **TB** = thiếu/không nhất quán, sửa trước khi thiết kế chi tiết; **Thấp** = diễn đạt, biên tập.

---

## 1. Kết quả tính lại ví dụ số

| Ví dụ (vị trí trong 01) | Kết quả trong 01 | Tính lại | Kết luận |
|---|---|---|---|
| BQ cuối kỳ §3.3 | ĐG 11.000; xuất 3.850.000; tồn 550.000 | như nhau | ✓ Đúng |
| BQ tức thời §3.4 — xuất 10/01 | 2.666.667; tồn 533.333 | 250 × 3.200.000/300 = 2.666.666,67 → 2.666.667; tồn 533.333 | ✓ |
| BQ tức thời §3.4 — ĐG sau nhập 20/01 | **11.555,56** | 1.733.333 / 150 = 11.555,5533… → 2 số lẻ = **11.555,55**; 4 số lẻ = 11.555,5533 | ✗ Sai làm tròn |
| BQ tức thời §3.4 — xuất 25/01 | **1.155.556** | 100 × 11.555,5533 = 1.155.555,33 → **1.155.555** (dù dùng ĐG 2 hay 4 số lẻ đều ra 1.155.555) | ✗ Sai 1 đồng |
| BQ tức thời §3.4/§3.7 — tổng xuất / tồn | **3.822.223 / 577.777** | **3.822.222 / 577.778** | ✗ Sai 1 đồng (lan sang bảng §3.7) |
| FIFO §3.5 | 2.650.000 + 1.150.000 = 3.800.000; tồn 600.000 | như nhau | ✓ |
| Đích danh §3.6 | 1.200.000 | như nhau | ✓ (nhưng không cho tổng kỳ — xem lỗi L13) |
| Điều chỉnh giảm giá nhập sau §3.8 | Có 152: 250.000; Có 632/154: 750.000 | 1.000.000 × 50/200 và × 150/200 | ✓ số học (nhưng sai về nguyên tắc với BQ — xem L7) |
| Phân bổ chi phí mua §3.8 | A 400.000, B 200.000 | 600.000 × 2,2/3,3 và × 1,1/3,3 | ✓ |
| **Phân bổ 627 theo NCTT §4.2** | ĐH1 **13.333.333**, ĐH2 **6.666.667** | Hệ số 20tr/30tr = 0,6667 → ĐH1 = 18tr × 2/3 = **12.000.000**; ĐH2 = 12tr × 2/3 = **8.000.000** | ✗ **Sai nghiêm trọng** |
| SXC dưới công suất §4.2 | 8.000.000 vào Z; 2.000.000 → 632 | như nhau | ✓ (thiếu trường hợp vượt công suất — L10) |
| DDCK theo NVLTT §4.3(a) | DDCK 10tr; Z 140tr; z 155.555,56 | (10+90)/1.000 × 100 = 10tr; Z = 10+140−10 = 140tr; z = 155.555,5556 | ✓ |
| DDCK theo SL tương đương §4.3(b) | DDCK 12.750.000; Z 139.500.000; z 155.000 | NVL 100.000/SP; NC 31,35tr/950 = 33.000; SXC 20,9tr/950 = 22.000 → DDCK 10tr+1,65tr+1,1tr; Z 90+29,7+19,8 | ✓ (kiểm tra 12,25+140−12,75 = 139,5 ✓) |
| DDCK theo định mức §4.3(c) | 12.000.000 | 9.500.000 + 2.500.000 | ✓ |
| Hệ số §4.4(2) | SL chuẩn 1.160; z chuẩn 100.000; Z 50/36/30tr | như nhau | ✓ |
| Tỷ lệ §4.4(3) | 105%; z_M 52.500; z_N 105.000 | như nhau | ✓ |
| Phân bước có BTP §4.4(5) | Z_BTP 68tr; Z_TP 90tr; NVL 50 / NC 22 / SXC 18 | như nhau | ✓ |
| Dự phòng §5.2 | NRV 450.000; DP 5tr; lập bổ sung 3tr | như nhau | ✓ |
| Bán hàng §5.3 | 825.000 / 750.000 / 75.000; giá vốn 550.000; trả lại 165.000 / 110.000 | như nhau | ✓ số học (sai TK — L9) |
| Xác định KQKD §5.4 | DT thuần 980; LNTT 140; thuế 28; LNST 112 (tr) | như nhau | ✓ |

**Số đúng cho §3.4 (thay thế bảng trong 01):**

| Ngày | SL tồn | GT tồn | ĐG (4 số lẻ) | GT xuất |
|---|---|---|---|---|
| 05/01 sau nhập | 300 | 3.200.000 | 10.666,6667 | |
| 10/01 xuất 250 | 50 | 533.333 | 10.666,6667 | 2.666.667 |
| 20/01 sau nhập | 150 | 1.733.333 | 11.555,5533 | |
| 25/01 xuất 100 | 50 | **577.778** | 11.555,5533 | **1.155.555** |

Tổng xuất **3.822.222**; kiểm tra 4.400.000 − 3.822.222 = 577.778 ✓. Bảng §3.7 sửa dòng BQ tức thời thành 3.822.222 / 577.778.

> Bài học cho golden test: phải ghi rõ trong YAML **ĐG lưu bao nhiêu số lẻ, GT xuất = round(SL × ĐG_lưu) hay round(SL × GT/SL chính xác)**, kiểu làm tròn (half-up vs banker's). Hai cách có thể lệch 1 đồng ở ví dụ khác — và MISA có tùy chọn số lẻ đơn giá riêng, nên tiêu chí "chênh lệch = 0 với MISA" bắt buộc khớp cấu hình làm tròn của MISA.

---

## 2. Bảng lỗi

| # | Mức | Vị trí | Mô tả | Đề xuất sửa |
|---|---|---|---|---|
| L1 | **Cao** | 01 §4.2 "Ví dụ phân bổ 627" | Sai số học: hệ số 0,6667 nhưng kết quả ĐH1 13.333.333 / ĐH2 6.666.667 (như chia 2/3–1/3 của 20tr). Đúng: **ĐH1 12.000.000; ĐH2 8.000.000**. Nếu đưa vào golden test sẽ khóa cứng thuật toán sai. | Sửa số; thêm 1 ví dụ có phần dư làm tròn thật (VD 627 = 10.000.000 chia 3 ĐH NCTT bằng nhau → 3.333.333/3.333.333/3.333.334) để test luật "dòng cuối nhận phần dư" — hoặc largest-remainder như kế hoạch Phase 0 (hai luật này **khác nhau**, phải chọn một, xem L16). |
| L2 | **Cao** | 01 §6 bước 8 "Kiểm kê, xử lý thừa thiếu" sau bước 4–7 | Sai thứ tự: phiếu xuất/nhập chênh lệch kiểm kê là chứng từ kho, làm thay đổi SL/GT dùng trong tính giá xuất (BQ cuối kỳ) và có thể là NVL thiếu trong định mức ở PX (ảnh hưởng 154). Đặt sau tính giá thành/giá xuất TP ⇒ phải chạy lại 4–7 hoặc sai giá. | Đưa "ghi nhận chênh lệch kiểm kê" lên **trước bước 3** (cùng nhóm chứng từ kỳ); giữ lập/hoàn nhập dự phòng 2294 sau bước 7 (cần giá gốc cuối kỳ). |
| L3 | **Cao** | KẾ HOẠCH §3 Phase 1 #9 ("tập hợp 621/622/627 … kết chuyển 154") vs 01 §2 & quyết định "TT133 song song" | TT133 **không có** 621/622/623/627; mọi chi phí ghi thẳng Nợ 154. Kế hoạch mô tả engine giá thành theo luồng TT99, không nhắc dimension khoản mục — nếu công ty dùng TT133 (rất có thể với SME) thì engine MVP không chạy được. | Ghi rõ trong kế hoạch: engine giá thành đọc **dimension "khoản mục CP" + đối tượng** trên dòng 154 (TT133) hoặc 621/622/627 (TT99); bước "kết chuyển → 154" chỉ sinh với TT99. Câu hỏi §5.1 (TT99 hay TT133) phải trả lời **trước** Phase 1. |
| L4 | **Cao** | KẾ HOẠCH Phase 1 vs Phase 2–3; 01 §6 bước 2 | Bước 2 khóa sổ cần **khấu hao (214), phân bổ 242, lương & trích theo lương (622/627)** trước giá thành, nhưng CCDC/TSCĐ/lương ở Phase 3. MVP không nói cách đưa chi phí này vào. Không có 622 & 6274 thì giá thành giản đơn và chạy song song MISA vô nghĩa. | MVP bổ sung tường minh: "Chứng từ nghiệp vụ khác" cho phép hạch toán 622/627/154 **bắt buộc đối tượng tập hợp CP + khoản mục** (nhập từ bảng lương, bảng khấu hao MISA/Excel), và nhập Excel bảng phân bổ. Đánh dấu bước 2 của orchestrator là "nhập ngoài" trong MVP. |
| L5 | **Cao** | KẾ HOẠCH Phase 2 "đơn mua/bán, trả lại hàng"; 04 §6 P2 #6 "hàng mua đi đường; trả lại hàng" | Hàng bán trả lại, trả lại hàng mua, giảm giá/CKTM, hàng mua đi đường (151), gửi bán (157) là nghiệp vụ **hằng tháng** của DN SX-TM. Đẩy sang Phase 2 mà tiêu chí MVP là "chạy song song MISA 2–3 tháng, chênh lệch = 0" ⇒ không đạt được. 01 lại đã đặc tả chúng như phần của engine giá (§3.3, §3.8). | Đưa vào MVP tối thiểu: trả lại hàng mua, hàng bán trả lại, giảm giá/CKTM mua & bán (chứng từ điều chỉnh SL=0), hàng mua đi đường cuối kỳ (151), xuất gửi bán (157). Đơn mua/bán, báo giá vẫn ở P2. |
| L6 | **TB** | 01 §3.4 bảng & §3.7 | Sai làm tròn: ĐG 11.555,56 (đúng 11.555,55/11.555,5533), GT xuất 1.155.556 (đúng 1.155.555), tổng 3.822.223 (đúng 3.822.222), tồn 577.777 (đúng 577.778). Mâu thuẫn chính quy tắc "ĐG decimal 4 số lẻ" của 01. | Thay bảng như mục 1. Ghi luật làm tròn vào golden test. |
| L7 | **TB** | 01 §3.8 "Điều chỉnh giá nhập sau" + §5.1 "Chiết khấu TM / giảm giá hàng mua" | (a) Phân bổ "còn tồn / đã bán / đã SX" theo **lô nhập** chỉ đúng với FIFO/đích danh; với BQ, lô đã trộn vào bình quân — phần "còn tồn" phải tính theo **tỷ lệ tồn của mặt hàng** (SL tồn cuối / SL có trong kỳ), không theo lô 200 kg. (b) "Có 154/621": nếu kỳ chưa tính giá thành thì phải điều chỉnh 621 (TT99)/154 khoản mục NVL (TT133) và tính lại; nếu SP đã hoàn thành & bán thì phần tương ứng vào 632. (c) Nếu điều chỉnh rơi vào kỳ đã khóa, 01 cho "phân bổ thủ công" — cần quy tắc mặc định (MISA: ghi vào kỳ hiện tại theo tỷ lệ tồn hiện tại). | Tách quy tắc theo phương pháp giá; nêu rõ phân tầng 152 → 154 → 155 → 632 và cách xử lý khi tồn = 0 (toàn bộ vào 632/154). |
| L8 | **TB** | 01 §3.8 "Hàng mua trả lại người bán" | Với BQ cuối kỳ, trả lại hàng mua theo giá nhập gốc nên được xử lý như **nhập âm** (giảm cả Q và V trong công thức BQ), không phải dòng xuất mang giá riêng; nếu là dòng xuất thì tồn sau trả có ĐG méo. 01 không nói rõ mô hình. Cũng thiếu: trả lại khi hàng đã xuất một phần, trả lại khác kỳ. | Định nghĩa: "trả lại hàng mua" = điều chỉnh giảm nhập (SL<0, GT<0) gắn phiếu nhập gốc; với BQ tức thời/FIFO: giảm lô gốc, nếu lô đã tiêu hết → lấy giá gốc, chênh lệch với ĐG hiện tại vào 632 (hoặc tính lại). |
| L9 | **TB** | 01 §5.3 ví dụ bán hàng | Vật tư A là **NVL kho K1 (152)** ở §3.2 nhưng ví dụ bán ghi Có 156 / Có 5111 / Nợ 156 khi trả lại. Bán NVL: Có 152, doanh thu 5118 (TT200/TT99) hoặc 5111 tùy chính sách; nhập lại Nợ 152. Ngoài ra ví dụ bán 50 kg (đúng toàn bộ tồn cuối) → sau trả lại 10 kg thì tồn 10 kg giá 110.000 — phải chỉ rõ hàng trả lại vào **kỳ sau** hay cùng kỳ (BQ cuối kỳ: nếu cùng kỳ thì ảnh hưởng ĐG?). | Đổi ví dụ sang hàng hóa B (156) hoặc sửa TK; ghi rõ ngày trả lại và cách tính giá theo §3.3. |
| L10 | **TB** | 01 §4.2 "SXC cố định dưới công suất" | Thiếu nửa còn lại của VAS 02 đoạn 08: khi SX **vượt** công suất bình thường, SXC cố định phân bổ theo thực tế (không vốn hóa quá chi phí thực tế). Thiếu: công suất bình thường xác định theo đối tượng & kỳ (tháng vs năm — SX thời vụ bị "dưới công suất" giả tạo nếu đo theo tháng). TT133: bút toán là **Nợ 632 / Có 154** (không có 627). G1 viết "số dư 627 = 0 (trừ phần dưới công suất đã chuyển 632)" — câu vô nghĩa vì đã chuyển thì dư vẫn 0. | Công thức: tỷ lệ phân bổ = min(1, SL thực tế / SL công suất bình thường); cấu hình kỳ đo công suất; sửa G1 thành "627 dư = 0; Σ phân bổ 154 + Σ chuyển 632 = PS 627". |
| L11 | **TB** | 01 §5.4 & §6 bước 9–10 | Bảng kết chuyển chỉ theo TT200/TT99: TT133 không có 521 (bước 1 bỏ), không có 641 (dùng 6421/6422), 821 không có cấp 2 (không có 8211/8212). Đầu năm "kết chuyển 4212 → 4211" chỉ đúng nếu không có TK cấp 2 khác; TT133 vẫn có 4211/4212 ✓. | Bảng kết chuyển phải là cấu hình theo chế độ; thêm cột TT133. |
| L12 | **TB** | 01 §5.2 (CCDC 242, NVL thừa trả lại Nợ 152/Có 621, xuất dùng chung) | Ghi chú TT133 thiếu ở nhiều dòng: phân bổ 242 → **154/6421/6422** (không 627/641/642); NVL thừa nhập lại → **Có 154**; xuất CCDC dùng chung PX → 154 (khoản mục SXC). | Bổ sung cột "TT133" cho mọi dòng §4.2, §5.2. |
| L13 | **TB** | 01 §3.8 "Hàng bán trả lại" vs §3.3 quy tắc cài đặt | §3.3 nói MISA mặc định gán ĐG_bq (loại khỏi mẫu số); §3.8 nói mặc định = giá vốn dòng bán gốc. Hai "mặc định" khác nhau. Với BQ cuối kỳ cùng kỳ: giá vốn dòng bán gốc **chính là** ĐG_bq kỳ (chưa biết khi lập phiếu) ⇒ phải là phụ thuộc vòng; nếu khác kỳ: giá vốn dòng gốc ≠ ĐG_bq kỳ hiện tại và phải là "nhập có giá" tham gia bình quân. | Chốt 1 quy tắc: cùng kỳ → nhập theo ĐG_bq kỳ (loại khỏi mẫu số); khác kỳ → nhập theo giá vốn gốc, **tham gia** bình quân. Đây cũng là câu hỏi §5.3 của kế hoạch. |
| L14 | **TB** | 01 §8.2 K1 + §2 | K1 đòi Σ tồn chi tiết kho = số dư 151, 157 — nhưng không có mô hình "kho" cho 151 (hàng chưa về) và 157 (hàng ở đại lý/khách). Không có đặc tả giá xuất từ 157 (BQ của kho gửi bán? giữ giá lúc gửi?). | Định nghĩa kho ảo loại "đi đường" và "gửi bán" theo đối tượng; quy tắc: hàng ở 157 giữ nguyên giá vốn lúc xuất gửi (đích danh theo phiếu gửi), không tham gia bình quân lại. |
| L15 | **TB** | 01 §1.1 & KẾ HOẠCH §2 "Chỉ KKTX (TT99 bỏ TK 611/631)" | Lý do pháp lý không chính xác: bỏ 611/631 không đồng nghĩa TT99 cấm KKĐK (01 tự ghi [CXM]). TT133 vẫn có 611. Chọn chỉ KKTX là quyết định **phạm vi sản phẩm**, không phải do luật. | Sửa lý do; ghi rõ khách hàng dùng KKĐK (TT133) không được hỗ trợ ở MVP. |
| L16 | **TB** | 01 §8.5 "dòng cuối nhận phần dư" vs KẾ HOẠCH Phase 0 "phân bổ largest-remainder" | Hai thuật toán làm tròn khác nhau → kết quả lệch 1–n đồng giữa các dòng; "dòng cuối" phụ thuộc thứ tự dòng (không ổn định nếu sắp xếp đổi). MISA dùng dồn dòng cuối. | Chọn một (đề xuất: largest-remainder, tie-break theo khóa ổn định), hoặc cấu hình "tương thích MISA" cho giai đoạn chạy song song. |
| L17 | **TB** | 01 §6 bước 5 | Không có bước "trừ phế liệu thu hồi / SP hỏng / NVL vượt định mức" trước tính Z, dù công thức §4.1 có "khoản giảm giá thành". Không có bước tách phần SXC dưới công suất ra 632 (chỉ nêu ở §4.2). | Bước 5 tách: 5a kết chuyển (TT99) → 5b tách phần ngoài định mức/dưới công suất → 632 → 5c phân bổ SXC → 5d phế liệu/SP hỏng → 5e dở dang. |
| L18 | **TB** | KẾ HOẠCH #12 "B01/B02 (TT99)" | Thiếu bộ báo cáo TT133 (B01a/b-DNN, B02-DNN, **F01-DNN** Bảng cân đối TK nộp kèm BCTC) trong khi hỗ trợ TT133 "song song". | Thêm vào MVP nếu §5.1 trả lời TT133. |
| L19 | **TB** | KẾ HOẠCH §2 "bút toán 15x/154/632 sinh từ value_change của sổ kho" | Với TT99, xuất NVL cho SX là **Nợ 621** (không phải 154); xuất dùng chung → 627/641/642; xuất CCDC → 242. TK đối ứng phải lấy theo **lý do xuất** + chế độ, không mặc định 154/632. Chứng từ SL=0 (điều chỉnh giá) cũng phải đi qua sổ kho để giữ K1. | Ghi rõ: value_change sinh vế TK kho; vế đối ứng theo account role của lý do xuất × chế độ. |
| L20 | **TB** | KẾ HOẠCH #7 "FIFO cuối P1 nếu kịp" vs Phase 2 "FIFO + đích danh" vs 04 §6 MVP #7 (FIFO P0) | Ba chỗ nói ba ý. | Thống nhất; nếu công ty dùng BQ thì đưa FIFO hẳn về P2. |
| L21 | **TB** | KẾ HOẠCH #10 "close orchestrator 13 bước" vs phạm vi | Bước 1 (đánh giá tỷ giá) cần đa tiền tệ (Phase 3); bước 8 dự phòng; bước 9 thuế TNDN — chưa có chức năng tương ứng. 04 §6 #11 "khóa sổ theo **ngày**" vs 01 khóa theo **kỳ**. | Orchestrator cho phép bước "không áp dụng/ngoài hệ thống"; chốt khóa theo ngày (như MISA) hay theo kỳ — giá thành BQ cuối kỳ đòi khóa theo kỳ. |
| L22 | **Thấp** | 01 §4.3 (a) và (b) | Hai ví dụ dùng DDĐK khác nhau (10tr vs 12,25tr) cùng "phân xưởng X" ⇒ người đọc nhầm khi so sánh phương pháp. (c) không tính Z. | Ghi "giả định riêng"; bổ sung Z cho (c): Z = DDĐK + 140tr − 12tr. |
| L23 | **Thấp** | 01 §5.1 "Chi phí mua … TT200 có thể dùng 1562" và §2 bảng 156 | TT133 TK 156 không có cấp 2 (theo hiểu biết [CXM]); 1562 chỉ TT200. | Thêm cột TT133. |
| L24 | **Thấp** | 01 §5.4 bước 6 "Tính thuế TNDN tạm tính" | Từ 2021 DN không phải nộp tờ khai tạm tính quý nhưng vẫn tạm nộp; hạch toán 8211 hằng quý là tùy chọn. Không chặn khóa sổ tháng. | Đánh dấu tùy chọn. |
| L25 | **Thấp** | 01 §1 dòng thuế GTGT 8% | Mức giảm 2% hiện hành theo NQ 204/2025/QH15 (theo hiểu biết: 01/07/2025–31/12/2026) [CXM]. Không áp dụng cho một số nhóm hàng (VD kim loại, hóa chất, hàng chịu TTĐB…). | Bảng thuế suất theo ngày + danh mục loại trừ theo mã ngành/VTHH. |

---

## 3. Định khoản — kiểm tra từng nghiệp vụ

Đã kiểm tra mọi dòng §4.2, §5.1–5.4: **đúng về nguyên tắc** với TT200/TT99, trừ các điểm đã nêu (L7, L8, L9, L11, L12). Ghi chú thêm:

| Nghiệp vụ (01) | Nhận xét |
|---|---|
| §5.1 Hàng về chưa có HĐ — Nợ 152/156 / Có 331 giá tạm | Đúng. Cần quy tắc: khi HĐ về khác giá tạm và hàng đã xuất ⇒ xử lý như "điều chỉnh giá nhập sau" (L7). |
| §5.1 Chiết khấu thanh toán được hưởng — Nợ 331 / Có 515 | Đúng. |
| §5.1 Thuế TTĐB hàng NK — 1383 (TT99) | Đúng hướng; TT200/TT133: phần được khấu trừ ghi Nợ 3332 (không phải 1331). Cần ghi rõ để mapping TT133. |
| §5.1 GTGT hàng NK không được khấu trừ — Nợ 152/156 | Đúng. |
| §5.2 Chuyển chi nhánh phụ thuộc — Nợ 1368 / Có 156 | Chấp nhận [KT]; ngoài MVP. |
| §5.2 Kiểm kê thiếu/thừa, dự phòng | Đúng. Thiếu ngoài định mức do lỗi cá nhân → Nợ 1388/334; không xác định → 632 (TT200/TT99) hay 811 theo quyết định — cần cấu hình. |
| §5.3 CKTM sau HĐ — Nợ 5211, 33311 / Có 131 | Đúng (TT133: Nợ 511). |
| §5.3 Giá vốn hàng trả lại — Nợ 155/156 / Có 632 | Đúng; nếu trả lại hàng của kỳ đã khóa thì vẫn ghi kỳ hiện tại. |
| §4.4 Nhập TP Nợ 155 / Có 154; bán thẳng Nợ 632 / Có 154; gửi bán Nợ 157 / Có 154 | Đúng. |
| §4.2 Phế liệu thu hồi — Nợ 152 / Có 154 | Đúng nhưng thiếu: giá trị phế liệu (NRV ước tính), giảm khoản mục nào (thường NVLTT), phế liệu bán ngay không nhập kho (Nợ 111/131 / Có 154 hoặc 711 tùy chính sách), xem mục 4. |

**Khác biệt TT133 vs TT99 cần cài đặt (tổng hợp):**

| Điểm | TT99 | TT133 |
|---|---|---|
| Xuất NVL SX | Nợ 621 | Nợ 154 (khoản mục NVLTT) |
| Lương CN SX | Nợ 622 | Nợ 154 (NCTT) |
| SXC (lương QLPX, KH, điện…) | Nợ 627x | Nợ 154 (SXC) — cần dimension để phân bổ |
| Kết chuyển cuối kỳ | 621/622/623/627 → 154 | Không có; chỉ phân bổ nội bộ 154 giữa đối tượng |
| SXC dưới công suất | Nợ 632 / Có 627 | Nợ 632 / Có 154 |
| NVL thừa trả kho | Nợ 152 / Có 621 | Nợ 152 / Có 154 |
| NVL/NC vượt định mức (VAS 02) | Nợ 632 / Có 621, 622 | Nợ 632 / Có 154 |
| Phân bổ 242 cho SX | Nợ 627 | Nợ 154 |
| CP bán hàng / QLDN | 641 / 642 | 6421 / 6422 |
| Giảm trừ DT | 5211/5212/5213 → kết chuyển 511 | Nợ 511 trực tiếp (không 521) |
| CP thuế TNDN | 8211/8212 | 821 |
| Kho bảo thuế | 158 | không có |
| BCTC | B01-DN (BC tình hình TC), B02, B03, B09 | B01a/b-DNN, B02-DNN, B09-DNN, F01-DNN |
| Hệ quả cho engine | Đọc TK | Bắt buộc dimension khoản mục + đối tượng trên **mọi** dòng 154 (bất biến I6 phải mạnh hơn: 154 TT133 thiếu khoản mục ⇒ chặn ghi sổ) |

---

## 4. Lỗ hổng nghiệp vụ cần có trong MVP (01 và kế hoạch chưa nói hoặc nói thiếu)

| # | Nghiệp vụ | Hiện trạng trong 01 / kế hoạch | Cần đặc tả |
|---|---|---|---|
| G1 | **Chi phí mua hàng về sau** (HĐ vận chuyển đến sau phiếu nhập, có thể khác kỳ) | 01 §3.8 chỉ 1 dòng "coi là điều chỉnh giá nhập sau"; kế hoạch chỉ "chi phí mua phân bổ vào giá nhập" | Chứng từ chi phí mua tham chiếu **nhiều phiếu nhập** (kể cả kỳ trước); phân bổ theo tiêu thức; tách phần còn tồn / đã xuất SX / đã bán (L7); VAT đầu vào 1331 của HĐ chi phí; nếu chi phí nhỏ cho phép chọn ghi 632/641. |
| G2 | **Hàng mua đi đường (151)** | Chỉ có định khoản; kế hoạch đẩy P2 | Cuối kỳ: HĐ đã về, hàng chưa về → Nợ 151; kỳ sau nhập kho Nợ 152 / Có 151 (không ghi lại 1331, không tính lại giá); có kho ảo để thỏa K1; báo cáo hàng đi đường. |
| G3 | **Hàng gửi bán / đại lý (157)** | Định khoản có; không có mô hình kho, giá, hoa hồng | Kho ảo theo đại lý; giá xuất từ kho gốc theo PP chọn; khi đại lý báo bán: DT + Nợ 632 / Có 157 (giá đích danh theo phiếu gửi); hoa hồng đại lý Nợ 641/6421, 1331 / Có 131; thời điểm lập HĐ theo NĐ70. |
| G4 | **Chiết khấu thương mại / thanh toán** (mua & bán) | Có định khoản; thiếu CKTM theo **doanh số lũy kế** (ghi trên HĐ cuối hoặc HĐ điều chỉnh), CKTM bằng hàng, phân bổ CKTM cho nhiều mặt hàng; CKTT không phải chứng từ kho | Chứng từ "giảm trừ mua/bán" SL=0 tham chiếu nhiều HĐ; với mua: phân bổ về giá nhập (theo L7); với bán: không ảnh hưởng giá vốn; CKTT chỉ qua công nợ (515/635). |
| G5 | **Thuế GTGT không được khấu trừ** | 01 §3.1 chỉ nhắc "GTGT nếu không được khấu trừ" vào giá gốc | Các trường hợp: (a) hàng dùng cho hoạt động không chịu thuế → cộng giá gốc; (b) **thanh toán ≥ 5 triệu không qua ngân hàng** (Luật GTGT 48/2024) → ghi nhận lúc mua thì khấu trừ, khi quá hạn thanh toán/thanh toán tiền mặt phải điều chỉnh giảm 1331 (Nợ 152/156 nếu còn tồn, 632/642 nếu đã dùng hoặc 811); (c) DN có cả hoạt động chịu/không chịu thuế → **phân bổ 1331 theo tỷ lệ doanh thu** cuối kỳ; (d) HĐ không hợp lệ. Cờ "khấu trừ / không khấu trừ / phân bổ" trên dòng thuế. |
| G6 | **Làm tròn đơn giá vs thành tiền** | 01 §8.5 nêu lưu trữ; không nêu thứ tự ưu tiên | Quy tắc: **thành tiền trên HĐ là gốc** (không tính lại SL × ĐG); ĐG hiển thị = thành tiền / SL; VAT tính theo tổng từng thuế suất của HĐ (theo HĐĐT) — chênh lệch so với tổng VAT từng dòng phải cho nhập tay; quy đổi ĐVT: GT giữ nguyên, ĐG theo ĐVT chính = GT / SL quy đổi. Ví dụ: 3 kg × 33.333,33 = 99.999,99 vs HĐ 100.000 → lấy 100.000. |
| G7 | **Chênh lệch làm tròn khi xuất hết tồn** | K4 có nguyên tắc; thiếu cách làm | (a) BQ tức thời: dòng xuất làm SL = 0 nhận toàn bộ GT tồn (đã có); (b) BQ cuối kỳ: dòng xuất cuối kỳ nhận phần dư **chỉ khi SL tồn cuối = 0**, ngược lại phần dư nằm ở tồn; (c) SL = 0 nhưng GT ≠ 0 do điều chỉnh giá đến sau (chứng từ SL=0) → tự sinh bút toán xả vào 632 (hàng thương mại) / 154 hoặc 632 (NVL); (d) SL rất nhỏ nhưng GT lớn (ĐG bất thường) → cảnh báo K5. |
| G8 | **Nhập lại hàng bán bị trả lại** | §3.8 & §5.3 có nhưng mâu thuẫn (L13); kế hoạch đẩy P2 | Tham chiếu chứng từ bán; trả lại khác kỳ; trả lại hàng đã bán từ 157; trả lại TP sản xuất (giá thành kỳ gốc); hàng trả lại kém phẩm chất nhập kho riêng/ghi giảm giá trị; HĐ điều chỉnh theo NĐ70. |
| G9 | **Phế liệu thu hồi** | Chỉ 1 dòng Nợ 152 / Có 154 | Giá nhập phế liệu = giá ước tính bán (NRV) do người dùng nhập; giảm Z theo khoản mục NVLTT (cấu hình); phế liệu bán ngay; vị trí trong close (trước tính Z); phế liệu không tham gia bình quân với NVL cùng mã (mã VTHH riêng). |
| G10 | **Sản phẩm hỏng** | Không có | Hỏng **trong định mức** → tính vào Z của SP đạt (không cần bút toán riêng, chỉ SL hoàn thành giảm); **ngoài định mức** sửa được → chi phí sửa tập hợp riêng rồi Nợ 1388/334/632 (hoặc 811) / Có 154; không sửa được → giá trị SP hỏng Nợ 1388/632/811, phế liệu thu hồi Nợ 152 / Có 154. Dữ liệu: SL hỏng trong/ngoài định mức theo đối tượng & kỳ, định mức hỏng (%). |
| G11 | NVL / NC / SXC **vượt mức bình thường** (VAS 02) | §3.1 nêu nguyên tắc, không có cơ chế | Cần định mức theo BOM + cờ cho phép tách phần vượt sang 632; tối thiểu cho nhập tay "chi phí không tính vào giá thành". |
| G12 | NVL xuất dùng chưa hết để lại PX cuối kỳ | Không có | Phiếu "xuất âm"/ghi đỏ Nợ 621 âm (TT99) để đầu kỳ sau ghi lại; hoặc coi là DD. Rất phổ biến ở MISA (lập phiếu xuất ghi âm). |
| G13 | Xuất hàng khuyến mại, biếu tặng, tiêu dùng nội bộ, hàng mẫu | Không có | Lý do xuất riêng; đối ứng 641/6421/642/811; xác định có phải xuất HĐ / tính VAT đầu ra (giá trị tính thuế = 0 với KM đăng ký đúng thủ tục). |
| G14 | Mua bán giao tay ba (không qua kho) | Không có | Nợ 632 / Có 331 (không qua sổ kho) hoặc qua kho ảo; ảnh hưởng K2. |
| G15 | Chuyển đổi chế độ & số dư đầu kỳ khi go-live giữa năm | 01 §1 Hệ quả 1 có mapping TK; kế hoạch #2 có số dư đầu kỳ | Cần số dư **154 theo đối tượng & khoản mục**, tồn kho theo lô (FIFO), hàng gửi bán theo đại lý, DP 2294 theo mặt hàng — nếu không có, kỳ đầu giá thành/giá vốn sai, không thể "chênh lệch = 0" với MISA. |

---

## 5. Mâu thuẫn giữa 01 và kế hoạch (tóm tắt)

1. **TT133 vs engine 621/622/627** (L3) — kế hoạch mô tả giá thành theo TK TT99.
2. **Phạm vi trả lại hàng / 151 / 157 / CKTM** (L5) — 01 coi là phần của engine giá, kế hoạch & 04 đẩy P2.
3. **Lương, khấu hao, phân bổ 242** (L4) — 01 bắt buộc ở bước 2 khóa sổ, kế hoạch để Phase 3, không có cách nhập thay thế.
4. **Luật làm tròn**: 01 "dòng cuối nhận phần dư" vs kế hoạch "largest-remainder" (L16).
5. **FIFO**: P0 (04) / "cuối P1 nếu kịp" / P2 (kế hoạch) (L20).
6. **Khóa sổ** theo kỳ (01) vs theo ngày (04 §6 #11); orchestrator 13 bước có bước ngoài phạm vi (L21).
7. **Kiểm kê**: kế hoạch P1 (sau P0) nhưng 01 đặt trong chuỗi khóa sổ bắt buộc; và đặt sai thứ tự (L2).
8. **BCTC**: kế hoạch chỉ B01/B02 TT99 trong khi cam kết TT133 song song (L18).
9. **Sổ kho sinh bút toán "15x/154/632"** — không khớp định khoản TT99 (621/627/641/642/242) ở 01 §5.2 (L19).
10. **Lý do chỉ KKTX** (L15) — kế hoạch dẫn lý do pháp lý chưa chính xác.
11. **Tiêu chí "chênh lệch = 0 với MISA"** — không khả thi nếu không khớp cấu hình làm tròn đơn giá/thành tiền và luật phân bổ phần dư của MISA (mục 1, L16) và nếu thiếu các nghiệp vụ ở mục 4.

## 6. Việc nên làm ngay (trước khi viết golden test từ 01 §3.2)
1. Sửa L1, L6 trong 01; thêm ví dụ có phần dư làm tròn thật.
2. Trả lời câu hỏi kế hoạch §5.1 (TT99/TT133) — quyết định cấu trúc engine giá thành.
3. Đưa G1, G2, G4, G5(b,c), G6, G7, G8, G9, G10 (tối thiểu dạng nhập tay) và L4 vào phạm vi MVP.
4. Viết lại §6 khóa sổ theo L2, L17.
