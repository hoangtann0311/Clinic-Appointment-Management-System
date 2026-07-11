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
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <style>
        :root {
            --cams-primary: #6b5a60;
            --cams-tertiary: #a82d68;
            --cams-tertiary-container: #ffe3ea;
            --cams-on-tertiary-container: #890f50;
            --cams-secondary-container: #d4e6e5;
            --cams-secondary-fixed: #d4e6e5;
            --cams-surface-bright: #f8f9fa;
            --cams-surface-container-lowest: #ffffff;
            --cams-outline-variant: #d0c3c7;
            --cams-on-surface-variant: #4d4447;
            --cams-on-background: #191c1d;
            --cams-outline: #7f7478;
        }

        /* ========== Register Page — Full Viewport Layout ========== */
        body.register-page {
            background-color: var(--cams-surface-bright);
            font-family: 'Be Vietnam Pro', 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100dvh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.5rem;
            margin: 0;
            overflow-y: auto;
        }

        /* ========== Asymmetric Container Card ========== */
        .register-container {
            width: 100%;
            max-width: 1200px;
            min-height: min(800px, calc(100dvh - 3rem));
            background: var(--cams-surface-container-lowest);
            border-radius: 24px;
            box-shadow: 0 8px 40px rgba(0, 0, 0, 0.10);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        @media (min-width: 768px) {
            .register-container {
                flex-direction: row;
                height: auto;
                min-height: 800px;
            }
        }

        /* ========== Left Brand Panel ========== */
        .register-brand {
            display: none;
            position: relative;
            background-color: var(--cams-secondary-container);
            align-items: center;
            justify-content: center;
            overflow: hidden;
            padding: 3rem;
        }

        @media (min-width: 768px) {
            .register-brand {
                display: flex;
                flex: 0 0 41.6667%; /* md:w-5/12 */
            }
        }

        @media (min-width: 992px) {
            .register-brand {
                flex: 0 0 50%; /* lg:w-1/2 */
            }
        }

        /* Gradient overlays */
        .register-brand::before {
            content: '';
            position: absolute;
            inset: 0;
            opacity: 0.40;
            background: radial-gradient(circle at top left, var(--cams-tertiary-container), transparent 50%);
        }

        .register-brand::after {
            content: '';
            position: absolute;
            inset: 0;
            opacity: 0.30;
            background: radial-gradient(circle at bottom right, var(--cams-secondary-fixed), transparent 50%);
        }

        /* Abstract background image overlay */
        .register-brand-bg-img {
            position: absolute;
            inset: 0;
            mix-blend-mode: overlay;
            opacity: 0.20;
            background-size: cover;
            background-position: center;
            background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuDr6qXPAGqfh4XgcyCRl0PDhmkGQrPDIhVJdUNekDG4obYXopeneL34FvF8wv87-VNQW29yymfMrVQYJBb27pyHvHxouT2j067BfQa7deqlWCYGnb_ZdIwGa99B2O9M1PqHY-1nDRVRqSs1xpKr7GcCIHI-kxZs_A-xnp9CaSy-NScNLI4xh3cTfc596U1-q2FNoNwbWMtxFt2m5VBUi3eYettNtj4vQ0aTsdil6mHh48bqCYQgKBOn-AgbO695EIOhrx1iIK1RdJn9');
        }

        /* Brand info card inside left panel */
        .register-brand-card {
            position: relative;
            z-index: 10;
            width: 100%;
            max-width: 24rem;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.20);
            backdrop-filter: blur(6px);
            background: rgba(255, 255, 255, 0.30);
            padding: 2rem;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 1.5rem;
        }

        .register-brand-card .brand-icon {
            font-size: 3.75rem;
            color: var(--cams-primary);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .register-brand-card h2 {
            font-family: 'Inter', 'Be Vietnam Pro', sans-serif;
            font-size: 1.5rem;
            font-weight: 600;
            line-height: 2rem;
            color: var(--cams-primary);
            margin: 0;
        }

        .register-brand-card p {
            font-size: 1rem;
            line-height: 1.5rem;
            color: var(--cams-on-surface-variant);
            margin: 0;
        }

        /* ========== Right Form Panel ========== */
        .register-form-panel {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 2.5rem 1.5rem;
            overflow-y: auto;
        }

        @media (min-width: 576px) {
            .register-form-panel {
                padding: 2.5rem 3rem;
            }
        }

        @media (min-width: 768px) {
            .register-form-panel {
                padding: 2.5rem 3rem;
            }
        }

        @media (min-width: 992px) {
            .register-form-panel {
                padding: 2.5rem 4rem;
            }
        }

        @media (min-width: 1200px) {
            .register-form-panel {
                padding: 2.5rem 6rem;
            }
        }

        /* Mobile brand header (visible only on mobile) */
        .register-mobile-brand {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 2rem;
            justify-content: center;
        }

        @media (min-width: 768px) {
            .register-mobile-brand {
                display: none;
            }
        }

        .register-mobile-brand .brand-icon {
            font-size: 1.875rem;
            color: var(--cams-primary);
        }

        .register-mobile-brand span {
            font-family: 'Inter', 'Be Vietnam Pro', sans-serif;
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--cams-primary);
            letter-spacing: -0.01em;
        }

        /* Heading area */
        .register-heading {
            margin-bottom: 2rem;
        }

        .register-heading h1 {
            font-family: 'Inter', 'Be Vietnam Pro', sans-serif;
            font-size: 2.25rem;
            font-weight: 700;
            line-height: 2.75rem;
            letter-spacing: -0.02em;
            color: var(--cams-on-background);
            margin-bottom: 0.5rem;
        }

        .register-heading p {
            font-size: 1rem;
            line-height: 1.5rem;
            color: var(--cams-on-surface-variant);
            margin: 0;
        }

        /* ========== Form Styling ========== */
        .register-form .form-label {
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: var(--cams-on-surface-variant);
            margin-bottom: 0.25rem;
        }

        .register-form .form-control {
            padding: 0.75rem 1rem 0.75rem 2.75rem;
            border: 1px solid var(--cams-outline-variant);
            border-radius: 8px;
            background: var(--cams-surface-bright);
            font-size: 0.875rem;
            line-height: 1.25rem;
            color: var(--cams-on-background);
            transition: border-color 0.2s, box-shadow 0.2s;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        }

        .register-form .form-control::placeholder {
            color: var(--cams-outline-variant);
        }

        .register-form .form-control:focus {
            outline: none;
            border-color: var(--cams-tertiary);
            box-shadow: 0 0 0 0.2rem rgba(168, 45, 104, 0.15);
        }

        .register-form .form-control.is-invalid {
            border-color: #dc3545;
            box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.15);
        }

        /* Input icon wrapper */
        .register-input-group {
            position: relative;
        }

        .register-input-group .input-icon {
            position: absolute;
            inset-y: 0;
            left: 0;
            padding-left: 0.75rem;
            display: flex;
            align-items: center;
            pointer-events: none;
            color: var(--cams-outline);
            font-size: 1.25rem;
            z-index: 5;
        }

        /* Toggle password button */
        .register-form .toggle-password {
            position: absolute;
            right: 0;
            top: 0;
            bottom: 0;
            background: transparent;
            border: none;
            padding: 0 0.75rem;
            display: flex;
            align-items: center;
            color: var(--cams-outline);
            cursor: pointer;
            z-index: 5;
            transition: color 0.15s;
        }

        .register-form .toggle-password:hover {
            color: var(--cams-on-surface-variant);
        }

        .register-form .toggle-password:focus {
            outline: none;
            color: var(--cams-tertiary);
        }

        /* Form spacing */
        .register-form .field-group {
            margin-bottom: 0.75rem;
        }

        .register-form .field-row {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1rem;
            padding-top: 0.5rem;
        }

        @media (min-width: 576px) {
            .register-form .field-row {
                grid-template-columns: 1fr 1fr;
            }
        }

        /* Terms checkbox */
        .register-terms {
            display: flex;
            align-items: flex-start;
            padding-top: 1rem;
            padding-bottom: 0.5rem;
        }

        .register-terms input[type="checkbox"] {
            width: 1rem;
            height: 1rem;
            margin-top: 0.15rem;
            accent-color: var(--cams-tertiary);
            cursor: pointer;
            flex-shrink: 0;
        }

        .register-terms label {
            margin-left: 0.75rem;
            font-size: 0.875rem;
            line-height: 1.25rem;
            color: var(--cams-on-surface-variant);
            cursor: pointer;
            user-select: none;
        }

        .register-terms label a {
            color: var(--cams-tertiary);
            font-weight: 500;
            text-decoration: none;
            transition: color 0.15s, text-decoration 0.15s;
        }

        .register-terms label a:hover {
            color: var(--cams-on-tertiary-container);
            text-decoration: underline;
        }

        /* Submit button */
        .register-form .btn-register {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 0.5rem;
            padding: 0.875rem 1rem;
            border: 1px solid transparent;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: var(--cams-on-tertiary-container);
            background-color: var(--cams-tertiary-container);
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .register-form .btn-register:hover {
            background-color: var(--cams-tertiary);
            color: #ffffff;
        }

        .register-form .btn-register:focus {
            outline: none;
            box-shadow: 0 0 0 0.25rem rgba(168, 45, 104, 0.25);
        }

        .register-form .btn-register:active {
            transform: scale(0.98);
        }

        .register-form .btn-register i {
            font-size: 0.875rem;
        }

        /* Login link */
        .register-login-link {
            margin-top: 2rem;
            text-align: center;
            font-size: 0.875rem;
            color: var(--cams-on-surface-variant);
        }

        .register-login-link a {
            color: var(--cams-tertiary);
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            text-decoration: none;
            margin-left: 0.25rem;
            transition: color 0.15s, text-decoration 0.15s;
        }

        .register-login-link a:hover {
            color: var(--cams-on-tertiary-container);
            text-decoration: underline;
        }

        /* ========== Alert Error Styling ========== */
        .register-alert {
            background-color: #fff5f5;
            border: 1px solid #fecaca;
            border-radius: 10px;
            padding: 0.875rem 1rem;
            margin-bottom: 1.5rem;
            font-size: 0.875rem;
        }

        .register-alert ul {
            margin-bottom: 0;
            margin-top: 0.5rem;
            padding-left: 1.25rem;
        }

        .register-alert ul li {
            margin-bottom: 0.25rem;
        }

        /* ========== Invalid Feedback ========== */
        .register-form .invalid-feedback {
            font-size: 0.75rem;
            margin-top: 0.25rem;
        }

        /* ========== Responsive Adjustments ========== */
        @media (max-width: 767.98px) {
            body.register-page {
                padding: 0;
                align-items: flex-start;
            }

            .register-container {
                border-radius: 0;
                box-shadow: none;
                min-height: 100dvh;
            }

            .register-heading h1 {
                font-size: 1.75rem;
                line-height: 2.25rem;
            }
        }

        @media (max-height: 700px) and (min-width: 768px) {
            .register-container {
                min-height: auto;
                margin: 1.5rem 0;
            }
        }
    </style>
</head>
<body class="register-page">

<!-- ============================================================
     Asymmetric Layout Container
     ============================================================ -->
<div class="register-container">

    <%-- ==================== LEFT: Brand Panel ==================== --%>
    <div class="register-brand">
        <%-- Background image overlay --%>
        <div class="register-brand-bg-img"
             title="Abstract flowing silk texture in pastel pink and teal hues — serene, modern aesthetic for a premium healthcare brand.">
        </div>

        <%-- Brand info card --%>
        <div class="register-brand-card">
            <div class="brand-icon">
                <i class="bi bi-clipboard2-heart"></i>
            </div>
            <div>
                <h2>Phòng Khám Sản Phụ Khoa</h2>
                <p style="margin-top: 1rem;">
                    Hệ thống quản lý phòng khám hiện đại, trao quyền cho đội ngũ y tế với công cụ chính xác,
                    tận tâm và hiệu quả trong môi trường lâm sàng.
                </p>
            </div>
        </div>
    </div>

    <%-- ==================== RIGHT: Form Panel ==================== --%>
    <div class="register-form-panel">

        <%-- Mobile Brand Header (visible only on mobile) --%>
        <div class="register-mobile-brand">
            <i class="bi bi-clipboard2-heart brand-icon"></i>
            <span>Phòng Khám Sản Nhi</span>
        </div>

        <%-- Heading --%>
        <div class="register-heading">
            <h1>Tạo Tài Khoản</h1>
            <p>Nhập thông tin của bạn để truy cập vào hệ thống phòng khám.</p>
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
            <div class="field-group">
                <label class="form-label" for="fullName">
                    Họ và tên <span class="text-danger">*</span>
                </label>
                <div class="register-input-group">
                    <span class="input-icon"><i class="bi bi-person"></i></span>
                    <input type="text"
                           class="form-control ${not empty errors.fullName ? 'is-invalid' : ''}"
                           id="fullName"
                           name="fullName"
                           value="${fullName}"
                           placeholder="Nguyễn Văn A"
                           maxlength="100"
                           required>
                    <c:if test="${not empty errors.fullName}">
                        <div class="invalid-feedback d-block">${errors.fullName}</div>
                    </c:if>
                </div>
            </div>

            <%-- Email --%>
            <div class="field-group">
                <label class="form-label" for="email">
                    Email <span class="text-danger">*</span>
                </label>
                <div class="register-input-group">
                    <span class="input-icon"><i class="bi bi-envelope"></i></span>
                    <input type="email"
                           class="form-control ${not empty errors.email ? 'is-invalid' : ''}"
                           id="email"
                           name="email"
                           value="${email}"
                           placeholder="ten@email.com"
                           maxlength="100"
                           required>
                    <c:if test="${not empty errors.email}">
                        <div class="invalid-feedback d-block">${errors.email}</div>
                    </c:if>
                </div>
            </div>

            <%-- Phone Number --%>
            <div class="field-group">
                <label class="form-label" for="phone">
                    Số điện thoại <span class="text-danger">*</span>
                </label>
                <div class="register-input-group">
                    <span class="input-icon"><i class="bi bi-telephone"></i></span>
                    <input type="tel"
                           class="form-control ${not empty errors.phone ? 'is-invalid' : ''}"
                           id="phone"
                           name="phone"
                           value="${phone}"
                           placeholder="0912345678 (đúng 10 chữ số)"
                           maxlength="10"
                           required>
                    <c:if test="${not empty errors.phone}">
                        <div class="invalid-feedback d-block">${errors.phone}</div>
                    </c:if>
                </div>
            </div>

            <%-- Password Row (2 columns on sm+) --%>
            <div class="field-row">
                <%-- Password --%>
                <div class="field-group">
                    <label class="form-label" for="password">
                        Mật khẩu <span class="text-danger">*</span>
                    </label>
                    <div class="register-input-group">
                        <span class="input-icon"><i class="bi bi-lock"></i></span>
                        <input type="password"
                               class="form-control ${not empty errors.password ? 'is-invalid' : ''}"
                               id="password"
                               name="password"
                               placeholder="••••••••"
                               minlength="6"
                               required>
                        <button class="toggle-password" type="button"
                                data-target="password" tabindex="-1"
                                aria-label="Hiển thị mật khẩu">
                            <i class="bi bi-eye"></i>
                        </button>
                        <c:if test="${not empty errors.password}">
                            <div class="invalid-feedback d-block">${errors.password}</div>
                        </c:if>
                    </div>
                    <c:if test="${empty errors.password}">
                        <div class="form-text" style="font-size:0.7rem; color: var(--cams-outline); margin-top:0.25rem;">
                            Ít nhất 6 ký tự, có chữ + số + ký tự đặc biệt
                        </div>
                    </c:if>
                </div>

                <%-- Confirm Password --%>
                <div class="field-group">
                    <label class="form-label" for="confirmPassword">
                        Xác nhận mật khẩu <span class="text-danger">*</span>
                    </label>
                    <div class="register-input-group">
                        <span class="input-icon"><i class="bi bi-lock-fill"></i></span>
                        <input type="password"
                               class="form-control ${not empty errors.confirmPassword ? 'is-invalid' : ''}"
                               id="confirmPassword"
                               name="confirmPassword"
                               placeholder="••••••••"
                               minlength="6"
                               required>
                        <button class="toggle-password" type="button"
                                data-target="confirmPassword" tabindex="-1"
                                aria-label="Hiển thị mật khẩu">
                            <i class="bi bi-eye"></i>
                        </button>
                        <c:if test="${not empty errors.confirmPassword}">
                            <div class="invalid-feedback d-block">${errors.confirmPassword}</div>
                        </c:if>
                    </div>
                </div>
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
            <div style="padding-top:0.5rem;">
                <button type="submit" class="btn-register">
                    Đăng Ký
                    <i class="bi bi-arrow-right"></i>
                </button>
            </div>
        </form>

        <%-- Login Link --%>
        <div class="register-login-link">
            Đã có tài khoản?
            <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
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
