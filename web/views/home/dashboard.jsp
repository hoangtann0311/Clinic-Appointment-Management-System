<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<div class="row mb-4">
    <div class="col-12">
        <c:choose>
            <c:when test="${user.roleId == 5}">
                <div class="card border-0 patient-hero-card rounded-4">
                    <div class="card-body p-4 p-md-5">
                        <div class="d-flex align-items-center justify-content-between flex-wrap">
                            <div>
                                <h2 class="fw-bold mb-1">
                                    <i class="bi bi-hand-wave me-2"></i>Xin chào, ${user.fullName}!
                                </h2>
                                <p class="mb-0 opacity-75 fs-5">Chào mừng bạn đến với ${dashboardTitle}</p>
                            </div>
                            <div class="mt-3 mt-md-0">
                                <span class="badge bg-light text-primary fs-6 px-3 py-2 rounded-pill">
                                    <i class="bi bi-person-badge me-1"></i>${roleName}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card border-0 bg-primary bg-gradient text-white rounded-4">
                    <div class="card-body p-4 p-md-5">
                        <div class="d-flex align-items-center justify-content-between flex-wrap">
                            <div>
                                <h2 class="fw-bold mb-1">
                                    <i class="bi bi-hand-wave me-2"></i>Xin chào, ${user.fullName}!
                                </h2>
                                <p class="mb-0 opacity-75 fs-5">Chào mừng bạn đến với ${dashboardTitle}</p>
                            </div>
                            <div class="mt-3 mt-md-0">
                                <span class="badge bg-light text-primary fs-6 px-3 py-2 rounded-pill">
                                    <i class="bi bi-person-badge me-1"></i>${roleName}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<c:if test="${not empty successMessage}">
    <div class="alert alert-success alert-dismissible fade show" data-cams-toast role="alert"><i class="bi bi-check-circle-fill me-2"></i>${successMessage}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
</c:if>

<div class="row g-4">
    <%-- ══════════════════════════════════════════════════════════ --%>
    <%-- PATIENT: Thống kê nhanh                                  --%>
    <%-- ══════════════════════════════════════════════════════════ --%>
    <c:if test="${user.roleId == 5}">
    <div class="col-md-4">
        <div class="card border-0 rounded-4 h-100" style="background: #f0f9ff; border-left: 4px solid #0ea5e9;">
            <div class="card-body p-3 d-flex align-items-center gap-3">
                <div class="rounded-circle d-flex align-items-center justify-content-center" style="width:44px;height:44px;background:rgba(14,165,233,.12);color:#0ea5e9;">
                    <i class="bi bi-calendar-check fs-5"></i>
                </div>
                <div>
                    <div class="fw-bold fs-5">${totalMyUpcoming}</div>
                    <small class="text-muted">Lịch sắp tới</small>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 rounded-4 h-100" style="background: #f0fdf4; border-left: 4px solid #22c55e;">
            <div class="card-body p-3 d-flex align-items-center gap-3">
                <div class="rounded-circle d-flex align-items-center justify-content-center" style="width:44px;height:44px;background:rgba(34,197,94,.12);color:#22c55e;">
                    <i class="bi bi-check2-circle fs-5"></i>
                </div>
                <div>
                    <div class="fw-bold fs-5">${totalMyCompleted}</div>
                    <small class="text-muted">Đã hoàn thành</small>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card border-0 rounded-4 h-100" style="background: #fefce8; border-left: 4px solid #eab308;">
            <div class="card-body p-3 d-flex align-items-center gap-3">
                <div class="rounded-circle d-flex align-items-center justify-content-center" style="width:44px;height:44px;background:rgba(234,179,8,.12);color:#eab308;">
                    <i class="bi bi-list-ul fs-5"></i>
                </div>
                <div>
                    <div class="fw-bold fs-5">${totalMyAppointments}</div>
                    <small class="text-muted">Tổng lịch hẹn</small>
                </div>
            </div>
        </div>
    </div>
    </c:if>

    <%-- ══════════════════════════════════════════════════════════ --%>
    <%-- PATIENT: Lịch hẹn sắp tới (nếu có)                       --%>
    <%-- ══════════════════════════════════════════════════════════ --%>
    <c:if test="${user.roleId == 5 && not empty upcomingAppointment}">
    <div class="col-12">
        <div class="card border-0 rounded-4" style="background: linear-gradient(135deg, #fdf2f8 0%, #fce4ec 100%); border-left: 5px solid var(--pt-pink-600, #b86689);">
            <div class="card-body p-4">
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div>
                        <h6 class="text-uppercase small fw-bold mb-1" style="color: var(--pt-pink-600, #b86689); letter-spacing: .05em;">
                            <i class="bi bi-calendar-heart me-1"></i>Lịch khám sắp tới
                        </h6>
                        <h5 class="fw-bold mb-1">
                            <c:choose><c:when test="${not empty upcomingAppointment.doctor}">BS. ${upcomingAppointment.doctor.fullName}</c:when><c:otherwise>Bác sĩ</c:otherwise></c:choose>
                            <span class="badge ms-2 rounded-pill
                                <c:choose>
                                    <c:when test="${fn:toLowerCase(upcomingAppointment.status) == 'confirmed'}">bg-success</c:when>
                                    <c:when test="${fn:toLowerCase(upcomingAppointment.status) == 'pending'}">bg-warning text-dark</c:when>
                                    <c:otherwise>bg-info</c:otherwise>
                                </c:choose>">
                                <c:choose>
                                    <c:when test="${fn:toLowerCase(upcomingAppointment.status) == 'confirmed'}">Đã xác nhận</c:when>
                                    <c:when test="${fn:toLowerCase(upcomingAppointment.status) == 'pending'}">Chờ xác nhận</c:when>
                                    <c:when test="${fn:toLowerCase(upcomingAppointment.status) == 'waiting'}">Chờ khám</c:when>
                                    <c:otherwise>${upcomingAppointment.status}</c:otherwise>
                                </c:choose>
                            </span>
                        </h5>
                        <div class="d-flex flex-wrap gap-3 mt-2 text-muted small">
                            <span><i class="bi bi-calendar3 me-1"></i>${upcomingAppointment.appointmentDate}</span>
                            <span><i class="bi bi-clock me-1"></i>${upcomingAppointment.timeSlot}</span>
                            <span><i class="bi bi-hospital me-1"></i><c:out value="${upcomingAppointment.serviceName}" default="Khám thai định kỳ"/></span>
                        </div>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-sm rounded-pill fw-medium" style="background: var(--pt-pink-600, #b86689); color: #fff;">
                            <i class="bi bi-list-ul me-1"></i>Xem tất cả
                        </a>
                        <c:if test="${fn:toLowerCase(upcomingAppointment.status) == 'pending' && upcomingAppointment.preExamPaymentStatus != 'Paid'}">
                        <a href="${pageContext.request.contextPath}/patient/payment?appointmentId=${upcomingAppointment.id}" class="btn btn-sm btn-light rounded-pill fw-medium">
                            <i class="bi bi-credit-card me-1"></i>Thanh toán
                        </a>
                        </c:if>
                    </div>
                </div>
                <%-- Hiển thị thêm các lịch tiếp theo nếu có nhiều hơn 1 --%>
                <c:if test="${fn:length(upcomingAppts) > 1}">
                <div class="mt-3 pt-3 border-top" style="border-color: rgba(184,102,137,0.15) !important;">
                    <small class="text-muted fw-medium">Các lịch tiếp theo:</small>
                    <div class="d-flex flex-wrap gap-2 mt-2">
                        <c:forEach var="apt" items="${upcomingAppts}" begin="1" end="3">
                            <span class="badge bg-white text-dark border rounded-pill px-3 py-2 small">
                                <i class="bi bi-dot"></i>${apt.appointmentDate} — ${apt.timeSlot} — <c:choose><c:when test="${not empty apt.doctor}">BS. ${apt.doctor.fullName}</c:when><c:otherwise>Bác sĩ</c:otherwise></c:choose>
                            </span>
                        </c:forEach>
                    </div>
                </div>
                </c:if>
            </div>
        </div>
    </div>
    </c:if>

    <%-- Thông tin tài khoản --%>
    <div class="col-lg-4 col-md-6">
        <div class="card h-100 rounded-4">
            <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                    <div class="icon-circle bg-primary bg-opacity-10 text-primary me-3">
                        <i class="bi bi-person-circle fs-3"></i>
                    </div>
                    <h5 class="card-title mb-0 fw-semibold">Thông Tin Tài Khoản</h5>
                </div>
                <ul class="list-unstyled mb-0">
                    <li class="mb-2 d-flex align-items-center">
                        <i class="bi bi-person text-muted me-2"></i>
                        <span class="text-muted me-2">Họ tên:</span>
                        <span class="fw-medium">${user.fullName}</span>
                    </li>
                    <li class="mb-2 d-flex align-items-center">
                        <i class="bi bi-envelope text-muted me-2"></i>
                        <span class="text-muted me-2">Email:</span>
                        <span class="fw-medium">${user.email}</span>
                    </li>
                    <li class="mb-2 d-flex align-items-center">
                        <i class="bi bi-telephone text-muted me-2"></i>
                        <span class="text-muted me-2">Điện thoại:</span>
                        <span class="fw-medium">${not empty user.phone ? user.phone : 'Chưa cập nhật'}</span>
                    </li>
                    <li class="d-flex align-items-center">
                        <i class="bi bi-shield-check text-success me-2"></i>
                        <span class="text-muted me-2">Trạng thái:</span>
                        <span class="badge bg-success rounded-pill">Đang hoạt động</span>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <%-- Truy cập nhanh theo role --%>
    <div class="col-lg-8 col-md-6">
        <div class="card h-100 rounded-4">
            <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                    <div class="icon-circle bg-success bg-opacity-10 text-success me-3">
                        <i class="bi bi-grid-3x3-gap fs-3"></i>
                    </div>
                    <h5 class="card-title mb-0 fw-semibold">Truy Cập Nhanh</h5>
                </div>
                <div class="row g-3">

                    <%-- ── Doctor (roleId=2) ─────────────────────────────── --%>
                    <c:if test="${user.roleId == 2}">
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/doctor/dashboard" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-speedometer2 fs-4 text-primary"></i>
                                    <h6 class="mt-2 mb-1">Tổng Quan Bác Sĩ</h6>
                                    <small class="text-muted">Tổng quan & thống kê</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/doctor/appointments" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-calendar-check fs-4 text-primary"></i>
                                    <h6 class="mt-2 mb-1">Lịch Hẹn</h6>
                                    <small class="text-muted">Xem lịch hẹn hôm nay</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/doctor/medical-records" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-journal-medical fs-4 text-success"></i>
                                    <h6 class="mt-2 mb-1">Hồ Sơ Bệnh Án</h6>
                                    <small class="text-muted">Quản lý hồ sơ bệnh án</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/doctor/prescriptions-list" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-prescription2 fs-4 text-danger"></i>
                                    <h6 class="mt-2 mb-1">Đơn Thuốc</h6>
                                    <small class="text-muted">Danh sách đơn thuốc đã kê</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/doctor/patients" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-people fs-4 text-info"></i>
                                    <h6 class="mt-2 mb-1">Bệnh Nhân</h6>
                                    <small class="text-muted">Danh sách & lịch sử khám</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                                        <%-- ── Patient (roleId=5) ────────────────────────────── --%>
                    <c:if test="${user.roleId == 5}">
                        <div class="col-sm-4">
                            <a href="${pageContext.request.contextPath}/patient/booking" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-calendar-plus fs-4 text-primary"></i>
                                    <h6 class="mt-2 mb-1">Đặt Lịch Khám</h6>
                                    <small class="text-muted">Đặt lịch hẹn mới</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-4">
                            <a href="${pageContext.request.contextPath}/patient/appointments" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-clock-history fs-4 text-info"></i>
                                    <h6 class="mt-2 mb-1">Lịch Sử Khám</h6>
                                    <small class="text-muted">Xem lịch sử khám bệnh</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-4">
                            <a href="${pageContext.request.contextPath}/patient/medical-records" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-journal-medical fs-4 text-success"></i>
                                    <h6 class="mt-2 mb-1">Hồ Sơ Bệnh Án</h6>
                                    <small class="text-muted">Xem chẩn đoán & đơn thuốc</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-4">
                            <a href="${pageContext.request.contextPath}/patient/invoices" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-receipt fs-4 text-warning"></i>
                                    <h6 class="mt-2 mb-1">Hóa Đơn</h6>
                                    <small class="text-muted">Xem & thanh toán hóa đơn</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-4">
                            <a href="${pageContext.request.contextPath}/patient/profile" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-person-gear fs-4 text-secondary"></i>
                                    <h6 class="mt-2 mb-1">Hồ Sơ Cá Nhân</h6>
                                    <small class="text-muted">Cập nhật thông tin</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- ── Manager (roleId=3) ────────────────────────────── --%>
                    <c:if test="${user.roleId == 3}">
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/manager/dashboard#mgrRevenue7DaysChart" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-graph-up fs-4 text-primary"></i>
                                    <h6 class="mt-2 mb-1">Biểu Đồ Doanh Thu</h6>
                                    <small class="text-muted">Theo dõi doanh thu phòng khám</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/manager/schedules" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-people fs-4 text-success"></i>
                                    <h6 class="mt-2 mb-1">Lịch Làm Việc</h6>
                                    <small class="text-muted">Xác nhận lịch làm việc của bác sĩ</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- ── Staff (roleId=4) ──────────────────────────────── --%>
                    <c:if test="${user.roleId == 4}">
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/admin/reception" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-calendar-check fs-4 text-primary"></i>
                                    <h6 class="mt-2 mb-1">Quản Lý Lịch Hẹn</h6>
                                    <small class="text-muted">Xác nhận, sắp xếp lịch hẹn</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/admin/reception/payments" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-receipt fs-4 text-warning"></i>
                                    <h6 class="mt-2 mb-1">Hóa Đơn</h6>
                                    <small class="text-muted">Quản lý thanh toán</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- ── Sonographer (roleId=6) ─────────────────────────── --%>
                    <c:if test="${user.roleId == 6}">
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/sonographer/waiting-list" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-soundwave fs-4 text-primary"></i>
                                    <h6 class="mt-2 mb-1">Kết Quả Siêu Âm</h6>
                                    <small class="text-muted">Nhập kết quả siêu âm</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
