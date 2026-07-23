<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Lịch Làm Việc Bác Sĩ — CAMS</title>

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
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role"><i class="bi bi-briefcase-fill me-1"></i>Quản Lý</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout" title="Đăng xuất">
            <i class="bi bi-box-arrow-right"></i>
            <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
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
                <i class="bi bi-calendar-check me-2" style="color:#b86689;"></i>Lịch Làm Việc Bác Sĩ
            </h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-people-fill"></i>
                Xác nhận hoặc từ chối đăng ký lịch làm việc của bác sĩ lâm sàng
            </div>
        </div>
    </div>

    <%-- ============================================================
         KPI MINI CARDS
         ============================================================ --%>
    <div class="kpi-mini-row">
        <div class="kpi-mini" onclick="window.location.href='?status=PENDING'" style="cursor:pointer;">
            <div class="kpi-mini-icon kmi-pending"><i class="bi bi-hourglass-split"></i></div>
            <div class="kpi-mini-body">
                <div class="kpi-mini-value">${pendingCount}</div>
                <div class="kpi-mini-label">Chờ Xác Nhận</div>
            </div>
        </div>
        <div class="kpi-mini" onclick="window.location.href='?status=APPROVED'" style="cursor:pointer;">
            <div class="kpi-mini-icon kmi-approved"><i class="bi bi-check-circle-fill"></i></div>
            <div class="kpi-mini-body">
                <div class="kpi-mini-value">${approvedCount}</div>
                <div class="kpi-mini-label">Đã Xác Nhận</div>
            </div>
        </div>
        <div class="kpi-mini" onclick="window.location.href='?status=REJECTED'" style="cursor:pointer;">
            <div class="kpi-mini-icon kmi-rejected"><i class="bi bi-x-circle-fill"></i></div>
            <div class="kpi-mini-body">
                <div class="kpi-mini-value">${rejectedCount}</div>
                <div class="kpi-mini-label">Đã Từ Chối</div>
            </div>
        </div>
        <div class="kpi-mini" onclick="window.location.href='?status=CANCELLED'" style="cursor:pointer;">
            <div class="kpi-mini-icon kmi-cancelled"><i class="bi bi-slash-circle-fill"></i></div>
            <div class="kpi-mini-body">
                <div class="kpi-mini-value">${cancelledCount}</div>
                <div class="kpi-mini-label">Đã Hủy</div>
            </div>
        </div>
        <div class="kpi-mini">
            <div class="kpi-mini-icon kmi-total"><i class="bi bi-calendar-week-fill"></i></div>
            <div class="kpi-mini-body">
                <div class="kpi-mini-value">${totalSchedules}</div>
                <div class="kpi-mini-label">Tổng Lịch Làm Việc</div>
            </div>
        </div>
    </div>

    <%-- ============================================================
         ALERT MESSAGES
         ============================================================ --%>
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md);">
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
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md);">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div>${fn:escapeXml(error)}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <%-- ============================================================
         FILTER BAR
         ============================================================ --%>
    <div class="admin-card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/manager/schedules/" class="filter-bar">
                <select name="status" class="form-select">
                    <option value="">Tất cả trạng thái</option>
                    <option value="PENDING" ${statusFilter eq 'PENDING' ? 'selected' : ''}>🟠 Chờ xác nhận</option>
                    <option value="APPROVED" ${statusFilter eq 'APPROVED' ? 'selected' : ''}>🟢 Đã xác nhận</option>
                    <option value="REJECTED" ${statusFilter eq 'REJECTED' ? 'selected' : ''}>🔴 Đã từ chối</option>
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
                <a href="${pageContext.request.contextPath}/manager/schedules/" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-counterclockwise me-1"></i>Đặt lại
                </a>
            </form>
        </div>
    </div>

    <%-- ============================================================
         SCHEDULES TABLE
         ============================================================ --%>
    <div class="admin-card">
        <div class="card-header admin-card-header-link d-flex justify-content-between align-items-center">
            <h5><i class="bi bi-calendar-check me-2" style="color:#b86689;"></i>Danh Sách Lịch Làm Việc</h5>
            <span class="badge bg-white text-dark border" style="font-size:0.78rem;">
                <i class="bi bi-database me-1"></i>${totalSchedules} lịch làm việc
            </span>
        </div>
        <div class="card-body p-0">
            <div class="admin-table-wrapper">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Bác sĩ lâm sàng</th>
                            <th>Chuyên Khoa</th>
                            <th>Ngày Trực</th>
                            <th>Ca Làm Việc</th>
                            <th>SL Tối Đa</th>
                            <th>Trạng Thái</th>
                            <th>Người Xác Nhận</th>
                            <th>Ngày Xác Nhận</th>
                            <th style="width:180px;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty schedules}">
                                <c:forEach var="sched" items="${schedules}" varStatus="row">
                                    <tr>
                                        <td style="color:var(--c-muted);font-size:0.8rem;">${(currentPage - 1) * pageSize + row.count}</td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="doctor-avatar-sm">
                                                    ${fn:substring(sched.doctorName, 0, 1)}
                                                </div>
                                                <span style="font-weight:600;">${fn:escapeXml(sched.doctorName)}</span>
                                            </div>
                                        </td>
                                        <td style="font-size:0.82rem;">
                                            ${not empty sched.doctorSpecialization ? fn:escapeXml(sched.doctorSpecialization) : '<span class="text-muted">&mdash;</span>'}
                                        </td>
                                        <td style="font-weight:600;">
                                            <i class="bi bi-calendar3 me-1" style="color:var(--pink-500);"></i>
                                            <fmt:formatDate value="${sched.workDate}" pattern="dd/MM/yyyy"/>
                                        </td>
                                        <td>
                                            <c:set var="startHour" value="${fn:substring(sched.startTime, 0, 2)}"/>
                                            <c:choose>
                                                <c:when test="${startHour < '12'}">
                                                    <span class="shift-badge-morning"><i class="bi bi-sunrise-fill me-1"></i>${sched.shiftLabel}</span>
                                                </c:when>
                                                <c:when test="${startHour < '17'}">
                                                    <span class="shift-badge-afternoon"><i class="bi bi-sun-fill me-1"></i>${sched.shiftLabel}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="shift-badge-evening"><i class="bi bi-moon-fill me-1"></i>${sched.shiftLabel}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:center;font-weight:600;">${sched.maxSlots}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${sched.status.name() eq 'PENDING'}">
                                                    <span class="badge-status-pending"><i class="bi bi-hourglass-split me-1"></i>Chờ xác nhận</span>
                                                </c:when>
                                                <c:when test="${sched.status.name() eq 'APPROVED'}">
                                                    <span class="badge-status-approved"><i class="bi bi-check-circle me-1"></i>Đã xác nhận</span>
                                                </c:when>
                                                <c:when test="${sched.status.name() eq 'REJECTED'}">
                                                    <span class="badge-status-rejected"><i class="bi bi-x-circle me-1"></i>Đã từ chối</span>
                                                    <c:if test="${not empty sched.rejectionReason}">
                                                        <span class="rejection-reason-cell d-block mt-1"
                                                              title="${fn:escapeXml(sched.rejectionReason)}"
                                                              data-bs-toggle="tooltip">
                                                            <i class="bi bi-chat-left-text me-1"></i>${fn:escapeXml(sched.rejectionReason)}
                                                        </span>
                                                    </c:if>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status-cancelled"><i class="bi bi-slash-circle me-1"></i>Đã hủy</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="font-size:0.82rem;">
                                            ${not empty sched.approvedByName ? fn:escapeXml(sched.approvedByName) : '<span class="text-muted">&mdash;</span>'}
                                        </td>
                                        <td style="font-size:0.82rem;color:var(--c-muted);">
                                            <c:choose>
                                                <c:when test="${not empty sched.approvedAt}">
                                                    <fmt:formatDate value="${sched.approvedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:when>
                                                <c:otherwise>&mdash;</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:if test="${sched.status.name() eq 'PENDING'}">
                                                <div class="d-flex gap-1">
                                                    <%-- Nút Duyệt (icon check, xanh) --%>
                                                    <form method="post" action="${pageContext.request.contextPath}/manager/schedules/" style="display:inline;"
                                                          onsubmit="return confirmApproval('${sched.id}', '${fn:escapeXml(sched.doctorName)}', '${sched.shiftLabel}')">
                                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="approve">
                                                        <input type="hidden" name="id" value="${sched.id}">
                                                        <button type="submit" class="btn btn-sm btn-approve" title="Xác nhận lịch làm việc">
                                                            <i class="bi bi-check-lg"></i> Xác Nhận
                                                        </button>
                                                    </form>
                                                    <%-- Nút Từ chối (icon x, đỏ) — mở modal --%>
                                                    <button type="button" class="btn btn-sm btn-reject"
                                                            title="Từ chối lịch làm việc"
                                                            onclick="openRejectModal('${sched.id}', '${fn:escapeXml(sched.doctorName)}', '${sched.shiftLabel}')">
                                                        <i class="bi bi-x-lg"></i> Từ chối
                                                    </button>
                                                </div>
                                            </c:if>
                                            <c:if test="${sched.status.name() eq 'APPROVED'}">
                                                <div class="d-flex gap-1">
                                                    <a href="${pageContext.request.contextPath}/manager/time-slots/?scheduleId=${sched.id}"
                                                       class="btn btn-sm btn-outline-primary"
                                                       title="Xem khung giờ khám đã sinh" style="font-size:0.78rem;">
                                                        <i class="bi bi-clock-fill"></i> Khung Giờ
                                                    </a>
                                                    <button type="button" class="btn btn-sm btn-outline-danger"
                                                            title="Hủy lịch làm việc"
                                                            style="font-size:0.78rem;"
                                                            onclick="openCancelModal('${sched.id}', '${fn:escapeXml(sched.doctorName)}', '${sched.shiftLabel}')">
                                                        <i class="bi bi-x-circle"></i> Hủy
                                                    </button>
                                                </div>
                                            </c:if>
                                            <c:if test="${sched.status.name() eq 'REJECTED' or sched.status.name() eq 'CANCELLED'}">
                                                <span class="text-muted" style="font-size:0.78rem;">Đã xử lý</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="10">
                                        <div class="admin-empty-state">
                                            <i class="bi bi-calendar-x" style="font-size:3rem;color:var(--c-muted);"></i>
                                            <h6>Không tìm thấy lịch làm việc</h6>
                                            <p>Chưa có đăng ký lịch làm việc nào hoặc dữ liệu không khớp bộ lọc.</p>
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

    <%-- ============================================================
         PAGINATION
         ============================================================ --%>
    <c:if test="${totalPages > 1}">
        <div class="admin-pagination">
            <c:url var="baseUrl" value="/manager/schedules/">
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
</main>

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
                                            <fmt:formatDate value="${bs.bookedAt}" pattern="dd/MM/yyyy HH:mm"/>
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
                                        <c:when test="${detailSchedule.status.name() eq 'PENDING'}"><span class="badge-status-pending">Chờ xác nhận</span></c:when>
                                        <c:when test="${detailSchedule.status.name() eq 'APPROVED'}"><span class="badge-status-approved">Đã xác nhận</span></c:when>
                                        <c:when test="${detailSchedule.status.name() eq 'REJECTED'}"><span class="badge-status-rejected">Đã từ chối</span></c:when>
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
</script>

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
