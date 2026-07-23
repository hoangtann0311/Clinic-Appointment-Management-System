<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thống Kê Dịch Vụ — CAMS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        :root {
            --sidebar-w: 270px; --topbar-h: 66px;
            --pink-50: #F0F7FF; --pink-100: #E0EFFF; --pink-200: #BFDBFE;
            --pink-400: #60A5FA; --pink-500: #3B82F6; --pink-600: #2563EB; --pink-700: #1D4ED8;
            --c-bg:#EFF6FF; --c-surface:#fff; --c-primary:#2563EB; --c-primary-dark:#1D4ED8;
            --c-on-bg:#0F172A; --c-on-surface:#1E293B; --c-on-surface-var:#475569; --c-muted:#94A3B8;
            --c-outline-variant:#DBEAFE;
            --green-500:#10b981; --amber-500:#f59e0b; --blue-500:#3b82f6; --purple-500:#8b5cf6;
            --red-500:#ef4444; --cyan-500:#06b6d4;
            --shadow-sm: 0 2px 8px rgba(37,99,235,0.08); --shadow-md: 0 4px 20px rgba(37,99,235,0.12);
            --r-sm:8px; --r-md:12px; --r-lg:16px; --r-pill:999px;
            --t-fast:0.15s ease; --t-normal:0.25s ease;
            --font-display:'Nunito','Be Vietnam Pro',sans-serif;
            --font-body:'Inter','Be Vietnam Pro',sans-serif;
        }
        *,*::before,*::after{box-sizing:border-box}
        html{scroll-behavior:smooth}
        body{font-family:var(--font-body);background:var(--c-bg);color:var(--c-on-bg);margin:0;padding:0;line-height:1.6}
        h1,h2,h3,h4,h5,h6{font-family:var(--font-display)}
        .card{border:none;box-shadow:none;background:transparent}

        /* KPI Cards */
        .kpi-card{background:var(--c-surface)!important;border-radius:var(--r-lg)!important;border:1px solid var(--c-outline-variant)!important;box-shadow:var(--shadow-sm)!important;overflow:hidden;transition:transform var(--t-normal),box-shadow var(--t-normal);height:100%}
        .kpi-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md)!important}
        .kpi-card .card-body{padding:1.2rem 1.2rem!important;display:flex!important;align-items:center!important;gap:.9rem!important}
        .kpi-icon{width:50px;height:50px;border-radius:var(--r-md);display:flex;align-items:center;justify-content:center;font-size:1.3rem;flex-shrink:0}
        .kpi-content{flex:1;min-width:0}
        .kpi-value{font-family:var(--font-display);font-size:1.6rem;font-weight:900;color:var(--c-on-surface);line-height:1.1;letter-spacing:-.03em}
        .kpi-label{font-size:.78rem;font-weight:600;color:var(--c-on-surface-var);margin-top:.1rem}
        .kpi-sub{font-size:.68rem;font-weight:500;color:var(--c-muted);display:flex;align-items:center;gap:.25rem;margin-top:.15rem}

        .kpi-usage .card-body{border-top:3px solid #3B82F6!important}
        .kpi-usage .kpi-icon{background:#DBEAFE;color:#2563EB}
        .kpi-revenue .card-body{border-top:3px solid #10B981!important}
        .kpi-revenue .kpi-icon{background:#D1FAE5;color:#059669}
        .kpi-services .card-body{border-top:3px solid #8B5CF6!important}
        .kpi-services .kpi-icon{background:#EDE9FE;color:#6D28D9}
        .kpi-active-svc .card-body{border-top:3px solid #F59E0B!important}
        .kpi-active-svc .kpi-icon{background:#FEF3C7;color:#D97706}

        /* Admin Card */
        .admin-card{background:var(--c-surface)!important;border:1px solid var(--c-outline-variant)!important;border-radius:var(--r-lg)!important;box-shadow:var(--shadow-sm)!important;overflow:hidden}
        .admin-card .card-header{background:#F0F7FF!important;border-bottom:1px solid var(--c-outline-variant)!important;padding:.85rem 1.2rem!important}
        .admin-card .card-header h5{font-family:var(--font-display);font-size:.88rem;font-weight:800;color:var(--c-primary-dark);margin:0;display:flex;align-items:center;gap:.5rem}
        .admin-card .card-body{padding:1.2rem!important}

        .chart-container{position:relative;width:100%}
        .chart-container canvas{width:100%!important}

        .admin-table-wrapper{overflow-x:auto}
        .admin-table{width:100%;border-collapse:collapse;font-size:.85rem}
        .admin-table thead th{font-family:var(--font-display);font-size:.68rem;font-weight:800;text-transform:uppercase;letter-spacing:.06em;color:var(--c-primary);padding:.7rem .8rem;background:#F0F7FF;border-bottom:2px solid var(--c-outline-variant);white-space:nowrap}
        .admin-table tbody tr{border-bottom:1px solid var(--c-outline-variant);transition:background var(--t-fast)}
        .admin-table tbody tr:hover{background:#F0F7FF}
        .admin-table tbody td{padding:.65rem .8rem;color:var(--c-on-surface);vertical-align:middle}
        .admin-table.compact thead th{padding:.5rem .7rem}
        .admin-table.compact tbody td{padding:.45rem .7rem;font-size:.8rem}

        .trend-up{color:#059669;font-weight:700;font-size:.72rem}
        .trend-down{color:#DC2626;font-weight:700;font-size:.72rem}
        .trend-stable{color:var(--c-muted);font-weight:600;font-size:.72rem}

        .admin-empty-state{text-align:center;padding:2rem 1rem;color:var(--c-muted)}
        .admin-empty-state i{font-size:2rem;color:var(--pink-200);display:block;margin-bottom:.5rem}

        /* Service category dot */
        .cat-dot{display:inline-block;width:10px;height:10px;border-radius:50%;flex-shrink:0}

        /* Header filter */
        .header-date-filter{display:flex;align-items:center;gap:.5rem;flex-wrap:wrap}
        .date-input-group{display:flex;align-items:center;gap:.3rem;background:var(--c-surface);border:1.5px solid #BFDBFE;border-radius:var(--r-pill);padding:.3rem .3rem .3rem .75rem;transition:all var(--t-normal);box-shadow:0 1px 3px rgba(37,99,235,.05)}
        .date-input-group:focus-within{border-color:#60A5FA;box-shadow:0 0 0 3px rgba(59,130,246,.08)}
        .date-input-group .date-label{font-size:.63rem;font-weight:700;color:var(--c-muted);text-transform:uppercase;letter-spacing:.04em;white-space:nowrap}
        .date-input-group input[type="date"]{border:none;background:transparent;font-size:.75rem;font-weight:600;color:var(--c-on-surface);padding:.2rem .3rem;outline:none;font-family:var(--font-body);width:118px;cursor:pointer}
        .btn-header-date{display:inline-flex;align-items:center;gap:.3rem;padding:.4rem .9rem;border-radius:var(--r-pill);font-size:.73rem;font-weight:700;cursor:pointer;transition:all var(--t-fast);white-space:nowrap;border:none;text-decoration:none;line-height:1.4}
        .btn-header-apply{background:linear-gradient(135deg,#2563EB,#3B82F6);color:#fff;box-shadow:0 2px 6px rgba(37,99,235,.2)}
        .btn-header-apply:hover{box-shadow:0 4px 12px rgba(37,99,235,.35);transform:translateY(-1px);color:#fff}
        .btn-header-today{background:var(--c-surface);color:var(--c-primary);border:1.5px solid #BFDBFE}
        .btn-header-today:hover{background:#F0F7FF;border-color:#60A5FA}

        @media(max-width:1199.98px){.kpi-value{font-size:1.3rem}.kpi-icon{width:42px;height:42px;font-size:1.1rem}}
        @media(max-width:767.98px){.admin-main{padding:1rem}.kpi-value{font-size:1.15rem}.header-date-filter{flex-direction:column;align-items:stretch}}
    </style>
</head>
<body class="admin-body">

<%-- TOP BAR --%>
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

<%-- SIDEBAR --%>
<%@ include file="layout/sidebar.jsp" %>

<%-- MAIN --%>
<main class="admin-main" id="adminMain">

    <%-- Page Header + Date Filter --%>
    <div class="admin-page-header">
        <div style="flex:1;min-width:0;">
            <h1 class="admin-page-title">
                <i class="bi bi-graph-up-arrow me-2" style="color:var(--pink-500);"></i>Thống Kê Dịch Vụ
            </h1>
            <div style="display:flex;align-items:center;flex-wrap:wrap;gap:.75rem;">
                <div class="admin-page-subtitle" style="margin-bottom:0;">
                    <i class="bi bi-calendar3"></i> ${not empty todayDisplay ? todayDisplay : 'Hôm nay'}
                    <span class="mx-2">&middot;</span>
                    <i class="bi bi-pie-chart"></i> Phân tích hiệu suất dịch vụ y tế
                </div>
                <form method="get" action="${pageContext.request.contextPath}/manager/statistics/" class="header-date-filter">
                    <div class="date-input-group">
                        <span class="date-label">Từ</span>
                        <input type="date" name="dateFrom" id="dateFrom" value="${dateFrom}" max="${today}">
                    </div>
                    <span style="font-size:.7rem;font-weight:700;color:var(--c-muted);"><i class="bi bi-arrow-right"></i></span>
                    <div class="date-input-group">
                        <span class="date-label">Đến</span>
                        <input type="date" name="dateTo" id="dateTo" value="${dateTo}" max="${today}">
                    </div>
                    <button type="submit" class="btn-header-date btn-header-apply">
                        <i class="bi bi-check2"></i> Xem
                    </button>
                    <a href="${pageContext.request.contextPath}/manager/statistics/" class="btn-header-date btn-header-today">
                        <i class="bi bi-calendar-check"></i> Hôm nay
                    </a>
                </form>
            </div>
        </div>
        <button class="btn-refresh" onclick="location.reload()" title="Làm mới">
            <i class="bi bi-arrow-clockwise"></i> Làm mới
        </button>
    </div>

    <%-- ═══ KPI CARDS — Chỉ số riêng của Thống kê ═══ --%>
    <div class="row g-3 mb-4">
        <div class="col-xl-4 col-lg-6">
            <div class="card kpi-card kpi-services fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-activity"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty servicesUsed ? servicesUsed : 0}</div>
                        <div class="kpi-label">Dịch Vụ Được Sử Dụng</div>
                        <div class="kpi-sub"><i class="bi bi-database"></i> / ${activeServiceCount} DV đang hoạt động</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-4 col-lg-6">
            <div class="card kpi-card kpi-active-svc fade-in-up">
                <div class="card-body">
                    <div class="kpi-icon"><i class="bi bi-star-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value" style="font-size:.95rem;"><c:out value="${topServiceName}"/></div>
                        <div class="kpi-label">DV Nhiều Lượt SD Nhất</div>
                        <div class="kpi-sub"><i class="bi bi-graph-up"></i> ${topServiceUsage} lượt</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-4 col-lg-6">
            <div class="card kpi-card fade-in-up">
                <div class="card-body" style="border-top:3px solid #EF4444!important;">
                    <div class="kpi-icon" style="background:#FEE2E2;color:#DC2626;"><i class="bi bi-exclamation-triangle-fill"></i></div>
                    <div class="kpi-content">
                        <div class="kpi-value">${not empty lowPerforming ? lowPerforming.size() : 0}</div>
                        <div class="kpi-label">DV Hiệu Suất Thấp</div>
                        <div class="kpi-sub"><i class="bi bi-arrow-down"></i> Cần chú ý</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ═══ BIỂU ĐỒ: Doanh thu 12 tháng + Phân bổ nhóm ═══ --%>
    <div class="row g-3 mb-4">
        <div class="col-xl-7">
            <div class="admin-card h-100">
                <div class="card-header">
                    <h5><i class="bi bi-calendar-range"></i> Doanh Thu Dịch Vụ 12 Tháng Gần Nhất</h5>
                </div>
                <div class="card-body">
                    <div class="chart-container"><canvas id="monthlyRevenueChart" height="280"></canvas></div>
                </div>
            </div>
        </div>
        <div class="col-xl-5">
            <div class="admin-card h-100">
                <div class="card-header"><h5><i class="bi bi-pie-chart-fill"></i> Doanh Thu Theo Nhóm Dịch Vụ</h5></div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty categoryBreakdown}">
                            <c:set var="maxRev" value="0"/>
                            <c:forEach var="cat" items="${categoryBreakdown}">
                                <c:if test="${cat.totalRevenue > maxRev}"><c:set var="maxRev" value="${cat.totalRevenue}"/></c:if>
                            </c:forEach>
                            <c:forEach var="cat" items="${categoryBreakdown}" varStatus="row">
                                <c:set var="catColor" value="#6B7280"/>
                                <c:if test="${row.index == 0}"><c:set var="catColor" value="#3B82F6"/></c:if>
                                <c:if test="${row.index == 1}"><c:set var="catColor" value="#10B981"/></c:if>
                                <c:if test="${row.index == 2}"><c:set var="catColor" value="#F59E0B"/></c:if>
                                <c:if test="${row.index == 3}"><c:set var="catColor" value="#8B5CF6"/></c:if>
                                <c:if test="${row.index == 4}"><c:set var="catColor" value="#06B6D4"/></c:if>
                                <c:set var="barPct" value="${maxRev > 0 ? (cat.totalRevenue / maxRev * 100) : 0}"/>
                                <div style="margin-bottom:1rem;${row.last ? 'margin-bottom:0;' : ''}">
                                    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:.3rem;">
                                        <span style="display:flex;align-items:center;gap:.5rem;font-size:.82rem;font-weight:600;">
                                            <span class="cat-dot" style="background:${catColor};"></span>
                                            <c:out value="${cat.categoryName}"/>
                                        </span>
                                        <span style="font-family:var(--font-display);font-weight:700;font-size:.78rem;">
                                            <c:choose>
                                                <c:when test="${cat.totalRevenue >= 1000000}"><fmt:formatNumber value="${cat.totalRevenue / 1000000}" maxFractionDigits="1"/>M</c:when>
                                                <c:otherwise><fmt:formatNumber value="${cat.totalRevenue / 1000}" maxFractionDigits="0"/>K</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div style="height:6px;background:#E5E7EB;border-radius:3px;overflow:hidden;">
                                        <div style="height:100%;width:${barPct}%;background:${catColor};border-radius:3px;transition:width .6s ease;"></div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-empty-state"><i class="bi bi-pie-chart"></i><p>Chưa có dữ liệu phân bổ doanh thu.</p></div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <%-- ═══ DỊCH VỤ HIỆU SUẤT THẤP ═══ --%>
    <c:if test="${not empty lowPerforming}">
    <div class="row g-3 mb-4">
        <div class="col-12">
            <div class="admin-card">
                <div class="card-header"><h5><i class="bi bi-exclamation-triangle-fill" style="color:#EF4444;"></i> Dịch Vụ Cần Chú Ý (Hiệu Suất Thấp)</h5></div>
                <div class="card-body p-0">
                    <div class="admin-table-wrapper">
                        <table class="admin-table compact">
                            <thead><tr><th>#</th><th>Tên Dịch Vụ</th><th>Nhóm</th><th style="text-align:right;">Lượt SD</th><th style="text-align:right;">Đơn Giá</th></tr></thead>
                            <tbody>
                                <c:forEach var="svc" items="${lowPerforming}" varStatus="row">
                                    <tr>
                                        <td>${row.count}</td>
                                        <td><div style="font-weight:600;"><c:out value="${svc.serviceName}"/></div></td>
                                        <td style="font-size:.72rem;color:var(--c-muted);"><c:out value="${svc.categoryName}"/></td>
                                        <td style="font-family:var(--font-display);font-weight:600;color:#DC2626;text-align:right;">${svc.usageToday}</td>
                                        <td style="text-align:right;font-size:.78rem;color:var(--c-on-surface-var);"><fmt:formatNumber value="${svc.price}" pattern="#,###"/> đ</td>
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

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
// Sidebar toggle
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });
(function(){
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        var link = links[i];
        if (link.href && link.href !== window.location.origin + '/') {
            try { if (window.location.pathname.startsWith(new URL(link.href, location).pathname)) link.classList.add('active'); } catch(e) {}
        }
    }
})();
</script>

<script>
// ═══ CHARTS ═══
(function(){
    var purple500 = '#8B5CF6';

    // Monthly Revenue 12 Months
    var ctx3 = document.getElementById('monthlyRevenueChart');
    if (ctx3) {
        new Chart(ctx3, {
            type: 'bar',
            data: {
                labels: [<c:forEach items="${monthlyRevenueLabels}" var="lbl" varStatus="s">'${lbl}'<c:if test="${!s.last}">,</c:if></c:forEach>],
                datasets: [{ label:'Doanh thu', data:[<c:forEach items="${monthlyRevenueValues}" var="v" varStatus="s">${v}<c:if test="${!s.last}">,</c:if></c:forEach>], backgroundColor:purple500, borderRadius:6 }]
            },
            options:{ responsive:true, maintainAspectRatio:false, plugins:{ legend:{display:false} }, scales:{ y:{ ticks:{ callback:function(v){return v>=1e9?(v/1e9).toFixed(1)+'B':v>=1e6?(v/1e6).toFixed(0)+'M':v>=1e3?(v/1e3).toFixed(0)+'K':v;} } }, x:{ grid:{display:false} } } }
        });
    }
})();
</script>

<%@ include file="../common/standalone-footer.jsp" %>
</body>
</html>
