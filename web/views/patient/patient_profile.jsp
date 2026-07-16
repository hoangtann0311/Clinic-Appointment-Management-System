<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-lg-8 col-xl-7">

        <div class="d-flex align-items-center gap-3 mb-4">
            <div style="width:56px;height:56px;border-radius:50%;background:linear-gradient(135deg,#667eea,#764ba2);
                        display:flex;align-items:center;justify-content:center;font-size:1.6rem;color:#fff;flex-shrink:0;">
                <i class="bi bi-person-fill"></i>
            </div>
            <div>
                <h2 class="fw-bold mb-0">Hồ Sơ Cá Nhân</h2>
                <p class="text-muted mb-0 small">Quản lý thông tin bệnh nhân của bạn</p>
            </div>
        </div>

        <c:if test="${not empty saved}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>
                Cập nhật thông tin thành công!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="card">
            <div class="card-body p-4">
                <form method="post" action="${pageContext.request.contextPath}/patient/profile" novalidate>

                    <div class="row g-4">
                        <%-- Thông tin cơ bản --%>
                        <div class="col-12">
                            <h6 class="fw-bold text-primary border-bottom pb-2 mb-3">
                                <i class="bi bi-person-lines-fill me-2"></i>Thông Tin Cơ Bản
                            </h6>
                        </div>

                        <div class="col-md-6">
                            <label for="fullName" class="form-label fw-semibold">Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" id="fullName" name="fullName" class="form-control"
                                   value="${not empty patient ? patient.fullName : user.fullName}"
                                   placeholder="Nhập họ và tên đầy đủ" required>
                        </div>

                        <div class="col-md-6">
                            <label for="phone" class="form-label fw-semibold">Số điện thoại</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="bi bi-phone"></i></span>
                                <input type="tel" id="phone" name="phone" class="form-control"
                                       value="${not empty patient ? patient.phone : user.phone}"
                                       placeholder="0901234567">
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label for="dateOfBirth" class="form-label fw-semibold">Ngày sinh</label>
                            <input type="date" id="dateOfBirth" name="dateOfBirth" class="form-control"
                                   value="${not empty patient.dateOfBirth ? patient.dateOfBirth : ''}"
                                   max="${pageContext.request.servletContext.getAttribute('today')}">
                        </div>

                        <div class="col-md-6">
                            <label for="zaloUserId" class="form-label fw-semibold">Zalo User ID</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light" style="background:#0068ff!important;">
                                    <i class="bi bi-chat-fill text-white"></i>
                                </span>
                                <input type="text" id="zaloUserId" name="zaloUserId" class="form-control"
                                       value="${not empty patient ? patient.zaloUserId : ''}"
                                       placeholder="ID Zalo để nhận thông báo">
                            </div>
                            <div class="form-text">Dùng để nhận thông báo lịch hẹn qua Zalo.</div>
                        </div>

                        <%-- Thông tin tài khoản (chỉ đọc) --%>
                        <div class="col-12 mt-2">
                            <h6 class="fw-bold text-secondary border-bottom pb-2 mb-3">
                                <i class="bi bi-shield-lock me-2"></i>Thông Tin Tài Khoản
                            </h6>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Email đăng nhập</label>
                            <input type="email" class="form-control bg-light" value="${user.email}" readonly>
                            <div class="form-text">Liên hệ quản trị viên để đổi email.</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Vai trò</label>
                            <input type="text" class="form-control bg-light"
                                   value="${user.roleId == 5 ? 'Bệnh nhân' : 'Tài khoản #' += user.roleId}" readonly>
                        </div>

                        <c:if test="${not empty patient}">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold text-muted small">Mã bệnh nhân</label>
                                <input type="text" class="form-control bg-light form-control-sm"
                                       value="BN-${patient.id}" readonly>
                            </div>
                        </c:if>
                    </div>

                    <hr class="my-4">

                    <div class="d-flex gap-2 justify-content-end">
                        <a href="${pageContext.request.contextPath}/patient/appointments"
                           class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left me-1"></i>Quay lại
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save me-1"></i>Lưu Thay Đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <%-- Đổi mật khẩu liên kết --%>
        <div class="card mt-3">
            <div class="card-body p-3 d-flex align-items-center justify-content-between">
                <div>
                    <span class="fw-semibold"><i class="bi bi-key me-2 text-warning"></i>Đổi mật khẩu</span>
                    <span class="text-muted small ms-2">Cập nhật mật khẩu để bảo mật tài khoản</span>
                </div>
                <a href="${pageContext.request.contextPath}/change-password"
                   class="btn btn-sm btn-outline-warning">
                    Đổi mật khẩu
                </a>
            </div>
        </div>

    </div>
</div>

<%@ include file="../common/footer.jsp" %>
