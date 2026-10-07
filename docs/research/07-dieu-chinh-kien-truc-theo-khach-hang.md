# 07 — Điều chỉnh kiến trúc và dữ liệu theo yêu cầu khách hàng

> Phiên bản: 0.2 · Ngày: 2026-10-07 · Trạng thái: đề xuất để review · 0.2 thêm §2.8 (vị trí chứa, mã hóa lô) từ file Excel kho BTP của khách
> Đầu vào: `../YEU-CAU-KHACH-HANG.md` (mã yêu cầu dẫn trong tài liệu này), `../KE-HOACH-DU-AN.md` v0.3, `05-kien-truc-de-xuat.md`.
> Quan hệ với 05: 05 đang được sửa song song ở vòng này (số CT có `fiscal_year`, FK dòng `ON DELETE RESTRICT`, guard chặn INSERT/UPDATE/DELETE dòng của chứng từ đã ghi sổ, không partition ở Giai đoạn 1, khoá advisory theo cost key khi ghi sổ, khoá kỳ `FOR SHARE`). 07 **chỉ mô tả phần thêm hoặc thay đổi** so với 05 để đáp ứng tài liệu khách; phần không nhắc tới giữ như 05.
> Kiểm chứng: toàn bộ DDL trong tài liệu này **đã chạy trên PostgreSQL 16.15** cùng một bộ giả lập tối thiểu các bảng của 05 (`uuidv7()` thay bằng `gen_random_uuid()` vì PG16 chưa có), kèm phép thử chức năng: guard dòng/trạng thái, chặn xuất lô chưa Đạt QC, khoá tỷ giá theo ngày, CHECK bảng giá thành, RLS hai tenant, truy vấn truy xuất lô. **Chưa** chạy trên PG18, **chưa** thử hai phiên đồng thời.

---

## 0. Tóm tắt thay đổi so với 05

| # | Chủ đề | 05 | 07 | Yêu cầu |
|---|---|---|---|---|
| 1 | Phương pháp giá xuất | BQ cuối kỳ / BQ tức thời là chính; FIFO, đích danh ở giai đoạn sau | **Đích danh theo lô là chính**. Cost key = `(company, item, warehouse, lot)`; lô chính là lớp giá, không cần `cst.cost_layers` | GT-07 |
| 2 | Lô | `inv.lots` tối giản, `lot_id` tuỳ chọn | Lô có loại, NSX/HSD, **trạng thái QC**, nguồn (phiếu nhập / lệnh SX), khu QC; hàng đích danh **bắt buộc lô** | QC-03, QC-05 |
| 3 | Kiểm âm | Theo `(item, warehouse, lot)` bằng truy vấn trên sổ kho | Thêm vị trí chứa: theo `(item, warehouse, lot, location)` (§2.8); vì cost key đã gồm lô nên lũy kế vật lý và lũy kế định giá **trùng nhau** | KHO-02 |
| 4 | Giá thành | Giản đơn; phân bước tự động qua SCC/BOM đa cấp | **Lệnh SX công đoạn** (lô × giai đoạn) là đối tượng tập hợp chi phí; BTP đi tiếp **bằng giá lô**; dở dang nhiều kỳ = chi phí luỹ kế của lệnh | GT-01..06 |
| 5 | Hệ phương trình BQ cuối kỳ | Gauss / Gauss–Seidel cho SCC | **Không cần** với đích danh: chuỗi lô là đồ thị có hướng theo thời gian; làm lại (rework) là lệnh mới nên không tạo vòng | — |
| 6 | Hàng không đạt QC | Không có | Trong định mức dồn vào SL đạt; ngoài định mức ra 632/811/1388; phiếu QC → quyết định xử lý → chứng từ | GT-06, QC-06 |
| 7 | Ngoại tệ | Cột `currency, amount_fc, fx_rate` trên dòng bút toán, chưa có nghiệp vụ | Tỷ giá theo ngày có **khoá ngày**; khoản mục mở theo chứng từ gốc; tất toán sinh 515/635; đánh giá lại qua 413 | NT-01..05 |
| 8 | TSCĐ, CCDC, khế ước vay | Ngoài phạm vi (nhập qua chứng từ tổng hợp) | Bảng riêng, lịch, bút toán tự sinh qua chứng từ hệ thống | TSCD-*, CCDC-*, NH-03 |
| 9 | Đơn hàng, đề nghị thanh toán | Ngoài phạm vi | Bảng đơn mua/bán, đề nghị thanh toán, luồng duyệt dùng chung | MUA-01, BAN-01, TIEN-01 |
| 10 | LCTT | Nhắc trong 01 | Mã dòng tiền trên dòng bút toán tiền (trực tiếp) + bảng công thức (gián tiếp) | BC-R4 |
| 11 | QC | Không có | Điểm kiểm soát theo thao tác, chỉ tiêu, phiếu kiểm, xử lý không đạt | QC-01..08 |
| 12 | Vị trí chứa, mã hóa | Không có | Bồn / trái / phuy theo kho; **kiểm âm theo `(item, warehouse, lot, location)`**, cost key vẫn theo lô; mã hóa lô tự sinh, bất biến; tồn tối thiểu, mã MISA, số phiếu kho theo tháng (§2.8) | KHO-06..11, KHO-R7..R9 |

## 1. Quy ước tuân thủ cho mọi bảng mới

- `tenant_id uuid NOT NULL`, PK `(tenant_id, id)`, FK kép `(tenant_id, x_id)`; RLS `ENABLE` + `FORCE` (khối §11).
- Số chứng từ/đơn/phiếu duy nhất **theo năm**: `UNIQUE (tenant_id, company_id, [loại,] fiscal_year, số)`.
- FK từ dòng tới header: `ON DELETE RESTRICT` (mặc định), **không** `CASCADE`.
- Dòng con của header đã chốt: trigger chặn **INSERT/UPDATE/DELETE** (`app.guard_child_rows`); header: chặn xoá khi rời nháp và chỉ cho chuyển trạng thái theo danh sách (`app.guard_header_status`). Header kế toán dùng `acc.documents` và guard của 05.
- Không partition ở Giai đoạn 1.
- Bảng dữ liệu hệ thống không thuộc tenant (`sys.currencies`, `sys.cash_flow_lines`) là ngoại lệ có tên trong test "mọi bảng có `tenant_id`" (06b-N4).
- Mọi số tiền theo **R1** (`../KE-HOACH-DU-AN.md` §2).

Hai hàm guard dùng chung:

```sql
CREATE SCHEMA ast;
CREATE SCHEMA fin;
CREATE SCHEMA wf;
CREATE SCHEMA ord;
CREATE SCHEMA cash;
CREATE SCHEMA qc;

-- Chặn INSERT/UPDATE/DELETE dòng con khi header ở trạng thái khoá.
-- TG_ARGV[0] = bảng header (schema.table), TG_ARGV[1] = cột FK trỏ tới header,
-- TG_ARGV[2] = mảng trạng thái khoá dạng text, vd '{POSTED,VOIDED}'
CREATE FUNCTION app.guard_child_rows() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_header regclass := TG_ARGV[0]::regclass;
  v_fk     text     := TG_ARGV[1];
  v_locked text[]   := TG_ARGV[2]::text[];
  v_row    jsonb;
  v_status text;
BEGIN
  -- kiểm cả header của hàng mới và hàng cũ (UPDATE đổi FK); jsonb để một hàm dùng cho mọi bảng
  FOREACH v_row IN ARRAY ARRAY[to_jsonb(NEW), to_jsonb(OLD)] LOOP
    CONTINUE WHEN v_row IS NULL OR v_row ->> v_fk IS NULL;
    EXECUTE format('SELECT status FROM %s WHERE tenant_id = $1 AND id = $2 FOR SHARE', v_header)
      INTO v_status USING (v_row ->> 'tenant_id')::uuid, (v_row ->> v_fk)::uuid;
    IF v_status = ANY (v_locked) THEN
      RAISE EXCEPTION '% %: trạng thái % — không được thêm/sửa/xoá dòng', v_header, v_row ->> v_fk, v_status
        USING ERRCODE = '55000';
    END IF;
  END LOOP;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;

-- Chặn xoá header đã rời trạng thái nháp; chỉ cho chuyển trạng thái theo bảng cho phép.
-- TG_ARGV[0] = trạng thái được xoá (thường 'DRAFT'); TG_ARGV[1] = các cặp chuyển hợp lệ 'A>B'
CREATE FUNCTION app.guard_header_status() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    IF OLD.status <> TG_ARGV[0] THEN
      RAISE EXCEPTION 'Không được xoá % ở trạng thái %', TG_TABLE_NAME, OLD.status USING ERRCODE = '55000';
    END IF;
    RETURN OLD;
  END IF;
  IF NEW.tenant_id <> OLD.tenant_id OR NEW.id <> OLD.id THEN
    RAISE EXCEPTION 'Không được đổi khoá' USING ERRCODE = '55000';
  END IF;
  IF NEW.status <> OLD.status
     AND NOT (OLD.status || '>' || NEW.status) = ANY (TG_ARGV[1]::text[]) THEN
    RAISE EXCEPTION '%: không cho chuyển % → %', TG_TABLE_NAME, OLD.status, NEW.status USING ERRCODE = '55000';
  END IF;
  RETURN NEW;
END $$;
```

Danh mục khu làm việc (khu QC, bộ phận sử dụng tài sản) dùng chung cho phân quyền theo khu, lô, TSCĐ:

```sql
CREATE TABLE md.work_areas (
  tenant_id  uuid NOT NULL,
  id         uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  code text NOT NULL, name text NOT NULL,
  kind text NOT NULL CHECK (kind IN ('PRODUCTION_AREA','DEPARTMENT')),   -- khu SX (thủy sản…) / bộ phận
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, code),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id)
);
```

---

## 2. Lô và sổ kho theo (vật tư, kho, lô)

### 2.1 Mô hình lô

- **Mã lót** = `lot_no`, duy nhất theo `(company, item)`. Mẫu sinh mã là cấu hình (chờ khách gửi quy tắc — câu hỏi A4).
- **Loại lô**: `PURCHASED` (tạo khi lập dòng phiếu nhập mua; nếu người dùng không chọn lô có sẵn thì mỗi dòng nhập một lô mới), `SEMI_FINISHED` / `FINISHED` (tạo bởi lệnh công đoạn), `OPENING` (tồn đầu kỳ khi chuyển đổi), `BYPRODUCT` (phế liệu, phụ phẩm thu hồi).
- **Trạng thái QC**: `PENDING` → `RELEASED` / `REJECTED` / `HOLD`. Chỉ đổi qua phiếu kiểm chốt hoặc quyết định xử lý (§10), trong cùng transaction với phiếu đó; mọi thay đổi vào nhật ký sửa đổi.
- Hàng có `costing_method = 'SPECIFIC'` bắt buộc `track_lot` (CHECK trên `md.items`); dòng kho của hàng theo lô bắt buộc có `lot_id` (trigger). Theo giả định của tài liệu yêu cầu, **mọi** hàng tồn kho đều đích danh theo lô; bao bì, phụ gia được hệ thống tự gợi ý lô (FEFO rồi lô cũ nhất) để người dùng không phải chọn tay.

### 2.2 Cost key và khoá

- Cost key đích danh = `(company, item, warehouse, lot)`: trong `inv.stock_ledger` của 05, `cost_key_scope = warehouse_id` và `lot_id` NOT NULL. Lũy kế định giá và lũy kế vật lý (dùng để kiểm âm, 06b-A4) **cùng một khoá**, nên truy vấn kiểm âm của 05 §4.7 dùng trực tiếp.
- Khoá: `inv.lock_cost_key(tenant, item, warehouse, lot)` (§2.7), gọi cho **mọi** cost key của chứng từ, **sắp tăng dần theo giá trị băm**, trước khi đọc tồn, cấp `seq`, ghi sổ kho; worker tính lại dùng cùng khoá. Chuyển kho lấy cả khoá kho đi và kho đến. Va chạm băm chỉ làm tuần tự hoá thừa, không sai. Chuỗi khoá trùng định dạng `'ck:'||tenant||':'||item||':'||scope||':'||lot` của 05 §5.1 (với đích danh `scope` = kho), nên ghi sổ và worker tính lại dùng chung một khoá.

### 2.3 Quy tắc định giá đích danh

| Nghiệp vụ | Giá trị dòng kho | Ghi chú |
|---|---|---|
| Nhập mua | Thành tiền HĐ (theo VND, R1(a)) + chi phí mua phân bổ (R1(b)) | Lô mới. Chi phí mua về sau: như "điều chỉnh giá trị lô" bên dưới |
| Xuất (bán, SX, dùng, huỷ, trả NCC, chuyển đi) | `round(q × V / Q)` của cost key tại thời điểm xuất; nếu `q = Q` thì lấy toàn bộ `V` — **R1(c)** | Không bình quân giữa các lô |
| Chuyển kho | Dòng nhận = đúng giá trị dòng xuất (`valuation_source = 'LINKED'`) vào `(item, kho đến, cùng lô)` | Giữ giá lô; bất biến K7 |
| Hàng bán trả lại | Vào **lô gốc**; giá trị = R1(c) áp trên **dòng xuất gốc** (nguồn = SL và giá trị của dòng bán gốc còn chưa bị trả); lần trả cuối nhận phần còn lại | Kho nhận có thể khác kho xuất |
| Trả lại hàng mua | Xuất từ lô gốc theo R1(c) | Chênh lệch với giá HĐ (phần chi phí mua đã phân bổ) theo quyết định KTT (632 hoặc 811) — chưa xác minh |
| Điều chỉnh giá trị lô (giảm giá hàng mua, chi phí mua về sau, HĐ khác giá tạm) | Chia số điều chỉnh theo **SL** (R1(b)) cho: (a) phần lô còn tồn ở từng kho → dòng `ADJUST` SL = 0 vào cost key đó; (b) phần đã xuất cho lệnh SX chưa tính giá thành trong kỳ mở → vào chi phí lệnh (621/154); (c) phần đã bán, đã vào lệnh đã tính giá, hoặc thuộc kỳ đã khoá → 632 | Không lan tiếp xuống lô BTP/TP đã tính giá trong Giai đoạn 1 — giữ hệ thống đơn giản, KTT cần xác nhận |
| Nhập BTP/TP từ lệnh | Từ giá thành lệnh (§4); `PENDING` đến khi tính | Phiếu xuất lô `PENDING` mang giá tạm (giá thành kế hoạch hoặc lô gần nhất cùng SP), chốt khi lô có giá |
| Kiểm kê thừa của lô đang có | `round(q × V/Q)` của lô tại kho; nếu lô đã hết ở kho: theo giá trị đơn vị của lô ở lần nhập gốc | Nợ 15x / Có 3381 |

Tính lại: **phát lại toàn bộ** cost key từ mốc kỳ khoá gần nhất (06b §5 đề xuất 2), không repost tăng dần. Với đích danh, mỗi cost key là một lô ở một kho nên chuỗi dòng rất ngắn. Lan truyền: lô NVL đổi giá → lệnh dùng lô → lô BTP → lệnh sau → lô TP → giá vốn; trong kỳ mở do lần chạy giá thành xử lý, không vượt kỳ đã khoá.

### 2.4 Bút toán phần kho theo mục đích xuất (sửa C5 của kế hoạch)

Composer của 05 lấy `Σ value_change` làm vế **TK kho**; vế đối ứng lấy theo **account role của mục đích dòng** × chế độ kế toán, không mặc định 154/632:

| Mục đích | Role đối ứng | TT99 | TT133 |
|---|---|---|---|
| Xuất NVL/BTP cho lệnh SX | `WIP_MATERIAL` / `WIP_SEMI` | 621 (hoặc 154 cho BTP, §4.2) | 154 (khoản mục NVL / BTP) |
| Xuất dùng chung xưởng | `MOH_MATERIAL` | 627x | 154 (SXC, chờ phân bổ) |
| Xuất cho bán hàng / QLDN | `SELLING_EXP` / `ADMIN_EXP` | 641 / 642 | 6421 / 6422 |
| Xuất CCDC đưa vào dùng | `PREPAID_TOOL` | 242 | 242 |
| Bán | `COGS` | 632 | 632 |
| Huỷ do không đạt / hư hỏng | theo quyết định xử lý | 632 / 811 / 1388 | 632 / 811 / 1388 |
| Trả NCC | `AP` | 331 | 331 |
| Nhập TP từ lệnh | `WIP` | Có 154 | Có 154 |
| Kiểm kê thiếu / thừa | `SHORTAGE` / `SURPLUS` | 1381 / 3381 | 1381 / 3381 |

### 2.5 Chặn sử dụng lô chưa Đạt QC

Trigger trên `inv.stock_moves` (khi INSERT): hàng có `qc_required` thì dòng xuất loại `SALE`, `PROD_ISSUE` phải từ lô `RELEASED`. Chuyển kho, trả NCC, xuất huỷ, kiểm kê **không** bị chặn (để đưa hàng không đạt ra khu cách ly, trả, huỷ). Trigger lấy `FOR SHARE` trên dòng lô nên không chạy song song với việc đổi trạng thái QC của chính lô đó.

### 2.6 Phả hệ lô và truy xuất

Không lưu bảng phả hệ riêng: view `inv.v_lot_genealogy` suy ra cặp (lô vào → lô ra) của cùng một lệnh từ `inv.stock_moves` (thêm cột `production_order_id` phi chuẩn hoá). View đặt `security_invoker = true` để RLS áp theo người gọi.

Truy ngược từ một lô TP về mọi lô đầu vào (đã chạy thử):

```sql
WITH RECURSIVE up AS (
  SELECT g.output_lot_id AS root, g.input_lot_id AS lot_id, 1 AS depth,
         ARRAY[g.output_lot_id, g.input_lot_id] AS path
    FROM inv.v_lot_genealogy g WHERE g.output_lot_id = $1
  UNION ALL
  SELECT up.root, g.input_lot_id, up.depth + 1, up.path || g.input_lot_id
    FROM up JOIN inv.v_lot_genealogy g ON g.output_lot_id = up.lot_id
   WHERE up.depth < 20 AND NOT g.input_lot_id = ANY (up.path)
)
SELECT up.depth, l.lot_no, l.lot_kind, l.supplier_id, l.qc_status
  FROM up JOIN inv.lots l ON l.tenant_id = app.current_tenant() AND l.id = up.lot_id
 ORDER BY up.depth;
```

Truy xuôi (lô NVL → lô TP → khách hàng) là cùng truy vấn đổi chiều (`input_lot_id = $1`, nối `output_lot_id`), rồi nối các dòng `SALE` của lô TP để ra danh sách KH, SL, ngày — phục vụ thu hồi sản phẩm (QC-07).

### 2.7 DDL

```sql
ALTER TABLE md.items
  ADD COLUMN qc_required boolean NOT NULL DEFAULT false,   -- lô phải Đạt QC mới được xuất SX/bán
  ADD COLUMN shelf_life_days int CHECK (shelf_life_days > 0),
  ADD CONSTRAINT items_specific_needs_lot
    CHECK (costing_method IS DISTINCT FROM 'SPECIFIC' OR track_lot);

CREATE TABLE inv.lots (                     -- thay inv.lots của 05 §4.6
  tenant_id  uuid NOT NULL,
  id         uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  item_id    uuid NOT NULL,
  lot_no     text NOT NULL,                 -- mã lót
  lot_kind   text NOT NULL
    CHECK (lot_kind IN ('PURCHASED','SEMI_FINISHED','FINISHED','OPENING','BYPRODUCT')),
  mfg_date date, expiry_date date,
  qc_status text NOT NULL DEFAULT 'PENDING'
    CHECK (qc_status IN ('PENDING','RELEASED','HOLD','REJECTED')),
  supplier_id uuid,
  receipt_line_id uuid,                     -- dòng phiếu nhập mua tạo lô (không FK: dòng nháp có thể bị xoá trước)
  production_order_id uuid,                 -- lệnh công đoạn tạo lô BTP/TP
  work_area_id uuid,                        -- khu QC lập mã
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, item_id, lot_no),
  CHECK (expiry_date IS NULL OR mfg_date IS NULL OR expiry_date >= mfg_date),
  CHECK (lot_kind NOT IN ('SEMI_FINISHED','FINISHED') OR production_order_id IS NOT NULL),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id),
  FOREIGN KEY (tenant_id, item_id) REFERENCES md.items (tenant_id, id),
  FOREIGN KEY (tenant_id, supplier_id) REFERENCES md.partners (tenant_id, id),
  FOREIGN KEY (tenant_id, production_order_id) REFERENCES mfg.production_orders (tenant_id, id),
  FOREIGN KEY (tenant_id, work_area_id) REFERENCES md.work_areas (tenant_id, id)
);
CREATE INDEX lots_expiry ON inv.lots (tenant_id, item_id, expiry_date) WHERE qc_status = 'RELEASED';

ALTER TABLE inv.stock_moves
  ADD COLUMN production_order_id uuid,      -- phi chuẩn hoá từ dòng chứng từ, cho truy xuất lô
  ADD CONSTRAINT sm_lot_fk FOREIGN KEY (tenant_id, lot_id) REFERENCES inv.lots (tenant_id, id);
ALTER TABLE inv.stock_ledger
  ADD CONSTRAINT sle_lot_fk FOREIGN KEY (tenant_id, lot_id) REFERENCES inv.lots (tenant_id, id);

-- Hàng tính giá đích danh bắt buộc có lô; lô phải Đạt QC mới được xuất SX/bán
CREATE FUNCTION inv.guard_move_lot() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_item record; v_qc text; v_lot_item uuid;
BEGIN
  SELECT costing_method, track_lot, qc_required INTO STRICT v_item
    FROM md.items WHERE tenant_id = NEW.tenant_id AND id = NEW.item_id;
  IF (v_item.costing_method = 'SPECIFIC' OR v_item.track_lot) AND NEW.lot_id IS NULL THEN
    RAISE EXCEPTION 'Vật tư % theo lô: dòng kho bắt buộc có lô', NEW.item_id USING ERRCODE = '23502';
  END IF;
  IF NEW.lot_id IS NOT NULL THEN
    SELECT item_id, qc_status INTO STRICT v_lot_item, v_qc
      FROM inv.lots WHERE tenant_id = NEW.tenant_id AND id = NEW.lot_id
      FOR SHARE;                                   -- xung đột với cập nhật trạng thái QC đang diễn ra
    IF v_lot_item <> NEW.item_id THEN
      RAISE EXCEPTION 'Lô % không thuộc vật tư %', NEW.lot_id, NEW.item_id USING ERRCODE = '23503';
    END IF;
    IF v_item.qc_required AND NEW.direction = -1 AND NEW.move_kind IN ('SALE','PROD_ISSUE')
       AND v_qc <> 'RELEASED' THEN
      RAISE EXCEPTION 'Lô % đang ở trạng thái QC % — không được xuất SX/bán', NEW.lot_id, v_qc
        USING ERRCODE = '55000';
    END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER stock_moves_lot_guard BEFORE INSERT ON inv.stock_moves
  FOR EACH ROW EXECUTE FUNCTION inv.guard_move_lot();

-- Khoá advisory theo cost key (item, warehouse, lot); caller gọi cho mọi key của chứng từ theo thứ tự tăng dần
CREATE FUNCTION inv.lock_cost_key(p_tenant uuid, p_item uuid, p_warehouse uuid, p_lot uuid)
RETURNS void LANGUAGE sql AS $$
  SELECT pg_advisory_xact_lock(hashtextextended(
    'ck:' || p_tenant || ':' || p_item || ':' || p_warehouse || ':' || coalesce(p_lot::text, ''), 0));   -- cùng chuỗi khoá với 05 §5.1 (scope = kho)
$$;

-- Phả hệ lô: lô đầu vào của một lệnh → lô đầu ra của cùng lệnh (suy ra, không lưu trùng)
CREATE VIEW inv.v_lot_genealogy WITH (security_invoker = true) AS
SELECT i.tenant_id, i.production_order_id,
       i.lot_id AS input_lot_id, i.item_id AS input_item_id, i.qty AS input_qty,
       o.lot_id AS output_lot_id, o.item_id AS output_item_id, o.qty AS output_qty
FROM (SELECT tenant_id, production_order_id, lot_id, item_id, sum(qty) AS qty
        FROM inv.stock_moves
       WHERE move_kind = 'PROD_ISSUE' AND status = 'ACTIVE' AND production_order_id IS NOT NULL
       GROUP BY 1, 2, 3, 4) i
JOIN (SELECT tenant_id, production_order_id, lot_id, item_id, sum(qty) AS qty
        FROM inv.stock_moves
       WHERE move_kind = 'PROD_RECEIPT' AND status = 'ACTIVE' AND production_order_id IS NOT NULL
       GROUP BY 1, 2, 3, 4) o
  ON o.tenant_id = i.tenant_id AND o.production_order_id = i.production_order_id;
```

### 2.8 Vị trí chứa (bồn / trái / phuy) và mã hóa lô

Nguồn: file Excel kho BTP của nhà máy Bà Ba Thạo (`../YEU-CAU-KHACH-HANG.md` §9). Sổ kho của khách theo dõi tồn theo **tên hàng + mã lô + mã hóa + bồn/trái/phuy**; một lô BTP nằm ở nhiều bồn (vd một lô mắm nêm ở 6 bồn A.15, A.26…A.30), chuyển bồn là nghiệp vụ thường ngày.

**Quyết định**

| # | Quyết định | Lý do |
|---|---|---|
| 1 | Bảng `inv.storage_locations` = khu + loại (`TANK` bồn, `JAR` trái, `DRUM` phuy) + số (tuỳ chọn, bắt buộc với bồn) + sức chứa, **theo kho** | Ký hiệu của khách (`A.15`, `5.Trái`, `B.Phuy`) tách được thành 3 phần; chuẩn hoá cách ghi (`2. trái`, `B.phuy`, `A.` thiếu số) |
| 2 | `location_id` trên `inv.stock_moves`, `inv.stock_ledger`, `inv.stock_balances`; **NULL = không theo vị trí** (hàng đóng gói, kho Bình Tây / 97 chưa theo bồn) | Không bắt mọi kho phải có danh mục vị trí; hàng `track_location` mới bắt buộc |
| 3 | **Kiểm âm theo `(item, warehouse, lot, location)`** — thay cấp `(item, warehouse, lot)` của §2.2 / 05 §4.7 | Xuất 250 kg từ bồn chỉ còn 100 kg phải bị chặn dù cả lô còn 1.200 kg |
| 4 | **Cost key giữ `(company, item, warehouse, lot)`**; vị trí chỉ chia số lượng | Giá trị đích danh thuộc về lô; chuyển bồn không được làm đổi giá lô. Giá trị theo vị trí (nếu cần hiển thị) = giá trị lô tại kho phân bổ theo SL theo R1(b), không ghi sổ |
| 5 | Khoá advisory vẫn theo cost key (§2.2): một khoá cho mọi vị trí của lô tại kho | Truy vấn kiểm âm theo vị trí chạy **sau** khi đã giữ khoá cost key nên không có hai phiên cùng xuất một bồn; chuyển bồn trong cùng kho chỉ cần **một** khoá |
| 6 | Chuyển vị trí trong cùng kho = chứng từ chuyển kho có `warehouse_id = to_warehouse_id`, `location_id ≠ to_location_id`; hai dòng `TRANSFER_OUT`/`TRANSFER_IN` `LINKED` cùng giá trị | Tổng giá trị cost key không đổi; không sinh bút toán (cùng TK kho); vẫn có số phiếu kho, in được |
| 7 | **Mã hóa (`lots.lot_code`) do hệ thống tự sinh** khi tạo lô: nhóm hàng + YYMM + số thứ tự 4 chữ số (`BTP-2601-0003`); duy nhất theo công ty; **không sửa, không cấp lại** khi huỷ phiếu; không đổi khi chuyển kho / chuyển bồn | Theo ý người dùng ("mã hóa có thể là 1 mã tự sinh"). **Đề xuất, chờ khách xác nhận định dạng.** File Excel cũ coi mã hóa = 2 ký tự cuối mã lô (chỉ kiểm khớp, không có nghĩa nghiệp vụ rõ) |
| 8 | Bộ đếm `inv.lot_code_counters` theo `(company, prefix, yymm)`, cấp bằng `UPDATE … RETURNING` (khoá dòng) trong cùng transaction tạo lô | Liền mạch, không trùng khi nhiều phiên; số đã cấp không quay lại kể cả khi transaction sau đó huỷ chứng từ (chỉ "nhảy số" khi rollback — chấp nhận được, mã hóa không phải số chứng từ kế toán) |
| 9 | `md.items` thêm `min_stock_qty` (tồn tối thiểu, cảnh báo "Cần đặt thêm") và `misa_code` (mã MISA tương ứng, duy nhất theo công ty, NULL được) | Từ sheet tồn kho và sheet cú pháp tên của file |
| 10 | Số phiếu kho `PNK-YYMMnnn` / `PXK-YYMMnnn` là cột riêng trên chứng từ kho (cạnh số chứng từ kế toán), bộ đếm theo `(company, slip_kind, yymm)` | File đánh số phiếu kho theo tháng; số chứng từ kế toán theo năm (§1) vẫn giữ |

Mã lô dạng **DDMMYY-nn** (ngày nhập / sản xuất + số mẻ) là mẫu mặc định của cấu hình sinh mã lô (A4); demo kiểm trùng mã lô **toàn công ty** (khách chưa nói trùng theo mặt hàng có được không — câu hỏi D6 ở `../YEU-CAU-KHACH-HANG.md` §9.7), còn `inv.lots` giữ `UNIQUE (tenant_id, company_id, item_id, lot_no)` như §2.7 cho tới khi khách trả lời.

**DDL** (đã chạy trên PostgreSQL 16 cùng bộ giả lập tối thiểu các bảng của 05/07 — xem phép thử cuối mục):

```sql
CREATE TABLE inv.storage_locations (
  tenant_id    uuid NOT NULL,
  id           uuid NOT NULL DEFAULT uuidv7(),
  company_id   uuid NOT NULL,
  warehouse_id uuid NOT NULL,
  zone   text NOT NULL CHECK (zone ~ '^[0-9A-Z]{1,3}$'),       -- khu: A, B, C, 2, 5…
  kind   text NOT NULL CHECK (kind IN ('TANK','JAR','DRUM')),   -- bồn / trái / phuy
  no     text CHECK (no ~ '^[1-9][0-9]{0,3}$'),                 -- số; NULL được với trái / phuy
  code   text GENERATED ALWAYS AS (
           zone || '.' || CASE kind WHEN 'TANK' THEN coalesce(no, '')
                                    WHEN 'JAR'  THEN 'Trái' || coalesce('.' || no, '')
                                    ELSE 'Phuy' || coalesce('.' || no, '') END) STORED,
  capacity_qty numeric(20,6) CHECK (capacity_qty > 0),          -- sức chứa (ĐVT chính); NULL = chưa khai
  active boolean NOT NULL DEFAULT true,                          -- ngừng dùng thay vì xoá
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, warehouse_id, code),
  UNIQUE (tenant_id, id, warehouse_id),                          -- cho FK kép (vị trí thuộc đúng kho)
  CHECK (kind <> 'TANK' OR no IS NOT NULL),                      -- "A." thiếu số bị chặn
  FOREIGN KEY (tenant_id, company_id)   REFERENCES core.companies (tenant_id, id),
  FOREIGN KEY (tenant_id, warehouse_id) REFERENCES md.warehouses (tenant_id, id)
);

ALTER TABLE md.items
  ADD COLUMN track_location boolean NOT NULL DEFAULT false,      -- dòng kho tại kho có vị trí phải ghi vị trí
  ADD COLUMN min_stock_qty  numeric(20,6) NOT NULL DEFAULT 0 CHECK (min_stock_qty >= 0),
  ADD COLUMN misa_code      text;
CREATE UNIQUE INDEX items_misa_code_uq ON md.items (tenant_id, company_id, misa_code) WHERE misa_code IS NOT NULL;

ALTER TABLE inv.lots ADD COLUMN lot_code text;                   -- mã hóa; NOT NULL sau khi cấp cho lô cũ
ALTER TABLE inv.lots ALTER COLUMN lot_code SET NOT NULL;
ALTER TABLE inv.lots ADD CONSTRAINT lots_code_uq UNIQUE (tenant_id, company_id, lot_code);

CREATE TABLE inv.lot_code_counters (
  tenant_id uuid NOT NULL, company_id uuid NOT NULL,
  prefix text NOT NULL CHECK (prefix ~ '^[A-Z]{2,3}$'), yymm char(4) NOT NULL CHECK (yymm ~ '^[0-9]{4}$'),
  last_no int NOT NULL DEFAULT 0 CHECK (last_no BETWEEN 0 AND 9999),
  PRIMARY KEY (tenant_id, company_id, prefix, yymm),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id)
);

-- Cấp mã hóa trong transaction tạo lô; khoá dòng bộ đếm nên hai phiên không nhận trùng số
CREATE FUNCTION inv.next_lot_code(p_tenant uuid, p_company uuid, p_prefix text, p_date date)
RETURNS text LANGUAGE plpgsql AS $$
DECLARE v_yymm char(4) := to_char(p_date, 'YYMM'); v_no int;
BEGIN
  INSERT INTO inv.lot_code_counters (tenant_id, company_id, prefix, yymm) VALUES (p_tenant, p_company, p_prefix, v_yymm)
    ON CONFLICT DO NOTHING;
  UPDATE inv.lot_code_counters SET last_no = last_no + 1
   WHERE tenant_id = p_tenant AND company_id = p_company AND prefix = p_prefix AND yymm = v_yymm
   RETURNING last_no INTO v_no;
  RETURN p_prefix || '-' || v_yymm || '-' || lpad(v_no::text, 4, '0');
END $$;

-- Mã hóa bất biến
CREATE FUNCTION inv.guard_lot_code() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.lot_code IS DISTINCT FROM OLD.lot_code THEN
    RAISE EXCEPTION 'Mã hóa của lô % không được sửa', OLD.lot_no USING ERRCODE = '55000';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER lots_code_immutable BEFORE UPDATE OF lot_code ON inv.lots
  FOR EACH ROW EXECUTE FUNCTION inv.guard_lot_code();

ALTER TABLE inv.stock_moves
  ADD COLUMN location_id uuid,
  ADD CONSTRAINT sm_location_fk FOREIGN KEY (tenant_id, location_id, warehouse_id)
    REFERENCES inv.storage_locations (tenant_id, id, warehouse_id);   -- MATCH SIMPLE: NULL = không theo vị trí
ALTER TABLE inv.stock_ledger
  ADD COLUMN location_id uuid,
  ADD CONSTRAINT sle_location_fk FOREIGN KEY (tenant_id, location_id, warehouse_id)
    REFERENCES inv.storage_locations (tenant_id, id, warehouse_id);
ALTER TABLE inv.stock_balances ADD COLUMN location_id uuid;
ALTER TABLE inv.stock_balances DROP CONSTRAINT stock_balances_tenant_id_item_id_warehouse_id_lot_id_key;
ALTER TABLE inv.stock_balances ADD CONSTRAINT stock_balances_key
  UNIQUE NULLS NOT DISTINCT (tenant_id, item_id, warehouse_id, lot_id, location_id);
-- thay sle_phys_time của 05 §4.7: kiểm âm theo (item, warehouse, lot, location)
DROP INDEX IF EXISTS inv.sle_phys_time;
CREATE INDEX sle_phys_time ON inv.stock_ledger
  (tenant_id, item_id, warehouse_id, lot_id, location_id, posting_date, posting_time, kind_rank, seq) WHERE NOT is_cancelled;

-- Hàng theo vị trí: dòng kho tại kho có danh mục vị trí phải ghi vị trí
CREATE FUNCTION inv.guard_move_location() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.location_id IS NULL
     AND (SELECT track_location FROM md.items WHERE tenant_id = NEW.tenant_id AND id = NEW.item_id)
     AND EXISTS (SELECT 1 FROM inv.storage_locations
                  WHERE tenant_id = NEW.tenant_id AND warehouse_id = NEW.warehouse_id AND active) THEN
    RAISE EXCEPTION 'Vật tư % tại kho % theo vị trí: dòng kho bắt buộc có bồn / trái / phuy', NEW.item_id, NEW.warehouse_id
      USING ERRCODE = '23502';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER stock_moves_location_guard BEFORE INSERT ON inv.stock_moves
  FOR EACH ROW EXECUTE FUNCTION inv.guard_move_location();
```

Truy vấn kiểm âm của 05 §4.7 thêm một điều kiện, vẫn chạy sau khi giữ khoá cost key:

```sql
WHERE tenant_id = $1 AND item_id = $2 AND warehouse_id = $3
  AND lot_id IS NOT DISTINCT FROM $4 AND location_id IS NOT DISTINCT FROM $9 AND NOT is_cancelled
```

Bảng mới nằm trong schema `inv` và có `tenant_id`, nên khối RLS ở §11 tự bật `ENABLE` + `FORCE` + policy `tenant_isolation` cho `inv.storage_locations` và `inv.lot_code_counters`. Không FK nào dùng `CASCADE`; vị trí không xoá được khi đã có dòng kho (FK `RESTRICT` mặc định), chỉ đặt `active = false`.

Bất biến bổ sung (property test Phase 0, đã có trong `selfTest` của demo): Σ SL theo vị trí của một `(item, warehouse, lot)` = SL của cost key; chuyển vị trí cùng kho không đổi giá trị cost key; mã hóa duy nhất, không đổi sau chuyển kho.

Phép thử đã chạy (PG16, vai trò không phải superuser):

| Thử | Mong đợi | Kết quả |
|---|---|---|
| Thêm bồn `A` không số; thêm `A.15` hai lần cùng kho | Vi phạm CHECK / UNIQUE | Đạt |
| `code` sinh ra cho (A, TANK, 15), (5, JAR, NULL), (B, DRUM, NULL) | `A.15`, `5.Trái`, `B.Phuy` | Đạt |
| Dòng kho gắn vị trí của kho khác | Vi phạm FK kép | Đạt |
| Vật tư `track_location` nhập vào kho có vị trí mà không ghi vị trí; nhập vào kho chưa có danh mục vị trí | Lỗi 23502 / thành công | Đạt |
| `inv.next_lot_code` gọi 3 lần cùng tháng, 1 lần tháng sau | `BTP-2601-0001..0003`, `BTP-2602-0001` | Đạt |
| Sửa `lot_code` của lô; tạo lô trùng `lot_code` | Lỗi 55000 / vi phạm UNIQUE | Đạt |
| Hai dòng `stock_balances` cùng (item, kho, lô) khác vị trí; trùng cả vị trí NULL | Thành công / vi phạm UNIQUE | Đạt |
| Đọc `inv.storage_locations` của tenant khác | 0 dòng | Đạt |

Chưa thử: hai phiên đồng thời gọi `inv.next_lot_code` (dựa vào khoá dòng của `UPDATE`), hiệu năng truy vấn kiểm âm với khoá 5 cột.

---

## 3. Quy trình, công đoạn, lệnh SX công đoạn

### 3.1 Mô hình

- `mfg.routings` → `mfg.routing_stages` (**giai đoạn tính giá**, có SP đầu ra, cách xử lý BTP, cờ nhiều kỳ, tỷ lệ không đạt trong định mức, tiêu thức SXC, khu) → `mfg.routing_operations` (ô trong sơ đồ khách: thao tác, điểm QC, có sinh lô hay không). Ánh xạ 4 quy trình khách ở `../YEU-CAU-KHACH-HANG.md` §4.
- `mfg.production_orders` (05) thêm: `routing_stage_id` (lệnh công đoạn) hoặc NULL (lệnh tổng theo kế hoạch ngày), `plan_order_id`, `work_area_id`, `wip_warehouse_id` (kho/khu nơi lô đang ủ), `fiscal_year`; số lệnh duy nhất theo năm.
- Mỗi lệnh công đoạn vẫn trỏ tới một `mfg.cost_objects` (05) — đối tượng tập hợp chi phí. Đối tượng "công đoạn × sản phẩm" mà báo cáo cần = **tổng các lệnh** cùng `(routing_stage, output_item)` trong kỳ; không tạo đối tượng riêng.
- `mfg.stage_outputs`: đầu ra theo lô của lệnh, kèm SL đạt, SL không đạt trong/ngoài định mức, phế liệu/phụ phẩm và giá trị ước tính.
- `mfg.order_cost_sheets`: giá thành lệnh theo **kỳ × khoản mục** `DM` (NVL), `SEMI` (BTP giai đoạn trước), `DL` (nhân công), `MOH` (SXC); CHECK cân `DDĐK + PS − phế liệu − hỏng ngoài định mức − DDCK − chuyển ra = 0` và CHECK khoản mục (sửa 06b-N1 cho bảng mới).

### 3.2 DDL

```sql
CREATE TABLE mfg.routings (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, code text NOT NULL, name text NOT NULL,
  valid_from date NOT NULL, valid_to date,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, code),
  CHECK (valid_to IS NULL OR valid_to >= valid_from),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id)
);

CREATE TABLE mfg.routing_stages (           -- giai đoạn tính giá
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  routing_id uuid NOT NULL, stage_no smallint NOT NULL CHECK (stage_no >= 0),
  code text NOT NULL, name text NOT NULL,
  output_item_id uuid,                      -- BTP/TP đầu ra; NULL = giai đoạn tiếp nhận
  semi_handling text NOT NULL DEFAULT 'STOCKED'
    CHECK (semi_handling IN ('STOCKED','DIRECT')),   -- BTP có lô nằm chờ / chuyển thẳng 154 (§4.2)
  is_multi_period boolean NOT NULL DEFAULT false,    -- công đoạn ủ có thể kéo qua nhiều kỳ
  normal_reject_pct numeric(7,4) NOT NULL DEFAULT 0
    CHECK (normal_reject_pct >= 0 AND normal_reject_pct <= 100),
  overhead_basis text NOT NULL DEFAULT 'QTY_DAYS'
    CHECK (overhead_basis IN ('QTY_DAYS','OUTPUT_QTY','LABOR_HOURS','MANUAL')),
  work_area_id uuid,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, routing_id, stage_no),
  FOREIGN KEY (tenant_id, routing_id) REFERENCES mfg.routings (tenant_id, id),
  FOREIGN KEY (tenant_id, output_item_id) REFERENCES md.items (tenant_id, id),
  FOREIGN KEY (tenant_id, work_area_id) REFERENCES md.work_areas (tenant_id, id)
);

CREATE TABLE mfg.routing_operations (       -- thao tác trong giai đoạn (ô trong sơ đồ của khách)
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  stage_id uuid NOT NULL, op_no smallint NOT NULL, name text NOT NULL,
  creates_lot boolean NOT NULL DEFAULT false,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, stage_id, op_no),
  FOREIGN KEY (tenant_id, stage_id) REFERENCES mfg.routing_stages (tenant_id, id)
);

ALTER TABLE mfg.production_orders
  ADD COLUMN fiscal_year smallint,
  ADD COLUMN plan_order_id uuid,            -- lệnh tổng (kế hoạch ngày)
  ADD COLUMN routing_stage_id uuid,         -- NULL = lệnh tổng
  ADD COLUMN work_area_id uuid,
  ADD COLUMN wip_warehouse_id uuid,         -- kho/khu xưởng nơi lô đang ủ/đang làm
  ADD CONSTRAINT po_plan_fk  FOREIGN KEY (tenant_id, plan_order_id) REFERENCES mfg.production_orders (tenant_id, id),
  ADD CONSTRAINT po_stage_fk FOREIGN KEY (tenant_id, routing_stage_id) REFERENCES mfg.routing_stages (tenant_id, id),
  ADD CONSTRAINT po_area_fk  FOREIGN KEY (tenant_id, work_area_id) REFERENCES md.work_areas (tenant_id, id),
  ADD CONSTRAINT po_wh_fk    FOREIGN KEY (tenant_id, wip_warehouse_id) REFERENCES md.warehouses (tenant_id, id);
ALTER TABLE mfg.production_orders DROP CONSTRAINT production_orders_tenant_id_company_id_order_no_key;
ALTER TABLE mfg.production_orders ALTER COLUMN fiscal_year SET NOT NULL;
ALTER TABLE mfg.production_orders ADD CONSTRAINT po_no_uq UNIQUE (tenant_id, company_id, fiscal_year, order_no);

CREATE TABLE mfg.stage_outputs (            -- đầu ra của lệnh công đoạn theo lô, kèm kết quả QC
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  production_order_id uuid NOT NULL,
  output_lot_id uuid NOT NULL,
  output_kind text NOT NULL CHECK (output_kind IN ('MAIN','BYPRODUCT','SCRAP')),
  qty_good numeric(20,6) NOT NULL DEFAULT 0 CHECK (qty_good >= 0),
  qty_reject_normal numeric(20,6) NOT NULL DEFAULT 0 CHECK (qty_reject_normal >= 0),
  qty_reject_abnormal numeric(20,6) NOT NULL DEFAULT 0 CHECK (qty_reject_abnormal >= 0),
  byproduct_value numeric(20,2) CHECK (byproduct_value >= 0),   -- giá trị ước tính phế liệu/phụ phẩm
  CHECK (output_kind = 'MAIN' OR byproduct_value IS NOT NULL),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, production_order_id, output_lot_id),
  FOREIGN KEY (tenant_id, production_order_id) REFERENCES mfg.production_orders (tenant_id, id),
  FOREIGN KEY (tenant_id, output_lot_id) REFERENCES inv.lots (tenant_id, id)
);

CREATE TABLE mfg.order_cost_sheets (        -- giá thành lệnh công đoạn theo kỳ × khoản mục
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  costing_run_id uuid NOT NULL, production_order_id uuid NOT NULL,
  cost_element text NOT NULL CHECK (cost_element IN ('DM','SEMI','DL','MOH')),  -- SEMI = BTP giai đoạn trước
  wip_opening numeric(20,2) NOT NULL DEFAULT 0,
  incurred numeric(20,2) NOT NULL DEFAULT 0,
  byproduct_deduction numeric(20,2) NOT NULL DEFAULT 0,
  abnormal_loss numeric(20,2) NOT NULL DEFAULT 0,     -- → 632/811/1388 theo quyết định xử lý
  wip_closing numeric(20,2) NOT NULL DEFAULT 0,
  to_output numeric(20,2) NOT NULL DEFAULT 0,         -- chuyển vào lô BTP/TP
  CHECK (wip_opening + incurred - byproduct_deduction - abnormal_loss - wip_closing - to_output = 0),
  CHECK (wip_closing >= 0 AND to_output >= 0 AND abnormal_loss >= 0),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, costing_run_id, production_order_id, cost_element),
  FOREIGN KEY (tenant_id, costing_run_id) REFERENCES mfg.costing_runs (tenant_id, id),
  FOREIGN KEY (tenant_id, production_order_id) REFERENCES mfg.production_orders (tenant_id, id)
);
```

---

## 4. Giá thành phân bước có BTP, đích danh theo lô

### 4.1 Tính một lệnh trong một kỳ

```
DDĐK(lệnh, khoản mục)      = DDCK kỳ trước (0 nếu lệnh mới)
PS kỳ:
  DM   = Σ giá trị lô NVL xuất cho lệnh (đích danh)            ← 621 / 154-NVL
  SEMI = Σ giá trị lô BTP giai đoạn trước xuất cho lệnh        ← xem §4.2
  DL   = nhân công trực tiếp ghi cho lệnh + phần phân bổ        ← 622 / 154-NC
  MOH  = phần SXC phân bổ cho lệnh (§4.3)                       ← 627 / 154-SXC
Lệnh chưa xong cuối kỳ:  DDCK = DDĐK + PS (toàn bộ), chuyển ra = 0
Lệnh xong trong kỳ:
  C   = DDĐK + PS − giá trị phế liệu/phụ phẩm thu hồi
  SL không đạt trong định mức tối đa = normal_reject_pct × (SL đạt + SL không đạt)
  SL ngoài định mức = phần SL không đạt vượt mức trên
  Chia C theo R1(b) với trọng số (SL đạt từng lô đầu ra, SL ngoài định mức)
    → phần lô đạt = giá trị nhập kho lô BTP/TP; phần ngoài định mức = abnormal_loss
  SL không đạt trong định mức không nhận giá trị (giá trị dồn vào SL đạt)
```

Ví dụ (giả định, chưa có số thật của khách): lệnh **ủ muối** lô cá 1.000 kg mở tháng 10, kết thúc tháng 11.

| Kỳ | DDĐK | PS | DDCK | Chuyển ra |
|---|---|---|---|---|
| Tháng 10 | 0 | NVL cá 50.000.000 + muối 2.000.000 + NC 3.000.000 + SXC 1.500.000 = 56.500.000 | 56.500.000 | 0 |
| Tháng 11 | 56.500.000 | NC 500.000 + SXC 1.200.000 = 1.700.000 | 0 | xem dưới |

Tháng 11: C = 58.200.000; đầu ra 800 kg đạt, 30 kg không đạt; định mức không đạt 2% → được phép 2% × 830 = 16,6 kg; ngoài định mức 13,4 kg. Chia 58.200.000 theo trọng số 800 : 13,4 (R1(b)): phần nguyên 57.241.209 và 958.790, thiếu 1 đồng cộng cho phần có phần lẻ lớn hơn (0,7369 > 0,2631) → **lô BTP đạt 57.241.210**, **hỏng ngoài định mức 958.790** (Nợ 632 hoặc 811/1388 / Có 154). Đơn giá hiển thị 71.551,5125 đ/kg (chỉ để xem, theo R1(a)).

Kiểm tra tổng: 57.241.210 + 958.790 = 58.200.000. Mọi phép chia theo khoản mục làm riêng từng khoản mục rồi cộng.

### 4.2 BTP: nhập kho có lô hay chuyển thẳng 154 giai đoạn sau

| | Phương án A — `STOCKED` | Phương án B — `DIRECT` |
|---|---|---|
| Cách làm | Hoàn thành lệnh → phiếu nhập BTP (sinh tự động) vào kho/khu xưởng, có lô và sổ kho. Lệnh sau xuất đích danh lô BTP | Hoàn thành lệnh → bút toán chuyển chi phí Nợ 154 (lệnh sau) / Có 154 (lệnh trước). Lô BTP có mã nhưng **không có sổ kho** |
| Bút toán nhập BTP | Nợ [TK BTP] / Có 154 (lệnh trước). [TK BTP] là **155 chi tiết BTP hay 154 chi tiết "BTP chờ"**: **chưa xác minh**, KTT chọn (B4) | — |
| Bút toán xuất BTP cho giai đoạn sau | Nợ 154 (lệnh sau, khoản mục `SEMI`) / Có [TK BTP]. Có DN ghi qua 621 thay vì thẳng 154 — **chưa xác minh**, cấu hình bằng role `WIP_SEMI` | Như trên, không qua kho |
| Lô ủ qua tháng, chờ phối trộn | Thấy được trên tồn kho, kiểm kê được, chặn QC bằng trạng thái lô | Chỉ thấy trên bảng lệnh; không kiểm kê bằng sổ kho |
| Chặn QC, truy xuất | Dùng chung cơ chế lô (§2.5, §2.6) | Phải có đường riêng qua `stage_outputs` |
| Số chứng từ | Nhiều hơn (sinh tự động) | Ít hơn |
| Bất biến K1 | Nếu [TK BTP] = 154 thì K1 phải hiểu "Σ tồn kho BTP + Σ DDCK lệnh = số dư 154" | Σ DDCK lệnh + chi phí đang chuyển = số dư 154 |

**Khuyến nghị**: A là mặc định cho mọi BTP có thể nằm chờ (sau ủ muối, ủ thính, ủ chượp, ủ đường, sau phối trộn) — tức phần lớn các giai đoạn của khách; B chỉ cho BTP làm xong và dùng ngay trong ca (cá chiên, sốt cà của quy trình cá bạc má). Cấu hình theo giai đoạn (`routing_stages.semi_handling`), hai phương án dùng chung engine vì cả hai chỉ khác cách chuyển giá trị sang lệnh sau.

### 4.3 Phân bổ chi phí chung cho lệnh đang ủ

Lệnh ủ chiếm chỗ (bể, kho, nhân công trông coi) theo khối lượng và thời gian, nên tiêu thức đề xuất là **khối lượng × số ngày lệnh mở trong kỳ** (`QTY_DAYS`); lệnh không ủ dùng SL đầu ra hoặc giờ công. Ví dụ (giả định): SXC tháng 9.000.000; lệnh A 1.000 kg × 31 ngày, B 600 kg × 15 ngày, C 400 kg × 10 ngày → trọng số 31.000 : 9.000 : 4.000. R1(b): phần nguyên 6.340.909 / 1.840.909 / 818.181, thiếu 1 đồng cộng cho C (phần lẻ 0,8182 lớn nhất) → **6.340.909 / 1.840.909 / 818.182**. Tiêu thức thật: câu hỏi B3.

SXC cố định dưới công suất bình thường (VAS 02) giữ nguyên thiết kế 05 (`mfg.normal_capacity`), mặc định **tắt** cho đến khi khách trả lời B11.

### 4.4 Dở dang nhiều kỳ

- Lệnh mở qua kỳ: DDCK = toàn bộ chi phí luỹ kế; không cần SL dở dang và % hoàn thành (khác 05 §5.8 bước 3).
- Mỗi tháng một `costing_run`; lệnh đã có bảng giá thành ở kỳ đã khoá thì kỳ sau lấy DDCK đó làm DDĐK, không tính lại.
- Một lệnh chỉ hoàn thành một lần (giả định). Nếu khách rút một phần bể ủ trong khi phần còn lại tiếp tục ủ → tách lệnh (chia chi phí luỹ kế theo khối lượng, R1(b)) rồi hoàn thành phần rút.

### 4.5 Thẻ tính giá thành theo lô TP

Thẻ của lô TP = bảng giá thành lệnh tạo ra lô đó + đệ quy theo phả hệ (§2.6) xuống các lệnh tạo lô BTP đầu vào, mỗi tầng theo tỷ lệ giá trị lô đầu vào thực dùng / giá trị lô. Khoản mục `SEMI` của tầng trên được nổ ra thành DM/DL/MOH của tầng dưới theo tỷ lệ, giống đồ thị dòng chi phí của 05 §6 (`cst.cost_flow_edges`, `cst.product_cost_trace`). Hạn chế phải nói với khách: khi một lô BTP cấp cho nhiều lệnh, phần NC/SXC của lô đó chia **theo tỷ lệ**, không đích danh.

### 4.6 Hàng không đạt QC

| Thời điểm phát hiện | Trong định mức | Ngoài định mức |
|---|---|---|
| Trong lệnh (gồm kiểm tra sau bảo ôn của cá hộp, nếu bảo ôn nằm trong lệnh) | Không bút toán riêng; SL đạt gánh chi phí | `abnormal_loss` → Nợ 632 / 811 / 1388 / Có 154 theo quyết định xử lý |
| Tiếp nhận NVL | — | Lô `REJECTED`: trả NCC (MUA-03) hoặc huỷ |
| Sau khi đã nhập kho (BTP/TP) | Hao hụt trong định mức lưu kho: Nợ 632 / Có 15x (như kiểm kê thiếu trong định mức) | Xuất huỷ lô: Nợ 632 / 811 / 1388 / Có 155/156 |

Khuyến nghị cho quy trình cá bạc má: đặt "đóng gói – tiệt trùng – bảo ôn – kiểm tra" trong **một lệnh** (có thể kéo qua tháng) để hàng loại bỏ sau kiểm tra vẫn là chi phí SX của lệnh, khớp sơ đồ khách (nhánh Không đạt → Loại bỏ trước khi dán nhãn).

### 4.7 Ảnh hưởng tới quy trình khoá sổ

Thứ tự đề xuất bổ sung vào close orchestrator (05 §7.2, 01 §6 đang được sửa để kiểm kê chạy trước tính giá):

1. Chứng từ kỳ hoàn tất; phiếu QC và quyết định xử lý của kỳ đã chốt.
2. Chênh lệch kiểm kê (theo lô) ghi sổ.
3. Khấu hao, phân bổ CCDC, trích lãi vay, lương (chứng từ tổng hợp).
4. Định giá hàng mua theo lô; điều chỉnh giá trị lô.
5. Tập hợp chi phí theo lệnh; phân bổ SXC (§4.3).
6. Tính giá thành lệnh theo **thứ tự thời gian hoàn thành và theo chuỗi giai đoạn** (lệnh trước xong mới có giá lô BTP cho lệnh sau); cập nhật giá lô BTP/TP; định giá các dòng xuất lô đó.
7. Đánh giá lại ngoại tệ (độc lập với giá kho).
8. Kết chuyển 911; kiểm tra bất biến; kiểm tra mọi dòng tiền có mã dòng tiền (§9).
9. Khoá kỳ (khoá luôn tỷ giá các ngày trong kỳ).

---

## 5. Ngoại tệ

### 5.1 Dòng bút toán

- `acc.journal_lines` (05) đã có `currency, amount_fc, fx_rate`; thêm CHECK đồng bộ (cả ba cùng NULL hoặc cùng có, tỷ giá > 0), thêm `bank_account_id`, `fx_open_item_id`, `loan_contract_id`, `cash_flow_code`.
- VND của dòng = `round(amount_fc × fx_rate)` (R1(a)), **trừ** dòng ghi giảm khoản mục ngoại tệ khi tất toán: dòng đó mang **giá trị ghi sổ** của khoản mục, phần chênh lệch là dòng 515/635 riêng. Vì vậy không đặt CHECK "VND = round(nguyên tệ × tỷ giá)" ở DB.
- Chứng từ cân Nợ = Có theo VND; nguyên tệ là thông tin phụ (01 I1).

### 5.2 Tỷ giá và khoá theo ngày

- `md.exchange_rates`: theo ngày × loại (mua/bán/chuyển khoản) × ngân hàng công bố.
- `md.fx_rate_day_locks`: một ngày bị khoá khi (a) chứng từ đầu tiên dùng tỷ giá của ngày được ghi sổ, (b) kỳ chứa ngày bị khoá, hoặc (c) KTT khoá tay. Trigger chặn INSERT/UPDATE/DELETE tỷ giá của ngày đã khoá. Chứng từ luôn **chép** tỷ giá vào dòng, nên khoá ngày là để báo cáo và đánh giá lại không lệch với chứng từ, không phải để chứng từ đọc lại tỷ giá.

### 5.3 Khoản mục mở và tất toán

- Mỗi dòng bút toán tạo công nợ/khoản vay bằng ngoại tệ sinh một `acc.fx_open_items` (tỷ giá ghi sổ **đích danh** theo chứng từ gốc). Khoản ứng trước đánh dấu `is_monetary = false` (không đánh giá lại; khi cấn trừ vào HĐ thì phần đã ứng dùng tỷ giá lúc ứng).
- Tiền ngoại tệ (1112, 1122) không theo khoản mục mà theo **bình quân gia quyền di động** của `(tài khoản, tài khoản NH, loại tiền)`, tính từ dòng bút toán dưới khoá advisory `'fx:'||tenant||account||bank_account||currency` (cùng cách khoá cost key).
- Tất toán (`acc.fx_settlements`): giảm `remaining_fc` và `remaining_base` theo tỷ giá ghi sổ; `settle_base` theo tỷ giá thanh toán (thu nợ) hoặc tỷ giá xuất quỹ (trả nợ); chênh lệch → 515 (lãi) hoặc 635 (lỗ) tuỳ phía tài sản/nợ. Khi `remaining_fc = 0` thì `remaining_base` buộc = 0 (CHECK).

Ví dụ (giả định): nhập khẩu NVL USD 10.000, tỷ giá bán ngày nhận hàng 25.400 → Nợ 152: 254.000.000 / Có 331: 254.000.000 (USD 10.000). Cuối tháng tỷ giá bán 25.500 → đánh giá lại Nợ 413: 1.000.000 / Có 331: 1.000.000; giá trị ghi sổ còn lại 255.000.000. Tháng sau trả USD 10.000 từ tài khoản USD có tỷ giá xuất quỹ 25.450 → Nợ 331: 255.000.000 / Có 1122: 254.500.000 / Có 515: 500.000.

### 5.4 Đánh giá lại cuối kỳ

- `acc.fx_revaluation_runs` (một lần/kỳ, trừ bản đã huỷ) + `acc.fx_revaluation_lines` (khoản mục mở có `is_monetary`, và số dư tiền ngoại tệ theo tài khoản NH). `new_base = round(balance_fc × rate)`; `diff` là cột sinh.
- Bút toán: Nợ/Có TK khoản mục ↔ 413; sau đó kết chuyển số dư thuần 413 sang 515/635 (chứng từ hệ thống `FX_REVALUATION`). Cập nhật `remaining_base` của khoản mục mở = giá trị sau đánh giá lại, để lần tất toán sau tính chênh lệch từ đó.
- Tần suất (tháng hay chỉ cuối năm), có đảo bút toán đầu kỳ sau hay không: **chưa xác minh với TT99/TT133**, chờ KTT (A5). Nếu chọn đảo thì không cập nhật `remaining_base` mà sinh bút toán đảo ngày đầu kỳ sau — engine hỗ trợ cả hai bằng cờ cấu hình.

### 5.5 DDL

```sql
CREATE TABLE sys.currencies (               -- dữ liệu hệ thống, không thuộc tenant (ngoại lệ test tenant_id)
  code char(3) PRIMARY KEY CHECK (code ~ '^[A-Z]{3}$'),
  name text NOT NULL,
  minor_units smallint NOT NULL CHECK (minor_units BETWEEN 0 AND 4)
);

CREATE TABLE md.exchange_rates (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  currency char(3) NOT NULL REFERENCES sys.currencies (code),
  rate_date date NOT NULL,
  rate_type text NOT NULL CHECK (rate_type IN ('BUY','SELL','TRANSFER')),
  bank_partner_id uuid,                     -- ngân hàng công bố; NULL = tỷ giá chung
  rate numeric(18,6) NOT NULL CHECK (rate > 0),
  PRIMARY KEY (tenant_id, id),
  UNIQUE NULLS NOT DISTINCT (tenant_id, company_id, currency, rate_date, rate_type, bank_partner_id),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id),
  FOREIGN KEY (tenant_id, bank_partner_id) REFERENCES md.partners (tenant_id, id)
);

CREATE TABLE md.fx_rate_day_locks (         -- khoá tỷ giá theo ngày
  tenant_id uuid NOT NULL, company_id uuid NOT NULL, rate_date date NOT NULL,
  locked_by uuid NOT NULL, locked_at timestamptz NOT NULL DEFAULT now(),
  reason text NOT NULL CHECK (reason IN ('POSTED_USAGE','PERIOD_LOCK','MANUAL')),
  PRIMARY KEY (tenant_id, company_id, rate_date),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id)
);

CREATE FUNCTION md.guard_fx_rate_lock() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_row md.exchange_rates;
BEGIN
  FOREACH v_row IN ARRAY ARRAY[NEW, OLD] LOOP
    CONTINUE WHEN v_row IS NULL;
    PERFORM 1 FROM md.fx_rate_day_locks k
     WHERE k.tenant_id = v_row.tenant_id AND k.company_id = v_row.company_id
       AND k.rate_date = v_row.rate_date
     FOR SHARE;
    IF FOUND THEN
      RAISE EXCEPTION 'Tỷ giá ngày % đã khoá', v_row.rate_date USING ERRCODE = '55000';
    END IF;
  END LOOP;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER exchange_rates_lock BEFORE INSERT OR UPDATE OR DELETE ON md.exchange_rates
  FOR EACH ROW EXECUTE FUNCTION md.guard_fx_rate_lock();

ALTER TABLE acc.journal_lines
  ADD COLUMN bank_account_id uuid,
  ADD COLUMN fx_open_item_id uuid,
  ADD COLUMN loan_contract_id uuid,
  ADD COLUMN cash_flow_code text,
  ADD CONSTRAINT jl_fx_consistent CHECK (
        (currency IS NULL AND amount_fc IS NULL AND fx_rate IS NULL)
     OR (currency IS NOT NULL AND amount_fc IS NOT NULL AND amount_fc >= 0
         AND fx_rate IS NOT NULL AND fx_rate > 0));

CREATE TABLE acc.fx_open_items (            -- khoản mục ngoại tệ theo chứng từ gốc (tỷ giá ghi sổ đích danh)
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, account_id uuid NOT NULL, partner_id uuid,
  loan_contract_id uuid,
  currency char(3) NOT NULL REFERENCES sys.currencies (code),
  side text NOT NULL CHECK (side IN ('ASSET','LIABILITY')),
  is_monetary boolean NOT NULL,             -- false = khoản ứng trước: không đánh giá lại
  origin_journal_line_id uuid NOT NULL, origin_date date NOT NULL,
  amount_fc numeric(20,2) NOT NULL CHECK (amount_fc > 0),
  remaining_fc numeric(20,2) NOT NULL,
  remaining_base numeric(20,2) NOT NULL,    -- giá trị ghi sổ còn lại (sau đánh giá lại gần nhất)
  status text NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','CLOSED')),
  CHECK (remaining_fc >= 0 AND remaining_fc <= amount_fc),
  CHECK ((status = 'CLOSED') = (remaining_fc = 0)),
  CHECK (remaining_fc > 0 OR remaining_base = 0),     -- hết nguyên tệ thì hết giá trị VND
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id),
  FOREIGN KEY (tenant_id, account_id) REFERENCES md.accounts (tenant_id, id),
  FOREIGN KEY (tenant_id, partner_id) REFERENCES md.partners (tenant_id, id),
  FOREIGN KEY (tenant_id, origin_journal_line_id) REFERENCES acc.journal_lines (tenant_id, id)
);

CREATE TABLE acc.fx_settlements (           -- tất toán một phần/toàn bộ khoản mục ngoại tệ
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  open_item_id uuid NOT NULL, settling_journal_line_id uuid NOT NULL,
  settle_date date NOT NULL,
  amount_fc numeric(20,2) NOT NULL CHECK (amount_fc > 0),
  book_base numeric(20,2) NOT NULL,         -- giá trị ghi sổ được xoá (theo tỷ giá ghi sổ)
  settle_base numeric(20,2) NOT NULL,       -- giá trị theo tỷ giá thanh toán / xuất quỹ
  realized_diff numeric(20,2) GENERATED ALWAYS AS (settle_base - book_base) STORED,
                                            -- dấu theo phía: hệ thống sinh 515/635 tương ứng
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, open_item_id) REFERENCES acc.fx_open_items (tenant_id, id),
  FOREIGN KEY (tenant_id, settling_journal_line_id) REFERENCES acc.journal_lines (tenant_id, id)
);

CREATE TABLE acc.fx_revaluation_runs (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, fiscal_period_id uuid NOT NULL, reval_date date NOT NULL,
  document_id uuid,                         -- chứng từ hệ thống 'FX_REVALUATION'
  status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','POSTED','VOIDED')),
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, fiscal_period_id) REFERENCES acc.fiscal_periods (tenant_id, id),
  FOREIGN KEY (tenant_id, document_id) REFERENCES acc.documents (tenant_id, id)
);
CREATE UNIQUE INDEX fx_reval_one_per_period ON acc.fx_revaluation_runs (tenant_id, company_id, fiscal_period_id)
  WHERE status <> 'VOIDED';

CREATE TABLE acc.fx_revaluation_lines (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  run_id uuid NOT NULL,
  open_item_id uuid,                        -- công nợ/khế ước; NULL với tiền (theo tài khoản)
  account_id uuid NOT NULL, bank_account_id uuid,
  currency char(3) NOT NULL REFERENCES sys.currencies (code),
  balance_fc numeric(20,2) NOT NULL,
  book_base numeric(20,2) NOT NULL,
  rate_id uuid NOT NULL,                    -- tỷ giá áp dụng (mua/bán tuỳ phía)
  new_base numeric(20,2) NOT NULL,          -- round(balance_fc × rate) theo R1(a)
  diff numeric(20,2) GENERATED ALWAYS AS (new_base - book_base) STORED,
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, run_id) REFERENCES acc.fx_revaluation_runs (tenant_id, id),
  FOREIGN KEY (tenant_id, open_item_id) REFERENCES acc.fx_open_items (tenant_id, id),
  FOREIGN KEY (tenant_id, rate_id) REFERENCES md.exchange_rates (tenant_id, id)
);
CREATE TRIGGER fx_reval_lines_guard BEFORE INSERT OR UPDATE OR DELETE ON acc.fx_revaluation_lines
  FOR EACH ROW EXECUTE FUNCTION app.guard_child_rows('acc.fx_revaluation_runs', 'run_id', '{POSTED,VOIDED}');
CREATE TRIGGER fx_reval_runs_status BEFORE UPDATE OR DELETE ON acc.fx_revaluation_runs
  FOR EACH ROW EXECUTE FUNCTION app.guard_header_status('DRAFT', '{DRAFT>POSTED,DRAFT>VOIDED,POSTED>VOIDED}');
```

Bất biến thêm (property test + kiểm khi khoá sổ): với mỗi TK theo dõi khoản mục ngoại tệ, Σ `remaining_base` = số dư sổ cái phần ngoại tệ của TK đó; Σ `remaining_fc` = số dư nguyên tệ.

---

## 6. TSCĐ và CCDC

- Một bảng `ast.assets` cho cả TSCĐ (`FA_TANGIBLE`, `FA_INTANGIBLE`) và CCDC (`TOOL`, theo số lượng). Khác nhau ở TK: TSCĐ có TK nguyên giá + TK hao mòn; CCDC có TK 242 và không có TK hao mòn (CHECK).
- `ast.asset_usages`: bộ phận/khu, địa điểm, TK chi phí, đối tượng tập hợp chi phí, tỷ lệ — có hiệu lực theo ngày. **Điều chuyển** = đóng dòng cũ, mở dòng mới (không bút toán).
- `ast.asset_events`: ghi tăng, điều chỉnh, điều chuyển, ghi giảm — mỗi sự kiện gắn một chứng từ `acc.documents` (loại `FA_INCREASE`, `FA_ADJUST`, `FA_TRANSFER`, `FA_DECREASE`, `TOOL_*`) để dùng chung số CT, khoá kỳ, nhật ký.
- `ast.depreciation_runs` + `ast.depreciation_lines`: một lần/kỳ/loại. Khấu hao đường thẳng; mức tháng = round((nguyên giá − HMLK) / số tháng còn lại) (R1(a)), tháng cuối nhận toàn bộ phần còn lại; nếu tính theo ngày thì nhân số ngày sử dụng / số ngày của tháng (câu hỏi C1). Chia cho các `asset_usages` hiệu lực trong tháng theo R1(b) với trọng số `share_pct × days_in_use`. Bút toán: Nợ TK chi phí (627/641/642; TT133: 154/6421/6422) / Có 214 (TSCĐ) hoặc Có 242 (CCDC).
- Ghi giảm: chạy khấu hao đến ngày ghi giảm rồi mới ghi giảm; bút toán theo `../YEU-CAU-KHACH-HANG.md` TSCD-06, CCDC-06.

```sql
CREATE TABLE ast.assets (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, code text NOT NULL, name text NOT NULL,
  asset_kind text NOT NULL CHECK (asset_kind IN ('FA_TANGIBLE','FA_INTANGIBLE','TOOL')),
  qty numeric(20,6) NOT NULL DEFAULT 1 CHECK (qty >= 0),        -- CCDC theo số lượng; TSCĐ = 1
  cost_account_id uuid NOT NULL,            -- 211/213 (TSCĐ) hoặc 242 (CCDC chờ phân bổ)
  accum_account_id uuid,                    -- 214; NULL với CCDC
  original_cost numeric(20,2) NOT NULL CHECK (original_cost >= 0),
  opening_accum numeric(20,2) NOT NULL DEFAULT 0 CHECK (opening_accum >= 0),  -- HMLK/đã phân bổ khi chuyển đổi
  start_date date NOT NULL,                 -- bắt đầu khấu hao / phân bổ
  useful_life_months int NOT NULL CHECK (useful_life_months > 0),
  method text NOT NULL DEFAULT 'STRAIGHT_LINE' CHECK (method IN ('STRAIGHT_LINE')),
  status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','ACTIVE','DISPOSED')),
  CHECK (opening_accum <= original_cost),
  CHECK ((asset_kind = 'TOOL') = (accum_account_id IS NULL)),
  CHECK (asset_kind = 'TOOL' OR qty = 1),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, code),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id),
  FOREIGN KEY (tenant_id, cost_account_id) REFERENCES md.accounts (tenant_id, id),
  FOREIGN KEY (tenant_id, accum_account_id) REFERENCES md.accounts (tenant_id, id)
);

CREATE TABLE ast.asset_usages (             -- bộ phận/đối tượng chịu chi phí, có hiệu lực theo ngày
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  asset_id uuid NOT NULL,
  valid_from date NOT NULL, valid_to date,
  work_area_id uuid, warehouse_id uuid,     -- bộ phận / địa điểm
  expense_account_id uuid NOT NULL,         -- 627/641/642 (TT133: 154/6421/6422)
  cost_object_id uuid, expense_item_id uuid,
  share_pct numeric(7,4) NOT NULL CHECK (share_pct > 0 AND share_pct <= 100),
  CHECK (valid_to IS NULL OR valid_to >= valid_from),
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, asset_id) REFERENCES ast.assets (tenant_id, id),
  FOREIGN KEY (tenant_id, work_area_id) REFERENCES md.work_areas (tenant_id, id),
  FOREIGN KEY (tenant_id, warehouse_id) REFERENCES md.warehouses (tenant_id, id),
  FOREIGN KEY (tenant_id, expense_account_id) REFERENCES md.accounts (tenant_id, id),
  FOREIGN KEY (tenant_id, cost_object_id) REFERENCES mfg.cost_objects (tenant_id, id),
  FOREIGN KEY (tenant_id, expense_item_id) REFERENCES md.expense_items (tenant_id, id)
);
-- Σ share_pct = 100 cho mọi ngày: kiểm ở tầng ứng dụng + kiểm tra trước khi chạy khấu hao

CREATE TABLE ast.asset_events (             -- ghi tăng / điều chỉnh / điều chuyển / ghi giảm
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  asset_id uuid NOT NULL,
  document_id uuid NOT NULL,                -- chứng từ acc.documents (điều chuyển: chứng từ không bút toán)
  event_type text NOT NULL CHECK (event_type IN ('INCREASE','ADJUST','TRANSFER','DECREASE')),
  event_date date NOT NULL,
  delta_cost numeric(20,2) NOT NULL DEFAULT 0,
  delta_accum numeric(20,2) NOT NULL DEFAULT 0,
  delta_qty numeric(20,6) NOT NULL DEFAULT 0,
  new_useful_life_months int CHECK (new_useful_life_months > 0),
  new_usage_id uuid,                        -- điều chuyển: dòng asset_usages mới
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, asset_id) REFERENCES ast.assets (tenant_id, id),
  FOREIGN KEY (tenant_id, document_id) REFERENCES acc.documents (tenant_id, id),
  FOREIGN KEY (tenant_id, new_usage_id) REFERENCES ast.asset_usages (tenant_id, id)
);

CREATE TABLE ast.depreciation_runs (        -- khấu hao TSCĐ / phân bổ CCDC theo kỳ
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, fiscal_period_id uuid NOT NULL,
  run_kind text NOT NULL CHECK (run_kind IN ('FA_DEPRECIATION','TOOL_ALLOCATION')),
  document_id uuid,
  status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','POSTED','VOIDED')),
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, fiscal_period_id) REFERENCES acc.fiscal_periods (tenant_id, id),
  FOREIGN KEY (tenant_id, document_id) REFERENCES acc.documents (tenant_id, id)
);
CREATE UNIQUE INDEX dep_run_one_per_period ON ast.depreciation_runs (tenant_id, company_id, fiscal_period_id, run_kind)
  WHERE status <> 'VOIDED';

CREATE TABLE ast.depreciation_lines (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  run_id uuid NOT NULL, asset_id uuid NOT NULL, usage_id uuid NOT NULL,
  days_in_use smallint NOT NULL CHECK (days_in_use >= 0),
  amount numeric(20,2) NOT NULL CHECK (amount >= 0),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, run_id, asset_id, usage_id),
  FOREIGN KEY (tenant_id, run_id) REFERENCES ast.depreciation_runs (tenant_id, id),
  FOREIGN KEY (tenant_id, asset_id) REFERENCES ast.assets (tenant_id, id),
  FOREIGN KEY (tenant_id, usage_id) REFERENCES ast.asset_usages (tenant_id, id)
);
CREATE TRIGGER dep_lines_guard BEFORE INSERT OR UPDATE OR DELETE ON ast.depreciation_lines
  FOR EACH ROW EXECUTE FUNCTION app.guard_child_rows('ast.depreciation_runs', 'run_id', '{POSTED,VOIDED}');
CREATE TRIGGER dep_runs_status BEFORE UPDATE OR DELETE ON ast.depreciation_runs
  FOR EACH ROW EXECUTE FUNCTION app.guard_header_status('DRAFT', '{DRAFT>POSTED,DRAFT>VOIDED,POSTED>VOIDED}');
```

---

## 7. Khế ước vay

- `fin.loan_contracts` (HĐ hạn mức là cha, khế ước nhận nợ là con), `fin.loan_rate_periods` (lãi suất theo giai đoạn), `fin.loan_schedule_lines` (lịch dự kiến; khoá khi khế ước đóng/huỷ), `fin.loan_transactions` (biến động thực tế, mỗi dòng gắn chứng từ).
- **Trích lãi** cuối tháng cho từng khế ước: lãi = Σ_ngày (dư gốc nguyên tệ cuối ngày × lãi suất năm hiệu lực / 365 hoặc 360), làm tròn một lần cho cả tháng (R1(a)); quy đổi VND theo tỷ giá cuối tháng nếu vay ngoại tệ. Chứng từ hệ thống `LOAN_INTEREST_ACCRUAL`: Nợ 635 / Có 335 (hoặc không trích, ghi khi trả — cấu hình theo khế ước bằng `accrued_interest_account_id`).
- Giải ngân, trả gốc, trả lãi lập từ phân hệ Ngân hàng, dòng bút toán mang `loan_contract_id`; giải ngân/trả gốc ngoại tệ tạo/tất toán khoản mục mở (§5.3).
- Báo cáo NH-R2 và tách vay ngắn/dài hạn trên BCĐKT đọc lịch trả còn lại: phần gốc có `due_date` ≤ ngày báo cáo + 12 tháng là ngắn hạn.

```sql
CREATE TABLE fin.loan_contracts (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  contract_no text NOT NULL,                -- số khế ước do ngân hàng cấp
  parent_contract_id uuid,                  -- HĐ tín dụng hạn mức
  lender_partner_id uuid NOT NULL,
  currency char(3) NOT NULL REFERENCES sys.currencies (code),
  principal_fc numeric(20,2) NOT NULL CHECK (principal_fc > 0),
  loan_account_id uuid NOT NULL,            -- 341x
  interest_expense_account_id uuid NOT NULL,-- 635
  accrued_interest_account_id uuid,         -- 335; NULL = không trích trước
  start_date date NOT NULL, maturity_date date NOT NULL,
  day_count text NOT NULL CHECK (day_count IN ('ACT_365','ACT_360')),
  purpose text NOT NULL CHECK (purpose IN ('WORKING_CAPITAL','CAPEX','OTHER')),
  status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','ACTIVE','CLOSED','VOIDED')),
  CHECK (maturity_date > start_date),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, lender_partner_id, contract_no),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id),
  FOREIGN KEY (tenant_id, parent_contract_id) REFERENCES fin.loan_contracts (tenant_id, id),
  FOREIGN KEY (tenant_id, lender_partner_id) REFERENCES md.partners (tenant_id, id),
  FOREIGN KEY (tenant_id, loan_account_id) REFERENCES md.accounts (tenant_id, id),
  FOREIGN KEY (tenant_id, interest_expense_account_id) REFERENCES md.accounts (tenant_id, id),
  FOREIGN KEY (tenant_id, accrued_interest_account_id) REFERENCES md.accounts (tenant_id, id)
);

CREATE TABLE fin.loan_rate_periods (        -- lãi suất theo giai đoạn (cố định hoặc điều chỉnh)
  tenant_id uuid NOT NULL, contract_id uuid NOT NULL, valid_from date NOT NULL,
  annual_rate_pct numeric(9,6) NOT NULL CHECK (annual_rate_pct >= 0),
  PRIMARY KEY (tenant_id, contract_id, valid_from),
  FOREIGN KEY (tenant_id, contract_id) REFERENCES fin.loan_contracts (tenant_id, id)
);

CREATE TABLE fin.loan_schedule_lines (      -- lịch trả dự kiến
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  contract_id uuid NOT NULL, due_date date NOT NULL,
  kind text NOT NULL CHECK (kind IN ('PRINCIPAL','INTEREST')),
  planned_fc numeric(20,2) NOT NULL CHECK (planned_fc >= 0),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, contract_id, due_date, kind),
  FOREIGN KEY (tenant_id, contract_id) REFERENCES fin.loan_contracts (tenant_id, id)
);
CREATE TRIGGER loan_schedule_guard BEFORE INSERT OR UPDATE OR DELETE ON fin.loan_schedule_lines
  FOR EACH ROW EXECUTE FUNCTION app.guard_child_rows('fin.loan_contracts', 'contract_id', '{CLOSED,VOIDED}');

CREATE TABLE fin.loan_transactions (        -- mọi biến động thực tế, mỗi dòng gắn chứng từ
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  contract_id uuid NOT NULL, document_id uuid NOT NULL,
  txn_type text NOT NULL CHECK (txn_type IN
    ('DRAWDOWN','PRINCIPAL_REPAY','INTEREST_ACCRUAL','INTEREST_PAY','REVALUATION')),
  txn_date date NOT NULL,
  amount_fc numeric(20,2) NOT NULL CHECK (amount_fc >= 0),
  amount_base numeric(20,2) NOT NULL,
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, contract_id) REFERENCES fin.loan_contracts (tenant_id, id),
  FOREIGN KEY (tenant_id, document_id) REFERENCES acc.documents (tenant_id, id)
);
```

---

## 8. Luồng duyệt, đơn hàng, đề nghị thanh toán

- **Luồng duyệt dùng chung** (`wf.*`): chính sách theo loại đối tượng × bước × vai trò × ngưỡng tiền; một yêu cầu duyệt đang mở cho mỗi đối tượng; hành động duyệt append-only. Quy tắc "người lập không tự duyệt" và "người duyệt không lập phiếu chi cho đề nghị mình duyệt" kiểm ở tầng ứng dụng (cần biết vai trò, không đặt ở DB).
- **Đơn hàng** (`ord.orders`, `ord.order_lines`): một bảng cho đơn mua và đơn bán. Dòng đơn khoá khi đơn đã gửi duyệt; muốn sửa phải trả về nháp (`SUBMITTED>DRAFT`) và duyệt lại. Tiến độ đơn (đã nhận/đã giao, đã lập HĐ, bị trả lại) suy ra từ `acc.document_lines.order_line_id`, không lưu cột cộng dồn:

  ```sql
  SELECT ol.id, ol.qty_base,
         coalesce(sum(dl.qty_base) FILTER (WHERE d.doc_type IN ('PURCHASE_RECEIPT','SALES_INVOICE')), 0) AS fulfilled,
         coalesce(sum(dl.qty_base) FILTER (WHERE d.doc_type IN ('PURCHASE_RETURN','SALES_RETURN')), 0)  AS returned
    FROM ord.order_lines ol
    LEFT JOIN acc.document_lines dl ON dl.tenant_id = ol.tenant_id AND dl.order_line_id = ol.id
    LEFT JOIN acc.documents d ON d.tenant_id = dl.tenant_id AND d.id = dl.document_id AND d.status = 'POSTED'
   GROUP BY ol.id, ol.qty_base;
  ```
- **Hạn mức dư nợ KH / hạn mức NCC**: thuộc danh mục đối tượng (05 chưa có DDL `md.partners`; thêm `credit_limit`, `payment_term_days`). Kiểm khi duyệt đơn bán và khi ghi sổ HĐ bán: dư nợ 131 hiện tại + giá trị chứng từ > hạn mức → cảnh báo hoặc bắt buộc yêu cầu duyệt `CREDIT_OVERRIDE` (cấu hình).
- **Đề nghị thanh toán** (`cash.payment_requests`, `..._lines`, `..._settlements`): luồng trạng thái ở `../YEU-CAU-KHACH-HANG.md` §3.1.1, được trigger cưỡng chế. Một đề nghị chi nhiều lần, một phiếu chi trả nhiều đề nghị. Phiếu chi/UNC tham chiếu đề nghị đã `APPROVED`; khi Σ đã chi = Σ đề nghị thì chuyển `PAID`.

```sql
CREATE TABLE wf.approval_policies (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  subject_type text NOT NULL CHECK (subject_type IN
    ('PAYMENT_REQUEST','PURCHASE_ORDER','SALES_ORDER','CREDIT_OVERRIDE','QC_DISPOSITION','ASSET_DISPOSAL','LOAN_CONTRACT')),
  step_no smallint NOT NULL CHECK (step_no > 0),
  approver_role text NOT NULL,              -- 'KTT', 'BOD', 'TRUONG_QC'…
  min_amount numeric(20,2) NOT NULL DEFAULT 0,   -- bước chỉ áp khi số tiền ≥ ngưỡng
  valid_from date NOT NULL, valid_to date,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, subject_type, step_no, valid_from),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id)
);

CREATE TABLE wf.approval_requests (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, subject_type text NOT NULL, subject_id uuid NOT NULL,
  amount_base numeric(20,2) NOT NULL,
  requested_by uuid NOT NULL, requested_at timestamptz NOT NULL DEFAULT now(),
  current_step smallint NOT NULL DEFAULT 1,
  status text NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','APPROVED','REJECTED','RETURNED','CANCELLED')),
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, requested_by) REFERENCES core.users (tenant_id, id)
);
CREATE UNIQUE INDEX approval_one_open ON wf.approval_requests (tenant_id, subject_type, subject_id)
  WHERE status = 'PENDING';

CREATE TABLE wf.approval_actions (          -- append-only
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  request_id uuid NOT NULL, step_no smallint NOT NULL,
  actor_id uuid NOT NULL,
  action text NOT NULL CHECK (action IN ('APPROVE','REJECT','RETURN')),
  comment text, acted_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, request_id, step_no, actor_id),
  FOREIGN KEY (tenant_id, request_id) REFERENCES wf.approval_requests (tenant_id, id),
  FOREIGN KEY (tenant_id, actor_id) REFERENCES core.users (tenant_id, id)
);

CREATE TABLE ord.orders (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  order_type text NOT NULL CHECK (order_type IN ('PURCHASE','SALES')),
  fiscal_year smallint NOT NULL, order_no text NOT NULL,
  order_date date NOT NULL, partner_id uuid NOT NULL, warehouse_id uuid,
  contract_ref text,                        -- số hợp đồng khung (nếu có)
  currency char(3) NOT NULL REFERENCES sys.currencies (code),
  expected_fx_rate numeric(18,6) CHECK (expected_fx_rate > 0),
  payment_term_days smallint CHECK (payment_term_days >= 0),
  status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN
    ('DRAFT','SUBMITTED','APPROVED','IN_PROGRESS','COMPLETED','CLOSED','CANCELLED')),
  approval_request_id uuid,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, order_type, fiscal_year, order_no),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id),
  FOREIGN KEY (tenant_id, partner_id) REFERENCES md.partners (tenant_id, id),
  FOREIGN KEY (tenant_id, warehouse_id) REFERENCES md.warehouses (tenant_id, id),
  FOREIGN KEY (tenant_id, approval_request_id) REFERENCES wf.approval_requests (tenant_id, id)
);
CREATE TRIGGER orders_status BEFORE UPDATE OR DELETE ON ord.orders
  FOR EACH ROW EXECUTE FUNCTION app.guard_header_status('DRAFT',
    '{DRAFT>SUBMITTED,SUBMITTED>DRAFT,SUBMITTED>APPROVED,SUBMITTED>CANCELLED,APPROVED>IN_PROGRESS,APPROVED>CANCELLED,IN_PROGRESS>COMPLETED,IN_PROGRESS>CLOSED,COMPLETED>CLOSED}');

CREATE TABLE ord.order_lines (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  order_id uuid NOT NULL, line_no int NOT NULL,
  item_id uuid NOT NULL, uom_id uuid NOT NULL,
  qty numeric(20,6) NOT NULL CHECK (qty > 0), qty_base numeric(20,6) NOT NULL CHECK (qty_base > 0),
  unit_price numeric(24,8) NOT NULL CHECK (unit_price >= 0),
  amount numeric(20,2) NOT NULL CHECK (amount >= 0),
  vat_rate numeric(5,2),
  due_date date,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, order_id, line_no),
  FOREIGN KEY (tenant_id, order_id) REFERENCES ord.orders (tenant_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (tenant_id, item_id) REFERENCES md.items (tenant_id, id),
  FOREIGN KEY (tenant_id, uom_id) REFERENCES md.uoms (tenant_id, id)
);
CREATE TRIGGER order_lines_guard BEFORE INSERT OR UPDATE OR DELETE ON ord.order_lines
  FOR EACH ROW EXECUTE FUNCTION app.guard_child_rows('ord.orders', 'order_id',
    '{SUBMITTED,APPROVED,IN_PROGRESS,COMPLETED,CLOSED,CANCELLED}');

ALTER TABLE acc.document_lines
  ADD COLUMN order_line_id uuid,
  ADD CONSTRAINT dl_order_line_fk FOREIGN KEY (tenant_id, order_line_id) REFERENCES ord.order_lines (tenant_id, id);

CREATE TABLE cash.payment_requests (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  fiscal_year smallint NOT NULL, request_no text NOT NULL,
  request_date date NOT NULL, requester_id uuid NOT NULL,
  request_type text NOT NULL CHECK (request_type IN
    ('SUPPLIER_PAYMENT','ADVANCE','ADVANCE_SETTLEMENT','EXPENSE','LOAN_REPAYMENT','OTHER')),
  payee_partner_id uuid,
  currency char(3) NOT NULL REFERENCES sys.currencies (code),
  pay_method text NOT NULL CHECK (pay_method IN ('CASH','BANK')),
  due_date date,
  status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN
    ('DRAFT','SUBMITTED','RETURNED','APPROVED','REJECTED','PARTIALLY_PAID','PAID','CANCELLED')),
  approval_request_id uuid,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, fiscal_year, request_no),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id),
  FOREIGN KEY (tenant_id, requester_id) REFERENCES core.users (tenant_id, id),
  FOREIGN KEY (tenant_id, payee_partner_id) REFERENCES md.partners (tenant_id, id),
  FOREIGN KEY (tenant_id, approval_request_id) REFERENCES wf.approval_requests (tenant_id, id)
);
CREATE TRIGGER payment_requests_status BEFORE UPDATE OR DELETE ON cash.payment_requests
  FOR EACH ROW EXECUTE FUNCTION app.guard_header_status('DRAFT',
    '{DRAFT>SUBMITTED,DRAFT>CANCELLED,SUBMITTED>RETURNED,SUBMITTED>APPROVED,SUBMITTED>REJECTED,RETURNED>SUBMITTED,RETURNED>CANCELLED,APPROVED>PARTIALLY_PAID,APPROVED>PAID,PARTIALLY_PAID>PAID,APPROVED>CANCELLED}');

CREATE TABLE cash.payment_request_lines (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  request_id uuid NOT NULL, line_no int NOT NULL,
  ref_document_id uuid,                     -- HĐ mua / chứng từ công nợ được thanh toán
  ref_order_id uuid,                        -- đơn mua (ứng trước)
  loan_contract_id uuid,
  expense_account_id uuid, cost_object_id uuid,
  description text NOT NULL,
  amount_fc numeric(20,2) NOT NULL CHECK (amount_fc > 0),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, request_id, line_no),
  FOREIGN KEY (tenant_id, request_id) REFERENCES cash.payment_requests (tenant_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (tenant_id, ref_document_id) REFERENCES acc.documents (tenant_id, id),
  FOREIGN KEY (tenant_id, ref_order_id) REFERENCES ord.orders (tenant_id, id),
  FOREIGN KEY (tenant_id, loan_contract_id) REFERENCES fin.loan_contracts (tenant_id, id),
  FOREIGN KEY (tenant_id, expense_account_id) REFERENCES md.accounts (tenant_id, id),
  FOREIGN KEY (tenant_id, cost_object_id) REFERENCES mfg.cost_objects (tenant_id, id)
);
CREATE TRIGGER payment_request_lines_guard BEFORE INSERT OR UPDATE OR DELETE ON cash.payment_request_lines
  FOR EACH ROW EXECUTE FUNCTION app.guard_child_rows('cash.payment_requests', 'request_id',
    '{SUBMITTED,APPROVED,REJECTED,PARTIALLY_PAID,PAID,CANCELLED}');

CREATE TABLE cash.payment_request_settlements (   -- phiếu chi/UNC nào trả cho dòng đề nghị nào
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  request_line_id uuid NOT NULL, payment_document_id uuid NOT NULL,
  amount_fc numeric(20,2) NOT NULL CHECK (amount_fc > 0),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, request_line_id, payment_document_id),
  FOREIGN KEY (tenant_id, request_line_id) REFERENCES cash.payment_request_lines (tenant_id, id),
  FOREIGN KEY (tenant_id, payment_document_id) REFERENCES acc.documents (tenant_id, id)
);
```

---

## 9. Lưu chuyển tiền tệ

**Trực tiếp**:
- Mọi dòng bút toán vào TK có role tiền (111x, 112x, và 113 nếu dùng) phải có `cash_flow_code`, trừ chuyển tiền nội bộ (mã thuộc nhóm `INTERNAL`).
- Posting rule phải **tách dòng tiền theo từng TK đối ứng** (một phiếu chi trả cả 331 và 1331 → hai dòng tiền, hoặc một dòng tiền mang mã của đối ứng chính theo quy tắc cấu hình); `md.cash_flow_rules` gợi ý mã theo TK đối ứng × chiều; người lập sửa được trước khi ghi sổ.
- Kiểm tra khi khoá sổ (bước 8 ở §4.7):

  ```sql
  SELECT jl.id FROM acc.journal_lines jl
    JOIN md.account_role_mappings rm
      ON rm.tenant_id = jl.tenant_id AND rm.account_id = jl.account_id AND rm.role IN ('CASH','BANK')
   WHERE jl.tenant_id = $1 AND jl.posting_date BETWEEN $2 AND $3 AND jl.is_active
     AND jl.cash_flow_code IS NULL;      -- phải rỗng mới cho khoá
  ```
- Ảnh hưởng tỷ giá: lấy từ dòng đánh giá lại tiền ngoại tệ (§5.4), không phải dòng tiền thật.

**Gián tiếp**: báo cáo dạng công thức như mẫu BCTC của 05 §2.3 (`report_lines` theo chế độ). Các điều chỉnh cần dữ liệu có cấu trúc, không suy được chỉ từ số dư:
- Khấu hao: PS Có 214 từ chứng từ `FA_DEPRECIATION`.
- Lãi/lỗ chênh lệch tỷ giá **chưa thực hiện**: bút toán `source = 'REVALUATION'`.
- Biến động phải trả **loại trừ** phải trả mua TSCĐ và lãi vay: dòng 331 của chứng từ ghi tăng TSCĐ được gắn nhóm "đầu tư"; 335 lãi vay theo `loan_contract_id`.
- Lãi vay đã trả, thuế TNDN đã nộp: lấy từ mã dòng tiền trực tiếp tương ứng.
- Kiểm tra: lưu chuyển thuần hoạt động kinh doanh theo hai phương pháp bằng nhau; nếu lệch, báo cáo hiển thị dòng chênh lệch kèm danh sách nghi vấn (thường là dòng tiền gắn sai mã). Đây là phần có rủi ro cao nhất về đúng/sai trong 1C — xem kế hoạch §5.

Mã chỉ tiêu trong `sys.cash_flow_lines` là dữ liệu theo chế độ + phiên bản; mã của TT99 và B03-DNN (TT133) **chưa xác minh**.

```sql
CREATE TABLE sys.cash_flow_lines (          -- chỉ tiêu B03 theo chế độ + phiên bản (dữ liệu hệ thống)
  regime text NOT NULL CHECK (regime IN ('TT99','TT133','TT200')),
  version_code text NOT NULL,
  code text NOT NULL,                       -- mã chỉ tiêu (chưa xác minh với TT99)
  name text NOT NULL,
  section text NOT NULL CHECK (section IN ('OPERATING','INVESTING','FINANCING','FX_EFFECT','INTERNAL')),
  PRIMARY KEY (regime, version_code, code)
);

CREATE TABLE md.cash_flow_rules (           -- gợi ý mã dòng tiền theo TK đối ứng
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  contra_account_id uuid NOT NULL,
  direction text NOT NULL CHECK (direction IN ('IN','OUT')),
  cash_flow_code text NOT NULL,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, contra_account_id, direction),
  FOREIGN KEY (tenant_id, contra_account_id) REFERENCES md.accounts (tenant_id, id)
);
```

---

## 10. Quản lý chất lượng

- `qc.control_points`: điểm kiểm soát theo loại (tiếp nhận / trong quy trình / giải phóng lô / lưu kho), gắn thao tác trong quy trình, khu, cờ điểm tới hạn (nếu khách dùng HACCP — chưa rõ).
- `qc.criteria`: chỉ tiêu có hiệu lực theo ngày; kiểu số đo (min/max), Đạt/Không đạt, ghi chú.
- `qc.inspections` + `qc.inspection_results`: phiếu kiểm theo lô × điểm; số phiếu duy nhất theo năm; chốt (`FINAL`) thì kết quả không sửa được, chỉ huỷ có lý do. Khi chốt, cùng transaction cập nhật `inv.lots.qc_status` (Đạt → `RELEASED`; Không đạt → `REJECTED`, hoặc `HOLD` nếu chờ xử lý).
- `qc.dispositions`: quyết định xử lý SL không đạt; phân loại trong/ngoài định mức; role TK ghi nhận tổn thất; yêu cầu duyệt (trưởng QC; vượt ngưỡng → KTT/BOD); khi thực hiện phải có chứng từ kết quả (phiếu xuất huỷ, phiếu trả NCC, lệnh làm lại). Chấp nhận có điều kiện thì không cần chứng từ.

```sql
CREATE TABLE qc.control_points (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL, code text NOT NULL, name text NOT NULL,
  point_kind text NOT NULL CHECK (point_kind IN ('RECEIVING','IN_PROCESS','FINAL_RELEASE','STORAGE')),
  routing_operation_id uuid,                -- NULL với tiếp nhận mua / lưu kho
  work_area_id uuid,
  is_critical boolean NOT NULL DEFAULT false,      -- điểm tới hạn (nếu khách áp dụng HACCP)
  sampling_rule text,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, code),
  CHECK (point_kind IN ('RECEIVING','STORAGE') OR routing_operation_id IS NOT NULL),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id),
  FOREIGN KEY (tenant_id, routing_operation_id) REFERENCES mfg.routing_operations (tenant_id, id),
  FOREIGN KEY (tenant_id, work_area_id) REFERENCES md.work_areas (tenant_id, id)
);

CREATE TABLE qc.criteria (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  control_point_id uuid NOT NULL, seq smallint NOT NULL,
  name text NOT NULL, unit text,
  value_type text NOT NULL CHECK (value_type IN ('NUMERIC','PASS_FAIL','TEXT')),
  min_value numeric, max_value numeric,
  is_mandatory boolean NOT NULL DEFAULT true,
  valid_from date NOT NULL, valid_to date,
  CHECK (value_type = 'NUMERIC' OR (min_value IS NULL AND max_value IS NULL)),
  CHECK (min_value IS NULL OR max_value IS NULL OR min_value <= max_value),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, control_point_id, seq, valid_from),
  FOREIGN KEY (tenant_id, control_point_id) REFERENCES qc.control_points (tenant_id, id)
);

CREATE TABLE qc.inspections (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  company_id uuid NOT NULL,
  fiscal_year smallint NOT NULL, inspection_no text NOT NULL,
  control_point_id uuid NOT NULL,
  lot_id uuid NOT NULL,
  production_order_id uuid, receipt_line_id uuid,
  inspector_id uuid NOT NULL, inspected_at timestamptz NOT NULL,
  qty_inspected numeric(20,6) NOT NULL CHECK (qty_inspected > 0),
  qty_passed numeric(20,6) NOT NULL DEFAULT 0 CHECK (qty_passed >= 0),
  qty_failed numeric(20,6) NOT NULL DEFAULT 0 CHECK (qty_failed >= 0),
  conclusion text CHECK (conclusion IN ('PASS','FAIL','CONDITIONAL')),
  status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','FINAL','VOIDED')),
  void_reason text,
  CHECK (qty_passed + qty_failed <= qty_inspected),
  CHECK (status <> 'FINAL' OR conclusion IS NOT NULL),
  CHECK (status <> 'VOIDED' OR void_reason IS NOT NULL),
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, company_id, fiscal_year, inspection_no),
  FOREIGN KEY (tenant_id, company_id) REFERENCES core.companies (tenant_id, id),
  FOREIGN KEY (tenant_id, control_point_id) REFERENCES qc.control_points (tenant_id, id),
  FOREIGN KEY (tenant_id, lot_id) REFERENCES inv.lots (tenant_id, id),
  FOREIGN KEY (tenant_id, production_order_id) REFERENCES mfg.production_orders (tenant_id, id),
  FOREIGN KEY (tenant_id, inspector_id) REFERENCES core.users (tenant_id, id)
);
CREATE TRIGGER inspections_status BEFORE UPDATE OR DELETE ON qc.inspections
  FOR EACH ROW EXECUTE FUNCTION app.guard_header_status('DRAFT', '{DRAFT>FINAL,FINAL>VOIDED}');

CREATE TABLE qc.inspection_results (
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  inspection_id uuid NOT NULL, criterion_id uuid NOT NULL,
  numeric_value numeric, pass_fail boolean, text_value text,
  within_limit boolean NOT NULL,
  PRIMARY KEY (tenant_id, id),
  UNIQUE (tenant_id, inspection_id, criterion_id),
  CHECK (num_nonnulls(numeric_value, pass_fail, text_value) = 1),
  FOREIGN KEY (tenant_id, inspection_id) REFERENCES qc.inspections (tenant_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (tenant_id, criterion_id) REFERENCES qc.criteria (tenant_id, id)
);
CREATE TRIGGER inspection_results_guard BEFORE INSERT OR UPDATE OR DELETE ON qc.inspection_results
  FOR EACH ROW EXECUTE FUNCTION app.guard_child_rows('qc.inspections', 'inspection_id', '{FINAL,VOIDED}');

CREATE TABLE qc.dispositions (              -- xử lý SL không đạt
  tenant_id uuid NOT NULL, id uuid NOT NULL DEFAULT uuidv7(),
  inspection_id uuid NOT NULL, lot_id uuid NOT NULL,
  qty numeric(20,6) NOT NULL CHECK (qty > 0),
  decision text NOT NULL CHECK (decision IN
    ('DESTROY','REWORK','RETURN_TO_SUPPLIER','DOWNGRADE','ACCEPT_DEVIATION')),
  loss_class text CHECK (loss_class IN ('NORMAL','ABNORMAL')),     -- trong / ngoài định mức
  loss_account_role text,                   -- 'COGS' (632) / 'OTHER_EXPENSE' (811) / 'RECEIVABLE_OTHER' (1388)
  approval_request_id uuid,
  result_document_id uuid,                  -- phiếu xuất huỷ / trả NCC / lệnh làm lại
  status text NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT','APPROVED','EXECUTED','CANCELLED')),
  CHECK (decision IN ('ACCEPT_DEVIATION','RETURN_TO_SUPPLIER') OR loss_class IS NOT NULL),
  CHECK (status <> 'EXECUTED' OR decision = 'ACCEPT_DEVIATION' OR result_document_id IS NOT NULL),
  PRIMARY KEY (tenant_id, id),
  FOREIGN KEY (tenant_id, inspection_id) REFERENCES qc.inspections (tenant_id, id),
  FOREIGN KEY (tenant_id, lot_id) REFERENCES inv.lots (tenant_id, id),
  FOREIGN KEY (tenant_id, approval_request_id) REFERENCES wf.approval_requests (tenant_id, id),
  FOREIGN KEY (tenant_id, result_document_id) REFERENCES acc.documents (tenant_id, id)
);
CREATE TRIGGER dispositions_status BEFORE UPDATE OR DELETE ON qc.dispositions
  FOR EACH ROW EXECUTE FUNCTION app.guard_header_status('DRAFT',
    '{DRAFT>APPROVED,DRAFT>CANCELLED,APPROVED>EXECUTED,APPROVED>CANCELLED}');

ALTER TABLE mfg.routing_operations
  ADD COLUMN qc_point_id uuid,
  ADD CONSTRAINT rop_qc_fk FOREIGN KEY (tenant_id, qc_point_id) REFERENCES qc.control_points (tenant_id, id);
```

---

## 11. RLS và kiểm thử

```sql
DO $$
DECLARE r record;
BEGIN
  FOR r IN
    SELECT c.oid::regclass AS tbl
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_attribute a ON a.attrelid = c.oid AND a.attname = 'tenant_id' AND NOT a.attisdropped
     WHERE c.relkind = 'r'
       AND n.nspname IN ('md','inv','mfg','acc','ast','fin','wf','ord','cash','qc')
       AND NOT c.relrowsecurity
  LOOP
    EXECUTE format('ALTER TABLE %s ENABLE ROW LEVEL SECURITY', r.tbl);
    EXECUTE format('ALTER TABLE %s FORCE ROW LEVEL SECURITY', r.tbl);
    EXECUTE format('CREATE POLICY tenant_isolation ON %s USING (tenant_id = app.current_tenant())'
                   ' WITH CHECK (tenant_id = app.current_tenant())', r.tbl);
  END LOOP;
END $$;
```

Phép thử đã chạy (PG16, vai trò không phải superuser vì superuser bỏ qua RLS):

| Thử | Kết quả mong đợi | Kết quả |
|---|---|---|
| Thêm/sửa/xoá dòng đơn khi đơn `SUBMITTED` | Lỗi 55000 | Đạt |
| Xoá đơn `SUBMITTED`; chuyển `SUBMITTED → COMPLETED` | Lỗi | Đạt |
| Trả đơn về nháp rồi sửa dòng | Thành công | Đạt |
| Vật tư `SPECIFIC` không bật theo lô | Vi phạm CHECK | Đạt |
| Xuất SX lô `PENDING`; dòng kho thiếu lô | Lỗi | Đạt |
| Xuất SX lô `RELEASED`; gọi `inv.lock_cost_key` | Thành công | Đạt |
| Sửa tỷ giá / thêm tỷ giá vào ngày đã khoá; thêm tỷ giá ngày khác | Lỗi / lỗi / thành công | Đạt |
| Dòng bút toán có nguyên tệ thiếu tỷ giá | Vi phạm CHECK | Đạt |
| Bảng giá thành lệnh không cân | Vi phạm CHECK | Đạt |
| Truy ngược từ lô BTP về lô NVL qua view | Trả 1 lô NVL | Đạt |
| Chốt phiếu QC thiếu kết luận; sửa kết quả sau khi chốt | Lỗi / lỗi | Đạt |
| Đọc lô của tenant khác; ghi dòng mang tenant khác | 0 dòng / lỗi RLS | Đạt |

Cần thêm ở Phase 0 (chưa làm): hai phiên đồng thời cho `guard_child_rows` (`FOR SHARE` header) và `guard_move_lot`; property test định giá đích danh (bảo toàn theo lô, `q = Q ⇒` lấy hết giá trị, chuyển kho K7, hàng trả lại không vượt dòng xuất gốc); golden test các ví dụ §4.1, §4.3, §5.3; chạy trên PG18 với `uuidv7()` thật.

---

## 12. Điểm chưa xác minh và rủi ro kỹ thuật

| # | Điểm | Ảnh hưởng | Cách xử lý |
|---|---|---|---|
| 1 | BTP nhập kho ghi 155 hay giữ 154; xuất BTP cho giai đoạn sau qua 621 hay thẳng 154 | Định khoản 1B | Role cấu hình `SEMI_STOCK`, `WIP_SEMI`; KTT chọn (B4) |
| 2 | Tỷ giá giao dịch / đánh giá lại theo TT99 (loại tỷ giá, tần suất, đảo hay không) | NT-02, NT-04 | Cờ cấu hình; KTT xác nhận (A5) |
| 3 | Mã chỉ tiêu LCTT, BCĐKT theo TT99 | BC-R3, BC-R4 | Dữ liệu `sys.*` có phiên bản; nạp khi có văn bản gốc |
| 4 | Điều chỉnh giá trị lô không lan xuống lô BTP/TP đã tính giá (§2.3) | Sai số nhỏ dồn vào 632 | KTT xác nhận chấp nhận được |
| 5 | Một lệnh ủ hoàn thành một lần; rút một phần bể = tách lệnh | Mô hình lệnh | Khách trả lời B1 |
| 6 | Mọi hàng đích danh theo lô (kể cả bao bì) | Khối lượng nhập liệu; hiệu năng không đáng lo | FEFO tự gợi ý; nếu khách muốn BQ cho bao bì thì phải thêm engine BQ và bài toán hỗn hợp phương pháp (06b-A10) |
| 7 | Guard dùng `EXECUTE format()` với tên bảng lấy từ tham số trigger | Chỉ người viết migration đặt được tham số; đã ép `regclass` | Không nhận tham số từ người dùng |
| 8 | Trigger `guard_move_lot` đọc `md.items` mỗi dòng | Chi phí nhỏ với khối lượng DN vừa | Theo dõi trong benchmark |
