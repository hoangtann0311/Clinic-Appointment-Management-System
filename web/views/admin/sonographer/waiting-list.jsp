<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách chờ siêu âm</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
</head>
<body class="bg-light">
<c:set var="dashboardPath" value="/sonographer/dashboard" />
<c:if test="${sessionScope.user.roleId == 1}">
    <c:set var="dashboardPath" value="/admin/dashboard" />
</c:if>
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container-fluid">
        <a class="navbar-brand fw-semibold" href="${pageContext.request.contextPath}${dashboardPath}">CAMS</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar"
                aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="mainNavbar">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}${dashboardPath}">Dashboard</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" aria-current="page" href="${actionUrl}">Chờ siêu âm</a>
                </li>
            </ul>
            <div class="d-flex align-items-center gap-3 text-white">
                <span>${sessionScope.user.fullName}</span>
                <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
            </div>
        </div>
    </div>
</nav>

<main class="container-fluid py-4">
    <div class="d-flex flex-column flex-lg-row align-items-lg-center justify-content-between gap-3 mb-4">
        <div>
            <h1 class="h3 mb-1">Danh sách người bệnh chờ siêu âm</h1>
            <p class="text-secondary mb-0">Tổng số đang chờ: <strong>${totalWaiting}</strong></p>
        </div>
        <a class="btn btn-outline-primary" href="${actionUrl}?sortBy=${sortBy}&sortDir=${sortDir}">Làm mới</a>
    </div>

    <c:if test="${success eq 'completed'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            Đã chuyển trạng thái chỉ định sang <strong>Đã siêu âm</strong>.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>
    <c:if test="${error eq 'updateFailed'}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            Không thể cập nhật chỉ định. Chỉ định có thể đã được xử lý hoặc không còn thuộc danh sách chờ siêu âm.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>
    <c:if test="${error eq 'invalidAction'}">
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
            Thao tác không hợp lệ.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>

    <form class="row gy-2 gx-3 align-items-end bg-white border rounded p-3 mb-4" method="get" action="${actionUrl}">
        <div class="col-12 col-md-5 col-xl-3">
            <label class="form-label" for="sortBy">Sắp xếp theo</label>
            <select class="form-select" id="sortBy" name="sortBy">
                <option value="appointmentDate" ${sortBy eq 'appointmentDate' ? 'selected' : ''}>Ngày hẹn</option>
                <option value="patientName" ${sortBy eq 'patientName' ? 'selected' : ''}>Tên người bệnh</option>
                <option value="serviceName" ${sortBy eq 'serviceName' ? 'selected' : ''}>Dịch vụ siêu âm</option>
                <option value="createdAt" ${sortBy eq 'createdAt' ? 'selected' : ''}>Thời điểm chỉ định</option>
                <option value="emergency" ${sortBy eq 'emergency' ? 'selected' : ''}>Ưu tiên cấp cứu</option>
                <option value="orderId" ${sortBy eq 'orderId' ? 'selected' : ''}>Mã chỉ định</option>
            </select>
        </div>
        <div class="col-12 col-md-4 col-xl-2">
            <label class="form-label" for="sortDir">Thứ tự</label>
            <select class="form-select" id="sortDir" name="sortDir">
                <option value="asc" ${sortDir eq 'asc' ? 'selected' : ''}>Tăng dần</option>
                <option value="desc" ${sortDir eq 'desc' ? 'selected' : ''}>Giảm dần</option>
            </select>
        </div>
        <div class="col-12 col-md-3 col-xl-2">
            <button type="submit" class="btn btn-primary w-100">Sắp xếp</button>
        </div>
    </form>

    <div class="bg-white border rounded">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-primary">
                <tr>
                    <th scope="col">
                        <a class="link-dark text-decoration-none" href="${actionUrl}?sortBy=orderId&sortDir=${sortBy eq 'orderId' ? nextSortDir : 'asc'}">
                            Mã
                        </a>
                    </th>
                    <th scope="col">
                        <a class="link-dark text-decoration-none" href="${actionUrl}?sortBy=patientName&sortDir=${sortBy eq 'patientName' ? nextSortDir : 'asc'}">
                            Người bệnh
                        </a>
                    </th>
                    <th scope="col">
                        <a class="link-dark text-decoration-none" href="${actionUrl}?sortBy=appointmentDate&sortDir=${sortBy eq 'appointmentDate' ? nextSortDir : 'asc'}">
                            Lịch hẹn
                        </a>
                    </th>
                    <th scope="col">
                        <a class="link-dark text-decoration-none" href="${actionUrl}?sortBy=serviceName&sortDir=${sortBy eq 'serviceName' ? nextSortDir : 'asc'}">
                            Dịch vụ
                        </a>
                    </th>
                    <th scope="col">Bác sĩ chỉ định</th>
                    <th scope="col">Ghi chú</th>
                    <th scope="col">Trạng thái</th>
                    <th scope="col" class="text-end">Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty waitingPatients}">
                        <tr>
                            <td colspan="8" class="text-center py-5">
                                <div class="fw-semibold">Không có người bệnh đang chờ siêu âm</div>
                                <div class="text-secondary">Danh sách sẽ hiển thị khi có chỉ định siêu âm ở trạng thái chờ.</div>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="item" items="${waitingPatients}">
                            <tr>
                                <td>
                                    <span class="fw-semibold">#${item.orderId}</span>
                                    <div class="small text-secondary">Tạo: ${item.createdAtText}</div>
                                </td>
                                <td>
                                    <div class="fw-semibold">
                                        <c:out value="${empty item.patientName ? 'Chưa có tên' : item.patientName}" />
                                    </div>
                                    <div class="small text-secondary">
                                        <c:out value="${empty item.phoneNumber ? 'Chưa có SĐT' : item.phoneNumber}" />
                                    </div>
                                    <div class="small text-secondary">${item.dateOfBirthText} · ${item.ageText}</div>
                                    <c:if test="${item.emergency}">
                                        <span class="badge text-bg-danger mt-1">Cấp cứu</span>
                                    </c:if>
                                </td>
                                <td>
                                    <div class="fw-semibold">${item.appointmentDateText}</div>
                                    <div class="text-secondary">${item.timeSlotText}</div>
                                </td>
                                <td>
                                    <div class="fw-semibold">
                                        <c:out value="${empty item.serviceName ? 'Siêu âm' : item.serviceName}" />
                                    </div>
                                    <div class="small text-secondary">${item.priceText}</div>
                                    <div class="d-flex flex-wrap gap-1 mt-1">
                                        <c:if test="${item.requiresFasting}">
                                            <span class="badge text-bg-warning">Nhịn ăn</span>
                                        </c:if>
                                        <c:if test="${item.requiresFullBladder}">
                                            <span class="badge text-bg-info">Bàng quang đầy</span>
                                        </c:if>
                                    </div>
                                </td>
                                <td>
                                    <c:out value="${empty item.doctorName ? 'Chưa xác định' : item.doctorName}" />
                                </td>
                                <td class="text-secondary">
                                    <c:out value="${empty item.symptoms ? 'Không có ghi chú' : item.symptoms}" />
                                </td>
                                <td>
                                    <span class="badge text-bg-secondary">Chờ siêu âm</span>
                                </td>
                                <td class="text-end">
                                    <form method="post" action="${actionUrl}" class="d-inline">
                                        <input type="hidden" name="action" value="markCompleted">
                                        <input type="hidden" name="orderId" value="${item.orderId}">
                                        <input type="hidden" name="sortBy" value="${sortBy}">
                                        <input type="hidden" name="sortDir" value="${sortDir}">
                                        <button type="submit" class="btn btn-success btn-sm">Đã siêu âm</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>
</body>
</html>
