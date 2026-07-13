<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<%-- ── Banner ──────────────────────────────────────────────────────────── --%>
<div class="row mb-4">
  <div class="col-12">
    <div class="card border-0 rounded-4" style="background:linear-gradient(135deg,#dc3545,#c0392b);">
      <div class="card-body p-4 text-white">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
          <div>
            <h2 class="fw-bold mb-1"><i class="bi bi-droplet-fill me-2"></i>Chỉ Định Xét Nghiệm</h2>
            <p class="mb-0 opacity-75">Hồ sơ #${recordId} — ${fn:length(orders)} xét nghiệm đã chỉ định</p>
          </div>
          <a href="javascript:history.back()" class="btn btn-light btn-sm rounded-pill px-3">
            <i class="bi bi-arrow-left me-1"></i>Quay lại hồ sơ
          </a>
        </div>
      </div>
    </div>
  </div>
</div>

<%-- Banner hướng dẫn khi vào từ luồng draft --%>
<c:if test="${not empty param.fromDraft}">
  <div class="alert alert-info rounded-3 mb-4 d-flex align-items-center justify-content-between flex-wrap gap-2">
    <div>
      <i class="bi bi-info-circle me-2"></i>
      <strong>Chỉ định đã được gửi.</strong>
      Chờ KTV xét nghiệm nhập kết quả. Sau khi có đủ kết quả, quay lại hồ sơ để lưu chính thức.
    </div>
    <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${apptId}"
       class="btn btn-info btn-sm rounded-pill px-3 text-white">
      <i class="bi bi-floppy me-1"></i>Quay lại hoàn tất hồ sơ
    </a>
  </div>
</c:if>

<c:if test="${not empty param.saved}">
  <div class="alert alert-success rounded-3 mb-4">
    <i class="bi bi-check-circle me-2"></i>Đã lưu chỉ định xét nghiệm thành công.
  </div>
</c:if>

<div class="row g-4">

  <%-- ── Cột trái: thêm chỉ định mới ─────────────────────────────────── --%>
  <div class="col-lg-4">
    <div class="card border-0 rounded-4 shadow-sm">
      <div class="card-body p-4">
        <h6 class="fw-bold mb-3">
          <i class="bi bi-plus-circle me-1 text-danger"></i>Chỉ định xét nghiệm mới
        </h6>
        <form method="post" action="${pageContext.request.contextPath}/doctor/lab-orders">
          <input type="hidden" name="action"   value="create">
          <input type="hidden" name="recordId" value="${recordId}">

          <div class="mb-3" style="max-height:380px;overflow-y:auto;">
            <c:forEach var="svc" items="${labServices}">
              <div class="form-check mb-2">
                <input class="form-check-input" type="checkbox"
                       name="serviceIds" value="${svc.id}"
                       id="svc_${svc.id}">
                <label class="form-check-label" for="svc_${svc.id}">
                  <span class="fw-medium">${svc.serviceName}</span>
                  <c:if test="${svc.requiresFasting}">
                    <span class="badge bg-warning text-dark rounded-pill ms-1" style="font-size:.65rem;">Nhịn ăn</span>
                  </c:if>
                  <br>
                  <small class="text-muted">
                    ${svc.serviceCode}
                    <c:if test="${svc.price != null}">
                      — <strong class="text-dark">${svc.price}đ</strong>
                    </c:if>
                  </small>
                </label>
              </div>
            </c:forEach>
          </div>

          <button type="submit" class="btn btn-danger rounded-pill w-100">
            <i class="bi bi-send me-1"></i>Gửi chỉ định
          </button>
        </form>
      </div>
    </div>
  </div>

  <%-- ── Cột phải: danh sách đã chỉ định ─────────────────────────────── --%>
  <div class="col-lg-8">
    <h6 class="fw-bold mb-3">
      <i class="bi bi-list-check me-1 text-danger"></i>Danh sách đã chỉ định
    </h6>

    <c:choose>
      <c:when test="${empty orders}">
        <div class="card border-0 rounded-4">
          <div class="card-body text-center py-5 text-muted">
            <i class="bi bi-droplet fs-1 d-block mb-3 opacity-25"></i>
            <h6>Chưa có xét nghiệm nào được chỉ định.</h6>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="o" items="${orders}">
          <div class="card border-0 rounded-4 shadow-sm mb-3">
            <div class="card-body p-4">
              <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-2">
                <div>
                  <h6 class="fw-bold mb-0">${o.serviceName}</h6>
                  <small class="text-muted">${o.serviceCode}</small>
                </div>
                <div class="d-flex align-items-center gap-2">
                  <c:choose>
                    <c:when test="${o.status == 'pending'}">
                      <span class="badge bg-warning text-dark rounded-pill">Chờ kết quả</span>
                    </c:when>
                    <c:when test="${o.status == 'completed'}">
                      <span class="badge bg-success rounded-pill">Đã có kết quả</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-secondary rounded-pill">Đã hủy</span>
                    </c:otherwise>
                  </c:choose>

                  <c:if test="${o.status == 'pending'}">
                    <form method="post" action="${pageContext.request.contextPath}/doctor/lab-orders"
                          style="display:inline;"
                          onsubmit="return confirm('Hủy chỉ định xét nghiệm này?')">
                      <input type="hidden" name="action"   value="cancel">
                      <input type="hidden" name="recordId" value="${recordId}">
                      <input type="hidden" name="orderId"  value="${o.id}">
                      <button type="submit" class="btn btn-sm btn-outline-secondary rounded-pill">
                        <i class="bi bi-x me-1"></i>Hủy
                      </button>
                    </form>
                  </c:if>
                </div>
              </div>

              <c:if test="${o.requiresFasting}">
                <div class="alert alert-warning py-1 px-2 mb-2 small rounded-2">
                  <i class="bi bi-exclamation-triangle me-1"></i>Bệnh nhân cần nhịn ăn trước xét nghiệm
                </div>
              </c:if>

              <%-- Hiển thị kết quả nếu đã có --%>
              <c:if test="${not empty o.labResult}">
                <div class="mt-3 p-3 rounded-3" style="background:#f8f9fa;">
                  <div class="d-flex align-items-center mb-2">
                    <i class="bi bi-clipboard2-check text-success me-2"></i>
                    <strong class="small text-success">Kết quả xét nghiệm</strong>
                    <small class="text-muted ms-2">
                      — ${o.labResult.updatedAt != null ? o.labResult.updatedAt : ''}
                      <c:if test="${not empty o.labResult.labTechnicianName}">
                        (KTV: ${o.labResult.labTechnicianName})
                      </c:if>
                    </small>
                  </div>
                  <div style="white-space:pre-wrap; font-size:.9rem;">${o.labResult.resultDetails}</div>
                  <c:if test="${not empty o.labResult.imageUrl}">
                    <div class="mt-2">
                      <a href="${o.labResult.imageUrl}" target="_blank" class="btn btn-sm btn-outline-secondary rounded-pill">
                        <i class="bi bi-image me-1"></i>Xem hình ảnh
                      </a>
                    </div>
                  </c:if>
                </div>
              </c:if>

              <small class="text-muted d-block mt-2">
                <i class="bi bi-clock me-1"></i>Chỉ định lúc: ${o.createdAt}
              </small>
            </div>
          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </div>

</div>

<%@ include file="../common/footer.jsp" %>
