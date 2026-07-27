<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<style>
.doc-kpi { transition: transform .15s; }
.doc-kpi:hover { transform: translateY(-2px); }
.pulse-border { animation: pulseBorder 2s infinite; }
@keyframes pulseBorder { 0%,100% { box-shadow: 0 0 0 0 rgba(220,38,38,0.4); } 50% { box-shadow: 0 0 0 8px rgba(220,38,38,0); } }
.pulse-alert { animation: pulseBg 2s infinite; }
@keyframes pulseBg { 0%,100% { background-color: #fef2f2; } 50% { background-color: #fee2e2; } }
.table-danger.bg-opacity-10 { --bs-table-bg: rgba(248,215,218,0.3); }
</style>

<%-- Banner --%>
<div class="mb-4">
    <div class="card border-0 bg-primary bg-gradient text-white rounded-4">
        <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div>
                <h2 class="fw-bold mb-1"><i class="bi bi-heart-pulse me-2"></i>Xin chào, BS. ${doctorName}</h2>
                <p class="mb-0 opacity-75">Hôm nay: ${today} — Chúc một ngày làm việc hiệu quả.</p>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-light btn-sm rounded-pill"><i class="bi bi-calendar2-week me-1"></i>Lịch hẹn</a>
                <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-light btn-sm rounded-pill"><i class="bi bi-journal-medical me-1"></i>Hồ sơ bệnh án</a>
                <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-light btn-sm rounded-pill"><i class="bi bi-journal-medical me-1"></i>Hồ sơ bệnh án</a>
            </div>
        </div>
    </div>
</div>

<%-- KPI: 4 số bác sĩ thực sự cần --%>
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card border-0 rounded-4 text-center p-3 doc-kpi h-100" style="background:#e0f2fe;border-left:4px solid #0ea5e9;">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Chờ khám</div>
            <div class="fs-2 fw-bold" style="color:#0369a1;">${empty todayCounts['waiting'] ? 0 : todayCounts['waiting']}</div>
            <div class="small text-muted">bệnh nhân đã check-in</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 rounded-4 text-center p-3 doc-kpi h-100" style="background:#fef3c7;border-left:4px solid #d97706;">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Đang khám</div>
            <div class="fs-2 fw-bold" style="color:#92400e;">${empty todayCounts['inprogress'] ? 0 : todayCounts['inprogress']}</div>
            <div class="small text-muted">ca đang xử lý</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 rounded-4 text-center p-3 doc-kpi h-100" style="background:#dcfce7;border-left:4px solid #15803d;">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Hoàn thành</div>
            <div class="fs-2 fw-bold" style="color:#15803d;">${empty todayCounts['success'] ? 0 : todayCounts['success']}</div>
            <div class="small text-muted">ca đã xong hôm nay</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-0 rounded-4 text-center p-3 doc-kpi h-100" style="<c:choose><c:when test='${priorityCount > 0}'>background:#fefce8;border-left:4px solid #eab308;</c:when><c:otherwise>background:#f8fafc;border-left:4px solid #94a3b8;</c:otherwise></c:choose>">
            <div class="text-muted small text-uppercase fw-semibold mb-1">
                <i class="bi bi-star-fill text-warning me-1"></i>Ưu tiên đang chờ
            </div>
            <div class="fs-2 fw-bold" style="color:#ca8a04;">${priorityCount}</div>
            <div class="small text-muted">ca ưu tiên tiếp nhận</div>
        </div>
    </div>
</div>

<%-- Thông báo ca ưu tiên đang chờ --%>
<c:if test="${priorityCount > 0}">
<div class="alert alert-warning border-0 rounded-4 d-flex align-items-center gap-3 mb-4 shadow-sm" role="alert">
    <i class="bi bi-info-circle-fill fs-3 text-warning-emphasis"></i>
    <div class="flex-grow-1">
        <strong>Có ${priorityCount} ca ưu tiên đang chờ khám!</strong>
        <div class="small mt-1">Thông tin ưu tiên được tiếp nhận từ bộ phận Lễ tân. Xem chi tiết trong danh sách bên dưới.</div>
    </div>
    <a href="#prioritySection" class="btn btn-warning text-dark btn-sm rounded-pill px-3">Xem danh sách <i class="bi bi-arrow-down ms-1"></i></a>
</div>
</c:if>

<%-- Lịch hẹn của bệnh nhân --%>
<div class="card rounded-4 border-0 shadow-sm">
    <div class="card-header bg-transparent border-0 p-3 d-flex justify-content-between align-items-center">
        <h6 class="fw-semibold mb-0"><i class="bi bi-calendar-check me-2 text-primary"></i>Lịch hẹn của bệnh nhân <span class="badge bg-primary rounded-pill ms-1">${totalToday}</span></h6>
        <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-sm btn-outline-primary rounded-pill">Xem tất cả <i class="bi bi-arrow-right ms-1"></i></a>
    </div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty todayAppointments}">
                <div class="text-center py-5 text-muted"><i class="bi bi-calendar-x d-block mb-2" style="font-size:2rem;opacity:.3;"></i>Hôm nay chưa có lịch hẹn nào.</div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" style="min-width: 900px; width: 100%;">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-3 py-3" style="width:7%; min-width: 60px;">STT</th>
                                <th class="py-3" style="width:30%; min-width: 240px;">Bệnh nhân</th>
                                <th class="py-3" style="width:26%; min-width: 210px;">Khung giờ &amp; Thời gian đặt</th>
                                <th class="py-3" style="width:16%; min-width: 130px;">Trạng thái</th>
                                <th class="pe-3 text-end py-3" style="width:21%; min-width: 160px;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="a" items="${todayAppointments}" varStatus="loop">
                        <c:set var="st" value="${fn:toLowerCase(a.status)}"/>
                        <tr class="${a.priority ? 'table-warning bg-opacity-10' : ''}" id="${a.priority ? 'prioritySection' : ''}">
                            <td class="ps-3 fw-semibold text-muted py-3" style="font-size:.85rem;">
                                ${not empty a.queueNumber ? a.queueNumber : loop.index + 1}
                            </td>
                            <td class="py-3">
                                <div class="d-flex align-items-center gap-2 flex-wrap mb-1">
                                    <span class="fw-bold text-dark" style="font-size:.92rem; line-height: 1.3;">${a.patientName}</span>
                                    <c:choose>
                                        <c:when test="${fn:toLowerCase(a.bookingSource) == 'staff' || fn:toLowerCase(a.bookingSource) == 'reception' || fn:toLowerCase(a.bookingSource) == 'counter'}">
                                            <span class="badge rounded-pill px-2 py-1" style="background:#e0e7ff; color:#3730a3; border:1px solid #c7d2fe; font-size:.68rem; font-weight:700;" title="Bệnh nhân đăng ký tiếp đón trực tiếp tại quầy">
                                                <i class="bi bi-person-workspace me-1"></i>Tại quầy
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge rounded-pill px-2 py-1" style="background:#e0f2fe; color:#0369a1; border:1px solid #bae6fd; font-size:.68rem; font-weight:700;" title="Bệnh nhân đặt lịch trực tuyến qua Website/App">
                                                <i class="bi bi-globe me-1"></i>Đặt Online
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <c:if test="${a.priority}">
                                    <div class="d-inline-flex flex-wrap gap-1 align-items-center mt-1">
                                        <span class="badge bg-warning text-dark rounded-pill px-2 py-1" style="font-size:.65rem;">
                                            <i class="bi bi-star-fill me-1"></i>Ưu tiên tiếp nhận
                                        </span>
                                        <c:if test="${not empty a.priorityReason}">
                                            <div class="small text-muted" style="font-size:.72rem; line-height: 1.2;" title="${a.priorityReason}">
                                                Lý do: <c:out value="${fn:substring(a.priorityReason, 0, 40)}${fn:length(a.priorityReason) > 40 ? '…' : ''}"/>
                                            </div>
                                        </c:if>
                                    </div>
                                </c:if>
                            </td>
                            <td class="py-3">
                                <div class="fw-semibold text-primary mb-1" style="font-size:.86rem; line-height: 1.3;">
                                    <i class="bi bi-clock-history me-1"></i>${not empty a.shiftLabel ? a.shiftLabel : (not empty a.timeSlot ? a.timeSlot : '—')}
                                </div>
                                <div class="text-muted" style="font-size:.76rem; line-height: 1.3;">
                                    <i class="bi bi-calendar2-check me-1"></i>Đặt lúc: 
                                    <c:choose>
                                        <c:when test="${not empty a.bookedAtDisplay}">${a.bookedAtDisplay}</c:when>
                                        <c:when test="${not empty a.createdAtText}">${a.createdAtText}</c:when>
                                        <c:otherwise>Hôm nay</c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td class="py-3">
                                <c:choose>
                                    <c:when test="${st == 'pending'}"><span class="badge bg-warning text-dark rounded-pill px-2.5 py-1.5" style="font-size:.78rem;">Chờ xác nhận</span></c:when>
                                    <c:when test="${st == 'confirmed'}"><span class="badge bg-success rounded-pill px-2.5 py-1.5" style="font-size:.78rem;">Đã xác nhận</span></c:when>
                                    <c:when test="${st == 'waiting'}"><span class="badge bg-primary rounded-pill px-2.5 py-1.5" style="font-size:.78rem;">Chờ khám</span></c:when>
                                    <c:when test="${st == 'inprogress'}"><span class="badge bg-info text-dark rounded-pill px-2.5 py-1.5" style="font-size:.78rem;">Đang khám</span></c:when>
                                    <c:when test="${st == 'success' || st == 'completed'}"><span class="badge bg-success rounded-pill px-2.5 py-1.5" style="font-size:.78rem;">Hoàn thành</span></c:when>
                                    <c:when test="${st == 'cancelled'}"><span class="badge bg-secondary rounded-pill px-2.5 py-1.5" style="font-size:.78rem;">Đã huỷ</span></c:when>
                                    <c:when test="${st == 'noshow'}"><span class="badge bg-dark rounded-pill px-2.5 py-1.5" style="font-size:.78rem;">Vắng mặt</span></c:when>
                                    <c:otherwise><span class="badge bg-light text-dark rounded-pill px-2.5 py-1.5" style="font-size:.78rem;">${a.status}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="pe-3 text-end py-3" style="white-space:nowrap;">
                                <c:if test="${st == 'waiting'}">
                                    <form method="post" action="${pageContext.request.contextPath}/doctor/appointments" style="margin:0;display:inline;">
                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="startConsultation">
                                        <input type="hidden" name="appointmentId" value="${a.id}">
                                        <button type="submit" class="btn btn-primary btn-sm rounded-pill shadow-sm" style="font-size:.8rem;padding:.38rem .95rem;">
                                            <i class="bi bi-play-fill me-1"></i>Bắt đầu khám
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${st == 'inprogress' || st == 'success' || st == 'completed'}">
                                    <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${a.id}" class="btn btn-sm btn-outline-success rounded-pill shadow-sm" style="font-size:.8rem;padding:.38rem .95rem;">
                                        <i class="bi bi-journal-plus me-1"></i>Hồ sơ bệnh án
                                    </a>
                                </c:if>
                                <c:if test="${st == 'confirmed'}">
                                    <span class="text-muted small"><i class="bi bi-clock me-1"></i>Chờ check-in</span>
                                </c:if>
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
