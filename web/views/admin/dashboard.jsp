<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — CAMS Admin</title>

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
   CAMS Admin — Pink Rose Dashboard v4.0
   Full Dashboard: KPI Cards, Charts, Tables, Alerts
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

    --green-500: #10b981;
    --amber-500: #f59e0b;
    --blue-500:  #3b82f6;
    --purple-500:#8b5cf6;
    --cyan-500:  #06b6d4;

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
.table > :not(caption) > * > * { background-color: transparent; }

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
    position: fixed;
    top: 0; left: 0; right: 0;
    height: var(--topbar-h);
    background: var(--c-surface);
    border-bottom: 2px solid var(--pink-200);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 1.5rem;
    z-index: 1030;
    box-shadow: var(--shadow-xs);
}
.admin-topbar-left { display: flex; align-items: center; gap: 0.875rem; }
.admin-topbar-brand {
    font-family: var(--font-display);
    font-weight: 900;
    font-size: 1.3rem;
    color: var(--c-primary);
    text-decoration: none;
    display: flex;
    align-items: center;
    gap: 0.5rem;
    letter-spacing: -0.03em;
}
.admin-topbar-brand i {
    color: var(--pink-500);
    font-size: 1.5rem;
    filter: drop-shadow(0 0 6px rgba(233,30,140,0.4));
}
.admin-topbar-brand .brand-badge {
    font-family: var(--font-body);
    font-weight: 700;
    font-size: 0.65rem;
    color: var(--c-primary);
    background: var(--pink-100);
    padding: 3px 10px;
    border-radius: var(--r-pill);
    letter-spacing: 0.06em;
    text-transform: uppercase;
    border: 1px solid var(--pink-200);
}
.admin-sidebar-toggle {
    background: none; border: none;
    color: var(--c-on-surface-var);
    font-size: 1.5rem; cursor: pointer;
    padding: 6px 8px; border-radius: var(--r-sm);
    display: none; line-height: 1;
    transition: background var(--t-fast), color var(--t-fast);
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
    cursor: pointer;
    position: relative;
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
.admin-sidebar-menu li a i {
    font-size: 1rem; width: 20px; text-align: center;
    color: var(--sb-text-muted); flex-shrink: 0; transition: color var(--t-fast);
}
.admin-sidebar-menu li a:hover {
    background: var(--sb-hover); color: #fff;
    border-left-color: var(--pink-400); padding-left: 1.5rem;
}
.admin-sidebar-menu li a:hover i { color: var(--sb-accent); }
.admin-sidebar-menu li a.active {
    background: var(--sb-active-bg); color: var(--sb-accent);
    border-left-color: var(--pink-500); font-weight: 700;
}
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
.admin-welcome-banner p {
    color: rgba(255,255,255,0.88); margin: 0; font-size: 0.88rem;
}
.badge-role {
    display: inline-flex; align-items: center; gap: 0.4rem;
    padding: 0.45rem 1rem; border-radius: var(--r-pill);
    background: rgba(255,255,255,0.2); color: #fff;
    font-size: 0.8rem; font-weight: 700;
    border: 1px solid rgba(255,255,255,0.3); backdrop-filter: blur(4px);
    position: relative; z-index: 1;
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
.kpi-patients      .kpi-icon { background: #ede9fe; color: #7c3aed; }
.kpi-appointments  .kpi-icon { background: #dbeafe; color: #2563eb; }
.kpi-waiting       .kpi-icon { background: #fef3c7; color: #d97706; }
.kpi-doctors       .kpi-icon { background: #d1fae5; color: #059669; }
.kpi-ultrasound    .kpi-icon { background: #cffafe; color: #0891b2; }
.kpi-revenue       .kpi-icon { background: var(--pink-100); color: var(--pink-600); }
.kpi-emergency     .kpi-icon { background: #fee2e2; color: #dc2626; }
.kpi-success       .kpi-icon { background: #d1fae5; color: #059669; }
.kpi-emergency     .card-body { border-top: 3px solid #dc2626 !important; }
.kpi-success       .card-body { border-top: 3px solid #059669 !important; }

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
.chart-container {
    position: relative; width: 100%;
}
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
.admin-table tbody tr {
    border-bottom: 1px solid var(--c-outline-variant); transition: background var(--t-fast);
}
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
.badge-rejected  { background: #fee2e2; color: #991b1b; }
.badge-role-tag  {
    display: inline-block; padding: 2px 10px; border-radius: var(--r-pill);
    font-size: 0.7rem; font-weight: 700;
    background: var(--pink-100); color: var(--pink-700); border: 1px solid var(--pink-200);
}
.badge-active    { background: #d1fae5; color: #065f46; }
.badge-inactive  { background: #f3f4f6; color: #6b7280; }
.badge-locked    { background: #fee2e2; color: #991b1b; }
.badge-pending-verify { background: #fef3c7; color: #92400e; }

/* ── Alert Cards ── */
.alert-item {
    display: flex; align-items: flex-start; gap: 0.75rem;
    padding: 0.75rem; border-radius: var(--r-md);
    margin-bottom: 0.5rem;
    transition: background var(--t-fast);
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
.alert-item .alert-title {
    font-size: 0.8rem; font-weight: 700; color: var(--c-on-surface); margin-bottom: 2px;
}
.alert-item .alert-msg { font-size: 0.75rem; color: var(--c-muted); }
.alert-item .alert-count {
    font-family: var(--font-display); font-size: 1.1rem; font-weight: 900;
    padding: 0.25rem 0.6rem; border-radius: var(--r-pill); flex-shrink: 0;
}
.alert-item.warning .alert-count { background: #fde68a; color: #92400e; }
.alert-item.danger  .alert-count { background: #fecaca; color: #991b1b; }
.alert-item.info   .alert-count { background: #bfdbfe; color: #1e40af; }

/* ── Slots Bar ── */
.slots-bar {
    display: flex; align-items: center; gap: 0.5rem;
}
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

/* ── Sidebar Backdrop ── */
.admin-sidebar-backdrop {
    display: none; position: fixed; inset: 0;
    background: rgba(26,10,18,0.5); z-index: 1015;
    backdrop-filter: blur(3px);
    animation: fadeBackdrop 0.2s ease;
}
@keyframes fadeBackdrop { from { opacity: 0; } to { opacity: 1; } }
.admin-sidebar-backdrop.show { display: block; }

/* ── Animations ── */
@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(14px); }
    to   { opacity: 1; transform: translateY(0); }
}
.fade-in-up { animation: fadeInUp 0.4s ease forwards; }

/* ── Inline Date Filter in Page Header ── */
.header-date-filter {
    display: flex; align-items: center; gap: 0.5rem;
    flex-wrap: wrap;
}
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
    font-size: 0.9rem;
}
.header-date-filter .date-separator {
    font-size: 0.7rem; font-weight: 700; color: var(--c-muted);
}
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
.header-date-badge.live {
    background: #e8f5e9; color: #2e7d32;
    animation: pulse-live 2.5s infinite;
}
.header-date-badge.history {
    background: #fff3e0; color: #e65100;
}
@keyframes pulse-live {
    0%, 100% { box-shadow: 0 0 0 0 rgba(46,125,50,0.3); }
    50% { box-shadow: 0 0 0 6px rgba(46,125,50,0); }
}
@media (max-width: 1199.98px) {
    .header-date-filter { margin-top: 0.5rem; }
    .header-date-filter .date-input-group input[type="date"] { width: 110px; font-size: 0.73rem; }
}
@media (max-width: 767.98px) {
    .header-date-filter { flex-direction: column; align-items: stretch; width: 100%; }
    .header-date-filter .date-input-group { justify-content: space-between; }
    .header-date-filter .date-input-group input[type="date"] { flex: 1; }
    .header-date-filter .date-separator { display: none; }
}

/* ── Responsive ── */
@media (max-width: 1199.98px) {
    .kpi-card .card-body { padding: 1rem !important; gap: 0.75rem !important; }
    .kpi-value { font-size: 1.4rem; }
    .kpi-icon { width: 42px; height: 42px; font-size: 1.1rem; }
}
@media (max-width: 991.98px) {
    .admin-sidebar-toggle { display: inline-flex; }
    .admin-sidebar { transform: translateX(-100%); box-shadow: none; }
    .admin-sidebar.show { transform: translateX(0); box-shadow: var(--shadow-xl); }
    .admin-main { margin-left: 0; }
}
@media (max-width: 767.98px) {
    .admin-main { padding: 1rem; }
    .admin-page-title { font-size: 1.4rem; }
    .admin-welcome-banner { padding: 1.25rem 1.5rem; }
    .topbar-date { display: none; }
    .kpi-value { font-size: 1.25rem; }
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

    <%-- Page Header — tích hợp Date Filter bên cạnh subtitle ── --%>
    <div class="admin-page-header">
        <div class="admin-page-header-left" style="flex:1; min-width:0;">
            <h1 class="admin-page-title">
                <i class="bi bi-speedometer2 me-2" style="color:var(--pink-500);"></i>Dashboard
            </h1>
            <div style="display:flex; align-items:center; flex-wrap:wrap; gap:0.75rem;">
                <div class="admin-page-subtitle" style="margin-bottom:0;">
                    <i class="bi bi-calendar3"></i>
                    ${not empty todayDisplay ? todayDisplay : 'Hôm nay'}
                    <span class="mx-2">&middot;</span>
                    <i class="bi bi-building"></i>
                    Tổng quan hoạt động phòng khám
                </div>
                <%-- Inline Date Filter — nằm ngay bên cạnh subtitle --%>
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

    <%-- Welcome Banner --%>
    <div class="admin-welcome-banner">
        <div class="welcome-left">
            <h2>
                <i class="bi bi-stars"></i>
                Xin chào, ${sessionScope.user.fullName}!
            </h2>
            <p>Chào mừng bạn đến với hệ thống quản trị CAMS. Dưới đây là tổng quan hoạt động của phòng khám.</p>
        </div>
        <span class="badge-role">
            <i class="bi bi-person-badge-fill"></i>
            Quản Trị Viên
        </span>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- 8 KPI CARDS --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- 1. Tổng số bệnh nhân --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-patients fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-people-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalPatients ? totalPatients : 0}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Bệnh Nhân Mới (Khoảng)</c:when>
                                <c:otherwise>Tổng Bệnh Nhân</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-database"></i> <c:choose><c:when test="${isCustomRange}">${dateRangeLabel}</c:when><c:otherwise>Toàn hệ thống</c:otherwise></c:choose></div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 2. Lịch hẹn hôm nay --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-appointments fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-calendar-check-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty totalAppointmentsToday ? totalAppointmentsToday : 0}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Lịch Hẹn (Khoảng)</c:when>
                                <c:otherwise>Lịch Hẹn Hôm Nay</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-clock"></i> ${isCustomRange ? dateRangeLabel : 'Cập nhật thực'}</div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 3. Bệnh nhân đang chờ --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-waiting fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-hourglass-split"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty waitingPatients ? waitingPatients : 0}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Đang Chờ (Khoảng)</c:when>
                                <c:otherwise>Đang Chờ Khám</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-person"></i> ${isCustomRange ? dateRangeLabel : 'Hôm nay'}</div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 4. Bác sĩ đang làm việc --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-doctors fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-person-badge-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty doctorsWorkingToday ? doctorsWorkingToday : 0}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Bác Sĩ (Ngày ${dateToFormatted})</c:when>
                                <c:otherwise>Bác Sĩ Đang Làm</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-check-circle"></i> <c:choose><c:when test="${isCustomRange}">Ngày ${dateToFormatted}</c:when><c:otherwise>Đã duyệt lịch</c:otherwise></c:choose></div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 5. Ca siêu âm hôm nay --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-ultrasound fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-soundwave"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty ultrasoundToday ? ultrasoundToday : 0}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Siêu Âm (Khoảng)</c:when>
                                <c:otherwise>Ca Siêu Âm</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-calendar-day"></i> ${isCustomRange ? dateRangeLabel : 'Hôm nay'}</div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 6. Doanh thu hôm nay --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-revenue fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-cash-coin"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value" style="font-size:1.05rem;">${not empty revenueToday ? revenueToday : '0 VNĐ'}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Doanh Thu (Khoảng)</c:when>
                                <c:otherwise>Doanh Thu Hôm Nay</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-graph-up"></i> <c:choose><c:when test="${isCustomRange}">${dateRangeLabel}</c:when><c:otherwise>Đã thanh toán</c:otherwise></c:choose></div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 7. Ca Cấp Cứu --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-emergency fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty emergencyCases ? emergencyCases : 0}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Cấp Cứu (Khoảng)</c:when>
                                <c:otherwise>Ca Cấp Cứu</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-activity"></i> <c:choose><c:when test="${isCustomRange}">${dateRangeLabel}</c:when><c:otherwise>Hôm nay</c:otherwise></c:choose></div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 8. Ca Thành Công --%>
        <div class="col-xl-3 col-lg-4 col-md-6">
            <div class="card kpi-card kpi-success fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-check-circle-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty successfulCases ? successfulCases : 0}</div>
                        <div class="kpi-label">
                            <c:choose>
                                <c:when test="${isCustomRange}">Thành Công (Khoảng)</c:when>
                                <c:otherwise>Ca Thành Công</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="kpi-sub"><i class="bi bi-check2-all"></i> <c:choose><c:when test="${isCustomRange}">${dateRangeLabel}</c:when><c:otherwise>Đã khám + TT</c:otherwise></c:choose></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- CẢNH BÁO HỆ THỐNG --%>
    <%-- ════════════════════════════════════════════ --%>
    <c:if test="${not empty systemAlerts}">
    <div class="row mb-4">
        <div class="col-12">
            <div class="admin-card">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-exclamation-diamond-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Cảnh Báo (đến ${dateToFormatted})</c:when>
                            <c:otherwise>Cảnh Báo &amp; Thông Báo</c:otherwise>
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
    <%-- BIỂU ĐỒ: Lịch hẹn 7 ngày + Doanh thu 12 tháng --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Biểu đồ lịch hẹn theo ngày (7 ngày) --%>
        <div class="col-xl-6">
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
                    <div class="chart-container">
                        <canvas id="appointmentsChart" height="260"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <%-- Biểu đồ doanh thu theo tháng (12 tháng) --%>
        <div class="col-xl-6">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-graph-up-arrow"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Doanh Thu 12 Tháng (đến ${dateToFormatted})</c:when>
                            <c:otherwise>Doanh Thu 12 Tháng</c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                <div class="card-body">
                    <div class="chart-container">
                        <canvas id="revenueChart" height="260"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- TOP DỊCH VỤ ĐƯỢC SỬ DỤNG --%>
    <%-- ════════════════════════════════════════════ --%>
    <c:if test="${not empty topServices}">
    <div class="row g-3 mb-4">
        <div class="col-12">
            <div class="admin-card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5>
                        <i class="bi bi-star-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Top Dịch Vụ (${dateRangeLabel})</c:when>
                            <c:otherwise>Top Dịch Vụ Được Sử Dụng</c:otherwise>
                        </c:choose>
                    </h5>
                    <a href="${pageContext.request.contextPath}/admin/reports/"
                       style="font-size:0.78rem;font-weight:700;color:var(--pink-500);text-decoration:none;">
                        Xem báo cáo →
                    </a>
                </div>
                <div class="card-body p-0">
                    <div class="admin-table-wrapper">
                        <table class="admin-table compact">
                            <thead>
                                <tr>
                                    <th style="width:50px;">#</th>
                                    <th>Tên Dịch Vụ</th>
                                    <th>Nhóm</th>
                                    <th class="text-end">Lượt SD</th>
                                    <th class="text-end">Doanh Thu</th>
                                    <th style="width:80px;">Tăng Trưởng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${topServices}" var="svc" varStatus="loop">
                                <tr>
                                    <td>
                                        <c:choose>
                                            <c:when test="${loop.index == 0}"><span style="display:inline-flex;align-items:center;justify-content:center;width:24px;height:24px;border-radius:50%;background:#e91e63;color:#fff;font-size:0.7rem;font-weight:800;">1</span></c:when>
                                            <c:when test="${loop.index == 1}"><span style="display:inline-flex;align-items:center;justify-content:center;width:24px;height:24px;border-radius:50%;background:#ec407a;color:#fff;font-size:0.7rem;font-weight:800;">2</span></c:when>
                                            <c:when test="${loop.index == 2}"><span style="display:inline-flex;align-items:center;justify-content:center;width:24px;height:24px;border-radius:50%;background:#f06292;color:#fff;font-size:0.7rem;font-weight:800;">3</span></c:when>
                                            <c:otherwise><span style="color:var(--c-muted);font-weight:700;">${loop.index + 1}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <strong>${svc.serviceName}</strong>
                                        <div style="font-size:0.7rem;color:var(--c-muted);"><code style="font-size:0.68rem;background:var(--pink-50);color:var(--pink-600);padding:1px 6px;border-radius:4px;">${svc.serviceCode}</code></div>
                                    </td>
                                    <td><span class="badge-role-tag">${svc.categoryName}</span></td>
                                    <td class="text-end"><strong>${svc.usageToday}</strong></td>
                                    <td class="text-end"><fmt:formatNumber value="${svc.revenueToday}" pattern="#,###"/> đ</td>
                                    <td>
                                        <c:set var="trend" value="${svc.growthTrend}" />
                                        <c:choose>
                                            <c:when test="${trend == 'up'}"><span style="color:#059669;font-weight:700;font-size:0.72rem;"><i class="bi bi-arrow-up-short"></i> +<fmt:formatNumber value="${svc.usageGrowthPercent}" pattern="#.#"/>%</span></c:when>
                                            <c:when test="${trend == 'down'}"><span style="color:#dc2626;font-weight:700;font-size:0.72rem;"><i class="bi bi-arrow-down-short"></i> <fmt:formatNumber value="${svc.usageGrowthPercent}" pattern="#.#"/>%</span></c:when>
                                            <c:otherwise><span style="color:var(--c-muted);font-weight:600;font-size:0.72rem;">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </c:if>

    <%-- ════════════════════════════════════════════ --%>
    <%-- HÀNG GIỮA: Hiệu suất bác sĩ + Lịch làm việc --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Bảng hiệu suất bác sĩ --%>
        <div class="col-xl-7">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5>
                        <i class="bi bi-trophy-fill"></i>
                        Hiệu Suất Bác Sĩ
                    </h5>
                    <a href="${pageContext.request.contextPath}/admin/doctors/"
                       style="font-size:0.78rem;font-weight:700;color:var(--pink-500);text-decoration:none;">
                        Quản lý bác sĩ →
                    </a>
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
                                            <th class="text-center">Tổng BN Đã Khám</th>
                                            <th class="text-center">
                                                <c:choose>
                                                    <c:when test="${isCustomRange}">Khoảng</c:when>
                                                    <c:otherwise>Hôm Nay</c:otherwise>
                                                </c:choose>
                                            </th>
                                            <th class="text-end">Doanh Thu</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="dp" items="${doctorPerformance}" varStatus="loop">
                                            <tr>
                                                <td style="color:var(--c-muted);width:40px;">${loop.index + 1}</td>
                                                <td style="font-weight:600;">${dp.doctorName}</td>
                                                <td style="color:var(--c-muted);font-size:0.8rem;">${dp.specialization}</td>
                                                <td class="text-center">
                                                    <span style="font-weight:700;color:var(--purple-500);">${dp.totalPatients}</span>
                                                </td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${dp.appointmentsToday > 0}">
                                                            <span style="font-weight:700;color:var(--green-500);">${dp.appointmentsToday}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color:var(--c-muted);">0</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end" style="font-weight:600;">
                                                    <fmt:formatNumber value="${dp.revenueGenerated}" pattern="#,###" /> VNĐ
                                                </td>
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
                                <p><c:choose><c:when test="${isCustomRange}">Không có bác sĩ nào có lịch hẹn trong khoảng ${dateRangeLabel}.</c:when><c:otherwise>Thêm bác sĩ vào hệ thống để xem hiệu suất.</c:otherwise></c:choose></p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Lịch làm việc hôm nay --%>
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
                                        <tr>
                                            <th>Bác Sĩ</th>
                                            <th>Giờ</th>
                                            <th>Slots</th>
                                            <th>Trạng Thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="sch" items="${todaySchedules}">
                                            <tr>
                                                <td>
                                                    <div style="font-weight:600;">${sch.doctorName}</div>
                                                    <div style="font-size:0.7rem;color:var(--c-muted);">${sch.specialization}</div>
                                                </td>
                                                <td style="font-family:var(--font-display);font-weight:600;color:var(--c-primary);">
                                                    ${sch.startTime} - ${sch.endTime}
                                                </td>
                                                <td>
                                                    <div class="slots-bar">
                                                        <div class="progress">
                                                            <c:set var="pct" value="${sch.maxSlots > 0 ? (sch.bookedSlots * 100 / sch.maxSlots) : 0}" />
                                                            <div class="progress-bar${sch.bookedSlots >= sch.maxSlots ? ' full' : ''}"
                                                                 style="width:${pct}%;"></div>
                                                        </div>
                                                        <span class="slots-text">${sch.bookedSlots}/${sch.maxSlots}</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${sch.isApproved}">
                                                            <span class="badge-status badge-approved">Đã duyệt</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-status badge-pending">Chờ duyệt</span>
                                                        </c:otherwise>
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
                                <p>Hôm nay chưa có bác sĩ nào đăng ký lịch làm việc.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ════════════════════════════════════════════ --%>
    <%-- HÀNG DƯỚI: Siêu Âm + Bệnh Nhân Mới + Nhật Ký --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3 mb-4">
        <%-- Thống kê dịch vụ siêu âm --%>
        <div class="col-xl-4">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-soundwave"></i>
                        Thống Kê Dịch Vụ Siêu Âm
                    </h5>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty ultrasoundStats}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead>
                                        <tr>
                                            <th>Dịch Vụ</th>
                                            <th class="text-center">Tổng Ca</th>
                                            <th class="text-center">
                                                <c:choose>
                                                    <c:when test="${isCustomRange}">Khoảng</c:when>
                                                    <c:otherwise>Hôm Nay</c:otherwise>
                                                </c:choose>
                                            </th>
                                            <th class="text-end">Giá</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="us" items="${ultrasoundStats}">
                                            <tr>
                                                <td style="font-weight:600;">${us.serviceName}</td>
                                                <td class="text-center" style="font-weight:700;">${us.totalCases}</td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${us.casesToday > 0}">
                                                            <span class="badge-status badge-active">${us.casesToday}</span>
                                                        </c:when>
                                                        <c:otherwise>0</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end" style="font-weight:600;">
                                                    <fmt:formatNumber value="${us.price}" pattern="#,###" /> đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-soundwave"></i>
                                <h6>Chưa có dịch vụ siêu âm</h6>
                                <p>Thêm dịch vụ siêu âm vào hệ thống để hiển thị thống kê.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Bệnh nhân mới đăng ký --%>
        <div class="col-xl-4">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5>
                        <i class="bi bi-person-plus-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Bệnh Nhân Mới (${dateRangeLabel})</c:when>
                            <c:otherwise>Bệnh Nhân Mới Đăng Ký</c:otherwise>
                        </c:choose>
                    </h5>
                    <a href="${pageContext.request.contextPath}/admin/users/"
                       style="font-size:0.78rem;font-weight:700;color:var(--pink-500);text-decoration:none;">
                        Xem tất cả →
                    </a>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${not empty recentPatients}">
                            <div class="admin-table-wrapper">
                                <table class="admin-table compact">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Họ Tên</th>
                                            <th>Email / SĐT</th>
                                            <th>Ngày ĐK</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="rp" items="${recentPatients}">
                                            <tr>
                                                <td style="color:var(--c-muted);font-size:0.78rem;">#${rp.id}</td>
                                                <td style="font-weight:600;">${rp.fullName}</td>
                                                <td style="font-size:0.78rem;">
                                                    <div>${rp.email}</div>
                                                    <c:if test="${not empty rp.phone}">
                                                        <div style="color:var(--c-muted);">${rp.phone}</div>
                                                    </c:if>
                                                </td>
                                                <td style="color:var(--c-muted);font-size:0.78rem;white-space:nowrap;">
                                                    ${rp.createdAt}
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state">
                                <i class="bi bi-people"></i>
                                <h6>Chưa có bệnh nhân mới</h6>
                                <p>Bệnh nhân mới đăng ký sẽ hiển thị ở đây.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%-- Nhật ký hệ thống --%>
        <div class="col-xl-4">
            <div class="admin-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <h5>
                        <i class="bi bi-clipboard-data-fill"></i>
                        <c:choose>
                            <c:when test="${isCustomRange}">Nhật Ký (${dateRangeLabel})</c:when>
                            <c:otherwise>Nhật Ký Hệ Thống</c:otherwise>
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
                                            <th>Hành Động</th>
                                            <th>Thời Gian</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="log" items="${recentAuditLogs}">
                                            <tr>
                                                <td>
                                                    <span style="font-weight:600;">${log.userName}</span>
                                                </td>
                                                <td>
                                                    <span style="font-size:0.78rem;">${log.action}</span>
                                                    <c:if test="${not empty log.tableName}">
                                                        <div style="font-size:0.68rem;color:var(--c-muted);">
                                                            Bảng: ${log.tableName}
                                                        </div>
                                                    </c:if>
                                                </td>
                                                <td style="color:var(--c-muted);font-size:0.75rem;white-space:nowrap;">
                                                    ${log.createdAt}
                                                </td>
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

    <%-- ════════════════════════════════════════════ --%>
    <%-- THÔNG TIN HỆ THỐNG --%>
    <%-- ════════════════════════════════════════════ --%>
    <div class="row g-3">
        <div class="col-lg-4">
            <div class="admin-card">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-info-circle-fill"></i>
                        Thông Tin Hệ Thống
                    </h5>
                </div>
                <div class="card-body">
                    <ul class="system-info-list" style="list-style:none;padding:0;margin:0;display:flex;flex-direction:column;gap:0.35rem;">
                        <li style="display:flex;justify-content:space-between;padding:0.45rem 0;border-bottom:1px solid var(--c-outline-variant);font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-box-seam-fill" style="color:var(--pink-400);"></i>Phiên bản</span>
                            <span style="font-weight:600;">v1.0.0</span>
                        </li>
                        <li style="display:flex;justify-content:space-between;padding:0.45rem 0;border-bottom:1px solid var(--c-outline-variant);font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-server" style="color:var(--pink-400);"></i>Database</span>
                            <span style="font-weight:600;">SQL Server</span>
                        </li>
                        <li style="display:flex;justify-content:space-between;padding:0.45rem 0;border-bottom:1px solid var(--c-outline-variant);font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-hdd-stack-fill" style="color:var(--pink-400);"></i>Server</span>
                            <span style="font-weight:600;">Tomcat 10.1</span>
                        </li>
                        <li style="display:flex;justify-content:space-between;padding:0.45rem 0;border-bottom:1px solid var(--c-outline-variant);font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-cpu-fill" style="color:var(--pink-400);"></i>Java</span>
                            <span style="font-weight:600;">JDK 17 LTS</span>
                        </li>
                        <li style="display:flex;justify-content:space-between;padding:0.45rem 0;border-bottom:1px solid var(--c-outline-variant);font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-shield-lock-fill" style="color:var(--pink-400);"></i>Bảo mật</span>
                            <span style="font-weight:600;color:#059669;"><i class="bi bi-check-circle-fill me-1"></i>BCrypt</span>
                        </li>
                        <li style="display:flex;justify-content:space-between;padding:0.45rem 0;font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-circle-fill" style="color:#10b981;font-size:0.5rem;"></i>Trạng thái</span>
                            <span style="font-weight:600;color:#059669;">Hoạt động</span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>

        <%-- Thao tác nhanh --%>
        <div class="col-lg-4">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-lightning-charge-fill"></i>
                        Thao Tác Nhanh
                    </h5>
                </div>
                <div class="card-body">
                    <a href="${pageContext.request.contextPath}/admin/users/" class="d-flex align-items-center gap-3 p-2 rounded-3 text-decoration-none"
                       style="transition:all var(--t-fast);margin-bottom:0.35rem;"
                       onmouseover="this.style.background='var(--pink-50)';this.style.transform='translateX(4px)';"
                       onmouseout="this.style.background='transparent';this.style.transform='translateX(0)';">
                        <div style="width:38px;height:38px;border-radius:8px;background:var(--pink-100);color:var(--pink-600);display:flex;align-items:center;justify-content:center;font-size:1rem;">
                            <i class="bi bi-person-plus-fill"></i>
                        </div>
                        <div>
                            <div style="font-size:0.85rem;font-weight:700;color:var(--c-on-surface);">Thêm Người Dùng</div>
                            <small style="color:var(--c-muted);">Tạo tài khoản mới</small>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/roles/" class="d-flex align-items-center gap-3 p-2 rounded-3 text-decoration-none"
                       style="transition:all var(--t-fast);margin-bottom:0.35rem;"
                       onmouseover="this.style.background='var(--pink-50)';this.style.transform='translateX(4px)';"
                       onmouseout="this.style.background='transparent';this.style.transform='translateX(0)';">
                        <div style="width:38px;height:38px;border-radius:8px;background:var(--pink-100);color:var(--pink-600);display:flex;align-items:center;justify-content:center;font-size:1rem;">
                            <i class="bi bi-shield-lock-fill"></i>
                        </div>
                        <div>
                            <div style="font-size:0.85rem;font-weight:700;color:var(--c-on-surface);">Phân Quyền</div>
                            <small style="color:var(--c-muted);">Quản lý vai trò & quyền</small>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/settings/" class="d-flex align-items-center gap-3 p-2 rounded-3 text-decoration-none"
                       style="transition:all var(--t-fast);margin-bottom:0.35rem;"
                       onmouseover="this.style.background='var(--pink-50)';this.style.transform='translateX(4px)';"
                       onmouseout="this.style.background='transparent';this.style.transform='translateX(0)';">
                        <div style="width:38px;height:38px;border-radius:8px;background:var(--pink-100);color:var(--pink-600);display:flex;align-items:center;justify-content:center;font-size:1rem;">
                            <i class="bi bi-gear-fill"></i>
                        </div>
                        <div>
                            <div style="font-size:0.85rem;font-weight:700;color:var(--c-on-surface);">Cài Đặt</div>
                            <small style="color:var(--c-muted);">Cấu hình hệ thống</small>
                        </div>
                    </a>
                </div>
            </div>
        </div>

        <%-- Tổng quan nhanh --%>
        <div class="col-lg-4">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-pie-chart-fill"></i>
                        Tổng Quan Chung
                    </h5>
                </div>
                <div class="card-body">
                    <ul class="system-info-list" style="list-style:none;padding:0;margin:0;display:flex;flex-direction:column;gap:0.35rem;">
                        <li style="display:flex;justify-content:space-between;padding:0.5rem 0;border-bottom:1px solid var(--c-outline-variant);font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-people-fill" style="color:var(--pink-400);"></i>
                                <c:choose>
                                    <c:when test="${isCustomRange}">Người dùng mới (khoảng)</c:when>
                                    <c:otherwise>Tổng người dùng</c:otherwise>
                                </c:choose>
                            </span>
                            <span style="font-weight:700;font-family:var(--font-display);">${not empty totalUsers ? totalUsers : 0}</span>
                        </li>
                        <li style="display:flex;justify-content:space-between;padding:0.5rem 0;border-bottom:1px solid var(--c-outline-variant);font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-person-badge-fill" style="color:var(--pink-400);"></i>
                                <c:choose>
                                    <c:when test="${isCustomRange}">Bác sĩ mới (khoảng)</c:when>
                                    <c:otherwise>Tổng bác sĩ</c:otherwise>
                                </c:choose>
                            </span>
                            <span style="font-weight:700;font-family:var(--font-display);">${not empty totalDoctors ? totalDoctors : 0}</span>
                        </li>
                        <li style="display:flex;justify-content:space-between;padding:0.5rem 0;border-bottom:1px solid var(--c-outline-variant);font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-people" style="color:var(--pink-400);"></i>
                                <c:choose>
                                    <c:when test="${isCustomRange}">Bệnh nhân mới (khoảng)</c:when>
                                    <c:otherwise>Tổng bệnh nhân</c:otherwise>
                                </c:choose>
                            </span>
                            <span style="font-weight:700;font-family:var(--font-display);">${not empty totalPatients ? totalPatients : 0}</span>
                        </li>
                        <li style="display:flex;justify-content:space-between;padding:0.5rem 0;border-bottom:1px solid var(--c-outline-variant);font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-calendar-check" style="color:var(--pink-400);"></i>
                                <c:choose>
                                    <c:when test="${isCustomRange}">Lịch hẹn (khoảng)</c:when>
                                    <c:otherwise>Lịch hẹn hôm nay</c:otherwise>
                                </c:choose>
                            </span>
                            <span style="font-weight:700;font-family:var(--font-display);">${not empty totalAppointmentsToday ? totalAppointmentsToday : 0}</span>
                        </li>
                        <li style="display:flex;justify-content:space-between;padding:0.5rem 0;font-size:0.85rem;">
                            <span style="display:flex;align-items:center;gap:0.5rem;color:var(--c-on-surface-var);"><i class="bi bi-cash-stack" style="color:var(--pink-400);"></i>
                                <c:choose>
                                    <c:when test="${isCustomRange}">Doanh thu (khoảng)</c:when>
                                    <c:otherwise>Doanh thu hôm nay</c:otherwise>
                                </c:choose>
                            </span>
                            <span style="font-weight:700;font-family:var(--font-display);color:var(--pink-600);">${not empty revenueToday ? revenueToday : '0 VNĐ'}</span>
                        </li>
                    </ul>
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
<%-- SIDEBAR SCRIPTS --%>
<%-- ════════════════════════════════════════════ --%>
<script>
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
<%-- CHART.JS INITIALIZATION --%>
<%-- ════════════════════════════════════════════ --%>
<script>
(function() {
    // Common chart colors
    var pink500 = '#e91e8c';
    var pink200 = '#ffb3d1';
    var pink100 = '#ffe0ef';

    // ── Appointments Chart (7 days) ──
    var apptCtx = document.getElementById('appointmentsChart');
    if (apptCtx) {
        new Chart(apptCtx, {
            type: 'bar',
            data: {
                labels: [
                    <c:forEach var="lbl" items="${apptChartLabels}" varStatus="s">
                        '${lbl}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Lịch hẹn',
                    data: [
                        <c:forEach var="val" items="${apptChartValues}" varStatus="s">
                            ${val}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    backgroundColor: pink500,
                    borderColor: '#c2185b',
                    borderWidth: 1,
                    borderRadius: 6,
                    hoverBackgroundColor: '#ff4d94'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
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

    // ── Revenue Chart (12 months) ──
    var revCtx = document.getElementById('revenueChart');
    if (revCtx) {
        new Chart(revCtx, {
            type: 'line',
            data: {
                labels: [
                    <c:forEach var="lbl" items="${revenueChartLabels}" varStatus="s">
                        '${lbl}'${s.last ? '' : ','}
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Doanh thu (VNĐ)',
                    data: [
                        <c:forEach var="val" items="${revenueChartValues}" varStatus="s">
                            ${val}${s.last ? '' : ','}
                        </c:forEach>
                    ],
                    borderColor: pink500,
                    backgroundColor: 'rgba(233,30,140,0.08)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: pink500,
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                if (value >= 1000000000) return (value/1000000000).toFixed(1) + 'B';
                                if (value >= 1000000) return (value/1000000).toFixed(0) + 'M';
                                if (value >= 1000) return (value/1000).toFixed(0) + 'K';
                                return value;
                            },
                            font: { size: 11 }
                        },
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
})();
</script>

</body>
</html>
