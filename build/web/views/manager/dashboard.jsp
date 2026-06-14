<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — CAMS Manager</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Admin CSS (Pink Theme) -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <style>
        /* Manager Dashboard — KPI card color variants trên nền Pink Admin */
        .kpi-card {
            background: var(--c-surface) !important;
            border-radius: var(--r-lg) !important;
            border: 1px solid var(--c-outline-variant) !important;
            box-shadow: var(--shadow-sm) !important;
            overflow: hidden;
            transition: transform var(--t-normal), box-shadow var(--t-normal);
            height: 100%;
        }
        .kpi-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-md) !important;
        }
        .kpi-card .card-body {
            padding: 1.35rem 1.3rem !important;
            display: flex !important;
            align-items: center !important;
            gap: 1rem !important;
        }
        .kpi-card.kpi-services .card-body  { border-top: 3px solid var(--pink-400) !important; }
        .kpi-card.kpi-medicines .card-body { border-top: 3px solid #ce3fa7 !important; }
        .kpi-card.kpi-pricing .card-body   { border-top: 3px solid var(--rose-500) !important; }
        .kpi-card.kpi-active .card-body    { border-top: 3px solid var(--pink-600) !important; }

        .kpi-icon {
            width: 52px; height: 52px; border-radius: var(--r-md);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.35rem; flex-shrink: 0;
        }
        .kpi-services .kpi-icon  { background: var(--pink-100); color: var(--pink-600); }
        .kpi-medicines .kpi-icon { background: #fce4f3; color: #9c0f6e; }
        .kpi-pricing .kpi-icon   { background: #fdeaf6; color: var(--rose-600); }
        .kpi-active .kpi-icon    { background: var(--pink-50); color: var(--pink-700); }

        .kpi-content { flex: 1; min-width: 0; }
        .kpi-value {
            font-family: var(--font-display); font-size: 1.75rem; font-weight: 900;
            color: var(--c-on-surface); line-height: 1.1; letter-spacing: -0.04em;
        }
        .kpi-label { font-size: 0.8rem; font-weight: 600; color: var(--c-on-surface-var); margin-top: 0.15rem; }
        .kpi-sub {
            font-size: 0.7rem; font-weight: 500; color: var(--c-muted);
            display: flex; align-items: center; gap: 0.3rem; margin-top: 0.3rem;
        }

        /* Activity feed */
        .activity-feed { list-style: none; padding: 0; margin: 0; }
        .activity-item {
            display: flex; align-items: flex-start; gap: 0.75rem;
            padding: 0.65rem 0;
            border-bottom: 1px solid var(--c-outline-variant);
            transition: background var(--t-fast);
        }
        .activity-item:last-child { border-bottom: none; }
        .activity-item:hover { background: var(--pink-50); margin: 0 -0.5rem; padding-left: 0.5rem; padding-right: 0.5rem; border-radius: var(--r-sm); }
        .activity-dot {
            width: 8px; height: 8px; border-radius: 50%;
            margin-top: 0.4rem; flex-shrink: 0;
        }
        .activity-dot.create  { background: #2e7d32; box-shadow: 0 0 0 3px rgba(46,125,50,0.15); }
        .activity-dot.update  { background: #3b82f6; box-shadow: 0 0 0 3px rgba(59,130,246,0.15); }
        .activity-body { flex: 1; min-width: 0; }
        .activity-body .act-title { font-size: 0.82rem; font-weight: 600; color: var(--c-on-surface); }
        .activity-body .act-meta  { font-size: 0.7rem; color: var(--c-muted); margin-top: 0.15rem; display: flex; gap: 0.75rem; }

        /* Stats mini */
        .stats-mini-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 0.75rem;
        }
        .stat-mini {
            background: var(--c-surface);
            border: 1px solid var(--c-outline-variant);
            border-radius: var(--r-md);
            padding: 1rem 1rem;
            text-align: center;
            transition: all var(--t-normal);
        }
        .stat-mini:hover {
            border-color: var(--pink-200);
            box-shadow: var(--shadow-sm);
            transform: translateY(-1px);
        }
        .stat-mini-icon { font-size: 1.5rem; margin-bottom: 0.4rem; display: block; }
        .stat-mini-label {
            font-size: 0.72rem; font-weight: 600;
            color: var(--c-muted);
            text-transform: uppercase; letter-spacing: 0.05em;
        }
        .stat-mini-sub { font-size: 0.67rem; color: var(--c-muted); margin-top: 0.15rem; }
    </style>
</head>
<body class="admin-body">

<%-- TOP BAR --%>
<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/manager/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i>
            CAMS
            <span class="brand-badge">Manager</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">
                ${fn:substring(sessionScope.user.fullName, 0, 1)}
            </div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role">
                <i class="bi bi-briefcase-fill me-1"></i>Manager
            </span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout" title="Đăng xuất">
            <i class="bi bi-box-arrow-right"></i>
            <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
    </div>
</nav>

<%-- SIDEBAR --%>
<%@ include file="layout/sidebar.jsp" %>

<%-- MAIN CONTENT --%>
<main class="admin-main" id="adminMain">

    <%-- Page Header --%>
    <div class="admin-page-header">
        <div>
            <h1 class="admin-page-title">
                <i class="bi bi-clipboard-data me-2" style="color:var(--pink-500);"></i>Dashboard Quản Lý
            </h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-calendar3"></i>
                ${not empty todayDisplay ? todayDisplay : 'Hôm nay'}
                <span class="mx-2">&middot;</span>
                <i class="bi bi-building"></i>
                Tổng quan kinh doanh phòng khám
            </div>
        </div>
        <button class="btn-refresh" onclick="location.reload()">
            <i class="bi bi-arrow-clockwise"></i>
            Làm mới
        </button>
    </div>

    <%-- Welcome Banner --%>
    <div class="admin-welcome-banner">
        <div>
            <h2>
                <i class="bi bi-stars"></i>
                Xin chào, ${sessionScope.user.fullName}!
            </h2>
            <p>Chào mừng bạn đến với bảng điều khiển Quản Lý. Quản lý biểu giá, dịch vụ y tế và danh mục thuốc của phòng khám.</p>
        </div>
        <span class="badge-role">
            <i class="bi bi-briefcase-fill"></i>
            Quản Lý
        </span>
    </div>

    <%-- 4 KPI CARDS — Manager Focus --%>
    <div class="row g-3 mb-4">
        <div class="col-xl-3 col-lg-6">
            <div class="card kpi-card kpi-services fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-activity"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalServices ? totalServices : 0}</div>
                        <div class="kpi-label">Dịch Vụ Y Tế</div>
                        <div class="kpi-sub"><i class="bi bi-clipboard2-pulse"></i> Đang quản lý</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6">
            <div class="card kpi-card kpi-medicines fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-capsule"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalMedicines ? totalMedicines : 0}</div>
                        <div class="kpi-label">Danh Mục Thuốc</div>
                        <div class="kpi-sub"><i class="bi bi-prescription2"></i> Đang quản lý</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6">
            <div class="card kpi-card kpi-pricing fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-cash-coin"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value" style="font-size:1.2rem;">
                            <c:set var="totalItems" value="${(not empty totalServices ? totalServices : 0) + (not empty totalMedicines ? totalMedicines : 0)}"/>
                            ${totalItems}
                        </div>
                        <div class="kpi-label">Tổng Mục Biểu Giá</div>
                        <div class="kpi-sub"><i class="bi bi-tags"></i> Dịch vụ + Thuốc</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6">
            <div class="card kpi-card kpi-active fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-check2-circle"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty activeServicesCount ? activeServicesCount : 0}</div>
                        <div class="kpi-label">Dịch Vụ Đang Áp Dụng</div>
                        <div class="kpi-sub"><i class="bi bi-check-circle-fill"></i> Có hiệu lực</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- QUICK ACTIONS — Manager Core Functions --%>
    <div class="row mb-4">
        <div class="col-12">
            <div class="admin-card">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-lightning-charge-fill"></i>
                        Thao Tác Nhanh
                    </h5>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-3 col-sm-6">
                            <a href="${pageContext.request.contextPath}/manager/pricing/" class="quick-action-btn">
                                <span class="quick-action-icon"><i class="bi bi-cash-stack"></i></span>
                                <span class="quick-action-text">
                                    <span>Quản Lý Biểu Giá</span>
                                    <small>Cập nhật giá dịch vụ &amp; thuốc</small>
                                </span>
                            </a>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <a href="${pageContext.request.contextPath}/manager/services/" class="quick-action-btn">
                                <span class="quick-action-icon"><i class="bi bi-activity"></i></span>
                                <span class="quick-action-text">
                                    <span>Dịch Vụ Y Tế</span>
                                    <small>Thêm, sửa, quản lý dịch vụ</small>
                                </span>
                            </a>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <a href="${pageContext.request.contextPath}/manager/medicines/" class="quick-action-btn">
                                <span class="quick-action-icon"><i class="bi bi-capsule"></i></span>
                                <span class="quick-action-text">
                                    <span>Danh Mục Thuốc</span>
                                    <small>Quản lý kho thuốc &amp; giá</small>
                                </span>
                            </a>
                        </div>
                        <div class="col-md-3 col-sm-6">
                            <a href="${pageContext.request.contextPath}/manager/pricing/" class="quick-action-btn">
                                <span class="quick-action-icon"><i class="bi bi-graph-up-arrow"></i></span>
                                <span class="quick-action-text">
                                    <span>Xem Biểu Giá</span>
                                    <small>Tổng quan tất cả bảng giá</small>
                                </span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- QUICK STATS — At a Glance + Hướng dẫn --%>
    <div class="row g-3 mb-4">
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header admin-card-header-link">
                    <h5>
                        <i class="bi bi-clock-history"></i>
                        Hoạt Động Gần Đây
                    </h5>
                    <span class="badge-status badge-status-active" style="font-size:0.7rem;">Trực tiếp</span>
                </div>
                <div class="card-body p-3">
                    <ul class="activity-feed">
                        <li class="activity-item">
                            <span class="activity-dot create"></span>
                            <div class="activity-body">
                                <div class="act-title">Quản lý biểu giá — sẵn sàng cập nhật</div>
                                <div class="act-meta">
                                    <span><i class="bi bi-tag me-1"></i>Biểu Giá</span>
                                    <span><i class="bi bi-clock me-1"></i>Hôm nay</span>
                                </div>
                            </div>
                        </li>
                        <li class="activity-item">
                            <span class="activity-dot update"></span>
                            <div class="activity-body">
                                <div class="act-title">Danh mục dịch vụ y tế — sẵn sàng quản lý</div>
                                <div class="act-meta">
                                    <span><i class="bi bi-activity me-1"></i>Dịch Vụ</span>
                                    <span><i class="bi bi-clock me-1"></i>Hôm nay</span>
                                </div>
                            </div>
                        </li>
                        <li class="activity-item">
                            <span class="activity-dot create"></span>
                            <div class="activity-body">
                                <div class="act-title">Danh mục thuốc — sẵn sàng quản lý</div>
                                <div class="act-meta">
                                    <span><i class="bi bi-capsule me-1"></i>Thuốc</span>
                                    <span><i class="bi bi-clock me-1"></i>Hôm nay</span>
                                </div>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-info-circle-fill"></i>
                        Hướng Dẫn Quản Lý
                    </h5>
                </div>
                <div class="card-body">
                    <div class="stats-mini-row">
                        <div class="stat-mini">
                            <span class="stat-mini-icon" style="color:var(--pink-500);"><i class="bi bi-1-circle-fill"></i></span>
                            <div class="stat-mini-label">Biểu Giá</div>
                            <div class="stat-mini-sub">Quản lý đơn giá<br>dịch vụ &amp; thuốc</div>
                        </div>
                        <div class="stat-mini">
                            <span class="stat-mini-icon" style="color:var(--pink-500);"><i class="bi bi-2-circle-fill"></i></span>
                            <div class="stat-mini-label">Dịch Vụ</div>
                            <div class="stat-mini-sub">Thêm / sửa / ẩn<br>dịch vụ y tế</div>
                        </div>
                        <div class="stat-mini">
                            <span class="stat-mini-icon" style="color:var(--pink-500);"><i class="bi bi-3-circle-fill"></i></span>
                            <div class="stat-mini-label">Thuốc</div>
                            <div class="stat-mini-sub">Quản lý danh mục<br>&amp; tồn kho thuốc</div>
                        </div>
                        <div class="stat-mini">
                            <span class="stat-mini-icon" style="color:#2e7d32;"><i class="bi bi-check-circle-fill"></i></span>
                            <div class="stat-mini-label">Áp Dụng</div>
                            <div class="stat-mini-sub">Giá mới có hiệu lực<br>ngay trong hệ thống</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- THONG TIN HE THONG + CHUC NANG --%>
    <div class="row g-3">
        <div class="col-lg-4">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-info-circle-fill"></i>
                        Thông Tin Hệ Thống
                    </h5>
                </div>
                <div class="card-body">
                    <ul class="admin-info-list">
                        <li>
                            <span class="info-label"><i class="bi bi-box-seam-fill"></i>Phiên bản</span>
                            <span class="info-value">v1.0.0</span>
                        </li>
                        <li>
                            <span class="info-label"><i class="bi bi-server"></i>Database</span>
                            <span class="info-value">SQL Server</span>
                        </li>
                        <li>
                            <span class="info-label"><i class="bi bi-hdd-stack-fill"></i>Server</span>
                            <span class="info-value">Tomcat 10.1</span>
                        </li>
                        <li>
                            <span class="info-label"><i class="bi bi-cpu-fill"></i>Java</span>
                            <span class="info-value">JDK 17 LTS</span>
                        </li>
                        <li>
                            <span class="info-label"><i class="bi bi-circle-fill" style="color:#2e7d32;font-size:0.5rem;"></i>Trạng thái</span>
                            <span class="info-value good">Hoạt động</span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-gear-wide-connected"></i>
                        Chức Năng Quản Lý
                    </h5>
                </div>
                <div class="card-body p-0">
                    <div class="admin-table-wrapper">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Chức Năng</th>
                                    <th>Mô Tả</th>
                                    <th>Đường Dẫn</th>
                                    <th>Trạng Thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td style="font-weight:700;">
                                        <i class="bi bi-cash-coin me-2" style="color:var(--pink-500);"></i>Biểu Giá
                                    </td>
                                    <td style="color:var(--c-muted);">Quản lý đơn giá dịch vụ y tế và thuốc</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/manager/pricing/"
                                           style="color:var(--pink-500);font-weight:600;text-decoration:none;">
                                            /manager/pricing &rarr;
                                        </a>
                                    </td>
                                    <td><span class="badge-status badge-status-active">Hoạt động</span></td>
                                </tr>
                                <tr>
                                    <td style="font-weight:700;">
                                        <i class="bi bi-activity me-2" style="color:var(--pink-500);"></i>Dịch Vụ
                                    </td>
                                    <td style="color:var(--c-muted);">Thêm, sửa, quản lý dịch vụ y tế</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/manager/services/"
                                           style="color:var(--pink-500);font-weight:600;text-decoration:none;">
                                            /manager/services &rarr;
                                        </a>
                                    </td>
                                    <td><span class="badge-status badge-status-active">Hoạt động</span></td>
                                </tr>
                                <tr>
                                    <td style="font-weight:700;">
                                        <i class="bi bi-capsule me-2" style="color:#ce3fa7;"></i>Thuốc
                                    </td>
                                    <td style="color:var(--c-muted);">Quản lý danh mục thuốc, tồn kho, giá</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/manager/medicines/"
                                           style="color:var(--pink-500);font-weight:600;text-decoration:none;">
                                            /manager/medicines &rarr;
                                        </a>
                                    </td>
                                    <td><span class="badge-status badge-status-active">Hoạt động</span></td>
                                </tr>
                                <tr>
                                    <td style="font-weight:700;">
                                        <i class="bi bi-graph-up-arrow me-2" style="color:var(--c-muted);"></i>Báo Cáo
                                    </td>
                                    <td style="color:var(--c-muted);">Báo cáo doanh thu &amp; thống kê</td>
                                    <td><span style="color:var(--c-muted);">&mdash;</span></td>
                                    <td><span class="badge-status badge-status-pending">Sắp ra mắt</span></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

</main>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
// Sidebar toggle
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });

// Active link highlight
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        var link = links[i];
        if (link.href && link.href !== window.location.origin + '/') {
            try {
                if (window.location.pathname.startsWith(new URL(link.href, location).pathname)) {
                    link.classList.add('active');
                }
            } catch(e) {}
        }
    }
})();
</script>

</body>
</html>
