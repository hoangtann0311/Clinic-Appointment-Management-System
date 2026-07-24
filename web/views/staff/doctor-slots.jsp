<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Khung Giờ Khám - CAMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/app-ui.css?v=202" rel="stylesheet">
    <script src="${pageContext.request.contextPath}/assets/js/app-ui.js?v=1" charset="UTF-8" defer></script>
    <style>
        .slot-row-available { border-left: 4px solid #198754; }
        .slot-row-locked { opacity: .5; background: #f8f9fa; }
        .st-badge { font-size: .72rem; padding: .18rem .5rem; border-radius: 2rem; font-weight: 600; }
    </style>
</head>
<body class="admin-body">
<c:set var="requestURI" value="${pageContext.request.servletPath}"/>
<nav class="admin-topbar">
    <div class="admin-topbar-left"><a href="${pageContext.request.contextPath}/admin/reception" class="admin-topbar-brand"><i class="bi bi-hospital-fill"></i> CAMS <span class="brand-badge">Lễ Tân</span></a></div>
    <div class="admin-topbar-right"><span class="topbar-date d-none d-lg-flex"><i class="bi bi-calendar3"></i>${not empty currentDisplayDate ? currentDisplayDate : 'Hôm nay'}</span><a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a></div>
</nav>
<div class="wrapper">
    <aside class="admin-sidebar" id="adminSidebar">
        <div class="admin-sidebar-user"><div class="admin-sidebar-avatar"><c:choose><c:when test="${not empty sessionScope.user.fullName}">${fn:substring(sessionScope.user.fullName,0,1)}</c:when><c:otherwise><i class="bi bi-person-fill"></i></c:otherwise></c:choose></div><div class="admin-sidebar-name"><c:out value="${sessionScope.user.fullName}" default="Người dùng"/></div><span class="admin-sidebar-badge"><i class="bi bi-shield-check"></i> LỄ TÂN</span></div>
        <ul class="admin-sidebar-menu">
            <li class="admin-sidebar-section">Tổng quan</li>
            <li><a href="${pageContext.request.contextPath}/admin/reception"><i class="bi bi-speedometer2"></i><span>Hàng đợi tiếp đón</span></a></li>
            <li class="admin-sidebar-section">Quản lý tiếp đón</li>
            <li><a href="${pageContext.request.contextPath}/admin/reception/booking"><i class="bi bi-calendar-plus"></i><span>Đặt lịch thủ công</span></a></li>
            <li><a href="${pageContext.request.contextPath}/admin/reception/doctor-schedules"><i class="bi bi-calendar-week"></i><span>Lịch làm việc</span></a></li>
            <li><a class="active" href="${pageContext.request.contextPath}/admin/reception/slots"><i class="bi bi-grid-3x3-gap"></i><span>Khung giờ khám</span></a></li>
            <li><a href="${pageContext.request.contextPath}/admin/reception/payments"><i class="bi bi-credit-card-2-front"></i><span>Xác nhận thanh toán</span></a></li>
        </ul>
    </aside>
    <main class="admin-main" id="adminMain">
        <div class="admin-page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div><h1 class="admin-page-title">Khung Giờ Khám</h1><div class="admin-page-subtitle">Xem chi tiết từng slot — ai đặt, trạng thái gì, giá bao nhiêu.</div></div>
            <form method="get" class="d-flex gap-2"><input class="form-control" type="date" name="date" value="${selectedDate}"><button class="btn btn-primary btn-sm" type="submit"><i class="bi bi-funnel me-1"></i>Xem</button></form>
        </div>
        <div class="d-flex gap-3 mb-3 small">
            <span><span class="badge bg-success bg-opacity-75 me-1">&nbsp;</span> Trống</span>
            <span><span class="badge bg-secondary bg-opacity-50 me-1">&nbsp;</span> Đã đặt / giữ chỗ / hết giờ</span>
        </div>
        <c:choose>
            <c:when test="${empty slots}">
                <div class="admin-card"><div class="card-body text-center py-5 text-muted">Chưa có khung giờ nào cho ngày ${displayDate}.</div></div>
            </c:when>
            <c:otherwise>
                <div class="admin-card"><div class="card-body p-0">
                <table class="table align-middle mb-0" style="table-layout:fixed;width:100%;">
                    <thead class="table-light"><tr>
                        <th style="width:16%;">Bác sĩ</th>
                        <th style="width:12%;">Giờ</th>
                        <th style="width:9%;">Giá</th>
                        <th style="width:10%;">Trạng thái</th>
                        <th style="width:14%;">Bệnh nhân</th>
                        <th style="width:39%;">Ghi chú</th>
                    </tr></thead>
                    <tbody>
                    <c:forEach var="s" items="${slots}">
                        <tr class="${s.available ? 'slot-row-available' : 'slot-row-locked'}">
                            <td class="fw-bold">${s.doctorName}</td>
                            <td>${s.timeLabel}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${s.price != null && s.price > 0}">
                                        <fmt:formatNumber value="${s.price}" pattern="#,###"/>đ
                                    </c:when>
                                    <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${s.available}"><span class="st-badge bg-success bg-opacity-75 text-white">Trống</span></c:when>
                                    <c:when test="${s.status == 'BOOKED'}"><span class="st-badge bg-danger bg-opacity-75 text-white">Đã đặt</span></c:when>
                                    <c:when test="${s.status == 'HELD'}"><span class="st-badge bg-warning text-dark">Giữ chỗ</span></c:when>
                                    <c:when test="${s.status == 'AVAILABLE'}"><span class="st-badge bg-secondary text-white">Quá giờ</span></c:when>
                                    <c:otherwise><span class="st-badge bg-secondary text-white">${s.status}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>${not empty s.bookedByName ? s.bookedByName : '—'}</td>
                            <td class="text-muted small">
                                <c:choose>
                                    <c:when test="${s.available}">Có thể đặt qua màn Đặt lịch thủ công.</c:when>
                                    <c:when test="${s.status == 'AVAILABLE'}">Đã qua giờ, không thể đặt.</c:when>
                                    <c:otherwise>Không thể thao tác.</c:otherwise>
                                </c:choose>
                            </td>
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
