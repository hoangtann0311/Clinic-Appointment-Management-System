<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../../common/header.jsp" %>

    <div class="admin-page-header">
        <div>
            <h1 class="admin-page-title">
                <i class="bi bi-hourglass-split me-2" style="color:var(--pink-500);"></i>Danh Sách Người Bệnh Chờ Siêu Âm
            </h1>
            <div class="admin-page-subtitle">
                <i class="bi bi-people"></i> Tổng số đang chờ siêu âm hôm nay: <strong>${totalWaiting}</strong>
            </div>
        </div>
        <a class="btn-refresh text-decoration-none d-flex align-items-center justify-content-center" href="${actionUrl}?sortBy=${sortBy}&sortDir=${sortDir}">
            <i class="bi bi-arrow-clockwise me-1"></i> Làm mới
        </a>
    </div>

    <c:if test="${success eq 'completed'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-1"></i> Đã chuyển trạng thái chỉ định sang <strong>Đã siêu âm</strong>.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>
    <c:if test="${error eq 'updateFailed'}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-1"></i> Không thể cập nhật chỉ định. Chỉ định có thể đã được xử lý hoặc không còn thuộc danh sách chờ siêu âm.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>
    <c:if test="${error eq 'invalidAction'}">
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-circle-fill me-1"></i> Thao tác không hợp lệ.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
        </div>
    </c:if>

    <div class="admin-card mb-4">
        <div class="card-body p-3">
            <form class="row gy-2 gx-3 align-items-end" method="get" action="${actionUrl}">
                <div class="col-12 col-md-5 col-xl-3">
                    <label class="form-label font-semibold" for="sortBy">Sắp xếp theo</label>
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
                    <label class="form-label font-semibold" for="sortDir">Thứ tự</label>
                    <select class="form-select" id="sortDir" name="sortDir">
                        <option value="asc" ${sortDir eq 'asc' ? 'selected' : ''}>Tăng dần</option>
                        <option value="desc" ${sortDir eq 'desc' ? 'selected' : ''}>Giảm dần</option>
                    </select>
                </div>
                <div class="col-12 col-md-3 col-xl-2">
                    <button type="submit" class="btn btn-primary w-100 py-2">Sắp xếp</button>
                </div>
            </form>
        </div>
    </div>

    <div class="admin-card">
        <div class="card-header">
            <h5><i class="bi bi-card-list"></i> Danh Sách Bệnh Nhân Chờ Siêu Âm</h5>
        </div>
        <div class="card-body p-0">
            <div class="admin-table-wrapper">
                <table class="admin-table">
                    <thead>
                    <tr>
                        <th scope="col">
                            <a class="link-dark text-decoration-none fw-bold" href="${actionUrl}?sortBy=orderId&sortDir=${sortBy eq 'orderId' ? nextSortDir : 'asc'}">
                                Mã chỉ định <i class="bi bi-chevron-expand"></i>
                            </a>
                        </th>
                        <th scope="col">
                            <a class="link-dark text-decoration-none fw-bold" href="${actionUrl}?sortBy=patientName&sortDir=${sortBy eq 'patientName' ? nextSortDir : 'asc'}">
                                Người bệnh <i class="bi bi-chevron-expand"></i>
                            </a>
                        </th>
                        <th scope="col">
                            <a class="link-dark text-decoration-none fw-bold" href="${actionUrl}?sortBy=appointmentDate&sortDir=${sortBy eq 'appointmentDate' ? nextSortDir : 'asc'}">
                                Lịch hẹn <i class="bi bi-chevron-expand"></i>
                            </a>
                        </th>
                        <th scope="col">
                            <a class="link-dark text-decoration-none fw-bold" href="${actionUrl}?sortBy=serviceName&sortDir=${sortBy eq 'serviceName' ? nextSortDir : 'asc'}">
                                Dịch vụ <i class="bi bi-chevron-expand"></i>
                            </a>
                        </th>
                        <th scope="col" class="fw-bold">Bác sĩ chỉ định</th>
                        <th scope="col" class="fw-bold">Ghi chú triệu chứng</th>
                        <th scope="col" class="fw-bold">Trạng thái</th>
                        <th scope="col" class="text-end fw-bold">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty waitingPatients}">
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <div class="fw-semibold fs-6">Không có người bệnh đang chờ siêu âm</div>
                                    <div class="small">Danh sách sẽ hiển thị khi có chỉ định siêu âm ở trạng thái chờ.</div>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${waitingPatients}">
                                <tr>
                                    <td>
                                        <span class="fw-semibold text-dark">#${item.orderId}</span>
                                        <div class="small text-secondary">Tạo: ${item.createdAtText}</div>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark">
                                            <c:out value="${empty item.patientName ? 'Chưa có tên' : item.patientName}" />
                                        </div>
                                        <div class="small text-secondary">
                                            <i class="bi bi-telephone me-1"></i><c:out value="${empty item.phoneNumber ? 'Chưa có SĐT' : item.phoneNumber}" />
                                        </div>
                                        <div class="small text-secondary">${item.dateOfBirthText} · ${item.ageText}</div>
                                        <c:if test="${item.emergency}">
                                            <span class="badge bg-danger mt-1">Cấp cứu</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <div class="fw-semibold">${item.appointmentDateText}</div>
                                        <div class="text-secondary small">${item.timeSlotText}</div>
                                    </td>
                                    <td>
                                        <div class="fw-semibold text-primary">
                                            <c:out value="${empty item.serviceName ? 'Siêu âm' : item.serviceName}" />
                                        </div>
                                        <div class="small text-secondary fw-medium">${item.priceText}</div>
                                        <div class="d-flex flex-wrap gap-1 mt-1">
                                            <c:if test="${item.requiresFasting}">
                                                <span class="badge bg-warning text-dark">Nhịn ăn</span>
                                            </c:if>
                                            <c:if test="${item.requiresFullBladder}">
                                                <span class="badge bg-info text-dark">Bàng quang đầy</span>
                                            </c:if>
                                        </div>
                                    </td>
                                    <td>
                                        <i class="bi bi-person-fill text-muted me-1"></i><c:out value="${empty item.doctorName ? 'Chưa xác định' : item.doctorName}" />
                                    </td>
                                    <td class="text-secondary small">
                                        <c:out value="${empty item.symptoms ? 'Không có ghi chú' : item.symptoms}" />
                                    </td>
                                    <td>
                                        <span class="badge-status badge-status-pending">Chờ siêu âm</span>
                                    </td>
                                    <td class="text-end">
                                        <form method="post" action="${actionUrl}" class="d-inline">
                                            <input type="hidden" name="action" value="markCompleted">
                                            <input type="hidden" name="orderId" value="${item.orderId}">
                                            <input type="hidden" name="sortBy" value="${sortBy}">
                                            <input type="hidden" name="sortDir" value="${sortDir}">
                                            <button type="submit" class="btn btn-success btn-sm font-semibold px-3 py-1.5">
                                                <i class="bi bi-check2-circle me-1"></i> Đã siêu âm
                                            </button>
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
    </div>

<%@ include file="../../common/footer.jsp" %>
