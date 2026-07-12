<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Banner ──────────────────────────────────────────────────────────── --%>
<div class="row mb-4">
  <div class="col-12">
    <div class="card border-0 rounded-4"
         style="background:linear-gradient(135deg,#e91e8c,#c2185b);color:#fff;">
      <div class="card-body p-4 d-flex align-items-center gap-4 flex-wrap">
        <%-- Avatar --%>
        <div class="flex-shrink-0">
          <c:choose>
            <c:when test="${not empty doctor.avatarUrl}">
              <img src="${doctor.avatarUrl}" alt="Avatar"
                   class="rounded-circle border border-3 border-white shadow"
                   style="width:80px;height:80px;object-fit:cover;"
                   onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
              <div class="rounded-circle bg-white d-none align-items-center justify-content-center"
                   style="width:80px;height:80px;font-size:2rem;color:#e91e8c;font-weight:700;">
                ${fn:substring(doctor.fullName,0,1)}
              </div>
            </c:when>
            <c:otherwise>
              <div class="rounded-circle bg-white d-flex align-items-center justify-content-center"
                   style="width:80px;height:80px;font-size:2rem;color:#e91e8c;font-weight:700;">
                ${fn:substring(doctor.fullName,0,1)}
              </div>
            </c:otherwise>
          </c:choose>
        </div>
        <div>
          <h2 class="fw-bold mb-1">BS. ${doctor.fullName}</h2>
          <p class="mb-0 opacity-75">
            ${not empty doctor.specialization ? doctor.specialization : 'Chưa cập nhật chuyên khoa'}
            <c:if test="${not empty doctor.degree}"> — ${doctor.degree}</c:if>
          </p>
        </div>
      </div>
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

<div class="row g-4">

  <%-- ── Form cập nhật hồ sơ ───────────────────────────────────────────── --%>
  <div class="col-12">
    <div class="card border-0 rounded-4 shadow-sm">
      <div class="card-body p-4">
        <h6 class="fw-bold mb-4">
          <i class="bi bi-pencil-square me-1 text-primary"></i>Cập nhật hồ sơ
        </h6>

        <form method="post" action="${pageContext.request.contextPath}/doctor/profile"
              id="profileForm" novalidate>

          <div class="row g-3 mb-3">
            <div class="col-md-6">
              <label class="form-label fw-medium">
                Họ và tên <span class="text-danger">*</span>
              </label>
              <input type="text" name="fullName" class="form-control rounded-3"
                     value="${doctor.fullName}" required maxlength="100"
                     placeholder="VD: Nguyễn Văn A">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-medium">Số điện thoại</label>
              <input type="tel" name="phoneNumber" class="form-control rounded-3"
                     value="${doctor.phoneNumber}" maxlength="15"
                     placeholder="VD: 0901234567">
            </div>
          </div>

          <div class="row g-3 mb-3">
            <div class="col-md-6">
              <label class="form-label fw-medium">Chuyên khoa</label>
              <select name="specialization" class="form-select rounded-3">
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
              <label class="form-label fw-medium">Học vị / Bằng cấp</label>
              <select name="degree" class="form-select rounded-3">
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
            <label class="form-label fw-medium">Số năm kinh nghiệm</label>
            <div class="input-group" style="max-width:200px;">
              <input type="number" name="experienceYears" class="form-control rounded-start-3"
                     value="${doctor.experienceYears > 0 ? doctor.experienceYears : ''}"
                     min="0" max="60" placeholder="0">
              <span class="input-group-text rounded-end-3">năm</span>
            </div>
          </div>

          <div class="mb-3">
            <label class="form-label fw-medium">Giới thiệu bản thân</label>
            <textarea name="bio" class="form-control rounded-3" rows="4"
                      maxlength="2000"
                      placeholder="Mô tả kinh nghiệm, thế mạnh chuyên môn, phương châm điều trị…">${doctor.bio}</textarea>
            <div class="form-text">Tối đa 2000 ký tự. Hiển thị cho bệnh nhân khi đặt lịch.</div>
          </div>

          <div class="mb-4">
            <label class="form-label fw-medium">URL ảnh đại diện</label>
            <div class="input-group">
              <span class="input-group-text rounded-start-3">
                <i class="bi bi-image"></i>
              </span>
              <input type="url" name="avatarUrl" id="avatarUrlInput"
                     class="form-control rounded-end-3"
                     value="${doctor.avatarUrl}"
                     placeholder="https://..."
                     oninput="previewAvatar(this.value)">
            </div>
            <div class="mt-2" id="avatarPreview" style="${not empty doctor.avatarUrl ? '' : 'display:none;'}">
              <img id="avatarPreviewImg"
                   src="${doctor.avatarUrl}"
                   alt="Preview"
                   class="rounded-circle border"
                   style="width:64px;height:64px;object-fit:cover;"
                   onerror="this.style.opacity='.3'">
              <small class="text-muted ms-2">Xem trước</small>
            </div>
            <div class="form-text">Nhập URL ảnh trực tiếp (HTTPS). Khuyến nghị ảnh vuông tối thiểu 200×200px.</div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary rounded-pill px-4">
              <i class="bi bi-save me-1"></i>Lưu thay đổi
            </button>
            <a href="${pageContext.request.contextPath}/doctor/dashboard"
               class="btn btn-outline-secondary rounded-pill px-4">Hủy</a>
          </div>

        </form>
      </div>
    </div>
  </div>
</div>

<script>
  function previewAvatar(url) {
    var preview = document.getElementById('avatarPreview');
    var img     = document.getElementById('avatarPreviewImg');
    if (url && url.startsWith('http')) {
      img.src = url;
      preview.style.display = '';
    } else {
      preview.style.display = 'none';
    }
  }

  // Validate client-side
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
