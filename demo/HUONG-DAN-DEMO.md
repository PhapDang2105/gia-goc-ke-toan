# Hướng dẫn trình diễn demo cho khách

> Phiên bản: 1.0 · Ngày: 2026-10-07 · Người phụ trách: Quản lý dự án · Trạng thái: Chờ duyệt (người dùng duyệt kịch bản trước buổi gặp khách)
> Áp dụng cho `gia-goc-demo.html` bản v4.0 (số liệu ở [CHANGELOG.md](CHANGELOG.md) "Số chính hiện hành"). Nếu demo đổi tên trang, nút hoặc dữ liệu mẫu thì sửa kịch bản này cùng lúc.
> Viết tắt: theo [THUAT-NGU](../docs/00-tong-quan/THUAT-NGU.md) §2 (trên màn hình demo không có chữ viết tắt).

## 1. Mục tiêu buổi trình diễn

Thời lượng 10–15 phút. Khách cần thấy được **một điều**: phần mềm cho biết **giá vốn của từng lô** và **giải thích được** giá đó đến từ lô nguyên liệu nào, giá bao nhiêu ([QD-07](../docs/02-ke-hoach/QUYET-DINH.md#qd-07)). Mọi bước dưới đây phục vụ điều đó. Không trình diễn tính năng không có trong demo.

Sau buổi, cần mang về câu trả lời (hoặc hẹn ngày trả lời) cho: [CH-10](../docs/01-yeu-cau/CAU-HOI-MO.md#ch-10) tiêu thức phân bổ, [CH-31](../docs/01-yeu-cau/CAU-HOI-MO.md#ch-31) bồn trộn nhiều lô, [CH-45](../docs/01-yeu-cau/CAU-HOI-MO.md#ch-45) mã hóa, [CH-46](../docs/01-yeu-cau/CAU-HOI-MO.md#ch-46) mã lô, [CH-47](../docs/01-yeu-cau/CAU-HOI-MO.md#ch-47) thời gian ủ.

## 2. Chuẩn bị (trước buổi, 5 phút)

1. Mở demo bằng Chrome (cách mở: [README](../README.md) mục "Mở demo"). Màn hình ngang tối thiểu 1366px; nếu chiếu máy chiếu thì phóng to trình duyệt 110–125%.
2. Bấm **Đặt lại dữ liệu mẫu** (cuối thanh bên trái) để số liệu đúng như kịch bản.
3. Trên thanh trên kiểm: **Chế độ** = Thông tư 99/2025, **Giá xuất** = Thực tế đích danh.
4. In thử một phiếu (bước 6) để chắc máy in / "Lưu thành PDF" hoạt động.
5. Nói trước với khách: **dữ liệu là mẫu** (kỳ 01/2026, tên đối tác giả định), không phải số của nhà máy.

## 3. Kịch bản

| # | Thời gian | Trang (menu bên trái) | Bấm gì | Khách thấy gì | Câu nói gợi ý |
|---|---|---|---|---|---|
| 1 | 1,5 phút | **Tổng quan** | Không bấm; chỉ vào 4 ô số và bảng "Giá vốn hàng bán theo sản phẩm" | Doanh thu thuần, giá vốn hàng bán, lãi gộp, hàng tồn kho cuối kỳ. Bảng theo sản phẩm có cột "Số lô đã bán" và "Đơn giá vốn thấp – cao" | "Cùng một sản phẩm nhưng mỗi lô có giá vốn khác nhau. Phần mềm không lấy giá trung bình cả tháng mà lấy đúng giá của lô bán ra." |
| 2 | 2 phút | **Giá nguyên liệu** | Ô **Vật tư** chọn "Cá linh tươi" | Hai lô cá: 050126-01 giá 45.000 đ/kg, 120126-01 giá 52.000 đ/kg, cột "So với lô trước" +15,6% chữ đỏ. Bên dưới: "Lịch sử giá" và bảng **Đã dùng cho** (lô cá → phiếu xuất → lệnh sản xuất → lô bán thành phẩm / thành phẩm) | "Mỗi lần nhập là một lô có giá riêng. Lô nào tăng quá 10% thì báo đỏ. Bấm vào là biết lô cá này đã đi vào lệnh nào, ra lô thành phẩm nào." |
| 3 | 3 phút | **Giá vốn theo lô** | Nút lọc **Thành phẩm**; bấm dòng lô **270126-01** (mắm cá linh hũ 500g), sau đó so với lô **290126-01** | Hai lô cùng sản phẩm: 43.457,56 và 48.788,92 đ/hũ. Bấm lô hiện **cây cấu thành**: lệnh sản xuất, lô bán thành phẩm, hũ, nhân công, sản xuất chung; mở dòng bán thành phẩm thấy lệnh giai đoạn trước và **lô cá 050126-01 cùng nhà cung cấp**. Dòng tổng bằng giá trị lô. Cuối cây: các hóa đơn đã bán từ lô (khách, số lượng, giá vốn, doanh thu, lãi gộp) | "Lô 290126-01 đắt hơn vì làm từ cá mua đợt hai giá 52.000. Đây là câu trả lời cho câu hỏi: lô này giá bao nhiêu, vì sao." |
| 4 | 2 phút | **Giá thành theo lệnh sản xuất** | Chỉ vào bảng lệnh, bảng "Phân bổ nhân công và sản xuất chung", thẻ giá thành | Mỗi lệnh là một dòng: dở dang đầu kỳ, nguyên vật liệu, bán thành phẩm, nhân công, sản xuất chung, hỏng ngoài định mức, tổng giá thành, giá thành đơn vị, dở dang cuối kỳ. Lệnh LSX-2512-05 (cá ủ từ tháng 12) còn dở dang 19.529.099. Mắm tôm LSX-2601-03 có 793.301 hỏng ngoài định mức đưa vào giá vốn | "Mỗi lệnh sản xuất tính giá riêng; lệnh ủ qua nhiều tháng thì chi phí cộng dồn cho đến khi nhập kho." **Phải nói thêm**: "Trong demo, nhân công và sản xuất chung đang chia theo chi phí nguyên liệu của lệnh — đây là giả định. Nhà máy đang chia theo cách nào?" (CH-10, [QD-29](../docs/02-ke-hoach/QUYET-DINH.md#qd-29)) |
| 5 | 2 phút | **Kho & lô** | Bảng **Tồn kho chi tiết**: bấm lọc **Bồn**; gõ "240126-01" vào ô tìm | Mỗi dòng: tên hàng · mã lô · mã hóa · vị trí · kho · hạn sử dụng · QC · số lượng · số ngày lưu kho · giá trị. Lô bán thành phẩm 240126-01 nằm ở hai bồn A.29 và A.30 (đã chuyển bồn bằng phiếu CK0003) | "Tồn kho theo dõi đúng như sổ kho của nhà máy: tên hàng, lô, mã hóa, bồn. Mã hóa do hệ thống tự cấp." Hỏi: "Một bồn có khi nào chứa hai lô hoặc châm thêm lô mới không?" (CH-31) |
| 6 | 2 phút | **Chứng từ & bút toán** | Nút lọc **Phiếu xuất kho** → bấm PX0001 → nút **In phiếu xuất kho …** ở đầu phần chi tiết. Sau đó tích ô đầu 2–3 dòng → **In các phiếu đã chọn** | Bản xem trước in: "Nhà máy chế biến mắm", số phiếu PXK-…, bảng nhóm hàng · tên hàng · lô · mã hóa · vị trí · số lượng · đơn giá · thành tiền, tiền bằng chữ, các ô ký. In nhiều phiếu: mỗi phiếu một trang | "Phiếu in theo mẫu sổ kho của nhà máy, có thêm đơn giá, thành tiền cho kế toán." |
| 7 | 2 phút (tùy chọn) | **+ Lập chứng từ** (góc phải trên) → **Phiếu nhập mua** | Ở dòng hàng chọn vật tư "Cá linh tươi", số lượng 500, đơn giá 60.000 (thành tiền tự tính 30.000.000) → **Lưu và in** → đóng bản in → mở lại **Giá nguyên liệu** | Lô cá mới được cấp mã lô và mã hóa tự động; ở Giá nguyên liệu lô mới hiện +15,4% chữ đỏ so với lô 52.000 | "Nhập xong là có giá lô, có cảnh báo, in phiếu ngay — không có bước tính giá cuối tháng." |
| 8 | 1 phút | — | — | — | Tóm tắt: giá vốn theo lô, giải thích được, tính lại ngay. Nêu rõ phần demo **chưa có** (mục 4) và hẹn ngày trả lời câu hỏi (mục 1) |

Nếu khách hỏi về sửa chứng từ: mở **Nhật ký sửa đổi** — mọi lần sửa, hủy đều ghi lý do và người làm; sửa là hủy chứng từ cũ và lập chứng từ mới.

## 4. Những điều phải nói rõ, không để khách hiểu sai

| Khách có thể nghĩ | Nói rõ |
|---|---|
| Demo đã đủ phần mềm | Demo chỉ minh họa giá vốn theo lô và kho theo lô + vị trí. Chưa có: đơn hàng và lập phiếu xuất từ đơn, đề nghị thanh toán, khế ước vay, TSCĐ, CCDC, trả lại / giảm giá hàng mua, phiếu kiểm QC theo chỉ tiêu, bảng cân đối kế toán, lưu chuyển tiền tệ, quy trình cá bạc má và dưa gang chay ([YEU-CAU-KHACH-HANG](../docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) §11) |
| Phần mềm không khóa sổ | Demo bỏ khóa sổ để dễ xem ([QD-09](../docs/02-ke-hoach/QUYET-DINH.md#qd-09)). Phần mềm thật **có khóa kỳ** theo tháng — kế toán trưởng bấm một lần, hệ thống tự kiểm rồi khóa ([QD-10](../docs/02-ke-hoach/QUYET-DINH.md#qd-10)) |
| Cách chia nhân công, sản xuất chung là cố định | Đang là giả định của demo; sẽ theo cách nhà máy chọn (CH-10) |
| Mã lô, mã hóa đã chốt | Đang là đề xuất; cần nhà máy xác nhận (CH-45, CH-46) |
| Số liệu là của nhà máy | Dữ liệu mẫu, đơn giá và tỷ lệ hao hụt là giả định |

## 5. Xử lý sự cố khi trình diễn

| Sự cố | Cách xử lý |
|---|---|
| Số liệu khác kịch bản | Bấm **Đặt lại dữ liệu mẫu**; kiểm Chế độ và Giá xuất trên thanh trên |
| Chữ tiếng Việt lỗi khi mở file gửi qua Zalo / email | Mở bằng Chrome, không mở bằng trình xem trong ứng dụng chat; hoặc dùng link xem trực tuyến / máy chủ demo ([README](../README.md)) |
| Bảng bị tràn trên màn hình nhỏ | Cuộn ngang trong vùng bảng; hoặc thu nhỏ trình duyệt |
| Hộp in không hiện | Cho phép cửa sổ bật lên; chọn máy in "Lưu thành PDF" |
