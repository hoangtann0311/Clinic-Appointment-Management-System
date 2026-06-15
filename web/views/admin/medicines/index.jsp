<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Thuốc — CAMS Admin</title>

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
            --c-success: #2e7d32; --c-danger: #c62828; --c-warning: #f57f17;
            --shadow-xs: 0 1px 3px rgba(194,24,91,0.07);
            --shadow-sm: 0 2px 8px rgba(194,24,91,0.10);
            --r-sm: 8px; --r-md: 12px; --r-lg: 16px; --r-pill: 999px;
            --t-fast: 0.15s ease;
            --font-display: 'Nunito', sans-serif;
            --font-body: 'Inter', sans-serif;
        }
        *, *::before, *::after { box-sizing: border-box; }
        body, .btn, .form-control, .table, .badge, .card { font-family: var(--font-body); }
        h1,h2,h3,h4,h5,h6 { font-family: var(--font-display); }
        body.admin-body { font-family: var(--font-body); background: var(--c-bg); color: var(--c-on-bg); margin: 0; padding: 0; line-height: 1.6; -webkit-font-smoothing: antialiased; }

        .admin-topbar { position: fixed; top: 0; left: 0; right: 0; height: var(--topbar-h); background: var(--c-surface); border-bottom: 2px solid var(--pink-200); display: flex; align-items: center; justify-content: space-between; padding: 0 1.5rem; z-index: 1030; box-shadow: var(--shadow-xs); }
        .admin-topbar-left { display: flex; align-items: center; gap: 0.875rem; }
        .admin-topbar-brand { font-family: var(--font-display); font-weight: 900; font-size: 1.3rem; color: var(--c-primary); text-decoration: none; display: flex; align-items: center; gap: 0.5rem; letter-spacing: -0.03em; }
        .admin-topbar-brand i { color: var(--pink-500); font-size: 1.5rem; }
        .admin-topbar-brand .brand-badge { font-family: var(--font-body); font-weight: 700; font-size: 0.65rem; color: var(--c-primary); background: var(--pink-100); padding: 3px 10px; border-radius: var(--r-pill); letter-spacing: 0.06em; text-transform: uppercase; border: 1px solid var(--pink-200); }
        .admin-sidebar-toggle { background: none; border: none; color: var(--c-on-surface-var); font-size: 1.5rem; cursor: pointer; padding: 6px 8px; border-radius: var(--r-sm); display: none; }
        .admin-sidebar-toggle:hover { background: var(--pink-100); color: var(--c-primary); }
        .admin-topbar-right { display: flex; align-items: center; gap: 0.75rem; }
        .admin-topbar-user { display: flex; align-items: center; gap: 0.6rem; padding: 0.375rem 0.875rem; background: var(--pink-50); border-radius: var(--r-pill); border: 1px solid var(--pink-200); }
        .admin-topbar-user span { font-size: 0.875rem; font-weight: 600; color: var(--c-primary-dark); }
        .admin-avatar-sm { width: 34px; height: 34px; border-radius: 50%; background: linear-gradient(135deg, var(--pink-500), var(--rose-400)); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.85rem; text-transform: uppercase; flex-shrink: 0; }
        .admin-topbar-role { font-size: 0.62rem; font-weight: 700; padding: 2px 8px; border-radius: var(--r-pill); background: linear-gradient(135deg, var(--pink-500), var(--rose-500)); color: #fff; letter-spacing: 0.05em; text-transform: uppercase; }
        .admin-topbar-logout { color: var(--c-on-surface-var); text-decoration: none; font-size: 0.85rem; font-weight: 600; display: flex; align-items: center; gap: 0.4rem; padding: 0.45rem 0.875rem; border-radius: var(--r-sm); transition: all var(--t-fast); border: 1px solid transparent; }
        .admin-topbar-logout:hover { background: var(--pink-50); color: var(--rose-600); border-color: var(--pink-200); }

        .admin-main { margin-left: var(--sidebar-w); margin-top: var(--topbar-h); padding: 2rem 2.25rem; min-height: calc(100vh - var(--topbar-h)); }
        .admin-page-header { display: flex; align-items: flex-start; justify-content: space-between; flex-wrap: wrap; gap: 1rem; margin-bottom: 1.5rem; }
        .admin-page-title { font-family: var(--font-display); font-size: 1.85rem; font-weight: 900; color: var(--c-on-bg); margin: 0 0 0.25rem; letter-spacing: -0.04em; }
        .admin-page-subtitle { font-size: 0.85rem; color: var(--c-muted); display: flex; align-items: center; gap: 0.4rem; }

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

        .badge-active { display: inline-block; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.72rem; font-weight: 700; background: #e8f5e9; color: #2e7d32; }
        .badge-inactive { display: inline-block; padding: 3px 10px; border-radius: var(--r-pill); font-size: 0.72rem; font-weight: 700; background: #f5f5f5; color: #757575; }
        .stock-low { color: var(--c-danger); font-weight: 700; }
        .stock-ok { color: var(--c-success); }

        .btn-primary-pink { background: linear-gradient(135deg, var(--pink-500), var(--pink-600)); color: #fff; border: none; font-weight: 700; border-radius: var(--r-sm); padding: 0.55rem 1.2rem; transition: all var(--t-fast); }
        .btn-primary-pink:hover { background: linear-gradient(135deg, var(--pink-600), var(--pink-700)); color: #fff; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(233,30,140,0.3); }
        .btn-action { display: inline-flex; align-items: center; gap: 0.25rem; }

        .filter-bar { display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: center; }
        .filter-bar .form-control, .filter-bar .form-select { width: auto; min-width: 150px; border-radius: var(--r-sm); border: 1px solid var(--c-outline); font-size: 0.85rem; padding: 0.45rem 0.75rem; }
        .filter-bar .form-control:focus, .filter-bar .form-select:focus { border-color: var(--pink-500); box-shadow: 0 0 0 0.2rem rgba(233,30,140,0.15); }

        .admin-pagination { display: flex; justify-content: center; gap: 0.25rem; margin-top: 1.25rem; }
        .admin-pagination a, .admin-pagination span { display: inline-flex; align-items: center; justify-content: center; min-width: 38px; height: 38px; padding: 0 0.5rem; border-radius: var(--r-sm); font-size: 0.85rem; font-weight: 600; text-decoration: none; border: 1px solid var(--c-outline-variant); color: var(--c-on-surface-var); transition: all var(--t-fast); }
        .admin-pagination a:hover { background: var(--pink-50); border-color: var(--pink-200); color: var(--c-primary); }
        .admin-pagination .active { background: var(--pink-500); color: #fff; border-color: var(--pink-500); }
        .admin-pagination .disabled { opacity: 0.4; pointer-events: none; }

        .admin-sidebar-backdrop { display: none; position: fixed; inset: 0; background: rgba(26,10,18,0.5); z-index: 1015; backdrop-filter: blur(3px); }
        .admin-sidebar-backdrop.show { display: block; }

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

<%-- TOP BAR --%>
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

<%-- SIDEBAR --%>
<%@ include file="../layout/sidebar.jsp" %>

<%-- MAIN CONTENT --%>
<main class="admin-main" id="adminMain">

    <div class="admin-page-header">
        <div>
            <h1 class="admin-page-title">Quản Lý Thuốc</h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-capsule"></i>
                Tổng: <strong>${totalMedicines}</strong> loại thuốc
            </div>
        </div>
        <button class="btn btn-primary-pink" data-bs-toggle="modal" data-bs-target="#addMedicineModal">
            <i class="bi bi-plus-circle-fill me-1"></i>Thêm Thuốc
        </button>
    </div>

    <%-- Alert messages --%>
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-1"></i>
            <c:choose>
                <c:when test="${success eq 'created'}">Đã thêm thuốc thành công!</c:when>
                <c:when test="${success eq 'updated'}">Đã cập nhật thuốc thành công!</c:when>
                <c:when test="${success eq 'deactivated'}">Đã vô hiệu hóa thuốc!</c:when>
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

    <%-- Filter Bar --%>
    <div class="admin-card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/medicines/" class="filter-bar">
                <input type="text" name="search" class="form-control" placeholder="Tìm tên, mã thuốc..."
                       value="${not empty search ? search : ''}" style="min-width:220px;">
                <select name="active" class="form-select">
                    <option value="">Tất cả trạng thái</option>
                    <option value="1" ${activeFilter eq '1' ? 'selected' : ''}>Đang sử dụng</option>
                    <option value="0" ${activeFilter eq '0' ? 'selected' : ''}>Ngừng sử dụng</option>
                </select>
                <button type="submit" class="btn btn-primary-pink">
                    <i class="bi bi-search me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/admin/medicines/" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-x-circle me-1"></i>Xóa lọc
                </a>
            </form>
        </div>
    </div>

    <%-- Medicines Table --%>
    <div class="admin-card">
        <div class="card-body p-0">
            <div class="admin-table-wrapper">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Mã Thuốc</th>
                            <th>Tên Thuốc</th>
                            <th>Hàm Lượng</th>
                            <th>ĐVT</th>
                            <th>Đơn Giá</th>
                            <th>Tồn Kho</th>
                            <th>Trạng Thái</th>
                            <th style="width:140px;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty medicines}">
                                <c:forEach var="med" items="${medicines}">
                                    <tr>
                                        <td style="color:var(--c-muted);font-size:0.8rem;">#${med.id}</td>
                                        <td style="font-weight:600;font-size:0.82rem;">${not empty med.medicineCode ? med.medicineCode : '—'}</td>
                                        <td style="font-weight:600;">${med.name}</td>
                                        <td>${not empty med.dosage ? med.dosage : '—'}</td>
                                        <td>${not empty med.unit ? med.unit : '—'}</td>
                                        <td style="font-weight:700;color:var(--c-primary);">
                                            <fmt:formatNumber value="${med.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${med.stockQuantity <= 10}">
                                                    <span class="stock-low">${med.stockQuantity}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="stock-ok">${med.stockQuantity}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${med.active}">
                                                    <span class="badge-active">Đang dùng</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-inactive">Ngừng</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="d-flex gap-1">
                                                <button class="btn btn-sm btn-outline-secondary btn-action"
                                                        onclick="openEditModal('${med.id}','${fn:escapeXml(med.medicineCode)}','${fn:escapeXml(med.name)}','${fn:escapeXml(med.description)}','${fn:escapeXml(med.dosage)}','${fn:escapeXml(med.unit)}','${med.price}','${med.stockQuantity}','${med.active}')"
                                                        title="Sửa">
                                                    <i class="bi bi-pencil-square"></i>
                                                </button>
                                                <c:if test="${med.active}">
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/medicines/" style="display:inline;">
                                                        <input type="hidden" name="action" value="deactivate">
                                                        <input type="hidden" name="id" value="${med.id}">
                                                        <button type="submit" class="btn btn-sm btn-outline-warning btn-action"
                                                                title="Vô hiệu" onclick="return confirm('Vô hiệu hóa thuốc #${med.id} — ${fn:escapeXml(med.name)}?')">
                                                            <i class="bi bi-slash-circle"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9">
                                        <div style="text-align:center;padding:2.5rem 1rem;color:var(--c-muted);">
                                            <i class="bi bi-inbox" style="font-size:2.5rem;color:var(--pink-200);display:block;margin-bottom:0.75rem;"></i>
                                            <h6>Không tìm thấy thuốc</h6>
                                            <p style="font-size:0.85rem;">Chưa có dữ liệu hoặc không khớp với bộ lọc.</p>
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
            <c:url var="baseUrl" value="/admin/medicines/">
                <c:param name="search" value="${search}"/>
                <c:param name="active" value="${activeFilter}"/>
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

<%-- ============================================================
     MODAL: THÊM THUỐC
     ============================================================ --%>
<div class="modal fade" id="addMedicineModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content" style="border-radius:var(--r-lg);border:1px solid var(--c-outline-variant);">
            <div class="modal-header" style="background:var(--pink-50);border-bottom:1px solid var(--pink-200);">
                <h5 class="modal-title" style="font-family:var(--font-display);font-weight:800;color:var(--c-primary-dark);">
                    <i class="bi bi-plus-circle-fill me-2"></i>Thêm Thuốc Mới
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/medicines/">
                <input type="hidden" name="action" value="create">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Mã thuốc <span class="text-danger">*</span></label>
                            <input type="text" name="medicineCode" class="form-control" required maxlength="50"
                                   placeholder="VD: THUOC-001" value="${formData.medicineCode}">
                            <c:if test="${not empty errors.medicineCode}">
                                <div class="text-danger" style="font-size:0.78rem;">${errors.medicineCode}</div>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên thuốc <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control" required maxlength="100"
                                   placeholder="VD: Paracetamol 500mg" value="${formData.name}">
                            <c:if test="${not empty errors.name}">
                                <div class="text-danger" style="font-size:0.78rem;">${errors.name}</div>
                            </c:if>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Mô tả</label>
                            <textarea name="description" class="form-control" rows="2" maxlength="500">${formData.description}</textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Hàm lượng</label>
                            <input type="text" name="dosage" class="form-control" maxlength="100"
                                   placeholder="VD: 500mg" value="${formData.dosage}">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Đơn vị tính</label>
                            <input type="text" name="unit" class="form-control" maxlength="20"
                                   placeholder="VD: Viên, Chai, Ống" value="${formData.unit}">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Giá bán (VNĐ) <span class="text-danger">*</span></label>
                            <input type="number" name="price" class="form-control" required min="0" step="1000"
                                   placeholder="VD: 5000" value="${formData.price}">
                            <c:if test="${not empty errors.price}">
                                <div class="text-danger" style="font-size:0.78rem;">${errors.price}</div>
                            </c:if>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Số lượng tồn kho</label>
                            <input type="number" name="stockQuantity" class="form-control" min="0"
                                   placeholder="VD: 100" value="${formData.stockQuantity}">
                        </div>
                    </div>
                </div>
                <div class="modal-footer" style="border-top:1px solid var(--c-outline-variant);">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary-pink">
                        <i class="bi bi-check-lg me-1"></i>Thêm Thuốc
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ============================================================
     MODAL: SỬA THUỐC
     ============================================================ --%>
<div class="modal fade" id="editMedicineModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content" style="border-radius:var(--r-lg);border:1px solid var(--c-outline-variant);">
            <div class="modal-header" style="background:var(--pink-50);border-bottom:1px solid var(--pink-200);">
                <h5 class="modal-title" style="font-family:var(--font-display);font-weight:800;color:var(--c-primary-dark);">
                    <i class="bi bi-pencil-square me-2"></i>Sửa Thuốc
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/admin/medicines/">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="editMedicineId">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Mã thuốc <span class="text-danger">*</span></label>
                            <input type="text" name="medicineCode" id="editMedicineCode" class="form-control" required maxlength="50">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tên thuốc <span class="text-danger">*</span></label>
                            <input type="text" name="name" id="editName" class="form-control" required maxlength="100">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Mô tả</label>
                            <textarea name="description" id="editDesc" class="form-control" rows="2" maxlength="500"></textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Hàm lượng</label>
                            <input type="text" name="dosage" id="editDosage" class="form-control" maxlength="100">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Đơn vị tính</label>
                            <input type="text" name="unit" id="editUnit" class="form-control" maxlength="20">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Giá bán (VNĐ) <span class="text-danger">*</span></label>
                            <input type="number" name="price" id="editPrice" class="form-control" required min="0" step="1000">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Tồn kho</label>
                            <input type="number" name="stockQuantity" id="editStock" class="form-control" min="0">
                        </div>
                        <div class="col-md-4 d-flex align-items-end pb-2">
                            <div class="form-check">
                                <input type="checkbox" name="isActive" class="form-check-input" id="editIsActive">
                                <label class="form-check-label" for="editIsActive">Đang sử dụng</label>
                            </div>
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
        if (links[i].href && links[i].href.indexOf('/admin/medicines') !== -1) {
            links[i].classList.add('active');
        }
    }
})();

function openEditModal(id, code, name, desc, dosage, unit, price, stock, isActive) {
    document.getElementById('editMedicineId').value = id;
    document.getElementById('editMedicineCode').value = code || '';
    document.getElementById('editName').value = name || '';
    document.getElementById('editDesc').value = desc || '';
    document.getElementById('editDosage').value = dosage || '';
    document.getElementById('editUnit').value = unit || '';
    document.getElementById('editPrice').value = price || '0';
    document.getElementById('editStock').value = stock || '0';
    document.getElementById('editIsActive').checked = isActive === 'true';
    new bootstrap.Modal(document.getElementById('editMedicineModal')).show();
}
</script>
</body>
</html>
