<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Giám Sát Cảnh Báo SOS - CAMS Staff</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css" rel="stylesheet">
    <!-- Leaflet.js Mapping Library (100% Free & Open Source Map) -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
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
            <span class="brand-badge">Staff</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="topbar-date d-none d-lg-flex">
            <i class="bi bi-calendar3"></i>
            <span><c:out value="${currentDisplayDate}"/></span>
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
                <a href="${pageContext.request.contextPath}/admin/reception/sos" 
                   class="${fn:contains(requestURI, 'sos') ? 'active' : ''}">
                    <i class="bi bi-bell-slash text-danger"></i>
                    <span>Giám Sát Cảnh Báo SOS</span>
                    <c:if test="${activeSos > 0}">
                        <span class="badge bg-danger ms-2"><c:out value="${activeSos}"/></span>
                    </c:if>
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
                <h1 class="admin-page-title">Giám Sát Cấp Cứu SOS</h1>
                <div class="admin-page-subtitle">
                    Quản lý tiếp đón &gt; Giám sát cảnh báo đỏ khẩn cấp
                </div>
            </div>
        </div>

        <!-- Layout split -->
        <div class="row">
            <div class="col-md-7">
                <!-- Active SOS alerts -->
                <div class="admin-card mb-4" style="border: 2px solid var(--rose-500) !important;">
                    <div class="card-header bg-danger text-white">
                        <h5 class="m-0 fw-bold d-flex align-items-center gap-2 text-white">
                            <i class="bi bi-exclamation-triangle-fill" style="animation: pulse-sos 1s infinite;"></i> 
                            Danh Sách Ca Báo Động Đỏ SOS Khẩn Cấp
                        </h5>
                    </div>
                    <div class="card-body p-0">
                        <div class="admin-table-wrapper">
                            <table class="admin-table table-cams">
                                <thead>
                                    <tr class="table-danger">
                                        <th>STT Hẹn</th>
                                        <th>Tên Sản Phụ</th>
                                        <th>Triệu Chứng Nguy Hiểm</th>
                                        <th>Phòng Điều Phối</th>
                                        <th>Hành Động</th>
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
                                                <strong class="text-dark">Phòng Sản 101</strong><br>
                                                <small class="text-muted">(BS. Trưởng Ca)</small>
                                            </td>
                                            <td>
                                                <form action="${pageContext.request.contextPath}/admin/reception/sos/dismiss" method="post">
                                                    <input type="hidden" name="id" value="${apt.id}">
                                                    <button type="submit" class="btn btn-danger btn-sm fw-bold px-2 py-1"><i class="bi bi-shield-fill-check"></i> TIẾP NHẬN</button>
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
                </div>

                <!-- Manual SOS Trigger Form -->
                <div class="admin-card mb-4">
                    <div class="card-header">
                        <h5><i class="bi bi-broadcast-pin text-danger"></i> Kích hoạt SOS khẩn cấp tại quầy</h5>
                    </div>
                    <div class="card-body">
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
                <div class="admin-card mb-4">
                    <div class="card-header">
                        <h5><i class="bi bi-geo-alt-fill text-primary"></i> GPS Clinic Locator (Định vị ca khẩn cấp)</h5>
                    </div>
                    <div class="card-body">
                        <p class="text-muted font-size-13">Hệ thống tự động quét và tính toán vị trí gần nhất từ sản phụ gửi báo động đỏ về để điều phối xe cấp cứu hoặc nhân sự túc trực sẵn sàng.</p>
                        
                        <!-- Real Leaflet Map Container -->
                        <div id="sosMap" class="rounded-3 mb-3 shadow-inner" style="height: 260px; border: 1px solid var(--c-outline-variant); background: #f8fafc; overflow: hidden; position: relative; z-index: 10;"></div>

                        <!-- Distance Calculations -->
                        <c:if test="${not empty sosAppointments}">
                            <div class="alert alert-danger p-3 mb-0" style="border-left: 4px solid #e53e3e;">
                                <h6 class="fw-bold text-danger m-0 mb-1"><i class="bi bi-pin-map-fill"></i> TÌM THẤY CA CẤP CỨU THAI SẢN GẦN NHẤT</h6>
                                <div class="row font-size-13 text-dark mt-2">
                                    <div class="col-6">
                                        <span class="text-muted d-block">Vị trí tương quan:</span>
                                        <strong id="sos-distance-text">Đang định vị...</strong>
                                    </div>
                                    <div class="col-6">
                                        <span class="text-muted d-block">Thời gian di chuyển dự kiến:</span>
                                        <strong id="sos-duration-text">-- phút (Taxi)</strong>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                        <c:if test="${empty sosAppointments}">
                            <div class="alert alert-secondary p-3 mb-0">
                                <i class="bi bi-check-circle-fill text-success"></i> Tình trạng yên tĩnh. Không phát hiện ca khẩn cấp nào.
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </main>
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

    // Leaflet.js Real GPS Map Integration
    document.addEventListener("DOMContentLoaded", function () {
        var mapContainer = document.getElementById('sosMap');
        if (!mapContainer) return;

        // Coordinates of the clinic (Hanoi, Vietnam)
        var clinicLat = 21.0285;
        var clinicLng = 105.8542;

        // Initialize Leaflet map centered at clinic
        var map = L.map('sosMap').setView([clinicLat, clinicLng], 14);

        // Add free OpenStreetMap tile layer
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 18,
            attribution: '© OpenStreetMap'
        }).addTo(map);

        // Add blue circular marker for the clinic
        var clinicMarker = L.circleMarker([clinicLat, clinicLng], {
            color: '#0284c7',
            fillColor: '#38bdf8',
            fillOpacity: 0.8,
            radius: 8,
            weight: 2
        }).addTo(map).bindPopup("<b>OCSS CLINIC (Phòng khám)</b><br>Trung tâm tiếp nhận SOS").openPopup();

        // Inject active SOS values from JSTL
        <c:choose>
            <c:when test="${not empty sosAppointments}">
                var hasActiveSos = true;
                var patientName = "${fn:escapeXml(sosAppointments[0].patientName)}";
                var patientPhone = "${fn:escapeXml(not empty sosAppointments[0].patient ? sosAppointments[0].patient.phone : '')}";
                var sosId = ${sosAppointments[0].id};
            </c:when>
            <c:otherwise>
                var hasActiveSos = false;
                var patientName = "";
                var patientPhone = "";
                var sosId = 0;
            </c:otherwise>
        </c:choose>

        if (hasActiveSos) {
            // Seed stable offset coordinates using SOS ID
            var seed = sosId * 123.456;
            var latOffset = (Math.sin(seed) * 0.012); // ~1km offset range
            var lngOffset = (Math.cos(seed) * 0.012);
            
            var patientLat = clinicLat + latOffset;
            var patientLng = clinicLng + lngOffset;

            // Add pulsing red marker for patient
            var patientMarker = L.circleMarker([patientLat, patientLng], {
                color: '#e11d48',
                fillColor: '#fda4af',
                fillOpacity: 0.9,
                radius: 10,
                weight: 2
            }).addTo(map).bindPopup("<b>Sản phụ khẩn cấp</b><br>" + patientName + "<br>SĐT: " + patientPhone);

            // Draw dashed routing connection line
            var polyline = L.polyline([[clinicLat, clinicLng], [patientLat, patientLng]], {
                color: '#e11d48',
                weight: 2,
                dashArray: '5, 8'
            }).addTo(map);

            // Zoom map to fit both markers perfectly
            var group = new L.featureGroup([clinicMarker, patientMarker]);
            map.fitBounds(group.getBounds().pad(0.3));

            // Calculate distance using Haversine formula
            function getDistanceKm(lat1, lon1, lat2, lon2) {
                var R = 6371; // Earth radius
                var dLat = (lat2-lat1) * Math.PI / 180;
                var dLon = (lon2-lon1) * Math.PI / 180;
                var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                        Math.sin(dLon/2) * Math.sin(dLon/2);
                var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
                return R * c;
            }

            var distance = getDistanceKm(clinicLat, clinicLng, patientLat, patientLng);
            var duration = Math.round(distance * 3 + 2); // Estimate ~3 mins/km + buffer

            // Update HTML text
            var distText = document.getElementById('sos-distance-text');
            var durText = document.getElementById('sos-duration-text');
            if (distText) distText.innerText = 'Cách phòng khám ' + distance.toFixed(1) + ' km';
            if (durText) durText.innerText = duration + ' phút (Taxi)';
        }
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
