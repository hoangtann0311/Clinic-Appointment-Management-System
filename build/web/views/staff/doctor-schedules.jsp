<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch Làm Việc - CAMS Lễ Tân</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/staff.css?v=202" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/app-ui.css?v=202" rel="stylesheet">
    <script src="${pageContext.request.contextPath}/assets/js/app-ui.js?v=1" charset="UTF-8" defer></script>
    <style>
        /* ── Slot grid styles ── */
        .slot-card {
            border-radius: 10px;
            border: 1.5px solid #dee2e6;
            padding: 0.65rem 0.85rem;
            margin-bottom: 0.5rem;
            transition: box-shadow 0.15s, border-color 0.15s;
            background: #fff;
            position: relative;
        }
        .slot-card.available {
            border-left: 4px solid #198754;
        }
        .slot-card.booked {
            border-left: 4px solid #dc3545;
            background: #fff5f5;
        }
        .slot-card.consulting {
            border-left: 4px solid #0d6efd;
            background: #f0f4ff;
        }
        .slot-card.held {
            border-left: 4px solid #f59e0b;
            background: #fffbf0;
        }
        .slot-card.past {
            border-left: 4px solid #adb5bd;
            opacity: 0.6;
            background: #f8f9fa;
        }
        .slot-card.completed {
            border-left: 4px solid #6c757d;
            background: #f8f9fa;
            opacity: 0.7;
        }
        .slot-card:hover:not(.past):not(.completed) {
            box-shadow: 0 2px 12px rgba(0,0,0,0.10);
        }
        .slot-time {
            font-weight: 700;
            font-size: 0.88rem;
            color: #374151;
            font-family: 'Nunito', sans-serif;
        }
        .slot-status-badge {
            font-size: 0.68rem;
            padding: 0.2rem 0.6rem;
            border-radius: 2rem;
            font-weight: 700;
            letter-spacing: 0.02em;
        }
        .slot-patient {
            font-size: 0.8rem;
            font-weight: 600;
            color: #1d4ed8;
        }
        .slot-price {
            font-size: 0.76rem;
            color: #6b7280;
        }
        .slot-book-btn {
            font-size: 0.72rem;
            padding: 0.22rem 0.75rem;
            border-radius: 2rem;
        }

        /* ── Doctor schedule card ── */
        .doctor-sched-card {
            border-radius: 14px;
            border: 1.5px solid #e9ecef;
            overflow: hidden;
            margin-bottom: 1.4rem;
            background: #fff;
            box-shadow: 0 1px 6px rgba(0,0,0,0.05);
        }
        .doctor-sched-header {
            padding: 0.85rem 1.2rem;
            background: linear-gradient(135deg, #f8f9fa 0%, #f0f2f5 100%);
            border-bottom: 1px solid #dee2e6;
            display: flex;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
        }
        .doctor-avatar {
            width: 44px; height: 44px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: #fff;
            font-weight: 800;
            font-size: 1.1rem;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .doctor-info-name {
            font-weight: 700;
            font-size: 1rem;
            color: #1f2937;
        }
        .doctor-info-spec {
            font-size: 0.78rem;
            color: #6b7280;
        }
        .doctor-shift-badge {
            background: #e0e7ff;
            color: #3730a3;
            border-radius: 2rem;
            padding: 0.18rem 0.7rem;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .kpi-pill {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            border-radius: 2rem;
            padding: 0.25rem 0.75rem;
            font-size: 0.75rem;
            font-weight: 700;
        }
        .kpi-pill-avail { background: #dcfce7; color: #15803d; }
        .kpi-pill-booked { background: #fee2e2; color: #b91c1c; }
        .kpi-pill-total { background: #e0e7ff; color: #3730a3; }

        .slot-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 0.6rem;
            padding: 1rem 1.2rem;
        }

        /* ── Date nav pills ── */
        .date-nav-form { display: flex; align-items: center; gap: 0.5rem; }
        .date-nav-btn {
            border: 1.5px solid #dee2e6;
            background: #fff;
            border-radius: 8px;
            padding: 0.4rem 0.7rem;
            font-size: 0.85rem;
            cursor: pointer;
            transition: background 0.15s;
        }
        .date-nav-btn:hover { background: #f0f4ff; border-color: #6366f1; }

        /* Legend */
        .legend-row { display: flex; flex-wrap: wrap; gap: 1rem; margin-bottom: 1rem; font-size: 0.78rem; }
        .legend-dot {
            width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 4px;
        }

        /* ── Slot table styles ── */
        .slot-table { font-size: 0.85rem; }
        .slot-table thead th {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            font-weight: 700;
            color: #6b7280;
            white-space: nowrap;
        }
        .slot-table tbody td {
            vertical-align: middle;
        }
        .slot-row { transition: background 0.15s; }
        .slot-row:hover:not(.opacity-50) { background: #f0f4ff !important; }
        .slot-row .slot-time {
            font-weight: 700;
            font-size: 0.82rem;
            color: #374151;
            font-family: 'Nunito', sans-serif;
            white-space: nowrap;
        }

        /* ── Search bar card ── */
        .filter-bar-card { border-radius: 12px; border: 1px solid #e9ecef; }

        /* ── Pagination styling ── */
        .pagination .page-link {
            border-radius: 6px;
            margin: 0 2px;
            color: #3730a3;
            font-weight: 600;
            font-size: 0.85rem;
        }
        .pagination .page-item.active .page-link {
            background: #3730a3;
            border-color: #3730a3;
            color: #fff;
        }
        .pagination .page-item.disabled .page-link {
            color: #adb5bd;
        }
    </style>
</head>
<body class="admin-body">
<c:set var="requestURI" value="${pageContext.request.servletPath}"/>

<!-- ── Topbar ── -->
<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/admin/reception" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i> CAMS <span class="brand-badge">Lễ Tân</span>
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
                        <c:out value="${sessionScope.user.roleNameDisplay}" />
                    </small>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li>
                    <a class="dropdown-item" href="${pageContext.request.contextPath}/staff/profile">
                        <i class="bi bi-person-circle me-2 text-muted"></i>Hồ Sơ Cá Nhân
                    </a>
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
    <div class="admin-sidebar-backdrop" id="sidebarBackdrop" onclick="closeSidebar()"></div>

    <!-- ── Sidebar ── -->
    <aside class="admin-sidebar" id="adminSidebar">
        <div class="admin-sidebar-user">
            <div class="admin-sidebar-avatar">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
            <div class="admin-sidebar-name">${sessionScope.user.fullName}</div>
            <span class="admin-sidebar-badge"><i class="bi bi-shield-check"></i> LỄ TÂN</span>
        </div>
        <ul class="admin-sidebar-menu">
            <li class="admin-sidebar-section">Tổng quan</li>
            <li><a href="${pageContext.request.contextPath}/admin/reception"><i class="bi bi-speedometer2"></i><span>Hàng Đợi Tiếp Đón</span></a></li>
            <li class="admin-sidebar-section">Quản lý tiếp đón</li>
            <li><a href="${pageContext.request.contextPath}/admin/reception/booking"><i class="bi bi-calendar-plus"></i><span>Đặt Lịch Thủ Công</span></a></li>
            <li><a class="active" href="${pageContext.request.contextPath}/admin/reception/doctor-schedules"><i class="bi bi-calendar-week"></i><span>Lịch Làm Việc</span></a></li>
            <li class="admin-sidebar-section">Tài khoản</li>
            <li><a href="${pageContext.request.contextPath}/staff/profile"><i class="bi bi-person-circle"></i><span>Hồ Sơ Cá Nhân</span></a></li>
        </ul>
    </aside>

    <!-- ── Main ── -->
    <main class="admin-main" id="adminMain">
        <!-- Header row -->
        <div class="admin-page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
            <div>
                <h1 class="admin-page-title"><i class="bi bi-calendar-week me-2"></i>Lịch Làm Việc Hôm Nay</h1>
                <div class="admin-page-subtitle">Tổng quan ca trực bác sĩ — trạng thái từng khung giờ — bệnh nhân đang khám</div>
            </div>
            <!-- Date navigation -->
            <form method="get" class="date-nav-form" id="dateNavForm">
                <button type="button" class="date-nav-btn" onclick="shiftDate(-1)" title="Ngày trước">
                    <i class="bi bi-chevron-left"></i>
                </button>
                <input class="form-control" type="date" name="date" id="dateInput"
                       value="${selectedDate}" style="width:160px;">
                <button type="submit" class="date-nav-btn" style="color:#3730a3;border-color:#a5b4fc;">
                    <i class="bi bi-funnel me-1"></i>Xem
                </button>
                <button type="button" class="date-nav-btn" onclick="shiftDate(1)" title="Ngày sau">
                    <i class="bi bi-chevron-right"></i>
                </button>
                <button type="button" class="date-nav-btn" onclick="goToday()" title="Về hôm nay"
                        style="color:#059669;border-color:#6ee7b7;">
                    <i class="bi bi-house-check me-1"></i>Hôm nay
                </button>
            </form>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger rounded-3 mb-3" data-cams-toast="true"><i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}</div>
        </c:if>

        <!-- Legend -->
        <div class="legend-row mb-3">
            <span><span class="legend-dot" style="background:#198754;"></span>Trống — Có thể đặt</span>
            <span><span class="legend-dot" style="background:#0d6efd;"></span>Đang khám</span>
            <span><span class="legend-dot" style="background:#dc3545;"></span>Đã đặt</span>
            <span><span class="legend-dot" style="background:#f59e0b;"></span>Đang giữ chỗ</span>
            <span><span class="legend-dot" style="background:#6c757d;"></span>Đã hoàn thành / Quá giờ</span>
        </div>

        <!-- ── Search & Filter Bar ── -->
        <div class="admin-card mb-3">
            <div class="card-body py-2">
                <form method="get" class="row g-2 align-items-end">
                    <input type="hidden" name="date" value="${selectedDate}">
                    <div class="col-md-5">
                        <label class="form-label small fw-semibold text-muted mb-1"><i class="bi bi-search me-1"></i>Tìm kiếm</label>
                        <input type="text" name="search" class="form-control form-control-sm"
                               placeholder="Tên bác sĩ, bệnh nhân, hoặc khung giờ..."
                               value="${search}">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small fw-semibold text-muted mb-1"><i class="bi bi-funnel me-1"></i>Trạng thái</label>
                        <select name="status" class="form-select form-select-sm">
                            <option value="">Tất cả trạng thái</option>
                            <option value="AVAILABLE" ${statusFilter == 'AVAILABLE' ? 'selected' : ''}>Trống</option>
                            <option value="HELD" ${statusFilter == 'HELD' ? 'selected' : ''}>Đang giữ chỗ</option>
                            <option value="WAITING_VERIFICATION" ${statusFilter == 'WAITING_VERIFICATION' ? 'selected' : ''}>Chờ xác nhận</option>
                            <option value="BOOKED" ${statusFilter == 'BOOKED' ? 'selected' : ''}>Đã đặt</option>
                            <option value="COMPLETED" ${statusFilter == 'COMPLETED' ? 'selected' : ''}>Hoàn thành</option>
                            <option value="CANCELLED" ${statusFilter == 'CANCELLED' ? 'selected' : ''}>Đã hủy</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-sm btn-primary w-100">
                            <i class="bi bi-funnel me-1"></i>Lọc
                        </button>
                    </div>
                    <div class="col-md-2">
                        <a href="${pageContext.request.contextPath}/admin/reception/doctor-schedules?date=${selectedDate}"
                           class="btn btn-sm btn-outline-secondary w-100">
                            <i class="bi bi-arrow-counterclockwise me-1"></i>Xóa lọc
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- ── Empty state ── -->
        <c:if test="${empty slotPage.slots}">
            <div class="admin-card">
                <div class="card-body text-center py-5 text-muted">
                    <i class="bi bi-calendar-x fs-1 opacity-50 d-block mb-3"></i>
                    <h5>
                        <c:choose>
                            <c:when test="${not empty search or not empty statusFilter}">
                                Không tìm thấy khung giờ nào khớp với bộ lọc
                            </c:when>
                            <c:otherwise>
                                Không có lịch làm việc nào được duyệt cho ngày ${displayDate}
                            </c:otherwise>
                        </c:choose>
                    </h5>
                    <p class="small">
                        <c:choose>
                            <c:when test="${not empty search or not empty statusFilter}">
                                Thử thay đổi từ khóa hoặc bộ lọc trạng thái.
                            </c:when>
                            <c:otherwise>
                                Manager cần tạo và duyệt Lịch trực trước khi Lễ tân có thể đặt lịch.
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </div>
        </c:if>

        <!-- ── Flat Slot Table ── -->
        <c:if test="${not empty slotPage.slots}">
            <div class="admin-card">
                <!-- Summary bar -->
                <div class="d-flex justify-content-between align-items-center px-3 py-2 border-bottom flex-wrap gap-2">
                    <span class="small text-muted">
                        <i class="bi bi-list-ul me-1"></i>
                        Hiển thị <strong>${slotPage.slots.size()}</strong> / <strong>${slotPage.totalRecords}</strong> khung giờ
                        <c:if test="${not empty search}">— tìm "<strong>${search}</strong>"</c:if>
                        <c:if test="${not empty statusFilter}">— trạng thái "<strong>${statusFilter}</strong>"</c:if>
                    </span>
                    <span class="small text-muted">
                        Trang <strong>${slotPage.currentPage}</strong> / <strong>${slotPage.totalPages}</strong>
                    </span>
                </div>

                <!-- Slot table -->
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 slot-table">
                        <thead class="table-light">
                            <tr>
                                <th style="width:5%;">#</th>
                                <th style="width:14%;">Khung giờ</th>
                                <th style="width:18%;">Bác sĩ</th>
                                <th style="width:11%;">Trạng thái</th>
                                <th style="width:18%;">Bệnh nhân</th>
                                <th style="width:12%;">Giá khám</th>
                                <th style="width:22%;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:set var="rowIdx" value="${(slotPage.currentPage - 1) * 10 + 1}"/>
                            <c:forEach var="sl" items="${slotPage.slots}">
                                <%-- Determine row style --%>
                                <c:choose>
                                    <c:when test="${sl.status == 'COMPLETED'}">
                                        <c:set var="rowClass" value="table-secondary"/>
                                        <c:set var="rowOpacity" value="opacity-75"/>
                                    </c:when>
                                    <c:when test="${sl.status == 'BOOKED' || sl.status == 'WAITING_VERIFICATION'}">
                                        <c:set var="rowClass" value=""/>
                                        <c:set var="rowOpacity" value=""/>
                                    </c:when>
                                    <c:when test="${sl.status == 'HELD'}">
                                        <c:set var="rowClass" value="table-warning"/>
                                        <c:set var="rowOpacity" value=""/>
                                    </c:when>
                                    <c:when test="${sl.status == 'CANCELLED'}">
                                        <c:set var="rowClass" value="table-secondary"/>
                                        <c:set var="rowOpacity" value="opacity-50"/>
                                    </c:when>
                                    <c:when test="${sl.available}">
                                        <c:set var="rowClass" value=""/>
                                        <c:set var="rowOpacity" value=""/>
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="rowClass" value="table-secondary"/>
                                        <c:set var="rowOpacity" value="opacity-50"/>
                                    </c:otherwise>
                                </c:choose>

                                <tr class="slot-row ${rowClass} ${rowOpacity}" data-slot-id="${sl.id}">
                                    <td class="fw-semibold text-muted small">${rowIdx}</td>
                                    <td>
                                        <span class="slot-time"><i class="bi bi-clock me-1"></i>${sl.timeLabel}</span>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="doctor-avatar-sm" style="width:30px;height:30px;border-radius:50%;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;font-weight:700;font-size:0.75rem;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                                                ${fn:substring(sl.doctorName, 0, 1)}
                                            </div>
                                            <div>
                                                <div class="fw-semibold small">BS. ${sl.doctorName}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${sl.status == 'AVAILABLE'}">
                                                <span class="slot-status-badge" style="background:#dcfce7;color:#15803d;"><i class="bi bi-circle-fill me-1" style="font-size:0.45rem;"></i>Trống</span>
                                            </c:when>
                                            <c:when test="${sl.status == 'HELD'}">
                                                <span class="slot-status-badge" style="background:#fef3c7;color:#92400e;"><i class="bi bi-hourglass-split me-1"></i>Giữ chỗ</span>
                                            </c:when>
                                            <c:when test="${sl.status == 'WAITING_VERIFICATION'}">
                                                <span class="slot-status-badge" style="background:#fef3c7;color:#92400e;"><i class="bi bi-clipboard-check me-1"></i>Chờ XN</span>
                                            </c:when>
                                            <c:when test="${sl.status == 'BOOKED'}">
                                                <span class="slot-status-badge" style="background:#fee2e2;color:#b91c1c;"><i class="bi bi-circle-fill me-1" style="font-size:0.45rem;"></i>Đã đặt</span>
                                            </c:when>
                                            <c:when test="${sl.status == 'COMPLETED'}">
                                                <span class="slot-status-badge" style="background:#f3f4f6;color:#6b7280;"><i class="bi bi-check-circle me-1"></i>Xong</span>
                                            </c:when>
                                            <c:when test="${sl.status == 'CANCELLED'}">
                                                <span class="slot-status-badge" style="background:#f3f4f6;color:#9ca3af;"><i class="bi bi-x-circle me-1"></i>Hủy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="slot-status-badge" style="background:#f3f4f6;color:#9ca3af;"><i class="bi bi-dash-circle me-1"></i>Quá giờ</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty sl.bookedByName}">
                                                <span class="fw-semibold small text-primary">${sl.bookedByName}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted small"><em>—</em></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${sl.price != null && sl.price > 0}">
                                            <span class="fw-semibold small"><fmt:formatNumber value="${sl.price}" pattern="#,###"/>đ</span>
                                        </c:if>
                                        <c:if test="${sl.price == null || sl.price == 0}">
                                            <span class="text-muted small">—</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <div class="d-flex gap-1 flex-wrap">
                                            <%-- View detail button — always shown --%>
                                            <button type="button" class="btn btn-sm btn-outline-secondary"
                                                    onclick="showSlotDetail(${sl.id}, '${sl.timeLabel}', '${sl.doctorName}', '${sl.status}', '${not empty sl.bookedByName ? sl.bookedByName : ''}', '${sl.price != null ? sl.price : 0}', '${selectedDate}')"
                                                    title="Xem chi tiết">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                            <%-- Book button (only for available slots) --%>
                                            <c:if test="${sl.status == 'AVAILABLE'}">
                                                <a href="${pageContext.request.contextPath}/admin/reception/booking?doctorId=${sl.doctorId}&date=${selectedDate}&slot=${sl.timeLabel}"
                                                   class="btn btn-sm btn-success">
                                                    <i class="bi bi-calendar-plus me-1"></i>Đặt lịch
                                                </a>
                                            </c:if>
                                            <%-- Booked/held: quick booking for same doctor --%>
                                            <c:if test="${!sl.available && sl.status != 'COMPLETED' && sl.status != 'CANCELLED'}">
                                                <a href="${pageContext.request.contextPath}/admin/reception/booking?doctorId=${sl.doctorId}&date=${selectedDate}"
                                                   class="btn btn-sm btn-outline-primary">
                                                    <i class="bi bi-person-plus"></i>
                                                </a>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                                <c:set var="rowIdx" value="${rowIdx + 1}"/>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ── Pagination ── -->
            <c:if test="${slotPage.totalPages > 1}">
                <nav class="d-flex justify-content-center mt-3">
                    <ul class="pagination pagination-sm flex-wrap">
                        <%-- First page --%>
                        <c:url var="firstUrl" value="/admin/reception/doctor-schedules">
                            <c:param name="date" value="${selectedDate}"/>
                            <c:param name="search" value="${search}"/>
                            <c:param name="status" value="${statusFilter}"/>
                            <c:param name="page" value="1"/>
                        </c:url>
                        <li class="page-item ${slotPage.currentPage <= 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${firstUrl}" title="Đầu">
                                <i class="bi bi-chevron-double-left"></i>
                            </a>
                        </li>

                        <%-- Previous --%>
                        <c:url var="prevUrl" value="/admin/reception/doctor-schedules">
                            <c:param name="date" value="${selectedDate}"/>
                            <c:param name="search" value="${search}"/>
                            <c:param name="status" value="${statusFilter}"/>
                            <c:param name="page" value="${slotPage.currentPage - 1}"/>
                        </c:url>
                        <li class="page-item ${slotPage.currentPage <= 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${prevUrl}" title="Trước">
                                <i class="bi bi-chevron-left"></i>
                            </a>
                        </li>

                        <%-- Page numbers (show up to 5 pages around current) --%>
                        <c:set var="startPage" value="${slotPage.currentPage - 2}"/>
                        <c:set var="endPage" value="${slotPage.currentPage + 2}"/>
                        <c:if test="${startPage < 1}">
                            <c:set var="startPage" value="1"/>
                            <c:set var="endPage" value="${endPage + (1 - (slotPage.currentPage - 2))}"/>
                        </c:if>
                        <c:if test="${endPage > slotPage.totalPages}">
                            <c:set var="endPage" value="${slotPage.totalPages}"/>
                            <c:set var="startPage" value="${startPage - (endPage - (slotPage.currentPage + 2))}"/>
                        </c:if>
                        <c:if test="${startPage < 1}"><c:set var="startPage" value="1"/></c:if>

                        <c:if test="${startPage > 1}">
                            <li class="page-item disabled"><span class="page-link">…</span></li>
                        </c:if>

                        <c:forEach var="p" begin="${startPage}" end="${endPage}">
                            <c:url var="pageUrl" value="/admin/reception/doctor-schedules">
                                <c:param name="date" value="${selectedDate}"/>
                                <c:param name="search" value="${search}"/>
                                <c:param name="status" value="${statusFilter}"/>
                                <c:param name="page" value="${p}"/>
                            </c:url>
                            <li class="page-item ${p == slotPage.currentPage ? 'active' : ''}">
                                <a class="page-link" href="${pageUrl}">${p}</a>
                            </li>
                        </c:forEach>

                        <c:if test="${endPage < slotPage.totalPages}">
                            <li class="page-item disabled"><span class="page-link">…</span></li>
                        </c:if>

                        <%-- Next --%>
                        <c:url var="nextUrl" value="/admin/reception/doctor-schedules">
                            <c:param name="date" value="${selectedDate}"/>
                            <c:param name="search" value="${search}"/>
                            <c:param name="status" value="${statusFilter}"/>
                            <c:param name="page" value="${slotPage.currentPage + 1}"/>
                        </c:url>
                        <li class="page-item ${slotPage.currentPage >= slotPage.totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${nextUrl}" title="Sau">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>

                        <%-- Last page --%>
                        <c:url var="lastUrl" value="/admin/reception/doctor-schedules">
                            <c:param name="date" value="${selectedDate}"/>
                            <c:param name="search" value="${search}"/>
                            <c:param name="status" value="${statusFilter}"/>
                            <c:param name="page" value="${slotPage.totalPages}"/>
                        </c:url>
                        <li class="page-item ${slotPage.currentPage >= slotPage.totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${lastUrl}" title="Cuối">
                                <i class="bi bi-chevron-double-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </c:if>

    </main>
</div>

<!-- ── Slot Detail Modal ── -->
<div class="modal fade" id="slotDetailModal" tabindex="-1" aria-labelledby="slotDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header" id="slotModalHeader">
                <h5 class="modal-title" id="slotDetailModalLabel">
                    <i class="bi bi-info-circle me-2"></i>Chi tiết khung giờ
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body" id="slotModalBody">
                <!-- Filled by JS -->
            </div>
            <div class="modal-footer" id="slotModalFooter">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="bi bi-x-circle me-1"></i>Đóng
                </button>
                <a href="#" id="slotModalBookBtn" class="btn btn-primary" style="display:none;">
                    <i class="bi bi-calendar-plus me-1"></i>Đặt lịch khung giờ này
                </a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// Map slot data from server for detail view
var slotDataMap = {};
<c:forEach var="sl" items="${slotPage.slots}">
slotDataMap[${sl.id}] = {
    id: ${sl.id},
    timeLabel: '${sl.timeLabel}',
    doctorName: '${sl.doctorName}',
    doctorId: ${sl.doctorId},
    status: '${sl.status}',
    statusLabel: '<c:choose><c:when test="${sl.status == 'AVAILABLE'}">Trống</c:when><c:when test="${sl.status == 'HELD'}">Đang giữ chỗ</c:when><c:when test="${sl.status == 'WAITING_VERIFICATION'}">Chờ xác nhận</c:when><c:when test="${sl.status == 'BOOKED'}">Đã đặt</c:when><c:when test="${sl.status == 'COMPLETED'}">Hoàn thành</c:when><c:when test="${sl.status == 'CANCELLED'}">Đã hủy</c:when><c:otherwise>Không xác định</c:otherwise></c:choose>',
    patientName: '${not empty sl.bookedByName ? sl.bookedByName : ""}',
    bookedPatients: '${fn:escapeXml(sl.bookedPatients)}',
    price: ${sl.price != null ? sl.price : 0},
    scheduleId: ${sl.scheduleId != null ? sl.scheduleId : 0},
    workDate: '${selectedDate}',
    notes: '${not empty sl.notes ? sl.notes : ""}'
};
</c:forEach>

function showSlotDetail(slotId, timeLabel, doctorName, status, patientName, price, date) {
    var data = slotDataMap[slotId];
    if (!data) {
        // Fallback with passed params
        data = {
            id: slotId,
            timeLabel: timeLabel,
            doctorName: doctorName,
            doctorId: 0,
            status: status,
            statusLabel: status,
            patientName: patientName,
            bookedPatients: '',
            price: parseFloat(price) || 0,
            scheduleId: 0,
            workDate: date,
            notes: ''
        };
    }

    var statusIcons = {
        'AVAILABLE': '<i class="bi bi-circle-fill me-1" style="font-size:0.5rem;"></i>',
        'HELD': '<i class="bi bi-hourglass-split me-1"></i>',
        'WAITING_VERIFICATION': '<i class="bi bi-clipboard-check me-1"></i>',
        'BOOKED': '<i class="bi bi-circle-fill me-1" style="font-size:0.5rem;"></i>',
        'COMPLETED': '<i class="bi bi-check-circle me-1"></i>',
        'CANCELLED': '<i class="bi bi-x-circle me-1"></i>'
    };
    var statusColors = {
        'AVAILABLE': {bg: '#dcfce7', color: '#15803d'},
        'HELD': {bg: '#fef3c7', color: '#92400e'},
        'WAITING_VERIFICATION': {bg: '#fef3c7', color: '#92400e'},
        'BOOKED': {bg: '#fee2e2', color: '#b91c1c'},
        'COMPLETED': {bg: '#f3f4f6', color: '#6b7280'},
        'CANCELLED': {bg: '#f3f4f6', color: '#9ca3af'}
    };
    var sc = statusColors[data.status] || {bg: '#f3f4f6', color: '#9ca3af'};
    var si = statusIcons[data.status] || '<i class="bi bi-dash-circle me-1"></i>';

    var priceFormatted = data.price > 0 ? new Intl.NumberFormat('vi-VN').format(data.price) + '₫' : 'Chưa công bố';

    var html = '<div class="mb-3">'
        + '<div class="d-flex align-items-center gap-2 mb-3">'
        + '<span class="badge fs-6 px-3 py-2" style="background:' + sc.bg + ';color:' + sc.color + ';">' + si + data.statusLabel + '</span>'
        + '</div>'
        + '<table class="table table-sm table-bordered mb-0">'
        + '<tr><td class="fw-semibold text-muted" style="width:35%;">Mã slot</td><td><strong>#SLOT-' + data.id + '</strong></td></tr>'
        + '<tr><td class="fw-semibold text-muted">Ngày</td><td>' + data.workDate + '</td></tr>'
        + '<tr><td class="fw-semibold text-muted">Khung giờ</td><td><span class="fw-bold"><i class="bi bi-clock me-1"></i>' + data.timeLabel + '</span></td></tr>'
        + '<tr><td class="fw-semibold text-muted">Bác sĩ</td><td><i class="bi bi-person-badge me-1"></i>BS. ' + data.doctorName + '</td></tr>'
        + '<tr><td class="fw-semibold text-muted">Giá khám</td><td><span class="fw-bold text-success">' + priceFormatted + '</span></td></tr>';

    if (data.bookedPatients) {
        var pList = data.bookedPatients.split(',').map(function(p) { return '<li><i class="bi bi-person-fill me-1 text-primary"></i>' + p.trim() + '</li>'; }).join('');
        html += '<tr><td class="fw-semibold text-muted">Danh sách hẹn</td><td><ul class="list-unstyled mb-0">' + pList + '</ul></td></tr>';
    } else {
        html += '<tr><td class="fw-semibold text-muted">Danh sách hẹn</td><td><span class="text-muted"><em>Chưa có bệnh nhân đặt</em></span></td></tr>';
    }

    if (data.notes) {
        html += '<tr><td class="fw-semibold text-muted">Ghi chú</td><td>' + data.notes + '</td></tr>';
    }

    html += '</table></div>';

    document.getElementById('slotModalBody').innerHTML = html;

    // Show/hide book button based on status
    var bookBtn = document.getElementById('slotModalBookBtn');
    if (data.status === 'AVAILABLE') {
        bookBtn.style.display = 'inline-block';
        bookBtn.href = '${pageContext.request.contextPath}/admin/reception/booking?doctorId=' + data.doctorId + '&date=' + data.workDate + '&slot=' + encodeURIComponent(data.timeLabel);
    } else {
        bookBtn.style.display = 'none';
    }

    var modal = new bootstrap.Modal(document.getElementById('slotDetailModal'));
    modal.show();
}

function shiftDate(delta) {
    var input = document.getElementById('dateInput');
    var d = input.value ? new Date(input.value) : new Date();
    d.setDate(d.getDate() + delta);
    input.value = d.toISOString().slice(0, 10);
    document.getElementById('dateNavForm').submit();
}
function goToday() {
    document.getElementById('dateInput').value = new Date().toISOString().slice(0, 10);
    document.getElementById('dateNavForm').submit();
}

// Sidebar toggle (từ app-ui.js nếu có, hoặc fallback)
function openSidebar() {
    var s = document.getElementById('adminSidebar');
    var b = document.getElementById('sidebarBackdrop');
    if (s) s.classList.add('show');
    if (b) b.classList.add('show');
    document.body.style.overflow = 'hidden';
}
function closeSidebar() {
    var s = document.getElementById('adminSidebar');
    var b = document.getElementById('sidebarBackdrop');
    if (s) s.classList.remove('show');
    if (b) b.classList.remove('show');
    document.body.style.overflow = '';
}
document.addEventListener('DOMContentLoaded', function () {
    var toggle = document.getElementById('sidebarToggle');
    if (toggle) toggle.addEventListener('click', openSidebar);
});
</script>
</body>
</html>
