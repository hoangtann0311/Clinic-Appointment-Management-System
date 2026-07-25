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
        <div class="topbar-date d-none d-lg-flex">
            <i class="bi bi-calendar3"></i> ${not empty currentDisplayDate ? currentDisplayDate : 'Hôm nay'}
        </div>
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role"><i class="bi bi-shield-check me-1"></i>Lễ Tân</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout">
            <i class="bi bi-box-arrow-right"></i> <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
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
            <div class="alert alert-danger rounded-3 mb-3"><i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}</div>
        </c:if>

        <!-- Legend -->
        <div class="legend-row mb-3">
            <span><span class="legend-dot" style="background:#198754;"></span>Trống — Có thể đặt</span>
            <span><span class="legend-dot" style="background:#0d6efd;"></span>Đang khám</span>
            <span><span class="legend-dot" style="background:#dc3545;"></span>Đã đặt</span>
            <span><span class="legend-dot" style="background:#f59e0b;"></span>Đang giữ chỗ</span>
            <span><span class="legend-dot" style="background:#6c757d;"></span>Đã hoàn thành / Quá giờ</span>
        </div>

        <!-- ── Empty state ── -->
        <c:if test="${empty schedules}">
            <div class="admin-card">
                <div class="card-body text-center py-5 text-muted">
                    <i class="bi bi-calendar-x fs-1 opacity-50 d-block mb-3"></i>
                    <h5>Không có lịch làm việc nào được duyệt cho ngày ${displayDate}</h5>
                    <p class="small">Manager cần tạo và duyệt Lịch trực trước khi Lễ tân có thể đặt lịch.</p>
                </div>
            </div>
        </c:if>

        <!-- ── Doctor schedule cards ── -->
        <c:forEach var="sched" items="${schedules}">
            <c:set var="remaining" value="${sched.maxSlots - sched.bookedSlotCount}"/>
            <div class="doctor-sched-card" id="sched-${sched.id}">

                <!-- Doctor header -->
                <div class="doctor-sched-header">
                    <div class="doctor-avatar">
                        ${fn:substring(sched.doctorName, 0, 1)}
                    </div>
                    <div class="flex-grow-1">
                        <div class="doctor-info-name">BS. ${sched.doctorName}</div>
                        <div class="doctor-info-spec">
                            <i class="bi bi-heart-pulse me-1"></i>
                            ${not empty sched.doctorSpecialization ? sched.doctorSpecialization : 'Sản phụ khoa'}
                        </div>
                    </div>
                    <span class="doctor-shift-badge"><i class="bi bi-clock me-1"></i>${sched.shiftLabel}</span>
                    <div class="d-flex gap-2 flex-wrap">
                        <span class="kpi-pill kpi-pill-total"><i class="bi bi-grid-3x3-gap"></i> ${sched.maxSlots} slot</span>
                        <span class="kpi-pill kpi-pill-booked"><i class="bi bi-person-check"></i> ${sched.bookedSlotCount} đã đặt</span>
                        <c:choose>
                            <c:when test="${remaining <= 0}">
                                <span class="kpi-pill" style="background:#fee2e2;color:#b91c1c;"><i class="bi bi-x-circle"></i> Hết chỗ</span>
                            </c:when>
                            <c:when test="${remaining <= 3}">
                                <span class="kpi-pill" style="background:#fef9c3;color:#854d0e;"><i class="bi bi-exclamation-triangle"></i> Còn ${remaining}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="kpi-pill kpi-pill-avail"><i class="bi bi-check-circle"></i> Còn ${remaining} trống</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <!-- Quick booking link -->
                    <a href="${pageContext.request.contextPath}/admin/reception/booking?doctorId=${sched.doctorId}&date=${selectedDate}"
                       class="btn btn-sm btn-primary rounded-pill px-3">
                        <i class="bi bi-calendar-plus me-1"></i>Đặt lịch
                    </a>
                </div>

                <!-- Slot grid for this doctor -->
                <div class="slot-grid">
                    <c:set var="hasSlotForDoctor" value="false"/>
                    <c:forEach var="sl" items="${slots}">
                        <c:if test="${sl.doctorId == sched.doctorId}">
                            <c:set var="hasSlotForDoctor" value="true"/>
                            <%-- Determine card CSS class --%>
                            <c:choose>
                                <c:when test="${sl.status.name() == 'COMPLETED'}"><c:set var="slotCss" value="completed"/></c:when>
                                <c:when test="${sl.status.name() == 'CONSULTING'}"><c:set var="slotCss" value="consulting"/></c:when>
                                <c:when test="${sl.status.name() == 'BOOKED' || sl.status.name() == 'WAITING_VERIFICATION'}"><c:set var="slotCss" value="booked"/></c:when>
                                <c:when test="${sl.status.name() == 'HELD'}"><c:set var="slotCss" value="held"/></c:when>
                                <c:when test="${sl.available}"><c:set var="slotCss" value="available"/></c:when>
                                <c:otherwise><c:set var="slotCss" value="past"/></c:otherwise>
                            </c:choose>

                            <div class="slot-card ${slotCss}">
                                <!-- Time & status -->
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="slot-time"><i class="bi bi-clock me-1"></i>${sl.timeLabel}</span>
                                    <c:choose>
                                        <c:when test="${sl.status.name() == 'CONSULTING'}">
                                            <span class="slot-status-badge" style="background:#dbeafe;color:#1d4ed8;">🔵 Đang khám</span>
                                        </c:when>
                                        <c:when test="${sl.status.name() == 'COMPLETED'}">
                                            <span class="slot-status-badge" style="background:#f3f4f6;color:#6b7280;">✓ Xong</span>
                                        </c:when>
                                        <c:when test="${sl.status.name() == 'BOOKED' || sl.status.name() == 'WAITING_VERIFICATION'}">
                                            <span class="slot-status-badge" style="background:#fee2e2;color:#b91c1c;">🔴 Đã đặt</span>
                                        </c:when>
                                        <c:when test="${sl.status.name() == 'HELD'}">
                                            <span class="slot-status-badge" style="background:#fef3c7;color:#92400e;">⏳ Giữ chỗ</span>
                                        </c:when>
                                        <c:when test="${sl.available}">
                                            <span class="slot-status-badge" style="background:#dcfce7;color:#15803d;">🟢 Trống</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="slot-status-badge" style="background:#f3f4f6;color:#9ca3af;">Quá giờ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Patient info (if booked/consulting) -->
                                <c:if test="${not empty sl.bookedByName}">
                                    <div class="slot-patient mb-1">
                                        <i class="bi bi-person-fill me-1"></i>${sl.bookedByName}
                                    </div>
                                </c:if>
                                <c:if test="${empty sl.bookedByName && slotCss == 'available'}">
                                    <div class="slot-patient mb-1" style="color:#9ca3af;font-weight:400;">
                                        <i class="bi bi-person me-1"></i><em>Chưa có bệnh nhân</em>
                                    </div>
                                </c:if>

                                <!-- Price -->
                                <c:if test="${sl.price != null && sl.price > 0}">
                                    <div class="slot-price"><i class="bi bi-cash me-1"></i><fmt:formatNumber value="${sl.price}" pattern="#,###"/>đ</div>
                                </c:if>

                                <!-- Book button (only for available slots) -->
                                <c:if test="${sl.available}">
                                    <div class="mt-2">
                                        <a href="${pageContext.request.contextPath}/admin/reception/booking?doctorId=${sl.doctorId}&date=${selectedDate}&slot=${sl.timeLabel}"
                                           class="btn btn-success btn-sm slot-book-btn w-100">
                                            <i class="bi bi-calendar-plus me-1"></i>Đặt lịch slot này
                                        </a>
                                    </div>
                                </c:if>
                            </div>
                        </c:if>
                    </c:forEach>

                    <c:if test="${!hasSlotForDoctor}">
                        <div class="text-muted small p-3 fst-italic">Chưa có khung giờ nào được tạo cho ca trực này.</div>
                    </c:if>
                </div>

            </div>
        </c:forEach>

    </main>
</div>

<script>
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
