<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Điều Khoản & Chính Sách — CAMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
          rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=Inter:wght@400;600;700&display=swap"
          rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css?v=202" rel="stylesheet">
    <style>
        .policy-wrapper {
            max-width: 800px;
            margin: 0 auto;
            padding: 2.5rem 1.5rem 4rem;
        }
        .policy-back {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            color: var(--brand-pink-600);
            font-weight: 600;
            text-decoration: none;
            font-size: 0.95rem;
            margin-bottom: 1.8rem;
            transition: opacity 0.2s;
        }
        .policy-back:hover { opacity: 0.7; color: var(--brand-pink-700); }
        .policy-hero {
            text-align: center;
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 2px solid var(--brand-pink-100);
        }
        .policy-hero .icon-circle {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 64px; height: 64px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--brand-pink-100), var(--brand-pink-50));
            color: var(--brand-pink-600);
            font-size: 1.8rem;
            margin-bottom: 0.8rem;
        }
        .policy-hero h1 {
            font-family: 'Be Vietnam Pro', sans-serif;
            font-weight: 700;
            font-size: 1.7rem;
            color: var(--brand-pink-700);
            margin: 0;
        }
        .policy-hero .sub {
            font-size: 0.85rem;
            color: #6c757d;
            margin-top: 0.3rem;
        }
        .policy-card {
            background: #fff;
            border: 1px solid var(--brand-pink-100);
            border-radius: 14px;
            padding: 1.8rem 2rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 12px rgba(37,99,235,0.04);
        }
        .policy-card h2 {
            font-family: 'Be Vietnam Pro', sans-serif;
            font-weight: 600;
            font-size: 1.1rem;
            color: var(--brand-pink-600);
            margin-bottom: 0.85rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .policy-card h2 i { font-size: 1.2rem; color: var(--brand-pink-500); }
        .policy-card p,
        .policy-card li {
            font-size: 0.92rem;
            line-height: 1.75;
            color: #495057;
            margin-bottom: 0.25rem;
        }
        .policy-card ul {
            padding-left: 1.3rem;
            margin: 0;
        }
        .policy-card ul li { margin-bottom: 0.2rem; }
        .policy-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.2rem;
        }
        @media (max-width: 600px) {
            .policy-grid { grid-template-columns: 1fr; }
            .policy-card { padding: 1.4rem; }
        }
    </style>
</head>
<body style="background: #F8FAFC; min-height:100vh;">

<div class="policy-wrapper">
    <a class="policy-back" href="${pageContext.request.contextPath}/register">
        <i class="bi bi-arrow-left"></i> Quay lại trang đăng ký
    </a>

    <div class="policy-hero">
        <div class="icon-circle"><i class="bi bi-shield-check"></i></div>
        <h1>Điều Khoản Sử Dụng & Chính Sách Bảo Mật</h1>
        <p class="sub">Cập nhật: 25/07/2026 — CAMS · Hệ Thống Quản Lý Đặt Lịch Khám Thai</p>
    </div>

    <%-- ===== ĐIỀU KHOẢN SỬ DỤNG ===== --%>
    <div class="policy-card">
        <h2><i class="bi bi-journal-check"></i> 1. Chấp Nhận Điều Khoản</h2>
        <p>
            Bằng việc đăng ký và sử dụng CAMS, bạn xác nhận đã đọc, hiểu và đồng ý tuân thủ
            toàn bộ điều khoản dưới đây. Nếu không đồng ý, vui lòng không sử dụng hệ thống.
        </p>
    </div>

    <div class="policy-grid">
        <div class="policy-card">
            <h2><i class="bi bi-person-check"></i> 2. Đăng Ký & Tài Khoản</h2>
            <ul>
                <li>Người dùng từ đủ <strong>18 tuổi</strong> hoặc có sự đồng ý của người giám hộ.</li>
                <li>Cung cấp thông tin <strong>chính xác, trung thực</strong>. Mỗi người chỉ được tạo một tài khoản duy nhất.</li>
                <li>Sau khi đăng ký, bạn cần <strong>xác thực email</strong> trong vòng 24 giờ để kích hoạt tài khoản. Tài khoản chưa xác thực sẽ không thể đăng nhập.</li>
                <li>Bạn chịu trách nhiệm bảo mật mật khẩu. Mọi hoạt động từ tài khoản của bạn đều do bạn chịu trách nhiệm.</li>
            </ul>
        </div>
        <div class="policy-card">
            <h2><i class="bi bi-calendar2-check"></i> 3. Đặt Lịch & Khám Thai</h2>
            <ul>
                <li>Chọn bác sĩ, dịch vụ và khung giờ phù hợp. Lịch hẹn chỉ có hiệu lực sau khi nhận <strong>email xác nhận</strong> từ hệ thống.</li>
                <li>Đến đúng giờ. Trễ trên <strong>15 phút</strong> có thể bị hủy hoặc chuyển sang khung giờ khác.</li>
                <li>Hủy/đổi lịch <strong>trước ít nhất 24 giờ</strong>. Hủy đột xuất nhiều lần sẽ ảnh hưởng đến quyền đặt lịch.</li>
            </ul>
        </div>
    </div>

    <div class="policy-grid">
        <div class="policy-card">
            <h2><i class="bi bi-credit-card"></i> 4. Thanh Toán</h2>
            <ul>
                <li>Phí dịch vụ được hiển thị rõ ràng trước khi xác nhận đặt lịch.</li>
                <li>Thanh toán qua cổng an toàn. CAMS <strong>không lưu trữ</strong> thông tin thẻ ngân hàng.</li>
                <li>Hóa đơn điện tử được gửi qua email sau mỗi giao dịch.</li>
            </ul>
        </div>
        <div class="policy-card">
            <h2><i class="bi bi-exclamation-triangle"></i> 5. Giới Hạn Trách Nhiệm</h2>
            <ul>
                <li>CAMS là nền tảng <strong>trung gian kết nối</strong> sản phụ với phòng khám, hoạt động trên cơ sở "như hiện trạng".</li>
                <li>Không chịu trách nhiệm về chất lượng dịch vụ y tế do phòng khám/bác sĩ cung cấp.</li>
                <li>Vi phạm điều khoản có thể dẫn đến <strong>đình chỉ hoặc khóa</strong> tài khoản.</li>
            </ul>
        </div>
    </div>

    <%-- ===== CHÍNH SÁCH BẢO MẬT ===== --%>
    <div class="policy-card">
        <h2><i class="bi bi-database-lock"></i> 6. Thông Tin Chúng Tôi Thu Thập</h2>
        <p>Chúng tôi chỉ thu thập thông tin cần thiết để vận hành hệ thống:</p>
        <ul>
            <li><strong>Định danh:</strong> Họ tên, email, số điện thoại — tạo tài khoản, gửi thông báo lịch hẹn, xác thực.</li>
            <li><strong>Y tế:</strong> Tiền sử bệnh, thông tin thai kỳ, kết quả siêu âm, đơn thuốc, chỉ số sức khỏe — phục vụ bác sĩ chẩn đoán và theo dõi thai kỳ.</li>
            <li><strong>Lịch hẹn & Thanh toán:</strong> Ngày giờ khám, bác sĩ, dịch vụ đã chọn, lịch sử giao dịch.</li>
            <li><strong>Google OAuth:</strong> Nếu đăng nhập bằng Google, chúng tôi chỉ nhận tên hiển thị và email công khai từ tài khoản Google của bạn.</li>
        </ul>
    </div>

    <div class="policy-grid">
        <div class="policy-card">
            <h2><i class="bi bi-shield-lock"></i> 7. Cách Chúng Tôi Bảo Vệ Dữ Liệu</h2>
            <ul>
                <li>Mật khẩu: mã hóa <strong>BCrypt</strong> một chiều — ngay cả quản trị viên cũng không thể xem được.</li>
                <li>Truyền tải: toàn bộ dữ liệu qua giao thức <strong>HTTPS/TLS</strong>.</li>
                <li>Lưu trữ: dữ liệu nhạy cảm mã hóa <strong>AES-256</strong> trên máy chủ đặt tại Việt Nam.</li>
                <li>Phân quyền <strong>RBAC</strong>: mỗi vai trò (Admin, Bác sĩ, Quản lý, Lễ tân, Sản phụ, Bác sĩ siêu âm) chỉ truy cập được dữ liệu trong phạm vi nghiệp vụ của mình.</li>
            </ul>
        </div>
        <div class="policy-card">
            <h2><i class="bi bi-shield-check"></i> 8. Bảo Mật Hệ Thống</h2>
            <ul>
                <li>Chống tấn công <strong>CSRF</strong> (giả mạo yêu cầu) cho mọi form POST/PUT/DELETE.</li>
                <li>Security headers: <strong>CSP, X-Frame-Options, X-Content-Type-Options</strong> chống XSS và clickjacking.</li>
                <li><strong>Audit log</strong>: mọi truy cập dữ liệu nhạy cảm đều được ghi nhật ký kèm IP và thời gian.</li>
                <li>Tự động <strong>logout sau 30 phút</strong> không hoạt động.</li>
            </ul>
        </div>
    </div>

    <div class="policy-grid">
        <div class="policy-card">
            <h2><i class="bi bi-share"></i> 9. Chia Sẻ Thông Tin</h2>
            <ul>
                <li><strong>Không bán, không cho thuê</strong> dữ liệu người dùng dưới bất kỳ hình thức nào.</li>
                <li>Chỉ chia sẻ thông tin y tế và lịch hẹn với <strong>bác sĩ/phòng khám bạn đã chọn</strong> để phục vụ khám chữa bệnh.</li>
                <li>Chia sẻ với cơ quan pháp luật <strong>khi có yêu cầu chính thức</strong> theo quy định.</li>
            </ul>
        </div>
        <div class="policy-card">
            <h2><i class="bi bi-person-lock"></i> 10. Quyền Của Bạn</h2>
            <ul>
                <li><strong>Truy cập & Chỉnh sửa</strong> thông tin cá nhân trong mục Hồ sơ.</li>
                <li><strong>Xóa tài khoản</strong> — gửi yêu cầu, xử lý trong 30 ngày (hồ sơ y tế được giữ theo quy định Bộ Y Tế).</li>
                <li><strong>Rút lại đồng ý</strong> bất kỳ lúc nào.</li>
            </ul>
        </div>
    </div>

    <div class="policy-card">
        <h2><i class="bi bi-cookie"></i> 11. Cookie & Đăng Nhập Google</h2>
        <ul>
            <li>Chỉ dùng <strong>cookie phiên</strong> (JSESSIONID) để duy trì đăng nhập và <strong>CSRF token</strong> để bảo mật form.</li>
            <li><strong>Không</strong> sử dụng cookie quảng cáo, cookie theo dõi hay cookie bên thứ ba.</li>
            <li>Đăng nhập Google qua <strong>OAuth 2.0</strong> — chúng tôi không bao giờ thấy hoặc lưu mật khẩu Google của bạn.</li>
        </ul>
    </div>

    <%-- ===== LIÊN HỆ ===== --%>
    <div class="policy-card" style="background: var(--brand-pink-50); border-color: var(--brand-pink-100);">
        <h2><i class="bi bi-telephone"></i> Liên Hệ</h2>
        <p style="margin-bottom:0;">
            <strong>Email:</strong> trunghieu23092004@gmail.com &nbsp;|&nbsp;
            <strong>Điện thoại:</strong> 0888 182 004
        </p>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous">
</script>
</body>
</html>
