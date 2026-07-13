<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="../common/header.jsp" %>

<div class="row mb-4">
  <div class="col-12">
    <div class="card border-0 rounded-4" style="background:linear-gradient(135deg,#dc3545,#c0392b);">
      <div class="card-body p-4 text-white">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
          <div>
            <h2 class="fw-bold mb-1"><i class="bi bi-clipboard2-pulse me-2"></i>Nhập Kết Quả Xét Nghiệm</h2>
            <p class="mb-0 opacity-75">${order.serviceName} — Mã: ${order.serviceCode}</p>
          </div>
          <a href="${pageContext.request.contextPath}/lab/orders" class="btn btn-light btn-sm rounded-pill px-3">
            <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách
          </a>
        </div>
      </div>
    </div>
  </div>
</div>

<c:if test="${not empty error}">
  <div class="alert alert-danger rounded-3 mb-4">
    <i class="bi bi-exclamation-triangle me-2"></i>${error}
  </div>
</c:if>

<div class="row g-4 justify-content-center">
  <div class="col-lg-7">

    <%-- Thông tin chỉ định --%>
    <div class="card border-0 rounded-4 shadow-sm mb-4">
      <div class="card-body p-4">
        <h6 class="fw-bold mb-3"><i class="bi bi-info-circle me-1 text-danger"></i>Thông tin chỉ định</h6>
        <div class="row g-2 small">
          <div class="col-6">
            <span class="text-muted d-block">Xét nghiệm</span>
            <strong>${order.serviceName}</strong>
          </div>
          <div class="col-6">
            <span class="text-muted d-block">Mã dịch vụ</span>
            <strong>${order.serviceCode}</strong>
          </div>
          <div class="col-6">
            <span class="text-muted d-block">Hồ sơ bệnh án #</span>
            <strong>${order.medicalRecordId}</strong>
          </div>
          <div class="col-6">
            <span class="text-muted d-block">Thời gian chỉ định</span>
            <strong>${order.createdAt}</strong>
          </div>
          <c:if test="${order.requiresFasting}">
            <div class="col-12">
              <div class="alert alert-warning py-2 px-3 mb-0 rounded-3 small">
                <i class="bi bi-exclamation-triangle me-1"></i>Bệnh nhân cần nhịn ăn trước xét nghiệm này
              </div>
            </div>
          </c:if>
        </div>
      </div>
    </div>

    <%-- Form nhập kết quả --%>
    <div class="card border-0 rounded-4 shadow-sm">
      <div class="card-body p-4">
        <h6 class="fw-bold mb-3">
          <i class="bi bi-pencil-square me-1 text-danger"></i>
          <c:choose>
            <c:when test="${not empty order.labResult}">Cập nhật kết quả</c:when>
            <c:otherwise>Nhập kết quả</c:otherwise>
          </c:choose>
        </h6>

        <form method="post" action="${pageContext.request.contextPath}/lab/orders">
          <input type="hidden" name="orderId"   value="${order.id}">
          <input type="hidden" name="serviceId" value="${order.serviceId}">

          <div class="mb-3">
            <label class="form-label fw-medium">
              Kết quả xét nghiệm <span class="text-danger">*</span>
            </label>
            <textarea name="resultDetails" class="form-control rounded-3" rows="8"
                      placeholder="Nhập kết quả chi tiết: chỉ số, nhận xét, kết luận…"
                      required>${not empty order.labResult ? order.labResult.resultDetails : ''}</textarea>
            <div class="form-text">Ghi đầy đủ các chỉ số đo được, đơn vị, giá trị tham chiếu bình thường và nhận xét.</div>
          </div>

          <div class="mb-4">
            <label class="form-label fw-medium">URL hình ảnh kết quả (tùy chọn)</label>
            <input type="url" name="imageUrl" class="form-control rounded-3"
                   placeholder="https://..."
                   value="${not empty order.labResult ? order.labResult.imageUrl : ''}">
            <div class="form-text">Link ảnh chụp phiếu xét nghiệm hoặc ảnh máy phân tích.</div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-danger rounded-pill px-4">
              <i class="bi bi-save me-1"></i>
              <c:choose>
                <c:when test="${not empty order.labResult}">Cập nhật kết quả</c:when>
                <c:otherwise>Lưu kết quả</c:otherwise>
              </c:choose>
            </button>
            <a href="${pageContext.request.contextPath}/lab/orders"
               class="btn btn-outline-secondary rounded-pill px-4">Hủy</a>
          </div>
        </form>
      </div>
    </div>

  </div>
</div>

<%@ include file="../common/footer.jsp" %>
