<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Nhập — CAMS</title>
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
    <style>
        :root {
            --cams-primary: #6b5a60;
            --cams-tertiary: #a82d68;
            --cams-tertiary-container: #ffe3ea;
            --cams-on-tertiary-container: #b63873;
            --cams-primary-container: #fce4ec;
            --cams-secondary-container: #d4e6e5;
            --cams-secondary-fixed: #d4e6e5;
            --cams-tertiary-fixed: #ffd9e4;
            --cams-surface-bright: #f8f9fa;
            --cams-surface-container-lowest: #ffffff;
            --cams-outline-variant: #d0c3c7;
            --cams-on-surface-variant: #4d4447;
            --cams-on-background: #191c1d;
            --cams-outline: #7f7478;
            --cams-on-primary-container: #76646b;
        }

        /* ========== Login Page — Full Viewport Layout ========== */
        body.login-page {
            background-color: var(--cams-primary-container);
            font-family: 'Be Vietnam Pro', 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100dvh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.5rem;
            margin: 0;
            position: relative;
            overflow: hidden;

            /* Dotted pattern background */
            background-image: radial-gradient(var(--cams-secondary-container) 1px, transparent 1px);
            background-size: 20px 20px;
        }

        /* ========== Decorative Blur Blobs ========== */
        .login-blob {
            position: absolute;
            border-radius: 50%;
            pointer-events: none;
            filter: blur(64px);
            z-index: 0;
        }

        .login-blob--top {
            top: -10%;
            left: -10%;
            width: 40vw;
            height: 40vw;
            background: var(--cams-surface-container-lowest);
            opacity: 0.40;
        }

        .login-blob--bottom {
            bottom: -10%;
            right: -10%;
            width: 50vw;
            height: 50vw;
            background: var(--cams-tertiary-fixed);
            opacity: 0.30;
        }

        /* ========== Glassmorphism Card ========== */
        .login-card-wrapper {
            position: relative;
            z-index: 10;
            width: 100%;
            max-width: 28rem; /* 448px, như max-w-md */
        }

        .login-card {
            background: rgba(248, 249, 250, 0.80); /* surface/80 */
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.40);
            overflow: hidden;
            padding: 2rem;
            animation: fadeInUp 0.6s ease-out forwards;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* ========== Header ========== */
        .login-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .login-icon-circle {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: var(--cams-tertiary-container);
            color: var(--cams-tertiary);
            margin-bottom: 1rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
            border: 1px solid rgba(255,255,255,0.50);
        }

        .login-icon-circle i {
            font-size: 2.25rem;
        }

        .login-header h1 {
            font-family: 'Inter', 'Be Vietnam Pro', sans-serif;
            font-size: 1.5rem;
            font-weight: 600;
            line-height: 2rem;
            color: var(--cams-primary);
            margin-bottom: 0.25rem;
        }

        .login-header p {
            font-size: 0.875rem;
            color: var(--cams-on-surface-variant);
            margin: 0;
        }

        /* ========== Alert Messages ========== */
        .login-alert {
            border: none;
            border-radius: 8px;
            padding: 0.75rem 1rem;
            margin-bottom: 1.25rem;
            font-size: 0.85rem;
            display: flex;
            align-items: flex-start;
            gap: 0.5rem;
        }

        .login-alert i {
            font-size: 1.1rem;
            flex-shrink: 0;
            margin-top: 0.1rem;
        }

        .login-alert-success {
            background: #f0fdf4;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .login-alert-danger {
            background: #fff5f5;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        /* ========== Floating Label Input ========== */
        .floating-group {
            position: relative;
            margin-bottom: 0.75rem;
        }

        .floating-input {
            width: 100%;
            background: var(--cams-surface-bright);
            color: var(--cams-on-background);
            font-size: 1rem;
            line-height: 1.5rem;
            border: 1px solid var(--cams-outline-variant);
            border-radius: 8px;
            padding: 0.75rem 1rem;
            transition: border-color 0.2s, box-shadow 0.2s;
            outline: none;
            box-sizing: border-box;
        }

        .floating-input.has-toggle {
            padding-right: 2.5rem;
        }

        .floating-input:focus {
            border-color: var(--cams-tertiary);
            box-shadow: 0 0 0 0.15rem rgba(168, 45, 104, 0.12);
        }

        .floating-input.is-invalid {
            border-color: #dc3545;
            box-shadow: 0 0 0 0.15rem rgba(220, 53, 69, 0.12);
        }

        .floating-input::placeholder {
            color: transparent;
        }

        .floating-label {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            font-size: 1rem;
            color: var(--cams-on-surface-variant);
            transition: all 0.2s ease;
            pointer-events: none;
            transform-origin: left center;
            background: transparent;
            padding: 0;
        }

        /* Float label up when input is focused or filled */
        .floating-input:focus ~ .floating-label,
        .floating-input:not(:placeholder-shown) ~ .floating-label {
            transform: translateY(-1.65rem) scale(0.85);
            background: var(--cams-surface-bright);
            padding: 0 4px;
            color: var(--cams-tertiary);
            top: 0;
        }

        .floating-input.is-invalid:focus ~ .floating-label,
        .floating-input.is-invalid:not(:placeholder-shown) ~ .floating-label {
            color: #dc3545;
        }

        /* Toggle password button */
        .floating-toggle {
            position: absolute;
            right: 0.5rem;
            top: 50%;
            transform: translateY(-50%);
            background: transparent;
            border: none;
            color: var(--cams-on-surface-variant);
            cursor: pointer;
            padding: 0.25rem 0.5rem;
            display: flex;
            align-items: center;
            transition: color 0.15s;
            z-index: 5;
        }

        .floating-toggle:hover {
            color: var(--cams-primary);
        }

        .floating-toggle:focus {
            outline: none;
            color: var(--cams-tertiary);
        }

        .floating-toggle i {
            font-size: 1.25rem;
        }

        /* Invalid feedback for floating inputs */
        .floating-group .invalid-feedback {
            font-size: 0.75rem;
            margin-top: 0.25rem;
            margin-left: 0.25rem;
        }

        /* ========== Forgot Password Link ========== */
        .login-forgot {
            display: flex;
            justify-content: flex-end;
            margin-top: -0.25rem;
            margin-bottom: 0.25rem;
        }

        .login-forgot a {
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: var(--cams-tertiary);
            text-decoration: none;
            transition: color 0.15s;
        }

        .login-forgot a:hover {
            color: var(--cams-on-tertiary-container);
        }

        /* ========== Submit Button ========== */
        .btn-login {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1rem;
            border: none;
            border-radius: 16px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
            font-size: 1rem;
            font-weight: 600;
            color: var(--cams-on-tertiary-container);
            background-color: var(--cams-tertiary-container);
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .btn-login:hover {
            background-color: var(--cams-tertiary);
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.10);
        }

        .btn-login:focus {
            outline: none;
            box-shadow: 0 0 0 0.25rem rgba(168, 45, 104, 0.25);
        }

        .btn-login:active {
            transform: scale(0.98);
        }

        .btn-login i {
            font-size: 1.25rem;
        }

        /* ========== Divider "hoặc" ========== */
        .login-divider {
            display: flex;
            align-items: center;
            margin: 1.5rem 0;
        }

        .login-divider::before,
        .login-divider::after {
            content: '';
            flex: 1;
            border-top: 1px solid rgba(208, 195, 199, 0.50); /* outline-variant/50 */
        }

        .login-divider span {
            padding: 0 0.75rem;
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: var(--cams-on-surface-variant);
            white-space: nowrap;
        }

        /* ========== Social Login Buttons ========== */
        .social-buttons {
            display: flex;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .btn-social {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            background: #fff;
            border: 1px solid rgba(208, 195, 199, 0.50);
            border-radius: 8px;
            padding: 0.625rem 1rem;
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--cams-on-background);
            cursor: pointer;
            transition: all 0.15s;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }

        .btn-social:hover {
            background: #f3f4f5;
        }

        .btn-social:active {
            transform: scale(0.95);
        }

        .btn-social img {
            width: 1.25rem;
            height: 1.25rem;
        }

        /* Google Sign-In container */
        #googleSignInButton {
            display: flex;
            justify-content: center;
        }

        #googleSignInButton > div {
            width: 100%;
        }

        /* ========== Register Link ========== */
        .login-register-link {
            text-align: center;
            margin-top: 0.5rem;
            font-size: 0.875rem;
            color: var(--cams-on-surface-variant);
        }

        .login-register-link a {
            color: var(--cams-tertiary);
            font-weight: 600;
            text-decoration: none;
            transition: color 0.15s, text-decoration 0.15s;
            text-underline-offset: 4px;
        }

        .login-register-link a:hover {
            text-decoration: underline;
            color: var(--cams-on-tertiary-container);
        }

        /* ========== Security Badge ========== */
        .login-security-badge {
            margin-top: 1.5rem;
            text-align: center;
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.05em;
            color: var(--cams-on-primary-container);
            opacity: 0.80;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.25rem;
        }

        .login-security-badge i {
            font-size: 1rem;
        }

        /* ========== Error State for Floating Labels ========== */
        .floating-input.is-invalid:not(:placeholder-shown) ~ .floating-label {
            color: #dc3545;
        }

        /* ========== Responsive ========== */
        @media (max-width: 575.98px) {
            body.login-page {
                padding: 1rem;
                align-items: flex-start;
                padding-top: 2rem;
            }

            .login-card {
                padding: 1.5rem;
                border-radius: 10px;
            }

            .login-blob--top {
                width: 60vw;
                height: 60vw;
                top: -20%;
                left: -20%;
            }

            .login-blob--bottom {
                width: 70vw;
                height: 70vw;
                bottom: -20%;
                right: -20%;
            }
        }

        @media (max-height: 700px) {
            body.login-page {
                align-items: flex-start;
                padding-top: 1rem;
                overflow-y: auto;
            }
        }
    </style>
</head>
<body class="login-page">

<%-- ========== Decorative Blur Blobs ========== --%>
<div class="login-blob login-blob--top"></div>
<div class="login-blob login-blob--bottom"></div>

<%-- ========== Main Card ========== --%>
<main class="login-card-wrapper">
    <div class="login-card">

        <%-- Header --%>
        <div class="login-header">
            <div class="login-icon-circle">
                <i class="bi bi-heart-pulse"></i>
            </div>
            <h1>Chào Mừng Trở Lại</h1>
            <p>Đăng nhập vào hệ thống phòng khám sản phụ khoa.</p>
        </div>

        <%-- ========== Success Message ========== --%>
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="login-alert login-alert-success" role="alert">
                <i class="bi bi-check-circle-fill"></i>
                <div>${sessionScope.successMessage}</div>
            </div>
            <c:remove var="successMessage" scope="session" />
        </c:if>

        <%-- ========== Error Messages ========== --%>
        <c:if test="${not empty errorMessage}">
            <div class="login-alert login-alert-danger" role="alert">
                <i class="bi bi-exclamation-triangle-fill"></i>
                <div>${errorMessage}</div>
            </div>
        </c:if>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="login-alert login-alert-danger" role="alert">
                <i class="bi bi-exclamation-triangle-fill"></i>
                <div>${sessionScope.errorMessage}</div>
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <%-- ========== Login Form ========== --%>
        <form action="${pageContext.request.contextPath}/login" method="post" novalidate>

            <%-- Email --%>
            <div class="floating-group">
                <input type="email"
                       class="floating-input ${not empty emailError ? 'is-invalid' : ''}"
                       id="email"
                       name="email"
                       placeholder=" "
                       value="${not empty emailValue ? emailValue : ''}"
                       required
                       autofocus>
                <label class="floating-label" for="email">Email</label>
                <c:if test="${not empty emailError}">
                    <div class="invalid-feedback d-block">${emailError}</div>
                </c:if>
            </div>

            <%-- Password --%>
            <div class="floating-group">
                <input type="password"
                       class="floating-input has-toggle ${not empty passwordError ? 'is-invalid' : ''}"
                       id="password"
                       name="password"
                       placeholder=" "
                       required>
                <label class="floating-label" for="password">Mật khẩu</label>
                <button type="button"
                        class="floating-toggle"
                        data-target="password"
                        tabindex="-1"
                        aria-label="Hiển thị mật khẩu">
                    <i class="bi bi-eye"></i>
                </button>
                <c:if test="${not empty passwordError}">
                    <div class="invalid-feedback d-block">${passwordError}</div>
                </c:if>
            </div>

            <%-- Forgot Password --%>
            <div class="login-forgot">
                <a href="${pageContext.request.contextPath}/forgot-password">
                    <i class="bi bi-question-circle me-1"></i>Quên mật khẩu?
                </a>
            </div>

            <%-- Submit Button --%>
            <button type="submit" class="btn-login">
                <span>Đăng Nhập</span>
                <i class="bi bi-arrow-right"></i>
            </button>
        </form>

        <%-- ========== Divider ========== --%>
        <div class="login-divider">
            <span>hoặc tiếp tục với</span>
        </div>

        <%-- ========== Google Sign-In Button ========== --%>
        <div class="d-grid">
            <div id="googleSignInButton" class="d-flex justify-content-center"></div>
            <div id="googleLoginError" class="text-danger small mt-2 text-center d-none">
                <i class="bi bi-exclamation-circle me-1"></i>
                <span id="googleLoginErrorMessage"></span>
            </div>
        </div>

        <%-- ========== Register Link ========== --%>
        <div class="login-register-link">
            Chưa có tài khoản?
            <a href="${pageContext.request.contextPath}/register">Đăng ký</a>
        </div>
    </div>

    <%-- ========== Security Badge ========== --%>
    <div class="login-security-badge">
        <i class="bi bi-lock-fill"></i>
        Kết nối được mã hóa an toàn
    </div>
</main>

<%-- ========== Inline Scripts ========== --%>
<script>
// ============================================================
// Toggle password visibility
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

<%-- ========== Google Sign-In Configuration ========== --%>
<%--
  Client ID được load từ application scope (set bởi GoogleConfigListener từ web.xml).
  Mỗi developer/máy chủ cấu hình Client ID riêng trong web.xml.
--%>
<c:set var="googleClientId" value="${applicationScope.googleClientId}" />

<%-- ========== Google Identity Services (client-side flow) ========== --%>
<c:if test="${applicationScope.googleConfigured}">
<script src="https://accounts.google.com/gsi/client" async defer></script>

<script>
/**
 * Xử lý callback từ Google Sign-In (client-side GIS flow).
 */
function handleGoogleCredential(response) {
    var credential = response.credential;

    var errorDiv = document.getElementById('googleLoginError');
    errorDiv.classList.add('d-none');

    fetch('${pageContext.request.contextPath}/google-login', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        },
        body: 'credential=' + encodeURIComponent(credential)
    })
    .then(function(res) { return res.json(); })
    .then(function(data) {
        if (data.success) {
            window.location.href = data.redirectUrl;
        } else {
            showGoogleLoginError(data.error || 'Đăng nhập Google thất bại.');
        }
    })
    .catch(function(err) {
        console.error('Google login error:', err);
        showGoogleLoginError('Lỗi kết nối. Vui lòng thử lại.');
    });
}

function showGoogleLoginError(message) {
    var errorDiv = document.getElementById('googleLoginError');
    var errorMsg = document.getElementById('googleLoginErrorMessage');
    errorMsg.textContent = message;
    errorDiv.classList.remove('d-none');
}

/**
 * Khởi tạo Google Identity Services với Client ID động.
 * Origin hiện tại được Google tự động kiểm tra.
 */
window.addEventListener('load', function() {
    var clientId = '${applicationScope.googleClientId}';

    if (clientId && clientId.indexOf('YOUR_GOOGLE_CLIENT_ID') === -1) {
        try {
            google.accounts.id.initialize({
                client_id: clientId,
                callback: handleGoogleCredential,
                auto_select: false,
                cancel_on_tap_outside: true
            });

            google.accounts.id.renderButton(
                document.getElementById('googleSignInButton'),
                {
                    type: 'standard',
                    theme: 'outline',
                    size: 'large',
                    text: 'signin_with',
                    shape: 'rectangular',
                    logo_alignment: 'left',
                    width: 320
                }
            );

            console.log('Google Sign-In initialized. Origin: ' + window.location.origin);
            console.log('Neu Google Sign-In khong hoat dong, hay them origin nay vao Google Cloud Console:');
            console.log('  Authorized JavaScript origins: ' + window.location.origin);
        } catch (e) {
            console.warn('Google Sign-In init failed:', e.message);
            showGoogleSetupGuide();
        }
    } else {
        showGoogleSetupGuide();
    }
});

/**
 * Hiển thị hướng dẫn cấu hình Google Cloud Console.
 */
function showGoogleSetupGuide() {
    var btnContainer = document.getElementById('googleSignInButton');
    var origin = window.location.origin;
    var ctxPath = '${pageContext.request.contextPath}';

    btnContainer.innerHTML =
        '<div class="alert alert-info text-start small mb-0 w-100" style="border-radius:8px;">' +
        '<strong><i class="bi bi-info-circle me-1"></i>Huong dan cau hinh Google Sign-In:</strong><br>' +
        '1. Vao <a href="https://console.cloud.google.com/" target="_blank">Google Cloud Console</a><br>' +
        '2. Tao OAuth 2.0 Client ID (Web application)<br>' +
        '3. Them <strong>Authorized JavaScript origins</strong>:<br>' +
        '   <code class="text-dark">' + origin + '</code><br>' +
        '4. Them <strong>Authorized redirect URIs</strong>:<br>' +
        '   <code class="text-dark">' + origin + ctxPath + '/google-login-server</code><br>' +
        '5. Copy Client ID vao <code class="text-dark">web.xml</code> → <code class="text-dark">google.client.id</code><br>' +
        '<small class="text-muted">(Sau do restart lai server)</small>' +
        '</div>';
}
</script>
</c:if>

<%-- ========== Server-Side Google Login Link (fallback) ========== --%>

<%-- ========== Chưa cấu hình Google ========== --%>
<c:if test="${not applicationScope.googleConfigured}">
<div id="googleNotConfigured" class="alert alert-light border text-muted text-center small mb-0" style="position:relative;z-index:10;border-radius:8px;">
    <i class="bi bi-google me-1"></i>
    Google Sign-In chưa được cấu hình.<br>
    <small>Thêm <code>google.client.id</code> vào <code>web.xml</code> để kích hoạt.</small>
</div>
</c:if>

<!-- Bootstrap 5 JS Bundle CDN -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous">
</script>
</body>
</html>
