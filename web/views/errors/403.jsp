<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="../common/header.jsp" %>

<div class="row justify-content-center">
    <div class="col-md-6 text-center">
        <div class="card p-5">
            <div class="mb-4">
                <div class="error-icon-wrapper bg-danger bg-opacity-10 text-danger mx-auto mb-3">
                    <i class="bi bi-shield-exclamation display-1"></i>
                </div>
                <h1 class="display-4 fw-bold text-danger">403</h1>
                <h4 class="fw-semibold mb-2">
                    <c:choose>
                        <c:when test="${not empty errorTitle}"><c:out value="${errorTitle}" /></c:when>
                        <c:otherwise>Truy Cập Bị Từ Chối</c:otherwise>
                    </c:choose>
                </h4>
                <p class="text-muted mb-4">
                    <c:choose>
                        <c:when test="${not empty errorDetail}"><c:out value="${errorDetail}" /></c:when>
                        <c:otherwise>Bạn không có quyền truy cập vào trang này.</c:otherwise>
                    </c:choose>
                </p>
                <p class="small text-muted">Mã đối chiếu: <code><c:out value="${requestId}" /></code></p>
            </div>
            <div class="d-flex justify-content-center gap-2">
                <a href="javascript:history.back()" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-2"></i>Quay lại
                </a>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-primary">
                    <i class="bi bi-house me-2"></i>Về Dashboard
                </a>
            </div>
        </div>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
