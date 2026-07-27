<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo Cáo Doanh Thu — CAMS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        .revenue-kpi {
            background: var(--c-surface); border-radius: var(--r-lg);
            border: 1px solid var(--c-outline-variant);
            box-shadow: var(--shadow-sm); padding: 1.25rem 1.5rem;
            display: flex; align-items: center; gap: 1rem;
        }
        .revenue-kpi-icon {
            width: 52px; height: 52px; border-radius: var(--r-md);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem; flex-shrink: 0;
        }
        .revenue-kpi-total .revenue-kpi-icon { background: #D1FAE5; color: #059669; }
        .revenue-kpi-sum .revenue-kpi-icon { background: #DBEAFE; color: #2563EB; }
        .revenue-kpi-value {
            font-family: 'Nunito','Be Vietnam Pro',sans-serif;
            font-size: 1.6rem; font-weight: 900; color: var(--c-on-surface);
            line-height: 1.2;
        }
        .revenue-kpi-label {
            font-size: 0.78rem; font-weight: 600; color: var(--c-on-surface-var);
        }

        .filter-bar {
            background: var(--c-surface); border: 1px solid var(--c-outline-variant);
            border-radius: var(--r-lg); padding: 1rem 1.25rem; margin-bottom: 1.25rem;
            box-shadow: var(--shadow-xs);
        }
        .filter-bar .form-control, .filter-bar .form-select {
            font-size: 0.85rem; border-radius: var(--r-sm);
            border: 1.5px solid var(--c-outline);
        }
        .filter-bar .form-control:focus, .filter-bar .form-select:focus {
            border-color: var(--pink-400); box-shadow: 0 0 0 3px rgba(37,99,235,0.08);
        }
        .filter-bar .input-group-text {
            background: var(--c-surface-variant); border: 1.5px solid var(--c-outline);
            font-size: 0.75rem; font-weight: 600; color: var(--c-on-surface-var);
            border-radius: var(--r-sm) 0 0 var(--r-sm);
        }
        .btn-filter-apply {
            background: linear-gradient(135deg, var(--pink-500), var(--pink-600));
            color: #fff; border: none; border-radius: var(--r-sm);
            font-weight: 700; font-size: 0.82rem; padding: 0.45rem 1rem;
            transition: all var(--t-fast);
        }
        .btn-filter-apply:hover { box-shadow: var(--shadow-pink); transform: translateY(-1px); color: #fff; }
        .btn-filter-reset {
            background: var(--c-surface); color: var(--c-on-surface-var);
            border: 1.5px solid var(--c-outline); border-radius: var(--r-sm);
            font-weight: 600; font-size: 0.82rem; padding: 0.45rem 1rem;
            transition: all var(--t-fast); text-decoration: none;
        }
        .btn-filter-reset:hover { background: var(--c-surface-variant); }

        .admin-table tbody td { vertical-align: middle; }
        .status-badge {
            display: inline-block; padding: 3px 10px; border-radius: var(--r-pill);
            font-size: 0.7rem; font-weight: 700;
        }
        .status-paid { background: #D1FAE5; color: #065F46; }
        .status-pending { background: #FEF3C7; color: #92400E; }
        .status-cancelled { background: #FEE2E2; color: #991B1B; }
        .status-unpaid { background: #F3F4F6; color: #6B7280; }

        .btn-eye {
            display: inline-flex; align-items: center; gap: 0.25rem;
            padding: 0.3rem 0.65rem; border-radius: var(--r-sm);
            background: var(--c-surface); border: 1.5px solid var(--pink-200);
            color: var(--pink-600); font-size: 0.75rem; font-weight: 600;
            text-decoration: none; transition: all var(--t-fast); white-space: nowrap;
        }
        .btn-eye:hover { background: var(--pink-50); border-color: var(--pink-400); color: var(--pink-700); }

        .amount-cell {
            font-family: 'Nunito','Be Vietnam Pro',sans-serif;
            font-weight: 700; color: #059669;
        }
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
            CAMS <span class="brand-badge">Quản Lý</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="dropdown admin-topbar-dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle"
               id="adminUserDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="admin-avatar-sm me-2">
                    ${not empty sessionScope.user.fullName ? fn:substring(sessionScope.user.fullName, 0, 1) : '?'}
                </div>
                <span class="d-none d-md-inline fw-semibold text-dark">${sessionScope.user.fullName}</span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg rounded-3" aria-labelledby="adminUserDropdown">
                <li class="dropdown-header">
                    <h6 class="text-dark mb-0 fw-bold">${sessionScope.user.fullName}</h6>
                    <small class="text-muted">Quản lý</small>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li>
                    <a class="dropdown-item" href="${pageContext.request.contextPath}/manager/profile">
                        <i class="bi bi-person-circle me-2 text-muted"></i>Hồ Sơ Cá Nhân
                    </a>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li>
                    <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">
                        <i class="bi bi-box-arrow-right me-2"></i>Đăng Xuất
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<%-- SIDEBAR --%>
<%@ include file="../layout/sidebar.jsp" %>

<%-- MAIN CONTENT --%>
<main class="admin-main" id="adminMain">

    <%-- Page Header --%>
    <div class="admin-page-header">
        <div class="admin-page-header-left">
            <h1 class="admin-page-title">
                <i class="bi bi-cash-stack me-2" style="color:var(--pink-500);"></i>Báo Cáo Doanh Thu
            </h1>
            <p class="admin-page-subtitle">
                <i class="bi bi-calendar3"></i> ${dateRangeLabel}
                <span class="mx-2">&middot;</span>
                <i class="bi bi-info-circle"></i> Chỉ tính giao dịch đã thanh toán thành công
            </p>
        </div>
        <button class="btn-refresh" onclick="location.reload()" title="Làm mới dữ liệu">
            <i class="bi bi-arrow-clockwise"></i> Làm mới
        </button>
    </div>

    <%-- ═══ KPI CARDS ═══ --%>
    <div class="row g-3 mb-4">
        <div class="col-md-6">
            <div class="revenue-kpi revenue-kpi-total">
                <div class="revenue-kpi-icon"><i class="bi bi-check-circle-fill"></i></div>
                <div>
                    <div class="revenue-kpi-value">${totalPaidCount}</div>
                    <div class="revenue-kpi-label">Tổng số giao dịch đã thanh toán thành công</div>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="revenue-kpi revenue-kpi-sum">
                <div class="revenue-kpi-icon"><i class="bi bi-cash-coin"></i></div>
                <div>
                    <div class="revenue-kpi-value">
                    <fmt:formatNumber value="${totalPaidRevenue}" pattern="#,###"/> VNĐ
                </div>
                    <div class="revenue-kpi-label">Tổng doanh thu từ giao dịch thành công</div>
                </div>
            </div>
        </div>
    </div>

    <%-- ═══ FILTER BAR ═══ --%>
    <form method="get" action="${pageContext.request.contextPath}/manager/revenue/" class="filter-bar">
        <div class="row g-2 align-items-end">
            <div class="col-md-3">
                <label class="form-label fw-semibold small text-muted mb-1">Tìm kiếm</label>
                <input type="text" name="search" class="form-control" placeholder="Tên BN, mã GD, bác sĩ..."
                       value="${fn:escapeXml(search)}">
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold small text-muted mb-1">Trạng thái</label>
                <select name="status" class="form-select">
                    <option value="Paid" ${statusFilter == 'Paid' ? 'selected' : ''}>Đã thanh toán</option>
                    <option value="PendingConfirmation" ${statusFilter == 'PendingConfirmation' ? 'selected' : ''}>Chờ xác nhận</option>
                    <option value="Unpaid" ${statusFilter == 'Unpaid' ? 'selected' : ''}>Chưa thanh toán</option>
                    <option value="Cancelled" ${statusFilter == 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                    <option value="" ${empty statusFilter ? 'selected' : ''}>Tất cả</option>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold small text-muted mb-1">Từ ngày</label>
                <input type="date" name="dateFrom" class="form-control" value="${dateFrom}" max="${today}">
            </div>
            <div class="col-md-2">
                <label class="form-label fw-semibold small text-muted mb-1">Đến ngày</label>
                <input type="date" name="dateTo" class="form-control" value="${dateTo}" max="${today}">
            </div>
            <div class="col-md-3 d-flex align-items-end gap-2">
                <button type="submit" class="btn-filter-apply">
                    <i class="bi bi-funnel-fill me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/manager/revenue/" class="btn-filter-reset">
                    <i class="bi bi-arrow-repeat me-1"></i>Đặt lại
                </a>
            </div>
        </div>
    </form>

    <%-- ═══ ALERTS ═══ --%>
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>${success}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <%-- ═══ TABLE ═══ --%>
    <div class="admin-card">
        <div class="card-header d-flex align-items-center justify-content-between">
            <h5><i class="bi bi-list-ul"></i> Danh Sách Giao Dịch</h5>
            <small class="text-muted">${totalInvoices} giao dịch</small>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty invoices}">
                    <div class="admin-table-wrapper">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Mã HĐ</th>
                                    <th>Bệnh Nhân</th>
                                    <th>Dịch Vụ</th>
                                    <th>Bác Sĩ</th>
                                    <th>Ngày Thanh Toán</th>
                                    <th>Phương Thức</th>
                                    <th style="text-align:right;">Số Tiền</th>
                                    <th>Trạng Thái</th>
                                    <th style="text-align:center;">Chi Tiết</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="inv" items="${invoices}">
                                    <tr>
                                        <td>
                                            <span style="font-weight:600;">#${inv.id}</span>
                                            <c:if test="${not empty inv.transactionCode}">
                                                <div style="font-size:0.68rem;color:var(--c-muted);">${fn:escapeXml(inv.transactionCode)}</div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <div style="font-weight:600;">${not empty inv.patientName ? fn:escapeXml(inv.patientName) : '—'}</div>
                                            <c:if test="${not empty inv.patientPhone}">
                                                <div style="font-size:0.7rem;color:var(--c-muted);">${fn:escapeXml(inv.patientPhone)}</div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty inv.serviceName}">
                                                    ${fn:escapeXml(inv.serviceName)}
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty inv.invoiceType}">
                                                <span style="font-size:0.65rem;background:var(--c-surface-variant);padding:1px 6px;border-radius:4px;margin-left:4px;">
                                                    <c:choose>
                                                        <c:when test="${inv.invoiceType == 'PRE_EXAM'}">Khám</c:when>
                                                        <c:when test="${inv.invoiceType == 'POST_EXAM'}">XN</c:when>
                                                        <c:when test="${inv.invoiceType == 'PRESCRIPTION'}">Thuốc</c:when>
                                                        <c:otherwise>${fn:escapeXml(inv.invoiceType)}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </c:if>
                                        </td>
                                        <td>${not empty inv.doctorName ? fn:escapeXml(inv.doctorName) : '—'}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty inv.confirmedAt}">
                                                    <fmt:formatDate value="${inv.confirmedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:when>
                                                <c:when test="${not empty inv.createdAt}">
                                                    <fmt:formatDate value="${inv.createdAt}" pattern="dd/MM/yyyy"/>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${inv.paymentMethod == 'Cash'}">
                                                    <span style="color:#059669;"><i class="bi bi-cash me-1"></i>Tiền mặt</span>
                                                </c:when>
                                                <c:when test="${inv.paymentMethod == 'BankTransfer'}">
                                                    <span style="color:#2563EB;"><i class="bi bi-bank me-1"></i>CK</span>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="amount-cell" style="text-align:right;">
                                            <fmt:formatNumber value="${inv.totalAmount}" pattern="#,###"/> VNĐ
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${inv.status == 'Paid'}">
                                                    <span class="status-badge status-paid">Đã TT</span>
                                                </c:when>
                                                <c:when test="${inv.status == 'PendingConfirmation'}">
                                                    <span class="status-badge status-pending">Chờ XN</span>
                                                </c:when>
                                                <c:when test="${inv.status == 'Cancelled'}">
                                                    <span class="status-badge status-cancelled">Đã hủy</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-unpaid">${fn:escapeXml(inv.status)}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:center;">
                                            <a href="${pageContext.request.contextPath}/manager/revenue/?action=detail&id=${inv.id}"
                                               class="btn-eye" title="Xem chi tiết">
                                                <i class="bi bi-eye-fill"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <%-- Pagination --%>
                    <c:if test="${totalPages > 1}">
                        <div class="d-flex justify-content-center align-items-center gap-2 p-3">
                            <c:if test="${currentPage > 1}">
                                <a href="?page=${currentPage - 1}&search=${fn:escapeXml(search)}&status=${fn:escapeXml(statusFilter)}&dateFrom=${dateFrom}&dateTo=${dateTo}"
                                   class="btn btn-sm btn-outline-secondary">&laquo; Trước</a>
                            </c:if>
                            <span class="text-muted small">Trang ${currentPage} / ${totalPages}</span>
                            <c:if test="${currentPage < totalPages}">
                                <a href="?page=${currentPage + 1}&search=${fn:escapeXml(search)}&status=${fn:escapeXml(statusFilter)}&dateFrom=${dateFrom}&dateTo=${dateTo}"
                                   class="btn btn-sm btn-outline-secondary">Sau &raquo;</a>
                            </c:if>
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="admin-empty-state">
                        <i class="bi bi-cash-stack"></i>
                        <h6>Không có giao dịch nào</h6>
                        <p>Chưa có giao dịch thanh toán nào được ghi nhận với bộ lọc hiện tại.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });
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

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
