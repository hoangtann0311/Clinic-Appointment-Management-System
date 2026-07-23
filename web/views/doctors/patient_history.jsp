<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Banner ──────────────────────────────────────────────────────────── --%>
<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 bg-info bg-gradient text-white rounded-4">
            <div class="card-body p-4">
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div>
                        <h2 class="fw-bold mb-1">
                            <i class="bi bi-clock-history me-2"></i>Lịch Sử Khám Bệnh
                        </h2>
                        <p class="mb-0 opacity-75">
                            Bệnh nhân: <strong>${patientName}</strong>
                            &mdash; Tổng <strong>${fn:length(records)}</strong> lần khám
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/doctor/dashboard"
                       class="btn btn-light btn-sm rounded-pill px-3">
                        <i class="bi bi-arrow-left me-1"></i>Tổng Quan
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>


<c:choose>
    <c:when test="${empty records}">
        <div class="card border-0 rounded-4">
            <div class="card-body text-center py-5 text-muted">
                <i class="bi bi-journal-x fs-1 d-block mb-3 opacity-25"></i>
                <h5>Chưa có hồ sơ bệnh án nào cho bệnh nhân này.</h5>
            </div>
        </div>
    </c:when>
    <c:otherwise>
        <%-- ── Timeline lịch sử ──────────────────────────────────────────── --%>
        <div class="position-relative">
            <%-- Đường line dọc --%>
            <div class="position-absolute top-0 start-0 ms-3 h-100 border-start border-2 border-primary opacity-25"
                 style="width:2px; margin-left:20px;"></div>

            <c:forEach var="rec" items="${records}" varStatus="st">
                <div class="d-flex gap-3 mb-4 position-relative">
                    <%-- Dot timeline --%>
                    <div class="flex-shrink-0" style="width:42px;">
                        <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold text-white
                            ${rec.hasRisk() ? 'bg-danger' : 'bg-primary'}"
                             style="width:42px;height:42px;font-size:0.85rem;">
                            ${st.index + 1}
                        </div>
                    </div>

                    <%-- Card hồ sơ --%>
                    <div class="card border-0 rounded-4 flex-grow-1 ${rec.hasRisk() ? 'border-danger border' : ''}">
                        <div class="card-body p-4">
                            <%-- Header --%>
                            <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3">
                                <div>
                                    <h6 class="fw-bold mb-0">
                                        <i class="bi bi-calendar-event text-primary me-1"></i>
                                        ${rec.appointmentDate}
                                        <c:if test="${not empty rec.timeSlot}">
                                            &mdash; ${rec.timeSlot}
                                        </c:if>
                                    </h6>
                                    <small class="text-muted">
                                        Tạo lúc: ${rec.createdAt}
                                    </small>
                                </div>
                                <div class="d-flex gap-2 flex-wrap">
                                    <c:if test="${rec.hasRisk()}">
                                        <span class="badge bg-danger rounded-pill">
                                            <i class="bi bi-exclamation-triangle me-1"></i>Có rủi ro
                                        </span>
                                    </c:if>
                                    <c:if test="${not empty rec.gestationalAgeWeeks}">
                                        <span class="badge bg-light text-dark border rounded-pill">
                                            <i class="bi bi-clock me-1"></i>${rec.gestationalAgeDisplay}
                                        </span>
                                    </c:if>
                                </div>
                            </div>

                            <%-- Chẩn đoán --%>
                            <div class="alert alert-light rounded-3 py-2 px-3 mb-3">
                                <strong><i class="bi bi-stethoscope me-1 text-success"></i>Chẩn đoán:</strong>
                                ${rec.finalDiagnosis}
                            </div>

                            <div class="row g-3">
                                <%-- Sinh hiệu --%>
                                <c:if test="${not empty rec.weightKg or not empty rec.bloodPressure
                                              or not empty rec.pulseBpm or not empty rec.temperatureC}">
                                    <div class="col-md-6">
                                        <div class="p-3 rounded-3 border h-100" style="background:#f8fafc;">
                                            <div class="fw-semibold small text-muted mb-2">
                                                <i class="bi bi-activity me-1 text-primary"></i>SINH HIỆU MẸ
                                            </div>
                                            <div class="row g-2 small">
                                                <c:if test="${not empty rec.weightKg}">
                                                    <div class="col-6">
                                                        <span class="text-muted">Cân nặng:</span>
                                                        <strong>${rec.weightKg} kg</strong>
                                                    </div>
                                                </c:if>
                                                <c:if test="${not empty rec.bloodPressure}">
                                                    <div class="col-6">
                                                        <span class="text-muted">Huyết áp:</span>
                                                        <strong>${rec.bloodPressure} mmHg</strong>
                                                    </div>
                                                </c:if>
                                                <c:if test="${not empty rec.pulseBpm}">
                                                    <div class="col-6">
                                                        <span class="text-muted">Mạch:</span>
                                                        <strong>${rec.pulseBpm} bpm</strong>
                                                    </div>
                                                </c:if>
                                                <c:if test="${not empty rec.temperatureC}">
                                                    <div class="col-6">
                                                        <span class="text-muted">Nhiệt độ:</span>
                                                        <strong>${rec.temperatureC}°C</strong>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>

                                <%-- Thai nhi --%>
                                <c:if test="${not empty rec.fetalHeartRate or not empty rec.fundalHeightCm
                                              or not empty rec.fetalPresentation}">
                                    <div class="col-md-6">
                                        <div class="p-3 rounded-3 border h-100" style="background:#f8fafc;">
                                            <div class="fw-semibold small text-muted mb-2">
                                                <i class="bi bi-heart-pulse me-1 text-danger"></i>THAI NHI
                                            </div>
                                            <div class="row g-2 small">
                                                <c:if test="${not empty rec.fetalHeartRate}">
                                                    <div class="col-6">
                                                        <span class="text-muted">Tim thai:</span>
                                                        <strong>${rec.fetalHeartRate} bpm</strong>
                                                    </div>
                                                </c:if>
                                                <c:if test="${not empty rec.fundalHeightCm}">
                                                    <div class="col-6">
                                                        <span class="text-muted">CCTC:</span>
                                                        <strong>${rec.fundalHeightCm} cm</strong>
                                                    </div>
                                                </c:if>
                                                <c:if test="${not empty rec.fetalPresentation}">
                                                    <div class="col-6">
                                                        <span class="text-muted">Ngôi thai:</span>
                                                        <strong>${rec.fetalPresentation}</strong>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>

                                <%-- Kế hoạch điều trị --%>
                                <c:if test="${not empty rec.treatmentPlan}">
                                    <div class="col-12">
                                        <div class="small">
                                            <span class="text-muted fw-semibold">
                                                <i class="bi bi-clipboard2-pulse me-1"></i>Kế hoạch:
                                            </span>
                                            ${rec.treatmentPlan}
                                        </div>
                                    </div>
                                </c:if>

                                <%-- Tái khám --%>
                                <c:if test="${not empty rec.nextAppointmentDate}">
                                    <div class="col-12">
                                        <span class="badge bg-primary rounded-pill">
                                            <i class="bi bi-calendar-check me-1"></i>
                                            Tái khám: ${rec.nextAppointmentDate}
                                        </span>
                                    </div>
                                </c:if>
                            </div>

                            <%-- Một lối vào duy nhất để xem hồ sơ đã hoàn tất. --%>
                            <div class="d-flex gap-2 mt-3">
                                <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${rec.appointmentId}"
                                   class="btn btn-sm btn-outline-primary rounded-pill">
                                    <i class="bi bi-eye me-1"></i>Xem Hồ Sơ
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>

<%@ include file="../common/footer.jsp" %>
