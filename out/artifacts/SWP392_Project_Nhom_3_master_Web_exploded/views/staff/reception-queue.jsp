<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hàng Đợi Tiếp Đón - CAMS Staff</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css" rel="stylesheet">
</head>
<body class="admin-body">

<c:set var="requestURI" value="${pageContext.request.servletPath}" />

<!-- Global Alert Banner for SOS Active -->
<c:if test="${activeSos > 0}">
    <div id="global-sos-alert">
        <div class="d-flex align-items-center gap-3">
            <i class="bi bi-exclamation-triangle-fill fs-3" style="animation: pulse-sos 1s infinite;"></i>
            <div>
                <h6 class="m-0 fw-bold">🚨 PHÁT HIỆN CÓ CA KHẨN CẤP (SOS) ĐANG CHỜ!</h6>
                <small>Hệ thống tự động chèn đầu hàng đợi và hú còi cảnh báo. Hãy tiến hành đón tiếp ngay tại cửa.</small>
            </div>
        </div>
        <div class="d-flex gap-2">
            <button class="btn btn-light btn-sm fw-bold text-danger" onclick="playSiren()">
                <i class="bi bi-volume-up-fill"></i> Phát Còi
            </button>
            <button class="btn btn-outline-light btn-sm" onclick="stopSiren()">
                <i class="bi bi-volume-mute-fill"></i> Tắt Còi
            </button>
        </div>
    </div>
</c:if>

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
                <h1 class="admin-page-title">Hàng Đợi Tiếp Đón</h1>
                <div class="admin-page-subtitle">
                    <i class="bi bi-calendar3"></i>
                    <span><c:out value="${displayDate}"/></span>
                </div>
            </div>
            <form action="${pageContext.request.contextPath}/admin/reception"
                  method="get"
                  class="d-flex align-items-center gap-2">
                <input type="date"
                       name="date"
                       class="cams-form-input"
                       style="width: 170px;"
                       value="${selectedDate}">

                <button type="submit" class="btn-refresh">
                    <i class="bi bi-search"></i> Xem
                </button>

                <a href="${pageContext.request.contextPath}/admin/reception" class="btn-refresh">
                    <i class="bi bi-calendar-check"></i> Hôm nay
                </a>
            </form>
        </div>

        <!-- Welcome Banner -->
        <div class="admin-welcome-banner">
            <div class="welcome-left">
                <h2>
                    <i class="bi bi-stars"></i>
                    Xin chào, ${sessionScope.user.fullName}!
                </h2>
                <p>Chào mừng bạn đến với hệ thống quản trị đặt lịch & điều phối hàng đợi CAMS. Dưới đây là tổng quan hoạt động của phòng khám.</p>
            </div>
            <span class="badge-role">
                <i class="bi bi-person-badge-fill"></i>
                Lễ Tân / Call Center
            </span>
        </div>

        <!-- Metrics Grid -->
        <div class="row g-3 mb-4">
            <%-- 1. Tổng lịch hẹn --%>
            <div class="col-xl-4 col-md-6">
                <div class="card kpi-card kpi-appointments">
                    <div class="card-body">
                        <div class="kpi-icon"><i class="bi bi-calendar-event"></i></div>
                        <div class="kpi-content">
                            <div class="kpi-value">${todayAppointments}</div>
                            <div class="kpi-label">Tổng Lịch Hẹn</div>
                            <div class="kpi-sub"><i class="bi bi-clock"></i> Cập nhật thực tế</div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- 2. Đang chờ khám --%>
            <div class="col-xl-4 col-md-6">
                <div class="card kpi-card kpi-waiting">
                    <div class="card-body">
                        <div class="kpi-icon"><i class="bi bi-hourglass-split"></i></div>
                        <div class="kpi-content">
                            <div class="kpi-value">${waitingQueue}</div>
                            <div class="kpi-label">Đang Chờ Khám</div>
                            <div class="kpi-sub"><i class="bi bi-person"></i> Đang xếp hàng chờ</div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- 3. Ca khẩn cấp --%>
            <div class="col-xl-4 col-md-6">
                <div class="card kpi-card kpi-patients <c:if test='${activeSos > 0}'>sos-blink</c:if>">
                    <div class="card-body">
                        <div class="kpi-icon">
                            <i class="bi bi-activity"></i>
                        </div>
                        <div class="kpi-content">
                            <div class="kpi-value">${activeSos}</div>
                            <div class="kpi-label">Ca Khẩn Cấp (SOS)</div>
                            <div class="kpi-sub"><i class="bi bi-exclamation-circle"></i> Ưu tiên số 1</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Smart Queue List (Spans 100% width) -->
        <div class="admin-card mb-4">
            <div class="card-header">
                <h5><i class="bi bi-card-list"></i> Danh Sách Điều Phối Hàng Đợi (Smart Queue)</h5>
            </div>
            <div class="card-body p-0">
                <c:if test="${not empty errors}">
                    <div class="alert alert-danger m-3">
                        <strong>Không thể thực hiện thao tác:</strong>
                        <ul class="mb-0 mt-2">
                            <c:forEach var="err" items="${errors}">
                                <li><c:out value="${err}"/></li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>

                <div class="admin-table-wrapper">
                    <table class="admin-table table-cams">
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>Sản phụ</th>
                            <th>Bác sĩ</th>
                            <th>Tuổi thai</th>
                            <th>Dịch vụ</th>
                            <th>Triệu chứng</th>
                            <th>Thanh toán</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="apt" items="${queue}">
                            <c:set var="statusLower" value="${fn:toLowerCase(apt.status)}"/>

                            <tr class="<c:if test='${statusLower == "emergency_sos"}'>sos-blink</c:if>">
                                <td>
                                    <c:choose>
                                        <c:when test="${statusLower == 'emergency_sos'}">
                                            <strong class="text-danger">
                                                <c:out value="${apt.queueNumber != null ? apt.queueNumber : 'SOS'}"/>
                                            </strong>
                                        </c:when>
                                        <c:otherwise>
                                            <strong class="text-dark">
                                                <c:out value="${apt.queueNumber != null ? apt.queueNumber : 'Chờ cấp'}"/>
                                            </strong>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <span class="fw-bold"><c:out value="${apt.patientName}"/></span><br>
                                    <small class="text-muted">
                                        <c:out value="${apt.patient != null ? apt.patient.phone : ''}"/>
                                    </small>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${apt.doctor != null}">
                                            BS. <c:out value="${apt.doctor.name}"/>
                                        </c:when>
                                        <c:otherwise>
                                            -
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="fw-semibold text-primary">
                                    <c:out value="${apt.gestationalAge != null ? apt.gestationalAge : 'Không xác định'}"/>
                                </td>

                                <td>
                                    <c:out value="${apt.service != null ? apt.service.serviceName : '-'}"/>
                                </td>

                                <td class="text-center">
                                    <c:out value="${apt.symptoms}"/>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${apt.preExamPaymentStatus == 'Paid'}">
                                            <span class="badge-cams badge-success">
                                                <i class="bi bi-check-circle"></i> Đã thanh toán
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-cams badge-pending">
                                                <i class="bi bi-exclamation-circle"></i> Chờ thanh toán
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <span class="badge-cams
                                        <c:choose>
                                            <c:when test="${statusLower == 'emergency_sos'}">badge-sos</c:when>
                                            <c:when test="${statusLower == 'waiting'}">badge-waiting</c:when>
                                            <c:when test="${statusLower == 'confirmed'}">badge-confirmed</c:when>
                                            <c:when test="${statusLower == 'pending'}">badge-pending</c:when>
                                            <c:when test="${statusLower == 'inprogress'}">badge-inprogress</c:when>
                                            <c:when test="${statusLower == 'success'}">badge-success</c:when>
                                            <c:otherwise>badge-cancelled</c:otherwise>
                                        </c:choose>">
                                        <c:out value="${apt.status}"/>
                                    </span>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${statusLower == 'emergency_sos'}">
                                            <form action="${pageContext.request.contextPath}/admin/reception/sos/dismiss"
                                                  method="post"
                                                  style="display:inline;">
                                                <input type="hidden" name="id" value="${apt.id}">
                                                <button type="submit" class="btn-cams btn-cams-sos btn-sm">
                                                    <i class="bi bi-shield-fill-exclamation"></i> ĐÓN TIẾP KHẨN
                                                </button>
                                            </form>
                                        </c:when>

                                        <c:when test="${statusLower == 'pending' || statusLower == 'confirmed'}">
                                            <div class="d-flex flex-wrap justify-content-center gap-1">
                                                <c:choose>
                                                    <c:when test="${apt.preExamPaymentStatus == 'Paid'}">
                                                        <form action="${pageContext.request.contextPath}/admin/reception/checkin"
                                                              method="post"
                                                              style="display:inline;">
                                                            <input type="hidden" name="id" value="${apt.id}">
                                                            <button type="submit" class="btn-cams btn-cams-primary btn-sm">
                                                                <i class="bi bi-check-circle"></i> CHECK-IN
                                                            </button>
                                                        </form>
                                                    </c:when>

                                                    <c:otherwise>
                                                        <button type="button"
                                                                class="btn-cams btn-cams-secondary btn-sm"
                                                                disabled
                                                                title="Bệnh nhân chưa thanh toán hóa đơn PRE_EXAM">
                                                            <i class="bi bi-lock-fill"></i> CHỜ THANH TOÁN
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>

                                                <a href="${pageContext.request.contextPath}/admin/reception/edit?id=${apt.id}"
                                                   class="btn-action btn-action-edit">
                                                    <i class="bi bi-pencil-square"></i> SỬA
                                                </a>

                                                <form action="${pageContext.request.contextPath}/admin/reception/cancel"
                                                      method="post"
                                                      style="display:inline;"
                                                      onsubmit="return confirm('Bạn có chắc chắn muốn hủy lịch hẹn khám này?')">
                                                    <input type="hidden" name="id" value="${apt.id}">
                                                    <button type="submit" class="btn-action btn-action-delete">
                                                        <i class="bi bi-x-circle"></i> HỦY
                                                    </button>
                                                </form>
                                            </div>
                                        </c:when>

                                        <c:when test="${statusLower == 'waiting'}">
                                            <span class="text-success fw-bold text-nowrap">
                                                <i class="bi bi-person-fill-check"></i> Đang đợi bác sĩ
                                            </span>
                                        </c:when>

                                        <c:when test="${statusLower == 'inprogress'}">
                                            <span class="text-warning fw-semibold text-nowrap">
                                                <i class="bi bi-activity"></i> Đang khám lâm sàng
                                            </span>
                                        </c:when>

                                        <c:when test="${statusLower == 'success'}">
                                            <span class="text-muted text-nowrap">
                                                <i class="bi bi-emoji-smile"></i> Đã hoàn thành
                                            </span>
                                        </c:when>

                                        <c:when test="${statusLower == 'cancelled'}">
                                            <span class="text-muted text-nowrap">
                                                <i class="bi bi-x-circle"></i> Đã hủy
                                            </span>
                                        </c:when>

                                        <c:otherwise>
                                            -
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty queue}">
                            <tr>
                                <td colspan="9" class="text-center text-muted py-4">
                                    Không có ca khám nào trong hàng đợi ngày hôm nay.
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Zalo OA Notifications Panel has been removed to reduce screen clutter -->
    </main>
</div>

<script>
    let audioCtx = null;
    let osc1 = null;
    let osc2 = null;
    let sirenInterval = null;
    let activeSos = ${activeSos != null ? activeSos : 0};

    function playSiren() {
        try {
            if (audioCtx) return;
            audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            osc1 = audioCtx.createOscillator();
            osc2 = audioCtx.createOscillator();
            let gainNode = audioCtx.createGain();

            osc1.type = 'sawtooth';
            osc1.frequency.setValueAtTime(600, audioCtx.currentTime);
            osc2.type = 'sine';
            osc2.frequency.setValueAtTime(500, audioCtx.currentTime);

            gainNode.gain.setValueAtTime(0.05, audioCtx.currentTime);

            osc1.connect(gainNode);
            osc2.connect(gainNode);
            gainNode.connect(audioCtx.destination);

            osc1.start();
            osc2.start();

            let high = true;
            sirenInterval = setInterval(() => {
                if (high) {
                    osc1.frequency.exponentialRampToValueAtTime(750, audioCtx.currentTime + 0.3);
                    osc2.frequency.exponentialRampToValueAtTime(650, audioCtx.currentTime + 0.3);
                } else {
                    osc1.frequency.exponentialRampToValueAtTime(450, audioCtx.currentTime + 0.3);
                    osc2.frequency.exponentialRampToValueAtTime(350, audioCtx.currentTime + 0.3);
                }
                high = !high;
            }, 400);
        } catch (e) {
            console.error("Web Audio API error: ", e);
        }
    }

    function stopSiren() {
        if (sirenInterval) {
            clearInterval(sirenInterval);
            sirenInterval = null;
        }
        if (osc1) {
            try {
                osc1.stop();
            } catch (e) {
            }
            osc1 = null;
        }
        if (osc2) {
            try {
                osc2.stop();
            } catch (e) {
            }
            osc2 = null;
        }
        if (audioCtx) {
            audioCtx.close();
            audioCtx = null;
        }
    }

    window.addEventListener('load', () => {
        if (activeSos > 0) {
            document.body.addEventListener('click', function autoSirenOnInteraction() {
                playSiren();
                document.body.removeEventListener('click', autoSirenOnInteraction);
            });
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
