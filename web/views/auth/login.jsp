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
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css?v=101" rel="stylesheet">
</head>
<body class="login-page">

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
                Chào mừng bạn đến với CAMS — Cổng thông tin chăm sóc thai kỳ thông minh và quản lý lịch hẹn sản phụ khoa trực tuyến.
            </p>
            
            <!-- Checklist Card Mockup -->
            <div class="auth-mockup-panel text-start">
                <div class="auth-mockup-header"><i class="bi bi-shield-check me-1"></i> Giá trị lâm sàng nổi bật</div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Theo dõi sát sao từng mốc siêu âm thai kỳ</span>
                </div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Thông báo khẩn cấp định vị SOS tức thì</span>
                </div>
                <div class="auth-mockup-row">
                    <i class="bi bi-check-circle-fill"></i>
                    <span class="auth-mockup-text">Hồ sơ thai sản, kết quả siêu âm số hóa</span>
                </div>
            </div>
        </div>
    </div>

    <%-- ==================== RIGHT: Form Panel ==================== --%>
    <div class="auth-split-right">
        <div class="auth-form-card">
            
            <div class="auth-form-header">
                <h2>Đăng Nhập Hệ Thống</h2>
                <p>Đăng nhập vào hệ thống để bắt đầu theo dõi sức khỏe thai kỳ.</p>
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
            <c:if test="${not empty sessionScope.sessionExpiredMessage}">
                <div class="login-alert login-alert-warning" role="alert">
                    <i class="bi bi-clock-history"></i>
                    <div>${sessionScope.sessionExpiredMessage}</div>
                </div>
                <c:remove var="sessionExpiredMessage" scope="session" />
            </c:if>

            <%-- ========== Login Form ========== --%>
            <form action="${pageContext.request.contextPath}/login" method="post" novalidate>

                <%-- Email hoặc tên đăng nhập --%>
                <div class="floating-group">
                    <input type="text"
                           class="floating-input ${not empty emailError ? 'is-invalid' : ''}"
                           id="email"
                           name="email"
                           placeholder=" "
                           value="${not empty emailValue ? emailValue : ''}"
                           required
                           autofocus>
                    <label class="floating-label" for="email">Email hoặc tên đăng nhập</label>
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
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input" id="rememberMe" name="rememberMe">
                        <label class="form-check-label small text-muted" for="rememberMe">Ghi nhớ đăng nhập</label>
                    </div>
                    <a href="${pageContext.request.contextPath}/forgot-password" class="small text-decoration-none" style="color: var(--brand-pink-600); font-weight: 600;">
                        Quên mật khẩu?
                    </a>
                </div>

                <%-- Submit Button --%>
                <button type="submit" class="btn-auth-submit mb-4">
                    <span>Đăng Nhập</span>
                    <i class="bi bi-arrow-right"></i>
                </button>
            </form>

            <%-- ========== Divider ========== --%>
            <div class="divider-with-text mb-4">
                <span class="divider-text text-muted small">HOẶC ĐĂNG NHẬP VỚI</span>
            </div>

            <%-- ========== Google Sign-In Button ========== --%>
            <div class="d-grid mb-4">
                <div id="googleSignInButton" class="d-flex justify-content-center"></div>
                <div id="googleLoginError" class="text-danger small mt-2 text-center d-none">
                    <i class="bi bi-exclamation-circle me-1"></i>
                    <span id="googleLoginErrorMessage"></span>
                </div>
            </div>

            <%-- ========== Register Link ========== --%>
            <div class="text-center small text-muted">
                Chưa có tài khoản? 
                <a href="${pageContext.request.contextPath}/register" style="color: var(--brand-pink-600); font-weight: 700; text-decoration: none;">Đăng ký ngay</a>
            </div>
            
        </div>
    </div>
</div>

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
