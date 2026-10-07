# Kế hoạch dự án — phần mềm Kế toán · Kho · Giá vốn · Giá thành · Chất lượng

> Phiên bản: v0.5 · Ngày: 2026-10-07 · Người phụ trách: Quản lý dự án · Trạng thái: Chờ duyệt (người dùng chọn kịch bản đội, CH-54)
> Nguồn duy nhất cho: **phạm vi theo đợt, tiêu chí xong, ước lượng, tiến độ, rủi ro, bước tiếp theo**. Quyết định: [QUYET-DINH](QUYET-DINH.md). Yêu cầu: [YEU-CAU-KHACH-HANG](../01-yeu-cau/YEU-CAU-KHACH-HANG.md) v1.3. Câu hỏi: [CAU-HOI-MO](../01-yeu-cau/CAU-HOI-MO.md). Thuật ngữ, R1: [THUAT-NGU](../00-tong-quan/THUAT-NGU.md).
> Viết tắt: theo [THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §2. Mã lỗi phản biện vòng 3 (A1–A11, L, U) theo [PHAN-BIEN-v3](../05-phan-bien/PHAN-BIEN-v3.md); luôn ghi kèm "phản biện vòng 3" để không nhầm với mã câu hỏi cũ.

## 0. Lịch sử phiên bản

| Phiên bản | Ngày | Thay đổi chính |
|---|---|---|
| v0.5 | 2026-10-07 | Không đổi phạm vi, ước lượng. Sắp xếp lại tài liệu ([QD-32](QUYET-DINH.md#qd-32)): quyết định chuyển sang [QUYET-DINH](QUYET-DINH.md), câu hỏi sang [CAU-HOI-MO](../01-yeu-cau/CAU-HOI-MO.md) (mã câu hỏi cũ A/B/C/D đổi thành CH-nn), R1 sang [THUAT-NGU](../00-tong-quan/THUAT-NGU.md); cập nhật trạng thái demo v4.0; thêm việc sửa demo còn lệch tài liệu (§6) |
| v0.4 | 2026-10-07 | Theo phản biện vòng 3 (A6, A7, A9) và quyết định người dùng: mục tiêu trọng tâm giá vốn theo lô ([QD-07](QUYET-DINH.md#qd-07)); giá thành theo lệnh ([QD-05](QUYET-DINH.md#qd-05)); luôn tính lại ngay, khóa kỳ một thao tác ([QD-08](QUYET-DINH.md#qd-08), [QD-10](QUYET-DINH.md#qd-10)); sắp lại đợt và mốc "Kho + QC" ([QD-23](QUYET-DINH.md#qd-23)); kế thừa file Excel kho vào 1A; ước lại ~43–61 PM ([QD-30](QUYET-DINH.md#qd-30)); rủi ro bồn trộn nhiều lô; yêu cầu giao diện NFR-01 |
| v0.3 | 2026-10-06 | Nhận `HỆ THỐNG.docx`; giai đoạn 1 đủ 10 phân hệ + QC chia 1A/1B/1C ([QD-03](QUYET-DINH.md#qd-03)); đích danh theo lô ([QD-04](QUYET-DINH.md#qd-04)); ngoại tệ, TSCĐ, CCDC, khế ước, đơn hàng, đề nghị thanh toán, LCTT vào giai đoạn 1; R1; ước 40–56 PM |
| v0.2 | 2026-10-06 | MVP hẹp 18–22 PM; tính lại toàn bộ theo cost key; engine giá thành theo khoản mục |

## 1. Mục tiêu

Xây phần mềm **Web SaaS** cho doanh nghiệp Việt Nam (sản xuất và thương mại). Khách hàng đầu tiên: nhà máy chế biến thực phẩm (mắm cá, mắm tôm, cá bạc má sốt cà, mắm dưa gang chay; 3 địa điểm: Nhà máy Bà Ba Thạo, Bình Tây, 97 Nguyễn Thái Học; 16 người vận hành). Sau đó thương mại hóa.

Mục tiêu giai đoạn 1 của khách (nguyên văn): **(1) hệ thống quản lý chất lượng; (2) hệ thống số liệu, sổ sách theo dõi quy trình mua hàng → xuất hàng → giá thành ⇒ P&L.**

Mục tiêu trọng tâm ([QD-07](QUYET-DINH.md#qd-07)): giá vốn hàng bán của mọi sản phẩm **theo lô**; kiểm soát giá nguyên liệu theo lô; bấm một lô thành phẩm thấy giá được cấu thành từ những lô nguyên liệu nào, giá nào.

Điểm khác biệt so với MISA ([PHAN-TICH-MISA](../04-tham-khao/PHAN-TICH-MISA.md)):
1. Giá vốn theo lô giải thích được (cây cấu thành), tính lại ngay khi có chứng từ.
2. Truy xuất lô và giá thành ngay trong giai đoạn 1: ngược từ lô thành phẩm về lô nguyên liệu, nhà cung cấp, phiếu QC; xuôi từ lô nguyên liệu tới khách hàng.
3. Giá thành nhiều giai đoạn sẵn có: lệnh công đoạn, bán thành phẩm có lô, dở dang nhiều kỳ cho công đoạn ủ (MISA phân bước thủ công, mỗi kỳ một công đoạn).
4. TT99 và TT133 sẵn từ đầu, hệ thống tài khoản là dữ liệu cấu hình có ngày hiệu lực.

## 2. Quyết định nền tảng

Toàn bộ ở [QUYET-DINH](QUYET-DINH.md). Các quyết định chi phối kế hoạch này: QD-03 (đủ 10 phân hệ, làm mỏng không cắt), QD-04, QD-05, QD-06, QD-07 (giá theo lô, theo lệnh), QD-08, QD-10 (tính lại ngay, khóa kỳ một thao tác), QD-19 (ngoài phạm vi giai đoạn 1), QD-23 (chia đợt), QD-30 (ước lượng).

## 3. Phạm vi theo giai đoạn

Mã yêu cầu theo [YEU-CAU-KHACH-HANG](../01-yeu-cau/YEU-CAU-KHACH-HANG.md) §3–§5, §9, §10.

### 3.1 Nguyên tắc chia đợt

1. **Mục tiêu trọng tâm đi đầu**: chuỗi mua → kho → sản xuất → bán và giá vốn theo lô nằm trọn trong 1A; đây cũng là đường găng kỹ thuật.
2. **Đợt nào phát hành cũng khóa kỳ được** theo đúng điều kiện ([QD-10](QUYET-DINH.md#qd-10)): giá thành theo lệnh nằm trong 1A nên lô thành phẩm luôn có giá. Dự phòng nếu phần giá thành của 1A trễ: phát hành phần còn lại với khóa kỳ có điều kiện — chỉ khóa được kỳ không có lô thành phẩm / bán thành phẩm chưa có giá (hàm khóa kỳ đã kiểm điều kiện này, [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §7.2).
3. **QC là mục tiêu số 1 của khách** → mốc phát hành sớm "Kho + QC" trong 1A (số lượng, chưa ghi sổ kế toán) để thủ kho và QC bỏ file Excel sớm nhất.
4. **Phân hệ độc lập tương đối** (đơn hàng đầy đủ + duyệt, đề nghị thanh toán, ngoại tệ; TSCĐ, CCDC, khế ước) để 1B/1C, làm song song từ giữa 1A bằng một người; trước khi có, khấu hao / phân bổ / lãi vay nhập bằng chứng từ tổng hợp.
5. Mỗi đợt có tiêu chí xong đo bằng **đối chiếu số liệu thật** (§3.4).

### 3.2 Đợt 1A — Kho, lô, QC, mua, bán, sản xuất và giá vốn theo lô

| # | Hạng mục | Mã yêu cầu | Mốc |
|---|---|---|---|
| 1 | Nền móng: monorepo, CI, migration SQL chạy nguyên văn DDL của [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) + [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md), vai trò CSDL + phiên, RLS mọi schema + test loại trừ, nhật ký sửa đổi qua trigger, outbox, xác thực + phân quyền theo phân hệ × thao tác × phạm vi kho/khu, `domain-core` (R1), bộ golden test, bộ phép thử tấn công ([DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §11) trong CI | NEN-03, NEN-05, NFR-05, NFR-06 | Kho + QC |
| 2 | Danh mục (tài khoản, account role, khoản mục, đối tượng, vật tư có cờ lô/HSD/QC, tên cũ ↔ tên mới + cú pháp 13 thuộc tính, mã MISA, ĐVT có số lẻ, kho, vị trí chứa, khu); số dư đầu (tài khoản, công nợ theo chứng từ, tồn kho theo lô + vị trí từ sheet TonDau) + nhập Excel | NEN-01, NEN-02, KHO-06, KHO-09, KHO-14 | Kho + QC |
| 3 | Kho: lô, mã hóa, mã lô, số phiếu kho theo tháng, nhập/xuất theo mục đích, chuyển kho 2 bước + chuyển bồn, kiểm kê theo lô + vị trí có giải trình, đối chiếu kế toán – thủ kho; lập phiếu xuất từ đơn hàng (đơn tối thiểu, SL yêu cầu / SL thực xuất); kiểm âm theo (vật tư, kho, lô, vị trí) | KHO-02..08, KHO-10, KHO-12, KHO-13 | Kho + QC (phần số lượng) |
| 4 | Mẫu in phiếu nhập / xuất kho đủ trường và chữ ký như file + mẫu chế độ; báo cáo kho theo lô + vị trí (tồn chi tiết, N-X-T theo khoảng ngày, N-X chi tiết, N-X-T thực tế lũy kế) | KHO-11, KHO-R1..R3, KHO-R6..R10 | Kho + QC |
| 5 | QC lõi: điểm kiểm tiếp nhận, chỉ tiêu, phiếu kiểm, trạng thái lô + chặn xuất, HSD/FEFO, phiếu xuất hủy lô không đạt; truy ngược 1 cấp | QC-01 (tiếp nhận)..05, QC-08 | Kho + QC |
| 6 | Chứng từ + engine ghi sổ; tiền, ngân hàng (thu/chi, sổ quỹ, sổ tiền gửi, chưa có đề nghị thanh toán); tổng hợp; số chứng từ | TIEN-02, 03, R1..R3; NH-01, 02, R1; TH-01; TH-R1..R3 | 1A |
| 7 | Mua: nhận hàng/hóa đơn (151, chi phí mua, chi phí về sau), trả lại, giảm giá; công nợ và tổng hợp mua; giá nguyên liệu theo lô + kiểm soát chênh lệch | MUA-02..04, R1..R4; GT-09, GT-R4 | 1A |
| 8 | Bán: hóa đơn bán (kể cả bán lẻ 97 Nguyễn Thái Học), trả lại, giảm giá; công nợ và tổng hợp bán | BAN-02..04, R1..R4 | 1A |
| 9 | Sản xuất: quy trình → giai đoạn → thao tác (ánh xạ 4 quy trình); lệnh tổng + lệnh công đoạn; tiến độ sản xuất; xuất nguyên vật liệu / bán thành phẩm theo lệnh | GT-01, KHO-01, KHO-R4, KHO-R5 | 1A |
| 10 | Giá thành theo lệnh: tập hợp theo lệnh, sản xuất chung theo tiêu thức cấu hình, dở dang nhiều kỳ, bán thành phẩm có lô, phế liệu, hỏng trong/ngoài định mức, tính lại ngay | GT-02..08 | 1A |
| 11 | Giá vốn theo lô + cây cấu thành, thẻ giá thành theo lô thành phẩm, giá vốn hàng bán theo lô, lãi lỗ theo mặt hàng/lô/khách hàng | GT-10, GT-R1..R3, GT-R5 | 1A |
| 12 | Sổ sách, CĐPS, kết chuyển lãi/lỗ, khóa kỳ một thao tác | TH-02, TH-03, BC-R2 | 1A |

Mốc phát hành sớm **"Kho + QC"** = hạng mục 1, 2, 3 (phần số lượng), 4, 5: thủ kho và QC nhập trên hệ thống mới thay file Excel; chưa ghi sổ kế toán (kế toán vẫn dùng MISA).

### 3.3 Đợt 1B — Đơn hàng + duyệt, đề nghị thanh toán, ngoại tệ, QC đầy đủ

| # | Hạng mục | Mã yêu cầu |
|---|---|---|
| 1 | Đơn mua, đơn bán đầy đủ: giá, hạn mức dư nợ, theo dõi tiến độ; giá đơn mua làm mốc kiểm soát giá lô nguyên vật liệu | MUA-01, BAN-01 |
| 2 | Đề nghị thanh toán + luồng duyệt dùng chung (cưỡng chế ở CSDL: lịch sử duyệt chỉ thêm, phân tách nhiệm vụ, không chi vượt) | TIEN-01, NEN-04 |
| 3 | Ngoại tệ phần giao dịch: tỷ giá theo ngày + khóa ngày, nguyên tệ trên dòng, khoản mục mở, tỷ giá xuất quỹ, chênh lệch thực hiện 515/635 | NT-01..03, NT-05 |
| 4 | QC đầy đủ: điểm kiểm theo công đoạn, xử lý không đạt (duyệt, sinh chứng từ), truy xuất xuôi/ngược nhiều cấp, báo cáo chất lượng | QC-01 (công đoạn), QC-06, QC-07, QC-R1 |

### 3.4 Đợt 1C — Tài sản, vay, ngoại tệ cuối kỳ, báo cáo tài chính

| # | Hạng mục | Mã yêu cầu |
|---|---|---|
| 1 | TSCĐ: khai báo, ghi tăng, khấu hao (phân bổ theo bộ phận/xưởng), điều chỉnh, điều chuyển, ghi giảm; sổ TSCĐ, bảng khấu hao | TSCD-01..06, R1, R2 |
| 2 | CCDC: khai báo, ghi tăng, phân bổ, điều chỉnh, điều chuyển, ghi giảm; sổ theo dõi, bảng phân bổ | CCDC-01..06, R1, R2 |
| 3 | Khế ước vay đầy đủ: khai báo, lãi suất theo giai đoạn, lịch trả, trích lãi tự động, theo dõi tiền vay, tách ngắn/dài hạn | NH-03, NH-R2 |
| 4 | Đánh giá lại ngoại tệ cuối kỳ (413 → 515/635) | NT-04 |
| 5 | BCTC: kết quả kinh doanh, bảng cân đối kế toán (tên mẫu theo chế độ), LCTT trực tiếp và gián tiếp, thuyết minh khung | BC-R1, BC-R3..R5 |

**Tiêu chí xong** (dữ liệu thật của khách, chạy song song MISA):
- **Mốc Kho + QC**: thủ kho 3 kho và 4 QC khu nhập trên hệ thống mới thay file Excel **4 tuần liên tiếp**; tồn theo lô + vị trí khớp kiểm kê cuối tháng (chênh lệch có giải trình); mọi lô nguyên vật liệu nhập trong tháng có phiếu QC tiếp nhận.
- **1A**: N-X-T theo kho khớp MISA về **số lượng**; sổ quỹ, sổ ngân hàng, công nợ khớp MISA; giá thành và giá vốn theo lô của ít nhất 2 quy trình (đề xuất mắm tôm và cá bạc má) cho 2 kỳ liên tiếp được **KTT ký** (MISA không có số đích danh theo lô để so, nên KTT duyệt từng thẻ giá thành, cây cấu thành của mẫu lô thành phẩm và bảng đối chiếu tổng 152/154/155/632 với sổ cái); hai kỳ khóa được.
- **1B**: đề nghị thanh toán và đơn hàng chạy qua luồng duyệt thật 1 tháng; chênh lệch tỷ giá thực hiện khớp tính tay của KTT.
- **1C**: CĐPS, kết quả kinh doanh, bảng cân đối kế toán khớp MISA (chênh lệch giải thích được từng đồng, phần giá vốn khác do phương pháp đích danh được liệt kê); LCTT hai phương pháp cho cùng lưu chuyển thuần.
- **Nghiệm thu giai đoạn 1**: chạy song song toàn bộ 2–3 tháng sau 1C.

### 3.5 Ước lượng tiến độ và nhân sự (không chắc chắn)

**Người-tháng (PM) phát triển**, đã gồm test tự động và review, chưa gồm BA, tester, KTT và nghiệm thu. Chưa có số liệu năng suất thật của đội nên **sai số có thể ±30%**.

| # | Hạng mục | Đợt | PM thấp | PM cao |
|---|---|---|---|---|
| 1 | Nền móng (vai trò CSDL, phiên, RLS mọi schema, nhật ký qua trigger, bộ phép thử tấn công, phân quyền theo kho/khu) | 1A | 3,5 | 5 |
| 2 | Danh mục, lưới nhập liệu, số dư đầu (theo lô + bồn), nhập Excel, tên cũ/mới + cú pháp tên | 1A | 3,5 | 5 |
| 3 | Kho + lô + vị trí chứa, mã hóa, số phiếu kho + engine đích danh + chuyển kho/bồn + kiểm kê có giải trình + đối chiếu thủ kho + lập phiếu xuất từ đơn | 1A | 4 | 5,5 |
| 4 | Mẫu in phiếu kho; báo cáo kho theo lô + vị trí, N-X-T thực tế | 1A | 1 | 1,5 |
| 5 | QC lõi | 1A | 1,5 | 2 |
| 6 | Chứng từ + engine ghi sổ; tiền, ngân hàng, tổng hợp; số chứng từ | 1A | 2,5 | 3 |
| 7 | Mua (chưa có đơn mua) + báo cáo + giá nguyên liệu theo lô | 1A | 2 | 3 |
| 8 | Bán (đơn tối thiểu) + báo cáo | 1A | 2 | 3 |
| 9 | Quy trình, lệnh công đoạn, tiến độ sản xuất | 1A | 2 | 3 |
| 10 | Giá thành theo lệnh (tính lại ngay) | 1A | 3 | 4 |
| 11 | Giá vốn theo lô + cây cấu thành, thẻ giá thành, lãi lỗ theo lô | 1A | 1,5 | 2,5 |
| 12 | Sổ sách, CĐPS, kết chuyển, khóa kỳ một thao tác | 1A | 2 | 2,5 |
| | **Cộng 1A** | | **28,5** | **40** |
| | — trong đó mốc Kho + QC (1, 2, 3, 4, 5) | | 13,5 | 19 |
| 13 | Đơn mua, đơn bán đầy đủ | 1B | 1,5 | 2 |
| 14 | Đề nghị thanh toán + luồng duyệt | 1B | 1 | 1,5 |
| 15 | Ngoại tệ phần giao dịch | 1B | 1,5 | 2 |
| 16 | QC đầy đủ + truy xuất nhiều cấp | 1B | 1,5 | 2 |
| | **Cộng 1B** | | **5,5** | **7,5** |
| 17 | TSCĐ | 1C | 1,5 | 2,5 |
| 18 | CCDC | 1C | 1 | 1,5 |
| 19 | Khế ước vay | 1C | 1 | 1,5 |
| 20 | Đánh giá lại ngoại tệ | 1C | 0,5 | 1 |
| 21 | BCTC + LCTT trực tiếp/gián tiếp + thuyết minh khung | 1C | 2,5 | 3,5 |
| | **Cộng 1C** | | **6,5** | **10** |
| 22 | Chuyển đổi dữ liệu MISA + file Excel kho, hỗ trợ chạy song song, sửa lỗi ổn định | xuyên suốt | 2,5 | 3,5 |
| | **Tổng phát triển** | | **~43** | **~61** |

**Năng suất** ([QD-30](QUYET-DINH.md#qd-30)): 60–70% ⇒ 5 người: 3,0–3,5 PM/tháng; 4 người: 2,4–2,8 PM/tháng. Mốc = PM lũy kế ÷ năng suất (đầu khoảng: PM thấp ÷ năng suất cao; cuối khoảng: PM cao ÷ năng suất thấp). Tháng tính từ ngày bắt đầu (CH-54).

| Mốc | PM lũy kế | **5 người** (tháng) | **4 người** (tháng) |
|---|---|---|---|
| Nền móng xong | 3,5–5 | 1,5–2 | 1,5–2,5 |
| **Kho + QC** dùng thật (thay file Excel) | 13,5–19 | **4–6,5** | 5–8 |
| **1A** dùng song song MISA (giá vốn theo lô, khóa kỳ) | 28,5–40 | **8–13,5** | 10–17 |
| **1B** dùng song song | 34–47,5 | 10–16 | 12–20 |
| **1C** xong mã nguồn (gồm chuyển đổi) | 43–61 | **12,5–20,5** | **15,5–25,5** |
| **Nghiệm thu giai đoạn 1** sau 2–3 tháng chạy song song | — | **14,5–23,5** | **17,5–28,5** |

Với 5 người, giữa khoảng là xong mã nguồn khoảng **tháng 16–17**, nghiệm thu khoảng **tháng 19**. **Không cam kết** con số giữa khoảng trước khi đo năng suất thật. Thêm người quá 6 không rút ngắn tương ứng vì đường găng (engine giá, giá thành theo lệnh, cây cấu thành) do 1–2 người nắm.

**Không chắc chắn chính** (theo thứ tự ảnh hưởng): (1) năng suất thật của đội — đo sau nền móng và sau mốc Kho + QC, ước lại ở v0.6, v0.7; (2) dữ liệu quy trình (thời gian ủ, định mức, tiêu thức sản xuất chung — CH-47, CH-48, CH-10) và trả lời CH-31 (bồn trộn lô — nếu có, mô hình lô gộp thêm ~0,5–1 PM); (3) khối lượng sửa theo KTT khi duyệt thẻ giá thành; (4) chất lượng dữ liệu chuyển đổi (file Excel nhiều công thức hỏng, mã lô và ký hiệu bồn không thống nhất — [YEU-CAU-KHACH-HANG](../01-yeu-cau/YEU-CAU-KHACH-HANG.md) §9.6); (5) chế độ kế toán và ngày bắt đầu (CH-05, CH-06).

**Đội đề xuất**: 5 người phát triển (1 trưởng kỹ thuật kiêm engine giá/giá thành, 2 backend, 2 fullstack/frontend) + **1 BA nghiệp vụ kế toán** toàn thời gian (đặc tả, golden test, làm việc với khách) + **1 tester** + **KTT ~1 ngày/tuần** duyệt đặc tả và golden test (nhiều hơn trong 2 tháng trước khi làm giá thành).

**Làm mỏng trong từng phân hệ** (danh sách chốt trước, áp dụng khi chậm hơn kế hoạch ≥ 1 tháng):
- Đề nghị thanh toán và đơn hàng: luồng duyệt cố định tối đa 2 cấp theo ngưỡng tiền, chưa có trình thiết kế luồng.
- Đơn hàng: chưa giữ chỗ tồn kho, chưa báo giá.
- Ngoại tệ: chỉ các đồng tiền thật sự dùng; tỷ giá nhập tay.
- Khế ước vay: lãi suất nhập tay theo giai đoạn; lịch trả đều hoặc nhập tay; không vốn hóa lãi vay.
- TSCĐ: chỉ khấu hao đường thẳng; chưa đánh giá lại. CCDC: phân bổ đều.
- Giá thành: tối đa 2 tiêu thức phân bổ; sản xuất chung dưới công suất để tắt; cây cấu thành dạng bảng thụt lề (chưa vẽ đồ thị).
- Giá nguyên liệu theo lô: một ngưỡng % cho mọi nhóm hàng.
- QC: chỉ tiêu dạng danh sách đơn giản; chưa biểu đồ kiểm soát; ảnh đính kèm thay vì nhập chi tiết kết quả phòng thí nghiệm.
- LCTT gián tiếp: công thức cố định theo chế độ + dòng điều chỉnh tay có lưu vết.
- Báo cáo: một khung lưới chung + xuất Excel; mẫu in PDF chỉ cho chứng từ, phiếu kho và BCTC bắt buộc.

### 3.6 Giai đoạn 2 và giai đoạn 3

- **Giai đoạn 2**: tích hợp HĐĐT (NĐ 70/2025, TT 32/2025), tờ khai thuế XML, phân hệ tiền lương, tính lại tăng dần có điểm dừng ([KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §5.5), bán thành phẩm chuyển thẳng 154 không qua kho (nếu cần), phương pháp bình quân / FIFO cho khách khác, giải vòng bán thành phẩm/thành phẩm, bật chế độ thứ hai, ứng dụng quét mã vạch cho thủ kho/QC, kết nối ngân hàng, partition.
- **Giai đoạn 3 — thương mại hóa**: khách tự đăng ký, thu phí, nhiều chi nhánh/hợp nhất, thiết kế báo cáo, API/webhook, chuỗi băm nhật ký, trợ lý AI hạch toán hóa đơn đầu vào.

## 4. Kiến trúc: trạng thái

DDL của [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) rồi [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) **chạy nguyên văn theo thứ tự** trên PostgreSQL 16.15 (chỉ thêm `uuidv7()` → `gen_random_uuid()`); **66 phép thử** chức năng và tấn công chạy bằng vai trò `app_user` đều đạt (bảng ở [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §11).

| Lỗi phản biện vòng 3 | Đã sửa | Ở đâu |
|---|---|---|
| A1 | Khóa ngoại kép dòng bút toán → bút toán → chứng từ; chỉ thêm dòng vào bút toán do chính giao dịch đang chạy tạo; chỉ vô hiệu hóa, không sửa/xóa; khóa kỳ áp cho dòng | KIEN-TRUC §4.5, §7.1, §7.2 |
| A2 | RLS mọi schema bằng `app.apply_tenant_rls()`; phép thử `app.check_rls_coverage()`; nhật ký chỉ ghi qua trigger `SECURITY DEFINER` | KIEN-TRUC §2.1, §7.3, §7.7 |
| A3 | CHECK `move_kind` + chiều; guard INSERT OR UPDATE; phương pháp giá hiệu lực lấy từ công ty; `qc_status` chỉ đổi qua hàm QC; lô mới luôn Chờ kiểm | KIEN-TRUC §4.7; DIEU-CHINH §2.5, §2.7, §10 |
| A4 | Guard header so `jsonb` trừ cột được phép | DIEU-CHINH §1 |
| A5 | Lịch sử duyệt chỉ thêm; `wf.act` kiểm vai trò bước, người lập không tự duyệt, một người không duyệt hai bước; quyết toán không vượt | DIEU-CHINH §8 |
| A9 | Một nguồn: trình tự khóa kỳ (KIEN-TRUC §7.2), tính lại toàn bộ / tăng dần (KIEN-TRUC §5.5), mã lô ([THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §4.1), hỏng ngoài định mức ([QD-24](QUYET-DINH.md#qd-24)), kiểu số (KIEN-TRUC §1.4) | như cột trái |
| A10 | Khối nền móng tạo extension/schema/vai trò; thêm `core.users`, `core.user_roles`, `core.sessions`, `md.partners`, `md.expense_items`; `inv.lots` tạo một lần | KIEN-TRUC §2.1, §4.1, §4.6; DIEU-CHINH §2.7 |
| A11 | Ứng dụng chỉ đặt token phiên; ghi giá trị sổ kho chỉ qua `inv.set_valuation` của `engine_user`; khóa/mở kỳ qua hàm kiểm vai trò KTT | KIEN-TRUC §2.1, §4.7, §7.2 |
| (mới) | `acc.period_locks`, `md.fx_rate_day_locks` sửa được bằng DML thường — đã chặn bằng `sys.table_privileges` | KIEN-TRUC §7.7; DIEU-CHINH §11 |

(KIEN-TRUC = [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md); DIEU-CHINH = [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md).)

Còn mở (làm trong nền móng 1A): chạy trên PG18; thử hai phiên đồng thời cho các guard mới và cho khóa kỳ sau khi chuyển sang hàm `SECURITY DEFINER`; property test định giá đích danh; golden test giá thành theo lệnh; đo chi phí trigger nhật ký; các lỗi mức trung bình còn lại của [PHAN-BIEN-v2-KIEN-TRUC](../05-phan-bien/PHAN-BIEN-v2-KIEN-TRUC.md) (trigger Nợ/Có O(n²), HOT update của sổ kho).

## 5. Rủi ro chính

| Rủi ro | Giảm thiểu |
|---|---|
| **Trễ tiến độ**: ~43–61 PM, xong mã nguồn 12,5–20,5 tháng (5 người) | Chia đợt có tiêu chí xong; mốc Kho + QC sớm; danh sách làm mỏng chốt trước (§3.5); ước lại sau nền móng và sau mốc Kho + QC; không nhận yêu cầu mới vào giai đoạn 1 khi chưa đổi kế hoạch |
| **Bồn trộn nhiều lô / châm thêm** (phản biện vòng 3 A8, suy luận từ 3 bồn trong file từng chứa 2 lô cùng lúc) — đích danh theo lô sai bản chất nếu lô xuất ra thực chất là hỗn hợp | Hỏi khách (CH-31) trước khi chốt mô hình lô; nếu có: thao tác trộn là lệnh sản xuất sinh **lô gộp** (giá trị = tổng các lô vào); trong khi chờ: cảnh báo khi đưa lô vào bồn đang có lô khác |
| Đổi phương pháp giá / chế độ kế toán giữa niên độ khi bắt đầu dùng thật | CH-06, XM-12; đề xuất bắt đầu từ đầu năm tài chính; KTT xác nhận |
| **KTT không đủ thời gian duyệt đặc tả** — đường găng của phần giá thành trong 1A | Lịch cố định ~1 ngày/tuần; KTT ký golden test giá thành, định khoản theo chế độ, quy tắc hàng không đạt trước khi làm; BA chuẩn bị sẵn để mỗi buổi chỉ cần quyết định |
| Chế độ kế toán chưa chốt (TT99 hay TT133) | Thiết kế theo account role + khoản mục ([QD-18](QUYET-DINH.md#qd-18)); chốt trước khi viết golden test (CH-05) |
| Thiếu dữ liệu quy trình (thời gian ủ, định mức, tỷ lệ không đạt, tiêu thức) | Gửi CH-10, CH-47, CH-48 ngay; ví dụ trong thiết kế và demo là giả định, phải thay bằng số thật. Nếu đến tháng 4 chưa có số liệu thì phần giá thành của 1A trễ tương ứng và dùng phương án dự phòng §3.1 mục 2 |
| Tồn đầu kỳ theo lô không có trong MISA | Kiểm kê lập lô + vị trí tại ngày chuyển đổi (lô tồn đầu, theo cột sheet TonDau); giá trị lô = giá trị tồn MISA chia theo SL (R1(b)) — KTT duyệt (CH-07) |
| Nhập liệu hai lần khi chạy song song làm 16 người quá tải | Từ mốc Kho + QC: QC, thủ kho nhập trên hệ thống mới làm nguồn thật; kế toán vẫn dùng MISA đến hết 1A; chứng từ kho từ hệ thống mới xuất Excel để nhập vào MISA (XM-10) |
| Người dùng xưởng/kho chưa quen nhập liệu trên phần mềm | Màn hình riêng tối giản cho QC/thủ kho, dùng được trên máy tính bảng; đào tạo theo khu; cho dùng thật sớm từ mốc Kho + QC |
| Đích danh theo lô cho mọi hàng làm tăng thao tác chọn lô | Hệ thống gợi ý lô (FEFO rồi lô cũ nhất); chỉ chọn tay khi khách muốn (CH-16) |
| Sai giá vốn / giá thành | Golden test do KTT ký + property test (Nợ = Có, kho = sổ cái, bảo toàn theo lô) + chạy song song |
| Demo khác thiết kế làm khách hiểu sai | Kịch bản trình diễn nói rõ giả định ([demo/HUONG-DAN-DEMO.md](../../demo/HUONG-DAN-DEMO.md)); danh sách lệch ở [demo/CHANGELOG.md](../../demo/CHANGELOG.md) |
| LCTT gián tiếp lệch trực tiếp | Kiểm tra bắt buộc hai phương pháp bằng nhau; dòng điều chỉnh tay có lưu vết |
| Quy định chưa ổn định (TT99 mới, dự thảo thay TT133, mẫu biểu TT99 chưa xác minh) | Mọi thứ phụ thuộc văn bản là dữ liệu có phiên bản; theo dõi XM-01..XM-12 |
| Rò rỉ dữ liệu giữa công ty thuê bao, sửa dữ liệu trái phép | [QD-21](QUYET-DINH.md#qd-21); bộ phép thử tấn công trong CI |
| Hàm `SECURITY DEFINER` có lỗi = lỗ hổng | Quy tắc viết hàm (đặt `search_path`, tenant từ phiên, kiểm vai trò đầu hàm); review như mã bảo mật ([DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §12 mục 11) |
| DDL chưa chạy trên PG18 | Nền móng 1A cài PG18 và chạy lại cùng bộ phép thử trước khi viết engine |
| Tuyển đủ đội | Bắt đầu nền móng với đội nhỏ hơn; đường găng là trưởng kỹ thuật và BA |

## 6. Bước tiếp theo (vòng 5)

| # | Việc | Người làm | Đầu ra |
|---|---|---|---|
| 1 | Gửi khách [YEU-CAU-KHACH-HANG](../01-yeu-cau/YEU-CAU-KHACH-HANG.md) v1.3 và [CAU-HOI-MO](../01-yeu-cau/CAU-HOI-MO.md); xin trả lời trước các câu ưu tiên (CH-05, CH-06, CH-01, CH-31, CH-44, CH-46, CH-45, CH-35, CH-47, CH-10) | BA dự án | Biên bản trả lời, cập nhật CAU-HOI-MO |
| 2 | Trình diễn demo v4.0 cho khách theo [demo/HUONG-DAN-DEMO.md](../../demo/HUONG-DAN-DEMO.md); ghi phản hồi | Quản lý dự án | Danh sách phản hồi → yêu cầu / câu hỏi mới |
| 3 | KTT duyệt: chế độ kế toán, định khoản trong ma trận truy vết, giá thành theo lệnh và cây cấu thành (golden test [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §4.1, §4.3 sau khi thay số thật), quy tắc hàng không đạt, điều kiện khóa kỳ ([KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §7.2) | KTT, BA | Golden test có chữ ký |
| 4 | Người dùng chọn kịch bản đội và ngày bắt đầu (CH-54); đặt mốc tháng ở §3.5 theo ngày thật | Người dùng | Kế hoạch v0.6 |
| 5 | Nền móng: cài Node 24 + Docker + PostgreSQL 18; chạy lại nguyên văn DDL và 66 phép thử trong CI; thêm phép thử hai phiên đồng thời | Trưởng kỹ thuật | CI xanh trên PG18 |
| 6 | Sửa demo cho khớp tài liệu: mã lô duy nhất theo mặt hàng ([QD-14](QUYET-DINH.md#qd-14)); lập phiếu xuất từ đơn hàng với SL yêu cầu / SL thực xuất khác nhau (KHO-12); chuyển kho hai bước ([QD-28](QUYET-DINH.md#qd-28)); chữ ký phiếu nhập kho theo mẫu khách (KHO-11) — danh sách đầy đủ ở [demo/CHANGELOG.md](../../demo/CHANGELOG.md) "Lệch so với tài liệu" | Người làm demo | Demo v4.1 |
