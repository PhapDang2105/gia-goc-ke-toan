# Nhật ký thay đổi demo

> Phiên bản tài liệu: 1.0 · Ngày: 2026-10-07 · Người phụ trách: Người làm demo · Trạng thái: Đã duyệt (ghi nhận theo từng bản)
> Tệp demo: `gia-goc-demo.html` — một file HTML, JavaScript thuần, dữ liệu mẫu kỳ 01/2026, lưu trong trình duyệt. Bản mới nhất ở trên cùng. Gộp từ `CHANGELOG-v3.md` và `CHANGELOG-v2.md` (đã xóa; nội dung đầy đủ xem lịch sử git trước commit gộp). Bản ghi mới thêm vào đây, không tạo file nhật ký mới.
> Viết tắt: theo [THUAT-NGU](../docs/00-tong-quan/THUAT-NGU.md) §2. Cách trình diễn: [HUONG-DAN-DEMO.md](HUONG-DAN-DEMO.md). Truy vết yêu cầu → demo: [YEU-CAU-KHACH-HANG](../docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) §11.

## Số chính hiện hành (v4.0, dữ liệu mẫu)

Thông tư 99, thực tế đích danh, 800 giờ máy. Dữ liệu mẫu, không phải số của khách.

| Chỉ tiêu | Giá trị |
|---|---|
| Doanh thu thuần | 266.790.000 |
| Giá vốn hàng bán | 183.496.965 |
| Lãi gộp / biên | 83.293.035 / 31,22% |
| Lợi nhuận trước thuế | 83.371.035 |
| Hàng tồn kho cuối kỳ | 262.575.035 |
| Dở dang 154 (lệnh LSX-2512-05) | 19.529.099 |
| Lô cá linh 050126-01 / 120126-01 | 45.000 / 52.000 đ/kg (+15,6%) |
| Lô bán thành phẩm 180126-01 / 240126-01 | 72.825,15 / 82.530,79 đ/kg |
| Lô mắm cá linh hũ 500g 270126-01 / 290126-01 | 43.457,56 / 48.788,92 đ/hũ |
| Lô mắm tôm hũ 250g 270126-02 | 40.482,89 đ/hũ (hỏng ngoài định mức 793.301 vào 632) |

Nếu người làm demo đổi dữ liệu mẫu, cập nhật bảng này và kịch bản [HUONG-DAN-DEMO.md](HUONG-DAN-DEMO.md).

## Lệch so với tài liệu (việc cần sửa ở demo)

| # | Demo v4.0 đang làm | Tài liệu yêu cầu | Nguồn |
|---|---|---|---|
| 1 | Mã lô kiểm trùng **toàn nhà máy** | Duy nhất theo (công ty, mặt hàng) | [QD-14](../docs/02-ke-hoach/QUYET-DINH.md#qd-14), [THUAT-NGU](../docs/00-tong-quan/THUAT-NGU.md) §4.1 |
| 2 | Chưa có đơn hàng; phiếu xuất in SL yêu cầu = SL thực xuất | Lập phiếu xuất từ đơn; SL yêu cầu và SL thực xuất nhập riêng | KHO-12 |
| 3 | Chuyển kho một bước | Hai bước: xuất – xác nhận nhận | [QD-28](../docs/02-ke-hoach/QUYET-DINH.md#qd-28), KHO-04 |
| 4 | Phiếu nhập kho ký: Người lập phiếu · Người giao hàng · Thủ kho · Kế toán; phiếu xuất kho thêm ô Người lập phiếu | Mẫu khách — nhập: Người lập phiếu · Thủ kho · Kế toán · Người nhận; xuất: Người nhận hàng · Bảo vệ · Tài xế · Thủ kho | [YEU-CAU-KHACH-HANG](../docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) §9.10 |
| 5 | Phiếu xuất in chưa có tên hàng cũ / mới, mã đơn hàng | Có cả hai tên, mã đơn hàng, thông tin giao hàng | KHO-09, KHO-11 |
| 6 | Hàng bán trả lại ghi giảm thẳng 511 | 5212 (TT99, chưa xác minh cấp 2) | BAN-03, XM-01 |
| 7 | Quy trình chỉ có cá linh (2 giai đoạn) và mắm tôm (1 giai đoạn) | 4 quy trình theo [YEU-CAU-KHACH-HANG](../docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) §4 | GT-01 |
| 8 | Tiêu thức phân bổ nhân công / sản xuất chung = chi phí nguyên vật liệu trực tiếp của lệnh; lệnh hoàn thành khi có phiếu nhập kho đầu tiên | Tiêu thức cấu hình theo giai đoạn (đề xuất khối lượng × số ngày cho công đoạn ủ); trạng thái lệnh có Hoàn thành → Đóng | [QD-29](../docs/02-ke-hoach/QUYET-DINH.md#qd-29) — cố ý giản lược, chỉ cần nói rõ khi trình diễn |

## v4.7 — quay lại sơ đồ nghiệp vụ (2026-10-07)

- Bấm một ô trên **Sơ đồ nghiệp vụ** → trang đích có thanh xanh ngay dưới tiêu đề: nút **Quay lại sơ đồ nghiệp vụ** + "Đang xem Bước n · tên bước".
- Quay về sơ đồ, ô vừa xem được viền đậm để biết đang ở bước nào.
- Đã bấm thử cả 14 ô ở 1366px và 390px: ô nào cũng mở đúng trang và quay về đúng sơ đồ.

## v4.6 — nút quay lại (2026-10-07)

- Thanh trên cùng có nút **← <tên trang trước>** (điện thoại chỉ hiện mũi tên). Bấm là về đúng trang trước, giữ nguyên bộ lọc, thẻ đang chọn, lô đang xem và vị trí cuộn. Quay lui được nhiều bước (tối đa 30).
- Nút Back của trình duyệt / vuốt lùi trên điện thoại cũng quay về trang trước thay vì thoát khỏi phần mềm.

## v4.5 — sơ đồ nghiệp vụ (2026-10-07)

- Trang **Sơ đồ nghiệp vụ** (menu Tổng hợp): quy trình từ mua hàng đến lãi lỗ, 8 bước, 6 làn theo bộ phận (Kế hoạch, Kho, Kiểm tra chất lượng, Sản xuất, Bán hàng, Kế toán) kèm tên người phụ trách theo tài liệu HỆ THỐNG.
- Mỗi bước ghi: việc, số chứng từ thật trong kỳ (8 phiếu nhập mua, 10 phiếu xuất kho, 5 lô thành phẩm…), người làm, bút toán (Nợ / Có). Mũi tên nét đứt: bán thành phẩm quay lại xuất cho giai đoạn sau.
- Bấm một bước mở trang tương ứng (phiếu xuất kho → Chứng từ lọc phiếu xuất; sản xuất → Giá thành theo lệnh; thanh toán nhà cung cấp → Báo cáo công nợ phải trả…).
- Vừa một màn hình 1366px; điện thoại cuộn ngang trong khung, cột làn đứng yên.

## v4.4 — truy xuất lô, giả lập giá nguyên liệu, tem lô có mã QR (2026-10-07)

- **Truy xuất lô** (menu Sản xuất): chọn lô bất kỳ. Sơ đồ nhánh hai chiều: bên trái nguồn gốc (nhà cung cấp → lô nguyên liệu → lệnh sản xuất → lô bán thành phẩm…), bên phải nơi đi (lệnh dùng lô → lô sinh ra → khách hàng). Bấm ô lô trên sơ đồ để chuyển sang lô đó. 4 ô số: lô liên quan phía sau, số khách đã nhận, đã bán, còn trong kho. Bảng khách đã nhận (bấm số hóa đơn mở chứng từ) và tồn trong kho theo kho, vị trí, thủ kho, QC.
- **Khóa các lô còn tồn**: một bước chuyển QC sang "Chờ" cho mọi lô liên quan còn tồn (cần lý do ≥ 5 ký tự, ghi nhật ký). Lô Chờ bị chặn xuất bán.
- **Giả lập giá nguyên liệu** (menu Sản xuất): thanh trượt −30% … +50% cho từng vật tư đang có giá. Tính lại ngay giá vốn hàng bán, lãi gộp, biên lãi gộp, tồn kho cuối kỳ; bảng theo sản phẩm: giá thành hiện tại / giả lập, chênh lệch, biên lãi theo giá bán, giá bán để giữ biên. Không ghi sổ.
- **Tem lô có mã QR**: tem 2 cột trên A4 (tên hàng, mã lô chữ lớn, mã hóa, kho, vị trí, ngày, hạn dùng, số lượng, QC và người QC, mã QR). In từ: Kho & lô → "In tem các lô" (theo bộ lọc đang xem) hoặc nút "Tem" từng dòng; Truy xuất lô → "In tem lô" / "In tem". Mã QR mở địa chỉ `…#lo=<mã lô>` → vào thẳng trang truy xuất của lô. Thư viện tạo mã QR qrcode-generator 1.4.4 (MIT) nhúng trong file, chạy không cần mạng.
- Giá vốn theo lô: thêm nút "Truy xuất lô" ở đầu cây cấu thành.
- Kiểm tra: bấm thử 1366px và 390px, nền sáng và tối, không lỗi, không cuộn ngang; khóa lô, in tem, kéo thanh giả lập, mở liên kết `#lo=`; tự kiểm tra 480 trường hợp, 0 sai.

## v4.3 — giảm tải các trang dày (2026-10-07)

Rà 10 trang (đo số khối, bảng, cột, chiều cao trang ở 1366px). Sửa 4 trang quá tải:

- **Danh mục & lệnh sản xuất**: 4 bảng xếp chồng (cao 1.815px) → 4 thẻ chọn Vật tư / Lệnh sản xuất / Vị trí chứa / Nhân sự, mỗi lần một bảng (cao 440–860px). Bỏ cột Thuế GTGT khỏi bảng vật tư (vẫn sửa trong biểu mẫu); cột QC chỉ ghi tên người, rê chuột thấy khu.
- **Giá vốn theo lô**: trong nhánh bán thành phẩm, 5 dòng nhân công / sản xuất chung gộp thành 1 dòng "Nhân công và sản xuất chung" kèm số lệnh; bỏ chữ "Tiêu thức nguyên vật liệu trực tiếp" lặp 10 lần; bỏ dòng giải thích làm tròn. Cây vẫn đi tới lô nguyên liệu, nhà cung cấp, đơn giá.
- **Giá thành theo lệnh sản xuất**: bảng phân bổ 11 cột ẩn mặc định, bấm "Xem bảng phân bổ" để mở; cột sản phẩm rộng hơn, không vỡ 4 dòng; bỏ dòng công thức dưới thẻ tính giá thành. Trang từ 1.509px còn 933px.
- **Tổng quan**: khối "Đối chiếu kho với sổ cái" chỉ hiện khi có lệch (khi khớp đã có dòng "Kho – sổ cái" trong Việc cần làm); cơ cấu giá thành dàn hết chiều ngang.
- Các trang còn lại (Chứng từ, Báo cáo, Kho & lô, Giá nguyên liệu, Giá xuất kho, Nhật ký) giữ nguyên: mỗi trang 1–3 khối, đúng một việc.
- Kiểm tra: bấm thử 1366px và 390px, không lỗi, không cuộn ngang; tự kiểm tra 480 trường hợp, 0 sai.

## v4.2 — kho và người phụ trách, ô tổng quan nổi bật (2026-10-07)

- Trang **Kho & lô** có bảng "Kho và người phụ trách" ở đầu trang: 3 kho, tên thủ kho (Mr Phú – Nhà máy Bà Ba Thạo, Ms Trâm – Kho Bình Tây, Mr Hải – Cửa hàng 97 Nguyễn Thái Học), kế toán kho Ms Huyền, số lô đang tồn, giá trị tồn, nút "Xem tồn" lọc theo kho.
- Trang **Danh mục** thay bảng kho bằng bảng **Nhân sự vận hành** đủ 16 người theo tài liệu HỆ THỐNG (tải được ra Excel).
- QC phụ trách hiển thị kèm tên: khu thủy sản Ms Hằng, nông sản Ms Huỳnh, đóng gói Ms Tú, hàng xay Ms Trâm, trưởng QC Ms Lan (danh mục vật tư, phiếu nhập thành phẩm, cập nhật QC lô).
- Phiếu in ghi sẵn tên dưới chữ ký: thủ kho theo kho của phiếu, kế toán kho Ms Huyền, kế toán trưởng Ms Nhung (phiếu thu/chi); dòng "Kho nhập/Kho xuất" kèm tên thủ kho.
- Ô tổng quan (chỉ số) có nền xanh nhạt, viền trái màu nhấn, số màu xanh đậm để nổi bật; có bản nền tối.
- Kiểm tra: bấm thử trên giao diện ở 1366px và 390px, nền sáng và tối, không lỗi, không cuộn ngang; tự kiểm tra 480 trường hợp, 0 sai.

## Sau v4.0 — tiêu đề trang

- Tiêu đề thẻ trình duyệt đổi từ "Giá Gốc · Mắm" thành "Hệ thống quản lý" (commit 7e45cbf). Chữ "Giá Gốc" trên thanh bên giữ nguyên. Tên sản phẩm chưa chốt: [CH-56](../docs/01-yeu-cau/CAU-HOI-MO.md#ch-56).

## v4.0 — giá vốn theo lô, giá thành theo lệnh sản xuất, bỏ khóa sổ (2026-10-07)

Theo [QD-07](../docs/02-ke-hoach/QUYET-DINH.md#qd-07), [QD-05](../docs/02-ke-hoach/QUYET-DINH.md#qd-05), [QD-09](../docs/02-ke-hoach/QUYET-DINH.md#qd-09) và [PHAN-BIEN-v3](../docs/05-phan-bien/PHAN-BIEN-v3.md). Khóa lưu trữ `giagoc-demo-v40`.

- **Bỏ khóa sổ**: bỏ trang, menu, 12 bước, khóa / mở khóa kỳ, giá tạm / đã chốt / cần tính lại, bù trừ thuế (TH0001), kết chuyển 911 (KQ0001). Báo cáo kết quả kinh doanh lấy thẳng từ số dư tài khoản loại 5–8. KC0001 giữ là chứng từ hệ thống luôn cập nhật (kết chuyển 621/622/627 sang 154 theo lệnh, Thông tư 99). Tồn âm bị chặn ngay khi lưu, sửa, hủy.
- **Giá thành theo lệnh sản xuất**: mỗi lệnh là đối tượng tập hợp chi phí; trạng thái Mới / Đang sản xuất / Hoàn thành; lệnh chưa nhập kho thì toàn bộ chi phí là dở dang; chặn phiếu xuất cho lệnh sau ngày nhập kho đầu tiên và phiếu nhập kho trước phiếu xuất cuối. Giản lược: [QD-29](../docs/02-ke-hoach/QUYET-DINH.md#qd-29). Dữ liệu mẫu 6 lệnh, gồm LSX-2512-05 ủ nhiều kỳ (dở dang đầu kỳ 18.000.000).
- **Trang mới**: Giá nguyên liệu (bảng lô, so với lô trước: trên 5% chữ cam, trên 10% chữ đỏ; lịch sử giá dạng biểu đồ / bảng; "Đã dùng cho" truy xuôi); Giá vốn theo lô (thay Truy xuất theo lô; cây cấu thành tới lô cá và nhà cung cấp, cuối cây là hóa đơn bán); Giá thành theo lệnh sản xuất (bảng lệnh, bảng phân bổ, thẻ giá thành). Tổng quan thêm "Giá vốn hàng bán theo sản phẩm".
- **In phiếu** ([QD-31](../docs/02-ke-hoach/QUYET-DINH.md#qd-31)): phiếu nhập kho, phiếu xuất kho, phiếu xuất kho kiêm vận chuyển nội bộ, biên bản kiểm kê kho, phiếu thu, phiếu chi; có đơn giá, thành tiền, tiền bằng chữ. Nút "Lưu và in" trong form; biểu tượng in và ô chọn đầu mỗi dòng chứng từ; lọc nhanh Phiếu nhập kho / Phiếu xuất kho; "In các phiếu đã chọn" (mỗi phiếu một trang). Chỉ ghi "Nhà máy chế biến mắm".
- **Sửa lỗi phản biện vòng 3**: L2, L3, L4, L6, L7, L9, L10; U2, U3, U5–U14, U16 (chi tiết ở [PHAN-BIEN-v3](../docs/05-phan-bien/PHAN-BIEN-v3.md) §5).
- **Chữ trên giao diện**: bỏ mã mẫu sổ trong tiêu đề màn hình; viết đầy đủ, không viết tắt ([QD-11](../docs/02-ke-hoach/QUYET-DINH.md#qd-11)).
- **Đã kiểm tra** (Playwright, Chromium): `__giagoc.selfTest()` 384 tổ hợp, 0 lỗi (2 chế độ × 4 phương pháp × 2 mức giờ máy × 24 biến thể; bất biến Nợ = Có, kho = sổ cái, tổng cây cấu thành = giá trị lô, giá vốn theo lô + ngoài lô = 632…); tính tay độc lập lô 180126-01 = 128.172.272 trùng engine; 1366×768 và 390×844, sáng và tối, 41 bước thao tác mỗi khung, in phiếu.

## v3.4 — biểu đồ

Thiết kế lại biểu đồ (doanh thu – lãi gộp 6 tháng kèm biên lãi gộp, cơ cấu giá thành đơn vị, thanh tiến độ); bảng màu 4 ô kiểm bằng công cụ kiểm bảng màu, có chế độ tối riêng; nút Biểu đồ / Bảng; tooltip bằng chuột, chạm, bàn phím. Không đổi engine và số liệu. `selfTest()` 1.216 tổ hợp, 0 lỗi.

## v3.3 — giao diện phẳng

Bỏ nhãn màu dạng viên thuốc, con dấu; trạng thái là chữ thường (cam cảnh báo, đỏ lỗi, xám đã hủy). Một màu nhấn xanh dương trầm; bỏ tím, pastel, gradient. Bo góc ≤ 2px cho mọi phần tử; font hệ thống. Không đổi engine. `selfTest()` 1.216 tổ hợp, 0 lỗi.

## v3.2 — vị trí chứa và mã hóa (theo file kho của nhà máy)

Theo [QD-12](../docs/02-ke-hoach/QUYET-DINH.md#qd-12), [QD-13](../docs/02-ke-hoach/QUYET-DINH.md#qd-13).
- Vị trí chứa (bồn / trái / phuy, 31 vị trí mẫu ở nhà máy), kiểm âm theo (kho, lô, vị trí), giá trị vẫn theo lô; chuyển vị trí trong cùng kho bằng phiếu chuyển kho.
- Mã lô `DDMMYY-nn` (kiểm trùng toàn nhà máy — xem "Lệch so với tài liệu" mục 1); mã hóa tự sinh `NHÓM-YYMM-nnnn`; số phiếu kho `PNK-YYMMnnn` / `PXK-YYMMnnn`; mã MISA, tồn tối thiểu, "Cần đặt thêm".
- Bảng Tồn kho chi tiết; báo cáo N-X-T theo lô và vị trí, sổ chi tiết mặt hàng theo lô và vị trí; kiểm kê theo lô và vị trí có % chênh lệch.
- `selfTest()` 1.216 tổ hợp, 0 lỗi; DDL vị trí chứa ([DIEU-CHINH-THEO-KHACH-HANG](../docs/03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §2.8) chạy trên PostgreSQL 16, 8 phép thử đạt.

## v3.1 — giao diện gọn

Bỏ toàn bộ chữ giải thích (đoạn mở đầu, thanh "Kịch bản demo", chú giải thuật ngữ, ghi chú tĩnh); tour chỉ mở bằng nút "?". Bố cục co giãn, thanh bên thu gọn được, bảng có tiêu đề dính khi cuộn. `selfTest()` 960 tổ hợp, 0 lỗi.

## v3.0 — chuyển sang nhà máy chế biến mắm

Chuyển dữ liệu mẫu từ xưởng bàn ghế gỗ sang nhà máy chế biến mắm theo `HỆ THỐNG.docx`: 3 kho, lô (mã lót), giá thực tế đích danh (mặc định), giá thành 2 giai đoạn có bán thành phẩm, hỏng trong / ngoài định mức, QC lô, ngoại tệ USD (515/635), lệnh sản xuất, trang Báo cáo (sổ nhật ký chung, sổ cái, cân đối số phát sinh, kết quả kinh doanh, công nợ, sổ quỹ / tiền gửi, tiến độ sản xuất, xuất kho theo lệnh). Luật làm tròn R1 (`allocate()`). Sửa lỗi B1–B5 của bản v2. `selfTest()` 960 tổ hợp, 0 lỗi.

## v2.1 — tour hướng dẫn, thêm vật tư mới (xưởng gỗ)

Tour 10 bước; form thêm vật tư (nguyên vật liệu, hàng hóa, sản phẩm có định mức 1 cấp); form nhập kho sản phẩm hoàn thành; điền phiếu xuất theo định mức; sửa / xóa vật tư có ghi nhật ký. `selfTest()` 864 tổ hợp, 0 lỗi.

## v2.0 — engine tính từ chứng từ (xưởng gỗ)

Dữ liệu mẫu và chứng từ trong trình duyệt; số liệu tính từ chứng từ; bình quân cuối kỳ, bình quân tức thời, FIFO; khóa sổ nhiều bước; form phiếu nhập, xuất, hóa đơn, hàng bán trả lại, kiểm kê, lương, khấu hao, chi phí; sửa = hủy + lập lại có lý do; nhật ký sửa đổi; xem trước bút toán Thông tư 99 / 133. Phản biện của bản này lưu ở [docs/05-phan-bien/luu-tru](../docs/05-phan-bien/luu-tru/).
