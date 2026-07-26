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
        <div class="dropdown admin-topbar-dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle" id="adminUserDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="admin-avatar-sm me-2">
                    ${not empty sessionScope.user.fullName ? fn:substring(sessionScope.user.fullName, 0, 1) : '?'}
                </div>
                <span class="d-none d-md-inline fw-semibold text-dark">${sessionScope.user.fullName}</span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg rounded-3" aria-labelledby="adminUserDropdown">
                <li class="dropdown-header">
                    <h6 class="text-dark mb-0 fw-bold">${sessionScope.user.fullName}</h6>
                    <small class="text-muted">
                        <c:choose>
                            <c:when test="${sessionScope.user.roleId == 1}">Quản Lý</c:when>
                            <c:when test="${sessionScope.user.roleId == 2}">Bác Sĩ Lâm Sàng</c:when>
                            <c:when test="${sessionScope.user.roleId == 3}">Admin</c:when>
                            <c:when test="${sessionScope.user.roleId == 4}">Lễ Tân</c:when>
                            <c:when test="${sessionScope.user.roleId == 6}">Bác Sĩ Siêu Âm</c:when>
                            <c:otherwise>Nhân viên</c:otherwise>
                        </c:choose>
                    </small>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li>
                    <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">
                        <i class="bi bi-box-arrow-right me-2"></i>Đăng Xuất
                    </a>
                </li>
            </ul>
        </div>
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
                <i class="bi bi-shield-check"></i>LỄ TÂN
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
                    <span>Lịch Làm Việc</span>
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
            <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                <h5 class="mb-0"><i class="bi bi-card-list"></i> Danh Sách Điều Phối Hàng Đợi</h5>
                <form method="get" action="${pageContext.request.contextPath}/admin/reception" class="d-flex gap-2 align-items-center">
                    <input type="hidden" name="date" value="${selectedDate}">
                    <input type="text" name="search" class="form-control form-control-sm" placeholder="Tìm tên, SĐT, mã..." value="${fn:escapeXml(search)}" style="width: 200px;">
                    <select name="status" class="form-select form-select-sm" style="width: 150px;">
                        <option value="">-- Tất cả TT --</option>
                        <option value="Pending" ${status == 'Pending' ? 'selected' : ''}>Chờ duyệt</option>
                        <option value="Confirmed" ${status == 'Confirmed' ? 'selected' : ''}>Đã duyệt</option>
                        <option value="Waiting" ${status == 'Waiting' ? 'selected' : ''}>Chờ khám</option>
                        <option value="InProgress" ${status == 'InProgress' ? 'selected' : ''}>Đang khám</option>
                    </select>
                    <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-search"></i> Lọc</button>
                    <c:if test="${not empty search or not empty status}">
                        <a href="${pageContext.request.contextPath}/admin/reception?date=${selectedDate}" class="btn btn-light btn-sm border" title="Xóa bộ lọc"><i class="bi bi-x-circle"></i></a>
                    </c:if>
                </form>
            </div>
            <div class="card-body p-0">
                <c:if test="${not empty errors}">
                    <div class="alert alert-danger m-3" data-cams-toast="true">
                        <strong>Không thể thực hiện thao tác:</strong>
                        <ul class="mb-0 mt-2">
                            <c:forEach var="err" items="${errors}">
                                <li><c:out value="${err}"/></li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
                <c:if test="${not empty queueError}">
                    <div class="alert alert-danger alert-dismissible fade show m-3" data-cams-toast role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>
                        <c:out value="${queueError}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty queueSuccess}">
                    <div class="alert alert-success alert-dismissible fade show m-3" data-cams-toast role="alert">
                        <i class="bi bi-check-circle-fill me-2"></i>
                        <c:out value="${queueSuccess}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <div class="admin-table-wrapper">
                    <table class="admin-table table-cams">
                        <thead>
                        <tr>
                            <th style="width:4%;">STT</th>
                            <th style="width:11%;">Sản phụ</th>
                            <th style="width:12%;">Bác sĩ</th>
                            <th style="width:9%;">Giờ khám</th>
                            <th style="width:8%;">Tuổi thai</th>
                            <th style="width:9%;">Dịch vụ</th>
                            <th style="width:14%;">Triệu chứng</th>
                            <th style="width:8%;">Thanh toán</th>
                            <th style="width:9%;">Trạng thái</th>
                            <th style="width:16%;">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="apt" items="${queue}">
                            <c:set var="statusLower" value="${fn:toLowerCase(apt.status)}"/>

                            <c:set var="isLate" value="${not empty lateAppointments && lateAppointments.contains(apt.id)}"/>
                            <tr class="${apt.priority ? 'table-warning' : (isLate ? 'table-danger bg-opacity-10' : '')}" style="${isLate && !apt.priority ? 'background:#fff3e0;' : ''}">
                                <td>
                                    <strong class="${apt.priority ? 'text-warning-emphasis' : 'text-dark'}">
                                        <c:choose>
                                            <c:when test="${apt.queueNumber != null && apt.queueNumber.length() >= 2}">
                                                <c:out value="${apt.queueNumber}"/>
                                            </c:when>
                                            <c:when test="${statusLower == 'success' || statusLower == 'completed'}">
                                                <span class="text-muted">—</span>
                                            </c:when>
                                            <c:otherwise>Chờ cấp</c:otherwise>
                                        </c:choose>
                                    </strong>
                                    <c:if test="${apt.priority}">
                                        <div class="mt-1">
                                            <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle">
                                                <i class="bi bi-arrow-up-circle-fill me-1"></i>Ưu tiên
                                            </span>
                                        </div>
                                    </c:if>
                                    <c:if test="${isLate}">
                                        <div class="mt-1">
                                            <span class="badge bg-danger bg-opacity-75 text-white" style="font-size:.65rem;">
                                                <i class="bi bi-clock-history me-1"></i>Đến muộn
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

                                <td class="fw-medium">
                                    <c:out value="${apt.timeSlot}"/>
                                    <c:if test="${not empty apt.createdAtText}">
                                        <div class="small text-muted fw-normal mt-1" style="font-size: 0.75rem;">
                                            <i class="bi bi-clock-history"></i> Đặt lúc: <c:out value="${apt.createdAtText}"/>
                                        </div>
                                    </c:if>
                                </td>

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
                                    <c:if test="${apt.priority}">
                                        <div class="mt-2 text-danger fw-semibold" style="font-size: 0.8rem;"
                                             title="Người thao tác: ${apt.prioritizedByName}; Thời gian: ${apt.prioritizedAtText}">
                                            <i class="bi bi-star-fill text-warning me-1"></i>
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
                                        <c:when test="${statusLower == 'pending'}">
                                            <div class="d-flex flex-wrap justify-content-center gap-1">
                                                <form action="${pageContext.request.contextPath}/admin/reception/approve-payment-request"
                                                      method="post"
                                                      style="display:inline;">
                                                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="id" value="${apt.id}">
                                                     <button type="submit" class="btn-cams btn-cams-primary btn-sm" style="font-size:.72rem;padding:.2rem .45rem;" title="Duyệt lịch hẹn và tạo hóa đơn thanh toán trước khám (bệnh nhân sẽ nộp tiền mặt khi đến quầy)">
                                                         <i class="bi bi-clipboard2-check"></i> Duyệt &amp; Tạo HĐ
                                                     </button>
                                                </form>

                                                <a href="${pageContext.request.contextPath}/admin/reception/edit?id=${apt.id}"
                                                   class="btn-action btn-action-edit" style="font-size:.7rem;padding:.15rem .4rem;">
                                                    <i class="bi bi-pencil-square"></i> Sửa
                                                </a>

                                                <form action="${pageContext.request.contextPath}/admin/reception/cancel"
                                                      method="post"
                                                      style="display:inline;"
                                                      onsubmit="return confirm('Bạn có chắc chắn muốn hủy lịch hẹn khám này?')">
                                                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="id" value="${apt.id}">
                                                    <button type="submit" class="btn-action btn-action-delete" style="font-size:.7rem;padding:.15rem .4rem;">
                                                        <i class="bi bi-x-circle"></i> Huỷ
                                                    </button>
                                                </form>
                                            </div>
                                        </c:when>

                                        <c:when test="${statusLower == 'confirmed'}">
                                            <div class="d-flex flex-wrap justify-content-center gap-1">
                                                <form action="${pageContext.request.contextPath}/admin/reception/checkin"
                                                      method="post"
                                                      style="display:inline;">
                                                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="id" value="${apt.id}">
                                                     <button type="submit" class="btn-cams btn-cams-success btn-sm" style="font-size:.72rem;padding:.2rem .45rem;" title="Xác nhận bệnh nhân đã nộp tiền mặt tại quầy và đưa vào hàng đợi Bác sĩ">
                                                         <i class="bi bi-cash-coin"></i> Thu Tiền &amp; Check-in
                                                     </button>
                                                </form>

                                                <a href="${pageContext.request.contextPath}/admin/reception/edit?id=${apt.id}"
                                                   class="btn-action btn-action-edit" style="font-size:.7rem;padding:.15rem .4rem;">
                                                    <i class="bi bi-pencil-square"></i> Sửa
                                                </a>

                                                <form action="${pageContext.request.contextPath}/admin/reception/cancel"
                                                      method="post"
                                                      style="display:inline;"
                                                      onsubmit="return confirm('Bạn có chắc chắn muốn hủy lịch hẹn khám này?')">
                                                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="id" value="${apt.id}">
                                                    <button type="submit" class="btn-action btn-action-delete" style="font-size:.7rem;padding:.15rem .4rem;">
                                                        <i class="bi bi-x-circle"></i> Huỷ
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
                                                    <c:when test="${apt.priority}">
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
                                                <c:if test="${apt.priority}">
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
                                                <c:if test="${unpaidPostExamAptIds.contains(apt.id)}">
                                                    <form action="${pageContext.request.contextPath}/admin/reception/approve-post-exam"
                                                          method="post"
                                                          style="display:inline;">
                                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="id" value="${apt.id}">
                                                        <button type="submit" class="btn-cams btn-cams-success btn-sm mt-1" style="font-size:.72rem;padding:.2rem .45rem;" title="Xác nhận thanh toán dịch vụ cận lâm sàng">
                                                            <i class="bi bi-cash-coin"></i> Xác nhận TT dịch vụ
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
                <!-- Phân trang -->
                <c:if test="${totalPages > 1}">
                    <div class="d-flex justify-content-between align-items-center p-3 border-top bg-light">
                        <small class="text-muted">
                            Hiển thị trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> 
                            (tổng cộng <strong>${totalRecords}</strong> bản ghi)
                        </small>
                        <nav aria-label="Page navigation">
                            <ul class="pagination pagination-sm mb-0">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/reception?date=${selectedDate}&search=${fn:escapeXml(search)}&status=${status}&page=${currentPage - 1}" tabindex="-1">Trước</a>
                                </li>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/admin/reception?date=${selectedDate}&search=${fn:escapeXml(search)}&status=${status}&page=${i}">${i}</a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/reception?date=${selectedDate}&search=${fn:escapeXml(search)}&status=${status}&page=${currentPage + 1}">Sau</a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </c:if>
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
