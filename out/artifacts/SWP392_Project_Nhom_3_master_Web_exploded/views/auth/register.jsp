<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Ký — CAMS</title>
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
    <link href="${pageContext.request.contextPath}/assets/css/style.css?v=101" rel="stylesheet">
    
</head>
<body class="register-page">

<div class="auth-split-wrapper w-100">
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
                Đăng ký tài khoản sản phụ CAMS để bắt đầu đặt lịch hẹn trực tuyến và quản lý hồ sơ sức khỏe thai kỳ.
            </p>
            
            <!-- Checklist Card Mockup -->
            <div class="auth-mockup-panel text-start">
                <div class="auth-mockup-header"><i class="bi bi-shield-check me-1"></i> Quy trình y tế tại CAMS</div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Chọn bác sĩ khám & giờ hẹn linh hoạt</span>
                </div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Nhận thông báo nhắc nhở tự động từ phòng khám</span>
                </div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Theo dõi kết quả lâm sàng nhanh chóng</span>
                </div>
            </div>
        </div>
    </div>

    <%-- ==================== RIGHT: Form Panel ==================== --%>
    <div class="auth-split-right">
        <div class="auth-form-card" style="max-width: 480px; padding: 1.5rem 0;">
            
            <div class="auth-form-header">
                <h2>Tạo Tài Khoản</h2>
                <p>Nhập thông tin đăng ký để sử dụng dịch vụ.</p>
            </div>

        <%-- ========== Server-side Error Display ========== --%>
        <c:if test="${not empty errors}">
            <div class="register-alert" role="alert">
                <strong><i class="bi bi-exclamation-triangle-fill me-2"></i>Vui lòng sửa các lỗi sau:</strong>
                <ul>
                    <c:forEach items="${errors}" var="error">
                        <li>${error.value}</li>
                    </c:forEach>
                </ul>
            </div>
        </c:if>

        <%-- ========== Registration Form ========== --%>
        <form class="register-form"
              action="${pageContext.request.contextPath}/register"
              method="post"
              novalidate
              onsubmit="return validateRegisterForm()">

            <%-- Full Name --%>
            <div class="floating-group">
                <input type="text"
                       class="floating-input ${not empty errors.fullName ? 'is-invalid' : ''}"
                       id="fullName"
                       name="fullName"
                       placeholder=" "
                       value="${fullName}"
                       maxlength="100"
                       required>
                <label class="floating-label" for="fullName">Họ và tên *</label>
                <c:if test="${not empty errors.fullName}">
                    <div class="invalid-feedback d-block">${errors.fullName}</div>
                </c:if>
            </div>

            <%-- Email --%>
            <div class="floating-group">
                <input type="email"
                       class="floating-input ${not empty errors.email ? 'is-invalid' : ''}"
                       id="email"
                       name="email"
                       placeholder=" "
                       value="${email}"
                       maxlength="100"
                       required>
                <label class="floating-label" for="email">Email *</label>
                <c:if test="${not empty errors.email}">
                    <div class="invalid-feedback d-block">${errors.email}</div>
                </c:if>
            </div>

            <%-- Phone Number --%>
            <div class="floating-group">
                <input type="tel"
                       class="floating-input ${not empty errors.phone ? 'is-invalid' : ''}"
                       id="phone"
                       name="phone"
                       placeholder=" "
                       value="${phone}"
                       maxlength="10"
                       required>
                <label class="floating-label" for="phone">Số điện thoại *</label>
                <c:if test="${not empty errors.phone}">
                    <div class="invalid-feedback d-block">${errors.phone}</div>
                </c:if>
            </div>

            <%-- Password --%>
            <div class="floating-group">
                <input type="password"
                       class="floating-input has-toggle ${not empty errors.password ? 'is-invalid' : ''}"
                       id="password"
                       name="password"
                       placeholder=" "
                       minlength="6"
                       required>
                <label class="floating-label" for="password">Mật khẩu *</label>
                <button class="floating-toggle toggle-password" type="button"
                        data-target="password" tabindex="-1"
                        aria-label="Hiển thị mật khẩu">
                    <i class="bi bi-eye"></i>
                </button>
                <c:if test="${not empty errors.password}">
                    <div class="invalid-feedback d-block">${errors.password}</div>
                </c:if>
                <c:if test="${empty errors.password}">
                    <div class="form-text" style="font-size:0.7rem; color: #6c757d; margin-top:0.25rem;">
                        Ít nhất 6 ký tự, có chữ + số + ký tự đặc biệt
                    </div>
                </c:if>
            </div>

            <%-- Confirm Password --%>
            <div class="floating-group">
                <input type="password"
                       class="floating-input has-toggle ${not empty errors.confirmPassword ? 'is-invalid' : ''}"
                       id="confirmPassword"
                       name="confirmPassword"
                       placeholder=" "
                       minlength="6"
                       required>
                <label class="floating-label" for="confirmPassword">Xác nhận mật khẩu *</label>
                <button class="floating-toggle toggle-password" type="button"
                        data-target="confirmPassword" tabindex="-1"
                        aria-label="Hiển thị mật khẩu">
                    <i class="bi bi-eye"></i>
                </button>
                <c:if test="${not empty errors.confirmPassword}">
                    <div class="invalid-feedback d-block">${errors.confirmPassword}</div>
                </c:if>
            </div>

            <%-- Terms and Conditions Checkbox --%>
            <div class="register-terms">
                <input type="checkbox" id="terms" name="terms" required
                       <c:if test="${not empty terms}">checked</c:if>>
                <label for="terms">
                    Tôi đồng ý với
                    <a href="#" tabindex="-1">Điều khoản sử dụng</a>
                    và
                    <a href="#" tabindex="-1">Chính sách bảo mật</a>
                </label>
            </div>
            <c:if test="${not empty errors.terms}">
                <div class="invalid-feedback d-block" style="margin-top:-0.25rem;margin-bottom:0.5rem;">${errors.terms}</div>
            </c:if>

            <%-- Submit Button --%>
            <div class="mt-4">
                <button type="submit" class="btn-auth-submit">
                    Đăng Ký
                    <i class="bi bi-arrow-right"></i>
                </button>
            </div>
        </form>

        <%-- Login Link --%>
        <div class="text-center small text-muted mt-4">
            Đã có tài khoản? 
            <a href="${pageContext.request.contextPath}/login" style="color: var(--brand-pink-600); font-weight: 700; text-decoration: none;">Đăng nhập ngay</a>
        </div>
    </div>
</div>

<script>
// ============================================================
// Client-side Validation — đồng bộ với server ValidationUtil
// ============================================================

var VALIDATION = {
    EMAIL_REGEX: /^[-A-Za-z0-9+_.]+@[-A-Za-z0-9.]+\.[A-Za-z]{2,}$/,
    // SĐT Việt Nam: bắt đầu 03|05|07|08|09, chính xác 10 chữ số
    PHONE_REGEX: /^(0[3|5|7|8|9])[0-9]{8}$/,
    MIN_PASSWORD_LENGTH: 6,
    MIN_NAME_LENGTH: 2,
    MAX_NAME_LENGTH: 100,
    // Mật khẩu: ít nhất 1 chữ cái, 1 chữ số, 1 ký tự đặc biệt
    HAS_LETTER: /[A-Za-z]/,
    HAS_DIGIT: /\d/,
    HAS_SPECIAL: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?`~]/
};

function validateRegisterForm() {
    var fullName = document.getElementById('fullName').value.trim();
    var email = document.getElementById('email').value.trim();
    var phone = document.getElementById('phone').value.trim();
    var password = document.getElementById('password').value;
    var confirmPassword = document.getElementById('confirmPassword').value;
    var terms = document.getElementById('terms');

    clearAllErrors();

    var isValid = true;

    // ----- Họ tên -----
    if (fullName === '') {
        showFieldError('fullName', 'Họ tên không được để trống.');
        isValid = false;
    } else if (fullName.length < VALIDATION.MIN_NAME_LENGTH) {
        showFieldError('fullName', 'Họ tên phải có ít nhất ' + VALIDATION.MIN_NAME_LENGTH + ' ký tự.');
        isValid = false;
    } else if (fullName.length > VALIDATION.MAX_NAME_LENGTH) {
        showFieldError('fullName', 'Họ tên không được vượt quá ' + VALIDATION.MAX_NAME_LENGTH + ' ký tự.');
        isValid = false;
    }

    // ----- Email -----
    if (email === '') {
        showFieldError('email', 'Email không được để trống.');
        isValid = false;
    } else if (!VALIDATION.EMAIL_REGEX.test(email)) {
        showFieldError('email', 'Email không đúng định dạng (VD: ten@domain.com).');
        isValid = false;
    }

    // ----- SĐT -----
    if (phone === '') {
        showFieldError('phone', 'Số điện thoại không được để trống.');
        isValid = false;
    } else if (!VALIDATION.PHONE_REGEX.test(phone)) {
        showFieldError('phone', 'Số điện thoại phải đúng 10 chữ số, bắt đầu bằng 03, 05, 07, 08 hoặc 09.');
        isValid = false;
    }

    // ----- Mật khẩu -----
    if (password === '') {
        showFieldError('password', 'Mật khẩu không được để trống.');
        isValid = false;
    } else if (password.length < VALIDATION.MIN_PASSWORD_LENGTH) {
        showFieldError('password', 'Mật khẩu phải có ít nhất ' + VALIDATION.MIN_PASSWORD_LENGTH + ' ký tự.');
        isValid = false;
    } else if (!VALIDATION.HAS_LETTER.test(password)) {
        showFieldError('password', 'Mật khẩu phải chứa ít nhất 1 chữ cái.');
        isValid = false;
    } else if (!VALIDATION.HAS_DIGIT.test(password)) {
        showFieldError('password', 'Mật khẩu phải chứa ít nhất 1 chữ số.');
        isValid = false;
    } else if (!VALIDATION.HAS_SPECIAL.test(password)) {
        showFieldError('password', 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt (VD: !@#$%).');
        isValid = false;
    }

    // ----- Xác nhận mật khẩu -----
    if (confirmPassword === '') {
        showFieldError('confirmPassword', 'Xác nhận mật khẩu không được để trống.');
        isValid = false;
    } else if (confirmPassword !== password) {
        showFieldError('confirmPassword', 'Xác nhận mật khẩu không khớp với mật khẩu.');
        isValid = false;
    }

    // ----- Terms & Conditions -----
    if (terms && !terms.checked) {
        showTermsError('Bạn phải đồng ý với Điều khoản sử dụng và Chính sách bảo mật.');
        isValid = false;
    }

    return isValid;
}

/**
 * Hiển thị lỗi cho một trường cụ thể.
 */
function showFieldError(fieldId, message) {
    var field = document.getElementById(fieldId);
    if (!field) return;

    field.classList.add('is-invalid');

    var container = field.closest('.register-input-group');
    if (!container) {
        container = field.parentElement;
    }

    // Tìm hoặc tạo feedback element
    var existing = container.parentElement.querySelector('.invalid-feedback');
    if (existing) {
        existing.textContent = message;
        existing.classList.add('d-block');
        return;
    }

    var feedback = document.createElement('div');
    feedback.className = 'invalid-feedback d-block';
    feedback.textContent = message;
    container.parentElement.appendChild(feedback);
}

/**
 * Hiển thị lỗi cho checkbox terms.
 */
function showTermsError(message) {
    var termsRow = document.querySelector('.register-terms');
    if (!termsRow) return;

    var existing = termsRow.parentElement.querySelector('.terms-error');
    if (existing) {
        existing.textContent = message;
        return;
    }

    var error = document.createElement('div');
    error.className = 'invalid-feedback d-block terms-error';
    error.textContent = message;
    error.style.marginTop = '-0.25rem';
    error.style.marginBottom = '0.5rem';
    termsRow.parentElement.insertBefore(error, termsRow.nextSibling);
}

/**
 * Xóa tất cả lỗi hiện có.
 */
function clearAllErrors() {
    document.querySelectorAll('.form-control.is-invalid').forEach(function(el) {
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
    document.querySelectorAll('.toggle-password').forEach(function(btn) {
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
