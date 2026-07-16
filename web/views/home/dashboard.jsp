<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<style>
/* ─── Dashboard Premium Styles ─────────────────────────────── */
.hero-banner {
    background: linear-gradient(135deg, #1a6fc4 0%, #0ea5e9 50%, #38bdf8 100%);
    border-radius: 20px;
    padding: 2.5rem;
    position: relative;
    overflow: hidden;
    color: #fff;
}
.hero-banner::before {
    content:''; position:absolute; top:-60px; right:-60px;
    width:220px; height:220px;
    background:rgba(255,255,255,.08); border-radius:50%;
}
.hero-banner::after {
    content:''; position:absolute; bottom:-80px; left:-40px;
    width:300px; height:300px;
    background:rgba(255,255,255,.05); border-radius:50%;
}
.hero-badge {
    background:rgba(255,255,255,.2);
    border:1px solid rgba(255,255,255,.3);
    backdrop-filter:blur(10px);
    border-radius:50px; padding:.45rem 1.1rem;
    font-size:.85rem; display:inline-flex; align-items:center; gap:.4rem;
}
.stat-pill {
    background:rgba(255,255,255,.15);
    border-radius:12px; padding:.7rem 1.2rem;
    text-align:center; min-width:90px;
}
.stat-pill .num { font-size:1.5rem; font-weight:700; }
.stat-pill .lbl { font-size:.72rem; opacity:.85; }

.section-card {
    border:none; border-radius:16px;
    box-shadow:0 2px 16px rgba(0,0,0,.06);
    transition:box-shadow .2s;
}
.section-card:hover { box-shadow:0 6px 28px rgba(0,0,0,.10); }
.section-header {
    display:flex; align-items:center; gap:.75rem; margin-bottom:1.2rem;
}
.section-icon {
    width:42px; height:42px; border-radius:12px;
    display:flex; align-items:center; justify-content:center;
    font-size:1.2rem; flex-shrink:0;
}

.appt-card {
    border-radius:14px; border:1.5px solid #e0eeff;
    background:#f8fbff; padding:1rem 1.2rem; margin-bottom:.75rem;
    transition:all .2s;
}
.appt-card:hover { border-color:#1a6fc4; background:#eaf3ff; }
.appt-card:last-child { margin-bottom:0; }

.status-badge {
    font-size:.72rem; padding:.3em .75em;
    border-radius:50px; font-weight:600;
}
.status-Pending    { background:#fff3cd; color:#856404; }
.status-Confirmed  { background:#d1e7dd; color:#0a3622; }
.status-Waiting    { background:#cff4fc; color:#055160; }
.status-Completed  { background:#e2e3e5; color:#383d41; }
.status-Cancelled  { background:#f8d7da; color:#842029; }
.status-Emergency  { background:#ffe0b2; color:#bf360c; }

.notif-item {
    display:flex; align-items:flex-start; gap:.85rem;
    padding:.85rem 0; border-bottom:1px solid #f0f0f0;
}
.notif-item:last-child { border-bottom:none; padding-bottom:0; }
.notif-dot {
    width:10px; height:10px; border-radius:50%;
    background:#1a6fc4; flex-shrink:0; margin-top:.35rem;
}
.notif-dot.read { background:#ccc; }
.notif-title { font-weight:600; font-size:.88rem; color:#1a1a2e; margin-bottom:.15rem; }
.notif-body  { font-size:.8rem; color:#6c757d; line-height:1.4; }
.notif-time  { font-size:.72rem; color:#adb5bd; margin-top:.2rem; }

.quick-link-card {
    border-radius:14px; border:1.5px solid #e9ecef;
    background:#fff; padding:1.1rem; text-align:center;
    transition:all .22s;
}
.quick-link-card:hover {
    border-color:#1a6fc4; background:#eaf3ff;
    transform:translateY(-3px);
    box-shadow:0 8px 20px rgba(26,111,196,.12);
}
.quick-link-card i  { font-size:1.6rem; }
.quick-link-card h6 { font-size:.85rem; font-weight:600; margin:.5rem 0 .15rem; }
.quick-link-card small { font-size:.75rem; }

.info-row {
    display:flex; align-items:center; gap:.6rem;
    padding:.5rem 0; border-bottom:1px solid #f5f5f5; font-size:.88rem;
}
.info-row:last-child { border-bottom:none; }
.info-row .label { color:#888; min-width:100px; }
.info-row .value  { font-weight:500; color:#222; }

.no-data-box {
    text-align:center; padding:2rem; color:#adb5bd;
}
.no-data-box i { font-size:2.5rem; display:block; margin-bottom:.5rem; }
</style>

<%-- ─── Hero Banner ─────────────────────────────────────────── --%>
<div class="row mb-4">
    <div class="col-12">
        <div class="hero-banner">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3"
                 style="position:relative;z-index:1">
                <div>
                    <div class="hero-badge mb-2">
                        <i class="bi bi-person-badge"></i> ${roleName}
                    </div>
                    <h2 class="fw-bold mb-1" style="font-size:1.75rem">
                        Xin ch&#xE0;o, <span style="color:#bfdbfe">${user.fullName}</span>!
                    </h2>
                    <p class="mb-0 opacity-75">
                        Ch&#xE0;o m&#x1EEB;ng b&#x1EA1;n quay l&#x1EA1;i h&#x1EC7; th&#x1ED1;ng ph&#xF2;ng kh&#xE1;m.
                        S&#x1EE9;c kh&#x1EDB;e c&#x1EE7;a b&#x1EA1;n l&#xE0; &#x1B0;u ti&#xEA;n h&#xE0;ng &#x111;&#x1EA7;u c&#x1EE7;a ch&#xFA;ng t&#xF4;i.
                    </p>
                </div>
                <c:if test="${user.roleId == 5}">
                    <div class="d-flex gap-2 flex-wrap">
                        <div class="stat-pill">
                            <div class="num">${fn:length(upcomingAppts)}</div>
                            <div class="lbl">L&#x1ECB;ch s&#x1EAF;p t&#x1EDBi</div>
                        </div>
                        <div class="stat-pill">
                            <div class="num">${unreadNotifCount}</div>
                            <div class="lbl">Th&#xF4;ng b&#xE1;o m&#x1EDBi</div>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<%-- ─── Patient Widgets (upcoming appointments + notifications) ─── --%>
<c:if test="${user.roleId == 5}">
<div class="row g-4 mb-4">

    <div class="col-lg-7">
        <div class="card section-card h-100">
            <div class="card-body p-4">
                <div class="section-header">
                    <div class="section-icon" style="background:#e0eeff;color:#1a6fc4">
                        <i class="bi bi-calendar2-week"></i>
                    </div>
                    <div>
                        <h5 class="mb-0 fw-semibold">L&#x1ECB;ch H&#x1EB9;n S&#x1EAF;p T&#x1EDBi</h5>
                        <small class="text-muted">C&#xE1;c l&#x1ECB;ch h&#x1EB9;n ch&#x01B0;a ho&#xE0;n th&#xE0;nh</small>
                    </div>
                    <a href="${pageContext.request.contextPath}/patient/appointments"
                       class="btn btn-sm btn-outline-primary ms-auto rounded-pill" style="font-size:.78rem">
                        Xem t&#x1EA5;t c&#x1EA3; <i class="bi bi-arrow-right"></i>
                    </a>
                </div>

                <c:choose>
                    <c:when test="${empty upcomingAppts}">
                        <div class="no-data-box">
                            <i class="bi bi-calendar-x"></i>
                            <p class="mb-2 fw-medium">Kh&#xF4;ng c&#xF3; l&#x1ECB;ch h&#x1EB9;n s&#x1EAF;p t&#x1EDBi</p>
                            <a href="${pageContext.request.contextPath}/patient/booking"
                               class="btn btn-primary btn-sm rounded-pill">
                                <i class="bi bi-plus-lg me-1"></i>&#x110;&#x1EB7;t L&#x1ECB;ch Ngay
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="appt" items="${upcomingAppts}" varStatus="vs">
                            <c:if test="${vs.index < 3}">
                            <div class="appt-card">
                                <div class="d-flex align-items-center justify-content-between mb-1">
                                    <div class="d-flex align-items-center gap-2">
                                        <i class="bi bi-person-circle text-primary"></i>
                                        <span class="fw-semibold" style="font-size:.9rem">
                                            <c:choose>
                                                <c:when test="${not empty appt.doctor}">BS. ${appt.doctor.fullName}</c:when>
                                                <c:otherwise>Ch&#x01B0;a ph&#xE2;n c&#xF4;ng b&#xE1;c s&#x129;</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <c:choose>
                                        <c:when test="${appt.status == 'Pending'}">
                                            <span class="status-badge status-Pending">Ch&#x1EDD; x&#xE1;c nh&#x1EAD;n</span>
                                        </c:when>
                                        <c:when test="${appt.status == 'Confirmed'}">
                                            <span class="status-badge status-Confirmed">&#x110;&#xE3; x&#xE1;c nh&#x1EAD;n</span>
                                        </c:when>
                                        <c:when test="${appt.status == 'Waiting'}">
                                            <span class="status-badge status-Waiting">&#x110;ang ch&#x1EDD; kh&#xE1;m</span>
                                        </c:when>
                                        <c:when test="${appt.status == 'Emergency_SOS'}">
                                            <span class="status-badge status-Emergency">Kh&#x1EA9;n c&#x1EA5;p</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-Completed">${appt.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="d-flex flex-wrap gap-3 mt-1" style="font-size:.8rem;color:#555">
                                    <c:if test="${not empty appt.appointmentDate}">
                                        <span><i class="bi bi-calendar3 me-1 text-primary"></i>${appt.appointmentDate}</span>
                                    </c:if>
                                    <c:if test="${not empty appt.timeSlot}">
                                        <span><i class="bi bi-clock me-1 text-info"></i>${appt.timeSlot}</span>
                                    </c:if>
                                    <c:if test="${not empty appt.serviceName}">
                                        <span><i class="bi bi-clipboard2-pulse me-1 text-success"></i>${appt.serviceName}</span>
                                    </c:if>
                                </div>
                            </div>
                            </c:if>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="col-lg-5">
        <div class="card section-card h-100">
            <div class="card-body p-4">
                <div class="section-header">
                    <div class="section-icon" style="background:#fff3cd;color:#c77800">
                        <i class="bi bi-bell"></i>
                    </div>
                    <div>
                        <h5 class="mb-0 fw-semibold">Th&#xF4;ng B&#xE1;o G&#x1EA7;n &#x110;&#xE2;y</h5>
                        <small class="text-muted">
                            <c:choose>
                                <c:when test="${unreadNotifCount > 0}">
                                    <span class="badge bg-danger rounded-pill">${unreadNotifCount}</span> ch&#x01B0;a &#x111;&#x1ECD;c
                                </c:when>
                                <c:otherwise>T&#x1EA5;t c&#x1EA3; &#x111;&#xE3; &#x111;&#x1ECD;c</c:otherwise>
                            </c:choose>
                        </small>
                    </div>
                    <a href="${pageContext.request.contextPath}/patient/notifications"
                       class="btn btn-sm btn-outline-warning ms-auto rounded-pill" style="font-size:.78rem">
                        T&#x1EA5;t c&#x1EA3; <i class="bi bi-arrow-right"></i>
                    </a>
                </div>

                <c:choose>
                    <c:when test="${empty recentNotifs}">
                        <div class="no-data-box">
                            <i class="bi bi-bell-slash"></i>
                            <p class="mb-0">Ch&#x01B0;a c&#xF3; th&#xF4;ng b&#xE1;o n&#xE0;o</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="notif" items="${recentNotifs}">
                            <div class="notif-item">
                                <div class="notif-dot ${notif.read ? 'read' : ''}"></div>
                                <div class="flex-grow-1">
                                    <div class="notif-title">${notif.title}</div>
                                    <div class="notif-body">${notif.content}</div>
                                    <c:if test="${not empty notif.createdAt}">
                                        <div class="notif-time">
                                            <i class="bi bi-clock me-1"></i>${notif.createdAt}
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

</div>
</c:if>

<%-- ─── Account Info + Quick Access ──────────────────────────────── --%>
<div class="row g-4">

    <div class="col-lg-4 col-md-6">
        <div class="card section-card h-100">
            <div class="card-body p-4">
                <div class="section-header">
                    <div class="section-icon" style="background:#ede9fe;color:#7c3aed">
                        <i class="bi bi-person-circle"></i>
                    </div>
                    <h5 class="mb-0 fw-semibold">Th&#xF4;ng Tin T&#xE0;i Kho&#x1EA3;n</h5>
                </div>

                <div class="text-center mb-3">
                    <div style="width:72px;height:72px;border-radius:50%;
                                background:linear-gradient(135deg,#1a6fc4,#38bdf8);
                                display:flex;align-items:center;justify-content:center;
                                margin:0 auto;font-size:2rem;color:#fff;font-weight:700;">
                        ${fn:substring(user.fullName, 0, 1)}
                    </div>
                    <div class="fw-bold mt-2" style="font-size:.95rem">${user.fullName}</div>
                    <div class="text-muted" style="font-size:.8rem">${roleName}</div>
                </div>

                <div class="info-row">
                    <i class="bi bi-envelope text-primary"></i>
                    <span class="label">Email:</span>
                    <span class="value">${user.email}</span>
                </div>
                <div class="info-row">
                    <i class="bi bi-telephone text-success"></i>
                    <span class="label">&#x110;i&#x1EC7;n tho&#x1EA1;i:</span>
                    <span class="value">${not empty user.phone ? user.phone : 'Ch&#x01B0;a c&#x1EAD;p nh&#x1EAD;t'}</span>
                </div>
                <div class="info-row">
                    <i class="bi bi-shield-check text-success"></i>
                    <span class="label">Tr&#x1EA1;ng th&#xE1;i:</span>
                    <span class="badge bg-success rounded-pill" style="font-size:.75rem">Ho&#x1EA1;t &#x111;&#x1ED9;ng</span>
                </div>

                <c:if test="${user.roleId == 5}">
                    <div class="mt-3 d-grid">
                        <a href="${pageContext.request.contextPath}/patient/profile"
                           class="btn btn-outline-primary btn-sm rounded-pill">
                            <i class="bi bi-pencil-square me-1"></i>C&#x1EAD;p nh&#x1EAD;t h&#x1ED3; s&#x1A1;
                        </a>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <div class="col-lg-8 col-md-6">
        <div class="card section-card h-100">
            <div class="card-body p-4">
                <div class="section-header">
                    <div class="section-icon" style="background:#d1fae5;color:#059669">
                        <i class="bi bi-grid-3x3-gap"></i>
                    </div>
                    <h5 class="mb-0 fw-semibold">Truy C&#x1EAD;p Nhanh</h5>
                </div>
                <div class="row g-3">

                    <%-- Doctor --%>
                    <c:if test="${user.roleId == 2}">
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/doctor/dashboard" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-speedometer2 text-primary"></i>
                                    <h6>Dashboard B&#xE1;c S&#x129;</h6>
                                    <small class="text-muted">T&#x1ED5;ng quan &amp; th&#x1ED1;ng k&#xEA;</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/doctor/appointments" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-calendar-check text-primary"></i>
                                    <h6>L&#x1ECB;ch H&#x1EB9;n</h6>
                                    <small class="text-muted">Xem l&#x1ECB;ch h&#x1EB9;n h&#xF4;m nay</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/doctor/medical-records" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-journal-medical text-success"></i>
                                    <h6>H&#x1ED3; S&#x1A1; B&#x1EC7;nh &#xC1;n</h6>
                                    <small class="text-muted">Qu&#x1EA3;n l&#xFD; h&#x1ED3; s&#x1A1; b&#x1EC7;nh &#xE1;n</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/doctor/prescriptions-list" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-prescription2 text-danger"></i>
                                    <h6>&#x110;&#x1A1;n Thu&#x1ED1;c</h6>
                                    <small class="text-muted">Danh s&#xE1;ch &#x111;&#x1A1;n thu&#x1ED1;c &#x111;&#xE3; k&#xEA;</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/doctor/patients" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-people text-info"></i>
                                    <h6>B&#x1EC7;nh Nh&#xE2;n</h6>
                                    <small class="text-muted">Danh s&#xE1;ch &amp; l&#x1ECB;ch s&#x1EED; kh&#xE1;m</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- Patient --%>
                    <c:if test="${user.roleId == 5}">
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/patient/booking" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-calendar-plus text-primary"></i>
                                    <h6>&#x110;&#x1EB7;t L&#x1ECB;ch Kh&#xE1;m</h6>
                                    <small class="text-muted">&#x110;&#x1EB7;t l&#x1ECB;ch h&#x1EB9;n m&#x1EDBi</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/patient/appointments" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-calendar2-check text-success"></i>
                                    <h6>L&#x1ECB;ch H&#x1EB9;n C&#x1EE7;a T&#xF4;i</h6>
                                    <small class="text-muted">Xem &amp; qu&#x1EA3;n l&#xFD; l&#x1ECB;ch h&#x1EB9;n</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/patient/medical-records" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-clock-history text-info"></i>
                                    <h6>L&#x1ECB;ch S&#x1EED; Kh&#xE1;m</h6>
                                    <small class="text-muted">Xem l&#x1ECB;ch s&#x1EED; kh&#xE1;m b&#x1EC7;nh</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/patient/medical-records" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-file-earmark-medical text-success"></i>
                                    <h6>K&#x1EBF;t Qu&#x1EA3; X&#xE9;t Nghi&#x1EC7;m</h6>
                                    <small class="text-muted">Xem k&#x1EBF;t qu&#x1EA3; x&#xE9;t nghi&#x1EC7;m</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/patient/notifications" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-bell text-warning"></i>
                                    <h6>Th&#xF4;ng B&#xE1;o</h6>
                                    <small class="text-muted">
                                        <c:choose>
                                            <c:when test="${unreadNotifCount > 0}">${unreadNotifCount} th&#xF4;ng b&#xE1;o m&#x1EDBi</c:when>
                                            <c:otherwise>Xem th&#xF4;ng b&#xE1;o</c:otherwise>
                                        </c:choose>
                                    </small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6 col-lg-4">
                            <a href="${pageContext.request.contextPath}/patient/profile" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-person-gear" style="color:#7c3aed"></i>
                                    <h6>H&#x1ED3; S&#x1A1; C&#xE1; Nh&#xE2;n</h6>
                                    <small class="text-muted">C&#x1EAD;p nh&#x1EAD;t th&#xF4;ng tin</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- Manager --%>
                    <c:if test="${user.roleId == 3}">
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/manager/dashboard" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-graph-up text-primary"></i>
                                    <h6>B&#xE1;o C&#xE1;o</h6>
                                    <small class="text-muted">Th&#x1ED1;ng k&#xEA; doanh thu</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="#" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-people text-success"></i>
                                    <h6>Nh&#xE2;n S&#x1EF1;</h6>
                                    <small class="text-muted">Qu&#x1EA3;n l&#xFD; b&#xE1;c s&#x129;, nh&#xE2;n vi&#xEA;n</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- Staff --%>
                    <c:if test="${user.roleId == 4}">
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/admin/reception" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-calendar-check text-primary"></i>
                                    <h6>Qu&#x1EA3;n L&#xFD; L&#x1ECB;ch H&#x1EB9;n</h6>
                                    <small class="text-muted">X&#xE1;c nh&#x1EAD;n, s&#x1EAF;p x&#x1EBF;p l&#x1ECB;ch h&#x1EB9;n</small>
                                </div>
                            </a>
                        </div>
                        <div class="col-sm-6">
                            <a href="#" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-receipt text-warning"></i>
                                    <h6>H&#xF3;a &#x110;&#x1A1;n</h6>
                                    <small class="text-muted">Qu&#x1EA3;n l&#xFD; thanh to&#xE1;n</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                    <%-- Sonographer --%>
                    <c:if test="${user.roleId == 6}">
                        <div class="col-sm-6">
                            <a href="${pageContext.request.contextPath}/sonographer/dashboard" class="text-decoration-none">
                                <div class="quick-link-card">
                                    <i class="bi bi-soundwave text-primary"></i>
                                    <h6>K&#x1EBF;t Qu&#x1EA3; Si&#xEA;u &#xC2;m</h6>
                                    <small class="text-muted">Nh&#x1EAD;p k&#x1EBF;t qu&#x1EA3; si&#xEA;u &#xE2;m</small>
                                </div>
                            </a>
                        </div>
                    </c:if>

                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>


