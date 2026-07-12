<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Banner ──────────────────────────────────────────────────────── --%>
<div class="row mb-4">
  <div class="col-12">
    <div class="card border-0 rounded-4"
         style="background:linear-gradient(135deg,#0d6efd,#0a58ca);">
      <div class="card-body p-4 text-white">
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

<%-- ── Tabs ─────────────────────────────────────────────────────────── --%>
<ul class="nav nav-pills mb-4 gap-2" id="resultTabs">
  <li class="nav-item">
    <button class="nav-link active rounded-pill px-4 fw-medium"
            onclick="switchTab('lab', this)" type="button">
      <i class="bi bi-droplet me-1"></i>Xét nghiệm
      <span class="badge bg-danger ms-1 rounded-pill">${fn:length(labResults)}</span>
    </button>
  </li>
  <li class="nav-item">
    <button class="nav-link rounded-pill px-4 fw-medium"
            onclick="switchTab('us', this)" type="button">
      <i class="bi bi-soundwave me-1"></i>Siêu âm
      <span class="badge bg-danger ms-1 rounded-pill">${fn:length(ultrasoundResults)}</span>
    </button>
  </li>
</ul>

<%-- ══════════════════════════════════════════════════════════════════
     PANEL: KẾT QUẢ XÉT NGHIỆM
     ══════════════════════════════════════════════════════════════════ --%>
<div id="panel-lab">
  <c:choose>
    <c:when test="${empty labResults}">
      <div class="card border-0 rounded-4 text-center py-5 text-muted">
        <i class="bi bi-droplet fs-1 d-block mb-3 opacity-25"></i>
        <h6>Hồ sơ này chưa có chỉ định xét nghiệm hoặc chưa có kết quả.</h6>
      </div>
    </c:when>
    <c:otherwise>
      <div class="row g-3">
        <c:forEach var="r" items="${labResults}">
          <div class="col-12">
            <div class="card border-0 rounded-4 shadow-sm">
              <div class="card-body p-4">

                <%-- Header --%>
                <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3">
                  <div>
                    <h6 class="fw-bold mb-0">${r.service_name}</h6>
                    <small class="text-muted">${r.service_code}</small>
                  </div>
                  <c:choose>
                    <c:when test="${r.status == 'completed' or r.status == 'Completed'}">
                      <span class="badge bg-success rounded-pill">Đã có kết quả</span>
                    </c:when>
                    <c:when test="${r.status == 'cancelled'}">
                      <span class="badge bg-secondary rounded-pill">Đã hủy</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-warning text-dark rounded-pill">Chờ kết quả</span>
                    </c:otherwise>
                  </c:choose>
                </div>

                <%-- Kết quả --%>
                <c:choose>
                  <c:when test="${not empty r.result_details}">
                    <div class="p-3 rounded-3 mb-3"
                         style="background:#f8f9fa;border-left:4px solid #0d6efd;">
                      <div class="d-flex align-items-center mb-2">
                        <i class="bi bi-clipboard2-check text-primary me-2"></i>
                        <strong class="small text-primary">Kết quả xét nghiệm</strong>
                        <c:if test="${not empty r.tech_name}">
                          <small class="text-muted ms-2">— KTV: ${r.tech_name}</small>
                        </c:if>
                        <c:if test="${not empty r.result_at}">
                          <small class="text-muted ms-2">(${r.result_at})</small>
                        </c:if>
                      </div>
                      <div style="white-space:pre-wrap;font-size:.9rem;line-height:1.6;">
                          ${r.result_details}
                      </div>
                    </div>
                    <%-- Ảnh kèm theo nếu có --%>
                    <c:if test="${not empty r.image_url}">
                      <div class="mb-2">
                        <a href="${r.image_url}" target="_blank"
                           class="btn btn-sm btn-outline-secondary rounded-pill">
                          <i class="bi bi-image me-1"></i>Xem hình ảnh kết quả
                        </a>
                      </div>
                    </c:if>
                  </c:when>
                  <c:otherwise>
                    <div class="text-muted small fst-italic">
                      <i class="bi bi-hourglass-split me-1"></i>Chưa có kết quả — đang chờ KTV xét nghiệm.
                    </div>
                  </c:otherwise>
                </c:choose>

                <small class="text-muted d-block mt-2">
                  <i class="bi bi-clock me-1"></i>Chỉ định lúc: ${r.ordered_at}
                </small>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%-- ══════════════════════════════════════════════════════════════════
     PANEL: KẾT QUẢ SIÊU ÂM
     ══════════════════════════════════════════════════════════════════ --%>
<div id="panel-us" class="d-none">
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
          <div class="col-12">
            <div class="card border-0 rounded-4 shadow-sm">
              <div class="card-body p-4">

                <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                  <h6 class="fw-bold mb-0">
                    <i class="bi bi-soundwave text-primary me-1"></i>
                    ${not empty r.service_name ? r.service_name : 'Kết quả siêu âm'} #${st.index + 1}
                  </h6>
                  <c:if test="${not empty r.sonographer_name}">
                    <small class="text-muted">KTV: ${r.sonographer_name}</small>
                  </c:if>
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
                        <a href="${r.raw_image_url}" target="_blank">
                          <img src="${r.raw_image_url}" alt="Anh sieu am goc"
                               class="img-fluid rounded-3 border"
                               style="max-height:280px;width:100%;object-fit:contain;background:#000;"
                               onerror="this.style.display='none';this.nextElementSibling.style.display='block'">
                          <div class="d-none text-muted small p-3 border rounded-3">
                            <i class="bi bi-image me-1"></i>
                            <a href="${r.raw_image_url}" target="_blank">Mở ảnh gốc</a>
                          </div>
                        </a>
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
                      <span class="badge bg-warning text-dark ms-1 rounded-pill" style="font-size:.65rem;">
                        Chỉ tham khảo
                      </span>
                    </p>
                    <c:choose>
                      <c:when test="${not empty r.ai_processed_image_url}">
                        <a href="${r.ai_processed_image_url}" target="_blank">
                          <img src="${r.ai_processed_image_url}" alt="Anh AI"
                               class="img-fluid rounded-3 border"
                               style="max-height:280px;width:100%;object-fit:contain;background:#000;"
                               onerror="this.style.display='none';this.nextElementSibling.style.display='block'">
                          <div class="d-none text-muted small p-3 border rounded-3">
                            <i class="bi bi-image me-1"></i>
                            <a href="${r.ai_processed_image_url}" target="_blank">Mở ảnh AI</a>
                          </div>
                        </a>
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

                <%-- Kết quả AI --%>
                <c:if test="${not empty r.ai_suggested_label or r.ai_confidence_score != null}">
                  <div class="p-3 rounded-3" style="background:#fffbeb;border-left:4px solid #f59e0b;">
                    <div class="fw-medium small text-warning mb-1">
                      <i class="bi bi-robot me-1"></i>Đề xuất AI (chỉ mang tính tham khảo)
                    </div>
                    <c:if test="${not empty r.ai_suggested_label}">
                      <div class="mb-1">
                        <strong>Nhận định:</strong> ${r.ai_suggested_label}
                      </div>
                    </c:if>
                    <c:if test="${r.ai_confidence_score != null}">
                      <div class="d-flex align-items-center gap-2">
                        <strong>Độ tin cậy:</strong>
                        <div class="progress flex-grow-1" style="height:10px;max-width:200px;">
                          <div class="progress-bar bg-warning" role="progressbar"
                               style="width:${r.ai_confidence_score}%"
                               aria-valuenow="${r.ai_confidence_score}"
                               aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                        <strong>${r.ai_confidence_score}%</strong>
                      </div>
                    </c:if>
                    <div class="small text-muted mt-2">
                      <i class="bi bi-exclamation-circle me-1"></i>
                      Kết quả AI chỉ hỗ trợ tham khảo. Bác sĩ chịu trách nhiệm kết luận cuối cùng.
                    </div>
                  </div>
                </c:if>

              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<script>
  function switchTab(tab, btn) {
    document.getElementById('panel-lab').classList.toggle('d-none', tab !== 'lab');
    document.getElementById('panel-us').classList.toggle('d-none',  tab !== 'us');
    document.querySelectorAll('#resultTabs .nav-link')
            .forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
  }
</script>

<%@ include file="../common/footer.jsp" %>
