# Giá Gốc demo v2: nhật ký thay đổi

Tệp: `gia-goc-demo.html`. Vẫn là một file, vanilla JS, không dùng script ngoài. Bản v1 được sao lưu tại scratchpad (`gia-goc-demo.v1.bak.html`).

## v2.1: tour hướng dẫn và thêm vật tư mới

Số liệu bộ mẫu không đổi (giá vốn 136.230.331, biên 26,5%). Dòng `<meta name="viewport">` đã bị người điều phối gỡ; bản này không thêm lại.

### Tour hướng dẫn
- Có 10 bước, popover neo vào phần tử thật trên trang:
  1. KPI
  2. Đối chiếu kho với sổ cái
  3. Đổi phương pháp giá
  4. Sổ chi tiết và phiếu xuất PX0004
  5. Nguồn gốc đơn giá
  6. Nút lập phiếu nhập lùi ngày, giải thích ô "Ảnh hưởng"
  7. Thẻ giá thành
  8. Truy xuất giá thành
  9. Chứng từ và TT 99 / TT 133
  10. Khóa sổ và mở khóa có lý do
- Tour tự chuyển trang, chọn sẵn đối tượng (KEO, PX0004) và cuộn phần tử vào tầm nhìn.
- Phần tử đang nói tới có khung sáng, phần còn lại của trang bị làm mờ nhưng vẫn bấm được.
- Popover có mũi tên chỉ vào phần tử, nút Quay lại / Tiếp / Bỏ qua và chỉ số "Bước 3/10".
- Bàn phím: ← → để chuyển bước, Esc để đóng. Mỗi bước, focus chuyển vào popover (`role=dialog`, có `aria-labelledby` và `aria-describedby`). Khi đóng, focus trả về nút "Hướng dẫn".
- Ở bề rộng ≤760px, popover thành sheet dưới đáy màn hình. Nếu bước cần ô thiết lập, tour tự mở rồi tự đóng lại ô này. Tôn trọng prefers-reduced-motion: cuộn tức thì, không chuyển động.
- Tour tự mở ở lần đầu (`localStorage['giagoc-tour-v1']`, bọc try/catch). Nếu storage lỗi thì không tự mở. Nút "Hướng dẫn" luôn hiện trên thanh trên; trên điện thoại nút thu thành "?".

### Thêm vật tư mới
- Trang mới **Danh mục vật tư**, và mục "Thêm vật tư, hàng hóa, sản phẩm" trong menu "+ Lập chứng từ".
- Form dạng drawer gồm:
  - Loại: NVL (152), hàng hóa (156) hoặc sản phẩm (155). Không có công cụ dụng cụ 153 vì engine chưa xử lý phân bổ.
  - Mã tự gợi ý từ chữ đầu của tên, có kiểm tra định dạng và trùng mã.
  - Tên (kiểm tra trùng), ĐVT, kiểu số lượng (số nguyên hoặc số lẻ), kho mặc định, thuế suất GTGT, giá bán mặc định (cho hàng hóa và sản phẩm).
  - Tồn đầu: số lượng và giá trị phải đi cùng nhau.
  - Với sản phẩm: định mức NVL 1 cấp.
- Engine:
  - Thêm loại hàng hóa (TK 156), định giá theo cả 3 phương pháp; với bình quân cuối kỳ, giá chốt ở bước 8.
  - Tồn đầu được cộng vào số dư đầu 152 / 155 / 156. Bảng đối chiếu có thêm dòng 156; N-X-T có thêm nhóm "Cộng TK 156".
  - Phiếu nhập, hóa đơn, hàng trả lại, kiểm kê hạch toán vào đúng TK kho theo loại vật tư.
- Vật tư mới hiện ngay trong mọi chỗ chọn vật tư:
  - Phiếu nhập: NVL và hàng hóa.
  - Phiếu xuất: NVL; sản phẩm mới làm đối tượng tập hợp chi phí.
  - Hóa đơn và hàng trả lại: sản phẩm và hàng hóa.
  - Cả kiểm kê, sổ chi tiết, N-X-T, thẻ giá thành, truy xuất.
- Form mới **Nhập kho sản phẩm hoàn thành** (NK), để sản phẩm mới có giá thành. Giá trị nhập kho lấy từ Z.
- Phiếu xuất có nút "Điền vật tư theo định mức": nhập số sản phẩm định sản xuất, hệ thống điền số lượng NVL. Hai sản phẩm mẫu BG và GG đã có định mức suy từ số liệu thực tế.
- Quy tắc sửa và xóa:
  - Sửa vật tư được ghi vào nhật ký với các trường đổi, dạng "trước → sau".
  - Vật tư đã có phát sinh (kể cả chứng từ đã hủy) hoặc đang nằm trong định mức của sản phẩm khác thì không xóa được, và không đổi được loại, ĐVT.
  - Xóa vật tư phải xác nhận trong trang và được ghi nhật ký.
  - Kỳ đã khóa: vẫn thêm vật tư hoặc sửa tên được, nhưng không khai hay sửa tồn đầu (ô bị vô hiệu, và bước kiểm tra cũng chặn).
- Dữ liệu vật tư nằm trong dữ liệu đã lưu; "Đặt lại dữ liệu mẫu" xóa sạch (đã kiểm tra: danh mục trở về 5 mã, key storage bị xóa).

### Đã kiểm tra thật (v2.1)
- `scratchpad/sim2.py`: viết lại tổng quát, chạy 144 tổ hợp, 0 lỗi. Gồm bộ mẫu và bộ có vật tư mới: ván MDF có tồn đầu; khóa tủ 156, VAT 8%, có bán, trả lại và kiểm kê thiếu; tủ gỗ có xuất NVL, nhập kho, dở dang và bán. Mỗi bộ chạy 2 chế độ × 3 phương pháp × 3 mức giờ máy × 2 mức dở dang × mở/khóa sổ. Kiểm tra Nợ = Có, kho = sổ cái 152/155/156/154, Z = DDĐK + C − DDCK, TK 5–8 về 0.
- Kịch bản vật tư mới: số liệu JS (`compute`) và Python khớp từng đồng ở cả trạng thái mới mở và đã khóa sổ (doanh thu 202.350.000, giá vốn 143.706.760 và 143.726.523, TK 156 = 3.255.000, Z tủ = 6.797.143).
- Chrome, qua `python -m http.server`:
  - `selfTest()` chạy 864 tổ hợp, 0 lỗi (thêm 2 biến thể vật tư mới), không có lỗi console.
  - Form vật tư chạy qua sự kiện DOM: thêm NVL có tồn đầu, hàng hóa, sản phẩm có định mức; báo trùng mã và tên; vật tư mới có trong các ô chọn; phiếu xuất theo định mức; nhập kho; bán hàng hóa với giá và VAT mặc định.
  - Đổi qua 3 phương pháp: vẫn khớp sổ cái và Nợ = Có.
  - Đã kiểm: sửa tên ghi nhật ký; không xóa được vật tư đã có phát sinh; xóa vật tư chưa có phát sinh làm số dư đầu 152 giảm đúng 50.000; khi kỳ khóa không khai được tồn đầu; đặt lại dữ liệu xóa sạch.
  - Tour: tự mở lần đầu, không mở lại sau khi đã xem; đi đủ 10 bước bằng phím →; ← quay lại; Esc đóng và trả focus về nút. Khung sáng khớp vị trí phần tử (lệch 6px, đúng phần đệm).
  - Trong iframe 390px: popover thành sheet rộng hết màn hình, nằm dưới đáy; không cuộn ngang được (scrollX = 0) ở trang Danh mục vật tư và N-X-T; drawer không tràn ngang.

### Chưa làm hoặc giới hạn (v2.1)
- Chưa có công cụ dụng cụ 153 và định mức nhiều cấp. Định mức chưa so với thực tế tiêu hao trên thẻ giá thành.
- Sản phẩm mới chưa có lương công nhân trực tiếp riêng (bảng lương chỉ có BG/GG), nên không nhận phân bổ SXC; giá thành của nó chỉ gồm NVL.
- Trên desktop, với phần tử cao hơn màn hình (cây truy xuất, chi tiết chứng từ), popover nằm ở đáy màn hình và có thể che một phần phần tử.
- Ảnh chụp ở 390px được lấy từ iframe dựng tạm để test, không phải thiết bị thật.

---

## Số chính v2 (kịch bản mặc định: TT 99, bình quân cuối kỳ, 800 giờ máy, bàn dở dang 20)
| | Mới mở (bước 1–4 xong) | Sau khi khóa sổ |
|---|---|---|
| Doanh thu thuần | 185.400.000 | 185.400.000 |
| Giá vốn | 136.230.331 | 136.250.094 |
| Lãi gộp / biên | 49.169.669 / 26,5% | 49.149.906 / 26,5% |
| z bàn BG-01 / ghế GG-02 | 467.234,28 / 132.102 | 467.360,54 / 132.102 |
| Sổ cái 154 | 5.906.566 | 5.909.091 |

Giá bán đổi thành bàn 650.000 và ghế 180.000. Biên lịch sử 08–12/2025 được chỉnh về 25–26%. Tồn đầu sản phẩm được chỉnh về gần giá thành mới (bàn 460.000, ghế 130.000).

## 1. Dữ liệu và engine
- Có `SEED`, gồm danh mục vật tư (mỗi mục có thuế suất GTGT riêng), dịch vụ, NCC/khách hàng, số dư đầu, thiết lập, mảng chứng từ (`type`, `status`, `lines`, `replaces`, `voidedBy`…), nhật ký và trạng thái khóa sổ.
- `deriveMoves()` sinh lại dòng kho từ chứng từ. Các số sau đều được tính ra, không gõ cứng: doanh thu, số lượng bán, số dư đầu sổ cái, số lượng hoàn thành, mã lô, số chứng từ (`nextNo`) và số hóa đơn điện tử.
- Dữ liệu lưu vào `localStorage['giagoc-demo-v2']`; mọi lần đọc/ghi đều bọc try/catch. Có nút "Đặt lại dữ liệu mẫu" kèm hộp xác nhận ngay trong trang. View không được lưu nên link luôn mở ở Tổng quan.
- `valuate()`:
  - Bình quân tức thời không còn chia cho 0.
  - Cả 3 phương pháp đều báo tồn âm theo ngày (`negatives`).
  - FIFO định giá phần thiếu theo lô gần nhất, không còn để 0 đ.
  - Có xử lý hàng bán trả lại.
- Làm tròn theo một quy tắc chung: mỗi phần làm tròn đến đồng, phần dư dồn vào phần cuối. Với bình quân cuối kỳ thì phần dư nằm ở tồn cuối, còn khi tồn cuối bằng 0 thì dồn vào phiếu xuất cuối. Quy tắc này áp dụng cho phân bổ SXC, phiếu nhập kho, cây truy xuất và lương.
- C1/C4: KC0001 luôn được sinh ra, theo khoản mục (NVL/NC/SXC × sản phẩm). Trạng thái đi theo thứ tự Tạm tính → Đã chốt → Cần tính lại (hiện số đã chốt → số hiện tại). Chứng từ không bao giờ biến mất và sổ cái 154 không âm.
- Bảng đối chiếu, "Việc cần làm" và bước 11 dùng chung một hàm `reconcile()`.
- C2:
  - Bước 9 sinh TH0001: Nợ 33311 / Có 1331.
  - Bước 10 sinh KQ0001: kết chuyển TK loại 5–8 sang 911, rồi 911 sang 4212 (ghi rõ là chưa tính thuế TNDN).
  - Bước 11 kiểm tra thật: Nợ = Có, kho = sổ cái, TK 5–8 không còn số dư.
  - Bước 4 dừng khi có tồn âm và chỉ ra phiếu gây tồn âm.
- C3: thuế suất GTGT theo từng dòng hàng (0/5/8/10%, mặc định 10%), có ghi chú "Thuế suất theo cấu hình — kiểm tra chính sách giảm thuế GTGT hiện hành".
- Tên TK theo chế độ:
  - TT 99: 155 "Sản phẩm", 5112 "Doanh thu bán sản phẩm", 242 "Chi phí chờ phân bổ".
  - TT 133: dùng tên cũ. BHTN là 3386 (TT 99) và 3385 (TT 133).
- T5: bảng lương có trích theo lương 23,5% (3383/3384/BHTN/3382). Khoản này được tính vào NCTT và SXC.
- L5: vật tư phụ 4.500.000 + VAT 10%, trả tiền mặt (dưới 5 triệu). Form cảnh báo khi trả tiền mặt từ 5 triệu trở lên.

## 2. Thao tác khách tự làm (drawer `<dialog>`, không dùng alert/confirm/prompt)
- Phiếu nhập mua: nhiều dòng, cho lùi ngày, cảnh báo đơn giá lệch quá 50%, thêm NCC mới (kiểm tra định dạng MST), hiện tồn tại ngày.
- Phiếu xuất cho sản xuất: chặn khi tồn âm (kiểm tra cả các phiếu sau ngày đó). Có ô "Vẫn lưu" để thử cơ chế kiểm soát khi khóa sổ.
- Hóa đơn bán: hiện giá vốn dự kiến, lãi gộp từng dòng, cảnh báo bán dưới giá vốn; có thể thêm khách hàng mới.
- Hàng bán bị trả lại: theo dòng hóa đơn gốc, giới hạn số lượng còn được trả, nhập lại kho theo giá vốn lúc bán.
- Kiểm kê: K1 hoặc K2, xử lý hàng thiếu qua 1381 hoặc 632, hàng thừa qua 3381.
- Bảng lương, khấu hao (cảnh báo trùng), chi phí SXC khác (loại dịch vụ, cố định/biến đổi, thuế suất).
- Hủy và sửa chứng từ:
  - Sửa nghĩa là hủy chứng từ cũ rồi lập chứng từ mới có `replaces`.
  - Lý do sửa/hủy bắt buộc, ít nhất 10 ký tự.
  - Chặn hủy hóa đơn đã có phiếu trả lại; cảnh báo khi việc hủy làm tồn âm.
  - Chứng từ đã hủy vẫn hiện, gạch ngang.
  - Có trang "Nhật ký sửa đổi".
- Kỳ khóa chặn mọi form và thiết lập, kèm tooltip và thanh báo. Mở khóa cần xác nhận vai trò kế toán trưởng và lý do ít nhất 15 ký tự, rồi ghi nhật ký.
- Mỗi form có bảng xem trước bút toán, chuyển được giữa TT 99 và TT 133, và ô "Ảnh hưởng dự kiến" (trước → sau). Sau khi lưu, ô "Ảnh hưởng" giữ nguyên chip chênh lệch và danh sách phiếu được tính lại (bấm vào để mở). KPI cũng có chip chênh lệch.
- `invalidate()` theo loại chứng từ: hóa đơn từ bước 8, phiếu nhập/xuất từ bước 4, chi phí từ bước 3, kiểm kê từ bước 2. Đổi giờ máy, dở dang hoặc phương pháp cũng đánh dấu đúng các bước bị ảnh hưởng.
- "Sao chép cho Excel" ở danh sách chứng từ, bút toán, N-X-T, sổ chi tiết, thẻ giá thành và nhật ký. Dùng `navigator.clipboard` trong click handler; nếu bị chặn thì mở hộp có textarea đã chọn sẵn.

## 3. Báo cáo và giao diện
- Thẻ giá thành dạng ma trận: DDĐK / phát sinh / giảm giá thành / DDCK / Z / z × Tổng, NVL, NC, SXC.
- Sổ chi tiết S10 có cột TK đối ứng, đơn giá và đầu sổ (TK, kho, ĐVT).
- N-X-T cộng riêng 152 và 155 rồi mới đến tổng.
- Số âm hiển thị trong ngoặc đơn.
- Thanh "Kịch bản demo" 5 bước, có dấu ✓ cho bước đã xem, tô sáng chỗ cần bấm. Trên điện thoại thu lại thành "Bước n/5 ‹ ›".
- Trạng thái giá tạm/chốt thống nhất theo phương pháp:
  - Phiếu xuất "tạm" chỉ khi dùng bình quân cuối kỳ và chưa chạy bước 5.
  - Phiếu nhập kho và hóa đơn ghi "Giá thành/Giá vốn tạm tính" cho tới bước 7/8.
  - Thẻ so sánh phương pháp ghi "dự kiến … (đang hiển thị giá tạm …)".
- Trang Chứng từ:
  - Tô vàng các dòng TK khác nhau giữa TT 99 và TT 133, kèm ghi chú TK của chế độ kia.
  - Khi đổi chế độ mà chứng từ đang chọn không có khác biệt thì tự chọn PX0004.
  - Có tìm kiếm và chip lọc (tạm tính, do bạn lập, đã hủy).
- Giữ focus bàn phím sau Enter/Space. Dòng đang chọn có `aria-current`.
- Trên điện thoại:
  - Header gọn, nội dung bắt đầu ở khoảng 166px (đo trong khung 390px).
  - Menu ngang có lớp mờ ở mép và tự cuộn tới mục đang chọn.
  - Cây truy xuất xếp lại thành một cột.
  - Panel chi tiết tự cuộn vào tầm nhìn.
  - Cột đầu bảng cố định khi cuộn ngang.
  - Vùng chạm tối thiểu 44px khi dùng cảm ứng.
- Có hộp "Chú giải thuật ngữ" và `<abbr>` cho NVL/NCTT/SXC. "Kiểm tra bất biến" đổi thành "Kiểm tra cân đối".
- Độ tương phản: `--warn` #8a5300, `--ok` #1a6e45, `--stamp` #b92525, `--muted` #525d6f.
- Toast có `role=status aria-live=polite`.
- Có `<meta charset="utf-8">` ở dòng đầu.
- Có nút chuyển sáng/tối (chỉ lưu localStorage, bọc try/catch). Tôn trọng prefers-reduced-motion.
- Biểu đồ có bảng số ẩn cho trình đọc màn hình. Thanh cơ cấu giá thành hiện nhãn giá trị.
- Có con dấu "Đã khóa sổ" nhỏ trên thanh trên.
- Đổi tên đối tác mẫu trùng thương hiệu thật thành tên giả định.

## Đã kiểm tra thật
- `scratchpad/sim2.py` là bản viết lại độc lập bằng Python, chạy 72 tổ hợp (2 chế độ × 3 phương pháp × 3 mức giờ máy × 2 mức dở dang × mở/khóa): 0 lỗi. Kiểm tra Nợ = Có, kho = sổ cái 152/154/155, 621/622/627 bằng 0, Z = DDĐK + C − DDCK, 154 ≥ 0, TK 5–8 bằng 0 sau khóa sổ, biên 25–27,5% (với dở dang mặc định). Số liệu khớp từng đồng với JS.
- Trong Chrome (qua `python -m http.server`), hàm `__giagoc.selfTest()` chạy 720 tổ hợp, có thêm các biến thể: lùi ngày, bán thêm, trả lại, kiểm kê, chi phí, tồn âm, hủy PN, sản phẩm không có NK. Kết quả 0 lỗi. Khi có tồn âm, khóa sổ dừng đúng ở bước 4.
- Đã chạy qua các form bằng sự kiện DOM: PN (kịch bản bước 2), sửa PN, PX vượt tồn (bị chặn, rồi "Vẫn lưu"), HĐ có khách mới, trả lại, kiểm kê, lương, khấu hao, chi phí. Sau đó chạy khóa sổ: dừng ở bước 4, hủy PX, khóa, form bị chặn, mở khóa (từ chối lý do ngắn), đổi TT 133, đổi 3 phương pháp, mở 8 trang và chạy 5 bước kịch bản. Không có lỗi console, không có NaN.
- Trong khung 390px: không cuộn ngang được (scrollX = 0).

## Chưa làm hoặc giới hạn
- Phiếu xuất đã chốt không "đóng băng" số cũ khi có chứng từ lùi ngày. Số luôn tính theo dữ liệu hiện tại; bước liên quan và chứng từ hệ thống được đánh dấu "Cần tính lại" và hiện số cũ → số mới.
- Chưa kiểm chứng việc giảm thuế GTGT 8%: mặc định vẫn 10%, có ghi chú.
- Chưa xác minh tài khoản giảm trừ doanh thu theo TT 99: hàng trả lại đang ghi giảm thẳng 5112, có ghi chú.
- Số hiệu mẫu S37-DN theo TT 99 cũng chưa xác minh.
- Chưa làm: tour lớp phủ (P1-6), báo cáo hoàn thành dạng form (P1-4; số lượng dở dang sửa ở trang Giá thành), thêm vật tư mới (P2-1), dán từ Excel (P2-2), chia sẻ qua link (P2-3), chứng từ nháp (P2-4), ribbon kiểu phần mềm kế toán, mẫu in có chữ ký, TK cấp 2 (6271…), chỉnh giá vật tư theo thị trường (L6).
- Không chụp được giao diện thật ở 390px: lệnh resize cửa sổ không có tác dụng, nên bố cục điện thoại được đo trong iframe 390px.
- Hàm kiểm thử `window.__giagoc` vẫn còn trong trang. Hàm này vô hại; muốn gỡ thì xóa một dòng gần cuối script.
