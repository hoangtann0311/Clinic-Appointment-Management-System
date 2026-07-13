<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<div class="row mb-4">
  <div class="col-12">
    <div class="card border-0 rounded-4" style="background:linear-gradient(135deg,#dc3545,#c0392b);">
      <div class="card-body p-4 text-white">
        <h2 class="fw-bold mb-1"><i class="bi bi-droplet-fill me-2"></i>Danh Sách Xét Nghiệm Chờ Xử Lý</h2>
        <p class="mb-0 opacity-75">${fn:length(orders)} chỉ định đang chờ kết quả</p>
      </div>
    </div>
  </div>
</div>

<c:if test="${not empty param.saved}">
  <div class="alert alert-success rounded-3 mb-4">
    <i class="bi bi-check-circle me-2"></i>Đã lưu kết quả xét nghiệm thành công.
  </div>
</c:if>

<div class="card border-0 rounded-4 shadow-sm">
  <div class="card-body p-0">
    <c:choose>
      <c:when test="${empty orders}">
        <div class="text-center py-5 text-muted">
          <i class="bi bi-check2-all fs-1 d-block mb-3 opacity-25"></i>
          <h6>Không có xét nghiệm nào đang chờ xử lý.</h6>
        </div>
      </c:when>
      <c:otherwise>
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th class="px-4 py-3">#</th>
                <th>Bệnh nhân</th>
                <th>Ngày khám</th>
                <th>Xét nghiệm</th>
                <th>Lưu ý</th>
                <th>Chỉ định lúc</th>
                <th class="text-center">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="o" items="${orders}" varStatus="st">
                <tr>
                  <td class="px-4">${st.index + 1}</td>
                  <td><strong>${o.patientName}</strong></td>
                  <td>${o.apptDate}</td>
                  <td>
                    <span class="fw-medium">${o.serviceName}</span><br>
                    <small class="text-muted">${o.serviceCode}</small>
                  </td>
                  <td>
                    <c:if test="${o.requiresFasting}">
                      <span class="badge bg-warning text-dark rounded-pill">Nhịn ăn</span>
                    </c:if>
                  </td>
                  <td><small class="text-muted">${o.createdAt}</small></td>
                  <td class="text-center">
                    <a href="${pageContext.request.contextPath}/lab/orders?id=${o.id}"
                       class="btn btn-sm btn-danger rounded-pill px-3">
                      <i class="bi bi-pencil me-1"></i>Nhập kết quả
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

<%@ include file="../common/footer.jsp" %>
