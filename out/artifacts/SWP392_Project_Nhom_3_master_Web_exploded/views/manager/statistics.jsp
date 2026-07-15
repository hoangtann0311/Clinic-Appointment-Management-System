<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thống Kê Dịch Vụ — CAMS Manager</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>

    <!-- Admin CSS (Pink Theme) -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <style>
        /* ── Thống Kê Dịch Vụ — Manager Dashboard Styles ── */

        /* KPI Card — service-statistics variants */
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

        /* 6 KPI card color variants */
        .kpi-usage-today    .card-body { border-top: 3px solid #3b82f6 !important; }
        .kpi-revenue-today  .card-body { border-top: 3px solid #10b981 !important; }
        .kpi-growth         .card-body { border-top: 3px solid #f59e0b !important; }
        .kpi-active-svc     .card-body { border-top: 3px solid var(--pink-400) !important; }
        .kpi-top-svc        .card-body { border-top: 3px solid #8b5cf6 !important; }
        .kpi-svc-used       .card-body { border-top: 3px solid #06b6d4 !important; }

        .kpi-usage-today    .kpi-icon { background: #dbeafe; color: #2563eb; }
        .kpi-revenue-today  .kpi-icon { background: #d1fae5; color: #059669; }
        .kpi-growth         .kpi-icon { background: #fef3c7; color: #d97706; }
        .kpi-active-svc     .kpi-icon { background: var(--pink-100); color: var(--pink-600); }
        .kpi-top-svc        .kpi-icon { background: #ede9fe; color: #7c3aed; }
        .kpi-svc-used       .kpi-icon { background: #cffafe; color: #0891b2; }

        .kpi-icon {
            width: 52px; height: 52px; border-radius: var(--r-md);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.35rem; flex-shrink: 0;
        }
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
        .kpi-sub.up   { color: #059669; }
        .kpi-sub.down { color: #dc2626; }

        /* Admin Card */
        .admin-card {
            background: var(--c-surface) !important;
            border: 1px solid var(--c-outline-variant) !important;
            border-radius: var(--r-lg) !important;
            box-shadow: var(--shadow-xs) !important;
            overflow: hidden;
        }
        .admin-card .card-header {
            background: var(--pink-50) !important;
            border-bottom: 1px solid var(--pink-200) !important;
            padding: 0.9rem 1.25rem !important;
        }
        .admin-card .card-header h5 {
            font-family: var(--font-display); font-size: 0.9rem; font-weight: 800;
            color: var(--c-primary-dark); margin: 0;
            display: flex; align-items: center; gap: 0.5rem;
        }
        .admin-card .card-header h5 i { color: var(--pink-500); }
        .admin-card .card-body { background: var(--c-surface) !important; padding: 1.25rem !important; }

        /* Chart containers */
        .chart-container {
            position: relative; width: 100%;
        }
        .chart-container canvas { width: 100% !important; }

        /* Table */
        .admin-table-wrapper { overflow-x: auto; }
        .admin-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
        .admin-table thead th {
            font-family: var(--font-display); font-size: 0.7rem; font-weight: 800;
            text-transform: uppercase; letter-spacing: 0.07em;
            color: var(--c-primary); padding: 0.75rem 0.875rem;
            background: var(--pink-50); border-bottom: 2px solid var(--pink-200); white-space: nowrap;
        }
        .admin-table tbody tr {
            border-bottom: 1px solid var(--c-outline-variant); transition: background var(--t-fast);
        }
        .admin-table tbody tr:hover { background: var(--pink-50); }
        .admin-table tbody td { padding: 0.7rem 0.875rem; color: var(--c-on-surface); vertical-align: middle; }

        /* Growth indicators */
        .growth-indicator {
            display: inline-flex; align-items: center; gap: 0.25rem;
            font-weight: 700; font-size: 0.8rem;
        }
        .growth-indicator.up   { color: #059669; }
        .growth-indicator.down { color: #dc2626; }
        .growth-indicator.stable { color: var(--c-muted); }

        /* Badges */
        .badge-status {
            display: inline-block; padding: 3px 10px; border-radius: var(--r-pill);
            font-size: 0.7rem; font-weight: 700;
        }
        .badge-status-active    { background: #d1fae5; color: #065f46; }
        .badge-status-warning   { background: #fef3c7; color: #92400e; }
        .badge-status-danger    { background: #fee2e2; color: #991b1b; }
        .badge-status-info      { background: #dbeafe; color: #1e40af; }

        /* Low perf highlight */
        .low-perf-row { background: #fffbeb !important; }
        .low-perf-row:hover { background: #fef3c7 !important; }

        /* Empty state */
        .admin-empty-state { text-align: center; padding: 2.5rem 1rem; color: var(--c-muted); }
        .admin-empty-state i { font-size: 2.5rem; color: var(--pink-200); display: block; margin-bottom: 0.75rem; }
        .admin-empty-state h6 { font-family: var(--font-display); font-weight: 700; color: var(--c-on-surface-var); margin-bottom: 0.25rem; }
        .admin-empty-state p { font-size: 0.85rem; margin: 0; }

        /* Animations */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .fade-in-up { animation: fadeInUp 0.4s ease forwards; }

        @media (max-width: 991.98px) {
            .kpi-value { font-size: 1.4rem; }
            .kpi-icon { width: 42px; height: 42px; font-size: 1.1rem; }
        }
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
                <i class="bi bi-file-earmark-bar-graph me-2" style="color:var(--pink-500);"></i>Thống Kê Dịch Vụ Y Tế
            </h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-calendar3"></i>
                ${not empty todayDisplay ? todayDisplay : 'Hôm nay'}
                <span class="mx-2">&middot;</span>
                <i class="bi bi-graph-up-arrow"></i>
                Phân tích sử dụng &amp; doanh thu dịch vụ
            </div>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/manager/dashboard" class="btn-refresh">
                <i class="bi bi-speedometer2"></i>
                Dashboard
            </a>
            <button class="btn-refresh" onclick="location.reload()">
                <i class="bi bi-arrow-clockwise"></i>
                Làm mới
            </button>
        </div>
    </div>

    <%-- ═══════════════════════════════════════════════ --%>
    <%-- 6 KPI CARDS — TỔNG QUAN DỊCH VỤ HÔM NAY         --%>
    <%-- ═══════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- 1. Tổng Lượt Sử Dụng Hôm Nay --%>
        <div class="col-xl-2 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-usage-today fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-people-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalUsageToday ? totalUsageToday : 0}</div>
                        <div class="kpi-label">Lượt Sử Dụng</div>
                        <div class="kpi-sub">
                            <i class="bi bi-calendar-check"></i> Hôm nay
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 2. Tổng Doanh Thu Dịch Vụ Hôm Nay --%>
        <div class="col-xl-2 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-revenue-today fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-cash-coin"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value" style="font-size:1.2rem;">${not empty totalRevenueTodayFormatted ? totalRevenueTodayFormatted : '0'}</div>
                        <div class="kpi-label">Doanh Thu Dịch Vụ</div>
                        <div class="kpi-sub">
                            <i class="bi bi-graph-up-arrow"></i> Đã thanh toán
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 3. Tốc Độ Tăng Trưởng Lượt Sử Dụng --%>
        <div class="col-xl-2 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-growth fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-graph-up-arrow"></i></div>
                    <div class="kpi-content">
                        <c:set var="growthRate" value="${not empty usageGrowthRate ? usageGrowthRate : 0}" />
                        <div class="kpi-value" style="color:${growthRate >= 0 ? '#059669' : '#dc2626'};">
                            ${not empty usageGrowthFormatted ? usageGrowthFormatted : '0%'}
                        </div>
                        <div class="kpi-label">Tăng Trưởng Lượt SD</div>
                        <div class="kpi-sub ${growthRate >= 0 ? 'up' : 'down'}">
                            <c:choose>
                                <c:when test="${growthRate > 0}">
                                    <i class="bi bi-arrow-up-circle-fill"></i> Tăng so hôm qua
                                </c:when>
                                <c:when test="${growthRate < 0}">
                                    <i class="bi bi-arrow-down-circle-fill"></i> Giảm so hôm qua
                                </c:when>
                                <c:otherwise>
                                    <i class="bi bi-dash-circle"></i> Không đổi
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 4. Dịch Vụ Đang Hoạt Động --%>
        <div class="col-xl-2 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-active-svc fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-check2-circle"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty activeServiceCount ? activeServiceCount : 0}</div>
                        <div class="kpi-label">Dịch Vụ Hoạt Động</div>
                        <div class="kpi-sub">
                            <i class="bi bi-check-circle-fill"></i> Đang áp dụng
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 5. Dịch Vụ Được Dùng Nhiều Nhất --%>
        <div class="col-xl-2 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-top-svc fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-trophy-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value" style="font-size:1.1rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                            ${not empty topServiceName ? topServiceName : '—'}
                        </div>
                        <div class="kpi-label">Dịch Vụ Top 1</div>
                        <div class="kpi-sub">
                            <i class="bi bi-bar-chart-fill"></i> ${not empty topServiceUsage ? topServiceUsage : 0} lượt hôm nay
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 6. Dịch Vụ Được Sử Dụng Hôm Nay --%>
        <div class="col-xl-2 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-svc-used fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-activity"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty servicesUsedToday ? servicesUsedToday : 0}</div>
                        <div class="kpi-label">Loại DV Được Dùng</div>
                        <div class="kpi-sub">
                            <i class="bi bi-pie-chart-fill"></i> / ${not empty activeServiceCount ? activeServiceCount : 0} đang hoạt động
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ═══════════════════════════════════════════════ --%>
    <%-- BIỂU ĐỒ HÀNG 1: Top DV theo lượt sử dụng + Phân bổ doanh thu theo nhóm --%>
    <%-- ═══════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Biểu đồ cột: Top 10 dịch vụ theo lượt sử dụng hôm nay --%>
        <div class="col-xl-7">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5>
                        <i class="bi bi-bar-chart-fill"></i>
                        Top Dịch Vụ — Lượt Sử Dụng Hôm Nay
                    </h5>
                    <span class="badge-status badge-status-info" style="font-size:0.65rem;">Hôm nay</span>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty topServicesByUsage}">
                            <div class="chart-container">
                                <canvas id="topUsageChart" height="300"></canvas>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-bar-chart"></i>
                                <h6>Chưa có dữ liệu lượt sử dụng</h6>
                                <p>Dữ liệu lịch hẹn sẽ hiển thị tại đây khi có bệnh nhân đặt lịch.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Biểu đồ tròn: Phân bổ doanh thu theo nhóm dịch vụ --%>
        <div class="col-xl-5">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-pie-chart-fill"></i>
                        Doanh Thu Theo Nhóm Dịch Vụ
                    </h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty categoryRevenue && categoryRevenue.size() > 0}">
                            <div class="chart-container">
                                <canvas id="categoryRevenueChart" height="300"></canvas>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-pie-chart"></i>
                                <h6>Chưa có dữ liệu doanh thu</h6>
                                <p>Doanh thu theo nhóm sẽ hiển thị khi có hóa đơn được thanh toán.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ═══════════════════════════════════════════════ --%>
    <%-- BIỂU ĐỒ HÀNG 2: Doanh thu 7 ngày + Doanh thu 12 tháng --%>
    <%-- ═══════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Biểu đồ đường: Doanh thu 7 ngày gần nhất --%>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-graph-up-arrow"></i>
                        Doanh Thu Dịch Vụ — 7 Ngày Gần Nhất
                    </h5>
                </div>
                <div class="card-body">
                    <div class="chart-container">
                        <canvas id="revenue7DaysChart" height="280"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <%-- Biểu đồ đường: Doanh thu 12 tháng --%>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-graph-up-arrow"></i>
                        Doanh Thu Dịch Vụ — 12 Tháng Gần Nhất
                    </h5>
                </div>
                <div class="card-body">
                    <div class="chart-container">
                        <canvas id="revenue12MonthsChart" height="280"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ═══════════════════════════════════════════════ --%>
    <%-- BẢNG THỐNG KÊ CHI TIẾT TẤT CẢ DỊCH VỤ           --%>
    <%-- ═══════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <div class="col-12">
            <div class="admin-card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5>
                        <i class="bi bi-table"></i>
                        Bảng Thống Kê Chi Tiết Dịch Vụ
                    </h5>
                    <span style="font-size:0.75rem;color:var(--c-muted);">
                        <i class="bi bi-info-circle me-1"></i>
                        So sánh: Hôm nay vs Hôm qua
                    </span>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty allServiceStats}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Mã DV</th>
                                            <th>Tên Dịch Vụ</th>
                                            <th>Nhóm</th>
                                            <th class="text-end">Đơn Giá</th>
                                            <th class="text-center">Hôm Nay</th>
                                            <th class="text-center">Hôm Qua</th>
                                            <th class="text-center">Tăng Trưởng</th>
                                            <th class="text-end">Doanh Thu Hôm Nay</th>
                                            <th class="text-center">Tổng Lượt SD</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:set var="rowIndex" value="0" />
                                        <c:forEach var="svc" items="${allServiceStats}" varStatus="loop">
                                            <c:set var="rowIndex" value="${loop.index + 1}" />
                                            <c:set var="growthPct" value="${svc.usageGrowthPercent}" />
                                            <c:set var="trend" value="${svc.growthTrend}" />
                                            <c:set var="rowClass" value="" />
                                            <c:if test="${svc.usageToday == 0 && svc.totalUsage > 0}">
                                                <c:set var="rowClass" value="low-perf-row" />
                                            </c:if>
                                            <tr class="${rowClass}">
                                                <td style="color:var(--c-muted);width:36px;">${rowIndex}</td>
                                                <td>
                                                    <code style="font-size:0.75rem;background:var(--pink-50);color:var(--pink-700);padding:2px 6px;border-radius:4px;">
                                                        ${svc.serviceCode}
                                                    </code>
                                                </td>
                                                <td style="font-weight:600;max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"
                                                    title="${svc.serviceName}">
                                                    ${svc.serviceName}
                                                </td>
                                                <td style="font-size:0.8rem;color:var(--c-muted);">
                                                    <c:if test="${not empty svc.categoryIcon}">
                                                        <i class="bi ${svc.categoryIcon} me-1"></i>
                                                    </c:if>
                                                    ${svc.categoryName}
                                                </td>
                                                <td class="text-end" style="font-weight:600;white-space:nowrap;">
                                                    <fmt:formatNumber value="${svc.price}" pattern="#,###" /> đ
                                                </td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${svc.usageToday > 0}">
                                                            <span style="font-weight:700;color:var(--c-primary);">${svc.usageToday}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color:var(--c-muted);">0</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${svc.usageYesterday > 0}">
                                                            <span style="color:var(--c-muted);">${svc.usageYesterday}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color:var(--c-muted);">0</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <span class="growth-indicator ${trend}">
                                                        <c:choose>
                                                            <c:when test="${trend == 'up'}">
                                                                <i class="bi bi-arrow-up-short"></i>
                                                            </c:when>
                                                            <c:when test="${trend == 'down'}">
                                                                <i class="bi bi-arrow-down-short"></i>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="bi bi-dash"></i>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <fmt:formatNumber value="${growthPct}" pattern="#,###.#" />%
                                                    </span>
                                                </td>
                                                <td class="text-end" style="font-weight:600;">
                                                    <c:choose>
                                                        <c:when test="${svc.revenueToday > 0}">
                                                            <fmt:formatNumber value="${svc.revenueToday}" pattern="#,###" /> đ
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color:var(--c-muted);">—</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <span style="font-weight:600;">${svc.totalUsage}</span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-database"></i>
                                <h6>Chưa có dữ liệu thống kê</h6>
                                <p>Dữ liệu sẽ xuất hiện khi có lịch hẹn và hóa đơn được tạo trong hệ thống.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ═══════════════════════════════════════════════ --%>
    <%-- DỊCH VỤ HIỆU SUẤT THẤP + TOP DOANH THU         --%>
    <%-- ═══════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Dịch vụ hiệu suất thấp (chưa được sử dụng hôm nay) --%>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        Dịch Vụ Chưa Được Sử Dụng Hôm Nay
                    </h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty lowPerformingServices}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th>Mã DV</th>
                                            <th>Tên Dịch Vụ</th>
                                            <th>Nhóm</th>
                                            <th class="text-end">Đơn Giá</th>
                                            <th class="text-center">Tổng Lượt SD</th>
                                            <th class="text-center">Hôm Qua</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="low" items="${lowPerformingServices}">
                                            <tr class="low-perf-row">
                                                <td>
                                                    <code style="font-size:0.7rem;background:var(--pink-50);color:var(--pink-700);padding:2px 6px;border-radius:4px;">
                                                        ${low.serviceCode}
                                                    </code>
                                                </td>
                                                <td style="font-weight:600;">${low.serviceName}</td>
                                                <td style="font-size:0.8rem;color:var(--c-muted);">${low.categoryName}</td>
                                                <td class="text-end" style="font-weight:600;white-space:nowrap;">
                                                    <fmt:formatNumber value="${low.price}" pattern="#,###" /> đ
                                                </td>
                                                <td class="text-center" style="color:var(--c-muted);">${low.totalUsage}</td>
                                                <td class="text-center" style="color:var(--c-muted);">${low.usageYesterday}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-check-circle-fill" style="color:#10b981;"></i>
                                <h6>Tất cả dịch vụ đều được sử dụng hôm nay</h6>
                                <p>Không có dịch vụ nào trong tình trạng không được sử dụng hôm nay.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Top 10 dịch vụ theo tổng doanh thu mọi thời gian --%>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-trophy-fill"></i>
                        Top Dịch Vụ — Tổng Doanh Thu
                    </h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty topServicesByTotalRevenue}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Tên Dịch Vụ</th>
                                            <th>Nhóm</th>
                                            <th class="text-center">Tổng Lượt SD</th>
                                            <th class="text-end">Tổng Doanh Thu</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="top" items="${topServicesByTotalRevenue}" varStatus="loop">
                                            <tr>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${loop.index == 0}">
                                                            <span style="color:#f59e0b;font-size:1.2rem;">🥇</span>
                                                        </c:when>
                                                        <c:when test="${loop.index == 1}">
                                                            <span style="color:#94a3b8;font-size:1.2rem;">🥈</span>
                                                        </c:when>
                                                        <c:when test="${loop.index == 2}">
                                                            <span style="color:#d97706;font-size:1.2rem;">🥉</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color:var(--c-muted);">${loop.index + 1}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="font-weight:600;">${top.serviceName}</td>
                                                <td style="font-size:0.8rem;color:var(--c-muted);">${top.categoryName}</td>
                                                <td class="text-center" style="font-weight:600;">${top.totalUsage}</td>
                                                <td class="text-end" style="font-weight:700;color:#059669;">
                                                    <fmt:formatNumber value="${top.revenueToday}" pattern="#,###" /> đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-graph-up"></i>
                                <h6>Chưa có dữ liệu doanh thu</h6>
                                <p>Bảng xếp hạng sẽ hiển thị khi có hóa đơn được thanh toán.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
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

<%-- ═══════════════════════════════════════════════ --%>
<%-- CHART.JS INITIALIZATION — BIỂU ĐỒ THỐNG KÊ DỊCH VỤ --%>
<%-- ═══════════════════════════════════════════════ --%>
<script>
(function() {
    // Common colors — Pink theme
    var pink500 = '#e91e8c';
    var pink200 = '#ffb3d1';
    var pink100 = '#ffe0ef';
    var categoryColors = [
        '#e91e8c', '#3b82f6', '#10b981', '#f59e0b', '#8b5cf6',
        '#06b6d4', '#ef4444', '#ec4899', '#6366f1', '#14b8a6',
        '#f97316', '#84cc16'
    ];

    // ── 1. Bar Chart: Top dịch vụ theo lượt sử dụng hôm nay ──
    var topUsageCtx = document.getElementById('topUsageChart');
    if (topUsageCtx) {
        new Chart(topUsageCtx, {
            type: 'bar',
            data: {
                labels: [
                    <c:forEach var="svc" items="${topServicesByUsage}" varStatus="s">
                        '${svc.serviceName}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Lượt sử dụng hôm nay',
                    data: [
                        <c:forEach var="svc" items="${topServicesByUsage}" varStatus="s">
                            ${svc.usageToday}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    backgroundColor: pink500,
                    borderColor: '#c2185b',
                    borderWidth: 1,
                    borderRadius: 6,
                    hoverBackgroundColor: '#ff4d94'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                indexAxis: 'y',
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: {
                        beginAtZero: true,
                        ticks: { stepSize: 1, font: { size: 11 } },
                        grid: { color: '#f5dfe9' }
                    },
                    y: {
                        ticks: {
                            font: { size: 11 },
                            callback: function(value) {
                                var label = this.getLabelForValue(value);
                                return label.length > 25 ? label.substring(0, 25) + '...' : label;
                            }
                        },
                        grid: { display: false }
                    }
                }
            }
        });
    }

    // ── 2. Doughnut Chart: Phân bổ doanh thu theo nhóm dịch vụ ──
    var catRevCtx = document.getElementById('categoryRevenueChart');
    if (catRevCtx) {
        new Chart(catRevCtx, {
            type: 'doughnut',
            data: {
                labels: [
                    <c:forEach var="cat" items="${categoryRevenue}" varStatus="s">
                        '${cat.categoryName}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    data: [
                        <c:forEach var="cat" items="${categoryRevenue}" varStatus="s">
                            ${cat.totalRevenue}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    backgroundColor: categoryColors,
                    borderColor: '#ffffff',
                    borderWidth: 2,
                    hoverBorderWidth: 3
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 16,
                            usePointStyle: true,
                            pointStyleWidth: 10,
                            font: { size: 11 },
                            generateLabels: function(chart) {
                                var data = chart.data;
                                return data.labels.map(function(label, i) {
                                    var value = data.datasets[0].data[i];
                                    var total = data.datasets[0].data.reduce(function(a, b) { return a + b; }, 0);
                                    var pct = total > 0 ? Math.round((value / total) * 100) : 0;
                                    return {
                                        text: label + ' (' + pct + '%)',
                                        fillStyle: data.datasets[0].backgroundColor[i],
                                        strokeStyle: data.datasets[0].backgroundColor[i],
                                        hidden: false,
                                        index: i
                                    };
                                });
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(ctx) {
                                var value = ctx.parsed;
                                var total = ctx.dataset.data.reduce(function(a, b) { return a + b; }, 0);
                                var pct = total > 0 ? Math.round((value / total) * 100) : 0;
                                if (value >= 1000000) {
                                    return ' ' + (value/1000000).toFixed(0) + ' Triệu VNĐ (' + pct + '%)';
                                }
                                return ' ' + value.toLocaleString('vi-VN') + ' VNĐ (' + pct + '%)';
                            }
                        }
                    }
                }
            }
        });
    }

    // ── 3. Line Chart: Doanh thu 7 ngày ──
    var rev7Ctx = document.getElementById('revenue7DaysChart');
    if (rev7Ctx) {
        new Chart(rev7Ctx, {
            type: 'line',
            data: {
                labels: [
                    <c:forEach var="lbl" items="${revenue7DaysLabels}" varStatus="s">
                        '${lbl}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Doanh thu (VNĐ)',
                    data: [
                        <c:forEach var="val" items="${revenue7DaysValues}" varStatus="s">
                            ${val}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    borderColor: pink500,
                    backgroundColor: 'rgba(233,30,140,0.08)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: pink500,
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                if (value >= 1000000000) return (value/1000000000).toFixed(1) + 'B';
                                if (value >= 1000000) return (value/1000000).toFixed(0) + 'M';
                                if (value >= 1000) return (value/1000).toFixed(0) + 'K';
                                return value;
                            },
                            font: { size: 11 }
                        },
                        grid: { color: '#f5dfe9' }
                    },
                    x: {
                        ticks: { font: { size: 11 } },
                        grid: { display: false }
                    }
                }
            }
        });
    }

    // ── 4. Line Chart: Doanh thu 12 tháng ──
    var rev12Ctx = document.getElementById('revenue12MonthsChart');
    if (rev12Ctx) {
        new Chart(rev12Ctx, {
            type: 'line',
            data: {
                labels: [
                    <c:forEach var="lbl" items="${revenue12MonthsLabels}" varStatus="s">
                        '${lbl}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Doanh thu (VNĐ)',
                    data: [
                        <c:forEach var="val" items="${revenue12MonthsValues}" varStatus="s">
                            ${val}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    borderColor: '#3b82f6',
                    backgroundColor: 'rgba(59,130,246,0.06)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#3b82f6',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    pointHoverRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                if (value >= 1000000000) return (value/1000000000).toFixed(1) + 'B';
                                if (value >= 1000000) return (value/1000000).toFixed(0) + 'M';
                                if (value >= 1000) return (value/1000).toFixed(0) + 'K';
                                return value;
                            },
                            font: { size: 11 }
                        },
                        grid: { color: '#f5dfe9' }
                    },
                    x: {
                        ticks: { font: { size: 11 }, maxRotation: 45 },
                        grid: { display: false }
                    }
                }
            }
        });
    }
})();
</script>

</body>
</html>
