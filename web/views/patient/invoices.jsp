<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 patient-hero-card rounded-4">
            <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div>
                    <h2 class="fw-bold mb-1"><i class="bi bi-clock-history me-2"></i>Lịch Sử Thanh Toán</h2>
                    <p class="mb-0 opacity-75">Theo dõi toàn bộ lịch sử thanh toán phí khám, dịch vụ cận lâm sàng và đơn thuốc của bạn.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-light text-pink-theme fw-bold rounded-3">
                        <i class="bi bi-calendar2-week me-1"></i>Xem Lịch Hẹn Của Tôi
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="alert alert-info border-0 rounded-4 shadow-sm p-3 mb-4 d-flex align-items-center gap-3">
    <div class="fs-2 text-info me-2"><i class="bi bi-info-circle-fill"></i></div>
    <div>
        <div class="fw-bold text-dark mb-1">Thông tin thanh toán</div>
        <div class="small text-secondary">
            Tất cả các khoản chi phí (phí khám, dịch vụ cận lâm sàng, đơn thuốc) được <strong>thanh toán trực tiếp tại quầy Lễ tân</strong>.
            Lịch sử bên dưới hiển thị toàn bộ các giao dịch đã và đang xử lý trong quá trình khám chữa bệnh của bạn.
        </div>
    </div>
</div>

<c:if test="${not empty infoMessage}">
    <div class="alert alert-light border rounded-4 text-center py-4 mb-4">
        <i class="bi bi-info-circle fs-4 text-muted mb-2 d-block"></i>
        ${infoMessage}
    </div>
</c:if>

<div class="card border-0 shadow-sm rounded-4 mb-5">
    <div class="card-header bg-transparent border-0 p-4 pb-2 d-flex align-items-center justify-content-between flex-wrap gap-2">
        <div>
            <h5 class="fw-bold mb-1">
                <i class="bi bi-receipt-cutoff me-2 text-primary"></i>Lịch Sử Giao Dịch
            </h5>
            <p class="text-muted small mb-0">Xem lại toàn bộ các giao dịch thanh toán đã thực hiện và đang chờ xử lý</p>
        </div>
        <span class="badge bg-light text-dark border px-3 py-2 rounded-pill">
            Tổng cộng: <strong>${fn:length(invoices)}</strong> phiếu
        </span>
    </div>
    <div class="card-body p-4 pt-3">
        <form action="${pageContext.request.contextPath}/patient/invoices" method="GET" class="mb-4">
            <div class="row">
                <div class="col-md-7 col-lg-6">
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                        <input type="text" name="keyword" class="form-control border-start-0 ps-0"
                               value="${fn:escapeXml(keyword)}"
                               placeholder="Tìm theo mã HĐ, tên Bác sĩ...">
                               
                        <select name="status" class="form-select" style="max-width: 170px;">
                            <option value="">-- Trạng thái TT --</option>
                            <option value="Unpaid" ${status == 'Unpaid' ? 'selected' : ''}>Chưa thanh toán</option>
                            <option value="Paid" ${status == 'Paid' ? 'selected' : ''}>Đã thanh toán</option>
                            <option value="PendingConfirmation" ${status == 'PendingConfirmation' ? 'selected' : ''}>Chờ duyệt</option>
                        </select>
                        <button type="submit" class="btn btn-primary">Tìm kiếm</button>
                    </div>
                </div>
            </div>
        </form>

        <c:choose>
            <c:when test="${not empty invoices}">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-3">Mã phiếu</th>
                                <th>Loại khoản chi</th>
                                <th>Mã lịch hẹn</th>
                                <th>Ngày tạo</th>
                                <th>Số tiền</th>
                                <th>Phương thức</th>
                                <th class="text-center">Trạng thái</th>
                                <th class="text-end pe-3">Ghi chú</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="inv" items="${invoices}">
                                <c:set var="statusLower" value="${fn:toLowerCase(inv.status)}"/>
                                <tr>
                                    <td class="ps-3 fw-bold text-primary">
                                        #INV-${inv.id}
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${inv.invoiceType == 'PRE_EXAM'}">
                                                <span class="fw-semibold text-dark"><i class="bi bi-person-badge me-1 text-primary"></i>Dịch vụ khám lâm sàng</span>
                                                <c:if test="${not empty inv.items}">
                                                    <ul class="mb-1 ps-3 small text-muted" style="list-style-type: disc;">
                                                        <c:forEach var="item" items="${inv.items}">
                                                            <li>${item.itemName}</li>
                                                        </c:forEach>
                                                    </ul>
                                                </c:if>
                                                <div class="small text-muted fst-italic">Do Lễ tân phát hành</div>
                                            </c:when>
                                            <c:when test="${inv.invoiceType == 'POST_EXAM'}">
                                                <span class="fw-semibold text-dark"><i class="bi bi-activity me-1 text-danger"></i>Chỉ định Cận lâm sàng</span>
                                                <c:if test="${not empty inv.items}">
                                                    <ul class="mb-1 ps-3 small text-muted" style="list-style-type: disc;">
                                                        <c:forEach var="item" items="${inv.items}">
                                                            <li>${item.itemName}</li>
                                                        </c:forEach>
                                                    </ul>
                                                </c:if>
                                                <div class="small text-muted fst-italic">Do Bác sĩ phát hành</div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="fw-semibold text-dark"><i class="bi bi-receipt me-1"></i>Hóa đơn dịch vụ</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/patient/appointments" class="text-decoration-none fw-semibold">
                                            #APT-${inv.appointmentId}
                                        </a>
                                    </td>
                                    <td class="small text-muted">
                                        <c:choose>
                                            <c:when test="${not empty inv.createdAt}">
                                                <fmt:formatDate value="${inv.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="fw-bold text-danger">
                                        <fmt:formatNumber value="${inv.totalAmount}" pattern="#,###"/>đ
                                    </td>
                                    <td class="small">
                                        <c:choose>
                                            <c:when test="${inv.paymentMethod == 'Cash'}">
                                                <span style="color:#15803d;"><i class="bi bi-cash-stack me-1"></i>Tiền mặt</span>
                                            </c:when>
                                            <c:when test="${inv.paymentMethod == 'BankTransfer'}">
                                                <span style="color:#0d6efd;"><i class="bi bi-bank me-1"></i>Chuyển khoản</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${statusLower == 'paid'}">
                                                <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-2">
                                                    <i class="bi bi-check-circle-fill me-1"></i>Đã thanh toán tại quầy
                                                </span>
                                            </c:when>
                                            <c:when test="${statusLower == 'cancelled'}">
                                                <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle rounded-pill px-3 py-2">
                                                    <i class="bi bi-x-circle-fill me-1"></i>Đã hủy phiếu
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill px-3 py-2">
                                                    <i class="bi bi-clock-history me-1"></i>Chờ thanh toán tại quầy
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end pe-3 small text-muted">
                                        <c:choose>
                                            <c:when test="${statusLower == 'paid'}">
                                                <span class="text-success"><i class="bi bi-shield-check me-1"></i>Đã hoàn tất tại quầy</span>
                                            </c:when>
                                            <c:when test="${statusLower == 'cancelled'}">
                                                <span class="text-muted"><i class="bi bi-slash-circle me-1"></i>Lịch hẹn đã hủy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-secondary"><i class="bi bi-geo-alt me-1"></i>Đóng tiền tại Lễ tân</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                
                <c:if test="${totalPages > 1}">
                    <div class="d-flex justify-content-center mt-4">
                        <nav aria-label="Page navigation">
                            <ul class="pagination mb-0">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="?page=${currentPage - 1}&keyword=${fn:escapeXml(keyword)}&status=${fn:escapeXml(status)}">Trước</a>
                                </li>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="?page=${i}&keyword=${fn:escapeXml(keyword)}&status=${fn:escapeXml(status)}">${i}</a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="?page=${currentPage + 1}&keyword=${fn:escapeXml(keyword)}&status=${fn:escapeXml(status)}">Sau</a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5">
                    <i class="bi bi-file-earmark-x fs-1 text-muted opacity-50 mb-3 d-block"></i>
                    <h5 class="fw-bold text-secondary">Chưa có giao dịch thanh toán nào</h5>
                    <p class="text-muted small">Khi bạn thực hiện thanh toán tại quầy Lễ tân, lịch sử giao dịch sẽ xuất hiện tại đây.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
