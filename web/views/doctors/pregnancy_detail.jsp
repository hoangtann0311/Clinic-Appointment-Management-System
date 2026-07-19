<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Banner ──────────────────────────────────────────────────────────── --%>
<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 bg-danger bg-gradient text-white rounded-4">
            <div class="card-body p-4">
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div>
                        <h2 class="fw-bold mb-1">
                            <i class="bi bi-heart-pulse-fill me-2"></i>Theo Dõi Thai Kỳ
                        </h2>
                        <p class="mb-0 opacity-75">
                            Bệnh nhân: <strong>${pregnancy.patientName}</strong>
                            &mdash; <strong>${fn:length(timeline)}</strong> lần khám đã ghi nhận
                        </p>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/doctor/patient-history?patientId=${pregnancy.patientId}"
                           class="btn btn-light btn-sm rounded-pill px-3">
                            <i class="bi bi-clock-history me-1"></i>Lịch sử khám
                        </a>
                        <a href="${pageContext.request.contextPath}/doctor/dashboard"
                           class="btn btn-outline-light btn-sm rounded-pill px-3">
                            <i class="bi bi-arrow-left me-1"></i>Dashboard
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<c:if test="${not empty errorMessage}">
    <div class="alert alert-danger rounded-3 mb-4">
        <i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}
    </div>
</c:if>

<div class="row g-4">
    <%-- ── Cột trái: thông tin thai kỳ + form cập nhật ─────────────────── --%>
    <div class="col-lg-4">
        <div class="card border-0 rounded-4 shadow-sm mb-4">
            <div class="card-body p-4">
                <h6 class="fw-bold mb-3">
                    <i class="bi bi-info-circle me-1 text-danger"></i>Thông tin thai kỳ
                </h6>

                <c:set var="gw" value="${pregnancy.currentGestationalWeeks}" />
                <c:if test="${gw >= 0}">
                    <div class="text-center p-3 rounded-3 mb-3" style="background:#fff0f3;">
                        <div class="display-6 fw-bold text-danger">${gw}</div>
                        <div class="text-muted small">tuần thai (ước tính từ ngày bắt đầu)</div>
                    </div>
                </c:if>

                <div class="info-item mb-2">
                    <span class="label">TRẠNG THÁI</span>
                    <span class="value">
                        <c:choose>
                            <c:when test="${pregnancy.pregnancyStatus == 'active'}">
                                <span class="badge bg-success rounded-pill">Đang theo dõi</span>
                            </c:when>
                            <c:when test="${pregnancy.pregnancyStatus == 'delivered'}">
                                <span class="badge bg-primary rounded-pill">Đã sinh</span>
                            </c:when>
                            <c:when test="${pregnancy.pregnancyStatus == 'miscarried'}">
                                <span class="badge bg-secondary rounded-pill">Sảy thai</span>
                            </c:when>
                            <c:when test="${pregnancy.pregnancyStatus == 'terminated'}">
                                <span class="badge bg-dark rounded-pill">Đình chỉ thai</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-light text-dark border rounded-pill">${pregnancy.pregnancyStatus}</span>
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <div class="info-item mb-2">
                    <span class="label">NGÀY BẮT ĐẦU (LMP)</span>
                    <span class="value">${pregnancy.startDate != null ? pregnancy.startDate : '—'}</span>
                </div>

                <div class="info-item mb-2">
                    <span class="label">NGÀY TẠO HỒ SƠ</span>
                    <span class="value text-muted small">
                        ${not empty pregnancy.createdAtFormatted ? pregnancy.createdAtFormatted : '—'}
                    </span>
                </div>

                <div class="info-item mb-2">
                    <span class="label">NGÀY DỰ SINH</span>
                    <span class="value">
                        ${pregnancy.estimatedDueDate != null ? pregnancy.estimatedDueDate : '—'}
                        <c:if test="${pregnancy.estimatedDueDate != null and pregnancy.pregnancyStatus == 'active'}">
                            <c:set var="daysLeft" value="${pregnancy.daysUntilDueDate}" />
                            <c:choose>
                                <c:when test="${daysLeft >= 0}">
                                    <span class="text-muted small">(còn ${daysLeft} ngày)</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-danger small">(quá dự sinh ${-daysLeft} ngày)</span>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                    </span>
                </div>

                <div class="info-item mb-2">
                    <span class="label">SỐ THAI</span>
                    <span class="value">${pregnancy.fetusCount != null ? pregnancy.fetusCount : '—'}</span>
                </div>

                <c:if test="${pregnancy.actualDeliveryDate != null}">
                    <div class="info-item mb-2">
                        <span class="label">NGÀY SINH THỰC TẾ</span>
                        <span class="value">${pregnancy.actualDeliveryDate}</span>
                    </div>
                </c:if>

                <c:if test="${not empty pregnancy.notes}">
                    <div class="info-item mb-2">
                        <span class="label">GHI CHÚ</span>
                        <span class="value" style="white-space:pre-wrap;">${pregnancy.notes}</span>
                    </div>
                </c:if>
            </div>
        </div>

        <%-- Form cập nhật --%>
        <div class="card border-0 rounded-4 shadow-sm">
            <div class="card-body p-4">
                <h6 class="fw-bold mb-3">
                    <i class="bi bi-pencil-square me-1 text-primary"></i>Cập nhật thai kỳ
                </h6>
                <form method="post" action="${pageContext.request.contextPath}/doctor/pregnancy">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="${pregnancy.id}">

                    <div class="mb-3">
                        <label class="form-label small fw-medium">Trạng thái</label>
                        <select name="pregnancyStatus" class="form-select form-select-sm rounded-3">
                            <option value="active"     ${pregnancy.pregnancyStatus == 'active' ? 'selected' : ''}>Đang theo dõi</option>
                            <option value="delivered"  ${pregnancy.pregnancyStatus == 'delivered' ? 'selected' : ''}>Đã sinh</option>
                            <option value="miscarried" ${pregnancy.pregnancyStatus == 'miscarried' ? 'selected' : ''}>Sảy thai</option>
                            <option value="terminated" ${pregnancy.pregnancyStatus == 'terminated' ? 'selected' : ''}>Đình chỉ thai</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-medium">Ngày bắt đầu (LMP)</label>
                        <input type="date" name="startDate" class="form-control form-control-sm rounded-3"
                               value="${not empty pregnancy.startDate ? pregnancy.startDate : suggestedStartDate}">
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-medium">Ngày dự sinh</label>
                        <input type="date" name="estimatedDueDate" class="form-control form-control-sm rounded-3"
                               value="${not empty pregnancy.estimatedDueDate ? pregnancy.estimatedDueDate : suggestedEstimatedDueDate}">
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-medium">Ngày sinh thực tế</label>
                        <input type="date" name="actualDeliveryDate" class="form-control form-control-sm rounded-3"
                               value="${pregnancy.actualDeliveryDate}">
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-medium">Số thai</label>
                        <input type="number" name="fetusCount" class="form-control form-control-sm rounded-3"
                               min="1" max="5" value="${pregnancy.fetusCount}">
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-medium">Ghi chú</label>
                        <textarea name="notes" class="form-control form-control-sm rounded-3" rows="3">${pregnancy.notes}</textarea>
                    </div>

                    <button type="submit" class="btn btn-primary btn-sm rounded-pill w-100">
                        <i class="bi bi-save me-1"></i>Lưu thay đổi
                    </button>
                </form>
            </div>
        </div>
    </div>

    <%-- ── Cột phải: timeline các lần khám ───────────────────────────────── --%>
    <div class="col-lg-8">
        <h6 class="fw-bold mb-3">
            <i class="bi bi-graph-up me-1 text-danger"></i>Diễn biến qua các lần khám
        </h6>

        <c:choose>
            <c:when test="${empty timeline}">
                <div class="card border-0 rounded-4">
                    <div class="card-body text-center py-5 text-muted">
                        <i class="bi bi-journal-x fs-1 d-block mb-3 opacity-25"></i>
                        <h6>Chưa có lần khám nào được gắn vào thai kỳ này.</h6>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="position-relative">
                    <div class="position-absolute top-0 start-0 ms-3 h-100 border-start border-2 border-danger opacity-25"
                         style="width:2px; margin-left:20px;"></div>

                    <c:forEach var="visit" items="${timeline}" varStatus="st">
                        <div class="d-flex gap-3 mb-4 position-relative">
                            <div class="flex-shrink-0" style="width:42px;">
                                <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold text-white bg-danger"
                                     style="width:42px;height:42px;font-size:0.85rem;">
                                    ${st.index + 1}
                                </div>
                            </div>

                            <div class="card border-0 rounded-4 flex-grow-1">
                                <div class="card-body p-4">
                                    <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-2">
                                        <div>
                                            <h6 class="fw-bold mb-0">
                                                <i class="bi bi-calendar-event text-danger me-1"></i>
                                                ${visit.appointmentDate}
                                            </h6>
                                            <small class="text-muted">BS. ${visit.doctorName}</small>
                                        </div>
                                        <c:if test="${visit.gestationalAgeWeeks != null}">
                                            <span class="badge bg-light text-dark border rounded-pill">
                                                Thai ${visit.gestationalAgeWeeks}w${visit.gestationalAgeDays != null ? visit.gestationalAgeDays : 0}d
                                            </span>
                                        </c:if>
                                    </div>

                                    <c:if test="${not empty visit.finalDiagnosis}">
                                        <div class="alert alert-light rounded-3 py-2 px-3 mb-2 small">
                                            <strong>Chẩn đoán:</strong> ${visit.finalDiagnosis}
                                        </div>
                                    </c:if>

                                    <div class="row g-2 small">
                                        <c:if test="${visit.weightKg != null}">
                                            <div class="col-6 col-md-3">
                                                <span class="text-muted d-block">Cân nặng</span>
                                                <strong>${visit.weightKg} kg</strong>
                                            </div>
                                        </c:if>
                                        <c:if test="${not empty visit.bloodPressure}">
                                            <div class="col-6 col-md-3">
                                                <span class="text-muted d-block">Huyết áp</span>
                                                <strong>${visit.bloodPressure}</strong>
                                            </div>
                                        </c:if>
                                        <c:if test="${visit.fundalHeightCm != null}">
                                            <div class="col-6 col-md-3">
                                                <span class="text-muted d-block">CCTC</span>
                                                <strong>${visit.fundalHeightCm} cm</strong>
                                            </div>
                                        </c:if>
                                        <c:if test="${visit.fetalHeartRate != null}">
                                            <div class="col-6 col-md-3">
                                                <span class="text-muted d-block">Tim thai</span>
                                                <strong>${visit.fetalHeartRate} bpm</strong>
                                            </div>
                                        </c:if>
                                    </div>

                                    <div class="d-flex gap-2 mt-3">
                                        <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${visit.appointmentId}"
                                           class="btn btn-sm btn-outline-primary rounded-pill">
                                            <i class="bi bi-eye me-1"></i>Xem hồ sơ
                                        </a>
                                        <a href="${pageContext.request.contextPath}/doctor/prescriptions?recordId=${visit.recordId}"
                                           class="btn btn-sm btn-outline-danger rounded-pill">
                                            <i class="bi bi-prescription2 me-1"></i>Đơn thuốc
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
.info-item { display:flex; flex-direction:column; margin-bottom:.5rem; }
.info-item .label { font-size:.7rem; text-transform:uppercase; color:#adb5bd; font-weight:600; letter-spacing:.05em; }
.info-item .value { font-size:.95rem; font-weight:500; color:#212529; }
</style>

<%@ include file="../common/footer.jsp" %>
