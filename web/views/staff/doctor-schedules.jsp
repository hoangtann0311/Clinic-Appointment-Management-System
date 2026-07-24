<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch Làm Việc Bác Sĩ - CAMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/app-ui.css?v=202" rel="stylesheet">
    <script src="${pageContext.request.contextPath}/assets/js/app-ui.js?v=1" charset="UTF-8" defer></script>
</head>
<body class="admin-body">
<c:set var="requestURI" value="${pageContext.request.servletPath}"/>
<nav class="admin-topbar">
    <div class="admin-topbar-left"><a href="${pageContext.request.contextPath}/admin/reception" class="admin-topbar-brand"><i class="bi bi-hospital-fill"></i> CAMS <span class="brand-badge">Lễ Tân</span></a></div>
    <div class="admin-topbar-right"><span class="topbar-date d-none d-lg-flex"><i class="bi bi-calendar3"></i>${currentDisplayDate}</span><a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a></div>
</nav>
<div class="wrapper">
    <aside class="admin-sidebar" id="adminSidebar">
        <div class="admin-sidebar-user"><div class="admin-sidebar-avatar">${fn:substring(sessionScope.user.fullName,0,1)}</div><div class="admin-sidebar-name">${sessionScope.user.fullName}</div><span class="admin-sidebar-badge"><i class="bi bi-shield-check"></i> LỄ TÂN</span></div>
        <ul class="admin-sidebar-menu">
            <li class="admin-sidebar-section">Tổng quan</li>
            <li><a href="${pageContext.request.contextPath}/admin/reception"><i class="bi bi-speedometer2"></i><span>Hàng đợi tiếp đón</span></a></li>
            <li class="admin-sidebar-section">Quản lý tiếp đón</li>
            <li><a href="${pageContext.request.contextPath}/admin/reception/booking"><i class="bi bi-calendar-plus"></i><span>Đặt lịch thủ công</span></a></li>
            <li><a class="active" href="${pageContext.request.contextPath}/admin/reception/doctor-schedules"><i class="bi bi-calendar-week"></i><span>Lịch làm việc</span></a></li>
            <li><a href="${pageContext.request.contextPath}/admin/reception/slots"><i class="bi bi-grid-3x3-gap"></i><span>Khung giờ khám</span></a></li>
            <li><a href="${pageContext.request.contextPath}/admin/reception/payments"><i class="bi bi-credit-card-2-front"></i><span>Xác nhận thanh toán</span></a></li>
        </ul>
    </aside>
    <main class="admin-main" id="adminMain">
        <div class="admin-page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div><h1 class="admin-page-title">Lịch Làm Việc Bác Sĩ</h1><div class="admin-page-subtitle">Tra cứu nhanh để biết bác sĩ nào đang trực, còn bao nhiêu slot trống.</div></div>
            <form method="get" class="d-flex gap-2"><input class="form-control" type="date" name="date" value="${selectedDate}"><button class="btn btn-primary btn-sm" type="submit"><i class="bi bi-funnel me-1"></i>Xem</button></form>
        </div>
        <c:choose>
            <c:when test="${empty schedules}">
                <div class="admin-card"><div class="card-body text-center py-5 text-muted">Chưa có lịch làm việc nào được xác nhận cho ngày ${displayDate}.</div></div>
            </c:when>
            <c:otherwise>
                <div class="admin-card"><div class="card-body p-0">
                <table class="table table-hover align-middle mb-0" style="table-layout:fixed;width:100%;">
                    <thead class="table-light"><tr>
                        <th style="width:18%;">Bác sĩ</th>
                        <th style="width:14%;">Chuyên khoa</th>
                        <th style="width:11%;">Ca trực</th>
                        <th style="width:9%;" class="text-center">Tổng slot</th>
                        <th style="width:9%;" class="text-center">Đã đặt</th>
                        <th style="width:9%;" class="text-center">Còn trống</th>
                        <th style="width:30%;">Ghi chú</th>
                    </tr></thead>
                    <tbody>
                    <c:forEach var="s" items="${schedules}">
                        <c:set var="remaining" value="${s.maxSlots - s.bookedSlotCount}"/>
                        <tr>
                            <td class="fw-bold">${s.doctorName}</td>
                            <td>${not empty s.doctorSpecialization ? s.doctorSpecialization : 'Sản phụ khoa'}</td>
                            <td>${s.shiftLabel}</td>
                            <td class="text-center">${s.maxSlots}</td>
                            <td class="text-center"><span class="badge bg-secondary bg-opacity-75">${s.bookedSlotCount}</span></td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${remaining <= 0}"><span class="badge bg-danger bg-opacity-75">Hết</span></c:when>
                                    <c:when test="${remaining <= 3}"><span class="badge bg-warning text-dark">${remaining}</span></c:when>
                                    <c:otherwise><span class="badge bg-success bg-opacity-75">${remaining}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-muted small">${not empty s.notes ? s.notes : '—'}</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
                </div></div>
            </c:otherwise>
        </c:choose>
    </main>
</div>
</body>
</html>
