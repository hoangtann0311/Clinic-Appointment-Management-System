OCSS — Obstetric Clinic Scheduling & AI Support System

OCSS là hệ thống web quản lý phòng khám sản phụ khoa, hỗ trợ toàn bộ hành trình từ mở lịch khám, đặt lịch, tiếp nhận bệnh nhân, quản lý hàng đợi, khám thai, chỉ định siêu âm, phân tích ảnh bằng AI, bác sĩ xác nhận kết luận, kê đơn và thanh toán.

Hệ thống được phát triển bằng Java Servlet/JSP, SQL Server và một AI Engine riêng để hỗ trợ phát hiện vùng nghi ngờ u xơ trên ảnh siêu âm.

Nguyên tắc an toàn lâm sàng: AI chỉ đưa ra kết quả hỗ trợ như vùng nghi ngờ, độ tin cậy và ảnh đánh dấu. AI không được chẩn đoán, kê đơn hoặc tự động sửa bệnh án. Bác sĩ là người duy nhất xác nhận kết luận chuyên môn và công bố kết quả cho bệnh nhân.

1. Mục tiêu dự án

OCSS giải quyết các vấn đề chính trong vận hành phòng khám sản phụ khoa:

Quản lý lịch làm việc và khung giờ khám của bác sĩ.

Tránh đặt trùng lịch hoặc trùng time-slot.

Cho phép bệnh nhân đặt lịch trực tuyến và Staff đặt lịch tại quầy.

Hỗ trợ check-in, cấp số thứ tự và quản lý hàng đợi.

Ưu tiên ca khẩn cấp nội bộ bằng cơ chế SOS.

Quản lý bệnh án, thai kỳ và lịch sử khám.

Tạo, tiếp nhận và xử lý yêu cầu siêu âm.

Lưu ảnh siêu âm gốc và kết quả phân tích AI.

Hỗ trợ bác sĩ xem ảnh gốc, vùng AI đánh dấu và độ tin cậy.

Quản lý đơn thuốc, hóa đơn và thanh toán.

Phân quyền dữ liệu theo đúng vai trò và người sở hữu.

Ghi nhận audit log cho các thao tác nhạy cảm.

2. Phạm vi nghiệp vụ

2.1. Trong phạm vi

Quản lý người dùng và phân quyền.

Lịch làm việc của Doctor.

Manager duyệt hoặc từ chối lịch.

Quản lý time-slot.

Đặt lịch từ Patient Portal hoặc tại quầy.

Check-in, hàng đợi và SOS.

Quản lý bệnh án và thai kỳ.

Doctor tạo yêu cầu siêu âm.

Sonographer tiếp nhận và thực hiện siêu âm.

Upload ảnh siêu âm.

AI hỗ trợ phát hiện vùng nghi ngờ u xơ.

Doctor xác nhận kết luận.

Kê đơn thuốc.

Hóa đơn và thanh toán thủ công.

Thống kê, báo cáo, đánh giá và thông báo nội bộ.

2.2. Ngoài phạm vi

Quy trình xét nghiệm và Lab Technician.

AI tự động chẩn đoán.

AI tự động kê đơn.

Cổng thanh toán trực tuyến chính thức.

Tích hợp HIS/EMR của bệnh viện bên ngoài.

GPS SOS thực tế.

Zalo, SMS hoặc OTT chính thức.

Quản lý kho thuốc theo lô và hạn dùng chuyên sâu.

3. Kiến trúc tổng thể

flowchart LR
    Patient[Patient]
    Staff[Staff]
    Doctor[Doctor]
    Sono[Sonographer]
    Manager[Manager]
    Admin[Admin]
    Web[Java Servlet/JSP Web Application]
    DB[(SQL Server\nObstetricsClinicDB)]
    AI[Python AI Engine]

    Patient --> Web
    Staff --> Web
    Doctor --> Web
    Sono --> Web
    Manager --> Web
    Admin --> Web

    Web --> DB
    Web --> AI
    AI --> Web

Thành phần chính

Thành phần

Trách nhiệm

Java Web Application

Xử lý nghiệp vụ, phân quyền, giao diện JSP, Servlet, DAO và Service

SQL Server

Lưu người dùng, lịch khám, bệnh án, yêu cầu siêu âm, ảnh, AI result, hóa đơn và audit

AI Engine

Nhận ảnh, chạy detection/segmentation và trả kết quả kỹ thuật

File Storage

Lưu ảnh siêu âm gốc, mask và ảnh kết quả theo cấu hình an toàn

4. Công nghệ sử dụng

Web application

Java 17

Java Servlet

JSP

JSTL

JDBC

Apache Tomcat 10.1

Apache Ant

HTML5

CSS3

JavaScript

Database

Microsoft SQL Server

Database baseline: ObstetricsClinicDB

AI Engine

Python

YOLOv3 cho object detection

U-Net cho segmentation

OpenCV và các thư viện xử lý ảnh liên quan

JSON contract để tích hợp với hệ thống Java

5. Vai trò và trách nhiệm

Vai trò

Được phép thực hiện

Không được phép

Admin

Quản lý tài khoản, role, permission, audit và báo cáo tổng quan

Không sửa kết luận chuyên môn

Manager

Duyệt lịch Doctor, quản lý dịch vụ, thuốc, giá, slot và báo cáo

Không khám, kê đơn hoặc xác nhận AI

Staff

Đặt lịch tại quầy, check-in, queue, SOS và xác nhận thanh toán

Không sửa bệnh án hoặc kết luận siêu âm

Doctor

Khám, bệnh án, thai kỳ, yêu cầu siêu âm, xem AI, kết luận và kê đơn

Không tự xác nhận thanh toán

Sonographer

Nhận yêu cầu, thực hiện siêu âm, upload ảnh, chạy AI và cập nhật tiến độ

Không chẩn đoán cuối cùng hoặc kê đơn

Patient

Đặt/hủy lịch, xem dữ liệu của mình, hóa đơn và kết quả được công bố

Không xem dữ liệu người khác

AI Engine

Phân tích ảnh và trả kết quả kỹ thuật

Không có quyền quyết định lâm sàng

6. Luồng nghiệp vụ end-to-end

flowchart TD
    A[Doctor tạo lịch làm việc] --> B[Manager duyệt lịch]
    B --> C[Hệ thống công bố time-slot]
    C --> D[Patient hoặc Staff đặt lịch]
    D --> E[Staff xác nhận thanh toán pre-exam]
    E --> F[Staff check-in và cấp queue number]
    F --> G{Ca SOS?}
    G -- Có --> H[Ưu tiên Emergency_SOS]
    G -- Không --> I[Waiting]
    H --> J[Doctor khám]
    I --> J
    J --> K{Có chỉ định siêu âm?}
    K -- Không --> P[Doctor hoàn tất bệnh án]
    K -- Có --> L[Doctor tạo Yêu cầu siêu âm]
    L --> M[Staff xác nhận điều kiện thanh toán]
    M --> N[Sonographer thực hiện và upload ảnh]
    N --> O[AI phân tích ảnh]
    O --> Q[Doctor xem ảnh gốc và kết quả AI]
    Q --> P
    P --> R[Doctor kê đơn nếu cần]
    R --> S[Staff xác nhận thanh toán]
    S --> T[Patient xem kết quả được công bố]

7. Các module nghiệp vụ

7.1. Authentication và RBAC

Hệ thống hỗ trợ:

Đăng ký.

Đăng nhập.

Google Login nếu cấu hình.

Xác thực email.

Quên mật khẩu.

Đổi mật khẩu.

Khóa hoặc mở khóa tài khoản.

Gán role và permission.

Chặn truy cập route không hợp lệ.

Yêu cầu bảo mật:

Kiểm tra đăng nhập ở Filter.

Kiểm tra role tại route hoặc Servlet.

Kiểm tra ownership tại Service hoặc DAO.

Không tin ID role hoặc user gửi từ trình duyệt.

Không hiển thị stack trace và thông tin kết nối database.

7.2. Doctor Schedule và Time-slot

Luồng:

Doctor tạo lịch làm việc theo ngày hoặc ca.

Manager duyệt hoặc từ chối.

Chỉ lịch Approved mới được công bố.

Hệ thống hoặc Manager tạo time-slot.

Patient và Staff chỉ thấy slot hợp lệ và còn trống.

Trạng thái Doctor Schedule:

Pending
Approved
Rejected
Cancelled

Business rules:

Không công bố lịch chưa được duyệt.

Không đặt lịch trong quá khứ.

Một time-slot chỉ được liên kết với một appointment đang hoạt động.

Hệ thống phải kiểm tra lại slot ngay trước khi lưu appointment.

Giữ slot và tạo appointment phải chạy trong transaction.

7.3. Đặt lịch khám

Patient hoặc Staff có thể:

Chọn Doctor.

Chọn dịch vụ.

Chọn ngày khám.

Chọn time-slot còn trống.

Nhập triệu chứng.

Nhập ngày kinh cuối nếu cần.

Xác nhận đặt lịch.

Hủy lịch theo chính sách.

Appointment phải liên kết đúng:

Patient

Doctor

Service

Time-slot

Nguồn đặt lịch

Thời gian tạo

Trạng thái hiện tại

Trạng thái chuẩn của Appointment:

Pending
Confirmed
Waiting
Emergency_SOS
InProgress
Completed
Cancelled
NoShow

7.4. Staff Check-in và hàng đợi

Staff chịu trách nhiệm:

Kiểm tra appointment.

Kiểm tra Patient.

Kiểm tra điều kiện thanh toán pre-exam.

Check-in.

Cấp queue number.

Đưa ca vào Waiting.

Theo dõi ca đang chờ, đang khám và hoàn tất.

Đánh dấu NoShow khi phù hợp.

Business rules:

Chỉ Staff được check-in.

Chỉ Staff được cấp queue number.

Queue number không được trùng trong cùng phạm vi vận hành.

Appointment Cancelled, Completed hoặc NoShow không được check-in.

Dữ liệu queue và appointment phải được cập nhật nhất quán.

7.5. Emergency SOS

SOS là cơ chế điều phối ưu tiên nội bộ.

Khi kích hoạt SOS, hệ thống phải:

Chuyển appointment sang Emergency_SOS.

Đưa ca lên trước ca Waiting.

Lưu lý do.

Lưu người thao tác.

Lưu thời điểm.

Gửi thông báo nội bộ.

Ghi audit log.

Không làm mất queue number hoặc hồ sơ.

SOS không thay thế quy trình cấp cứu y tế thực tế.

7.6. Medical Record và Pregnancy Tracking

Doctor có thể:

Ghi sinh hiệu.

Ghi triệu chứng.

Ghi tiền sử.

Cập nhật thông tin thai kỳ.

Theo dõi pregnancy timeline.

Xem lịch sử khám.

Tạo yêu cầu siêu âm.

Kê đơn.

Xác nhận kết luận.

Patient chỉ được xem dữ liệu của chính mình và chỉ khi dữ liệu được phép công bố.

7.7. Yêu cầu siêu âm

Chỉ Doctor được tạo yêu cầu siêu âm.

Một yêu cầu siêu âm phải liên kết đúng với:

Patient

Appointment

Medical Record

Doctor chỉ định

Dịch vụ siêu âm

Sonographer xử lý

Ảnh siêu âm

Kết quả AI

Trạng thái chuẩn:

Pending
InProgress
Uploaded
Analyzing
AI_Failed
Completed
Cancelled

Bảng test_orders trong database là tên kỹ thuật kế thừa. Trong nghiệp vụ OCSS, bảng này được hiểu là Yêu cầu siêu âm, không phải yêu cầu xét nghiệm.

7.8. Sonographer Workflow

Sonographer thực hiện:

Mở danh sách yêu cầu đủ điều kiện.

Chọn yêu cầu được giao.

Chuyển sang InProgress.

Thực hiện siêu âm.

Upload ảnh gốc.

Chuyển sang Uploaded.

Khởi chạy AI.

Theo dõi trạng thái AI.

Xác nhận phần việc kỹ thuật đã hoàn tất.

Chuyển yêu cầu sang Completed để Doctor kết luận.

Sonographer không được:

Sửa kết luận của Doctor.

Kê đơn.

Xác nhận thanh toán.

Xem yêu cầu không thuộc phạm vi được giao.

7.9. Upload và bảo vệ ảnh siêu âm

Yêu cầu upload:

Hỗ trợ JPG, JPEG và PNG.

Kiểm tra MIME type thực tế.

Giới hạn dung lượng.

Đổi tên file bằng UUID.

Không dùng trực tiếp tên file do người dùng cung cấp.

Lưu metadata vào database.

Không đặt file trong thư mục public không kiểm soát.

Mọi request xem ảnh phải qua endpoint có xác thực.

Ghi audit khi upload, xem, sửa hoặc xóa.

Ảnh phải liên kết đúng với:

Yêu cầu siêu âm

Appointment

Medical Record

Patient

Người upload

Thời gian upload

7.10. AI Engine

AI Engine thực hiện hai bước chính:

Ultrasound Image
      ↓
YOLOv3 Detection
      ↓
Expanded Bounding Box
      ↓
U-Net Segmentation
      ↓
Mask Post-processing
      ↓
Result Image + JSON

Kết quả AI có thể gồm:

{
  "success": true,
  "detected": true,
  "confidence": 0.86,
  "message": "Phát hiện vùng nghi ngờ u xơ",
  "inputImage": "original-image-id",
  "resultImage": "result-image-id",
  "maskImage": "mask-image-id",
  "bbox": {
    "x": 120,
    "y": 80,
    "width": 240,
    "height": 180
  },
  "expandedBbox": {
    "x": 90,
    "y": 50,
    "width": 300,
    "height": 240
  },
  "rawMaskArea": 14500,
  "finalMaskArea": 11200,
  "modelVersion": "fibroid-v1.0",
  "processingTimeMs": 843
}

Trạng thái kỹ thuật:

Queued
Processing
Succeeded
Failed

Business rules:

detected=false là kết quả hợp lệ, không phải lỗi.

AI timeout phải trả trạng thái lỗi rõ ràng.

AI không được cập nhật diagnosis hoặc conclusion.

Doctor vẫn phải xem được ảnh gốc khi AI lỗi.

Mỗi kết quả phải lưu model version và confidence.

Kết quả phải liên kết đúng ảnh và Yêu cầu siêu âm.

7.11. Doctor Review và kết luận

Doctor xem:

Ảnh gốc.

Ảnh kết quả AI.

Bounding box.

Segmentation mask.

Confidence.

Message.

Model version.

Lịch sử phân tích.

Doctor là người duy nhất:

Ghi kết luận chuyên môn.

Cập nhật diagnosis.

Cập nhật recommendation.

Xác nhận kết quả.

Quyết định nội dung công bố cho Patient.

7.12. Prescription

Doctor có thể:

Chọn thuốc trong danh mục đang hoạt động.

Nhập liều dùng.

Nhập số lần dùng.

Nhập số ngày.

Nhập hướng dẫn.

Lưu đơn thuốc.

Chỉnh sửa trước khi hoàn tất theo điều kiện nghiệp vụ.

Business rules:

Không kê thuốc đã ngừng hoạt động.

Đơn thuốc phải liên kết appointment và medical record.

Bệnh nhân có thể từ chối mua thuốc tại phòng khám.

7.13. Invoice và thanh toán

Các loại hóa đơn:

PRE_EXAM
POST_EXAM
PRESCRIPTION

Trạng thái:

pending
paid
cancelled
declined_purchase

Staff chịu trách nhiệm:

Xác nhận tiền mặt.

Xác nhận chuyển khoản thủ công.

Kiểm tra bằng chứng giao dịch.

Xác nhận thanh toán.

Ghi nhận bệnh nhân từ chối mua thuốc.

Business rules:

Giá invoice item phải là snapshot tại thời điểm phát hành.

Không thay đổi hóa đơn đã thanh toán khi giá dịch vụ thay đổi.

Các thao tác liên quan nhiều bảng phải chạy trong transaction.

Không tạo hóa đơn trùng cho cùng nghiệp vụ nếu hệ thống không cho phép.

7.14. Notification và Audit Log

Các sự kiện cần thông báo:

Lịch Doctor được duyệt hoặc từ chối.

Appointment được tạo, đổi hoặc hủy.

Patient check-in.

Ca SOS được kích hoạt hoặc hủy.

Yêu cầu siêu âm mới.

AI hoàn tất hoặc thất bại.

Doctor hoàn tất kết luận.

Invoice được thanh toán.

Các thao tác cần audit:

Thay đổi tài khoản và quyền.

Thay đổi giá.

Đặt hoặc hủy lịch.

Check-in.

SOS.

Thanh toán.

Upload và xem ảnh siêu âm.

Chạy AI.

Sửa bệnh án.

Xác nhận kết luận.

8. Dữ liệu nghiệp vụ chính

Miền dữ liệu

Bảng hoặc đối tượng

Identity và RBAC

users, roles, permissions, role_permissions

Nhân sự và Patient

doctors, sonographers, patients

Lịch và tiếp nhận

doctor_schedules, time_slots, appointments

Thai kỳ và bệnh án

pregnancies, medical_records

Siêu âm và AI

test_orders, ultrasound_images, ai_analysis_results

Tài chính

invoices, invoice_items, prescriptions, prescription_items

Danh mục

services, service_categories, medicines, price_history

Hệ thống

notifications, audit_logs, reviews

9. Cấu trúc dự án

Cấu trúc điển hình của repository:

project-root/
├── build.xml
├── nbproject/
├── sql/
│   ├── schema/
│   ├── seed/
│   └── migrations/
├── src/
│   └── java/
│       └── com/
│           └── clinic/
│               ├── config/
│               ├── controller/
│               ├── dao/
│               ├── filter/
│               ├── model/
│               ├── service/
│               └── util/
├── web/
│   ├── assets/
│   │   ├── css/
│   │   ├── js/
│   │   └── images/
│   ├── views/
│   │   ├── admin/
│   │   ├── manager/
│   │   ├── staff/
│   │   ├── doctor/
│   │   ├── sonographer/
│   │   └── patient/
│   └── WEB-INF/
│       └── web.xml
└── ai-engine/
    ├── models/
    ├── pipeline/
    ├── predict_for_web.py
    ├── requirements.txt
    └── tests/

Khi thêm code mới:

Giữ đúng package com.clinic.*.

Không tạo thêm thư mục java/com/clinic sai vị trí.

Không đặt cấu hình database trong DAO.

Không commit file model hoặc dữ liệu lớn nếu repository không dùng Git LFS.

Database thay đổi phải đi kèm migration.

10. Yêu cầu môi trường

JDK 17

Apache Tomcat 10.1

Microsoft SQL Server

Apache Ant

IntelliJ IDEA hoặc NetBeans

Python 3.x cho AI Engine

Git

11. Cài đặt database

11.1. Tạo database

Tạo hoặc restore:

ObstetricsClinicDB

11.2. Chạy script

Chạy theo thứ tự:

Script tạo schema.

Script seed data.

Các migration trong thư mục sql/.

Kiểm tra foreign key, index và dữ liệu mẫu.

Migration phải:

Có khả năng chạy lại an toàn nếu có thể.

Không xóa dữ liệu y tế đã phát sinh.

Có transaction.

Có rollback khi lỗi.

Không tạo trùng constraint hoặc index.

12. Cấu hình database

Cấu hình tại:

src/java/com/clinic/config/DatabaseConfig.java

Hoặc dùng biến môi trường:

DB_HOST=localhost
DB_PORT=1433
DB_NAME=ObstetricsClinicDB
DB_USERNAME=sa
DB_PASSWORD=your_password

Không commit:

Mật khẩu database.

Secret key.

Google OAuth secret.

Đường dẫn máy cá nhân.

Thông tin bệnh nhân thật.

13. Build và chạy Web Application

Clone repository

git clone <REPOSITORY_URL>
cd <PROJECT_FOLDER>

Build bằng Ant

ant clean
ant build

Deploy lên Tomcat

Cấu hình Tomcat 10.1 trong IDE.

Deploy artifact hoặc WAR.

Khởi động SQL Server.

Khởi động Tomcat.

Truy cập context path được cấu hình.

Ví dụ:

http://localhost:8080/ClinicAppointmentManagementSystem

Context path có thể thay đổi tùy cấu hình repository.

14. Cài đặt AI Engine

Tạo virtual environment

cd ai-engine
python -m venv .venv

Windows:

.venv\Scripts\activate

Linux/macOS:

source .venv/bin/activate

Cài dependency

pip install -r requirements.txt

Cấu hình model

Đặt model theo cấu trúc:

ai-engine/models/
├── detector/
└── segmentation/

Chạy kiểm thử pipeline

python predict_for_web.py --input <IMAGE_PATH>

AI Engine phải trả JSON hợp lệ để Java đọc và lưu.

15. Chuẩn hóa trạng thái dữ liệu cũ

Database có thể còn dữ liệu lịch sử dùng nhiều cách viết:

completed
SUCCESS
Paid
paid
Unpaid
pending

DAO hoặc Service phải chuẩn hóa khi đọc và ghi để:

Dashboard không đếm sai.

Báo cáo không sai doanh thu.

Filter trạng thái không bỏ sót dữ liệu.

Phân quyền không bị sai do status khác hoa-thường.

Không sửa dữ liệu lịch sử hàng loạt khi chưa có migration và kiểm thử đầy đủ.

16. Kiểm thử bắt buộc

AT-01 — Doctor Schedule

Doctor tạo lịch.

Manager duyệt.

Slot xuất hiện cho Patient.

Lịch chưa duyệt không được công bố.

AT-02 — Booking và Check-in

Patient hoặc Staff đặt lịch.

Không đặt trùng slot.

Staff xác nhận thanh toán.

Staff check-in và cấp queue number.

AT-03 — SOS

Kích hoạt SOS cho ca hợp lệ.

Ca SOS được ưu tiên.

Có notification và audit.

Không làm mất appointment hoặc queue.

AT-04 — Tạo Yêu cầu siêu âm

Doctor tạo từ Medical Record.

Liên kết đúng Patient, appointment, Doctor và service.

Không phát sinh workflow xét nghiệm.

AT-05 — Sonographer và AI

Sonographer upload ảnh.

Ảnh gốc được lưu.

AI trả detected, confidence, message và ảnh kết quả.

AI lỗi không chặn xem ảnh gốc.

AT-06 — Doctor xác nhận kết luận

Doctor xem ảnh và AI.

Doctor ghi kết luận.

AI không tự cập nhật bệnh án.

AT-07 — Prescription và Invoice

Doctor kê đơn.

Invoice item lưu snapshot giá.

Staff xác nhận thanh toán.

Có thể ghi nhận từ chối mua thuốc.

AT-08 — Patient Data Ownership

Patient chỉ xem dữ liệu của chính mình.

Không truy cập được URL của Patient khác.

Chỉ xem kết quả đã được công bố.

AT-09 — Báo cáo

Doanh thu chỉ tính từ invoice paid.

Không hiển thị Lab Technician.

Không có nghiệp vụ xét nghiệm.

AT-10 — AI Failure

AI timeout hoặc không phản hồi.

Lưu AI_Failed hoặc Failed.

Doctor vẫn xem ảnh gốc.

Luồng khám vẫn tiếp tục.
