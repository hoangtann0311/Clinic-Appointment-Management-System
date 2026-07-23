<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Người Dùng — CAMS Quản Trị</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        :root {
            --sidebar-w: 270px; --topbar-h: 66px;
            --pink-50: #fff9fc; --pink-100: #fff1f6; --pink-200: #f7dce7; --pink-300: #e8b4c9;
            --pink-400: #df94b2; --pink-500: #d27b9f; --pink-600: #b86689; --pink-700: #a9607e;
            --pink-800: #a9607e; --rose-400: #fb7185; --rose-500: #f43f5e; --rose-600: #e11d48;
            --c-bg: #fff5f9; --c-surface: #ffffff; --c-surface-variant: #fff0f5;
            --c-surface-container: #f7e7ee; --c-primary: #b86689; --c-primary-light: #df94b2;
            --c-primary-dark: #a9607e; --c-primary-container: #fff1f6; --c-on-bg: #1f1117;
            --c-on-surface: #2d1a25; --c-on-surface-var: #5a3d4e; --c-muted: #8a6070;
            --c-outline: #e8c5d5; --c-outline-variant: #f5dfe9;
            --sb-bg: #fff5f9; --sb-bg-mid: #fae9f0; --sb-bg-deep: #f7e1ea;
            --sb-hover: #fffafd; --sb-active-bg: rgba(184,102,137,0.18);
            --sb-active-border: #d27b9f; --sb-text: #f0d5e3; --sb-text-muted: #a07085;
            --sb-border: rgba(255,255,255,0.07); --sb-accent: #e8b4c9;
            --status-active-bg: #e8f5e9; --status-active-fg: #2e7d32;
            --status-inactive-bg: #f5f5f5; --status-inactive-fg: #757575;
            --status-locked-bg: #ffebee; --status-locked-fg: #c62828;
            --status-pending-bg: #fff8e1; --status-pending-fg: #f57f17;
            --shadow-xs: 0 1px 3px rgba(184,102,137,0.07);
            --shadow-sm: 0 2px 8px rgba(184,102,137,0.10);
            --shadow-md: 0 4px 20px rgba(184,102,137,0.13);
            --shadow-lg: 0 8px 32px rgba(184,102,137,0.16);
            --r-sm: 8px; --r-md: 12px; --r-lg: 16px; --r-xl: 20px; --r-pill: 999px;
            --t-fast: 0.15s ease; --t-smooth: 0.25s cubic-bezier(0.4,0,0.2,1);
            --font-display: 'Nunito', sans-serif;
            --font-body: 'Inter', sans-serif;
        }
        *, *::before, *::after { box-sizing: border-box; }
        body, .btn, .form-control, .form-select, .form-label, .table, .badge, .card, .modal { font-family: var(--font-body); }
        h1,h2,h3,h4,h5,h6 { font-family: var(--font-display); }
        body.admin-body { font-family: var(--font-body); background: var(--c-bg); color: var(--c-on-bg); margin: 0; padding: 0; line-height: 1.6; -webkit-font-smoothing: antialiased; }

        /* ── TOP BAR ── */
        .admin-topbar { position: fixed; top: 0; left: 0; right: 0; height: var(--topbar-h); background: var(--c-surface); border-bottom: 2px solid var(--pink-200); display: flex; align-items: center; justify-content: space-between; padding: 0 1.5rem; z-index: 1030; box-shadow: var(--shadow-xs); }
        .admin-topbar-left { display: flex; align-items: center; gap: 0.875rem; }
        .admin-topbar-brand { font-family: var(--font-display); font-weight: 900; font-size: 1.3rem; color: var(--c-primary); text-decoration: none; display: flex; align-items: center; gap: 0.5rem; letter-spacing: -0.03em; }
        .admin-topbar-brand i { color: var(--pink-500); font-size: 1.5rem; filter: drop-shadow(0 0 6px rgba(184,102,137,0.4)); }
        .admin-topbar-brand .brand-badge { font-family: var(--font-body); font-weight: 700; font-size: 0.65rem; color: var(--c-primary); background: var(--pink-100); padding: 3px 10px; border-radius: var(--r-pill); letter-spacing: 0.06em; text-transform: uppercase; border: 1px solid var(--pink-200); }
        .admin-sidebar-toggle { background: none; border: none; color: var(--c-on-surface-var); font-size: 1.5rem; cursor: pointer; padding: 6px 8px; border-radius: var(--r-sm); display: none; line-height: 1; }
        .admin-sidebar-toggle:hover { background: var(--pink-100); color: var(--c-primary); }
        .admin-topbar-right { display: flex; align-items: center; gap: 0.75rem; }
        .admin-topbar-user { display: flex; align-items: center; gap: 0.6rem; padding: 0.375rem 0.875rem; background: var(--pink-50); border-radius: var(--r-pill); border: 1px solid var(--pink-200); }
        .admin-topbar-user span { font-size: 0.875rem; font-weight: 600; color: var(--c-primary-dark); }
        .admin-avatar-sm { width: 34px; height: 34px; border-radius: 50%; background: linear-gradient(135deg, var(--pink-500), var(--rose-400)); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.85rem; text-transform: uppercase; flex-shrink: 0; box-shadow: 0 2px 8px rgba(184,102,137,0.35); }
        .admin-topbar-role { font-size: 0.62rem; font-weight: 700; padding: 2px 8px; border-radius: var(--r-pill); background: linear-gradient(135deg, var(--pink-500), var(--rose-500)); color: #fff; letter-spacing: 0.05em; text-transform: uppercase; }
        .admin-topbar-logout { color: var(--c-on-surface-var); text-decoration: none; font-size: 0.85rem; font-weight: 600; display: flex; align-items: center; gap: 0.4rem; padding: 0.45rem 0.875rem; border-radius: var(--r-sm); transition: all var(--t-fast); border: 1px solid transparent; }
        .admin-topbar-logout:hover { background: var(--pink-50); color: var(--rose-600); border-color: var(--pink-200); }

        /* ── MAIN ── */
        .admin-main { margin-left: var(--sidebar-w); margin-top: var(--topbar-h); padding: 2rem 2.25rem; min-height: calc(100vh - var(--topbar-h)); }
        .admin-page-header { display: flex; align-items: flex-start; justify-content: space-between; flex-wrap: wrap; gap: 1rem; margin-bottom: 1.25rem; }
        .admin-page-title { font-family: var(--font-display); font-size: 1.85rem; font-weight: 900; color: var(--c-on-bg); margin: 0 0 0.25rem; letter-spacing: -0.04em; }
        .admin-page-subtitle { font-size: 0.85rem; color: var(--c-muted); display: flex; align-items: center; gap: 0.5rem; }

        /* ── STATS CARDS ── */
        .stats-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem; margin-bottom: 1.5rem; }
        .stat-card { background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-lg); padding: 1.25rem; display: flex; align-items: center; gap: 1rem; box-shadow: var(--shadow-xs); transition: all var(--t-smooth); cursor: default; position: relative; overflow: hidden; }
        .stat-card:hover { box-shadow: var(--shadow-md); transform: translateY(-2px); border-color: var(--pink-200); }
        .stat-card::after { content: ''; position: absolute; top: -20px; right: -20px; width: 80px; height: 80px; border-radius: 50%; opacity: 0.06; transition: all var(--t-smooth); }
        .stat-card:hover::after { transform: scale(1.2); opacity: 0.10; }
        .stat-card-icon { width: 52px; height: 52px; border-radius: var(--r-md); display: flex; align-items: center; justify-content: center; font-size: 1.4rem; flex-shrink: 0; color: #fff; }
        .sc-icon-total { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); }
        .sc-icon-doctor { background: linear-gradient(135deg, #6366f1, #4f46e5); }
        .sc-icon-manager { background: linear-gradient(135deg, #f59e0b, #d97706); }
        .sc-icon-staff { background: linear-gradient(135deg, #10b981, #059669); }
        .sc-icon-sono { background: linear-gradient(135deg, #06b6d4, #0891b2); }
        .sc-icon-patient { background: linear-gradient(135deg, var(--pink-400), var(--pink-600)); }
        .stat-card-body { flex: 1; min-width: 0; }
        .stat-card-label { font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.07em; color: var(--c-muted); margin-bottom: 0.25rem; }
        .stat-card-value { font-family: var(--font-display); font-size: 1.7rem; font-weight: 900; color: var(--c-on-bg); line-height: 1; }
        .stat-card-sub { font-size: 0.72rem; color: var(--c-muted); margin-top: 0.2rem; }

        /* ── QUICK FILTER TABS ── */
        .quick-tabs { display: flex; gap: 0.375rem; margin-bottom: 1rem; flex-wrap: wrap; }
        .quick-tab { padding: 0.5rem 1.25rem; border-radius: var(--r-pill); font-size: 0.82rem; font-weight: 700; text-decoration: none; border: 2px solid var(--c-outline); color: var(--c-on-surface-var); background: var(--c-surface); transition: all var(--t-fast); display: flex; align-items: center; gap: 0.4rem; cursor: pointer; }
        .quick-tab:hover { border-color: var(--pink-300); color: var(--c-primary); background: var(--pink-50); }
        .quick-tab.active { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); color: #fff; border-color: transparent; box-shadow: 0 2px 8px rgba(184,102,137,0.25); }
        .quick-tab .tab-count { font-size: 0.7rem; font-weight: 800; background: rgba(255,255,255,0.2); padding: 2px 8px; border-radius: var(--r-pill); }
        .quick-tab.active .tab-count { background: rgba(255,255,255,0.3); }

        /* ── Cards & Tables ── */
        .admin-card { background: var(--c-surface) !important; border: 1px solid var(--c-outline-variant) !important; border-radius: var(--r-lg) !important; box-shadow: var(--shadow-xs) !important; overflow: hidden; }
        .admin-card .card-header { background: var(--pink-50) !important; border-bottom: 1px solid var(--pink-200) !important; padding: 1rem 1.25rem !important; }
        .admin-card .card-header h5 { font-family: var(--font-display); font-size: 0.95rem; font-weight: 800; color: var(--c-primary-dark); margin: 0; display: flex; align-items: center; gap: 0.5rem; }
        .admin-card .card-body { background: var(--c-surface) !important; padding: 1.25rem !important; }
        .admin-table-wrapper { overflow-x: auto; }
        .admin-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
        .admin-table thead th { font-family: var(--font-display); font-size: 0.72rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.07em; color: var(--c-primary); padding: 0.875rem 1rem; background: var(--pink-50); border-bottom: 2px solid var(--pink-200); white-space: nowrap; }
        .admin-table tbody tr { border-bottom: 1px solid var(--c-outline-variant); transition: background var(--t-fast); }
        .admin-table tbody tr:hover { background: var(--pink-50); }
        .admin-table tbody td { padding: 0.75rem 1rem; color: var(--c-on-surface); vertical-align: middle; }

        /* ── Badges ── */
        .badge-role-tag { display: inline-flex; align-items: center; gap: 0.3rem; padding: 3px 12px; border-radius: var(--r-pill); font-size: 0.72rem; font-weight: 700; white-space: nowrap; }
        .badge-role-admin { background: #fdf2f8; color: #b91c6a; border: 1px solid #f9a8d4; }
        .badge-role-doctor { background: #eef2ff; color: #4338ca; border: 1px solid #c7d2fe; }
        .badge-role-manager { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
        .badge-role-staff { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
        .badge-role-patient { background: #f5f3ff; color: #6d28d9; border: 1px solid #ddd6fe; }
        .badge-role-sonographer { background: #ecfeff; color: #0e7490; border: 1px solid #a5f3fc; }
        .badge-status { display: inline-flex; align-items: center; gap: 0.3rem; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.72rem; font-weight: 700; white-space: nowrap; }
        .badge-status-active { background: var(--status-active-bg); color: var(--status-active-fg); }
        .badge-status-inactive { background: var(--status-inactive-bg); color: var(--status-inactive-fg); }
        .badge-status-locked { background: var(--status-locked-bg); color: var(--status-locked-fg); }
        .badge-status-pending { background: var(--status-pending-bg); color: var(--status-pending-fg); }
        .badge-status-pending-verification { background: var(--status-pending-bg); color: var(--status-pending-fg); }
        .badge-status-deleted { background: #fff1f6; color: #b71c1c; border: 1px solid #ef9a9a; }
        .tr-deleted { background: #fff5f5 !important; opacity: 0.85; }
        .tr-deleted:hover { background: #ffebee !important; }

        /* ── Buttons ── */
        .btn-primary-pink { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); color: #fff; border: none; font-weight: 700; border-radius: var(--r-sm); padding: 0.55rem 1.2rem; transition: all var(--t-fast); }
        .btn-primary-pink:hover { background: linear-gradient(135deg, var(--pink-600), var(--pink-700)); color: #fff; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(184,102,137,0.3); }
        .btn-sm-outline { font-size: 0.75rem; font-weight: 600; padding: 4px 10px; border-radius: var(--r-sm); }
        .btn-action { display: inline-flex; align-items: center; gap: 0.25rem; }
        .btn-action-group { display: flex; gap: 4px; align-items: center; flex-wrap: wrap; }

        /* ── Filter Bar ── */
        .filter-bar { display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: center; }
        .filter-bar .form-control, .filter-bar .form-select { width: auto; min-width: 150px; border-radius: var(--r-sm); border: 1px solid var(--c-outline); font-size: 0.85rem; padding: 0.45rem 0.75rem; }
        .filter-bar .form-control:focus, .filter-bar .form-select:focus { border-color: var(--pink-500); box-shadow: 0 0 0 0.2rem rgba(184,102,137,0.15); }

        /* ── Pagination ── */
        .admin-pagination { display: flex; justify-content: center; gap: 0.25rem; margin-top: 1.25rem; }
        .admin-pagination a, .admin-pagination span { display: inline-flex; align-items: center; justify-content: center; min-width: 38px; height: 38px; padding: 0 0.5rem; border-radius: var(--r-sm); font-size: 0.85rem; font-weight: 600; text-decoration: none; border: 1px solid var(--c-outline-variant); color: var(--c-on-surface-var); transition: all var(--t-fast); }
        .admin-pagination a:hover { background: var(--pink-50); border-color: var(--pink-200); color: var(--c-primary); }
        .admin-pagination .active { background: var(--pink-500); color: #fff; border-color: var(--pink-500); }
        .admin-pagination .disabled { opacity: 0.4; pointer-events: none; }

        /* ── Sidebar Backdrop ── */
        .admin-sidebar-backdrop { display: none; position: fixed; inset: 0; background: rgba(26,10,18,0.5); z-index: 1015; backdrop-filter: blur(3px); }
        .admin-sidebar-backdrop.show { display: block; }

        /* ── Empty State ── */
        .admin-empty-state { text-align: center; padding: 3rem 1rem; color: var(--c-muted); }
        .admin-empty-state i { font-size: 3rem; color: var(--pink-200); display: block; margin-bottom: 0.75rem; }
        .admin-empty-state h6 { font-family: var(--font-display); font-weight: 700; color: var(--c-on-surface-var); margin-bottom: 0.25rem; }

        /* ── Modal Enhancements ── */
        .modal-content { border-radius: var(--r-lg) !important; border: 1px solid var(--c-outline-variant) !important; box-shadow: var(--shadow-lg) !important; }
        .modal-header { background: linear-gradient(135deg, var(--pink-50), #fff0f8) !important; border-bottom: 1px solid var(--pink-200) !important; padding: 1.1rem 1.4rem !important; }
        .modal-header .modal-title { font-family: var(--font-display); font-weight: 800; color: var(--c-primary-dark); font-size: 1.05rem; }
        .modal-footer { border-top: 1px solid var(--c-outline-variant) !important; padding: 1rem 1.4rem !important; }
        .modal-body { padding: 1.4rem !important; }
        .form-label { font-size: 0.83rem; color: var(--c-on-surface-var); margin-bottom: 0.3rem; }
        .form-label.fw-semibold { font-weight: 600; color: var(--c-on-surface); }
        .input-group-text { background: var(--pink-50); border: 1px solid var(--c-outline); color: var(--c-primary); }

        /* ── Toast / Alert ── */
        .alert { border-radius: var(--r-md); border: none; font-size: 0.875rem; font-weight: 500; }

        /* ── Responsive ── */
        @media (max-width: 991.98px) {
            .admin-sidebar-toggle { display: inline-flex; }
            .admin-main { margin-left: 0; }
            .stats-row { grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); }
        }
        @media (max-width: 767.98px) {
            .admin-main { padding: 1rem; }
            .filter-bar .form-control, .filter-bar .form-select { width: 100%; min-width: auto; }
            .admin-page-header { flex-direction: column; }
            .stats-row { grid-template-columns: repeat(2, 1fr); }
            .quick-tabs { overflow-x: auto; flex-wrap: nowrap; }
        }
    </style>
</head>
<body class="admin-body">

<%-- ── TOP BAR ── --%>
<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i>
            CAMS
            <span class="brand-badge">Quản trị viên</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role"><i class="bi bi-shield-check me-1"></i>Quản trị viên</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout">
            <i class="bi bi-box-arrow-right"></i>
            <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
    </div>
</nav>

<%-- ── SIDEBAR ── --%>
<%@ include file="../layout/sidebar.jsp" %>

<%-- ── MAIN CONTENT ── --%>
<main class="admin-main" id="adminMain">

    <%-- ── PAGE HEADER ── --%>
    <div class="admin-page-header">
        <div class="admin-page-header-left">
            <h1 class="admin-page-title">
                <i class="bi bi-people-fill me-2" style="color:var(--pink-500);"></i>Quản Lý Người Dùng
            </h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-diagram-3-fill"></i>
                Quản lý toàn bộ tài khoản trong hệ thống — quản trị viên, nhân sự &amp; bệnh nhân
            </div>
        </div>
        <button class="btn btn-primary-pink" data-bs-toggle="modal" data-bs-target="#addUserModal">
            <i class="bi bi-person-plus-fill me-1"></i>Thêm Người Dùng
        </button>
    </div>

    <%-- ── STATISTICS CARDS ── --%>
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-card-icon sc-icon-total">
                <i class="bi bi-people-fill"></i>
            </div>
            <div class="stat-card-body">
                <div class="stat-card-label">Tổng Người Dùng</div>
                <div class="stat-card-value">${countTotal}</div>
                <div class="stat-card-sub">Toàn hệ thống</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-card-icon sc-icon-doctor">
                <i class="bi bi-heart-pulse-fill"></i>
            </div>
            <div class="stat-card-body">
                <div class="stat-card-label">Bác sĩ lâm sàng</div>
                <div class="stat-card-value">${countDoctor}</div>
                <div class="stat-card-sub">Bác sĩ lâm sàng</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-card-icon sc-icon-manager">
                <i class="bi bi-briefcase-fill"></i>
            </div>
            <div class="stat-card-body">
                <div class="stat-card-label">Quản Lý</div>
                <div class="stat-card-value">${countManager}</div>
                <div class="stat-card-sub">Quản lý vận hành</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-card-icon sc-icon-staff">
                <i class="bi bi-person-workspace"></i>
            </div>
            <div class="stat-card-body">
                <div class="stat-card-label">Nhân Viên</div>
                <div class="stat-card-value">${countStaffOnly}</div>
                <div class="stat-card-sub">Nhân viên lễ tân</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-card-icon sc-icon-sono">
                <i class="bi bi-soundwave"></i>
            </div>
            <div class="stat-card-body">
                <div class="stat-card-label">Bác sĩ siêu âm</div>
                <div class="stat-card-value">${countSono}</div>
                <div class="stat-card-sub">Bác sĩ siêu âm</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-card-icon sc-icon-patient">
                <i class="bi bi-person-hearts"></i>
            </div>
            <div class="stat-card-body">
                <div class="stat-card-label">Bệnh Nhân</div>
                <div class="stat-card-value">${countPatient}</div>
                <div class="stat-card-sub">Hồ sơ bệnh nhân</div>
            </div>
        </div>
    </div>

    <%-- ── ALERT MESSAGES ── --%>
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            <div>
                <c:choose>
                    <c:when test="${success eq 'created'}"><strong>Thành công!</strong> Đã thêm người dùng mới vào hệ thống.</c:when>
                    <c:when test="${success eq 'updated'}"><strong>Đã lưu!</strong> Thông tin người dùng đã được cập nhật.</c:when>
                    <c:when test="${success eq 'deleted'}"><strong>Đã xoá!</strong> Người dùng đã được xoá khỏi hệ thống.</c:when>
                    <c:when test="${success eq 'restored'}"><strong>Đã khôi phục!</strong> Người dùng đã được kích hoạt trở lại.</c:when>
                    <c:when test="${success eq 'hardDeleted'}"><strong>Đã xoá vĩnh viễn!</strong> Người dùng đã bị xoá hoàn toàn khỏi hệ thống.</c:when>
                </c:choose>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div>${error}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <%-- Fallback: hiển thị lỗi validation từ map errors --%>
    <c:if test="${not empty errors and empty showAddModal}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div>
                <strong>Lỗi khi tạo người dùng:</strong>
                <c:if test="${not empty errors['general']}">${errors['general']}</c:if>
                <c:if test="${empty errors['general']}">Vui lòng kiểm tra lại thông tin đã nhập.</c:if>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty editErrors and empty showEditModal}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div>
                <strong>Lỗi khi cập nhật người dùng:</strong>
                <c:if test="${not empty editErrors['general']}">${editErrors['general']}</c:if>
                <c:if test="${empty editErrors['general']}">Vui lòng kiểm tra lại thông tin đã nhập.</c:if>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <%-- ── QUICK FILTER TABS ── --%>
    <c:url var="baseUsersUrl" value="/admin/users/">
        <c:param name="search" value="${search}"/>
        <c:param name="status" value="${statusFilter}"/>
    </c:url>
    <div class="quick-tabs">
        <a href="${baseUsersUrl}&roleGroup=all" class="quick-tab ${empty roleGroup or roleGroup eq 'all' ? 'active' : ''}">
            <i class="bi bi-grid-fill"></i> Tất Cả
            <span class="tab-count">${countTotal}</span>
        </a>
        <a href="${baseUsersUrl}&roleGroup=staff" class="quick-tab ${roleGroup eq 'staff' ? 'active' : ''}">
            <i class="bi bi-person-badge-fill"></i> Nhân Sự
            <span class="tab-count">${countDoctor + countManager + countStaffOnly + countSono}</span>
        </a>
        <a href="${baseUsersUrl}&roleGroup=patients" class="quick-tab ${roleGroup eq 'patients' ? 'active' : ''}">
            <i class="bi bi-person-fill"></i> Bệnh Nhân
            <span class="tab-count">${countPatient}</span>
        </a>
    </div>

    <%-- ── FILTER BAR ── --%>
    <div class="admin-card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/users/" class="filter-bar">
                <%-- Giữ lại roleGroup khi filter --%>
                <c:if test="${not empty roleGroup}">
                    <input type="hidden" name="roleGroup" value="${roleGroup}">
                </c:if>
                <div class="input-group" style="max-width:280px;">
                    <span class="input-group-text"><i class="bi bi-search"></i></span>
                    <input type="text" name="search" class="form-control" placeholder="Tìm tên, email, SĐT..."
                           value="${not empty search ? fn:escapeXml(search) : ''}">
                </div>
                <select name="role" class="form-select">
                    <option value="">Tất cả vai trò</option>
                    <c:forEach var="entry" items="${roleMap}">
                        <option value="${entry.key}" ${roleFilter eq entry.key ? 'selected' : ''}>${entry.value}</option>
                    </c:forEach>
                </select>
                <select name="status" class="form-select">
                    <option value="">Tất cả trạng thái</option>
                    <option value="Active" ${statusFilter eq 'Active' ? 'selected' : ''}>Đang hoạt động</option>
                    <option value="Inactive" ${statusFilter eq 'Inactive' ? 'selected' : ''}>Ngừng hoạt động</option>
                    <option value="Locked" ${statusFilter eq 'Locked' ? 'selected' : ''}>Đã khoá</option>
                    <option value="Pending Verification" ${statusFilter eq 'Pending Verification' ? 'selected' : ''}>Chờ xác thực</option>
                </select>
                <%-- Ẩn chức năng Thùng rác --%>
                <%--
                <div class="form-check form-switch d-flex align-items-center gap-1 ms-2">
                    <input class="form-check-input" type="checkbox" name="includeDeleted" value="true"
                           id="chkIncludeDeleted" ${includeDeleted ? 'checked' : ''}
                           onchange="this.form.submit()" style="cursor:pointer;">
                    <label class="form-check-label" for="chkIncludeDeleted" style="cursor:pointer;font-size:0.82rem;font-weight:600;white-space:nowrap;">
                        <i class="bi bi-trash3-fill me-1" style="color:#b71c1c;font-size:0.7rem;"></i>Thùng rác
                    </label>
                </div>
                <c:if test="${includeDeleted}">
                    <span class="badge bg-danger ms-1" style="font-size:0.7rem;">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i>Đang xem ${totalUsers} tài khoản đã xoá
                    </span>
                </c:if>
                --%>
                <button type="submit" class="btn btn-primary-pink">
                    <i class="bi bi-funnel-fill me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/admin/users/" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-counterclockwise me-1"></i>Đặt lại
                </a>
            </form>
        </div>
    </div>

    <%-- ── USERS TABLE ── --%>
    <div class="admin-card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5><i class="bi bi-person-lines-fill me-2"></i>Danh Sách Người Dùng</h5>
            <span class="badge bg-white text-dark border" style="font-size:0.8rem;">
                <i class="bi bi-database me-1"></i>${not empty totalUsers ? totalUsers : '0'} bản ghi
            </span>
        </div>
        <div class="card-body p-0">
            <div class="admin-table-wrapper">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Người Dùng</th>
                            <th>Email</th>
                            <th>Điện Thoại</th>
                            <th>Vai Trò</th>
                            <th>Trạng Thái</th>
                            <th>Ngày Tạo</th>
                            <th style="width:200px;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty users}">
                                <c:forEach var="u" items="${users}" varStatus="row">
                                    <tr class="${u.deleted ? 'tr-deleted' : ''}">
                                        <td style="color:var(--c-muted);font-size:0.8rem;font-weight:600;">${(currentPage - 1) * pageSize + row.index + 1}</td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="admin-avatar-sm" style="width:36px;height:36px;font-size:0.8rem;">
                                                    ${fn:substring(u.fullName, 0, 1)}
                                                </div>
                                                <div>
                                                    <div style="font-weight:700;color:var(--c-on-surface);line-height:1.2;">
                                                        ${fn:escapeXml(u.fullName)}
                                                    </div>
                                                    <c:if test="${u.authProvider eq 'google'}">
                                                        <small style="font-size:0.68rem;color:var(--c-muted);">
                                                            <i class="bi bi-google me-1"></i>Google
                                                        </small>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </td>
                                        <td style="font-size:0.82rem;">
                                            <i class="bi bi-envelope-fill me-1" style="color:var(--c-muted);font-size:0.7rem;"></i>
                                            ${fn:escapeXml(u.email)}
                                        </td>
                                        <td style="font-size:0.82rem;">
                                            <c:choose>
                                                <c:when test="${not empty u.phone}">
                                                    <i class="bi bi-telephone-fill me-1" style="color:var(--c-muted);font-size:0.7rem;"></i>
                                                    ${fn:escapeXml(u.phone)}
                                                </c:when>
                                                <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <%-- Role badge với màu riêng cho từng role --%>
                                            <c:set var="roleClass" value="badge-role-staff"/>
                                            <c:set var="roleIcon" value="bi-person"/>
                                            <c:choose>
                                                <c:when test="${u.roleId eq 1}">
                                                    <c:set var="roleClass" value="badge-role-admin"/>
                                                    <c:set var="roleIcon" value="bi-shield-fill"/>
                                                </c:when>
                                                <c:when test="${u.roleId eq 2}">
                                                    <c:set var="roleClass" value="badge-role-doctor"/>
                                                    <c:set var="roleIcon" value="bi-heart-pulse-fill"/>
                                                </c:when>
                                                <c:when test="${u.roleId eq 3}">
                                                    <c:set var="roleClass" value="badge-role-manager"/>
                                                    <c:set var="roleIcon" value="bi-briefcase-fill"/>
                                                </c:when>
                                                <c:when test="${u.roleId eq 4}">
                                                    <c:set var="roleClass" value="badge-role-staff"/>
                                                    <c:set var="roleIcon" value="bi-person-workspace"/>
                                                </c:when>
                                                <c:when test="${u.roleId eq 5}">
                                                    <c:set var="roleClass" value="badge-role-patient"/>
                                                    <c:set var="roleIcon" value="bi-person-fill"/>
                                                </c:when>
                                                <c:when test="${u.roleId eq 6}">
                                                    <c:set var="roleClass" value="badge-role-sonographer"/>
                                                    <c:set var="roleIcon" value="bi-soundwave"/>
                                                </c:when>
                                            </c:choose>
                                            <span class="badge-role-tag ${roleClass}">
                                                <i class="bi ${roleIcon}"></i>
                                                ${not empty u.roleNameDisplay ? u.roleNameDisplay : roleMap[u.roleId]}
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${u.deleted}">
                                                    <span class="badge-status badge-status-deleted">
                                                        <i class="bi bi-trash3-fill me-1"></i>Đã xoá
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="statusClass" value="${not empty u.status ? fn:toLowerCase(fn:replace(u.status, ' ', '-')) : 'inactive'}" />
                                                    <span class="badge-status badge-status-${statusClass}">
                                                        <c:choose>
                                                            <c:when test="${u.status eq 'Active'}"><i class="bi bi-check-circle-fill me-1"></i>Hoạt động</c:when>
                                                            <c:when test="${u.status eq 'Locked'}"><i class="bi bi-lock-fill me-1"></i>Đã khoá</c:when>
                                                            <c:when test="${u.status eq 'Inactive'}"><i class="bi bi-slash-circle me-1"></i>Ngừng</c:when>
                                                            <c:when test="${u.status eq 'Pending Verification'}"><i class="bi bi-hourglass-split me-1"></i>Chờ Xác Thực</c:when>
                                                            <c:otherwise>${u.status}</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="font-size:0.8rem;color:var(--c-muted);">
                                            <c:choose>
                                                <c:when test="${not empty u.createdAt}">
                                                    <fmt:formatDate value="${u.createdAt}" pattern="dd/MM/yyyy"/>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="btn-action-group">
                                                <%-- Edit --%>
                                                <button class="btn btn-sm btn-outline-secondary btn-action"
                                                        onclick="openEditModal('${u.id}','${fn:escapeXml(u.fullName)}','${fn:escapeXml(u.email)}','${fn:escapeXml(u.phone)}','${u.roleId}','${fn:escapeXml(u.status)}')"
                                                        title="Chỉnh sửa" data-bs-toggle="tooltip">
                                                    <i class="bi bi-pencil-square"></i>
                                                </button>
                                                <%-- Các thao tác đặt lại mật khẩu và khóa tài khoản không hiển thị trong danh sách. --%>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" class="p-0">
                                        <div class="admin-empty-state">
                                            <i class="bi bi-inbox"></i>
                                            <h6>Không tìm thấy người dùng</h6>
                                            <p style="font-size:0.85rem;">Chưa có dữ liệu hoặc không khớp với bộ lọc. Nhấn "Thêm Người Dùng" để tạo mới.</p>
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

    <%-- ── PAGINATION ── --%>
    <c:if test="${totalPages > 1}">
        <div class="admin-pagination">
            <c:url var="baseUrl" value="/admin/users/">
                <c:if test="${not empty roleGroup}"><c:param name="roleGroup" value="${roleGroup}"/></c:if>
                <c:param name="search" value="${search}"/>
                <c:param name="role" value="${roleFilter}"/>
                <c:param name="status" value="${statusFilter}"/>
            </c:url>

            <c:if test="${currentPage > 1}">
                <a href="${baseUrl}&page=${currentPage - 1}" aria-label="Trang trước">
                    <i class="bi bi-chevron-left"></i>
                </a>
            </c:if>

            <c:forEach begin="1" end="${totalPages}" var="p">
                <c:choose>
                    <c:when test="${p eq currentPage}">
                        <span class="active">${p}</span>
                    </c:when>
                    <c:otherwise>
                        <a href="${baseUrl}&page=${p}">${p}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>

            <c:if test="${currentPage < totalPages}">
                <a href="${baseUrl}&page=${currentPage + 1}" aria-label="Trang sau">
                    <i class="bi bi-chevron-right"></i>
                </a>
            </c:if>
        </div>
    </c:if>

</main>

<%-- ============================================================
     MODAL: THÊM NGƯỜI DÙNG
     ============================================================ --%>
<div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addUserModalLabel">
                    <i class="bi bi-person-plus-fill me-2"></i>Thêm Người Dùng Mới
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/users/" autocomplete="off" novalidate>
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="create">
                <c:if test="${not empty roleGroup}"><input type="hidden" name="roleGroup" value="${roleGroup}"></c:if>
                <div class="modal-body">
                    <%-- Error summary --%>
                    <c:if test="${not empty errors['general']}">
                        <div class="alert alert-danger py-2 mb-3 d-flex align-items-center gap-2">
                            <i class="bi bi-exclamation-triangle-fill flex-shrink-0"></i>
                            <span>${errors['general']}</span>
                        </div>
                    </c:if>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-person-fill me-1" style="color:var(--pink-500);"></i>Họ tên <span class="text-danger">*</span>
                            </label>
                            <input type="text" name="fullName" class="form-control ${not empty errors['fullName'] ? 'is-invalid' : ''}"
                                   required maxlength="100" placeholder="VD: Nguyễn Văn A" value="${fn:escapeXml(formFullName)}">
                            <c:if test="${not empty errors['fullName']}">
                                <div class="invalid-feedback">${errors['fullName']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-envelope-fill me-1" style="color:var(--pink-500);"></i>Email <span class="text-danger">*</span>
                            </label>
                            <input type="email" name="email" class="form-control ${not empty errors['email'] ? 'is-invalid' : ''}"
                                   required maxlength="100" placeholder="VD: nvana@clinic.vn" value="${fn:escapeXml(formEmail)}">
                            <c:if test="${not empty errors['email']}">
                                <div class="invalid-feedback">${errors['email']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-lock-fill me-1" style="color:var(--pink-500);"></i>Mật khẩu <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-shield-lock-fill"></i></span>
                                <input type="password" name="password" class="form-control ${not empty errors['password'] ? 'is-invalid' : ''}"
                                       required minlength="6" placeholder="Ít nhất 6 ký tự" id="addPassword">
                                <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('addPassword', this)" tabindex="-1">
                                    <i class="bi bi-eye-fill"></i>
                                </button>
                            </div>
                            <c:if test="${not empty errors['password']}">
                                <div class="invalid-feedback">${errors['password']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-telephone-fill me-1" style="color:var(--pink-500);"></i>Số điện thoại <span class="text-danger">*</span>
                            </label>
                            <input type="text" name="phone" class="form-control ${not empty errors['phone'] ? 'is-invalid' : ''}"
                                   required inputmode="numeric" pattern="0(3|5|7|8|9)[0-9]{8}" maxlength="10"
                                   placeholder="VD: 0912345678" value="${fn:escapeXml(formPhone)}">
                            <c:if test="${not empty errors['phone']}">
                                <div class="invalid-feedback">${errors['phone']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-briefcase-fill me-1" style="color:var(--pink-500);"></i>Vai trò
                            </label>
                            <select name="roleId" class="form-select ${not empty errors['roleId'] ? 'is-invalid' : ''}">
                                <c:forEach var="entry" items="${roleMap}">
                                    <option value="${entry.key}" ${not empty formRoleId ? (entry.key == formRoleId ? 'selected' : '') : (entry.key == 5 ? 'selected' : '')}>${entry.value}</option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty errors['roleId']}">
                                <div class="invalid-feedback">${errors['roleId']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-toggle-on me-1" style="color:var(--pink-500);"></i>Trạng thái
                            </label>
                            <select name="status" class="form-select">
                                <option value="Active" ${formStatus eq 'Active' ? 'selected' : ''}>Hoạt động</option>
                                <option value="Inactive" ${formStatus eq 'Inactive' ? 'selected' : ''}>Ngừng hoạt động</option>
                                <option value="Locked" ${formStatus eq 'Locked' ? 'selected' : ''}>Đã khoá</option>
                            </select>
                        </div>
                        <div class="col-12 doctor-fields" id="addDoctorFields" style="display: none;">
                            <hr class="my-2 text-muted">
                            <h6 class="fw-bold text-primary mb-3"><i class="bi bi-hospital me-1"></i>Hồ sơ Bác sĩ lâm sàng (Bắt buộc khi chọn vai trò Bác sĩ lâm sàng)</h6>
                            <div class="row g-3">
                                <div class="col-md-5">
                                    <label class="form-label fw-semibold">Chuyên khoa <span class="text-danger">*</span></label>
                                    <input type="text" name="specialization" class="form-control ${not empty errors['specialization'] ? 'is-invalid' : ''}" placeholder="VD: Sản phụ khoa / Siêu âm thai" value="${fn:escapeXml(param.specialization)}">
                                    <c:if test="${not empty errors['specialization']}">
                                        <div class="invalid-feedback">${errors['specialization']}</div>
                                    </c:if>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold">Bằng cấp / Học vị</label>
                                    <input type="text" name="degree" class="form-control" placeholder="VD: BS. CKI / Thạc sĩ" value="${fn:escapeXml(param.degree)}">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Số năm kinh nghiệm</label>
                                    <input type="number" name="experienceYears" class="form-control ${not empty errors['experienceYears'] ? 'is-invalid' : ''}" min="0" placeholder="VD: 5" value="${fn:escapeXml(param.experienceYears)}">
                                    <c:if test="${not empty errors['experienceYears']}">
                                        <div class="invalid-feedback">${errors['experienceYears']}</div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Huỷ
                    </button>
                    <button type="submit" class="btn btn-primary-pink">
                        <i class="bi bi-check-lg me-1"></i>Tạo Người Dùng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: SỬA NGƯỜI DÙNG
     ============================================================ --%>
<div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="editUserModalLabel">
                    <i class="bi bi-pencil-square me-2"></i>Chỉnh Sửa Người Dùng
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/users/" novalidate>
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="userId" id="editUserId" value="${editUserId}">
                <c:if test="${not empty roleGroup}"><input type="hidden" name="roleGroup" value="${roleGroup}"></c:if>
                <div class="modal-body">
                    <c:if test="${not empty editErrors['general']}">
                        <div class="alert alert-danger py-2 mb-3 d-flex align-items-center gap-2">
                            <i class="bi bi-exclamation-triangle-fill flex-shrink-0"></i>
                            <span>${editErrors['general']}</span>
                        </div>
                    </c:if>
                    <div class="row g-3">
                        <%-- Họ tên: readonly (không được sửa) --%>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-lock-fill me-1" style="font-size:0.65rem;color:var(--c-muted);"></i>Họ tên
                            </label>
                            <input type="text" id="editFullName" class="form-control"
                                   readonly tabindex="-1"
                                   value="${fn:escapeXml(formEditFullName)}"
                                   style="background:#f5f5f5;color:#666;cursor:not-allowed;">
                        </div>
                        <%-- Email — readonly, nhưng vẫn submit để server validate (cần name attribute) --%>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-lock-fill me-1" style="font-size:0.65rem;color:var(--c-muted);"></i>Email
                            </label>
                            <input type="text" name="email" id="editEmail"
                                   class="form-control ${not empty editErrors['email'] ? 'is-invalid' : ''}"
                                   readonly tabindex="-1"
                                   value="${fn:escapeXml(formEditEmail)}"
                                   style="background:#f5f5f5;color:#666;cursor:not-allowed;">
                            <c:if test="${not empty editErrors['email']}">
                                <div class="invalid-feedback">${editErrors['email']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-lock-fill me-1" style="font-size:0.65rem;color:var(--c-muted);"></i>Số điện thoại
                            </label>
                            <input type="text" name="phone" id="editPhone"
                                   class="form-control ${not empty editErrors['phone'] ? 'is-invalid' : ''}"
                                   readonly tabindex="-1"
                                   value="${fn:escapeXml(formEditPhone)}"
                                   style="background:#f5f5f5;color:#666;cursor:not-allowed;">
                            <c:if test="${not empty editErrors['phone']}">
                                <div class="invalid-feedback">${editErrors['phone']}</div>
                            </c:if>
                        </div>
                        <%-- Phân quyền: cho phép chỉnh sửa --%>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-unlock-fill me-1" style="font-size:0.65rem;color:var(--pink-500);"></i>Vai trò
                            </label>
                            <input type="hidden" name="roleId" id="editRoleId" value="${formEditRoleId}">
                            <select id="editRoleIdDisplay" class="form-select" disabled
                                    aria-describedby="editRoleHelp">
                                <c:forEach var="entry" items="${roleMap}">
                                    <option value="${entry.key}" ${not empty formEditRoleId ? (entry.key == formEditRoleId ? 'selected' : '') : ''}>${entry.value}</option>
                                </c:forEach>
                            </select>
                            <div id="editRoleHelp" class="form-text">Không đổi vai trò của tài khoản đã có để bảo toàn hồ sơ nghiệp vụ.</div>
                            <c:if test="${not empty editErrors['roleId']}">
                                <div class="invalid-feedback">${editErrors['roleId']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-unlock-fill me-1" style="font-size:0.65rem;color:var(--pink-500);"></i>Trạng thái
                            </label>
                            <select name="status" id="editStatus" class="form-select ${not empty editErrors['status'] ? 'is-invalid' : ''}">
                                <option value="Active" ${formEditStatus eq 'Active' ? 'selected' : ''}>Hoạt động</option>
                                <option value="Inactive" ${formEditStatus eq 'Inactive' ? 'selected' : ''}>Ngừng hoạt động</option>
                                <option value="Locked" ${formEditStatus eq 'Locked' ? 'selected' : ''}>Đã khoá</option>
                            </select>
                            <c:if test="${not empty editErrors['status']}">
                                <div class="invalid-feedback">${editErrors['status']}</div>
                            </c:if>
                        </div>
                        <div class="col-12 doctor-fields" id="editDoctorFields" style="display: none;">
                            <hr class="my-2 text-muted">
                            <h6 class="fw-bold text-primary mb-3"><i class="bi bi-hospital me-1"></i>Hồ sơ Bác sĩ lâm sàng (Bắt buộc khi chọn vai trò Bác sĩ lâm sàng)</h6>
                            <div class="row g-3">
                                <div class="col-md-5">
                                    <label class="form-label fw-semibold">Chuyên khoa <span class="text-danger">*</span></label>
                                    <input type="text" name="specialization" id="editSpecialization" class="form-control ${not empty editErrors['specialization'] ? 'is-invalid' : ''}" placeholder="VD: Sản phụ khoa / Siêu âm thai" value="${fn:escapeXml(param.specialization)}">
                                    <c:if test="${not empty editErrors['specialization']}">
                                        <div class="invalid-feedback">${editErrors['specialization']}</div>
                                    </c:if>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold">Bằng cấp / Học vị</label>
                                    <input type="text" name="degree" id="editDegree" class="form-control" placeholder="VD: BS. CKI / Thạc sĩ" value="${fn:escapeXml(param.degree)}">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Số năm kinh nghiệm</label>
                                    <input type="number" name="experienceYears" id="editExperienceYears" class="form-control ${not empty editErrors['experienceYears'] ? 'is-invalid' : ''}" min="0" placeholder="VD: 5" value="${fn:escapeXml(param.experienceYears)}">
                                    <c:if test="${not empty editErrors['experienceYears']}">
                                        <div class="invalid-feedback">${editErrors['experienceYears']}</div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Huỷ
                    </button>
                    <button type="submit" class="btn btn-primary-pink">
                        <i class="bi bi-check-lg me-1"></i>Lưu Thay Đổi
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: ĐẶT LẠI MẬT KHẨU
     ============================================================ --%>
<div class="modal fade" id="resetPasswordModal" tabindex="-1" aria-labelledby="resetPwdModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="resetPwdModalLabel">
                    <i class="bi bi-key-fill me-2"></i>Đặt Lại Mật Khẩu
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/users/"
                  id="resetPasswordForm" autocomplete="off" novalidate
                  onsubmit="return validateResetPassword()">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="resetPassword">
                <input type="hidden" name="userId" id="resetPwdUserId">
                <c:if test="${not empty roleGroup}"><input type="hidden" name="roleGroup" value="${roleGroup}"></c:if>
                <c:if test="${not empty roleFilter}"><input type="hidden" name="role" value="${roleFilter}"></c:if>
                <c:if test="${not empty statusFilter}"><input type="hidden" name="status" value="${statusFilter}"></c:if>
                <c:if test="${not empty search}"><input type="hidden" name="search" value="${fn:escapeXml(search)}"></c:if>
                <div class="modal-body">
                    <%-- Error summary từ server --%>
                    <c:if test="${not empty resetPwdErrors}">
                        <div class="alert alert-danger py-2 mb-3 d-flex align-items-center gap-2" style="font-size:0.85rem;">
                            <i class="bi bi-exclamation-triangle-fill flex-shrink-0"></i>
                            <span>${resetPwdErrors}</span>
                        </div>
                    </c:if>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Người dùng</label>
                        <input type="text" id="resetPwdName" class="form-control" readonly
                               style="background:var(--pink-50);font-weight:600;">
                    </div>
                    <%-- Mật khẩu mới --%>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            Mật khẩu mới <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-shield-lock-fill"></i></span>
                            <input type="password" name="newPassword" class="form-control"
                                   placeholder="6-50 ký tự, gồm chữ, số và ký tự đặc biệt"
                                   id="newPasswordField" maxlength="50"
                                   oninput="checkPasswordStrength()" onkeyup="checkPasswordMatchLive()">
                            <button class="btn btn-outline-secondary" type="button"
                                    onclick="togglePassword('newPasswordField', this)" tabindex="-1">
                                <i class="bi bi-eye-fill"></i>
                            </button>
                        </div>
                        <%-- Thanh độ mạnh mật khẩu --%>
                        <div class="progress mt-1" style="height:4px;" id="pwdStrengthProgress">
                            <div id="pwdStrengthBar" class="progress-bar bg-danger" role="progressbar"
                                 style="width:0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                        <div style="font-size:0.68rem;margin-top:2px;" id="pwdStrengthText" class="text-muted"></div>
                        <%-- Error inline --%>
                        <div id="newPasswordError" class="invalid-feedback" style="font-size:0.75rem;"></div>
                        <small class="text-muted" style="font-size:0.72rem;">
                            <i class="bi bi-info-circle me-1"></i>6-50 ký tự, phải có chữ cái, chữ số và ký tự đặc biệt (!@#$%...).
                        </small>
                    </div>
                    <%-- Xác nhận mật khẩu --%>
                    <div class="mb-2">
                        <label class="form-label fw-semibold">
                            Xác nhận mật khẩu <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-shield-check"></i></span>
                            <input type="password" name="confirmPassword" class="form-control"
                                   placeholder="Nhập lại mật khẩu mới"
                                   id="confirmPasswordField" maxlength="50"
                                   onkeyup="checkPasswordMatchLive()">
                            <button class="btn btn-outline-secondary" type="button"
                                    onclick="togglePassword('confirmPasswordField', this)" tabindex="-1">
                                <i class="bi bi-eye-fill"></i>
                            </button>
                        </div>
                        <div id="confirmPasswordError" class="invalid-feedback" style="font-size:0.75rem;"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Huỷ
                    </button>
                    <button type="submit" class="btn btn-primary-pink" id="resetPwdSubmitBtn">
                        <i class="bi bi-check-lg me-1"></i>Đặt Lại Mật Khẩu
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
// ── Sidebar toggle ──
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });

// ── Active sidebar link ──
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        var link = links[i];
        if (link.href && link.href.indexOf('/admin/users') !== -1) {
            link.classList.add('active');
        }
    }
})();

// ── Doctor fields toggle helper ──
function toggleDoctorFields() {
    var addRoleSelect = document.querySelector('#addUserModal select[name="roleId"]');
    var addDoctorFields = document.getElementById('addDoctorFields');
    if (addRoleSelect && addDoctorFields) {
        var addIsDoctor = addRoleSelect.value == '2';
        addDoctorFields.style.display = addIsDoctor ? 'block' : 'none';
        var addSpecialization = addDoctorFields.querySelector('[name="specialization"]');
        if (addSpecialization) addSpecialization.required = addIsDoctor;
    }

    var editRoleSelect = document.getElementById('editRoleId');
    var editDoctorFields = document.getElementById('editDoctorFields');
    if (editRoleSelect && editDoctorFields) {
        var editIsDoctor = editRoleSelect.value == '2';
        editDoctorFields.style.display = editIsDoctor ? 'block' : 'none';
        var editSpecialization = editDoctorFields.querySelector('[name="specialization"]');
        if (editSpecialization) editSpecialization.required = editIsDoctor;
    }
}
document.addEventListener('DOMContentLoaded', function() {
    var addRoleSelect = document.querySelector('#addUserModal select[name="roleId"]');
    if (addRoleSelect) addRoleSelect.addEventListener('change', toggleDoctorFields);

    var editRoleSelect = document.getElementById('editRoleId');
    if (editRoleSelect) editRoleSelect.addEventListener('change', toggleDoctorFields);

    toggleDoctorFields();
});

// ── Edit modal helper ──
function openEditModal(id, fullName, email, phone, roleId, status) {
    document.getElementById('editUserId').value = id;
    document.getElementById('editFullName').value = fullName || '';
    document.getElementById('editEmail').value = email || '';
    document.getElementById('editPhone').value = phone || '';
    document.getElementById('editRoleId').value = roleId;
    document.getElementById('editRoleIdDisplay').value = roleId;
    document.getElementById('editStatus').value = status;

    toggleDoctorFields();
    new bootstrap.Modal(document.getElementById('editUserModal')).show();
}

// ── Reset password modal helper ──
function openResetPwdModal(id, fullName) {
    document.getElementById('resetPwdUserId').value = id;
    document.getElementById('resetPwdName').value = fullName;
    // Reset all fields
    var pwdField = document.getElementById('newPasswordField');
    var confirmField = document.getElementById('confirmPasswordField');
    if (pwdField) { pwdField.value = ''; pwdField.type = 'password'; pwdField.classList.remove('is-invalid'); }
    if (confirmField) { confirmField.value = ''; confirmField.type = 'password'; confirmField.classList.remove('is-invalid'); }
    // Reset error displays
    var newPwdErr = document.getElementById('newPasswordError');
    var confirmPwdErr = document.getElementById('confirmPasswordError');
    if (newPwdErr) { newPwdErr.style.display = 'none'; newPwdErr.textContent = ''; }
    if (confirmPwdErr) { confirmPwdErr.style.display = 'none'; confirmPwdErr.textContent = ''; }
    // Reset strength bar
    var bar = document.getElementById('pwdStrengthBar');
    var text = document.getElementById('pwdStrengthText');
    if (bar) { bar.style.width = '0%'; bar.className = 'progress-bar bg-danger'; }
    if (text) { text.textContent = ''; text.className = 'text-muted'; }
    // Reset submit button
    var btn = document.getElementById('resetPwdSubmitBtn');
    if (btn) btn.disabled = false;

    new bootstrap.Modal(document.getElementById('resetPasswordModal')).show();
}

// ── Validate password strength (real-time) ──
function checkPasswordStrength() {
    var pwd = document.getElementById('newPasswordField').value;
    var bar = document.getElementById('pwdStrengthBar');
    var text = document.getElementById('pwdStrengthText');
    if (!bar || !text) return;

    var hasLetter = /[a-zA-Z]/.test(pwd);
    var hasDigit = /[0-9]/.test(pwd);
    var hasSpecial = /[^a-zA-Z0-9]/.test(pwd);
    var hasMinLength = pwd.length >= 6;
    var hasGoodLength = pwd.length >= 10;

    // Score: mỗi yêu cầu bắt buộc = 1 sao, bonus thêm length/special
    var score = 0;
    if (hasMinLength) score++;
    if (hasLetter) score++;
    if (hasDigit) score++;
    if (hasSpecial) score++;
    if (hasGoodLength) score++;

    var pct = score * 20;
    bar.style.width = pct + '%';

    // Thiếu yêu cầu bắt buộc → danger
    if (!hasMinLength || !hasLetter || !hasDigit || !hasSpecial) {
        var missing = [];
        if (!hasMinLength) missing.push('≥6 ký tự');
        if (!hasLetter) missing.push('chữ cái');
        if (!hasDigit) missing.push('chữ số');
        if (!hasSpecial) missing.push('ký tự đặc biệt');
        bar.className = 'progress-bar bg-danger';
        text.textContent = 'Thiếu: ' + missing.join(', ');
        text.className = 'text-danger';
    } else if (score <= 3) {
        bar.className = 'progress-bar bg-warning';
        text.textContent = 'Yếu — nên dùng mật khẩu dài hơn';
        text.className = 'text-warning';
    } else if (score <= 4) {
        bar.className = 'progress-bar bg-info';
        text.textContent = 'Trung bình — có thể dùng thêm';
        text.className = 'text-info';
    } else {
        bar.className = 'progress-bar bg-success';
        text.textContent = 'Mật khẩu mạnh';
        text.className = 'text-success';
    }
}

// ── Check confirm password match (real-time) ──
function checkPasswordMatchLive() {
    var pwd = document.getElementById('newPasswordField').value;
    var confirm = document.getElementById('confirmPasswordField').value;
    var errEl = document.getElementById('confirmPasswordError');
    var field = document.getElementById('confirmPasswordField');
    if (!errEl || !field) return;

    if (confirm.length > 0 && pwd !== confirm) {
        field.classList.add('is-invalid');
        errEl.textContent = 'Mật khẩu xác nhận không khớp.';
        errEl.style.display = 'block';
    } else if (confirm.length > 0 && pwd === confirm) {
        field.classList.remove('is-invalid');
        field.classList.add('is-valid');
        errEl.style.display = 'none';
    } else {
        field.classList.remove('is-invalid', 'is-valid');
        errEl.style.display = 'none';
    }
}

// ── Validate toàn bộ form reset password (khi submit) ──
function validateResetPassword() {
    var pwd = document.getElementById('newPasswordField').value.trim();
    var confirm = document.getElementById('confirmPasswordField').value.trim();
    var valid = true;

    // Reset previous errors
    var pwdField = document.getElementById('newPasswordField');
    var confirmField = document.getElementById('confirmPasswordField');
    var pwdErr = document.getElementById('newPasswordError');
    var confirmErr = document.getElementById('confirmPasswordError');
    pwdField.classList.remove('is-invalid');
    confirmField.classList.remove('is-invalid', 'is-valid');
    if (pwdErr) { pwdErr.style.display = 'none'; }
    if (confirmErr) { confirmErr.style.display = 'none'; }

    // 1. Validate password không rỗng
    if (pwd.length === 0) {
        pwdField.classList.add('is-invalid');
        if (pwdErr) { pwdErr.textContent = 'Vui lòng nhập mật khẩu mới.'; pwdErr.style.display = 'block'; }
        valid = false;
    }
    // 2. Validate độ dài tối thiểu
    else if (pwd.length < 6) {
        pwdField.classList.add('is-invalid');
        if (pwdErr) { pwdErr.textContent = 'Mật khẩu phải có ít nhất 6 ký tự.'; pwdErr.style.display = 'block'; }
        valid = false;
    }
    // 3. Validate độ dài tối đa
    else if (pwd.length > 50) {
        pwdField.classList.add('is-invalid');
        if (pwdErr) { pwdErr.textContent = 'Mật khẩu không được vượt quá 50 ký tự.'; pwdErr.style.display = 'block'; }
        valid = false;
    }
    // 4. Validate phải có chữ cái
    else if (!/[a-zA-Z]/.test(pwd)) {
        pwdField.classList.add('is-invalid');
        if (pwdErr) { pwdErr.textContent = 'Mật khẩu phải có ít nhất 1 chữ cái (a-z, A-Z).'; pwdErr.style.display = 'block'; }
        valid = false;
    }
    // 5. Validate phải có chữ số
    else if (!/[0-9]/.test(pwd)) {
        pwdField.classList.add('is-invalid');
        if (pwdErr) { pwdErr.textContent = 'Mật khẩu phải có ít nhất 1 chữ số (0-9).'; pwdErr.style.display = 'block'; }
        valid = false;
    }
    // 6. Validate phải có ký tự đặc biệt
    else if (!/[^a-zA-Z0-9]/.test(pwd)) {
        pwdField.classList.add('is-invalid');
        if (pwdErr) { pwdErr.textContent = 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt (!@#$%^&*...).'; pwdErr.style.display = 'block'; }
        valid = false;
    }

    // 4. Validate confirm password
    if (confirm.length === 0) {
        confirmField.classList.add('is-invalid');
        if (confirmErr) { confirmErr.textContent = 'Vui lòng xác nhận mật khẩu mới.'; confirmErr.style.display = 'block'; }
        valid = false;
    } else if (pwd !== confirm) {
        confirmField.classList.add('is-invalid');
        if (confirmErr) { confirmErr.textContent = 'Mật khẩu xác nhận không khớp.'; confirmErr.style.display = 'block'; }
        valid = false;
    }

    if (!valid) {
        // Scroll đến lỗi đầu tiên
        if (pwdField.classList.contains('is-invalid')) {
            pwdField.focus();
        } else if (confirmField.classList.contains('is-invalid')) {
            confirmField.focus();
        }
        return false;
    }

    // Xác nhận lần cuối
    return confirm('Bạn có chắc chắn muốn đặt lại mật khẩu cho người dùng này?\n\n'
        + 'Hành động này không thể hoàn tác. Người dùng sẽ phải đăng nhập bằng mật khẩu mới.');
}

// ── Toggle password visibility ──
function togglePassword(fieldId, btn) {
    var field = document.getElementById(fieldId);
    var icon = btn.querySelector('i');
    if (field.type === 'password') {
        field.type = 'text';
        icon.className = 'bi bi-eye-slash-fill';
    } else {
        field.type = 'password';
        icon.className = 'bi bi-eye-fill';
    }
}

// ── Initialize tooltips ──
document.addEventListener('DOMContentLoaded', function() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (el) {
        return new bootstrap.Tooltip(el);
    });

    // Auto-open add modal nếu validation fail
    <c:if test="${showAddModal}">
        new bootstrap.Modal(document.getElementById('addUserModal')).show();
    </c:if>
    // Auto-open edit modal nếu validation fail
    <c:if test="${showEditModal}">
        new bootstrap.Modal(document.getElementById('editUserModal')).show();
    </c:if>
    // Auto-open reset password modal nếu validation fail
    <c:if test="${showResetPwdModal}">
        // Set lại giá trị modal từ server attributes
        var resetUserId = '${resetPwdUserId}';
        var resetUserName = '${fn:escapeXml(resetPwdUserName)}';
        if (resetUserId) document.getElementById('resetPwdUserId').value = resetUserId;
        if (resetUserName) document.getElementById('resetPwdName').value = resetUserName;
        new bootstrap.Modal(document.getElementById('resetPasswordModal')).show();
    </c:if>
});
</script>

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
