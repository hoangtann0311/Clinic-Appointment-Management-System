<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Quản Trị Hệ Thống — CAMS Admin</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
          rel="stylesheet">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap"
          rel="stylesheet">

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>

    <!-- Admin CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <style>
/* ============================================================
   CAMS Admin — System Administration Dashboard v5.0
   Focus: User Management, RBAC, Security, Audit & Monitoring
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
    --c-primary-container: #ffe0ef;
    --c-on-bg:           #1f1117;
    --c-on-surface:      #2d1a25;
    --c-on-surface-var:  #5a3d4e;
    --c-muted:           #8a6070;
    --c-outline:         #e8c5d5;
    --c-outline-variant: #f5dfe9;

    --sb-bg:           #1a0a12;
    --sb-bg-mid:       #2d1020;
    --sb-bg-deep:      #0f0509;
    --sb-hover:        #3d1830;
    --sb-active-bg:    rgba(233,30,140,0.18);
    --sb-active-border:#e91e8c;
    --sb-text:         #f0d5e3;
    --sb-text-muted:   #a07085;
    --sb-border:       rgba(255,255,255,0.07);
    --sb-accent:       #ff80b3;

    --green-500: #10b981;  --green-100: #d1fae5;  --green-700: #065f46;
    --amber-500: #f59e0b;  --amber-100: #fef3c7;  --amber-700: #92400e;
    --blue-500:  #3b82f6;  --blue-100:  #dbeafe;  --blue-700:  #1e40af;
    --purple-500:#8b5cf6;  --purple-100:#ede9fe;  --purple-700:#5b21b6;
    --cyan-500:  #06b6d4;  --cyan-100:  #cffafe;  --cyan-700:  #155e75;
    --red-500:   #ef4444;  --red-100:   #fee2e2;  --red-700:   #991b1b;
    --teal-500:  #14b8a6;  --teal-100:  #ccfbf1;  --teal-700:  #115e59;

    --shadow-xs:   0 1px 3px rgba(194,24,91,0.07);
    --shadow-sm:   0 2px 8px rgba(194,24,91,0.10);
    --shadow-md:   0 4px 20px rgba(194,24,91,0.13);
    --shadow-lg:   0 8px 32px rgba(194,24,91,0.16);
    --shadow-pink: 0 4px 24px rgba(233,30,140,0.30);

    --r-sm: 8px; --r-md: 12px; --r-lg: 16px; --r-xl: 22px; --r-pill: 999px;
    --t-fast: 0.15s ease; --t-normal: 0.25s ease;
    --t-slow: 0.35s cubic-bezier(0.4,0,0.2,1);
    --font-display: 'Nunito', 'Be Vietnam Pro', sans-serif;
    --font-body:    'Inter', 'Be Vietnam Pro', sans-serif;
}

*, *::before, *::after { box-sizing: border-box; }
html { scroll-behavior: smooth; }

body, .btn, .form-control, .table, .badge, .card {
    font-family: var(--font-body);
}
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

/* ── TOP BAR ── */
.admin-topbar {
    position: fixed; top: 0; left: 0; right: 0;
    height: var(--topbar-h);
    background: var(--c-surface);
    border-bottom: 2px solid var(--pink-200);
    display: flex; align-items: center; justify-content: space-between;
    padding: 0 1.5rem; z-index: 1030;
    box-shadow: var(--shadow-xs);
}
.admin-topbar-left { display: flex; align-items: center; gap: 0.875rem; }
.admin-topbar-brand {
    font-family: var(--font-display);
    font-weight: 900; font-size: 1.3rem;
    color: var(--c-primary); text-decoration: none;
    display: flex; align-items: center; gap: 0.5rem; letter-spacing: -0.03em;
}
.admin-topbar-brand i {
    color: var(--pink-500); font-size: 1.5rem;
    filter: drop-shadow(0 0 6px rgba(233,30,140,0.4));
}
.admin-topbar-brand .brand-badge {
    font-family: var(--font-body); font-weight: 700; font-size: 0.65rem;
    color: var(--c-primary); background: var(--pink-100);
    padding: 3px 10px; border-radius: var(--r-pill);
    letter-spacing: 0.06em; text-transform: uppercase;
    border: 1px solid var(--pink-200);
}
.admin-sidebar-toggle {
    background: none; border: none;
    color: var(--c-on-surface-var); font-size: 1.5rem;
    cursor: pointer; padding: 6px 8px; border-radius: var(--r-sm);
    display: none; line-height: 1; transition: background var(--t-fast), color var(--t-fast);
}
.admin-sidebar-toggle:hover { background: var(--pink-100); color: var(--c-primary); }

.admin-topbar-right { display: flex; align-items: center; gap: 0.75rem; }

.topbar-date {
    font-size: 0.8rem; color: var(--c-muted);
    display: flex; align-items: center; gap: 0.35rem;
    padding: 0.35rem 0.75rem;
    background: var(--c-surface-variant);
    border-radius: var(--r-pill);
    border: 1px solid var(--c-outline-variant);
}
.topbar-date i { color: var(--pink-400); font-size: 0.9rem; }

.admin-topbar-user {
    display: flex; align-items: center; gap: 0.6rem;
    padding: 0.375rem 0.875rem;
    background: var(--pink-50);
    border-radius: var(--r-pill);
    border: 1px solid var(--pink-200);
    cursor: pointer; position: relative;
}
.admin-topbar-user span { font-size: 0.875rem; font-weight: 600; color: var(--c-primary-dark); }
.admin-avatar-sm {
    width: 34px; height: 34px; border-radius: 50%;
    background: linear-gradient(135deg, var(--pink-500), var(--rose-400));
    color: #fff; display: flex; align-items: center; justify-content: center;
    font-weight: 800; font-size: 0.85rem; text-transform: uppercase; flex-shrink: 0;
    box-shadow: 0 2px 8px rgba(233,30,140,0.35);
}
.admin-topbar-role {
    font-size: 0.62rem; font-weight: 700; padding: 2px 8px;
    border-radius: var(--r-pill);
    background: linear-gradient(135deg, var(--pink-500), var(--rose-500));
    color: #fff; letter-spacing: 0.05em; text-transform: uppercase;
}
.admin-topbar-logout {
    color: var(--c-on-surface-var); text-decoration: none;
    font-size: 0.85rem; font-weight: 600;
    display: flex; align-items: center; gap: 0.4rem;
    padding: 0.45rem 0.875rem; border-radius: var(--r-sm);
    transition: all var(--t-fast); border: 1px solid transparent;
}
.admin-topbar-logout:hover {
    background: var(--pink-50); color: var(--rose-600); border-color: var(--pink-200);
}

/* ── SIDEBAR ── */
.admin-sidebar {
    position: fixed; top: var(--topbar-h); left: 0; bottom: 0;
    width: var(--sidebar-w);
    background: linear-gradient(180deg, var(--sb-bg) 0%, var(--sb-bg-mid) 50%, var(--sb-bg-deep) 100%);
    overflow-y: auto; overflow-x: hidden;
    z-index: 1020; transition: transform var(--t-slow);
    border-right: 1px solid var(--sb-border);
}
.admin-sidebar::-webkit-scrollbar { width: 3px; }
.admin-sidebar::-webkit-scrollbar-thumb { background: rgba(255,128,179,0.25); border-radius: 3px; }
.admin-sidebar::before {
    content: ''; display: block; height: 3px;
    background: linear-gradient(90deg, var(--pink-500), var(--rose-400), transparent);
}
.admin-sidebar-user {
    padding: 1.5rem 1.25rem 1.25rem; text-align: center;
    border-bottom: 1px solid var(--sb-border);
    background: linear-gradient(180deg, rgba(233,30,140,0.08) 0%, transparent 100%);
}
.admin-sidebar-avatar {
    width: 62px; height: 62px; border-radius: 50%;
    background: linear-gradient(135deg, var(--pink-400), var(--pink-600));
    color: #fff; display: inline-flex; align-items: center; justify-content: center;
    font-family: var(--font-display); font-weight: 900; font-size: 1.4rem;
    text-transform: uppercase; margin-bottom: 0.75rem;
    box-shadow: 0 0 0 3px rgba(233,30,140,0.2), var(--shadow-pink);
}
.admin-sidebar-name {
    font-family: var(--font-display); color: #f5e0ea;
    font-weight: 700; font-size: 0.9rem; margin-bottom: 0.4rem;
}
.admin-sidebar-badge {
    display: inline-flex; align-items: center; gap: 0.3rem;
    font-size: 0.63rem; font-weight: 700; padding: 3px 12px;
    border-radius: var(--r-pill);
    background: linear-gradient(135deg, var(--pink-600), var(--pink-500));
    color: #fff; letter-spacing: 0.05em; text-transform: uppercase;
}
.admin-sidebar-menu { list-style: none; padding: 0.75rem 0 1rem; margin: 0; }
.admin-sidebar-section {
    font-family: var(--font-body); font-size: 0.62rem; font-weight: 700;
    letter-spacing: 0.1em; text-transform: uppercase;
    color: var(--sb-text-muted); padding: 1rem 1.25rem 0.4rem; margin-top: 0.25rem;
}
.admin-sidebar-menu li a {
    display: flex; align-items: center; gap: 0.75rem;
    padding: 0.65rem 1.25rem;
    color: var(--sb-text); text-decoration: none;
    font-size: 0.875rem; font-weight: 500;
    border-left: 3px solid transparent;
    transition: all var(--t-fast); margin: 1px 0;
}
.admin-sidebar-menu li a i { font-size: 1rem; width: 20px; text-align: center; color: var(--sb-text-muted); flex-shrink: 0; transition: color var(--t-fast); }
.admin-sidebar-menu li a:hover { background: var(--sb-hover); color: #fff; border-left-color: var(--pink-400); padding-left: 1.5rem; }
.admin-sidebar-menu li a:hover i { color: var(--sb-accent); }
.admin-sidebar-menu li a.active { background: var(--sb-active-bg); color: var(--sb-accent); border-left-color: var(--pink-500); font-weight: 700; }
.admin-sidebar-menu li a.active i { color: var(--pink-300); }
.admin-sidebar-menu li a.disabled { opacity: 0.4; pointer-events: none; }

/* ── MAIN ── */
.admin-main {
    margin-left: var(--sidebar-w); margin-top: var(--topbar-h);
    padding: 2rem 2.25rem;
    min-height: calc(100vh - var(--topbar-h));
}
.admin-page-header {
    display: flex; align-items: flex-start; justify-content: space-between;
    flex-wrap: wrap; gap: 1rem; margin-bottom: 1.5rem;
}
.admin-page-title {
    font-family: var(--font-display); font-size: 1.85rem; font-weight: 900;
    color: var(--c-on-bg); margin: 0 0 0.25rem; letter-spacing: -0.04em;
}
.admin-page-subtitle {
    font-size: 0.85rem; color: var(--c-muted);
    display: flex; align-items: center; gap: 0.4rem;
}
.btn-refresh {
    display: inline-flex; align-items: center; gap: 0.4rem;
    padding: 0.55rem 1.1rem; border-radius: var(--r-sm);
    font-size: 0.85rem; font-weight: 600;
    color: var(--c-primary); background: var(--pink-50);
    border: 1px solid var(--pink-200); cursor: pointer;
    transition: all var(--t-fast); font-family: var(--font-body);
}
.btn-refresh:hover { background: var(--pink-100); border-color: var(--pink-300); transform: translateY(-1px); }
.btn-refresh i { transition: transform 0.4s ease; }
.btn-refresh:hover i { transform: rotate(180deg); }

/* ── Welcome Banner ── */
.admin-welcome-banner {
    background: linear-gradient(135deg, var(--pink-700) 0%, var(--pink-500) 55%, var(--rose-400) 100%);
    border-radius: var(--r-lg); padding: 1.5rem 2rem; margin-bottom: 1.75rem;
    display: flex; align-items: center; justify-content: space-between;
    flex-wrap: wrap; gap: 1rem; position: relative; overflow: hidden;
    box-shadow: var(--shadow-pink);
}
.admin-welcome-banner::before {
    content: ''; position: absolute; top: -40px; right: -40px;
    width: 180px; height: 180px; border-radius: 50%;
    background: rgba(255,255,255,0.07); pointer-events: none;
}
.admin-welcome-banner::after {
    content: ''; position: absolute; bottom: -60px; right: 80px;
    width: 220px; height: 220px; border-radius: 50%;
    background: rgba(255,255,255,0.05); pointer-events: none;
}
.admin-welcome-banner .welcome-left { position: relative; z-index: 1; }
.admin-welcome-banner h2 {
    font-family: var(--font-display); color: #fff; font-size: 1.35rem;
    font-weight: 900; margin: 0 0 0.4rem;
    display: flex; align-items: center; gap: 0.5rem;
}
.admin-welcome-banner p { color: rgba(255,255,255,0.88); margin: 0; font-size: 0.88rem; }
.badge-role {
    display: inline-flex; align-items: center; gap: 0.4rem;
    padding: 0.45rem 1rem; border-radius: var(--r-pill);
    background: rgba(255,255,255,0.2); color: #fff;
    font-size: 0.8rem; font-weight: 700;
    border: 1px solid rgba(255,255,255,0.3); backdrop-filter: blur(4px);
    position: relative; z-index: 1;
}

/* ── KPI Cards — System Admin color variants ── */
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

/* Color-coded KPI cards */
.kpi-accounts     .card-body { border-top: 3px solid var(--purple-500) !important; }
.kpi-accounts     .kpi-icon { background: var(--purple-100); color: var(--purple-500); }
.kpi-active       .card-body { border-top: 3px solid var(--green-500) !important; }
.kpi-active       .kpi-icon { background: var(--green-100); color: var(--green-500); }
.kpi-locked       .card-body { border-top: 3px solid var(--red-500) !important; }
.kpi-locked       .kpi-icon { background: var(--red-100); color: var(--red-500); }
.kpi-unverified   .card-body { border-top: 3px solid var(--amber-500) !important; }
.kpi-unverified   .kpi-icon { background: var(--amber-100); color: var(--amber-500); }
.kpi-roles        .card-body { border-top: 3px solid var(--cyan-500) !important; }
.kpi-roles        .kpi-icon { background: var(--cyan-100); color: var(--cyan-500); }
.kpi-permissions  .card-body { border-top: 3px solid var(--teal-500) !important; }
.kpi-permissions  .kpi-icon { background: var(--teal-100); color: var(--teal-500); }
.kpi-logins       .card-body { border-top: 3px solid var(--blue-500) !important; }
.kpi-logins       .kpi-icon { background: var(--blue-100); color: var(--blue-500); }
.kpi-audit        .card-body { border-top: 3px solid var(--purple-500) !important; }
.kpi-audit        .kpi-icon { background: var(--purple-100); color: var(--purple-500); }

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

/* ── Chart Containers ── */
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
.badge-active    { background: #d1fae5; color: #065f46; }
.badge-inactive  { background: #f3f4f6; color: #6b7280; }
.badge-locked    { background: #fee2e2; color: #991b1b; }
.badge-pending   { background: #fef3c7; color: #92400e; }

/* ── System Alerts ── */
.alert-item {
    display: flex; align-items: flex-start; gap: 0.75rem;
    padding: 0.75rem; border-radius: var(--r-md);
    margin-bottom: 0.5rem;
    transition: background var(--t-fast);
}
.alert-item:last-child { margin-bottom: 0; }
.alert-item.danger  { background: #fef2f2; border: 1px solid #fecaca; }
.alert-item.warning { background: #fffbeb; border: 1px solid #fde68a; }
.alert-item.info   { background: #eff6ff; border: 1px solid #bfdbfe; }
.alert-item .alert-icon {
    width: 36px; height: 36px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 1rem; flex-shrink: 0;
}
.alert-item.danger  .alert-icon { background: #fee2e2; color: #dc2626; }
.alert-item.warning .alert-icon { background: #fef3c7; color: #d97706; }
.alert-item.info   .alert-icon { background: #dbeafe; color: #2563eb; }
.alert-item .alert-body { flex: 1; min-width: 0; }
.alert-item .alert-title { font-size: 0.8rem; font-weight: 700; color: var(--c-on-surface); margin-bottom: 2px; }
.alert-item .alert-msg { font-size: 0.75rem; color: var(--c-muted); }
.alert-item .alert-count {
    font-family: var(--font-display); font-size: 1.1rem; font-weight: 900;
    padding: 0.25rem 0.6rem; border-radius: var(--r-pill); flex-shrink: 0;
}
.alert-item.danger  .alert-count { background: #fecaca; color: #991b1b; }
.alert-item.warning .alert-count { background: #fde68a; color: #92400e; }
.alert-item.info   .alert-count { background: #bfdbfe; color: #1e40af; }

/* Audit action type badges */
.badge-action {
    display: inline-block; padding: 2px 8px; border-radius: var(--r-pill);
    font-size: 0.65rem; font-weight: 700; white-space: nowrap;
}
.badge-action.LOGIN  { background: #dbeafe; color: #1e40af; }
.badge-action.CREATE { background: #d1fae5; color: #065f46; }
.badge-action.UPDATE { background: #fef3c7; color: #92400e; }
.badge-action.DELETE { background: #fee2e2; color: #991b1b; }
.badge-action.DENIED { background: #fce4ec; color: #c62828; }
.badge-action.EXPORT { background: #ede9fe; color: #5b21b6; }
.badge-action.APPROVE{ background: #cffafe; color: #155e75; }
.badge-action.TOGGLE { background: #fff3e0; color: #e65100; }
.badge-action.OTHER  { background: #f3f4f6; color: #6b7280; }

/* ── Empty State ── */
.admin-empty-state { text-align: center; padding: 2.5rem 1rem; color: var(--c-muted); }
.admin-empty-state i { font-size: 2.5rem; color: var(--pink-200); display: block; margin-bottom: 0.75rem; }
.admin-empty-state h6 { font-family: var(--font-display); font-weight: 700; color: var(--c-on-surface-var); margin-bottom: 0.25rem; }
.admin-empty-state p { font-size: 0.85rem; margin: 0; }

/* ── Sidebar Backdrop ── */
.admin-sidebar-backdrop { display: none; position: fixed; inset: 0; background: rgba(26,10,18,0.5); z-index: 1015; backdrop-filter: blur(3px); animation: fadeBackdrop 0.2s ease; }
@keyframes fadeBackdrop { from { opacity: 0; } to { opacity: 1; } }
.admin-sidebar-backdrop.show { display: block; }

/* ── Animations ── */
@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(14px); }
    to   { opacity: 1; transform: translateY(0); }
}
.fade-in-up { animation: fadeInUp 0.4s ease forwards; }

/* ── Inline Date Filter ── */
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

/* ── System Info List ── */
.system-info-list { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 0.35rem; }

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

/* ── Responsive ── */
@media (max-width: 1199.98px) {
    .kpi-card .card-body { padding: 1rem !important; gap: 0.75rem !important; }
    .kpi-value { font-size: 1.4rem; }
    .kpi-icon { width: 42px; height: 42px; font-size: 1.1rem; }
    .header-date-filter { margin-top: 0.5rem; }
    .header-date-filter .date-input-group input[type="date"] { width: 110px; font-size: 0.73rem; }
}
@media (max-width: 991.98px) {
    .admin-sidebar-toggle { display: inline-flex; }
    .admin-sidebar { transform: translateX(-100%); box-shadow: none; }
    .admin-sidebar.show { transform: translateX(0); box-shadow: var(--shadow-lg); }
    .admin-main { margin-left: 0; }
}
@media (max-width: 767.98px) {
    .admin-main { padding: 1rem; }
    .admin-page-title { font-size: 1.4rem; }
    .admin-welcome-banner { padding: 1.25rem 1.5rem; }
    .topbar-date { display: none; }
    .kpi-value { font-size: 1.25rem; }
    .header-date-filter { flex-direction: column; align-items: stretch; width: 100%; }
    .header-date-filter .date-input-group { justify-content: space-between; }
    .header-date-filter .date-input-group input[type="date"] { flex: 1; }
    .header-date-filter .date-separator { display: none; }
}
@media (max-width: 575.98px) {
    .admin-topbar { padding: 0 0.875rem; }
    .admin-topbar-brand .brand-badge { display: none; }
    .admin-main { padding: 0.75rem; }
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
        <%-- Ngày hiện tại --%>
        <div class="topbar-date d-none d-lg-flex">
            <i class="bi bi-calendar3"></i>
            ${not empty todayDisplay ? todayDisplay : 'Hôm nay'}
        </div>

        <%-- Thông tin người dùng --%>
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">
                ${fn:substring(sessionScope.user.fullName, 0, 1)}
            </div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role">
                <i class="bi bi-shield-check me-1"></i>Admin
            </span>
        </div>

        <%-- Đăng xuất --%>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout" title="Đăng xuất">
            <i class="bi bi-box-arrow-right"></i>
            <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
    </div>
</nav>

<%-- ── SIDEBAR ── --%>
<%@ include file="layout/sidebar.jsp" %>

<%-- ── MAIN CONTENT ── --%>
<main class="admin-main" id="adminMain">

    <%-- Page Header — với Date Filter tích hợp ── --%>
    <div class="admin-page-header">
        <div class="admin-page-header-left" style="flex:1; min-width:0;">
            <h1 class="admin-page-title">
                <i class="bi bi-shield-lock-fill me-2" style="color:var(--pink-500);"></i>Quản Trị Hệ Thống
            </h1>
            <div style="display:flex; align-items:center; flex-wrap:wrap; gap:0.75rem;">
                <div class="admin-page-subtitle" style="margin-bottom:0;">
                    <i class="bi bi-calendar3"></i>
                    ${not empty subtitleDisplay ? subtitleDisplay : 'Hôm nay'}
                    <span class="mx-2">&middot;</span>
                    <i class="bi bi-cpu"></i>
                    <c:choose>
                        <c:when test="${isCustomRange}">Dữ liệu trong khoảng đã chọn</c:when>
                        <c:otherwise>Giám sát hệ thống toàn diện</c:otherwise>
                    </c:choose>
                </div>
                <%-- Inline Date Filter --%>
                <form method="get" action="${pageContext.request.contextPath}/admin/dashboard" class="header-date-filter">
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
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn-header-date btn-header-today" title="Về thời gian thực">
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

    <%-- Welcome Banner — System Admin --%>
    <div class="admin-welcome-banner">
        <div class="welcome-left">
            <h2>
                <i class="bi bi-shield-shaded"></i>
                Xin chào, ${sessionScope.user.fullName}!
            </h2>
            <p>Trung tâm quản trị hệ thống CAMS — giám sát người dùng, phân quyền, bảo mật và hoạt động toàn hệ thống.</p>
        </div>
        <span class="badge-role">
            <i class="bi bi-person-badge-fill"></i>
            Quản Trị Viên Hệ Thống
        </span>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- 8 KPI CARDS — System Administration --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- 1. Tổng số tài khoản --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/admin/users/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-accounts fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-people-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalAccounts ? totalAccounts : 0}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Tài Khoản Mới (Khoảng)</c:when>
                                <c:otherwise>Tổng Tài Khoản</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-database"></i> <c:choose><c:when test="${isCustomRange}">${dateRangeLabel}</c:when><c:otherwise>Toàn hệ thống</c:otherwise></c:choose></div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 2. Tài khoản đang hoạt động --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/admin/users/?status=Active" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-active fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-check-circle-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty activeAccounts ? activeAccounts : 0}</div>
                        <div class="kpi-label">Tài Khoản Đang Hoạt Động</div>
                        <div class="kpi-sub"><i class="bi bi-shield-check"></i> Trạng thái Active</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 3. Tài khoản bị khóa --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/admin/users/?status=LOCKED" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-locked fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-lock-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value" style="${lockedAccounts > 0 ? 'color:#dc2626;' : ''}">${not empty lockedAccounts ? lockedAccounts : 0}</div>
                        <div class="kpi-label">Tài Khoản Bị Khóa</div>
                        <div class="kpi-sub"><i class="bi bi-exclamation-triangle"></i> Cần xem xét</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 4. Tài khoản chưa xác thực --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/admin/users/?status=PENDING_VERIFICATION" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-unverified fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-envelope-exclamation"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value" style="${unverifiedAccounts > 0 ? 'color:#d97706;' : ''}">${not empty unverifiedAccounts ? unverifiedAccounts : 0}</div>
                        <div class="kpi-label">Chưa Xác Thực Email</div>
                        <div class="kpi-sub"><i class="bi bi-hourglass-split"></i> Đang chờ xác nhận</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 5. Tổng số vai trò (Role) --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/admin/roles/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-roles fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-shield-lock-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalRoles ? totalRoles : 0}</div>
                        <div class="kpi-label">Vai Trò (Roles)</div>
                        <div class="kpi-sub"><i class="bi bi-person-badge"></i> Phân quyền hệ thống</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 6. Tổng số quyền (Permission) --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/admin/roles/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-permissions fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-key-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalPermissions ? totalPermissions : 0}</div>
                        <div class="kpi-label">Quyền (Permissions)</div>
                        <div class="kpi-sub"><i class="bi bi-gear"></i> Kiểm soát truy cập</div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 7. Đăng nhập hôm nay --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/admin/audit-logs/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-logins fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-box-arrow-in-right"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty loginsToday ? loginsToday : 0}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Đăng Nhập (Khoảng)</c:when>
                                <c:otherwise>Đăng Nhập Hôm Nay</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-activity"></i> <c:choose><c:when test="${isCustomRange}">${dateRangeLabel}</c:when><c:otherwise>Lượt truy cập</c:otherwise></c:choose></div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <%-- 8. Audit Log hôm nay --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <a href="${pageContext.request.contextPath}/admin/audit-logs/" style="text-decoration:none;color:inherit;">
            <div class="card kpi-card kpi-audit fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-clipboard-data-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty auditLogsToday ? auditLogsToday : 0}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Audit Log (Khoảng)</c:when>
                                <c:otherwise>Audit Log Hôm Nay</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-journal-check"></i> <c:choose><c:when test="${isCustomRange}">${dateRangeLabel}</c:when><c:otherwise>Bản ghi hoạt động</c:otherwise></c:choose></div>
                    </div>
                </div>
            </div>
            </a>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- CẢNH BÁO HỆ THỐNG (System Alerts) --%>
    <%-- ════════════════════════════════════════════ --%>
    <c:if test="${not empty systemAlerts}">
    <div class="row mb-4">
        <div class="col-12">
            <div class="admin-card">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-exclamation-diamond-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Cảnh Báo Hệ Thống (${dateRangeLabel})</c:when>
                            <c:otherwise>Cảnh Báo &amp; An Ninh Hệ Thống</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body p-3">
                    <div class="row g-2">
                        <c:forEach var="alert" items="${systemAlerts}">
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
    <%-- BIỂU ĐỒ HÀNG 1: Xu hướng đăng nhập + Tăng trưởng tài khoản --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Biểu đồ xu hướng đăng nhập (Line) --%>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-graph-up-arrow"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Xu Hướng Đăng Nhập (${dateRangeLabel})</c:when>
                            <c:otherwise>Xu Hướng Đăng Nhập 7 Ngày Qua</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${hasLoginTrendData}">
                            <div class="chart-container">
                                <canvas id="loginTrendChart" height="280"></canvas>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state py-4">
                                <i class="bi bi-graph-up" style="font-size:2rem;color:var(--pink-200);"></i>
                                <p class="mt-2 mb-0" style="color:var(--c-muted);">Chưa có dữ liệu đăng nhập trong khoảng này</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Biểu đồ tăng trưởng tài khoản (Bar) --%>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-bar-chart-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Tăng Trưởng Tài Khoản (${dateRangeLabel})</c:when>
                            <c:otherwise>Tăng Trưởng Tài Khoản 12 Tháng</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${hasAccountGrowthData}">
                            <div class="chart-container">
                                <canvas id="accountGrowthChart" height="280"></canvas>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state py-4">
                                <i class="bi bi-bar-chart" style="font-size:2rem;color:var(--pink-200);"></i>
                                <p class="mt-2 mb-0" style="color:var(--c-muted);">Chưa có dữ liệu tài khoản trong khoảng này</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- BIỂU ĐỒ HÀNG 2: Phân bố vai trò + Phân loại Audit Log --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Biểu đồ phân bố vai trò (Doughnut) --%>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-pie-chart-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Phân Bố Người Dùng Theo Vai Trò (${dateRangeLabel})</c:when>
                            <c:otherwise>Phân Bố Người Dùng Theo Vai Trò</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${hasRoleDistData}">
                            <div class="chart-container">
                                <canvas id="roleDistributionChart" height="280"></canvas>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state py-4">
                                <i class="bi bi-pie-chart" style="font-size:2rem;color:var(--pink-200);"></i>
                                <p class="mt-2 mb-0" style="color:var(--c-muted);">
                                    <c:choose>
                                        <c:when test="${isCustomRange}">Chưa có dữ liệu người dùng trong khoảng này</c:when>
                                        <c:otherwise>Chưa có dữ liệu người dùng</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Biểu đồ phân loại Audit Log (Doughnut) --%>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-diagram-3-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Phân Loại Hoạt Động (${dateRangeLabel})</c:when>
                            <c:otherwise>Phân Loại Hoạt Động Hệ Thống</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${hasAuditClassData}">
                            <div class="chart-container">
                                <canvas id="auditClassChart" height="280"></canvas>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state py-4">
                                <i class="bi bi-diagram-3" style="font-size:2rem;color:var(--pink-200);"></i>
                                <p class="mt-2 mb-0" style="color:var(--c-muted);">Chưa có hoạt động nào trong khoảng này</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- HÀNG BẢNG: Người dùng mới nhất + Audit Log gần đây (full-width) --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Người dùng mới nhất --%>
        <div class="col-12">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5>
                        <i class="bi bi-person-plus-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Người Dùng Mới (${dateRangeLabel})</c:when>
                            <c:otherwise>Người Dùng Mới Nhất</c:otherwise>
                        </c:choose>
                    </h5>
                    <a href="${pageContext.request.contextPath}/admin/users/"
                       style="font-size:0.78rem;font-weight:700;color:var(--pink-500);text-decoration:none;">
                        Quản lý người dùng →
                    </a>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty recentUsers}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead>
                                        <tr>
                                            <th>STT</th>
                                            <th>Họ Tên</th>
                                            <th>Email</th>
                                            <th>Vai Trò</th>
                                            <th>Trạng Thái</th>
                                            <th>Ngày Tạo</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="ru" items="${recentUsers}" varStatus="row">
                                            <tr>
                                                <td style="color:var(--c-muted);font-size:0.78rem;">${row.count}</td>
                                                <td style="font-weight:600;">${ru.fullName}</td>
                                                <td style="font-size:0.78rem;">${ru.email}</td>
                                                <td><span class="badge-role-tag" style="display:inline-block;padding:2px 10px;border-radius:var(--r-pill);font-size:0.7rem;font-weight:700;background:var(--pink-100);color:var(--pink-700);border:1px solid var(--pink-200);">${ru.roleName}</span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${ru.status == 'Active'}"><span class="badge-status badge-active">Active</span></c:when>
                                                        <c:when test="${ru.status == 'LOCKED'}"><span class="badge-status badge-locked">Khóa</span></c:when>
                                                        <c:when test="${ru.status == 'PENDING_VERIFICATION'}"><span class="badge-status badge-pending">Chờ XT</span></c:when>
                                                        <c:otherwise><span class="badge-status badge-inactive">${ru.status}</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="color:var(--c-muted);font-size:0.78rem;white-space:nowrap;">${ru.createdAt}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-people"></i>
                                <h6>Chưa có người dùng mới</h6>
                                <p>Người dùng mới đăng ký sẽ hiển thị ở đây.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Audit Log gần đây --%>
        <div class="col-12">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5>
                        <i class="bi bi-clipboard-data-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Nhật Ký Hệ Thống (${dateRangeLabel})</c:when>
                            <c:otherwise>Nhật Ký Hệ Thống Gần Đây</c:otherwise>
                        </c:choose>
                    </h5>
                    <a href="${pageContext.request.contextPath}/admin/audit-logs/"
                       style="font-size:0.78rem;font-weight:700;color:var(--pink-500);text-decoration:none;">
                        Xem tất cả →
                    </a>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty recentAuditLogs}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead>
                                        <tr>
                                            <th>Người Dùng</th>
                                            <th>Vai Trò</th>
                                            <th>Hành Động</th>
                                            <th>Loại</th>
                                            <th>Thời Gian</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="log" items="${recentAuditLogs}">
                                            <tr>
                                                <td style="font-weight:600;">${log.userName}</td>
                                                <td style="font-size:0.75rem;color:var(--c-muted);">${log.roleName}</td>
                                                <td>
                                                    <div style="font-size:0.8rem;max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="${fn:escapeXml(log.action)}">
                                                        ${log.action}
                                                    </div>
                                                </td>
                                                <td><span class="badge-action ${log.actionType}">${log.actionType}</span></td>
                                                <td style="color:var(--c-muted);font-size:0.75rem;white-space:nowrap;">${log.createdAt}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-clipboard"></i>
                                <h6>Chưa có nhật ký</h6>
                                <p>Hoạt động hệ thống sẽ được ghi lại ở đây.</p>
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

<%-- ════════════════════════════════════════════ --%>
<%-- QUICK RANGE + SIDEBAR SCRIPTS --%>
<%-- ════════════════════════════════════════════ --%>
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

var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeSidebar();
});

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
</script>

<%-- ════════════════════════════════════════════ --%>
<%-- CHART.JS INITIALIZATION — System Admin Charts --%>
<%-- ════════════════════════════════════════════ --%>
<script>
(function() {
    var pink500 = '#e91e8c';
    var pink200 = '#ffb3d1';

    // ── 1. Login Trend Chart (Line) ──
    var loginCtx = document.getElementById('loginTrendChart');
    if (loginCtx) {
        new Chart(loginCtx, {
            type: 'line',
            data: {
                labels: [
                    <c:forEach var="lbl" items="${loginTrendLabels}" varStatus="s">
                        '${lbl}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Lượt đăng nhập',
                    data: [
                        <c:forEach var="val" items="${loginTrendValues}" varStatus="s">
                            ${val}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    borderColor: '#3b82f6',
                    backgroundColor: 'rgba(59,130,246,0.08)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#3b82f6',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1, font: { size: 11 } },
                        grid: { color: '#f5dfe9' }
                    },
                    x: {
                        ticks: { font: { size: 11 } },
                        grid: { display: false }
                    }
                }
            }
        });
    }

    // ── 2. Account Growth Chart (Bar) ──
    var growthCtx = document.getElementById('accountGrowthChart');
    if (growthCtx) {
        new Chart(growthCtx, {
            type: 'bar',
            data: {
                labels: [
                    <c:forEach var="lbl" items="${accountGrowthLabels}" varStatus="s">
                        '${lbl}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Tài khoản mới',
                    data: [
                        <c:forEach var="val" items="${accountGrowthValues}" varStatus="s">
                            ${val}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    backgroundColor: '#8b5cf6',
                    borderRadius: 6,
                    hoverBackgroundColor: '#a78bfa'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1, font: { size: 11 } },
                        grid: { color: '#f5dfe9' }
                    },
                    x: {
                        ticks: { font: { size: 11 } },
                        grid: { display: false }
                    }
                }
            }
        });
    }

    // ── 3. Role Distribution Chart (Doughnut) ──
    var roleDistCtx = document.getElementById('roleDistributionChart');
    if (roleDistCtx) {
        new Chart(roleDistCtx, {
            type: 'doughnut',
            data: {
                labels: [
                    <c:forEach var="lbl" items="${roleDistributionLabels}" varStatus="s">
                        '${lbl}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    data: [
                        <c:forEach var="val" items="${roleDistributionValues}" varStatus="s">
                            ${val}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    backgroundColor: [
                        '#e91e8c', '#3b82f6', '#10b981', '#f59e0b', '#8b5cf6', '#ef4444', '#06b6d4'
                    ],
                    borderColor: '#fff',
                    borderWidth: 2.5,
                    hoverOffset: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '55%',
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 14,
                            usePointStyle: true,
                            pointStyleWidth: 8,
                            font: { size: 11 }
                        }
                    }
                }
            }
        });
    }

    // ── 4. Audit Log Classification Chart (Doughnut) ──
    var auditClassCtx = document.getElementById('auditClassChart');
    if (auditClassCtx) {
        new Chart(auditClassCtx, {
            type: 'doughnut',
            data: {
                labels: [
                    <c:forEach var="lbl" items="${auditClassLabels}" varStatus="s">
                        '${lbl}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    data: [
                        <c:forEach var="val" items="${auditClassValues}" varStatus="s">
                            ${val}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    backgroundColor: [
                        '#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#06b6d4',
                        '#8b5cf6', '#f97316', '#dc2626', '#6b7280'
                    ],
                    borderColor: '#fff',
                    borderWidth: 2.5,
                    hoverOffset: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '55%',
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 14,
                            usePointStyle: true,
                            pointStyleWidth: 8,
                            font: { size: 11 }
                        }
                    }
                }
            }
        });
    }
})();
</script>


<%@ include file="../common/standalone-footer.jsp" %>
</body>
</html>
