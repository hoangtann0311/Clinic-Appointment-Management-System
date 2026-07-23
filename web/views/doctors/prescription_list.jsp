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
                            <i class="bi bi-prescription2 me-2"></i>Danh Sách Đơn Thuốc
                        </h2>
                        <p class="mb-0 opacity-75">BS. ${doctorName} &mdash; các đơn thuốc đã kê</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/doctor/dashboard"
                       class="btn btn-light btn-sm rounded-pill px-3">
                        <i class="bi bi-arrow-left me-1"></i>Dashboard
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- ── Tìm kiếm ────────────────────────────────────────────────────────── --%>
<div class="card border-0 rounded-4 shadow-sm mb-4">
    <div class="card-body p-4">
        <form method="get" action="${pageContext.request.contextPath}/doctor/prescriptions-list"
              class="d-flex gap-3 align-items-end flex-wrap">
            <div class="flex-grow-1">
                <label class="form-label fw-semibold small text-muted">
                    <i class="bi bi-search me-1"></i>Tìm kiếm
                </label>
                <input type="text" name="keyword" class="form-control rounded-3"
                       placeholder="Tên bệnh nhân hoặc mã đơn thuốc..."
                       value="${keyword}">
            </div>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-danger rounded-3">
                    <i class="bi bi-search me-1"></i>Tìm
                </button>
                <c:if test="${not empty keyword}">
                    <a href="${pageContext.request.contextPath}/doctor/prescriptions-list"
                       class="btn btn-outline-secondary rounded-3">Xoá bộ lọc</a>
                </c:if>
            </div>
        </form>
    </div>
</div>

<%-- ── Bảng đơn thuốc ─────────────────────────────────────────────────── --%>
<div class="card border-0 rounded-4">
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty prescriptions}">
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-prescription2 fs-1 d-block mb-3 opacity-25"></i>
                    <c:choose>
                        <c:when test="${not empty keyword}">
                            Không tìm thấy đơn thuốc nào với từ khoá "<strong>${keyword}</strong>".
                        </c:when>
                        <c:otherwise>Chưa có đơn thuốc nào được kê.</c:otherwise>
                    </c:choose>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4">Mã Đơn</th>
                                <th>Bệnh Nhân</th>
                                <th>Ngày Khám</th>
                                <th>Chẩn Đoán</th>
                                <th class="text-center">Số Thuốc</th>
                                <th class="text-center">Trạng Thái</th>
                                <th class="text-end pe-4">Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="rx" items="${prescriptions}">
                                <tr>
                                    <td class="ps-4">
                                        <span class="font-monospace small fw-semibold text-danger">${rx.code}</span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/doctor/patient-history?patientId=${rx.patientId}"
                                           class="text-decoration-none fw-medium">
                                            ${rx.patientName}
                                        </a>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-dark border small">
                                            <i class="bi bi-calendar me-1"></i>${rx.appointmentDate}
                                        </span>
                                    </td>
                                    <td class="small text-muted">
                                        ${fn:substring(rx.finalDiagnosis,0,45)}
                                        <c:if test="${fn:length(rx.finalDiagnosis)>45}">...</c:if>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge bg-primary rounded-pill">${rx.itemCount} thuốc</span>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${rx.status == 'issued'}">
                                                <span class="badge bg-success rounded-pill">Đã kê</span>
                                            </c:when>
                                            <c:when test="${rx.status == 'dispensed'}">
                                                <span class="badge bg-info rounded-pill">Đã cấp</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary rounded-pill">${rx.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end pe-4">
                                        <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${rx.appointmentId}"
                                           class="btn btn-sm btn-outline-danger rounded-pill">
                                            <i class="bi bi-eye me-1"></i>Xem hồ sơ và đơn
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <div class="p-3 text-muted small border-top">
                    Tổng: <strong>${fn:length(prescriptions)}</strong> đơn thuốc
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
