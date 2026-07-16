<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<style>
    .notif-item {
        border-left: 4px solid transparent;
        transition: background 0.15s;
    }
    .notif-item.unread {
        border-left-color: #0d6efd;
        background: #f0f6ff;
    }
    .notif-item:hover { background: #f8f9fa; }
    .notif-icon {
        width: 40px; height: 40px;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 1.1rem; flex-shrink: 0;
    }
</style>

<div class="row">
    <div class="col-lg-8 col-xl-7 mx-auto">

        <div class="d-flex align-items-center justify-content-between mb-4">
            <div class="d-flex align-items-center gap-3">
                <div style="width:50px;height:50px;border-radius:50%;background:linear-gradient(135deg,#f7971e,#ffd200);
                            display:flex;align-items:center;justify-content:center;font-size:1.4rem;flex-shrink:0;">
                    <i class="bi bi-bell-fill text-white"></i>
                </div>
                <div>
                    <h2 class="fw-bold mb-0">Thông Báo</h2>
                    <p class="text-muted mb-0 small">Cập nhật lịch hẹn và thông tin từ phòng khám</p>
                </div>
            </div>
            <c:if test="${unreadCount > 0}">
                <span class="badge bg-danger rounded-pill fs-6">${unreadCount} mới</span>
            </c:if>
        </div>

        <c:choose>
            <c:when test="${empty notifications}">
                <div class="card">
                    <div class="card-body text-center py-5">
                        <i class="bi bi-bell-slash text-muted" style="font-size:3rem;"></i>
                        <h6 class="fw-bold mt-3 text-muted">Chưa có thông báo nào</h6>
                        <p class="text-muted small mb-0">Các cập nhật về lịch hẹn sẽ xuất hiện ở đây.</p>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card p-0">
                    <c:forEach var="notif" items="${notifications}" varStatus="loop">
                        <div class="notif-item p-3 ${!notif.read ? 'unread' : ''} ${!loop.last ? 'border-bottom' : ''}">
                            <div class="d-flex gap-3 align-items-start">
                                <%-- Icon theo loại --%>
                                <c:choose>
                                    <c:when test="${fn:containsIgnoreCase(notif.content, 'SOS') || fn:containsIgnoreCase(notif.content, 'khẩn cấp')}">
                                        <div class="notif-icon bg-danger text-white"><i class="bi bi-exclamation-triangle-fill"></i></div>
                                    </c:when>
                                    <c:when test="${fn:containsIgnoreCase(notif.content, 'xác nhận')}">
                                        <div class="notif-icon bg-success text-white"><i class="bi bi-check-circle-fill"></i></div>
                                    </c:when>
                                    <c:when test="${fn:containsIgnoreCase(notif.content, 'huỷ') || fn:containsIgnoreCase(notif.content, 'hủy')}">
                                        <div class="notif-icon bg-danger text-white"><i class="bi bi-x-circle-fill"></i></div>
                                    </c:when>
                                    <c:when test="${fn:containsIgnoreCase(notif.content, 'thanh toán')}">
                                        <div class="notif-icon bg-success text-white"><i class="bi bi-credit-card-fill"></i></div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="notif-icon bg-primary text-white"><i class="bi bi-bell-fill"></i></div>
                                    </c:otherwise>
                                </c:choose>

                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <p class="mb-1 ${!notif.read ? 'fw-semibold' : ''}" style="font-size:0.92rem;">
                                            ${notif.content}
                                        </p>
                                        <c:if test="${!notif.read}">
                                            <span class="badge bg-primary ms-2 flex-shrink-0" style="font-size:0.65rem;">Mới</span>
                                        </c:if>
                                    </div>
                                    <c:if test="${not empty notif.createdAt}">
                                        <small class="text-muted">
                                            <i class="bi bi-clock me-1"></i>${notif.createdAt}
                                        </small>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="text-center mt-3">
                    <p class="text-muted small">
                        Tổng <strong>${fn:length(notifications)}</strong> thông báo —
                        tất cả đã được đánh dấu đã đọc khi bạn truy cập trang này.
                    </p>
                </div>
            </c:otherwise>
        </c:choose>

        <div class="mt-3">
            <a href="${pageContext.request.contextPath}/patient/appointments"
               class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-left me-1"></i>Quay lại lịch hẹn
            </a>
        </div>

    </div>
</div>

<%@ include file="../common/footer.jsp" %>
