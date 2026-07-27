<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Bác Sĩ — CAMS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        .filter-bar {
            background: var(--c-surface); border: 1px solid var(--c-outline-variant);
            border-radius: var(--r-lg); padding: 1rem 1.25rem; margin-bottom: 1.25rem;
            box-shadow: var(--shadow-xs);
        }
        .btn-filter-apply {
            background: linear-gradient(135deg, var(--pink-500), var(--pink-600));
            color: #fff; border: none; border-radius: var(--r-sm);
            font-weight: 700; font-size: 0.82rem; padding: 0.45rem 1rem;
        }
        .btn-filter-apply:hover { box-shadow: var(--shadow-pink); transform: translateY(-1px); color: #fff; }
        .btn-filter-reset {
            background: var(--c-surface); color: var(--c-on-surface-var);
            border: 1.5px solid var(--c-outline); border-radius: var(--r-sm);
            font-weight: 600; font-size: 0.82rem; padding: 0.45rem 1rem;
            text-decoration: none;
        }
        .btn-filter-reset:hover { background: var(--c-surface-variant); }
        .btn-eye {
            display: inline-flex; align-items: center; gap: 0.25rem;
            padding: 0.3rem 0.65rem; border-radius: var(--r-sm);
            background: var(--c-surface); border: 1.5px solid var(--pink-200);
            color: var(--pink-600); font-size: 0.75rem; font-weight: 600;
            text-decoration: none; transition: all var(--t-fast); white-space: nowrap;
        }
        .btn-eye:hover { background: var(--pink-50); border-color: var(--pink-400); color: var(--pink-700); }
        .status-active { background: #D1FAE5; color: #065F46; }
        .status-inactive { background: #FEE2E2; color: #991B1B; }
        .specialty-tag {
            display: inline-block; padding: 2px 10px; border-radius: var(--r-pill);
            font-size: 0.7rem; font-weight: 600;
            background: var(--pink-50); color: var(--pink-700);
            border: 1px solid var(--pink-200);
        }
        .doc-avatar {
            width: 36px; height: 36px; border-radius: 50%;
            background: var(--pink-100); color: var(--pink-600);
            display: flex; align-items: center; justify-content: center;
            font-size: 0.85rem; font-weight: 700; flex-shrink: 0;
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
            <i class="bi bi-hospital-fill"></i> CAMS <span class="brand-badge">Quản Lý</span>
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
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/manager/profile"><i class="bi bi-person-circle me-2 text-muted"></i>Hồ Sơ Cá Nhân</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng Xuất</a></li>
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
                <i class="bi bi-person-badge-fill me-2" style="color:var(--pink-500);"></i>Quản Lý Bác Sĩ
            </h1>
            <p class="admin-page-subtitle">
                <i class="bi bi-eye"></i> Chế độ chỉ xem — không thể thêm, sửa hoặc xóa bác sĩ
                <span class="mx-2">&middot;</span>
                <i class="bi bi-people-fill"></i> ${totalDoctors} bác sĩ
            </p>
        </div>
        <button class="btn-refresh" onclick="location.reload()" title="Làm mới dữ liệu">
            <i class="bi bi-arrow-clockwise"></i> Làm mới
        </button>
    </div>

    <%-- ═══ FILTER BAR ═══ --%>
    <form method="get" action="${pageContext.request.contextPath}/manager/doctors/" class="filter-bar">
        <div class="row g-2 align-items-end">
            <div class="col-md-4">
                <label class="form-label fw-semibold small text-muted mb-1">Tìm kiếm</label>
                <input type="text" name="search" class="form-control"
                       placeholder="Tên, chuyên khoa, email, SĐT..."
                       value="${fn:escapeXml(search)}">
            </div>
            <div class="col-md-3 d-flex align-items-end gap-2">
                <button type="submit" class="btn-filter-apply">
                    <i class="bi bi-search me-1"></i>Tìm
                </button>
                <a href="${pageContext.request.contextPath}/manager/doctors/" class="btn-filter-reset">
                    <i class="bi bi-arrow-repeat me-1"></i>Đặt lại
                </a>
            </div>
        </div>
    </form>

    <%-- ═══ ALERTS ═══ --%>
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <%-- ═══ TABLE ═══ --%>
    <div class="admin-card">
        <div class="card-header d-flex align-items-center justify-content-between">
            <h5><i class="bi bi-list-ul"></i> Danh Sách Bác Sĩ</h5>
            <small class="text-muted">${totalDoctors} bác sĩ</small>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty doctors}">
                    <div class="admin-table-wrapper">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Mã BS</th>
                                    <th>Họ và Tên</th>
                                    <th>Chuyên Khoa</th>
                                    <th>SĐT</th>
                                    <th>Email</th>
                                    <th>Kinh Nghiệm</th>
                                    <th>Trạng Thái</th>
                                    <th style="text-align:center;">Chi Tiết</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="doc" items="${doctors}">
                                    <tr>
                                        <td style="font-weight:600;">#${doc.id}</td>
                                        <td>
                                            <div style="display:flex;align-items:center;gap:0.5rem;">
                                                <div class="doc-avatar">
                                                    ${fn:substring(doc.fullName, 0, 1)}
                                                </div>
                                                <span style="font-weight:600;">${fn:escapeXml(doc.fullName)}</span>
                                            </div>
                                        </td>
                                        <td>
                                            <c:if test="${not empty doc.specialization}">
                                                <span class="specialty-tag">${fn:escapeXml(doc.specialization)}</span>
                                            </c:if>
                                        </td>
                                        <td>${not empty doc.phoneNumber ? doc.phoneNumber : '—'}</td>
                                        <td>
                                            <span style="font-size:0.85rem;">${not empty doc.email ? doc.email : '—'}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${doc.experienceYears > 0}">
                                                    ${doc.experienceYears} năm
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${doc.userStatus == 'Active'}">
                                                    <span class="badge-status status-active">Đang làm việc</span>
                                                </c:when>
                                                <c:when test="${doc.userStatus == 'Inactive'}">
                                                    <span class="badge-status status-inactive">Ngừng làm việc</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status" style="background:#F3F4F6;color:#6B7280;">${not empty doc.userStatus ? fn:escapeXml(doc.userStatus) : '—'}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:center;">
                                            <a href="${pageContext.request.contextPath}/manager/doctors/?action=detail&id=${doc.id}"
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
                                <a href="?page=${currentPage - 1}&search=${fn:escapeXml(search)}"
                                   class="btn btn-sm btn-outline-secondary">&laquo; Trước</a>
                            </c:if>
                            <span class="text-muted small">Trang ${currentPage} / ${totalPages}</span>
                            <c:if test="${currentPage < totalPages}">
                                <a href="?page=${currentPage + 1}&search=${fn:escapeXml(search)}"
                                   class="btn btn-sm btn-outline-secondary">Sau &raquo;</a>
                            </c:if>
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="admin-empty-state">
                        <i class="bi bi-person-x"></i>
                        <h6>Không tìm thấy bác sĩ nào</h6>
                        <p>Không có bác sĩ nào khớp với tiêu chí tìm kiếm.</p>
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
