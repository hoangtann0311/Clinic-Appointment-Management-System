<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CAMS — Hệ Thống Chăm Sóc Thai Kỳ & Đặt Lịch Khám</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Inter:wght@300;400;500;600;700&family=Be+Vietnam+Pro:wght@400;600;700;800;900&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
</head>
<body>

    <!-- Header Navigation -->
    <nav class="navbar navbar-expand-lg home-navbar sticky-top">
        <div class="container">
            <a href="${pageContext.request.contextPath}/" class="home-navbar-brand">
                <i class="bi bi-clipboard2-heart-fill"></i>
                CAMS
            </a>
            <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#homeNav" aria-controls="homeNav" aria-expanded="false" aria-label="Toggle navigation">
                <i class="bi bi-list fs-2 text-dark"></i>
            </button>
            <div class="collapse navbar-collapse" id="homeNav">
                <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="home-nav-link" href="#features">Tính năng</a>
                    </li>
                    <li class="nav-item">
                        <a class="home-nav-link" href="#benefits">Lợi ích</a>
                    </li>
                    <li class="nav-item">
                        <a class="home-nav-link" href="#doctors">Đội ngũ Bác sĩ</a>
                    </li>
                    <li class="nav-item">
                        <a class="home-nav-link" href="#faq">Hỏi đáp</a>
                    </li>
                </ul>
                <div class="d-flex align-items-center gap-3">
                    <a href="${pageContext.request.contextPath}/login" class="btn-home-outline">Đăng nhập</a>
                    <a href="${pageContext.request.contextPath}/register" class="btn-home-primary">Đăng ký ngay</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <header class="home-hero">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-7 text-start">
                    <div class="hero-tag">
                        <i class="bi bi-stars"></i> Trợ lý Y tế & Đặt Lịch Khám Thông Minh Thế hệ mới
                    </div>
                    <h1 class="hero-title">
                        Hành Trình Chăm Sóc Sức Khỏe,<br>Trọn Vẹn Cùng <span>CAMS</span>
                    </h1>
                    <p class="hero-sub">
                        Hệ thống quản lý phòng khám và đặt lịch chăm sóc sức khỏe thông minh. Đồng hành cùng bạn trên mọi hành trình sức khỏe với trải nghiệm đặt lịch nhanh chóng, nhắc lịch khám tự động và cảnh báo cấp cứu SOS 24/7.
                    </p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="${pageContext.request.contextPath}/register" class="btn-home-primary px-4 py-3 fs-6">
                            <i class="bi bi-calendar-plus me-2"></i> Bắt đầu theo dõi sức khỏe
                        </a>
                        <a href="#features" class="btn-home-outline px-4 py-3 fs-6">
                            Tìm hiểu thêm <i class="bi-arrow-down ms-2"></i>
                        </a>
                    </div>
                </div>
                
                <div class="col-lg-5">
                    <div class="hero-mockup-container">
                        <div class="mockup-bg-glow"></div>
                        <!-- Mockup Panel -->
                        <div class="mockup-panel">
                            <div class="mockup-user-info">
                                <div class="d-flex align-items-center gap-2">
                                    <div class="mockup-avatar">H</div>
                                    <div>
                                        <h6 class="m-0 fw-bold text-dark" style="font-size: 0.9rem;">Hoàng Thị Đan</h6>
                                        <small class="text-muted" style="font-size: 0.75rem;">Thai kỳ: Tuần 24 (Tam cá nguyệt 2)</small>
                                    </div>
                                </div>
                                <span class="mockup-status-badge">Thai kỳ khỏe mạnh</span>
                            </div>

                            <h6 class="fw-bold text-dark mb-3" style="font-size: 0.85rem;"><i class="bi bi-clock-history text-danger"></i> Lịch Sinh Hoạt & Nhắc Nhở Y Tế</h6>

                            <div class="mockup-task-item">
                                <i class="bi bi-check-circle-fill text-success"></i>
                                <div>
                                    <div class="mockup-task-title">Bổ sung dinh dưỡng</div>
                                    <div class="mockup-task-desc">Uống Canxi & Sắt sau ăn sáng (Đã hoàn thành lúc 08:30)</div>
                                </div>
                            </div>

                            <div class="mockup-task-item">
                                <i class="bi bi-circle text-muted"></i>
                                <div>
                                    <div class="mockup-task-title">Lịch khám thai định kỳ</div>
                                    <div class="mockup-task-desc">Khám mốc 24 tuần tại phòng khám lúc 14:00 hôm nay</div>
                                </div>
                            </div>

                            <div class="mockup-task-item">
                                <i class="bi bi-circle text-muted"></i>
                                <div>
                                    <div class="mockup-task-title">Đếm cử động thai nhi (Kick counter)</div>
                                    <div class="mockup-task-desc">Theo dõi cử động của bé vào lúc 20:00 tối</div>
                                </div>
                            </div>

                            <!-- Emergency SOS Widget Mockup -->
                            <div class="mockup-alert-panel">
                                <i class="bi bi-exclamation-triangle-fill"></i>
                                <div>
                                    <div class="fw-bold text-danger" style="font-size: 0.85rem;">Nút khẩn cấp SOS kích hoạt</div>
                                    <div class="text-muted" style="font-size: 0.75rem;">Một chạm để kết nối trực tiếp với bác sĩ trực ca của phòng khám khi có bất thường.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <!-- Features Section -->
    <section class="home-section" id="features">
        <div class="container">
            <div class="section-header scroll-reveal">
                <span class="section-tag">Tính năng chính</span>
                <h2 class="section-title">Giải Pháp Toàn Diện Cho Thai Kỳ Khỏe Mạnh</h2>
            </div>
            
            <div class="row g-4">
                <div class="col-md-6 col-lg-3 scroll-reveal reveal-delay-1">
                    <div class="feature-card">
                        <div class="feature-icon-circle">
                            <i class="bi bi-calendar2-check-fill"></i>
                        </div>
                        <h5 class="fw-bold text-dark mb-3">Đặt Lịch Nhanh Chóng</h5>
                        <p class="text-muted mb-0 font-size-14">
                            Chọn bác sĩ yêu thích, dịch vụ khám phù hợp và đặt lịch trực tuyến chỉ trong 30 giây, giúp mẹ tiết kiệm thời gian chờ đợi.
                        </p>
                    </div>
                </div>

                <div class="col-md-6 col-lg-3 scroll-reveal reveal-delay-2">
                    <div class="feature-card">
                        <div class="feature-icon-circle">
                            <i class="bi bi-bell-fill"></i>
                        </div>
                        <h5 class="fw-bold text-dark mb-3">Nhắc Lịch Tự Động</h5>
                        <p class="text-muted mb-0 font-size-14">
                            Hệ thống thông minh tự động nhắc lịch khám, lịch tiêm phòng và lịch uống thuốc định kỳ qua SMS/Zalo để mẹ không bỏ lỡ cột mốc quan trọng.
                        </p>
                    </div>
                </div>

                <div class="col-md-6 col-lg-3 scroll-reveal reveal-delay-3">
                    <div class="feature-card">
                        <div class="feature-icon-circle" style="background-color: #fff1f2; color: #e11d48;">
                            <i class="bi bi-activity"></i>
                        </div>
                        <h5 class="fw-bold text-dark mb-3">Cảnh Báo Đỏ SOS</h5>
                        <p class="text-muted mb-0 font-size-14">
                            Kênh kết nối y tế khẩn cấp, tự động định vị GPS và gửi chuông cảnh báo âm lượng lớn tới bác sĩ khi sản phụ gặp triệu chứng nguy hiểm.
                        </p>
                    </div>
                </div>

                <div class="col-md-6 col-lg-3 scroll-reveal">
                    <div class="feature-card">
                        <div class="feature-icon-circle">
                            <i class="bi bi-folder-fill"></i>
                        </div>
                        <h5 class="fw-bold text-dark mb-3">Hồ Sơ Điện Tử</h5>
                        <p class="text-muted mb-0 font-size-14">
                            Lưu trữ toàn bộ lịch sử khám thai, kết quả siêu âm và chỉ số sinh hiệu trực tuyến giúp mẹ dễ dàng theo dõi và tra cứu khi cần.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Benefits Section -->
    <section class="home-section bg-light-rose" id="benefits">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-6 scroll-reveal">
                    <span class="section-tag text-start">Tại sao chọn CAMS?</span>
                    <h2 class="section-title mb-4">Sự Hài Lòng Của Mẹ Là Ưu Tiên Hàng Đầu</h2>
                    <p class="text-muted mb-4">
                        Chúng tôi cam kết mang lại trải nghiệm y tế sản phụ khoa chất lượng cao nhất, kết hợp công nghệ hiện đại với sự chăm sóc tận tâm như người nhà.
                    </p>
                    
                    <div class="d-flex flex-column gap-3">
                        <div class="benefit-item">
                            <i class="bi bi-patch-check-fill benefit-icon"></i>
                            <div>
                                <h6 class="fw-bold text-dark mb-1">Quy trình chuyên nghiệp, nhanh gọn</h6>
                                <p class="text-muted small mb-0">Hạn chế tối đa thời gian chờ đợi tại quầy tiếp đón phòng khám.</p>
                            </div>
                        </div>

                        <div class="benefit-item">
                            <i class="bi bi-patch-check-fill benefit-icon"></i>
                            <div>
                                <h6 class="fw-bold text-dark mb-1">Đội ngũ y bác sĩ đầu ngành sản phụ khoa</h6>
                                <p class="text-muted small mb-0">Các bác sĩ trình độ chuyên môn cao, giàu kinh nghiệm từ các bệnh viện lớn.</p>
                            </div>
                        </div>

                        <div class="benefit-item">
                            <i class="bi bi-patch-check-fill benefit-icon"></i>
                            <div>
                                <h6 class="fw-bold text-dark mb-1">An toàn thông tin bảo mật tuyệt đối</h6>
                                <p class="text-muted small mb-0">Hồ sơ sức khỏe của mẹ và bé được mã hóa an toàn trên cloud.</p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="col-lg-6 scroll-reveal reveal-delay-2">
                    <div class="p-4 bg-white rounded-4 border border-rose" style="border: 1px solid var(--brand-pink-100);">
                        <h6 class="fw-bold text-dark mb-3"><i class="bi bi-quote text-danger fs-3"></i> Đánh giá từ các mẹ bầu</h6>
                        <figure class="mb-0">
                            <blockquote class="blockquote font-size-14 text-dark italic">
                                "Nhờ hệ thống đặt lịch khám trực tuyến CAMS, mình không còn phải chịu cảnh xếp hàng mệt mỏi từ sáng sớm. Hệ thống nhắc nhở uống thuốc và theo dõi cân nặng hàng tuần rất chi tiết. Mình cảm thấy cực kỳ an tâm trong lần đầu mang thai này!"
                            </blockquote>
                            <figcaption class="blockquote-footer mt-2 mb-0 font-size-12">
                                <strong class="text-dark">Chị Mai Anh</strong> (Sản phụ khám mốc 32 tuần, Hà Nội)
                            </figcaption>
                        </figure>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Doctors Section -->
    <section class="home-section" id="doctors">
        <div class="container">
            <div class="section-header scroll-reveal">
                <span class="section-tag">Chuyên gia đồng hành</span>
                <h2 class="section-title">Đội Ngũ Bác Sĩ Tận Tâm & Giàu Kinh Nghiệm</h2>
            </div>
            
            <div class="row g-4 justify-content-center">
                <div class="col-md-6 col-lg-3 scroll-reveal reveal-delay-1">
                    <div class="doctor-card">
                        <div class="doctor-avatar-wrapper">
                            <div class="doctor-avatar">
                                <img src="${pageContext.request.contextPath}/assets/images/doctor-obgyn-01.svg" alt="Ảnh minh họa bác sĩ sản phụ khoa" onerror="this.classList.add('is-missing'); this.style.display='none';">
                                <span class="doctor-avatar-fallback" aria-label="Ảnh đại diện mặc định"><i class="bi bi-person-badge"></i></span>
                            </div>
                        </div>
                        <h5 class="doctor-name">ThS.BS Nguyễn Thị Anh</h5>
                        <span class="doctor-role">Trưởng khoa Sản Phụ Khoa</span>
                        <p class="text-muted small mb-0">Hơn 15 năm kinh nghiệm điều trị sản phụ khoa lâm sàng.</p>
                    </div>
                </div>

                <div class="col-md-6 col-lg-3 scroll-reveal reveal-delay-2">
                    <div class="doctor-card">
                        <div class="doctor-avatar-wrapper">
                            <div class="doctor-avatar">
                                <img src="${pageContext.request.contextPath}/assets/images/doctor-obgyn-02.svg" alt="Ảnh minh họa bác sĩ siêu âm" onerror="this.classList.add('is-missing'); this.style.display='none';">
                                <span class="doctor-avatar-fallback" aria-label="Ảnh đại diện mặc định"><i class="bi bi-person-badge"></i></span>
                            </div>
                        </div>
                        <h5 class="doctor-name">BS CKI. Trần Văn Bình</h5>
                        <span class="doctor-role">Chuyên Gia Siêu Âm Chẩn Đoán</span>
                        <p class="text-muted small mb-0">Chuyên sâu siêu âm dị tật thai nhi, mốc 12w, 22w, 32w.</p>
                    </div>
                </div>

                <div class="col-md-6 col-lg-3 scroll-reveal reveal-delay-3">
                    <div class="doctor-card">
                        <div class="doctor-avatar-wrapper">
                            <div class="doctor-avatar">
                                <img src="${pageContext.request.contextPath}/assets/images/doctor-obgyn-03.svg" alt="Ảnh minh họa bác sĩ thai kỳ" onerror="this.classList.add('is-missing'); this.style.display='none';">
                                <span class="doctor-avatar-fallback" aria-label="Ảnh đại diện mặc định"><i class="bi bi-person-badge"></i></span>
                            </div>
                        </div>
                        <h5 class="doctor-name">ThS.BS Lê Hoài Chi</h5>
                        <span class="doctor-role">Bác Sĩ Điều Trị Cao Cấp</span>
                        <p class="text-muted small mb-0">Chuyên tư vấn quản lý thai nghén nguy cơ cao, tiểu đường thai kỳ.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- FAQ Section -->
    <section class="home-section bg-light-rose" id="faq">
        <div class="container">
            <div class="section-header scroll-reveal">
                <span class="section-tag">Hỏi đáp thường gặp</span>
                <h2 class="section-title">Giải Đáp Thắc Mắc Cho Mẹ</h2>
            </div>
            
            <div class="faq-accordion">
                <div class="faq-item scroll-reveal">
                    <button class="faq-btn text-start" type="button" data-bs-toggle="collapse" data-bs-target="#faq1" aria-expanded="true" aria-controls="faq1">
                        Làm thế nào để tôi đặt lịch khám thai trực tuyến?
                        <i class="bi bi-chevron-down"></i>
                    </button>
                    <div id="faq1" class="collapse show" data-bs-parent="#faq">
                        <div class="faq-body">
                            Mẹ chỉ cần bấm nút "Đăng ký ngay" để tạo tài khoản bệnh nhân, điền số điện thoại, sau đó chọn mốc khám, dịch vụ siêu âm, chọn bác sĩ và thời gian mong muốn. Hệ thống sẽ ngay lập tức xếp lịch và thông báo mã lịch hẹn tới mẹ qua SMS/Zalo.
                        </div>
                    </div>
                </div>

                <div class="faq-item scroll-reveal">
                    <button class="faq-btn collapsed text-start" type="button" data-bs-toggle="collapse" data-bs-target="#faq2" aria-expanded="false" aria-controls="faq2">
                        Tính năng SOS khẩn cấp hoạt động như thế nào?
                        <i class="bi bi-chevron-down"></i>
                    </button>
                    <div id="faq2" class="collapse" data-bs-parent="#faq">
                        <div class="faq-body">
                            Tính năng SOS dùng trong tình huống khẩn cấp khi sản phụ gặp nguy hiểm tại nhà hoặc trên đường. Khi kích hoạt qua Zalo OA hoặc ứng dụng, tọa độ GPS sẽ được gửi về quầy lễ tân để điều phối hỗ trợ y tế nhanh nhất. Đồng thời, nếu sản phụ đến thẳng quầy trong trạng thái nguy kịch, lễ tân sẽ kích hoạt báo động đỏ tại chỗ để chèn hồ sơ lên đầu hàng đợi khám.
                        </div>
                    </div>
                </div>

                <div class="faq-item scroll-reveal">
                    <button class="faq-btn collapsed text-start" type="button" data-bs-toggle="collapse" data-bs-target="#faq3" aria-expanded="false" aria-controls="faq3">
                        Hồ sơ thai sản trực tuyến có hiển thị kết quả siêu âm không?
                        <i class="bi bi-chevron-down"></i>
                    </button>
                    <div id="faq3" class="collapse" data-bs-parent="#faq">
                        <div class="faq-body">
                            Có. Sau khi bác sĩ siêu âm xong, toàn bộ kết quả, chỉ số sinh trắc học của thai nhi, cân nặng dự kiến và hình ảnh siêu âm 4D sẽ được cập nhật trực tiếp lên hồ sơ cá nhân trực tuyến của mẹ. Mẹ có thể đăng nhập vào cổng thông tin bệnh nhân để tải về hoặc xem lại bất cứ lúc nào.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="home-footer">
        <div class="container">
            <div class="row g-4 mb-4">
                <div class="col-lg-5">
                    <a href="${pageContext.request.contextPath}/" class="home-footer-brand text-decoration-none">
                        <i class="bi bi-clipboard2-heart-fill"></i> CAMS
                    </a>
                    <p class="small">
                        Hệ thống quản lý đặt lịch khám & chăm sóc sức khỏe thông minh CAMS.<br>
                        Tận tâm chăm sóc — Đồng hành cùng bạn vì cuộc sống khỏe mạnh và trọn vẹn của cả gia đình.
                    </p>
                    <p class="small text-white">Hotline cấp cứu: <strong>1900 123 456 (24/7)</strong></p>
                </div>
                <div class="col-6 col-lg-3 offset-lg-1">
                    <h6>Về phòng khám</h6>
                    <ul class="footer-links">
                        <li><a href="#features">Tính năng chính</a></li>
                        <li><a href="#benefits">Lợi ích khách hàng</a></li>
                        <li><a href="#doctors">Đội ngũ chuyên gia</a></li>
                    </ul>
                </div>
                <div class="col-6 col-lg-3">
                    <h6>Địa chỉ liên hệ</h6>
                    <p class="small mb-2"><i class="bi-geo-alt me-1"></i> Tòa nhà CAMS, Đường Nguyễn Chí Thanh, Đống Đa, Hà Nội</p>
                    <p class="small mb-2"><i class="bi-envelope me-1"></i> support@camsclinic.vn</p>
                    <p class="small"><i class="bi-telephone me-1"></i> (024) 3838 3838</p>
                </div>
            </div>
            <div class="border-top border-secondary pt-3 text-center">
                <p class="small mb-0">© 2026 CAMS Clinic. All rights reserved. Developed by SWP392 Team 3.</p>
            </div>
        </div>
    </footer>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Scroll Reveal JavaScript Logic -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Options for intersection observer
            const observerOptions = {
                root: null,
                rootMargin: '0px',
                threshold: 0.12 // Trigger when 12% of the element is visible
            };

            // Observer callback
            const observerCallback = (entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('visible');
                        observer.unobserve(entry.target); // Unobserve once animated
                    }
                });
            };

            // Initialize intersection observer
            const observer = new IntersectionObserver(observerCallback, observerOptions);

            // Observe all elements with scroll-reveal class
            document.querySelectorAll('.scroll-reveal').forEach(el => {
                observer.observe(el);
            });
        });
    </script>
</body>
</html>
