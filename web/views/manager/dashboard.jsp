<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tổng Quan Quản Lý — CAMS</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>

    <!-- Admin CSS (dùng chung nền Pink) -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        /* ============================================================
           CAMS Manager — Business Operations Dashboard v5.0
           Focus: Patients, Appointments, Revenue, Doctors, Services
           ============================================================ */

        :root {
            --sidebar-w: 270px;
            --topbar-h: 66px;
            --pink-50:  #F0F7FF;
            --pink-100: #E0EFFF;
            --pink-200: #BFDBFE;
            --pink-300: #93C5FD;
            --pink-400: #60A5FA;
            --pink-500: #3B82F6;
            --pink-600: #2563EB;
            --pink-700: #1D4ED8;
            --pink-800: #1D4ED8;
            --rose-400: #93C5FD;
            --rose-500: #60A5FA;
            --rose-600: #3B82F6;

            --c-bg:              #EFF6FF;
            --c-surface:         #ffffff;
            --c-surface-variant: #E0EFFF;
            --c-primary:         #2563EB;
            --c-primary-light:   #60A5FA;
            --c-primary-dark:    #1D4ED8;
            --c-on-bg:           #0F172A;
            --c-on-surface:      #1E293B;
            --c-on-surface-var:  #475569;
            --c-muted:           #94A3B8;
            --c-outline:         #BFDBFE;
            --c-outline-variant: #DBEAFE;

            --green-500: #10b981;  --green-100: #d1fae5;  --green-700: #065f46;
            --amber-500: #f59e0b;  --amber-100: #fef3c7;  --amber-700: #92400e;
            --blue-500:  #3b82f6;  --blue-100:  #dbeafe;  --blue-700:  #1e40af;
            --purple-500:#8b5cf6;  --purple-100:#ede9fe;  --purple-700:#5b21b6;
            --cyan-500:  #06b6d4;  --cyan-100:  #cffafe;  --cyan-700:  #155e75;
            --red-500:   #ef4444;  --red-100:   #fee2e2;  --red-700:   #991b1b;

            --shadow-xs:   0 1px 3px rgba(37,99,235,0.07);
            --shadow-sm:   0 2px 8px rgba(37,99,235,0.10);
            --shadow-md:   0 4px 20px rgba(37,99,235,0.13);
            --shadow-pink: 0 4px 24px rgba(37,99,235,0.30);

            --r-sm: 8px; --r-md: 12px; --r-lg: 16px; --r-xl: 22px; --r-pill: 999px;
            --t-fast: 0.15s ease; --t-normal: 0.25s ease;
            --t-slow: 0.35s cubic-bezier(0.4,0,0.2,1);
            --font-display: 'Nunito', 'Be Vietnam Pro', sans-serif;
            --font-body:    'Inter', 'Be Vietnam Pro', sans-serif;
        }

        *, *::before, *::after { box-sizing: border-box; }
        html { scroll-behavior: smooth; }
        body, .btn, .form-control, .table, .badge, .card { font-family: var(--font-body); }
        h1,h2,h3,h4,h5,h6 { font-family: var(--font-display); }
        .card { border: none; box-shadow: none; background: transparent; }

        body.admin-body {
            font-family: var(--font-body);
            background: var(--c-bg);
            color: var(--c-on-bg);
            margin: 0; padding: 0;
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
        }

        /* ── KPI Cards ── */
        .kpi-card {
            background: var(--c-surface) !important;
            border-radius: var(--r-lg) !important;
            border: 1px solid var(--c-outline-variant) !important;
            box-shadow: var(--shadow-sm) !important;
            overflow: hidden;
            transition: transform var(--t-normal), box-shadow var(--t-normal);
            height: 100%;
        }
        .kpi-card:hover { transform: translateY(-4px); box-shadow: var(--shadow-md) !important; }
        .kpi-card .card-body {
            padding: 1.25rem 1.25rem !important;
            display: flex !important; align-items: center !important; gap: 1rem !important;
        }
        .kpi-icon {
            width: 52px; height: 52px; border-radius: var(--r-md);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem; flex-shrink: 0;
        }
        .kpi-content { flex: 1; min-width: 0; }
        .kpi-value {
            font-family: var(--font-display); font-size: 1.75rem; font-weight: 900;
            color: var(--c-on-surface); line-height: 1.1; letter-spacing: -0.04em;
        }
        .kpi-label { font-size: 0.8rem; font-weight: 600; color: var(--c-on-surface-var); margin-top: 0.15rem; }
        .kpi-sub {
            font-size: 0.7rem; font-weight: 500; color: var(--c-muted);
            display: flex; align-items: center; gap: 0.3rem; margin-top: 0.25rem;
        }

        /* KPI màu phân biệt theo vai trò từng chỉ số */
        .kpi-appointments .card-body { border-top: 3px solid #3B82F6 !important; }
        .kpi-appointments .kpi-icon { background: #DBEAFE; color: #2563EB; }
        .kpi-waiting .card-body    { border-top: 3px solid #F59E0B !important; }
        .kpi-waiting .kpi-icon     { background: #FEF3C7; color: #D97706; }
        .kpi-doctors .card-body    { border-top: 3px solid #10B981 !important; }
        .kpi-doctors .kpi-icon     { background: #D1FAE5; color: #059669; }
        .kpi-ultrasound .card-body { border-top: 3px solid #8B5CF6 !important; }
        .kpi-ultrasound .kpi-icon  { background: #EDE9FE; color: #6D28D9; }
        .kpi-revenue .card-body    { border-top: 3px solid #059669 !important; }
        .kpi-revenue .kpi-icon     { background: #D1FAE5; color: #047857; }
        .kpi-completed .card-body  { border-top: 3px solid #06B6D4 !important; }
        .kpi-completed .kpi-icon   { background: #CFFAFE; color: #0891B2; }

        /* Service/Medicine KPI (Manager's own domain) */
        .kpi-services  .card-body { border-top: 3px solid #6366F1 !important; }
        .kpi-services  .kpi-icon { background: #E0E7FF; color: #4F46E5; }
        .kpi-medicines .card-body { border-top: 3px solid #14B8A6 !important; }
        .kpi-medicines .kpi-icon { background: #CCFBF1; color: #0D9488; }

        /* ── Admin Card ── */
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

        /* ── Chart ── */
        .chart-container { position: relative; width: 100%; }
        .chart-container canvas { width: 100% !important; }

        /* ── Table ── */
        .admin-table-wrapper { overflow-x: auto; }
        .admin-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
        .admin-table thead th {
            font-family: var(--font-display); font-size: 0.7rem; font-weight: 800;
            text-transform: uppercase; letter-spacing: 0.07em;
            color: var(--c-primary); padding: 0.75rem 0.875rem;
            background: var(--pink-50); border-bottom: 2px solid var(--pink-200); white-space: nowrap;
        }
        .admin-table tbody tr { border-bottom: 1px solid var(--c-outline-variant); transition: background var(--t-fast); }
        .admin-table tbody tr:hover { background: var(--pink-50); }
        .admin-table tbody td { padding: 0.7rem 0.875rem; color: var(--c-on-surface); vertical-align: middle; }
        .admin-table.compact thead th { padding: 0.55rem 0.75rem; font-size: 0.65rem; }
        .admin-table.compact tbody td { padding: 0.5rem 0.75rem; font-size: 0.8rem; }

        /* ── Badges ── */
        .badge-status {
            display: inline-block; padding: 3px 10px; border-radius: var(--r-pill);
            font-size: 0.7rem; font-weight: 700;
        }
        .badge-approved  { background: #d1fae5; color: #065f46; }
        .badge-pending   { background: #fef3c7; color: #92400e; }
        .badge-active    { background: #d1fae5; color: #065f46; }
        .badge-role-tag  {
            display: inline-block; padding: 2px 10px; border-radius: var(--r-pill);
            font-size: 0.7rem; font-weight: 700;
            background: var(--pink-100); color: var(--pink-700); border: 1px solid var(--pink-200);
        }

        /* ── Alerts ── */
        .alert-item {
            display: flex; align-items: flex-start; gap: 0.75rem;
            padding: 0.75rem; border-radius: var(--r-md);
            margin-bottom: 0.5rem; transition: background var(--t-fast);
        }
        .alert-item:last-child { margin-bottom: 0; }
        .alert-item.warning { background: #fffbeb; border: 1px solid #fde68a; }
        .alert-item.danger  { background: #fef2f2; border: 1px solid #fecaca; }
        .alert-item.info   { background: #eff6ff; border: 1px solid #bfdbfe; }
        .alert-item .alert-icon {
            width: 36px; height: 36px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem; flex-shrink: 0;
        }
        .alert-item.warning .alert-icon { background: #fef3c7; color: #d97706; }
        .alert-item.danger  .alert-icon { background: #fee2e2; color: #dc2626; }
        .alert-item.info   .alert-icon { background: #dbeafe; color: #2563eb; }
        .alert-item .alert-body { flex: 1; min-width: 0; }
        .alert-item .alert-title { font-size: 0.8rem; font-weight: 700; color: var(--c-on-surface); margin-bottom: 2px; }
        .alert-item .alert-msg { font-size: 0.75rem; color: var(--c-muted); }
        .alert-item .alert-count {
            font-family: var(--font-display); font-size: 1.1rem; font-weight: 900;
            padding: 0.25rem 0.6rem; border-radius: var(--r-pill); flex-shrink: 0;
        }
        .alert-item.warning .alert-count { background: #fde68a; color: #92400e; }
        .alert-item.danger  .alert-count { background: #fecaca; color: #991b1b; }
        .alert-item.info   .alert-count { background: #bfdbfe; color: #1e40af; }

        /* ── Slots Bar ── */
        .slots-bar { display: flex; align-items: center; gap: 0.5rem; }
        .slots-bar .progress {
            flex: 1; height: 6px; background: var(--pink-100); border-radius: 3px; overflow: hidden;
        }
        .slots-bar .progress .progress-bar {
            height: 100%; border-radius: 3px;
            background: linear-gradient(90deg, var(--pink-400), var(--pink-500));
            transition: width var(--t-slow);
        }
        .slots-bar .progress .progress-bar.full {
            background: linear-gradient(90deg, var(--rose-400), var(--rose-600));
        }
        .slots-bar .slots-text {
            font-size: 0.75rem; font-weight: 700; color: var(--c-on-surface-var); white-space: nowrap;
        }

        /* ── Empty State ── */
        .admin-empty-state { text-align: center; padding: 2.5rem 1rem; color: var(--c-muted); }
        .admin-empty-state i { font-size: 2.5rem; color: var(--pink-200); display: block; margin-bottom: 0.75rem; }
        .admin-empty-state h6 { font-family: var(--font-display); font-weight: 700; color: var(--c-on-surface-var); margin-bottom: 0.25rem; }
        .admin-empty-state p { font-size: 0.85rem; margin: 0; }

        /* ── Activity Feed ── */
        .activity-feed { list-style: none; padding: 0; margin: 0; }
        .activity-item {
            display: flex; align-items: flex-start; gap: 0.75rem;
            padding: 0.65rem 0;
            border-bottom: 1px solid var(--c-outline-variant);
        }
        .activity-item:last-child { border-bottom: none; }
        .activity-dot {
            width: 8px; height: 8px; border-radius: 50%;
            margin-top: 0.4rem; flex-shrink: 0;
        }
        .activity-dot.create  { background: #2e7d32; box-shadow: 0 0 0 3px rgba(46,125,50,0.15); }
        .activity-dot.update  { background: #3b82f6; box-shadow: 0 0 0 3px rgba(59,130,246,0.15); }
        .activity-body { flex: 1; min-width: 0; }
        .activity-body .act-title { font-size: 0.82rem; font-weight: 600; color: var(--c-on-surface); }
        .activity-body .act-meta  { font-size: 0.7rem; color: var(--c-muted); margin-top: 0.15rem; display: flex; gap: 0.75rem; }

        /* ── Quick Actions ── */
        .quick-action-btn {
            display: flex; align-items: center; gap: 0.75rem;
            padding: 0.875rem 1rem; border-radius: var(--r-md);
            background: var(--c-surface-variant); border: 1px solid var(--c-outline-variant);
            text-decoration: none; transition: all var(--t-fast); height: 100%;
        }
        .quick-action-btn:hover {
            background: var(--pink-50); border-color: var(--pink-200);
            transform: translateY(-2px); box-shadow: var(--shadow-sm);
        }
        .quick-action-icon {
            width: 40px; height: 40px; border-radius: var(--r-sm);
            background: var(--pink-100); color: var(--pink-600);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem; flex-shrink: 0;
        }
        .quick-action-text { display: flex; flex-direction: column; }
        .quick-action-text span { font-size: 0.85rem; font-weight: 700; color: var(--c-on-surface); }
        .quick-action-text small { font-size: 0.7rem; color: var(--c-muted); margin-top: 0.1rem; }

        /* ── Usage Rank ── */
        .usage-rank {
            display: inline-flex; align-items: center; justify-content: center;
            width: 24px; height: 24px; border-radius: 50%;
            font-size: 0.7rem; font-weight: 800; color: #fff; flex-shrink: 0;
        }
        .usage-rank.r1 { background: #3B82F6; }
        .usage-rank.r2 { background: #ec407a; }
        .usage-rank.r3 { background: #60A5FA; }
        .usage-rank.rn { background: #f48fb1; }

        /* ── Revenue Compare ── */
        .revenue-compare {
            display: flex; align-items: center; gap: 0.4rem; margin-top: 0.15rem;
            font-size: 0.68rem;
        }
        .rev-yesterday { color: var(--c-muted); }
        .rev-arrow-up   { color: #059669; font-weight: 700; }
        .rev-arrow-down { color: #dc2626; font-weight: 700; }

        .trend-up    { color: #059669; font-weight: 700; font-size: 0.72rem; }
        .trend-down  { color: #dc2626; font-weight: 700; font-size: 0.72rem; }
        .trend-stable{ color: var(--c-muted); font-weight: 600; font-size: 0.72rem; }

        /* ── Stock Badges ── */
        .stock-out   { background: #ffebee; color: #c62828; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.68rem; font-weight: 700; white-space: nowrap; }
        .stock-low   { background: #fff3e0; color: #e65100; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.68rem; font-weight: 700; white-space: nowrap; }
        .stock-ok    { background: #fff8e1; color: #f57f17; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.68rem; font-weight: 700; white-space: nowrap; }

        .btn-sm-outline-pink {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.3rem 0.75rem; border-radius: var(--r-sm);
            font-size: 0.75rem; font-weight: 600;
            background: #fff; border: 1.5px solid var(--pink-300);
            color: var(--pink-600); text-decoration: none;
            transition: all var(--t-fast); white-space: nowrap;
        }
        .btn-sm-outline-pink:hover { background: var(--pink-50); border-color: var(--pink-500); }

        /* ── Date Filter ── */
        .header-date-filter { display: flex; align-items: center; gap: 0.5rem; flex-wrap: wrap; }
        .header-date-filter .date-input-group {
            display: flex; align-items: center; gap: 0.3rem;
            background: var(--c-surface);
            border: 1.5px solid var(--c-outline);
            border-radius: var(--r-pill);
            padding: 0.3rem 0.3rem 0.3rem 0.75rem;
            transition: all var(--t-slow);
            box-shadow: var(--shadow-xs);
        }
        .header-date-filter .date-input-group:focus-within {
            border-color: var(--pink-400);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.08);
        }
        .header-date-filter .date-input-group .date-label {
            font-size: 0.65rem; font-weight: 700; color: var(--c-muted);
            text-transform: uppercase; letter-spacing: 0.04em; white-space: nowrap;
        }
        .header-date-filter .date-input-group input[type="date"] {
            border: none; background: transparent; font-size: 0.78rem;
            font-weight: 600; color: var(--c-on-surface);
            padding: 0.2rem 0.3rem; outline: none; font-family: var(--font-body);
            width: 122px; cursor: pointer;
        }
        .header-date-filter .date-input-group input[type="date"]::-webkit-calendar-picker-indicator {
            cursor: pointer; filter: invert(25%) sepia(60%) saturate(1500%) hue-rotate(305deg) brightness(90%) contrast(95%);
        }
        .header-date-filter .date-separator { font-size: 0.7rem; font-weight: 700; color: var(--c-muted); }
        .btn-header-date {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.4rem 0.9rem; border-radius: var(--r-pill);
            font-size: 0.75rem; font-weight: 700; cursor: pointer;
            transition: all var(--t-fast); white-space: nowrap;
            border: none; text-decoration: none; line-height: 1.4;
        }
        .btn-header-apply {
            background: linear-gradient(135deg, var(--pink-500), var(--pink-600));
            color: #fff; box-shadow: 0 2px 6px rgba(37,99,235,0.2);
        }
        .btn-header-apply:hover { box-shadow: 0 4px 12px rgba(37,99,235,0.35); transform: translateY(-1px); color: #fff; }
        .btn-header-today {
            background: var(--c-surface); color: var(--c-primary);
            border: 1.5px solid var(--pink-200);
        }
        .btn-header-today:hover { background: var(--pink-50); border-color: var(--pink-400); }
        .header-date-badge {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.25rem 0.7rem; border-radius: var(--r-pill);
            font-size: 0.65rem; font-weight: 700; white-space: nowrap;
            letter-spacing: 0.02em;
        }
        .header-date-badge.live { background: #e8f5e9; color: #2e7d32; animation: pulse-live 2.5s infinite; }
        .header-date-badge.history { background: #fff3e0; color: #e65100; }
        @keyframes pulse-live {
            0%, 100% { box-shadow: 0 0 0 0 rgba(46,125,50,0.3); }
            50% { box-shadow: 0 0 0 6px rgba(46,125,50,0); }
        }

        /* ── Responsive ── */
        @media (max-width: 1199.98px) {
            .kpi-card .card-body { padding: 1rem !important; gap: 0.75rem !important; }
            .kpi-value { font-size: 1.4rem; }
            .kpi-icon { width: 42px; height: 42px; font-size: 1.1rem; }
            .header-date-filter { margin-top: 0.5rem; }
            .header-date-filter .date-input-group input[type="date"] { width: 110px; font-size: 0.73rem; }
        }
        @media (max-width: 767.98px) {
            .admin-main { padding: 1rem; }
            .header-date-filter { flex-direction: column; align-items: stretch; width: 100%; }
            .header-date-filter .date-input-group { justify-content: space-between; }
            .header-date-filter .date-input-group input[type="date"] { flex: 1; }
            .header-date-filter .date-separator { display: none; }
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
            <span class="brand-badge">Quản Lý</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">
                ${fn:substring(sessionScope.user.fullName, 0, 1)}
            </div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role">
                <i class="bi bi-briefcase-fill me-1"></i>Quản Lý
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

    <%-- Page Header — với Date Filter --%>
    <div class="admin-page-header">
        <div class="admin-page-header-left" style="flex:1; min-width:0;">
            <h1 class="admin-page-title">
                <i class="bi bi-clipboard-data me-2" style="color:var(--pink-500);"></i>Tổng Quan Quản Lý
            </h1>
            <div style="display:flex; align-items:center; flex-wrap:wrap; gap:0.75rem;">
                <div class="admin-page-subtitle" style="margin-bottom:0;">
                    <i class="bi bi-calendar3"></i>
                    ${not empty todayDisplay ? todayDisplay : 'Hôm nay'}
                    <span class="mx-2">&middot;</span>
                    <i class="bi bi-building"></i>
                    Tổng quan vận hành phòng khám
                </div>
                <%-- Inline Date Filter --%>
                <form method="get" action="${pageContext.request.contextPath}/manager/dashboard" class="header-date-filter">
                    <div class="date-input-group">
                        <span class="date-label">Từ</span>
                        <input type="date" name="dateFrom" id="dateFrom"
                               value="${dateFrom}" max="${today}" title="Từ ngày">
                    </div>
                    <span class="date-separator"><i class="bi bi-arrow-right"></i></span>
                    <div class="date-input-group">
                        <span class="date-label">Đến</span>
                        <input type="date" name="dateTo" id="dateTo"
                               value="${dateTo}" max="${today}" title="Đến ngày">
                    </div>
                    <button type="submit" class="btn-header-date btn-header-apply" title="Xem dữ liệu trong khoảng">
                        <i class="bi bi-check2"></i> Xem
                    </button>
                    <a href="${pageContext.request.contextPath}/manager/dashboard" class="btn-header-date btn-header-today" title="Về thời gian thực">
                        <i class="bi bi-calendar-check"></i> Hôm nay
                    </a>
                    <button type="button" class="btn-header-date btn-header-today" onclick="setQuickRange(7)" title="7 ngày qua">7 ngày</button>
                    <button type="button" class="btn-header-date btn-header-today" onclick="setQuickRange(30)" title="30 ngày qua">30 ngày</button>
                    <span class="header-date-badge ${isCustomRange ? 'history' : 'live'}">
                        <c:choose>
                            <c:when test="${isCustomRange}">
                                <i class="bi bi-clock-history"></i> ${dateRangeLabel}
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-broadcast"></i> Trực tiếp
                            </c:otherwise>
                        </c:choose>
                    </span>
                </form>
            </div>
        </div>
        <button class="btn-refresh" onclick="location.reload()" title="Làm mới dữ liệu">
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
            <p>Trung tâm điều hành phòng khám — theo dõi bệnh nhân, lịch hẹn, doanh thu, hiệu suất Bác sĩ lâm sàng và dịch vụ y tế.</p>
        </div>
        <span class="badge-role">
            <i class="bi bi-briefcase-fill"></i>
            Quản Lý Vận Hành
        </span>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- CÁC CHỈ SỐ VẬN HÀNH CỐT LÕI --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- 1. Lịch hẹn --%>
        <div class="col-xl-4 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/manager/schedules/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-appointments fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-calendar-check-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalAppointments ? totalAppointments : 0}</div>
                        <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">Lịch Hẹn (Khoảng)</c:when><c:otherwise>Tổng Lịch Hẹn</c:otherwise></c:choose></div>
                        <div class="kpi-sub"><i class="bi bi-clock"></i> ${isCustomRange ? dateRangeLabel : 'Toàn thời gian'}</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 3. Đang chờ khám --%>
        <div class="col-xl-4 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/manager/schedules/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-waiting fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-hourglass-split"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty waitingPatients ? waitingPatients : 0}</div>
                        <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">Đang Chờ (Khoảng)</c:when><c:otherwise>Đang Chờ Khám</c:otherwise></c:choose></div>
                        <div class="kpi-sub"><i class="bi bi-person"></i> ${isCustomRange ? dateRangeLabel : 'Hiện tại'}</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 4. Bác sĩ trực --%>
        <div class="col-xl-4 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/manager/schedules/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-doctors fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-person-badge-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty doctorsWorking ? doctorsWorking : 0}</div>
                        <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">BS (${dateToFormatted})</c:when><c:otherwise>Bác sĩ có lịch làm việc</c:otherwise></c:choose></div>
                        <div class="kpi-sub"><i class="bi bi-check-circle"></i> Lịch đã xác nhận</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 5. Ca siêu âm --%>
        <div class="col-xl-4 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/manager/services/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-ultrasound fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-soundwave"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty ultrasoundCases ? ultrasoundCases : 0}</div>
                        <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">Siêu Âm (Khoảng)</c:when><c:otherwise>Tổng Ca Siêu Âm</c:otherwise></c:choose></div>
                        <div class="kpi-sub"><i class="bi bi-calendar-day"></i> ${isCustomRange ? dateRangeLabel : 'Toàn thời gian'}</div>
                    </div>
                </div>
            </div>
            </a>
        </div>
        <%-- 6. Doanh thu --%>
        <div class="col-xl-4 col-lg-4 col-md-6">
            <a href="#revenueCharts" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-revenue fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-cash-coin"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value" style="font-size:1.05rem;">${not empty revenueToday ? revenueToday : '0 VNĐ'}</div>
                        <div class="kpi-label">Doanh Thu Hôm Nay</div>
                        <div class="kpi-sub"><i class="bi bi-graph-up"></i> Tổng: ${not empty revenue ? revenue : '0 VNĐ'}</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 7. Ca hoàn thành --%>
        <div class="col-xl-4 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/manager/dashboard" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-completed fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-check-circle-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty completedCases ? completedCases : 0}</div>
                        <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">Hoàn Thành (Khoảng)</c:when><c:otherwise>Tổng Ca Hoàn Thành</c:otherwise></c:choose></div>
                        <div class="kpi-sub"><i class="bi bi-check2-all"></i> Đã khám + TT</div>
                    </div>
                </div>
            </div>
            </a>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- BIỂU ĐỒ DOANH THU — 7 ngày & 30 ngày --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4" id="revenueCharts">
        <div class="col-12">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5>
                        <i class="bi bi-graph-up-arrow"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Doanh Thu (${dateRangeLabel})</c:when>
                            <c:otherwise>Doanh Thu Dịch Vụ</c:otherwise>
                        </c:choose>
                    </h5>
                    <div class="btn-group btn-group-sm" role="group" style="gap:0;">
                        <button type="button" class="btn btn-sm active" id="btn7Days"
                                style="background:#2563EB;color:#fff;border-radius:6px 0 0 6px;font-size:.72rem;font-weight:700;padding:.35rem .75rem;border:none;"
                                onclick="switchRevenueChart(7)">7 Ngày</button>
                        <button type="button" class="btn btn-sm" id="btn30Days"
                                style="background:#E0EFFF;color:#2563EB;border-radius:0 6px 6px 0;font-size:.72rem;font-weight:700;padding:.35rem .75rem;border:none;"
                                onclick="switchRevenueChart(30)">30 Ngày</button>
                    </div>
                </div>
                <div class="card-body">
                    <div class="chart-container" id="chart7Container">
                        <canvas id="mgrRevenue7DaysChart" height="260"></canvas>
                    </div>
                    <div class="chart-container" id="chart30Container" style="display:none;">
                        <canvas id="mgrRevenue30DaysChart" height="260"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- LỊCH LÀM VIỆC --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <div class="col-12">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-calendar-week-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Lịch Làm Việc (${dateToFormatted})</c:when>
                            <c:otherwise>Lịch Làm Việc Hôm Nay</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty todaySchedules}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead>
                                        <tr><th>Bác sĩ lâm sàng</th><th>Giờ</th><th>Khung Giờ</th><th>Trạng Thái</th></tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="sch" items="${todaySchedules}">
                                            <tr>
                                                <td>
                                                    <div style="font-weight:600;">${sch.doctorName}</div>
                                                    <div style="font-size:0.7rem;color:var(--c-muted);">${sch.specialization}</div>
                                                </td>
                                                <td style="font-family:var(--font-display);font-weight:600;color:var(--c-primary);">${sch.startTime} - ${sch.endTime}</td>
                                                <td>
                                                    <div class="slots-bar">
                                                        <div class="progress">
                                                            <c:set var="pct" value="${sch.maxSlots > 0 ? (sch.bookedSlots * 100 / sch.maxSlots) : 0}" />
                                                            <div class="progress-bar${sch.bookedSlots >= sch.maxSlots ? ' full' : ''}" style="width:${pct}%;"></div>
                                                        </div>
                                                        <span class="slots-text">${sch.bookedSlots}/${sch.maxSlots}</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${sch.isApproved}"><span class="badge-status badge-approved">Đã xác nhận</span></c:when>
                                                        <c:otherwise><span class="badge-status badge-pending">Chờ xác nhận</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-calendar-x"></i>
                                <h6>Chưa có lịch làm việc</h6>
                                <p>Hôm nay chưa có bác sĩ lâm sàng nào đăng ký lịch làm việc.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- BIỂU ĐỒ XU HƯỚNG LỊCH HẸN --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-calendar-check-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Lịch Hẹn 7 Ngày (${dateRangeLabel})</c:when>
                            <c:otherwise>Lịch Hẹn 7 Ngày Gần Nhất</c:otherwise>
                        </c:choose>
                    </h5>
                    <a href="${pageContext.request.contextPath}/manager/schedules/" style="font-size:0.75rem;font-weight:700;color:var(--c-primary);text-decoration:none;">
                        Xem tất cả <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="card-body">
                    <div class="chart-container">
                        <canvas id="mgrAppointmentsChart" height="260"></canvas>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-graph-up"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Lượt Sử Dụng Dịch Vụ (${dateRangeLabel})</c:when>
                            <c:otherwise>Lượt Sử Dụng Dịch Vụ 7 Ngày Gần Nhất</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty serviceUsageLast7DaysLabels}">
                            <div class="chart-container">
                                <canvas id="mgrServiceUsageChart" height="260"></canvas>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state py-4">
                                <i class="bi bi-activity" style="font-size:2rem;"></i>
                                <p class="mt-2 mb-0">Chưa có dữ liệu sử dụng dịch vụ.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- DỊCH VỤ — Tổng Quan Nhanh --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5><i class="bi bi-bar-chart-steps"></i> Dịch Vụ — Lượt Sử Dụng</h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty topServicesByUsage}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead><tr><th>#</th><th>Tên Dịch Vụ</th><th>Nhóm</th><th style="text-align:right;">Lượt SD</th></tr></thead>
                                    <tbody>
                                        <c:forEach var="svc" items="${topServicesByUsage}" varStatus="row">
                                            <tr>
                                                <td><span style="display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border-radius:50%;font-size:.68rem;font-weight:800;color:#fff;background:${row.index == 0 ? '#3B82F6' : (row.index == 1 ? '#94A3B8' : '#9CA3AF')};">${row.count}</span></td>
                                                <td><div style="font-weight:600;"><c:out value="${svc.serviceName}"/></div></td>
                                                <td style="font-size:0.72rem;color:var(--c-muted);"><c:out value="${svc.categoryName}"/></td>
                                                <td style="font-family:var(--font-display);font-weight:700;color:var(--c-primary);text-align:right;">${svc.usageToday}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state" style="padding:1.5rem;">
                                <i class="bi bi-inbox"></i>
                                <p class="mt-1 mb-0">Chưa có dữ liệu dịch vụ.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5><i class="bi bi-cash-stack"></i> Doanh Thu Dịch Vụ <span style="font-size:0.68rem;font-weight:400;color:var(--c-muted);">(Tất cả thời gian)</span></h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty topServicesByRevenue}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead><tr><th>#</th><th>Tên Dịch Vụ</th><th style="text-align:right;">Doanh Thu</th><th style="text-align:right;">Lượt SD</th></tr></thead>
                                    <tbody>
                                        <c:forEach var="svc" items="${topServicesByRevenue}" varStatus="row">
                                            <tr>
                                                <td><span style="display:inline-flex;align-items:center;justify-content:center;width:22px;height:22px;border-radius:50%;font-size:.68rem;font-weight:800;color:#fff;background:${row.index == 0 ? '#10B981' : (row.index == 1 ? '#94A3B8' : '#9CA3AF')};">${row.count}</span></td>
                                                <td><div style="font-weight:600;"><c:out value="${svc.serviceName}"/></div></td>
                                                <td style="font-family:var(--font-display);font-weight:700;color:#059669;text-align:right;">
                                                    <c:choose>
                                                        <c:when test="${svc.totalRevenue >= 1000000000}"><fmt:formatNumber value="${svc.totalRevenue / 1000000000}" maxFractionDigits="2"/> Tỷ</c:when>
                                                        <c:when test="${svc.totalRevenue >= 1000000}"><fmt:formatNumber value="${svc.totalRevenue / 1000000}" maxFractionDigits="1"/> Triệu</c:when>
                                                        <c:when test="${svc.totalRevenue > 0}"><fmt:formatNumber value="${svc.totalRevenue}" pattern="#,###"/> đ</c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="font-family:var(--font-display);font-weight:600;text-align:right;">${svc.totalUsage > 0 ? svc.totalUsage : '—'}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state" style="padding:1.5rem;">
                                <i class="bi bi-cash"></i>
                                <p class="mt-1 mb-0">Chưa có dữ liệu doanh thu. Hóa đơn cần được xác nhận thanh toán bởi Lễ Tân.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- HÀNG CUỐI: Dịch vụ & Thuốc KPI + Cảnh báo tồn kho --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Dịch vụ & Thuốc KPI cards --%>
        <div class="col-xl-6">
            <div class="row g-3">
                <div class="col-6">
                    <div class="card kpi-card kpi-services fade-in-up">
                        <div class="card-body">
                            <div class="kpi-icon"><i class="bi bi-activity"></i></div>
                            <div class="kpi-content">
                                <div class="kpi-value">${not empty totalServices ? totalServices : 0}</div>
                                <div class="kpi-label">Dịch Vụ Y Tế</div>
                                <div class="kpi-sub">Đang quản lý</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-6">
                    <div class="card kpi-card kpi-medicines fade-in-up">
                        <div class="card-body">
                            <div class="kpi-icon"><i class="bi bi-capsule"></i></div>
                            <div class="kpi-content">
                                <div class="kpi-value">${not empty totalMedicines ? totalMedicines : 0}</div>
                                <div class="kpi-label">Danh Mục Thuốc</div>
                                <div class="kpi-sub">Đang quản lý</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-6">
                    <div class="card kpi-card fade-in-up" style="--kpi-accent:#3b82f6;">
                        <div class="card-body" style="border-top:3px solid #3b82f6 !important;">
                            <div class="kpi-icon" style="background:#dbeafe;color:#2563eb;"><i class="bi bi-people-fill"></i></div>
                            <div class="kpi-content">
                                <div class="kpi-value">${not empty totalUsageToday ? totalUsageToday : 0}</div>
                                <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">Lượt SD (Khoảng)</c:when><c:otherwise>Lượt SD Hôm Nay</c:otherwise></c:choose></div>
                                <div class="kpi-sub"><i class="bi bi-calendar-check"></i> Dịch vụ</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-6">
                    <div class="card kpi-card fade-in-up" style="--kpi-accent:#10b981;">
                        <div class="card-body" style="border-top:3px solid #10b981 !important;">
                            <div class="kpi-icon" style="background:#d1fae5;color:#059669;"><i class="bi bi-cash-stack"></i></div>
                            <div class="kpi-content">
                                <div class="kpi-value" style="font-size:1.05rem;">${not empty revenue ? revenue : '0 VNĐ'}</div>
                                <div class="kpi-label">Tổng Doanh Thu</div>
                                <div class="kpi-sub"><i class="bi bi-check-circle"></i> Đã thanh toán</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Cảnh báo tồn kho --%>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5><i class="bi bi-exclamation-triangle-fill" style="color:#e65100;"></i> Cảnh Báo Tồn Kho</h5>
                    <a href="${pageContext.request.contextPath}/manager/medicines/" class="btn-sm-outline-pink">Quản lý kho <i class="bi bi-arrow-right"></i></a>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty lowStockMedicines}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead><tr><th>Thuốc</th><th>Tồn Kho</th><th>Trạng Thái</th></tr></thead>
                                    <tbody>
                                        <c:forEach var="med" items="${lowStockMedicines}">
                                            <tr>
                                                <td><div style="font-weight:600;"><c:out value="${med.name}"/></div><small style="font-size:0.68rem;color:var(--c-muted);"><c:out value="${med.dosage}"/></small></td>
                                                <td><span style="font-family:var(--font-display);font-weight:800;font-size:0.9rem;color:${med.stockQuantity <= 0 ? '#c62828' : (med.stockQuantity <= 3 ? '#c62828' : '#e65100')};">${med.stockQuantity}</span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${med.stockQuantity <= 0}"><span class="stock-out">HẾT HÀNG</span></c:when>
                                                        <c:when test="${med.stockQuantity <= 3}"><span class="stock-low">Sắp hết</span></c:when>
                                                        <c:otherwise><span class="stock-ok">Còn ít</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state" style="padding:1.5rem;">
                                <c:choose>
                                    <c:when test="${isCustomRange}"><i class="bi bi-inbox" style="font-size:1.8rem;color:var(--c-muted);"></i><p class="text-muted mt-1 mb-0" style="font-size:0.8rem;">Tồn kho là dữ liệu hiện tại.</p></c:when>
                                    <c:otherwise><i class="bi bi-check-circle" style="font-size:1.8rem;color:#2e7d32;"></i><p class="text-muted mt-1 mb-0" style="font-size:0.8rem;color:#2e7d32 !important;"><strong>Tất cả thuốc đều đủ tồn kho.</strong></p></c:otherwise>
                                </c:choose>
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
// Quick-select time range for charts
function setQuickRange(days) {
    var today = new Date();
    var from = new Date(today);
    from.setDate(today.getDate() - days);
    var dd = String(from.getDate()).padStart(2,'0');
    var mm = String(from.getMonth()+1).padStart(2,'0');
    var yyyy = from.getFullYear();
    document.getElementById('dateFrom').value = yyyy + '-' + mm + '-' + dd;
    dd = String(today.getDate()).padStart(2,'0');
    mm = String(today.getMonth()+1).padStart(2,'0');
    yyyy = today.getFullYear();
    document.getElementById('dateTo').value = yyyy + '-' + mm + '-' + dd;
    document.querySelector('.header-date-filter').submit();
}

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

// ── Manager Charts ──
(function() {
    var ocean500 = '#3B82F6';
    var ocean200 = '#BFDBFE';

    // Revenue 7 days (line chart)
    var ctx7 = document.getElementById('mgrRevenue7DaysChart');
    if (ctx7) {
        new Chart(ctx7, {
            type: 'line',
            data: {
                labels: [<c:forEach items="${mgrRevenueChartLabels}" var="lbl" varStatus="s">'${lbl}'<c:if test="${!s.last}">,</c:if></c:forEach>],
                datasets: [{ label: 'Doanh thu', data: [<c:forEach items="${mgrRevenueChartValues}" var="v" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>], borderColor: '#3B82F6', backgroundColor: 'rgba(59,130,246,0.08)', fill: true, tension: 0.4, pointRadius: 4, pointBackgroundColor: '#3B82F6', pointBorderColor: '#fff', pointBorderWidth: 2 }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { ticks: { callback: function(v){return v>=1e9?(v/1e9).toFixed(1)+'B':v>=1e6?(v/1e6).toFixed(0)+'M':v>=1e3?(v/1e3).toFixed(0)+'K':v;} } }, x: { grid: { display: false } } } }
        });
    }

    // Revenue 30 days (line chart)
    var ctx30 = document.getElementById('mgrRevenue30DaysChart');
    if (ctx30) {
        new Chart(ctx30, {
            type: 'line',
            data: {
                labels: [<c:forEach items="${mgrRevenue30Labels}" var="lbl" varStatus="s">'${lbl}'<c:if test="${!s.last}">,</c:if></c:forEach>],
                datasets: [{ label: 'Doanh thu', data: [<c:forEach items="${mgrRevenue30Values}" var="v" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>], borderColor: '#10B981', backgroundColor: 'rgba(16,185,129,0.06)', fill: true, tension: 0.3, pointRadius: 3, pointBackgroundColor: '#10B981', pointBorderColor: '#fff', pointBorderWidth: 1.5, borderWidth: 2 }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { ticks: { callback: function(v){return v>=1e9?(v/1e9).toFixed(1)+'B':v>=1e6?(v/1e6).toFixed(0)+'M':v>=1e3?(v/1e3).toFixed(0)+'K':v;} } }, x: { grid: { display: false } } } }
        });
    }

    // Appointments trend 7 days (Bar chart)
    var apptCtx = document.getElementById('mgrAppointmentsChart');
    if (apptCtx) {
        new Chart(apptCtx, {
            type: 'bar',
            data: {
                labels: [<c:forEach items="${mgrApptChartLabels}" var="lbl" varStatus="s">'${lbl}'<c:if test="${!s.last}">,</c:if></c:forEach>],
                datasets: [{ label: 'Lịch hẹn', data: [<c:forEach items="${mgrApptChartValues}" var="v" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>], backgroundColor: ['#3B82F6','#2563EB','#1D4ED8','#60A5FA','#3B82F6','#2563EB','#1D4ED8'], borderRadius: 6, hoverBackgroundColor: '#2563EB' }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#E5E7EB' } }, x: { grid: { display: false } } } }
        });
    }

    // Service usage 7 days (Line chart)
    var svcCtx = document.getElementById('mgrServiceUsageChart');
    if (svcCtx) {
        new Chart(svcCtx, {
            type: 'line',
            data: {
                labels: [
                    <c:forEach var="lbl" items="${serviceUsageLast7DaysLabels}" varStatus="s">
                        '${lbl}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Lượt sử dụng',
                    data: [
                        <c:forEach var="val" items="${serviceUsageLast7DaysValues}" varStatus="s">
                            ${val}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    borderColor: '#10B981',
                    backgroundColor: 'rgba(16,185,129,0.08)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#10B981',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    pointHoverRadius: 6
                }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#E5E7EB' } }, x: { grid: { display: false } } } }
        });
    }

})();

function switchRevenueChart(days) {
    var btn7 = document.getElementById('btn7Days');
    var btn30 = document.getElementById('btn30Days');
    var chart7 = document.getElementById('chart7Container');
    var chart30 = document.getElementById('chart30Container');
    if (days === 7) {
        chart7.style.display = 'block';
        chart30.style.display = 'none';
        btn7.style.background = '#2563EB'; btn7.style.color = '#fff';
        btn30.style.background = '#E0EFFF'; btn30.style.color = '#2563EB';
    } else {
        chart7.style.display = 'none';
        chart30.style.display = 'block';
        btn7.style.background = '#E0EFFF'; btn7.style.color = '#2563EB';
        btn30.style.background = '#2563EB'; btn30.style.color = '#fff';
    }
}
</script>


<%@ include file="../common/standalone-footer.jsp" %>
</body>
</html>
