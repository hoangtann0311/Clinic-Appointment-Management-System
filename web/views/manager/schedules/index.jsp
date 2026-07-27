<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lí Lịch Làm Việc — CAMS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        /* Schedule-specific styles on top of admin.css Pink Theme */
        :root {
            --shift-morning: #e3f2fd;
            --shift-afternoon: #fff3e0;
            --shift-evening: #f3e5f5;
            --shift-morning-text: #1565c0;
            --shift-afternoon-text: #e65100;
            --shift-evening-text: #7b1fa2;
        }

        .badge-status-pending {
            background: #fff3e0; color: #e65100;
            border: 1px solid #ffcc80; font-weight: 600;
            border-radius: var(--r-sm); padding: 0.25rem 0.65rem;
        }
        .badge-status-approved {
            background: #e8f5e9; color: #2e7d32;
            border: 1px solid #a5d6a7; font-weight: 600;
            border-radius: var(--r-sm); padding: 0.25rem 0.65rem;
        }
        .badge-status-rejected {
            background: #ffebee; color: #c62828;
            border: 1px solid #ef9a9a; font-weight: 600;
            border-radius: var(--r-sm); padding: 0.25rem 0.65rem;
        }
        .badge-status-cancelled {
            background: #eceff1; color: #546e7a;
            border: 1px solid #b0bec5; font-weight: 600;
            border-radius: var(--r-sm); padding: 0.25rem 0.65rem;
        }

        .shift-badge-morning {
            background: var(--shift-morning); color: var(--shift-morning-text);
            padding: 0.2rem 0.6rem; border-radius: var(--r-sm);
            font-weight: 600; font-size: 0.78rem; white-space: nowrap;
        }
        .shift-badge-afternoon {
            background: var(--shift-afternoon); color: var(--shift-afternoon-text);
            padding: 0.2rem 0.6rem; border-radius: var(--r-sm);
            font-weight: 600; font-size: 0.78rem; white-space: nowrap;
        }
        .shift-badge-evening {
            background: var(--shift-evening); color: var(--shift-evening-text);
            padding: 0.2rem 0.6rem; border-radius: var(--r-sm);
            font-weight: 600; font-size: 0.78rem; white-space: nowrap;
        }

        .btn-approve {
            background: linear-gradient(135deg, #2e7d32, #43a047);
            color: #fff; border: none; font-weight: 700;
            border-radius: var(--r-sm); padding: 0.45rem 1rem;
            transition: all var(--t-fast);
            display: inline-flex; align-items: center; gap: 0.3rem;
        }
        .btn-approve:hover {
            background: linear-gradient(135deg, #1b5e20, #2e7d32);
            color: #fff; transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(46,125,50,0.3);
        }
        .btn-reject {
            background: linear-gradient(135deg, #c62828, #e53935);
            color: #fff; border: none; font-weight: 700;
            border-radius: var(--r-sm); padding: 0.45rem 1rem;
            transition: all var(--t-fast);
            display: inline-flex; align-items: center; gap: 0.3rem;
        }
        .btn-reject:hover {
            background: linear-gradient(135deg, #b71c1c, #c62828);
            color: #fff; transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(198,40,40,0.3);
        }

        /* ═══════════════════════════════════════════════════════
           ACTION PANEL — Sticky top-right, luôn hiển thị
           ═══════════════════════════════════════════════════════ */
        .action-panel-wrapper {
            position: sticky; top: 0.75rem; z-index: 1020;
            float: right; width: 380px; max-width: 40%;
            margin-left: 1.5rem; margin-bottom: 1rem;
        }
        .action-panel {
            background: var(--c-surface);
            border: 2px solid var(--c-outline-variant);
            border-radius: var(--r-lg);
            overflow: hidden;
            box-shadow: var(--shadow-md);
            transition: all var(--t-smooth);
        }
        .action-panel.active {
            border-color: var(--pink-400);
            box-shadow: 0 8px 32px rgba(184,102,137,0.15), 0 2px 8px rgba(0,0,0,0.08);
        }
        .action-panel-header {
            padding: 0.65rem 1rem;
            background: linear-gradient(135deg, var(--pink-50), #fff1f6);
            border-bottom: 1px solid var(--pink-200);
            display: flex; align-items: center; gap: 0.5rem;
            font-family: var(--font-display);
        }
        .action-panel-header-icon {
            width: 36px; height: 36px; border-radius: var(--r-sm);
            background: linear-gradient(135deg, var(--pink-500), var(--pink-700));
            color: #fff; display: flex; align-items: center; justify-content: center;
            font-size: 1rem; flex-shrink: 0;
        }
        .action-panel-header-title {
            font-weight: 800; font-size: 0.85rem; color: var(--c-primary-dark);
            letter-spacing: 0.02em;
        }
        .action-panel-header-subtitle {
            font-size: 0.7rem; color: var(--c-muted); font-weight: 500;
        }
        .action-panel-body {
            padding: 1rem;
            min-height: 80px;
            display: flex; align-items: center; justify-content: center;
        }
        .action-panel-placeholder {
            text-align: center; color: var(--c-muted);
        }
        .action-panel-placeholder i {
            font-size: 2rem; display: block; margin-bottom: 0.4rem;
            color: var(--c-outline);
        }
        .action-panel-placeholder span {
            font-size: 0.78rem; font-weight: 600;
        }
        .action-panel-selected {
            width: 100%; display: none;
        }
        .action-panel-selected.show { display: block; }
        .action-panel-doctor {
            display: flex; align-items: center; gap: 0.65rem; margin-bottom: 0.6rem;
        }
        .action-panel-avatar {
            width: 40px; height: 40px; border-radius: 50%;
            background: linear-gradient(135deg, var(--pink-500), var(--pink-700));
            color: #fff; display: flex; align-items: center; justify-content: center;
            font-weight: 800; font-size: 0.95rem; flex-shrink: 0;
        }
        .action-panel-doctor-name {
            font-weight: 700; font-size: 0.88rem; color: var(--c-on-surface); line-height: 1.2;
        }
        .action-panel-doctor-spec {
            font-size: 0.7rem; color: var(--c-muted); font-weight: 500;
        }
        .action-panel-meta {
            display: flex; flex-wrap: wrap; gap: 0.4rem; margin-bottom: 0.75rem;
        }
        .action-panel-meta-tag {
            font-size: 0.7rem; font-weight: 600; padding: 0.2rem 0.5rem;
            border-radius: var(--r-xs); background: var(--pink-50);
            color: var(--pink-600); display: inline-flex; align-items: center; gap: 0.25rem;
            border: 1px solid var(--pink-200);
        }
        .action-panel-buttons-row {
            display: flex; gap: 0.5rem;
        }
        .action-panel-buttons-row .btn-approve,
        .action-panel-buttons-row .btn-reject {
            flex: 1; justify-content: center; padding: 0.6rem 1rem;
            font-size: 0.85rem; font-weight: 700; letter-spacing: 0.02em;
        }
        .action-panel-buttons-row .btn-approve i,
        .action-panel-buttons-row .btn-reject i {
            font-size: 1.1rem;
        }
        .action-panel-footer {
            padding: 0.5rem 1rem; border-top: 1px solid var(--c-outline-variant);
            background: var(--pink-50); text-align: center;
        }
        .action-panel-footer-text {
            font-size: 0.68rem; color: var(--c-muted); font-weight: 500;
        }
        .action-panel-footer-text i { color: var(--pink-400); }

        /* Row selection styling */
        .schedule-row-pending {
            cursor: pointer;
            transition: all var(--t-fast);
            position: relative;
        }
        .schedule-row-pending:hover {
            background: linear-gradient(90deg, rgba(184,102,137,0.04), rgba(184,102,137,0.08)) !important;
        }
        .schedule-row-pending.selected {
            background: linear-gradient(90deg, rgba(184,102,137,0.08), rgba(184,102,137,0.14)) !important;
            outline: 2px solid var(--pink-400); outline-offset: -2px;
            box-shadow: inset 4px 0 0 var(--pink-500);
        }
        .schedule-row-pending.selected td:first-child::before {
            content: '▶'; font-size: 0.55rem; color: var(--pink-500);
            margin-right: 0.35rem; vertical-align: middle;
        }

        /* Responsive: panel xuống dưới trên mobile */
        @media (max-width: 992px) {
            .action-panel-wrapper {
                float: none; width: 100%; max-width: 100%;
                margin-left: 0; position: static;
            }
        }

        .btn-primary-pink {
            background: linear-gradient(135deg, var(--pink-500), var(--pink-600));
            color: #fff; border: none; font-weight: 700;
            border-radius: var(--r-sm); padding: 0.55rem 1.2rem;
            transition: all var(--t-fast); font-family: var(--font-body);
        }
        .btn-primary-pink:hover {
            background: linear-gradient(135deg, var(--pink-600), var(--pink-700));
            color: #fff; transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(184,102,137,0.3);
        }

        .kpi-mini-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 0.75rem; margin-bottom: 1.25rem; }
        .kpi-mini { background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-md); padding: 1rem 1.1rem; display: flex; align-items: center; gap: 0.875rem; transition: all var(--t-smooth); }
        .kpi-mini:hover { border-color: var(--pink-200); box-shadow: var(--shadow-sm); transform: translateY(-2px); }
        .kpi-mini-icon { width: 44px; height: 44px; border-radius: var(--r-sm); display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; color: #fff; }
        .kmi-pending  { background: linear-gradient(135deg, #f57c00, #e65100); }
        .kmi-approved { background: linear-gradient(135deg, #2e7d32, #1b5e20); }
        .kmi-rejected { background: linear-gradient(135deg, #c62828, #b71c1c); }
        .kmi-cancelled { background: linear-gradient(135deg, #546e7a, #37474f); }
        .kmi-total    { background: linear-gradient(135deg, #6366f1, #4f46e5); }
        .kpi-mini-body { flex: 1; min-width: 0; }
        .kpi-mini-value { font-family: var(--font-display); font-size: 1.3rem; font-weight: 900; color: var(--c-on-surface); line-height: 1.1; }
        .kpi-mini-label { font-size: 0.7rem; font-weight: 600; color: var(--c-muted); text-transform: uppercase; letter-spacing: 0.05em; }

        .filter-bar { display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: center; }
        .filter-bar .form-control, .filter-bar .form-select {
            width: auto; min-width: 150px; border-radius: var(--r-sm);
            border: 1px solid var(--c-outline); font-size: 0.85rem; padding: 0.45rem 0.75rem;
        }
        .filter-bar .form-control:focus, .filter-bar .form-select:focus {
            border-color: var(--pink-500); box-shadow: 0 0 0 0.2rem rgba(184,102,137,0.15);
        }

        .admin-pagination { display: flex; justify-content: center; gap: 0.25rem; margin-top: 1.25rem; }
        .admin-pagination a, .admin-pagination span {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 38px; height: 38px; padding: 0 0.5rem; border-radius: var(--r-sm);
            font-size: 0.85rem; font-weight: 600; text-decoration: none;
            border: 1px solid var(--c-outline-variant); color: var(--c-on-surface-var);
            transition: all var(--t-fast);
        }
        .admin-pagination a:hover { background: var(--pink-50); border-color: var(--pink-200); color: var(--c-primary); }
        .admin-pagination .active { background: var(--pink-500); color: #fff; border-color: var(--pink-500); }
        .admin-pagination .disabled { opacity: 0.4; pointer-events: none; }

        .doctor-avatar-sm {
            width: 32px; height: 32px; border-radius: 50%;
            background: var(--pink-100); color: var(--pink-600);
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 0.8rem; flex-shrink: 0;
        }
        .rejection-reason-cell {
            max-width: 200px; overflow: hidden; text-overflow: ellipsis;
            white-space: nowrap; font-size: 0.8rem; color: var(--c-muted);
            cursor: pointer;
        }
        .rejection-reason-cell:hover { white-space: normal; }

        .modal-content { border-radius: var(--r-lg) !important; border: 1px solid var(--c-outline-variant) !important; }
        .modal-header { background: var(--pink-50) !important; border-bottom: 1px solid var(--pink-200) !important; }
        .modal-header .modal-title { font-family: var(--font-display); font-weight: 800; color: var(--c-primary-dark); }
        .modal-footer { border-top: 1px solid var(--c-outline-variant) !important; }

        .detail-card { background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-md); padding: 1.25rem; margin-bottom: 1rem; }
        .detail-label { font-size: 0.75rem; font-weight: 600; color: var(--c-muted); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 0.2rem; }
        .detail-value { font-size: 0.9rem; font-weight: 600; color: var(--c-on-surface); }

        .warning-list { list-style: none; padding: 0; margin: 0; }
        .warning-list li {
            padding: 0.5rem 0.75rem; margin-bottom: 0.35rem;
            background: #fff8e1; border-left: 3px solid #ff8f00;
            color: #e65100; border-radius: 0 var(--r-sm) var(--r-sm) 0;
            font-size: 0.82rem; display: flex; align-items: flex-start; gap: 0.5rem;
        }

        /* Shift row styles */
        .shift-active { border-left: 3px solid #2e7d32; }
        .shift-inactive { border-left: 3px solid #b0bec5; opacity: 0.7; }
        .shift-inactive:hover { opacity: 1; }

        /* Tab styling */
        .nav-tabs .nav-link {
            border: none; border-bottom: 2px solid transparent;
            border-radius: var(--r-sm) var(--r-sm) 0 0;
            padding: 0.55rem 1.2rem; transition: all var(--t-fast);
            font-family: var(--font-body);
        }

        /* ═══════════════════════════════════════════════════════
           SHIFT CARDS — 3 ca chuẩn
           ═══════════════════════════════════════════════════════ */
        .shift-cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 1.25rem;
        }
        .shift-card {
            background: var(--c-surface);
            border: 2px solid var(--c-outline-variant);
            border-radius: var(--r-lg);
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            transition: all var(--t-smooth);
            position: relative;
            overflow: hidden;
        }
        .shift-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-md);
        }
        .shift-card--active {
            border-color: var(--c-outline-variant);
        }
        .shift-card--inactive {
            opacity: 0.55;
            background: #f9f9f9;
        }
        .shift-card--inactive:hover {
            opacity: 0.8;
        }

        .shift-card-icon {
            width: 64px; height: 64px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.8rem; margin-bottom: 0.75rem;
            flex-shrink: 0;
        }
        .shift-card--morning .shift-card-icon {
            background: linear-gradient(135deg, #e3f2fd, #bbdefb);
            color: #1565c0;
        }
        .shift-card--afternoon .shift-card-icon {
            background: linear-gradient(135deg, #fff3e0, #ffe0b2);
            color: #e65100;
        }
        .shift-card--evening .shift-card-icon {
            background: linear-gradient(135deg, #f3e5f5, #e1bee7);
            color: #7b1fa2;
        }

        .shift-card-body { flex: 1; min-width: 0; width: 100%; }
        .shift-card-name {
            font-family: var(--font-display);
            font-weight: 800; font-size: 1.15rem;
            color: var(--c-on-surface);
            margin: 0 0 0.15rem 0;
            display: flex; align-items: center; justify-content: center; gap: 0.5rem;
            flex-wrap: wrap;
        }
        .shift-card-time-label {
            font-size: 0.65rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.08em;
            padding: 0.15rem 0.5rem; border-radius: 1rem;
            background: var(--pink-50); color: var(--pink-600);
        }
        .shift-card-time {
            font-size: 0.95rem; font-weight: 700;
            color: var(--c-primary); margin-bottom: 0.25rem;
        }
        .shift-card-desc {
            font-size: 0.75rem; color: var(--c-muted);
            margin-top: 0.25rem; line-height: 1.3;
        }

        .shift-card-action {
            margin-top: 1rem; width: 100%;
            display: flex; flex-direction: column; align-items: center;
            gap: 0.4rem;
        }
        .shift-status-badge {
            font-size: 0.75rem; font-weight: 700;
            padding: 0.25rem 0.75rem; border-radius: 1rem;
            display: inline-flex; align-items: center; gap: 0.3rem;
        }
        .shift-status-badge--active {
            background: #e8f5e9; color: #2e7d32;
            border: 1px solid #a5d6a7;
        }
        .shift-status-badge--inactive {
            background: #eceff1; color: #546e7a;
            border: 1px solid #b0bec5;
        }

        .shift-toggle-btn {
            font-size: 0.8rem; font-weight: 700; border: none;
            padding: 0.45rem 1.25rem; border-radius: var(--r-sm);
            cursor: pointer; transition: all var(--t-fast);
            display: inline-flex; align-items: center; gap: 0.3rem;
        }
        .shift-toggle-btn--off {
            background: linear-gradient(135deg, #546e7a, #78909c);
            color: #fff;
        }
        .shift-toggle-btn--off:hover {
            background: linear-gradient(135deg, #37474f, #546e7a);
            box-shadow: 0 4px 12px rgba(84,110,122,0.35);
        }
        .shift-toggle-btn--on {
            background: linear-gradient(135deg, #2e7d32, #43a047);
            color: #fff;
        }
        .shift-toggle-btn--on:hover {
            background: linear-gradient(135deg, #1b5e20, #2e7d32);
            box-shadow: 0 4px 12px rgba(46,125,50,0.35);
        }

        /* ═══════════════════════════════════════════════════════
           SHIFT GROUP ACCORDION
           ═══════════════════════════════════════════════════════ */
        .shift-group-card {
            transition: all var(--t-smooth);
        }
        .shift-group-card:hover {
            box-shadow: var(--shadow-sm);
        }
        .shift-group-header {
            transition: all var(--t-fast);
        }
        .shift-group-header:hover {
            filter: brightness(0.97);
        }
        .shift-group-chevron {
            transition: transform 0.3s ease;
        }
        .shift-group-header[aria-expanded="true"] .shift-group-chevron {
            transform: rotate(180deg);
        }
        .shift-group-header[aria-expanded="false"] .shift-group-chevron {
            transform: rotate(0deg);
        }
    </style>
</head>
<body class="admin-body">

<%-- ============================================================
     TOP BAR
     ============================================================ --%>
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
                    ${not empty sessionScope.user.fullName ? fn:substring(sessionScope.user.fullName, 0, 1) : '?'}
                </div>
                <span class="d-none d-md-inline fw-semibold text-dark">${sessionScope.user.fullName}</span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg rounded-3" aria-labelledby="adminUserDropdown">
                <li class="dropdown-header">
                    <h6 class="text-dark mb-0 fw-bold">${sessionScope.user.fullName}</h6>
                    <small class="text-muted">
                        <c:out value="${sessionScope.user.roleNameDisplay}" />
                    </small>
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

<%-- ============================================================
     SIDEBAR
     ============================================================ --%>
<%@ include file="../layout/sidebar.jsp" %>

<%-- ============================================================
     MAIN CONTENT
     ============================================================ --%>
<main class="admin-main" id="adminMain">

    <%-- Page Header --%>
    <div class="admin-page-header">
        <div>
            <h1 class="admin-page-title">
                <i class="bi bi-calendar-check me-2" style="color:#b86689;"></i>Quản Lí Lịch Làm Việc
            </h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-people-fill"></i>
                <c:choose>
                    <c:when test="${tab eq 'shifts'}">Quản lý các ca làm việc và duyệt đăng ký lịch của bác sĩ</c:when>
                    <c:otherwise>Xác nhận hoặc từ chối đăng ký lịch làm việc của bác sĩ lâm sàng</c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <%-- ============================================================
         TAB NAVIGATION
         ============================================================ --%>
    <ul class="nav nav-tabs mb-3" style="border-bottom: 2px solid var(--pink-200);">
        <li class="nav-item">
            <a class="nav-link ${tab eq 'shifts' ? 'active' : ''}"
               href="?tab=shifts"
               style="${tab eq 'shifts' ? 'background: var(--pink-50); border-color: var(--pink-200) var(--pink-200) var(--c-surface); color: var(--pink-700); font-weight: 700;' : 'color: var(--c-muted); font-weight: 600;'}">
                <i class="bi bi-layers-fill me-1"></i>Quản lý ca làm việc
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${tab ne 'shifts' ? 'active' : ''}"
               href="?tab=schedules"
               style="${tab ne 'shifts' ? 'background: var(--pink-50); border-color: var(--pink-200) var(--pink-200) var(--c-surface); color: var(--pink-700); font-weight: 700;' : 'color: var(--c-muted); font-weight: 600;'}">
                <i class="bi bi-calendar-check me-1"></i>Duyệt đăng ký lịch
            </a>
        </li>
    </ul>

    <%-- ============================================================
         ALERT MESSAGES
         ============================================================ --%>
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show" data-cams-toast role="alert">
            <c:choose>
                <c:when test="${success eq 'approved'}">
                    <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                    <div><strong>Xác nhận thành công!</strong> Lịch làm việc #${param.id} đã được đưa vào lịch chính thức.</div>
                </c:when>
                <c:when test="${success eq 'rejected'}">
                    <i class="bi bi-x-circle-fill me-2 fs-5"></i>
                    <div><strong>Đã từ chối!</strong> Lịch làm việc #${param.id} không được xác nhận. Bác sĩ sẽ nhận được lý do.</div>
                </c:when>
                <c:otherwise>
                    <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                    <div>Thao tác thành công.</div>
                </c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" data-cams-toast role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div>${fn:escapeXml(error)}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <%-- ============================================================
         SHIFT MANAGEMENT SECTION (tab = shifts)
         ============================================================ --%>
    <c:if test="${tab eq 'shifts'}">

    <%-- Shift toggle alert --%>
    <c:if test="${success eq 'shiftToggled'}">
        <div class="alert alert-info alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md);">
            <i class="bi bi-info-circle-fill me-2 fs-5"></i>
            <div><strong>Đã cập nhật!</strong> Trạng thái ca làm việc đã được thay đổi.</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty shiftErrors}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md);">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div><strong>${fn:escapeXml(shiftErrors.general)}</strong></div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <%-- Section header with Add button --%>
    <div class="mb-3 d-flex justify-content-between align-items-start">
        <div>
            <h5 style="font-family:var(--font-display);font-weight:800;color:var(--c-primary-dark);margin:0;">
                <i class="bi bi-layers-fill me-2" style="color:#b86689;"></i>Danh Sách Ca Làm Việc Chuẩn
            </h5>
            <p style="font-size:0.8rem;color:var(--c-muted);margin:0.25rem 0 0 0;">
                <i class="bi bi-info-circle me-1"></i>Hệ thống vận hành với 3 ca cố định. Tắt ca để tạm ngưng nhận đăng ký lịch.
            </p>
        </div>
        <button type="button" class="btn btn-primary-pink" onclick="openShiftModal('create')">
            <i class="bi bi-plus-lg me-1"></i>Thêm Ca Làm Việc
        </button>
    </div>

    <%-- 3 Shift Cards --%>
    <div class="shift-cards-grid">
        <c:choose>
            <c:when test="${not empty shifts}">
                <c:forEach var="shift" items="${shifts}" varStatus="row">
                    <%-- Determine card theme based on start time --%>
                    <c:set var="cardTheme" value="morning"/>
                    <c:set var="cardIcon" value="bi-sunrise-fill"/>
                    <c:set var="cardTimeLabel" value="Buổi sáng"/>
                    <c:choose>
                        <c:when test="${fn:substring(shift.startTime.toString(), 0, 5) eq '13:00'}">
                            <c:set var="cardTheme" value="afternoon"/>
                            <c:set var="cardIcon" value="bi-sun-fill"/>
                            <c:set var="cardTimeLabel" value="Buổi chiều"/>
                        </c:when>
                        <c:when test="${fn:substring(shift.startTime.toString(), 0, 5) eq '19:00'}">
                            <c:set var="cardTheme" value="evening"/>
                            <c:set var="cardIcon" value="bi-moon-stars-fill"/>
                            <c:set var="cardTimeLabel" value="Buổi tối"/>
                        </c:when>
                    </c:choose>

                    <div class="shift-card shift-card--${cardTheme} ${shift.active ? 'shift-card--active' : 'shift-card--inactive'}">
                        <%-- Icon --%>
                        <div class="shift-card-icon">
                            <i class="bi ${cardIcon}"></i>
                        </div>
                        <%-- Info --%>
                        <div class="shift-card-body">
                            <h3 class="shift-card-name">
                                ${fn:escapeXml(shift.name)}
                                <span class="shift-card-time-label">${cardTimeLabel}</span>
                            </h3>
                            <div class="shift-card-time">
                                <i class="bi bi-clock me-1"></i>
                                ${fn:substring(shift.startTime.toString(), 0, 5)} — ${fn:substring(shift.endTime.toString(), 0, 5)}
                            </div>
                            <c:if test="${not empty shift.description}">
                                <div class="shift-card-desc">${fn:escapeXml(shift.description)}</div>
                            </c:if>
                        </div>
                        <%-- Status & Action --%>
                        <div class="shift-card-action">
                            <c:choose>
                                <c:when test="${shift.active}">
                                    <span class="shift-status-badge shift-status-badge--active">
                                        <i class="bi bi-check-circle-fill me-1"></i>Đang hoạt động
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="shift-status-badge shift-status-badge--inactive">
                                        <i class="bi bi-pause-circle-fill me-1"></i>Đã tắt
                                    </span>
                                </c:otherwise>
                            </c:choose>
                            <form method="post" action="${pageContext.request.contextPath}/manager/schedules/" style="margin-top:0.5rem;"
                                  onsubmit="return confirm('Bạn có chắc muốn ${shift.active ? 'TẮT' : 'BẬT'} ca \'${fn:escapeXml(shift.name)}\'?\n\n${shift.active ? 'Bác sĩ sẽ không thể đăng ký lịch cho ca này.' : 'Bác sĩ sẽ có thể đăng ký lịch cho ca này trở lại.'}')">
                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="toggleShift">
                                <input type="hidden" name="shiftId" value="${shift.id}">
                                <input type="hidden" name="shiftActive" value="${!shift.active}">
                                <button type="submit" class="shift-toggle-btn ${shift.active ? 'shift-toggle-btn--off' : 'shift-toggle-btn--on'}">
                                    <c:choose>
                                        <c:when test="${shift.active}">
                                            <i class="bi bi-toggle2-off me-1"></i>Tắt ca
                                        </c:when>
                                        <c:otherwise>
                                            <i class="bi bi-toggle2-on me-1"></i>Bật ca
                                        </c:otherwise>
                                    </c:choose>
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="admin-empty-state" style="grid-column:1/-1;">
                    <i class="bi bi-exclamation-triangle" style="font-size:3rem;color:#e65100;"></i>
                    <h6>Chưa có ca làm việc chuẩn</h6>
                    <p>Vui lòng chạy script <code>docs/CleanShifts.sql</code> để tạo 3 ca chuẩn: Ca sáng (07-11), Ca chiều (13-17), Ca tối (19-23).</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    </c:if>

    <%-- ============================================================
         SCHEDULE APPROVAL SECTION (tab = schedules, default)
         ============================================================ --%>
    <c:if test="${tab ne 'shifts'}">

    <%-- ============================================================
         FILTER BAR
         ============================================================ --%>
    <div class="admin-card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/manager/schedules/" class="filter-bar">
                <input type="hidden" name="tab" value="schedules">
                <select name="status" class="form-select">
                    <option value="">Tất cả trạng thái</option>
                    <option value="PENDING" ${statusFilter eq 'PENDING' ? 'selected' : ''}>Chờ xác nhận</option>
                    <option value="APPROVED" ${statusFilter eq 'APPROVED' ? 'selected' : ''}>Đã xác nhận</option>
                    <option value="REJECTED" ${statusFilter eq 'REJECTED' ? 'selected' : ''}>Đã từ chối</option>
                </select>
                <select name="doctorId" class="form-select">
                    <option value="">Tất cả Bác sĩ lâm sàng</option>
                    <c:forEach var="doc" items="${doctors}">
                        <option value="${doc.id}" ${doctorIdFilter eq doc.id.toString() ? 'selected' : ''}>
                            ${fn:escapeXml(doc.fullName)} <c:if test="${not empty doc.specialization}">(${fn:escapeXml(doc.specialization)})</c:if>
                        </option>
                    </c:forEach>
                </select>
                <div class="input-group" style="max-width:170px;">
                    <span class="input-group-text" style="background:var(--pink-50);border-color:var(--c-outline);"><i class="bi bi-calendar3"></i></span>
                    <input type="date" name="dateFrom" class="form-control" value="${dateFromFilter}" title="Từ ngày">
                </div>
                <div class="input-group" style="max-width:170px;">
                    <span class="input-group-text" style="background:var(--pink-50);border-color:var(--c-outline);"><i class="bi bi-calendar3"></i></span>
                    <input type="date" name="dateTo" class="form-control" value="${dateToFilter}" title="Đến ngày">
                </div>
                <button type="submit" class="btn btn-primary-pink">
                    <i class="bi bi-funnel-fill me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/manager/schedules/?tab=schedules" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-counterclockwise me-1"></i>Đặt lại
                </a>
            </form>
        </div>
    </div>

    <%-- ============================================================
         GROUPED SCHEDULES BY SHIFT (accordion)
         ============================================================ --%>
    <c:set var="hasAnySchedules" value="false"/>
    <c:forEach var="entry" items="${groupedSchedules}">
        <c:if test="${not empty entry.value}">
            <c:set var="hasAnySchedules" value="true"/>
        </c:if>
    </c:forEach>

    <c:choose>
        <c:when test="${hasAnySchedules}">

            <c:forEach var="entry" items="${groupedSchedules}" varStatus="shiftLoop">
                <c:set var="shiftKey" value="${entry.key}"/>
                <c:set var="shiftSchedules" value="${entry.value}"/>
                <c:set var="schedCount" value="${fn:length(shiftSchedules)}"/>

                <%-- Determine shift theme --%>
                <c:set var="accordionIcon" value="bi-sunrise-fill"/>
                <c:set var="accordionColor" value="#1565c0"/>
                <c:set var="accordionBg" value="#e3f2fd"/>
                <c:set var="accordionBorder" value="#90caf9"/>
                <c:if test="${shiftKey eq 'Ca chiều'}">
                    <c:set var="accordionIcon" value="bi-sun-fill"/>
                    <c:set var="accordionColor" value="#e65100"/>
                    <c:set var="accordionBg" value="#fff3e0"/>
                    <c:set var="accordionBorder" value="#ffcc80"/>
                </c:if>
                <c:if test="${shiftKey eq 'Ca tối'}">
                    <c:set var="accordionIcon" value="bi-moon-stars-fill"/>
                    <c:set var="accordionColor" value="#7b1fa2"/>
                    <c:set var="accordionBg" value="#f3e5f5"/>
                    <c:set var="accordionBorder" value="#ce93d8"/>
                </c:if>

                <div class="shift-group-card" style="border:1px solid ${accordionBorder};border-radius:var(--r-lg);margin-bottom:1rem;overflow:hidden;">
                    <%-- Accordion Header --%>
                    <button class="shift-group-header"
                            type="button"
                            data-bs-toggle="collapse"
                            data-bs-target="#collapseShift${shiftLoop.index}"
                            aria-expanded="${schedCount > 0 ? 'true' : 'false'}"
                            style="background:${accordionBg};border:none;width:100%;padding:0.85rem 1.25rem;display:flex;align-items:center;justify-content:space-between;cursor:pointer;transition:all var(--t-fast);">
                        <div style="display:flex;align-items:center;gap:0.75rem;">
                            <span style="font-size:1.4rem;color:${accordionColor};width:40px;height:40px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,0.7);border-radius:50%;">
                                <i class="bi ${accordionIcon}"></i>
                            </span>
                            <div style="text-align:left;">
                                <strong style="font-size:0.95rem;color:${accordionColor};font-family:var(--font-display);">
                                    ${shiftKey}
                                </strong>
                                <div style="font-size:0.75rem;color:var(--c-muted);font-weight:500;">
                                    <c:choose>
                                        <c:when test="${shiftKey eq 'Ca sáng'}">07:00 — 11:00</c:when>
                                        <c:when test="${shiftKey eq 'Ca chiều'}">13:00 — 17:00</c:when>
                                        <c:when test="${shiftKey eq 'Ca tối'}">19:00 — 23:00</c:when>
                                        <c:otherwise>${shiftKey}</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                        <div style="display:flex;align-items:center;gap:0.75rem;">
                            <span style="background:${accordionColor};color:#fff;padding:0.25rem 0.65rem;border-radius:1rem;font-size:0.75rem;font-weight:700;">
                                ${schedCount} lịch
                            </span>
                            <i class="bi bi-chevron-down shift-group-chevron" style="color:${accordionColor};transition:transform 0.3s;"></i>
                        </div>
                    </button>

                    <%-- Accordion Body --%>
                    <div id="collapseShift${shiftLoop.index}" class="collapse ${schedCount > 0 ? 'show' : ''}">
                        <div style="padding:0.5rem;">
                            <div class="admin-table-wrapper">
                                <table class="admin-table" style="table-layout:fixed;min-width:1150px;">
                                    <thead>
                                        <tr>
                                            <th style="width:40px;">#</th>
                                            <th style="width:145px;">Bác sĩ</th>
                                            <th style="width:110px;">Chuyên Khoa</th>
                                            <th style="width:95px;">Ngày Trực</th>
                                            <th style="width:70px;">SL Tối Đa</th>
                                            <th style="width:120px;">Trạng Thái</th>
                                            <th style="width:120px;">Người XN</th>
                                            <th style="width:95px;">Ngày XN</th>
                                            <th style="width:180px;">Thao Tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="sched" items="${shiftSchedules}" varStatus="row">
                                            <tr style="white-space:nowrap;">
                                                <td style="color:var(--c-muted);font-size:0.75rem;text-align:center;">${row.count}</td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2 overflow-hidden">
                                                        <div class="doctor-avatar-sm" style="flex-shrink:0;">
                                                            ${fn:substring(sched.doctorName, 0, 1)}
                                                        </div>
                                                        <span style="font-weight:600;font-size:0.83rem;overflow:hidden;text-overflow:ellipsis;" title="${fn:escapeXml(sched.doctorName)}">${fn:escapeXml(sched.doctorName)}</span>
                                                    </div>
                                                </td>
                                                <td style="font-size:0.78rem;overflow:hidden;text-overflow:ellipsis;" title="${fn:escapeXml(sched.doctorSpecialization)}">
                                                    ${not empty sched.doctorSpecialization ? fn:escapeXml(sched.doctorSpecialization) : '<span class="text-muted">&mdash;</span>'}
                                                </td>
                                                <td style="font-weight:600;">
                                                    <i class="bi bi-calendar3 me-1" style="color:var(--pink-500);"></i>
                                                    <fmt:formatDate value="${sched.workDate}" pattern="dd/MM/yyyy"/>
                                                </td>
                                                <td style="text-align:center;font-weight:600;">${sched.maxSlots}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${sched.status.name() eq 'PENDING'}">
                                                            <span class="badge-status-pending" style="font-size:0.7rem;white-space:nowrap;"><i class="bi bi-hourglass-split me-1"></i>Chờ xác nhận</span>
                                                        </c:when>
                                                        <c:when test="${sched.status.name() eq 'APPROVED'}">
                                                            <span class="badge-status-approved" style="font-size:0.7rem;white-space:nowrap;"><i class="bi bi-check-circle me-1"></i>Đã xác nhận</span>
                                                        </c:when>
                                                        <c:when test="${sched.status.name() eq 'REJECTED'}">
                                                            <span class="badge-status-rejected" style="font-size:0.7rem;white-space:nowrap;"><i class="bi bi-x-circle me-1"></i>Đã từ chối</span>
                                                            <c:if test="${not empty sched.rejectionReason}">
                                                                <span class="d-block mt-1" style="font-size:0.68rem;color:var(--c-muted);overflow:hidden;text-overflow:ellipsis;max-width:110px;cursor:pointer;" title="${fn:escapeXml(sched.rejectionReason)}">
                                                                    <i class="bi bi-chat-left-text me-1"></i>${fn:escapeXml(sched.rejectionReason)}
                                                                </span>
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-status-cancelled" style="font-size:0.7rem;white-space:nowrap;"><i class="bi bi-slash-circle me-1"></i>Đã hủy</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="font-size:0.78rem;overflow:hidden;text-overflow:ellipsis;" title="${fn:escapeXml(sched.approvedByName)}">
                                                    ${not empty sched.approvedByName ? fn:escapeXml(sched.approvedByName) : '<span class="text-muted">&mdash;</span>'}
                                                </td>
                                                <td style="font-size:0.8rem;color:var(--c-muted);">
                                                    <c:choose>
                                                        <c:when test="${not empty sched.approvedAt}">
                                                            <fmt:formatDate value="${sched.approvedAt}" pattern="dd/MM/yyyy"/>
                                                        </c:when>
                                                        <c:otherwise>&mdash;</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:if test="${sched.status.name() eq 'PENDING'}">
                                                        <div class="d-flex gap-1">
                                                            <form method="post" action="${pageContext.request.contextPath}/manager/schedules/" style="display:inline;"
                                                                  onsubmit="return confirmApproval('${sched.id}', '${fn:escapeXml(sched.doctorName)}', '${sched.shiftLabel}')">
                                                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                                <input type="hidden" name="action" value="approve">
                                                                <input type="hidden" name="id" value="${sched.id}">
                                                                <button type="submit" class="btn btn-sm btn-approve" title="Xác nhận" style="padding:0.3rem 0.55rem;font-size:0.72rem;">
                                                                    <i class="bi bi-check-lg"></i> Duyệt
                                                                </button>
                                                            </form>
                                                            <button type="button" class="btn btn-sm btn-reject" title="Từ chối" style="padding:0.3rem 0.55rem;font-size:0.72rem;"
                                                                    onclick="openRejectModal('${sched.id}', '${fn:escapeXml(sched.doctorName)}', '${sched.shiftLabel}')">
                                                                <i class="bi bi-x-lg"></i> Từ chối
                                                            </button>
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${sched.status.name() eq 'APPROVED'}">
                                                        <div class="d-flex gap-1">
                                                            <a href="${pageContext.request.contextPath}/manager/time-slots/?scheduleId=${sched.id}"
                                                               class="btn btn-sm btn-outline-primary" title="Khung giờ" style="padding:0.3rem 0.45rem;font-size:0.7rem;">
                                                                <i class="bi bi-clock-fill"></i> Khung Giờ
                                                            </a>
                                                            <button type="button" class="btn btn-sm btn-outline-danger" title="Hủy lịch" style="padding:0.3rem 0.45rem;font-size:0.7rem;"
                                                                    onclick="openCancelModal('${sched.id}', '${fn:escapeXml(sched.doctorName)}', '${sched.shiftLabel}')">
                                                                <i class="bi bi-x-circle"></i> Hủy
                                                            </button>
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${sched.status.name() eq 'REJECTED' or sched.status.name() eq 'CANCELLED'}">
                                                        <span class="text-muted" style="font-size:0.72rem;"><i class="bi bi-check2-all me-1"></i>Đã xử lý</span>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <c:if test="${empty shiftSchedules}">
                                <div style="text-align:center;padding:1.5rem;color:var(--c-muted);">
                                    <i class="bi bi-inbox" style="font-size:1.5rem;display:block;margin-bottom:0.5rem;"></i>
                                    <span style="font-size:0.85rem;font-weight:600;">Không có lịch nào trong ca này</span>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </c:forEach>

        </c:when>
        <c:otherwise>
            <div class="admin-card">
                <div class="card-body">
                    <div class="admin-empty-state">
                        <i class="bi bi-calendar-x" style="font-size:3rem;color:var(--c-muted);"></i>
                        <h6>Không tìm thấy lịch làm việc</h6>
                        <p>Chưa có đăng ký lịch làm việc nào hoặc dữ liệu không khớp bộ lọc.</p>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>

    <%-- ============================================================
         PAGINATION
         ============================================================ --%>
    <c:if test="${totalPages > 1}">
        <div class="admin-pagination">
            <c:url var="baseUrl" value="/manager/schedules/">
                <c:param name="tab" value="schedules"/>
                <c:param name="status" value="${statusFilter}"/>
                <c:param name="doctorId" value="${doctorIdFilter}"/>
                <c:param name="dateFrom" value="${dateFromFilter}"/>
                <c:param name="dateTo" value="${dateToFilter}"/>
            </c:url>
            <c:if test="${currentPage > 1}">
                <a href="${baseUrl}&page=${currentPage - 1}"><i class="bi bi-chevron-left"></i></a>
            </c:if>
            <c:forEach begin="1" end="${totalPages}" var="p">
                <c:choose>
                    <c:when test="${p eq currentPage}"><span class="active">${p}</span></c:when>
                    <c:otherwise><a href="${baseUrl}&page=${p}">${p}</a></c:otherwise>
                </c:choose>
            </c:forEach>
            <c:if test="${currentPage < totalPages}">
                <a href="${baseUrl}&page=${currentPage + 1}"><i class="bi bi-chevron-right"></i></a>
            </c:if>
        </div>
    </c:if>
    </c:if><%-- end schedules tab --%>
</main>

<%-- ============================================================
     MODAL: THÊM / SỬA CA LÀM VIỆC
     ============================================================ --%>
<div class="modal fade" id="shiftModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="shiftModalTitle">
                    <i class="bi bi-layers-fill me-2" style="color:#b86689;"></i>Thêm Ca Làm Việc
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/manager/schedules/" id="shiftForm"
                  onsubmit="return validateShiftForm()">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" id="shiftAction" value="createShift">
                <input type="hidden" name="shiftId" id="shiftId" value="">
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="shiftName" class="form-label fw-semibold">
                            Tên ca <span class="text-danger">*</span>
                        </label>
                        <input type="text" class="form-control" id="shiftName" name="shiftName"
                               maxlength="100" placeholder="Ví dụ: Ca sáng, Ca chiều, Ca tối..."
                               required style="border-radius:var(--r-sm);">
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label for="shiftStartTime" class="form-label fw-semibold">
                                Giờ bắt đầu <span class="text-danger">*</span>
                            </label>
                            <input type="time" class="form-control" id="shiftStartTime" name="shiftStartTime"
                                   required style="border-radius:var(--r-sm);">
                        </div>
                        <div class="col-6">
                            <label for="shiftEndTime" class="form-label fw-semibold">
                                Giờ kết thúc <span class="text-danger">*</span>
                            </label>
                            <input type="time" class="form-control" id="shiftEndTime" name="shiftEndTime"
                                   required style="border-radius:var(--r-sm);">
                        </div>
                    </div>
                    <div id="shiftError" class="text-danger mt-2" style="font-size:0.82rem;display:none;"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Hủy
                    </button>
                    <button type="submit" class="btn btn-primary-pink" id="shiftSubmitBtn">
                        <i class="bi bi-plus-lg me-1"></i>Thêm Ca Làm Việc
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: XÁC NHẬN TỪ CHỐI (REJECT)
     ============================================================ --%>
<div class="modal fade" id="rejectModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="bi bi-x-circle-fill me-2" style="color:#c62828;"></i>Từ Chối Lịch Làm Việc
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/manager/schedules/">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="id" id="rejectScheduleId">
                <div class="modal-body">
                    <div class="detail-card mb-3">
                        <div class="row g-2">
                            <div class="col-6">
                                <div class="detail-label">Bác sĩ</div>
                                <div class="detail-value" id="rejectDoctorName">&mdash;</div>
                            </div>
                            <div class="col-6">
                                <div class="detail-label">Ca làm việc</div>
                                <div class="detail-value" id="rejectShiftLabel">&mdash;</div>
                            </div>
                        </div>
                    </div>

                    <label class="form-label fw-semibold">
                        Lý do từ chối <span class="text-danger">*</span>
                    </label>
                    <textarea name="rejectionReason" id="rejectionReason"
                              class="form-control" rows="4" maxlength="500"
                              placeholder="Nhập lý do từ chối (tối thiểu 10 ký tự). Ví dụ: Ca làm việc đã đủ nhân sự hoặc bác sĩ có lịch trùng giờ..."
                              required></textarea>
                    <div class="form-text">
                        <i class="bi bi-info-circle me-1"></i>
                        Lý do từ chối sẽ được gửi đến Bác sĩ lâm sàng để đảm bảo tính minh bạch. Tối thiểu 10 ký tự.
                    </div>
                    <div id="rejectError" class="text-danger mt-2" style="font-size:0.82rem;display:none;"></div>

                    <c:if test="${not empty errors.rejectionReason}">
                        <div class="text-danger mt-2" style="font-size:0.82rem;">
                            <i class="bi bi-exclamation-circle me-1"></i>${errors.rejectionReason}
                        </div>
                    </c:if>
                    <c:if test="${not empty errors.general}">
                        <div class="text-danger mt-2" style="font-size:0.82rem;">
                            <i class="bi bi-exclamation-circle me-1"></i>${errors.general}
                        </div>
                    </c:if>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Hủy
                    </button>
                    <button type="submit" class="btn btn-reject">
                        <i class="bi bi-x-lg me-1"></i>Xác Nhận Từ Chối
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: XÁC NHẬN HỦY LỊCH TRỰC (CANCEL)
     ============================================================ --%>
<div class="modal fade" id="cancelModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header" style="background:#eceff1 !important; border-bottom: 1px solid #b0bec5 !important;">
                <h5 class="modal-title" style="color:#37474f;">
                    <i class="bi bi-slash-circle-fill me-2" style="color:#546e7a;"></i>Hủy Lịch Làm Việc
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/manager/schedules/">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" name="id" id="cancelScheduleId">
                <div class="modal-body">
                    <div class="detail-card mb-3">
                        <div class="row g-2">
                            <div class="col-6">
                                <div class="detail-label">Bác sĩ</div>
                                <div class="detail-value" id="cancelDoctorName">&mdash;</div>
                            </div>
                            <div class="col-6">
                                <div class="detail-label">Ca làm việc</div>
                                <div class="detail-value" id="cancelShiftLabel">&mdash;</div>
                            </div>
                        </div>
                    </div>

                    <div class="alert alert-warning d-flex align-items-center" style="font-size:0.85rem;border-radius:var(--r-sm);">
                        <i class="bi bi-exclamation-triangle-fill me-2 flex-shrink-0" style="font-size:1.2rem;"></i>
                        <div>
                            <strong>Lưu ý:</strong> Nếu lịch làm việc đã có bệnh nhân đặt, bạn không thể hủy trực tiếp.
                            Hệ thống sẽ yêu cầu bạn xử lý chuyển bác sĩ hoặc đổi lịch cho bệnh nhân trước.
                        </div>
                    </div>

                    <label class="form-label fw-semibold">
                        Lý do hủy <span class="text-danger">*</span>
                    </label>
                    <textarea name="cancellationReason" id="cancellationReason"
                              class="form-control" rows="3" maxlength="500"
                              placeholder="Nhập lý do hủy lịch làm việc (tối thiểu 10 ký tự)..."
                              required></textarea>
                    <div class="form-text">
                        <i class="bi bi-info-circle me-1"></i>
                        Lý do hủy sẽ được lưu vào hệ thống để đối chiếu sau này.
                    </div>
                    <div id="cancelError" class="text-danger mt-2" style="font-size:0.82rem;display:none;"></div>

                    <c:if test="${not empty errors.cancellationReason}">
                        <div class="text-danger mt-2" style="font-size:0.82rem;">
                            <i class="bi bi-exclamation-circle me-1"></i>${errors.cancellationReason}
                        </div>
                    </c:if>
                    <c:if test="${not empty errors.general}">
                        <div class="text-danger mt-2" style="font-size:0.82rem;">
                            <i class="bi bi-exclamation-circle me-1"></i>${errors.general}
                        </div>
                    </c:if>
                </div>
                <div class="modal-footer" style="border-top: 1px solid var(--c-outline-variant) !important;">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Đóng
                    </button>
                    <button type="submit" class="btn btn-outline-danger" style="font-weight:700;">
                        <i class="bi bi-slash-circle me-1"></i>Xác Nhận Hủy
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: CẢNH BÁO CÓ BOOKED SLOTS KHI HỦY
     ============================================================ --%>
<c:if test="${showCancelWarning}">
<div class="modal fade" id="cancelWarningModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header" style="background:#fff3e0 !important; border-bottom: 1px solid #ffcc80 !important;">
                <h5 class="modal-title" style="color:#e65100;">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    Không Thể Hủy Lịch Làm Việc — Có Bệnh Nhân Đã Đặt
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="alert alert-danger" style="font-size:0.9rem;border-radius:var(--r-sm);">
                    <i class="bi bi-shield-exclamation me-2"></i>
                    <strong>${hasBookedSlotsError}</strong>
                </div>

                <c:if test="${not empty bookedSlots}">
                    <h6 style="font-weight:700;margin-bottom:0.75rem;">
                        <i class="bi bi-people-fill me-2"></i>
                        Danh sách ${bookedSlotCount} bệnh nhân cần xử lý:
                    </h6>
                    <div class="admin-table-wrapper" style="max-height:300px;overflow-y:auto;">
                        <table class="admin-table" style="font-size:0.82rem;">
                            <thead>
                                <tr>
                                    <th>STT</th>
                                    <th>Khung Giờ</th>
                                    <th>Bệnh Nhân</th>
                                    <th>Ngày Đặt</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="bs" items="${bookedSlots}" varStatus="row">
                                    <tr>
                                        <td>${row.count}</td>
                                        <td style="font-weight:600;">${bs.timeLabel}</td>
                                        <td>${not empty bs.bookedByName ? fn:escapeXml(bs.bookedByName) : '#' += bs.bookedBy}</td>
                                        <td style="font-size:0.78rem;color:var(--c-muted);">
                                            <fmt:formatDate value="${bs.bookedAt}" pattern="dd/MM/yyyy"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <div class="mt-3 p-3" style="background:#f5f5f5;border-radius:var(--r-sm);font-size:0.85rem;">
                    <strong><i class="bi bi-lightbulb-fill me-1" style="color:#f9a825;"></i>Hướng dẫn:</strong>
                    <ul class="mb-0 mt-2">
                        <li>Chuyển từng bệnh nhân sang bác sĩ khác có lịch làm việc cùng ngày</li>
                        <li>Hoặc đổi lịch hẹn của bệnh nhân sang ngày khác</li>
                        <li>Sau khi xử lý xong tất cả bệnh nhân, quay lại đây để hủy lịch làm việc</li>
                    </ul>
                </div>
            </div>
            <div class="modal-footer" style="border-top: 1px solid var(--c-outline-variant) !important;">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                    <i class="bi bi-x-circle me-1"></i>Đóng
                </button>
                <a href="${pageContext.request.contextPath}/manager/time-slots/?scheduleId=${cancelSchedule.id}"
                   class="btn btn-primary-pink">
                    <i class="bi bi-arrow-right-circle me-1"></i>Đi Đến Quản Lý Khung Giờ
                </a>
            </div>
        </div>
    </div>
</div>
</c:if>

<%-- ============================================================
     MODAL: CHI TIẾT LỊCH TRỰC
     ============================================================ --%>
<c:if test="${not empty detailSchedule}">
    <div class="modal fade" id="detailModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-info-circle-fill me-2"></i>Chi Tiết Lịch Làm Việc #${detailSchedule.id}
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="detail-card">
                                <div class="detail-label">Bác sĩ</div>
                                <div class="detail-value">
                                    <i class="bi bi-person-badge me-1"></i>${fn:escapeXml(detailSchedule.doctorName)}
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="detail-card">
                                <div class="detail-label">Chuyên khoa</div>
                                <div class="detail-value">${not empty detailSchedule.doctorSpecialization ? fn:escapeXml(detailSchedule.doctorSpecialization) : '&mdash;'}</div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="detail-card">
                                <div class="detail-label">Ngày trực</div>
                                <div class="detail-value"><fmt:formatDate value="${detailSchedule.workDate}" pattern="EEEE, dd/MM/yyyy"/></div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="detail-card">
                                <div class="detail-label">Ca làm việc</div>
                                <div class="detail-value">${detailSchedule.shiftLabel}</div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="detail-card">
                                <div class="detail-label">SL tối đa</div>
                                <div class="detail-value">${detailSchedule.maxSlots} bệnh nhân/ca</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="detail-card">
                                <div class="detail-label">Trạng thái</div>
                                <div class="detail-value">
                                    <c:choose>
                                        <c:when test="${detailSchedule.status.name() eq 'PENDING'}"><span class="badge-status-pending" style="font-size:0.73rem;white-space:nowrap;">Chờ xác nhận</span></c:when>
                                        <c:when test="${detailSchedule.status.name() eq 'APPROVED'}"><span class="badge-status-approved" style="font-size:0.73rem;white-space:nowrap;">Đã xác nhận</span></c:when>
                                        <c:when test="${detailSchedule.status.name() eq 'REJECTED'}"><span class="badge-status-rejected" style="font-size:0.73rem;white-space:nowrap;">Đã từ chối</span></c:when>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="detail-card">
                                <div class="detail-label">Ghi chú</div>
                                <div class="detail-value">${not empty detailSchedule.notes ? fn:escapeXml(detailSchedule.notes) : '&mdash;'}</div>
                            </div>
                        </div>
                    </div>

                    <%-- Cảnh báo nghiệp vụ --%>
                    <c:if test="${not empty warnings}">
                        <div class="mt-3">
                            <h6 style="font-size:0.85rem;font-weight:700;color:#e65100;">
                                <i class="bi bi-exclamation-triangle-fill me-1"></i>Cảnh báo:
                            </h6>
                            <ul class="warning-list">
                                <c:forEach var="w" items="${warnings}">
                                    <li><i class="bi bi-exclamation-circle flex-shrink-0 mt-0"></i> ${w}</li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Đóng
                    </button>
                </div>
            </div>
        </div>
    </div>
</c:if>

<%-- ============================================================
     SCRIPTS
     ============================================================ --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
// ── Sidebar Toggle ──
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });

// ── Active menu highlight ──
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        if (links[i].href && links[i].href.indexOf('/manager/schedules') !== -1) {
            links[i].classList.add('active');
        }
    }
})();

// ── Init Bootstrap tooltips ──
document.addEventListener('DOMContentLoaded', function() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function(el) { return new bootstrap.Tooltip(el); });
});

// ── Confirm approval ──
function confirmApproval(id, doctorName, shiftLabel) {
    return confirm('Xác nhận lịch làm việc #' + id + '?\n\n'
        + 'Bác sĩ: ' + doctorName + '\n'
        + 'Ca làm việc: ' + shiftLabel + '\n\n'
        + 'Lịch này sẽ được đưa vào lịch làm việc chính thức.');
}

// ── Open reject modal ──
function openRejectModal(id, doctorName, shiftLabel) {
    document.getElementById('rejectScheduleId').value = id;
    document.getElementById('rejectDoctorName').textContent = doctorName;
    document.getElementById('rejectShiftLabel').textContent = shiftLabel;
    document.getElementById('rejectionReason').value = '';
    document.getElementById('rejectError').style.display = 'none';
    new bootstrap.Modal(document.getElementById('rejectModal')).show();
}

// ── Client-side validate reject reason ──
(function() {
    var rejectForm = document.querySelector('#rejectModal form');
    if (rejectForm) {
        rejectForm.addEventListener('submit', function(e) {
            var reason = document.getElementById('rejectionReason').value.trim();
            var errorEl = document.getElementById('rejectError');
            if (reason.length < 10) {
                e.preventDefault();
                errorEl.style.display = 'block';
                errorEl.innerHTML = '<i class="bi bi-exclamation-circle me-1"></i>Lý do từ chối phải có ít nhất 10 ký tự.';
                return false;
            }
            if (reason.length > 500) {
                e.preventDefault();
                errorEl.style.display = 'block';
                errorEl.innerHTML = '<i class="bi bi-exclamation-circle me-1"></i>Lý do từ chối không được vượt quá 500 ký tự.';
                return false;
            }
        });
    }
})();

// ── Open cancel modal ──
function openCancelModal(id, doctorName, shiftLabel) {
    document.getElementById('cancelScheduleId').value = id;
    document.getElementById('cancelDoctorName').textContent = doctorName;
    document.getElementById('cancelShiftLabel').textContent = shiftLabel;
    document.getElementById('cancellationReason').value = '';
    document.getElementById('cancelError').style.display = 'none';
    new bootstrap.Modal(document.getElementById('cancelModal')).show();
}

// ── Client-side validate cancel reason ──
(function() {
    var cancelForm = document.querySelector('#cancelModal form');
    if (cancelForm) {
        cancelForm.addEventListener('submit', function(e) {
            var reason = document.getElementById('cancellationReason').value.trim();
            var errorEl = document.getElementById('cancelError');
            if (reason.length < 10) {
                e.preventDefault();
                errorEl.style.display = 'block';
                errorEl.innerHTML = '<i class="bi bi-exclamation-circle me-1"></i>Lý do hủy phải có ít nhất 10 ký tự.';
                return false;
            }
        });
    }
})();

<%-- Hiển thị modal từ chối nếu có lỗi validate trước đó --%>
<c:if test="${showRejectModal}">
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('rejectScheduleId').value = '${rejectScheduleId}';
        new bootstrap.Modal(document.getElementById('rejectModal')).show();
    });
</c:if>

<%-- Hiển thị modal hủy nếu có lỗi validate trước đó --%>
<c:if test="${showCancelModal}">
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('cancelScheduleId').value = '${cancelScheduleId}';
        new bootstrap.Modal(document.getElementById('cancelModal')).show();
    });
</c:if>

<%-- Hiển thị modal cảnh báo booked slots --%>
<c:if test="${showCancelWarning}">
    document.addEventListener('DOMContentLoaded', function() {
        new bootstrap.Modal(document.getElementById('cancelWarningModal')).show();
    });
</c:if>

<%-- Hiển thị modal chi tiết nếu có --%>
<c:if test="${not empty detailSchedule}">
    document.addEventListener('DOMContentLoaded', function() {
        new bootstrap.Modal(document.getElementById('detailModal')).show();
    });
</c:if>

// ── Accordion chevron rotation ──
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.shift-group-header').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var chevron = this.querySelector('.shift-group-chevron');
            if (chevron) {
                setTimeout(function() {
                    var collapsed = btn.getAttribute('aria-expanded') === 'false';
                    chevron.style.transform = collapsed ? 'rotate(0deg)' : 'rotate(180deg)';
                }, 10);
            }
        });
    });
});

<%-- Hiển thị shift modal nếu có lỗi validate trước đó --%>
<c:if test="${showShiftModal}">
    document.addEventListener('DOMContentLoaded', function() {
        openShiftModal('<%= request.getAttribute("shiftAction") != null ? request.getAttribute("shiftAction") : "create" %>');
        var shiftName = '${fn:escapeXml(param.shiftName)}';
        var shiftStart = '${fn:escapeXml(param.shiftStartTime)}';
        var shiftEnd = '${fn:escapeXml(param.shiftEndTime)}';
        if (shiftName) document.getElementById('shiftName').value = shiftName;
        if (shiftStart) document.getElementById('shiftStartTime').value = shiftStart;
        if (shiftEnd) document.getElementById('shiftEndTime').value = shiftEnd;
    });
</c:if>

// ── Shift modal functions ──

function openShiftModal(mode, id, name, startTime, endTime) {
    var modal = new bootstrap.Modal(document.getElementById('shiftModal'));
    var title = document.getElementById('shiftModalTitle');
    var actionInput = document.getElementById('shiftAction');
    var shiftIdInput = document.getElementById('shiftId');
    var submitBtn = document.getElementById('shiftSubmitBtn');
    var errorEl = document.getElementById('shiftError');
    errorEl.style.display = 'none';

    if (mode === 'create') {
        title.innerHTML = '<i class="bi bi-layers-fill me-2" style="color:#b86689;"></i>Thêm Ca Làm Việc';
        actionInput.value = 'createShift';
        shiftIdInput.value = '';
        submitBtn.innerHTML = '<i class="bi bi-plus-lg me-1"></i>Thêm Ca Làm Việc';
        document.getElementById('shiftName').value = '';
        document.getElementById('shiftStartTime').value = '';
        document.getElementById('shiftEndTime').value = '';
    } else {
        title.innerHTML = '<i class="bi bi-pencil-fill me-2" style="color:#b86689;"></i>Sửa Ca Làm Việc';
        actionInput.value = 'updateShift';
        shiftIdInput.value = id || '';
        submitBtn.innerHTML = '<i class="bi bi-check-lg me-1"></i>Cập Nhật';
        document.getElementById('shiftName').value = name || '';
        document.getElementById('shiftStartTime').value = startTime || '';
        document.getElementById('shiftEndTime').value = endTime || '';
    }
    modal.show();
}

function validateShiftForm() {
    var name = document.getElementById('shiftName').value.trim();
    var startTime = document.getElementById('shiftStartTime').value;
    var endTime = document.getElementById('shiftEndTime').value;
    var errorEl = document.getElementById('shiftError');

    if (!name) {
        errorEl.innerHTML = '<i class="bi bi-exclamation-circle me-1"></i>Vui lòng nhập tên ca làm việc.';
        errorEl.style.display = 'block';
        return false;
    }
    if (!startTime || !endTime) {
        errorEl.innerHTML = '<i class="bi bi-exclamation-circle me-1"></i>Vui lòng nhập cả giờ bắt đầu và giờ kết thúc.';
        errorEl.style.display = 'block';
        return false;
    }
    if (startTime >= endTime) {
        errorEl.innerHTML = '<i class="bi bi-exclamation-circle me-1"></i>Giờ kết thúc phải sau giờ bắt đầu.';
        errorEl.style.display = 'block';
        return false;
    }
    errorEl.style.display = 'none';
    return true;
}
</script>

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
