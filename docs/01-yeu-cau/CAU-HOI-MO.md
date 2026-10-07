# Câu hỏi mở và việc cần xác minh

> Phiên bản: 1.0 · Ngày: 2026-10-07 · Người phụ trách: BA dự án · Trạng thái: Chờ duyệt (gửi khách cùng [YEU-CAU-KHACH-HANG](YEU-CAU-KHACH-HANG.md))
> Nguồn duy nhất cho mọi câu hỏi đang chờ trả lời. Tài liệu khác chỉ trích mã `CH-nn` / `XM-nn`. Câu hỏi được gom từ: yêu cầu khách hàng v1.2 (§1.3, §3, §5.2, §7, §8, §9.7), kế hoạch v0.4 (§6, §7), [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) Phụ lục B, [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §12, [NGHIEP-VU-KE-TOAN](../03-thiet-ke/NGHIEP-VU-KE-TOAN.md) §9, [PHAN-BIEN-v3](../05-phan-bien/PHAN-BIEN-v3.md) §3, giả định của [demo](../../demo/CHANGELOG.md).
> Viết tắt: theo [THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §2.

## 1. Cách đọc

- **Mã**: `CH-nn` câu hỏi cho người (khách hoặc người dùng); `XM-nn` việc đội dự án tự xác minh văn bản pháp lý. Mã không đổi, không cấp lại.
- **Nhóm theo người trả lời**: §2 BOD, §3 KTT, §4 thủ kho – kế toán kho – kinh doanh, §5 QC, §6 người dùng (chủ dự án), §7 đội dự án.
- **Chặn** (việc không làm tiếp được khi chưa có câu trả lời), theo thứ tự gấp:
  - **Kho + QC**: chặn mốc phát hành sớm "Kho + QC" của đợt 1A.
  - **1A thiết kế**: chặn thiết kế chi tiết, migration và phần kho/mua/bán của 1A.
  - **1A giá thành**: chặn golden test giá thành theo lệnh, giá vốn theo lô (hạng mục 10–11 của 1A).
  - **1B**, **1C**: chặn đợt tương ứng.
  - **Không chặn**: đã có mặc định để làm tiếp; câu trả lời có thể đổi cấu hình.
- **Mặc định khi chưa trả lời**: điều đội dự án đang làm theo. Không phải câu trả lời của khách.
- **Trạng thái**: Mở · Đã trả lời (ghi ngày, người trả lời, chuyển sang §9) · Bỏ.

Ưu tiên gửi trước (chặn sớm nhất): CH-05, CH-06, CH-01, CH-31, CH-44, CH-46, CH-45, CH-35, CH-47, CH-10.

## 2. Ban giám đốc (BOD)

| Mã | Câu hỏi | Ảnh hưởng | Chặn | Mặc định khi chưa trả lời | Trạng thái |
|---|---|---|---|---|---|
| <a id="ch-01"></a>CH-01 | Ngày muốn dùng thật; chạy song song MISA bao lâu? | Kế hoạch chuyển đổi, mốc tiến độ, số dư đầu kỳ | 1A thiết kế | Bắt đầu dùng thật từ đầu năm tài chính (xem CH-06) | Mở |
| <a id="ch-02"></a>CH-02 | Luồng duyệt đề nghị thanh toán, đơn mua, đơn bán vượt hạn mức: mấy cấp, ai duyệt, hạn mức tiền bao nhiêu? | TIEN-01, NEN-04, BAN-01 | 1B | Tối đa 2 cấp theo ngưỡng tiền: KTT, rồi BOD khi vượt ngưỡng | Mở |
| <a id="ch-03"></a>CH-03 | Hai "Ms Trâm" (thủ kho Bình Tây và QC khu hàng xay) là một hay hai người? | Tài khoản, phân quyền | 1A thiết kế | Hai tài khoản | Mở |
| <a id="ch-04"></a>CH-04 | Ai đặt hàng mua (lập đơn mua) và ai nhận hóa đơn mua? | Phân quyền phân hệ Mua | 1A thiết kế | Kế hoạch lập đề xuất mua, kế toán kho lập chứng từ mua | Mở |

## 3. Kế toán trưởng (KTT)

| Mã | Câu hỏi | Ảnh hưởng | Chặn | Mặc định khi chưa trả lời | Trạng thái |
|---|---|---|---|---|---|
| <a id="ch-05"></a>CH-05 | Năm 2026 công ty áp dụng **TT99 hay TT133**? | 621/622/627 hay 154; 521 hay 511; 641/642 hay 6421/6422; mẫu BCTC; golden test | 1A thiết kế | Thiết kế và golden test theo TT99 ([QD-16](../02-ke-hoach/QUYET-DINH.md#qd-16)) | Mở |
| <a id="ch-06"></a>CH-06 | Ngày dùng thật có phải đầu năm tài chính không? Nếu giữa năm: MISA đang tính giá xuất bằng phương pháp nào (đổi sang đích danh giữa năm?), có đổi TT133 ↔ TT99 giữa năm không? | Ngày chuyển đổi, số dư đầu theo lô, thuyết minh thay đổi chính sách kế toán | 1A thiết kế | Đề xuất bắt đầu từ đầu năm tài chính. Mặt pháp lý: XM-12 | Mở |
| <a id="ch-07"></a>CH-07 | Đang dùng MISA bản nào; tồn kho trong MISA có theo lô không; cần chuyển dữ liệu mấy năm? | Chuyển đổi dữ liệu, tồn đầu theo lô | 1A thiết kế | Tồn đầu theo lô lập bằng kiểm kê tại ngày chuyển đổi (lô tồn đầu); giá trị = giá trị MISA chia theo SL theo R1(b), KTT duyệt | Mở |
| <a id="ch-08"></a>CH-08 | Có địa điểm nào là chi nhánh có MST hoặc hạch toán riêng không? | Mô hình công ty / chi nhánh, sổ | 1A thiết kế | Một công ty, một sổ | Mở |
| <a id="ch-09"></a>CH-09 | Ngoại tệ: đồng tiền nào; nghiệp vụ nào (nhập khẩu, xuất khẩu, tài khoản ngân hàng, vay); tỷ giá ngân hàng nào; đánh giá lại **hằng tháng hay chỉ cuối năm**; có đảo đầu kỳ sau không? | NT-01..NT-05 | 1B | USD, ít nghiệp vụ, tỷ giá nhập tay | Mở |
| <a id="ch-10"></a>CH-10 | Nhân công trả lương theo thời gian hay sản phẩm; có chấm công theo lệnh/khu không; **tiêu thức phân bổ nhân công và sản xuất chung** cho lệnh sản xuất? | GT-02, GT-03 | 1A giá thành | Thiết kế: sản xuất chung theo khối lượng × số ngày lệnh mở trong kỳ cho công đoạn ủ ([DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §4.3). Demo v4.0 dùng tiêu thức đơn giản hơn: chi phí nguyên vật liệu trực tiếp của lệnh ([QD-29](../02-ke-hoach/QUYET-DINH.md#qd-29)) | Mở |
| <a id="ch-11"></a>CH-11 | Bán thành phẩm có nhập kho thật, có bán ra ngoài không? Bán thành phẩm nhập kho ghi **155 hay giữ 154**? Xuất bán thành phẩm cho giai đoạn sau qua 621 hay thẳng 154? | GT-05, định khoản | 1A giá thành | Demo ghi 155 và xuất thẳng Nợ 154; sản phẩm cấu hình bằng account role | Mở |
| <a id="ch-12"></a>CH-12 | Hàng không đạt **ngoài định mức** hạch toán vào đâu: 632, 811 hay 1388 (bắt bồi thường)? Ai quyết định? | GT-06, QC-06 | 1A giá thành | 632 | Mở |
| <a id="ch-13"></a>CH-13 | Phế liệu (đầu cá, nước muối…) có thu hồi, bán không? | Giảm giá thành lệnh | 1A giá thành | Thiết kế có trường phế liệu thu hồi; demo không có phế liệu | Mở |
| <a id="ch-14"></a>CH-14 | Có tách sản xuất chung cố định dưới công suất bình thường sang giá vốn không (VAS 02)? Công suất bình thường từng xưởng? | GT-08 | Không chặn | Tắt (demo có bật để minh họa) | Mở |
| <a id="ch-15"></a>CH-15 | Ngưỡng % chênh lệch giá lô nguyên vật liệu so với lô trước / giá đơn mua để cảnh báo, theo nhóm hàng? | GT-09, GT-R4 | Không chặn | Một ngưỡng cho mọi nhóm; demo: trên 5% chữ cam, trên 10% chữ đỏ | Mở |
| <a id="ch-16"></a>CH-16 | Có nhóm hàng nào (bao bì, phụ gia) muốn tính giá bình quân thay vì đích danh theo lô không? | Engine giá, khối lượng nhập liệu; mặt pháp lý XM-08 | 1A thiết kế | Mọi hàng tồn kho đích danh theo lô, hệ thống tự gợi ý lô | Mở |
| <a id="ch-17"></a>CH-17 | Trả lại hàng mua khi lô đã được cộng chi phí mua phân bổ: phần chênh lệch (chi phí mua của SL trả) ghi 632 hay 811? | MUA-03 | Không chặn | Chưa có (demo chưa có nghiệp vụ trả lại hàng mua) | Mở |
| <a id="ch-18"></a>CH-18 | Giảm giá hàng mua / chi phí mua đến muộn cho lô đã dùng một phần: phần lô còn tồn giảm giá trị lô; phần đã vào lệnh chưa tính giá vào chi phí lệnh; phần đã bán hoặc thuộc kỳ đã khóa vào 632; **không** lan xuống lô bán thành phẩm/thành phẩm đã tính giá. Chấp nhận không? | MUA-04, giá vốn theo lô | 1A giá thành | Như câu hỏi | Mở |
| <a id="ch-19"></a>CH-19 | Phiếu xuất lô chưa có giá (lệnh tạo lô chưa hoàn thành): chặn hay cho xuất với giá tạm? | GT-07 | 1A giá thành | Chặn | Mở |
| <a id="ch-20"></a>CH-20 | Có cho xuất âm kho không? | KHO-02 | 1A thiết kế | Cấm (đích danh theo lô không định giá được tồn âm) | Mở |
| <a id="ch-21"></a>CH-21 | Sửa chứng từ đã ghi sổ: cho "bỏ ghi" như MISA hay bắt buộc chứng từ đảo / hủy có lý do rồi lập lại? | Nhật ký sửa đổi, quy trình sửa | Không chặn | Chứng từ đã ghi sổ không sửa trực tiếp; sửa = hủy có lý do + lập chứng từ mới ([KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §7.1) | Mở |
| <a id="ch-22"></a>CH-22 | Kiểm kê: chênh lệch bao nhiêu % thì phải giải trình; ai duyệt giải trình; chênh lệch trong định mức → 632, ngoài định mức → bắt bồi thường? | KHO-05, KHO-13 | Kho + QC | Giải trình bắt buộc khi vượt một ngưỡng % cấu hình | Mở |
| <a id="ch-23"></a>CH-23 | "Tổng hợp mua hàng theo … hạn mức thanh toán" nghĩa là gì? Báo cáo "trả lại hàng mua / giảm giá hàng bán" trong phân hệ Mua có phải là **giảm giá hàng mua** không? | MUA-R3, MUA-R4 | 1A thiết kế | Hạn mức công nợ nhà cung cấp cấp cho công ty; giảm giá hàng mua | Mở |
| <a id="ch-24"></a>CH-24 | TSCĐ/CCDC: số lượng tài sản; khấu hao theo ngày hay tháng; ngưỡng phân biệt TSCĐ/CCDC; điều chuyển giữa tháng tính thế nào? | TSCD-03..05 | 1C | Đường thẳng; theo ngày hay theo tháng chưa chốt | Mở |
| <a id="ch-25"></a>CH-25 | Khế ước vay: số khế ước; lãi suất cố định hay thả nổi; cơ sở 365 hay 360 ngày; có trích lãi dồn tích hằng tháng không? | NH-03 | 1C | Trích lãi dồn tích cuối tháng | Mở |
| <a id="ch-26"></a>CH-26 | Báo cáo lưu chuyển tiền tệ nộp theo phương pháp nào; có cần cả hai để quản trị? | BC-R4 | 1C | Làm cả hai | Mở |
| <a id="ch-27"></a>CH-27 | Có lập thuyết minh BCTC năm từ hệ thống không? | BC-R5 | 1C | Khung + nhập tay | Mở |
| <a id="ch-28"></a>CH-28 | Nhà cung cấp HĐĐT hiện tại; có cần tích hợp phát hành HĐĐT ngay giai đoạn 1 không (tài liệu khách không yêu cầu)? | Phạm vi | Không chặn | Không tích hợp HĐĐT ở giai đoạn 1; chỉ lưu số hóa đơn | Mở |
| <a id="ch-29"></a>CH-29 | Có cần sổ quản trị song song sổ tài chính ngay giai đoạn 1 không? | Mô hình sổ | Không chặn | Một sổ tài chính | Mở |

## 4. Thủ kho, kế toán kho, kinh doanh

| Mã | Người trả lời | Câu hỏi | Ảnh hưởng | Chặn | Mặc định khi chưa trả lời | Trạng thái |
|---|---|---|---|---|---|---|
| <a id="ch-30"></a>CH-30 | Kế toán kho, thủ kho nhà máy | Mỗi địa điểm là một kho hay nhiều kho con (nguyên vật liệu, bao bì, phụ gia, thành phẩm, khu bán thành phẩm đang ủ)? Kho Bình Tây chứa hàng gì? | Danh mục kho, phân quyền, chuyển kho | Kho + QC | Một kho mỗi địa điểm | Mở |
| <a id="ch-31"></a>CH-31 | Thủ kho nhà máy, trưởng QC | **Một bồn / trái / phuy có chứa cùng lúc nhiều lô không; có châm thêm hoặc trộn lô mới vào bồn đang ủ không?** File kho có 3 bồn (`A.54`, `C.48`, `E.2`) từng chứa đồng thời 2 lô | Mô hình lô, tính đúng của đích danh theo lô. Nếu có trộn: thao tác trộn là một lệnh sản xuất sinh **lô gộp** (giá trị = tổng các lô vào) | Kho + QC | Mỗi vị trí một lô tại một thời điểm; cảnh báo khi đưa lô vào vị trí đang có lô khác | Mở |
| <a id="ch-32"></a>CH-32 | Thủ kho nhà máy | Gửi danh mục bồn / trái / phuy đầy đủ theo khu, sức chứa (kg hay lít); ký hiệu không có dấu chấm (`H1`, `MA1`, `TB2`…) là gì? | KHO-06, cảnh báo vượt sức chứa | Kho + QC | Chỉ nhận ký hiệu có dấu chấm | Mở |
| <a id="ch-33"></a>CH-33 | Thủ kho nhà máy | "Trái" là gì (chum, lu?), thể tích bao nhiêu; một trái chứa một lô hay nhiều lô? | KHO-06 | Kho + QC | Như bồn | Mở |
| <a id="ch-34"></a>CH-34 | Thủ kho Bình Tây, 97 Nguyễn Thái Học | Kho Bình Tây và 97 Nguyễn Thái Học có theo dõi theo bồn / kệ không? | Danh mục vị trí | Kho + QC | Không theo vị trí | Mở |
| <a id="ch-35"></a>CH-35 | Kế toán kho | Quy tắc số phiếu kho: `PNK-YYMMnnn` hay `PXK-MMYY-nnn` (file có cả hai); đánh số chung các kho hay riêng từng kho; phiếu chuyển kho dùng PXK hay mẫu riêng? | KHO-10 | Kho + QC | `PNK-YYMMnnn` / `PXK-YYMMnnn`, chung các kho ([THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §4.3) | Mở |
| <a id="ch-36"></a>CH-36 | Thủ kho | "SL thực xuất" khác "SL yêu cầu" khi nào (cân lại? hao hụt khi bơm?); chênh lệch xử lý thế nào? | KHO-02, KHO-12 | Kho + QC | Chọn lý do từ danh sách khi khác | Mở |
| <a id="ch-37"></a>CH-37 | Kế toán kho | Quy tắc ghép tên chốt (thứ tự 13 thuộc tính, khối lượng viết liền đơn vị, "/" trước quy cách, kích thước DxRxC, viết hoa chữ đầu) có đúng không; có bắt buộc khi khai danh mục mới không; gửi danh sách mã MISA hiện có | KHO-09 | Kho + QC | Như [YEU-CAU-KHACH-HANG](YEU-CAU-KHACH-HANG.md) §9.8 | Mở |
| <a id="ch-38"></a>CH-38 | Kế toán kho, kinh doanh | "Tên cũ" là tên trên MISA, trên đơn hàng hay tên gọi cũ của xưởng? Một mặt hàng có nhiều tên cũ không? | KHO-09 | Kho + QC | Cho phép nhiều tên cũ | Mở |
| <a id="ch-39"></a>CH-39 | Kế toán kho | Cột "Số ngày lưu kho" nghĩa là số ngày tối đa được lưu (cảnh báo tồn lâu) hay số ngày đã lưu từ ngày nhập đầu tiên? Tính theo lô hay mặt hàng? | KHO-R7 | Không chặn | Số ngày đã lưu, theo lô | Mở |
| <a id="ch-40"></a>CH-40 | Kinh doanh (sale admin), thủ kho | Sheet `GoiYXuat` lọc dòng đơn hàng theo hai cột nào (đã duyệt? đã xuất?). Gửi sheet đơn hàng. Ngoài đơn bán, có "đơn" cho chuyển kho Bình Tây / 97 không? | KHO-12, BAN-01 | Kho + QC | Lọc dòng đơn còn chưa xuất đủ | Mở |
| <a id="ch-41"></a>CH-41 | Kinh doanh | Trên phiếu xuất in, "Hình thức thanh toán" hiển thị dạng % là gì (tỷ lệ trả trước?) | KHO-11 | Không chặn | In chữ "Công nợ" / "Tiền mặt" | Mở |
| <a id="ch-42"></a>CH-42 | Thủ kho | Mẫu in phiếu xuất của file giới hạn 5 lô cho mỗi mặt hàng — có cần giữ giới hạn này không, hay in đủ mọi lô? | KHO-11 | Không chặn | In đủ mọi lô | Mở |
| <a id="ch-43"></a>CH-43 | Kinh doanh, KTT | Bán lẻ tại 97 Nguyễn Thái Học: có máy tính tiền, có xuất hóa đơn cho từng khách lẻ không? | BAN-02 | 1A thiết kế | Hóa đơn bán lẻ thu tiền ngay (demo: mỗi lần bán một hóa đơn cho khách lẻ) | Mở |

## 5. QC (trưởng QC và QC khu)

| Mã | Câu hỏi | Ảnh hưởng | Chặn | Mặc định khi chưa trả lời | Trạng thái |
|---|---|---|---|---|---|
| <a id="ch-44"></a>CH-44 | Quy tắc mã lót đang dùng (gửi mẫu); đánh mã tại tiếp nhận nguyên vật liệu, đầu mỗi lần ủ, hay chỉ khi đóng gói? Có in mã vạch / QR không? | Mô hình lô, truy xuất | Kho + QC | Mã lô sinh ở 3 nơi: tiếp nhận, bắt đầu giai đoạn có bán thành phẩm nằm chờ, đóng gói ([YEU-CAU-KHACH-HANG](YEU-CAU-KHACH-HANG.md) §4.1 G3); chưa quét mã vạch | Mở |
| <a id="ch-45"></a>CH-45 | **Mã hóa** dùng để làm gì (in bao bì? QC ghi? đối chiếu với lot)? Đồng ý mã tự sinh `NHÓM-YYMM-nnnn` không, hay muốn mã do người ghi? | KHO-07 | Kho + QC | Tự sinh ([THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §4.2) | Mở |
| <a id="ch-46"></a>CH-46 | **Mã lô duy nhất trong từng mặt hàng** (không phải toàn công ty) — đồng ý không? Mã dạng `6232-4`, `6248-03` nghĩa là gì; lô `DDMMYY` không số mẻ còn dùng không? | KHO-03, quy ước mã lô | Kho + QC | Duy nhất theo (công ty, mặt hàng) ([THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §4.1) | Mở |
| <a id="ch-47"></a>CH-47 | Thời gian từng công đoạn ủ (muối, thính, chượp, đường) và bảo ôn / bảo quản; bể ủ có trộn nhiều lô nguyên liệu không; có gộp / tách lô giữa công đoạn không; có rút **một phần** bể (lệnh hoàn thành nhiều lần) không? | Dở dang nhiều kỳ, mô hình lệnh và lô | 1A giá thành | Một lệnh hoàn thành một lần; rút một phần = tách lệnh. Demo v4.0: lệnh hoàn thành khi có phiếu nhập kho đầu tiên ([QD-29](../02-ke-hoach/QUYET-DINH.md#qd-29)) | Mở |
| <a id="ch-48"></a>CH-48 | Định mức nguyên vật liệu, tỷ lệ thu hồi và **tỷ lệ không đạt được chấp nhận** (trong định mức) theo công đoạn / sản phẩm | GT-05, GT-06 | 1A giá thành | Ví dụ trong tài liệu là giả định; demo: 3% bán thành phẩm, 1% mắm cá linh, 2% mắm tôm | Mở |
| <a id="ch-49"></a>CH-49 | Quy trình khu hàng xay (tài liệu khách không có sơ đồ) | Ánh xạ quy trình §4.6 của yêu cầu | 1A giá thành | Chưa ánh xạ | Mở |
| <a id="ch-50"></a>CH-50 | "Phân loại" (mắm cá) có tạo nhiều loại sản phẩm giá trị khác nhau không? Cá linh / sặc / chốt / trèn sản xuất riêng hay chung? | Chia giá thành liên sản phẩm | 1A giá thành | Chưa có (demo chỉ có cá linh) | Mở |
| <a id="ch-51"></a>CH-51 | "Massage bán thành phẩm" là thao tác thường xuyên hay xử lý lại bán thành phẩm chưa đạt? | Công đoạn / làm lại | 1A giá thành | Gộp vào giai đoạn rửa – ủ thính ([YEU-CAU-KHACH-HANG](YEU-CAU-KHACH-HANG.md) §4.2) | Mở |
| <a id="ch-52"></a>CH-52 | Có áp dụng HACCP / ISO 22000 không? Gửi mẫu biểu QC đang dùng, chỉ tiêu, giới hạn, tần suất lấy mẫu; kết quả kiểm nghiệm bên ngoài có cần lưu theo lô không; giám sát thiết bị (nhiệt độ tiệt trùng, kho lạnh) ghi thế nào? | QC-01, QC-02, QC-04 | Kho + QC | Chỉ tiêu dạng danh sách đơn giản; ảnh đính kèm; nhập tay, không kết nối thiết bị | Mở |
| <a id="ch-53"></a>CH-53 | Hạn sử dụng theo từng sản phẩm; có bắt buộc xuất theo hạn dùng gần nhất (FEFO) không? | QC-08, BAN-02 | Kho + QC | Gợi ý FEFO rồi lô cũ nhất, người dùng sửa được | Mở |

## 6. Người dùng (chủ dự án, bên làm phần mềm)

| Mã | Câu hỏi | Ảnh hưởng | Chặn | Mặc định khi chưa trả lời | Trạng thái |
|---|---|---|---|---|---|
| <a id="ch-54"></a>CH-54 | Đội phát triển 5 hay 4 người; ngày bắt đầu? | Mốc tháng trong [KE-HOACH-DU-AN](../02-ke-hoach/KE-HOACH-DU-AN.md) §3.5 | 1A thiết kế (đặt mốc) | Ghi cả hai kịch bản | Mở |
| <a id="ch-55"></a>CH-55 | `HỆ THỐNG.docx` ở gốc repo chứa họ tên 16 nhân sự và metadata tác giả. Giữ hay gỡ khỏi repo (và lịch sử git)? | Bảo mật thông tin khách | Không chặn | Giữ nguyên tên và vị trí (chỉ đạo ngày 2026-10-07) | Đã trả lời: giữ nguyên trong repo, repo để công khai (người dùng, 2026-10-07) — [QD-34](../02-ke-hoach/QUYET-DINH.md#qd-34) |
| <a id="ch-56"></a>CH-56 | Tên sản phẩm: kế hoạch dùng tên tạm "Outhouse", demo dùng "Giá Gốc", tiêu đề trang demo là "Hệ thống quản lý". Chốt tên nào? | Tài liệu, giao diện, tên miền | Không chặn | Tài liệu gọi "phần mềm"; demo giữ như hiện tại | Đã trả lời: **Hệ thống quản lý** (người dùng, 2026-10-07) — [QD-33](../02-ke-hoach/QUYET-DINH.md#qd-33) |

## 7. Đội dự án: việc cần xác minh văn bản

Người làm: BA dự án; KTT xác nhận kết luận. Mọi điểm dưới đây hiện ghi "chưa xác minh" trong tài liệu và là dữ liệu cấu hình có phiên bản, nên không chặn viết mã nhưng chặn golden test hoặc mẫu in liên quan.

| Mã | Việc cần xác minh | Ảnh hưởng | Chặn | Trạng thái |
|---|---|---|---|---|
| <a id="xm-01"></a>XM-01 | Phụ lục II TT99: TK 1562, 1385, 6275; cấp 2 của 521 (5212, 5213); số hiệu và cấp 2 của 211, 213, 214, 241, 335, 341, 413 (các tài khoản đánh dấu `(*)`) | Định khoản, golden test | 1A giá thành | Mở |
| <a id="xm-02"></a>XM-02 | TT99: số hiệu mẫu sổ (42 mẫu, gồm thẻ tính giá thành), mã chỉ tiêu BCTC (B01, B02, B03), tên "Bảng cân đối kế toán" hay "Báo cáo tình hình tài chính"; số hiệu mẫu chứng từ 01-VT, 02-VT, 05-VT, 01-TT, 02-TT và mẫu phiếu xuất kho kiêm vận chuyển nội bộ (demo đang in các số hiệu này) | Mẫu in, BCTC | 1C (mẫu in kho: Kho + QC) | Mở |
| <a id="xm-03"></a>XM-03 | TT99: hướng dẫn kiểm kê định kỳ khi bỏ 611/631; còn cấm LIFO không; 4 văn bản bị thay thế theo Điều 31 | Phạm vi phương pháp | Không chặn | Mở |
| <a id="xm-04"></a>XM-04 | Tỷ giá giao dịch và tỷ giá đánh giá lại theo TT99/TT133 (loại tỷ giá, tần suất, đảo hay không) — hiện dựa trên hướng dẫn TT200 | NT-02, NT-04 | 1B | Mở |
| <a id="xm-05"></a>XM-05 | Hiệu lực TT 45/2013/TT-BTC (khung khấu hao, ngưỡng TSCĐ) tại 10/2026 | TSCD-* | 1C | Mở |
| <a id="xm-06"></a>XM-06 | Có phải lập phiếu xuất kho kiêm vận chuyển nội bộ dạng điện tử khi chuyển hàng giữa các địa điểm (NĐ 123/2020, NĐ 70/2025)? | KHO-04 | Kho + QC | Mở |
| <a id="xm-07"></a>XM-07 | NĐ 70/2025, TT 32/2025: xử lý hóa đơn sai sót, hóa đơn cho hàng bán trả lại / giảm giá (ai lập, lập loại gì) | MUA-03, BAN-03, BAN-04 | Không chặn | Mở |
| <a id="xm-08"></a>XM-08 | Dùng phương pháp giá khác nhau cho các nhóm hàng (đích danh và bình quân) có phù hợp VAS 02 không | CH-16 | 1A thiết kế | Mở |
| <a id="xm-09"></a>XM-09 | Hiệu lực TT48/2019, TT24/2022 (dự phòng) sau TT99; "TT 118/2026" ghi ở [SACH-VA-VAN-BAN](../04-tham-khao/SACH-VA-VAN-BAN.md) §8; thời hạn mức thuế GTGT 8%; dự thảo thông tư thay TT133 | Cấu hình thuế, dự phòng | Không chặn | Mở |
| <a id="xm-10"></a>XM-10 | MISA bản khách dùng: ĐVT quy đổi, phân quyền chi tiết, **nhập chứng từ kho từ Excel** (cần để chạy song song từ mốc Kho + QC) | Kế hoạch chạy song song | Kho + QC | Mở |
| <a id="xm-11"></a>XM-11 | Thuế suất GTGT của cá / tôm tươi, muối, thính, đường, mắm (demo đang để 0% / 5% / 10%) | Định khoản bán, mua | Không chặn | Mở |
| <a id="xm-12"></a>XM-12 | Đổi phương pháp tính giá hàng tồn kho (bình quân → đích danh) hoặc đổi chế độ kế toán **giữa niên độ**: được không, xử lý và thuyết minh thế nào | CH-06 | 1A thiết kế | Mở |

## 8. Bảng đối chiếu mã cũ → mã mới

Mã cũ ở yêu cầu v1.2 (§7, §9.7), kế hoạch v0.4 (§6, §7), kiến trúc Phụ lục B. Tài liệu hiện hành đã đổi hết sang mã mới; bảng này để đọc lịch sử git và tài liệu phản biện.

| Cũ | Mới | Cũ | Mới | Cũ | Mới | Cũ | Mới |
|---|---|---|---|---|---|---|---|
| A1 | CH-05 | B1 | CH-47 | C1 | CH-24 | D1 | CH-45 |
| A2 | CH-01, CH-07 | B2 | CH-12, CH-48 | C2 | CH-25 | D2 | CH-32 |
| A3 | CH-08, CH-30 | B3 | CH-10 | C3 | CH-26 | D3 | CH-33 |
| A4 | CH-44 | B4 | CH-11 | C4 | CH-27 | D4 | CH-34 |
| A5 | CH-09 | B5 | CH-49 | C5 | CH-23 | D5 | CH-35 |
| A6 | CH-02 | B6 | CH-50 | C6 | CH-28 | D6 | CH-46 |
| A7 | CH-03 | B7 | CH-51 | C7 | CH-21 | D7 | CH-36 |
| A8 | CH-04 | B8 | CH-52 | C8 | CH-43 | D8 | CH-37 |
| A9 | (gộp vào CH-30..CH-46) | B9 | CH-53 | C9 | CH-20 | D9 | CH-38 |
| A10 | CH-06 | B10 | CH-13 | | | D10 | CH-39 |
| | | B11 | CH-14 | | | D11 | CH-40 |
| | | B12 | CH-31 | | | D12 | CH-41 |
| | | B13 | CH-15 | | | D13 | CH-22 |
| | | | | | | D14 | CH-42 |

Kiến trúc Phụ lục B: mục 1 → CH-16; mục 2 → CH-20; mục 3 → CH-11, CH-47; mục 4 → CH-29; mục 5 → CH-21; mục 6 → CH-28; mục 7 → CH-05, CH-07. Kế hoạch v0.4 §6 mục 9 → CH-54; §7 → XM-01..XM-12. Mới thêm ở bản này: CH-16..CH-19, CH-29, CH-55, CH-56.

## 9. Đã trả lời

| Câu hỏi (mã cũ) | Trả lời | Nguồn | Ngày |
|---|---|---|---|
| Phương pháp tính giá xuất kho (kế hoạch v0.2) | Thực tế đích danh → đích danh theo lô ([QD-04](../02-ke-hoach/QUYET-DINH.md#qd-04)) | `HỆ THỐNG.docx` | 2026-10-06 |
| Phương pháp giá thành; có bán thành phẩm không (kế hoạch v0.2) | Nhiều giai đoạn, có bán thành phẩm; tính theo lệnh sản xuất ([QD-05](../02-ke-hoach/QUYET-DINH.md#qd-05)) | `HỆ THỐNG.docx`; người dùng | 2026-10-06; 2026-10-07 |
| Ai là KTT duyệt đặc tả (kế hoạch v0.2) | Ms Nhung | `HỆ THỐNG.docx` | 2026-10-06 |
| Bán thành phẩm có nhập kho giữa các giai đoạn không (kiến trúc Phụ lục B mục 3, phần mô hình) | Luôn có lô và sổ kho ([QD-06](../02-ke-hoach/QUYET-DINH.md#qd-06)); phần tài khoản còn ở CH-11 | Người dùng | 2026-10-07 |
