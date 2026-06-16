<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Người Dùng — CAMS Admin</title>

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
            --sb-bg: #1a0a12; --sb-bg-mid: #2d1020; --sb-bg-deep: #0f0509;
            --sb-hover: #3d1830; --sb-active-bg: rgba(233,30,140,0.18);
            --sb-active-border: #e91e8c; --sb-text: #f0d5e3; --sb-text-muted: #a07085;
            --sb-border: rgba(255,255,255,0.07); --sb-accent: #ff80b3;
            --status-active-bg: #e8f5e9; --status-active-fg: #2e7d32;
            --status-inactive-bg: #f5f5f5; --status-inactive-fg: #757575;
            --status-locked-bg: #ffebee; --status-locked-fg: #c62828;
            --status-pending-bg: #fff8e1; --status-pending-fg: #f57f17;
            --shadow-xs: 0 1px 3px rgba(194,24,91,0.07);
            --shadow-sm: 0 2px 8px rgba(194,24,91,0.10);
            --shadow-md: 0 4px 20px rgba(194,24,91,0.13);
            --r-sm: 8px; --r-md: 12px; --r-lg: 16px; --r-pill: 999px;
            --t-fast: 0.15s ease;
            --font-display: 'Nunito', sans-serif;
            --font-body: 'Inter', sans-serif;
            /* Ghi đè biến Bootstrap để toàn bộ component (modal, card, ...) dùng chung font */
            --bs-body-font-family: var(--font-body);
        }
        *, *::before, *::after { box-sizing: border-box; }
        body, .btn, .form-control, .form-select, .form-label, .table, .badge, .card, .modal { font-family: var(--font-body); }
        h1,h2,h3,h4,h5,h6 { font-family: var(--font-display); }
        body.admin-body { font-family: var(--font-body); background: var(--c-bg); color: var(--c-on-bg); margin: 0; padding: 0; line-height: 1.6; -webkit-font-smoothing: antialiased; }

        /* ── TOP BAR (giống dashboard) ── */
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
        .badge-role-tag { display: inline-block; padding: 2px 10px; border-radius: var(--r-pill); font-size: 0.7rem; font-weight: 700; background: var(--pink-100); color: var(--pink-700); border: 1px solid var(--pink-200); }
        .badge-status { display: inline-block; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.72rem; font-weight: 700; }
        .badge-status-active { background: var(--status-active-bg); color: var(--status-active-fg); }
        .badge-status-inactive { background: var(--status-inactive-bg); color: var(--status-inactive-fg); }
        .badge-status-locked { background: var(--status-locked-bg); color: var(--status-locked-fg); }
        .badge-status-pending { background: var(--status-pending-bg); color: var(--status-pending-fg); }
        .badge-status-pending-verification { background: var(--status-pending-bg); color: var(--status-pending-fg); }

        /* ── Buttons ── */
        .btn-primary-pink { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); color: #fff; border: none; font-weight: 700; border-radius: var(--r-sm); padding: 0.55rem 1.2rem; transition: all var(--t-fast); }
        .btn-primary-pink:hover { background: linear-gradient(135deg, var(--pink-600), var(--pink-700)); color: #fff; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(233,30,140,0.3); }
        .btn-sm-outline { font-size: 0.75rem; font-weight: 600; padding: 4px 10px; border-radius: var(--r-sm); }
        .btn-action { display: inline-flex; align-items: center; gap: 0.25rem; }

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
        .admin-empty-state { text-align: center; padding: 2.5rem 1rem; color: var(--c-muted); }
        .admin-empty-state i { font-size: 2.5rem; color: var(--pink-200); display: block; margin-bottom: 0.75rem; }

        /* ── Responsive ── */
        @media (max-width: 991.98px) {
            .admin-sidebar-toggle { display: inline-flex; }
            .admin-main { margin-left: 0; }
        }
        @media (max-width: 767.98px) {
            .admin-main { padding: 1rem; }
            .filter-bar .form-control, .filter-bar .form-select { width: 100%; min-width: auto; }
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

    <div class="admin-page-header">
        <div class="admin-page-header-left">
            <h1 class="admin-page-title">Quản Lý Người Dùng </h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-people-fill"></i>
                Tổng: <strong>${totalUsers}</strong> người dùng
            </div>
        </div>
        <button class="btn btn-primary-pink" data-bs-toggle="modal" data-bs-target="#addUserModal">
            <i class="bi bi-person-plus-fill me-1"></i>Thêm Người Dùng
        </button>
    </div>

    <%-- Alert messages --%>
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-1"></i>
            <c:choose>
                <c:when test="${success eq 'created'}">Đã tạo người dùng thành công!</c:when>
                <c:when test="${success eq 'updated'}">Đã cập nhật thành công!</c:when>
                <c:when test="${success eq 'deleted'}">Đã xóa người dùng thành công!</c:when>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-1"></i>${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <%-- Fallback: hiển thị lỗi validation từ map errors (phòng trường hợp modal không show được) --%>
    <c:if test="${not empty errors and empty showAddModal}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-1"></i>
            <strong>Lỗi khi tạo người dùng:</strong>
            <c:if test="${not empty errors['general']}">${errors['general']}</c:if>
            <c:if test="${empty errors['general']}">Vui lòng kiểm tra lại thông tin đã nhập.</c:if>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty editErrors and empty showEditModal}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-1"></i>
            <strong>Lỗi khi cập nhật người dùng:</strong>
            <c:if test="${not empty editErrors['general']}">${editErrors['general']}</c:if>
            <c:if test="${empty editErrors['general']}">Vui lòng kiểm tra lại thông tin đã nhập.</c:if>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <%-- Filter + Search Bar --%>
    <div class="admin-card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/users/" class="filter-bar">
                <input type="text" name="search" class="form-control" placeholder="Tìm tên, email, SĐT..."
                       value="${not empty search ? search : ''}" style="min-width:220px;">
                <select name="role" class="form-select">
                    <option value="">Tất cả vai trò</option>
                    <c:forEach var="entry" items="${roleMap}">
                        <option value="${entry.key}" ${roleFilter eq entry.key ? 'selected' : ''}>${entry.value}</option>
                    </c:forEach>
                </select>
                <select name="status" class="form-select">
                    <option value="">Tất cả trạng thái</option>
                    <option value="Active" ${statusFilter eq 'Active' ? 'selected' : ''}>Active</option>
                    <option value="Inactive" ${statusFilter eq 'Inactive' ? 'selected' : ''}>Inactive</option>
                    <option value="Pending Verification" ${statusFilter eq 'Pending Verification' ? 'selected' : ''}>Pending</option>
                </select>
                <button type="submit" class="btn btn-primary-pink">
                    <i class="bi bi-search me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/admin/users/" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-x-circle me-1"></i>Xóa lọc
                </a>
            </form>
        </div>
    </div>

    <%-- Users Table --%>
    <div class="admin-card">
        <div class="card-body p-0">
            <div class="admin-table-wrapper">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Họ Tên</th>
                            <th>Tên ĐN</th>
                            <th>Email</th>
                            <th>Điện Thoại</th>
                            <th>Vai Trò</th>
                            <th>Trạng Thái</th>
                            <th>Ngày Tạo</th>
                            <th style="width:160px;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty users}">
                                <c:forEach var="u" items="${users}" varStatus="loop">
                                    <tr>
                                        <td style="color:var(--c-muted);font-size:0.8rem;font-weight:600;">#${(currentPage - 1) * pageSize + loop.index + 1}</td>
                                        <td style="font-weight:600;">
                                            ${u.fullName}
                                            <c:if test="${u.authProvider eq 'google'}">
                                                <i class="bi bi-google text-muted ms-1" title="Google"></i>
                                            </c:if>
                                        </td>
                                        <td style="font-size:0.82rem;font-weight:500;">${not empty u.username ? u.username : '—'}</td>
                                        <td style="font-size:0.82rem;">${u.email}</td>
                                        <td style="font-size:0.82rem;">${not empty u.phone ? fn:escapeXml(u.phone) : '—'}</td>
                                        <td><span class="badge-role-tag">${not empty u.roleName ? u.roleName : roleMap[u.roleId]}</span></td>
                                        <td>
                                            <c:set var="statusClass" value="${not empty u.status ? fn:toLowerCase(fn:replace(u.status, ' ', '-')) : 'inactive'}" />
                                            <span class="badge-status badge-status-${statusClass}">
                                                ${not empty u.status ? u.status : 'Inactive'}
                                            </span>
                                        </td>
                                        <td style="font-size:0.8rem;color:var(--c-muted);">
                                            <c:choose>
                                                <c:when test="${not empty u.createdAt}">
                                                    <fmt:formatDate value="${u.createdAt}" pattern="dd/MM/yyyy" />
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="d-flex gap-1">
                                                <%-- Edit button --%>
                                                <button class="btn btn-sm btn-outline-secondary btn-action btn-edit-user"
                                                        data-id="${u.id}"
                                                        data-fullname="${fn:escapeXml(u.fullName)}"
                                                        data-email="${fn:escapeXml(u.email)}"
                                                        data-username="${fn:escapeXml(u.username)}"
                                                        data-phone="${fn:escapeXml(u.phone)}"
                                                        data-roleid="${u.roleId}"
                                                        data-status="${fn:escapeXml(u.status)}"
                                                        data-authprovider="${fn:escapeXml(u.authProvider)}"
                                                        title="Sửa">
                                                    <i class="bi bi-pencil-square"></i>
                                                </button>
                                                <%-- Toggle status --%>
                                                <c:choose>
                                                    <c:when test="${u.status eq 'Active'}">
                                                        <form method="post" action="${pageContext.request.contextPath}/admin/users/" style="display:inline;">
                                                            <input type="hidden" name="action" value="toggleStatus">
                                                            <input type="hidden" name="userId" value="${u.id}">
                                                            <input type="hidden" name="newStatus" value="Locked">
                                                            <button type="submit" class="btn btn-sm btn-outline-warning btn-action"
                                                                    title="Khóa" onclick="return confirm('Khóa người dùng #${u.id}?')">
                                                                <i class="bi bi-lock-fill"></i>
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form method="post" action="${pageContext.request.contextPath}/admin/users/" style="display:inline;">
                                                            <input type="hidden" name="action" value="toggleStatus">
                                                            <input type="hidden" name="userId" value="${u.id}">
                                                            <input type="hidden" name="newStatus" value="Active">
                                                            <button type="submit" class="btn btn-sm btn-outline-success btn-action"
                                                                    title="Mở khóa" onclick="return confirm('Kích hoạt người dùng #${u.id}?')">
                                                                <i class="bi bi-unlock-fill"></i>
                                                            </button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                                <%-- Delete --%>
                                                <form method="post" action="${pageContext.request.contextPath}/admin/users/" style="display:inline;">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="userId" value="${u.id}">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger btn-action"
                                                            title="Xóa" onclick="return confirm('Vô hiệu hóa người dùng #${u.id} — ${fn:escapeXml(u.fullName)}?\nTài khoản sẽ bị khóa và không thể đăng nhập. Dữ liệu liên quan vẫn được giữ nguyên.')">
                                                        <i class="bi bi-trash3-fill"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9" class="p-0">
                                        <div class="admin-empty-state">
                                            <i class="bi bi-inbox"></i>
                                            <h6>Không tìm thấy người dùng</h6>
                                            <p>Chưa có dữ liệu hoặc không khớp với bộ lọc.</p>
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

    <%-- Pagination --%>
    <c:if test="${totalPages > 1}">
        <div class="admin-pagination">
            <c:url var="baseUrl" value="/admin/users/">
                <c:param name="search" value="${search}"/>
                <c:param name="role" value="${roleFilter}"/>
                <c:param name="status" value="${statusFilter}"/>
            </c:url>

            <c:if test="${currentPage > 1}">
                <a href="${baseUrl}&page=${currentPage - 1}"><i class="bi bi-chevron-left"></i></a>
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
                <a href="${baseUrl}&page=${currentPage + 1}"><i class="bi bi-chevron-right"></i></a>
            </c:if>
        </div>
    </c:if>

</main>

<%-- ============================================================
     MODAL: THÊM NGƯỜI DÙNG
     ============================================================ --%>
<div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content" style="border-radius:var(--r-lg);border:1px solid var(--c-outline-variant);">
            <div class="modal-header" style="background:var(--pink-50);border-bottom:1px solid var(--pink-200);">
                <h5 class="modal-title" style="font-family:var(--font-display);font-weight:800;color:var(--c-primary-dark);">
                    <i class="bi bi-person-plus-fill me-2"></i>Thêm Người Dùng Mới
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/users/" novalidate>
                <input type="hidden" name="action" value="create">
                <div class="modal-body">
                    <%-- Error summary cho lỗi chung (DB, hệ thống) --%>
                    <c:if test="${not empty errors['general']}">
                        <div class="alert alert-danger py-2 mb-3 d-flex align-items-center gap-2">
                            <i class="bi bi-exclamation-triangle-fill flex-shrink-0"></i>
                            <span>${errors['general']}</span>
                        </div>
                    </c:if>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Họ tên <span class="text-danger">*</span></label>
                            <input type="text" name="fullName" class="form-control ${not empty errors['fullName'] ? 'is-invalid' : ''}"
                                   required maxlength="100" value="${fn:escapeXml(formFullName)}">
                            <c:if test="${not empty errors['fullName']}">
                                <div class="invalid-feedback">${errors['fullName']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Email <span class="text-danger">*</span></label>
                            <input type="email" name="email" class="form-control ${not empty errors['email'] ? 'is-invalid' : ''}"
                                   required maxlength="100" value="${fn:escapeXml(formEmail)}">
                            <c:if test="${not empty errors['email']}">
                                <div class="invalid-feedback">${errors['email']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên đăng nhập <span class="text-danger">*</span></label>
                            <input type="text" name="username" class="form-control ${not empty errors['username'] ? 'is-invalid' : ''}"
                                   required minlength="4" maxlength="50" pattern="[a-zA-Z0-9_]+"
                                   placeholder="Ít nhất 4 ký tự, chỉ chữ/số/_"
                                   title="Tên đăng nhập phải có ít nhất 4 ký tự, chỉ được chứa chữ cái (a-z), số (0-9) và dấu gạch dưới (_)"
                                   value="${fn:escapeXml(formUsername)}">
                            <c:if test="${not empty errors['username']}">
                                <div class="invalid-feedback">${errors['username']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Mật khẩu <span class="text-danger">*</span></label>
                            <input type="password" name="password" class="form-control ${not empty errors['password'] ? 'is-invalid' : ''}"
                                   required minlength="6" placeholder="Ít nhất 6 ký tự">
                            <c:if test="${not empty errors['password']}">
                                <div class="invalid-feedback">${errors['password']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Số điện thoại</label>
                            <input type="text" name="phone" class="form-control ${not empty errors['phone'] ? 'is-invalid' : ''}"
                                   maxlength="20" placeholder="VD: 0912345678" value="${fn:escapeXml(formPhone)}">
                            <c:if test="${not empty errors['phone']}">
                                <div class="invalid-feedback">${errors['phone']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Vai trò</label>
                            <select name="roleId" class="form-select ${not empty errors['roleId'] ? 'is-invalid' : ''}">
                                <c:forEach var="entry" items="${roleMap}">
                                    <option value="${entry.key}" ${not empty formRoleId ? (entry.key == formRoleId ? 'selected' : '') : (entry.key == 5 ? 'selected' : '')}>${entry.value}</option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty errors['roleId']}">
                                <div class="invalid-feedback">${errors['roleId']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Trạng thái</label>
                            <select name="status" class="form-select">
                                <option value="Active" ${formStatus eq 'Active' ? 'selected' : ''}>Active</option>
                                <option value="Inactive" ${formStatus eq 'Inactive' ? 'selected' : ''}>Inactive</option>
                                <option value="Locked" ${formStatus eq 'Locked' ? 'selected' : ''}>Locked</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer" style="border-top:1px solid var(--c-outline-variant);">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
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
    <div class="modal-dialog modal-lg">
        <div class="modal-content" style="border-radius:var(--r-lg);border:1px solid var(--c-outline-variant);">
            <div class="modal-header" style="background:var(--pink-50);border-bottom:1px solid var(--pink-200);">
                <h5 class="modal-title" style="font-family:var(--font-display);font-weight:800;color:var(--c-primary-dark);">
                    <i class="bi bi-pencil-square me-2"></i>Sửa Người Dùng
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/users/" novalidate>
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="userId" id="editUserId" value="${editUserId}">
                <div class="modal-body">
                    <%-- Error summary cho lỗi chung --%>
                    <c:if test="${not empty editErrors['general']}">
                        <div class="alert alert-danger py-2 mb-3 d-flex align-items-center gap-2">
                            <i class="bi bi-exclamation-triangle-fill flex-shrink-0"></i>
                            <span>${editErrors['general']}</span>
                        </div>
                    </c:if>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Họ tên <span class="text-danger">*</span></label>
                            <input type="text" name="fullName" id="editFullName" class="form-control ${not empty editErrors['fullName'] ? 'is-invalid' : ''}"
                                   required maxlength="100" value="${fn:escapeXml(formEditFullName)}">
                            <c:if test="${not empty editErrors['fullName']}">
                                <div class="invalid-feedback">${editErrors['fullName']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Email <span class="text-danger">*</span></label>
                            <input type="email" name="email" id="editEmail" class="form-control ${not empty editErrors['email'] ? 'is-invalid' : ''}"
                                   required maxlength="100" value="${fn:escapeXml(formEditEmail)}">
                            <small id="editEmailGoogleNote" class="form-text text-warning d-none" style="font-size:0.72rem;">
                                <i class="bi bi-google"></i> Tài khoản Google — thay đổi email có thể ảnh hưởng đến đăng nhập Google.
                            </small>
                            <c:if test="${not empty editErrors['email']}">
                                <div class="invalid-feedback">${editErrors['email']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên đăng nhập <span class="text-danger">*</span></label>
                            <input type="text" name="username" id="editUsername" class="form-control ${not empty editErrors['username'] ? 'is-invalid' : ''}"
                                   required minlength="4" maxlength="50" pattern="[a-zA-Z0-9_]+"
                                   placeholder="Ít nhất 4 ký tự, chỉ chữ/số/_"
                                   title="Tên đăng nhập phải có ít nhất 4 ký tự, chỉ được chứa chữ cái (a-z), số (0-9) và dấu gạch dưới (_)"
                                   value="${fn:escapeXml(formEditUsername)}">
                            <c:if test="${not empty editErrors['username']}">
                                <div class="invalid-feedback">${editErrors['username']}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Số điện thoại</label>
                            <input type="text" name="phone" id="editPhone" class="form-control"
                                   maxlength="20" placeholder="VD: 0912345678"
                                   value="${fn:escapeXml(formEditPhone)}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Vai trò</label>
                            <select name="roleId" id="editRoleId" class="form-select">
                                <c:forEach var="entry" items="${roleMap}">
                                    <option value="${entry.key}" ${not empty formEditRoleId ? (entry.key == formEditRoleId ? 'selected' : '') : ''}>${entry.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Trạng thái</label>
                            <select name="status" id="editStatus" class="form-select">
                                <option value="Active" ${formEditStatus eq 'Active' ? 'selected' : ''}>Active</option>
                                <option value="Inactive" ${formEditStatus eq 'Inactive' ? 'selected' : ''}>Inactive</option>
                                <option value="Locked" ${formEditStatus eq 'Locked' ? 'selected' : ''}>Locked</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer" style="border-top:1px solid var(--c-outline-variant);">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary-pink">
                        <i class="bi bi-check-lg me-1"></i>Lưu Thay Đổi
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
<%-- Sidebar toggle --%>
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });

<%-- Active sidebar link --%>
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        var link = links[i];
        if (link.href && link.href.indexOf('/admin/users') !== -1) {
            link.classList.add('active');
        }
    }
})();

<%-- Edit modal: dùng data-* attributes thay vì inline onclick để tránh lỗi escape ký tự đặc biệt --%>
document.querySelectorAll('.btn-edit-user').forEach(function(btn) {
    btn.addEventListener('click', function() {
        var ds = this.dataset;
        document.getElementById('editUserId').value     = ds.id;
        document.getElementById('editFullName').value   = ds.fullname;
        document.getElementById('editEmail').value      = ds.email || '';
        // Nếu username rỗng, tự động tạo từ email (phần trước dấu @)
        var username = ds.username || '';
        if (!username && ds.email) {
            username = ds.email.split('@')[0].replace(/[^a-zA-Z0-9_]/g, '_').toLowerCase();
        }
        document.getElementById('editUsername').value   = username;
        document.getElementById('editPhone').value      = ds.phone || '';
        document.getElementById('editRoleId').value     = ds.roleid;
        document.getElementById('editStatus').value     = ds.status;

        // Hiển thị/ẩn cảnh báo Google nếu user đăng nhập qua Google
        var googleNote = document.getElementById('editEmailGoogleNote');
        var emailInput = document.getElementById('editEmail');
        if (ds.authprovider === 'google') {
            if (googleNote) googleNote.classList.remove('d-none');
            emailInput.setAttribute('title', 'Tài khoản Google — chỉ đổi email khi thực sự cần thiết');
        } else {
            if (googleNote) googleNote.classList.add('d-none');
            emailInput.removeAttribute('title');
        }

        new bootstrap.Modal(document.getElementById('editUserModal')).show();
    });
});

<%-- Auto-show add user modal khi có lỗi validation (form submit thất bại) --%>
<c:if test="${showAddModal}">
(function() {
    var addModalEl = document.getElementById('addUserModal');
    if (addModalEl) {
        var addModal = new bootstrap.Modal(addModalEl);
        addModal.show();
    }
})();
</c:if>

<%-- Auto-show edit user modal khi có lỗi validation --%>
<c:if test="${showEditModal}">
(function() {
    var editModalEl = document.getElementById('editUserModal');
    if (editModalEl) {
        var editModal = new bootstrap.Modal(editModalEl);
        editModal.show();
    }
})();
</c:if>
</script>
</body>
</html>
