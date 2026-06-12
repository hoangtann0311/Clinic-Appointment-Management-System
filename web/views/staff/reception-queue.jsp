<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hàng Đợi Tiếp Đón - CAMS Staff</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
          rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css" rel="stylesheet">
</head>
<body>

<!-- Global Alert Banner for SOS Active -->
<c:if test="${activeSos > 0}">
    <div id="global-sos-alert">
        <div class="d-flex align-items-center gap-3">
            <i class="bi bi-exclamation-triangle-fill fs-3" style="animation: pulse-sos 1s infinite;"></i>
            <div>
                <h6 class="m-0 fw-bold">🚨 PHÁT HIỆN CÓ CA KHẨN CẤP (SOS) ĐANG CHỜ!</h6>
                <small>Hệ thống tự động chèn đầu hàng đợi và hú còi cảnh báo. Hãy tiến hành đón tiếp ngay tại
                    cửa.</small>
            </div>
        </div>
        <div class="d-flex gap-2">
            <button class="btn btn-light btn-sm fw-bold text-danger" onclick="playSiren()"><i
                    class="bi bi-volume-up-fill"></i> Phát Còi
            </button>
            <button class="btn btn-outline-light btn-sm" onclick="stopSiren()"><i class="bi bi-volume-mute-fill"></i>
                Tắt Còi
            </button>
        </div>
    </div>
</c:if>

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
            <a href="${pageContext.request.contextPath}/admin/reception" class="menu-item active">
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
                <h3 class="page-title">Hàng Đợi Tiếp Đón</h3>
                <div class="header-date-pill">
                    <i class="bi bi-calendar-event"></i>
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

                <button type="submit" class="btn-cams-refresh">
                    <i class="bi bi-search"></i> Xem
                </button>

                <a href="${pageContext.request.contextPath}/admin/reception" class="btn-cams-refresh">
                    <i class="bi bi-calendar-check"></i> Hôm nay
                </a>
            </form>
        </div>

        <!-- Greeting Card -->
        <div class="greeting-card">
            <div class="greeting-text-box">
                <h3>Xin chào, Hoàng Văn Tân!</h3>
                <p>Chào mừng bạn đến với hệ thống quản trị đặt lịch & điều phối hàng đợi CAMS. Dưới đây là tổng quan
                    hoạt động của phòng khám.</p>
            </div>
            <div class="greeting-badge-btn">
                <i class="bi bi-shield-lock-fill"></i> Lễ Tân / Call Center
            </div>
        </div>

        <!-- Metrics Cards Grid -->
        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-icon-box icon-blue"><i class="bi bi-calendar-event"></i></div>
                <div class="metric-info">
                    <h4><c:out value="${todayAppointments}"/></h4>
                    <p>Tổng Lịch Hẹn</p>
                    <span class="metric-subtext">Cập nhật thực tế</span>
                </div>
            </div>
            <div class="metric-card">
                <div class="metric-icon-box icon-orange"><i class="bi bi-hourglass-split"></i></div>
                <div class="metric-info">
                    <h4><c:out value="${waitingQueue}"/></h4>
                    <p>Đang Chờ Khám</p>
                    <span class="metric-subtext">Đang xếp hàng chờ</span>
                </div>
            </div>
            <div class="metric-card <c:if test='${activeSos > 0}'>sos-blink</c:if>">
                <div class="metric-icon-box <c:choose><c:when test='${activeSos > 0}'>icon-red</c:when><c:otherwise>icon-cyan</c:otherwise></c:choose>">
                    <i class="bi bi-activity"></i></div>
                <div class="metric-info">
                    <h4><c:out value="${activeSos}"/></h4>
                    <p>Ca Khẩn Cấp (SOS)</p>
                    <span class="metric-subtext">Ưu tiên số 1</span>
                </div>
            </div>
        </div>

        <!-- Smart Queue List (Spans 100% width) -->
        <div class="cams-card">
            <div class="cams-card-header">
                <h5 class="cams-card-title"><i class="bi bi-card-list"></i> Danh Sách Điều Phối Hàng Đợi (Smart Queue)
                </h5>
            </div>
            <div class="cams-card-body p-0">
                <c:if test="${not empty errors}">
                    <div class="alert alert-danger">
                        <strong>Không thể thực hiện thao tác:</strong>
                        <ul class="mb-0 mt-2">
                            <c:forEach var="err" items="${errors}">
                                <li><c:out value="${err}"/></li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
                <table class="table-cams">
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
                    <span class="text-success fw-bold">
                        <i class="bi bi-person-fill-check"></i> Đang đợi bác sĩ
                    </span>
                                    </c:when>

                                    <c:when test="${statusLower == 'inprogress'}">
                    <span class="text-warning fw-semibold">
                        <i class="bi bi-activity"></i> Đang khám lâm sàng
                    </span>
                                    </c:when>

                                    <c:when test="${statusLower == 'success'}">
                    <span class="text-muted">
                        <i class="bi bi-emoji-smile"></i> Đã hoàn thành
                    </span>
                                    </c:when>

                                    <c:when test="${statusLower == 'cancelled'}">
                    <span class="text-muted">
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

        <!-- Zalo OA Notifications below the table -->
        <!-- Zalo OA Notifications Panel -->
        <div class="dashboard-lower-grid" style="display:block; width:100%;">
            <div class="cams-card" style="width:100%;">
                <div class="cams-card-header">
                    <h5 class="cams-card-title text-primary">
                        <i class="bi bi-chat-right-text-fill"></i> Zalo OA Notifications
                    </h5>
                </div>
                <div class="cams-card-body" style="max-height: 280px; overflow-y: auto;">
                    <c:forEach var="msg" items="${zaloMsgs}">
                        <div class="zalo-entry">
                            <div class="d-flex justify-content-between font-monospace text-muted mb-1"
                                 style="font-size: 10px;">
                                <span><c:out value="${msg.name}"/></span>
                                <span><c:out value="${fn:substring(msg.time, 11, 19)}"/></span>
                            </div>
                            <strong><c:out value="${msg.content}"/></strong>
                        </div>
                    </c:forEach>

                    <c:if test="${empty zaloMsgs}">
                        <div class="text-center text-muted py-3 fs-7">
                            Chưa phát sinh tin nhắn Zalo tự động nào.
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
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
</script>
</body>
</html>
