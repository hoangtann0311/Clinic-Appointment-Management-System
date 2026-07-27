<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:choose>
  <c:when test="${param.embed == 'true'}">
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </head>
    <body style="background:#f8fafc;padding:15px;">
  </c:when>
  <c:otherwise>
    <%@ include file="../common/header.jsp" %>
  </c:otherwise>
</c:choose>

<%-- Modal phóng to ảnh --%>
<div class="modal fade" id="imageZoomModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content bg-dark border-0 rounded-4">
      <div class="modal-header border-0">
        <span class="text-white small">Ảnh siêu âm</span>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body text-center p-2">
        <img id="zoomModalImage" src="" alt="Phóng to" style="max-width:100%;max-height:80vh;object-fit:contain;border-radius:8px;">
      </div>
    </div>
  </div>
</div>

<style>
  .result-toast { position:fixed;top:76px;right:20px;z-index:1080;min-width:320px;max-width:440px; }
  .clinical-value { white-space:pre-wrap;line-height:1.65; }
  .result-image { width:100%;height:300px;object-fit:contain;background:#0f172a;border-radius:8px; }
  .official-report { border-left:4px solid #2563eb;background:#f8fafc; }
</style>

<c:if test="${param.embed != 'true'}">
<div class="admin-page-header d-flex justify-content-between align-items-start gap-3 mb-4">
  <div><h1 class="admin-page-title mb-1">Kết quả cận lâm sàng</h1>
    <div class="admin-page-subtitle">Bệnh nhân: <strong><c:out value="${recordInfo.patientName}" /></strong>
      — Ngày khám: <c:out value="${recordInfo.appointmentDate}" /> — Hồ sơ #${recordId}</div></div>
  <c:choose>
    <c:when test="${not empty recordInfo.appointmentId}">
      <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${recordInfo.appointmentId}" class="btn btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i>Quay lại hồ sơ</a>
    </c:when>
    <c:otherwise>
      <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i>Quay lại danh sách hồ sơ</a>
    </c:otherwise>
  </c:choose>
</div>
</c:if>

<c:if test="${param.success == 'signed'}">
  <div class="alert alert-success alert-dismissible fade show" data-cams-toast role="alert">
    <i class="bi bi-check-circle-fill me-2"></i>Phiếu kết quả đã được Bác sĩ siêu âm ký. Kết quả sẵn sàng cho Bác sĩ lâm sàng.
    <button class="btn-close" data-bs-dismiss="alert"></button>
  </div>
</c:if>

<c:if test="${not reviewSchemaSupported}"><div class="alert alert-warning">Chưa áp dụng migration V13. Chức năng xem phiếu đã ký và xác nhận kết quả đang bị khóa an toàn.</div></c:if>

<c:choose>
  <c:when test="${empty ultrasoundResults}"><div class="admin-card p-5 text-center text-muted"><i class="bi bi-soundwave fs-1"></i><p class="mt-3 mb-0">Hồ sơ chưa có chỉ định siêu âm.</p></div></c:when>
  <c:otherwise><div class="d-grid gap-4">
    <c:forEach var="r" items="${ultrasoundResults}" varStatus="loop">
      <c:set var="orderStatus" value="${fn:toLowerCase(r.order_status)}" />
      <article class="admin-card" id="us-order-${r.order_id}">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
          <div><h5 class="mb-1"><c:out value="${r.service_name}" /> #${loop.index + 1}</h5><div class="small text-muted">Chỉ định lúc <c:out value="${r.ordered_at}" /></div></div>
          <c:choose>
            <c:when test="${orderStatus == 'completed' || orderStatus == 'confirmed'}">
              <span class="badge bg-success"><i class="bi bi-patch-check-fill me-1"></i>Hoàn thành</span>
            </c:when>
            <c:otherwise><span class="badge bg-secondary"><c:out value="${r.order_status}" /></span></c:otherwise>
          </c:choose>
        </div>
        <div class="card-body p-4">
          <div class="row g-3 mb-4">
            <%-- 1. Ảnh siêu âm gốc --%>
            <div class="col-md-6">
              <div class="small fw-semibold mb-2"><i class="bi bi-image me-1"></i>1. Ảnh siêu âm gốc</div>
              <c:choose>
                <c:when test="${not empty r.raw_image_id}">
                  <img loading="lazy" class="result-image" src="${pageContext.request.contextPath}/medical/ultrasound-image?id=${r.raw_image_id}" alt="Ảnh siêu âm gốc"
                       style="cursor:pointer" onclick="zoomImage(this.src)" title="Bấm để phóng to trên màn hình">
                </c:when>
                <c:otherwise><div class="border rounded p-5 text-center text-muted">Chưa có ảnh gốc</div></c:otherwise>
              </c:choose>
            </div>

            <%-- 2. Kết quả siêu âm chính thức được Bác sĩ siêu âm duyệt --%>
            <div class="col-md-6">
              <c:choose>
                <c:when test="${r.review_status == 'Rejected'}">
                  <div class="small fw-semibold mb-2"><i class="bi bi-pencil-square text-primary me-1"></i>2. Kết quả khoanh vùng thủ công (BS Siêu Âm vẽ)</div>
                  <c:choose>
                    <c:when test="${not empty r.raw_image_id}">
                      <div class="position-relative">
                        <img loading="lazy" id="review-image-${r.order_id}" class="result-image" src="${pageContext.request.contextPath}/medical/ultrasound-image?id=${r.raw_image_id}" alt="Ảnh khoanh vùng thủ công"
                             style="cursor:pointer" onclick="zoomImage(this.src)" title="Bấm để phóng to trên màn hình">
                        <canvas id="review-overlay-${r.order_id}" class="position-absolute" style="inset:0;pointer-events:none"></canvas>
                        <textarea id="review-annotation-${r.order_id}" hidden><c:out value="${r.annotation_data}" /></textarea>
                      </div>
                    </c:when>
                    <c:otherwise><div class="border rounded p-5 text-center text-muted">Chưa có dữ liệu vẽ</div></c:otherwise>
                  </c:choose>
                </c:when>
                <c:otherwise>
                  <div class="small fw-semibold mb-2"><i class="bi bi-cpu text-success me-1"></i>2. Kết quả AI phân tích (BS Siêu Âm chấp nhận)</div>
                  <c:choose>
                    <c:when test="${not empty r.ai_processed_image_url && not empty r.raw_image_id}">
                      <img loading="lazy" class="result-image" src="${pageContext.request.contextPath}/medical/ai-image?orderId=${r.order_id}&amp;imageId=${r.raw_image_id}&amp;type=result" alt="Ảnh AI phân tích đã duyệt"
                           style="cursor:pointer" onclick="zoomImage(this.src)" title="Bấm để phóng to trên màn hình">
                    </c:when>
                    <c:otherwise>
                      <img loading="lazy" class="result-image" src="${pageContext.request.contextPath}/medical/ultrasound-image?id=${r.raw_image_id}" alt="Ảnh siêu âm gốc"
                           style="cursor:pointer" onclick="zoomImage(this.src)" title="Bấm để phóng to trên màn hình">
                    </c:otherwise>
                  </c:choose>
                </c:otherwise>
              </c:choose>
            </div>
          </div>

          <c:if test="${not empty r.ai_suggested_label}"><details class="border rounded p-3 mb-4"><summary class="fw-semibold">Gợi ý AI (chỉ tham khảo)</summary>
            <div class="mt-2 clinical-value"><c:out value="${r.ai_suggested_label}" /></div>
            <c:if test="${not empty r.ai_confidence_score}"><div class="small text-muted mt-2">Độ tin cậy: <c:out value="${r.ai_confidence_score}" />%</div></c:if>
          </details></c:if>

          <c:choose>
            <c:when test="${empty r.report_status}">
              <div class="alert alert-secondary mb-0">Bác sĩ siêu âm chưa ký phiếu kết quả. Chưa thể xác nhận hoặc chốt hồ sơ bệnh án.</div>
            </c:when>
            <c:otherwise>
              <section class="official-report rounded p-4 mb-4">
                <div class="d-flex justify-content-between align-items-start gap-2 mb-3"><div><h6 class="fw-bold mb-1">Phiếu kết quả của Bác sĩ siêu âm</h6>
                  <div class="small text-muted">Ký bởi <strong><c:out value="${r.signed_name}" /></strong> lúc <c:out value="${r.signed_at}" /></div></div>
                  <span class="badge bg-primary-subtle text-primary">Vùng: <c:out value="${r.review_status}" /></span></div>
                <c:if test="${r.review_status == 'Rejected'}"><div class="alert alert-warning py-2 small">Lý do từ chối AI: <c:out value="${r.rejection_reason}" /></div></c:if>
                <div class="mb-3"><div class="small text-muted">Mô tả hình ảnh</div><div class="clinical-value"><c:out value="${r.image_description}" /></div></div>
                <div class="mb-3"><div class="small text-muted">Nhận xét chuyên môn</div><div class="clinical-value"><c:out value="${r.professional_findings}" /></div></div>
                <div><div class="small text-muted">Kết luận siêu âm</div><div class="clinical-value fw-semibold"><c:out value="${r.sonographer_conclusion}" /></div></div>
              </section>

              <%-- Kết quả hoàn thành --%>
              <c:choose>
                <c:when test="${(orderStatus == 'completed' || orderStatus == 'confirmed') && r.report_status == 'Signed'}">
                  <div class="d-flex align-items-center justify-content-between p-3 rounded-3 border border-success bg-success bg-opacity-10">
                    <div>
                      <div class="fw-semibold text-success"><i class="bi bi-patch-check-fill me-1"></i>Kết quả đã hoàn thành</div>
                      <div class="small text-muted mt-1">Bác sĩ siêu âm đã ký duyệt và hoàn tất phiếu kết quả cận lâm sàng.</div>
                    </div>
                  </div>
                </c:when>
                <c:otherwise>
                  <div class="alert alert-secondary mb-0">Bác sĩ siêu âm chưa ký phiếu kết quả.</div>
                </c:otherwise>
              </c:choose>
            </c:otherwise>
          </c:choose>
        </div>
      </article>
    </c:forEach>
  </div></c:otherwise>
</c:choose>

<script>
function zoomImage(src) {
    document.getElementById('zoomModalImage').src = src;
    new bootstrap.Modal(document.getElementById('imageZoomModal')).show();
}
(function(){
  document.querySelectorAll('[data-auto-dismiss="true"]').forEach(el=>setTimeout(()=>bootstrap.Alert.getOrCreateInstance(el).close(),4500));
  document.querySelectorAll('img[id^="review-image-"]').forEach(img=>{
    const id=img.id.substring('review-image-'.length), canvas=document.getElementById('review-overlay-'+id), source=document.getElementById('review-annotation-'+id);
    function render(){
      if(!img.naturalWidth||!canvas)return; const rect=img.getBoundingClientRect(); canvas.width=Math.round(rect.width);canvas.height=Math.round(rect.height);canvas.style.width=rect.width+'px';canvas.style.height=rect.height+'px';
      const imageRatio=img.naturalWidth/img.naturalHeight, boxRatio=rect.width/rect.height;
      const drawWidth=imageRatio>boxRatio?rect.width:rect.height*imageRatio;
      const drawHeight=imageRatio>boxRatio?rect.width/imageRatio:rect.height;
      const offsetX=(rect.width-drawWidth)/2, offsetY=(rect.height-drawHeight)/2;
      let data;try{data=JSON.parse(source.value||'null')}catch(ignore){return}if(!data)return;const ctx=canvas.getContext('2d');ctx.clearRect(0,0,canvas.width,canvas.height);ctx.strokeStyle='#2563eb';ctx.fillStyle='rgba(37,99,235,.16)';ctx.lineWidth=3;
      if(Array.isArray(data.points)&&data.points.length>=3){ctx.beginPath();data.points.forEach((p,i)=>i?ctx.lineTo(offsetX+p.x*drawWidth,offsetY+p.y*drawHeight):ctx.moveTo(offsetX+p.x*drawWidth,offsetY+p.y*drawHeight));ctx.closePath();ctx.fill();ctx.stroke();}
      else if(data.xMin!==undefined){ctx.strokeRect(offsetX+data.xMin*drawWidth,offsetY+data.yMin*drawHeight,(data.xMax-data.xMin)*drawWidth,(data.yMax-data.yMin)*drawHeight);}
    }
    img.addEventListener('load',render);if(img.complete)render();window.addEventListener('resize',render);
  });
  if(location.hash){const el=document.querySelector(location.hash);if(el)setTimeout(()=>el.scrollIntoView({block:'start'}),100);}
})();
</script>

<c:choose>
  <c:when test="${param.embed == 'true'}">
    </body>
    </html>
  </c:when>
  <c:otherwise>
    <%@ include file="../common/footer.jsp" %>
  </c:otherwise>
</c:choose>
