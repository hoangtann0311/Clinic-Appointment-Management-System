<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Hoạt Động — Admin CAMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        :root { --bs-body-font-family: 'Be Vietnam Pro', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body.admin-body { font-family: var(--bs-body-font-family); background: #f7f3f5; }

        /* ── Filter Bar ── */
        .audit-filter-bar {
            background: #fff;
            border-radius: 16px;
            padding: 1.25rem 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            border: 1px solid #f1e0e6;
        }
        .audit-filter-bar .form-label {
            font-size: 0.78rem;
            font-weight: 600;
            color: #6b4c5b;
            margin-bottom: 0.35rem;
        }
        .audit-filter-bar .form-control,
        .audit-filter-bar .form-select {
            font-size: 0.82rem;
            border-radius: 10px;
            border: 1.5px solid #e8d5dd;
            padding: 0.5rem 0.75rem;
            transition: border-color 0.2s;
        }
        .audit-filter-bar .form-control:focus,
        .audit-filter-bar .form-select:focus {
            border-color: var(--pink-400, #d16b8a);
            box-shadow: 0 0 0 3px rgba(209,107,138,0.1);
        }
        .audit-filter-bar .btn-filter {
            font-size: 0.82rem;
            font-weight: 600;
            padding: 0.5rem 1.25rem;
            border-radius: 10px;
        }
        .btn-filter-search {
            background: var(--pink-500, #c24b6e);
            color: #fff;
            border: none;
        }
        .btn-filter-search:hover { background: var(--pink-600, #a83d5b); color: #fff; }
        .btn-filter-reset {
            background: #fff;
            color: #6b4c5b;
            border: 1.5px solid #e8d5dd;
        }
        .btn-filter-reset:hover { background: #fdf2f5; }

        /* ── Stats Row ── */
        .audit-stat-card {
            background: #fff;
            border-radius: 12px;
            padding: 1rem 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.9rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            border: 1px solid #f1e0e6;
        }
        .audit-stat-icon {
            width: 44px; height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }
        .audit-stat-icon.total  { background: #fdf2f5; color: #c24b6e; }
        .audit-stat-icon.today  { background: #eef7ee; color: #3b7a3b; }
        .audit-stat-icon.users  { background: #eef2ff; color: #4a5fc1; }
        .audit-stat-value { font-size: 1.35rem; font-weight: 700; color: #3d2630; line-height:1.1; }
        .audit-stat-label { font-size: 0.73rem; color: #9e8590; font-weight: 500; }

        /* ── Table Card ── */
        .audit-table-card {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            border: 1px solid #f1e0e6;
            overflow: hidden;
        }
        .audit-table-card .card-header {
            background: #fff;
            border-bottom: 1px solid #f1e0e6;
            padding: 1rem 1.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .audit-table-card .card-header h5 {
            font-size: 0.95rem;
            font-weight: 700;
            color: #3d2630;
            margin: 0;
        }
        .audit-table-card .card-header h5 i { color: #c24b6e; margin-right: 0.5rem; }

        /* ── Table ── */
        .audit-table { width: 100%; border-collapse: collapse; }
        .audit-table thead th {
            background: #fdf2f5;
            font-size: 0.73rem;
            font-weight: 700;
            color: #6b4c5b;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            padding: 0.7rem 1rem;
            border-bottom: 2px solid #f1e0e6;
            white-space: nowrap;
        }
        .audit-table tbody td {
            padding: 0.7rem 1rem;
            font-size: 0.8rem;
            color: #4a3540;
            border-bottom: 1px solid #f5ebef;
            vertical-align: middle;
        }
        .audit-table tbody tr {
            cursor: pointer;
            transition: background 0.15s;
        }
        .audit-table tbody tr:hover { background: #fdf2f5; }

        /* ── Badges ── */
        .badge-action {
            display: inline-block;
            padding: 0.2rem 0.55rem;
            border-radius: 6px;
            font-size: 0.68rem;
            font-weight: 700;
            letter-spacing: 0.02em;
            text-transform: uppercase;
        }
        .badge-create   { background: #d4edda; color: #1b5e20; }
        .badge-update   { background: #d6eaf8; color: #1a5276; }
        .badge-delete   { background: #fadbd8; color: #922b21; }
        .badge-login    { background: #e8daef; color: #6c3483; }
        .badge-logout   { background: #fdebd0; color: #7d6608; }
        .badge-approve  { background: #d5f5e3; color: #145a32; }
        .badge-toggle   { background: #fcf3cf; color: #7d6608; }
        .badge-security { background: #fadbd8; color: #922b21; }
        .badge-export   { background: #d6eaf8; color: #1a5276; }
        .badge-other    { background: #eaecee; color: #424949; }

        .badge-module {
            display: inline-block;
            padding: 0.15rem 0.45rem;
            border-radius: 5px;
            font-size: 0.7rem;
            font-weight: 600;
            background: #f5ebef;
            color: #6b4c5b;
        }

        /* ── User cell ── */
        .audit-user-name { font-weight: 600; color: #3d2630; }
        .audit-user-role { font-size: 0.68rem; color: #9e8590; }

        /* ── Action cell ── */
        .audit-action-text {
            display: block;
            font-family: 'Be Vietnam Pro', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 0.85rem;
            font-weight: 500;
            color: #3d2630;
            line-height: 1.5;
            word-break: break-word;
            overflow-wrap: break-word;
            white-space: normal;
        }
        .audit-action-ip {
            display: block;
            font-family: 'Be Vietnam Pro', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 0.72rem;
            color: #a08c96;
            margin-top: 0.25rem;
        }

        /* ── Pagination ── */
        .audit-pagination {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0.8rem 1.5rem;
            border-top: 1px solid #f1e0e6;
        }
        .audit-pagination .page-info {
            font-size: 0.78rem;
            color: #9e8590;
            font-weight: 500;
        }
        .audit-pagination .page-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 34px; height: 34px;
            border-radius: 8px;
            font-size: 0.78rem;
            font-weight: 600;
            color: #6b4c5b;
            border: 1.5px solid #e8d5dd;
            background: #fff;
            margin: 0 2px;
            text-decoration: none;
            transition: all 0.15s;
        }
        .audit-pagination .page-btn:hover { background: #fdf2f5; border-color: #c24b6e; }
        .audit-pagination .page-btn.active {
            background: #c24b6e;
            color: #fff;
            border-color: #c24b6e;
        }
        .audit-pagination .page-btn.disabled {
            opacity: 0.4;
            pointer-events: none;
        }

        /* ── Detail Modal ── */
        .modal-audit .modal-header {
            background: #fdf2f5;
            border-bottom: 2px solid #f1e0e6;
        }
        .modal-audit .modal-title { font-weight: 700; color: #3d2630; font-size: 1rem; }
        .modal-audit .detail-label {
            font-size: 0.73rem;
            font-weight: 600;
            color: #9e8590;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            margin-bottom: 0.2rem;
        }
        .modal-audit .detail-value {
            font-size: 0.85rem;
            color: #3d2630;
            margin-bottom: 0.8rem;
        }
        .modal-audit .diff-box {
            background: #fafafa;
            border-radius: 10px;
            padding: 0.75rem 1rem;
            font-family: 'SF Mono', 'Fira Code', 'Consolas', monospace;
            font-size: 0.75rem;
            max-height: 200px;
            overflow-y: auto;
            white-space: pre-wrap;
            word-break: break-all;
            color: #4a3540;
            border: 1px solid #eaecee;
        }
        .diff-added { background: #d4edda; color: #1b5e20; }
        .diff-removed { background: #fadbd8; color: #922b21; }

        /* ── Empty State ── */
        .audit-empty {
            text-align: center;
            padding: 3rem 1rem;
        }
        .audit-empty i { font-size: 3rem; color: #d5c0cb; }
        .audit-empty h6 { color: #6b4c5b; margin-top: 0.8rem; font-weight: 600; }
        .audit-empty p  { color: #9e8590; font-size: 0.82rem; }

        /* ── Responsive ── */
        @media (max-width: 768px) {
            .audit-filter-bar .row > div { margin-bottom: 0.5rem; }
            .audit-table thead { display: none; }
            .audit-table tbody td {
                display: block;
                padding: 0.4rem 0.75rem;
                border-bottom: none;
            }
            .audit-table tbody tr {
                display: block;
                border-bottom: 2px solid #f1e0e6;
                padding: 0.5rem 0;
            }
            .audit-table tbody td::before {
                content: attr(data-label);
                font-weight: 700;
                color: #6b4c5b;
                display: inline-block;
                width: 90px;
                font-size: 0.7rem;
            }
        }
    </style>
</head>
<body class="admin-body">

<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" onclick="toggleSidebar()" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital"></i> CAMS <span>Admin</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role"><i class="bi bi-shield-check me-1"></i>Admin</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout">
            <i class="bi bi-box-arrow-right"></i> <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
    </div>
</nav>

<%@ include file="../layout/sidebar.jsp" %>

<main class="admin-main" id="adminMain">

    <%-- ========== PAGE HEADER ========== --%>
    <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
        <div>
            <h4 style="font-weight:700;color:#3d2630;margin:0;">
                <i class="bi bi-clipboard-data-fill" style="color:#c24b6e;"></i> Lịch Sử Hoạt Động
            </h4>
            <p style="color:#9e8590;font-size:0.82rem;margin:0.2rem 0 0 0;">
                Theo dõi và truy vết mọi thao tác trên hệ thống
            </p>
        </div>
        <div>
            <span style="font-size:0.78rem;color:#9e8590;">
                <i class="bi bi-clock"></i> Hôm nay: <strong style="color:#3d2630;">${fn:length(auditLogs)}</strong> hoạt động gần đây
            </span>
        </div>
    </div>

    <%-- ========== STATS ROW ========== --%>
    <div class="row g-3 mb-3">
        <div class="col-sm-4 col-6">
            <div class="audit-stat-card">
                <div class="audit-stat-icon total"><i class="bi bi-journal-text"></i></div>
                <div>
                    <div class="audit-stat-value">${totalLogs}</div>
                    <div class="audit-stat-label">Tổng số bản ghi</div>
                </div>
            </div>
        </div>
        <div class="col-sm-4 col-6">
            <div class="audit-stat-card">
                <div class="audit-stat-icon today"><i class="bi bi-calendar-check"></i></div>
                <div>
                    <div class="audit-stat-value">${currentPage} / ${totalPages}</div>
                    <div class="audit-stat-label">Trang hiện tại</div>
                </div>
            </div>
        </div>
        <div class="col-sm-4 col-6">
            <div class="audit-stat-card">
                <div class="audit-stat-icon users"><i class="bi bi-people"></i></div>
                <div>
                    <div class="audit-stat-value">${fn:length(userOptions)}</div>
                    <div class="audit-stat-label">Người dùng đã hoạt động</div>
                </div>
            </div>
        </div>
    </div>

    <%-- ========== FILTER BAR ========== --%>
    <form method="GET" action="${pageContext.request.contextPath}/admin/audit-logs/" class="audit-filter-bar">
        <div class="row g-2 align-items-end">
            <%-- Search --%>
            <div class="col-md-3 col-sm-6">
                <label class="form-label"><i class="bi bi-search"></i> Tìm kiếm</label>
                <input type="text" name="search" class="form-control"
                       placeholder="Từ khoá hành động, người dùng..."
                       value="${fn:escapeXml(filterSearch)}">
            </div>

            <%-- Module (table_name) --%>
            <div class="col-md-1 col-sm-6">
                <label class="form-label"><i class="bi bi-grid"></i> Phân hệ</label>
                <select name="tableName" class="form-select">
                    <option value="">Tất cả</option>
                    <c:forEach var="opt" items="${tableOptions}">
                        <option value="${opt.key}" ${opt.key eq filterTableName ? 'selected' : ''}>
                            ${opt.value}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <%-- Role — hiển thị đầy đủ 7 role từ bảng roles --%>
            <div class="col-md-1 col-sm-6">
                <label class="form-label"><i class="bi bi-shield-check"></i> Vai trò</label>
                <select name="roleId" class="form-select">
                    <option value="">Tất cả</option>
                    <c:forEach var="r" items="${roleOptions}">
                        <option value="${r.userId}" ${r.userId eq filterRoleId ? 'selected' : ''}>
                            ${r.userName}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <%-- User --%>
            <div class="col-md-1 col-sm-6">
                <label class="form-label"><i class="bi bi-person"></i> Người dùng</label>
                <select name="userId" class="form-select">
                    <option value="">Tất cả</option>
                    <c:forEach var="u" items="${userOptions}">
                        <option value="${u.userId}" ${u.userId eq filterUserId ? 'selected' : ''}>
                            ${u.userName}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <%-- Date From --%>
            <div class="col-md-2 col-sm-6">
                <label class="form-label"><i class="bi bi-calendar"></i> Từ ngày</label>
                <input type="date" name="dateFrom" class="form-control"
                       value="${fn:escapeXml(filterDateFrom)}">
            </div>

            <%-- Date To --%>
            <div class="col-md-2 col-sm-6">
                <label class="form-label"><i class="bi bi-calendar"></i> Đến ngày</label>
                <input type="date" name="dateTo" class="form-control"
                       value="${fn:escapeXml(filterDateTo)}">
            </div>

            <%-- Buttons --%>
            <div class="col-md-1 col-sm-6 d-flex gap-2">
                <button type="submit" class="btn btn-filter btn-filter-search flex-fill" title="Tìm kiếm">
                    <i class="bi bi-search"></i>
                </button>
                <a href="${pageContext.request.contextPath}/admin/audit-logs/"
                   class="btn btn-filter btn-filter-reset flex-fill" title="Xoá bộ lọc">
                    <i class="bi bi-arrow-clockwise"></i>
                </a>
            </div>
        </div>
    </form>

    <%-- ========== AUDIT LOG TABLE ========== --%>
    <div class="audit-table-card">
        <div class="card-header">
            <h5><i class="bi bi-list-ul"></i> Danh Sách Hoạt Động</h5>
            <span style="font-size:0.78rem;color:#9e8590;font-weight:500;">
                Hiển thị <strong style="color:#3d2630;">${fn:length(auditLogs)}</strong> / ${totalLogs} bản ghi
            </span>
        </div>

        <c:choose>
            <c:when test="${not empty auditLogs}">
                <div class="table-responsive">
                    <table class="audit-table">
                        <thead>
                            <tr>
                                <th style="width:60px;">#</th>
                                <th style="width:160px;">Thời Gian</th>
                                <th style="width:150px;">Người Dùng</th>
                                <th style="width:110px;">Phân hệ</th>
                                <th style="width:90px;">Loại</th>
                                <th>Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="log" items="${auditLogs}" varStatus="loop">
                                <tr onclick="openDetail(${log.id})" title="Nhấp để xem chi tiết">
                                    <%-- ID --%>
                                    <td data-label="#">
                                        <span style="font-weight:600;color:#c24b6e;">#${log.id}</span>
                                    </td>

                                    <%-- Thời gian --%>
                                    <td data-label="Thời Gian">
                                        <c:choose>
                                            <c:when test="${not empty log.createdAt}">
                                                <fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy" var="logDate"/>
                                                <fmt:formatDate value="${log.createdAt}" pattern="HH:mm:ss" var="logTime"/>
                                                <div style="font-weight:600;">${logDate}</div>
                                                <div style="font-size:0.73rem;color:#9e8590;">${logTime}</div>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:#9e8590;">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- Người dùng --%>
                                    <td data-label="Người Dùng">
                                        <div class="audit-user-name">${log.userName}</div>
                                        <div class="audit-user-role">${log.roleNameDisplay}</div>
                                    </td>

                                    <%-- Module --%>
                                    <td data-label="Phân hệ">
                                        <c:set var="tbl" value="${log.tableName}"/>
                                        <span class="badge-module">
                                            <c:choose>
                                                <c:when test="${tbl eq 'users'}"><i class="bi bi-people"></i> Người dùng</c:when>
                                                <c:when test="${tbl eq 'roles'}"><i class="bi bi-shield-lock"></i> Vai trò</c:when>
                                                <c:when test="${tbl eq 'doctors'}"><i class="bi bi-person-badge"></i> Bác sĩ</c:when>
                                                <c:when test="${tbl eq 'patients'}"><i class="bi bi-heart"></i> Bệnh nhân</c:when>
                                                <c:when test="${tbl eq 'services'}"><i class="bi bi-clipboard2-pulse"></i> Dịch vụ</c:when>
                                                <c:when test="${tbl eq 'medicines'}"><i class="bi bi-capsule"></i> Thuốc</c:when>
                                                <c:when test="${tbl eq 'appointments'}"><i class="bi bi-calendar-check"></i> Lịch hẹn</c:when>
                                                <c:when test="${tbl eq 'doctor_schedules'}"><i class="bi bi-calendar-week"></i> Lịch trực</c:when>
                                                <c:when test="${tbl eq 'time_slots'}"><i class="bi bi-clock"></i> Khung giờ</c:when>
                                                <c:when test="${tbl eq 'medical_records'}"><i class="bi bi-file-medical"></i> Bệnh án</c:when>
                                                <c:when test="${tbl eq 'prescriptions'}"><i class="bi bi-prescription2"></i> Đơn thuốc</c:when>
                                                <c:when test="${tbl eq 'invoices'}"><i class="bi bi-receipt"></i> Hoá đơn</c:when>
                                                <c:when test="${tbl eq 'notifications'}"><i class="bi bi-bell"></i> Thông báo</c:when>
                                                <c:when test="${tbl eq 'reviews'}"><i class="bi bi-star"></i> Đánh giá</c:when>
                                                <c:when test="${tbl eq 'system_settings'}"><i class="bi bi-gear"></i> Cài đặt</c:when>
                                                <c:when test="${tbl eq 'ultrasound_images'}"><i class="bi bi-camera"></i> Ảnh siêu âm</c:when>
                                                <c:when test="${tbl eq 'ultrasound_results'}"><i class="bi bi-file-image"></i> Kết quả siêu âm</c:when>
                                                <c:when test="${tbl eq 'access_control'}"><i class="bi bi-shield-lock-fill"></i> Kiểm soát truy cập</c:when>
                                                <c:when test="${tbl eq 'security'}"><i class="bi bi-shield-exclamation"></i> Bảo mật</c:when>
                                                <c:when test="${tbl eq 'audit_logs'}"><i class="bi bi-journal-text"></i> Nhật ký</c:when>
                                                <c:when test="${tbl eq 'test_orders'}"><i class="bi bi-clipboard-check"></i> Phiếu xét nghiệm</c:when>
                                                <c:when test="${tbl eq 'lab_results'}"><i class="bi bi-file-earmark-bar-graph"></i> Kết quả xét nghiệm</c:when>
                                                <c:when test="${tbl eq 'ai_analysis_results'}"><i class="bi bi-cpu"></i> Kết quả AI</c:when>
                                                <c:when test="${tbl eq 'pregnancies'}"><i class="bi bi-heart-pulse"></i> Thai kỳ</c:when>
                                                <c:when test="${tbl eq 'sonographers'}"><i class="bi bi-person-workspace"></i> KTV siêu âm</c:when>
                                                <c:when test="${tbl eq 'prescription_items'}"><i class="bi bi-prescription2"></i> Chi tiết đơn thuốc</c:when>
                                                <c:when test="${tbl eq 'invoice_items'}"><i class="bi bi-receipt-cutoff"></i> Chi tiết hoá đơn</c:when>
                                                <c:when test="${tbl eq 'medicine_categories'}"><i class="bi bi-tags"></i> Danh mục thuốc</c:when>
                                                <c:when test="${tbl eq 'service_categories'}"><i class="bi bi-tags-fill"></i> Danh mục dịch vụ</c:when>
                                                <c:when test="${tbl eq 'price_history'}"><i class="bi bi-graph-up"></i> Lịch sử giá DV</c:when>
                                                <c:when test="${tbl eq 'medicine_price_history'}"><i class="bi bi-graph-up-arrow"></i> Lịch sử giá thuốc</c:when>
                                                <c:when test="${tbl eq 'role_permissions'}"><i class="bi bi-key"></i> Phân quyền</c:when>
                                                <c:when test="${tbl eq 'permissions'}"><i class="bi bi-key-fill"></i> Quyền hệ thống</c:when>
                                                <c:when test="${tbl eq 'password_reset_tokens'}"><i class="bi bi-lock"></i> Token đặt lại MK</c:when>
                                                <c:otherwise>${tbl}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>

                                    <%-- Loại hành động --%>
                                    <td data-label="Loại">
                                        <c:set var="atype" value="${log.actionType}"/>
                                        <span class="badge-action badge-${fn:toLowerCase(atype)}">${log.actionTypeDisplay}</span>
                                    </td>

                                    <%-- Hành động --%>
                                    <td data-label="Hành Động">
                                        <span class="audit-action-text">${log.action}</span>
                                        <c:if test="${not empty log.ipAddress and log.ipAddress ne 'unknown'}">
                                            <span class="audit-action-ip">
                                                <i class="bi bi-globe2"></i> ${log.ipAddress}
                                            </span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <%-- ========== PAGINATION ========== --%>
                <c:if test="${totalPages > 1}">
                    <div class="audit-pagination">
                        <div class="page-info">
                            Trang ${currentPage} / ${totalPages} &middot; ${totalLogs} bản ghi
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <%-- Build pagination URL with current filters --%>
                            <c:url var="pageUrl" value="/admin/audit-logs/">
                                <c:if test="${not empty filterSearch}"><c:param name="search" value="${filterSearch}"/></c:if>
                                <c:if test="${not empty filterTableName}"><c:param name="tableName" value="${filterTableName}"/></c:if>
                                <c:if test="${not empty filterUserId}"><c:param name="userId" value="${filterUserId}"/></c:if>
                                <c:if test="${not empty filterRoleId}"><c:param name="roleId" value="${filterRoleId}"/></c:if>
                                <c:if test="${not empty filterDateFrom}"><c:param name="dateFrom" value="${filterDateFrom}"/></c:if>
                                <c:if test="${not empty filterDateTo}"><c:param name="dateTo" value="${filterDateTo}"/></c:if>
                            </c:url>
                            <%-- Xác định separator: ? nếu chưa có query string, & nếu đã có --%>
                            <c:set var="sep" value="${fn:contains(pageUrl, '?') ? '&' : '?'}"/>

                            <%-- Previous --%>
                            <c:choose>
                                <c:when test="${currentPage > 1}">
                                    <a href="${pageUrl}${sep}page=${currentPage - 1}" class="page-btn" title="Trang trước">
                                        <i class="bi bi-chevron-left"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="page-btn disabled"><i class="bi bi-chevron-left"></i></span>
                                </c:otherwise>
                            </c:choose>

                            <%-- Page numbers (max 7 visible) --%>
                            <c:set var="maxVisible" value="7"/>
                            <c:set var="startPage" value="${currentPage - 3}"/>
                            <c:set var="endPage"   value="${currentPage + 3}"/>
                            <c:if test="${startPage < 1}">
                                <c:set var="startPage" value="1"/>
                                <c:set var="endPage" value="${startPage + maxVisible - 1}"/>
                            </c:if>
                            <c:if test="${endPage > totalPages}">
                                <c:set var="endPage" value="${totalPages}"/>
                                <c:set var="startPage" value="${endPage - maxVisible + 1}"/>
                                <c:if test="${startPage < 1}"><c:set var="startPage" value="1"/></c:if>
                            </c:if>

                            <c:if test="${startPage > 1}">
                                <a href="${pageUrl}${sep}page=1" class="page-btn">1</a>
                                <c:if test="${startPage > 2}">
                                    <span class="page-btn disabled">…</span>
                                </c:if>
                            </c:if>

                            <c:forEach var="p" begin="${startPage}" end="${endPage}">
                                <a href="${pageUrl}${sep}page=${p}"
                                   class="page-btn ${p eq currentPage ? 'active' : ''}">${p}</a>
                            </c:forEach>

                            <c:if test="${endPage < totalPages}">
                                <c:if test="${endPage < totalPages - 1}">
                                    <span class="page-btn disabled">…</span>
                                </c:if>
                                <a href="${pageUrl}${sep}page=${totalPages}" class="page-btn">${totalPages}</a>
                            </c:if>

                            <%-- Next --%>
                            <c:choose>
                                <c:when test="${currentPage < totalPages}">
                                    <a href="${pageUrl}${sep}page=${currentPage + 1}" class="page-btn" title="Trang sau">
                                        <i class="bi bi-chevron-right"></i>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="page-btn disabled"><i class="bi bi-chevron-right"></i></span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:if>
            </c:when>

            <c:otherwise>
                <div class="audit-empty">
                    <i class="bi bi-clipboard"></i>
                    <h6>Chưa Có Nhật Ký Nào</h6>
                    <p>
                        <c:choose>
                            <c:when test="${not empty filterSearch or not empty filterTableName or not empty filterUserId or not empty filterDateFrom or not empty filterDateTo}">
                                Không tìm thấy bản ghi nào khớp với bộ lọc hiện tại.
                                <br><a href="${pageContext.request.contextPath}/admin/audit-logs/" style="color:#c24b6e;font-weight:600;">Xoá bộ lọc</a>
                            </c:when>
                            <c:otherwise>
                                Hoạt động hệ thống sẽ được ghi lại ở đây khi người dùng thực hiện các thao tác.
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- ========== DETAIL MODAL ========== --%>
    <div class="modal fade modal-audit" id="auditDetailModal" tabindex="-1"
         aria-labelledby="auditDetailModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content" style="border-radius:16px;border:none;overflow:hidden;">
                <div class="modal-header">
                    <h5 class="modal-title" id="auditDetailModalLabel">
                        <i class="bi bi-info-circle-fill" style="color:#c24b6e;"></i>
                        Chi Tiết Nhật Ký
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body" id="auditDetailBody">
                    <div class="text-center py-5">
                        <div class="spinner-border" style="color:#c24b6e;" role="status">
                            <span class="visually-hidden">Đang tải...</span>
                        </div>
                        <p class="mt-3" style="color:#9e8590;">Đang tải chi tiết...</p>
                    </div>
                </div>
                <div class="modal-footer" style="border-top:1px solid #f1e0e6;">
                    <button type="button" class="btn btn-sm" data-bs-dismiss="modal"
                            style="background:#f5ebef;color:#6b4c5b;font-weight:600;border-radius:8px;">
                        <i class="bi bi-x-circle me-1"></i> Đóng
                    </button>
                </div>
            </div>
        </div>
    </div>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous">
</script>

<script>
    /**
     * Mở modal xem chi tiết audit log.
     * Gọi AJAX để lấy dữ liệu từ server (tái sử dụng AuditLogDAO.findById).
     */
    function openDetail(logId) {
        const modal = new bootstrap.Modal(document.getElementById('auditDetailModal'));
        const body  = document.getElementById('auditDetailBody');

        // Hiển thị loading
        body.innerHTML = `
            <div class="text-center py-5">
                <div class="spinner-border" style="color:#c24b6e;" role="status">
                    <span class="visually-hidden">Đang tải...</span>
                </div>
                <p class="mt-3" style="color:#9e8590;">Đang tải chi tiết...</p>
            </div>`;

        modal.show();

        // Fetch dữ liệu — gọi trực tiếp servlet với tham số id
        const ctx = '${pageContext.request.contextPath}';
        fetch(ctx + '/admin/audit-logs/?action=detail&id=' + logId, {
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(response => {
            if (!response.ok) throw new Error('HTTP ' + response.status);
            return response.json();
        })
        .then(data => {
            if (data.error) {
                body.innerHTML = '<div class="alert alert-danger m-3">' + data.error + '</div>';
                return;
            }
            body.innerHTML = renderDetail(data);
        })
        .catch(err => {
            body.innerHTML = `
                <div class="alert alert-warning m-3">
                    <i class="bi bi-exclamation-triangle me-2"></i>
                    Không thể tải chi tiết. Vui lòng thử lại.
                    <br><small class="text-muted">Lỗi: ` + err.message + `</small>
                </div>`;
        });
    }

    function renderDetail(log) {
        const ip = log.ipAddress && log.ipAddress !== 'unknown' ? log.ipAddress : '—';
        const oldVal = log.oldValue || '—';
        const newVal = log.newValue || '—';

        return `
            <div class="row g-3">
                <div class="col-sm-6">
                    <div class="detail-label"><i class="bi bi-person-fill me-1"></i> Người thực hiện</div>
                    <div class="detail-value">` + escapeHtml(log.userName) + `
                        <span style="color:#9e8590;font-size:0.75rem;">(` + escapeHtml(log.roleName) + `)</span>
                    </div>
                </div>
                <div class="col-sm-6">
                    <div class="detail-label"><i class="bi bi-clock-fill me-1"></i> Thời gian</div>
                    <div class="detail-value">` + (log.createdAtDisplay || '—') + `</div>
                </div>
                <div class="col-sm-6">
                    <div class="detail-label"><i class="bi bi-globe2 me-1"></i> Địa chỉ IP</div>
                    <div class="detail-value">` + ip + `</div>
                </div>
                <div class="col-sm-6">
                    <div class="detail-label"><i class="bi bi-grid-fill me-1"></i> Phân hệ / Bảng</div>
                    <div class="detail-value">
                        <span class="badge-module">` + escapeHtml(log.tableName || '—') + `</span>
                    </div>
                </div>
                <div class="col-12">
                    <div class="detail-label"><i class="bi bi-chat-left-text-fill me-1"></i> Hành động</div>
                    <div class="detail-value">` + escapeHtml(log.action || '—') + `</div>
                </div>
            </div>
            <hr style="border-color:#f1e0e6;">
            <div class="row g-3">
                <div class="col-sm-6">
                    <div class="detail-label">
                        <span style="background:#fadbd8;color:#922b21;padding:0.1rem 0.4rem;border-radius:4px;font-size:0.7rem;">CŨ</span>
                        Giá trị cũ
                    </div>
                    <div class="diff-box">` + escapeHtml(oldVal) + `</div>
                </div>
                <div class="col-sm-6">
                    <div class="detail-label">
                        <span style="background:#d4edda;color:#1b5e20;padding:0.1rem 0.4rem;border-radius:4px;font-size:0.7rem;">MỚI</span>
                        Giá trị mới
                    </div>
                    <div class="diff-box">` + escapeHtml(newVal) + `</div>
                </div>
            </div>`;
    }

    function escapeHtml(str) {
        if (!str) return '—';
        const div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }
</script>
</body>
</html>
