<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thay Đổi Lịch Khám - CAMS Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet">
</head>
<body>

<!-- Top Header Bar -->
<div class="top-header">
    <a href="${pageContext.request.contextPath}/admin/reception" class="header-left text-decoration-none">
        <div class="header-logo-icon">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path d="M19 10.5H13.5V5C13.5 4.45 13.05 4 12.5 4H11.5C10.95 4 10.5 4.45 10.5 5V10.5H5C4.45 10.5 4 10.95 4 11.5V12.5C4 13.05 4.45 13.5 5 13.5H10.5V19C10.5 19.55 10.95 20 11.5 20H12.5C13.05 20 13.5 19.55 13.5 19V13.5H19C19.55 13.5 20 13.05 20 12.5V11.5C20 10.95 19.55 10.5 19 10.5Z"/>
            </svg>
        </div>
        <div class="header-brand-name">CAMS</div>
        <span class="header-role-badge">STAFF</span>
    </a>

    <div class="header-right">
        <div class="header-date-pill">
            <i class="bi bi-calendar-event"></i>
            <span>06 tháng 06, 2026</span>
        </div>
        <div class="header-user-badge">
            <div class="header-avatar-circle">T</div>
            <span class="header-display-name">Hoàng Văn Tân</span>
            <span class="header-role-label">LỄ TÂN</span>
        </div>
        <a href="${pageContext.request.contextPath}/admin/reception" class="btn-header-logout">
            <i class="bi bi-box-arrow-right"></i> Đăng xuất
        </a>
    </div>
</div>

<div class="wrapper">
    <!-- Left Sidebar -->
    <div class="sidebar">
        <div class="sidebar-profile">
            <div class="sidebar-avatar">T</div>
            <h6 class="sidebar-name">Hoàng Văn Tân</h6>
            <span class="sidebar-role-badge">LỄ TÂN / CALL CENTER</span>
        </div>

        <div class="sidebar-menu">
            <div class="menu-section-title">Tổng quan</div>
            <a href="${pageContext.request.contextPath}/admin/reception" class="menu-item">
                <i class="bi bi-speedometer2"></i> Hàng Đợi Tiếp Đón
            </a>

            <div class="menu-section-title">Quản lý tiếp đón</div>
            <a href="${pageContext.request.contextPath}/admin/reception/booking" class="menu-item">
                <i class="bi bi-calendar-plus"></i> Đặt Lịch Thủ Công
            </a>
            <a href="${pageContext.request.contextPath}/admin/reception/sos" class="menu-item">
                <i class="bi bi-bell-slash text-danger"></i> Giám Sát Cảnh Báo SOS
                <c:if test="${activeSos > 0}">
                    <span class="badge bg-danger ms-2"><c:out value="${activeSos}"/></span>
                </c:if>
            </a>
        </div>
    </div>

    <!-- Main Content Area -->
    <div class="main-content">
        <!-- Page Title Row -->
        <div class="page-title-row">
            <div>
                <h3 class="page-title">Thay Đổi Lịch Khám</h3>
                <span class="page-subtitle">Quản lý Tiếp đón &gt; Sửa đổi thông tin lịch hẹn #${apt.id}</span>
            </div>
        </div>

        <div class="cams-card">
            <div class="cams-card-header">
                <h5 class="cams-card-title"><i class="bi bi-pencil-square"></i> Điều chỉnh thời gian, bác sĩ hoặc gói khám</h5>
            </div>
            <div class="cams-card-body">
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
                            <label class="cams-form-label">Bác sĩ khám chỉ định <span class="text-danger">*</span></label>
                            <select name="doctorId" id="doctorId" class="cams-form-input" required onchange="updatePriceDisplay()">
                                <c:forEach var="doc" items="${doctors}">
                                    <option value="${doc.id}">
                                        <c:out value="${doc.name}"/> - <c:out value="${doc.specialization}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6 cams-form-group">
                            <label class="cams-form-label">Gói dịch vụ ban đầu <span class="text-danger">*</span></label>
                            <select name="serviceId" id="serviceId" class="cams-form-input" required onchange="updatePriceDisplay()">
                                <c:forEach var="srv" items="${services}">
                                    <option value="${srv.id}" data-price="${srv.price}" <c:if test="${apt.service != null && apt.service.id == srv.id}">selected</c:if>>
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
                                   onchange="calculateLMPAge()"
                                   oninput="calculateLMPAge()">
                        </div>
                        <div class="col-md-4 cams-form-group">
                            <label class="cams-form-label">Khung giờ trống (Slots) <span class="text-danger">*</span></label>
                            <select name="timeSlot" id="timeSlot" class="cams-form-input" required>
                                <option value="08:00 - 08:20" <c:if test="${apt.timeSlot == '08:00 - 08:20'}">selected</c:if>>08:00 - 08:20</option>
                                <option value="08:20 - 08:40" <c:if test="${apt.timeSlot == '08:20 - 08:40'}">selected</c:if>>08:20 - 08:40</option>
                                <option value="08:40 - 09:00" <c:if test="${apt.timeSlot == '08:40 - 09:00'}">selected</c:if>>08:40 - 09:00</option>
                                <option value="09:00 - 09:20" <c:if test="${apt.timeSlot == '09:00 - 09:20'}">selected</c:if>>09:00 - 09:20</option>
                                <option value="09:20 - 09:40" <c:if test="${apt.timeSlot == '09:20 - 09:40'}">selected</c:if>>09:20 - 09:40</option>
                                <option value="09:40 - 10:00" <c:if test="${apt.timeSlot == '09:40 - 10:00'}">selected</c:if>>09:40 - 10:00</option>
                                <option value="10:00 - 10:20" <c:if test="${apt.timeSlot == '10:00 - 10:20'}">selected</c:if>>10:00 - 10:20</option>
                                <option value="10:20 - 10:40" <c:if test="${apt.timeSlot == '10:20 - 10:40'}">selected</c:if>>10:20 - 10:40</option>
                                <option value="10:40 - 11:00" <c:if test="${apt.timeSlot == '10:40 - 11:00'}">selected</c:if>>10:40 - 11:00</option>
                            </select>
                            <small class="text-muted mt-1 d-block">Mỗi slot khám kéo dài mặc định 20 phút.</small>
                        </div>
                        <div class="col-md-4 cams-form-group">
                            <label class="cams-form-label">Tổng chi phí tạm tính</label>
                            <div class="alert alert-info py-2 px-3 m-0 fw-bold fs-5 text-pink" id="total-price-box" style="border-color: var(--cams-border-pink); color: var(--cams-deep-pink);">
                                0đ
                            </div>
                        </div>
                    </div>

                    <hr class="my-3 text-muted">

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
    </div>
</div>

<script>
    function updatePriceDisplay() {
        let docSelect = document.getElementById("doctorId");
        let srvSelect = document.getElementById("serviceId");

        let srvPrice = 0;

        if (srvSelect.selectedIndex > 0) {
            srvPrice = parseFloat(srvSelect.options[srvSelect.selectedIndex].getAttribute("data-price")) || 0;
        }

        let total = srvPrice;
        document.getElementById("total-price-box").innerText = total.toLocaleString('vi-VN') + "đ";
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

    window.onload = function() {
        updatePriceDisplay();
        let lmpVal = document.getElementById("lastMenstrualPeriod").value;
        if (lmpVal) {
            calculateLMPAge();
        }
    };
</script>

</body>
</html>
