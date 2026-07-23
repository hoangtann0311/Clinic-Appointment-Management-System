<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="../common/header.jsp" />

<%-- CSS and document shell are provided once by common/header.jsp. --%>
<!-- Page Title Row -->
<div class="admin-page-header">
    <div class="admin-page-header-left">
        <h1 class="admin-page-title">Danh Sách Yêu Cầu Siêu Âm</h1>
        <div class="admin-page-subtitle">
            Quản lý siêu âm &gt; Chỉ định từ Bác sĩ lâm sàng
        </div>
    </div>
</div>

<!-- Alerts -->
<c:if test="${not empty success}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>
        <c:choose>
            <c:when test="${success == 'completed'}">Đã xác nhận hoàn thành ca siêu âm!</c:when>
            <c:otherwise>Thao tác thực hiện thành công!</c:otherwise>
        </c:choose>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
<c:if test="${not empty error}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <c:out value="${error}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<!-- Advanced Filters -->
<div class="admin-card mb-4">
    <div class="card-body">
        <form method="GET" action="${pageContext.request.contextPath}/sonographer/waiting-list" class="row g-3">
            <div class="col-md-3">
                <label class="form-label text-muted small fw-bold">TÌM KIẾM</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                    <input type="text" name="search" class="form-control border-start-0 ps-0" placeholder="Tên sản phụ, Bác sĩ lâm sàng, mã SA..." value="${searchParam}">
                </div>
            </div>
            <div class="col-md-3">
                <label class="form-label text-muted small fw-bold">TRẠNG THÁI</label>
                <select name="status" class="form-select">
                    <option value="">Tất cả trạng thái</option>
                    <option value="Pending" ${statusParam == 'Pending' ? 'selected' : ''}>Chờ siêu âm</option>
                    <option value="InProgress" ${statusParam == 'InProgress' ? 'selected' : ''}>Đang siêu âm</option>
                    <option value="Uploaded" ${statusParam == 'Uploaded' ? 'selected' : ''}>Đã tải ảnh</option>
                    <option value="Completed" ${statusParam == 'Completed' ? 'selected' : ''}>Đã hoàn thành</option>
                    <option value="confirmed" ${statusParam == 'confirmed' ? 'selected' : ''}>Đã xác nhận</option>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label text-muted small fw-bold">NGÀY CHỈ ĐỊNH</label>
                <input type="date" name="date" class="form-control" value="${dateParam}">
            </div>
            <div class="col-md-3 d-flex align-items-end gap-2">
                <button type="submit" class="btn btn-primary w-100 flex-grow-1">
                    <i class="bi bi-funnel-fill me-1"></i> Lọc danh sách
                </button>
                <a href="${pageContext.request.contextPath}/sonographer/waiting-list" class="btn btn-light border" title="Đặt lại bộ lọc">
                    <i class="bi bi-arrow-counterclockwise"></i>
                </a>
            </div>
        </form>
    </div>
</div>

<!-- Requests Table Card -->
<div class="admin-card">
    <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
        <h5 class="m-0 fw-bold text-dark d-flex align-items-center gap-2">
            <i class="bi bi-list-task text-primary"></i> 
            Danh Sách Chỉ Định Siêu Âm (${totalOrders} kết quả)
        </h5>
    </div>
    <div class="card-body p-0">
        <div class="admin-table-wrapper">
            <table class="admin-table table-cams">
                <thead>
                    <tr>
                        <th>
                            <a href="?sortBy=orderId&sortDir=${nextSortDir}&search=${searchParam}&status=${statusParam}&date=${dateParam}" class="text-dark d-flex align-items-center gap-1">
                                Mã Yêu Cầu <i class="bi bi-arrow-down-up small text-muted"></i>
                            </a>
                        </th>
                        <th>
                            <a href="?sortBy=patientName&sortDir=${nextSortDir}&search=${searchParam}&status=${statusParam}&date=${dateParam}" class="text-dark d-flex align-items-center gap-1">
                                Sản Phụ <i class="bi bi-arrow-down-up small text-muted"></i>
                            </a>
                        </th>
                        <th>
                            <a href="?sortBy=serviceName&sortDir=${nextSortDir}&search=${searchParam}&status=${statusParam}&date=${dateParam}" class="text-dark d-flex align-items-center gap-1">
                                Dịch Vụ Siêu Âm <i class="bi bi-arrow-down-up small text-muted"></i>
                            </a>
                        </th>
                        <th>Chỉ Định Bởi</th>
                        <th>
                            <a href="?sortBy=createdAt&sortDir=${nextSortDir}&search=${searchParam}&status=${statusParam}&date=${dateParam}" class="text-dark d-flex align-items-center gap-1">
                                Thời Gian <i class="bi bi-arrow-down-up small text-muted"></i>
                            </a>
                        </th>
                        <th>Trạng Thái</th>
                        <th>Thao Tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty waitingPatients}">
                            <tr>
                                <td colspan="7" class="text-center text-muted py-5">
                                    <i class="bi bi-card-checklist fs-2 d-block mb-2 text-muted"></i>
                                    Không tìm thấy yêu cầu siêu âm nào.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="order" items="${waitingPatients}">
                                <tr>
                                    <td><strong>SA-${order.orderId}</strong></td>
                                    <td>
                                        <span class="fw-bold text-dark"><c:out value="${order.patientName}"/></span><br>
                                        <small class="text-muted"><i class="bi bi-telephone me-1"></i><c:out value="${order.phoneNumber}"/></small>
                                    </td>
                                    <td>
                                        <span class="fw-semibold text-dark"><c:out value="${order.serviceName}"/></span><br>
                                        <small class="text-danger fw-bold"><c:out value="${String.format('%,.0f', order.price)}"/>đ</small>
                                    </td>
                                    <td>
                                        <span>BS. <c:out value="${order.doctorName}"/></span>
                                    </td>
                                    <td>
                                        <span>${fn:substring(order.createdAt, 11, 16)}</span><br>
                                        <small class="text-muted">${fn:substring(order.createdAt, 0, 10)}</small>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${fn:toLowerCase(order.status) == 'pending'}">
                                                <span class="badge bg-secondary-subtle text-secondary border border-secondary-subtle">Chờ tiếp nhận</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(order.status) == 'inprogress'}">
                                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle">Đang siêu âm</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(order.status) == 'uploaded'}">
                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle">Đã tải ảnh</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(order.status) == 'analyzing'}">
                                                <span class="badge bg-info-subtle text-info border border-info-subtle">AI Phân tích</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(order.status) == 'completed'}">
                                                <span class="badge bg-success-subtle text-success border border-success-subtle">Hoàn thành</span>
                                            </c:when>
                                            <c:when test="${fn:toLowerCase(order.status) == 'confirmed'}">
                                                <span class="badge bg-success text-white border border-success">Đã xác nhận</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-muted border"><c:out value="${order.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/sonographer/detail?orderId=${order.orderId}" 
                                           class="btn btn-sm ${fn:toLowerCase(order.status) == 'pending' ? 'btn-success' : 'btn-outline-primary'} fw-bold">
                                            <c:choose>
                                                <c:when test="${fn:toLowerCase(order.status) == 'pending'}">
                                                    <i class="bi bi-play-fill"></i> Tiến hành
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="bi bi-eye-fill"></i> Chi tiết
                                                </c:otherwise>
                                            </c:choose>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
    
    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <div class="card-footer bg-white py-3 border-top d-flex justify-content-center">
            <nav aria-label="Page navigation">
                <ul class="pagination pagination-cams m-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage - 1}&search=${searchParam}&status=${statusParam}&date=${dateParam}&sortBy=${sortBy}&sortDir=${sortDir}">
                            <i class="bi bi-chevron-left"></i>
                        </a>
                    </li>
                    <c:forEach var="p" begin="1" end="${totalPages}">
                        <li class="page-item ${currentPage == p ? 'active' : ''}">
                            <a class="page-link" href="?page=${p}&search=${searchParam}&status=${statusParam}&date=${dateParam}&sortBy=${sortBy}&sortDir=${sortDir}">${p}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage + 1}&search=${searchParam}&status=${statusParam}&date=${dateParam}&sortBy=${sortBy}&sortDir=${sortDir}">
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<jsp:include page="../common/footer.jsp" />
