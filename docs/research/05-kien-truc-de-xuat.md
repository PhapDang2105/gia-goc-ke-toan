# 05 — Kiến trúc đề xuất: Kế toán + Kho + Giá vốn + Giá thành (Web SaaS multi-tenant)

> Phiên bản: 0.1 (2026-10-04) · Trạng thái: đề xuất để review
> Phạm vi: phần mềm kế toán kiểu MISA cho doanh nghiệp Việt Nam (sản xuất + thương mại), Web SaaS multi-tenant, trước mắt dùng nội bộ.
> Stack đã chốt: **TypeScript + PostgreSQL**.
> Liên quan: `01..04` (nghiệp vụ, repo tham khảo, sách, phân tích MISA). Bản này đã tích hợp kết luận của `02-repo-tham-khao.md` và `04-phan-tich-misa.md` (xem §0.1); các chỗ đánh dấu **[ĐỐI CHIẾU 01/03]** cần rà lại với ví dụ số/quy định chi tiết.

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
| TT99 bỏ TK 611/631 (kê khai định kỳ) | 01 | **MVP chỉ hỗ trợ kê khai thường xuyên (KKTX)**; KKĐK không có trong mô hình dữ liệu MVP | §2.3 |
| TT99 cho DN tự đổi tên/số hiệu/kết cấu TK | 01 | Số hiệu TK, mẫu báo cáo, thuế suất = **dữ liệu cấu hình theo chế độ + ngày hiệu lực**; logic định khoản chỉ dùng **account role**; báo cáo map qua **mã TK chuẩn** (`standard_code`) chứ không qua `code` do DN đặt | §2.3 |
| TT99 yêu cầu phần mềm ngăn sửa trái phép, **lưu vết sửa đổi** | 01 | Audit log là **bắt buộc**, không tắt được | §7.3 |
| TT133 vẫn hiệu lực song song | 01 | Hai chế độ chạy song song ngay từ MVP (TT133: chi phí ghi thẳng 154) | §2.3, §5.9 |
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
- **Quy tắc phần dư làm tròn** (largest remainder): khi phân bổ tổng T cho n dòng, làm tròn từng dòng rồi dồn chênh lệch vào dòng có trọng số lớn nhất ⇒ tổng phân bổ luôn = T (invariant được property-test).

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
- **BullMQ** trên Redis/Valkey: queue `costing.repost`, `costing.period-close`, `mfg.cost-calc`, `report.export`, `einvoice.publish`. Job có `jobId` xác định (vd `repost:{tenant}:{item}:{wh}`) ⇒ chống trùng; dùng *BullMQ Flows* cho cha–con (tính giá cả kỳ → nhiều job item).
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

Kiểm thử bắt buộc: test “tenant leak” — tạo 2 tenant, chạy toàn bộ API của tenant A, assert không đọc/ghi được 1 dòng nào của B; test quét `pg_class` đảm bảo mọi bảng trong schema nghiệp vụ có `relforcerowsecurity = true` và có cột `tenant_id`.

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
     template_version_id uuid NOT NULL, valid_from date NOT NULL, valid_to date,
     PRIMARY KEY (tenant_id, company_id, valid_from)
   );
   ```
2. **`accounts`** (của company): copy từ template khi khởi tạo, tenant thêm TK chi tiết (cấp 2,3,4…). Vì TT99 cho DN **tự đổi tên, số hiệu, kết cấu TK**, mỗi TK của DN mang `standard_code` (mã TK chuẩn trong template, vd `156`) tách khỏi `code` hiển thị do DN đặt; BCTC, mẫu sổ và kiểm tra bất biến (K1: TK HTK…) luôn dựa trên `standard_code`/role, không dựa trên `code`. Đổi chế độ chỉ ở đầu năm tài chính (`company_chart_assignments`).
   - **Chỉ hỗ trợ KKTX** (kê khai thường xuyên) trong MVP: TT99 đã bỏ 611/631; TT133 còn 611 nhưng MVP không làm KKĐK — nếu cần, bổ sung ở P3 như một chế độ hạch toán kho riêng.
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
  accounting_regime text NOT NULL CHECK (accounting_regime IN ('TT200','TT133','TT99')),
  base_currency char(3) NOT NULL DEFAULT 'VND',
  amount_scale smallint NOT NULL DEFAULT 0,   -- số lẻ làm tròn tiền VND
  inventory_costing_method text NOT NULL      -- mặc định công ty, có thể ghi đè theo item
    CHECK (inventory_costing_method IN ('PERIODIC_AVG','MOVING_AVG','FIFO','SPECIFIC')),
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

-- Khoá sổ theo ngày (giống MISA "khoá sổ kỳ kế toán đến ngày"), có thể theo module
CREATE TABLE acc.period_locks (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL,
  scope text NOT NULL CHECK (scope IN ('ALL','INVENTORY','COSTING','CASH','TAX')),
  locked_through date NOT NULL,       -- mọi posting_date <= ngày này bị chặn
  locked_by uuid NOT NULL, locked_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, company_id, scope)
);
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
CREATE UNIQUE INDEX documents_no_uq ON acc.documents (tenant_id, company_id, doc_type, doc_no)
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
  FOREIGN KEY (tenant_id, document_id) REFERENCES acc.documents(tenant_id, id) ON DELETE CASCADE
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
  is_active boolean NOT NULL DEFAULT true,   -- false khi bị thay bằng phiên bản mới (repost/bỏ ghi)
  superseded_by uuid, valuation_version int, -- cho bút toán do Costing sinh
  PRIMARY KEY (tenant_id, id)
);

CREATE TABLE acc.journal_lines (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  entry_id uuid NOT NULL,
  company_id uuid NOT NULL, book_id uuid NOT NULL, branch_id uuid NOT NULL,
  posting_date date NOT NULL, fiscal_year smallint NOT NULL,  -- phi chuẩn hoá để partition & báo cáo
  account_id uuid NOT NULL,
  contra_account_id uuid,          -- TK đối ứng (sổ Nhật ký chung/S38 kiểu VN cần cặp đối ứng)
  debit  numeric(20,2) NOT NULL DEFAULT 0 CHECK (debit  >= 0),
  credit numeric(20,2) NOT NULL DEFAULT 0 CHECK (credit >= 0),
  CHECK ((debit = 0) <> (credit = 0)),     -- mỗi dòng đúng 1 bên
  currency char(3), amount_fc numeric(20,2), fx_rate numeric(18,6),
  partner_id uuid, item_id uuid, cost_object_id uuid, expense_item_id uuid,
  warehouse_id uuid, production_order_id uuid, document_line_id uuid,
  is_active boolean NOT NULL DEFAULT true,
  PRIMARY KEY (tenant_id, fiscal_year, id)
) PARTITION BY LIST (fiscal_year);
-- partition mỗi năm: acc.journal_lines_2026 ... (tạo trước 2 năm bằng job)
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
  costing_method text,                -- NULL = theo công ty
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
  kind_rank smallint NOT NULL,           -- thứ tự loại trong ngày: 1 nhập, 2 chuyển, 3 xuất (01 §8.5)
  seq bigint NOT NULL,                   -- thứ tự ghi sổ (sequence) – phá hoà cuối cùng
  fiscal_year smallint NOT NULL,
  qty_change numeric(20,6) NOT NULL,     -- +/- 
  incoming_rate numeric(24,8),           -- cho dòng nhập
  valuation_rate numeric(24,8),          -- giá đơn vị BQ/sau dòng này (moving avg)
  value_change numeric(20,2),            -- +/- giá trị (≈ stock_value_difference của ERPNext) – NGUỒN của bút toán 15x
  valuation_status text NOT NULL DEFAULT 'PROVISIONAL'
    CHECK (valuation_status IN ('PENDING','PROVISIONAL','FINAL')),
                                         -- PENDING: chưa có giá (TP chờ giá thành); PROVISIONAL: giá tạm
                                         -- (BQ tức thời tạm trong kỳ BQ cuối kỳ / xuất âm); FINAL: đã chốt
  qty_after numeric(20,6) NOT NULL,      -- tồn lũy kế theo cost key
  value_after numeric(20,2),
  valuation_version int NOT NULL DEFAULT 1,
  is_cancelled boolean NOT NULL DEFAULT false,
  PRIMARY KEY (tenant_id, fiscal_year, id)
) PARTITION BY LIST (fiscal_year);

-- Truy vấn "tồn tại thời điểm T" và repost từ T: index theo thứ tự thời gian của cost key
CREATE INDEX sle_key_time ON inv.stock_ledger
  (tenant_id, item_id, cost_key_scope, posting_date, posting_time, kind_rank, seq)
  INCLUDE (qty_after, value_after, valuation_rate) WHERE NOT is_cancelled;
CREATE INDEX sle_not_final ON inv.stock_ledger (tenant_id, company_id, posting_date)
  WHERE valuation_status <> 'FINAL' AND NOT is_cancelled;   -- "còn gì chưa chốt giá?" khi khoá sổ
CREATE INDEX ON inv.stock_ledger (tenant_id, stock_move_id);
CREATE INDEX ON inv.stock_ledger (tenant_id, lot_id) WHERE lot_id IS NOT NULL;
```

“Append-only” ở đây nghĩa là: **dòng không bao giờ bị xoá vật lý**; huỷ chứng từ ⇒ `is_cancelled = true` (+ audit); các cột *dẫn xuất* (`valuation_rate`, `value_change`, `qty_after`, `value_after`, `valuation_version`) chỉ được engine giá vốn cập nhật (trigger chặn mọi UPDATE khác, kiểm `current_setting('app.engine')='costing'`). Đây đúng là mô hình *Stock Ledger Entry* của ERPNext — đổi lại thay vì xoá/ghi lại SLE như ERPNext, ta cập nhật tại chỗ có version, vì sổ kho VN cần giữ id ổn định cho truy xuất.

**GL suy ra từ sổ kho (học ERPNext `BaseStockGLComposer`)**: bút toán phần kho của mọi chứng từ kho (Nợ/Có 15x, đối ứng 632/621/627/154/641/642…) **không** tính độc lập mà được *compose* từ `Σ value_change` các dòng `stock_ledger` của từng dòng chứng từ: `value_change > 0` ⇒ Nợ TK kho / Có TK đối ứng của dòng; `< 0` ⇒ ngược lại; chuyển kho dùng TK kho của kho đích. Mỗi khi engine đổi `value_change` (repost/chốt cuối kỳ), composer sinh lại bút toán `source='COSTING'` của chứng từ đó. ⇒ Bất biến K1/K2 (kho = sổ cái 15x; mỗi dòng kho ↔ đúng 1 dòng bút toán) đúng *theo cấu trúc*, không phải nhờ đối chiếu.

**Giá tạm và trạng thái chốt (sửa điểm đau của MISA)**: MISA để phiếu xuất BQ cuối kỳ *không có giá* tới khi chạy batch, rồi ghi đè; người dùng thấy tồn âm giá trị giữa kỳ và không biết số nào đã “chắc”. Ở đây:
- Với BQ cuối kỳ, khi ghi sổ phiếu xuất, engine gán ngay **giá tạm = BQ tức thời** tại thời điểm đó (`valuation_status='PROVISIONAL'`) ⇒ báo cáo giữa kỳ có số hợp lý, không âm giá trị.
- “Tính giá xuất kho cuối kỳ” chuyển các dòng của kỳ sang `FINAL` (giá BQ kỳ), sinh lại bút toán; UI/báo cáo luôn hiển thị nhãn **Tạm tính / Đã chốt** và tổng chênh lệch tạm→chốt.
- Phiếu nhập TP chưa có giá thành ⇒ `PENDING` (giá trị = 0 hoặc giá kế hoạch nếu cấu hình), chuyển `FINAL` khi tính giá thành.
- **Cảnh báo tồn âm**: khi ghi sổ (kể cả backdated) kiểm `min(qty_after)` từ thời điểm T trở đi; tồn âm (khi được phép) ⇒ dòng `PROVISIONAL` + cảnh báo trên màn hình + báo cáo “VTHH tồn âm”; **không cho khoá kỳ** khi còn tồn âm hoặc còn dòng ≠ FINAL trong kỳ (01 §3.8, K3).

Bảng tồn hiện thời (cache, đọc nhanh, khoá khi xuất để chống âm kho):

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
  cost_element text NOT NULL CHECK (cost_element IN ('DM','DL','MOH')), -- NVLTT(621), NCTT(622), SXC(627)
  expense_item_id uuid,                 -- khoản mục chi tiết (6271, 6272, … hoặc mã khoản mục)
  cost_object_id uuid,                  -- NULL = chi phí chung chờ phân bổ
  amount numeric(20,2) NOT NULL,
  PRIMARY KEY (tenant_id, id)
);

CREATE TABLE mfg.allocation_rules (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  cost_element text NOT NULL, expense_item_id uuid,  -- NULL = mọi khoản mục của element
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
  cost_element text NOT NULL,
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
  cost_element text NOT NULL,
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

- **Partition theo `fiscal_year` (LIST)** cho bảng tăng nhanh: `journal_lines`, `stock_ledger`, `audit.change_log` (theo tháng, RANGE), `cst.cost_flow_edges`. Lợi ích: báo cáo năm chỉ quét 1 partition; lưu trữ 10 năm: partition cũ chuyển sang tablespace rẻ / detach + export Parquet sang cold storage nhưng vẫn attach được để tra cứu.
- PK/Index luôn bắt đầu bằng `tenant_id` (RLS + locality). Khi một tenant cực lớn → chuyển sang cell riêng chứ không hash-partition theo tenant (đơn giản vận hành).
- Index partial `WHERE is_active` / `WHERE NOT is_cancelled` / `WHERE qty_remaining > 0`.
- BRIN trên `posting_date` cho bảng append theo thời gian.
- Không dùng FK từ bảng partitioned lớn sang bảng lớn khác nếu ảnh hưởng ghi (journal_lines → document_lines chỉ giữ id, kiểm bằng test toàn vẹn định kỳ); FK tới danh mục giữ lại.
- `autovacuum` tinh chỉnh cho `stock_ledger` (UPDATE dẫn xuất khi repost tạo bloat): `fillfactor=80` để HOT update.

---

## 5. Engine giá vốn

### 5.1 Nguyên tắc

1. **Thuần (pure core)**: thuật toán tính giá trong `packages/costing/core` là hàm thuần nhận chuỗi giao dịch đã sắp xếp + trạng thái đầu → trả giá trị từng dòng + trạng thái cuối. Không IO ⇒ golden test & property test dễ.
2. **Đơn vị xử lý = cost key** `(company, item, scope)`. Các cost key độc lập được chạy **song song**; phụ thuộc giữa các key (chuyển kho, sản xuất, trả lại) được xử lý qua **đồ thị phụ thuộc** (§5.5–5.6).
3. **Thứ tự chuẩn** của giao dịch: `(posting_date, posting_time, kind_rank, seq)` — trong cùng ngày **nhập < chuyển < xuất**, sau đó theo thứ tự ghi sổ (01 §8.5); seq cấp từ sequence khi ghi sổ ⇒ xác định & ổn định khi tính lại. (Mặc định `posting_time = 00:00` như MISA, nên `kind_rank` thực sự quyết định.)
4. **Idempotent**: chạy lại engine với cùng dữ liệu vào cho cùng kết quả; mỗi lần ghi kết quả tăng `valuation_version`, chỉ ghi khi giá trị khác (so sánh trước khi UPDATE ⇒ giảm bloat & sự kiện thừa).
5. **Khoá**: `pg_advisory_xact_lock(hashtextextended(tenant||item||scope, 0))` khi repost 1 key ⇒ không 2 worker cùng sửa 1 key.
6. **Không vượt kỳ đã khoá**: repost không bao giờ sửa dòng có `posting_date <= locked_through(COSTING)`; nếu cần ⇒ lỗi nghiệp vụ, yêu cầu mở khoá.

### 5.2 Bình quân gia quyền tức thời (moving average)

```
state = (qty, value)   // trạng thái ngay trước điểm bắt đầu repost (đọc qty_after/value_after của dòng trước)
for each sle in ledger(key) order by (date, time, seq) from T:
  if sle.qty_change > 0:                              // nhập
     inValue = sle.valuation_source == 'GIVEN'  ? round(sle.qty * incoming_rate)
             : sle.valuation_source == 'LINKED' ? valueOf(linked_out_move)   // chuyển kho/trả lại
             : sle.valuation_source == 'ENGINE' ? costFromProduction(sle)    // nhập TP
     state.qty += q; state.value += inValue
     rate = state.qty > 0 ? state.value / state.qty : inRate
  else:                                               // xuất
     q = -sle.qty_change
     if state.qty <= 0 or q > state.qty: handleNegativeStock()   // xem 5.7
     outValue = (q == state.qty) ? state.value                     // xuất hết → lấy hết giá trị, không để dư lẻ
                                 : round(q * state.value / state.qty)
     state.qty -= q; state.value -= outValue
  write(sle, value_change, qty_after=state.qty, value_after=state.value, valuation_rate=rate)
```

Điểm quan trọng: dùng `value/qty` tại thời điểm xuất (không dùng rate đã làm tròn) và quy tắc “xuất hết thì lấy hết giá trị” ⇒ không bao giờ có tồn 0 mà giá trị ≠ 0.

### 5.3 Bình quân gia quyền cuối kỳ (periodic average) — mặc định của nhiều DN VN

Trong kỳ, dòng xuất mang **giá tạm** = BQ tức thời tại thời điểm xuất (`valuation_status='PROVISIONAL'`, xem §4.7) — khác MISA (để trống rồi ghi đè), giúp báo cáo giữa kỳ không âm giá trị. Cuối kỳ chạy “Tính giá xuất kho” để **chốt** (`FINAL`):

```
unit_cost(key, period) = (opening_value + Σ inbound_value) / (opening_qty + Σ inbound_qty)
```
– inbound gồm mua, nhập TP (từ giá thành), nhập chuyển kho (= giá xuất của kho nguồn), điều chỉnh giá trị nhập (SL = 0). Nhập trả lại: theo cấu hình (a) loại khỏi mẫu số và gán giá = ĐG BQ kỳ (mặc định MISA với hàng trả lại không có giá), hoặc (b) giá xuất gốc/giá nhập tay và tham gia bình quân (01 §3.3).
– Sau khi có `unit_cost`, mọi dòng xuất trong kỳ = `round(q × unit_cost)`; **dòng xuất cuối cùng (hoặc bút toán chênh lệch) nhận phần dư** sao cho `closing_value = opening + in − out` khớp và `closing_qty = 0 ⇒ closing_value = 0`.

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
                 take = min(q, remaining); value = (take == remaining) ? value_remaining : round(take × unit_cost)
                 ghi layer_consumptions; q −= take; lặp
       trả lại hàng bán (RETURN_IN linked) → tạo layer với giá = giá của dòng xuất gốc
  4. Cập nhật qty_after/value_after cho từng sle.
Đích danh = FIFO giới hạn theo lot/serial chỉ định trên dòng xuất (layer = lô).
```

### 5.5 Repost khi có chứng từ backdated (học từ ERPNext *Repost Item Valuation* & Odoo 19 `_correct_inventory_valuation(from_date)`)

Ghi chú nguồn (02): ERPNext repost bất đồng bộ có checkpoint/resume, khử trùng lặp, chặn trước kỳ khoá — ta lấy nguyên các ý này. Odoo 17/18 (SVL) **không** hỗ trợ backdate; Odoo 19 bỏ SVL, giá trị nằm trên `stock.move` và có replay từ ngày sớm nhất bị ảnh hưởng — trùng hướng thiết kế ở đây. Khác ERPNext: không lưu FIFO queue JSON trên từng dòng mà dùng `cost_layers` + `valuation_snapshots` (§4.8).

Sự kiện gây repost: ghi sổ/bỏ ghi chứng từ kho có `posting_ts` < ts dòng cuối của key; sửa giá nhập (chi phí mua phân bổ về sau, hoá đơn NCC đến muộn ⇒ landed cost); thay đổi giá thành TP; chuyển kho từ key đã thay đổi.

```sql
CREATE TABLE cst.repost_requests (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, item_id uuid NOT NULL, cost_key_scope uuid NOT NULL,
  from_date date NOT NULL, from_time time NOT NULL, from_seq bigint NOT NULL,
  status text NOT NULL DEFAULT 'QUEUED' CHECK (status IN ('QUEUED','RUNNING','DONE','FAILED')),
  cause jsonb, attempts int NOT NULL DEFAULT 0, error text,
  PRIMARY KEY (tenant_id, id)
);
-- Gộp: chỉ 1 request QUEUED / key; request mới thì lùi from_ts về min
CREATE UNIQUE INDEX repost_one_queued ON cst.repost_requests (tenant_id, item_id, cost_key_scope)
  WHERE status = 'QUEUED';
```

```sql
-- Upsert gộp (trong transaction ghi sổ)
INSERT INTO cst.repost_requests (tenant_id, company_id, item_id, cost_key_scope, from_date, from_time, from_seq, cause)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
ON CONFLICT (tenant_id, item_id, cost_key_scope) WHERE status = 'QUEUED'
DO UPDATE SET (from_date, from_time, from_seq) =
  (SELECT * FROM (VALUES (EXCLUDED.from_date, EXCLUDED.from_time, EXCLUDED.from_seq),
                         (cst.repost_requests.from_date, cst.repost_requests.from_time, cst.repost_requests.from_seq)) v(d,t,s)
   ORDER BY d, t, s LIMIT 1);
```

Worker (pseudo-code TS):

```ts
async function processRepost(req: RepostRequest) {
  await withTenantTx(sys(req.tenantId), async (tx) => {
    await advisoryLock(tx, costKey(req));
    await markRunning(tx, req);                         // QUEUED → RUNNING (request mới sẽ tạo QUEUED khác)
    assertNotLocked(tx, req.companyId, req.fromDate);   // khoá sổ COSTING

    const method = await costingMethodOf(tx, req.itemId);
    if (method === 'PERIODIC_AVG') {                    // tính lại giá TẠM (moving avg) + đánh dấu kỳ dirty;
      await markPeriodDirty(tx, req);                   // dòng của kỳ đã FINAL quay về PROVISIONAL
    }                                                   // (rồi chạy tiếp như moving avg cho giá tạm)
    const start = await stateBefore(tx, req);          // snapshot gần nhất trước from_ts + replay đoạn ngắn
    const rows  = await ledgerFrom(tx, req);           // stream theo lô 5k dòng nếu lớn
    const result = runEngine(method, start, rows, resolvers(tx));   // core thuần
    const changed = diff(rows, result);                // chỉ dòng có giá trị thay đổi
    await writeValuation(tx, changed);                 // bump valuation_version
    await regenerateCogsJournal(tx, changed);          // bút toán source='COSTING' của chứng từ bị ảnh hưởng:
                                                       //  is_active=false bản cũ, insert bản mới (vẫn cân Nợ/Có)
    // Lan truyền: dòng xuất đổi giá trị mà có "người nhận" ⇒ repost key nhận
    for (const d of downstream(changed))               // TRANSFER_OUT→TRANSFER_IN, PROD_ISSUE→WIP/giá thành, SALE→RETURN_IN
      await enqueueRepost(tx, d.key, d.fromTs, { cause: 'propagation', from: req.id });
    await outbox(tx, 'ValuationChanged', { key: costKey(req), from: req.fromTs });
    await done(tx, req);
  });
}
```

Đặc tính:
- **Gộp (coalescing)**: 50 chứng từ backdated vào cùng key ⇒ 1 lần repost từ ts sớm nhất.
- **Song song**: BullMQ job id = cost key; concurrency N; advisory lock bảo vệ thêm.
- **Lan truyền & chu trình**: lan truyền theo cạnh; nếu đồ thị có chu trình (A→B→A chuyển qua lại) thì vì mỗi lần lan truyền đi *tới tương lai* (ts nhận ≥ ts gửi) và có điểm dừng “không đổi giá trị ⇒ không lan truyền” nên hội tụ; thêm giới hạn `maxPropagationDepth` + cảnh báo.
- **Kỳ lớn**: dữ liệu > 100k dòng/key ⇒ xử lý theo lô, commit theo checkpoint (lưu `state` sau mỗi lô vào request: `checkpoint_seq`, `checkpoint_state jsonb`) để resume khi crash — như `current_index`/`reposting_data_file` của ERPNext.
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
   - n nhỏ (≤ 200): giải đúng bằng khử Gauss với Decimal (độ chính xác 40) → c.
   - n lớn: Gauss–Seidel lặp: c_k ← (V_k^0 + P_k + Σ a_kj c_j + M_k(c)) / Q_k cho tới khi max|Δc| < 1e-8;
     hội tụ đảm bảo khi ma trận chéo trội (Q_k > Σ_j a_kj, luôn đúng nếu k có tồn đầu hoặc nhập ngoài > 0).
   - Không hội tụ / suy biến (Q_k = 0 hoặc toàn bộ nguồn của SCC chỉ là nội bộ) ⇒ báo lỗi nghiệp vụ,
     cho phép người dùng nhập giá thủ công (giống MISA cảnh báo "không tính được giá").
4. Sau khi có c: định giá dòng xuất, tính giá thành, ghi giá nhập TP, phân bổ phần dư làm tròn, sinh bút toán.
5. Lưu ma trận/vector vào costing_run (jsonb nén) để audit "vì sao giá ra như vậy".
```

Pseudo-code điều phối cuối kỳ:

```ts
async function periodClose(companyId, period) {
  const keys = await dirtyKeys(companyId, period);             // + mọi key có phát sinh
  const g = buildDependencyGraph(keys, transfers, prodIssues, prodReceipts, bomCostObjects);
  for (const scc of topoSort(tarjan(g))) {
    const sys = assembleLinearSystem(scc, solvedCosts);        // dùng c đã giải của SCC phía trước làm hằng số
    const c = scc.size === 1 ? solveSingle(sys) : solve(sys);  // Gauss (Decimal) hoặc Gauss–Seidel
    solvedCosts.set(scc, c);
    if (scc.hasProductionNodes) computeProductCost(scc, c);     // §5.8
  }
  await persistValuation(solvedCosts);                         // ledger, cost sheets, journals — 1 transaction/SCC
}
```

### 5.7 Âm kho, trả lại, chi phí mua về sau

- **Âm kho**: cấu hình tenant `allow_negative_stock`. Nếu cho phép: dòng xuất khi tồn ≤ 0 lấy giá = giá gần nhất (last valuation rate) ⇒ khi có nhập sau, sinh **dòng điều chỉnh chênh lệch** (giống Odoo “negative stock correction”) gắn vào dòng nhập. Nếu không cho phép: chặn tại ghi sổ bằng `SELECT … FOR UPDATE` trên `stock_balances` **và** kiểm tồn tại *thời điểm backdated*: tồn tối thiểu từ T trở đi phải ≥ q (truy vấn `min(qty_after)` trên ledger từ T).
- **Hàng bán trả lại**: nhập lại theo giá xuất gốc (LINKED) — repost dòng bán gốc ⇒ lan truyền.
- **Chi phí mua / hoá đơn đến sau** (landed cost, giảm giá hàng mua): tăng/giảm giá trị dòng nhập gốc nếu hàng còn tồn; phần đã xuất phân bổ vào 632 (cấu hình) — engine xử lý tự nhiên qua repost từ ts dòng nhập.

### 5.8 Tính giá thành (manufacturing costing run)

```
Input kỳ: chi phí tập hợp (journal_lines TK 621/622/627 hoặc 154 chi tiết theo cost_object & expense_item),
          NVL xuất cho SX (giá từ engine, có thể là ẩn c của SCC), sản lượng hoàn thành, dở dang SL & % hoàn thành.
1. Tập hợp: cost_pools ← SUM journal theo (element, expense_item, cost_object); không có cost_object ⇒ pool chung.
2. Phân bổ chi phí chung: với mỗi pool chung và rule hợp lệ:
     basis_k = đại lượng theo basis cho đối tượng k (NVLTT thực tế, định mức NVL, giờ công, SL quy đổi theo hệ số…)
     amount_k = largestRemainder(pool.amount, basis_k)         // Σ amount_k == pool.amount (invariant)
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
                   tính bước 1 → cập nhật giá nhập BTP → giá xuất BTP sang bước 2 → … trong cùng vòng lặp §5.6
     JOB_ORDER   : tổng theo lệnh SX; DD = toàn bộ CP lệnh chưa xong
6. Ghi product_cost_sheets; cập nhật incoming_rate cho stock moves PROD_RECEIPT (valuation_source='ENGINE');
   sinh bút toán Nợ 155/Có 154 (và kết chuyển 621/622/627 → 154 theo TT200/TT99, hoặc trực tiếp 154 theo TT133).
```

**BOM đa cấp** (MISA chỉ 1 cấp): `bom_lines.component_id` có thể là BTP có BOM riêng; `md.items.low_level_code` tính lại mỗi khi BOM đổi (BFS từ TP xuống, LLC = độ sâu lớn nhất); phát hiện BOM vòng ⇒ chặn lưu trừ khi dòng được đánh dấu `is_recycle` (tái chế/thu hồi) — trường hợp đó được giải bằng SCC ở §5.6. MVP chỉ cần BOM 1 cấp ở UI nhưng **mô hình dữ liệu và engine đa cấp ngay từ đầu**.

Tất cả công thức nằm trong core thuần; số liệu kiểm bằng ví dụ giáo trình (§8.3). **[ĐỐI CHIẾU 01 §4, 03: ví dụ số các phương pháp]**

### 5.9 Tập hợp & phân bổ 621/622/627 → 154 (tự thiết kế, theo mô hình cost element)

Không repo tham khảo nào có sẵn (02). Mô hình lấy ý tưởng *cost element* của iDempiere (Material/Labor/Overhead) và ánh xạ sang kế toán VN:

```sql
-- Ánh xạ TK chi phí (theo standard_code/role) → yếu tố chi phí; cấu hình theo chế độ
CREATE TABLE mfg.cost_element_map (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL,
  account_id uuid NOT NULL,                -- 621x, 622x, 623x, 627x (TT99/TT200) hoặc 154 chi tiết (TT133)
  expense_item_id uuid,                    -- khoản mục CP (bắt buộc với TT133 vì mọi thứ dồn vào 154)
  cost_element text NOT NULL CHECK (cost_element IN ('DM','DL','MC','MOH')),  -- MC = máy thi công 623
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
3. Phân bổ pool chung theo allocation_rules (§5.8 bước 2) → mfg.allocations (largest-remainder; G3).
4. Kết chuyển (TT99/TT200): Nợ 154 (cost_object, cost_element) / Có 621, 622, 623, 627 — 1 chứng từ
     'COST_TRANSFER' / kỳ / company, idempotent: chạy lại = void bản cũ + sinh bản mới.
   TT133: chi phí đã ở 154 ⇒ chỉ ghi lại phân bổ giữa các đối tượng (Nợ 154-đối tượng / Có 154-chung).
5. Đánh giá dở dang, tính giá thành, Nợ 155/Có 154 (§5.8); NVL thừa nhập lại (Nợ 152/Có 621), phế liệu thu hồi
   (Nợ 152/Có 154) là "giảm giá thành" — cột byproduct_deduction.
6. Kiểm tra G1–G5: số dư 621/622/623/627 = 0 sau kết chuyển (trừ phần đã sang 632);
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
  cost_element text,                     -- DM/DL/MOH (giữ xuyên suốt)
  expense_item_id uuid,
  amount numeric(20,2) NOT NULL,
  qty numeric(20,6),
  is_active boolean NOT NULL DEFAULT true,
  PRIMARY KEY (tenant_id, fiscal_year, id)
) PARTITION BY LIST (fiscal_year);
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
  leaf_type text NOT NULL, leaf_id text NOT NULL, cost_element text NOT NULL,
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

```sql
CREATE FUNCTION acc.guard_posted_lines() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM acc.documents d
             WHERE d.tenant_id = OLD.tenant_id AND d.id = OLD.document_id AND d.status <> 'DRAFT') THEN
    RAISE EXCEPTION 'Chứng từ đã ghi sổ/huỷ – không được sửa dòng' USING ERRCODE = '55000';
  END IF;
  RETURN coalesce(NEW, OLD);
END $$;
CREATE TRIGGER document_lines_immutable BEFORE UPDATE OR DELETE ON acc.document_lines
  FOR EACH ROW EXECUTE FUNCTION acc.guard_posted_lines();
```

### 7.2 Khoá kỳ

```sql
CREATE FUNCTION acc.guard_period_lock() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_lock date;
BEGIN
  SELECT max(locked_through) INTO v_lock FROM acc.period_locks
   WHERE tenant_id = NEW.tenant_id AND company_id = NEW.company_id
     AND scope IN ('ALL', TG_ARGV[0]);
  IF v_lock IS NOT NULL AND NEW.posting_date <= v_lock THEN
    RAISE EXCEPTION 'Kỳ đã khoá sổ đến %', v_lock USING ERRCODE = '55P04';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER je_period_lock BEFORE INSERT OR UPDATE ON acc.journal_entries
  FOR EACH ROW EXECUTE FUNCTION acc.guard_period_lock('ALL');
CREATE TRIGGER sl_period_lock BEFORE INSERT OR UPDATE ON inv.stock_ledger
  FOR EACH ROW EXECUTE FUNCTION acc.guard_period_lock('INVENTORY');
```
(Với UPDATE cần kiểm cả `OLD.posting_date` — chặn dời chứng từ ra khỏi kỳ đã khoá.)
**Close orchestrator** (quy trình 13 bước của 01 §6, có phụ thuộc và cờ `dirty`):

```sql
CREATE TABLE acc.period_close_steps (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL, fiscal_period_id uuid NOT NULL,
  step_code text NOT NULL,   -- 'DOCS_COMPLETE','FX_REVAL','PREPAID_DEPR_PAYROLL','LANDED_COST_NEG_STOCK',
                             -- 'COST_ISSUE_PURCHASED','COLLECT_ALLOCATE_154','PRODUCT_COST','COST_ISSUE_FG',
                             -- 'STOCKTAKE_PROVISION','VAT_OFFSET','CLOSE_911','INVARIANT_CHECK','LOCK'
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
  prev_hash bytea, hash bytea NOT NULL,      -- chuỗi băm theo tenant: hash = sha256(prev_hash || row)
  PRIMARY KEY (tenant_id, occurred_at, id)
) PARTITION BY RANGE (occurred_at);          -- partition theo tháng
REVOKE UPDATE, DELETE ON audit.change_log FROM app_user;
```
- **Bắt buộc, không tắt được**: TT99 yêu cầu phần mềm kế toán ngăn sửa dữ liệu trái phép và lưu vết sửa đổi (01 §1.1); test CI kiểm mọi bảng nghiệp vụ/danh mục đều có trigger audit.
- Trigger generic `audit.log_change()` gắn vào bảng nghiệp vụ & danh mục; lấy `app.user_id`, `app.request_id` từ `current_setting`.
- **Hash chain** theo tenant (khoá `pg_advisory_xact_lock(tenant)` khi lấy prev_hash, hoặc chuỗi theo partition-ngày để tránh nút thắt) ⇒ phát hiện sửa trực tiếp DB. Định kỳ neo (anchor) hash cuối ngày ra object storage Object Lock.
- Nhật ký truy cập (đăng nhập, xuất báo cáo, in chứng từ) ghi riêng `audit.access_log`.

### 7.4 Số chứng từ liên tục (không nhảy số)

- Số chỉ cấp **khi ghi sổ**, trong cùng transaction; nếu rollback ⇒ số không bị “đốt”.
- Không dùng `SEQUENCE` (có lỗ hổng khi rollback). Dùng bảng đếm + khoá dòng:

```sql
CREATE TABLE acc.document_sequences (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL, branch_id uuid,
  doc_type text NOT NULL, fiscal_year smallint NOT NULL,
  prefix text NOT NULL,                       -- 'PN', 'PX', 'BH', 'PC'… theo cấu hình MISA-like
  next_no bigint NOT NULL DEFAULT 1, pad smallint NOT NULL DEFAULT 5,
  PRIMARY KEY (tenant_id, company_id, doc_type, fiscal_year)   -- (+branch nếu đánh số theo CN)
);

UPDATE acc.document_sequences SET next_no = next_no + 1
 WHERE tenant_id=$1 AND company_id=$2 AND doc_type=$3 AND fiscal_year=$4
RETURNING prefix || lpad((next_no-1)::text, pad, '0') AS doc_no;
```
- Khoá dòng nóng chỉ giữ trong transaction ghi sổ (ngắn). Người dùng muốn số “ngay khi lập” (như MISA hiển thị số đề xuất) ⇒ hiển thị **số dự kiến**, số chính thức cấp lúc ghi sổ; cho phép người dùng nhập tay số (kiểm trùng), cấu hình được.
- Chứng từ VOIDED giữ số. Báo cáo “kiểm tra số chứng từ bị nhảy/trùng” là tính năng.
- Số hoá đơn điện tử do hệ thống HĐĐT/nhà cung cấp cấp, lưu riêng (`einvoice.invoices.invoice_no`, ký hiệu mẫu số).

### 7.5 Lưu trữ 10 năm

- Dữ liệu: partition theo năm; năm > N (cấu hình, vd 3) chuyển tablespace rẻ; năm > 10 + kết thúc nghĩa vụ ⇒ export (Parquet + JSON chứng từ + PDF/XML) có checksum, lưu object storage **Object Lock (WORM) 10 năm**, sau đó mới detach.
- Tệp: XML HĐĐT (bản gốc có chữ ký số), PDF chứng từ in, đính kèm ⇒ object storage, key theo `tenant/year/doc_id/…`, ghi `sha256` vào DB.
- Backup: PITR 30 ngày + snapshot hàng tháng giữ 12 tháng + bản năm giữ 10 năm; diễn tập khôi phục hàng quý.
- Xuất dữ liệu theo tenant (data portability): dump logical lọc `tenant_id` (một lý do nữa giữ `tenant_id` ở mọi bảng).

### 7.6 HĐĐT & thuế (tích hợp)

- Anti-corruption layer `EInvoiceProvider` (interface: `issue`, `adjust`, `replace`, `cancel`, `getStatus`, `downloadXml`) với adapter MISA meInvoice / Viettel / VNPT / BKAV… — chọn 1 nhà cung cấp cho MVP nội bộ.
- Luồng: chứng từ bán hàng POSTED → tạo `einvoice.invoices(DRAFT)` → job `einvoice.publish` (BullMQ, retry, idempotency key = invoice id) → lưu mã CQT, XML. Điều chỉnh/thay thế hoá đơn theo NĐ 123 + NĐ 70/2025 là nghiệp vụ riêng, không sửa chứng từ đã ghi sổ.
- Tờ khai thuế GTGT/TNDN: sinh XML theo định dạng HTKK/eTax từ view báo cáo; phiên bản mẫu tờ khai là dữ liệu cấu hình. **[ĐỐI CHIẾU 01, 04]**

---

## 8. Lộ trình, rủi ro, kiểm thử

### 8.1 Lộ trình kỹ thuật

**Phase 0 — Nền móng (3–4 tuần)**
- Monorepo, CI (lint, typecheck, Vitest, Testcontainers), dbmate, kysely-codegen, RLS helper + test tenant-leak, audit trigger, outbox + BullMQ worker khung, auth OIDC, RBAC cơ bản.
- `domain-core`: Money/Qty/Decimal, largest-remainder, Period.
- Golden-test harness (đọc ca kiểm thử YAML).

**Phase 1 — MVP kế toán + kho thương mại (3–4 tháng)**
- Danh mục: TK (template TT99 + TT200 lịch sử, TT133), account roles, VTHH, ĐVT quy đổi, kho, KH/NCC, NV.
- Chứng từ: quỹ, ngân hàng, mua hàng (nhập kho, CP mua), bán hàng (xuất kho), nhập/xuất/chuyển kho, chứng từ nghiệp vụ khác (hạch toán tổng hợp), số dư đầu kỳ.
- Posting engine + constraint trigger cân Nợ/Có; số chứng từ; bỏ ghi/version.
- Stock ledger + GL compose từ `value_change`; giá vốn **BQ cuối kỳ (giá tạm → chốt) + BQ tức thời**; FIFO ở cuối P1 nếu kịp (04 xếp FIFO vào MVP); repost backdated có checkpoint; tính giá xuất kho cuối kỳ có chuyển kho (SCC); cảnh báo tồn âm. Chỉ **KKTX**.
- Giá thành **giản đơn** (04: điểm khác biệt chính so với MISA, đưa vào MVP): BOM (UI 1 cấp, dữ liệu đa cấp), lệnh SX → phiếu xuất NVL, nhập TP; tập hợp 621/622/627 (TT133: 154), phân bổ chi phí chung, SXC dưới công suất → 632, dở dang, kết chuyển 154 (§5.9).
- Kỳ & khoá sổ theo close orchestrator 13 bước, kết chuyển lãi lỗ; kiểm kê.
- Audit log bắt buộc (TT99) ngay từ Phase 0.
- Báo cáo: Sổ Nhật ký chung, Sổ cái, Sổ chi tiết TK/đối tượng, Bảng CĐ số phát sinh, Tổng hợp N-X-T, Thẻ kho, BCTC B01/B02 (theo TT99), drill-down.
- Xuất Excel. Nhập liệu từ Excel (danh mục, số dư đầu).

**Phase 2 — Sản xuất & giá thành + HĐĐT (3 tháng)**
- BOM đa cấp ở UI, bán thành phẩm; phương pháp hệ số, tỷ lệ, đơn đặt hàng (nghiệm thu → 632); **phân bước tự động** trong 1 costing run; lắp ráp/tháo dỡ, gia công.
- Hệ phương trình BTP/TP vòng; `cost_flow_edges` + `product_cost_trace`; báo cáo thẻ tính giá thành, truy xuất lô.
- FIFO + đích danh (lot/serial, hạn dùng).
- HĐĐT 1 nhà cung cấp; tờ khai GTGT; B03 (LCTT), B09 khung.

**Phase 3 — SaaS hoá & mở rộng (liên tục)**
- Onboarding tenant tự phục vụ, billing, giới hạn quota; cell/cluster cho tenant lớn; read replica cho báo cáo.
- CCDC, TSCĐ (khấu hao), tiền lương; ngoại tệ & đánh giá chênh lệch tỷ giá; hợp nhất chi nhánh; sổ quản trị.
- Báo cáo tuỳ biến (report designer), API mở/webhook, kết nối ngân hàng.
- Lưu trữ lạnh tự động 10 năm, kiểm toán hash-chain.

### 8.2 Rủi ro kỹ thuật lớn nhất & giảm thiểu

| # | Rủi ro | Ảnh hưởng | Giảm thiểu |
|---|---|---|---|
| 1 | **Sai giá vốn/giá thành** (làm tròn, thứ tự giao dịch, backdated, vòng lặp) | Sai BCTC, mất niềm tin | Core thuần + golden test giáo trình + property test bảo toàn; so khớp song song với MISA trên dữ liệu thật 2–3 tháng trước khi bỏ MISA (*parallel run*); lưu “giải thích” (ma trận, layer) cho mỗi lần tính |
| 2 | **Hiệu năng repost** khi backdated sâu vào kỳ dài, nhiều lan truyền | Báo cáo trễ, khoá tranh chấp | Coalescing, chạy theo cost key song song, chỉ ghi dòng thay đổi, checkpoint theo lô, giới hạn độ sâu lan truyền, khuyến khích khoá sổ hàng tháng; benchmark 1 triệu dòng/kỳ trong CI nightly |
| 3 | **Rò rỉ dữ liệu giữa tenant** | Nghiêm trọng | FORCE RLS, `current_setting` không missing_ok, FK kép, test tenant-leak tự động cho mọi endpoint, role DB không bypass |
| 4 | **Toàn vẹn kế toán bị phá** (chứng từ có thẻ kho nhưng không có bút toán, Nợ≠Có) | Sai sổ | Posting đồng bộ trong 1 transaction; constraint trigger; job đối chiếu hàng đêm (kho 15x vs sổ cái, document vs journal), cảnh báo |
| 5 | **Thay đổi chế độ/quy định** (TT99 thay TT200, NĐ 70/2025, mẫu tờ khai) | Phải sửa code liên tục | Account roles, báo cáo dạng công thức cấu hình, mẫu tờ khai là dữ liệu có version |
| 6 | **Số học Decimal sai** do lẫn `number` | Lệch xu | ESLint rule, API dùng string, branded types `Money`, property test |
| 7 | **Phạm vi phình** (muốn bằng MISA ngay) | Trễ | MVP: thương mại + kho + BQ + giá thành **giản đơn** (BOM 1 cấp ở UI); phần SX nâng cao ở P2; mỗi phân hệ có “definition of done” bằng báo cáo đối chiếu |
| 9 | **Quy định chưa ổn định** (TT99 mới áp dụng; dự thảo thay TT133; số hiệu mẫu sổ TT99 chưa xác minh — 01 §9) | Sửa mẫu/biểu nhiều lần | Mọi thứ phụ thuộc văn bản là dữ liệu có version; theo dõi văn bản như một backlog riêng |
| 8 | **Kysely/SQL nặng → khó bảo trì** | Chậm phát triển | Báo cáo phức tạp viết thành SQL function có test riêng (pgTAP hoặc Vitest gọi function), tài liệu hoá |

### 8.3 Chiến lược kiểm thử

**Kim tự tháp**
1. **Unit (core thuần, Vitest)** — engine giá, phân bổ, dở dang, posting rules, làm tròn. Nhanh, chiếm phần lớn.
2. **Golden tests** — ví dụ số từ giáo trình (Kế toán tài chính / Kế toán chi phí, NEU/UEH/HV Tài chính, sách tham khảo trong `03`) và từ tài liệu hướng dẫn MISA. Định dạng YAML:
   ```yaml
   # Ví dụ dùng chung 01 §3.2 – Vật tư A, kho K1, tháng 01; 1 bộ dữ liệu, 4 phương pháp, 4 kỳ vọng
   name: "VTA-K1-T01"
   opening: { qty: 100, value: 1_000_000 }
   txns:
     - { id: N1, date: 2026-01-05, kind: PURCHASE,   qty: 200, rate: 11_000 }
     - { id: X1, date: 2026-01-10, kind: PROD_ISSUE, qty: 250 }
     - { id: N2, date: 2026-01-20, kind: PURCHASE,   qty: 100, rate: 12_000 }
     - { id: X2, date: 2026-01-25, kind: PROD_ISSUE, qty: 100 }
   expect:
     PERIODIC_AVG: { unit_cost: "11000", out: { X1: "2750000", X2: "1100000" }, closing: { qty: 50, value: "550000" } }
     MOVING_AVG:   { out: { X1: "2666667", X2: "1155555" }, closing: { qty: 50, value: "577778" } }
     FIFO:         { out: { X1: "2650000", X2: "1150000" }, closing: { qty: 50, value: "600000" } }
     SPECIFIC:     { pick: { X2: N2 }, out: { X2: "1200000" } }
     journals:     # BQ cuối kỳ, sau khi chốt
       - { dr: "621", cr: "152", amount: "3850000", cost_object: required }
   variants:       # cùng dữ liệu, thêm biến cố – kết quả phải bằng chạy-lại-từ-đầu
     - backdated: { id: N0, date: 2026-01-08, kind: PURCHASE, qty: 50, rate: 10_000, posted_after: X2 }
     - provisional_then_final: true      # PERIODIC_AVG: X1 tạm = 10.666,67 → chốt 11.000
   ```
   Bộ golden ban đầu lấy từ `01-nghiep-vu-ke-toan.md`: §3.2–3.7 (4 phương pháp giá xuất), §3.8 (trả lại, điều chỉnh giá nhập sau: giảm giá 1tr cho lô 200 kg đã xuất 150 → Có 152: 250.000, Có 632/154: 750.000; phân bổ CP mua 600.000 theo giá trị → A 400.000 / B 200.000), §4.2 (phân bổ 627 theo NCTT: 13.333.333 / 6.666.667 — dòng cuối nhận dư; SXC dưới công suất 8tr/2tr → 632), §4.3–4.4 (dở dang, giản đơn/hệ số/tỷ lệ/phân bước/đơn hàng); bổ sung từ giáo trình trong `03`; BCTC B01/B02 từ bộ số dư mẫu. Golden test chạy cả ở mức core và mức tích hợp (DB thật) ⇒ bảo đảm SQL và TS cho cùng kết quả.
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
     | I7 số CT duy nhất | unique index + `document_sequences` | integration song song |
     | K1, K2 kho = sổ cái 15x; 1 dòng kho ↔ 1 dòng bút toán | GL compose từ `value_change` (§4.7) | property |
     | K3 SL ≥ 0 / = 0 khi khoá | kiểm `min(qty_after)` từ T; checklist khoá | property + integration |
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
  return withTenantTx(ctx, async (tx) => {
    const doc = await loadForUpdate(tx, docId);                  // SELECT … FOR UPDATE
    assertStatus(doc, 'DRAFT'); validate(doc);                   // Zod + nghiệp vụ (TK theo dõi đối tượng…)
    await assertPeriodOpen(tx, doc);                             // (trigger cũng chặn)
    doc.docNo ??= await nextDocNo(tx, doc);                      // §7.4
    const lines = postingRules[doc.docType](doc, await roles(tx, doc));
    assertBalanced(lines);                                       // fail sớm
    const entry = await insertJournal(tx, doc, lines);           // constraint trigger kiểm lúc COMMIT
    const moves = stockEffects(doc);                             // nhập/xuất/chuyển
    for (const m of moves) {
      await assertStockAvailable(tx, m);                         // nếu cấm âm kho, kiểm cả tương lai từ ts
      const sle = await appendLedger(tx, m);                     // seq từ sequence; qty_after tạm tính
      if (isBackdated(sle) || needsValuation(sle)) await enqueueRepost(tx, keyOf(sle), tsOf(sle));
      else await valueInline(tx, sle);                           // moving avg, không backdated: tính ngay
    }
    await markPosted(tx, doc, hashOf(doc, lines, moves));
    await outbox(tx, 'DocumentPosted', { docId, type: doc.docType });
  });
}
```

## Phụ lục B — Câu hỏi mở cần chốt với nghiệp vụ

1. Phương pháp tính giá mặc định của công ty (BQ cuối kỳ theo tháng hay BQ tức thời)? Tính giá theo từng kho hay toàn công ty?
2. Có cho phép xuất âm kho không? Hàng bán trả lại nhập theo giá nào?
3. Sản xuất: phương pháp giá thành thực tế đang dùng (giản đơn/hệ số/tỷ lệ/phân bước/đơn hàng)? Đánh giá dở dang theo cách nào? Có BTP/tái chế tạo vòng không?
4. Cần sổ quản trị song song sổ tài chính ngay từ MVP không?
5. Chính sách “bỏ ghi” (MISA cho phép) hay bắt buộc chứng từ đảo?
6. Nhà cung cấp HĐĐT hiện tại của công ty?
7. Chế độ kế toán áp dụng năm 2026: TT99 hay TT133? Cần chuyển dữ liệu lịch sử từ MISA mấy năm?
