<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cài Đặt Hệ Thống — Admin CAMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        :root { --bs-body-font-family: 'Be Vietnam Pro', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body.admin-body { font-family: var(--bs-body-font-family); background: #f7f3f5; }
    </style>
</head>
<body class="admin-body">

<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" onclick="toggleSidebar()" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital"></i> CAMS <span>Admin</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role"><i class="bi bi-shield-check me-1"></i>Admin</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout">
            <i class="bi bi-box-arrow-right"></i> <span class="d-none d-md-inline">Đăng xuất</span>
        </a>
    </div>
</nav>

<%@ include file="../layout/sidebar.jsp" %>

<main class="admin-main" id="adminMain">
    <div class="placeholder-page">
        <div class="placeholder-icon">
            <i class="bi bi-tools"></i>
        </div>
        <h3>Đang Phát Triển</h3>
        <p>Tính năng <strong>Cài Đặt Hệ Thống</strong> đang được xây dựng và sẽ sớm ra mắt.</p>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn rounded-3 fw-medium"
           style="background:var(--cams-tertiary-container);color:var(--cams-on-tertiary-container);border:none;padding:0.6rem 1.5rem;">
            <i class="bi bi-arrow-left me-2"></i>Quay lại Dashboard
        </a>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous">
</script>
</body>
</html>
