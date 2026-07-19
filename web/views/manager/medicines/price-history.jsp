<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Điều Chỉnh Giá Thuốc — CAMS Manager</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <style>
        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem; flex-wrap: wrap; gap: 1rem; }
        .page-header h1 { font-family: var(--font-display); font-weight: 800; font-size: 1.4rem; color: var(--c-primary-dark); margin: 0; }
        .btn-back {
            display: inline-flex; align-items: center; gap: 0.35rem;
            padding: 0.5rem 1rem; border-radius: var(--r-sm);
            background: var(--c-surface); border: 1px solid var(--c-outline);
            color: var(--c-on-surface-var); font-weight: 600; font-size: 0.85rem;
            text-decoration: none; transition: all var(--t-fast);
        }
        .btn-back:hover { background: var(--pink-50); border-color: var(--pink-300); color: var(--c-primary); }

        .admin-card { background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-lg); overflow: hidden; margin-bottom: 1.25rem; }
        .admin-card-header { background: var(--pink-50); padding: 0.85rem 1.2rem; border-bottom: 1px solid var(--pink-200); font-family: var(--font-display); font-weight: 700; color: var(--c-primary-dark); }
        .admin-table-wrapper { overflow-x: auto; }
        .admin-table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
        .admin-table th { background: var(--c-surface-variant); color: var(--c-on-surface-var); font-weight: 700; font-size: 0.73rem; text-transform: uppercase; letter-spacing: 0.04em; padding: 0.65rem 0.85rem; border-bottom: 2px solid var(--c-outline); }
        .admin-table td { padding: 0.7rem 0.85rem; border-bottom: 1px solid var(--c-outline-variant); vertical-align: middle; }
        .admin-table tbody tr:hover { background: #fff5f9; }
        .med-link { color: var(--c-primary); font-weight: 600; text-decoration: none; }
        .med-link:hover { text-decoration: underline; color: var(--pink-700); }
        .price-change { display: flex; align-items: center; gap: 0.4rem; font-size: 0.85rem; }
        .p-old { color: #c62828; text-decoration: line-through; font-weight: 600; }
        .p-arrow { color: var(--pink-500); }
        .p-new { color: #2e7d32; font-weight: 700; }
        .p-diff { font-size: 0.72rem; font-weight: 700; }
        .p-diff.up { color: #2e7d32; }
        .p-diff.down { color: #c62828; }
        .init-badge { background: var(--pink-100); color: var(--pink-700); font-size: 0.65rem; padding: 2px 8px; border-radius: var(--r-pill); font-weight: 700; }

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

        .kpi-mini-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 0.75rem; margin-bottom: 1.25rem; }
        .kpi-mini { background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-md); padding: 1rem; display: flex; align-items: center; gap: 0.75rem; }
        .kpi-mini-icon { width: 44px; height: 44px; border-radius: var(--r-sm); display: flex; align-items: center; justify-content: center; font-size: 1.1rem; color: #fff; }
        .kpi-mini-value { font-family: var(--font-display); font-size: 1.3rem; font-weight: 900; color: var(--c-on-surface); }
        .kpi-mini-label { font-size: 0.68rem; font-weight: 600; color: var(--c-muted); text-transform: uppercase; }
    </style>
</head>
<body class="admin-body">

<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/manager/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i> CAMS <span class="brand-badge">Manager</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role"><i class="bi bi-briefcase-fill me-1"></i>Manager</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout"><i class="bi bi-box-arrow-right"></i></a>
    </div>
</nav>

<%@ include file="../layout/sidebar.jsp" %>

<main class="admin-main" id="adminMain">

    <a href="${pageContext.request.contextPath}/manager/medicines/" class="btn-back mb-3">
        <i class="bi bi-arrow-left"></i> Quay lại Danh Mục Thuốc
    </a>

    <div class="page-header">
        <div>
            <h1><i class="bi bi-clock-history me-2" style="color:var(--pink-500);"></i>Lịch Sử Điều Chỉnh Giá Thuốc</h1>
            <div style="font-size:0.82rem;color:var(--c-muted);margin-top:0.2rem;">
                Toàn bộ lịch sử thay đổi giá của tất cả thuốc trong danh mục
            </div>
        </div>
    </div>

    <div class="kpi-mini-row">
        <div class="kpi-mini">
            <div class="kpi-mini-icon" style="background: linear-gradient(135deg, var(--pink-500), var(--pink-600));">
                <i class="bi bi-clock-history"></i>
            </div>
            <div>
                <div class="kpi-mini-value">${totalHistory}</div>
                <div class="kpi-mini-label">Tổng lần điều chỉnh giá</div>
            </div>
        </div>
    </div>

    <div class="admin-card">
        <div class="admin-card-header">
            <i class="bi bi-list-ul me-2"></i>Danh sách điều chỉnh giá thuốc
            <span class="badge bg-white text-dark border ms-2" style="font-size:0.7rem;">${totalHistory} bản ghi</span>
        </div>
        <div class="admin-table-wrapper">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Thuốc</th>
                        <th>Giá Cũ</th>
                        <th>Giá Mới</th>
                        <th>Thay Đổi</th>
                        <th>Lý Do</th>
                        <th>Người Thực Hiện</th>
                        <th>Thời Gian</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty historyList}">
                            <c:forEach var="h" items="${historyList}">
                                <tr>
                                    <td style="font-size:0.78rem;color:var(--c-muted);">#${h.id}</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/manager/medicines/?action=detail&id=${h.medicineId}" class="med-link">
                                            <c:if test="${not empty h.medicineCode}">
                                                <span style="font-size:0.7rem;color:var(--c-muted);">${fn:escapeXml(h.medicineCode)}</span><br>
                                            </c:if>
                                            ${fn:escapeXml(h.medicineName)}
                                        </a>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty h.oldPrice}">
                                                <span class="p-old"><fmt:formatNumber value="${h.oldPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="init-badge">KHỞI TẠO</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="p-new"><fmt:formatNumber value="${h.newPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                                    </td>
                                    <td>
                                        <c:if test="${not empty h.oldPrice}">
                                            <c:set var="diff" value="${h.newPrice.subtract(h.oldPrice)}"/>
                                            <span class="p-diff ${diff.signum() >= 0 ? 'up' : 'down'}">
                                                ${diff.signum() >= 0 ? '+' : ''}<fmt:formatNumber value="${diff}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            </span>
                                        </c:if>
                                        <c:if test="${empty h.oldPrice}">
                                            <span style="color:var(--c-muted);">—</span>
                                        </c:if>
                                    </td>
                                    <td style="max-width:200px;">
                                        <span style="font-size:0.8rem;" title="${fn:escapeXml(h.changeReason)}">
                                            ${not empty h.changeReason ? fn:escapeXml(h.changeReason) : '—'}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty h.changedByName}">
                                                <span style="font-size:0.8rem;"><i class="bi bi-person me-1"></i>${fn:escapeXml(h.changedByName)}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:var(--c-muted);font-size:0.75rem;">Hệ thống</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="font-size:0.78rem;color:var(--c-muted);white-space:nowrap;">
                                        <fmt:formatDate value="${h.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="8">
                                    <div style="text-align:center;padding:3rem 1rem;color:var(--c-muted);">
                                        <i class="bi bi-clock-history" style="font-size:2.5rem;"></i>
                                        <h6 class="mt-2">Chưa có lịch sử điều chỉnh giá thuốc</h6>
                                        <p style="font-size:0.8rem;">Dữ liệu sẽ xuất hiện khi bạn thay đổi giá thuốc lần đầu tiên.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <c:if test="${totalPages > 1}">
        <div class="admin-pagination">
            <c:url var="baseUrl" value="/manager/medicines/">
                <c:param name="action" value="price-history"/>
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
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
<script>
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        if (links[i].href && links[i].href.indexOf('/manager/medicines') !== -1) {
            links[i].classList.add('active');
        }
    }
})();
</script>

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
