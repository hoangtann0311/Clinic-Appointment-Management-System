<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="../common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-md-7 col-lg-5">
        <div class="card p-4 p-md-5 login-card">
            <%-- Logo & Heading --%>
            <div class="text-center mb-4">
                <div class="login-icon-wrapper mb-3">
                    <i class="bi bi-key text-warning" style="font-size: 3rem;"></i>
                </div>
                <h2 class="fw-bold mb-1">Quên Mật Khẩu</h2>
                <p class="text-muted">Nhập email để nhận link đặt lại mật khẩu</p>
            </div>

            <%-- Hiển thị lỗi từ server --%>
            <c:if test="${not empty emailError}">
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
                    <div>${emailError}</div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <%-- Form quên mật khẩu --%>
            <form action="${pageContext.request.contextPath}/forgot-password" method="post" novalidate>
                <div class="mb-4">
                    <label for="email" class="form-label fw-semibold">
                        <i class="bi bi-envelope me-1"></i>Email đã đăng ký
                    </label>
                    <div class="input-group">
                        <span class="input-group-text bg-white">
                            <i class="bi bi-envelope text-muted"></i>
                        </span>
                        <input type="email"
                               class="form-control ${not empty emailError ? 'is-invalid' : ''}"
                               id="email" name="email"
                               placeholder="Nhập email bạn đã đăng ký"
                               value="${not empty emailValue ? emailValue : ''}"
                               required autofocus>
                        <c:if test="${not empty emailError}">
                            <div class="invalid-feedback">
                                <i class="bi bi-info-circle me-1"></i>${emailError}
                            </div>
                        </c:if>
                    </div>
                    <div class="form-text mt-2">
                        <small class="text-muted">
                            <i class="bi bi-info-circle me-1"></i>
                            Chúng tôi sẽ gửi link đặt lại mật khẩu vào email của bạn.
                        </small>
                    </div>
                </div>

                <%-- Nút gửi --%>
                <div class="d-grid mb-3">
                    <button type="submit" class="btn btn-warning btn-lg shadow-sm" id="submitBtn">
                        <i class="bi bi-send me-2"></i>Gửi Link Đặt Lại Mật Khẩu
                    </button>
                </div>

                <%-- Link quay lại đăng nhập --%>
                <div class="text-center">
                    <a href="${pageContext.request.contextPath}/login"
                       class="fw-semibold text-decoration-none">
                        <i class="bi bi-arrow-left me-1"></i>Quay lại Đăng Nhập
                    </a>
                </div>
            </form>
        </div>

        <%-- Footer note --%>
        <div class="text-center mt-3">
            <small class="text-muted">
                <i class="bi bi-shield-lock me-1"></i>
                Link đặt lại mật khẩu có hiệu lực trong vòng 1 giờ
            </small>
        </div>
    </div>
</div>

<%-- JavaScript --%>
<script>
document.addEventListener('DOMContentLoaded', function() {
    var submitBtn = document.getElementById('submitBtn');

    // Hiển thị loading khi submit form
    document.querySelector('form').addEventListener('submit', function() {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Đang gửi...';
    });
});
</script>

<%@ include file="../common/footer.jsp" %>
