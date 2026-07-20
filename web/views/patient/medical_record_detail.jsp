<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ══════════════════════════════════════════════════════════════════════
     CHẾ ĐỘ DANH SÁCH: /patient/medical-records
     ══════════════════════════════════════════════════════════════════════ --%>
<c:if test="${mode == 'list'}">

    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 patient-hero-card rounded-4">
                <div class="card-body p-4">
                    <h2 class="fw-bold mb-1">
                        <i class="bi bi-journal-medical me-2"></i>Hồ Sơ Bệnh Án Của Tôi
                    </h2>
                    <p class="mb-0 opacity-75">Lịch sử khám bệnh và đơn thuốc</p>
                </div>
            </div>
        </div>
    </div>

    <div class="card rounded-4 border-0 shadow-sm">
        <div class="card-body p-4">
            <c:choose>
                <c:when test="${empty records}">
                    <div class="text-center py-5">
                        <i class="bi bi-journal-x text-muted" style="font-size:3rem;"></i>
                        <p class="text-muted mt-3">Bạn chưa có hồ sơ bệnh án nào.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="border-0 ps-3">#</th>
                                    <th class="border-0">Ngày khám</th>
                                    <th class="border-0">Giờ</th>
                                    <th class="border-0">Triệu chứng</th>
                                    <th class="border-0">Chẩn đoán</th>
                                    <th class="border-0">Ngày tạo</th>
                                    <th class="border-0">Chi tiết</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="rec" items="${records}" varStatus="loop">
                                    <tr>
                                        <td class="ps-3 text-muted small">${loop.index + 1}</td>
                                        <td class="text-nowrap fw-medium">${rec.appointmentDate}</td>
                                        <td>
                                            <c:if test="${not empty rec.timeSlot}">
                                                <span class="badge bg-light text-dark border">
                                                    <i class="bi bi-clock me-1"></i>${rec.timeSlot}
                                                </span>
                                            </c:if>
                                        </td>
                                        <td style="max-width:180px;">
                                            <span class="text-truncate d-inline-block" style="max-width:160px;"
                                                  title="${rec.symptoms}">
                                                ${not empty rec.symptoms ? rec.symptoms : '—'}
                                            </span>
                                        </td>
                                        <td style="max-width:220px;">
                                            <span class="text-truncate d-inline-block" style="max-width:200px;"
                                                  title="${rec.finalDiagnosis}">
                                                ${not empty rec.finalDiagnosis ? rec.finalDiagnosis : '—'}
                                            </span>
                                        </td>
                                        <td class="text-muted small text-nowrap">${rec.createdAt}</td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/patient/medical-records?recordId=${rec.id}"
                                               class="btn btn-sm btn-outline-info rounded-pill">
                                                <i class="bi bi-eye me-1"></i>Xem
                                            </a>
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
     CHẾ ĐỘ CHI TIẾT: /patient/medical-records?recordId=X
     ══════════════════════════════════════════════════════════════════════ --%>
<c:if test="${mode == 'detail'}">

    <%-- Banner --%>
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 patient-hero-card rounded-4">
                <div class="card-body p-4">
                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                        <div>
                            <h2 class="fw-bold mb-1">
                                <i class="bi bi-journal-text me-2"></i>Chi Tiết Hồ Sơ Bệnh Án
                            </h2>
                            <p class="mb-0 opacity-75">
                                Ngày khám: ${record.appointmentDate}
                                <c:if test="${not empty record.timeSlot}">&mdash; ${record.timeSlot}</c:if>
                            </p>
                        </div>
                        <a href="${pageContext.request.contextPath}/patient/medical-records"
                           class="btn btn-sm rounded-pill px-3 fw-semibold"
                           style="background: var(--pt-pink-50); color: var(--pt-pink-600); border: 1.5px solid var(--pt-pink-200);">
                            <i class="bi bi-arrow-left me-1"></i>Quay lại
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">

        <%-- Thông tin hồ sơ --%>
        <div class="col-md-6">
            <div class="card rounded-4 border-0 shadow-sm h-100">
                <div class="card-body p-4">
                    <h6 class="fw-semibold mb-3">
                        <i class="bi bi-clipboard2-pulse me-2 text-info"></i>Kết quả khám
                    </h6>
                    <div class="mb-3">
                        <div class="text-muted small mb-1">Triệu chứng</div>
                        <div class="p-3 rounded-3 bg-light small">
                            <c:out value="${not empty record.symptoms ? record.symptoms : '(không có)'}"/>
                        </div>
                    </div>
                    <div class="mb-3">
                        <div class="text-muted small mb-1">Ghi chú lâm sàng</div>
                        <div class="p-3 rounded-3 bg-light small" style="white-space:pre-wrap;">
                            <c:out value="${not empty record.clinicalNotes ? record.clinicalNotes : '(chưa cập nhật)'}"/>
                        </div>
                    </div>
                    <div>
                        <div class="text-muted small mb-1">Chẩn đoán</div>
                        <div class="p-3 rounded-3 fw-medium" style="background:#e8f4f8;">
                            <c:out value="${not empty record.finalDiagnosis ? record.finalDiagnosis : '(chưa có chẩn đoán)'}"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Đơn thuốc --%>
        <div class="col-md-6">
            <div class="card rounded-4 border-0 shadow-sm h-100">
                <div class="card-body p-4">
                    <h6 class="fw-semibold mb-3">
                        <i class="bi bi-prescription2 me-2 text-primary"></i>Đơn thuốc
                    </h6>

                    <c:choose>
                        <c:when test="${empty prescription}">
                            <div class="text-center py-4 text-muted">
                                <i class="bi bi-capsule" style="font-size:2rem;"></i>
                                <p class="mt-2 small">Chưa có đơn thuốc cho lần khám này.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="mb-2 d-flex justify-content-between align-items-center">
                                <small class="text-muted">Mã đơn: <code>${prescription.prescriptionCode}</code></small>
                                <span class="badge rounded-pill
                                    <c:choose>
                                        <c:when test="${prescription.status == 'issued'}">bg-success</c:when>
                                        <c:when test="${prescription.status == 'cancelled'}">bg-danger</c:when>
                                        <c:otherwise>bg-secondary</c:otherwise>
                                    </c:choose>">
                                    ${prescription.status}
                                </span>
                            </div>

                            <c:choose>
                                <c:when test="${empty prescription.items}">
                                    <p class="text-muted small">Đơn thuốc chưa có danh sách thuốc.</p>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-sm table-bordered align-middle mb-0">
                                            <thead class="table-light">
                                                <tr>
                                                    <th class="small border-0">Tên thuốc</th>
                                                    <th class="small border-0 text-center">SL</th>
                                                    <th class="small border-0">Liều dùng</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="item" items="${prescription.items}">
                                                    <tr>
                                                        <td class="small fw-medium">${item.medicineName}</td>
                                                        <td class="small text-center">${item.quantity}</td>
                                                        <td class="small text-muted">${not empty item.dosage ? item.dosage : '—'}</td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
    </div> <%-- Đóng col-md-6 đơn thuốc --%>
</div> <%-- Đóng row g-4 chính --%>

<%-- ══════════ Kết Quả Siêu Âm & AI (Cột 12 ngang bên dưới) ══════════ --%>
<c:if test="${not empty usOrders}">
    <div class="row g-4 mt-2">
        <div class="col-12">
            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-header bg-transparent border-0 fw-bold py-3">
                    <i class="bi bi-soundwave text-info me-2"></i>Phiếu Kết Quả Siêu Âm
                </div>
                <div class="card-body pt-0">
                    <c:forEach var="order" items="${usOrders}" varStatus="loop">
                        <div class="${!loop.first ? 'border-top pt-3 mt-3' : ''}">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                                <span class="fw-semibold">
                                    <i class="bi bi-clipboard2-pulse me-1 text-info"></i>
                                    Lần siêu âm ${loop.index + 1}
                                    <span class="badge bg-light text-dark border ms-1">${order.status}</span>
                                </span>
                                <small class="text-muted">${order.createdAtText}</small>
                            </div>
                            <p class="text-muted small mb-3">
                                Triệu chứng ghi nhận:
                                <c:choose>
                                    <c:when test="${not empty order.symptoms}"><c:out value="${order.symptoms}"/></c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </p>

                            <c:set var="imgs" value="${orderImages[order.orderId]}"/>
                            <c:set var="aiResult" value="${orderAiResults[order.orderId]}"/>

                            <c:choose>
                                <%-- AI output is never published directly to the patient. --%>
                                <c:when test="${order.status == 'confirmed'}">
                            <div class="row g-3 patient-ultrasound-result">
                                <%-- Cột chứa các ảnh (gốc và AI) --%>
                                <div class="col-md-5">
                                    <div class="row g-2">
                                        <%-- Ảnh siêu âm gốc --%>
                                        <c:if test="${not empty imgs}">
                                            <div class="col-6">
                                                <div class="text-muted small mb-1 fw-semibold"><i class="bi bi-image me-1"></i>Ảnh siêu âm trong phiếu kết quả</div>
                                                <c:forEach var="img" items="${imgs}">
                                                    <a href="javascript:void(0);" onclick="viewLargeImage('${pageContext.request.contextPath}/${img.filePath}')" title="Xem ảnh gốc">
                                                        <img src="${pageContext.request.contextPath}/${img.filePath}" alt="Ảnh siêu âm gốc"
                                                             style="width:100%; height:130px; object-fit:cover; border-radius:8px; border:1px solid #dee2e6;"
                                                             onerror="this.src='${pageContext.request.contextPath}/assets/img/us_placeholder.png'">
                                                    </a>
                                                </c:forEach>
                                            </div>
                                        </c:if>

                                        <%-- Ảnh kỹ thuật nội bộ: không hiển thị ở cổng bệnh nhân --%>
                                        <c:if test="${not empty aiResult && not empty aiResult.resultImage}">
                                            <div class="col-6 patient-ai-internal">
                                                <div class="text-muted small mb-1 fw-semibold"><i class="bi bi-cpu me-1"></i>Ảnh kỹ thuật nội bộ</div>
                                                <a href="javascript:void(0);" onclick="viewLargeImage('${pageContext.request.contextPath}/${aiResult.resultImage}')" title="Xem ảnh AI">
                                                    <img src="${pageContext.request.contextPath}/${aiResult.resultImage}" alt="Ảnh phân tích AI"
                                                         style="width:100%; height:130px; object-fit:cover; border-radius:8px; border:1px solid #dee2e6;"
                                                         onerror="this.src='${pageContext.request.contextPath}/assets/img/us_placeholder.png'">
                                                </a>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>

                                <%-- Cột thông tin kết luận & gợi ý AI --%>
                                <div class="col-md-7">
                                    <div class="patient-report-title fw-bold mb-2">
                                        <i class="bi bi-file-earmark-medical me-1"></i>Phiếu kết quả siêu âm đã được bác sĩ xác nhận
                                    </div>
                                    <c:if test="${not empty aiResult}">
                                        <div class="rounded-3 p-3 h-100" style="background:#f0f8ff;border:1px solid #b8d4f0;">
                                            <div class="fw-bold small mb-2 text-primary">
                                                <i class="bi bi-cpu-fill me-1 text-info"></i>Thông tin kỹ thuật nội bộ
                                            </div>
                                            
                                            <%-- Kết luận Bác sĩ --%>
                                            <c:choose>
                                                <c:when test="${order.status == 'confirmed'}">
                                                    <p class="mb-2 small"><strong>Kết luận và hướng dẫn của Bác sĩ:</strong> <span class="fw-bold text-success"><c:out value="${aiResult.message}"/></span></p>
                                                    <div class="mb-3">
                                                        <span class="badge bg-success text-white small" style="font-size:0.75rem;">
                                                            <i class="bi bi-patch-check-fill me-1"></i>Đã được Bác sĩ xác nhận & chốt kết luận
                                                        </span>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <p class="mb-3 small text-muted"><strong>Trạng thái:</strong> Đang chờ Bác sĩ khám chốt kết luận cuối cùng.</p>
                                                </c:otherwise>
                                            </c:choose>

                                            <%-- Chỉ số AI tham khảo --%>
                                            <div class="border-top pt-2 mt-2">
                                                <div class="small fw-semibold text-secondary mb-1">Tham khảo kết quả phân tích AI:</div>
                                                <p class="mb-1 small">
                                                    <strong>Kết quả phát hiện:</strong> 
                                                    <c:choose>
                                                        <c:when test="${aiResult.detected}">
                                                            <span class="text-danger fw-bold"><i class="bi bi-exclamation-triangle-fill me-1"></i>Phát hiện vùng nghi ngờ U xơ tử cung</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-success"><i class="bi bi-check-circle-fill me-1"></i>Không phát hiện vùng bất thường</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </p>
                                                <c:if test="${aiResult.confidence > 0}">
                                                    <p class="mb-0 small text-muted">
                                                        <strong>Độ tin cậy của AI:</strong> <fmt:formatNumber value="${aiResult.confidence}" pattern="0.0"/>%
                                                    </p>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:if>

                                    <c:if test="${empty imgs && empty aiResult}">
                                        <p class="text-muted small fst-italic h-100 d-flex align-items-center justify-content-center border rounded-3 p-3">
                                            Chưa có ảnh siêu âm hoặc kết quả AI cho lần này.
                                        </p>
                                    </c:if>
                                </div>
                            </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="patient-result-pending rounded-3 p-4 text-center">
                                        <i class="bi bi-hourglass-split d-block mb-2"></i>
                                        <strong>Kết quả siêu âm đang chờ bác sĩ xác nhận</strong>
                                        <p class="mb-0 mt-1 small">Ảnh và thông tin hỗ trợ của AI chỉ được sử dụng nội bộ. Phiếu kết quả chính thức sẽ hiển thị tại đây sau khi bác sĩ xem xét và ký xác nhận.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </div>
</c:if>

<!-- Modal xem ảnh lớn -->
<div class="modal fade" id="imageViewerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content bg-transparent border-0">
            <div class="modal-body text-center p-0 position-relative">
                <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-3" data-bs-dismiss="modal" aria-label="Close"></button>
                <img id="modalViewerImage" src="" alt="Zoom Image" style="max-width:100%; max-height:85vh; object-fit:contain; border-radius:8px; box-shadow: 0 5px 15px rgba(0,0,0,0.5);">
            </div>
        </div>
    </div>
</div>

<script>
function viewLargeImage(src) {
    document.getElementById('modalViewerImage').src = src;
    var myModal = new bootstrap.Modal(document.getElementById('imageViewerModal'));
    myModal.show();
}
</script>
</c:if>

<%@ include file="../common/footer.jsp" %>
