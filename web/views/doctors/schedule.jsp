<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Banner ──────────────────────────────────────────────────────────────── --%>
<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 rounded-4" style="background: linear-gradient(135deg,#e91e8c,#c2185b); color:#fff;">
            <div class="card-body p-4">
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div>
                        <h2 class="fw-bold mb-1">
                            <i class="bi bi-calendar2-week me-2"></i>Lịch Làm Việc Của Tôi
                        </h2>
                        <p class="mb-0 opacity-75 fs-6">
                            BS. <strong>${doctor.fullName}</strong> &mdash;
                            Đăng ký lịch trực và xem trạng thái phê duyệt
                        </p>
                    </div>
                    <button class="btn btn-light fw-semibold px-4 rounded-pill"
                            data-bs-toggle="modal" data-bs-target="#createModal">
                        <i class="bi bi-plus-circle me-2"></i>Đăng Ký Lịch Mới
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- ── Flash messages ───────────────────────────────────────────────────────── --%>
<c:if test="${not empty success}">
    <div class="alert alert-success alert-dismissible fade show rounded-3 mb-3" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>
        <c:choose>
            <c:when test="${success == 'created'}">Đăng ký lịch làm việc thành công! Chờ Manager phê duyệt.</c:when>
            <c:when test="${success == 'cancelled'}">Đã hủy đăng ký lịch trực thành công.</c:when>
            <c:otherwise>Thao tác thành công.</c:otherwise>
        </c:choose>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${not empty error}">
    <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-3" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${not empty errorMessage}">
    <div class="alert alert-warning rounded-3 mb-3">
        <i class="bi bi-person-x me-2"></i>${errorMessage}
    </div>
</c:if>

<%-- ── KPI Cards ─────────────────────────────────────────────────────────────── --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-md-4">
        <div class="card border-0 rounded-4 h-100 text-center p-3" style="background:#fff8f0;">
            <div class="fs-1 fw-bold text-warning">${pendingCount}</div>
            <div class="small text-muted mt-1">
                <i class="bi bi-hourglass-split me-1"></i>Chờ Duyệt
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4">
        <div class="card border-0 rounded-4 h-100 text-center p-3" style="background:#e8fdf0;">
            <div class="fs-1 fw-bold text-success">${approvedCount}</div>
            <div class="small text-muted mt-1">
                <i class="bi bi-check-circle me-1"></i>Đã Duyệt
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4">
        <div class="card border-0 rounded-4 h-100 text-center p-3" style="background:#f5f5f5;">
            <div class="fs-1 fw-bold text-secondary">${cancelledCount}</div>
            <div class="small text-muted mt-1">
                <i class="bi bi-x-circle me-1"></i>Đã Hủy
            </div>
        </div>
    </div>
</div>

<%-- ── Filter bar ───────────────────────────────────────────────────────────── --%>
<div class="card border-0 rounded-4 mb-4">
    <div class="card-body p-3">
        <form method="get" action="${pageContext.request.contextPath}/doctor/schedules"
              class="row g-2 align-items-end">
            <div class="col-sm-6 col-md-3">
                <label class="form-label small fw-medium mb-1">Trạng thái</label>
                <select name="status" class="form-select form-select-sm rounded-3">
                    <option value="">-- Tất cả --</option>
                    <option value="PENDING"   ${statusFilter == 'PENDING'   ? 'selected' : ''}>Chờ duyệt</option>
                    <option value="APPROVED"  ${statusFilter == 'APPROVED'  ? 'selected' : ''}>Đã duyệt</option>
                    <option value="REJECTED"  ${statusFilter == 'REJECTED'  ? 'selected' : ''}>Đã từ chối</option>
                    <option value="CANCELLED" ${statusFilter == 'CANCELLED' ? 'selected' : ''}>Đã hủy</option>
                </select>
            </div>
            <div class="col-sm-6 col-md-3">
                <label class="form-label small fw-medium mb-1">Từ ngày</label>
                <input type="date" name="dateFrom" class="form-control form-control-sm rounded-3"
                       value="${dateFromFilter}">
            </div>
            <div class="col-sm-6 col-md-3">
                <label class="form-label small fw-medium mb-1">Đến ngày</label>
                <input type="date" name="dateTo" class="form-control form-control-sm rounded-3"
                       value="${dateToFilter}">
            </div>
            <div class="col-sm-6 col-md-3 d-flex gap-2">
                <button type="submit" class="btn btn-primary btn-sm rounded-3 flex-fill">
                    <i class="bi bi-search me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/doctor/schedules"
                   class="btn btn-outline-secondary btn-sm rounded-3">
                    <i class="bi bi-arrow-clockwise"></i>
                </a>
            </div>
        </form>
    </div>
</div>

<%-- ── Tab chuyển chế độ xem ────────────────────────────────────────────────── --%>
<div class="d-flex gap-2 mb-3">
    <button id="btnViewList" type="button"
            class="btn btn-primary btn-sm rounded-pill px-4 active-view"
            onclick="switchView('list')">
        <i class="bi bi-list-ul me-1"></i>Danh sách
    </button>
    <button id="btnViewCal" type="button"
            class="btn btn-outline-primary btn-sm rounded-pill px-4"
            onclick="switchView('cal')">
        <i class="bi bi-calendar3 me-1"></i>Lịch tháng
    </button>
</div>

<%-- ── Calendar view ─────────────────────────────────────────────────────────── --%>
<div id="calendarView" class="card border-0 rounded-4 mb-4 d-none">
    <div class="card-body p-4">

        <%-- Điều hướng tháng --%>
        <div class="d-flex align-items-center justify-content-between mb-3">
            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill px-3"
                    onclick="calPrev()">
                <i class="bi bi-chevron-left"></i>
            </button>
            <h6 class="fw-bold mb-0" id="calTitle"></h6>
            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill px-3"
                    onclick="calNext()">
                <i class="bi bi-chevron-right"></i>
            </button>
        </div>

        <%-- Chú thích --%>
        <div class="d-flex gap-3 mb-3 flex-wrap small">
            <span><span class="badge bg-warning text-dark">●</span> Chờ duyệt</span>
            <span><span class="badge bg-success">●</span> Đã duyệt</span>
            <span><span class="badge bg-danger">●</span> Từ chối</span>
            <span><span class="badge bg-secondary">●</span> Đã hủy</span>
        </div>

        <%-- Lưới lịch --%>
        <div class="table-responsive">
            <table class="table table-bordered mb-0 text-center" id="calTable"
                   style="table-layout:fixed;">
                <thead class="table-light">
                    <tr>
                        <th style="width:14.28%">CN</th>
                        <th style="width:14.28%">Hai</th>
                        <th style="width:14.28%">Ba</th>
                        <th style="width:14.28%">Tư</th>
                        <th style="width:14.28%">Năm</th>
                        <th style="width:14.28%">Sáu</th>
                        <th style="width:14.28%">Bảy</th>
                    </tr>
                </thead>
                <tbody id="calBody"></tbody>
            </table>
        </div>
    </div>
</div>

<%-- ── Bảng danh sách lịch ──────────────────────────────────────────────────── --%>
<div id="listView" class="card border-0 rounded-4">
    <div class="card-body p-0">
        <div class="d-flex align-items-center justify-content-between px-4 pt-3 pb-2">
            <h6 class="fw-semibold mb-0">
                <i class="bi bi-list-ul me-2 text-primary"></i>
                Danh Sách Lịch Đăng Ký
                <span class="badge bg-light text-dark border ms-2">${totalSchedules}</span>
            </h6>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th class="ps-4">#</th>
                        <th>Ngày Làm Việc</th>
                        <th>Ca Làm Việc</th>
                        <th class="text-center">Giới Hạn BN</th>
                        <th>Trạng Thái</th>
                        <th>Ghi Chú</th>
                        <th>Ngày Đăng Ký</th>
                        <th class="text-center">Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty schedules}">
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <i class="bi bi-calendar-x fs-1 d-block mb-2 opacity-25"></i>
                                    Chưa có lịch đăng ký nào.
                                    <a href="#" data-bs-toggle="modal" data-bs-target="#createModal"
                                       class="d-block mt-2">Đăng ký ngay</a>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="s" items="${schedules}" varStatus="st">
                                <tr>
                                    <%-- # --%>
                                    <td class="ps-4 text-muted small">
                                        ${(currentPage - 1) * pageSize + st.index + 1}
                                    </td>

                                    <%-- Ngày --%>
                                    <td class="fw-medium">
                                        <i class="bi bi-calendar3 me-1 text-primary"></i>
                                        <fmt:formatDate value="${s.workDate}" pattern="dd/MM/yyyy"/>
                                        <c:set var="dow" value="${s.workDate.day}"/>
                                        <%-- Hiển thị thứ --%>
                                        <span class="d-block small text-muted">
                                            <fmt:formatDate value="${s.workDate}" pattern="EEEE" />
                                        </span>
                                    </td>

                                    <%-- Ca làm việc --%>
                                    <td>
                                        <span class="badge bg-light text-dark border px-2 py-1">
                                            <i class="bi bi-clock me-1"></i>
                                            <fmt:formatDate value="${s.startTime}" pattern="HH:mm"/>
                                            &ndash;
                                            <fmt:formatDate value="${s.endTime}" pattern="HH:mm"/>
                                        </span>
                                    </td>

                                    <%-- Giới hạn bệnh nhân --%>
                                    <td class="text-center">
                                        <span class="badge rounded-pill px-3 py-2"
                                              style="background:#e8f4fd; color:#0d6efd; font-size:.85rem;">
                                            <i class="bi bi-people me-1"></i>
                                            ${s.maxSlots} BN/ca
                                        </span>
                                    </td>

                                    <%-- Trạng thái --%>
                                    <td>
                                        <c:choose>
                                            <c:when test="${s.status.name() == 'PENDING'}">
                                                <span class="badge bg-warning text-dark rounded-pill px-3">
                                                    <i class="bi bi-hourglass-split me-1"></i>Chờ duyệt
                                                </span>
                                            </c:when>
                                            <c:when test="${s.status.name() == 'APPROVED'}">
                                                <span class="badge bg-success rounded-pill px-3">
                                                    <i class="bi bi-check-circle me-1"></i>Đã duyệt
                                                </span>
                                            </c:when>
                                            <c:when test="${s.status.name() == 'REJECTED'}">
                                                <span class="badge bg-danger rounded-pill px-3"
                                                      title="${s.rejectionReason}">
                                                    <i class="bi bi-x-circle me-1"></i>Từ chối
                                                </span>
                                                <c:if test="${not empty s.rejectionReason}">
                                                    <div class="small text-danger mt-1">
                                                        <i class="bi bi-info-circle me-1"></i>
                                                        ${s.rejectionReason}
                                                    </div>
                                                </c:if>
                                            </c:when>
                                            <c:when test="${s.status.name() == 'CANCELLED'}">
                                                <span class="badge bg-secondary rounded-pill px-3">
                                                    <i class="bi bi-slash-circle me-1"></i>Đã hủy
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-dark rounded-pill px-3">
                                                    ${s.status}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- Ghi chú --%>
                                    <td class="text-muted small" style="max-width:160px;">
                                        <c:choose>
                                            <c:when test="${not empty s.notes}">
                                                <span title="${s.notes}">
                                                    <c:out value="${fn:length(s.notes) > 40 ? fn:substring(s.notes,0,40).concat('...') : s.notes}"/>
                                                </span>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- Ngày đăng ký --%>
                                    <td class="text-muted small">
                                        <c:if test="${not empty s.createdAt}">
                                            <fmt:formatDate value="${s.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </c:if>
                                    </td>

                                    <%-- Thao tác --%>
                                    <td class="text-center">
                                        <c:if test="${s.status.name() == 'PENDING'}">
                                            <button type="button"
                                                    class="btn btn-sm btn-outline-danger rounded-pill px-3"
                                                    onclick="confirmCancel(${s.id})">
                                                <i class="bi bi-x-circle me-1"></i>Hủy
                                            </button>
                                        </c:if>
                                        <c:if test="${s.status.name() != 'PENDING'}">
                                            <span class="text-muted small">—</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <%-- Phân trang --%>
        <c:if test="${totalPages > 1}">
            <div class="d-flex justify-content-between align-items-center px-4 py-3 border-top">
                <small class="text-muted">
                    Trang ${currentPage} / ${totalPages}
                    (${totalSchedules} lịch đăng ký)
                </small>
                <nav>
                    <ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&status=${statusFilter}&dateFrom=${dateFromFilter}&dateTo=${dateToFilter}">
                                &laquo;
                            </a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <li class="page-item ${p == currentPage ? 'active' : ''}">
                                <a class="page-link" href="?page=${p}&status=${statusFilter}&dateFrom=${dateFromFilter}&dateTo=${dateToFilter}">
                                    ${p}
                                </a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&status=${statusFilter}&dateFrom=${dateFromFilter}&dateTo=${dateToFilter}">
                                &raquo;
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>
    </div>
</div>
<%-- ── Kết thúc listView ── --%>
</div>

<%-- ══════════════════════════════════════════════════════════════════════════
     MODAL: Đăng Ký Lịch Làm Việc Mới
═══════════════════════════════════════════════════════════════════════════ --%>
<div class="modal fade" id="createModal" tabindex="-1" aria-labelledby="createModalLabel"
     aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 rounded-4 shadow">
            <div class="modal-header rounded-top-4 text-white border-0"
                 style="background: linear-gradient(135deg,#e91e8c,#c2185b);">
                <h5 class="modal-title fw-bold" id="createModalLabel">
                    <i class="bi bi-calendar2-plus me-2"></i>Đăng Ký Lịch Làm Việc
                </h5>
                <button type="button" class="btn-close btn-close-white"
                        data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/doctor/schedules"
                  id="createForm" novalidate>
                <input type="hidden" name="action" value="create">

                <div class="modal-body p-4">

                    <%-- Global error --%>
                    <c:if test="${not empty errors.conflict}">
                        <div class="alert alert-warning rounded-3 small">
                            <i class="bi bi-exclamation-triangle me-2"></i>${errors.conflict}
                        </div>
                    </c:if>

                    <%-- Ngày làm việc --%>
                    <div class="mb-3">
                        <label for="workDate" class="form-label fw-medium">
                            Ngày Làm Việc <span class="text-danger">*</span>
                        </label>
                        <input type="date" id="workDate" name="workDate"
                               class="form-control rounded-3 ${not empty errors.workDate ? 'is-invalid' : ''}"
                               min="${minDate}"
                               value="${formWorkDate}" required>
                        <c:if test="${not empty errors.workDate}">
                            <div class="invalid-feedback">${errors.workDate}</div>
                        </c:if>
                        <div class="form-text">Chỉ đăng ký từ ngày mai trở đi.</div>
                    </div>

                    <%-- Giờ bắt đầu / Kết thúc --%>
                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label for="startTime" class="form-label fw-medium">
                                Giờ Bắt Đầu <span class="text-danger">*</span>
                            </label>
                            <input type="time" id="startTime" name="startTime"
                                   class="form-control rounded-3 ${not empty errors.startTime ? 'is-invalid' : ''}"
                                   value="${formStartTime}" required>
                            <c:if test="${not empty errors.startTime}">
                                <div class="invalid-feedback">${errors.startTime}</div>
                            </c:if>
                        </div>
                        <div class="col-6">
                            <label for="endTime" class="form-label fw-medium">
                                Giờ Kết Thúc <span class="text-danger">*</span>
                            </label>
                            <input type="time" id="endTime" name="endTime"
                                   class="form-control rounded-3 ${not empty errors.endTime ? 'is-invalid' : ''}"
                                   value="${formEndTime}" required>
                            <c:if test="${not empty errors.endTime}">
                                <div class="invalid-feedback">${errors.endTime}</div>
                            </c:if>
                        </div>
                    </div>

                    <%-- Quick-fill ca mẫu --%>
                    <div class="mb-3">
                        <label class="form-label small fw-medium text-muted">Ca mẫu nhanh</label>
                        <div class="d-flex gap-2 flex-wrap">
                            <button type="button" class="btn btn-sm btn-outline-primary rounded-pill"
                                    onclick="fillShift('07:00','11:30')">
                                <i class="bi bi-sunrise me-1"></i>Ca Sáng 07:00–11:30
                            </button>
                            <button type="button" class="btn btn-sm btn-outline-warning rounded-pill"
                                    onclick="fillShift('13:00','17:00')">
                                <i class="bi bi-sun me-1"></i>Ca Chiều 13:00–17:00
                            </button>
                            <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill"
                                    onclick="fillShift('17:00','20:00')">
                                <i class="bi bi-moon-stars me-1"></i>Ca Tối 17:00–20:00
                            </button>
                        </div>
                    </div>

                    <%-- Số bệnh nhân tối đa / slot --%>
                    <div class="mb-3">
                        <label for="maxSlots" class="form-label fw-medium">
                            Số Bệnh Nhân Tối Đa / Ca
                            <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text rounded-start-3">
                                <i class="bi bi-people-fill text-primary"></i>
                            </span>
                            <input type="number" id="maxSlots" name="maxSlots"
                                   class="form-control rounded-end-3 ${not empty errors.maxSlots ? 'is-invalid' : ''}"
                                   min="1" max="50" step="1"
                                   value="${not empty formMaxSlots ? formMaxSlots : '10'}"
                                   placeholder="VD: 10" required>
                            <c:if test="${not empty errors.maxSlots}">
                                <div class="invalid-feedback">${errors.maxSlots}</div>
                            </c:if>
                        </div>
                        <div class="form-text">
                            Giới hạn từ 1 đến 50 bệnh nhân. Hệ thống sẽ tự động đóng slot khi đạt tối đa.
                        </div>
                    </div>

                    <%-- Ghi chú --%>
                    <div class="mb-1">
                        <label for="notes" class="form-label fw-medium">Ghi Chú</label>
                        <textarea id="notes" name="notes" rows="2"
                                  class="form-control rounded-3"
                                  placeholder="VD: Phòng khám 2, ưu tiên bệnh nhân tái khám..."
                                  maxlength="500"><c:out value="${formNotes}"/></textarea>
                    </div>
                </div>

                <div class="modal-footer border-0 pt-0 px-4 pb-4">
                    <button type="button" class="btn btn-outline-secondary rounded-pill px-4"
                            data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary rounded-pill px-4 fw-medium"
                            id="submitBtn">
                        <i class="bi bi-send me-2"></i>Gửi Đăng Ký
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════════════════════════════════
     MODAL: Xác nhận Hủy Lịch
═══════════════════════════════════════════════════════════════════════════ --%>
<div class="modal fade" id="cancelModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 rounded-4 shadow">
            <div class="modal-body text-center p-4">
                <div class="mb-3">
                    <i class="bi bi-exclamation-triangle-fill text-warning" style="font-size:3rem;"></i>
                </div>
                <h5 class="fw-bold mb-2">Xác Nhận Hủy Lịch</h5>
                <p class="text-muted small mb-4">
                    Bạn có chắc muốn hủy đăng ký lịch trực này không?<br>
                    Hành động này không thể hoàn tác.
                </p>
                <form method="post" action="${pageContext.request.contextPath}/doctor/schedules"
                      id="cancelForm">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="id" id="cancelScheduleId" value="">
                    <div class="d-flex gap-2 justify-content-center">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4"
                                data-bs-dismiss="modal">Không</button>
                        <button type="submit" class="btn btn-danger rounded-pill px-4">
                            <i class="bi bi-x-circle me-1"></i>Hủy Lịch
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<%-- ── Scripts ──────────────────────────────────────────────────────────────── --%>
<script>
    // Mở modal hủy lịch với ID tương ứng
    function confirmCancel(scheduleId) {
        document.getElementById('cancelScheduleId').value = scheduleId;
        new bootstrap.Modal(document.getElementById('cancelModal')).show();
    }

    // Điền nhanh giờ ca
    function fillShift(start, end) {
        document.getElementById('startTime').value = start;
        document.getElementById('endTime').value   = end;
    }

    // Client-side validation trước khi submit
    document.getElementById('createForm').addEventListener('submit', function(e) {
        const workDate  = document.getElementById('workDate').value;
        const startTime = document.getElementById('startTime').value;
        const endTime   = document.getElementById('endTime').value;
        const maxSlots  = parseInt(document.getElementById('maxSlots').value, 10);

        let valid = true;

        // Ngày không được ở quá khứ
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const selectedDate = new Date(workDate);
        if (!workDate || selectedDate <= today) {
            showFieldError('workDate', 'Ngày làm việc phải từ ngày mai trở đi.');
            valid = false;
        } else {
            clearFieldError('workDate');
        }

        // Giờ kết thúc > giờ bắt đầu
        if (startTime && endTime && startTime >= endTime) {
            showFieldError('endTime', 'Giờ kết thúc phải sau giờ bắt đầu.');
            valid = false;
        } else {
            clearFieldError('endTime');
        }

        // Tối thiểu 30 phút
        if (startTime && endTime && startTime < endTime) {
            const [sh, sm] = startTime.split(':').map(Number);
            const [eh, em] = endTime.split(':').map(Number);
            const diffMin  = (eh * 60 + em) - (sh * 60 + sm);
            if (diffMin < 30) {
                showFieldError('endTime', 'Ca làm việc phải có độ dài tối thiểu 30 phút.');
                valid = false;
            }
        }

        // maxSlots
        if (isNaN(maxSlots) || maxSlots < 1 || maxSlots > 50) {
            showFieldError('maxSlots', 'Số bệnh nhân tối đa phải từ 1 đến 50.');
            valid = false;
        } else {
            clearFieldError('maxSlots');
        }

        if (!valid) e.preventDefault();
    });

    function showFieldError(fieldId, msg) {
        const el = document.getElementById(fieldId);
        el.classList.add('is-invalid');
        let fb = el.nextElementSibling;
        if (!fb || !fb.classList.contains('invalid-feedback')) {
            fb = document.createElement('div');
            fb.className = 'invalid-feedback';
            el.parentNode.insertBefore(fb, el.nextSibling);
        }
        fb.textContent = msg;
    }

    function clearFieldError(fieldId) {
        const el = document.getElementById(fieldId);
        el.classList.remove('is-invalid');
    }

    // Nếu server trả về lỗi (showCreateModal = true), tự mở modal
    <c:if test="${showCreateModal}">
    document.addEventListener('DOMContentLoaded', function () {
        new bootstrap.Modal(document.getElementById('createModal')).show();
    });
    </c:if>

    // ── Calendar view ─────────────────────────────────────────────────────────
    // Thu thập dữ liệu từ server (render phía JSP, không cần thêm API)
    const scheduleData = [
        <c:forEach var="s" items="${allSchedules}" varStatus="st">
        {
            date:   "${s.workDate}",
            start:  "${s.startTime}",
            end:    "${s.endTime}",
            status: "${s.status}",
            slots:  ${s.maxSlots},
            notes:  "${s.notes != null ? s.notes : ''}"
        }<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];

    // Nhóm lịch theo ngày (key: "yyyy-MM-dd")
    const byDate = {};
    scheduleData.forEach(function(s) {
        var d = s.date ? s.date.substring(0, 10) : '';
        if (!d) return;
        if (!byDate[d]) byDate[d] = [];
        byDate[d].push(s);
    });

    var calYear, calMonth;
    (function initCal() {
        var now = new Date();
        calYear  = now.getFullYear();
        calMonth = now.getMonth(); // 0-based
    })();

    function statusColor(st) {
        if (st === 'APPROVED')  return '#198754';
        if (st === 'PENDING')   return '#ffc107';
        if (st === 'REJECTED')  return '#dc3545';
        if (st === 'CANCELLED') return '#6c757d';
        return '#6c757d';
    }
    function statusBg(st) {
        if (st === 'APPROVED')  return '#d1edda';
        if (st === 'PENDING')   return '#fff3cd';
        if (st === 'REJECTED')  return '#f8d7da';
        if (st === 'CANCELLED') return '#e2e3e5';
        return '#e2e3e5';
    }
    function statusLabel(st) {
        if (st === 'APPROVED')  return 'Đã duyệt';
        if (st === 'PENDING')   return 'Chờ duyệt';
        if (st === 'REJECTED')  return 'Từ chối';
        if (st === 'CANCELLED') return 'Đã hủy';
        return st;
    }

    function renderCalendar() {
        var months = ['Tháng 1','Tháng 2','Tháng 3','Tháng 4','Tháng 5','Tháng 6',
                      'Tháng 7','Tháng 8','Tháng 9','Tháng 10','Tháng 11','Tháng 12'];
        document.getElementById('calTitle').textContent =
            months[calMonth] + ' ' + calYear;

        var firstDay = new Date(calYear, calMonth, 1).getDay(); // 0=CN
        var daysInMonth = new Date(calYear, calMonth + 1, 0).getDate();
        var today = new Date();
        today.setHours(0,0,0,0);

        var html = '';
        var day  = 1;
        var row  = 0;

        while (day <= daysInMonth) {
            html += '<tr>';
            for (var col = 0; col < 7; col++) {
                if ((row === 0 && col < firstDay) || day > daysInMonth) {
                    html += '<td style="background:#fafafa;height:90px;"></td>';
                } else {
                    var dateStr = calYear + '-' +
                        String(calMonth + 1).padStart(2,'0') + '-' +
                        String(day).padStart(2,'0');
                    var cellDate = new Date(calYear, calMonth, day);
                    var isToday  = cellDate.getTime() === today.getTime();
                    var events   = byDate[dateStr] || [];

                    var cellStyle = isToday
                        ? 'background:#fff0f8;height:90px;vertical-align:top;'
                        : 'height:90px;vertical-align:top;';

                    html += '<td style="' + cellStyle + '" class="p-1">';
                    html += '<div class="fw-bold small mb-1" style="' +
                        (isToday ? 'color:#e91e8c;' : 'color:#555;') + '">' +
                        day + '</div>';

                    events.forEach(function(ev) {
                        var bg    = statusBg(ev.status);
                        var color = statusColor(ev.status);
                        html += '<div title="' + ev.start + '-' + ev.end +
                            ' | ' + statusLabel(ev.status) +
                            (ev.notes ? ' | ' + ev.notes : '') + '"' +
                            ' style="background:' + bg + ';border-left:3px solid ' + color +
                            ';border-radius:3px;padding:1px 4px;margin-bottom:2px;' +
                            'font-size:.68rem;line-height:1.3;cursor:default;overflow:hidden;' +
                            'white-space:nowrap;text-overflow:ellipsis;color:#333;">' +
                            '<span style="color:' + color + ';font-weight:600;">' +
                            ev.start.substring(0,5) + '-' + ev.end.substring(0,5) +
                            '</span>' +
                            '</div>';
                    });

                    html += '</td>';
                    day++;
                }
            }
            html += '</tr>';
            row++;
        }

        document.getElementById('calBody').innerHTML = html;
    }

    function calPrev() {
        calMonth--;
        if (calMonth < 0) { calMonth = 11; calYear--; }
        renderCalendar();
    }
    function calNext() {
        calMonth++;
        if (calMonth > 11) { calMonth = 0; calYear++; }
        renderCalendar();
    }

    function switchView(view) {
        var listEl  = document.getElementById('listView');
        var calEl   = document.getElementById('calendarView');
        var btnList = document.getElementById('btnViewList');
        var btnCal  = document.getElementById('btnViewCal');
        if (view === 'cal') {
            listEl.classList.add('d-none');
            calEl.classList.remove('d-none');
            btnList.className = 'btn btn-outline-primary btn-sm rounded-pill px-4';
            btnCal.className  = 'btn btn-primary btn-sm rounded-pill px-4';
            renderCalendar();
        } else {
            calEl.classList.add('d-none');
            listEl.classList.remove('d-none');
            btnList.className = 'btn btn-primary btn-sm rounded-pill px-4';
            btnCal.className  = 'btn btn-outline-primary btn-sm rounded-pill px-4';
        }
    }
</script>

<%@ include file="../common/footer.jsp" %>
