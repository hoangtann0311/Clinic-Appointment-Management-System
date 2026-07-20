<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Custom CSS for alignment with Brand CAMS ── --%>
<style>
  /* Ghi đè màu chủ đạo Bootstrap sang màu thương hiệu CAMS (Rose/Crimson) */
  #resultTabs .nav-link {
    color: #4b5563;
    background: #f3f4f6;
    border: 1px solid #e5e7eb;
    transition: all 0.2s ease;
  }
  #resultTabs .nav-link.active {
    background: linear-gradient(135deg, #be123c 0%, #881337 100%) !important;
    color: #ffffff !important;
    border-color: transparent !important;
    box-shadow: 0 4px 12px rgba(190, 18, 60, 0.25);
  }
  #resultTabs .nav-link:hover:not(.active) {
    background: #e5e7eb;
    color: #111827;
  }
  .text-brand {
    color: #be123c !important;
  }
  .bg-brand {
    background-color: #be123c !important;
  }
</style>

<%-- ── Banner ──────────────────────────────────────────────────────── --%>
<div class="row mb-4">
  <div class="col-12">
    <div class="card border-0 rounded-4 text-white"
         style="background:linear-gradient(135deg,#be123c,#881337);">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
          <div>
            <h2 class="fw-bold mb-1">
              <i class="bi bi-clipboard2-pulse me-2"></i>Kết Quả Cận Lâm Sàng
            </h2>
            <p class="mb-0 opacity-75">
              Bệnh nhân: <strong>${recordInfo.patientName}</strong>
              <c:if test="${not empty recordInfo.appointmentDate}">
                — Ngày khám: <strong>${recordInfo.appointmentDate}</strong>
              </c:if>
              — Hồ sơ #${recordId}
            </p>
          </div>
          <a href="javascript:history.back()"
             class="btn btn-light btn-sm rounded-pill px-3">
            <i class="bi bi-arrow-left me-1"></i>Quay lại hồ sơ
          </a>
        </div>
      </div>
    </div>
  </div>
</div>

<%-- ── Alerts (success / error) ─────────────────────────────────────── --%>
<c:if test="${not empty param.success}">
  <div class="alert alert-success alert-dismissible fade show rounded-4 mb-4 d-flex align-items-center gap-2" role="alert">
    <i class="bi bi-check-circle-fill fs-5"></i>
    <div>
      <c:choose>
        <c:when test="${param.success == 'confirmed'}">
          <strong>Xác nhận thành công!</strong> Kết quả siêu âm đã được bác sĩ duyệt và chốt kết luận chính thức.
        </c:when>
        <c:otherwise>Thao tác thực hiện thành công!</c:otherwise>
      </c:choose>
    </div>
    <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
</c:if>
<c:if test="${not empty param.error}">
  <div class="alert alert-danger alert-dismissible fade show rounded-4 mb-4 d-flex align-items-center gap-2" role="alert">
    <i class="bi bi-exclamation-triangle-fill fs-5"></i>
    <div>
      <c:choose>
        <c:when test="${param.error == 'confirmFailed'}">
          <strong>Xác nhận thất bại!</strong> Không thể xác nhận kết quả siêu âm. Vui lòng kiểm tra trạng thái đơn hoặc thử lại.
        </c:when>
        <c:when test="${param.error == 'invalidOrder'}">
          <strong>Lỗi!</strong> Không tìm thấy đơn siêu âm cần xác nhận.
        </c:when>
        <c:when test="${param.error == 'incompleteConclusion'}">
          <strong>Cần bổ sung kết luận.</strong> Hãy ghi tối thiểu 20 ký tự, nêu nhận định và hướng dẫn phù hợp để bệnh nhân có thể hiểu.
        </c:when>
        <c:otherwise><strong>Lỗi:</strong> Đã xảy ra sự cố. Vui lòng thử lại.</c:otherwise>
      </c:choose>
    </div>
    <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
</c:if>

<%-- ── Kết quả siêu âm ── --%>
<div class="d-flex align-items-center mb-4">
  <h4 class="fw-bold mb-0 text-dark"><i class="bi bi-soundwave me-2 text-brand"></i>Kết quả siêu âm</h4>
  <span class="badge bg-danger ms-2 rounded-pill">${fn:length(ultrasoundResults)}</span>
</div>

<div id="panel-us">
  <c:choose>
    <c:when test="${empty ultrasoundResults}">
      <div class="card border-0 rounded-4 text-center py-5 text-muted">
        <i class="bi bi-soundwave fs-1 d-block mb-3 opacity-25"></i>
        <h6>Hồ sơ này chưa có kết quả siêu âm.</h6>
      </div>
    </c:when>
    <c:otherwise>
      <div class="row g-4">
        <c:forEach var="r" items="${ultrasoundResults}" varStatus="st">
          <div class="col-12" id="us-order-${r.order_id}">
            <div class="card border-0 rounded-4 shadow-sm">
              <div class="card-body p-4">

                <%-- Card header --%>
                <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                  <div>
                    <h6 class="fw-bold mb-0">
                      <i class="bi bi-soundwave text-brand me-1"></i>
                      ${not empty r.service_name ? r.service_name : 'Kết quả siêu âm'} #${st.index + 1}
                    </h6>
                    <small class="text-muted">Chỉ định lúc: ${r.ordered_at}</small>
                  </div>
                  <div class="d-flex align-items-center gap-2">
                    <c:if test="${not empty r.sonographer_name}">
                      <small class="text-muted"><i class="bi bi-person me-1"></i>KTV: ${r.sonographer_name}</small>
                    </c:if>
                    <%-- Badge trạng thái --%>
                    <c:choose>
                      <c:when test="${r.order_status == 'confirmed'}">
                        <span class="badge rounded-pill bg-brand" style="font-size:.75rem;">
                          <i class="bi bi-check-circle-fill me-1"></i>Bác sĩ đã xác nhận
                        </span>
                      </c:when>
                      <c:when test="${r.order_status == 'Completed'}">
                        <span class="badge bg-warning text-dark rounded-pill" style="font-size:.75rem;">
                          <i class="bi bi-hourglass-split me-1"></i>Chờ bác sĩ duyệt
                        </span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge bg-secondary rounded-pill" style="font-size:.75rem;">
                          <i class="bi bi-clock me-1"></i>${r.order_status}
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>

                <%-- Ảnh gốc + ảnh AI song song --%>
                <div class="row g-3 mb-3">
                  <%-- Ảnh gốc --%>
                  <div class="col-md-6">
                    <p class="fw-medium small mb-2">
                      <i class="bi bi-camera me-1"></i>Ảnh siêu âm gốc
                    </p>
                    <c:choose>
                      <c:when test="${not empty r.raw_image_url}">
                        <c:set var="rawImageUrl" value="${pageContext.request.contextPath}/${r.raw_image_url}" />
                        <a href="${rawImageUrl}" target="_blank" class="d-block">
                          <img src="${rawImageUrl}" alt="Ảnh siêu âm gốc"
                               class="img-fluid rounded-3 border"
                               style="max-height:280px;width:100%;object-fit:contain;background:#000;"
                               onerror="this.classList.add('d-none');document.getElementById('raw-image-missing-${r.order_id}').classList.remove('d-none');">
                        </a>
                        <div id="raw-image-missing-${r.order_id}" class="d-none text-muted small p-3 border rounded-3">
                          <i class="bi bi-exclamation-triangle me-1"></i>
                          Không tìm thấy file ảnh gốc trên máy chủ.
                          <a href="${rawImageUrl}" target="_blank">Mở đường dẫn ảnh</a>
                        </div>
                      </c:when>
                      <c:otherwise>
                        <div class="border rounded-3 d-flex align-items-center justify-content-center text-muted"
                             style="height:160px;background:#f8f9fa;">
                          <span class="small">Chưa có ảnh gốc</span>
                        </div>
                      </c:otherwise>
                    </c:choose>
                  </div>

                  <%-- Ảnh AI phân tích --%>
                  <div class="col-md-6">
                    <p class="fw-medium small mb-2">
                      <i class="bi bi-cpu me-1 text-warning"></i>Ảnh AI phân tích
                      <span class="badge bg-warning text-dark ms-1 rounded-pill" style="font-size:.65rem;">Chỉ tham khảo</span>
                    </p>
                    <c:choose>
                      <c:when test="${not empty r.ai_processed_image_url}">
                        <c:set var="aiImageUrl" value="${pageContext.request.contextPath}/${r.ai_processed_image_url}" />
                        <a href="${aiImageUrl}" target="_blank" class="d-block">
                          <img src="${aiImageUrl}" alt="Ảnh AI phân tích"
                               class="img-fluid rounded-3 border"
                               style="max-height:280px;width:100%;object-fit:contain;background:#000;"
                               onerror="this.classList.add('d-none');document.getElementById('ai-image-missing-${r.order_id}').classList.remove('d-none');">
                        </a>
                        <div id="ai-image-missing-${r.order_id}" class="d-none text-muted small p-3 border rounded-3">
                          <i class="bi bi-exclamation-triangle me-1"></i>
                          Không tìm thấy file ảnh AI trên máy chủ.
                          <a href="${aiImageUrl}" target="_blank">Mở đường dẫn ảnh</a>
                        </div>
                      </c:when>
                      <c:otherwise>
                        <div class="border rounded-3 d-flex align-items-center justify-content-center text-muted"
                             style="height:160px;background:#f8f9fa;">
                          <span class="small">AI chưa phân tích</span>
                        </div>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>

                <%-- ═══════════════════════════════════════════════════════
                     DOCTOR CONFIRMATION SECTION
                     ═══════════════════════════════════════════════════════ --%>

                <c:choose>
                  <%-- ── Đã xác nhận: hiển thị kết luận chính thức ── --%>
                  <c:when test="${r.order_status == 'confirmed'}">
                    <div class="p-3 rounded-3 border" style="background:linear-gradient(135deg,#fff1f2,#ffe4e6);border-color:#fecdd3!important;">
                      <div class="d-flex align-items-center gap-2 mb-2">
                        <span class="d-inline-flex align-items-center justify-content-center rounded-circle bg-brand"
                              style="width:32px;height:32px;">
                          <i class="bi bi-check-lg text-white"></i>
                        </span>
                        <div>
                          <div class="fw-bold text-brand">Kết Luận Siêu Âm Chính Thức</div>
                          <small class="text-muted">Bác sĩ đã xem xét và xác nhận kết quả phân tích AI</small>
                        </div>
                      </div>
                      <c:if test="${not empty r.ai_suggested_label}">
                        <div class="p-3 rounded-3 mb-2" style="background:rgba(255,255,255,0.7);font-size:.9rem;line-height:1.7;">
                          ${r.ai_suggested_label}
                        </div>
                      </c:if>
                      <c:if test="${r.ai_confidence_score != null}">
                        <div class="d-flex align-items-center gap-2">
                          <small class="fw-medium text-brand">Độ tin cậy AI:</small>
                          <div class="progress flex-grow-1" style="height:8px;max-width:180px;">
                            <div class="progress-bar bg-brand" role="progressbar"
                                 style="width:${r.ai_confidence_score}%;"
                                 aria-valuenow="${r.ai_confidence_score}" aria-valuemin="0" aria-valuemax="100"></div>
                          </div>
                          <small class="fw-bold text-brand">${r.ai_confidence_score}%</small>
                        </div>
                      </c:if>
                    </div>
                  </c:when>

                  <%-- ── Completed hoặc Uploaded/Failed (Cho phép bác sĩ chốt kết quả thủ công nếu không chạy AI hoặc AI lỗi) ── --%>
                  <c:when test="${r.order_status == 'Completed' || r.order_status == 'Uploaded' || r.order_status == 'Failed'}">
                    <%-- Đề xuất AI (tham khảo) --%>
                    <c:if test="${not empty r.ai_suggested_label or r.ai_confidence_score != null}">
                      <div class="p-3 rounded-3 mb-3" style="background:#fffbeb;border-left:4px solid #f59e0b;">
                        <div class="fw-medium small text-warning mb-1">
                          <i class="bi bi-robot me-1"></i>Đề xuất của AI (chỉ mang tính tham khảo)
                        </div>
                        <c:if test="${not empty r.ai_suggested_label}">
                          <div class="mb-1 small">${r.ai_suggested_label}</div>
                        </c:if>
                        <c:if test="${r.ai_confidence_score != null}">
                          <div class="d-flex align-items-center gap-2">
                            <strong class="small">Độ tin cậy:</strong>
                            <div class="progress flex-grow-1" style="height:8px;max-width:160px;">
                              <div class="progress-bar bg-warning" role="progressbar"
                                   style="width:${r.ai_confidence_score}%"
                                   aria-valuenow="${r.ai_confidence_score}" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                            <strong class="small">${r.ai_confidence_score}%</strong>
                          </div>
                        </c:if>
                      </div>
                    </c:if>

                    <%-- Form xác nhận của bác sĩ --%>
                    <div class="p-3 rounded-3 border" style="background:linear-gradient(135deg,#fefce8,#fef9c3);border-color:#fde047!important;">
                      <div class="d-flex align-items-center gap-2 mb-3">
                        <span class="d-inline-flex align-items-center justify-content-center rounded-circle"
                              style="width:32px;height:32px;background:#ca8a04;">
                          <i class="bi bi-pencil-square text-white" style="font-size:.8rem;"></i>
                        </span>
                        <div>
                          <div class="fw-bold" style="color:#92400e;">Kết Luận Chuyên Môn Của Bác Sĩ</div>
                          <small class="text-muted">Xem xét gợi ý AI phía trên rồi nhập kết luận và xác nhận</small>
                        </div>
                      </div>
                      <form method="POST" action="${pageContext.request.contextPath}/doctor/results">
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="orderId"  value="${r.order_id}">
                        <input type="hidden" name="recordId" value="${recordId}">
                        <div class="mb-3">
                          <label for="doctorMsg-${r.order_id}" class="form-label fw-medium small" style="color:#92400e;">
                            <i class="bi bi-chat-text me-1"></i>Kết luận chẩn đoán lâm sàng
                          </label>
                          <textarea id="doctorMsg-${r.order_id}" name="doctorMessage" rows="4" required minlength="20" maxlength="2000"
                                    class="form-control" style="font-size:.9rem;resize:vertical;"
                                    placeholder="Ví dụ: Chưa ghi nhận dấu hiệu u xơ trên ảnh hiện tại. Tiếp tục theo dõi thai kỳ và tái khám theo lịch hẹn hoặc sớm hơn khi đau bụng/tăng ra huyết.">${not empty r.ai_suggested_label ? r.ai_suggested_label : ''}</textarea>
                          <div class="form-text" style="color:#a16207;">
                            <i class="bi bi-info-circle me-1"></i>
                            Nội dung này là phiếu trả kết quả cho bệnh nhân. Hãy viết rõ nhận định, hướng dẫn theo dõi và dấu hiệu cần tái khám; AI chỉ là thông tin hỗ trợ nội bộ.
                          </div>
                        </div>
                        <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                          <div class="small" style="color:#92400e;">
                            <i class="bi bi-shield-check me-1"></i>
                            Sau khi xác nhận, trạng thái sẽ chuyển thành <strong>Đã xác nhận</strong> và không thể thay đổi.
                          </div>
                          <button type="submit" class="btn fw-bold px-4"
                                  style="background:linear-gradient(135deg,#be123c,#881337);color:white;border:none;"
                                  onclick="return confirm('Bạn có chắc chắn muốn xác nhận và hoàn tất kết quả siêu âm này không?')">
                            <i class="bi bi-patch-check-fill me-2"></i>Xác Nhận &amp; Hoàn Tất
                          </button>
                        </div>
                      </form>
                    </div>
                  </c:when>

                  <%-- ── Trạng thái khác: đang tiến hành ── --%>
                  <c:otherwise>
                    <div class="p-3 rounded-3 text-muted" style="background:#f8fafc;border-left:4px solid #cbd5e1;">
                      <i class="bi bi-hourglass-split me-2"></i>
                      Đơn siêu âm đang được tiến hành — chưa có kết quả AI để duyệt.
                      <span class="badge bg-secondary ms-2">${r.order_status}</span>
                    </div>
                  </c:otherwise>
                </c:choose>

              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<script>
  // Tự động cuộn đến card kết quả tương ứng nếu có hash trong URL
  (function() {
    const hash = window.location.hash;
    if (hash) {
      const el = document.querySelector(hash);
      if (el) { setTimeout(() => el.scrollIntoView({behavior:'smooth', block:'start'}), 200); }
    }
  })();
</script>

<%@ include file="../common/footer.jsp" %>
