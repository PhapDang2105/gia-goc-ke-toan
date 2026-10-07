# Phản biện nghiệp vụ — `gia-goc-demo.html`

> Góc nhìn: kế toán trưởng doanh nghiệp sản xuất (TT99/2025, TT133/2016, VAS 02). Ngày 2026-10-04.
> Cách làm: chép nguyên logic `valuate / compute / buildDocs / glBalances` sang Python, chạy 144 tổ hợp: 2 chế độ × 3 phương pháp × giờ máy 800/1000/1200 × dở dang 0/20 × có/không PN0015 × trạng thái khóa sổ (mới mở = bước 1–4 xong, chạy hết). Trạng thái "phiếu lùi ngày sau khi đã chạy hết" làm các bước 5–12 bị đánh dấu "cần chạy lại", nên số liệu trùng với trạng thái mới mở.
> Không sửa file HTML. Số dòng là dòng trong `gia-goc-demo.html`.

## 1. Kết quả tính lại

| Kiểm tra | Kết quả |
|---|---|
| Nợ = Có từng chứng từ (cả 144 tổ hợp) | ✓ Đạt |
| Sổ kho 152 và 155 = sổ cái | ✓ Đạt mọi tổ hợp, mọi trạng thái |
| Sổ cái 154 = dở dang cuối kỳ (DDCK) | ✓ sau khi chạy hết (5.909.091). **✗ Lúc mới mở theo TT99 (màn hình mặc định), sổ cái 154 = −133.985.656** (xem C1) |
| Z = DDĐK + C − DDCK | ✓ (BG-01: 5.000.000 + 60.000.000 + 18.000.000 + 12.000.000 − 5.909.091 = 89.090.909; z = 445.454,55) |
| Phân bổ SXC: Σ phân bổ + Σ vào 632 = 22.000.000 | ✓ Giờ máy 800: 2.000.000 vào 632, BG 12.000.000 / GG 8.000.000. Giờ máy 1000 và 1200: 0 vào 632, BG 13.200.000 / GG 8.800.000 (không vốn hóa vượt chi phí thực tế, đúng VAS 02) |
| Định khoản SXC dưới công suất | ✓ TT99: Nợ 632 / Có 627. TT133: Nợ 632 / Có 154 |
| Làm tròn ở cây truy xuất giá thành | ✗ Khi có PN0015, tổng các lá NVL của BG lệch **+1 đ** so với dòng tổng của nhánh (dòng 690–692) |
| Bình quân cuối kỳ: phần dư làm tròn | Phần dư dồn vào phiếu xuất cuối **kể cả khi tồn cuối > 0** (dòng 394–399), trái quy tắc G7 trong 06a |
| FIFO + PN0015 | Chỉ PX0011 đổi giá (−25.000 đ), nhưng thông báo vẫn ghi "Tính lại 2 phiếu xuất keo" (dòng 759) |
| Biên lãi gộp 01/2026 | **39,8–39,9%** (cả 3 phương pháp), trong khi biểu đồ tháng 08–12/2025 chỉ 24–26% (dòng 552) |

Số chính, kịch bản mặc định (TT99, bình quân cuối kỳ, giờ máy 800, dở dang 20, đã chạy hết): doanh thu 214.800.000; giá vốn sản phẩm bán ra 127.275.088 + 2.000.000 SXC dưới công suất; lãi gộp 85.524.912. Thuế GTGT đầu vào 8.270.000, đầu ra 21.480.000.

## 2. Bảng lỗi

| # | Mức | Dòng | Mô tả | Cách sửa |
|---|---|---|---|---|
| C1 | **Cao** | 207, 578–588, 511–512 | Màn hình mặc định (TT99, bước 1–4 đã xong): bảng "Đối chiếu kho với sổ cái" hiện **sổ cái 154 = −133.985.656**, lệch 139,9 triệu với dở dang. Lý do: NK0001/NK0002 (25/01) đã ghi Có 154 theo giá thành, còn 621/622/627 chưa kết chuyển sang 154 (KC0001 chỉ sinh ở bước 6). Ngay dưới bảng lại có câu "số dư … luôn bằng giá trị tồn". Kế toán trưởng nhìn thấy 154 âm là mất tin ngay. | Cách 1: phiếu nhập sản phẩm trước khi tính giá thành ghi **số lượng, giá trị 0** (hoặc trạng thái chờ giá, chưa sinh bút toán); sinh Nợ 155 / Có 154 ở bước 7. Cách 2: mở demo ở trạng thái đã chạy hết. Dòng 154 trong bảng đối chiếu ghi rõ "Chờ kết chuyển" và đưa câu ở dòng 207 xuống dưới điều kiện đó. |
| C2 | **Cao** | 373–374, 497–509, 708–711 | Bước 9 "Bù trừ thuế GTGT" và bước 10 "Kết chuyển 911" **không sinh bút toán nào**. Sau khi "khóa sổ", 5112 (−214,8 triệu), 632, 1331 và 33311 vẫn còn số dư, trái bất biến B1 (TK loại 5–9 phải dư 0). Bước 11 "Tổng Nợ = Tổng Có" vì vậy chỉ cộng các chứng từ đã có. | Sinh chứng từ **TH0001**: Nợ 33311 / Có 1331 8.270.000. Sinh chứng từ **KC0002**: Nợ 5112 / Có 911 214.800.000; Nợ 911 / Có 632 129.275.088; Nợ 911 / Có 4212 (lãi). Thêm 911, 4212 vào ACC_NAME. Theo TT133 dùng cùng số hiệu tài khoản. |
| C3 | **Cao** | 484, 495, 513 | Thuế GTGT áp **10% cho mọi thứ**. Kỳ 01/2026 đang có giảm thuế 2% theo NQ 204/2025/QH15 và NĐ 174/2025 (hiệu lực 01/07/2025–31/12/2026, *cần xác minh*). Bàn ghế gỗ, gỗ xẻ và tiền điện thuộc diện **8%**. Keo PVA và sơn PU là hóa chất bị loại trừ nên vẫn 10%. Kế toán trưởng thấy hóa đơn bán đồ gỗ 10% sẽ hỏi ngay. | Thuế suất lấy theo dòng hàng và ngày: bán BG/GG 8% (đầu ra 17.184.000), gỗ 8%, điện 8% (560.000), keo và sơn 10%. Hoặc dời kỳ demo sang năm 2027 nếu muốn giữ 10% (khi đó cần đổi toàn bộ ngày). |
| C4 | **Cao** | 752–757, 497 | Thêm phiếu lùi ngày sau khi đã chạy hết: các bước từ 5 trở đi bị đánh dấu "cần chạy lại", và **KC0001 đang "Đã ghi sổ" biến mất khỏi danh sách chứng từ**. Các phiếu xuất đã chốt giá chuyển lại thành "Giá tạm". Như vậy chứng từ đã ghi sổ bị xóa mà không để lại dấu vết, trái quy tắc I5 (không xóa vật lý, có nhật ký). | Giữ KC0001, gắn trạng thái "Cần tính lại" và hiện số cũ → số mới khi chạy lại bước. Phiếu xuất đã chốt giữ số cũ cho đến khi chạy lại bước 5. |
| T1 | TB | 547, 449 | KPI "Giá vốn hàng bán" luôn cộng 2.000.000 SXC dưới công suất, kể cả khi KC0001 chưa sinh. Lúc mới mở, KPI là 129.255.325 nhưng sổ cái 632 chỉ có 127.255.325. | Chỉ cộng khoản dưới công suất khi bước 6 đã xong, hoặc ghi chú "(tạm tính, chưa hạch toán)". |
| T2 | TB | 552, 548 | Biên lãi gộp tháng 01 là ≈ 40%, trong khi 5 tháng trước chỉ 24–26%. Ai xem demo cũng sẽ hỏi vì sao tháng này nhảy vọt. | Hạ giá bán (BG ≈ 590.000, GG ≈ 165.000) hoặc sửa số liệu lịch sử cho biên ~38–40%. |
| T3 | TB | 354, 357 | Theo TT99, 155 đã đổi tên thành "Sản phẩm", nhưng 5112 vẫn ghi "Doanh thu bán thành phẩm". Bước 8, kho "K2 · Kho thành phẩm" và loại "TP" cũng còn dùng chữ thành phẩm, nên các tên gọi không nhất quán. | Tên 5112 lấy theo chế độ: TT99 "Doanh thu bán sản phẩm" (*cần xác minh nguyên văn phụ lục TT99*), TT133 "Doanh thu bán thành phẩm". Nhãn "thành phẩm" trên giao diện lấy theo `accName('155')`. |
| T4 | TB | 367 | Bước 3 ghi "phân bổ chi phí trả trước". Theo TT99, TK 242 đã đổi tên thành "Chi phí chờ phân bổ". | Lấy tên theo chế độ: TT99 "chi phí chờ phân bổ (242)", TT133 "chi phí trả trước (242)". |
| T5 | TB | 492–493 | Bảng lương không có **các khoản trích theo lương** (BHXH, BHYT, BHTN, KPCĐ phần doanh nghiệp chịu ≈ 23,5%). Nhân công trực tiếp và SXC vì vậy thấp hơn thực tế khoảng 8 triệu. Kế toán trưởng sẽ hỏi "338 đâu?". | Thêm chứng từ **BL0002**: Nợ 622 (TT133: 154 khoản mục NC) 7.050.000; Nợ 627 940.000; Có 3383/3384/3386/3382. Đưa phần này vào giá thành. |
| T6 | TB | 500–502 | Theo TT99, KC0001 gộp 3 khoản mục vào **một dòng Nợ 154 cho mỗi sản phẩm**, nên sổ chi tiết 154 (S36) và thẻ giá thành không còn tách được NVL/NC/SXC. Các dòng Có 621/622 cũng không ghi đối tượng. | Tách ra 3 dòng cho mỗi sản phẩm: Nợ 154-BG (NVL) / Có 621-BG; Nợ 154-BG (NC) / Có 622-BG; Nợ 154-BG (SXC) / Có 627. Thêm thuộc tính "khoản mục" vào dòng hạch toán, như đã làm cho TT133. |
| T7 | TB | 665–672 | "Thẻ tính giá thành" chỉ có một cột số tiền. Mẫu quen thuộc (S37-DN; TT99 *cần xác minh số hiệu mẫu*) là **ma trận**: hàng gồm DDĐK, chi phí phát sinh, giá thành (Z), DDCK, giá thành đơn vị; cột gồm Tổng, NVLTT, NCTT, SXC. Thẻ cũng thiếu dòng "Các khoản giảm giá thành". | Dựng lại thẻ thành ma trận 4 cột × 5 hàng. DDĐK và DDCK chỉ có ở cột NVL (đánh giá dở dang theo NVL). |
| T8 | TB | 628–633 | Sổ chi tiết vật tư (S10-DN) thiếu các cột quen thuộc: **TK đối ứng** (621/154, 331), **đơn giá nhập**, chứng từ tách thành 2 cột "Số hiệu" và "Ngày tháng", cột ghi chú. Đầu sổ thiếu kho, TK, ĐVT. | Thêm cột "TK đối ứng" và gộp cột "Đơn giá" dùng chung cho nhập và xuất. Đầu sổ ghi: "Tài khoản 152 · Kho K1 · ĐVT kg". |
| T9 | TB | 606–617 | Bảng N-X-T (S11-DN) cộng chung NVL (152) với sản phẩm (155) thành một dòng "Cộng", trong khi ĐVT khác nhau. | Thêm dòng cộng riêng cho 152 và 155, sau đó mới đến tổng cộng. |
| T10 | TB | 394–399 | Bình quân cuối kỳ dồn phần dư làm tròn vào phiếu xuất cuối kể cả khi tồn cuối > 0. Tài liệu 06a G7 lại quy định phần dư nằm ở tồn. Demo và đặc tả không khớp nhau, và sẽ lệch 1 đ khi so với MISA. | Thống nhất một quy tắc (tương thích MISA) và ghi rõ trong phần giải thích ở dòng 647. |
| T11 | TB | 740–741, 536 | Đổi chế độ TT99↔TT133 và đổi phương pháp tính giá làm **ghi lại các chứng từ đã ghi sổ** ngay giữa kỳ. Chế độ kế toán và phương pháp tính giá phải áp dụng nhất quán trong năm (VAS 02, Luật Kế toán), nên kế toán trưởng sẽ phản đối. | Ghi nhãn "Xem thử (không ghi sổ)", hoặc giải thích rằng đây là chọn cấu hình đầu năm tài chính. |
| T12 | TB | 342–345, 494–496 | TT99/TT133 dùng 627 và 214 chưa chi tiết cấp 2. Kế toán trưởng quen hạch toán 6271 (lương quản đốc), 6272 (vật tư phụ), 6274 (khấu hao), 6277 (điện) và 2141. | Dùng tài khoản cấp 2. Riêng TT133 đi vào 154 kèm khoản mục SXC như hiện tại. |
| L1 | Thấp | 690–692 | Cây truy xuất làm tròn từng lá nên tổng các lá lệch 1 đ so với tổng nhánh NVL (BG, khi có PN0015). | Dồn phần dư vào lá cuối (hoặc lá có giá trị lớn nhất). |
| L2 | Thấp | 759 | Theo FIFO, PN0015 chỉ làm đổi PX0011, nhưng thông báo vẫn ghi "Tính lại 2 phiếu xuất keo". | Đếm đúng số phiếu đã đổi giá trị. |
| L3 | Thấp | 711 | Kết quả bước 11 là chuỗi văn bản cố định "kho khớp sổ cái 152, 155, 154", không thực sự kiểm tra. Bảng việc cần làm (dòng 567–568) cũng chỉ kiểm 152 và 155. | Gọi lại phép kiểm như ở dòng 578. Nếu lệch thì báo lỗi và không cho chạy bước 12 (khóa sổ). |
| L4 | Thấp | 724 | Câu "nhật ký sửa đổi theo TT 99/2025" vẫn hiện khi đang ở chế độ TT133. | Ghi "theo Luật Kế toán và chế độ kế toán đang áp dụng". |
| L5 | Thấp | 496 | PC0007 mua vật tư phụ 5.000.000 trả tiền mặt nhưng không có thuế GTGT. Kế toán trưởng sẽ hỏi chứng từ là hóa đơn gì; nếu có thuế GTGT thì từ 5 triệu trở lên không được trả tiền mặt (Luật GTGT 2024). | Đổi sang 4.500.000 kèm thuế 10%, hoặc ghi rõ "hóa đơn bán hàng hộ kinh doanh". |
| L6 | Thấp | 311–313, 322 | Đơn giá mẫu lệch giá thị trường: keo PVA 10.000–12.000 đ/kg (thực tế ~30.000–45.000), gỗ thông sấy 5 tr/m³ (thực tế ~7–9 tr). Ghế GG-02 không dùng keo. | Điều chỉnh giá và định mức để số liệu "trông thật". |
| L7 | Thấp | 271 vs 679 | Mã lô viết "NK-0001" ở nút bấm nhưng "NK0001" ở chỗ khác. Số chứng từ bán hàng "HD0012" không giống số hóa đơn điện tử (ký hiệu + số). | Dùng một định dạng thống nhất. Ghi số HĐ, ví dụ "1C26TGG · 0000012". |
| L8 | Thấp | 446, 662 | Công suất đo bằng giờ máy nhưng SXC lại phân bổ theo chi phí nhân công trực tiếp. Không sai, nhưng sẽ bị hỏi. | Thêm một dòng giải thích: công suất bình thường dùng để tách phần định phí; tiêu thức phân bổ là một lựa chọn riêng. |

## 3. Kết luận nhanh

- Phần lõi đúng: Nợ = Có, kho khớp 152/155, công thức Z, VAS 02 dưới công suất, cách TT133 ghi thẳng vào 154 và tên TK 155 theo TT99.
- Trước khi đưa khách xem, nên sửa trước C1–C4 vì kế toán trưởng sẽ thấy ngay: 154 âm ở màn hình đầu, khóa sổ mà 5112/632/thuế chưa kết chuyển, thuế suất 10% trong thời gian đang giảm thuế, và chứng từ đã ghi sổ biến mất khi tính lại.
- Sau đó sửa T5–T9: thêm các khoản trích theo lương, dựng thẻ giá thành dạng ma trận khoản mục, thêm các cột S10/S11 quen thuộc.
