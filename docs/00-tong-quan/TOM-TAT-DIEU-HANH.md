# Tóm tắt điều hành

> Phiên bản: 1.0 · Ngày: 2026-10-07 · Người phụ trách: Quản lý dự án · Trạng thái: Chờ duyệt (người dùng)
> Viết tắt: QC = kiểm tra chất lượng; CH-nn = mã câu hỏi ([THUAT-NGU](THUAT-NGU.md) §2).
> Một trang cho Ban giám đốc. Số liệu và lý do chi tiết ở các tài liệu được dẫn; tài liệu này không phải nguồn gốc của số nào.

## Dự án là gì

Phần mềm kế toán – kho – giá vốn – giá thành – quản lý chất lượng chạy trên web, làm cho nhà máy chế biến mắm (3 địa điểm: Nhà máy Bà Ba Thạo, Bình Tây, 97 Nguyễn Thái Học; 16 người vận hành) trước, sau đó bán cho doanh nghiệp khác.

Mục tiêu giai đoạn 1 của nhà máy: **(1) quản lý chất lượng; (2) số liệu, sổ sách theo dõi mua hàng → xuất hàng → giá thành → lãi lỗ.**

## Điều phần mềm làm khác

**Giá vốn theo từng lô.** Mỗi lần nhập nguyên liệu là một lô có giá riêng; mỗi lệnh sản xuất tính giá riêng; mỗi lô thành phẩm có giá riêng. Bấm vào một lô mắm thấy ngay giá được tạo từ lô cá nào, mua của ai, giá bao nhiêu, nhân công và chi phí chung bao nhiêu. Giá tính lại ngay khi có chứng từ, không chờ cuối tháng. Tồn kho theo dõi theo tên hàng + lô + mã hóa + bồn/trái/phuy như sổ kho hiện tại của nhà máy.

## Đã có gì (2026-10-07)

| Hạng mục | Trạng thái |
|---|---|
| Yêu cầu chuẩn hóa từ tài liệu của nhà máy và file kho Excel | Xong bản v1.3, **chờ nhà máy xác nhận** |
| Bản demo chạy trên trình duyệt (dữ liệu mẫu) | Bản v4.0: giá nguyên liệu theo lô, giá vốn theo lô, giá thành theo lệnh sản xuất, kho theo lô + bồn, in phiếu theo mẫu nhà máy |
| Thiết kế dữ liệu và bảo mật | Chạy thử trên PostgreSQL 16, 66 phép thử đạt; chưa chạy trên bản 18 |
| Kế hoạch, ước lượng | Bản v0.5, chờ chọn quy mô đội |
| Viết phần mềm thật | **Chưa bắt đầu** |

## Kế hoạch và chi phí công sức

Giai đoạn 1 gồm đủ 10 phân hệ nhà máy yêu cầu + quản lý chất lượng, chia 3 đợt. Ước **43–61 người-tháng** phát triển (sai số có thể ±30%, chưa đo năng suất thật).

| Mốc | Đội 5 người | Đội 4 người |
|---|---|---|
| Thủ kho và QC dùng thật thay file Excel | tháng 4–6,5 | tháng 5–8 |
| Đợt 1A: kho, mua, bán, sản xuất, giá vốn theo lô chạy song song MISA | tháng 8–13,5 | tháng 10–17 |
| Xong viết phần mềm giai đoạn 1 | tháng 12,5–20,5 | tháng 15,5–25,5 |
| Nghiệm thu sau 2–3 tháng chạy song song | tháng 14,5–23,5 | tháng 17,5–28,5 |

Chi tiết: [KE-HOACH-DU-AN](../02-ke-hoach/KE-HOACH-DU-AN.md) §3.5.

## Cần Ban giám đốc quyết định / trả lời

1. **Quy mô đội và ngày bắt đầu** (5 hay 4 người) — [CH-54](../01-yeu-cau/CAU-HOI-MO.md#ch-54).
2. **Ngày muốn dùng thật** và thời gian chạy song song MISA — [CH-01](../01-yeu-cau/CAU-HOI-MO.md#ch-01). Đề xuất bắt đầu từ đầu năm tài chính.
3. **Hạn mức và cấp duyệt** đề nghị thanh toán, đơn hàng — [CH-02](../01-yeu-cau/CAU-HOI-MO.md#ch-02).
4. **Bố trí kế toán trưởng ~1 ngày/tuần** duyệt đặc tả và ví dụ số; đây là điểm nghẽn lớn nhất của phần giá thành.
5. Cho phép thủ kho, QC, kế toán trả lời danh sách câu hỏi ([CAU-HOI-MO](../01-yeu-cau/CAU-HOI-MO.md)), ưu tiên: chế độ kế toán, bồn có trộn nhiều lô không, quy tắc mã lô, thời gian ủ, cách chia nhân công và chi phí chung.

## Rủi ro chính

- **Trễ tiến độ** nếu năng suất đội thấp hơn ước lượng — giảm bằng mốc sớm "Thủ kho + QC", danh sách cắt mỏng tính năng chốt trước, ước lại sau 2 mốc đầu.
- **Thiếu số liệu sản xuất thật** (thời gian ủ, định mức, tỷ lệ hỏng) làm chậm phần giá thành.
- **Bồn trộn nhiều lô**: nếu nhà máy châm/trộn lô trong bồn thì phải đổi cách quản lý lô — cần trả lời sớm.

Danh sách đầy đủ: [KE-HOACH-DU-AN](../02-ke-hoach/KE-HOACH-DU-AN.md) §5.
