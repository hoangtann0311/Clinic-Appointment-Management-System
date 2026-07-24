<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ═══════════ DANH SÁCH ═══════════ --%>
<c:if test="${mode == 'list'}">
<div class="mb-4">
    <div class="card border-0 patient-hero-card rounded-4">
        <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div>
                <h2 class="fw-bold mb-1"><i class="bi bi-journal-medical me-2"></i>Hồ Sơ Bệnh Án Của Tôi</h2>
                <p class="mb-0 opacity-75">Lịch sử khám bệnh và đơn thuốc</p>
            </div>
        </div>
    </div>
</div>
<div class="card rounded-4 border-0 shadow-sm">
    <div class="card-body p-0">
        <c:choose>
            <c:when test="${empty records}">
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-journal-x d-block mb-2" style="font-size:2.5rem;opacity:.3;"></i>
                    <p>Bạn chưa có hồ sơ bệnh án nào.</p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table table-hover align-middle mb-0" style="table-layout:fixed;width:100%;">
                    <thead class="table-light">
                        <tr>
                            <th style="width:4%;" class="ps-3">#</th>
                            <th style="width:12%;">Ngày khám</th>
                            <th style="width:13%;">Giờ</th>
                            <th style="width:22%;">Chẩn đoán</th>
                            <th style="width:15%;">Ngày tạo</th>
                            <th style="width:10%;" class="text-center">Chi tiết</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="rec" items="${records}" varStatus="loop">
                            <tr>
                                <td class="ps-3 text-muted small">${loop.index + 1}</td>
                                <td class="fw-medium" style="font-size:.85rem;">${rec.appointmentDateText}</td>
                                <td style="font-size:.85rem;">${not empty rec.timeSlot ? rec.timeSlot : '—'}</td>
                                <td style="font-size:.84rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:0;" title="${rec.finalDiagnosis}">${not empty rec.finalDiagnosis ? rec.finalDiagnosis : '—'}</td>
                                <td class="text-muted small">${rec.createdAtText}</td>
                                <td class="text-center">
                                    <a href="${pageContext.request.contextPath}/patient/medical-records?recordId=${rec.id}" class="btn btn-sm btn-outline-info rounded-pill"><i class="bi bi-eye me-1"></i>Xem</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</c:if>

<%-- ═══════════ CHƯA CÔNG BỐ ═══════════ --%>
<c:if test="${mode == 'unreleased'}">
<div class="card border-0 shadow-sm rounded-4 p-4 text-center">
    <i class="bi bi-clock-history text-warning display-4 mb-3"></i>
    <h4 class="fw-bold">Kết quả chưa được công bố</h4>
    <p class="text-muted mb-4">${unreleasedNotice}</p>
    <a href="${pageContext.request.contextPath}/patient/medical-records" class="btn btn-primary rounded-pill px-4"><i class="bi bi-arrow-left me-1"></i>Quay lại danh sách</a>
</div>
</c:if>

<%-- ═══════════ CHI TIẾT ═══════════ --%>
<c:if test="${mode == 'detail'}">

<style>
    .detail-label { font-size: .75rem; color: #64748b; text-transform: uppercase; letter-spacing: .04em; font-weight: 600; }
    .detail-value { font-size: .88rem; }
    .vital-badge { display:inline-block;padding:.25rem .6rem;border-radius:.4rem;background:#f8fafc;border:1px solid #e2e8f0;font-size:.82rem;white-space:nowrap; }
</style>

<%-- Banner --%>
<div class="mb-4">
    <div class="card border-0 patient-hero-card rounded-4">
        <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div>
                <h2 class="fw-bold mb-1"><i class="bi bi-journal-text me-2"></i>Chi Tiết Hồ Sơ Bệnh Án</h2>
                <p class="mb-0 opacity-75">Ngày khám: ${record.appointmentDateText} <c:if test="${not empty record.timeSlot}">&mdash; ${record.timeSlot}</c:if></p>
            </div>
            <a href="${pageContext.request.contextPath}/patient/medical-records" class="btn btn-sm rounded-pill px-3 fw-semibold" style="background:var(--pt-pink-50);color:var(--pt-pink-600);border:1.5px solid var(--pt-pink-200);"><i class="bi bi-arrow-left me-1"></i>Quay lại</a>
        </div>
    </div>
</div>

<div class="row g-4">
    <%-- ═══════════ KẾT QUẢ KHÁM ═══════════ --%>
    <div class="col-md-6">
        <div class="card rounded-4 border-0 shadow-sm h-100">
            <div class="card-body p-4">
                <h6 class="fw-semibold mb-3"><i class="bi bi-clipboard2-pulse me-2 text-info"></i>Kết Quả Khám</h6>

                <%-- Chẩn đoán — quan trọng nhất --%>
                <c:if test="${not empty record.finalDiagnosis}">
                <div class="mb-3">
                    <div class="detail-label mb-1">Chẩn đoán</div>
                    <div class="p-3 rounded-3 fw-medium detail-value" style="background:#e8f4f8;">${record.finalDiagnosis}</div>
                </div>
                </c:if>

                <%-- Triệu chứng --%>
                <c:if test="${not empty record.symptoms}">
                <div class="mb-3">
                    <div class="detail-label mb-1">Triệu chứng</div>
                    <div class="p-3 rounded-3 bg-light detail-value" style="white-space:pre-wrap;">${record.symptoms}</div>
                </div>
                </c:if>

                <%-- Sinh hiệu --%>
                <c:if test="${not empty record.weightKg || not empty record.bloodPressure || not empty record.pulseBpm || not empty record.temperatureC}">
                <div class="mb-3">
                    <div class="detail-label mb-2">Sinh hiệu</div>
                    <div class="d-flex flex-wrap gap-2">
                        <c:if test="${not empty record.weightKg}"><span class="vital-badge">Cân nặng: ${record.weightKg} kg</span></c:if>
                        <c:if test="${not empty record.bloodPressure}"><span class="vital-badge">Huyết áp: ${record.bloodPressure}</span></c:if>
                        <c:if test="${not empty record.pulseBpm}"><span class="vital-badge">Mạch: ${record.pulseBpm} l/ph</span></c:if>
                        <c:if test="${not empty record.temperatureC}"><span class="vital-badge">Nhiệt độ: ${record.temperatureC}°C</span></c:if>
                    </div>
                </div>
                </c:if>

                <%-- Thai kỳ --%>
                <c:if test="${not empty record.gestationalAgeWeeks || not empty record.fetalHeartRate}">
                <div class="mb-3">
                    <div class="detail-label mb-2">Thai kỳ</div>
                    <div class="d-flex flex-wrap gap-2">
                        <c:if test="${not empty record.gestationalAgeWeeks}"><span class="vital-badge">${record.gestationalAgeDisplay}</span></c:if>
                        <c:if test="${not empty record.fundalHeightCm}"><span class="vital-badge">Bề cao tử cung: ${record.fundalHeightCm} cm</span></c:if>
                        <c:if test="${not empty record.fetalHeartRate}"><span class="vital-badge">Tim thai: ${record.fetalHeartRate} l/ph</span></c:if>
                        <c:if test="${not empty record.fetalPresentation}"><span class="vital-badge">Ngôi: ${record.fetalPresentation}</span></c:if>
                    </div>
                </div>
                </c:if>

                <%-- Ghi chú --%>
                <c:if test="${not empty record.clinicalNotes}">
                <div class="mb-3">
                    <div class="detail-label mb-1">Ghi chú của bác sĩ</div>
                    <div class="p-3 rounded-3 bg-light detail-value" style="white-space:pre-wrap;">${record.clinicalNotes}</div>
                </div>
                </c:if>

                <%-- Kế hoạch --%>
                <c:if test="${not empty record.treatmentPlan || not empty record.nextAppointmentDate}">
                <div>
                    <div class="detail-label mb-1">Kế hoạch điều trị</div>
                    <c:if test="${not empty record.treatmentPlan}"><p class="detail-value mb-1">${record.treatmentPlan}</p></c:if>
                    <c:if test="${not empty record.nextAppointmentDate}"><span class="badge bg-info text-dark">Tái khám: ${record.nextAppointmentDate}</span></c:if>
                </div>
                </c:if>
            </div>
        </div>
    </div>

    <%-- ═══════════ ĐƠN THUỐC ═══════════ --%>
    <div class="col-md-6">
        <div class="card rounded-4 border-0 shadow-sm h-100">
            <div class="card-body p-4">
                <h6 class="fw-semibold mb-3"><i class="bi bi-prescription2 me-2 text-primary"></i>Đơn Thuốc</h6>
                <c:choose>
                    <c:when test="${empty prescription}">
                        <div class="text-center py-4 text-muted"><i class="bi bi-capsule" style="font-size:2rem;"></i><p class="mt-2 small">Không có đơn thuốc cho lần khám này.</p></div>
                    </c:when>
                    <c:otherwise>
                        <c:if test="${not empty prescription.prescriptionCode}"><small class="text-muted">Mã đơn: <code>${prescription.prescriptionCode}</code></small></c:if>
                        <c:if test="${not empty prescription.items}">
                        <div class="table-responsive mt-2">
                            <table class="table table-sm align-middle mb-0">
                                <thead class="table-light"><tr><th class="small">Thuốc</th><th class="small text-center">SL</th><th class="small">Cách dùng</th></tr></thead>
                                <tbody>
                                    <c:forEach var="item" items="${prescription.items}">
                                        <tr><td class="small fw-medium">${item.medicineName}</td><td class="small text-center">${item.quantity}</td><td class="small text-muted">${not empty item.dosage ? item.dosage : '—'}</td></tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        </c:if>
                        <c:if test="${empty prescription.items}"><p class="text-muted small mt-2">Đơn thuốc chưa có danh sách thuốc.</p></c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<%-- ═══════════ PHIẾU SIÊU ÂM ═══════════ --%>
<c:if test="${not empty usOrders}">
<div class="row g-4 mt-2">
    <div class="col-12">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-header bg-transparent border-0 fw-bold py-3"><i class="bi bi-soundwave text-info me-2"></i>Kết Quả Siêu Âm</div>
            <div class="card-body pt-0">
                <c:forEach var="order" items="${usOrders}" varStatus="loop">
                    <c:set var="imgs" value="${orderImages[order.orderId]}"/>
                    <c:set var="report" value="${orderReports[order.orderId]}"/>
                    <c:set var="annSrc" value="${orderAnnotationSources[order.orderId]}"/>
                    <c:set var="aiImg" value="${orderAiResultImages[order.orderId]}"/>
                    <div class="${!loop.first ? 'border-top pt-3 mt-3' : ''}">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <span class="fw-semibold"><i class="bi bi-clipboard2-pulse me-1 text-info"></i>Lần ${loop.index + 1}</span>
                            <span class="badge bg-success" style="font-size:.7rem;">Đã xác nhận</span>
                            <small class="text-muted ms-auto">${order.createdAtText}</small>
                        </div>

                        <%-- Phiếu kết quả --%>
                        <c:if test="${not empty report}">
                        <div class="rounded-3 p-4 mb-3" style="background:linear-gradient(135deg,#f0f9ff,#e8f4f8);border:1px solid #b8d4f0;">
                            <div class="d-flex align-items-center gap-2 mb-3">
                                <i class="bi bi-file-earmark-medical text-primary"></i>
                                <span class="fw-bold">Phiếu Kết Quả</span>
                                <span class="badge bg-success ms-auto" style="font-size:.7rem;"><i class="bi bi-patch-check-fill me-1"></i>BS. ${report.signedName}</span>
                            </div>
                            <c:if test="${not empty report.imageDescription}"><div class="detail-label">Mô tả</div><p class="small mb-2" style="white-space:pre-wrap;">${report.imageDescription}</p></c:if>
                            <c:if test="${not empty report.professionalFindings}"><div class="detail-label">Nhận xét</div><p class="small mb-2" style="white-space:pre-wrap;">${report.professionalFindings}</p></c:if>
                            <div class="mt-2 pt-2 border-top" style="border-color:rgba(0,0,0,.06)!important;">
                                <div class="detail-label">Kết luận</div>
                                <div class="fw-bold text-success">${report.conclusion}</div>
                            </div>
                        </div>
                        </c:if>

                        <%-- Hình ảnh --%>
                        <c:if test="${not empty imgs}">
                        <div class="detail-label mb-2"><i class="bi bi-image me-1"></i>Hình ảnh (bấm để phóng to)</div>
                        <div class="d-flex flex-wrap gap-2">
                            <c:if test="${annSrc == 'AI' && not empty aiImg}">
                                <a href="javascript:void(0);" onclick="viewLargeImage('${pageContext.request.contextPath}/medical/ai-image?orderId=${order.orderId}&imageId=${imgs[0].id}&type=result')" style="display:block;border-radius:8px;overflow:hidden;border:2px solid #3b82f6;text-decoration:none;">
                                    <img loading="lazy" src="${pageContext.request.contextPath}/medical/ai-image?orderId=${order.orderId}&imageId=${imgs[0].id}&type=result" alt="Ảnh chẩn đoán" style="width:180px;height:140px;object-fit:cover;display:block;" onerror="this.parentElement.style.display='none';">
                                    <div style="background:#3b82f6;color:#fff;font-size:.64rem;padding:3px 6px;text-align:center;">Có đánh dấu</div>
                                </a>
                            </c:if>
                            <c:forEach var="img" items="${imgs}">
                                <a href="javascript:void(0);" onclick="viewLargeImage('${pageContext.request.contextPath}/medical/ultrasound-image?id=${img.id}')" style="display:block;border-radius:8px;overflow:hidden;border:1px solid #dee2e6;text-decoration:none;">
                                    <img loading="lazy" src="${pageContext.request.contextPath}/medical/ultrasound-image?id=${img.id}" alt="Ảnh siêu âm" style="width:180px;height:140px;object-fit:cover;display:block;" onerror="this.parentElement.style.display='none';">
                                </a>
                            </c:forEach>
                        </div>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</div>
</c:if>

<%-- Modal xem ảnh lớn --%>
<div class="modal fade" id="imageViewerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content bg-transparent border-0">
            <div class="modal-body text-center p-0 position-relative">
                <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-3" data-bs-dismiss="modal"></button>
                <img id="modalViewerImage" src="" alt="Zoom" style="max-width:100%;max-height:85vh;object-fit:contain;border-radius:8px;box-shadow:0 5px 15px rgba(0,0,0,.5);">
            </div>
        </div>
    </div>
</div>
<script>
function viewLargeImage(src){document.getElementById('modalViewerImage').src=src;new bootstrap.Modal(document.getElementById('imageViewerModal')).show();}
</script>
</c:if>

<%@ include file="../common/footer.jsp" %>
