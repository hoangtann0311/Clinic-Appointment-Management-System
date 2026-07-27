<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Hồ Sơ Cá Nhân — Nhân viên lễ tân (role_id = 4)

    Dữ liệu chỉ nằm ở bảng users. Không có ảnh đại diện: bảng users không có cột
    lưu ảnh, và vai trò này không có bảng mở rộng riêng.

    Trang tự dựng khung HTML giống hệt các trang Lễ Tân khác (reception-queue.jsp,
    reception-booking.jsp…) vì nhóm trang này không dùng common/header.jsp.

    Trường chỉ-xem (Email, Bộ phận, Chức danh, Vai trò) render bằng
    profile-readonly-field.jspf — không phải thẻ <input>, nên không sửa được bằng
    DevTools. Servlet cũng không đọc getParameter cho chúng và DAO không có chúng
    trong câu UPDATE.
--%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ Sơ Cá Nhân - CAMS Lễ Tân</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css?v=202" rel="stylesheet">
</head>
<body class="admin-body">

<%@ include file="../common/profile-readonly-style.jspf" %>

<c:set var="requestURI" value="${pageContext.request.servletPath}" />

<%-- Giá trị hiển thị: ưu tiên dữ liệu vừa nhập (khi có lỗi), nếu không thì lấy từ CSDL --%>
<c:set var="vFullName" value="${pf_formFullName != null ? pf_formFullName : pf_profile.fullName}" />
<c:set var="vPhone"    value="${pf_formPhone    != null ? pf_formPhone    : pf_profile.phone}" />

<!-- Top Header Bar -->
<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/admin/reception" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i>
            CAMS
            <span class="brand-badge">Lễ Tân</span>
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
                    <small class="text-muted">Lễ Tân</small>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li>
                    <a class="dropdown-item" href="${pageContext.request.contextPath}/staff/profile">
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

<div class="wrapper">
    <!-- Sidebar Backdrop (mobile) -->
    <div class="admin-sidebar-backdrop" id="sidebarBackdrop" onclick="closeSidebar()"></div>

    <!-- Left Sidebar -->
    <aside class="admin-sidebar" id="adminSidebar">
        <div class="admin-sidebar-user">
            <div class="admin-sidebar-avatar">
                ${fn:escapeXml(fn:substring(sessionScope.user.fullName, 0, 1))}
            </div>
            <div class="admin-sidebar-name"><c:out value="${sessionScope.user.fullName}" /></div>
            <span class="admin-sidebar-badge">
                <i class="bi bi-shield-check"></i>LỄ TÂN
            </span>
        </div>

        <ul class="admin-sidebar-menu">
            <li class="admin-sidebar-section">Tổng quan</li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception"
                   class="${fn:contains(requestURI, '/reception') && !fn:contains(requestURI, 'booking') ? 'active' : ''}">
                    <i class="bi bi-speedometer2"></i>
                    <span>Hàng Đợi Tiếp Đón</span>
                </a>
            </li>

            <li class="admin-sidebar-section">Quản lý tiếp đón</li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/booking"
                   class="${fn:contains(requestURI, 'booking') ? 'active' : ''}">
                    <i class="bi bi-calendar-plus"></i>
                    <span>Đặt Lịch Thủ Công</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/doctor-schedules"
                   class="${fn:contains(requestURI, 'doctor-schedules') ? 'active' : ''}">
                    <i class="bi bi-calendar-week"></i>
                    <span>Lịch Làm Việc</span>
                </a>
            </li>
        </ul>
    </aside>

    <!-- Main Content -->
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
                        <form method="post" action="${pageContext.request.contextPath}/staff/profile" novalidate>
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

                            <c:set var="pfLabel" value="Bộ phận" />
                            <c:set var="pfValue" value="${pf_profile.department}" />
                            <c:set var="pfHint"  value="Do quản trị viên phân công, bạn không thể tự thay đổi." />
                            <%@ include file="../common/profile-readonly-field.jspf" %>

                            <c:set var="pfLabel" value="Chức danh" />
                            <c:set var="pfValue" value="${pf_profile.jobTitle}" />
                            <c:set var="pfHint"  value="Do quản trị viên phân công, bạn không thể tự thay đổi." />
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
                <c:set var="pfPasswordRedirect" value="${pageContext.request.contextPath}/staff/profile" />
                <%@ include file="../common/profile-password-card.jspf" %>
            </div>
        </div>

    </main>
</div>

<%-- standalone-footer.jsp KHÔNG nạp Bootstrap JS. Thiếu thẻ này thì modal đổi
     mật khẩu và dropdown tài khoản đều không mở được. Dùng đúng phiên bản mà các
     trang Lễ Tân khác đang dùng (reception-queue.jsp). --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Sidebar Toggle Script — chép đúng từ reception-queue.jsp.
    // Nút ☰ và nền mờ ở trên gọi các hàm này; không có thì chúng báo lỗi undefined.
    function openSidebar() {
        var s = document.getElementById('adminSidebar');
        var b = document.getElementById('sidebarBackdrop');
        if (!s) return;
        s.classList.add('show');
        if (b) b.classList.add('show');
        document.body.style.overflow = 'hidden';
    }
    function closeSidebar() {
        var s = document.getElementById('adminSidebar');
        var b = document.getElementById('sidebarBackdrop');
        if (!s) return;
        s.classList.remove('show');
        if (b) b.classList.remove('show');
        document.body.style.overflow = '';
    }
    function toggleSidebar() {
        var s = document.getElementById('adminSidebar');
        if (!s) return;
        s.classList.contains('show') ? closeSidebar() : openSidebar();
    }
    var toggleBtn = document.getElementById('sidebarToggle');
    if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
</script>

<%@ include file="../common/standalone-footer.jsp" %>
