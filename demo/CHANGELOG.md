# Giá Gốc demo v3: nhật ký thay đổi

## v4.0: giá vốn theo lô, giá thành theo lệnh sản xuất, bỏ khóa sổ

Mục tiêu người dùng: biết giá vốn hàng bán của mọi sản phẩm; kiểm soát giá nguyên liệu; mỗi lô một giá; bấm vào lô thấy giá vốn cấu thành từ những lô nguyên liệu nào, giá bao nhiêu. Theo phản biện `docs/PHAN-BIEN-v3.md`.

### Bỏ khóa sổ
- Bỏ trang, menu, 12 bước, khóa / mở khóa kỳ, giá tạm / đã chốt / cần tính lại, thanh tiến độ, nhắc khóa sổ trong tour, Việc cần làm, thanh trên. Bỏ bù trừ thuế (TH0001) và kết chuyển 911 (KQ0001); báo cáo kết quả kinh doanh lấy thẳng từ số dư tài khoản loại 5–8 (thêm chi phí khác 811).
- KC0001 giữ là chứng từ hệ thống luôn cập nhật: kết chuyển 621 / 622 / 627 sang 154 theo từng lệnh sản xuất (Thông tư 99); Thông tư 133 phân bổ sản xuất chung trong 154.
- Engine luôn tính theo phương pháp đã chọn (bình quân cuối kỳ không còn giá tạm bình quân tức thời).
- Tồn âm bị chặn ngay khi lưu, sửa hoặc hủy chứng từ (bỏ "Vẫn lưu", "Vẫn hủy"); sửa tồn đầu kỳ của vật tư gây tồn âm cũng bị chặn. Tổng quan vẫn báo nếu có.

### Giá thành theo lệnh sản xuất
- Mỗi lệnh là một đối tượng tập hợp chi phí: nguyên vật liệu / bán thành phẩm xuất cho chính lệnh (giá theo lô); nhân công trực tiếp của sản phẩm phân bổ cho các lệnh của sản phẩm đó; sản xuất chung (sau phần cố định dưới công suất → 632) phân bổ cho mọi lệnh trong kỳ. Một tiêu thức: chi phí nguyên vật liệu trực tiếp của lệnh (không gồm bán thành phẩm giai đoạn trước); hiện trong bảng phân bổ. Làm tròn R1(b) `allocate()`.
- Trạng thái lệnh: Mới / Đang sản xuất / Hoàn thành. Lệnh hoàn thành khi có phiếu nhập kho: toàn bộ chi phí lệnh − hỏng ngoài định mức (→ 632) = tổng giá thành, chia cho các dòng nhập kho theo số lượng đạt. Lệnh chưa nhập kho: toàn bộ chi phí là dở dang 154 của lệnh (bỏ ô nhập số dở dang thủ công).
- Chặn sai thời gian: phiếu xuất cho lệnh không được sau ngày nhập kho đầu tiên của lệnh; phiếu nhập kho không được trước phiếu xuất cuối của lệnh.
- Dữ liệu mẫu (key lưu trữ `giagoc-demo-v40`): 6 lệnh. LSX-2512-05 bán thành phẩm cá linh mua 12/2025 ủ nhiều kỳ, dở dang đầu kỳ 18.000.000, còn dở dang cuối kỳ 19.529.099. LSX-2601-01 (cá lô 050126-01, 45.000 đ/kg) → bán thành phẩm 180126-01, 1.760 kg × 72.825,15. LSX-2601-02 (cá lô 120126-01, 52.000 đ/kg, +15,6%) → 240126-01, 970 kg × 82.530,79. LSX-2601-04 (bán thành phẩm tồn đầu 70.000 + lô 180126-01) → mắm cá linh 270126-01, 2.400 hũ × 43.457,56. LSX-2601-05 (lô 240126-01) → 290126-01, 1.570 hũ × 48.788,92. Mắm tôm 1 giai đoạn LSX-2601-03 → 270126-02, 1.940 hũ × 40.482,89 (hỏng ngoài định mức 793.301).
- Số chính: doanh thu thuần 266.790.000; giá vốn 183.496.965; lãi gộp 83.293.035 (31,22%); lợi nhuận trước thuế 83.371.035; hàng tồn kho 262.575.035; 154 = 19.529.099.

### Trang mới, trang làm lại
- **Giá nguyên liệu** (nhóm Kho & giá): mọi lô nguyên liệu, bao bì, phụ gia: mã lô, mã hóa, nhà cung cấp, ngày nhập, đơn giá, so với lô trước cùng vật tư (tăng > 10% chữ đỏ, > 5% chữ cam; hằng số `PRICE_BAD`, `PRICE_WARN`), số lượng nhập / còn, kho · vị trí; lọc vật tư, tìm không dấu. Bấm vật tư: biểu đồ đường lịch sử giá (một trục, điểm 8px, tooltip theo điểm, nút Biểu đồ / Bảng) và bảng "Đã dùng cho" (truy xuôi lô nguyên liệu → lệnh → lô bán thành phẩm → lô thành phẩm).
- **Giá vốn theo lô** (thay Truy xuất theo lô): lọc Thành phẩm / Bán thành phẩm / Hàng hóa; mỗi lô: mã lô, mã hóa, lệnh, ngày, số lượng, đơn giá thành, giá trị, đã bán, giá vốn đã bán, còn. Bấm lô: cây cấu thành theo bảng (thành phần · lô · mã hóa · nhà cung cấp · phiếu · số lượng · đơn giá · thành tiền · đ/đơn vị · %); dòng bán thành phẩm mở xuống lệnh giai đoạn 1 và lô cá của nó (đệ quy); nhân công, sản xuất chung phân bổ; tổng = giá trị lô; chỉ phiếu xuất của chính lệnh (sửa U1). Cuối cây: hóa đơn bán từ lô (ngày, khách, số lượng, giá vốn, doanh thu, lãi gộp) hoặc lệnh đã dùng lô bán thành phẩm.
- **Giá thành theo lệnh sản xuất**: bảng lệnh (dở dang đầu kỳ, nguyên vật liệu, bán thành phẩm, nhân công, sản xuất chung, tổng, hỏng → 632, tổng giá thành, giá thành đơn vị, dở dang cuối kỳ), bảng phân bổ có dòng tiêu thức, thẻ giá thành của lệnh đang chọn.
- **Tổng quan**: bảng "Giá vốn hàng bán theo sản phẩm" (số lượng bán, doanh thu, giá vốn, lãi gộp, biên, số lô đã bán, đơn giá vốn thấp – cao) cộng các dòng ngoài lô (sản xuất chung dưới công suất, hỏng ngoài định mức, hao hụt kiểm kê, xuất hủy) = số dư 632; cơ cấu giá thành theo từng lệnh đã hoàn thành; giữ biểu đồ doanh thu – lãi gộp.

### In phiếu
- Mẫu theo sổ kho của nhà máy: phiếu xuất kho (02-VT: khách / người nhận, địa chỉ, mã số thuế, điện thoại, lý do, kho, lệnh sản xuất; bảng STT · nhóm hàng · tên hàng · lô · mã hóa · vị trí · đơn vị tính · số lượng yêu cầu · số lượng thực xuất · đơn giá · thành tiền · ghi chú; tổng cộng, tiền bằng chữ, ngày / địa điểm giao, hình thức thanh toán; ký Người lập phiếu · Người nhận hàng · Bảo vệ · Tài xế · Thủ kho), phiếu nhập kho (01-VT; ký Người lập phiếu · Người giao hàng · Thủ kho · Kế toán), phiếu xuất kho kiêm vận chuyển nội bộ (chuyển kho), biên bản kiểm kê (sổ sách, kiểm kê, chênh lệch, %, ký Thủ kho · Kế toán · QC), phiếu thu, phiếu chi. Chỉ ghi "Nhà máy chế biến mắm", không chép thông tin công ty từ file. Đọc số tiền bằng chữ (`moneyWords`).
- Dễ thấy: nút "Lưu và in" trong form; biểu tượng in và ô chọn ở đầu mỗi dòng danh sách chứng từ (ghim khi cuộn ngang ở màn hẹp); nút chính "In phiếu nhập kho / xuất kho…" đầu hàng nút ở chi tiết; lọc nhanh Phiếu nhập kho / Phiếu xuất kho; "In các phiếu đã chọn" in liên tiếp, mỗi phiếu một trang.

### Sửa lỗi phản biện
- L2, L3: Sửa và Hủy dùng chung điều kiện chặn (hóa đơn có hàng trả lại, phiếu nhập có phiếu chi). L4: trong ngày, nhập trước, các phiếu còn lại theo thứ tự lập. L6: lần trả lại cuối nhận phần còn lại. L7: nhân / chia làm tròn bằng số nguyên (`mulRound`, `ratioRound`; 1,001 × 31.500 = 31.532). L9: bảng lương khấu trừ 10,5% người lao động. L10: cảnh báo phiếu nhập trả tiền mặt ≥ 5 triệu.
- U2 cảnh báo "phiếu kiểm kê lỗi thời" (form và Việc cần làm). U3 Enter sang ô kế, Ctrl+Enter ghi sổ. U5 Esc / Hủy bỏ khi đang nhập: hỏi "Bỏ phiếu đang nhập?". U6 "sau phiếu này X / Y". U7 cảnh báo trộn lô khi nhập / chuyển / nhận trả vào vị trí đang chứa lô khác. U8 "+ Vị trí" (phiếu nhập) và thêm vị trí (nhập kho sản xuất): dòng đầu tự nhận phần còn lại. U9 nhận hàng trả chọn QC và vị trí; chưa đạt vào lô con riêng (`270126-01-T1`). U10 phiếu xuất hủy lô Không đạt, Nợ 632 hoặc 811 (nút "Xuất hủy" ở Tồn kho chi tiết). U11 bảng không cắt cột ở 1366; ở 390 cuộn ngang trong vùng bảng, cột đầu ghim nhưng hẹp. U12 tìm không dấu. U13 ô Ảnh hưởng một dòng gập được, tự ẩn khi chuyển màn. U14 ô mã vật tư luôn hiện đúng mã sẽ lưu. U16 nút "Tải bảng" tải CSV UTF-8 có BOM.

### Chữ trên giao diện
- Bỏ mã mẫu sổ trong tiêu đề màn hình (S10-DN, S11-DN, S37-DN…; bản in vẫn ghi mẫu số) và dòng nhắc lại ngữ cảnh ở sổ chi tiết vật tư.
- Viết đầy đủ, không chữ viết tắt (nguyên vật liệu, bán thành phẩm, nhân công trực tiếp, sản xuất chung, dở dang, lệnh sản xuất, giai đoạn, số lượng, đơn vị tính, hạn sử dụng, nhà cung cấp, chứng từ, tài khoản, Thông tư 99/2025, Thông tư 133/2016, tổng giá thành, giá thành đơn vị…); bỏ `<abbr>`. Giữ mã định danh (PN0001, LSX-2601-01, mã lô, mã hóa, mã vật tư, mã kho), số hiệu tài khoản, QC, thuế GTGT.

### Đã kiểm tra (Playwright, Chromium, thao tác giao diện)
- `__giagoc.selfTest()`: **384 tổ hợp, 0 lỗi** = 2 chế độ × 4 phương pháp × giờ máy 800 / 1200 × 24 biến thể. Bất biến: Nợ = Có từng chứng từ; kho = sổ cái 152 / 155 / 156 / 154; 621 / 622 / 627 = 0; tổng chi phí lệnh = DDĐK + nguyên vật liệu + bán thành phẩm + nhân công + sản xuất chung; lệnh hoàn thành: tổng giá thành = tổng − hỏng, Σ lô = tổng giá thành, không phiếu xuất sau ngày nhập kho; lệnh dở dang: dở dang = tổng; cây cấu thành mỗi lô cộng đúng giá trị lô, nhánh bán thành phẩm cộng đúng dòng; Σ phân bổ = phát sinh; giá vốn theo lô + ngoài lô = 632; không tồn âm ở biến thể hợp lệ; biến thể tồn âm (xuất, bán, hủy nhập kho, vượt tồn vị trí) bị hàm chặn và `docCheck` của form báo lỗi. Biến thể mới: trả lại không đạt + xuất hủy 811, trả lại 3 lần (L6), trả lại rồi bán lại cùng ngày (L4), kiểm kê lỗi thời (U2), lệnh mới với cá giá mới. Độ nhạy: bỏ phần còn lại L6 → 4 lỗi; bỏ sản xuất chung khỏi tổng giá thành → 2.336 lỗi; thứ tự cũ trong ngày → 16 lỗi.
- Tính tay độc lập (Python, phân số): lô 180126-01 = nguyên vật liệu 98.910.000 + nhân công 15.093.020 + sản xuất chung 14.169.252 = 128.172.272, trùng engine.
- 1366×768 và 390×844, sáng và tối, 41 bước mỗi khung: 10 trang không lỗi / NaN / cuộn ngang / bo góc > 2px / chữ khóa sổ / mã mẫu sổ; Giá nguyên liệu (2 lô cá 45.000 / 52.000, +15,6% đỏ, tooltip, truy xuôi); Giá vốn theo lô (2 lô mắm cá linh 43.457,56 / 48.788,92; cây tới lô cá 050126-01 và nhà cung cấp; tổng 104.298.152 = round(z × 2.400); phiếu xuất ≤ ngày nhập kho); nhập cá 60.000 → lệnh mới → nhập kho bán thành phẩm → lệnh giai đoạn 2 → nhập kho → bán 100 hũ: giá vốn hóa đơn = round(100 × giá trị lô / số lượng lô); Enter / Ctrl+Enter / Esc; bán 99.999 hũ bị chặn; tìm không dấu; tải CSV có BOM. In phiếu (1366 và 390): Lưu và in, in từ dòng, in 3 phiếu đã chọn (3 trang), chuyển kho đúng tiêu đề, phiếu thu / chi; đọc số 1.005.000, 21.000.100, 0 đúng. Quét chữ hiển thị (mọi trang, báo cáo, form, tooltip, tour, bản in): 0 chữ viết tắt trong danh sách.

### Giả định chưa chắc
- Tiêu thức phân bổ nhân công và sản xuất chung cho lệnh: chi phí nguyên vật liệu trực tiếp của lệnh (không gồm bán thành phẩm); chưa có giờ công theo lệnh. Bảng lương vẫn ghi nhân công theo sản phẩm.
- Lệnh hoàn thành khi có phiếu nhập kho đầu tiên; toàn bộ chi phí vào các lô nhập kho của lệnh, không có dở dang một phần.
- Hàng trả lại chưa đạt nhận vào lô con riêng; đơn giá trên phiếu xuất kho là giá vốn.


## v3.4: biểu đồ

Thiết kế lại các biểu đồ theo quy trình dataviz (chọn dạng → màu → kiểm bảng màu bằng `validate_palette.js` → vạch, khe → lớp hover → a11y). Chỉ đổi giao diện; engine, số liệu, ID và `window.__giagoc` giữ nguyên.

### Bảng màu biểu đồ (4 ô categorical, chế độ tối có bước riêng)
- Sáng (nền #ffffff): `--k1` #1f5fa8 xanh dương, `--k2` #6899e2 xanh dương nhạt, `--k3` #1e8163 xanh lục lam đậm, `--k4` #67c7a4 xanh lục lam nhạt. Validator: dải L, chroma ≥ 0,10 đạt; CVD cặp kề ΔE 18,9, mọi cặp 16,5; thị lực thường cặp kề 19,5, mọi cặp 17,2. Tương phản < 3:1 ở #6899e2, #67c7a4 → có nhãn trực tiếp và chế độ Bảng.
- Tối (nền #1e2124): #5894e0, #3063a6, #3ba888, #04785d. Validator: mọi cặp CVD 13,7, thị lực thường 15,1; tương phản < 3:1 ở #3063a6, #04785d → nhãn và Bảng.
- Gán theo đối tượng, không theo thứ hạng: doanh thu = k1, lãi gộp = k2; khoản mục giá thành NVL = k1, BTP GĐ trước = k2, NC = k3, SXC = k4 (dùng chung cho cơ cấu giá thành và chấm màu ở Truy xuất). Đỏ / cam chỉ cho trạng thái. Không tím, không gradient.
- Chữ luôn dùng màu chữ; nhãn đặt trong ô màu chọn trắng hoặc mực đậm theo độ sáng nền (`--kN-ink`).

### Từng biểu đồ
- **Doanh thu và lãi gộp 6 tháng**: cột nhóm vẽ SVG theo đúng bề rộng thật (vẽ lại khi đổi kích thước, chữ không bị co), cột ≤ 24px, đầu cột bo 2px, chân vuông, khe 2px giữa hai cột; một trục y số tròn (0 / 100 / 200 / 300), lưới mảnh liền nét; kỳ hiện tại: nhãn tháng đậm và chỉ hai cột kỳ này có nhãn số. Thêm biểu đồ nhỏ **biên lãi gộp %** dùng chung trục x, trục y riêng (không dùng 2 trục y trên một biểu đồ). Bỏ độ mờ 55% của các tháng trước. Rê chuột / chạm / Tab vào cả dải tháng (lớn hơn cột) hiện tooltip doanh thu, lãi gộp, biên và tô nền dải tháng ở cả hai biểu đồ. Chú giải đặt trên biểu đồ. Nút **Biểu đồ / Bảng** (bảng số vẫn có cho trình đọc màn hình khi xem biểu đồ).
- **Cơ cấu giá thành đơn vị**: thanh xếp chồng 100% nằm ngang, thứ tự cố định BTP GĐ trước → NVL → NC → SXC (khớp cột thẻ S37), khe 2px, đầu thanh bo 2px; nhãn % trong đoạn chỉ khi đủ chỗ (đo sau khi vẽ); giá thành đơn vị ở đầu dòng. Dở dang đầu kỳ gộp vào khoản mục NVL (như thẻ giá thành), số tiền hiện trong tooltip và cột "Gồm DDĐK" của bảng. Rê / Tab vào đoạn: tooltip đ/đvt, tỷ trọng; các đoạn khác mờ đi. Bỏ dòng chữ liệt kê dưới mỗi thanh; thay bằng nút **Biểu đồ / Bảng**.
- **Khóa sổ**: thanh tiến độ 12 ô (xong = màu nhấn, cần chạy lại / dừng = đỏ, bước tiếp theo = viền màu nhấn, chưa chạy = bước nhạt cùng dải); rê chuột hiện tên bước và trạng thái.
- **Báo cáo tiến độ sản xuất**: cột Hoàn thành có thanh nhỏ (nền nhạt cùng dải, phần hoàn thành màu nhấn) cạnh số %.
- **Sơ đồ thứ tự tính giá thành**: ô nền trắng viền mảnh, mũi tên nét mảnh; sản phẩm 1 giai đoạn tách bằng vạch dọc. Vạch nhánh ở Truy xuất đổi từ nét đứt sang nét liền.

### Đã kiểm tra (Playwright, Chromium)
- `__giagoc.selfTest()`: **1.216 tổ hợp, 0 lỗi**; số chính không đổi (doanh thu 225.990.000, giá vốn 154.605.503, z BTP 71.848,61, tồn kho 284.266.497).
- 1366×768 và 390×844, sáng và tối: chụp từng biểu đồ, rê chuột lên cột / đoạn / ô tiến độ thấy tooltip, focus bàn phím hiện tooltip, chuyển Bảng và lại Biểu đồ, chạy hết 12 bước khóa sổ, thu cửa sổ 1366 → 900 (biểu đồ vẽ lại). Không chữ chồng nhau trong SVG, không chữ ra ngoài panel, không nhãn % bị cắt, không cuộn ngang, không NaN / undefined, không pageerror / console error; mọi `border-radius` ≤ 2px và mọi `rx` / `ry` SVG ≤ 2.

## v3.3: giao diện phẳng

Theo phản hồi của người dùng (kế toán / vận hành): bỏ nhãn màu, màu sắc "kiểu AI" và bo góc. Chỉ đổi giao diện; engine, số liệu, ID, `window.__giagoc`, a11y và bản in giữ nguyên.

### Trạng thái: chữ thường, không nhãn
- Bỏ toàn bộ nhãn dạng viên thuốc / chip / con dấu (CSS `.pill`, `.chip`, `.chips`, `.stamp`, `.mini-stamp`, `.brand-mark` đã xóa). Trạng thái hiển thị bằng chữ thường, không nền, không viền: cam đậm cho tạm tính / cảnh báo, đỏ cho lỗi / lệch / tồn âm, xám cho đã hủy.
- Dòng Cộng của bảng bút toán (chi tiết chứng từ và xem trước trong form): chỉ "Cộng" và hai số tổng. Khi lệch, hai số tổng tô đỏ và có thêm chữ đỏ "Lệch X".
- Danh sách chứng từ: bỏ cột "Trạng thái". Chứng từ đã ghi sổ không hiện gì; ngoại lệ hiện ngay sau diễn giải: "tạm tính" (cam), "cần tính lại" (đỏ), "đã hủy" (cả dòng gạch ngang và chữ xám, riêng chữ "đã hủy" không gạch). Bỏ "Do bạn lập", "Hệ thống tự sinh", "Lùi ngày", "USD", "Thay PN…" (thông tin thay thế và nguyên tệ vẫn có trong phần chi tiết). Chi tiết chứng từ chỉ hiện trạng thái ngoại lệ ("giá vốn tạm tính"…).
- QC lô: "Đạt" (chữ thường), "Chờ" (cam), "Không đạt" (đỏ). HSD sắp hết: ngày màu cam; quá HSD: "Quá HSD …" màu đỏ.
- Đối chiếu kho – sổ cái, kết quả kỳ ở khóa sổ: "Khớp", "Cân", "Không" là chữ thường; chỉ "Lệch" / "N chỗ" màu đỏ. Báo cáo: bỏ "Khớp sổ cái", "Cân", "Từ 911", "Xong / Đang làm / Chưa"; chỉ hiện chữ đỏ "lệch sổ cái", "lệch", hoặc chữ cam "tạm tính từ số dư TK 5–8" khi có.
- Khóa sổ: số bước là chữ (không còn vòng tròn màu), cột phải "Xong" (xám), "Tiếp theo" (màu nhấn), "Dừng" / "Cần chạy lại" (đỏ). Bỏ con dấu tròn "ĐÃ KHÓA SỔ" và con dấu nhỏ trên thanh trên; thanh trên ghi "Kỳ 01/2026 Đang mở" / "Đã khóa sổ" bằng chữ thường.
- Việc cần làm: cột nhãn là chữ đậm thường (cam / đỏ khi là cảnh báo / lỗi), không nhãn màu; "Bước 5/12" chuyển vào nội dung dòng "Khóa sổ".
- Ô Ảnh hưởng, KPI, cơ cấu giá thành: chênh lệch hiện "+1.234" / "−1.234" chữ thường thay cho chip ▲▼.
- Bộ lọc chứng từ, lọc kho, lọc loại vị trí, chọn lô truy xuất: nút segmented vuông, phẳng. Gợi ý lý do hủy: nút nhỏ thường.

### Màu, bo góc, kiểu chữ
- Bảng màu doanh nghiệp: nền trang #f5f6f7, bề mặt trắng, chữ #1d2226, viền #d0d4d9 (đường kẻ hàng #e3e6ea); một màu nhấn xanh dương trầm #1f5fa8 (hover #184d8a) chỉ cho nút chính, liên kết, mục / dòng đang chọn, nút lọc đang bật; đỏ #b42318, cam đậm #9a5b00. Bỏ tím / indigo, mọi nền pastel (tím, mint, kem) và gradient. Dark mode trung tính (#16181b / #1e2124, nhấn #5b9ae0).
- Biểu đồ và cơ cấu giá thành: dải xanh dương – xám (navy #12355e, #1f5fa8, #6e9fd4, xám #56616c, #a4adb6), các đoạn ngăn bằng vạch 1px.
- Sidebar trắng có viền phải; mục đang chọn = vạch trái màu nhấn + nền xám nhạt, không bo. Màn hẹp: thanh menu ngang, mục chọn = vạch dưới. Bỏ ô "GG", chỉ giữ chữ "Giá Gốc".
- Bo góc ≤ 2px cho nút, ô nhập, select, bảng, panel, dialog, menu; 0 cho dòng bảng, mục menu, thanh. Bóng chỉ còn một bóng mảnh ở dropdown, dialog, toast, tour.
- Font hệ thống `"Segoe UI", system-ui, -apple-system, Roboto, "Helvetica Neue", Arial, sans-serif`; mã dùng `Consolas, ui-monospace, monospace`. Bỏ link Google Fonts. Nội dung 13–13,5px, tiêu đề trang 18px đậm vừa, tiêu đề panel 14px. Bảng: hàng ~31px, header nền xám chữ đậm, số canh phải tabular-nums. Panel viền 1px, không bóng, padding 12–14px; khoảng cách gọn hơn.
- KPI: khung vuông viền mảnh, nhãn chữ thường xám, số đậm, không nền màu.
- Thông báo lỗi / cảnh báo trong form: viền trái 3px màu ngữ nghĩa, không nền màu. Dòng bút toán khác nhau giữa TT 99 và TT 133: vạch cam bên trái thay cho nền vàng.
- Focus ring 2px màu nhấn, vuông. Màn ≤ 900px: tiêu đề trang dòng 1, kỳ / "Lập chứng từ" dòng 2.

### Đã kiểm tra (Playwright, Chromium)
- `node --check` phần script: đạt. `__giagoc.selfTest()`: **1.216 tổ hợp, 0 lỗi** (~15 giây); số chính không đổi (doanh thu 225.990.000, giá vốn 154.605.503, z BTP 71.848,61, tồn kho 284.266.497, lợi nhuận 71.462.497, TH0001 5.898.500).
- Thao tác giao diện thật (click / gõ / phím Enter trên phần tử nhìn thấy) ở **1366×768 và 390×844, sáng và tối: 4 × 93 bước, 0 lỗi**: mở 10 trang bằng menu; không cột "Trạng thái", không "Nợ = Có" ở dòng Cộng; lập phiếu nhập mua; hóa đơn bán 99.999 hũ bị chặn ("Xuất quá tồn", nút lưu khóa, Enter không lưu) rồi bán 10 hũ lưu được; hủy CT0001 → cả dòng gạch ngang, chữ "đã hủy" không nền / không viền / không gạch; có chữ "tạm tính" trong danh sách; In phiếu PN0001 → với `emulateMedia('print')` chỉ còn PHIẾU NHẬP KHO PNK-2601001; "Chạy tất cả" khóa đủ 12 bước, 12 "Xong", thanh trên "Đã khóa sổ" chữ thường; 10 trang sau khóa sổ. Mọi trang: không pageerror / console error, không NaN / undefined, không cuộn ngang, không phần tử `.pill/.chip/.badge/.stamp/.tag`.
- `getComputedStyle` mọi phần tử hiển thị (cả khi mở menu "Lập chứng từ", form phiếu nhập, tour, hộp QC lô): **không phần tử nào có border-radius > 2px**.

## v3.2: theo dõi theo vị trí chứa và mã hóa

Theo file Excel sổ kho BTP của nhà máy Bà Ba Thạo và yêu cầu "hàng tồn kho theo dõi: tên hàng + mã lot + mã hóa + bồn/trái/phuy". Đối chiếu tính năng file → yêu cầu: `docs/YEU-CAU-KHACH-HANG.md` §9; dữ liệu và DDL: `docs/research/07-…` §2.8. Không thêm chữ giải thích trên giao diện.

### Engine
- **Vị trí chứa** = khu + loại (Bồn / Trái / Phuy) + số, theo kho (`D.locs`, 31 vị trí mẫu ở nhà máy: 26 bồn khu A, B, C, 2, 4; `2.Trái`, `5.Trái`; `5.Phuy`, `A.Phuy`, `B.Phuy`). Ký hiệu `A.15`, `5.Trái`, `B.Phuy`; khi khai vị trí mới nhận các biến thể ghi tay (`c. 12`, `2. trái`, `B.phuy`) và chuẩn hoá, chặn bồn thiếu số (`A.`).
- `valuate` giữ thêm ô số lượng `lcells` theo **(kho, lô, vị trí)**; **tồn âm kiểm theo ô này** (xuất vượt tồn của một bồn bị báo dù cả lô còn hàng). Giá trị vẫn theo ô (kho, lô): vị trí chỉ chia số lượng; giá trị theo vị trí trong bảng tồn = giá trị lô phân bổ theo SL (R1 b), chỉ để hiển thị.
- Dòng phiếu mang `loc` (CK thêm `locTo`); hàng trả lại về đúng lô và vị trí của dòng hoá đơn gốc. **Chuyển vị trí trong cùng kho** bằng phiếu CK (`whTo = wh`, vị trí đến khác vị trí đi); không bút toán; N-X-T theo kho không tính chuyển nội bộ cùng kho. BTP bắt buộc chọn vị trí ở kho có danh mục vị trí.
- Một lô nằm ở nhiều vị trí: nhiều dòng cùng mã lô trong một phiếu nhập; lô gộp SL / giá trị các dòng; thẻ giá thành gộp lô nhập kho theo mã lô (trước đây mỗi dòng một lô).
- **Mã lô** theo sổ kho: `DDMMYY-nn` (ngày + số mẻ trong ngày), tự gợi ý, sửa được, kiểm trùng toàn công ty (cả lô của phiếu đã huỷ), không cấp lại. Dữ liệu mẫu đổi sang định dạng này (`NL-CL-260105-01` → `050126-01`…).
- **Mã hóa** (theo cập nhật của người dùng: mã tự sinh): hệ thống cấp khi tạo lô (phiếu nhập mua, nhập kho SX, kiểm kê thừa ngoài sổ) = nhóm hàng + YYMM + số thứ tự 4 chữ số (`BTP-2601-0003`, `PG-2601-0005`); duy nhất, không sửa, không đổi khi chuyển kho / chuyển bồn, không cấp lại; sửa phiếu giữ mã hóa cũ. Mọi lô mẫu có mã hóa. Không còn nhập tay hay cảnh báo "kiểm tra mã lot".
- Vật tư thêm **Mã MISA** (mã giả định) và **Tồn tối thiểu**; số **phiếu kho** `PNK-YYMMnnn` (PN, NK, TL) / `PXK-YYMMnnn` (PX, HD, CK) cấp theo tháng, lưu trên chứng từ; **lý do xuất** suy ra từ loại chứng từ (Sản xuất, Bán hàng, Chuyển kho Bình Tây, Chuyển kho 97, Chuyển vị trí, Khác).
- Dữ liệu mẫu: tồn đầu lô BTP `261225-01` ở 2 bồn (A.15, A.26); NK0001 vào A.27 + A.28; NK0002 vào A.29; thêm **CK0003** chuyển 400 kg lô `240126-01` từ A.29 sang A.30 (37 chứng từ); muối ở `5.Phuy`, tôm ở `5.Trái`; tên BTP đổi thành "BTP Cá linh ủ thính". Key lưu trữ đổi sang `giagoc-demo-v32` (dữ liệu v3.1 đã lưu bị bỏ qua).

### Giao diện
- Kho & lô: bảng **Tồn kho chi tiết** (thay "Tồn kho theo kho và lô"): Tên hàng · Mã lô · Mã hóa · Vị trí · Kho · HSD · QC · SL tồn · Số ngày lưu kho · Giá trị; lọc kho (dùng chung với N-X-T), lọc loại vị trí (Tất cả / Bồn / Trái / Phuy / Chưa xếp), ô tìm theo tên, mã lô, mã hóa, vị trí; dòng cộng theo tên hàng.
- Phiếu xuất SX, hoá đơn, chuyển kho: chọn **"Lô (mã hóa) · Vị trí · tồn"**, gợi ý HSD gần nhất rồi lô cũ nhất, cột "Tồn tại vị trí". Chuyển kho có cột "Vị trí đến", cho phép kho đến = kho đi.
- Phiếu nhập mua: cột Mã lô (sửa được), Mã hóa (chỉ đọc), Vị trí chứa + nút "+ Vị trí" (cùng lô sang vị trí khác). Nhập kho SX: ô Mã lô, bảng Vị trí chứa / SL đạt + "+ Vị trí", mã hóa hiện trong phần tóm tắt.
- Kiểm kê theo lô và vị trí: SL sổ, SL kiểm kê, chênh lệch, **% chênh lệch**, giá trị; hàng thừa ngoài sổ chọn vị trí.
- Chi tiết chứng từ: số phiếu kho, lý do xuất, cột Mã hóa và Vị trí (CK: đi → đến; KK: sổ · đếm · %); nút **In phiếu** (PNK / PXK) in bằng `window.print()`; bản in ở `#printArea` chỉ hiện với `@media print`: "Nhà máy chế biến mắm", PHIẾU NHẬP / XUẤT KHO, ngày, số phiếu, chứng từ, kho, lý do xuất / lệnh SX / đối tượng, bảng STT · Tên hàng · Lot · Mã hóa · Vị trí · ĐVT · Số lượng · Ghi chú, chữ ký Người lập phiếu · Người giao (nhận) hàng · Thủ kho.
- Danh sách chứng từ hiện số phiếu kho dưới số chứng từ; tìm được theo số phiếu kho, mã hóa, vị trí.
- Danh mục: cột Mã MISA, Tồn tối thiểu, Tồn hiện tại (+ "Cần đặt thêm"); bảng **Vị trí chứa** (kho, ký hiệu, loại, khu, số, sức chứa, đang chứa lô nào) và form "+ Vị trí chứa" (cũng có trong menu "+ Lập chứng từ"). Tổng quan → Việc cần làm: "**Cần đặt thêm**" khi tồn ≤ tối thiểu (mẫu: đường 50/50 kg, gia vị 7/10 kg).
- Báo cáo mới: **N-X-T theo lô và vị trí** (khoảng ngày trong kỳ, lọc kho) và **Sổ chi tiết mặt hàng theo lô và vị trí** (tồn theo ô và tồn tổng, cột phiếu kho, mã hóa).
- Giá xuất kho, truy xuất: hiện vị trí và mã hóa của lô. Tour bước 3 trỏ vào Tồn kho chi tiết.

### Đã kiểm tra (Playwright, Chromium, chặn font)
- `node --check` phần script: đạt. `__giagoc.selfTest()`: **1.216 tổ hợp, 0 lỗi** (~16 giây) = 2 chế độ × 4 phương pháp × giờ máy 800/1200 × dở dang mặc định/0 × **19 biến thể** × mở/khóa. 4 biến thể mới: `lot2loc` (một lô nhập vào A.16 + A.17, xuất từ một bồn), `move` (chuyển bồn A.30 → A.16 trong cùng kho rồi xuất từ bồn mới), `negLoc` (xuất 500 kg từ A.30 chỉ có 400 kg trong khi lô còn 1.200 kg → phải báo tồn âm đúng bồn, thiếu 100, bước tiếp theo là 4, không khóa được), `kkLoc` (kiểm kê thiếu ở A.29, thừa ở A.30). Bất biến mới ở mọi tổ hợp: Σ SL theo vị trí = SL ô (kho, lô); không vị trí nào âm ở biến thể hợp lệ. Thêm kiểm: form CK chặn vị trí đến trùng vị trí đi; form PN chặn mã lô trùng; mã hóa tự sinh đúng dạng, hai dòng cùng lô cùng mã hóa, lô khác mã hóa khác; mọi lô có mã hóa và không trùng. Bất biến cũ giữ nguyên (Nợ = Có, kho = sổ cái 152/154/155/156, Zt = DDĐK + C − DDCK, Z = Zt − hỏng, Σ lô = Z…).
- Số chính **không đổi** so với v3.1: doanh thu 225.990.000, giá vốn 154.605.503, z BTP 71.848,61, ML5 44.597,95, MT2 39.371,15, 154 = 23.426.252, tồn kho 284.266.497, lợi nhuận 71.462.497, TH0001 5.898.500.
- Độ nhạy của selfTest (bản sửa hỏng tạm): kiểm âm theo lô thay vì theo vị trí → 192 lỗi; chuyển bồn ghi về vị trí đi thay vì vị trí đến → 480 lỗi.
- Thao tác giao diện thật (click / gõ / chọn / phím Enter trên phần tử nhìn thấy; không gọi `__giagoc`), **1366×768 và 390×844, mỗi khung 41/41 bước đạt** + 5 bước bổ sung: Tổng quan thấy "Cần đặt thêm"; lập phiếu nhập kho SX lô `310126-01` vào 2 bồn A.16 (500) và A.17 (300) bằng "+ Vị trí", thấy mã hóa tự sinh `BTP-2601-0003` không có ô sửa; phiếu nhập mua thấy mã hóa `PG-2601-0005` chỉ đọc; phiếu nhập mua một lô vào `5.Phuy` + `A.Phuy` qua "+ Vị trí"; Tồn kho chi tiết thấy 2 dòng cùng lô khác vị trí; tìm tồn theo mã hóa ra đúng 2 dòng của lô; lọc Phuy; chuyển bồn A.16 → A.18 bằng CK (sau đó A.16 = 400, A.17 = 300, A.18 = 100); xuất 250 kg từ A.18 bị chặn với thông báo "Xuất quá tồn … vị trí A.18 … thiếu 150 kg", phiếu không lưu; tìm chứng từ theo mã hóa ra NK0006 và CK0004; kiểm kê A.16 sổ 400 đếm 390 → "thiếu 10 · −2,5%", lưu được; In phiếu NK0006 → với `emulateMedia('print')` chỉ còn bản in PHIẾU NHẬP KHO `PNK-2601014`, 2 dòng A.16 / A.17, mã hóa, chữ ký; 2 báo cáo mới có dữ liệu; "Chạy tất cả" khóa đủ 12 bước; thêm vị trí "c. 12" → `C.12`, "A." bị chặn; sửa tồn tối thiểu hũ 250g = 900 → Tổng quan báo cần đặt thêm. 10 trang trước và sau khóa sổ, 2 báo cáo mới, 15 form: không pageerror / console error, không NaN / undefined, `scrollWidth ≤ innerWidth`.
- DDL §2.8 của `research/07` chạy trên PostgreSQL 16 với bộ giả lập tối thiểu: 8 phép thử đạt (CHECK bồn thiếu số, UNIQUE ký hiệu, cột `code` sinh ra, FK vị trí đúng kho, bắt buộc vị trí, bộ đếm mã hóa theo tháng, mã hóa bất biến / duy nhất, `stock_balances` theo vị trí, RLS hai tenant).

### Giả định chưa xác minh (chờ khách, §9.7 tài liệu yêu cầu)
- Ý nghĩa và định dạng mã hóa (đang là đề xuất mã tự sinh); mã lô duy nhất toàn công ty hay theo mặt hàng; quy tắc số phiếu kho (file có cả `PXK-0126-001` và `PNK-2609001`).
- Danh mục bồn / trái / phuy đầy đủ và sức chứa; "trái" là gì; ký hiệu không dấu chấm (`H1`, `MA1`…); kho Bình Tây / 97 có theo vị trí không (demo: không có vị trí).
- Chỉ BTP bắt buộc chọn vị trí; NVL, bao bì, thành phẩm để "chưa xếp" được. Mã MISA trong dữ liệu mẫu là mã giả định.

## v3.1: giao diện gọn

Theo yêu cầu người vận hành: bỏ hết câu chữ giải thích, thiết kế lại cho gọn, dễ thao tác. Engine, công thức tính và `selfTest()` không đổi.

### Đã xóa
- 11 đoạn mở đầu `<p class="lead">` ở mọi trang.
- Thanh "Kịch bản demo" (`#scen`, `SCEN`, `runScen`, `data-scen*`, CSS, `runScen` trong `window.__giagoc`), nhãn "Bản demo", dòng "Demo cho quy trình…", "(dữ liệu mẫu · bản demo)" ở chân sidebar.
- Nút và hộp "Chú giải thuật ngữ" (giữ `<abbr title>`), phụ đề mô tả trong menu "+ Lập chứng từ", phụ đề thương hiệu.
- Các ghi chú `.note` / `msg info` chỉ mang tính giải thích, tĩnh và sinh bằng JS: ghi chú danh mục, kho, giá thành, khóa sổ; ghi chú dòng đối chiếu và `reconNote`; `whNote`, `nxtNote`, `lotNote`; ghi chú biểu đồ; ghi chú chi tiết chứng từ (hủy, chế độ, PX BTP, 413, sửa/hủy, chứng từ hệ thống, nút "Xem PX0001 / BL0001"); ghi chú trong 8 báo cáo; ghi chú `#explain` (R1, đích danh, BQ, FIFO, chuyển kho, "đi tiếp vào giá thành"); ghi chú truy xuất; `VAT_NOTE` và `BTP_NOTE` cùng mọi nơi dùng; ghi chú trong form PN, PX, HD, TL, CK, KK, CT, BL, KH, NK, ITEM, LSX, QC lô, hủy, mở khóa, đặt lại; ghi chú phím tắt trong tour; câu "bản demo…" trong tooltip Chế độ / Giá xuất, toast đổi phương pháp, checkbox mở khóa.
- Đoạn "Vì sao phải đúng thứ tự" và 2 mục "Thử" ở trang Khóa sổ.
- Người thực hiện trong nhật ký đổi từ "Khách demo" sang "Người dùng" / "Kế toán trưởng".
- Grep phần hiển thị (mọi trang, 14 form, 8 báo cáo, cả `title` / `aria-label`): không còn "bản demo", "Demo cho", "chưa làm", "chưa xác minh", "R1(", "Kịch bản"; "dữ liệu mẫu" chỉ còn ở nút / hộp xác nhận / toast "Đặt lại dữ liệu mẫu".

### Cố ý giữ (dữ liệu, trạng thái, thông báo)
- Đơn vị "triệu đồng" của biểu đồ, `docCount`, "loại X" trên dòng NK, công đoạn / hao hụt trong danh mục và ghi chú lệnh SX, "Đối tượng tập hợp chi phí" và định mức trong form PX, "Số chứng từ sẽ cấp", số giờ công suất (rút gọn "/ 1.000 giờ công suất · dưới 20%"), "Đã trừ X đ hỏng ngoài định mức … vào 632".
- Dòng kiểm tra thẻ giá thành rút còn công thức số `DDĐK + C − DDCK − hỏng = Z: …`.
- Pill trạng thái: Cân / Lệch (cân đối phát sinh), Từ 911 / Từ số dư TK 5–8 (KQKD), Khớp / Lệch sổ cái (sổ cái, công nợ); tiêu thức phân bổ rút còn "Tiêu thức: NCTT · BTP-CL 57,1% · …".
- Mọi thông báo lỗi / cảnh báo / thông tin sinh theo dữ liệu (tồn âm, lệch đơn giá, lùi ngày, giá vốn tạm tính, bán dưới giá vốn, tiền mặt ≥ 5 triệu…) và toast kết quả.
- `#explain`: công thức số và bảng nguồn; dòng mô tả đổi thành bảng nhỏ (Diễn giải, SL, Giá trị, Đơn giá).
- Tour: không tự bật nữa, mở bằng nút "?" trên thanh trên; 10 bước vẫn trỏ đúng phần tử đang có.

### Đổi giao diện
- Bố cục fluid: bỏ `max-width` vùng nội dung. Sidebar 220px, thu gọn còn 64px chỉ icon (nút "‹" cạnh logo, nhớ bằng `localStorage['giagoc-side']`, bọc try/catch). ≤1080px sidebar thành menu ngang; ≤900px thanh trên gói Chế độ / Giá xuất / Sáng-tối / Đặt lại vào nút "Thiết lập".
- Thanh trên 1 dòng, sticky (cao 57px ở 1366 và 1920): tiêu đề trang · Kỳ 01/2026 + Đang mở / Đã khóa · Chế độ · Giá xuất · "?" · "+ Lập chứng từ".
- Chân sidebar: "Nhà máy chế biến mắm", nút sáng/tối dạng icon, "Đặt lại dữ liệu mẫu" dạng nút chữ nhỏ.
- Tổng quan: 4 ô KPI (số lớn + 1 dòng phụ ngắn); "Việc cần làm" 1 dòng / mục có nút hành động (Khóa sổ, Xem lô, Giá thành, Mở PX…, Mở khóa); biểu đồ; đối chiếu kho – sổ cái (cột "Sổ kho", tên TK xuống dòng, không bị cắt cột ở 1366+); cơ cấu giá thành. Lưới 2 cột tự co giãn (`minmax(max(480px, 50%), 1fr)`), KPI `auto-fit`.
- Kho & lô: bộ lọc kho thành segmented control (Tất cả / BBT / BT / NTH) trong header bảng N-X-T, bỏ panel riêng. Bộ lọc chứng từ, nút Excel đưa vào header bảng.
- Bảng: header sticky trong vùng cuộn (`thead` sticky, `max-height: 100vh − 150px`), hàng ~34px, số canh phải + tabular-nums, dòng cộng nổi nhẹ, hover rõ; cột đầu sticky khi cuộn ngang ở ≤1080px. "Sao chép cho Excel" thành nút nhỏ "Excel" có icon, `aria-label` "Sao chép … cho Excel".
- Chi tiết chứng từ: nút Nguồn đơn giá / Sửa / Hủy / Excel lên đầu panel. Khóa sổ: panel bên là "Kết quả kỳ" (tiến độ, Nợ = Có, kho – sổ cái, tồn âm, doanh thu, giá vốn, lãi gộp, lợi nhuận).
- Form drawer rộng 1080px, trường xếp lưới tự co (3 cột desktop, 1 cột mobile), footer luôn thấy và không xuống dòng; "Bút toán & ảnh hưởng dự kiến" gói trong `<details>` đóng sẵn (tiêu đề hiện tổng tiền), lỗi chặn lưu vẫn hiện ngay. Hộp hủy chứng từ và ô "Ảnh hưởng" cũng gập danh sách chứng từ tính lại.
- Một màu nhấn, viền nhẹ, khoảng cách lưới 8px, giữ token sáng / tối.

### Đã kiểm tra (Playwright, Chromium, chặn font)
- `node --check` phần script: đạt. `__giagoc.selfTest()`: 960 tổ hợp, 0 lỗi; số chính trùng v3 (doanh thu 225.990.000, giá vốn 154.605.503, z BTP 71.848,61, ML5 44.597,95, MT2 39.371,15, 154 = 23.426.252, tồn kho 284.266.497, lợi nhuận 71.462.497).
- 1920×1000, 1366×768, 390×844, 10 trang: 0 pageerror / console error, không "NaN" / "undefined", `scrollWidth ≤ innerWidth` ở mọi trang; vùng nội dung lấp 100% phần còn lại sau sidebar (cả khi thu gọn); bảng đối chiếu không cắt cột ở 1366 và 1920.
- Kiểm tra bằng thao tác giao diện thật (chỉ click / gõ / chọn trên phần tử nhìn thấy), 1920×1000 và 390×844: 48/48 bước đạt — mở 10 trang từ menu; lập PN, PX, NK, CK, HD, TL, KK, CT qua "+ Lập chứng từ" và thấy trong danh sách; để trống số lượng và bán vượt tồn đều báo lỗi, không lưu; sửa (lý do) và hủy chứng từ qua nút; "Chạy tất cả" khóa đủ 12 bước, lập chứng từ khi khóa bị chặn, mở khóa qua hộp thoại; đổi Chế độ và Giá xuất trên thanh trên; lọc kho NTH; chọn vật tư, bấm dòng xuất xem nguồn giá; tour 10 bước bằng nút "?"; sáng / tối; thu gọn sidebar (64px, nhớ sau khi tải lại).

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
