<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Giám Sát Cảnh Báo SOS - CAMS Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css" rel="stylesheet">
</head>
<body>

<!-- Top Header Bar (spans 100vw) -->
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
            <span><c:out value="${currentDisplayDate}"/></span>
        </div>
        <div class="header-user-badge">
            <div class="header-avatar-circle">T</div>
            <span class="header-display-name">Hoàng Văn Tân</span>
            <span class="header-role-label">LỄ TÂN</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="btn-header-logout">
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
            <a href="${pageContext.request.contextPath}/admin/reception/sos" class="menu-item active">
                <i class="bi bi-bell-slash text-danger"></i> Giám Sát Cảnh Báo SOS
                <c:if test="${activeSos > 0}">
                    <span class="badge bg-danger ms-2"><c:out value="${activeSos}"/></span>
                </c:if>
            </a>
        </div>
    </div>

    <!-- Main Content Area -->
    <div class="main-content flex-grow-1">
        <!-- Page Title Row -->
        <div class="page-title-row">
            <div>
                <h3 class="page-title">Giám Sát Cấp Cứu SOS</h3>
                <span class="page-subtitle">Quản lý tiếp đón &gt; Giám sát cảnh báo đỏ khẩn cấp</span>
            </div>
        </div>

        <!-- Layout split -->
        <div class="row">
            <div class="col-md-7">
                <!-- Active SOS alerts -->
                <div class="cams-card border border-danger border-2">
                    <div class="cams-card-header bg-danger text-white">
                        <h5 class="m-0 fw-bold d-flex align-items-center gap-2 text-white">
                            <i class="bi bi-exclamation-triangle-fill" style="animation: pulse-sos 1s infinite;"></i> 
                            Danh Sách Ca Báo Động Đỏ SOS Khẩn Cấp
                        </h5>
                    </div>
                    <div class="cams-card-body p-0">
                        <table class="table-cams">
                            <thead>
                                <tr class="table-danger">
                                    <th>STT Hẹn</th>
                                    <th>Tên Sản Phụ</th>
                                    <th>Triệu Chứng Nguy Hiểm</th>
                                    <th>Phòng Điều Phối Chỉ Định</th>
                                    <th>Hành Động Đón Tiếp</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="apt" items="${sosAppointments}">
                                    <tr class="sos-blink">
                                        <td><strong class="text-danger"><c:out value="${apt.queueNumber}"/></strong></td>
                                        <td>
                                            <strong class="text-danger fs-6"><c:out value="${apt.patientName}"/></strong><br>
                                            <small class="text-muted"><c:out value="${apt.patient != null ? apt.patient.phone : ''}"/></small>
                                        </td>
                                        <td class="text-start text-danger fw-bold"><c:out value="${apt.symptoms}"/></td>
                                        <td>
                                            <strong class="text-dark">Phòng Khám Sản 101</strong><br>
                                            <small class="text-muted">(BS. Trưởng Ca trực)</small>
                                        </td>
                                        <td>
                                            <form action="${pageContext.request.contextPath}/admin/reception/sos/dismiss" method="post">
                                                <input type="hidden" name="id" value="${apt.id}">
                                                <button type="submit" class="btn btn-danger btn-sm fw-bold px-3 py-2"><i class="bi bi-shield-fill-check"></i> TIẾP NHẬN NGAY</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty sosAppointments}">
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-4">Hiện không có ca cấp cứu SOS nào đang kích hoạt.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Manual SOS Trigger Form -->
                <div class="cams-card mt-4">
                    <div class="cams-card-header bg-white">
                        <h5 class="cams-card-title text-danger"><i class="bi bi-broadcast-pin text-danger"></i> Kích hoạt SOS khẩn cấp tại quầy</h5>
                    </div>
                    <div class="cams-card-body">
                        <c:if test="${not empty errors}">
                            <div class="alert alert-danger">
                                <strong>Không thể xử lý SOS:</strong>
                                <ul class="mb-0 mt-2">
                                    <c:forEach var="err" items="${errors}">
                                        <li><c:out value="${err}"/></li>
                                    </c:forEach>
                                </ul>
                            </div>
                        </c:if>
                        <p class="text-muted font-size-13 mb-3">Sử dụng trong trường hợp sản phụ đến trực tiếp tại quầy trong trạng thái nguy kịch để ngay lập tức chèn lên đầu hàng đợi và gửi chuông cảnh báo tới các bác sĩ trưởng ca.</p>
                        <form action="${pageContext.request.contextPath}/admin/reception/sos/trigger"
                              method="post"
                              onsubmit="return validateSosForm()">

                            <div class="row">
                                <div class="col-md-6 cams-form-group">
                                    <label class="cams-form-label text-danger fw-bold">
                                        Tên sản phụ <span class="text-danger">*</span>
                                    </label>

                                    <input type="text"
                                           name="name"
                                           id="sosName"
                                           class="cams-form-input ${not empty fieldErrors.name ? 'is-invalid' : ''}"
                                           value="${param.name}"
                                           placeholder="Họ tên sản phụ khẩn cấp"
                                           required
                                           oninput="validateSosName()">

                                    <small id="sosNameError" class="cams-field-error">
                                        <c:out value="${fieldErrors.name}"/>
                                    </small>
                                </div>

                                <div class="col-md-6 cams-form-group">
                                    <label class="cams-form-label text-danger fw-bold">
                                        Số điện thoại liên lạc <span class="text-danger">*</span>
                                    </label>

                                    <input type="text"
                                           name="phone"
                                           id="sosPhone"
                                           class="cams-form-input ${not empty fieldErrors.phone ? 'is-invalid' : ''}"
                                           value="${param.phone}"
                                           placeholder="SĐT liên hệ"
                                           required
                                           maxlength="11"
                                           oninput="this.value = this.value.replace(/[^0-9]/g, ''); validateSosPhone();">

                                    <small id="sosPhoneError" class="cams-field-error">
                                        <c:out value="${fieldErrors.phone}"/>
                                    </small>
                                </div>
                            </div>

                            <div class="cams-form-group">
                                <label class="cams-form-label text-danger fw-bold">
                                    Tình trạng lâm sàng khẩn cấp <span class="text-danger">*</span>
                                </label>

                                <textarea name="symptoms"
                                          id="sosSymptoms"
                                          rows="2"
                                          class="cams-form-input ${not empty fieldErrors.symptoms ? 'is-invalid' : ''}"
                                          placeholder="Ví dụ: Sản phụ đau thắt vùng bụng dữ dội, ra máu âm đạo nhiều..."
                                          required
                                          oninput="validateSosSymptoms()"><c:out value="${param.symptoms}"/></textarea>

                                <small id="sosSymptomsError" class="cams-field-error">
                                    <c:out value="${fieldErrors.symptoms}"/>
                                </small>
                            </div>

                            <div class="d-flex justify-content-end mt-3">
                                <button type="submit" class="btn btn-danger px-4 py-2 fw-bold shadow-sm">
                                    <i class="bi bi-megaphone-fill"></i> KÍCH HOẠT BÁO ĐỘNG ĐỎ
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- GPS Clinic Locator Simulation -->
            <div class="col-md-5">
                <div class="cams-card">
                    <div class="cams-card-header bg-white">
                        <h5 class="cams-card-title text-primary"><i class="bi bi-geo-alt-fill text-primary"></i> GPS Clinic Locator (Định vị ca khẩn cấp)</h5>
                    </div>
                    <div class="cams-card-body">
                        <p class="text-muted font-size-13">Hệ thống tự động quét và tính toán vị trí gần nhất từ sản phụ gửi báo động đỏ về để điều phối xe cấp cứu hoặc nhân sự túc trực sẵn sàng.</p>
                        
                        <!-- Map Visual Simulation (SVG) -->
                        <div class="bg-dark rounded-3 p-2 text-center shadow-inner mb-3" style="position: relative; height: 260px; background-color: #1a202c !important;">
                            <svg width="100%" height="100%" viewBox="0 0 400 250" xmlns="http://www.w3.org/2000/svg">
                                <line x1="0" y1="50" x2="400" y2="50" stroke="#2d3748" stroke-dasharray="5,5" />
                                <line x1="0" y1="100" x2="400" y2="100" stroke="#2d3748" stroke-dasharray="5,5" />
                                <line x1="0" y1="150" x2="400" y2="150" stroke="#2d3748" stroke-dasharray="5,5" />
                                <line x1="0" y1="200" x2="400" y2="200" stroke="#2d3748" stroke-dasharray="5,5" />
                                
                                <line x1="100" y1="0" x2="100" y2="250" stroke="#2d3748" stroke-dasharray="5,5" />
                                <line x1="200" y1="0" x2="200" y2="250" stroke="#2d3748" stroke-dasharray="5,5" />
                                <line x1="300" y1="0" x2="300" y2="250" stroke="#2d3748" stroke-dasharray="5,5" />

                                <circle cx="200" cy="125" r="14" fill="#005a9e" opacity="0.3" />
                                <circle cx="200" cy="125" r="7" fill="#0078d4" />
                                <text x="200" y="105" font-family="'Inter', sans-serif" font-size="11" font-weight="bold" fill="#63b3ed" text-anchor="middle">OCSS CLINIC (Phòng khám)</text>

                                <c:if test="${not empty sosAppointments}">
                                    <circle cx="290" cy="65" r="25" fill="#e53e3e" opacity="0.15">
                                        <animate attributeName="r" values="5;30" dur="2s" repeatCount="indefinite" />
                                        <animate attributeName="opacity" values="0.6;0" dur="2s" repeatCount="indefinite" />
                                    </circle>
                                    <circle cx="290" cy="65" r="6" fill="#e53e3e" />
                                    <path d="M200 125 L290 65" stroke="#e53e3e" stroke-width="2" stroke-dasharray="4,4">
                                        <animate attributeName="stroke-dashoffset" values="0;20" dur="1s" repeatCount="indefinite" />
                                    </path>
                                    <text x="290" y="45" font-family="'Inter', sans-serif" font-size="11" font-weight="bold" fill="#fc8181" text-anchor="middle">SẢN PHỤ SOS</text>
                                </c:if>
                            </svg>
                        </div>

                        <!-- Distance Calculations -->
                        <c:if test="${not empty sosAppointments}">
                            <div class="alert alert-danger p-3 mb-0" style="border-left: 4px solid #e53e3e;">
                                <h6 class="fw-bold text-danger m-0 mb-1"><i class="bi bi-pin-map-fill"></i> TÌM THẤY CA CẤP CỨU THAI SẢN GẦN NHẤT</h6>
                                <div class="row font-size-13 text-dark mt-2">
                                    <div class="col-6">
                                        <span class="text-muted d-block">Vị trí tương quan:</span>
                                        <strong>Cách phòng khám 1.2 km</strong>
                                    </div>
                                    <div class="col-6">
                                        <span class="text-muted d-block">Thời gian di chuyển dự kiến:</span>
                                        <strong>4 phút (Đang di chuyển bằng taxi)</strong>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                        <c:if test="${empty sosAppointments}">
                            <div class="alert alert-secondary p-3 mb-0">
                                <i class="bi bi-check-circle-fill text-success"></i> Tình trạng yên tĩnh. Không phát hiện xung điện định vị khẩn cấp.
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
    function setSosError(inputId, errorId, message) {
        const input = document.getElementById(inputId);
        const error = document.getElementById(errorId);

        if (!input || !error) return false;

        input.classList.add("is-invalid");
        error.innerText = message;
        error.style.display = "block";

        return false;
    }

    function clearSosError(inputId, errorId) {
        const input = document.getElementById(inputId);
        const error = document.getElementById(errorId);

        if (!input || !error) return true;

        input.classList.remove("is-invalid");
        error.innerText = "";
        error.style.display = "none";

        return true;
    }

    function validateSosName() {
        const name = document.getElementById("sosName").value.trim();

        if (!name) {
            return setSosError("sosName", "sosNameError", "Họ tên bệnh nhân không được để trống.");
        }

        const nameRegex = /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚÝàáâãèéêìíòóôõùúýĂăĐđĨĩŨũƠơƯưẠ-ỹ\s]+$/;
        if (!nameRegex.test(name)) {
            return setSosError("sosName", "sosNameError", "Họ tên chỉ được chứa chữ cái và khoảng trắng.");
        }

        return clearSosError("sosName", "sosNameError");
    }

    function validateSosPhone() {
        const phone = document.getElementById("sosPhone").value.trim();

        if (!phone) {
            return setSosError("sosPhone", "sosPhoneError", "Số điện thoại không được để trống.");
        }

        if (!/^0\d{9,10}$/.test(phone)) {
            return setSosError("sosPhone", "sosPhoneError", "Số điện thoại phải bắt đầu bằng 0 và có 10-11 chữ số.");
        }

        return clearSosError("sosPhone", "sosPhoneError");
    }

    function validateSosSymptoms() {
        const symptoms = document.getElementById("sosSymptoms").value.trim();

        if (!symptoms) {
            return setSosError("sosSymptoms", "sosSymptomsError", "Triệu chứng khẩn cấp không được để trống.");
        }

        if (symptoms.length < 5) {
            return setSosError("sosSymptoms", "sosSymptomsError", "Triệu chứng khẩn cấp quá ngắn, vui lòng nhập rõ hơn.");
        }

        if (symptoms.length > 500) {
            return setSosError("sosSymptoms", "sosSymptomsError", "Triệu chứng khẩn cấp không được vượt quá 500 ký tự.");
        }

        if (/^[0-9\s]+$/.test(symptoms)) {
            return setSosError("sosSymptoms", "sosSymptomsError", "Triệu chứng khẩn cấp không được chỉ chứa số.");
        }

        const symptomRegex = /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚÝàáâãèéêìíòóôõùúýĂăĐđĨĩŨũƠơƯưẠ-ỹ0-9\s,.()/-]+$/;
        if (!symptomRegex.test(symptoms)) {
            return setSosError("sosSymptoms", "sosSymptomsError", "Triệu chứng khẩn cấp chứa ký tự không hợp lệ.");
        }

        if (/(.)\1{5,}/.test(symptoms.toLowerCase())) {
            return setSosError("sosSymptoms", "sosSymptomsError", "Triệu chứng khẩn cấp không hợp lệ. Vui lòng nhập rõ ràng hơn.");
        }

        return clearSosError("sosSymptoms", "sosSymptomsError");
    }

    function validateSosForm() {
        const validName = validateSosName();
        const validPhone = validateSosPhone();
        const validSymptoms = validateSosSymptoms();

        return validName && validPhone && validSymptoms;
    }

    document.addEventListener("DOMContentLoaded", function () {
        const nameError = document.getElementById("sosNameError");
        const phoneError = document.getElementById("sosPhoneError");
        const symptomsError = document.getElementById("sosSymptomsError");

        if (nameError && nameError.innerText.trim()) {
            nameError.style.display = "block";
        }

        if (phoneError && phoneError.innerText.trim()) {
            phoneError.style.display = "block";
        }

        if (symptomsError && symptomsError.innerText.trim()) {
            symptomsError.style.display = "block";
        }
    });
</script>

</body>
</html>
