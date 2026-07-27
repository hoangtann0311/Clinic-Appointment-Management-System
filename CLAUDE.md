# CAMS — Luật dự án

Java Servlet + JSP, chạy localhost:8080, giao diện tiếng Việt.
Sáu vai trò: Admin, Manager, Bệnh nhân, Bác sĩ lâm sàng, Bác sĩ siêu âm, Nhân viên.

Đặc tả use case chi tiết ở `docs/cams-dac-ta-use-case.md`. Bộ prompt triển khai ở `docs/cams-prompt.md`. Đọc khi cần, không tự ý làm trước.

## Nguyên tắc bất biến

- Hệ thống KHÔNG có cổng thanh toán. Bệnh nhân trả tiền mặt tại quầy, staff xác nhận. Không thêm bất kỳ phương thức thanh toán điện tử nào.
- Bệnh nhân không bao giờ được tự đánh dấu đã thanh toán.
- Bác sĩ lâm sàng không sửa được kết luận của bác sĩ siêu âm.
- Staff không sửa được chẩn đoán hay đơn thuốc.
- Không có trạng thái nào được phép khiến một ca treo vĩnh viễn.

## Phạm vi

- Chỉ làm đúng những gì task hiện tại nêu. Thấy chỗ khác cần sửa thì ghi ra, không tự sửa.
- Không thêm use case mới ngoài đặc tả.
- Không đổi tên, chữ ký, URL của servlet/DAO/service đang có trừ khi task nói rõ.
- Không refactor ngoài phạm vi. Thay đổi tối thiểu.
- Không đổi framework, không thêm thư viện UI.
- Nếu bắt buộc phải vượt phạm vi mới làm được: DỪNG và hỏi.

## Cơ sở dữ liệu

Chỉ được phép thêm đúng bốn nhóm sau, ngoài ra phải dừng và hỏi:

1. `appointments`: một cột số lưu giá khám
2. `invoices`: `paid_at`, `paid_by_user_id`, `payment_method`
3. `invoices`: bổ sung giá trị trạng thái `Refunded`
4. Bảng mới `service_price_history`

Mọi câu `ALTER TABLE` / `CREATE TABLE` phải viết ra cho người dùng chạy tay, KHÔNG tự chạy.

Tuyệt đối không thêm: cột `current_step`, cột lưu trạng thái quy trình, bảng doanh thu tổng hợp, bảng hàng đợi riêng. Tất cả phải suy ra từ dữ liệu gốc mỗi lần truy vấn.

## Đúng đắn và bảo mật

- Mọi validate nghiệp vụ và kiểm tra quyền phải ở SERVER. Ẩn hoặc disable ở JSP/JavaScript chỉ là lớp phụ.
- Mọi action nhận id từ URL hoặc form phải kiểm tra chủ sở hữu hoặc phân công trước khi xử lý.
- Mọi thao tác ghi nhiều bảng phải nằm trong một transaction có rollback.
- Mọi thao tác đổi trạng thái hoặc đụng tới tiền phải ghi audit log.
- Chống gửi trùng: bấm hai lần hoặc F5 gửi lại không được tạo bản ghi trùng hay cộng trừ số liệu hai lần.

## Giao diện

- Toàn bộ chữ hiển thị bằng tiếng Việt, không lộ tên trạng thái kỹ thuật.
- Ngày `dd/MM/yyyy`, giờ `HH:mm`, tiền có phân cách nghìn kèm "đ".
- Khung hiển thị rõ toàn bộ nội dung, không chồng đè, không tràn, không bị sidebar che.
- Danh sách rỗng phải có dòng thông báo, không để bảng trống.
- Lỗi trả thông báo tiếng Việt dễ hiểu, không trả 500 hay trang trắng, không lộ thông tin kỹ thuật.

## Quyết định nghiệp vụ đã chốt

| Vấn đề | Chốt |
|---|---|
| Đổi lịch | Chỉ đổi slot cùng một bác sĩ. Muốn đổi bác sĩ thì huỷ rồi đặt lại. |
| Đổi/huỷ khi đã thanh toán | Bệnh nhân không tự làm được, chuyển sang quầy xử lý hoàn tiền. |
| Hạn chót đổi/huỷ | 2 giờ trước giờ bắt đầu ca. |
| Kê đơn chặn chốt hồ sơ | Không chặn. Hoá đơn thuốc do staff xử lý riêng ở quầy. |
| Nhiều chỉ định siêu âm | Cho phép. Mở khoá chẩn đoán khi TẤT CẢ đã hoàn thành. |
| AI Engine chết | Cho phép bỏ qua AI, vẽ thủ công hoàn toàn, ghi log ca không qua AI. |
| Thống kê vs doanh thu | Thống kê = số lượt. Doanh thu = tiền. Hai màn hình tách biệt. |
| Đổi giá dịch vụ | Hoá đơn đã phát hành không đổi. Giá mới chỉ áp cho chỉ định sau đó. |
| Ca kéo dài qua ngày | Chấp nhận, không auto huỷ. Manager có danh sách ca chưa chốt quá 24h. |
| Bác sĩ khám song song | Cho phép nhiều ca đang khám cùng lúc. |

## Cách làm việc

1. Đọc code liên quan, báo cáo hiện trạng và danh sách file sẽ sửa kèm tóm tắt thay đổi. CHỜ xác nhận.
2. Sửa theo từng phần nhỏ.
3. Liệt kê file đã sửa, sửa gì, và các bước để người dùng tự test trên localhost:8080.


- Ảnh siêu âm lưu nguyên bytes gốc, KHÔNG re-encode qua ImageIO. Re-encode làm
  giảm chất lượng ảnh chẩn đoán. Chỉ avatar mới re-encode.
  - MockAiEngineServlet dựa vào isLoopbackRequest. Nếu sau này đặt sau reverse
  proxy, kiểm tra này mất tác dụng — phải chuyển sang kiểm tra token là chính.