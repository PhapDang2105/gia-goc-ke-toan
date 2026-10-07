# Yêu cầu khách hàng — chuẩn hóa từ `HỆ THỐNG.docx`

> Phiên bản: v1.3 · Ngày: 2026-10-07 · Người phụ trách: BA dự án · Trạng thái: Chờ duyệt (khách chưa xác nhận)
> Nguồn duy nhất cho: **yêu cầu** (mã yêu cầu, định khoản, đợt), ánh xạ quy trình, QC, ma trận vai trò, kế thừa file Excel kho, yêu cầu phi chức năng, **truy vết yêu cầu → demo** (§11). Câu hỏi mở: [CAU-HOI-MO](CAU-HOI-MO.md). Quyết định: [QUYET-DINH](../02-ke-hoach/QUYET-DINH.md). Phạm vi theo đợt và tiến độ: [KE-HOACH-DU-AN](../02-ke-hoach/KE-HOACH-DU-AN.md). Thiết kế dữ liệu: [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md), [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md); định khoản gốc: [NGHIEP-VU-KE-TOAN](../03-thiet-ke/NGHIEP-VU-KE-TOAN.md).
> Nguồn yêu cầu: `HỆ THỐNG.docx` (gốc repo; tạo và sửa lần cuối 2026-10-06, lấy làm ngày nhận) và file Excel sổ kho bán thành phẩm của nhà máy Bà Ba Thạo (nhận 2026-10-07, không đưa vào repo).
> Viết tắt: theo [THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §2. Lịch sử: v1.1 thêm §9 (kế thừa file Excel kho); v1.2 sửa theo [PHAN-BIEN-v3](../05-phan-bien/PHAN-BIEN-v3.md) §3, thêm GT-09, GT-10, GT-R4, GT-R5, §10; v1.3 chuyển câu hỏi sang CAU-HOI-MO (mã A/B/C/D → CH-nn), quyết định sang QUYET-DINH, R1 sang THUAT-NGU; thêm §11 truy vết sang demo v4.0; cột "Demo" ở §9.2 cập nhật theo demo v4.0.

---

## 1. Tóm tắt tài liệu khách

### 1.1 Mục tiêu giai đoạn 1 (nguyên văn)

1. Hệ thống quản lý chất lượng.
2. Hệ thống số liệu, sổ sách để theo dõi được quy trình từ mua hàng → xuất hàng → giá thành ⇒ P&L.

Các phân hệ được yêu cầu "theo hệ thống tài khoản kế toán hiện hành / có hạch toán ngoại tệ".

### 1.2 Những gì tài liệu khách nói rõ

| Chủ đề | Nội dung | Hệ quả |
|---|---|---|
| Phạm vi | 10 phân hệ: Tiền, Ngân hàng, Mua hàng, Bán hàng, TSCĐ, CCDC, Kho, Giá thành, Tổng hợp, Báo cáo cuối tháng/năm | Người dùng đã chốt **cả 10 phân hệ thuộc GĐ1**. Có thể chia đợt phát hành nội bộ (1A/1B/1C) |
| Giá vốn | "Xác định tính giá vốn theo phương pháp **thực tế đích danh**" | Phương pháp giá xuất chính là đích danh **theo lô (mã lót)** |
| Giá thành | "Thẻ tính giá thành sản phẩm (đi từ NVL ban đầu, qua **nhiều giai đoạn** để tạo ra thành phẩm)" | Phân bước có tính giá bán thành phẩm (BTP) |
| Ngoại tệ | "có hạch toán ngoại tệ" | Nguyên tệ + tỷ giá trên dòng bút toán; chênh lệch tỷ giá thực hiện và đánh giá lại cuối kỳ |
| Kho | 3 địa điểm: Nhà máy Bà Ba Thạo, Bình Tây, 97 Nguyễn Thái Học; cả 3 kiểm kê cuối tháng | Nhiều kho, chuyển kho nội bộ, đối chiếu kế toán – thủ kho |
| Chất lượng | 4 QC theo khu (thủy sản, nông sản, đóng gói, hàng xay) lập **mã lót hàng** và sản xuất theo lệnh | Mã lô sinh ở xưởng, gắn với lệnh SX và điểm kiểm tra |
| Nhân sự | 16 người, có **kế toán trưởng (Ms Nhung)** | Có người duyệt đặc tả; xem §6 |
| Quy trình SX | 4 sơ đồ (mắm cá linh/sặc/chốt/trèn, mắm tôm, cá bạc má sốt cà, mắm dưa gang chay) | Ánh xạ sang công đoạn tính giá, điểm QC, điểm sinh lô — §4 |

### 1.3 Những gì tài liệu khách **không** nói (không tự suy thành yêu cầu)

- Chế độ kế toán đang áp dụng (TT99/2025 hay TT133/2016). "Hệ thống tài khoản hiện hành" có thể là một trong hai.
- Hóa đơn điện tử, tờ khai thuế, tiền lương: không có trong danh sách phân hệ. Kế hoạch v0.3 **không** đưa tích hợp HĐĐT và phân hệ lương vào GĐ1. Lương được nhập bằng chứng từ tổng hợp để có chi phí nhân công cho giá thành.
- Quy trình khu hàng xay: không có sơ đồ.
- Thời gian ủ, định mức, tỷ lệ hao hụt, tiêu chuẩn chất lượng (HACCP/ISO…): không có.
- Ai đặt hàng mua: không có vai trò "mua hàng" trong danh sách nhân sự.

### 1.4 Quyết định của người dùng ngày 2026-10-07

Chi tiết và lý do ở [QUYET-DINH](../02-ke-hoach/QUYET-DINH.md). Bảng dưới giữ mã Q1–Q5 vì các dòng yêu cầu bên dưới trích "§1.4 Qn".

| # | Quyết định | Mã quyết định | Hệ quả trong tài liệu này |
|---|---|---|---|
| Q1 | Mục tiêu trọng tâm: giá vốn theo lô, giá nguyên liệu theo lô, cây cấu thành | [QD-07](../02-ke-hoach/QUYET-DINH.md#qd-07) | GT-09, GT-10, GT-R4, GT-R5 (§3.8), đợt 1A |
| Q2 | Giá thành theo lệnh sản xuất; bán thành phẩm luôn có lô | [QD-05](../02-ke-hoach/QUYET-DINH.md#qd-05), [QD-06](../02-ke-hoach/QUYET-DINH.md#qd-06) | GT-01..GT-06, §4 |
| Q3 | Demo bỏ quy trình khóa sổ 12 bước | [QD-09](../02-ke-hoach/QUYET-DINH.md#qd-09) | Chỉ áp cho demo |
| Q4 | Sản phẩm vẫn khóa kỳ, một thao tác; kết chuyển lãi/lỗ giữ | [QD-10](../02-ke-hoach/QUYET-DINH.md#qd-10) | TH-02, TH-03 |
| Q5 | Giao diện đơn giản, không chữ thừa, không nhãn màu, không viết tắt, bo góc ≤ 2px | [QD-11](../02-ke-hoach/QUYET-DINH.md#qd-11) | NFR-01 (§10) |

---|---|---|
| Q1 | **Mục tiêu trọng tâm**: biết giá vốn hàng bán của mọi sản phẩm **theo lô** (lô này giá này, lô khác giá khác); kiểm soát giá nguyên liệu theo lô; bấm vào một lô thành phẩm thấy giá vốn được cấu thành từ những lô nguyên liệu nào, giá nào | Yêu cầu mới GT-09, GT-10, GT-R4, GT-R5 (§3.8); đưa vào đợt 1A |
| Q2 | **Giá thành tính theo lệnh sản xuất** (job-order): mỗi lệnh SX là đối tượng tập hợp chi phí; dở dang = chi phí luỹ kế của lệnh chưa hoàn thành, kể cả lệnh ủ qua nhiều kỳ; không gộp theo sản phẩm/tháng; BTP luôn có lô (phương án A của `DIEU-CHINH-THEO-KHACH-HANG.md` §4.2) | GT-01..GT-06, §4; `DIEU-CHINH-THEO-KHACH-HANG.md` §0, §4 |
| Q3 | Demo **bỏ quy trình khoá sổ 12 bước** — luôn tính lại ngay giá xuất, giá thành, giá vốn | Chỉ áp cho demo |
| Q4 | Sản phẩm thật **vẫn khoá kỳ** vì luật (TT99: phần mềm phải ngăn sửa trái phép và lưu nhật ký sửa đổi; Luật Kế toán: sổ đã khoá chỉ sửa bằng ghi bổ sung/ghi đỏ). Khoá kỳ là **một thao tác** chạy kiểm tra cân đối, không phải quy trình nhiều bước. **Kết chuyển lãi/lỗ** vẫn là yêu cầu của khách (phân hệ Tổng hợp) | TH-02, TH-03; trình tự duy nhất ở `KIEN-TRUC-VA-CSDL.md` §7.2 |
| Q5 | Giao diện **đơn giản, không chữ giải thích thừa, không nhãn màu, bo góc ≤ 2px** | NFR-01 (§10) |

---

## 2. Quy ước

- **Mã yêu cầu**: `<PHÂN HỆ>-<số>`. Phân hệ: TIEN, NH, MUA, BAN, TSCD, CCDC, KHO, GT, TH, BC; bổ sung QC (chất lượng), NT (ngoại tệ, dùng chung), NEN (nền móng, danh mục, phân quyền). Báo cáo có hậu tố `R` (vd `KHO-R3`).
- **Định khoản** viết theo TT99/2025 (logic như TT200). Cột "TT133" chỉ ghi khi khác. Số hiệu TK dùng **account role** khi cài đặt, không hardcode (`KIEN-TRUC-VA-CSDL.md` §2.3).
- Ký hiệu **(*)** sau số TK: chưa xác minh số hiệu/cấp 2 trong Phụ lục II TT99 ([THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §4.5, XM-01). Số hiệu TT200/TT133 là kiến thức chuyên môn phổ biến, chưa đối chiếu nguyên văn.
- **Đợt** (trong giai đoạn 1, theo [KE-HOACH-DU-AN](../02-ke-hoach/KE-HOACH-DU-AN.md) §3): **1A** nền móng + danh mục + kế thừa file Excel kho + kho/lô/vị trí + QC lõi + mua + bán + tiền/ngân hàng cơ bản + **lệnh SX, giá thành theo lệnh, giá vốn theo lô** + tổng hợp, kết chuyển lãi/lỗ, khoá kỳ (có mốc phát hành sớm "Kho + QC" trong 1A); **1B** đơn mua/đơn bán đầy đủ + luồng duyệt, đề nghị thanh toán, ngoại tệ phần giao dịch, QC đầy đủ; **1C** TSCĐ, CCDC, khế ước vay, đánh giá lại ngoại tệ, BCTC, LCTT. v1.1 đặt giá thành ở 1B nên 1A không khoá kỳ được theo chính quy tắc (thành phẩm chờ giá) — phản biện vòng 3, lỗi A7.
- **Cột "v0.2"** = mức có trong kế hoạch v0.2: **Có** (đã trong MVP), **Một phần**, **Thiếu** (không nhắc), **P2/P3** (đã bị đẩy sang giai đoạn sau).
- **Luật làm tròn R1** áp dụng cho mọi số tiền (nguyên văn ở [THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §5). Kiểu lưu số: [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §1.4.
- **Mã câu hỏi** `CH-nn`, `XM-nn` theo [CAU-HOI-MO](CAU-HOI-MO.md).
- **(đề xuất)** đánh dấu nội dung do bên làm phần mềm đề xuất hoặc suy ra, khách chưa nói; chờ khách/KTT xác nhận.

---

## 3. Ma trận truy vết theo phân hệ

### 3.1 Phân hệ 1 — Tiền (quỹ tiền mặt)

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| TIEN-01 | Đề nghị thanh toán | Phiếu đề nghị thanh toán / tạm ứng / thanh toán tạm ứng; **không phải chứng từ kế toán** | Không sinh bút toán. Khi chi: sinh phiếu chi (TIEN-03) hoặc UNC (NH-02) tham chiếu đề nghị | Người đề nghị, người nhận, loại đề nghị, chứng từ gốc kèm theo (HĐ mua, đơn mua), số tiền nguyên tệ/VND, hạn chi, hình thức chi, trạng thái duyệt | 1B | Thiếu | Luồng duyệt §3.1.1; cưỡng chế ở CSDL (`DIEU-CHINH-THEO-KHACH-HANG.md` §8) |
| TIEN-02 | Thu tiền | Phiếu thu: thu nợ KH, bán lẻ thu ngay (97 Nguyễn Thái Học), hoàn ứng, rút NH nhập quỹ, thu khác | Nợ 1111/1112 / Có 131, 5111/5112 + 33311, 141, 1121, 711… | Mã dòng tiền LCTT (BC-R4), đối tượng, nguyên tệ + tỷ giá nếu 1112 | 1A | Có | Thu ngoại tệ tiền mặt: NT-02 |
| TIEN-03 | Chi tiền | Phiếu chi: trả NCC, tạm ứng, chi phí, nộp tiền vào NH | Nợ 331, 141, 627/641/642 (TT133: 154/6421/6422), 1331, 1121… / Có 1111/1112 | Tham chiếu đề nghị thanh toán đã duyệt (bắt buộc theo cấu hình — đề xuất; từ 1B), mã dòng tiền | 1A | Có | Chi ngoại tệ: tỷ giá xuất quỹ (NT-03, 1B) |
| TIEN-R1 | Sổ quỹ tiền mặt | Theo quỹ, theo loại tiền: số dư đầu, thu, chi, tồn sau từng phiếu | — | Dòng bút toán TK 111x theo ngày, số CT | 1A | Có | Có cột nguyên tệ cho 1112 |
| TIEN-R2 | Nhật ký chi tiền | Liệt kê phiếu chi theo ngày, TK đối ứng | — | Như trên | 1A | Một phần (có NKC chung) | Nhật ký đặc biệt; mẫu số hiệu theo TT99 chưa xác minh |
| TIEN-R3 | Nhật ký thu tiền | Liệt kê phiếu thu theo ngày, TK đối ứng | — | Như trên | 1A | Một phần | Như trên |

#### 3.1.1 Đề nghị thanh toán — luồng duyệt (đề xuất, chờ khách xác nhận hạn mức)

```
Nháp ─gửi─► Chờ kế toán kiểm ─đủ chứng từ─► Chờ KTT duyệt ─≤ hạn mức H─► Đã duyệt ─lập phiếu chi/UNC─► Đã chi một phần ─► Đã chi
                │ thiếu chứng từ                 │ > H                       │
                └──► Trả lại (về Nháp)           └──► Chờ BOD duyệt ──────────┘
Bất kỳ bước duyệt nào: Từ chối (kết thúc) · Người lập: Huỷ khi còn Nháp/Trả lại
```

- Loại đề nghị: thanh toán NCC (theo HĐ mua / đơn mua), tạm ứng (141), thanh toán tạm ứng (hoàn ứng hoặc chi bù), chi phí không qua NCC, trả nợ vay (gốc/lãi).
- Kiểm tra khi duyệt: số đề nghị cộng dồn cho cùng HĐ mua không vượt số còn phải trả; tạm ứng mới khi người đó còn dư 141 quá hạn thì cảnh báo.
- Phân tách nhiệm vụ: người lập không được duyệt đề nghị của chính mình; người duyệt không được lập phiếu chi cho đề nghị mình duyệt (cấu hình, mặc định bật).
- Một đề nghị có thể được chi nhiều lần; một phiếu chi có thể trả nhiều đề nghị (bảng đối ứng).
- Hạn mức H, số cấp duyệt, ai trong BOD duyệt: **chưa có** — câu hỏi CH-02.

### 3.2 Phân hệ 2 — Ngân hàng (có khế ước vay)

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| NH-01 | Thu tiền | Báo có: KH chuyển khoản, giải ngân vay, lãi tiền gửi, nộp tiền mặt vào | Nợ 1121/1122 / Có 131, 341 (*), 515, 1111… | Tài khoản NH (danh mục), mã dòng tiền, nguyên tệ + tỷ giá (từ 1B) | 1A | Có | Giải ngân vay sinh từ NH-03 |
| NH-02 | Chi tiền | UNC / séc / báo nợ: trả NCC, nộp thuế, trả nợ vay, phí NH | Nợ 331, 333x, 341 (*), 335 (*), 635, 642 (phí NH; TT133: 6422)… / Có 1121/1122 | Tham chiếu đề nghị thanh toán; mã dòng tiền | 1A | Có | TK chi tiết cấp 2 cho phí NH theo quy chế nội bộ |
| NH-03 | Khế ước vay | Khai báo HĐ tín dụng / khế ước nhận nợ; giải ngân; lịch trả gốc lãi; trích lãi dồn tích; trả gốc, trả lãi | §3.2.1 | §3.2.1 | 1C (khai báo + giải ngân/trả gốc nhập tay từ 1A) | Thiếu | Ngoại tệ: đánh giá lại số dư 341 (NT-04) |
| NH-R1 | Sổ tiền gửi ngân hàng | Theo tài khoản NH × loại tiền: dư đầu, thu, chi, dư cuối; cột nguyên tệ | — | Dòng 112x có `bank_account_id` | 1A | Có | Đối chiếu sổ phụ: nhập tay số dư sổ phụ để so (đề xuất; không kết nối NH trong GĐ1) |
| NH-R2 | Theo dõi tiền vay / khế ước vay | Theo khế ước: dư gốc đầu kỳ, giải ngân, trả gốc, lãi phải trả, lãi đã trả, dư cuối; lịch đến hạn 30/60/90 ngày; phần gốc đến hạn trong 12 tháng | — | Bảng khế ước, lịch trả, giao dịch | 1C | Thiếu | Dùng để tách vay ngắn/dài hạn trên BCĐKT |

#### 3.2.1 Khế ước vay — đặc tả

- **Khai báo**: số HĐ tín dụng (hạn mức, cha) và số khế ước nhận nợ (con); ngân hàng (đối tượng 341); loại tiền; số tiền; ngày giải ngân; ngày đáo hạn; lãi suất theo giai đoạn (cố định hoặc điều chỉnh định kỳ — nhập tay mỗi lần NH thông báo); cơ sở tính lãi (ngày thực tế/365 hay /360 — chưa biết, câu hỏi CH-25); kỳ trả lãi; lịch trả gốc (đều hoặc nhập tay); mục đích (vốn lưu động / đầu tư TSCĐ — dùng cho LCTT và xét vốn hoá); tài sản bảo đảm (thông tin).
- **Giải ngân**: Nợ 1121/1122 (hoặc Nợ 331 khi NH chuyển thẳng cho NCC) / Có 3411 (*) chi tiết khế ước. LCTT: "tiền thu từ đi vay" (hoạt động tài chính; mã 33 theo B03-DN TT200, mã TT99 chưa xác minh).
- **Trích lãi dồn tích cuối tháng** (đề xuất mặc định): lãi tháng = Σ ngày (dư gốc ngày × lãi suất năm / cơ sở ngày), làm tròn theo R1(a) cho cả tháng của từng khế ước. Nợ 635 / Có 335 (*). Trả lãi: Nợ 335 (*) / Có 112. Nếu KTT chọn không trích trước: Nợ 635 / Có 112 khi trả.
- **Trả gốc**: Nợ 3411 (*) / Có 112. LCTT: "tiền trả nợ gốc vay" (mã 34 theo TT200).
- **Vay ngoại tệ**: số dư 341 là khoản mục tiền tệ có gốc ngoại tệ → đánh giá lại cuối kỳ (NT-04); trả gốc ngoại tệ sinh chênh lệch thực hiện 515/635 (NT-03).
- **Vốn hoá lãi vay** (VAS 16): chỉ khi vay cho tài sản dở dang cần thời gian dài. Với mắm ủ, chưa có thông tin thời gian ủ > 12 tháng; GĐ1 **không** tự động vốn hoá, cho phép chứng từ tổng hợp nếu KTT quyết định.
- Bút toán do hệ thống sinh từ khế ước là chứng từ hệ thống (loại riêng), xem/huỷ như chứng từ thường.

### 3.3 Phân hệ 3 — Mua hàng

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| MUA-01 | Đơn đặt hàng / HĐ mua hàng | Hợp đồng mua (khung: thời hạn, hạn mức) và đơn mua (dòng hàng, SL, giá, hạn giao, điều khoản thanh toán, kho nhận) | Không sinh bút toán. Ứng trước NCC theo đơn: Nợ 331 / Có 112 (chi tiết đơn) | NCC, loại tiền, tỷ giá dự kiến, số ngày được nợ, kho nhận; theo dõi SL đã nhận / đã nhận HĐ / đã trả lại; **giá trên đơn là mốc để kiểm soát giá lô NVL (GT-09)** | 1B | P2 | Duyệt đơn theo hạn mức (đề xuất, cấu hình như §3.1.1) |
| MUA-02 | Mua hàng / nhận hóa đơn | Phiếu nhập mua kèm HĐ; hàng về trước HĐ (giá tạm); HĐ về trước hàng (151); mua dịch vụ/chi phí; chi phí mua phân bổ; chi phí mua về sau; nhập khẩu (nếu có) | Nợ 152/153/156, 1331 / Có 331; HĐ về trước: Nợ 151 / Có 331, khi hàng về Nợ 152 / Có 151; dịch vụ: Nợ 627/641/642/242 (TT133: 154/6421/6422/242), 1331 / Có 331; nhập khẩu: thuế NK Có 3333, GTGT NK Nợ 1331 / Có 33312 | **Mỗi dòng nhập tạo hoặc chọn 1 lô** (mã lót NVL, mã hóa, NSX, HSD, vị trí chứa); kho; tham chiếu đơn mua (từ 1B); tiêu thức phân bổ chi phí mua; nguyên tệ + tỷ giá (từ 1B) | 1A | Có (trừ lô) | Lô ở trạng thái **Chờ kiểm** đến khi QC tiếp nhận đạt (QC-04). Giá lô NVL = GT-09 |
| MUA-03 | Trả lại hàng mua | Phiếu xuất trả NCC, **đích danh lô gốc** | Nợ 331 (hoặc 1388 nếu NCC hoàn tiền sau) / Có 152/153/156 (giá trị lô theo R1(c)) / Có 1331 | Phiếu nhập gốc / lô gốc (bắt buộc), SL ≤ tồn của lô tại kho, lý do (gồm "không đạt QC tiếp nhận") | 1A | Có | §3.3.1 |
| MUA-04 | Giảm giá hàng mua | Chứng từ điều chỉnh SL = 0 gắn phiếu nhập/lô gốc | Nợ 331 / Có 152/156 (phần lô còn tồn), Có 621 hoặc 154 (TT133) (phần đã xuất cho lệnh SX chưa tính giá thành), Có 632 (phần đã thành SP đã bán hoặc kỳ đã khoá), Có 1331 | Lô gốc, số tiền, HĐ điều chỉnh của NCC | 1A | Có | Với đích danh, tách phần còn tồn / đã dùng **chính xác theo lô** (khắc phục `PHAN-BIEN-v2-NGHIEP-VU.md` L7) |
| MUA-R1 | Tổng hợp công nợ phải trả NCC | Theo NCC: dư đầu, phát sinh, dư cuối; theo nguyên tệ | — | 331 theo đối tượng | 1A | Có | |
| MUA-R2 | Chi tiết phải trả NCC | Theo NCC × chứng từ; hạn thanh toán; tuổi nợ | — | Hạn thanh toán trên HĐ | 1A | Có | |
| MUA-R3 | Tổng hợp mua hàng theo mặt hàng / NCC / thời hạn thanh toán / hạn mức thanh toán | Giá trị, SL mua; phân theo hạn thanh toán; so với hạn mức | — | Hạn mức thanh toán theo NCC (ý nghĩa chưa rõ — CH-23) | 1A | Thiếu | "Hạn mức thanh toán" đang hiểu là hạn mức công nợ NCC cấp cho công ty |
| MUA-R4 | Tổng hợp trả lại hàng mua / giảm giá hàng ~~bán~~ mua | Theo NCC, mặt hàng, lô, lý do | — | MUA-03, MUA-04 | 1A | Thiếu | Tài liệu khách ghi "giảm giá hàng bán" trong phân hệ Mua — đang hiểu là **giảm giá hàng mua** (CH-23) |

#### 3.3.1 Trả lại hàng mua và giảm giá hàng mua — quy tắc

- Trả lại chỉ lấy từ **lô gốc** của phiếu nhập; không cho trả từ lô khác cùng mã hàng.
- Giá trị ghi Có kho = giá trị của lô tại kho xuất theo R1(c). Nếu lô đã được cộng chi phí mua phân bổ, phần Nợ 331 (theo giá HĐ) nhỏ hơn giá trị lô xuất ra; phần chênh lệch (chi phí mua đã phân bổ cho SL trả) đưa vào 632 hay 811 — **chưa xác minh, KTT quyết định**.
- Lô không đạt QC tiếp nhận thì không bao giờ được giải phóng (trạng thái Không đạt) và chỉ có hai lối ra: trả NCC hoặc xuất huỷ.
- Hóa đơn cho hàng trả lại / giảm giá theo NĐ 123/2020 sửa đổi bởi NĐ 70/2025: ai lập HĐ, lập HĐ điều chỉnh hay HĐ trả hàng — **chưa xác minh** (`NGHIEP-VU-KE-TOAN.md` §9 mục 6). GĐ1 chỉ lưu số HĐ, không phát hành HĐĐT.
- Giảm giá rơi vào kỳ đã khoá: ghi ở kỳ đang mở; phần lô còn tồn giảm giá trị lô, phần đã tiêu hao vào 632 (đề xuất, chờ KTT).

### 3.4 Phân hệ 4 — Bán hàng

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| BAN-01 | Đơn đặt hàng / HĐ bán hàng | Hợp đồng bán (khung) và đơn bán: KH, dòng hàng, giá, hạn giao, kho xuất, điều khoản thanh toán | Không sinh bút toán. KH ứng trước: Nợ 112 / Có 131 (chi tiết đơn) | **Hạn mức dư nợ KH**: kiểm khi duyệt đơn và khi lập HĐ (cảnh báo hoặc chặn — cấu hình); theo dõi SL đã giao / đã lập HĐ / bị trả lại | 1A (đơn tối thiểu: KH, dòng hàng, SL yêu cầu — đủ để lập phiếu xuất từ đơn, KHO-12) / 1B (giá, hạn mức, duyệt) | P2 | Vượt hạn mức cần duyệt BOD/KTT (đề xuất) |
| BAN-02 | Bán hàng / hóa đơn | Chứng từ bán kiêm xuất kho; bán lẻ thu tiền ngay tại 97 Nguyễn Thái Học; xuất gửi bán (157) nếu có | Doanh thu: Nợ 131/111/112 / Có 5111 (hàng hóa) hoặc 5112 (thành phẩm), Có 33311. Giá vốn: Nợ 632 / Có 155/156 — **giá trị của lô xuất** | Lô và vị trí xuất (gợi ý FEFO rồi lô cũ nhất — đề xuất; người dùng sửa được); chỉ cho xuất lô đã Đạt QC; số HĐ (nhập tay trong GĐ1); xuất kho qua phiếu lập từ đơn (KHO-12) | 1A | Có (trừ lô) | Hàng hoá ghi 5111, thành phẩm 5112 (lỗi B2 của demo v2 đã sửa) |
| BAN-03 | Trả lại hàng bán | Nhập lại kho **vào đúng lô gốc** của chứng từ bán | DT: Nợ 5212 (*cấp 2 TT99) / TT133: Nợ 511; Nợ 33311 / Có 131/111. Giá vốn: Nợ 155/156 / Có 632 = giá vốn đã xuất của lô gốc × SL trả / SL bán (R1(c)) | Chứng từ bán gốc (bắt buộc), kho nhận, tình trạng hàng | 1A | Có | §3.4.1 |
| BAN-04 | Giảm giá hàng bán | Chứng từ giảm trừ SL = 0 gắn HĐ gốc | Nợ 5213 (*cấp 2 TT99) / TT133: Nợ 511; Nợ 33311 / Có 131 | HĐ gốc, số tiền, lý do | 1A | Có | Không ảnh hưởng giá vốn |
| BAN-R1 | Tổng hợp công nợ phải thu KH | Theo KH: dư đầu, phát sinh, dư cuối; nguyên tệ | — | 131 theo đối tượng | 1A | Có | |
| BAN-R2 | Chi tiết công nợ phải thu KH | Theo KH × chứng từ; hạn thanh toán; tuổi nợ | — | Hạn thanh toán | 1A | Có | |
| BAN-R3 | Tổng hợp bán hàng theo mặt hàng / KH / thời hạn thanh toán, hạn mức dư nợ | SL, doanh thu, giảm trừ, (giá vốn theo lô và lãi gộp với quyền xem giá vốn); dư nợ so với hạn mức | — | Hạn mức dư nợ KH | 1A | Một phần | Giá thành theo lệnh SX cùng ở 1A nên lãi gộp đúng ngay |
| BAN-R4 | Tổng hợp trả lại hàng bán / giảm giá hàng bán | Theo KH, mặt hàng, lô, lý do | — | BAN-03, BAN-04 | 1A | Thiếu | |

#### 3.4.1 Hàng bán trả lại — quy tắc

- Bắt buộc tham chiếu chứng từ bán; nhập lại **lô gốc** với giá vốn gốc (không theo giá hiện tại). Điều này giải quyết mâu thuẫn hai "mặc định" ở `NGHIEP-VU-KE-TOAN.md` (`PHAN-BIEN-v2-NGHIEP-VU.md` L13) cho trường hợp đích danh.
- Hàng trả lại vào kho khác kho đã xuất: vẫn giữ lô gốc và giá vốn gốc.
- Hàng trả lại: người nhận chọn trạng thái QC và vị trí nhập lại; hàng kém chất lượng vào **Tạm giữ** để QC kiểm (đề xuất); nếu huỷ: Nợ 632 (hoặc 811 / 1388 theo quyết định) / Có 155/156.
- Trả lại hàng của kỳ đã khoá: ghi ở kỳ hiện tại, giá vốn vẫn là giá vốn gốc.
- Trả lại nhiều lần một dòng bán: lần trả làm hết SL còn lại nhận toàn bộ giá trị còn lại (R1(c)), không lệch 1 đồng (phản biện v3 L6). Sửa/huỷ hoá đơn đã có hàng trả lại bị chặn như huỷ (L2).

### 3.5 Phân hệ 5 — Tài sản cố định

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| TSCD-01 | Khai báo TSCĐ | Thẻ TSCĐ; khai báo số dư đầu khi chuyển từ MISA | Không sinh bút toán (số dư đầu qua chứng từ số dư) | Mã, tên, loại (hữu hình/vô hình), nhóm, bộ phận sử dụng, địa điểm (3 kho/xưởng), nguyên giá, hao mòn luỹ kế đầu, ngày bắt đầu khấu hao, thời gian sử dụng (tháng), phương pháp, TK nguyên giá/khấu hao/chi phí, đối tượng tập hợp chi phí (xưởng/khu) | 1C | P3 | |
| TSCD-02 | Ghi tăng TSCĐ | Mua sắm; hoàn thành XDCB; nhận góp vốn | Nợ 211 (*) (vô hình: 213 (*); TT133 cấp 2 của 211 chưa xác minh), Nợ 1332 / Có 331/112/241 | Chứng từ mua liên kết, biên bản giao nhận | 1C | P3 | LCTT: mua sắm TSCĐ thuộc hoạt động đầu tư |
| TSCD-03 | Khấu hao | Chạy khấu hao tháng | Nợ 627 (TT133: 154 khoản mục SXC) / 641 / 642 (TT133: 6421/6422) / Có 214 (*) | Phân bổ theo bộ phận và tỷ lệ (một tài sản dùng chung nhiều khu); khấu hao đường thẳng; tính theo ngày hay theo tháng (CH-24) | 1C | P3 (1A/1B nhập qua chứng từ tổng hợp) | Đầu vào SXC của giá thành |
| TSCD-04 | Điều chỉnh | Thay đổi nguyên giá (nâng cấp, sửa chữa lớn được vốn hoá), thay đổi thời gian sử dụng còn lại, điều chỉnh hao mòn | Nâng cấp: tập hợp Nợ 241 (*cấp 2: 2414 theo `NGHIEP-VU-KE-TOAN.md` §1.1) → Nợ 211 / Có 241 | Ngày hiệu lực; áp dụng **từ kỳ hiệu lực trở đi**, không tính lại kỳ đã khoá | 1C | P3 | |
| TSCD-05 | Điều chuyển | Chuyển bộ phận sử dụng hoặc địa điểm (giữa các xưởng/kho) | Không bút toán; từ ngày điều chuyển, chi phí khấu hao đi theo bộ phận mới | Ngày điều chuyển, bộ phận/địa điểm mới, tỷ lệ | 1C | P3 | Tháng điều chuyển: chia theo ngày hay theo tháng sau (CH-24) |
| TSCD-06 | Ghi giảm | Thanh lý, nhượng bán, mất mát, góp vốn đi | Nợ 214 (*) (HMLK), Nợ 811 (giá trị còn lại) / Có 211 (*). Thu thanh lý: Nợ 111/112/131 / Có 711, 33311. Chi phí thanh lý: Nợ 811 / Có 111. Mất chưa rõ nguyên nhân: Nợ 1381 thay 811 | Biên bản, ngày ghi giảm; khấu hao tháng ghi giảm | 1C | P3 | Duyệt BOD |
| TSCD-R1 | Sổ TSCĐ | Theo tài sản: nguyên giá, HMLK, GTCL, tăng/giảm trong kỳ, bộ phận | — | | 1C | P3 | Mẫu sổ theo chế độ; số hiệu mẫu TT99 chưa xác minh |
| TSCD-R2 | Bảng (tính và phân bổ) khấu hao TSCĐ | Theo tài sản × bộ phận × TK chi phí × đối tượng | — | | 1C | P3 | Khớp tổng PS Có 214 kỳ |

Ghi chú pháp lý: khung thời gian khấu hao, ngưỡng nguyên giá TSCĐ và cách tính khấu hao theo ngày đang theo TT 45/2013/TT-BTC (sửa đổi nhiều lần) — **tình trạng hiệu lực tại 10/2026 chưa xác minh**. Các tham số này phải là cấu hình.

### 3.6 Phân hệ 6 — Công cụ dụng cụ

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| CCDC-01 | Khai báo CCDC | Thẻ CCDC, theo **số lượng** (nhiều cái cùng mã: khay, rổ, thùng, dao…); số dư đầu | — | Mã, tên, SL, giá trị, số kỳ phân bổ, đã phân bổ, bộ phận, địa điểm, TK chi phí, đối tượng | 1C | P3 | Thùng/chum ủ là TSCĐ hay CCDC tuỳ ngưỡng giá trị (CH-24) |
| CCDC-02 | Ghi tăng CCDC | Xuất kho 153 đưa vào dùng (phân bổ nhiều kỳ) hoặc mua dùng ngay | Nợ 242 / Có 153 (giá trị lô xuất); mua dùng ngay: Nợ 242, 1331 / Có 331. Giá trị nhỏ phân bổ 1 lần: Nợ 627/641/642 (TT133: 154/6421/6422) / Có 153 | Liên kết phiếu xuất kho (KHO-02) | 1C | P3 | 242 đổi tên "Chi phí chờ phân bổ" ở TT99 (`NGHIEP-VU-KE-TOAN.md` §1.1) |
| CCDC-03 | Phân bổ | Phân bổ tháng | Nợ 627 (TT133: 154 SXC) / 641 / 642 (TT133: 6421/6422) / Có 242 | Đều theo số kỳ; kỳ cuối nhận phần còn lại (R1(a)); chia theo bộ phận (R1(b)) | 1C | P3 (nhập qua chứng từ tổng hợp trước 1C) | Đầu vào SXC |
| CCDC-04 | Điều chỉnh | Đổi số kỳ phân bổ còn lại; điều chỉnh giá trị | Từ kỳ hiệu lực | | 1C | P3 | |
| CCDC-05 | Điều chuyển | Đổi bộ phận / địa điểm sử dụng | Không bút toán; phân bổ đi theo bộ phận mới | | 1C | P3 | |
| CCDC-06 | Ghi giảm | Hỏng, mất, thanh lý (một phần SL) | Phân bổ nốt giá trị còn lại của SL ghi giảm: Nợ 627/641/642 hoặc 1388 (bắt bồi thường) / Có 242; thu thanh lý Nợ 111 / Có 711 | SL, lý do | 1C | P3 | |
| CCDC-R1 | Sổ theo dõi CCDC | Theo CCDC × bộ phận: SL, giá trị, đã phân bổ, còn lại | — | | 1C | P3 | |
| CCDC-R2 | Bảng phân bổ CCDC | Theo kỳ × bộ phận × TK chi phí × đối tượng | — | | 1C | P3 | Khớp PS Có 242 phần CCDC |

### 3.7 Phân hệ 7 — Kho

Kho vật lý: **Nhà máy Bà Ba Thạo** (NVL, bao bì, phụ gia, thành phẩm; thủ kho Mr Phú), **Bình Tây** (Ms Trâm), **97 Nguyễn Thái Học** (Mr Hải; nơi sale admin bán hàng). Có thể cần kho con tại nhà máy (NVL / bao bì / TP / khu BTP đang ủ) — câu hỏi CH-30 (đề xuất). Thêm kho ảo: "đang chuyển nội bộ", "hàng mua đi đường (151)", "hàng gửi bán (157)" nếu có.

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| KHO-01 | Lệnh sản xuất | Lệnh SX **theo công đoạn** (một lô đầu vào → một/nhiều lô đầu ra), có lệnh tổng theo kế hoạch ngày; trạng thái Kế hoạch → Phát lệnh → Đang SX (đang ủ) → Hoàn thành → Đóng | Không sinh bút toán; là **đối tượng tập hợp chi phí** | Quy trình, công đoạn, SP/BTP đầu ra, SL kế hoạch, định mức NVL (BOM theo công đoạn), khu QC phụ trách, ngày bắt đầu/dự kiến xong (ủ nhiều ngày) | 1A | Có (BOM 1 cấp, không công đoạn) | §4; cảnh báo vượt kế hoạch tính cả phiếu đang lập (phản biện v3 U6) |
| KHO-02 | Xuất kho | Theo **mục đích xuất**: cho lệnh SX; dùng chung xưởng; cho bán hàng/QLDN; CCDC đưa vào dùng; khuyến mại/mẫu; huỷ hàng; trả NCC; bán (từ BAN-02) | Có 152/153/155/156; Nợ theo mục đích: 621 (TT133: 154 NVL) chi tiết lệnh, 627 (TT133: 154 SXC), 641/642 (TT133: 6421/6422), 242, 632/811/1388 (huỷ), 331 (trả NCC), 632 (bán) | Lô và vị trí xuất (bắt buộc với hàng theo lô), kho, mục đích, lệnh SX; chặn lô chưa Đạt QC; SL yêu cầu và SL thực xuất (KHO-12); phiếu xuất huỷ cho lô Không đạt (phản biện v3 U10) | 1A | Có | Bút toán sinh theo TK đối ứng của mục đích, không mặc định 154/632 (sửa lỗi C5 của kế hoạch v0.2) |
| KHO-03 | Nhập kho | Nhập mua (từ MUA-02); nhập TP/BTP từ lệnh SX; nhập hàng bán trả lại; NVL thừa trả lại; phế liệu thu hồi; kiểm kê thừa | Nhập TP: Nợ 155 / Có 154 (BTP: xem GT-05); NVL thừa: Nợ 152 / Có 621 (TT133: 154); phế liệu: Nợ 152 / Có 154; kiểm kê thừa: Nợ 15x / Có 3381 | Lô (TP/BTP: mã lót do QC lập), mã hóa, vị trí, NSX, HSD | 1A | Có | Giá trị lô TP/BTP tính ngay khi lệnh hoàn thành (GT-05, cùng đợt) |
| KHO-04 | Chuyển kho | Phiếu xuất kho kiêm vận chuyển nội bộ; **2 bước**: kho đi xuất → kho đến xác nhận nhận (SL thực nhận); giữ nguyên lô và giá trị lô | Cùng TK kho: không đổi số dư sổ cái; chỉ chi tiết kho. Thiếu khi nhận: xử lý như kiểm kê thiếu (1381) | Kho đi, kho đến, lô, vị trí đi/đến, SL gửi, SL nhận, người xác nhận | 1A | Có (1 bước) | Hai bước là đề xuất. Có cần phát hành PXK kiêm vận chuyển nội bộ dạng điện tử khi vận chuyển giữa các địa điểm — **chưa xác minh** |
| KHO-05 | Kiểm kê (thuộc Kho, khách nêu trong nhiệm vụ thủ kho) | Phiếu kiểm kê cuối tháng theo kho × lô; chênh lệch → phiếu điều chỉnh | Thiếu: Nợ 1381 / Có 15x (xử lý: Nợ 632/1388/334 / Có 1381); thừa: Nợ 15x / Có 3381 | SL sổ sách, SL thực tế, % chênh lệch, **giải trình** (KHO-13), theo lô + vị trí | 1A | Có | Giá trị điều chỉnh tính lại ngay; cảnh báo phiếu kiểm kê lỗi thời khi có chứng từ sửa trước ngày kiểm kê (phản biện v3 U2) |
| KHO-R1 | Tổng hợp tồn kho | Theo kho × mặt hàng (× lô, × HSD tuỳ chọn): đầu, nhập, xuất, cuối (SL, GT) | — | | 1A | Có (không lô) | Tổng GT = số dư TK kho (bất biến K1) |
| KHO-R2 | Chi tiết tồn kho | Sổ chi tiết vật tư theo kho × lô: từng chứng từ | — | | 1A | Có | Thẻ kho (chỉ SL) cho thủ kho |
| KHO-R3 | Chuyển kho nội bộ | Theo phiếu: đi/đến, SL gửi/nhận, chênh lệch, đang đi đường | — | | 1A | Thiếu | |
| KHO-R4 | Tổng hợp xuất kho theo lệnh SX | Theo lệnh: định mức vs thực xuất theo NVL và lô; chênh lệch | — | BOM theo công đoạn | 1A | Thiếu | |
| KHO-R5 | Báo cáo tiến độ sản xuất | Theo lệnh/công đoạn: SL kế hoạch, đã nhận NVL, đang ủ (ngày bắt đầu, ngày dự kiến xong), hoàn thành, Đạt/Không đạt QC | — | Trạng thái lệnh, phiếu QC | 1A | Thiếu | Dữ liệu từ QC khu và kế hoạch |
| KHO-R6 | Đối chiếu nhập kho – xuất kho giữa kế toán và thủ kho | Theo kho × kỳ: chứng từ thủ kho đã xác nhận nhưng kế toán chưa ghi sổ và ngược lại; lệch SL theo mặt hàng × lô; kết quả kiểm kê | — | Mỗi chứng từ kho có 2 dấu: thủ kho xác nhận (SL thực) và kế toán ghi sổ | 1A | Thiếu | Thủ kho chỉ thấy SL |

Vị trí chứa (bồn / trái / phuy), mã hóa lô, tồn tối thiểu, tên cũ ↔ tên mới và cú pháp tên, số phiếu kho, mẫu in, lập phiếu xuất từ đơn hàng, giải trình kiểm kê, tồn đầu theo lô + bồn, báo cáo tồn theo lô + vị trí (KHO-06..14, KHO-R7..R10): §9.

### 3.8 Phân hệ 8 — Giá thành

| Mã | Tab / Báo cáo | Nghiệp vụ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| GT-01 | Quy trình SX (tham khảo quy trình khách) | Khai báo quy trình → giai đoạn tính giá → thao tác, điểm QC, điểm sinh lô | — | §4 | 1A | P2 (phân bước) | |
| GT-02 | Tập hợp chi phí trực tiếp theo lệnh công đoạn (giá thành **theo lệnh SX**, §1.4 Q2) | NVL đích danh theo lô xuất cho lệnh; BTP giai đoạn trước (đích danh lô BTP); nhân công trực tiếp | Nợ 621 / Có 152 (TT133: Nợ 154 khoản mục NVL); Nợ 622 / Có 334, 338 (TT133: 154 NC) | Lệnh SX trên mọi dòng 621/622/154 | 1A | Một phần | Lương nhập bằng chứng từ tổng hợp (không có phân hệ lương) |
| GT-03 | Phân bổ chi phí chung (SXC) | 627 (TT133: 154 SXC chưa phân bổ) phân bổ cho các lệnh **đang mở trong kỳ**, kể cả lệnh đang ủ | Kết chuyển TT99: Nợ 154 (lệnh, khoản mục) / Có 621, 622, 627. TT133: phân bổ nội bộ 154 | Tiêu thức (giờ công / SL / **khối lượng × số ngày nằm trong xưởng** cho công đoạn ủ — đề xuất); phân bổ theo R1(b) | 1A | Có (giản đơn) | Tiêu thức thật: câu hỏi CH-10 |
| GT-04 | Dở dang nhiều kỳ | Lệnh chưa hoàn thành cuối kỳ: dở dang = **toàn bộ chi phí luỹ kế** của lệnh (không cần % hoàn thành) | Số dư 154 chi tiết lệnh | Trạng thái lệnh cuối kỳ | 1A | Thiếu | Phù hợp công đoạn ủ kéo dài |
| GT-05 | Hoàn thành công đoạn, tính giá BTP/TP | Z lệnh = DDĐK + chi phí kỳ − phế liệu thu hồi − giá trị hỏng ngoài định mức; chia cho các lô đầu ra theo SL (R1(b)) | TP: Nợ 155 / Có 154. BTP nhập kho: Nợ 155 (chi tiết BTP) **hoặc** giữ 154 chi tiết BTP — **chưa xác minh**, KTT chọn (CH-11). Mọi BTP có lô và sổ kho (phương án A, §1.4 Q2); chuyển thẳng 154 không dùng ở GĐ1 | SL đầu ra Đạt, SL không đạt trong/ngoài định mức, phế liệu | 1A | P2 | `DIEU-CHINH-THEO-KHACH-HANG.md` §4. Hỏng ngoài định mức chia theo R1(b) với trọng số (SL đạt, SL ngoài định mức) — ví dụ 958.790 ở `DIEU-CHINH-THEO-KHACH-HANG.md` §4.1 |
| GT-06 | Hàng không đạt QC | Trong định mức: không bút toán riêng, Z dồn vào SL đạt. Ngoài định mức: Nợ 632 (hoặc 811 / 1388 theo quyết định xử lý) / Có 154. Huỷ TP đã nhập kho: Nợ 632/811/1388 / Có 155 | Định mức hỏng theo công đoạn (%); phiếu QC và quyết định xử lý | 1A | Thiếu | VAS 02: chi phí vượt mức bình thường không tính vào giá gốc |
| GT-07 | Giá vốn đích danh | Xuất bán / xuất dùng lô nào thì giá trị = giá trị lô đó (R1(c)) | Nợ 632 / Có 155/156 | Lô trên mọi dòng xuất | 1A | P2 | Giá lô TP tính ngay khi lệnh hoàn thành; phiếu xuất lô chưa có giá (lệnh chưa xong) bị chặn hoặc mang giá tạm tới khi lệnh xong (đề xuất: chặn) |
| GT-08 | SXC cố định dưới công suất bình thường | Phần không phân bổ → giá vốn | Nợ 632 / Có 627 (TT133: Có 154) | Công suất bình thường theo xưởng; cờ cố định/biến đổi | 1A (tuỳ chọn, tắt mặc định) | Có | Mùa vụ cá có thể làm "dưới công suất" giả nếu đo theo tháng (`PHAN-BIEN-v2-NGHIEP-VU.md` L10); hỏi CH-14 |
| GT-R1 | Thẻ tính giá thành sản phẩm | Theo **lô TP**: cây giai đoạn từ NVL ban đầu → các BTP → TP; mỗi giai đoạn: DDĐK, chi phí kỳ theo khoản mục (NVL, NC, SXC), BTP chuyển sang, DDCK, Z, z | — | | 1A | P2 | Đúng yêu cầu "đi từ NVL ban đầu qua nhiều giai đoạn" |
| GT-R2 | Tổng hợp chi phí SXKD theo đối tượng tập hợp chi phí | Theo lệnh / giai đoạn / SP / khu × khoản mục × kỳ | — | | 1A | Có | |
| GT-R3 | Lãi lỗ theo mặt hàng / lô / KH (P&L quản trị) | Doanh thu thuần − giá vốn đích danh = lãi gộp | — | | 1A | Thiếu | Đề xuất, suy ra từ mục tiêu 2 "⇒ P&L"; không có tên trong bảng phân hệ |
| GT-09 | **Giá nguyên liệu theo lô** (mục tiêu trọng tâm, §1.4 Q1) | Mỗi lô NVL có giá lô = (thành tiền HĐ theo VND + chi phí mua phân bổ ± điều chỉnh về sau) / SL nhập. Kiểm soát giá: so giá lô với lô gần nhất cùng mặt hàng (cùng NCC) và với giá trên đơn mua; vượt ngưỡng % theo nhóm hàng thì cảnh báo khi ghi phiếu nhập | — (giá lô là giá trị dòng nhập, không bút toán riêng) | Lô NVL, NCC, phiếu nhập, chi phí mua phân bổ, lịch sử điều chỉnh giá trị lô; ngưỡng % theo nhóm hàng (đề xuất, chờ khách) | 1A | Thiếu | `DIEU-CHINH-THEO-KHACH-HANG.md` §4.8 |
| GT-10 | **Giá vốn theo lô và cây cấu thành** (mục tiêu trọng tâm, §1.4 Q1) | Mọi lô TP/hàng hoá có giá vốn riêng (lô này giá này, lô khác giá khác). Bấm vào một lô: cây lô TP ← lệnh SX (DDĐK, NVL, BTP, NC, SXC, phế liệu, hỏng ngoài định mức) ← các lô BTP/NVL **chính lệnh đó** đã xuất (ngày ≤ ngày nhập kho lô TP) ← lệnh tạo lô BTP ← … ← lô NVL (NCC, phiếu nhập, giá lô); mỗi nút có SL dùng và giá trị; tổng các nhánh = giá trị lô. Truy xuôi lô NVL → lô TP → khách hàng | Nợ 632 / Có 155/156 theo giá trị lô xuất (GT-07) | Phả hệ lô theo lệnh, sổ kho theo lô, bảng giá thành lệnh | 1A | Thiếu | NC/SXC và một lô BTP cấp cho nhiều lệnh chia theo tỷ lệ SL, không đích danh — phải nói rõ với khách. `DIEU-CHINH-THEO-KHACH-HANG.md` §4.5, §4.8 |
| GT-R4 | Bảng giá nguyên liệu theo lô | Theo mặt hàng × lô: NCC, ngày nhập, SL, giá HĐ, chi phí mua, điều chỉnh, giá lô, chênh lệch % so với lô trước và với giá đơn mua; lọc nhóm hàng, NCC, khoảng ngày | — | GT-09 | 1A | Thiếu | |
| GT-R5 | Giá vốn hàng bán theo lô | Theo HĐ bán × lô xuất: SL, giá vốn lô, doanh thu, lãi gộp; tổng theo lô, mặt hàng, khách hàng, kỳ; từ mỗi dòng mở cây GT-10 | — | GT-10 | 1A | Thiếu | Thay cho câu hỏi "giá vốn sản phẩm này bao nhiêu" bằng "giá vốn lô này bao nhiêu" |

### 3.9 Phân hệ 9 — Tổng hợp

| Mã | Tab / Báo cáo | Nghiệp vụ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| TH-01 | Chứng từ nghiệp vụ khác | Hạch toán tổng hợp: lương và trích theo lương, khấu hao/phân bổ (trước 1C), bù trừ công nợ, thuế, điều chỉnh | Theo nhập liệu; ràng buộc: TK kho không được hạch toán tay (K2); TK chi phí SX bắt buộc lệnh/khoản mục (I6) | | 1A | Có | |
| TH-02 | Kết chuyển lãi / lỗ | Kết chuyển giảm trừ DT, DT thuần, DT tài chính, thu nhập khác, giá vốn, chi phí, thuế TNDN, lãi lỗ → 911 → 4212 | Bảng kết chuyển **theo chế độ** (TT133: không 521, dùng 6421/6422, 821) | | 1A | Có | Yêu cầu của khách, giữ (§1.4 Q4). Chứng từ hệ thống chạy lại được; tự đánh dấu cần chạy lại khi có chứng từ mới trong kỳ |
| TH-03 | Khoá kỳ (ngầm định, bắt buộc theo luật — §1.4 Q4) | **Một thao tác** của KTT theo **kỳ (tháng)**: hệ thống chạy kiểm tra cân đối (Nợ = Có, mọi lô có giá, không tồn âm, kết chuyển đã chạy lại, kỳ trước đã khoá…), đạt thì khoá; mở khoá chỉ KTT, bắt buộc lý do, ghi nhật ký. Giá xuất, giá thành, giá vốn tính lại ngay khi có chứng từ nên không có bước tính giá cuối kỳ | — | Trình tự và điều kiện: `KIEN-TRUC-VA-CSDL.md` §7.2 (nguồn duy nhất) | 1A | Có | v1.1 ghi "quy trình khoá sổ có thứ tự, đủ bước ở 1C" — bỏ |
| TH-R1 | Sổ nhật ký chung | | — | | 1A | Có | Số hiệu mẫu sổ TT99 chưa xác minh |
| TH-R2 | Sổ cái | | — | | 1A | Có | |
| TH-R3 | Sổ chi tiết các tài khoản | Theo TK × đối tượng / lệnh / khế ước / loại tiền | — | | 1A | Có | |

### 3.10 Phân hệ 10 — Báo cáo cuối tháng / năm

| Mã | Báo cáo | Nội dung | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|
| BC-R1 | Báo cáo KQHĐKD | B02 theo chế độ | PS đối ứng 911 | 1C (bản quản trị tháng từ 1A) | Có | |
| BC-R2 | Bảng cân đối số phát sinh | Mọi TK: dư đầu, PS, dư cuối; TT133 nộp kèm BCTC dạng "Bảng cân đối tài khoản" (F01-DNN theo `NGHIEP-VU-KE-TOAN.md`) | | 1A | Có | |
| BC-R3 | Bảng cân đối kế toán | B01 theo chế độ. `NGHIEP-VU-KE-TOAN.md` §1.1 ghi TT99 đổi tên thành "Báo cáo tình hình tài chính" (nguồn thứ cấp, chưa đối chiếu nguyên văn). Giữ tên khách dùng trên menu, in đúng tên mẫu theo chế độ | Mapping chỉ tiêu; 131/331 lấy số dư chi tiết theo đối tượng; vay tách ngắn/dài hạn theo lịch trả | 1C | Có | Mã chỉ tiêu TT99 chưa xác minh |
| BC-R4 | Báo cáo lưu chuyển tiền tệ (trực tiếp / gián tiếp) | Cả hai phương pháp | §3.10.1 | 1C | P2 | |
| BC-R5 | Thuyết minh BCTC | Không có trong tài liệu khách nhưng là bộ phận của BCTC năm | | 1C (khung + nhập tay), câu hỏi CH-27 | P2 | |

#### 3.10.1 LCTT — đặc tả

- **Trực tiếp**: mọi dòng bút toán vào TK tiền (111, 112, và 113 nếu dùng) mang **mã dòng tiền**. Hệ thống gợi ý theo TK đối ứng (Có 131 → thu tiền bán hàng; Nợ 331 → trả NCC; Nợ 334 → trả người lao động; Nợ 335/635 lãi vay → lãi vay đã trả; Có 341 → thu từ đi vay; Nợ 341 → trả nợ gốc; Nợ 211/241 → mua sắm TSCĐ…); người lập sửa được. Chuyển tiền nội bộ (111↔112, giữa các tài khoản NH) mang mã "nội bộ" và bị loại. Bút toán có nhiều TK đối ứng phải tách dòng tiền theo từng đối ứng.
- **Gián tiếp**: từ lợi nhuận trước thuế, điều chỉnh khoản không bằng tiền (khấu hao, dự phòng, chênh lệch tỷ giá **chưa thực hiện** do đánh giá lại, lãi/lỗ hoạt động đầu tư, chi phí lãi vay), biến động vốn lưu động (phải thu, HTK, phải trả **không gồm** phải trả mua TSCĐ và lãi vay, chi phí trả trước), lãi vay đã trả, thuế TNDN đã nộp. Công thức là cấu hình theo chế độ.
- Kiểm tra bắt buộc: lưu chuyển thuần của hai phương pháp bằng nhau; tiền cuối kỳ = số dư TK tiền trên BCĐKT (bất biến B4), có dòng "ảnh hưởng thay đổi tỷ giá" cho số dư tiền ngoại tệ đánh giá lại.
- Mã chỉ tiêu dẫn ở trên (33, 34…) theo B03-DN của TT200; mã của TT99 và B03-DNN của TT133 **chưa xác minh**.

### 3.11 Ngoại tệ (dùng chung, "có hạch toán ngoại tệ")

| Mã | Yêu cầu | Đặc tả | Đợt | v0.2 |
|---|---|---|---|---|
| NT-01 | Danh mục tiền tệ, tỷ giá theo ngày | Tỷ giá theo ngày × loại (mua / bán / chuyển khoản) × ngân hàng; nhập tay hằng ngày (không lấy tự động trong GĐ1). **Khoá tỷ giá theo ngày**: khi một ngày đã có chứng từ ghi sổ dùng tỷ giá đó hoặc ngày thuộc kỳ đã khoá thì không sửa được tỷ giá của ngày | 1B | P3 |
| NT-02 | Ghi nhận giao dịch theo tỷ giá giao dịch thực tế | Dòng bút toán lưu **nguyên tệ + tỷ giá**; VND = round(nguyên tệ × tỷ giá) theo R1(a). Mặc định tỷ giá: phải thu → tỷ giá mua; phải trả → tỷ giá bán; theo hướng dẫn TT200 về TK 413 [kiến thức chuyên môn; điều tương ứng ở TT99/TT133 chưa xác minh]. Khoản **ứng trước** cho NCC / KH trả trước: khi nhận hàng / ghi doanh thu, phần đã ứng dùng tỷ giá lúc ứng (không đánh giá lại khoản ứng trước) | 1B | P3 |
| NT-03 | Chênh lệch tỷ giá thực hiện | Thanh toán nợ / thu nợ: ghi giảm nợ theo **tỷ giá ghi sổ đích danh** của khoản nợ; xuất tiền ngoại tệ theo **tỷ giá xuất quỹ bình quân gia quyền di động** của tài khoản tiền (đề xuất; MISA có cả BQ cuối kỳ — `PHAN-TICH-MISA.md` §1). Chênh lệch: lãi Có 515, lỗ Nợ 635. Ví dụ: trả nợ USD 1.000 ghi sổ 25.000 bằng tiền gửi USD có tỷ giá xuất quỹ 25.300 → Nợ 331: 25.000.000; Nợ 635: 300.000 / Có 1122: 25.300.000 | 1B | P3 |
| NT-04 | Đánh giá lại cuối kỳ | Số dư khoản mục tiền tệ có gốc ngoại tệ (1112, 1122, 131, 331, 341, khoản phải thu/trả khác bằng ngoại tệ; **không** gồm khoản ứng trước) theo tỷ giá cuối kỳ (tài sản: tỷ giá mua; nợ phải trả: tỷ giá bán — TT200, chưa xác minh với TT99). Chênh lệch qua 413 (*): Nợ/Có 413; sau đó kết chuyển số dư thuần 413 sang 515 (lãi) hoặc 635 (lỗ). Ví dụ: phải thu KH USD 10.000 ghi sổ 25.000, tỷ giá mua cuối kỳ 25.200 → Nợ 131: 2.000.000 / Có 413; kết chuyển Nợ 413 / Có 515: 2.000.000. Tần suất (tháng hay chỉ khi lập BCTC năm) và có đảo đầu kỳ sau hay không: **chưa xác minh / chờ KTT** (CH-09) | 1C | P3 |
| NT-05 | Báo cáo theo nguyên tệ | Sổ quỹ, sổ NH, công nợ, khế ước có cột nguyên tệ; LCTT có dòng ảnh hưởng tỷ giá | 1B / 1C | P3 |

Bất biến: mỗi chứng từ cân Nợ = Có **theo VND**; nguyên tệ là thông tin phụ (`NGHIEP-VU-KE-TOAN.md` I1). Một khoản mục ngoại tệ trả hết nguyên tệ thì số dư VND của khoản đó phải về 0 (chênh lệch còn lại vào 515/635).

### 3.12 Nền móng (dùng chung, cần cho mọi phân hệ)

| Mã | Yêu cầu | Đợt | v0.2 |
|---|---|---|---|
| NEN-01 | Danh mục: TK (1 chế độ), account role, khoản mục chi phí, KH/NCC/NV/ngân hàng, VTHH (cờ theo lô, theo HSD, bắt buộc QC; tên cũ ↔ tên mới, cú pháp tên — KHO-09), ĐVT + quy đổi, kho, vị trí chứa, bộ phận, khu QC | 1A | Có (trừ lô/QC) |
| NEN-02 | Số dư đầu kỳ: TK, công nợ theo chứng từ (cả nguyên tệ), **tồn kho theo kho × lô × vị trí** (nhập từ sheet TonDau, KHO-14), dở dang 154 theo lệnh, TSCĐ/CCDC, khế ước | 1A (TSCĐ/CCDC/khế ước ở 1C) | Một phần |
| NEN-03 | Người dùng, vai trò, quyền phân hệ × thao tác × phạm vi kho / khu; nhật ký truy cập | 1A | Có (thiếu phạm vi) |
| NEN-04 | Luồng duyệt dùng chung (đề nghị thanh toán, đơn mua, đơn bán vượt hạn mức, xử lý hàng không đạt, ghi giảm TSCĐ); cưỡng chế ở CSDL: lịch sử duyệt không sửa/xoá, người lập không tự duyệt, người duyệt không lập phiếu chi cho đề nghị mình duyệt, không chi vượt đề nghị | 1B | Thiếu |
| NEN-05 | Nhật ký sửa đổi bắt buộc (gồm sửa danh mục như định mức hao hụt, loại vật tư — phản biện v3 L1), chứng từ bất biến sau ghi sổ, số CT liền mạch theo năm, khoá kỳ (TH-03) | 1A | Có |

---

## 4. Ánh xạ 4 quy trình sản xuất

### 4.1 Giả định chung (chưa được khách xác nhận)

- G1. **Giai đoạn tính giá** = nhóm thao tác kết thúc bằng một **BTP hoặc TP có thể đo đếm và có thể nằm chờ** (sau ủ, sau chiên, sau phối trộn). Thao tác ngắn liên tiếp trong cùng ngày gộp vào một giai đoạn.
- G2. **Mỗi giai đoạn chạy bằng một lệnh SX công đoạn**; lệnh nhận lô đầu vào (NVL hoặc BTP) và sinh lô đầu ra. Lệnh là đối tượng tập hợp chi phí. Lệnh tổng (kế hoạch ngày của Ms Thảo) gom các lệnh công đoạn.
- G3. **Mã lót** sinh ở 3 nơi: (1) tiếp nhận NVL (lô NVL, theo NCC + ngày); (2) bắt đầu mỗi giai đoạn có BTP nằm chờ (lô BTP, vd lô ủ); (3) đóng gói (lô TP in trên nhãn). Nếu khách chỉ đánh mã ở đóng gói thì lô BTP vẫn cần mã nội bộ do hệ thống sinh.
- G4. **Điểm QC** gồm mọi ô "Tiếp nhận – kiểm tra", "Kiểm tra" trong sơ đồ, cộng điểm kiểm tra thành phẩm trước khi giải phóng lô TP (đề xuất). Lô đầu ra của giai đoạn ở trạng thái Chờ kiểm đến khi QC kết luận.
- G5. **Ủ muối, ủ thính, ủ chượp, ủ đường** có thể kéo qua nhiều tháng → lệnh mở qua nhiều kỳ, dở dang = chi phí luỹ kế. "Bảo ôn" và "bảo quản" có thể kéo vài ngày đến vài tuần (đặc biệt với cá hộp sau tiệt trùng) — thời gian thật **chưa có** (CH-47).
- G6. Gia vị, phụ gia, bao bì, dầu ăn là NVL xuất theo lô cho lệnh của giai đoạn dùng chúng.
- G7. Hao hụt khối lượng tự nhiên (mất nước khi ủ, bỏ đầu/ruột khi sơ chế) xử lý bằng **định mức thu hồi** (yield) trong BOM giai đoạn, **khác** với SL không đạt QC.

### 4.2 Mắm cá linh / sặc / chốt / trèn (khu thủy sản — QC Ms Hằng; đóng gói — QC Ms Tú)

Sơ đồ: Tiếp nhận NL → Sơ chế NL → Ủ muối → Rửa → Ủ thính → (Massage BTP, nhánh tuỳ chọn) → Phân loại → Phối trộn → Đóng gói – dán nhãn → Bảo ôn → Thành phẩm.

| Giai đoạn tính giá | Thao tác gộp | Đầu vào | Đầu ra (lô) | Điểm QC | Sinh mã lót | Nhiều kỳ |
|---|---|---|---|---|---|---|
| GĐ0 Tiếp nhận | Tiếp nhận NL | Cá tươi (mua) | Lô NVL cá | QC tiếp nhận | Có (lô NVL) | Không |
| GĐ1 Sơ chế – ủ muối | Sơ chế NL, Ủ muối | Lô NVL cá, muối | **BTP cá ủ muối** | Sau sơ chế (đề xuất), khi kết thúc ủ | Có (lô ủ) | **Có** |
| GĐ2 Rửa – ủ thính | Rửa, Ủ thính, Massage BTP (nếu có) | BTP GĐ1, thính, (đường/gia vị?) | **BTP mắm ủ thính** | Khi kết thúc ủ | Có | **Có** |
| GĐ3 Phân loại – phối trộn | Phân loại, Phối trộn | BTP GĐ2, gia vị/phụ gia | **BTP mắm phối trộn** (có thể nhiều loại sau phân loại) | Sau phối trộn (đề xuất) | Có | Không |
| GĐ4 Đóng gói – bảo ôn | Đóng gói – dán nhãn, Bảo ôn | BTP GĐ3, bao bì, nhãn | **TP lô** | Trước giải phóng lô TP | Có (lô TP) | Có thể (bảo ôn) |

Điểm chưa rõ: "Massage BTP" là thao tác thường xuyên hay xử lý lại BTP chưa đạt (CH-51); "Phân loại" có tạo nhiều sản phẩm giá trị khác nhau không (nếu có → chia giá thành theo hệ số, CH-50); cá linh/sặc/chốt/trèn là 4 sản phẩm cùng quy trình hay trộn.

### 4.3 Mắm tôm (khu thủy sản)

Sơ đồ: Nguyên liệu → Tiếp nhận – kiểm tra → Ủ chượp → Phối trộn (+ tiếp nhận gia vị/phụ gia) → Kiểm tra → Đóng gói – dán nhãn (+ tiếp nhận bao bì) → Bảo ôn → Thành phẩm.

| Giai đoạn tính giá | Thao tác gộp | Đầu vào | Đầu ra | Điểm QC | Sinh mã lót | Nhiều kỳ |
|---|---|---|---|---|---|---|
| GĐ0 Tiếp nhận | Tiếp nhận – kiểm tra NL; tiếp nhận gia vị/phụ gia; tiếp nhận bao bì | Tôm/ruốc, muối, gia vị, bao bì (mua) | Lô NVL từng loại | QC tiếp nhận (3 điểm) | Có | Không |
| GĐ1 Ủ chượp | Ủ chượp | Lô NVL tôm, muối | **BTP chượp** | Khi kết thúc ủ (đề xuất) | Có | **Có** |
| GĐ2 Phối trộn – kiểm tra | Phối trộn, Kiểm tra | BTP chượp, gia vị/phụ gia | **BTP mắm tôm rời** | **Kiểm tra** (có trong sơ đồ) | Có | Không |
| GĐ3 Đóng gói – bảo ôn | Đóng gói – dán nhãn, Bảo ôn | BTP GĐ2, bao bì | **TP lô** | Trước giải phóng lô TP | Có (lô TP) | Có thể |

### 4.4 Cá bạc má sốt cà (khu thủy sản + nông sản + đóng gói)

Sơ đồ hai nhánh: cá (Tiếp nhận – kiểm tra → Sơ chế → Cân → Chiên (+ dầu ăn) → Làm nguội) và sốt (cà chua, hành tây: Tiếp nhận – kiểm tra → Sơ chế → Cân (+ gia vị) → Gia nhiệt → vào Làm nguội) → Đóng gói → Tiệt trùng → Bảo ôn → Kiểm tra: **Đạt** → Dán nhãn – đóng thùng → Thành phẩm; **Không đạt** → Loại bỏ.

| Giai đoạn tính giá | Thao tác gộp | Đầu vào | Đầu ra | Điểm QC | Sinh mã lót | Nhiều kỳ |
|---|---|---|---|---|---|---|
| GĐ0 Tiếp nhận | Tiếp nhận – kiểm tra cá; cà chua, hành tây | NVL mua | Lô NVL | QC tiếp nhận (2 điểm) | Có | Không |
| GĐ1a Cá chiên | Sơ chế, Cân, Chiên, Làm nguội (phần cá) | Lô cá, dầu ăn | **BTP cá chiên** | (đề xuất) sau chiên | Có (nội bộ) | Không |
| GĐ1b Sốt cà | Sơ chế, Cân, Gia nhiệt, Làm nguội (phần sốt) | Cà chua, hành tây, gia vị | **BTP sốt cà** | (đề xuất) sau gia nhiệt | Có (nội bộ) | Không |
| GĐ2 Đóng gói – tiệt trùng – bảo ôn | Đóng gói, Tiệt trùng, Bảo ôn | BTP 1a + 1b, bao bì (hộp/lon) | **TP chờ kiểm** (chưa nhãn) | **Kiểm tra sau bảo ôn**: Đạt / Không đạt → **Loại bỏ** | Có (lô TP, gán lúc đóng gói) | Có thể (bảo ôn) |
| GĐ3 Dán nhãn – đóng thùng | Dán nhãn, đóng thùng | TP đạt, nhãn, thùng | **TP lô** | — | Giữ lô GĐ2 | Không |

Đây là chỗ duy nhất trong tài liệu khách có **nhánh Không đạt → Loại bỏ** tường minh: SL loại bỏ trong định mức dồn giá vào SL đạt; vượt định mức → Nợ 632 (hoặc 811/1388) / Có 154 (GT-06). Nếu GĐ1a và GĐ1b luôn xong trong ngày, có thể gộp vào GĐ2 bằng phương án "chuyển thẳng 154" (`DIEU-CHINH-THEO-KHACH-HANG.md` §4.2).

### 4.5 Mắm dưa gang chay (khu nông sản — QC Ms Huỳnh)

Sơ đồ: Tiếp nhận NL – kiểm tra → Lật dưa – ủ muối → Kiểm tra – cắt – rửa → Ủ đường → Phối trộn (+ gia vị/phụ gia) → Cân – đóng gói – dán nhãn (+ bao bì) → Bảo quản → Thành phẩm.

| Giai đoạn tính giá | Thao tác gộp | Đầu vào | Đầu ra | Điểm QC | Sinh mã lót | Nhiều kỳ |
|---|---|---|---|---|---|---|
| GĐ0 Tiếp nhận | Tiếp nhận NL – kiểm tra; gia vị/phụ gia; bao bì | Dưa gang, muối, đường, gia vị, bao bì | Lô NVL | QC tiếp nhận | Có | Không |
| GĐ1 Ủ muối | Lật dưa – ủ muối | Lô dưa, muối | **BTP dưa muối** | Khi kết thúc ủ | Có | **Có** |
| GĐ2 Cắt rửa – ủ đường | Kiểm tra – cắt – rửa, Ủ đường | BTP GĐ1, đường | **BTP dưa ủ đường** | **Kiểm tra** (có trong sơ đồ, trước cắt) | Có | **Có** |
| GĐ3 Phối trộn – đóng gói – bảo quản | Phối trộn, Cân – đóng gói – dán nhãn, Bảo quản | BTP GĐ2, gia vị, bao bì | **TP lô** | Trước giải phóng lô TP | Có (lô TP) | Có thể |

### 4.6 Khu hàng xay (QC Ms Trâm)

Không có sơ đồ. Chưa ánh xạ được. Cần quy trình (CH-49).

---

## 5. Phân hệ Quản lý chất lượng (mục tiêu số 1 của khách)

### 5.1 Phạm vi đề xuất cho GĐ1

| Mã | Yêu cầu | Mô tả | Đợt |
|---|---|---|---|
| QC-01 | Điểm kiểm soát theo công đoạn | Danh mục điểm kiểm tra gắn với thao tác trong quy trình (§4) và với tiếp nhận mua; mỗi điểm có khu phụ trách, có là điểm tới hạn hay không (nếu khách có HACCP), quy tắc lấy mẫu | 1A (tiếp nhận) / 1B (công đoạn) |
| QC-02 | Bộ chỉ tiêu | Mỗi điểm có danh sách chỉ tiêu: tên, đơn vị, kiểu (số đo có giới hạn min/max, Đạt/Không đạt, ghi chú), bắt buộc hay không, hiệu lực theo ngày | 1A |
| QC-03 | Mã lót hàng (mã lô) | Sinh theo mẫu cấu hình (vd mã SP + ngày + khu + số thứ tự); gắn với lệnh SX hoặc phiếu nhập mua; NSX, HSD; in phiếu/nhãn lô (chưa quét mã vạch trong GĐ1 — đề xuất) | 1A |
| QC-04 | Phiếu kiểm tra | Theo lô × điểm: người kiểm, thời điểm, kết quả từng chỉ tiêu, SL kiểm / đạt / không đạt, kết luận **Đạt / Không đạt**, ảnh và phiếu kết quả kiểm nghiệm đính kèm. Phiếu đã chốt không sửa, chỉ huỷ có lý do | 1A |
| QC-05 | Trạng thái lô và chặn sử dụng | Lô: Chờ kiểm → Đạt (được xuất dùng/bán) / Không đạt / Tạm giữ. Hệ thống **chặn** xuất SX, xuất bán, xuất dùng/khuyến mại đối với lô Không đạt hoặc Tạm giữ (mọi mặt hàng) và lô Chờ kiểm (nhóm hàng bật "bắt buộc QC"); trạng thái chỉ đổi qua phiếu kiểm chốt hoặc quyết định xử lý; hàng trả lại chọn trạng thái QC và vị trí khi nhận (phản biện v3 U9) | 1A |
| QC-06 | Xử lý hàng không đạt | Quyết định: loại bỏ (huỷ) / làm lại / trả NCC / hạ cấp / chấp nhận có điều kiện; phân loại trong / ngoài định mức; duyệt bởi trưởng QC (vượt giá trị → KTT/BOD); sinh chứng từ kho/giá thành tương ứng (GT-06, MUA-03) | 1B |
| QC-07 | Truy xuất ngược và xuôi | Ngược: lô TP → lô BTP các giai đoạn → lô NVL → NCC, phiếu nhập, phiếu QC. Xuôi: lô NVL → mọi lô BTP/TP đã dùng → KH đã mua, SL, ngày (phục vụ thu hồi sản phẩm) | 1B (ngược 1 cấp ở 1A) |
| QC-08 | Hạn sử dụng | HSD theo SP (số ngày từ NSX) hoặc nhập tay; cảnh báo cận hạn; gợi ý xuất FEFO; báo cáo tồn theo HSD | 1A |
| QC-R1 | Báo cáo chất lượng | Tỷ lệ đạt theo điểm/khu/SP/kỳ; danh sách lô không đạt và cách xử lý; nhật ký QC theo lô | 1B |

### 5.2 Những gì chưa rõ

Tài liệu khách không có: tiêu chuẩn áp dụng (HACCP, ISO 22000), chỉ tiêu và giới hạn từng điểm kiểm, mẫu biểu QC, quy tắc mã lót, kiểm nghiệm bên ngoài, giám sát thiết bị. Hai ảnh quy trình trong tài liệu khách có tiêu đề mục ("III. Qui trình sản xuất") và số trang, gợi ý được trích từ một bộ hồ sơ sản phẩm hoặc hồ sơ chất lượng có sẵn — chưa xác minh. Câu hỏi: [CH-44](CAU-HOI-MO.md#ch-44), [CH-52](CAU-HOI-MO.md#ch-52), [CH-53](CAU-HOI-MO.md#ch-53). Giai đoạn 1 chỉ nhập tay, không kết nối thiết bị.

---

## 6. Ma trận vai trò

### 6.1 Người → vai trò hệ thống

| # | Người | Chức danh (khách) | Vai trò hệ thống | Phạm vi kho / khu |
|---|---|---|---|---|
| 1–3 | Mr Thiên, Ms Tuyết, Ms Kim Cương | BOD | `BOD` | Tất cả |
| 4 | Ms Nhung | Kế toán trưởng | `KTT` (kiêm quản trị nghiệp vụ hệ thống) | Tất cả |
| 5 | Ms Loan | Kế toán tổng hợp | `KT_TONGHOP` | Tất cả |
| 6 | Ms Huyền | Kế toán kho | `KT_KHO` | Tất cả kho |
| 7 | Ms Thảo | Kế hoạch | `KE_HOACH` | Nhà máy Bà Ba Thạo (xem tồn mọi kho) |
| 8 | Ms Phượng Anh | Sale admin | `SALE_ADMIN` | 97 Nguyễn Thái Học (xem tồn mọi kho, chỉ SL) |
| 9 | Ms Trâm | Thủ kho Bình Tây | `THU_KHO` | Kho Bình Tây |
| 10 | Mr Hải | Thủ kho 97 Nguyễn Thái Học | `THU_KHO` | Kho 97 Nguyễn Thái Học |
| 11 | Mr Phú | Thủ kho nhà máy Bà Ba Thạo | `THU_KHO` | Các kho tại nhà máy |
| 12 | Ms Lan | Trưởng QC | `TRUONG_QC` | Mọi khu; kho nhà máy (xem) |
| 13 | Ms Hằng | QC khu thủy sản | `QC_KHU` | Khu thủy sản |
| 14 | Ms Huỳnh | QC khu nông sản | `QC_KHU` | Khu nông sản |
| 15 | Ms Tú | QC khu đóng gói | `QC_KHU` | Khu đóng gói |
| 16 | Ms Trâm | QC khu hàng xay | `QC_KHU` | Khu hàng xay |

Có **hai người tên "Ms Trâm"** (thủ kho Bình Tây và QC hàng xay). Nếu là một người thì tài khoản đó có hai vai trò và hai phạm vi — câu hỏi CH-03. Chưa có ai giữ vai trò **quản trị hệ thống kỹ thuật** (tạo người dùng, sao lưu): đề xuất KTT quản trị nghiệp vụ, đơn vị triển khai quản trị kỹ thuật.

### 6.2 Quyền theo phân hệ × thao tác

Ký hiệu: **X** xem (kể cả giá trị) · **x** xem chỉ số lượng, không thấy giá vốn/giá trị kho · **L** lập/sửa nháp · **D** duyệt · **G** ghi sổ / bỏ ghi · **K** khoá / mở sổ · **—** không truy cập. Mọi người dùng đều được lập đề nghị thanh toán của chính mình (không ghi lại trong bảng).

| Vai trò | Tiền | Ngân hàng + khế ước | Mua | Bán | TSCĐ | CCDC | Kho | Lệnh SX | Giá thành | QC | Tổng hợp | BC tài chính | Danh mục / hệ thống |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| BOD | X, D (đề nghị > hạn mức) | X, D (khế ước) | X, D (đơn > hạn mức) | X, D (vượt hạn mức dư nợ) | X, D (ghi giảm) | X | X | X | X | X | X | X | X |
| KTT | X L D G | X L D G | X L D G | X L D G | X L D G | X L D G | X L D G | X | X L D G | X | X L D G **K** | X L D | X L D (TK, role, phân quyền) |
| KT_TONGHOP | X L G | X L G | X | X L G | X L G | X L G | X | X | X L | X | X L G | X L | X L (đối tượng) |
| KT_KHO | X (L đề nghị) | X | X L G | X L G (phần xuất kho) | X | X L (xuất CCDC) | X L D G (duyệt chứng từ thủ kho) | X | X L | X | X | X | X L (VTHH, kho) |
| KE_HOACH | — | — | x, L (đề xuất mua — giả định) | x | — | — | x | X L | — | X | — | — | x |
| SALE_ADMIN | L (phiếu thu bán lẻ, nháp) | — | — | X L (đơn, HĐ nháp) | — | — | x | — | — | x (trạng thái lô) | — | — | L (KH mới, chờ duyệt) |
| THU_KHO | — | — | x (phiếu nhập chờ nhận) | x (phiếu xuất chờ giao) | — | x | x L (xác nhận nhập/xuất/chuyển; kiểm kê) | x | — | x (trạng thái lô) | — | — | — |
| TRUONG_QC | — | — | x | — | — | — | x | X L D (phát lệnh, đóng lệnh) | x (SL, hao hụt) | X L D | — | — | X L (điểm QC, chỉ tiêu) |
| QC_KHU | — | — | x (lô chờ kiểm tiếp nhận) | — | — | — | x, L (đề nghị lĩnh vật tư) | X L (báo hoàn thành công đoạn) | — | X L (phiếu kiểm, mã lót) | — | — | — |

Quy tắc kèm theo:
- Phạm vi kho/khu ở §6.1 áp lên mọi cột: thủ kho chỉ thấy và thao tác kho mình; QC khu chỉ thấy lệnh và lô của khu mình.
- Chứng từ kho do thủ kho lập/xác nhận **số lượng**; kế toán kho duyệt và ghi sổ (sinh giá trị). Báo cáo KHO-R6 dựa trên hai dấu này.
- Phân tách nhiệm vụ: người lập không duyệt chứng từ của mình; người duyệt đề nghị thanh toán không lập phiếu chi cho chính đề nghị đó.
- Khoá / mở sổ chỉ KTT; mở sổ bắt buộc ghi lý do, ghi nhật ký.
- Ai làm mua hàng (lập đơn mua) chưa rõ — tạm giao `KE_HOACH` lập đề xuất, `KT_KHO` lập chứng từ mua; câu hỏi CH-04.

---

## 7. Câu hỏi mở

Đã chuyển toàn bộ sang [CAU-HOI-MO](CAU-HOI-MO.md) (nhóm theo người trả lời, mức chặn, mặc định khi chưa trả lời). Bảng đối chiếu mã cũ A1–A10, B1–B13, C1–C9 → `CH-nn`: [CAU-HOI-MO](CAU-HOI-MO.md) §8.

---

## 8. Giả định quan trọng (tổng hợp)

1. Lấy "phương pháp thực tế đích danh" theo nghĩa **đích danh theo lô (mã lót)** cho mọi hàng tồn kho, kể cả bao bì và phụ gia; với hàng giá trị nhỏ, hệ thống tự gợi ý lô (FEFO/lô cũ nhất) để người dùng không phải chọn tay. Nếu KTT muốn bao bì/phụ gia dùng bình quân, cần xác minh việc dùng nhiều phương pháp cho các nhóm hàng khác nhau có phù hợp VAS 02 không (**chưa xác minh**, XM-08) và kế hoạch phải ước lại. Câu hỏi: CH-16.
2. Mỗi phiếu nhập mua tạo lô mới nếu người dùng không chọn lô có sẵn.
3. Giá thành theo **lệnh SX công đoạn** (lô × giai đoạn), dở dang = chi phí luỹ kế lệnh chưa xong — **đã chốt** (§1.4 Q2); BTP luôn có lô.
4. Giai đoạn 1 không có phân hệ lương, không tích hợp HĐĐT, không kết nối ngân hàng, không ứng dụng di động ([QD-19](../02-ke-hoach/QUYET-DINH.md#qd-19)); thủ kho và QC dùng web trên máy tính/máy tính bảng.
5. Một công ty, một sổ tài chính, một chế độ kế toán; khoá kỳ theo tháng bằng một thao tác (TH-03).
6. Ngoại tệ: giả định chủ yếu USD, số nghiệp vụ ít; tỷ giá nhập tay.
7. Mỗi bồn / trái / phuy chứa một lô tại một thời điểm, trừ khi khách trả lời CH-31 khác.

---

## 9. Kế thừa file Excel kho BTP (Bà Ba Thạo)

> Nguồn: file Excel sổ kho bán thành phẩm của nhà máy Bà Ba Thạo, khách gửi ngày 2026-10-07 (xuất từ Google Sheets; không đưa vào repo). Yêu cầu người dùng kèm theo: **"Hàng tồn kho sẽ theo dõi: Tên hàng + mã lot + mã hóa + bồn/trái/phuy"** và kế thừa các tính năng của file. Tên công ty, mã số thuế, địa chỉ trong file **không** chép vào repo; demo và mẫu in dùng "Nhà máy chế biến mắm".

### 9.1 File có gì

13 sheet: tồn đầu, cú pháp tên hàng, vùng chọn (danh sách thả xuống), tồn kho, gợi ý xuất, **sổ nhập xuất** (sheet chính, 420 dòng, 88 tên hàng, 206 mã lô), gợi ý điều chỉnh (kiểm kê), tồn theo lô, mẫu in phiếu xuất kho, mẫu in phiếu nhập kho, báo cáo N-X-T, báo cáo N-X chi tiết, N-X-T thực tế. Nhiều công thức đã hỏng khi xuất file (`#REF!`, `#NAME?`) và tham chiếu tới 3 sheet không có trong file (đơn hàng, nhập kiểm kê, tồn lô phụ).

Mỗi dòng sổ nhập xuất: ngày, người thực hiện, mã đơn hàng, lý do xuất, nhóm hàng, **tên sản phẩm, mã hóa, lot, bồn**, cảnh báo, SL nhập, SL xuất, ghi chú, mã phiếu, tồn tổng, ĐVT, SL thực xuất, tồn theo lot, tồn theo lot + bồn.

### 9.2 Tính năng của file → yêu cầu → trạng thái

v1.2 sửa hai chỗ hiểu sai của v1.1 (phản biện vòng 3 §3): sheet `GoiYXuat` là **lập phiếu xuất từ đơn hàng**, không phải gợi ý lô theo HSD; mẫu in phiếu xuất/nhập có nhiều trường và chữ ký hơn v1.1 ghi. Cột "Demo v4.0" là trạng thái của `demo/gia-goc-demo.html` bản v4.0 (rà ngày 2026-10-07).

| Tính năng trong file (sheet) | Mã | Yêu cầu chuẩn hóa | Demo v4.0 | Đợt |
|---|---|---|---|---|
| Cột BỒN; tồn theo lot + bồn (`2.NXKho`) | KHO-06 | **Vị trí chứa** (khu + loại bồn / trái / phuy + số) theo kho; khoá tồn = (vật tư, kho, lô, vị trí); một lô ở nhiều vị trí; kiểm âm theo vị trí; giá trị vẫn theo lô; **cảnh báo khi nhập/chuyển một lô vào vị trí đang chứa lô khác** (phản biện vòng 3 U7; xem CH-31) | Có: 31 vị trí ở nhà máy; cảnh báo trộn lô | 1A |
| Chuyển bồn (1 dòng xuất + 1 dòng nhập) | KHO-04 (mở rộng) | Chuyển vị trí trong cùng kho bằng phiếu chuyển kho; không bút toán | Có | 1A |
| Cột MÃ HÓA | KHO-07 | Mã hóa lô do hệ thống tự sinh (đề xuất), §9.4 | Có | 1A, chờ khách duyệt định dạng (CH-45) |
| Mã LOT | KHO-03 (mở rộng) | Mã lô gợi ý `DDMMYY-nn`, sửa được, lưu chuỗi, **duy nhất theo (công ty, mặt hàng)** (§9.3) | Lệch: kiểm trùng toàn nhà máy, chưa theo mặt hàng ([QD-14](../02-ke-hoach/QUYET-DINH.md#qd-14)) | 1A |
| Tồn tối thiểu, cảnh báo "CẦN ĐẶT THÊM" (`1.TonKho`) | KHO-08 | Tồn tối thiểu trên danh mục; cảnh báo khi tồn ≤ tối thiểu (file: chỉ cảnh báo khi tồn tối thiểu > 0) | Có | 1A |
| Cảnh báo "TRÙNG" tên hàng (`1.TonKho`) | NEN-01 | Chặn trùng tên / mã khi khai danh mục | Có | 1A |
| Cột "SỐ NGÀY LƯU KHO" (`1.TonKho`) | KHO-R7 | **Chưa rõ nghĩa** — cột trống toàn bộ 156 dòng; có thể là (a) số ngày tối đa được lưu (ngưỡng cảnh báo tồn lâu) hoặc (b) số ngày đã lưu tính từ "NGÀY NHẬP ĐẦU TIÊN" (cột cạnh bên). Hỏi CH-39 | Có cột (b), giả định | 1A, chờ CH-39 |
| Sheet `CuPhapTen`: **tên cũ ↔ tên mới**, cú pháp tên 13 thuộc tính, mã MISA tương ứng | KHO-09 | §9.8: danh mục lưu tên cũ (tên đang dùng trên đơn hàng / MISA) và tên chốt theo cú pháp; tìm theo cả hai; phiếu xuất in cả hai; cột Mã MISA | Có cột Mã MISA (giả định); cú pháp tên chưa làm | 1A |
| Số phiếu PNK / PXK theo tháng | KHO-10 | Số phiếu kho `PNK-YYMMnnn` / `PXK-YYMMnnn` bên cạnh số chứng từ kế toán. File có hai kiểu (`PXK-MMYY-nnn` ở ô đầu sheet, `PXK-YYMMnnn` ở cột gợi ý mã phiếu) — hỏi CH-35 | Có | 1A |
| Lý do xuất (Xuất sản xuất / bán hàng / kho Bình Tây / kho 97) | KHO-02 (mở rộng) | Lý do xuất suy ra từ loại chứng từ: Sản xuất, Bán hàng, Chuyển kho Bình Tây, Chuyển kho 97, Chuyển vị trí, Huỷ, Khác | Có | 1A |
| ĐVT Kg / Cái / Hũ / Chai / Can | NEN-01 | Danh mục ĐVT, số lẻ theo ĐVT (`KIEN-TRUC-VA-CSDL.md` §1.4) | Có | 1A |
| `GoiYXuat`: **lập phiếu xuất từ đơn hàng** | **KHO-12** | §9.9: chọn đơn (bán, hoặc yêu cầu chuyển kho Bình Tây / 97) → hệ thống điền các dòng đơn còn chưa xuất với **SL yêu cầu**; người lập chọn lô + vị trí (tách một dòng đơn thành nhiều lô/bồn); thủ kho xác nhận **SL thực xuất**; tồn, giá vốn theo SL thực xuất; dòng đơn còn thiếu vẫn mở. Gợi ý lô theo HSD rồi lô cũ nhất là **đề xuất riêng** (QC-08), không phải chức năng của sheet này | Chưa (demo không có đơn hàng); có gợi ý lô theo HSD rồi lô cũ nhất | 1A (đơn tối thiểu) |
| Cột "SỐ LƯỢNG THỰC XUẤT" (`2.NXKho`) | KHO-12 | File: SL xuất ghi nhận = SL thực xuất nếu có, không thì SL xuất; tồn và mọi báo cáo dùng SL ghi nhận. Hệ thống: phiếu xuất có SL yêu cầu (từ đơn) và SL thực xuất (thủ kho xác nhận); chênh lệch phải chọn lý do (CH-36) | Một phần: phiếu xuất in hai cột SL yêu cầu / SL thực xuất nhưng chưa nhập riêng (hai cột bằng nhau) | 1A |
| `GoiYDieuChinh`: kiểm kê theo tên + lot + bồn, % chênh lệch, **giải trình** | KHO-05, **KHO-13** | Phiếu kiểm kê theo lô **và vị trí**: tồn sổ, SL đếm, chênh lệch, % chênh lệch, **giải trình từng dòng** (bắt buộc khi vượt ngưỡng % — đề xuất, CH-22); lập phiếu nhập/xuất điều chỉnh mang giải trình vào ghi chú; cảnh báo phiếu kiểm kê lỗi thời khi có chứng từ sửa trước ngày kiểm kê | Có % chênh lệch, cảnh báo phiếu kiểm kê lỗi thời, in biên bản kiểm kê; chưa có giải trình bắt buộc | 1A |
| `TonDau`: nhập tồn đầu theo tên + **lot + bồn** | **KHO-14** | Nhập tồn đầu kỳ (khi chuyển đổi) theo kho × mặt hàng × lô × vị trí, từ Excel theo đúng cột của sheet (ngày, người, nhóm hàng, tên SP, lot, bồn, SL, ghi chú); lô `OPENING`; giá trị tồn đầu theo lô do KTT duyệt ([CH-07](CAU-HOI-MO.md#ch-07)). Sheet trong file đang trống | Một phần: dữ liệu mẫu có tồn đầu theo lô + vị trí; chưa nhập từ Excel | 1A |
| `3.TonLot`: tồn cuối theo SP tách theo lot | KHO-R7 | Bảng **Tồn kho chi tiết**: tên hàng · mã lô · mã hóa · vị trí · kho · HSD · QC · SL · số ngày lưu kho (CH-39) · giá trị; lọc, tìm, cộng theo tên hàng | Có | 1A |
| `6.BCNXT`: N-X-T theo SP + lot, khoảng ngày | KHO-R8 | N-X-T theo lô và vị trí trong khoảng ngày: tồn đầu (trước ngày bắt đầu), nhập, xuất, tồn cuối, lọc kho; chỉ liệt kê lô còn tồn hoặc có phát sinh. File tính tồn đầu bằng SL xuất **chưa** thay bằng SL thực xuất nên lệch với tồn thực tế khi có SL thực xuất — hệ thống dùng một định nghĩa (SL ghi nhận) | Có | 1A |
| `8.BCNXTThucTe`: N-X-T **thực tế lũy kế** | **KHO-R10** | Theo tên hàng + lot (+ vị trí): tổng nhập, tổng xuất (theo SL thực xuất), tồn — **lũy kế từ đầu, không lọc ngày**; dùng để đối chiếu tồn đang có với kiểm kê | Chưa | 1A |
| `7.BCNXChiTiet`: N-X chi tiết một SP | KHO-R9 | Sổ chi tiết một mặt hàng theo lô + vị trí, khoảng ngày, có tồn theo ô và tồn tổng | Có | 1A |
| `4.InPXKMoi`, `5.InPNK`: mẫu in | KHO-11 | §9.10: đủ trường và chữ ký như file; thêm mẫu 01-VT / 02-VT theo chế độ (có đơn giá, thành tiền) cho kế toán | Có (phiếu nhập kho, phiếu xuất kho, phiếu xuất kho kiêm vận chuyển nội bộ, biên bản kiểm kê; có đơn giá, thành tiền, tiền bằng chữ). Còn thiếu: tên hàng cũ / mới, mã đơn hàng, SL đặt hàng thật, thông tin giao hàng đủ; chữ ký phiếu nhập kho khác mẫu khách (§9.10) | 1A |
| Người thực hiện, mã đơn hàng trên từng dòng | NEN-05 / BAN-01 | Người lập ghi tự động từ phiên đăng nhập; mã đơn hàng từ KHO-12 | Người lập: có; đơn hàng: chưa | 1A |

### 9.3 Quy ước mã lô

- Định dạng trong file: `DDMMYY-n` hoặc `DDMMYY-nn` (ngày nhập / sản xuất + số mẻ; 116 mã), `DDMMYY` không có số mẻ (53 mã), và 37 mã dạng khác (`6232-4`, `6248-03`, `10724`, `40624`…). `10724`, `40624` nhiều khả năng là `010724`, `040624` bị Excel bỏ số 0 đầu.
- **Quy tắc chốt (đề xuất, một nguồn với `DIEU-CHINH-THEO-KHACH-HANG.md` §2.1):** mã lô gợi ý `DDMMYY-nn` (ngày nhập / ngày bắt đầu lệnh + số mẻ 2 chữ số đếm trong ngày theo mặt hàng), **sửa được**, chỉ nhận chữ, số, `-`, `.` (3–20 ký tự), lưu dạng chuỗi (không mất số 0 đầu); **duy nhất theo (công ty, mặt hàng)**; mã đã cấp không cấp lại kể cả khi huỷ phiếu. Nhiều dòng cùng mã lô trong một phiếu = một lô ở nhiều vị trí (hệ thống tự chia phần SL còn lại khi thêm vị trí — phản biện v3 U8).
- Lý do chọn "theo mặt hàng" chứ không "toàn công ty": trong file có **16 mã lô dùng chung cho 2–4 mặt hàng khác nhau** (thường là các BTP làm cùng ngày). Bắt duy nhất toàn công ty sẽ chặn dữ liệu thật. Mã duy nhất toàn công ty là **mã hóa** (§9.4). Demo v3.2 kiểm trùng toàn công ty — phải sửa theo quy tắc này. Khách xác nhận ở CH-46.
- Chưa rõ: dạng `6232-4`, `6248-03` có nghĩa gì; lô `DDMMYY` không số mẻ có còn dùng không (CH-46).

### 9.4 Mã hóa

- **Bối cảnh từ file**: mã hóa là một cột riêng; công thức cảnh báo so `RIGHT(LOT, 2)` với mã hóa ("KIỂM TRA MÃ LOT") và cột "mã SP = tên hàng + 2 số cuối lot". Trong file cột mã hóa **trống toàn bộ** 420 dòng. Ý nghĩa nghiệp vụ của mã hóa **chưa xác minh**.
- **Đề xuất (theo ý người dùng: "mã hóa có thể là 1 mã tự sinh ra trong hệ thống")**: hệ thống tự sinh mã hóa khi tạo lô (phiếu nhập mua, nhập kho sản xuất, kiểm kê thừa ngoài sổ), định dạng **nhóm hàng + YYMM + số thứ tự 4 chữ số** (`NL`, `PG`, `BB`, `BTP`, `TP`, `HH`; ví dụ `BTP-2601-0003`): ngắn, ghi tay và in lên phiếu được; duy nhất toàn công ty; không sửa tay; không đổi khi chuyển kho / chuyển bồn; không cấp lại khi huỷ phiếu. Hiển thị ở danh sách chọn lô, Tồn kho chi tiết, sổ chi tiết, báo cáo, phiếu in, truy xuất; tìm được chứng từ và tồn theo mã hóa. **Còn chờ khách xác nhận định dạng**; khi khách xác nhận khác (vd mã do QC ghi tay), mã hóa đổi thành trường nhập có kiểm tra như file.

### 9.5 Ký hiệu vị trí chứa

| Trong file | Số dòng | Hiểu là (suy luận) | Hệ thống |
|---|---|---|---|
| `A.15`, `A.109`, `C.34`, `2.205`, `A. 98` | 279 | Bồn: khu + số | Bồn `A.15` (bỏ khoảng trắng) |
| `5.trái`, `2. trái`, `2.trái` | 21 | Trái ở khu 5 / khu 2 | `5.Trái` |
| `5.Phuy`, `A.Phuy`, `B.phuy` | 8 | Phuy ở khu | `5.Phuy`, `B.Phuy` |
| `A.`, `4.`, `C.`, `1.` (thiếu số) | 73 | Chưa rõ bồn nào | **Bị chặn**: bồn phải có số |
| `H1`, `A1`, `MA1`, `TB2`, `TE3`… (không có dấu chấm) | 37 | Chưa rõ (kệ? pallet? khu khác?) | Chưa nhận; hỏi khách |

Khi nhập ký hiệu vị trí mới, hệ thống nhận các biến thể có dấu chấm ở trên (không phân biệt hoa thường, có / không dấu, có khoảng trắng) và chuẩn hoá. Phiếu kho chọn vị trí từ danh sách, không gõ tay.

### 9.6 Lỗi dữ liệu trong file và cách hệ thống chặn

| Lỗi thấy trong file | Hệ thống |
|---|---|
| Tồn theo lot âm (−884, −40) | Kiểm âm theo (vật tư, kho, lô, vị trí) khi lưu phiếu; mặc định chặn (CH-20); nếu khách cho phép tạm âm thì khoá kỳ không qua được khi còn tồn âm và báo đúng phiếu, lô, vị trí |
| Số lẻ dấu phẩy động (`1,42e-14` còn lại sau khi trừ) | Số lượng làm tròn 3 chữ số thập phân ở mọi phép cộng trừ; ĐVT "chỉ số nguyên" không nhận số lẻ |
| ĐVT `#REF!` (3.717 dòng), `#N/A` (302 dòng) | ĐVT lấy từ danh mục vật tư, không tính bằng công thức trên dòng |
| Ký hiệu bồn không thống nhất (`2. trái` / `2.trái`, `B.phuy` / `5.Phuy`, `A.` thiếu số) | Danh mục vị trí chuẩn hoá; phiếu chọn từ danh sách |
| Mã hóa bỏ trống | Mã hóa tự sinh khi tạo lô, bắt buộc |
| Mã lô mất số 0 đầu (`10724`) | Mã lô lưu dạng chuỗi |
| Mã phiếu hai kiểu (`PXK-0126-001` và `PNK-2609001`), công thức gợi ý mã phiếu `#NAME?` | Số phiếu kho cấp tự động một kiểu `PNK-YYMMnnn` / `PXK-YYMMnnn` |
| Tên hàng trùng / nhiều cách viết | Danh mục chặn trùng tên và mã; tên chốt ghép theo cú pháp (§9.8); tên cũ lưu để tra cứu và in; mỗi tên hàng có Mã MISA để đối chiếu |
| Cú pháp tên lệch giữa các dòng (`490g/hũ` và `24 kg/xô`; khoảng trắng thừa `cá chốt  ăn liền`; `ủ thinh` / `ủ thính`; `hủ` / `hũ`) | Ghép tên tự động theo quy tắc §9.8, chuẩn hoá khoảng trắng; người dùng sửa tên chốt thì hệ thống cảnh báo khác tên ghép |
| Cột ĐƠN VỊ và MÃ MISA trong `CuPhapTen` trống cả 24 dòng; công thức ghép tên `#NAME?` khi mở ngoài Google Sheets | Ghép tên là chức năng của hệ thống, không phụ thuộc công thức |

### 9.7 Câu hỏi mở về file Excel kho

Đã chuyển sang [CAU-HOI-MO](CAU-HOI-MO.md) §4–§5 (mã cũ D1–D14 → CH-22, CH-32..CH-42, CH-45, CH-46).

### 9.8 Tên cũ ↔ tên mới và cú pháp tên (KHO-09)

Nguồn: sheet `CuPhapTen` (24 mặt hàng đã điền, trên 88 tên hàng đang dùng ở sổ nhập xuất). Cột: TÊN CŨ · TÊN HÀNG GỢI Ý · 13 thuộc tính · TÊN HÀNG CHỐT · ĐƠN VỊ · MÃ MISA TƯƠNG ỨNG.

**13 thuộc tính, theo đúng thứ tự ghép:** (1) Tên SP (loại: Mắm, Nước mắm, Nhãn, Decal, Thùng…), (2) Nguyên liệu, (3) Thông tin SP, (4) Khối lượng, (5) Đơn vị khối lượng, (6) Quy cách đóng gói, (7) Chủng loại, (8) Dài, (9) Rộng, (10) Cao, (11) Màu, (12) Thương hiệu / xuất xứ / tên nhãn, (13) Mã nhà sản xuất.

**Quy tắc của file:** tên gợi ý = nối 13 thuộc tính theo thứ tự trên, cách nhau một khoảng trắng, **bỏ ô trống** (`TEXTJOIN(" ", TRUE, …)`). Tên chốt do người sửa lại từ tên gợi ý.

**Quy tắc hệ thống (đề xuất, suy ra từ các tên chốt đã điền — chờ khách xác nhận ở CH-37):**
- Ghép đúng thứ tự 13 thuộc tính, bỏ thuộc tính trống, một khoảng trắng giữa các phần, cắt khoảng trắng thừa.
- Khối lượng viết liền đơn vị: `490g`, `1kg` (file có 2 tên viết cách `24 kg`, `100 ml` — coi là lệch).
- Quy cách đóng gói đứng sau dấu `/`: `490g/hũ`, `430g/hũ nhựa`, `5kg/can`.
- Kích thước nối bằng `x`: `315x240x252`; số thập phân dùng dấu phẩy: `22,5x18`.
- Viết hoa chữ cái đầu, phần còn lại viết thường (tên nhãn hiệu giữ nguyên nếu khách muốn).
- Ví dụ (từ file): Tên SP "Mắm" + Nguyên liệu "Cá cơm" + Thông tin "Chua ngọt" + 430 + "g" + Quy cách "Hũ nhựa" → **Mắm cá cơm chua ngọt 430g/hũ nhựa**.

**Yêu cầu:**
- Danh mục vật tư lưu 13 thuộc tính, **tên chốt** (tự ghép; sửa được nhưng hệ thống cảnh báo khi khác tên ghép), **một hoặc nhiều tên cũ** (CH-38), ĐVT, Mã MISA (duy nhất, được để trống).
- Chặn trùng tên chốt; tìm kiếm (không dấu) theo tên chốt, tên cũ, mã, Mã MISA.
- Phiếu xuất in cả **tên hàng cũ** và **tên hàng mới** (như mẫu file); đơn hàng nhập theo tên cũ vẫn tìm ra đúng mặt hàng.
- Nhập danh mục từ sheet `CuPhapTen` (cột A → tên cũ, C–O → thuộc tính, P → tên chốt, R → Mã MISA).

### 9.9 Lập phiếu xuất từ đơn hàng — SL yêu cầu và SL thực xuất (KHO-12)

Nguồn: sheet `GoiYXuat` và cột "SỐ LƯỢNG THỰC XUẤT" của `2.NXKho`.

**Cách file làm:** người dùng nhập **mã đơn hàng** và tên người thực hiện ở đầu sheet → sheet lọc các dòng của đơn đó trong sheet đơn hàng (không có trong file; lọc thêm theo hai cột chưa rõ nghĩa — CH-40) → điền tên hàng cũ, nhóm hàng, tên SP (mới, tra từ tên cũ), mã hóa, SL xuất (= SL trên đơn) → người dùng điền LOT, BỒN (tách nhiều dòng nếu lấy từ nhiều lô/bồn), sheet cảnh báo "KIỂM TRA MÃ LOT" khi 2 ký tự cuối lot ≠ mã hóa, gợi ý mã phiếu PXK theo tháng → dán giá trị sang sổ nhập xuất. Khi giao thực tế khác, thủ kho ghi **SL thực xuất**; mọi tồn và báo cáo dùng SL thực xuất nếu có, không thì dùng SL xuất.

**Yêu cầu:**
1. Lập phiếu xuất bằng cách chọn đơn (đơn bán; hoặc yêu cầu chuyển kho Bình Tây / 97 — CH-40). Hệ thống điền các dòng đơn **còn chưa xuất đủ**, SL yêu cầu = SL đơn − SL đã xuất thực.
2. Mỗi dòng đơn tách được thành nhiều dòng phiếu theo **lô + vị trí**; tổng SL các dòng tách mặc định = SL yêu cầu, thêm vị trí thì tự chia phần còn lại.
3. Chỉ chọn lô Đạt QC (QC-05); gợi ý lô theo HSD rồi lô cũ nhất (đề xuất, QC-08).
4. Thủ kho xác nhận **SL thực xuất** từng dòng; khác SL yêu cầu thì chọn lý do (CH-36). Tồn kho, giá vốn (R1(c)), công nợ và tiến độ đơn theo **SL thực xuất**.
5. Dòng đơn chưa xuất đủ vẫn mở để lập phiếu tiếp; đơn hết dòng mở thì hoàn thành.
6. Phiếu in (§9.10) có cả SL đặt hàng và SL xuất kho; ghi chú dòng = chênh lệch đặt − xuất + ghi chú đơn.
7. Đơn hàng ở 1A chỉ cần mức tối thiểu (khách hàng / kho đến, dòng hàng theo tên cũ hoặc tên chốt, SL, ngày giao, địa điểm giao, người nhận, SĐT); giá, hạn mức, duyệt ở 1B (BAN-01).

### 9.10 Mẫu in phiếu xuất kho và phiếu nhập kho (KHO-11)

Mẫu của khách (sheet `4.InPXKMoi`, `5.InPNK`). Thông tin công ty, khách hàng, họ tên người ký lấy từ danh mục khi in; **không** chép thông tin thật vào tài liệu và demo.

| Phần | Phiếu xuất kho (PXK) | Phiếu nhập kho (PNK) |
|---|---|---|
| Đầu phiếu | Tên công ty, địa chỉ, MST, điện thoại, email; tiêu đề PHIẾU XUẤT KHO; ngày; **mã đơn hàng**; loại tiền; số phiếu `PXK-…` | Tên công ty, địa chỉ; tiêu đề PHIẾU NHẬP KHO; ngày (file ghi nhầm nhãn "Ngày xuất"); số phiếu `PNK-…` |
| Khách hàng | Tên khách hàng, địa chỉ, MST, điện thoại, email; ghi chú | — |
| Bảng dòng | STT · Mã hàng · **Tên hàng cũ** · **Tên hàng mới** · Mã hóa · Mã lot · ĐVT · **SL đặt hàng** · **SL xuất kho** · Ghi chú (chênh lệch đặt − xuất + ghi chú đơn). Một mặt hàng nhiều lot in liền nhau (file giới hạn 5 lot — CH-42). Dòng **Tổng cộng** SL đặt, SL xuất | STT · Nhóm hàng · Tên sản phẩm · Lot · ĐVT · Số lượng · Ghi chú (thêm mã hóa và vị trí — đề xuất) |
| Giao hàng | Ngày giao hàng; địa điểm giao hàng; người nhận hàng; SĐT người nhận; hình thức thanh toán (CH-41) | — |
| Chữ ký | **4 ô: Người nhận hàng · Bảo vệ · Tài xế · Thủ kho** (ký, họ tên); họ tên in sẵn dưới ô ký lấy từ danh mục | **4 ô: Người lập phiếu · Thủ kho · Kế toán · Người nhận** (ký và ghi họ tên) |

Ngoài mẫu kho của khách (không có đơn giá), kế toán cần mẫu **01-VT (PNK) / 02-VT (PXK)** theo chế độ, có đơn giá và thành tiền (phản biện v3 U15); số hiệu mẫu theo TT99 **chưa xác minh**. Phiếu chuyển kho in tiêu đề "Phiếu xuất kho kiêm vận chuyển nội bộ".

---

## 10. Yêu cầu phi chức năng

| Mã | Yêu cầu | Nguồn |
|---|---|---|
| NFR-01 | **Giao diện đơn giản**: không chữ giải thích thừa (không đoạn hướng dẫn, mô tả, chú thích trên màn hình; nhãn trường ngắn; thông báo lỗi một câu nói rõ sai ở đâu); **không nhãn màu** (không badge/thẻ màu cho trạng thái, loại, QC — trạng thái hiện bằng chữ thường; màu chỉ dùng cho lỗi và chỗ đang chọn); **bo góc ≤ 2px** cho mọi khung, nút, ô nhập, bảng | Quyết định người dùng 2026-10-07 (§1.4 Q5) |
| NFR-02 | Nhập liệu bằng bàn phím: Enter sang ô kế, Ctrl+Enter ghi; Esc/Huỷ khi đang có thay đổi thì hỏi "Bỏ thay đổi?" | Phản biện v3 U3, U5 |
| NFR-03 | Bảng và báo cáo dùng được ở màn hình 1366px và điện thoại 390px, không mất cột số liệu (cuộn ngang trong bảng, không cắt cột) | Phản biện v3 U11 |
| NFR-04 | Tìm kiếm không phân biệt dấu và hoa thường (tên chốt, tên cũ, mã, mã lô, mã hóa, vị trí) | Phản biện v3 U12 |
| NFR-05 | Số học: tiền và số lượng tính bằng số thập phân chính xác (không số thực), làm tròn theo R1; kiểu lưu theo `KIEN-TRUC-VA-CSDL.md` §1.4 | Phản biện v3 L7 |
| NFR-06 | Toàn vẹn và nhật ký theo TT99: chứng từ đã ghi sổ không sửa/xoá trực tiếp; khoá kỳ (TH-03); nhật ký sửa đổi mọi bảng; tách dữ liệu giữa các công ty thuê bao ở mức CSDL | `KIEN-TRUC-VA-CSDL.md` §2.1, §7; `DIEU-CHINH-THEO-KHACH-HANG.md` §11 |
| NFR-07 | Xuất dữ liệu: nút "Excel" tải tệp thật (CSV/XLSX), "Sao chép" là chức năng riêng | Phản biện v3 U16 |

---

## 11. Truy vết yêu cầu → demo v4.0

Demo: `demo/gia-goc-demo.html` bản v4.0 (thay đổi ở [demo/CHANGELOG.md](../../demo/CHANGELOG.md)); số liệu là dữ liệu mẫu, không phải số của khách. Trạng thái: **Có** = thao tác được trên demo; **Một phần** = có nhưng giản lược (ghi rõ); **Chưa** = chưa có. Demo được làm để minh họa mục tiêu trọng tâm (giá vốn theo lô) và kho theo lô + vị trí, **không** nhằm phủ đủ phạm vi giai đoạn 1.

| Nhóm yêu cầu | Mã | Demo v4.0 | Ở đâu trên demo | Giản lược / lệch so với yêu cầu |
|---|---|---|---|---|
| Giá nguyên liệu theo lô, kiểm soát chênh lệch | GT-09, GT-R4 | Có | Trang **Giá nguyên liệu** (bảng lô, lịch sử giá, "Đã dùng cho"); Tổng quan → Việc cần làm "Giá nguyên liệu tăng" | Ngưỡng cố định 5% / 10% (CH-15); chưa so với giá đơn mua (đơn mua thuộc 1B) |
| Giá vốn theo lô, cây cấu thành, truy xuôi | GT-10, GT-R5 | Có | Trang **Giá vốn theo lô** (lọc Thành phẩm / Bán thành phẩm / Hàng hóa; bấm lô xem cây; cuối cây là hóa đơn bán); Tổng quan → "Giá vốn hàng bán theo sản phẩm" | — |
| Giá thành theo lệnh sản xuất, dở dang nhiều kỳ, hỏng ngoài định mức | GT-02..GT-06, GT-R1, GT-R2 | Một phần | Trang **Giá thành theo lệnh sản xuất** (bảng lệnh, phân bổ, thẻ giá thành) | Tiêu thức phân bổ nhân công và sản xuất chung = chi phí nguyên vật liệu trực tiếp của lệnh; lệnh hoàn thành khi có phiếu nhập kho đầu tiên ([QD-29](../02-ke-hoach/QUYET-DINH.md#qd-29)) |
| Sản xuất chung dưới công suất | GT-08 | Có | Trang Giá thành theo lệnh sản xuất, ô "Giờ máy thực tế" | Demo bật; sản phẩm mặc định tắt (CH-14) |
| Lãi lỗ theo mặt hàng / lô | GT-R3 | Một phần | Tổng quan (theo sản phẩm), Giá vốn theo lô (theo lô) | Chưa có theo khách hàng |
| Quy trình → giai đoạn → thao tác | GT-01 | Một phần | Danh mục vật tư (giai đoạn, các bước) | Chỉ cá linh (2 giai đoạn) và mắm tôm (1 giai đoạn); thiếu cá bạc má, dưa gang chay (phản biện vòng 3 §3) |
| Lệnh sản xuất, tiến độ, xuất theo lệnh | KHO-01, KHO-R4, KHO-R5 | Có | Danh mục & lệnh sản xuất; Báo cáo "Tiến độ sản xuất theo lệnh", "Tổng hợp xuất kho theo lệnh sản xuất" | Không có lệnh tổng; trạng thái Mới / Đang sản xuất / Hoàn thành |
| Giá xuất kho đích danh theo lô | GT-07 | Có | Trang **Giá xuất kho** (sổ chi tiết vật tư, nguồn đơn giá, so sánh 4 phương pháp) | — |
| Nhập, xuất theo mục đích, chuyển kho, chuyển vị trí, kiểm kê | KHO-02..KHO-05 | Một phần | "+ Lập chứng từ": phiếu nhập mua, phiếu xuất cho lệnh sản xuất, nhập kho, chuyển kho / chuyển vị trí, phiếu xuất hủy, phiếu kiểm kê kho | Chuyển kho một bước (QD-28); chưa xuất dùng chung xưởng, xuất cho bán hàng / quản lý |
| Vị trí chứa, mã hóa, số phiếu kho, tồn tối thiểu | KHO-06..KHO-08, KHO-10 | Có | Kho & lô → "Tồn kho chi tiết"; Danh mục → "Vị trí chứa" | Mã lô kiểm trùng toàn nhà máy (lệch QD-14) |
| Mẫu in theo mẫu khách | KHO-11 | Có | Chứng từ & bút toán: nút "In …" ở chi tiết, biểu tượng in đầu dòng, "In các phiếu đã chọn"; nút "Lưu và in" trong form. In được: phiếu nhập kho, phiếu xuất kho, phiếu xuất kho kiêm vận chuyển nội bộ, biên bản kiểm kê kho, phiếu thu, phiếu chi | Xem §9.2 dòng mẫu in; số hiệu mẫu TT99 chưa xác minh (XM-02) |
| Lập phiếu xuất từ đơn, SL thực xuất, giải trình kiểm kê, N-X-T thực tế, tên cũ / cú pháp tên | KHO-09, KHO-12, KHO-13, KHO-R10 | Chưa | — | Xem §9.2 |
| Báo cáo kho theo lô + vị trí | KHO-R1, KHO-R2, KHO-R7..KHO-R9 | Có | Kho & lô (N-X-T, Tồn kho chi tiết); Báo cáo "Nhập – xuất – tồn theo lô và vị trí", "Sổ chi tiết mặt hàng theo lô và vị trí" | — |
| Đối chiếu kế toán – thủ kho, chuyển kho nội bộ | KHO-R3, KHO-R6 | Chưa | — | Tổng quan có "Đối chiếu kho với sổ cái" (khác KHO-R6) |
| QC lõi: trạng thái lô, chặn xuất, HSD, xuất hủy | QC-03..QC-05, QC-08 | Một phần | Trạng thái lô Đạt / Chờ / Không đạt; lô chưa đạt không bán được; "Xuất hủy" ở Tồn kho chi tiết; hàng trả lại chọn QC và vị trí | Chưa có điểm kiểm, chỉ tiêu, phiếu kiểm (QC-01, QC-02); QC yếu nhất trên demo |
| QC đầy đủ, truy xuất nhiều cấp, báo cáo chất lượng | QC-06, QC-07, QC-R1 | Một phần | Truy ngược và truy xuôi qua cây cấu thành và "Đã dùng cho" | Chưa có quyết định xử lý, báo cáo chất lượng |
| Mua: phiếu nhập mua VND/USD, công nợ | MUA-02, MUA-R1, MUA-R2 | Có | "Phiếu nhập mua"; Báo cáo "Công nợ phải thu / phải trả theo đối tượng" | — |
| Trả lại / giảm giá hàng mua, đơn mua, tổng hợp mua | MUA-01, MUA-03, MUA-04, MUA-R3, MUA-R4 | Chưa | — | — |
| Bán: hóa đơn, bán lẻ, hàng bán bị trả lại, công nợ | BAN-02, BAN-03, BAN-R1, BAN-R2 | Có | "Hóa đơn bán hàng", "Hàng bán bị trả lại"; Báo cáo công nợ | Hàng trả lại ghi giảm thẳng 511 (yêu cầu ghi 5212 — XM-01) |
| Đơn bán, giảm giá hàng bán, tổng hợp bán | BAN-01, BAN-04, BAN-R3, BAN-R4 | Chưa | — | — |
| Thu, chi tiền mặt / ngân hàng, sổ quỹ, sổ tiền gửi | TIEN-02, TIEN-03, TIEN-R1, NH-01, NH-02, NH-R1 | Có | "Chi tiền trả nhà cung cấp", "Thu tiền khách hàng"; Báo cáo "Sổ quỹ tiền mặt / sổ tiền gửi" | Chưa có nhật ký thu / chi riêng (TIEN-R2, TIEN-R3) |
| Đề nghị thanh toán, khế ước vay, luồng duyệt | TIEN-01, NH-03, NH-R2, NEN-04 | Chưa | — | — |
| Ngoại tệ | NT-01..NT-05 | Một phần | Phiếu nhập USD, phiếu chi USD (chênh lệch 515 / 635) | Chưa đánh giá lại cuối kỳ (NT-04) |
| TSCĐ, CCDC | TSCD-*, CCDC-* | Chưa | Chỉ có chứng từ "Khấu hao tài sản cố định" nhập tổng | — |
| Tổng hợp: chứng từ khác, sổ nhật ký chung, sổ cái | TH-01, TH-R1..TH-R3 | Có | "Bảng lương", "Chi phí sản xuất chung"; Báo cáo "Sổ nhật ký chung", "Sổ cái" | — |
| Kết chuyển lãi / lỗ, khóa kỳ | TH-02, TH-03 | Chưa (cố ý) | — | Demo bỏ khóa sổ ([QD-09](../02-ke-hoach/QUYET-DINH.md#qd-09)); kết quả kinh doanh lấy thẳng từ số dư tài khoản loại 5–8 |
| Báo cáo tài chính | BC-R1, BC-R2 | Có | Báo cáo "Bảng cân đối số phát sinh", "Báo cáo kết quả kinh doanh" | — |
| Bảng cân đối kế toán, LCTT, thuyết minh | BC-R3..BC-R5 | Chưa | — | — |
| Nhật ký sửa đổi, chứng từ không sửa trực tiếp | NEN-05 | Có | Trang **Nhật ký sửa đổi**; sửa = hủy + lập lại có lý do | — |
| Danh mục | NEN-01 | Có | Danh mục & lệnh sản xuất | Chưa có 13 thuộc tính tên |
| Giao diện, bàn phím, màn hẹp, tìm không dấu, xuất Excel | NFR-01..NFR-04, NFR-07 | Có | Toàn bộ demo; Enter sang ô kế, Ctrl+Enter ghi; nút "Tải bảng" | — |

