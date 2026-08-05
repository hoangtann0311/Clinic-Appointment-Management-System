Clinic Appointment Management System (CAMS)

Hệ thống web quản lý toàn bộ vòng đời lịch khám tại phòng khám sản phụ khoa: từ đặt lịch, tiếp nhận, thanh toán tại quầy, khám lâm sàng, chỉ định siêu âm, đến công bố kết quả và chốt hồ sơ. CAMS tích hợp AI thị giác máy tính để **hỗ trợ** phát hiện và phân vùng vùng nghi ngờ u xơ tử cung trên ảnh siêu âm; quyết định chuyên môn vẫn do bác sĩ siêu âm xác nhận.

## Điểm nổi bật

- Quản lý lịch hẹn, khung giờ, hàng đợi, bệnh án, đơn thuốc, hóa đơn và báo cáo vận hành trong cùng một hệ thống.
- Phân quyền theo 6 vai trò, kiểm tra quyền ở server và giới hạn dữ liệu theo chủ sở hữu/phân công ca.
- Thanh toán tiền mặt tại quầy: lưu người xác nhận, thời điểm thanh toán và chống ghi nhận doanh thu trùng lặp.
- Điều phối quy trình khám theo trạng thái suy ra từ dữ liệu nguồn, chặn thao tác sai bước ở cả giao diện lẫn server.
- Tích hợp AI theo mô hình *human-in-the-loop*: bác sĩ siêu âm có thể chấp nhận kết quả AI hoặc hiệu chỉnh bằng vùng vẽ thủ công trước khi ký.

## Luồng nghiệp vụ chính

1. **Bệnh nhân** chọn bác sĩ, khung giờ, nhập triệu chứng và tạo lịch hẹn.
2. **Lễ tân** duyệt lịch, tạo hóa đơn phí khám và xác nhận thu tiền mặt tại quầy.
3. Sau khi thanh toán, lễ tân **check-in**, cấp số thứ tự và điều phối bệnh nhân vào hàng chờ.
4. **Bác sĩ lâm sàng** tiếp nhận ca, lập bệnh án nháp và quyết định có chỉ định siêu âm hay không.
5. Nếu không cần siêu âm, bác sĩ chẩn đoán, kê đơn khi cần và chốt hồ sơ.
6. Nếu cần siêu âm, hệ thống tạo chỉ định cùng hóa đơn dịch vụ; lễ tân xác nhận thanh toán trước khi ca được chuyển đến bác sĩ siêu âm.
7. **Bác sĩ siêu âm** tiếp nhận ca, tải ảnh JPEG/PNG và yêu cầu AI phân tích vùng nghi ngờ.
8. Bác sĩ siêu âm kiểm tra kết quả: chấp nhận bounding box AI hoặc từ chối để vẽ vùng thủ công; khi AI lỗi, vẫn có thể hoàn tất bằng thao tác thủ công.
9. Bác sĩ siêu âm lập báo cáo, ký và công bố kết quả. Bác sĩ lâm sàng chỉ xem kết quả này ở chế độ chỉ đọc để chẩn đoán và chốt hồ sơ.
10. Khi hồ sơ đã chốt, **bệnh nhân** có thể xem bệnh án, đơn thuốc, hóa đơn và kết quả của chính mình.

## Chức năng theo vai trò

| Vai trò | Chức năng chính |
|---|---|
| **Bệnh nhân** | Cập nhật hồ sơ, đặt lịch, theo dõi lịch/hàng đợi, hủy lịch đủ điều kiện, xem hóa đơn, bệnh án, đơn thuốc và kết quả thuộc về mình. |
| **Nhân viên lễ tân** | Tra cứu/đăng ký bệnh nhân, tạo và duyệt lịch, thu tiền mặt, check-in, đánh dấu ưu tiên/không đến, hoàn tiền và quản lý hàng đợi tiếp nhận. |
| **Bác sĩ lâm sàng** | Tiếp nhận ca được phân công, lập bệnh án, chỉ định hoặc hủy chỉ định siêu âm hợp lệ, xem kết quả siêu âm chỉ đọc, chẩn đoán, kê đơn và chốt hồ sơ. |
| **Bác sĩ siêu âm** | Nhận ca siêu âm được phân công, tải ảnh, chạy AI, đánh giá/chỉnh sửa kết quả bằng vùng vẽ thủ công, lập báo cáo, ký và công bố kết quả. |
| **Quản lý** | Quản lý dịch vụ và lịch sử giá, lịch làm việc/khung giờ, xem bác sĩ, thống kê số lượt sử dụng dịch vụ và báo cáo doanh thu chi tiết. |
| **Quản trị viên** | Quản lý người dùng/trạng thái tài khoản, danh mục dịch vụ–thuốc–bảng giá và theo dõi audit log hệ thống. |

## AI hỗ trợ siêu âm

| Hạng mục | Triển khai |
|---|---|
| **Bài toán** | Phát hiện và phân vùng vùng nghi ngờ u xơ tử cung trên ảnh siêu âm. |
| **Kiến trúc** | YOLOv3 định vị bounding box kết hợp U-Net Small tạo mask phân vùng. |
| **Tích hợp** | Java gửi yêu cầu nội bộ đến AI engine, engine gọi script Python suy luận và trả về JSON gồm trạng thái, confidence, bounding box, ảnh kết quả và mask. |
| **Kiểm soát đầu vào/đầu ra** | Chỉ nhận JPEG/PNG (tối đa 10 MB), xác thực nội dung ảnh và kích thước ở server; kiểm tra đường dẫn output, tọa độ bounding box và liên kết kết quả với đúng ảnh gốc. |
| **Human-in-the-loop** | Kết quả AI không tự chuyển thành kết luận lâm sàng. Bác sĩ siêu âm phải chấp nhận AI hoặc vẽ polygon hiệu chỉnh/bỏ qua AI rồi mới được ký. |
| **Khả năng chịu lỗi** | Có timeout kết nối/đọc phản hồi; khi AI không khả dụng, quy trình vẫn có thể hoàn tất bằng đánh dấu thủ công. |

Hồ sơ kỹ thuật đang hiển thị trong ứng dụng ghi nhận: YOLO Precision **90,28%**, Recall **83,33%**, F1-score **86,67%** và U-Net validation Dice **0,7073**. Các chỉ số này phục vụ đối chiếu kỹ thuật, không phải cam kết hiệu năng lâm sàng trong môi trường thực tế.

## Kiến trúc và công nghệ

JSP / Bootstrap / JavaScript
           ↓
Servlet Controllers → Service (nghiệp vụ, transaction) → DAO → SQL Server
           ↓
Authentication • RBAC • CSRF • Security Headers • Audit Log
           ↓
AI Engine nội bộ → Python inference (YOLOv3 + U-Net) → Kết quả/mask AI


- **Backend:** Java 17, Jakarta Servlet 6, JSP/JSTL, Apache Tomcat.
- **Database:** Microsoft SQL Server, Microsoft JDBC Driver.
- **Frontend:** JSP, Bootstrap 5, Bootstrap Icons, JavaScript.
- **Bảo mật & tích hợp:** BCrypt, Google OAuth 2.0, email xác thực/đặt lại mật khẩu, CSRF token, security headers và audit log.

## Bảo mật và tính toàn vẹn dữ liệu

- RBAC theo *role zone* và permission whitelist theo nguyên tắc **default deny**.
- Kiểm tra session, trạng thái tài khoản, quyền sở hữu bệnh nhân và phân công bác sĩ/siêu âm ở phía server.
- Bảo vệ CSRF cho các request thay đổi dữ liệu; header chống clickjacking, MIME sniffing và cache dữ liệu nhạy cảm.
- Mã hóa mật khẩu bằng BCrypt; hỗ trợ xác thực Google OAuth 2.0.
- Ghi audit cho truy cập quan trọng, giao dịch tiền, chuyển trạng thái và ký kết quả siêu âm.
- Dùng transaction cho các thao tác liên quan nhiều bảng; ngăn gửi lại request làm tạo lịch, hóa đơn hoặc doanh thu trùng.
