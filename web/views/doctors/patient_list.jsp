<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Banner ──────────────────────────────────────────────────────────── --%>
<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 bg-success bg-gradient text-white rounded-4">
            <div class="card-body p-4">
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div>
                        <h2 class="fw-bold mb-1">
                            <i class="bi bi-people me-2"></i>Danh Sách Bệnh Nhân
                        </h2>
                        <p class="mb-0 opacity-75">BS. ${doctorName} &mdash; các bệnh nhân đã từng khám</p>
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

<%-- ── Tìm kiếm ────────────────────────────────────────────────────────── --%>
<div class="card border-0 rounded-4 shadow-sm mb-4">
    <div class="card-body p-4">
        <form method="get" action="${pageContext.request.contextPath}/doctor/patients"
              class="d-flex gap-3 align-items-end flex-wrap">
            <div class="flex-grow-1">
                <label class="form-label fw-semibold small text-muted">
                    <i class="bi bi-search me-1"></i>Tìm kiếm bệnh nhân
                </label>
                <input type="text" name="keyword" class="form-control rounded-3"
                       placeholder="Tên, số điện thoại hoặc email..."
                       value="${keyword}">
            </div>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary rounded-3">
                    <i class="bi bi-search me-1"></i>Tìm
                </button>
                <c:if test="${not empty keyword}">
                    <a href="${pageContext.request.contextPath}/doctor/patients"
                       class="btn btn-outline-secondary rounded-3">Xoá bộ lọc</a>
                </c:if>
            </div>
        </form>
    </div>
</div>

<%-- ── Bảng bệnh nhân ─────────────────────────────────────────────────── --%>
<div class="card border-0 rounded-4">
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty patients}">
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-person-x fs-1 d-block mb-3 opacity-25"></i>
                    <c:choose>
                        <c:when test="${not empty keyword}">
                            Không tìm thấy bệnh nhân nào với từ khoá "<strong>${keyword}</strong>".
                        </c:when>
                        <c:otherwise>Chưa có bệnh nhân nào.</c:otherwise>
                    </c:choose>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4">Bệnh Nhân</th>
                                <th>Liên Hệ</th>
                                <th class="text-center">Lần Khám</th>
                                <th>Khám Gần Nhất</th>
                                <th class="text-end pe-4">Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${patients}">
                                <tr>
                                    <td class="ps-4">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="avatar-sm bg-primary bg-opacity-10 text-primary rounded-circle
                                                        d-flex align-items-center justify-content-center fw-bold"
                                                 style="width:40px;height:40px;">
                                                ${fn:substring(p.fullName, 0, 1)}
                                            </div>
                                            <div>
                                                <div class="fw-semibold">${p.fullName}</div>
                                                <small class="text-muted">Hồ sơ thai sản</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="small">
                                            <c:if test="${not empty p.phone}">
                                                <div><i class="bi bi-telephone text-muted me-1"></i>${p.phone}</div>
                                            </c:if>
                                            <div class="text-muted">${p.email}</div>
                                        </div>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge bg-primary rounded-pill fs-6 px-3">${p.totalVisits}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty p.lastVisit}">
                                                <span class="badge bg-light text-dark border">
                                                    <i class="bi bi-calendar me-1"></i>${p.lastVisit}
                                                </span>
                                            </c:when>
                                            <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end pe-4">
                                        <a href="${pageContext.request.contextPath}/doctor/patient-history?patientId=${p.id}"
                                           class="btn btn-sm btn-outline-info rounded-pill me-1">
                                            <i class="bi bi-clock-history me-1"></i>Lịch Sử
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <div class="p-3 text-muted small border-top">
                    Tổng: <strong>${fn:length(patients)}</strong> bệnh nhân
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
