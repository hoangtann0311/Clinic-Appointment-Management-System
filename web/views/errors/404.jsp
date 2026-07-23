<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Không Tìm Thấy</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --bs-body-font-family: 'Be Vietnam Pro', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { font-family: var(--bs-body-font-family); }
    </style>
</head>
<body class="bg-light">
    <div class="container text-center py-5">
        <div class="display-1 text-warning">404</div>
        <h2 class="mb-3">Không Tìm Thấy Trang</h2>
        <p class="text-muted mb-4">Trang bạn yêu cầu không tồn tại hoặc đã bị di chuyển.</p>
        <p class="small text-muted">Mã đối chiếu: <code>${requestScope.requestId}</code></p>
        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">
            <i class="bi bi-house"></i> Về Trang Đăng Nhập
        </a>
    </div>
</body>
</html>
