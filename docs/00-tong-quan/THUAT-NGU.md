# Thuật ngữ và quy ước mã

> Phiên bản: 1.0 · Ngày: 2026-10-07 · Người phụ trách: BA dự án · Trạng thái: Chờ duyệt (kế toán trưởng xác nhận quy ước mã)
> Nguồn duy nhất cho: chữ viết tắt, thuật ngữ, quy ước mã (mã lô, mã hóa, số phiếu, vị trí chứa, số chứng từ, mã yêu cầu, mã câu hỏi, mã quyết định), luật làm tròn R1. Tài liệu khác chỉ trích, không chép lại.

## 1. Quy tắc dùng chữ

- **Giao diện phần mềm và demo**: viết đầy đủ, không chữ viết tắt (quyết định [QD-11](../02-ke-hoach/QUYET-DINH.md#qd-11)). Được giữ: mã định danh (PN0001, LSX-2601-01, mã lô, mã hóa, mã vật tư, mã kho), số hiệu tài khoản, "QC", "thuế GTGT".
- **Tài liệu**: được dùng chữ viết tắt ở bảng §2. Mỗi tài liệu ghi dòng "Viết tắt" ở đầu, trỏ về bảng này. Chữ viết tắt không có trong bảng §2 thì phải viết đầy đủ.

## 2. Chữ viết tắt

| Viết tắt | Viết đầy đủ |
|---|---|
| BCTC | Báo cáo tài chính |
| BCĐKT | Bảng cân đối kế toán |
| BOD | Ban giám đốc (Board of Directors) |
| BOM | Định mức nguyên vật liệu (Bill of Materials) |
| BQ | Bình quân gia quyền |
| BTP | Bán thành phẩm |
| CCDC | Công cụ dụng cụ |
| CĐPS | Bảng cân đối số phát sinh |
| CH-nn | Mã câu hỏi mở ([CAU-HOI-MO](../01-yeu-cau/CAU-HOI-MO.md)) |
| CSDL | Cơ sở dữ liệu |
| CT | Chứng từ |
| DDĐK / DDCK | Dở dang đầu kỳ / dở dang cuối kỳ (chi phí sản xuất kinh doanh dở dang, tài khoản 154) |
| DDL | Câu lệnh định nghĩa lược đồ cơ sở dữ liệu (Data Definition Language) |
| DN | Doanh nghiệp |
| ĐVT | Đơn vị tính |
| FEFO | Hết hạn trước – xuất trước (First Expired, First Out) |
| FIFO | Nhập trước – xuất trước (First In, First Out) |
| GĐ1, GĐ2, GĐ3 | Giai đoạn 1, 2, 3 của dự án (phạm vi ở [KE-HOACH-DU-AN](../02-ke-hoach/KE-HOACH-DU-AN.md) §3). Trong mô tả quy trình sản xuất, "GĐ" là giai đoạn sản xuất; tài liệu ghi rõ ngữ cảnh |
| 1A, 1B, 1C | Ba đợt phát hành trong giai đoạn 1 |
| HĐ | Hóa đơn |
| HĐĐT | Hóa đơn điện tử |
| HSD / NSX | Hạn sử dụng / ngày sản xuất |
| HTK | Hàng tồn kho |
| KH | Khách hàng (trong bảng phản biện cũ "KH:" là kế hoạch dự án, có ghi chú tại chỗ) |
| KKTX | Kê khai thường xuyên |
| KTT | Kế toán trưởng |
| LCTT | Báo cáo lưu chuyển tiền tệ |
| LSX | Lệnh sản xuất |
| MST | Mã số thuế |
| NC, NCTT | Nhân công trực tiếp (khoản mục chi phí, tài khoản 622) |
| NCC | Nhà cung cấp |
| NFR | Yêu cầu phi chức năng (Non-Functional Requirement) |
| NVL, NVLTT | Nguyên vật liệu, nguyên vật liệu trực tiếp (tài khoản 152, khoản mục 621) |
| PG16, PG18 | PostgreSQL 16, PostgreSQL 18 |
| PM | Người-tháng (person-month) |
| PNK / PXK | Phiếu nhập kho / phiếu xuất kho (số phiếu kho, §4.3) |
| QC | Kiểm tra chất lượng (Quality Control) — giữ nguyên trên giao diện |
| QD-nn | Mã quyết định ([QUYET-DINH](../02-ke-hoach/QUYET-DINH.md)) |
| RLS | Bảo mật theo dòng của PostgreSQL (Row-Level Security) |
| SL | Số lượng |
| SoD | Phân tách nhiệm vụ (Segregation of Duties) |
| SX | Sản xuất |
| SXC | Sản xuất chung (khoản mục chi phí, tài khoản 627) |
| TK | Tài khoản kế toán |
| TP | Thành phẩm |
| TSCĐ | Tài sản cố định |
| TT99, TT133, TT200 | Thông tư 99/2025/TT-BTC, Thông tư 133/2016/TT-BTC, Thông tư 200/2014/TT-BTC |
| VAS | Chuẩn mực kế toán Việt Nam |
| XM-nn | Mã việc cần xác minh văn bản ([CAU-HOI-MO](../01-yeu-cau/CAU-HOI-MO.md) §7) |
| Z, z | Tổng giá thành, giá thành đơn vị |

Viết tắt khác, chủ yếu trong tài liệu thiết kế, tham khảo và phản biện:

| Viết tắt | Viết đầy đủ |
|---|---|
| BA | Chuyên viên phân tích nghiệp vụ (Business Analyst) |
| BCKQKD, KQHĐKD | Báo cáo kết quả hoạt động kinh doanh |
| BHXH | Bảo hiểm xã hội |
| CKTM | Chiết khấu thương mại |
| COA | Hệ thống tài khoản (Chart of Accounts) |
| CP | Chi phí |
| DD, SPDD | Dở dang, sản phẩm dở dang |
| DM, DL, MOH, SEMI | Mã khoản mục trong cơ sở dữ liệu: nguyên vật liệu trực tiếp, nhân công trực tiếp, sản xuất chung, bán thành phẩm giai đoạn trước |
| DNNVV | Doanh nghiệp nhỏ và vừa |
| DT | Doanh thu |
| ĐG | Đơn giá |
| ĐH | Đơn hàng |
| ERP | Phần mềm quản trị nguồn lực doanh nghiệp |
| FK | Khóa ngoại trong cơ sở dữ liệu (Foreign Key) |
| GL | Sổ cái (General Ledger) |
| GT | Giá trị (khác tiền tố mã yêu cầu `GT-` của phân hệ Giá thành) |
| GTCL, HMLK | Giá trị còn lại, hao mòn lũy kế (TSCĐ) |
| GPL, LGPL, AGPL, MIT | Tên giấy phép phần mềm mã nguồn mở |
| HACCP | Hệ thống phân tích mối nguy và điểm kiểm soát tới hạn |
| HH | Hàng hóa (tài khoản 156) |
| IFRS, VFRS | Chuẩn mực báo cáo tài chính quốc tế / Việt Nam |
| KKĐK | Kiểm kê định kỳ |
| LIFO | Nhập sau – xuất trước |
| MVP | Bản tối thiểu dùng được (Minimum Viable Product) |
| NĐ, QĐ, TT | Nghị định, quyết định, thông tư |
| NH | Ngân hàng (cũng là tiền tố mã yêu cầu `NH-`) |
| NK, TTĐB | Nhập khẩu, tiêu thụ đặc biệt (thuế) |
| NL | Nguyên liệu |
| NRV | Giá trị thuần có thể thực hiện được |
| NV | Nhân viên |
| PP | Phương pháp |
| PS | Phát sinh |
| QLDN | Quản lý doanh nghiệp (chi phí, tài khoản 642) |
| SCC | Thành phần liên thông mạnh trong đồ thị (dùng cho bình quân cuối kỳ nhiều giai đoạn) |
| SĐT, STT | Số điện thoại, số thứ tự |
| SP | Sản phẩm |
| SXKD | Sản xuất kinh doanh |
| TB | Trung bình (mức độ lỗi trong bảng phản biện) |
| THCP | Tập hợp chi phí (đối tượng tập hợp chi phí) |
| TNDN, TNCN | Thuế thu nhập doanh nghiệp, thu nhập cá nhân |
| UNC | Ủy nhiệm chi |
| VD | Ví dụ |
| VN | Việt Nam |
| VTHH | Vật tư, hàng hóa |
| XDCB | Xây dựng cơ bản |
| [XM], [KT], [CXM] | Nhãn độ tin cậy trong [NGHIEP-VU-KE-TOAN](../03-thiet-ke/NGHIEP-VU-KE-TOAN.md): đã xác minh / kiến thức chuyên môn / chưa xác minh. Khác mã `XM-nn` (việc cần xác minh) |

## 3. Thuật ngữ nghiệp vụ

| Thuật ngữ | Nghĩa trong dự án |
|---|---|
| Lô (mã lót hàng) | Một lượng hàng cùng nguồn (một dòng phiếu nhập mua, một lệnh sản xuất, một lần kiểm kê thừa, hoặc tồn đầu khi chuyển đổi). Lô là **đơn vị giá**: mỗi lô có giá riêng. "Mã lót" là cách khách gọi mã lô |
| Mã hóa | Mã do hệ thống tự sinh cho mỗi lô, duy nhất toàn công ty (§4.2) |
| Vị trí chứa | Bồn, trái hoặc phuy trong một kho (§4.4). Vị trí chỉ chia số lượng, không mang giá |
| Đích danh theo lô | Phương pháp giá xuất kho thực tế đích danh: xuất lô nào lấy giá của lô đó ([QD-04](../02-ke-hoach/QUYET-DINH.md#qd-04)) |
| Lệnh sản xuất công đoạn | Lệnh cho một giai đoạn tính giá của một quy trình (một lô đầu vào → một hoặc nhiều lô đầu ra). Là **đối tượng tập hợp chi phí** ([QD-05](../02-ke-hoach/QUYET-DINH.md#qd-05)) |
| Lệnh tổng | Kế hoạch sản xuất trong ngày, gom các lệnh công đoạn; không tập hợp chi phí |
| Giá thành theo lệnh | Giá thành tính riêng cho từng lệnh: dở dang = toàn bộ chi phí lũy kế của lệnh chưa hoàn thành |
| Giá nguyên liệu theo lô | Giá lô nguyên vật liệu = (thành tiền hóa đơn quy VND + chi phí mua phân bổ ± điều chỉnh về sau) / SL nhập |
| Giá vốn theo lô | Giá vốn hàng bán tính theo đúng lô xuất bán; hai lô cùng sản phẩm có giá khác nhau |
| Cây cấu thành | Bảng truy ngược giá của một lô thành phẩm: lô thành phẩm ← lệnh ← lô bán thành phẩm, lô nguyên vật liệu ← nhà cung cấp; tổng các nhánh = giá trị lô |
| Hỏng trong / ngoài định mức | SL không đạt QC nằm trong / vượt tỷ lệ cho phép của công đoạn. Trong định mức: giá trị dồn vào SL đạt. Ngoài định mức: tách ra 632 / 811 / 1388 theo R1(b) |
| Khóa kỳ | Một thao tác của KTT khóa sổ một tháng sau khi hệ thống tự kiểm cân đối ([QD-10](../02-ke-hoach/QUYET-DINH.md#qd-10)). Không phải quy trình nhiều bước |
| Cost key | Khóa tính giá: (công ty, vật tư, kho, lô) với đích danh |
| Account role | Vai trò tài khoản dùng trong định khoản thay cho số hiệu tài khoản cố định |
| Kho + QC | Mốc phát hành sớm trong đợt 1A: thủ kho và QC dùng hệ thống thay file Excel, chưa ghi sổ kế toán |
| Golden test | Bộ ví dụ số do KTT ký, phần mềm phải ra đúng từng đồng |

## 4. Quy ước mã

### 4.1 Mã lô

- Định dạng gợi ý: `DDMMYY-nn` = ngày nhập (hoặc ngày bắt đầu lệnh) + số mẻ 2 chữ số đếm trong ngày theo mặt hàng. Ví dụ `050126-01`.
- Người dùng sửa được; nhận chữ, số, `-`, `.`; 3–20 ký tự; lưu dạng chuỗi (giữ số 0 đầu).
- **Phạm vi duy nhất: theo (công ty, mặt hàng)** — một mã lô có thể dùng cho hai mặt hàng khác nhau, vì file kho của khách có 16 mã lô dùng chung cho 2–4 mặt hàng. Mã đã cấp không cấp lại kể cả khi hủy phiếu.
- Trạng thái: đề xuất, chờ khách xác nhận ([CH-46](../01-yeu-cau/CAU-HOI-MO.md#ch-46)). Quyết định: [QD-14](../02-ke-hoach/QUYET-DINH.md#qd-14). Thiết kế dữ liệu: [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §2.1.
- Lệch hiện có: demo v4.0 còn kiểm trùng mã lô **toàn nhà máy** (chặt hơn quy ước này) — ghi ở [demo/CHANGELOG.md](../../demo/CHANGELOG.md) mục "Lệch so với tài liệu".

### 4.2 Mã hóa

- Hệ thống tự sinh khi tạo lô: `NHÓM-YYMM-nnnn` = nhóm hàng + năm tháng tạo lô + số thứ tự 4 chữ số. Nhóm: `NL` nguyên liệu, `PG` phụ gia, `BB` bao bì, `BTP` bán thành phẩm, `TP` thành phẩm, `HH` hàng hóa. Ví dụ `BTP-2601-0003`.
- Duy nhất toàn công ty; không sửa tay; không đổi khi chuyển kho hoặc chuyển bồn; không cấp lại khi hủy phiếu.
- Trạng thái: nguyên tắc "tự sinh" đã chốt ([QD-13](../02-ke-hoach/QUYET-DINH.md#qd-13)); định dạng chờ khách ([CH-45](../01-yeu-cau/CAU-HOI-MO.md#ch-45)).

### 4.3 Số chứng từ và số phiếu kho

| Loại | Định dạng | Phạm vi duy nhất | Trạng thái |
|---|---|---|---|
| Số chứng từ kế toán | Tiền tố theo loại + số tăng liền mạch, đánh lại theo **năm tài chính** (demo: PN0001, PX0001, NK0001, HD0001, CK0001, CT0001, TN0001…) | (công ty, loại chứng từ, năm) | Thiết kế ([KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §7.4) |
| Số phiếu kho | `PNK-YYMMnnn` (nhập) / `PXK-YYMMnnn` (xuất), đánh lại theo **tháng**, nằm cạnh số chứng từ kế toán | (công ty, loại phiếu, tháng) | Đề xuất, chờ khách ([CH-35](../01-yeu-cau/CAU-HOI-MO.md#ch-35)) |
| Lệnh sản xuất | `LSX-YYMM-nn` (demo: LSX-2601-01) | (công ty, năm) | Demo; định dạng sản phẩm chưa chốt |

Phiếu nhập kho gồm: nhập mua, nhập kho thành phẩm/bán thành phẩm từ lệnh, hàng bán bị trả lại. Phiếu xuất kho gồm: xuất cho lệnh sản xuất, xuất bán, chuyển kho/chuyển vị trí, xuất hủy.

### 4.4 Vị trí chứa

- Ký hiệu `KHU.SỐ` cho bồn (ví dụ `A.15`), `KHU.Trái`, `KHU.Phuy` (ví dụ `5.Trái`, `B.Phuy`); khu là chữ hoặc số 1–3 ký tự.
- Bồn bắt buộc có số; khi khai vị trí mới hệ thống chuẩn hóa cách ghi tay (`2. trái` → `2.Trái`, `c. 12` → `C.12`) và chặn bồn thiếu số (`A.`).
- Tồn kho theo dõi theo **tên hàng + lô + mã hóa + vị trí** ([QD-12](../02-ke-hoach/QUYET-DINH.md#qd-12)); kiểm âm theo (vật tư, kho, lô, vị trí); giá trị vẫn theo lô.
- Chưa rõ: ký hiệu không có dấu chấm (`H1`, `MA1`, `TB2`), "trái" là gì, sức chứa — [CH-32](../01-yeu-cau/CAU-HOI-MO.md#ch-32), [CH-33](../01-yeu-cau/CAU-HOI-MO.md#ch-33).

### 4.5 Tài khoản kế toán

- Định khoản trong tài liệu viết theo TT99 (logic như TT200); cột "TT133" chỉ ghi khi khác. Chế độ áp dụng chưa chốt ([CH-05](../01-yeu-cau/CAU-HOI-MO.md#ch-05)).
- Phần mềm định khoản bằng **account role** + khoản mục chi phí, không viết cứng số hiệu ([QD-18](../02-ke-hoach/QUYET-DINH.md#qd-18)).
- Ký hiệu `(*)` sau số tài khoản: số hiệu hoặc cấp 2 theo Phụ lục II TT99 **chưa xác minh** ([XM-01](../01-yeu-cau/CAU-HOI-MO.md#xm-01)).
- Khác biệt chính TT133: 621/622/627 → 154 theo khoản mục; 521 → ghi giảm 511; 641/642 → 6421/6422.

### 4.6 Mã trong tài liệu

| Mã | Ý nghĩa | Nguồn |
|---|---|---|
| `TIEN-`, `NH-`, `MUA-`, `BAN-`, `TSCD-`, `CCDC-`, `KHO-`, `GT-`, `TH-`, `BC-`, `QC-`, `NT-`, `NEN-` + số | Mã yêu cầu theo phân hệ; hậu tố `R` là báo cáo (ví dụ `KHO-R3`) | [YEU-CAU-KHACH-HANG](../01-yeu-cau/YEU-CAU-KHACH-HANG.md) §2 |
| `NFR-nn` | Yêu cầu phi chức năng | [YEU-CAU-KHACH-HANG](../01-yeu-cau/YEU-CAU-KHACH-HANG.md) §10 |
| `CH-nn`, `XM-nn` | Câu hỏi mở, việc cần xác minh văn bản | [CAU-HOI-MO](../01-yeu-cau/CAU-HOI-MO.md) |
| `QD-nn` | Quyết định đã chốt | [QUYET-DINH](../02-ke-hoach/QUYET-DINH.md) |
| `L1–L10`, `U1–U16`, `A1–A11` | Lỗi logic demo, lỗi thao tác demo, lỗi tài liệu/kiến trúc của phản biện vòng 3 | [PHAN-BIEN-v3](../05-phan-bien/PHAN-BIEN-v3.md) |
| `I`, `K`, `G`, `B` + số (ví dụ K1, I3) | Bất biến kế toán (bút toán, kho – sổ cái, giá thành, báo cáo) | [NGHIEP-VU-KE-TOAN](../03-thiet-ke/NGHIEP-VU-KE-TOAN.md) §8 |
| Mã lỗi trong phản biện vòng 2 (`L`, `G` của nghiệp vụ; `D`, `A`, `U`, `M` của kiến trúc) | Chỉ dùng trong tài liệu lưu trữ; khi trích luôn kèm tên tài liệu | [05-phan-bien](../05-phan-bien/) |

Mã cũ của câu hỏi (A1–A10, B1–B13, C1–C9, D1–D14 ở yêu cầu v1.2 và kế hoạch v0.4) đã đổi sang `CH-nn`; bảng đối chiếu ở [CAU-HOI-MO](../01-yeu-cau/CAU-HOI-MO.md) §8. Lý do: chữ "A1…A11" trùng với mã lỗi của phản biện vòng 3.

## 5. Luật làm tròn duy nhất R1

Dùng nguyên văn ở mọi tài liệu, demo và golden test. Tài liệu khác chỉ ghi "R1(a)", "R1(b)", "R1(c)" và trỏ về đây.

> **(a)** ROUND_HALF_UP đến đồng cho mọi số tiền. Đơn giá lưu 4 số lẻ chỉ để hiển thị/giải thích; giá trị luôn tính từ tổng giá trị, không nhân lại từ đơn giá đã làm tròn.
>
> **(b)** Phân bổ một số tiền T cho n phần theo trọng số w (sản xuất chung, chi phí mua, tổng giá thành cho các phiếu nhập kho, trích theo lương…): **largest remainder** — mỗi phần lấy phần nguyên floor(T·wᵢ/W) đến đồng; số đồng còn thiếu cộng 1 đồng lần lượt cho các phần có phần lẻ lớn nhất; hòa thì theo thứ tự ổn định (ngày, số chứng từ, số dòng).
>
> **(c)** Giá trị xuất kho = round(SL × giá trị tồn / SL tồn) theo nguồn giá (lô với đích danh/FIFO, cả kỳ với bình quân cuối kỳ, thời điểm với bình quân tức thời); phần dư nằm lại ở tồn; phiếu xuất làm tồn của nguồn đó về 0 nhận toàn bộ giá trị còn lại.

Ví dụ: chia 10.000.000 cho 3 phần bằng nhau → 3.333.334 / 3.333.333 / 3.333.333. Hỏng ngoài định mức: chia 58.200.000 theo trọng số 800 : 13,4 → 57.241.210 và 958.790 ([DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §4.1).

Kiểu lưu số trong cơ sở dữ liệu (tiền, số lượng, tỷ giá, đơn giá): [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §1.4.
