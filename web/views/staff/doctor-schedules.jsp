<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch làm việc Bác sĩ lâm sàng - CAMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/app-ui.css?v=202" rel="stylesheet">
    <script src="${pageContext.request.contextPath}/assets/js/app-ui.js?v=1" charset="UTF-8" defer></script>
</head>
<body class="admin-body">
<c:set var="requestURI" value="${pageContext.request.servletPath}" />
<nav class="admin-topbar">
    <div class="admin-topbar-left"><a href="${pageContext.request.contextPath}/admin/reception" class="admin-topbar-brand"><i class="bi bi-hospital-fill"></i> CAMS <span class="brand-badge">Lễ Tân</span></a></div>
    <div class="admin-topbar-right"><span class="topbar-date d-none d-lg-flex"><i class="bi bi-calendar3"></i>${currentDisplayDate}</span><a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a></div>
</nav>
<div class="wrapper">
    <aside class="admin-sidebar" id="adminSidebar">
        <div class="admin-sidebar-user"><div class="admin-sidebar-avatar">${fn:substring(sessionScope.user.fullName, 0, 1)}</div><div class="admin-sidebar-name">${sessionScope.user.fullName}</div><span class="admin-sidebar-badge"><i class="bi bi-shield-check"></i> LỄ TÂN</span></div>
        <ul class="admin-sidebar-menu">
            <li class="admin-sidebar-section">Tổng quan</li>
            <li><a href="${pageContext.request.contextPath}/admin/reception"><i class="bi bi-speedometer2"></i><span>Hàng đợi tiếp đón</span></a></li>
            <li class="admin-sidebar-section">Quản lý tiếp đón</li>
            <li><a href="${pageContext.request.contextPath}/admin/reception/booking"><i class="bi bi-calendar-plus"></i><span>Đặt lịch thủ công</span></a></li>
            <li><a class="active" href="${pageContext.request.contextPath}/admin/reception/doctor-schedules"><i class="bi bi-calendar-week"></i><span>Lịch làm việc Bác sĩ</span></a></li>
            <li><a href="${pageContext.request.contextPath}/admin/reception/slots"><i class="bi bi-grid-3x3-gap"></i><span>Khung giờ khám</span></a></li>
            <li><a href="${pageContext.request.contextPath}/admin/reception/payments"><i class="bi bi-credit-card-2-front"></i><span>Xác nhận thanh toán</span></a></li>
        </ul>
    </aside>
    <main class="admin-main" id="adminMain">
        <div class="admin-page-header d-flex justify-content-between align-items-center">
            <div><h1 class="admin-page-title">Lịch Làm Việc Bác Sĩ</h1><div class="admin-page-subtitle">Tra cứu lịch làm việc đã được quản lý xác nhận.</div></div>
            <form method="get" class="d-flex gap-2"><input class="form-control" type="date" name="date" value="${selectedDate}"><button class="btn btn-primary" type="submit"><i class="bi bi-funnel"></i> Xem</button></form>
        </div>
        <div class="alert alert-info"><i class="bi bi-info-circle me-2"></i>Lễ tân chỉ tra cứu để tư vấn và đặt lịch, không chỉnh sửa lịch làm việc hoặc khung giờ tại đây.</div>
        <div class="admin-card"><div class="card-body p-0"><div class="table-responsive"><table class="table align-middle mb-0"><thead><tr><th>Bác sĩ lâm sàng</th><th>Chuyên môn</th><th>Ca làm việc</th><th class="text-center">Tổng khung giờ</th><th class="text-center">Đã đặt</th><th class="text-center">Còn trống</th><th>Ghi chú</th></tr></thead><tbody>
        <c:choose><c:when test="${empty schedules}"><tr><td colspan="7" class="text-center text-muted py-5">Chưa có lịch làm việc đã được xác nhận cho ngày ${displayDate}.</td></tr></c:when><c:otherwise><c:forEach var="schedule" items="${schedules}"><tr><td class="fw-bold">${schedule.doctorName}</td><td>${not empty schedule.doctorSpecialization ? schedule.doctorSpecialization : 'Sản phụ khoa'}</td><td>${schedule.shiftLabel}</td><td class="text-center">${schedule.maxSlots}</td><td class="text-center"><span class="badge text-bg-secondary">${schedule.bookedSlotCount}</span></td><td class="text-center"><span class="badge text-bg-success">${schedule.maxSlots - schedule.bookedSlotCount}</span></td><td>${not empty schedule.notes ? schedule.notes : '—'}</td></tr></c:forEach></c:otherwise></c:choose>
        </tbody></table></div></div></div>
    </main>
</div>
</body>
</html>
