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

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        /* Slot-specific styles — Pink theme */
        .badge-slot-available {
            background: #e8f5e9; color: #2e7d32;
            border: 1px solid #a5d6a7; font-weight: 600;
            border-radius: 0.375rem; padding: 0.25rem 0.65rem;
            font-size: 0.78rem;
        }
        .badge-slot-booked {
            background: #e3f2fd; color: #1565c0;
            border: 1px solid #90caf9; font-weight: 600;
            border-radius: 0.375rem; padding: 0.25rem 0.65rem;
            font-size: 0.78rem;
        }
        .badge-slot-completed {
            background: #f3e5f5; color: #6a1b9a;
            border: 1px solid #ce93d8; font-weight: 600;
            border-radius: 0.375rem; padding: 0.25rem 0.65rem;
            font-size: 0.78rem;
        }
        .badge-slot-cancelled {
            background: #ffebee; color: #c62828;
            border: 1px solid #ef9a9a; font-weight: 600;
            border-radius: 0.375rem; padding: 0.25rem 0.65rem;
            font-size: 0.78rem;
        }

        .booked-patient-info {
            font-size: 0.68rem; color: var(--c-muted);
            margin-top: 0.25rem; font-weight: 500;
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }

        .warning-banner {
            background: #fff3e0; border: 2px solid #ff9800;
            border-radius: var(--r-md); padding: 1rem 1.25rem;
            margin-bottom: 1.25rem; display: flex; align-items: flex-start; gap: 0.75rem;
        }
        .warning-banner i { color: #e65100; font-size: 1.5rem; flex-shrink: 0; }
        .warning-banner-body { flex: 1; }
        .warning-banner-title { font-weight: 800; color: #e65100; margin-bottom: 0.25rem; }
        .warning-banner-text { font-size: 0.85rem; color: #bf360c; }

        .schedule-info-card {
            background: linear-gradient(135deg, var(--pink-50), #fff1f6);
            border: 1px solid var(--pink-200);
            border-radius: var(--r-md);
            padding: 1.25rem;
            margin-bottom: 1.25rem;
        }
        .schedule-info-row {
            display: flex; flex-wrap: wrap; gap: 1.25rem; align-items: center;
        }
        .schedule-info-item {
            display: flex; align-items: center; gap: 0.5rem;
            font-size: 0.9rem; font-weight: 600; color: var(--c-on-surface);
        }
        .schedule-info-item i {
            color: var(--pink-500); font-size: 1.1rem;
        }
        .schedule-info-label {
            font-size: 0.7rem; font-weight: 600; color: var(--c-muted);
            text-transform: uppercase; letter-spacing: 0.05em;
        }

        .kpi-mini-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 0.75rem; margin-bottom: 1.25rem;
        }
        .kpi-mini {
            background: var(--c-surface);
            border: 1px solid var(--c-outline-variant);
            border-radius: var(--r-md);
            padding: 1rem 1.1rem;
            display: flex; align-items: center; gap: 0.875rem;
            transition: all var(--t-smooth);
        }
        .kpi-mini:hover {
            border-color: var(--pink-200);
            box-shadow: var(--shadow-sm);
            transform: translateY(-2px);
        }
        .kpi-mini-icon {
            width: 44px; height: 44px;
            border-radius: var(--r-sm);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.2rem; flex-shrink: 0; color: #fff;
        }
        .kmi-available   { background: linear-gradient(135deg, #2e7d32, #43a047); }
        .kmi-booked      { background: linear-gradient(135deg, #1565c0, #42a5f5); }
        .kmi-completed   { background: linear-gradient(135deg, #6a1b9a, #ab47bc); }
        .kmi-total       { background: linear-gradient(135deg, #6366f1, #4f46e5); }
        .kpi-mini-body { flex: 1; min-width: 0; }
        .kpi-mini-value {
            font-family: var(--font-display);
            font-size: 1.3rem; font-weight: 900;
            color: var(--c-on-surface); line-height: 1.1;
        }
        .kpi-mini-label {
            font-size: 0.7rem; font-weight: 600; color: var(--c-muted);
            text-transform: uppercase; letter-spacing: 0.05em;
        }

        .slot-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
            gap: 0.5rem;
        }
        .slot-card {
            background: var(--c-surface);
            border: 1px solid var(--c-outline-variant);
            border-radius: var(--r-sm);
            padding: 0.65rem 0.75rem;
            text-align: center;
            transition: all var(--t-fast);
            cursor: default;
        }
        .slot-card:hover {
            border-color: var(--pink-300);
            box-shadow: 0 2px 8px rgba(184,102,137,0.08);
        }
        .slot-card.available {
            border-left: 3px solid #43a047;
            background: #f1f8e9;
        }
        .slot-card.booked {
            border-left: 3px solid #1e88e5;
            background: #e3f2fd;
        }
        .slot-card.completed {
            border-left: 3px solid #8e24aa;
            background: #f3e5f5;
        }
        .slot-card.cancelled {
            border-left: 3px solid #e53935;
            background: #ffebee;
            opacity: 0.65;
        }
        .slot-time {
            font-family: var(--font-display);
            font-weight: 800; font-size: 0.9rem;
            color: var(--c-on-surface);
            letter-spacing: 0.02em;
        }
        .slot-number {
            font-size: 0.68rem; color: var(--c-muted);
            font-weight: 600;
        }

        .btn-primary-pink {
            background: linear-gradient(135deg, var(--pink-500), var(--pink-600));
            color: #fff; border: none; font-weight: 700;
            border-radius: var(--r-sm); padding: 0.55rem 1.2rem;
            transition: all var(--t-fast);
        }
        .btn-primary-pink:hover {
            background: linear-gradient(135deg, var(--pink-600), var(--pink-700));
            color: #fff; transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(184,102,137,0.3);
        }

        .admin-pagination {
            display: flex; justify-content: center; gap: 0.25rem; margin-top: 1.25rem;
        }
        .admin-pagination a, .admin-pagination span {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 38px; height: 38px; padding: 0 0.5rem;
            border-radius: var(--r-sm);
            font-size: 0.85rem; font-weight: 600; text-decoration: none;
            border: 1px solid var(--c-outline-variant);
            color: var(--c-on-surface-var);
            transition: all var(--t-fast);
        }
        .admin-pagination a:hover {
            background: var(--pink-50); border-color: var(--pink-200);
            color: var(--c-primary);
        }
        .admin-pagination .active {
            background: var(--pink-500); color: #fff; border-color: var(--pink-500);
        }
        .admin-pagination .disabled {
            opacity: 0.4; pointer-events: none;
        }

        .empty-state {
            text-align: center; padding: 3rem 1.5rem; color: var(--c-muted);
        }
        .empty-state i {
            font-size: 3.5rem; display: block; margin-bottom: 1rem; color: var(--c-outline);
        }
        .empty-state h5 {
            font-family: var(--font-display); font-weight: 700;
            color: var(--c-on-surface); margin-bottom: 0.4rem;
        }
        .empty-state p {
            font-size: 0.85rem; max-width: 420px; margin: 0 auto 1.25rem;
        }

        .shift-badge-morning {
            background: #e3f2fd; color: #1565c0;
            padding: 0.2rem 0.6rem; border-radius: 0.375rem;
            font-weight: 600; font-size: 0.78rem; white-space: nowrap;
        }
        .shift-badge-afternoon {
            background: #fff3e0; color: #e65100;
            padding: 0.2rem 0.6rem; border-radius: 0.375rem;
            font-weight: 600; font-size: 0.78rem; white-space: nowrap;
        }
        .shift-badge-evening {
            background: #f3e5f5; color: #7b1fa2;
            padding: 0.2rem 0.6rem; border-radius: 0.375rem;
            font-weight: 600; font-size: 0.78rem; white-space: nowrap;
        }

        .btn-outline-primary {
            border-color: var(--pink-400); color: var(--pink-600);
            font-weight: 600; border-radius: var(--r-sm);
            transition: all var(--t-fast);
        }
        .btn-outline-primary:hover {
            background: var(--pink-50); border-color: var(--pink-500);
            color: var(--pink-700);
        }
    </style>
</head>
<body class="admin-body">

<%-- ============================================================
     TOP BAR
     ============================================================ --%>
<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/manager/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i>
            CAMS
            <span class="brand-badge">Quản Lý</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role"><i class="bi bi-briefcase-fill me-1"></i>Quản Lý</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout" title="Đăng xuất">
            <i class="bi bi-box-arrow-right"></i>
            <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
    </div>
</nav>

<%-- ============================================================
     SIDEBAR
     ============================================================ --%>
<%@ include file="../layout/sidebar.jsp" %>

<%-- ============================================================
     MAIN CONTENT
     ============================================================ --%>
<main class="admin-main" id="adminMain">

    <%-- Page Header --%>
    <div class="admin-page-header">
        <div>
            <h1 class="admin-page-title">
                <i class="bi bi-clock-fill me-2" style="color:#b86689;"></i>Khung Giờ Khám
            </h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-calendar-check"></i>
                Danh sách khung giờ khám 20 phút được sinh tự động từ lịch làm việc đã xác nhận
            </div>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/manager/schedules/?status=APPROVED"
               class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left me-1"></i>Quay lại Lịch Làm Việc
            </a>
        </div>
    </div>

    <%-- ============================================================
         ALERT MESSAGES
         ============================================================ --%>
    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md);">
            <c:choose>
                <c:when test="${success eq 'generated'}">
                    <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                    <div><strong>Sinh khung giờ thành công!</strong> Đã tạo ${generatedCount} khung giờ khám (20 phút/khung giờ).</div>
                </c:when>
                <c:when test="${success eq 'deleted'}">
                    <i class="bi bi-trash-fill me-2 fs-5"></i>
                    <div><strong>Đã xóa!</strong> Tất cả khung giờ khám của lịch làm việc này đã bị xóa.</div>
                </c:when>
                <c:otherwise>
                    <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                    <div>Thao tác thành công.</div>
                </c:otherwise>
            </c:choose>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md);">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
            <div>${fn:escapeXml(error)}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty warning}">
        <div class="alert alert-warning alert-dismissible fade show d-flex align-items-center" role="alert" style="border-radius:var(--r-md);">
            <i class="bi bi-exclamation-circle-fill me-2 fs-5"></i>
            <div>${fn:escapeXml(warning)}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <%-- ============================================================
         OVERVIEW MODE: Danh sách lịch trực đã duyệt + trạng thái slot
         ============================================================ --%>
    <c:if test="${overviewMode}">
        <div class="admin-card mb-3">
            <div class="card-header admin-card-header-link d-flex justify-content-between align-items-center">
                <h5><i class="bi bi-list-check me-2" style="color:#b86689;"></i>Lịch Làm Việc Đã Xác Nhận — Quản Lý Khung Giờ</h5>
                <span class="badge bg-white text-dark border" style="font-size:0.78rem;">
                    <i class="bi bi-calendar-check me-1"></i>${fn:length(approvedSchedules)} lịch làm việc
                </span>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${not empty approvedSchedules}">
                        <div class="admin-table-wrapper">
                            <table class="admin-table">
                                <thead>
                                    <tr>
                                        <th>STT</th>
                                        <th>Bác Sĩ</th>
                                        <th>Ngày Trực</th>
                                        <th>Ca Làm Việc</th>
                                        <th>Khung Giờ</th>
                                        <th style="width:140px;">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="sched" items="${approvedSchedules}" varStatus="row">
                                        <tr>
                                            <td style="color:var(--c-muted);font-size:0.8rem;">${row.count}</td>
                                            <td style="font-weight:600;">
                                                <i class="bi bi-person-badge me-1" style="color:var(--pink-500);"></i>
                                                ${fn:escapeXml(sched.doctorName)}
                                            </td>
                                            <td style="font-weight:600;">
                                                <i class="bi bi-calendar3 me-1" style="color:var(--pink-500);"></i>
                                                <fmt:formatDate value="${sched.workDate}" pattern="dd/MM/yyyy"/>
                                            </td>
                                            <td>
                                                <c:set var="startHour" value="${fn:substring(sched.startTime, 0, 2)}"/>
                                                <c:choose>
                                                    <c:when test="${startHour < '12'}">
                                                        <span class="shift-badge-morning"><i class="bi bi-sunrise-fill me-1"></i>${sched.shiftLabel}</span>
                                                    </c:when>
                                                    <c:when test="${startHour < '17'}">
                                                        <span class="shift-badge-afternoon"><i class="bi bi-sun-fill me-1"></i>${sched.shiftLabel}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="shift-badge-evening"><i class="bi bi-moon-fill me-1"></i>${sched.shiftLabel}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:set var="count" value="${slotCounts[sched.id]}"/>
                                                <c:choose>
                                                    <c:when test="${count != null and count > 0}">
                                                        <span class="badge-slot-available">
                                                            <i class="bi bi-check-circle-fill me-1"></i>${count} khung giờ
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-slot-cancelled">
                                                            <i class="bi bi-exclamation-circle-fill me-1"></i>Chưa sinh
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="d-flex gap-1">
                                                    <c:choose>
                                                        <c:when test="${count != null and count > 0}">
                                                            <a href="${pageContext.request.contextPath}/manager/time-slots/?scheduleId=${sched.id}"
                                                               class="btn btn-sm btn-outline-primary" title="Xem khung giờ">
                                                                <i class="bi bi-eye-fill"></i> Xem
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="${pageContext.request.contextPath}/manager/time-slots/?scheduleId=${sched.id}"
                                                               class="btn btn-sm btn-primary-pink" title="Sinh khung giờ">
                                                                <i class="bi bi-lightning-charge-fill"></i> Sinh Khung Giờ
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state" style="padding:2.5rem 1.5rem;">
                            <i class="bi bi-calendar-x" style="font-size:3rem;color:var(--c-muted);"></i>
                            <h5>Chưa Có Lịch Làm Việc Được Xác Nhận</h5>
                            <p>Không có lịch làm việc nào đã được xác nhận. Vui lòng xác nhận lịch trước khi quản lý khung giờ khám.</p>
                            <a href="${pageContext.request.contextPath}/manager/schedules/?status=PENDING"
                               class="btn btn-primary-pink">
                                <i class="bi bi-calendar-check me-1"></i>Đi Đến Lịch Làm Việc
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </c:if>

    <%-- ============================================================
         SCHEDULE INFO CARD (chỉ hiển thị khi xem slot của 1 lịch trực)
         ============================================================ --%>
    <c:if test="${not overviewMode}">
    <div class="schedule-info-card">
        <div class="schedule-info-label mb-2">
            <i class="bi bi-info-circle-fill me-1"></i>Thông tin lịch làm việc #${schedule.id}
        </div>
        <div class="schedule-info-row">
            <div class="schedule-info-item">
                <i class="bi bi-person-badge"></i>
                <div>
                    <div style="font-size:0.68rem;color:var(--c-muted);">Bác sĩ</div>
                    <div>${fn:escapeXml(schedule.doctorName)}</div>
                </div>
            </div>
            <div class="schedule-info-item">
                <i class="bi bi-heart-pulse"></i>
                <div>
                    <div style="font-size:0.68rem;color:var(--c-muted);">Chuyên khoa</div>
                    <div>${not empty schedule.doctorSpecialization ? fn:escapeXml(schedule.doctorSpecialization) : '&mdash;'}</div>
                </div>
            </div>
            <div class="schedule-info-item">
                <i class="bi bi-calendar3"></i>
                <div>
                    <div style="font-size:0.68rem;color:var(--c-muted);">Ngày trực</div>
                    <div><fmt:formatDate value="${schedule.workDate}" pattern="EEEE, dd/MM/yyyy"/></div>
                </div>
            </div>
            <div class="schedule-info-item">
                <i class="bi bi-clock"></i>
                <div>
                    <div style="font-size:0.68rem;color:var(--c-muted);">Ca làm việc</div>
                    <div>${schedule.shiftLabel}</div>
                </div>
            </div>
            <div class="schedule-info-item">
                <span class="badge-status-approved" style="font-size:0.78rem;">
                    <i class="bi bi-check-circle me-1"></i>Đã xác nhận
                </span>
            </div>
        </div>
    </div>

    <%-- ============================================================
         BOOKED SLOTS WARNING BANNER
         ============================================================ --%>
    <c:if test="${bookedCount > 0}">
        <div class="warning-banner">
            <i class="bi bi-shield-exclamation"></i>
            <div class="warning-banner-body">
                <div class="warning-banner-title">
                    <i class="bi bi-people-fill me-1"></i>Cảnh báo: Có ${bookedCount} bệnh nhân đã đặt lịch
                </div>
                <div class="warning-banner-text">
                    Không thể xóa hoặc sinh lại khung giờ khi đang có bệnh nhân đã đặt.
                    Vui lòng xử lý các lịch hẹn này trước khi thực hiện thao tác.
                </div>
            </div>
        </div>
    </c:if>

    <%-- ============================================================
         ACTION BUTTONS
         ============================================================ --%>
    <div class="d-flex flex-wrap gap-2 mb-3">
        <c:choose>
            <c:when test="${hasSlots}">
                <c:if test="${bookedCount == 0}">
                    <%-- Không có booked slots → cho phép xóa và sinh lại --%>
                    <form method="post" action="${pageContext.request.contextPath}/manager/time-slots/"
                          onsubmit="return confirm('Xác nhận XÓA TẤT CẢ khung giờ khám của lịch làm việc này và sinh lại?\n\nHành động này không thể hoàn tác.')">
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="action" value="regenerate">
                        <input type="hidden" name="scheduleId" value="${schedule.id}">
                        <button type="submit" class="btn btn-primary-pink">
                            <i class="bi bi-arrow-repeat me-1"></i>Sinh Lại Khung Giờ
                        </button>
                    </form>
                    <form method="post" action="${pageContext.request.contextPath}/manager/time-slots/"
                          onsubmit="return confirm('Xác nhận XÓA TẤT CẢ khung giờ khám của lịch làm việc #${schedule.id}?\n\nHành động này không thể hoàn tác.')">
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="scheduleId" value="${schedule.id}">
                        <button type="submit" class="btn btn-outline-danger">
                            <i class="bi bi-trash me-1"></i>Xóa Khung Giờ
                        </button>
                    </form>
                </c:if>
                <c:if test="${bookedCount > 0}">
                    <%-- Có booked slots → nút bị vô hiệu hóa + thông báo --%>
                    <button type="button" class="btn btn-outline-secondary" disabled
                            title="Không thể sinh lại khi có bệnh nhân đã đặt">
                        <i class="bi bi-arrow-repeat me-1"></i>Sinh Lại (bị khóa)
                    </button>
                    <button type="button" class="btn btn-outline-secondary" disabled
                            title="Không thể xóa khi có bệnh nhân đã đặt">
                        <i class="bi bi-trash me-1"></i>Xóa (bị khóa)
                    </button>
                    <span class="text-muted align-self-center" style="font-size:0.8rem;">
                        <i class="bi bi-info-circle me-1"></i>
                        Cần xử lý ${bookedCount} bệnh nhân đã đặt trước
                    </span>
                </c:if>
            </c:when>
            <c:otherwise>
                <%-- Chưa có slots → cho phép sinh mới --%>
                <form method="post" action="${pageContext.request.contextPath}/manager/time-slots/">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="regenerate">
                    <input type="hidden" name="scheduleId" value="${schedule.id}">
                    <button type="submit" class="btn btn-primary-pink">
                        <i class="bi bi-lightning-charge-fill me-1"></i>Sinh Khung Giờ Khám
                    </button>
                </form>
            </c:otherwise>
        </c:choose>
        <c:if test="${hasSlots}">
            <form method="post" action="${pageContext.request.contextPath}/manager/time-slots/"
                  class="d-flex align-items-center gap-2"
                  onsubmit="return confirm('Áp giá này cho tất cả khung giờ của ngày ${schedule.workDate}?');">
                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="updatePriceForSchedule">
                <input type="hidden" name="scheduleId" value="${schedule.id}">
                <input type="number" name="price" min="0" step="1000" class="form-control form-control-sm"
                       style="width:170px;" placeholder="Giá cho cả ngày (đ)">
                <button type="submit" class="btn btn-sm btn-outline-primary">
                    <i class="bi bi-cash-coin me-1"></i>Áp Giá Cả Ngày
                </button>
            </form>
        </c:if>
    </div>

    <c:if test="${param.warning eq 'NoAvailableSlotsForPriceUpdate'}">
        <div class="alert alert-warning py-2" style="font-size:0.85rem;">
            <i class="bi bi-exclamation-triangle-fill me-1"></i>Kh&ocirc;ng c&ograve;n khung gi&#7901; tr&#7889;ng &#273;&#7875; c&#7853;p nh&#7853;t gi&aacute;; gi&aacute; c&#7911;a khung gi&#7901; &#273;&atilde; gi&#7919;/&#273;&#7863;t &#273;&#432;&#7907;c b&#7843;o to&agrave;n.
        </div>
    </c:if>
    <c:if test="${success eq 'priceUpdated'}">
        <div class="alert alert-success py-2" style="font-size:0.85rem;">
            <i class="bi bi-check-circle-fill me-1"></i>Đã cập nhật giá khung giờ thành công.
        </div>
    </c:if>

    <%-- ============================================================
         SLOTS CONTENT
         ============================================================ --%>
    <c:choose>
        <c:when test="${hasSlots and not empty slots}">
            <%-- CARD VIEW (Grid): dạng thẻ slot trực quan --%>
            <div class="admin-card mb-3">
                <div class="card-header admin-card-header-link d-flex justify-content-between align-items-center">
                    <h5><i class="bi bi-grid-3x3-gap-fill me-2" style="color:#b86689;"></i>Khung Giờ Khám — Dạng Lưới</h5>
                    <span class="badge bg-white text-dark border" style="font-size:0.78rem;">
                        <i class="bi bi-clock me-1"></i>${totalSlots} khung giờ (20 phút/khung giờ)
                    </span>
                </div>
                <div class="card-body">
                    <div class="slot-grid">
                        <c:forEach var="slot" items="${slots}" varStatus="loop">
                            <div class="slot-card ${fn:toLowerCase(slot.status.name())}">
                                <div class="slot-number">Khung giờ #${loop.index + 1 + (currentPage - 1) * pageSize}</div>
                                <div class="slot-time">${slot.timeLabel}</div>
                                <c:choose>
                                    <c:when test="${slot.status.name() eq 'AVAILABLE'}">
                                        <span class="badge-slot-available"><i class="bi bi-circle-fill me-1" style="font-size:0.45rem;"></i>Còn trống</span>
                                    </c:when>
                                    <c:when test="${slot.status.name() eq 'BOOKED'}">
                                        <span class="badge-slot-booked"><i class="bi bi-person-check-fill me-1"></i>Đã đặt</span>
                                        <c:if test="${not empty slot.bookedByName}">
                                            <div class="booked-patient-info" title="${fn:escapeXml(slot.bookedByName)}">
                                                <i class="bi bi-person-circle me-1"></i>${fn:escapeXml(slot.bookedByName)}
                                            </div>
                                        </c:if>
                                    </c:when>
                                    <c:when test="${slot.status.name() eq 'COMPLETED'}">
                                        <span class="badge-slot-completed"><i class="bi bi-check2-all me-1"></i>Hoàn thành</span>
                                    </c:when>
                                    <c:when test="${slot.status.name() eq 'CANCELLED'}">
                                        <span class="badge-slot-cancelled"><i class="bi bi-x-circle-fill me-1"></i>Đã hủy</span>
                                    </c:when>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <%-- TABLE VIEW: dạng bảng để xem chi tiết + phân trang --%>
            <div class="admin-card">
                <div class="card-header admin-card-header-link d-flex justify-content-between align-items-center">
                    <h5><i class="bi bi-table me-2" style="color:#b86689;"></i>Danh Sách Chi Tiết</h5>
                </div>
                <div class="card-body p-0">
                    <div class="admin-table-wrapper">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th style="width:60px;">STT</th>
                                    <th>Giờ Bắt Đầu</th>
                                    <th>Giờ Kết Thúc</th>
                                    <th>Trạng Thái</th>
                                    <th style="width:225px;">Giá Riêng (đ)</th>
                                    <th>Bệnh Nhân</th>
                                    <th>Ngày Tạo</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="slot" items="${slots}" varStatus="loop">
                                    <tr>
                                        <td style="color:var(--c-muted);font-size:0.8rem;">
                                            ${loop.index + 1 + (currentPage - 1) * pageSize}
                                        </td>
                                        <td style="font-weight:700;font-family:var(--font-display);">
                                            <i class="bi bi-play-circle-fill me-1" style="color:var(--pink-500);font-size:0.7rem;"></i>
                                            ${fn:substring(slot.startTime, 0, 5)}
                                        </td>
                                        <td style="font-weight:600;">
                                            <i class="bi bi-stop-circle-fill me-1" style="color:var(--pink-400);font-size:0.7rem;"></i>
                                            ${fn:substring(slot.endTime, 0, 5)}
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${slot.status.name() eq 'AVAILABLE'}">
                                                    <span class="badge-slot-available"><i class="bi bi-circle-fill me-1" style="font-size:0.4rem;"></i>Còn trống</span>
                                                </c:when>
                                                <c:when test="${slot.status.name() eq 'BOOKED'}">
                                                    <span class="badge-slot-booked"><i class="bi bi-person-check-fill me-1"></i>Đã đặt</span>
                                                </c:when>
                                                <c:when test="${slot.status.name() eq 'COMPLETED'}">
                                                    <span class="badge-slot-completed"><i class="bi bi-check2-all me-1"></i>Hoàn thành</span>
                                                </c:when>
                                                <c:when test="${slot.status.name() eq 'CANCELLED'}">
                                                    <span class="badge-slot-cancelled"><i class="bi bi-x-circle-fill me-1"></i>Đã hủy</span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:if test="${slot.status.name() eq 'AVAILABLE'}">
                                            <form method="post" action="${pageContext.request.contextPath}/manager/time-slots/"
                                                  class="d-flex align-items-center gap-1">
                                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="action" value="updatePrice">
                                                <input type="hidden" name="scheduleId" value="${schedule.id}">
                                                <input type="hidden" name="slotId" value="${slot.id}">
                                                <input type="number" name="price" min="0" step="1000"
                                                       value="${slot.price}" placeholder="Mặc định"
                                                       class="form-control form-control-sm" style="width:125px;">
                                                <button type="submit" class="btn btn-sm btn-outline-primary" title="Lưu giá">
                                                    <i class="bi bi-check-lg"></i>
                                                </button>
                                            </form>
                                            </c:if>
                                            <c:if test="${slot.status.name() ne 'AVAILABLE'}">
                                                <span class="text-muted small">
                                                    <c:choose>
                                                        <c:when test="${not empty slot.price}">${slot.price}</c:when>
                                                        <c:otherwise>M&#7863;c &#273;&#7883;nh</c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <div class="text-muted" style="font-size:0.72rem;">&#272;&atilde; kh&oacute;a theo l&#7883;ch h&#7865;n</div>
                                            </c:if>
                                        </td>
                                        <td style="font-size:0.8rem;">
                                            <c:choose>
                                                <c:when test="${not empty slot.bookedByName}">
                                                    <i class="bi bi-person-circle me-1" style="color:var(--pink-500);"></i>
                                                    ${fn:escapeXml(slot.bookedByName)}
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">&mdash;</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="font-size:0.8rem;color:var(--c-muted);">
                                            <fmt:formatDate value="${slot.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <%-- PAGINATION --%>
            <c:if test="${totalPages > 1}">
                <div class="admin-pagination">
                    <c:url var="baseUrl" value="/manager/time-slots/">
                        <c:param name="scheduleId" value="${schedule.id}"/>
                    </c:url>
                    <c:if test="${currentPage > 1}">
                        <a href="${baseUrl}&page=${currentPage - 1}"><i class="bi bi-chevron-left"></i></a>
                    </c:if>
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <c:choose>
                            <c:when test="${p eq currentPage}"><span class="active">${p}</span></c:when>
                            <c:otherwise><a href="${baseUrl}&page=${p}">${p}</a></c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <a href="${baseUrl}&page=${currentPage + 1}"><i class="bi bi-chevron-right"></i></a>
                    </c:if>
                </div>
            </c:if>
        </c:when>

        <c:otherwise>
            <%-- Empty state: chưa có slots --%>
            <div class="admin-card">
                <div class="card-body">
                    <div class="empty-state">
                        <i class="bi bi-clock-history"></i>
                        <h5>Chưa Có Khung Giờ Khám</h5>
                        <p>
                            Lịch làm việc này chưa có khung giờ khám nào được sinh.
                            <c:choose>
                                <c:when test="${schedule.isApprovedSchedule()}">
                                    <br>Nhấn nút <strong>"Sinh Khung Giờ Khám"</strong> bên trên để tạo các khung giờ 20 phút.
                                </c:when>
                                <c:otherwise>
                                    <br>Vui lòng <strong>xác nhận lịch làm việc</strong> trước khi sinh khung giờ khám.
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <c:if test="${schedule.isApprovedSchedule()}">
                            <form method="post" action="${pageContext.request.contextPath}/manager/time-slots/">
                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="regenerate">
                                <input type="hidden" name="scheduleId" value="${schedule.id}">
                                <button type="submit" class="btn btn-primary-pink">
                                    <i class="bi bi-lightning-charge-fill me-1"></i>Sinh Khung Giờ Khám Ngay
                                </button>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
    </c:if><%-- end not overviewMode --%>
</main>

<%-- ============================================================
     SCRIPTS
     ============================================================ --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
// ── Sidebar Toggle ──
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });

// ── Active menu highlight ──
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        if (links[i].href && links[i].href.indexOf('/manager/time-slots') !== -1) {
            links[i].classList.add('active');
        }
    }
})();
</script>

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
