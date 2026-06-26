<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Manager Sidebar — CAMS v3.0 Pink Theme (dùng chung admin.css)
--%>

<c:set var="requestURI" value="${pageContext.request.servletPath}" />

<!-- Sidebar Backdrop (mobile) -->
<div class="admin-sidebar-backdrop" id="sidebarBackdrop" onclick="closeSidebar()"></div>

<!-- Sidebar -->
<aside class="admin-sidebar" id="mgrSidebar">

    <!-- User Info -->
    <div class="admin-sidebar-user">
        <div class="admin-sidebar-avatar">
            ${fn:substring(sessionScope.user.fullName, 0, 1)}
        </div>
        <div class="admin-sidebar-name">${sessionScope.user.fullName}</div>
        <span class="admin-sidebar-badge">
            <i class="bi bi-briefcase-fill"></i>Quản Lý
        </span>
    </div>

    <!-- Navigation Menu -->
    <ul class="admin-sidebar-menu">

        <!-- TONG QUAN -->
        <li class="admin-sidebar-section">Tổng Quan</li>
        <li>
            <a href="${pageContext.request.contextPath}/manager/dashboard"
               class="${fn:contains(requestURI, '/manager/dashboard') ? 'active' : ''}">
                <i class="bi bi-speedometer2"></i>
                <span>Dashboard</span>
            </a>
        </li>

        <!-- QUAN LY KINH DOANH -->
        <li class="admin-sidebar-section">Quản Lý Kinh Doanh</li>
        <li>
            <a href="${pageContext.request.contextPath}/manager/services/"
               class="${fn:contains(requestURI, '/manager/services') ? 'active' : ''}">
                <i class="bi bi-activity"></i>
                <span>Dịch Vụ Y Tế</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/manager/medicines/"
               class="${fn:contains(requestURI, '/manager/medicines') ? 'active' : ''}">
                <i class="bi bi-capsule"></i>
                <span>Danh Mục Thuốc</span>
            </a>
        </li>

        <!-- QUAN LY LICH TRUC -->
        <li class="admin-sidebar-section">Quản Lý Nhân Sự</li>
        <li>
            <a href="${pageContext.request.contextPath}/manager/schedules/"
               class="${fn:contains(requestURI, '/manager/schedules') ? 'active' : ''}">
                <i class="bi bi-calendar-check"></i>
                <span>Duyệt Lịch Trực</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/manager/time-slots/"
               class="${fn:contains(requestURI, '/manager/time-slots') ? 'active' : ''}">
                <i class="bi bi-clock-fill"></i>
                <span>Khung Giờ Khám</span>
            </a>
        </li>

        <!-- BAO CAO -->
        <li class="admin-sidebar-section">Báo Cáo &amp; Thống Kê</li>
        <li>
            <a href="${pageContext.request.contextPath}/manager/services/?action=price-history"
               class="${fn:contains(requestURI, '/manager/services') && fn:contains(pageContext.request.queryString, 'price-history') ? 'active' : ''}">
                <i class="bi bi-clock-history"></i>
                <span>Nhật Ký Điều Chỉnh Giá</span>
            </a>
        </li>
        <li>
            <a href="#" class="disabled" title="Đang phát triển">
                <i class="bi bi-graph-up-arrow"></i>
                <span>Báo Cáo Doanh Thu</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/manager/statistics/"
               class="${fn:contains(requestURI, '/manager/statistics') ? 'active' : ''}">
                <i class="bi bi-file-earmark-bar-graph"></i>
                <span>Thống Kê Dịch Vụ</span>
            </a>
        </li>
    </ul>
</aside>

<!-- Sidebar Toggle Script -->
<script>
function openSidebar() {
    var s = document.getElementById('mgrSidebar');
    var b = document.getElementById('sidebarBackdrop');
    if (!s) return;
    s.classList.add('show');
    if (b) b.classList.add('show');
    document.body.style.overflow = 'hidden';
}
function closeSidebar() {
    var s = document.getElementById('mgrSidebar');
    var b = document.getElementById('sidebarBackdrop');
    if (!s) return;
    s.classList.remove('show');
    if (b) b.classList.remove('show');
    document.body.style.overflow = '';
}
function toggleSidebar() {
    var s = document.getElementById('mgrSidebar');
    if (!s) return;
    s.classList.contains('show') ? closeSidebar() : openSidebar();
}
</script>
