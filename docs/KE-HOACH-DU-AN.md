# Kế hoạch dự án — Phần mềm Kế toán · Kho · Giá vốn · Giá thành (tên tạm: Outhouse)

> Phiên bản: **v0.2** (vòng lặp 2) · Ngày: 2026-10-04
> Nguồn: `docs/research/01..05` (nghiên cứu) + `06a`, `06b` (phản biện). File này là bản điều phối; chi tiết nằm ở tài liệu nghiên cứu.

## 0. Thay đổi so với v0.1

| # | Thay đổi | Lý do |
|---|---|---|
| 1 | Tiến độ MVP: **3–4 tháng → 7–9 tháng** (đội 3–4 dev) + 2–3 tháng chạy song song MISA; Phase 0: **5–6 tuần** | 06b: phạm vi ước ~18–22 người-tháng |
| 2 | Cắt MVP: 1 công ty · 1 sổ · 1 chế độ · 1 phương pháp giá xuất; **tính lại toàn bộ (vật tư, kho)** thay cho repost tăng dần; chưa partition; hash chain → P3; vòng lặp BTP/TP → báo lỗi thay vì giải hệ phương trình | 06b |
| 3 | Thêm vào MVP: hàng bán trả lại, chiết khấu/giảm giá, hàng mua đi đường (151), hàng gửi bán (157), chi phí mua về sau; nhập lương/khấu hao/phân bổ 242 bằng chứng từ tổng hợp (để có chi phí vào giá thành) | 06a L4, L5 |
| 4 | Engine giá thành dựa trên **khoản mục chi phí** (NVL/NC/SXC) + đối tượng, **không** dựa vào số TK 621/622/627 (TT133 ghi thẳng 154) | 06a L3 |
| 5 | Khoá sổ: xử lý kiểm kê thừa/thiếu **trước** tính giá xuất kho | 06a L2 |
| 6 | Kiến trúc: khoá theo cost key khi ghi sổ, repost transaction ngắn, khoá kỳ chống race, số CT gồm năm tài chính… (danh sách §4) | 06b |
| 7 | Đã sửa số học trong 01 (phân bổ 627: 12.000.000/8.000.000; BQ tức thời: 3.822.222/577.778) và golden test trong 05 | 06a L1, L6; 06b |

## 1. Mục tiêu

Xây phần mềm **Web SaaS** tương đương MISA SME/AMIS cho doanh nghiệp Việt Nam (thương mại **và** sản xuất), dùng nội bộ công ty trước, sau đó thương mại hoá. Điểm khác biệt:

1. **Giá vốn chính xác, giải thích được** — drill-down “đơn giá này lấy từ đâu”; về sau tính lại tăng dần.
2. **Truy xuất giá thành** — từ lô thành phẩm truy ngược đến lô NVL, nhân công, chi phí chung đã phân bổ (P2).
3. **Giá thành sản xuất native** — BOM đa cấp, phân bước tự động, SXC dưới công suất → 632 (MISA: BOM 1 cấp, phân bước thủ công, chỉ gói đắt nhất).
4. **TT99/2025 + TT133 sẵn từ đầu**, hệ thống tài khoản là dữ liệu cấu hình có ngày hiệu lực.

## 2. Quyết định đã chốt

| Hạng mục | Quyết định | Nguồn |
|---|---|---|
| Hình thức | Web SaaS multi-tenant (`tenant_id` + Postgres FORCE RLS) | Người dùng, 05 §2 |
| Khách hàng | Sản xuất + thương mại; công ty nội bộ là khách hàng đầu tiên | Người dùng |
| Stack | TypeScript · Node 24 · NestJS 11 (Fastify) · React 19 + Vite + TanStack + AG Grid · PostgreSQL 18 · Kysely + SQL migration · BullMQ + outbox · pnpm/Turborepo · Vitest + Testcontainers + fast-check | Người dùng, 05 §0–1 |
| Số học | `numeric` ⇄ decimal.js; cấm `float`/`number`; **một** luật làm tròn & phân bổ phần dư duy nhất (largest-remainder, ROUND_HALF_UP; đơn giá lưu 4 số lẻ, thành tiền làm tròn đồng) | 05 §1.4, 06a, 06b |
| Chế độ | TT99/2025 và TT133 (MVP chỉ bật **1** chế độ theo lựa chọn công ty); TT200 chỉ để chuyển dữ liệu lịch sử | 01, 03, 06b |
| HTK | Chỉ **kê khai thường xuyên** (TT99 bỏ 611/631) | 01 |
| Định khoản | Dùng **account role** + **khoản mục chi phí**; báo cáo map qua `standard_code`; không hardcode số hiệu TK | 01, 05 §2.3, 06a |
| Sổ kho | Append-only; bút toán 15x/154/632 sinh từ `value_change` của sổ kho (mẫu ERPNext) | 02, 05 §4.7 |
| Giá xuất | Giá tạm khi ghi sổ (`PROVISIONAL`) → chốt cuối kỳ (`FINAL`); cảnh báo tồn âm | 04, 05 §5 |
| Audit | Nhật ký sửa đổi bắt buộc (TT99), chứng từ bất biến sau ghi sổ, khoá kỳ, số CT liền mạch theo năm, lưu 10 năm | 01, 05 §7 |
| License | Chỉ **học thiết kế** từ ERPNext (GPL-3) / Odoo (LGPL-3); không chép code | 02 |

## 3. Phạm vi theo giai đoạn

### Phase 0 — Nền móng (5–6 tuần)
Monorepo + CI · migration SQL · RLS + test rò rỉ tenant · audit trigger · auth OIDC + RBAC · outbox/BullMQ · `domain-core` (Money/Qty/Decimal, phân bổ, Period) · harness golden test (YAML) với các ví dụ đã sửa của 01.

### Phase 1 — MVP (7–9 tháng): mua → kho → bán → giá vốn → giá thành giản đơn → khoá sổ

| # | Hạng mục | Ưu tiên |
|---|---|---|
| 1 | Danh mục: TK (1 chế độ), account roles, khoản mục chi phí, KH/NCC/NV, VTHH, nhóm, ĐVT + quy đổi, kho | P0 |
| 2 | Số dư đầu kỳ (TK, công nợ, tồn kho theo kho) + nhập Excel có kiểm tra | P0 |
| 3 | Quỹ, ngân hàng; **chứng từ hạch toán tổng hợp** (dùng nhập lương, khấu hao, phân bổ 242 khi chưa có phân hệ riêng) | P0 |
| 4 | Mua hàng nhập kho (VAT được/không được khấu trừ, chi phí mua phân bổ, **chi phí mua về sau**, **hàng mua đi đường 151**) | P0 |
| 5 | Bán hàng kiêm xuất kho; **hàng bán trả lại**, **chiết khấu thương mại / giảm giá**, **hàng gửi bán 157** | P0 |
| 6 | Nhập / xuất / chuyển kho, nhiều kho | P0 |
| 7 | Giá xuất kho: **1 phương pháp** theo lựa chọn công ty (BQ cuối kỳ hoặc BQ tức thời); tính lại toàn bộ theo (vật tư, kho) khi có chứng từ backdated | P0 |
| 8 | BOM 1 cấp, lệnh SX → xuất NVL, nhập TP; phế liệu thu hồi | P0 |
| 9 | Kỳ giá thành **giản đơn**: tập hợp theo khoản mục, phân bổ SXC, SXC dưới công suất → 632, dở dang, nhập giá TP | P0 |
| 10 | Kiểm kê → phiếu chênh lệch (chạy **trước** tính giá) | P0 |
| 11 | Khoá sổ theo trình tự chuẩn (01 §6 đã điều chỉnh); kết chuyển 911 | P0 |
| 12 | Người dùng, vai trò, quyền phân hệ × thao tác; nhật ký truy cập | P0 |
| 13 | Báo cáo: NKC, Sổ cái, sổ chi tiết, CĐPS, N-X-T, thẻ kho, công nợ, bảng tính giá thành, BCTC theo chế độ đã chọn (TT99 hoặc TT133), drill-down, xuất Excel | P0 |

**Tiêu chí xong MVP:** chạy song song với MISA trên dữ liệu thật **2–3 tháng**, chênh lệch giá vốn/giá thành/BCTC = 0 hoặc giải thích được từng đồng.

### Phase 2 — Sản xuất nâng cao + HĐĐT (≈4–5 tháng)
Repost tăng dần có checkpoint · FIFO + đích danh (bảng `cost_layers`), lô/HSD (FEFO), serial · BOM đa cấp, bán thành phẩm, **phân bước tự động**, hệ số/tỷ lệ, đơn đặt hàng · giải vòng BTP/TP · truy xuất giá thành (`cost_flow_edges`, `product_cost_trace`) · xử lý sản phẩm hỏng · lắp ráp/tháo dỡ, gia công · đơn mua/bán · HĐĐT 1 nhà cung cấp (NĐ 70/2025, TT 32/2025) · tờ khai GTGT XML · B03, B09 · bật chế độ thứ 2 (TT99/TT133) · partition.

### Phase 3 — SaaS hoá & mở rộng
Onboarding tự phục vụ, billing · CCDC, TSCĐ, lương (phân hệ đầy đủ) · đa tiền tệ · nhiều chi nhánh/hợp nhất · ngân hàng điện tử · report designer, API/webhook · app thủ kho quét mã vạch · hash chain audit · trợ lý AI hạch toán HĐ đầu vào.

## 4. Sửa kiến trúc bắt buộc trước khi code (từ 06b, mức Cao)

| Mã | Vấn đề | Hướng sửa |
|---|---|---|
| D1 | Số chứng từ trùng giữa các năm | Unique gồm `fiscal_year` |
| D2 | RLS không áp khi truy cập thẳng partition | Chưa partition ở MVP; khi partition phải bật RLS từng partition / cấm truy cập trực tiếp |
| D3, D4 | Dòng chứng từ POSTED bị xoá (CASCADE) hoặc chèn thêm | Bỏ CASCADE; trigger chặn INSERT/UPDATE/DELETE dòng khi header POSTED |
| A1 | Race khi ghi sổ cùng (vật tư, kho) | Advisory lock theo cost key trong transaction ghi sổ |
| A2 | Repost giữ transaction dài | Chia lô nhỏ, commit theo checkpoint |
| A3 | `jobId` cố định nuốt yêu cầu repost | Bảng yêu cầu repost trong Postgres làm nguồn sự thật, job chỉ là trigger |
| A4 | Không kiểm âm kho theo kho/lô | Lũy kế theo đúng cấp kiểm soát tồn |
| U1 | Khoá kỳ race với giao dịch đang ghi | Khoá kỳ lấy lock xung đột với lock ghi sổ (cùng advisory lock theo công ty/kỳ) |
| U2 | Hash chain tuần tự hoá cả tenant | Hoãn sang P3, thiết kế lại theo chuỗi/ngày |

Các lỗi mức TB (trigger Nợ/Có O(n²), Gauss–Seidel, `kind_rank`, FK kép còn thiếu…) xử lý trong Phase 0 — xem 06b.

## 5. Rủi ro chính

| Rủi ro | Giảm thiểu |
|---|---|
| **Chưa có kế toán trưởng duyệt đặc tả** — đường găng | Tìm ngay (nội bộ hoặc thuê bán thời gian) để duyệt 01 + 06a + golden test trước khi code engine |
| Sai giá vốn/giá thành | Golden test + property test (Nợ=Có, kho=sổ cái) + chạy song song MISA |
| Quy định chưa ổn định (TT99 mới, dự thảo thay TT133) | Mọi thứ phụ thuộc văn bản là dữ liệu có version |
| Phình phạm vi / trễ tiến độ | Giữ đúng cắt giảm §0 mục 2; mọi thứ khác vào P2/P3 |
| Rò rỉ tenant | FORCE RLS, FK kép, test rò rỉ tự động |
| DDL chưa chạy thử | Máy chưa có Node/Docker — Phase 0 phải cài và chạy toàn bộ DDL trên Postgres 18 trước |

## 6. Câu hỏi cần bạn / phòng kế toán trả lời

1. Năm 2026 công ty áp dụng **TT99 hay TT133**? Chuyển dữ liệu từ MISA mấy năm?
2. Phương pháp tính giá xuất kho đang dùng (BQ cuối kỳ / BQ tức thời / FIFO)? Theo kho hay toàn công ty?
3. Có cho xuất âm kho không? Hàng bán trả lại nhập theo giá nào?
4. Sản xuất: phương pháp giá thành, cách đánh giá dở dang, có bán thành phẩm không?
5. Sửa chứng từ: cho “bỏ ghi” như MISA hay bắt buộc chứng từ đảo?
6. Nhà cung cấp hóa đơn điện tử hiện tại?
7. Ai làm **chuyên gia nghiệp vụ / kế toán trưởng** duyệt đặc tả?
8. Đội dev dự kiến bao nhiêu người, khi nào bắt đầu?

## 7. Việc chưa xác minh (theo dõi)

- Phụ lục II TT99: TK 1562, 1385, 6275, cấp 2 của 521; mã chỉ tiêu BCTC & mẫu sổ TT99; LIFO (01 §9).
- Hiệu lực TT48/2019, TT24/2022 sau TT99; “TT 118/2026” (03 §8).
- Thời hạn thuế GTGT 8%; quy trình hóa đơn sai sót/hàng trả lại theo NĐ70/TT32.
- MISA: ĐVT quy đổi, phân quyền chi tiết (04 §6).
- Các mâu thuẫn còn lại trong 06a (ưu tiên FIFO, giá nhập hàng trả lại mặc định, cột TT133 cho kết chuyển 911) — sửa ở vòng 3 sau khi có câu trả lời §6.

## 8. Bước tiếp theo (vòng lặp 3)

1. Bạn trả lời §6 (đặc biệt câu 1, 2, 7).
2. Cập nhật 01 và 05 theo toàn bộ 06a/06b (đã sửa số học; còn trình tự khoá sổ, cột TT133, sửa DDL).
3. Cài Node 24 + Docker, khởi tạo monorepo Phase 0, chạy DDL lõi trên Postgres 18, viết golden test đầu tiên.
4. Mua giáo trình “Kế toán chi phí” (UEH) và “Kế toán tài chính” (NEU) — lộ trình đọc ở 03.

## 9. Chỉ mục tài liệu

| File | Nội dung |
|---|---|
| `research/01-nghiep-vu-ke-toan.md` | Pháp lý, TK TT200/133/99, giá xuất kho, giá thành, định khoản, khoá sổ, bất biến |
| `research/02-repo-tham-khao.md` | ERPNext, Odoo 19, iDempiere…; license; repo VN |
| `research/03-sach-tai-lieu.md` | ~60 sách/văn bản/khoá học + lộ trình đọc 4 tuần |
| `research/04-phan-tich-misa.md` | Phân hệ MISA, giá gói, điểm yếu, user story |
| `research/05-kien-truc-de-xuat.md` | Stack, multi-tenant, DDL, engine giá vốn, truy xuất, audit, kiểm thử |
| `research/06a-phan-bien-nghiep-vu.md` | 25 lỗi, 15 lỗ hổng nghiệp vụ, 11 mâu thuẫn |
| `research/06b-phan-bien-kien-truc.md` | Lỗi DDL/engine/audit, đánh giá tiến độ |
