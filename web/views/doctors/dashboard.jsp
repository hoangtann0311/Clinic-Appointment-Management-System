<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Banner ──────────────────────────────────────────────────────────── --%>
<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 bg-primary bg-gradient text-white rounded-4">
            <div class="card-body p-4 p-md-5">
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div>
                        <h2 class="fw-bold mb-1">
                            <i class="bi bi-heart-pulse me-2"></i>Xin chào, BS. ${doctorName}!
                        </h2>
                        <p class="mb-0 opacity-75 fs-5">
                            Hôm nay: <strong>${today}</strong> &mdash; Chúc bạn một ngày làm việc hiệu quả.
                        </p>
                    </div>
                    <span class="badge bg-light text-primary fs-6 px-3 py-2 rounded-pill">
                        <i class="bi bi-person-badge me-1"></i>Bác Sĩ
                    </span>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- ── Thống kê nhanh hôm nay ─────────────────────────────────────────── --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
        <div class="card border-0 rounded-4 text-center p-3 h-100" style="background:#e8f4fd;">
            <div class="fs-1 fw-bold text-primary">
                <c:out value="${empty todayCounts['pending'] ? 0 : todayCounts['pending']}"/>
            </div>
            <div class="small text-muted mt-1"><i class="bi bi-hourglass-split me-1"></i>Chờ xác nhận</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card border-0 rounded-4 text-center p-3 h-100" style="background:#e8fdf0;">
            <div class="fs-1 fw-bold text-success">
                <c:out value="${empty todayCounts['confirmed'] ? 0 : todayCounts['confirmed']}"/>
            </div>
            <div class="small text-muted mt-1"><i class="bi bi-check-circle me-1"></i>Đã xác nhận</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card border-0 rounded-4 text-center p-3 h-100" style="background:#f0eaff;">
            <div class="fs-1 fw-bold" style="color:#7c3aed;">
                <c:out value="${empty todayCounts['success'] ? 0 : todayCounts['success']}"/>
            </div>
            <div class="small text-muted mt-1"><i class="bi bi-clipboard2-check me-1"></i>Hoàn thành</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="card border-0 rounded-4 text-center p-3 h-100" style="background:#fff8e1;">
            <div class="fs-1 fw-bold text-warning">${totalRecords}</div>
            <div class="small text-muted mt-1"><i class="bi bi-journal-medical me-1"></i>Tổng hồ sơ</div>
        </div>
    </div>
</div>

<div class="row g-4">
    <%-- ── Truy cập nhanh ────────────────────────────────────────────────── --%>
    <div class="col-lg-4">
        <div class="card border-0 rounded-4 h-100">
            <div class="card-body p-4">
                <h5 class="fw-semibold mb-3">
                    <i class="bi bi-grid-3x3-gap text-primary me-2"></i>Truy Cập Nhanh
                </h5>
                <div class="d-grid gap-2">
                    <a href="${pageContext.request.contextPath}/doctor/appointments"
                       class="btn btn-outline-primary rounded-3 text-start">
                        <i class="bi bi-calendar2-week me-2"></i>Lịch Hẹn Hôm Nay
                        <c:if test="${totalToday > 0}">
                            <span class="badge bg-primary float-end">${totalToday}</span>
                        </c:if>
                    </a>
                    <a href="${pageContext.request.contextPath}/doctor/medical-records"
                       class="btn btn-outline-success rounded-3 text-start">
                        <i class="bi bi-journal-medical me-2"></i>Quản Lý Hồ Sơ Bệnh Án
                    </a>
                    <a href="${pageContext.request.contextPath}/doctor/prescriptions-list"
                       class="btn btn-outline-danger rounded-3 text-start">
                        <i class="bi bi-prescription2 me-2"></i>Danh Sách Đơn Thuốc
                    </a>
                    <a href="${pageContext.request.contextPath}/doctor/patients"
                       class="btn btn-outline-info rounded-3 text-start">
                        <i class="bi bi-people me-2"></i>Danh Sách Bệnh Nhân
                    </a>
                </div>
            </div>
        </div>
    </div>

    <%-- ── Lịch hẹn hôm nay ──────────────────────────────────────────────── --%>
    <div class="col-lg-8">
        <div class="card border-0 rounded-4">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-semibold mb-0">
                        <i class="bi bi-calendar-day text-primary me-2"></i>Lịch Hẹn Hôm Nay
                    </h5>
                    <a href="${pageContext.request.contextPath}/doctor/appointments"
                       class="btn btn-sm btn-outline-primary rounded-pill">
                        Xem tất cả <i class="bi bi-arrow-right ms-1"></i>
                    </a>
                </div>

                <c:choose>
                    <c:when test="${empty todayAppointments}">
                        <div class="text-center py-4 text-muted">
                            <i class="bi bi-calendar-x fs-1 d-block mb-2 opacity-25"></i>
                            Không có lịch hẹn nào hôm nay.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Giờ</th>
                                        <th>Bệnh Nhân</th>
                                        <th>Triệu Chứng</th>
                                        <th>Trạng Thái</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="appt" items="${todayAppointments}" varStatus="st">
                                        <c:if test="${st.index < 6}">
                                        <tr>
                                            <td><span class="badge bg-light text-dark border">
                                                <i class="bi bi-clock me-1"></i>${appt.timeSlot}
                                            </span></td>
                                            <td class="fw-medium">${appt.patientName}</td>
                                            <td class="text-muted small">
                                                <c:choose>
                                                    <c:when test="${not empty appt.symptoms}">
                                                        ${fn:substring(appt.symptoms,0,40)}<c:if test="${fn:length(appt.symptoms)>40}">...</c:if>
                                                    </c:when>
                                                    <c:otherwise>—</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${fn:toLowerCase(appt.status) == 'confirmed'}">
                                                        <span class="badge bg-success rounded-pill">Xác nhận</span>
                                                    </c:when>
                                                    <c:when test="${fn:toLowerCase(appt.status) == 'pending'}">
                                                        <span class="badge bg-warning text-dark rounded-pill">Chờ xác nhận</span>
                                                    </c:when>
                                                    <c:when test="${fn:toLowerCase(appt.status) == 'waiting'}">
                                                        <span class="badge bg-info text-dark rounded-pill">Chờ khám</span>
                                                    </c:when>
                                                    <c:when test="${fn:toLowerCase(appt.status) == 'inprogress'}">
                                                        <span class="badge bg-primary rounded-pill">Đang khám</span>
                                                    </c:when>
                                                    <c:when test="${fn:toLowerCase(appt.status) == 'success'}">
                                                        <span class="badge bg-secondary rounded-pill">Hoàn thành</span>
                                                    </c:when>
                                                    <c:when test="${fn:toLowerCase(appt.status) == 'emergency_sos'}">
                                                        <span class="badge bg-danger rounded-pill"><i class="bi bi-exclamation-triangle-fill me-1"></i>Cấp cứu</span>
                                                    </c:when>
                                                    <c:when test="${fn:toLowerCase(appt.status) == 'cancelled'}">
                                                        <span class="badge bg-danger rounded-pill">Đã huỷ</span>
                                                    </c:when>
                                                    <c:when test="${fn:toLowerCase(appt.status) == 'noshow'}">
                                                        <span class="badge bg-dark rounded-pill">Vắng mặt</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-light text-dark rounded-pill border">${appt.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${appt.id}"
                                                   class="btn btn-sm btn-outline-primary rounded-pill">
                                                    <i class="bi bi-pencil-square me-1"></i>Khám
                                                </a>
                                            </td>
                                        </tr>
                                        </c:if>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <%-- ── Hồ sơ bệnh án gần nhất ────────────────────────────────────────── --%>
    <div class="col-12">
        <div class="card border-0 rounded-4">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-semibold mb-0">
                        <i class="bi bi-journal-medical text-success me-2"></i>Hồ Sơ Bệnh Án Gần Nhất
                    </h5>
                    <a href="${pageContext.request.contextPath}/doctor/medical-records"
                       class="btn btn-sm btn-outline-success rounded-pill">
                        Xem tất cả <i class="bi bi-arrow-right ms-1"></i>
                    </a>
                </div>

                <c:choose>
                    <c:when test="${empty recentRecords}">
                        <div class="text-center py-4 text-muted">
                            <i class="bi bi-journal-x fs-1 d-block mb-2 opacity-25"></i>
                            Chưa có hồ sơ bệnh án nào.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Bệnh Nhân</th>
                                        <th>Ngày Khám</th>
                                        <th>Chẩn Đoán</th>
                                        <th>Tuổi Thai</th>
                                        <th>Rủi Ro</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="rec" items="${recentRecords}">
                                        <tr>
                                            <td class="fw-medium">${rec.patientName}</td>
                                            <td class="text-muted small">${rec.appointmentDate}</td>
                                            <td>
                                                <c:out value="${fn:substring(rec.finalDiagnosis,0,50)}"/>
                                                <c:if test="${fn:length(rec.finalDiagnosis)>50}">...</c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty rec.gestationalAgeWeeks}">
                                                        ${rec.gestationalAgeDisplay}
                                                    </c:when>
                                                    <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${rec.hasRisk()}">
                                                        <span class="badge bg-danger rounded-pill">
                                                            <i class="bi bi-exclamation-triangle me-1"></i>Có rủi ro
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-success rounded-pill">Bình thường</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${rec.appointmentId}"
                                                   class="btn btn-sm btn-outline-secondary rounded-pill">
                                                    <i class="bi bi-eye me-1"></i>Xem
                                                </a>
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
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
