<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CAMS - Clinic Appointment Management System</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <!-- Bootstrap Icons CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
          rel="stylesheet">
    <!-- Google Fonts: Be Vietnam Pro (thiết kế riêng cho tiếng Việt) -->
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap"
          rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css"
          rel="stylesheet">
    <style>
        :root {
            --primary-color: #0d6efd;
            --success-color: #198754;
            /* Ghi đè font mặc định của Bootstrap 5 bằng font hỗ trợ tiếng Việt */
            --bs-body-font-family: 'Be Vietnam Pro', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        body {
            background-color: #f5f7fa;
            font-family: var(--bs-body-font-family);
        }
        .navbar-brand {
            font-weight: 700;
            font-size: 1.25rem;
        }
        .card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
        }
        .btn-primary {
            border-radius: 8px;
            padding: 10px 24px;
            font-weight: 500;
        }
        .form-control {
            border-radius: 8px;
            padding: 10px 14px;
            border: 1px solid #dee2e6;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15);
        }
    </style>
</head>
<c:choose>
    <c:when test="${not empty sessionScope.user && (sessionScope.user.roleId == 2 || sessionScope.user.roleId == 6)}">
        <!-- Rose Pink Theme Header/Sidebar for Doctor (2) and Sonographer (6) -->
        <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
        <body class="admin-body">
        
        <%-- TOP BAR --%>
        <nav class="admin-topbar">
            <div class="admin-topbar-left">
                <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar" onclick="toggleSidebar()">
                    <i class="bi bi-list"></i>
                </button>
                <a href="${pageContext.request.contextPath}/home" class="admin-topbar-brand">
                    <i class="bi bi-hospital-fill"></i>
                    CAMS
                    <span class="brand-badge">${sessionScope.user.roleId == 2 ? 'Doctor' : 'Sonographer'}</span>
                </a>
            </div>
            <div class="admin-topbar-right">
                <div class="admin-topbar-user d-none d-md-flex">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.avatarUrl}">
                            <img src="${sessionScope.user.avatarUrl}" alt="Avatar" class="admin-avatar-sm"
                                 style="object-fit:cover;"
                                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                            <div class="admin-avatar-sm" style="display:none;">
                                ${fn:substring(sessionScope.user.fullName, 0, 1)}
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="admin-avatar-sm">
                                ${fn:substring(sessionScope.user.fullName, 0, 1)}
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <span>${sessionScope.user.fullName}</span>
                    <span class="admin-topbar-role">
                        <i class="bi bi-briefcase-fill me-1"></i>${sessionScope.user.roleId == 2 ? 'Bác Sĩ' : 'KTV Siêu Âm'}
                    </span>
                </div>

                <%-- Chuông thông báo — chỉ hiện cho bác sĩ --%>
                <c:if test="${sessionScope.user.roleId == 2}">
                <div class="position-relative me-2" id="notifBell" style="cursor:pointer;"
                     onclick="toggleNotifDropdown(event)">
                    <i class="bi bi-bell-fill" style="font-size:1.2rem;color:#e91e8c;"></i>
                    <span id="notifBadge"
                          class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger"
                          style="font-size:.6rem;display:none;">0</span>
                </div>

                <%-- Dropdown thông báo --%>
                <div id="notifDropdown"
                     class="card border-0 shadow-lg rounded-4 d-none"
                     style="position:fixed;top:56px;right:80px;width:360px;z-index:9999;max-height:480px;overflow:hidden;">
                    <div class="card-header d-flex align-items-center justify-content-between py-2 px-3"
                         style="background:#fff;">
                        <span class="fw-bold small">Thông báo</span>
                        <button class="btn btn-sm btn-link text-muted p-0 small"
                                onclick="markAllRead(event)">Đánh dấu tất cả đã đọc</button>
                    </div>
                    <div id="notifList" style="overflow-y:auto;max-height:400px;">
                        <div class="text-center py-4 text-muted small" id="notifEmpty">
                            <i class="bi bi-bell-slash d-block fs-3 mb-2 opacity-25"></i>
                            Chưa có thông báo
                        </div>
                    </div>
                </div>
                </c:if>

                <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout" title="Đăng xuất">
                    <i class="bi bi-box-arrow-right"></i>
                    <span class="d-none d-md-inline">Đăng xuất</span>
                </a>
            </div>
        </nav>

        <!-- Sidebar Backdrop (mobile) -->
        <div class="admin-sidebar-backdrop" id="sidebarBackdrop" onclick="closeSidebar()"></div>

        <!-- Sidebar -->
        <aside class="admin-sidebar" id="adminSidebar">
            <div class="admin-sidebar-user">
                <c:choose>
                    <c:when test="${not empty sessionScope.user.avatarUrl}">
                        <img src="${sessionScope.user.avatarUrl}" alt="Avatar" class="admin-sidebar-avatar"
                             style="object-fit:cover;"
                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                        <div class="admin-sidebar-avatar" style="display:none;">
                            ${fn:substring(sessionScope.user.fullName, 0, 1)}
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="admin-sidebar-avatar">
                            ${fn:substring(sessionScope.user.fullName, 0, 1)}
                        </div>
                    </c:otherwise>
                </c:choose>
                <div class="admin-sidebar-name">${sessionScope.user.fullName}</div>
                <span class="admin-sidebar-badge">
                    <i class="bi bi-person-badge-fill"></i>${sessionScope.user.roleId == 2 ? 'Bác Sĩ' : 'KTV Siêu Âm'}
                </span>
            </div>

            <ul class="admin-sidebar-menu">
                <c:choose>
                    <c:when test="${sessionScope.user.roleId == 2}">
                        <li class="admin-sidebar-section">Chức Năng Bác Sĩ</li>
                        <li>
                            <a href="${pageContext.request.contextPath}/doctor/dashboard">
                                <i class="bi bi-speedometer2"></i>
                                <span>Dashboard</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/doctor/appointments">
                                <i class="bi bi-calendar2-week"></i>
                                <span>Lịch Hẹn Hôm Nay</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/doctor/medical-records">
                                <i class="bi bi-journal-medical"></i>
                                <span>Quản Lý Bệnh Án</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/doctor/prescriptions-list">
                                <i class="bi bi-prescription2"></i>
                                <span>Đơn Thuốc</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/doctor/patients">
                                <i class="bi bi-people"></i>
                                <span>Danh Sách Bệnh Nhân</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/doctor/profile">
                                <i class="bi bi-person-circle"></i>
                                <span>Hồ Sơ Của Tôi</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/doctor/schedules">
                                <i class="bi bi-calendar2-check"></i>
                                <span>Lịch Làm Việc</span>
                            </a>
                        </li>
                    </c:when>
                    <c:when test="${sessionScope.user.roleId == 6}">
                        <li class="admin-sidebar-section">Chức Năng Siêu Âm</li>
                        <li>
                            <a href="${pageContext.request.contextPath}/sonographer/dashboard" 
                               class="${fn:contains(pageContext.request.requestURI, '/dashboard') ? 'active' : ''}">
                                <i class="bi bi-speedometer2"></i>
                                <span>Dashboard Thống Kê</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/sonographer/waiting-list" 
                               class="${fn:contains(pageContext.request.requestURI, '/waiting-list') && empty param.status ? 'active' : ''}">
                                <i class="bi bi-hourglass-split"></i>
                                <span>Yêu Cầu Chờ Siêu Âm</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=InProgress" 
                               class="${param.status == 'InProgress' ? 'active' : ''}">
                                <i class="bi bi-play-circle"></i>
                                <span>Đang Thực Hiện</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=Uploaded" 
                               class="${param.status == 'Uploaded' ? 'active' : ''}">
                                <i class="bi bi-cloud-upload"></i>
                                <span>Đã Tải Ảnh (Chờ AI)</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/sonographer/waiting-list?status=Completed" 
                               class="${param.status == 'Completed' ? 'active' : ''}">
                                <i class="bi bi-check-circle"></i>
                                <span>Đã Hoàn Thành</span>
                            </a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/sonographer/ai-model" 
                               class="${fn:contains(pageContext.request.requestURI, '/ai-model') ? 'active' : ''}">
                                <i class="bi bi-robot"></i>
                                <span>Model AI</span>
                            </a>
                        </li>
                    </c:when>
                </c:choose>
            </ul>
        </aside>

        <!-- Main Content Wrapper -->
        <main class="admin-main" id="adminMain">

        <%-- JS: Auto active sidebar link based on current URL --%>
        <script>
        (function() {
            var path = window.location.pathname;
            var links = document.querySelectorAll('.admin-sidebar-menu li a');
            var bestMatch = null, bestLen = 0;
            links.forEach(function(a) {
                var href = a.getAttribute('href');
                if (!href) return;
                // Strip context path prefix if needed
                var rel = href.split('?')[0];
                if (path.endsWith(rel) || path.includes(rel)) {
                    if (rel.length > bestLen) {
                        bestLen = rel.length;
                        bestMatch = a;
                    }
                }
            });
            if (bestMatch) bestMatch.classList.add('active');
        })();
        </script>

        <%-- JS thông báo (chỉ load cho bác sĩ) --%>
        <c:if test="${sessionScope.user.roleId == 2}">
        <style>
          #notifBell {
              padding: 4px 8px;
              border-radius: 8px;
              transition: background .2s;
              display: flex !important;
              align-items: center;
              position: relative;
          }
          #notifBell:hover { background: rgba(233,30,140,.1); }
          #notifDropdown .notif-item { padding: 10px 14px; border-bottom: 1px solid #f0f0f0;
            cursor: pointer; transition: background .15s; }
          #notifDropdown .notif-item:hover { background: #fafafa; }
          #notifDropdown .notif-item.unread { background: #fff5fb; }
          #notifDropdown .notif-item.unread:hover { background: #fce4f3; }
          #notifDropdown .notif-dot { width:8px;height:8px;border-radius:50%;
            background:#e91e8c;flex-shrink:0;margin-top:4px; }
        </style>
        <script>
        document.addEventListener('DOMContentLoaded', function() {
          var CTX = '${pageContext.request.contextPath}';
          var dropdown = document.getElementById('notifDropdown');
          var badge    = document.getElementById('notifBadge');
          var list     = document.getElementById('notifList');
          var empty    = document.getElementById('notifEmpty');
          var open     = false;

          if (!dropdown || !badge) return; // guard nếu elements chưa có

          // ── Polling đếm unread mỗi 30 giây ──────────────────────────────
          function pollUnread() {
            fetch(CTX + '/doctor/notifications?count=1')
              .then(function(r){ return r.json(); })
              .then(function(d){
                if (d.unread > 0) {
                  badge.textContent = d.unread > 99 ? '99+' : d.unread;
                  badge.style.display = '';
                } else {
                  badge.style.display = 'none';
                }
              }).catch(function(){});
          }
          pollUnread();
          setInterval(pollUnread, 30000);

          // ── Load danh sách khi mở dropdown ───────────────────────────────
          function loadNotifs() {
            fetch(CTX + '/doctor/notifications')
              .then(function(r){ return r.json(); })
              .then(function(d){
                badge.textContent = d.unread > 99 ? '99+' : d.unread;
                badge.style.display = d.unread > 0 ? '' : 'none';

                if (!d.items || d.items.length === 0) {
                  list.innerHTML = '';
                  empty.style.display = '';
                  return;
                }
                empty.style.display = 'none';
                var html = '';
                d.items.forEach(function(n) {
                  html += '<div class="notif-item d-flex gap-2 ' + (n.isRead ? '' : 'unread') + '"' +
                    ' onclick="readNotif(' + n.id + ',this)">' +
                    (!n.isRead ? '<div class="notif-dot mt-1 flex-shrink-0"></div>' :
                      '<div style="width:8px;flex-shrink:0;"></div>') +
                    '<div class="flex-grow-1">' +
                      '<div class="fw-semibold small">' + escHtml(n.title) + '</div>' +
                      '<div class="small text-muted" style="line-height:1.3;">' + escHtml(n.content) + '</div>' +
                      '<div class="text-muted" style="font-size:.7rem;margin-top:2px;">' + n.timeAgo + '</div>' +
                    '</div>' +
                    '</div>';
                });
                list.innerHTML = html;
              }).catch(function(){});
          }

          window.toggleNotifDropdown = function(e) {
            e.stopPropagation();
            open = !open;
            dropdown.classList.toggle('d-none', !open);
            if (open) loadNotifs();
          };

          window.readNotif = function(id, el) {
            fetch(CTX + '/doctor/notifications?action=read&id=' + id, { method:'POST' })
              .then(function(){ pollUnread(); });
            el.classList.remove('unread');
            var dot = el.querySelector('.notif-dot');
            if (dot) dot.style.display = 'none';
          };

          window.markAllRead = function(e) {
            e.stopPropagation();
            fetch(CTX + '/doctor/notifications?action=readAll', { method:'POST' })
              .then(function(){ loadNotifs(); });
          };

          // Đóng dropdown khi click ra ngoài
          document.addEventListener('click', function(e) {
            if (open && !dropdown.contains(e.target)) {
              open = false;
              dropdown.classList.add('d-none');
            }
          });

          function escHtml(s) {
            return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;')
                          .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
          }
        }); // end DOMContentLoaded
        </script>
        </c:if>

    </c:when>
    <c:when test="${not empty sessionScope.user && sessionScope.user.roleId == 5}">
        <!-- Rose-Pink Theme Header/Sidebar for Patient (5) -->
        <link href="${pageContext.request.contextPath}/assets/css/patient.css" rel="stylesheet">
        <body class="patient-body">

        <%-- TOP BAR --%>
        <nav class="patient-topbar">
            <div class="patient-topbar-left">
                <button class="patient-sidebar-toggle" id="ptSidebarToggle" onclick="togglePtSidebar()" aria-label="Toggle sidebar">
                    <i class="bi bi-list"></i>
                </button>
                <a href="${pageContext.request.contextPath}/home" class="patient-topbar-brand">
                    <i class="bi bi-heart-pulse-fill"></i>
                    CAMS
                    <span class="pt-brand-badge">Bệnh Nhân</span>
                </a>
            </div>
            <div class="patient-topbar-right">
                <div class="patient-topbar-user d-none d-md-flex">
                    <div class="patient-avatar-sm">
                        ${fn:substring(sessionScope.user.fullName, 0, 1)}
                    </div>
                    <span>${sessionScope.user.fullName}</span>
                    <span class="patient-topbar-role">
                        <i class="bi bi-person-heart me-1"></i>Bệnh Nhân
                    </span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="patient-topbar-logout" title="Đăng xuất">
                    <i class="bi bi-box-arrow-right"></i>
                    <span class="d-none d-md-inline">Đăng xuất</span>
                </a>
            </div>
        </nav>

        <!-- Sidebar Backdrop (mobile) -->
        <div class="patient-sidebar-backdrop" id="ptSidebarBackdrop" onclick="closePtSidebar()"></div>

        <!-- Sidebar -->
        <aside class="patient-sidebar" id="ptSidebar">
            <div class="patient-sidebar-user">
                <div class="patient-sidebar-avatar">
                    ${fn:substring(sessionScope.user.fullName, 0, 1)}
                </div>
                <div class="patient-sidebar-name">${sessionScope.user.fullName}</div>
                <span class="patient-sidebar-badge">
                    <i class="bi bi-person-heart me-1"></i>Bệnh Nhân
                </span>
            </div>

            <ul class="patient-sidebar-menu">
                <li class="patient-sidebar-section">Tổng Quan</li>
                <li>
                    <a href="${pageContext.request.contextPath}/home">
                        <i class="bi bi-speedometer2"></i>
                        <span>Dashboard</span>
                    </a>
                </li>

                <li class="patient-sidebar-section">Lịch Hẹn & Khám</li>
                <li>
                    <a href="${pageContext.request.contextPath}/patient/booking">
                        <i class="bi bi-calendar-plus"></i>
                        <span>Đặt Lịch Khám</span>
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/patient/appointments">
                        <i class="bi bi-calendar2-week"></i>
                        <span>Lịch Hẹn Của Tôi</span>
                    </a>
                </li>

                <li class="patient-sidebar-section">Hồ Sơ Y Tế</li>
                <li>
                    <a href="${pageContext.request.contextPath}/patient/medical-records">
                        <i class="bi bi-journal-medical"></i>
                        <span>Hồ Sơ Bệnh Án</span>
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/patient/pregnancy">
                        <i class="bi bi-heart-pulse-fill"></i>
                        <span>Theo Dõi Thai Kỳ</span>
                    </a>
                </li>

                <li class="patient-sidebar-section">Tài Khoản</li>
                <li>
                    <a href="${pageContext.request.contextPath}/patient/profile">
                        <i class="bi bi-person-circle"></i>
                        <span>Hồ Sơ Cá Nhân</span>
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/patient/notifications">
                        <i class="bi bi-bell"></i>
                        <span>Thông Báo</span>
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/logout" class="pt-logout-link">
                        <i class="bi bi-box-arrow-right"></i>
                        <span>Đăng Xuất</span>
                    </a>
                </li>
            </ul>
        </aside>

        <!-- Main Content Wrapper -->
        <main class="patient-main" id="ptMain">

        <%-- JS: Auto active sidebar link --%>
        <script>
        (function() {
            var path = window.location.pathname;
            var links = document.querySelectorAll('.patient-sidebar-menu li a');
            var bestMatch = null, bestLen = 0;
            links.forEach(function(a) {
                var href = a.getAttribute('href');
                if (!href) return;
                var rel = href.split('?')[0];
                if (path === rel || path.startsWith(rel + '/') || path.startsWith(rel + '?')) {
                    if (rel.length > bestLen && rel.length > 1) {
                        bestLen = rel.length;
                        bestMatch = a;
                    }
                }
            });
            if (bestMatch) bestMatch.classList.add('active');
        })();
        </script>

    </c:when>
    <c:otherwise>
        <body>
        <!-- Navbar -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm">
            <div class="container">
                <a class="navbar-brand" href="${pageContext.request.contextPath}/">
                    <i class="bi bi-hospital me-2"></i>CAMS
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav"
                        aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav ms-auto align-items-lg-center">

                        <%-- ========== Khi chưa đăng nhập ========== --%>
                        <c:if test="${empty sessionScope.user}">
                            <li class="nav-item">
                                <a class="nav-link" href="${pageContext.request.contextPath}/login">
                                    <i class="bi bi-box-arrow-in-right me-1"></i>Đăng nhập
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="${pageContext.request.contextPath}/register">
                                    <i class="bi bi-person-plus me-1"></i>Đăng ký
                                </a>
                            </li>
                        </c:if>

                        <%-- ========== Khi đã đăng nhập ========== --%>
                        <c:if test="${not empty sessionScope.user}">
                            <%-- Link về Dashboard --%>
                            <li class="nav-item">
                                <a class="nav-link" href="${pageContext.request.contextPath}/home">
                                    <i class="bi bi-speedometer2 me-1"></i>Dashboard
                                </a>
                            </li>

                            <%-- Menu riêng cho Patient (roleId == 5) --%>
                            <c:if test="${sessionScope.user.roleId == 5}">
                                <li class="nav-item">
                                    <a class="nav-link" href="${pageContext.request.contextPath}/patient/booking">
                                        <i class="bi bi-calendar-plus me-1"></i>Đặt Lịch Khám
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="${pageContext.request.contextPath}/patient/appointments">
                                        <i class="bi bi-calendar2-week me-1"></i>Lịch Hẹn Của Tôi
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="${pageContext.request.contextPath}/patient/medical-records">
                                        <i class="bi bi-journal-medical me-1"></i>Hồ Sơ Khám Bệnh
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="${pageContext.request.contextPath}/patient/pregnancy">
                                        <i class="bi bi-heart-pulse-fill text-danger me-1"></i>Theo Dõi Thai Kỳ
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link position-relative" href="${pageContext.request.contextPath}/patient/notifications">
                                        <i class="bi bi-bell me-1"></i>Thông Báo
                                    </a>
                                </li>
                            </c:if>

                            <%-- Dropdown tài khoản --%>
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle d-flex align-items-center" href="#"
                                   id="userDropdown" role="button" data-bs-toggle="dropdown"
                                   aria-expanded="false">
                                    <span class="avatar-circle me-2">
                                        ${fn:substring(sessionScope.user.fullName, 0, 1)}
                                    </span>
                                    ${sessionScope.user.fullName}
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 rounded-3"
                                    aria-labelledby="userDropdown">
                                    <li>
                                        <div class="dropdown-header">
                                            <small class="text-muted">${sessionScope.user.email}</small>
                                        </div>
                                    </li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li>
                                        <a class="dropdown-item" href="${pageContext.request.contextPath}/patient/profile">
                                            <i class="bi bi-person me-2"></i>Hồ sơ cá nhân
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="${pageContext.request.contextPath}/patient/notifications">
                                            <i class="bi bi-bell me-2"></i>Thông báo
                                        </a>
                                    </li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li>
                                        <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">
                                            <i class="bi bi-box-arrow-right me-2"></i>Đăng xuất
                                        </a>
                                    </li>
                                </ul>
                            </li>
                        </c:if>
                    </ul>
                </div>
            </div>
        </nav>

        <!-- Main Content Container -->
        <main class="container my-4">
    </c:otherwise>
</c:choose>
