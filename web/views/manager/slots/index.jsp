<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khung Giờ Khám — CAMS Quản Lý</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">
    <style>
        .schedule-info-card {
            background: linear-gradient(135deg, #fdf2f8, #fff1f6);
            border: 1px solid #f0c6dc; border-radius: 12px; padding: 1.25rem; margin-bottom: 1.25rem;
        }
        .schedule-info-row { display: flex; flex-wrap: wrap; gap: 1.25rem; align-items: center; }
        .schedule-info-item { display: flex; align-items: center; gap: 0.5rem; font-size: 0.9rem; font-weight: 600; }
        .schedule-info-item i { color: #b86689; font-size: 1.1rem; }
        .schedule-info-label { font-size: 0.7rem; font-weight: 600; color: #6b7280; text-transform: uppercase; letter-spacing: 0.05em; }
        .shift-badge-morning { background: #e3f2fd; color: #1565c0; padding: 0.2rem 0.6rem; border-radius: 6px; font-weight: 600; font-size: 0.78rem; }
        .shift-badge-afternoon { background: #fff3e0; color: #e65100; padding: 0.2rem 0.6rem; border-radius: 6px; font-weight: 600; font-size: 0.78rem; }
        .shift-badge-evening { background: #f3e5f5; color: #7b1fa2; padding: 0.2rem 0.6rem; border-radius: 6px; font-weight: 600; font-size: 0.78rem; }
        .badge-status-approved { background: #d1fae5; color: #065f46; padding: 0.3rem 0.7rem; border-radius: 6px; font-weight: 600; }
        .empty-state { text-align: center; padding: 3rem 1.5rem; color: #6b7280; }
        .empty-state i { font-size: 3rem; display: block; margin-bottom: 1rem; opacity: 0.3; }
    </style>
</head>
<body class="admin-body">

<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle"><i class="bi bi-list"></i></button>
        <a href="${pageContext.request.contextPath}/manager/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i>CAMS<span class="brand-badge">Quản Lý</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="dropdown admin-topbar-dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle" data-bs-toggle="dropdown">
                <div class="admin-avatar-sm me-2">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
                <span class="d-none d-md-inline fw-semibold text-dark">${sessionScope.user.fullName}</span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg rounded-3">
                <li class="dropdown-header"><h6 class="text-dark mb-0 fw-bold">${sessionScope.user.fullName}</h6><small class="text-muted">Quản Lý</small></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/manager/profile"><i class="bi bi-person-circle me-2 text-muted"></i>Hồ Sơ Cá Nhân</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng Xuất</a></li>
            </ul>
        </div>
    </div>
</nav>

<%@ include file="../layout/sidebar.jsp" %>

<main class="admin-main" id="adminMain">

    <div class="admin-page-header">
        <div>
            <h1 class="admin-page-title"><i class="bi bi-people-fill me-2" style="color:#b86689;"></i>Khung Giờ Khám</h1>
            <div class="admin-page-subtitle"><i class="bi bi-calendar-check"></i> Danh sách bệnh nhân trong ca làm việc — mô hình theo ca</div>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/manager/schedules/?status=APPROVED" class="btn btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i>Quay lại Lịch Làm Việc</a>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" data-cams-toast role="alert"><i class="bi bi-exclamation-triangle-fill me-2"></i>${fn:escapeXml(error)}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    </c:if>

    <%-- ═══ OVERVIEW: danh sách ca đã duyệt ═══ --%>
    <c:if test="${overviewMode}">
        <div class="admin-card mb-3">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5><i class="bi bi-list-check me-2" style="color:#b86689;"></i>Lịch Làm Việc Đã Xác Nhận</h5>
                <span class="badge bg-white text-dark border">${fn:length(approvedSchedules)} lịch làm việc</span>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${not empty approvedSchedules}">
                        <div class="table-responsive">
                            <table class="admin-table">
                                <thead><tr><th>STT</th><th>Bác Sĩ</th><th>Ngày Trực</th><th>Ca Làm Việc</th><th class="text-center">BN Đã Đặt</th><th style="width:100px;">Xem</th></tr></thead>
                                <tbody>
                                    <c:forEach var="sched" items="${approvedSchedules}" varStatus="row">
                                        <tr>
                                            <td class="text-muted small">${row.count}</td>
                                            <td><strong><i class="bi bi-person-badge me-1" style="color:#b86689;"></i>${fn:escapeXml(sched.doctorName)}</strong></td>
                                            <td><fmt:formatDate value="${sched.workDate}" pattern="dd/MM/yyyy"/></td>
                                            <td>
                                                <c:set var="startHour" value="${fn:substring(sched.startTime, 0, 2)}"/>
                                                <c:choose>
                                                    <c:when test="${startHour < '12'}"><span class="shift-badge-morning"><i class="bi bi-sunrise-fill me-1"></i>${sched.shiftLabel}</span></c:when>
                                                    <c:when test="${startHour < '17'}"><span class="shift-badge-afternoon"><i class="bi bi-sun-fill me-1"></i>${sched.shiftLabel}</span></c:when>
                                                    <c:otherwise><span class="shift-badge-evening"><i class="bi bi-moon-fill me-1"></i>${sched.shiftLabel}</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center"><span class="badge bg-primary rounded-pill">${sched.bookedCount} / ${sched.maxSlots}</span></td>
                                            <td><a href="?scheduleId=${sched.id}" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye-fill"></i> Xem</a></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state"><i class="bi bi-calendar-x"></i><h5>Chưa Có Lịch Làm Việc Được Xác Nhận</h5><p>Vui lòng xác nhận lịch làm việc trước.</p><a href="${pageContext.request.contextPath}/manager/schedules/?status=PENDING" class="btn btn-primary">Đi Đến Lịch Làm Việc</a></div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </c:if>

    <%-- ═══ DETAIL: danh sách BN trong 1 ca ═══ --%>
    <c:if test="${not overviewMode}">
        <div class="schedule-info-card">
            <div class="schedule-info-label mb-2"><i class="bi bi-info-circle-fill me-1"></i>Thông tin ca làm việc #${schedule.id}</div>
            <div class="schedule-info-row">
                <div class="schedule-info-item"><i class="bi bi-person-badge"></i><div><div class="small text-muted">Bác sĩ</div><div>${fn:escapeXml(schedule.doctorName)}</div></div></div>
                <div class="schedule-info-item"><i class="bi bi-calendar3"></i><div><div class="small text-muted">Ngày trực</div><div><fmt:formatDate value="${schedule.workDate}" pattern="dd/MM/yyyy"/></div></div></div>
                <div class="schedule-info-item"><i class="bi bi-clock"></i><div><div class="small text-muted">Ca làm việc</div><div>${schedule.shiftLabel}</div></div></div>
                <div class="schedule-info-item"><span class="badge-status-approved"><i class="bi bi-check-circle me-1"></i>Đã xác nhận</span></div>
            </div>
        </div>

        <div class="admin-card">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <h6 class="mb-0"><i class="bi bi-people-fill me-1"></i>Bệnh nhân đã đặt: <strong>${bookedCount} / ${schedule.maxSlots}</strong></h6>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${not empty appointments}">
                        <div class="table-responsive">
                            <table class="admin-table">
                                <thead><tr><th>#</th><th>Bệnh nhân</th><th>Bác sĩ</th><th>Ngày khám</th><th>Giờ</th><th>Trạng thái</th><th>Đặt lúc</th></tr></thead>
                                <tbody>
                                    <c:forEach var="apt" items="${appointments}" varStatus="lp">
                                    <tr>
                                        <td class="text-muted small">${lp.index + 1}</td>
                                        <td><strong><c:out value="${apt.patientName}"/></strong></td>
                                        <td><c:out value="${apt.doctorName}"/></td>
                                        <td><fmt:formatDate value="${apt.appointmentDate}" pattern="dd/MM/yyyy"/></td>
                                        <td><c:out value="${apt.timeLabel}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${fn:toLowerCase(apt.status)=='waiting'}"><span class="badge bg-primary">Chờ khám</span></c:when>
                                                <c:when test="${fn:toLowerCase(apt.status)=='confirmed'}"><span class="badge bg-success">Đã XN</span></c:when>
                                                <c:when test="${fn:toLowerCase(apt.status)=='inprogress'}"><span class="badge bg-info text-dark">Đang khám</span></c:when>
                                                <c:when test="${fn:toLowerCase(apt.status)=='success'||fn:toLowerCase(apt.status)=='completed'}"><span class="badge bg-success">Hoàn thành</span></c:when>
                                                <c:when test="${fn:toLowerCase(apt.status)=='cancelled'}"><span class="badge bg-danger">Đã hủy</span></c:when>
                                                <c:otherwise><span class="badge bg-secondary"><c:out value="${apt.status}"/></span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="small text-muted">
                                            <c:choose>
                                                <c:when test="${not empty apt.createdAt}"><fmt:formatDate value="${apt.createdAt}" pattern="HH:mm dd/MM"/></c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5 text-muted"><i class="bi bi-people fs-2 d-block mb-2 opacity-25"></i>Chưa có bệnh nhân đặt lịch trong ca này.</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </c:if>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        if (links[i].href && links[i].href.indexOf('/manager/time-slots') !== -1) links[i].classList.add('active');
    }
})();
</script>
<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
