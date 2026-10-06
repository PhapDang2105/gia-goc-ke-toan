# 04 — Phân tích MISA SME / MISA AMIS Kế toán và đối thủ

> Ngày nghiên cứu: 2026-10-04. Nguồn chính: trang hướng dẫn công khai helpsme.misa.vn (bản SME 2026, một số trang bản 2022/2023 khi bản 2026 chưa có trang tương ứng), helpact.misa.vn (AMIS Kế toán), trang giá chính thức của MISA, và trang của FAST, Bravo, Viindoo, KiotViet, Sapo, Base.
> Quy ước: chỉ ghi điều xác minh được qua nguồn dẫn. Mục nào nguồn mâu thuẫn hoặc chưa xác minh được thì ghi rõ **[chưa xác minh]** / **[mâu thuẫn nguồn]**.
> Lưu ý pháp lý: Thông tư 99/2025/TT-BTC thay thế TT200/2014 từ 01/01/2026 ([thuvienphapluat](https://thuvienphapluat.vn/phap-luat/ho-tro-phap-luat/toan-van-thong-tu-992025ttbtc-che-do-ke-toan-doanh-nghiep-thay-the-thong-tu-200-tu-01012026-ra-sao-239165.html)). MISA SME 2026 có mục "Cập nhật dữ liệu kế toán theo TT99/2025" ([helpsme 2026](https://helpsme.misa.vn/2026/)). Các tài khoản 152/154/155/156/621/622/627/632 dưới đây lấy theo tài liệu MISA (đa số viết cho TT200/TT133) — cần đối chiếu lại danh mục TK theo TT99 ở tài liệu nghiên cứu pháp lý riêng.

---

## 0. Tổng quan sản phẩm

| Sản phẩm | Nền tảng | Ghi chú | Nguồn |
|---|---|---|---|
| MISA SME 2026 (SME.NET) | Desktop/offline (cài trên máy, có app mobile cho người dùng) | "18 phân hệ", đáp ứng TT99 và TT133 | [sme.misa.vn](https://sme.misa.vn/), [helpsme 2026](https://helpsme.misa.vn/2026/) |
| MISA AMIS Kế toán | Cloud | 5 gói; quảng cáo trợ lý AI "AVA Kế toán", đồng bộ hóa đơn đầu vào từ cơ quan thuế, kết nối ngân hàng, 200+ báo cáo, app mobile bán hàng, luồng phê duyệt | [amis.misa.vn/amis-ke-toan](https://amis.misa.vn/amis-ke-toan/), [helpact](https://helpact.misa.vn/kb/dong-bo-hoa-don-dau-vao-tu-co-quan-thue/) |

Tài liệu hướng dẫn SME 2026 tổ chức theo: Bắt đầu sử dụng → Hướng dẫn nghiệp vụ (Quỹ, Ngân hàng, Mua hàng, Bán hàng, Hóa đơn điện tử, Kho, CCDC, TSCĐ, Nghiệp vụ khác) → Hướng dẫn theo lĩnh vực (dược, thiết bị văn phòng, ô tô, VLXD, logistics…) → FAQ → Kiểm tra đối chiếu báo cáo → Hệ thống/Tiện ích ([helpsme 2026](https://helpsme.misa.vn/2026/)).

---

## 1. Danh sách phân hệ và chức năng chính

Theo trang báo giá SME 2026, các phân hệ được bán theo gói ([sme.misa.vn/bao-gia](https://sme.misa.vn/bao-gia)):

| Phân hệ | Chức năng / chứng từ chính (đã xác minh) | Gói SME 2026 |
|---|---|---|
| **Quỹ, Thủ quỹ** | Phiếu thu, phiếu chi; tỷ giá xuất quỹ (bình quân cuối kỳ / bình quân tức thời) ([helpsme](https://helpsme.misa.vn/2026/kb/danhgialai_taikhoanngoaite/)) | Standard |
| **Ngân hàng** | Thu/chi/chuyển tiền qua NH; kết nối ngân hàng điện tử (chuyển tiền, duyệt lệnh, tra số dư, tra lịch sử giao dịch); **đối chiếu ngân hàng online** — lấy sổ phụ, lập nhanh chứng từ thu/chi từ giao dịch. Ngân hàng hỗ trợ: MSB, VPBank, BIDV, VietinBank, Nam A Bank, Vietcombank, HDBank, MB, OCB, Techcombank ([kết nối NHĐT](https://helpsme.misa.vn/2022/kb/ket_noi_voi_ngan_hang_dien_tu/), [đối chiếu online](https://helpsme.misa.vn/2022/kb/doi_chieu_ngan_hang_online/), [lệnh chuyển tiền](https://helpsme.misa.vn/2023/kb/quan_ly_lenh_chuyen_tien/)) | Standard |
| **Mua hàng** | Đơn mua hàng; mua hàng trong nước nhập kho; mua hàng nhập khẩu; mua hàng nhiều hóa đơn; phân bổ chi phí mua hàng (vận chuyển, bốc xếp) vào giá nhập; lập nhanh chứng từ mua ([mua trong nước](https://helpsme.misa.vn/2026/kb/muahang_trongnuoc_venhapkho/), [nhập khẩu](https://helpsme.misa.vn/2023/kb/muahang_nhapkhau_nhapkho/), [nhiều HĐ](https://helpsme.misa.vn/2026/kb/lap_chung_tu_mua_hang_nhieu_hoa_don/), [theo đơn mua](https://helpsme.misa.vn/2023/kb/muahang_theodonhang/)) | Standard |
| **Bán hàng** | Chứng từ bán hàng (ghi nhận doanh thu), sau đó phiếu xuất kho bán hàng chọn từ chứng từ bán; hàng bán trả lại ([xuất kho bán hàng](https://helpsme.misa.vn/2026/kb/xuat_kho_ban_hang/)) | Standard |
| **Quản lý hóa đơn / Hóa đơn điện tử** | Phân hệ HĐĐT riêng trong SME 2026; AMIS đồng bộ HĐ đầu vào từ cổng tra cứu của Tổng cục Thuế bằng tài khoản meInvoice, kiểm tra hợp lệ, cảnh báo NCC rủi ro, lập chứng từ mua hàng loạt từ HĐĐT ([helpsme 2026](https://helpsme.misa.vn/2026/), [helpact đồng bộ HĐ](https://helpact.misa.vn/kb/dong-bo-hoa-don-dau-vao-tu-co-quan-thue/), [lập CT từ HĐĐT](https://helpact.misa.vn/kb/lap_chung_tu_tu_hoa_don_dien_tu/)) | Standard |
| **Thuế** | Lập tờ khai GTGT/TNDN/TNCN; xuất XML để nộp qua HTKK / cổng thuế điện tử, hoặc nộp trực tiếp qua MISA mTax; "Thuế điện tử" là tính năng mới gói Standard 2026 ([nộp tờ khai SME 2026](https://helpsme.misa.vn/2026/kb/nop_to_khai_thue/), [báo giá](https://sme.misa.vn/bao-gia)) | Standard |
| **Kho, Thủ kho** | Xem mục 2 | Standard |
| **Công cụ dụng cụ** | Ghi tăng, phân bổ CCDC (mục CCDC trong helpsme 2026) | Standard |
| **Tài sản cố định** | Ghi tăng, khấu hao TSCĐ (mục TSCĐ trong helpsme 2026) | Professional |
| **Tiền lương** | Bảng lương, hạch toán lương | Professional |
| **Hợp đồng** | Quản lý hợp đồng mua/bán; là đối tượng tính giá thành theo hợp đồng | Professional |
| **Khế ước vay** | Mới trong 2026 | Professional |
| **Giá thành** | Xem mục 2.6 | **Chỉ gói Enterprise** |
| **Ngân sách** | Lập/quản lý ngân sách | Enterprise |
| **Tổng hợp** | Chứng từ nghiệp vụ khác; khóa sổ / bỏ khóa sổ; đánh giá lại TK ngoại tệ; tính tỷ giá xuất quỹ; kết chuyển lãi lỗ; BCTC ([khóa sổ](https://helpsme.misa.vn/2023/kb/khoa_so_ke_toan/), [đánh giá ngoại tệ](https://helpsme.misa.vn/2026/kb/danhgialai_taikhoanngoaite/)) | Mọi gói |

---

## 2. Đi sâu: KHO và GIÁ THÀNH

### 2.1 Danh mục

| Danh mục | Điểm chính | Nguồn |
|---|---|---|
| **Vật tư hàng hóa (VTHH)** | Có "tính chất": *Vật tư hàng hóa*, *Thành phẩm*… Thành phẩm có tab **Định mức nguyên vật liệu** (BOM 1 cấp). | [giản đơn TT200](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theopp_iandon_theo_tt200/) |
| **Kho** | Nhiều kho; tính giá theo kho hoặc không theo kho; báo cáo tồn trên nhiều kho dạng ma trận | [tính giá xuất kho](https://helpsme.misa.vn/2026/kb/html_17060000/), [báo cáo kho](https://helpsme.misa.vn/2026/kb/html_35080000/) |
| **Mã quy cách** | Theo dõi số khung, số máy, màu, size… 2 loại: quy cách **không trùng** (serial-like: số khung/số máy/số thuê bao) và **có thể trùng** (size/màu) | [mã quy cách](https://helpsme.misa.vn/2021/kb/html_lamthenao_quanlymathangtheomavach_maquycach/), [số khung số máy](https://helpsme.misa.vn/2019/quan_ly_hang_hoa_theo_so_khung_so_may_mau_sac_o_to_xe_may1.htm) |
| **Số lô, hạn sử dụng** | Bật trong tùy chọn; nhập tồn đầu, mua, bán theo lô/HSD ở cả phân hệ Mua/Bán và Kho | [lô/HSD](https://helpsme.misa.vn/2023/kb/quan-ly-kho-hang-hoa-theo-so-lo-han-su-dung/) |
| **Đơn vị tính & quy đổi** | **[chưa xác minh chi tiết trên trang 2026]** — không tìm được trang hướng dẫn công khai mô tả rõ cơ chế ĐVT chuyển đổi; cần xác minh thêm | — |
| **Nhóm VTHH** | **[chưa xác minh chi tiết]** | — |
| **Đối tượng tập hợp chi phí (THCP)** | Danh mục riêng; loại "Sản phẩm" (mỗi đối tượng ↔ 1 thành phẩm), ngoài ra công trình, đơn hàng, hợp đồng dùng làm đối tượng giá thành theo phương pháp tương ứng | [giản đơn TT200](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theopp_iandon_theo_tt200/), [đơn hàng](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theodonhang_theott200/) |
| **Định mức phân bổ chi phí theo đối tượng THCP** | Khai báo để phân bổ CP chung theo định mức | (cùng nguồn) |
| **Định mức giá thành thành phẩm** | Theo khoản mục: NVL, nhân công, khấu hao, mua ngoài, chi phí khác; dùng cho đánh giá dở dang theo định mức và cho phương pháp hệ số/tỷ lệ | [định mức giá thành TP](https://helpsme.misa.vn/2023/kb/thiet_lap_dinh_muc_gia_thanh_thanh_pham/) |
| **Định mức NVL cho công trình / định mức phân bổ theo công trình** | Có trong mục Giá thành | [mục Giá thành 2022](https://helpsme.misa.vn/2022/kb/gia-thanh/) |

### 2.2 Chứng từ kho (SME 2026)

Nguồn: [helpsme 2026 – mục Kho](https://helpsme.misa.vn/2026/kb/6-kho/)

- **Nhập kho**: hàng mua đang đi đường; thành phẩm sản xuất; NVL dùng không hết nhập lại; hàng bán bị trả lại; hàng từ chi nhánh phụ thuộc chuyển đến; hàng gửi gia công nhập lại; hàng nhận bán hộ/ký gửi/ký cược; hàng nhận giữ hộ/gia công.
- **Xuất kho**: NVL cho sản xuất; NVL cho XDCB/sửa chữa lớn TSCĐ; góp vốn đầu tư; bán hàng; biếu tặng/tiêu dùng nội bộ; xuất cho chi nhánh hạch toán phụ thuộc; trả lại hàng mua.
- **Chuyển kho**: giữa các kho nội bộ; gửi bán đại lý.
- **Lắp ráp / Tháo dỡ**: Lệnh lắp ráp chọn thành phẩm + SL → tự tính linh kiện theo định mức NVL → tự sinh **phiếu xuất** (Nợ 154 / Có 152,156) và **phiếu nhập** (Nợ 155 / Có 154); giá thành phẩm lắp ráp = giá trị phiếu xuất ([lắp ráp](https://helpsme.misa.vn/2026/kb/xuatkho_vattu_delaprap_va_nhap_thanhpham_laprap/)). Tháo dỡ là chiều ngược lại.
- **Lệnh sản xuất**: chọn thành phẩm + SL → hệ thống tính NVL cần theo định mức → nút "Lập phiếu xuất" sinh phiếu xuất NVL, gán Đối tượng THCP ở tab Thống kê ([giản đơn](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theopp_iandon_theo_tt200/)). Có "Lập nhanh các lệnh sản xuất", báo cáo tiến độ sản xuất.
- **Kiểm kê kho**: theo hàng thường / theo lô-HSD / theo mã quy cách; xuất danh sách ra Excel và nhập lại kết quả; xử lý chênh lệch tự sinh phiếu nhập (thừa, Có 3381) / phiếu xuất (thiếu, Nợ 1381); đánh dấu "Đã xử lý chênh lệch" ([kiểm kê](https://helpsme.misa.vn/2026/kb/kiemkekho/)).
- **Tiện ích**: sắp xếp thứ tự chứng từ nhập/xuất (ảnh hưởng giá tức thời/FIFO), lập nhanh phiếu xuất/chuyển kho/lệnh SX, cập nhật đơn giá phiếu nhập từ chi nhánh chuyển đến, dashboard phân tích kho, kết nối phần mềm bán hàng (MISA eShop, CUKCUK, nhanh.vn).
- **Thủ kho**: khi thủ kho dùng phần mềm, chứng từ bán hàng tự sinh "Đề nghị nhập, xuất kho" cho thủ kho ([xuất kho bán hàng](https://helpsme.misa.vn/2026/kb/xuat_kho_ban_hang/)).

### 2.3 Tính giá xuất kho

Nguồn: [Tính giá xuất kho 2026](https://helpsme.misa.vn/2026/kb/html_17060000/), [Tùy chọn hệ thống](https://helpsme.misa.vn/2026/kb/thietlap_hethong/)

- 4 phương pháp (chọn trong Tùy chọn): **Bình quân cuối kỳ**, **Bình quân tức thời**, **Nhập trước xuất trước (FIFO)**, **Đích danh**.
- Phạm vi: **theo kho** hoặc **không theo kho**; nếu nhiều chi nhánh thì tính độc lập theo kho và chi nhánh.
- Bình quân cuối kỳ: đơn giá xuất chỉ có sau khi chạy chức năng "Tính giá xuất kho". Tức thời/FIFO/đích danh: có đơn giá khi Ghi sổ; khi sửa chứng từ quá khứ phải chạy lại tính giá, hệ thống tự xác định chứng từ bị ảnh hưởng. Chứng từ lắp ráp/tháo dỡ khác tháng phải tính lại từng tháng.
- Tùy chọn liên quan: "Cho phép xuất quá số lượng tồn", cảnh báo xuất âm kho.
- Hệ quả đã biết của bình quân cuối kỳ: giá trị tồn có thể âm tạm thời giữa kỳ dù cuối kỳ đúng — MISA giải thích là đặc tính phương pháp ([forum MISA](https://forum.misa.vn/threads/vi-sao-so-chi-tiet-ton-kho-bi-am-gia-tri-tai-mot-thoi-diem-trong-ky.821/)). Có trang FAQ riêng "tính giá xuất kho không lên đơn giá vốn hoặc sai" ([helpsme](https://helpsme.misa.vn/2023/kb/lam-the-nao-khi-tinh-gia-xuat-kho-khong-len-don-gia-von/)) → đây là điểm đau thực tế.

### 2.4 Cập nhật giá nhập kho thành phẩm

Nguồn: [helpsme 2026](https://helpsme.misa.vn/2026/kb/cap_nhat_gia_nhap_kho_thanh_pham/)

- Dùng khi **không tính giá thành trên phần mềm** (tính ngoài): lọc thành phẩm, nhập đơn giá (hoặc **nhập từ Excel**) → Thực hiện → cập nhật đơn giá và thành tiền trên các phiếu nhập có bút toán **Nợ 15x / Có 154** (trừ Nợ 154/Có 154).
- Sau đó, với bình quân cuối kỳ/tức thời/FIFO phải chạy lại "Tính giá xuất kho"; đích danh tự tính lại.
- Khi tính giá thành trong phân hệ Giá thành, có tùy chọn "Cập nhật giá nhập kho" và "Cập nhật giá xuất kho" ngay tại bước tính giá thành.

### 2.5 Phương pháp giá thành MISA hỗ trợ

Theo mục lục Giá thành trong tài liệu hướng dẫn ([helpsme 2022 – Giá thành](https://helpsme.misa.vn/2022/kb/gia-thanh/)), mỗi phương pháp có bản TT133 và TT200:

| Phương pháp | Đối tượng THCP / tính giá thành | Nguồn |
|---|---|---|
| Sản xuất liên tục – **Giản đơn** | Sản phẩm (1 đối tượng THCP ↔ 1 TP) | [TT200](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theopp_iandon_theo_tt200/), [2026 TT133](https://helpsme.misa.vn/2026/kb/tinhgiathanh_theopp_giandon_theott133/) |
| Sản xuất liên tục – **Hệ số, tỷ lệ** | Nhóm sản phẩm cùng NVL chính; phân bổ theo định mức giá thành TP để ra tỷ lệ → đơn giá | [TT200](https://helpsme.misa.vn/2023/kb/tinhgiathanh_theopp_hesotyle_theott200/), [công thức](https://helpsme.misa.vn/2023/kb/cong-thuc-cach-tinh-he-soty-le-trong-quy-trinh-gia-thanh-he-soty-le-tren-phan-mem/) |
| **Công trình / vụ việc** | Công trình (xây lắp) | [TT200](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theocongtrinhvuviec_theott200/) |
| **Đơn hàng** | Đơn đặt hàng có tích "Tính giá thành"; có bước **nghiệm thu** đơn hàng → kết chuyển 632, xem lãi lỗ, không cần nhập kho | [TT200](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theodonhang_theott200/) |
| **Hợp đồng** | Hợp đồng bán | [TT200](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theohopdong_tt200/) |
| **Phân bước** (nhiều công đoạn) | Không phải chức năng riêng: làm bằng **nhiều kỳ tính giá thành**, mỗi kỳ tính bán thành phẩm 1 công đoạn, kỳ cuối ra TP | [FAQ phân bước](https://helpsme.misa.vn/2023/kb/lam-the-nao-de-tinh-gia-thanh-phan-buoc-nhieu-cong-doan-tren-phan-mem/) |
| **Gia công** | Có FAQ riêng | [FAQ gia công](https://helpsme.misa.vn/2022/kb/html_lamthenao_tinhgiathanhgiacong/) |

**[mâu thuẫn nguồn]** Trang tính năng marketing ghi "Giản đơn, Hệ số, Tỷ lệ, Định mức, Phân bước liên tục" ([sme.misa.vn/tinh-nang/gia-thanh](https://sme.misa.vn/tinh-nang/gia-thanh/)), còn tài liệu hướng dẫn chỉ có menu cho giản đơn, hệ số-tỷ lệ, công trình, đơn hàng, hợp đồng; phân bước làm thủ công bằng nhiều kỳ; "định mức" xuất hiện dưới dạng tiêu thức phân bổ/đánh giá dở dang.

Tiêu thức phân bổ chi phí chung: NVL trực tiếp, nhân công trực tiếp, chi phí trực tiếp, hoặc định mức ([FAQ phân bước](https://helpsme.misa.vn/2023/kb/lam-the-nao-de-tinh-gia-thanh-phan-buoc-nhieu-cong-doan-tren-phan-mem/)); trên màn hình giản đơn có lựa chọn theo định mức hoặc số lượng. Đánh giá dở dang: theo NVL trực tiếp, sản lượng hoàn thành tương đương, hoặc định mức ([sme.misa.vn tính năng](https://sme.misa.vn/tinh-nang/gia-thanh/)).

### 2.6 Quy trình một kỳ tính giá thành (giản đơn, TT200)

Nguồn: [helpsme – giản đơn TT200](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theopp_iandon_theo_tt200/)

1. **Khai báo VTHH**: NVL (tính chất "Vật tư hàng hóa"), TP (tính chất "Thành phẩm") + định mức NVL.
2. **Khai báo Đối tượng THCP** loại "Sản phẩm".
3. **Xuất kho NVL** qua Lệnh sản xuất → Lập phiếu xuất (Nợ 621 / Có 152), gán đối tượng THCP. Đơn giá: BQ cuối kỳ có sau khi chạy Tính giá xuất kho; các PP khác có khi Ghi sổ.
4. **Hạch toán chi phí phát sinh** (Nợ 621/622/623/627/154) ở Quỹ, Ngân hàng, Tổng hợp; xác định được đối tượng thì gán, không thì để trống (chờ phân bổ). TK 623 chỉ dùng cho xây lắp.
5. **Nhập kho thành phẩm** (loại "Thành phẩm sản xuất", Nợ 155 / Có 154), gán đối tượng THCP; đơn giá tạm chưa có.
6. **Tạo kỳ tính giá thành** (Giá thành › Sản xuất liên tục – Giản đơn › Thêm) → "Lấy dữ liệu" tự lấy các đối tượng THCP phát sinh trong kỳ.
7. **Tính giá thành** 3 giai đoạn:
   a. *Phân bổ chi phí chung* (621/622/627 chưa gán đối tượng) theo tỷ lệ + tiêu thức; phần không phân bổ hết **không** chuyển kỳ sau.
   b. *Đánh giá dở dang*: nhập SL dở dang + % hoàn thành; theo định mức hoặc thực tế → "Tính chi phí dở dang".
   c. *Tính giá thành* → tích "Cập nhật giá nhập kho" (cập nhật phiếu nhập TP ở bước 5) và "Cập nhật giá xuất kho" → Cất. Kiểm tra tab **Bảng tính giá thành**.
8. **Kết chuyển chi phí**: tự sinh chứng từ kết chuyển 621/622/627 → 154.

Phương pháp đơn hàng thêm bước khai báo đơn hàng có tích "Tính giá thành" và **nghiệm thu đơn hàng** (kết chuyển sang 632, tính lãi lỗ) ([đơn hàng](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theodonhang_theott200/)).

Tiện ích kèm: tập hợp chi phí trực tiếp, tập hợp khoản giảm giá thành, bảng tập hợp chi phí theo yếu tố / theo khoản mục ([mục Giá thành](https://helpsme.misa.vn/2022/kb/gia-thanh/), [bảng THCP theo khoản mục](https://helpsme.misa.vn/2023/kb/bang_tap_hop_chi_phi_theo_khoan_muc/)).

### 2.7 Báo cáo kho & giá thành

**Kho** ([báo cáo kho 2026](https://helpsme.misa.vn/2026/kb/html_35080000/)): Tổng hợp tồn kho; THTK theo số lô; THTK theo mã quy cách; THTK hàng nhận bán hộ/ký gửi/gia công/giữ hộ; Tổng hợp tồn trên nhiều kho; Sổ chi tiết vật liệu, công cụ; Sổ chi tiết VTHH; Báo cáo tiến độ sản xuất; Tổng hợp xuất kho theo lệnh sản xuất; Sổ chuyển kho nội bộ; DS phiếu xuất chưa lập hóa đơn; Thẻ kho (theo lô/HSD); Báo cáo tồn theo chứng từ nhập (FIFO/đích danh); Sổ chi tiết vật tư theo chứng từ nhập; Đối chiếu xuất nhập hàng giữa các chi nhánh.

**Giá thành** ([mục Giá thành](https://helpsme.misa.vn/2022/kb/gia-thanh/), [tính năng](https://sme.misa.vn/tinh-nang/gia-thanh/)): bảng tính giá thành; bảng tập hợp chi phí theo yếu tố / theo khoản mục; báo cáo lãi lỗ theo công trình/đơn hàng/hợp đồng; thẻ tính giá thành, sổ chi phí SXKD (theo mẫu chế độ). Danh sách đầy đủ: [báo cáo giá thành](https://helpsme.misa.vn/2022/kb/bao_cao_gia_thanh/).

### 2.8 Lô/HSD, serial, nhiều kho — tóm tắt

| Năng lực | MISA SME | Ghi chú |
|---|---|---|
| Nhiều kho | Có; tính giá theo kho hoặc gộp | |
| Lô + HSD | Có (bật trong tùy chọn), kiểm kê và thẻ kho theo lô | Cảnh báo hết hạn chủ yếu thấy ở MISA eShop (bán lẻ), chưa xác minh trong SME |
| Serial | Qua "mã quy cách không trùng" (số khung, số máy) | Không phải module serial/IMEI chuyên biệt như KiotViet/Sapo |
| Vị trí kệ/bin | **[không tìm thấy]** trong tài liệu SME | Bravo quảng cáo theo dõi theo vị trí ([Bravo](https://www.bravo.com.vn/bravo/bravo-erp-vn/ke-toan-gia-thanh-tren-san-pham-phan-mem-ke-toan-bravo-8/)) |

---

## 3. Luồng nghiệp vụ end-to-end và bút toán tự sinh

| Bước | Chứng từ MISA | Bút toán tự sinh (theo tài liệu MISA) | Nguồn |
|---|---|---|---|
| 1. Mua hàng | Đơn mua hàng → Chứng từ mua hàng nhập kho (có thể lập từ HĐĐT đầu vào) | Nợ 152/156, Nợ 133 / Có 331 (hoặc 111/112); chi phí mua phân bổ vào giá nhập | [mua trong nước](https://helpsme.misa.vn/2026/kb/muahang_trongnuoc_venhapkho/) |
| 2. Xuất NVL sản xuất | Lệnh sản xuất → Phiếu xuất NVL (gán đối tượng THCP) | Nợ 621 / Có 152 | [giản đơn](https://helpsme.misa.vn/2022/kb/tinhgiathanh_theopp_iandon_theo_tt200/) |
| 3. Chi phí NC, SXC | Phiếu chi / UNC / chứng từ nghiệp vụ khác / bảng lương | Nợ 622, 627 / Có 334, 111, 112, 214… | (cùng nguồn) |
| 4. Nhập kho TP | Phiếu nhập "Thành phẩm sản xuất" (đơn giá tạm = 0) | Nợ 155 / Có 154 | (cùng nguồn) |
| 5. Kỳ giá thành | Phân bổ → dở dang → tính giá thành → cập nhật giá nhập TP | Kết chuyển Nợ 154 / Có 621, 622, 627; cập nhật giá phiếu nhập TP | (cùng nguồn) |
| 6. Bán hàng | Chứng từ bán hàng (doanh thu) → Phiếu xuất kho bán hàng chọn từ chứng từ bán | Nợ 131/111/112 / Có 511, 3331; Nợ 632 / Có 155/156 | [xuất kho bán hàng](https://helpsme.misa.vn/2026/kb/xuat_kho_ban_hang/) |
| 7. Tính giá xuất kho | Chức năng Tính giá xuất kho | Cập nhật đơn giá 632 trên các phiếu xuất | [tính giá xuất kho](https://helpsme.misa.vn/2026/kb/html_17060000/) |
| 8. Cuối kỳ | Đánh giá lại ngoại tệ, tính tỷ giá xuất quỹ, kết chuyển lãi lỗ, lập tờ khai thuế, BCTC | — | [đánh giá ngoại tệ](https://helpsme.misa.vn/2026/kb/danhgialai_taikhoanngoaite/) |
| 9. Khóa sổ | Tổng hợp › Khóa sổ kỳ kế toán: nhập ngày khóa sổ mới → không thêm/sửa/xóa chứng từ có ngày ≤ ngày khóa. Bỏ khóa: đặt lại ngày khóa sổ | — | [khóa sổ](https://helpsme.misa.vn/2023/kb/khoa_so_ke_toan/), [bỏ khóa 2026](https://helpsme.misa.vn/2026/kb/html_23060000/) |

**Nguyên tắc sinh bút toán của MISA** (rút ra từ các trang trên):
- Mỗi chứng từ nghiệp vụ có **loại chứng từ** và TK mặc định; người dùng có thể sửa TK Nợ/Có trên dòng.
- Chế độ **"Cất đồng thời ghi sổ"** hoặc **"Cất không ghi sổ"** (ghi sổ sau) ([tùy chọn](https://helpsme.misa.vn/2026/kb/thietlap_hethong/)). Chứng từ nhập khẩu từ Excel ở trạng thái chưa ghi sổ ([nhập khẩu Excel](https://helpsme.misa.vn/2026/kb/html_10050000/)).
- Giá trị tiền trên phiếu xuất (632, 621) và phiếu nhập TP **được cập nhật lại** bởi các chức năng batch (Tính giá xuất kho, Tính giá thành, Cập nhật giá nhập TP) — tức sổ cái là "sống", không bất biến cho tới khi khóa sổ. Đây là quyết định thiết kế quan trọng cần cân nhắc cho hệ thống mới.
- Thứ tự chứng từ trong ngày ảnh hưởng giá (có tiện ích "Sắp xếp thứ tự chứng từ nhập, xuất").

---

## 4. Tính năng hệ thống

| Tính năng | MISA SME 2026 | Nguồn |
|---|---|---|
| **Nhiều chi nhánh** | Tùy chọn có/không chi nhánh; danh mục dùng chung hoặc riêng theo chi nhánh; chứng từ xuất/nhập giữa chi nhánh hạch toán phụ thuộc + báo cáo đối chiếu; tính giá theo chi nhánh | [tùy chọn](https://helpsme.misa.vn/2026/kb/thietlap_hethong/), [mục Kho](https://helpsme.misa.vn/2026/kb/6-kho/) |
| **Nhiều sổ** | Nhật ký truy cập có cột "Làm việc trên sổ" (sổ tài chính / sổ quản trị) | [nhật ký truy cập](https://helpsme.misa.vn/2026/kb/kiem_tra_nhat_ky_truy_cap/) |
| **Phân quyền** | Người dùng + Vai trò (tạo/sửa vai trò, gán vai trò). Mức chi tiết (theo thao tác/chi nhánh) **[chưa xác minh từ trang 2026]** | [vai trò & quyền](https://helpsme.misa.vn/2026/kb/phan_quyen_su_dung/) |
| **Khóa sổ kỳ** | Theo ngày khóa sổ; bỏ khóa bằng đặt lại ngày | [khóa sổ](https://helpsme.misa.vn/2023/kb/khoa_so_ke_toan/) |
| **Nhật ký truy cập** | Ghi người dùng, thời gian, hành động (thêm/sửa/xóa), đối tượng, tên máy, IP, chi nhánh, sổ, mô tả chi tiết thay đổi; **không cho xóa** | [nhật ký truy cập](https://helpsme.misa.vn/2026/kb/kiem_tra_nhat_ky_truy_cap/) |
| **Nhập khẩu Excel** | Tệp › Nhập khẩu từ Excel, 4 bước: chọn loại (Danh mục/Số dư/Chứng từ) → chi tiết → file/sheet → kiểm tra hợp lệ; có copy-paste Excel vào lưới chứng từ | [nhập khẩu](https://helpsme.misa.vn/2026/kb/html_10050000/), [copy Excel](https://helpsme.misa.vn/2026/kb/copy-du-lieu-tu-excel-vao-chung-tu/) |
| **Hóa đơn điện tử** | Phân hệ HĐĐT (meInvoice); AMIS đồng bộ HĐ đầu vào từ cổng Thuế | xem mục 1 |
| **Ngân hàng điện tử** | 10 ngân hàng; chuyển tiền, đối chiếu online | xem mục 1 |
| **Thuế** | Xuất XML cho HTKK/cổng thuế; nộp qua mTax; ký số; thiết lập ký số trong Hệ thống | [nộp tờ khai](https://helpsme.misa.vn/2026/kb/nop_to_khai_thue/), [ký số](https://helpsme.misa.vn/2026/kb/thiet_lap_ky_so/) |
| **Đa tiền tệ** | Tùy chọn "Có phát sinh nghiệp vụ liên quan đến ngoại tệ"; tỷ giá xuất quỹ BQ cuối kỳ/tức thời; đánh giá lại TK ngoại tệ cuối kỳ | [đánh giá ngoại tệ](https://helpsme.misa.vn/2026/kb/danhgialai_taikhoanngoaite/) |
| **Khác** | Email/ mẫu email, nhắc nhở thông minh, quản lý người dùng mobile, đánh số chứng từ theo quy tắc, định dạng số, cảnh báo âm kho/vượt hạn mức nợ/trùng HĐ/sai MST | [hệ thống](https://helpsme.misa.vn/2026/kb/he-thong/), [tùy chọn](https://helpsme.misa.vn/2026/kb/thietlap_hethong/) |
| **Kết nối bán hàng** | MISA eShop, CUKCUK, nhanh.vn → SME | [mục Kho](https://helpsme.misa.vn/2026/kb/6-kho/) |

---

## 5. Giá, gói, phân khúc; điểm yếu → cơ hội

### 5.1 Bảng giá (thu thập 2026)

**MISA SME 2026 (thuê bao/năm)** — [sme.misa.vn/bao-gia](https://sme.misa.vn/bao-gia)

| Gói | Giá/năm | User | Phân hệ |
|---|---|---|---|
| Standard | 6.150.000đ | 3 | Quỹ, Thủ quỹ, Ngân hàng, Mua, Bán, QL hóa đơn, Thuế, Kho, Thủ kho, CCDC, Tổng hợp, Thuế điện tử |
| Professional (khuyên dùng) | 7.650.000đ | 3 | + TSCĐ, Tiền lương, Hợp đồng, Khế ước vay |
| Enterprise | 9.150.000đ | 3 | + **Giá thành**, Ngân sách |
| Thêm user | 2.050.000–3.050.000đ/người/năm | | |

Một trang báo giá khác của MISA ghi SME thuê bao 6.150.000–19.950.000đ (có cả hình thức mua vĩnh viễn) ([amis.misa.vn báo giá](https://amis.misa.vn/20355/bao-gia-phan-mem-ke-toan-online-misa-amis/)).

**MISA AMIS Kế toán (cloud, /năm)** — [amis.misa.vn báo giá](https://amis.misa.vn/20355/bao-gia-phan-mem-ke-toan-online-misa-amis/), [bảng giá AMIS](https://amis.misa.vn/128379/bang-gia-phan-mem-misa-amis/)

| Gói | Giá | Định vị |
|---|---|---|
| Starter | 2.950.000đ (1 user, 9 nghiệp vụ) **[mâu thuẫn nguồn: trang sản phẩm ghi từ 3.650.000đ]** | DN mới thành lập |
| Standard | 4.450.000đ (3 user) | Thương mại/dịch vụ; có Kho, CCDC |
| Professional | 5.950.000đ (3 user) | + TSCĐ, lương, hợp đồng, thu nợ |
| Enterprise | 6.950.000đ (3 user) | Sản xuất/xây lắp — **Giá thành** |
| Enterprise Plus | 8.150.000đ | + Ngân sách, phân tích tài chính |

Giá Standard–Enterprise lấy từ kết quả tìm kiếm trích trang AMIS, trang chính chỉ hiển thị khoảng 2,95–8,15 triệu. AMIS giới hạn ~100 hóa đơn/gói theo trang sản phẩm.

**Đối thủ**

| Sản phẩm | Điểm nổi bật về kho/giá thành | Giá công bố | Nguồn |
|---|---|---|---|
| FAST Accounting | Giá thành linh hoạt: theo đơn hàng hoặc sản xuất để kho; cùng SP ở nhiều phân xưởng/lệnh SX; nhiều công đoạn; PP định mức, tỷ lệ, trực tiếp hoặc kết hợp; NVL thay thế trong định mức | Bản sản xuất 11.900.000đ + 4.450.000đ triển khai (bên thứ ba) | [fast.com.vn](https://fast.com.vn/fast-accounting-phan-mem-ke-toan-chuyen-sau-ve-quan-tri-va-tinh-gia-thanh/), [accgroup](https://accgroup.vn/phan-mem-ke-toan-fast/) |
| Bravo 8 / ERP | DN vừa–lớn; giá thành nhiều công đoạn (chi phí trực tiếp gán công đoạn, chung phân bổ); tồn kho theo lô, vị trí, serial | Không công bố | [bravo.com.vn](https://www.bravo.com.vn/bravo/bravo-erp-vn/ke-toan-gia-thanh-tren-san-pham-phan-mem-ke-toan-bravo-8/) |
| Viindoo (nền Odoo) | Giá chuẩn/FIFO/bình quân; landed cost tự phân bổ; BOM, giá thành thực tế vs định mức | Kế toán Standard 198.000đ/tháng (158.400đ nếu trả năm) | [viindoo docs](https://viindoo.com/documentation/17.0/applications/finance/accounting-and-invoicing/manufacturing/production-costs-configuration.html), [báo giá](https://viindoo.com/blog/business-management-3/accounting-software-pricing-916) |
| Base.vn | Nền tảng quản trị; Base Finance+ (dashboard, ngân sách); không phải phần mềm kế toán theo chế độ chuyên sâu | — | [base.vn](https://base.vn/) |
| KiotViet / Sapo | Bán lẻ cloud; lô-HSD, serial/IMEI chuyên biệt; không có giá thành/chế độ kế toán đầy đủ | — | [KiotViet lô](https://www.kiotviet.vn/huong-dan-su-dung-kiotviet/retail-hang-hoa/hang-hoa-lo-han-su-dung/), [Sapo serial](https://support.sapo.vn/quan-ly-san-pham-serial-imei) |

### 5.2 Điểm yếu người dùng phàn nàn (có nguồn)

| Điểm yếu | Nguồn | Mức tin cậy |
|---|---|---|
| Xử lý chậm, nhất là khi **cập nhật giá xuất** hoặc bảo trì dữ liệu; cần máy cấu hình cao | [webketoan](https://webketoan.com/threads/1525470-uu-nhuoc-diem-cua-cac-phan-mem-ke-toan-hien-nay/), [dichvuketoanbienhoa](https://dichvuketoanbienhoa.com/uu-nhuoc-diem-phan-mem-ke-toan-misa-moi.html) | Trung bình — bài diễn đàn cũ, áp dụng bản desktop |
| **Phân hệ giá thành chưa được chú trọng**, chưa đáp ứng nhu cầu | (cùng nguồn) | Trung bình — phù hợp với việc phân bước phải làm thủ công nhiều kỳ |
| Báo cáo xuất Excel không đúng thứ tự; in sổ chi tiết khó | (cùng nguồn) | Thấp–trung bình |
| Lỗi/nhầm lẫn giá xuất kho, tồn âm giá trị giữa kỳ (BQ cuối kỳ), đơn giá không lên | [forum MISA](https://forum.misa.vn/threads/tinh-gia-xuat-kho-bi-sai.67671/), [FAQ MISA](https://helpsme.misa.vn/2023/kb/lam-the-nao-khi-tinh-gia-xuat-kho-khong-len-don-gia-von/) | Cao — chính MISA có FAQ |
| Bất tiện khi làm nhiều dữ liệu (nhiều công ty) cùng lúc | [webketoan](https://webketoan.com/threads/1525470-uu-nhuoc-diem-cua-cac-phan-mem-ke-toan-hien-nay/) | Thấp |
| Giá thành chỉ có ở gói cao nhất (SME Enterprise / AMIS Enterprise) | [báo giá SME](https://sme.misa.vn/bao-gia) | Cao (dữ kiện) |

### 5.3 Cơ hội khác biệt (suy luận từ dữ kiện trên)

1. **Giá vốn tính lại tăng dần (incremental), nhanh, minh bạch**: thay "chạy Tính giá xuất kho" batch chậm bằng engine tính lại theo vật tư/kho bị ảnh hưởng, có giải thích từng đơn giá (drill-down: phiếu xuất này lấy giá từ đâu).
2. **Giá thành nhiều công đoạn native** (BOM nhiều cấp, routing, bán thành phẩm) thay vì xếp nhiều kỳ thủ công; tính chênh lệch thực tế vs định mức.
3. **Kho hiện đại trong cùng sổ kế toán**: serial/IMEI chuyên biệt, lô-HSD có FEFO + cảnh báo hết hạn, vị trí kệ, quét mã vạch mobile — điều SME đang phải ghép với eShop/KiotViet.
4. **Cloud-first, giá thấp hơn cho SX nhỏ**: đưa giá thành cơ bản (giản đơn + đơn hàng) vào gói giữa thay vì chỉ gói đắt nhất.
5. **Kiểm soát khóa sổ chi tiết hơn** (khóa theo phân hệ/ chi nhánh, workflow mở khóa có phê duyệt, nhật ký) và báo cáo đối chiếu tự động kho ↔ sổ cái (152/155/156).
6. **TT99 sẵn từ đầu** (không mang nợ kỹ thuật TT200).

---

## 6. Kết luận — phạm vi đề xuất

Nguyên tắc: MVP phải tạo được **vòng khép kín mua → kho → bán → giá vốn → báo cáo → khóa sổ** cho DN thương mại và SX đơn giản; giá thành giản đơn vào MVP vì đây là điểm khác biệt chính (MISA bán ở gói cao nhất và bị chê).

### MVP (Phase 1)

| # | User story | Ưu tiên |
|---|---|---|
| 1 | Là kế toán, tôi khai báo danh mục TK theo TT99/TT133, đối tượng (KH/NCC/NV), VTHH, kho, ĐVT + quy đổi, nhóm VTHH | P0 |
| 2 | Là kế toán, tôi nhập số dư đầu kỳ (TK, công nợ, tồn kho theo kho) và nhập khẩu danh mục/số dư từ Excel có kiểm tra hợp lệ | P0 |
| 3 | Là kế toán, tôi lập phiếu thu/chi, báo nợ/báo có; hệ thống tự sinh bút toán | P0 |
| 4 | Là kế toán mua hàng, tôi lập chứng từ mua hàng nhập kho (có thuế GTGT, chi phí mua phân bổ vào giá nhập) → Nợ 152/156, 133 / Có 331 | P0 |
| 5 | Là kế toán bán hàng, tôi lập chứng từ bán hàng kiêm xuất kho → Nợ 131 / Có 511, 3331 và Nợ 632 / Có 155/156 | P0 |
| 6 | Là thủ kho/kế toán kho, tôi lập phiếu nhập, xuất (theo lý do), chuyển kho nội bộ, nhiều kho | P0 |
| 7 | Là kế toán, tôi chọn PP tính giá xuất: BQ cuối kỳ, BQ tức thời, FIFO (theo kho / không theo kho); giá vốn tự cập nhật và xem được nguồn gốc đơn giá | P0 |
| 8 | Là kế toán SX, tôi khai báo BOM 1 cấp, lập lệnh sản xuất → tự sinh phiếu xuất NVL; nhập kho TP | P0 |
| 9 | Là kế toán SX, tôi chạy kỳ giá thành **giản đơn**: phân bổ CP chung (NVL/NC/định mức/SL), đánh giá dở dang, tính giá thành, cập nhật giá nhập TP, kết chuyển 154 | P0 |
| 10 | Là kế toán, tôi kiểm kê kho và xử lý chênh lệch tự sinh phiếu nhập/xuất | P1 |
| 11 | Là kế toán trưởng, tôi khóa sổ theo ngày; bỏ khóa có lưu vết | P0 |
| 12 | Là quản trị, tôi quản lý người dùng, vai trò, quyền theo phân hệ × thao tác; nhật ký truy cập không xóa được | P0 |
| 13 | Là kế toán, tôi xem báo cáo: sổ nhật ký chung, sổ cái, CĐPS, tổng hợp tồn kho, sổ chi tiết VTHH, thẻ kho, công nợ, bảng tính giá thành, BCTC cơ bản | P0 |
| 14 | Là kế toán, tôi kết chuyển lãi lỗ cuối kỳ | P1 |

### Phase 2

| # | User story | Ưu tiên |
|---|---|---|
| 1 | Lô + HSD (FEFO, cảnh báo hết hạn), serial/IMEI chuyên biệt, kiểm kê theo lô/serial | P1 |
| 2 | Giá thành **hệ số/tỷ lệ**, **theo đơn hàng** (nghiệm thu → 632, lãi lỗ đơn hàng) | P1 |
| 3 | Lắp ráp/tháo dỡ; xuất/nhập gia công; FIFO + đích danh | P1 |
| 4 | Hóa đơn điện tử: phát hành HĐ đầu ra qua nhà cung cấp HĐĐT; đồng bộ HĐ đầu vào → lập chứng từ mua | P1 |
| 5 | Thuế: tờ khai GTGT, xuất XML tương thích HTKK/cổng thuế | P1 |
| 6 | Đơn mua hàng, đơn bán hàng, báo giá; hàng mua đi đường; trả lại hàng | P1 |
| 7 | CCDC và TSCĐ (ghi tăng, phân bổ, khấu hao) | P2 |
| 8 | Đa tiền tệ: tỷ giá xuất quỹ, đánh giá lại TK ngoại tệ | P2 |
| 9 | App mobile thủ kho: quét mã vạch nhập/xuất/kiểm kê | P2 |

### Phase 3

| # | User story | Ưu tiên |
|---|---|---|
| 1 | Giá thành nhiều công đoạn (BOM nhiều cấp, bán thành phẩm), công trình/vụ việc, hợp đồng; so sánh thực tế vs định mức | P2 |
| 2 | Nhiều chi nhánh hạch toán phụ thuộc, chuyển hàng nội bộ có đối chiếu, báo cáo hợp nhất | P2 |
| 3 | Kết nối ngân hàng điện tử (sổ phụ, đối chiếu tự động, lệnh chuyển tiền) | P2 |
| 4 | Tiền lương, hợp đồng, khế ước vay, ngân sách | P3 |
| 5 | Kết nối phần mềm bán hàng / sàn TMĐT (nhập đơn bán tự động), vị trí kệ/bin | P3 |
| 6 | Trợ lý AI hạch toán HĐ đầu vào (tương tự AVA của AMIS) | P3 |

### Các điểm cần nghiên cứu tiếp
- Danh mục TK và mẫu chứng từ/sổ theo TT99/2025 (khác TT200 thế nào ở 152–156, 154, 632).
- Cơ chế ĐVT quy đổi và nhóm VTHH trong MISA (chưa xác minh từ trang công khai).
- Mức chi tiết phân quyền MISA (theo chi nhánh/ dữ liệu người khác).
- Định dạng XML tờ khai HTKK và API của nhà cung cấp HĐĐT/ngân hàng.
