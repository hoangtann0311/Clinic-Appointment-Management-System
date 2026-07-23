<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<style>
    .us-step { flex: 1; min-width: 120px; color: #64748b; }
    .us-step-dot { width: 34px; height: 34px; border-radius: 50%; display: inline-flex; align-items: center;
        justify-content: center; background: #e2e8f0; color: #475569; font-weight: 700; }
    .us-step.is-done .us-step-dot, .us-step.is-current .us-step-dot { background: #2563eb; color: #fff; }
    .us-step.is-current { color: #1d4ed8; font-weight: 700; }
    .us-image-stage { position: relative; min-height: 420px; background: #0f172a; border-radius: 10px;
        overflow: hidden; display: flex; align-items: center; justify-content: center; }
    #imageViewport { position:absolute; inset:0; transform-origin:center center; }
    #imageViewport > img:first-child { width: 100%; height: 420px; object-fit: contain; }
    #aiMaskLayer { position: absolute; inset: 0; width: 100%; height: 420px; object-fit: contain; opacity: .45; }
    #annotationCanvas { position: absolute; z-index: 4; touch-action: none; cursor: crosshair; }
    .review-choice { border: 1px solid #cbd5e1; border-radius: 8px; padding: 12px; cursor: pointer; height: 100%; }
    .review-choice:has(input:checked) { border-color: #2563eb; background: #eff6ff; }
    .us-toast { position: fixed; top: 76px; right: 20px; z-index: 1080; min-width: 320px; max-width: 440px; }
    .readonly-field { white-space: pre-wrap; line-height: 1.6; }
</style>

<c:set var="status" value="${fn:toLowerCase(order.status)}" />
<div class="admin-page-header d-flex justify-content-between align-items-start gap-3 mb-4">
    <div>
        <a href="${pageContext.request.contextPath}/sonographer/waiting-list" class="btn btn-outline-secondary btn-sm mb-3">
            <i class="bi bi-arrow-left me-1"></i>Danh sách chờ
        </a>
        <h1 class="admin-page-title mb-1">Ca siêu âm #SA-${order.orderId}</h1>
        <div class="admin-page-subtitle">Bác sĩ siêu âm thực hiện, duyệt vùng AI và ký phiếu kết quả</div>
    </div>
    <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2">
        <c:out value="${order.status}" />
    </span>
</div>

<c:if test="${not empty param.success}">
    <div class="alert alert-success alert-dismissible fade show shadow-sm us-toast" role="alert" data-auto-dismiss="true">
        <i class="bi bi-check-circle-fill me-2"></i>
        <c:choose>
            <c:when test="${param.success == 'started'}">Đã tiếp nhận ca siêu âm.</c:when>
            <c:when test="${param.success == 'uploaded'}">Đã tải ảnh siêu âm.</c:when>
            <c:when test="${param.success == 'analyzed'}">AI đã phân tích xong. Hãy kiểm tra trước khi ký.</c:when>
            <c:when test="${param.success == 'signed' || param.success == 'completed'}">Đã ký phiếu và chuyển cho Bác sĩ lâm sàng.</c:when>
            <c:otherwise>Thao tác đã hoàn tất.</c:otherwise>
        </c:choose>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${not empty param.error}">
    <div class="alert alert-danger alert-dismissible fade show shadow-sm us-toast" role="alert" data-auto-dismiss="true">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <c:choose>
            <c:when test="${param.error == 'startConflict'}">Ca đã được người khác tiếp nhận hoặc chưa đủ điều kiện xử lý.</c:when>
            <c:when test="${param.error == 'invalidImageMetadata'}">Không đọc được kích thước ảnh. Hãy tải lại ảnh rồi thử lại.</c:when>
            <c:when test="${param.error == 'signFailed'}">Không thể ký: hãy kiểm tra trạng thái duyệt, nội dung phiếu và phiên làm việc.</c:when>
            <c:when test="${param.error == 'aiAlreadyRun'}">Chỉ định này đã gửi AI một lần. Hãy kiểm tra kết quả và hoàn tất phiếu.</c:when>
            <c:when test="${param.error == 'aiUnavailable'}">AI không hoàn tất phân tích. Bác sĩ siêu âm hãy đánh giá thủ công và ghi rõ kết quả chuyên môn.</c:when>
            <c:otherwise>Thao tác chưa hoàn tất. Vui lòng kiểm tra dữ liệu và thử lại.</c:otherwise>
        </c:choose>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<div class="admin-card p-4 mb-4">
    <div class="d-flex flex-wrap text-center gap-2" id="workflowSteps">
        <div class="us-step" data-step="pending"><span class="us-step-dot">1</span><div class="small mt-2">Tiếp nhận</div></div>
        <div class="us-step" data-step="inprogress"><span class="us-step-dot">2</span><div class="small mt-2">Chụp và tải ảnh</div></div>
        <div class="us-step" data-step="uploaded"><span class="us-step-dot">3</span><div class="small mt-2">AI và duyệt ảnh</div></div>
        <div class="us-step" data-step="completed"><span class="us-step-dot">4</span><div class="small mt-2">Đã ký</div></div>
        <div class="us-step" data-step="confirmed"><span class="us-step-dot">5</span><div class="small mt-2">BS lâm sàng xác nhận</div></div>
    </div>
</div>

<div class="row g-4">
    <div class="col-lg-4">
        <div class="admin-card h-100">
            <div class="card-header bg-white py-3"><h5 class="mb-0">Thông tin chỉ định</h5></div>
            <div class="card-body">
                <dl class="row mb-0 small">
                    <dt class="col-5 text-muted mb-3">Sản phụ</dt><dd class="col-7 fw-semibold"><c:out value="${order.patientName}" /></dd>
                    <dt class="col-5 text-muted mb-3">Ngày sinh</dt><dd class="col-7"><c:out value="${order.dateOfBirth}" /></dd>
                    <dt class="col-5 text-muted mb-3">Dịch vụ</dt><dd class="col-7 fw-semibold text-primary"><c:out value="${order.serviceName}" /></dd>
                    <dt class="col-5 text-muted mb-3">Bác sĩ lâm sàng chỉ định</dt><dd class="col-7">BS. <c:out value="${order.doctorName}" /></dd>
                    <dt class="col-5 text-muted mb-3">Triệu chứng</dt><dd class="col-7"><c:out value="${empty order.symptoms ? 'Không ghi nhận' : order.symptoms}" /></dd>
                    <dt class="col-5 text-muted">Ưu tiên</dt><dd class="col-7">
                        <c:choose><c:when test="${order.emergency}"><span class="badge bg-warning text-dark">Ưu tiên</span></c:when>
                        <c:otherwise><span class="badge bg-secondary-subtle text-secondary">Thông thường</span></c:otherwise></c:choose>
                    </dd>
                </dl>
            </div>
        </div>
    </div>
    <div class="col-lg-8">
        <div class="admin-card h-100">
            <div class="card-header bg-white py-3"><h5 class="mb-0">Việc cần làm ở bước hiện tại</h5></div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not ownershipSupported}">
                        <div class="alert alert-warning mb-0">Cần áp dụng migration V12 trước khi phân công người phụ trách.</div>
                    </c:when>
                    <c:when test="${status == 'pending' || status == 'waiting' || status == 'ordered'}">
                        <p>Kiểm tra đúng bệnh nhân và chỉ định, sau đó tiếp nhận ca để bắt đầu chụp siêu âm.</p>
                        <form method="post" action="${pageContext.request.contextPath}/sonographer/detail">
                            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="orderId" value="${order.orderId}">
                            <input type="hidden" name="action" value="start">
                            <button class="btn btn-primary"><i class="bi bi-play-fill me-1"></i>Tiếp nhận ca</button>
                        </form>
                    </c:when>
                    <c:when test="${status == 'inprogress' || status == 'uploaded'}">
                        <p class="mb-3">Mỗi chỉ định sử dụng một ảnh siêu âm gốc để AI và Bác sĩ siêu âm cùng đối chiếu.</p>
                        <c:if test="${not empty images}">
                            <div class="mb-3">
                                <img loading="lazy" src="${pageContext.request.contextPath}/medical/ultrasound-image?id=${selectedImage.id}" alt="Ảnh siêu âm gốc"
                                     class="img-fluid rounded border w-100" style="height:180px;object-fit:contain;background:#0f172a">
                                <div class="small text-truncate mt-1"><c:out value="${selectedImage.originalFilename}" /></div>
                            </div>
                        </c:if>
                        <c:if test="${status == 'inprogress' && empty images}">
                            <form method="post" action="${pageContext.request.contextPath}/sonographer/upload" enctype="multipart/form-data">
                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="orderId" value="${order.orderId}">
                                <div class="input-group"><input type="file" class="form-control" name="file" accept="image/jpeg,image/png" required>
                                    <button class="btn btn-primary"><i class="bi bi-cloud-arrow-up me-1"></i>Tải ảnh gốc</button></div>
                                <div class="form-text">Chỉ một ảnh JPG/PNG, tối đa 10 MB. Hãy kiểm tra đúng bệnh nhân trước khi tải.</div>
                            </form>
                        </c:if>
                        <c:if test="${status == 'uploaded' && empty aiResult}"><hr>
                            <form method="post" action="${pageContext.request.contextPath}/sonographer/analyze" id="aiAnalyzeForm">
                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="orderId" value="${order.orderId}">
                                <button class="btn btn-outline-primary" id="analyzeButton"><i class="bi bi-cpu me-1"></i>
                                    Gửi ảnh cho AI phân tích</button>
                                <span class="small text-muted ms-2">Mỗi chỉ định chỉ gửi AI một lần; AI không tự tạo kết luận chính thức.</span>
                            </form>
                        </c:if>
                    </c:when>
                    <c:when test="${status == 'completed'}">
                        <div class="alert alert-info mb-0"><strong>Đã ký phiếu.</strong> Đang chờ Bác sĩ lâm sàng xem và xác nhận.</div>
                    </c:when>
                    <c:when test="${status == 'confirmed'}">
                        <div class="alert alert-success mb-0"><strong>Đã hoàn tất.</strong> Bác sĩ lâm sàng đã xác nhận kết quả.</div>
                    </c:when>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<c:if test="${status == 'uploaded' && not empty selectedImage}">
<section id="review-workspace" class="admin-card mt-4">
    <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
        <div><h5 class="mb-1">Duyệt ảnh và lập phiếu kết quả</h5><div class="small text-muted">Ba bước: xem ảnh → duyệt vùng → nhập phiếu và ký</div></div>
        <c:if test="${not empty aiResult}"><span class="badge ${aiResult.status == 'Success' ? 'bg-success' : aiResult.status == 'Failed' ? 'bg-danger' : 'bg-warning text-dark'}">
            AI: ${aiResult.status == 'Success' ? 'Đã phân tích' : aiResult.status == 'Failed' ? 'Không hoàn tất' : 'Đang phân tích'}</span></c:if>
    </div>
    <div class="card-body p-4">
        <c:if test="${not reviewSchemaSupported}">
            <div class="alert alert-warning mb-0">Cơ sở dữ liệu chưa sẵn sàng cho chức năng lưu vùng phân tích và ký phiếu kết quả. Vui lòng liên hệ quản trị viên.</div>
        </c:if>
        <c:if test="${reviewSchemaSupported}">
            <c:choose>
                <c:when test="${empty aiResult}"><div class="alert alert-info mb-0">Hãy gửi ảnh cho AI phân tích trước khi duyệt.</div></c:when>
                <c:when test="${aiResult.status == 'Analyzing'}"><div class="alert alert-info mb-0">AI đang phân tích. Vui lòng chờ kết quả.</div></c:when>
                <c:otherwise>
                <form method="post" action="${pageContext.request.contextPath}/sonographer/detail?orderId=${order.orderId}" id="reviewForm">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="orderId" value="${order.orderId}">
                    <input type="hidden" name="action" id="formActionInput">
                    <input type="hidden" name="imageId" value="${selectedImage.id}">
                    <input type="hidden" name="imageWidth" id="imageWidth"><input type="hidden" name="imageHeight" id="imageHeight">
                    <input type="hidden" name="annotationData" id="annotationData">

                    <div class="alert alert-warning py-2 small">Kết quả AI chỉ mang tính hỗ trợ, không thay thế kết luận chuyên môn.</div>

                    <h6 class="fw-bold mb-3"><span class="badge bg-primary me-2">1</span>Đối chiếu ảnh gốc, ảnh AI và vùng đánh dấu thủ công</h6>
                    <div class="row g-3 mb-4">
                        <div class="col-lg-8">
                            <div class="us-image-stage" id="imageStage"><div id="imageViewport">
                                <img id="rawUltrasoundImage" src="${pageContext.request.contextPath}/medical/ultrasound-image?id=${selectedImage.id}" alt="Ảnh siêu âm gốc">
                                <c:if test="${not empty aiResult.maskImage}"><img id="aiMaskLayer" src="${pageContext.request.contextPath}/medical/ai-image?orderId=${order.orderId}&amp;imageId=${selectedImage.id}&amp;type=mask" alt="Lớp vùng AI"></c:if>
                                <canvas id="annotationCanvas"></canvas>
                            </div></div>
                        </div>
                        <div class="col-lg-4">
                            <div class="border rounded p-3 mb-3">
                                <div class="small text-muted">Nhận định AI — chỉ tham khảo</div>
                                <div class="fw-semibold mt-1"><c:out value="${empty aiResult.message ? 'Không có nhận định' : aiResult.message}" /></div>
                                <c:if test="${not empty aiResult.confidence}"><div class="small mt-2">Độ tin cậy: <strong><c:out value="${aiResult.confidence}" />%</strong></div></c:if>
                            </div>
                            <div class="d-flex flex-wrap gap-2 mb-2">
                                <button type="button" class="btn btn-sm btn-outline-primary image-view-button" data-image-view="raw">Xem ảnh gốc</button>
                                <button type="button" class="btn btn-sm btn-outline-primary image-view-button" data-image-view="ai">Xem vùng AI</button>
                                <button type="button" class="btn btn-sm btn-outline-primary image-view-button" data-image-view="review">Xem vùng Bác sĩ siêu âm</button>
                            </div>
                            <div class="d-flex flex-wrap gap-2 mb-2">
                                <button type="button" class="btn btn-sm btn-outline-secondary" id="zoomInButton">Phóng to</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary" id="zoomOutButton">Thu nhỏ</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary" id="panButton">Kéo ảnh</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary" id="resetViewButton">Đặt lại vị trí</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary" id="undoButton">Hoàn tác</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary" id="redoButton">Làm lại</button>
                                <button type="button" class="btn btn-sm btn-outline-secondary" id="resetAiButton">Đặt lại theo AI</button>
                                <button type="button" class="btn btn-sm btn-outline-danger" id="clearButton">Xóa vùng vẽ</button>
                            </div>
                            <div class="small text-muted">Chọn “Hiệu chỉnh”, sau đó bấm lên ảnh để tạo đa giác; kéo một điểm để chỉnh vị trí.</div>
                        </div>
                    </div>

                    <h6 class="fw-bold mb-3"><span class="badge bg-primary me-2">2</span>Duyệt vùng phân tích</h6>
                    <div class="row g-3 mb-3">
                        <div class="col-md-4"><label class="review-choice d-block"><input type="radio" name="reviewStatus" value="Accepted"
                            ${currentAnnotation.reviewStatus == 'Accepted' ? 'checked' : ''} ${aiResult.status != 'Success' ? 'disabled' : ''}>
                            <strong class="ms-1">Chấp nhận AI</strong><div class="small text-muted mt-1">Vùng và nhận định AI phù hợp.</div></label></div>
                        <div class="col-md-4"><label class="review-choice d-block"><input type="radio" name="reviewStatus" value="Corrected"
                            ${currentAnnotation.reviewStatus == 'Corrected' ? 'checked' : ''}>
                            <strong class="ms-1">Hiệu chỉnh vùng</strong><div class="small text-muted mt-1">Vẽ đa giác chuyên môn thay thế.</div></label></div>
                        <div class="col-md-4"><label class="review-choice d-block"><input type="radio" name="reviewStatus" value="Rejected"
                            ${currentAnnotation.reviewStatus == 'Rejected' ? 'checked' : ''}>
                            <strong class="ms-1">Từ chối gợi ý</strong><div class="small text-muted mt-1">Nêu lý do; có thể vẽ vùng thủ công.</div></label></div>
                    </div>
                    <div class="mb-4" id="rejectionReasonGroup">
                        <label class="form-label">Lý do từ chối <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="rejectionReason" rows="2" maxlength="500"><c:out value="${currentAnnotation.rejectionReason}" /></textarea>
                    </div>

                    <h6 class="fw-bold mb-3"><span class="badge bg-primary me-2">3</span>Phiếu kết quả chuyên môn</h6>
                    <div class="border rounded-3 p-3 mb-3 bg-light">
                        <div class="fw-semibold mb-1">Mẫu mô tả có cấu trúc</div>
                        <div class="small text-muted mb-3">Không có lựa chọn mặc định. Bác sĩ chủ động chọn rồi chèn; nội dung sau khi chèn vẫn phải được kiểm tra và sửa.</div>
                        <div class="row g-2">
                            <div class="col-md-4"><label class="form-label small">Vị trí</label><select id="findingPosition" class="form-select form-select-sm">
                                <option value="">-- Chưa chọn --</option><option>Thành trước</option><option>Thành sau</option><option>Thành bên</option>
                                <option>Đáy tử cung</option><option>Cổ tử cung</option><option>Không xác định</option><option>Khác</option>
                            </select></div>
                            <div class="col-md-2"><label class="form-label small">Số lượng</label><input id="findingCount" type="number" class="form-control form-control-sm" min="1" max="99" placeholder="Nhập số"></div>
                            <div class="col-md-3"><label class="form-label small">Kích thước</label><input id="findingSize" type="text" class="form-control form-control-sm" maxlength="100" placeholder="Ví dụ: 12 × 8 mm"></div>
                            <div class="col-md-3"><label class="form-label small">Hình dạng</label><select id="findingShape" class="form-select form-select-sm">
                                <option value="">-- Chưa chọn --</option><option>Tròn</option><option>Bầu dục</option><option>Không đều</option><option>Khác</option>
                            </select></div>
                            <div class="col-md-3"><label class="form-label small">Bờ</label><select id="findingBorder" class="form-select form-select-sm">
                                <option value="">-- Chưa chọn --</option><option>Rõ</option><option>Không rõ</option><option>Khác</option>
                            </select></div>
                            <div class="col-md-3"><label class="form-label small">Độ hồi âm</label><input id="findingEcho" type="text" class="form-control form-control-sm" maxlength="100" placeholder="Bác sĩ mô tả"></div>
                            <div class="col-md-3"><label class="form-label small">Tưới máu</label><input id="findingPerfusion" type="text" class="form-control form-control-sm" maxlength="100" placeholder="Bác sĩ mô tả"></div>
                            <div class="col-md-3"><label class="form-label small">Mô xung quanh</label><input id="findingSurrounding" type="text" class="form-control form-control-sm" maxlength="150" placeholder="Bác sĩ mô tả"></div>
                            <div class="col-12"><label class="form-label small">Ghi chú khác</label><input id="findingNotes" type="text" class="form-control form-control-sm" maxlength="300" placeholder="Nội dung Khác hoặc ghi chú bổ sung"></div>
                            <div class="col-12 text-end"><button type="button" id="insertStructuredFinding" class="btn btn-sm btn-outline-primary">Chèn vào mô tả hình ảnh</button></div>
                        </div>
                    </div>
                    <div class="mb-3"><label class="form-label">Mô tả hình ảnh <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="imageDescription" rows="3" maxlength="8000"><c:out value="${currentReport.imageDescription}" /></textarea></div>
                    <div class="mb-3"><label class="form-label">Nhận xét chuyên môn <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="professionalFindings" rows="4" maxlength="8000"><c:out value="${currentReport.professionalFindings}" /></textarea></div>
                    <div class="input-group input-group-sm mb-2">
                        <select id="conclusionTemplate" class="form-select" aria-label="Chọn mẫu kết luận">
                            <option value="">-- Chọn mẫu để chèn, không có mặc định --</option>
                            <option>Chưa ghi nhận bất thường rõ trên hình ảnh hiện tại.</option>
                            <option>Ghi nhận vùng tổn thương cần bác sĩ đánh giá kết hợp lâm sàng.</option>
                            <option>Hình ảnh gợi ý tổn thương dạng u xơ.</option>
                            <option>Theo dõi và đối chiếu với lần kiểm tra trước.</option>
                            <option>Chất lượng hình ảnh chưa đủ để kết luận.</option>
                            <option>Đề nghị thực hiện lại hoặc bổ sung hình ảnh.</option>
                            <option>Khác</option>
                        </select>
                        <button type="button" id="insertConclusionTemplate" class="btn btn-outline-secondary">Chèn</button>
                    </div>
                    <div class="mb-3"><label class="form-label">Kết luận siêu âm <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="conclusion" rows="3" maxlength="8000"><c:out value="${currentReport.conclusion}" /></textarea></div>
                    <div class="alert alert-light border small">Người ký: <strong><c:out value="${sessionScope.user.fullName}" /></strong>. Sau khi ký, phiếu chuyển sang chờ Bác sĩ lâm sàng xác nhận và không thể sửa trực tiếp.</div>
                    <div class="d-flex justify-content-end gap-2">
                        <button type="submit" class="btn btn-primary" id="signButton"><i class="bi bi-pen me-1"></i>Ký và chuyển Bác sĩ lâm sàng</button>
                    </div>
                </form>
                <textarea id="existingAnnotationData" hidden><c:out value="${currentAnnotation.annotationData}" /></textarea>
                </c:otherwise>
            </c:choose>
        </c:if>
    </div>
</section>
</c:if>

<c:if test="${status == 'completed' || status == 'confirmed'}">
<section id="review-workspace" class="admin-card mt-4">
    <div class="card-header bg-white py-3"><h5 class="mb-0">Phiếu kết quả siêu âm đã ký</h5></div>
    <div class="card-body p-4">
        <c:choose><c:when test="${empty currentReport}"><div class="alert alert-warning mb-0">Không tìm thấy phiếu kết quả hiện hành. Cần kiểm tra migration và dữ liệu.</div></c:when>
        <c:otherwise>
            <div class="row g-4">
                <div class="col-md-4"><div class="text-muted small">Trạng thái duyệt vùng</div><div class="fw-semibold"><c:out value="${currentAnnotation.reviewStatus}" /></div></div>
                <div class="col-md-4"><div class="text-muted small">Bác sĩ siêu âm ký</div><div class="fw-semibold"><c:out value="${currentReport.signedName}" /></div></div>
                <div class="col-md-4"><div class="text-muted small">Thời điểm ký</div><div class="fw-semibold"><c:out value="${currentReport.signedAt}" /></div></div>
                <div class="col-12"><div class="text-muted small">Mô tả hình ảnh</div><div class="readonly-field"><c:out value="${currentReport.imageDescription}" /></div></div>
                <div class="col-12"><div class="text-muted small">Nhận xét chuyên môn</div><div class="readonly-field"><c:out value="${currentReport.professionalFindings}" /></div></div>
                <div class="col-12"><div class="text-muted small">Kết luận</div><div class="readonly-field fw-semibold"><c:out value="${currentReport.conclusion}" /></div></div>
                <c:if test="${status == 'confirmed'}"><div class="col-12"><div class="alert alert-success mb-0">Bác sĩ lâm sàng đã xác nhận lúc <c:out value="${currentReport.doctorConfirmedAt}" />.</div></div></c:if>
            </div>
        </c:otherwise></c:choose>
    </div>
</section>
</c:if>

<script>
(function () {
    const states = ['pending', 'inprogress', 'uploaded', 'completed', 'confirmed'];
    let state = '${status}';
    if (state === 'waiting' || state === 'ordered') state = 'pending';
    const current = Math.max(0, states.indexOf(state));
    document.querySelectorAll('#workflowSteps .us-step').forEach((el, index) => {
        if (index < current) el.classList.add('is-done');
        if (index === current) el.classList.add('is-current');
    });
    document.querySelectorAll('[data-auto-dismiss="true"]').forEach(el => {
        window.setTimeout(() => bootstrap.Alert.getOrCreateInstance(el).close(), 4500);
    });

    const aiForm = document.getElementById('aiAnalyzeForm');
    if (aiForm) aiForm.addEventListener('submit', () => {
        const button = document.getElementById('analyzeButton');
        button.disabled = true; button.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang phân tích...';
    });

    const form = document.getElementById('reviewForm');
    const raw = document.getElementById('rawUltrasoundImage');
    const canvas = document.getElementById('annotationCanvas');
    if (!form || !raw || !canvas) return;
    const ctx = canvas.getContext('2d');
    const dataField = document.getElementById('annotationData');
    const widthField = document.getElementById('imageWidth');
    const heightField = document.getElementById('imageHeight');
    const mask = document.getElementById('aiMaskLayer');
    const aiBox = {
        x1: ${not empty aiResult.xmin ? aiResult.xmin : 'null'}, y1: ${not empty aiResult.ymin ? aiResult.ymin : 'null'},
        x2: ${not empty aiResult.xmax ? aiResult.xmax : 'null'}, y2: ${not empty aiResult.ymax ? aiResult.ymax : 'null'}
    };
    const viewport = document.getElementById('imageViewport');
    let points = [], undoStack = [], redoStack = [], dragIndex = -1, activeView = 'raw';
    let viewScale = 1, viewX = 0, viewY = 0, panMode = false, panStart = null;

    function selectedReview() { const x = form.querySelector('[name="reviewStatus"]:checked'); return x ? x.value : ''; }
    function clone(value) { return value.map(p => ({x:p.x, y:p.y})); }
    function saveHistory() { undoStack.push(clone(points)); if (undoStack.length > 30) undoStack.shift(); redoStack = []; }
    function syncData() { dataField.value = points.length >= 3 ? JSON.stringify({points: points.map(p => ({x:+p.x.toFixed(6), y:+p.y.toFixed(6)}))}) : ''; }
    function align() {
        if (!raw.naturalWidth) return;
        const stage = document.getElementById('imageStage'), sw = stage.clientWidth, sh = stage.clientHeight;
        const ratio = raw.naturalWidth / raw.naturalHeight, stageRatio = sw / sh;
        const w = ratio > stageRatio ? sw : sh * ratio, h = ratio > stageRatio ? sw / ratio : sh;
        canvas.style.left = ((sw - w) / 2) + 'px'; canvas.style.top = ((sh - h) / 2) + 'px';
        canvas.style.width = w + 'px'; canvas.style.height = h + 'px'; canvas.width = Math.round(w); canvas.height = Math.round(h);
        widthField.value = raw.naturalWidth; heightField.value = raw.naturalHeight; draw();
    }
    function draw() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        const showAiLayer = activeView === 'ai' || (activeView === 'review' && selectedReview() === 'Accepted');
        if (mask) mask.style.display = showAiLayer ? 'block' : 'none';
        if (showAiLayer && aiBox.x1 !== null && raw.naturalWidth) {
            ctx.save(); ctx.setLineDash([7,5]); ctx.strokeStyle='#38bdf8'; ctx.lineWidth=2;
            ctx.strokeRect(aiBox.x1/raw.naturalWidth*canvas.width, aiBox.y1/raw.naturalHeight*canvas.height,
                (aiBox.x2-aiBox.x1)/raw.naturalWidth*canvas.width, (aiBox.y2-aiBox.y1)/raw.naturalHeight*canvas.height); ctx.restore();
        }
        if (activeView !== 'review' || !points.length) return;
        ctx.beginPath(); points.forEach((p,i) => { const x=p.x*canvas.width,y=p.y*canvas.height; i?ctx.lineTo(x,y):ctx.moveTo(x,y); });
        if (points.length > 2) ctx.closePath(); ctx.fillStyle='rgba(37,99,235,.18)'; ctx.fill(); ctx.strokeStyle='#2563eb'; ctx.lineWidth=2.5; ctx.stroke();
        points.forEach(p => { ctx.beginPath(); ctx.arc(p.x*canvas.width,p.y*canvas.height,5,0,Math.PI*2); ctx.fillStyle='#fff';ctx.fill();ctx.strokeStyle='#1d4ed8';ctx.stroke(); });
    }
    function position(e) { const r=canvas.getBoundingClientRect(); return {x:Math.max(0,Math.min(1,(e.clientX-r.left)/r.width)),y:Math.max(0,Math.min(1,(e.clientY-r.top)/r.height))}; }
    canvas.addEventListener('pointerdown', e => {
        if (panMode) { panStart={x:e.clientX,y:e.clientY,viewX,viewY}; canvas.setPointerCapture(e.pointerId); return; }
        if (activeView !== 'review') return;
        const review=selectedReview(); if (review !== 'Corrected' && review !== 'Rejected') return;
        const p=position(e), threshold=12/Math.max(canvas.width,1);
        dragIndex=points.findIndex(q => Math.hypot(q.x-p.x,q.y-p.y)<threshold); saveHistory();
        if (dragIndex < 0) { points.push(p); dragIndex=points.length-1; }
        canvas.setPointerCapture(e.pointerId); syncData(); draw();
    });
    canvas.addEventListener('pointermove', e => { if(panStart){viewX=panStart.viewX+e.clientX-panStart.x;viewY=panStart.viewY+e.clientY-panStart.y;applyView();return;} if (dragIndex<0) return; points[dragIndex]=position(e); syncData(); draw(); });
    canvas.addEventListener('pointerup', () => { dragIndex=-1; panStart=null; });
    document.getElementById('undoButton').onclick=()=>{ if(!undoStack.length)return;redoStack.push(clone(points));points=undoStack.pop();syncData();draw(); };
    document.getElementById('redoButton').onclick=()=>{ if(!redoStack.length)return;undoStack.push(clone(points));points=redoStack.pop();syncData();draw(); };
    document.getElementById('clearButton').onclick=()=>{saveHistory();points=[];syncData();draw();};
    document.getElementById('resetAiButton').onclick=()=>{ if(aiBox.x1===null||!raw.naturalWidth)return;saveHistory();points=[
        {x:aiBox.x1/raw.naturalWidth,y:aiBox.y1/raw.naturalHeight},{x:aiBox.x2/raw.naturalWidth,y:aiBox.y1/raw.naturalHeight},
        {x:aiBox.x2/raw.naturalWidth,y:aiBox.y2/raw.naturalHeight},{x:aiBox.x1/raw.naturalWidth,y:aiBox.y2/raw.naturalHeight}];syncData();draw();};
    function setImageView(view) {
        activeView = view;
        document.querySelectorAll('.image-view-button').forEach(button => {
            const active = button.dataset.imageView === view;
            button.classList.toggle('btn-primary', active);
            button.classList.toggle('btn-outline-primary', !active);
            button.setAttribute('aria-pressed', active ? 'true' : 'false');
        });
        draw();
    }
    document.querySelectorAll('.image-view-button').forEach(button => {
        button.addEventListener('click', () => setImageView(button.dataset.imageView));
    });
    function applyView(){viewport.style.transform=`translate(${viewX}px,${viewY}px) scale(${viewScale})`;}
    document.getElementById('zoomInButton').onclick=()=>{viewScale=Math.min(4,viewScale+.25);applyView();};
    document.getElementById('zoomOutButton').onclick=()=>{viewScale=Math.max(.5,viewScale-.25);applyView();};
    document.getElementById('panButton').onclick=e=>{panMode=!panMode;e.currentTarget.classList.toggle('btn-primary',panMode);e.currentTarget.classList.toggle('btn-outline-secondary',!panMode);canvas.style.cursor=panMode?'grab':'crosshair';};
    document.getElementById('resetViewButton').onclick=()=>{viewScale=1;viewX=0;viewY=0;applyView();};
    function updateReviewUi(){const review=selectedReview(),rejected=review==='Rejected';document.getElementById('rejectionReasonGroup').style.display=rejected?'block':'none';if(review)setImageView('review');else draw();}
    form.querySelectorAll('[name="reviewStatus"]').forEach(x=>x.addEventListener('change',updateReviewUi));
    let clickedAction = 'sign';
    const signBtn = document.getElementById('signButton');
    if (signBtn) signBtn.addEventListener('click', () => { clickedAction = 'sign'; });

    function notifyValidation(message) {
        if (window.CAMS?.notify) window.CAMS.notify(message, 'warning');
        else {
            const field = document.createElement('div');
            field.className = 'alert alert-warning mt-2';
            field.textContent = message;
            form.prepend(field);
        }
    }

    document.getElementById('insertStructuredFinding')?.addEventListener('click', () => {
        const values = [
            ['Vị trí', document.getElementById('findingPosition').value],
            ['Số lượng', document.getElementById('findingCount').value],
            ['Kích thước', document.getElementById('findingSize').value.trim()],
            ['Hình dạng', document.getElementById('findingShape').value],
            ['Bờ', document.getElementById('findingBorder').value],
            ['Độ hồi âm', document.getElementById('findingEcho').value.trim()],
            ['Tưới máu', document.getElementById('findingPerfusion').value.trim()],
            ['Mô xung quanh', document.getElementById('findingSurrounding').value.trim()],
            ['Ghi chú', document.getElementById('findingNotes').value.trim()]
        ].filter(item => item[1]);
        const target = form.elements.imageDescription;
        if (!values.length) { notifyValidation('Hãy chọn hoặc nhập ít nhất một đặc điểm trước khi chèn.'); return; }
        const text = values.map(item => item[0] + ': ' + item[1]).join('; ') + '.';
        target.value = target.value.trim() ? target.value.trim() + '\n' + text : text;
        target.focus();
    });
    document.getElementById('insertConclusionTemplate')?.addEventListener('click', () => {
        const template = document.getElementById('conclusionTemplate').value;
        const target = form.elements.conclusion;
        if (!template || template === 'Khác') { target.focus(); return; }
        target.value = target.value.trim() ? target.value.trim() + '\n' + template : template;
        target.focus();
    });

    form.addEventListener('submit', e => {
        const actionInput = document.getElementById('formActionInput');
        if (actionInput) actionInput.value = clickedAction;

        const signing = clickedAction === 'sign', review = selectedReview();
        if (!review) {
            e.preventDefault(); notifyValidation('Bác sĩ siêu âm phải chủ động chọn Chấp nhận, Hiệu chỉnh hoặc Từ chối gợi ý AI.'); return;
        }
        if ((review==='Corrected' && points.length<3) || (review==='Rejected' && form.rejectionReason.value.trim().length<5)) {
            e.preventDefault(); notifyValidation(review==='Corrected'?'Vui lòng tạo vùng đa giác có ít nhất 3 điểm.':'Vui lòng nêu lý do từ chối (ít nhất 5 ký tự).'); return;
        }
        if (signing) {
            const fields=['imageDescription','professionalFindings','conclusion'];
            if(fields.some(n=>form.elements[n].value.trim().length<5) || form.conclusion.value.trim().length<10){e.preventDefault();notifyValidation('Vui lòng nhập đầy đủ mô tả, nhận xét và kết luận trước khi ký.');return;}
            if(!confirm('Xác nhận ký phiếu và chuyển cho Bác sĩ lâm sàng?'))e.preventDefault();
        }
    });
    try { const existing=JSON.parse(document.getElementById('existingAnnotationData').value||'null'); if(existing&&Array.isArray(existing.points))points=existing.points; } catch(ignore) {}
    raw.addEventListener('load', align); if(raw.complete) align(); window.addEventListener('resize',align); setImageView('raw'); updateReviewUi(); syncData();
})();
</script>

<%@ include file="../common/footer.jsp" %>
