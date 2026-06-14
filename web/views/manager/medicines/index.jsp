<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Mục Thuốc — CAMS Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        .page-header-gradient {
            background: linear-gradient(135deg, #fff0f6 0%, #ffe0ef 40%, #fce4ec 100%);
            border-radius: var(--r-lg); padding: 1.5rem 1.75rem; margin-bottom: 1.5rem;
            border: 1px solid var(--pink-200); display: flex; align-items: center;
            justify-content: space-between; flex-wrap: wrap; gap: 1rem;
        }
        .page-header-gradient h1 { font-family: var(--font-display); font-weight: 800; font-size: 1.5rem; color: var(--c-primary-dark); margin: 0; }
        .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 1.5rem; }
        .kpi-card { background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-md); padding: 1.2rem; display: flex; align-items: center; gap: 1rem; transition: all var(--t-slow); cursor: pointer; position: relative; overflow: hidden; }
        .kpi-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); border-color: var(--pink-200); }
        .kpi-icon { width: 48px; height: 48px; border-radius: var(--r-sm); display: flex; align-items: center; justify-content: center; font-size: 1.4rem; flex-shrink: 0; color: #fff; }
        .kpi-icon.ki-total { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); }
        .kpi-icon.ki-active { background: linear-gradient(135deg, #43a047, #2e7d32); }
        .kpi-icon.ki-inactive { background: linear-gradient(135deg, #ff9800, #e65100); }
        .kpi-icon.ki-cat { background: linear-gradient(135deg, #22d3ee, #0891b2); }
        .kpi-body { flex: 1; min-width: 0; }
        .kpi-value { font-family: var(--font-display); font-size: 1.5rem; font-weight: 900; color: var(--c-on-surface); line-height: 1.1; }
        .kpi-label { font-size: 0.72rem; font-weight: 600; color: var(--c-muted); text-transform: uppercase; letter-spacing: 0.05em; }
        .category-chips { display: flex; flex-wrap: wrap; gap: 0.4rem; padding: 0.75rem 1rem; background: var(--c-surface); border-bottom: 1px solid var(--c-outline-variant); }
        .cat-chip { display: inline-flex; align-items: center; gap: 0.35rem; padding: 0.4rem 0.85rem; border-radius: var(--r-pill); font-size: 0.78rem; font-weight: 600; border: 1px solid var(--c-outline); color: var(--c-on-surface-var); background: var(--c-surface); text-decoration: none; transition: all var(--t-fast); white-space: nowrap; }
        .cat-chip:hover { background: var(--pink-50); border-color: var(--pink-300); color: var(--c-primary); }
        .cat-chip.active { background: var(--pink-500); color: #fff; border-color: var(--pink-500); }
        .cat-chip .cat-count { font-size: 0.68rem; opacity: 0.8; }
        .filter-bar { display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: center; padding: 0.75rem 1rem; background: var(--c-surface); border-bottom: 1px solid var(--c-outline-variant); }
        .filter-bar .form-control, .filter-bar .form-select { width: auto; min-width: 140px; border-radius: var(--r-sm); border: 1px solid var(--c-outline); font-size: 0.82rem; padding: 0.4rem 0.7rem; }
        .admin-card { background: var(--c-surface); border: 1px solid var(--c-outline-variant); border-radius: var(--r-lg); overflow: hidden; }
        .admin-card-header { background: var(--pink-50); padding: 0.85rem 1.2rem; border-bottom: 1px solid var(--pink-200); display: flex; align-items: center; justify-content: space-between; }
        .admin-card-header h5 { margin: 0; font-family: var(--font-display); font-weight: 700; color: var(--c-primary-dark); font-size: 0.95rem; }
        .admin-table-wrapper { overflow-x: auto; }
        .admin-table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
        .admin-table th { background: var(--c-surface-variant); color: var(--c-on-surface-var); font-weight: 700; font-size: 0.73rem; text-transform: uppercase; letter-spacing: 0.04em; padding: 0.65rem 0.85rem; border-bottom: 2px solid var(--c-outline); white-space: nowrap; }
        .admin-table td { padding: 0.7rem 0.85rem; border-bottom: 1px solid var(--c-outline-variant); vertical-align: middle; }
        .admin-table tbody tr:hover { background: #fff5f9; }
        .cat-badge { display: inline-flex; align-items: center; gap: 0.25rem; padding: 2px 10px; border-radius: var(--r-pill); font-size: 0.7rem; font-weight: 700; background: var(--pink-50); color: var(--pink-600); border: 1px solid var(--pink-200); }
        .action-btn { width: 32px; height: 32px; border-radius: var(--r-sm); border: 1px solid var(--c-outline); display: inline-flex; align-items: center; justify-content: center; font-size: 0.85rem; color: var(--c-on-surface-var); background: var(--c-surface); transition: all var(--t-fast); cursor: pointer; text-decoration: none; }
        .action-btn:hover { background: var(--pink-50); border-color: var(--pink-300); color: var(--pink-600); }
        .btn-primary-pink { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); color: #fff; border: none; font-weight: 700; border-radius: var(--r-sm); padding: 0.5rem 1.1rem; transition: all var(--t-fast); }
        .btn-primary-pink:hover { background: linear-gradient(135deg, var(--pink-600), var(--pink-700)); color: #fff; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(233,30,140,0.3); }
        .btn-outline-pink { background: #fff; border: 1.5px solid var(--pink-300); color: var(--pink-600); font-weight: 600; border-radius: var(--r-sm); padding: 0.5rem 1.1rem; transition: all var(--t-fast); text-decoration: none; display: inline-flex; align-items: center; gap: 0.35rem; }
        .btn-outline-pink:hover { background: var(--pink-50); border-color: var(--pink-500); color: var(--pink-600); }
        .stock-low { color: #c62828; font-weight: 700; font-size: 0.78rem; background: #ffebee; padding: 2px 10px; border-radius: var(--r-pill); }
        .stock-warn { color: #e65100; font-weight: 700; }
        .stock-ok { color: #2e7d32; font-weight: 600; }
        .admin-pagination { display: flex; justify-content: center; gap: 0.2rem; margin-top: 1rem; padding: 0.5rem; }
        .admin-pagination a, .admin-pagination span { display: inline-flex; align-items: center; justify-content: center; min-width: 36px; height: 36px; padding: 0 0.4rem; border-radius: var(--r-sm); font-size: 0.82rem; font-weight: 600; text-decoration: none; border: 1px solid var(--c-outline-variant); color: var(--c-on-surface-var); transition: all var(--t-fast); }
        .admin-pagination a:hover { background: var(--pink-50); border-color: var(--pink-200); color: var(--c-primary); }
        .admin-pagination .active { background: var(--pink-500); color: #fff; border-color: var(--pink-500); }
        .modal-content { border-radius: var(--r-lg) !important; border: 1px solid var(--c-outline-variant) !important; overflow: hidden; }
        .modal-header { background: var(--pink-50) !important; border-bottom: 1px solid var(--pink-200) !important; }
        .modal-header .modal-title { font-family: var(--font-display); font-weight: 800; color: var(--c-primary-dark); }
        .form-section-title { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: var(--c-primary); padding-bottom: 0.4rem; margin-bottom: 0.75rem; border-bottom: 2px solid var(--pink-100); }
    </style>
</head>
<body class="admin-body">

<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle"><i class="bi bi-list"></i></button>
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

    <%-- Page Header --%>
    <div class="page-header-gradient">
        <div>
            <h1><i class="bi bi-capsule me-2" style="color:var(--pink-500);"></i>Danh Mục Thuốc</h1>
            <div style="font-size:0.82rem;color:var(--c-muted);margin-top:0.2rem;">
                <i class="bi bi-prescription2 me-1"></i>Quản lý danh mục, giá và tồn kho thuốc — Phòng khám Sản Phụ Khoa
            </div>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/manager/medicines/?action=price-history" class="btn btn-outline-pink">
                <i class="bi bi-clock-history me-1"></i>Lịch Sử Giá
            </a>
            <button class="btn btn-primary-pink" data-bs-toggle="modal" data-bs-target="#addMedicineModal">
                <i class="bi bi-plus-circle-fill me-1"></i>Thêm Thuốc Mới
            </button>
        </div>
    </div>

    <%-- KPI Cards --%>
    <div class="kpi-grid">
        <div class="kpi-card" onclick="window.location='${pageContext.request.contextPath}/manager/medicines/'">
            <div class="kpi-icon ki-total"><i class="bi bi-capsule-fill"></i></div>
            <div class="kpi-body"><div class="kpi-value">${totalMedicines}</div><div class="kpi-label">Tổng Số Thuốc</div></div>
        </div>
        <div class="kpi-card" onclick="window.location='${pageContext.request.contextPath}/manager/medicines/?active=1'">
            <div class="kpi-icon ki-active"><i class="bi bi-check-circle-fill"></i></div>
            <div class="kpi-body"><div class="kpi-value">${activeMedicinesCount}</div><div class="kpi-label">Đang Sử Dụng</div></div>
        </div>
        <div class="kpi-card" onclick="window.location='${pageContext.request.contextPath}/manager/medicines/?active=0'">
            <div class="kpi-icon ki-inactive"><i class="bi bi-slash-circle-fill"></i></div>
            <div class="kpi-body"><div class="kpi-value">${totalMedicines - activeMedicinesCount}</div><div class="kpi-label">Ngừng Sử Dụng</div></div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon ki-cat"><i class="bi bi-collection-fill"></i></div>
            <div class="kpi-body"><div class="kpi-value">${fn:length(categories)}</div><div class="kpi-label">Nhóm Thuốc</div></div>
        </div>
    </div>

    <%-- Alerts --%>
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md); border-left: 4px solid #2e7d32;">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i>
            <div>
                <c:choose>
                    <c:when test="${success eq 'created'}"><strong>Thành công!</strong> Đã thêm thuốc mới và ghi nhận giá khởi tạo.</c:when>
                    <c:when test="${success eq 'updated'}"><strong>Thành công!</strong> Đã cập nhật thuốc. Nếu giá thay đổi, lịch sử đã được ghi nhận.</c:when>
                    <c:when test="${success eq 'deactivated'}"><strong>Thành công!</strong> Đã ngừng sử dụng thuốc.</c:when>
                    <c:when test="${success eq 'activated'}"><strong>Thành công!</strong> Đã kích hoạt lại thuốc.</c:when>
                </c:choose>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md); border-left: 4px solid #c62828;">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i><div>${error}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <%-- Category Chips + Filter --%>
    <div class="admin-card mb-0">
        <div class="category-chips">
            <a href="${pageContext.request.contextPath}/manager/medicines/<c:if test='${not empty search}'>?search=${fn:escapeXml(search)}</c:if>"
               class="cat-chip ${empty categoryFilter || categoryFilter eq '' ? 'active' : ''}">
                <i class="bi bi-grid-fill"></i> Tất cả <span class="cat-count">${totalMedicines}</span>
            </a>
            <c:forEach var="cat" items="${categories}">
                <c:url var="catUrl" value="/manager/medicines/">
                    <c:param name="category" value="${cat.id}"/>
                    <c:if test="${not empty search}"><c:param name="search" value="${search}"/></c:if>
                    <c:if test="${not empty activeFilter}"><c:param name="active" value="${activeFilter}"/></c:if>
                </c:url>
                <a href="${catUrl}" class="cat-chip ${categoryFilter eq cat.id.toString() ? 'active' : ''}">
                    <i class="bi ${not empty cat.icon ? cat.icon : 'bi-folder'}"></i> ${fn:escapeXml(cat.categoryName)}
                    <span class="cat-count">${cat.medicineCount}</span>
                </a>
            </c:forEach>
        </div>
        <form method="get" action="${pageContext.request.contextPath}/manager/medicines/" class="filter-bar">
            <div class="input-group" style="max-width:280px;">
                <span class="input-group-text" style="background:var(--pink-50);border-color:var(--c-outline);"><i class="bi bi-search"></i></span>
                <input type="text" name="search" class="form-control" placeholder="Tìm tên, mã thuốc..." value="${not empty search ? fn:escapeXml(search) : ''}">
            </div>
            <select name="active" class="form-select">
                <option value="">Tất cả trạng thái</option>
                <option value="1" ${activeFilter eq '1' ? 'selected' : ''}>🟢 Đang sử dụng</option>
                <option value="0" ${activeFilter eq '0' ? 'selected' : ''}>⚫ Ngừng sử dụng</option>
            </select>
            <c:if test="${not empty categoryFilter}"><input type="hidden" name="category" value="${categoryFilter}"></c:if>
            <button type="submit" class="btn btn-primary-pink btn-sm"><i class="bi bi-funnel-fill me-1"></i>Lọc</button>
            <a href="${pageContext.request.contextPath}/manager/medicines/" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-counterclockwise me-1"></i>Đặt lại</a>
        </form>
    </div>

    <%-- Medicines Table --%>
    <div class="admin-card mt-3">
        <div class="admin-card-header">
            <h5><i class="bi bi-capsule me-2" style="color:var(--pink-500);"></i>Danh Sách Thuốc</h5>
            <span class="badge bg-white text-dark border" style="font-size:0.75rem;"><i class="bi bi-database me-1"></i>${totalMedicines} thuốc</span>
        </div>
        <div class="admin-table-wrapper">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>ID</th><th>Mã Thuốc</th><th>Tên Thuốc</th><th>Nhóm</th><th>Hàm Lượng</th>
                        <th>ĐVT</th><th>Đơn Giá</th><th>Tồn Kho</th><th>Trạng Thái</th><th>Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty medicines}">
                            <c:forEach var="med" items="${medicines}">
                                <tr>
                                    <td style="color:var(--c-muted);font-size:0.78rem;">#${med.id}</td>
                                    <td><code style="background:#fce4f3;color:#9c0f6e;padding:2px 8px;border-radius:4px;font-size:0.72rem;font-weight:600;">${not empty med.medicineCode ? fn:escapeXml(med.medicineCode) : '-'}</code></td>
                                    <td style="font-weight:600;">
                                        <div class="d-flex align-items-center gap-2">
                                            <i class="bi ${not empty med.categoryIcon ? med.categoryIcon : 'bi-capsule-fill'}" style="color:var(--pink-500);"></i>
                                            ${fn:escapeXml(med.name)}
                                        </div>
                                    </td>
                                    <td>
                                        <c:if test="${not empty med.categoryName}">
                                            <span class="cat-badge"><i class="bi ${not empty med.categoryIcon ? med.categoryIcon : 'bi-folder'}"></i> ${fn:escapeXml(med.categoryName)}</span>
                                        </c:if>
                                        <c:if test="${empty med.categoryName}"><span style="color:var(--c-muted);">—</span></c:if>
                                    </td>
                                    <td>${not empty med.dosage ? fn:escapeXml(med.dosage) : '—'}</td>
                                    <td>${not empty med.unit ? fn:escapeXml(med.unit) : '—'}</td>
                                    <td style="font-family:var(--font-display);font-weight:800;color:var(--c-primary);white-space:nowrap;">
                                        <fmt:formatNumber value="${med.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${med.stockQuantity <= 0}"><span class="stock-low">Hết hàng</span></c:when>
                                            <c:when test="${med.stockQuantity <= 10}"><span class="stock-warn">${med.stockQuantity}</span></c:when>
                                            <c:otherwise><span class="stock-ok">${med.stockQuantity}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${med.active}"><span class="badge-status badge-status-active"><i class="bi bi-check-circle me-1"></i>Đang dùng</span></c:when>
                                            <c:otherwise><span class="badge-status badge-status-inactive"><i class="bi bi-slash-circle me-1"></i>Ngừng</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex gap-1">
                                            <button class="action-btn" onclick="openEditModal('${med.id}','${fn:escapeXml(med.medicineCode)}','${fn:escapeXml(med.name)}','${fn:escapeXml(med.description)}','${fn:escapeXml(med.dosage)}','${fn:escapeXml(med.unit)}','${med.price}','${med.stockQuantity}','${med.active}','${med.categoryId}')" title="Sửa">
                                                <i class="bi bi-pencil-square"></i>
                                            </button>
                                            <form method="post" action="${pageContext.request.contextPath}/manager/medicines/" style="display:inline;">
                                                <input type="hidden" name="action" value="toggle">
                                                <input type="hidden" name="id" value="${med.id}">
                                                <button type="submit" class="action-btn ${med.active ? 'btn-outline-warning' : 'btn-outline-success'}" title="${med.active ? 'Ngừng' : 'Kích hoạt'}"
                                                        style="color:${med.active ? '#e65100' : '#2e7d32'};border-color:${med.active ? '#ff9800' : '#43a047'};"
                                                        onclick="return confirm('${med.active ? 'Ngừng sử dụng' : 'Kích hoạt lại'} thuốc «${fn:escapeXml(med.name)}»?')">
                                                    <i class="bi ${med.active ? 'bi-toggle-on' : 'bi-toggle-off'}"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="10"><div class="admin-empty-state"><i class="bi bi-capsule" style="font-size:2.5rem;color:var(--c-muted);"></i><h6 class="mt-2">Không tìm thấy thuốc</h6><p class="text-muted">Chưa có dữ liệu hoặc không khớp với bộ lọc.</p></div></td></tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <%-- Pagination --%>
    <c:if test="${totalPages > 1}">
        <div class="admin-pagination">
            <c:url var="baseUrl" value="/manager/medicines/">
                <c:param name="search" value="${search}"/><c:param name="active" value="${activeFilter}"/>
                <c:if test="${not empty categoryFilter}"><c:param name="category" value="${categoryFilter}"/></c:if>
            </c:url>
            <c:if test="${currentPage > 1}"><a href="${baseUrl}&page=${currentPage - 1}"><i class="bi bi-chevron-left"></i></a></c:if>
            <c:forEach begin="1" end="${totalPages}" var="p">
                <c:choose><c:when test="${p eq currentPage}"><span class="active">${p}</span></c:when><c:otherwise><a href="${baseUrl}&page=${p}">${p}</a></c:otherwise></c:choose>
            </c:forEach>
            <c:if test="${currentPage < totalPages}"><a href="${baseUrl}&page=${currentPage + 1}"><i class="bi bi-chevron-right"></i></a></c:if>
        </div>
    </c:if>
</main>

<%-- ===== MODAL: THEM THUOC ===== --%>
<div class="modal fade" id="addMedicineModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-plus-circle-fill me-2"></i>Thêm Thuốc Mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/manager/medicines/">
                <input type="hidden" name="action" value="create">
                <div class="modal-body">
                    <div class="form-section-title"><i class="bi bi-info-circle me-1"></i>Thông tin cơ bản</div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small">Mã thuốc <span class="text-danger">*</span></label>
                            <input type="text" name="medicineCode" class="form-control form-control-sm" required maxlength="50" placeholder="VD: THUOC-SAT-01" value="${formData.medicineCode}">
                            <c:if test="${not empty errors.medicineCode}"><div class="text-danger mt-1" style="font-size:0.72rem;">${errors.medicineCode}</div></c:if>
                        </div>
                        <div class="col-md-8">
                            <label class="form-label fw-semibold small">Tên thuốc <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control form-control-sm" required maxlength="150" placeholder="VD: Ferrovit" value="${formData.name}">
                            <c:if test="${not empty errors.name}"><div class="text-danger mt-1" style="font-size:0.72rem;">${errors.name}</div></c:if>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small">Mô tả / Chỉ định</label>
                            <textarea name="description" class="form-control form-control-sm" rows="2" maxlength="500" placeholder="Mô tả công dụng, chỉ định...">${formData.description}</textarea>
                        </div>
                    </div>
                    <div class="form-section-title"><i class="bi bi-cash-coin me-1"></i>Giá &amp; Phân loại</div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Hàm lượng</label>
                            <input type="text" name="dosage" class="form-control form-control-sm" maxlength="100" placeholder="VD: 200mg" value="${formData.dosage}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Đơn vị tính</label>
                            <input type="text" name="unit" class="form-control form-control-sm" maxlength="50" placeholder="VD: Viên" value="${formData.unit}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Giá bán (VNĐ) <span class="text-danger">*</span></label>
                            <div class="input-group input-group-sm"><span class="input-group-text fw-bold">₫</span><input type="number" name="price" class="form-control" required min="1000" step="100" placeholder="VD: 3500" value="${formData.price}"></div>
                            <c:if test="${not empty errors.price}"><div class="text-danger mt-1" style="font-size:0.72rem;">${errors.price}</div></c:if>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Tồn kho</label>
                            <input type="number" name="stockQuantity" class="form-control form-control-sm" min="0" placeholder="VD: 200" value="${formData.stockQuantity}">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold small">Nhóm thuốc</label>
                            <select name="categoryId" class="form-select form-select-sm">
                                <option value="">-- Chọn nhóm --</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.id}" ${formData.categoryId eq cat.id.toString() ? 'selected' : ''}>${fn:escapeXml(cat.categoryName)}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal"><i class="bi bi-x-circle me-1"></i>Hủy</button>
                    <button type="submit" class="btn btn-primary-pink btn-sm"><i class="bi bi-check-lg me-1"></i>Tạo Thuốc</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ===== MODAL: SUA THUOC ===== --%>
<div class="modal fade" id="editMedicineModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-pencil-square me-2"></i>Chỉnh Sửa Thuốc</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/manager/medicines/">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="editMedicineId">
                <div class="modal-body">
                    <div class="form-section-title"><i class="bi bi-info-circle me-1"></i>Thông tin cơ bản</div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold small">Mã thuốc <span class="text-danger">*</span></label>
                            <input type="text" name="medicineCode" id="editMedicineCode" class="form-control form-control-sm" required maxlength="50">
                        </div>
                        <div class="col-md-8">
                            <label class="form-label fw-semibold small">Tên thuốc <span class="text-danger">*</span></label>
                            <input type="text" name="name" id="editName" class="form-control form-control-sm" required maxlength="150">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small">Mô tả / Chỉ định</label>
                            <textarea name="description" id="editDesc" class="form-control form-control-sm" rows="2" maxlength="500"></textarea>
                        </div>
                    </div>
                    <div class="form-section-title"><i class="bi bi-cash-coin me-1"></i>Giá &amp; Phân loại</div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Hàm lượng</label>
                            <input type="text" name="dosage" id="editDosage" class="form-control form-control-sm" maxlength="100">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Đơn vị tính</label>
                            <input type="text" name="unit" id="editUnit" class="form-control form-control-sm" maxlength="50">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Giá bán (VNĐ) <span class="text-danger">*</span></label>
                            <div class="input-group input-group-sm"><span class="input-group-text fw-bold">₫</span><input type="number" name="price" id="editPrice" class="form-control" required min="1000" step="100"></div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold small">Tồn kho</label>
                            <input type="number" name="stockQuantity" id="editStock" class="form-control form-control-sm" min="0">
                        </div>
                        <div class="col-md-5">
                            <label class="form-label fw-semibold small">Nhóm thuốc</label>
                            <select name="categoryId" id="editCategoryId" class="form-select form-select-sm">
                                <option value="">-- Chọn nhóm --</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.id}">${fn:escapeXml(cat.categoryName)}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-3 d-flex align-items-end pb-1">
                            <div class="form-check"><input type="checkbox" name="isActive" class="form-check-input" id="editIsActive"><label class="form-check-label small fw-semibold" for="editIsActive">Đang sử dụng</label></div>
                        </div>
                        <div class="col-12">
                            <div class="alert alert-info d-flex align-items-center gap-2 mb-0" style="font-size:0.75rem;padding:0.4rem 0.7rem;border-radius:var(--r-sm);">
                                <i class="bi bi-info-circle-fill"></i> Nếu thay đổi giá, hệ thống sẽ tự động ghi nhận vào lịch sử điều chỉnh giá thuốc.
                            </div>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold small">Lý do thay đổi giá <span class="text-muted">(nếu có)</span></label>
                            <input type="text" name="changeReason" id="editChangeReason" class="form-control form-control-sm" maxlength="500" placeholder="VD: Điều chỉnh theo giá nhập mới từ nhà cung cấp">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal"><i class="bi bi-x-circle me-1"></i>Hủy</button>
                    <button type="submit" class="btn btn-primary-pink btn-sm"><i class="bi bi-check-lg me-1"></i>Lưu Thay Đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
<script>
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        if (links[i].href && links[i].href.indexOf('/manager/medicines') !== -1) links[i].classList.add('active');
    }
})();

function openEditModal(id, code, name, desc, dosage, unit, price, stock, isActive, catId) {
    document.getElementById('editMedicineId').value = id;
    document.getElementById('editMedicineCode').value = code || '';
    document.getElementById('editName').value = name || '';
    document.getElementById('editDesc').value = desc || '';
    document.getElementById('editDosage').value = dosage || '';
    document.getElementById('editUnit').value = unit || '';
    document.getElementById('editPrice').value = price || '1000';
    document.getElementById('editStock').value = stock || '0';
    document.getElementById('editIsActive').checked = isActive === 'true';
    document.getElementById('editChangeReason').value = '';
    var catSelect = document.getElementById('editCategoryId');
    if (catSelect && catId) {
        for (var i = 0; i < catSelect.options.length; i++) {
            if (catSelect.options[i].value === catId) { catSelect.options[i].selected = true; break; }
        }
    }
    new bootstrap.Modal(document.getElementById('editMedicineModal')).show();
}

<c:if test="${showCreateModal}">new bootstrap.Modal(document.getElementById('addMedicineModal')).show();</c:if>
<c:if test="${showEditModal}">
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('editMedicineId').value = '${editMedicineId}';
    document.getElementById('editMedicineCode').value = '${fn:escapeXml(formData.medicineCode)}';
    document.getElementById('editName').value = '${fn:escapeXml(formData.name)}';
    document.getElementById('editDesc').value = '${fn:escapeXml(formData.description)}';
    document.getElementById('editDosage').value = '${fn:escapeXml(formData.dosage)}';
    document.getElementById('editUnit').value = '${fn:escapeXml(formData.unit)}';
    document.getElementById('editPrice').value = '${formData.price}';
    document.getElementById('editStock').value = '${formData.stockQuantity}';
    document.getElementById('editChangeReason').value = '${fn:escapeXml(formData.changeReason)}';
    var catSel = document.getElementById('editCategoryId');
    if (catSel && '${formData.categoryId}') {
        for (var i = 0; i < catSel.options.length; i++) {
            if (catSel.options[i].value === '${formData.categoryId}') { catSel.options[i].selected = true; break; }
        }
    }
    new bootstrap.Modal(document.getElementById('editMedicineModal')).show();
});
</c:if>
</script>
</body>
</html>
