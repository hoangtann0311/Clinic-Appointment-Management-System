<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="../common/header.jsp" />

<!-- Main Content Area -->
<div class="admin-page-header">
    <div class="admin-page-header-left">
        <h1 class="admin-page-title">Tổng Quan Siêu Âm</h1>
        <div class="admin-page-subtitle">
            <i class="bi bi-calendar3"></i>
            <span>${not empty displayDate ? displayDate : 'Hôm nay'}</span>
        </div>
    </div>
    <form action="${pageContext.request.contextPath}/sonographer/dashboard"
          method="get"
          class="d-flex align-items-center gap-2">
        <input type="date"
               name="date"
               class="form-control"
               style="width: 170px;"
               value="${selectedDate}">

        <button type="submit" class="btn-refresh">
            <i class="bi bi-search"></i> Xem
        </button>

        <a href="${pageContext.request.contextPath}/sonographer/dashboard" class="btn-refresh">
            <i class="bi bi-calendar-check"></i> Hôm nay
        </a>
    </form>
</div>

<!-- Quick Statistics Row -->
<div class="row g-3 mb-4">
    <!-- PENDING -->
    <div class="col-xl col-md-4 col-sm-6">
        <div class="card clinical-kpi kpi-card kpi-pending">
            <div class="card-body">
                <div class="kpi-icon">
                    <i class="bi bi-hourglass-split"></i>
                </div>
                <div class="kpi-content">
                    <div class="kpi-value">${totalPending}</div>
                    <div class="kpi-label">Yêu Cầu Chờ</div>
                    <div class="kpi-sub"><i class="bi bi-clock"></i> Đang chờ tiếp nhận</div>
                </div>
                <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=Pending" class="stretched-link"></a>
            </div>
        </div>
    </div>

    <!-- IN PROGRESS -->
    <div class="col-xl col-md-4 col-sm-6">
        <div class="card clinical-kpi kpi-card kpi-inprogress">
            <div class="card-body">
                <div class="kpi-icon">
                    <i class="bi bi-play-circle"></i>
                </div>
                <div class="kpi-content">
                    <div class="kpi-value">${totalInProgress}</div>
                    <div class="kpi-label">Đang Siêu Âm</div>
                    <div class="kpi-sub"><i class="bi bi-activity"></i> Đang thực hiện</div>
                </div>
                <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=InProgress" class="stretched-link"></a>
            </div>
        </div>
    </div>

    <!-- UPLOADED -->
    <div class="col-xl col-md-4 col-sm-6">
        <div class="card clinical-kpi kpi-card kpi-uploaded clinical-kpi--warning">
            <div class="card-body">
                <div class="kpi-icon">
                    <i class="bi bi-cloud-upload"></i>
                </div>
                <div class="kpi-content">
                    <div class="kpi-value">${totalUploaded}</div>
                    <div class="kpi-label">Đã tải ảnh</div>
                    <div class="kpi-sub"><i class="bi bi-cpu"></i> Chờ AI hoặc duyệt ảnh</div>
                </div>
                <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=Uploaded" class="stretched-link"></a>
            </div>
        </div>
    </div>

    <!-- COMPLETED -->
    <div class="col-xl col-md-4 col-sm-6">
        <div class="card clinical-kpi kpi-card kpi-completed clinical-kpi--success">
            <div class="card-body">
                <div class="kpi-icon">
                    <i class="bi bi-check-circle"></i>
                </div>
                <div class="kpi-content">
                    <div class="kpi-value">${totalCompletedToday}</div>
                    <div class="kpi-label">${selectedDate == currentDisplayDate ? 'Hoàn Thành Hôm Nay' : 'Hoàn Thành Trong Ngày'}</div>
                    <div class="kpi-sub"><i class="bi bi-check2-all"></i> Đã hoàn thành</div>
                </div>
                <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=Completed" class="stretched-link"></a>
            </div>
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
                        <th>Bác sĩ lâm sàng chỉ định</th>
                        <th>Trạng Thái</th>
                        <th>Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty recentOrders}">
                            <tr>
                                <td colspan="6" class="text-center text-muted py-5">
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
                                            <c:when test="${fn:toLowerCase(order.status) == 'pending'}">
                                                <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle">Chờ tiếp nhận</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(order.status) == 'inprogress'}">
                                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle">Đang tiến hành</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(order.status) == 'uploaded'}">
                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle">Đã tải ảnh</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(order.status) == 'analyzing'}">
                                                <span class="badge bg-info-subtle text-info border border-info-subtle">AI Đang phân tích</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(order.status) == 'completed'}">
                                                <span class="badge bg-success-subtle text-success border border-success-subtle">Hoàn thành</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(order.status) == 'confirmed'}">
                                                <span class="badge bg-success text-white border border-success">Đã xác nhận</span>
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

<style>
    /* KPI Cards Styling matching Staff page */
    .kpi-card {
        background: var(--c-surface) !important;
        border: 1px solid var(--c-outline-variant) !important;
        border-radius: var(--r-lg) !important;
        box-shadow: var(--shadow-sm) !important;
        transition: transform var(--t-normal), box-shadow var(--t-normal), border-color var(--t-normal);
        position: relative;
        overflow: hidden;
        height: 100%;
    }
    .kpi-card:hover {
        transform: translateY(-4px);
        box-shadow: var(--shadow-md) !important;
        border-color: var(--pink-300) !important;
    }
    .kpi-card .card-body {
        padding: 1.25rem 1.3rem !important;
        display: flex !important;
        align-items: center !important;
        gap: 1.1rem !important;
    }
    .kpi-icon {
        width: 52px;
        height: 52px;
        border-radius: var(--r-md);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.4rem;
        flex-shrink: 0;
        transition: transform var(--t-normal);
    }
    .kpi-card:hover .kpi-icon {
        transform: scale(1.08) rotate(4deg);
    }
    .kpi-content {
        flex-grow: 1;
        min-width: 0;
    }
    .kpi-value {
        font-size: 1.9rem;
        font-weight: 800;
        color: var(--c-on-bg);
        line-height: 1.1;
        margin-bottom: 0.2rem;
        letter-spacing: -0.02em;
    }
    .kpi-label {
        font-size: 0.85rem;
        font-weight: 700;
        color: var(--c-on-surface-var);
        margin-bottom: 0.15rem;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .kpi-sub {
        font-size: 0.72rem;
        color: var(--c-muted);
        display: flex;
        align-items: center;
        gap: 0.3rem;
        white-space: nowrap;
    }

    /* Individual Card Styles */
    .kpi-pending {
        border-left: 4px solid #6c757d !important;
    }
    .kpi-pending .kpi-icon {
        background: #f1f3f5;
        color: #495057;
    }

    .kpi-inprogress {
        border-left: 4px solid #0d6efd !important;
    }
    .kpi-inprogress .kpi-icon {
        background: #e7f1ff;
        color: #0d6efd;
    }

    .kpi-uploaded {
        border-left: 4px solid #f59e0b !important;
    }
    .kpi-uploaded .kpi-icon {
        background: #fffbeb;
        color: #d97706;
    }

    .kpi-completed {
        border-left: 4px solid #198754 !important;
    }
    .kpi-completed .kpi-icon {
        background: #e8f5e9;
        color: #2e7d32;
    }

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

<%@ include file="../common/footer.jsp" %>
