# Yêu cầu khách hàng — chuẩn hoá từ `HỆ THỐNG.docx`

> Phiên bản: **v1.0** · Ngày: 2026-10-06 · Trạng thái: bản chuẩn hoá lần đầu, **chưa được khách xác nhận**
> Nguồn: `HỆ THỐNG.docx` (gốc repo). Metadata của file: tạo và sửa lần cuối ngày 2026-10-06; đưa vào repo cùng ngày. Tài liệu khách không ghi ngày gửi, nên lấy **2026-10-06** làm ngày nhận.
> Liên quan: `KE-HOACH-DU-AN.md` v0.3 (phạm vi, đợt phát hành, tiến độ), `research/07-dieu-chinh-kien-truc-theo-khach-hang.md` (thay đổi dữ liệu và kiến trúc), `research/01` (định khoản gốc), `research/05` (kiến trúc gốc).

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

---

## 2. Quy ước

- **Mã yêu cầu**: `<PHÂN HỆ>-<số>`. Phân hệ: TIEN, NH, MUA, BAN, TSCD, CCDC, KHO, GT, TH, BC; bổ sung QC (chất lượng), NT (ngoại tệ, dùng chung), NEN (nền móng, danh mục, phân quyền). Báo cáo có hậu tố `R` (vd `KHO-R3`).
- **Định khoản** viết theo TT99/2025 (logic như TT200). Cột "TT133" chỉ ghi khi khác. Số hiệu TK dùng **account role** khi cài đặt, không hardcode (`research/05` §2.3).
- Ký hiệu **(*)** sau số TK: TK này không có trong bảng đối chiếu `research/01` §2, nên **chưa xác minh** đúng số hiệu/cấp 2 trong Phụ lục II TT99. Số hiệu TT200/TT133 là kiến thức chuyên môn phổ biến, chưa đối chiếu nguyên văn lần này.
- **Đợt** (trong GĐ1): **1A** nền móng + danh mục + tiền/ngân hàng + mua + bán + kho/lô + QC lõi; **1B** sản xuất theo công đoạn + giá thành đích danh nhiều giai đoạn + QC đầy đủ + P&L; **1C** TSCĐ, CCDC, khế ước vay, ngoại tệ đánh giá lại, khoá sổ đầy đủ, BCTC, LCTT. Lý do thứ tự: `KE-HOACH-DU-AN.md` §3.
- **Cột "v0.2"** = mức có trong kế hoạch v0.2: **Có** (đã trong MVP), **Một phần**, **Thiếu** (không nhắc), **P2/P3** (đã bị đẩy sang giai đoạn sau).
- **Luật làm tròn R1** áp dụng cho mọi số tiền (nguyên văn ở `KE-HOACH-DU-AN.md` §2).

---

## 3. Ma trận truy vết theo phân hệ

### 3.1 Phân hệ 1 — Tiền (quỹ tiền mặt)

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| TIEN-01 | Đề nghị thanh toán | Phiếu đề nghị thanh toán / tạm ứng / thanh toán tạm ứng; **không phải chứng từ kế toán** | Không sinh bút toán. Khi chi: sinh phiếu chi (TIEN-03) hoặc UNC (NH-02) tham chiếu đề nghị | Người đề nghị, người nhận, loại đề nghị, chứng từ gốc kèm theo (HĐ mua, đơn mua), số tiền nguyên tệ/VND, hạn chi, hình thức chi, trạng thái duyệt | 1A | Thiếu | Luồng duyệt §3.1.1 |
| TIEN-02 | Thu tiền | Phiếu thu: thu nợ KH, bán lẻ thu ngay (97 Nguyễn Thái Học), hoàn ứng, rút NH nhập quỹ, thu khác | Nợ 1111/1112 / Có 131, 5111/5112 + 33311, 141, 1121, 711… | Mã dòng tiền LCTT (BC-R4), đối tượng, nguyên tệ + tỷ giá nếu 1112 | 1A | Có | Thu ngoại tệ tiền mặt: NT-02 |
| TIEN-03 | Chi tiền | Phiếu chi: trả NCC, tạm ứng, chi phí, nộp tiền vào NH | Nợ 331, 141, 627/641/642 (TT133: 154/6421/6422), 1331, 1121… / Có 1111/1112 | Tham chiếu đề nghị thanh toán đã duyệt (bắt buộc theo cấu hình), mã dòng tiền | 1A | Có | Chi ngoại tệ: tỷ giá xuất quỹ (NT-03) |
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
- Hạn mức H, số cấp duyệt, ai trong BOD duyệt: **chưa có** — câu hỏi A6.

### 3.2 Phân hệ 2 — Ngân hàng (có khế ước vay)

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| NH-01 | Thu tiền | Báo có: KH chuyển khoản, giải ngân vay, lãi tiền gửi, nộp tiền mặt vào | Nợ 1121/1122 / Có 131, 341 (*), 515, 1111… | Tài khoản NH (danh mục), mã dòng tiền, nguyên tệ + tỷ giá | 1A | Có | Giải ngân vay sinh từ NH-03 |
| NH-02 | Chi tiền | UNC / séc / báo nợ: trả NCC, nộp thuế, trả nợ vay, phí NH | Nợ 331, 333x, 341 (*), 335 (*), 635, 642 (phí NH; TT133: 6422)… / Có 1121/1122 | Tham chiếu đề nghị thanh toán; mã dòng tiền | 1A | Có | TK chi tiết cấp 2 cho phí NH theo quy chế nội bộ |
| NH-03 | Khế ước vay | Khai báo HĐ tín dụng / khế ước nhận nợ; giải ngân; lịch trả gốc lãi; trích lãi dồn tích; trả gốc, trả lãi | §3.2.1 | §3.2.1 | 1C (khai báo + giải ngân/trả gốc nhập tay từ 1A) | Thiếu | Ngoại tệ: đánh giá lại số dư 341 (NT-04) |
| NH-R1 | Sổ tiền gửi ngân hàng | Theo tài khoản NH × loại tiền: dư đầu, thu, chi, dư cuối; cột nguyên tệ | — | Dòng 112x có `bank_account_id` | 1A | Có | Đối chiếu sổ phụ: nhập tay số dư sổ phụ để so (không kết nối NH trong GĐ1) |
| NH-R2 | Theo dõi tiền vay / khế ước vay | Theo khế ước: dư gốc đầu kỳ, giải ngân, trả gốc, lãi phải trả, lãi đã trả, dư cuối; lịch đến hạn 30/60/90 ngày; phần gốc đến hạn trong 12 tháng | — | Bảng khế ước, lịch trả, giao dịch | 1C | Thiếu | Dùng để tách vay ngắn/dài hạn trên BCĐKT |

#### 3.2.1 Khế ước vay — đặc tả

- **Khai báo**: số HĐ tín dụng (hạn mức, cha) và số khế ước nhận nợ (con); ngân hàng (đối tượng 341); loại tiền; số tiền; ngày giải ngân; ngày đáo hạn; lãi suất theo giai đoạn (cố định hoặc điều chỉnh định kỳ — nhập tay mỗi lần NH thông báo); cơ sở tính lãi (ngày thực tế/365 hay /360 — chưa biết, câu hỏi C2); kỳ trả lãi; lịch trả gốc (đều hoặc nhập tay); mục đích (vốn lưu động / đầu tư TSCĐ — dùng cho LCTT và xét vốn hoá); tài sản bảo đảm (thông tin).
- **Giải ngân**: Nợ 1121/1122 (hoặc Nợ 331 khi NH chuyển thẳng cho NCC) / Có 3411 (*) chi tiết khế ước. LCTT: "tiền thu từ đi vay" (hoạt động tài chính; mã 33 theo B03-DN TT200, mã TT99 chưa xác minh).
- **Trích lãi dồn tích cuối tháng** (đề xuất mặc định): lãi tháng = Σ ngày (dư gốc ngày × lãi suất năm / cơ sở ngày), làm tròn theo R1(a) cho cả tháng của từng khế ước. Nợ 635 / Có 335 (*). Trả lãi: Nợ 335 (*) / Có 112. Nếu KTT chọn không trích trước: Nợ 635 / Có 112 khi trả.
- **Trả gốc**: Nợ 3411 (*) / Có 112. LCTT: "tiền trả nợ gốc vay" (mã 34 theo TT200).
- **Vay ngoại tệ**: số dư 341 là khoản mục tiền tệ có gốc ngoại tệ → đánh giá lại cuối kỳ (NT-04); trả gốc ngoại tệ sinh chênh lệch thực hiện 515/635 (NT-03).
- **Vốn hoá lãi vay** (VAS 16): chỉ khi vay cho tài sản dở dang cần thời gian dài. Với mắm ủ, chưa có thông tin thời gian ủ > 12 tháng; GĐ1 **không** tự động vốn hoá, cho phép chứng từ tổng hợp nếu KTT quyết định.
- Bút toán do hệ thống sinh từ khế ước là chứng từ hệ thống (loại riêng), xem/huỷ như chứng từ thường.

### 3.3 Phân hệ 3 — Mua hàng

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| MUA-01 | Đơn đặt hàng / HĐ mua hàng | Hợp đồng mua (khung: thời hạn, hạn mức) và đơn mua (dòng hàng, SL, giá, hạn giao, điều khoản thanh toán, kho nhận) | Không sinh bút toán. Ứng trước NCC theo đơn: Nợ 331 / Có 112 (chi tiết đơn) | NCC, loại tiền, tỷ giá dự kiến, số ngày được nợ, kho nhận; theo dõi SL đã nhận / đã nhận HĐ / đã trả lại | 1A | P2 | Duyệt đơn theo hạn mức (cấu hình như §3.1.1) |
| MUA-02 | Mua hàng / nhận hóa đơn | Phiếu nhập mua kèm HĐ; hàng về trước HĐ (giá tạm); HĐ về trước hàng (151); mua dịch vụ/chi phí; chi phí mua phân bổ; chi phí mua về sau; nhập khẩu (nếu có) | Nợ 152/153/156, 1331 / Có 331; HĐ về trước: Nợ 151 / Có 331, khi hàng về Nợ 152 / Có 151; dịch vụ: Nợ 627/641/642/242 (TT133: 154/6421/6422/242), 1331 / Có 331; nhập khẩu: thuế NK Có 3333, GTGT NK Nợ 1331 / Có 33312 | **Mỗi dòng nhập tạo hoặc chọn 1 lô** (mã lót NVL, NSX, HSD); kho; tham chiếu đơn mua; tiêu thức phân bổ chi phí mua; nguyên tệ + tỷ giá | 1A | Có (trừ lô) | Lô ở trạng thái **Chờ kiểm** đến khi QC tiếp nhận đạt (QC-04) |
| MUA-03 | Trả lại hàng mua | Phiếu xuất trả NCC, **đích danh lô gốc** | Nợ 331 (hoặc 1388 nếu NCC hoàn tiền sau) / Có 152/153/156 (giá trị lô theo R1(c)) / Có 1331 | Phiếu nhập gốc / lô gốc (bắt buộc), SL ≤ tồn của lô tại kho, lý do (gồm "không đạt QC tiếp nhận") | 1A | Có | §3.3.1 |
| MUA-04 | Giảm giá hàng mua | Chứng từ điều chỉnh SL = 0 gắn phiếu nhập/lô gốc | Nợ 331 / Có 152/156 (phần lô còn tồn), Có 621 hoặc 154 (TT133) (phần đã xuất cho lệnh SX chưa tính giá thành), Có 632 (phần đã thành SP đã bán hoặc kỳ đã khoá), Có 1331 | Lô gốc, số tiền, HĐ điều chỉnh của NCC | 1A | Có | Với đích danh, tách phần còn tồn / đã dùng **chính xác theo lô** (khắc phục `06a` L7) |
| MUA-R1 | Tổng hợp công nợ phải trả NCC | Theo NCC: dư đầu, phát sinh, dư cuối; theo nguyên tệ | — | 331 theo đối tượng | 1A | Có | |
| MUA-R2 | Chi tiết phải trả NCC | Theo NCC × chứng từ; hạn thanh toán; tuổi nợ | — | Hạn thanh toán trên HĐ | 1A | Có | |
| MUA-R3 | Tổng hợp mua hàng theo mặt hàng / NCC / thời hạn thanh toán / hạn mức thanh toán | Giá trị, SL mua; phân theo hạn thanh toán; so với hạn mức | — | Hạn mức thanh toán theo NCC (ý nghĩa chưa rõ — C5) | 1A | Thiếu | "Hạn mức thanh toán" đang hiểu là hạn mức công nợ NCC cấp cho công ty |
| MUA-R4 | Tổng hợp trả lại hàng mua / giảm giá hàng ~~bán~~ mua | Theo NCC, mặt hàng, lô, lý do | — | MUA-03, MUA-04 | 1A | Thiếu | Tài liệu khách ghi "giảm giá hàng bán" trong phân hệ Mua — đang hiểu là **giảm giá hàng mua** (C5) |

#### 3.3.1 Trả lại hàng mua và giảm giá hàng mua — quy tắc

- Trả lại chỉ lấy từ **lô gốc** của phiếu nhập; không cho trả từ lô khác cùng mã hàng.
- Giá trị ghi Có kho = giá trị của lô tại kho xuất theo R1(c). Nếu lô đã được cộng chi phí mua phân bổ, phần Nợ 331 (theo giá HĐ) nhỏ hơn giá trị lô xuất ra; phần chênh lệch (chi phí mua đã phân bổ cho SL trả) đưa vào 632 hay 811 — **chưa xác minh, KTT quyết định**.
- Lô không đạt QC tiếp nhận thì không bao giờ được giải phóng (trạng thái Không đạt) và chỉ có hai lối ra: trả NCC hoặc xuất huỷ.
- Hóa đơn cho hàng trả lại / giảm giá theo NĐ 123/2020 sửa đổi bởi NĐ 70/2025: ai lập HĐ, lập HĐ điều chỉnh hay HĐ trả hàng — **chưa xác minh** (`research/01` §9 mục 6). GĐ1 chỉ lưu số HĐ, không phát hành HĐĐT.
- Giảm giá rơi vào kỳ đã khoá: ghi ở kỳ đang mở; phần lô còn tồn giảm giá trị lô, phần đã tiêu hao vào 632 (đề xuất, chờ KTT).

### 3.4 Phân hệ 4 — Bán hàng

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| BAN-01 | Đơn đặt hàng / HĐ bán hàng | Hợp đồng bán (khung) và đơn bán: KH, dòng hàng, giá, hạn giao, kho xuất, điều khoản thanh toán | Không sinh bút toán. KH ứng trước: Nợ 112 / Có 131 (chi tiết đơn) | **Hạn mức dư nợ KH**: kiểm khi duyệt đơn và khi lập HĐ (cảnh báo hoặc chặn — cấu hình); theo dõi SL đã giao / đã lập HĐ / bị trả lại | 1A | P2 | Vượt hạn mức cần duyệt (BOD/KTT) |
| BAN-02 | Bán hàng / hóa đơn | Chứng từ bán kiêm xuất kho; bán lẻ thu tiền ngay tại 97 Nguyễn Thái Học; xuất gửi bán (157) nếu có | Doanh thu: Nợ 131/111/112 / Có 5111 (hàng hóa) hoặc 5112 (thành phẩm), Có 33311. Giá vốn: Nợ 632 / Có 155/156 — **giá trị của lô xuất** | Lô xuất (hệ thống gợi ý theo hạn dùng gần nhất trước — FEFO; người dùng sửa được); chỉ cho xuất lô đã Đạt QC; số HĐ (nhập tay trong GĐ1) | 1A | Có (trừ lô) | Demo đang ghi hàng hóa vào 5112 — lỗi B2, phải là 5111 |
| BAN-03 | Trả lại hàng bán | Nhập lại kho **vào đúng lô gốc** của chứng từ bán | DT: Nợ 5212 (*cấp 2 TT99) / TT133: Nợ 511; Nợ 33311 / Có 131/111. Giá vốn: Nợ 155/156 / Có 632 = giá vốn đã xuất của lô gốc × SL trả / SL bán (R1(c)) | Chứng từ bán gốc (bắt buộc), kho nhận, tình trạng hàng | 1A | Có | §3.4.1 |
| BAN-04 | Giảm giá hàng bán | Chứng từ giảm trừ SL = 0 gắn HĐ gốc | Nợ 5213 (*cấp 2 TT99) / TT133: Nợ 511; Nợ 33311 / Có 131 | HĐ gốc, số tiền, lý do | 1A | Có | Không ảnh hưởng giá vốn |
| BAN-R1 | Tổng hợp công nợ phải thu KH | Theo KH: dư đầu, phát sinh, dư cuối; nguyên tệ | — | 131 theo đối tượng | 1A | Có | |
| BAN-R2 | Chi tiết công nợ phải thu KH | Theo KH × chứng từ; hạn thanh toán; tuổi nợ | — | Hạn thanh toán | 1A | Có | |
| BAN-R3 | Tổng hợp bán hàng theo mặt hàng / KH / thời hạn thanh toán, hạn mức dư nợ | SL, doanh thu, giảm trừ, (giá vốn và lãi gộp với quyền xem giá vốn); dư nợ so với hạn mức | — | Hạn mức dư nợ KH | 1A (lãi gộp chốt sau 1B) | Một phần | Lãi gộp chỉ đúng khi giá thành TP đã tính (1B) |
| BAN-R4 | Tổng hợp trả lại hàng bán / giảm giá hàng bán | Theo KH, mặt hàng, lô, lý do | — | BAN-03, BAN-04 | 1A | Thiếu | |

#### 3.4.1 Hàng bán trả lại — quy tắc

- Bắt buộc tham chiếu chứng từ bán; nhập lại **lô gốc** với giá vốn gốc (không theo giá hiện tại). Điều này giải quyết mâu thuẫn hai "mặc định" ở `research/01` (06a L13) cho trường hợp đích danh.
- Hàng trả lại vào kho khác kho đã xuất: vẫn giữ lô gốc và giá vốn gốc.
- Hàng trả lại kém chất lượng: lô nhập lại được đặt trạng thái **Tạm giữ** để QC kiểm; nếu huỷ: Nợ 632 (hoặc 811 / 1388 theo quyết định) / Có 155/156.
- Trả lại hàng của kỳ đã khoá: ghi ở kỳ hiện tại, giá vốn vẫn là giá vốn gốc.

### 3.5 Phân hệ 5 — Tài sản cố định

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| TSCD-01 | Khai báo TSCĐ | Thẻ TSCĐ; khai báo số dư đầu khi chuyển từ MISA | Không sinh bút toán (số dư đầu qua chứng từ số dư) | Mã, tên, loại (hữu hình/vô hình), nhóm, bộ phận sử dụng, địa điểm (3 kho/xưởng), nguyên giá, hao mòn luỹ kế đầu, ngày bắt đầu khấu hao, thời gian sử dụng (tháng), phương pháp, TK nguyên giá/khấu hao/chi phí, đối tượng tập hợp chi phí (xưởng/khu) | 1C | P3 | |
| TSCD-02 | Ghi tăng TSCĐ | Mua sắm; hoàn thành XDCB; nhận góp vốn | Nợ 211 (*) (vô hình: 213 (*); TT133 cấp 2 của 211 chưa xác minh), Nợ 1332 / Có 331/112/241 | Chứng từ mua liên kết, biên bản giao nhận | 1C | P3 | LCTT: mua sắm TSCĐ thuộc hoạt động đầu tư |
| TSCD-03 | Khấu hao | Chạy khấu hao tháng | Nợ 627 (TT133: 154 khoản mục SXC) / 641 / 642 (TT133: 6421/6422) / Có 214 (*) | Phân bổ theo bộ phận và tỷ lệ (một tài sản dùng chung nhiều khu); khấu hao đường thẳng; tính theo ngày hay theo tháng (C1) | 1C | P3 (1A/1B nhập qua chứng từ tổng hợp) | Đầu vào SXC của giá thành |
| TSCD-04 | Điều chỉnh | Thay đổi nguyên giá (nâng cấp, sửa chữa lớn được vốn hoá), thay đổi thời gian sử dụng còn lại, điều chỉnh hao mòn | Nâng cấp: tập hợp Nợ 241 (*cấp 2: 2414 theo `research/01` §1.1) → Nợ 211 / Có 241 | Ngày hiệu lực; áp dụng **từ kỳ hiệu lực trở đi**, không tính lại kỳ đã khoá | 1C | P3 | |
| TSCD-05 | Điều chuyển | Chuyển bộ phận sử dụng hoặc địa điểm (giữa các xưởng/kho) | Không bút toán; từ ngày điều chuyển, chi phí khấu hao đi theo bộ phận mới | Ngày điều chuyển, bộ phận/địa điểm mới, tỷ lệ | 1C | P3 | Tháng điều chuyển: chia theo ngày hay theo tháng sau (C1) |
| TSCD-06 | Ghi giảm | Thanh lý, nhượng bán, mất mát, góp vốn đi | Nợ 214 (*) (HMLK), Nợ 811 (giá trị còn lại) / Có 211 (*). Thu thanh lý: Nợ 111/112/131 / Có 711, 33311. Chi phí thanh lý: Nợ 811 / Có 111. Mất chưa rõ nguyên nhân: Nợ 1381 thay 811 | Biên bản, ngày ghi giảm; khấu hao tháng ghi giảm | 1C | P3 | Duyệt BOD |
| TSCD-R1 | Sổ TSCĐ | Theo tài sản: nguyên giá, HMLK, GTCL, tăng/giảm trong kỳ, bộ phận | — | | 1C | P3 | Mẫu sổ theo chế độ; số hiệu mẫu TT99 chưa xác minh |
| TSCD-R2 | Bảng (tính và phân bổ) khấu hao TSCĐ | Theo tài sản × bộ phận × TK chi phí × đối tượng | — | | 1C | P3 | Khớp tổng PS Có 214 kỳ |

Ghi chú pháp lý: khung thời gian khấu hao, ngưỡng nguyên giá TSCĐ và cách tính khấu hao theo ngày đang theo TT 45/2013/TT-BTC (sửa đổi nhiều lần) — **tình trạng hiệu lực tại 10/2026 chưa xác minh**. Các tham số này phải là cấu hình.

### 3.6 Phân hệ 6 — Công cụ dụng cụ

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| CCDC-01 | Khai báo CCDC | Thẻ CCDC, theo **số lượng** (nhiều cái cùng mã: khay, rổ, thùng, dao…); số dư đầu | — | Mã, tên, SL, giá trị, số kỳ phân bổ, đã phân bổ, bộ phận, địa điểm, TK chi phí, đối tượng | 1C | P3 | Thùng/chum ủ là TSCĐ hay CCDC tuỳ ngưỡng giá trị (C1) |
| CCDC-02 | Ghi tăng CCDC | Xuất kho 153 đưa vào dùng (phân bổ nhiều kỳ) hoặc mua dùng ngay | Nợ 242 / Có 153 (giá trị lô xuất); mua dùng ngay: Nợ 242, 1331 / Có 331. Giá trị nhỏ phân bổ 1 lần: Nợ 627/641/642 (TT133: 154/6421/6422) / Có 153 | Liên kết phiếu xuất kho (KHO-02) | 1C | P3 | 242 đổi tên "Chi phí chờ phân bổ" ở TT99 (`research/01` §1.1) |
| CCDC-03 | Phân bổ | Phân bổ tháng | Nợ 627 (TT133: 154 SXC) / 641 / 642 (TT133: 6421/6422) / Có 242 | Đều theo số kỳ; kỳ cuối nhận phần còn lại (R1(a)); chia theo bộ phận (R1(b)) | 1C | P3 (nhập qua chứng từ tổng hợp trước 1C) | Đầu vào SXC |
| CCDC-04 | Điều chỉnh | Đổi số kỳ phân bổ còn lại; điều chỉnh giá trị | Từ kỳ hiệu lực | | 1C | P3 | |
| CCDC-05 | Điều chuyển | Đổi bộ phận / địa điểm sử dụng | Không bút toán; phân bổ đi theo bộ phận mới | | 1C | P3 | |
| CCDC-06 | Ghi giảm | Hỏng, mất, thanh lý (một phần SL) | Phân bổ nốt giá trị còn lại của SL ghi giảm: Nợ 627/641/642 hoặc 1388 (bắt bồi thường) / Có 242; thu thanh lý Nợ 111 / Có 711 | SL, lý do | 1C | P3 | |
| CCDC-R1 | Sổ theo dõi CCDC | Theo CCDC × bộ phận: SL, giá trị, đã phân bổ, còn lại | — | | 1C | P3 | |
| CCDC-R2 | Bảng phân bổ CCDC | Theo kỳ × bộ phận × TK chi phí × đối tượng | — | | 1C | P3 | Khớp PS Có 242 phần CCDC |

### 3.7 Phân hệ 7 — Kho

Kho vật lý: **Nhà máy Bà Ba Thạo** (NVL, bao bì, phụ gia, thành phẩm; thủ kho Mr Phú), **Bình Tây** (Ms Trâm), **97 Nguyễn Thái Học** (Mr Hải; nơi sale admin bán hàng). Có thể cần kho con tại nhà máy (NVL / bao bì / TP / khu BTP đang ủ) — câu hỏi A3. Thêm kho ảo: "đang chuyển nội bộ", "hàng mua đi đường (151)", "hàng gửi bán (157)" nếu có.

| Mã | Tab / Báo cáo | Nghiệp vụ, chứng từ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| KHO-01 | Lệnh sản xuất | Lệnh SX **theo công đoạn** (một lô đầu vào → một/nhiều lô đầu ra), có lệnh tổng theo kế hoạch ngày; trạng thái Kế hoạch → Phát lệnh → Đang SX (đang ủ) → Hoàn thành → Đóng | Không sinh bút toán; là **đối tượng tập hợp chi phí** | Quy trình, công đoạn, SP/BTP đầu ra, SL kế hoạch, định mức NVL (BOM theo công đoạn), khu QC phụ trách, ngày bắt đầu/dự kiến xong (ủ nhiều ngày) | 1A (SL, lô); 1B (công đoạn, chi phí) | Có (BOM 1 cấp, không công đoạn) | §4 |
| KHO-02 | Xuất kho | Theo **mục đích xuất**: cho lệnh SX; dùng chung xưởng; cho bán hàng/QLDN; CCDC đưa vào dùng; khuyến mại/mẫu; huỷ hàng; trả NCC; bán (từ BAN-02) | Có 152/153/155/156; Nợ theo mục đích: 621 (TT133: 154 NVL) chi tiết lệnh, 627 (TT133: 154 SXC), 641/642 (TT133: 6421/6422), 242, 632/811/1388 (huỷ), 331 (trả NCC), 632 (bán) | Lô xuất (bắt buộc với hàng theo lô), kho, mục đích, lệnh SX; chặn lô chưa Đạt QC | 1A | Có | Bút toán sinh theo TK đối ứng của mục đích, không mặc định 154/632 (sửa C5 kế hoạch) |
| KHO-03 | Nhập kho | Nhập mua (từ MUA-02); nhập TP/BTP từ lệnh SX; nhập hàng bán trả lại; NVL thừa trả lại; phế liệu thu hồi; kiểm kê thừa | Nhập TP: Nợ 155 / Có 154 (BTP: xem GT-05); NVL thừa: Nợ 152 / Có 621 (TT133: 154); phế liệu: Nợ 152 / Có 154; kiểm kê thừa: Nợ 15x / Có 3381 | Lô (TP/BTP: mã lót do QC lập), NSX, HSD | 1A | Có | Phiếu nhập TP có giá trị **chờ giá thành** đến khi 1B tính |
| KHO-04 | Chuyển kho | Phiếu xuất kho kiêm vận chuyển nội bộ; **2 bước**: kho đi xuất → kho đến xác nhận nhận (SL thực nhận); giữ nguyên lô và giá trị lô | Cùng TK kho: không đổi số dư sổ cái; chỉ chi tiết kho. Thiếu khi nhận: xử lý như kiểm kê thiếu (1381) | Kho đi, kho đến, lô, SL gửi, SL nhận, người xác nhận | 1A | Có (1 bước) | Có cần phát hành PXK kiêm vận chuyển nội bộ dạng điện tử khi vận chuyển giữa các địa điểm — **chưa xác minh** |
| KHO-05 | Kiểm kê (thuộc Kho, khách nêu trong nhiệm vụ thủ kho) | Phiếu kiểm kê cuối tháng theo kho × lô; chênh lệch → phiếu điều chỉnh | Thiếu: Nợ 1381 / Có 15x (xử lý: Nợ 632/1388/334 / Có 1381); thừa: Nợ 15x / Có 3381 | SL sổ sách, SL thực tế, nguyên nhân | 1A | Có | Chạy **trước** tính giá thành trong khoá sổ |
| KHO-R1 | Tổng hợp tồn kho | Theo kho × mặt hàng (× lô, × HSD tuỳ chọn): đầu, nhập, xuất, cuối (SL, GT) | — | | 1A | Có (không lô) | Tổng GT = số dư TK kho (bất biến K1) |
| KHO-R2 | Chi tiết tồn kho | Sổ chi tiết vật tư theo kho × lô: từng chứng từ | — | | 1A | Có | Thẻ kho (chỉ SL) cho thủ kho |
| KHO-R3 | Chuyển kho nội bộ | Theo phiếu: đi/đến, SL gửi/nhận, chênh lệch, đang đi đường | — | | 1A | Thiếu | |
| KHO-R4 | Tổng hợp xuất kho theo lệnh SX | Theo lệnh: định mức vs thực xuất theo NVL và lô; chênh lệch | — | BOM theo công đoạn | 1A (SL) / 1B (GT) | Thiếu | |
| KHO-R5 | Báo cáo tiến độ sản xuất | Theo lệnh/công đoạn: SL kế hoạch, đã nhận NVL, đang ủ (ngày bắt đầu, ngày dự kiến xong), hoàn thành, Đạt/Không đạt QC | — | Trạng thái lệnh, phiếu QC | 1B (bản SL đơn giản ở 1A) | Thiếu | Dữ liệu từ QC khu và kế hoạch |
| KHO-R6 | Đối chiếu nhập kho – xuất kho giữa kế toán và thủ kho | Theo kho × kỳ: chứng từ thủ kho đã xác nhận nhưng kế toán chưa ghi sổ và ngược lại; lệch SL theo mặt hàng × lô; kết quả kiểm kê | — | Mỗi chứng từ kho có 2 dấu: thủ kho xác nhận (SL thực) và kế toán ghi sổ | 1A | Thiếu | Thủ kho chỉ thấy SL |

### 3.8 Phân hệ 8 — Giá thành

| Mã | Tab / Báo cáo | Nghiệp vụ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| GT-01 | Quy trình SX (tham khảo quy trình khách) | Khai báo quy trình → giai đoạn tính giá → thao tác, điểm QC, điểm sinh lô | — | §4 | 1B | P2 (phân bước) | |
| GT-02 | Tập hợp chi phí trực tiếp theo lệnh công đoạn | NVL đích danh theo lô xuất cho lệnh; BTP giai đoạn trước (đích danh lô BTP); nhân công trực tiếp | Nợ 621 / Có 152 (TT133: Nợ 154 khoản mục NVL); Nợ 622 / Có 334, 338 (TT133: 154 NC) | Lệnh SX trên mọi dòng 621/622/154 | 1B | Một phần | Lương nhập bằng chứng từ tổng hợp (không có phân hệ lương) |
| GT-03 | Phân bổ chi phí chung (SXC) | 627 (TT133: 154 SXC chưa phân bổ) phân bổ cho các lệnh **đang mở trong kỳ**, kể cả lệnh đang ủ | Kết chuyển TT99: Nợ 154 (lệnh, khoản mục) / Có 621, 622, 627. TT133: phân bổ nội bộ 154 | Tiêu thức (giờ công / SL / **khối lượng × số ngày nằm trong xưởng** cho công đoạn ủ — đề xuất); phân bổ theo R1(b) | 1B | Có (giản đơn) | Tiêu thức thật: câu hỏi B3 |
| GT-04 | Dở dang nhiều kỳ | Lệnh chưa hoàn thành cuối kỳ: dở dang = **toàn bộ chi phí luỹ kế** của lệnh (không cần % hoàn thành) | Số dư 154 chi tiết lệnh | Trạng thái lệnh cuối kỳ | 1B | Thiếu | Phù hợp công đoạn ủ kéo dài |
| GT-05 | Hoàn thành công đoạn, tính giá BTP/TP | Z lệnh = DDĐK + chi phí kỳ − phế liệu thu hồi − giá trị hỏng ngoài định mức; chia cho các lô đầu ra theo SL (R1(b)) | TP: Nợ 155 / Có 154. BTP nhập kho: Nợ 155 (chi tiết BTP) **hoặc** giữ 154 chi tiết BTP — **chưa xác minh**, KTT chọn (B4). BTP chuyển thẳng sang lệnh sau: Nợ 154 (lệnh sau) / Có 154 (lệnh trước) | SL đầu ra Đạt, SL không đạt trong/ngoài định mức, phế liệu | 1B | P2 | `research/07` §4 |
| GT-06 | Hàng không đạt QC | Trong định mức: không bút toán riêng, Z dồn vào SL đạt. Ngoài định mức: Nợ 632 (hoặc 811 / 1388 theo quyết định xử lý) / Có 154. Huỷ TP đã nhập kho: Nợ 632/811/1388 / Có 155 | Định mức hỏng theo công đoạn (%); phiếu QC và quyết định xử lý | 1B | Thiếu | VAS 02: chi phí vượt mức bình thường không tính vào giá gốc |
| GT-07 | Giá vốn đích danh | Xuất bán / xuất dùng lô nào thì giá trị = giá trị lô đó (R1(c)) | Nợ 632 / Có 155/156 | Lô trên mọi dòng xuất | 1A (hàng mua) / 1B (TP) | P2 | Phiếu xuất TP trước khi tính giá thành mang giá **tạm**, chốt khi lô TP có giá |
| GT-08 | SXC cố định dưới công suất bình thường | Phần không phân bổ → giá vốn | Nợ 632 / Có 627 (TT133: Có 154) | Công suất bình thường theo xưởng; cờ cố định/biến đổi | 1B (tuỳ chọn, tắt mặc định) | Có | Mùa vụ cá có thể làm "dưới công suất" giả nếu đo theo tháng (06a L10); hỏi B11 |
| GT-R1 | Thẻ tính giá thành sản phẩm | Theo **lô TP**: cây giai đoạn từ NVL ban đầu → các BTP → TP; mỗi giai đoạn: DDĐK, chi phí kỳ theo khoản mục (NVL, NC, SXC), BTP chuyển sang, DDCK, Z, z | — | | 1B | P2 | Đúng yêu cầu "đi từ NVL ban đầu qua nhiều giai đoạn" |
| GT-R2 | Tổng hợp chi phí SXKD theo đối tượng tập hợp chi phí | Theo lệnh / giai đoạn / SP / khu × khoản mục × kỳ | — | | 1B | Có | |
| GT-R3 | Lãi lỗ theo mặt hàng / lô / KH (P&L quản trị) | Doanh thu thuần − giá vốn đích danh = lãi gộp | — | | 1B | Thiếu | Suy ra từ mục tiêu 2 "⇒ P&L"; không có tên trong bảng phân hệ |

### 3.9 Phân hệ 9 — Tổng hợp

| Mã | Tab / Báo cáo | Nghiệp vụ | Định khoản chính | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|---|
| TH-01 | Chứng từ nghiệp vụ khác | Hạch toán tổng hợp: lương và trích theo lương, khấu hao/phân bổ (trước 1C), bù trừ công nợ, thuế, điều chỉnh | Theo nhập liệu; ràng buộc: TK kho không được hạch toán tay (K2); TK chi phí SX bắt buộc lệnh/khoản mục (I6) | | 1A | Có | |
| TH-02 | Kết chuyển lãi / lỗ | Kết chuyển giảm trừ DT, DT thuần, DT tài chính, thu nhập khác, giá vốn, chi phí, thuế TNDN, lãi lỗ → 911 → 4212 | Bảng kết chuyển **theo chế độ** (TT133: không 521, dùng 6421/6422, 821) | | 1A (thủ công) / 1C (trong quy trình khoá sổ) | Có | |
| TH-03 | Khoá sổ kỳ (ngầm định, cần cho mọi báo cáo cuối kỳ) | Quy trình khoá sổ tháng có thứ tự; khoá theo **kỳ (tháng)** | — | | 1A (khoá đơn giản) / 1C (đủ bước) | Có | |
| TH-R1 | Sổ nhật ký chung | | — | | 1A | Có | Số hiệu mẫu sổ TT99 chưa xác minh |
| TH-R2 | Sổ cái | | — | | 1A | Có | |
| TH-R3 | Sổ chi tiết các tài khoản | Theo TK × đối tượng / lệnh / khế ước / loại tiền | — | | 1A | Có | |

### 3.10 Phân hệ 10 — Báo cáo cuối tháng / năm

| Mã | Báo cáo | Nội dung | Dữ liệu cần | Đợt | v0.2 | Ghi chú |
|---|---|---|---|---|---|---|
| BC-R1 | Báo cáo KQHĐKD | B02 theo chế độ | PS đối ứng 911 | 1C (bản quản trị tháng từ 1A) | Có | |
| BC-R2 | Bảng cân đối số phát sinh | Mọi TK: dư đầu, PS, dư cuối; TT133 nộp kèm BCTC dạng "Bảng cân đối tài khoản" (F01-DNN theo `research/01`) | | 1A | Có | |
| BC-R3 | Bảng cân đối kế toán | B01 theo chế độ. `research/01` §1.1 ghi TT99 đổi tên thành "Báo cáo tình hình tài chính" (nguồn thứ cấp, chưa đối chiếu nguyên văn). Giữ tên khách dùng trên menu, in đúng tên mẫu theo chế độ | Mapping chỉ tiêu; 131/331 lấy số dư chi tiết theo đối tượng; vay tách ngắn/dài hạn theo lịch trả | 1C | Có | Mã chỉ tiêu TT99 chưa xác minh |
| BC-R4 | Báo cáo lưu chuyển tiền tệ (trực tiếp / gián tiếp) | Cả hai phương pháp | §3.10.1 | 1C | P2 | |
| BC-R5 | Thuyết minh BCTC | Không có trong tài liệu khách nhưng là bộ phận của BCTC năm | | 1C (khung + nhập tay), câu hỏi C4 | P2 | |

#### 3.10.1 LCTT — đặc tả

- **Trực tiếp**: mọi dòng bút toán vào TK tiền (111, 112, và 113 nếu dùng) mang **mã dòng tiền**. Hệ thống gợi ý theo TK đối ứng (Có 131 → thu tiền bán hàng; Nợ 331 → trả NCC; Nợ 334 → trả người lao động; Nợ 335/635 lãi vay → lãi vay đã trả; Có 341 → thu từ đi vay; Nợ 341 → trả nợ gốc; Nợ 211/241 → mua sắm TSCĐ…); người lập sửa được. Chuyển tiền nội bộ (111↔112, giữa các tài khoản NH) mang mã "nội bộ" và bị loại. Bút toán có nhiều TK đối ứng phải tách dòng tiền theo từng đối ứng.
- **Gián tiếp**: từ lợi nhuận trước thuế, điều chỉnh khoản không bằng tiền (khấu hao, dự phòng, chênh lệch tỷ giá **chưa thực hiện** do đánh giá lại, lãi/lỗ hoạt động đầu tư, chi phí lãi vay), biến động vốn lưu động (phải thu, HTK, phải trả **không gồm** phải trả mua TSCĐ và lãi vay, chi phí trả trước), lãi vay đã trả, thuế TNDN đã nộp. Công thức là cấu hình theo chế độ.
- Kiểm tra bắt buộc: lưu chuyển thuần của hai phương pháp bằng nhau; tiền cuối kỳ = số dư TK tiền trên BCĐKT (bất biến B4), có dòng "ảnh hưởng thay đổi tỷ giá" cho số dư tiền ngoại tệ đánh giá lại.
- Mã chỉ tiêu dẫn ở trên (33, 34…) theo B03-DN của TT200; mã của TT99 và B03-DNN của TT133 **chưa xác minh**.

### 3.11 Ngoại tệ (dùng chung, "có hạch toán ngoại tệ")

| Mã | Yêu cầu | Đặc tả | Đợt | v0.2 |
|---|---|---|---|---|
| NT-01 | Danh mục tiền tệ, tỷ giá theo ngày | Tỷ giá theo ngày × loại (mua / bán / chuyển khoản) × ngân hàng; nhập tay hằng ngày (không lấy tự động trong GĐ1). **Khoá tỷ giá theo ngày**: khi một ngày đã có chứng từ ghi sổ dùng tỷ giá đó hoặc ngày thuộc kỳ đã khoá thì không sửa được tỷ giá của ngày | 1A | P3 |
| NT-02 | Ghi nhận giao dịch theo tỷ giá giao dịch thực tế | Dòng bút toán lưu **nguyên tệ + tỷ giá**; VND = round(nguyên tệ × tỷ giá) theo R1(a). Mặc định tỷ giá: phải thu → tỷ giá mua; phải trả → tỷ giá bán; theo hướng dẫn TT200 về TK 413 [kiến thức chuyên môn; điều tương ứng ở TT99/TT133 chưa xác minh]. Khoản **ứng trước** cho NCC / KH trả trước: khi nhận hàng / ghi doanh thu, phần đã ứng dùng tỷ giá lúc ứng (không đánh giá lại khoản ứng trước) | 1A | P3 |
| NT-03 | Chênh lệch tỷ giá thực hiện | Thanh toán nợ / thu nợ: ghi giảm nợ theo **tỷ giá ghi sổ đích danh** của khoản nợ; xuất tiền ngoại tệ theo **tỷ giá xuất quỹ bình quân gia quyền di động** của tài khoản tiền (đề xuất; MISA có cả BQ cuối kỳ — `research/04` §1). Chênh lệch: lãi Có 515, lỗ Nợ 635. Ví dụ: trả nợ USD 1.000 ghi sổ 25.000 bằng tiền gửi USD có tỷ giá xuất quỹ 25.300 → Nợ 331: 25.000.000; Nợ 635: 300.000 / Có 1122: 25.300.000 | 1A | P3 |
| NT-04 | Đánh giá lại cuối kỳ | Số dư khoản mục tiền tệ có gốc ngoại tệ (1112, 1122, 131, 331, 341, khoản phải thu/trả khác bằng ngoại tệ; **không** gồm khoản ứng trước) theo tỷ giá cuối kỳ (tài sản: tỷ giá mua; nợ phải trả: tỷ giá bán — TT200, chưa xác minh với TT99). Chênh lệch qua 413 (*): Nợ/Có 413; sau đó kết chuyển số dư thuần 413 sang 515 (lãi) hoặc 635 (lỗ). Ví dụ: phải thu KH USD 10.000 ghi sổ 25.000, tỷ giá mua cuối kỳ 25.200 → Nợ 131: 2.000.000 / Có 413; kết chuyển Nợ 413 / Có 515: 2.000.000. Tần suất (tháng hay chỉ khi lập BCTC năm) và có đảo đầu kỳ sau hay không: **chưa xác minh / chờ KTT** (A5) | 1C | P3 |
| NT-05 | Báo cáo theo nguyên tệ | Sổ quỹ, sổ NH, công nợ, khế ước có cột nguyên tệ; LCTT có dòng ảnh hưởng tỷ giá | 1A / 1C | P3 |

Bất biến: mỗi chứng từ cân Nợ = Có **theo VND**; nguyên tệ là thông tin phụ (`research/01` I1). Một khoản mục ngoại tệ trả hết nguyên tệ thì số dư VND của khoản đó phải về 0 (chênh lệch còn lại vào 515/635).

### 3.12 Nền móng (dùng chung, cần cho mọi phân hệ)

| Mã | Yêu cầu | Đợt | v0.2 |
|---|---|---|---|
| NEN-01 | Danh mục: TK (1 chế độ), account role, khoản mục chi phí, KH/NCC/NV/ngân hàng, VTHH (cờ theo lô, theo HSD, bắt buộc QC), ĐVT + quy đổi, kho, bộ phận, khu QC | 1A | Có (trừ lô/QC) |
| NEN-02 | Số dư đầu kỳ: TK, công nợ theo chứng từ (cả nguyên tệ), **tồn kho theo kho × lô**, dở dang 154 theo lệnh, TSCĐ/CCDC, khế ước | 1A (TSCĐ/CCDC/khế ước ở 1C) | Một phần |
| NEN-03 | Người dùng, vai trò, quyền phân hệ × thao tác × phạm vi kho / khu; nhật ký truy cập | 1A | Có (thiếu phạm vi) |
| NEN-04 | Luồng duyệt dùng chung (đề nghị thanh toán, đơn mua, đơn bán vượt hạn mức, xử lý hàng không đạt, ghi giảm TSCĐ) | 1A | Thiếu |
| NEN-05 | Nhật ký sửa đổi bắt buộc, chứng từ bất biến sau ghi sổ, số CT liền mạch theo năm | 1A | Có |

---

## 4. Ánh xạ 4 quy trình sản xuất

### 4.1 Giả định chung (chưa được khách xác nhận)

- G1. **Giai đoạn tính giá** = nhóm thao tác kết thúc bằng một **BTP hoặc TP có thể đo đếm và có thể nằm chờ** (sau ủ, sau chiên, sau phối trộn). Thao tác ngắn liên tiếp trong cùng ngày gộp vào một giai đoạn.
- G2. **Mỗi giai đoạn chạy bằng một lệnh SX công đoạn**; lệnh nhận lô đầu vào (NVL hoặc BTP) và sinh lô đầu ra. Lệnh là đối tượng tập hợp chi phí. Lệnh tổng (kế hoạch ngày của Ms Thảo) gom các lệnh công đoạn.
- G3. **Mã lót** sinh ở 3 nơi: (1) tiếp nhận NVL (lô NVL, theo NCC + ngày); (2) bắt đầu mỗi giai đoạn có BTP nằm chờ (lô BTP, vd lô ủ); (3) đóng gói (lô TP in trên nhãn). Nếu khách chỉ đánh mã ở đóng gói thì lô BTP vẫn cần mã nội bộ do hệ thống sinh.
- G4. **Điểm QC** gồm mọi ô "Tiếp nhận – kiểm tra", "Kiểm tra" trong sơ đồ, cộng điểm kiểm tra thành phẩm trước khi giải phóng lô TP (đề xuất). Lô đầu ra của giai đoạn ở trạng thái Chờ kiểm đến khi QC kết luận.
- G5. **Ủ muối, ủ thính, ủ chượp, ủ đường** có thể kéo qua nhiều tháng → lệnh mở qua nhiều kỳ, dở dang = chi phí luỹ kế. "Bảo ôn" và "bảo quản" có thể kéo vài ngày đến vài tuần (đặc biệt với cá hộp sau tiệt trùng) — thời gian thật **chưa có** (B1).
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

Điểm chưa rõ: "Massage BTP" là thao tác thường xuyên hay xử lý lại BTP chưa đạt (B7); "Phân loại" có tạo nhiều sản phẩm giá trị khác nhau không (nếu có → chia giá thành theo hệ số, B6); cá linh/sặc/chốt/trèn là 4 sản phẩm cùng quy trình hay trộn.

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

Đây là chỗ duy nhất trong tài liệu khách có **nhánh Không đạt → Loại bỏ** tường minh: SL loại bỏ trong định mức dồn giá vào SL đạt; vượt định mức → Nợ 632 (hoặc 811/1388) / Có 154 (GT-06). Nếu GĐ1a và GĐ1b luôn xong trong ngày, có thể gộp vào GĐ2 bằng phương án "chuyển thẳng 154" (`research/07` §4.2).

### 4.5 Mắm dưa gang chay (khu nông sản — QC Ms Huỳnh)

Sơ đồ: Tiếp nhận NL – kiểm tra → Lật dưa – ủ muối → Kiểm tra – cắt – rửa → Ủ đường → Phối trộn (+ gia vị/phụ gia) → Cân – đóng gói – dán nhãn (+ bao bì) → Bảo quản → Thành phẩm.

| Giai đoạn tính giá | Thao tác gộp | Đầu vào | Đầu ra | Điểm QC | Sinh mã lót | Nhiều kỳ |
|---|---|---|---|---|---|---|
| GĐ0 Tiếp nhận | Tiếp nhận NL – kiểm tra; gia vị/phụ gia; bao bì | Dưa gang, muối, đường, gia vị, bao bì | Lô NVL | QC tiếp nhận | Có | Không |
| GĐ1 Ủ muối | Lật dưa – ủ muối | Lô dưa, muối | **BTP dưa muối** | Khi kết thúc ủ | Có | **Có** |
| GĐ2 Cắt rửa – ủ đường | Kiểm tra – cắt – rửa, Ủ đường | BTP GĐ1, đường | **BTP dưa ủ đường** | **Kiểm tra** (có trong sơ đồ, trước cắt) | Có | **Có** |
| GĐ3 Phối trộn – đóng gói – bảo quản | Phối trộn, Cân – đóng gói – dán nhãn, Bảo quản | BTP GĐ2, gia vị, bao bì | **TP lô** | Trước giải phóng lô TP | Có (lô TP) | Có thể |

### 4.6 Khu hàng xay (QC Ms Trâm)

Không có sơ đồ. Chưa ánh xạ được. Cần quy trình (B5).

---

## 5. Phân hệ Quản lý chất lượng (mục tiêu số 1 của khách)

### 5.1 Phạm vi đề xuất cho GĐ1

| Mã | Yêu cầu | Mô tả | Đợt |
|---|---|---|---|
| QC-01 | Điểm kiểm soát theo công đoạn | Danh mục điểm kiểm tra gắn với thao tác trong quy trình (§4) và với tiếp nhận mua; mỗi điểm có khu phụ trách, có là điểm tới hạn hay không (nếu khách có HACCP), quy tắc lấy mẫu | 1A (tiếp nhận) / 1B (công đoạn) |
| QC-02 | Bộ chỉ tiêu | Mỗi điểm có danh sách chỉ tiêu: tên, đơn vị, kiểu (số đo có giới hạn min/max, Đạt/Không đạt, ghi chú), bắt buộc hay không, hiệu lực theo ngày | 1A |
| QC-03 | Mã lót hàng (mã lô) | Sinh theo mẫu cấu hình (vd mã SP + ngày + khu + số thứ tự); gắn với lệnh SX hoặc phiếu nhập mua; NSX, HSD; in phiếu/nhãn lô (chưa quét mã vạch trong GĐ1 — đề xuất) | 1A |
| QC-04 | Phiếu kiểm tra | Theo lô × điểm: người kiểm, thời điểm, kết quả từng chỉ tiêu, SL kiểm / đạt / không đạt, kết luận **Đạt / Không đạt**, ảnh và phiếu kết quả kiểm nghiệm đính kèm. Phiếu đã chốt không sửa, chỉ huỷ có lý do | 1A |
| QC-05 | Trạng thái lô và chặn sử dụng | Lô: Chờ kiểm → Đạt (được xuất dùng/bán) / Không đạt / Tạm giữ. Hệ thống **chặn** xuất cho SX, chuyển kho bán, xuất bán đối với lô chưa Đạt (áp dụng cho nhóm hàng bật "bắt buộc QC") | 1A |
| QC-06 | Xử lý hàng không đạt | Quyết định: loại bỏ (huỷ) / làm lại / trả NCC / hạ cấp / chấp nhận có điều kiện; phân loại trong / ngoài định mức; duyệt bởi trưởng QC (vượt giá trị → KTT/BOD); sinh chứng từ kho/giá thành tương ứng (GT-06, MUA-03) | 1B |
| QC-07 | Truy xuất ngược và xuôi | Ngược: lô TP → lô BTP các giai đoạn → lô NVL → NCC, phiếu nhập, phiếu QC. Xuôi: lô NVL → mọi lô BTP/TP đã dùng → KH đã mua, SL, ngày (phục vụ thu hồi sản phẩm) | 1B (ngược 1 cấp ở 1A) |
| QC-08 | Hạn sử dụng | HSD theo SP (số ngày từ NSX) hoặc nhập tay; cảnh báo cận hạn; gợi ý xuất FEFO; báo cáo tồn theo HSD | 1A |
| QC-R1 | Báo cáo chất lượng | Tỷ lệ đạt theo điểm/khu/SP/kỳ; danh sách lô không đạt và cách xử lý; nhật ký QC theo lô | 1B |

### 5.2 Những gì **chưa rõ** (không tự đặt ra)

- Công ty có áp dụng **HACCP**, ISO 22000 hay tiêu chuẩn nào khác không; có hồ sơ kế hoạch HACCP/CCP sẵn không. Hai ảnh quy trình trong tài liệu khách có tiêu đề mục ("III. Qui trình sản xuất") và số trang, gợi ý được trích từ một bộ hồ sơ sản phẩm hoặc hồ sơ chất lượng có sẵn — **chưa xác minh**.
- Chỉ tiêu, giới hạn, tần suất lấy mẫu cụ thể ở từng điểm (độ mặn, pH, nhiệt độ/thời gian tiệt trùng, cảm quan…).
- **Mẫu biểu QC** đang dùng (giấy/Excel) — cần bản mẫu để thiết kế phiếu.
- Quy tắc mã lót hiện tại; đánh mã ở đâu; có in mã vạch/QR không.
- Kiểm nghiệm bên ngoài (phòng thí nghiệm) có cần lưu kết quả theo lô không.
- Giám sát thiết bị (nhiệt độ lò tiệt trùng, kho lạnh) — GĐ1 chỉ nhập tay, không kết nối thiết bị.

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

Có **hai người tên "Ms Trâm"** (thủ kho Bình Tây và QC hàng xay). Nếu là một người thì tài khoản đó có hai vai trò và hai phạm vi — câu hỏi A7. Chưa có ai giữ vai trò **quản trị hệ thống kỹ thuật** (tạo người dùng, sao lưu): đề xuất KTT quản trị nghiệp vụ, đơn vị triển khai quản trị kỹ thuật.

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
- Ai làm mua hàng (lập đơn mua) chưa rõ — tạm giao `KE_HOACH` lập đề xuất, `KT_KHO` lập chứng từ mua; câu hỏi A8.

---

## 7. Câu hỏi mở cho khách — sắp theo mức chặn tiến độ

**Mức A — chặn thiết kế chi tiết và đợt 1A (cần trước khi viết migration):**

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| A1 | Năm 2026 công ty áp dụng **TT99/2025 hay TT133/2016**? | 621/622/627 hay 154; 521 hay 511; 641/642 hay 6421/6422; mẫu BCTC |
| A2 | Ngày muốn dùng thật; chạy song song MISA bao lâu; đang dùng MISA bản nào; tồn kho hiện tại trong MISA **có theo lô không**? (nếu không: tồn đầu kỳ theo lô phải kiểm kê lập lô) | Số dư đầu kỳ, kế hoạch chuyển đổi |
| A3 | Cấu trúc kho: mỗi địa điểm là 1 kho hay nhiều kho con (NVL, bao bì, phụ gia, TP, khu BTP/ủ)? Bình Tây chứa hàng gì? Có địa điểm nào là chi nhánh có MST/hạch toán riêng? | Danh mục kho, phân quyền, chuyển kho |
| A4 | Quy tắc **mã lót** đang dùng (gửi mẫu); đánh mã tại tiếp nhận NVL, đầu mỗi lần ủ, hay chỉ khi đóng gói? Có in mã vạch/QR? | Mô hình lô, truy xuất |
| A5 | Ngoại tệ: đồng tiền nào; nghiệp vụ nào (nhập khẩu NVL, xuất khẩu, tài khoản NH ngoại tệ, vay ngoại tệ); tỷ giá ngân hàng nào; đánh giá lại **hằng tháng hay chỉ cuối năm**; có đảo đầu kỳ sau không | NT-01..04 |
| A6 | Luồng duyệt: đề nghị thanh toán, đơn mua, đơn bán vượt hạn mức — mấy cấp, ai duyệt, hạn mức tiền bao nhiêu | NEN-04, TIEN-01 |
| A7 | Hai "Ms Trâm" là một hay hai người? | Tài khoản, phân quyền |
| A8 | Ai đặt hàng mua (lập đơn mua) và ai nhận hóa đơn mua? | Phân quyền MUA |

**Mức B — chặn đợt 1B (giá thành, QC):**

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| B1 | Thời gian từng công đoạn ủ (muối, thính, chượp, đường) và bảo ôn/bảo quản; một bể ủ có trộn nhiều lô NVL không; có gộp/tách lô giữa các công đoạn không | Dở dang nhiều kỳ, mô hình lô |
| B2 | Định mức NVL, tỷ lệ thu hồi và **tỷ lệ không đạt được chấp nhận** (trong định mức) theo công đoạn/SP; hàng không đạt ngoài định mức xử lý vào đâu (632 / 811 / bắt bồi thường) | GT-06 |
| B3 | Nhân công trả lương theo thời gian hay sản phẩm; có chấm công theo lệnh/khu không; tiêu thức phân bổ nhân công và SXC mong muốn | GT-02, GT-03 |
| B4 | BTP có nhập kho thật, có bán ra ngoài không? KTT muốn BTP nhập kho ghi **155 hay giữ 154**? | GT-05 |
| B5 | Quy trình **khu hàng xay** | §4.6 |
| B6 | "Phân loại" (mắm cá) có tạo nhiều loại SP giá trị khác nhau không? Cá linh/sặc/chốt/trèn sản xuất riêng hay chung? | Chia giá thành liên sản phẩm |
| B7 | "Massage BTP" là thao tác thường xuyên hay xử lý lại BTP chưa đạt? | Công đoạn / làm lại |
| B8 | Có HACCP / ISO 22000? Gửi mẫu biểu QC, chỉ tiêu, giới hạn, tần suất | QC-01, QC-02 |
| B9 | HSD theo từng SP; có bắt buộc xuất theo hạn dùng gần nhất (FEFO)? | QC-08, BAN-02 |
| B10 | Phế liệu (đầu cá, nước muối…) có thu hồi bán không? | Giảm giá thành |
| B11 | Có muốn tách SXC cố định dưới công suất bình thường sang giá vốn không (VAS 02)? Công suất bình thường từng xưởng? | GT-08 |

**Mức C — chặn đợt 1C hoặc ít chặn:**

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| C1 | TSCĐ/CCDC: số lượng tài sản; khấu hao theo ngày hay tháng; ngưỡng phân biệt TSCĐ/CCDC đang dùng; điều chuyển giữa tháng tính thế nào | TSCD-03..05 |
| C2 | Khế ước: số khế ước đang có; lãi suất cố định hay thả nổi; cơ sở 365 hay 360 ngày; có trích lãi dồn tích hằng tháng không | NH-03 |
| C3 | LCTT nộp theo phương pháp nào; có cần cả hai để quản trị? | BC-R4 |
| C4 | Có lập thuyết minh BCTC năm từ hệ thống không? | BC-R5 |
| C5 | "Tổng hợp mua hàng theo … hạn mức thanh toán" nghĩa là gì; báo cáo "trả lại hàng mua / giảm giá hàng bán" trong phân hệ Mua có phải là **giảm giá hàng mua** không? | MUA-R3, MUA-R4 |
| C6 | Nhà cung cấp HĐĐT hiện tại; có cần tích hợp phát hành HĐĐT trong GĐ1 không (tài liệu khách không yêu cầu)? | Phạm vi |
| C7 | Sửa chứng từ đã ghi sổ: cho "bỏ ghi" như MISA hay bắt buộc chứng từ đảo? | Audit |
| C8 | Bán lẻ tại 97 Nguyễn Thái Học: có máy tính tiền, có xuất HĐ cho từng khách lẻ không? | BAN-02 |
| C9 | Có cho xuất âm kho không (đề xuất: **cấm**, vì đích danh theo lô) | KHO-02 |

---

## 8. Giả định quan trọng (tổng hợp)

1. Lấy "phương pháp thực tế đích danh" theo nghĩa **đích danh theo lô (mã lót)** cho mọi hàng tồn kho, kể cả bao bì và phụ gia; với hàng giá trị nhỏ, hệ thống tự gợi ý lô (FEFO/lô cũ nhất) để người dùng không phải chọn tay. Nếu KTT muốn bao bì/phụ gia dùng bình quân, cần xác minh việc dùng nhiều phương pháp cho các nhóm hàng khác nhau có phù hợp VAS 02 không (**chưa xác minh**) và kế hoạch phải ước lại.
2. Mỗi phiếu nhập mua tạo lô mới nếu người dùng không chọn lô có sẵn.
3. Giá thành theo **lệnh SX công đoạn** (lô × giai đoạn), dở dang = chi phí luỹ kế lệnh chưa xong.
4. GĐ1 không có phân hệ lương, không tích hợp HĐĐT, không kết nối ngân hàng, không ứng dụng di động; thủ kho và QC dùng web trên máy tính/máy tính bảng.
5. Một công ty, một sổ tài chính, một chế độ kế toán; khoá sổ theo tháng.
6. Ngoại tệ: giả định chủ yếu USD, số nghiệp vụ ít; tỷ giá nhập tay.
