<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Quản Lý — CAMS Manager</title>

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
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <style>
        /* ============================================================
           CAMS Manager — Business Operations Dashboard v5.0
           Focus: Patients, Appointments, Revenue, Doctors, Services
           ============================================================ */

        :root {
            --sidebar-w: 270px;
            --topbar-h: 66px;
            --pink-50:  #fff0f6;
            --pink-100: #ffe0ef;
            --pink-200: #ffb3d1;
            --pink-300: #ff80b3;
            --pink-400: #ff4d94;
            --pink-500: #e91e8c;
            --pink-600: #c2185b;
            --pink-700: #9c0f4a;
            --pink-800: #7b0a39;
            --rose-400: #fb7185;
            --rose-500: #f43f5e;
            --rose-600: #e11d48;

            --c-bg:              #fff5f9;
            --c-surface:         #ffffff;
            --c-surface-variant: #fff0f5;
            --c-primary:         #c2185b;
            --c-primary-light:   #ff4d94;
            --c-primary-dark:    #9c0f4a;
            --c-on-bg:           #1f1117;
            --c-on-surface:      #2d1a25;
            --c-on-surface-var:  #5a3d4e;
            --c-muted:           #8a6070;
            --c-outline:         #e8c5d5;
            --c-outline-variant: #f5dfe9;

            --green-500: #10b981;  --green-100: #d1fae5;  --green-700: #065f46;
            --amber-500: #f59e0b;  --amber-100: #fef3c7;  --amber-700: #92400e;
            --blue-500:  #3b82f6;  --blue-100:  #dbeafe;  --blue-700:  #1e40af;
            --purple-500:#8b5cf6;  --purple-100:#ede9fe;  --purple-700:#5b21b6;
            --cyan-500:  #06b6d4;  --cyan-100:  #cffafe;  --cyan-700:  #155e75;
            --red-500:   #ef4444;  --red-100:   #fee2e2;  --red-700:   #991b1b;

            --shadow-xs:   0 1px 3px rgba(194,24,91,0.07);
            --shadow-sm:   0 2px 8px rgba(194,24,91,0.10);
            --shadow-md:   0 4px 20px rgba(194,24,91,0.13);
            --shadow-pink: 0 4px 24px rgba(233,30,140,0.30);

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

        /* Business KPI variants */
        .kpi-patients      .card-body { border-top: 3px solid #7c3aed !important; }
        .kpi-patients      .kpi-icon { background: #ede9fe; color: #7c3aed; }
        .kpi-appointments  .card-body { border-top: 3px solid #2563eb !important; }
        .kpi-appointments  .kpi-icon { background: #dbeafe; color: #2563eb; }
        .kpi-waiting       .card-body { border-top: 3px solid #d97706 !important; }
        .kpi-waiting       .kpi-icon { background: #fef3c7; color: #d97706; }
        .kpi-doctors       .card-body { border-top: 3px solid #059669 !important; }
        .kpi-doctors       .kpi-icon { background: #d1fae5; color: #059669; }
        .kpi-ultrasound    .card-body { border-top: 3px solid #0891b2 !important; }
        .kpi-ultrasound    .kpi-icon { background: #cffafe; color: #0891b2; }
        .kpi-revenue       .card-body { border-top: 3px solid var(--pink-600) !important; }
        .kpi-revenue       .kpi-icon { background: var(--pink-100); color: var(--pink-600); }
        .kpi-emergency     .card-body { border-top: 3px solid #dc2626 !important; }
        .kpi-emergency     .kpi-icon { background: #fee2e2; color: #dc2626; }
        .kpi-completed     .card-body { border-top: 3px solid #059669 !important; }
        .kpi-completed     .kpi-icon { background: #d1fae5; color: #059669; }
        .kpi-rate          .card-body { border-top: 3px solid #f59e0b !important; }
        .kpi-rate          .kpi-icon { background: #fff7ed; color: #ea580c; }
        .kpi-new-patients  .card-body { border-top: 3px solid #8b5cf6 !important; }
        .kpi-new-patients  .kpi-icon { background: #ede9fe; color: #8b5cf6; }

        /* Service/Medicine KPI (Manager's own domain) */
        .kpi-services  .card-body { border-top: 3px solid var(--pink-400) !important; }
        .kpi-services  .kpi-icon { background: var(--pink-100); color: var(--pink-600); }
        .kpi-medicines .card-body { border-top: 3px solid #ce3fa7 !important; }
        .kpi-medicines .kpi-icon { background: #fce4f3; color: #9c0f6e; }

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
        .usage-rank.r1 { background: #e91e63; }
        .usage-rank.r2 { background: #ec407a; }
        .usage-rank.r3 { background: #f06292; }
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
            box-shadow: 0 0 0 3px rgba(233,30,140,0.08);
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
            color: #fff; box-shadow: 0 2px 6px rgba(233,30,140,0.2);
        }
        .btn-header-apply:hover { box-shadow: 0 4px 12px rgba(233,30,140,0.35); transform: translateY(-1px); color: #fff; }
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

    <%-- Page Header — với Date Filter --%>
    <div class="admin-page-header">
        <div class="admin-page-header-left" style="flex:1; min-width:0;">
            <h1 class="admin-page-title">
                <i class="bi bi-clipboard-data me-2" style="color:var(--pink-500);"></i>Dashboard Quản Lý
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
        <a href="${pageContext.request.contextPath}/export/reports?dateFrom=${dateFrom}&dateTo=${dateTo}"
           class="btn-refresh" title="Xuất báo cáo CSV" style="color:#059669;background:#ecfdf5;border-color:#a7f3d0;">
            <i class="bi bi-download"></i>
            Xuất Báo Cáo
        </a>
    </div>

    <%-- Welcome Banner --%>
    <div class="admin-welcome-banner">
        <div>
            <h2>
                <i class="bi bi-stars"></i>
                Xin chào, ${sessionScope.user.fullName}!
            </h2>
            <p>Trung tâm điều hành phòng khám — theo dõi bệnh nhân, lịch hẹn, doanh thu, hiệu suất bác sĩ và dịch vụ y tế.</p>
        </div>
        <span class="badge-role">
            <i class="bi bi-briefcase-fill"></i>
            Quản Lý Vận Hành
        </span>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- HÀNG 1: 10 KPI CARDS — Business Operations --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- 1. Tổng bệnh nhân --%>
        <div class="col-xl-15 col-lg-3 col-md-4 col-sm-6" style="flex:0 0 auto;width:20%;">
            <a href="${pageContext.request.contextPath}/manager/statistics/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-patients fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-people-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalPatients ? totalPatients : 0}</div>
                        <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">BN (Khoảng)</c:when><c:otherwise>Tổng Bệnh Nhân</c:otherwise></c:choose></div>
                        <div class="kpi-sub"><i class="bi bi-database"></i> <c:choose><c:when test="${isCustomRange}">${dateRangeLabel}</c:when><c:otherwise>Toàn hệ thống</c:otherwise></c:choose></div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 2. Lịch hẹn --%>
        <div class="col-xl-15 col-lg-3 col-md-4 col-sm-6" style="flex:0 0 auto;width:20%;">
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
        <div class="col-xl-15 col-lg-3 col-md-4 col-sm-6" style="flex:0 0 auto;width:20%;">
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
        <div class="col-xl-15 col-lg-3 col-md-4 col-sm-6" style="flex:0 0 auto;width:20%;">
            <a href="${pageContext.request.contextPath}/manager/schedules/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-doctors fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-person-badge-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty doctorsWorking ? doctorsWorking : 0}</div>
                        <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">BS (${dateToFormatted})</c:when><c:otherwise>Bác Sĩ Có Lịch</c:otherwise></c:choose></div>
                        <div class="kpi-sub"><i class="bi bi-check-circle"></i> Đã duyệt lịch</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 5. Ca siêu âm --%>
        <div class="col-xl-15 col-lg-3 col-md-4 col-sm-6" style="flex:0 0 auto;width:20%;">
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
    </div>

    <%-- HÀNG 1B: 5 KPI tiếp theo --%>
    <div class="row g-3 mb-4">
        <%-- 6. Doanh thu --%>
        <div class="col-xl-15 col-lg-3 col-md-4 col-sm-6" style="flex:0 0 auto;width:20%;">
            <a href="${pageContext.request.contextPath}/manager/statistics/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-revenue fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-cash-coin"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value" style="font-size:1.05rem;">${not empty revenue ? revenue : '0 VNĐ'}</div>
                        <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">Doanh Thu (Khoảng)</c:when><c:otherwise>Tổng Doanh Thu</c:otherwise></c:choose></div>
                        <div class="kpi-sub"><i class="bi bi-graph-up"></i> Đã thanh toán</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 7. Ca cấp cứu --%>
        <div class="col-xl-15 col-lg-3 col-md-4 col-sm-6" style="flex:0 0 auto;width:20%;">
            <a href="${pageContext.request.contextPath}/manager/schedules/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-emergency fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty emergencyCases ? emergencyCases : 0}</div>
                        <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">Cấp Cứu (Khoảng)</c:when><c:otherwise>Tổng Ca Cấp Cứu</c:otherwise></c:choose></div>
                        <div class="kpi-sub"><i class="bi bi-activity"></i> Khẩn cấp</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 8. Ca hoàn thành --%>
        <div class="col-xl-15 col-lg-3 col-md-4 col-sm-6" style="flex:0 0 auto;width:20%;">
            <a href="${pageContext.request.contextPath}/manager/statistics/" style="text-decoration:none;color:inherit;">
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

        <%-- 9. Tỉ lệ hoàn thành --%>
        <div class="col-xl-15 col-lg-3 col-md-4 col-sm-6" style="flex:0 0 auto;width:20%;">
            <a href="${pageContext.request.contextPath}/manager/statistics/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-rate fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-percent"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty completionRate ? completionRate : '0%'}</div>
                        <div class="kpi-label">Tỉ Lệ Hoàn Thành</div>
                        <div class="kpi-sub"><i class="bi bi-graph-up"></i> Completed / Total</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 10. Bệnh nhân mới --%>
        <div class="col-xl-15 col-lg-3 col-md-4 col-sm-6" style="flex:0 0 auto;width:20%;">
            <a href="${pageContext.request.contextPath}/manager/statistics/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-new-patients fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-person-plus-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty newPatients ? newPatients : 0}</div>
                        <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">BN Mới (Khoảng)</c:when><c:otherwise>Bệnh Nhân Mới</c:otherwise></c:choose></div>
                        <div class="kpi-sub"><i class="bi bi-person-plus"></i> Mới đăng ký</div>
                    </div>
                </div>
            </div>
            </a>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- HÀNG 1C: CHỈ SỐ CHẤT LƯỢNG VẬN HÀNH --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Tỉ lệ hủy lịch (Cancellation Rate) --%>
        <div class="col-md-6">
            <div class="card kpi-card fade-in-up" style="--kpi-accent:#ef4444;">
                <div class="card-body" style="border-top:3px solid #ef4444 !important;">
                    <div class="kpi-icon" style="background:#fee2e2;color:#dc2626;"><i class="bi bi-x-circle-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty cancellationRate ? cancellationRate : '0%'}</div>
                        <div class="kpi-label">Tỉ Lệ Hủy Lịch</div>
                        <div class="kpi-sub"><i class="bi bi-slash-circle"></i> ${not empty cancelledCount ? cancelledCount : 0} ca hủy / ${not empty totalAppointments ? totalAppointments : 0} tổng</div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Tỉ lệ cấp cứu (Emergency Rate) --%>
        <div class="col-md-6">
            <div class="card kpi-card fade-in-up" style="--kpi-accent:#f59e0b;">
                <div class="card-body" style="border-top:3px solid #f59e0b !important;">
                    <div class="kpi-icon" style="background:#fff7ed;color:#ea580c;"><i class="bi bi-exclamation-triangle-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty emergencyRate ? emergencyRate : '0%'}</div>
                        <div class="kpi-label">Tỉ Lệ Cấp Cứu</div>
                        <div class="kpi-sub"><i class="bi bi-activity"></i> ${not empty emergencyCases ? emergencyCases : 0} ca cấp cứu / ${not empty totalAppointments ? totalAppointments : 0} tổng</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- CẢNH BÁO VẬN HÀNH --%>
    <%-- ════════════════════════════════════════════ --%>
    <c:if test="${not empty operationalAlerts}">
    <div class="row mb-4">
        <div class="col-12">
            <div class="admin-card">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-exclamation-diamond-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Cảnh Báo Vận Hành (${dateRangeLabel})</c:when>
                            <c:otherwise>Cảnh Báo &amp; Thông Báo Vận Hành</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body p-3">
                    <div class="row g-2">
                        <c:forEach var="alert" items="${operationalAlerts}">
                        <div class="col-lg-3 col-md-6">
                            <div class="alert-item ${alert.type}">
                                <div class="alert-icon"><i class="bi ${alert.icon}"></i></div>
                                <div class="alert-body">
                                    <div class="alert-title">${alert.title}</div>
                                    <div class="alert-msg">${alert.message}</div>
                                </div>
                                <span class="alert-count">${alert.count}</span>
                            </div>
                        </div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </c:if>

    <%-- ════════════════════════════════════════════ --%>
    <%-- BIỂU ĐỒ: Lịch hẹn + Phân bố trạng thái + Doanh thu --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Biểu đồ lịch hẹn --%>
        <div class="col-xl-4 col-lg-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-graph-up-arrow"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Lịch Hẹn (${dateRangeLabel})</c:when>
                            <c:otherwise>Lịch Hẹn 7 Ngày Qua</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${hasApptData}">
                            <div class="chart-container">
                                <canvas id="appointmentsChart" height="260"></canvas>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state py-4">
                                <i class="bi bi-bar-chart" style="font-size:2rem;color:var(--pink-200);"></i>
                                <p class="mt-2 mb-0" style="color:var(--c-muted);">Chưa có dữ liệu trong khoảng này</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Phân bố trạng thái lịch hẹn (Doughnut) --%>
        <div class="col-xl-4 col-lg-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-pie-chart-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Phân Bố Trạng Thái (${dateRangeLabel})</c:when>
                            <c:otherwise>Phân Bố Trạng Thái Lịch Hẹn</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty statusBreakdown}">
                            <div class="chart-container">
                                <canvas id="statusChart" height="260"></canvas>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state py-4">
                                <i class="bi bi-pie-chart" style="font-size:2rem;color:var(--pink-200);"></i>
                                <p class="mt-2 mb-0" style="color:var(--c-muted);">Chưa có dữ liệu</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Doanh thu 7 ngày --%>
        <div class="col-xl-4 col-lg-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-graph-up-arrow"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Doanh Thu 7 Ngày (${dateRangeLabel})</c:when>
                            <c:otherwise>Doanh Thu 7 Ngày Gần Nhất</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body">
                    <div class="chart-container">
                        <canvas id="mgrRevenue7DaysChart" height="260"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- HÀNG GIỮA: Hiệu suất bác sĩ + Lịch làm việc --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Hiệu suất bác sĩ --%>
        <div class="col-xl-7">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5>
                        <i class="bi bi-trophy-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Hiệu Suất Bác Sĩ (${dateRangeLabel})</c:when>
                            <c:otherwise>Hiệu Suất Bác Sĩ</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty doctorPerformance}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Bác Sĩ</th>
                                            <th>Chuyên Khoa</th>
                                            <th class="text-center" title="Ca hoàn thành">Hoàn Thành</th>
                                            <th class="text-center" title="Ca đã hủy">Hủy</th>
                                            <th class="text-center" title="Ca cấp cứu">Cấp Cứu</th>
                                            <th class="text-center" title="Tỉ lệ hoàn thành">Tỉ Lệ HT</th>
                                            <th class="text-end">Doanh Thu</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="dp" items="${doctorPerformance}" varStatus="loop">
                                            <tr>
                                                <td style="color:var(--c-muted);">${loop.index + 1}</td>
                                                <td style="font-weight:600;">${dp.doctorName}</td>
                                                <td style="color:var(--c-muted);font-size:0.8rem;">${dp.specialization}</td>
                                                <td class="text-center"><span style="font-weight:700;color:var(--green-500);">${dp.completedCases}</span></td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${dp.cancelledCases > 0}"><span style="font-weight:700;color:var(--red-500);">${dp.cancelledCases}</span></c:when>
                                                        <c:otherwise><span style="color:var(--c-muted);">0</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${dp.emergencyCases > 0}"><span style="font-weight:700;color:var(--amber-500);">${dp.emergencyCases}</span></c:when>
                                                        <c:otherwise><span style="color:var(--c-muted);">0</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <span style="font-weight:700;color:${dp.completionRate >= 80 ? 'var(--green-500)' : (dp.completionRate >= 50 ? 'var(--amber-500)' : 'var(--red-500)')};"><fmt:formatNumber value="${dp.completionRate}" pattern="#.0"/>%</span>
                                                </td>
                                                <td class="text-end" style="font-weight:600;"><fmt:formatNumber value="${dp.revenueGenerated}" pattern="#,###" /> VNĐ</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-person-badge"></i>
                                <h6>Chưa có dữ liệu</h6>
                                <p>Thêm bác sĩ vào hệ thống để xem hiệu suất.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Lịch làm việc --%>
        <div class="col-xl-5">
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
                                        <tr><th>Bác Sĩ</th><th>Giờ</th><th>Slots</th><th>Trạng Thái</th></tr>
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
                                                        <c:when test="${sch.isApproved}"><span class="badge-status badge-approved">Đã duyệt</span></c:when>
                                                        <c:otherwise><span class="badge-status badge-pending">Chờ duyệt</span></c:otherwise>
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
                                <p>Hôm nay chưa có bác sĩ nào đăng ký lịch.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- HÀNG DƯỚI: Siêu âm + Bệnh nhân mới + Top dịch vụ --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Thống kê siêu âm --%>
        <div class="col-xl-4">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5><i class="bi bi-soundwave"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Thống Kê Dịch Vụ Siêu Âm (${dateRangeLabel})</c:when>
                            <c:otherwise>Thống Kê Dịch Vụ Siêu Âm</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty ultrasoundStats}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead>
                                        <tr><th>Dịch Vụ</th><th class="text-center">Tổng Ca</th><th class="text-center"><c:choose><c:when test="${isCustomRange}">${dateToFormatted}</c:when><c:otherwise>Hôm Nay</c:otherwise></c:choose></th><th class="text-end">Giá</th></tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="us" items="${ultrasoundStats}">
                                            <tr>
                                                <td style="font-weight:600;">${us.serviceName}</td>
                                                <td class="text-center" style="font-weight:700;">${us.totalCases}</td>
                                                <td class="text-center"><c:if test="${us.casesToday > 0}"><span class="badge-status badge-active">${us.casesToday}</span></c:if><c:if test="${us.casesToday == 0}">0</c:if></td>
                                                <td class="text-end" style="font-weight:600;"><fmt:formatNumber value="${us.price}" pattern="#,###" /> đ</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state"><i class="bi bi-soundwave"></i><h6>Chưa có dịch vụ siêu âm</h6></div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Bệnh nhân mới --%>
        <div class="col-xl-4">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5><i class="bi bi-person-plus-fill"></i> <c:choose><c:when test="${isCustomRange}">BN Mới (${dateRangeLabel})</c:when><c:otherwise>Bệnh Nhân Mới Đăng Ký</c:otherwise></c:choose></h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty recentPatients}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead><tr><th>STT</th><th>Họ Tên</th><th>Email / SĐT</th><th>Ngày ĐK</th></tr></thead>
                                    <tbody>
                                        <c:forEach var="rp" items="${recentPatients}" varStatus="row">
                                            <tr>
                                                <td style="color:var(--c-muted);font-size:0.78rem;">${row.count}</td>
                                                <td style="font-weight:600;">${rp.fullName}</td>
                                                <td style="font-size:0.78rem;"><div>${rp.email}</div><c:if test="${not empty rp.phone}"><div style="color:var(--c-muted);">${rp.phone}</div></c:if></td>
                                                <td style="color:var(--c-muted);font-size:0.78rem;white-space:nowrap;">${rp.createdAt}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise><div class="admin-empty-state"><i class="bi bi-people"></i><h6>Chưa có bệnh nhân mới</h6></div></c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Top Dịch Vụ --%>
        <div class="col-xl-4">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5><i class="bi bi-fire" style="color:#e91e63;"></i> <c:choose><c:when test="${isCustomRange}">Top Dịch Vụ (${dateRangeLabel})</c:when><c:otherwise>Top Dịch Vụ Hôm Nay</c:otherwise></c:choose></h5>
                    <a href="${pageContext.request.contextPath}/manager/statistics/" class="btn-sm-outline-pink">Thống kê <i class="bi bi-arrow-right"></i></a>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty topServicesToday}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead><tr><th style="width:36px;">#</th><th>Dịch Vụ</th><th style="width:75px;">Lượt SD</th><th style="width:90px;">Xu Hướng</th></tr></thead>
                                    <tbody>
                                        <c:forEach var="svc" items="${topServicesToday}" varStatus="loop">
                                            <tr>
                                                <td><span class="usage-rank ${loop.index == 0 ? 'r1' : (loop.index == 1 ? 'r2' : (loop.index == 2 ? 'r3' : 'rn'))}">${loop.index + 1}</span></td>
                                                <td>
                                                    <div style="font-weight:600;">${fn:escapeXml(svc.serviceName)}</div>
                                                    <c:if test="${not empty svc.categoryName}"><small style="font-size:0.68rem;color:var(--c-muted);"><i class="bi bi-folder me-1"></i>${fn:escapeXml(svc.categoryName)}</small></c:if>
                                                </td>
                                                <td><span style="font-family:var(--font-display);font-weight:800;font-size:0.95rem;">${svc.usageToday}</span> <span style="font-size:0.7rem;color:var(--c-muted);">lượt</span></td>
                                                <td>
                                                    <c:set var="trend" value="${svc.growthTrend}"/>
                                                    <c:choose>
                                                        <c:when test="${trend eq 'up'}"><span class="trend-up"><i class="bi bi-arrow-up-short"></i> ↑<fmt:formatNumber value="${svc.usageGrowthPercent}" maxFractionDigits="0"/>%</span></c:when>
                                                        <c:when test="${trend eq 'down'}"><span class="trend-down"><i class="bi bi-arrow-down-short"></i> ↓<fmt:formatNumber value="${svc.usageGrowthPercent * -1}" maxFractionDigits="0"/>%</span></c:when>
                                                        <c:otherwise><span class="trend-stable"><i class="bi bi-dash"></i> ổn định</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise><div class="admin-empty-state" style="padding:1.5rem;"><i class="bi bi-bar-chart" style="font-size:1.8rem;color:var(--c-muted);"></i><p class="text-muted mt-1 mb-0" style="font-size:0.8rem;">Chưa có lượt sử dụng dịch vụ.</p></div></c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- HÀNG CUỐI: Dịch vụ & Thuốc KPI + Cảnh báo tồn kho + Thao tác nhanh --%>
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
                                <div class="kpi-value" style="font-size:1.05rem;">${not empty totalRevenueTodayFormatted ? totalRevenueTodayFormatted : '0'}</div>
                                <div class="kpi-label"><c:choose><c:when test="${isCustomRange}">Doanh Thu DV (Khoảng)</c:when><c:otherwise>Doanh Thu DV Hôm Nay</c:otherwise></c:choose></div>
                                <div class="revenue-compare">
                                    <span class="rev-yesterday"><i class="bi bi-clock-history me-1"></i><c:choose><c:when test="${isCustomRange}">Kỳ trước ${not empty revenueYesterdayFormatted ? revenueYesterdayFormatted : '0'}</c:when><c:otherwise>H.qua ${not empty revenueYesterdayFormatted ? revenueYesterdayFormatted : '0'}</c:otherwise></c:choose></span>
                                    <c:choose>
                                        <c:when test="${revenueGrowthRate > 0}"><span class="rev-arrow-up"><i class="bi bi-arrow-up-short"></i><fmt:formatNumber value="${revenueGrowthRate}" maxFractionDigits="1"/>%</span></c:when>
                                        <c:when test="${revenueGrowthRate < 0}"><span class="rev-arrow-down"><i class="bi bi-arrow-down-short"></i><fmt:formatNumber value="${revenueGrowthRate * -1}" maxFractionDigits="1"/>%</span></c:when>
                                        <c:otherwise><span style="color:var(--c-muted);font-size:0.68rem;">→ 0%</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Cảnh báo tồn kho --%>
        <div class="col-xl-3">
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
                                                <td><div style="font-weight:600;">${fn:escapeXml(med.name)}</div><small style="font-size:0.68rem;color:var(--c-muted);">${fn:escapeXml(med.dosage)}</small></td>
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

        <%-- Thao tác nhanh --%>
        <div class="col-xl-3">
            <div class="admin-card h-100">
                <div class="card-header"><h5><i class="bi bi-lightning-charge-fill"></i> Thao Tác Nhanh</h5></div>
                <div class="card-body">
                    <div class="d-flex flex-column gap-2">
                        <a href="${pageContext.request.contextPath}/manager/services/" class="quick-action-btn">
                            <span class="quick-action-icon"><i class="bi bi-activity"></i></span>
                            <span class="quick-action-text"><span>Dịch Vụ Y Tế</span><small>Thêm, sửa, quản lý dịch vụ &amp; đơn giá</small></span>
                        </a>
                        <a href="${pageContext.request.contextPath}/manager/medicines/" class="quick-action-btn">
                            <span class="quick-action-icon"><i class="bi bi-capsule"></i></span>
                            <span class="quick-action-text"><span>Danh Mục Thuốc</span><small>Quản lý kho thuốc &amp; giá</small></span>
                        </a>
                        <a href="${pageContext.request.contextPath}/manager/schedules/" class="quick-action-btn">
                            <span class="quick-action-icon"><i class="bi bi-calendar-check"></i></span>
                            <span class="quick-action-text"><span>Duyệt Lịch Trực</span><small>Phê duyệt lịch làm việc bác sĩ</small></span>
                        </a>
                        <a href="${pageContext.request.contextPath}/manager/statistics/" class="quick-action-btn">
                            <span class="quick-action-icon"><i class="bi bi-file-earmark-bar-graph"></i></span>
                            <span class="quick-action-text"><span>Thống Kê Dịch Vụ</span><small>KPI, biểu đồ &amp; phân tích</small></span>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- BIỂU ĐỒ DOANH THU 12 THÁNG --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <div class="col-12">
            <div class="admin-card">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-bar-chart-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Doanh Thu 12 Tháng (${dateRangeLabel})</c:when>
                            <c:otherwise>Doanh Thu 12 Tháng</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body">
                    <div class="chart-container">
                        <canvas id="mgrRevenue12MonthsChart" height="300"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Activity Feed + Hướng dẫn --%>
    <div class="row g-3">
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header"><h5><i class="bi bi-clock-history"></i> <c:choose><c:when test="${isCustomRange}">Hoạt Động (${dateRangeLabel})</c:when><c:otherwise>Hoạt Động Gần Đây</c:otherwise></c:choose></h5></div>
                <div class="card-body p-3">
                    <ul class="activity-feed">
                        <c:if test="${not empty topServiceName && topServiceUsage > 0}">
                            <li class="activity-item">
                                <span class="activity-dot create"></span>
                                <div class="activity-body">
                                    <div class="act-title"><strong>${topServiceName}</strong> — dịch vụ được sử dụng nhiều nhất</div>
                                    <div class="act-meta"><span><i class="bi bi-bar-chart-fill me-1"></i>${topServiceUsage} lượt</span><span><i class="bi bi-trophy-fill me-1"></i>Top 1</span></div>
                                </div>
                            </li>
                        </c:if>
                        <li class="activity-item">
                            <span class="activity-dot update"></span>
                            <div class="activity-body">
                                <div class="act-title"><strong>${not empty totalUsageToday ? totalUsageToday : 0} lượt</strong> sử dụng dịch vụ</div>
                                <div class="act-meta"><span><i class="bi bi-people me-1"></i>${not empty servicesUsedToday ? servicesUsedToday : 0} loại dịch vụ</span></div>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header"><h5><i class="bi bi-info-circle-fill"></i> Hướng Dẫn Quản Lý</h5></div>
                <div class="card-body">
                    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:0.75rem;">
                        <div style="background:var(--c-surface);border:1px solid var(--c-outline-variant);border-radius:var(--r-md);padding:1rem;text-align:center;">
                            <span style="font-size:1.5rem;color:var(--pink-500);display:block;margin-bottom:0.4rem;"><i class="bi bi-1-circle-fill"></i></span>
                            <div style="font-size:0.72rem;font-weight:600;color:var(--c-muted);text-transform:uppercase;letter-spacing:0.05em;">Dịch Vụ Y Tế</div>
                            <div style="font-size:0.67rem;color:var(--c-muted);margin-top:0.15rem;">Thêm / sửa / ẩn dịch vụ &amp; đơn giá</div>
                        </div>
                        <div style="background:var(--c-surface);border:1px solid var(--c-outline-variant);border-radius:var(--r-md);padding:1rem;text-align:center;">
                            <span style="font-size:1.5rem;color:var(--pink-500);display:block;margin-bottom:0.4rem;"><i class="bi bi-2-circle-fill"></i></span>
                            <div style="font-size:0.72rem;font-weight:600;color:var(--c-muted);text-transform:uppercase;letter-spacing:0.05em;">Danh Mục Thuốc</div>
                            <div style="font-size:0.67rem;color:var(--c-muted);margin-top:0.15rem;">Quản lý danh mục &amp; tồn kho thuốc</div>
                        </div>
                        <div style="background:var(--c-surface);border:1px solid var(--c-outline-variant);border-radius:var(--r-md);padding:1rem;text-align:center;">
                            <span style="font-size:1.5rem;color:#3b82f6;display:block;margin-bottom:0.4rem;"><i class="bi bi-3-circle-fill"></i></span>
                            <div style="font-size:0.72rem;font-weight:600;color:var(--c-muted);text-transform:uppercase;letter-spacing:0.05em;">Lịch Trực</div>
                            <div style="font-size:0.67rem;color:var(--c-muted);margin-top:0.15rem;">Duyệt &amp; quản lý lịch bác sĩ</div>
                        </div>
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
    var pink500 = '#e91e8c', pink200 = '#ffb3d1';

    // Status Breakdown Doughnut
    var statusCtx = document.getElementById('statusChart');
    if (statusCtx) {
        var statusLabelsVi = {
            'completed':'Hoàn Thành','confirmed':'Đã Xác Nhận','pending':'Chờ Xác Nhận',
            'cancelled':'Đã Hủy','waiting':'Đang Chờ','in_progress':'Đang Khám'
        };
        var rawLabels = [<c:forEach var="sb" items="${statusBreakdown}" varStatus="s">'${sb.status}'${s.last ? '' : ','}</c:forEach>];
        var translatedLabels = rawLabels.map(function(l){return statusLabelsVi[l]||l;});
        new Chart(statusCtx, {
            type: 'doughnut',
            data: {
                labels: translatedLabels,
                datasets: [{
                    data: [<c:forEach var="sb" items="${statusBreakdown}" varStatus="s">${sb.count}${s.last ? '' : ','}</c:forEach>],
                    backgroundColor: ['#10b981','#3b82f6','#f59e0b','#ef4444','#8b5cf6','#f97316'],
                    borderColor: '#fff', borderWidth: 2.5, hoverOffset: 6
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false, cutout: '60%',
                plugins: { legend: { position: 'bottom', labels: { padding: 14, usePointStyle: true, pointStyleWidth: 8, font: { size: 11 } } } }
            }
        });
    }

    // Appointments Chart
    var apptCtx = document.getElementById('appointmentsChart');
    if (apptCtx) {
        new Chart(apptCtx, {
            type: 'bar',
            data: {
                labels: [<c:forEach var="lbl" items="${apptChartLabels}" varStatus="s">'${lbl}'${s.last ? '' : ','}</c:forEach>],
                datasets: [{
                    label: 'Lịch hẹn',
                    data: [<c:forEach var="val" items="${apptChartValues}" varStatus="s">${val}${s.last ? '' : ','}</c:forEach>],
                    backgroundColor: pink500, borderColor: '#c2185b', borderWidth: 1, borderRadius: 6
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } }, x: { grid: { display: false } } }
            }
        });
    }

    // Revenue 7 days
    var ctx7 = document.getElementById('mgrRevenue7DaysChart');
    if (ctx7) {
        new Chart(ctx7, {
            type: 'line',
            data: {
                labels: [<c:forEach items="${mgrRevenueChartLabels}" var="lbl" varStatus="s">'${lbl}'<c:if test="${!s.last}">,</c:if></c:forEach>],
                datasets: [{ label: 'Doanh thu', data: [<c:forEach items="${mgrRevenueChartValues}" var="v" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>], borderColor: pink500, backgroundColor: 'rgba(233,30,140,0.1)', fill: true, tension: 0.4, pointRadius: 4, pointBackgroundColor: pink500 }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { ticks: { callback: function(v){return v>=1e9?(v/1e9).toFixed(1)+'B':v>=1e6?(v/1e6).toFixed(0)+'M':v>=1e3?(v/1e3).toFixed(0)+'K':v;} } } } }
        });
    }

    // Revenue 12 months
    var ctx12 = document.getElementById('mgrRevenue12MonthsChart');
    if (ctx12) {
        new Chart(ctx12, {
            type: 'bar',
            data: {
                labels: [<c:forEach items="${mgrRevenue12MonthsLabels}" var="lbl" varStatus="s">'${lbl}'<c:if test="${!s.last}">,</c:if></c:forEach>],
                datasets: [{ label: 'Doanh thu', data: [<c:forEach items="${mgrRevenue12MonthsValues}" var="v" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>], backgroundColor: pink500, borderRadius: 6 }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { ticks: { callback: function(v){return v>=1e9?(v/1e9).toFixed(1)+'B':v>=1e6?(v/1e6).toFixed(0)+'M':v>=1e3?(v/1e3).toFixed(0)+'K':v;} } } } }
        });
    }
})();
</script>


<%@ include file="../common/standalone-footer.jsp" %>
</body>
</html>
