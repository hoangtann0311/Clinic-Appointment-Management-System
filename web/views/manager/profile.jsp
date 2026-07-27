<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Hồ Sơ Cá Nhân — Quản lý (role_id = 3)

    Dữ liệu chỉ nằm ở bảng users. Không có ảnh đại diện.
    Khác trang Nhân viên lễ tân: KHÔNG hiển thị Chức danh (users.job_title)
    và KHÔNG hiển thị Bộ phận (users.department). Trang này chỉ có họ tên,
    số điện thoại (sửa được) cùng email và vai trò (chỉ-xem).

    Trang tự dựng khung HTML giống các trang Quản lý khác (statistics.jsp,
    dashboard.jsp…) vì nhóm trang này không dùng common/header.jsp; chỉ phần
    sidebar là fragment dùng chung layout/sidebar.jsp.

    Trường chỉ-xem (Email, Bộ phận phụ trách, Vai trò) render bằng
    profile-readonly-field.jspf — không phải thẻ <input>, nên không sửa được bằng
    DevTools. Servlet cũng không đọc getParameter cho chúng và DAO không có chúng
    trong câu UPDATE.
--%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Cá Nhân — CAMS Quản Lý</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        /* Bộ biến màu xanh của nhóm trang Quản lý — chép đúng khai báo đang dùng
           ở statistics.jsp để trang này không lệch tông với phần còn lại. */
        :root {
            --sidebar-w: 270px; --topbar-h: 66px;
            --pink-50: #F0F7FF; --pink-100: #E0EFFF; --pink-200: #BFDBFE;
            --pink-400: #60A5FA; --pink-500: #3B82F6; --pink-600: #2563EB; --pink-700: #1D4ED8;
            --c-bg:#EFF6FF; --c-surface:#fff; --c-primary:#2563EB; --c-primary-dark:#1D4ED8;
            --c-on-bg:#0F172A; --c-on-surface:#1E293B; --c-on-surface-var:#475569; --c-muted:#94A3B8;
            --c-outline-variant:#DBEAFE;
            --shadow-sm: 0 2px 8px rgba(37,99,235,0.08); --shadow-md: 0 4px 20px rgba(37,99,235,0.12);
            --r-sm:8px; --r-md:12px; --r-lg:16px; --r-pill:999px;
            --font-display:'Nunito','Be Vietnam Pro',sans-serif;
            --font-body:'Inter','Be Vietnam Pro',sans-serif;
        }
        body{font-family:var(--font-body);background:var(--c-bg);color:var(--c-on-bg);margin:0;padding:0;line-height:1.6}
        h1,h2,h3,h4,h5,h6{font-family:var(--font-display)}
    </style>
</head>
<body class="admin-body">

<%@ include file="../common/profile-readonly-style.jspf" %>

<%-- Giá trị hiển thị: ưu tiên dữ liệu vừa nhập (khi có lỗi), nếu không thì lấy từ CSDL --%>
<c:set var="vFullName" value="${pf_formFullName != null ? pf_formFullName : pf_profile.fullName}" />
<c:set var="vPhone"    value="${pf_formPhone    != null ? pf_formPhone    : pf_profile.phone}" />

<%-- TOP BAR --%>
<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/manager/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i>
            CAMS
            <span class="brand-badge">Quản Lý</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="dropdown admin-topbar-dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle" id="adminUserDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="admin-avatar-sm me-2">
                    ${not empty sessionScope.user.fullName ? fn:escapeXml(fn:substring(sessionScope.user.fullName, 0, 1)) : '?'}
                </div>
                <span class="d-none d-md-inline fw-semibold text-dark"><c:out value="${sessionScope.user.fullName}" /></span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg rounded-3" aria-labelledby="adminUserDropdown">
                <li class="dropdown-header">
                    <h6 class="text-dark mb-0 fw-bold"><c:out value="${sessionScope.user.fullName}" /></h6>
                    <%-- Trang này chỉ vai trò 3 vào được nên in thẳng nhãn đúng,
                         không dùng bảng ánh xạ roleId của các trang khác. --%>
                    <small class="text-muted">Quản Lý</small>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li>
                    <a class="dropdown-item" href="${pageContext.request.contextPath}/manager/profile">
                        <i class="bi bi-person-circle me-2 text-muted"></i>Hồ Sơ Cá Nhân
                    </a>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li>
                    <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">
                        <i class="bi bi-box-arrow-right me-2"></i>Đăng Xuất
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<%-- SIDEBAR --%>
<%@ include file="layout/sidebar.jsp" %>

<%-- MAIN --%>
<main class="admin-main" id="adminMain">

    <div class="admin-page-header">
        <div>
            <h1 class="admin-page-title">Hồ Sơ Cá Nhân</h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-person-circle"></i>
                Xem và cập nhật thông tin tài khoản của bạn
            </div>
        </div>
    </div>

    <c:if test="${not empty pf_infoSuccess}">
        <div class="alert alert-success d-flex align-items-center" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            <div><c:out value="${pf_infoSuccess}" /></div>
        </div>
    </c:if>
    <c:if test="${not empty pf_infoError}">
        <div class="alert alert-danger d-flex align-items-center" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <div><c:out value="${pf_infoError}" /></div>
        </div>
    </c:if>
    <%-- Đổi mật khẩu thành công: ChangePasswordServlet đặt successMessage vào
         session rồi redirect về đây. Không hiển thị thì người dùng không biết
         đã đổi được, và thông báo còn kẹt lại nhảy ra ở trang khác sau đó. --%>
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success d-flex align-items-center" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            <div><c:out value="${sessionScope.successMessage}" /></div>
        </div>
        <c:remove var="successMessage" scope="session" />
    </c:if>

    <div class="row g-4">
        <div class="col-12 col-xl-7">
            <div class="card admin-card">
                <div class="card-header">
                    <h5><i class="bi bi-person-vcard"></i>Thông Tin Cá Nhân</h5>
                </div>
                <div class="card-body">
                    <form method="post" action="${pageContext.request.contextPath}/manager/profile" novalidate>
                        <input type="hidden" name="_csrf" value="${fn:escapeXml(sessionScope.csrfToken)}">

                        <%-- ── Trường sửa được ── --%>
                        <div class="mb-3">
                            <label for="pf_fullName" class="form-label fw-semibold">
                                Họ và tên <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="pf_fullName" name="pf_fullName"
                                   maxlength="100" required value="${fn:escapeXml(vFullName)}">
                            <div class="form-text">Tối đa 100 ký tự.</div>
                        </div>

                        <div class="mb-3">
                            <label for="pf_phone" class="form-label fw-semibold">Số điện thoại</label>
                            <input type="text" class="form-control" id="pf_phone" name="pf_phone"
                                   maxlength="10" inputmode="numeric" value="${fn:escapeXml(vPhone)}">
                            <div class="form-text">Gồm đúng 10 chữ số, bắt đầu bằng 0. Có thể để trống.</div>
                        </div>

                        <%-- ── Trường CHỈ-XEM ── --%>
                        <c:set var="pfLabel" value="Email" />
                        <c:set var="pfValue" value="${pf_profile.email}" />
                        <c:set var="pfHint"  value="Email dùng để đăng nhập. Liên hệ quản trị viên nếu cần thay đổi." />
                        <%@ include file="../common/profile-readonly-field.jspf" %>

                        <c:set var="pfLabel" value="Vai trò" />
                        <c:set var="pfValue" value="${pf_user.roleNameDisplay}" />
                        <c:set var="pfHint"  value="Vai trò do hệ thống quản lý, bạn không thể tự thay đổi." />
                        <%@ include file="../common/profile-readonly-field.jspf" %>

                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save me-1"></i>Lưu Thay Đổi
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-12 col-xl-5">
            <c:set var="pfPasswordRedirect" value="${pageContext.request.contextPath}/manager/profile" />
            <%@ include file="../common/profile-password-card.jspf" %>
        </div>
    </div>

</main>

<%-- standalone-footer.jsp KHÔNG nạp Bootstrap JS. Thiếu thẻ này thì modal đổi
     mật khẩu và dropdown tài khoản đều không mở được. Dùng đúng phiên bản mà các
     trang Quản lý khác đang dùng (statistics.jsp, dashboard.jsp).
     Hàm bật/tắt sidebar đã có sẵn trong layout/sidebar.jsp nên không lặp lại. --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<%@ include file="../common/standalone-footer.jsp" %>
