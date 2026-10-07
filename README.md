# Phần mềm kế toán – kho – giá vốn theo lô cho nhà máy chế biến mắm

> Phiên bản: 1.0 · Ngày: 2026-10-07 · Người phụ trách: Quản lý dự án · Trạng thái: Chờ duyệt · Tên sản phẩm chưa chốt ([CH-56](docs/01-yeu-cau/CAU-HOI-MO.md#ch-56))
> Viết tắt: theo [THUAT-NGU](docs/00-tong-quan/THUAT-NGU.md) §2 (DDL: câu lệnh định nghĩa cơ sở dữ liệu; QC: kiểm tra chất lượng).

Dự án xây phần mềm kế toán, kho, giá vốn, giá thành và quản lý chất lượng chạy trên web (Web SaaS), dùng PostgreSQL. Khách hàng đầu tiên là một nhà máy chế biến mắm có 3 địa điểm (Nhà máy Bà Ba Thạo, Bình Tây, 97 Nguyễn Thái Học) và 16 người vận hành. Điểm chính: **giá vốn theo từng lô**, giải thích được từ lô nguyên liệu đến lô thành phẩm, tính lại ngay khi có chứng từ. Repo hiện chứa tài liệu dự án và một bản demo HTML; **chưa có mã nguồn sản phẩm**.

## Khách hàng và mục tiêu

- Yêu cầu gốc: `HỆ THỐNG.docx` (gốc repo, tài liệu của khách — không sửa) và file Excel sổ kho bán thành phẩm (không đưa vào repo).
- Mục tiêu giai đoạn 1 của khách: (1) hệ thống quản lý chất lượng; (2) số liệu, sổ sách theo dõi mua hàng → xuất hàng → giá thành ⇒ lãi lỗ. Gồm đủ 10 phân hệ: Tiền, Ngân hàng, Mua hàng, Bán hàng, Tài sản cố định, Công cụ dụng cụ, Kho, Giá thành, Tổng hợp, Báo cáo + phân hệ Chất lượng.
- Mục tiêu trọng tâm do người dùng chốt: giá vốn theo lô, giá nguyên liệu theo lô, giá thành theo lệnh sản xuất, tồn kho theo tên hàng + lô + mã hóa + vị trí (bồn / trái / phuy) — [QUYET-DINH](docs/02-ke-hoach/QUYET-DINH.md).

## Trạng thái hiện tại

| Hạng mục | Trạng thái | Tài liệu |
|---|---|---|
| Yêu cầu khách hàng | v1.3 — chờ khách xác nhận | [YEU-CAU-KHACH-HANG](docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) |
| Câu hỏi mở | 56 câu hỏi cho khách / người dùng + 12 việc xác minh văn bản; chưa câu nào được trả lời | [CAU-HOI-MO](docs/01-yeu-cau/CAU-HOI-MO.md) |
| Quyết định | 32 quyết định (26 đã chốt, 6 tạm chờ khách) | [QUYET-DINH](docs/02-ke-hoach/QUYET-DINH.md) |
| Kế hoạch, ước lượng | v0.5 — ~43–61 người-tháng; chờ chọn đội 5 hay 4 người | [KE-HOACH-DU-AN](docs/02-ke-hoach/KE-HOACH-DU-AN.md) |
| Thiết kế dữ liệu | DDL chạy nguyên văn trên PostgreSQL 16, 66 phép thử đạt; chưa chạy PostgreSQL 18 | [KIEN-TRUC-VA-CSDL](docs/03-thiet-ke/KIEN-TRUC-VA-CSDL.md), [DIEU-CHINH-THEO-KHACH-HANG](docs/03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) |
| Demo | v4.0 — giá nguyên liệu, giá vốn theo lô, giá thành theo lệnh, kho theo lô + vị trí, in phiếu; còn 8 điểm lệch tài liệu | [demo/CHANGELOG.md](demo/CHANGELOG.md), [demo/HUONG-DAN-DEMO.md](demo/HUONG-DAN-DEMO.md) |
| Phản biện | 3 vòng; vòng 3 đã xử lý, còn mở bồn trộn lô (CH-31) và lỗi demo L8 | [PHAN-BIEN-v3](docs/05-phan-bien/PHAN-BIEN-v3.md) §5 |
| Mã nguồn sản phẩm | Chưa bắt đầu | [KE-HOACH-DU-AN](docs/02-ke-hoach/KE-HOACH-DU-AN.md) §6 |

## Mở demo

- **Trên máy mình**: tải file [`demo/gia-goc-demo.html`](demo/gia-goc-demo.html) về máy, mở bằng **Google Chrome** (nhấp đúp hoặc kéo file vào cửa sổ Chrome). Không cần mạng, không cần cài đặt. Dữ liệu mẫu lưu trong trình duyệt; nút "Đặt lại dữ liệu mẫu" ở cuối thanh bên trái đưa về ban đầu.
- **Link xem trực tuyến**: (đang cập nhật)
- **Máy chủ demo** (thư mục [`deploy/`](deploy/)): trên một máy Ubuntu/Debian, chạy một lệnh

  ```bash
  curl -fsSL https://raw.githubusercontent.com/PhapDang2105/gia-goc-ke-toan/cap-nhat-theo-yeu-cau-khach-hang/deploy/cai-dat-may-chu.sh | sudo bash
  ```

  Script cài git + nginx, tải nhánh `cap-nhat-theo-yeu-cau-khach-hang` vào `/opt/gia-goc-ke-toan`, phục vụ thư mục `demo/` ở cổng 8080 và tự cập nhật từ GitHub mỗi 2 phút. Mở `http://IP-máy-chủ:8080/`. Cập nhật ngay không chờ: `sudo gia-goc-cap-nhat`. Chạy lại script nhiều lần không làm hỏng cài đặt cũ.
- Kịch bản trình diễn 10–15 phút cho khách: [demo/HUONG-DAN-DEMO.md](demo/HUONG-DAN-DEMO.md).

## Sơ đồ thư mục

```
.
├── README.md                     ← bạn đang đọc
├── HỆ THỐNG.docx                 ← tài liệu yêu cầu của khách (giữ nguyên, không sửa)
├── demo/
│   ├── gia-goc-demo.html         ← bản demo (một file HTML)
│   ├── CHANGELOG.md              ← nhật ký thay đổi demo, số chính, điểm lệch tài liệu
│   └── HUONG-DAN-DEMO.md         ← kịch bản trình diễn cho khách
├── deploy/
│   └── cai-dat-may-chu.sh        ← cài máy chủ demo (nginx cổng 8080, tự cập nhật)
└── docs/
    ├── 00-tong-quan/             ← đọc đầu tiên
    │   ├── TOM-TAT-DIEU-HANH.md  ← 1 trang cho Ban giám đốc
    │   └── THUAT-NGU.md          ← chữ viết tắt, thuật ngữ, quy ước mã, luật làm tròn R1
    ├── 01-yeu-cau/               ← khách cần gì
    │   ├── YEU-CAU-KHACH-HANG.md ← yêu cầu chuẩn hóa, truy vết yêu cầu → demo
    │   └── CAU-HOI-MO.md         ← mọi câu hỏi đang chờ trả lời
    ├── 02-ke-hoach/              ← làm gì, khi nào, vì sao
    │   ├── KE-HOACH-DU-AN.md     ← phạm vi theo đợt, ước lượng, rủi ro, bước tiếp theo
    │   └── QUYET-DINH.md         ← nhật ký quyết định
    ├── 03-thiet-ke/              ← làm thế nào
    │   ├── NGHIEP-VU-KE-TOAN.md  ← nghiệp vụ, định khoản, bất biến
    │   ├── KIEN-TRUC-VA-CSDL.md  ← kiến trúc, DDL nền, engine giá, khóa kỳ
    │   └── DIEU-CHINH-THEO-KHACH-HANG.md ← thay đổi dữ liệu theo khách: lô, vị trí, giá thành theo lệnh, QC…
    ├── 04-tham-khao/             ← nghiên cứu nền
    │   ├── REPO-MA-NGUON-MO.md
    │   ├── SACH-VA-VAN-BAN.md
    │   └── PHAN-TICH-MISA.md
    └── 05-phan-bien/             ← phản biện độc lập (đã xử lý, giữ để truy vết)
        ├── PHAN-BIEN-v2-NGHIEP-VU.md
        ├── PHAN-BIEN-v2-KIEN-TRUC.md
        ├── PHAN-BIEN-v3.md
        └── luu-tru/              ← phản biện bản demo xưởng gỗ cũ, chỉ để lưu
```

**Vì sao chia như vậy.** Thư mục đánh số theo thứ tự đọc: tổng quan → yêu cầu → kế hoạch → thiết kế → tham khảo → phản biện. Mỗi nội dung có **một nguồn duy nhất** ([QD-32](docs/02-ke-hoach/QUYET-DINH.md#qd-32)); tài liệu khác chỉ trích mã:

| Nội dung | Nguồn duy nhất | Mã dùng để trích |
|---|---|---|
| Yêu cầu | YEU-CAU-KHACH-HANG | `KHO-06`, `GT-10`, `NFR-01`… |
| Câu hỏi đang chờ | CAU-HOI-MO | `CH-nn`, `XM-nn` |
| Quyết định đã chốt | QUYET-DINH | `QD-nn` |
| Phạm vi theo đợt, tiến độ, rủi ro | KE-HOACH-DU-AN | §3, §5 |
| Thuật ngữ, quy ước mã, luật làm tròn R1 | THUAT-NGU | §2, §4, §5 |
| Kiểu lưu số, trình tự khóa kỳ | KIEN-TRUC-VA-CSDL | §1.4, §7.2 |
| Thay đổi demo, điểm lệch | demo/CHANGELOG.md | — |

Mỗi tài liệu có dòng đầu "Phiên bản · Ngày · Người phụ trách · Trạng thái (Nháp / Chờ duyệt / Đã duyệt)". Bỏ cách đánh số `research/01..07` cũ vì số không nói lên nội dung và tham chiếu kiểu "05 §7.2" khó đọc. Bảng đổi tên ở cuối trang.

## Đọc gì trước

| Người đọc | Đọc theo thứ tự | Thời gian |
|---|---|---|
| **Ban giám đốc** | [TOM-TAT-DIEU-HANH](docs/00-tong-quan/TOM-TAT-DIEU-HANH.md) → xem demo theo [HUONG-DAN-DEMO](demo/HUONG-DAN-DEMO.md) → [CAU-HOI-MO](docs/01-yeu-cau/CAU-HOI-MO.md) §2 (câu hỏi cho Ban giám đốc) | 20 phút |
| **Kế toán trưởng** | [YEU-CAU-KHACH-HANG](docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) §1–§3, §9 → [CAU-HOI-MO](docs/01-yeu-cau/CAU-HOI-MO.md) §3 → [THUAT-NGU](docs/00-tong-quan/THUAT-NGU.md) §4–§5 → [DIEU-CHINH-THEO-KHACH-HANG](docs/03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) §2.3, §4 (ví dụ số giá thành để duyệt) → [NGHIEP-VU-KE-TOAN](docs/03-thiet-ke/NGHIEP-VU-KE-TOAN.md) §5, §8 | 2–3 giờ |
| **Thủ kho, QC** | [CAU-HOI-MO](docs/01-yeu-cau/CAU-HOI-MO.md) §4, §5 → [YEU-CAU-KHACH-HANG](docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) §4, §5, §9 | 1 giờ |
| **Quản lý dự án, BA** | README → [KE-HOACH-DU-AN](docs/02-ke-hoach/KE-HOACH-DU-AN.md) → [QUYET-DINH](docs/02-ke-hoach/QUYET-DINH.md) → [CAU-HOI-MO](docs/01-yeu-cau/CAU-HOI-MO.md) → [YEU-CAU-KHACH-HANG](docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) | nửa ngày |
| **Lập trình viên** | [THUAT-NGU](docs/00-tong-quan/THUAT-NGU.md) → [QUYET-DINH](docs/02-ke-hoach/QUYET-DINH.md) → [KIEN-TRUC-VA-CSDL](docs/03-thiet-ke/KIEN-TRUC-VA-CSDL.md) → [DIEU-CHINH-THEO-KHACH-HANG](docs/03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) → [NGHIEP-VU-KE-TOAN](docs/03-thiet-ke/NGHIEP-VU-KE-TOAN.md) → [YEU-CAU-KHACH-HANG](docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) §3 (ma trận truy vết); nền: [REPO-MA-NGUON-MO](docs/04-tham-khao/REPO-MA-NGUON-MO.md), [SACH-VA-VAN-BAN](docs/04-tham-khao/SACH-VA-VAN-BAN.md) §7 | 1–2 ngày |
| **Người làm demo** | [demo/CHANGELOG.md](demo/CHANGELOG.md) (mục "Lệch so với tài liệu") → [YEU-CAU-KHACH-HANG](docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) §11 → [THUAT-NGU](docs/00-tong-quan/THUAT-NGU.md) §1 | 1 giờ |

## Chỉ mục tài liệu

| Tài liệu | Nội dung | Phiên bản · trạng thái |
|---|---|---|
| [TOM-TAT-DIEU-HANH](docs/00-tong-quan/TOM-TAT-DIEU-HANH.md) | Một trang: dự án, trạng thái, mốc, việc cần Ban giám đốc quyết | 1.0 · Chờ duyệt |
| [THUAT-NGU](docs/00-tong-quan/THUAT-NGU.md) | Chữ viết tắt, thuật ngữ, quy ước mã lô / mã hóa / số phiếu / vị trí / tài khoản / mã tài liệu, luật R1 | 1.0 · Chờ duyệt |
| [YEU-CAU-KHACH-HANG](docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md) | Ma trận truy vết 10 phân hệ + QC (mã yêu cầu, định khoản, đợt), ánh xạ 4 quy trình, ma trận vai trò, kế thừa file Excel kho, yêu cầu phi chức năng, truy vết sang demo | v1.3 · Chờ duyệt (khách) |
| [CAU-HOI-MO](docs/01-yeu-cau/CAU-HOI-MO.md) | CH-01..CH-56 theo người trả lời, mức chặn, mặc định; XM-01..XM-12; đối chiếu mã cũ | 1.0 · Chờ duyệt |
| [KE-HOACH-DU-AN](docs/02-ke-hoach/KE-HOACH-DU-AN.md) | Mục tiêu, phạm vi 1A/1B/1C, tiêu chí xong, ước lượng, rủi ro, bước tiếp theo | v0.5 · Chờ duyệt |
| [QUYET-DINH](docs/02-ke-hoach/QUYET-DINH.md) | QD-01..QD-32: quyết định, lý do, phương án đã loại, ảnh hưởng | 1.0 · Chờ duyệt |
| [NGHIEP-VU-KE-TOAN](docs/03-thiet-ke/NGHIEP-VU-KE-TOAN.md) | Pháp lý, tài khoản, phương pháp giá, giá thành, định khoản, bất biến | 1.2 · Chờ duyệt (KTT) |
| [KIEN-TRUC-VA-CSDL](docs/03-thiet-ke/KIEN-TRUC-VA-CSDL.md) | Stack, nhiều công ty thuê bao, DDL nền, engine giá vốn, truy xuất, nhật ký, khóa kỳ, kiểm thử | 0.3.1 · Chờ duyệt |
| [DIEU-CHINH-THEO-KHACH-HANG](docs/03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md) | Lô + QC + vị trí, đích danh, giá thành theo lệnh, giá vốn theo lô, ngoại tệ, TSCĐ/CCDC, khế ước, duyệt, LCTT, QC; 66 phép thử | 0.3.1 · Chờ duyệt |
| [REPO-MA-NGUON-MO](docs/04-tham-khao/REPO-MA-NGUON-MO.md) | ERPNext, Odoo, iDempiere…; giấy phép; học gì, tránh gì | 1.0 · Đã duyệt |
| [SACH-VA-VAN-BAN](docs/04-tham-khao/SACH-VA-VAN-BAN.md) | Sách, văn bản pháp lý, lộ trình đọc 4 tuần | 1.0 · Đã duyệt |
| [PHAN-TICH-MISA](docs/04-tham-khao/PHAN-TICH-MISA.md) | Phân hệ, giá gói, điểm yếu của MISA và đối thủ | 1.0 · Đã duyệt |
| [PHAN-BIEN-v2-NGHIEP-VU](docs/05-phan-bien/PHAN-BIEN-v2-NGHIEP-VU.md) | Phản biện vòng 2 về nghiệp vụ (25 lỗi) | lưu trữ |
| [PHAN-BIEN-v2-KIEN-TRUC](docs/05-phan-bien/PHAN-BIEN-v2-KIEN-TRUC.md) | Phản biện vòng 2 về kiến trúc | lưu trữ |
| [PHAN-BIEN-v3](docs/05-phan-bien/PHAN-BIEN-v3.md) | Phản biện vòng 3: demo, truy vết yêu cầu, DDL chạy thật; trạng thái xử lý | lưu trữ |
| [luu-tru/](docs/05-phan-bien/luu-tru/) | 3 bản phản biện demo xưởng gỗ cũ | lưu trữ |
| [demo/CHANGELOG.md](demo/CHANGELOG.md) | Nhật ký thay đổi demo, số chính, điểm lệch tài liệu | — |
| [demo/HUONG-DAN-DEMO.md](demo/HUONG-DAN-DEMO.md) | Kịch bản trình diễn 10–15 phút | 1.0 · Chờ duyệt |

## Bảng đổi tên (2026-10-07)

| Đường dẫn cũ | Đường dẫn mới |
|---|---|
| `docs/YEU-CAU-KHACH-HANG.md` | `docs/01-yeu-cau/YEU-CAU-KHACH-HANG.md` |
| `docs/KE-HOACH-DU-AN.md` | `docs/02-ke-hoach/KE-HOACH-DU-AN.md` |
| `docs/research/01-nghiep-vu-ke-toan.md` | `docs/03-thiet-ke/NGHIEP-VU-KE-TOAN.md` |
| `docs/research/05-kien-truc-de-xuat.md` | `docs/03-thiet-ke/KIEN-TRUC-VA-CSDL.md` |
| `docs/research/07-dieu-chinh-kien-truc-theo-khach-hang.md` | `docs/03-thiet-ke/DIEU-CHINH-THEO-KHACH-HANG.md` |
| `docs/research/02-repo-tham-khao.md` | `docs/04-tham-khao/REPO-MA-NGUON-MO.md` |
| `docs/research/03-sach-tai-lieu.md` | `docs/04-tham-khao/SACH-VA-VAN-BAN.md` |
| `docs/research/04-phan-tich-misa.md` | `docs/04-tham-khao/PHAN-TICH-MISA.md` |
| `docs/research/06a-phan-bien-nghiep-vu.md` | `docs/05-phan-bien/PHAN-BIEN-v2-NGHIEP-VU.md` |
| `docs/research/06b-phan-bien-kien-truc.md` | `docs/05-phan-bien/PHAN-BIEN-v2-KIEN-TRUC.md` |
| `docs/PHAN-BIEN-v3.md` | `docs/05-phan-bien/PHAN-BIEN-v3.md` |
| `demo/review-nghiep-vu.md` | `docs/05-phan-bien/luu-tru/DEMO-XUONG-GO-NGHIEP-VU.md` |
| `demo/review-thao-tac.md` | `docs/05-phan-bien/luu-tru/DEMO-XUONG-GO-THAO-TAC.md` |
| `demo/review-ui.md` | `docs/05-phan-bien/luu-tru/DEMO-XUONG-GO-GIAO-DIEN.md` |
| `demo/CHANGELOG-v3.md` + `demo/CHANGELOG-v2.md` | `demo/CHANGELOG.md` (gộp) |
