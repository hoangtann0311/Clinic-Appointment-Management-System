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
                <a href="${pageContext.request.contextPath}/admin/reception/doctor-schedules"
                   class="${fn:contains(requestURI, 'doctor-schedules') ? 'active' : ''}">
                    <i class="bi bi-calendar-week"></i>
                    <span>Lịch Trực Bác Sĩ</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/slots"
                   class="${fn:contains(requestURI, '/slots') ? 'active' : ''}">
                    <i class="bi bi-grid-3x3-gap"></i>
                    <span>Khung Giờ Khám</span>
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
                <a href="${pageContext.request.contextPath}/admin/reception/payments?status=PendingConfirmation"
                   class="${statusParam == 'PendingConfirmation' || empty statusParam ? 'active' : ''}">
                    <i class="bi bi-credit-card-2-front"></i>
                    <span>Xác Nhận Thanh Toán</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/payments?status=Paid"
                   class="${statusParam == 'Paid' ? 'active' : ''}">
                    <i class="bi bi-clock-history"></i>
                    <span>Lịch Sử Giao Dịch</span>
                </a>
            </li>
        </ul>
    </aside>

    <!-- Main Content Area -->
    <main class="admin-main" id="adminMain">
        <div class="admin-page-header">
            <div class="admin-page-header-left">
                <h1 class="admin-page-title">
                    <c:choose>
                        <c:when test="${statusParam == 'Paid'}">Lịch Sử Giao Dịch Thanh Toán</c:when>
                        <c:when test="${statusParam == 'PendingConfirmation'}">Duyệt Xác Nhận Thanh Toán</c:when>
                        <c:otherwise>Xác Nhận Thanh Toán Hóa Đơn</c:otherwise>
                    </c:choose>
                </h1>
                <div class="admin-page-subtitle">
                    Quản lý tiếp đón &gt;
                    <c:choose>
                        <c:when test="${statusParam == 'Paid'}">Lịch sử giao dịch</c:when>
                        <c:otherwise>Danh sách hóa đơn &amp; Thu phí dịch vụ</c:otherwise>
                    </c:choose>
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
                            <option value="DeclinedPurchase" ${statusParam == 'DeclinedPurchase' ? 'selected' : ''}>Từ chối mua thuốc</option>
                            <option value="Cancelled" ${statusParam == 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label text-muted small fw-bold">LOẠI HÓA ĐƠN</label>
                        <select name="type" class="form-select">
                            <option value="">Tất cả loại</option>
                            <option value="PRE_EXAM" ${typeParam == 'PRE_EXAM' ? 'selected' : ''}>Trước khám (PRE_EXAM)</option>
                            <option value="POST_EXAM" ${typeParam == 'POST_EXAM' ? 'selected' : ''}>Sau khám (POST_EXAM)</option>
                            <option value="PRESCRIPTION" ${typeParam == 'PRESCRIPTION' ? 'selected' : ''}>Đơn thuốc (PRESCRIPTION)</option>
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

        <!-- Alerts -->
        <c:if test="${param.success == 'declined'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>
                Đã xác nhận từ chối mua thuốc thành công! Trạng thái hóa đơn đã cập nhật thành Từ chối mua.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

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
                                <th>Trạng Thế</th>
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
                                                <c:choose>
                                                    <c:when test="${inv.invoiceType == 'PRESCRIPTION'}">
                                                        <span class="badge bg-success-subtle text-success fw-medium border">Hóa đơn thuốc tây</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-light text-dark fw-medium border"><c:out value="${inv.serviceName != null ? inv.serviceName : 'Phí khám thai tổng quát'}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
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
                                                    <c:when test="${inv.invoiceType == 'PRESCRIPTION'}">
                                                        <span class="badge bg-success-subtle text-success border border-success-subtle">Đơn thuốc</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle">Chỉ định sau khám</span>
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
                                                    <c:when test="${inv.status == 'DeclinedPurchase'}">
                                                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle d-flex align-items-center gap-1 w-fit" title="Sản phụ từ chối mua thuốc tại phòng khám">
                                                            <i class="bi bi-x-circle-fill"></i> Từ chối mua thuốc
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
                                                <div class="d-flex gap-1 flex-wrap">
                                                    <c:choose>
                                                        <c:when test="${inv.status == 'Unpaid' || inv.status == 'PendingConfirmation'}">
                                                            <c:if test="${inv.status == 'PendingConfirmation'}">
                                                                <button type="button" class="btn btn-sm btn-outline-info fw-bold d-inline-flex align-items-center gap-1"
                                                                        onclick="openQRModal(${inv.id}, '${inv.patientName}', ${inv.totalAmount}, '${inv.appointmentId}', '${inv.transactionCode}', '${inv.invoiceType}', '${fn:escapeXml(inv.serviceName != null ? inv.serviceName : 'Phí khám thai tổng quát')}')">
                                                                    <i class="bi bi-qr-code-scan"></i> Xem QR
                                                                </button>
                                                            </c:if>
                                                            <button type="button" class="btn btn-sm btn-outline-success fw-bold d-inline-flex align-items-center gap-1"
                                                                    onclick="openPaymentModal(${inv.id}, '${inv.patientName}', ${inv.totalAmount}, '${inv.invoiceType}', '${inv.appointmentId}', '${inv.appointmentDate}', '${fn:escapeXml(inv.serviceName != null ? inv.serviceName : 'Phí khám thai tổng quát')}', '${inv.transactionCode}', '${inv.paymentMethod}', '${inv.proofImagePath}')">
                                                                <i class="bi bi-credit-card"></i> Xác nhận Paid
                                                            </button>
                                                            <c:if test="${inv.invoiceType == 'PRESCRIPTION'}">
                                                                <button type="button" class="btn btn-sm btn-outline-danger fw-bold d-inline-flex align-items-center gap-1"
                                                                        onclick="confirmDecline(${inv.id}, '${inv.patientName}')">
                                                                    <i class="bi bi-x-circle"></i> Từ chối
                                                                </button>
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button class="btn btn-sm btn-light border text-muted disabled" disabled>
                                                                <i class="bi bi-lock"></i> Khóa
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
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
            <input type="hidden" name="action" value="confirm">
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
                    <input type="hidden" id="modalAppointmentId" value="">
                    
                    <div class="mb-3">
                        <label class="text-muted small fw-bold">SẢN PHỤ</label>
                        <div class="fs-5 fw-bold text-dark" id="modalPatientName"></div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="text-muted small fw-bold">TỔNG TIỀN CẦN THU</label>
                        <div class="fs-4 fw-bold text-danger" id="modalTotalAmount"></div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <span class="text-muted small fw-bold">LOẠI HÓA ĐƠN</span>
                            <div><span class="badge bg-info text-dark" id="modalInvoiceType"></span></div>
                        </div>
                        <div class="col-6 text-end">
                            <span class="text-muted small fw-bold">NGÀY HẸN</span>
                            <div class="fw-bold text-dark" id="modalAppointmentDate"></div>
                        </div>
                    </div>

                    <div class="mb-3" id="modalServiceInfo">
                        <span class="text-muted small fw-bold">DỊCH VỤ ĐĂNG KÝ</span>
                        <div class="fw-bold text-dark" id="modalServiceName"></div>
                    </div>

                    <div id="modalRxInfo" style="display: none;" class="mb-3">
                        <span class="text-muted small fw-bold">DANH SÁCH THUỐC ĐÃ KÊ</span>
                        <div id="modalRxTable" class="mt-1"></div>
                    </div>

                    <div id="modalTestOrdersInfo" style="display: none;" class="mb-3">
                        <span class="text-muted small fw-bold">CHI TIẾT CHỈ ĐỊNH SIÊU ÂM</span>
                        <div id="modalTestOrdersTable" class="mt-1"></div>
                    </div>

                    <div id="modalTxInfo" style="display: none;" class="mb-3">
                        <div class="alert alert-info py-2 px-3 mb-0" style="font-size:13px;">
                            <span class="fw-bold"><i class="bi bi-info-circle me-1"></i>Thông tin thanh toán chuyển khoản:</span>
                            <div class="mt-1">
                                <strong>Mã giao dịch của BN:</strong> <code id="modalTxCode"></code><br>
                                <strong>Phương thức đăng ký:</strong> <span id="modalTxMethod"></span>
                            </div>
                        </div>
                    </div>

                    <div id="modalProofImageBox" style="display: none;" class="mb-3">
                        <label class="text-muted small fw-bold d-block mb-1">ẢNH MINH CHỨNG CHUYỂN KHOẢN (BỆNH NHÂN GỬI)</label>
                        <a id="modalProofImageLink" href="#" target="_blank">
                            <img id="modalProofImage" src="" alt="Ảnh minh chứng chuyển khoản"
                                 class="img-fluid rounded-3 border" style="max-height: 280px;">
                        </a>
                        <div class="form-text">Bấm vào ảnh để xem kích thước đầy đủ.</div>
                    </div>

                    <div id="modalNoProofBox" style="display: none;" class="mb-3">
                        <div class="alert alert-warning py-2 px-3 mb-0" style="font-size:13px;">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i>Bệnh nhân chưa gửi ảnh minh chứng chuyển khoản nào.
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold">PHƯƠNG THỨC THANH TOÁN THỰC TẾ</label>
                        <div class="d-flex gap-4">
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="paymentMethod" id="methodCash" value="Cash" checked>
                                <label class="form-check-label fw-bold text-dark" for="methodCash">
                                    <i class="bi bi-cash me-1 text-success"></i> Tiền mặt (Cash)
                                </label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="paymentMethod" id="methodTransfer" value="BankTransfer">
                                <label class="form-check-label fw-bold text-dark" for="methodTransfer">
                                    <i class="bi bi-bank me-1 text-primary"></i> Chuyển khoản (BankTransfer)
                                </label>
                            </div>
                        </div>
                    </div>

                </div>
                <div class="modal-footer bg-light border-0">
                    <button type="button" class="btn btn-secondary border" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="button" class="btn btn-outline-danger fw-bold" onclick="rejectCurrentPayment()">
                        <i class="bi bi-x-lg"></i> Từ chối thanh toán
                    </button>
                    <button type="submit" class="btn btn-success fw-bold px-4">
                        <i class="bi bi-check-lg"></i> Xác nhận PAID
                    </button>
                </div>
            </div>
        </form>

        <!-- Form riêng (không lồng trong form trên) để gửi Từ chối thanh toán sang StaffEditServlet -->
        <form id="rejectPaymentForm" method="POST" action="${pageContext.request.contextPath}/admin/reception/edit" style="display:none;">
            <input type="hidden" name="id" id="rejectApptId">
            <input type="hidden" name="invoiceId" id="rejectInvoiceIdInput">
            <input type="hidden" name="action" value="rejectPayment">
            <input type="hidden" name="rejectReason" id="rejectReasonInput">
        </form>
    </div>
</div>

<!-- View QR Code Modal -->
<div class="modal fade" id="qrModal" tabindex="-1" aria-labelledby="qrModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title fw-bold text-white" id="qrModalLabel">
                    <i class="bi bi-qr-code-scan"></i> Xem QR Code
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <div id="qrCodeDisplay" style="height: 200px; border: 1px solid #ccc; border-radius: 5px; display: none; text-align: center;">
                </div>
                <div id="paymentDetails" style="margin-top: 10px; font-size: 14px; color: #333;">
                </div>
            </div>
            <div class="modal-footer bg-light border-0">
                <button type="button" class="btn btn-secondary border" data-bs-dismiss="modal">Hủy bỏ</button>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    const prescriptionItemsData = {};
    <c:if test="${not empty prescriptionItemsJson}">
        <c:forEach var="entry" items="${prescriptionItemsJson.entrySet()}">
            <c:if test="${not empty entry.value}">
                prescriptionItemsData['${entry.key}'] = ${entry.value};
            </c:if>
        </c:forEach>
    </c:if>

    const testOrdersData = {};
    <c:if test="${not empty testOrdersJson}">
        <c:forEach var="entry" items="${testOrdersJson.entrySet()}">
            <c:if test="${not empty entry.value}">
                testOrdersData['${entry.key}'] = ${entry.value};
            </c:if>
        </c:forEach>
    </c:if>

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
    
    function openPaymentModal(invoiceId, patientName, amount, type, appointmentId, appointmentDate, serviceName, transactionCode, paymentMethod, proofImagePath) {
        document.getElementById('modalInvoiceId').value = invoiceId;
        document.getElementById('modalAppointmentId').value = appointmentId;
        document.getElementById('modalPatientName').textContent = patientName;
        document.getElementById('modalTotalAmount').textContent = new Intl.NumberFormat('vi-VN').format(amount) + 'đ';
        
        const typeLabels = {
            'PRE_EXAM': 'Trước khám',
            'POST_EXAM': 'Sau khám',
            'PRESCRIPTION': 'Đơn thuốc'
        };
        document.getElementById('modalInvoiceType').textContent = typeLabels[type] || type;
        document.getElementById('modalAppointmentDate').textContent = appointmentDate || '—';
        document.getElementById('modalServiceName').textContent = serviceName || '—';

        // Ảnh minh chứng chuyển khoản do bệnh nhân gửi (nếu có)
        const proofBox = document.getElementById('modalProofImageBox');
        const noProofBox = document.getElementById('modalNoProofBox');
        const proofImg = document.getElementById('modalProofImage');
        const proofLink = document.getElementById('modalProofImageLink');
        if (proofImagePath && proofImagePath.trim() !== '' && proofImagePath !== 'null') {
            const fullUrl = '${pageContext.request.contextPath}' + proofImagePath;
            proofImg.src = fullUrl;
            proofLink.href = fullUrl;
            proofBox.style.display = 'block';
            noProofBox.style.display = 'none';
        } else {
            proofBox.style.display = 'none';
            noProofBox.style.display = (paymentMethod === 'BankTransfer') ? 'block' : 'none';
        }

        // Display transaction details if the patient already paid online
        const txInfo = document.getElementById('modalTxInfo');
        const txCode = document.getElementById('modalTxCode');
        const txMethod = document.getElementById('modalTxMethod');

        if (transactionCode && transactionCode.trim() !== '' && transactionCode !== 'null') {
            txInfo.style.display = 'block';
            txCode.textContent = transactionCode;
            txMethod.textContent = paymentMethod === 'BankTransfer' ? 'Chuyển khoản' : 'Tiền mặt';
        } else {
            txInfo.style.display = 'none';
        }

        // Pre-select payment method thực tế dựa theo phương thức bệnh nhân đã đăng ký
        if (paymentMethod === 'BankTransfer') {
            document.getElementById('methodTransfer').checked = true;
        } else {
            document.getElementById('methodCash').checked = true;
        }

        // Reset prescription list
        const modalRxTable = document.getElementById('modalRxTable');
        const modalRxInfo = document.getElementById('modalRxInfo');
        const prescriptionItems = prescriptionItemsData[invoiceId] || [];
        if (type === 'PRESCRIPTION' && prescriptionItems.length > 0) {
            let html = '<table class="table table-sm mb-0" style="font-size:13px;"><thead><tr><th>#</th><th>Tên thuốc</th><th>Đơn vị</th><th class="text-center">SL</th><th class="text-end">Đơn giá</th><th class="text-end">Thành tiền</th></tr></thead><tbody>';
            prescriptionItems.forEach(function(item, idx) {
                const lineTotal = (item.price * item.quantity);
                html += '<tr>' +
                    '<td>' + (idx + 1) + '</td>' +
                    '<td>' + (item.name || '') + '</td>' +
                    '<td>' + (item.unit || '') + '</td>' +
                    '<td class="text-center">' + item.quantity + '</td>' +
                    '<td class="text-end">' + new Intl.NumberFormat('vi-VN').format(item.price) + 'đ</td>' +
                    '<td class="text-end">' + new Intl.NumberFormat('vi-VN').format(lineTotal) + 'đ</td>' +
                    '</tr>';
            });
            html += '</tbody></table>';
            modalRxTable.innerHTML = html;
            modalRxInfo.style.display = 'block';
        } else {
            modalRxInfo.style.display = 'none';
        }

        // Reset test orders list
        const modalTestOrdersTable = document.getElementById('modalTestOrdersTable');
        const modalTestOrdersInfo = document.getElementById('modalTestOrdersInfo');
        const testOrders = testOrdersData[invoiceId] || [];
        if (type === 'POST_EXAM' && testOrders.length > 0) {
            let html = '<table class="table table-sm mb-0" style="font-size:13px;"><thead><tr><th>#</th><th>Tên dịch vụ</th><th class="text-end">Đơn giá</th></tr></thead><tbody>';
            testOrders.forEach(function(item, idx) {
                html += '<tr>' +
                    '<td>' + (idx + 1) + '</td>' +
                    '<td>' + (item.name || '') + '</td>' +
                    '<td class="text-end">' + new Intl.NumberFormat('vi-VN').format(item.price) + 'đ</td>' +
                    '</tr>';
            });
            html += '</tbody></table>';
            modalTestOrdersTable.innerHTML = html;
            modalTestOrdersInfo.style.display = 'block';
        } else {
            modalTestOrdersInfo.style.display = 'none';
        }
        
        paymentModal.show();
    }

    function validatePaymentForm() {
        // Mã giao dịch giờ chỉ là thông tin bổ sung tuỳ chọn — bằng chứng chính là ảnh
        // minh chứng chuyển khoản bệnh nhân đã gửi (hiển thị phía trên), nên không bắt buộc nữa.
        return true;
    }

    function rejectCurrentPayment() {
        const apptId = document.getElementById('modalAppointmentId').value;
        const invoiceId = document.getElementById('modalInvoiceId').value;
        if (!apptId || !invoiceId) {
            alert('Không xác định được hóa đơn cần từ chối.');
            return;
        }
        const reason = prompt('Lý do từ chối thanh toán (bệnh nhân sẽ mất slot đã giữ, phải đặt lại lịch):');
        if (reason === null) return; // bấm Cancel
        document.getElementById('rejectApptId').value = apptId;
        document.getElementById('rejectInvoiceIdInput').value = invoiceId;
        document.getElementById('rejectReasonInput').value = reason;
        document.getElementById('rejectPaymentForm').submit();
    }

    const qrModal = new bootstrap.Modal(document.getElementById('qrModal'));

    function openQRModal(invoiceId, patientName, amount, appointmentId, transactionCode, invoiceType, serviceName) {
        const qrCodeDisplay = document.getElementById('qrCodeDisplay');
        const paymentDetailsDiv = document.getElementById('paymentDetails');

        // Generate VietQR URL
        const bankAccount = "0967629020";
        const bankName = "mb"; // MB Bank
        const amount_long = Math.floor(parseFloat(amount));
        const accountName = "PHONG KHAM SAN PHU";
        const description = "CAMSHD" + appointmentId;

        // VietQR API - compact format
        const qrUrl = "https://img.vietqr.io/image/" + bankName + "-" + bankAccount + "-compact2.png?amount=" + amount_long + "&addInfo=" + encodeURIComponent(description) + "&accountName=" + encodeURIComponent(accountName);

        // Create QR code display with image
        qrCodeDisplay.innerHTML = '<img src="' + qrUrl + '" alt="QR Code" style="max-width: 200px; height: auto; object-fit: contain; border-radius: 5px;">';
        qrCodeDisplay.style.display = 'block';

        // Fetch prescription items or test orders
        const prescriptionItems = prescriptionItemsData[invoiceId] || [];
        const testOrders = testOrdersData[invoiceId] || [];

        let itemsHtml = '';
        if (invoiceType === 'PRESCRIPTION' && prescriptionItems.length > 0) {
            itemsHtml += '<div style="margin-top: 10px; border-top: 1px solid #e0e0e0; padding-top: 10px;">' +
                         '<strong>Danh sách thuốc đã kê:</strong>' +
                         '<table class="table table-sm mb-0 mt-1" style="font-size:12px;">' +
                         '<thead><tr><th>Tên thuốc</th><th class="text-center">SL</th><th class="text-end">Đơn giá</th></tr></thead><tbody>';
            prescriptionItems.forEach(item => {
                itemsHtml += '<tr><td>' + item.name + '</td><td class="text-center">' + item.quantity + '</td><td class="text-end">' + new Intl.NumberFormat('vi-VN').format(item.price) + 'đ</td></tr>';
            });
            itemsHtml += '</tbody></table></div>';
        } else if (invoiceType === 'POST_EXAM' && testOrders.length > 0) {
            itemsHtml += '<div style="margin-top: 10px; border-top: 1px solid #e0e0e0; padding-top: 10px;">' +
                         '<strong>Danh sách chỉ định siêu âm:</strong>' +
                         '<table class="table table-sm mb-0 mt-1" style="font-size:12px;">' +
                         '<thead><tr><th>Tên dịch vụ</th><th class="text-end">Đơn giá</th></tr></thead><tbody>';
            testOrders.forEach(item => {
                itemsHtml += '<tr><td>' + item.name + '</td><td class="text-end">' + new Intl.NumberFormat('vi-VN').format(item.price) + 'đ</td></tr>';
            });
            itemsHtml += '</tbody></table></div>';
        } else if (invoiceType === 'PRE_EXAM') {
            itemsHtml += '<div style="margin-top: 10px; border-top: 1px solid #e0e0e0; padding-top: 10px;">' +
                         '<strong>Dịch vụ khám đăng ký:</strong> <span class="fw-bold">' + (serviceName || 'Khám thai định kỳ') + '</span>' +
                         '</div>';
        }

        // Display payment details
        const formattedAmount = new Intl.NumberFormat('vi-VN').format(amount_long) + 'đ';
        const typeLabels = {
            'PRE_EXAM': 'Trước khám',
            'POST_EXAM': 'Sau khám',
            'PRESCRIPTION': 'Đơn thuốc'
        };
        const invoiceTypeLabel = typeLabels[invoiceType] || invoiceType;

        paymentDetailsDiv.innerHTML =
            '<div style="margin-top: 15px;">' +
                '<div class="row">' +
                    '<div class="col-6">' +
                        '<strong>Bệnh nhân:</strong> ' + patientName + '<br>' +
                        '<strong>Mã GD:</strong> <code>' + (transactionCode || 'Chưa nhập') + '</code>' +
                    '</div>' +
                    '<div class="col-6 text-end">' +
                        '<strong>Số tiền:</strong> <span class="text-danger fw-bold">' + formattedAmount + '</span><br>' +
                        '<strong>Phân loại:</strong> <span class="badge bg-info text-dark">' + invoiceTypeLabel + '</span>' +
                    '</div>' +
                '</div>' +
                itemsHtml +
                '<div style="margin-top: 10px; border-top: 1px solid #e0e0e0; padding-top: 10px; font-size: 13px;">' +
                    '<strong>Thông tin chuyển khoản ngân hàng:</strong><br>' +
                    'Ngân hàng: <strong>MB Bank</strong><br>' +
                    'Số TK: <strong>' + bankAccount + '</strong><br>' +
                    'Chủ TK: <strong>' + accountName + '</strong><br>' +
                    'Nội dung: <strong>' + description + '</strong>' +
                '</div>' +
            '</div>';

        qrModal.show();
    }

    function confirmDecline(invoiceId, patientName) {
        if (confirm("Xác nhận sản phụ '" + patientName + "' từ chối mua đơn thuốc này? Trạng thái hóa đơn sẽ chuyển thành 'Từ chối mua thuốc' và đơn thuốc sẽ bị Hủy.")) {
            document.getElementById('declineInvoiceId').value = invoiceId;
            document.getElementById('declineForm').submit();
        }
    }
</script>

<!-- Hidden Form for Decline Purchase -->
<form id="declineForm" method="POST" action="${pageContext.request.contextPath}/admin/reception/payments" style="display:none;">
    <input type="hidden" name="invoiceId" id="declineInvoiceId">
    <input type="hidden" name="action" value="decline">
    <input type="hidden" name="search" value="${searchParam}">
    <input type="hidden" name="status" value="${statusParam}">
    <input type="hidden" name="type" value="${typeParam}">
    <input type="hidden" name="date" value="${dateParam}">
    <input type="hidden" name="page" value="${currentPage}">
</form>

</body>
</html>

