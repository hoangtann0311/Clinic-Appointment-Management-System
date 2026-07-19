<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 patient-hero-card rounded-4">
            <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div>
                    <h2 class="fw-bold mb-1"><i class="bi bi-wallet2 me-2"></i>Thanh Toán Của Tôi</h2>
                    <p class="mb-0 opacity-75">Quản lý hóa đơn lâm sàng, hóa đơn sau khám và đơn thuốc.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-light text-pink-theme fw-bold rounded-3">
                        <i class="bi bi-calendar2-week me-1"></i>Xem Lịch Hẹn
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Metrics Summary --%>
<div class="row g-3 mb-4">
    <c:set var="totalCount" value="${fn:length(invoices)}" />
    <c:set var="unpaidCount" value="0" />
    <c:set var="pendingCount" value="0" />
    <c:set var="paidCount" value="0" />
    <c:forEach var="inv" items="${invoices}">
        <c:choose>
            <c:when test="${inv.status == 'Unpaid'}">
                <c:set var="unpaidCount" value="${unpaidCount + 1}" />
            </c:when>
            <c:when test="${inv.status == 'PendingConfirmation'}">
                <c:set var="pendingCount" value="${pendingCount + 1}" />
            </c:when>
            <c:when test="${inv.status == 'Paid'}">
                <c:set var="paidCount" value="${paidCount + 1}" />
            </c:when>
        </c:choose>
    </c:forEach>

    <div class="col-md-4">
        <div class="card border-0 shadow-sm rounded-3 bg-white p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="rounded-circle bg-danger bg-opacity-10 text-danger d-flex align-items-center justify-content-center" style="width:48px;height:48px;">
                    <i class="bi bi-exclamation-circle-fill fs-4"></i>
                </div>
                <div>
                    <h6 class="text-muted small fw-medium mb-1">Chưa Thanh Toán</h6>
                    <h4 class="fw-bold mb-0 text-danger">${unpaidCount} <span class="fs-6 fw-normal text-muted">hóa đơn</span></h4>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm rounded-3 bg-white p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="rounded-circle bg-warning bg-opacity-10 text-warning d-flex align-items-center justify-content-center" style="width:48px;height:48px;">
                    <i class="bi bi-hourglass-split fs-4"></i>
                </div>
                <div>
                    <h6 class="text-muted small fw-medium mb-1">Đang Chờ Xác Nhận</h6>
                    <h4 class="fw-bold mb-0 text-warning">${pendingCount} <span class="fs-6 fw-normal text-muted">yêu cầu</span></h4>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 shadow-sm rounded-3 bg-white p-3">
            <div class="d-flex align-items-center gap-3">
                <div class="rounded-circle bg-success bg-opacity-10 text-success d-flex align-items-center justify-content-center" style="width:48px;height:48px;">
                    <i class="bi bi-check-circle-fill fs-4"></i>
                </div>
                <div>
                    <h6 class="text-muted small fw-medium mb-1">Đã Thanh Toán</h6>
                    <h4 class="fw-bold mb-0 text-success">${paidCount} <span class="fs-6 fw-normal text-muted">giao dịch</span></h4>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Invoices List Card --%>
<div class="card border-0 shadow-sm rounded-4">
    <div class="card-header bg-transparent border-0 p-4 pb-0">
        <h5 class="fw-bold text-dark mb-0">
            <i class="bi bi-list-stars me-2 text-primary"></i>Danh Sách Hóa Đơn
        </h5>
    </div>
    <div class="card-body p-4 pt-3">
        <c:choose>
            <c:when test="${empty invoices}">
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-receipt-cutoff d-block mb-3" style="font-size: 3rem; opacity: .3;"></i>
                    Bạn chưa có bất kỳ hóa đơn nào trong hệ thống.
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Mã Hóa Đơn</th>
                                <th>Ngày Tạo</th>
                                <th>Phân Loại</th>
                                <th>Nội Dung / Dịch Vụ</th>
                                <th>Tổng Tiền</th>
                                <th>Trạng Thái</th>
                                <th class="text-end">Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="inv" items="${invoices}">
                                <tr>
                                    <td><strong>HĐ-${inv.id}</strong></td>
                                    <td>
                                        <fmt:formatDate value="${inv.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
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
                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle">Dịch vụ sau khám</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${inv.invoiceType == 'PRESCRIPTION'}">
                                                <i class="bi bi-capsule-capsule me-1"></i>Đơn thuốc tây bác sĩ kê
                                            </c:when>
                                            <c:otherwise>
                                                <c:out value="${inv.serviceName != null ? inv.serviceName : 'Khám thai định kỳ'}"/>
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="text-muted small mt-1">
                                            <i class="bi bi-person-fill-gear me-1"></i>Bác sĩ: BS. <c:out value="${inv.doctorName != null ? inv.doctorName : 'Chưa chỉ định'}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <strong class="text-danger">
                                            <fmt:formatNumber value="${inv.totalAmount}" pattern="#,###"/>đ
                                        </strong>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${inv.status == 'Paid'}">
                                                <span class="badge bg-success-subtle text-success border border-success-subtle">
                                                    <i class="bi bi-check-circle me-1"></i>Đã thanh toán
                                                </span>
                                                <c:if test="${not empty inv.paymentMethod}">
                                                    <div class="text-muted small mt-1" style="font-size:10px;">
                                                        ${inv.paymentMethod == 'Cash' ? 'Tiền mặt' : 'Chuyển khoản'}
                                                    </div>
                                                </c:if>
                                            </c:when>
                                            <c:when test="${inv.status == 'PendingConfirmation'}">
                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle">
                                                    <i class="bi bi-clock-history me-1"></i>Chờ xác nhận
                                                </span>
                                            </c:when>
                                            <c:when test="${inv.status == 'DeclinedPurchase'}">
                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle">
                                                    <i class="bi bi-x-circle me-1"></i>Từ chối mua thuốc
                                                </span>
                                            </c:when>
                                            <c:when test="${inv.status == 'Cancelled'}">
                                                <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle">
                                                    <i class="bi bi-slash-circle me-1"></i>Đã hủy
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle">
                                                    <i class="bi bi-x-circle-fill me-1"></i>Chưa thanh toán
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <c:choose>
                                            <c:when test="${inv.status == 'Unpaid'}">
                                                <a href="${pageContext.request.contextPath}/patient/payment?appointmentId=${inv.appointmentId}&type=${inv.invoiceType}"
                                                   class="btn btn-sm btn-outline-success fw-bold rounded-pill px-3">
                                                    <i class="bi bi-credit-card me-1"></i>Thanh Toán
                                                </a>
                                            </c:when>
                                            <c:when test="${inv.status == 'PendingConfirmation' || inv.status == 'Paid'}">
                                                <a href="${pageContext.request.contextPath}/patient/payment?appointmentId=${inv.appointmentId}&type=${inv.invoiceType}"
                                                   class="btn btn-sm btn-outline-secondary rounded-pill px-3">
                                                    <i class="bi bi-eye me-1"></i>Xem Chi Tiết
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn btn-sm btn-light border text-muted disabled rounded-pill px-3" disabled>
                                                    <i class="bi bi-lock me-1"></i>Khóa
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
