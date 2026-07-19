<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<div class="py-2">
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 patient-hero-card rounded-4">
                <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <div>
                        <h2 class="fw-bold mb-1"><i class="bi bi-images me-2"></i>Kết Quả Siêu Âm</h2>
                        <p class="mb-0 opacity-75">Chi tiết lần khám thai ngày ${visitInfo.appointmentDate}.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/patient/pregnancy" class="btn btn-light rounded-pill px-3">
                        <i class="bi bi-arrow-left me-1"></i>Về Theo Dõi Thai Kỳ
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <%-- Cột trái: thông tin lần khám --%>
        <div class="col-lg-4">
            <div class="card rounded-4 mb-4">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-3" style="color: var(--pt-pink-700);">
                        <i class="bi bi-clipboard2-pulse me-2" style="color: var(--pt-pink-500);"></i>Thông Tin Lần Khám
                    </h5>
                    <div class="mb-2 pb-2 border-bottom">
                        <small class="d-block text-muted">Ngày siêu âm</small>
                        <strong>${visitInfo.appointmentDate}</strong>
                    </div>
                    <div class="mb-2 pb-2 border-bottom">
                        <small class="d-block text-muted">Tuổi thai</small>
                        <strong>
                            <c:choose>
                                <c:when test="${not empty visitInfo.gestationalAgeWeeks}">${visitInfo.gestationalAgeWeeks} tuần ${visitInfo.gestationalAgeDays} ngày</c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </strong>
                    </div>
                    <div class="mb-2 pb-2 border-bottom">
                        <small class="d-block text-muted">Bác sĩ khám</small>
                        <strong>BS. ${visitInfo.doctorName}</strong>
                    </div>

                    <h6 class="fw-bold mt-3 mb-2" style="color: var(--pt-pink-700);">Chỉ số thai nhi / mẹ</h6>
                    <div class="row g-2 small">
                        <div class="col-6">
                            <div class="p-2 rounded-3" style="background: var(--pt-pink-50);">
                                Cân nặng mẹ<br>
                                <strong>
                                    <c:choose>
                                        <c:when test="${not empty visitInfo.weightKg}">${visitInfo.weightKg} kg</c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </strong>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="p-2 rounded-3" style="background: var(--pt-pink-50);">
                                Huyết áp<br>
                                <strong>${not empty visitInfo.bloodPressure ? visitInfo.bloodPressure : '—'}</strong>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="p-2 rounded-3" style="background: var(--pt-pink-50);">
                                Tim thai<br>
                                <strong>
                                    <c:choose>
                                        <c:when test="${not empty visitInfo.fetalHeartRate}">${visitInfo.fetalHeartRate} nhịp/p</c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </strong>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="p-2 rounded-3" style="background: var(--pt-pink-50);">
                                Bề cao TC<br>
                                <strong>
                                    <c:choose>
                                        <c:when test="${not empty visitInfo.fundalHeightCm}">${visitInfo.fundalHeightCm} cm</c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Cột phải: ảnh siêu âm + kết luận, theo từng chỉ định siêu âm --%>
        <div class="col-lg-8">
            <c:choose>
                <c:when test="${empty ultrasoundResults}">
                    <div class="card rounded-4 border-0 shadow-sm text-center py-5">
                        <div class="card-body">
                            <i class="bi bi-images fs-1 d-block mb-3 opacity-25"></i>
                            <h5 class="fw-bold mb-2">Chưa có kết quả siêu âm</h5>
                            <p class="text-muted mb-0">Lần khám này chưa có chỉ định siêu âm nào được bác sĩ xác nhận kết quả.</p>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="us" items="${ultrasoundResults}" varStatus="loop">
                        <div class="card rounded-4 mb-4">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-3" style="color: var(--pt-pink-700);">
                                    <i class="bi bi-file-earmark-medical me-2" style="color: var(--pt-pink-500);"></i>${us.serviceName}
                                </h5>

                                <h6 class="fw-bold small text-muted mb-2">🖼️ ẢNH SIÊU ÂM</h6>
                                <c:choose>
                                    <c:when test="${empty us.images}">
                                        <p class="text-muted small">Chưa có ảnh được tải lên cho chỉ định này.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="row g-2 mb-3">
                                            <c:forEach var="img" items="${us.images}" varStatus="imgLoop">
                                                <div class="col-6 col-md-4">
                                                    <a href="${img}" target="_blank">
                                                        <img src="${img}" alt="Ảnh siêu âm ${imgLoop.index + 1}"
                                                             class="img-fluid rounded-3 border w-100"
                                                             style="aspect-ratio: 1/1; object-fit: cover;">
                                                    </a>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                                <div class="p-3 rounded-3" style="background: var(--pt-pink-50, #fff6fb); border: 1px solid var(--pt-outline, #f0dae5);">
                                    <h6 class="fw-bold small mb-2" style="color: var(--pt-pink-700);">🩺 KẾT LUẬN CỦA BÁC SĨ</h6>
                                    <p class="mb-0 small">
                                        ${not empty us.doctorConclusion ? us.doctorConclusion : 'Chưa ghi nhận bất thường.'}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
