<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="../common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-md-7 col-lg-5">
        <div class="card p-4 p-md-5 login-card">
            <%-- Logo & Heading --%>
            <div class="text-center mb-4">
                <div class="login-icon-wrapper mb-3">
                    <i class="bi bi-lock-fill text-success" style="font-size: 3rem;"></i>
                </div>
                <h2 class="fw-bold mb-1">Đặt Lại Mật Khẩu</h2>
                <p class="text-muted">Nhập mật khẩu mới cho tài khoản của bạn</p>
            </div>

            <%-- Hiển thị lỗi từ server --%>
            <c:if test="${not empty errors}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <strong>Vui lòng sửa các lỗi sau:</strong>
                    <ul class="mb-0 mt-2">
                        <c:forEach items="${errors}" var="error">
                            <li>${error.value}</li>
                        </c:forEach>
                    </ul>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
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
                <div class="mb-3">
                    <label for="newPassword" class="form-label fw-semibold">
                        <i class="bi bi-lock me-1"></i>Mật khẩu mới <span class="text-danger">*</span>
                    </label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                        <input type="password"
                               class="form-control ${not empty errors.newPassword ? 'is-invalid' : ''}"
                               id="newPassword"
                               name="newPassword"
                               placeholder="Ít nhất 6 ký tự, có chữ, số & ký tự đặc biệt"
                               minlength="6"
                               required>
                        <button class="btn btn-outline-secondary toggle-password" type="button"
                                data-target="newPassword" tabindex="-1">
                            <i class="bi bi-eye"></i>
                        </button>
                        <c:if test="${not empty errors.newPassword}">
                            <div class="invalid-feedback d-block">${errors.newPassword}</div>
                        </c:if>
                    </div>
                    <div class="form-text mt-2">
                        <small class="text-muted">
                            <i class="bi bi-info-circle me-1"></i>
                            Mật khẩu phải có: chữ cái + chữ số + ký tự đặc biệt (!@#$%...)
                        </small>
                    </div>
                </div>

                <%-- Xác nhận mật khẩu mới --%>
                <div class="mb-4">
                    <label for="confirmPassword" class="form-label fw-semibold">
                        <i class="bi bi-lock-fill me-1"></i>Xác nhận mật khẩu mới <span class="text-danger">*</span>
                    </label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                        <input type="password"
                               class="form-control ${not empty errors.confirmPassword ? 'is-invalid' : ''}"
                               id="confirmPassword"
                               name="confirmPassword"
                               placeholder="Nhập lại mật khẩu mới"
                               minlength="6"
                               required>
                        <button class="btn btn-outline-secondary toggle-password" type="button"
                                data-target="confirmPassword" tabindex="-1">
                            <i class="bi bi-eye"></i>
                        </button>
                        <c:if test="${not empty errors.confirmPassword}">
                            <div class="invalid-feedback d-block">${errors.confirmPassword}</div>
                        </c:if>
                    </div>
                </div>

                <%-- Nút đặt lại mật khẩu --%>
                <div class="d-grid mb-3">
                    <button type="submit" class="btn btn-success btn-lg shadow-sm">
                        <i class="bi bi-check-circle me-2"></i>Đặt Lại Mật Khẩu
                    </button>
                </div>

                <%-- Link quay lại --%>
                <div class="text-center">
                    <a href="${pageContext.request.contextPath}/login"
                       class="fw-semibold text-decoration-none">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại Đăng Nhập
                    </a>
                </div>
            </form>
        </div>

        <%-- Footer note --%>
        <div class="text-center mt-3">
            <small class="text-muted">
                <i class="bi bi-shield-check me-1"></i>
                Mật khẩu của bạn sẽ được mã hóa và bảo mật
            </small>
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

    return isValid;
}

function showFieldError(fieldId, message) {
    var field = document.getElementById(fieldId);
    if (!field) return;

    field.classList.add('is-invalid');

    var inputGroup = field.closest('.input-group');
    var feedback = inputGroup ? inputGroup.querySelector('.invalid-feedback') : null;

    if (!feedback) {
        feedback = document.createElement('div');
        feedback.className = 'invalid-feedback d-block';
        if (inputGroup) {
            inputGroup.parentElement.appendChild(feedback);
        } else {
            field.parentElement.appendChild(feedback);
        }
    }
    feedback.textContent = message;
}

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

<%@ include file="../common/footer.jsp" %>
