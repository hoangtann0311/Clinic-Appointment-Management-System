<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Khung giờ khám - CAMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/app-ui.css?v=202" rel="stylesheet">
    <script src="${pageContext.request.contextPath}/assets/js/app-ui.js?v=1" charset="UTF-8" defer></script>
    <style>.slot-locked { opacity: .48; background: #f3f4f6; } .slot-available { border-left: 4px solid #198754; }</style>
</head>
<body class="admin-body">
<nav class="admin-topbar"><div class="admin-topbar-left"><a href="${pageContext.request.contextPath}/admin/reception" class="admin-topbar-brand"><i class="bi bi-hospital-fill"></i> CAMS <span class="brand-badge">Lễ Tân</span></a></div><div class="admin-topbar-right"><a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a></div></nav>
<div class="wrapper">
    <aside class="admin-sidebar" id="adminSidebar"><div class="admin-sidebar-user"><div class="admin-sidebar-avatar"><c:choose><c:when test="${not empty sessionScope.user.fullName}">${fn:substring(sessionScope.user.fullName, 0, 1)}</c:when><c:otherwise><i class="bi bi-person-fill"></i></c:otherwise></c:choose></div><div class="admin-sidebar-name"><c:out value="${sessionScope.user.fullName}" default="Người dùng" /></div><span class="admin-sidebar-badge"><i class="bi bi-shield-check"></i> LỄ TÂN</span></div><ul class="admin-sidebar-menu"><li class="admin-sidebar-section">Tổng quan</li><li><a href="${pageContext.request.contextPath}/admin/reception"><i class="bi bi-speedometer2"></i><span>Hàng đợi tiếp đón</span></a></li><li class="admin-sidebar-section">Quản lý tiếp đón</li><li><a href="${pageContext.request.contextPath}/admin/reception/booking"><i class="bi bi-calendar-plus"></i><span>Đặt lịch thủ công</span></a></li><li><a href="${pageContext.request.contextPath}/admin/reception/doctor-schedules"><i class="bi bi-calendar-week"></i><span>Lịch làm việc bác sĩ</span></a></li><li><a class="active" href="${pageContext.request.contextPath}/admin/reception/slots"><i class="bi bi-grid-3x3-gap"></i><span>Khung giờ khám</span></a></li><li><a href="${pageContext.request.contextPath}/admin/reception/payments"><i class="bi bi-credit-card-2-front"></i><span>Xác nhận thanh toán</span></a></li></ul></aside>
    <main class="admin-main" id="adminMain">
        <div class="admin-page-header d-flex justify-content-between align-items-center"><div><h1 class="admin-page-title">Khung giờ khám</h1><div class="admin-page-subtitle">Khung giờ đã đặt hoặc đang giữ chỗ được làm mờ và không thể thao tác.</div></div><form method="get" class="d-flex gap-2"><input class="form-control" type="date" name="date" value="${selectedDate}"><button class="btn btn-primary" type="submit"><i class="bi bi-funnel"></i> Xem</button></form></div>
        <div class="d-flex gap-3 mb-3 small"><span><i class="bi bi-square-fill text-success"></i> Còn trống</span><span><i class="bi bi-square-fill text-secondary"></i> Đã đặt/đang giữ/không khả dụng</span></div>
        <div class="admin-card"><div class="card-body p-0"><div class="table-responsive"><table class="table align-middle mb-0"><thead><tr><th>Bác sĩ lâm sàng</th><th>Khung giờ</th><th>Trạng thái</th><th>Sản phụ</th><th>Hướng dẫn</th></tr></thead><tbody>
        <c:choose><c:when test="${empty slots}"><tr><td colspan="5" class="text-center text-muted py-5">Chưa có khung giờ thuộc lịch làm việc đã xác nhận cho ngày ${displayDate}.</td></tr></c:when><c:otherwise><c:forEach var="slot" items="${slots}"><tr class="${slot.available ? 'slot-available' : 'slot-locked'}"><td class="fw-bold">${slot.doctorName}</td><td>${slot.timeLabel}</td><td><c:choose><c:when test="${slot.available}"><span class="badge text-bg-success">Còn trống</span></c:when><c:otherwise><span class="badge text-bg-secondary"><c:choose><c:when test="${slot.status == 'AVAILABLE'}">Quá giờ</c:when><c:when test="${slot.status == 'BOOKED'}">Đã đặt</c:when><c:when test="${slot.status == 'HOLD'}">Đang giữ chỗ</c:when><c:otherwise>Không khả dụng</c:otherwise></c:choose></span></c:otherwise></c:choose></td><td>${not empty slot.bookedByName ? slot.bookedByName : '—'}</td><td><c:choose><c:when test="${slot.available}">Có thể chọn ở màn Đặt lịch thủ công.</c:when><c:otherwise><c:choose><c:when test="${slot.status == 'AVAILABLE'}"><i class="bi bi-clock-history me-1"></i>Khung giờ đã qua, không thể đặt.</c:when><c:otherwise><i class="bi bi-lock-fill me-1"></i>Đã khóa, không thao tác.</c:otherwise></c:choose></c:otherwise></c:choose></td></tr></c:forEach></c:otherwise></c:choose>
        </tbody></table></div></div></div>
    </main>
</div>
</body>
</html>
