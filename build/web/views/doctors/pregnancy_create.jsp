<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="../common/header.jsp" %>

<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 bg-danger bg-gradient text-white rounded-4">
            <div class="card-body p-4">
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div>
                        <h2 class="fw-bold mb-1">
                            <i class="bi bi-heart-pulse-fill me-2"></i>Bắt Đầu Theo Dõi Thai Kỳ
                        </h2>
                        <p class="mb-0 opacity-75">Bệnh nhân: <strong>${patientName}</strong></p>
                    </div>
                    <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${apptId}"
                       class="btn btn-light btn-sm rounded-pill px-3">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại hồ sơ
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="row g-4 justify-content-center">
    <div class="col-lg-7">

        <%-- Gợi ý gắn vào thai kỳ đang theo dõi sẵn (nếu có) --%>
        <c:if test="${not empty suggestion}">
            <div class="card border-0 rounded-4 shadow-sm mb-4 border-warning border">
                <div class="card-body p-4">
                    <h6 class="fw-bold mb-2">
                        <i class="bi bi-lightbulb me-1 text-warning"></i>
                        Bệnh nhân đang có một thai kỳ chưa kết thúc
                    </h6>
                    <p class="text-muted small mb-3">
                        Bắt đầu: ${suggestion.startDate}
                        <c:if test="${suggestion.estimatedDueDate != null}"> — Dự sinh: ${suggestion.estimatedDueDate}</c:if>
                        — Đã khám ${suggestion.visitCount} lần.
                        Nếu lần khám này thuộc cùng thai kỳ đó, hãy gắn vào thay vì tạo mới.
                    </p>
                    <form method="post" action="${pageContext.request.contextPath}/doctor/pregnancy">
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="action" value="create">
                        <input type="hidden" name="apptId" value="${apptId}">
                        <input type="hidden" name="linkExistingId" value="${suggestion.id}">
                        <button type="submit" class="btn btn-warning btn-sm rounded-pill px-3">
                            <i class="bi bi-link-45deg me-1"></i>Gắn vào thai kỳ này
                        </button>
                    </form>
                </div>
            </div>
        </c:if>

        <div class="card border-0 rounded-4 shadow-sm">
            <div class="card-body p-4">
                <h6 class="fw-bold mb-3">
                    <i class="bi bi-plus-circle me-1 text-danger"></i>Tạo thai kỳ mới
                </h6>

                <form method="post" action="${pageContext.request.contextPath}/doctor/pregnancy">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="create">
                    <input type="hidden" name="apptId" value="${apptId}">

                    <div class="mb-3">
                        <label class="form-label fw-medium">Ngày đầu kỳ kinh cuối (LMP)</label>
                        <input type="date" name="startDate" class="form-control rounded-3"
                               value="${lastMenstrualPeriod}">
                        <div class="form-text">Mặc định lấy theo LMP đã khai báo lúc đặt lịch hẹn (nếu có). Ngày dự sinh sẽ tự ước tính = LMP + 280 ngày nếu để trống bên dưới.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-medium">Ngày dự sinh (tùy chọn, ghi đè ước tính tự động)</label>
                        <input type="date" name="estimatedDueDate" class="form-control rounded-3">
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-medium">Số thai</label>
                        <select name="fetusCount" class="form-select rounded-3">
                            <option value="1" selected>Đơn thai</option>
                            <option value="2">Song thai</option>
                            <option value="3">Tam thai</option>
                        </select>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-medium">Ghi chú</label>
                        <textarea name="notes" class="form-control rounded-3" rows="3"
                                  placeholder="Tiền sử sản khoa, ghi chú ban đầu…"></textarea>
                    </div>

                    <button type="submit" class="btn btn-danger rounded-pill px-4">
                        <i class="bi bi-check-lg me-1"></i>Bắt đầu theo dõi thai kỳ
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
