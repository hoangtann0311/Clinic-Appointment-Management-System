<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Hồ Sơ Cá Nhân — Quản trị viên (CAMS)
    Phạm vi: họ tên, email, số điện thoại, đổi mật khẩu, vai trò (chỉ đọc).
    Dùng lại admin.css + layout/sidebar.jsp sẵn có, không tạo style mới.
--%>

<c:set var="u" value="${pf_user}" />

<%-- Giá trị hiển thị trong form: ưu tiên dữ liệu người dùng vừa nhập (khi có lỗi),
     nếu không thì lấy từ CSDL. --%>
<c:set var="vFullName" value="${pf_formFullName != null ? pf_formFullName : u.fullName}" />
<c:set var="vEmail"    value="${pf_formEmail    != null ? pf_formEmail    : u.email}" />
<c:set var="vPhone"    value="${pf_formPhone    != null ? pf_formPhone    : u.phone}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Cá Nhân — CAMS Quản Trị</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">
    <style>
        /* Ô chỉ-xem (vai trò): nhìn phải khác hẳn 3 ô sửa được ở trên.
           Chỉ dùng biến màu đã có trong admin.css.
           Selector phải là ".admin-body .pf-readonly-box" (không chỉ
           ".pf-readonly-box") để thắng ".admin-body .form-control" ở
           admin.css:926 — rule đó có độ ưu tiên 0,2,0. */
        .admin-body .pf-readonly-box {
            background-color: #f1f5f9;
            color: var(--c-muted, #64748b);
            border-color: transparent;
            box-shadow: none;
            cursor: not-allowed;
            user-select: none;
        }
    </style>
</head>
<body class="admin-body">

<%-- ── TOP BAR ── --%>
<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Mở menu" onclick="toggleSidebar()">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i>
            CAMS
            <span class="brand-badge">Quản trị viên</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="dropdown admin-topbar-dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle"
               id="adminUserDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="admin-avatar-sm me-2">
                    ${not empty sessionScope.user.fullName ? fn:escapeXml(fn:substring(sessionScope.user.fullName, 0, 1)) : '?'}
                </div>
                <span class="d-none d-md-inline fw-semibold text-dark">
                    <c:out value="${sessionScope.user.fullName}" />
                </span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg rounded-3" aria-labelledby="adminUserDropdown">
                <li class="dropdown-header">
                    <h6 class="text-dark mb-0 fw-bold"><c:out value="${sessionScope.user.fullName}" /></h6>
                    <small class="text-muted"><c:out value="${sessionScope.user.roleNameDisplay}" /></small>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li>
                    <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">
                        <i class="bi bi-box-arrow-right me-2"></i>Đăng Xuất
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<%-- ── SIDEBAR ── --%>
<%@ include file="../layout/sidebar.jsp" %>

<%-- ── NỘI DUNG CHÍNH ── --%>
<main class="admin-main" id="adminMain">

    <div class="admin-page-header">
        <div>
            <h1 class="admin-page-title">Hồ Sơ Cá Nhân</h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-person-circle"></i>
                Xem và cập nhật thông tin tài khoản của bạn
            </div>
        </div>
    </div>

    <div class="row g-4">

        <%-- ══════════ THÔNG TIN CÁ NHÂN ══════════ --%>
        <div class="col-12 col-xl-7">
            <div class="card admin-card">
                <div class="card-header">
                    <h5><i class="bi bi-person-vcard"></i>Thông Tin Cá Nhân</h5>
                </div>
                <div class="card-body">

                    <c:if test="${not empty pf_infoSuccess}">
                        <div class="alert alert-success d-flex align-items-center" role="alert">
                            <i class="bi bi-check-circle-fill me-2"></i>
                            <div><c:out value="${pf_infoSuccess}" /></div>
                        </div>
                    </c:if>
                    <c:if test="${not empty pf_infoError}">
                        <div class="alert alert-danger d-flex align-items-center" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i>
                            <div><c:out value="${pf_infoError}" /></div>
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/admin/users/profile" novalidate
                          data-cams-no-busy="true" data-pf-busy-label="Đang lưu…">
                        <input type="hidden" name="_csrf" value="${fn:escapeXml(sessionScope.csrfToken)}">
                        <input type="hidden" name="pf_action" value="info">

                        <div class="mb-3">
                            <label for="pf_fullName" class="form-label fw-semibold">
                                Họ và tên <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="pf_fullName" name="pf_fullName"
                                   maxlength="100" required
                                   value="${fn:escapeXml(vFullName)}">
                            <div class="form-text">Tối đa 100 ký tự.</div>
                        </div>

                        <%-- Email, Số điện thoại và Vai trò đều CHỈ-XEM.
                             Cố ý KHÔNG dùng <input>: đây là <div> nên không gõ được,
                             không submit được, và không "mở khoá" được bằng DevTools như
                             readonly/disabled. Servlet cũng không đọc getParameter cho
                             ba trường này, và AdminProfileDAO không có chúng trong câu
                             UPDATE — khoá ở cả hai phía. --%>
                        <div class="mb-3">
                            <label class="form-label fw-semibold" id="pf_emailLabel">Email</label>
                            <div class="form-control pf-readonly-box" role="textbox"
                                 aria-readonly="true" aria-labelledby="pf_emailLabel" tabindex="-1">
                                <c:out value="${vEmail}" default="—" />
                            </div>
                            <div class="form-text">Email dùng để đăng nhập, không thể tự thay đổi.</div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold" id="pf_phoneLabel">Số điện thoại</label>
                            <div class="form-control pf-readonly-box" role="textbox"
                                 aria-readonly="true" aria-labelledby="pf_phoneLabel" tabindex="-1">
                                <c:out value="${vPhone}" default="—" />
                            </div>
                            <div class="form-text">Số điện thoại do hệ thống quản lý, không thể tự thay đổi.</div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold" id="pf_roleLabel">Vai trò</label>
                            <div class="form-control pf-readonly-box" role="textbox"
                                 aria-readonly="true" aria-labelledby="pf_roleLabel" tabindex="-1">
                                <c:out value="${sessionScope.user.roleNameDisplay}" />
                            </div>
                            <div class="form-text">Bạn không thể tự sửa quyền của chính mình.</div>
                        </div>

                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save me-1"></i>Lưu Thay Đổi
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <%-- ══════════ ĐỔI MẬT KHẨU ══════════ --%>
        <div class="col-12 col-xl-5">
            <div class="card admin-card">
                <div class="card-header">
                    <h5><i class="bi bi-shield-lock"></i>Đổi Mật Khẩu</h5>
                </div>
                <div class="card-body">

                    <c:if test="${not empty pf_pwError}">
                        <div class="alert alert-danger d-flex align-items-center" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i>
                            <div><c:out value="${pf_pwError}" /></div>
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/admin/users/profile" novalidate
                          data-cams-no-busy="true" data-pf-busy-label="Đang xử lý…">
                        <input type="hidden" name="_csrf" value="${fn:escapeXml(sessionScope.csrfToken)}">
                        <input type="hidden" name="pf_action" value="password">

                        <div class="mb-3">
                            <label for="pf_currentPassword" class="form-label fw-semibold">
                                Mật khẩu hiện tại <span class="text-danger">*</span>
                            </label>
                            <input type="password" class="form-control" id="pf_currentPassword"
                                   name="pf_currentPassword" autocomplete="current-password" required>
                        </div>

                        <div class="mb-3">
                            <label for="pf_newPassword" class="form-label fw-semibold">
                                Mật khẩu mới <span class="text-danger">*</span>
                            </label>
                            <input type="password" class="form-control" id="pf_newPassword"
                                   name="pf_newPassword" autocomplete="new-password" required>
                            <div class="form-text">
                                Tối thiểu 8 ký tự, có chữ in hoa, chữ thường và chữ số.
                                Không được trùng mật khẩu hiện tại.
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="pf_confirmPassword" class="form-label fw-semibold">
                                Nhập lại mật khẩu mới <span class="text-danger">*</span>
                            </label>
                            <input type="password" class="form-control" id="pf_confirmPassword"
                                   name="pf_confirmPassword" autocomplete="new-password" required>
                        </div>

                        <div class="alert alert-info d-flex align-items-start" role="alert">
                            <i class="bi bi-info-circle-fill me-2 mt-1"></i>
                            <div class="small">
                                Sau khi đổi mật khẩu thành công, bạn sẽ được đăng xuất
                                và cần đăng nhập lại bằng mật khẩu mới.
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-key me-1"></i>Đổi Mật Khẩu
                        </button>
                    </form>
                </div>
            </div>
        </div>

    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
/*
 * Chống bấm nút gửi hai lần cho 2 form của trang hồ sơ.
 *
 * Hai form đã đặt data-cams-no-busy="true" nên phần khoá nút dùng chung trong
 * assets/js/app-ui.js bỏ qua chúng (app-ui.js luôn ghi "Đang xử lý…" cho mọi form
 * và không xử lý pageshow). Ở đây tự quản lý để có nhãn riêng cho từng nút và
 * để trả nút về bình thường khi người dùng bấm Back.
 */
(function () {
    'use strict';

    var forms = document.querySelectorAll('form[data-pf-busy-label]');

    function submitButtonOf(form) {
        return form.querySelector('button[type="submit"]');
    }

    Array.prototype.forEach.call(forms, function (form) {
        form.addEventListener('submit', function (event) {
            // (b) Nếu có bước kiểm tra nào chặn submit thì KHÔNG khoá nút,
            //     tránh để nút kẹt ở trạng thái "Đang xử lý…".
            if (event.defaultPrevented) { return; }
            if (typeof form.checkValidity === 'function' && !form.checkValidity()) { return; }

            var btn = submitButtonOf(form);
            if (!btn || btn.disabled) { return; }

            // (a) Khoá nút SAU khi trình duyệt đã bắt đầu gửi form. Nếu khoá ngay
            //     trong handler thì tham số của nút submit có name sẽ bị mất.
            window.setTimeout(function () {
                if (!btn.dataset.pfOriginalHtml) {
                    btn.dataset.pfOriginalHtml = btn.innerHTML;
                }
                btn.disabled = true;
                btn.textContent = form.getAttribute('data-pf-busy-label');
            }, 0);
        });
    });

    // (c) Bấm Back: trang có thể được khôi phục từ bộ nhớ đệm với nút vẫn đang bị
    //     khoá. Đặt lại trạng thái ban đầu cho nút.
    window.addEventListener('pageshow', function () {
        Array.prototype.forEach.call(forms, function (form) {
            var btn = submitButtonOf(form);
            if (!btn) { return; }
            btn.disabled = false;
            if (btn.dataset.pfOriginalHtml) {
                btn.innerHTML = btn.dataset.pfOriginalHtml;
                delete btn.dataset.pfOriginalHtml;
            }
        });
    });
}());
</script>

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
