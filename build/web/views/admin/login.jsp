<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel — CAMS</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <!-- Bootstrap Icons CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
          rel="stylesheet">
    <!-- Google Fonts: Admin UI (Plus Jakarta Sans + DM Sans) + Be Vietnam Pro fallback -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap"
          rel="stylesheet">
    <!-- Admin CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        /* Login form specific — CAMS patient-style floating labels */
        .admin-login-input-group {
            position: relative;
            margin-bottom: 0.75rem;
        }
        .admin-login-input-group .input-group {
            border-radius: 8px;
            overflow: hidden;
        }
        .admin-login-input-group .input-group-text {
            background: var(--cams-surface-bright);
            border: 1px solid var(--cams-outline-variant);
            border-right: none;
            color: var(--cams-on-surface-variant);
            padding: 0.75rem 0.85rem;
        }
        .admin-login-input-group .form-control {
            border: 1px solid var(--cams-outline-variant);
            border-left: none;
            padding: 0.75rem 0.75rem;
            font-size: 1rem;
            background: var(--cams-surface-bright);
            color: var(--cams-on-background);
        }
        .admin-login-input-group .form-control:focus {
            border-color: var(--cams-tertiary);
            box-shadow: 0 0 0 0.15rem rgba(168, 45, 104, 0.12);
        }
        .admin-login-input-group .form-control.is-invalid {
            border-color: #dc3545;
        }
        .admin-login-input-group .form-control.is-invalid:focus {
            box-shadow: 0 0 0 0.15rem rgba(220, 53, 69, 0.12);
        }
        .admin-password-wrap {
            position: relative;
            flex: 1;
        }
        .admin-password-wrap .form-control {
            width: 100%;
            border-radius: 0 8px 8px 0;
            padding-right: 2.5rem;
        }
        .admin-password-toggle {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            background: transparent;
            border: none;
            color: var(--cams-on-surface-variant);
            cursor: pointer;
            padding: 4px 8px;
            z-index: 5;
            display: flex;
            align-items: center;
            transition: color 0.15s;
        }
        .admin-password-toggle:hover {
            color: var(--cams-primary);
        }

        /* Alert styling */
        .admin-alert-danger {
            background: #fff5f5;
            color: #991b1b;
            border: 1px solid #fecaca;
            border-radius: 8px;
            padding: 0.75rem 1rem;
            font-size: 0.85rem;
            display: flex;
            align-items: flex-start;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body class="admin-login-page">

<%-- ========== Decorative Blur Blobs (giống patient login) ========== --%>
<div class="admin-login-blob admin-login-blob--top"></div>
<div class="admin-login-blob admin-login-blob--bottom"></div>

<%-- ========== Main Card ========== --%>
<main class="admin-login-wrapper">
    <div class="admin-login-card">

        <%-- Header --%>
        <div class="admin-login-header">
            <div class="admin-login-icon">
                <i class="bi bi-shield-lock-fill"></i>
            </div>
            <h1>Admin Panel</h1>
            <p>Đăng nhập vào hệ thống quản trị phòng khám</p>
        </div>

        <%-- ========== Error Message ========== --%>
        <c:if test="${not empty errorMessage}">
            <div class="admin-alert-danger" role="alert">
                <i class="bi bi-exclamation-triangle-fill flex-shrink-0" style="margin-top:1px;"></i>
                <span>${errorMessage}</span>
            </div>
        </c:if>

        <%-- ========== Session Error ========== --%>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="admin-alert-danger" role="alert">
                <i class="bi bi-exclamation-triangle-fill flex-shrink-0" style="margin-top:1px;"></i>
                <span>${sessionScope.errorMessage}</span>
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <%-- ========== Login Form ========== --%>
        <form action="${pageContext.request.contextPath}/admin/login" method="post" novalidate>

            <%-- Email --%>
            <div class="admin-login-input-group">
                <div class="input-group">
                    <span class="input-group-text">
                        <i class="bi bi-envelope"></i>
                    </span>
                    <input type="email"
                           class="form-control ${not empty emailError ? 'is-invalid' : ''}"
                           id="email"
                           name="email"
                           placeholder="Email"
                           value="${not empty emailValue ? emailValue : ''}"
                           required
                           autofocus>
                </div>
                <c:if test="${not empty emailError}">
                    <div class="invalid-feedback d-block ms-1 mt-1" style="font-size:0.75rem;">${emailError}</div>
                </c:if>
            </div>

            <%-- Password --%>
            <div class="admin-login-input-group">
                <div class="input-group">
                    <span class="input-group-text">
                        <i class="bi bi-lock-fill"></i>
                    </span>
                    <div class="admin-password-wrap">
                        <input type="password"
                               class="form-control ${not empty passwordError ? 'is-invalid' : ''}"
                               id="password"
                               name="password"
                               placeholder="Mật khẩu"
                               required>
                        <button type="button"
                                class="admin-password-toggle"
                                data-target="password"
                                tabindex="-1"
                                aria-label="Hiển thị mật khẩu">
                            <i class="bi bi-eye"></i>
                        </button>
                    </div>
                </div>
                <c:if test="${not empty passwordError}">
                    <div class="invalid-feedback d-block ms-1 mt-1" style="font-size:0.75rem;">${passwordError}</div>
                </c:if>
            </div>

            <%-- Submit Button --%>
            <button type="submit" class="btn-admin-login mt-2">
                <span>Đăng Nhập</span>
                <i class="bi bi-arrow-right"></i>
            </button>
        </form>

        <%-- Back Link --%>
        <div class="admin-login-back">
            <i class="bi bi-arrow-left me-1"></i>
            <a href="${pageContext.request.contextPath}/login">Quay lại trang đăng nhập</a>
        </div>
    </div>

    <%-- Security Badge --%>
    <div class="admin-login-security">
        <i class="bi bi-lock-fill"></i>
        Kết nối được mã hóa an toàn
    </div>
</main>

<%-- ========== Scripts ========== --%>
<script>
// ============================================================
// Toggle password visibility
// ============================================================
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.admin-password-toggle').forEach(function(btn) {
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
