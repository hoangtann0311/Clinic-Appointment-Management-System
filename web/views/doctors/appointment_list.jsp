<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Banner tiêu đề ────────────────────────────────────────────────── --%>
<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 bg-primary bg-gradient text-white rounded-4 clinical-page-hero">
            <div class="card-body p-4">
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div>
                        <h2 class="fw-bold mb-1">
                            <i class="bi bi-calendar2-week me-2"></i>Lịch Hẹn Của Tôi
                        </h2>
                        <p class="mb-0 opacity-75">
                            BS. ${doctorName} &mdash;
                            <c:choose>
                                <c:when test="${mode == 'single'}">
                                    Ngày ${viewDate}
                                </c:when>
                                <c:otherwise>
                                    ${fromDate} đến ${toDate}
                                </c:otherwise>
                            </c:choose>
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

<%-- ── Thống kê nhanh hôm nay ────────────────────────────────────────── --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-md-4">
        <div class="card border-0 rounded-4 h-100 text-center p-3 clinical-kpi clinical-kpi--success" style="background:#e8fdf0;">
            <div class="fs-1 fw-bold text-success">
                <c:out value="${empty todayCounts['confirmed'] ? 0 : todayCounts['confirmed']}"/>
            </div>
            <div class="small text-muted mt-1"><i class="bi bi-check-circle me-1"></i>Đã xác nhận</div>
        </div>
    </div>
    <div class="col-6 col-md-4">
        <div class="card border-0 rounded-4 h-100 text-center p-3 clinical-kpi" style="background:#f0eaff;">
            <div class="fs-1 fw-bold" style="color:#7c3aed;">
                <c:out value="${empty todayCounts['success'] ? 0 : todayCounts['success']}"/>
            </div>
            <div class="small text-muted mt-1"><i class="bi bi-clipboard2-check me-1"></i>Hoàn thành</div>
        </div>
    </div>
    <div class="col-6 col-md-4">
        <div class="card border-0 rounded-4 h-100 text-center p-3 clinical-kpi clinical-kpi--danger" style="background:#fdf0f0;">
            <div class="fs-1 fw-bold text-danger">
                <c:out value="${empty todayCounts['cancelled'] ? 0 : todayCounts['cancelled']}"/>
            </div>
            <div class="small text-muted mt-1"><i class="bi bi-x-circle me-1"></i>Đã huỷ</div>
        </div>
    </div>
</div>

<%-- ── Bộ lọc ───────────────────────────────────────────────────────── --%>
<div class="card rounded-4 border-0 shadow-sm mb-4">
    <div class="card-body p-4">
        <h6 class="fw-semibold mb-3"><i class="bi bi-funnel me-2 text-primary"></i>Bộ Lọc</h6>
        <form method="get" action="${pageContext.request.contextPath}/doctor/appointments"
              class="row g-3 align-items-end">
            <div class="col-md-3">
                <label class="form-label small fw-medium text-muted">Xem theo ngày</label>
                <input type="date" name="date" class="form-control rounded-3"
                       value="${mode == 'single' ? viewDate : ''}">
            </div>
            <div class="col-md-1 text-center d-none d-md-flex align-items-center justify-content-center pb-1">
                <span class="text-muted small">hoặc</span>
            </div>
            <div class="col-md-2">
                <label class="form-label small fw-medium text-muted">Từ ngày</label>
                <input type="date" name="from" class="form-control rounded-3"
                       value="${mode == 'range' ? fromDate : ''}">
            </div>
            <div class="col-md-2">
                <label class="form-label small fw-medium text-muted">Đến ngày</label>
                <input type="date" name="to" class="form-control rounded-3"
                       value="${mode == 'range' ? toDate : ''}">
            </div>
            <div class="col-md-2">
                <label class="form-label small fw-medium text-muted">Trạng thái</label>
                <select name="status" class="form-select rounded-3">
                    <option value="">Tất cả</option>
                    <option value="Confirmed"      ${fn:toLowerCase(statusFilter) == 'confirmed'      ? 'selected' : ''}>Đã xác nhận</option>
                    <option value="Waiting"        ${fn:toLowerCase(statusFilter) == 'waiting'        ? 'selected' : ''}>Chờ khám</option>
                    <option value="InProgress"     ${fn:toLowerCase(statusFilter) == 'inprogress'     ? 'selected' : ''}>Đang khám</option>
                    <option value="SUCCESS"        ${fn:toLowerCase(statusFilter) == 'success'        ? 'selected' : ''}>Hoàn thành</option>
                    <option value="Cancelled"      ${fn:toLowerCase(statusFilter) == 'cancelled'      ? 'selected' : ''}>Đã huỷ</option>
                    <option value="NoShow"         ${fn:toLowerCase(statusFilter) == 'noshow'         ? 'selected' : ''}>Vắng mặt</option>
                </select>
            </div>
            <div class="col-md-2 d-flex gap-2">
                <button type="submit" class="btn btn-primary rounded-3 flex-fill">
                    <i class="bi bi-search me-1"></i>Tìm
                </button>
                <a href="${pageContext.request.contextPath}/doctor/appointments"
                   class="btn btn-outline-secondary rounded-3" title="Đặt lại">
                    <i class="bi bi-arrow-counterclockwise"></i>
                </a>
            </div>
        </form>
    </div>
</div>

<%-- ── Bảng lịch hẹn ──────────────────────────────────────────────────── --%>
<div class="card rounded-4 border-0 shadow-sm">
    <div class="card-header bg-transparent border-0 p-4 pb-0 d-flex justify-content-between align-items-center">
        <h6 class="fw-semibold mb-0">
            <i class="bi bi-list-ul me-2 text-primary"></i>
            Danh sách lịch hẹn
            <span class="badge bg-primary rounded-pill ms-2">${fn:length(appointments)}</span>
        </h6>
    </div>
    <div class="card-body p-4 pt-3">
        <c:choose>
            <c:when test="${empty appointments}">
                <div class="text-center py-5">
                    <i class="bi bi-calendar-x text-muted" style="font-size:3rem;"></i>
                    <p class="text-muted mt-3 mb-0">Không có lịch hẹn nào trong khoảng thời gian này.</p>
                    <a href="${pageContext.request.contextPath}/doctor/appointments"
                       class="btn btn-sm btn-outline-primary mt-3 rounded-pill">
                        Xem hôm nay
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="border-0 ps-3">#</th>
                                <th class="border-0">Bệnh nhân</th>
                                <th class="border-0">Ngày hẹn</th>
                                <th class="border-0">Giờ</th>
                                <th class="border-0">Triệu chứng</th>
                                <th class="border-0">Nguồn đặt</th>
                                <th class="border-0">Trạng thái</th>
                                <th class="border-0">Hồ sơ</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="appt" items="${appointments}" varStatus="loop">
                                <tr>
                                    <td class="ps-3 text-muted small">${loop.index + 1}</td>

                                    <%-- Bệnh nhân --%>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle bg-primary bg-opacity-10 text-primary
                                                        d-flex align-items-center justify-content-center me-2 fw-bold"
                                                 style="width:36px;height:36px;min-width:36px;font-size:.85rem;">
                                                ${fn:toUpperCase(fn:substring(appt.patientName,0,1))}
                                            </div>
                                            <span class="fw-medium">${appt.patientName}</span>
                                        </div>
                                    </td>

                                    <%-- Ngày --%>
                                    <td class="text-nowrap">${appt.appointmentDate}</td>

                                    <%-- Giờ --%>
                                    <td class="text-nowrap">
                                        <c:if test="${not empty appt.timeSlot}">
                                            <span class="badge bg-light text-dark border">
                                                <i class="bi bi-clock me-1"></i>${appt.timeSlot}
                                            </span>
                                        </c:if>
                                    </td>

                                    <%-- Triệu chứng --%>
                                    <td style="max-width:200px;">
                                        <span class="text-truncate d-inline-block" style="max-width:180px;"
                                              title="${appt.symptoms}">
                                            ${not empty appt.symptoms ? appt.symptoms : '—'}
                                        </span>
                                    </td>

                                    <%-- Nguồn đặt --%>
                                    <td>
                                        <c:if test="${appt.emergency}">
                                            <span class="badge bg-warning-subtle text-warning-emphasis border rounded-pill mb-1"
                                                  title="${appt.priorityReason}">
                                                <i class="bi bi-arrow-up-circle-fill me-1"></i>Ưu tiên
                                            </span>
                                        </c:if>
                                        <c:choose>
                                            <c:when test="${appt.bookingSource == 'online'}">
                                                <span class="badge bg-info text-dark rounded-pill">
                                                    <i class="bi bi-globe me-1"></i>Trực tuyến
                                                </span>
                                            </c:when>
                                            <c:when test="${appt.bookingSource == 'direct'}">
                                                <span class="badge bg-secondary rounded-pill">
                                                    <i class="bi bi-building me-1"></i>Trực tiếp
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted small">${not empty appt.bookingSource ? appt.bookingSource : '—'}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- Bác sĩ lâm sàng chỉ được bắt đầu ca đã check-in; hoàn tất chỉ diễn ra khi lưu bệnh án chính thức. --%>
                                    <td>
                                        <c:choose>
                                            <c:when test="${fn:toLowerCase(appt.status) == 'waiting'}">
                                                <form method="post" action="${pageContext.request.contextPath}/doctor/appointments">
                                                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"/>
                                                    <input type="hidden" name="action" value="startConsultation"/>
                                                    <input type="hidden" name="appointmentId" value="${appt.id}"/>
                                                    <button type="submit" class="btn btn-sm btn-primary rounded-pill">Bắt đầu khám</button>
                                                </form>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(appt.status) == 'inprogress'}">
                                                <span class="badge bg-primary rounded-pill">Đang khám</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(appt.status) == 'success'}">
                                                <span class="badge bg-success rounded-pill">Hoàn thành</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(appt.status) == 'confirmed'}">
                                                <span class="badge bg-info text-dark rounded-pill">Chờ tiếp đón</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(appt.status) == 'cancelled'}">
                                                <span class="badge bg-secondary rounded-pill">Đã hủy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-dark border rounded-pill"><c:out value="${appt.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- Hồ sơ bệnh án --%>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${appt.id}"
                                           class="btn btn-sm btn-outline-success rounded-pill"
                                           title="Tạo / xem hồ sơ bệnh án">
                                            <i class="bi bi-journal-plus"></i>
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


<style>
/* ── Dropdown trạng thái ─────────────────────────── */
.status-dropdown {
    appearance: auto;
    -webkit-appearance: auto;
    border: 2px solid transparent;
    border-radius: 20px;
    padding: .3rem .9rem;
    font-size: .8rem;
    font-weight: 600;
    cursor: pointer;
    outline: none;
    min-width: 160px;
    transition: box-shadow .15s;
}
.status-dropdown:hover  { box-shadow: 0 0 0 3px rgba(0,0,0,.12); }
.status-dropdown:focus  { box-shadow: 0 0 0 3px rgba(66,153,225,.5); }

/* BA §7.1 canonical statuses */
.status-pending       { background: #fef3c7; color: #92400e; border-color: #fcd34d; }
.status-confirmed     { background: #d1fae5; color: #065f46; border-color: #6ee7b7; }
.status-waiting       { background: #e0f2fe; color: #075985; border-color: #7dd3fc; }
.status-inprogress    { background: #dbeafe; color: #1e40af; border-color: #93c5fd; }
.status-success       { background: #ede9fe; color: #5b21b6; border-color: #c4b5fd; }
.status-cancelled     { background: #fee2e2; color: #991b1b; border-color: #fca5a5; }
.status-noshow        { background: #f3f4f6; color: #374151; border-color: #9ca3af; }
</style>
<%@ include file="../common/footer.jsp" %>
