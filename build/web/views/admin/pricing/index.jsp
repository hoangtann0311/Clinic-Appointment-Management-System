<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Biểu Giá — CAMS Admin</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <style>
        :root {
            --sidebar-w: 270px; --topbar-h: 66px;
            --pink-50: #fff0f6; --pink-100: #ffe0ef; --pink-200: #ffb3d1; --pink-300: #ff80b3;
            --pink-400: #ff4d94; --pink-500: #e91e8c; --pink-600: #c2185b; --pink-700: #9c0f4a;
            --pink-800: #7b0a39; --rose-400: #fb7185; --rose-500: #f43f5e; --rose-600: #e11d48;
            --c-bg: #fff5f9; --c-surface: #ffffff; --c-surface-variant: #fff0f5;
            --c-surface-container: #fce8f0; --c-primary: #c2185b; --c-primary-light: #ff4d94;
            --c-primary-dark: #9c0f4a; --c-primary-container: #ffe0ef; --c-on-bg: #1f1117;
            --c-on-surface: #2d1a25; --c-on-surface-var: #5a3d4e; --c-muted: #8a6070;
            --c-outline: #e8c5d5; --c-outline-variant: #f5dfe9;
            --c-success: #2e7d32; --c-danger: #c62828; --c-warning: #f57f17; --c-info: #0e7490;
            --sb-bg: #1a0a12; --sb-bg-mid: #2d1020; --sb-bg-deep: #0f0509;
            --sb-hover: #3d1830; --sb-active-bg: rgba(233,30,140,0.18);
            --sb-active-border: #e91e8c; --sb-text: #f0d5e3; --sb-text-muted: #a07085;
            --sb-border: rgba(255,255,255,0.07); --sb-accent: #ff80b3;
            --shadow-xs: 0 1px 3px rgba(194,24,91,0.07);
            --shadow-sm: 0 2px 8px rgba(194,24,91,0.10);
            --shadow-md: 0 4px 20px rgba(194,24,91,0.13);
            --shadow-lg: 0 8px 32px rgba(194,24,91,0.16);
            --r-sm: 8px; --r-md: 12px; --r-lg: 16px; --r-xl: 20px; --r-pill: 999px;
            --t-fast: 0.15s ease; --t-smooth: 0.25s cubic-bezier(0.4,0,0.2,1);
            --font-display: 'Nunito', sans-serif;
            --font-body: 'Inter', sans-serif;
        }
        *, *::before, *::after { box-sizing: border-box; }
        body, .btn, .form-control, .table, .badge, .card { font-family: var(--font-body); }
        h1,h2,h3,h4,h5,h6 { font-family: var(--font-display); }
        body.admin-body { font-family: var(--font-body); background: var(--c-bg); color: var(--c-on-bg); margin: 0; padding: 0; line-height: 1.6; -webkit-font-smoothing: antialiased; }

        /* ── TOP BAR ── */
        .admin-topbar { position: fixed; top: 0; left: 0; right: 0; height: var(--topbar-h); background: var(--c-surface); border-bottom: 2px solid var(--pink-200); display: flex; align-items: center; justify-content: space-between; padding: 0 1.5rem; z-index: 1030; box-shadow: var(--shadow-xs); }
        .admin-topbar-left { display: flex; align-items: center; gap: 0.875rem; }
        .admin-topbar-brand { font-family: var(--font-display); font-weight: 900; font-size: 1.3rem; color: var(--c-primary); text-decoration: none; display: flex; align-items: center; gap: 0.5rem; letter-spacing: -0.03em; }
        .admin-topbar-brand i { color: var(--pink-500); font-size: 1.5rem; filter: drop-shadow(0 0 6px rgba(233,30,140,0.4)); }
        .admin-topbar-brand .brand-badge { font-family: var(--font-body); font-weight: 700; font-size: 0.65rem; color: var(--c-primary); background: var(--pink-100); padding: 3px 10px; border-radius: var(--r-pill); letter-spacing: 0.06em; text-transform: uppercase; border: 1px solid var(--pink-200); }
        .admin-sidebar-toggle { background: none; border: none; color: var(--c-on-surface-var); font-size: 1.5rem; cursor: pointer; padding: 6px 8px; border-radius: var(--r-sm); display: none; line-height: 1; }
        .admin-sidebar-toggle:hover { background: var(--pink-100); color: var(--c-primary); }
        .admin-topbar-right { display: flex; align-items: center; gap: 0.75rem; }
        .admin-topbar-user { display: flex; align-items: center; gap: 0.6rem; padding: 0.375rem 0.875rem; background: var(--pink-50); border-radius: var(--r-pill); border: 1px solid var(--pink-200); }
        .admin-topbar-user span { font-size: 0.875rem; font-weight: 600; color: var(--c-primary-dark); }
        .admin-avatar-sm { width: 34px; height: 34px; border-radius: 50%; background: linear-gradient(135deg, var(--pink-500), var(--rose-400)); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.85rem; text-transform: uppercase; flex-shrink: 0; box-shadow: 0 2px 8px rgba(233,30,140,0.35); }
        .admin-topbar-role { font-size: 0.62rem; font-weight: 700; padding: 2px 8px; border-radius: var(--r-pill); background: linear-gradient(135deg, var(--pink-500), var(--rose-500)); color: #fff; letter-spacing: 0.05em; text-transform: uppercase; }
        .admin-topbar-logout { color: var(--c-on-surface-var); text-decoration: none; font-size: 0.85rem; font-weight: 600; display: flex; align-items: center; gap: 0.4rem; padding: 0.45rem 0.875rem; border-radius: var(--r-sm); transition: all var(--t-fast); border: 1px solid transparent; }
        .admin-topbar-logout:hover { background: var(--pink-50); color: var(--rose-600); border-color: var(--pink-200); }

        /* ── MAIN ── */
        .admin-main { margin-left: var(--sidebar-w); margin-top: var(--topbar-h); padding: 2rem 2.25rem; min-height: calc(100vh - var(--topbar-h)); }
        .admin-page-header { display: flex; align-items: flex-start; justify-content: space-between; flex-wrap: wrap; gap: 1rem; margin-bottom: 1.5rem; }
        .admin-page-title { font-family: var(--font-display); font-size: 1.85rem; font-weight: 900; color: var(--c-on-bg); margin: 0 0 0.25rem; letter-spacing: -0.04em; }
        .admin-page-subtitle { font-size: 0.85rem; color: var(--c-muted); display: flex; align-items: center; gap: 0.4rem; }

        /* ── STATS CARDS ── */
        .stats-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 1.5rem; }
        .stat-card { background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-lg); padding: 1.25rem 1.25rem; display: flex; align-items: center; gap: 1rem; box-shadow: var(--shadow-xs); transition: all var(--t-smooth); cursor: default; position: relative; overflow: hidden; }
        .stat-card:hover { box-shadow: var(--shadow-md); transform: translateY(-2px); border-color: var(--pink-200); }
        .stat-card::after { content: ''; position: absolute; top: -20px; right: -20px; width: 80px; height: 80px; border-radius: 50%; opacity: 0.06; transition: all var(--t-smooth); }
        .stat-card:hover::after { transform: scale(1.2); opacity: 0.10; }
        .stat-card-icon { width: 52px; height: 52px; border-radius: var(--r-md); display: flex; align-items: center; justify-content: center; font-size: 1.4rem; flex-shrink: 0; color: #fff; }
        .sc-icon-service { background: linear-gradient(135deg, var(--pink-500), var(--rose-400)); }
        .sc-icon-medicine { background: linear-gradient(135deg, #6366f1, #4f46e5); }
        .sc-icon-money { background: linear-gradient(135deg, #10b981, #059669); }
        .stat-card-body { flex: 1; min-width: 0; }
        .stat-card-label { font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.07em; color: var(--c-muted); margin-bottom: 0.25rem; }
        .stat-card-value { font-family: var(--font-display); font-size: 1.7rem; font-weight: 900; color: var(--c-on-bg); line-height: 1; }
        .stat-card-sub { font-size: 0.72rem; color: var(--c-muted); margin-top: 0.2rem; }

        /* ── TABS ── */
        .pricing-tabs { display: flex; gap: 0; background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-lg); overflow: hidden; margin-bottom: 1.5rem; box-shadow: var(--shadow-xs); }
        .pricing-tab { flex: 1; text-align: center; padding: 1rem 1.5rem; font-weight: 700; font-size: 0.9rem; color: var(--c-on-surface-var); text-decoration: none; transition: all var(--t-smooth); border-bottom: 3px solid transparent; background: var(--c-surface); display: flex; align-items: center; justify-content: center; gap: 0.5rem; cursor: pointer; }
        .pricing-tab:hover { background: var(--pink-50); color: var(--c-primary); }
        .pricing-tab.active { background: linear-gradient(180deg, var(--pink-50) 0%, var(--c-surface) 100%); color: var(--c-primary-dark); border-bottom-color: var(--pink-500); font-weight: 800; }
        .pricing-tab .tab-icon { font-size: 1.2rem; }
        .pricing-tab .tab-count { font-size: 0.7rem; font-weight: 600; padding: 2px 8px; border-radius: var(--r-pill); background: var(--pink-100); color: var(--pink-700); }
        .pricing-tab.active .tab-count { background: var(--pink-500); color: #fff; }

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
        .badge-boolean-true { display: inline-block; padding: 2px 8px; border-radius: var(--r-pill); font-size: 0.65rem; font-weight: 700; background: #e8f5e9; color: #2e7d32; }
        .badge-boolean-false { display: inline-block; padding: 2px 8px; border-radius: var(--r-pill); font-size: 0.65rem; font-weight: 700; background: #f5f5f5; color: #757575; }
        .badge-active { display: inline-block; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.72rem; font-weight: 700; background: #e8f5e9; color: #2e7d32; }
        .badge-inactive { display: inline-block; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.72rem; font-weight: 700; background: #f5f5f5; color: #757575; }

        /* ── Buttons ── */
        .btn-primary-pink { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); color: #fff; border: none; font-weight: 700; border-radius: var(--r-sm); padding: 0.55rem 1.2rem; transition: all var(--t-fast); }
        .btn-primary-pink:hover { background: linear-gradient(135deg, var(--pink-600), var(--pink-700)); color: #fff; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(233,30,140,0.3); }
        .btn-action { display: inline-flex; align-items: center; gap: 0.25rem; }

        /* ── Price Display ── */
        .price-display { font-family: var(--font-display); font-weight: 800; font-size: 1.05rem; color: var(--c-primary); white-space: nowrap; }
        .price-edit-group { display: flex; align-items: center; gap: 0.5rem; }
        .price-edit-group input { width: 120px; text-align: right; font-weight: 700; border-radius: var(--r-sm); border: 1px solid var(--c-outline); padding: 0.4rem 0.6rem; font-size: 0.85rem; }
        .price-edit-group input:focus { border-color: var(--pink-500); box-shadow: 0 0 0 0.2rem rgba(233,30,140,0.15); outline: none; }
        .price-change-indicator { display: inline-flex; align-items: center; gap: 0.3rem; font-size: 0.75rem; }
        .price-up { color: var(--c-success); }
        .price-down { color: var(--c-danger); }

        /* ── Filter Bar ── */
        .filter-bar { display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: center; }
        .filter-bar .form-control, .filter-bar .form-select { width: auto; min-width: 150px; border-radius: var(--r-sm); border: 1px solid var(--c-outline); font-size: 0.85rem; padding: 0.45rem 0.75rem; }
        .filter-bar .form-control:focus, .filter-bar .form-select:focus { border-color: var(--pink-500); box-shadow: 0 0 0 0.2rem rgba(233,30,140,0.15); }

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

        /* ── Modal ── */
        .modal-content { border-radius: var(--r-lg) !important; border: 1px solid var(--c-outline-variant) !important; box-shadow: var(--shadow-lg) !important; }
        .modal-header { background: linear-gradient(135deg, var(--pink-50), #fff0f8) !important; border-bottom: 1px solid var(--pink-200) !important; padding: 1.1rem 1.4rem !important; }
        .modal-header .modal-title { font-family: var(--font-display); font-weight: 800; color: var(--c-primary-dark); }
        .modal-footer { border-top: 1px solid var(--c-outline-variant) !important; padding: 1rem 1.4rem !important; }
        .modal-body { padding: 1.4rem !important; }
        .form-label { font-size: 0.83rem; color: var(--c-on-surface-var); margin-bottom: 0.3rem; }
        .form-label.fw-semibold { font-weight: 600; color: var(--c-on-surface); }
        .input-group-text { background: var(--pink-50); border: 1px solid var(--c-outline); color: var(--c-primary); }

        /* ── Timeline for price history ── */
        .price-notice { background: linear-gradient(135deg, #fffbeb, #fff7ed); border: 1px solid #fde68a; border-radius: var(--r-md); padding: 0.75rem 1rem; font-size: 0.8rem; color: #92400e; display: flex; align-items: center; gap: 0.5rem; margin-bottom: 1rem; }

        /* ── Responsive ── */
        @media (max-width: 991.98px) {
            .admin-sidebar-toggle { display: inline-flex; }
            .admin-main { margin-left: 0; }
        }
        @media (max-width: 767.98px) {
            .admin-main { padding: 1rem; }
            .filter-bar .form-control, .filter-bar .form-select { width: 100%; min-width: auto; }
            .admin-page-header { flex-direction: column; }
            .pricing-tab { padding: 0.75rem 1rem; font-size: 0.8rem; }
            .pricing-tab .tab-icon { font-size: 1rem; }
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
            <span class="brand-badge">Admin</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role"><i class="bi bi-shield-check me-1"></i>Admin</span>
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
                <i class="bi bi-cash-coin me-2" style="color:var(--pink-500);"></i>Quản Lý Biểu Giá
            </h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-database-gear"></i>
                Quản lý đơn giá dịch vụ y tế và thuốc — cập nhật giá mới sẽ áp dụng cho toàn hệ thống
            </div>
        </div>
        <c:choose>
            <c:when test="${tab eq 'medicines'}">
                <button class="btn btn-primary-pink" data-bs-toggle="modal" data-bs-target="#addMedicineModal">
                    <i class="bi bi-plus-circle-fill me-1"></i>Thêm Thuốc Mới
                </button>
            </c:when>
            <c:otherwise>
                <button class="btn btn-primary-pink" data-bs-toggle="modal" data-bs-target="#addServiceModal">
                    <i class="bi bi-plus-circle-fill me-1"></i>Thêm Dịch Vụ Mới
                </button>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- ── STATISTICS CARDS ── --%>
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-card-icon sc-icon-service">
                <i class="bi bi-activity"></i>
            </div>
            <div class="stat-card-body">
                <div class="stat-card-label">Dịch Vụ</div>
                <div class="stat-card-value">${not empty totalServices ? totalServices : '0'}</div>
                <div class="stat-card-sub">Dịch vụ y tế đang quản lý</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-card-icon sc-icon-medicine">
                <i class="bi bi-capsule"></i>
            </div>
            <div class="stat-card-body">
                <div class="stat-card-label">Thuốc</div>
                <div class="stat-card-value">${not empty totalMedicines ? totalMedicines : '0'}</div>
                <div class="stat-card-sub">Mặt hàng thuốc đang quản lý</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-card-icon sc-icon-money">
                <i class="bi bi-graph-up-arrow"></i>
            </div>
            <div class="stat-card-body">
                <div class="stat-card-label">Tổng Mục</div>
                <div class="stat-card-value">
                    <c:set var="svcCount" value="${not empty totalServices ? totalServices : 0}"/>
                    <c:set var="medCount" value="${not empty totalMedicines ? totalMedicines : 0}"/>
                    ${svcCount + medCount}
                </div>
                <div class="stat-card-sub">Dịch vụ + Thuốc</div>
            </div>
        </div>
    </div>

    <%-- ── ALERT MESSAGES ── --%>
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            <div>
                <c:choose>
                    <c:when test="${success eq 'created'}"><strong>Thành công!</strong> Đã thêm mới vào danh mục. Mục mới sẽ có hiệu lực ngay lập tức trong toàn hệ thống.</c:when>
                    <c:when test="${success eq 'updated'}"><strong>Thành công!</strong> Đơn giá đã được cập nhật. Hệ thống sẽ sử dụng mức giá mới cho các giao dịch tiếp theo.</c:when>
                    <c:otherwise><strong>Thành công!</strong> Thao tác hoàn tất.</c:otherwise>
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

    <%-- ── PRICE UPDATE NOTICE ── --%>
    <div class="price-notice">
        <i class="bi bi-info-circle-fill fs-5"></i>
        <div>
            <strong>Lưu ý:</strong> Khi thay đổi đơn giá, mức giá mới sẽ được áp dụng cho tất cả các giao dịch mới (lập hóa đơn, kê đơn thuốc, thanh toán). Các giao dịch đã hoàn tất trước đó không bị ảnh hưởng. Mọi thay đổi đều được ghi nhận vào lịch sử hệ thống.
        </div>
    </div>

    <%-- ── TAB SWITCHER ── --%>
    <div class="pricing-tabs">
        <a href="${pageContext.request.contextPath}/admin/pricing/?tab=services"
           class="pricing-tab ${tab eq 'services' ? 'active' : ''}">
            <span class="tab-icon"><i class="bi bi-activity"></i></span>
            <span>Dịch Vụ Y Tế</span>
            <span class="tab-count">${not empty totalServices ? totalServices : '0'}</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/pricing/?tab=medicines"
           class="pricing-tab ${tab eq 'medicines' ? 'active' : ''}">
            <span class="tab-icon"><i class="bi bi-capsule"></i></span>
            <span>Thuốc</span>
            <span class="tab-count">${not empty totalMedicines ? totalMedicines : '0'}</span>
        </a>
    </div>

    <%-- ── FILTER BAR ── --%>
    <div class="admin-card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/pricing/" class="filter-bar">
                <input type="hidden" name="tab" value="${tab}">
                <div class="input-group" style="max-width:280px;">
                    <span class="input-group-text"><i class="bi bi-search"></i></span>
                    <input type="text" name="search" class="form-control"
                           placeholder="${tab eq 'medicines' ? 'Tìm tên thuốc, mã thuốc...' : 'Tìm tên dịch vụ, mã dịch vụ...'}"
                           value="${not empty search ? fn:escapeXml(search) : ''}">
                </div>
                <select name="active" class="form-select">
                    <option value="">Tất cả trạng thái</option>
                    <option value="1" ${activeFilter eq '1' ? 'selected' : ''}>Đang áp dụng</option>
                    <option value="0" ${activeFilter eq '0' ? 'selected' : ''}>Ngừng áp dụng</option>
                </select>
                <button type="submit" class="btn btn-primary-pink">
                    <i class="bi bi-funnel-fill me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/admin/pricing/?tab=${tab}" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-counterclockwise me-1"></i>Đặt lại
                </a>
            </form>
        </div>
    </div>

    <%-- ════════════════════════════════════════════════════════
         TAB: DỊCH VỤ Y TẾ
         ════════════════════════════════════════════════════════ --%>
    <c:if test="${tab eq 'services'}">
        <div class="admin-card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5><i class="bi bi-activity me-2"></i>Danh Sách Dịch Vụ & Đơn Giá</h5>
                <span class="badge bg-white text-dark border" style="font-size:0.8rem;">
                    <i class="bi bi-database me-1"></i>${not empty totalServices ? totalServices : '0'} dịch vụ
                </span>
            </div>
            <div class="card-body p-0">
                <div class="admin-table-wrapper">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>#ID</th>
                                <th>Mã DV</th>
                                <th>Tên Dịch Vụ</th>
                                <th>Mô Tả</th>
                                <th>Thời Gian</th>
                                <th>Yêu Cầu</th>
                                <th style="width:200px;">Đơn Giá Hiện Tại</th>
                                <th>Trạng Thái</th>
                                <th style="width:140px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty services}">
                                    <c:forEach var="svc" items="${services}">
                                        <tr>
                                            <td style="color:var(--c-muted);font-size:0.8rem;font-weight:600;">#${svc.id}</td>
                                            <td style="font-weight:600;font-size:0.82rem;">
                                                <code style="background:var(--pink-50);color:var(--c-primary-dark);padding:2px 8px;border-radius:4px;font-size:0.75rem;">
                                                    ${not empty svc.serviceCode ? fn:escapeXml(svc.serviceCode) : '—'}
                                                </code>
                                            </td>
                                            <td style="font-weight:600;">
                                                <div class="d-flex align-items-center gap-2">
                                                    <i class="bi bi-clipboard2-pulse" style="color:var(--pink-500);"></i>
                                                    ${fn:escapeXml(svc.serviceName)}
                                                </div>
                                            </td>
                                            <td style="font-size:0.8rem;max-width:200px;">
                                                <c:choose>
                                                    <c:when test="${not empty svc.description}">
                                                        <span title="${fn:escapeXml(svc.description)}">
                                                            ${fn:length(svc.description) > 50 ? fn:substring(svc.description, 0, 50).concat('...') : svc.description}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="font-size:0.82rem;">
                                                ${svc.durationMins > 0 ? svc.durationMins.toString().concat(' phút') : '—'}
                                            </td>
                                            <td>
                                                <c:if test="${svc.requiresFasting}">
                                                    <span class="badge-boolean-true">Nhịn ăn</span>
                                                </c:if>
                                                <c:if test="${svc.requiresFullBladder}">
                                                    <span class="badge-boolean-true">Đầy bàng quang</span>
                                                </c:if>
                                                <c:if test="${!svc.requiresFasting && !svc.requiresFullBladder}">
                                                    <span class="text-muted">—</span>
                                                </c:if>
                                            </td>
                                            <td>
                                                <div class="price-display">
                                                    <fmt:formatNumber value="${svc.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </div>
                                                <c:if test="${not empty svc.updatedAt}">
                                                    <small style="font-size:0.68rem;color:var(--c-muted);">
                                                        Cập nhật: <fmt:formatDate value="${svc.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${svc.active}">
                                                        <span class="badge-active"><i class="bi bi-check-circle me-1"></i>Áp dụng</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-inactive"><i class="bi bi-slash-circle me-1"></i>Ngừng</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <button class="btn btn-sm btn-primary-pink btn-action"
                                                        onclick="openServicePriceModal('${svc.id}','${fn:escapeXml(svc.serviceCode)}','${fn:escapeXml(svc.serviceName)}','${fn:escapeXml(svc.description)}','${svc.price}','${svc.durationMins}','${svc.requiresFasting}','${svc.requiresFullBladder}','${fn:escapeXml(svc.requiredRoomType)}','${fn:escapeXml(svc.allowedSpecialties)}','${svc.categoryId}','${svc.active}')"
                                                        title="Sửa giá">
                                                    <i class="bi bi-pencil-square me-1"></i>Sửa Giá
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="9" class="p-0">
                                            <div class="admin-empty-state">
                                                <i class="bi bi-clipboard2-pulse"></i>
                                                <h6>Không tìm thấy dịch vụ</h6>
                                                <p style="font-size:0.85rem;">Chưa có dữ liệu hoặc không khớp với bộ lọc.</p>
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
    </c:if>

    <%-- ════════════════════════════════════════════════════════
         TAB: THUỐC
         ════════════════════════════════════════════════════════ --%>
    <c:if test="${tab eq 'medicines'}">
        <div class="admin-card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5><i class="bi bi-capsule me-2"></i>Danh Sách Thuốc & Đơn Giá</h5>
                <span class="badge bg-white text-dark border" style="font-size:0.8rem;">
                    <i class="bi bi-database me-1"></i>${not empty totalMedicines ? totalMedicines : '0'} thuốc
                </span>
            </div>
            <div class="card-body p-0">
                <div class="admin-table-wrapper">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>#ID</th>
                                <th>Mã Thuốc</th>
                                <th>Tên Thuốc</th>
                                <th>Hàm Lượng</th>
                                <th>Đơn Vị</th>
                                <th>Tồn Kho</th>
                                <th style="width:200px;">Đơn Giá Hiện Tại</th>
                                <th>Trạng Thái</th>
                                <th style="width:140px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty medicines}">
                                    <c:forEach var="med" items="${medicines}">
                                        <tr>
                                            <td style="color:var(--c-muted);font-size:0.8rem;font-weight:600;">#${med.id}</td>
                                            <td style="font-weight:600;font-size:0.82rem;">
                                                <code style="background:#eef2ff;color:#4338ca;padding:2px 8px;border-radius:4px;font-size:0.75rem;">
                                                    ${not empty med.medicineCode ? fn:escapeXml(med.medicineCode) : '—'}
                                                </code>
                                            </td>
                                            <td style="font-weight:600;">
                                                <div class="d-flex align-items-center gap-2">
                                                    <i class="bi bi-capsule-fill" style="color:#6366f1;"></i>
                                                    ${fn:escapeXml(med.name)}
                                                </div>
                                            </td>
                                            <td style="font-size:0.82rem;">
                                                ${not empty med.dosage ? fn:escapeXml(med.dosage) : '—'}
                                            </td>
                                            <td style="font-size:0.82rem;">
                                                ${not empty med.unit ? fn:escapeXml(med.unit) : '—'}
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${med.stockQuantity > 10}">
                                                        <span class="text-success fw-semibold">${med.stockQuantity}</span>
                                                    </c:when>
                                                    <c:when test="${med.stockQuantity > 0}">
                                                        <span class="text-warning fw-semibold">${med.stockQuantity}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-danger fw-semibold">Hết hàng</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="price-display" style="color:#4338ca;">
                                                    <fmt:formatNumber value="${med.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </div>
                                                <c:if test="${not empty med.updatedAt}">
                                                    <small style="font-size:0.68rem;color:var(--c-muted);">
                                                        Cập nhật: <fmt:formatDate value="${med.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${med.active}">
                                                        <span class="badge-active"><i class="bi bi-check-circle me-1"></i>Áp dụng</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-inactive"><i class="bi bi-slash-circle me-1"></i>Ngừng</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <button class="btn btn-sm btn-primary-pink btn-action"
                                                        onclick="openMedicinePriceModal('${med.id}','${fn:escapeXml(med.medicineCode)}','${fn:escapeXml(med.name)}','${fn:escapeXml(med.description)}','${fn:escapeXml(med.dosage)}','${fn:escapeXml(med.unit)}','${med.price}','${med.stockQuantity}','${med.active}')"
                                                        title="Sửa giá">
                                                    <i class="bi bi-pencil-square me-1"></i>Sửa Giá
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="9" class="p-0">
                                            <div class="admin-empty-state">
                                                <i class="bi bi-capsule"></i>
                                                <h6>Không tìm thấy thuốc</h6>
                                                <p style="font-size:0.85rem;">Chưa có dữ liệu hoặc không khớp với bộ lọc.</p>
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
    </c:if>

    <%-- ── PAGINATION ── --%>
    <c:if test="${totalPages > 1}">
        <div class="admin-pagination">
            <c:url var="baseUrl" value="/admin/pricing/">
                <c:param name="tab" value="${tab}"/>
                <c:param name="search" value="${search}"/>
                <c:param name="active" value="${activeFilter}"/>
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
     MODAL: SỬA GIÁ DỊCH VỤ
     ============================================================ --%>
<div class="modal fade" id="editServicePriceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="bi bi-pencil-square me-2"></i>Sửa Biểu Giá — Dịch Vụ
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/pricing/">
                <input type="hidden" name="action" value="updateServicePrice">
                <input type="hidden" name="tab" value="services">
                <input type="hidden" name="id" id="editSvcId">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Mã dịch vụ</label>
                            <input type="text" name="serviceCode" id="editSvcCode" class="form-control" required maxlength="50">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên dịch vụ</label>
                            <input type="text" name="serviceName" id="editSvcName" class="form-control" required maxlength="100">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Mô tả</label>
                            <textarea name="description" id="editSvcDesc" class="form-control" rows="2" maxlength="500"></textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-cash-stack me-1" style="color:var(--pink-500);"></i>Đơn giá mới (VNĐ) <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-text">₫</span>
                                <input type="number" name="price" id="editSvcPrice" class="form-control"
                                       required min="1" step="1000" placeholder="Nhập đơn giá mới">
                            </div>
                            <small id="svcOldPriceHint" class="text-muted" style="font-size:0.72rem;"></small>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Thời gian (phút)</label>
                            <input type="number" name="durationMins" id="editSvcDuration" class="form-control" min="0">
                        </div>
                        <div class="col-md-2 d-flex align-items-end pb-2">
                            <div class="form-check">
                                <input type="checkbox" name="isActive" class="form-check-input" id="editSvcIsActive">
                                <label class="form-check-label fw-semibold" for="editSvcIsActive">Đang áp dụng</label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Hủy
                    </button>
                    <button type="submit" class="btn btn-primary-pink" onclick="return confirm('Xác nhận cập nhật đơn giá dịch vụ này?\n\n⚠️ Giá mới sẽ được áp dụng cho tất cả giao dịch mới.')">
                        <i class="bi bi-check-lg me-1"></i>Cập Nhật Đơn Giá
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: SỬA GIÁ THUỐC
     ============================================================ --%>
<div class="modal fade" id="editMedicinePriceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="bi bi-pencil-square me-2"></i>Sửa Biểu Giá — Thuốc
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/pricing/">
                <input type="hidden" name="action" value="updateMedicinePrice">
                <input type="hidden" name="tab" value="medicines">
                <input type="hidden" name="id" id="editMedId">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Mã thuốc</label>
                            <input type="text" name="medicineCode" id="editMedCode" class="form-control" required maxlength="50">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên thuốc</label>
                            <input type="text" name="name" id="editMedName" class="form-control" required maxlength="100">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Mô tả</label>
                            <textarea name="description" id="editMedDesc" class="form-control" rows="2" maxlength="500"></textarea>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Hàm lượng</label>
                            <input type="text" name="dosage" id="editMedDosage" class="form-control" maxlength="100">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-semibold">Đơn vị</label>
                            <input type="text" name="unit" id="editMedUnit" class="form-control" maxlength="50">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Tồn kho</label>
                            <input type="number" name="stockQuantity" id="editMedStock" class="form-control" min="0">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">
                                <i class="bi bi-cash-stack me-1" style="color:var(--pink-500);"></i>Đơn giá mới (VNĐ) <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <span class="input-group-text">₫</span>
                                <input type="number" name="price" id="editMedPrice" class="form-control"
                                       required min="1" step="1000" placeholder="Nhập đơn giá mới">
                            </div>
                            <small id="medOldPriceHint" class="text-muted" style="font-size:0.72rem;"></small>
                        </div>
                        <div class="col-md-2 d-flex align-items-end pb-2">
                            <div class="form-check">
                                <input type="checkbox" name="isActive" class="form-check-input" id="editMedIsActive">
                                <label class="form-check-label fw-semibold" for="editMedIsActive">Đang áp dụng</label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Hủy
                    </button>
                    <button type="submit" class="btn btn-primary-pink" onclick="return confirm('Xác nhận cập nhật đơn giá thuốc này?\n\n⚠️ Giá mới sẽ được áp dụng cho tất cả giao dịch mới.')">
                        <i class="bi bi-check-lg me-1"></i>Cập Nhật Đơn Giá
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: THÊM DỊCH VỤ MỚI
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
            <form method="post" action="${pageContext.request.contextPath}/admin/pricing/">
                <input type="hidden" name="action" value="createService">
                <input type="hidden" name="tab" value="services">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Mã dịch vụ <span class="text-danger">*</span></label>
                            <input type="text" name="serviceCode" class="form-control" required maxlength="50"
                                   placeholder="VD: SVC-KHAI-THAI" value="${formData.serviceCode}">
                            <c:if test="${not empty errors.serviceCode}">
                                <div class="text-danger mt-1" style="font-size:0.78rem;">${errors.serviceCode}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên dịch vụ <span class="text-danger">*</span></label>
                            <input type="text" name="serviceName" class="form-control" required maxlength="100"
                                   placeholder="VD: Khám thai định kỳ" value="${formData.serviceName}">
                            <c:if test="${not empty errors.serviceName}">
                                <div class="text-danger mt-1" style="font-size:0.78rem;">${errors.serviceName}</div>
                            </c:if>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Mô tả</label>
                            <textarea name="description" class="form-control" rows="2" maxlength="500"
                                      placeholder="Mô tả chi tiết dịch vụ...">${formData.description}</textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Đơn giá (VNĐ) <span class="text-danger">*</span></label>
                            <input type="number" name="price" class="form-control" required min="1000" step="1000"
                                   placeholder="VD: 500000" value="${formData.price}">
                            <c:if test="${not empty errors.price}">
                                <div class="text-danger mt-1" style="font-size:0.78rem;">${errors.price}</div>
                            </c:if>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Thời gian (phút)</label>
                            <input type="number" name="durationMins" class="form-control" min="0"
                                   placeholder="VD: 30" value="${formData.durationMins}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Phòng yêu cầu</label>
                            <input type="text" name="requiredRoomType" class="form-control" maxlength="50"
                                   placeholder="VD: Phòng siêu âm" value="${formData.requiredRoomType}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Chuyên khoa</label>
                            <input type="text" name="allowedSpecialties" class="form-control" maxlength="255"
                                   placeholder="VD: Sản khoa, Phụ khoa" value="${formData.allowedSpecialties}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Category ID</label>
                            <input type="number" name="categoryId" class="form-control" min="0"
                                   placeholder="1-4" value="${formData.categoryId}">
                        </div>
                        <div class="col-md-3 d-flex align-items-end gap-3 pb-2">
                            <div class="form-check">
                                <input type="checkbox" name="requiresFasting" class="form-check-input" id="addSvcFasting">
                                <label class="form-check-label" for="addSvcFasting" style="font-size:0.82rem;">Nhịn ăn</label>
                            </div>
                            <div class="form-check">
                                <input type="checkbox" name="requiresFullBladder" class="form-check-input" id="addSvcBladder">
                                <label class="form-check-label" for="addSvcBladder" style="font-size:0.82rem;">Đầy bàng quang</label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Hủy
                    </button>
                    <button type="submit" class="btn btn-primary-pink">
                        <i class="bi bi-check-lg me-1"></i>Tạo Dịch Vụ
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: THÊM THUỐC MỚI
     ============================================================ --%>
<div class="modal fade" id="addMedicineModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="bi bi-plus-circle-fill me-2"></i>Thêm Thuốc Mới
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/pricing/">
                <input type="hidden" name="action" value="createMedicine">
                <input type="hidden" name="tab" value="medicines">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Mã thuốc <span class="text-danger">*</span></label>
                            <input type="text" name="medicineCode" class="form-control" required maxlength="50"
                                   placeholder="VD: MED-ACID-FOLIC" value="${formData.medicineCode}">
                            <c:if test="${not empty errors.medicineCode}">
                                <div class="text-danger mt-1" style="font-size:0.78rem;">${errors.medicineCode}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên thuốc <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control" required maxlength="100"
                                   placeholder="VD: Acid Folic 400mcg" value="${formData.name}">
                            <c:if test="${not empty errors.name}">
                                <div class="text-danger mt-1" style="font-size:0.78rem;">${errors.name}</div>
                            </c:if>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Mô tả</label>
                            <textarea name="description" class="form-control" rows="2" maxlength="500"
                                      placeholder="Mô tả công dụng, chỉ định...">${formData.description}</textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Hàm lượng</label>
                            <input type="text" name="dosage" class="form-control" maxlength="100"
                                   placeholder="VD: 400mcg" value="${formData.dosage}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Đơn vị tính</label>
                            <input type="text" name="unit" class="form-control" maxlength="50"
                                   placeholder="VD: Viên" value="${formData.unit}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Tồn kho</label>
                            <input type="number" name="stockQuantity" class="form-control" min="0"
                                   placeholder="VD: 100" value="${formData.stockQuantity}">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Đơn giá (VNĐ) <span class="text-danger">*</span></label>
                            <input type="number" name="price" class="form-control" required min="1" step="1000"
                                   placeholder="VD: 2500" value="${formData.price}">
                            <c:if test="${not empty errors.price}">
                                <div class="text-danger mt-1" style="font-size:0.78rem;">${errors.price}</div>
                            </c:if>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-1"></i>Hủy
                    </button>
                    <button type="submit" class="btn btn-primary-pink">
                        <i class="bi bi-check-lg me-1"></i>Tạo Thuốc
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
        if (link.href && link.href.indexOf('/admin/pricing') !== -1) {
            link.classList.add('active');
        }
    }
})();

// ── Format currency ──
function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', maximumFractionDigits: 0 }).format(amount);
}

// ── Service Price Modal ──
function openServicePriceModal(id, code, name, desc, price, duration, fasting, bladder, room, specialties, catId, isActive) {
    document.getElementById('editSvcId').value = id;
    document.getElementById('editSvcCode').value = code || '';
    document.getElementById('editSvcName').value = name || '';
    document.getElementById('editSvcDesc').value = desc || '';
    document.getElementById('editSvcPrice').value = price || '0';
    document.getElementById('editSvcDuration').value = duration || '';
    document.getElementById('editSvcIsActive').checked = isActive === 'true';
    document.getElementById('svcOldPriceHint').innerHTML =
        '<i class="bi bi-info-circle me-1"></i>Giá hiện tại: <strong>' + formatCurrency(parseFloat(price) || 0) + '</strong>';
    new bootstrap.Modal(document.getElementById('editServicePriceModal')).show();
}

// ── Medicine Price Modal ──
function openMedicinePriceModal(id, code, name, desc, dosage, unit, price, stock, isActive) {
    document.getElementById('editMedId').value = id;
    document.getElementById('editMedCode').value = code || '';
    document.getElementById('editMedName').value = name || '';
    document.getElementById('editMedDesc').value = desc || '';
    document.getElementById('editMedDosage').value = dosage || '';
    document.getElementById('editMedUnit').value = unit || '';
    document.getElementById('editMedPrice').value = price || '0';
    document.getElementById('editMedStock').value = stock || '0';
    document.getElementById('editMedIsActive').checked = isActive === 'true';
    document.getElementById('medOldPriceHint').innerHTML =
        '<i class="bi bi-info-circle me-1"></i>Giá hiện tại: <strong>' + formatCurrency(parseFloat(price) || 0) + '</strong>';
    new bootstrap.Modal(document.getElementById('editMedicinePriceModal')).show();
}

// ── Initialize tooltips ──
document.addEventListener('DOMContentLoaded', function() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (el) {
        return new bootstrap.Tooltip(el);
    });

    // Auto-open create modals nếu validation fail
    <c:if test="${showCreateServiceModal}">
        new bootstrap.Modal(document.getElementById('addServiceModal')).show();
    </c:if>
    <c:if test="${showCreateMedicineModal}">
        new bootstrap.Modal(document.getElementById('addMedicineModal')).show();
    </c:if>
});
</script>
</body>
</html>
