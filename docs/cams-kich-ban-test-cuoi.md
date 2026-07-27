# CAMS — KỊCH BẢN TEST CUỐI (PHẦN D)

> **Yêu cầu:** Chạy đủ tám kịch bản trên `localhost:8080`. Sau mỗi kịch bản, mở màn hình Manager kiểm tra doanh thu.
>
> **Trước khi bắt đầu:** Ghi lại số dư doanh thu hiện tại của Manager (màn hình Manage Revenue, chọn ngày hôm nay). Dùng làm mốc đối chiếu sau mỗi kịch bản.

---

## Chuẩn bị dữ liệu test

| # | Vai trò | Email đăng nhập | Mật khẩu | Ghi chú |
|---|---------|----------------|----------|---------|
| 1 | Patient | (tự tạo hoặc dùng tài khoản test) | — | Cần có hồ sơ: họ tên, SĐT, giới tính |
| 2 | Doctor | (bác sĩ lâm sàng có lịch làm việc hôm nay) | — | Có slot được Manager duyệt |
| 3 | Sonographer | (bác sĩ siêu âm) | — | — |
| 4 | Staff | (nhân viên lễ tân) | — | — |
| 5 | Manager | (quản lý) | — | Dùng để kiểm tra doanh thu sau mỗi KB |

> **Ghi chú trước khi test:** Điền email/mật khẩu thực tế vào bảng trên. Đảm bảo:
> - Bác sĩ lâm sàng có ít nhất 2 slot làm việc còn chỗ trong ngày hôm nay.
> - Bác sĩ siêu âm có tài khoản hoạt động.
> - AI Engine (Python) đang chạy cho KB1–KB3.
> - Manager có thể truy cập màn hình Manage Revenue.

---

## 📋 KỊCH BẢN 1 — Ca không siêu âm (Happy path cơ bản)

> **Mục tiêu:** Luồng khám cơ bản nhất: đặt lịch → duyệt → thu tiền → check-in → khám → chẩn đoán → kê đơn mua ngoài → chốt → bệnh nhân xem kết quả.

### Bước 1.1 — Bệnh nhân đặt lịch

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Đăng nhập với vai trò **Patient** | Vào trang chủ `/home` | ☐ |
| 2 | Nhấn "Đặt lịch khám mới" | Hiển thị danh sách bác sĩ | ☐ |
| 3 | Chọn một bác sĩ lâm sàng | Hiển thị **giá khám** của bác sĩ đó (VD: 300.000đ) | ☐ |
| 4 | Chọn ngày hôm nay | Hiển thị các slot còn chỗ | ☐ |
| 5 | Chọn một slot còn chỗ | Form nhập triệu chứng hiện ra | ☐ |
| 6 | Nhập triệu chứng: "Đau bụng dưới, thai 28 tuần" | — | ☐ |
| 7 | Nhấn "Xác nhận đặt lịch" | Màn hình xác nhận hiển thị đầy đủ: tên BS, ngày, giờ, **giá khám**, dòng "Thanh toán tại quầy lễ tân trước giờ khám" | ☐ |
| 8 | Nhấn "Đặt lịch" | Thành công, lịch hẹn hiển thị trạng thái "Chờ phòng khám duyệt" | ☐ |
| 9 | **Ghi lại:** ID lịch hẹn = `____`, Giá khám = `________đ` | — | ☐ |

### Bước 1.2 — Staff duyệt lịch và thu tiền

| # | Thao tác (vai trò **Staff**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Đăng nhập Staff, vào Reception Queue | Thấy lịch hẹn vừa đặt ở trạng thái "Chờ duyệt" | ☐ |
| 2 | Nhấn **Approve** (Duyệt) | Lịch chuyển sang "Đã duyệt", hệ thống tạo hoá đơn PRE_EXAM với số tiền **đúng bằng giá khám đã ghi ở B1.1** | ☐ |
| 3 | Vào danh sách hoá đơn của bệnh nhân này | Có đúng 1 hoá đơn PRE_EXAM, trạng thái "Chưa thanh toán", số tiền khớp | ☐ |
| 4 | Nhấn **Xác nhận thanh toán** (Pay) cho hoá đơn đó | Thành công. Hoá đơn chuyển sang "Đã thanh toán", có ghi thời điểm + người xác nhận + hình thức "CASH" | ☐ |
| 5 | Thử bấm xác nhận thanh toán **lần hai** cho cùng hoá đơn | **Bị chặn**, thông báo "Hoá đơn đã thanh toán rồi" | ☐ |

### Bước 1.3 — Staff check-in

| # | Thao tác (vai trò **Staff**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Nhấn **Check-in** cho lịch hẹn đã thanh toán | Thành công, chuyển sang "Chờ khám", có **số thứ tự** (VD: STT-01) | ☐ |
| 2 | **Ghi lại:** Số thứ tự = `____` | — | ☐ |

### Bước 1.4 — Bác sĩ tiếp nhận ca và khám lâm sàng

| # | Thao tác (vai trò **Doctor** - đúng bác sĩ được phân công) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Đăng nhập Doctor, vào "Lịch khám hôm nay" | Thấy bệnh nhân trong danh sách chờ khám | ☐ |
| 2 | Nhấn vào bệnh nhân → mở hồ sơ bệnh án | Màn hình 5 khối: **chỉ khối 1 (Tiếp nhận ca) mở**, khối 2–5 khoá | ☐ |
| 3 | Nhấn "Tiếp nhận ca" | Lịch chuyển sang "Đang khám", khối 2 (Khám lâm sàng) mở ra | ☐ |
| 4 | Nhập thông tin khám lâm sàng: cân nặng, huyết áp, chiều cao bề cao tử cung, tim thai… | Form nhập đầy đủ | ☐ |
| 5 | Nhấn "Lưu nháp" | Lưu thành công, khối 3 (Chỉ định cận lâm sàng) mở ra | ☐ |

### Bước 1.5 — Bác sĩ chọn "Không chỉ định" và chẩn đoán

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Ở khối 3, chọn **"Không chỉ định"** | Khối 4 (Chẩn đoán & Kê đơn) mở ra | ☐ |
| 2 | Nhập chẩn đoán: "Thai 28 tuần, đau bụng sinh lý, không dấu hiệu dọa sinh non" | — | ☐ |
| 3 | Kê đơn: thêm 1 thuốc (VD: Ferrous Sulfate), chọn **"Mua ngoài"** | Đơn thuốc được lưu, không tạo hoá đơn thuốc | ☐ |
| 4 | Nhấn "Lưu chẩn đoán" | Lưu thành công, khối 5 (Chốt hồ sơ) mở ra | ☐ |

### Bước 1.6 — Chốt hồ sơ và bệnh nhân xem kết quả

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Nhấn **"Chốt hồ sơ bệnh án"** | Thành công. Bệnh án → Final, lịch hẹn → Hoàn tất. **Cùng lúc**, không lệch. | ☐ |
| 2 | Toàn bộ màn hình hồ sơ chuyển sang **chỉ đọc** | Không còn nút sửa, không còn nút chốt | ☐ |
| 3 | Đăng xuất, đăng nhập lại với vai trò **Patient** của chính bệnh nhân đó | — | ☐ |
| 4 | Vào "Hồ sơ bệnh án" | **Thấy** hồ sơ vừa chốt (trước đó không thấy vì còn nháp) | ☐ |
| 5 | Nhấn vào xem chi tiết | Hiển thị đầy đủ: chẩn đoán, kết luận, đơn thuốc; không có nút sửa | ☐ |
| 6 | Kiểm tra thông báo | Bệnh nhân nhận được thông báo "Kết quả khám đã sẵn sàng" | ☐ |

### Bước 1.7 — Kiểm tra doanh thu (Manager)

| # | Thao tác (vai trò **Manager**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Đăng nhập Manager → Manage Revenue → chọn ngày hôm nay | Doanh thu **tăng đúng 300.000đ** (tiền phí khám). Chỉ có 1 hoá đơn PRE_EXAM đã thanh toán. | ☐ |
| 2 | Vào View Service Details | Danh sách hoá đơn khớp với tổng doanh thu | ☐ |

---

## 📋 KỊCH BẢN 2 — Ca có siêu âm, AI đúng

> **Mục tiêu:** Luồng có chỉ định siêu âm: bác sĩ chỉ định → staff thu tiền dịch vụ → sonographer siêu âm → đồng ý AI → ký → công bố → bác sĩ lâm sàng xem kết quả → chốt hồ sơ.

### Bước 2.1 — Đặt lịch và chuẩn bị (giống KB1 nhưng chưa chốt)

Lặp lại B1.1 → B1.4 (đặt lịch, duyệt, thu tiền phí khám, check-in, tiếp nhận ca, lưu khám lâm sàng).

### Bước 2.2 — Bác sĩ chỉ định siêu âm

| # | Thao tác (vai trò **Doctor**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Ở khối 3, chọn **"Chỉ định siêu âm"** | Form chọn dịch vụ siêu âm hiện ra | ☐ |
| 2 | Chọn dịch vụ (VD: "Siêu âm thai 2D") | — | ☐ |
| 3 | Nhập **lý do chỉ định**: "Kiểm tra chỉ số nước ối và vị trí thai nhi — bệnh nhân đau bụng dưới" (≥10 ký tự) | — | ☐ |
| 4 | Nhấn "Tạo chỉ định" | Thành công. Hoá đơn POST_EXAM được tạo (chưa thanh toán). Khối 4 & 5 bị **khoá**, hiển thị lý do: "Đang chờ bệnh nhân thanh toán dịch vụ siêu âm" | ☐ |
| 5 | **Ghi lại:** ID chỉ định = `____`, Số tiền dịch vụ = `________đ` | — | ☐ |

### Bước 2.3 — Staff thu tiền dịch vụ siêu âm

| # | Thao tác (vai trò **Staff**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Vào Reception Queue → tìm bệnh nhân | Thấy hoá đơn POST_EXAM với số tiền đúng bằng giá dịch vụ đã chọn | ☐ |
| 2 | Nhấn **Xác nhận thanh toán** cho hoá đơn POST_EXAM | Thành công. Trạng thái → Paid | ☐ |
| 3 | Bác sĩ lâm sàng tải lại trang hồ sơ | Khối 4 & 5 vẫn khoá, lý do đổi thành: "Đang chờ bác sĩ siêu âm trả kết quả" kèm nút "Tải lại" | ☐ |

### Bước 2.4 — Sonographer siêu âm (AI đúng)

| # | Thao tác (vai trò **Sonographer**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Đăng nhập Sonographer → Dashboard | Thấy ca siêu âm mới trong danh sách chờ | ☐ |
| 2 | Nhấn **"Tiếp nhận ca"** | Ca chuyển sang trạng thái đang siêu âm | ☐ |
| 3 | **Chụp và tải ảnh** (ít nhất 1 ảnh siêu âm) | Ảnh hiển thị trong gallery | ☐ |
| 4 | Nhấn **"Phân tích với AI"** | AI Engine xử lý, trả về kết quả (có bounding box, nhãn…) | ☐ |
| 5 | Xem kết quả AI → nhấn **"Đồng ý với kết quả AI"** (Accept) | Chuyển sang bước điền thông tin | ☐ |
| 6 | Điền thông tin kết quả siêu âm (chỉ số, nhận xét…) | — | ☐ |
| 7 | Nhấn **"Ký và xác nhận"** | Thành công. | ☐ |
| 8 | Nhấn **"Công bố kết quả"** | Ca siêu âm hoàn thành. | ☐ |

### Bước 2.5 — Bác sĩ lâm sàng xem kết quả và chốt

| # | Thao tác (vai trò **Doctor**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Đăng nhập Doctor, mở lại hồ sơ bệnh án của ca này | Khối 4 **đã mở**. Hiển thị kết quả siêu âm ở chế độ **chỉ đọc**: ảnh, kết quả AI, kết luận của sonographer. | ☐ |
| 2 | **Thử sửa** kết luận siêu âm | **Không sửa được** (chỉ đọc) | ☐ |
| 3 | Nhấn "Xác nhận đã xem kết quả siêu âm" | — | ☐ |
| 4 | Nhập chẩn đoán: "Thai 28 tuần, chỉ số nước ối bình thường, ngôi thuận" | — | ☐ |
| 5 | Kê đơn: chọn **"Mua tại phòng khám"** → thêm thuốc | Tạo hoá đơn PRESCRIPTION chưa thanh toán | ☐ |
| 6 | Nhấn **"Chốt hồ sơ"** | Thành công. Bệnh án → Final, lịch hẹn → Hoàn tất. | ☐ |
| 7 | **Ghi chú:** Hoá đơn thuốc vẫn chưa thanh toán nhưng hồ sơ đã chốt được (đúng nghiệp vụ: BS xong việc, thuốc do staff xử lý sau). | — | ☐ |

### Bước 2.6 — Kiểm tra doanh thu (Manager)

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Manager → Manage Revenue → hôm nay | Doanh thu tăng thêm: phí khám + phí siêu âm (thuốc chưa thanh toán nên chưa tính) | ☐ |
| 2 | Staff thu tiền hoá đơn thuốc → Manager kiểm tra lại | Doanh thu tăng thêm đúng tiền thuốc | ☐ |

---

## 📋 KỊCH BẢN 3 — Ca có siêu âm, AI sai → vẽ tay

> **Mục tiêu:** Sonographer từ chối kết quả AI, chọn nhánh vẽ tay. Kiểm tra validate: chưa vẽ mà ký → bị chặn.

### Bước 3.1 — Chuẩn bị ca giống KB2 đến bước phân tích AI

Lặp lại B2.1 → B2.4 bước 4 (tải ảnh, phân tích AI xong).

### Bước 3.2 — Từ chối AI và vẽ tay

| # | Thao tác (vai trò **Sonographer**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Nhấn **"Từ chối kết quả AI"** (Reject) | Chuyển sang chế độ vẽ tay | ☐ |
| 2 | **CHƯA vẽ gì cả** → nhấn **"Ký và xác nhận"** | **Bị chặn ở server!** Thông báo: "Bạn phải vẽ ít nhất một hình trước khi ký" (tiếng Việt) | ☐ |
| 3 | Vẽ thủ công 1–2 hình (annotation) lên ảnh siêu âm | Hình vẽ được lưu | ☐ |
| 4 | Điền thông tin kết quả | — | ☐ |
| 5 | Nhấn **"Ký và xác nhận"** lần nữa | Thành công (đã có hình vẽ) | ☐ |
| 6 | Nhấn **"Công bố kết quả"** | Ca siêu âm hoàn thành | ☐ |

### Bước 3.3 — Bác sĩ chốt hồ sơ và kiểm tra doanh thu

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Doctor mở hồ sơ → thấy kết quả siêu âm (có cả hình vẽ tay) | Hiển thị đúng, chỉ đọc | ☐ |
| 2 | Chẩn đoán, kê đơn, chốt hồ sơ | Thành công | ☐ |
| 3 | Manager kiểm tra doanh thu | Tăng đúng phí khám + phí siêu âm | ☐ |

---

## 📋 KỊCH BẢN 4 — AI Engine chết → vẽ tay hoàn toàn

> **Mục tiêu:** Khi AI Engine không hoạt động, sonographer vẫn hoàn thành được ca bằng cách vẽ tay hoàn toàn, không bị kẹt.

### Bước 4.1 — Tắt AI Engine

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | **Tắt service Python** (AI Engine) — dừng process hoặc tắt API | AI Engine không phản hồi | ☐ |

### Bước 4.2 — Làm một ca siêu âm hoàn chỉnh không qua AI

| # | Thao tác (vai trò **Sonographer**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Tạo ca mới (bác sĩ chỉ định siêu âm như KB2, staff thu tiền) | Có ca siêu âm mới trong danh sách chờ | ☐ |
| 2 | Sonographer tiếp nhận ca, tải ảnh | Ảnh hiển thị | ☐ |
| 3 | Nhấn **"Phân tích với AI"** | AI Engine lỗi / timeout → hiển thị thông báo lỗi tiếng Việt: "Không thể kết nối tới AI Engine" | ☐ |
| 4 | Hệ thống cho phép **"Bỏ qua AI, vẽ thủ công"** | Nút này hiện ra, nhấn được | ☐ |
| 5 | Vẽ tay annotation lên ảnh | Hình vẽ được lưu | ☐ |
| 6 | Điền thông tin, ký, công bố | **Hoàn thành bình thường**, không kẹt | ☐ |
| 7 | Kiểm tra audit log | Có log ghi "Ca siêu âm không qua AI" | ☐ |
| 8 | Doctor chốt hồ sơ | Thành công | ☐ |
| 9 | Manager kiểm tra doanh thu | Tăng đúng | ☐ |

### Bước 4.3 — Bật lại AI Engine

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | **Bật lại AI Engine** | Sẵn sàng cho KB tiếp theo | ☐ |

---

## 📋 KỊCH BẢN 5 — Bệnh nhân bỏ siêu âm (huỷ chỉ định)

> **Mục tiêu:** Bác sĩ chỉ định siêu âm nhưng bệnh nhân không làm → bác sĩ huỷ chỉ định → vẫn chốt được hồ sơ. Không có ca treo.

### Bước 5.1 — Chuẩn bị ca có chỉ định siêu âm chưa thanh toán

Lặp lại B2.1 → B2.2 (đặt lịch, duyệt, thu tiền phí khám, check-in, khám lâm sàng, chỉ định siêu âm). **Không thu tiền dịch vụ siêu âm.**

### Bước 5.2 — Bác sĩ huỷ chỉ định

| # | Thao tác (vai trò **Doctor**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Ở khối 3 của hồ sơ bệnh án, nhấn **"Huỷ chỉ định siêu âm"** | Nút hiện ra (vì hoá đơn POST_EXAM chưa thanh toán, sonographer chưa tiếp nhận) | ☐ |
| 2 | Nhập lý do huỷ: "Bệnh nhân không đủ tiền làm siêu âm, đồng ý chẩn đoán trên lâm sàng" (≥10 ký tự) | — | ☐ |
| 3 | Nhấn "Xác nhận huỷ" | Thành công. Chỉ định bị huỷ, hoá đơn POST_EXAM bị huỷ. | ☐ |
| 4 | Tải lại trang | Khối 4 (Chẩn đoán) **mở ra**, không còn bị khoá | ☐ |
| 5 | Nhập chẩn đoán, kê đơn, **chốt hồ sơ** | **Thành công.** Không có ca treo. | ☐ |
| 6 | Manager kiểm tra doanh thu | Chỉ có phí khám, không có phí siêu âm (vì đã huỷ) | ☐ |

### Bước 5.3 — Thử huỷ khi đã thanh toán (phải bị chặn)

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Tạo ca mới, chỉ định siêu âm, **staff thu tiền** dịch vụ | Hoá đơn POST_EXAM đã Paid | ☐ |
| 2 | Doctor mở hồ sơ, khối 3 | **Nút "Huỷ chỉ định" không hiện** (vì đã thanh toán) | ☐ |
| 3 | Dùng công cụ HTTP (Postman/curl) POST thẳng vào action huỷ chỉ định | **Bị chặn ở server**, thông báo "Bệnh nhân đã thanh toán, liên hệ quầy lễ tân để xử lý" | ☐ |

---

## 📋 KỊCH BẢN 6 — Bệnh nhân đổi lịch

> **Mục tiêu:** Bệnh nhân tự đổi sang slot khác cùng bác sĩ. Kiểm tra tổng số chỗ không đổi.

### Bước 6.1 — Đặt lịch ban đầu

| # | Thao tác (vai trò **Patient**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Đặt một lịch hẹn với bác sĩ X, slot A (chưa thanh toán) | Thành công, trạng thái "Chờ duyệt" | ☐ |
| 2 | **Ghi lại:** Slot A: booked_count trước khi đổi = `____` | — | ☐ |
| 3 | Staff duyệt lịch (nhưng **chưa thu tiền**) | Trạng thái "Đã duyệt — chưa thanh toán" | ☐ |

### Bước 6.2 — Đổi lịch

| # | Thao tác (vai trò **Patient**) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Vào "Lịch hẹn của tôi" → nhấn **"Đổi lịch hẹn"** | Nút hiện ra (cùng bác sĩ, chưa thanh toán, chưa check-in, còn ≥2h trước giờ khám) | ☐ |
| 2 | Chọn slot B khác của **cùng bác sĩ X** | Hiển thị các slot còn chỗ | ☐ |
| 3 | Nhấn "Xác nhận đổi" | Thành công. Lịch hẹn cập nhật slot mới, giá khám **giữ nguyên** | ☐ |
| 4 | **Kiểm tra:** Slot A: booked_count **giảm 1** (trả chỗ) | Đúng | ☐ |
| 5 | **Kiểm tra:** Slot B: booked_count **tăng 1** | Đúng | ☐ |
| 6 | **Tổng booked_count toàn hệ thống không đổi** | Slot A giảm 1 + Slot B tăng 1 = tổng không đổi | ☐ |

### Bước 6.3 — Giới hạn số lần đổi

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Đổi lịch **lần thứ hai** | Thành công (tối đa 2 lần) | ☐ |
| 2 | Thử đổi lịch **lần thứ ba** | **Bị chặn**, thông báo "Bạn đã đổi lịch tối đa 2 lần" | ☐ |

### Bước 6.4 — Chống đổi khi đã thanh toán

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Với lịch đã thanh toán phí khám: nút "Đổi lịch" | **Không hiện** | ☐ |
| 2 | POST thẳng vào action đổi lịch | **Bị chặn**, thông báo "Bạn đã thanh toán, liên hệ quầy lễ tân" | ☐ |

### Bước 6.5 — Kiểm tra doanh thu (Manager)

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Manager → Manage Revenue | Doanh thu không bị ảnh hưởng bởi việc đổi lịch (vì chưa có giao dịch tiền mới) | ☐ |

---

## 📋 KỊCH BẢN 7 — Không đến và hoàn tiền

> **Mục tiêu:** Một ca đánh dấu không đến (chưa thanh toán), một ca hoàn tiền (đã thanh toán). Đối chiếu doanh thu Manager.

### Bước 7.1 — Đánh dấu "Không đến" (chưa thanh toán)

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Tạo lịch hẹn, staff duyệt nhưng **chưa thu tiền** | Trạng thái "Đã duyệt — chưa thanh toán" | ☐ |
| 2 | Đợi qua giờ kết thúc ca của ngày hôm nay (hoặc dùng slot quá khứ) | — | ☐ |
| 3 | Staff → Reception Queue → nhấn **"Không đến"** (No Show) | Thành công | ☐ |
| 4 | **Kiểm tra:** lịch hẹn → "Không đến khám" | Đúng | ☐ |
| 5 | **Kiểm tra:** hoá đơn PRE_EXAM chưa thanh toán → **bị huỷ** | Đúng | ☐ |
| 6 | **Kiểm tra:** slot → booked_count **giảm 1** (trả chỗ) | Đúng | ☐ |
| 7 | Manager kiểm tra doanh thu | **Không tăng** (vì chưa thu tiền, hoá đơn đã huỷ) | ☐ |

### Bước 7.2 — Hoàn tiền (đã thanh toán rồi mới huỷ)

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Tạo lịch hẹn mới, staff duyệt, **thu tiền phí khám** | Hoá đơn PRE_EXAM đã Paid. **Ghi lại:** mã hoá đơn = `____`, số tiền = `________đ` | ☐ |
| 2 | Staff → nhấn **"Hoàn tiền"** (Refund) cho hoá đơn đó | Hiện form: nhập lý do hoàn tiền | ☐ |
| 3 | Nhập lý do: "Bệnh nhân huỷ lịch đột xuất, đã liên hệ trước" → Xác nhận | Thành công. Hoá đơn → Refunded. Ghi nhận: thời điểm hoàn, người hoàn, lý do. | ☐ |
| 4 | **Kiểm tra:** lịch hẹn → "Đã huỷ" | Đúng | ☐ |
| 5 | **Kiểm tra:** slot → booked_count giảm 1 | Đúng | ☐ |
| 6 | Thử hoàn tiền **lần hai** cho cùng hoá đơn | **Bị chặn**, thông báo "Hoá đơn đã được hoàn tiền" | ☐ |

### Bước 7.3 — Đối chiếu doanh thu (Manager)

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Manager → Manage Revenue → chọn ngày hôm nay | **Tổng doanh thu đã trừ khoản hoàn tiền** ở B7.2 | ☐ |
| 2 | View Service Details | Dòng hoá đơn đã hoàn hiển thị trạng thái "Đã hoàn tiền", không cộng vào tổng | ☐ |
| 3 | Xác nhận: Doanh thu = Tổng Paid − Tổng Refunded | Khớp | ☐ |

---

## 📋 KỊCH BẢN 8 — Thử phá (Security & Robustness)

> **Mục tiêu:** Xác nhận hệ thống chống được các hành vi cố ý hoặc vô ý gây hỏng dữ liệu.

### 8.1 — Sửa ID trên URL

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | **Patient:** Xem lịch hẹn của mình (ID=100). Sửa URL thành ID=101 (của người khác) | Bị từ chối / redirect, thông báo "Bạn không có quyền xem lịch hẹn này" | ☐ |
| 2 | **Patient:** Xem hồ sơ bệnh án (ID=50 của mình). Sửa URL thành ID=51 (của người khác) | Bị từ chối | ☐ |
| 3 | **Patient:** Xem hoá đơn. Sửa URL sang ID hoá đơn của người khác | Bị từ chối | ☐ |
| 4 | **Patient:** Xem kết quả siêu âm. Sửa URL sang ID của người khác | Bị từ chối | ☐ |
| 5 | **Doctor:** Mở hồ sơ bệnh án của bệnh nhân được phân công cho bác sĩ khác | Bị từ chối | ☐ |
| 6 | **Sonographer:** Mở ca siêu âm đã được sonographer khác tiếp nhận | Bị từ chối | ☐ |

### 8.2 — POST thẳng vào action sai bước

| # | Thao tác (dùng Postman/curl, có cookie session hợp lệ) | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | **Doctor:** Ca mới chưa có bệnh án → POST thẳng action "Chốt hồ sơ" | Bị chặn, thông báo bước hiện tại và cần làm gì trước | ☐ |
| 2 | **Doctor:** Ca đang chờ siêu âm → POST thẳng action "Chẩn đoán" | Bị chặn: "Đang chờ kết quả siêu âm" | ☐ |
| 3 | **Sonographer:** Chưa tải ảnh → POST thẳng action "Ký và xác nhận" | Bị chặn | ☐ |
| 4 | **Sonographer:** Chưa ký → POST thẳng action "Công bố kết quả" | Bị chặn | ☐ |
| 5 | **Staff:** Lịch chưa thanh toán → POST thẳng action "Check-in" | Bị chặn: "Bệnh nhân chưa thanh toán phí khám" | ☐ |

### 8.3 — Bấm nút hai lần liên tiếp (chống gửi trùng)

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | **Patient:** Đặt lịch → bấm nút "Đặt lịch" 2 lần nhanh | Chỉ tạo 1 lịch hẹn, booked_count chỉ tăng 1 | ☐ |
| 2 | **Patient:** Huỷ lịch → bấm "Xác nhận huỷ" 2 lần | Chỉ xử lý 1 lần, booked_count chỉ giảm 1 | ☐ |
| 3 | **Patient:** Đổi lịch → bấm "Xác nhận đổi" 2 lần | Chỉ đổi 1 lần, slot cũ -1, slot mới +1 | ☐ |
| 4 | **Staff:** Xác nhận thanh toán → bấm 2 lần | Lần 2 bị chặn, không nhân đôi doanh thu | ☐ |
| 5 | **Staff:** Check-in → bấm 2 lần | Chỉ check-in 1 lần, không cấp 2 số thứ tự | ☐ |
| 6 | **Doctor:** Chốt hồ sơ → bấm 2 lần | Chỉ chốt 1 lần, không tạo trùng | ☐ |
| 7 | **Sonographer:** Công bố kết quả → bấm 2 lần | Chỉ công bố 1 lần | ☐ |

### 8.4 — Kiểm tra quyền vai trò (Role Zone)

| # | Thao tác | Kết quả mong đợi | Đạt? |
|---|----------|-----------------|------|
| 1 | Patient gõ URL `/doctor/dashboard` | Bị chặn 403 | ☐ |
| 2 | Patient gõ URL `/staff/dashboard` | Bị chặn 403 | ☐ |
| 3 | Patient gõ URL `/sonographer/dashboard` | Bị chặn 403 | ☐ |
| 4 | Patient gõ URL `/manager/dashboard` | Bị chặn 403 | ☐ |
| 5 | Doctor gõ URL `/admin/reception` | Bị chặn 403 | ☐ |
| 6 | Staff gõ URL `/doctor/medical-records` | Bị chặn 403 | ☐ |

---

## 📊 BẢNG TỔNG KẾT DOANH THU

> Điền sau mỗi kịch bản. Manager → Manage Revenue → chọn ngày hôm nay.

| Sau KB | PRE_EXAM (Phí khám) | POST_EXAM (Dịch vụ) | PRESCRIPTION (Thuốc) | REFUNDED (Hoàn tiền) | TỔNG THỰC THU | Khớp dự kiến? |
|--------|---------------------|---------------------|-----------------------|---------------------|---------------|---------------|
| Trước test | | | | | | — |
| KB1 | | | | | | ☐ |
| KB2 | | | | | | ☐ |
| KB3 | | | | | | ☐ |
| KB4 | | | | | | ☐ |
| KB5 | | | | | | ☐ |
| KB6 | | | | | | ☐ |
| KB7 | | | | | | ☐ |
| KB8 | | | | | | ☐ |

---

## 🏁 KẾT LUẬN

| # | Kịch bản | Kết quả | Ghi chú / Lỗi phát hiện |
|---|----------|---------|-------------------------|
| 1 | Ca không siêu âm | ☐ Đạt / ☐ Lỗi | |
| 2 | Siêu âm, AI đúng | ☐ Đạt / ☐ Lỗi | |
| 3 | Siêu âm, AI sai → vẽ tay | ☐ Đạt / ☐ Lỗi | |
| 4 | AI Engine chết | ☐ Đạt / ☐ Lỗi | |
| 5 | Huỷ chỉ định siêu âm | ☐ Đạt / ☐ Lỗi | |
| 6 | Bệnh nhân đổi lịch | ☐ Đạt / ☐ Lỗi | |
| 7 | Không đến & hoàn tiền | ☐ Đạt / ☐ Lỗi | |
| 8 | Thử phá (security) | ☐ Đạt / ☐ Lỗi | |

**Ngày test:** ____/____/2026
**Người test:** ________________
**Chữ ký:** ________________
