# Phản biện độc lập dự án — vòng v3 (2026-10-07)

Bốn phản biện viên độc lập rà bản chốt `d159ce3` (trước khi vẽ lại biểu đồ). Mọi lỗi dưới đây đã được tái hiện thật (Playwright trên demo; PostgreSQL 16 cho DDL) trừ chỗ ghi *suy luận*. Cột "Xử lý" ghi hướng đi đã chốt với người dùng.

Quyết định mới của người dùng ảnh hưởng tới danh sách:
- **Bỏ toàn bộ quy trình Khóa sổ 12 bước trong demo** (khóa/mở khóa kỳ, giá tạm → chốt, kết chuyển 911). Hệ thống luôn tính lại giá xuất, giá thành, giá vốn ngay khi có chứng từ.
- **Mục tiêu trọng tâm:** biết giá vốn hàng bán của mọi sản phẩm **theo lô** (lô này giá này, lô khác giá khác), bấm vào lô thấy giá vốn được cấu thành từ những lô nguyên liệu nào với giá nào. → Giá thành tính **theo lệnh sản xuất** (mỗi LSX là đối tượng tập hợp chi phí), không gộp theo sản phẩm/tháng.

## 1. Logic kế toán – giá vốn – giá thành (demo)

| Mã | Mức | Vấn đề | Bằng chứng | Xử lý |
|---|---|---|---|---|
| L1 | Cao | Sửa danh mục (định mức hao hụt, loại vật tư) khi kỳ đã khóa vẫn đổi số kỳ khóa | Giá vốn −334.057 đ, sổ vẫn "Đã khóa" | Hết khóa sổ; vẫn phải tính lại ngay và ghi nhật ký khi đổi định mức/loại |
| L2 | Cao | Sửa hóa đơn đã có hàng trả lại: phiếu trả treo vào hóa đơn đã hủy, trả được 1.020/1.000 | TL0001 trỏ HD0003 đã hủy | Đường "Sửa" dùng chung điều kiện chặn của "Hủy" |
| L3 | Cao | Sửa phiếu nhập USD đã thanh toán làm mất lãi tỷ giá 515 (78.000 đ), lệch công nợ 331 | CT0002 tham chiếu số phiếu cũ | Chặn sửa/hủy phiếu nhập đã có phiếu chi, hoặc chuyển tham chiếu |
| L4 | TB | Trả lại rồi bán lại cùng ngày báo tồn âm giả | KIND_ORDER xếp xuất trước trả lại | Xếp theo thời điểm lập trong ngày |
| L5 | TB | Dở dang mắm tôm gánh chi phí hũ dù hũ đã dùng hết | DDCK thừa 622.325 đ; z 39.371 vs 39.689 | Theo LSX: dở dang = chi phí lũy kế của LSX chưa hoàn thành |
| L6 | TB | Trả lại nhiều lần một dòng lệch 1 đồng | 44.597.952 vs 44.597.951 | Lần trả cuối nhận phần còn lại |
| L7 | Thấp | Làm tròn bằng số thực JS sai 1 đồng | 1,001 × 31.500 → 31.531 (đúng 31.532) | Tính trên số nguyên |
| L8 | Thấp | Hàng bán trả lại ghi thẳng 511, tài liệu ghi 5212 | — | Theo tài liệu (chưa xác minh TT99) |
| L9 | Thấp | Bảng lương thiếu khấu trừ 10,5% người lao động | 334 thừa 4.935.000 | Bổ sung |
| L10 | Thấp | Phiếu nhập trả tiền mặt ≥ 5 triệu không cảnh báo khấu trừ VAT | — | Bổ sung |

Đã kiểm và đúng: phân bổ SXC, SXC dưới công suất, z hai giai đoạn, lô ở nhiều bồn và chuyển bồn, định khoản TT99/TT133, kiểm kê 1381/3381, hỏng ngoài định mức 632, chênh lệch tỷ giá, bù trừ thuế.

## 2. Chức năng qua thao tác giao diện (demo)

| Mã | Mức | Vấn đề | Xử lý |
|---|---|---|---|
| U1 | Cao | Truy xuất theo lô ra kết quả vô lý về thời gian (lô BTP 18/01 "dùng" cá mua 31/01); không truy xuôi NVL → TP; thiếu lô tồn đầu | Truy xuất theo LSX thật: lô TP ← LSX ← các phiếu xuất của chính LSX đó (ngày ≤ ngày nhập kho); thêm truy xuôi |
| U2 | Cao | Sửa chứng từ trước ngày kiểm kê làm tồn sổ lệch số đếm mà không báo | Cảnh báo "phiếu kiểm kê lỗi thời" |
| U3 | Cao | Enter trong ô nhập là ghi sổ luôn | Enter sang ô kế; Ctrl+Enter ghi sổ |
| U4 | Cao | "Chạy tất cả" khóa sổ không hỏi lại | Hết (bỏ khóa sổ) |
| U5 | TB | Esc/Hủy bỏ làm mất phiếu đang nhập | Hỏi "Bỏ thay đổi?" |
| U6 | TB | Cảnh báo vượt kế hoạch LSX tính sai (không cộng phiếu đang lập) | Hiện "sau phiếu này X/Y" |
| U7 | TB | Đổ lô vào bồn đang chứa lô khác không cảnh báo | Cảnh báo trộn lô |
| U8 | TB | "+ Vị trí" giữ nguyên SL dòng gốc, dễ nhập gấp đôi | Tự chia phần còn lại |
| U9 | TB | Hàng trả lại "hũ nứt" về lô cũ với QC Đạt | Chọn QC/vị trí khi nhận trả |
| U10 | TB | Lô Không đạt không có cách xử lý (không xuất hủy) | Thêm phiếu xuất hủy |
| U11 | TB | Bảng bị cắt cột ở 1366px và 390px (bút toán mất cột Có, N-X-T mất số) | Sửa bố cục bảng |
| U12 | TB | Tìm kiếm không dấu không ra | So khớp bỏ dấu |
| U13 | TB | Khung "Ảnh hưởng" dính đầu mọi màn | Thu gọn/tự ẩn |
| U14 | TB | Mã vật tư hiển thị khác mã lưu khi đổi nhóm | Sửa |
| U15 | TB | In phiếu thiếu đơn giá/thành tiền, mẫu 01-VT/02-VT; phiếu chuyển kho in tiêu đề sai | Bổ sung |
| U16 | TB | "Excel" chỉ sao chép clipboard | Ghi đúng "Sao chép" hoặc tải CSV |

Luồng đã chạy đạt: nhập mua VND/USD, sản xuất 2 giai đoạn, QC, chuyển kho/bồn, bán, trả lại, kiểm kê theo vị trí, thu/chi USD, chi phí, danh mục, sửa/hủy, tìm kiếm, 10 báo cáo khớp nhau.

## 3. Truy vết yêu cầu khách hàng

- Tài liệu phủ 86% (112/130) yêu cầu; **demo phủ 26%** (34/130). Thiếu trên demo: TSCĐ, CCDC, khế ước vay, đề nghị thanh toán, đơn mua/bán, giảm giá, CĐKT, LCTT, đối chiếu kế toán–thủ kho, QC theo công đoạn.
- **Hiểu sai file Excel:**
  - Sheet `GoiYXuat` là **lập phiếu xuất từ đơn hàng** (lọc dòng đơn chưa giao theo mã đơn), không phải gợi ý lô theo HSD.
  - Mẫu in phiếu xuất kho có 4 chữ ký **Người nhận hàng / Bảo vệ / Tài xế / Thủ kho**, khối thông tin khách, SL đặt vs SL xuất, thông tin giao hàng; phiếu nhập kho có chữ ký **Kế toán**.
- Chưa thành yêu cầu: tên cũ ↔ tên mới và cú pháp tên 13 thuộc tính (quy tắc có sẵn trong sheet `CuPhapTen`), SL thực xuất, N-X-T thực tế lũy kế, giải trình kiểm kê, ý nghĩa cột "Số ngày lưu kho", nhập tồn đầu theo lô + bồn (sheet `TonDau`).
- Demo lệch ánh xạ quy trình §4 (số giai đoạn cá linh, mắm tôm; thiếu cá bạc má, dưa gang chay).
- QC (mục tiêu số 1 của khách) yếu nhất trên demo: chỉ trạng thái lô.
- Thông tin: không lộ dữ liệu từ file Excel. `HỆ THỐNG.docx` gốc (họ tên 16 nhân sự, metadata tác giả) đã nằm trong repo — **người dùng quyết định có gỡ hay không**.

## 4. Tài liệu & kiến trúc (DDL chạy thật trên PostgreSQL 16)

| Mã | Mức | Vấn đề | Đề xuất |
|---|---|---|---|
| A1 | Cao | Dòng bút toán sửa/xóa được sau ghi sổ và sau khóa kỳ; `journal_lines` không FK | Trigger guard + khóa kỳ trên `journal_lines`, FK kép |
| A2 | Cao | RLS bỏ sót `core`, `cst`, `audit` (11 bảng): tenant B đọc được dữ liệu tenant A, giả mạo được audit log | Bật RLS cho mọi schema bằng một hàm; test theo danh sách loại trừ; chỉ trigger ghi audit |
| A3 | Cao | Chặn xuất lô chưa Đạt QC lách được 3 cách (move_kind tự do, UPDATE lot_id, item không bật theo dõi lô) | CHECK move_kind; trigger INSERT OR UPDATE; suy phương pháp từ công ty; qc_status chỉ đổi qua hàm |
| A4 | Cao | Guard header trạng thái cho sửa mọi cột (phiếu QC đã chốt đổi FAIL→PASS) | So jsonb trừ cột được phép |
| A5 | Cao | Luồng duyệt/đề nghị thanh toán không ràng buộc ở DB (sửa/xóa lịch sử duyệt, quyết toán vượt) | Trigger append-only, kiểm điều kiện chuyển trạng thái, SoD |
| A6 | Cao | Phạm vi tăng (vị trí chứa, mã hóa, mẫu in…) chưa đưa vào kế hoạch; ước lượng 40–56 người-tháng lạc quan (năng suất thực tế 60–70% → 16–19 tháng code) | Kế hoạch v0.4 |
| A7 | Cao | Đợt 1A không khóa sổ được theo chính quy tắc (TP giá tạm tới 1B) | Sắp lại đợt |
| A8 | Cao (suy luận) | Đích danh theo lô sai bản chất nếu một bồn trộn nhiều lô | Hỏi khách; mô hình "gộp lô" sinh lô mới |
| A9 | TB | 4 phiên bản trình tự khóa sổ; tính lại toàn bộ vs repost tăng dần; định dạng mã lô và phạm vi duy nhất lệch; công thức hỏng ngoài định mức lệch (958.790 vs 939.614); kiểu lưu số lệch | Thống nhất một nguồn |
| A10 | TB | DDL 05 + 07 chạy nguyên văn lỗi (`inv.lots` tạo hai lần; thiếu `md.partners`, `core.users`) | Sửa |
| A11 | TB | Biến môi trường `app.tenant_id`, `app.engine` do app_user tự đặt được | Hàm SECURITY DEFINER / vai trò DB riêng |

Câu hỏi pháp lý chưa chắc: đổi phương pháp tính giá hàng tồn kho / chế độ kế toán giữa niên độ.
