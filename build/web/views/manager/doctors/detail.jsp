<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Bác Sĩ — ${fn:escapeXml(doctor.fullName)} — CAMS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        .detail-header {
            background: linear-gradient(135deg, #F0F7FF 0%, #E0EFFF 40%, #E0EFFF 100%);
            border-radius: var(--r-lg); padding: 1.5rem 1.75rem;
            margin-bottom: 1.5rem; border: 1px solid var(--pink-200);
            display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem;
        }
        .detail-header h1 {
            font-family: 'Nunito','Be Vietnam Pro',sans-serif;
            font-weight: 800; font-size: 1.4rem; color: var(--c-primary-dark); margin: 0;
        }
        .detail-card {
            background: var(--c-surface); border: 1px solid var(--c-outline-variant);
            border-radius: var(--r-lg); overflow: hidden; margin-bottom: 1.25rem;
        }
        .detail-card-header {
            background: var(--pink-50); padding: 0.8rem 1.2rem;
            border-bottom: 1px solid var(--pink-200);
            font-family: 'Nunito','Be Vietnam Pro',sans-serif;
            font-weight: 700; color: var(--c-primary-dark); font-size: 0.95rem;
            display: flex; align-items: center; gap: 0.5rem;
        }
        .detail-card-body { padding: 1.2rem; }
        .info-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1rem;
        }
        .info-item { display: flex; gap: 0.75rem; align-items: flex-start; }
        .info-icon {
            width: 40px; height: 40px; border-radius: var(--r-sm);
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem; color: #fff; flex-shrink: 0;
            background: linear-gradient(135deg, var(--pink-400), var(--pink-500));
        }
        .info-label { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--c-muted); }
        .info-value { font-weight: 600; color: var(--c-on-surface); font-size: 0.9rem; }
        .btn-back {
            display: inline-flex; align-items: center; gap: 0.35rem;
            padding: 0.5rem 1rem; border-radius: var(--r-sm);
            background: var(--c-surface); border: 1px solid var(--c-outline);
            color: var(--c-on-surface-var); font-weight: 600; font-size: 0.85rem;
            text-decoration: none; transition: all var(--t-fast);
        }
        .btn-back:hover { background: var(--c-surface-variant); }
        .status-active { background: #D1FAE5; color: #065F46; }
        .status-inactive { background: #FEE2E2; color: #991B1B; }
        .doc-avatar-lg {
            width: 72px; height: 72px; border-radius: 50%;
            background: linear-gradient(135deg, var(--pink-400), var(--pink-600));
            color: #fff; display: flex; align-items: center; justify-content: center;
            font-size: 1.8rem; font-weight: 700; flex-shrink: 0;
        }
        .specialty-tag {
            display: inline-block; padding: 3px 12px; border-radius: var(--r-pill);
            font-size: 0.75rem; font-weight: 600;
            background: var(--pink-50); color: var(--pink-700);
            border: 1px solid var(--pink-200);
        }
    </style>
</head>
<body class="admin-body">

<%-- TOP BAR --%>
<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/manager/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i> CAMS <span class="brand-badge">Quản Lý</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="dropdown admin-topbar-dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle"
               id="adminUserDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="admin-avatar-sm me-2">
                    ${not empty sessionScope.user.fullName ? fn:substring(sessionScope.user.fullName, 0, 1) : '?'}
                </div>
                <span class="d-none d-md-inline fw-semibold text-dark">${sessionScope.user.fullName}</span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg rounded-3" aria-labelledby="adminUserDropdown">
                <li class="dropdown-header">
                    <h6 class="text-dark mb-0 fw-bold">${sessionScope.user.fullName}</h6>
                    <small class="text-muted">Quản lý</small>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/manager/profile"><i class="bi bi-person-circle me-2 text-muted"></i>Hồ Sơ Cá Nhân</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng Xuất</a></li>
            </ul>
        </div>
    </div>
</nav>

<%-- SIDEBAR --%>
<%@ include file="../layout/sidebar.jsp" %>

<%-- MAIN CONTENT --%>
<main class="admin-main" id="adminMain">

    <div class="detail-header">
        <div style="display:flex;align-items:center;gap:1rem;">
            <div class="doc-avatar-lg">
                ${fn:substring(doctor.fullName, 0, 1)}
            </div>
            <div>
                <h1>${fn:escapeXml(doctor.fullName)}</h1>
                <p class="mb-0 mt-1" style="font-size:0.85rem;color:var(--c-on-surface-var);">
                    <i class="bi bi-person-badge me-1"></i> Mã bác sĩ: #${doctor.id}
                    <c:if test="${not empty doctor.specialization}">
                        <span class="mx-2">&middot;</span>
                        <span class="specialty-tag">${fn:escapeXml(doctor.specialization)}</span>
                    </c:if>
                </p>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/manager/doctors/" class="btn-back">
            <i class="bi bi-arrow-left"></i> Quay lại danh sách
        </a>
    </div>

    <%-- Thông tin cá nhân --%>
    <div class="detail-card">
        <div class="detail-card-header">
            <i class="bi bi-person-vcard"></i> Thông Tin Cá Nhân
        </div>
        <div class="detail-card-body">
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-person-fill"></i></div>
                    <div>
                        <div class="info-label">Họ và Tên</div>
                        <div class="info-value">${fn:escapeXml(doctor.fullName)}</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-hash"></i></div>
                    <div>
                        <div class="info-label">Mã Bác Sĩ</div>
                        <div class="info-value">#${doctor.id}</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-telephone-fill"></i></div>
                    <div>
                        <div class="info-label">Số Điện Thoại</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${not empty doctor.phoneNumber}">${doctor.phoneNumber}</c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-envelope-fill"></i></div>
                    <div>
                        <div class="info-label">Email</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${not empty doctor.email}">${doctor.email}</c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Thông tin chuyên môn --%>
    <div class="detail-card">
        <div class="detail-card-header">
            <i class="bi bi-mortarboard-fill"></i> Thông Tin Chuyên Môn
        </div>
        <div class="detail-card-body">
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-heart-pulse-fill"></i></div>
                    <div>
                        <div class="info-label">Chuyên Khoa</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${not empty doctor.specialization}">${fn:escapeXml(doctor.specialization)}</c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-patch-check-fill"></i></div>
                    <div>
                        <div class="info-label">Bằng Cấp / Chứng Chỉ</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${not empty doctor.degree}">${fn:escapeXml(doctor.degree)}</c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-clock-history"></i></div>
                    <div>
                        <div class="info-label">Số Năm Kinh Nghiệm</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${doctor.experienceYears > 0}">${doctor.experienceYears} năm</c:when>
                                <c:otherwise>Chưa cập nhật</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Bio / Giới thiệu --%>
            <c:if test="${not empty doctor.bio}">
                <div class="mt-3">
                    <div class="info-label mb-1">Mô Tả / Giới Thiệu</div>
                    <div style="background:var(--c-surface-variant);border-radius:var(--r-sm);padding:0.8rem 1rem;font-size:0.85rem;color:var(--c-on-surface);line-height:1.6;">
                        ${fn:escapeXml(doctor.bio)}
                    </div>
                </div>
            </c:if>
        </div>
    </div>

    <%-- Trạng thái --%>
    <div class="detail-card">
        <div class="detail-card-header">
            <i class="bi bi-shield-check"></i> Trạng Thái Tài Khoản & Làm Việc
        </div>
        <div class="detail-card-body">
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-person-check-fill"></i></div>
                    <div>
                        <div class="info-label">Trạng Thái Tài Khoản</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${doctor.userStatus == 'Active'}">
                                    <span class="badge-status status-active">Đang Hoạt Động</span>
                                </c:when>
                                <c:when test="${doctor.userStatus == 'Inactive'}">
                                    <span class="badge-status status-inactive">Ngừng Hoạt Động</span>
                                </c:when>
                                <c:otherwise>
                                    ${not empty doctor.userStatus ? fn:escapeXml(doctor.userStatus) : '—'}
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-briefcase-fill"></i></div>
                    <div>
                        <div class="info-label">Trạng Thái Làm Việc</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${doctor.userStatus == 'Active'}">
                                    <span style="color:#059669;font-weight:600;">
                                        <i class="bi bi-check-circle-fill me-1"></i>Đang làm việc
                                    </span>
                                </c:when>
                                <c:when test="${doctor.userStatus == 'Inactive'}">
                                    <span style="color:#dc2626;font-weight:600;">
                                        <i class="bi bi-x-circle-fill me-1"></i>Ngừng làm việc
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color:#6B7280;">—</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });
</script>

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
