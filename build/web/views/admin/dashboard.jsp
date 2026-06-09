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

    <!-- Admin CSS (file ngoài — nếu có) -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <%-- ============================================================
         TOÀN BỘ CSS NHÚNG TRỰC TIẾP — đảm bảo luôn hiển thị đúng
         dù file admin.css ngoài chưa được link hoặc không tồn tại
         ============================================================ --%>
    <style>
/* ============================================================
   CAMS Admin — Pink Rose Dashboard v3.0
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
    --c-surface-container: #fce8f0;
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

    --status-active-bg:   #e8f5e9;
    --status-active-fg:   #2e7d32;
    --status-inactive-bg: #f5f5f5;
    --status-inactive-fg: #757575;
    --status-locked-bg:   #ffebee;
    --status-locked-fg:   #c62828;
    --status-pending-bg:  #fff8e1;
    --status-pending-fg:  #f57f17;

    --shadow-xs:   0 1px 3px rgba(194,24,91,0.07);
    --shadow-sm:   0 2px 8px rgba(194,24,91,0.10);
    --shadow-md:   0 4px 20px rgba(194,24,91,0.13);
    --shadow-lg:   0 8px 32px rgba(194,24,91,0.16);
    --shadow-xl:   0 16px 56px rgba(194,24,91,0.20);
    --shadow-pink: 0 4px 24px rgba(233,30,140,0.30);

    --r-sm:   8px;  --r-md: 12px; --r-lg: 16px;
    --r-xl:   22px; --r-pill: 999px;
    --t-fast: 0.15s ease; --t-normal: 0.25s ease;
    --t-slow: 0.35s cubic-bezier(0.4,0,0.2,1);
    --font-display: 'Nunito', 'Be Vietnam Pro', sans-serif;
    --font-body:    'Inter', 'Be Vietnam Pro', sans-serif;
}

/* ── Reset ── */
*, *::before, *::after { box-sizing: border-box; }
html { scroll-behavior: smooth; }

/* Bootstrap overrides */
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

.admin-topbar-user {
    display: flex; align-items: center; gap: 0.6rem;
    padding: 0.375rem 0.875rem;
    background: var(--pink-50);
    border-radius: var(--r-pill);
    border: 1px solid var(--pink-200);
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
.admin-page-header-left {}
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
    border-radius: var(--r-lg); padding: 1.6rem 2rem; margin-bottom: 1.75rem;
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
.admin-welcome-banner h2 {
    font-family: var(--font-display); color: #fff; font-size: 1.35rem;
    font-weight: 900; margin: 0 0 0.4rem;
    display: flex; align-items: center; gap: 0.5rem; position: relative;
}
.admin-welcome-banner p {
    color: rgba(255,255,255,0.88); margin: 0; font-size: 0.88rem; position: relative;
}
.badge-role {
    display: inline-flex; align-items: center; gap: 0.4rem;
    padding: 0.45rem 1rem; border-radius: var(--r-pill);
    background: rgba(255,255,255,0.2); color: #fff;
    font-size: 0.8rem; font-weight: 700;
    border: 1px solid rgba(255,255,255,0.3); backdrop-filter: blur(4px);
}

/* ── Stat Cards ── */
.stat-card {
    border-radius: var(--r-lg) !important;
    border: 1px solid var(--c-outline-variant) !important;
    box-shadow: var(--shadow-sm) !important;
    overflow: hidden; transition: transform var(--t-normal), box-shadow var(--t-normal);
}
.stat-card:hover { transform: translateY(-4px); box-shadow: var(--shadow-md) !important; }

.stat-card .card-body {
    background: var(--c-surface) !important;
    padding: 1.4rem 1.35rem !important;
    display: flex !important; align-items: center !important; gap: 1rem !important;
}
.stat-card.users   .card-body { border-top: 3px solid var(--pink-400) !important; }
.stat-card.doctors .card-body { border-top: 3px solid #ce3fa7 !important; }
.stat-card.appts   .card-body { border-top: 3px solid var(--rose-500) !important; }
.stat-card.revenue .card-body { border-top: 3px solid var(--pink-600) !important; }

.stat-card-icon {
    width: 52px; height: 52px; border-radius: var(--r-md);
    display: flex; align-items: center; justify-content: center;
    font-size: 1.4rem; flex-shrink: 0;
}
.stat-card-icon.users   { background: var(--pink-100); color: var(--pink-600); }
.stat-card-icon.doctors { background: #fce4f3;         color: #9c0f6e; }
.stat-card-icon.appts   { background: #fdeaf6;         color: var(--rose-600); }
.stat-card-icon.revenue { background: var(--pink-50);  color: var(--pink-700); }

.stat-card-content { flex: 1; min-width: 0; }
.stat-card-value {
    font-family: var(--font-display); font-size: 1.9rem; font-weight: 900;
    color: var(--c-on-surface); line-height: 1.1; letter-spacing: -0.04em;
}
.stat-card-label { font-size: 0.8rem; font-weight: 600; color: var(--c-on-surface-var); margin-top: 0.15rem; }
.stat-card-trend {
    font-size: 0.73rem; font-weight: 600;
    display: flex; align-items: center; gap: 0.3rem; margin-top: 0.3rem;
}
.stat-card-trend.up      { color: #2e7d32; }
.stat-card-trend.down    { color: var(--rose-600); }
.stat-card-trend.neutral { color: var(--c-muted); }

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
    padding: 1rem 1.25rem !important;
}
.admin-card .card-header h5 {
    font-family: var(--font-display); font-size: 0.95rem; font-weight: 800;
    color: var(--c-primary-dark); margin: 0;
    display: flex; align-items: center; gap: 0.5rem;
}
.admin-card .card-header h5 i { color: var(--pink-500); }
.admin-card .card-body { background: var(--c-surface) !important; padding: 1.25rem !important; }

/* ── Table ── */
.admin-table-wrapper { overflow-x: auto; }
.admin-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
.admin-table thead th {
    font-family: var(--font-display); font-size: 0.72rem; font-weight: 800;
    text-transform: uppercase; letter-spacing: 0.07em;
    color: var(--c-primary); padding: 0.875rem 1rem;
    background: var(--pink-50); border-bottom: 2px solid var(--pink-200); white-space: nowrap;
}
.admin-table tbody tr {
    border-bottom: 1px solid var(--c-outline-variant); transition: background var(--t-fast);
}
.admin-table tbody tr:hover { background: var(--pink-50); }
.admin-table tbody td { padding: 0.75rem 1rem; color: var(--c-on-surface); vertical-align: middle; }

/* ── Quick Actions ── */
.quick-action-btn {
    display: flex; align-items: center; gap: 0.875rem; padding: 0.75rem 1rem;
    border-radius: var(--r-md); text-decoration: none; color: var(--c-on-surface);
    transition: all var(--t-fast); border: 1px solid transparent; margin-bottom: 0.5rem;
}
.quick-action-btn:hover {
    background: var(--pink-50); border-color: var(--pink-200);
    transform: translateX(4px); color: var(--c-primary-dark);
}
.quick-action-icon {
    width: 42px; height: 42px; border-radius: var(--r-sm);
    background: var(--pink-100); color: var(--pink-600);
    display: flex; align-items: center; justify-content: center;
    font-size: 1.1rem; flex-shrink: 0; transition: all var(--t-fast);
}
.quick-action-btn:hover .quick-action-icon {
    background: linear-gradient(135deg, var(--pink-500), var(--rose-400));
    color: #fff; box-shadow: 0 4px 12px rgba(233,30,140,0.3);
}
.quick-action-text { display: flex; flex-direction: column; gap: 1px; min-width: 0; }
.quick-action-text span { font-size: 0.875rem; font-weight: 700; color: var(--c-on-surface); }
.quick-action-text small { font-size: 0.75rem; color: var(--c-muted); }

/* ── System Info ── */
.admin-info-list { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 0.25rem; }
.admin-info-list li {
    display: flex; align-items: center; justify-content: space-between;
    padding: 0.5rem 0; border-bottom: 1px solid var(--c-outline-variant); font-size: 0.85rem;
}
.admin-info-list li:last-child { border-bottom: none; }
.info-label { display: flex; align-items: center; gap: 0.5rem; color: var(--c-on-surface-var); }
.info-label i { color: var(--pink-400); }
.info-value { font-weight: 600; color: var(--c-on-surface); }
.info-value.good { color: #2e7d32; }

/* ── Badges ── */
.badge-role-tag {
    display: inline-block; padding: 2px 10px; border-radius: var(--r-pill);
    font-size: 0.7rem; font-weight: 700;
    background: var(--pink-100); color: var(--pink-700); border: 1px solid var(--pink-200);
}
.badge-status {
    display: inline-block; padding: 3px 10px; border-radius: var(--r-pill);
    font-size: 0.72rem; font-weight: 700;
}
.badge-status-active    { background: var(--status-active-bg);   color: var(--status-active-fg); }
.badge-status-inactive  { background: var(--status-inactive-bg); color: var(--status-inactive-fg); }
.badge-status-locked    { background: var(--status-locked-bg);   color: var(--status-locked-fg); }
.badge-status-pending   { background: var(--status-pending-bg);  color: var(--status-pending-fg); }

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
.fade-in-up:nth-child(1) { animation-delay: 0.00s; }
.fade-in-up:nth-child(2) { animation-delay: 0.06s; }
.fade-in-up:nth-child(3) { animation-delay: 0.12s; }
.fade-in-up:nth-child(4) { animation-delay: 0.18s; }

/* ── Responsive ── */
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
    .stat-card .card-body { padding: 1rem !important; gap: 0.75rem !important; }
    .stat-card-value { font-size: 1.5rem; }
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
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">
                ${fn:substring(sessionScope.user.fullName, 0, 1)}
            </div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role">
                <i class="bi bi-shield-check me-1"></i>Admin
            </span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout">
            <i class="bi bi-box-arrow-right"></i>
            <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
    </div>
</nav>

<%-- ── SIDEBAR ── --%>
<%@ include file="layout/sidebar.jsp" %>

<%-- ── MAIN CONTENT ── --%>
<main class="admin-main" id="adminMain">

    <%-- Page Header --%>
    <div class="admin-page-header">
        <div class="admin-page-header-left">
            <h1 class="admin-page-title">Dashboard</h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-calendar3"></i>
                Hôm nay, <%= java.time.LocalDate.now().format(
                    java.time.format.DateTimeFormatter.ofPattern("dd 'tháng' MM, yyyy")) %>
            </div>
        </div>
        <button class="btn-refresh" onclick="location.reload()">
            <i class="bi bi-arrow-clockwise"></i>
            Làm mới
        </button>
    </div>

    <%-- Welcome Banner --%>
    <div class="admin-welcome-banner">
        <div>
            <h2>
                <i class="bi bi-stars"></i>
                Xin chào, ${sessionScope.user.fullName}!
            </h2>
            <p>Chào mừng bạn đến với hệ thống quản trị CAMS. Hệ thống đang hoạt động bình thường.</p>
        </div>
        <div>
            <span class="badge-role">
                <i class="bi bi-person-badge-fill"></i>
                Quản Trị Viên
            </span>
        </div>
    </div>

    <%-- Stat Cards --%>
    <div class="row g-3 mb-4">

        <div class="col-xl-3 col-md-6">
            <div class="card stat-card users fade-in-up">
                <div class="card-body">
                    <div class="stat-card-icon users">
                        <i class="bi bi-people-fill"></i>
                    </div>
                    <div class="stat-card-content">
                        <div class="stat-card-value">${not empty totalUsers ? totalUsers : '0'}</div>
                        <div class="stat-card-label">Tổng Người Dùng</div>
                        <div class="stat-card-trend neutral">
                            <i class="bi bi-circle-fill" style="font-size:0.45rem;"></i>
                            Toàn hệ thống
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6">
            <div class="card stat-card doctors fade-in-up">
                <div class="card-body">
                    <div class="stat-card-icon doctors">
                        <i class="bi bi-person-badge-fill"></i>
                    </div>
                    <div class="stat-card-content">
                        <div class="stat-card-value">${not empty totalDoctors ? totalDoctors : '0'}</div>
                        <div class="stat-card-label">Bác Sĩ</div>
                        <div class="stat-card-trend up">
                            <i class="bi bi-circle-fill" style="font-size:0.45rem;"></i>
                            Đang hoạt động
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6">
            <div class="card stat-card appts fade-in-up">
                <div class="card-body">
                    <div class="stat-card-icon appts">
                        <i class="bi bi-calendar-check-fill"></i>
                    </div>
                    <div class="stat-card-content">
                        <div class="stat-card-value">${not empty totalAppointmentsToday ? totalAppointmentsToday : '0'}</div>
                        <div class="stat-card-label">Lịch Hẹn Hôm Nay</div>
                        <div class="stat-card-trend up">
                            <i class="bi bi-circle-fill" style="font-size:0.45rem;"></i>
                            Cập nhật thời gian thực
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6">
            <div class="card stat-card revenue fade-in-up">
                <div class="card-body">
                    <div class="stat-card-icon revenue">
                        <i class="bi bi-cash-coin"></i>
                    </div>
                    <div class="stat-card-content">
                        <div class="stat-card-value" style="font-size:1.4rem;">
                            ${not empty monthlyRevenue ? monthlyRevenue : '0'} VND
                        </div>
                        <div class="stat-card-label">Doanh Thu Tháng</div>
                        <div class="stat-card-trend neutral">
                            <i class="bi bi-circle-fill" style="font-size:0.45rem;"></i>
                            Tháng hiện tại
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div><%-- /row stats --%>

    <%-- Bottom Row: Users Table + Quick Actions --%>
    <div class="row g-3">

        <%-- Users Table --%>
        <div class="col-lg-8">
            <div class="admin-card h-100">
                <div class="card-header">
                    <div class="d-flex align-items-center justify-content-between">
                        <h5>
                            <i class="bi bi-people-fill"></i>
                            Người Dùng Mới Nhất
                        </h5>
                        <a href="${pageContext.request.contextPath}/admin/users/"
                           style="font-size:0.8rem;font-weight:700;color:var(--pink-500);text-decoration:none;">
                            Xem tất cả →
                        </a>
                    </div>
                </div>
                <div class="card-body p-0">
                    <div class="admin-table-wrapper">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Họ Tên</th>
                                    <th>Email</th>
                                    <th>Vai Trò</th>
                                    <th>Trạng Thái</th>
                                    <th>Ngày Tạo</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty recentUsers}">
                                        <c:forEach var="u" items="${recentUsers}">
                                            <tr>
                                                <td style="color:var(--c-muted);font-size:0.8rem;">#${u.id}</td>
                                                <td style="font-weight:600;">${u.fullName}</td>
                                                <td style="color:var(--c-muted);font-size:0.82rem;">${u.email}</td>
                                                <td>
                                                    <span class="badge-role-tag">
                                                        ${not empty u.roleName ? u.roleName : u.roleId}
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="badge-status badge-status-${fn:toLowerCase(u.status)}">
                                                        ${u.status}
                                                    </span>
                                                </td>
                                                <td style="color:var(--c-muted);font-size:0.8rem;">
                                                    <c:choose>
                                                        <c:when test="${not empty u.createdAt}">
                                                            <fmt:formatDate value="${u.createdAt}" pattern="dd/MM/yyyy" />
                                                        </c:when>
                                                        <c:otherwise>—</c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6" class="p-0">
                                                <div class="admin-empty-state">
                                                    <i class="bi bi-inbox"></i>
                                                    <h6>Chưa có dữ liệu</h6>
                                                    <p>Chưa có người dùng nào trong hệ thống.</p>
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
        </div>

        <%-- Right Column --%>
        <div class="col-lg-4 d-flex flex-column gap-3">

            <%-- Quick Actions --%>
            <div class="admin-card">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-lightning-charge-fill"></i>
                        Thao Tác Nhanh
                    </h5>
                </div>
                <div class="card-body">
                    <a href="${pageContext.request.contextPath}/admin/users/" class="quick-action-btn">
                        <div class="quick-action-icon"><i class="bi bi-person-plus-fill"></i></div>
                        <div class="quick-action-text">
                            <span>Thêm Người Dùng</span>
                            <small>Tạo tài khoản mới trong hệ thống</small>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/settings/" class="quick-action-btn">
                        <div class="quick-action-icon"><i class="bi bi-gear-fill"></i></div>
                        <div class="quick-action-text">
                            <span>Cài Đặt Hệ Thống</span>
                            <small>Cấu hình và tùy chỉnh phòng khám</small>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/audit-logs/" class="quick-action-btn">
                        <div class="quick-action-icon"><i class="bi bi-clipboard-data-fill"></i></div>
                        <div class="quick-action-text">
                            <span>Nhật Ký Hoạt Động</span>
                            <small>Theo dõi lịch sử thao tác</small>
                        </div>
                    </a>
                    <a href="#" class="quick-action-btn" style="margin-bottom:0;">
                        <div class="quick-action-icon"><i class="bi bi-file-earmark-bar-graph-fill"></i></div>
                        <div class="quick-action-text">
                            <span>Báo Cáo &amp; Thống Kê</span>
                            <small>Xem phân tích chi tiết</small>
                        </div>
                    </a>
                </div>
            </div>

            <%-- System Info --%>
            <div class="admin-card flex-grow-1">
                <div class="card-header">
                    <h5>
                        <i class="bi bi-info-circle-fill"></i>
                        Thông Tin Hệ Thống
                    </h5>
                </div>
                <div class="card-body">
                    <ul class="admin-info-list">
                        <li>
                            <span class="info-label"><i class="bi bi-box-seam-fill"></i>Phiên bản</span>
                            <span class="info-value">v1.0.0</span>
                        </li>
                        <li>
                            <span class="info-label"><i class="bi bi-server"></i>Database</span>
                            <span class="info-value">SQL Server</span>
                        </li>
                        <li>
                            <span class="info-label"><i class="bi bi-hdd-stack-fill"></i>Server</span>
                            <span class="info-value">Tomcat 10.1</span>
                        </li>
                        <li>
                            <span class="info-label"><i class="bi bi-cpu-fill"></i>Java</span>
                            <span class="info-value">JDK 17 LTS</span>
                        </li>
                        <li>
                            <span class="info-label"><i class="bi bi-shield-lock-fill"></i>Bảo mật</span>
                            <span class="info-value good">
                                <i class="bi bi-check-circle-fill me-1"></i>BCrypt Active
                            </span>
                        </li>
                        <li>
                            <span class="info-label"><i class="bi bi-circle-fill" style="color:#10b981;"></i>Trạng thái</span>
                            <span class="info-value good">Hoạt động bình thường</span>
                        </li>
                    </ul>
                </div>
            </div>

        </div><%-- /col-lg-4 --%>
    </div><%-- /row --%>

</main>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeSidebar();
});

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
</body>
</html>
