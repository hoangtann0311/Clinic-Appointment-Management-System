<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt Lại Mật Khẩu — CAMS</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <!-- Bootstrap Icons CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
          rel="stylesheet">
    <!-- Google Fonts: Inter + Be Vietnam Pro -->
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

            <!-- Checklist Card Mockup -->
            <div class="auth-mockup-panel text-start">
                <div class="auth-mockup-header"><i class="bi bi-shield-check me-1"></i> Bảo mật tài khoản</div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Mật khẩu mới được băm an toàn bằng BCrypt</span>
                </div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Liên kết xác thực mã hóa an toàn sử dụng một lần</span>
                </div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Thời hạn sử dụng link đặt lại có hiệu lực 1 giờ</span>
                </div>
            </div>
        </div>
    </div>

    <%-- ==================== RIGHT: Form Panel ==================== --%>
    <div class="auth-split-right">
        <div class="auth-form-card">

            <div class="auth-form-header">
                <h2>Đặt Lại Mật Khẩu</h2>
                <p>Nhập mật khẩu mới cho tài khoản của bạn để khôi phục quyền truy cập.</p>
            </div>

            <%-- ========== Error Messages ========== --%>
            <c:if test="${not empty errors}">
                <div class="login-alert login-alert-danger" role="alert">
                    <div>
                        <i class="bi bi-exclamation-triangle-fill me-2 fs-6"></i>
                        <strong>Lỗi đặt lại mật khẩu:</strong>
                        <ul class="mb-0 mt-2 ps-3">
                            <c:forEach items="${errors}" var="error">
                                <li>${error.value}</li>
                            </c:forEach>
                        </ul>
                    </div>
                </div>
            </c:if>

            <%-- Form đặt lại mật khẩu --%>
            <form action="${pageContext.request.contextPath}/reset-password"
                  method="post"
                  novalidate
                  onsubmit="return validateResetPasswordForm()">

                <%-- Token ẩn từ URL --%>
                <input type="hidden" name="token" value="${token}">

                <%-- Mật khẩu mới --%>
                <div class="floating-group">
                    <input type="password"
                           class="floating-input has-toggle ${not empty errors.newPassword ? 'is-invalid' : ''}"
                           id="newPassword"
                           name="newPassword"
                           placeholder=" "
                           required
                           autofocus>
                    <label class="floating-label" for="newPassword">Mật khẩu mới</label>
                    <button type="button"
                            class="floating-toggle"
                            data-target="newPassword"
                            tabindex="-1"
                            aria-label="Hiển thị mật khẩu">
                        <i class="bi bi-eye"></i>
                    </button>
                    <c:if test="${not empty errors.newPassword}">
                        <div class="invalid-feedback d-block">${errors.newPassword}</div>
                    </c:if>
                </div>
                <div class="form-text mt-1 mb-4 text-muted" style="font-size: 0.8rem;">
                    <i class="bi bi-info-circle me-1"></i>Mật khẩu phải có ít nhất 6 ký tự, gồm cả chữ cái, chữ số & ký tự đặc biệt (!@#$%...)
                </div>

                <%-- Xác nhận mật khẩu mới --%>
                <div class="floating-group">
                    <input type="password"
                           class="floating-input has-toggle ${not empty errors.confirmPassword ? 'is-invalid' : ''}"
                           id="confirmPassword"
                           name="confirmPassword"
                           placeholder=" "
                           required>
                    <label class="floating-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                    <button type="button"
                            class="floating-toggle"
                            data-target="confirmPassword"
                            tabindex="-1"
                            aria-label="Hiển thị mật khẩu">
                        <i class="bi bi-eye"></i>
                    </button>
                    <c:if test="${not empty errors.confirmPassword}">
                        <div class="invalid-feedback d-block">${errors.confirmPassword}</div>
                    </c:if>
                </div>

                <%-- Submit Button --%>
                <button type="submit" class="btn-auth-submit mb-4" id="submitBtn">
                    <span>Đặt Lại Mật Khẩu</span>
                    <i class="bi bi-arrow-right"></i>
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
                <i class="bi bi-shield-check me-1"></i>
                Mật khẩu của bạn sẽ được mã hóa và bảo mật.
            </div>
        </div>
    </div>
</div>

<script>
// ============================================================
// Client-side validation cho form đặt lại mật khẩu
// ============================================================

var VALIDATION = {
    MIN_PASSWORD_LENGTH: 6,
    HAS_LETTER: /[A-Za-z]/,
    HAS_DIGIT: /\d/,
    HAS_SPECIAL: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?`~]/
};

function validateResetPasswordForm() {
    var newPassword = document.getElementById('newPassword').value;
    var confirmPassword = document.getElementById('confirmPassword').value;

    // Reset tất cả lỗi trước đó
    clearAllErrors();

    var isValid = true;

    // ----- Mật khẩu mới -----
    if (newPassword === '') {
        showFieldError('newPassword', 'Mật khẩu mới không được để trống.');
        isValid = false;
    } else if (newPassword.length < VALIDATION.MIN_PASSWORD_LENGTH) {
        showFieldError('newPassword', 'Mật khẩu phải có ít nhất ' + VALIDATION.MIN_PASSWORD_LENGTH + ' ký tự.');
        isValid = false;
    } else if (!VALIDATION.HAS_LETTER.test(newPassword)) {
        showFieldError('newPassword', 'Mật khẩu phải chứa ít nhất 1 chữ cái.');
        isValid = false;
    } else if (!VALIDATION.HAS_DIGIT.test(newPassword)) {
        showFieldError('newPassword', 'Mật khẩu phải chứa ít nhất 1 chữ số.');
        isValid = false;
    } else if (!VALIDATION.HAS_SPECIAL.test(newPassword)) {
        showFieldError('newPassword', 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt (VD: !@#$%).');
        isValid = false;
    }

    // ----- Xác nhận mật khẩu -----
    if (confirmPassword === '') {
        showFieldError('confirmPassword', 'Xác nhận mật khẩu không được để trống.');
        isValid = false;
    } else if (confirmPassword !== newPassword) {
        showFieldError('confirmPassword', 'Xác nhận mật khẩu không khớp với mật khẩu mới.');
        isValid = false;
    }

    if (isValid) {
        var submitBtn = document.getElementById('submitBtn');
        submitBtn.disabled = true;
        submitBtn.querySelector('span').textContent = 'Đang xử lý...';
        submitBtn.querySelector('i').className = 'spinner-border spinner-border-sm';
    }

    return isValid;
}

function showFieldError(fieldId, message) {
    var field = document.getElementById(fieldId);
    if (!field) return;

    field.classList.add('is-invalid');

    var floatingGroup = field.closest('.floating-group');
    var feedback = floatingGroup ? floatingGroup.querySelector('.invalid-feedback') : null;

    if (!feedback) {
        feedback = document.createElement('div');
        feedback.className = 'invalid-feedback d-block';
        if (floatingGroup) {
            floatingGroup.appendChild(feedback);
        } else {
            field.parentElement.appendChild(feedback);
        }
    }
    feedback.textContent = message;
}

function clearAllErrors() {
    document.querySelectorAll('.floating-input.is-invalid').forEach(function(el) {
        el.classList.remove('is-invalid');
    });
    document.querySelectorAll('.invalid-feedback').forEach(function(el) {
        el.remove();
    });
}

// ============================================================
// Toggle hiển thị mật khẩu
// ============================================================
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.floating-toggle').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var targetId = this.getAttribute('data-target');
            var input = document.getElementById(targetId);
            var icon = this.querySelector('i');

            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('bi-eye');
                icon.classList.add('bi-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('bi-eye-slash');
                icon.classList.add('bi-eye');
            }
        });
    });
});
</script>

<!-- Bootstrap 5 JS Bundle CDN -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous">
</script>
</body>
</html>
