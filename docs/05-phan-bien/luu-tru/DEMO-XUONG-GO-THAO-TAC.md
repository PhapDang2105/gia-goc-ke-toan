# Giá Gốc – Bộ thao tác khách tự làm trong demo

> Phạm vi: `gia-goc-demo.html` (vanilla JS, kỳ 01/2026, xưởng nội thất mẫu). Mọi dữ liệu chỉ nằm trong trình duyệt. Tài liệu này chỉ là đề xuất, chưa sửa file HTML.
> Nguyên tắc chung: **mọi thao tác đều tạo hoặc hủy một chứng từ trong `state`**, rồi gọi lại `renderAll()` → `compute()` → `valuate()` → `buildDocs()`. Không có số nào "vẽ cho đẹp": cái khách thấy là kết quả thật của engine.

---

## 0. Hiện trạng engine và những điểm phải sửa trước khi cho khách nhập liệu

| # | Vấn đề trong code hiện tại | Hậu quả khi khách tự nhập | Cách xử lý |
|---|---|---|---|
| 1 | `BASE_MOVES`, `TPM`, `POOL`, `NC`, `DONE` là hằng số; `TPM` dựng lại trong `compute()` | Không có chỗ để thêm chứng từ | Chuyển thành mảng `docs` trong state (mục 2) |
| 2 | `revenue = 180*PRICE.BG + 380*PRICE.GG`; KPI ghi cứng "180 bàn, 380 ghế" | Thêm hóa đơn mà doanh thu không đổi | Tính từ hóa đơn bán và hàng trả lại |
| 3 | `SUP`/`CUST` tra theo **số chứng từ** (`SUP['PN0003']`) | Phiếu mới không có NCC/KH | Danh mục đối tượng riêng, chứng từ giữ `partyId` |
| 4 | `valuate()` kiểu `moving`: nếu tồn bằng 0 mà vẫn xuất thì `v/q` chia cho 0 → **NaN** (vd. xuất sơn trước 08/01, tồn đầu SON = 0) | Màn hình hiện NaN, mất uy tín | Chặn chia cho 0: khi `q<=0` thì lấy đơn giá nhập gần nhất (hoặc 0) và báo tồn âm |
| 5 | `periodic` không cảnh báo tồn âm; `closeQ<0` làm `closeV=0`, phiếu xuất cuối gánh hết giá trị | Số sai mà không có cảnh báo | Thêm `warn` khi số lượng tồn chạy âm theo ngày (kể cả với phương pháp periodic) |
| 6 | FIFO: phần thiếu khi hết lô có giá trị 0 | Giá vốn thấp giả | Gắn cờ tồn âm, định giá phần thiếu theo lô cuối |
| 7 | `glBalances()` ghi cứng số dư đầu (`152: 21.000.000`, `155: 19.200.000`) | Lệch đối chiếu khi thêm vật tư mới hoặc sửa tồn đầu | Tính từ `OPEN` |
| 8 | Nhập kho thành phẩm: `qty = DONE[o]`, cả `Z` gán cho một phiếu NK | Không có báo cáo hoàn thành động | NK là chứng từ; `DONE` = tổng SL các NK; Z chia theo SL |
| 9 | Truy xuất: mã lô `NK0001/NK0002` ghi cứng | Sai nếu có thêm NK | Lấy từ chứng từ NK |
| 10 | `STEPS[0].r` có chữ "21 chứng từ"; biểu đồ `max=250` cố định | Lệch khi khách thêm chứng từ hoặc bán nhiều | Tính động |
| 11 | Nút `btnReset` "Làm lại từ đầu" chỉ đặt lại khóa sổ và bỏ PN0015 | Dễ nhầm với "Đặt lại dữ liệu mẫu" | Đổi nhãn thành "Mở lại quy trình (bỏ kết quả các bước)"; thêm nút đặt lại dữ liệu riêng |
| 12 | `S.dirty` chỉ được bật ở `btnBack` (đánh dấu từ bước 5) | Phải xác định lại phạm vi tính lại theo từng loại chứng từ | Dùng hàm `invalidate(fromStep)` theo loại chứng từ (mục 2.5) |

---

## 1. Danh sách thao tác theo ưu tiên

Quy ước:
- **P0**: bắt buộc có để khách "tự tay thấy được" khác biệt. Thiếu nhóm này thì việc mở nhập liệu không có ý nghĩa.
- **P1**: làm demo có chiều sâu, nên có trong bản gửi khách.
- **P2**: làm sau, hoặc chỉ dành cho khách kỹ tính.

Một số thứ dùng chung cho mọi form (P0):
- **Xem trước bút toán ngay trong form.** Khi khách gõ, bảng Nợ/Có cập nhật theo chế độ đang chọn (TT 99 ra 621/622/627, TT 133 ra 154). Khách không bao giờ phải gõ số hiệu tài khoản.
- **Ô "Ảnh hưởng" sau khi lưu.** Chụp các chỉ số trước và sau khi lưu (đơn giá xuất từng phiếu bị ảnh hưởng, z BG/GG, giá vốn, lãi gộp, tồn kho) rồi hiện dạng "trước → sau" kèm thời gian tính, ví dụ "tính lại trong 3 ms". Bấm vào một dòng sẽ nhảy tới đúng phiếu ở trang Giá xuất kho, mở sẵn phần giải thích đơn giá.
- **Huy hiệu "Do bạn tạo"** trên chứng từ khách lập, cùng bộ lọc "Chỉ chứng từ của tôi" ở trang Chứng từ.
- **Chặn khi đã khóa sổ.** Nút lưu bị vô hiệu và hiện lý do; mọi lối vào form đều đi qua `guardPeriod(date)`.
- **Số chứng từ tự sinh** theo `nextNo(type)`, ví dụ PN0016. Khách không sửa được số.
- **Kỳ kế toán:** ngày chứng từ chỉ được nằm trong khoảng 01/01–31/01/2026. Ngày ngoài kỳ báo lỗi "Ngoài kỳ 01/2026 đang mở".
- **Định dạng số kiểu Việt Nam** (1.234.567,5). Ô nhập nhận được cả "1.200.000" lẫn "1200000".

### P0-1. Lập phiếu nhập mua NVL (cho phép lùi ngày)
- **Mục tiêu với khách:** tự kiểm chứng câu "nhập lùi ngày thì giá xuất, giá thành và giá vốn tự tính lại". Hiện demo chỉ có một phiếu PN0015 cố định.
- **Form:**
  - Ngày chứng từ (mặc định 31/01).
  - NCC: chọn trong danh sách, có mục "+ Thêm NCC mới" ngay trong ô chọn (P1).
  - Một hoặc nhiều dòng, mỗi dòng gồm vật tư (chỉ NVL), SL, đơn giá và thành tiền (tự tính, cho sửa để chênh tối đa ±1 đ do làm tròn).
  - Thuế suất GTGT: 0/5/8/10%, mặc định 10%.
  - Thanh toán: 331 (chưa trả) hoặc 111 (tiền mặt).
  - Diễn giải (tự gợi ý).
- **Validate:**
  - SL > 0. Số thập phân tối đa 3 chữ số với đơn vị kg/m³; số nguyên với chiếc/thùng.
  - Đơn giá > 0 và < 10 tỷ.
  - Ngày nằm trong kỳ và kỳ đang mở.
  - Có ít nhất 1 dòng; NCC bắt buộc.
  - Cảnh báo mềm khi đơn giá lệch quá ±50% so với đơn giá nhập gần nhất ("Có gõ nhầm số 0?"). Đây là một điểm wow nhỏ về kiểm soát.
- **Engine:** đẩy một doc `{type:'PN', lines:[{item, qty, value}]}` vào `S.data.docs`. Hàm `deriveMoves()` sinh move `kind:'in'` cho từng dòng, sau đó `valuate()` chạy lại cho vật tư đó. Gọi `invalidate(3)`.
- **Bút toán:** Nợ 152 (chi tiết theo mã vật tư) / Nợ 1331 / Có 331 hoặc 111.
- **Trạng thái:**
  - Có phiếu xuất cùng vật tư mang ngày sau ngày phiếu → huy hiệu "Lùi ngày", kèm danh sách phiếu xuất sẽ tính lại (vd. "PX0004, PX0011").
  - Kỳ đã khóa → từ chối lưu.
- **Wow:**
  - Ngay trong form hiện dòng "Phiếu này lùi ngày so với 2 phiếu xuất → sẽ tính lại giá của chúng".
  - Sau khi lưu, ô Ảnh hưởng hiện "Đơn giá xuất keo 10.476 → 10.612; z bàn BG-01 … → …".
  - Ở trang Giá xuất kho, ba cột so sánh phương pháp (`#cmp`) đổi số ngay.
  - Gợi ý đổi sang FIFO để xem lô mới chen vào đâu.

### P0-2. Phiếu xuất kho NVL cho sản xuất (kèm cảnh báo tồn âm)
- **Mục tiêu:** cho thấy chi phí NVL đi thẳng vào thẻ giá thành của đúng sản phẩm, và hệ thống không để xuất quá tồn trong im lặng.
- **Form:**
  - Ngày.
  - Đối tượng tập hợp chi phí: BG-01 hoặc GG-02.
  - Các dòng gồm vật tư và SL. Bên cạnh mỗi dòng hiện **"Tồn tại ngày dd/mm: x kg"**, tính bằng cách chạy `valuate` đến ngày đó.
  - Không có ô đơn giá. Đơn giá do engine tính và hiện "giá tạm" nếu đang dùng bình quân cuối kỳ.
- **Validate:**
  - SL > 0.
  - SL > tồn tại ngày đó → khung đỏ "Xuất quá tồn 50 kg. Tồn âm sẽ chặn bước 4 khi khóa sổ." Mặc định chặn lưu; có ô tích "Vẫn lưu (ghi nhận tồn âm tạm thời)" để demo cơ chế kiểm soát lúc khóa sổ.
  - Cần kiểm tra **cả các ngày sau**: phiếu xuất lùi ngày có thể làm một phiếu xuất muộn hơn bị âm. Phải hiện tên phiếu đó.
- **Engine:** doc `{type:'PX', to:'BG', lines:[{item, qty}]}` sinh move `kind:'out', to`, rồi đi theo luồng hiện có: `nvl[to][item]` → `card[o]` → NK → giá vốn. Gọi `invalidate(3)`.
- **Bút toán:**
  - TT 99: Nợ 621 (đối tượng BG/GG) / Có 152.
  - TT 133: Nợ 154 (khoản mục NVL) / Có 152.
- **Trạng thái:** bình quân cuối kỳ thì "Giá tạm"; khi bước 5 đã chạy thì "Giá đã chốt". Bước 4 "Kiểm tra tồn âm" **chạy thật**: `runStep()` gặp `warn` thì dừng và báo "Tồn âm KEO tại PX0017 ngày 12/01: -50 kg".
- **Wow:**
  - Thẻ giá thành và cây truy xuất có thêm một lá "PX0017 ← PN0003 (Hóa chất Phương Nam)".
  - Khóa sổ dừng đúng ở bước kiểm tra tồn âm, kèm link tới phiếu gây lỗi.

### P0-3. Hóa đơn bán hàng (thành phẩm)
- **Mục tiêu:** doanh thu, giá vốn và lãi gộp động theo chứng từ khách tạo.
- **Form:**
  - Ngày; khách hàng (chọn hoặc "+ Thêm mới").
  - Các dòng gồm thành phẩm (BG/GG), SL và giá bán chưa thuế (mặc định lấy `PRICE`).
  - Thuế GTGT (mặc định 10%); hình thức thanh toán 131 hoặc 111.
- **Validate:** SL là số nguyên > 0; giá bán > 0; kiểm tra tồn thành phẩm tại ngày giống P0-2. Cảnh báo khi giá bán thấp hơn giá thành tạm tính ("bán dưới giá vốn").
- **Live trong form:** "Giá vốn dự kiến ≈ x đ (giá tạm), lãi gộp dòng ≈ y đ (z%)". Đây là chỗ khách thấy giá trị của việc có giá thành ngay trong kỳ.
- **Engine:**
  - Doc `{type:'HD', partyId, lines:[{item, qty, price}]}` sinh move TP `kind:'out', to:'sale'`.
  - `revenue = Σ qty×price` trên mọi HD, trừ đi TL.
  - KPI "x bàn, y ghế" tính động. Gọi `invalidate(7)` (bước 8 – giá vốn TP).
- **Bút toán:** Nợ 131 / Có 5112 / Có 33311; đồng thời Nợ 632 / Có 155 theo giá engine tính.
- **Wow:** hóa đơn **không làm đổi giá thành**, chỉ đổi giá vốn và tồn cuối. Ô Ảnh hưởng chứng minh bằng dòng "z BG-01: không đổi". Khóa sổ chỉ đánh dấu chạy lại từ bước 8, không phải từ bước 5, cho thấy hệ thống biết chính xác phần nào cần tính lại.

### P0-4. Hủy chứng từ, và sửa chứng từ theo kiểu "hủy + lập lại" (có nhật ký)
- **Mục tiêu:** khách được sửa sai thoải mái mà vẫn thấy dấu vết kiểm toán. Đây là điểm khác MISA khi demo kiểm soát nội bộ.
- **Form hủy:** lý do (bắt buộc, ≥ 10 ký tự, có gợi ý sẵn: "Nhập sai SL", "Trùng chứng từ"…).
- **Form sửa:** mở form của loại chứng từ đó với dữ liệu đã điền sẵn. Khi lưu:
  1. Chứng từ cũ chuyển `status:'void'`, `voidedBy: <số mới>`.
  2. Lập chứng từ mới có `replaces: <số cũ>`, số mới (PN0016 thay PN0003). *Phương án khác:* giữ số cũ kèm hậu tố phiên bản PN0003-R1. Khuyên dùng số mới cho đúng nguyên tắc không sửa đè.
  3. Ghi vào `S.data.audit` một dòng `{at, actor:'Khách demo', action:'edit', no, newNo, reason, diff}`.
- **Validate:**
  - Không hủy được chứng từ khi kỳ đã khóa.
  - Không hủy được HD đã có hàng trả lại tham chiếu (phải hủy phiếu trả trước).
  - Không hủy được PN nếu việc hủy làm tồn âm. Khi đó hiện tên phiếu xuất bị ảnh hưởng và cho chọn "Vẫn hủy".
  - Chứng từ mẫu (`origin:'seed'`) vẫn hủy hoặc sửa được, để khách thử trên số liệu thật.
- **Engine:** `deriveMoves()` bỏ qua `status==='void'`. Gọi `invalidate(AFFECT[type])`.
- **Bút toán:** chứng từ hủy vẫn hiện trong danh sách, gạch ngang, huy hiệu "Đã hủy", không sinh dòng sổ cái. Trong cùng kỳ đang mở thì không cần bút toán đảo.
- **Wow:** tab "Nhật ký sửa đổi" có bảng thời gian · người · hành động · lý do · trước → sau. Câu nói khi demo: "Sửa là hủy rồi lập lại, nên mọi lần sửa đều có dấu vết theo TT 99/2025."

### P0-5. Khóa sổ chặn sửa, và mở khóa có lý do
- **Mục tiêu:** chứng minh kỳ đã khóa là khóa thật, còn mở lại thì phải có kiểm soát.
- **Chặn khi khóa:** mọi nút "Lập phiếu", "Sửa", "Hủy", "Nhập Excel" và các ô `hours/wip/method/regime` đều bị vô hiệu, kèm tooltip "Kỳ 01/2026 đã khóa". Nếu khách vẫn gọi được (vd. bằng phím tắt) thì hiện toast từ chối, giống `btnBack` hiện nay.
- **Form mở khóa:**
  - Vai trò: "Kế toán trưởng (giả lập)" kèm ô tích xác nhận.
  - Lý do: bắt buộc, ≥ 15 ký tự.
  - Phạm vi: chỉ hiện "Mở lại toàn kỳ" (một lựa chọn duy nhất, tránh phức tạp).
- **Engine:** `S.done[11]=false`, ghi audit `{action:'unlock', reason}`. Các bước 1–11 giữ kết quả. Khi có chứng từ mới thì `invalidate()` lo phần còn lại. Khóa lại thì ghi audit `{action:'lock'}`.
- **Wow:** con dấu "Đã khóa sổ" biến mất, nhật ký có thêm dòng mở khóa. Lập một phiếu lùi ngày thì các bước liên quan chuyển "Cần chạy lại". Chạy tất cả thì khóa lại với số mới, và dòng "Kiểm tra bất biến Nợ = Có, kho = sổ cái" vẫn xanh.

### P0-6. Nút "Đặt lại dữ liệu mẫu" và lưu trạng thái
- **Mục tiêu:** khách nghịch thoải mái, sales đặt lại được trong 1 giây trước buổi demo sau.
- **Hành vi:**
  - Mọi thay đổi gọi `save()` vào `localStorage['giagoc-demo-v2']`, có bọc `try/catch`. Ở chế độ ẩn danh hoặc khi bị chặn storage, demo vẫn chạy, chỉ là không nhớ được.
  - Nút đặt lại nằm ở thanh trên, có hộp xác nhận: "Xóa N chứng từ bạn đã tạo và đưa kỳ 01/2026 về dữ liệu mẫu?".
  - Đặt lại bằng cách `S.data = clone(SEED)` và xóa key.
- **Wow:** gián tiếp. Khách dám thử vì biết lúc nào cũng quay lại được.

### P1-1. Hàng bán bị trả lại
- **Form:**
  - Chọn hóa đơn gốc (chỉ HD chưa hủy). Mặt hàng và giá bán tự điền theo hóa đơn.
  - SL trả ≤ SL bán − SL đã trả trước đó.
  - Ngày phải ≥ ngày hóa đơn.
  - Lý do; ô tích "Nhập lại kho" (mặc định có).
- **Engine:** move TP `kind:'ret', ref:'HD0012'`. Mở rộng `valuate()`:
  - moving/FIFO: giá trị nhập lại = SL × đơn giá xuất của dòng HD gốc. Hóa đơn có ngày sớm hơn nên đã được định giá trước trong cùng vòng lặp. Với FIFO, đưa lại thành một lớp mới có ngày bằng ngày trả.
  - periodic: coi như xuất âm (`outQ -= qty`, giá trị = SL × đơn giá bình quân kỳ). Cách này đơn giản và đúng tinh thần bình quân cuối kỳ.
  - Doanh thu = Σ HD − Σ TL. Gọi `invalidate(7)`.
- **Bút toán:**
  - Nợ 5112 (giảm doanh thu) / Nợ 33311 / Có 131.
  - Nợ 155 / Có 632 theo giá vốn lúc xuất.
  - *Cần kế toán trưởng chốt:* TT 133 không dùng TK 521 nên ghi giảm thẳng 511. Với TT 99/2025, cần xác nhận lại tài khoản giảm trừ doanh thu trước khi đưa vào demo.
- **Wow:** phần giải thích đơn giá của dòng trả lại ghi "Nhập lại theo giá vốn của HD0012: 100 × 66.120 đ". Khách thấy giá vốn được truy ngược đúng tới hóa đơn gốc.

### P1-2. Phiếu kiểm kê kho
- **Form:**
  - Ngày kiểm kê; kho K1 hoặc K2.
  - Bảng các mặt hàng thuộc kho, gồm cột SL sổ sách (engine tính tại ngày đó, chỉ đọc), cột SL thực tế (khách nhập) và cột chênh lệch tự tính.
  - Xử lý: thiếu thì ghi 1381 (chờ xử lý) hoặc 632 (hao hụt trong định mức); thừa thì ghi 3381.
- **Validate:** SL thực tế ≥ 0; nếu không có chênh lệch thì báo "Không phát sinh bút toán".
- **Engine:**
  - Thiếu sinh move `kind:'out', to:'loss'`, giá do engine tính.
  - Thừa sinh move `kind:'in'`, giá trị = SL × đơn giá tức thời tại ngày, gợi ý sẵn và cho sửa.
  - Gọi `invalidate(1)`. Bước 2 "Kiểm kê kho" lúc chạy hiện kết quả thật: "Thiếu 2 kg keo, 21.000 đ".
- **Bút toán:** Nợ 1381 hoặc 632 / Có 152 hoặc 155; Nợ 152 hoặc 155 / Có 3381.
- **Wow:** đối chiếu "kho = sổ cái" vẫn khớp ngay sau khi điều chỉnh.

### P1-3. Chứng từ chi phí: lương, khấu hao, chi phí sản xuất chung
Làm một form có 3 tab, thay cho các chứng từ cứng BL0001, KH0001, HD-DIEN01, PC0007.
- **Lương:**
  - Các trường: lương CN trực tiếp BG-01, lương CN trực tiếp GG-02, lương quản đốc.
  - Hiện tại `NC` lấy từ tổng các chứng từ BL theo đối tượng. **Điểm wow:** tăng lương CN BG thì tiêu thức phân bổ SXC (60/40) cũng đổi, nên SXC phân bổ cho GG giảm theo.
  - Bút toán: Nợ 622 (từng đối tượng) / Nợ 627 / Có 334. TT 133 ghi Nợ 154 với khoản mục tương ứng.
- **Khấu hao:**
  - Các trường: số tiền và tên tài sản; cố định = có.
  - Engine thêm một phần tử vào `POOL`, nên phần chi phí dưới công suất (VAS 02) tính lại theo `S.hours`.
  - Bút toán: Nợ 627 / Có 214.
- **Chi phí chung khác:**
  - Các trường: tên khoản, số tiền, loại cố định/biến đổi, VAT, thanh toán 111/331, NCC.
  - Bút toán: Nợ 627 / Nợ 1331 / Có 111 hoặc 331.
- **Validate:** số tiền > 0; khấu hao chỉ lập 1 lần cho mỗi tài sản trong kỳ (cảnh báo trùng). Gọi `invalidate(2)`.
- **Wow:** bảng phân bổ SXC có thêm dòng mới và cột "Dưới công suất → 632" tính lại. Thêm 3 triệu khấu hao khi xưởng chạy 800/1.000 giờ thì khách thấy ngay 600.000 đ vào thẳng giá vốn, không vào giá thành.

### P1-4. Báo cáo hoàn thành / phiếu nhập kho thành phẩm
- **Form:** sản phẩm, SL hoàn thành, SL dở dang cuối kỳ (nhập vào đây thay cho ô `wip` rời rạc hiện nay), ngày.
- **Engine:** `DONE[o] = Σ qty` của các doc NK. Value của NK do engine gán `= card[o].Z × qty / DONE[o]`. Gọi `invalidate(6)`.
- **Wow:** giá thành đơn vị thay đổi theo sản lượng: hoàn thành ít thì z tăng. Trang Truy xuất có thêm lô mới với mã lô động.

### P1-5. Xuất dữ liệu ra Excel (thay cho tải file)
- Sandbox của artifact chặn tải file trực tiếp. Đề xuất theo thứ tự ưu tiên:
  1. **"Sao chép cho Excel":** tạo chuỗi TSV (tab + xuống dòng, số không định dạng, có dòng tiêu đề) rồi gọi `navigator.clipboard.writeText()`. Dán vào Excel/Google Sheets là ra đúng cột. Có ở các bảng N-X-T, sổ chi tiết vật tư, danh sách chứng từ, bút toán và thẻ giá thành.
  2. **Dự phòng** khi clipboard API bị chặn trong iframe: mở hộp thoại có `<textarea readonly>` đã chọn sẵn toàn bộ nội dung, kèm hướng dẫn "Nhấn Ctrl+C". Có thể thử thêm `document.execCommand('copy')`, bọc `try/catch`.
  3. *(Tùy chọn)* Nếu runtime artifact có khả năng "đưa file cho người xem lưu" thì thêm nút "Tải CSV (UTF-8 có BOM)". Kiểm tra khả năng này khi dựng artifact, không coi là mặc định.
- **Wow:** dán vào Excel thấy cột Nợ/Có cân, số khớp từng đồng với màn hình.

### P1-6. Tour hướng dẫn từng bước
- Lớp phủ làm mờ màn hình, khoanh sáng phần tử đang được hướng dẫn và có bong bóng lời dẫn. Mỗi bước **chờ khách tự làm thao tác thật** rồi mới qua bước sau, bằng cách nghe sự kiện `docSaved`, `methodChanged`, `stepRun`. Có nút "Làm giúp tôi" để tự điền và lưu.
- Gồm 7 bước, khớp với kịch bản 5 phút ở mục 3:
  1. Tổng quan
  2. Lập PN lùi ngày
  3. Xem ô Ảnh hưởng và giải thích đơn giá
  4. Truy xuất bàn BG-01
  5. Đổi TT 133
  6. Chạy khóa sổ
  7. Thử sửa (bị chặn) rồi mở khóa có lý do
- Tiến độ tour lưu trong `localStorage` (`try/catch`). Có thể bỏ qua bất kỳ lúc nào.

### P1-7. Thêm NCC / khách hàng mới
- Thêm ngay trong ô chọn của form ("+ Thêm …"). Các trường: tên (bắt buộc, không trùng tên, tự thêm hậu tố "(mẫu)" nếu khách muốn) và MST (tùy chọn; nếu nhập thì phải là 10 hoặc 13 số dạng `0123456789-001`, chỉ kiểm tra định dạng).
- Engine: thêm vào `S.data.parties`. Không tính lại gì.
- Wow: tên NCC mới xuất hiện ngay trong cây truy xuất giá thành ("PX0017 ← PN0016 (NCC bạn vừa tạo)").

### P2-1. Thêm vật tư mới
- Các trường: mã (duy nhất, theo mẫu `NVL-XXX00`), tên, ĐVT, kho, tồn đầu SL/giá trị (mặc định 0).
- Engine: thêm vào `ITEMS` và `OPEN`. Mọi vòng lặp `['KEO','GO','SON']` phải chuyển thành `itemsOf('NVL')`. `glBalances` tính số dư đầu từ `OPEN`.
- Để P2 vì phải sửa nhiều chỗ render. *Không khuyến nghị* cho thêm **sản phẩm** mới, vì cần định mức, tiêu thức phân bổ và thẻ giá thành mới, ngoài phạm vi demo.

### P2-2. Nhập Excel bằng cách dán từ clipboard
- Ô `textarea` "Dán dữ liệu từ Excel". Cột: Ngày | Mã vật tư | NCC | SL | Đơn giá.
- Phân tích TSV, nhận số kiểu Việt Nam ("1.200.000") và ngày dạng `dd/mm/yyyy` hoặc `yyyy-mm-dd`.
- Bảng xem trước tô màu từng dòng: hợp lệ / lỗi (mã không tồn tại, ngày ngoài kỳ, SL ≤ 0) / cảnh báo (NCC mới sẽ được tạo).
- Bấm "Ghi sổ N dòng hợp lệ" thì lập 1 PN cho mỗi nhóm (ngày, NCC), ghi 1 dòng audit `import`, gọi `renderAll()` **một lần**.
- Có nút "Dán dữ liệu mẫu" để khách không cần mở Excel.
- Wow: 30 dòng ghi sổ và tính lại toàn bộ giá trong vài ms.

### P2-3. Chia sẻ kịch bản qua link
- Mã hóa `S.data.docs` do khách tạo thành base64 JSON gắn vào `location.hash` (`#s=...`), để sales gửi link "kịch bản xưởng của anh" cho khách. Chỉ làm khi dữ liệu nhỏ (< ~4 KB).

### P2-4. Chứng từ nháp và ghi sổ
- Cho lưu nháp: nháp không vào engine. Bước 1 "Ghi sổ toàn bộ chứng từ" chặn khóa sổ nếu còn nháp. Có giá trị kiểm soát nhưng ít "wow" hơn các mục trên.

---

## 2. Đề xuất cấu trúc lại dữ liệu

### 2.1 Tách "dữ liệu" khỏi "trạng thái giao diện"
```js
const SEED = {
  v: 2, period: { from:'2026-01-01', to:'2026-01-31', label:'01/2026' },
  items:   { KEO:{code:'NVL-KEO02', name:'Keo dán gỗ PVA', uom:'kg', kind:'NVL', wh:'K1', dec:3}, ... },
  open:    { KEO:{qty:100,value:1000000}, ... },          // = OPEN hiện tại
  parties: { S01:{type:'SUP', name:'Lâm sản Tây Nguyên (mẫu)'}, C01:{type:'CUS', name:'Nội thất Hòa Phát Đạt (mẫu)'}, ... },
  settings:{ normalHours:1000, wipOpen:{BG:5000000}, price:{BG:750000, GG:210000} },
  docs: [ /* toàn bộ chứng từ mẫu, gồm cả BL/KH/chi phí/NK/HD */ ],
  audit: []
};
const S = { ui:{view, item, sel, doc, lot}, regime, method, hours, wip,
            done, dirty, prev, data: load() || clone(SEED) };
```

### 2.2 Một kiểu chứng từ chung
```js
// type: PN mua | PX xuất SX | NK nhập TP | HD bán | TL trả lại | KK kiểm kê | BL lương | KH khấu hao | CP chi phí chung
doc = {
  no:'PN0016', type:'PN', date:'2026-01-08', createdAt:'2026-02-02T09:15',
  origin:'seed'|'user', status:'posted'|'void', partyId:'S02',
  to:'BG',                         // PX: đối tượng tập hợp chi phí
  ref:'HD0012',                    // TL: hóa đơn gốc
  vat:0.1, pay:'331',
  lines:[ {item:'KEO', qty:50, value:575000} ],    // PN
       // {item:'BG', qty:20, price:750000}        // HD/TL
       // {item:'KEO', qty:2, counted:98}          // KK (qty = chênh lệch có dấu)
       // {obj:'BG', amt:18000000, role:'NC'}      // BL
       // {name:'Điện SX', amt:7000000, fixed:false} // CP/KH
  desc:'Mua keo PVA', replaces:null, voidedBy:null
};
```
Hai chứng từ mẫu `PN0015` (BACKDATED) và `HD-DIEN01` chuyển thành doc thường. Nút "Thêm phiếu nhập lùi ngày 08/01" giữ lại như **phím tắt mở form điền sẵn** PN0015, để kịch bản cũ vẫn dùng được.

### 2.3 Từ chứng từ ra dữ liệu cho engine
```js
function active(){ return S.data.docs.filter(d => d.status !== 'void'); }

function deriveMoves(docs){
  const mv = {}; Object.keys(S.data.items).forEach(k => mv[k] = []);
  docs.forEach(d => d.lines.forEach((l, i) => {
    const id = d.lines.length > 1 ? `${d.no}#${i+1}` : d.no, base = {id, doc:d.no, date:d.date, desc:d.desc, isUser:d.origin==='user'};
    switch (d.type) {
      case 'PN': mv[l.item].push({...base, kind:'in',  qty:l.qty, value:l.value}); break;
      case 'PX': mv[l.item].push({...base, kind:'out', qty:l.qty, to:d.to}); break;
      case 'NK': mv[l.item].push({...base, kind:'in',  qty:l.qty, value:null, fromCard:true}); break; // gán sau
      case 'HD': mv[l.item].push({...base, kind:'out', qty:l.qty, to:'sale', price:l.price}); break;
      case 'TL': mv[l.item].push({...base, kind:'ret', qty:l.qty, ref:d.ref}); break;
      case 'KK': mv[l.item].push(l.qty < 0 ? {...base, kind:'out', qty:-l.qty, to:'loss'}
                                         : {...base, kind:'in',  qty:l.qty, value:l.value}); break;
    }
  }));
  return mv;
}

function compute(){
  const docs = active(), mv = deriveMoves(docs), R = {items:{}, val:{}};
  const nvlM = effMethod('NVL');
  itemsOf('NVL').forEach(k => { R.items[k] = valuate(S.data.open[k], mv[k], nvlM); });
  // nvl theo đối tượng: như hiện tại, đọc r.to từ rows
  const NC   = sumBy(docs.filter(d=>d.type==='BL'), l=>l.role==='NC', l=>l.obj, l=>l.amt); // {BG, GG}
  const POOL = docs.filter(d=>['BL','KH','CP'].includes(d.type))
                   .flatMap(d => d.lines.filter(l=>l.role!=='NC').map(l => ({...l, doc:d.no})));
  const DONE = sumBy(docs.filter(d=>d.type==='NK'), ()=>true, l=>l.item, l=>l.qty);
  // card[o] như hiện tại, nhưng dùng NC/POOL/DONE ở trên; chặn DONE[o]===0
  itemsOf('TP').forEach(k => {
    mv[k].filter(m=>m.fromCard).forEach(m => m.value = Math.round(card[k].Z * m.qty / DONE[k])); // chia Z theo NK
    R.items[k] = valuate(S.data.open[k], mv[k], effMethod('TP'));
  });
  const sales = docs.filter(d=>d.type==='HD').flatMap(d=>d.lines);
  const rets  = docs.filter(d=>d.type==='TL').flatMap(d=>d.lines.map(l=>({...l, price: priceOf(d.ref, l.item)})));
  R.revenue = Σ(sales, l=>l.qty*l.price) - Σ(rets, l=>l.qty*l.price);
  R.qtySold = groupSum(sales, 'item') - groupSum(rets,'item');    // cho KPI "x bàn, y ghế"
  // index giá trị đã định giá theo số chứng từ để buildDocs tra cứu
  Object.values(R.items).forEach(it => it.rows.forEach(r => R.val[r.id] = r));
  R.docs = buildDocs(R, S.data.docs);   // gồm cả chứng từ void (hiển thị gạch ngang)
  return R;
}
```

### 2.4 Bút toán: bảng hàm theo loại chứng từ
```js
const POST = {
  PN: (d,R) => d.lines.flatMap(l => [L(role('RM'), l.value, 0, code(l.item))])
               .concat([L('1331', vat(d)), L(d.pay, 0, total(d)+vat(d), party(d))]),
  PX: (d,R) => d.lines.flatMap(l => { const v = R.val[mid(d,l)].value;
               return [L(role('NVL'), v, 0, objLabel(d.to)), L(role('RM'), 0, v, code(l.item))]; }),
  HD: (d,R) => ..., TL: ..., KK: ..., BL: ..., KH: ..., CP: ..., NK: ...
};
function buildDocs(R, all){
  const out = all.map(d => ({ no:d.no, date:d.date, desc:descOf(d), origin:d.origin,
     status: d.status==='void' ? 'void' : statusOf(d), lines: d.status==='void' ? [] : POST[d.type](d,R),
     src: srcOf(d) }));
  if (stepDone(5)) out.push(kc0001(R));          // giữ nguyên logic kết chuyển hiện có
  return out.sort(byDateNo);
}
```
`valuate()` cần thêm:
- Xử lý `kind:'ret'` (mục P1-1).
- Cảnh báo tồn âm theo ngày cho cả 3 phương pháp. Trả về `negatives:[{id, date, short}]` thay cho một chuỗi `warn` duy nhất.
- Chặn chia cho 0.

### 2.5 Ghi chứng từ, tính lại có phạm vi, nhật ký, lưu trữ
```js
const AFFECT = { KK:1, BL:2, KH:2, CP:2, PN:3, PX:3, NK:6, HD:7, TL:7 }; // chỉ số bước (0-based) đầu tiên bị ảnh hưởng
function invalidate(from){ for (let i = from; i < STEPS.length; i++) if (S.done[i]) S.dirty[i] = true; }

function guardPeriod(date){
  if (locked()) throw new UserError('Kỳ 01/2026 đã khóa sổ. Cần kế toán trưởng mở khóa và ghi lý do.');
  if (date < S.data.period.from || date > S.data.period.to) throw new UserError('Ngày ngoài kỳ 01/2026');
}

function commit(mutator, auditEntry){
  const before = snapshot(R);                  // {unitOut:{PX0004:…}, z:{BG,GG}, cogs, gross, stock}
  const t0 = performance.now();
  mutator(S.data);                             // push doc / set void / ...
  S.data.audit.push({at:nowISO(), actor:'Khách demo', ...auditEntry});
  invalidate(auditEntry.from);
  renderAll();
  showImpact(diff(before, snapshot(R)), performance.now() - t0);   // ô "Ảnh hưởng"
  save();
}

function createDoc(doc){ guardPeriod(doc.date); validate(doc);
  doc.no = nextNo(doc.type); doc.origin = 'user'; doc.status = 'posted';
  commit(D => D.docs.push(doc), {action:'create', no:doc.no, from:AFFECT[doc.type]}); }

function voidDoc(no, reason){ const d = find(no); guardPeriod(d.date); checkVoidable(d);
  commit(() => { d.status = 'void'; d.voidReason = reason; },
         {action:'void', no, reason, from:AFFECT[d.type]}); }

function editDoc(no, patch, reason){ const old = find(no); guardPeriod(old.date);
  const neo = {...clone(old), ...patch, no:nextNo(old.type), replaces:no, origin:'user'}; validate(neo);
  commit(D => { old.status='void'; old.voidedBy=neo.no; D.docs.push(neo); },
         {action:'edit', no, newNo:neo.no, reason, diff:shallowDiff(old, neo),
          from:Math.min(AFFECT[old.type], AFFECT[neo.type])}); }

function unlock(reason){ if (reason.trim().length < 15) throw new UserError('Ghi rõ lý do mở khóa');
  S.done[11] = false; S.data.audit.push({at:nowISO(), action:'unlock', reason}); renderAll(); save(); }

const KEY = 'giagoc-demo-v2';
function save(){ try { localStorage.setItem(KEY, JSON.stringify({data:S.data, done:S.done, dirty:S.dirty,
                       regime:S.regime, method:S.method, hours:S.hours, wip:S.wip})); } catch(_){} }
function load(){ try { const o = JSON.parse(localStorage.getItem(KEY)); return o && o.data && o.data.v === 2 ? o : null; }
                 catch(_){ return null; } }
function resetSample(){ try { localStorage.removeItem(KEY); } catch(_){}
  S.data = clone(SEED); S.done = STEPS.map((_,i)=>i<4); S.dirty = STEPS.map(()=>false); renderAll(); }
```
Ghi chú:
- `nextNo(type)` lấy số lớn nhất trong cùng loại (kể cả chứng từ đã hủy) rồi cộng 1, đệm đủ 4 chữ số.
- `snapshot`/`diff` chỉ so khoảng 10–20 chỉ số, nên ô Ảnh hưởng luôn ngắn gọn.
- `runStep()` cần thêm phần kiểm tra thật: bước 4 dừng khi `R.items[*].negatives` khác rỗng; bước 11 dừng khi Nợ ≠ Có hoặc kho ≠ sổ cái.

### 2.6 Những chỗ render cần đổi
- KPI doanh thu dùng `R.qtySold`.
- Biểu đồ: `max = ceil(max(hist)/50)*50`.
- `STEPS[0]` dùng `R.docs.filter(d=>d.status!=='void').length`.
- Mã lô ở trang Truy xuất lấy từ các doc NK.
- `SUP[src]` đổi thành `partyName(docOf(src))`.
- Trang Chứng từ: lọc "Của tôi", cột thao tác Sửa/Hủy, dòng hủy gạch ngang.
- Thêm tab "Nhật ký sửa đổi".
- Thanh trên: các nút "+ Lập chứng từ ▾" và "Đặt lại dữ liệu mẫu".

---

## 3. Kịch bản demo 5 phút cho sales

Chuẩn bị: bấm "Đặt lại dữ liệu mẫu"; để chế độ TT 99/2025, phương pháp bình quân cuối kỳ, mở trang Tổng quan.

| Thời gian | Thao tác | Câu nói gợi ý | Khách nhìn vào |
|---|---|---|---|
| 0:00–0:40 | Trang Tổng quan | "Đây là xưởng nội thất tháng 01: 21 chứng từ, giá thành bàn ~xx nghìn đ/chiếc. Mọi con số trên màn hình đều tính từ chứng từ, không ai gõ tay." | KPI, cơ cấu giá thành, dòng "Kho khớp sổ cái" |
| 0:40–1:50 | **Mời khách tự lập phiếu nhập:** + Lập chứng từ → Phiếu nhập mua → keo PVA, 50 kg, 11.500 đ/kg, **ngày 08/01** (lùi ngày), NCC "Hóa chất Phương Nam" | "Kế toán hay nhận hóa đơn muộn. Anh chị cứ lập lùi ngày như ngoài đời." Chỉ vào dòng cảnh báo "lùi ngày so với PX0004, PX0011" và bảng bút toán xem trước | Bút toán tự sinh, không gõ tài khoản |
| 1:50–2:30 | Lưu → ô **Ảnh hưởng** → bấm dòng PX0004 | "Hai phiếu xuất keo, giá thành bàn và giá vốn tính lại trong 3 ms. Với MISA, chỗ này phải chạy lại tính giá xuất kho, và thường người ta quên." Mở phần "Nguồn gốc đơn giá": công thức và danh sách phiếu nhập, NCC | Số trước → sau; công thức bình quân |
| 2:30–3:10 | Trang **Truy xuất giá thành**, lô bàn BG-01 | "Mỗi chiếc bàn: NVL lấy từ phiếu xuất nào, phiếu nhập nào, NCC nào, phần nào là sản xuất chung. Có cả phiếu anh chị vừa lập." | Lá PN mới trong cây |
| 3:10–3:40 | Đổi chế độ sang **TT 133** rồi xem trang Chứng từ | "DN nhỏ dùng TT 133: chi phí ghi thẳng 154. Chọn chế độ là xong, bút toán tự đổi." | 621/622/627 → 154 |
| 3:40–4:20 | Trang **Khóa sổ** → Chạy tất cả | "12 bước chạy đúng thứ tự. Nếu có tồn âm, bước 4 dừng và chỉ ra đúng phiếu." (Nếu còn thời gian, mời khách lập 1 phiếu xuất quá tồn để thấy bước 4 dừng.) | Con dấu "Đã khóa sổ" |
| 4:20–5:00 | Thử sửa hoặc hủy một phiếu → bị chặn → **Mở khóa có lý do** → mở tab Nhật ký | "Khóa là khóa thật. Muốn mở phải là kế toán trưởng và ghi lý do; mọi lần sửa, hủy, mở khóa đều có nhật ký theo TT 99." Kết thúc: "Anh chị giữ link này, tự nghịch tiếp. Muốn làm lại thì bấm Đặt lại dữ liệu mẫu." | Nhật ký sửa đổi |

Phương án dự phòng:
- Khách hỏi "xuất Excel được không" → bấm "Sao chép cho Excel" ở bảng N-X-T, dán vào Excel/Sheets.
- Khách hỏi "nhập hàng loạt" → P2 "Dán từ Excel" với dữ liệu mẫu.
- Khách là kế toán trưởng → cho tự làm hàng bán bị trả lại hoặc phiếu kiểm kê thiếu hàng, rồi chạy lại khóa sổ.

---

## 4. Thứ tự làm đề xuất
1. Tái cấu trúc dữ liệu: SEED, docs, deriveMoves, POST, sửa các lỗi ở mục 0.
2. Kiểm tra hồi quy: số liệu mẫu sau tái cấu trúc phải **khớp từng đồng** với bản hiện tại ở cả 3 phương pháp × 2 chế độ.
3. Hạ tầng form dùng chung: xem trước bút toán, ô Ảnh hưởng, guardPeriod, lưu/đặt lại.
4. Các mục P0-1 đến P0-5.
5. Nhóm P1: tour sau cùng, vì tour phụ thuộc giao diện đã ổn định.
6. Nhóm P2.
