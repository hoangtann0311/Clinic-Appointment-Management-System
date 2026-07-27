# CAMS — Chốt phạm vi và bộ prompt triển khai

Tài liệu này **thay thế** hai file `cams-prompt-tung-buoc.md` và `cams-prompt-benh-nhan.md`. Dùng file này, bỏ hai file kia để tránh lệch số bước.

Căn cứ: bộ use case đã chốt cho 5 actor (Patient, Doctor, Sonographer, Staff, Manager) và bảng đặc tả trong `cams-sua-use-case-va-dac-ta.md`.

---

# PHẦN A — CHỐT PHẠM VI

## A1. Use case trong phạm vi và tình trạng code

Ký hiệu: **[Có]** đã có trong code, chỉ cần rà lại · **[Sửa]** đã có nhưng sai logic · **[Mới]** chưa có, phải viết

### Patient
| Use case | Tình trạng | Prompt |
|---|---|---|
| Book Appointment | [Sửa] giá chưa khoá, chưa hiện giá | P1, P11 |
| View My Appointments | [Sửa] trạng thái tiếng Anh, thiếu số thứ tự | P10, P11 |
| Change my appointment | **[Mới]** | P12 |
| Cancel appointment | **[Mới]** | P12 |
| View Payment History | [Có] | P10 |
| View Medical Record + Detail | [Sửa] lộ bản nháp | P10 |

### Staff
| Use case | Tình trạng | Prompt |
|---|---|---|
| View Reception Queue | [Có] | P4 |
| Approve Booking | [Sửa] tách khỏi Change Appointment Status | P4 |
| Check In Patient | [Sửa] tách ra, chặt điều kiện | P4 |
| Cancel Appointment | [Sửa] chưa xử lý hoá đơn đã thanh toán | P4, P13 |
| Confirm Payment | [Sửa] tên hàm mock, thiếu bằng chứng thu tiền | P3 |
| Mark Priority | [Có] | P4 |
| Create Initial Patient Record | [Có] | P4 |
| Create Manual Appointment | [Có] | P4 |
| Update Patient / Appointment Information | [Có] | P4 |
| Update Reception Information | [Có] | P4 |
| View Doctor Schedule | [Có] | — |

### Doctor
| Use case | Tình trạng | Prompt |
|---|---|---|
| View Appointment Overview | [Có] | — |
| View Today's Appointments | [Sửa] gồm cả tiếp nhận ca | P5, P6 |
| Manage Medical Records | [Có] | P6 |
| Update Medical Record | [Sửa] chưa khoá theo bước | P5, P6 |
| Order Ultrasound | [Sửa] lý do chỉ định chưa bắt buộc | P6, P7 |
| Cancel Ultrasound Order | **[Mới]** | P7 |
| Diagnose and Prescribe | [Sửa] chưa chặn khi đang chờ siêu âm | P5, P6 |
| Finalize Medical Record | [Sửa] chưa gộp transaction | P8 |
| Manage Prescription + View Details | [Có] chỉ đọc | — |
| Manage Work Schedules + Register/Cancel | [Có] | — |

### Sonographer
| Use case | Tình trạng | Prompt |
|---|---|---|
| View Ultrasound Overview | [Có] | P9 |
| View Medical Record Details | [Có] | P9 |
| Accept Ultrasound Case | [Có] | P9 |
| Capture and Upload Images | [Có] | P9 |
| Analyze with AI | [Sửa] chưa xử lý AI lỗi | P9 |
| Accept AI Result | [Có] | P9 |
| Reject AI Result → Draw Manually | [Sửa] chưa bắt buộc vẽ ở server | P9 |
| Update Ultrasound Result Information | [Có] | P9 |
| Sign and Confirm | [Có] | P9 |
| Publish Results | [Sửa] thiếu thông báo cho BS lâm sàng | P9 |

### Manager
| Use case | Tình trạng | Prompt |
|---|---|---|
| Manage Medical Services + Update | [Sửa] giá chưa có lịch sử | P2 |
| View Price Adjustment History | **[Mới]** | P2 |
| Manage Revenue + View Service Details | **[Mới]** | P3 |
| View Service Statistics | **[Mới]** | P3 |
| Manage Work Schedule + shifts + Approve | [Có] | — |
| Manage Appointment Time Slots | [Có] | — |
| Manage Doctors + View doctor detail | [Có] | — |

---

## A2. Chốt thay đổi CSDL — chỉ được phép đúng bốn nhóm này

Ngoài bốn nhóm dưới đây, **mọi đề xuất thêm cột hay bảng đều phải dừng lại và hỏi**.

| # | Bảng | Cột | Lý do |
|---|---|---|---|
| 1 | appointments | 1 cột số lưu giá khám | Khoá giá tại thời điểm đặt lịch |
| 2 | invoices | `paid_at`, `paid_by_user_id`, `payment_method` | Bằng chứng thu tiền mặt, để đối soát và tính doanh thu |
| 3 | invoices | mở rộng tập giá trị status thêm `Refunded` | Hoàn tiền khi huỷ lịch đã thanh toán |
| 4 | Bảng mới `service_price_history` | `service_id`, giá cũ, giá mới, `changed_by`, `changed_at` | Use case View Price Adjustment History |

Mọi câu `ALTER TABLE` / `CREATE TABLE` phải được viết ra cho người dùng chạy tay, **không tự động chạy**.

**Tuyệt đối không thêm:** cột `current_step`, cột trạng thái quy trình, bảng doanh thu tổng hợp, bảng hàng đợi riêng. Tất cả những thứ này phải suy ra từ dữ liệu gốc.

---

## A3. Chốt những thứ KHÔNG làm

- Không tích hợp bất kỳ cổng thanh toán nào. Không QR, không ví, không thẻ.
- Không thêm use case ngoài danh sách A1.
- Không đổi framework, không thêm thư viện UI, không refactor kiến trúc.
- Không viết job tự động huỷ lịch hẹn đang khám cuối ngày.
- Không cho bệnh nhân tự xác nhận đã thanh toán, dưới bất kỳ hình thức nào.
- Không cho bác sĩ lâm sàng sửa kết luận của bác sĩ siêu âm.
- Không cho staff sửa chẩn đoán hay đơn thuốc.

---

## A4. Chốt các quyết định nghiệp vụ còn treo

Đây là các điểm sơ đồ use case không quyết định được. Chốt theo phương án dưới, nếu bạn muốn khác thì sửa ở đây trước khi chạy prompt.

| # | Vấn đề | Chốt |
|---|---|---|
| 1 | Change my appointment đổi được gì | **Chỉ đổi slot trong cùng một bác sĩ.** Không cho đổi bác sĩ — đổi bác sĩ nghĩa là đổi giá và phải sửa hoá đơn, phức tạp không đáng. Muốn đổi bác sĩ thì huỷ rồi đặt lại. |
| 2 | Đổi/huỷ lịch khi đã thanh toán | **Không cho bệnh nhân tự làm.** Chuyển sang quầy, staff xử lý hoàn tiền. |
| 3 | Hạn chót đổi/huỷ | **2 giờ trước giờ bắt đầu ca.** |
| 4 | Kê đơn có chặn chốt hồ sơ không | **Không chặn.** Bác sĩ chốt hồ sơ ngay; hoá đơn thuốc do staff xử lý riêng ở quầy. |
| 5 | Một lịch hẹn có nhiều chỉ định siêu âm | **Cho phép.** Điều kiện mở khoá chẩn đoán là **tất cả** đã hoàn thành. |
| 6 | AI Engine chết | **Cho phép bỏ qua AI**, vẽ thủ công hoàn toàn, ghi log đánh dấu ca không qua AI. |
| 7 | View Service Statistics khác gì Manage Revenue | **Statistics = số lượt** dịch vụ được chỉ định và thực hiện. **Revenue = tiền** đã thu. Hai màn hình khác nhau. |
| 8 | Giá dịch vụ đổi giữa chừng | Hoá đơn đã phát hành **không đổi**. Giá mới chỉ áp cho chỉ định phát sinh sau đó. |
| 9 | Ca khám kéo dài qua ngày | **Chấp nhận.** Không auto huỷ. Manager có danh sách ca chưa chốt quá 24 giờ. |
| 10 | Bác sĩ khám nhiều ca song song | **Cho phép.** Phải bỏ ràng buộc một bác sĩ chỉ một ca đang khám nếu có. |

---

# PHẦN B — KHỐI LUẬT CHUNG

Dán vào **đầu mọi prompt** từ P1 trở đi.

```
LUẬT CHUNG (áp dụng tuyệt đối cho task này):

BỐI CẢNH
- Dự án CAMS, Java Servlet + JSP, chạy localhost:8080, giao diện tiếng Việt.
- Sáu vai trò: Admin, Manager, Bệnh nhân, Bác sĩ lâm sàng, Bác sĩ siêu âm, Nhân viên.
- Hệ thống KHÔNG có cổng thanh toán. Bệnh nhân trả tiền mặt tại quầy, staff xác
  nhận. Không thêm bất kỳ phương thức thanh toán điện tử nào.

PHẠM VI
- Chỉ làm ĐÚNG những gì task này nêu. Thấy chỗ khác có vẻ cần sửa thì GHI RA,
  không tự sửa.
- Không thêm use case mới.
- Chỉ được thêm cột/bảng CSDL nếu task này nói rõ. Khi thêm, viết câu lệnh
  ALTER TABLE / CREATE TABLE ra cho tôi chạy tay, KHÔNG tự chạy.
- Tuyệt đối không thêm cột current_step hay bất kỳ cột nào lưu trạng thái quy
  trình. Trạng thái phải suy ra từ dữ liệu gốc mỗi lần truy vấn.
- Không đổi tên, không đổi chữ ký, không đổi URL của servlet/DAO/service đang
  có trừ khi task nói rõ.
- Không refactor ngoài phạm vi. Thay đổi tối thiểu.

BẢO MẬT VÀ ĐÚNG ĐẮN
- Mọi validate nghiệp vụ và mọi kiểm tra quyền phải nằm ở SERVER. Ẩn hoặc
  disable ở JSP/JavaScript chỉ là lớp phụ, không được coi là biện pháp bảo vệ.
- Mọi action nhận id từ URL hoặc form phải kiểm tra chủ sở hữu / phân công
  trước khi xử lý.
- Mọi thao tác ghi nhiều bảng phải nằm trong một transaction có rollback.
- Mọi thao tác đổi trạng thái hoặc đụng tới tiền phải ghi audit log.
- Chống gửi trùng: bấm hai lần hoặc F5 gửi lại không được tạo bản ghi trùng
  hay cộng trừ số liệu hai lần.

GIAO DIỆN
- Giữ nguyên theme và CSS hiện có, không thêm framework UI mới.
- Toàn bộ chữ hiển thị cho người dùng bằng tiếng Việt, không lộ tên trạng thái
  kỹ thuật.
- Ngày dd/MM/yyyy, giờ HH:mm, tiền có phân cách nghìn kèm "đ".
- Khung hiển thị rõ toàn bộ nội dung, không chồng đè, không tràn, không bị
  sidebar che.
- Danh sách rỗng phải có dòng thông báo, không để bảng trống.
- Lỗi phải trả thông báo tiếng Việt dễ hiểu, không trả 500 hay trang trắng,
  không lộ thông tin kỹ thuật.

CÁCH LÀM VIỆC
- Bước 1: đọc code liên quan, báo cáo hiện trạng và danh sách file sẽ sửa kèm
  tóm tắt từng thay đổi. CHỜ tôi xác nhận.
- Bước 2: sửa theo từng phần nhỏ.
- Bước 3: liệt kê file đã sửa, sửa gì, và các bước tôi tự test trên
  localhost:8080.
- Nếu bắt buộc phải vượt phạm vi mới làm được: DỪNG và hỏi tôi.
```

---

# PHẦN C — BỘ PROMPT

Thứ tự bắt buộc. Mỗi prompt một phiên chat riêng với Claude Code.

**Giai đoạn 1 — Nền móng dữ liệu:** P0, P1, P2, P3
**Giai đoạn 2 — Lễ tân:** P4
**Giai đoạn 3 — Bác sĩ lâm sàng:** P5, P6, P7, P8
**Giai đoạn 4 — Bác sĩ siêu âm:** P9
**Giai đoạn 5 — Bệnh nhân:** P10, P11, P12
**Giai đoạn 6 — Bịt lỗ hổng và rà soát:** P13, P14

---

## P0 — Khảo sát toàn hệ thống

```
CHỈ ĐỌC VÀ BÁO CÁO. TUYỆT ĐỐI KHÔNG SỬA, KHÔNG TẠO, KHÔNG XOÁ FILE NÀO.

Đọc code dự án CAMS và trả lời chính xác từng câu. Mỗi câu kèm file:dòng làm
bằng chứng. Không tìm thấy thì ghi "KHÔNG CÓ", không được đoán.

A. CƠ SỞ DỮ LIỆU
 1. Liệt kê đầy đủ cột của các bảng: appointments, invoices, test_orders,
    medical_records, prescriptions, doctor_schedules, shifts, patients, users.
 2. Bảng invoices có paid_at / paid_by_user_id / payment_method không?
 3. Bảng appointments có cột lưu giá khám không?
 4. Có bảng danh mục dịch vụ y tế không? Giá dịch vụ lưu ở đâu?
 5. Có bảng lịch sử điều chỉnh giá không?
 6. Bảng test_orders có cột lưu lý do chỉ định của bác sĩ không?
 7. Bảng patients/users có cột giới tính không?
 8. Tập giá trị status của: appointments, invoices, test_orders,
    medical_records.

B. GIÁ VÀ TIỀN
 9. Giá khám tính ở đâu lúc đặt lịch? Công thức chính xác?
10. Số tiền hoá đơn PRE_EXAM lấy từ đâu lúc staff duyệt lịch?
11. Hai giá trị trên có luôn bằng nhau không? Chứng minh.
12. Giá dịch vụ siêu âm lấy từ đâu khi bác sĩ chỉ định?
13. Liệt kê mọi hàm chuyển hoá đơn sang trạng thái đã thanh toán. Tên hàm nào
    có chữ "mock"?

C. LUỒNG KHÁM
14. Các nút của bác sĩ lâm sàng (kê đơn, chỉ định siêu âm, hoàn tất khám) hiện
    hiển thị đồng thời hay có điều kiện? Điều kiện là gì?
15. Có điều kiện nào chặn hoàn tất khám khi còn chỉ định siêu âm chưa xong?
16. Một bác sĩ có bị giới hạn chỉ một ca đang khám cùng lúc không?
17. Có job/scheduler nào tự đổi trạng thái lịch hẹn theo thời gian không?
18. Chốt hồ sơ bệnh án và hoàn tất khám hiện là một hay hai hành động?

D. SIÊU ÂM
19. Ba giá trị Accepted / Corrected / Rejected trong saveSonographerReview dẫn
    tới hành vi gì? Sau Rejected ca đi về đâu?
20. Có validate bắt buộc annotation khi chọn Corrected không?
21. AI Engine timeout hoặc lỗi thì code xử lý thế nào? Có đặt timeout không?
22. Sau khi sonographer ký, có gửi thông báo cho bác sĩ lâm sàng không?

E. LỄ TÂN
23. Liệt kê mọi action của staff và điều kiện tiền đề của từng action.
24. Có action nào cho phép staff đổi trạng thái lịch hẹn tuỳ ý không?
25. Huỷ lịch hiện xử lý hoá đơn đã thanh toán thế nào?
26. Có chức năng đánh dấu bệnh nhân không đến không?

F. BỆNH NHÂN
27. Câu truy vấn lấy hồ sơ bệnh án cho bệnh nhân có lọc trạng thái Final không?
    Chép nguyên câu ra.
28. Bệnh nhân có nút tự huỷ hoặc tự đổi lịch không?
29. Trạng thái hiển thị cho bệnh nhân là tiếng Anh hay tiếng Việt? Chỗ dịch
    nằm ở đâu?
30. Màn hình bệnh nhân có hiển thị số thứ tự hàng đợi không?
31. Trường LMP có điều kiện theo giới tính không?
32. Có chỗ nào trên màn hình bệnh nhân nhận id từ URL mà không kiểm tra chủ
    sở hữu không?

G. QUẢN LÝ
33. Manager có báo cáo doanh thu chưa? Lấy dữ liệu từ đâu?
34. Manager có màn hình quản lý dịch vụ y tế và giá chưa?

Trình bày dạng bảng: Câu | Trả lời | File:dòng.
Cuối báo cáo liệt kê riêng: (a) các chỗ mâu thuẫn, (b) các lỗ hổng bảo mật,
(c) các chỗ có thể gây treo dữ liệu vĩnh viễn.
```

**Đọc kỹ báo cáo này trước khi chạy P1.** Các prompt sau giả định một số điều; nếu báo cáo cho thấy khác thì sửa prompt trước khi chạy.

---

## P1 — Khoá giá khám tại thời điểm đặt lịch

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: Book Appointment (Patient), Approve Booking (Staff)

MỤC TIÊU: Hệ thống chỉ có MỘT nguồn giá khám. Bệnh nhân thấy giá nào lúc đặt
thì ra quầy trả đúng giá đó, kể cả khi Manager đổi bảng giá sau đó.

VẤN ĐỀ: Giá khám hiện được tính lúc đặt lịch theo công thức dựa trên số năm
kinh nghiệm bác sĩ, nhưng hoá đơn phí khám lúc staff duyệt lại lấy số tiền từ
nguồn khác. Hai số có thể lệch.

VIỆC CẦN LÀM:
1. Xác nhận bug bằng cách chỉ ra hai đoạn code. Nếu thực tế khác với mô tả
   trên thì DỪNG và báo cho tôi.
2. Thêm đúng MỘT cột kiểu số vào bảng appointments để lưu giá khám. Viết sẵn
   ALTER TABLE và câu UPDATE điền giá cho bản ghi cũ, cho tôi chạy tay.
3. Sửa luồng đặt lịch: tính giá một lần, ghi vào cột đó trong cùng transaction
   với việc tạo lịch hẹn.
4. Sửa luồng duyệt lịch của staff: hoá đơn phí khám copy nguyên số tiền từ cột
   đó, KHÔNG tính lại.
5. Hiển thị giá cho bệnh nhân ở ba chỗ: khi chọn xong bác sĩ, ở màn hình xác
   nhận trước khi bấm đặt, và ở danh sách lịch hẹn. Kèm dòng "Thanh toán tại
   quầy lễ tân trước giờ khám".

TIÊU CHÍ HOÀN THÀNH:
- Đặt lịch mới, ghi lại giá thấy trên màn hình. Staff duyệt. Số tiền hoá đơn
  phải bằng đúng số đó.
- Đổi số năm kinh nghiệm của bác sĩ sau khi bệnh nhân đã đặt: giá lịch cũ
  không đổi.
- Không còn chỗ nào tính lại giá khám ngoài luồng đặt lịch.
```

---

## P2 — Danh mục dịch vụ và lịch sử điều chỉnh giá

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: Manage Medical Services, Update Medical Service,
View Price Adjustment History (Manager)

MỤC TIÊU: Manager quản lý được danh mục dịch vụ y tế và giá, mọi lần đổi giá
đều được ghi lại, và giá cũ không ảnh hưởng tới hoá đơn đã phát hành.

VIỆC CẦN LÀM:
1. Rà màn hình quản lý dịch vụ hiện có của Manager. Nếu chưa có thì làm mới,
   nếu có rồi thì chỉ bổ sung phần còn thiếu.
2. Chức năng: xem danh sách dịch vụ, thêm, sửa tên và giá, bật/tắt hoạt động.
   KHÔNG cho xoá cứng dịch vụ đã từng được sử dụng — chỉ tắt hoạt động.
3. Tạo bảng mới service_price_history gồm: mã dịch vụ, giá cũ, giá mới, người
   thực hiện, thời điểm. Viết sẵn CREATE TABLE cho tôi chạy tay.
4. Mỗi lần Manager đổi giá, ghi một dòng vào bảng lịch sử trong cùng
   transaction với việc cập nhật giá. Ghi audit log.
5. Màn hình View Price Adjustment History: lọc theo dịch vụ và khoảng thời
   gian, hiển thị giá cũ, giá mới, chênh lệch, người đổi, thời điểm.
6. QUAN TRỌNG: đổi giá KHÔNG được ảnh hưởng tới hoá đơn đã phát hành và không
   ảnh hưởng tới lịch hẹn đã đặt. Kiểm tra và khẳng định điều này trong báo cáo.
7. Khi bác sĩ chỉ định siêu âm, số tiền hoá đơn lấy từ giá dịch vụ tại thời
   điểm chỉ định và ghi cứng vào hoá đơn.

TIÊU CHÍ HOÀN THÀNH:
- Đổi giá một dịch vụ, kiểm tra lịch sử ghi đúng giá cũ và giá mới.
- Chỉ định siêu âm, thu tiền, rồi Manager đổi giá dịch vụ đó: hoá đơn cũ không
  đổi số tiền.
- Tắt hoạt động một dịch vụ: bác sĩ không chọn được nữa nhưng dữ liệu cũ vẫn
  hiển thị bình thường.
```

---

## P3 — Xác nhận thu tiền mặt, doanh thu và thống kê

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: Confirm Payment (Staff), Manage Revenue,
View Service Details, View Service Statistics (Manager)

MỤC TIÊU: Ghi nhận việc thu tiền mặt đúng bản chất nghiệp vụ, và cho Manager
xem được doanh thu và thống kê.

VIỆC CẦN LÀM:
1. Đổi tên mọi hàm có chữ "mock" trong luồng thanh toán thành tên đúng nghiệp
   vụ, ví dụ confirmCashPayment. Đây là nghiệp vụ thật, không phải giả lập.
   Cập nhật mọi chỗ gọi.
2. Thêm ba cột vào bảng invoices: paid_at, paid_by_user_id, payment_method
   (mặc định 'CASH'). Viết sẵn ALTER TABLE cho tôi chạy tay.
3. Mọi chỗ chuyển hoá đơn sang đã thanh toán, cho cả ba loại hoá đơn phí khám,
   dịch vụ cận lâm sàng và đơn thuốc, đều phải ghi đủ ba trường trên trong cùng
   transaction với việc đổi trạng thái, kèm audit log.
4. Chống xác nhận trùng: hoá đơn đã thanh toán thì từ chối, báo lỗi rõ ràng,
   không ghi đè, không cộng doanh thu hai lần. Áp dụng cả khi staff bấm hai lần
   hoặc F5 gửi lại.
5. Màn hình Manage Revenue của Manager:
   - đọc TRỰC TIẾP từ bảng invoices, điều kiện đã thanh toán
   - KHÔNG tạo bảng doanh thu tổng hợp, KHÔNG lưu số tổng vào đâu
   - chọn khoảng ngày, hiển thị tổng tiền và tách theo ba loại hoá đơn
   - View Service Details: danh sách chi tiết từng hoá đơn kèm bệnh nhân, dịch
     vụ, số tiền, thời điểm, staff xác nhận
6. Màn hình View Service Statistics: đếm SỐ LƯỢT dịch vụ được chỉ định và số
   lượt đã thực hiện, theo khoảng thời gian. Đây là màn hình về số lượng, khác
   với Manage Revenue là về tiền. Không trộn hai thứ vào một màn hình.

TIÊU CHÍ HOÀN THÀNH:
- Thu tiền một hoá đơn, Manager thấy ngay khoản đó trong ngày hôm nay, đúng số
  tiền, đúng tên staff.
- Bấm xác nhận lần hai: bị chặn, doanh thu không nhân đôi.
- Toàn bộ source không còn hàm nào tên chứa "mock" trong luồng thanh toán.
- Tổng của View Service Details bằng đúng số tổng của Manage Revenue.
```

---

## P4 — Tách các hành động của lễ tân

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: View Reception Queue, Approve Booking, Check In Patient,
Cancel Appointment, Mark Priority, Create Initial Patient Record (Staff)

MỤC TIÊU: Mỗi hành động của lễ tân là một action riêng với điều kiện riêng.
Không có action chung nào cho phép staff đổi trạng thái lịch hẹn tuỳ ý.

VIỆC CẦN LÀM:
1. Rà soát: nếu tồn tại một action kiểu "đổi trạng thái lịch hẹn" nhận trạng
   thái đích làm tham số thì XOÁ BỎ, thay bằng các action cụ thể dưới đây.
2. Approve Booking
   - điều kiện: lịch hẹn ở trạng thái chờ duyệt
   - kết quả: chuyển sang đã xác nhận, tạo đúng một hoá đơn phí khám chưa
     thanh toán với số tiền copy từ giá đã lưu trong lịch hẹn (làm ở P1)
   - nếu đã có hoá đơn phí khám thì không tạo trùng
   - thông báo cho bệnh nhân kèm số tiền và yêu cầu ra quầy thanh toán
3. Check In Patient
   - điều kiện BẮT BUỘC ĐỦ: đã xác nhận, của ngày hôm nay, hoá đơn phí khám ĐÃ
     thanh toán, chưa check-in, đang trong khung giờ cho phép
   - nếu chưa thanh toán: từ chối kèm thông báo "bệnh nhân chưa thanh toán phí
     khám"
   - kết quả: chuyển sang chờ khám, cấp số thứ tự, xếp lại hàng đợi
4. Cancel Appointment (staff)
   - điều kiện: chưa khám xong, chưa đang khám
   - kết quả: chuyển sang đã huỷ, huỷ hoá đơn chưa thanh toán, trả slot bằng
     cách giảm booked_count, audit log — tất cả trong một transaction
   - nếu có hoá đơn ĐÃ thanh toán: KHÔNG tự huỷ hoá đơn đó, hiển thị cảnh báo
     cần xử lý hoàn tiền (làm ở P13)
5. Mark Priority: giữ nguyên logic hiện có, chỉ rà lại điều kiện và việc xếp
   lại số thứ tự.
6. Create Initial Patient Record: chỉ cho phép nhập thông tin HÀNH CHÍNH của
   bệnh nhân vãng lai. KHÔNG cho staff nhập hoặc sửa chẩn đoán, kết luận, đơn
   thuốc. Kiểm tra và chặn ở server nếu đang cho phép.
7. Mọi action trên đều kiểm tra quyền vai trò ở server và ghi audit log.

TIÊU CHÍ HOÀN THÀNH:
- Không tồn tại đường nào để staff chuyển lịch hẹn từ chờ duyệt thẳng sang
  hoàn tất.
- Check-in một bệnh nhân chưa thanh toán: bị chặn cả ở giao diện và khi POST
  thẳng.
- Huỷ lịch chưa thanh toán: slot được trả về, người khác đặt lại được.
- Staff không sửa được chẩn đoán của bác sĩ.
```

---

## P5 — Hàm getStage và khoá ở server

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: toàn bộ nhánh Update Medical Record của Doctor

MỤC TIÊU: Có một nguồn chân lý duy nhất xác định lịch hẹn đang ở bước nào, và
mọi hành động của bác sĩ đều bị chặn nếu sai bước. Chỉ làm backend, chưa đụng
giao diện.

QUAN TRỌNG: KHÔNG thêm cột lưu bước hiện tại. Bước phải được SUY RA mỗi lần
gọi, vì trạng thái bị thay đổi bởi người khác ở luồng khác — staff xác nhận
thanh toán, bác sĩ siêu âm ký kết quả. Lưu vào CSDL sẽ lệch ngay khi bác sĩ mở
hai tab.

VIỆC CẦN LÀM:
1. Tạo enum ExamStage: NOT_STARTED, CLINICAL_EXAM, ORDER_DECISION,
   WAITING_PAYMENT, WAITING_ULTRASOUND, DIAGNOSIS, READY_TO_FINALIZE, FINALIZED
2. Tạo hàm getStage(appointmentId) ở service layer, xét lần lượt từ trên xuống:
   - lịch hẹn không ở trạng thái đang khám và chưa hoàn tất -> NOT_STARTED
   - lịch hẹn đã hoàn tất                                   -> FINALIZED
   - chưa có bệnh án                                        -> CLINICAL_EXAM
   - có chỉ định mà hoá đơn dịch vụ chưa thanh toán         -> WAITING_PAYMENT
   - có chỉ định đã trả tiền nhưng chưa có kết quả          -> WAITING_ULTRASOUND
   - chưa nhập chẩn đoán                                    -> DIAGNOSIS
   - đã nhập chẩn đoán và đã quyết định đơn thuốc           -> READY_TO_FINALIZE
   - còn lại                                                -> ORDER_DECISION
   Nếu một lịch hẹn có NHIỀU chỉ định siêu âm thì điều kiện là TẤT CẢ đã hoàn
   thành, không phải chỉ một cái.
3. Mọi servlet action của bác sĩ lâm sàng gọi getStage() ở đầu và từ chối nếu
   sai bước:
   - lưu khám lâm sàng        : CLINICAL_EXAM hoặc ORDER_DECISION
   - tạo chỉ định siêu âm     : ORDER_DECISION
   - huỷ chỉ định siêu âm     : WAITING_PAYMENT
   - lưu chẩn đoán và kê đơn  : DIAGNOSIS hoặc READY_TO_FINALIZE
   - chốt hồ sơ               : READY_TO_FINALIZE
   Khi từ chối: thông báo tiếng Việt nói rõ đang ở bước nào và cần làm gì trước.
4. Kiểm tra phân công: chỉ bác sĩ được phân công lịch hẹn đó mới gọi được các
   action trên. Đổi id trên URL phải bị chặn.
5. Kiểm tra và BỎ ràng buộc một bác sĩ chỉ được một ca đang khám cùng lúc nếu
   ràng buộc đó tồn tại. Bác sĩ phải khám ca khác trong lúc chờ siêu âm.
6. Ghi log getStage() để tôi kiểm tra được với vài lịch hẹn thật.

TIÊU CHÍ HOÀN THÀNH:
- POST thẳng tới action chốt hồ sơ khi ca đang chờ siêu âm: bị từ chối kèm
  thông báo rõ ràng.
- Đổi id lịch hẹn trên URL sang ca của bác sĩ khác: bị từ chối.
- Một bác sĩ mở được hai ca đang khám cùng lúc.
```

---

## P6 — Giao diện hồ sơ bệnh án dạng từng bước

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: View Today's Appointments, Manage Medical Records,
Update Medical Record, Order Ultrasound, Diagnose and Prescribe (Doctor)

MỤC TIÊU: Màn hình hồ sơ bệnh án hiển thị 5 khối xếp dọc, mở dần theo tiến độ.
Dùng hàm getStage() đã làm ở P5, KHÔNG tự viết lại logic tính bước ở JSP.

NĂM KHỐI:
 1. Tiếp nhận ca — chỉ có nút, không form. Chuyển lịch hẹn từ chờ khám sang
    đang khám.
 2. Khám lâm sàng — triệu chứng, tiền sử, khám lâm sàng. Nút lưu nháp.
 3. Chỉ định cận lâm sàng — hai lựa chọn "Không chỉ định" hoặc "Chỉ định siêu
    âm". Nếu chỉ định thì hiện form chọn dịch vụ từ danh mục Manager quản lý,
    kèm ô lý do chỉ định BẮT BUỘC 10 đến 500 ký tự.
 4. Chẩn đoán và kê đơn — bên trên hiển thị kết quả siêu âm CHỈ ĐỌC gồm ảnh,
    kết quả AI, kết luận của bác sĩ siêu âm, kèm nút "Xác nhận đã xem". Bác sĩ
    lâm sàng KHÔNG sửa được kết luận siêu âm. Bên dưới là ô chẩn đoán, kết
    luận, kê đơn, và lựa chọn bệnh nhân mua thuốc tại phòng khám hay mua ngoài.
 5. Chốt hồ sơ bệnh án — nút cuối cùng.

QUY TẮC HIỂN THỊ:
- Khối đã xong: thu gọn, dấu tích, tóm tắt một dòng, có nút "Sửa".
- Khối đang tới lượt: mở rộng, nhập được.
- Khối chưa tới lượt: thu gọn, xám, biểu tượng khoá, và BẮT BUỘC ghi rõ lý do
  đang khoá bằng tiếng Việt, ví dụ "Đang chờ bệnh nhân thanh toán dịch vụ siêu
  âm" hoặc "Đang chờ bác sĩ siêu âm trả kết quả". Khoá mà không nói lý do là
  không đạt.
- Ở trạng thái chờ: hiện dải thông báo kèm nút "Tải lại" để bác sĩ chủ động
  kiểm tra kết quả đã về chưa.
- Cho phép quay lại SỬA khối trước cho tới khi chốt hồ sơ. Sau khi chốt thì
  toàn bộ chuyển sang chỉ đọc.

RÀNG BUỘC:
- Disable nút ở JSP/JS chỉ là lớp phụ, server vẫn chặn như P5.
- Danh sách bệnh nhân của bác sĩ: thêm bộ lọc "Đang chờ kết quả" để bác sĩ biết
  ca nào quay lại được.

TIÊU CHÍ HOÀN THÀNH:
- Ca mới: chỉ khối 1 mở, khối 2 đến 5 khoá.
- Lưu khám lâm sàng xong: khối 3 mở.
- Chỉ định siêu âm xong: khối 4 và 5 khoá, hiện đúng lý do đang chờ.
- Kết quả siêu âm về, bấm tải lại: khối 4 mở.
```

---

## P7 — Huỷ chỉ định siêu âm

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: Cancel Ultrasound Order (Doctor)

MỤC TIÊU: Xử lý trường hợp bác sĩ đã chỉ định siêu âm nhưng bệnh nhân không làm
— không đủ tiền, về luôn, đổi ý. Không có chức năng này thì ca kẹt vĩnh viễn ở
trạng thái chờ và bác sĩ không bao giờ chốt được hồ sơ.

VIỆC CẦN LÀM:
1. Nút "Huỷ chỉ định siêu âm" ở khối 3 của màn hình hồ sơ bệnh án, chỉ hiện khi
   ĐỦ CẢ BA:
   - lịch hẹn đang khám
   - hoá đơn dịch vụ đó CHƯA thanh toán
   - bác sĩ siêu âm chưa tiếp nhận ca
2. Bắt buộc nhập lý do huỷ, 10 đến 500 ký tự.
3. Trong MỘT transaction: huỷ chỉ định, huỷ hoá đơn chưa thanh toán, ghi audit
   log kèm lý do.
4. Sau khi huỷ, getStage() phải trả về DIAGNOSIS để bác sĩ chẩn đoán trên lâm
   sàng và chốt hồ sơ bình thường.
5. Nếu hoá đơn ĐÃ thanh toán: không cho bác sĩ huỷ, hiển thị "Bệnh nhân đã
   thanh toán, liên hệ quầy lễ tân để xử lý".
6. Nếu lịch hẹn có nhiều chỉ định, cho huỷ từng cái riêng.
7. Thông báo cho bệnh nhân khi chỉ định bị huỷ.

TIÊU CHÍ HOÀN THÀNH:
- Chỉ định rồi huỷ ngay: bác sĩ chốt được hồ sơ, không còn ca treo.
- Chỉ định, staff thu tiền xong, rồi thử huỷ: nút không hiện và POST thẳng
  cũng bị chặn.
- Huỷ một trong hai chỉ định: cái còn lại vẫn giữ nguyên trạng thái chờ.
```

---

## P8 — Chốt hồ sơ bệnh án và thông báo

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: Finalize Medical Record (Doctor)

MỤC TIÊU: Chốt hồ sơ và hoàn tất khám là một hành động nguyên tử, và bổ sung
các thông báo còn thiếu.

VIỆC CẦN LÀM:
1. Nút chốt hồ sơ thực hiện trong MỘT transaction: bệnh án chuyển sang bản
   chính thức, lịch hẹn chuyển sang hoàn tất, xoá số thứ tự, ghi audit log.
   Bất kỳ bước nào lỗi thì rollback toàn bộ.
2. Điều kiện cho phép chốt: đã nhập chẩn đoán, đã có quyết định về đơn thuốc,
   không còn chỉ định siêu âm nào đang chờ.
3. KHÔNG được yêu cầu bệnh nhân đã thanh toán tiền thuốc mới cho chốt. Bác sĩ
   đã xong việc, hoá đơn thuốc do staff xử lý riêng ở quầy. Nếu code hiện tại
   chặn theo tiền thuốc thì BỎ điều kiện đó.
4. Đơn thuốc: bệnh nhân chọn mua tại phòng khám hoặc mua ngoài.
   - mua ngoài: không tạo hoá đơn thuốc
   - mua tại phòng khám: tạo hoá đơn chưa thanh toán, staff thu tiền và trừ
     tồn kho sau
   Cả hai trường hợp đều chốt hồ sơ được ngay.
5. Bổ sung thông báo cho bệnh nhân khi hồ sơ được chốt: "Kết quả khám đã sẵn
   sàng, bạn có thể xem trong mục Hồ sơ bệnh án".
6. Sau khi chốt, toàn bộ màn hình hồ sơ chuyển sang chỉ đọc, kể cả với chính
   bác sĩ đó.

TIÊU CHÍ HOÀN THÀNH:
- Chốt hồ sơ: bệnh án và lịch hẹn đổi trạng thái cùng lúc, không có trường hợp
  một cái đổi một cái không.
- Ca có kê đơn mua tại phòng khám: vẫn chốt được dù chưa trả tiền thuốc.
- Bệnh nhân nhận thông báo và xem được hồ sơ ngay sau đó.
```

---

## P9 — Siết chặt luồng bác sĩ siêu âm

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: Accept Ultrasound Case, Capture and Upload Images,
Analyze with AI, Accept AI Result, Reject AI Result, Draw Manually,
Update Ultrasound Result Information, Sign and Confirm, Publish Results

MỤC TIÊU: Bốn bước siêu âm đi tuần tự, không bỏ bước, không có ngõ cụt, và kết
quả luôn về được tới bác sĩ lâm sàng.

BỐN BƯỚC: tiếp nhận ca -> chụp và tải ảnh -> gửi phân tích AI và xử lý kết quả
-> hoàn thành và công bố kết quả.

VIỆC CẦN LÀM:
1. Chuẩn hoá hai nhánh xử lý kết quả AI theo đúng use case đã chốt:
   - Accept AI Result: đồng ý với kết quả AI, điền thông tin, ký
   - Reject AI Result: không đồng ý, BẮT BUỘC vẽ thủ công, rồi điền thông tin,
     ký
   Cả hai nhánh sau khi ký đều đi tới bước công bố kết quả.
   Nếu code hiện tại có ba giá trị Accepted / Corrected / Rejected thì ánh xạ:
   Accept AI Result -> Accepted, Reject AI Result kèm vẽ tay -> Corrected. Giá
   trị còn lại KHÔNG được là trạng thái kết thúc — nếu nó đang là trạng thái
   kết thúc thì bác sĩ lâm sàng sẽ chờ mãi không có kết quả. Báo cho tôi biết
   bạn xử lý giá trị thứ ba thế nào trước khi sửa.
2. Validate ở SERVER: chọn nhánh vẽ tay thì phải có ít nhất một hình vẽ được
   lưu mới cho ký. Chỉ dựa vào checkbox phía client là không đạt.
3. Xử lý AI Engine lỗi hoặc quá thời gian chờ:
   - đặt timeout cụ thể cho lời gọi HTTP tới AI Engine
   - cho phép bỏ qua AI và vẽ thủ công hoàn toàn
   - ghi log đánh dấu ca này không qua AI
   - hiển thị thông báo tiếng Việt khi lỗi, không để bác sĩ kẹt ở bước 3
4. Không cho nhảy bước, chặn ở server: chưa tải ảnh thì không gọi được AI, chưa
   xử lý kết quả thì không ký được, chưa ký thì không công bố được.
5. Khi công bố kết quả, trong MỘT transaction: cập nhật chỉ định sang hoàn
   thành, lưu báo cáo, VÀ gửi thông báo cho bác sĩ lâm sàng rằng kết quả đã sẵn
   sàng. Thông báo này hiện đang thiếu — đây là mắt xích bàn giao quan trọng
   nhất giữa hai bác sĩ.
6. Chỉ bác sĩ siêu âm đã tiếp nhận ca mới thao tác được trên ca đó. Kiểm tra ở
   server.

TIÊU CHÍ HOÀN THÀNH:
- Chọn nhánh vẽ tay mà không vẽ gì: bị chặn ở server.
- Tắt AI Engine rồi làm một ca: vẫn hoàn thành được bằng vẽ tay, có log.
- Ký xong: bác sĩ lâm sàng nhận được thông báo và mở được khối chẩn đoán.
- Không có giá trị trạng thái nào khiến ca biến mất khỏi cả hai màn hình.
```

---

## P10 — Bệnh nhân: bảo mật dữ liệu và chuẩn hoá hiển thị

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: View My Appointments, View Payment History,
View Medical Record, View Medical Record Detail (Patient)

MỤC TIÊU: Bệnh nhân chỉ thấy dữ liệu của chính mình và chỉ thấy hồ sơ đã chốt,
mọi trạng thái hiển thị bằng tiếng Việt nói rõ cần làm gì.

VIỆC CẦN LÀM:

PHẦN 1 — CHẶN RÒ RỈ (làm trước, ưu tiên cao nhất)
1. Mọi truy vấn phục vụ màn hình bệnh nhân liên quan tới bệnh án, đơn thuốc,
   kết quả siêu âm phải lọc chỉ lấy hồ sơ đã chốt. Bản nháp bác sĩ đang viết dở
   tuyệt đối không được lộ.
2. Chặn truy cập trực tiếp: sửa id trên URL để mở hồ sơ chưa chốt phải bị từ
   chối, kể cả hồ sơ của chính bệnh nhân đó.
3. Kiểm tra chủ sở hữu ở TẤT CẢ màn hình bệnh nhân: lịch hẹn, hoá đơn, bệnh án,
   kết quả siêu âm. Đổi id sang dữ liệu người khác phải bị từ chối.
4. Khi từ chối: thông báo tiếng Việt nhã nhặn, không lộ thông tin kỹ thuật.

PHẦN 2 — DỊCH TRẠNG THÁI
5. Tạo MỘT chỗ duy nhất để dịch trạng thái, dùng chung cho mọi màn hình bệnh
   nhân. Không rải chuỗi tiếng Việt khắp các JSP. Bảng dịch:
     chờ duyệt                                -> "Chờ phòng khám duyệt"
     đã duyệt + hoá đơn khám chưa thanh toán  -> "Đã duyệt — chưa thanh toán"
     đã duyệt + hoá đơn khám đã thanh toán    -> "Đã thanh toán — chờ check-in"
     chờ khám                                 -> "Đã check-in — đang chờ khám"
     đang khám                                -> "Đang khám"
     hoàn tất                                 -> "Đã hoàn tất"
     đã huỷ                                   -> "Đã huỷ"
     không đến                                -> "Không đến khám"
   Hai dòng "đã duyệt" phân biệt bằng tình trạng hoá đơn, phải truy vấn hoá đơn
   để tách, không được gộp.
6. Ba tình huống cần bệnh nhân hành động phải hiển thị nổi bật hơn hẳn phần còn
   lại, kèm hướng dẫn cụ thể:
   - chưa thanh toán phí khám: "Vui lòng đến quầy lễ tân thanh toán trước giờ
     khám", kèm số tiền và mã hoá đơn
   - chưa thanh toán dịch vụ siêu âm: "Vui lòng đến quầy lễ tân thanh toán dịch
     vụ siêu âm", kèm tên dịch vụ và số tiền
   - còn hoá đơn thuốc: "Còn hoá đơn thuốc chưa thanh toán tại quầy"
7. Trạng thái hoá đơn cũng dịch sang tiếng Việt.

TIÊU CHÍ HOÀN THÀNH:
- Bác sĩ lưu bệnh án nháp, bệnh nhân vào xem: không thấy gì.
- Sửa id trên URL sang dữ liệu bệnh nhân khác ở cả bốn màn hình: đều bị chặn.
- Rà toàn bộ màn hình bệnh nhân: không còn chuỗi trạng thái tiếng Anh.
- Lịch đã duyệt chưa trả tiền và lịch đã duyệt đã trả tiền hiển thị khác nhau
  rõ ràng.
```

---

## P11 — Bệnh nhân: khối việc cần làm và số thứ tự hàng đợi

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: View My Appointments (Patient)

MỤC TIÊU: Bệnh nhân mở lên là biết ngay phải làm gì, và biết còn bao lâu tới
lượt mình khi đang ngồi chờ.

VIỆC CẦN LÀM:

PHẦN 1 — KHỐI VIỆC CẦN LÀM
1. Đầu trang chủ của bệnh nhân, thêm MỘT khối duy nhất hiển thị việc cần làm
   gần nhất.
2. Nội dung SUY RA từ dữ liệu mỗi lần load trang. KHÔNG thêm cột, KHÔNG lưu
   trạng thái vào đâu. Cùng nguyên tắc với getStage() bên bác sĩ.
3. Thứ tự ưu tiên, gặp cái nào khớp thì hiện cái đó rồi dừng:
   a. hoá đơn dịch vụ siêu âm chưa thanh toán
      -> "Cần thanh toán dịch vụ siêu âm" + tên dịch vụ + số tiền
   b. lịch đã duyệt, hoá đơn khám chưa thanh toán
      -> "Cần thanh toán phí khám" + số tiền + ngày giờ khám
   c. đang chờ khám
      -> "Đang chờ khám" + số thứ tự
   d. đang chờ kết quả siêu âm
      -> "Đang chờ kết quả siêu âm"
   e. hồ sơ mới chốt chưa xem
      -> "Kết quả khám đã sẵn sàng" + nút xem
   f. hoá đơn thuốc chưa thanh toán
      -> "Còn hoá đơn thuốc chưa thanh toán tại quầy"
   g. có lịch sắp tới đã thanh toán
      -> "Lịch hẹn sắp tới" + ngày giờ + tên bác sĩ
   h. không có gì
      -> nút "Đặt lịch khám mới"
4. Viết logic này trong MỘT hàm ở service layer, không rải trong JSP.

PHẦN 2 — SỐ THỨ TỰ HÀNG ĐỢI
5. Với lịch hẹn đang chờ khám của ngày hôm nay, hiển thị: số thứ tự của bệnh
   nhân, số đang được khám của cùng bác sĩ cùng ngày, và còn bao nhiêu người
   phía trước. Dùng cột số thứ tự đã có, KHÔNG thêm cột mới.
6. Nút "Tải lại" và auto refresh mỗi 30 giây, CHỈ khi đang ở trạng thái chờ
   khám. Trạng thái khác không auto refresh.
7. Số thứ tự thay đổi khi staff đánh dấu ca ưu tiên — bệnh nhân phải luôn thấy
   số mới nhất, không cache.
8. Không hiển thị tên hay thông tin của bệnh nhân khác, chỉ hiển thị con số.

TIÊU CHÍ HOÀN THÀNH:
- Tạo lần lượt từng tình huống a đến h, khối hiện đúng nội dung tương ứng.
- Staff thu tiền xong, bệnh nhân tải lại: khối tự đổi sang việc tiếp theo.
- Check-in ba bệnh nhân, mỗi người thấy đúng số của mình.
- Staff đánh dấu ưu tiên: những người còn lại thấy số đã đổi sau khi tải lại.
```

---

## P12 — Bệnh nhân: đổi lịch và huỷ lịch

```
[DÁN KHỐI LUẬT CHUNG]

USE CASE LIÊN QUAN: Change my appointment, Cancel appointment (Patient)

MỤC TIÊU: Bệnh nhân tự đổi hoặc huỷ lịch được, nhưng chặt chẽ để không lạm dụng
và không làm hỏng dữ liệu slot.

CHỐT PHẠM VI: Change my appointment CHỈ cho đổi sang slot khác CỦA CÙNG MỘT BÁC
SĨ. Không cho đổi bác sĩ — đổi bác sĩ nghĩa là đổi giá và phải sửa hoá đơn.
Muốn đổi bác sĩ thì bệnh nhân huỷ rồi đặt lại.

ĐIỀU KIỆN CHUNG cho cả đổi và huỷ, phải thoả TẤT CẢ, kiểm tra ở SERVER:
 - lịch hẹn thuộc về chính bệnh nhân đang đăng nhập
 - trạng thái là chờ duyệt hoặc đã duyệt
 - hoá đơn phí khám CHƯA thanh toán
 - chưa check-in
 - còn cách giờ bắt đầu ca ít nhất 2 giờ
Nếu đã thanh toán: KHÔNG cho tự làm, hiển thị "Bạn đã thanh toán phí khám, vui
lòng liên hệ quầy lễ tân để được hỗ trợ."

VIỆC CẦN LÀM:

PHẦN 1 — HUỶ LỊCH
1. Nút "Huỷ lịch hẹn" ở danh sách lịch hẹn, chỉ hiện khi đủ điều kiện chung.
2. Hộp xác nhận nêu rõ không thể hoàn tác. Cho nhập lý do, không bắt buộc, tối
   đa 500 ký tự.
3. Trong MỘT transaction: chuyển sang đã huỷ, huỷ hoá đơn chưa thanh toán, giảm
   booked_count của slot đi 1 để trả chỗ, ghi audit log. Thiếu bước trả slot thì
   chỗ đó bị chiếm ảo vĩnh viễn.
4. Thông báo cho bác sĩ được phân công.

PHẦN 2 — ĐỔI LỊCH
5. Nút "Đổi lịch hẹn", chỉ hiện khi đủ điều kiện chung.
6. Hiển thị các slot còn chỗ khác của CÙNG bác sĩ đó, cùng cách hiển thị như
   màn hình đặt lịch.
7. Trong MỘT transaction:
   - giảm booked_count của slot cũ đi 1
   - tăng booked_count của slot mới lên 1, kiểm tra slot mới còn chỗ ngay tại
     thời điểm ghi
   - cập nhật slot và thời gian của lịch hẹn
   - giá khám GIỮ NGUYÊN vì cùng bác sĩ
   - nếu đã có hoá đơn phí khám chưa thanh toán thì giữ nguyên hoá đơn, không
     huỷ không tạo mới
   - ghi audit log kèm slot cũ và slot mới
   Nếu slot mới vừa hết chỗ: rollback toàn bộ, báo lỗi, giữ nguyên lịch cũ.
8. Giới hạn số lần đổi: mỗi lịch hẹn chỉ được đổi tối đa 2 lần. Đếm từ audit
   log, không thêm cột.
9. Thông báo cho bác sĩ về việc đổi lịch.

PHẦN 3 — CHỐNG GỬI TRÙNG
10. Bấm hai lần hoặc F5 gửi lại: không xử lý lần thứ hai, không giảm hay tăng
    booked_count hai lần. Áp dụng cho cả huỷ và đổi.

TIÊU CHÍ HOÀN THÀNH:
- Huỷ lịch chưa thanh toán: slot được trả về, người khác đặt lại được ngay.
- Bấm huỷ hai lần liên tiếp: booked_count chỉ giảm 1.
- Đổi lịch: slot cũ tăng chỗ trống, slot mới giảm chỗ trống, tổng số chỗ toàn
  hệ thống không đổi.
- Hai người cùng đổi vào slot cuối cùng: chỉ một người thành công, người kia
  nhận lỗi và giữ nguyên lịch cũ.
- Đổi lần thứ ba: bị chặn.
- Thử đổi hoặc huỷ lịch đã thanh toán: nút không hiện và POST thẳng cũng bị
  chặn.
- Đổi id lịch hẹn sang lịch người khác: bị chặn.
```

---

## P13 — Không đến khám, hoàn tiền, ca treo

```
[DÁN KHỐI LUẬT CHUNG]

MỤC TIÊU: Bịt các lỗ hổng vận hành còn lại. Làm từng mục một, báo cáo sau mỗi
mục.

MỤC 1 — BỆNH NHÂN KHÔNG ĐẾN
- Nút cho staff đánh dấu không đến khám, chỉ áp dụng cho lịch đã duyệt của ngày
  hôm nay và đã qua giờ kết thúc ca.
- Trong một transaction: đổi trạng thái, huỷ hoá đơn phí khám còn chưa thanh
  toán, giảm booked_count trả slot, ghi audit log.
- Nếu hoá đơn ĐÃ thanh toán thì không tự huỷ, để staff xử lý hoàn tiền ở mục 2.

MỤC 2 — HOÀN TIỀN
- Bổ sung giá trị trạng thái hoàn tiền cho hoá đơn. Viết sẵn câu lệnh CSDL nếu
  cần, cho tôi chạy tay.
- Nút hoàn tiền cho staff, ghi rõ ai hoàn, lúc nào, lý do. Ghi audit log.
- Chỉ hoàn được hoá đơn đang ở trạng thái đã thanh toán. Không hoàn hai lần.
- Doanh thu ở màn hình Manager phải TRỪ các khoản đã hoàn. Kiểm tra lại số tổng
  sau khi thêm chức năng này.

MỤC 3 — CA KÉO DÀI QUA NGÀY
- Xác nhận trong code KHÔNG có job tự động huỷ lịch hẹn đang khám cuối ngày.
  Nếu có thì báo cho tôi, đừng tự xoá.
- Thêm cho Manager danh sách "Ca chưa chốt quá 24 giờ" gồm: bệnh nhân, bác sĩ,
  thời điểm bắt đầu khám, đang kẹt ở bước nào (dùng getStage()).

TIÊU CHÍ HOÀN THÀNH:
- Đánh dấu không đến: slot được trả về, hoá đơn chưa thanh toán bị huỷ.
- Hoàn tiền một hoá đơn: doanh thu Manager giảm đúng số đó.
- Danh sách ca treo hiển thị đúng bước đang kẹt.
```

---

## P14 — Rà soát toàn hệ thống

```
CHỈ ĐỌC VÀ BÁO CÁO, KHÔNG SỬA.

Rà soát toàn bộ sau khi đã làm xong P1 đến P13. Với mỗi mục, xác nhận đạt hay
chưa kèm file:dòng:

TIỀN VÀ GIÁ
 1. Chỉ một nguồn giá khám; giá bệnh nhân thấy bằng đúng số tiền hoá đơn.
 2. Đổi giá dịch vụ không ảnh hưởng hoá đơn đã phát hành.
 3. Mọi lần đổi giá được ghi vào lịch sử điều chỉnh giá.
 4. Mọi hoá đơn đã thanh toán đều có thời điểm, người xác nhận, hình thức.
 5. Không xác nhận thanh toán trùng được.
 6. Doanh thu đọc trực tiếp từ hoá đơn, có trừ khoản hoàn tiền.
 7. Thống kê số lượt và báo cáo doanh thu là hai màn hình tách biệt.
 8. Không còn hàm nào tên chứa "mock" trong luồng thanh toán.

LUỒNG KHÁM
 9. getStage() là nơi duy nhất quyết định bước, không có logic trùng lặp ở JSP.
10. Mọi action của bác sĩ đều chặn ở server theo getStage().
11. Có đường thoát khi bệnh nhân không làm siêu âm.
12. Nhánh vẽ tay bắt buộc có hình vẽ, validate ở server.
13. AI Engine chết vẫn hoàn thành được ca siêu âm.
14. Sonographer công bố kết quả thì bác sĩ lâm sàng nhận thông báo.
15. Chốt hồ sơ là một transaction nguyên tử.
16. Không có trạng thái nào khiến ca treo vĩnh viễn ở bất kỳ vai trò nào.

LỄ TÂN
17. Không tồn tại action cho phép staff đổi trạng thái lịch hẹn tuỳ ý.
18. Check-in bắt buộc đã thanh toán phí khám.
19. Staff không sửa được chẩn đoán hay đơn thuốc.

BỆNH NHÂN
20. Không màn hình nào lộ hồ sơ bệnh án chưa chốt.
21. Mọi action nhận id đều kiểm tra chủ sở hữu ở server.
22. Không có nút nào cho bệnh nhân tự đánh dấu đã thanh toán.
23. Đổi và huỷ lịch trả slot đúng, không cộng trừ hai lần.
24. Không còn chuỗi trạng thái tiếng Anh hiển thị cho bệnh nhân.

CHUNG
25. Mọi thao tác nhiều bảng đều trong transaction có rollback.
26. Mọi thao tác đổi trạng thái và đụng tiền đều có audit log.
27. Định dạng ngày giờ và tiền thống nhất toàn hệ thống.
28. Không khung nào chồng đè hoặc tràn nội dung.

Cuối cùng liệt kê các trường hợp biên vẫn chưa được xử lý.
```

---

# PHẦN D — KỊCH BẢN TEST CUỐI

Chạy đủ tám kịch bản trên localhost:8080. Sau mỗi kịch bản mở màn hình Manager kiểm tra doanh thu.

1. **Ca không siêu âm** — đặt lịch, duyệt, thu tiền, check-in, khám, chẩn đoán, kê đơn mua ngoài, chốt hồ sơ, bệnh nhân xem kết quả.
2. **Ca có siêu âm, AI đúng** — thêm chỉ định, thu tiền dịch vụ, siêu âm, đồng ý AI, ký, công bố, bác sĩ chốt.
3. **Ca có siêu âm, AI sai** — chọn nhánh vẽ tay, thử ký khi chưa vẽ phải bị chặn, vẽ rồi ký.
4. **AI Engine chết** — tắt service Python, làm một ca siêu âm hoàn chỉnh bằng vẽ tay.
5. **Bệnh nhân bỏ siêu âm** — chỉ định rồi huỷ chỉ định, vẫn chốt được hồ sơ.
6. **Bệnh nhân đổi lịch** — đổi sang slot khác cùng bác sĩ, kiểm tra tổng số chỗ không đổi.
7. **Không đến và hoàn tiền** — một ca đánh dấu không đến, một ca đã thanh toán rồi hoàn tiền, đối chiếu doanh thu.
8. **Thử phá** — sửa id trên URL ở mọi màn hình, POST thẳng vào action sai bước, bấm nút hai lần liên tiếp ở mọi chỗ có cộng trừ số liệu.
