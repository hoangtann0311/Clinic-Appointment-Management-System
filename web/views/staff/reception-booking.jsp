<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt Lịch Thủ Công - CAMS Lễ Tân</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/app-ui.css?v=202" rel="stylesheet">
    <script src="${pageContext.request.contextPath}/assets/js/app-ui.js?v=1" charset="UTF-8" defer></script>
</head>
<body class="admin-body">

<c:set var="requestURI" value="${pageContext.request.servletPath}" />

<!-- Top Header Bar (spans 100vw) -->
<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/admin/reception" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i>
            CAMS
            <span class="brand-badge">Lễ Tân</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="topbar-date d-none d-lg-flex">
            <i class="bi bi-calendar3"></i>
            ${not empty currentDisplayDate ? currentDisplayDate : 'Hôm nay'}
        </div>
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">
                ${fn:substring(sessionScope.user.fullName, 0, 1)}
            </div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role">
                <i class="bi bi-shield-check me-1"></i>Lễ Tân
            </span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout" title="Đăng xuất">
            <i class="bi bi-box-arrow-right"></i>
            <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
    </div>
</nav>

<div class="wrapper">
    <!-- Sidebar Backdrop (mobile) -->
    <div class="admin-sidebar-backdrop" id="sidebarBackdrop" onclick="closeSidebar()"></div>

    <!-- Left Sidebar -->
    <aside class="admin-sidebar" id="adminSidebar">
        <div class="admin-sidebar-user">
            <div class="admin-sidebar-avatar">
                ${fn:substring(sessionScope.user.fullName, 0, 1)}
            </div>
            <div class="admin-sidebar-name">${sessionScope.user.fullName}</div>
            <span class="admin-sidebar-badge">
                <i class="bi bi-shield-check"></i>LỄ TÂN / CALL CENTER
            </span>
        </div>

        <ul class="admin-sidebar-menu">
            <li class="admin-sidebar-section">Tổng quan</li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception" 
                   class="${fn:contains(requestURI, '/reception') && !fn:contains(requestURI, 'booking') ? 'active' : ''}">
                    <i class="bi bi-speedometer2"></i>
                    <span>Hàng Đợi Tiếp Đón</span>
                </a>
            </li>

            <li class="admin-sidebar-section">Quản lý tiếp đón</li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/booking" 
                   class="${fn:contains(requestURI, 'booking') ? 'active' : ''}">
                    <i class="bi bi-calendar-plus"></i>
                    <span>Đặt Lịch Thủ Công</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/doctor-schedules"
                   class="${fn:contains(requestURI, 'doctor-schedules') ? 'active' : ''}">
                    <i class="bi bi-calendar-week"></i>
                    <span>Lịch Làm Việc Bác Sĩ</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/slots"
                   class="${fn:contains(requestURI, '/slots') ? 'active' : ''}">
                    <i class="bi bi-grid-3x3-gap"></i>
                    <span>Khung Giờ Khám</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/admin/reception/payments" 
                   class="${fn:contains(requestURI, 'payments') ? 'active' : ''}">
                    <i class="bi bi-credit-card-2-front"></i>
                    <span>Xác Nhận Thanh Toán</span>
                </a>
            </li>
        </ul>
    </aside>

    <!-- Main Content Area -->
    <main class="admin-main" id="adminMain">
        <!-- Page Title Row -->
        <div class="admin-page-header">
            <div class="admin-page-header-left">
                <h1 class="admin-page-title">Đặt Lịch Khám</h1>
                <div class="admin-page-subtitle">
                    Quản lý Tiếp đón &gt; Đặt lịch thủ công
                </div>
            </div>
        </div>

        <div class="admin-card">
            <div class="card-header">
                <h5><i class="bi bi-calendar-plus"></i> Tiếp nhận cuộc gọi tổng đài & Tạo lịch hẹn khám (Manual Booking)</h5>
            </div>
            <div class="card-body">
                <p class="text-muted small mb-4"><span class="text-danger fw-bold">*</span> Thông tin bắt buộc để tạo lịch hẹn.</p>
                <c:if test="${not empty errors}">
                    <div class="alert alert-danger">
                        <strong>Không thể tạo lịch hẹn:</strong>
                        <ul class="mb-0 mt-2">
                            <c:forEach var="err" items="${errors}">
                                <li><c:out value="${err}"/></li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
                <form action="${pageContext.request.contextPath}/admin/reception/booking" method="post" onsubmit="return validateForm()">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">

                    <!-- Patient Search & Info -->
                    <div class="row">
                        <div class="col-md-4 cams-form-group">
                            <label class="cams-form-label">Số điện thoại sản phụ <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                                <input type="text"
                                       name="phone"
                                       id="phone"
                                       class="cams-form-input form-control"
                                       placeholder="Nhập SĐT để tìm hoặc tạo mới"
                                       required
                                       maxlength="11"
                                       value="${param.phone}"
                                       oninput="this.value = this.value.replace(/[^0-9]/g, ''); lookupPhone(this.value);">
                            </div>
                            <small id="patient-match-label" class="text-success fw-semibold mt-1 d-block" style="display:none;"></small>
                        </div>
                        <div class="col-md-4 cams-form-group">
                            <label class="cams-form-label">Họ và tên sản phụ <span class="text-danger">*</span></label>
                            <input type="text"
                                   name="name"
                                   id="name"
                                   class="cams-form-input"
                                   placeholder="Họ và tên sản phụ"
                                   required
                                   value="${param.name}"
                                   oninput="this.value = this.value.replace(/[0-9]/g, '');">
                        </div>
                        <div class="col-md-4 cams-form-group">
                            <label class="cams-form-label">Ngày sinh <span class="text-muted fw-normal">(nếu có)</span></label>
                            <input type="date"
                                   name="dob"
                                   id="dob"
                                   class="cams-form-input"
                                   value="${param.dob}"
                                   max="<%= java.time.LocalDate.now() %>"
                                   onchange="validateDob()"
                                   oninput="validateDob()">
                            <small id="dobError" class="cams-field-error"></small>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-12 cams-form-group">
                            <label class="cams-form-label">Địa chỉ <span class="text-muted fw-normal">(nếu có)</span></label>
                            <input type="text" name="address" id="address" class="cams-form-input" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành" value="${param.address}">
                        </div>
                    </div>

                    <hr class="my-3 text-muted">

                    <!-- Appointment config -->
                    <div class="row">
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label">Bác sĩ lâm sàng chỉ định <span class="text-danger">*</span></label>
                            <select name="doctorId" id="doctorId" class="cams-form-input" required onchange="onDoctorOrDateChanged()">
                                <option value="" disabled ${empty param.doctorId ? 'selected' : ''}>-- Chọn Bác sĩ lâm sàng --</option>

                                <c:forEach var="doc" items="${doctors}">
                                    <c:set var="wl" value="${not empty doctorWorkload ? doctorWorkload[doc.id] : 0}"/>
                                    <option value="${doc.id}" ${param.doctorId == doc.id ? 'selected' : ''}>
                                        <c:out value="${doc.fullName}"/> — <c:out value="${doc.specialization}"/> <c:if test="${wl > 0}">(🔴 ${wl} BN hôm nay)</c:if>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label">Gói dịch vụ ban đầu <span class="text-danger">*</span></label>
                            <select name="serviceId" id="serviceId" class="cams-form-input" required onchange="updatePriceDisplay()">
                                <option value="" disabled ${empty param.serviceId ? 'selected' : ''}>-- Chọn dịch vụ --</option>

                                <c:forEach var="srv" items="${services}">
                                    <option value="${srv.id}"
                                            data-price="${srv.price}"
                                        ${param.serviceId == srv.id ? 'selected' : ''}>
                                        <c:out value="${srv.serviceName}"/>
                                        (<fmt:formatNumber value="${srv.price}" pattern="#,###"/>đ - <c:out value="${srv.durationMins}"/> phút)
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-4 cams-form-group">
                            <label class="cams-form-label">Ngày hẹn khám <span class="text-danger">*</span></label>
                            <input type="date"
                                   name="appointmentDate"
                                   id="appointmentDate"
                                   class="cams-form-input"
                                   min="${today}"
                                   value="${empty param.appointmentDate ? today : param.appointmentDate}"
                                   required
                                   onchange="onDoctorOrDateChanged(); calculateLMPAge()"
                                   oninput="calculateLMPAge()">
                        </div>
                        <div class="col-md-4 cams-form-group">
                            <label class="cams-form-label">Khung giờ khám <span class="text-danger">*</span></label>

                            <select name="timeSlot" id="timeSlot" class="cams-form-input" required>
                                <option value="" disabled ${empty param.timeSlot ? 'selected' : ''}>-- Chọn khung giờ --</option>
                            </select>

                            <small class="text-muted mt-1 d-block">Chọn bác sĩ và ngày khám để tải các khung giờ còn trống.</small>
                        </div>
                        <div class="col-md-4 cams-form-group">
                            <label class="cams-form-label">Tổng chi phí tạm tính</label>
                            <div class="alert alert-info py-2 px-3 m-0 fw-bold fs-5 text-pink" id="total-price-box" style="border-color: var(--c-outline-variant); color: var(--c-primary-dark); background: var(--pink-50);">
                                0đ
                            </div>
                        </div>
                    </div>

                    <hr class="my-3 text-muted">

                    <!-- Gestational Age & Medical Declarations -->
                    <div class="row">
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label">Ngày kinh cuối cùng (LMP) <span class="text-muted fw-normal">(nếu nhớ)</span></label>
                            <input type="date"
                                   name="lastMenstrualPeriod"
                                   id="lastMenstrualPeriod"
                                   class="cams-form-input"
                                   value="${param.lastMenstrualPeriod}"
                                   onchange="calculateLMPAge()"
                                   oninput="calculateLMPAge()">
                            <div class="alert alert-warning py-2 px-3 mt-2 fw-semibold" id="lmp-age-result" style="display:none;">
                                <strong>Tuổi thai ước tính:</strong>
                                <span class="text-danger" id="lmp-age-val">Chưa khai báo</span>
                            </div>
                            <small class="text-muted d-block mt-1">Hệ thống sẽ tự động quy đổi tuần tuổi thai nhi dựa trên LMP.</small>
                        </div>
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label">Triệu chứng lâm sàng / Lý do khám <span class="text-danger">*</span></label>
                            <textarea name="symptoms"
                                      id="symptoms"
                                      rows="3"
                                      class="cams-form-input"
                                      placeholder="Ví dụ: Đau bụng âm ỉ, trễ kinh, khám thai định kỳ..."
                                      required
                                      minlength="10"
                                      maxlength="500"><c:out value="${param.symptoms}"/></textarea>
                            <small class="text-muted">
                                Vui lòng nhập triệu chứng/lý do khám rõ ràng, tối thiểu 10 ký tự.
                            </small>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-3 mt-4">
                        <a href="${pageContext.request.contextPath}/admin/reception" class="btn-cams btn-cams-secondary"><i class="bi bi-x-circle"></i> Hủy Bỏ</a>
                        <button type="submit" class="btn-cams btn-cams-primary"><i class="bi bi-calendar-check"></i> Hoàn Tất Đặt Lịch</button>
                    </div>

                </form>
            </div>
        </div>
    </main>
</div>

<script>
    const contextPath = "${pageContext.request.contextPath}";
    const selectedSlot = "${param.timeSlot}";
    let phoneLookupSequence = 0;

    function lookupPhone(val) {
        const phone = val.trim();
        const label = document.getElementById("patient-match-label");
        const nameInput = document.getElementById("name");
        const dobInput = document.getElementById("dob");
        const requestId = ++phoneLookupSequence;

        label.style.display = "none";
        nameInput.readOnly = false;
        dobInput.readOnly = false;
        if (!/^0\d{9,10}$/.test(phone)) return;

        fetch(contextPath + '/admin/reception/patient-lookup?phone=' + encodeURIComponent(phone))
            .then(function (res) { return res.ok ? res.json() : null; })
            .then(function (data) {
                if (requestId !== phoneLookupSequence || !data) return;
                if (data.exists) {
                    nameInput.value = data.fullName || '';
                    dobInput.value = data.dateOfBirth || '';
                    nameInput.readOnly = true;
                    dobInput.readOnly = true;
                    label.style.display = 'block';
                    label.innerHTML = '<i class="bi bi-person-check-fill"></i> Đã tìm thấy hồ sơ sản phụ; thông tin định danh được giữ nguyên.';
                }
            })
            .catch(function () { /* Có thể vẫn tạo mới hồ sơ sau khi gửi form. */ });
    }

    function updatePriceDisplay() {
        let srvSelect = document.getElementById("serviceId");

        let srvPrice = 0;

        if (srvSelect.selectedIndex > 0) {
            srvPrice = parseFloat(srvSelect.options[srvSelect.selectedIndex].getAttribute("data-price")) || 0;
        }

        let total = srvPrice;
        document.getElementById("total-price-box").innerText = total.toLocaleString('vi-VN') + "đ";
    }

    function onDoctorOrDateChanged() {
        updatePriceDisplay();
        loadAvailableSlots();
    }

    function loadAvailableSlots() {
        const doctorId = document.getElementById('doctorId').value;
        const date = document.getElementById('appointmentDate').value;
        const slotSelect = document.getElementById('timeSlot');

        if (!doctorId || !date) {
            slotSelect.innerHTML = '<option value="" selected>-- Chọn Bác sĩ lâm sàng và ngày khám trước --</option>';
            return;
        }

        slotSelect.disabled = true;
        slotSelect.innerHTML = '<option value="">Đang tải khung giờ trống...</option>';
        fetch(contextPath + '/patient/booking/slots?doctorId=' + encodeURIComponent(doctorId) + '&date=' + encodeURIComponent(date))
            .then(function (res) { return res.ok ? res.json() : Promise.reject(); })
            .then(function (slots) {
                let html = '<option value="" selected>-- Chọn khung giờ --</option>';
                if (slots && slots.length) {
                    slots.forEach(function (slot) {
                        const selected = selectedSlot && selectedSlot === slot.label ? ' selected' : '';
                        html += '<option value="' + slot.label + '"' + selected + '>' + slot.label + ' (còn trống)</option>';
                    });
                } else {
                    html += '<option value="" disabled>Không có khung giờ trống</option>';
                }
                slotSelect.innerHTML = html;
            })
            .catch(function () {
                slotSelect.innerHTML = '<option value="" selected>Không tải được khung giờ, vui lòng thử lại</option>';
                slotSelect.disabled = false;
            });
    }

    function calculateLMPAge() {
        let ageResultDiv = document.getElementById("lmp-age-result");
        let ageValSpan = document.getElementById("lmp-age-val");
        let lmpInput = document.getElementById("lastMenstrualPeriod");
        let appDateInput = document.getElementById("appointmentDate");

        if (!ageResultDiv || !ageValSpan || !lmpInput || !appDateInput) {
            return;
        }

        let lmpDateVal = lmpInput.value;
        let appDateVal = appDateInput.value;

        if (!lmpDateVal) {
            ageResultDiv.style.display = "none";
            ageValSpan.innerText = "Chưa khai báo";
            return;
        }

        if (!appDateVal) {
            ageResultDiv.style.display = "block";
            ageValSpan.innerText = "Vui lòng chọn ngày hẹn trước";
            return;
        }

        let lmp = new Date(lmpDateVal);
        let appDate = new Date(appDateVal);

        if (isNaN(lmp.getTime()) || isNaN(appDate.getTime())) {
            ageResultDiv.style.display = "block";
            ageValSpan.innerText = "Ngày không hợp lệ";
            return;
        }

        let diffTime = appDate.getTime() - lmp.getTime();
        let diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

        ageResultDiv.style.display = "block";

        if (diffDays < 0) {
            ageValSpan.innerText = "LMP sau ngày hẹn";
            return;
        }

        let weeks = Math.floor(diffDays / 7);
        let days = diffDays % 7;

        if (weeks > 42) {
            ageValSpan.innerText = weeks + " tuần " + days + " ngày - Cảnh báo: LMP quá xa ngày hẹn";
            return;
        }

        ageValSpan.innerText = weeks + " tuần " + days + " ngày";
    }

    function validateForm() {
        let phone = document.getElementById("phone").value.trim();
        let name = document.getElementById("name").value.trim();
        let doc = document.getElementById("doctorId").value;
        let srv = document.getElementById("serviceId").value;

        if (!validateDob()) {
            return false;
        }
        let slot = document.getElementById("timeSlot").value;
        if (!phone || !name || !doc || !srv || !slot) {
            alert("Vui lòng điền đầy đủ thông tin bắt buộc!");
            return false;
        }

        // Phone: digits only, length 9 to 11
        let phoneRegex = /^0\d{9,10}$/;
        if (!phoneRegex.test(phone)) {
            alert("Số điện thoại phải bắt đầu bằng 0 và có 10-11 chữ số!");
            return false;
        }

        // Name: letters and spaces only (Vietnamese accents allowed)
        let nameRegex = /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚÝàáâãèéêìíòóôõùúýĂăĐđĨĩŨũƠơƯưẠ-ỹ\s]+$/;
        if (!nameRegex.test(name)) {
            alert("Họ và tên chỉ được chứa chữ cái và khoảng trắng, không chứa số hay ký tự đặc biệt!");
            return false;
        }
        let lmpVal = document.getElementById("lastMenstrualPeriod").value;
        let appDateVal = document.getElementById("appointmentDate").value;

        if (lmpVal && appDateVal) {
            let lmp = new Date(lmpVal);
            let appDate = new Date(appDateVal);
            let diffDays = Math.floor((appDate.getTime() - lmp.getTime()) / (1000 * 60 * 60 * 24));
            let weeks = Math.floor(diffDays / 7);

            if (diffDays < 0) {
                alert("Ngày kinh cuối không được sau ngày hẹn khám!");
                return false;
            }

            if (weeks > 42) {
                alert("Tuổi thai vượt quá 42 tuần. Vui lòng kiểm tra lại ngày kinh cuối cùng (LMP).");
                return false;
            }
        }
        let symptoms = document.getElementById("symptoms").value.trim();

        if (!symptoms) {
            alert("Vui lòng nhập triệu chứng lâm sàng hoặc lý do khám!");
            return false;
        }

        if (symptoms.length < 10) {
            alert("Triệu chứng/lý do khám quá ngắn. Vui lòng nhập rõ hơn, tối thiểu 10 ký tự!");
            return false;
        }

        let symptomRegex = /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚÝàáâãèéêìíòóôõùúýĂăĐđĨĩŨũƠơƯưẠ-ỹ0-9\s,.()/-]+$/;

        if (!symptomRegex.test(symptoms)) {
            alert("Triệu chứng/lý do khám không được chứa ký tự đặc biệt không hợp lệ!");
            return false;
        }

        let onlyNumberRegex = /^[0-9\s]+$/;
        if (onlyNumberRegex.test(symptoms)) {
            alert("Triệu chứng/lý do khám không được chỉ chứa số!");
            return false;
        }

        let repeatedCharRegex = /(.)\1{5,}/;
        if (repeatedCharRegex.test(symptoms.toLowerCase())) {
            alert("Triệu chứng/lý do khám không hợp lệ, vui lòng nhập nội dung rõ ràng hơn!");
            return false;
        }

        let words = symptoms.split(/\s+/);
        if (words.length < 2) {
            alert("Triệu chứng/lý do khám cần có ít nhất 2 từ, ví dụ: đau bụng, trễ kinh, khám thai định kỳ.");
            return false;
        }
        return true;
    }

    function validateDob() {
        let dobInput = document.getElementById("dob");
        let dobError = document.getElementById("dobError");

        if (!dobInput || !dobError) {
            return true;
        }

        let dobValue = dobInput.value;

        dobError.style.display = "none";
        dobError.innerText = "";
        dobInput.classList.remove("is-invalid");

        if (!dobValue) {
            return true;
        }

        let dob = new Date(dobValue);
        let today = new Date();

        dob.setHours(0, 0, 0, 0);
        today.setHours(0, 0, 0, 0);

        if (isNaN(dob.getTime())) {
            dobError.innerText = "Ngày sinh sản phụ không hợp lệ.";
            dobError.style.display = "block";
            dobInput.classList.add("is-invalid");
            return false;
        }

        if (dob > today) {
            dobError.innerText = "Ngày sinh sản phụ không được lớn hơn ngày hiện tại.";
            dobError.style.display = "block";
            dobInput.classList.add("is-invalid");
            return false;
        }

        let age = today.getFullYear() - dob.getFullYear();
        let monthDiff = today.getMonth() - dob.getMonth();
        let dayDiff = today.getDate() - dob.getDate();

        if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
            age--;
        }

        if (age < 12) {
            dobError.innerText = "Tuổi sản phụ phải từ 12 tuổi trở lên để đặt lịch khám.";
            dobError.style.display = "block";
            dobInput.classList.add("is-invalid");
            return false;
        }

        if (age > 55) {
            dobError.innerText = "Tuổi sản phụ không được vượt quá 55 tuổi khi đặt lịch khám sản/phụ khoa.";
            dobError.style.display = "block";
            dobInput.classList.add("is-invalid");
            return false;
        }

        return true;
    }

    document.addEventListener("DOMContentLoaded", function () {
        updatePriceDisplay();
        calculateLMPAge();

        validateDob();
        onDoctorOrDateChanged();
    });

    // Sidebar Toggle Script
    function openSidebar() {
        var s = document.getElementById('adminSidebar');
        var b = document.getElementById('sidebarBackdrop');
        if (!s) return;
        s.classList.add('show');
        if (b) b.classList.add('show');
        document.body.style.overflow = 'hidden';
    }
    function closeSidebar() {
        var s = document.getElementById('adminSidebar');
        var b = document.getElementById('sidebarBackdrop');
        if (!s) return;
        s.classList.remove('show');
        if (b) b.classList.remove('show');
        document.body.style.overflow = '';
    }
    function toggleSidebar() {
        var s = document.getElementById('adminSidebar');
        if (!s) return;
        s.classList.contains('show') ? closeSidebar() : openSidebar();
    }
    var toggleBtn = document.getElementById('sidebarToggle');
    if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeSidebar();
    });
</script>
</body>
</html>
