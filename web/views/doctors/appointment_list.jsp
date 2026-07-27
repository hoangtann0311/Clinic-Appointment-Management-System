<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>
<style>
.table-danger.bg-opacity-10 { --bs-table-bg: rgba(248,215,218,0.3); }
.doc-table { table-layout: fixed; width: 100%; }
.doc-table th { font-size: .78rem; font-weight: 700; text-transform: uppercase; letter-spacing: .03em; color: #64748b; padding: .7rem .5rem; background: #fff; border-bottom: 2px solid #e2e8f0; white-space: nowrap; }
.doc-table td { padding: .65rem .5rem; font-size: .86rem; vertical-align: middle; }
.doc-table tbody tr { border-bottom: 1px solid #f1f5f9; transition: background .1s; }
.doc-table tbody tr:hover { background: #fafbfc; }
.doc-table tbody tr:last-child { border-bottom: 0; }
.col-idx { width: 3%; }
.col-patient { width: 16%; }
.col-date { width: 10%; }
.col-time { width: 9%; }
.col-booked { width: 10%; }
.col-symptoms { width: 16%; }
.col-source { width: 9%; }
.col-status { width: 10%; }
.col-stage { width: 12%; }
.col-action { width: 18%; }
.st-chip { display: inline-block; padding: .2rem .55rem; border-radius: 2rem; font-size: .75rem; font-weight: 600; }
.st-confirmed { background: #d1fae5; color: #065f46; }
.st-waiting { background: #e0f2fe; color: #075985; }
.st-inprogress { background: #dbeafe; color: #1e40af; }
.st-success { background: #ede9fe; color: #5b21b6; }
.st-cancelled { background: #fee2e2; color: #991b1b; }
.st-noshow { background: #f3f4f6; color: #374151; }
</style>

<div class="mb-4">
    <div class="card border-0 bg-primary bg-gradient text-white rounded-4">
        <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div><h2 class="fw-bold mb-1"><i class="bi bi-calendar2-week me-2"></i>Lịch hẹn của bệnh nhân</h2>
                <p class="mb-0 opacity-75">BS. ${doctorName} — <c:choose><c:when test="${mode == 'single'}">Ngày ${viewDate}</c:when><c:otherwise>${fromDate} → ${toDate}</c:otherwise></c:choose></p>
            </div>
            <a href="${pageContext.request.contextPath}/doctor/dashboard" class="btn btn-light btn-sm rounded-pill px-3"><i class="bi bi-arrow-left me-1"></i>Tổng Quan</a>
        </div>
    </div>
</div>

<%-- KPI cards --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-md-3"><div class="card border-0 rounded-4 text-center p-3" style="background:#e8fdf0;"><div class="fs-3 fw-bold text-success">${empty todayCounts['confirmed'] ? 0 : todayCounts['confirmed']}</div><div class="small text-muted mt-1">Đã xác nhận</div></div></div>
    <div class="col-6 col-md-3"><div class="card border-0 rounded-4 text-center p-3" style="background:#f0eaff;"><div class="fs-3 fw-bold" style="color:#7c3aed;">${empty todayCounts['success'] ? 0 : todayCounts['success']}</div><div class="small text-muted mt-1">Hoàn thành</div></div></div>
    <div class="col-6 col-md-3"><div class="card border-0 rounded-4 text-center p-3" style="background:#e8f4fd;"><div class="fs-3 fw-bold text-primary">${empty todayCounts['waiting'] ? 0 : todayCounts['waiting']}</div><div class="small text-muted mt-1">Chờ khám</div></div></div>
    <div class="col-6 col-md-3"><div class="card border-0 rounded-4 text-center p-3" style="background:#fdf0f0;"><div class="fs-3 fw-bold text-danger">${empty todayCounts['cancelled'] ? 0 : todayCounts['cancelled']}</div><div class="small text-muted mt-1">Đã huỷ</div></div></div>
</div>

<%-- Toast --%>
<c:if test="${param.success == 'consultationStarted'}"><div class="alert alert-success alert-dismissible fade show" data-cams-toast role="alert"><i class="bi bi-check-circle-fill me-2"></i>Đã bắt đầu khám.<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
<c:if test="${not empty param.error}"><div class="alert alert-danger alert-dismissible fade show" data-cams-toast role="alert"><i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${param.error}"/><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>

<%-- Filter --%>
<div class="card rounded-4 border-0 shadow-sm mb-4">
    <div class="card-body p-3">
        <form method="get" class="row g-2 align-items-end">
            <div class="col-md-2"><label class="form-label small fw-medium text-muted mb-1">Ngày</label><input type="date" name="date" class="form-control form-control-sm rounded-3" value="${mode == 'single' ? viewDate : ''}"></div>
            <div class="col-md-2"><label class="form-label small fw-medium text-muted mb-1">Từ ngày</label><input type="date" name="from" class="form-control form-control-sm rounded-3" value="${mode == 'range' ? fromDate : ''}"></div>
            <div class="col-md-2"><label class="form-label small fw-medium text-muted mb-1">Đến ngày</label><input type="date" name="to" class="form-control form-control-sm rounded-3" value="${mode == 'range' ? toDate : ''}"></div>
            <div class="col-md-2"><label class="form-label small fw-medium text-muted mb-1">Trạng thái</label><select name="status" class="form-select form-select-sm rounded-3"><option value="">Tất cả</option><option value="Confirmed" ${fn:toLowerCase(statusFilter)=='confirmed'?'selected':''}>Đã xác nhận</option><option value="Waiting" ${fn:toLowerCase(statusFilter)=='waiting'?'selected':''}>Chờ khám</option><option value="InProgress" ${fn:toLowerCase(statusFilter)=='inprogress'?'selected':''}>Đang khám</option><option value="WaitingResult" ${fn:toLowerCase(statusFilter)=='waitingresult'?'selected':''}>Đang chờ kết quả</option><option value="SUCCESS" ${fn:toLowerCase(statusFilter)=='success'?'selected':''}>Hoàn thành</option><option value="Cancelled" ${fn:toLowerCase(statusFilter)=='cancelled'?'selected':''}>Đã huỷ</option></select></div>
            <div class="col-md-2"><label class="form-label small fw-medium text-muted mb-1">Tìm kiếm</label><input type="text" name="keyword" class="form-control form-control-sm rounded-3" placeholder="Tên hoặc SĐT..." value="${fn:escapeXml(keyword)}"></div>
            <div class="col-md-2 d-flex gap-2"><button type="submit" class="btn btn-primary btn-sm rounded-3 flex-fill"><i class="bi bi-search me-1"></i>Tìm</button><a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-outline-secondary btn-sm rounded-3"><i class="bi bi-arrow-counterclockwise"></i></a></div>
        </form>
    </div>
</div>

<%-- Table --%>
<div class="card rounded-4 border-0 shadow-sm">
    <div class="card-header bg-transparent border-0 p-3 d-flex justify-content-between align-items-center"><h6 class="fw-semibold mb-0"><i class="bi bi-list-ul me-2 text-primary"></i>Lịch hẹn của bệnh nhân <span class="badge bg-primary rounded-pill ms-1">${totalRecords}</span></h6><c:if test="${not empty keyword}"><span class="badge bg-warning text-dark rounded-pill ms-2"><i class="bi bi-funnel me-1"></i>Lọc: "${fn:escapeXml(keyword)}"</span></c:if></div>
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty appointments}"><div class="text-center py-5 text-muted">Không có lịch hẹn nào.</div></c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" style="min-width: 950px; width: 100%;">
                    <thead><tr><th class="col-idx ps-3">#</th><th class="col-patient">Bệnh nhân</th><th class="col-date">Ngày</th><th class="col-time">Giờ</th><th class="col-booked">Đặt lúc</th><th class="col-symptoms">Triệu chứng</th><th class="col-source">Nguồn</th><th class="col-status">Trạng thái</th><th class="col-stage" style="width:12%;">Giai đoạn</th><th class="col-action pe-3">Thao tác</th></tr></thead>
                    <tbody>
                    <c:forEach var="a" items="${appointments}" varStatus="loop">
                    <c:set var="st" value="${fn:toLowerCase(a.status)}"/>
                    <tr class="${a.priority ? 'table-warning bg-opacity-10' : ''}">
                        <td class="col-idx ps-3 text-muted small">${loop.index + 1}</td>
                        <td class="col-patient fw-medium">${a.patientName}
                            <c:if test="${a.priority}">
                                <br><span class="badge bg-warning text-dark rounded-pill mt-1" style="font-size:.65rem;">
                                    <i class="bi bi-star-fill me-1"></i>Ưu tiên tiếp nhận
                                </span>
                                <c:if test="${not empty a.priorityReason}">
                                    <div class="small text-muted mt-1" style="font-size:.7rem;">
                                        <c:out value="${fn:substring(a.priorityReason, 0, 50)}${fn:length(a.priorityReason) > 50 ? '…' : ''}"/>
                                    </div>
                                </c:if>
                            </c:if>
                        </td>
                        <td class="col-date text-nowrap">${a.appointmentDate}</td>
                        <td class="col-time text-nowrap">${not empty a.shiftLabel ? a.shiftLabel : (not empty a.timeSlot ? a.timeSlot : '—')}</td>
                        <td class="col-booked text-nowrap small text-muted">
                            <c:choose>
                                <c:when test="${not empty a.createdAtText}"><i class="bi bi-clock-history me-1"></i>${a.createdAtText}</c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </td>
                        <td class="col-symptoms text-truncate" title="${a.symptoms}" style="max-width:0;">${not empty a.symptoms ? a.symptoms : '—'}</td>
                        <td class="col-source"><c:choose><c:when test="${a.bookingSource == 'WEB'}"><span class="badge bg-info bg-opacity-75 text-dark rounded-pill">Trực tuyến</span></c:when><c:when test="${a.bookingSource == 'Staff'}"><span class="badge bg-secondary rounded-pill">Tại quầy</span></c:when><c:otherwise><span class="text-muted small">—</span></c:otherwise></c:choose></td>
                        <td class="col-status">
                            <c:choose>
                                <c:when test="${st == 'waiting'}"><form method="post" action="${pageContext.request.contextPath}/doctor/appointments" style="margin:0;"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="action" value="startConsultation"><input type="hidden" name="appointmentId" value="${a.id}"><button type="submit" class="btn btn-primary btn-sm rounded-pill" style="font-size:.72rem;padding:.25rem .7rem;">Bắt đầu khám</button></form></c:when>
                                <c:when test="${st == 'inprogress'}"><span class="st-chip st-inprogress">Đang khám</span></c:when>
                                <c:when test="${st == 'success' || st == 'completed'}"><span class="st-chip st-success">Hoàn thành</span></c:when>
                                <c:when test="${st == 'confirmed'}"><span class="st-chip st-confirmed">Đã xác nhận</span></c:when>
                                <c:when test="${st == 'cancelled'}"><span class="st-chip st-cancelled">Đã huỷ</span></c:when>
                                <c:otherwise><span class="st-chip" style="background:#f3f4f6;color:#6b7280;">${a.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="col-stage small text-muted">
                            <c:choose>
                                <c:when test="${a.status == 'InProgress'}">
                                    <span class="badge bg-info bg-opacity-75 text-dark">${not empty appointmentStages[a.id] ? appointmentStages[a.id] : '—'}</span>
                                </c:when>
                                <c:otherwise><span class="text-muted">—</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="col-action pe-3"><a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${a.id}" class="btn btn-sm btn-outline-success rounded-pill"><i class="bi bi-journal-plus me-1"></i>Hồ sơ</a></td>
                    </tr>
                    </c:forEach>
                </table>
                </div>
            </c:otherwise>
        </c:choose>

        <%-- Phân trang --%>
        <c:if test="${totalPages > 1}">
          <div class="card-footer bg-white p-3 border-top d-flex align-items-center justify-content-between flex-wrap gap-2">
            <div class="text-muted small">Hiển thị <strong>${fn:length(appointments)}</strong> / <strong>${totalRecords}</strong> lịch hẹn</div>
            <nav><ul class="pagination pagination-sm mb-0">
              <c:set var="qp" value=""/>
              <c:if test="${not empty param.date}"><c:set var="qp" value="${qp}&date=${fn:escapeXml(param.date)}"/></c:if>
              <c:if test="${not empty param.from}"><c:set var="qp" value="${qp}&from=${fn:escapeXml(param.from)}"/></c:if>
              <c:if test="${not empty param.to}"><c:set var="qp" value="${qp}&to=${fn:escapeXml(param.to)}"/></c:if>
              <c:if test="${not empty param.status}"><c:set var="qp" value="${qp}&status=${fn:escapeXml(param.status)}"/></c:if>
              <c:if test="${not empty keyword}"><c:set var="qp" value="${qp}&keyword=${fn:escapeXml(keyword)}"/></c:if>
              <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                <a class="page-link" href="?page=${currentPage - 1}${qp}"><i class="bi bi-chevron-left"></i></a>
              </li>
              <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${i == currentPage ? 'active' : ''}">
                  <a class="page-link" href="?page=${i}${qp}">${i}</a>
                </li>
              </c:forEach>
              <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                <a class="page-link" href="?page=${currentPage + 1}${qp}"><i class="bi bi-chevron-right"></i></a>
              </li>
            </ul></nav>
          </div>
        </c:if>
    </div>
</div>
<%@ include file="../common/footer.jsp" %>
