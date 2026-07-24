<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<style>
    .appt-card { border-radius: .75rem; border: 0; box-shadow: 0 1px 3px rgba(0,0,0,.05); overflow: hidden; }
    .appt-table { table-layout: fixed; width: 100%; }
    .appt-table thead th {
        font-size: .78rem; font-weight: 700; text-transform: uppercase;
        letter-spacing: .03em; color: #64748b; padding: .7rem .6rem;
        background: #f8fafc; border-bottom: 2px solid #e2e8f0;
        white-space: nowrap;
    }
    .appt-table tbody td {
        padding: .65rem .6rem; font-size: .86rem; color: #172033;
        vertical-align: middle;
    }
    .appt-table tbody tr { transition: background .1s; border-bottom: 1px solid #f1f5f9; }
    .appt-table tbody tr:last-child { border-bottom: 0; }
    .appt-table tbody tr:hover { background: #fafbfc; }

    /* Column widths */
    .col-date    { width: 10%; }
    .col-time    { width: 13%; }
    .col-doctor  { width: 16%; }
    .col-service { width: 12%; }
    .col-status  { width: 13%; }
    .col-actions { width: 36%; }

    .col-date, .col-time, .col-service { white-space: nowrap; }
    .col-doctor { white-space: normal; word-break: break-word; }

    /* Status chips */
    .st-chip {
        display: inline-block; padding: .2rem .6rem; border-radius: 2rem;
        font-size: .76rem; font-weight: 600; line-height: 1.35;
    }
    .st-confirmed  { background: #dcfce7; color: #15803d; }
    .st-pending    { background: #fef9c3; color: #a16207; }
    .st-waiting    { background: #dbeafe; color: #1d4ed8; }
    .st-success    { background: #e0f2fe; color: #0369a1; }
    .st-inprogress { background: #e0f2fe; color: #0369a1; }
    .st-cancelled  { background: #fee2e2; color: #b91c1c; }
    .st-noshow     { background: #f3f4f6; color: #6b7280; }

    /* Actions */
    .act-group {
        display: flex; flex-wrap: wrap; justify-content: flex-end;
        align-items: center; gap: 4px;
    }
    .act-group .btn {
        font-size: .74rem; padding: .25rem .55rem; border-radius: .4rem;
        white-space: nowrap; font-weight: 500;
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

<%-- Toast notifications --%>
<c:if test="${not empty bookingSuccess}">
    <div class="alert alert-success alert-dismissible fade show" data-cams-toast role="alert"><i class="bi bi-check-circle-fill me-2"></i>${bookingSuccess}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
</c:if>
<c:if test="${not empty bookingError}">
    <div class="alert alert-danger alert-dismissible fade show" data-cams-toast role="alert"><i class="bi bi-exclamation-triangle-fill me-2"></i>${bookingError}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
</c:if>

<c:choose>
    <%-- ── Empty state ── --%>
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

    <%-- ── Appointments table ── --%>
    <c:otherwise>
        <div class="card appt-card">
            <div class="card-body p-0">
                <table class="table table-hover align-middle mb-0 appt-table">
                    <thead>
                        <tr>
                            <th class="col-date">Ngày khám</th>
                            <th class="col-time">Giờ</th>
                            <th class="col-doctor">Bác sĩ</th>
                            <th class="col-service">Dịch vụ</th>
                            <th class="col-status">Trạng thái</th>
                            <th class="col-actions text-end pe-3">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${appointments}">
                            <c:set var="st" value="${fn:toLowerCase(a.status)}" />
                            <tr>
                                <td class="col-date fw-medium ps-3">${a.appointmentDate}</td>
                                <td class="col-time">${a.timeSlot}</td>
                                <td class="col-doctor" title="<c:out value='${not empty a.doctor ? a.doctor.fullName : ""}'/>">
                                    <c:out value="${not empty a.doctor ? a.doctor.fullName : '—'}"/>
                                </td>
                                <td class="col-service text-truncate" title="<c:out value='${a.serviceName}'/>">
                                    <c:out value="${not empty a.serviceName ? a.serviceName : 'Khám lâm sàng'}"/>
                                </td>
                                <td class="col-status">
                                    <%-- Appointment status chip --%>
                                    <c:choose>
                                        <c:when test="${st == 'confirmed'}"><span class="st-chip st-confirmed">Đã xác nhận</span></c:when>
                                        <c:when test="${st == 'pending'}"><span class="st-chip st-pending">Chờ xác nhận</span></c:when>
                                        <c:when test="${st == 'waiting'}"><span class="st-chip st-waiting">Chờ khám</span></c:when>
                                        <c:when test="${st == 'success' || st == 'completed'}"><span class="st-chip st-success">Hoàn thành</span></c:when>
                                        <c:when test="${st == 'inprogress'}"><span class="st-chip st-inprogress">Đang khám</span></c:when>
                                        <c:when test="${st == 'cancelled'}"><span class="st-chip st-cancelled">Đã huỷ</span></c:when>
                                        <c:when test="${st == 'noshow'}"><span class="st-chip st-noshow">Vắng mặt</span></c:when>
                                        <c:otherwise><span class="st-chip" style="background:#f3f4f6;color:#6b7280;">${a.status}</span></c:otherwise>
                                    </c:choose>
                                    <%-- Payment status — only for active appointments --%>
                                    <c:if test="${st == 'pending' || st == 'confirmed' || st == 'waiting'}">
                                        <div style="font-size:.7rem;margin-top:3px;">
                                            <c:choose>
                                                <c:when test="${a.preExamPaymentStatus == 'Paid'}"><span style="color:#15803d;"><i class="bi bi-check-circle-fill me-1"></i>Đã thanh toán</span></c:when>
                                                <c:when test="${a.preExamPaymentStatus == 'PendingConfirmation'}"><span style="color:#d97706;"><i class="bi bi-hourglass-split me-1"></i>Chờ xác nhận</span></c:when>
                                                <c:when test="${a.preExamPaymentStatus == 'Cancelled'}"><span style="color:#9ca3af;"><i class="bi bi-x-circle me-1"></i>Đã huỷ hoá đơn</span></c:when>
                                                <c:otherwise><span style="color:#dc2626;"><i class="bi bi-exclamation-circle me-1"></i>Chưa thanh toán</span></c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:if>
                                </td>
                                <td class="col-actions text-end pe-3">
                                    <div class="act-group">
                                        <%-- Thanh toán --%>
                                        <c:if test="${a.preExamPaymentStatus != 'Paid' && a.preExamPaymentStatus != 'PendingConfirmation' && st == 'pending'}">
                                            <a href="${pageContext.request.contextPath}/patient/payment?appointmentId=${a.id}"
                                               class="btn btn-success btn-sm"><i class="bi bi-credit-card me-1"></i>Thanh toán</a>
                                        </c:if>
                                        <%-- Đóng phí DV --%>
                                        <c:if test="${not empty postExamInvoices[a.id]}">
                                            <a href="${pageContext.request.contextPath}/patient/payment?appointmentId=${a.id}&type=POST_EXAM"
                                               class="btn btn-outline-info btn-sm"><i class="bi bi-receipt me-1"></i>Đóng phí DV</a>
                                        </c:if>
                                        <%-- Mua thuốc --%>
                                        <c:if test="${not empty prescriptionInvoices[a.id]}">
                                            <a href="${pageContext.request.contextPath}/patient/payment?appointmentId=${a.id}&type=PRESCRIPTION"
                                               class="btn btn-outline-success btn-sm"><i class="bi bi-capsule me-1"></i>Mua thuốc</a>
                                        </c:if>
                                        <%-- Chọn mua thuốc --%>
                                        <c:if test="${not empty pendingPrescriptionChoices[a.id]}">
                                            <a href="${pageContext.request.contextPath}/patient/invoices#prescription-decisions"
                                               class="btn btn-outline-success btn-sm"><i class="bi bi-ui-checks me-1"></i>Chọn thuốc</a>
                                        </c:if>
                                        <%-- Đổi lịch: chỉ khi chưa thanh toán xong --%>
                                        <c:if test="${st == 'pending' && a.preExamPaymentStatus != 'Paid'}">
                                            <a href="${pageContext.request.contextPath}/patient/booking?rescheduleId=${a.id}"
                                               class="btn btn-outline-warning btn-sm"><i class="bi bi-arrow-repeat me-1"></i>Đổi lịch</a>
                                        </c:if>
                                        <%-- Huỷ: chỉ khi chưa thanh toán xong --%>
                                        <c:if test="${st == 'pending' && a.preExamPaymentStatus != 'Paid'}">
                                            <form method="post" action="${pageContext.request.contextPath}/patient/appointments"
                                                  onsubmit="return confirm('Bạn có chắc muốn huỷ lịch hẹn này?');">
                                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="action" value="cancel">
                                                <input type="hidden" name="appointmentId" value="${a.id}">
                                                <button type="submit" class="btn btn-outline-danger btn-sm"><i class="bi bi-x-circle me-1"></i>Huỷ</button>
                                            </form>
                                        </c:if>
                                        <%-- Đánh giá --%>
                                        <c:if test="${(st == 'success' || st == 'completed') && prescriptionPurchaseResolved[a.id] && !hasReviewed[a.id]}">
                                            <button type="button" class="btn btn-outline-primary btn-sm"
                                                    data-bs-toggle="modal" data-bs-target="#reviewModal"
                                                    data-appt-id="${a.id}"
                                                    data-doctor="<c:out value='${a.doctor.fullName}' default='Bác sĩ'/>">
                                                <i class="bi bi-star me-1"></i>Đánh giá
                                            </button>
                                        </c:if>
                                        <c:if test="${(st == 'success' || st == 'completed') && hasReviewed[a.id]}">
                                            <span class="text-success small"><i class="bi bi-check-circle-fill me-1"></i>Đã đánh giá</span>
                                        </c:if>
                                        <c:if test="${(st == 'success' || st == 'completed') && !prescriptionPurchaseResolved[a.id] && !hasReviewed[a.id]}">
                                            <button type="button" class="btn btn-outline-secondary btn-sm" disabled
                                                    title="Cần hoàn tất lựa chọn mua thuốc hoặc thanh toán hóa đơn thuốc trước">
                                                <i class="bi bi-lock me-1"></i>Chưa thể ĐG
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <div class="p-3 border-top d-flex justify-content-between align-items-center flex-wrap gap-2" style="font-size:.82rem;color:#64748b;">
                <span>Tổng: <strong style="color:#172033;">${fn:length(appointments)}</strong> lịch hẹn</span>
                <span><i class="bi bi-info-circle me-1"></i>Có thể huỷ/đổi trong 15 phút sau khi đặt, hoặc trước giờ khám tối thiểu 2 tiếng.</span>
            </div>
        </div>
    </c:otherwise>
</c:choose>

<%-- Review Modal --%>
<div class="modal fade" id="reviewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-star-fill text-warning me-2"></i>Đánh Giá Bác Sĩ</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/patient/review">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <div class="modal-body">
                    <input type="hidden" name="appointmentId" id="reviewApptId">
                    <p class="text-muted small mb-3">Bác sĩ: <strong id="reviewDoctorName"></strong></p>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Số sao <span class="text-danger">*</span></label>
                        <div class="d-flex gap-1 fs-3" id="starRating">
                            <c:forEach begin="1" end="5" var="star">
                                <label class="star-label" style="cursor:pointer;color:#ccc;" data-val="${star}">
                                    <i class="bi bi-star-fill"></i>
                                    <input type="radio" name="rating" value="${star}" style="display:none;" required>
                                </label>
                            </c:forEach>
                        </div>
                    </div>
                    <div class="mb-0">
                        <label class="form-label fw-semibold">Nhận xét (tuỳ chọn)</label>
                        <textarea name="comment" class="form-control" rows="3" placeholder="Chia sẻ trải nghiệm khám bệnh của bạn..."></textarea>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-outline-secondary rounded-pill" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-warning fw-semibold rounded-pill"><i class="bi bi-send me-1"></i>Gửi Đánh Giá</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
(function(){
    var modal = document.getElementById('reviewModal');
    if (modal) {
        modal.addEventListener('show.bs.modal', function(e) {
            var btn = e.relatedTarget;
            document.getElementById('reviewApptId').value = btn.dataset.apptId;
            document.getElementById('reviewDoctorName').textContent = 'BS. ' + btn.dataset.doctor;
        });
    }
    var labels = document.querySelectorAll('.star-label');
    var rating = 0;
    labels.forEach(function(l) {
        l.addEventListener('mouseenter', function() { highlight(parseInt(this.dataset.val)); });
        l.addEventListener('click', function() { rating = parseInt(this.dataset.val); this.querySelector('input').checked = true; highlight(rating); });
    });
    var container = document.getElementById('starRating');
    if (container) container.addEventListener('mouseleave', function() { highlight(rating); });
    function highlight(n) { labels.forEach(function(l, i) { l.style.color = i < n ? '#ffc107' : '#ccc'; }); }
})();
</script>

<%@ include file="../common/footer.jsp" %>
