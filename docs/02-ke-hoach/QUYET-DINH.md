# Nhật ký quyết định

> Phiên bản: 1.0 · Ngày: 2026-10-07 · Người phụ trách: Quản lý dự án · Trạng thái: Chờ duyệt (người dùng xác nhận danh sách)
> Nguồn duy nhất cho các quyết định đã chốt. Tài liệu khác trích mã `QD-nn`, không chép lại lý do. Quyết định mới thêm cuối danh sách, không đánh lại số; quyết định bị thay thì ghi "Thay bởi QD-nn".
> Viết tắt: theo [THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §2.

## Cách đọc

Mỗi mục theo dạng nhật ký quyết định kiến trúc rút gọn: **Quyết định** · **Lý do** · **Đã loại** (phương án đã cân nhắc và bỏ) · **Ảnh hưởng** (tài liệu, phần mềm, demo) · **Ngày / người chốt / trạng thái**.

- **Người chốt**: *Khách* = tài liệu `HỆ THỐNG.docx` hoặc file kho của khách; *Người dùng* = chủ dự án (bên làm phần mềm); *Đội dự án* = quản lý dự án, BA, trưởng kỹ thuật sau phản biện.
- **Trạng thái**: *Đã chốt* · *Tạm* (đang làm theo, chờ câu trả lời ở `CH-nn`) · *Thay bởi QD-nn*.
- Ngày là ngày quyết định xuất hiện lần đầu trong tài liệu của repo; không có biên bản họp riêng.

## Tóm tắt

| Mã | Quyết định | Trạng thái |
|---|---|---|
| [QD-01](#qd-01) | Web SaaS nhiều công ty thuê bao | Đã chốt |
| [QD-02](#qd-02) | TypeScript + PostgreSQL | Đã chốt |
| [QD-03](#qd-03) | Giai đoạn 1 đủ 10 phân hệ + QC, chia đợt 1A/1B/1C | Đã chốt |
| [QD-04](#qd-04) | Giá xuất kho thực tế đích danh theo lô | Đã chốt |
| [QD-05](#qd-05) | Giá thành theo lệnh sản xuất | Đã chốt |
| [QD-06](#qd-06) | Bán thành phẩm luôn có lô và sổ kho | Đã chốt |
| [QD-07](#qd-07) | Mục tiêu trọng tâm: giá vốn theo lô, giá nguyên liệu theo lô, cây cấu thành | Đã chốt |
| [QD-08](#qd-08) | Luôn tính lại ngay khi có chứng từ | Đã chốt |
| [QD-09](#qd-09) | Demo bỏ quy trình khóa sổ 12 bước | Đã chốt |
| [QD-10](#qd-10) | Sản phẩm vẫn khóa kỳ theo tháng, một thao tác có kiểm tra | Đã chốt |
| [QD-11](#qd-11) | Giao diện đơn giản, không viết tắt, không chữ thừa | Đã chốt |
| [QD-12](#qd-12) | Tồn kho theo tên hàng + lô + mã hóa + vị trí | Đã chốt |
| [QD-13](#qd-13) | Mã hóa do hệ thống tự sinh | Đã chốt nguyên tắc; định dạng Tạm |
| [QD-14](#qd-14) | Mã lô `DDMMYY-nn`, duy nhất theo mặt hàng | Tạm (CH-46) |
| [QD-15](#qd-15) | Luật làm tròn duy nhất R1 | Đã chốt |
| [QD-16](#qd-16) | Thiết kế mặc định theo TT99 | Tạm (CH-05) |
| [QD-17](#qd-17) | Chỉ kê khai thường xuyên | Đã chốt |
| [QD-18](#qd-18) | Định khoản bằng account role + khoản mục | Đã chốt |
| [QD-19](#qd-19) | Giai đoạn 1 không có HĐĐT, phân hệ lương, kết nối ngân hàng | Đã chốt |
| [QD-20](#qd-20) | Chỉ học thiết kế từ phần mềm mã nguồn mở, không chép mã | Đã chốt |
| [QD-21](#qd-21) | Ranh giới bảo mật nằm ở cơ sở dữ liệu | Đã chốt |
| [QD-22](#qd-22) | Không chia partition ở giai đoạn 1 | Đã chốt |
| [QD-23](#qd-23) | Sắp lại đợt: giá thành và giá vốn theo lô vào 1A; mốc "Kho + QC" | Đã chốt |
| [QD-24](#qd-24) | Một công thức cho hỏng ngoài định mức | Đã chốt |
| [QD-25](#qd-25) | Không hiện nhãn "tạm tính" trên giao diện | Đã chốt |
| [QD-26](#qd-26) | Số phiếu kho theo tháng bên cạnh số chứng từ theo năm | Tạm (CH-35) |
| [QD-27](#qd-27) | Cấm xuất âm | Tạm (CH-20) |
| [QD-28](#qd-28) | Chuyển kho hai bước | Tạm |
| [QD-29](#qd-29) | Demo dùng cách tính giá thành giản lược | Đã chốt (chỉ cho demo) |
| [QD-30](#qd-30) | Ước lượng tiến độ theo năng suất thực tế 60–70% | Đã chốt |
| [QD-31](#qd-31) | In phiếu theo mẫu sổ kho của khách và mẫu chế độ | Đã chốt |
| [QD-32](#qd-32) | Cấu trúc tài liệu, một nguồn cho mỗi nội dung | Đã chốt |
| [QD-33](#qd-33) | Tên sản phẩm: "Hệ thống quản lý" | Đã chốt |
| [QD-34](#qd-34) | Giữ `HỆ THỐNG.docx` trong repo, repo công khai | Đã chốt |

## Chi tiết

<a id="qd-01"></a>
### QD-01 — Web SaaS nhiều công ty thuê bao
- **Quyết định**: phần mềm chạy trên web, nhiều công ty dùng chung một hệ thống; dữ liệu tách bằng `tenant_id` + PostgreSQL FORCE RLS.
- **Lý do**: khách đầu tiên dùng nội bộ, sau đó thương mại hóa.
- **Đã loại**: cài đặt riêng tại máy khách; một cơ sở dữ liệu mỗi khách ở giai đoạn đầu.
- **Ảnh hưởng**: [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §2.
- **Ngày / người chốt / trạng thái**: 2026-10-04 · Người dùng · Đã chốt.

<a id="qd-02"></a>
### QD-02 — TypeScript + PostgreSQL
- **Quyết định**: TypeScript, Node 24, NestJS 11 (Fastify), React 19 + Vite + TanStack + AG Grid, PostgreSQL 18, Kysely + migration SQL, BullMQ + outbox, pnpm/Turborepo, Vitest + Testcontainers + fast-check.
- **Lý do**: người dùng chốt ngôn ngữ và cơ sở dữ liệu; chi tiết thư viện chọn ở kiến trúc.
- **Đã loại**: Next.js, tRPC, Prisma, Drizzle (lý do ở [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §1).
- **Ảnh hưởng**: toàn bộ thiết kế kỹ thuật.
- **Ngày / người chốt / trạng thái**: 2026-10-04 · Người dùng (ngôn ngữ, cơ sở dữ liệu), Đội dự án (thư viện) · Đã chốt.

<a id="qd-03"></a>
### QD-03 — Giai đoạn 1 đủ 10 phân hệ + QC, chia đợt 1A/1B/1C
- **Quyết định**: giai đoạn 1 gồm đủ 10 phân hệ khách liệt kê (Tiền, Ngân hàng, Mua, Bán, TSCĐ, CCDC, Kho, Giá thành, Tổng hợp, Báo cáo) và phân hệ QC. Được làm mỏng tính năng trong từng phân hệ, **không** cắt phân hệ.
- **Lý do**: khách liệt kê 10 phân hệ là phạm vi giai đoạn 1; mục tiêu số 1 của khách là hệ thống quản lý chất lượng.
- **Đã loại**: MVP hẹp 18–22 PM của kế hoạch v0.2.
- **Ảnh hưởng**: [KE-HOACH-DU-AN](KE-HOACH-DU-AN.md) §3; ước lượng tăng lên ~43–61 PM.
- **Ngày / người chốt / trạng thái**: 2026-10-06 · Người dùng · Đã chốt.

<a id="qd-04"></a>
### QD-04 — Giá xuất kho thực tế đích danh theo lô
- **Quyết định**: mọi hàng tồn kho (kể cả bao bì, phụ gia) tính giá xuất thực tế đích danh theo lô; cost key (công ty, vật tư, kho, lô); hệ thống gợi ý lô (FEFO, rồi lô cũ nhất) để người dùng không phải chọn tay hàng giá trị nhỏ.
- **Lý do**: tài liệu khách ghi "xác định tính giá vốn theo phương pháp thực tế đích danh"; khách quản lý hàng theo mã lót.
- **Đã loại**: bình quân cuối kỳ / bình quân tức thời làm phương pháp chính (giữ trong demo chỉ để so sánh); dùng bình quân cho bao bì (chờ CH-16, XM-08).
- **Ảnh hưởng**: [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §2; demo mặc định "Thực tế đích danh".
- **Ngày / người chốt / trạng thái**: 2026-10-06 · Khách · Đã chốt.

<a id="qd-05"></a>
### QD-05 — Giá thành theo lệnh sản xuất
- **Quyết định**: mỗi lệnh sản xuất công đoạn (lô × giai đoạn) là một đối tượng tập hợp chi phí; dở dang = toàn bộ chi phí lũy kế của lệnh chưa hoàn thành, kể cả lệnh ủ qua nhiều kỳ; không gộp theo sản phẩm/tháng; không cần % hoàn thành.
- **Lý do**: mục tiêu giá vốn theo lô (QD-07) cần giá riêng cho từng lô thành phẩm; công đoạn ủ kéo dài nhiều tháng.
- **Đã loại**: giá thành giản đơn theo sản phẩm/tháng; phân bước gộp theo tháng (cách của MISA).
- **Ảnh hưởng**: GT-01..GT-06, GT-10; [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §3–§4; demo trang "Giá thành theo lệnh sản xuất".
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-06"></a>
### QD-06 — Bán thành phẩm luôn có lô và sổ kho
- **Quyết định**: mọi bán thành phẩm (kể cả loại làm xong và dùng ngay trong ca) được nhập kho bằng phiếu có lô, có giá lô; giai đoạn sau xuất đích danh lô bán thành phẩm (phương án A).
- **Lý do**: cây cấu thành giá lô thành phẩm đi qua lô bán thành phẩm; chặn QC và kiểm kê dùng chung cơ chế lô.
- **Đã loại**: phương án B "chuyển thẳng 154 giữa các lệnh, không qua kho" — để giai đoạn 2 nếu số chứng từ tự sinh thành gánh nặng.
- **Ảnh hưởng**: [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §4.2. Tài khoản ghi nhận bán thành phẩm (155 hay 154) vẫn chờ CH-11.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-07"></a>
### QD-07 — Mục tiêu trọng tâm: giá vốn theo lô, giá nguyên liệu theo lô, cây cấu thành
- **Quyết định**: biết giá vốn hàng bán của mọi sản phẩm **theo lô** (lô này giá này, lô khác giá khác); kiểm soát giá nguyên liệu theo lô; bấm vào một lô thành phẩm thấy giá được cấu thành từ những lô nguyên liệu nào, giá nào.
- **Lý do**: yêu cầu của người dùng, cụ thể hóa mục tiêu "mua hàng → xuất hàng → giá thành ⇒ P&L" của khách.
- **Đã loại**: chỉ báo giá vốn theo mặt hàng/tháng.
- **Ảnh hưởng**: yêu cầu GT-09, GT-10, GT-R4, GT-R5; đưa vào đợt 1A; demo trang "Giá nguyên liệu", "Giá vốn theo lô".
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-08"></a>
### QD-08 — Luôn tính lại ngay khi có chứng từ
- **Quyết định**: giá xuất kho, giá thành lệnh, giá vốn tính lại ngay khi ghi, sửa hoặc hủy chứng từ. Giai đoạn 1 phát lại **toàn bộ** cost key (một lô ở một kho) từ kỳ khóa gần nhất; tính lại tăng dần có điểm dừng để giai đoạn 2.
- **Lý do**: với đích danh, mỗi cost key là một chuỗi ngắn; bỏ được bước tính giá cuối kỳ.
- **Đã loại**: bộ điều phối khóa sổ nhiều bước (13 bước ở kiến trúc 0.2); tính lại tăng dần ngay giai đoạn 1.
- **Ảnh hưởng**: [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §5.5, §7.2.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-09"></a>
### QD-09 — Demo bỏ quy trình khóa sổ 12 bước
- **Quyết định**: demo không còn trang, menu, 12 bước khóa sổ, khóa / mở khóa kỳ, giá tạm / đã chốt; mọi số luôn tính lại ngay.
- **Lý do**: người dùng thấy quy trình nhiều bước không cần với đích danh và làm rối demo; phản biện vòng 3 phát hiện lỗi sửa danh mục khi đã khóa (L1) và "Chạy tất cả" không hỏi lại (U4).
- **Đã loại**: giữ khóa sổ trong demo.
- **Ảnh hưởng**: demo v4.0 ([CHANGELOG](../../demo/CHANGELOG.md)). Chỉ áp cho demo; sản phẩm theo QD-10.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-10"></a>
### QD-10 — Sản phẩm vẫn khóa kỳ theo tháng, một thao tác có kiểm tra
- **Quyết định**: sản phẩm thật khóa kỳ theo tháng bằng **một thao tác** của KTT; hệ thống tự kiểm (kỳ trước đã khóa, không còn yêu cầu tính lại, mọi dòng kho có giá, Nợ = Có, không tồn âm, kết chuyển không cần chạy lại, dòng tiền có mã), đạt thì khóa. Mở khóa chỉ KTT, bắt buộc lý do, ghi nhật ký. Kết chuyển lãi/lỗ vẫn là yêu cầu (TH-02).
- **Lý do**: TT99 yêu cầu phần mềm ngăn sửa trái phép và lưu vết sửa đổi; Luật Kế toán chỉ cho sửa sổ đã khóa bằng ghi bổ sung / ghi đỏ.
- **Đã loại**: không khóa kỳ; khóa theo ngày ở giai đoạn 1.
- **Ảnh hưởng**: TH-03; trình tự cuối kỳ duy nhất ở [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §7.2.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-11"></a>
### QD-11 — Giao diện đơn giản, không viết tắt, không chữ thừa
- **Quyết định**: không đoạn hướng dẫn, mô tả, chú thích trên màn hình; nhãn trường ngắn; thông báo lỗi một câu nói rõ sai ở đâu; không nhãn màu (trạng thái là chữ thường; màu chỉ cho lỗi và chỗ đang chọn); bo góc ≤ 2px; **viết đầy đủ, không chữ viết tắt** (giữ mã định danh, số hiệu tài khoản, "QC", "thuế GTGT").
- **Lý do**: phản hồi của người vận hành (kế toán, thủ kho) trên các bản demo v3.1–v3.3.
- **Đã loại**: tour và thanh "Kịch bản demo" tự bật; nhãn viên thuốc màu; chữ viết tắt kèm chú giải.
- **Ảnh hưởng**: NFR-01; demo v3.1, v3.3, v4.0.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-12"></a>
### QD-12 — Tồn kho theo tên hàng + lô + mã hóa + vị trí
- **Quyết định**: tồn kho theo dõi theo tên hàng + mã lô + mã hóa + bồn/trái/phuy; kiểm âm theo (vật tư, kho, lô, vị trí); giá trị vẫn theo lô; chuyển bồn trong cùng kho bằng phiếu chuyển kho, không bút toán.
- **Lý do**: yêu cầu người dùng khi chuyển file Excel kho bán thành phẩm của nhà máy; một lô thường nằm ở nhiều bồn.
- **Đã loại**: vị trí mang giá riêng.
- **Ảnh hưởng**: KHO-06, KHO-R7..R10; [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §2.8; demo v3.2.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-13"></a>
### QD-13 — Mã hóa do hệ thống tự sinh
- **Quyết định**: mã hóa do hệ thống cấp khi tạo lô, dạng `NHÓM-YYMM-nnnn`, duy nhất toàn công ty, không sửa, không cấp lại ([THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §4.2).
- **Lý do**: người dùng: "mã hóa có thể là một mã tự sinh ra trong hệ thống"; cột mã hóa trong file Excel trống toàn bộ.
- **Đã loại**: mã hóa = 2 ký tự cuối mã lô (cách kiểm trong file Excel); nhập tay.
- **Ảnh hưởng**: KHO-07. Nếu khách trả lời CH-45 khác thì đổi thành trường nhập có kiểm tra.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt nguyên tắc tự sinh; định dạng Tạm (CH-45).

<a id="qd-14"></a>
### QD-14 — Mã lô `DDMMYY-nn`, duy nhất theo mặt hàng
- **Quyết định**: mã lô gợi ý `DDMMYY-nn`, sửa được, lưu chuỗi, duy nhất theo (công ty, mặt hàng) ([THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §4.1).
- **Lý do**: định dạng phổ biến nhất trong file kho (116/206 mã); file có 16 mã lô dùng chung cho 2–4 mặt hàng nên bắt duy nhất toàn công ty sẽ chặn dữ liệu thật; mã duy nhất toàn công ty đã có là mã hóa.
- **Đã loại**: `mã vật tư + yymmdd + số` (demo v3.0); duy nhất toàn công ty (demo v3.2–v4.0 vẫn đang kiểm kiểu này — cần sửa demo).
- **Ảnh hưởng**: KHO-03; [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §2.1.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Đội dự án (thống nhất sau phản biện vòng 3, A9) · Tạm (CH-46).

<a id="qd-15"></a>
### QD-15 — Luật làm tròn duy nhất R1
- **Quyết định**: một luật làm tròn cho mọi số tiền, phân bổ và giá xuất: R1(a), R1(b) largest remainder, R1(c) ([THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §5).
- **Lý do**: phản biện vòng 2 phát hiện ba luật làm tròn khác nhau giữa nghiệp vụ, kiến trúc và kế hoạch, làm golden test không khớp.
- **Đã loại**: "dòng cuối nhận phần dư" (phụ thuộc thứ tự dòng).
- **Ảnh hưởng**: golden test, demo (`allocate()`), NFR-05.
- **Ngày / người chốt / trạng thái**: 2026-10-06 · Đội dự án · Đã chốt.

<a id="qd-16"></a>
### QD-16 — Thiết kế mặc định theo TT99
- **Quyết định**: thiết kế, golden test và demo mặc định theo TT99/2025; TT133 là bộ cấu hình thứ hai (đổi 621/622/627 → 154, 521 → 511, 641/642 → 6421/6422, mẫu BCTC). TT200 chỉ để chuyển dữ liệu lịch sử. Giai đoạn 1 bật **một** chế độ theo lựa chọn của khách.
- **Lý do**: tài liệu khách chỉ ghi "hệ thống tài khoản hiện hành"; TT99 thay TT200 từ 01/01/2026.
- **Đã loại**: viết cứng theo một chế độ.
- **Ảnh hưởng**: nếu khách chọn TT133 thì đổi bộ cấu hình và golden test, không đổi engine.
- **Ngày / người chốt / trạng thái**: 2026-10-06 · Đội dự án · Tạm (CH-05).

<a id="qd-17"></a>
### QD-17 — Chỉ kê khai thường xuyên
- **Quyết định**: giai đoạn 1 chỉ hỗ trợ kê khai thường xuyên hàng tồn kho.
- **Lý do**: quyết định phạm vi sản phẩm (không phải do luật bắt buộc); đích danh theo lô cần theo dõi từng lần nhập xuất.
- **Đã loại**: kiểm kê định kỳ.
- **Ảnh hưởng**: không có TK 611/631 trong mô hình dữ liệu.
- **Ngày / người chốt / trạng thái**: 2026-10-04 · Đội dự án · Đã chốt.

<a id="qd-18"></a>
### QD-18 — Định khoản bằng account role + khoản mục
- **Quyết định**: logic định khoản dùng account role và khoản mục chi phí; báo cáo ánh xạ qua mã tài khoản chuẩn; bút toán phần kho sinh từ sổ kho (vế kho từ giá trị dòng kho, vế đối ứng theo mục đích xuất/nhập × chế độ).
- **Lý do**: TT99 cho doanh nghiệp tự đặt số hiệu; cùng engine chạy được TT99 và TT133.
- **Đã loại**: viết cứng số hiệu tài khoản; mặc định đối ứng 154/632 cho mọi phiếu xuất.
- **Ảnh hưởng**: [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §2.3, §4.7; [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §2.4.
- **Ngày / người chốt / trạng thái**: 2026-10-04 · Đội dự án · Đã chốt.

<a id="qd-19"></a>
### QD-19 — Giai đoạn 1 không có HĐĐT, phân hệ lương, kết nối ngân hàng
- **Quyết định**: không tích hợp phát hành HĐĐT, không phân hệ tiền lương, không kết nối ngân hàng, không ứng dụng di động ở giai đoạn 1. Lương nhập bằng chứng từ tổng hợp; số hóa đơn nhập tay.
- **Lý do**: không có trong danh sách phân hệ của khách.
- **Đã loại**: —
- **Ảnh hưởng**: đưa sang giai đoạn 2 ([KE-HOACH-DU-AN](KE-HOACH-DU-AN.md) §3.6). Câu hỏi xác nhận: CH-28.
- **Ngày / người chốt / trạng thái**: 2026-10-06 · Đội dự án · Đã chốt.

<a id="qd-20"></a>
### QD-20 — Chỉ học thiết kế từ phần mềm mã nguồn mở, không chép mã
- **Quyết định**: ERPNext (GPL-3), Odoo (LGPL-3), iDempiere (GPL-2) chỉ dùng để học thiết kế; không chép mã.
- **Lý do**: giấy phép GPL/LGPL không phù hợp sản phẩm thương mại đóng.
- **Đã loại**: dựng trên ERPNext/Odoo.
- **Ảnh hưởng**: [REPO-MA-NGUON-MO](../04-tham-khao/REPO-MA-NGUON-MO.md) §0.
- **Ngày / người chốt / trạng thái**: 2026-10-04 · Đội dự án · Đã chốt.

<a id="qd-21"></a>
### QD-21 — Ranh giới bảo mật nằm ở cơ sở dữ liệu
- **Quyết định**: RLS cho mọi schema bằng một hàm; nhật ký sửa đổi chỉ ghi qua trigger; chứng từ, bút toán, sổ kho bất biến sau ghi sổ; vai trò CSDL tách quyền (`app_user`, `engine_user`, `auth_service`); phiên tra từ `core.sessions`, không tin biến phiên do ứng dụng tự đặt; luồng duyệt và phân tách nhiệm vụ cưỡng chế bằng CSDL.
- **Lý do**: phản biện vòng 3 (A1–A5, A11) chứng minh được lách khi chỉ kiểm ở ứng dụng.
- **Đã loại**: kiểm quyền chỉ ở tầng ứng dụng.
- **Ảnh hưởng**: [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §2.1, §7; 66 phép thử ở [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §11.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Đội dự án · Đã chốt.

<a id="qd-22"></a>
### QD-22 — Không chia partition ở giai đoạn 1
- **Quyết định**: không partition bảng ở giai đoạn 1.
- **Lý do**: RLS không tự áp cho partition truy cập trực tiếp; khối lượng doanh nghiệp vừa chưa cần.
- **Đã loại**: partition theo năm/tháng từ đầu.
- **Ảnh hưởng**: [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §4.11.
- **Ngày / người chốt / trạng thái**: 2026-10-06 · Đội dự án · Đã chốt.

<a id="qd-23"></a>
### QD-23 — Sắp lại đợt: giá thành và giá vốn theo lô vào 1A; mốc "Kho + QC"
- **Quyết định**: giá thành theo lệnh, giá vốn theo lô, giá nguyên liệu theo lô và kế thừa file Excel kho vào đợt 1A; mốc phát hành sớm "Kho + QC" trong 1A; đơn hàng đầy đủ + duyệt, đề nghị thanh toán, ngoại tệ giao dịch sang 1B.
- **Lý do**: đợt nào phát hành cũng phải khóa kỳ được (mọi dòng kho có giá) — kế hoạch v0.3 để giá thành ở 1B thì 1A không khóa được (phản biện vòng 3, A7); QC là mục tiêu số 1 của khách.
- **Đã loại**: phân đợt của kế hoạch v0.3.
- **Ảnh hưởng**: [KE-HOACH-DU-AN](KE-HOACH-DU-AN.md) §3.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Đội dự án · Đã chốt.

<a id="qd-24"></a>
### QD-24 — Một công thức cho hỏng ngoài định mức
- **Quyết định**: chia chi phí lệnh C theo R1(b) với trọng số (SL đạt từng lô đầu ra, SL ngoài định mức); SL không đạt trong định mức không có trọng số. Ví dụ chuẩn: 58.200.000 → 57.241.210 / 958.790.
- **Lý do**: hai công thức lệch nhau trong tài liệu cũ (958.790 và 939.614).
- **Đã loại**: "giá đơn vị trên tổng SL đầu ra × SL ngoài định mức".
- **Ảnh hưởng**: GT-05, GT-06; golden test; [DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §4.1. Tài khoản ghi nhận: CH-12.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Đội dự án · Đã chốt.

<a id="qd-25"></a>
### QD-25 — Không hiện nhãn "tạm tính" trên giao diện
- **Quyết định**: dòng kho mang trạng thái giá tạm bên trong tới khi khóa kỳ (sản xuất chung của kỳ còn đổi), nhưng giao diện không gắn nhãn "tạm tính".
- **Lý do**: giá luôn tính lại ngay (QD-08); nhãn gây nhiễu (QD-11).
- **Đã loại**: nhãn "tạm tính / đã chốt / cần tính lại" (demo trước v4.0).
- **Ảnh hưởng**: [KIEN-TRUC-VA-CSDL](../03-thiet-ke/KIEN-TRUC-VA-CSDL.md) §4.7.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-26"></a>
### QD-26 — Số phiếu kho theo tháng bên cạnh số chứng từ theo năm
- **Quyết định**: chứng từ kho có thêm số phiếu kho `PNK-YYMMnnn` / `PXK-YYMMnnn` đánh theo tháng; số chứng từ kế toán vẫn liền mạch theo năm.
- **Lý do**: thủ kho quen đánh số phiếu theo tháng (file Excel); kế toán cần số liền mạch theo năm.
- **Đã loại**: dùng một số duy nhất.
- **Ảnh hưởng**: KHO-10; [THUAT-NGU](../00-tong-quan/THUAT-NGU.md) §4.3.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Đội dự án · Tạm (CH-35).

<a id="qd-27"></a>
### QD-27 — Cấm xuất âm
- **Quyết định**: chặn lưu, sửa hoặc hủy chứng từ làm tồn âm theo (vật tư, kho, lô, vị trí).
- **Lý do**: đích danh theo lô không định giá được phần tồn âm; file kho của khách có tồn theo lô âm (−884, −40).
- **Đã loại**: cho tạm âm rồi chặn khi khóa kỳ.
- **Ảnh hưởng**: KHO-02; demo v4.0 chặn ngay khi lưu.
- **Ngày / người chốt / trạng thái**: 2026-10-06 · Đội dự án · Tạm (CH-20).

<a id="qd-28"></a>
### QD-28 — Chuyển kho hai bước
- **Quyết định**: chuyển kho giữa các địa điểm gồm hai bước: kho đi xuất, kho đến xác nhận SL thực nhận; giữ nguyên lô và giá trị lô.
- **Lý do**: ba địa điểm cách xa nhau, cần đối chiếu hàng đi đường.
- **Đã loại**: một bước (demo đang làm một bước).
- **Ảnh hưởng**: KHO-04, KHO-R3.
- **Ngày / người chốt / trạng thái**: 2026-10-06 · Đội dự án · Tạm (chưa có câu hỏi riêng; xác nhận cùng CH-30).

<a id="qd-29"></a>
### QD-29 — Demo dùng cách tính giá thành giản lược
- **Quyết định**: trong demo v4.0: (1) nhân công trực tiếp của một sản phẩm phân bổ cho các lệnh của sản phẩm đó, sản xuất chung phân bổ cho mọi lệnh trong kỳ, cả hai theo **một tiêu thức: chi phí nguyên vật liệu trực tiếp của lệnh** (không gồm bán thành phẩm giai đoạn trước); (2) lệnh **hoàn thành khi có phiếu nhập kho đầu tiên**, toàn bộ chi phí lệnh vào các lô nhập kho của lệnh, không có dở dang một phần; phiếu xuất cho lệnh sau ngày nhập kho đầu tiên bị chặn.
- **Lý do**: chưa có giờ công theo lệnh và thời gian ủ thật (CH-10, CH-47); demo cần chạy được với dữ liệu mẫu.
- **Đã loại**: dùng ngay tiêu thức "khối lượng × số ngày" của thiết kế trong demo.
- **Ảnh hưởng**: chỉ demo. Thiết kế sản phẩm giữ tiêu thức cấu hình theo giai đoạn ([DIEU-CHINH-THEO-KHACH-HANG](../03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §3.2 `overhead_basis`, §4.3) và trạng thái lệnh có bước "Hoàn thành → Đóng" (KHO-01). Khi trình diễn phải nói rõ đây là giả định.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Đội dự án · Đã chốt (chỉ cho demo).

<a id="qd-30"></a>
### QD-30 — Ước lượng tiến độ theo năng suất thực tế 60–70%
- **Quyết định**: ước ~43–61 PM phát triển; năng suất 60–70% (5 người: 3,0–3,5 PM/tháng; 4 người: 2,4–2,8 PM/tháng); không cam kết con số giữa khoảng trước khi đo năng suất thật.
- **Lý do**: phản biện vòng 3 (A6): kế hoạch v0.3 giả định 80% và thiếu phần kế thừa file Excel kho.
- **Đã loại**: 40–56 PM với 4 PM/tháng (v0.3).
- **Ảnh hưởng**: [KE-HOACH-DU-AN](KE-HOACH-DU-AN.md) §3.5.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Đội dự án · Đã chốt (ước lại sau nền móng và sau mốc Kho + QC).

<a id="qd-31"></a>
### QD-31 — In phiếu theo mẫu sổ kho của khách và mẫu chế độ
- **Quyết định**: phiếu nhập kho, phiếu xuất kho in đủ trường và chữ ký như mẫu sổ kho của khách, kèm đơn giá và thành tiền cho kế toán; có phiếu xuất kho kiêm vận chuyển nội bộ, biên bản kiểm kê, phiếu thu, phiếu chi. Mẫu in chỉ ghi tên công ty lấy từ danh mục (demo: "Nhà máy chế biến mắm"), không chép thông tin thật từ file khách.
- **Lý do**: phản biện vòng 3 (U15, §3): mẫu in thiếu trường, thiếu chữ ký.
- **Đã loại**: chỉ in mẫu 01-VT / 02-VT.
- **Ảnh hưởng**: KHO-11; demo v4.0 ("Lưu và in", in từ dòng, "In các phiếu đã chọn"). Số hiệu mẫu theo TT99: XM-02.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-32"></a>
### QD-32 — Cấu trúc tài liệu, một nguồn cho mỗi nội dung
- **Quyết định**: tài liệu chia theo thư mục `docs/00-tong-quan` … `docs/05-phan-bien`; mỗi nội dung có một nguồn: phạm vi và tiến độ → kế hoạch; yêu cầu → YEU-CAU-KHACH-HANG; quyết định → tài liệu này; câu hỏi → CAU-HOI-MO; thuật ngữ, quy ước mã, R1 → THUAT-NGU; thiết kế dữ liệu → KIEN-TRUC-VA-CSDL và DIEU-CHINH-THEO-KHACH-HANG; thay đổi demo → demo/CHANGELOG.md. Mỗi tài liệu có dòng Phiên bản · Ngày · Người phụ trách · Trạng thái.
- **Lý do**: các tài liệu cũ lặp lại cùng nội dung (R1, trình tự khóa kỳ, câu hỏi) và lệch nhau sau mỗi vòng sửa.
- **Đã loại**: giữ thư mục `docs/research` đánh số 01–07.
- **Ảnh hưởng**: [README](../../README.md).
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-33"></a>
### QD-33 — Tên sản phẩm: "Hệ thống quản lý"
- **Quyết định**: tên sản phẩm dùng thống nhất là **Hệ thống quản lý** (tiêu đề trang, thanh bên demo, tài liệu). Tên tạm "Outhouse" và "Giá Gốc" không dùng nữa; tên file demo `gia-goc-demo.html` giữ nguyên để không đổi đường dẫn máy chủ.
- **Lý do**: trả lời [CH-56](../01-yeu-cau/CAU-HOI-MO.md#ch-56).
- **Đã loại**: "Outhouse", "Giá Gốc".
- **Ảnh hưởng**: demo, README.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.

<a id="qd-34"></a>
### QD-34 — Giữ `HỆ THỐNG.docx` trong repo, repo công khai
- **Quyết định**: không gỡ `HỆ THỐNG.docx` khỏi repo và lịch sử git; repo tiếp tục để công khai.
- **Lý do**: trả lời [CH-55](../01-yeu-cau/CAU-HOI-MO.md#ch-55).
- **Rủi ro chấp nhận**: file chứa họ tên 16 nhân sự của khách và metadata tác giả, ai cũng xem được trên GitHub.
- **Ngày / người chốt / trạng thái**: 2026-10-07 · Người dùng · Đã chốt.
