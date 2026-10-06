# Kế hoạch dự án — Phần mềm Kế toán · Kho · Giá vốn · Giá thành · Chất lượng (tên tạm: Outhouse)

> Phiên bản: **v0.3** (vòng lặp 3) · Ngày: 2026-10-06
> Nguồn: `../HỆ THỐNG.docx` (tài liệu khách, chuẩn hoá ở `YEU-CAU-KHACH-HANG.md`), `research/01..05` (nghiên cứu), `06a`, `06b` (phản biện), `research/07` (điều chỉnh kiến trúc theo khách). File này là bản điều phối; chi tiết nằm ở các tài liệu trên.

## 0. Thay đổi so với v0.2

Lý do chung: (1) nhận tài liệu khách `HỆ THỐNG.docx` ngày 2026-10-06, mâu thuẫn với v0.2 ở nhiều điểm (H1–H7 dưới đây); (2) người dùng đã chốt **đưa đủ 10 phân hệ của khách vào Giai đoạn 1**, được chia đợt phát hành nội bộ nhưng không được cắt phân hệ.

| # | Thay đổi | Lý do |
|---|---|---|
| 1 | Phạm vi **Giai đoạn 1 (GĐ1)** = đủ 10 phân hệ (Tiền, Ngân hàng + khế ước vay, Mua, Bán, TSCĐ, CCDC, Kho, Giá thành, Tổng hợp, Báo cáo cuối tháng/năm) **+ Quản lý chất lượng**. Chia 3 đợt phát hành nội bộ **1A / 1B / 1C** (§3). Thuật ngữ "Phase 1 / MVP" của v0.2 bỏ; "Phase 2/3" đổi thành GĐ2/GĐ3 | Tài liệu khách + quyết định người dùng |
| 2 | Giá xuất chính: **thực tế đích danh theo lô (mã lót)** thay cho "1 phương pháp BQ" (H1) | Khách: "tính giá vốn theo phương pháp thực tế đích danh" |
| 3 | Giá thành: **phân bước nhiều giai đoạn có tính giá BTP**, đối tượng là **lệnh SX công đoạn** (lô × giai đoạn), dở dang nhiều kỳ cho công đoạn ủ; hàng không đạt QC trong/ngoài định mức (H2, H7) | Khách: thẻ giá thành "đi từ NVL ban đầu, qua nhiều giai đoạn"; sơ đồ có nhánh "Không đạt → Loại bỏ" và các công đoạn ủ |
| 4 | **Ngoại tệ** vào GĐ1: tỷ giá giao dịch, chênh lệch thực hiện 515/635, đánh giá lại cuối kỳ qua 413 (H3) | Khách: "có hạch toán ngoại tệ" |
| 5 | **QC + mã lô** vào GĐ1 (H4) — là mục tiêu số 1 của khách | Khách |
| 6 | **TSCĐ, CCDC, khế ước vay, đơn đặt hàng mua/bán, đề nghị thanh toán, LCTT trực tiếp/gián tiếp** vào GĐ1 (H5) | Khách |
| 7 | Rủi ro "chưa có kế toán trưởng" đổi thành "**cần KTT (Ms Nhung) dành thời gian duyệt đặc tả**" (H6) | Khách có KTT |
| 8 | **3 kho**: Nhà máy Bà Ba Thạo, Bình Tây, 97 Nguyễn Thái Học; chuyển kho 2 bước; đối chiếu kế toán – thủ kho | Khách |
| 9 | Ước lại tiến độ: **~40–56 người-tháng** phát triển (v0.2: 18–22); đội đề xuất 5 dev + 1 BA nghiệp vụ + 1 tester; code xong GĐ1 sau **~10–14 tháng**, nghiệm thu sau chạy song song **~13–17 tháng** kể từ khi bắt đầu. **Ước lượng chưa chắc chắn** (§3.5) | Phạm vi tăng ~2,2–2,5 lần |
| 10 | Chốt **luật làm tròn R1** (nguyên văn ở §2), thay ≥4 phiên bản cũ (C1) | Rà soát |
| 11 | Khoá sổ **theo kỳ (tháng)**; khoá theo ngày có thể bổ sung sau (C4) | Rà soát; giá thành theo tháng |
| 12 | Sửa diễn đạt "bút toán 15x/154/632 sinh từ `value_change`": vế kho sinh từ `value_change`, vế đối ứng theo **mục đích xuất** (C5, 06a L19) | Rà soát |
| 13 | Sửa mâu thuẫn trình tự khoá sổ (KH v0.2 dòng 61 vs dòng 123): kiểm kê chạy **trước** tính giá; `research/01` §6 đang được sửa theo hướng này ở vòng này | Rà soát |
| 14 | Đính chính v0.2 mục 0.7 "đã sửa golden test trong 05": **sai một phần** — xem §0.1 | Rà soát |
| 15 | Ngoài GĐ1 (khách không yêu cầu): tích hợp phát hành HĐĐT, phân hệ tiền lương, kết nối ngân hàng, ứng dụng di động/quét mã vạch | Tập trung phạm vi khách |

### 0.1 Lịch sử: thay đổi v0.1 → v0.2 (giữ để tra cứu, đã đính chính)

| # | Thay đổi | Lý do |
|---|---|---|
| 1 | Tiến độ MVP: 3–4 tháng → 7–9 tháng (đội 3–4 dev) + 2–3 tháng chạy song song MISA; Phase 0: 5–6 tuần | 06b |
| 2 | Cắt MVP: 1 công ty · 1 sổ · 1 chế độ · 1 phương pháp giá; tính lại toàn bộ theo cost key thay cho repost tăng dần; chưa partition; hash chain hoãn; vòng BTP/TP → báo lỗi | 06b |
| 3 | Thêm vào MVP: hàng bán trả lại, chiết khấu/giảm giá, hàng mua đi đường (151), hàng gửi bán (157), chi phí mua về sau; nhập lương/khấu hao/phân bổ 242 bằng chứng từ tổng hợp | 06a L4, L5 |
| 4 | Engine giá thành dựa trên **khoản mục chi phí** + đối tượng, không dựa vào số TK 621/622/627 (TT133 ghi thẳng 154) | 06a L3 |
| 5 | Khoá sổ: xử lý kiểm kê thừa/thiếu trước tính giá xuất kho | 06a L2 |
| 6 | Kiến trúc: khoá theo cost key khi ghi sổ, repost transaction ngắn, khoá kỳ chống race, số CT gồm năm tài chính | 06b |
| 7 | Đã sửa số học trong 01 (phân bổ 627: 12.000.000/8.000.000; BQ tức thời: 3.822.222/577.778) và kỳ vọng BQ tức thời trong YAML golden của 05. **Đính chính v0.3**: v0.2 ghi "đã sửa golden test trong 05" là **sai một phần** — tại thời điểm v0.2, phần mô tả bộ golden ở 05 vẫn ghi phân bổ 627 = 13.333.333/6.666.667 (S1), YAML hardcode `dr 621 cr 152` trong khi TT133 là 154 (S3), YAML thiếu khai báo làm tròn (S4). Các điểm này đang được sửa trong 05 ở vòng này | 06a L1, L6; 06b; rà soát v0.3 |

## 1. Mục tiêu

Xây phần mềm **Web SaaS** cho doanh nghiệp Việt Nam (sản xuất **và** thương mại), dùng cho công ty khách hàng đầu tiên (sản xuất thực phẩm: mắm cá, mắm tôm, cá bạc má sốt cà, mắm dưa gang chay; 3 địa điểm; 16 người vận hành), sau đó thương mại hoá.

Mục tiêu GĐ1 theo khách (nguyên văn): **(1) hệ thống quản lý chất lượng; (2) hệ thống số liệu, sổ sách theo dõi quy trình mua hàng → xuất hàng → giá thành ⇒ P&L.**

Điểm khác biệt của sản phẩm:
1. **Giá vốn chính xác, giải thích được** — đích danh theo lô; drill-down "giá trị này lấy từ lô nào, lệnh nào".
2. **Truy xuất lô và giá thành ngay trong GĐ1** — từ lô thành phẩm ngược về lô BTP, lô NVL, NCC, phiếu QC; xuôi từ lô NVL tới khách hàng.
3. **Giá thành nhiều giai đoạn native** — lệnh công đoạn, BTP có lô, dở dang nhiều kỳ cho công đoạn ủ (MISA: phân bước thủ công, mỗi kỳ giá thành một công đoạn — `research/04`).
4. **TT99/2025 + TT133 sẵn từ đầu**, hệ thống tài khoản là dữ liệu cấu hình có ngày hiệu lực; GĐ1 bật **một** chế độ theo lựa chọn của khách.

## 2. Quyết định đã chốt

| Hạng mục | Quyết định | Nguồn |
|---|---|---|
| Hình thức | Web SaaS multi-tenant (`tenant_id` + Postgres FORCE RLS) | Người dùng, 05 §2 |
| Khách hàng | Công ty sản xuất + thương mại thực phẩm (tài liệu `HỆ THỐNG.docx`) là khách hàng đầu tiên | Người dùng, khách |
| Phạm vi GĐ1 | **Đủ 10 phân hệ + QC**, chia đợt 1A/1B/1C; được làm mỏng tính năng trong từng phân hệ, **không** cắt phân hệ | Người dùng |
| Stack | TypeScript · Node 24 · NestJS 11 (Fastify) · React 19 + Vite + TanStack + AG Grid · PostgreSQL 18 · Kysely + SQL migration · BullMQ + outbox · pnpm/Turborepo · Vitest + Testcontainers + fast-check | Người dùng, 05 §0–1 |
| Số học | `numeric` ⇄ decimal.js; cấm `float`/`number`; **luật làm tròn duy nhất R1** (dưới bảng) | 05 §1.4, 06a, 06b, rà soát |
| Giá xuất kho | **Thực tế đích danh theo lô (mã lót)** cho mọi hàng tồn kho; cost key `(công ty, vật tư, kho, lô)`; hệ thống tự gợi ý lô (FEFO, rồi lô cũ nhất) cho hàng giá trị nhỏ | Khách, người dùng, `research/07` §2 |
| Giá thành | **Phân bước nhiều giai đoạn có tính giá BTP**; đối tượng tập hợp = lệnh SX công đoạn; dở dang nhiều kỳ = chi phí luỹ kế lệnh; hàng không đạt QC trong định mức dồn vào SL đạt, ngoài định mức ra 632/811/1388 | Khách, `research/07` §4 |
| Ngoại tệ | Nguyên tệ + tỷ giá trên dòng bút toán; tỷ giá theo ngày, **khoá theo ngày**; khoản mục mở theo chứng từ gốc; chênh lệch thực hiện 515/635; đánh giá lại cuối kỳ qua 413 (tần suất, đảo hay không: chờ KTT) | Khách, `research/07` §5 |
| Chế độ kế toán | Mặc định thiết kế và golden test theo **TT99/2025** — **chưa xác nhận**: khách chỉ ghi "hệ thống tài khoản hiện hành"; nếu khách dùng **TT133** thì đổi bộ cấu hình (621/622/627 → 154 theo khoản mục; 521 → 511; 641/642 → 6421/6422; mẫu BCTC). Câu hỏi A1. TT200 chỉ để chuyển dữ liệu lịch sử | 01, 06a L3, khách |
| HTK | Chỉ **kê khai thường xuyên** (quyết định phạm vi sản phẩm, không phải do luật — 06a L15) | 01, 06a |
| Kho | 3 địa điểm (Nhà máy Bà Ba Thạo, Bình Tây, 97 Nguyễn Thái Học), có thể có kho con; chuyển kho 2 bước (xuất – xác nhận nhận); kiểm kê cuối tháng theo lô; **cấm xuất âm** (đề xuất mặc định) | Khách |
| Định khoản | Dùng **account role** + **khoản mục chi phí**; báo cáo map qua `standard_code`; không hardcode số hiệu TK | 01, 05 §2.3, 06a |
| Sổ kho → sổ cái | Sổ kho append-only. **Vế TK kho** của bút toán sinh từ `value_change` của sổ kho; **vế đối ứng** lấy theo **tài khoản đối ứng của mục đích xuất/nhập** × chế độ: 621 (TT133: 154), 627 (TT133: 154), 641/642 (TT133: 6421/6422), 242, 632, 811, 1388, 331, 1381/3381…; không chỉ 15x/154/632 | 02, 05 §4.7, 06a L19, `research/07` §2.4 |
| Tính lại giá | Phát lại toàn bộ cost key từ mốc kỳ khoá gần nhất; repost tăng dần để GĐ2 | 06b §5 |
| Giá tạm | Lô BTP/TP chưa tính giá thành: `PENDING`; xuất lô đó mang giá tạm, chốt khi lô có giá; không cho khoá kỳ khi còn dòng chưa chốt | 05 §4.7, 07 §2.3 |
| Khoá sổ | **Theo kỳ (tháng)**: `locked_through` là ngày cuối kỳ; khoá theo ngày giữa kỳ có thể mở rộng sau. Trình tự: kiểm kê → định giá hàng mua → tập hợp, phân bổ → giá thành theo chuỗi giai đoạn → đánh giá lại ngoại tệ → kết chuyển → kiểm tra → khoá | 01 §6 (đang sửa), 05 §7.2, 07 §4.7 |
| Audit | Nhật ký sửa đổi bắt buộc (TT99), chứng từ bất biến sau ghi sổ, khoá kỳ, số CT liền mạch theo năm, lưu 10 năm | 01, 05 §7 |
| Partition | Không partition ở GĐ1 | 06b §5 |
| License | Chỉ **học thiết kế** từ ERPNext (GPL-3) / Odoo (LGPL-3); không chép code | 02 |

**Luật làm tròn duy nhất (R1)** — dùng nguyên văn ở mọi tài liệu và demo:

> (a) ROUND_HALF_UP đến đồng cho mọi số tiền. Đơn giá lưu 4 số lẻ chỉ để hiển thị/giải thích; giá trị luôn tính từ tổng giá trị, không nhân lại từ đơn giá đã làm tròn.
> (b) Phân bổ một số tiền T cho n phần theo trọng số w (SXC, chi phí mua, Z cho các phiếu nhập kho, trích theo lương…): **largest remainder** — mỗi phần lấy phần nguyên floor(T·wᵢ/W) đến đồng; số đồng còn thiếu cộng 1 đồng lần lượt cho các phần có phần lẻ lớn nhất; hòa thì theo thứ tự ổn định (ngày, số CT, số dòng).
> (c) Giá trị xuất kho = round(SL × giá trị tồn / SL tồn) theo nguồn giá (lô với đích danh/FIFO, cả kỳ với BQ cuối kỳ, thời điểm với BQ tức thời); phần dư nằm lại ở tồn; phiếu xuất làm tồn của nguồn đó về 0 nhận toàn bộ giá trị còn lại.

## 3. Phạm vi theo giai đoạn

Mã yêu cầu (TIEN-, NH-, MUA-, BAN-, TSCD-, CCDC-, KHO-, GT-, TH-, BC-, QC-, NT-, NEN-) theo `YEU-CAU-KHACH-HANG.md` §3–§5.

### 3.1 Nguyên tắc chia đợt

1. **Phụ thuộc dữ liệu**: không có danh mục, lô, kho và chứng từ thì không có giá thành; không có giá thành thì không có giá vốn TP và P&L; BCTC và LCTT cần mọi phân hệ khác đã chạy đúng.
2. **Mục tiêu số 1 của khách là QC** → phần QC không phụ thuộc giá thành (mã lót, phiếu kiểm, trạng thái lô, HSD) đi cùng 1A, để xưởng và kho dùng thật sớm nhất.
3. **Đường găng là engine giá thành** (1B) → bắt đầu thiết kế và golden test giá thành ngay từ 1A, code ở 1B.
4. **Phân hệ độc lập tương đối** (TSCĐ, CCDC, khế ước vay) để 1C và có thể làm song song từ giữa 1B bằng một dev; trước khi có, khấu hao/phân bổ/lãi vay nhập bằng chứng từ tổng hợp (cách v0.2 đã dùng).
5. Mỗi đợt có tiêu chí xong đo bằng **đối chiếu số liệu thật** (§3.4).

### 3.2 Đợt 1A — Nền móng + dòng hàng và tiền + QC lõi

| # | Hạng mục | Mã yêu cầu |
|---|---|---|
| 1 | Nền móng (Phase 0 cũ): monorepo, CI, migration SQL, RLS + test rò rỉ tenant, audit, outbox, xác thực + RBAC **theo phân hệ × thao tác × phạm vi kho/khu**, luồng duyệt dùng chung, `domain-core` (R1), harness golden test | NEN-03..05 |
| 2 | Danh mục (TK 1 chế độ, role, khoản mục, đối tượng, VTHH có cờ lô/HSD/QC, ĐVT, kho, khu); số dư đầu kỳ (TK, công nợ theo chứng từ cả nguyên tệ, **tồn kho theo kho × lô**) + nhập Excel | NEN-01, NEN-02 |
| 3 | Tiền: đề nghị thanh toán + duyệt, thu, chi; sổ quỹ, nhật ký thu/chi | TIEN-01..03, R1..R3 |
| 4 | Ngân hàng: thu, chi; sổ tiền gửi. Khế ước vay: chỉ ghi nhận giải ngân/trả gốc/lãi bằng chứng từ thường | NH-01, NH-02, NH-R1 |
| 5 | Ngoại tệ phần giao dịch: tỷ giá theo ngày + khoá ngày, nguyên tệ trên dòng, khoản mục mở, tỷ giá xuất quỹ, chênh lệch thực hiện 515/635 | NT-01..03, NT-05 |
| 6 | Mua: đơn mua, nhận hàng/HĐ (151, chi phí mua, chi phí về sau), trả lại, giảm giá; báo cáo công nợ và tổng hợp mua | MUA-01..04, R1..R4 |
| 7 | Bán: đơn bán + hạn mức dư nợ, bán hàng/HĐ (kể cả bán lẻ 97 Nguyễn Thái Học), trả lại, giảm giá; báo cáo công nợ và tổng hợp bán | BAN-01..04, R1..R4 |
| 8 | Kho: lô/mã lót, 3 kho, nhập/xuất theo mục đích, chuyển kho 2 bước, kiểm kê, đối chiếu kế toán – thủ kho; **engine đích danh theo lô** + khoá cost key + kiểm âm theo lô; lệnh SX ở mức **số lượng và lô** (chưa chi phí) | KHO-01..05, R1..R4, R6; GT-07 (hàng mua) |
| 9 | QC lõi: điểm kiểm tiếp nhận, chỉ tiêu, phiếu kiểm, trạng thái lô + chặn xuất, HSD/FEFO; truy ngược 1 cấp | QC-01..05, QC-08 |
| 10 | Tổng hợp: chứng từ nghiệp vụ khác, kết chuyển lãi lỗ thủ công, khoá sổ tháng đơn giản; NKC, sổ cái, sổ chi tiết; CĐPS | TH-01..03, R1..R3; BC-R2 |

### 3.3 Đợt 1B — Sản xuất theo công đoạn + giá thành + QC đầy đủ + P&L

| # | Hạng mục | Mã yêu cầu |
|---|---|---|
| 1 | Quy trình → giai đoạn tính giá → thao tác/điểm QC (ánh xạ 4 quy trình của khách); lệnh tổng + lệnh công đoạn; báo cáo tiến độ SX | GT-01, KHO-01, KHO-R5 |
| 2 | Giá thành đích danh nhiều giai đoạn: tập hợp theo lệnh, phân bổ SXC (khối lượng × ngày cho công đoạn ủ), dở dang nhiều kỳ, BTP (phương án A có lô / B chuyển thẳng, cấu hình theo giai đoạn), phế liệu, hàng không đạt trong/ngoài định mức, cập nhật giá lô BTP/TP và giá vốn | GT-02..08 |
| 3 | Thẻ tính giá thành theo lô TP (nhiều giai đoạn), tổng hợp chi phí theo đối tượng, tổng hợp xuất kho theo lệnh (giá trị), **lãi lỗ theo mặt hàng/lô/KH** | GT-R1..R3, KHO-R4 |
| 4 | QC đầy đủ: điểm kiểm theo công đoạn, xử lý không đạt (duyệt, sinh chứng từ), truy xuất xuôi/ngược nhiều cấp, báo cáo chất lượng | QC-01, QC-06, QC-07, QC-R1 |

### 3.4 Đợt 1C — Tài sản, vay, ngoại tệ cuối kỳ, khoá sổ và báo cáo tài chính

| # | Hạng mục | Mã yêu cầu |
|---|---|---|
| 1 | TSCĐ: khai báo, ghi tăng, khấu hao (phân bổ theo bộ phận/xưởng), điều chỉnh, điều chuyển, ghi giảm; sổ TSCĐ, bảng khấu hao | TSCD-01..06, R1, R2 |
| 2 | CCDC: khai báo, ghi tăng, phân bổ, điều chỉnh, điều chuyển, ghi giảm; sổ theo dõi, bảng phân bổ | CCDC-01..06, R1, R2 |
| 3 | Khế ước vay đầy đủ: khai báo, lãi suất theo giai đoạn, lịch trả, trích lãi tự động, theo dõi tiền vay, tách ngắn/dài hạn | NH-03, NH-R2 |
| 4 | Đánh giá lại ngoại tệ cuối kỳ (413 → 515/635) | NT-04 |
| 5 | Khoá sổ đầy đủ theo trình tự (close orchestrator), kết chuyển 911 theo chế độ | TH-02, TH-03 |
| 6 | BCTC: KQHĐKD, Bảng cân đối kế toán (tên mẫu theo chế độ), **LCTT trực tiếp và gián tiếp**, thuyết minh khung | BC-R1, BC-R3..R5 |

**Tiêu chí xong từng đợt** (đo trên dữ liệu thật của khách, chạy song song MISA):
- 1A: sổ quỹ, sổ NH, công nợ, N-X-T theo kho **khớp MISA về số lượng và giá trị hàng mua**; mọi lô NVL nhập trong tháng có phiếu QC tiếp nhận; thủ kho đối chiếu xong KHO-R6 hai tháng liên tiếp.
- 1B: giá thành và giá vốn của ít nhất 2 quy trình (đề xuất mắm tôm và cá bạc má) cho 2 kỳ liên tiếp được **KTT ký xác nhận** (MISA không có số đích danh theo lô để so, nên tiêu chí là KTT duyệt từng thẻ giá thành và bảng đối chiếu tổng 154/155/632 với sổ cái).
- 1C: CĐPS, KQHĐKD, BCĐKT khớp MISA (chênh lệch giải thích được từng đồng, phần giá vốn khác do phương pháp đích danh được liệt kê); LCTT hai phương pháp cho cùng lưu chuyển thuần.
- **Nghiệm thu GĐ1**: chạy song song toàn bộ 2–3 tháng sau 1C.

### 3.5 Ước lượng tiến độ và nhân sự (chưa chắc chắn)

Người-tháng (PM) **phát triển**, đã gồm test tự động và review, chưa gồm thời gian BA, tester, KTT và UAT. Cơ sở: ước lượng v0.2/06b (18–22 PM cho MVP hẹp hơn) cộng phần mới; chưa có số liệu năng suất thật của đội, nên sai số có thể **±30%**.

| # | Hạng mục | Đợt | PM thấp | PM cao |
|---|---|---|---|---|
| 1 | Nền móng (gồm RBAC theo kho/khu, luồng duyệt dùng chung) | 1A | 3 | 4 |
| 2 | Danh mục, lưới nhập liệu, số dư đầu kỳ (theo lô, theo chứng từ nguyên tệ), nhập Excel | 1A | 3,5 | 4,5 |
| 3 | Chứng từ + posting engine; tiền, ngân hàng, tổng hợp; bỏ ghi/version; số CT | 1A | 2,5 | 3 |
| 4 | Đề nghị thanh toán + luồng duyệt | 1A | 1 | 1,5 |
| 5 | Ngoại tệ phần giao dịch | 1A | 1,5 | 2 |
| 6 | Mua hàng (đơn mua → trả lại, giảm giá) + báo cáo | 1A | 2,5 | 3,5 |
| 7 | Bán hàng (đơn bán, hạn mức → trả lại, giảm giá) + báo cáo | 1A | 2 | 3 |
| 8 | Kho + lô + engine đích danh + chuyển kho 2 bước + kiểm kê + đối chiếu thủ kho | 1A | 3,5 | 4,5 |
| 9 | QC lõi | 1A | 1,5 | 2 |
| 10 | Sổ sách, báo cáo 1A, CĐPS | 1A | 2 | 2,5 |
| | **Cộng 1A** | | **23** | **30,5** |
| 11 | Quy trình, lệnh công đoạn, tiến độ SX | 1B | 2 | 3 |
| 12 | Engine giá thành nhiều giai đoạn + thẻ giá thành + P&L | 1B | 3,5 | 5 |
| 13 | QC đầy đủ + truy xuất | 1B | 1,5 | 2 |
| | **Cộng 1B** | | **7** | **10** |
| 14 | TSCĐ | 1C | 1,5 | 2,5 |
| 15 | CCDC | 1C | 1 | 1,5 |
| 16 | Khế ước vay | 1C | 1 | 1,5 |
| 17 | Đánh giá lại ngoại tệ | 1C | 0,5 | 1 |
| 18 | Khoá sổ đầy đủ + kết chuyển theo chế độ | 1C | 1,5 | 2 |
| 19 | BCTC + LCTT trực tiếp/gián tiếp + thuyết minh khung | 1C | 2,5 | 3,5 |
| | **Cộng 1C** | | **8** | **12** |
| 20 | Chuyển đổi dữ liệu MISA, hỗ trợ chạy song song, sửa lỗi ổn định | xuyên suốt | 2 | 3 |
| | **Tổng phát triển** | | **~40** | **~56** |

So với v0.2: 18–22 PM → ~40–56 PM (gấp ~2,2–2,5 lần). Phần tăng lớn nhất: kho theo lô + engine đích danh, giá thành nhiều giai đoạn, ngoại tệ, đơn hàng/duyệt, TSCĐ/CCDC/khế ước, LCTT hai phương pháp, QC.

**Đội đề xuất**: 5 dev (1 trưởng kỹ thuật kiêm engine giá/giá thành, 2 backend, 2 fullstack/frontend) + **1 BA nghiệp vụ kế toán** toàn thời gian (viết đặc tả, golden test, làm việc với khách) + **1 tester** + **KTT Ms Nhung ~1 ngày/tuần** duyệt đặc tả và golden test (nhiều hơn trong tháng đầu của 1B).

**Tiến độ với 5 dev** (năng suất thực tế ~4 PM/tháng sau trừ phối hợp; tháng tính từ ngày bắt đầu):

| Mốc | Tháng (ước) | Khoảng có thể |
|---|---|---|
| Nền móng xong (trong 1A) | 1,5 | 1,5–2 |
| **1A** dùng song song với MISA | 7 | 6–9 |
| **1B** dùng song song | 10 | 9–13 |
| **1C** xong code (GĐ1 code-complete) | 12 | 10–14 |
| **Nghiệm thu GĐ1** sau 2–3 tháng chạy song song toàn bộ | 15 | 13–17 |

Với 4 dev: code-complete ~13–18 tháng, nghiệm thu ~15–20 tháng. Thêm người quá 6 dev không rút ngắn tương ứng vì đường găng là engine giá/giá thành do 1–2 người nắm.

**Rủi ro trễ chính** và giảm thiểu (không cắt phân hệ):
- *Đặc tả giá thành chưa có dữ liệu thật* (thời gian ủ, định mức, tiêu thức) → gửi câu hỏi mức B ngay; BA và KTT chốt golden test giá thành **trước** khi 1B bắt đầu code; nếu đến tháng 5 chưa có số liệu thì 1B trễ tương ứng.
- *Năng suất đội chưa biết* → đo tốc độ sau nền móng và sau 1A, ước lại kế hoạch ở hai mốc này (v0.4, v0.5).
- *Nhập liệu hai lần khi chạy song song* làm 16 người quá tải → từ 1A: QC, thủ kho nhập trên hệ thống mới làm nguồn thật (QC hiện chưa có hệ thống nào); kế toán vẫn dùng MISA; chứng từ kho từ hệ thống mới xuất Excel để nhập vào MISA (khả năng nhập chứng từ kho từ Excel của MISA — `research/04` §3 — cần thử với bản khách đang dùng).
- **Làm mỏng trong từng phân hệ** (danh sách đã chốt trước, áp dụng khi chậm hơn kế hoạch ≥ 1 tháng):
  - Đề nghị thanh toán và đơn hàng: luồng duyệt cố định tối đa 2 cấp theo ngưỡng tiền, chưa có trình thiết kế luồng.
  - Đơn hàng: chưa giữ chỗ tồn kho, chưa báo giá.
  - Ngoại tệ: chỉ các đồng tiền thật sự dùng; tỷ giá nhập tay, không lấy tự động.
  - Khế ước vay: lãi suất nhập tay theo giai đoạn; lịch trả đều hoặc nhập tay; không vốn hoá lãi vay.
  - TSCĐ: chỉ khấu hao đường thẳng; chưa đánh giá lại TSCĐ. CCDC: phân bổ đều.
  - Giá thành: tối đa 2 tiêu thức phân bổ; SXC dưới công suất để tắt; thẻ giá thành nổ khoản mục theo tỷ lệ.
  - QC: chỉ tiêu dạng danh sách đơn giản; chưa biểu đồ kiểm soát; ảnh đính kèm thay vì nhập chi tiết kết quả phòng thí nghiệm.
  - LCTT gián tiếp: công thức cố định theo chế độ + dòng điều chỉnh tay có lưu vết.
  - Báo cáo: một khung lưới báo cáo chung + xuất Excel; mẫu in PDF chỉ cho chứng từ và BCTC bắt buộc.

### 3.6 Giai đoạn 2 (sau GĐ1) và Giai đoạn 3

- **GĐ2**: tích hợp HĐĐT (NĐ 70/2025, TT 32/2025), tờ khai thuế XML, phân hệ tiền lương, repost tăng dần có checkpoint, phương pháp BQ cuối kỳ / BQ tức thời / FIFO cho khách khác, giải vòng BTP/TP, bật chế độ thứ 2 (TT99/TT133), ứng dụng thủ kho/QC quét mã vạch, kết nối ngân hàng, partition.
- **GĐ3 — SaaS hoá**: onboarding tự phục vụ, billing, nhiều chi nhánh/hợp nhất, report designer, API/webhook, hash chain audit, trợ lý AI hạch toán HĐ đầu vào.

## 4. Sửa kiến trúc bắt buộc trước khi code

Các mục mức Cao của 06b — **đang được sửa trong 05 ở vòng này**; kiểm lại khi review 05:

| Mã | Vấn đề | Hướng sửa |
|---|---|---|
| D1 | Số chứng từ trùng giữa các năm | Unique gồm `fiscal_year` |
| D2 | RLS không áp khi truy cập thẳng partition | Không partition ở GĐ1; khi partition phải bật RLS từng partition |
| D3, D4 | Dòng chứng từ POSTED bị xoá (CASCADE) hoặc chèn thêm | `ON DELETE RESTRICT`; trigger chặn INSERT/UPDATE/DELETE dòng khi header POSTED; guard header |
| A1 | Race khi ghi sổ cùng cost key | Advisory lock theo cost key trong transaction ghi sổ, sắp tăng dần; với đích danh cost key = (vật tư, kho, lô) |
| A2, A3 | Repost giữ transaction dài; `jobId` cố định nuốt yêu cầu | GĐ1 dùng phát lại toàn bộ cost key; bảng yêu cầu trong Postgres là nguồn sự thật |
| A4 | Không kiểm âm theo kho/lô | Kiểm theo (vật tư, kho, lô); với đích danh trùng cost key |
| U1 | Khoá kỳ race với giao dịch đang ghi | Đọc `period_locks … FOR SHARE`; khoá kỳ bằng `UPDATE` |
| U2 | Hash chain tuần tự hoá cả tenant | Hoãn sang GĐ3, làm bất đồng bộ |

Bổ sung từ tài liệu khách (`research/07`, DDL đã chạy thử trên PG16): lô có trạng thái QC và trigger chặn xuất lô chưa Đạt; guard dùng chung cho mọi bảng có header/dòng mới (đơn hàng, đề nghị thanh toán, phiếu QC, đánh giá lại, khấu hao, lịch vay); số đơn/phiếu duy nhất theo năm; khoá tỷ giá theo ngày; CHECK cân bảng giá thành lệnh.

Các lỗi mức TB (trigger Nợ/Có O(n²), `kind_rank`, FK kép còn thiếu…) xử lý trong phần nền móng của 1A — xem 06b.

## 5. Rủi ro chính

| Rủi ro | Giảm thiểu |
|---|---|
| **Trễ tiến độ** do phạm vi GĐ1 gấp ~2,2–2,5 lần v0.2 | Chia đợt có tiêu chí xong; danh sách làm mỏng chốt trước (§3.5); ước lại sau nền móng và sau 1A; không nhận yêu cầu mới vào GĐ1 khi chưa đổi kế hoạch |
| **Cần KTT (Ms Nhung) dành thời gian duyệt đặc tả** — đường găng của 1B | Lịch cố định ~1 ngày/tuần; KTT ký golden test giá thành, định khoản theo chế độ, quy tắc xử lý hàng không đạt trước khi code; BA chuẩn bị sẵn để mỗi buổi chỉ cần quyết định |
| Chế độ kế toán chưa chốt (TT99 hay TT133) | Thiết kế theo role + khoản mục (cả hai chạy được); chốt trước khi viết golden test (câu A1) |
| Thiếu dữ liệu quy trình (thời gian ủ, định mức, tỷ lệ không đạt, tiêu thức) | Câu hỏi mức B gửi ngay; ví dụ trong 07 là giả định, phải thay bằng số thật |
| Tồn đầu kỳ theo lô không có trong MISA | Kiểm kê lập lô tại ngày chuyển đổi (lô `OPENING`); giá trị lô = giá trị tồn MISA chia theo SL (R1(b)) — KTT duyệt |
| Người dùng xưởng/kho (QC, thủ kho) chưa quen nhập liệu trên phần mềm | Màn hình riêng tối giản cho QC/thủ kho, dùng được trên máy tính bảng; đào tạo theo khu; 1A cho QC/kho dùng thật sớm |
| Đích danh theo lô cho mọi hàng làm tăng thao tác chọn lô | Hệ thống gợi ý lô (FEFO rồi lô cũ nhất); chỉ yêu cầu chọn tay khi khách muốn |
| Sai giá vốn/giá thành | Golden test do KTT ký + property test (Nợ = Có, kho = sổ cái, bảo toàn theo lô) + chạy song song |
| LCTT gián tiếp lệch trực tiếp | Kiểm tra bắt buộc hai phương pháp bằng nhau; dòng điều chỉnh tay có lưu vết |
| Quy định chưa ổn định (TT99 mới, dự thảo thay TT133, mẫu biểu TT99 chưa xác minh) | Mọi thứ phụ thuộc văn bản là dữ liệu có version |
| Rò rỉ tenant | FORCE RLS, FK kép, test rò rỉ tự động (DDL 07 đã thử 2 tenant) |
| DDL chưa chạy trên PG18 | DDL 07 đã chạy trên PG16; nền móng 1A cài PG18 và chạy toàn bộ DDL 05 + 07 trước khi viết engine |
| Tuyển đủ đội 5 dev + BA | Bắt đầu nền móng với đội nhỏ hơn; đường găng là trưởng kỹ thuật và BA |

## 6. Câu hỏi cần khách / phòng kế toán trả lời

Danh sách đầy đủ, sắp theo mức chặn tiến độ: `YEU-CAU-KHACH-HANG.md` §7. Quan trọng nhất:

1. **(A1)** Năm 2026 công ty áp dụng **TT99 hay TT133**?
2. **(A2)** Ngày muốn dùng thật; đang dùng MISA bản nào; tồn kho trong MISA có theo lô không; chuyển dữ liệu mấy năm?
3. **(A3, A4)** Cấu trúc kho con tại nhà máy; quy tắc mã lót hiện dùng và điểm sinh mã.
4. **(A5)** Ngoại tệ: đồng tiền, nghiệp vụ, ngân hàng lấy tỷ giá, tần suất đánh giá lại.
5. **(A6, A8)** Luồng duyệt và hạn mức; ai đặt hàng mua.
6. **(B1–B4)** Thời gian ủ; định mức và tỷ lệ không đạt chấp nhận được; tiêu thức phân bổ; BTP ghi 155 hay 154.
7. **(B8)** Có HACCP/ISO 22000? Mẫu biểu QC hiện dùng.
8. Đội dev dự kiến bao nhiêu người, khi nào bắt đầu? (câu hỏi cho người dùng)

Đã bỏ khỏi danh sách v0.2 vì tài liệu khách đã trả lời: phương pháp tính giá xuất kho (→ đích danh); phương pháp giá thành và có BTP hay không (→ nhiều giai đoạn, có BTP); ai là kế toán trưởng duyệt đặc tả (→ Ms Nhung). Giữ nhưng hạ mức: nhà cung cấp HĐĐT (C6, vì HĐĐT ngoài GĐ1); bỏ ghi hay chứng từ đảo (C7); xuất âm (C9, đề xuất cấm).

## 7. Việc chưa xác minh (theo dõi)

- Phụ lục II TT99: TK 1562, 1385, 6275, cấp 2 của 521; cấp 2 và số hiệu của 211/213/214/335/341/413 trong TT99; mã chỉ tiêu BCTC (gồm B03) và mẫu sổ TT99; LIFO (01 §9).
- Tên mẫu "Bảng cân đối kế toán" theo TT99: `research/01` ghi đổi thành "Báo cáo tình hình tài chính" theo nguồn thứ cấp — chưa đối chiếu nguyên văn.
- BTP nhập kho ghi 155 hay giữ 154; xuất BTP cho giai đoạn sau qua 621 hay thẳng 154 (`research/07` §4.2).
- Tỷ giá giao dịch và tỷ giá đánh giá lại theo TT99/TT133 (loại tỷ giá, tần suất, đảo hay không) — hiện dựa trên hướng dẫn TT200.
- Tình trạng hiệu lực TT 45/2013/TT-BTC (khung khấu hao, ngưỡng TSCĐ) tại 10/2026.
- Có phải lập phiếu xuất kho kiêm vận chuyển nội bộ dạng điện tử khi chuyển hàng giữa các địa điểm (NĐ 123/2020, NĐ 70/2025).
- Dùng phương pháp giá khác nhau cho các nhóm hàng khác nhau (nếu khách muốn BQ cho bao bì) có phù hợp VAS 02 không.
- Hiệu lực TT48/2019, TT24/2022 sau TT99; "TT 118/2026" (03 §8); thời hạn thuế GTGT 8%; quy trình hoá đơn sai sót/hàng trả lại theo NĐ70/TT32.
- MISA: ĐVT quy đổi, phân quyền chi tiết (04 §6); khả năng nhập chứng từ kho từ Excel ở bản khách đang dùng.

## 8. Bước tiếp theo (vòng lặp 4)

1. Gửi khách `YEU-CAU-KHACH-HANG.md` để xác nhận phạm vi, ánh xạ quy trình (§4), ma trận vai trò (§6) và trả lời câu hỏi mức A, B.
2. KTT Ms Nhung duyệt: chế độ kế toán, định khoản trong ma trận truy vết, quy tắc hàng không đạt, phương án BTP.
3. Hoàn tất sửa 01 §6 và 05 theo rà soát (đang làm ở vòng này); review 07 cùng 05.
4. Sửa demo theo B1–B5 và theo phương pháp đích danh.
5. Cài Node 24 + Docker + PostgreSQL 18, khởi tạo monorepo nền móng, chạy toàn bộ DDL 05 + 07, viết golden test đầu tiên (ví dụ §4.1, §4.3, §5.3 của 07 sau khi thay số thật).
6. Chốt đội phát triển và ngày bắt đầu; đặt lại mốc tháng ở §3.5 theo ngày thật.

## 9. Chỉ mục tài liệu

| File | Nội dung |
|---|---|
| `../HỆ THỐNG.docx` | Tài liệu khách: mục tiêu GĐ1, 10 phân hệ, 16 nhân sự, 4 sơ đồ quy trình sản xuất |
| `YEU-CAU-KHACH-HANG.md` | Yêu cầu khách chuẩn hoá: ma trận truy vết (mã yêu cầu, định khoản, đợt, mức v0.2), ánh xạ quy trình, QC, ma trận vai trò, câu hỏi mở |
| `research/01-nghiep-vu-ke-toan.md` | Pháp lý, TK TT200/133/99, giá xuất kho, giá thành, định khoản, khoá sổ, bất biến |
| `research/02-repo-tham-khao.md` | ERPNext, Odoo 19, iDempiere…; license; repo VN |
| `research/03-sach-tai-lieu.md` | ~60 sách/văn bản/khoá học + lộ trình đọc 4 tuần |
| `research/04-phan-tich-misa.md` | Phân hệ MISA, giá gói, điểm yếu, user story |
| `research/05-kien-truc-de-xuat.md` | Stack, multi-tenant, DDL, engine giá vốn, truy xuất, audit, kiểm thử |
| `research/06a-phan-bien-nghiep-vu.md` | 25 lỗi, 15 lỗ hổng nghiệp vụ, 11 mâu thuẫn |
| `research/06b-phan-bien-kien-truc.md` | Lỗi DDL/engine/audit, đánh giá tiến độ |
| `research/07-dieu-chinh-kien-truc-theo-khach-hang.md` | Thay đổi kiến trúc/dữ liệu theo khách: lô + QC, đích danh theo lô, giá thành nhiều giai đoạn có BTP, ngoại tệ, TSCĐ/CCDC, khế ước vay, đơn hàng + duyệt, LCTT; DDL đã chạy thử trên PG16 |
