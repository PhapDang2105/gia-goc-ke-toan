# 01 — Đặc tả nghiệp vụ & logic kế toán (Kho – Giá thành – Kế toán tổng hợp)

> Phạm vi: phần mềm kế toán / quản lý kho / tính giá thành cho DN Việt Nam (tham chiếu hành vi MISA SME).
> Ngày lập: 2026-10-04. Ký hiệu độ tin cậy: **[XM]** = đã xác minh qua nguồn web khi lập tài liệu; **[KT]** = kiến thức chuyên môn phổ biến, khớp TT200/TT133 nhưng chưa đối chiếu nguyên văn lần này; **[CXM]** = chưa xác minh / cần đối chiếu văn bản gốc trước khi code cứng.
> Nguyên tắc thiết kế: **mọi quy định có thể thay đổi (số hiệu TK, mẫu báo cáo, thuế suất) phải là dữ liệu cấu hình theo "Chế độ kế toán" (TT200 / TT133 / TT99), không hard-code.**

---

## 1. Khung pháp lý hiện hành (tại 10/2026)

| Văn bản | Nội dung | Hiệu lực / tình trạng | Ghi chú cho phần mềm | Độ tin cậy |
|---|---|---|---|---|
| **Luật Kế toán 88/2015/QH13** | Chứng từ, sổ, BCTC, lưu trữ, phần mềm kế toán | Hiệu lực 01/01/2017; sửa đổi bởi Luật QLT 2019 và **Luật 56/2024/QH15** (hiệu lực 01/01/2025, bổ sung Điều 70a về dịch vụ kế toán của đại lý thuế) | Lưu trữ sổ, BCTC ≥ 10 năm; chứng từ điện tử có giá trị như giấy; sửa sổ phải theo phương pháp quy định (không xóa dấu vết) | [XM] |
| **TT 200/2014/TT-BTC** | Chế độ kế toán DN (lớn) | **Bị thay thế bởi TT99/2025 từ 01/01/2026** (áp dụng cho năm tài chính bắt đầu từ/sau 01/01/2026). Vẫn cần hỗ trợ để xem/in dữ liệu các năm ≤ 2025 | Giữ bộ cấu hình "TT200" cho dữ liệu lịch sử | [XM] |
| **TT 99/2025/TT-BTC** (27/10/2025) | Chế độ kế toán DN mới | Hiệu lực **01/01/2026**, thay thế TT200 và một số TT liên quan (Điều 31 nêu 4 văn bản bị thay thế) | Bộ cấu hình mặc định cho DN không phải DNNVV | [XM] ngày & thay thế; chi tiết danh mục TK một phần [XM] |
| **TT 133/2016/TT-BTC** | Chế độ kế toán DN nhỏ và vừa | **Vẫn còn hiệu lực**; TT99 **không** thay thế TT133. DNNVV được chọn TT133 hoặc TT99. Có dự thảo thay thế TT133 (rút gọn TK) **chưa ban hành** | Bộ cấu hình "TT133" — nhiều khách hàng SME sẽ dùng | [XM] |
| **VAS 02 – Hàng tồn kho** (QĐ 149/2001/QĐ-BTC) | Giá gốc, giá trị thuần có thể thực hiện (NRV), phương pháp tính giá xuất | Còn hiệu lực | Xem mục 3 | [KT] |
| **NĐ 123/2020/NĐ-CP** | Hóa đơn, chứng từ | Hiệu lực 01/07/2022 (bắt buộc HĐĐT) | Phần mềm kế toán nhận/ghi nhận HĐ đầu vào, phát hành HĐ đầu ra (thường qua nhà cung cấp HĐĐT) | [KT] |
| **NĐ 70/2025/NĐ-CP** (20/03/2025) | Sửa đổi NĐ123 | Hiệu lực **01/06/2025**. Điểm chính: thời điểm lập HĐ bán hàng = thời điểm chuyển giao quyền sở hữu/sử dụng **không phân biệt đã thu tiền**; HĐ xuất khẩu lập chậm nhất ngày làm việc tiếp theo sau thông quan; HĐĐT khởi tạo từ máy tính tiền mở rộng; sửa quy trình xử lý HĐ sai sót (điều chỉnh/thay thế); chứng từ khấu trừ TNCN điện tử | Ngày HĐ ≠ ngày thu tiền; liên kết HĐ gốc ↔ HĐ điều chỉnh/thay thế | [XM] hiệu lực & thời điểm lập HĐ; chi tiết xử lý sai sót [CXM] |
| **TT 78/2021/TT-BTC** | Hướng dẫn HĐĐT | **Bị thay thế bởi TT32/2025** từ 01/06/2025 | — | [XM] |
| **TT 32/2025/TT-BTC** (31/05/2025) | Hướng dẫn NĐ123 + NĐ70 | Hiệu lực **01/06/2025** | Ký hiệu mẫu số/ký hiệu HĐ, ủy nhiệm lập HĐ (bỏ điều kiện bên liên kết) | [XM] |
| TT 48/2019/TT-BTC (sửa bởi TT 24/2022) | Trích lập dự phòng giảm giá HTK | Còn hiệu lực (theo hiểu biết) | Điều kiện trích lập dự phòng được trừ thuế | [CXM] |
| Luật Thuế GTGT 48/2024/QH15 + NĐ 181/2025 | Thuế GTGT | Hiệu lực 01/07/2025 | Thuế suất 0/5/10%, giảm 2% (8%) theo Nghị quyết từng thời kỳ — **cấu hình theo ngày** | [CXM] thời hạn giảm thuế 8% hiện hành |

### 1.1 Thay đổi chính của TT99/2025 so với TT200 (ảnh hưởng phần mềm)

| Thay đổi | Chi tiết | Độ tin cậy |
|---|---|---|
| Quyền tự thiết kế hệ thống TK | DN được **sửa tên, số hiệu, kết cấu, nội dung TK** không cần xin BTC chấp thuận, phải ghi vào quy chế kế toán nội bộ → phần mềm phải cho phép danh mục TK tùy biến nhưng gắn "TK chuẩn" (mapping) để lập BCTC | [XM] |
| **Bỏ TK 611 (Mua hàng), TK 631 (Giá thành SX)** | Không còn hạch toán theo phương pháp KKĐK qua 611/631; mua hàng ghi thẳng 151/152/153/156; giá thành tập hợp 154 | [XM] (nhiều nguồn: MISA, ketoan.vn, easybooks) |
| Bỏ TK 161, 417, 441, 461, 466 | Không liên quan kho | [XM] |
| Bỏ TK cấp 2 **1562** (chi phí thu mua) | MISA AMIS liệt kê "bỏ TK 1562"; chi phí mua hàng ghi trực tiếp vào giá gốc 156 (hoặc 632 nếu nhỏ). Phần mềm vẫn nên cho phép theo dõi chi phí mua riêng (TK chi tiết tùy chọn) | [XM một nguồn] / [CXM] cấu trúc cấp 2 của 156 |
| Bổ sung | 215 Tài sản sinh học (2151–2153), 2295 DP tổn thất TS sinh học, **1383 Thuế TTĐB của hàng nhập khẩu**, 1385 (MISA nêu, nội dung [CXM]), 2414 Nâng cấp cải tạo TSCĐ, 332 Phải trả cổ tức/lợi nhuận, 3525, **6275** (MISA nêu, nội dung [CXM]), 82112 Thuế TNDN bổ sung theo thuế tối thiểu toàn cầu | [XM] tên TK; nội dung 1385/6275 [CXM] |
| Đổi tên | 112 → "Tiền gửi không kỳ hạn"; **155 "Thành phẩm" → "Sản phẩm"**; 242 → "Chi phí chờ phân bổ"; 419 → "Cổ phiếu mua lại của chính mình"; 3387 → "Doanh thu chờ phân bổ" | [XM] |
| Giữ nguyên (liên quan kho/doanh thu) | 133, 151–154, 156, 157, 158, 2294, 3331…3338, 511, 521, 621, 622, 623, 627, 632 | [XM] |
| BCTC | "Bảng cân đối kế toán" → **"Báo cáo tình hình tài chính"**; vẫn có BCKQKD, LCTT, Thuyết minh; đơn vị phụ thuộc không bắt buộc lập BCTC riêng | [XM] |
| Sổ kế toán | Phụ lục mẫu sổ giảm từ 45 → 42 mẫu; số hiệu mẫu cụ thể [CXM] | [XM] số lượng |
| Phần mềm kế toán | Yêu cầu đảm bảo chính xác, minh bạch, **ngăn sửa dữ liệu trái phép, lưu vết sửa đổi** | [XM] (theo MISA tóm tắt) |
| Tổng số TK cấp 1 | 71 (ít hơn TT200 5 TK) | [XM] |
| Phương pháp tính giá xuất | Dẫn chiếu VAS 02; không phát hiện thay đổi | [CXM] |

Nguồn: [VASEP – văn bản TT99](https://vasep.com.vn/van-ban/bo-tai-chinh/thong-tu-99-2025-tt-btc-huong-dan-che-do-ke-toan-doanh-nghiep-3440.html), [ATA Legal](https://ata-legal.com/thong-tu-99-2025-tt-btc-cac-diem-moi-noi-bat-ve-che-do-ke-toan-doanh-nghiep-tu-ngay-01-01-2026), [MISA AMIS](https://amis.misa.vn/251383/thong-tu-99-2025-tt-btc-thay-the-thong-tu-200-2014-tt-btc/), [ketoan.vn](https://www.ketoan.vn/tin-tuc/thay-doi-trong-he-thong-tai-khoan-cua-thong-tu-99-2025-tt-btc/), [Easybooks](https://easybooks.vn/he-thong-tai-khoan-theo-thong-tu-99-2025/), [LuatVietnam – danh mục TK TT99](https://luatvietnam.vn/thue-phi-le-phi/danh-muc-tai-khoan-ke-toan-theo-thong-tu-99-2025-tt-btc-565-105326-article.html), [TVPL – TT133 có bị thay thế?](https://thuvienphapluat.vn/ma-so-thue/phap-luat-thue/thong-tu-992025-co-thay-the-thong-tu-1332016-che-do-ke-toan-doanh-nghiep-nho-va-vua-213873.html), [Fast – dự thảo thay TT133](https://fast.com.vn/du-thao-thong-tu-thay-the-thong-tu-133-2016-tt-btc/), [LuatVietnam – NĐ70](https://luatvietnam.vn/tin-van-ban-moi/da-co-nghi-dinh-70-2025-nd-cp-sua-doi-nghi-dinh-123-2020-186-101431-article.html), [meInvoice – TT32 thay TT78](https://www.meinvoice.vn/tin-tuc/34635/thong-tu-32-2025-tt-btc-thay-the-thong-tu-78/), [TVPL – Luật 56/2024](https://thuvienphapluat.vn/van-ban/Thue-Phi-Le-Phi/Luat-sua-doi-Luat-Chung-khoan-Ke-toan-Ngan-sach-Nha-nuoc-Thue-thu-nhap-ca-nhan-2024-622318.aspx). Văn bản gốc nên tải từ vbpl.vn / thuvienphapluat.vn để đối chiếu Phụ lục II (danh mục TK) và Phụ lục IV (mẫu BCTC) của TT99.

**Hệ quả thiết kế:**
1. Bảng `accounting_regime` (TT200, TT133, TT99) → mỗi DN chọn 1 chế độ cho mỗi năm tài chính; đổi chế độ chỉ ở đầu năm tài chính, kèm **bảng chuyển đổi số dư** (mapping TK cũ → TK mới, ví dụ 611 → 152/156; 1562 → 156; 631 → 154).
2. Hỗ trợ cả phương pháp **kê khai thường xuyên (KKTX)** (mặc định, như MISA) và chỉ hỗ trợ KKĐK cho TT133 (còn TK 611). Với TT99, KKĐK (nếu DN chọn) vẫn hạch toán vào TK HTK — [CXM] hướng dẫn cụ thể; đề xuất MVP chỉ hỗ trợ KKTX.

---

## 2. Hệ thống tài khoản cốt lõi (kho & giá thành)

| TK | Tên | Tính chất | TT200 | TT133 | TT99 |
|---|---|---|---|---|---|
| 111/112 | Tiền mặt / Tiền gửi | Dư Nợ | ✓ | ✓ | ✓ (112 đổi tên "Tiền gửi không kỳ hạn") |
| 131 | Phải thu khách hàng | Lưỡng tính (chi tiết theo KH) | ✓ | ✓ | ✓ |
| 133 | Thuế GTGT được khấu trừ (1331 HH-DV, 1332 TSCĐ) | Dư Nợ | ✓ | ✓ | ✓ |
| 1381 / 3381 | Tài sản thiếu chờ xử lý / thừa chờ giải quyết | | ✓ | ✓ | ✓ |
| 1383 | Thuế TTĐB của hàng nhập khẩu | Dư Nợ | — | — | **mới** |
| 151 | Hàng mua đang đi đường | Dư Nợ | ✓ | ✓ | ✓ |
| 152 | Nguyên liệu, vật liệu | Dư Nợ | ✓ | ✓ | ✓ |
| 153 | Công cụ, dụng cụ (TT200: 1531–1534) | Dư Nợ | ✓ | ✓ | ✓ |
| 154 | Chi phí SXKD dở dang | Dư Nợ | ✓ | ✓ (tập hợp **toàn bộ** chi phí SX) | ✓ |
| 155 | Thành phẩm (TT200: 1551, 1557 BĐS) | Dư Nợ | ✓ | ✓ | ✓ đổi tên **"Sản phẩm"** |
| 156 | Hàng hóa (TT200: 1561 giá mua, 1562 chi phí mua, 1567 BĐS) | Dư Nợ | ✓ | ✓ | ✓ (1562 bỏ — [CXM] cấu trúc cấp 2) |
| 157 | Hàng gửi đi bán | Dư Nợ | ✓ | ✓ | ✓ |
| 158 | Hàng hóa kho bảo thuế | Dư Nợ | ✓ | — | ✓ |
| 2294 | Dự phòng giảm giá HTK | Dư Có (TK điều chỉnh giảm) | ✓ | ✓ (TT133: 2294) | ✓ |
| 331 | Phải trả người bán | Lưỡng tính | ✓ | ✓ | ✓ |
| 3331 | Thuế GTGT phải nộp (33311 đầu ra, 33312 hàng NK) | Dư Có | ✓ | ✓ | ✓ |
| 3332/3333 | Thuế TTĐB / Thuế XNK | Dư Có | ✓ | ✓ | ✓ |
| 511 | Doanh thu bán hàng & CCDV (5111 HH, 5112 SP, 5113 DV…) | Không số dư | ✓ | ✓ | ✓ |
| 521 | Giảm trừ DT (5211 CKTM, 5212 hàng bán trả lại, 5213 giảm giá) | Không số dư | ✓ (*lưu ý số hiệu cấp 2 ở dưới*) | **— (ghi Nợ 511 trực tiếp)** | ✓ |
| 611 | Mua hàng (KKĐK) | | ✓ | ✓ | **bỏ** |
| 621 | Chi phí NVL trực tiếp | Không số dư | ✓ | **—** (dùng 154) | ✓ |
| 622 | Chi phí nhân công trực tiếp | Không số dư | ✓ | **—** | ✓ |
| 623 | Chi phí sử dụng máy thi công | Không số dư | ✓ | **—** | ✓ |
| 627 | Chi phí SX chung (6271 NV PX, 6272 VL, 6273 DCSX, 6274 KH TSCĐ, 6277 DV mua ngoài, 6278 khác) | Không số dư | ✓ | **—** | ✓ (+6275 [CXM]) |
| 631 | Giá thành SX (KKĐK) | | ✓ | — | **bỏ** |
| 632 | Giá vốn hàng bán | Không số dư | ✓ | ✓ | ✓ |
| 641 / 642 | Chi phí bán hàng / QLDN | Không số dư | ✓ | **chỉ 642** (6421 bán hàng, 6422 QLDN) | ✓ |
| 711/811 | Thu nhập / chi phí khác | | ✓ | ✓ | ✓ |
| 821 | Chi phí thuế TNDN | | ✓ | ✓ | ✓ (+82112) |
| 911 | Xác định kết quả KD | Không số dư | ✓ | ✓ | ✓ |
| 421 | Lợi nhuận sau thuế chưa phân phối (4211 năm trước, 4212 năm nay) | Lưỡng tính | ✓ | ✓ | ✓ |

**Lưu ý số hiệu 521 [KT]:** TT200: 5211 Chiết khấu thương mại, **5212 Hàng bán bị trả lại, 5213 Giảm giá hàng bán**. (Một số tài liệu ghi ngược 5212/5213 — phần mềm phải dùng mapping cấu hình, không hard-code.)

**Khác biệt cần cài đặt theo chế độ:**
- TT133: luồng giá thành `152 → 154 → 155`, không qua 621/622/627; muốn phân tích khoản mục thì dùng **mã khoản mục chi phí** (dimension) trên dòng hạch toán 154. Khuyến nghị: **mọi chế độ đều lưu dimension "khoản mục CP" (NVLTT/NCTT/MTC/SXC)** để thuật toán giá thành dùng chung.
- TT133: giảm trừ doanh thu ghi Nợ 511 (có thể chi tiết bằng dimension).
- TT99: bỏ 611/631 → chỉ KKTX qua TK HTK.

---

## 3. Tính giá xuất kho

### 3.1 Nguyên tắc (VAS 02) [KT]
- HTK ghi theo **giá gốc** = giá mua + thuế không hoàn lại (NK, TTĐB, BVMT, GTGT nếu không được khấu trừ) + chi phí vận chuyển, bốc xếp, bảo quản trong quá trình mua + hao hụt trong định mức − chiết khấu TM, giảm giá hàng mua.
- Giá gốc SP tự SX = chi phí NVL TT + NCTT + SXC (SXC cố định phân bổ theo **công suất bình thường**; phần dưới công suất → 632). Chi phí NVL/NC/SXC **vượt mức bình thường**, chi phí bảo quản sau mua, chi phí bán hàng/QLDN **không** tính vào giá gốc.
- Cuối kỳ: giá trị ghi sổ = min(giá gốc, **NRV**); chênh lệch → dự phòng 2294.
- Phương pháp: đích danh, bình quân gia quyền (cuối kỳ hoặc sau mỗi lần nhập), FIFO. (VAS 02 gốc có LIFO nhưng **TT200 đã bỏ LIFO**; TT133/TT99 không cho LIFO — [KT]/[CXM] với TT99.) Áp dụng **nhất quán** trong niên độ; thay đổi phải thuyết minh.

### 3.2 Ví dụ số dùng chung — Vật tư A, kho K1, tháng 01

| Ngày | Nghiệp vụ | SL | Đơn giá | Giá trị |
|---|---|---|---|---|
| 01/01 | Tồn đầu | 100 | 10.000 | 1.000.000 |
| 05/01 | Nhập mua | 200 | 11.000 | 2.200.000 |
| 10/01 | Xuất SX | 250 | ? | ? |
| 20/01 | Nhập mua | 100 | 12.000 | 1.200.000 |
| 25/01 | Xuất SX | 100 | ? | ? |

### 3.3 Bình quân gia quyền cuối kỳ (MISA: "Bình quân cuối kỳ")
```
ĐG_bq = (GT tồn đầu + GT nhập trong kỳ) / (SL tồn đầu + SL nhập trong kỳ)
```
= (1.000.000 + 2.200.000 + 1.200.000) / (100 + 200 + 100) = 4.400.000 / 400 = **11.000**
- Xuất 10/01: 250 × 11.000 = 2.750.000; Xuất 25/01: 100 × 11.000 = 1.100.000 → tổng xuất **3.850.000**
- Tồn cuối: 50 kg, **550.000**.

Quy tắc cài đặt:
- "Nhập trong kỳ" gồm mọi chứng từ nhập có giá xác định trước (mua, nhập khẩu, thành phẩm SX sau khi tính giá thành, điều chỉnh tăng giá trị). **Nhập do hàng bán trả lại** và **nhập chuyển kho** thường lấy giá theo giá xuất → có 2 lựa chọn: (a) loại khỏi mẫu số và gán giá = ĐG_bq (MISA mặc định với hàng trả lại không có giá); (b) cho phép người dùng nhập giá cụ thể → tham gia bình quân. Phải cấu hình rõ.
- Tính theo kho hay toàn DN (tùy chọn, MISA: "tính giá theo kho / không theo kho"; đa chi nhánh: theo từng chi nhánh hoặc chung) [XM].
- **Chênh lệch làm tròn**: dòng xuất cuối cùng trong kỳ (hoặc khi tồn SL = 0) nhận phần chênh lệch để `GT tồn cuối = GT đầu + GT nhập − GT xuất` chính xác; khi SL tồn = 0 thì GT tồn **phải** = 0.
- Chuyển kho khi tính theo kho: chuyển kho ra lấy ĐG_bq kho xuất; kho nhận coi là "nhập có giá" → phải tính **theo thứ tự phụ thuộc giữa các kho** (lặp đến khi hội tụ, hoặc giải hệ phương trình tuyến tính khi có vòng chuyển kho A↔B trong cùng kỳ).

### 3.4 Bình quân tức thời (di động / sau mỗi lần nhập)
```
Sau mỗi lần nhập: ĐG_mới = (GT tồn hiện tại + GT nhập) / (SL tồn hiện tại + SL nhập)
Xuất: GT xuất = SL xuất × ĐG hiện tại (xuất làm SL tồn về 0 ⇒ GT xuất = toàn bộ GT tồn)
```
| Ngày | SL tồn | GT tồn | ĐG | GT xuất |
|---|---|---|---|---|
| 05/01 sau nhập | 300 | 3.200.000 | 10.666,67 | |
| 10/01 xuất 250 | 50 | 533.333 | 10.666,67 | 2.666.667 |
| 20/01 sau nhập | 150 | 1.733.333 | 11.555,5533 | |
| 25/01 xuất 100 | 50 | 577.778 | 11.555,5533 | 1.155.555 |
Tổng xuất **3.822.222**, tồn **577.778** (kiểm tra: 4.400.000 − 3.822.222 = 577.778 ✓).

Cài đặt: lưu giá trị bằng số nguyên VND (hoặc decimal 4 chữ số cho đơn giá), làm tròn GT xuất từng dòng; GT tồn = phần dư (không tính lại SL × ĐG). **Sửa/chèn chứng từ có ngày trước** chứng từ đã tính → phải tính lại toàn bộ chuỗi từ ngày đó (MISA: cần chạy lại "Tính giá xuất kho") [XM].

### 3.5 Nhập trước – xuất trước (FIFO)
Mỗi lần nhập tạo một **lô giá (cost layer)**; xuất tiêu thụ lô cũ nhất.
- 10/01 xuất 250: 100 × 10.000 + 150 × 11.000 = **2.650.000**; còn lô (50 × 11.000)
- 20/01 nhập lô (100 × 12.000)
- 25/01 xuất 100: 50 × 11.000 + 50 × 12.000 = **1.150.000**; còn lô (50 × 12.000)
Tổng xuất **3.800.000**, tồn **600.000** ✓.

Cài đặt: bảng `cost_layer(item, warehouse, source_doc, date, qty_in, qty_remaining, unit_cost)` + bảng `layer_consumption(issue_line, layer, qty, amount)`. Một dòng xuất có thể sinh nhiều consumption → đơn giá hiển thị trên phiếu xuất = tổng tiền / SL.

### 3.6 Thực tế đích danh
Xuất chỉ định lô/số serial cụ thể (VD xuất 25/01: 100 kg thuộc phiếu nhập 20/01 → 1.200.000). Yêu cầu: dòng xuất **bắt buộc** tham chiếu dòng nhập (lô); kiểm tra SL lô còn đủ. Phù hợp hàng giá trị lớn, ít mặt hàng (ô tô, máy móc, BĐS).

### 3.7 So sánh kết quả ví dụ

| Phương pháp | GT xuất | GT tồn 50 kg |
|---|---|---|
| BQ cuối kỳ | 3.850.000 | 550.000 |
| BQ tức thời | 3.822.222 | 577.778 |
| FIFO | 3.800.000 | 600.000 |

### 3.8 Edge case & quy tắc xử lý

| Tình huống | Vấn đề | Quy tắc đề xuất |
|---|---|---|
| **Tồn âm** (xuất khi SL tồn < SL xuất tại thời điểm xuất) | BQ tức thời/FIFO không có giá; BQ cuối kỳ có thể ra ĐG âm/vô nghĩa (MISA: nguyên nhân phổ biến khiến không lên giá [XM]) | Tùy chọn hệ thống "Cho phép xuất quá tồn" (mặc định **tắt**). Nếu bật: dòng xuất phần âm được gán giá tạm (ĐG gần nhất / ĐG bq), đánh dấu `provisional`; khi có nhập bù → tính lại. Báo cáo "VTHH tồn âm" bắt buộc trước khóa sổ; **không cho khóa kỳ nếu còn tồn âm** (tại cuối kỳ hoặc—tùy cấu hình—tại bất kỳ thời điểm nào). |
| **Xuất trước nhập sau trong kỳ** (chứng từ nhập ghi ngày sau nhưng thực tế hàng đã về) | Với BQ cuối kỳ: không ảnh hưởng (chỉ cần cuối kỳ SL ≥ 0). Với BQ tức thời/FIFO: tồn âm tạm thời | Như trên; cảnh báo khi ghi sổ. Thứ tự xử lý trong cùng ngày: **nhập trước, xuất sau** (sắp xếp theo ngày hạch toán, rồi loại chứng từ nhập < xuất, rồi số thứ tự ghi sổ). |
| **Hàng bán trả lại** | Nhập lại kho với giá nào? | Mặc định = giá vốn của dòng bán gốc (tham chiếu chứng từ bán → lấy GT xuất của dòng đó theo tỷ lệ SL). Nếu không tham chiếu: lấy ĐG bq kỳ (BQ) / ĐG tại ngày trả (tức thời) / lô gốc (FIFO). Bút toán Nợ 156/155 – Có 632. |
| **Hàng mua trả lại người bán** | Xuất kho trả NCC | Giá = giá của phiếu nhập gốc (đích danh theo chứng từ nhập), không lấy ĐG bq. Ghi Nợ 331 – Có 152/156, Có 1331. |
| **Điều chỉnh giá nhập sau** (giảm giá/CKTM hàng mua nhận sau, HĐ điều chỉnh, chi phí mua về sau) | Hàng có thể đã xuất một phần | Chứng từ "điều chỉnh giá trị nhập" (SL = 0, GT ≠ 0) gắn với phiếu nhập gốc. BQ cuối kỳ: cộng vào GT nhập kỳ → tự phân bổ khi tính lại. BQ tức thời/FIFO: cộng vào lô/ĐG tại ngày điều chỉnh. Nếu điều chỉnh sau khi đã khóa kỳ của phiếu nhập: phân bổ thủ công theo tỷ lệ: phần còn tồn → 152/156, phần đã bán → 632, phần đã đưa vào SX dở → 154 (VD: giảm giá 1.000.000 cho lô 200 kg, đã xuất 150 kg → Có 152: 250.000; Có 632/154: 750.000). |
| **Chi phí mua hàng phân bổ** (vận chuyển, bốc xếp, bảo hiểm, thuế NK) | 1 HĐ chi phí cho nhiều mặt hàng | Chức năng "phân bổ chi phí mua hàng" theo tiêu thức: **giá trị**, **số lượng**, **trọng lượng/thể tích** hoặc nhập tay; phần dư làm tròn dồn vào dòng cuối. VD: phí VC 600.000 cho A (giá trị 2.200.000) và B (giá trị 1.100.000), theo giá trị → A 400.000, B 200.000. Kết quả cộng vào GT nhập từng dòng. Nếu HĐ chi phí về sau → coi là "điều chỉnh giá nhập sau". |
| **Đánh giá lại HTK** | Góp vốn bằng HTK, chuyển đổi DN, kiểm kê đánh giá theo quyết định | Chứng từ "điều chỉnh giá trị kho" (SL = 0). Tăng: Nợ 152/156 – Có 711 (hoặc TK theo quyết định); giảm: Nợ 811 – Có 152/156. Góp vốn ra ngoài: Nợ 221/222 (giá đánh giá), Nợ 811 / Có 711 chênh lệch, Có 152/156 (giá ghi sổ) [KT]. |
| **Đơn vị tính quy đổi** | Nhập thùng, xuất chai | Mọi tính toán theo **ĐVT chính**; lưu tỷ lệ quy đổi trên dòng chứng từ tại thời điểm lập; sai tỷ lệ là nguyên nhân sai giá phổ biến (MISA) [XM]. |
| **Thành phẩm chưa có giá** | Phiếu nhập TP từ SX chỉ có SL tới khi tính giá thành | Tính giá thành xong mới cập nhật GT phiếu nhập TP → sau đó mới tính giá xuất TP. Xem mục 6 (thứ tự). |
| **SX nhiều cấp** (BTP tự SX dùng làm NVL cho SP khác) | Vòng phụ thuộc tính giá xuất ↔ giá thành | Tính theo **cấp BOM từ thấp đến cao**: giá xuất NVL mua → giá thành BTP → giá xuất BTP → giá thành TP… |
| **Kỳ tính giá** | Tháng/quý/năm | BQ cuối kỳ: kỳ tính phải ⊆ kỳ kế toán; thường tháng. Số dư cuối kỳ trước là tồn đầu kỳ sau. |

### 3.9 Cách MISA SME xử lý (tham chiếu hành vi) [XM]
- Chọn phương pháp tính giá trong **Tùy chọn hệ thống** (1 phương pháp cho toàn DB; một số bản cho phép theo từng VTHH — [CXM]).
- Phiếu xuất khi lập **chưa cần đơn giá** (BQ cuối kỳ) hoặc được điền tạm (tức thời/FIFO).
- Chức năng **Nghiệp vụ › Kho › Tính giá xuất kho**: chọn khoảng thời gian, phạm vi VTHH, theo kho/không theo kho, theo chi nhánh → chương trình **ghi đè đơn giá & thành tiền vốn** vào các chứng từ xuất kho (xuất bán, xuất SX, chuyển kho, xuất trả…) và **các bút toán giá vốn** liên quan (Nợ 632/621/154… Có 152/155/156).
- BQ tức thời/FIFO/đích danh: tự cập nhật khi ghi sổ, nhưng khi sửa/chèn chứng từ có ngày trước → phải chạy lại tính giá.
- Lỗi thường gặp: tồn âm, ĐVT quy đổi sai, chứng từ nhập thiếu đơn giá, nhập TP thay đổi do tính giá thành (phải tính lại) → xử lý: kiểm tra Sổ chi tiết VTHH, sửa chứng từ gốc, chạy lại từ ngày bắt đầu dữ liệu.

Nguồn: [MISA Help – Tính giá xuất kho](https://helpsme.misa.vn/2022/kb/html_17060000/), [MISA Help – không lên đơn giá vốn](https://helpsme.misa.vn/2023/kb/lam-the-nao-khi-tinh-gia-xuat-kho-khong-len-don-gia-von/), [MISA AMIS – bình quân theo chi nhánh](https://amis.misa.vn/144043/tinh-gia-xuat-kho-binh-quan-cuoi-ky-theo-tung-chi-nhanh/).

**Thuật toán đề xuất (BQ cuối kỳ, theo kho, có chuyển kho):**
```
for level in BOM_levels ascending:          # mục 3.8
  items = items_at_level(level)
  repeat until không còn thay đổi (tối đa N vòng) / hoặc giải hệ tuyến tính:
    for (item, wh) in items × warehouses:
      Q = opening_qty + Σ qty_in_priced ; V = opening_val + Σ val_in_priced
           (+ nhập chuyển kho từ kho khác với giá của kho nguồn ở vòng trước)
      if Q <= 0: lỗi "tồn âm/không có giá" -> dừng & báo cáo
      p = V / Q
      for each issue line (ordered): amount = round(qty * p); dồn chênh lệch vào dòng cuối
      cập nhật giá cho dòng nhận tương ứng ở kho đích
  ghi đè amount vào dòng chứng từ xuất + sinh lại bút toán GL (trong transaction)
```

---

## 4. Tính giá thành sản phẩm

### 4.1 Khái niệm
| Khái niệm | Định nghĩa | Ví dụ | Đối tượng dữ liệu |
|---|---|---|---|
| **Đối tượng tập hợp chi phí** | Phạm vi gom chi phí (nơi phát sinh) | Phân xưởng, quy trình công nghệ, giai đoạn, đơn hàng, công trình, nhóm SP | `cost_center` / `cost_object` gắn trên dòng hạch toán 621/622/627/154 |
| **Đối tượng tính giá thành** | Sản phẩm/BTP/đơn hàng cần xác định Z và z | SP X, BTP giai đoạn 1, ĐĐH-01 | `product` / `order` |
| **Kỳ tính giá thành** | Tháng/quý/năm, hoặc khi đơn hàng/công trình hoàn thành | | `costing_period` |
| Quan hệ | 1–1 (giản đơn), 1–n (hệ số, tỷ lệ), n–1 (phân bước) | | `costing_rule` |

**Công thức tổng quát:**
```
Z (tổng giá thành) = DDĐK + C (chi phí phát sinh trong kỳ) − DDCK − Khoản giảm giá thành (phế liệu thu hồi, SP hỏng ngoài định mức bắt bồi thường…)
z (giá thành đơn vị) = Z / Số lượng SP hoàn thành
```
Tính **theo từng khoản mục** (NVLTT / NCTT / MTC / SXC) để lập Thẻ tính giá thành.

### 4.2 Tập hợp chi phí
| Khoản mục | Nguồn | Bút toán | Phân bổ |
|---|---|---|---|
| NVL trực tiếp (621) | Phiếu xuất kho cho SX (giá từ mục 3) | Nợ 621 (chi tiết đối tượng) / Có 152 | Trực tiếp nếu xuất cho đối tượng cụ thể; nếu dùng chung → theo định mức NVL hoặc SL SP |
| NC trực tiếp (622) | Bảng lương công nhân SX, BHXH/BHYT/BHTN/KPCĐ phần DN | Nợ 622 / Có 334, 338 | Trực tiếp hoặc theo giờ công, tiền lương định mức |
| SX chung (627) | Lương QL PX, VL/CCDC dùng chung, khấu hao, điện nước, DV mua ngoài | Nợ 627x / Có 334, 338, 152, 153, 242, 214, 331, 111… | **Phân bổ cuối kỳ** theo tiêu thức: chi phí NVLTT, chi phí NCTT, giờ máy, giờ công, SL SP, định mức, doanh thu (ít dùng) |
| NVL thừa trả lại kho | | Nợ 152 / Có 621 | |
| Phế liệu thu hồi | | Nợ 152 / Có 154 (giảm Z) | |

**Ví dụ phân bổ 627** theo chi phí NCTT: 627 = 20.000.000; 622 của ĐH1 = 18.000.000, ĐH2 = 12.000.000.
Hệ số = 20.000.000 / 30.000.000 = 2/3 → ĐH1 = 18.000.000 × 2/3 = 12.000.000, ĐH2 = **8.000.000** (dòng cuối nhận phần dư). _(Đã sửa theo phản biện 06a-L1.)_

**SXC cố định dưới công suất bình thường (VAS 02):** 627 cố định 10.000.000, công suất bình thường 1.000 SP, thực tế 800 SP → phân bổ vào Z: 10.000.000 × 800/1.000 = 8.000.000; **2.000.000 → Nợ 632** (không tính vào giá thành). SXC biến đổi phân bổ hết theo thực tế. → Dữ liệu cần: cờ "cố định/biến đổi" trên TK 627 chi tiết hoặc dòng chi phí, công suất bình thường theo đối tượng.

**Kết chuyển** (TT200/TT99): Nợ 154 (chi tiết đối tượng, khoản mục) / Có 621, 622, 623, 627. TT133: chi phí đã ghi thẳng Nợ 154 nên không có bước này (nhưng vẫn phân bổ chi phí chung giữa các đối tượng trong 154).

### 4.3 Đánh giá sản phẩm dở dang cuối kỳ (DDCK)

Ví dụ: Phân xưởng SX sản phẩm X. Trong kỳ: 621 = 90.000.000; 622 = 30.000.000; 627 = 20.000.000. Hoàn thành 900 SP; DDCK 100 SP, mức độ hoàn thành 50%. NVL bỏ **một lần từ đầu** quy trình.

**(a) Theo chi phí NVL trực tiếp (hoặc NVL chính)** — DDCK chỉ gồm NVLTT, NC & SXC tính hết cho TP. Giả sử DDĐK = 10.000.000 (toàn NVLTT).
```
DDCK = (DDĐK + C_NVLTT) / (SL_HT + SL_DD) × SL_DD = (10tr + 90tr)/(900+100) × 100 = 10.000.000
Z = 10tr + (90 + 30 + 20)tr − 10tr = 140.000.000 ; z = 155.555,56
```

**(b) Theo sản lượng hoàn thành tương đương** — DDĐK: NVLTT 10.000.000; NCTT 1.350.000; SXC 900.000 (tổng 12.250.000).
- NVL bỏ từ đầu: DD tính 100% SL. NC, SXC tính theo SL tương đương = 100 × 50% = 50.

| Khoản mục | DDĐK | PS kỳ | SL quy đổi | ĐG | DDCK | Z | z |
|---|---|---|---|---|---|---|---|
| NVLTT | 10.000.000 | 90.000.000 | 900 + 100 = 1.000 | 100.000 | 10.000.000 | 90.000.000 | 100.000 |
| NCTT | 1.350.000 | 30.000.000 | 900 + 50 = 950 | 33.000 | 1.650.000 | 29.700.000 | 33.000 |
| SXC | 900.000 | 20.000.000 | 950 | 22.000 | 1.100.000 | 19.800.000 | 22.000 |
| **Cộng** | 12.250.000 | 140.000.000 | | | **12.750.000** | **139.500.000** | **155.000** |

Biến thể: nếu NVL bỏ dần theo tiến độ → NVL cũng dùng SL tương đương. Biến thể FIFO cho SL tương đương (tách phần hoàn thành tiếp DDĐK) — tùy chọn nâng cao, ít dùng ở VN.

**(c) Theo chi phí định mức (kế hoạch)**:
```
DDCK = Σ_khoản mục SL_DD × định mức chi phí đơn vị × % hoàn thành (khoản mục chế biến)
```
VD định mức NVL 95.000/SP, NC 30.000, SXC 20.000: DDCK = 100 × 95.000 + 100 × 50% × (30.000 + 20.000) = 9.500.000 + 2.500.000 = 12.000.000.

Cấu hình: phương pháp đánh giá DD **theo đối tượng tập hợp chi phí**; người dùng nhập SL DD & % hoàn thành cuối kỳ (hoặc lấy từ kiểm kê DD). Nếu không có DD → DDCK = 0.

### 4.4 Các phương pháp tính giá thành

**(1) Giản đơn (trực tiếp)** — 1 đối tượng tập hợp = 1 SP, quy trình đơn giản, SL lớn. Dùng công thức tổng quát (ví dụ 4.3).

**(2) Hệ số** — 1 quy trình cho ra nhiều SP (liên sản phẩm) có hệ số quy đổi.
VD: Z liên sản phẩm (đã trừ DD) = 116.000.000. Hoàn thành A 500 (hệ số 1,0), B 300 (1,2), C 200 (1,5).
```
SL chuẩn = 500×1 + 300×1,2 + 200×1,5 = 1.160 ; z chuẩn = 116tr/1.160 = 100.000
z_A = 100.000 ; z_B = 120.000 ; z_C = 150.000
Z_A = 50.000.000 ; Z_B = 36.000.000 ; Z_C = 30.000.000 (Σ = 116tr ✓)
```
DD cũng có thể quy đổi theo hệ số trước khi tính.

**(3) Tỷ lệ** — nhóm SP cùng quy trình, khác quy cách; phân bổ theo giá thành kế hoạch/định mức.
VD: Z thực tế nhóm = 105.000.000; KH: M 1.000 SP × 50.000 = 50tr; N 500 SP × 100.000 = 50tr (tổng 100tr).
```
Tỷ lệ = 105tr / 100tr = 105%  → z_M = 52.500 ; z_N = 105.000 ; Z_M = Z_N = 52.500.000
```
(Tính tỷ lệ riêng cho từng khoản mục để lập thẻ giá thành theo khoản mục.)

**(4) Định mức** — `Z_tt = Z_định mức ± chênh lệch do thay đổi định mức ± chênh lệch thoát ly định mức`. Yêu cầu bảng định mức (BOM + định mức NC/SXC) có hiệu lực theo thời gian; phần mềm lưu 3 thành phần để phân tích.

**(5) Phân bước có tính giá thành BTP (kết chuyển tuần tự)**
VD 2 giai đoạn, không DD:
- GĐ1: 621 = 50tr, 622 = 10tr, 627 = 8tr → 1.000 BTP: Z_BTP = 68.000.000 (z = 68.000). Nợ 154-GĐ2 (hoặc 155-BTP nếu nhập kho) / Có 154-GĐ1.
- GĐ2: BTP chuyển sang 68tr + 622 = 12tr + 627 = 10tr → 1.000 TP: Z = 90.000.000, z = 90.000.
- Kết chuyển **theo khoản mục** (để thẻ TP thể hiện đúng): NVLTT 50tr, NCTT 22tr, SXC 18tr. (Kết chuyển tổng hợp thì BTP thành 1 khoản mục "BTP GĐ trước".)
- Nếu BTP nhập kho rồi xuất cho GĐ sau → BTP đi qua tính giá xuất kho (mục 3.8 "SX nhiều cấp").

**(6) Phân bước không tính BTP (kết chuyển song song)**
```
Chi phí GĐ i nằm trong TP = (DDĐK_i + C_i) / (SL_TP + SL DD tại GĐ i (quy đổi theo % HT ở GĐ i) + SL DD ở các GĐ sau i) × SL_TP
Z_TP = Σ_i chi phí GĐ i nằm trong TP
```
(NVL bỏ từ đầu ở GĐ1: DD ở mọi GĐ đều tính 100% NVL.) Ví dụ trên không DD ⇒ cùng kết quả 90tr.

**(7) Theo đơn đặt hàng** — đối tượng tập hợp & tính giá thành = đơn hàng; kỳ tính giá = khi ĐH hoàn thành. Cuối mỗi tháng: chi phí ĐH chưa xong = DD (không tính Z). 627 phân bổ hằng tháng (ví dụ mục 4.2). Khi ĐH hoàn thành: Z = Σ chi phí lũy kế; z = Z / SL của ĐH.

**(8) Theo công trình / hợp đồng (xây lắp)** — đối tượng = công trình/hạng mục; có thêm 623 (máy thi công). DD xác định theo: chi phí thực tế lũy kế của khối lượng chưa nghiệm thu, hoặc theo dự toán × tỷ lệ hoàn thành. Giá vốn ghi nhận theo khối lượng được nghiệm thu/ghi nhận doanh thu. (Chi tiết VAS 15 ngoài phạm vi MVP.)

Nhập kho TP: Nợ 155 / Có 154; bán thẳng không qua kho: Nợ 632 / Có 154; gửi bán: Nợ 157 / Có 154.

### 4.5 Dữ liệu tối thiểu cho module giá thành
`costing_period`, `cost_object` (loại: SP / nhóm SP / PX / ĐH / CT), `costing_method`, `wip_method`, `bom(version, valid_from)`, `standard_cost`, `allocation_rule(627 → tiêu thức)`, `coefficient`/`plan_cost` (hệ số, tỷ lệ), `wip_count(qty, % hoàn thành theo khoản mục)`, `costing_result(object, product, khoản mục, DDĐK, PS, DDCK, Z, z)`.

---

## 5. Định khoản các nghiệp vụ (KKTX; TT200/TT99; ghi chú TT133)

Giả định: DN nộp GTGT theo phương pháp khấu trừ. Ký hiệu: GTGT = thuế GTGT; mọi bút toán phải sinh từ **chứng từ nghiệp vụ** (không nhập bút toán tự do cho kho).

### 5.1 Mua hàng
| Nghiệp vụ | Nợ | Có | Ghi chú |
|---|---|---|---|
| Mua NVL/HH trong nước, nhập kho | 152/153/156 (giá chưa thuế); 1331 | 331/111/112/141 | VD: 10.000.000 + GTGT 10% → Nợ 152: 10tr; Nợ 1331: 1tr; Có 331: 11tr |
| Hàng mua đang đi đường (đã có HĐ, chưa về) | 151; 1331 | 331 | Khi về: Nợ 152/156 / Có 151 |
| Hàng về chưa có HĐ | 152/156 (giá tạm tính) | 331 | Khi có HĐ: điều chỉnh chênh lệch + Nợ 1331 |
| Chi phí mua (VC, bốc xếp) | 152/156 (phân bổ — TT200 có thể dùng 1562); 1331 | 331/111 | TT99: 1562 bỏ → vào 156 trực tiếp [CXM] |
| Chiết khấu TM / giảm giá hàng mua | 331/111 | 152/156 (phần còn tồn), 632 (đã bán), 154/621 (đã đưa SX); 1331 | Xem 3.8 |
| Trả lại hàng mua | 331 | 152/156 (giá nhập gốc); 1331 | |
| Chiết khấu thanh toán được hưởng | 331 | 515 | Không giảm giá nhập |
| **Nhập khẩu** – giá mua | 152/156 (giá CIF × tỷ giá giao dịch thực tế) | 331 (ngoại tệ) | Đánh giá chênh lệch tỷ giá khi thanh toán: 515/635 |
| – Thuế NK | 152/156 | 3333 | |
| – Thuế TTĐB hàng NK | 152/156 (nếu không được khấu trừ) **hoặc 1383 (TT99, nếu được khấu trừ)** | 3332 | 1383 mới ở TT99 [XM tên TK] |
| – Thuế BVMT hàng NK | 152/156 | 33381 | |
| – GTGT hàng NK (được khấu trừ) | 1331 | 33312 | Không khấu trừ → Nợ 152/156 |
| – Nộp thuế | 3333, 3332, 33312… | 111/112 | |

### 5.2 Kho
| Nghiệp vụ | Nợ | Có | Ghi chú |
|---|---|---|---|
| Xuất NVL cho SX | 621 (TT133: 154) | 152 | Giá từ tính giá xuất kho |
| Xuất dùng chung PX / bán hàng / QLDN | 627 / 641 / 642 (TT133: 154 / 6421 / 6422) | 152/153 | |
| Xuất CCDC phân bổ nhiều kỳ | 242 | 153 | Phân bổ: Nợ 627/641/642 / Có 242 |
| Chuyển kho nội bộ (cùng pháp nhân, cùng TK) | 152 (kho nhận) | 152 (kho xuất) | Không ảnh hưởng sổ cái tổng hợp; chỉ chi tiết kho. Chứng từ: Phiếu xuất kho kiêm vận chuyển nội bộ |
| Chuyển cho chi nhánh hạch toán phụ thuộc có kế toán riêng | 1368 / (hoặc 157 nếu coi là gửi bán) | 156 | Đơn vị nhận: Nợ 156 / Có 3368 [KT] |
| Nhập TP từ SX | 155 | 154 | GT cập nhật sau tính giá thành |
| Xuất gửi bán / đại lý | 157 | 155/156 | Khi bán: Nợ 632 / Có 157 |
| Kiểm kê **thiếu** chưa rõ nguyên nhân | 1381 | 152/155/156 | Xử lý: bắt bồi thường Nợ 1388/334; hao hụt trong định mức/ tính vào giá vốn Nợ 632 / Có 1381 |
| Kiểm kê thiếu trong định mức | 632 | 152/156 | |
| Kiểm kê **thừa** chưa rõ nguyên nhân | 152/155/156 | 3381 | Xử lý: Nợ 3381 / Có 711 (hoặc 331 nếu của người bán giao thừa) |
| Lập dự phòng giảm giá HTK (bổ sung) | 632 | 2294 | Số phải lập kỳ này − số dư hiện có (nếu > 0) |
| Hoàn nhập dự phòng | 2294 | 632 | Nếu số phải lập < số dư |
| Xử lý HTK hư hỏng đã lập DP | 2294 (phần đã lập), 632 (phần thiếu) | 152/155/156 | |

**Ví dụ dự phòng:** HH B tồn 100 cái, giá gốc 500.000, NRV = giá bán ước tính 480.000 − CP bán ước tính 30.000 = 450.000 → DP cần lập = 100 × 50.000 = 5.000.000. Số dư 2294 đầu kỳ cho B = 2.000.000 → lập bổ sung Nợ 632 / Có 2294: 3.000.000. Lập **theo từng mặt hàng**, không bù trừ giữa các mặt hàng.

### 5.3 Bán hàng
| Nghiệp vụ | Nợ | Có | Ghi chú |
|---|---|---|---|
| Doanh thu | 131/111/112 | 5111 (HH)/5112 (SP)/5113 (DV); 33311 | Ghi nhận khi chuyển giao rủi ro/lợi ích; ngày HĐ theo NĐ70 = thời điểm chuyển quyền sở hữu |
| Giá vốn (đồng thời) | 632 | 155/156 (hoặc 157, 154) | Giá vốn cập nhật lại sau "tính giá xuất kho" |
| Chiết khấu thương mại (sau khi đã xuất HĐ) | 5211 (TT133: 511); 33311 | 131 | Lập HĐ điều chỉnh giảm. CKTM ghi ngay trên HĐ → ghi DT thuần, không qua 521 |
| Giảm giá hàng bán | 5213* (TT133: 511); 33311 | 131 | *xem lưu ý số hiệu 521 mục 2 |
| Hàng bán bị trả lại – DT | 5212* (TT133: 511); 33311 | 131/111 | HĐ điều chỉnh / HĐ của người mua (theo NĐ123/70 — [CXM] thủ tục cụ thể) |
| – Nhập lại kho | 155/156 | 632 | Giá vốn của lần bán gốc |
| Chiết khấu thanh toán cho KH | 635 | 131 | |
| Kết chuyển giảm trừ cuối kỳ | 511 | 521 | |

**Ví dụ:** Bán 50 kg A giá 15.000/kg, GTGT 10%: Nợ 131: 825.000 / Có 5111: 750.000 / Có 33311: 75.000. Giá vốn (BQ cuối kỳ 11.000): Nợ 632: 550.000 / Có 156: 550.000. KH trả lại 10 kg: Nợ 5212: 150.000; Nợ 33311: 15.000 / Có 131: 165.000; Nợ 156: 110.000 / Có 632: 110.000.

### 5.4 Kết chuyển cuối kỳ & xác định kết quả (911)
| Bước | Nợ | Có |
|---|---|---|
| 1. Kết chuyển giảm trừ DT | 511 | 521 |
| 2. Kết chuyển DT thuần | 511 | 911 |
| 3. Kết chuyển DT tài chính, TN khác | 515, 711 | 911 |
| 4. Kết chuyển giá vốn | 911 | 632 |
| 5. Kết chuyển CP tài chính, bán hàng, QLDN, khác | 911 | 635, 641, 642, 811 |
| 6. Tính thuế TNDN tạm tính/quyết toán | 8211 | 3334 |
| 7. Kết chuyển CP thuế TNDN | 911 | 8211 (± 8212) |
| 8. Kết chuyển lãi / lỗ | 911 / 4212 | 4212 / 911 |

Sau bước 8: mọi TK loại 5–9 **số dư = 0**. (632 có thể dư Nợ trong kỳ do điều chỉnh, nhưng phải về 0 sau kết chuyển.) Đầu năm mới: kết chuyển 4212 → 4211 (Nợ 4212 / Có 4211 hoặc ngược lại).

Ví dụ: DT 5111 = 1.000tr; 5212 = 20tr; 632 = 700tr; 641 = 50tr; 642 = 80tr; 515 = 5tr; 635 = 15tr; thuế TNDN 20% → DT thuần 980tr; LN trước thuế = 980 − 700 − 50 − 80 + 5 − 15 = 140tr; thuế = 28tr; LNST = 112tr (Nợ 911 / Có 4212: 112tr).

---

## 6. Quy trình khóa sổ cuối kỳ

Thứ tự bắt buộc (mũi tên = phụ thuộc dữ liệu):

| # | Bước | Điều kiện trước | Kết quả | Ghi chú |
|---|---|---|---|---|
| 0 | Hoàn tất & ghi sổ toàn bộ chứng từ kỳ; đối chiếu HĐ đầu vào/ra, ngân hàng, công nợ | — | | Không còn chứng từ nháp trong kỳ |
| 1 | Đánh giá chênh lệch tỷ giá cuối kỳ (khoản mục tiền tệ có gốc ngoại tệ) | 0 | 413 → 515/635 | Không ảnh hưởng giá kho |
| 2 | Phân bổ chi phí trả trước 242, khấu hao TSCĐ (214), lương & trích theo lương | 0 | Bút toán vào 627/641/642 | Phải xong **trước** tính giá thành vì tạo 627 |
| 3 | Phân bổ chi phí mua hàng; kiểm tra tồn âm | 0 | | Chặn nếu tồn âm |
| 4 | **Tính giá xuất kho NVL/HH mua ngoài** (BOM cấp thấp nhất) | 3 | Giá trị xuất 621/627/641/642/632 | |
| 5 | Nhập SL & % HT sản phẩm dở dang; kết chuyển 621/622/623/627 → 154; phân bổ 627 | 2, 4 | 154 theo đối tượng & khoản mục | |
| 6 | **Tính giá thành** → cập nhật GT phiếu nhập TP/BTP | 5 | Nợ 155 / Có 154 | Lặp 4–6 theo cấp BOM nếu có BTP nhập kho |
| 7 | **Tính giá xuất kho thành phẩm** (và BTP) | 6 | Giá vốn 632 TP | |
| 8 | Kiểm kê, xử lý thừa thiếu; lập/hoàn nhập dự phòng 2294 (thường cuối năm/giữa niên độ) | 7 | | |
| 9 | Bù trừ thuế GTGT (Nợ 33311 / Có 1331 theo số nhỏ hơn); thuế TNDN tạm tính | 0 | | |
| 10 | Kết chuyển giảm trừ DT, kết chuyển 911, LNST (mục 5.4) | 1–9 | | Kết chuyển phải chạy **lại** nếu có thay đổi bước trước |
| 11 | Kiểm tra bất biến (mục 8); lập Bảng cân đối số phát sinh | 10 | | |
| 12 | Lập BCTC (năm) / báo cáo quản trị (tháng) | 11 | | |
| 13 | **Khóa sổ kỳ** | 11 | Kỳ bị khóa; số dư cuối thành số dư đầu kỳ sau | Mở khóa cần quyền đặc biệt + ghi log + lý do |

**Ràng buộc phụ thuộc:**
- Bất kỳ chứng từ nào sửa ở bước ≤ k làm **mất hiệu lực** kết quả các bước > k → hệ thống đánh dấu `dirty` cho kỳ (và các kỳ sau nếu ảnh hưởng tồn đầu), yêu cầu chạy lại.
- Sửa chứng từ kỳ N khi kỳ N+1 đã tính giá: số dư đầu kỳ N+1 thay đổi → phải tính lại N+1… (không cho phép nếu N+1 đã khóa).
- Không cho chạy bước 10 nếu bước 4/6/7 đang `dirty`.
- Khóa sổ theo thứ tự thời gian: không khóa kỳ N+1 khi kỳ N chưa khóa; mở khóa kỳ N phải mở các kỳ sau (hoặc cấm).
- Năm tài chính mới: chuyển số dư; kết chuyển 4212 → 4211.

---

## 7. Sổ sách & báo cáo

Số hiệu mẫu theo TT200 [KT]; TT99 có phụ lục sổ mới (42 mẫu) — **[CXM] số hiệu**; TT133 dùng hậu tố "-DNN".

| Báo cáo | Mẫu (TT200 / TT133) | Nội dung / logic dữ liệu |
|---|---|---|
| Sổ Nhật ký chung | S03a-DN / S03a-DNN | Toàn bộ bút toán theo thứ tự thời gian: ngày ghi sổ, số/ngày chứng từ, diễn giải, TK Nợ/Có, số tiền; có cột "đã ghi sổ cái", STT dòng |
| Sổ cái | S03b-DN / S03b-DNN | Theo từng TK: số dư đầu, PS Nợ/Có (TK đối ứng), số dư cuối |
| Sổ chi tiết vật liệu, dụng cụ, sản phẩm, hàng hóa | S10-DN / S07-DNN [CXM] | Theo VTHH × kho: SL & GT nhập/xuất/tồn, đơn giá từng dòng |
| Bảng tổng hợp chi tiết VL, DC, SP, HH (**Tổng hợp N-X-T**) | S11-DN / S08-DNN [CXM] | Theo VTHH: tồn đầu, nhập, xuất, tồn cuối (SL, GT). **Tổng GT tồn cuối = số dư TK tương ứng** |
| Thẻ kho | S12-DN / S09-DNN [CXM] | Chỉ **số lượng**, theo kho × VTHH, có cột xác nhận kế toán |
| Sổ chi phí SXKD | S36-DN | Theo TK 154/621/622/627 và đối tượng |
| Thẻ tính giá thành SP, DV | S37-DN | Theo SP: DDĐK, PS, DDCK, Z, z theo khoản mục |
| Bảng phân bổ NVL, CCDC; Bảng phân bổ tiền lương & BHXH; Bảng tính & phân bổ khấu hao | 07-VT, 11-LĐTL, 06-TSCĐ (chứng từ hướng dẫn) | Đầu vào giá thành |
| Bảng cân đối số phát sinh / Bảng cân đối tài khoản | S06-DN [CXM] / **F01-DNN** (TT133 – nộp kèm BCTC cho CQ thuế) | Mỗi TK: dư đầu Nợ/Có, PS Nợ/Có, dư cuối Nợ/Có; dòng Tổng: ΣNợ = ΣCó ở cả 3 cặp cột |
| BCĐKT / **Báo cáo tình hình tài chính (TT99)** | B01-DN; TT133: B01a-DNN (hoạt động liên tục) hoặc B01b-DNN | Lập từ số dư TK theo mapping chỉ tiêu (mã số 100, 110…); TK lưỡng tính (131, 331) lấy **số dư chi tiết theo đối tượng**, không lấy số dư bù trừ; 2294 ghi âm ở chỉ tiêu HTK |
| BCKQKD | B02-DN / B02-DNN | Từ PS đối ứng với 911 (hoặc PS các TK 5–8 trong kỳ, loại kết chuyển nội bộ) |
| LCTT | B03-DN (trực tiếp) / B03-DN (gián tiếp) / B03-DNN | Phương pháp trực tiếp cần **gắn mã luồng tiền** trên từng dòng thu/chi tiền (111/112/113); gián tiếp từ LN + điều chỉnh biến động vốn lưu động |
| Thuyết minh BCTC | B09-DN / B09-DNN | Có phần chính sách HTK (phương pháp tính giá, phương pháp hạch toán HTK, phương pháp lập dự phòng), chi tiết HTK theo loại, giá vốn… |

Thời hạn nộp BCTC năm (DN ngoài nhà nước): chậm nhất **90 ngày** kể từ kết thúc năm tài chính (DNTN, công ty hợp danh: 30 ngày) [KT]. Sổ & BCTC lưu trữ ≥ 10 năm [KT].

---

## 8. Bất biến & quy tắc kiểm tra cho phần mềm

### 8.1 Bất biến bút toán (cứng — vi phạm thì không cho ghi sổ)
| # | Bất biến |
|---|---|
| I1 | Mỗi chứng từ: Σ Nợ = Σ Có (theo VND; nếu đa tiền tệ: cân theo tiền hạch toán, ngoại tệ là thông tin phụ) |
| I2 | Mỗi dòng bút toán: amount > 0 (âm chỉ dùng cho bút toán đỏ/điều chỉnh có cờ rõ ràng), TK là **TK chi tiết nhất** (lá), TK đang hoạt động trong chế độ kế toán của năm |
| I3 | Toàn sổ trong mọi khoảng thời gian: Σ PS Nợ = Σ PS Có; Σ dư Nợ = Σ dư Có (Bảng CĐSPS cân) |
| I4 | Ngày hạch toán ∈ kỳ **chưa khóa**; không thêm/sửa/xóa chứng từ ở kỳ đã khóa (kể cả gián tiếp qua tính giá lại) |
| I5 | Không xóa vật lý chứng từ đã ghi sổ; sửa = bỏ ghi + ghi lại có **audit log** (ai, khi nào, giá trị trước/sau) — yêu cầu TT99 & Luật Kế toán |
| I6 | Dòng hạch toán vào TK công nợ (131, 331, 141, 1388…) bắt buộc có đối tượng; vào 152–158 bắt buộc có VTHH + kho; vào 154/621/622/627 bắt buộc có đối tượng tập hợp CP (trừ 627 chờ phân bổ) |
| I7 | Số chứng từ duy nhất theo loại chứng từ × năm (quy tắc đánh số cấu hình) |

### 8.2 Bất biến kho ↔ sổ cái
| # | Bất biến |
|---|---|
| K1 | Với mỗi TK HTK T ∈ {151, 152, 153, 155, 156, 157, 158}: **Σ GT tồn (sổ chi tiết kho) của các VTHH gắn T = Số dư sổ cái T** tại mọi thời điểm cuối ngày (đặc biệt cuối kỳ) |
| K2 | Mỗi dòng nhập/xuất kho sinh đúng 1 dòng bút toán tương ứng (cùng amount); không cho bút toán thủ công vào TK HTK không có dòng kho (trừ chứng từ "điều chỉnh giá trị kho" SL = 0) |
| K3 | SL tồn ≥ 0 theo VTHH × kho (× lô) — mặc định cứng; nếu cho phép âm tạm thời thì bắt buộc = 0 tại thời điểm khóa sổ |
| K4 | SL tồn = 0 ⇒ GT tồn = 0 (phần dư làm tròn phải được xả) |
| K5 | GT tồn ≥ 0; ĐG tồn (GT/SL) không lệch bất thường (cảnh báo nếu > ±X% so với ĐG nhập gần nhất) |
| K6 | Tồn đầu kỳ N+1 = tồn cuối kỳ N (SL, GT) theo VTHH × kho |
| K7 | Chuyển kho nội bộ: Σ GT xuất = Σ GT nhập của cùng chứng từ (tổng TK không đổi) |
| K8 | FIFO/đích danh: Σ qty_remaining các lô = SL tồn; mọi consumption tham chiếu lô có ngày ≤ ngày xuất |
| K9 | Thẻ kho (SL) khớp sổ chi tiết VTHH (SL) |

### 8.3 Bất biến giá thành
| # | Bất biến |
|---|---|
| G1 | Sau kết chuyển: số dư 621, 622, 623, 627 = 0 (trừ phần 627 dưới công suất đã chuyển 632) |
| G2 | Theo đối tượng & khoản mục: DDĐK + PS − Z − DDCK − giảm giá thành = 0; Σ DDCK các đối tượng = số dư 154 |
| G3 | Σ phân bổ 627 = Σ 627 phát sinh (sau trừ phần vào 632); dòng cuối nhận phần làm tròn |
| G4 | GT phiếu nhập TP = Z đã tính (Σ theo SP); SP hoàn thành có SL > 0 mà Z = 0 → cảnh báo |
| G5 | Hệ số/tỷ lệ: Σ Z các SP = Z nhóm |

### 8.4 Bất biến báo cáo & cuối kỳ
| # | Bất biến |
|---|---|
| B1 | Sau kết chuyển 911: mọi TK loại 5, 6, 7, 8, 9 dư = 0 |
| B2 | BCĐKT/BCTHTC: Tổng tài sản = Tổng nguồn vốn |
| B3 | LN sau thuế trên BCKQKD = PS 911 kết chuyển sang 4212 trong kỳ |
| B4 | LCTT: Tiền cuối kỳ (mã 70) = Số dư 111 + 112 + 113 (+ tương đương tiền) trên BCĐKT; Tiền đầu kỳ + lưu chuyển thuần ± ảnh hưởng tỷ giá = tiền cuối kỳ |
| B5 | Tổng công nợ chi tiết theo đối tượng = số dư sổ cái 131/331 (theo từng phía Nợ/Có) |
| B6 | Thuế: Σ GTGT đầu ra trên chứng từ bán = PS Có 33311 (trừ điều chỉnh); Σ GTGT đầu vào = PS Nợ 1331 — đối chiếu với tờ khai |
| B7 | Kỳ có trạng thái `dirty` (tính giá/giá thành chưa chạy lại sau khi sửa) ⇒ không được khóa, BCTC in ra phải gắn cảnh báo |

### 8.5 Quy tắc kỹ thuật
- Tiền: lưu **số nguyên VND** (hoặc decimal(18,0)); đơn giá decimal(18,4+); SL decimal(18,4+). Ngoại tệ decimal(18,2) + tỷ giá decimal(18,4). Không dùng float.
- Làm tròn: tại dòng chứng từ; quy tắc "dòng cuối nhận phần dư" cho mọi phép phân bổ.
- Thứ tự xử lý trong ngày: theo (ngày hạch toán, thứ tự loại chứng từ: nhập < chuyển < xuất, thời điểm ghi sổ, số chứng từ) — phải **xác định & ổn định** để tính lại cho cùng kết quả.
- Mọi tác vụ cuối kỳ (tính giá, giá thành, kết chuyển) là **idempotent**: chạy lại xóa kết quả cũ của cùng tác vụ rồi sinh mới, trong một transaction.
- Cấu hình theo chế độ kế toán & ngày hiệu lực: danh mục TK, mapping chỉ tiêu BCTC, thuế suất GTGT (giảm 8% theo thời kỳ), mẫu sổ.

---

## 9. Điểm pháp lý / nghiệp vụ còn cần xác minh (trước khi code cứng)
1. **TT99 Phụ lục II (danh mục TK)**: cấu trúc cấp 2 của 156 (1562 có thực sự bỏ?), 155, 153, nội dung TK 1385 và 6275; số hiệu cấp 2 của 521 trong TT99.
2. **TT99 KKĐK**: hướng dẫn hạch toán khi bỏ 611/631 cho DN chọn kiểm kê định kỳ.
3. **TT99 mẫu sổ/BCTC**: số hiệu mẫu sổ mới (42 mẫu), mã chỉ tiêu Báo cáo tình hình tài chính, B02, B03 — cần để lập mapping BCTC.
4. TT99 có còn cấm LIFO / có thay đổi gì về phương pháp tính giá xuất kho không (đánh giá: không, nhưng chưa đọc nguyên văn).
5. 4 văn bản bị thay thế theo Điều 31 TT99 (ngoài TT200, nghi là TT53/2016, TT75/2015, TT195/2012 — chưa xác minh).
6. NĐ70/TT32: quy trình chi tiết xử lý HĐ sai sót (điều chỉnh/thay thế, mẫu 04/SS-HĐĐT), hàng bán trả lại (ai lập HĐ).
7. Thời hạn hiệu lực mức giảm thuế GTGT 8% đang áp dụng tại 10/2026.
8. Dự thảo thông tư thay thế TT133 (rút gọn còn 22 TK) — theo dõi; nếu ban hành sẽ cần bộ cấu hình thứ 4.
9. TT48/2019 & TT24/2022 về dự phòng HTK còn hiệu lực sau các thay đổi 2025–2026.
