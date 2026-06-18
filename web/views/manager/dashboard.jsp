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
        .kpi-card.kpi-active-svc .card-body { border-top: 3px solid var(--pink-600) !important; }
        .kpi-card.kpi-active-med .card-body { border-top: 3px solid #9c0f6e !important; }

        .kpi-icon {
            width: 52px; height: 52px; border-radius: var(--r-md);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.35rem; flex-shrink: 0;
        }
        .kpi-services .kpi-icon    { background: var(--pink-100); color: var(--pink-600); }
        .kpi-medicines .kpi-icon   { background: #fce4f3; color: #9c0f6e; }
        .kpi-active-svc .kpi-icon  { background: var(--pink-50); color: var(--pink-700); }
        .kpi-active-med .kpi-icon  { background: #f3e5f5; color: #7b1fa2; }

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

        /* ── Live Dashboard Widgets (Top Services + Low Stock) ── */
        .live-widget .card-header {
            background: linear-gradient(135deg, #fff0f6, #fce4ec);
            border-bottom: 1px solid var(--pink-200);
            padding: 0.85rem 1.2rem;
            display: flex; align-items: center; justify-content: space-between;
        }
        .live-widget .card-header h5 {
            margin: 0; font-family: var(--font-display); font-weight: 700;
            color: var(--c-primary-dark); font-size: 0.95rem;
        }
        .live-widget .admin-table { font-size: 0.82rem; margin: 0; }
        .live-widget .admin-table th {
            background: var(--c-surface-variant);
            color: var(--c-on-surface-var);
            font-weight: 700; font-size: 0.7rem;
            text-transform: uppercase; letter-spacing: 0.05em;
            padding: 0.55rem 0.75rem;
            border-bottom: 2px solid var(--c-outline);
        }
        .live-widget .admin-table td {
            padding: 0.55rem 0.75rem;
            border-bottom: 1px solid var(--c-outline-variant);
            vertical-align: middle;
        }
        .live-widget .admin-table tbody tr { transition: background var(--t-fast); }
        .live-widget .admin-table tbody tr:hover { background: #fff5f9; }

        /* Usage rank number */
        .usage-rank {
            display: inline-flex; align-items: center; justify-content: center;
            width: 24px; height: 24px; border-radius: 50%;
            font-size: 0.7rem; font-weight: 800; color: #fff; flex-shrink: 0;
        }
        .usage-rank.r1 { background: #e91e63; }
        .usage-rank.r2 { background: #ec407a; }
        .usage-rank.r3 { background: #f06292; }
        .usage-rank.rn { background: #f48fb1; }

        /* Usage count badge */
        .usage-badge-live {
            font-family: var(--font-display); font-weight: 800; font-size: 0.95rem;
            color: var(--c-on-surface);
        }

        /* Growth trend indicators */
        .trend-up    { color: #059669; font-weight: 700; font-size: 0.72rem; }
        .trend-down  { color: #dc2626; font-weight: 700; font-size: 0.72rem; }
        .trend-stable{ color: var(--c-muted); font-weight: 600; font-size: 0.72rem; }

        /* Stock status badges */
        .stock-out   { background: #ffebee; color: #c62828; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.68rem; font-weight: 700; white-space: nowrap; }
        .stock-low   { background: #fff3e0; color: #e65100; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.68rem; font-weight: 700; white-space: nowrap; }
        .stock-ok    { background: #fff8e1; color: #f57f17; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.68rem; font-weight: 700; white-space: nowrap; }
        .stock-qty   { font-family: var(--font-display); font-weight: 800; font-size: 0.9rem; }

        /* Revenue comparison */
        .revenue-compare {
            display: flex; align-items: center; gap: 0.4rem; margin-top: 0.15rem;
            font-size: 0.68rem;
        }
        .rev-yesterday { color: var(--c-muted); }
        .rev-arrow-up   { color: #059669; font-weight: 700; }
        .rev-arrow-down { color: #dc2626; font-weight: 700; }

        .btn-sm-outline-pink {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.3rem 0.75rem; border-radius: var(--r-sm);
            font-size: 0.75rem; font-weight: 600;
            background: #fff; border: 1.5px solid var(--pink-300);
            color: var(--pink-600); text-decoration: none;
            transition: all var(--t-fast); white-space: nowrap;
        }
        .btn-sm-outline-pink:hover {
            background: var(--pink-50); border-color: var(--pink-500);
            color: var(--pink-600);
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
            <p>Chào mừng bạn đến với bảng điều khiển Quản Lý. Quản lý dịch vụ y tế, danh mục thuốc và lịch trực bác sĩ của phòng khám.</p>
        </div>
        <span class="badge-role">
            <i class="bi bi-briefcase-fill"></i>
            Quản Lý
        </span>
    </div>

    <%-- 6 KPI CARDS — Manager Focus (Quản lý + Thống kê dịch vụ) --%>
    <div class="row g-3 mb-4">
        <div class="col-xl-2 col-lg-4 col-md-6">
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
        <div class="col-xl-2 col-lg-4 col-md-6">
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
        <div class="col-xl-2 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-active-med fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-capsule-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty activeMedicinesCount ? activeMedicinesCount : 0}</div>
                        <div class="kpi-label">Thuốc Đang Sử Dụng</div>
                        <div class="kpi-sub"><i class="bi bi-check-circle-fill"></i> Còn hiệu lực</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-2 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-active-svc fade-in-up">
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

        <%-- KPI Thống kê: Lượt sử dụng hôm nay --%>
        <div class="col-xl-2 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-stat-usage fade-in-up" style="--kpi-accent:#3b82f6;">
                <div class="card-body" style="border-top:3px solid #3b82f6 !important;">
                    <div class="kpi-icon" style="background:#dbeafe;color:#2563eb;"><i class="bi bi-people-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalUsageToday ? totalUsageToday : 0}</div>
                        <div class="kpi-label">Lượt SD Hôm Nay</div>
                        <div class="kpi-sub"><i class="bi bi-calendar-check"></i> Dịch vụ</div>
                    </div>
                </div>
            </div>
        </div>

        <%-- KPI Thống kê: Doanh thu hôm nay + so sánh hôm qua --%>
        <div class="col-xl-2 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-stat-revenue fade-in-up" style="--kpi-accent:#10b981;">
                <div class="card-body" style="border-top:3px solid #10b981 !important;">
                    <div class="kpi-icon" style="background:#d1fae5;color:#059669;"><i class="bi bi-cash-stack"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value" style="font-size:1.05rem;">${not empty totalRevenueTodayFormatted ? totalRevenueTodayFormatted : '0'}</div>
                        <div class="kpi-label">Doanh Thu Hôm Nay</div>
                        <div class="revenue-compare">
                            <span class="rev-yesterday">
                                <i class="bi bi-clock-history me-1"></i>H.qua ${not empty revenueYesterdayFormatted ? revenueYesterdayFormatted : '0'}
                            </span>
                            <c:choose>
                                <c:when test="${revenueGrowthRate > 0}">
                                    <span class="rev-arrow-up"><i class="bi bi-arrow-up-short"></i><fmt:formatNumber value="${revenueGrowthRate}" maxFractionDigits="1"/>%</span>
                                </c:when>
                                <c:when test="${revenueGrowthRate < 0}">
                                    <span class="rev-arrow-down"><i class="bi bi-arrow-down-short"></i><fmt:formatNumber value="${revenueGrowthRate * -1}" maxFractionDigits="1"/>%</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color:var(--c-muted);font-size:0.68rem;">→ 0%</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ============================================================
         LIVE WIDGETS — Dữ liệu thực tế hôm nay, có giá trị hành động
         ============================================================ --%>
    <div class="row g-3 mb-4">
        <%-- WIDGET 1: Top Dịch Vụ Được Đặt Nhiều Hôm Nay --%>
        <div class="col-xl-6">
            <div class="admin-card live-widget h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-fire me-2" style="color:#e91e63;"></i>
                        Dịch Vụ Được Đặt Nhiều Hôm Nay
                    </h5>
                    <a href="${pageContext.request.contextPath}/manager/statistics/" class="btn-sm-outline-pink">
                        Thống kê <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="card-body p-0">
                    <div class="admin-table-wrapper">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th style="width:36px;">#</th>
                                    <th>Dịch Vụ</th>
                                    <th style="width:75px;">Lượt SD</th>
                                    <th style="width:90px;">Xu Hướng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty topServicesToday}">
                                        <c:forEach var="svc" items="${topServicesToday}" varStatus="loop">
                                            <tr>
                                                <td>
                                                    <c:set var="rank" value="${loop.index + 1}"/>
                                                    <span class="usage-rank ${rank == 1 ? 'r1' : (rank == 2 ? 'r2' : (rank == 3 ? 'r3' : 'rn'))}">${rank}</span>
                                                </td>
                                                <td>
                                                    <div style="font-weight:600;color:var(--c-on-surface);">
                                                        ${fn:escapeXml(svc.serviceName)}
                                                    </div>
                                                    <c:if test="${not empty svc.categoryName}">
                                                        <small style="font-size:0.68rem;color:var(--c-muted);">
                                                            <i class="bi bi-folder me-1"></i>${fn:escapeXml(svc.categoryName)}
                                                        </small>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <span class="usage-badge-live">${svc.usageToday}</span>
                                                    <span style="font-size:0.7rem;color:var(--c-muted);">lượt</span>
                                                </td>
                                                <td>
                                                    <c:set var="trend" value="${svc.growthTrend}"/>
                                                    <c:choose>
                                                        <c:when test="${trend eq 'up'}">
                                                            <span class="trend-up"><i class="bi bi-arrow-up-short"></i> ↑<fmt:formatNumber value="${svc.usageGrowthPercent}" maxFractionDigits="0"/>%</span>
                                                        </c:when>
                                                        <c:when test="${trend eq 'down'}">
                                                            <span class="trend-down"><i class="bi bi-arrow-down-short"></i> ↓<fmt:formatNumber value="${svc.usageGrowthPercent * -1}" maxFractionDigits="0"/>%</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="trend-stable"><i class="bi bi-dash"></i> ổn định</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4">
                                                <div class="admin-empty-state" style="padding:1.5rem;">
                                                    <i class="bi bi-bar-chart" style="font-size:1.8rem;color:var(--c-muted);"></i>
                                                    <p class="text-muted mt-1 mb-0" style="font-size:0.8rem;">Chưa có lượt sử dụng dịch vụ nào hôm nay.</p>
                                                    <small style="font-size:0.7rem;color:var(--c-muted);">Dữ liệu sẽ xuất hiện khi có bệnh nhân đặt lịch.</small>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <%-- WIDGET 2: Cảnh Báo Tồn Kho Thuốc --%>
        <div class="col-xl-6">
            <div class="admin-card live-widget h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-exclamation-triangle-fill me-2" style="color:#e65100;"></i>
                        Cảnh Báo Tồn Kho Thuốc
                    </h5>
                    <a href="${pageContext.request.contextPath}/manager/medicines/" class="btn-sm-outline-pink">
                        Quản lý kho <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="card-body p-0">
                    <div class="admin-table-wrapper">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Thuốc</th>
                                    <th style="width:80px;">Tồn Kho</th>
                                    <th style="width:100px;">Đơn Giá</th>
                                    <th style="width:110px;">Trạng Thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty lowStockMedicines}">
                                        <c:forEach var="med" items="${lowStockMedicines}">
                                            <tr>
                                                <td>
                                                    <div style="font-weight:600;color:var(--c-on-surface);">
                                                        <i class="bi bi-capsule-fill me-1" style="color:#ce3fa7;font-size:0.8rem;"></i>
                                                        ${fn:escapeXml(med.name)}
                                                    </div>
                                                    <c:if test="${not empty med.dosage}">
                                                        <small style="font-size:0.68rem;color:var(--c-muted);">
                                                            ${fn:escapeXml(med.dosage)} — ${fn:escapeXml(med.unit)}
                                                        </small>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${med.stockQuantity <= 0}">
                                                            <span class="stock-qty" style="color:#c62828;">0</span>
                                                        </c:when>
                                                        <c:when test="${med.stockQuantity <= 3}">
                                                            <span class="stock-qty" style="color:#c62828;">${med.stockQuantity}</span>
                                                        </c:when>
                                                        <c:when test="${med.stockQuantity <= 7}">
                                                            <span class="stock-qty" style="color:#e65100;">${med.stockQuantity}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="stock-qty" style="color:#f57f17;">${med.stockQuantity}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <span style="font-size:0.7rem;color:var(--c-muted);"> ${fn:escapeXml(med.unit)}</span>
                                                </td>
                                                <td>
                                                    <span style="font-family:var(--font-display);font-weight:700;font-size:0.82rem;color:#9c0f6e;white-space:nowrap;">
                                                        <fmt:formatNumber value="${med.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${med.stockQuantity <= 0}">
                                                            <span class="stock-out"><i class="bi bi-x-circle-fill me-1"></i>HẾT HÀNG</span>
                                                        </c:when>
                                                        <c:when test="${med.stockQuantity <= 3}">
                                                            <span class="stock-low"><i class="bi bi-exclamation-circle-fill me-1"></i>Sắp hết</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="stock-ok"><i class="bi bi-dash-circle-fill me-1"></i>Còn ít</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4">
                                                <div class="admin-empty-state" style="padding:1.5rem;">
                                                    <i class="bi bi-check-circle" style="font-size:1.8rem;color:#2e7d32;"></i>
                                                    <p class="text-muted mt-1 mb-0" style="font-size:0.8rem;color:#2e7d32 !important;">
                                                        <strong>Tất cả thuốc đều đủ tồn kho.</strong>
                                                    </p>
                                                    <small style="font-size:0.7rem;color:var(--c-muted);">Không có thuốc nào dưới ngưỡng cảnh báo (≤10).</small>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
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
                        <div class="col-md-4 col-sm-6">
                            <a href="${pageContext.request.contextPath}/manager/services/" class="quick-action-btn">
                                <span class="quick-action-icon"><i class="bi bi-activity"></i></span>
                                <span class="quick-action-text">
                                    <span>Dịch Vụ Y Tế</span>
                                    <small>Thêm, sửa, quản lý dịch vụ &amp; đơn giá</small>
                                </span>
                            </a>
                        </div>
                        <div class="col-md-4 col-sm-6">
                            <a href="${pageContext.request.contextPath}/manager/medicines/" class="quick-action-btn">
                                <span class="quick-action-icon"><i class="bi bi-capsule"></i></span>
                                <span class="quick-action-text">
                                    <span>Danh Mục Thuốc</span>
                                    <small>Quản lý kho thuốc &amp; giá</small>
                                </span>
                            </a>
                        </div>
                        <div class="col-md-4 col-sm-6">
                            <a href="${pageContext.request.contextPath}/manager/statistics/" class="quick-action-btn">
                                <span class="quick-action-icon"><i class="bi bi-file-earmark-bar-graph"></i></span>
                                <span class="quick-action-text">
                                    <span>Thống Kê Dịch Vụ</span>
                                    <small>KPI, biểu đồ &amp; phân tích</small>
                                </span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- QUICK STATS — Thống kê nhanh + Thông tin dịch vụ --%>
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
                        <c:if test="${not empty topServiceName && topServiceUsage > 0}">
                            <li class="activity-item">
                                <span class="activity-dot create"></span>
                                <div class="activity-body">
                                    <div class="act-title">
                                        <strong>${topServiceName}</strong> — dịch vụ được sử dụng nhiều nhất hôm nay
                                    </div>
                                    <div class="act-meta">
                                        <span><i class="bi bi-bar-chart-fill me-1"></i>${topServiceUsage} lượt hôm nay</span>
                                        <span><i class="bi bi-clock me-1"></i>Top 1</span>
                                    </div>
                                </div>
                            </li>
                        </c:if>
                        <li class="activity-item">
                            <span class="activity-dot update"></span>
                            <div class="activity-body">
                                <div class="act-title">
                                    <strong>${not empty totalUsageToday ? totalUsageToday : 0} lượt</strong> sử dụng dịch vụ được ghi nhận hôm nay
                                </div>
                                <div class="act-meta">
                                    <span><i class="bi bi-people me-1"></i>${not empty servicesUsedToday ? servicesUsedToday : 0} loại dịch vụ</span>
                                    <span><i class="bi bi-clock me-1"></i>Hôm nay</span>
                                </div>
                            </div>
                        </li>
                        <li class="activity-item">
                            <span class="activity-dot create"></span>
                            <div class="activity-body">
                                <div class="act-title">
                                    <c:choose>
                                        <c:when test="${usageGrowthRate > 0}">
                                            <span style="color:#059669;">Tăng <strong>${usageGrowthFormatted}</strong></span> lượt sử dụng so với hôm qua
                                        </c:when>
                                        <c:when test="${usageGrowthRate < 0}">
                                            <span style="color:#dc2626;">Giảm <strong>${usageGrowthFormatted}</strong></span> lượt sử dụng so với hôm qua
                                        </c:when>
                                        <c:otherwise>
                                            Lượt sử dụng <strong>không đổi</strong> so với hôm qua
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="act-meta">
                                    <span><i class="bi bi-graph-up-arrow me-1"></i>Tăng trưởng</span>
                                    <span><i class="bi bi-clock me-1"></i>24h qua</span>
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
                            <div class="stat-mini-label">Dịch Vụ Y Tế</div>
                            <div class="stat-mini-sub">Thêm / sửa / ẩn<br>dịch vụ &amp; đơn giá</div>
                        </div>
                        <div class="stat-mini">
                            <span class="stat-mini-icon" style="color:var(--pink-500);"><i class="bi bi-2-circle-fill"></i></span>
                            <div class="stat-mini-label">Danh Mục Thuốc</div>
                            <div class="stat-mini-sub">Quản lý danh mục<br>&amp; tồn kho thuốc</div>
                        </div>
                        <div class="stat-mini">
                            <span class="stat-mini-icon" style="color:#3b82f6;"><i class="bi bi-3-circle-fill"></i></span>
                            <div class="stat-mini-label">Thống Kê</div>
                            <div class="stat-mini-sub">Phân tích KPI<br>dịch vụ &amp; doanh thu</div>
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
                                        <i class="bi bi-file-earmark-bar-graph me-2" style="color:#3b82f6;"></i>Thống Kê
                                    </td>
                                    <td style="color:var(--c-muted);">Thống kê, KPI &amp; phân tích dịch vụ y tế</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/manager/statistics/"
                                           style="color:var(--pink-500);font-weight:600;text-decoration:none;">
                                            /manager/statistics &rarr;
                                        </a>
                                    </td>
                                    <td><span class="badge-status badge-status-active">Hoạt động</span></td>
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
