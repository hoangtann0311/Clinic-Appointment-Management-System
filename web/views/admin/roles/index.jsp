<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vai Trò & Phân Quyền — Admin CAMS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <%-- ============================================================
         CSS NỘI TUYẾN — Pink Rose Admin Theme
         ============================================================ --%>
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
    --shadow-xs: 0 1px 3px rgba(194,24,91,0.07);
    --shadow-sm: 0 2px 8px rgba(194,24,91,0.10);
    --shadow-md: 0 4px 20px rgba(194,24,91,0.13);
    --r-sm: 8px; --r-md: 12px; --r-lg: 16px; --r-pill: 999px;
    --t-fast: 0.15s ease; --t-normal: 0.25s ease;
    --font-display: 'Nunito', sans-serif;
    --font-body: 'Inter', sans-serif;
}
*, *::before, *::after { box-sizing: border-box; }
body, .btn, .form-control, .form-select, .table, .badge { font-family: var(--font-body); }
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

/* ── Alert ── */
.alert-pink { background: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; border-radius: var(--r-md); font-size: 0.875rem; }
.alert-pink-danger { background: #ffebee; color: #c62828; border: 1px solid #ffcdd2; border-radius: var(--r-md); font-size: 0.875rem; }

/* ── Role Tabs (Pill Nav) ── */
.role-tabs-wrapper { display: flex; flex-wrap: wrap; gap: 0.5rem; margin-bottom: 1.25rem; padding: 0.35rem; background: var(--c-surface); border-radius: var(--r-pill); border: 1px solid var(--c-outline-variant); box-shadow: var(--shadow-xs); overflow-x: auto; }
.role-tab-link { display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.55rem 1.1rem; border-radius: var(--r-pill); text-decoration: none; font-weight: 600; font-size: 0.85rem; color: var(--c-on-surface-var); transition: all var(--t-fast); white-space: nowrap; border: none; background: transparent; cursor: pointer; }
.role-tab-link:hover { background: var(--pink-50); color: var(--c-primary); }
.role-tab-link.active { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); color: #fff; box-shadow: 0 4px 12px rgba(233,30,140,0.3); }
.role-tab-icon { width: 28px; height: 28px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 0.8rem; background: rgba(233,30,140,0.12); color: var(--pink-600); font-weight: 800; }
.role-tab-link.active .role-tab-icon { background: rgba(255,255,255,0.25); color: #fff; }

/* ── Permission Card ── */
.permission-module-card { background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-lg); box-shadow: var(--shadow-xs); overflow: hidden; margin-bottom: 1rem; }
.permission-module-header { background: var(--pink-50); border-bottom: 1px solid var(--pink-200); padding: 0.75rem 1.25rem; display: flex; align-items: center; justify-content: space-between; cursor: pointer; user-select: none; transition: background var(--t-fast); }
.permission-module-header:hover { background: var(--pink-100); }
.permission-module-header h6 { font-family: var(--font-display); font-size: 0.88rem; font-weight: 800; color: var(--c-primary-dark); margin: 0; display: flex; align-items: center; gap: 0.5rem; }
.permission-module-header h6 i { color: var(--pink-500); font-size: 1rem; }
.permission-module-header .collapse-icon { color: var(--c-muted); font-size: 0.85rem; transition: transform var(--t-normal); }
.permission-module-header.collapsed .collapse-icon { transform: rotate(-90deg); }
.permission-module-body { padding: 0.75rem 1.25rem; }
.permission-check-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 0.4rem; }

/* ── Checkbox Styling ── */
.form-check.permission-check { display: flex; align-items: center; gap: 0.6rem; padding: 0.45rem 0.65rem; border-radius: var(--r-sm); transition: background var(--t-fast); cursor: pointer; margin: 0; }
.form-check.permission-check:hover { background: var(--pink-50); }
.form-check.permission-check .form-check-input { width: 18px; height: 18px; margin: 0; border: 2px solid var(--c-outline); cursor: pointer; flex-shrink: 0; }
.form-check.permission-check .form-check-input:checked { background-color: var(--pink-500); border-color: var(--pink-500); }
.form-check.permission-check .form-check-input:focus { box-shadow: 0 0 0 0.2rem rgba(233,30,140,0.2); }
.form-check.permission-check .form-check-label { font-size: 0.84rem; color: var(--c-on-surface); cursor: pointer; font-weight: 500; }
.permission-desc { font-size: 0.72rem; color: var(--c-muted); margin-left: 1.8rem; margin-top: -0.2rem; margin-bottom: 0.25rem; }

/* ── Select All Checkbox ── */
.select-all-check { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem; padding-bottom: 0.5rem; border-bottom: 1px dashed var(--c-outline-variant); }
.select-all-check .form-check-input { width: 16px; height: 16px; margin: 0; border: 2px solid var(--pink-300); cursor: pointer; }
.select-all-check .form-check-input:checked { background-color: var(--pink-500); border-color: var(--pink-500); }
.select-all-label { font-size: 0.78rem; font-weight: 700; color: var(--c-primary); cursor: pointer; }

/* ── Role Info Card ── */
.role-info-card { background: linear-gradient(135deg, var(--pink-700) 0%, var(--pink-500) 55%, var(--rose-400) 100%); border-radius: var(--r-lg); padding: 1.5rem 1.75rem; margin-bottom: 1.25rem; color: #fff; box-shadow: 0 4px 24px rgba(233,30,140,0.3); position: relative; overflow: hidden; }
.role-info-card::after { content: ''; position: absolute; top: -30px; right: -30px; width: 140px; height: 140px; border-radius: 50%; background: rgba(255,255,255,0.07); pointer-events: none; }
.role-info-card h4 { font-family: var(--font-display); font-weight: 900; font-size: 1.2rem; margin: 0 0 0.4rem; display: flex; align-items: center; gap: 0.5rem; position: relative; }
.role-info-card p { margin: 0; font-size: 0.85rem; opacity: 0.9; position: relative; }
.role-info-meta { display: flex; gap: 1rem; margin-top: 0.6rem; font-size: 0.78rem; position: relative; }
.role-info-meta span { display: flex; align-items: center; gap: 0.35rem; background: rgba(255,255,255,0.15); padding: 0.25rem 0.75rem; border-radius: var(--r-pill); border: 1px solid rgba(255,255,255,0.2); }

/* ── Save Bar ── */
.save-bar { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 0.75rem; margin-top: 1.5rem; padding: 1rem 1.25rem; background: var(--c-surface); border-radius: var(--r-lg); border: 1px solid var(--c-outline-variant); box-shadow: var(--shadow-sm); }
.save-bar .save-hint { font-size: 0.82rem; color: var(--c-muted); display: flex; align-items: center; gap: 0.4rem; }

/* ── Buttons ── */
.btn-primary-pink { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); color: #fff; border: none; font-weight: 700; border-radius: var(--r-sm); padding: 0.55rem 1.2rem; transition: all var(--t-fast); font-family: var(--font-body); }
.btn-primary-pink:hover { background: linear-gradient(135deg, var(--pink-600), var(--pink-700)); color: #fff; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(233,30,140,0.3); }
.btn-outline-pink { color: var(--pink-600); background: var(--c-surface); border: 1px solid var(--pink-300); font-weight: 600; border-radius: var(--r-sm); padding: 0.55rem 1.2rem; transition: all var(--t-fast); font-family: var(--font-body); }
.btn-outline-pink:hover { background: var(--pink-50); border-color: var(--pink-500); color: var(--pink-700); }
.btn-refresh { display: inline-flex; align-items: center; gap: 0.4rem; padding: 0.55rem 1.1rem; border-radius: var(--r-sm); font-size: 0.85rem; font-weight: 600; color: var(--c-primary); background: var(--pink-50); border: 1px solid var(--pink-200); cursor: pointer; transition: all var(--t-fast); font-family: var(--font-body); }
.btn-refresh:hover { background: var(--pink-100); border-color: var(--pink-300); transform: translateY(-1px); }
.btn-refresh i { transition: transform 0.4s ease; }
.btn-refresh:hover i { transform: rotate(180deg); }

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
    .permission-check-grid { grid-template-columns: 1fr; }
    .role-tabs-wrapper { border-radius: var(--r-md); }
    .role-tab-link { padding: 0.5rem 0.85rem; font-size: 0.8rem; }
}
@media (max-width: 767.98px) {
    .admin-main { padding: 1rem; }
    .admin-page-title { font-size: 1.4rem; }
    .role-info-card { padding: 1rem 1.25rem; }
    .save-bar { flex-direction: column; align-items: stretch; }
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

    <%-- Page Header --%>
    <div class="admin-page-header">
        <div class="admin-page-header-left">
            <h1 class="admin-page-title">Vai Trò & Phân Quyền</h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-shield-lock-fill"></i>
                Quản lý <strong>${fn:length(roles)}</strong> vai trò và phân quyền chi tiết cho từng vai trò
            </div>
        </div>
        <button class="btn-refresh" onclick="location.reload()">
            <i class="bi bi-arrow-clockwise"></i>
            Làm mới
        </button>
    </div>

    <%-- Alert messages --%>
    <c:if test="${not empty success}">
        <div class="alert alert-pink alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            <c:choose>
                <c:when test="${success eq 'updated'}">Đã cập nhật phân quyền thành công!</c:when>
                <c:otherwise>Thao tác thành công!</c:otherwise>
            </c:choose>
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-pink-danger alert-dismissible fade show d-flex align-items-center" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>${error}
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <%-- Role Tabs ── Pill Navigation --%>
    <div class="role-tabs-wrapper" role="tablist">
        <c:forEach var="role" items="${roles}">
            <a href="?tab=${role.id}" class="role-tab-link ${activeTab eq role.id.toString() ? 'active' : ''}"
               role="tab" data-role-id="${role.id}">
                <span class="role-tab-icon">
                    <c:choose>
                        <c:when test="${role.id eq 1}"><i class="bi bi-shield-fill"></i></c:when>
                        <c:when test="${role.id eq 2}"><i class="bi bi-heart-pulse-fill"></i></c:when>
                        <c:when test="${role.id eq 3}"><i class="bi bi-briefcase-fill"></i></c:when>
                        <c:when test="${role.id eq 4}"><i class="bi bi-person-workspace"></i></c:when>
                        <c:when test="${role.id eq 5}"><i class="bi bi-people-fill"></i></c:when>
                        <c:when test="${role.id eq 6}"><i class="bi bi-soundwave"></i></c:when>
                        <c:otherwise><i class="bi bi-person-fill"></i></c:otherwise>
                    </c:choose>
                </span>
                ${role.roleName}
            </a>
        </c:forEach>
    </div>

    <%-- Active Role Content --%>
    <c:forEach var="role" items="${roles}">
        <c:if test="${activeTab eq role.id.toString()}">

            <%-- Role Info Banner --%>
            <div class="role-info-card">
                <h4>
                    <i class="bi bi-person-badge-fill"></i>
                    ${role.roleName}
                </h4>
                <p>${not empty role.description ? role.description : 'Chưa có mô tả cho vai trò này.'}</p>
                <div class="role-info-meta">
                    <span><i class="bi bi-fingerprint"></i> ID: ${role.id}</span>
                    <span><i class="bi bi-check2-circle"></i>
                        <c:set var="permCount" value="0"/>
                        <c:forEach var="rid" items="${rolePermissionMap.keySet()}">
                            <c:if test="${rid eq role.id}">
                                <c:set var="permCount" value="${fn:length(rolePermissionMap[rid])}"/>
                            </c:if>
                        </c:forEach>
                        ${permCount} quyền được gán
                    </span>
                </div>
            </div>

            <%-- Permission Form --%>
            <form method="post" action="${pageContext.request.contextPath}/admin/roles/" id="permForm_${role.id}">
                <input type="hidden" name="action" value="updatePermissions">
                <input type="hidden" name="roleId" value="${role.id}">

                <%-- Permission Cards grouped by Module --%>
                <c:forEach var="entry" items="${permissionsByModule}">
                    <c:set var="moduleKey" value="${entry.key}"/>
                    <c:set var="modulePerms" value="${entry.value}"/>

                    <%-- Module display name --%>
                    <c:set var="moduleName" value="${moduleKey}"/>
                    <c:choose>
                        <c:when test="${moduleKey eq 'users'}"><c:set var="moduleName" value="Quản Lý Người Dùng"/><c:set var="moduleIcon" value="bi-people-fill"/></c:when>
                        <c:when test="${moduleKey eq 'appointments'}"><c:set var="moduleName" value="Quản Lý Lịch Hẹn"/><c:set var="moduleIcon" value="bi-calendar-check-fill"/></c:when>
                        <c:when test="${moduleKey eq 'medical_records'}"><c:set var="moduleName" value="Quản Lý Bệnh Án"/><c:set var="moduleIcon" value="bi-file-medical-fill"/></c:when>
                        <c:when test="${moduleKey eq 'prescriptions'}"><c:set var="moduleName" value="Quản Lý Đơn Thuốc"/><c:set var="moduleIcon" value="bi-capsule"/></c:when>
                        <c:when test="${moduleKey eq 'ultrasound'}"><c:set var="moduleName" value="Siêu Âm"/><c:set var="moduleIcon" value="bi-soundwave"/></c:when>
                        <c:when test="${moduleKey eq 'payments'}"><c:set var="moduleName" value="Thanh Toán"/><c:set var="moduleIcon" value="bi-cash-coin"/></c:when>
                        <c:when test="${moduleKey eq 'reports'}"><c:set var="moduleName" value="Báo Cáo & Thống Kê"/><c:set var="moduleIcon" value="bi-graph-up-arrow"/></c:when>
                        <c:when test="${moduleKey eq 'system'}"><c:set var="moduleName" value="Hệ Thống"/><c:set var="moduleIcon" value="bi-gear-fill"/></c:when>
                    </c:choose>

                    <div class="permission-module-card">
                        <div class="permission-module-header" onclick="toggleModule(this)" data-bs-toggle="collapse" data-bs-target="#module_${role.id}_${moduleKey}" aria-expanded="true">
                            <h6>
                                <i class="bi ${moduleIcon}"></i>
                                ${moduleName}
                                <span style="font-size:0.72rem;font-weight:500;color:var(--c-muted);">(${fn:length(modulePerms)} quyền)</span>
                            </h6>
                            <i class="bi bi-chevron-down collapse-icon"></i>
                        </div>
                        <div class="collapse show" id="module_${role.id}_${moduleKey}">
                            <div class="permission-module-body">
                                <%-- Select All checkbox for this module --%>
                                <div class="select-all-check">
                                    <input class="form-check-input module-select-all" type="checkbox"
                                           id="selectAll_${role.id}_${moduleKey}"
                                           data-role="${role.id}" data-module="${moduleKey}"
                                           onchange="toggleModuleCheckboxes(this)">
                                    <label class="select-all-label" for="selectAll_${role.id}_${moduleKey}">
                                        Chọn tất cả
                                    </label>
                                </div>

                                <div class="permission-check-grid">
                                    <c:forEach var="perm" items="${modulePerms}">
                                        <c:set var="isChecked" value="false"/>
                                        <c:forEach var="rid" items="${rolePermissionMap.keySet()}">
                                            <c:if test="${rid eq role.id}">
                                                <c:forEach var="pid" items="${rolePermissionMap[rid]}">
                                                    <c:if test="${pid eq perm.id}">
                                                        <c:set var="isChecked" value="true"/>
                                                    </c:if>
                                                </c:forEach>
                                            </c:if>
                                        </c:forEach>

                                        <div>
                                            <div class="form-check permission-check">
                                                <input class="form-check-input perm-checkbox"
                                                       type="checkbox"
                                                       name="permissionIds"
                                                       value="${perm.id}"
                                                       id="perm_${role.id}_${perm.id}"
                                                       data-role="${role.id}"
                                                       data-module="${moduleKey}"
                                                       ${isChecked ? 'checked' : ''}>
                                                <label class="form-check-label" for="perm_${role.id}_${perm.id}">
                                                    ${perm.permissionName}
                                                </label>
                                            </div>
                                            <c:if test="${not empty perm.description}">
                                                <div class="permission-desc">${perm.description}</div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <%-- Save Bar --%>
                <div class="save-bar">
                    <div class="save-hint">
                        <i class="bi bi-info-circle-fill"></i>
                        <span>Chọn quyền phù hợp cho vai trò <strong>${role.roleName}</strong>. Nhấn <strong>"Lưu Phân Quyền"</strong> để áp dụng thay đổi.</span>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-outline-pink" onclick="resetForm('${role.id}')">
                            <i class="bi bi-arrow-counterclockwise me-1"></i>Đặt Lại
                        </button>
                        <button type="submit" class="btn btn-primary-pink">
                            <i class="bi bi-shield-check me-1"></i>Lưu Phân Quyền
                        </button>
                    </div>
                </div>
            </form>

        </c:if>
    </c:forEach>

    <%-- Empty state when no roles --%>
    <c:if test="${empty roles}">
        <div class="admin-empty-state">
            <i class="bi bi-shield-exclamation"></i>
            <h5>Không có vai trò nào</h5>
            <p>Chưa có dữ liệu vai trò trong hệ thống. Vui lòng chạy script khởi tạo dữ liệu.</p>
        </div>
    </c:if>

</main>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
// ── Sidebar ──
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });

// ── Active sidebar link ──
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        if (links[i].href && links[i].href.indexOf('/admin/roles') !== -1) {
            links[i].classList.add('active');
        }
    }
})();

// ── Module collapse toggle ──
function toggleModule(header) {
    // Bootstrap collapse handles this automatically via data-bs-toggle
}

// ── "Select All" per module ──
function toggleModuleCheckboxes(selectAllCheckbox) {
    var roleId = selectAllCheckbox.getAttribute('data-role');
    var moduleKey = selectAllCheckbox.getAttribute('data-module');
    var checkboxes = document.querySelectorAll(
        '.perm-checkbox[data-role="' + roleId + '"][data-module="' + moduleKey + '"]'
    );
    for (var i = 0; i < checkboxes.length; i++) {
        checkboxes[i].checked = selectAllCheckbox.checked;
    }
}

// ── Auto-check "Select All" when all checkboxes in module are checked ──
document.addEventListener('DOMContentLoaded', function() {
    var selectAlls = document.querySelectorAll('.module-select-all');
    for (var i = 0; i < selectAlls.length; i++) {
        updateSelectAllState(selectAlls[i]);
    }
});

document.addEventListener('change', function(e) {
    if (e.target && e.target.classList.contains('perm-checkbox')) {
        var roleId = e.target.getAttribute('data-role');
        var moduleKey = e.target.getAttribute('data-module');
        var selectAll = document.getElementById('selectAll_' + roleId + '_' + moduleKey);
        if (selectAll) {
            updateSelectAllState(selectAll);
        }
    }
});

function updateSelectAllState(selectAllCheckbox) {
    var roleId = selectAllCheckbox.getAttribute('data-role');
    var moduleKey = selectAllCheckbox.getAttribute('data-module');
    var checkboxes = document.querySelectorAll(
        '.perm-checkbox[data-role="' + roleId + '"][data-module="' + moduleKey + '"]'
    );
    var allChecked = checkboxes.length > 0;
    for (var i = 0; i < checkboxes.length; i++) {
        if (!checkboxes[i].checked) {
            allChecked = false;
            break;
        }
    }
    selectAllCheckbox.checked = allChecked;
}

// ── Reset form to original state ──
function resetForm(roleId) {
    if (confirm('Bạn có chắc muốn đặt lại tất cả các lựa chọn? Các thay đổi chưa lưu sẽ bị mất.')) {
        location.reload();
    }
}

// ── Role tab click via JavaScript (for programmatic navigation) ──
document.querySelectorAll('.role-tab-link').forEach(function(tab) {
    tab.addEventListener('click', function(e) {
        // Allow default link behavior
    });
});
</script>
</body>
</html>
