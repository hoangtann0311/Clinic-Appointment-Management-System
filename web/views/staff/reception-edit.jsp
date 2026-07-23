<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thay Đổi Lịch Khám - CAMS Lễ Tân</title>
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

<!-- Top Header Bar -->
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
            <span>06 tháng 06, 2026</span>
        </div>
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">
                ${fn:substring(sessionScope.user.fullName, 0, 1)}
            </div>
            <span class="header-display-name">Hoàng Văn Tân</span>
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
                   class="${fn:contains(requestURI, '/reception') && !fn:contains(requestURI, 'booking') && !fn:contains(requestURI, 'sos') ? 'active' : ''}">
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
                <h1 class="admin-page-title">Thay Đổi Lịch Khám</h1>
                <div class="admin-page-subtitle">
                    Quản lý Tiếp đón &gt; Sửa đổi thông tin lịch hẹn
                </div>
            </div>
        </div>

        <div class="admin-card">
            <div class="card-header">
                <h5><i class="bi bi-pencil-square"></i> Điều chỉnh thời gian, Bác sĩ lâm sàng hoặc gói khám</h5>
            </div>
            <div class="card-body">
                <c:if test="${not empty errors}">
                    <div class="alert alert-danger">
                        <strong>Không thể cập nhật lịch hẹn:</strong>
                        <ul class="mb-0 mt-2">
                            <c:forEach var="err" items="${errors}">
                                <li><c:out value="${err}"/></li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
                <form action="${pageContext.request.contextPath}/admin/reception/edit" method="post" onsubmit="return validateForm()">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="id" value="${apt.id}">
                    
                    <!-- Patient Search & Info (Read Only) -->
                    <div class="row">
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label text-muted">Họ và tên sản phụ (Không được sửa)</label>
                            <input type="text" class="cams-form-input bg-light" value="${apt.patientName}" readonly>
                        </div>
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label text-muted">Số điện thoại liên lạc (Không được sửa)</label>
                            <input type="text" class="cams-form-input bg-light" value="${apt.patient != null ? apt.patient.phone : ''}" readonly>
                        </div>
                    </div>

                    <hr class="my-3 text-muted">

                    <!-- Appointment config -->
                    <div class="row">
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label">Bác sĩ lâm sàng chỉ định <span class="text-danger">*</span></label>
                            <select name="doctorId" id="doctorId" class="cams-form-input" required onchange="onDoctorOrDateChanged()">
                                <c:forEach var="doc" items="${doctors}">
                                    <option value="${doc.id}" ${(apt.doctor != null && apt.doctor.id eq doc.id) ? 'selected' : ''}>
                                        <c:out value="${doc.name}"/> - <c:out value="${doc.specialization}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label">Gói dịch vụ ban đầu <span class="text-danger">*</span></label>
                            <select name="serviceId" id="serviceId" class="cams-form-input" required onchange="onDoctorOrDateChanged()">
                                <c:forEach var="srv" items="${services}">
                                    <option value="${srv.id}" data-price="${srv.price}"
                                            <c:if test="${(apt.service != null and apt.service.id eq srv.id) or (apt.service == null and apt.serviceName eq srv.serviceName)}">selected</c:if>>
                                        <c:out value="${srv.serviceName}"/> (<fmt:formatNumber value="${srv.price}" pattern="#,###"/>đ - <c:out value="${srv.durationMins}"/> phút)
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
                                   value="${apt.appointmentDate}"
                                   required
                                   onchange="onDoctorOrDateChanged(); calculateLMPAge();">
                        </div>
                        <div class="col-md-4 cams-form-group">
                            <label class="cams-form-label">Khung giờ còn trống <span class="text-danger">*</span></label>
                            <select name="timeSlot" id="timeSlot" class="cams-form-input" required onchange="onSlotChanged()">
                                <c:if test="${not empty apt.timeSlot}">
                                    <option value="${apt.timeSlot}" selected>${apt.timeSlot} (đã đặt)</option>
                                </c:if>
                                <option value="">-- Chọn khung giờ --</option>
                            </select>
                            <small class="text-muted mt-1 d-block">Mỗi khung giờ khám kéo dài mặc định 20 phút.</small>
                        </div>
                        <div class="col-md-4 cams-form-group">
                            <label class="cams-form-label">Tổng chi phí tạm tính</label>
                            <div class="alert alert-info py-2 px-3 m-0 fw-bold fs-5" id="total-price-box" style="border-color: var(--c-outline-variant); color: var(--c-primary-dark); background: var(--pink-50);">
                                0đ
                            </div>
                        </div>
                    </div>

                    <hr class="my-3 text-muted">

                    <c:if test="${not empty preInvoice}">
                        <div class="admin-card mb-3">
                            <div class="card-header bg-white py-3">
                                <h5 class="m-0 fw-bold text-dark d-flex align-items-center gap-2">
                                    <i class="bi bi-credit-card-2-front text-primary"></i>
                                    Thanh Toán Trước Khám
                                </h5>
                            </div>
                            <div class="card-body">
                                <c:if test="${not empty param.success}">
                                    <div class="alert alert-success"><i class="bi bi-check-circle-fill me-2"></i>Xác nhận thanh toán thành công!</div>
                                </c:if>
                                <c:if test="${not empty param.error}">
                                    <div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${param.error}"/></div>
                                </c:if>
                                <div class="row align-items-center">
                                    <div class="col-md-4">
                                        <label class="text-muted small fw-bold">MÃ HÓA ĐƠN</label>
                                        <div class="fw-bold">HĐ-${preInvoice.id}</div>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="text-muted small fw-bold">TỔNG TIỀN</label>
                                        <div class="fw-bold text-danger fs-5"><fmt:formatNumber value="${preInvoice.totalAmount}" pattern="#,###"/>đ</div>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="text-muted small fw-bold">TRẠNG THÁI</label>
                                        <div>
                                            <c:choose>
                                                <c:when test="${preInvoice.status == 'Paid'}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle">
                                                        <i class="bi bi-check-circle me-1"></i>Đã thanh toán
                                                    </span>
                                                </c:when>
                                                <c:when test="${preInvoice.status == 'PendingConfirmation'}">
                                                    <span class="badge bg-warning-subtle text-warning border border-warning-subtle">
                                                        <i class="bi bi-clock-history me-1"></i>Chờ xác nhận
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle">
                                                        <i class="bi bi-exclamation-circle me-1"></i>Chưa thanh toán
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                                <c:if test="${preInvoice.status == 'PendingConfirmation'}">
                                    <hr class="my-3">
                                    <form method="POST" action="${pageContext.request.contextPath}/admin/reception/edit">
                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="id" value="${apt.id}">
                                        <input type="hidden" name="action" value="confirmPayment">
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <label class="form-label text-muted small fw-bold">PHƯƠNG THỨC</label>
                                                <input type="hidden" name="paymentMethod" value="${preInvoice.paymentMethod}">
                                                <select class="form-select" disabled>
                                                    <option value="Cash" ${preInvoice.paymentMethod == 'Cash' ? 'selected' : ''}>Tiền mặt</option>
                                                    <option value="BankTransfer" ${preInvoice.paymentMethod == 'BankTransfer' ? 'selected' : ''}>Chuyển khoản</option>
                                                </select>
                                            </div>
                                            <div class="col-md-3" id="txCodeContainer" style="display: none;">
                                                <label class="form-label text-muted small fw-bold">MÃ GIAO DỊCH <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" name="transactionCode" placeholder="VD: FT24090...">
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label text-muted small fw-bold">GHI CHÚ</label>
                                                <input type="text" class="form-control" name="paymentNote" placeholder="Thông tin thêm...">
                                            </div>
                                            <div class="col-md-2 d-flex align-items-end">
                                                <button type="submit" class="btn btn-success fw-bold w-100">
                                                    <i class="bi bi-check-lg me-1"></i> Đã thanh toán
                                                </button>
                                            </div>
                                        </div>
                                    </form>
                                </c:if>
                            </div>
                        </div>
                    </c:if>

                    <!-- Gestational Age & Medical Declarations -->
                    <div class="row">
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label">Ngày kinh cuối cùng (LMP)</label>
                            <input type="date"
                                   name="lastMenstrualPeriod"
                                   id="lastMenstrualPeriod"
                                   class="cams-form-input"
                                   value="${apt.lastMenstrualPeriod}"
                                   onchange="calculateLMPAge()"
                                   oninput="calculateLMPAge()">
                            <div class="alert alert-warning py-2 px-3 mt-2 fw-semibold" id="lmp-age-result" style="display:none;">
                                Tuổi thai ước tính: <span class="text-danger" id="lmp-age-val">0 tuần 0 ngày</span>
                            </div>
                            <small class="text-muted d-block mt-1">Hệ thống sẽ tự động quy đổi tuần tuổi thai nhi dựa trên LMP.</small>
                        </div>
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label">Triệu chứng lâm sàng / Lý do khám <span class="text-danger">*</span></label>
                            <textarea name="symptoms"
                                      id="symptoms"
                                      rows="3"
                                      class="cams-form-input"
                                      required
                                      minlength="10"
                                      maxlength="500"><c:out value="${apt.symptoms}"/></textarea>

                            <small class="text-muted">
                                Vui lòng nhập triệu chứng/lý do khám rõ ràng, tối thiểu 10 ký tự.
                            </small>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-3 mt-4">
                        <a href="${pageContext.request.contextPath}/admin/reception" class="btn-cams btn-cams-secondary"><i class="bi bi-x-circle"></i> Hủy Bỏ</a>
                        <button type="submit" class="btn-cams btn-cams-primary"><i class="bi bi-calendar-check"></i> Lưu Thay Đổi</button>
                    </div>

                </form>
            </div>
        </div>
    </main>
</div>

<script>
    const contextPath = "${pageContext.request.contextPath}";

    function updatePriceDisplay() {
        let srvSelect = document.getElementById("serviceId");

        let srvPrice = 0;

        if (srvSelect.selectedIndex >= 0 && srvSelect.options[srvSelect.selectedIndex] != null) {
            srvPrice = parseFloat(srvSelect.options[srvSelect.selectedIndex].getAttribute("data-price")) || 0;
        }

        document.getElementById("total-price-box").innerText = srvPrice.toLocaleString('vi-VN') + "đ";
    }

    function onDoctorOrDateChanged() {
        updatePriceDisplay();
        loadAvailableSlots();
    }

    function loadAvailableSlots() {
        let doctorId = document.getElementById("doctorId").value;
        let date = document.getElementById("appointmentDate").value;
        let slotSelect = document.getElementById("timeSlot");

        if (!doctorId || !date) {
            slotSelect.innerHTML = '<option value="">-- Chọn khung giờ --</option>';
            return;
        }

        fetch(contextPath + '/patient/booking/slots?doctorId=' + doctorId + '&date=' + date)
            .then(function (res) { return res.json(); })
            .then(function (slots) {
                let html = '<option value="">-- Chọn khung giờ --</option>';
                let availableLabels = new Set();
                if (slots && slots.length > 0) {
                    slots.forEach(function (s) {
                        availableLabels.add(s.label);
                        html += '<option value="' + s.label + '">' + s.time + ' - ' + s.label.split(' - ')[1] + '</option>';
                    });
                } else {
                    html += '<option value="" disabled>Không có khung giờ trống</option>';
                }

                let currentSlot = "${apt.timeSlot}";
                if (currentSlot && !availableLabels.has(currentSlot)) {
                    html += '<option value="' + currentSlot + '" selected>' + currentSlot + ' (đã đặt)</option>';
                }

                slotSelect.innerHTML = html;

                if (currentSlot && availableLabels.has(currentSlot)) {
                    for (let i = 0; i < slotSelect.options.length; i++) {
                        if (slotSelect.options[i].value === currentSlot) {
                            slotSelect.selectedIndex = i;
                            break;
                        }
                    }
                }
            })
            .catch(function () {
                slotSelect.innerHTML = '<option value="">-- Chọn khung giờ --</option>';
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
        let doc = document.getElementById("doctorId").value;
        let srv = document.getElementById("serviceId").value;
        let symptoms = document.getElementById("symptoms").value.trim();

        if (!doc || !srv) {
            alert("Vui lòng điền đầy đủ thông tin bắt buộc!");
            return false;
        }

        if (!symptoms) {
            alert("Vui lòng nhập triệu chứng lâm sàng hoặc lý do khám!");
            return false;
        }

        if (symptoms.length < 10) {
            alert("Triệu chứng/lý do khám quá ngắn. Vui lòng nhập rõ hơn, tối thiểu 10 ký tự!");
            return false;
        }

        if (symptoms.length > 500) {
            alert("Triệu chứng/lý do khám không được vượt quá 500 ký tự!");
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

    function toggleTxCode(method) {
        const container = document.getElementById("txCodeContainer");
        const input = document.querySelector('input[name="transactionCode"]');
        if (method === "BankTransfer") {
            container.style.display = "block";
            if (input) input.focus();
        } else {
            container.style.display = "none";
            if (input) input.value = "";
        }
    }

    function validatePaymentForm() {
        const method = document.querySelector('select[name="paymentMethod"]').value;
        const txInput = document.querySelector('input[name="transactionCode"]');
        if (method === "BankTransfer" && (!txInput || txInput.value.trim() === "")) {
            if (txInput) txInput.classList.add("is-invalid");
            return false;
        }
        if (txInput) txInput.classList.remove("is-invalid");
        return true;
    }

    window.onload = function() {
        updatePriceDisplay();
        let lmpVal = document.getElementById("lastMenstrualPeriod").value;
        if (lmpVal) {
            calculateLMPAge();
        }
    };

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
