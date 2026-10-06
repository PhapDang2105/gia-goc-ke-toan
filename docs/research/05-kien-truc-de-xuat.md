# 05 — Kiến trúc đề xuất: Kế toán + Kho + Giá vốn + Giá thành (Web SaaS multi-tenant)

> Phiên bản: **0.2** (2026-10-06; bản 0.1 ngày 2026-10-04) · Trạng thái: đề xuất để review
> Phạm vi: phần mềm kế toán kiểu MISA cho doanh nghiệp Việt Nam (sản xuất + thương mại), Web SaaS multi-tenant, trước mắt dùng nội bộ.
> Stack đã chốt: **TypeScript + PostgreSQL**.
> Liên quan: `01..04` (nghiệp vụ, repo tham khảo, sách, phân tích MISA), `06b-phan-bien-kien-truc.md` (phản biện bản 0.1). Bản này đã tích hợp kết luận của `02-repo-tham-khao.md` và `04-phan-tich-misa.md` (xem §0.1); các chỗ đánh dấu **[ĐỐI CHIẾU 01/03]** cần rà lại với ví dụ số/quy định chi tiết.
> **Phạm vi & tiến độ: xem `docs/KE-HOACH-DU-AN.md` v0.3 (nguồn duy nhất).** Tài liệu này chỉ mô tả kỹ thuật, không đặt mốc thời gian.

### Đã sửa theo 06b (bản 0.2)

Mọi khối SQL của tài liệu đã được chạy thử trên **PostgreSQL 16** có sẵn trong máy (thay `uuidv7()` bằng `gen_random_uuid()`): tạo bảng/hàm/trigger không lỗi; đã thử hành vi của guard chứng từ/dòng, khoá kỳ (cả hai phiên đồng thời), cấp số CT theo năm, upsert gộp repost, truy vấn kiểm âm, domain `cost_element`, CHECK `costing_method`, `md.regime_at`. **Chưa chạy thử trên PostgreSQL 18**; chưa thử phần partition (§4.11) vì Giai đoạn 1 không dùng. Pseudo-code TS chưa chạy.

Mã D/A/U lấy từ `06b`; mã S/N/C là mã của đợt rà soát chéo sau `06b` (số liệu, đặt tên, nhất quán giữa các tài liệu).

| Mã | Lỗi | Cách sửa trong bản này | Mục |
|---|---|---|---|
| D1 | Unique số CT thiếu năm; prefix cố định | `acc.documents.fiscal_year` + unique `(tenant, company, doc_type, fiscal_year, doc_no)`; `document_sequences` có `prefix_template` chứa `{YY}`, cấp số bằng `INSERT … ON CONFLICT DO UPDATE` (cũng sửa U4) | §4.4, §7.4 |
| D2 | RLS không áp cho partition truy cập trực tiếp | Bỏ `PARTITION BY` ở Giai đoạn 1; ghi rõ khi nào partition và các yêu cầu RLS cho từng partition | §4.5, §4.7, §4.11, §6.1, §7.3 |
| D3 | `ON DELETE CASCADE` + guard chỉ bằng lời | FK dòng chứng từ `ON DELETE RESTRICT`; DDL trigger `acc.guard_documents()` (cấm xoá chứng từ đã có số/không DRAFT, chỉ cho chuyển trạng thái hợp lệ) | §4.4, §7.1 |
| D4 | Trigger dòng thiếu INSERT, dùng `OLD` | `BEFORE INSERT OR UPDATE OR DELETE`, `COALESCE(NEW.document_id, OLD.document_id)`, kiểm cả chứng từ cũ khi dòng đổi `document_id`, đọc header `FOR SHARE` | §7.1 |
| A1 | Ghi sổ không khoá cost key | `postDocument` lấy `pg_advisory_xact_lock` cho mọi khoá (cost key + khoá tồn vật lý), sắp tăng dần; cấp `seq` sau khoá; cấp số CT ở cuối transaction (cũng sửa A16) | Phụ lục A, §5.1 |
| A2 | Repost một transaction dài | Claim request bằng transaction ngắn (`FOR UPDATE SKIP LOCKED`, lease), xử lý theo lô, mỗi lô một transaction, lưu checkpoint | §5.5 |
| A3 | `jobId` cố định nuốt yêu cầu repost | `cst.repost_requests` là nguồn sự thật; job BullMQ chỉ để đánh thức, `jobId = request id`; cron quét QUEUED tồn và RUNNING hết lease | §1.5, §5.5 |
| A4 | Kiểm âm bằng `qty_after` theo cost key | Kiểm âm theo đúng cấp kiểm soát `(item, warehouse, lot)` bằng lũy kế vật lý tính tại lúc ghi sổ, dưới khoá A1 | §4.7, §5.7 |
| U1/U3 | Race khoá kỳ; scope `IN ('ALL','ALL')` | Trigger đọc `period_locks … FOR SHARE`; khoá kỳ bằng `UPDATE` (khoá xung đột); scope lấy từ cột `lock_scope` của dòng; kiểm cả `OLD` và DELETE; gắn thêm `documents` | §4.3, §7.2 |
| U2 | Hash chain khoá theo tenant | Hash chain chuyển ra sau Giai đoạn 1 (bản 0.1 gọi là P3), làm bất đồng bộ; không còn advisory lock theo tenant trên đường ghi sổ | §7.3 |
| A5/A6/A9/A13 | Pseudo-code thiếu `kind_rank`, biến chưa khai báo; upsert bỏ `kind_rank`; điều kiện hội tụ sai; largest remainder định nghĩa sai | Định nghĩa `kind_rank` và `compareKey` dùng chung; khai báo biến; upsert gộp so sánh đủ 4 thành phần; điều kiện hội tụ theo cột có trọng số + dừng khi giá trị làm tròn đến đồng không đổi; `largestRemainder` đúng R1 (b) | §1.4, §5.1–§5.6, §5.8 |
| S1 | Golden phân bổ 627 = 13.333.333/6.666.667 | Sửa 12.000.000/8.000.000 + thêm ca có dư 10.000.000 chia 3 → 3.333.334/3.333.333/3.333.333 | §8.3 |
| S3 | Golden hardcode `621` | Kỳ vọng bút toán theo role + khoản mục; ánh xạ TK riêng cho TT99/TT133 | §8.3 |
| S4 | YAML thiếu khai báo làm tròn | Thêm khối `rounding` (R1) bắt buộc | §8.3 |
| N1 | `MC` không có trong CHECK `cost_pools` | Domain `mfg.cost_element` dùng chung (`DM, DL, MC, MOH`) cho mọi bảng | §4.10, §5.9 |
| N2 | Hai nguồn sự thật cho chế độ kế toán | Bỏ `companies.accounting_regime`; suy ra từ `company_chart_assignments` theo ngày (`md.regime_at`) | §2.3, §4.1 |
| N3 | `items.costing_method` không CHECK | CHECK gồm `SPECIFIC` (đích danh — phương pháp khách hàng dùng) | §4.6 |
| N4 | Test "mọi bảng có tenant_id" fail với bảng hệ thống | Danh sách loại trừ tường minh `core.tenants`, `sys.*` | §2.1 |
| C1 | Nhiều luật làm tròn | Dùng R1 (nguyên văn ở §1.4) | §1.4, §5.2–§5.4, §5.8 |
| C2/C3 | Tiến độ, phạm vi theo phase lệch kế hoạch | §8.1 chỉ còn thứ tự phụ thuộc kỹ thuật; phạm vi & tiến độ tham chiếu `KE-HOACH-DU-AN.md` v0.3 | §8.1 |
| C4 | Khoá theo ngày hay theo kỳ chưa chốt | Khoá sổ theo **kỳ tháng** (`locked_through` = ngày cuối một kỳ); khoá theo ngày có thể thêm về sau | §4.3, §7.2 |

Xử lý kèm: A16 (cấp số CT cuối transaction, cùng A1), U4 (cấp số bằng `ON CONFLICT`, cùng D1), U5 một phần (chứng từ đã có số không xoá được, không đổi năm), U7 một phần (REVOKE thêm TRUNCATE). A12 (golden BQ tức thời 1.155.555/577.778) đã đúng từ trước.
Chưa xử lý trong bản này (vẫn mở theo 06b): D5–D10, D11 (chỉ ghi chú), D12–D23, A7, A8, A10, A11, A14, A15, U6, M1–M8 (phần tiến độ/phạm vi nay thuộc `KE-HOACH-DU-AN.md`).

## 0. Tóm tắt quyết định (TL;DR)

| Hạng mục | Quyết định | Lý do ngắn |
|---|---|---|
| Runtime | Node.js 24 LTS | LTS hiện hành, hỗ trợ đến 2028 |
| Backend | **NestJS 11 + Fastify adapter**, module theo bounded context | DI + module rõ ràng cho miền lớn; Fastify nhanh |
| API contract | REST + **Zod** schema dùng chung (ts-rest hoặc `@nestjs/zod`-style), sinh OpenAPI | Kiểu dùng chung FE/BE, vẫn mở cho tích hợp bên thứ 3 (tRPC thì không) |
| Frontend | **React 19 + Vite + TanStack Router/Query + AG Grid** (SPA) | App nghiệp vụ nặng lưới nhập liệu, không cần SSR/SEO → không cần Next.js |
| Truy cập DB | **Kysely** (query builder type-safe) + `kysely-codegen` sinh type từ DB | SQL mạnh (CTE, window, recursive, lateral) cho báo cáo & engine giá |
| Migration | **SQL thuần** (dbmate hoặc node-pg-migrate ở chế độ SQL) | Trigger, RLS, partition, constraint trigger viết bằng SQL – ORM không quản lý tốt |
| Kiểu số | Postgres `numeric(p,s)` ⇄ **decimal.js** (Decimal 40 chữ số, ROUND_HALF_UP) | Cấm `float`/`number` cho tiền & số lượng |
| DB | **PostgreSQL 18** | `uuidv7()`, AIO, virtual generated columns, partition tốt |
| Multi-tenant | **Row-level `tenant_id` + Postgres RLS** (FORCE), cell/DB riêng cho tenant lớn về sau | Một lần migrate, pool chung, cô lập mức DB |
| Queue | **BullMQ (Redis/Valkey)** + **transactional outbox** trong Postgres | Tác vụ tính giá/repost dài, retry, tiến độ |
| Monorepo | **pnpm workspaces + Turborepo** | Cache build/test, chia package miền |
| Test | **Vitest + Testcontainers (postgres:18)** + **fast-check** (property-based) + golden tests | Test trên Postgres thật, invariant Nợ=Có & Kho=Sổ cái |
| Báo cáo | SQL view/func + bảng số dư kỳ (materialized), xuất Excel bằng ExcelJS, PDF bằng Typst/Puppeteer | Báo cáo kế toán = SQL tổng hợp |

Phiên bản (kiểm tra 10/2026): PostgreSQL 18 (GA 25/09/2025, có `uuidv7()`); Drizzle v1 vẫn ở RC (rc.1 tháng 4/2026) — một lý do nữa chọn Kysely ổn định. **Pin chính xác version khi `pnpm init`.**

## 0.1 Kết luận từ nghiên cứu 02/04 đã đưa vào kiến trúc

| Phát hiện | Nguồn | Quyết định kiến trúc | Mục |
|---|---|---|---|
| TT99/2025/TT-BTC thay TT200 từ 01/01/2026 | 01, 04 | Template mặc định **TT99 + TT133**; TT200 chỉ để nhập dữ liệu lịch sử/chuyển đổi; hệ thống TK **có version theo ngày hiệu lực** | §2.3 |
| ERPNext: sổ kho append-only; **GL suy ra từ `stock_value_difference`** từng dòng sổ kho; repost nền có checkpoint/resume | 02 | Bút toán 15x/632/154/155 được *compose* từ `value_change` của `stock_ledger` ⇒ kho luôn khớp sổ cái; repost có checkpoint | §4.7, §5.5 |
| ERPNext lưu FIFO queue JSON trong từng dòng → phình dữ liệu | 02 | **Bảng FIFO layers riêng** (`cst.cost_layers` + `layer_consumptions`) + snapshot định kỳ để replay nhanh | §4.8, §5.4 |
| Odoo 19 bỏ `stock.valuation.layer`; giá trị nằm trên `stock.move`, `product.value` lưu lịch sử điều chỉnh; hỗ trợ periodic & perpetual | 02 | Giá trị nằm trên dòng sổ kho; **bảng `cst.valuation_adjustments`** lưu lịch sử điều chỉnh thủ công (old/new, user, lý do); hai chế độ periodic/perpetual | §4.8, §5.3 |
| MISA: chạy lô cuối kỳ ghi đè giá phiếu xuất/nhập TP; chậm; tồn âm giá trị giữa kỳ; BOM 1 cấp; phân bước thủ công | 04 | **Giá tạm tức thời + chốt cuối kỳ** với `valuation_status` rõ ràng (PROVISIONAL/FINAL); repost tăng dần theo cost key; **cảnh báo tồn âm**; **BOM đa cấp**; **phân bước tự động** qua đồ thị/topo | §4.7, §5.3, §5.6, §5.8 |
| Không repo nào có tập hợp/phân bổ 621/622/627 → 154 kiểu VN | 02 | Tự thiết kế, dựa trên **cost element** (iDempiere): ánh xạ TK → yếu tố chi phí, pool, quy tắc phân bổ, kết chuyển | §5.9 |
| TT99 bỏ TK 611/631 (kê khai định kỳ) | 01 | **Giai đoạn 1 chỉ hỗ trợ kê khai thường xuyên (KKTX)**; KKĐK không có trong mô hình dữ liệu Giai đoạn 1 | §2.3 |
| TT99 cho DN tự đổi tên/số hiệu/kết cấu TK | 01 | Số hiệu TK, mẫu báo cáo, thuế suất = **dữ liệu cấu hình theo chế độ + ngày hiệu lực**; logic định khoản chỉ dùng **account role**; báo cáo map qua **mã TK chuẩn** (`standard_code`) chứ không qua `code` do DN đặt | §2.3 |
| TT99 yêu cầu phần mềm ngăn sửa trái phép, **lưu vết sửa đổi** | 01 | Audit log là **bắt buộc**, không tắt được | §7.3 |
| TT133 vẫn hiệu lực song song | 01 | Mô hình dữ liệu hỗ trợ cả hai chế độ (TT133: chi phí ghi thẳng 154); chế độ áp dụng do `md.regime_at` theo ngày | §2.3, §5.9 |
| SXC cố định dưới công suất bình thường → 632 (VAS 02) | 01 | Pool 627 tách **cố định/biến đổi**; đối tượng có **công suất bình thường**; phần dưới công suất kết chuyển 632 | §5.9 |
| Quy trình khoá sổ 13 bước có phụ thuộc, cờ `dirty` | 01 §6 | **Close orchestrator** với bảng trạng thái bước & lan truyền dirty | §7.2 |
| Thứ tự trong ngày: nhập < chuyển < xuất, rồi thời điểm ghi sổ, số CT | 01 §8.5 | Khoá sắp xếp chuẩn của engine dùng `kind_rank` | §5.1 |
| ~30 bất biến I1–I7, K1–K9, G1–G5, B1–B7 | 01 §8 | Mỗi bất biến ánh xạ vào constraint DB / kiểm tra khoá sổ / property test | §8.3 |

---

## 1. Lựa chọn stack và lý do

### 1.1 Backend: NestJS (Fastify adapter) thay vì Fastify/tRPC thuần

- Miền nghiệp vụ lớn (≥8 bounded context, hàng trăm loại chứng từ). NestJS cho **module + DI + guard/interceptor** chuẩn hoá: mỗi context là 1 Nest module, chỉ export *application service*, cấm import chéo repository (lint bằng `eslint-plugin-boundaries` / `dependency-cruiser`).
- Interceptor dùng chung cho: mở transaction, `SET LOCAL app.tenant_id`, audit context (user, IP, request-id), idempotency-key.
- Dùng **Fastify adapter** để lấy hiệu năng & schema validation.
- **Không tRPC**: tRPC buộc client là TS, khó cho tích hợp ngoài (hoá đơn điện tử callback, ngân hàng, Excel add-in, mobile). Thay vào đó: **contract-first bằng Zod** trong package `@app/contracts` → (a) validate ở BE, (b) client typed ở FE, (c) sinh OpenAPI.
- Phương án thay thế chấp nhận được: Fastify + ts-rest không Nest (nhẹ hơn, nhưng tự xây DI/module). Chọn Nest vì team đông dần và cần quy ước.

### 1.2 Frontend: React SPA (Vite) thay vì Next.js

- Ứng dụng kế toán = form chứng từ master-detail + lưới nhập liệu bàn phím (Tab/Enter như MISA) + báo cáo nhiều cột. Không cần SSR/SEO. Next.js thêm độ phức tạp (RSC, server actions) không mang lại giá trị.
- **AG Grid** (Community đủ cho MVP; Enterprise nếu cần pivot/row grouping/Excel export phía client) cho lưới chứng từ & báo cáo; hoặc TanStack Table + virtualizer nếu muốn tránh license.
- **TanStack Query** (cache server state), **TanStack Router** (type-safe route + search params cho bộ lọc báo cáo), **React Hook Form + Zod** (dùng lại schema của `@app/contracts`).
- UI kit: shadcn/ui (Radix) + Tailwind. i18n: mặc định `vi-VN`; định dạng số `1.234.567,89` qua `Intl.NumberFormat('vi-VN')` nhưng **luôn format từ chuỗi Decimal**, không qua `number`.
- Nếu sau này cần trang marketing/portal khách hàng → Next.js riêng, không trộn vào app chính.

### 1.3 Truy cập dữ liệu: Kysely > Drizzle > Prisma

| Tiêu chí | Prisma | Drizzle | **Kysely** |
|---|---|---|---|
| SQL phức tạp (CTE đệ quy, window, LATERAL, `GROUPING SETS`) | yếu, phải `$queryRaw` | khá | **tốt nhất, gần SQL** |
| `numeric` → string/Decimal | Prisma.Decimal (decimal.js) | string | string (tự map Decimal) |
| RLS + `SET LOCAL` trong transaction | vướng (pool/extension) | được | **được, kiểm soát connection rõ ràng** |
| Migration chứa trigger/RLS/partition | phải raw SQL | raw SQL | dùng SQL thuần riêng |
| Độ ổn định API 2026 | ổn định | v1 còn RC | ổn định |

Quyết định: **Kysely** cho mọi truy cập DB; schema là nguồn chân lý trong SQL migration; `kysely-codegen` sinh type sau mỗi migration (chạy trong CI, fail nếu lệch). Truy vấn báo cáo cực phức tạp được viết thành **SQL function / view** trong migration và gọi từ Kysely (`sql\`select * from rpt.trial_balance(...)\``) — để DBA/kế toán viên đọc được và test được bằng SQL.

### 1.4 Kiểu số — quy tắc bất di bất dịch

| Đại lượng | Kiểu Postgres | Ghi chú |
|---|---|---|
| Số tiền hạch toán (VND) | **`numeric(20,2)`** | VND thường làm tròn 0 số lẻ nhưng để 2 để chứa ngoại tệ quy đổi trung gian; làm tròn theo cấu hình tenant (mặc định 0) tại *dòng chứng từ* |
| Số tiền nguyên tệ | `numeric(20,2)` | |
| Tỷ giá | `numeric(18,6)` | |
| Số lượng | `numeric(20,6)` | |
| Đơn giá, giá vốn đơn vị | `numeric(24,8)` | chống sai số khi chia |
| Tỷ lệ phân bổ, hệ số | `numeric(20,12)` | |

- Domain type `Money`/`Qty` bọc `Decimal` (decimal.js, `precision: 40`, `rounding: ROUND_HALF_UP`). Driver `pg`: `types.setTypeParser(1700, s => s)` (giữ string) rồi map sang Decimal ở repository.
- ESLint rule cấm `parseFloat`, `Number(` trên field tiền; JSON API truyền số tiền dưới dạng **string**.
- 01 §8.5 đề xuất lưu tiền VND dạng số nguyên; ta giữ `numeric(20,2)` để chứa ngoại tệ nhưng **giá trị VND luôn được làm tròn về `amount_scale` của công ty (mặc định 0)** trước khi ghi sổ ⇒ tương đương số nguyên với VND.
- **Luật làm tròn duy nhất R1** (nguyên văn, dùng chung với `01` §8.5, golden test và demo):
  - (a) ROUND_HALF_UP đến đồng cho mọi số tiền. Đơn giá lưu 4 số lẻ chỉ để hiển thị/giải thích; giá trị luôn tính từ tổng giá trị, không nhân lại từ đơn giá đã làm tròn.
  - (b) Phân bổ một số tiền T cho n phần theo trọng số w (SXC, chi phí mua, Z cho các phiếu nhập kho, trích theo lương…): **largest remainder** — mỗi phần lấy phần nguyên floor(T·wᵢ/W) đến đồng; số đồng còn thiếu cộng 1 đồng lần lượt cho các phần có phần lẻ lớn nhất; hòa thì theo thứ tự ổn định (ngày, số CT, số dòng).
  - (c) Giá trị xuất kho = round(SL × giá trị tồn / SL tồn) theo nguồn giá (lô với đích danh/FIFO, cả kỳ với BQ cuối kỳ, thời điểm với BQ tức thời); phần dư nằm lại ở tồn; phiếu xuất làm tồn của nguồn đó về 0 nhận toàn bộ giá trị còn lại.
- Cột `numeric(24,8)` của đơn giá chỉ là chỗ chứa; không phép tính giá trị nào được đọc lại đơn giá đã lưu để nhân với SL (R1 (a)). Với ngoại tệ, "đến đồng" thay bằng `amount_scale` của đồng tiền đó.
- Hàm duy nhất trong `domain-core` cho R1 (b) (property test: Σ = T; mỗi phần ≥ 0 khi T ≥ 0 và w ≥ 0; hoán vị đầu vào không đổi kết quả):

  ```ts
  // R1 (b). T: số tiền nguyên đồng, T ≥ 0 (T < 0: phân bổ |T| rồi đổi dấu). w_i ≥ 0, W = Σw > 0.
  // key: khoá ổn định (ngày, số CT, số dòng) để phá hoà.
  function largestRemainder(T: Money, parts: { w: Decimal; key: StableKey }[]): Money[] {
    const W = sum(parts.map(p => p.w));
    const exact = parts.map(p => T.times(p.w).div(W));          // Decimal 40 chữ số
    const out = exact.map(x => x.floor());                         // phần nguyên đến đồng
    let left = T.minus(sum(out));                                  // 0 ≤ left < n (số đồng còn thiếu)
    const order = parts.map((_, i) => i).sort((i, j) =>
      exact[j].minus(out[j]).cmp(exact[i].minus(out[i]))            // phần lẻ lớn trước
      || compareStableKey(parts[i].key, parts[j].key));             // hoà ⇒ (ngày, số CT, số dòng)
    for (const i of order) { if (left.isZero()) break; out[i] = out[i].plus(1); left = left.minus(1); }
    return out;
  }
  // VD: largestRemainder(10_000_000, [1,1,1]) = [3_333_334, 3_333_333, 3_333_333]
  ```

### 1.5 Hạ tầng & công cụ

- **Monorepo pnpm + Turborepo**:
  ```
  apps/
    api/            NestJS (HTTP)
    worker/         NestJS standalone: BullMQ consumers (costing, repost, report, e-invoice)
    web/            React SPA
  packages/
    contracts/      Zod schema + types API
    domain-core/    Money, Qty, Period, Result, errors (thuần TS, không IO)
    db/             Kysely instance, codegen types, tx helper, RLS helper
    ledger/         context Chứng từ → Bút toán (posting engine)
    inventory/      stock ledger
    costing/        costing engine (thuần, test được không cần DB) + adapter DB
    manufacturing/  BOM, lệnh SX, giá thành
    reporting/      báo cáo
    einvoice/       adapter nhà cung cấp HĐĐT
    test-kit/       Testcontainers, fixtures, golden data
  db/migrations/    *.sql (dbmate)
  ```
- **BullMQ** trên Redis/Valkey: queue `costing.repost`, `costing.period-close`, `mfg.cost-calc`, `report.export`, `einvoice.publish`. **Nguồn sự thật là bảng trong Postgres** (vd `cst.repost_requests`), không phải hàng đợi: job BullMQ chỉ là tín hiệu "đánh thức", `jobId` = id của dòng yêu cầu (không bao giờ là cost key cố định — BullMQ bỏ qua job trùng id khi job cũ còn tồn tại, sẽ nuốt yêu cầu mới), `removeOnComplete: true`; worker xong việc thì quét tiếp các yêu cầu QUEUED; cron quét yêu cầu QUEUED tồn đọng và RUNNING hết hạn lease (§5.5). Dùng *BullMQ Flows* cho cha–con (tính giá cả kỳ → nhiều job item).
- **Transactional outbox**: ghi `outbox_events` trong cùng transaction với posting; relay đẩy sang BullMQ. Không bao giờ enqueue trực tiếp trong transaction (tránh job chạy trước khi commit).
- Observability: OpenTelemetry → Grafana/Tempo; pino log có `tenant_id`, `request_id`.
- Auth: OIDC (Keycloak/Zitadel tự host, hoặc Auth.js) — user thuộc nhiều tenant; RBAC + phân quyền theo chi nhánh/kho/loại chứng từ.
- Deploy: Docker; Postgres managed (hoặc Patroni), PITR bật, backup mã hoá; object storage (S3-compatible, Object Lock) cho tệp đính kèm, XML hoá đơn, bản lưu trữ.

---

## 2. Multi-tenancy, đa chi nhánh, đa sổ

### 2.1 So sánh và quyết định

| | Schema-per-tenant | DB-per-tenant | **Row-level + RLS** |
|---|---|---|---|
| Migrate | N lần, dễ lệch | N lần | **1 lần** |
| Pool kết nối | `search_path` đổi liên tục, cache plan phình | pool/tenant | **pool chung** |
| Cô lập | tốt | tốt nhất | tốt nếu FORCE RLS + test |
| Báo cáo liên tenant (vận hành) | khó | khó | dễ |
| Hợp với “nội bộ trước, SaaS sau” | thừa | thừa | **vừa** |

**Quyết định**: Row-level với `tenant_id uuid NOT NULL` ở *mọi* bảng nghiệp vụ, **RLS FORCE**, khoá ngoại **kép** `(tenant_id, id)` để không thể tham chiếu chéo tenant. Kiến trúc “cell”: một tenant lớn có thể được tách sang cluster riêng (cùng schema) — router tenant→cluster ở tầng kết nối.

```sql
-- Vai trò: owner chạy migration; app_user chỉ DML, KHÔNG bypass RLS
CREATE ROLE app_user NOINHERIT LOGIN;

-- Hàm lấy tenant hiện tại (set bằng SET LOCAL trong mỗi transaction)
CREATE FUNCTION app.current_tenant() RETURNS uuid
LANGUAGE sql STABLE AS $$ SELECT current_setting('app.tenant_id')::uuid $$;
-- current_setting không có missing_ok ⇒ quên set sẽ lỗi, không lộ dữ liệu.

-- Mẫu áp cho mọi bảng (sinh tự động bằng hàm trong migration)
ALTER TABLE acc.journal_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE acc.journal_lines FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON acc.journal_lines
  USING (tenant_id = app.current_tenant())
  WITH CHECK (tenant_id = app.current_tenant());
```

TS — mọi truy cập DB đi qua helper:

```ts
export async function withTenantTx<T>(ctx: RequestCtx, fn: (tx: Tx) => Promise<T>) {
  return db.transaction().setIsolationLevel('read committed').execute(async (tx) => {
    await sql`select set_config('app.tenant_id', ${ctx.tenantId}, true),
                     set_config('app.user_id',   ${ctx.userId},   true),
                     set_config('app.request_id',${ctx.requestId},true)`.execute(tx);
    return fn(tx);
  });
}
```

Kiểm thử bắt buộc: test “tenant leak” — tạo 2 tenant, chạy toàn bộ API của tenant A, assert không đọc/ghi được 1 dòng nào của B; test quét `pg_class` (`relkind IN ('r','p')`, kể cả partition con nếu sau này có) đảm bảo mọi bảng trong các schema `core, md, acc, inv, cst, mfg, audit` có `relforcerowsecurity = true` và có cột `tenant_id`, **trừ danh sách loại trừ tường minh** nằm ngay trong test:
- `core.tenants` — chính là bảng tenant (khoá là `id`, không có `tenant_id`); chỉ role vận hành được đọc/ghi, `app_user` chỉ có quyền đọc qua hàm.
- mọi bảng schema `sys.*` — dữ liệu hệ thống dùng chung, không thuộc tenant (template hệ thống TK, mẫu báo cáo, thuế suất…); `app_user` chỉ có `SELECT`.
Bảng mới không có `tenant_id` mà không nằm trong danh sách ⇒ test fail; thêm vào danh sách phải qua review.

Hiệu năng RLS: luôn đặt `tenant_id` là **cột đầu tiên** của PK/index; hàm `current_tenant()` là `STABLE` nên planner dùng index được.

### 2.2 Đơn vị kế toán & chi nhánh

```
tenant (khách hàng SaaS / công ty mẹ)
 └─ company (đơn vị kế toán: MST, chế độ kế toán, đồng tiền hạch toán, sổ)
     └─ branch (chi nhánh: hạch toán phụ thuộc → chung sổ company, có mã CN trên mọi dòng;
                hạch toán độc lập → là company riêng, có MST riêng 13 số)
         └─ warehouse
```

- Mọi chứng từ/bút toán/stock move mang `company_id` + `branch_id`. Báo cáo lọc “toàn công ty” hoặc “từng chi nhánh”, giống tuỳ chọn *“Lấy số liệu chi nhánh phụ thuộc”* của MISA. **[ĐỐI CHIẾU 04]**
- Giao dịch nội bộ giữa chi nhánh (TK 136/336) sinh cặp bút toán đối ứng; báo cáo hợp nhất loại trừ theo `intercompany_ref`.

### 2.3 Đa chế độ kế toán (TT200, TT133, TT99/2025) — hệ thống tài khoản cấu hình được

Bối cảnh (đã xác minh ở 01/04): **TT99/2025/TT-BTC** thay thế TT200 cho kỳ kế toán từ 01/01/2026; TT133 vẫn cho DN nhỏ và vừa. Do đó **template mặc định khi tạo công ty mới chỉ có TT99 và TT133**; TT200 chỉ tồn tại như template “lịch sử” để nhập số liệu các năm ≤ 2025 (chuyển đổi từ MISA) và để map sang TT99. Phần mềm phải: (a) chạy dữ liệu lịch sử theo TT200, (b) chuyển đổi số dư sang TT99, (c) không hard-code số hiệu TK trong code, (d) chịu được các thông tư sửa đổi sau này (versioning). **[ĐỐI CHIẾU 01: danh mục TK & khác biệt TT99]**

Thiết kế:

1. **`account_chart_templates` + `account_chart_template_versions`** (dữ liệu hệ thống, không thuộc tenant): mỗi chế độ (TT99, TT133, TT200-lịch sử) có nhiều *version* với `effective_from/effective_to` (văn bản sửa đổi = version mới); mỗi version là cây TK chuẩn, tính chất (dư Nợ/Có/lưỡng tính), chỉ tiêu báo cáo map tới, danh sách account roles mặc định.

   ```sql
   CREATE TABLE sys.chart_template_versions (
     id uuid PRIMARY KEY DEFAULT uuidv7(),
     regime text NOT NULL CHECK (regime IN ('TT99','TT133','TT200')),
     version_code text NOT NULL,              -- 'TT99-2025', 'TT99-2025-sđ1'…
     legal_ref text NOT NULL,                 -- số hiệu văn bản
     effective_from date NOT NULL, effective_to date,
     is_selectable_for_new boolean NOT NULL,  -- TT200 = false
     UNIQUE (regime, version_code)
   );
   CREATE TABLE sys.chart_template_accounts (
     version_id uuid NOT NULL REFERENCES sys.chart_template_versions(id),
     code text NOT NULL, name text NOT NULL, parent_code text,
     nature text NOT NULL, is_postable boolean NOT NULL, default_role text,
     PRIMARY KEY (version_id, code)
   );
   -- Mỗi company ghi lại đã áp version nào, từ ngày nào (lịch sử đổi chế độ)
   CREATE TABLE md.company_chart_assignments (
     tenant_id uuid NOT NULL, company_id uuid NOT NULL,
     template_version_id uuid NOT NULL REFERENCES sys.chart_template_versions(id),
     valid_from date NOT NULL, valid_to date,
     PRIMARY KEY (tenant_id, company_id, valid_from),
     CHECK (valid_to IS NULL OR valid_to >= valid_from),
     EXCLUDE USING gist (tenant_id WITH =, company_id WITH =,
                         daterange(valid_from, valid_to, '[]') WITH &&)   -- không chồng giai đoạn (btree_gist)
   );
   -- NGUỒN DUY NHẤT của chế độ kế toán (rà soát N2): không lưu chế độ ở core.companies.
   CREATE FUNCTION md.regime_at(p_tenant uuid, p_company uuid, p_date date) RETURNS text
   LANGUAGE sql STABLE AS $$
     SELECT v.regime
     FROM md.company_chart_assignments a
     JOIN sys.chart_template_versions v ON v.id = a.template_version_id
     WHERE a.tenant_id = p_tenant AND a.company_id = p_company
       AND a.valid_from <= p_date AND (a.valid_to IS NULL OR p_date <= a.valid_to)
   $$;   -- NULL ⇒ ngày chưa được gán chế độ ⇒ ghi sổ phải lỗi
   ```
2. **`accounts`** (của company): copy từ template khi khởi tạo, tenant thêm TK chi tiết (cấp 2,3,4…). Vì TT99 cho DN **tự đổi tên, số hiệu, kết cấu TK**, mỗi TK của DN mang `standard_code` (mã TK chuẩn trong template, vd `156`) tách khỏi `code` hiển thị do DN đặt; BCTC, mẫu sổ và kiểm tra bất biến (K1: TK HTK…) luôn dựa trên `standard_code`/role, không dựa trên `code`. Đổi chế độ chỉ ở đầu năm tài chính (`company_chart_assignments`).
   - **Chỉ hỗ trợ KKTX** (kê khai thường xuyên) trong Giai đoạn 1: TT99 đã bỏ 611/631; TT133 còn 611 nhưng Giai đoạn 1 không làm KKĐK — nếu cần, bổ sung sau như một chế độ hạch toán kho riêng.
   - Thuế suất (GTGT 0/5/8/10%, giảm 8% theo từng thời kỳ), mẫu sổ, mẫu tờ khai đều là bảng cấu hình có `effective_from/effective_to`.
3. **Account roles** (vai trò TK): code nghiệp vụ không bao giờ viết `'1561'`, mà viết `role('INVENTORY_GOODS')`. Bảng `account_role_mappings(company_id, role, account_id, item_category_id?, warehouse_id?)` cho phép mặc định theo template + ghi đè theo nhóm VTHH/kho (giống “TK kho, TK doanh thu, TK giá vốn” trên danh mục VTHH của MISA).
4. **Chuyển đổi chế độ**: `account_conversion_maps(from_chart, to_chart, from_code, to_code, ratio)` + công cụ “kết chuyển số dư đầu kỳ sang chế độ mới” tạo chứng từ chuyển đổi (loại `REGIME_CONVERSION`).
5. **Mẫu báo cáo theo chế độ**: `report_templates(regime, report_code, version)` + `report_lines(code, formula)` với công thức kiểu `PS_NO(511) - PS_CO(5211)`, `DU_NO(131)`… (DSL giống MISA “thiết lập báo cáo tài chính”).
6. **Đa sổ**: `books` (sổ Tài chính `FIN`, sổ Quản trị `MGT`). Mỗi chứng từ có thể sinh bút toán vào 1 hoặc cả 2 sổ (MISA có “sổ tài chính/sổ quản trị”). `journal_entries.book_id` là phần của khoá phân vùng logic.

---

## 3. Mô hình miền (bounded contexts)

```
                ┌───────────────┐
                │  Danh mục (MD)│  items, partners, accounts, uom, warehouses, cost objects…
                └──────┬────────┘
                       │ (đọc)
 ┌──────────────┐  post ┌──────────────┐   events   ┌──────────────┐
 │  Chứng từ    ├──────►│  Sổ cái (GL) │◄───────────┤ Giá vốn      │
 │  (Documents) │       │ journal      │  COGS/adj  │ (Costing)    │
 └──────┬───────┘       └──────▲───────┘   lines    └──────▲───────┘
        │ stock effects        │                           │ valuation
        ▼                      │                           │
 ┌──────────────┐  moves  ┌────┴─────────┐  cost of FG  ┌──┴───────────┐
 │  Kho (Inv.)  ├────────►│ Kỳ & Khoá sổ │◄─────────────┤ Sản xuất &   │
 │ stock ledger │         │ (Periods)    │              │ Giá thành    │
 └──────────────┘         └──────────────┘              └──────────────┘
        ▲                                                       ▲
        └────────────── Báo cáo (Reporting, read-only) ─────────┘
 Hoá đơn điện tử / Thuế (anti-corruption layer tới nhà cung cấp, cơ quan thuế)
```

| Context | Trách nhiệm | Aggregate chính | Phát sự kiện |
|---|---|---|---|
| **Danh mục** (Master Data) | VTHH, ĐVT & quy đổi, kho, đối tượng (KH/NCC/NV), TK, ngân hàng, đối tượng THCP, mã thống kê, khoản mục CP | Item, Partner, Account | `ItemChanged` |
| **Chứng từ** (Documents) | Nhập/sửa/ghi sổ/bỏ ghi chứng từ: mua hàng, bán hàng, kho, quỹ, ngân hàng, tổng hợp, CCDC, TSCĐ, lương | Document (+lines) | `DocumentPosted`, `DocumentUnposted` |
| **Sổ cái** (Ledger/GL) | Posting engine: chứng từ → bút toán theo *posting rule*; invariant Nợ = Có; số dư kỳ | JournalEntry | `JournalPosted` |
| **Kho** (Inventory) | Stock ledger append-only, tồn theo kho/lô/serial, đặt chỗ, kiểm kê | StockMove, StockLedgerEntry | `StockMoved(item, wh, ts)` |
| **Giá vốn** (Costing) | Định giá xuất kho (BQ cuối kỳ, BQ tức thời, FIFO, đích danh), repost, chênh lệch giá, sinh bút toán 632/15x | CostLayer, RepostRequest, ValuationRun | `ValuationChanged` |
| **Sản xuất & giá thành** | BOM, định mức, lệnh SX, tập hợp CP (621/622/627 hoặc 154 theo TT133), phân bổ, đánh giá dở dang, tính giá thành, cost trace | ProductionOrder, CostingPeriodRun, ProductCostSheet | `ProductCostComputed` |
| **Kỳ & khoá sổ** | Kỳ kế toán, khoá sổ theo module/sổ, kết chuyển cuối kỳ, đánh giá ngoại tệ, đóng năm | FiscalPeriod, PeriodLock | `PeriodLocked` |
| **Báo cáo** | BCTC (B01..B09), sổ sách (S03a, S38…), báo cáo kho, giá thành, thuế; drill-down về chứng từ | (read model) | — |
| **HĐĐT & Thuế** | Phát hành HĐĐT (NĐ 123/2020, sửa đổi NĐ 70/2025) qua nhà cung cấp; tờ khai thuế (XML HTKK); đối chiếu hoá đơn đầu vào | EInvoice, TaxReturn | `EInvoiceIssued` |

Quy tắc giao tiếp:
- **Đồng bộ trong 1 transaction**: Documents → Ledger (posting) và Documents → Inventory (stock moves) — cùng commit để không bao giờ có chứng từ “đã ghi sổ” mà thiếu bút toán/thẻ kho.
- **Bất đồng bộ qua outbox**: Inventory → Costing (repost), Costing → Ledger (cập nhật bút toán giá vốn), Manufacturing → Costing (giá nhập kho thành phẩm).
- Posting rule là **dữ liệu + code**: mỗi loại chứng từ có một `PostingRule` (TS) trả về danh sách dòng bút toán dựa trên account roles; tenant cấu hình được TK ngầm định nhưng không đổi được cấu trúc.

```ts
// packages/ledger/src/posting/rules/sales-invoice.ts
export const salesInvoiceRule: PostingRule<SalesInvoiceDoc> = (doc, r) => doc.lines.flatMap(l => [
  dr(r.partnerReceivable(doc.customer), l.amountAfterDiscount.plus(l.vat), { partner: doc.customer }),
  cr(r.revenue(l.item),               l.amountAfterDiscount, { item: l.item }),
  cr(r.vatOutput(l.vatRate),          l.vat),
  // Giá vốn KHÔNG sinh ở đây: dòng 632/156 do Costing sinh (source='COSTING') vì
  // giá xuất có thể chưa biết (BQ cuối kỳ) hoặc thay đổi khi repost.
]);
```

---

## 4. Lược đồ dữ liệu cốt lõi (DDL PostgreSQL 18, rút gọn)

Quy ước: schema `core` (tenant, user), `md` (danh mục), `acc` (chứng từ, sổ cái, kỳ), `inv` (kho), `cst` (giá vốn), `mfg` (sản xuất/giá thành), `audit`, `app` (hàm tiện ích). PK `id uuid DEFAULT uuidv7()`; mọi bảng nghiệp vụ có `tenant_id` và `UNIQUE (tenant_id, id)` để làm đích FK kép. Cột `created_at/created_by` lược bớt cho gọn.

### 4.1 Tenant, công ty, chi nhánh, sổ

```sql
CREATE TABLE core.tenants (
  id uuid PRIMARY KEY DEFAULT uuidv7(),
  code text UNIQUE NOT NULL, name text NOT NULL,
  status text NOT NULL DEFAULT 'active', created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE core.companies (
  tenant_id uuid NOT NULL REFERENCES core.tenants(id),
  id uuid NOT NULL DEFAULT uuidv7(),
  tax_code text NOT NULL,                     -- MST
  name text NOT NULL,
  -- KHÔNG có cột chế độ kế toán: chế độ theo ngày = md.regime_at(tenant, company, ngày) (§2.3, rà soát N2)
  base_currency char(3) NOT NULL DEFAULT 'VND',
  amount_scale smallint NOT NULL DEFAULT 0,   -- số lẻ làm tròn tiền VND
  inventory_costing_method text NOT NULL      -- mặc định công ty, có thể ghi đè theo item
    CHECK (inventory_costing_method IN ('PERIODIC_AVG','MOVING_AVG','FIFO','SPECIFIC')),
                                              -- SPECIFIC = thực tế đích danh theo lô (khách hàng dùng)
  fiscal_year_start_month smallint NOT NULL DEFAULT 1,
  PRIMARY KEY (tenant_id, id)
);

CREATE TABLE core.branches (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, code text NOT NULL, name text NOT NULL,
  accounting_mode text NOT NULL CHECK (accounting_mode IN ('DEPENDENT','INDEPENDENT')),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, code),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies(tenant_id, id)
);

CREATE TABLE acc.books (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, code text NOT NULL CHECK (code IN ('FIN','MGT')),
  PRIMARY KEY (tenant_id, id), UNIQUE (tenant_id, company_id, code)
);
```

### 4.2 Hệ thống tài khoản (cây) & vai trò TK

```sql
CREATE TABLE md.accounts (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  code text NOT NULL,                 -- '1561', '33311'
  name text NOT NULL,
  parent_id uuid,
  path ltree NOT NULL,                -- '156.1561' – truy vấn cây nhanh (extension ltree)
  level smallint NOT NULL,
  nature text NOT NULL CHECK (nature IN ('DEBIT','CREDIT','BOTH')),
  is_postable boolean NOT NULL,       -- chỉ TK lá được hạch toán
  -- theo dõi chi tiết bắt buộc khi hạch toán vào TK này:
  track_partner boolean NOT NULL DEFAULT false,
  track_item boolean NOT NULL DEFAULT false,
  track_cost_object boolean NOT NULL DEFAULT false,
  track_expense_item boolean NOT NULL DEFAULT false, -- khoản mục CP
  track_bank_account boolean NOT NULL DEFAULT false,
  currency_mode text NOT NULL DEFAULT 'BASE' CHECK (currency_mode IN ('BASE','FOREIGN','ANY')),
  standard_code text NOT NULL,        -- mã TK chuẩn trong template (TT99/TT133) – BCTC & role map theo cột này
                                      -- (TT99 cho DN đổi code/tên; standard_code thì không đổi)
  valid_from date, valid_to date,     -- hỗ trợ chuyển chế độ
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, code),
  FOREIGN KEY (tenant_id, parent_id) REFERENCES md.accounts(tenant_id, id)
);
CREATE INDEX ON md.accounts USING gist (path);

CREATE TABLE md.account_role_mappings (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL,
  role text NOT NULL,                 -- 'INVENTORY_GOODS','COGS','REVENUE_GOODS','VAT_OUTPUT',…
  item_category_id uuid, warehouse_id uuid,    -- NULL = mặc định
  account_id uuid NOT NULL,
  UNIQUE NULLS NOT DISTINCT (tenant_id, company_id, role, item_category_id, warehouse_id)
);
```

### 4.3 Kỳ kế toán & khoá sổ

```sql
CREATE TABLE acc.fiscal_periods (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  fiscal_year smallint NOT NULL, period_no smallint NOT NULL,   -- 1..12 (+13 kỳ điều chỉnh)
  start_date date NOT NULL, end_date date NOT NULL,
  status text NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','CLOSING','LOCKED')),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, fiscal_year, period_no),
  EXCLUDE USING gist (tenant_id WITH =, company_id WITH =,
                      daterange(start_date, end_date, '[]') WITH &&)  -- không chồng kỳ (btree_gist)
);

-- Khoá sổ THEO KỲ THÁNG (01 §6; giá BQ cuối kỳ đòi khoá theo kỳ), có thể theo module.
-- locked_through luôn là ngày cuối một kỳ (end_date của acc.fiscal_periods) hoặc '-infinity'.
-- Khoá theo ngày giữa kỳ (kiểu MISA "khoá sổ đến ngày") có thể bổ sung về sau bằng cách nới điều kiện này.
CREATE TABLE acc.period_locks (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL,
  scope text NOT NULL CHECK (scope IN ('ALL','INVENTORY','COSTING','CASH','TAX')),
  locked_through date NOT NULL DEFAULT '-infinity',  -- mọi posting_date <= ngày này bị chặn
  locked_by uuid, locked_at timestamptz,
  PRIMARY KEY (tenant_id, company_id, scope)
);
-- Khi tạo company: tạo sẵn ĐỦ 5 dòng (mỗi scope) với '-infinity', để giao dịch ghi sổ luôn có dòng
-- mà khoá FOR SHARE, và thao tác khoá kỳ luôn là UPDATE (khoá xung đột) — xem §7.2 (06b-U1).
```

### 4.4 Chứng từ & dòng chứng từ

```sql
CREATE TABLE acc.documents (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, branch_id uuid NOT NULL,
  doc_type text NOT NULL,           -- 'PURCHASE_RECEIPT','SALES_INVOICE','STOCK_ISSUE','CASH_PAYMENT',
                                    -- 'PROD_ISSUE','PROD_RECEIPT','GENERAL_JOURNAL','COST_ALLOC',…
  doc_no text,                      -- cấp khi ghi sổ (xem §7.4)
  doc_date date NOT NULL,           -- ngày chứng từ
  posting_date date NOT NULL,       -- ngày hạch toán
  fiscal_year smallint NOT NULL,    -- năm tài chính của posting_date, lấy từ acc.fiscal_periods (không tự tính
                                    -- từ ngày vì năm tài chính có thể không bắt đầu tháng 1); khoá số CT theo năm
  lock_scope text NOT NULL DEFAULT 'ALL',  -- scope khoá kỳ áp cho chứng từ này (map theo doc_type, §7.2)
  posting_time time NOT NULL DEFAULT '00:00', -- thứ tự trong ngày cho kho
  status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','POSTED','VOIDED')),
  version int NOT NULL DEFAULT 1,
  replaces_doc_id uuid,             -- khi "sửa" = huỷ + lập lại
  partner_id uuid, currency char(3) NOT NULL DEFAULT 'VND', fx_rate numeric(18,6) NOT NULL DEFAULT 1,
  description text,
  total_amount numeric(20,2) NOT NULL DEFAULT 0,
  source_ref jsonb,                 -- liên kết: đơn hàng, HĐĐT, lệnh SX…
  posted_at timestamptz, posted_by uuid,
  voided_at timestamptz, voided_by uuid, void_reason text,
  row_hash bytea,                   -- băm nội dung khi POSTED (tamper-evident)
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies(tenant_id, id)
);
-- Số CT duy nhất theo loại × NĂM (06b-D1): sang năm mới đánh lại từ 1 không trùng năm trước
CREATE UNIQUE INDEX documents_no_uq ON acc.documents (tenant_id, company_id, doc_type, fiscal_year, doc_no)
  WHERE doc_no IS NOT NULL;
CREATE INDEX ON acc.documents (tenant_id, company_id, posting_date, doc_type);

CREATE TABLE acc.document_lines (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  document_id uuid NOT NULL, line_no int NOT NULL,
  item_id uuid, uom_id uuid,
  qty numeric(20,6), qty_base numeric(20,6),   -- quy đổi về ĐVT chính
  unit_price numeric(24,8), amount numeric(20,2), amount_fc numeric(20,2),
  discount_amount numeric(20,2) DEFAULT 0,
  vat_rate numeric(5,2), vat_amount numeric(20,2) DEFAULT 0,
  debit_account_id uuid, credit_account_id uuid,     -- cho chứng từ dạng "hạch toán"
  warehouse_id uuid, to_warehouse_id uuid,           -- chuyển kho
  lot_id uuid, serial_ids uuid[],
  cost_object_id uuid, expense_item_id uuid, production_order_id uuid,
  partner_id uuid,
  extra jsonb,                                        -- trường mở rộng theo doc_type
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, document_id, line_no),
  FOREIGN KEY (tenant_id, document_id) REFERENCES acc.documents(tenant_id, id) ON DELETE RESTRICT
  -- KHÔNG CASCADE (06b-D3): cascade chạy sau khi header đã bị xoá nên guard dòng không còn thấy trạng thái.
  -- Xoá chứng từ DRAFT = xoá dòng trước rồi xoá header, trong cùng transaction (guard ở §7.1).
);
```

Ghi chú: dùng **một bảng chung** cho mọi loại chứng từ + `extra jsonb` cho phần riêng; loại phức tạp (hoá đơn bán, phiếu nhập mua có chi phí mua phân bổ) có bảng phụ (`acc.purchase_landed_costs`…). Validation theo `doc_type` ở tầng ứng dụng (Zod discriminated union).

### 4.5 Bút toán (sổ cái) + ràng buộc cân Nợ/Có

```sql
CREATE TABLE acc.journal_entries (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, book_id uuid NOT NULL, branch_id uuid NOT NULL,
  document_id uuid NOT NULL,
  source text NOT NULL CHECK (source IN ('DOCUMENT','COSTING','CLOSING','ALLOCATION','REVALUATION')),
  posting_date date NOT NULL,
  fiscal_year smallint NOT NULL,
  lock_scope text NOT NULL DEFAULT 'ALL',    -- scope khoá kỳ: theo doc_type/source (vd COSTING cho source='COSTING',
                                             -- CASH cho phiếu thu/chi) — trigger §7.2 đọc cột này (06b-U3)
  is_active boolean NOT NULL DEFAULT true,   -- false khi bị thay bằng phiên bản mới (repost/bỏ ghi)
  superseded_by uuid, valuation_version int, -- cho bút toán do Costing sinh
  PRIMARY KEY (tenant_id, id)
);

CREATE TABLE acc.journal_lines (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  entry_id uuid NOT NULL,
  company_id uuid NOT NULL, book_id uuid NOT NULL, branch_id uuid NOT NULL,
  posting_date date NOT NULL, fiscal_year smallint NOT NULL,  -- phi chuẩn hoá cho báo cáo (và partition về sau)
  account_id uuid NOT NULL,
  contra_account_id uuid,          -- TK đối ứng (sổ Nhật ký chung/S38 kiểu VN cần cặp đối ứng)
  debit  numeric(20,2) NOT NULL DEFAULT 0 CHECK (debit  >= 0),
  credit numeric(20,2) NOT NULL DEFAULT 0 CHECK (credit >= 0),
  CHECK ((debit = 0) <> (credit = 0)),     -- mỗi dòng đúng 1 bên
  currency char(3), amount_fc numeric(20,2), fx_rate numeric(18,6),
  partner_id uuid, item_id uuid, cost_object_id uuid, expense_item_id uuid,
  warehouse_id uuid, production_order_id uuid, document_line_id uuid,
  is_active boolean NOT NULL DEFAULT true,
  PRIMARY KEY (tenant_id, id)
);
-- Giai đoạn 1: KHÔNG partition (06b-D2). Điều kiện và yêu cầu khi partition: §4.11.
CREATE INDEX ON acc.journal_lines (tenant_id, company_id, account_id, posting_date) WHERE is_active;
CREATE INDEX ON acc.journal_lines (tenant_id, entry_id);
CREATE INDEX ON acc.journal_lines (tenant_id, partner_id, account_id, posting_date) WHERE partner_id IS NOT NULL AND is_active;
CREATE INDEX ON acc.journal_lines USING brin (posting_date);
```

Ràng buộc cân bằng — **constraint trigger DEFERRABLE INITIALLY DEFERRED** (kiểm tại COMMIT, sau khi đã insert đủ dòng):

```sql
CREATE FUNCTION acc.check_entry_balanced() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_entry uuid := coalesce(NEW.entry_id, OLD.entry_id);
        v_diff numeric; v_cnt int;
BEGIN
  SELECT sum(debit) - sum(credit), count(*) INTO v_diff, v_cnt
  FROM acc.journal_lines
  WHERE tenant_id = coalesce(NEW.tenant_id, OLD.tenant_id) AND entry_id = v_entry;
  IF v_cnt > 0 AND v_diff <> 0 THEN
    RAISE EXCEPTION 'Bút toán % lệch Nợ/Có: %', v_entry, v_diff USING ERRCODE = '23514';
  END IF;
  RETURN NULL;
END $$;

CREATE CONSTRAINT TRIGGER journal_balanced
  AFTER INSERT OR UPDATE OR DELETE ON acc.journal_lines
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION acc.check_entry_balanced();
```

Tối ưu: trigger FOR EACH ROW chạy lại tổng mỗi dòng → với bút toán lớn (phân bổ CP hàng nghìn dòng) dùng biến thể **statement-level với transition table** gom `DISTINCT entry_id` rồi kiểm một lần (constraint trigger chỉ hỗ trợ FOR EACH ROW, nên dùng kỹ thuật: row trigger chỉ ghi entry_id vào bảng tạm `pg_temp.dirty_entries`, và 1 constraint trigger deferred trên bảng phụ `acc.entry_check_queue` kiểm). Bảo vệ thêm: kiểm tra tương tự ở tầng TS trước khi insert (fail sớm, lỗi thân thiện).

Số dư kỳ (phục vụ báo cáo nhanh):

```sql
CREATE TABLE acc.account_period_balances (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL, book_id uuid NOT NULL, branch_id uuid NOT NULL,
  fiscal_year smallint NOT NULL, period_no smallint NOT NULL,
  account_id uuid NOT NULL, partner_id uuid, -- NULL nếu TK không theo dõi đối tượng
  debit numeric(20,2) NOT NULL DEFAULT 0, credit numeric(20,2) NOT NULL DEFAULT 0,
  UNIQUE NULLS NOT DISTINCT (tenant_id, company_id, book_id, branch_id, fiscal_year, period_no, account_id, partner_id)
);
```
Cập nhật bằng job “rebuild balance cho (company, period)” khi nhận `JournalPosted` (idempotent: xoá & tính lại kỳ bị ảnh hưởng) — không cập nhật delta trong trigger để tránh tranh chấp khoá dòng nóng.

### 4.6 Danh mục vật tư, ĐVT, kho, lô/serial

```sql
CREATE TABLE md.uoms (tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  code text NOT NULL, name text NOT NULL, PRIMARY KEY (tenant_id, id), UNIQUE (tenant_id, code));

CREATE TABLE md.items (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, code text NOT NULL, name text NOT NULL,
  item_type text NOT NULL CHECK (item_type IN ('GOODS','MATERIAL','FINISHED','SEMI_FINISHED','TOOL','SERVICE')),
  category_id uuid, base_uom_id uuid NOT NULL,
  costing_method text                 -- NULL = theo công ty; SPECIFIC = đích danh theo lô (bắt buộc track_lot)
    CHECK (costing_method IN ('PERIODIC_AVG','MOVING_AVG','FIFO','SPECIFIC')),
  CHECK (costing_method IS DISTINCT FROM 'SPECIFIC' OR track_lot OR track_serial),
  track_lot boolean NOT NULL DEFAULT false, track_serial boolean NOT NULL DEFAULT false,
  track_expiry boolean NOT NULL DEFAULT false,
  low_level_code smallint NOT NULL DEFAULT 0,   -- cấp BOM thấp nhất (MRP LLC) – xem §5.6
  default_vat_rate numeric(5,2),
  PRIMARY KEY (tenant_id, id), UNIQUE (tenant_id, company_id, code)
);

CREATE TABLE md.uom_conversions (
  tenant_id uuid NOT NULL, item_id uuid,     -- NULL = quy đổi chung
  from_uom_id uuid NOT NULL, to_uom_id uuid NOT NULL,
  factor numeric(20,10) NOT NULL CHECK (factor > 0),   -- 1 from = factor to
  UNIQUE NULLS NOT DISTINCT (tenant_id, item_id, from_uom_id, to_uom_id)
);

CREATE TABLE md.warehouses (tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, branch_id uuid NOT NULL, code text NOT NULL, name text NOT NULL,
  inventory_account_id uuid,           -- TK kho mặc định
  costing_scope text NOT NULL DEFAULT 'WAREHOUSE' CHECK (costing_scope IN ('WAREHOUSE','COMPANY')),
  PRIMARY KEY (tenant_id, id), UNIQUE (tenant_id, company_id, code));

CREATE TABLE inv.lots (tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  item_id uuid NOT NULL, lot_no text NOT NULL, mfg_date date, expiry_date date,
  production_order_id uuid,            -- lô do lệnh SX nào tạo → truy xuất giá thành
  PRIMARY KEY (tenant_id, id), UNIQUE (tenant_id, item_id, lot_no));

CREATE TABLE inv.serials (tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  item_id uuid NOT NULL, serial_no text NOT NULL, lot_id uuid,
  PRIMARY KEY (tenant_id, id), UNIQUE (tenant_id, item_id, serial_no));
```

**Phạm vi tính giá (`costing key`)**: `(company_id, item_id, valuation_scope)` trong đó `valuation_scope = warehouse_id` nếu tính giá theo từng kho, hoặc `company` nếu tính giá chung toàn công ty (MISA có tuỳ chọn “tính giá theo kho”). Toàn bộ engine dùng khái niệm **cost key** này.

### 4.7 Stock moves & stock ledger (append-only, lũy kế)

```sql
-- Ý định di chuyển, sinh từ dòng chứng từ khi ghi sổ
CREATE TABLE inv.stock_moves (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, document_id uuid NOT NULL, document_line_id uuid NOT NULL,
  item_id uuid NOT NULL, warehouse_id uuid NOT NULL, lot_id uuid, serial_id uuid,
  direction smallint NOT NULL CHECK (direction IN (1,-1)),
  qty numeric(20,6) NOT NULL CHECK (qty > 0),           -- theo ĐVT chính
  move_kind text NOT NULL,   -- 'PURCHASE','SALE','TRANSFER_IN','TRANSFER_OUT','PROD_ISSUE','PROD_RECEIPT',
                             -- 'RETURN_IN','RETURN_OUT','ADJUST','OPENING'
  -- giá vào xác định từ nguồn (mua: giá HĐ + CP mua; nhập TP: từ giá thành; trả lại: giá xuất gốc)
  incoming_rate numeric(24,8),
  valuation_source text NOT NULL CHECK (valuation_source IN ('GIVEN','ENGINE','LINKED')),
  linked_move_id uuid,       -- TRANSFER_IN ↔ TRANSFER_OUT; RETURN ↔ move gốc
  status text NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','CANCELLED')),
  PRIMARY KEY (tenant_id, id)
);

-- Sổ kho: append-only theo (cost key), có lũy kế
CREATE TABLE inv.stock_ledger (
  tenant_id uuid NOT NULL, id bigint GENERATED ALWAYS AS IDENTITY,
  company_id uuid NOT NULL,
  item_id uuid NOT NULL, warehouse_id uuid NOT NULL, lot_id uuid,
  cost_key_scope uuid NOT NULL,          -- warehouse_id hoặc company_id
  stock_move_id uuid NOT NULL,
  posting_date date NOT NULL, posting_time time NOT NULL,
  kind_rank smallint NOT NULL CHECK (kind_rank IN (1,2,3)),
                                         -- thứ tự loại trong ngày (01 §8.5), suy ra từ move_kind:
                                         -- 1 = nhập (PURCHASE, PROD_RECEIPT, RETURN_IN, OPENING, ADJUST tăng)
                                         -- 2 = chuyển (TRANSFER_OUT, TRANSFER_IN)
                                         -- 3 = xuất (SALE, PROD_ISSUE, RETURN_OUT, ADJUST giảm)
  seq bigint NOT NULL,                   -- thứ tự ghi sổ (sequence) – phá hoà cuối cùng; cấp SAU khi đã lấy
                                         -- khoá cost key (Phụ lục A) ⇒ đơn điệu theo key
  fiscal_year smallint NOT NULL,
  qty_change numeric(20,6) NOT NULL,     -- +/- 
  incoming_rate numeric(24,8),           -- cho dòng nhập
  valuation_rate numeric(24,8),          -- giá đơn vị BQ/sau dòng này (moving avg)
  value_change numeric(20,2),            -- +/- giá trị (≈ stock_value_difference của ERPNext) – NGUỒN của bút toán 15x
  valuation_status text NOT NULL DEFAULT 'PROVISIONAL'
    CHECK (valuation_status IN ('PENDING','PROVISIONAL','FINAL')),
                                         -- PENDING: chưa có giá (TP chờ giá thành); PROVISIONAL: giá tạm
                                         -- (BQ tức thời tạm trong kỳ BQ cuối kỳ / xuất âm); FINAL: đã chốt
  qty_after numeric(20,6) NOT NULL,      -- tồn lũy kế theo COST KEY (phục vụ định giá) — KHÔNG dùng để kiểm âm
                                         -- kho (với scope COMPANY nó là tồn toàn công ty; xem kiểm âm bên dưới)
  value_after numeric(20,2),
  valuation_version int NOT NULL DEFAULT 1,
  is_cancelled boolean NOT NULL DEFAULT false,
  PRIMARY KEY (tenant_id, id)
);   -- Giai đoạn 1: không partition (§4.11)

-- Truy vấn "tồn tại thời điểm T" và repost từ T: index theo thứ tự thời gian của cost key
CREATE INDEX sle_key_time ON inv.stock_ledger
  (tenant_id, item_id, cost_key_scope, posting_date, posting_time, kind_rank, seq)
  INCLUDE (qty_after, value_after, valuation_rate) WHERE NOT is_cancelled;
CREATE INDEX sle_not_final ON inv.stock_ledger (tenant_id, company_id, posting_date)
  WHERE valuation_status <> 'FINAL' AND NOT is_cancelled;   -- "còn gì chưa chốt giá?" khi khoá sổ
CREATE INDEX ON inv.stock_ledger (tenant_id, stock_move_id);
CREATE INDEX ON inv.stock_ledger (tenant_id, lot_id) WHERE lot_id IS NOT NULL;
-- Kiểm âm theo cấp kiểm soát vật lý (item, warehouse, lot) — 06b-A4
CREATE INDEX sle_phys_time ON inv.stock_ledger
  (tenant_id, item_id, warehouse_id, lot_id, posting_date, posting_time, kind_rank, seq) WHERE NOT is_cancelled;
```

“Append-only” ở đây nghĩa là: **dòng không bao giờ bị xoá vật lý**; huỷ chứng từ ⇒ `is_cancelled = true` (+ audit); các cột *dẫn xuất* (`valuation_rate`, `value_change`, `qty_after`, `value_after`, `valuation_version`) chỉ được engine giá vốn cập nhật (trigger chặn mọi UPDATE khác, kiểm `current_setting('app.engine')='costing'`). Đây đúng là mô hình *Stock Ledger Entry* của ERPNext — đổi lại thay vì xoá/ghi lại SLE như ERPNext, ta cập nhật tại chỗ có version, vì sổ kho VN cần giữ id ổn định cho truy xuất.

**GL suy ra từ sổ kho (học ERPNext `BaseStockGLComposer`)**: bút toán phần kho của mọi chứng từ kho (Nợ/Có 15x, đối ứng 632/621/627/154/641/642…) **không** tính độc lập mà được *compose* từ `Σ value_change` các dòng `stock_ledger` của từng dòng chứng từ: `value_change > 0` ⇒ Nợ TK kho / Có TK đối ứng của dòng; `< 0` ⇒ ngược lại; chuyển kho dùng TK kho của kho đích. Mỗi khi engine đổi `value_change` (repost/chốt cuối kỳ), composer sinh lại bút toán `source='COSTING'` của chứng từ đó. ⇒ Bất biến K1/K2 (kho = sổ cái 15x; mỗi dòng kho ↔ đúng 1 dòng bút toán) đúng *theo cấu trúc*, không phải nhờ đối chiếu.

**Giá tạm và trạng thái chốt (sửa điểm đau của MISA)**: MISA để phiếu xuất BQ cuối kỳ *không có giá* tới khi chạy batch, rồi ghi đè; người dùng thấy tồn âm giá trị giữa kỳ và không biết số nào đã “chắc”. Ở đây:
- Với BQ cuối kỳ, khi ghi sổ phiếu xuất, engine gán ngay **giá tạm = BQ tức thời** tại thời điểm đó (`valuation_status='PROVISIONAL'`) ⇒ báo cáo giữa kỳ có số hợp lý, không âm giá trị.
- “Tính giá xuất kho cuối kỳ” chuyển các dòng của kỳ sang `FINAL` (giá BQ kỳ), sinh lại bút toán; UI/báo cáo luôn hiển thị nhãn **Tạm tính / Đã chốt** và tổng chênh lệch tạm→chốt.
- Phiếu nhập TP chưa có giá thành ⇒ `PENDING` (giá trị = 0 hoặc giá kế hoạch nếu cấu hình), chuyển `FINAL` khi tính giá thành.
- **Kiểm/cảnh báo tồn âm theo `(item, warehouse, lot)`** (đúng cấp K3, không theo cost key — 06b-A4): khi ghi sổ một dòng xuất SL q tại khoá thứ tự T (kể cả backdated), **sau khi đã lấy khoá A1** (Phụ lục A), tính lũy kế vật lý trực tiếp từ `stock_ledger` (không đọc `qty_after`, vì `qty_after` theo cost key và được repost cập nhật bất đồng bộ):

  ```sql
  -- $1 tenant, $2 item, $3 warehouse, $4 lot (NULL nếu không theo lô), ($5,$6,$7,$8) = khoá thứ tự T của dòng mới
  WITH s AS (
    SELECT posting_date d, posting_time t, kind_rank k, seq,
           sum(qty_change) OVER (ORDER BY posting_date, posting_time, kind_rank, seq) AS run_qty
    FROM inv.stock_ledger
    WHERE tenant_id = $1 AND item_id = $2 AND warehouse_id = $3
      AND lot_id IS NOT DISTINCT FROM $4 AND NOT is_cancelled
  )
  SELECT least(
    coalesce((SELECT run_qty FROM s WHERE (d,t,k,seq) < ($5,$6,$7,$8)
              ORDER BY d DESC, t DESC, k DESC, seq DESC LIMIT 1), 0),     -- tồn ngay trước T
    coalesce((SELECT min(run_qty) FROM s WHERE (d,t,k,seq) > ($5,$6,$7,$8)),
             'Infinity'::numeric)                                         -- tồn thấp nhất sau T
  ) AS available;   -- cấm âm ⇒ yêu cầu available ≥ q
  ```
  Đã chạy thử trên PG16 (`'Infinity'::numeric` cần PG ≥ 14). Khối lượng dữ liệu một DN vừa thì quét cả lịch sử của một `(item, kho, lô)` là chấp nhận được; khi lớn thì bắt đầu từ số dư chốt cuối kỳ khoá gần nhất.
  Tồn âm (khi được phép) ⇒ dòng `PROVISIONAL` + cảnh báo trên màn hình + báo cáo “VTHH tồn âm”; **không cho khoá kỳ** khi còn tồn âm hoặc còn dòng ≠ FINAL trong kỳ (01 §3.8, K3).

Bảng tồn hiện thời (cache để đọc nhanh; **không** phải cơ chế chống âm kho — việc đó do khoá A1 + truy vấn trên):

```sql
CREATE TABLE inv.stock_balances (
  tenant_id uuid NOT NULL, item_id uuid NOT NULL, warehouse_id uuid NOT NULL,
  lot_id uuid, qty numeric(20,6) NOT NULL, value numeric(20,2),
  UNIQUE NULLS NOT DISTINCT (tenant_id, item_id, warehouse_id, lot_id)
);
```

### 4.8 Cost layers (FIFO / đích danh)

```sql
CREATE TABLE cst.cost_layers (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  item_id uuid NOT NULL, cost_key_scope uuid NOT NULL, lot_id uuid,
  in_ledger_id bigint NOT NULL,             -- dòng nhập tạo layer
  in_date date NOT NULL, in_time time NOT NULL, in_seq bigint NOT NULL,
  qty_in numeric(20,6) NOT NULL, unit_cost numeric(24,8) NOT NULL, value_in numeric(20,2) NOT NULL,
  qty_remaining numeric(20,6) NOT NULL, value_remaining numeric(20,2) NOT NULL,
  valuation_version int NOT NULL,
  PRIMARY KEY (tenant_id, id)
);
CREATE INDEX ON cst.cost_layers (tenant_id, item_id, cost_key_scope, in_date, in_time, in_seq)
  WHERE qty_remaining > 0;

-- Tiêu hao layer: dòng xuất lấy từ layer nào, bao nhiêu (đồng thời là cạnh truy xuất)
CREATE TABLE cst.layer_consumptions (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  out_ledger_id bigint NOT NULL, layer_id uuid NOT NULL,
  qty numeric(20,6) NOT NULL, value numeric(20,2) NOT NULL,
  valuation_version int NOT NULL,
  PRIMARY KEY (tenant_id, id)
);

-- Snapshot trạng thái định giá theo cost key tại mốc (cuối mỗi kỳ / mỗi N dòng):
-- repost từ T chỉ cần nạp snapshot gần nhất trước T thay vì replay từ đầu
-- (thay cho stock_queue JSON trên mọi dòng của ERPNext)
CREATE TABLE cst.valuation_snapshots (
  tenant_id uuid NOT NULL, item_id uuid NOT NULL, cost_key_scope uuid NOT NULL,
  as_of_date date NOT NULL, as_of_seq bigint NOT NULL,
  qty numeric(20,6) NOT NULL, value numeric(20,2) NOT NULL,
  open_layers jsonb,                 -- chỉ cho FIFO: [{layer_id, qty_remaining, value_remaining}]
  valuation_version int NOT NULL,
  PRIMARY KEY (tenant_id, item_id, cost_key_scope, as_of_date, as_of_seq)
);

-- Lịch sử điều chỉnh giá trị thủ công (học product.value của Odoo 19): đổi giá nhập TP khi
-- tính giá thành ngoài phần mềm, nhập giá tay khi engine không giải được, đánh giá lại HTK…
CREATE TABLE cst.valuation_adjustments (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  target_type text NOT NULL CHECK (target_type IN ('LEDGER_LINE','COST_KEY_PERIOD','LAYER')),
  target_id text NOT NULL,
  old_rate numeric(24,8), new_rate numeric(24,8),
  old_value numeric(20,2), new_value numeric(20,2),
  reason text NOT NULL, document_id uuid,          -- chứng từ điều chỉnh (SL = 0) nếu có
  user_id uuid NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, id)
);
```

### 4.9 Sản xuất: BOM, lệnh SX

```sql
CREATE TABLE mfg.boms (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  product_id uuid NOT NULL, version text NOT NULL,
  base_qty numeric(20,6) NOT NULL DEFAULT 1,     -- định mức cho bao nhiêu SP
  valid_from date NOT NULL, valid_to date,
  is_default boolean NOT NULL DEFAULT false,
  PRIMARY KEY (tenant_id, id), UNIQUE (tenant_id, product_id, version)
);

CREATE TABLE mfg.bom_lines (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  bom_id uuid NOT NULL, line_no int NOT NULL,
  component_id uuid NOT NULL,
  line_type text NOT NULL CHECK (line_type IN ('MATERIAL','BYPRODUCT','LABOR','OVERHEAD')),
  qty numeric(20,6) NOT NULL, scrap_pct numeric(7,4) NOT NULL DEFAULT 0,
  cost_ratio numeric(20,12),   -- cho phụ phẩm: tỷ lệ/giá trị trừ khỏi giá thành
  PRIMARY KEY (tenant_id, id)
);

CREATE TABLE mfg.production_orders (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, branch_id uuid NOT NULL,
  order_no text NOT NULL, start_date date NOT NULL, end_date date,
  status text NOT NULL CHECK (status IN ('PLANNED','RELEASED','IN_PROGRESS','DONE','CLOSED')),
  cost_object_id uuid NOT NULL,          -- lệnh SX là 1 đối tượng THCP (phương pháp đơn đặt hàng)
  PRIMARY KEY (tenant_id, id), UNIQUE (tenant_id, company_id, order_no)
);

CREATE TABLE mfg.production_order_outputs (
  tenant_id uuid NOT NULL, production_order_id uuid NOT NULL,
  product_id uuid NOT NULL, bom_id uuid, planned_qty numeric(20,6) NOT NULL,
  completed_qty numeric(20,6) NOT NULL DEFAULT 0,
  PRIMARY KEY (tenant_id, production_order_id, product_id)
);
```

### 4.10 Đối tượng THCP, pool chi phí, quy tắc phân bổ, dở dang, bảng giá thành

```sql
-- MỘT miền giá trị khoản mục chi phí dùng chung cho mọi bảng (rà soát N1):
-- DM = NVLTT (621), DL = NCTT (622), MC = máy thi công (623), MOH = SXC (627).
-- TT133 không có 621/622/623/627 nhưng vẫn dùng cùng mã khoản mục trên dòng 154.
CREATE DOMAIN mfg.cost_element AS text CHECK (VALUE IN ('DM','DL','MC','MOH'));

-- Đối tượng tập hợp chi phí (phân xưởng, quy trình/công đoạn, sản phẩm, nhóm SP, lệnh SX, công trình, đơn hàng)
CREATE TABLE mfg.cost_objects (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, code text NOT NULL, name text NOT NULL,
  kind text NOT NULL CHECK (kind IN ('WORKSHOP','PROCESS_STEP','PRODUCT','PRODUCT_GROUP','ORDER','PROJECT','CONTRACT')),
  parent_id uuid, step_no smallint,               -- phân bước
  costing_method text NOT NULL CHECK (costing_method IN
    ('SIMPLE','COEFFICIENT','RATIO','STEP','JOB_ORDER','PROJECT')),  -- giản đơn, hệ số, tỷ lệ, phân bước, đơn hàng, công trình
  PRIMARY KEY (tenant_id, id), UNIQUE (tenant_id, company_id, code)
);
CREATE TABLE mfg.cost_object_products (   -- sản phẩm thuộc đối tượng + hệ số/định mức
  tenant_id uuid NOT NULL, cost_object_id uuid NOT NULL, product_id uuid NOT NULL,
  coefficient numeric(20,12),             -- PP hệ số
  standard_cost numeric(24,8),            -- PP tỷ lệ (giá kế hoạch/định mức)
  PRIMARY KEY (tenant_id, cost_object_id, product_id)
);

-- Kỳ tính giá thành (một lần chạy, có version)
CREATE TABLE mfg.costing_runs (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, period_from date NOT NULL, period_to date NOT NULL,
  status text NOT NULL CHECK (status IN ('DRAFT','COMPUTED','POSTED','SUPERSEDED')),
  run_version int NOT NULL, input_hash bytea,       -- băm tập dữ liệu vào → idempotent
  PRIMARY KEY (tenant_id, id)
);

-- Pool chi phí: chi phí đã tập hợp theo (đối tượng hoặc chung) × khoản mục
CREATE TABLE mfg.cost_pools (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  costing_run_id uuid NOT NULL,
  cost_element mfg.cost_element NOT NULL,
  expense_item_id uuid,                 -- khoản mục chi tiết (6271, 6272, … hoặc mã khoản mục)
  cost_object_id uuid,                  -- NULL = chi phí chung chờ phân bổ
  amount numeric(20,2) NOT NULL,
  PRIMARY KEY (tenant_id, id)
);

CREATE TABLE mfg.allocation_rules (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  cost_element mfg.cost_element NOT NULL, expense_item_id uuid,  -- NULL = mọi khoản mục của element
  basis text NOT NULL CHECK (basis IN
    ('DIRECT_MATERIAL','STANDARD_MATERIAL','DIRECT_LABOR','LABOR_HOURS','MACHINE_HOURS',
     'OUTPUT_QTY','COEFFICIENT','REVENUE','MANUAL')),
  target_scope text NOT NULL CHECK (target_scope IN ('COST_OBJECT','PRODUCT')),
  valid_from date NOT NULL, valid_to date,
  PRIMARY KEY (tenant_id, id)
);

-- Kết quả phân bổ (mỗi cạnh pool → đối tượng)
CREATE TABLE mfg.allocations (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  costing_run_id uuid NOT NULL, pool_id uuid NOT NULL, rule_id uuid,
  cost_object_id uuid NOT NULL, product_id uuid,
  basis_value numeric(24,8) NOT NULL, ratio numeric(20,12) NOT NULL, amount numeric(20,2) NOT NULL,
  PRIMARY KEY (tenant_id, id)
);

-- Dở dang cuối kỳ (và đầu kỳ = cuối kỳ trước)
CREATE TABLE mfg.wip_balances (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL,
  period_end date NOT NULL, cost_object_id uuid NOT NULL, product_id uuid,
  cost_element mfg.cost_element NOT NULL,
  wip_qty numeric(20,6), completion_pct numeric(7,4),
  method text NOT NULL CHECK (method IN ('DIRECT_MATERIAL','EQUIVALENT_UNITS','STANDARD','MANUAL','NONE')),
  amount numeric(20,2) NOT NULL,
  costing_run_id uuid NOT NULL,
  UNIQUE NULLS NOT DISTINCT (tenant_id, company_id, period_end, cost_object_id, product_id, cost_element)
);

-- Bảng tính giá thành: 1 dòng / (run, đối tượng, SP, khoản mục)
CREATE TABLE mfg.product_cost_sheets (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  costing_run_id uuid NOT NULL, cost_object_id uuid NOT NULL, product_id uuid NOT NULL,
  production_order_id uuid,
  cost_element mfg.cost_element NOT NULL,
  wip_opening numeric(20,2) NOT NULL, incurred numeric(20,2) NOT NULL,
  wip_closing numeric(20,2) NOT NULL, byproduct_deduction numeric(20,2) NOT NULL DEFAULT 0,
  total_cost numeric(20,2) GENERATED ALWAYS AS (wip_opening + incurred - wip_closing - byproduct_deduction) STORED,
  output_qty numeric(20,6) NOT NULL,
  unit_cost numeric(24,8) NOT NULL,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, costing_run_id, cost_object_id, product_id, cost_element)
);
-- Truy vết ngược: xem §6 (cst.cost_flow_edges)
```

### 4.11 Index & partition — nguyên tắc

- **Giai đoạn 1 không partition bảng nào** (06b-D2): một DN với 3 kho, vài nghìn mã hàng thì `journal_lines`, `stock_ledger`, `audit.change_log`, `cst.cost_flow_edges` ước chừng không quá vài triệu dòng/năm (ước lượng, chưa đo trên dữ liệu khách), index thường là đủ. Cột `fiscal_year` vẫn giữ trên các bảng này để partition về sau không phải đổi dữ liệu.
- **Khi nào partition**: khi đo được nhu cầu thật — truy vấn báo cáo năm chậm dù đã có index, vacuum/bloat của bảng lớn thành vấn đề, hoặc cần tách dữ liệu năm cũ (lưu trữ 10 năm) — chứ không làm trước. Dự kiến: `journal_lines`, `stock_ledger`, `cst.cost_flow_edges` LIST theo `fiscal_year`; `audit.change_log` RANGE theo tháng.
- **Yêu cầu bắt buộc khi partition** (chưa chạy thử trên PG18):
  1. PK/unique phải chứa cột partition ⇒ PK đổi thành `(tenant_id, fiscal_year, id)`; FK đang trỏ vào `(tenant_id, id)` của bảng đó phải thêm `fiscal_year` (hoặc bỏ FK, thay bằng job kiểm toàn vẹn — ghi rõ từng chỗ).
  2. RLS **không** tự áp khi truy vấn trực tiếp vào partition con: mọi partition tạo qua một hàm duy nhất `app.create_partition()` luôn `ENABLE` + `FORCE ROW LEVEL SECURITY` và tạo policy `tenant_isolation` cho từng partition; `REVOKE ALL` trên partition con với `app_user` (chỉ truy cập qua bảng cha).
  3. Test quét `pg_class` gồm cả partition con (`relispartition`), như §2.1.
  4. `fillfactor`/storage parameter đặt trên từng partition (không đặt được trên bảng cha), trong cùng hàm tạo partition.
  5. Constraint trigger (Nợ = Có §4.5), trigger guard (§7.1, §7.2) và trigger audit phải được kiểm lại trên bảng partitioned — chưa chạy thử.
- PK/Index luôn bắt đầu bằng `tenant_id` (RLS + locality). Khi một tenant cực lớn → chuyển sang cell riêng chứ không hash-partition theo tenant (đơn giản vận hành).
- Index partial `WHERE is_active` / `WHERE NOT is_cancelled` / `WHERE qty_remaining > 0`.
- BRIN trên `posting_date` cho bảng append theo thời gian.
- Không dùng FK từ bảng partitioned lớn sang bảng lớn khác nếu ảnh hưởng ghi (journal_lines → document_lines chỉ giữ id, kiểm bằng test toàn vẹn định kỳ); FK tới danh mục giữ lại.
- `autovacuum` tinh chỉnh cho `stock_ledger` (UPDATE dẫn xuất khi repost tạo bloat); `fillfactor=80` đặt được vì Giai đoạn 1 không partition. Lưu ý: HOT update chỉ xảy ra khi cột bị cập nhật không nằm trong index nào — hiện `sle_key_time` INCLUDE `qty_after, value_after, valuation_rate` nên chưa đạt (06b-D11, chưa xử lý trong bản này).

---

## 5. Engine giá vốn

### 5.1 Nguyên tắc

1. **Thuần (pure core)**: thuật toán tính giá trong `packages/costing/core` là hàm thuần nhận chuỗi giao dịch đã sắp xếp + trạng thái đầu → trả giá trị từng dòng + trạng thái cuối. Không IO ⇒ golden test & property test dễ.
2. **Đơn vị xử lý = cost key** `(company, item, scope)`. Các cost key độc lập được chạy **song song**; phụ thuộc giữa các key (chuyển kho, sản xuất, trả lại) được xử lý qua **đồ thị phụ thuộc** (§5.5–5.6).
3. **Thứ tự chuẩn** của giao dịch: `(posting_date, posting_time, kind_rank, seq)` — trong cùng ngày **nhập < chuyển < xuất**, sau đó theo thứ tự ghi sổ (01 §8.5). `kind_rank`: 1 = nhập, 2 = chuyển, 3 = xuất (định nghĩa đầy đủ ở cột `inv.stock_ledger.kind_rank`, §4.7). `seq` cấp từ sequence **sau khi** đã lấy khoá cost key (Phụ lục A) ⇒ xác định, ổn định và đơn điệu theo key. (Mặc định `posting_time = 00:00` như MISA, nên `kind_rank` thực sự quyết định.) Một hàm duy nhất dùng cho cả SQL `ORDER BY` và TS, có test so khớp hai phía:
   ```ts
   type SortKey = { date: string; time: string; kindRank: 1 | 2 | 3; seq: bigint };
   const compareKey = (a: SortKey, b: SortKey) =>
     cmp(a.date, b.date) || cmp(a.time, b.time) || a.kindRank - b.kindRank || cmp(a.seq, b.seq);
   // SQL tương ứng: ORDER BY posting_date, posting_time, kind_rank, seq
   ```
4. **Idempotent**: chạy lại engine với cùng dữ liệu vào cho cùng kết quả; mỗi lần ghi kết quả tăng `valuation_version`, chỉ ghi khi giá trị khác (so sánh trước khi UPDATE ⇒ giảm bloat & sự kiện thừa).
5. **Khoá (06b-A1)**: mọi giao dịch đọc/ghi tồn hoặc giá của một cost key — **cả ghi sổ chứng từ lẫn worker repost** — lấy `pg_advisory_xact_lock(hashtextextended('ck:'||tenant||':'||item||':'||scope||':'||coalesce(lot,''), 0))`; ghi sổ thêm khoá vật lý `'pk:'||tenant||item||warehouse||lot` cho kiểm âm (§4.7). Giao dịch cần nhiều khoá thì lấy **theo thứ tự tăng dần của giá trị băm** ⇒ không deadlock. Worker repost chỉ giữ một khoá cost key tại một thời điểm.
6. **Không vượt kỳ đã khoá**: repost không bao giờ sửa dòng có `posting_date <= locked_through(COSTING)` (đọc `period_locks … FOR SHARE`, §7.2); nếu cần ⇒ lỗi nghiệp vụ, yêu cầu mở khoá.
7. **Làm tròn**: theo R1 (§1.4) ở mọi phương pháp.

### 5.2 Bình quân gia quyền tức thời (moving average)

```
// T: SortKey điểm bắt đầu; mọi phép tiền dùng Decimal, round = R1 (a)
state = stateBefore(key, T)        // { qty, value } ngay trước T theo compareKey
                                   // (= qty_after/value_after của dòng liền trước T, hoặc snapshot + replay)
for sle in ledger(key) where sortKey(sle) >= T order by posting_date, posting_time, kind_rank, seq:
  q = abs(sle.qty_change)          // SL của dòng, luôn > 0
  if sle.qty_change > 0:                                    // nhập (kind_rank 1, hoặc TRANSFER_IN)
     inValue = sle.valuation_source == 'GIVEN'  ? sle.given_value      // thành tiền trên chứng từ (+ CP mua phân bổ);
                                                                       // KHÔNG tính lại q × đơn giá (R1 a)
             : sle.valuation_source == 'LINKED' ? valueOf(sle.linked_move)  // chuyển kho / trả lại (giá vốn dòng gốc)
             : /* 'ENGINE' */                     costFromProduction(sle)   // nhập TP/BTP từ giá thành
     state.qty += q; state.value += inValue
     valueChange = inValue
  else:                                                     // xuất
     if q > state.qty: handleNegativeStock(sle, state)      // xem 5.7 (state.qty ≤ 0 cũng rơi vào đây)
     outValue = (q == state.qty) ? state.value              // R1 (c): xuất làm tồn về 0 nhận toàn bộ giá trị còn lại
                                 : round(q * state.value / state.qty)   // R1 (c): từ tổng giá trị, không từ rate đã làm tròn
     state.qty -= q; state.value -= outValue
     valueChange = -outValue
  rate = state.qty > 0 ? round4(state.value / state.qty) : null   // 4 số lẻ, CHỈ để hiển thị (R1 a)
  write(sle, value_change = valueChange, qty_after = state.qty, value_after = state.value, valuation_rate = rate)
```

Điểm quan trọng: dùng `value/qty` tại thời điểm xuất (không dùng rate đã làm tròn) và quy tắc “xuất hết thì lấy hết giá trị” ⇒ không bao giờ có tồn 0 mà giá trị ≠ 0. Ví dụ 01 §3.4: X2 = round(100 × 1.733.333 / 150) = 1.155.555; tồn 577.778.

### 5.3 Bình quân gia quyền cuối kỳ (periodic average) — mặc định của nhiều DN VN

Trong kỳ, dòng xuất mang **giá tạm** = BQ tức thời tại thời điểm xuất (`valuation_status='PROVISIONAL'`, xem §4.7) — khác MISA (để trống rồi ghi đè), giúp báo cáo giữa kỳ không âm giá trị. Cuối kỳ chạy “Tính giá xuất kho” để **chốt** (`FINAL`):

```
unit_cost(key, period) = (opening_value + Σ inbound_value) / (opening_qty + Σ inbound_qty)
```
– inbound gồm mua, nhập TP (từ giá thành), nhập chuyển kho (= giá xuất của kho nguồn), điều chỉnh giá trị nhập (SL = 0). Nhập hàng bán trả lại — **một mặc định duy nhất** (01 §3.3): giá vốn lúc xuất bán của chính dòng hoá đơn gốc (LINKED); dòng gốc cùng kỳ ⇒ loại khỏi mẫu số, nhận giá sau khi chốt `unit_cost`; dòng gốc thuộc kỳ trước ⇒ giá đã chốt, tham gia bình quân.
– Sau khi có tổng `(V, Q)` của kỳ (V = opening_value + Σ inbound_value, Q = opening_qty + Σ inbound_qty): mỗi dòng xuất = `round(q × V / Q)` (R1 (c), không nhân từ `unit_cost` đã làm tròn); phần dư nằm lại ở tồn cuối, `closing_value = V − Σ out`; nếu tồn cuối kỳ SL = 0 thì dòng xuất làm tồn về 0 (dòng cuối theo `compareKey`) nhận toàn bộ giá trị còn lại ⇒ `closing_qty = 0 ⇒ closing_value = 0`.

Vì nhập chuyển kho / nhập TP phụ thuộc giá của key khác ⇒ đây là **hệ phương trình tuyến tính**, giải ở §5.6.

Biến thể “bình quân theo tháng trong năm tài chính” và “bình quân cuối kỳ theo kỳ tính giá tuỳ chọn (tuần/tháng/quý)” chỉ khác tham số period.

### 5.4 FIFO và đích danh

```
FIFO, repost từ T cho key K:
  1. Khôi phục layers tại T: layers có in_ts < T, với qty_remaining = qty_in − Σ consumptions bởi out có ts < T
     (truy vấn: xoá consumptions của các dòng xuất ts ≥ T; tính lại remaining).
  2. Xoá layers được tạo bởi dòng nhập ts ≥ T (version cũ).
  3. Duyệt dòng theo thứ tự từ T:
       nhập  → tạo layer (qty, unit_cost)
       xuất q → lấy layer cũ nhất có remaining > 0 (với lot: chỉ layer cùng lot_id)
                 take = min(q, qty_remaining)
                 value = (take == qty_remaining) ? value_remaining                         // R1 (c): lô về 0 nhận hết
                                                 : round(take × value_remaining / qty_remaining)  // không dùng unit_cost
                 ghi layer_consumptions; qty_remaining −= take; value_remaining −= value; q −= take; lặp
       trả lại hàng bán (RETURN_IN linked) → giá = giá vốn dòng xuất gốc theo tỷ lệ SL (R1 c);
                 FIFO: tạo layer mới; đích danh: cộng trả lại vào đúng lô gốc
  4. Cập nhật qty_after/value_after cho từng sle.
Đích danh (SPECIFIC) = cùng thuật toán nhưng dòng xuất BẮT BUỘC chỉ định lot (hoặc serial) và chỉ tiêu hao
layer của lô đó; cost key gồm lot ⇒ mỗi lô là một nguồn giá. Ví dụ đầy đủ (NVL → BTP nhiều giai đoạn → TP): 01 §4.6.
```

### 5.5 Repost khi có chứng từ backdated (học từ ERPNext *Repost Item Valuation* & Odoo 19 `_correct_inventory_valuation(from_date)`)

Ghi chú nguồn (02): ERPNext repost bất đồng bộ có checkpoint/resume, khử trùng lặp, chặn trước kỳ khoá — ta lấy nguyên các ý này. Odoo 17/18 (SVL) **không** hỗ trợ backdate; Odoo 19 bỏ SVL, giá trị nằm trên `stock.move` và có replay từ ngày sớm nhất bị ảnh hưởng — trùng hướng thiết kế ở đây. Khác ERPNext: không lưu FIFO queue JSON trên từng dòng mà dùng `cost_layers` + `valuation_snapshots` (§4.8).

Sự kiện gây repost: ghi sổ/bỏ ghi chứng từ kho có `posting_ts` < ts dòng cuối của key; sửa giá nhập (chi phí mua phân bổ về sau, hoá đơn NCC đến muộn ⇒ landed cost); thay đổi giá thành TP; chuyển kho từ key đã thay đổi.

```sql
CREATE TABLE cst.repost_requests (       -- NGUỒN SỰ THẬT của việc cần tính lại (06b-A3), không phải BullMQ
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, item_id uuid NOT NULL, cost_key_scope uuid NOT NULL,
  lot_id uuid,                            -- chỉ khi cost key theo lô (SPECIFIC)
  from_date date NOT NULL, from_time time NOT NULL,
  from_kind_rank smallint NOT NULL, from_seq bigint NOT NULL,   -- đủ 4 thành phần của compareKey (06b-A6)
  status text NOT NULL DEFAULT 'QUEUED' CHECK (status IN ('QUEUED','RUNNING','DONE','FAILED')),
  lease_until timestamptz,                -- RUNNING quá hạn lease ⇒ cron trả về QUEUED (worker chết)
  checkpoint_key jsonb, checkpoint_state jsonb,   -- SortKey + {qty, value | layers} sau lô đã commit
  cause jsonb, attempts int NOT NULL DEFAULT 0, error text,
  PRIMARY KEY (tenant_id, id)
);
-- Gộp: chỉ 1 request QUEUED / key; request mới thì lùi điểm bắt đầu về điểm sớm hơn.
-- Request RUNNING không nằm trong index ⇒ yêu cầu mới đến trong lúc đang chạy tạo QUEUED riêng, không bị nuốt.
CREATE UNIQUE INDEX repost_one_queued ON cst.repost_requests
  (tenant_id, item_id, cost_key_scope, lot_id) NULLS NOT DISTINCT
  WHERE status = 'QUEUED';
```

```sql
-- Upsert gộp (trong transaction ghi sổ, dưới khoá cost key). So sánh đủ (ngày, giờ, kind_rank, seq) — 06b-A6.
-- Đã chạy thử trên PG16 (tham chiếu EXCLUDED và bảng đích trong subquery của SET hợp lệ).
INSERT INTO cst.repost_requests AS r
  (tenant_id, company_id, item_id, cost_key_scope, lot_id, from_date, from_time, from_kind_rank, from_seq, cause)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
ON CONFLICT (tenant_id, item_id, cost_key_scope, lot_id) WHERE status = 'QUEUED'
DO UPDATE SET (from_date, from_time, from_kind_rank, from_seq) =
  (SELECT d, t, k, s FROM (VALUES
       (EXCLUDED.from_date, EXCLUDED.from_time, EXCLUDED.from_kind_rank, EXCLUDED.from_seq),
       (r.from_date,        r.from_time,        r.from_kind_rank,        r.from_seq)) v(d, t, k, s)
   ORDER BY d, t, k, s LIMIT 1)
RETURNING id;          -- id này là jobId của tín hiệu BullMQ (qua outbox)
```

Worker (pseudo-code TS) — **không giữ transaction dài** (06b-A2):

```ts
const BATCH = 5_000;
async function processRepost(requestId: string, tenantId: string) {
  // (1) Claim bằng transaction ngắn rồi commit ngay
  const req = await withTenantTx(sys(tenantId), tx => sql`
      UPDATE cst.repost_requests
         SET status = 'RUNNING', lease_until = now() + interval '5 minutes', attempts = attempts + 1
       WHERE id = (SELECT id FROM cst.repost_requests
                    WHERE id = ${requestId} AND status = 'QUEUED'
                    FOR UPDATE SKIP LOCKED)
      RETURNING *`.execute(tx).then(one));
  if (!req) return;                                     // đã có worker khác nhận, hoặc đã xong

  const method = await costingMethodOf(req);            // SPECIFIC/FIFO/MOVING_AVG/PERIODIC_AVG
  let cursor = req.checkpoint_key ? { from: req.checkpoint_key, state: req.checkpoint_state, first: false }
                                  : { from: startKeyOf(req), state: null, first: true };
  // (2) Mỗi lô một transaction: lấy lại khoá cost key (cùng khoá với postDocument), kiểm lease, commit checkpoint
  for (;;) {
    const finished = await withTenantTx(sys(tenantId), async (tx) => {
      await advisoryLock(tx, costKeyLock(req));          // §5.1 mục 5
      await renewLeaseOrThrow(tx, req.id);               // UPDATE … WHERE status='RUNNING' AND lease_until > now()
      await assertNotLockedForShare(tx, req, 'COSTING'); // period_locks … FOR SHARE (§7.2)
      if (cursor.first && method === 'PERIODIC_AVG')
        await markPeriodDirty(tx, req);                  // dòng FINAL của kỳ quay về PROVISIONAL
      const state = cursor.state ?? await stateBefore(tx, req, cursor.from);
      const rows  = await ledgerBatch(tx, req, cursor.from, BATCH);   // ORDER BY posting_date, posting_time, kind_rank, seq
      const result  = runEngine(method, state, rows, resolvers(tx));   // core thuần
      const changed = diff(rows, result);
      await writeValuation(tx, changed);                 // bump valuation_version
      await regenerateCogsJournal(tx, changed);          // bản cũ is_active=false, bản mới vẫn cân Nợ/Có
      for (const d of downstream(changed))               // TRANSFER_OUT→TRANSFER_IN, PROD_ISSUE→giá thành, SALE→RETURN_IN
        await enqueueRepost(tx, d.key, d.fromKey, { cause: 'propagation', from: req.id });   // upsert ở trên + outbox
      cursor = { from: nextKeyAfter(last(rows)), state: result.endState, first: false };
      await saveCheckpoint(tx, req.id, cursor);          // checkpoint_key, checkpoint_state
      return rows.length < BATCH;
    });
    if (finished) break;
  }
  // (3) Kết thúc: transaction ngắn
  await withTenantTx(sys(tenantId), async (tx) => {
    await markDone(tx, req.id);
    await outbox(tx, 'ValuationChanged', { key: costKeyOf(req), from: startKeyOf(req) });
  });
}
```
Giữa hai lô, giao dịch ghi sổ khác được chen vào cùng key (khoá chỉ giữ trong một lô). Dòng mới ở **sau** con trỏ sẽ được chính lần chạy này tính khi tới; dòng mới ở **trước** con trỏ tạo request QUEUED mới (không xung đột với request RUNNING). Khi key còn request QUEUED/RUNNING, `postDocument` không `valueInline` mà để dòng `PROVISIONAL` cho worker tính.

Đặc tính:
- **Gộp (coalescing)**: 50 chứng từ backdated vào cùng key ⇒ 1 lần repost từ điểm sớm nhất.
- **Song song**: các cost key khác nhau chạy song song; BullMQ chỉ đánh thức (`jobId` = request id, §1.5); advisory lock cost key bảo đảm một key chỉ có một người sửa tại một thời điểm.
- **Lan truyền & chu trình**: lan truyền theo cạnh; nếu đồ thị có chu trình (A→B→A chuyển qua lại) thì vì mỗi lần lan truyền đi *tới tương lai* (ts nhận ≥ ts gửi) và có điểm dừng “không đổi giá trị ⇒ không lan truyền” nên hội tụ; thêm giới hạn `maxPropagationDepth` + cảnh báo.
- **Theo lô, commit theo checkpoint** (mọi kích thước, không chỉ kỳ lớn): sau mỗi lô lưu `checkpoint_key`, `checkpoint_state` vào request trong cùng transaction với kết quả lô đó ⇒ crash giữa chừng thì resume từ checkpoint — như `current_index`/`reposting_data_file` của ERPNext. Cron trả request RUNNING hết lease về QUEUED (giữ checkpoint); nếu key đó đã có request QUEUED khác thì gộp vào request QUEUED (lùi điểm bắt đầu về `least(checkpoint_key, from của QUEUED)`) và đóng request cũ là `FAILED` với lý do "merged".
- **Hiển thị trạng thái**: báo cáo kho/giá vốn hiển thị banner “Đang tính lại giá từ ngày …” khi còn request QUEUED/RUNNING trong phạm vi báo cáo.

### 5.6 Phụ thuộc giữa các key & vòng lặp sản xuất (BQ cuối kỳ + giá thành)

Cuối kỳ, với BQ cuối kỳ, đặt ẩn `c_k` = giá đơn vị của key k trong kỳ.

```
c_k · Q_k = V_k^0 + P_k + Σ_j  a_kj · c_j  + M_k(c)
  Q_k   = tồn đầu + tổng nhập kỳ (số lượng)
  V_k^0 = giá trị tồn đầu ; P_k = giá trị nhập có giá cho trước (mua, CP mua)
  a_kj  = số lượng nhập vào k từ xuất của key j (chuyển kho j→k)
  M_k(c)= giá trị nhập TP/BTP k từ sản xuất = phần của giá thành phân cho k,
          trong đó chi phí NVL (621) = Σ_m q_m · c_m (NVL xuất cho SX, có thể là BTP/TP khác)
          cộng NC, SXC (hằng số) ± dở dang (phụ thuộc tuyến tính vào c nếu đánh giá DD theo NVL)
```

Tất cả đều tuyến tính theo c ⇒ hệ `(D − A) c = b` (D = diag(Q_k)).

Thuật toán:

```
1. Dựng đồ thị G: nút = cost key; cạnh j→k nếu k nhận giá trị từ xuất của j (chuyển kho, NVL→TP qua đối tượng THCP).
2. Tìm thành phần liên thông mạnh (Tarjan SCC), sắp xếp topo các SCC.
   - Với hàng hoá thuần thương mại: phần lớn SCC 1 nút ⇒ tính trực tiếp theo thứ tự topo.
   - Với sản xuất không vòng: thứ tự topo ≡ thứ tự low_level_code của BOM (NVL → BTP → TP).
3. Với SCC nhiều nút (chuyển kho qua lại; TP quay lại làm NVL – vd. tái chế phế phẩm, BTP dùng chéo):
   - Mặc định (n ≤ 200, đủ cho DN vừa): giải đúng bằng khử Gauss với Decimal (độ chính xác 40) → c.
   - Dự phòng khi n lớn: lặp Gauss–Seidel trên GIÁ TRỊ y_k = Q_k·c_k (không trên đơn giá, vì đơn vị
     SL của NVL (kg) và SP (cái) khác nhau nên so a_kj với Q_k là vô nghĩa — 06b-A9):
       y_k ← V_k^0 + P_k + Σ_j b_kj · y_j        với b_kj = (phần SL của j chảy vào k) / Q_j
       (P_k gồm cả NC, SXC hằng số của sản xuất; phần giá trị NVL giữ lại ở dở dang làm b_kj nhỏ đi)
     Điều kiện hội tụ đúng: tổng theo CỘT Σ_k b_kj ≤ 1 với mọi j (không key nào chuyển đi quá giá trị nó có —
     đúng khi không âm kho), và **mỗi SCC có "rò"** ra ngoài (ít nhất một key trong SCC có bán, xuất ra ngoài
     SCC, tồn cuối > 0 hoặc dở dang giữ lại giá trị, tức Σ_k b_kj < 1) ⇒ bán kính phổ < 1, Jacobi hội tụ,
     và với ma trận không âm thì Gauss–Seidel hội tụ khi Jacobi hội tụ (Stein–Rosenberg).
     Dừng khi max_k |round(y_k^(t+1)) − round(y_k^(t))| < 1 đồng (giá trị làm tròn đến đồng không còn đổi),
     tối đa N vòng (cấu hình); hết N vòng mà chưa dừng ⇒ coi như không hội tụ.
   - Trước khi giải: SCC có key tồn âm (Q_k ≤ 0 hoặc xuất > Q_k) ⇒ phá điều kiện trên ⇒ báo lỗi nghiệp vụ ngay.
   - Không hội tụ / suy biến (Q_k = 0 hoặc toàn bộ nguồn của SCC chỉ là nội bộ, không rò) ⇒ báo lỗi nghiệp vụ,
     cho phép người dùng nhập giá thủ công (giống MISA cảnh báo "không tính được giá").
4. Sau khi có c (hoặc y): định giá dòng xuất theo R1 (c) từ tổng giá trị y_k, tính giá thành, ghi giá nhập TP
   (chia Z cho nhiều phiếu nhập theo R1 (b)), sinh bút toán.
5. Lưu ma trận/vector vào costing_run (jsonb nén) để audit "vì sao giá ra như vậy".
```

Pseudo-code điều phối cuối kỳ:

```ts
async function periodClose(companyId, period) {
  const keys = await dirtyKeys(companyId, period);             // + mọi key có phát sinh
  const g = buildDependencyGraph(keys, transfers, prodIssues, prodReceipts, bomCostObjects);
  for (const scc of topoSort(tarjan(g))) {
    const sys = assembleLinearSystem(scc, solvedCosts);        // dùng c đã giải của SCC phía trước làm hằng số
    assertNoNegativeStock(scc);                                  // âm kho phá điều kiện hội tụ ⇒ lỗi nghiệp vụ
    const c = scc.size === 1 ? solveSingle(sys)
            : scc.size <= 200 ? gaussDecimal(sys)                // mặc định
            : gaussSeidelOnValues(sys, { stopBelow: 1 /* đồng */, maxIter: N });   // dự phòng
    solvedCosts.set(scc, c);
    if (scc.hasProductionNodes) computeProductCost(scc, c);     // §5.8
  }
  await persistValuation(solvedCosts);                         // ledger, cost sheets, journals — 1 transaction/SCC
}
```

### 5.7 Âm kho, trả lại, chi phí mua về sau

- **Âm kho**: cấu hình tenant `allow_negative_stock`. Nếu cho phép: dòng xuất khi tồn ≤ 0 lấy giá = giá gần nhất (last valuation rate) ⇒ khi có nhập sau, sinh **dòng điều chỉnh chênh lệch** (giống Odoo “negative stock correction”) gắn vào dòng nhập. Nếu không cho phép: chặn tại ghi sổ, **dưới khoá vật lý `(item, warehouse, lot)` của A1**, bằng truy vấn lũy kế vật lý ở §4.7 (tồn ngay trước T và tồn thấp nhất sau T đều phải ≥ q). Không dùng `qty_after` (theo cost key, cập nhật bất đồng bộ) và không dùng `stock_balances` (chỉ là cache).
- **Hàng bán trả lại**: nhập lại theo giá vốn lúc xuất bán của chính dòng hoá đơn gốc (LINKED, mặc định duy nhất — 01 §3.3) — repost dòng bán gốc ⇒ lan truyền.
- **Chi phí mua / hoá đơn đến sau** (landed cost, giảm giá hàng mua): tăng/giảm giá trị dòng nhập gốc nếu hàng còn tồn; phần đã xuất phân bổ vào 632 (cấu hình) — engine xử lý tự nhiên qua repost từ ts dòng nhập.

### 5.8 Tính giá thành (manufacturing costing run)

```
Input kỳ: chi phí tập hợp (journal_lines TK 621/622/627 hoặc 154 chi tiết theo cost_object & expense_item),
          NVL xuất cho SX (giá từ engine, có thể là ẩn c của SCC), sản lượng hoàn thành, dở dang SL & % hoàn thành.
1. Tập hợp: cost_pools ← SUM journal theo (element, expense_item, cost_object); không có cost_object ⇒ pool chung.
2. Phân bổ chi phí chung: với mỗi pool chung và rule hợp lệ:
     basis_k = đại lượng theo basis cho đối tượng k (NVLTT thực tế, định mức NVL, giờ công, SL quy đổi theo hệ số…)
     amount_k = largestRemainder(pool.amount, basis_k)         // R1 (b), định nghĩa ở §1.4; Σ amount_k == pool.amount
     ghi mfg.allocations + cạnh cost_flow_edges (pool → cost_object)
3. Đánh giá dở dang cuối kỳ cho từng đối tượng/element:
     DIRECT_MATERIAL : DD = (DDĐK_DM + CP_DM) / (SL_HT + SL_DD) × SL_DD ; DL,MOH = 0
     EQUIVALENT_UNITS: DM như trên (bỏ vào 1 lần đầu quy trình);
                       DL/MOH = (DDĐK + CP) / (SL_HT + SL_DD × %HT) × SL_DD × %HT
     STANDARD        : DD = SL_DD × định mức × %HT
4. Tổng giá thành đối tượng = DDĐK + CP phát sinh − DDCK − phụ phẩm
5. Chia cho sản phẩm theo phương pháp:
     SIMPLE      : 1 SP / đối tượng → unit = tổng / SL
     COEFFICIENT : SL quy đổi = Σ SL_i × hệ số_i ; giá SP chuẩn = tổng / SL quy đổi ; unit_i = giá chuẩn × hệ số_i
     RATIO       : tỷ lệ = tổng thực tế / Σ (SL_i × giá định mức_i) ; unit_i = định mức_i × tỷ lệ
     STEP        : bước n nhận giá thành BTP bước n-1 (kết chuyển tuần tự hoặc song song) → SCC/topo tự nhiên.
                   TỰ ĐỘNG trong 1 costing run (MISA phải lập nhiều kỳ giá thành thủ công, mỗi kỳ 1 công đoạn):
                   cost_objects có parent/step_no + BOM đa cấp ⇒ engine sắp thứ tự theo low_level_code,
                   tính bước 1 → cập nhật giá nhập BTP → giá xuất BTP sang bước 2 → … trong cùng vòng lặp §5.6.
                   BTP chuyển một phần sang bước sau: GT = round(SL chuyển × Z_BTP còn lại / SL BTP còn lại) (R1 c),
                   phần còn lại ở 154 của bước trước; tách GT chuyển theo khoản mục bằng R1 (b) (ví dụ số: 01 §4.6).
     JOB_ORDER   : tổng theo lệnh SX; DD = toàn bộ CP lệnh chưa xong
6. Ghi product_cost_sheets; Z của đối tượng chia cho các phiếu nhập TP/BTP (nhiều lô, nhiều phiếu) bằng R1 (b)
   (trọng số = SL, hoặc SL × hệ số / giá định mức); cập nhật giá trị nhập cho stock moves PROD_RECEIPT
   (valuation_source='ENGINE'; unit cost 4 số lẻ chỉ để hiển thị);
   sinh bút toán Nợ 155/Có 154 (và kết chuyển 621/622/627 → 154 theo TT200/TT99, hoặc trực tiếp 154 theo TT133).
```

**BOM đa cấp** (MISA chỉ 1 cấp): `bom_lines.component_id` có thể là BTP có BOM riêng; `md.items.low_level_code` tính lại mỗi khi BOM đổi (BFS từ TP xuống, LLC = độ sâu lớn nhất); phát hiện BOM vòng ⇒ chặn lưu trừ khi dòng được đánh dấu `is_recycle` (tái chế/thu hồi) — trường hợp đó được giải bằng SCC ở §5.6. **Mô hình dữ liệu và engine đa cấp ngay từ đầu** (khách hàng có quy trình nhiều giai đoạn); phạm vi giao diện theo `KE-HOACH-DU-AN.md` v0.3.

Tất cả công thức nằm trong core thuần; số liệu kiểm bằng ví dụ giáo trình (§8.3). **[ĐỐI CHIẾU 01 §4, 03: ví dụ số các phương pháp]**

### 5.9 Tập hợp & phân bổ 621/622/627 → 154 (tự thiết kế, theo mô hình cost element)

Không repo tham khảo nào có sẵn (02). Mô hình lấy ý tưởng *cost element* của iDempiere (Material/Labor/Overhead) và ánh xạ sang kế toán VN:

```sql
-- Ánh xạ TK chi phí (theo standard_code/role) → yếu tố chi phí; cấu hình theo chế độ
CREATE TABLE mfg.cost_element_map (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL,
  account_id uuid NOT NULL,                -- 621x, 622x, 623x, 627x (TT99/TT200) hoặc 154 chi tiết (TT133)
  expense_item_id uuid,                    -- khoản mục CP (bắt buộc với TT133 vì mọi thứ dồn vào 154)
  cost_element mfg.cost_element NOT NULL,  -- domain chung §4.10
  behavior text NOT NULL DEFAULT 'VARIABLE' CHECK (behavior IN ('FIXED','VARIABLE')),  -- cho SXC
  UNIQUE NULLS NOT DISTINCT (tenant_id, company_id, account_id, expense_item_id)
);
-- Công suất bình thường (VAS 02) theo đối tượng THCP & kỳ
CREATE TABLE mfg.normal_capacity (
  tenant_id uuid NOT NULL, cost_object_id uuid NOT NULL,
  valid_from date NOT NULL, valid_to date,
  capacity_qty numeric(20,6) NOT NULL,     -- SL SP (hoặc giờ máy) ở công suất bình thường / kỳ
  capacity_basis text NOT NULL CHECK (capacity_basis IN ('OUTPUT_QTY','MACHINE_HOURS','LABOR_HOURS')),
  PRIMARY KEY (tenant_id, cost_object_id, valid_from)
);
```

Thuật toán (bước 5 của quy trình khoá sổ 01 §6):

```
1. Thu thập: với mỗi journal_line active trong kỳ có TK thuộc cost_element_map:
     pool_key = (cost_element, behavior, expense_item, cost_object | NULL)
     (bất biến I6: 621/622/154 bắt buộc có cost_object; 627 được để trống = chờ phân bổ)
2. SXC cố định dưới công suất (VAS 02):
     với pool MOH-FIXED của đối tượng/phân xưởng k:
       util = min(1, actual_k / capacity_k)
       absorbed = round(pool × util) ; unabsorbed = pool − absorbed
       unabsorbed → bút toán Nợ 632 / Có 627x (source='ALLOCATION'), cạnh trace pool → 'COGS_UNABSORBED'
     MOH-VARIABLE phân bổ hết theo thực tế.
     (VD 01 §4.2: 627 cố định 10tr, công suất 1.000, thực tế 800 → 8tr vào Z, 2tr → 632)
3. Phân bổ pool chung theo allocation_rules (§5.8 bước 2) → mfg.allocations (R1 (b); G3).
4. Kết chuyển (TT99/TT200): Nợ 154 (cost_object, cost_element) / Có 621, 622, 623, 627 — 1 chứng từ
     'COST_TRANSFER' / kỳ / company, idempotent: chạy lại = void bản cũ + sinh bản mới.
   TT133: chi phí đã ở 154 ⇒ chỉ ghi lại phân bổ giữa các đối tượng (Nợ 154-đối tượng / Có 154-chung).
5. Đánh giá dở dang, tính giá thành, Nợ 155/Có 154 (§5.8); NVL thừa nhập lại (Nợ 152/Có 621), phế liệu thu hồi
   (Nợ 152/Có 154) là "giảm giá thành" — cột byproduct_deduction.
6. Kiểm tra G1–G5 (01 §8.3): số dư 621/622/623/627 = 0 sau kết chuyển và PS Nợ 627 = Σ phân bổ vào 154 + Σ chuyển 632;
   Σ DDCK theo đối tượng = số dư 154; Σ phân bổ = Σ pool; GT phiếu nhập TP = Z.
```

---

## 6. Truy xuất giá thành (traceability) — đồ thị dòng chi phí

### 6.1 Mô hình

Coi mọi đối tượng mang chi phí là **nút**; mỗi lần giá trị chảy từ nút này sang nút khác là **cạnh** có `amount` (và `qty`).

| Loại nút | Ví dụ | Lá (nguồn gốc)? |
|---|---|---|
| `IN_LAYER` / dòng nhập kho (`stock_ledger` nhập) | Lô NVL mua từ NCC X, HĐ số … | **Lá** nếu là mua/đầu kỳ |
| `OUT_LINE` dòng xuất kho | Xuất NVL cho lệnh SX | trung gian |
| `JOURNAL_LINE` chi phí | Lương NCTT (622), khấu hao (6274), điện (6277) | **Lá** |
| `COST_POOL` | Pool SXC chung phân xưởng 1 | trung gian |
| `COST_OBJECT_RUN` | Đối tượng THCP trong costing run | trung gian |
| `WIP_OPENING` / `WIP_CLOSING` | Dở dang đầu/cuối | lá kỳ này (có thể đi tiếp sang kỳ trước) |
| `PROD_RECEIPT` | Nhập kho TP lô L | đích |

```sql
CREATE TABLE cst.cost_flow_edges (
  tenant_id uuid NOT NULL, id bigint GENERATED ALWAYS AS IDENTITY,
  fiscal_year smallint NOT NULL,
  run_ref uuid NOT NULL,                 -- costing_run_id hoặc repost request id (để thay thế theo version)
  src_type text NOT NULL, src_id text NOT NULL,   -- id dạng text để chứa uuid/bigint
  dst_type text NOT NULL, dst_id text NOT NULL,
  cost_element mfg.cost_element,         -- domain chung §4.10 (giữ xuyên suốt)
  expense_item_id uuid,
  amount numeric(20,2) NOT NULL,
  qty numeric(20,6),
  is_active boolean NOT NULL DEFAULT true,
  PRIMARY KEY (tenant_id, id)
);   -- Giai đoạn 1: không partition (§4.11)
CREATE INDEX ON cst.cost_flow_edges (tenant_id, dst_type, dst_id) WHERE is_active;
CREATE INDEX ON cst.cost_flow_edges (tenant_id, src_type, src_id) WHERE is_active;
```

Cạnh được sinh bởi:
- Engine giá vốn: `layer_consumptions` ⇒ `IN_LAYER → OUT_LINE` (FIFO/đích danh: chính xác theo lô). Với BQ: cạnh `KEY_PERIOD_POOL → OUT_LINE` và `IN_LINE → KEY_PERIOD_POOL` (tỷ lệ, vì BQ trộn lẫn — truy xuất theo **tỷ trọng**, đây là giới hạn bản chất của phương pháp BQ và phải nói rõ cho người dùng).
- Xuất NVL cho SX: `OUT_LINE → COST_OBJECT_RUN` (element DM).
- Tập hợp CP: `JOURNAL_LINE → COST_POOL` hoặc `→ COST_OBJECT_RUN`.
- Phân bổ: `COST_POOL → COST_OBJECT_RUN` (mfg.allocations).
- Dở dang: `WIP_OPENING → COST_OBJECT_RUN`, `COST_OBJECT_RUN → WIP_CLOSING`.
- Kết quả: `COST_OBJECT_RUN → PROD_RECEIPT` (theo SP/lô).

Invariant (property test): với mọi nút trung gian, `Σ in = Σ out` (bảo toàn giá trị) theo từng element.

### 6.2 Truy ngược từ 1 lô thành phẩm

```sql
-- Bùng nổ (explode) chi phí của nhập kho TP (lô L) về các lá, nhân tỷ lệ dọc đường
WITH RECURSIVE trace AS (
  SELECT e.src_type, e.src_id, e.cost_element, e.amount::numeric AS amount,
         1 AS depth, ARRAY[e.dst_type||':'||e.dst_id] AS path
  FROM cst.cost_flow_edges e
  WHERE e.dst_type = 'PROD_RECEIPT' AND e.dst_id = $1 AND e.is_active
UNION ALL
  SELECT e.src_type, e.src_id, coalesce(e.cost_element, t.cost_element),
         t.amount * e.amount / o.total_out AS amount,   -- tỷ trọng phần giá trị nút trung gian chảy vào nhánh này
         t.depth + 1, t.path || (e.dst_type||':'||e.dst_id)
  FROM trace t
  JOIN cst.cost_flow_edges e ON e.dst_type = t.src_type AND e.dst_id = t.src_id AND e.is_active
  JOIN LATERAL (SELECT sum(amount) AS total_out FROM cst.cost_flow_edges x
                WHERE x.src_type = t.src_type AND x.src_id = t.src_id AND x.is_active) o ON true
  WHERE t.src_type NOT IN ('JOURNAL_LINE','IN_LAYER_PURCHASE','OPENING')   -- dừng ở lá
    AND t.depth < 30
    AND NOT (e.dst_type||':'||e.dst_id) = ANY(t.path)                      -- chống vòng
)
SELECT src_type, src_id, cost_element, sum(amount) AS contributed
FROM trace WHERE src_type IN ('JOURNAL_LINE','IN_LAYER_PURCHASE','OPENING','WIP_OPENING')
GROUP BY 1,2,3 ORDER BY contributed DESC;
```

Kết quả: “Lô TP L (100 sp, 52.300.000đ) = 31.2tr từ lô NVL A-0925 (NCC X, HĐ 0001234) + 8.1tr lương NCTT tháng 9 phân xưởng 1 + 4.5tr khấu hao máy M3 (phân bổ theo giờ máy) + …”. UI drill-down từ mỗi lá tới chứng từ gốc.

### 6.3 Vật chất hoá (materialize) để nhanh

Đệ quy trên đồ thị lớn mỗi lần mở báo cáo là đắt. Sau mỗi costing run, job `cst.flatten_trace(run_id)` tính sẵn:

```sql
CREATE TABLE cst.product_cost_trace (   -- "bảng giá thành có truy vết"
  tenant_id uuid NOT NULL, costing_run_id uuid NOT NULL,
  product_cost_sheet_id uuid NOT NULL, prod_receipt_ref text NOT NULL, lot_id uuid,
  leaf_type text NOT NULL, leaf_id text NOT NULL, cost_element mfg.cost_element NOT NULL,
  expense_item_id uuid, source_document_id uuid,
  amount numeric(20,2) NOT NULL,          -- đã làm tròn largest-remainder để Σ = total_cost của sheet
  PRIMARY KEY (tenant_id, costing_run_id, product_cost_sheet_id, leaf_type, leaf_id, cost_element)
);
```
Invariant: `Σ product_cost_trace.amount (theo sheet) = product_cost_sheets.total_cost`.
Đa kỳ (lô NVL tồn từ kỳ trước, dở dang đầu kỳ): lá `OPENING`/`WIP_OPENING` có liên kết sang trace kỳ trước — truy tiếp theo yêu cầu (lazy), không flatten toàn lịch sử.

---

## 7. Audit & tuân thủ

Căn cứ: TT99/2025 (phần mềm phải lưu vết sửa đổi), Luật Kế toán 2015 (lưu trữ chứng từ dùng ghi sổ & BCTC tối thiểu 10 năm), NĐ 174/2016 (lưu trữ tài liệu kế toán, có thể lưu bản điện tử), NĐ 123/2020 + NĐ 70/2025 (hoá đơn), TT 99/2025 & TT133 (chế độ kế toán). **[ĐỐI CHIẾU 01]**

### 7.1 Vòng đời chứng từ & bất biến

```
DRAFT ──ghi sổ──► POSTED ──bỏ ghi (kỳ mở, có quyền)──► DRAFT(version+1)   [MISA-like]
                    │
                    └──huỷ──► VOIDED   (giữ nguyên, số CT không tái sử dụng)
Kỳ đã khoá: không bỏ ghi/huỷ; chỉ lập chứng từ điều chỉnh ở kỳ mở.
```

- Ở trạng thái POSTED: trigger chặn UPDATE/DELETE trên `documents` (trừ chuyển trạng thái hợp lệ), `document_lines`, `journal_lines` (trừ cờ `is_active` do engine), `stock_moves`.
- **Bỏ ghi** không xoá: snapshot đầy đủ phiên bản đã ghi sổ vào `acc.document_versions(document_id, version, payload jsonb, row_hash)`; journal entries cũ `is_active=false`; stock ledger `is_cancelled=true`; sinh repost. Khi ghi sổ lại ⇒ version mới, bút toán mới. Báo cáo chỉ đọc `is_active`, nhưng *Nhật ký truy vết* xem được mọi phiên bản.
- Chế độ nghiêm ngặt (tuỳ chọn tenant/kiểm toán): cấm bỏ ghi, sửa = chứng từ đảo (reversal) + lập lại.

Guard trên **header** `acc.documents` (06b-D3) — đã chạy thử trên PG16:

```sql
CREATE FUNCTION acc.guard_documents() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  -- các cột được phép đổi trong từng chuyển trạng thái của chứng từ đã có số / đã ghi sổ
  c_unpost text[] := ARRAY['status','version','posted_at','posted_by','row_hash'];
  c_void   text[] := ARRAY['status','voided_at','voided_by','void_reason'];
BEGIN
  IF TG_OP = 'DELETE' THEN
    -- Chỉ xoá được nháp CHƯA TỪNG có số (06b-U5: chứng từ đã có số thì chỉ VOIDED, không xoá)
    IF OLD.status <> 'DRAFT' OR OLD.doc_no IS NOT NULL THEN
      RAISE EXCEPTION 'Không được xoá chứng từ % (trạng thái %, số %)', OLD.id, OLD.status, OLD.doc_no
        USING ERRCODE = '55000';
    END IF;
    RETURN OLD;
  END IF;

  -- UPDATE
  IF NEW.tenant_id <> OLD.tenant_id OR NEW.id <> OLD.id OR NEW.company_id <> OLD.company_id
     OR NEW.doc_type <> OLD.doc_type THEN
    RAISE EXCEPTION 'Không được đổi khoá/loại chứng từ' USING ERRCODE = '55000';
  END IF;

  IF OLD.status = 'DRAFT' THEN
    IF NEW.status = 'VOIDED' AND OLD.doc_no IS NULL THEN
      RAISE EXCEPTION 'Nháp chưa có số thì xoá, không huỷ' USING ERRCODE = '55000';
    END IF;
    -- Đã từng có số (sau bỏ ghi): giữ nguyên số và năm (đổi năm = huỷ và lập mới)
    IF OLD.doc_no IS NOT NULL AND (NEW.doc_no IS DISTINCT FROM OLD.doc_no
                                   OR NEW.fiscal_year <> OLD.fiscal_year) THEN
      RAISE EXCEPTION 'Chứng từ đã có số: không đổi số/năm tài chính' USING ERRCODE = '55000';
    END IF;
    IF NEW.status = 'POSTED' AND NEW.doc_no IS NULL THEN
      RAISE EXCEPTION 'Ghi sổ phải có số chứng từ' USING ERRCODE = '55000';
    END IF;
    RETURN NEW;                                   -- DRAFT→DRAFT (sửa nháp), DRAFT→POSTED, DRAFT(có số)→VOIDED
  ELSIF OLD.status = 'POSTED' THEN
    IF NEW.status = 'DRAFT' THEN                  -- bỏ ghi: version + 1, chỉ đổi cột trạng thái
      IF NEW.version <> OLD.version + 1
         OR (to_jsonb(NEW) - c_unpost) <> (to_jsonb(OLD) - c_unpost) THEN
        RAISE EXCEPTION 'Bỏ ghi chỉ được đổi trạng thái và tăng version' USING ERRCODE = '55000';
      END IF;
      RETURN NEW;
    ELSIF NEW.status = 'VOIDED' THEN              -- huỷ: chỉ đổi cột huỷ
      IF (to_jsonb(NEW) - c_void) <> (to_jsonb(OLD) - c_void) THEN
        RAISE EXCEPTION 'Huỷ chỉ được đổi trạng thái và thông tin huỷ' USING ERRCODE = '55000';
      END IF;
      RETURN NEW;
    END IF;
    RAISE EXCEPTION 'Chứng từ đã ghi sổ – không được sửa' USING ERRCODE = '55000';
  ELSE                                            -- VOIDED là trạng thái cuối
    RAISE EXCEPTION 'Chứng từ đã huỷ – không được sửa' USING ERRCODE = '55000';
  END IF;
END $$;
CREATE TRIGGER documents_guard BEFORE UPDATE OR DELETE ON acc.documents
  FOR EACH ROW EXECUTE FUNCTION acc.guard_documents();
```
(Kỳ đã khoá: bỏ ghi/huỷ bị chặn bởi trigger khoá kỳ gắn trên `acc.documents`, §7.2.)

Guard trên **dòng** `acc.document_lines` (06b-D4: chặn cả INSERT; dòng đổi `document_id` thì kiểm cả chứng từ cũ và mới) — đã chạy thử trên PG16:

```sql
CREATE FUNCTION acc.guard_posted_lines() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_tenant uuid := COALESCE(NEW.tenant_id, OLD.tenant_id);
  v_doc    uuid;
  v_status text;
BEGIN
  FOREACH v_doc IN ARRAY ARRAY[COALESCE(NEW.document_id, OLD.document_id), OLD.document_id] LOOP
    CONTINUE WHEN v_doc IS NULL;
    -- FOR SHARE: nếu đang có giao dịch ghi sổ giữ FOR UPDATE header thì chờ nó xong rồi đọc trạng thái mới
    SELECT d.status INTO v_status FROM acc.documents d
     WHERE d.tenant_id = v_tenant AND d.id = v_doc FOR SHARE;
    IF v_status IS DISTINCT FROM 'DRAFT' THEN
      RAISE EXCEPTION 'Chứng từ % đã ghi sổ/huỷ – không được thêm/sửa/xoá dòng', v_doc
        USING ERRCODE = '55000';
    END IF;
  END LOOP;
  RETURN COALESCE(NEW, OLD);
END $$;
CREATE TRIGGER document_lines_immutable BEFORE INSERT OR UPDATE OR DELETE ON acc.document_lines
  FOR EACH ROW EXECUTE FUNCTION acc.guard_posted_lines();
```
Cùng mẫu (đổi tên cột tham chiếu header) áp cho `inv.stock_moves`. Với `acc.journal_lines` thì guard khác: cấm INSERT vào entry không thuộc giao dịch ghi sổ hiện tại và chỉ cho UPDATE cột `is_active` — chưa viết DDL trong bản này.

### 7.2 Khoá kỳ

Khoá sổ **theo kỳ tháng**: `locked_through` luôn là ngày cuối một kỳ trong `acc.fiscal_periods` (khoá theo ngày giữa kỳ có thể bổ sung về sau). Chống race giữa "đang ghi sổ" và "đang khoá kỳ" (06b-U1) bằng khoá dòng xung đột: giao dịch ghi sổ đọc `period_locks … FOR SHARE`; thao tác khoá kỳ `UPDATE` cùng dòng ⇒ phải chờ mọi giao dịch ghi sổ đang chạy commit/rollback, và giao dịch ghi sổ đến sau phải chờ thao tác khoá xong rồi mới đọc được `locked_through` mới. Đã chạy thử trên PG16, kể cả hai phiên đồng thời: phiên khoá kỳ chờ đến khi giao dịch ghi sổ đang mở commit, sau đó chứng từ mới trong kỳ bị chặn. Chưa thử trên PG18.

```sql
-- Scope lấy từ trigger argument, hoặc 'ROW' = đọc cột lock_scope của chính dòng (journal_entries, documents) — 06b-U3
CREATE FUNCTION acc.guard_period_lock() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_scopes text[];
  v_row    jsonb;
  v_lock   date;
BEGIN
  -- kiểm cả hàng mới (INSERT/UPDATE) và hàng cũ (UPDATE dời ngày ra khỏi kỳ khoá, DELETE)
  FOREACH v_row IN ARRAY ARRAY[to_jsonb(NEW), to_jsonb(OLD)] LOOP
    CONTINUE WHEN v_row IS NULL;
    v_scopes := ARRAY['ALL',
                      CASE WHEN TG_ARGV[0] = 'ROW' THEN v_row->>'lock_scope' ELSE TG_ARGV[0] END];
    IF TG_TABLE_NAME = 'stock_ledger' AND TG_OP = 'UPDATE' THEN
      v_scopes := v_scopes || 'COSTING';          -- engine cập nhật giá trị ⇒ còn bị khoá COSTING
    END IF;
    FOR v_lock IN
      SELECT locked_through FROM acc.period_locks
       WHERE tenant_id = (v_row->>'tenant_id')::uuid AND company_id = (v_row->>'company_id')::uuid
         AND scope = ANY (v_scopes)
       FOR SHARE                                   -- xung đột với UPDATE của thao tác khoá kỳ
    LOOP
      IF (v_row->>'posting_date')::date <= v_lock THEN
        RAISE EXCEPTION 'Kỳ đã khoá sổ đến % (scope %)', v_lock, v_scopes USING ERRCODE = '55P04';
      END IF;
    END LOOP;
  END LOOP;
  RETURN COALESCE(NEW, OLD);
END $$;
CREATE TRIGGER doc_period_lock BEFORE INSERT OR UPDATE OR DELETE ON acc.documents
  FOR EACH ROW EXECUTE FUNCTION acc.guard_period_lock('ROW');      -- chặn ghi sổ/bỏ ghi/huỷ trong kỳ khoá
CREATE TRIGGER je_period_lock BEFORE INSERT OR UPDATE OR DELETE ON acc.journal_entries
  FOR EACH ROW EXECUTE FUNCTION acc.guard_period_lock('ROW');
CREATE TRIGGER sl_period_lock BEFORE INSERT OR UPDATE OR DELETE ON inv.stock_ledger
  FOR EACH ROW EXECUTE FUNCTION acc.guard_period_lock('INVENTORY');
-- journal_lines: dòng thuộc entry đã được kiểm qua je_period_lock (entry và dòng cùng posting_date, D8)

-- Thao tác khoá kỳ (một transaction, chạy trong bước LOCK của close orchestrator)
CREATE FUNCTION acc.lock_period(p_tenant uuid, p_company uuid, p_period uuid, p_scope text, p_user uuid)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_end date;
BEGIN
  -- một thao tác đóng/khoá kỳ tại một thời điểm cho mỗi công ty
  PERFORM pg_advisory_xact_lock(hashtextextended('close:' || p_tenant || ':' || p_company, 0));
  SELECT end_date INTO STRICT v_end FROM acc.fiscal_periods
   WHERE tenant_id = p_tenant AND company_id = p_company AND id = p_period;
  -- UPDATE lấy khoá dòng ⇒ chờ mọi giao dịch ghi sổ đang giữ FOR SHARE trên dòng này
  UPDATE acc.period_locks SET locked_through = v_end, locked_by = p_user, locked_at = now()
   WHERE tenant_id = p_tenant AND company_id = p_company AND scope = p_scope
     AND locked_through < v_end;
  IF NOT FOUND THEN RAISE EXCEPTION 'Kỳ đã khoá hoặc thiếu dòng period_locks' USING ERRCODE = '55000'; END IF;
  -- Từ đây (READ COMMITTED, câu lệnh mới ⇒ snapshot mới) thấy mọi giao dịch ghi sổ đã commit trước đó.
  -- Kiểm lại trong CÙNG transaction, lỗi thì rollback cả việc khoá:
  --   không còn repost QUEUED/RUNNING có điểm bắt đầu ≤ v_end; không còn dòng kho ≠ FINAL ≤ v_end;
  --   không tồn âm; kỳ trước đã khoá; bất biến I/K/G/B pass (gọi các hàm kiểm tương ứng).
END $$;
```
**Close orchestrator** (quy trình 13 bước của 01 §6, có phụ thuộc và cờ `dirty`):

```sql
CREATE TABLE acc.period_close_steps (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL, fiscal_period_id uuid NOT NULL,
  step_code text NOT NULL,   -- theo 01 §6 (bản đã đưa kiểm kê lên trước tính giá — 06a-L2):
                             -- 'DOCS_COMPLETE','FX_REVAL','PREPAID_DEPR_PAYROLL',
                             -- 'STOCKTAKE_LANDED_NEG_STOCK' (3: kiểm kê → phân bổ CP mua → kiểm tồn âm),
                             -- 'COST_ISSUE_PURCHASED','COLLECT_ALLOCATE_154','PRODUCT_COST','COST_ISSUE_FG',
                             -- 'INV_PROVISION' (8: dự phòng 2294),'VAT_OFFSET','CLOSE_911','INVARIANT_CHECK',
                             -- 'REPORTS','LOCK'
  step_no smallint NOT NULL, depends_on text[] NOT NULL,
  status text NOT NULL CHECK (status IN ('TODO','RUNNING','DONE','DIRTY','FAILED','SKIPPED')),
  run_ref uuid, input_hash bytea,         -- idempotent: cùng input_hash ⇒ không chạy lại
  finished_at timestamptz, finished_by uuid, result jsonb,   -- số liệu/cảnh báo của bước
  PRIMARY KEY (tenant_id, company_id, fiscal_period_id, step_code)
);
```

- Mỗi bước là 1 job BullMQ idempotent (chạy lại = void kết quả cũ cùng bước + sinh mới, trong 1 transaction).
- **Lan truyền dirty**: sự kiện `DocumentPosted/Unposted`, `ValuationChanged` trong kỳ N ⇒ đặt `DIRTY` cho bước bị ảnh hưởng *và mọi bước phụ thuộc* (vd sửa phiếu xuất NVL ⇒ 4→5→6→7→10→11 dirty), và cho kỳ N+1… nếu tồn đầu thay đổi (K6).
- Các bước 4–7 lặp theo cấp BOM được gộp trong một costing run (§5.6) nên không cần người dùng lặp tay.
- **Khoá (bước 13)** chỉ thành công khi: mọi bước DONE (không DIRTY), không còn repost QUEUED/RUNNING, không còn dòng kho ≠ FINAL, không tồn âm, các bất biến I/K/G/B pass. Khoá theo thứ tự thời gian (không khoá N+1 khi N chưa khoá); mở khoá cần quyền đặc biệt + lý do + log, và mở luôn các kỳ sau.
- BCTC in khi kỳ còn dirty ⇒ gắn watermark cảnh báo (B7).

### 7.3 Nhật ký thay đổi (audit log)

```sql
CREATE TABLE audit.change_log (
  tenant_id uuid NOT NULL, id bigint GENERATED ALWAYS AS IDENTITY,
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  user_id uuid, request_id text, ip inet,
  table_name text NOT NULL, row_pk jsonb NOT NULL,
  op char(1) NOT NULL,                       -- I/U/D
  old_data jsonb, new_data jsonb,            -- chỉ cột thay đổi với U
  action text,                               -- ngữ nghĩa: 'POST','UNPOST','VOID','LOCK_PERIOD'…
  xid xid8 NOT NULL DEFAULT pg_current_xact_id(),   -- để job niêm phong (sau GĐ1) biết dòng đã chắc chắn commit
  PRIMARY KEY (tenant_id, id)
);   -- Giai đoạn 1: không partition (§4.11); không hash chain
REVOKE UPDATE, DELETE, TRUNCATE ON audit.change_log FROM app_user;
```
- **Bắt buộc, không tắt được**: TT99 yêu cầu phần mềm kế toán ngăn sửa dữ liệu trái phép và lưu vết sửa đổi (01 §1.1); test CI kiểm mọi bảng nghiệp vụ/danh mục đều có trigger audit.
- Trigger generic `audit.log_change()` gắn vào bảng nghiệp vụ & danh mục; lấy `app.user_id`, `app.request_id` từ `current_setting`.
- **Hash chain: không làm trong Giai đoạn 1** (bản 0.1 gọi là P3; 06b-U2). Đường ghi sổ **không** lấy bất kỳ advisory lock nào theo tenant (khoá đó tuần tự hoá toàn tenant và gây deadlock với khoá cost key). Khi làm: hash **bất đồng bộ** — trigger chỉ INSERT log; job niêm phong theo tenant định kỳ nối chuỗi các dòng có `xid < pg_snapshot_xmin(pg_current_snapshot())` (chắc chắn đã kết thúc), theo thứ tự `id`, ghi `hash = sha256(prev_hash || jsonb chuẩn hoá của dòng)` vào bảng `audit.chain` riêng; neo hash cuối ngày ra object storage Object Lock. Trong Giai đoạn 1, chống sửa trái phép dựa vào: role DB không có quyền UPDATE/DELETE/TRUNCATE trên log, chứng từ bất biến (§7.1), `row_hash` trên chứng từ đã ghi sổ.
- Nhật ký truy cập (đăng nhập, xuất báo cáo, in chứng từ) ghi riêng `audit.access_log`.

### 7.4 Số chứng từ liên tục (không nhảy số)

- Số chỉ cấp **khi ghi sổ**, trong cùng transaction; nếu rollback ⇒ số không bị “đốt”.
- Không dùng `SEQUENCE` (có lỗ hổng khi rollback). Dùng bảng đếm + khoá dòng:

Đánh số **theo năm tài chính** (06b-D1, U4) — đã chạy thử trên PG16:

```sql
CREATE TABLE acc.document_sequences (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL,
  doc_type text NOT NULL, fiscal_year smallint NOT NULL,
  series text NOT NULL DEFAULT '',            -- '' = dãy chung công ty; mã chi nhánh nếu đánh số theo CN
  prefix_template text NOT NULL,              -- vd 'PN{YY}-' ⇒ 'PN26-00001'; cấu hình theo loại CT (MISA-like)
  next_no bigint NOT NULL DEFAULT 1, pad smallint NOT NULL DEFAULT 5,
  PRIMARY KEY (tenant_id, company_id, doc_type, fiscal_year, series)
);

-- Cấp số: tạo dòng nếu chưa có (đầu năm), tăng nếu đã có; luôn trả đúng 1 dòng.
INSERT INTO acc.document_sequences AS s
  (tenant_id, company_id, doc_type, fiscal_year, series, prefix_template, next_no)
VALUES ($1, $2, $3, $4, $5, $6, 2)             -- $6 = prefix_template của loại CT; số cấp ra = 1
ON CONFLICT (tenant_id, company_id, doc_type, fiscal_year, series)
DO UPDATE SET next_no = s.next_no + 1
RETURNING replace(s.prefix_template, '{YY}', lpad((s.fiscal_year % 100)::text, 2, '0'))
          || lpad((s.next_no - 1)::text, s.pad, '0') AS doc_no;
```
Unique `documents_no_uq` có `fiscal_year` (§4.4) nên kể cả khi tenant chọn tiền tố không chứa năm (`'PN'`), sang năm mới đánh lại từ 1 không trùng.
- Cấp số ở **bước cuối** của giao dịch ghi sổ (Phụ lục A, 06b-A16) ⇒ khoá dòng đếm chỉ giữ trong khoảng ngắn trước commit. Người dùng muốn số “ngay khi lập” (như MISA hiển thị số đề xuất) ⇒ hiển thị **số dự kiến**, số chính thức cấp lúc ghi sổ; cho phép người dùng nhập tay số (kiểm trùng), cấu hình được.
- Chứng từ VOIDED giữ số. Báo cáo “kiểm tra số chứng từ bị nhảy/trùng” là tính năng.
- Số hoá đơn điện tử do hệ thống HĐĐT/nhà cung cấp cấp, lưu riêng (`einvoice.invoices.invoice_no`, ký hiệu mẫu số).

### 7.5 Lưu trữ 10 năm

- Dữ liệu: khi đã partition theo năm (§4.11, chưa làm ở Giai đoạn 1): năm > N (cấu hình, vd 3) chuyển tablespace rẻ; năm > 10 + kết thúc nghĩa vụ ⇒ export (Parquet + JSON chứng từ + PDF/XML) có checksum, lưu object storage **Object Lock (WORM) 10 năm**, sau đó mới detach.
- Tệp: XML HĐĐT (bản gốc có chữ ký số), PDF chứng từ in, đính kèm ⇒ object storage, key theo `tenant/year/doc_id/…`, ghi `sha256` vào DB.
- Backup: PITR 30 ngày + snapshot hàng tháng giữ 12 tháng + bản năm giữ 10 năm; diễn tập khôi phục hàng quý.
- Xuất dữ liệu theo tenant (data portability): dump logical lọc `tenant_id` (một lý do nữa giữ `tenant_id` ở mọi bảng).

### 7.6 HĐĐT & thuế (tích hợp)

- Anti-corruption layer `EInvoiceProvider` (interface: `issue`, `adjust`, `replace`, `cancel`, `getStatus`, `downloadXml`) với adapter MISA meInvoice / Viettel / VNPT / BKAV… — chọn 1 nhà cung cấp cho bản dùng nội bộ.
- Luồng: chứng từ bán hàng POSTED → tạo `einvoice.invoices(DRAFT)` → job `einvoice.publish` (BullMQ, retry, idempotency key = invoice id) → lưu mã CQT, XML. Điều chỉnh/thay thế hoá đơn theo NĐ 123 + NĐ 70/2025 là nghiệp vụ riêng, không sửa chứng từ đã ghi sổ.
- Tờ khai thuế GTGT/TNDN: sinh XML theo định dạng HTKK/eTax từ view báo cáo; phiên bản mẫu tờ khai là dữ liệu cấu hình. **[ĐỐI CHIẾU 01, 04]**

---

## 8. Thứ tự kỹ thuật, rủi ro, kiểm thử

### 8.1 Thứ tự phụ thuộc kỹ thuật (không phải tiến độ)

**Phạm vi & tiến độ: xem `docs/KE-HOACH-DU-AN.md` v0.3 (nguồn duy nhất).** Bản 0.1 của tài liệu này có lộ trình Phase 0–3 kèm số tuần/tháng; phần đó đã bỏ (lỗi C2/C3) vì lệch kế hoạch. Mục này chỉ ghi khối kỹ thuật nào phải có trước khối nào, để kế hoạch xếp đợt phát hành:

1. **Nền móng**: monorepo, CI (lint, typecheck, Vitest, Testcontainers), dbmate, kysely-codegen; RLS helper + test tenant-leak (§2.1, có danh sách loại trừ); audit `change_log` (không hash chain); outbox + worker khung; xác thực, RBAC cơ bản; `domain-core` (Money/Qty/Decimal, **R1** và `largestRemainder` §1.4, Period); golden-test harness đọc YAML có khối `rounding` (§8.3).
2. **Danh mục & chế độ kế toán**: template TK (TT99, TT133, TT200 lịch sử), `company_chart_assignments` + `md.regime_at` (§2.3), account roles, VTHH (có `costing_method`, lô), ĐVT quy đổi, kho, đối tượng. Phụ thuộc 1.
3. **Chứng từ + posting engine**: guard trạng thái/dòng (§7.1), khoá kỳ (§7.2), số CT theo năm (§7.4), constraint trigger Nợ = Có (§4.5), bỏ ghi/version. Phụ thuộc 2.
4. **Sổ kho + engine giá**: stock ledger, khoá cost key (§5.1, Phụ lục A), kiểm âm theo `(item, kho, lô)` (§4.7), GL compose từ `value_change`, các phương pháp giá (đích danh theo lô là phương pháp khách hàng dùng), repost theo lô có checkpoint (§5.5). Phụ thuộc 3.
5. **Giá thành**: cost element (§4.10), tập hợp/phân bổ (§5.9), dở dang, phân bước có tính giá BTP (§5.8, ví dụ 01 §4.6), SCC/hệ tuyến tính (§5.6), truy vết (§6). Phụ thuộc 4.
6. **Đóng kỳ**: close orchestrator theo 01 §6 (kiểm kê trước tính giá), kết chuyển 911 theo chế độ, khoá kỳ tháng. Phụ thuộc 4, 5.
7. **Báo cáo**: sổ sách, N-X-T, thẻ kho, thẻ giá thành, BCTC theo chế độ, drill-down. Phụ thuộc 3–6.
8. **Sau Giai đoạn 1 (định hướng kỹ thuật, không cam kết)**: partition (§4.11), hash chain bất đồng bộ (§7.3), repost tăng dần tối ưu, SaaS hoá (onboarding, billing, cell/cluster, read replica), report designer, lưu trữ lạnh tự động.

### 8.2 Rủi ro kỹ thuật lớn nhất & giảm thiểu

| # | Rủi ro | Ảnh hưởng | Giảm thiểu |
|---|---|---|---|
| 1 | **Sai giá vốn/giá thành** (làm tròn, thứ tự giao dịch, backdated, vòng lặp) | Sai BCTC, mất niềm tin | Core thuần + golden test giáo trình + property test bảo toàn; so khớp song song với MISA trên dữ liệu thật 2–3 tháng trước khi bỏ MISA (*parallel run*); lưu “giải thích” (ma trận, layer) cho mỗi lần tính |
| 2 | **Hiệu năng repost** khi backdated sâu vào kỳ dài, nhiều lan truyền | Báo cáo trễ, khoá tranh chấp | Coalescing, chạy theo cost key song song, chỉ ghi dòng thay đổi, checkpoint theo lô, giới hạn độ sâu lan truyền, khuyến khích khoá sổ hàng tháng; benchmark 1 triệu dòng/kỳ trong CI nightly |
| 3 | **Rò rỉ dữ liệu giữa tenant** | Nghiêm trọng | FORCE RLS, `current_setting` không missing_ok, FK kép, test tenant-leak tự động cho mọi endpoint, role DB không bypass |
| 4 | **Toàn vẹn kế toán bị phá** (chứng từ có thẻ kho nhưng không có bút toán, Nợ≠Có) | Sai sổ | Posting đồng bộ trong 1 transaction; constraint trigger; job đối chiếu hàng đêm (kho 15x vs sổ cái, document vs journal), cảnh báo |
| 5 | **Thay đổi chế độ/quy định** (TT99 thay TT200, NĐ 70/2025, mẫu tờ khai) | Phải sửa code liên tục | Account roles, báo cáo dạng công thức cấu hình, mẫu tờ khai là dữ liệu có version |
| 6 | **Số học Decimal sai** do lẫn `number` | Lệch xu | ESLint rule, API dùng string, branded types `Money`, property test |
| 7 | **Phạm vi phình** (muốn bằng MISA ngay) | Trễ | Phạm vi chốt ở `KE-HOACH-DU-AN.md` v0.3; mỗi phân hệ có “definition of done” bằng báo cáo đối chiếu |
| 9 | **Quy định chưa ổn định** (TT99 mới áp dụng; dự thảo thay TT133; số hiệu mẫu sổ TT99 chưa xác minh — 01 §9) | Sửa mẫu/biểu nhiều lần | Mọi thứ phụ thuộc văn bản là dữ liệu có version; theo dõi văn bản như một backlog riêng |
| 8 | **Kysely/SQL nặng → khó bảo trì** | Chậm phát triển | Báo cáo phức tạp viết thành SQL function có test riêng (pgTAP hoặc Vitest gọi function), tài liệu hoá |

### 8.3 Chiến lược kiểm thử

**Kim tự tháp**
1. **Unit (core thuần, Vitest)** — engine giá, phân bổ, dở dang, posting rules, làm tròn. Nhanh, chiếm phần lớn.
2. **Golden tests** — ví dụ số từ giáo trình (Kế toán tài chính / Kế toán chi phí, NEU/UEH/HV Tài chính, sách tham khảo trong `03`) và từ tài liệu hướng dẫn MISA. Định dạng YAML:
   ```yaml
   # Ví dụ dùng chung 01 §3.2 – Vật tư A, kho K1, tháng 01; 1 bộ dữ liệu, 4 phương pháp, 4 kỳ vọng
   name: "VTA-K1-T01"
   rounding:       # BẮT BUỘC ở mọi ca (rà soát S4) — R1, §1.4; harness từ chối ca thiếu khối này
     mode: HALF_UP
     amount_scale: 0                      # tiền làm tròn đến đồng
     unit_cost_scale: 4                   # đơn giá 4 số lẻ, chỉ để hiển thị/so sánh
     issue_value: from_total              # R1 (c): round(SL × GT tồn / SL tồn), không nhân từ đơn giá đã làm tròn
     depletion: remainder_to_depleting_issue   # phiếu xuất làm tồn của nguồn về 0 nhận toàn bộ phần còn lại
     allocation: largest_remainder        # R1 (b); hoà theo (ngày, số CT, số dòng)
   opening: { qty: 100, value: 1_000_000, lot: OPEN }
   txns:
     - { id: N1, date: 2026-01-05, kind: PURCHASE,   qty: 200, value: 2_200_000, lot: N1 }   # thành tiền là gốc
     - { id: X1, date: 2026-01-10, kind: PROD_ISSUE, qty: 250 }
     - { id: N2, date: 2026-01-20, kind: PURCHASE,   qty: 100, value: 1_200_000, lot: N2 }
     - { id: X2, date: 2026-01-25, kind: PROD_ISSUE, qty: 100 }
   expect:
     PERIODIC_AVG: { unit_cost: "11000.0000", out: { X1: "2750000", X2: "1100000" }, closing: { qty: 50, value: "550000" } }
     MOVING_AVG:   { out: { X1: "2666667", X2: "1155555" }, closing: { qty: 50, value: "577778" } }
     FIFO:         { out: { X1: "2650000", X2: "1150000" }, closing: { qty: 50, value: "600000" } }
     SPECIFIC:     # đích danh theo lô (phương pháp khách hàng dùng); 01 §3.6
       pick: { X1: [ { lot: OPEN, qty: 100 }, { lot: N1, qty: 150 } ], X2: [ { lot: N2, qty: 100 } ] }
       out: { X1: "2650000", X2: "1200000" }
       closing: { qty: 50, value: "550000", lots: { N1: { qty: 50, value: "550000" } } }
     journals:     # BQ cuối kỳ, sau khi chốt — kỳ vọng theo ROLE + khoản mục, không hardcode số TK (rà soát S3)
       - { dr_role: PROD_MATERIAL_COST, cr_role: INVENTORY_MATERIAL, amount: "3850000",
           cost_object: required, cost_element: DM }
   regime_accounts:  # ánh xạ role → standard_code để kiểm thêm ở mức tích hợp; chạy ca này cho CẢ HAI chế độ
     TT99:  { PROD_MATERIAL_COST: "621", INVENTORY_MATERIAL: "152" }
     TT133: { PROD_MATERIAL_COST: "154", INVENTORY_MATERIAL: "152" }   # TT133 không có 621: Nợ 154 + khoản mục DM
   variants:       # cùng dữ liệu, thêm biến cố – kết quả phải bằng chạy-lại-từ-đầu
     - backdated: { id: N0, date: 2026-01-08, kind: PURCHASE, qty: 50, value: 500_000, posted_after: X2 }
     - provisional_then_final: true      # PERIODIC_AVG: X1 tạm = round(250 × 3.200.000 / 300) = 2.666.667 → chốt 2.750.000
   ```
   Ca phân bổ có phần dư thật (R1 (b)) — kiểm luật làm tròn, không chỉ kiểm số học:
   ```yaml
   name: "ALLOC-627-REMAINDER"
   rounding: { mode: HALF_UP, amount_scale: 0, allocation: largest_remainder }
   allocate:
     - { pool: "20000000", basis: { DH1: "18000000", DH2: "12000000" }, expect: { DH1: "12000000", DH2: "8000000" } }
     - { pool: "10000000", basis: { DH1: "1", DH2: "1", DH3: "1" },    # hoà phần lẻ ⇒ theo thứ tự ổn định
         expect: { DH1: "3333334", DH2: "3333333", DH3: "3333333" } }
   ```
   Bộ golden ban đầu lấy từ `01-nghiep-vu-ke-toan.md`: §3.2–3.7 (4 phương pháp giá xuất, kể cả đích danh), §3.8 (trả lại theo giá vốn dòng hoá đơn gốc; điều chỉnh giá nhập sau: giảm giá 1tr cho lô 200 kg đã xuất 150 → Có 152: 250.000, Có 632/154: 750.000; phân bổ CP mua 600.000 theo giá trị → A 400.000 / B 200.000), §4.2 (phân bổ 627 theo NCTT: **12.000.000 / 8.000.000**; ca có dư 10.000.000 chia 3 → 3.333.334 / 3.333.333 / 3.333.333 theo R1 (b); SXC dưới công suất 8tr/2tr → 632), §4.3–4.4 (dở dang, giản đơn/hệ số/tỷ lệ/phân bước/đơn hàng), **§4.6 (đích danh theo lô + phân bước có tính giá BTP, Z_TP 34.699.589, Nợ = Có 168.156.106)**; bổ sung từ giáo trình trong `03`; BCTC B01/B02 từ bộ số dư mẫu. Golden test chạy cả ở mức core và mức tích hợp (DB thật) ⇒ bảo đảm SQL và TS cho cùng kết quả.
3. **Property-based (fast-check)** — sinh ngẫu nhiên chuỗi giao dịch (kể cả backdated, huỷ, chuyển kho, trả lại):
   - *Cân bằng*: mọi journal entry Σ Nợ = Σ Có; tổng toàn sổ Σ Nợ = Σ Có.
   - *Kho khớp sổ cái*: với mỗi TK kho (152/153/155/156) và kỳ: `Σ value_after cuối kỳ theo cost key thuộc TK = số dư TK trên sổ cái`.
   - *Bảo toàn*: `opening + Σ in − Σ out = closing` (qty và value) cho mỗi key; `qty = 0 ⇒ value = 0`.
   - *Repost ≡ tính lại từ đầu*: kết quả sau chuỗi repost tăng dần **bằng** kết quả chạy engine từ đầu trên tập giao dịch cuối cùng (oracle). Đây là test quan trọng nhất cho backdated.
   - *Thứ tự nhập liệu không ảnh hưởng*: hoán vị thứ tự *nhập* các chứng từ (giữ nguyên posting ts) ⇒ cùng kết quả.
   - *Phân bổ*: Σ phần phân bổ = tổng pool; mỗi phần ≥ 0 khi basis ≥ 0.
   - *Truy vết*: Σ product_cost_trace theo sheet = total_cost; bảo toàn tại mọi nút trung gian của đồ thị.
   - *FIFO*: Σ consumption theo layer ≤ qty_in; không tiêu hao layer sinh sau thời điểm xuất.
   - **Ánh xạ bất biến 01 §8 → nơi kiểm** (mỗi bất biến có ≥ 1 test, và được kiểm lại trong checklist khoá sổ):

     | Bất biến | Cơ chế cưỡng chế | Test |
     |---|---|---|
     | I1 Σ Nợ = Σ Có / chứng từ | constraint trigger deferred (§4.5) | property + integration (cố ý lệch ⇒ COMMIT lỗi) |
     | I2 TK lá, đang hiệu lực trong chế độ | CHECK `is_postable` qua trigger; `valid_from/to` | unit posting rules |
     | I3 CĐSPS cân | hệ quả I1; truy vấn kiểm khi khoá | property |
     | I4 kỳ khoá | trigger `guard_period_lock` (+ engine không vượt khoá) | integration |
     | I5 không xoá chứng từ đã ghi sổ, có audit | trigger bất biến + `audit.change_log` | integration |
     | I6 TK bắt buộc chiều phân tích | `track_*` trên `md.accounts` → validate + trigger | unit + integration |
     | I7 số CT duy nhất theo loại × năm | unique index có `fiscal_year` + `document_sequences` theo năm (§7.4) | integration song song + ca sang năm mới |
     | K1, K2 kho = sổ cái 15x; 1 dòng kho ↔ 1 dòng bút toán | GL compose từ `value_change` (§4.7) | property |
     | K3 SL ≥ 0 / = 0 khi khoá | lũy kế vật lý theo `(item, kho, lô)` dưới khoá A1 (§4.7); checklist khoá | property + integration (2 giao dịch xuất đồng thời cùng lô) |
     | K4 SL = 0 ⇒ GT = 0 | quy tắc “xuất hết lấy hết” trong engine | property |
     | K5 GT ≥ 0, ĐG không bất thường | cảnh báo (không chặn) | property (GT ≥ 0 khi SL ≥ 0) |
     | K6 tồn đầu N+1 = tồn cuối N | ledger lũy kế liên tục (không reset theo kỳ) | property |
     | K7 chuyển kho Σ xuất = Σ nhập | `LINKED` valuation | property |
     | K8 FIFO Σ remaining = tồn | `cost_layers` | property |
     | K9 thẻ kho = sổ chi tiết | cùng nguồn `stock_ledger` | hệ quả cấu trúc |
     | G1–G5 giá thành | §5.9 bước 6 | golden + property |
     | B1–B7 cuối kỳ & báo cáo | close orchestrator (§7.2) | golden BCTC + integration |
4. **Integration (Testcontainers `postgres:18` + Redis)** — RLS/tenant leak, trigger bất biến, khoá kỳ, constraint trigger Nợ/Có (cố ý insert lệch ⇒ COMMIT phải lỗi), số chứng từ liên tục dưới tải song song (100 transaction đồng thời ⇒ dãy số liền, không trùng), repost đồng thời trên cùng key.
   - Tối ưu tốc độ: 1 container/worker Vitest, mỗi test dùng `TEMPLATE` database đã migrate sẵn (`CREATE DATABASE t_x TEMPLATE base`) ⇒ < 1s/test.
5. **E2E (Playwright)** — luồng chính: nhập mua → bán → tính giá → khoá sổ → BCTC; lưới nhập liệu bàn phím.
6. **Đối chiếu song song với MISA (UAT)** — nhập lại 2–3 tháng dữ liệu thật; so từng báo cáo (CĐPS, N-X-T, giá thành); chênh lệch phải giải thích được.
7. **Hiệu năng (nightly)** — dataset sinh: 50k mã hàng, 2 triệu dòng kho/năm, 5 triệu dòng sổ cái; ngưỡng: ghi sổ chứng từ 50 dòng < 300ms p95; repost 1 key 100k dòng < 30s; tính giá xuất kho cuối kỳ toàn công ty < 10 phút; B01 < 3s.

---

## Phụ lục A — Luồng ghi sổ 1 chứng từ (tóm tắt)

```ts
async function postDocument(ctx, docId) {
  return withTenantTx(ctx, async (tx) => {                       // READ COMMITTED
    const doc = await loadForUpdate(tx, docId);                  // SELECT … FOR UPDATE (header)
    assertStatus(doc, 'DRAFT'); validate(doc);                   // Zod + nghiệp vụ (TK theo dõi đối tượng…)
    await assertPeriodOpenForShare(tx, doc);                     // period_locks … FOR SHARE (§7.2); trigger cũng chặn
    const moves = stockEffects(doc);                             // nhập/xuất/chuyển (đã quy đổi ĐVT chính)

    // 06b-A1: khoá MỌI cost key và khoá tồn vật lý của chứng từ, theo thứ tự tăng dần ⇒ không deadlock.
    //   cost key  = 'ck:' tenant:item:scope[:lot nếu SPECIFIC]   (scope = warehouse hoặc company, §4.6)
    //   khoá vật lý = 'pk:' tenant:item:warehouse:lot            (cấp kiểm âm K3)
    const lockIds = uniq(moves.flatMap(m => [costKeyLockId(ctx.tenantId, m), physKeyLockId(ctx.tenantId, m)]))
                      .sort((a, b) => (a < b ? -1 : a > b ? 1 : 0));        // bigint từ hashtextextended(…, 0)
    for (const id of lockIds) await sql`select pg_advisory_xact_lock(${id})`.execute(tx);

    const lines = postingRules[doc.docType](doc, await roles(tx, doc));
    assertBalanced(lines);                                       // fail sớm
    await insertJournal(tx, doc, lines);                         // constraint trigger kiểm lúc COMMIT
    for (const m of moves) {
      if (m.direction < 0) await assertStockAvailable(tx, m);    // §4.7: theo (item, kho, lô), đọc SAU khi đã khoá
      const sle = await appendLedger(tx, m);                     // seq cấp SAU khoá ⇒ đơn điệu theo cost key
      const pending = await hasOpenRepost(tx, keyOf(sle));       // còn request QUEUED/RUNNING của key?
      if (isBackdated(sle) || needsValuation(sle) || pending)
        await enqueueRepost(tx, keyOf(sle), sortKeyOf(sle));     // upsert gộp §5.5 + outbox (jobId = request id)
      else await valueInline(tx, sle);                           // moving avg/đích danh, không backdated: tính ngay
    }
    // 06b-A16: cấp số ở bước CUỐI ⇒ khoá dòng document_sequences chỉ giữ rất ngắn trước commit
    doc.docNo ??= await nextDocNo(tx, doc);                      // §7.4, theo fiscal_year
    await markPosted(tx, doc, hashOf(doc, lines, moves));        // DRAFT→POSTED (guard §7.1 yêu cầu có doc_no)
    await outbox(tx, 'DocumentPosted', { docId, type: doc.docType });
  });
}
```
Ghi chú: thứ tự khoá trong một giao dịch ghi sổ là header chứng từ (FOR UPDATE) → `period_locks` (FOR SHARE) → advisory lock tăng dần → dòng `document_sequences`. Worker repost chỉ giữ một advisory lock cost key và không đụng header/sequence nên không tạo vòng chờ với thứ tự này. Đây là suy luận, chưa có test đồng thời.

## Phụ lục B — Câu hỏi mở cần chốt với nghiệp vụ

1. ~~Phương pháp tính giá mặc định~~ — **đã có câu trả lời**: thực tế đích danh theo lô (mã lót). Còn hỏi: có mặt hàng nào (vd phụ gia, bao bì nhỏ lẻ) dùng phương pháp khác không? Tính theo từng kho hay toàn công ty (3 kho: Nhà máy Bà Ba Thạo, Bình Tây, 97 Nguyễn Thái Học)?
2. Có cho phép xuất âm kho không? (Giá nhập hàng bán trả lại đã chốt mặc định: giá vốn dòng hoá đơn gốc — 01 §3.3.)
3. Sản xuất: **đã có câu trả lời** phân bước nhiều giai đoạn có tính giá BTP. Còn hỏi: BTP có nhập kho giữa các giai đoạn không? Đánh giá dở dang (công đoạn ủ nhiều kỳ) theo cách nào? Có BTP/tái chế tạo vòng không?
4. Cần sổ quản trị song song sổ tài chính ngay từ Giai đoạn 1 không?
5. Chính sách “bỏ ghi” (MISA cho phép) hay bắt buộc chứng từ đảo?
6. Nhà cung cấp HĐĐT hiện tại của công ty?
7. Chế độ kế toán áp dụng năm 2026: TT99 hay TT133? Cần chuyển dữ liệu lịch sử từ MISA mấy năm?
