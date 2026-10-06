# Giá Gốc demo v3: nhật ký thay đổi

Tệp: `gia-goc-demo.html`. Vẫn là một file, vanilla JS, không dùng script ngoài (chỉ giữ font Google). Bản v3 chuyển demo từ xưởng bàn ghế gỗ sang **nhà máy chế biến mắm** theo tài liệu HỆ THỐNG.docx, sửa lỗi B1–B5 và thêm các yêu cầu cốt lõi của khách: lô (mã lót hàng), giá thực tế đích danh, giá thành phân bước 2 giai đoạn, 3 kho, QC, ngoại tệ, lệnh sản xuất, trang Báo cáo.

Key lưu trữ đổi sang `localStorage['giagoc-demo-v3']` và tour `giagoc-tour-v2`, nên dữ liệu v2 cũ không làm vỡ trang (bị bỏ qua, nạp dữ liệu mẫu mới). Vẫn không có `<meta name="viewport">` (giữ nguyên quyết định ở v2.1).

## Số chính v3 (kịch bản mặc định: TT 99, thực tế đích danh, 800 giờ máy, dở dang BTP 350 kg, ML5 0, MT2 150 hũ)
| | Mới mở (bước 1–4 xong) | Sau khi khóa sổ |
|---|---|---|
| Doanh thu thuần | 225.990.000 | 225.990.000 |
| Giá vốn (gồm 5.964.000 SXC dưới công suất và 771.515 hỏng ngoài định mức) | 154.605.503 | 154.605.503 |
| Lãi gộp / biên | 71.384.497 / 31,59% | 71.384.497 / 31,59% |
| Lãi chênh lệch tỷ giá (515) | 78.000 | đã kết chuyển |
| Lợi nhuận trước thuế sang 4212 | – | 71.462.497 |
| z BTP cá linh ủ thính (GĐ1) | 71.848,61 đ/kg | 71.848,61 đ/kg |
| z mắm cá linh hũ 500g (GĐ2) | 44.597,95 đ/hũ | 44.597,95 đ/hũ |
| z mắm tôm hũ 250g (1 GĐ) | 39.371,15 đ/hũ | 39.371,15 đ/hũ |
| Sổ cái 154 (dở dang) | 23.426.252 | 23.426.252 |
| Hàng tồn kho cuối kỳ (152 + 154 + 155 + 156) | 284.266.497 | 284.266.497 |
| Bù trừ thuế GTGT (TH0001) | – | 5.898.500 |

Với thực tế đích danh, số mới mở và sau khóa sổ trùng nhau vì không có giá tạm (giá xuất lấy theo lô; giá thành tạm tính chỉ đổi khi chứng từ đổi). Với bình quân cuối kỳ, phiếu xuất dùng giá tạm (bình quân tức thời) cho tới bước chốt như v2.

## 1. Dữ liệu mẫu ngành mắm (kỳ 01/2026)
- 3 kho: `BBT` Nhà máy Bà Ba Thạo (NVL, bao bì, phụ gia, BTP, thành phẩm), `BT` Kho Bình Tây, `NTH` Cửa hàng 97 Nguyễn Thái Học (bán lẻ). Vai trò thủ kho và 4 QC theo khu lấy từ tài liệu, chỉ hiện tên vai trò.
- Vật tư: cá linh tươi, tôm/ruốc tươi, muối hạt, thính gạo, đường, gia vị (kg); hũ + nhãn 500g, 250g (cái); BTP "Cá linh ủ thính" (kg); thành phẩm "Mắm cá linh hũ 500g", "Mắm tôm hũ 250g"; một hàng hóa mua về bán (nước mắm chai, TK 156). Mỗi vật tư có nhóm, kho mặc định, QC phụ trách, hạn sử dụng.
- Đối tác đều ghi "(mẫu)"; một NCC nước ngoài thanh toán USD.
- 36 chứng từ: 8 phiếu nhập mua (1 phiếu USD), 8 phiếu xuất theo 3 lệnh sản xuất, 5 phiếu nhập kho (2 BTP, 3 thành phẩm, 1 lô "Chờ" QC), 2 phiếu chuyển kho, 5 hóa đơn (bán sỉ, bán lẻ tại NTH), 2 phiếu chi (VND và USD), 1 phiếu thu, lương, khấu hao, 2 chi phí SXC.
- Tồn đầu kỳ theo lô; dở dang đầu kỳ (cá, tôm đang ủ); số dư đầu tiền mặt, 2 tài khoản ngân hàng (1122 có 3.000 USD), phải thu, phải trả, TSCĐ, vốn. 4211 là số cân đối để tổng Nợ = tổng Có (ghi rõ trên Bảng cân đối số phát sinh).
- Lịch sử 08–12/2025 chỉnh về biên 30–31% (số mẫu cố định).

## 2. Engine
- **Luật làm tròn R1**: hàm `allocate(total, weights)` largest remainder, dùng cho phân bổ SXC, chia Z cho các phiếu nhập kho, chia phần hỏng ngoài định mức cho các phiếu, trích theo lương (theo dòng lương và theo từng quỹ), cây truy xuất. Bỏ kiểu "phần cuối nhận dư". Giá xuất theo R1(c): `round(SL × giá trị tồn / SL tồn)` của nguồn giá, phiếu làm nguồn về 0 nhận phần còn lại.
- **Lô**: mỗi dòng phiếu nhập mua, phiếu nhập kho sản xuất, hàng thừa kiểm kê ngoài sổ sinh một mã lô (mã vật tư + yymmdd + số thứ tự, ví dụ `NL-CL-260105-01`, `TP-ML5-260127-01`). Mã lô lưu trên chứng từ, không cấp lại kể cả khi phiếu bị hủy; sửa phiếu giữ nguyên mã lô.
- **Tồn theo ô (vật tư, kho, lô)** ở mọi phương pháp; tồn âm báo theo ô.
- **Phương pháp `specific` (thực tế đích danh) là mặc định**: nguồn giá là lô tại kho. Giữ bình quân cuối kỳ, bình quân tức thời, FIFO để so sánh; với các phương pháp này lô chỉ để đếm số lượng và truy xuất. Thẻ so sánh trên trang Giá xuất kho có đủ 4 phương pháp.
- **Hàng bán trả lại** về đúng lô và kho gốc của hóa đơn, giá vốn lúc bán (bình quân cuối kỳ: giá bình quân kỳ).
- **Chuyển kho nội bộ** (`CK`): giữ mã lô và giá trị lô, **không sinh bút toán** (cùng TK kho); giá trị chuyển chỉ dùng cho N-X-T theo kho. Ghi rõ trong chi tiết chứng từ: muốn sổ cái thấy theo kho phải mở TK chi tiết theo kho (chưa làm).
- **Giá thành phân bước có tính giá BTP**: engine tính theo thứ tự phụ thuộc — giá xuất NVL → thẻ BTP (GĐ1) → giá nhập kho các lô BTP → định giá phiếu xuất BTP → thẻ mắm cá linh (GĐ2); mắm tôm 1 giai đoạn. Thứ tự được suy ra từ phiếu xuất (vật tư nào xuất cho đối tượng nào), không gõ cứng.
- Thẻ giá thành: chọn **cột riêng "BTP GĐ trước chuyển sang"**, không gộp vào NVL. Phiếu xuất BTP ghi Nợ 154 (khoản mục BTP) / Có 155, cả hai chế độ.
- **BTP nhập kho hạch toán TK 155**, kèm ghi chú trên UI: "chưa xác minh: BTP nhập kho ghi 155 hay giữ 154 — chờ kế toán trưởng".
- **Hao hụt và QC trên phiếu nhập kho sản xuất**: SL đạt, SL không đạt (loại bỏ), tỷ lệ hao hụt định mức theo sản phẩm (BTP 3%, ML5 1%, MT2 2%). Công thức:
  - Zt (hoàn thành gồm hỏng) = DDĐK + C − DDCK
  - Cho phép = định mức % × (đạt + không đạt); vượt = max(0, không đạt − cho phép)
  - Hỏng ngoài định mức = round(Zt × vượt / (đạt + không đạt)) → Nợ 632 / Có 154 (ghi trên phiếu nhập kho có hỏng)
  - Z SP đạt = Zt − hỏng ngoài định mức; z = Z / SL đạt. Phần trong định mức nằm trong Z.
  - Mẫu: mắm tôm hỏng 60 hũ, cho phép 40, vượt 20 → 771.515 đ vào 632.
- **QC lô**: Đạt / Chờ / Không đạt, người QC theo khu. Đổi trạng thái ở bảng "Tồn kho theo kho và lô" (ghi nhật ký, không sinh bút toán). Lô Chờ / Không đạt không chọn được khi bán; lô Không đạt không xuất sản xuất, không chuyển kho được. Lô quá hạn sử dụng còn tồn được nhắc ở "Việc cần làm".
- **Ngoại tệ**: phiếu nhập USD (giá trị = round(SL × đơn giá USD × tỷ giá), thuế GTGT nhập khẩu chưa làm nên để 0%). Phiếu chi `CT` (1111 / 1121 / 1122): USD ghi **Nợ 331 theo tỷ giá ghi sổ đích danh của hóa đơn được trả, Có 1122 theo tỷ giá ghi sổ bình quân gia quyền di động của TK 1122**, chênh lệch Có 515 / Nợ 635; theo dõi nguyên tệ còn nợ từng hóa đơn và số USD trên 1122. Phiếu thu `TN`: Nợ 1111/1121 / Có 131. **Đánh giá lại cuối kỳ (413): chưa làm.**
- **Lệnh sản xuất** `LSX` (danh mục, có form lập / sửa): số lệnh, sản phẩm / giai đoạn, SL kế hoạch, kho. Phiếu xuất và nhập kho tham chiếu lệnh; đối tượng tập hợp chi phí lấy từ lệnh.
- **B1** (tồn âm khóa sổ được): hàm `settle()` dùng chung cho mọi thay đổi: sau khi tính lại, nếu có tồn âm mà bước 4 đã chạy thì đánh dấu chạy lại từ bước 4, bất kể loại chứng từ (HD, hủy NK, CK, PX…). Bước 11 (`balanceCheck`) cũng kiểm tồn âm. Câu "Tồn âm sẽ chặn bước 4" giờ đúng.
- **B2**: doanh thu theo loại hàng — thành phẩm / BTP → 5112, hàng hóa → 5111 (có tên TK); hàng bán trả lại ghi Nợ đúng TK đó.
- **B3**: text bước 11 liệt kê đúng các TK kho có mặt (152, 155, 156, 154).
- **B4**: cảnh báo lệch đơn giá chỉ chạy khi đơn giá lần nhập trước > 0.
- **B5**: kiểm kê thừa trên lô có sẵn lấy đơn giá của lô (đích danh) hoặc bình quân tại ngày, không được thì giá lô gần nhất; hàng thừa ngoài sổ bắt nhập đơn giá (mặc định giá lô gần nhất). Không còn ghi 0 đ.

## 3. Giao diện
- Header / thanh kịch bản: "Demo cho quy trình mua → kho → giá thành → P&L theo tài liệu HỆ THỐNG".
- Trang mới **Báo cáo** (chọn loại): sổ nhật ký chung; sổ cái (chọn TK, có TK đối ứng, số dư lũy kế); bảng cân đối số phát sinh (kiểm cân đầu / cuối kỳ); báo cáo kết quả kinh doanh (sau bước 10 lấy từ 911 của KQ0001, trước đó lấy từ số dư TK 5–8, có nhãn nguồn); công nợ phải thu / phải trả theo đối tượng có cột nguyên tệ USD; sổ quỹ / sổ tiền gửi (1122 có cột USD và tỷ giá ghi sổ); tiến độ sản xuất theo lệnh; tổng hợp xuất kho theo lệnh. Đều tính từ bút toán và có "Sao chép cho Excel".
- Trang **Kho & lô**: lọc theo kho (tất cả / BBT / BT / NTH), N-X-T nhóm theo 152 / BTP / thành phẩm / 156 (theo kho thì nhập gồm hàng chuyển đến, xuất gồm hàng chuyển đi), bảng "Tồn kho theo kho và lô" (nguồn, ngày, HSD, QC, người QC, SL, giá trị lô với đích danh, nút QC lô).
- Trang **Giá xuất kho**: sổ chi tiết có cột Kho, Lô; panel "Nguồn gốc đơn giá" hiện lô (nguồn, QC, HSD) và công thức theo lô. Nút "Thử: nhập bổ sung thính gạo lùi ngày 06/01"; với đích danh, form nói rõ phiếu đã chọn lô không đổi giá.
- Trang **Giá thành phân bước**: sơ đồ thứ tự tính (GĐ1 → kho BTP → GĐ2 · mắm tôm), ô dở dang cho từng đối tượng, bảng phân bổ SXC, thẻ giá thành từng giai đoạn với dòng "Hỏng ngoài định mức → Nợ 632 / Có 154" và "Z SP đạt".
- Trang **Truy xuất theo lô**: chọn lô BTP hoặc thành phẩm; với lô GĐ2 có nhánh "BTP giai đoạn trước chuyển sang" → từng lô BTP → thẻ GĐ1 (z = NVL + NC + SXC) → phiếu xuất, lô, nhà cung cấp cá linh.
- Trang **Danh mục & lệnh SX**: danh mục vật tư (nhóm, QC phụ trách, HSD, định mức), lệnh sản xuất, kho và vai trò.
- Form mới hoặc làm lại: phiếu nhập (kho, VND/USD, QC, mã lô sẽ cấp), phiếu xuất theo lệnh (chọn lô, gợi ý lô HSD gần nhất / cũ nhất, hiện tồn của lô tại kho, điền định mức tự tách theo lô), nhập kho sản xuất (đạt / loại bỏ / QC, z và hỏng ngoài định mức dự kiến), chuyển kho, hóa đơn (chỉ lô Đạt, giá lẻ tại NTH), trả lại (hiện lô gốc), kiểm kê theo kho và lô (+ hàng thừa ngoài sổ), chi tiền, thu tiền, bảng lương theo từng đối tượng, lệnh sản xuất, vật tư (nhóm, QC, HSD, giá sỉ / lẻ, định mức hao hụt).
- Tour 10 bước, kịch bản 5 bước (bước 2 đổi thành "Sửa giá lô cá linh, giá thành 2 GĐ tính lại": mở sửa PN0001 đã điền sẵn), chú giải thuật ngữ đều viết lại cho ngành mắm.
- Thẻ giá thành xếp 1 cột cho đủ chỗ 5–6 cột số.

## Đã kiểm tra thật (Chromium 1194 qua Playwright, mở file://, chặn font)
- `node --check` phần script đã trích: đạt.
- `__giagoc.selfTest()`: **960 tổ hợp, 0 lỗi** (khoảng 12 giây) = 2 chế độ × 4 phương pháp × giờ máy 800/1200 × dở dang mặc định/0 × 15 biến thể × mở/khóa. Biến thể: cơ bản, lùi ngày, bán thêm, trả lại, kiểm kê thừa/thiếu (gồm hàng thừa ngoài sổ, 2 kho), chuyển kho rồi bán tại kho đến, nhập USD + chi USD một phần + chi VND, hủy phiếu (CP, CT, TN, HD), chi phí bổ sung, hỏng vượt định mức, lô không đạt, vật tư mới, tồn âm do PX, tồn âm do HD bán vượt, tồn âm do hủy NK. Ở trạng thái "khóa", thay đổi được áp dụng **sau khi đã chạy tới bước 9** rồi qua `settle(D, AFFECT)` như khi bấm lưu, nên kiểm luôn việc đánh dấu chạy lại.
- Mỗi tổ hợp kiểm: Nợ = Có từng chứng từ; không NaN; kho = sổ cái 152/155/156/154 (và 621/622/627 = 0 với TT 99); Zt = DDĐK + C − DDCK; Z = Zt − hỏng ngoài định mức; Σ giá trị lô nhập kho = Z SP đạt; Σ hỏng theo phiếu = hỏng ngoài định mức; giá lô = giá nhập kho; 154 ≥ 0; tồn theo (vật tư, kho, lô) không âm và tiền 1111/1121/1122 không âm ở biến thể hợp lệ; biến thể tồn âm: bước tiếp theo là bước 4 ngay sau khi lưu, không khóa được, dừng ở bước 4 (hoặc 11); hợp lệ: khóa được, TK 5–8 = 0, thuế đã bù trừ; B2 (5111/5112 cả bán và trả lại); Nợ 331 USD đúng tỷ giá hóa đơn, nguyên tệ còn nợ đúng; lô Không đạt / Chờ bị form hóa đơn từ chối. Thêm 5 ca kiểm `allocate`.
- Kiểm độ nhạy của selfTest bằng bản sửa hỏng tạm: bỏ đánh dấu chạy lại khi tồn âm → 128 lỗi; gộp 5111 vào 5112 → 128 lỗi; bỏ trừ hỏng ngoài định mức khỏi Z → 1.568 lỗi; bỏ cả hai lớp chặn tồn âm → 256 lỗi (có "khóa sổ được dù tồn âm").
- Qua sự kiện DOM (đặt giá trị + dispatch `input`/`change`, `openForm`/`saveForm`): lưu được 15 loại form (PN VND, PN USD, PX, PX điền theo định mức, NK, CK, HD, TL, CT VND, CT USD, TN, KK + hàng thừa, BL, KH, CP) và 3 form danh mục (LSX, vật tư có / không tồn đầu). B5: hàng thừa của vật tư chưa có lô giá bị chặn đến khi nhập đơn giá (15.000 → 30.000 đ). Kịch bản 2 sửa PN0001 (+2.000 đ/kg): z mắm cá linh 45.283,68 → 45.779,05, mã lô giữ nguyên. Lô "Chờ" hiện mờ, đổi QC sang Đạt thì bán được. B1 qua giao diện: khóa sổ, mở khóa, lập HD bán vượt lô (form báo "Tồn âm sẽ chặn bước 4", tích "Vẫn lưu") → "Chạy tất cả" dừng ở bước 4 chỉ đúng phiếu, kho, lô; hủy HD → khóa đủ 12 bước. Đổi 4 phương pháp và TT 133: kho vẫn khớp sổ cái. 8 báo cáo đều có dữ liệu, không lệch. Kịch bản 5 bước, tour 10 bước chạy hết.
- Mọi view (10 trang) không có lỗi trang / console (ngoài yêu cầu font bị chặn), không có "NaN", "undefined", "Infinity".
- Khung 390px (sáng và tối): `scrollWidth ≤ 390` ở 10 trang, 8 loại báo cáo, 14 form và 10 bước tour.

## Chưa làm hoặc giới hạn
- Đánh giá lại số dư ngoại tệ cuối kỳ (413); thuế GTGT hàng nhập khẩu; phí ngân hàng.
- Bảng cân đối kế toán, lưu chuyển tiền tệ; TSCĐ, CCDC, khế ước vay; đơn đặt hàng, đề nghị thanh toán; giảm giá hàng mua / bán; nhật ký thu / chi riêng; đối chiếu kế toán – thủ kho; chi phí 641/642; thuế TNDN.
- Chuyển kho không có bút toán và không có TK chi tiết theo kho; sổ cái chỉ thấy tổng 152/155/156.
- Công đoạn "massage BTP" quay lại và dở dang kéo nhiều kỳ chỉ thể hiện bằng số dở dang đầu/cuối kỳ; định mức hao hụt là một tỷ lệ cho cả giai đoạn.
- Dở dang chỉ đánh giá theo NVL (và BTP), không theo sản lượng tương đương.
- Với bình quân / FIFO, giá trị theo kho là phân bổ theo số lượng (tổng 3 kho vẫn khớp sổ chi tiết); giá trị theo lô chỉ có ở đích danh.
- Đổi QC một lô đã bán không tự sinh phiếu thu hồi.
- Không có `<meta name="viewport">` nên trên điện thoại thật trang hiển thị ở bề rộng 980px; kiểm 390px là khung trình duyệt 390px.

## Giả định nghiệp vụ chưa xác minh
- BTP nhập kho ghi 155 hay giữ 154 (chờ kế toán trưởng); xuất BTP cho GĐ2 ghi thẳng Nợ 154 (có đơn vị ghi qua 621).
- Thuế suất GTGT cá / tôm tươi (để 0%), muối, thính, đường (5%), mắm (10%); chính sách giảm thuế hiện hành.
- Hạn sử dụng, tỷ lệ hao hụt định mức, đơn giá, giá bán là số mẫu.
- Hàng bán trả lại ghi giảm thẳng 511; số hiệu mẫu S37-DN theo TT 99.
