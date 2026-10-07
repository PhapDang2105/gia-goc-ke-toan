# Danh mục sách, văn bản và tài liệu hỗ trợ

> Phiên bản: 1.0 · Ngày: 2026-10-04 (đổi tên file 2026-10-07; cũ: `research/03-sach-tai-lieu.md`) · Người phụ trách: Nhóm nghiên cứu · Trạng thái: Đã duyệt (tài liệu tham khảo; mục ⚠ chưa xác minh, theo dõi ở [CAU-HOI-MO](../01-yeu-cau/CAU-HOI-MO.md) §7)
> Viết tắt: theo [THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §2.

> Dự án: phần mềm kế toán / quản lý kho / tính giá vốn & giá thành (tương tự MISA SME) cho doanh nghiệp Việt Nam.
> Ngày lập: 2026-10-04. Người lập: nhóm nghiên cứu (AI hỗ trợ).

**Quy ước**
- Ưu tiên: **[Phải đọc]** / **[Nên đọc]** / **[Tham khảo]**
- Xác minh: ✔ = link/thông tin đã được kiểm tra qua tìm kiếm web ngày 2026-10-04; ⚠ = **chưa xác minh** (link hoặc chi tiết cần kiểm tra lại trước khi dùng).
- Với giáo trình in: "chương liên quan" ghi theo nội dung tổng quát tìm được; số chương cụ thể có thể khác theo lần tái bản (⚠ cần đối chiếu bản in).

---

## 0. Cảnh báo pháp lý quan trọng (đọc trước)

1. **TT 99/2025/TT-BTC đã thay thế TT 200/2014/TT-BTC** từ 01/01/2026 (áp dụng cho năm tài chính bắt đầu từ 01/01/2026). Ban hành 27/10/2025. Thay thế TT 200/2014, 75/2015, 53/2016, 195/2012. ✔
2. **TT 99/2025 KHÔNG thay thế TT 133/2016** (DN nhỏ và vừa). DNNVV từ 2026 được chọn TT 133 hoặc TT 99. Bộ Tài chính đã có **dự thảo thông tư thay thế TT 133** (hệ thống tài khoản rút từ 49 xuống ~22 tài khoản) — **chưa ban hành chính thức tại thời điểm tra cứu** ⚠ (cần theo dõi).
3. Hóa đơn: **NĐ 123/2020** được sửa đổi bởi **NĐ 70/2025** (hiệu lực 01/06/2025); **TT 32/2025/TT-BTC thay thế TT 78/2021** (từ 01/06/2025). ✔
4. Thuế: **Luật Thuế GTGT 48/2024/QH15** (hiệu lực 01/07/2025) + **NĐ 181/2025**; **Luật Thuế TNDN 67/2025/QH15** (hiệu lực 01/10/2025, áp dụng từ kỳ tính thuế 2025) + **NĐ 320/2025**. ✔
5. ⇒ Phần mềm phải thiết kế **đa chế độ kế toán** (TT 99 / TT 133 / thông tư thay thế TT 133 sắp tới) với hệ thống tài khoản & mẫu biểu cấu hình được, có hiệu lực theo thời gian (effective-dated).

---

## 1. Giáo trình Việt Nam

| # | Tên | Tác giả | NXB / Năm | Chương liên quan giá thành / HTK | Ưu tiên | XM |
|---|-----|---------|-----------|-------------------------------|---------|----|
| 1.1 | **Giáo trình Kế toán tài chính trong các doanh nghiệp** | GS.TS. Đặng Thị Loan (chủ biên) | NXB ĐH Kinh tế Quốc dân, 2011; tái bản lần 2 có sửa đổi 2013 (656 tr., ISBN 978-604-927-304-9) | Kế toán NVL–CCDC; Chi phí SXKD & tính giá thành sản phẩm; Kế toán thành phẩm, tiêu thụ; Đặc thù DN thương mại, xây lắp, nông nghiệp | Phải đọc | ✔ (thư viện [VKU](https://elib.vku.udn.vn/handle/123456789/3348)) |
| 1.2 | **Giáo trình Kế toán quản trị** | PGS.TS. Nguyễn Ngọc Quang (chủ biên), Nguyễn Năng Phúc, Phạm Thị Gái, Phạm Thị Thủy | NXB ĐH KTQD, 2012; tái bản 2014; bản 2021 (575 tr.) | Phân loại chi phí (biến phí/định phí), CVP, chi phí định mức & dự toán, phân tích biến động, giá thành theo công việc/quá trình | Phải đọc | ✔ (khoa [SAA-NEU](https://saa.neu.edu.vn/PGSTS-NGUYEN-NGOC-QUANG.html)) |
| 1.3 | **Giáo trình Kế toán chi phí** | TS. Đoàn Ngọc Quế, PGS.TS. Phạm Văn Dương, TS. Huỳnh Lợi (chủ biên) — Khoa Kế toán–Kiểm toán UEH | NXB Kinh tế TP.HCM, 2015 (315 tr., ISBN 9786049221989) | Toàn bộ sách: tập hợp chi phí, đánh giá SPDD, tính giá thành giản đơn/hệ số/tỷ lệ/phân bước/đơn đặt hàng, chi phí định mức, ABC | **Phải đọc** (sách lõi cho module giá thành) | ✔ (thông tin thư viện; năm có thể có bản mới hơn ⚠) |
| 1.4 | **Giáo trình Kế toán tài chính doanh nghiệp** (Học viện Tài chính) | GS.TS. Ngô Thế Chi, PGS.TS. Trương Thị Thủy (bản 2013, 2015); PGS.TS. Trương Thị Thủy, PGS.TS. Ngô Thị Thu Hồng (bản 2019, 2024) | NXB Tài chính | Kế toán HTK (KKTX/KKĐK), chi phí sản xuất & giá thành, giá vốn hàng bán, dự phòng giảm giá HTK | Nên đọc (đọc bản 2024 vì cập nhật hơn) | ✔ ([dlib HVTC](https://dlib.hvtc.edu.vn/entities/publication/79d9cc8e-c42b-4787-9e52-77036715fbbf)) |
| 1.5 | **Giáo trình Kế toán tài chính** (ĐH Thương mại) | Nguyễn Tuấn Duy (chủ biên) | NXB Thống kê, 2010 | Kế toán HTK, tiền lương, TSCĐ; góc nhìn DN thương mại (giá vốn hàng mua – bán) | Tham khảo | ✔ ([dlib TMU](https://dlib.tmu.edu.vn/handle/123456789/11403)) |
| 1.6 | **Giáo trình Nguyên lý kế toán** | Nguyễn Hữu Ánh, Phạm Đức Cường | NXB ĐH KTQD, 2020 | Tài khoản, ghi sổ kép, chứng từ, sổ sách, tính giá các đối tượng (nguyên tắc giá gốc, tính giá xuất kho) | **Phải đọc** (nền tảng cho cả dev) | ✔ (đề cương học phần [NEU KTKE1101](https://courses.neu.edu.vn/syllabus/K66-2024/vi/KTKE1101)) |
| 1.7 | Hướng dẫn học tập Nguyên lý kế toán | Phạm Đức Cường, Trần Quang Chung | NXB ĐH KTQD, 2023 | Bài tập định khoản — dùng làm **test case** | Nên đọc | ✔ (qua tìm kiếm, chưa có link trang sách) |
| 1.8 | Giáo trình Kế toán quản trị 1 (UEH) | Khoa Kế toán UEH | UEH Press | Hệ thống tính giá thành, phân tích chi phí | Tham khảo | ✔ ([UEH Book](https://shop.ueh.edu.vn/ueh-book/san-pham/ke-toan-quan-tri-1/)); tác giả/năm ⚠ |

**Lưu ý**: Hầu hết giáo trình xuất bản trước 2026 dựa trên TT 200 → khi đọc phải đối chiếu số hiệu tài khoản/mẫu biểu với TT 99/2025.

---

## 2. Văn bản pháp lý gốc

### 2.1 Luật & chế độ kế toán

| # | Văn bản | Ngày / hiệu lực | Link | Ưu tiên | Vì sao quan trọng cho phần mềm | XM |
|---|---------|-----------------|------|---------|-------------------------------|----|
| 2.1 | **Luật Kế toán 88/2015/QH13** | 20/11/2015; HL 01/01/2017 | [thuvienphapluat](https://thuvienphapluat.vn/van-ban/Ke-toan-Kiem-toan/Luat-ke-toan-2015-298369.aspx) · [vbpl.vn (Bộ TC)](https://vbpl.vn/botaichinh/Pages/vbpq-luocdo.aspx?ItemID=95924) | Phải đọc | Quy định chứng từ điện tử, sổ kế toán, khóa sổ, sửa chữa sổ (ghi đỏ/ghi bổ sung — không xóa), lưu trữ 10 năm → yêu cầu **immutability & audit trail**. | ✔ |
| 2.2 | **Luật 56/2024/QH15** (sửa đổi Luật Kế toán và 8 luật khác) | 29/11/2024; HL 01/01/2025 | [Công báo Chính phủ](https://congbao.chinhphu.vn/van-ban/luat-so-56-2024-qh15-43561.htm) · [thuvienphapluat](https://thuvienphapluat.vn/van-ban/Thue-Phi-Le-Phi/Luat-sua-doi-Luat-Chung-khoan-Ke-toan-Ngan-sach-Nha-nuoc-Thue-thu-nhap-ca-nhan-2024-622318.aspx) | Nên đọc | Cập nhật các điều sửa đổi của Luật Kế toán. | ✔ |
| 2.3 | **TT 99/2025/TT-BTC** — Hướng dẫn chế độ kế toán doanh nghiệp | 27/10/2025; HL 01/01/2026 | [thuvienphapluat](https://thuvienphapluat.vn/van-ban/Doanh-nghiep/Circular-99-2025-TT-BTC-2025-corporate-accounting-guidelines-680753.aspx) · [bản EN](https://thuvienphapluat.vn/van-ban/EN/Doanh-nghiep/Circular-99-2025-TT-BTC-2025-corporate-accounting-guidelines/680753/tieng-anh.aspx) · [MISA tổng hợp điểm thay đổi](https://helpsme.misa.vn/2026/kb/tong-hop-cac-diem-thay-doi-trong-thong-tu-99-2025-tt-btc-thay-the-thong-tu-200-2014-tt-btc/) | **Phải đọc** | Hệ thống tài khoản, chứng từ, 42 mẫu sổ, BCTC hiện hành — là **spec chính** cho Chart of Accounts & báo cáo. Mở rộng sang quy chế kiểm soát nội bộ/quy chế hạch toán nội bộ. | ✔ |
| 2.4 | **TT 200/2014/TT-BTC** | 22/12/2014; HL 07/02/2015; **hết hiệu lực từ 2026** | [thuvienphapluat](https://thuvienphapluat.vn/van-ban/Doanh-nghiep/Thong-tu-200-2014-TT-BTC-huong-dan-Che-do-ke-toan-Doanh-nghiep-263599.aspx) · [Công báo](https://congbao.chinhphu.vn/van-ban/thong-tu-so-200-2014-tt-btc-6697.htm) | Nên đọc | Cần cho **chuyển đổi dữ liệu** (mapping TK cũ → TK mới) và xử lý số liệu năm ≤2025. | ✔ |
| 2.5 | **TT 133/2016/TT-BTC** — Chế độ kế toán DN nhỏ và vừa | 26/08/2016; HL 01/01/2017; **vẫn hiệu lực** | [thuvienphapluat](https://thuvienphapluat.vn/van-ban/Doanh-nghiep/Thong-tu-133-2016-TT-BTC-huong-dan-che-do-ke-toan-doanh-nghiep-nho-va-vua-284997.aspx) · [Công báo](https://congbao.chinhphu.vn/van-ban/thong-tu-so-133-2016-tt-btc-21048/15522.htm) | **Phải đọc** | Phân khúc mục tiêu (SME) chủ yếu dùng TT 133. | ✔ |
| 2.6 | Dự thảo TT thay thế TT 133/2016 | Dự thảo (chưa ban hành) | [FAST — bảng so sánh dự thảo](https://fast.com.vn/bang-so-sanh-du-thao-thong-tu-thay-the-thong-tu-133-tai-bang-so-sanh-chi-tiet/) · [MISA AMIS](https://amis.misa.vn/293267/du-thao-thong-tu-thay-the-thong-tu-133/) · [TVPL: TT 99 có thay TT 133?](https://thuvienphapluat.vn/ma-so-thue/phap-luat-thue/thong-tu-992025-co-thay-the-thong-tu-1332016-che-do-ke-toan-doanh-nghiep-nho-va-vua-213873.html) | Nên đọc (theo dõi) | Thiết kế CoA cấu hình được để sẵn sàng khi ban hành. | ✔ link / ⚠ trạng thái ban hành |

### 2.2 Chuẩn mực kế toán Việt Nam (VAS)

| # | Chuẩn mực | Văn bản ban hành | Link | Ưu tiên | Vì sao hữu ích | XM |
|---|-----------|------------------|------|---------|----------------|----|
| 2.7 | **VAS 02 – Hàng tồn kho**; VAS 03 TSCĐ hữu hình; VAS 04 TSCĐ vô hình; **VAS 14 – Doanh thu & thu nhập khác** | QĐ 149/2001/QĐ-BTC (31/12/2001), đợt 1 | [thuvienphapluat QĐ 149](https://thuvienphapluat.vn/van-ban/Ke-toan-Kiem-toan/Quyet-dinh-149-2001-QD-BTC-bon-04-chuan-muc-ke-toan-Viet-Nam-dot-1-Hang-ton-khoTai-san-co-dinh-huu-hinh-vo-hinh-Doanh-thu-nhap-khac-48964.aspx) · [Bộ Tư pháp](https://moj.gov.vn/vbpq/lists/vn%20bn%20php%20lut/view_detail.aspx?itemid=22050) | **Phải đọc (VAS 02)** | VAS 02 định nghĩa giá gốc HTK, chi phí chế biến, phân bổ chi phí SXC cố định theo công suất bình thường, các phương pháp tính giá xuất (đích danh, bình quân gia quyền, FIFO — **không có LIFO**), dự phòng theo giá trị thuần có thể thực hiện → **spec trực tiếp cho engine giá vốn**. | ✔ |
| 2.8 | **VAS 01 – Chuẩn mực chung**; VAS 10 (tỷ giá); VAS 15 (HĐ xây dựng); VAS 16 (chi phí đi vay); VAS 24 (LCTT); VAS 06 | QĐ 165/2002/QĐ-BTC (31/12/2002), đợt 2 | [thuvienphapluat QĐ 165](https://thuvienphapluat.vn/van-ban/Ke-toan-Kiem-toan/Quyet-dinh-165-2002-QD-BTC-sau-06-chuan-muc-ke-toan-Viet-Nam-50537.aspx) · [chinhphu.vn](https://chinhphu.vn/default.aspx?pageid=27160&docid=11581) | Phải đọc (VAS 01), Nên đọc (VAS 10, 24) | VAS 01: nguyên tắc dồn tích, phù hợp, giá gốc, nhất quán. VAS 10: đánh giá lại ngoại tệ cuối kỳ. VAS 24: báo cáo lưu chuyển tiền tệ. | ✔ |
| 2.9 | **VAS 21 – Trình bày BCTC**; VAS 05, 07, 08, 25, 26 | QĐ 234/2003/QĐ-BTC (30/12/2003), đợt 3 | [thuvienphapluat QĐ 234](https://thuvienphapluat.vn/van-ban/Ke-toan-Kiem-toan/Quyet-dinh-234-2003-QD-BTC-cong-bo-sau-06-Chuan-muc-ke-toan-Viet-Nam-dot-3-53084.aspx) | Nên đọc | Cấu trúc & nguyên tắc trình bày BCTC. | ✔ |
| 2.10 | VAS 29 – Thay đổi chính sách KT, ước tính KT và sai sót (QĐ 12/2005/QĐ-BTC); TT 161/2007/TT-BTC hướng dẫn 16 chuẩn mực | — | (chưa kiểm tra link) | Tham khảo | Xử lý đổi phương pháp tính giá xuất kho, điều chỉnh hồi tố. | ⚠ |

### 2.3 Hóa đơn điện tử & thuế liên quan HTK / giá vốn

| # | Văn bản | Hiệu lực | Link | Ưu tiên | Vì sao hữu ích | XM |
|---|---------|----------|------|---------|----------------|----|
| 2.11 | **NĐ 123/2020/NĐ-CP** về hóa đơn, chứng từ (gốc) | 2020 | (xem tích hợp trong văn bản hợp nhất trên thuvienphapluat — link chưa kiểm tra) | Phải đọc | Định dạng, thời điểm lập HĐĐT, xử lý sai sót. | ⚠ link |
| 2.12 | **NĐ 70/2025/NĐ-CP** sửa đổi NĐ 123 | 20/03/2025; HL 01/06/2025 | [xaydungchinhsach.chinhphu.vn](https://xaydungchinhsach.chinhphu.vn/nghi-dinh-70-2025-nd-cp-sua-doi-bo-sung-quy-dinh-ve-hoa-don-chung-tu-11925032321512617.htm) · [baochinhphu.vn](https://baochinhphu.vn/nhung-noi-dung-moi-cua-nghi-dinh-so-70-2025-nd-cp-ve-hoa-don-chung-tu-102250903091616929.htm) | **Phải đọc** | Thời điểm lập hóa đơn (vd. xuất khẩu), HĐ khởi tạo từ máy tính tiền, chứng từ khấu trừ TNCN điện tử. | ✔ |
| 2.13 | **TT 32/2025/TT-BTC** (thay thế TT 78/2021) | 31/05/2025; HL 01/06/2025 | [FAST tóm tắt](https://fast.com.vn/thong-tu-32-2025-tt-btc-quy-dinh-moi-ve-hoa-don-chung-tu/) · [luatminhkhue](https://luatminhkhue.vn/van-ban/thong-tu-32-2025-tt-btc.aspx) | Phải đọc | Chuẩn dữ liệu HĐĐT, mẫu tờ khai — cần cho module bán hàng/tích hợp nhà cung cấp HĐĐT. | ✔ (link TVPL gốc ⚠) |
| 2.14 | **Luật Thuế GTGT 48/2024/QH15** | HL 01/07/2025 | [thuvienphapluat](https://thuvienphapluat.vn/van-ban/Thue-Phi-Le-Phi/Luat-Thue-gia-tri-gia-tang-2024-so-48-2024-QH15-556390.aspx) | Phải đọc | Thuế suất, khấu trừ đầu vào (thanh toán không dùng tiền mặt từ 5 triệu đồng), hàng tiêu dùng nội bộ, khuyến mại → bút toán thuế khi xuất kho. | ✔ |
| 2.15 | **NĐ 181/2025/NĐ-CP** hướng dẫn Luật Thuế GTGT | 01/07/2025 | [thuvienphapluat](https://thuvienphapluat.vn/van-ban/Thue-Phi-Le-Phi/Nghi-dinh-181-2025-ND-CP-huong-dan-Luat-Thue-gia-tri-gia-tang-646124.aspx) | Phải đọc | Chi tiết giá tính thuế, thời điểm xác định thuế, điều kiện khấu trừ. | ✔ |
| 2.16 | **Luật Thuế TNDN 67/2025/QH15** | HL 01/10/2025; áp dụng kỳ tính thuế 2025 | [thuvienphapluat](https://thuvienphapluat.vn/van-ban/Doanh-nghiep/Luat-Thue-thu-nhap-doanh-nghiep-2025-so-67-2025-QH15-580594.aspx) | Phải đọc | Thuế suất 15%/17%/20% theo doanh thu; chi phí được trừ (giá vốn, hao hụt HTK, dự phòng). | ✔ |
| 2.17 | **NĐ 320/2025/NĐ-CP** hướng dẫn Luật Thuế TNDN | 15/12/2025 | [thuvienphapluat](https://thuvienphapluat.vn/van-ban/Doanh-nghiep/Nghi-dinh-320-2025-ND-CP-huong-dan-Luat-Thue-thu-nhap-doanh-nghiep-665051.aspx) | Phải đọc | Điều kiện chi phí được trừ liên quan HTK (hao hụt định mức, hủy hàng, chứng từ). | ✔ |
| 2.18 | TT 48/2019/TT-BTC (trích lập dự phòng giảm giá HTK, nợ phải thu khó đòi) | — | (chưa kiểm tra; cần xác minh còn hiệu lực sau TT 99) | Nên đọc | Logic dự phòng cuối kỳ. | ⚠ |

### 2.4 Lộ trình IFRS / VFRS

| # | Văn bản | Link | Ưu tiên | Ghi chú | XM |
|---|---------|------|---------|---------|----|
| 2.19 | **QĐ 345/QĐ-BTC** (16/03/2020) phê duyệt Đề án áp dụng chuẩn mực BCTC tại Việt Nam (IFRS tự nguyện 2022–2025, bắt buộc theo lộ trình sau 2025; xây dựng VFRS) | [ifrs.vn](https://ifrs.vn/document/quyet-dinh-345-2020-7379/) · [KPMG: IFRS in Vietnam 2020](https://kpmg.com/vn/vi/home/phan-tich-chuyen-sau/2020/11/ifrs-in-vietnam-2020.html) | Nên đọc | Kiến trúc nên hỗ trợ **nhiều sổ (multi-book/multi-GAAP)** về lâu dài. | ✔ |
| 2.20 | Thông tin "TT 118/2026" về áp dụng chuẩn mực cho thành viên Trung tâm tài chính quốc tế từ 2027 | ([theleader.vn](https://theleader.vn/chuan-ifrs-va-tien-do-ap-dung-tai-viet-nam-d46077.html) — nguồn báo chí) | Tham khảo | Chỉ xuất hiện trong 1 bài báo; **chưa xác minh** văn bản gốc. | ⚠ |

---

## 3. Tài liệu MISA, FAST, Bravo (đối thủ / tham chiếu nghiệp vụ)

| # | Tài liệu | Link | Ưu tiên | Vì sao hữu ích | XM |
|---|----------|------|---------|----------------|----|
| 3.1 | **MISA SME — Tính giá xuất kho** (bình quân cuối kỳ theo kho/toàn kho, bình quân tức thời, đích danh, FIFO) | [2023](https://helpsme.misa.vn/2023/kb/html_17060000/) · [2022](https://helpsme.misa.vn/2022/kb/html_17060000/) | **Phải đọc** | Cho thấy chính xác UX & tham số (tính theo kho vs toàn công ty, tính lại khi chèn chứng từ lùi ngày) mà người dùng VN quen. | ✔ |
| 3.2 | MISA — Cách tính đơn giá vốn VTHH xuất kho; Khi tính giá xuất kho sai / không lên đơn giá; Thay đổi phương pháp tính giá xuất kho | [Cách tính](https://helpsme.misa.vn/2022/kb/cach_tinh_don_gia_von_cua_vthh_xuat_kho/) · [Lỗi thường gặp](https://helpsme.misa.vn/2023/kb/lam-the-nao-khi-tinh-gia-xuat-kho-khong-len-don-gia-von/) · [Đổi phương pháp](https://helpsme.misa.vn/2023/kb/toi-muon-thay-doi-phuong-phap-tinh-gia-xuat-kho-thi-phai-lam-the-nao/) | **Phải đọc** | Trang "lỗi thường gặp" = danh sách edge case cần test (tồn âm, chứng từ lùi ngày, trả lại hàng). | ✔ |
| 3.3 | MISA — Phân hệ Kho (mục lục) | [helpsme 2023 – 6. Kho](https://helpsme.misa.vn/2023/kb/6-kho/) | Nên đọc | Cấu trúc nghiệp vụ kho: nhập/xuất/chuyển kho/kiểm kê/lắp ráp. | ✔ |
| 3.4 | **MISA SME — Giá thành** (giản đơn, hệ số/tỷ lệ, công trình, đơn hàng, hợp đồng; phân bổ chi phí chung theo NVL TT, NC TT, chi phí trực tiếp, định mức; đánh giá dở dang) | [9.4 Giá thành 2023](https://helpsme.misa.vn/2023/kb/gia-thanh/) · [Tập hợp chi phí trực tiếp](https://helpsme.misa.vn/2022/kb/tap_hop_chi_phi_truc_tiep/) · [Giá thành gia công](https://helpsme.misa.vn/2022/kb/html_lamthenao_tinhgiathanhgiacong/) · [Định mức giá thành TP](https://helpsme.misa.vn/2019/thiet_lap_dinh_muc_gia_thanh_thanh_pham.htm) | **Phải đọc** | Đặc tả thực tế của module giá thành cần "ngang hàng MISA". | ✔ |
| 3.5 | **MISA — Khóa sổ / bỏ khóa sổ kỳ kế toán** | [2023](https://helpsme.misa.vn/2023/kb/khoa_so_ke_toan/) · [html_23050000](https://helpsme.misa.vn/2023/kb/html_23050000/) | **Phải đọc** | Mô hình "ngày khóa sổ" theo chi nhánh; chặn thêm/sửa/xóa chứng từ ≤ ngày khóa; kiểm tra chứng từ chưa hợp lệ trước khi khóa. | ✔ |
| 3.6 | MISA — Hướng dẫn nghiệp vụ (mục lục tổng) | [helpsme 2023/ac/huong_dan_nghiep_vu](https://helpsme.misa.vn/2023/ac/huong_dan_nghiep_vu/) | Nên đọc | Bản đồ toàn bộ nghiệp vụ → dùng lập backlog/feature parity. | ✔ |
| 3.7 | **Kênh YouTube MISA SME / Học MISA Online** + playlist khóa cơ bản | [@MISASME](https://www.youtube.com/@MISASME/) · [hocmisaonline](https://www.youtube.com/c/hocmisaonline) · [Playlist khóa cơ bản](https://www.youtube.com/playlist?list=PLmU34ILEVDnXavC9zPBNf9-86g69dUuYA) · [Tổng hợp kênh hỗ trợ](https://sme.misa.vn/62775/tron-bo-cac-kenh-huong-dan-su-dung-phan-mem-ke-toan-misa-sme-net/) | Nên đọc (xem) | Quan sát luồng UI thực tế theo ngành (thương mại, sản xuất, xây lắp). | ✔ |
| 3.8 | **FAST Accounting — Tính giá thành sản phẩm** (make-to-order / make-to-stock, giá thành phân đoạn, khai báo đối tượng tập hợp & phân bổ) | [fa11 help](https://fa11r09help.fast.com.vn/index.php/fa11help/tinh-gia-thanh-san-pham-trong-phan-mem-fast-accounting/) · [Các bước chạy tổng hợp](https://fa11r09help.fast.com.vn/index.php/fa11help/tinh-gia-thanh-chay-tong-hop-cac-buoc/) · [fa12: giới thiệu chung](https://fa12help.fast.com.vn/index.php/fa12help/gioi-thieu-chung-ve-cach-tinh-gia-thanh-san-xuat/) · [Phân hệ giá thành](https://fast.com.vn/phan-mem-ke-toan-fast-accounting-phan-he-ke-toan-gia-thanh-san-xuat/) | **Phải đọc** | Mô hình giá thành phức tạp hơn MISA (lệnh sản xuất, công đoạn) — tham chiếu cho thiết kế mở rộng. | ✔ |
| 3.9 | Bravo — Kế toán tổng hợp & quản trị; danh sách phân hệ (có "Tính giá thành", "Tính giá vốn hàng xuất") | [bravo.com.vn](https://www.bravo.com.vn/bravo/bravo-erp-vn/ke-toan-tong-hop-quan-tri-tren-phan-mem-bravo) | Tham khảo | Bravo không công khai help chi tiết như MISA/FAST; chủ yếu tài liệu marketing. | ✔ (nội dung hạn chế) |

---

## 4. Sách & chuẩn mực quốc tế về kế toán chi phí

| # | Tên | Tác giả | Năm / NXB | Link | Ưu tiên | Vì sao hữu ích | XM |
|---|-----|---------|-----------|------|---------|----------------|----|
| 4.1 | **Horngren's Cost Accounting: A Managerial Emphasis, 17th ed.** | Srikant M. Datar, Madhav V. Rajan | Pearson, 2020 (ISBN 9780135628478; Global Ed. 9781292363073) | [Pearson Global Ed.](https://www.pearson.com/en-gb/subject-catalog/p/horngrens-cost-accounting-a-managerial-emphasis-global-edition/P200000004493/9781292436500) | **Phải đọc** (ch. job costing, process costing, cost allocation, joint/by-products, standard costing & variances, ABC) | Chuẩn mực "vàng" về mô hình chi phí; các ví dụ số liệu dùng được làm test fixture cho engine giá thành. | ✔ |
| 4.2 | **Management and Cost Accounting, 11th ed.** | Colin Drury (+ Mike Tayles) | Cengage EMEA, 12/2020 (ISBN 978-1473773615) | [Cengage Asia](https://www.cengageasia.com/TitleDetails/isbn/9781473773615) | Nên đọc | Góc nhìn Anh/ACCA–CIMA, gần cách dạy ở VN; process costing với tương đương hoàn thành rất rõ. | ✔ |
| 4.3 | **IAS 2 Inventories** | IASB | Bản hiện hành | [ifrs.org – IAS 2](https://www.ifrs.org/issued-standards/list-of-standards/ias-2-inventories/) · [HTML 2025](https://www.ifrs.org/content/dam/ifrs/publications/html-standards/english/2025/issued/ias2.html) | Phải đọc | Gốc của VAS 02; lower of cost and NRV, cost formulas (FIFO/WAC, không LIFO). So sánh để biết điểm VAS khác IFRS. | ✔ |
| 4.4 | IFRS 15 Revenue; IAS 16 PPE; IAS 21 FX | IASB | — | [ifrs.org](https://www.ifrs.org/issued-standards/list-of-standards/) (⚠ link danh sách chưa mở) | Tham khảo | Khi hướng tới VFRS/IFRS (multi-GAAP). | ⚠ |

---

## 5. Thiết kế phần mềm kế toán / ledger

| # | Tên | Tác giả | Năm | Link | Ưu tiên | Vì sao hữu ích | XM |
|---|-----|---------|-----|------|---------|----------------|----|
| 5.1 | **Accounting for Computer Scientists** | Martin Kleppmann | 2011 | [blog](https://martin.kleppmann.com/2011/03/07/accounting-for-computer-scientists.html) | **Phải đọc** (30 phút) | Kế toán kép = đồ thị có hướng (tài khoản = node, giao dịch = cạnh); cầu nối tư duy cho dev chưa học kế toán. | ✔ |
| 5.2 | **Accounting for Developers, Part I–III** (+ ebook) | Modern Treasury | 2022– | [Part I](https://www.moderntreasury.com/journal/accounting-for-developers-part-i) · [Part II](https://www.moderntreasury.com/journal/accounting-for-developers-part-ii) · [Part III](https://www.moderntreasury.com/journal/accounting-for-developers-part-iii) · [Ebook](https://www.moderntreasury.com/resources/ebooks/accounting-for-developers) | **Phải đọc** | Từ nguyên lý → thiết kế ledger (account, entry, transaction, balance), normal balance debit/credit, immutability. | ✔ |
| 5.3 | **Analysis Patterns: Reusable Object Models** — ch. 6–7 (Inventory & Accounting, Using the Accounting Models): Account, Transaction, Posting Rule, Summary Account, Memo Account, Individual Instance Method | Martin Fowler | Addison-Wesley, 1996 | [Google Books](https://books.google.com/books/about/Analysis_Patterns.html?id=4V8pZmpwmBYC) · [Bản cập nhật "Accounting Patterns" (PDF)](https://martinfowler.com/apsupp/accounting.pdf) | **Phải đọc** (ch. 6–7) | Mẫu **Posting Rule** rất hợp với "định khoản tự động" từ chứng từ (phiếu xuất → Nợ 632/Có 156). | ✔ (PDF tải được) |
| 5.4 | Patterns of Enterprise Application Architecture — **Money** pattern; bài **Event Sourcing** | Martin Fowler | 2002 / 2005 | [PoEAA catalog](https://martinfowler.com/eaaCatalog/) · [Money](https://martinfowler.com/eaaCatalog/money.html) · [Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html) | Phải đọc (Money), Nên đọc (ES) | Money = amount + currency, **không dùng float**, phân bổ (allocate) không mất đồng lẻ. | ✔ (catalog); Money/ES link qua trích dẫn ⚠ nhẹ |
| 5.5 | **Books, an immutable double-entry accounting database service** | Square Engineering | 2019 | [developer.squareup.com](https://developer.squareup.com/blog/books-an-immutable-double-entry-accounting-database-service/) | Nên đọc | Sổ kép bất biến, dữ liệu tự nhất quán nhờ ràng buộc tổng Nợ = tổng Có. | ✔ |
| 5.6 | **Ledger: Stripe's system for tracking and validating money movement** | Stripe | 2024 | [stripe.dev](https://stripe.dev/blog/ledger-stripe-system-for-tracking-and-validating-money-movement) | Nên đọc | Log bất biến, mô hình state machine, đối soát & cảnh báo chất lượng dữ liệu → ý tưởng cho **kiểm tra số dư/đối chiếu sổ**. | ✔ |
| 5.7 | **TigerBeetle docs** — Debit/Credit: The Schema for OLTP; Transfer; two-phase transfers | TigerBeetle | hiện hành | [Debit/Credit](https://docs.tigerbeetle.com/concepts/debit-credit/) · [Transfer](https://docs.tigerbeetle.com/reference/transfer/) · [Single-page](https://docs.tigerbeetle.com/single-page/) | Nên đọc | Mô hình tối giản (accounts, transfers, 1 bất biến), ID idempotent, amount nguyên (u128) — tham chiếu schema. Không nhất thiết dùng TigerBeetle làm DB. | ✔ |
| 5.8 | **Designing Data-Intensive Applications, 2nd ed.** | Martin Kleppmann, Chris Riccomini | O'Reilly, 03/2026 | [O'Reilly](https://www.oreilly.com/library/view/designing-data-intensive-applications/9781098119058/) · [trang tác giả](https://martin.kleppmann.com/2026/03/24/designing-data-intensive-applications-2e.html) | Nên đọc (ch. transactions, isolation, derived data/event log) | Hiểu isolation level để tránh race condition khi tính giá bình quân tức thời, khóa sổ đồng thời. | ✔ |
| 5.9 | **Domain-Driven Design** | Eric Evans | Addison-Wesley, 2003 | (link chưa kiểm tra) | Nên đọc (Part IV – Strategic Design) | Bounded context: Kho, Mua hàng, Bán hàng, Giá thành, Sổ cái, Thuế/HĐĐT; context map giữa kho và sổ cái. | ⚠ link |
| 5.10 | **Implementing Domain-Driven Design** | Vaughn Vernon | Addison-Wesley, 2013 | (link chưa kiểm tra) | Nên đọc | Aggregate design (Chứng từ = aggregate; dòng định khoản), domain events cho tích hợp module. | ⚠ link |
| 5.11 | Learning Domain-Driven Design | Vlad Khononov | O'Reilly, 2021 | (link chưa kiểm tra) | Tham khảo | Bản ngắn, hiện đại hơn Evans; tốt cho dev mới. | ⚠ |
| 5.12 | Python `decimal` module docs (hoặc tương đương: Java `BigDecimal`, .NET `decimal`, PostgreSQL `numeric`) | — | — | https://docs.python.org/3/library/decimal.html (⚠ chưa mở) | Phải đọc (phần rounding) | VND không có số lẻ nhưng **đơn giá, số lượng, tỷ giá có số lẻ** → cần quy tắc làm tròn rõ (ROUND_HALF_UP vs HALF_EVEN), làm tròn ở bước nào, dồn chênh lệch làm tròn vào dòng cuối khi phân bổ. | ⚠ |
| 5.13 | Beancount — "The Double-Entry Counting Method" | Martin Blais | — | https://beancount.github.io/docs/ (⚠ chưa mở) | Tham khảo | Giải thích kế toán kép theo góc nhìn lập trình viên; mô hình lot/cost basis giống FIFO. | ⚠ |
| 5.14 | Pragmatic Engineer — "Designing a Payment System" | Gergely Orosz | — | [newsletter](https://newsletter.pragmaticengineer.com/p/designing-a-payment-system) | Tham khảo | Idempotency, ledger, đối soát. | ✔ (xuất hiện trong tìm kiếm) |

### 5.x Mã nguồn mở nên đọc như "sách"
| # | Tài liệu | Link | Ưu tiên | Vì sao | XM |
|---|----------|------|---------|-------|----|
| 5.15 | **ERPNext — FIFO and Moving Average; Perpetual Inventory; Stock Settings** | [FIFO & Moving Average](https://docs.frappe.io/erpnext/fifo-and-moving-average) · [Stock Settings](https://docs.erpnext.com/docs/user/manual/en/stock-settings) · [GitHub erpnext](https://github.com/frappe/erpnext) | **Phải đọc** | Stock Ledger Entry + "repost item valuation" khi chứng từ lùi ngày = đúng bài toán của MISA; code Python đọc được. | ✔ |
| 5.16 | **Odoo — Inventory valuation (FIFO/AVCO/Standard, automated valuation, cheat sheet)** | [Odoo 19 Inventory valuation](https://www.odoo.com/documentation/19.0/applications/finance/accounting/get_started/inventory_valuation.html) · [Valuation cheat sheet](https://www.odoo.com/documentation/19.0/applications/inventory_and_mrp/inventory/inventory_valuation/cheat_sheet.html) · [Using inventory valuation (18.0)](https://www.odoo.com/documentation/18.0/applications/inventory_and_mrp/inventory/product_management/inventory_valuation/using_inventory_valuation.html) | **Phải đọc** | Mô hình stock valuation layer → bút toán tự động (journal STJ); so sánh "perpetual real-time" với "bình quân cuối kỳ" kiểu VN. | ✔ |

---

## 6. Khóa học / chứng chỉ

| # | Khóa học | Link | Ưu tiên | Vì sao | XM |
|---|----------|------|---------|-------|----|
| 6.1 | **Frappe School — ERPNext Accounting** (miễn phí, không cần nền kế toán) | [school.frappe.io – erpnext-accounting](https://school.frappe.io/lms/courses/erpnext-accounting) · [ERPNext Essentials](https://school.frappe.io/lms/courses/erpnext-training) | Nên học | Kế toán + ERP trong cùng một khóa, có demo hệ thống. | ✔ |
| 6.2 | **Khóa cơ bản MISA SME.NET** (YouTube, miễn phí) | [Playlist](https://www.youtube.com/playlist?list=PLmU34ILEVDnXavC9zPBNf9-86g69dUuYA) | **Phải học** (PO, BA, QA) | Nắm UX chuẩn thị trường VN. | ✔ |
| 6.3 | Khóa Kế toán sản xuất – tính giá thành (Kế toán Lê Ánh: giản đơn, hệ số, tỷ lệ, định mức) | [ketoanleanh.edu.vn](https://ketoanleanh.edu.vn/khoa-hoc/khoa-hoc-ke-toan-san-xuat) | Nên học (BA/QA) | Thực hành tính giá thành bằng Excel → bộ dữ liệu kiểm thử. Không chứng thực chất lượng. | ✔ link |
| 6.4 | Khóa học kế toán giá thành kèm tư vấn (Gonnapass); khóa ĐH Bình Dương "Kế toán sản xuất – tính giá thành theo quy trình công nghệ" | [gonnapass](https://gonnapass.com/khoa-hoc-ke-toan-gia-thanh-kem-tu-van-tinh-gia-thanh/) · [BDU](https://tuyensinh.bdu.edu.vn/index.php/dao-tao-ngan-han/thong-bao-chieu-sinh-khoa-hoc-ke-toan-tong-hop-va-thuc-hanh-khai-bao-thue-577.html) | Tham khảo | Lựa chọn thay thế. | ✔ link |
| 6.5 | Odoo eLearning (Accounting, Inventory) | https://www.odoo.com/slides (⚠ chưa mở) | Tham khảo | Video ngắn về valuation. | ⚠ |
| 6.6 | Chứng chỉ chuyên sâu: ACCA (F2/MA – Management Accounting), CIMA; Chứng chỉ Kế toán viên (Bộ Tài chính) | (chưa kiểm tra link) | Tham khảo (cho domain expert, không cho dev) | Chỉ cần nếu team thiếu chuyên gia kế toán. | ⚠ |

---

## 7. Lộ trình đọc đề xuất cho dev team (4 tuần)

**Nguyên tắc**: mỗi tuần kết thúc bằng 1 sản phẩm cụ thể (tài liệu/test case/prototype); có ít nhất 1 kế toán viên (domain expert) review.

### Tuần 1 — Nền tảng kế toán kép & mô hình dữ liệu
- Đọc: 5.1 Kleppmann; 5.2 Modern Treasury Part I–II; Giáo trình Nguyên lý kế toán (1.6) — chương tài khoản, ghi sổ kép, chứng từ, tính giá.
- Xem: 6.2 Khóa cơ bản MISA SME (các video khởi tạo dữ liệu, danh mục, chứng từ).
- Lướt: TT 133/2016 (2.5) & TT 99/2025 (2.3) — chỉ phần hệ thống tài khoản và chứng từ.
- **Đầu ra**: bản nháp ERD cho Account / Journal Entry / Journal Line / Voucher; danh sách 30 bút toán mẫu (định khoản) làm test case.

### Tuần 2 — Hàng tồn kho & giá vốn
- Đọc: VAS 02 (2.7) toàn văn; IAS 2 (4.3) phần measurement & cost formulas; Giáo trình KTTC (1.1/1.4) chương NVL–CCDC & thành phẩm.
- Đọc MISA 3.1, 3.2, 3.3; ERPNext 5.15; Odoo 5.16.
- Đọc: Fowler Money (5.4) + tài liệu decimal (5.12) → chốt **chính sách làm tròn**.
- **Đầu ra**: đặc tả engine giá xuất kho (bình quân cuối kỳ theo kho/toàn công ty, bình quân tức thời, FIFO, đích danh), quy tắc tính lại khi chứng từ lùi ngày, xử lý tồn âm; bộ test số liệu tay so sánh với MISA.

### Tuần 3 — Giá thành sản xuất & khóa sổ
- Đọc: Giáo trình Kế toán chi phí UEH (1.3) — tập hợp chi phí, đánh giá SPDD, các phương pháp tính giá thành; Horngren (4.1) ch. job costing, process costing, cost allocation, joint costs.
- Đọc MISA 3.4, 3.5; FAST 3.8.
- Đọc: Luật Kế toán (2.1) phần chứng từ, sổ, sửa chữa sổ, lưu trữ.
- **Đầu ra**: đặc tả module giá thành (giản đơn, hệ số, tỷ lệ, đơn hàng/công trình — MVP chọn 2–3 phương pháp); quy trình cuối kỳ (thứ tự: tính giá xuất kho → phân bổ → tính giá thành → kết chuyển → khóa sổ); quy tắc khóa sổ.

### Tuần 4 — Kiến trúc hệ thống, thuế & hóa đơn
- Đọc: Fowler Analysis Patterns ch. 6–7 (5.3) — Posting Rule; Square Books (5.5); Stripe Ledger (5.6); TigerBeetle Debit/Credit (5.7); DDIA 2e (5.8) chương transactions/isolation; Evans DDD (5.9) phần Strategic Design.
- Đọc: NĐ 70/2025 + TT 32/2025 (hóa đơn), Luật GTGT 48/2024 + NĐ 181/2025, Luật TNDN 67/2025 + NĐ 320/2025 — chỉ phần liên quan HTK, giá vốn, khấu trừ.
- **Đầu ra**: ADR (Architecture Decision Records) về: bounded contexts & context map; ledger bất biến (sửa = bút toán đảo/điều chỉnh); posting rules cấu hình được theo chế độ kế toán (TT 99/TT 133/thông tư mới); kiểu dữ liệu tiền tệ; chiến lược tính lại giá vốn (batch vs incremental) và isolation.

### Tiếp theo (sau tuần 4)
- Drury (4.2) cho standard costing & variance; QĐ 345 (2.19) cho định hướng multi-GAAP; theo dõi thông tư thay thế TT 133 (2.6).

---

## 8. Mục chưa xác minh — cần kiểm tra lại
- Trạng thái ban hành thông tư thay thế TT 133/2016 (mới là dự thảo khi tra cứu).
- "TT 118/2026" về chuẩn mực cho Trung tâm tài chính quốc tế — chỉ thấy trên báo.
- Hiệu lực TT 48/2019 (dự phòng) sau khi TT 99/2025 có hiệu lực.
- Link chính thức: NĐ 123/2020 (thuvienphapluat), TT 32/2025 (thuvienphapluat), QĐ 12/2005 (VAS 29), TT 161/2007.
- Link nhà xuất bản cho Evans, Vernon, Khononov; docs Python decimal; Beancount; Odoo eLearning; ACCA/CIMA.
- Số chương cụ thể trong các giáo trình VN theo bản tái bản mới nhất.
