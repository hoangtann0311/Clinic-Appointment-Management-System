<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Admin Sidebar — CAMS v3.0 Pink Theme
    CSS nhúng trực tiếp để đảm bảo luôn hiển thị đúng.
--%>

<c:set var="requestURI" value="${pageContext.request.servletPath}" />

<!-- Sidebar Backdrop (mobile) -->
<div class="admin-sidebar-backdrop" id="sidebarBackdrop" onclick="closeSidebar()"></div>

<!-- Sidebar -->
<aside class="admin-sidebar" id="adminSidebar">

    <!-- User Info -->
    <div class="admin-sidebar-user">
        <div class="admin-sidebar-avatar">
            ${fn:substring(sessionScope.user.fullName, 0, 1)}
        </div>
        <div class="admin-sidebar-name">${sessionScope.user.fullName}</div>
        <span class="admin-sidebar-badge">
            <i class="bi bi-shield-check"></i>Quản Trị Viên
        </span>
    </div>

    <!-- Navigation Menu -->
    <ul class="admin-sidebar-menu">

        <!-- TỔNG QUAN -->
        <li class="admin-sidebar-section">Tổng Quan</li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/dashboard"
               class="${fn:contains(requestURI, '/admin/dashboard') ? 'active' : ''}">
                <i class="bi bi-speedometer2"></i>
                <span>Dashboard</span>
            </a>
        </li>

        <!-- QUẢN LÝ -->
        <li class="admin-sidebar-section">Quản Lý</li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/users/"
               class="${fn:contains(requestURI, '/admin/users') ? 'active' : ''}">
                <i class="bi bi-people-fill"></i>
                <span>Quản Lý Người Dùng</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/roles/"
               class="${fn:contains(requestURI, '/admin/roles') ? 'active' : ''}">
                <i class="bi bi-shield-lock-fill"></i>
                <span>Vai Trò &amp; Phân Quyền</span>
            </a>
        </li>
        <!-- <li>
            <a href="${pageContext.request.contextPath}/admin/doctors/"
               class="${fn:contains(requestURI, '/admin/doctors') ? 'active' : ''}">
                <i class="bi bi-person-badge-fill"></i>
                <span>Quản Lý Bác Sĩ lâm sàng</span>
            </a>
        </li> -->
        <!-- Dịch Vụ, Thuốc, Biểu Giá → Đã chuyển sang Manager -->

        <!-- HỆ THỐNG -->
        <li class="admin-sidebar-section">Hệ Thống</li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/audit-logs/"
               class="${fn:contains(requestURI, '/admin/audit-logs') ? 'active' : ''}">
                <i class="bi bi-clipboard-data"></i>
                <span>Lịch Sử Hoạt Động</span>
            </a>
        </li>
    </ul>
</aside>

<!-- Sidebar Toggle Script -->
<script>
function openSidebar() {
    var s = document.getElementById('adminSidebar');
    var b = document.getElementById('sidebarBackdrop');
    var m = document.getElementById('adminMain');
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
</script>
