<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>400 - Yêu cầu không hợp lệ</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"></head>
<body class="bg-light"><main class="container text-center py-5"><div class="display-1 text-warning">400</div>
<h2>Yêu cầu không hợp lệ</h2><p class="text-muted">Dữ liệu gửi lên bị thiếu hoặc sai định dạng. Vui lòng kiểm tra và thử lại.</p>
<p class="small text-muted">Mã đối chiếu: <code>${requestScope.requestId}</code></p>
<a href="javascript:history.back()" class="btn btn-outline-secondary me-2">Quay lại</a><a href="${pageContext.request.contextPath}/home" class="btn btn-primary">Về trang chính</a>
</main></body></html>
