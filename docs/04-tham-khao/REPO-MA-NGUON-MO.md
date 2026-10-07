# 02 — Repo mã nguồn mở tham khảo cho phần mềm kế toán / kho / giá thành (kiểu MISA SME)

> Ngày khảo sát: **2026-10-04**. Số sao, license, ngày push lấy từ GitHub REST API (gọi không xác thực) trong ngày này.
> Mã nguồn trích dẫn được tải trực tiếp từ `raw.githubusercontent.com` (nhánh `develop` của ERPNext; nhánh `master`, `18.0`, `17.0` của Odoo; `master` của iDempiere).
> Ký hiệu: ✅ = đã xác minh trực tiếp (API/đọc file); ⚠️ = chỉ biết qua web search/README, hoặc chưa xác minh.

---

## 0. Ghi chú pháp lý quan trọng (đọc trước)

- ✅ **Thông tư 99/2025/TT-BTC** (ban hành 27/10/2025) **thay thế Thông tư 200/2014/TT-BTC**, áp dụng cho năm tài chính bắt đầu từ **01/01/2026** (nguồn: [MISA AMIS](https://amis.misa.vn/251383/thong-tu-99-2025-tt-btc-thay-the-thong-tu-200-2014-tt-btc/), [meInvoice](https://www.meinvoice.vn/tin-tuc/39331/thong-tu-99-2025-tt-btc-thay-the-thong-tu-200/), [FAST](https://fast.com.vn/diem-moi-thong-tu-99-2025-tt-btc-chuan-bi-cho-che-do-ke-toan-doanh-nghiep-2026/)). Hệ thống tài khoản thay đổi đáng kể.
- ✅ Module `l10n_vn` của Odoo (cả `master` hiện tại) **vẫn mô tả là hệ thống tài khoản theo TT200** (`addons/l10n_vn/__manifest__.py`). Tức là gần như mọi bộ COA mã nguồn mở hiện có đều **đã lỗi thời** với TT99 → dự án phải tự xây bộ dữ liệu COA TT99 (và TT133 cho DN nhỏ & vừa nếu vẫn còn hiệu lực — ⚠️ cần kiểm tra lại văn bản thay thế TT133).
- ⚠️ Repo `n8n2erpnext/erpnext-vietnam` tuyên bố đã dùng COA TT99 (184 mã) và baseline hóa đơn điện tử "Nghị định 254/2026, Thông tư 91/2026" — **chưa xác minh** các văn bản này; cần đội nghiệp vụ kiểm tra.

---

## 1. ERP / phần mềm kế toán lớn

| Repo | Stack | License | ⭐ (2026-10-04) | Push gần nhất | Ghi chú license thương mại |
|---|---|---|---|---|---|
| [frappe/erpnext](https://github.com/frappe/erpnext) | Python, Frappe framework, MariaDB/Postgres | GPL-3.0 ✅ | 39 777 | 2026-10-04 | GPL: chỉ đọc học thiết kế, **không copy code** vào sản phẩm đóng |
| [frappe/frappe](https://github.com/frappe/frappe) | Python/JS | MIT ✅ | 10 877 | 2026-10-04 | Framework MIT — dùng được thương mại |
| [odoo/odoo](https://github.com/odoo/odoo) | Python, PostgreSQL, OWL | LGPL-3.0 ✅ (Community) | 54 822 | 2026-10-04 | LGPL: module riêng có thể đóng nếu chỉ "link"; Enterprise là độc quyền |
| [idempiere/idempiere](https://github.com/idempiere/idempiere) | Java, OSGi, PostgreSQL/Oracle | GPL-2.0 ✅ (badge README) | 665 | 2026-10-02 | GPL-2 |
| [apache/ofbiz-framework](https://github.com/apache/ofbiz-framework) | Java, Groovy | Apache-2.0 ✅ | 1 125 | 2026-10-04 | Thân thiện thương mại nhất trong nhóm ERP |
| [tryton/tryton](https://github.com/tryton/tryton) (mirror) | Python | GPL-3 ⚠️ (API không nhận diện; Tryton công bố GPL-3) | 226 | 2026-10-03 | GPL |
| [Dolibarr/dolibarr](https://github.com/Dolibarr/dolibarr) | PHP, MySQL | GPL-3.0 ✅ | 7 683 | 2026-10-04 | GPL |
| [akaunting/akaunting](https://github.com/akaunting/akaunting) | PHP Laravel, Vue | **BSL 1.1** ✅ (giới hạn: >2 user / >1 công ty / >1000 hóa đơn, cấm white-label, cấm làm "Accounting Service") | 10 161 | 2026-10-03 | **Không phải open-source thực sự** — tránh dùng code |
| [frappe/books](https://github.com/frappe/books) | TypeScript, Electron, Vue, SQLite | AGPL-3.0 ✅ | 4 997 | — | ✅ **Đã archive ngày 2026-10-02** (README ghi bản Electron/Vue đã end-of-life) |
| [bigcapitalhq/bigcapital](https://github.com/bigcapitalhq/bigcapital) | TypeScript, Node (NestJS ⚠️), React | AGPL-3.0 ✅ | 3 921 | 2026-09-28 | AGPL: nặng nhất với SaaS |
| [ledgersmb/LedgerSMB](https://github.com/ledgersmb/LedgerSMB) | Perl, PostgreSQL | GPL-2.0 ✅ | 570 | 2026-10-03 | GPL |
| [metasfresh/metasfresh](https://github.com/metasfresh/metasfresh) | Java (fork ADempiere) | GPL-2.0 ✅ | 2 441 | 2026-10-02 | GPL |

### Thư viện / engine sổ cái

| Repo | Stack | License | ⭐ | Push | Điểm học |
|---|---|---|---|---|---|
| [beancount/beancount](https://github.com/beancount/beancount) | Python (v3 có C++) | GPL-2.0 ✅ | 6 050 | 2026-08-23 | Mô hình "lot" có cost basis (`{}` booking: FIFO/LIFO/STRICT) — rất giống FIFO kho |
| [ledger/ledger](https://github.com/ledger/ledger) | C++ | BSD-3 ✅ (đọc LICENSE.md) | 6 049 | 2026-09-22 | Plain-text accounting, cú pháp giao dịch |
| [hledgerorg/hledger](https://github.com/hledgerorg/hledger) (đã đổi từ simonmichael/hledger) | Haskell | GPL-3.0 ✅ | 4 743 | 2026-10-02 | Báo cáo, kiểm tra cân đối |
| [tigerbeetle/tigerbeetle](https://github.com/tigerbeetle/tigerbeetle) | Zig | Apache-2.0 ✅ | 17 133 | 2026-10-02 | DB double-entry hiệu năng cao, `Account`/`Transfer` bất biến, số nguyên 128-bit (không float) |
| [formancehq/ledger](https://github.com/formancehq/ledger) | Go | MIT ✅ | 1 413 | 2026-10-02 | Ledger lập trình được (Numscript), append-only, posting nhiều chân |
| [flash-oss/medici](https://github.com/flash-oss/medici) | TypeScript, MongoDB | MIT ✅ | 360 | 2026-07-29 | Journal/Transaction đơn giản cho Node |

> Nhận xét chung về engine ledger: chúng giải quyết **sổ cái tiền tệ** (bất biến, cân đối Nợ=Có) nhưng **không** giải quyết bài toán giá vốn kho/giá thành — phần khó nhất của dự án. Học nguyên tắc (append-only, số nguyên/decimal, idempotency), không cần dùng trực tiếp.

---

## 2. Repo liên quan Việt Nam

| Repo | Nội dung | License | ⭐ / hoạt động | Đánh giá |
|---|---|---|---|---|
| [odoo/odoo – `addons/l10n_vn`](https://github.com/odoo/odoo/tree/master/addons/l10n_vn) | COA TT200 song ngữ (`data/template/account.account-vn.csv`, ~300 dòng, có `name@vi_VN`, tài khoản cha), báo cáo thuế, ngân hàng VN, VietQR | LGPL-3 ✅ | Lõi Odoo | **Nguồn dữ liệu COA TT200 dạng CSV tốt nhất** (song ngữ, có cây cha–con). Lỗi thời với TT99 |
| [odoo/odoo – `addons/l10n_vn_edi_viettel`](https://github.com/odoo/odoo/tree/master/addons/l10n_vn_edi_viettel) | Tích hợp **Viettel SInvoice** (JSON): `models/account_move.py` (`_l10n_vn_edi_generate_invoice_json`, `_send_invoice`, tải XML/PDF), `models/sinvoice_service.py` | LGPL-3 ✅ | Lõi Odoo, có từ 17.0 | **Mẫu tích hợp HĐĐT chất lượng nhất tìm được**: map `templateCode`, `invoiceSeries`, buyer/seller/item/taxBreakdowns |
| [OCA/l10n-vietnam](https://github.com/OCA/l10n-vietnam) | Khung localization OCA, nhánh mặc định 19.0 | AGPL-3 ✅ | 7⭐, ít nội dung | Gần như rỗng ở 19.0 |
| [trobz/l10n-vietnam](https://github.com/trobz/l10n-vietnam) | `l10n_vn_country_state` (Odoo 10) | AGPL-3 ✅ | 2⭐ | Cũ, chỉ dữ liệu tỉnh |
| [Viindoo/odoo](https://github.com/Viindoo/odoo) | Fork Odoo của Viindoo ("Mã nguồn Viindoo") | ⚠️ không hiển thị | 10⭐, cập nhật 2026-10-02 | Các module `to_l10n_vn_*` của Viindoo phân phối qua apps.odoo.com/viindoo.com, **không thấy repo công khai riêng** ⚠️ |
| [n8n2erpnext/erpnext-vietnam](https://github.com/n8n2erpnext/erpnext-vietnam) | App Frappe: COA **TT99** (184 mã), VAT 0/5/8/10%, PIT/BHXH, định hướng HĐĐT (chưa có adapter chứng nhận) | ⚠️ chưa rõ | 1⭐, 44 commit, v0.1.0-rc1 | Đáng đọc để lấy danh sách TT99 — **phải kiểm tra lại** độ chính xác |
| [nguyenhuuduong-lkf/erpnext-vietnam-localization](https://github.com/nguyenhuuduong-lkf/erpnext-vietnam-localization) | Bản dịch .po ~17.6k chuỗi, patch "đọc số tiền bằng chữ" kiểu VN, Docker | MIT (script) ✅ qua README | 2⭐ | Chỉ UI/i18n, không có COA |
| [Openroadvietnam/openaccounting](https://github.com/Openroadvietnam/openaccounting) | "Phần mềm kế toán nguồn mở Việt Nam" (JS) | AGPL-3 ✅ | 29⭐, push cuối **2015** | Chết; chỉ tham khảo lịch sử |
| [nguyentruongsonn/accounting-system](https://github.com/nguyentruongsonn/accounting-system) | Clone MISA AMIS (Laravel 12 + React 19), TT200 | ⚠️ không ghi | 0⭐, 21 commit | Dự án học tập; có thể xem UI flow, không tin cậy nghiệp vụ |
| [tonghoangvu/read-vietnamese-number-js](https://github.com/tonghoangvu/read-vietnamese-number-js) (npm `read-vietnamese-number`) | Đọc số thành chữ tiếng Việt (TS, số âm, thập phân, số lớn tùy ý) | MIT ⚠️ (theo snyk/npm) | v2.4.0 | **Khuyên dùng** nếu frontend/Node |
| [hckhanh/read-vn-number](https://github.com/hckhanh/read-vn-number) | Đọc số tiếng Việt (npm `read-vn-number`) | ⚠️ | ⚠️ | Phương án thay thế |
| [savoirfairelinux/num2words](https://github.com/savoirfairelinux/num2words) | Python, hỗ trợ `vi` ✅ (README) | LGPL-2.1 ⚠️ | — | Nếu backend Python; cần test quy tắc "lẻ/linh, mốt, lăm, tư" |
| [5canh-softtech/ehoadon-bkav](https://github.com/5canh-softtech/ehoadon-bkav) | SDK npm cho **BKAV eHoaDon** (SOAP + mã hóa, CmdType 100 tạo/sửa, 202 hủy, 800 tra cứu) | MIT ✅ | 2⭐, **archive 2025-09-21** | Tham khảo cách gọi BKAV |
| [XuHo-IT/SePay-Einvoice](https://github.com/XuHo-IT/SePay-Einvoice) | SDK TS không chính thức cho SePay eInvoice | MIT ✅ | 0⭐ | Tham khảo |
| [dieutx/meinvoice-inbot-api](https://github.com/dieutx/meinvoice-inbot-api) | Google Apps Script kéo dữ liệu MISA meInvoice | ⚠️ | 0⭐ | Mẫu gọi API meInvoice nhỏ |
| [dieutx/TaiHoaDonDienTu](https://github.com/dieutx/TaiHoaDonDienTu), [TranHoangAnhTuan/invoices-hoadondientu.gdt.gov.vn](https://github.com/TranHoangAnhTuan/invoices-hoadondientu.gdt.gov.vn) | Tải/tra cứu HĐĐT từ cổng hoadondientu.gdt.gov.vn | ⚠️ | 1–3⭐ | Ý tưởng cho tính năng "lấy hóa đơn đầu vào từ cổng thuế" |
| [tuyenlqvnp/vnpt-einvoice](https://github.com/tuyenlqvnp/vnpt-einvoice) | VNPT eInvoice (HTML, 2018) | ⚠️ | 0⭐ | Quá cũ |

**Không tìm thấy** (qua GitHub search): bộ COA TT200/TT99 dạng JSON chuẩn độc lập có uy tín; SDK chính thức của VNPT/Viettel/MISA/BKAV trên GitHub; repo kế toán VN lớn (>100⭐) đang hoạt động. ⚠️ GitHub search API bị giới hạn tốc độ khi không xác thực — một số truy vấn (`tt200`, `odoo vietnam localization`) chưa chạy được; nên chạy lại với `gh` đã đăng nhập.

---

## 3. Đọc mã nguồn chi tiết

### 3.1 ERPNext (nhánh `develop`) — tham chiếu thiết kế hàng đầu cho "sổ kho + repost backdated"

**Mô hình dữ liệu sổ kho** — `erpnext/stock/doctype/stock_ledger_entry/stock_ledger_entry.json` ✅
Mỗi dòng SLE = một biến động của (item, warehouse) do một dòng chứng từ sinh ra:
- Khóa nguồn: `voucher_type`, `voucher_no` (Dynamic Link), `voucher_detail_no`
- Thời điểm: `posting_date`, `posting_time`, `posting_datetime`
- Số lượng: `actual_qty` (±), `qty_after_transaction` (tồn lũy kế)
- Giá trị: `incoming_rate`, `outgoing_rate`, `valuation_rate` (đơn giá bình quân sau GD), `stock_value` (giá trị tồn lũy kế), `stock_value_difference` (Δ giá trị — **chính là số tiền hạch toán GL**), `stock_queue` (JSON các lô FIFO `[[qty, rate], ...]`)
- Trạng thái: `is_cancelled` (hủy chứng từ ⇒ đánh dấu + tạo dòng đảo, không xóa), `recalculate_rate`, `dependant_sle_voucher_detail_no`, `is_adjustment_entry`, `serial_and_batch_bundle`
- Bảng phụ `Bin` giữ tồn hiện thời (cache) cho (item, warehouse).

**Thuật toán giá vốn** — `erpnext/stock/stock_ledger.py` ✅
- `make_sl_entries()` (dòng ~147): khóa theo cặp (item, warehouse) đã sắp xếp (`sle_processing_gate`) để tránh deadlock; hủy ⇒ đảo dấu `actual_qty`, lấy lại rate cũ.
- Lớp `update_entries_after` → `process_sle()` (dòng ~1164): với mỗi SLE lấy trạng thái SLE trước đó của (item, wh), rồi:
  - **Moving Average**: `get_moving_average_values()` — nhập: `rate = (q·r + q_in·r_in)/(q+q_in)`; tồn ≤0 thì lấy rate nhập; xuất âm kho: dùng outgoing_rate/fallback.
  - **FIFO/LIFO**: `update_queue_values()` dùng `erpnext/stock/valuation.py` (`FIFOValuation`, `LIFOValuation` với `add_stock`/`remove_stock` trên danh sách bin `[qty, rate]`).
  - **Standard Cost** (mới ở develop): `process_standard_cost()`.
  - Lô/serial: `calculate_valuation_for_serial_batch_bundle()`, `update_batched_values()` (định giá theo lô).
  - Stock Reconciliation (kiểm kê) **đặt lại** qty/rate tuyệt đối tại thời điểm đó.
  - Sau cùng ghi `stock_value_difference = stock_value - prev_stock_value`; nếu khác giá trị cũ ⇒ thêm (voucher_type, voucher_no) vào `repost_affected_transaction` để **hạch toán lại GL**.
  - `update_outgoing_rate_on_transaction()` ghi ngược rate xuất về dòng chứng từ (Delivery Note, Stock Entry…), và tính lại thành phẩm.

**Chứng từ backdated / repost** — `erpnext/stock/doctype/repost_item_valuation/repost_item_valuation.py` ✅
- Khi ghi một chứng từ có SLE "tương lai" đã tồn tại (`future_sle_exists` trong `controllers/stock_controller.py`) ⇒ tạo doc **Repost Item Valuation** (based_on = Transaction hoặc Item and Warehouse) và xử lý **bất đồng bộ** bằng scheduler (`execute_repost_item_valuation`, `run_parallel_reposting`, có khung giờ chạy `in_configured_timeslot`).
- `repost()` → `repost_sl_entries()` (gọi `repost_future_sle`, tính lại mọi SLE sau thời điểm đó, kể cả **phụ thuộc chéo kho**: chuyển kho, sản xuất — `include_dependant_sle_in_reposting`) → `repost_gl_entries()` (gọi `repost_gle_for_stock_vouchers` cho các chứng từ bị ảnh hưởng).
- Có checkpoint/resume (lưu `reposting_data_file` JSON gzip, `current_index`), khử trùng lặp (`deduplicate_similar_repost`), xử lý lỗi recoverable (deadlock → re-queue), chặn sửa trước kỳ khóa sổ (`validate_period_closing_voucher`, `validate_stock_frozen_by_closing_entry`).

**Sinh bút toán GL từ chứng từ kho** — `erpnext/stock/services/base_stock_gl_composer.py` (`BaseStockGLComposer.compose`) ✅
- Với mỗi dòng chứng từ, đọc các SLE của dòng đó; hạch toán cặp: **Nợ TK kho (theo warehouse) / Có TK chi phí-đối ứng (`expense_account` của dòng)** bằng `stock_value_difference` (âm thì tự đảo chiều). Chuyển kho dùng TK kho của `target_warehouse`. Chênh lệch làm tròn ghi vào TK giá vốn mặc định.
- ⇒ **GL được suy ra từ sổ kho**, không tính độc lập ⇒ sổ kho và TK 15x luôn khớp. `StockController.make_gl_entries` trong `erpnext/controllers/stock_controller.py` gọi composer; hủy ⇒ `make_reverse_gl_entries`.

**BOM & giá thành**
- `erpnext/manufacturing/doctype/bom/bom.py` ✅: `rm_cost_as_per` ∈ {Valuation Rate, Last Purchase Rate, Price List}; operations (routing, hour_rate), **secondary items** (phế liệu/đồng sản phẩm với `cost_allocation_per`), `process_loss`, cây BOM đa cấp (`BOMTree`), BOM exploded. Tính giá đã tách sang `BOMCostingService` (`calculate_rm_cost`, `calculate_op_cost`, `update_cost`, `update_parent_cost`).
- Giá thành thực tế khi nhập kho thành phẩm — `erpnext/stock/doctype/stock_entry/stock_entry.py` ✅: `set_basic_rate()` → `get_basic_rate_for_manufactured_item()`:
  `đơn giá TP = (Σ giá trị NVL xuất thực tế − giá trị phế liệu/đồng SP được tách ra) / SL thành phẩm`, nhân `bom.cost_allocation_per`; chi phí bổ sung (nhân công, SXC) qua bảng `additional_costs` phân bổ bằng `distribute_additional_costs()`. Có chế độ lấy chi phí NVL từ các phiếu "Material Consumption for Manufacture" của Work Order.
- Hạn chế với VN: không có mô hình tập hợp chi phí 621/622/627 → 154 → 155 và phân bổ SXC cuối kỳ theo tiêu thức; giá thành tính **theo từng lệnh tại thời điểm nhập kho**, không phải "tính giá thành cuối kỳ" kiểu MISA.

### 3.2 Odoo — đã **thay đổi kiến trúc ở 19.0**

✅ Đã kiểm tra: `addons/stock_account/models/stock_valuation_layer.py` **có ở 17.0/18.0, không còn ở `19.0`/`master`**. Odoo 19 bỏ `stock.valuation.layer`, chuyển giá trị lên `stock.move` + model mới `product.value`.

**Odoo 17/18 — Stock Valuation Layer (SVL)** (`addons/stock_account/models/stock_valuation_layer.py`, `product.py`, `stock_move.py` nhánh 18.0) ✅
- SVL: `product_id, quantity, unit_cost, value, remaining_qty, remaining_value, stock_move_id, account_move_id, stock_valuation_layer_id` (layer điều chỉnh trỏ về layer gốc), `lot_id`.
- FIFO = các SVL nhập còn `remaining_qty > 0` là "candidates"; `_run_fifo()` (product.py) tiêu thụ dần, cập nhật `remaining_*`. AVCO = `standard_price` cập nhật khi nhập; xuất theo `standard_price` + điều chỉnh làm tròn.
- **Âm kho**: xuất vượt tồn được định giá tạm theo giá FIFO cuối; `_run_fifo_vacuum()` tạo layer bù khi có hàng nhập sau. **Không có repost backdated** — định giá theo thứ tự thời gian xác nhận (create_date), không theo ngày chứng từ.
- GL: `stock_move._account_entry_move()` → `_prepare_account_move_vals()`: nhập: Nợ `stock_valuation` / Có `stock_input`; xuất: Nợ `stock_output` / Có `stock_valuation` (Anglo-Saxon: giá vốn ghi khi xuất hóa đơn).

**Odoo 19/master — valuation trên stock.move** ✅
- `stock.move` có `value`, `remaining_qty`, `remaining_value`, `is_in`, `is_out`, `value_manual`, `value_justification`; `product.value` (`addons/stock_account/models/product_value.py`) lưu **lịch sử điều chỉnh thủ công** (đổi giá chuẩn, sửa giá trị move) với `old/new_cost`, `old/new_value`, `user_id`, `date`.
- `stock_move._set_value(recompute_date=...)`: FIFO dùng `product._get_fifo_stack()`/`_get_fifo_value()` (xếp chồng các move nhập tính lại từ tồn thời điểm); **có cơ chế replay**: `stock_move.write()` khi đổi `date` của move đã done ⇒ `product._correct_inventory_valuation(from_date)` chạy lại `_run_fifo/_run_avco/_run_standard(correction=True)` từ ngày sớm nhất bị ảnh hưởng. Đây là bước tiến về hướng giống ERPNext (backdate).
- **Periodic vs real-time**: `product.valuation` ∈ {`periodic`, `real_time`}; `_should_create_account_move()` chỉ tạo bút toán từng move khi `real_time` và location có `valuation_account_id`; còn lại dùng **bút toán khóa sổ định kỳ** (`res_company._get_closing_move...`, `closing_datetime`). Mô hình "định kỳ" này gần với cách kế toán VN tính giá xuất kho bình quân cuối kỳ.
- MRP: `addons/mrp_account/models/mrp_production.py` `_cal_price()`: `total_cost = |Σ value NVL tiêu hao| + Σ chi phí work center (_cal_cost) + extra_cost × SL`; phân bổ cho **byproduct** theo `cost_share %`, phần còn lại cho thành phẩm; `_post_labour()` hạch toán chi phí nhân công work center vào TK WIP/production location. `res.company` có `account_production_wip_account_id`, `account_production_wip_overhead_account_id`.

### 3.3 iDempiere — costing engine tổng quát nhất (đọc để hiểu, không copy: GPL-2)
- `org.adempiere.base/src/org/compiere/model/MCost.java` ✅: `calculateAverageInv`, `calculateAveragePO`, `calculateFiFo`, `calculateLiFo`, `getCurrentCost`, `getSeedCosts`. Phương pháp (`X_M_CostElement`): AveragePO `A`, Fifo `F`, AverageInvoice `I`, Lifo `L`, Standard `S`, UserDefined `U`, LastInvoice `i`, LastPOPrice `p`.
- `MCostDetail.java` ✅: một bản ghi chi tiết cho mỗi loại chứng từ (`createOrder/Invoice/Shipment/Inventory/Movement/Production/MatchInvoice/ProjectIssue`); `M_Cost` = trạng thái hiện thời theo (acct schema, org, product, ASI, cost element). Có **cost element** (Material, Labor, Overhead, Burden…) — mô hình tách yếu tố chi phí rất hợp với 621/622/627.
- Backdate: `periodClosedCheckForDocsAfterBackDateTrx()` tìm các chứng từ sau ngày backdate (theo `DateAcct`, `Ref_CostDetail_ID`) để kiểm tra kỳ đã đóng và repost.

### 3.4 Các ERP khác (chưa đọc mã chi tiết ⚠️)
- **Dolibarr**: dùng PMP (giá bình quân gia quyền) cho kho — đơn giản, không FIFO ⚠️.
- **Bigcapital**: có tính giá vốn kho (FIFO/bình quân) và bút toán tự động trong Node/TS ⚠️ — đáng xem nếu chọn stack TypeScript, nhưng AGPL.
- **Tryton** (`stock`, `product_cost_fifo`, `production`) ⚠️: thiết kế module sạch, cost price theo move.
- **OFBiz**: Apache-2, mô hình dữ liệu (Universal Data Model) rộng nhưng UI/kỹ thuật cũ ⚠️.
- **Metasfresh**: fork ADempiere, có costing engine tách riêng (`de.metas.costing`) ⚠️.

---

## 4. Đánh giá từng repo chính: học gì / tránh gì

| Repo | Đáng học | Nên tránh |
|---|---|---|
| ERPNext | SLE append-only + `stock_value_difference` là nguồn của GL; repost bất đồng bộ có checkpoint; khóa theo (item, wh); hủy chứng từ = đảo, không xóa; FIFO queue lưu trong từng SLE (snapshot) giúp tính lại từ giữa | Lưu `stock_queue` dạng JSON text trong mỗi dòng (phình dữ liệu); độ phức tạp tích tụ (serial/batch bundle, nhiều cờ); repost toàn bộ tương lai rất nặng với DN nhiều giao dịch; GPL-3 |
| Odoo 19 | Tách "giá trị move" và "lịch sử điều chỉnh" (`product.value` có audit user/old/new); hỗ trợ cả periodic và real-time; replay khi đổi ngày | Kiến trúc thay đổi lớn giữa các phiên bản (SVL → move) — đừng bám API; Anglo-Saxon không khớp thông lệ VN; không có giá thành cuối kỳ theo khoản mục |
| Odoo 17/18 SVL | Mô hình layer + remaining_qty dễ hiểu cho FIFO thực tế | Không hỗ trợ backdate; fifo_vacuum phức tạp |
| iDempiere | Cost element (NVL/NC/SXC), nhiều phương pháp, đa sổ (acct schema) | Java/OSGi nặng, code cũ, GPL-2 |
| TigerBeetle / Formance | Bất biến, số nguyên, idempotency key, posting nhiều chân | Không có khái niệm kho/giá vốn |
| Beancount | Lot booking theo cost basis | Plain-text, không phải ứng dụng nghiệp vụ |
| Odoo `l10n_vn` / `l10n_vn_edi_viettel` | Dữ liệu COA song ngữ; cấu trúc JSON gửi SInvoice | COA là TT200 (lỗi thời từ 2026) |
| Akaunting | UI/UX SME | BSL — không dùng code |

---

## 5. Bảng xếp hạng "nên đọc kỹ"

| Hạng | Repo / file | Lý do |
|---|---|---|
| 1 | ERPNext: `stock/stock_ledger.py`, `stock/valuation.py`, `stock/doctype/stock_ledger_entry/*.json`, `stock/doctype/repost_item_valuation/repost_item_valuation.py`, `stock/services/base_stock_gl_composer.py` | Lời giải hoàn chỉnh, đang chạy thực tế cho **backdate + repost + GL từ sổ kho** — đúng bài toán MISA (MISA cho nhập lùi ngày và "tính giá xuất kho" lại) |
| 2 | Odoo 19/master: `stock_account/models/stock_move.py` (`_set_value`, `write`), `product.py` (`_get_fifo_stack`, `_correct_inventory_valuation`, `_run_avco`), `product_value.py`, `res_company.py` (periodic closing) | Thiết kế mới nhất, có periodic valuation + audit điều chỉnh |
| 3 | ERPNext: `stock_entry.py` (`set_basic_rate`, `distribute_additional_costs`), `bom.py` + `BOMCostingService`; Odoo `mrp_account/models/mrp_production.py` (`_cal_price`, `_post_labour`) | Hai cách tính giá thành theo lệnh SX, phân bổ đồng sản phẩm |
| 4 | iDempiere `MCost.java`, `MCostDetail.java`, `X_M_CostElement.java` | Mô hình yếu tố chi phí & nhiều phương pháp giá |
| 5 | Odoo `l10n_vn` (`data/template/account.account-vn.csv`) và `l10n_vn_edi_viettel` (`models/account_move.py`, `models/sinvoice_service.py`) | Dữ liệu COA mẫu + mẫu tích hợp Viettel SInvoice |
| 6 | Odoo 18 `stock_valuation_layer.py` + `_run_fifo/_run_fifo_vacuum` | Hiểu FIFO dạng layer & xử lý âm kho |
| 7 | `n8n2erpnext/erpnext-vietnam` | Danh mục TT99 & thuế VN 2026 (phải đối chiếu văn bản gốc) |
| 8 | TigerBeetle / Formance docs | Nguyên tắc sổ cái bất biến |

---

## 6. Khuyến nghị thiết kế

1. **Sổ kho là nguồn sự thật, GL suy ra từ sổ kho** (theo ERPNext): bảng `stock_ledger` append-only với `qty_after`, `value_after`, `value_delta`; bút toán 15x/632/154 sinh từ `value_delta`. Hủy chứng từ = dòng đảo.
2. **Hỗ trợ cả hai chế độ tính giá** như MISA: (a) *tức thời* (bình quân di động, FIFO, đích danh) và (b) *bình quân cuối kỳ* (periodic — giống `valuation='periodic'` của Odoo 19): chứng từ xuất trong kỳ chưa có giá, chạy "Tính giá xuất kho" cuối kỳ rồi cập nhật đơn giá + bút toán.
3. **Backdate**: mô hình "repost job" bất đồng bộ của ERPNext (theo item×kho, có checkpoint, có khóa kỳ), nhưng **tránh lưu FIFO queue JSON ở mọi dòng** — thay bằng bảng lớp FIFO (layer, kiểu Odoo 18 SVL với `remaining_qty`) + snapshot định kỳ để replay nhanh.
4. **Giá thành**: kết hợp ERPNext/Odoo (giá theo lệnh sản xuất, phân bổ đồng sản phẩm theo %) với mô hình **yếu tố chi phí** của iDempiere để tập hợp 621/622/627 → 154 → 155 và phân bổ SXC cuối kỳ theo tiêu thức (NVL, giờ công, định mức) — phần này các repo nước ngoài **không có**, phải tự thiết kế theo MISA.
5. **Ledger**: số tiền dùng `NUMERIC`/decimal (VND không lẻ nhưng đơn giá có lẻ), idempotency key cho chứng từ, khóa sổ theo kỳ.
6. **Dữ liệu VN**: tự xây COA **TT99** (đối chiếu văn bản gốc; tham khảo cấu trúc CSV của Odoo `l10n_vn` và danh mục trong `n8n2erpnext/erpnext-vietnam`); đọc số bằng chữ dùng `read-vietnamese-number` (MIT) hoặc tự viết; HĐĐT thiết kế lớp adapter theo mẫu `l10n_vn_edi_viettel` (Viettel), `ehoadon-bkav` (BKAV); API VNPT/MISA meInvoice cần lấy tài liệu chính thức từ nhà cung cấp (không có SDK nguồn mở tin cậy).
7. **License**: chỉ đọc học thiết kế từ ERPNext/iDempiere/Bigcapital (GPL/AGPL); code có thể tái sử dụng: Frappe framework (MIT), OFBiz/TigerBeetle (Apache-2), Formance/Medici (MIT), Odoo LGPL (cẩn trọng). Tránh Akaunting (BSL).

---

## 7. Những điểm chưa xác minh / việc tiếp theo
- Chạy lại GitHub search có xác thực (`gh auth login`) cho: `tt200`, `tt99`, `thong tu 133`, `odoo vietnam`, `viettel sinvoice api`, `vnpt invoice api`, `misa meinvoice api`.
- Xác minh license `num2words` (dự đoán LGPL-2.1), `read-vn-number`, `Viindoo/odoo`, `n8n2erpnext/erpnext-vietnam`.
- Đọc sâu Bigcapital (inventory cost lots) và Tryton `product_cost_fifo` nếu chọn stack TypeScript/Python thuần.
- Kiểm tra văn bản pháp lý: TT99/2025 (đã xác minh qua nhiều nguồn), văn bản thay thế TT133 cho DN nhỏ & vừa, và các văn bản HĐĐT mà repo `n8n2erpnext` nêu (chưa xác minh).
