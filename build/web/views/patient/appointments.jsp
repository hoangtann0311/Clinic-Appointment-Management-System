<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<style>
    .appt-table { width: 100%; }
    .appt-table thead th {
        font-size: .75rem; font-weight: 700; text-transform: uppercase;
        letter-spacing: .04em; color: #64748b; padding: .6rem .75rem;
        background: #f8fafc; border-bottom: 2px solid #e2e8f0;
        white-space: nowrap;
    }
    .appt-table tbody td {
        padding: .7rem .75rem; font-size: .85rem; color: #1e293b;
        vertical-align: middle;
    }
    .appt-table tbody tr {
        border-bottom: 1px solid #f1f5f9;
        transition: background .12s;
    }
    .appt-table tbody tr:last-child { border-bottom: 0; }
    .appt-table tbody tr:hover { background: #f8fafc; }

    /* Status chip */
    .st-chip {
        display: inline-flex; align-items: center; gap: 5px;
        padding: .22rem .65rem; border-radius: 2rem;
        font-size: .75rem; font-weight: 600; white-space: nowrap;
    }
    .st-chip::before {
        content: ''; width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0;
    }
    .st-confirmed  { background: #dcfce7; color: #15803d; } .st-confirmed::before { background: #15803d; }
    .st-pending    { background: #fef9c3; color: #a16207; } .st-pending::before   { background: #a16207; }
    .st-waiting    { background: #dbeafe; color: #1d4ed8; } .st-waiting::before   { background: #1d4ed8; }
    .st-success    { background: #e0f2fe; color: #0369a1; } .st-success::before   { background: #0369a1; }
    .st-inprogress { background: #f3e8ff; color: #7c3aed; } .st-inprogress::before{ background: #7c3aed; }
    .st-cancelled  { background: #fee2e2; color: #b91c1c; } .st-cancelled::before { background: #b91c1c; }
    .st-noshow     { background: #f3f4f6; color: #6b7280; } .st-noshow::before    { background: #6b7280; }

    /* Payment status */
    .pay-paid    { color: #15803d; font-weight: 500; }
    .pay-unpaid  { color: #dc2626; font-weight: 500; }
    .pay-na      { color: #94a3b8; }

    /* Action buttons */
    .act-group {
        display: flex; gap: 6px; align-items: center; white-space: nowrap;
    }
    .act-group .btn-action {
        font-size: .76rem; padding: .3rem .6rem; border-radius: .4rem; font-weight: 500;
    }
    .act-group form { display: inline; margin: 0; }
</style>

<div class="mb-4">
    <div class="card border-0 patient-hero-card rounded-4">
        <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div>
                <h2 class="fw-bold mb-1"><i class="bi bi-calendar2-week me-2"></i>Lịch Hẹn Của Tôi</h2>
                <p class="mb-0 opacity-75">Quản lý lịch khám, thanh toán và theo dõi trạng thái.</p>
            </div>
            <a href="${pageContext.request.contextPath}/patient/booking"
               class="btn btn-light text-pink-theme fw-bold rounded-3">
                <i class="bi bi-plus-circle me-1"></i>Đặt Lịch Mới
            </a>
        </div>
    </div>
</div>

<%-- Toast --%>
<c:if test="${not empty bookingSuccess}">
    <div class="alert alert-success alert-dismissible fade show" data-cams-toast role="alert"><i class="bi bi-check-circle-fill me-2"></i>${bookingSuccess}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
</c:if>
<c:if test="${not empty bookingError}">
    <div class="alert alert-danger alert-dismissible fade show" data-cams-toast role="alert"><i class="bi bi-exclamation-triangle-fill me-2"></i>${bookingError}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
</c:if>

<%-- Filter bar --%>
<form action="${pageContext.request.contextPath}/patient/appointments" method="GET" class="mb-4">
    <div class="row">
        <div class="col-md-7 col-lg-6">
            <div class="input-group">
                <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                <input type="text" name="keyword" class="form-control border-start-0 ps-0"
                       value="${fn:escapeXml(keyword)}" placeholder="Tìm bác sĩ, dịch vụ...">
                <select name="status" class="form-select" style="max-width:155px;">
                    <option value="">-- Trạng thái --</option>
                    <option value="Pending" ${status == 'Pending' ? 'selected' : ''}>Chờ duyệt</option>
                    <option value="Confirmed" ${status == 'Confirmed' ? 'selected' : ''}>Đã duyệt</option>
                    <option value="Waiting" ${status == 'Waiting' ? 'selected' : ''}>Đang chờ khám</option>
                    <option value="InProgress" ${status == 'InProgress' ? 'selected' : ''}>Đang khám</option>
                    <option value="Completed" ${status == 'Completed' ? 'selected' : ''}>Đã hoàn thành</option>
                    <option value="Cancelled" ${status == 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                </select>
                <button type="submit" class="btn btn-primary">Tìm</button>
            </div>
        </div>
    </div>
</form>

<c:choose>
    <%-- ── Empty ── --%>
    <c:when test="${empty appointments}">
        <div class="card rounded-4 border-0 shadow-sm">
            <div class="card-body text-center text-muted py-5">
                <i class="bi bi-calendar-x d-block mb-2" style="font-size:2.5rem;opacity:.3;"></i>
                Bạn chưa có lịch hẹn nào.
                <div class="mt-3">
                    <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-primary rounded-pill">
                        <i class="bi bi-plus-circle me-1"></i>Đặt lịch khám ngay
                    </a>
                </div>
            </div>
        </div>
    </c:when>

    <%-- ── Table ── --%>
    <c:otherwise>
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
            <div class="table-responsive">
                <table class="table align-middle mb-0 appt-table">
                    <thead>
                        <tr>
                            <th>Ngày / Giờ</th>
                            <th>Bác sĩ</th>
                            <th>Dịch vụ</th>
                            <th>Trạng thái</th>
                            <th>Thanh toán</th>
                            <th class="text-center" style="width:120px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${appointments}">
                            <c:set var="st" value="${fn:toLowerCase(a.status)}" />
                            <tr>
                                <%-- Ngày + Giờ gộp chung --%>
                                <td>
                                    <div class="fw-semibold">${a.appointmentDate}</div>
                                    <c:set var="ts" value="${a.timeSlot}"/>
                                    <div class="small text-muted">
                                        <c:choose>
                                            <c:when test="${fn:contains(ts, '(')}">
                                                <c:set var="timeOnly" value="${fn:substringAfter(ts, '(')}"/>
                                                ${fn:substringBefore(timeOnly, ')')}
                                            </c:when>
                                            <c:otherwise>${ts}</c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                                <%-- Bác sĩ --%>
                                <td>
                                    <c:out value="${not empty a.doctor ? a.doctor.fullName : '—'}"/>
                                </td>
                                <%-- Dịch vụ --%>
                                <td>
                                    <c:out value="${not empty a.serviceName ? a.serviceName : 'Khám lâm sàng'}"/>
                                </td>
                                <%-- Trạng thái --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${st == 'confirmed'}"><span class="st-chip st-confirmed">Đã xác nhận</span></c:when>
                                        <c:when test="${st == 'pending'}"><span class="st-chip st-pending">Chờ duyệt</span></c:when>
                                        <c:when test="${st == 'waiting'}"><span class="st-chip st-waiting">Chờ khám</span></c:when>
                                        <c:when test="${st == 'success' || st == 'completed'}"><span class="st-chip st-success">Hoàn thành</span></c:when>
                                        <c:when test="${st == 'inprogress'}"><span class="st-chip st-inprogress">Đang khám</span></c:when>
                                        <c:when test="${st == 'cancelled'}"><span class="st-chip st-cancelled">Đã huỷ</span></c:when>
                                        <c:when test="${st == 'noshow'}"><span class="st-chip st-noshow">Vắng mặt</span></c:when>
                                        <c:otherwise><span class="st-chip" style="background:#f3f4f6;color:#6b7280;">${a.status}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <%-- Thanh toán --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${st == 'cancelled' || st == 'noshow'}">
                                            <span class="pay-na">—</span>
                                        </c:when>
                                        <c:when test="${preExamPaymentStatuses[a.id] == 'Paid' || st == 'waiting' || st == 'inprogress' || st == 'success' || st == 'completed'}">
                                            <c:set var="payMethod" value="${preExamPaymentMethods[a.id]}"/>
                                            <c:choose>
                                                <c:when test="${payMethod == 'Cash'}">
                                                    <span class="pay-paid"><i class="bi bi-cash-stack me-1"></i>Tiền mặt</span>
                                                </c:when>
                                                <c:when test="${payMethod == 'BankTransfer'}">
                                                    <span class="pay-paid"><i class="bi bi-bank me-1"></i>Chuyển khoản</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="pay-paid"><i class="bi bi-check-circle me-1"></i>Đã thanh toán</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pay-unpaid"><i class="bi bi-exclamation-circle me-1"></i>Chưa thanh toán</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <%-- Thao tác --%>
                                <td class="text-center">
                                    <div class="act-group">
                                        <c:if test="${st == 'pending' || st == 'confirmed'}">
                                            <a href="${pageContext.request.contextPath}/patient/booking?rescheduleId=${a.id}"
                                               class="btn btn-outline-warning btn-sm btn-action" title="Đổi lịch">
                                                <i class="bi bi-arrow-repeat"></i>
                                            </a>
                                        </c:if>
                                        <c:if test="${(st == 'pending' || st == 'confirmed') && a.preExamPaymentStatus != 'Paid'}">
                                            <form method="post" action="${pageContext.request.contextPath}/patient/appointments"
                                                  onsubmit="return confirm('Bạn có chắc muốn huỷ lịch hẹn này?');">
                                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="action" value="cancel">
                                                <input type="hidden" name="appointmentId" value="${a.id}">
                                                <button type="submit" class="btn btn-outline-danger btn-sm btn-action" title="Huỷ lịch">
                                                    <i class="bi bi-x-lg"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <%-- Footer --%>
            <div class="px-3 py-2 border-top d-flex justify-content-between align-items-center small text-muted">
                <span>Tổng <strong class="text-dark">${fn:length(appointments)}</strong> lịch hẹn</span>
                <span><i class="bi bi-info-circle me-1"></i>Huỷ/đổi lịch trước giờ hẹn khi chưa thanh toán</span>
            </div>

            <c:if test="${totalPages > 1}">
                <div class="p-3 border-top d-flex justify-content-center">
                    <nav><ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&keyword=${fn:escapeXml(keyword)}&status=${fn:escapeXml(status)}">Trước</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&keyword=${fn:escapeXml(keyword)}&status=${fn:escapeXml(status)}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&keyword=${fn:escapeXml(keyword)}&status=${fn:escapeXml(status)}">Sau</a>
                        </li>
                    </ul></nav>
                </div>
            </c:if>
        </div>
    </c:otherwise>
</c:choose>

<%@ include file="../common/footer.jsp" %>
