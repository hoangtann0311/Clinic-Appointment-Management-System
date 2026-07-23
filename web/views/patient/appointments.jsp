<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 patient-hero-card rounded-4">
            <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div>
                    <h2 class="fw-bold mb-1"><i class="bi bi-calendar2-week me-2"></i>Lịch Hẹn Của Tôi</h2>
                    <p class="mb-0 opacity-75">Danh sách các lịch khám đã đặt.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-light text-pink-theme fw-bold rounded-3">
                        <i class="bi bi-plus-circle me-1"></i>Đặt Lịch Mới
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<c:if test="${not empty bookingSuccess}">
    <div class="alert alert-success"><i class="bi bi-check-circle-fill me-2"></i>${bookingSuccess}</div>
</c:if>
<c:if test="${not empty bookingError}">
    <div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i>${bookingError}</div>
</c:if>

<c:choose>
    <c:when test="${empty appointments}">
        <div class="card">
            <div class="card-body text-center text-muted py-5">
                <i class="bi bi-calendar-x d-block mb-2" style="font-size:2.5rem;opacity:.3;"></i>
                Bạn chưa có lịch hẹn nào.
                <div class="mt-3">
                    <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-sm btn-primary">
                        Đặt lịch khám ngay
                    </a>
                </div>
            </div>
        </div>
    </c:when>
    <c:otherwise>
        <div class="card patient-appointments-card">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 patient-appointments-table">
                    <thead class="table-light">
                        <tr>
                            <th class="appointment-date">Ngày khám</th>
                            <th class="appointment-time">Giờ</th>
                            <th class="appointment-doctor">Bác sĩ lâm sàng</th>
                            <th class="appointment-service">Dịch vụ</th>
                            <th class="appointment-symptoms">Triệu chứng</th>
                            <th class="appointment-status-cell">Trạng thái</th>
                            <th class="appointment-actions text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${appointments}">
                            <tr>
                                <td class="appointment-date">${a.appointmentDate}</td>
                                <td class="appointment-time">${a.timeSlot}</td>
                                <td class="appointment-doctor">BS. ${a.doctor.fullName}</td>
                                <td class="appointment-service" title="${a.serviceName}"><span><c:out value="${not empty a.serviceName ? a.serviceName : 'Khám thai định kỳ'}"/></span></td>
                                <td class="appointment-symptoms" title="${a.symptoms}"><span><c:out value="${a.symptoms}"/></span></td>
                                <td class="appointment-status-cell">
                                    <div class="appointment-status-line">
                                    <c:set var="statusLower" value="${fn:toLowerCase(a.status)}" />
                                    <c:choose>
                                        <c:when test="${statusLower == 'confirmed'}">
                                            <span class="appointment-status-chip status-confirmed">Đã xác nhận</span>
                                        </c:when>
                                        <c:when test="${statusLower == 'pending'}">
                                            <span class="appointment-status-chip status-pending">Chờ xác nhận</span>
                                        </c:when>
                                        <c:when test="${statusLower == 'waiting'}">
                                            <span class="appointment-status-chip status-waiting">Chờ khám</span>
                                        </c:when>
                                        <c:when test="${statusLower == 'success' || statusLower == 'completed'}">
                                            <span class="appointment-status-chip status-success">Hoàn thành</span>
                                        </c:when>
                                        <c:when test="${statusLower == 'inprogress'}">
                                            <span class="appointment-status-chip status-waiting" style="background:#e0f2fe;color:#0369a1;">Đang khám</span>
                                        </c:when>
                                        <c:when test="${statusLower == 'cancelled'}">
                                            <span class="appointment-status-chip status-cancelled">Đã huỷ</span>
                                        </c:when>
                                        <c:when test="${statusLower == 'noshow'}">
                                            <span class="appointment-status-chip status-no-show">Vắng mặt</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="appointment-status-chip status-neutral">${a.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <%-- Chỉ hiển thị trạng thái thanh toán trước khám khi lịch hẹn ở giai đoạn chưa khám --%>
                                    <c:if test="${(statusLower == 'pending' || statusLower == 'confirmed') && a.preExamPaymentStatus == 'Paid'}">
                                        <span class="appointment-payment-chip payment-paid">Đã thanh toán</span>
                                    </c:if>
                                    <c:if test="${a.preExamPaymentStatus == 'PendingConfirmation'}">
                                        <span class="appointment-payment-chip payment-pending" title="Chờ nhân viên xác nhận thanh toán">Chờ thanh toán</span>
                                    </c:if>
                                    <c:if test="${a.preExamPaymentStatus == 'Unpaid' && (statusLower == 'pending' || statusLower == 'confirmed')}">
                                        <span class="appointment-payment-chip payment-unpaid">Chưa thanh toán</span>
                                    </c:if>
                                    </div>
                                </td>
                                <td class="appointment-actions text-end">
                                    <div class="d-flex flex-nowrap justify-content-end gap-1 flex-wrap" style="max-width: 320px;">
                                        <%-- Thanh toán trước khám (Pending/Confirmed và chưa thanh toán) --%>
                                        <c:if test="${a.preExamPaymentStatus == 'Unpaid' && (a.status == 'Pending' || a.status == 'Confirmed')}">
                                            <a href="${pageContext.request.contextPath}/patient/payment?appointmentId=${a.id}&type=PRE_EXAM"
                                               class="btn btn-sm btn-success fw-bold text-white"
                                               title="Thanh toán phí khám trước khi khám">
                                                <i class="bi bi-credit-card me-1"></i>Thanh toán
                                            </a>
                                        </c:if>

                                        <%-- Thanh toán phí dịch vụ phát sinh (nếu có hóa đơn post-exam chưa thanh toán) --%>
                                        <c:if test="${not empty postExamInvoices[a.id]}">
                                            <a href="${pageContext.request.contextPath}/patient/payment?appointmentId=${a.id}&type=POST_EXAM"
                                               class="btn btn-sm btn-outline-info fw-bold"
                                               title="Thanh toán chi phí dịch vụ/cận lâm sàng phát sinh">
                                                <i class="bi bi-receipt me-1"></i>Đóng phí DV
                                            </a>
                                        </c:if>

                                        <%-- Thanh toán đơn thuốc (nếu có hóa đơn đơn thuốc chưa thanh toán) --%>
                                        <c:if test="${not empty prescriptionInvoices[a.id]}">
                                            <a href="${pageContext.request.contextPath}/patient/payment?appointmentId=${a.id}&type=PRESCRIPTION"
                                               class="btn btn-sm btn-outline-success fw-bold"
                                               title="Thanh toán đơn thuốc bác sĩ đã kê">
                                                <i class="bi bi-capsule me-1"></i>Mua thuốc
                                            </a>
                                        </c:if>

                                        <c:if test="${not empty pendingPrescriptionChoices[a.id]}">
                                            <a href="${pageContext.request.contextPath}/patient/invoices#prescription-decisions"
                                               class="btn btn-sm btn-outline-success fw-bold"
                                               title="Chọn mua hoặc không mua thuốc tại phòng khám">
                                                <i class="bi bi-ui-checks me-1"></i>Chọn mua thuốc
                                            </a>
                                        </c:if>

                                        <%-- Đổi lịch (Pending/Confirmed) --%>
                                        <c:if test="${a.status == 'Pending' || a.status == 'Confirmed'}">
                                            <a href="${pageContext.request.contextPath}/patient/booking?rescheduleId=${a.id}"
                                               class="btn btn-sm btn-outline-warning"
                                               title="Đổi lịch hẹn">
                                                 <i class="bi bi-arrow-repeat me-1"></i>Đổi lịch
                                            </a>
                                        </c:if>

                                        <%-- Huỷ (Pending/Confirmed) --%>
                                        <c:if test="${a.status == 'Pending' || a.status == 'Confirmed'}">
                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/patient/appointments"
                                                  onsubmit="return confirm('Bạn có chắc muốn huỷ lịch hẹn này?');"
                                                  style="display:inline;">
                                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="action" value="cancel">
                                                <input type="hidden" name="appointmentId" value="${a.id}">
                                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Huỷ lịch hẹn">
                                                    <i class="bi bi-x-circle me-1"></i>Huỷ
                                                </button>
                                            </form>
                                        </c:if>

                                        <%-- Đánh giá bác sĩ (chỉ khi hoàn thành) --%>
                                        <c:if test="${(statusLower == 'success' || statusLower == 'completed') && prescriptionPurchaseResolved[a.id]}">
                                            <button type="button"
                                                    class="btn btn-sm btn-outline-primary"
                                                    data-bs-toggle="modal"
                                                    data-bs-target="#reviewModal"
                                                    data-appt-id="${a.id}"
                                                    data-doctor="${a.doctor.fullName}"
                                                    title="Đánh giá bác sĩ">
                                                <i class="bi bi-star me-1"></i>Đánh giá
                                            </button>
                                        </c:if>
                                        <c:if test="${(statusLower == 'success' || statusLower == 'completed') && !prescriptionPurchaseResolved[a.id]}">
                                            <button type="button" class="btn btn-sm btn-outline-secondary" disabled
                                                    title="Cần hoàn tất lựa chọn mua thuốc hoặc thanh toán hóa đơn thuốc trước">
                                                <i class="bi bi-lock me-1"></i>Chưa thể đánh giá
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <div class="p-3 border-top text-muted small">
                Tổng: <strong>${fn:length(appointments)}</strong> lịch hẹn.
                <span class="ms-3"><i class="bi bi-info-circle me-1"></i>Chỉ huỷ/đổi lịch được trước giờ khám tối thiểu 2 giờ.</span>
            </div>
        </div>
    </c:otherwise>
</c:choose>

<%-- Modal đánh giá bác sĩ --%>
<div class="modal fade" id="reviewModal" tabindex="-1" aria-labelledby="reviewModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="reviewModalLabel">
                    <i class="bi bi-star-fill text-warning me-2"></i>Đánh Giá Bác Sĩ
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/patient/review">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <div class="modal-body">
                    <input type="hidden" name="appointmentId" id="reviewApptId">
                    <p class="text-muted small mb-3">Bác sĩ: <strong id="reviewDoctorName"></strong></p>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Số sao đánh giá <span class="text-danger">*</span></label>
                        <div class="d-flex gap-2 fs-3">
                            <c:forEach begin="1" end="5" var="star">
                                <label class="star-label" style="cursor:pointer;color:#ccc;" data-val="${star}">
                                    <i class="bi bi-star-fill"></i>
                                    <input type="radio" name="rating" value="${star}" style="display:none;" required>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Nhận xét (tuỳ chọn)</label>
                        <textarea name="comment" class="form-control" rows="3"
                                  placeholder="Chia sẻ trải nghiệm khám bệnh của bạn..."></textarea>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-warning fw-semibold">
                        <i class="bi bi-send me-1"></i>Gửi Đánh Giá
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// Gán appointmentId vào modal đánh giá khi mở
document.getElementById('reviewModal') && document.getElementById('reviewModal').addEventListener('show.bs.modal', function (e) {
    var btn = e.relatedTarget;
    document.getElementById('reviewApptId').value = btn.dataset.apptId;
    document.getElementById('reviewDoctorName').textContent = 'BS. ' + btn.dataset.doctor;
});

// Star rating interaction
document.querySelectorAll('.star-label').forEach(function(label) {
    label.addEventListener('mouseover', function() {
        var val = parseInt(this.dataset.val);
        document.querySelectorAll('.star-label').forEach(function(l, i) {
            l.style.color = (i < val) ? '#ffc107' : '#ccc';
        });
    });
    label.addEventListener('click', function() {
        var val = parseInt(this.dataset.val);
        this.querySelector('input').checked = true;
        document.querySelectorAll('.star-label').forEach(function(l, i) {
            l.style.color = (i < val) ? '#ffc107' : '#ccc';
        });
    });
});
document.querySelector('.star-label') && document.querySelector('#reviewModal .modal-body').addEventListener('mouseleave', function() {
    var checked = document.querySelector('input[name="rating"]:checked');
    var val = checked ? parseInt(checked.value) : 0;
    document.querySelectorAll('.star-label').forEach(function(l, i) {
        l.style.color = (i < val) ? '#ffc107' : '#ccc';
    });
});
</script>

<%@ include file="../common/footer.jsp" %>
