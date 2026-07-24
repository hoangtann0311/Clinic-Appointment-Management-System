<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hàng Đợi Tiếp Đón - CAMS Lễ Tân</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css?v=202" rel="stylesheet">
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
            <div class="col-lg-6">
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
            <div class="col-lg-6">
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
                <c:if test="${not empty queueError}">
                    <div class="alert alert-danger m-3">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>
                        <c:out value="${queueError}"/>
                    </div>
                </c:if>
                <c:if test="${not empty queueSuccess}">
                    <div class="alert alert-success m-3">
                        <i class="bi bi-check-circle-fill me-2"></i>
                        <c:out value="${queueSuccess}"/>
                    </div>
                </c:if>

                <div class="admin-table-wrapper">
                    <table class="admin-table table-cams">
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>Sản phụ</th>
                            <th>Bác sĩ lâm sàng</th>
                            <th>Giờ khám</th>
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

                            <tr class="${apt.emergency ? 'table-warning' : ''}">
                                <td>
                                    <strong class="${apt.emergency ? 'text-warning-emphasis' : 'text-dark'}">
                                        <c:out value="${apt.queueNumber != null ? apt.queueNumber : 'Chờ cấp'}"/>
                                    </strong>
                                    <c:if test="${apt.emergency}">
                                        <div class="mt-1">
                                            <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle">
                                                <i class="bi bi-arrow-up-circle-fill me-1"></i>Ưu tiên
                                            </span>
                                        </div>
                                    </c:if>
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
                                            BS. <c:out value="${apt.doctor.fullName}"/>
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="fw-medium"><c:out value="${apt.timeSlot}"/></td>

                                <td class="fw-semibold text-primary">
                                    <c:out value="${apt.gestationalAge != null ? apt.gestationalAge : '—'}"/>
                                </td>

                                <td>
                                    <%-- Lịch đặt online có thể lưu nhiều dịch vụ trong appointment_services,
                                         nên service_id trên appointment có thể NULL. serviceName đã được DAO tổng hợp. --%>
                                    <c:out value="${not empty apt.serviceName ? apt.serviceName : (apt.service != null ? apt.service.serviceName : '-')}"/>
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
                                            <c:when test="${statusLower == 'waiting'}">badge-waiting</c:when>
                                            <c:when test="${statusLower == 'confirmed'}">badge-confirmed</c:when>
                                            <c:when test="${statusLower == 'pending'}">badge-pending</c:when>
                                            <c:when test="${statusLower == 'inprogress'}">badge-inprogress</c:when>
                                            <c:when test="${statusLower == 'success'}">badge-success</c:when>
                                            <c:otherwise>badge-cancelled</c:otherwise>
                                        </c:choose>">
                                        <c:choose>
                                            <c:when test="${statusLower == 'waiting'}">Chờ khám</c:when>
                                            <c:when test="${statusLower == 'confirmed'}">Đã xác nhận</c:when>
                                            <c:when test="${statusLower == 'pending'}">Chờ xác nhận</c:when>
                                            <c:when test="${statusLower == 'inprogress'}">Đang khám</c:when>
                                            <c:when test="${statusLower == 'success' || statusLower == 'completed'}">Hoàn thành</c:when>
                                            <c:otherwise>Đã hủy</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <c:if test="${apt.emergency}">
                                        <div class="small mt-2 text-warning-emphasis"
                                             title="Người thao tác: ${apt.prioritizedByName}; Thời gian: ${apt.prioritizedAtText}">
                                            <i class="bi bi-info-circle me-1"></i>
                                            <c:out value="${apt.priorityReason}"/>
                                            <c:if test="${not empty apt.prioritizedByName}">
                                                <br><span class="text-muted">
                                                    Bởi <c:out value="${apt.prioritizedByName}"/>
                                                    <c:if test="${not empty apt.prioritizedAtText}">
                                                        lúc <c:out value="${apt.prioritizedAtText}"/>
                                                    </c:if>
                                                </span>
                                            </c:if>
                                        </div>
                                    </c:if>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${statusLower == 'pending' || statusLower == 'confirmed'}">
                                            <div class="d-flex flex-wrap justify-content-center gap-1">
                                                <c:choose>
                                                    <c:when test="${apt.preExamPaymentStatus == 'Paid'}">
                                                        <form action="${pageContext.request.contextPath}/admin/reception/checkin"
                                                              method="post"
                                                              style="display:inline;">
                                                            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
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
                                                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="id" value="${apt.id}">
                                                    <button type="submit" class="btn-action btn-action-delete">
                                                        <i class="bi bi-x-circle"></i> HỦY
                                                    </button>
                                                </form>
                                            </div>
                                        </c:when>

                                        <c:when test="${statusLower == 'waiting'}">
                                            <div class="d-flex flex-column align-items-center gap-2">
                                                <span class="text-success fw-bold text-nowrap">
                                                    <i class="bi bi-person-fill-check"></i> Đang đợi Bác sĩ lâm sàng
                                                </span>
                                                <c:choose>
                                                    <c:when test="${apt.emergency}">
                                                        <form method="post"
                                                              action="${pageContext.request.contextPath}/admin/reception/priority"
                                                              onsubmit="return confirm('Bỏ mức ưu tiên của ca khám này?');">
                                                            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                            <input type="hidden" name="action" value="clear">
                                                            <input type="hidden" name="id" value="${apt.id}">
                                                            <button type="submit" class="btn btn-sm btn-outline-secondary">
                                                                <i class="bi bi-arrow-down-circle me-1"></i>Bỏ ưu tiên
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="button"
                                                                class="btn btn-sm btn-outline-warning"
                                                                data-bs-toggle="modal"
                                                                data-bs-target="#priorityModal"
                                                                data-appointment-id="${apt.id}"
                                                                data-patient-name="${fn:escapeXml(apt.patientName)}">
                                                            <i class="bi bi-arrow-up-circle me-1"></i>Đánh dấu ưu tiên
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:when>

                                        <c:when test="${statusLower == 'inprogress'}">
                                            <div class="d-flex flex-column align-items-center gap-2">
                                                <span class="text-warning fw-semibold text-nowrap">
                                                    <i class="bi bi-activity"></i> Đang khám lâm sàng
                                                </span>
                                                <c:if test="${apt.emergency}">
                                                    <form method="post"
                                                          action="${pageContext.request.contextPath}/admin/reception/priority"
                                                          onsubmit="return confirm('Bỏ mức ưu tiên của ca khám này?');">
                                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="clear">
                                                        <input type="hidden" name="id" value="${apt.id}">
                                                        <button type="submit" class="btn btn-sm btn-outline-secondary">
                                                            <i class="bi bi-arrow-down-circle me-1"></i>Bỏ ưu tiên
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </div>
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

<div class="modal fade" id="priorityModal" tabindex="-1" aria-labelledby="priorityModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 rounded-4">
            <form method="post" action="${pageContext.request.contextPath}/admin/reception/priority">
                <div class="modal-header border-0 pb-1">
                    <h5 class="modal-title fw-bold" id="priorityModalLabel">
                        <i class="bi bi-arrow-up-circle-fill text-warning me-2"></i>Đánh Dấu Ưu Tiên
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="mark">
                    <input type="hidden" name="id" id="priorityAppointmentId">
                    <div class="alert alert-warning py-2">
                        Ca khám của <strong id="priorityPatientName">bệnh nhân</strong>
                        sẽ được xếp trước các ca đang chờ thông thường.
                    </div>
                    <label for="priorityReason" class="form-label fw-semibold">
                        Lý do ưu tiên <span class="text-danger">*</span>
                    </label>
                    <textarea class="form-control" id="priorityReason" name="reason"
                              rows="4" minlength="5" maxlength="500" required
                              placeholder="Nhập tình trạng hoặc lý do cần ưu tiên (5–500 ký tự)"></textarea>
                    <div class="form-text">Thông tin người thao tác và thời gian sẽ được ghi vào nhật ký.</div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-warning">
                        <i class="bi bi-check2-circle me-1"></i>Xác nhận ưu tiên
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
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

    var priorityModal = document.getElementById('priorityModal');
    if (priorityModal) {
        priorityModal.addEventListener('show.bs.modal', function(event) {
            var button = event.relatedTarget;
            document.getElementById('priorityAppointmentId').value =
                    button.getAttribute('data-appointment-id') || '';
            document.getElementById('priorityPatientName').textContent =
                    button.getAttribute('data-patient-name') || 'bệnh nhân';
            document.getElementById('priorityReason').value = '';
        });
    }
</script>

<%@ include file="../common/standalone-footer.jsp" %>
</body>
</html>
