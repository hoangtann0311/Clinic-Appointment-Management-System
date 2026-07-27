<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Hồ Sơ Cá Nhân — Bác sĩ siêu âm (role_id = 6)

    Dữ liệu nằm ở bảng sonographers + users, KHÔNG phải bảng doctors.
    Dùng lại header/footer chung, admin.css sẵn có và các fragment trong views/common.
    Không tạo file CSS mới, không sửa file nào của Bác sĩ lâm sàng.

    Trường chỉ-xem (Email, Vai trò) render bằng profile-readonly-field.jspf —
    không phải thẻ <input>, nên không thể sửa bằng DevTools. Servlet cũng không
    đọc getParameter cho chúng và DAO không có chúng trong câu UPDATE.
--%>
<%@ include file="../common/header.jsp" %>
<%@ include file="../common/profile-readonly-style.jspf" %>

<%-- Giá trị hiển thị: ưu tiên dữ liệu vừa nhập (khi có lỗi), nếu không thì lấy từ CSDL --%>
<c:set var="vFullName"   value="${pf_formFullName       != null ? pf_formFullName       : pf_user.fullName}" />
<c:set var="vPhone"      value="${pf_formPhone          != null ? pf_formPhone          : pf_phone}" />
<c:set var="vSpec"       value="${pf_formSpecialization != null ? pf_formSpecialization : pf_profile.specialization}" />
<c:set var="vDegree"     value="${pf_formDegree         != null ? pf_formDegree         : pf_profile.degree}" />
<c:set var="vBio"        value="${pf_formBio            != null ? pf_formBio            : pf_profile.bio}" />
<c:set var="vQualif"     value="${pf_formQualification  != null ? pf_formQualification  : pf_profile.qualification}" />
<c:set var="vExperience" value="${pf_formExperienceYears != null ? pf_formExperienceYears
                                 : (pf_profile.experienceYears > 0 ? pf_profile.experienceYears : '')}" />

<%-- ── Page Header ────────────────────────────────────────────────────── --%>
<div class="admin-page-header fade-in-up">
    <div>
        <h1 class="admin-page-title">Hồ Sơ Cá Nhân</h1>
        <div class="admin-page-subtitle">
            <i class="bi bi-house-fill"></i>
            <a href="${pageContext.request.contextPath}/sonographer/dashboard"
               style="color:inherit;text-decoration:none;">Tổng Quan</a>
            <i class="bi bi-chevron-right" style="font-size:.65rem;"></i>
            <span>Hồ Sơ</span>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/sonographer/dashboard" class="btn-refresh">
        <i class="bi bi-arrow-left"></i> Quay lại
    </a>
</div>

<%-- ── Banner ─────────────────────────────────────────────────────────── --%>
<div class="card admin-card fade-in-up">
    <div class="card-body d-flex align-items-center gap-4 flex-wrap"
         style="padding: 1.5rem !important;">
        <c:choose>
            <c:when test="${not empty pf_profile.avatarUrl}">
                <img src="${fn:escapeXml(pf_profile.avatarUrl)}" alt="Ảnh đại diện"
                     class="rounded-circle border border-3"
                     style="width:80px;height:80px;object-fit:cover;flex-shrink:0;"
                     onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                <div class="rounded-circle d-none align-items-center justify-content-center"
                     style="width:80px;height:80px;font-size:2rem;background:rgba(124,58,237,.15);
                            color:#6d28d9;font-weight:700;flex-shrink:0;">
                    ${not empty pf_user.fullName ? fn:escapeXml(fn:substring(pf_user.fullName,0,1)) : '?'}
                </div>
            </c:when>
            <c:otherwise>
                <div class="rounded-circle d-flex align-items-center justify-content-center"
                     style="width:80px;height:80px;font-size:2rem;background:rgba(124,58,237,.15);
                            color:#6d28d9;font-weight:700;flex-shrink:0;">
                    ${not empty pf_user.fullName ? fn:escapeXml(fn:substring(pf_user.fullName,0,1)) : '?'}
                </div>
            </c:otherwise>
        </c:choose>
        <div>
            <h2 class="h4 mb-1 fw-bold">BS. <c:out value="${pf_user.fullName}" /></h2>
            <p class="text-muted mb-0">
                <c:out value="${not empty pf_profile.specialization
                               ? pf_profile.specialization : 'Chưa cập nhật chuyên khoa'}" />
                <c:if test="${not empty pf_profile.degree}"> — <c:out value="${pf_profile.degree}" /></c:if>
            </p>
        </div>
    </div>
</div>

<%-- ── Thông báo ──────────────────────────────────────────────────────── --%>
<c:if test="${not empty pf_infoSuccess}">
    <div class="alert alert-success alert-dismissible fade show mt-3" data-cams-toast role="alert">
        <i class="bi bi-check-circle-fill me-2"></i><c:out value="${pf_infoSuccess}" />
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${not empty pf_infoError}">
    <div class="alert alert-danger alert-dismissible fade show mt-3" data-cams-toast role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${pf_infoError}" />
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${not empty sessionScope.successMessage}">
    <div class="alert alert-success alert-dismissible fade show mt-3" data-cams-toast role="alert">
        <i class="bi bi-check-circle-fill me-2"></i><c:out value="${sessionScope.successMessage}" />
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <c:remove var="successMessage" scope="session" />
</c:if>

<%-- ── Form cập nhật hồ sơ ────────────────────────────────────────────── --%>
<div class="card admin-card fade-in-up mt-4">
    <div class="card-header">
        <h5><i class="bi bi-pencil-square"></i>Cập Nhật Hồ Sơ</h5>
    </div>
    <div class="card-body" style="padding: 1.5rem !important;">
        <form method="post" action="${pageContext.request.contextPath}/sonographer/profile"
              id="pfProfileForm" enctype="multipart/form-data" novalidate>
            <input type="hidden" name="_csrf" value="${fn:escapeXml(sessionScope.csrfToken)}">

            <%-- ── Trường sửa được ── --%>
            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label for="pf_fullName" class="form-label fw-semibold">
                        Họ và tên <span class="text-danger">*</span>
                    </label>
                    <input type="text" class="form-control" id="pf_fullName" name="pf_fullName"
                           maxlength="100" required value="${fn:escapeXml(vFullName)}"
                           placeholder="VD: Nguyễn Văn A">
                    <div class="form-text">Tối đa 100 ký tự.</div>
                </div>
                <div class="col-md-6">
                    <label for="pf_phone" class="form-label fw-semibold">Số điện thoại</label>
                    <input type="text" class="form-control" id="pf_phone" name="pf_phone"
                           maxlength="10" inputmode="numeric" value="${fn:escapeXml(vPhone)}"
                           placeholder="VD: 0901234567">
                    <div class="form-text">Gồm đúng 10 chữ số, bắt đầu bằng 0. Có thể để trống.</div>
                </div>
            </div>

            <%-- ── Trường CHỈ-XEM ── --%>
            <div class="row g-3">
                <div class="col-md-6">
                    <c:set var="pfLabel" value="Email" />
                    <c:set var="pfValue" value="${pf_email}" />
                    <c:set var="pfHint"  value="Email dùng để đăng nhập. Liên hệ quản trị viên nếu cần thay đổi." />
                    <%@ include file="../common/profile-readonly-field.jspf" %>
                </div>
                <div class="col-md-6">
                    <c:set var="pfLabel" value="Vai trò" />
                    <c:set var="pfValue" value="${pf_user.roleNameDisplay}" />
                    <c:set var="pfHint"  value="Vai trò do hệ thống quản lý, bạn không thể tự thay đổi." />
                    <%@ include file="../common/profile-readonly-field.jspf" %>
                </div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label for="pf_specialization" class="form-label fw-semibold">
                        Chuyên khoa <span class="text-danger">*</span>
                    </label>
                    <select name="pf_specialization" id="pf_specialization" class="form-select" required>
                        <option value="">— Chọn chuyên khoa —</option>
                        <option value="Sản phụ khoa"                ${vSpec == 'Sản phụ khoa'                ? 'selected' : ''}>Sản phụ khoa</option>
                        <option value="Thai sản &amp; Y học bào thai" ${vSpec == 'Thai sản & Y học bào thai' ? 'selected' : ''}>Thai sản &amp; Y học bào thai</option>
                        <option value="Siêu âm sản phụ khoa"        ${vSpec == 'Siêu âm sản phụ khoa'        ? 'selected' : ''}>Siêu âm sản phụ khoa</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label for="pf_degree" class="form-label fw-semibold">Học vị / Bằng cấp</label>
                    <select name="pf_degree" id="pf_degree" class="form-select">
                        <option value="">— Chọn học vị —</option>
                        <option value="Bác sĩ"      ${vDegree == 'Bác sĩ'      ? 'selected' : ''}>Bác sĩ</option>
                        <option value="Thạc sĩ"     ${vDegree == 'Thạc sĩ'     ? 'selected' : ''}>Thạc sĩ</option>
                        <option value="Tiến sĩ"     ${vDegree == 'Tiến sĩ'     ? 'selected' : ''}>Tiến sĩ</option>
                        <option value="Phó Giáo sư" ${vDegree == 'Phó Giáo sư' ? 'selected' : ''}>Phó Giáo sư</option>
                        <option value="Giáo sư"     ${vDegree == 'Giáo sư'     ? 'selected' : ''}>Giáo sư</option>
                        <option value="Bác sĩ CKI"  ${vDegree == 'Bác sĩ CKI'  ? 'selected' : ''}>Bác sĩ CKI</option>
                        <option value="Bác sĩ CKII" ${vDegree == 'Bác sĩ CKII' ? 'selected' : ''}>Bác sĩ CKII</option>
                    </select>
                </div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <label for="pf_experienceYears" class="form-label fw-semibold">Số năm kinh nghiệm</label>
                    <div class="input-group">
                        <input type="number" class="form-control" id="pf_experienceYears"
                               name="pf_experienceYears" min="0" max="60" placeholder="0"
                               value="${fn:escapeXml(vExperience)}">
                        <span class="input-group-text">năm</span>
                    </div>
                </div>
                <div class="col-md-8">
                    <label for="pf_qualification" class="form-label fw-semibold">Chứng chỉ siêu âm</label>
                    <input type="text" class="form-control" id="pf_qualification"
                           name="pf_qualification" maxlength="100"
                           value="${fn:escapeXml(vQualif)}"
                           placeholder="VD: Chứng chỉ siêu âm sản phụ khoa — Bệnh viện Từ Dũ, 2022">
                    <div class="form-text">Tối đa 100 ký tự.</div>
                </div>
            </div>

            <div class="mb-3">
                <label for="pf_bio" class="form-label fw-semibold">Giới thiệu bản thân</label>
                <textarea class="form-control" id="pf_bio" name="pf_bio" rows="4" maxlength="2000"
                          placeholder="Mô tả kinh nghiệm, thế mạnh chuyên môn…">${fn:escapeXml(vBio)}</textarea>
                <div class="form-text">Tối đa 2000 ký tự.</div>
            </div>

            <div class="mb-4">
                <label for="pf_avatarFile" class="form-label fw-semibold">Ảnh đại diện</label>
                <div class="d-flex align-items-center gap-3">
                    <img id="pfAvatarPreview"
                         src="${fn:escapeXml(pf_profile.avatarUrl)}" alt="Ảnh đại diện"
                         class="rounded-circle border"
                         style="width:72px;height:72px;object-fit:cover;${empty pf_profile.avatarUrl ? 'display:none;' : ''}"
                         onerror="this.style.display='none'">
                    <div class="flex-grow-1">
                        <input type="file" class="form-control" id="pf_avatarFile" name="pf_avatarFile"
                               accept="image/jpeg,image/png,image/webp"
                               onchange="pfPreviewAvatar(this)">
                        <div class="form-text">
                            Chọn ảnh từ máy tính (JPG, PNG hoặc WEBP, tối đa 5MB).
                            Nếu không chọn ảnh mới, ảnh hiện tại sẽ được giữ nguyên.
                        </div>
                    </div>
                </div>
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary fw-bold px-4 rounded-pill">
                    <i class="bi bi-save me-1"></i>Lưu thay đổi
                </button>
                <a href="${pageContext.request.contextPath}/sonographer/dashboard"
                   class="btn btn-outline-secondary rounded-pill px-4">Hủy</a>
            </div>
        </form>
    </div>
</div>

<%-- ── Card + modal đổi mật khẩu (dùng chung) ─────────────────────────── --%>
<c:set var="pfPasswordRedirect" value="${pageContext.request.contextPath}/sonographer/profile" />
<%@ include file="../common/profile-password-card.jspf" %>

<script>
  function pfPreviewAvatar(input) {
    var img = document.getElementById('pfAvatarPreview');
    var file = input.files && input.files[0];
    if (!file) return;

    // Kiểm tra dung lượng ngay phía client — khớp giới hạn 5MB validate ở server
    if (file.size > 5 * 1024 * 1024) {
      alert('Kích thước ảnh không được vượt quá 5MB.');
      input.value = '';
      return;
    }

    var reader = new FileReader();
    reader.onload = function (e) {
      img.src = e.target.result;
      img.style.display = '';
    };
    reader.readAsDataURL(file);
  }
  // Việc mở lại modal khi đổi mật khẩu lỗi do profile-password-card.jspf lo,
  // dùng chung cho cả ba vai trò — không lặp lại ở đây.
</script>

<%@ include file="../common/footer.jsp" %>
