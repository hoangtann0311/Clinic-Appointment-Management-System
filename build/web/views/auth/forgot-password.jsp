<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên Mật Khẩu — CAMS</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <!-- Bootstrap Icons CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
          rel="stylesheet">
    <!-- Google Fonts: Be Vietnam Pro -->
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=Inter:wght@400;600;700&display=swap"
          rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css?v=202" rel="stylesheet">
</head>
<body class="login-page">

<div class="auth-split-wrapper w-100">
    <a class="auth-home-link" href="${pageContext.request.contextPath}/" aria-label="Quay về trang chủ CAMS">
        <i class="bi bi-arrow-left"></i><span>Quay lại trang chủ</span>
    </a>

    <%-- ==================== LEFT: Brand Panel ==================== --%>
    <div class="auth-split-left">
        <div class="auth-glow-blob auth-glow-blob-1"></div>
        <div class="auth-glow-blob auth-glow-blob-2"></div>

        <div class="auth-brand-content">
            <div class="auth-brand-logo">
                <i class="bi bi-clipboard2-heart-fill"></i>
            </div>
            <h1 class="auth-brand-title">Hành Trình Làm Mẹ An Nhiên</h1>
            <p class="auth-brand-desc">
                Chào mừng bạn đến với CAMS — Cổng thông tin chăm sóc thai kỳ thông minh và quản lý lịch hẹn sản phụ khoa trực tuyến.
            </p>

            <!-- Info Card Mockup -->
            <div class="auth-mockup-panel text-start">
                <div class="auth-mockup-header"><i class="bi bi-envelope-check me-1"></i> Hướng dẫn khôi phục</div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Nhập email đã đăng ký tài khoản CAMS</span>
                </div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Kiểm tra hộp thư nhận link đặt lại mật khẩu</span>
                </div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Link có hiệu lực trong 1 giờ — sử dụng một lần duy nhất</span>
                </div>
            </div>
        </div>
    </div>

    <%-- ==================== RIGHT: Form Panel ==================== --%>
    <div class="auth-split-right">
        <div class="auth-form-card">

            <div class="auth-form-header">
                <h2>Quên Mật Khẩu</h2>
                <p>Nhập email đã đăng ký để nhận liên kết đặt lại mật khẩu.</p>
            </div>

            <%-- ========== Error / Info Messages ========== --%>
            <c:if test="${not empty emailError}">
                <div class="login-alert login-alert-danger" role="alert">
                    <i class="bi bi-exclamation-triangle-fill fs-6"></i>
                    <div>${emailError}</div>
                </div>
            </c:if>

            <%-- ========== Forgot Password Form ========== --%>
            <form action="${pageContext.request.contextPath}/forgot-password" method="post" novalidate
                  onsubmit="return handleSubmit(this)">

                <%-- Email field --%>
                <div class="floating-group">
                    <input type="email"
                           class="floating-input ${not empty emailError ? 'is-invalid' : ''}"
                           id="email"
                           name="email"
                           placeholder=" "
                           value="${not empty emailValue ? emailValue : ''}"
                           required
                           autofocus>
                    <label class="floating-label" for="email">Email đã đăng ký</label>
                    <c:if test="${not empty emailError}">
                        <div class="invalid-feedback d-block">
                            <i class="bi bi-info-circle me-1"></i>${emailError}
                        </div>
                    </c:if>
                </div>
                <div class="form-text mb-4 text-muted" style="font-size: 0.8rem;">
                    <i class="bi bi-info-circle me-1"></i>Chúng tôi sẽ gửi link đặt lại mật khẩu vào email của bạn.
                </div>

                <%-- Submit Button --%>
                <button type="submit" class="btn-auth-submit mb-4" id="submitBtn">
                    <span>Gửi Link Đặt Lại Mật Khẩu</span>
                    <i class="bi bi-send"></i>
                </button>

                <%-- Quay lại đăng nhập --%>
                <div class="text-center small text-muted">
                    <a href="${pageContext.request.contextPath}/login"
                       style="color: var(--brand-pink-600); font-weight: 700; text-decoration: none;">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại Đăng Nhập
                    </a>
                </div>
            </form>

            <%-- Footer note --%>
            <div class="text-center mt-5 small text-muted">
                <i class="bi bi-shield-lock me-1"></i>
                Link đặt lại mật khẩu có hiệu lực trong vòng 1 giờ.
            </div>
        </div>
    </div>
</div>

<script>
function handleSubmit(form) {
    var emailInput = document.getElementById('email');
    var submitBtn = document.getElementById('submitBtn');

    // Basic client-side validation
    if (!emailInput.value.trim()) {
        emailInput.classList.add('is-invalid');
        var existing = emailInput.parentElement.querySelector('.invalid-feedback');
        if (!existing) {
            var feedback = document.createElement('div');
            feedback.className = 'invalid-feedback d-block';
            feedback.textContent = 'Vui lòng nhập địa chỉ email.';
            emailInput.parentElement.appendChild(feedback);
        }
        return false;
    }

    // Show loading state
    submitBtn.disabled = true;
    submitBtn.querySelector('span').textContent = 'Đang gửi...';
    submitBtn.querySelector('i').className = 'spinner-border spinner-border-sm';

    return true;
}

// Clear error on input
document.addEventListener('DOMContentLoaded', function() {
    var emailInput = document.getElementById('email');
    if (emailInput) {
        emailInput.addEventListener('input', function() {
            this.classList.remove('is-invalid');
            var feedback = this.parentElement.querySelector('.invalid-feedback');
            if (feedback) feedback.remove();
        });
    }
});
</script>

<!-- Bootstrap 5 JS Bundle CDN -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous">
</script>
</body>
</html>
