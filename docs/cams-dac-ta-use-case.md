# CAMS — Sửa use case và đặc tả để code đúng luồng

Phần A: danh sách thao tác cụ thể trong draw.io.
Phần B: đặc tả use case — nơi chứa các ràng buộc mà sơ đồ không diễn tả được.
Phần C: ánh xạ use case sang code.

---

# PHẦN A — Thao tác sửa sơ đồ

## Quy ước hướng mũi tên UML (kiểm tra lại toàn bộ sơ đồ theo hai dòng này)

- `<<include>>` — mũi tên đứt nét đi **từ use case cơ sở TRỎ ĐẾN use case được gồm**. Nghĩa: luôn luôn xảy ra.
- `<<extend>>` — mũi tên đứt nét đi **từ use case mở rộng TRỎ VỀ use case cơ sở**. Nghĩa: chỉ xảy ra trong một số điều kiện.

Nhớ ngược lại là lỗi hay bị bắt nhất khi review.

---

## A1. Patient — 1 thao tác

| # | Thao tác |
|---|---|
| 1 | **Xoá** ellipse `Schedule a new appointment` và mũi tên extend của nó. Trùng hoàn toàn với `Book Appointment`. |

Giữ nguyên tất cả phần còn lại, kể cả `Change my appointment`.

---

## A2. Doctor — 4 thao tác

| # | Thao tác |
|---|---|
| 1 | **Xoá** mũi tên `<<include>>` từ `Order Ultrasound` sang `Diagnose and Prescribe`. |
| 2 | **Di chuyển** ellipse `Diagnose and Prescribe` xuống dưới `Update Medical Record`, rồi vẽ mũi tên đứt nét `<<extend>>` từ `Diagnose and Prescribe` **trỏ về** `Update Medical Record`. |
| 3 | **Thêm** ellipse `Finalize Medical Record`, mũi tên `<<extend>>` trỏ về `Update Medical Record`. |
| 4 | **Thêm** ellipse `Cancel Ultrasound Order`, mũi tên `<<extend>>` trỏ về `Order Ultrasound`. |

Kết quả: `Update Medical Record` có ba nhánh mở rộng song song — `Order Ultrasound`, `Diagnose and Prescribe`, `Finalize Medical Record`. Không nhánh nào nối tiếp nhánh nào.

Không cần thêm `Accept Consultation` hay `View Ultrasound Result` — hai việc này ghi trong đặc tả của `View Today's Appointments` và `Update Medical Record`.

---

## A3. Sonographer — 3 thao tác, không thêm ellipse nào

| # | Thao tác |
|---|---|
| 1 | **Xoá** mũi tên `<<include>>` từ `Analyze with AI` sang `Publish Results`. |
| 2 | **Xoá** hai mũi tên `<<extend>>` từ `Accept AI Result` và `Reject AI Result` sang `Publish Results`. Vẽ lại cả hai `<<extend>>` trỏ về `Analyze with AI`. |
| 3 | **Thêm** mũi tên `<<include>>` từ `Sign and Confirm` sang `Publish Results`. |

Chuỗi đúng sau khi sửa, đọc từ trên xuống:

```
Accept Ultrasound Case
  <<include>> Capture and Upload Images
    <<include>> Analyze with AI
      <<extend>> Accept AI Result
        <<include>> Update Ultrasound Result Information
      <<extend>> Reject AI Result
        <<include>> Draw Manually
          <<include>> Update Ultrasound Result Information
            <<include>> Sign and Confirm
              <<include>> Publish Results
```

`Publish Results` chính là bước 4 "hoàn thành siêu âm" trong mô tả nghiệp vụ của bạn — nó phải đứng cuối, không phải giữa.

**Tuỳ chọn:** nếu muốn xử lý tình huống AI Engine chết, thêm ellipse `Skip AI Analysis` với `<<extend>>` trỏ về `Analyze with AI`. Nếu không thêm vào sơ đồ thì phải ghi trong đặc tả.

---

## A4. Staff — 3 thao tác

| # | Thao tác |
|---|---|
| 1 | **Xoá** ellipse `Change Appointment Status`. **Thêm** ba ellipse thay thế, tất cả `<<extend>>` trỏ về `View Reception Queue`: `Approve Booking`, `Check In Patient`, `Cancel Appointment`. |
| 2 | **Đổi tên** `Update Medical Record` thành `Create Initial Patient Record`. |
| 3 | **Thêm** ellipse `Mark Priority`, `<<extend>>` trỏ về `View Reception Queue`. Chức năng này đã có trong code nhưng chưa có trong đặc tả. |

Lý do thao tác 1: ba hành động này có điều kiện và hệ quả hoàn toàn khác nhau — duyệt lịch thì phát hoá đơn, check-in thì bắt buộc đã thanh toán, huỷ lịch thì phải trả slot. Gộp một tên chung thì người code sẽ làm một dropdown cho staff chọn trạng thái tuỳ ý, và bệnh nhân sẽ nhảy được từ Pending thẳng sang SUCCESS.

**Tuỳ chọn:** `Update Reception Information` nếu không định nghĩa được bằng một câu thì xoá luôn.

---

## A5. Manager — 2 thao tác

| # | Thao tác |
|---|---|
| 1 | **Xoá** ellipse `Check In` và mũi tên extend của nó. Đây là việc của Staff, và cũng không liên quan gì tới `Manage Medical Services`. |
| 2 | **Xoá** ellipse `Confirm Payment` và mũi tên extend của nó. Cùng lý do. |

Giữ nguyên phần còn lại. `Manage Revenue`, `Manage Medical Services`, `View Price Adjustment History`, `Approve schedule bookings` đều đúng và quan trọng.

---

## Tổng kết khối lượng

| Sơ đồ | Xoá | Thêm | Sửa mũi tên / đổi tên |
|---|---|---|---|
| Patient | 1 ellipse | 0 | 0 |
| Doctor | 1 mũi tên | 2 ellipse | 1 mũi tên |
| Sonographer | 3 mũi tên | 0 | 3 mũi tên |
| Staff | 1 ellipse | 4 ellipse | 1 đổi tên |
| Manager | 2 ellipse | 0 | 0 |

---

# PHẦN B — Đặc tả use case cốt lõi

Đây là phần quyết định code đúng hay sai. Sơ đồ use case **không diễn tả được thứ tự thời gian và điều kiện** — tất cả nằm ở đây.

Định dạng: tiền điều kiện → luồng chính → luồng thay thế → hậu điều kiện.

---

## B1. Book Appointment — Patient

**Tiền điều kiện:** đã đăng nhập với vai trò bệnh nhân; hồ sơ cá nhân đã có đủ họ tên, số điện thoại, giới tính.

**Luồng chính:**
1. Bệnh nhân chọn bác sĩ từ danh sách.
2. Hệ thống hiển thị **giá khám của bác sĩ đó**.
3. Bệnh nhân chọn ngày, hệ thống hiển thị các slot còn chỗ của lịch làm việc đã được Manager duyệt.
4. Bệnh nhân chọn slot, nhập triệu chứng, nhập LMP nếu là bệnh nhân nữ.
5. Hệ thống xác nhận lại toàn bộ thông tin kèm số tiền và dòng "thanh toán tại quầy lễ tân trước giờ khám".
6. Bệnh nhân xác nhận, hệ thống tạo lịch hẹn ở trạng thái Pending.

**Luồng thay thế:**
- Slot vừa hết chỗ do người khác đặt trước → báo lỗi, tải lại danh sách slot.
- Bệnh nhân đã có lịch hẹn còn hiệu lực trong cùng ngày → từ chối.
- Slot thuộc quá khứ hoặc sắp bắt đầu → từ chối.
- Bệnh nhân bấm gửi hai lần hoặc F5 gửi lại → chỉ tạo một lịch hẹn.

**Hậu điều kiện:**
- Lịch hẹn Pending được tạo, **giá khám được lưu cứng vào bản ghi lịch hẹn** — Manager đổi bảng giá sau này không làm đổi giá của lịch này.
- `booked_count` của slot tăng 1 trong cùng transaction.
- Bác sĩ nhận thông báo, bệnh nhân nhận thông báo, ghi audit log.
- **Chưa có hoá đơn nào được tạo.**

---

## B2. Cancel Appointment — Patient

**Tiền điều kiện:** lịch hẹn thuộc về chính bệnh nhân; trạng thái Pending hoặc Confirmed; **hoá đơn phí khám chưa thanh toán**; chưa check-in; còn cách giờ bắt đầu ca ít nhất 2 giờ.

**Luồng chính:** bệnh nhân chọn huỷ → xác nhận → nhập lý do (không bắt buộc) → hệ thống huỷ.

**Luồng thay thế:**
- Hoá đơn đã thanh toán → không cho huỷ, hiển thị "vui lòng liên hệ quầy lễ tân".
- Bấm huỷ hai lần → lần thứ hai không xử lý, không giảm `booked_count` lần nữa.

**Hậu điều kiện:** trạng thái Cancelled; hoá đơn chưa thanh toán bị huỷ; `booked_count` giảm 1; bác sĩ nhận thông báo; audit log. Tất cả trong một transaction.

---

## B3. Approve Booking — Staff

**Tiền điều kiện:** lịch hẹn ở trạng thái Pending.

**Luồng chính:** staff xem hàng đợi → duyệt lịch → hệ thống chuyển sang Confirmed và **tạo hoá đơn PRE_EXAM ở trạng thái chưa thanh toán, số tiền copy nguyên từ giá đã lưu trong lịch hẹn**.

**Luồng thay thế:** lịch đã có hoá đơn PRE_EXAM → không tạo trùng.

**Hậu điều kiện:** Confirmed; tồn tại đúng một hoá đơn PRE_EXAM chưa thanh toán; bệnh nhân nhận thông báo cần ra quầy thanh toán kèm số tiền.

---

## B4. Confirm Payment — Staff

**Tiền điều kiện:** hoá đơn tồn tại và đang ở trạng thái chưa thanh toán; bệnh nhân đã đưa tiền mặt tại quầy.

**Luồng chính:** staff tìm hoá đơn → xác nhận đã nhận tiền → hệ thống chuyển hoá đơn sang đã thanh toán.

**Luồng thay thế:**
- Hoá đơn đã thanh toán rồi → từ chối, không ghi đè, không nhân đôi doanh thu.
- Hoá đơn đã huỷ → từ chối.

**Hậu điều kiện:** hoá đơn Paid, ghi đủ **thời điểm thanh toán, staff nào xác nhận, hình thức tiền mặt**; audit log; khoản tiền xuất hiện ngay trong báo cáo doanh thu của Manager. Áp dụng chung cho cả ba loại hoá đơn PRE_EXAM, POST_EXAM, PRESCRIPTION.

---

## B5. Check In Patient — Staff

**Tiền điều kiện:** lịch hẹn Confirmed; của **ngày hôm nay**; **hoá đơn PRE_EXAM đã thanh toán**; chưa check-in; đang trong khung giờ cho phép check-in.

**Luồng chính:** staff bấm check-in → hệ thống chuyển sang Waiting và cấp số thứ tự.

**Luồng thay thế:** chưa thanh toán → từ chối kèm thông báo rõ "bệnh nhân chưa thanh toán phí khám".

**Hậu điều kiện:** trạng thái Waiting; có số thứ tự; hàng đợi được xếp lại theo ưu tiên rồi tới khung giờ; bệnh nhân xem được số của mình.

---

## B6. Update Medical Record — Doctor

**Tiền điều kiện:** lịch hẹn ở trạng thái InProgress; bác sĩ đang đăng nhập đúng là bác sĩ được phân công.

**Luồng chính:** bác sĩ nhập triệu chứng, tiền sử, khám lâm sàng → lưu ở trạng thái nháp.

**Hậu điều kiện:** tồn tại bệnh án nháp; **mở khoá** `Order Ultrasound` và `Diagnose and Prescribe`.

> Việc chuyển lịch hẹn từ Waiting sang InProgress (tiếp nhận ca) nằm trong đặc tả của `View Today's Appointments`, không cần use case riêng.

---

## B7. Order Ultrasound — Doctor

**Tiền điều kiện:** bệnh án nháp đã tồn tại; lịch hẹn InProgress.

**Luồng chính:** bác sĩ chọn dịch vụ siêu âm từ danh mục do Manager quản lý → **nhập lý do chỉ định, bắt buộc, 10 đến 500 ký tự** → hệ thống tạo yêu cầu và tạo hoá đơn POST_EXAM chưa thanh toán, số tiền lấy từ bảng giá dịch vụ tại thời điểm chỉ định.

**Hậu điều kiện:** yêu cầu siêu âm được tạo; hoá đơn POST_EXAM chưa thanh toán; bệnh nhân nhận thông báo cần ra quầy thanh toán; **`Diagnose and Prescribe` và `Finalize Medical Record` bị khoá**.

---

## B8. Cancel Ultrasound Order — Doctor

**Tiền điều kiện:** yêu cầu siêu âm tồn tại; **hoá đơn POST_EXAM chưa thanh toán**; bác sĩ siêu âm chưa tiếp nhận ca.

**Luồng chính:** bác sĩ nhập lý do huỷ (10 đến 500 ký tự) → hệ thống huỷ yêu cầu và huỷ hoá đơn chưa thanh toán.

**Luồng thay thế:** hoá đơn đã thanh toán → không cho bác sĩ huỷ, hiển thị "bệnh nhân đã thanh toán, liên hệ quầy lễ tân".

**Hậu điều kiện:** yêu cầu bị huỷ; hoá đơn bị huỷ; **`Diagnose and Prescribe` được mở lại** để bác sĩ chẩn đoán trên lâm sàng; bệnh nhân nhận thông báo.

> Không có use case này thì ca sẽ treo vĩnh viễn khi bệnh nhân không đủ tiền làm siêu âm.

---

## B9. Diagnose and Prescribe — Doctor

**Tiền điều kiện:** bệnh án nháp tồn tại; **và** một trong hai: không có yêu cầu siêu âm nào, **hoặc** tất cả yêu cầu siêu âm đã có kết quả.

**Luồng chính:**
1. Nếu có kết quả siêu âm, hệ thống hiển thị ảnh, kết quả AI và kết luận của bác sĩ siêu âm ở **chế độ chỉ đọc**. Bác sĩ lâm sàng xác nhận đã xem.
2. Bác sĩ nhập chẩn đoán và kết luận.
3. Bác sĩ kê đơn thuốc nếu cần, và ghi nhận bệnh nhân chọn mua tại phòng khám hay mua ngoài.

**Luồng thay thế:** còn yêu cầu siêu âm chưa có kết quả → từ chối kèm thông báo "đang chờ kết quả siêu âm".

**Hậu điều kiện:** chẩn đoán đã lưu; nếu chọn mua tại phòng khám thì tạo hoá đơn thuốc chưa thanh toán; `Finalize Medical Record` được mở khoá.

> Bác sĩ lâm sàng **không được sửa** kết luận của bác sĩ siêu âm.

---

## B10. Finalize Medical Record — Doctor

**Tiền điều kiện:** đã nhập chẩn đoán; đã có quyết định về đơn thuốc; không còn yêu cầu siêu âm nào đang chờ.

**Luồng chính:** bác sĩ bấm chốt hồ sơ → hệ thống thực hiện trong **một transaction**: bệnh án chuyển sang Final, lịch hẹn chuyển sang SUCCESS, xoá số thứ tự, ghi audit log.

**Hậu điều kiện:** bệnh án Final và chỉ từ lúc này bệnh nhân mới xem được; bệnh nhân nhận thông báo kết quả đã sẵn sàng; toàn bộ màn hình chuyển sang chỉ đọc.

> **Không** yêu cầu bệnh nhân đã thanh toán tiền thuốc mới cho chốt. Bác sĩ đã xong việc; hoá đơn thuốc do staff xử lý riêng tại quầy.

---

## B11. Sign and Confirm / Publish Results — Sonographer

**Tiền điều kiện:** đã tiếp nhận ca; đã tải ảnh; đã có kết quả AI **hoặc** đã bỏ qua AI do lỗi; nếu chọn từ chối kết quả AI thì **bắt buộc đã có ít nhất một hình vẽ thủ công**.

**Luồng chính:** bác sĩ siêu âm điền thông tin kết quả → ký xác nhận → hệ thống công bố kết quả.

**Luồng thay thế:**
- Chọn từ chối AI nhưng chưa vẽ gì → từ chối ở phía server, không chỉ ẩn nút.
- AI Engine lỗi hoặc quá thời gian chờ → cho phép bỏ qua AI và vẽ thủ công hoàn toàn, ghi log đánh dấu ca này không qua AI.

**Hậu điều kiện:** yêu cầu siêu âm chuyển sang hoàn thành; báo cáo được lưu; **bác sĩ lâm sàng nhận thông báo kết quả đã sẵn sàng** — bước này hiện đang thiếu trong code.

---

## B12. Manage Medical Services — Manager

**Tiền điều kiện:** vai trò Manager.

**Luồng chính:** Manager thêm, sửa, ngừng hoạt động dịch vụ và cập nhật giá.

**Hậu điều kiện:** giá mới **chỉ áp dụng cho chỉ định phát sinh từ thời điểm cập nhật trở đi**. Mọi lần đổi giá được ghi vào lịch sử điều chỉnh giá kèm người thực hiện và thời điểm. Hoá đơn đã phát hành không bị ảnh hưởng.

---

# PHẦN C — Ánh xạ use case sang code

Bảng này để đối chiếu khi làm theo bộ prompt trong `cams-prompt-tung-buoc.md` và `cams-prompt-benh-nhan.md`.

| Use case | Điều kiện mở khoá | Bước trong bộ prompt |
|---|---|---|
| Book Appointment | — | Bước 1, BN-3 |
| Cancel Appointment (Patient) | hoá đơn chưa thanh toán | BN-6 |
| Approve Booking | Pending | Bước 2 |
| Confirm Payment | hoá đơn chưa thanh toán | Bước 2 |
| Check In Patient | PRE_EXAM đã thanh toán | Bước 2 |
| Mark Priority | Waiting, đã thanh toán | có sẵn, chỉ bổ sung vào sơ đồ |
| Update Medical Record | InProgress | Bước 3, Bước 4 |
| Order Ultrasound | có bệnh án nháp | Bước 3, Bước 4 |
| Cancel Ultrasound Order | POST_EXAM chưa thanh toán | Bước 5 |
| Diagnose and Prescribe | không còn siêu âm chờ | Bước 3, Bước 4 |
| Finalize Medical Record | đã có chẩn đoán | Bước 7 |
| Sign and Confirm / Publish Results | đúng thứ tự 4 bước | Bước 6 |
| Manage Revenue | — | Bước 2 |
| Manage Medical Services | — | Bước 1 (khoá giá) |

**Cột giữa chính là đầu ra của hàm `getStage()`.** Viết hàm đó một lần, dùng cho cả việc ẩn hiện giao diện lẫn việc chặn ở server — đó là cách duy nhất để code khớp với đặc tả và không lệch nhau giữa hai nơi.

---

# Thứ tự làm

1. Sửa 5 sơ đồ theo Phần A — khoảng 30 phút trong draw.io.
2. Dán Phần B vào tài liệu đặc tả của đồ án.
3. Code theo bộ prompt, mỗi bước mở Phần B ra đối chiếu điều kiện.
