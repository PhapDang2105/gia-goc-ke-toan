# Phản biện UI/UX: bản demo "Giá Gốc" (gia-goc-demo.html)

Người phản biện: góc nhìn UI/UX phần mềm kế toán/ERP Việt Nam. Ngày: 04/10/2026.

**Cách kiểm tra.** Đọc toàn bộ 769 dòng code. Chạy thật trong Chrome qua `http://127.0.0.1` (Chrome chặn `file://`). Dùng bản sao trong scratchpad có thêm `<meta charset>` vì skeleton chỉ được thêm lúc publish. Các thao tác chạy bằng JS trên DOM thật: đổi phương pháp, đổi TT99/TT133, chọn phiếu, thêm phiếu lùi ngày, chạy từng bước và chạy tất cả, làm lại. Xem bản điện thoại bằng iframe rộng 390px. Không chụp được màn hình (Chrome báo timeout 2 lần), nên phần hình ảnh được đánh giá qua số đo DOM và code. Console không có lỗi JS. File HTML gốc không bị sửa.

Số dòng bên dưới là số dòng của file gốc.

---

## 1. Lỗi chức năng và hiển thị

| # | Mức | Lỗi | Dòng | Tái hiện |
|---|---|---|---|---|
| B1 | **P0** | **Màn hình đầu tiên báo sổ cái 154 âm 133.985.656, lệch 139.892.222.** Phiếu nhập kho thành phẩm NK0001/NK0002 (Nợ 155/Có 154) luôn được ghi. Còn bút toán kết chuyển KC0001 (Nợ 154) chỉ sinh khi đã xong bước 6. Vì vậy trước khi khóa sổ, 154 trên sổ cái âm hơn 100 triệu. Ngay bên dưới lại có câu "số dư tài khoản hàng tồn kho luôn bằng giá trị tồn trên sổ chi tiết", tức là trang tự phủ nhận đúng điểm khác biệt nó muốn chứng minh. | 497–512, 578–580, 582–588, 207 | Mở trang ở trạng thái mặc định, xem bảng "Đối chiếu kho với sổ cái". Lỗi cũng lặp lại sau khi bấm "Thêm phiếu nhập lùi ngày", vì các bước 5–8 bị đánh dấu chạy lại nên KC0001 biến mất. |
| B2 | **P0** | **Hai tín hiệu trái ngược trên cùng màn hình.** Ô "Việc cần làm" hiện pill xanh "Khớp: giá trị kho khớp sổ cái 152 và 155" vì chỉ kiểm 152 và 155. Panel đối chiếu thì báo "Chờ kết chuyển" và lệch 139 triệu ở 154. | 567–568 so với 578–580 | Trạng thái mặc định, trang Tổng quan. |
| B3 | **P0** (tùy cách gửi) | **File không có `<meta charset="utf-8">`.** Nếu file .html được gửi qua Zalo hoặc email rồi mở trực tiếp, hay được phục vụ không kèm charset, toàn bộ tiếng Việt vỡ thành "GiÃ¡ Gá»‘c" (đã thấy thật khi chạy qua http.server). Khi publish thành artifact thì không lỗi, vì skeleton có thêm charset. | 1 | Phục vụ file gốc qua `python -m http.server`: `document.characterSet` = `windows-1252`. |
| B4 | P1 | **Thẻ so sánh phương pháp lệch với sổ chi tiết.** Khi đang chọn "Bình quân cuối kỳ" nhưng chưa chạy bước 5, sổ chi tiết dùng giá tạm bình quân tức thời (tổng xuất keo 3.822.222). Thẻ được tô viền "đang chọn" lại hiện 3.850.000. Khách sẽ hỏi con số nào mới đúng. | 627, 635–636 | Vào Giá xuất kho, vật tư Keo, trạng thái mặc định. |
| B5 | P1 | **Dòng "N phiếu đang dùng giá tạm (bình quân tức thời)" sai khi dùng FIFO hoặc bình quân tức thời.** Bộ đếm còn tính cả 2 phiếu NK có trạng thái `prov`, nên vẫn hiện "2 phiếu… bình quân tức thời" dù phương pháp đang là FIFO. | 511, 544, 563 | Đổi Giá xuất kho sang FIFO rồi xem Tổng quan. |
| B6 | P1 | **Hóa đơn bán hiện "Giá đã chốt" trong khi giá thành còn tạm tính.** Với FIFO hoặc bình quân tức thời, `stOut` luôn trả về `final`, mà giá vốn của HD lại lấy từ NK0001/NK0002 (còn "Giá tạm"). Hai trạng thái mâu thuẫn trên cùng danh sách. | 482, 514 | Chọn FIFO, vào Chứng từ: HD0012 hiện "Giá đã chốt", NK0001 hiện "Giá tạm". |
| B7 | P1 | **Hướng dẫn ở trang Chứng từ không làm theo được.** Câu dẫn ghi "Đổi sang TT 133 để thấy chi phí SX ghi thẳng vào 154". Nhưng (a) chứng từ được chọn sẵn là HD0012 (bán hàng), nên đổi chế độ không thấy gì thay đổi; (b) sau khi kỳ đã khóa thì ô chọn chế độ bị vô hiệu mà không có lời giải thích nào. | 214, 536, 592 | Chạy tất cả rồi vào Chứng từ: ô "Chế độ" xám, không có tooltip. |
| B8 | P1 | **Nút "Thêm phiếu nhập lùi ngày" biến mất khi đổi vật tư khác Keo.** Đây là thao tác "wow" chính của demo. Nếu người trình bày đi từ Chứng từ qua nút "Xem đơn giá…" của phiếu gỗ hoặc sơn thì không còn thấy nút này. | 624, 748 | Chứng từ → chọn PX0005 → "Xem đơn giá xuất được tính từ đâu". |
| B9 | P1 | **Mất focus bàn phím sau khi chọn dòng.** Các dòng có `tabindex=0` và xử lý phím Enter, nhưng `renderAll()` thay `innerHTML` nên focus rơi về `body`. Phím Space cũng không có tác dụng. | 594, 632, 743–747 | Tab đến một dòng PX rồi nhấn Enter, sau đó nhấn Tab: focus quay về đầu trang. |
| B10 | P1 | **Số liệu biểu đồ không nhất quán.** Biên lãi gộp các tháng 08–12/2025 khoảng 24–26% (41/168,2…), tháng 01/2026 lại là 39,8%. Kế toán trưởng sẽ hỏi ngay vì sao biên tăng 14 điểm. | 552 | Xem biểu đồ ở Tổng quan. |
| B11 | P2 | Bước 1 ghi "21 chứng từ đã ghi sổ", nhưng sau bước 6 số này tự thành 22 vì có thêm KC0001, tức là kết quả của bước đã xong bị thay đổi về sau. | 365, 713 | Chạy tất cả rồi đọc bước 1. |
| B12 | P2 | View được nhớ trong `localStorage`. Nếu lần trước người trình bày dừng ở Khóa sổ, khách mở link sẽ vào thẳng Khóa sổ thay vì Tổng quan. | 739, 765 | Chuyển sang Khóa sổ rồi tải lại trang. |
| B13 | P2 | Toast không có `role="status"` / `aria-live`, nên trình đọc màn hình không đọc được kết quả thao tác. | 297 | — |
| B14 | P2 | Ô chọn và input bị `disabled` khi kỳ đã khóa nhưng không có `title` hay dòng giải thích. Khách bấm thấy "chết" mà không biết vì sao. | 536 | Chạy tất cả rồi bấm vào ô "Giá xuất kho". |

---

## 2. Vấn đề UX

### 2.1 Luồng giới thiệu: khách có thấy ngay điểm khác biệt không?
Hiện tại là **chưa**. Sản phẩm có 4 điểm khác biệt thật, nhưng đang nằm rải rác và phải biết chỗ mới tìm ra:
1. Nhập lùi ngày thì hệ thống tự tính lại giá xuất, giá thành, giá vốn và đánh dấu các bước khóa sổ cần chạy lại. Nút nằm ở trang thứ 4, chỉ hiện với Keo.
2. Truy xuất giá thành đến tận phiếu nhập và nhà cung cấp (trang 6).
3. Kho luôn khớp sổ cái. Đây chính là chỗ đang hiện **lệch 139 triệu** (B1).
4. Chi phí SXC cố định dưới công suất được đưa thẳng vào 632 theo VAS 02. Hiện chỉ là một dòng trong ô "Việc cần làm".

Trang Tổng quan đang giống một dashboard bình thường: 4 KPI, biểu đồ, việc cần làm. Không có câu nào trả lời câu hỏi "khác MISA ở đâu". Gợi ý duy nhất về kịch bản demo ("Mẹo: bấm Chạy tất cả…") lại nằm ở trang cuối.

Sau khi nhập lùi ngày, giá vốn chỉ đổi khoảng 10.000 đ trên 129 triệu (129.275.088 → 129.264.925). Hiệu ứng nhấp nháy 2,4 giây quá ngắn và không cho biết chênh bao nhiêu, nên khách gần như không nhận ra.

### 2.2 Phân cấp thông tin
- KPI không ghi đơn vị "đ" và không có so sánh kỳ trước. Trong khi đó trục biểu đồ tính bằng triệu, nên khó đối chiếu.
- Mỗi trang đều mở đầu bằng một đoạn "lead" màu xám, nhưng đó lại là chỉ dẫn thao tác quan trọng nhất. Câu này đang bị làm mờ thay vì được nhấn mạnh.
- Ở Khóa sổ có 3 nút ngang hàng ("Làm lại từ đầu" cạnh "Chạy tất cả"). Nút phá trạng thái nên tách ra xa.

### 2.3 Thuật ngữ
- Nhiều từ viết tắt không chú giải: SXC, NCTT, NVL, GT, SL, "dở dang", "tiêu thức". Kế toán trưởng hiểu được, nhưng chủ doanh nghiệp thì không.
- "Kiểm tra bất biến" là từ của lập trình viên. Kế toán nói "Kiểm tra cân đối" hoặc "Đối chiếu số liệu".
- Pill "Giá tạm" trên hóa đơn bán dễ bị hiểu là **giá bán** tạm. Nên đổi thành "Giá vốn tạm tính".
- "VAS 02" để làm nhãn pill thì khó hiểu với chủ doanh nghiệp. Nên viết "Chi phí dưới công suất".
- Số âm đang hiển thị dạng "-2.000.000". Báo cáo kế toán Việt Nam (và MISA) quen dùng ngoặc đơn "(2.000.000)".

### 2.4 Độ dày bảng
- Font 13px và padding 7/10px là mức vừa phải với dân kế toán. Bảng N-X-T 12 cột cũng đúng mẫu quen thuộc.
- Còn thiếu: dòng lọc và tìm kiếm trên danh sách chứng từ; cột đầu (Mã, Số CT) không cố định khi cuộn ngang; không có dòng sọc (zebra), nên bảng dài 22 dòng khó dò theo hàng.

### 2.5 Trạng thái
Có tới 4 nhóm pill (Đã ghi sổ / Giá đã chốt / Giá tạm / Mới · lùi ngày), cộng thêm "Đang mở / Đã khóa", "Khớp / Lệch / Chờ kết chuyển", "Xong / Tiếp theo / Cần chạy lại". Màu sắc nhất quán, nhưng như ở B5 và B6, logic gán trạng thái đang mâu thuẫn. Kỳ đã khóa chỉ được báo bằng một pill nhỏ trên thanh trên. Dấu mộc "Đã khóa sổ" (rất đẹp) chỉ thấy ở trang Khóa sổ.

### 2.6 Khả năng bấm
- Dòng bấm được chỉ được nhận ra nhờ con trỏ chuột, không có biểu tượng hay mũi tên nào. Trên cảm ứng thì không có cách nhận biết.
- Nút cao 36–37px là chấp nhận được trên desktop, nhưng dưới mức 44px trên điện thoại.
- Cây truy xuất dùng `<details>` nên bấm và dùng bàn phím đều được. Tốt.

### 2.7 Mobile (đo ở 390px)
- Không bị cuộn ngang trang. Tốt.
- Nội dung bắt đầu ở y = 352–391px, tức khoảng 45% màn hình đầu tiên là logo, menu, dải demo và thanh trên (cao 130–169px vì 3 ô chọn xuống dòng).
- Menu cuộn ngang 1.070px trong khung 327px, khoảng 70% mục bị ẩn và không có dấu hiệu "còn nữa".
- Dòng tóm tắt của cây truy xuất (`grid 14px 1fr auto auto`, dòng 114) cao tới **328px** vì tiêu đề bị ép hẹp. Mỗi lá cao 140–200px.
- Bảng rộng 504–914px trong khung 291px, chỉ đọc được bằng cuộn ngang và cột mã không cố định.
- Ở Chứng từ và Giá xuất kho, bấm một dòng thì panel chi tiết cập nhật **ở phía dưới, ngoài tầm nhìn**, nên người dùng tưởng bấm không ăn.

### 2.8 Dark mode
Token màu đầy đủ, có hỗ trợ `prefers-color-scheme` và `data-theme`. Độ tương phản dark mode đều ≥ 5,5:1. Nhưng **không có nút chuyển sáng/tối**, nên người trình bày không chủ động được khi máy chiếu cần nền sáng.

### 2.9 Accessibility
- Pill vàng (`--warn` #a46200 trên #fbf0dc) và dải demo đạt **4,3:1**, chưa tới 4,5:1 của AA cho chữ 11,5–12,5px.
- Có thêm các lỗi B9, B13, B14.
- Biểu đồ SVG có `role="img"` và `aria-label` nhưng không có bảng số thay thế.
- Thanh cơ cấu giá thành chỉ dùng màu, giá trị nằm trong `title`, nên trên cảm ứng không xem được.

---

## 3. Đề xuất cải thiện (theo mức ưu tiên)

### P0: phải sửa trước khi đưa khách xem

**P0-1. Sửa đối chiếu 154 (B1, B2).**
- Trong `glBalances()` (dòng 582), khi `!stepDone(5)` và chế độ là TT99: cộng thêm vào 154 phần chi phí còn nằm ở 621/622/627 (tức là coi như đã kết chuyển tạm). Cách khác là đổi dòng 154 trong bảng đối chiếu thành "154 (gồm 621/622/627 chưa kết chuyển)" và so sánh với tổng 154 + 621 + 622 + 627.
- Tiêu chí đạt: ở mọi trạng thái, cột "Chênh lệch" phải bằng 0, hoặc dòng 154 hiện pill xám "Chờ kết chuyển" và cột chênh lệch hiện "—" thay cho số âm.
- Ô "Việc cần làm" (dòng 567) phải dùng chung một hàm kiểm tra với panel đối chiếu, để không thể có "Khớp" ở chỗ này và "Lệch" ở chỗ kia.
- Câu ở dòng 207 sửa thành: "Bút toán kho sinh từ chính sổ kho. Khi khóa sổ, số dư 152, 154, 155 bằng giá trị trên sổ chi tiết."

**P0-2. Thêm thanh "Kịch bản demo" ngay dưới thanh trên.** Thay dải demo-note màu vàng bằng một stepper ngang gồm 5 bước. Mỗi bước là một nút bấm được: chuyển sang đúng trang, chọn sẵn đúng đối tượng, rồi đặt viền nhấn (outline 2px `--accent` và nhấp nháy 2 lần) quanh nút hoặc vùng cần bấm.
1. "Giá vốn từng phiếu xuất, có công thức": vào cogs, chọn KEO, chọn PX0004.
2. "Nhập lùi ngày, tự tính lại": nhấn viền nút `btnBack`.
3. "Mỗi chiếc bàn gồm những gì": vào trace, chọn BG.
4. "Đổi TT 99 ↔ TT 133": vào docs, chọn PX0004, nhấn viền ô `regime`.
5. "Khóa sổ 1 nút, kho = sổ cái": vào close, nhấn viền `btnAll`.

Bước đã xem có dấu ✓. Trạng thái bước hiện tại chỉ giữ trong biến, không lưu vào storage. Trên điện thoại, stepper co thành "Bước 2/5 ‹ ›".

**P0-3. Làm cho thay đổi do nhập lùi ngày nhìn thấy được.**
- Sau khi bấm `btnBack`, các ô KPI và ô giá trị bị đổi hiện thêm chip chênh lệch cố định (không tự tắt), ví dụ "▼ 10.163 đ" màu `--warn` cạnh giá trị, cho đến khi bấm "Làm lại từ đầu".
- Đồng thời mở một panel nhỏ "Đã tính lại", liệt kê từng dòng *trước → sau*: PX0004, PX0011, giá thành BG-01/chiếc, giá vốn, tồn kho.
- Cách làm: lưu `R` trước khi đặt `S.backdated = true` rồi so sánh với `R` mới.

**P0-4. Kiểm tra lại số liệu mẫu của biểu đồ (B10).** Chỉnh lãi gộp lịch sử về biên 36–40% (ví dụ 08/25 lãi gộp 63,1 thay cho 41,0), hoặc giải thích lý do biên tăng.

**P0-5. Đảm bảo charset (B3).** Nếu có khả năng gửi file .html trực tiếp cho khách, thêm `<meta charset="utf-8">` vào dòng 1, trước `<title>`, vì dòng này vô hại khi publish. Nếu chỉ gửi link artifact thì không cần.

### P1: nên làm

**P1-1. Trạng thái nhất quán (B4, B5, B6).**
- Thẻ so sánh (`cmp`) dùng đúng `r.method` của sổ đang hiển thị. Khi đang dùng giá tạm, thẻ được chọn ghi: "Bình quân cuối kỳ · dự kiến 3.850.000 (đang hiển thị giá tạm 3.822.222)".
- Bộ đếm ở dòng 544 chỉ đếm phiếu PX và HD có `status === 'prov'`. Câu chữ lấy theo `effMethod`. Phiếu NK đếm riêng: "2 phiếu nhập thành phẩm dùng giá thành tạm tính".
- `stOut` cho hóa đơn bán thành phẩm phải phụ thuộc thêm `stepDone(6)`.

**P1-2. Trang Chứng từ.**
- Khi đổi chế độ, nếu chứng từ đang chọn không có dòng tài khoản nào thay đổi thì tự chọn PX0004.
- Các dòng tài khoản thay đổi giữa TT99 và TT133 được tô nền `--warn-soft` trong 3 giây, kèm chú thích nhỏ "621 → 154".
- Thêm ô tìm kiếm (theo số CT hoặc diễn giải) và bộ lọc trạng thái dạng chip: Tất cả / Giá tạm / Mới. Đặt ở `panel-head` bên trái `docCount`.

**P1-3. Ô bị khóa phải có lời giải thích (B7, B14).** Khi `locked()`, đặt `title="Kỳ 01/2026 đã khóa. Bấm 'Làm lại từ đầu' ở trang Khóa sổ để mở lại."` cho cả 4 ô. Thêm một dòng nhỏ dưới thanh trên: "Kỳ đã khóa: các thiết lập bị khóa · [Mở lại kỳ]", trong đó "Mở lại kỳ" gọi cùng hàm với btnReset.

**P1-4. Nút nhập lùi ngày luôn hiển thị (B8).** Không ẩn khi đổi vật tư. Khi vật tư khác KEO, bấm nút thì chuyển `S.item = 'KEO'` trước rồi thực hiện. Đổi nhãn thành "Thử: nhập bổ sung keo lùi ngày 08/01".

**P1-5. Giữ focus khi chọn dòng (B9).** Sau `renderAll()`, gọi `document.querySelector('[data-doc="'+S.doc+'"]')?.focus()` (tương tự cho `data-sel`) nếu thao tác đến từ bàn phím. Thêm phím Space. Thêm `aria-selected` cho dòng đang chọn.

**P1-6. Mobile.**
- Ở ≤ 760px: ẩn chữ "Kế toán · Kho · Giá thành". Gộp 3 ô Chế độ / Giá xuất kho / Kỳ vào một nút "⚙ Thiết lập kỳ", bấm mở một sheet từ dưới lên. Mục tiêu là nội dung bắt đầu ở y ≤ 200px.
- Menu ngang: thêm lớp mờ dần (gradient) ở mép phải, và `scrollIntoView({inline: 'center'})` cho mục đang chọn.
- Cây truy xuất (dòng 114): ở ≤ 760px đổi summary thành `grid-template-columns: 14px 1fr`, đưa hai cột số xuống dòng thứ hai (`grid-column: 2`, căn trái).
- Sau khi chọn dòng ở Chứng từ hoặc Giá xuất kho, ở ≤ 1080px gọi `$('docDetail').scrollIntoView({behavior: 'smooth', block: 'start'})` (hoặc `#explain`).
- Cố định cột đầu của bảng bằng `position: sticky; left: 0; background: var(--surface)` trên `th:first-child, td:first-child`.
- Nút và dòng bấm có `min-height: 44px` trên màn hình cảm ứng (`@media (pointer: coarse)`).

**P1-7. Thuật ngữ.**
- Thêm `<abbr title>` cho SXC, NCTT, NVL. Lần đầu xuất hiện thì viết đầy đủ.
- Đổi "Kiểm tra bất biến: Nợ = Có, kho = sổ cái" thành "Kiểm tra cân đối: tổng Nợ = tổng Có, kho khớp sổ cái".
- Đổi pill "Giá tạm" thành "Giá vốn tạm tính".
- Đổi pill "VAS 02" thành "Dưới công suất", giữ "VAS 02" trong phần chú thích.
- Số âm hiển thị dạng `(2.000.000)`: sửa `fmt` thành `n < 0 ? '(' + ... + ')' : ...`.

**P1-8. KPI.** Thêm "đ" sau giá trị (cỡ chữ 14px, màu muted). Thêm dòng so sánh với 12/2025 dựa trên mảng `hist`, ví dụ "▲ 9% so với 12/2025".

**P1-9. Độ tương phản màu vàng.** Đổi `--warn` (light) thành `#8a5300`, đạt khoảng 5,6:1 trên `--warn-soft`.

### P2: hay ho

**P2-1. Thanh công cụ dạng ribbon kiểu phần mềm kế toán.** Ở trang Chứng từ, thêm thanh nút quen tay với kế toán Việt Nam: Thêm · Sửa · Ghi sổ · Bỏ ghi · In · Xuất Excel, có biểu tượng phía trên chữ. Trong demo chỉ cần hiện toast "Bản demo". Dùng màu và biểu tượng riêng của Giá Gốc, không dùng xanh dương hay biểu tượng của MISA.

**P2-2. Ghi số hiệu mẫu sổ.** Ghi mẫu sổ ở tiêu đề bảng ("Sổ chi tiết vật tư · Mẫu S10-DN", "Bảng tổng hợp N-X-T"), đi kèm nút "Xem mẫu in" mở bản in có quốc hiệu, chữ ký Người lập / Kế toán trưởng / Giám đốc. Đây là điều kế toán trưởng luôn hỏi.

**P2-3. Nút chuyển sáng/tối.** Đặt ở chân sidebar, chuyển giữa `data-theme="light"` và `data-theme="dark"`. Chỉ lưu localStorage trong try/catch.

**P2-4. Dấu mộc "Đã khóa sổ" thu nhỏ.** Khi kỳ đã khóa, hiện dấu mộc cỡ 56px (xoay −12°) cạnh tiêu đề thanh trên ở mọi trang.

**P2-5. Giá trị thanh cơ cấu giá thành.** Hiển thị giá trị ngay dưới thanh (4 nhãn nhỏ: số đ/chiếc và %), thay cho `title`. Thêm bảng số ẩn (`visually-hidden`) cho biểu đồ.

**P2-6. Mở trang theo kịch bản.** Bỏ việc nhớ view qua localStorage (B12), hoặc chỉ dùng hash `#dash`, để link gửi khách luôn mở ở Tổng quan / bước 1 kịch bản.

**P2-7. Trợ năng.** Toast: thêm `role="status" aria-live="polite"`. Bảng: thêm dòng sọc `tbody tr:nth-child(even) td{background:color-mix(in srgb,var(--surface-2) 45%,transparent)}`.

**P2-8. Số chứng từ ở bước 1 (B11).** Chốt số chứng từ của bước 1 tại thời điểm chạy bước (lưu vào `S.stepResult[0]`) thay vì tính lại liên tục.
