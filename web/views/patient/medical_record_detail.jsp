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


            <%-- ══════════ Kết Quả Siêu Âm & AI ══════════ --%>
            <c:if test="${not empty usOrders}">
                <div class="card mt-3 border-0 shadow-sm">
                    <div class="card-header bg-transparent border-0 fw-bold py-3">
                        <i class="bi bi-soundwave text-info me-2"></i>Kết Quả Siêu Âm & Phân Tích AI
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
                                <p class="text-muted small mb-2">Ghi chú bác sĩ: ${not empty order.notes ? order.notes : '—'}</p>

                                <%-- Ảnh siêu âm --%>
                                <c:set var="imgs" value="${orderImages[order.orderId]}"/>
                                <c:if test="${not empty imgs}">
                                    <div class="d-flex flex-wrap gap-2 mb-3">
                                        <c:forEach var="img" items="${imgs}">
                                            <a href="${img.imageUrl}" target="_blank" title="${img.imageType}">
                                                <img src="${img.imageUrl}" alt="Ảnh siêu âm"
                                                     style="width:90px;height:90px;object-fit:cover;border-radius:8px;border:1px solid #dee2e6;"
                                                     onerror="this.src='${pageContext.request.contextPath}/assets/img/us_placeholder.png'">
                                            </a>
                                        </c:forEach>
                                    </div>
                                </c:if>

                                <%-- Kết quả AI --%>
                                <c:set var="aiResult" value="${orderAiResults[order.orderId]}"/>
                                <c:if test="${not empty aiResult}">
                                    <div class="rounded-3 p-3" style="background:#f0f8ff;border:1px solid #b8d4f0;">
                                        <div class="fw-bold small mb-2">
                                            <i class="bi bi-robot me-1 text-primary"></i>Phân Tích AI
                                            <span class="badge bg-primary ms-1" style="font-size:0.65rem;">
                                                Độ chính xác: <fmt:formatNumber value="${aiResult.confidenceScore * 100}" pattern="0.0"/>%
                                            </span>
                                        </div>
                                        <p class="mb-1 small"><strong>Chẩn đoán AI:</strong> ${aiResult.diagnosis}</p>
                                        <c:if test="${not empty aiResult.findings}">
                                            <p class="mb-1 small text-muted"><strong>Phát hiện:</strong> ${aiResult.findings}</p>
                                        </c:if>
                                        <c:if test="${not empty aiResult.recommendations}">
                                            <p class="mb-0 small text-muted"><strong>Khuyến nghị:</strong> ${aiResult.recommendations}</p>
                                        </c:if>
                                    </div>
                                </c:if>

                                <c:if test="${empty imgs && empty aiResult}">
                                    <p class="text-muted small fst-italic">Chưa có ảnh siêu âm hoặc kết quả AI cho lần này.</p>
                                </c:if>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

        </div>

    </div>

</c:if>

<%@ include file="../common/footer.jsp" %>
