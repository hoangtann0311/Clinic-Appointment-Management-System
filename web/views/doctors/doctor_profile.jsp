<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Page Header ────────────────────────────────────────────────────── --%>
<div class="admin-page-header fade-in-up">
    <div>
        <h1 class="admin-page-title">Hồ Sơ Cá Nhân</h1>
        <div class="admin-page-subtitle">
            <i class="bi bi-house-fill"></i>
            <a href="${pageContext.request.contextPath}/doctor/dashboard" style="color:inherit;text-decoration:none;">Dashboard</a>
            <i class="bi bi-chevron-right" style="font-size:.65rem;"></i>
            <span>Hồ Sơ</span>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/doctor/dashboard" class="btn-refresh">
        <i class="bi bi-arrow-left"></i> Quay lại
    </a>
</div>

<%-- ── Banner ───────────────────────────────────────────────────────────── --%>
<div class="doctor-page-banner fade-in-up">
    <div class="d-flex align-items-center gap-4 banner-content flex-wrap">
        <%-- Avatar --%>
        <c:choose>
            <c:when test="${not empty doctor.avatarUrl}">
                <img src="${doctor.avatarUrl}" alt="Avatar"
                     class="rounded-circle border border-3"
                     style="width:80px;height:80px;object-fit:cover;border-color:rgba(255,255,255,0.5)!important;"
                     onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                <div class="rounded-circle d-none align-items-center justify-content-center"
                     style="width:80px;height:80px;font-size:2rem;background:rgba(255,255,255,0.2);color:#fff;font-weight:700;">
                    ${fn:substring(doctor.fullName,0,1)}
                </div>
            </c:when>
            <c:otherwise>
                <div class="rounded-circle d-flex align-items-center justify-content-center"
                     style="width:80px;height:80px;font-size:2rem;background:rgba(255,255,255,0.2);color:#fff;font-weight:700;flex-shrink:0;">
                    ${fn:substring(doctor.fullName,0,1)}
                </div>
            </c:otherwise>
        </c:choose>
        <div>
            <h2>BS. ${doctor.fullName}</h2>
            <p>
                ${not empty doctor.specialization ? doctor.specialization : 'Chưa cập nhật chuyên khoa'}
                <c:if test="${not empty doctor.degree}"> — ${doctor.degree}</c:if>
            </p>
        </div>
    </div>
</div>

<%-- Flash messages --%>
<c:if test="${not empty param.saved}">
    <div class="alert alert-success rounded-3 mb-4 alert-dismissible fade show">
        <i class="bi bi-check-circle me-2"></i>Cập nhật hồ sơ thành công!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${not empty error}">
    <div class="alert alert-danger rounded-3 mb-4">
        <i class="bi bi-exclamation-triangle me-2"></i>${error}
    </div>
</c:if>

<%-- ── Form cập nhật hồ sơ ───────────────────────────────────────────── --%>
<div class="card admin-card fade-in-up">
    <div class="card-header">
        <h5><i class="bi bi-pencil-square"></i>Cập Nhật Hồ Sơ</h5>
    </div>
    <div class="card-body" style="padding: 1.5rem !important;">
        <form method="post" action="${pageContext.request.contextPath}/doctor/profile"
              id="profileForm" enctype="multipart/form-data" novalidate>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label class="doctor-form-label">Họ và tên <span class="text-danger">*</span></label>
                    <input type="text" name="fullName" class="form-control"
                           value="${doctor.fullName}" required maxlength="100"
                           placeholder="VD: Nguyễn Văn A">
                </div>
                <div class="col-md-6">
                    <label class="doctor-form-label">Số điện thoại</label>
                    <input type="tel" name="phoneNumber" class="form-control"
                           value="${doctor.phoneNumber}" maxlength="15"
                           placeholder="VD: 0901234567">
                </div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <label class="doctor-form-label">Chuyên khoa</label>
                    <select name="specialization" class="form-select">
                        <option value="">— Chọn chuyên khoa —</option>
                        <option value="Sản phụ khoa"  ${doctor.specialization == 'Sản phụ khoa'  ? 'selected' : ''}>Sản phụ khoa</option>
                        <option value="Nhi khoa"       ${doctor.specialization == 'Nhi khoa'       ? 'selected' : ''}>Nhi khoa</option>
                        <option value="Nội khoa"       ${doctor.specialization == 'Nội khoa'       ? 'selected' : ''}>Nội khoa</option>
                        <option value="Ngoại khoa"     ${doctor.specialization == 'Ngoại khoa'     ? 'selected' : ''}>Ngoại khoa</option>
                        <option value="Tim mạch"       ${doctor.specialization == 'Tim mạch'       ? 'selected' : ''}>Tim mạch</option>
                        <option value="Da liễu"        ${doctor.specialization == 'Da liễu'        ? 'selected' : ''}>Da liễu</option>
                        <option value="Thần kinh"      ${doctor.specialization == 'Thần kinh'      ? 'selected' : ''}>Thần kinh</option>
                        <option value="Mắt"            ${doctor.specialization == 'Mắt'            ? 'selected' : ''}>Mắt</option>
                        <option value="Tai mũi họng"   ${doctor.specialization == 'Tai mũi họng'   ? 'selected' : ''}>Tai mũi họng</option>
                        <option value="Răng hàm mặt"   ${doctor.specialization == 'Răng hàm mặt'   ? 'selected' : ''}>Răng hàm mặt</option>
                        <option value="Khác"           ${doctor.specialization == 'Khác'           ? 'selected' : ''}>Khác</option>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="doctor-form-label">Học vị / Bằng cấp</label>
                    <select name="degree" class="form-select">
                        <option value="">— Chọn học vị —</option>
                        <option value="Bác sĩ"      ${doctor.degree == 'Bác sĩ'      ? 'selected' : ''}>Bác sĩ</option>
                        <option value="Thạc sĩ"     ${doctor.degree == 'Thạc sĩ'     ? 'selected' : ''}>Thạc sĩ</option>
                        <option value="Tiến sĩ"     ${doctor.degree == 'Tiến sĩ'     ? 'selected' : ''}>Tiến sĩ</option>
                        <option value="Phó Giáo sư" ${doctor.degree == 'Phó Giáo sư' ? 'selected' : ''}>Phó Giáo sư</option>
                        <option value="Giáo sư"     ${doctor.degree == 'Giáo sư'     ? 'selected' : ''}>Giáo sư</option>
                        <option value="Bác sĩ CKI"  ${doctor.degree == 'Bác sĩ CKI'  ? 'selected' : ''}>Bác sĩ CKI</option>
                        <option value="Bác sĩ CKII" ${doctor.degree == 'Bác sĩ CKII' ? 'selected' : ''}>Bác sĩ CKII</option>
                    </select>
                </div>
            </div>

            <div class="mb-3">
                <label class="doctor-form-label">Số năm kinh nghiệm</label>
                <div class="input-group" style="max-width:200px;">
                    <input type="number" name="experienceYears" class="form-control"
                           value="${doctor.experienceYears > 0 ? doctor.experienceYears : ''}"
                           min="0" max="60" placeholder="0">
                    <span class="input-group-text">năm</span>
                </div>
            </div>

            <div class="mb-3">
                <label class="doctor-form-label">Giới thiệu bản thân</label>
                <textarea name="bio" class="form-control" rows="4"
                          maxlength="2000"
                          placeholder="Mô tả kinh nghiệm, thế mạnh chuyên môn, phương châm điều trị…">${doctor.bio}</textarea>
                <div class="form-text">Tối đa 2000 ký tự. Hiển thị cho bệnh nhân khi đặt lịch.</div>
            </div>

            <div class="mb-4">
                <label class="doctor-form-label">Ảnh đại diện</label>
                <div class="d-flex align-items-center gap-3">
                    <img id="avatarPreviewImg"
                         src="${not empty doctor.avatarUrl ? doctor.avatarUrl : ''}"
                         alt="Ảnh đại diện"
                         class="rounded-circle border"
                         style="width:72px;height:72px;object-fit:cover;${empty doctor.avatarUrl ? 'display:none;' : ''}"
                         onerror="this.style.display='none'">
                    <div class="flex-grow-1">
                        <input type="file" name="avatarFile" id="avatarFileInput"
                               class="form-control" accept="image/jpeg,image/png,image/webp"
                               onchange="previewAvatarFile(this)">
                        <div class="form-text">
                            Chọn ảnh từ máy tính (JPG, PNG hoặc WEBP, tối đa 5MB).
                            Nếu không chọn ảnh mới, ảnh đại diện hiện tại sẽ được giữ nguyên.
                        </div>
                    </div>
                </div>
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn fw-bold px-4 rounded-pill"
                        style="background:linear-gradient(135deg,var(--pink-600),var(--pink-500));color:#fff;border:none;box-shadow:var(--shadow-pink);">
                    <i class="bi bi-save me-1"></i>Lưu thay đổi
                </button>
                <a href="${pageContext.request.contextPath}/doctor/dashboard"
                   class="btn btn-outline-secondary rounded-pill px-4">Hủy</a>
            </div>

        </form>
    </div>
</div>

<script>
  function previewAvatarFile(input) {
    var img = document.getElementById('avatarPreviewImg');
    var file = input.files && input.files[0];
    if (!file) return;

    // Kiểm tra dung lượng ngay phía client (giới hạn 5MB — khớp validate phía server)
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

  document.getElementById('profileForm').addEventListener('submit', function(e) {
    var name = document.querySelector('[name="fullName"]').value.trim();
    if (!name) {
      e.preventDefault();
      alert('Vui lòng nhập họ tên.');
      return;
    }
    var phone = document.querySelector('[name="phoneNumber"]').value.trim();
    if (phone && !/^[0-9+\-\s]{7,15}$/.test(phone)) {
      e.preventDefault();
      alert('Số điện thoại không hợp lệ.');
    }
  });
</script>

<%@ include file="../common/footer.jsp" %>
