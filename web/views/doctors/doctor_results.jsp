<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<style>
  .result-toast { position:fixed;top:76px;right:20px;z-index:1080;min-width:320px;max-width:440px; }
  .clinical-value { white-space:pre-wrap;line-height:1.65; }
  .result-image { width:100%;height:300px;object-fit:contain;background:#0f172a;border-radius:8px; }
  .official-report { border-left:4px solid #2563eb;background:#f8fafc; }
</style>

<div class="admin-page-header d-flex justify-content-between align-items-start gap-3 mb-4">
  <div><h1 class="admin-page-title mb-1">Kết quả cận lâm sàng</h1>
    <div class="admin-page-subtitle">Bệnh nhân: <strong><c:out value="${recordInfo.patientName}" /></strong>
      — Ngày khám: <c:out value="${recordInfo.appointmentDate}" /> — Hồ sơ #${recordId}</div></div>
  <a href="javascript:history.back()" class="btn btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i>Quay lại hồ sơ</a>
</div>

<c:if test="${not empty param.success}"><div class="alert alert-success alert-dismissible fade show shadow-sm result-toast" data-auto-dismiss="true">
  <i class="bi bi-check-circle-fill me-2"></i>Đã xác nhận kết quả siêu âm. Bệnh nhân có thể xem phiếu chính thức.
  <button class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
<c:if test="${not empty param.error}"><div class="alert alert-danger alert-dismissible fade show shadow-sm result-toast" data-auto-dismiss="true">
  <i class="bi bi-exclamation-triangle-fill me-2"></i>
  <c:choose><c:when test="${param.error == 'incompleteConclusion'}">Ghi chú xác nhận phải có ít nhất 20 ký tự.</c:when>
    <c:when test="${param.error == 'confirmFailed'}">Chỉ có thể xác nhận phiếu đã được Bác sĩ Siêu âm ký và đang ở trạng thái chờ duyệt.</c:when>
    <c:otherwise>Không thể hoàn tất thao tác. Vui lòng kiểm tra dữ liệu.</c:otherwise></c:choose>
  <button class="btn-close" data-bs-dismiss="alert"></button></div></c:if>

<c:if test="${not reviewSchemaSupported}"><div class="alert alert-warning">Chưa áp dụng migration V13. Chức năng xem phiếu đã ký và xác nhận kết quả đang bị khóa an toàn.</div></c:if>

<c:choose>
  <c:when test="${empty ultrasoundResults}"><div class="admin-card p-5 text-center text-muted"><i class="bi bi-soundwave fs-1"></i><p class="mt-3 mb-0">Hồ sơ chưa có chỉ định siêu âm.</p></div></c:when>
  <c:otherwise><div class="d-grid gap-4">
    <c:forEach var="r" items="${ultrasoundResults}" varStatus="loop">
      <c:set var="orderStatus" value="${fn:toLowerCase(r.order_status)}" />
      <article class="admin-card" id="us-order-${r.order_id}">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
          <div><h5 class="mb-1"><c:out value="${r.service_name}" /> #${loop.index + 1}</h5><div class="small text-muted">Chỉ định lúc <c:out value="${r.ordered_at}" /></div></div>
          <c:choose><c:when test="${orderStatus == 'confirmed'}"><span class="badge bg-success">Đã xác nhận</span></c:when>
            <c:when test="${orderStatus == 'completed'}"><span class="badge bg-warning text-dark">Chờ bác sĩ lâm sàng xác nhận</span></c:when>
            <c:otherwise><span class="badge bg-secondary"><c:out value="${r.order_status}" /></span></c:otherwise></c:choose>
        </div>
        <div class="card-body p-4">
          <div class="row g-3 mb-4">
            <div class="col-xl-4"><div class="small fw-semibold mb-2">1. Ảnh siêu âm gốc</div>
              <c:choose><c:when test="${not empty r.raw_image_id}">
                <img loading="lazy" class="result-image" src="${pageContext.request.contextPath}/medical/ultrasound-image?id=${r.raw_image_id}" alt="Ảnh siêu âm gốc không có lớp khoanh">
              </c:when><c:otherwise><div class="border rounded p-5 text-center text-muted">Chưa có ảnh</div></c:otherwise></c:choose>
            </div>
            <div class="col-xl-4"><div class="small fw-semibold mb-2">2. Vùng AI phân tích <span class="badge bg-secondary-subtle text-secondary">Tham khảo</span></div>
              <c:choose><c:when test="${not empty r.ai_processed_image_url && not empty r.raw_image_id}"><img loading="lazy" class="result-image" src="${pageContext.request.contextPath}/medical/ai-image?orderId=${r.order_id}&amp;imageId=${r.raw_image_id}&amp;type=result" alt="Ảnh AI phân tích đúng ảnh gốc"></c:when>
              <c:otherwise><div class="border rounded p-5 text-center text-muted">AI không tạo vùng hợp lệ cho ảnh này</div></c:otherwise></c:choose>
            </div>
            <div class="col-xl-4"><div class="small fw-semibold mb-2">3. Vùng Bác sĩ Siêu âm xác nhận/chỉnh sửa</div>
              <c:choose><c:when test="${not empty r.raw_image_id}"><div class="position-relative">
                <img loading="lazy" id="review-image-${r.order_id}" class="result-image" src="${pageContext.request.contextPath}/medical/ultrasound-image?id=${r.raw_image_id}" alt="Ảnh có vùng Bác sĩ Siêu âm xác nhận hoặc chỉnh sửa">
                <canvas id="review-overlay-${r.order_id}" class="position-absolute" style="inset:0;pointer-events:none"></canvas>
                <textarea id="review-annotation-${r.order_id}" hidden><c:out value="${r.annotation_data}" /></textarea>
              </div></c:when><c:otherwise><div class="border rounded p-5 text-center text-muted">Chưa có vùng duyệt</div></c:otherwise></c:choose>
            </div>
          </div>

          <c:if test="${not empty r.ai_suggested_label}"><details class="border rounded p-3 mb-4"><summary class="fw-semibold">Gợi ý AI (chỉ tham khảo)</summary>
            <div class="mt-2 clinical-value"><c:out value="${r.ai_suggested_label}" /></div>
            <c:if test="${not empty r.ai_confidence_score}"><div class="small text-muted mt-2">Độ tin cậy: <c:out value="${r.ai_confidence_score}" />%</div></c:if>
          </details></c:if>

          <c:choose>
            <c:when test="${empty r.report_status}">
              <div class="alert alert-secondary mb-0">Bác sĩ Siêu âm chưa ký phiếu kết quả. Chưa thể xác nhận hoặc chốt hồ sơ bệnh án.</div>
            </c:when>
            <c:otherwise>
              <section class="official-report rounded p-4 mb-4">
                <div class="d-flex justify-content-between align-items-start gap-2 mb-3"><div><h6 class="fw-bold mb-1">Phiếu kết quả của Bác sĩ Siêu âm</h6>
                  <div class="small text-muted">Ký bởi <strong><c:out value="${r.signed_name}" /></strong> lúc <c:out value="${r.signed_at}" /></div></div>
                  <span class="badge bg-primary-subtle text-primary">Vùng: <c:out value="${r.review_status}" /></span></div>
                <c:if test="${r.review_status == 'Rejected'}"><div class="alert alert-warning py-2 small">Lý do từ chối AI: <c:out value="${r.rejection_reason}" /></div></c:if>
                <div class="mb-3"><div class="small text-muted">Mô tả hình ảnh</div><div class="clinical-value"><c:out value="${r.image_description}" /></div></div>
                <div class="mb-3"><div class="small text-muted">Nhận xét chuyên môn</div><div class="clinical-value"><c:out value="${r.professional_findings}" /></div></div>
                <div><div class="small text-muted">Kết luận siêu âm</div><div class="clinical-value fw-semibold"><c:out value="${r.sonographer_conclusion}" /></div></div>
              </section>

              <c:choose><c:when test="${orderStatus == 'completed' && r.report_status == 'Signed'}">
                <form method="post" action="${pageContext.request.contextPath}/doctor/results" class="border rounded p-4">
                  <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="orderId" value="${r.order_id}"><input type="hidden" name="recordId" value="${recordId}">
                  <label for="doctor-notes-${r.order_id}" class="form-label fw-semibold">Ghi chú xác nhận của Bác sĩ lâm sàng <span class="text-danger">*</span></label>
                  <textarea id="doctor-notes-${r.order_id}" name="doctorMessage" class="form-control" rows="3" minlength="20" maxlength="2000" required
                    placeholder="Ghi nhận đã đối chiếu kết quả siêu âm với thăm khám lâm sàng và nêu hướng xử trí..."></textarea>
                  <div class="form-text mb-3">Nội dung này không thay thế hoặc sửa kết luận của Bác sĩ Siêu âm.</div>
                  <div class="d-flex justify-content-end"><button class="btn btn-primary" onclick="return confirm('Xác nhận đã xem phiếu siêu âm và cho phép chốt hồ sơ?')">
                    <i class="bi bi-patch-check me-1"></i>Xác nhận kết quả</button></div>
                </form>
              </c:when><c:when test="${orderStatus == 'confirmed'}"><div class="alert alert-success mb-0">
                <strong>Đã xác nhận.</strong><div class="clinical-value mt-1"><c:out value="${r.doctor_review_notes}" /></div>
                <div class="small mt-1">Thời điểm: <c:out value="${r.doctor_confirmed_at}" /></div></div>
              </c:when><c:otherwise><div class="alert alert-secondary mb-0">Phiếu chưa ở trạng thái hợp lệ để xác nhận.</div></c:otherwise></c:choose>
            </c:otherwise>
          </c:choose>
        </div>
      </article>
    </c:forEach>
  </div></c:otherwise>
</c:choose>

<script>
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

<%@ include file="../common/footer.jsp" %>
