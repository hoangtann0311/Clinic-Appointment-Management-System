<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Sonographer Dashboard - CAMS</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
</head>
<body class="admin-body">

<jsp:include page="../common/header.jsp" />

<!-- Main Content Area -->
<div class="admin-page-header">
    <div class="admin-page-header-left">
        <h1 class="admin-page-title">Dashboard Thống Kê</h1>
        <div class="admin-page-subtitle">
            Tổng quan &gt; Số liệu siêu âm trong ngày hôm nay
        </div>
    </div>
</div>

<!-- Quick Statistics Row -->
<div class="row g-3 mb-4">
    <!-- SOS ALERT CARD (Only shows if there are active SOS cases today) -->
    <c:if test="${totalEmergencyToday > 0}">
        <div class="col-12">
            <div class="card bg-danger-subtle border-2 border-danger text-danger shadow-sm">
                <div class="card-body d-flex align-items-center justify-content-between py-3">
                    <div class="d-flex align-items-center gap-3">
                        <i class="bi bi-exclamation-triangle-fill fs-3 text-danger" style="animation: pulse-sos 1s infinite;"></i>
                        <div>
                            <h5 class="m-0 fw-bold">Cảnh Báo Khẩn Cấp SOS!</h5>
                            <p class="m-0 small text-danger-emphasis">Có <strong>${totalEmergencyToday}</strong> ca cần ưu tiên siêu âm khẩn cấp ngay hôm nay.</p>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/sonographer/waiting-list?emergency=true" class="btn btn-danger fw-bold btn-sm">Xem ngay</a>
                </div>
            </div>
        </div>
    </c:if>

    <!-- PENDING -->
    <div class="col-md-4 col-xl-2">
        <div class="admin-kpi-card text-start">
            <div class="kpi-icon-wrapper text-secondary bg-secondary-subtle">
                <i class="bi bi-hourglass-split"></i>
            </div>
            <div class="kpi-value">${totalPending}</div>
            <div class="kpi-label">Yêu Cầu Chờ</div>
            <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=Pending" class="stretched-link"></a>
        </div>
    </div>

    <!-- IN PROGRESS -->
    <div class="col-md-4 col-xl-2">
        <div class="admin-kpi-card text-start">
            <div class="kpi-icon-wrapper text-primary bg-primary-subtle">
                <i class="bi bi-play-circle"></i>
            </div>
            <div class="kpi-value">${totalInProgress}</div>
            <div class="kpi-label">Đang Siêu Âm</div>
            <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=InProgress" class="stretched-link"></a>
        </div>
    </div>

    <!-- UPLOADED -->
    <div class="col-md-4 col-xl-2">
        <div class="admin-kpi-card text-start">
            <div class="kpi-icon-wrapper text-warning bg-warning-subtle">
                <i class="bi bi-cloud-upload"></i>
            </div>
            <div class="kpi-value">${totalUploaded}</div>
            <div class="kpi-label">Đã Tải Ảnh (Chờ AI)</div>
            <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=Uploaded" class="stretched-link"></a>
        </div>
    </div>

    <!-- ANALYZING -->
    <div class="col-md-4 col-xl-2">
        <div class="admin-kpi-card text-start">
            <div class="kpi-icon-wrapper text-info bg-info-subtle">
                <i class="bi bi-cpu" style="animation: spin 3s infinite linear;"></i>
            </div>
            <div class="kpi-value">${totalAnalyzing}</div>
            <div class="kpi-label">AI Đang Phân Tích</div>
            <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=Analyzing" class="stretched-link"></a>
        </div>
    </div>

    <!-- COMPLETED -->
    <div class="col-md-4 col-xl-2">
        <div class="admin-kpi-card text-start">
            <div class="kpi-icon-wrapper text-success bg-success-subtle">
                <i class="bi bi-check-circle"></i>
            </div>
            <div class="kpi-value">${totalCompletedToday}</div>
            <div class="kpi-label">Hoàn Thành Hôm Nay</div>
            <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=Completed" class="stretched-link"></a>
        </div>
    </div>
</div>

<!-- Recent Requests List -->
<div class="admin-card">
    <div class="card-header bg-white py-3">
        <h5 class="m-0 fw-bold text-dark d-flex align-items-center gap-2">
            <i class="bi bi-clock-history text-primary"></i> 
            Các Yêu Cầu Siêu Âm Gần Nhất (Hôm Nay)
        </h5>
    </div>
    <div class="card-body p-0">
        <div class="admin-table-wrapper">
            <table class="admin-table table-cams">
                <thead>
                    <tr>
                        <th>Mã Yêu Cầu</th>
                        <th>Sản Phụ</th>
                        <th>Dịch Vụ Chỉ Định</th>
                        <th>Bác Sĩ Chỉ Định</th>
                        <th>Mức Ưu Tiên</th>
                        <th>Trạng Thái</th>
                        <th>Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty recentOrders}">
                            <tr>
                                <td colspan="7" class="text-center text-muted py-5">
                                    Chưa có chỉ định siêu âm nào được thực hiện hôm nay.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="order" items="${recentOrders}">
                                <tr>
                                    <td><strong>SA-${order.orderId}</strong></td>
                                    <td>
                                        <span class="fw-bold text-dark"><c:out value="${order.patientName}"/></span><br>
                                        <small class="text-muted"><c:out value="${order.phoneNumber}"/></small>
                                    </td>
                                    <td><c:out value="${order.serviceName}"/></td>
                                    <td><c:out value="${order.doctorName}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${order.emergency}">
                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle font-weight-bold">
                                                    <i class="bi bi-exclamation-triangle-fill"></i> SOS
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-muted border">Thường</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${order.status == 'Pending'}">
                                                <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle">Chờ tiếp nhận</span>
                                            </c:when>
                                            <c:when test="${order.status == 'InProgress'}">
                                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle">Đang tiến hành</span>
                                            </c:when>
                                            <c:when test="${order.status == 'Uploaded'}">
                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle">Đã tải ảnh</span>
                                            </c:when>
                                            <c:when test="${order.status == 'Analyzing'}">
                                                <span class="badge bg-info-subtle text-info border border-info-subtle">AI Đang phân tích</span>
                                            </c:when>
                                            <c:when test="${order.status == 'Completed'}">
                                                <span class="badge bg-success-subtle text-success border border-success-subtle">Hoàn thành</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-muted border"><c:out value="${order.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/sonographer/detail?orderId=${order.orderId}" class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-eye"></i> Chi tiết
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />

<style>
    @keyframes pulse-sos {
        0% { transform: scale(1); opacity: 1; }
        50% { transform: scale(1.1); opacity: 0.8; }
        100% { transform: scale(1); opacity: 1; }
    }
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
</style>
</body>
</html>
