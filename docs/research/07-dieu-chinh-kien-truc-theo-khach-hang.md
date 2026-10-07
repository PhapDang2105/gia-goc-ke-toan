# 07 — Điều chỉnh kiến trúc và dữ liệu theo yêu cầu khách hàng

> Phiên bản: 0.3 · Ngày: 2026-10-07 · Trạng thái: đề xuất để review · 0.2 thêm §2.8 (vị trí chứa, mã hóa lô) · 0.3 sửa theo `../PHAN-BIEN-v3.md` §4 (A3, A4, A5, A8, A9, A10) và chốt giá thành theo lệnh SX + giá vốn theo lô (§4, §4.8)
> Đầu vào: `../YEU-CAU-KHACH-HANG.md` (mã yêu cầu dẫn trong tài liệu này), `../KE-HOACH-DU-AN.md` v0.4, `05-kien-truc-de-xuat.md` v0.3.
> Quan hệ với 05: 07 **chỉ mô tả phần thêm hoặc thay đổi** so với 05 để đáp ứng tài liệu khách; phần không nhắc tới giữ như 05. Quy ước khối SQL, vai trò CSDL và ngữ cảnh tenant theo 05 (đầu tài liệu, §2.1).
> Kiểm chứng (2026-10-07): khối SQL của 05 rồi 07 **chạy nguyên văn theo thứ tự** trên PostgreSQL 16.15 bằng vai trò `app_owner` (chỉ thêm `uuidv7()` → `gen_random_uuid()` vì PG16 chưa có); truy vấn mẫu kiểm bằng `PREPARE`; phép thử chức năng và tấn công ở §11 chạy bằng `app_user`. **Chưa** chạy trên PG18, **chưa** thử hai phiên đồng thời.

---

## 0. Tóm tắt thay đổi so với 05

| # | Chủ đề | 05 | 07 | Yêu cầu |
|---|---|---|---|---|
| 1 | Phương pháp giá xuất | BQ cuối kỳ / BQ tức thời là chính; FIFO, đích danh ở giai đoạn sau | **Đích danh theo lô là chính**. Cost key = `(company, item, warehouse, lot)`; lô chính là lớp giá, không cần `cst.cost_layers` | GT-07 |
| 2 | Lô | `inv.lots` tối giản, `lot_id` tuỳ chọn | Lô có loại, NSX/HSD, **trạng thái QC**, nguồn (phiếu nhập / lệnh SX), khu QC; hàng đích danh **bắt buộc lô** | QC-03, QC-05 |
| 3 | Kiểm âm | Theo `(item, warehouse, lot)` bằng truy vấn trên sổ kho | Thêm vị trí chứa: theo `(item, warehouse, lot, location)` (§2.8); vì cost key đã gồm lô nên lũy kế vật lý và lũy kế định giá **trùng nhau** | KHO-02 |
| 4 | Giá thành | Giản đơn; phân bước tự động qua SCC/BOM đa cấp | **Chốt: giá thành theo lệnh SX (job-order)**. Mỗi lệnh SX công đoạn (lô × giai đoạn) là một đối tượng tập hợp chi phí; dở dang = chi phí luỹ kế của lệnh chưa hoàn thành, kể cả lệnh ủ qua nhiều kỳ; BTP **luôn có lô và sổ kho** (phương án A, §4.2) và đi tiếp **bằng giá lô**; không gộp theo sản phẩm/tháng | GT-01..06 |
| 4b | Giá vốn theo lô | Truy vết chi phí theo đồ thị (05 §6) | **Mục tiêu trọng tâm của khách**: mỗi lô TP/hàng hoá có giá vốn riêng; bấm vào lô thấy cây cấu thành: lô TP ← lệnh ← lô BTP ← lệnh ← lô NVL (NCC, giá lô) — §4.8 | GT-09, GT-10, GT-R4, GT-R5 |
| 5 | Hệ phương trình BQ cuối kỳ | Gauss / Gauss–Seidel cho SCC | **Không cần** với đích danh: chuỗi lô là đồ thị có hướng theo thời gian; làm lại (rework) là lệnh mới nên không tạo vòng | — |
| 6 | Hàng không đạt QC | Không có | Trong định mức dồn vào SL đạt; ngoài định mức ra 632/811/1388; phiếu QC → quyết định xử lý → chứng từ | GT-06, QC-06 |
| 7 | Ngoại tệ | Cột `currency, amount_fc, fx_rate` trên dòng bút toán, chưa có nghiệp vụ | Tỷ giá theo ngày có **khoá ngày**; khoản mục mở theo chứng từ gốc; tất toán sinh 515/635; đánh giá lại qua 413 | NT-01..05 |
| 8 | TSCĐ, CCDC, khế ước vay | Ngoài phạm vi (nhập qua chứng từ tổng hợp) | Bảng riêng, lịch, bút toán tự sinh qua chứng từ hệ thống | TSCD-*, CCDC-*, NH-03 |
| 9 | Đơn hàng, đề nghị thanh toán | Ngoài phạm vi | Bảng đơn mua/bán, đề nghị thanh toán, luồng duyệt dùng chung | MUA-01, BAN-01, TIEN-01 |
| 10 | LCTT | Nhắc trong 01 | Mã dòng tiền trên dòng bút toán tiền (trực tiếp) + bảng công thức (gián tiếp) | BC-R4 |
| 11 | QC | Không có | Điểm kiểm soát theo thao tác, chỉ tiêu, phiếu kiểm, xử lý không đạt | QC-01..08 |
| 12 | Vị trí chứa, mã hóa | Không có | Bồn / trái / phuy theo kho; **kiểm âm theo `(item, warehouse, lot, location)`**, cost key vẫn theo lô; mã hóa lô tự sinh, bất biến; tồn tối thiểu, mã MISA, số phiếu kho theo tháng (§2.8) | KHO-06..11, KHO-R7..R9 |

## 1. Quy ước tuân thủ cho mọi bảng mới

- `tenant_id uuid NOT NULL`, PK `(tenant_id, id)`, FK kép `(tenant_id, x_id)`; RLS `ENABLE` + `FORCE` do `app.apply_tenant_rls()` của 05 §2.1 tự bật cho mọi schema (gọi lại ở §11); quyền hẹp hơn mặc định khai trong `sys.table_privileges`.
- Số chứng từ/đơn/phiếu duy nhất **theo năm**: `UNIQUE (tenant_id, company_id, [loại,] fiscal_year, số)`.
- FK từ dòng tới header: `ON DELETE RESTRICT` (mặc định), **không** `CASCADE`.
- Dòng con của header đã chốt: trigger chặn **INSERT/UPDATE/DELETE** (`app.guard_child_rows`); header: chặn xoá khi rời nháp, chỉ cho chuyển trạng thái theo danh sách, và **ngoài trạng thái được sửa thì chỉ được đổi các cột khai báo** (`app.guard_header_status`, so `jsonb` — A4). Header kế toán dùng `acc.documents` và guard của 05.
- Không partition ở Giai đoạn 1.
- Bảng dữ liệu hệ thống không thuộc tenant nằm trong schema `sys` (`sys.currencies`, `sys.cash_flow_lines`), được `app.check_rls_coverage()` loại trừ theo schema (06b-N4).
- Trạng thái có ý nghĩa kiểm soát (trạng thái QC của lô, duyệt, khoá kỳ) **chỉ đổi qua hàm** `SECURITY DEFINER` có kiểm vai trò; `app_user` không có quyền UPDATE cột đó.
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

-- Header có trạng thái (A4). TG_ARGV:
--   [0] trạng thái được xoá (thường 'DRAFT')
--   [1] các cặp chuyển hợp lệ 'A>B'
--   [2] trạng thái được sửa nội dung, vd '{DRAFT}' hoặc '{DRAFT,RETURNED}'
--   [3] cột ngoài status được đổi khi header KHÔNG ở trạng thái sửa được, vd '{void_reason}'
-- Bản 0.2 chỉ kiểm cặp chuyển trạng thái nên phiếu QC đã chốt vẫn đổi được kết luận FAIL → PASS.
CREATE FUNCTION app.guard_header_status() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_keep text[];
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
  IF NOT OLD.status = ANY (TG_ARGV[2]::text[]) THEN
    v_keep := TG_ARGV[3]::text[] || ARRAY['status'];
    IF (to_jsonb(NEW) - v_keep) <> (to_jsonb(OLD) - v_keep) THEN
      RAISE EXCEPTION '% ở trạng thái %: chỉ được đổi %', TG_TABLE_NAME, OLD.status, v_keep USING ERRCODE = '55000';
    END IF;
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

- **Mã lót** = `lot_no` (chốt, A9 — mọi tài liệu và demo theo dòng này):
  - **Định dạng gợi ý mặc định `DDMMYY-nn`** (ngày nhập / ngày bắt đầu lệnh + số mẻ 2 chữ số đếm trong ngày theo mặt hàng); người dùng sửa được; nhận chữ, số, `.`, `-`, 3–20 ký tự; lưu **chuỗi** (không mất số 0 đầu). Mẫu sinh là cấu hình (A4, D6).
  - **Phạm vi duy nhất: theo (công ty, mặt hàng)** — `UNIQUE (tenant_id, company_id, item_id, lot_no)`. Lý do: file Excel kho BTP của khách có **16 mã lô dùng chung cho 2–4 mặt hàng khác nhau** (ví dụ cùng một mã ngày cho nhiều loại BTP làm cùng ngày); bắt duy nhất toàn công ty sẽ chặn dữ liệu thật. Demo bản trước kiểm trùng toàn công ty — sửa theo dòng này. Muốn phân biệt toàn công ty thì dùng **mã hóa** (§2.8, duy nhất toàn công ty).
  - Mã đã cấp không cấp lại kể cả khi huỷ phiếu.
- **Loại lô**: `PURCHASED` (tạo khi lập dòng phiếu nhập mua; nếu người dùng không chọn lô có sẵn thì mỗi dòng nhập một lô mới), `SEMI_FINISHED` / `FINISHED` (tạo bởi lệnh công đoạn), `OPENING` (tồn đầu kỳ khi chuyển đổi), `BYPRODUCT` (phế liệu, phụ phẩm thu hồi).
- **Trạng thái QC**: `PENDING` → `RELEASED` / `REJECTED` / `HOLD`. Chỉ đổi qua hàm `qc.finalize_inspection`, `qc.void_inspection`, `qc.execute_disposition` (§10), trong cùng transaction với phiếu đó; `app_user` không có quyền UPDATE cột `qc_status`, lô mới luôn bắt đầu `PENDING` (trigger) — A3; mọi thay đổi vào nhật ký sửa đổi.
- **Bồn trộn nhiều lô (A8, suy luận — chờ khách trả lời câu B1/B12):** đích danh theo lô đúng khi mỗi bồn chỉ chứa một lô. File Excel có 3 bồn có số (`A.54`, `C.48`, `E.2`) từng chứa đồng thời 2 lô. Nếu khách thật sự **châm thêm / trộn** lô vào bồn đang ủ thì không được ghi "hai lô cùng nằm một bồn" rồi xuất đích danh tuỳ chọn; mô hình đề xuất là **gộp lô**: thao tác trộn là một lệnh SX (giai đoạn "phối trộn/châm") xuất các lô đầu vào và **sinh lô mới** với giá trị = tổng giá trị các lô vào (R1), phả hệ ghi đủ các lô nguồn. Trong khi chờ, hệ thống **cảnh báo** khi nhập/chuyển một lô vào bồn đang chứa lô khác (phản biện v3 U7) và không tự gộp.
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
| Nhập BTP/TP từ lệnh | Từ giá thành lệnh (§4), tính **ngay** khi lệnh hoàn thành và tính lại khi chi phí của kỳ đổi | Lô chỉ xuất được khi đã có giá; nhập kho từ lệnh chưa hoàn thành không có (đề xuất: chặn xuất lô `PENDING`, thay cho "giá tạm" của bản 0.2) |
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

Trigger trên `inv.stock_moves` khi **INSERT hoặc UPDATE** (bản 0.2 chỉ INSERT nên đổi `lot_id` sau khi chèn là lách được — A3):
- Phương pháp giá **hiệu lực** = `coalesce(items.costing_method, companies.inventory_costing_method)`: vật tư để trống phương pháp ở công ty đích danh vẫn **bắt buộc lô** (bản 0.2 chỉ xem cột của vật tư — A3 cách 3).
- Dòng xuất `SALE`, `PROD_ISSUE`, `CONSUME` (dùng nội bộ, khuyến mại) từ lô `REJECTED` hoặc `HOLD` luôn bị chặn; từ lô `PENDING` bị chặn khi vật tư bật `qc_required`.
- `move_kind` là danh sách đóng (CHECK ở 05 §4.7) nên không đặt được loại "lạ" để lách (A3 cách 1). Chuyển kho, trả NCC (`RETURN_OUT`), xuất huỷ (`SCRAP`), kiểm kê (`ADJUST`) **không** bị chặn, để đưa hàng không đạt ra khu cách ly, trả, huỷ.
- Trigger lấy `FOR SHARE` trên dòng lô nên không chạy song song với việc đổi trạng thái QC của chính lô đó.

### 2.6 Phả hệ lô và truy xuất

Không lưu bảng phả hệ riêng: view `inv.v_lot_genealogy` suy ra cặp (lô vào → lô ra) của cùng một lệnh từ `inv.stock_moves` (thêm cột `production_order_id` phi chuẩn hoá). View đặt `security_invoker = true` để RLS áp theo người gọi.

Truy ngược từ một lô TP về mọi lô đầu vào (đã chạy thử):

```sql
-- mẫu truy vấn: truy ngược từ lô TP ($1) về mọi lô đầu vào
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

-- inv.lots tạo ở 05 §4.6 (A10: không tạo lại); ở đây chỉ bổ sung cột và ràng buộc
ALTER TABLE inv.lots
  ADD COLUMN lot_kind text NOT NULL
    CHECK (lot_kind IN ('PURCHASED','SEMI_FINISHED','FINISHED','OPENING','BYPRODUCT','MERGED')),
                                            -- MERGED = lô gộp sinh ra khi trộn/châm bồn (§2.1, A8 — chờ khách)
  ADD COLUMN qc_status text NOT NULL DEFAULT 'PENDING'
    CHECK (qc_status IN ('PENDING','RELEASED','HOLD','REJECTED')),
  ADD COLUMN supplier_id uuid,
  ADD COLUMN receipt_line_id uuid,          -- dòng phiếu nhập mua tạo lô (không FK: dòng nháp có thể bị xoá trước)
  ADD COLUMN work_area_id uuid,             -- khu QC lập mã
  ADD CONSTRAINT lots_dates_ck CHECK (expiry_date IS NULL OR mfg_date IS NULL OR expiry_date >= mfg_date),
  ADD CONSTRAINT lots_order_ck CHECK (lot_kind NOT IN ('SEMI_FINISHED','FINISHED','MERGED') OR production_order_id IS NOT NULL),
  ADD CONSTRAINT lots_supplier_fk FOREIGN KEY (tenant_id, supplier_id) REFERENCES md.partners (tenant_id, id),
  ADD CONSTRAINT lots_order_fk FOREIGN KEY (tenant_id, production_order_id) REFERENCES mfg.production_orders (tenant_id, id),
  ADD CONSTRAINT lots_area_fk FOREIGN KEY (tenant_id, work_area_id) REFERENCES md.work_areas (tenant_id, id);
CREATE INDEX lots_expiry ON inv.lots (tenant_id, item_id, expiry_date) WHERE qc_status = 'RELEASED';

-- Lô mới luôn Chờ kiểm, bất kể ứng dụng gửi gì (A3); đổi trạng thái chỉ qua hàm của §10
CREATE FUNCTION inv.lots_on_insert() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.qc_status := 'PENDING';
  RETURN NEW;
END $$;
CREATE TRIGGER lots_insert_pending BEFORE INSERT ON inv.lots
  FOR EACH ROW EXECUTE FUNCTION inv.lots_on_insert();

ALTER TABLE inv.stock_moves
  ADD COLUMN production_order_id uuid,      -- phi chuẩn hoá từ dòng chứng từ, cho truy xuất lô
  ADD CONSTRAINT sm_lot_fk FOREIGN KEY (tenant_id, lot_id) REFERENCES inv.lots (tenant_id, id);
ALTER TABLE inv.stock_ledger
  ADD CONSTRAINT sle_lot_fk FOREIGN KEY (tenant_id, lot_id) REFERENCES inv.lots (tenant_id, id);

-- Hàng tính giá đích danh (theo phương pháp HIỆU LỰC) bắt buộc có lô; lô chưa Đạt không được xuất SX/bán/dùng.
-- INSERT OR UPDATE (A3); 05 §7.1 đã chặn đổi lot_id sau khi chèn, trigger này là lớp thứ hai.
CREATE FUNCTION inv.guard_move_lot() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_method text; v_track boolean; v_qc_req boolean; v_item_company uuid;
        v_lot_item uuid; v_lot_company uuid; v_qc text;
BEGIN
  SELECT coalesce(i.costing_method, c.inventory_costing_method), i.track_lot, i.qc_required, i.company_id
    INTO STRICT v_method, v_track, v_qc_req, v_item_company
    FROM md.items i
    JOIN core.companies c ON c.tenant_id = i.tenant_id AND c.id = i.company_id
   WHERE i.tenant_id = NEW.tenant_id AND i.id = NEW.item_id;
  IF v_item_company <> NEW.company_id THEN
    RAISE EXCEPTION 'Vật tư % không thuộc công ty của dòng kho', NEW.item_id USING ERRCODE = '23503';
  END IF;
  IF (v_method = 'SPECIFIC' OR v_track) AND NEW.lot_id IS NULL THEN
    RAISE EXCEPTION 'Vật tư % tính giá đích danh / theo lô: dòng kho bắt buộc có lô', NEW.item_id USING ERRCODE = '23502';
  END IF;
  IF NEW.lot_id IS NOT NULL THEN
    SELECT item_id, company_id, qc_status INTO STRICT v_lot_item, v_lot_company, v_qc
      FROM inv.lots WHERE tenant_id = NEW.tenant_id AND id = NEW.lot_id
      FOR SHARE;                                   -- xung đột với cập nhật trạng thái QC đang diễn ra
    IF v_lot_item <> NEW.item_id OR v_lot_company <> NEW.company_id THEN
      RAISE EXCEPTION 'Lô % không thuộc vật tư %', NEW.lot_id, NEW.item_id USING ERRCODE = '23503';
    END IF;
    IF NEW.direction = -1 AND NEW.move_kind IN ('SALE','PROD_ISSUE','CONSUME')
       AND (v_qc IN ('REJECTED','HOLD') OR (v_qc = 'PENDING' AND v_qc_req)) THEN
      RAISE EXCEPTION 'Lô % đang ở trạng thái QC % — không được xuất SX/bán/dùng', NEW.lot_id, v_qc
        USING ERRCODE = '55000';
    END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER stock_moves_lot_guard BEFORE INSERT OR UPDATE ON inv.stock_moves
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

Mã lô: định dạng gợi ý `DDMMYY-nn`, duy nhất theo **(công ty, mặt hàng)** — chốt ở §2.1 (A9). Mã hóa (`lot_code`) mới là mã duy nhất toàn công ty.

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
CREATE FUNCTION inv.next_lot_code(p_company uuid, p_prefix text, p_date date)
RETURNS text LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
-- app_user chỉ SELECT bộ đếm; tenant lấy từ phiên, không nhận qua tham số (§12 mục 11)
DECLARE v_tenant uuid := app.current_tenant(); v_yymm char(4) := to_char(p_date, 'YYMM'); v_no int;
BEGIN
  INSERT INTO inv.lot_code_counters (tenant_id, company_id, prefix, yymm) VALUES (v_tenant, p_company, p_prefix, v_yymm)
    ON CONFLICT DO NOTHING;
  UPDATE inv.lot_code_counters SET last_no = last_no + 1
   WHERE tenant_id = v_tenant AND company_id = p_company AND prefix = p_prefix AND yymm = v_yymm
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

Truy vấn kiểm âm của 05 §4.7 thêm một điều kiện vị trí, vẫn chạy sau khi giữ khoá cost key:

```sql
-- mẫu truy vấn: tồn khả dụng tại T theo (vật tư, kho, lô, vị trí); $9 = vị trí (NULL nếu không theo vị trí)
WITH s AS (
  SELECT posting_date d, posting_time t, kind_rank k, seq,
         sum(qty_change) OVER (ORDER BY posting_date, posting_time, kind_rank, seq) AS run_qty
  FROM inv.stock_ledger
  WHERE tenant_id = $1 AND item_id = $2 AND warehouse_id = $3
    AND lot_id IS NOT DISTINCT FROM $4 AND location_id IS NOT DISTINCT FROM $9 AND NOT is_cancelled
)
SELECT least(
  coalesce((SELECT run_qty FROM s WHERE (d,t,k,seq) < ($5,$6,$7,$8)
            ORDER BY d DESC, t DESC, k DESC, seq DESC LIMIT 1), 0),
  coalesce((SELECT min(run_qty) FROM s WHERE (d,t,k,seq) > ($5,$6,$7,$8)), 'Infinity'::numeric)
) AS available;
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
    CHECK (semi_handling = 'STOCKED'),       -- GĐ1 chốt phương án A: BTP luôn có lô + sổ kho (§4.2); 'DIRECT' để GĐ2
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

**Công thức duy nhất cho hỏng ngoài định mức (A9):** chia C theo R1(b) với trọng số (SL đạt từng lô đầu ra, SL ngoài định mức) như trên — tức SL không đạt **trong** định mức không có trọng số, giá trị của nó dồn vào SL đạt. **Không** dùng cách "giá đơn vị trên tổng SL đầu ra × SL ngoài định mức" (58.200.000 × 13,4 / 830 = 939.614), vì cách đó coi phần trong định mức cũng mang giá và để phần dư cho lô đạt không theo R1(b). Demo và golden test theo con số 958.790.

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

**Chốt (2026-10-07): GĐ1 chỉ dùng phương án A** cho mọi BTP, kể cả BTP làm xong và dùng ngay trong ca (cá chiên, sốt cà của quy trình cá bạc má — lô nội bộ, phiếu nhập/xuất sinh tự động). Lý do: mục tiêu trọng tâm của khách là **giá vốn theo lô và cây cấu thành** (§4.8); cây đó đi qua lô BTP, nên BTP nào cũng phải có lô, giá lô và sổ kho. Phương án B (`DIRECT`) để GĐ2 nếu số chứng từ tự sinh thành gánh nặng; CHECK của `routing_stages.semi_handling` (§3.2) chỉ nhận `STOCKED`.

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

### 4.7 Tính lại ngay và khoá kỳ

Trình tự cuối kỳ và điều kiện khoá kỳ: **chỉ một nguồn là 05 §7.2** (A9). Phần riêng của 07:

- Giá thành lệnh được tính lại **ngay** khi có chứng từ ảnh hưởng (xuất NVL/BTP cho lệnh, chi phí NC/SXC của kỳ, hoàn thành lệnh), theo **thứ tự thời gian hoàn thành và chuỗi giai đoạn** (lệnh trước xong mới có giá lô BTP cho lệnh sau); giá lô BTP/TP và các dòng xuất lô đó cập nhật theo. Không có bước "tính giá thành" cuối kỳ.
- Thêm vào điều kiện của `acc.lock_period`: mọi dòng tiền có mã dòng tiền (§9); khoá kỳ khoá luôn tỷ giá các ngày trong kỳ (§5.2).

### 4.8 Giá nguyên liệu theo lô, giá vốn theo lô và cây cấu thành (mục tiêu trọng tâm)

Yêu cầu: `../YEU-CAU-KHACH-HANG.md` GT-09, GT-10, GT-R4, GT-R5.

- **Giá nguyên liệu theo lô (GT-09)**: giá lô NVL = (thành tiền HĐ theo VND + chi phí mua phân bổ ± điều chỉnh về sau) / SL nhập — đúng giá trị dòng nhập trong sổ kho (§2.3), không tính riêng. Kiểm soát giá: so giá lô với lô gần nhất cùng mặt hàng (và cùng NCC), với giá trên đơn mua (MUA-01); vượt ngưỡng % cấu hình theo nhóm hàng thì cảnh báo khi ghi phiếu nhập và hiện trong báo cáo GT-R4. Điều chỉnh giá trị lô về sau (giảm giá, chi phí mua đến muộn) giữ lịch sử ở `cst.valuation_adjustments` (05 §4.8).
- **Giá vốn theo lô (GT-10)**: mỗi dòng xuất bán mang giá trị của **đúng lô** xuất (R1(c)); giá vốn hàng bán theo lô = Σ giá trị dòng `SALE` − dòng `RETURN_IN` của lô. Lô TP có đơn giá riêng (giá trị lô / SL lô), hai lô cùng sản phẩm có giá khác nhau.
- **Cây cấu thành** của một lô TP: lô TP ← lệnh tạo ra nó (bảng giá thành lệnh §3.2: DDĐK, NVL, BTP, NC, SXC, phế liệu, hỏng ngoài định mức) ← các lô BTP/NVL lệnh đã xuất (phả hệ §2.6, chỉ các phiếu xuất của **chính lệnh đó**, ngày ≤ ngày nhập kho lô TP — sửa lỗi U1 của demo) ← lệnh tạo lô BTP ← … ← lô NVL (NCC, phiếu nhập, giá lô). Mỗi nút hiện SL dùng và giá trị chảy vào nút trên; tổng các nhánh = giá trị lô (bảo toàn, property test). Phần NC/SXC và phần một lô BTP cấp cho nhiều lệnh chia **theo tỷ lệ SL** (§4.5) — phải nói rõ với khách. Truy xuôi (lô NVL → lô TP → khách hàng) là cùng đồ thị đổi chiều.
- Lưu trữ: cạnh giá trị dùng `cst.cost_flow_edges` của 05 §6 với nút `LOT` (lô tại kho) và `ORDER` (lệnh SX); không cần bảng mới. Truy vấn mẫu một tầng của cây (giá trị từng lô đầu vào mà lệnh tạo ra lô `$1` đã dùng):

```sql
-- mẫu truy vấn: một tầng của cây cấu thành giá lô $1 (đệ quy theo §2.6 để ra cả cây)
SELECT g.input_lot_id, l.lot_no, l.lot_code, l.lot_kind, g.input_qty,
       -sum(sl.value_change) AS value_used
  FROM inv.v_lot_genealogy g
  JOIN inv.lots l ON l.tenant_id = g.tenant_id AND l.id = g.input_lot_id
  JOIN inv.stock_moves m ON m.tenant_id = g.tenant_id AND m.production_order_id = g.production_order_id
                        AND m.lot_id = g.input_lot_id AND m.move_kind = 'PROD_ISSUE' AND m.status = 'ACTIVE'
  JOIN inv.stock_ledger sl ON sl.tenant_id = m.tenant_id AND sl.stock_move_id = m.id AND NOT sl.is_cancelled
 WHERE g.output_lot_id = $1
 GROUP BY g.input_lot_id, l.lot_no, l.lot_code, l.lot_kind, g.input_qty;
```

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

-- SECURITY DEFINER: app_user chỉ SELECT/INSERT fx_rate_day_locks (không gỡ khoá được) nên không tự FOR SHARE được
CREATE FUNCTION md.guard_fx_rate_lock() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
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
  FOR EACH ROW EXECUTE FUNCTION app.guard_header_status('DRAFT', '{DRAFT>POSTED,DRAFT>VOIDED,POSTED>VOIDED}',
                                                       '{DRAFT}', '{}');
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
  FOR EACH ROW EXECUTE FUNCTION app.guard_header_status('DRAFT', '{DRAFT>POSTED,DRAFT>VOIDED,POSTED>VOIDED}',
                                                       '{DRAFT}', '{}');
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

- **Luồng duyệt dùng chung** (`wf.*`): chính sách theo loại đối tượng × bước × vai trò × ngưỡng tiền; một yêu cầu duyệt đang mở cho mỗi đối tượng. Bản 0.2 để luật duyệt ở tầng ứng dụng nên sửa/xoá được lịch sử duyệt và quyết toán vượt đề nghị (A5). Bản 0.3 cưỡng chế ở CSDL:
  - `wf.approval_actions` **append-only** (trigger chặn UPDATE/DELETE với mọi vai trò); `app_user` không INSERT trực tiếp, chỉ qua hàm `wf.act` (`SECURITY DEFINER`).
  - `wf.act` kiểm: yêu cầu còn `PENDING`; người duyệt có vai trò của **bước hiện tại** (`core.user_roles`); **người lập không tự duyệt**; một người không duyệt hai bước của cùng yêu cầu (SoD); bước tiếp theo chọn theo ngưỡng tiền; cập nhật trạng thái yêu cầu. `requested_by` và số tiền yêu cầu lấy từ phiên / từ đối tượng, không từ ứng dụng.
  - Đối tượng (đề nghị thanh toán, đơn hàng) chỉ chuyển sang `APPROVED` khi yêu cầu duyệt tương ứng đã `APPROVED` và số tiền duyệt ≥ số tiền hiện tại của đối tượng.
  - Quyết toán đề nghị (`cash.payment_request_settlements`): đề nghị phải `APPROVED`/`PARTIALLY_PAID`; Σ đã chi của dòng ≤ số đề nghị; **người lập phiếu chi không phải người đã duyệt đề nghị** (SoD theo `acc.documents.created_by`).
- **Đơn hàng** (`ord.orders`, `ord.order_lines`): một bảng cho đơn mua và đơn bán. Dòng đơn khoá khi đơn đã gửi duyệt; muốn sửa phải trả về nháp (`SUBMITTED>DRAFT`) và duyệt lại. Tiến độ đơn (đã nhận/đã giao, đã lập HĐ, bị trả lại) suy ra từ `acc.document_lines.order_line_id`, không lưu cột cộng dồn:

  ```sql
  -- mẫu truy vấn: tiến độ dòng đơn hàng (đã nhận/giao, bị trả lại)
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
    '{DRAFT>SUBMITTED,SUBMITTED>DRAFT,SUBMITTED>APPROVED,SUBMITTED>CANCELLED,APPROVED>IN_PROGRESS,APPROVED>CANCELLED,IN_PROGRESS>COMPLETED,IN_PROGRESS>CLOSED,COMPLETED>CLOSED}',
    '{DRAFT}', '{approval_request_id}');

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
    '{DRAFT>SUBMITTED,DRAFT>CANCELLED,SUBMITTED>RETURNED,SUBMITTED>APPROVED,SUBMITTED>REJECTED,RETURNED>SUBMITTED,RETURNED>CANCELLED,APPROVED>PARTIALLY_PAID,APPROVED>PAID,PARTIALLY_PAID>PAID,APPROVED>CANCELLED}',
    '{DRAFT,RETURNED}', '{approval_request_id}');

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

Cưỡng chế luồng duyệt (A5):

```sql
-- Yêu cầu duyệt: người lập lấy từ phiên; luôn bắt đầu PENDING ở bước 1; không sửa/xoá trực tiếp
CREATE FUNCTION wf.guard_approval_requests() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.requested_by := app.current_user_id();
    NEW.requested_at := now();
    NEW.status := 'PENDING';
    NEW.current_step := 1;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Không được xoá yêu cầu duyệt' USING ERRCODE = '55000';
  END IF;
  IF OLD.status <> 'PENDING'
     OR (to_jsonb(NEW) - '{status,current_step}'::text[]) <> (to_jsonb(OLD) - '{status,current_step}'::text[]) THEN
    RAISE EXCEPTION 'Yêu cầu duyệt: chỉ đổi trạng thái/bước khi đang chờ duyệt' USING ERRCODE = '55000';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER approval_requests_guard BEFORE INSERT OR UPDATE OR DELETE ON wf.approval_requests
  FOR EACH ROW EXECUTE FUNCTION wf.guard_approval_requests();

-- Lịch sử duyệt append-only với MỌI vai trò (kể cả chủ sở hữu)
CREATE FUNCTION wf.guard_append_only() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '%: chỉ được thêm, không sửa/xoá', TG_TABLE_NAME USING ERRCODE = '55000';
END $$;
CREATE TRIGGER approval_actions_append_only BEFORE UPDATE OR DELETE ON wf.approval_actions
  FOR EACH ROW EXECUTE FUNCTION wf.guard_append_only();

-- Số tiền hiện tại của đối tượng cần duyệt (quy VND)
CREATE FUNCTION wf.subject_amount(p_type text, p_tenant uuid, p_id uuid) RETURNS numeric
LANGUAGE plpgsql STABLE AS $$
DECLARE v numeric;
BEGIN
  IF p_type = 'PAYMENT_REQUEST' THEN
    SELECT sum(l.amount_fc) * CASE WHEN r.currency = 'VND' THEN 1 ELSE
             (SELECT x.rate FROM md.exchange_rates x
               WHERE x.tenant_id = r.tenant_id AND x.company_id = r.company_id AND x.currency = r.currency
                 AND x.rate_type = 'SELL' AND x.rate_date <= r.request_date
               ORDER BY x.rate_date DESC LIMIT 1) END
      INTO v
      FROM cash.payment_requests r JOIN cash.payment_request_lines l ON l.tenant_id = r.tenant_id AND l.request_id = r.id
     WHERE r.tenant_id = p_tenant AND r.id = p_id
     GROUP BY r.tenant_id, r.company_id, r.currency, r.request_date;
  ELSIF p_type IN ('PURCHASE_ORDER','SALES_ORDER') THEN
    SELECT sum(l.amount) * coalesce(o.expected_fx_rate, 1) INTO v
      FROM ord.orders o JOIN ord.order_lines l ON l.tenant_id = o.tenant_id AND l.order_id = o.id
     WHERE o.tenant_id = p_tenant AND o.id = p_id
     GROUP BY o.expected_fx_rate;
  END IF;
  IF v IS NULL THEN
    RAISE EXCEPTION 'Không tính được số tiền của % % (thiếu dòng hoặc tỷ giá)', p_type, p_id USING ERRCODE = '22023';
  END IF;
  RETURN v;
END $$;

-- Duyệt / từ chối / trả lại: đường DUY NHẤT ghi wf.approval_actions
CREATE FUNCTION wf.act(p_request uuid, p_action text, p_comment text)
RETURNS text LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
DECLARE r wf.approval_requests; v_user uuid := app.current_user_id(); v_role text; v_next smallint;
BEGIN
  SELECT * INTO r FROM wf.approval_requests
   WHERE tenant_id = app.current_tenant() AND id = p_request FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Không có yêu cầu duyệt %', p_request USING ERRCODE = '02000'; END IF;
  IF r.status <> 'PENDING' THEN RAISE EXCEPTION 'Yêu cầu đã kết thúc (%)', r.status USING ERRCODE = '55000'; END IF;
  IF v_user = r.requested_by THEN
    RAISE EXCEPTION 'Người lập không được tự duyệt' USING ERRCODE = '42501';
  END IF;
  IF EXISTS (SELECT 1 FROM wf.approval_actions a
              WHERE a.tenant_id = r.tenant_id AND a.request_id = r.id AND a.actor_id = v_user) THEN
    RAISE EXCEPTION 'Một người không duyệt hai bước của cùng yêu cầu' USING ERRCODE = '42501';
  END IF;
  SELECT approver_role INTO v_role FROM wf.approval_policies p
   WHERE p.tenant_id = r.tenant_id AND p.company_id = r.company_id AND p.subject_type = r.subject_type
     AND p.step_no = r.current_step AND p.valid_from <= current_date
     AND (p.valid_to IS NULL OR current_date <= p.valid_to);
  IF v_role IS NULL OR NOT app.has_role(v_role) THEN
    RAISE EXCEPTION 'Người dùng không có vai trò duyệt bước %', r.current_step USING ERRCODE = '42501';
  END IF;
  INSERT INTO wf.approval_actions (tenant_id, request_id, step_no, actor_id, action, comment)
  VALUES (r.tenant_id, r.id, r.current_step, v_user, p_action, p_comment);
  IF p_action = 'APPROVE' THEN
    SELECT min(step_no) INTO v_next FROM wf.approval_policies p
     WHERE p.tenant_id = r.tenant_id AND p.company_id = r.company_id AND p.subject_type = r.subject_type
       AND p.step_no > r.current_step AND p.min_amount <= r.amount_base
       AND p.valid_from <= current_date AND (p.valid_to IS NULL OR current_date <= p.valid_to);
    IF v_next IS NULL THEN
      UPDATE wf.approval_requests SET status = 'APPROVED' WHERE tenant_id = r.tenant_id AND id = r.id;
      RETURN 'APPROVED';
    END IF;
    UPDATE wf.approval_requests SET current_step = v_next WHERE tenant_id = r.tenant_id AND id = r.id;
    RETURN 'PENDING';
  END IF;
  UPDATE wf.approval_requests SET status = CASE p_action WHEN 'REJECT' THEN 'REJECTED' ELSE 'RETURNED' END
   WHERE tenant_id = r.tenant_id AND id = r.id;
  RETURN CASE p_action WHEN 'REJECT' THEN 'REJECTED' ELSE 'RETURNED' END;
END $$;

-- Người lập huỷ yêu cầu đang chờ
CREATE FUNCTION wf.cancel(p_request uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
BEGIN
  UPDATE wf.approval_requests SET status = 'CANCELLED'
   WHERE tenant_id = app.current_tenant() AND id = p_request AND status = 'PENDING'
     AND requested_by = app.current_user_id();
  IF NOT FOUND THEN RAISE EXCEPTION 'Chỉ người lập huỷ được yêu cầu đang chờ' USING ERRCODE = '42501'; END IF;
END $$;

-- Đối tượng chỉ sang APPROVED khi có yêu cầu duyệt APPROVED của chính nó, số tiền duyệt đủ. TG_ARGV[0] = subject_type
CREATE FUNCTION wf.guard_subject_approval() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_type text := TG_ARGV[0];
BEGIN
  IF TG_OP = 'UPDATE' AND NEW.status = 'APPROVED' AND OLD.status <> 'APPROVED' THEN
    IF NOT EXISTS (SELECT 1 FROM wf.approval_requests a
                    WHERE a.tenant_id = NEW.tenant_id AND a.id = NEW.approval_request_id
                      AND a.subject_type = v_type AND a.subject_id = NEW.id AND a.status = 'APPROVED'
                      AND a.amount_base >= wf.subject_amount(v_type, NEW.tenant_id, NEW.id)) THEN
      RAISE EXCEPTION '% %: chưa có phê duyệt hợp lệ cho đúng số tiền', v_type, NEW.id USING ERRCODE = '42501';
    END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER payment_requests_approval BEFORE UPDATE ON cash.payment_requests
  FOR EACH ROW EXECUTE FUNCTION wf.guard_subject_approval('PAYMENT_REQUEST');
CREATE FUNCTION ord.guard_order_approval() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status = 'APPROVED' AND OLD.status <> 'APPROVED' THEN
    IF NOT EXISTS (SELECT 1 FROM wf.approval_requests a
                    WHERE a.tenant_id = NEW.tenant_id AND a.id = NEW.approval_request_id AND a.subject_id = NEW.id
                      AND a.subject_type = CASE NEW.order_type WHEN 'PURCHASE' THEN 'PURCHASE_ORDER' ELSE 'SALES_ORDER' END
                      AND a.status = 'APPROVED'
                      AND a.amount_base >= wf.subject_amount(a.subject_type, NEW.tenant_id, NEW.id)) THEN
      RAISE EXCEPTION 'Đơn %: chưa có phê duyệt hợp lệ cho đúng số tiền', NEW.id USING ERRCODE = '42501';
    END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER orders_approval BEFORE UPDATE ON ord.orders
  FOR EACH ROW EXECUTE FUNCTION ord.guard_order_approval();

-- Người đề nghị lấy từ phiên
CREATE FUNCTION cash.stamp_payment_requests() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.requester_id := app.current_user_id();
  RETURN NEW;
END $$;
CREATE TRIGGER payment_requests_stamp BEFORE INSERT ON cash.payment_requests
  FOR EACH ROW EXECUTE FUNCTION cash.stamp_payment_requests();

-- Quyết toán: không vượt đề nghị, đề nghị phải đã duyệt, người lập phiếu chi ≠ người duyệt
CREATE FUNCTION cash.guard_settlement() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
DECLARE v_line_amt numeric; v_req_status text; v_appr uuid; v_paid numeric; v_doc_by uuid; v_doc_status text;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    RAISE EXCEPTION 'Quyết toán đề nghị: không sửa, chỉ xoá khi phiếu chi còn nháp' USING ERRCODE = '55000';
  END IF;
  SELECT d.created_by, d.status INTO v_doc_by, v_doc_status FROM acc.documents d
   WHERE d.tenant_id = coalesce(NEW.tenant_id, OLD.tenant_id)
     AND d.id = coalesce(NEW.payment_document_id, OLD.payment_document_id);
  IF TG_OP = 'DELETE' THEN
    IF v_doc_status IS DISTINCT FROM 'DRAFT' THEN
      RAISE EXCEPTION 'Phiếu chi đã ghi sổ/huỷ: không xoá quyết toán' USING ERRCODE = '55000';
    END IF;
    RETURN OLD;
  END IF;
  SELECT l.amount_fc, r.status, r.approval_request_id INTO v_line_amt, v_req_status, v_appr
    FROM cash.payment_request_lines l
    JOIN cash.payment_requests r ON r.tenant_id = l.tenant_id AND r.id = l.request_id
   WHERE l.tenant_id = NEW.tenant_id AND l.id = NEW.request_line_id
     FOR UPDATE OF l;                           -- tuần tự hoá các lần chi cùng một dòng đề nghị
  IF v_req_status NOT IN ('APPROVED','PARTIALLY_PAID') THEN
    RAISE EXCEPTION 'Đề nghị chưa được duyệt (trạng thái %)', v_req_status USING ERRCODE = '55000';
  END IF;
  SELECT coalesce(sum(amount_fc), 0) INTO v_paid FROM cash.payment_request_settlements
   WHERE tenant_id = NEW.tenant_id AND request_line_id = NEW.request_line_id;
  IF v_paid + NEW.amount_fc > v_line_amt THEN
    RAISE EXCEPTION 'Chi vượt đề nghị: đã chi % + % > %', v_paid, NEW.amount_fc, v_line_amt USING ERRCODE = '23514';
  END IF;
  IF EXISTS (SELECT 1 FROM wf.approval_actions a
              WHERE a.tenant_id = NEW.tenant_id AND a.request_id = v_appr
                AND a.action = 'APPROVE' AND a.actor_id = v_doc_by) THEN
    RAISE EXCEPTION 'Người đã duyệt đề nghị không được lập phiếu chi cho đề nghị đó' USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER payment_settlements_guard BEFORE INSERT OR UPDATE OR DELETE ON cash.payment_request_settlements
  FOR EACH ROW EXECUTE FUNCTION cash.guard_settlement();
```

---

## 9. Lưu chuyển tiền tệ

**Trực tiếp**:
- Mọi dòng bút toán vào TK có role tiền (111x, 112x, và 113 nếu dùng) phải có `cash_flow_code`, trừ chuyển tiền nội bộ (mã thuộc nhóm `INTERNAL`).
- Posting rule phải **tách dòng tiền theo từng TK đối ứng** (một phiếu chi trả cả 331 và 1331 → hai dòng tiền, hoặc một dòng tiền mang mã của đối ứng chính theo quy tắc cấu hình); `md.cash_flow_rules` gợi ý mã theo TK đối ứng × chiều; người lập sửa được trước khi ghi sổ.
- Kiểm tra khi khoá sổ (bước 8 ở §4.7):

  ```sql
  -- mẫu truy vấn: dòng tiền thiếu mã trong kỳ (phải rỗng mới cho khoá)
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
- `qc.inspections` + `qc.inspection_results`: phiếu kiểm theo lô × điểm; số phiếu duy nhất theo năm; chốt (`FINAL`) thì **mọi cột** không sửa được (guard so `jsonb`, A4), chỉ huỷ có lý do. Chốt và huỷ chỉ qua `qc.finalize_inspection` / `qc.void_inspection` (người dùng có vai trò `QC_KHU` hoặc `TRUONG_QC`); cùng transaction cập nhật `inv.lots.qc_status` (Đạt → `RELEASED`; Không đạt → `REJECTED`; Đạt có điều kiện → `HOLD` chờ quyết định xử lý). Huỷ phiếu đã chốt đưa lô về `PENDING`.
- `qc.dispositions`: quyết định xử lý SL không đạt; phân loại trong/ngoài định mức; role TK ghi nhận tổn thất; yêu cầu duyệt (trưởng QC; vượt ngưỡng → KTT/BOD); khi thực hiện phải có chứng từ kết quả (phiếu xuất huỷ, phiếu trả NCC, lệnh làm lại). Chấp nhận có điều kiện thì không cần chứng từ, và `qc.execute_disposition` là đường duy nhất đưa lô `HOLD`/`REJECTED` về `RELEASED` (chỉ `TRUONG_QC`).

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
  FOR EACH ROW EXECUTE FUNCTION app.guard_header_status('DRAFT', '{DRAFT>FINAL,FINAL>VOIDED}',
                                                       '{DRAFT}', '{void_reason}');

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
    '{DRAFT>APPROVED,DRAFT>CANCELLED,APPROVED>EXECUTED,APPROVED>CANCELLED}',
    '{DRAFT}', '{approval_request_id,result_document_id}');

ALTER TABLE mfg.routing_operations
  ADD COLUMN qc_point_id uuid,
  ADD CONSTRAINT rop_qc_fk FOREIGN KEY (tenant_id, qc_point_id) REFERENCES qc.control_points (tenant_id, id);
```

Đường duy nhất đổi trạng thái QC của lô (A3 — `app_user` không có quyền UPDATE `inv.lots.qc_status`, `qc.inspections.status`, `qc.dispositions.status`):

```sql
CREATE FUNCTION qc.finalize_inspection(p_id uuid, p_conclusion text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
DECLARE r qc.inspections; v_missing int;
BEGIN
  IF NOT (app.has_role('QC_KHU') OR app.has_role('TRUONG_QC')) THEN
    RAISE EXCEPTION 'Chỉ QC được chốt phiếu kiểm' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO r FROM qc.inspections WHERE tenant_id = app.current_tenant() AND id = p_id FOR UPDATE;
  IF NOT FOUND OR r.status <> 'DRAFT' THEN
    RAISE EXCEPTION 'Phiếu kiểm % không ở trạng thái nháp', p_id USING ERRCODE = '55000';
  END IF;
  SELECT count(*) INTO v_missing FROM qc.criteria c         -- chỉ tiêu bắt buộc phải có kết quả
   WHERE c.tenant_id = r.tenant_id AND c.control_point_id = r.control_point_id AND c.is_mandatory
     AND c.valid_from <= r.inspected_at::date AND (c.valid_to IS NULL OR r.inspected_at::date <= c.valid_to)
     AND NOT EXISTS (SELECT 1 FROM qc.inspection_results x
                      WHERE x.tenant_id = r.tenant_id AND x.inspection_id = r.id AND x.criterion_id = c.id);
  IF v_missing > 0 THEN
    RAISE EXCEPTION 'Còn % chỉ tiêu bắt buộc chưa có kết quả', v_missing USING ERRCODE = '23514';
  END IF;
  UPDATE qc.inspections SET status = 'FINAL', conclusion = p_conclusion WHERE tenant_id = r.tenant_id AND id = r.id;
  UPDATE inv.lots SET qc_status = CASE p_conclusion WHEN 'PASS' THEN 'RELEASED' WHEN 'FAIL' THEN 'REJECTED' ELSE 'HOLD' END
   WHERE tenant_id = r.tenant_id AND id = r.lot_id;
END $$;

CREATE FUNCTION qc.void_inspection(p_id uuid, p_reason text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
DECLARE r qc.inspections;
BEGIN
  IF NOT app.has_role('TRUONG_QC') THEN
    RAISE EXCEPTION 'Chỉ trưởng QC được huỷ phiếu kiểm đã chốt' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO r FROM qc.inspections WHERE tenant_id = app.current_tenant() AND id = p_id FOR UPDATE;
  IF NOT FOUND OR r.status <> 'FINAL' THEN
    RAISE EXCEPTION 'Chỉ huỷ phiếu đã chốt' USING ERRCODE = '55000';
  END IF;
  UPDATE qc.inspections SET status = 'VOIDED', void_reason = p_reason WHERE tenant_id = r.tenant_id AND id = r.id;
  UPDATE inv.lots SET qc_status = 'PENDING' WHERE tenant_id = r.tenant_id AND id = r.lot_id;
END $$;

CREATE FUNCTION qc.execute_disposition(p_id uuid, p_result_document uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
DECLARE d qc.dispositions;
BEGIN
  IF NOT app.has_role('TRUONG_QC') THEN
    RAISE EXCEPTION 'Chỉ trưởng QC thực hiện quyết định xử lý' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO d FROM qc.dispositions WHERE tenant_id = app.current_tenant() AND id = p_id FOR UPDATE;
  IF NOT FOUND OR d.status <> 'APPROVED' THEN
    RAISE EXCEPTION 'Quyết định xử lý chưa được duyệt' USING ERRCODE = '55000';
  END IF;
  UPDATE qc.dispositions SET status = 'EXECUTED', result_document_id = p_result_document
   WHERE tenant_id = d.tenant_id AND id = d.id;
  IF d.decision = 'ACCEPT_DEVIATION' THEN
    UPDATE inv.lots SET qc_status = 'RELEASED' WHERE tenant_id = d.tenant_id AND id = d.lot_id;
  END IF;
END $$;

-- Duyệt quyết định xử lý: trưởng QC. Vượt ngưỡng giá trị → thêm bước KTT/BOD qua wf (loại QC_DISPOSITION) — chưa nối ở bản này.
CREATE FUNCTION qc.approve_disposition(p_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $$
BEGIN
  IF NOT app.has_role('TRUONG_QC') THEN
    RAISE EXCEPTION 'Chỉ trưởng QC duyệt quyết định xử lý' USING ERRCODE = '42501';
  END IF;
  UPDATE qc.dispositions SET status = 'APPROVED'
   WHERE tenant_id = app.current_tenant() AND id = p_id AND status = 'DRAFT';
  IF NOT FOUND THEN RAISE EXCEPTION 'Quyết định xử lý % không ở trạng thái nháp', p_id USING ERRCODE = '55000'; END IF;
END $$;
```

---

## 11. RLS, quyền và kiểm thử

Bản 0.2 dùng một khối `DO` liệt kê tay 10 schema, bỏ sót `core`, `cst`, `audit` (A2). Bản 0.3 gọi lại ba hàm chung của 05 (§2.1, §7.3), quét **mọi** schema nghiệp vụ, và khai báo các bảng của 07 cần quyền hẹp:

```sql
INSERT INTO sys.table_privileges (table_name, privs, update_columns, reason) VALUES
  ('inv.lots', '{SELECT,INSERT,DELETE}',
     '{mfg_date,expiry_date,supplier_id,receipt_line_id,work_area_id}', 'qc_status, lot_code không sửa trực tiếp (A3)'),
  ('inv.lot_code_counters',  '{SELECT}',               NULL, 'cấp mã qua inv.next_lot_code'),
  ('md.fx_rate_day_locks',   '{SELECT,INSERT}',        NULL, 'không gỡ khoá tỷ giá bằng DML'),
  ('wf.approval_requests',   '{SELECT,INSERT}',        NULL, 'chuyển trạng thái qua wf.act / wf.cancel (A5)'),
  ('wf.approval_actions',    '{SELECT}',               NULL, 'chỉ wf.act ghi (A5)'),
  ('cash.payment_request_settlements', '{SELECT,INSERT,DELETE}', NULL, 'không sửa; guard chặn chi vượt'),
  ('qc.inspections', '{SELECT,INSERT,DELETE}',
     '{inspection_no,control_point_id,lot_id,production_order_id,receipt_line_id,inspector_id,inspected_at,qty_inspected,qty_passed,qty_failed,conclusion}',
     'status chỉ qua qc.finalize_inspection / qc.void_inspection'),
  ('qc.dispositions', '{SELECT,INSERT,DELETE}',
     '{qty,decision,loss_class,loss_account_role,approval_request_id}', 'status chỉ qua qc.approve_disposition / qc.execute_disposition')
ON CONFLICT (table_name) DO UPDATE SET privs = EXCLUDED.privs, update_columns = EXCLUDED.update_columns,
                                       reason = EXCLUDED.reason;

SELECT app.apply_tenant_rls();
SELECT app.apply_grants();
SELECT app.apply_audit_triggers();
REVOKE EXECUTE ON FUNCTION wf.act(uuid, text, text), wf.cancel(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION wf.act(uuid, text, text), wf.cancel(uuid) TO app_user;
```

Phép thử đã chạy (2026-10-07, PG16.15, sau khi dựng nguyên văn 05 + 07; 66/66 đạt). Ngoài dòng ghi rõ, mọi phép thử chạy bằng `app_user` với token phiên thật; dòng "chủ sở hữu" chạy bằng `app_owner` để chứng minh trigger chặn cả khi có quyền bảng.

| Mã | Tấn công / thao tác | Mong đợi | Kết quả |
|---|---|---|---|
| A1 | Ghi sổ chứng từ: header + bút toán + 2 dòng cân, chuyển `POSTED` | Thành công | Đạt |
| A1 | Sửa số tiền dòng bút toán đã ghi sổ | `app_user`: không có quyền; chủ sở hữu: trigger chặn | Đạt / Đạt |
| A1 | Xoá dòng bút toán; xoá bút toán | Không có quyền; chủ sở hữu: trigger chặn | Đạt |
| A1 | Thêm dòng vào bút toán đã ghi sổ (giao dịch khác) | "Chỉ thêm dòng vào bút toán vừa tạo trong cùng giao dịch" | Đạt |
| A1 | Sau khi KTT khoá tháng 9: vô hiệu hoá dòng / bút toán tháng 9; lập chứng từ ngày 25/09; engine ghi giá dòng kho tháng 9 | Lỗi 55P04 "Kỳ đã khoá" | Đạt (4/4) |
| A1 | Người không phải KTT gọi khoá kỳ; `UPDATE acc.period_locks` để mở khoá | 42501 / không có quyền | Đạt |
| A1 | Mở khoá không lý do / có lý do | Lỗi / thành công | Đạt |
| A2 | Tenant B đọc `core.companies` | Chỉ thấy 1 công ty của B | Đạt |
| A2 | Tenant B ghi `cst.cost_flow_edges` mang tenant A | Vi phạm RLS | Đạt |
| A2 | `app_user` ghi giả `audit.change_log` | Không có quyền | Đạt |
| A2 | Tenant B đọc `audit.change_log` | 0 dòng của A, có dòng của B; dòng bút toán của A có log | Đạt |
| A2 | `app.check_rls_coverage()` (87 bảng có `tenant_id`, 85 trigger audit) | 0 dòng | Đạt |
| A3 | `move_kind = 'SALE_X'` | Vi phạm CHECK | Đạt |
| A3 | Xuất bán vật tư để trống phương pháp, không bật lô, ở công ty đích danh, không ghi lô | "bắt buộc có lô" | Đạt |
| A3 | Xuất bán lô `REJECTED` (vật tư bắt buộc QC); xuất dùng (`CONSUME`) lô `REJECTED` của vật tư **không** bắt buộc QC | Chặn / chặn | Đạt |
| A3 | Xuất bán lô `RELEASED` rồi đổi `lot_id` sang lô `REJECTED` | Không có quyền; chủ sở hữu: "chỉ được huỷ" | Đạt |
| A3 | `UPDATE inv.lots SET qc_status = 'RELEASED'`; thêm lô với `qc_status = 'RELEASED'` | Không có quyền / lô vẫn `PENDING` | Đạt |
| A3 | Kế toán (không phải QC) gọi `qc.finalize_inspection` | 42501 | Đạt |
| A4 | Đổi kết luận phiếu QC đã chốt FAIL → PASS | "ở trạng thái FINAL: chỉ được đổi {void_reason,status}" (cả chủ sở hữu) | Đạt |
| A4 | Đổi `status` phiếu QC bằng UPDATE | Không có quyền | Đạt |
| A5 | Người lập tự duyệt đề nghị | "Người lập không được tự duyệt" | Đạt |
| A5 | Thêm thẳng `wf.approval_actions`; `UPDATE wf.approval_requests`; sửa/xoá lịch sử duyệt | Không có quyền; chủ sở hữu: "chỉ được thêm" | Đạt |
| A5 | Người không có vai trò bước 1 duyệt | 42501 | Đạt |
| A5 | Chuyển đề nghị sang `APPROVED` khi chưa duyệt | "chưa có phê duyệt hợp lệ" | Đạt |
| A5 | Khai số tiền duyệt 1.000 cho đề nghị 20.000.000 để bỏ bước BOD rồi chuyển `APPROVED` | Chặn (số tiền duyệt < số tiền đề nghị) | Đạt |
| A5 | Người đã duyệt lập phiếu chi cho chính đề nghị đó | Chặn (SoD) | Đạt |
| A5 | Chi 3.000.000 + 3.000.000 cho dòng đề nghị 5.000.000; sửa quyết toán | Lần 2 bị chặn "Chi vượt đề nghị"; sửa không có quyền | Đạt |
| A5 | Duyệt lại yêu cầu đã kết thúc | "Yêu cầu đã kết thúc" | Đạt |
| A11 | Phiên B đặt `app.tenant_id`, `app.user_id` = của A rồi đọc vật tư | 0 dòng (biến không có tác dụng) | Đạt |
| A11 | Token giả; không đặt token | Lỗi 28000 / 0 dòng | Đạt |
| A11 | `app_user` đọc `core.sessions` | Không có quyền | Đạt |
| A11 | `app_user` sửa `value_change`; đặt `app.engine = 'costing'` rồi gọi `inv.set_valuation` | Không có quyền (bảng / hàm) | Đạt |
| A11 | `engine_user` gọi `inv.set_valuation`; chủ sở hữu sửa `qty_change` | Thành công / trigger chặn | Đạt |

Cần thêm ở nền móng 1A (chưa làm): hai phiên đồng thời cho `guard_child_rows`, `guard_move_lot`, `acc.assert_period_open` + `acc.lock_period` (bản 0.2 đã thử khoá kỳ đồng thời nhưng chưa thử lại sau khi đổi sang hàm `SECURITY DEFINER`); `cash.guard_settlement` dưới tải song song; property test định giá đích danh (bảo toàn theo lô, `q = Q ⇒` lấy hết giá trị, chuyển kho K7, hàng trả lại không vượt dòng xuất gốc); golden test §4.1, §4.3, §5.3; chạy trên PG18 với `uuidv7()` thật; đo chi phí trigger audit trên `journal_lines` khi ghi hàng nghìn dòng.

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
| 9 | **Bồn trộn nhiều lô / châm thêm (A8, suy luận)** | Nếu có mà vẫn ghi "nhiều lô trong một bồn" thì đích danh theo lô sai bản chất (lô xuất ra thực chất là hỗn hợp) | Hỏi khách (B12); nếu có: thao tác trộn là lệnh SX sinh **lô gộp** (`lot_kind = 'MERGED'`), giá trị = tổng các lô vào; trong khi chờ: cảnh báo khi nhập/chuyển lô vào bồn đang có lô khác |
| 10 | Quyền theo cột (`GRANT UPDATE (cột)`) phải cập nhật khi thêm cột mới vào bảng được bảo vệ | Cột mới không sửa được bằng API cho tới khi khai | `sys.table_privileges` là nguồn duy nhất; test CI so cột của bảng với danh sách |
| 11 | Hàm `SECURITY DEFINER` là đường vòng qua quyền | Lỗi trong hàm = lỗ hổng | Mọi hàm `SECURITY DEFINER` đặt `search_path`, lấy tenant từ `app.current_tenant()` (không nhận tenant từ tham số), kiểm vai trò ở đầu hàm; danh sách hàm được review như mã bảo mật |
