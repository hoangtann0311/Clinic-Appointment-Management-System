<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<div class="row mb-4 align-items-center">
    <div class="col">
        <h2 class="fw-bold"><i class="bi bi-calendar2-week text-primary me-2"></i>Lịch Hẹn Của Tôi</h2>
        <p class="text-muted mb-0">Danh sách các lịch khám đã đặt.</p>
    </div>
    <div class="col-auto">
        <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-primary">
            <i class="bi bi-plus-circle me-1"></i>Đặt Lịch Mới
        </a>
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
        <div class="card">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Ngày khám</th>
                            <th>Giờ</th>
                            <th>Bác sĩ</th>
                            <th>Dịch vụ</th>
                            <th>Triệu chứng</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${appointments}">
                            <tr>
                                <td>${a.appointmentDate}</td>
                                <td>${a.timeSlot}</td>
                                <td>BS. ${a.doctor.fullName}</td>
                                <td>${a.serviceName}</td>
                                <td style="max-width:220px;" class="text-truncate">${a.symptoms}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.status == 'Confirmed'}">
                                            <span class="badge bg-success">Đã xác nhận</span>
                                        </c:when>
                                        <c:when test="${a.status == 'Pending'}">
                                            <span class="badge bg-warning text-dark">Chờ xác nhận</span>
                                        </c:when>
                                        <c:when test="${a.status == 'Waiting'}">
                                            <span class="badge bg-info text-dark">Đang chờ khám</span>
                                        </c:when>
                                        <c:when test="${a.status == 'Emergency_SOS'}">
                                            <span class="badge bg-danger">Khẩn cấp (SOS)</span>
                                        </c:when>
                                        <c:when test="${a.status == 'SUCCESS'}">
                                            <span class="badge bg-primary">Đã hoàn thành</span>
                                        </c:when>
                                        <c:when test="${a.status == 'Cancelled'}">
                                            <span class="badge bg-secondary">Đã huỷ</span>
                                        </c:when>
                                        <c:when test="${a.status == 'NoShow'}">
                                            <span class="badge bg-dark">Không đến khám</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-light text-dark">${a.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <div class="d-flex flex-wrap justify-content-end gap-1">
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
                                                <input type="hidden" name="action" value="cancel">
                                                <input type="hidden" name="appointmentId" value="${a.id}">
                                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Huỷ lịch hẹn">
                                                    <i class="bi bi-x-circle me-1"></i>Huỷ
                                                </button>
                                            </form>
                                        </c:if>

                                        <%-- SOS (chỉ khi Confirmed & chưa là Emergency) --%>
                                        <c:if test="${a.status == 'Confirmed' || a.status == 'Waiting'}">
                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/patient/appointments"
                                                  onsubmit="return confirm('⚠️ Kích hoạt SOS sẽ đánh dấu lịch hẹn này là KHẨN CẤP và ưu tiên điều phối bác sĩ ngay lập tức. Xác nhận?');"
                                                  style="display:inline;">
                                                <input type="hidden" name="action" value="sos">
                                                <input type="hidden" name="appointmentId" value="${a.id}">
                                                <button type="submit" class="btn btn-sm btn-danger" title="Báo khẩn cấp SOS">
                                                    <i class="bi bi-exclamation-triangle-fill me-1"></i>SOS
                                                </button>
                                            </form>
                                        </c:if>

                                        <%-- Thanh toán (Confirmed hoặc Waiting, chưa thanh toán) --%>
                                        <c:if test="${a.status == 'Confirmed' || a.status == 'Waiting' || a.status == 'Pending'}">
                                            <a href="${pageContext.request.contextPath}/patient/payment?appointmentId=${a.id}"
                                               class="btn btn-sm btn-outline-success"
                                               title="Thanh toán hóa đơn">
                                                <i class="bi bi-credit-card me-1"></i>Thanh toán
                                            </a>
                                        </c:if>

                                        <%-- Đánh giá bác sĩ (chỉ khi hoàn thành) --%>
                                        <c:if test="${a.status == 'SUCCESS'}">
                                            <button type="button"
                                                    class="btn btn-sm btn-outline-primary"
                                                    data-bs-toggle="modal"
                                                    data-bs-target="#reviewModal"
                                                    data-appt-id="${a.id}"
                                                    data-doctor="${a.doctorName}"
                                                    title="Đánh giá bác sĩ">
                                                <i class="bi bi-star me-1"></i>Đánh giá
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
// Gán appointmentId vào modal khi mở
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
