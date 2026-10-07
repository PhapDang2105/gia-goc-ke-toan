# Kế hoạch dự án — Phần mềm Kế toán · Kho · Giá vốn · Giá thành · Chất lượng (tên tạm: Outhouse)

> Phiên bản: **v0.4** (vòng lặp 4) · Ngày: 2026-10-07
> Nguồn: `../HỆ THỐNG.docx` và file Excel kho BTP của khách (chuẩn hoá ở `YEU-CAU-KHACH-HANG.md` v1.2), `research/01..05` (nghiên cứu), `06a`, `06b` (phản biện vòng 2), `PHAN-BIEN-v3.md` (phản biện vòng 3), `research/07` (điều chỉnh kiến trúc theo khách). File này là bản điều phối; chi tiết nằm ở các tài liệu trên.

## 0. Thay đổi so với v0.3

Lý do chung: (1) phản biện v3 (`PHAN-BIEN-v3.md` §4: A6 ước lượng lạc quan và phạm vi kế thừa Excel chưa vào kế hoạch; A7 đợt 1A không khoá kỳ được; A9 nhiều phiên bản cho cùng một quy tắc); (2) quyết định của người dùng ngày 2026-10-07 (`YEU-CAU-KHACH-HANG.md` §1.4).

| # | Thay đổi | Lý do |
|---|---|---|
| 1 | **Mục tiêu trọng tâm**: giá vốn hàng bán của mọi sản phẩm **theo lô**, kiểm soát giá nguyên liệu theo lô, cây cấu thành giá lô TP ← lô BTP ← lô NVL (yêu cầu mới GT-09, GT-10, GT-R4, GT-R5) | Người dùng |
| 2 | **Giá thành theo lệnh SX (job-order)** — chốt: mỗi lệnh SX công đoạn là đối tượng tập hợp chi phí, dở dang = chi phí luỹ kế lệnh chưa xong (kể cả ủ nhiều kỳ); BTP luôn có lô (phương án A của `research/07` §4.2), bỏ phương án "chuyển thẳng 154" khỏi GĐ1 | Người dùng; truy vết theo lô cần lô BTP |
| 3 | **Luôn tính lại ngay** giá xuất, giá thành, giá vốn; bỏ close orchestrator; **khoá kỳ là một thao tác** có kiểm tra (vẫn bắt buộc theo luật); kết chuyển lãi/lỗ vẫn là yêu cầu. Trình tự duy nhất: `research/05` §7.2 | Người dùng; A9 |
| 4 | **Sắp lại đợt (A7)**: giá thành theo lệnh SX, giá vốn theo lô, giá NVL theo lô **vào 1A** (1A khoá kỳ được theo đúng điều kiện); đơn hàng đầy đủ + duyệt, đề nghị thanh toán, ngoại tệ giao dịch sang 1B; có mốc phát hành sớm **"Kho + QC"** trong 1A để thủ kho và QC bỏ file Excel sớm | A7; mục tiêu trọng tâm |
| 5 | Đưa **kế thừa file Excel kho** vào 1A kèm người-tháng: vị trí chứa, mã hóa, số phiếu kho, mẫu in đủ trường, tên cũ ↔ tên mới + cú pháp tên, lập phiếu xuất từ đơn (SL yêu cầu / thực xuất), giải trình kiểm kê, tồn đầu theo lô + bồn, báo cáo theo lô + vị trí, N-X-T thực tế | A6 |
| 6 | **Ước lại tiến độ trung thực (A6)**: ~43–61 người-tháng; năng suất thực tế 60–70% (5 dev ⇒ 3,0–3,5 PM/tháng); code xong GĐ1 sau **~12,5–20,5 tháng** (5 dev) hoặc **~15,5–25,5 tháng** (4 dev); có kịch bản 4 dev | A6 |
| 7 | Thống nhất một nguồn (A9): trình tự khoá kỳ (`05` §7.2); GĐ1 **tính lại toàn bộ** cost key, repost tăng dần là GĐ2 (`05` §5.5); mã lô `DDMMYY-nn`, **duy nhất theo (công ty, mặt hàng)** (`07` §2.1); hỏng ngoài định mức theo R1(b) (958.790, `07` §4.1); kiểu lưu số (`05` §1.4) | A9 |
| 8 | Kiến trúc: DDL 05 + 07 chạy nguyên văn; RLS mọi schema bằng một hàm; audit chỉ qua trigger; guard bút toán, sổ kho, header theo `jsonb`; chặn QC không lách được; duyệt/SoD ở CSDL; ranh giới bảo mật bằng vai trò CSDL thay biến phiên. 66 phép thử chạy thật (§4) | A1–A5, A10, A11 |
| 9 | Rủi ro mới: **bồn trộn nhiều lô / châm thêm** (A8, suy luận) — câu hỏi B12, mô hình "lô gộp" | A8 |
| 10 | Yêu cầu phi chức năng giao diện: đơn giản, không chữ giải thích thừa, không nhãn màu, bo góc ≤ 2px (NFR-01) | Người dùng |

### 0.1 Lịch sử

- **v0.3 (2026-10-06)**: nhận `HỆ THỐNG.docx`; GĐ1 = đủ 10 phân hệ + QC, chia 1A/1B/1C; giá xuất đích danh theo lô; giá thành nhiều giai đoạn có BTP; ngoại tệ, TSCĐ, CCDC, khế ước, đơn hàng, đề nghị thanh toán, LCTT vào GĐ1; luật làm tròn R1; khoá sổ theo kỳ tháng; ước 40–56 PM với giả định 4 PM/tháng cho 5 dev (phản biện v3 A6 cho là lạc quan).
- **v0.2**: MVP hẹp 18–22 PM; tính lại toàn bộ theo cost key thay repost tăng dần; engine giá thành theo khoản mục chi phí; đính chính golden test (S1, S3, S4) — xem `research/05` đầu tài liệu.

## 1. Mục tiêu

Xây phần mềm **Web SaaS** cho doanh nghiệp Việt Nam (sản xuất **và** thương mại), dùng cho công ty khách hàng đầu tiên (sản xuất thực phẩm: mắm cá, mắm tôm, cá bạc má sốt cà, mắm dưa gang chay; 3 địa điểm; 16 người vận hành), sau đó thương mại hoá.

Mục tiêu GĐ1 theo khách (nguyên văn): **(1) hệ thống quản lý chất lượng; (2) hệ thống số liệu, sổ sách theo dõi quy trình mua hàng → xuất hàng → giá thành ⇒ P&L.**

**Mục tiêu trọng tâm (người dùng, 2026-10-07):** biết giá vốn hàng bán của mọi sản phẩm **theo lô** — lô này giá này, lô khác giá khác; kiểm soát giá nguyên liệu theo lô; bấm vào một lô thành phẩm thấy giá vốn được cấu thành từ những lô nguyên liệu nào, giá nào (GT-09, GT-10, GT-R4, GT-R5).

Điểm khác biệt của sản phẩm:
1. **Giá vốn theo lô, giải thích được** — đích danh theo lô, giá thành theo lệnh SX; cây cấu thành "giá lô này lấy từ lô nào, lệnh nào, giá nào"; tính lại ngay khi có chứng từ.
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
| Số học | `numeric` ⇄ decimal.js; cấm `float`/`number`; **luật làm tròn duy nhất R1** (dưới bảng); kiểu lưu số: bảng duy nhất ở 05 §1.4 | 05 §1.4, 06a, 06b, rà soát |
| Giá xuất kho | **Thực tế đích danh theo lô (mã lót)** cho mọi hàng tồn kho; cost key `(công ty, vật tư, kho, lô)`; hệ thống tự gợi ý lô (FEFO, rồi lô cũ nhất) cho hàng giá trị nhỏ | Khách, người dùng, `research/07` §2 |
| Giá thành | **Theo lệnh SX (job-order)**: mỗi lệnh SX công đoạn (lô × giai đoạn) là đối tượng tập hợp chi phí; dở dang = chi phí luỹ kế lệnh chưa hoàn thành, kể cả ủ nhiều kỳ; không gộp theo sản phẩm/tháng. BTP **luôn có lô và sổ kho** (phương án A). Hàng không đạt QC trong định mức dồn vào SL đạt; ngoài định mức chia theo R1(b) với trọng số (SL đạt, SL ngoài định mức) ra 632/811/1388 | Khách, người dùng 2026-10-07, `research/07` §4 |
| Giá vốn theo lô | Mỗi lô có giá riêng; giá NVL theo lô có kiểm soát chênh lệch; cây cấu thành lô TP ← lệnh ← lô BTP/NVL (NC, SXC và lô BTP cấp cho nhiều lệnh chia theo tỷ lệ SL) | Người dùng, `research/07` §4.8 |
| Ngoại tệ | Nguyên tệ + tỷ giá trên dòng bút toán; tỷ giá theo ngày, **khoá theo ngày**; khoản mục mở theo chứng từ gốc; chênh lệch thực hiện 515/635; đánh giá lại cuối kỳ qua 413 (tần suất, đảo hay không: chờ KTT) | Khách, `research/07` §5 |
| Chế độ kế toán | Mặc định thiết kế và golden test theo **TT99/2025** — **chưa xác nhận**: khách chỉ ghi "hệ thống tài khoản hiện hành"; nếu khách dùng **TT133** thì đổi bộ cấu hình (621/622/627 → 154 theo khoản mục; 521 → 511; 641/642 → 6421/6422; mẫu BCTC). Câu hỏi A1. TT200 chỉ để chuyển dữ liệu lịch sử | 01, 06a L3, khách |
| HTK | Chỉ **kê khai thường xuyên** (quyết định phạm vi sản phẩm, không phải do luật — 06a L15) | 01, 06a |
| Kho | 3 địa điểm (Nhà máy Bà Ba Thạo, Bình Tây, 97 Nguyễn Thái Học), có thể có kho con; chuyển kho 2 bước (xuất – xác nhận nhận); vị trí chứa (bồn / trái / phuy) trong kho; kiểm kê cuối tháng theo lô + vị trí; **cấm xuất âm** (đề xuất mặc định) | Khách |
| Định khoản | Dùng **account role** + **khoản mục chi phí**; báo cáo map qua `standard_code`; không hardcode số hiệu TK | 01, 05 §2.3, 06a |
| Sổ kho → sổ cái | Sổ kho append-only. **Vế TK kho** của bút toán sinh từ `value_change` của sổ kho; **vế đối ứng** lấy theo **tài khoản đối ứng của mục đích xuất/nhập** × chế độ: 621 (TT133: 154), 627 (TT133: 154), 641/642 (TT133: 6421/6422), 242, 632, 811, 1388, 331, 1381/3381…; không chỉ 15x/154/632 | 02, 05 §4.7, 06a L19, `research/07` §2.4 |
| Tính lại giá | **Luôn tính lại ngay** khi có chứng từ: GĐ1 phát lại **toàn bộ** cost key (một lô ở một kho) từ mốc kỳ khoá gần nhất; repost tăng dần có checkpoint để GĐ2 | Người dùng, 05 §5.5 |
| Giá chưa chốt | Dòng kho mang `PROVISIONAL` tới khi khoá kỳ (SXC của kỳ còn đổi); lô TP/BTP có giá ngay khi lệnh hoàn thành. Không gắn nhãn "tạm tính" trên giao diện (NFR-01) | 05 §4.7 |
| Khoá kỳ | **Theo kỳ (tháng), một thao tác của KTT**, chạy kiểm tra cân đối (kỳ trước đã khoá, không còn yêu cầu tính lại, mọi dòng kho có giá, Nợ = Có, không tồn âm, kết chuyển không cần chạy lại, dòng tiền có mã); mở khoá chỉ KTT + lý do + nhật ký. Không có quy trình nhiều bước. **Trình tự cuối kỳ duy nhất: `research/05` §7.2** (01 §6, 07 §4.7, YEU-CAU TH-03 trích) | Người dùng, luật (TT99, Luật Kế toán) |
| Mã lô | Gợi ý `DDMMYY-nn`, sửa được, lưu chuỗi; **duy nhất theo (công ty, mặt hàng)** (file khách có 16 mã lô dùng chung nhiều mặt hàng); mã hóa (`NHÓM-YYMM-nnnn`, đề xuất) là mã duy nhất toàn công ty | `research/07` §2.1, §2.8 |
| Audit, bảo mật CSDL | Nhật ký sửa đổi bắt buộc (TT99) chỉ ghi qua trigger; chứng từ, bút toán, sổ kho bất biến sau ghi sổ; khoá kỳ; số CT liền mạch theo năm; lưu 10 năm. Ranh giới bảo mật bằng vai trò CSDL (`app_user`, `engine_user`, `auth_service`) và phiên tra từ `core.sessions`, không bằng biến phiên ứng dụng tự đặt | 01, 05 §2.1, §7 |
| Giao diện | Đơn giản, không chữ giải thích thừa, không nhãn màu, bo góc ≤ 2px (NFR-01) | Người dùng |
| Partition | Không partition ở GĐ1 | 06b §5 |
| License | Chỉ **học thiết kế** từ ERPNext (GPL-3) / Odoo (LGPL-3); không chép code | 02 |

**Luật làm tròn duy nhất (R1)** — dùng nguyên văn ở mọi tài liệu và demo:

> (a) ROUND_HALF_UP đến đồng cho mọi số tiền. Đơn giá lưu 4 số lẻ chỉ để hiển thị/giải thích; giá trị luôn tính từ tổng giá trị, không nhân lại từ đơn giá đã làm tròn.
> (b) Phân bổ một số tiền T cho n phần theo trọng số w (SXC, chi phí mua, Z cho các phiếu nhập kho, trích theo lương…): **largest remainder** — mỗi phần lấy phần nguyên floor(T·wᵢ/W) đến đồng; số đồng còn thiếu cộng 1 đồng lần lượt cho các phần có phần lẻ lớn nhất; hòa thì theo thứ tự ổn định (ngày, số CT, số dòng).
> (c) Giá trị xuất kho = round(SL × giá trị tồn / SL tồn) theo nguồn giá (lô với đích danh/FIFO, cả kỳ với BQ cuối kỳ, thời điểm với BQ tức thời); phần dư nằm lại ở tồn; phiếu xuất làm tồn của nguồn đó về 0 nhận toàn bộ giá trị còn lại.

## 3. Phạm vi theo giai đoạn

Mã yêu cầu (TIEN-, NH-, MUA-, BAN-, TSCD-, CCDC-, KHO-, GT-, TH-, BC-, QC-, NT-, NEN-, NFR-) theo `YEU-CAU-KHACH-HANG.md` v1.2 §3–§5, §9, §10.

### 3.1 Nguyên tắc chia đợt

1. **Mục tiêu trọng tâm đi đầu**: chuỗi mua → kho → sản xuất → bán và **giá vốn theo lô** nằm trọn trong 1A, vì đó là thứ khách cần nhất và là đường găng kỹ thuật.
2. **Đợt nào phát hành cũng khoá kỳ được theo đúng điều kiện** (A7): v0.3 để giá thành ở 1B nên 1A có lô TP chưa có giá, không qua được điều kiện "mọi dòng kho có giá". v0.4 đưa giá thành theo lệnh SX vào 1A. Phương án dự phòng nếu phần giá thành của 1A trễ: phát hành phần còn lại của 1A với **khoá kỳ có điều kiện** — chỉ khoá được kỳ không có lô TP/BTP chưa có giá (hàm khoá kỳ đã kiểm điều kiện này, `research/05` §7.2), các kỳ khác chờ.
3. **QC là mục tiêu số 1 của khách** → mốc phát hành sớm "Kho + QC" trong 1A (số lượng, chưa ghi sổ kế toán) để thủ kho và QC bỏ file Excel sớm nhất.
4. **Phân hệ độc lập tương đối** (đơn hàng đầy đủ + duyệt, đề nghị thanh toán, ngoại tệ; TSCĐ, CCDC, khế ước) để 1B/1C, làm song song được từ giữa 1A bằng một dev; trước khi có, khấu hao/phân bổ/lãi vay nhập bằng chứng từ tổng hợp.
5. Mỗi đợt có tiêu chí xong đo bằng **đối chiếu số liệu thật** (§3.4).

### 3.2 Đợt 1A — Kho, lô, QC, mua, bán, sản xuất và giá vốn theo lô

| # | Hạng mục | Mã yêu cầu | Mốc |
|---|---|---|---|
| 1 | Nền móng: monorepo, CI, migration SQL chạy nguyên văn DDL 05 + 07, vai trò CSDL + phiên, RLS mọi schema + test loại trừ, audit qua trigger, outbox, xác thực + RBAC theo phân hệ × thao tác × phạm vi kho/khu, `domain-core` (R1), harness golden test, bộ phép thử tấn công của `research/07` §11 trong CI | NEN-03, NEN-05, NFR-05, NFR-06 | Kho + QC |
| 2 | Danh mục (TK, role, khoản mục, đối tượng, VTHH có cờ lô/HSD/QC, **tên cũ ↔ tên mới + cú pháp 13 thuộc tính**, Mã MISA, ĐVT có số lẻ, kho, **vị trí chứa**, khu); số dư đầu (TK, công nợ theo chứng từ, **tồn kho theo lô + bồn từ sheet TonDau**) + nhập Excel | NEN-01, NEN-02, KHO-06, KHO-09, KHO-14 | Kho + QC |
| 3 | Kho: lô, **mã hóa**, mã lô `DDMMYY-nn`, **số phiếu kho PNK/PXK theo tháng**, nhập/xuất theo mục đích, chuyển kho 2 bước + chuyển bồn, kiểm kê theo lô + vị trí **có giải trình**, đối chiếu kế toán – thủ kho; **lập phiếu xuất từ đơn hàng** (đơn tối thiểu, SL yêu cầu / SL thực xuất); kiểm âm theo (vật tư, kho, lô, vị trí) | KHO-02..08, KHO-10, KHO-12, KHO-13 | Kho + QC (phần số lượng) |
| 4 | **Mẫu in** PXK/PNK đủ trường và chữ ký như file + 01-VT/02-VT; báo cáo kho theo lô + vị trí (tồn chi tiết, N-X-T theo khoảng ngày, N-X chi tiết, **N-X-T thực tế lũy kế**) | KHO-11, KHO-R1..R3, KHO-R6..R10 | Kho + QC |
| 5 | QC lõi: điểm kiểm tiếp nhận, chỉ tiêu, phiếu kiểm, trạng thái lô + chặn xuất, HSD/FEFO, phiếu xuất huỷ lô không đạt; truy ngược 1 cấp | QC-01 (tiếp nhận)..05, QC-08 | Kho + QC |
| 6 | Chứng từ + posting engine; tiền, ngân hàng (thu/chi, sổ quỹ, sổ tiền gửi, không đề nghị thanh toán); tổng hợp; số CT | TIEN-02, 03, R1..R3; NH-01, 02, R1; TH-01; TH-R1..R3 | 1A |
| 7 | Mua: nhận hàng/HĐ (151, chi phí mua, chi phí về sau), trả lại, giảm giá; công nợ và tổng hợp mua; **giá NVL theo lô + kiểm soát chênh lệch** | MUA-02..04, R1..R4; GT-09, GT-R4 | 1A |
| 8 | Bán: HĐ bán (kể cả bán lẻ 97 Nguyễn Thái Học), trả lại, giảm giá; công nợ và tổng hợp bán | BAN-02..04, R1..R4 | 1A |
| 9 | Sản xuất: quy trình → giai đoạn → thao tác (ánh xạ 4 quy trình); lệnh tổng + lệnh công đoạn; tiến độ SX; xuất NVL/BTP theo lệnh | GT-01, KHO-01, KHO-R4, KHO-R5 | 1A |
| 10 | **Giá thành theo lệnh SX**: tập hợp theo lệnh, SXC theo khối lượng × ngày, dở dang nhiều kỳ, BTP có lô, phế liệu, hỏng trong/ngoài định mức, tính lại ngay | GT-02..08 | 1A |
| 11 | **Giá vốn theo lô + cây cấu thành**, thẻ giá thành theo lô TP, giá vốn hàng bán theo lô, lãi lỗ theo mặt hàng/lô/KH | GT-10, GT-R1..R3, GT-R5 | 1A |
| 12 | Sổ sách, CĐPS, **kết chuyển lãi/lỗ**, **khoá kỳ một thao tác** | TH-02, TH-03, BC-R2 | 1A |

Mốc phát hành sớm **"Kho + QC"** = hạng mục 1, 2, 3 (phần số lượng), 4, 5: thủ kho và QC nhập trên hệ thống mới thay file Excel; chưa ghi sổ kế toán (kế toán vẫn dùng MISA).

### 3.3 Đợt 1B — Đơn hàng + duyệt, đề nghị thanh toán, ngoại tệ, QC đầy đủ

| # | Hạng mục | Mã yêu cầu |
|---|---|---|
| 1 | Đơn mua, đơn bán đầy đủ: giá, hạn mức dư nợ, theo dõi tiến độ; giá đơn mua làm mốc kiểm soát giá lô NVL | MUA-01, BAN-01 |
| 2 | Đề nghị thanh toán + luồng duyệt dùng chung (cưỡng chế ở CSDL: lịch sử duyệt append-only, SoD, không chi vượt) | TIEN-01, NEN-04 |
| 3 | Ngoại tệ phần giao dịch: tỷ giá theo ngày + khoá ngày, nguyên tệ trên dòng, khoản mục mở, tỷ giá xuất quỹ, chênh lệch thực hiện 515/635 | NT-01..03, NT-05 |
| 4 | QC đầy đủ: điểm kiểm theo công đoạn, xử lý không đạt (duyệt, sinh chứng từ), truy xuất xuôi/ngược nhiều cấp, báo cáo chất lượng | QC-01 (công đoạn), QC-06, QC-07, QC-R1 |

### 3.4 Đợt 1C — Tài sản, vay, ngoại tệ cuối kỳ, báo cáo tài chính

| # | Hạng mục | Mã yêu cầu |
|---|---|---|
| 1 | TSCĐ: khai báo, ghi tăng, khấu hao (phân bổ theo bộ phận/xưởng), điều chỉnh, điều chuyển, ghi giảm; sổ TSCĐ, bảng khấu hao | TSCD-01..06, R1, R2 |
| 2 | CCDC: khai báo, ghi tăng, phân bổ, điều chỉnh, điều chuyển, ghi giảm; sổ theo dõi, bảng phân bổ | CCDC-01..06, R1, R2 |
| 3 | Khế ước vay đầy đủ: khai báo, lãi suất theo giai đoạn, lịch trả, trích lãi tự động, theo dõi tiền vay, tách ngắn/dài hạn | NH-03, NH-R2 |
| 4 | Đánh giá lại ngoại tệ cuối kỳ (413 → 515/635) | NT-04 |
| 5 | BCTC: KQHĐKD, Bảng cân đối kế toán (tên mẫu theo chế độ), **LCTT trực tiếp và gián tiếp**, thuyết minh khung | BC-R1, BC-R3..R5 |

**Tiêu chí xong** (đo trên dữ liệu thật của khách, chạy song song MISA):
- Mốc Kho + QC: thủ kho 3 kho và 4 QC khu nhập trên hệ thống mới thay file Excel **4 tuần liên tiếp**; tồn theo lô + vị trí khớp kiểm kê cuối tháng (chênh lệch có giải trình); mọi lô NVL nhập trong tháng có phiếu QC tiếp nhận.
- 1A: N-X-T theo kho khớp MISA về **số lượng**; sổ quỹ, sổ NH, công nợ khớp MISA; giá thành và giá vốn theo lô của ít nhất 2 quy trình (đề xuất mắm tôm và cá bạc má) cho 2 kỳ liên tiếp được **KTT ký** (MISA không có số đích danh theo lô để so, nên KTT duyệt từng thẻ giá thành, cây cấu thành của mẫu lô TP và bảng đối chiếu tổng 152/154/155/632 với sổ cái); hai kỳ khoá được bằng `acc.lock_period`.
- 1B: đề nghị thanh toán và đơn hàng chạy qua luồng duyệt thật 1 tháng; chênh lệch tỷ giá thực hiện khớp tính tay của KTT.
- 1C: CĐPS, KQHĐKD, BCĐKT khớp MISA (chênh lệch giải thích được từng đồng, phần giá vốn khác do phương pháp đích danh được liệt kê); LCTT hai phương pháp cho cùng lưu chuyển thuần.
- **Nghiệm thu GĐ1**: chạy song song toàn bộ 2–3 tháng sau 1C.

### 3.5 Ước lượng tiến độ và nhân sự (không chắc chắn)

**Người-tháng (PM) phát triển**, đã gồm test tự động và review, chưa gồm BA, tester, KTT và UAT. Cơ sở: bảng v0.3 + phần phạm vi phản biện v3 chỉ ra là chưa có trong kế hoạch (A6) + phần bảo mật CSDL vừa làm − phần bỏ (close orchestrator). Chưa có số liệu năng suất thật của đội nên **sai số có thể ±30%**, và khoảng dưới đây đã rộng.

| # | Hạng mục | Đợt | PM thấp | PM cao | So với v0.3 |
|---|---|---|---|---|---|
| 1 | Nền móng (gồm vai trò CSDL, phiên, RLS mọi schema, audit trigger, bộ phép thử tấn công, RBAC theo kho/khu) | 1A | 3,5 | 5 | +0,5 / +1 (A1–A5, A11) |
| 2 | Danh mục, lưới nhập liệu, số dư đầu (theo lô + bồn), nhập Excel, **tên cũ/mới + cú pháp tên** | 1A | 3,5 | 5 | +0 / +0,5 |
| 3 | Kho + lô + **vị trí chứa, mã hóa, số phiếu kho** + engine đích danh + chuyển kho/bồn + kiểm kê có giải trình + đối chiếu thủ kho + **lập phiếu xuất từ đơn (SL yêu cầu/thực xuất)** | 1A | 4 | 5,5 | +0,5 / +1 |
| 4 | **Mẫu in** PXK/PNK + 01-VT/02-VT; báo cáo kho theo lô + vị trí, N-X-T thực tế | 1A | 1 | 1,5 | mới |
| 5 | QC lõi | 1A | 1,5 | 2 | = |
| 6 | Chứng từ + posting engine; tiền, ngân hàng, tổng hợp; số CT | 1A | 2,5 | 3 | = |
| 7 | Mua (không đơn mua) + báo cáo + **giá NVL theo lô** | 1A | 2 | 3 | đơn mua sang 1B; + giá lô |
| 8 | Bán (đơn tối thiểu) + báo cáo | 1A | 2 | 3 | = (đơn đầy đủ sang 1B) |
| 9 | Quy trình, lệnh công đoạn, tiến độ SX | 1A | 2 | 3 | từ 1B |
| 10 | **Giá thành theo lệnh SX** (tính lại ngay) | 1A | 3 | 4 | từ 1B |
| 11 | **Giá vốn theo lô + cây cấu thành**, thẻ giá thành, P&L theo lô | 1A | 1,5 | 2,5 | mới + phần từ 1B |
| 12 | Sổ sách, CĐPS, kết chuyển, **khoá kỳ một thao tác** | 1A | 2 | 2,5 | khoá đầy đủ của 1C (1,5–2) bỏ, còn khoá đơn giản |
| | **Cộng 1A** | | **28,5** | **40** | |
| | — trong đó mốc Kho + QC (1, 2, 3, 4, 5) | | 13,5 | 19 | |
| 13 | Đơn mua, đơn bán đầy đủ | 1B | 1,5 | 2 | từ 1A |
| 14 | Đề nghị thanh toán + luồng duyệt | 1B | 1 | 1,5 | từ 1A |
| 15 | Ngoại tệ phần giao dịch | 1B | 1,5 | 2 | từ 1A |
| 16 | QC đầy đủ + truy xuất nhiều cấp | 1B | 1,5 | 2 | = |
| | **Cộng 1B** | | **5,5** | **7,5** | |
| 17 | TSCĐ | 1C | 1,5 | 2,5 | = |
| 18 | CCDC | 1C | 1 | 1,5 | = |
| 19 | Khế ước vay | 1C | 1 | 1,5 | = |
| 20 | Đánh giá lại ngoại tệ | 1C | 0,5 | 1 | = |
| 21 | BCTC + LCTT trực tiếp/gián tiếp + thuyết minh khung | 1C | 2,5 | 3,5 | = |
| | **Cộng 1C** | | **6,5** | **10** | |
| 22 | Chuyển đổi dữ liệu MISA + file Excel kho, hỗ trợ chạy song song, sửa lỗi ổn định | xuyên suốt | 2,5 | 3,5 | +0,5 (Excel kho) |
| | **Tổng phát triển** | | **~43** | **~61** | v0.3: ~40–56 |

**Năng suất (A6):** v0.3 giả định 5 dev cho ~4 PM/tháng (80%). Phản biện v3 chỉ ra mức thực tế thường gặp là **60–70%** sau phối hợp, review, sửa lỗi, họp với khách ⇒ **5 dev: 3,0–3,5 PM/tháng; 4 dev: 2,4–2,8 PM/tháng**. Tháng tính từ ngày bắt đầu; mốc = PM luỹ kế ÷ năng suất (đầu khoảng: PM thấp ÷ năng suất cao; cuối khoảng: PM cao ÷ năng suất thấp).

| Mốc | PM luỹ kế | **5 dev** (tháng) | **4 dev** (tháng) |
|---|---|---|---|
| Nền móng xong | 3,5–5 | 1,5–2 | 1,5–2,5 |
| **Kho + QC** dùng thật (thay file Excel) | 13,5–19 | **4–6,5** | 5–8 |
| **1A** dùng song song MISA (giá vốn theo lô, khoá kỳ) | 28,5–40 | **8–13,5** | 10–17 |
| **1B** dùng song song | 34–47,5 | 10–16 | 12–20 |
| **1C** xong code (GĐ1 code-complete, gồm chuyển đổi) | 43–61 | **12,5–20,5** | **15,5–25,5** |
| **Nghiệm thu GĐ1** sau 2–3 tháng chạy song song | — | **14,5–23,5** | **17,5–28,5** |

Đọc bảng: với 5 dev, giữa khoảng là code xong khoảng **tháng 16–17**, nghiệm thu khoảng **tháng 19** — khớp nhận định 16–19 tháng code của phản biện v3 ở nửa trên. **Không cam kết** con số giữa khoảng trước khi đo năng suất thật. Thêm người quá 6 dev không rút ngắn tương ứng vì đường găng (engine giá, giá thành theo lệnh, cây cấu thành) do 1–2 người nắm.

**Không chắc chắn chính** (theo thứ tự ảnh hưởng): (1) năng suất thật của đội — đo sau nền móng và sau mốc Kho + QC, ước lại ở v0.5, v0.6; (2) dữ liệu quy trình (thời gian ủ, định mức, tiêu thức SXC) và trả lời B12 (bồn trộn lô — nếu có, mô hình lô gộp thêm ~0,5–1 PM); (3) khối lượng sửa theo KTT khi duyệt thẻ giá thành; (4) chất lượng dữ liệu chuyển đổi (file Excel có nhiều công thức hỏng, mã lô và ký hiệu bồn không thống nhất — `YEU-CAU-KHACH-HANG.md` §9.6); (5) chế độ kế toán và ngày bắt đầu (A1, A10).

**Đội đề xuất**: 5 dev (1 trưởng kỹ thuật kiêm engine giá/giá thành, 2 backend, 2 fullstack/frontend) + **1 BA nghiệp vụ kế toán** toàn thời gian (đặc tả, golden test, làm việc với khách) + **1 tester** + **KTT Ms Nhung ~1 ngày/tuần** duyệt đặc tả và golden test (nhiều hơn trong 2 tháng trước khi code giá thành — nay rơi vào 1A).

**Rủi ro trễ chính** và giảm thiểu (không cắt phân hệ):
- *Đặc tả giá thành chưa có dữ liệu thật* (thời gian ủ, định mức, tiêu thức) → gửi câu hỏi mức B ngay; BA và KTT chốt golden test giá thành **trước** khi bắt đầu hạng mục 10; nếu đến tháng 4 chưa có số liệu thì phần giá thành của 1A trễ tương ứng và dùng phương án dự phòng ở §3.1 mục 2.
- *Năng suất đội chưa biết* → đo tốc độ sau nền móng và sau mốc Kho + QC, ước lại kế hoạch ở hai mốc này.
- *Nhập liệu hai lần khi chạy song song* làm 16 người quá tải → từ mốc Kho + QC: QC, thủ kho nhập trên hệ thống mới làm nguồn thật; kế toán vẫn dùng MISA đến hết 1A; chứng từ kho từ hệ thống mới xuất Excel để nhập vào MISA (khả năng nhập chứng từ kho từ Excel của MISA — `research/04` §3 — cần thử với bản khách đang dùng).
- **Làm mỏng trong từng phân hệ** (danh sách chốt trước, áp dụng khi chậm hơn kế hoạch ≥ 1 tháng):
  - Đề nghị thanh toán và đơn hàng: luồng duyệt cố định tối đa 2 cấp theo ngưỡng tiền, chưa có trình thiết kế luồng.
  - Đơn hàng: chưa giữ chỗ tồn kho, chưa báo giá.
  - Ngoại tệ: chỉ các đồng tiền thật sự dùng; tỷ giá nhập tay, không lấy tự động.
  - Khế ước vay: lãi suất nhập tay theo giai đoạn; lịch trả đều hoặc nhập tay; không vốn hoá lãi vay.
  - TSCĐ: chỉ khấu hao đường thẳng; chưa đánh giá lại TSCĐ. CCDC: phân bổ đều.
  - Giá thành: tối đa 2 tiêu thức phân bổ; SXC dưới công suất để tắt; cây cấu thành hiển thị dạng bảng thụt lề (chưa vẽ đồ thị).
  - Giá NVL theo lô: một ngưỡng % cho mọi nhóm hàng.
  - QC: chỉ tiêu dạng danh sách đơn giản; chưa biểu đồ kiểm soát; ảnh đính kèm thay vì nhập chi tiết kết quả phòng thí nghiệm.
  - LCTT gián tiếp: công thức cố định theo chế độ + dòng điều chỉnh tay có lưu vết.
  - Báo cáo: một khung lưới báo cáo chung + xuất Excel; mẫu in PDF chỉ cho chứng từ, phiếu kho và BCTC bắt buộc.

### 3.6 Giai đoạn 2 (sau GĐ1) và Giai đoạn 3

- **GĐ2**: tích hợp HĐĐT (NĐ 70/2025, TT 32/2025), tờ khai thuế XML, phân hệ tiền lương, repost tăng dần có checkpoint (`research/05` §5.5), BTP chuyển thẳng 154 không qua kho (nếu cần), phương pháp BQ cuối kỳ / BQ tức thời / FIFO cho khách khác, giải vòng BTP/TP, bật chế độ thứ 2 (TT99/TT133), ứng dụng thủ kho/QC quét mã vạch, kết nối ngân hàng, partition.
- **GĐ3 — SaaS hoá**: onboarding tự phục vụ, billing, nhiều chi nhánh/hợp nhất, report designer, API/webhook, hash chain audit, trợ lý AI hạch toán HĐ đầu vào.

## 4. Kiến trúc: trạng thái sau phản biện v3

DDL của `research/05` v0.3 rồi `research/07` v0.3 **chạy nguyên văn theo thứ tự** trên PostgreSQL 16.15 (41 khối DDL, 9 truy vấn mẫu kiểm bằng `PREPARE`; chỉ thêm `uuidv7()` → `gen_random_uuid()`). **66 phép thử** chức năng và tấn công chạy bằng vai trò `app_user` đều đạt (bảng ở `research/07` §11):

| Mã (PHAN-BIEN-v3 §4) | Đã sửa | Ở đâu |
|---|---|---|
| A1 | FK kép dòng bút toán → bút toán → chứng từ; chỉ thêm dòng vào bút toán do chính giao dịch đang chạy tạo; chỉ vô hiệu hoá, không sửa/xoá; khoá kỳ áp cho dòng | 05 §4.5, §7.1, §7.2 |
| A2 | RLS mọi schema bằng `app.apply_tenant_rls()`; phép thử `app.check_rls_coverage()` theo danh sách loại trừ; audit chỉ ghi qua trigger `SECURITY DEFINER` | 05 §2.1, §7.3, §7.7 |
| A3 | CHECK `move_kind` + chiều; guard INSERT OR UPDATE; phương pháp giá hiệu lực lấy từ công ty; `qc_status` chỉ đổi qua hàm QC; lô mới luôn Chờ kiểm | 05 §4.7, 07 §2.5, §2.7, §10 |
| A4 | Guard header so `jsonb` trừ cột được phép | 07 §1 |
| A5 | Lịch sử duyệt append-only; `wf.act` kiểm vai trò bước, người lập không tự duyệt, một người không duyệt hai bước; đối tượng chỉ `APPROVED` khi có duyệt đủ số tiền; quyết toán không vượt, người duyệt không lập phiếu chi | 07 §8 |
| A9 | Một nguồn: trình tự khoá kỳ (05 §7.2), tính lại toàn bộ GĐ1 / tăng dần GĐ2 (05 §5.5), mã lô (07 §2.1), hỏng ngoài định mức (07 §4.1), kiểu số (05 §1.4) | như cột trái |
| A10 | Khối nền móng tạo extension/schema/vai trò; thêm `core.users`, `core.user_roles`, `core.sessions`, `md.partners`, `md.expense_items`; `inv.lots` tạo một lần | 05 §2.1, §4.1, §4.6; 07 §2.7 |
| A11 | Ứng dụng chỉ đặt token phiên, tenant/người dùng tra trong `core.sessions`; ghi giá trị sổ kho chỉ qua `inv.set_valuation` của `engine_user`; khoá/mở kỳ chỉ qua hàm kiểm vai trò KTT | 05 §2.1, §4.7, §7.2 |
| (mới) | `acc.period_locks`, `md.fx_rate_day_locks` sửa/gỡ được bằng DML thường — đã chặn bằng bảng quyền `sys.table_privileges` | 05 §7.7, 07 §11 |

Còn mở (làm trong nền móng 1A): chạy trên PG18; thử hai phiên đồng thời cho các guard mới và cho khoá kỳ sau khi chuyển sang hàm `SECURITY DEFINER`; property test định giá đích danh; golden test giá thành theo lệnh; đo chi phí trigger audit; các lỗi mức TB còn lại của 06b (trigger Nợ/Có O(n²), HOT update của sổ kho).

## 5. Rủi ro chính

| Rủi ro | Giảm thiểu |
|---|---|
| **Trễ tiến độ**: ~43–61 PM, code xong 12,5–20,5 tháng (5 dev) | Chia đợt có tiêu chí xong; mốc Kho + QC sớm; danh sách làm mỏng chốt trước (§3.5); ước lại sau nền móng và sau mốc Kho + QC; không nhận yêu cầu mới vào GĐ1 khi chưa đổi kế hoạch |
| **Bồn trộn nhiều lô / châm thêm** (A8, suy luận từ 3 bồn trong file từng chứa 2 lô cùng lúc) — đích danh theo lô sai bản chất nếu lô xuất ra thực chất là hỗn hợp | Hỏi khách (B12) trước khi chốt mô hình lô; nếu có: thao tác trộn là lệnh SX sinh **lô gộp** (giá trị = tổng các lô vào, phả hệ đủ nguồn); trong khi chờ: cảnh báo khi đưa lô vào bồn đang có lô khác |
| Đổi phương pháp giá / chế độ kế toán giữa niên độ khi bắt đầu dùng thật | Câu A10; đề xuất bắt đầu từ đầu năm tài chính; KTT xác nhận; chưa xác minh pháp lý (§7) |
| **Cần KTT (Ms Nhung) dành thời gian duyệt đặc tả** — đường găng của phần giá thành trong 1A | Lịch cố định ~1 ngày/tuần; KTT ký golden test giá thành, định khoản theo chế độ, quy tắc xử lý hàng không đạt trước khi code; BA chuẩn bị sẵn để mỗi buổi chỉ cần quyết định |
| Chế độ kế toán chưa chốt (TT99 hay TT133) | Thiết kế theo role + khoản mục (cả hai chạy được); chốt trước khi viết golden test (câu A1) |
| Thiếu dữ liệu quy trình (thời gian ủ, định mức, tỷ lệ không đạt, tiêu thức) | Câu hỏi mức B gửi ngay; ví dụ trong 07 là giả định, phải thay bằng số thật |
| Tồn đầu kỳ theo lô không có trong MISA | Kiểm kê lập lô + vị trí tại ngày chuyển đổi (lô `OPENING`, nhập theo cột sheet TonDau); giá trị lô = giá trị tồn MISA chia theo SL (R1(b)) — KTT duyệt |
| Người dùng xưởng/kho (QC, thủ kho) chưa quen nhập liệu trên phần mềm | Màn hình riêng tối giản cho QC/thủ kho, dùng được trên máy tính bảng; đào tạo theo khu; 1A cho QC/kho dùng thật sớm |
| Đích danh theo lô cho mọi hàng làm tăng thao tác chọn lô | Hệ thống gợi ý lô (FEFO rồi lô cũ nhất); chỉ yêu cầu chọn tay khi khách muốn |
| Sai giá vốn/giá thành | Golden test do KTT ký + property test (Nợ = Có, kho = sổ cái, bảo toàn theo lô) + chạy song song |
| LCTT gián tiếp lệch trực tiếp | Kiểm tra bắt buộc hai phương pháp bằng nhau; dòng điều chỉnh tay có lưu vết |
| Quy định chưa ổn định (TT99 mới, dự thảo thay TT133, mẫu biểu TT99 chưa xác minh) | Mọi thứ phụ thuộc văn bản là dữ liệu có version |
| Rò rỉ tenant, sửa dữ liệu trái phép từ ứng dụng | FORCE RLS mọi schema, FK kép, vai trò CSDL tách quyền, hàm `SECURITY DEFINER` có kiểm vai trò; bộ phép thử tấn công trong CI (`research/07` §11) |
| Hàm `SECURITY DEFINER` có lỗi = lỗ hổng | Quy tắc viết hàm (đặt `search_path`, tenant từ phiên, kiểm vai trò đầu hàm); review như mã bảo mật (`research/07` §12 mục 11) |
| DDL chưa chạy trên PG18 | DDL 05 + 07 đã chạy nguyên văn trên PG16 kèm 66 phép thử; nền móng 1A cài PG18 và chạy lại cùng bộ trước khi viết engine |
| Tuyển đủ đội 5 dev + BA | Bắt đầu nền móng với đội nhỏ hơn; đường găng là trưởng kỹ thuật và BA |

## 6. Câu hỏi cần khách / phòng kế toán trả lời

Danh sách đầy đủ, sắp theo mức chặn tiến độ: `YEU-CAU-KHACH-HANG.md` §7. Quan trọng nhất:

1. **(A1, A10)** Năm 2026 công ty áp dụng **TT99 hay TT133**? Ngày bắt đầu dùng thật có phải đầu năm tài chính không (đổi phương pháp giá / chế độ giữa niên độ)?
2. **(A2)** Ngày muốn dùng thật; đang dùng MISA bản nào; tồn kho trong MISA có theo lô không; chuyển dữ liệu mấy năm?
3. **(A3, A4)** Cấu trúc kho con tại nhà máy; quy tắc mã lót hiện dùng và điểm sinh mã.
4. **(A5)** Ngoại tệ: đồng tiền, nghiệp vụ, ngân hàng lấy tỷ giá, tần suất đánh giá lại.
5. **(A6, A8)** Luồng duyệt và hạn mức; ai đặt hàng mua.
6. **(B1–B4, B12)** Thời gian ủ; định mức và tỷ lệ không đạt chấp nhận được; tiêu thức phân bổ; BTP ghi 155 hay 154; **bồn có trộn nhiều lô / châm thêm không**.
7. **(B8)** Có HACCP/ISO 22000? Mẫu biểu QC hiện dùng.
8. **(D6, D8–D11)** Mã lô duy nhất theo mặt hàng; cú pháp tên; tên cũ; "số ngày lưu kho"; sheet đơn hàng.
9. Đội dev dự kiến 5 hay 4 người, khi nào bắt đầu? (câu hỏi cho người dùng — chọn kịch bản ở §3.5)

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
- Đổi phương pháp tính giá hàng tồn kho (bình quân → đích danh) hoặc đổi chế độ kế toán (TT133 ↔ TT99) **giữa niên độ**: được không, xử lý và thuyết minh thế nào (nguyên tắc nhất quán; chuẩn mực về thay đổi chính sách kế toán).
- Số hiệu mẫu phiếu nhập kho / phiếu xuất kho (01-VT, 02-VT) theo TT99.

## 8. Bước tiếp theo (vòng lặp 5)

1. Gửi khách `YEU-CAU-KHACH-HANG.md` v1.2 để xác nhận phạm vi, ánh xạ quy trình (§4), quy tắc kế thừa file Excel (§9.3, §9.8–§9.10), ma trận vai trò (§6) và trả lời câu hỏi mức A, B (ưu tiên A1, A10, B1, B12, D6, D8, D10, D11).
2. KTT Ms Nhung duyệt: chế độ kế toán, định khoản trong ma trận truy vết, giá thành theo lệnh SX và cây cấu thành giá lô (golden test `research/07` §4.1, §4.3 sau khi thay số thật), quy tắc hàng không đạt, điều kiện khoá kỳ (`research/05` §7.2).
3. Người dùng chọn kịch bản đội (5 hay 4 dev) và ngày bắt đầu; đặt mốc tháng ở §3.5 theo ngày thật.
4. Nền móng: cài Node 24 + Docker + PostgreSQL 18; chạy lại nguyên văn DDL 05 + 07 và 66 phép thử của `research/07` §11 trong CI; thêm phép thử hai phiên đồng thời.
5. Demo (làm riêng): bỏ khoá sổ 12 bước, tính lại ngay; giá vốn theo lô + cây cấu thành; lập phiếu xuất từ đơn; mẫu in đủ trường; mã lô duy nhất theo mặt hàng; giao diện theo NFR-01.

## 9. Chỉ mục tài liệu

| File | Nội dung |
|---|---|
| `../HỆ THỐNG.docx` | Tài liệu khách: mục tiêu GĐ1, 10 phân hệ, 16 nhân sự, 4 sơ đồ quy trình sản xuất |
| `YEU-CAU-KHACH-HANG.md` | Yêu cầu khách chuẩn hoá (v1.2): ma trận truy vết (mã yêu cầu, định khoản, đợt, mức v0.2), ánh xạ quy trình, QC, ma trận vai trò, câu hỏi mở, kế thừa file Excel kho, yêu cầu phi chức năng |
| `PHAN-BIEN-v3.md` | Phản biện vòng 3: lỗi demo, truy vết yêu cầu, DDL chạy thật (A1–A11) |
| `research/01-nghiep-vu-ke-toan.md` | Pháp lý, TK TT200/133/99, giá xuất kho, giá thành, định khoản, khoá sổ, bất biến |
| `research/02-repo-tham-khao.md` | ERPNext, Odoo 19, iDempiere…; license; repo VN |
| `research/03-sach-tai-lieu.md` | ~60 sách/văn bản/khoá học + lộ trình đọc 4 tuần |
| `research/04-phan-tich-misa.md` | Phân hệ MISA, giá gói, điểm yếu, user story |
| `research/05-kien-truc-de-xuat.md` | Stack, multi-tenant, vai trò CSDL + phiên, DDL, engine giá vốn, truy xuất, audit, **trình tự khoá kỳ duy nhất (§7.2)**, kiểm thử |
| `research/06a-phan-bien-nghiep-vu.md` | 25 lỗi, 15 lỗ hổng nghiệp vụ, 11 mâu thuẫn |
| `research/06b-phan-bien-kien-truc.md` | Lỗi DDL/engine/audit, đánh giá tiến độ |
| `research/07-dieu-chinh-kien-truc-theo-khach-hang.md` | Thay đổi kiến trúc/dữ liệu theo khách: lô + QC + vị trí chứa, đích danh theo lô, giá thành theo lệnh SX, giá vốn theo lô + cây cấu thành, ngoại tệ, TSCĐ/CCDC, khế ước vay, đơn hàng + duyệt, LCTT; DDL 05 + 07 chạy nguyên văn trên PG16, 66 phép thử (§11) |
