<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Xác Nhận Thanh Toán - CAMS Staff</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css" rel="stylesheet">
</head>
<body class="admin-body">

<c:set var="requestURI" value="${pageContext.request.servletPath}" />

<!-- Top Header Bar -->
<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/admin/reception" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i>
            CAMS
            <span class="brand-badge">Staff</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="topbar-date d-none d-lg-flex">
            <i class="bi bi-calendar3"></i>
            <span><c:out value="${currentDisplayDate}"/></span>
        </div>
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">
                ${fn:substring(sessionScope.user.fullName, 0, 1)}
            </div>
            <span class="header-display-name">${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role">
                <i class="bi bi-shield-check me-1"></i>Lễ Tân
            </span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout" title="Đăng xuất">
            <i class="bi bi-box-arrow-right"></i>
            <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
    </div>
</nav>

<div class="wrapper">
    <!-- Sidebar Backdrop -->
    <div class="admin-sidebar-backdrop" id="sidebarBackdrop" onclick="closeSidebar()"></div>

    <!-- Left Sidebar -->
    <aside class="admin-sidebar" id="adminSidebar">
        <div class="admin-sidebar-user">
            <div class="admin-sidebar-avatar">
                ${fn:substring(sessionScope.user.fullName, 0, 1)}
            </div>
            <div class="admin-sidebar-name">${sessionScope.user.fullName}</div>
            <span class="admin-sidebar-badge">
                <i class="bi bi-shield-check"></i>LỄ TÂN / CALL CENTER
            </span>
        </div>

        <ul class="admin-sidebar-menu">
            <li class="admin-sidebar-section">Tổng quan</li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception" 
                   class="${fn:contains(requestURI, '/reception') && !fn:contains(requestURI, 'booking') && !fn:contains(requestURI, 'sos') && !fn:contains(requestURI, 'payments') ? 'active' : ''}">
                    <i class="bi bi-speedometer2"></i>
                    <span>Hàng Đợi Tiếp Đón</span>
                </a>
            </li>

            <li class="admin-sidebar-section">Quản lý tiếp đón</li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/booking" 
                   class="${fn:contains(requestURI, 'booking') ? 'active' : ''}">
                    <i class="bi bi-calendar-plus"></i>
                    <span>Đặt Lịch Thủ Công</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/sos" 
                   class="${fn:contains(requestURI, 'sos') ? 'active' : ''}">
                    <i class="bi bi-bell-slash text-danger"></i>
                    <span>Giám Sát Cảnh Báo SOS</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/payments" 
                   class="active">
                    <i class="bi bi-credit-card-2-front"></i>
                    <span>Xác Nhận Thanh Toán</span>
                </a>
            </li>
        </ul>
    </aside>

    <!-- Main Content Area -->
    <main class="admin-main" id="adminMain">
        <div class="admin-page-header">
            <div class="admin-page-header-left">
                <h1 class="admin-page-title">Xác Nhận Thanh Toán Hóa Đơn</h1>
                <div class="admin-page-subtitle">
                    Quản lý tiếp đón &gt; Danh sách hóa đơn &amp; Thu phí dịch vụ
                </div>
            </div>
        </div>

        <!-- Alerts -->
        <c:if test="${not empty param.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>
                <c:choose>
                    <c:when test="${param.success == 'confirmed'}">Xác nhận thanh toán hóa đơn thành công!</c:when>
                    <c:otherwise>Thao tác thực hiện thành công!</c:otherwise>
                </c:choose>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                <c:out value="${param.error}"/>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Filters Form -->
        <div class="admin-card mb-4">
            <div class="card-body">
                <form method="GET" action="${pageContext.request.contextPath}/admin/reception/payments" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label text-muted small fw-bold">TÌM KIẾM SẢN PHỤ</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" name="search" class="form-control border-start-0 ps-0" placeholder="Tên sản phụ, SĐT, mã GD..." value="${searchParam}">
                        </div>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label text-muted small fw-bold">TRẠNG THÁI</label>
                        <select name="status" class="form-select">
                            <option value="">Tất cả trạng thái</option>
                            <option value="Unpaid" ${statusParam == 'Unpaid' ? 'selected' : ''}>Chưa thanh toán</option>
                            <option value="Paid" ${statusParam == 'Paid' ? 'selected' : ''}>Đã thanh toán</option>
                            <option value="PendingConfirmation" ${statusParam == 'PendingConfirmation' ? 'selected' : ''}>Chờ xác nhận</option>
                            <option value="Cancelled" ${statusParam == 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label text-muted small fw-bold">LOẠI HÓA ĐƠN</label>
                        <select name="type" class="form-select">
                            <option value="">Tất cả loại</option>
                            <option value="PRE_EXAM" ${typeParam == 'PRE_EXAM' ? 'selected' : ''}>Trước khám (PRE_EXAM)</option>
                            <option value="POST_EXAM" ${typeParam == 'POST_EXAM' ? 'selected' : ''}>Sau khám (POST_EXAM)</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label text-muted small fw-bold">NGÀY HẸN KHÁM</label>
                        <input type="date" name="date" class="form-control" value="${dateParam}">
                    </div>
                    <div class="col-md-3 d-flex align-items-end gap-2">
                        <button type="submit" class="btn btn-primary w-100 flex-grow-1">
                            <i class="bi bi-funnel-fill me-1"></i> Lọc dữ liệu
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/reception/payments" class="btn btn-light border" title="Reset bộ lọc">
                            <i class="bi bi-arrow-counterclockwise"></i>
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Invoices List -->
        <div class="admin-card">
            <div class="card-header bg-white py-3">
                <h5 class="m-0 fw-bold text-dark d-flex align-items-center gap-2">
                    <i class="bi bi-receipt text-primary"></i> 
                    Danh Sách Hóa Đơn Lịch Hẹn
                </h5>
            </div>
            <div class="card-body p-0">
                <div class="admin-table-wrapper">
                    <table class="admin-table table-cams">
                        <thead>
                            <tr>
                                <th>Mã HĐ</th>
                                <th>Thông Tin Sản Phụ</th>
                                <th>Dịch Vụ Khám</th>
                                <th>Ngày Khám</th>
                                <th>Tổng Tiền</th>
                                <th>Phân Loại</th>
                                <th>Trạng Thái</th>
                                <th>Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty invoices}">
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-5">
                                            <i class="bi bi-receipt-cutoff fs-2 d-block mb-2"></i>
                                            Không tìm thấy hóa đơn nào khớp với điều kiện lọc.
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="inv" items="${invoices}">
                                        <tr>
                                            <td><strong>HĐ-${inv.id}</strong></td>
                                            <td>
                                                <strong class="text-dark"><c:out value="${inv.patientName}"/></strong><br>
                                                <small class="text-muted"><i class="bi bi-telephone me-1"></i><c:out value="${inv.patientPhone}"/></small>
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-dark fw-medium border"><c:out value="${inv.serviceName != null ? inv.serviceName : 'Phí khám thai tổng quát'}"/></span>
                                            </td>
                                            <td><c:out value="${inv.appointmentDate}"/></td>
                                            <td>
                                                <strong class="text-danger">
                                                    <c:out value="${String.format('%,.0f', inv.totalAmount)}"/>đ
                                                </strong>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${inv.invoiceType == 'PRE_EXAM'}">
                                                        <span class="badge bg-info-subtle text-info border border-info-subtle">Trước khám</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle">Sau khám / Chỉ định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${inv.status == 'Paid'}">
                                                        <span class="badge bg-success-subtle text-success border border-success-subtle d-flex align-items-center gap-1 w-fit">
                                                            <i class="bi bi-check-circle"></i> Đã thu
                                                        </span>
                                                        <small class="text-muted d-block mt-1 text-start" style="font-size: 11px;">
                                                            ${inv.paymentMethod == 'Cash' ? 'Tiền mặt' : 'Chuyển khoản'}<br>
                                                            Mã GD: ${inv.transactionCode}
                                                        </small>
                                                    </c:when>
                                                    <c:when test="${inv.status == 'PendingConfirmation'}">
                                                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle d-flex align-items-center gap-1 w-fit">
                                                            <i class="bi bi-clock-history"></i> Chờ xác nhận
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${inv.status == 'Cancelled'}">
                                                        <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle d-flex align-items-center gap-1 w-fit">
                                                            <i class="bi bi-x-circle"></i> Đã hủy
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle d-flex align-items-center gap-1 w-fit">
                                                            <i class="bi bi-exclamation-circle"></i> Chưa thanh toán
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${inv.status == 'Unpaid' || inv.status == 'PendingConfirmation'}">
                                                        <button type="button" class="btn btn-sm btn-outline-success fw-bold d-inline-flex align-items-center gap-1"
                                                                onclick="openPaymentModal(${inv.id}, '${inv.patientName}', ${inv.totalAmount}, '${inv.invoiceType}')">
                                                            <i class="bi bi-credit-card"></i> Xác nhận Paid
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="btn btn-sm btn-light border text-muted disabled" disabled>
                                                            <i class="bi bi-lock"></i> Khóa
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="card-footer bg-white py-3 border-top d-flex justify-content-center">
                    <nav aria-label="Page navigation">
                        <ul class="pagination pagination-cams m-0">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&search=${searchParam}&status=${statusParam}&type=${typeParam}&date=${dateParam}">
                                    <i class="bi bi-chevron-left"></i>
                                </a>
                            </li>
                            <c:forEach var="p" begin="1" end="${totalPages}">
                                <li class="page-item ${currentPage == p ? 'active' : ''}">
                                    <a class="page-link" href="?page=${p}&search=${searchParam}&status=${statusParam}&type=${typeParam}&date=${dateParam}">${p}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&search=${searchParam}&status=${statusParam}&type=${typeParam}&date=${dateParam}">
                                    <i class="bi bi-chevron-right"></i>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </c:if>
        </div>
    </main>
</div>

<!-- Confirm Payment Modal -->
<div class="modal fade" id="paymentModal" tabindex="-1" aria-labelledby="paymentModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <form method="POST" action="${pageContext.request.contextPath}/admin/reception/payments" onsubmit="return validatePaymentForm()">
            <!-- Retain filter parameters -->
            <input type="hidden" name="search" value="${searchParam}">
            <input type="hidden" name="status" value="${statusParam}">
            <input type="hidden" name="type" value="${typeParam}">
            <input type="hidden" name="date" value="${dateParam}">
            <input type="hidden" name="page" value="${currentPage}">

            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title fw-bold text-white" id="paymentModalLabel">
                        <i class="bi bi-cash-coin me-1"></i> Xác Nhận Thanh Toán Hóa Đơn
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <input type="hidden" id="modalInvoiceId" name="invoiceId">
                    
                    <div class="mb-3">
                        <label class="text-muted small fw-bold">SẢN PHỤ</label>
                        <div class="fs-5 fw-bold text-dark" id="modalPatientName"></div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="text-muted small fw-bold">TỔNG TIỀN CẦN THU</label>
                        <div class="fs-4 fw-bold text-danger" id="modalTotalAmount"></div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold">PHƯƠNG THỨC THANH TOÁN</label>
                        <div class="d-flex gap-4">
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="paymentMethod" id="methodCash" value="Cash" checked onclick="toggleTxCode(false)">
                                <label class="form-check-label fw-bold text-dark" for="methodCash">
                                    <i class="bi bi-cash me-1 text-success"></i> Tiền mặt (Cash)
                                </label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="paymentMethod" id="methodTransfer" value="BankTransfer" onclick="toggleTxCode(true)">
                                <label class="form-check-label fw-bold text-dark" for="methodTransfer">
                                    <i class="bi bi-bank me-1 text-primary"></i> Chuyển khoản (BankTransfer)
                                </label>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3" id="txCodeContainer" style="display: none;">
                        <label for="transactionCode" class="form-label text-muted small fw-bold">MÃ GIAO DỊCH CHUYỂN KHOẢN <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="transactionCode" name="transactionCode" placeholder="Nhập mã giao dịch ngân hàng (VD: FT24090...)">
                        <div class="invalid-feedback">Vui lòng nhập mã giao dịch ngân hàng.</div>
                    </div>

                    <div class="mb-3">
                        <label for="paymentNote" class="form-label text-muted small fw-bold">GHI CHÚ THANH TOÁN</label>
                        <textarea class="form-control" id="paymentNote" name="paymentNote" rows="2" placeholder="Thông tin thêm (nếu có)..."></textarea>
                    </div>
                </div>
                <div class="modal-footer bg-light border-0">
                    <button type="button" class="btn btn-secondary border" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-success fw-bold px-4">
                        <i class="bi bi-check-lg"></i> Xác nhận PAID
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Sidebar toggle
    const sidebarToggle = document.getElementById('sidebarToggle');
    const adminSidebar = document.getElementById('adminSidebar');
    const sidebarBackdrop = document.getElementById('sidebarBackdrop');

    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function() {
            adminSidebar.classList.toggle('show');
            sidebarBackdrop.classList.toggle('show');
        });
    }

    function closeSidebar() {
        adminSidebar.classList.remove('show');
        sidebarBackdrop.classList.remove('show');
    }

    // Modal helpers
    const paymentModal = new bootstrap.Modal(document.getElementById('paymentModal'));
    
    function openPaymentModal(invoiceId, patientName, amount, type) {
        document.getElementById('modalInvoiceId').value = invoiceId;
        document.getElementById('modalPatientName').textContent = patientName;
        document.getElementById('modalTotalAmount').textContent = new Intl.NumberFormat('vi-VN').format(amount) + 'đ';
        
        // Reset form
        document.getElementById('methodCash').checked = true;
        document.getElementById('transactionCode').value = '';
        document.getElementById('paymentNote').value = '';
        toggleTxCode(false);
        
        paymentModal.show();
    }

    function toggleTxCode(show) {
        const container = document.getElementById('txCodeContainer');
        const input = document.getElementById('transactionCode');
        if (show) {
            container.style.display = 'block';
            input.focus();
        } else {
            container.style.display = 'none';
        }
    }

    function validatePaymentForm() {
        const isTransfer = document.getElementById('methodTransfer').checked;
        const txCodeInput = document.getElementById('transactionCode');
        
        if (isTransfer) {
            if (txCodeInput.value.trim() === '') {
                txCodeInput.classList.add('is-invalid');
                return false;
            }
        }
        txCodeInput.classList.remove('is-invalid');
        return true;
    }
</script>
</body>
</html>
