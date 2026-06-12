<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ══════════════════════════════════════════════════════════════════════
     CHẾ ĐỘ DANH SÁCH: /doctor/medical-records
     ══════════════════════════════════════════════════════════════════════ --%>
<c:if test="${mode == 'list'}">

    <%-- Banner --%>
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 bg-success bg-gradient text-white rounded-4">
                <div class="card-body p-4">
                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                        <div>
                            <h2 class="fw-bold mb-1">
                                <i class="bi bi-journal-medical me-2"></i>Hồ Sơ Bệnh Án
                            </h2>
                            <p class="mb-0 opacity-75">BS. ${doctorName} &mdash; Tất cả hồ sơ đã tạo</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/doctor/appointments"
                           class="btn btn-light btn-sm rounded-pill px-3">
                            <i class="bi bi-arrow-left me-1"></i>Lịch hẹn
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Thanh tìm kiếm --%>
    <div class="card rounded-4 border-0 shadow-sm mb-4">
        <div class="card-body p-3">
            <form method="get" action="${pageContext.request.contextPath}/doctor/medical-records"
                  class="d-flex gap-2 align-items-center">
                <div class="input-group rounded-3 overflow-hidden" style="max-width:420px;">
                    <span class="input-group-text bg-white border-end-0">
                        <i class="bi bi-search text-muted"></i>
                    </span>
                    <input type="text" name="keyword" class="form-control border-start-0"
                           placeholder="Tìm theo tên bệnh nhân hoặc chẩn đoán…"
                           value="${keyword}">
                </div>
                <button type="submit" class="btn btn-success rounded-3 px-3">Tìm</button>
                <c:if test="${not empty keyword}">
                    <a href="${pageContext.request.contextPath}/doctor/medical-records"
                       class="btn btn-outline-secondary rounded-3">
                        <i class="bi bi-x-circle me-1"></i>Xoá lọc
                    </a>
                </c:if>
            </form>
        </div>
    </div>

    <%-- Bảng danh sách --%>
    <div class="card rounded-4 border-0 shadow-sm">
        <div class="card-header bg-transparent border-0 p-4 pb-0">
            <h6 class="fw-semibold mb-0">
                <i class="bi bi-list-ul me-2 text-success"></i>
                Danh sách hồ sơ
                <span class="badge bg-success rounded-pill ms-2">${fn:length(records)}</span>
                <c:if test="${not empty keyword}">
                    <span class="badge bg-light text-dark border ms-2">
                        Lọc: &ldquo;${keyword}&rdquo;
                    </span>
                </c:if>
            </h6>
        </div>
        <div class="card-body p-4 pt-3">
            <c:choose>
                <c:when test="${empty records}">
                    <div class="text-center py-5">
                        <i class="bi bi-journal-x text-muted" style="font-size:3rem;"></i>
                        <p class="text-muted mt-3 mb-0">
                            <c:choose>
                                <c:when test="${not empty keyword}">Không tìm thấy hồ sơ nào phù hợp.</c:when>
                                <c:otherwise>Chưa có hồ sơ bệnh án nào.</c:otherwise>
                            </c:choose>
                        </p>
                        <a href="${pageContext.request.contextPath}/doctor/appointments"
                           class="btn btn-sm btn-outline-success mt-3 rounded-pill">
                            Đến danh sách lịch hẹn
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="border-0 ps-3">#</th>
                                    <th class="border-0">Bệnh nhân</th>
                                    <th class="border-0">Ngày khám</th>
                                    <th class="border-0">Giờ</th>
                                    <th class="border-0">Chẩn đoán</th>
                                    <th class="border-0">Ngày tạo</th>
                                    <th class="border-0">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="rec" items="${records}" varStatus="loop">
                                    <tr>
                                        <td class="ps-3 text-muted small">${loop.index + 1}</td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="rounded-circle bg-success bg-opacity-10 text-success
                                                            d-flex align-items-center justify-content-center me-2 fw-bold"
                                                     style="width:36px;height:36px;min-width:36px;font-size:.85rem;">
                                                    ${fn:toUpperCase(fn:substring(rec.patientName,0,1))}
                                                </div>
                                                <span class="fw-medium">${rec.patientName}</span>
                                            </div>
                                        </td>
                                        <td class="text-nowrap">${rec.appointmentDate}</td>
                                        <td class="text-nowrap">
                                            <c:if test="${not empty rec.timeSlot}">
                                                <span class="badge bg-light text-dark border">
                                                    <i class="bi bi-clock me-1"></i>${rec.timeSlot}
                                                </span>
                                            </c:if>
                                        </td>
                                        <td style="max-width:220px;">
                                            <span class="text-truncate d-inline-block" style="max-width:200px;"
                                                  title="${rec.finalDiagnosis}">
                                                ${not empty rec.finalDiagnosis ? rec.finalDiagnosis : '—'}
                                            </span>
                                        </td>
                                        <td class="text-nowrap text-muted small">${rec.createdAt}</td>
                                        <td>
                                            <div class="d-flex gap-1">
                                                <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${rec.appointmentId}"
                                                   class="btn btn-sm btn-outline-success rounded-pill">
                                                    <i class="bi bi-pencil me-1"></i>Hồ sơ
                                                </a>
                                                <a href="${pageContext.request.contextPath}/doctor/prescriptions?recordId=${rec.id}"
                                                   class="btn btn-sm btn-outline-primary rounded-pill">
                                                    <i class="bi bi-prescription2 me-1"></i>Đơn thuốc
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

</c:if>

<%-- ══════════════════════════════════════════════════════════════════════
     CHẾ ĐỘ FORM: /doctor/medical-records?apptId=X
     ══════════════════════════════════════════════════════════════════════ --%>
<c:if test="${mode == 'form'}">

    <%-- Thông báo lỗi --%>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger rounded-3 mb-3">
            <i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}
        </div>
    </c:if>

    <%-- Thông báo lưu thành công --%>
    <c:if test="${param.saved == '1'}">
        <div class="alert alert-success rounded-3 mb-3 d-flex align-items-center gap-2 alert-dismissible fade show">
            <i class="bi bi-check-circle-fill"></i>
            Hồ sơ bệnh án đã được lưu thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <%-- Banner --%>
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 bg-success bg-gradient text-white rounded-4">
                <div class="card-body p-4">
                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                        <div>
                            <h2 class="fw-bold mb-1">
                                <i class="bi bi-journal-plus me-2"></i>
                                <c:choose>
                                    <c:when test="${record.id > 0}">Cập nhật hồ sơ bệnh án</c:when>
                                    <c:otherwise>Tạo hồ sơ bệnh án mới</c:otherwise>
                                </c:choose>
                            </h2>
                            <p class="mb-0 opacity-75">BS. ${doctorName}</p>
                        </div>
                        <div class="d-flex gap-2">
                            <a href="${pageContext.request.contextPath}/doctor/medical-records"
                               class="btn btn-light btn-sm rounded-pill px-3">
                                <i class="bi bi-list me-1"></i>Danh sách
                            </a>
                            <a href="${pageContext.request.contextPath}/doctor/appointments"
                               class="btn btn-outline-light btn-sm rounded-pill px-3">
                                <i class="bi bi-arrow-left me-1"></i>Lịch hẹn
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">

        <%-- Cột trái: Thông tin lịch hẹn (chỉ đọc) --%>
        <div class="col-md-4">
            <div class="card rounded-4 border-0 shadow-sm h-100">
                <div class="card-body p-4">
                    <h6 class="fw-semibold mb-3">
                        <i class="bi bi-person-circle me-2 text-success"></i>Thông tin bệnh nhân
                    </h6>

                    <div class="d-flex flex-column gap-3">
                        <div>
                            <div class="text-muted small mb-1">Họ tên</div>
                            <div class="fw-medium fs-5">
                                <c:out value="${not empty record.patientName ? record.patientName : '—'}"/>
                            </div>
                        </div>
                        <div>
                            <div class="text-muted small mb-1">Ngày hẹn</div>
                            <div class="fw-medium">
                                <i class="bi bi-calendar3 me-1 text-success"></i>
                                <c:out value="${not empty record.appointmentDate ? record.appointmentDate : '—'}"/>
                            </div>
                        </div>
                        <div>
                            <div class="text-muted small mb-1">Giờ khám</div>
                            <div class="fw-medium">
                                <i class="bi bi-clock me-1 text-success"></i>
                                <c:out value="${not empty record.timeSlot ? record.timeSlot : '—'}"/>
                            </div>
                        </div>
                        <div>
                            <div class="text-muted small mb-1">Triệu chứng báo cáo</div>
                            <div class="p-2 rounded-3" style="background:#f8f9fa;font-size:.9rem;">
                                <c:out value="${not empty record.symptoms ? record.symptoms : '(không có)'}"/>
                            </div>
                        </div>

                        <c:if test="${record.id > 0}">
                            <div>
                                <div class="text-muted small mb-1">Ngày tạo hồ sơ</div>
                                <div class="small text-muted">${record.createdAt}</div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <%-- Cột phải: Form nhập liệu --%>
        <div class="col-md-8">
            <div class="card rounded-4 border-0 shadow-sm">
                <div class="card-body p-4">
                    <h6 class="fw-semibold mb-4">
                        <i class="bi bi-pencil-square me-2 text-success"></i>Nội dung hồ sơ
                    </h6>

                    <form method="post"
                          action="${pageContext.request.contextPath}/doctor/medical-records">

                        <%-- Hidden fields --%>
                        <input type="hidden" name="appointmentId" value="${apptId}"/>
                        <c:if test="${record.id > 0}">
                            <input type="hidden" name="recordId" value="${record.id}"/>
                        </c:if>

                        <%-- Ghi chú lâm sàng --%>
                        <div class="mb-4">
                            <label class="form-label fw-medium" for="clinicalNotes">
                                <i class="bi bi-stethoscope me-1 text-success"></i>
                                Ghi chú lâm sàng
                            </label>
                            <textarea id="clinicalNotes"
                                      name="clinicalNotes"
                                      class="form-control rounded-3"
                                      rows="6"
                                      placeholder="Mô tả kết quả thăm khám, các dấu hiệu lâm sàng, thông số sinh hiệu..."
                                      required>${record.clinicalNotes}</textarea>
                            <div class="form-text">
                                Ghi lại toàn bộ quan sát và kết quả thăm khám.
                            </div>
                        </div>

                        <%-- Chẩn đoán cuối --%>
                        <div class="mb-4">
                            <label class="form-label fw-medium" for="finalDiagnosis">
                                <i class="bi bi-clipboard2-pulse me-1 text-success"></i>
                                Chẩn đoán
                                <span class="text-danger">*</span>
                            </label>
                            <textarea id="finalDiagnosis"
                                      name="finalDiagnosis"
                                      class="form-control rounded-3"
                                      rows="4"
                                      placeholder="Nhập chẩn đoán cuối cùng (ICD-10 nếu có)..."
                                      required>${record.finalDiagnosis}</textarea>
                        </div>

                        <%-- Nút lưu --%>
                        <div class="d-flex gap-3 align-items-center">
                            <button type="submit" class="btn btn-success rounded-3 px-4">
                                <i class="bi bi-floppy me-2"></i>
                                <c:choose>
                                    <c:when test="${record.id > 0}">Cập nhật hồ sơ</c:when>
                                    <c:otherwise>Lưu hồ sơ</c:otherwise>
                                </c:choose>
                            </button>

                            <a href="${pageContext.request.contextPath}/doctor/appointments"
                               class="btn btn-outline-secondary rounded-3">
                                Huỷ
                            </a>

                            <span class="ms-auto text-muted small">
                                <i class="bi bi-info-circle me-1"></i>
                                <c:choose>
                                    <c:when test="${record.id > 0}">Lưu sẽ không đổi trạng thái lịch hẹn khi cập nhật.</c:when>
                                    <c:otherwise>Lưu lần đầu sẽ tự chuyển lịch hẹn sang <strong>Hoàn thành</strong>.</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </form>
                </div>
            </div>

            <%-- Card kê đơn thuốc (chỉ hiện khi hồ sơ đã tồn tại) --%>
            <c:if test="${record.id > 0}">
                <div class="card rounded-4 border-0 shadow-sm mt-3">
                    <div class="card-body p-3 d-flex align-items-center justify-content-between">
                        <div>
                            <span class="fw-medium">Bước tiếp theo</span>
                            <span class="text-muted small ms-2">Kê đơn thuốc cho bệnh nhân này</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/doctor/prescriptions?recordId=${record.id}"
                           class="btn btn-outline-primary btn-sm rounded-pill px-3">
                            <i class="bi bi-prescription2 me-1"></i>Kê đơn thuốc
                        </a>
                    </div>
                </div>
            </c:if>
        </div>

    </div>

</c:if>

<%@ include file="../common/footer.jsp" %>
