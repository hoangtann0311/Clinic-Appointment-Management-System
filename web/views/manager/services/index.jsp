<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dịch Vụ Y Tế — CAMS Quản Lý</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        /* ── Page-specific Styles ── */
        .page-header-gradient {
            background: linear-gradient(135deg, #fff9fc 0%, #fff1f6 40%, #fff1f6 100%);
            border-radius: var(--r-lg);
            padding: 1.5rem 1.75rem;
            margin-bottom: 1.5rem;
            border: 1px solid var(--pink-200);
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 1rem;
        }
        .page-header-gradient .phg-left h1 {
            font-family: var(--font-display);
            font-weight: 800;
            font-size: 1.5rem;
            color: var(--c-primary-dark);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .page-header-gradient .phg-left .subtitle {
            font-size: 0.82rem;
            color: var(--c-muted);
            margin-top: 0.25rem;
        }

        /* KPI Row */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        .kpi-card {
            background: var(--c-surface);
            border: 1px solid var(--c-outline-variant);
            border-radius: var(--r-md);
            padding: 1.2rem 1.2rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all var(--t-slow);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }
        .kpi-card::after {
            content: '';
            position: absolute;
            top: 0; right: 0;
            width: 80px; height: 80px;
            border-radius: 0 0 0 100%;
            opacity: 0.06;
            transition: all var(--t-slow);
        }
        .kpi-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); border-color: var(--pink-200); }
        .kpi-card:hover::after { opacity: 0.12; width: 100px; height: 100px; }
        .kpi-card.kpi-total::after { background: var(--pink-500); }
        .kpi-card.kpi-active::after { background: #2e7d32; }
        .kpi-card.kpi-inactive::after { background: #e65100; }
        .kpi-card.kpi-revenue::after { background: #6366f1; }
        .kpi-card.kpi-categories::after { background: #0891b2; }
        .kpi-icon {
            width: 48px; height: 48px; border-radius: var(--r-sm);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem; flex-shrink: 0; color: #fff;
        }
        .kpi-icon.kpi-total { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); }
        .kpi-icon.kpi-active { background: linear-gradient(135deg, #43a047, #2e7d32); }
        .kpi-icon.kpi-inactive { background: linear-gradient(135deg, #ff9800, #e65100); }
        .kpi-icon.kpi-revenue { background: linear-gradient(135deg, #818cf8, #6366f1); }
        .kpi-icon.kpi-categories { background: linear-gradient(135deg, #22d3ee, #0891b2); }
        .kpi-body { flex: 1; min-width: 0; }
        .kpi-value { font-family: var(--font-display); font-size: 1.5rem; font-weight: 900; color: var(--c-on-surface); line-height: 1.1; }
        .kpi-label { font-size: 0.72rem; font-weight: 600; color: var(--c-muted); text-transform: uppercase; letter-spacing: 0.05em; }
        .kpi-sub { font-size: 0.7rem; color: var(--c-muted); margin-top: 0.15rem; }

        /* Category Chips */
        .category-chips {
            display: flex; flex-wrap: wrap; gap: 0.4rem;
            padding: 0.75rem 1rem;
            background: var(--c-surface);
            border-bottom: 1px solid var(--c-outline-variant);
        }
        .cat-chip {
            display: inline-flex; align-items: center; gap: 0.35rem;
            padding: 0.4rem 0.85rem; border-radius: var(--r-pill);
            font-size: 0.78rem; font-weight: 600;
            border: 1px solid var(--c-outline); color: var(--c-on-surface-var);
            background: var(--c-surface); text-decoration: none;
            transition: all var(--t-fast); white-space: nowrap;
        }
        .cat-chip:hover { background: var(--pink-50); border-color: var(--pink-300); color: var(--c-primary); }
        .cat-chip.active { background: var(--pink-500); color: #fff; border-color: var(--pink-500); }
        .cat-chip .cat-count { font-size: 0.68rem; opacity: 0.8; }

        /* Filter Bar */
        .filter-bar {
            display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: center;
            padding: 0.75rem 1rem; background: var(--c-surface); border-bottom: 1px solid var(--c-outline-variant);
        }
        .filter-bar .form-control, .filter-bar .form-select {
            width: auto; min-width: 140px; border-radius: var(--r-sm);
            border: 1px solid var(--c-outline); font-size: 0.82rem; padding: 0.4rem 0.7rem;
        }
        .filter-bar .form-control:focus, .filter-bar .form-select:focus {
            border-color: var(--pink-500); box-shadow: 0 0 0 0.18rem rgba(184,102,137,0.12);
        }

        /* Table */
        .admin-card { background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-lg); overflow: hidden; }
        .admin-card-header-link { background: var(--pink-50); padding: 0.85rem 1.2rem; border-bottom: 1px solid var(--pink-200); display: flex; align-items: center; justify-content: space-between; }
        .admin-card-header-link h5 { margin: 0; font-family: var(--font-display); font-weight: 700; color: var(--c-primary-dark); font-size: 0.95rem; }
        .admin-table-wrapper { overflow-x: auto; }
        .admin-table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
        .admin-table th { background: var(--c-surface-variant); color: var(--c-on-surface-var); font-weight: 700; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.04em; padding: 0.7rem 0.85rem; border-bottom: 2px solid var(--c-outline); white-space: nowrap; }
        .admin-table td { padding: 0.75rem 0.85rem; border-bottom: 1px solid var(--c-outline-variant); vertical-align: middle; }
        .admin-table tbody tr { transition: all var(--t-fast); }
        .admin-table tbody tr:hover { background: #fff5f9; }

        .svc-code-badge {
            display: inline-block; padding: 3px 10px; border-radius: var(--r-pill);
            font-size: 0.72rem; font-weight: 700; font-family: 'Courier New', monospace;
            background: var(--pink-100); color: var(--pink-700);
            border: 1px solid var(--pink-200);
        }
        .price-tag { font-family: var(--font-display); font-weight: 800; color: var(--c-primary); font-size: 0.9rem; }
        .usage-badge { font-size: 0.75rem; font-weight: 600; color: var(--c-muted); }
        .cat-badge {
            display: inline-flex; align-items: center; gap: 0.25rem;
            padding: 2px 10px; border-radius: var(--r-pill);
            font-size: 0.7rem; font-weight: 700;
            background: var(--pink-50); color: var(--pink-600);
            border: 1px solid var(--pink-200);
        }
        .req-tag {
            display: inline-block; padding: 2px 8px; border-radius: var(--r-pill);
            font-size: 0.6rem; font-weight: 700;
            background: #fff3e0; color: #e65100;
        }

        .action-btn-group { display: flex; gap: 0.25rem; flex-wrap: nowrap; }
        .action-btn {
            width: 32px; height: 32px; border-radius: var(--r-sm); border: 1px solid var(--c-outline);
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 0.85rem; color: var(--c-on-surface-var); background: var(--c-surface);
            transition: all var(--t-fast); cursor: pointer;
        }
        .action-btn:hover { background: var(--pink-50); border-color: var(--pink-300); color: var(--pink-600); }
        .action-btn.btn-warn:hover { background: #fff3e0; border-color: #ff9800; color: #e65100; }
        .action-btn.btn-danger:hover { background: #ffebee; border-color: #f44336; color: #c62828; }

        /* Modals */
        .modal-content { border-radius: var(--r-lg) !important; border: 1px solid var(--c-outline-variant) !important; overflow: hidden; }
        .modal-header { background: var(--pink-50) !important; border-bottom: 1px solid var(--pink-200) !important; }
        .modal-header .modal-title { font-family: var(--font-display); font-weight: 800; color: var(--c-primary-dark); font-size: 1.1rem; }
        .modal-footer { border-top: 1px solid var(--c-outline-variant) !important; }
        .form-section-title {
            font-size: 0.7rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: 0.08em; color: var(--c-primary);
            padding-bottom: 0.4rem; margin-bottom: 0.75rem;
            border-bottom: 2px solid var(--pink-100);
        }

        .btn-primary-pink {
            background: linear-gradient(135deg, var(--pink-500), var(--pink-600));
            color: #fff; border: none; font-weight: 700;
            border-radius: var(--r-sm); padding: 0.5rem 1.1rem;
            transition: all var(--t-fast); font-family: var(--font-body);
        }
        .btn-primary-pink:hover {
            background: linear-gradient(135deg, var(--pink-600), var(--pink-700));
            color: #fff; transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(184,102,137,0.3);
        }
        .btn-outline-pink {
            background: #fff; border: 1.5px solid var(--pink-300); color: var(--pink-600);
            font-weight: 600; border-radius: var(--r-sm); padding: 0.5rem 1.1rem;
            transition: all var(--t-fast);
        }
        .btn-outline-pink:hover { background: var(--pink-50); border-color: var(--pink-500); }

        /* Pagination */
        .admin-pagination { display: flex; justify-content: center; gap: 0.2rem; margin-top: 1rem; padding: 0.5rem; }
        .admin-pagination a, .admin-pagination span {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 36px; height: 36px; padding: 0 0.4rem; border-radius: var(--r-sm);
            font-size: 0.82rem; font-weight: 600; text-decoration: none;
            border: 1px solid var(--c-outline-variant); color: var(--c-on-surface-var);
            transition: all var(--t-fast);
        }
        .admin-pagination a:hover { background: var(--pink-50); border-color: var(--pink-200); color: var(--c-primary); }
        .admin-pagination .active { background: var(--pink-500); color: #fff; border-color: var(--pink-500); }

        /* Detail Modal Table */
        .detail-table { width: 100%; }
        .detail-table th { width: 140px; font-size: 0.78rem; color: var(--c-muted); font-weight: 600; padding: 0.5rem 0.75rem; vertical-align: top; }
        .detail-table td { font-size: 0.85rem; padding: 0.5rem 0.75rem; }

        /* Price History Timeline */
        .timeline { position: relative; padding-left: 2rem; }
        .timeline::before {
            content: ''; position: absolute; left: 0.65rem; top: 0; bottom: 0;
            width: 2px; background: var(--pink-200);
        }
        .timeline-item { position: relative; margin-bottom: 1rem; padding-left: 1rem; }
        .timeline-item::before {
            content: ''; position: absolute; left: -1.65rem; top: 0.4rem;
            width: 12px; height: 12px; border-radius: 50%;
            background: var(--pink-500); border: 2px solid #fff;
            box-shadow: 0 0 0 2px var(--pink-300);
        }
        .timeline-item:first-child::before { background: var(--pink-600); box-shadow: 0 0 0 3px var(--pink-300); }
        .timeline-body { background: var(--c-surface-variant); border-radius: var(--r-sm); padding: 0.6rem 0.85rem; border: 1px solid var(--c-outline-variant); }
        .timeline-date { font-size: 0.7rem; color: var(--c-muted); }
        .timeline-prices { display: flex; align-items: center; gap: 0.5rem; margin-top: 0.2rem; font-size: 0.82rem; }
        .timeline-old { color: #c62828; text-decoration: line-through; font-weight: 600; }
        .timeline-arrow { color: var(--pink-500); }
        .timeline-new { color: #2e7d32; font-weight: 700; }

        /* Revenue stats cards */
        .revenue-card {
            background: var(--c-surface); border: 1px solid var(--c-outline-variant);
            border-radius: var(--r-md); padding: 1rem;
            display: flex; align-items: center; gap: 0.75rem;
            transition: all var(--t-fast);
        }
        .revenue-card:hover { border-color: var(--pink-200); }
        .rev-icon {
            width: 42px; height: 42px; border-radius: var(--r-sm);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem; color: #fff; flex-shrink: 0;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .kpi-grid { grid-template-columns: repeat(2, 1fr); }
            .page-header-gradient { flex-direction: column; text-align: center; }
        }

        /* ── Validation Styles ── */
        .was-validated .form-control:invalid,
        .form-control.is-invalid {
            border-color: #c62828 !important;
            box-shadow: 0 0 0 0.18rem rgba(198,40,40,0.15) !important;
        }
        .was-validated .form-control:valid,
        .form-control.is-valid {
            border-color: #2e7d32 !important;
            box-shadow: 0 0 0 0.18rem rgba(46,125,50,0.12) !important;
        }
        .invalid-feedback {
            display: none;
            font-size: 0.72rem;
            color: #c62828;
            margin-top: 0.2rem;
        }
        .is-invalid ~ .invalid-feedback,
        .was-validated .form-control:invalid ~ .invalid-feedback {
            display: block;
        }
    </style>
</head>
<body class="admin-body">

<%-- ===== TOP BAR ===== --%>
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

<%-- ===== SIDEBAR ===== --%>
<%@ include file="../layout/sidebar.jsp" %>

<%-- ===== MAIN CONTENT ===== --%>
<main class="admin-main" id="adminMain">

    <%-- Page Header --%>
    <div class="page-header-gradient">
        <div class="phg-left">
            <h1>
                <i class="bi bi-activity" style="color:var(--pink-500);"></i>
                Dịch Vụ Y Tế
            </h1>
            <div class="subtitle">
                <i class="bi bi-clipboard2-pulse me-1"></i>
                Quản lý danh mục dịch vụ chuyên môn — Phòng khám Sản Phụ Khoa
            </div>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/manager/services/?action=price-history"
               class="btn btn-outline-pink">
                <i class="bi bi-clock-history me-1"></i>Lịch Sử Giá
            </a>
            <button class="btn btn-primary-pink" data-bs-toggle="modal" data-bs-target="#addServiceModal">
                <i class="bi bi-plus-circle-fill me-1"></i>Thêm Dịch Vụ Mới
            </button>
        </div>
    </div>

    <%-- ===== KPI CARDS ===== --%>
    <div class="kpi-grid">
        <div class="kpi-card kpi-total" onclick="window.location='${pageContext.request.contextPath}/manager/services/'">
            <div class="kpi-icon kpi-total"><i class="bi bi-activity"></i></div>
            <div class="kpi-body">
                <div class="kpi-value">${totalServices}</div>
                <div class="kpi-label">Tổng Dịch Vụ</div>
            </div>
        </div>
        <div class="kpi-card kpi-active" onclick="window.location='${pageContext.request.contextPath}/manager/services/?active=1'">
            <div class="kpi-icon kpi-active"><i class="bi bi-check-circle-fill"></i></div>
            <div class="kpi-body">
                <div class="kpi-value">${activeServicesCount}</div>
                <div class="kpi-label">Đang Hoạt Động</div>
                <div class="kpi-sub">
                    <fmt:formatNumber value="${totalServices > 0 ? (activeServicesCount / totalServices * 100) : 0}" maxFractionDigits="0"/>% tổng số
                </div>
            </div>
        </div>
        <div class="kpi-card kpi-inactive" onclick="window.location='${pageContext.request.contextPath}/manager/services/?active=0'">
            <div class="kpi-icon kpi-inactive"><i class="bi bi-slash-circle-fill"></i></div>
            <div class="kpi-body">
                <div class="kpi-value">${totalServices - activeServicesCount}</div>
                <div class="kpi-label">Ngừng Hoạt Động</div>
            </div>
        </div>
        <div class="kpi-card kpi-categories">
            <div class="kpi-icon kpi-categories"><i class="bi bi-collection-fill"></i></div>
            <div class="kpi-body">
                <div class="kpi-value">${fn:length(categories)}</div>
                <div class="kpi-label">Nhóm Dịch Vụ</div>
            </div>
        </div>
        <div class="kpi-card kpi-revenue">
            <div class="kpi-icon kpi-revenue"><i class="bi bi-cash-stack"></i></div>
            <div class="kpi-body">
                <c:set var="totalRev" value="0"/>
                <c:forEach var="r" items="${revenueByCategory}">
                    <c:set var="totalRev" value="${totalRev + r.totalRevenue}"/>
                </c:forEach>
                <div class="kpi-value">
                    <c:choose>
                        <c:when test="${totalRev >= 1000000000}"><fmt:formatNumber value="${totalRev / 1000000000}" maxFractionDigits="1"/> tỷ</c:when>
                        <c:when test="${totalRev >= 1000000}"><fmt:formatNumber value="${totalRev / 1000000}" maxFractionDigits="1"/> tr</c:when>
                        <c:otherwise><fmt:formatNumber value="${totalRev}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></c:otherwise>
                    </c:choose>
                </div>
                <div class="kpi-label">Tổng Doanh Thu</div>
            </div>
        </div>
    </div>

    <%-- ===== ALERTS ===== --%>
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md); border-left: 4px solid #2e7d32;">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            <div>
                <c:choose>
                    <c:when test="${success eq 'created'}"><strong>Thành công!</strong> Đã tạo dịch vụ mới và ghi nhận giá khởi tạo.</c:when>
                    <c:when test="${success eq 'updated'}"><strong>Thành công!</strong> Đã cập nhật thông tin dịch vụ. <c:if test="${not empty priceChanged}">Lịch sử giá đã được ghi nhận.</c:if></c:when>
                    <c:when test="${success eq 'deactivated'}"><strong>Thành công!</strong> Đã ngừng hoạt động dịch vụ. Dữ liệu lịch sử được bảo toàn.</c:when>
                    <c:when test="${success eq 'activated'}"><strong>Thành công!</strong> Đã kích hoạt lại dịch vụ.</c:when>
                </c:choose>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md); border-left: 4px solid #c62828;">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div>${error}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <%-- ===== CATEGORY CHIPS (Quick Filter) ===== --%>
    <div class="admin-card mb-0">
        <div class="category-chips">
            <a href="${pageContext.request.contextPath}/manager/services/<c:if test='${not empty search}'>?search=${fn:escapeXml(search)}</c:if>"
               class="cat-chip ${empty categoryFilter || categoryFilter eq '' ? 'active' : ''}">
                <i class="bi bi-grid-fill"></i> Tất cả
                <span class="cat-count">${totalServices}</span>
            </a>
            <c:forEach var="cat" items="${categories}">
                <c:url var="catUrl" value="/manager/services/">
                    <c:param name="category" value="${cat.id}"/>
                    <c:if test="${not empty search}"><c:param name="search" value="${search}"/></c:if>
                    <c:if test="${not empty activeFilter}"><c:param name="active" value="${activeFilter}"/></c:if>
                </c:url>
                <a href="${catUrl}" class="cat-chip ${categoryFilter eq cat.id.toString() ? 'active' : ''}">
                    <i class="bi ${not empty cat.icon ? cat.icon : 'bi-folder'}"></i>
                    ${fn:escapeXml(cat.categoryName)}
                    <span class="cat-count">${cat.serviceCount}</span>
                </a>
            </c:forEach>
        </div>

        <%-- Filter Bar --%>
        <form method="get" action="${pageContext.request.contextPath}/manager/services/" class="filter-bar">
            <div class="input-group" style="max-width:280px;">
                <span class="input-group-text" style="background:var(--pink-50);border-color:var(--c-outline);">
                    <i class="bi bi-search"></i>
                </span>
                <input type="text" name="search" class="form-control" placeholder="Tìm tên, mã dịch vụ..."
                       value="${not empty search ? fn:escapeXml(search) : ''}">
            </div>
            <select name="active" class="form-select">
                <option value="">Tất cả trạng thái</option>
                <option value="1" ${activeFilter eq '1' ? 'selected' : ''}>🟢 Đang hoạt động</option>
                <option value="0" ${activeFilter eq '0' ? 'selected' : ''}>⚫ Ngừng hoạt động</option>
            </select>
            <c:if test="${not empty categoryFilter}">
                <input type="hidden" name="category" value="${categoryFilter}">
            </c:if>
            <button type="submit" class="btn btn-primary-pink btn-sm">
                <i class="bi bi-funnel-fill me-1"></i>Lọc
            </button>
            <a href="${pageContext.request.contextPath}/manager/services/" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-counterclockwise me-1"></i>Đặt lại
            </a>
        </form>
    </div>

    <%-- ===== SERVICES TABLE ===== --%>
    <div class="admin-card mt-3">
        <div class="admin-card-header-link">
            <h5><i class="bi bi-activity me-2" style="color:var(--pink-500);"></i>Danh Sách Dịch Vụ Y Tế</h5>
            <span class="badge bg-white text-dark border" style="font-size:0.75rem;">
                <i class="bi bi-database me-1"></i>${totalServices} dịch vụ
            </span>
        </div>
        <div class="admin-table-wrapper">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th style="width:50px;">STT</th>
                        <th style="width:110px;">Mã DV</th>
                        <th>Tên Dịch Vụ</th>
                        <th style="width:100px;">Nhóm</th>
                        <th style="width:120px;">Đơn Giá</th>
                        <th style="width:85px;">Thời Gian</th>
                        <th style="width:90px;">Lượt SD</th>
                        <th style="width:105px;">Trạng Thái</th>
                        <th style="width:130px;">Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty services}">
                            <c:forEach var="svc" items="${services}" varStatus="row">
                                <tr>
                                    <td style="color:var(--c-muted);font-size:0.78rem;">${(currentPage - 1) * pageSize + row.count}</td>
                                    <td>
                                        <span class="svc-code-badge">
                                            ${not empty svc.serviceCode ? fn:escapeXml(svc.serviceCode) : '&mdash;'}
                                        </span>
                                    </td>
                                    <td style="font-weight:600;">
                                        <div class="d-flex align-items-center gap-2">
                                            <i class="bi ${not empty svc.categoryIcon ? svc.categoryIcon : 'bi-clipboard2-pulse'}" style="color:var(--pink-500);"></i>
                                            ${fn:escapeXml(svc.serviceName)}
                                        </div>
                                        <c:if test="${not empty svc.allowedSpecialties}">
                                            <div style="margin-top:2px;font-size:0.7rem;color:var(--c-muted);">
                                                <i class="bi bi-tag me-1"></i>${fn:escapeXml(svc.allowedSpecialties)}
                                            </div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:if test="${not empty svc.categoryName}">
                                            <span class="cat-badge">
                                                <i class="bi ${not empty svc.categoryIcon ? svc.categoryIcon : 'bi-folder'}"></i>
                                                ${fn:escapeXml(svc.categoryName)}
                                            </span>
                                        </c:if>
                                        <c:if test="${empty svc.categoryName}">
                                            <span style="color:var(--c-muted);font-size:0.75rem;">&mdash;</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <span class="price-tag">
                                            <fmt:formatNumber value="${svc.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${svc.durationMins > 0}">
                                                <span style="font-weight:600;">${svc.durationMins}</span>
                                                <span style="font-size:0.7rem;color:var(--c-muted);"> phút</span>
                                            </c:when>
                                            <c:otherwise><span style="color:var(--c-muted);">&mdash;</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${svc.usageCount > 0}">
                                                <span class="usage-badge">
                                                    <i class="bi bi-people-fill me-1"></i>${svc.usageCount}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:var(--c-muted);font-size:0.75rem;">0</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${svc.active}">
                                                <span class="badge-status badge-status-active">
                                                    <i class="bi bi-check-circle me-1"></i>Hoạt động
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status badge-status-inactive">
                                                    <i class="bi bi-slash-circle me-1"></i>Ngừng
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="action-btn-group">
                                            <a href="${pageContext.request.contextPath}/manager/services/?action=detail&id=${svc.id}"
                                               class="action-btn" title="Xem chi tiết">
                                                <i class="bi bi-eye-fill"></i>
                                            </a>
                                            <button class="action-btn"
                                                    onclick="openEditModal('${svc.id}','${fn:escapeXml(svc.serviceCode)}','${fn:escapeXml(svc.serviceName)}','${fn:escapeXml(svc.description)}','${svc.price}','${svc.durationMins}','${svc.requiresFasting}','${svc.requiresFullBladder}','${fn:escapeXml(svc.requiredRoomType)}','${fn:escapeXml(svc.allowedSpecialties)}','${svc.categoryId}','${svc.active}')"
                                                    title="Chỉnh sửa">
                                                <i class="bi bi-pencil-square"></i>
                                            </button>
                                            <form method="post" action="${pageContext.request.contextPath}/manager/services/" style="display:inline;">
                                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="action" value="toggle">
                                                <input type="hidden" name="id" value="${svc.id}">
                                                <button type="submit" class="action-btn ${svc.active ? 'btn-warn' : ''}"
                                                        title="${svc.active ? 'Ngừng hoạt động' : 'Kích hoạt'}"
                                                        onclick="return confirm('${svc.active ? 'Ngừng hoạt động' : 'Kích hoạt lại'} dịch vụ «${fn:escapeXml(svc.serviceName)}»?\n\n${svc.active ? 'Dịch vụ sẽ không được sử dụng cho giao dịch mới. Dữ liệu cũ vẫn được bảo toàn.' : 'Dịch vụ sẽ được sử dụng trở lại.'}')">
                                                    <i class="bi ${svc.active ? 'bi-toggle-on' : 'bi-toggle-off'}"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="9">
                                    <div class="admin-empty-state">
                                        <i class="bi bi-clipboard2-pulse" style="font-size:2.5rem; color:var(--c-muted);"></i>
                                        <h6 class="mt-2">Không tìm thấy dịch vụ</h6>
                                        <p class="text-muted">Chưa có dữ liệu hoặc không khớp với bộ lọc. Hãy thử lại hoặc tạo dịch vụ mới.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <%-- ===== PAGINATION ===== --%>
    <c:if test="${totalPages > 1}">
        <div class="admin-pagination">
            <c:url var="baseUrl" value="/manager/services/">
                <c:param name="search" value="${search}"/>
                <c:param name="active" value="${activeFilter}"/>
                <c:if test="${not empty categoryFilter}"><c:param name="category" value="${categoryFilter}"/></c:if>
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

    <%-- ===== REVENUE BY CATEGORY ===== --%>
    <c:if test="${not empty revenueByCategory}">
        <div class="admin-card mt-3">
            <div class="admin-card-header-link">
                <h5><i class="bi bi-pie-chart-fill me-2" style="color:var(--pink-500);"></i>Doanh Thu Theo Nhóm Dịch Vụ</h5>
            </div>
            <div style="padding:1rem; display:grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap:0.75rem;">
                <c:forEach var="rev" items="${revenueByCategory}">
                    <div class="revenue-card">
                        <div class="rev-icon" style="background: linear-gradient(135deg, var(--pink-400), var(--pink-600));">
                            <i class="bi ${not empty rev.categoryIcon ? rev.categoryIcon : 'bi-folder'}"></i>
                        </div>
                        <div style="flex:1;min-width:0;">
                            <div style="font-weight:700;font-size:0.85rem;color:var(--c-on-surface);">${fn:escapeXml(rev.categoryName)}</div>
                            <div style="font-size:0.72rem;color:var(--c-muted);">
                                <i class="bi bi-people me-1"></i>${rev.usageCount} lượt sử dụng
                            </div>
                            <div style="font-family:var(--font-display);font-weight:800;color:var(--c-primary);font-size:0.9rem;margin-top:2px;">
                                <c:choose>
                                    <c:when test="${rev.totalRevenue >= 1000000000}">
                                        <fmt:formatNumber value="${rev.totalRevenue / 1000000000}" maxFractionDigits="2"/> tỷ
                                    </c:when>
                                    <c:when test="${rev.totalRevenue >= 1000000}">
                                        <fmt:formatNumber value="${rev.totalRevenue / 1000000}" maxFractionDigits="1"/> tr
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${rev.totalRevenue}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:if>

</main>

<%-- ============================================================
     MODAL: THEM DICH VU MOI
     ============================================================ --%>
<div class="modal fade" id="addServiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="bi bi-plus-circle-fill me-2"></i>Thêm Dịch Vụ Mới
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/manager/services/"
                  id="addServiceForm" novalidate onsubmit="return validateAddService()">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="create">
                <div class="modal-body">
                    <!-- Server-side general error -->
                    <c:if test="${not empty errors.general}">
                        <div class="alert alert-danger d-flex align-items-center gap-2 mb-3" style="font-size:0.8rem;padding:0.5rem 0.75rem;border-radius:var(--r-sm);">
                            <i class="bi bi-exclamation-triangle-fill"></i>${errors.general}
                        </div>
                    </c:if>

                    <%-- Thông tin cơ bản --%>
                    <div class="form-section-title"><i class="bi bi-info-circle me-1"></i>Thông tin cơ bản</div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small">Mã dịch vụ <span class="text-danger">*</span></label>
                            <input type="text" name="serviceCode" id="addServiceCode"
                                   class="form-control form-control-sm text-uppercase" required
                                   minlength="3" maxlength="30"
                                   pattern="[A-Z0-9][A-Z0-9_\-]{2,29}"
                                   placeholder="VD: SVC-SIEU-AM-4D"
                                   value="${fn:escapeXml(formData.serviceCode)}"
                                   oninput="clearFieldError('serviceCode')"
                                   style="font-family:'Courier New',monospace;letter-spacing:0.05em;">
                            <div class="invalid-feedback" id="err-serviceCode"></div>
                            <div class="form-text" style="font-size:0.68rem;">Chữ IN HOA, số, gạch ngang (-), gạch dưới (_). 3-30 ký tự. Không khoảng trắng.</div>
                            <c:if test="${not empty errors.serviceCode}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.serviceCode}</div>
                            </c:if>
                        </div>
                        <div class="col-md-8">
                            <label class="form-label fw-semibold small">Tên dịch vụ <span class="text-danger">*</span></label>
                            <input type="text" name="serviceName" id="addServiceName"
                                   class="form-control form-control-sm" required
                                   minlength="2" maxlength="100"
                                   placeholder="VD: Siêu âm 4D thai kỳ"
                                   value="${fn:escapeXml(formData.serviceName)}"
                                   oninput="clearFieldError('serviceName')">
                            <div class="invalid-feedback" id="err-serviceName"></div>
                            <div class="form-text" style="font-size:0.68rem;">Tên rõ ràng, dễ hiểu, từ 2-100 ký tự. Không được chỉ gồm chữ số.</div>
                            <c:if test="${not empty errors.serviceName}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.serviceName}</div>
                            </c:if>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small">Mô tả dịch vụ</label>
                            <textarea name="description" id="addDescription"
                                      class="form-control form-control-sm" rows="2" maxlength="500"
                                      placeholder="Mô tả chi tiết về dịch vụ, quy trình thực hiện, đối tượng áp dụng..."
                                      oninput="updateCharCount('addDescription','descCount',500)">${fn:escapeXml(formData.description)}</textarea>
                            <div class="d-flex justify-content-between">
                                <div class="invalid-feedback d-block" id="err-description"></div>
                                <small class="text-muted" id="descCount" style="font-size:0.68rem;">0/500</small>
                            </div>
                        </div>
                    </div>

                    <%-- Giá & thời gian & nhóm --%>
                    <div class="form-section-title"><i class="bi bi-cash-coin me-1"></i>Giá &amp; Thời gian &amp; Nhóm</div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small">Đơn giá (VNĐ) <span class="text-danger">*</span></label>
                            <div class="input-group input-group-sm">
                                <span class="input-group-text fw-bold">₫</span>
                                <input type="text" name="price" id="addPrice"
                                       class="form-control" required
                                       placeholder="VD: 500000"
                                       value="${formData.price}"
                                       oninput="formatPriceInput(this);clearFieldError('price')"
                                       onkeypress="return onlyDigits(event)"
                                       autocomplete="off">
                            </div>
                            <div class="invalid-feedback" id="err-price"></div>
                            <div class="form-text" style="font-size:0.68rem;">Số nguyên dương, từ 50.000đ đến 100.000.000đ</div>
                            <c:if test="${not empty errors.price}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.price}</div>
                            </c:if>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Thời gian (phút) <span class="text-danger">*</span></label>
                            <input type="text" name="durationMins" id="addDurationMins"
                                   class="form-control form-control-sm" required
                                   list="durationSuggestions"
                                   placeholder="VD: 30"
                                   value="${formData.durationMins}"
                                   oninput="clearFieldError('durationMins')"
                                   onkeypress="return onlyDigits(event)"
                                   autocomplete="off">
                            <datalist id="durationSuggestions">
                                <option value="5">
                                <option value="10">
                                <option value="15">
                                <option value="20">
                                <option value="30">
                                <option value="45">
                                <option value="60">
                                <option value="90">
                                <option value="120">
                            </datalist>
                            <div class="invalid-feedback" id="err-durationMins"></div>
                            <div class="form-text" style="font-size:0.68rem;">Tối thiểu 5 phút, tối đa 480 phút (8 giờ).<br>Gợi ý: 5, 10, 15, 20, 30, 45, 60, 90 phút.</div>
                            <c:if test="${not empty errors.durationMins}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.durationMins}</div>
                            </c:if>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label fw-semibold small">Nhóm dịch vụ <span class="text-danger">*</span></label>
                            <select name="categoryId" id="addCategoryId" class="form-select form-select-sm" required
                                    onchange="clearFieldError('categoryId')">
                                <option value="">-- Chọn nhóm dịch vụ --</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.id}" ${formData.categoryId eq cat.id.toString() ? 'selected' : ''}>
                                        <c:choose>
                                            <c:when test="${not empty cat.icon}">${fn:escapeXml(cat.icon)} ${fn:escapeXml(cat.categoryName)}</c:when>
                                            <c:otherwise>📋 ${fn:escapeXml(cat.categoryName)}</c:otherwise>
                                        </c:choose>
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="invalid-feedback" id="err-categoryId"></div>
                            <c:if test="${not empty errors.categoryId}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.categoryId}</div>
                            </c:if>
                        </div>
                    </div>

                    <%-- Phòng & Chuyên khoa --%>
                    <div class="form-section-title"><i class="bi bi-geo-alt me-1"></i>Phòng thực hiện &amp; Chuyên khoa</div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-5">
                            <label class="form-label fw-semibold small">Phòng thực hiện</label>
                            <select name="requiredRoomType" id="addRoomType" class="form-select form-select-sm"
                                    onchange="clearFieldError('requiredRoomType')">
                                <option value="">-- Chọn phòng (không bắt buộc) --</option>
                                <optgroup label="Phòng Khám">
                                    <option value="Phòng Khám số 1" ${formData.requiredRoomType eq 'Phòng Khám số 1' ? 'selected' : ''}>🏥 Phòng Khám số 1</option>
                                    <option value="Phòng Khám số 2" ${formData.requiredRoomType eq 'Phòng Khám số 2' ? 'selected' : ''}>🏥 Phòng Khám số 2</option>
                                </optgroup>
                                <optgroup label="Phòng Siêu âm">
                                    <option value="Phòng Siêu âm 1" ${formData.requiredRoomType eq 'Phòng Siêu âm 1' ? 'selected' : ''}>🩻 Phòng Siêu âm 1</option>
                                    <option value="Phòng Siêu âm 2" ${formData.requiredRoomType eq 'Phòng Siêu âm 2' ? 'selected' : ''}>🩻 Phòng Siêu âm 2</option>
                                    <option value="Phòng Siêu âm 3" ${formData.requiredRoomType eq 'Phòng Siêu âm 3' ? 'selected' : ''}>🩻 Phòng Siêu âm 3</option>
                                </optgroup>
                            </select>
                            <div class="invalid-feedback" id="err-requiredRoomType"></div>
                            <c:if test="${not empty errors.requiredRoomType}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.requiredRoomType}</div>
                            </c:if>
                        </div>
                        <div class="col-md-7">
                            <label class="form-label fw-semibold small">Chuyên khoa áp dụng <span class="text-muted">(chọn nhiều)</span></label>
                            <div class="d-flex flex-wrap gap-2" style="padding-top:0.35rem;" id="addSpecialtiesGroup">
                                <div class="form-check form-check-inline">
                                    <input type="checkbox" class="form-check-input specialty-checkbox" id="addSpecSan"
                                           value="Sản khoa" onchange="updateSpecialtiesValue('add')"
                                           ${not empty formData.allowedSpecialties and formData.allowedSpecialties.contains('Sản khoa') ? 'checked' : ''}>
                                    <label class="form-check-label small" for="addSpecSan">Sản khoa</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input type="checkbox" class="form-check-input specialty-checkbox" id="addSpecPhu"
                                           value="Phụ khoa" onchange="updateSpecialtiesValue('add')"
                                           ${not empty formData.allowedSpecialties and formData.allowedSpecialties.contains('Phụ khoa') ? 'checked' : ''}>
                                    <label class="form-check-label small" for="addSpecPhu">Phụ khoa</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input type="checkbox" class="form-check-input specialty-checkbox" id="addSpecCDHA"
                                           value="Chẩn đoán hình ảnh" onchange="updateSpecialtiesValue('add')"
                                           ${not empty formData.allowedSpecialties and formData.allowedSpecialties.contains('Chẩn đoán hình ảnh') ? 'checked' : ''}>
                                    <label class="form-check-label small" for="addSpecCDHA">Chẩn đoán hình ảnh</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input type="checkbox" class="form-check-input specialty-checkbox" id="addSpecKHHGD"
                                           value="Kế hoạch hóa gia đình" onchange="updateSpecialtiesValue('add')"
                                           ${not empty formData.allowedSpecialties and formData.allowedSpecialties.contains('Kế hoạch hóa gia đình') ? 'checked' : ''}>
                                    <label class="form-check-label small" for="addSpecKHHGD">KHHGĐ</label>
                                </div>
                            </div>
                            <input type="hidden" name="allowedSpecialties" id="addSpecialtiesHidden" value="${fn:escapeXml(formData.allowedSpecialties)}">
                            <div class="invalid-feedback d-block" id="err-allowedSpecialties"></div>
                            <c:if test="${not empty errors.allowedSpecialties}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.allowedSpecialties}</div>
                            </c:if>
                        </div>
                    </div>

                    <%-- Yêu cầu đặc biệt --%>
                    <div class="form-section-title"><i class="bi bi-exclamation-diamond me-1"></i>Yêu cầu đặc biệt trước khi thực hiện</div>
                    <div class="row g-3">
                        <div class="col-12">
                            <div class="d-flex gap-4 align-items-center">
                                <div class="form-check">
                                    <input type="checkbox" name="requiresFasting" class="form-check-input" id="createFasting"
                                           ${formData.containsKey('requiresFasting') ? 'checked' : ''}>
                                    <label class="form-check-label small fw-semibold" for="createFasting">
                                        🍽️ Nhịn ăn trước khi thực hiện
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input type="checkbox" name="requiresFullBladder" class="form-check-input" id="createBladder"
                                           ${formData.containsKey('requiresFullBladder') ? 'checked' : ''}>
                                    <label class="form-check-label small fw-semibold" for="createBladder">
                                        💧 Đầy bàng quang trước khi thực hiện
                                    </label>
                                </div>
                                <div style="font-size:0.68rem;color:var(--c-muted);">
                                    <i class="bi bi-info-circle"></i> Thông tin này sẽ hiển thị cho bệnh nhân khi đặt lịch
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Hủy
                    </button>
                    <button type="submit" class="btn btn-primary-pink btn-sm">
                        <i class="bi bi-check-lg me-1"></i>Tạo Dịch Vụ
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: SUA DICH VU
     ============================================================ --%>
<div class="modal fade" id="editServiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="bi bi-pencil-square me-2"></i>Chỉnh Sửa Dịch Vụ
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/manager/services/"
                  id="editServiceForm" novalidate onsubmit="return validateEditService()">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="editServiceId">
                <div class="modal-body">
                    <!-- Server-side general error -->
                    <c:if test="${not empty errors.general}">
                        <div class="alert alert-danger d-flex align-items-center gap-2 mb-3" style="font-size:0.8rem;padding:0.5rem 0.75rem;border-radius:var(--r-sm);">
                            <i class="bi bi-exclamation-triangle-fill"></i>${errors.general}
                        </div>
                    </c:if>

                    <div class="form-section-title"><i class="bi bi-info-circle me-1"></i>Thông tin cơ bản</div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small">Mã dịch vụ 🔒</label>
                            <input type="text" id="editServiceCode"
                                   class="form-control form-control-sm text-uppercase" readonly disabled
                                   style="font-family:'Courier New',monospace;letter-spacing:0.05em;background:#f5f5f5;color:#757575;cursor:not-allowed;">
                            <div class="form-text" style="font-size:0.68rem;">
                                <i class="bi bi-lock-fill"></i> Mã định danh — không thể thay đổi sau khi tạo
                            </div>
                        </div>
                        <div class="col-md-8">
                            <label class="form-label fw-semibold small">Tên dịch vụ <span class="text-danger">*</span></label>
                            <input type="text" name="serviceName" id="editServiceName"
                                   class="form-control form-control-sm" required
                                   minlength="2" maxlength="100">
                            <div class="invalid-feedback" id="editErr-serviceName"></div>
                            <c:if test="${not empty errors.serviceName}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.serviceName}</div>
                            </c:if>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small">Mô tả</label>
                            <textarea name="description" id="editDescription"
                                      class="form-control form-control-sm" rows="2" maxlength="500"></textarea>
                            <div class="invalid-feedback d-block" id="editErr-description"></div>
                            <c:if test="${not empty errors.description}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.description}</div>
                            </c:if>
                        </div>
                    </div>

                    <div class="form-section-title"><i class="bi bi-cash-coin me-1"></i>Giá &amp; Thời gian &amp; Nhóm</div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small">Đơn giá (VNĐ) <span class="text-danger">*</span></label>
                            <div class="input-group input-group-sm">
                                <span class="input-group-text fw-bold">₫</span>
                                <input type="text" name="price" id="editPrice"
                                       class="form-control" required
                                       placeholder="VD: 500000"
                                       oninput="formatPriceInput(this)"
                                       onkeypress="return onlyDigits(event)"
                                       autocomplete="off">
                            </div>
                            <div class="invalid-feedback" id="editErr-price"></div>
                            <div class="form-text" style="font-size:0.68rem;">Số nguyên dương, từ 50.000đ đến 100.000.000đ</div>
                            <c:if test="${not empty errors.price}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.price}</div>
                            </c:if>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Thời gian (phút) <span class="text-danger">*</span></label>
                            <input type="text" name="durationMins" id="editDurationMins"
                                   class="form-control form-control-sm" required
                                   list="durationSuggestions"
                                   onkeypress="return onlyDigits(event)"
                                   autocomplete="off">
                            <div class="invalid-feedback" id="editErr-durationMins"></div>
                            <div class="form-text" style="font-size:0.68rem;">Tối thiểu 5 phút, tối đa 480 phút</div>
                            <c:if test="${not empty errors.durationMins}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.durationMins}</div>
                            </c:if>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label fw-semibold small">Nhóm dịch vụ <span class="text-danger">*</span></label>
                            <select name="categoryId" id="editCategoryId" class="form-select form-select-sm" required>
                                <option value="">-- Chọn nhóm dịch vụ --</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.id}">${fn:escapeXml(cat.categoryName)}</option>
                                </c:forEach>
                            </select>
                            <div class="invalid-feedback" id="editErr-categoryId"></div>
                            <c:if test="${not empty errors.categoryId}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.categoryId}</div>
                            </c:if>
                        </div>
                    </div>

                    <div class="form-section-title"><i class="bi bi-geo-alt me-1"></i>Phòng &amp; Chuyên khoa &amp; Trạng thái</div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small">Phòng thực hiện</label>
                            <select name="requiredRoomType" id="editRoomType" class="form-select form-select-sm">
                                <option value="">-- Chọn phòng --</option>
                                <optgroup label="Phòng Khám">
                                    <option value="Phòng Khám số 1">🏥 Phòng Khám số 1</option>
                                    <option value="Phòng Khám số 2">🏥 Phòng Khám số 2</option>
                                </optgroup>
                                <optgroup label="Phòng Siêu âm">
                                    <option value="Phòng Siêu âm 1">🩻 Phòng Siêu âm 1</option>
                                    <option value="Phòng Siêu âm 2">🩻 Phòng Siêu âm 2</option>
                                    <option value="Phòng Siêu âm 3">🩻 Phòng Siêu âm 3</option>
                                </optgroup>
                            </select>
                            <div class="invalid-feedback" id="editErr-requiredRoomType"></div>
                            <c:if test="${not empty errors.requiredRoomType}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.requiredRoomType}</div>
                            </c:if>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label fw-semibold small">Chuyên khoa <span class="text-muted">(chọn nhiều)</span></label>
                            <div class="d-flex flex-wrap gap-2" style="padding-top:0.35rem;" id="editSpecialtiesGroup">
                                <div class="form-check form-check-inline">
                                    <input type="checkbox" class="form-check-input specialty-checkbox" id="editSpecSan"
                                           value="Sản khoa" onchange="updateSpecialtiesValue('edit')">
                                    <label class="form-check-label small" for="editSpecSan">Sản khoa</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input type="checkbox" class="form-check-input specialty-checkbox" id="editSpecPhu"
                                           value="Phụ khoa" onchange="updateSpecialtiesValue('edit')">
                                    <label class="form-check-label small" for="editSpecPhu">Phụ khoa</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input type="checkbox" class="form-check-input specialty-checkbox" id="editSpecCDHA"
                                           value="Chẩn đoán hình ảnh" onchange="updateSpecialtiesValue('edit')">
                                    <label class="form-check-label small" for="editSpecCDHA">Chẩn đoán hình ảnh</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input type="checkbox" class="form-check-input specialty-checkbox" id="editSpecKHHGD"
                                           value="Kế hoạch hóa gia đình" onchange="updateSpecialtiesValue('edit')">
                                    <label class="form-check-label small" for="editSpecKHHGD">KHHGĐ</label>
                                </div>
                            </div>
                            <input type="hidden" name="allowedSpecialties" id="editSpecialtiesHidden" value="">
                            <div class="invalid-feedback d-block" id="editErr-allowedSpecialties"></div>
                            <c:if test="${not empty errors.allowedSpecialties}">
                                <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.allowedSpecialties}</div>
                            </c:if>
                        </div>
                        <div class="col-md-3 d-flex flex-column gap-2">
                            <div class="form-check">
                                <input type="checkbox" name="isActive" class="form-check-input" id="editIsActive">
                                <label class="form-check-label small fw-semibold" for="editIsActive">🟢 Hoạt động</label>
                            </div>
                            <div class="form-check">
                                <input type="checkbox" name="requiresFasting" class="form-check-input" id="editFasting">
                                <label class="form-check-label small" for="editFasting">🍽️ Nhịn ăn</label>
                            </div>
                            <div class="form-check">
                                <input type="checkbox" name="requiresFullBladder" class="form-check-input" id="editBladder">
                                <label class="form-check-label small" for="editBladder">💧 Đầy bàng quang</label>
                            </div>
                        </div>
                    </div>

                    <%-- Lý do thay đổi giá --%>
                    <div class="alert alert-info alert-sm d-flex align-items-center gap-2 mb-0" style="font-size:0.78rem; padding:0.5rem 0.75rem; border-radius:var(--r-sm);">
                        <i class="bi bi-info-circle-fill"></i>
                        <div>Nếu bạn thay đổi giá, hệ thống sẽ tự động ghi nhận vào lịch sử điều chỉnh giá.</div>
                    </div>
                    <div class="mt-2">
                        <label class="form-label fw-semibold small">Lý do thay đổi giá <span class="text-muted">(nếu có)</span></label>
                        <input type="text" name="changeReason" id="editChangeReason"
                               class="form-control form-control-sm" maxlength="500"
                               placeholder="VD: Điều chỉnh theo chính sách giá mới của phòng khám">
                        <c:if test="${not empty errors.changeReason}">
                            <div class="text-danger mt-1" style="font-size:0.72rem;"><i class="bi bi-exclamation-circle me-1"></i>${errors.changeReason}</div>
                        </c:if>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Hủy
                    </button>
                    <button type="submit" class="btn btn-primary-pink btn-sm">
                        <i class="bi bi-check-lg me-1"></i>Lưu Thay Đổi
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ===== SCRIPTS ===== --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });

// Active sidebar link
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        if (links[i].href && links[i].href.indexOf('/manager/services') !== -1) {
            links[i].classList.add('active');
        }
    }
})();

// ──────────────────────────────────────────────
//  Utility Functions
// ──────────────────────────────────────────────

/** Định dạng số tiền VNĐ */
function formatVND(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount);
}

/** Chỉ cho phép nhập chữ số (dùng onkeypress) */
function onlyDigits(event) {
    var charCode = event.which ? event.which : event.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) return false;
    return true;
}

/** Auto-format giá tiền khi nhập */
function formatPriceInput(el) {
    var raw = el.value.replace(/[^0-9]/g, '');
    if (raw) {
        el.value = parseInt(raw, 10).toLocaleString('vi-VN');
    }
}

/** Lấy giá trị số nguyên từ input đã format */
function getPriceRaw(el) {
    return parseInt(el.value.replace(/[^0-9]/g, ''), 10) || 0;
}

/** Xoá lỗi field khi user sửa */
function clearFieldError(fieldName) {
    var el = document.getElementById('add' + fieldName.charAt(0).toUpperCase() + fieldName.slice(1));
    if (el) el.classList.remove('is-invalid');
    var errEl = document.getElementById('err-' + fieldName);
    if (errEl) errEl.textContent = '';
}

/** Cập nhật bộ đếm ký tự */
function updateCharCount(textareaId, counterId, maxLen) {
    var ta = document.getElementById(textareaId);
    var counter = document.getElementById(counterId);
    if (ta && counter) {
        var len = ta.value.length;
        counter.textContent = len + '/' + maxLen;
        counter.style.color = len > maxLen ? '#c62828' : '';
    }
}

/** Gộp giá trị các checkbox chuyên khoa thành chuỗi, lưu vào hidden input */
function updateSpecialtiesValue(prefix) {
    var checkboxes = document.querySelectorAll('#' + prefix + 'SpecialtiesGroup input[type="checkbox"]');
    var values = [];
    for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked) values.push(checkboxes[i].value);
    }
    var hidden = document.getElementById(prefix + 'SpecialtiesHidden');
    if (hidden) hidden.value = values.join(', ');
}

/** Set trạng thái checkbox chuyên khoa từ chuỗi */
function setSpecialtiesFromString(prefix, str) {
    if (!str) return;
    var values = str.split(',').map(function(v) { return v.trim(); });
    var checkboxes = document.querySelectorAll('#' + prefix + 'SpecialtiesGroup input[type="checkbox"]');
    for (var i = 0; i < checkboxes.length; i++) {
        checkboxes[i].checked = values.indexOf(checkboxes[i].value) >= 0;
    }
    updateSpecialtiesValue(prefix);
}

function showFieldError(inputEl, errEl, message) {
    if (inputEl) inputEl.classList.add('is-invalid');
    if (errEl) errEl.textContent = message;
}

function clearOneError(inputEl, errEl) {
    if (inputEl) inputEl.classList.remove('is-invalid');
    if (errEl) errEl.textContent = '';
}

// ──────────────────────────────────────────────
//  Validate Form Thêm Dịch Vụ (client-side)
// ──────────────────────────────────────────────
function validateAddService() {
    var valid = true;
    var ONLY_DIGITS = /^\d+$/;
    var ONLY_SPECIAL = /^[\s!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?`~]+$/;
    var CODEMAX = 30;

    // ── Mã dịch vụ (3-30, chữ hoa, số, gạch ngang, gạch dưới) ──
    var codeEl = document.getElementById('addServiceCode');
    var codeErr = document.getElementById('err-serviceCode');
    var code = (codeEl.value || '').trim();
    var codeRegex = new RegExp('^[A-Z0-9][A-Z0-9_\\-]{2,' + (CODEMAX - 1) + '}$');
    if (!code) {
        showFieldError(codeEl, codeErr, 'Mã dịch vụ không được để trống.');
        valid = false;
    } else if (code.indexOf(' ') >= 0) {
        showFieldError(codeEl, codeErr, 'Mã dịch vụ không được chứa khoảng trắng.');
        valid = false;
    } else if (code.length < 3) {
        showFieldError(codeEl, codeErr, 'Mã dịch vụ phải có ít nhất 3 ký tự.');
        valid = false;
    } else if (code.length > CODEMAX) {
        showFieldError(codeEl, codeErr, 'Mã dịch vụ không được vượt quá ' + CODEMAX + ' ký tự.');
        valid = false;
    } else if (!codeRegex.test(code)) {
        showFieldError(codeEl, codeErr, 'Mã dịch vụ chỉ được chứa chữ IN HOA, số, gạch ngang (-) và gạch dưới (_).');
        valid = false;
    } else {
        clearOneError(codeEl, codeErr);
    }

    // ── Tên dịch vụ (2-100, không được chỉ gồm số hoặc KTB) ──
    var nameEl = document.getElementById('addServiceName');
    var nameErr = document.getElementById('err-serviceName');
    var name = (nameEl.value || '').trim();
    if (!name) {
        showFieldError(nameEl, nameErr, 'Tên dịch vụ không được để trống.');
        valid = false;
    } else if (name.length < 2) {
        showFieldError(nameEl, nameErr, 'Tên dịch vụ phải có ít nhất 2 ký tự.');
        valid = false;
    } else if (name.length > 100) {
        showFieldError(nameEl, nameErr, 'Tên dịch vụ không được vượt quá 100 ký tự.');
        valid = false;
    } else if (ONLY_DIGITS.test(name)) {
        showFieldError(nameEl, nameErr, 'Tên dịch vụ không được chỉ bao gồm chữ số.');
        valid = false;
    } else if (ONLY_SPECIAL.test(name)) {
        showFieldError(nameEl, nameErr, 'Tên dịch vụ không được chỉ bao gồm ký tự đặc biệt.');
        valid = false;
    } else {
        clearOneError(nameEl, nameErr);
    }

    // ── Nhóm dịch vụ (bắt buộc) ──
    var catEl = document.getElementById('addCategoryId');
    var catErr = document.getElementById('err-categoryId');
    if (!catEl.value) {
        showFieldError(catEl, catErr, 'Vui lòng chọn nhóm dịch vụ.');
        valid = false;
    } else {
        clearOneError(catEl, catErr);
    }

    // ── Đơn giá (bắt buộc, số nguyên, 50k-100tr) ──
    var priceEl = document.getElementById('addPrice');
    var priceErr = document.getElementById('err-price');
    var priceVal = getPriceRaw(priceEl);
    if (!priceEl.value.trim()) {
        showFieldError(priceEl, priceErr, 'Đơn giá không được để trống.');
        valid = false;
    } else if (isNaN(priceVal) || priceVal <= 0) {
        showFieldError(priceEl, priceErr, 'Đơn giá không hợp lệ. Vui lòng chỉ nhập số nguyên dương.');
        valid = false;
    } else if (priceVal < 50000) {
        showFieldError(priceEl, priceErr, 'Đơn giá phải lớn hơn hoặc bằng ' + formatVND(50000) + ' VNĐ.');
        valid = false;
    } else if (priceVal > 100000000) {
        showFieldError(priceEl, priceErr, 'Đơn giá không được vượt quá ' + formatVND(100000000) + ' VNĐ.');
        valid = false;
    } else {
        clearOneError(priceEl, priceErr);
    }

    // ── Thời gian (bắt buộc, 5-480 phút) ──
    var durEl = document.getElementById('addDurationMins');
    var durErr = document.getElementById('err-durationMins');
    var durVal = (durEl.value || '').trim();
    if (!durVal) {
        showFieldError(durEl, durErr, 'Thời gian thực hiện không được để trống.');
        valid = false;
    } else {
        var durNum = parseInt(durVal, 10);
        if (isNaN(durNum)) {
            showFieldError(durEl, durErr, 'Thời gian không hợp lệ. Vui lòng nhập số nguyên (VD: 30).');
            valid = false;
        } else if (durNum < 5) {
            showFieldError(durEl, durErr, 'Thời gian thực hiện tối thiểu là 5 phút.');
            valid = false;
        } else if (durNum > 480) {
            showFieldError(durEl, durErr, 'Thời gian thực hiện không được vượt quá 480 phút (8 giờ).');
            valid = false;
        } else {
            clearOneError(durEl, durErr);
        }
    }

    // ── Mô tả (optional, max 500) ──
    var descEl = document.getElementById('addDescription');
    var descErr = document.getElementById('err-description');
    if (descEl && descEl.value.length > 500) {
        showFieldError(descEl, descErr, 'Mô tả không được vượt quá 500 ký tự.');
        valid = false;
    } else {
        clearOneError(descEl, descErr);
    }

    // ── Chuyên khoa (optional) ──
    updateSpecialtiesValue('add');
    var specHidden = document.getElementById('addSpecialtiesHidden');
    var specErr = document.getElementById('err-allowedSpecialties');
    if (specHidden && specHidden.value.length > 255) {
        showFieldError(specHidden, specErr, 'Chuyên khoa áp dụng không được vượt quá 255 ký tự.');
        valid = false;
    } else {
        clearOneError(specHidden, specErr);
    }

    if (!valid) {
        var firstError = document.querySelector('#addServiceForm .is-invalid');
        if (firstError) firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
    } else {
        // Chuẩn hóa giá về số nguyên trước khi submit (bỏ định dạng .000)
        var addPriceEl = document.getElementById('addPrice');
        if (addPriceEl) addPriceEl.value = getPriceRaw(addPriceEl);
    }

    return valid;
}

// ──────────────────────────────────────────────
//  Validate Form Sửa Dịch Vụ (client-side)
// ──────────────────────────────────────────────
function validateEditService() {
    var valid = true;
    var ONLY_DIGITS = /^\d+$/;
    var ONLY_SPECIAL = /^[\s!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?`~]+$/;

    // ── Tên dịch vụ ──
    var nameEl = document.getElementById('editServiceName');
    var nameErr = document.getElementById('editErr-serviceName');
    var name = (nameEl.value || '').trim();
    if (!name) {
        showFieldError(nameEl, nameErr, 'Tên dịch vụ không được để trống.');
        valid = false;
    } else if (name.length < 2) {
        showFieldError(nameEl, nameErr, 'Tên dịch vụ phải có ít nhất 2 ký tự.');
        valid = false;
    } else if (name.length > 100) {
        showFieldError(nameEl, nameErr, 'Tên dịch vụ không được vượt quá 100 ký tự.');
        valid = false;
    } else if (ONLY_DIGITS.test(name)) {
        showFieldError(nameEl, nameErr, 'Tên dịch vụ không được chỉ bao gồm chữ số.');
        valid = false;
    } else if (ONLY_SPECIAL.test(name)) {
        showFieldError(nameEl, nameErr, 'Tên dịch vụ không được chỉ bao gồm ký tự đặc biệt.');
        valid = false;
    } else {
        clearOneError(nameEl, nameErr);
    }

    // ── Nhóm dịch vụ (bắt buộc) ──
    var catEl = document.getElementById('editCategoryId');
    var catErr = document.getElementById('editErr-categoryId');
    if (!catEl.value) {
        showFieldError(catEl, catErr, 'Vui lòng chọn nhóm dịch vụ.');
        valid = false;
    } else {
        clearOneError(catEl, catErr);
    }

    // ── Đơn giá ──
    var priceEl = document.getElementById('editPrice');
    var priceErr = document.getElementById('editErr-price');
    var priceVal = getPriceRaw(priceEl);
    if (!priceEl.value.trim()) {
        showFieldError(priceEl, priceErr, 'Đơn giá không được để trống.');
        valid = false;
    } else if (isNaN(priceVal) || priceVal <= 0) {
        showFieldError(priceEl, priceErr, 'Đơn giá không hợp lệ. Vui lòng chỉ nhập số nguyên dương.');
        valid = false;
    } else if (priceVal < 50000) {
        showFieldError(priceEl, priceErr, 'Đơn giá phải lớn hơn hoặc bằng ' + formatVND(50000) + ' VNĐ.');
        valid = false;
    } else if (priceVal > 100000000) {
        showFieldError(priceEl, priceErr, 'Đơn giá không được vượt quá ' + formatVND(100000000) + ' VNĐ.');
        valid = false;
    } else {
        clearOneError(priceEl, priceErr);
    }

    // ── Thời gian (bắt buộc, 5-480) ──
    var durEl = document.getElementById('editDurationMins');
    var durErr = document.getElementById('editErr-durationMins');
    var durVal = (durEl.value || '').trim();
    if (!durVal) {
        showFieldError(durEl, durErr, 'Thời gian thực hiện không được để trống.');
        valid = false;
    } else {
        var durNum = parseInt(durVal, 10);
        if (isNaN(durNum)) {
            showFieldError(durEl, durErr, 'Thời gian không hợp lệ. Vui lòng nhập số nguyên.');
            valid = false;
        } else if (durNum < 5) {
            showFieldError(durEl, durErr, 'Thời gian thực hiện tối thiểu là 5 phút.');
            valid = false;
        } else if (durNum > 480) {
            showFieldError(durEl, durErr, 'Thời gian thực hiện không được vượt quá 480 phút (8 giờ).');
            valid = false;
        } else {
            clearOneError(durEl, durErr);
        }
    }

    // ── Mô tả ──
    var descEl = document.getElementById('editDescription');
    var descErr = document.getElementById('editErr-description');
    if (descEl && descEl.value.length > 500) {
        showFieldError(descEl, descErr, 'Mô tả không được vượt quá 500 ký tự.');
        valid = false;
    } else {
        clearOneError(descEl, descErr);
    }

    // ── Chuyên khoa ──
    updateSpecialtiesValue('edit');
    var specHidden = document.getElementById('editSpecialtiesHidden');
    var specErr = document.getElementById('editErr-allowedSpecialties');
    if (specHidden && specHidden.value.length > 255) {
        showFieldError(specHidden, specErr, 'Chuyên khoa áp dụng không được vượt quá 255 ký tự.');
        valid = false;
    } else {
        clearOneError(specHidden, specErr);
    }

    if (!valid) {
        var firstError = document.querySelector('#editServiceForm .is-invalid');
        if (firstError) firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
    } else {
        // Chuẩn hóa giá về số nguyên trước khi submit (bỏ định dạng .000)
        var editPriceEl = document.getElementById('editPrice');
        if (editPriceEl) editPriceEl.value = getPriceRaw(editPriceEl);
    }

    return valid;
}

// ──────────────────────────────────────────────
//  Modal Events
// ──────────────────────────────────────────────
(function() {
    var addModal = document.getElementById('addServiceModal');
    if (addModal) {
        addModal.addEventListener('shown.bs.modal', function() {
            updateCharCount('addDescription', 'descCount', 500);
            var form = document.getElementById('addServiceForm');
            if (form) {
                var invalids = form.querySelectorAll('.is-invalid');
                for (var i = 0; i < invalids.length; i++) invalids[i].classList.remove('is-invalid');
                var errDivs = form.querySelectorAll('.invalid-feedback');
                for (var j = 0; j < errDivs.length; j++) errDivs[j].textContent = '';
            }
        });
    }

    var editModal = document.getElementById('editServiceModal');
    if (editModal) {
        editModal.addEventListener('shown.bs.modal', function() {
            var form = document.getElementById('editServiceForm');
            if (form) {
                var invalids = form.querySelectorAll('.is-invalid');
                for (var i = 0; i < invalids.length; i++) invalids[i].classList.remove('is-invalid');
            }
        });
    }
})();

// ──────────────────────────────────────────────
//  Open Edit Modal (updated: room dropdown + specialties checkboxes)
// ──────────────────────────────────────────────
function openEditModal(id, code, name, desc, price, duration, fasting, bladder, room, specialties, catId, isActive) {
    document.getElementById('editServiceId').value = id;
    // Mã dịch vụ: readonly, hiển thị nhưng không cho sửa
    document.getElementById('editServiceCode').value = code || '';
    document.getElementById('editServiceName').value = name || '';
    document.getElementById('editDescription').value = desc || '';
    // Đơn giá: hiển thị có format
    var priceEl = document.getElementById('editPrice');
    priceEl.value = price ? parseInt(price, 10).toLocaleString('vi-VN') : '';
    document.getElementById('editDurationMins').value = duration || '';
    document.getElementById('editChangeReason').value = '';

    // Phòng thực hiện: set dropdown
    var roomSelect = document.getElementById('editRoomType');
    if (roomSelect && room) {
        for (var i = 0; i < roomSelect.options.length; i++) {
            if (roomSelect.options[i].value === room) {
                roomSelect.options[i].selected = true;
                break;
            }
        }
    }

    // Chuyên khoa: set checkboxes
    setSpecialtiesFromString('edit', specialties || '');

    // Nhóm dịch vụ
    var catSelect = document.getElementById('editCategoryId');
    if (catSelect && catId) {
        for (var k = 0; k < catSelect.options.length; k++) {
            if (catSelect.options[k].value === catId) {
                catSelect.options[k].selected = true;
                break;
            }
        }
    }

    document.getElementById('editFasting').checked = fasting === 'true';
    document.getElementById('editBladder').checked = bladder === 'true';
    document.getElementById('editIsActive').checked = isActive === 'true';
    new bootstrap.Modal(document.getElementById('editServiceModal')).show();
}

// Auto-open modals on validation fail
<c:if test="${showCreateModal}">
    new bootstrap.Modal(document.getElementById('addServiceModal')).show();
</c:if>
<c:if test="${showEditModal}">
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('editServiceId').value = '${editServiceId}';
        document.getElementById('editServiceCode').value = '${fn:escapeXml(formData.serviceCode)}';
        document.getElementById('editServiceName').value = '${fn:escapeXml(formData.serviceName)}';
        document.getElementById('editDescription').value = '${fn:escapeXml(formData.description)}';
        // Format giá
        var priceVal = '${formData.price}';
        document.getElementById('editPrice').value = priceVal ? parseInt(priceVal, 10).toLocaleString('vi-VN') : '';
        document.getElementById('editDurationMins').value = '${formData.durationMins}';
        document.getElementById('editChangeReason').value = '${fn:escapeXml(formData.changeReason)}';
        // Phòng: set dropdown
        var roomVal = '${fn:escapeXml(formData.requiredRoomType)}';
        var roomSelect = document.getElementById('editRoomType');
        if (roomSelect && roomVal) {
            for (var r = 0; r < roomSelect.options.length; r++) {
                if (roomSelect.options[r].value === roomVal) {
                    roomSelect.options[r].selected = true;
                    break;
                }
            }
        }
        // Chuyên khoa: set checkboxes
        setSpecialtiesFromString('edit', '${fn:escapeXml(formData.allowedSpecialties)}');
        // Nhóm
        var catSel = document.getElementById('editCategoryId');
        if (catSel && '${formData.categoryId}') {
            for (var i = 0; i < catSel.options.length; i++) {
                if (catSel.options[i].value === '${formData.categoryId}') {
                    catSel.options[i].selected = true;
                    break;
                }
            }
        }
        new bootstrap.Modal(document.getElementById('editServiceModal')).show();
    });
</c:if>
</script>

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
