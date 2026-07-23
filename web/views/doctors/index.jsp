<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="../common/header.jsp" %>

<div class="row mb-4">
    <div class="col-12">
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
    </div>
</div>

<div class="row g-4">
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
                    <%-- Doctor (roleId=2) --%>
                    <c:if test="${user.roleId == 2}">
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/doctor/appointments" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-calendar-check fs-4 text-primary"></i>
                                    <h6 class="mt-2 mb-1">Lịch Khám</h6>
                                    <small class="text-muted">Xem lịch hẹn hôm nay</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/doctor/medical-records" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-journal-medical fs-4 text-success"></i>
                                    <h6 class="mt-2 mb-1">Bệnh Án</h6>
                                    <small class="text-muted">Quản lý hồ sơ bệnh án</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/doctor/prescriptions-list" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-prescription2 fs-4 text-danger"></i>
                                    <h6 class="mt-2 mb-1">Kê Đơn</h6>
                                    <small class="text-muted">Tạo đơn thuốc</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- Patient (roleId=5) --%>
                    <c:if test="${user.roleId == 5}">
                        <div class="col-sm-6">
                            <a href="#" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-calendar-plus fs-4 text-primary"></i>
                                    <h6 class="mt-2 mb-1">Đặt Lịch Khám</h6>
                                    <small class="text-muted">Đặt lịch hẹn mới</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="#" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-clock-history fs-4 text-info"></i>
                                    <h6 class="mt-2 mb-1">Lịch Sử Khám</h6>
                                    <small class="text-muted">Xem lịch sử khám bệnh</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- Manager (roleId=3) --%>
                    <c:if test="${user.roleId == 3}">
                        <div class="col-sm-6">
                            <a href="#" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-graph-up fs-4 text-primary"></i>
                                    <h6 class="mt-2 mb-1">Báo Cáo</h6>
                                    <small class="text-muted">Thống kê doanh thu</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="#" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-people fs-4 text-success"></i>
                                    <h6 class="mt-2 mb-1">Nhân Sự</h6>
                                    <small class="text-muted">Quản lý bác sĩ, nhân viên</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- Staff (roleId=4) --%>
                    <c:if test="${user.roleId == 4}">
                        <div class="col-sm-6">
                            <a href="#" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-calendar-check fs-4 text-primary"></i>
                                    <h6 class="mt-2 mb-1">Quản Lý Lịch Hẹn</h6>
                                    <small class="text-muted">Xác nhận, sắp xếp lịch hẹn</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="#" class="text-decoration-none">
                                <div class="quick-link-card p-3 rounded-3 border">
                                    <i class="bi bi-receipt fs-4 text-warning"></i>
                                    <h6 class="mt-2 mb-1">Hóa Đơn</h6>
                                    <small class="text-muted">Quản lý thanh toán</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- Sonographer (roleId=6) --%>
                    <c:if test="${user.roleId == 6}">
                        <div class="col-sm-6">
                            <a href="#" class="text-decoration-none">
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

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=202">

<%@ include file="../common/footer.jsp" %>
