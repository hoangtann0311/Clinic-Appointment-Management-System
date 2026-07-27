<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<style>
  .rx-card { border: none; border-radius: 16px; box-shadow: 0 1px 6px rgba(0,0,0,.07); transition: box-shadow .2s; }
  .rx-card:hover { box-shadow: 0 4px 18px rgba(0,0,0,.12); }
  .rx-badge-issued   { background: #d1fae5; color: #065f46; }
  .rx-badge-dispensed{ background: #dbeafe; color: #1e40af; }
  .rx-badge-other    { background: #f3f4f6; color: #374151; }
  .patient-avatar { width: 38px; height: 38px; border-radius: 50%; background: linear-gradient(135deg,#667eea,#764ba2);
    display: inline-flex; align-items: center; justify-content: center; color: #fff; font-weight: 700; font-size: .9rem; flex-shrink: 0; }
  .search-box { background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 12px; padding: .5rem 1rem; }
  .search-box:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.12); background: #fff; outline: none; }
  .rx-table th { font-size: .78rem; text-transform: uppercase; letter-spacing: .05em; color: #6b7280; background: #f9fafb; font-weight: 600; border-bottom: 2px solid #e5e7eb; }
  .rx-table td { vertical-align: middle; border-color: #f3f4f6; }
  .rx-table tbody tr:hover { background: #f8fafc; }
  .stat-pill { display: inline-flex; align-items: center; gap: 6px; background: #fff; border: 1px solid #e5e7eb;
    border-radius: 20px; padding: 4px 14px; font-size: .82rem; color: #374151; }
  .stat-pill .num { font-weight: 700; color: #6366f1; }

  /* Modal styles */
  .rx-modal-header { background: linear-gradient(135deg,#6366f1,#4f46e5); }
  .rx-info-row { display: flex; gap: 8px; align-items: baseline; padding: 6px 0; border-bottom: 1px dashed #e5e7eb; }
  .rx-info-label { font-size: .78rem; color: #6b7280; min-width: 100px; flex-shrink: 0; }
  .rx-info-value { font-size: .9rem; color: #111827; font-weight: 500; }
  .med-row { display: flex; gap: 12px; align-items: start; padding: 12px 0; border-bottom: 1px solid #f3f4f6; }
  .med-num { width: 26px; height: 26px; border-radius: 50%; background: #e0e7ff; color: #4f46e5;
    font-size: .78rem; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
  .med-name { font-weight: 600; color: #111827; }
  .med-qty  { font-size: .82rem; background: #f0fdf4; color: #166534; border-radius: 20px; padding: 2px 10px; font-weight: 600; }
  .med-dosage { font-size: .82rem; color: #6b7280; margin-top: 2px; }
</style>

<%-- ── Header ──────────────────────────────────────────────────────────── --%>
<div class="admin-page-header d-flex justify-content-between align-items-start gap-3 mb-4">
  <div>
    <h1 class="admin-page-title mb-1"><i class="bi bi-prescription2 me-2 text-primary"></i>Đơn Thuốc Đã Kê</h1>
    <div class="admin-page-subtitle">BS. <strong>${doctorName}</strong> — quản lý toàn bộ đơn thuốc đã kê cho bệnh nhân</div>
  </div>
  <a href="${pageContext.request.contextPath}/doctor/dashboard" class="btn btn-outline-secondary rounded-3">
    <i class="bi bi-arrow-left me-1"></i>Tổng quan
  </a>
</div>

<%-- ── Thống kê nhanh ─────────────────────────────────────────────────── --%>
<div class="d-flex flex-wrap gap-2 mb-4">
  <span class="stat-pill"><i class="bi bi-prescription2 text-primary"></i>Tổng: <span class="num">${totalRecords}</span> đơn</span>
  <c:if test="${not empty keyword || not empty statusFilter || not empty dateFrom || not empty dateTo}">
    <span class="stat-pill"><i class="bi bi-funnel text-warning"></i>Đang lọc: <span class="num">${fn:length(prescriptions)}</span> kết quả</span>
  </c:if>
</div>

<%-- ── Tìm kiếm & Lọc ─────────────────────────────────────────────────── --%>
<div class="admin-card p-4 mb-4">
  <form method="get" action="${pageContext.request.contextPath}/doctor/prescriptions-list" class="row g-2 align-items-end">
    <div class="col-md-3">
      <label class="form-label small fw-medium text-muted mb-1">Tìm kiếm</label>
      <div class="position-relative">
        <i class="bi bi-search position-absolute text-muted" style="left:14px;top:50%;transform:translateY(-50%);"></i>
        <input type="text" name="keyword" class="form-control ps-5 search-box"
               placeholder="Tên bệnh nhân hoặc mã đơn..."
               value="<c:out value='${keyword}'/>">
      </div>
    </div>
    <div class="col-md-2">
      <label class="form-label small fw-medium text-muted mb-1">Trạng thái</label>
      <select name="status" class="form-select form-select-sm rounded-3">
        <option value="">Tất cả</option>
        <option value="issued" ${statusFilter=='issued'?'selected':''}>Đã kê</option>
        <option value="dispensed" ${statusFilter=='dispensed'?'selected':''}>Đã cấp</option>
      </select>
    </div>
    <div class="col-md-2">
      <label class="form-label small fw-medium text-muted mb-1">Từ ngày</label>
      <input type="date" name="dateFrom" class="form-control form-control-sm rounded-3" value="${dateFrom}">
    </div>
    <div class="col-md-2">
      <label class="form-label small fw-medium text-muted mb-1">Đến ngày</label>
      <input type="date" name="dateTo" class="form-control form-control-sm rounded-3" value="${dateTo}">
    </div>
    <div class="col-md-3 d-flex gap-2">
      <button type="submit" class="btn btn-primary rounded-3 px-4">
        <i class="bi bi-search me-1"></i>Tìm kiếm
      </button>
      <c:if test="${not empty keyword || not empty statusFilter || not empty dateFrom || not empty dateTo}">
        <a href="${pageContext.request.contextPath}/doctor/prescriptions-list" class="btn btn-outline-secondary rounded-3">
          <i class="bi bi-x-lg me-1"></i>Xóa bộ lọc
        </a>
      </c:if>
    </div>
  </form>
</div>

<%-- ── Danh sách đơn thuốc ─────────────────────────────────────────────── --%>
<div class="admin-card">
  <c:choose>
    <c:when test="${empty prescriptions}">
      <div class="text-center py-5 text-muted">
        <i class="bi bi-prescription2 fs-1 d-block mb-3 opacity-25"></i>
        <c:choose>
          <c:when test="${not empty keyword || not empty statusFilter || not empty dateFrom || not empty dateTo}">
            Không tìm thấy đơn thuốc nào với bộ lọc hiện tại.
          </c:when>
          <c:otherwise>Chưa có đơn thuốc nào được kê.</c:otherwise>
        </c:choose>
      </div>
    </c:when>
    <c:otherwise>
      <div class="table-responsive">
        <table class="table rx-table mb-0">
          <thead>
            <tr>
              <th class="ps-4" style="width:130px">Mã đơn</th>
              <th>Bệnh nhân</th>
              <th style="width:130px">Ngày khám</th>
              <th>Chẩn đoán</th>
              <th class="text-center" style="width:100px">Số thuốc</th>
              <th class="text-center" style="width:110px">Trạng thái</th>
              <th class="text-center pe-4" style="width:140px">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="rx" items="${prescriptions}">
              <tr>
                <td class="ps-4">
                  <span class="font-monospace small fw-bold text-primary">${rx.code}</span><br>
                  <span class="text-muted" style="font-size:.75rem">${fn:substring(rx.createdAt,0,10)}</span>
                </td>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <span class="patient-avatar">${fn:substring(rx.patientName,0,1)}</span>
                    <div>
                      <div class="fw-semibold text-dark" style="font-size:.9rem"><c:out value="${rx.patientName}"/></div>
                      <div class="text-muted" style="font-size:.75rem">Lịch khám #${rx.appointmentId}</div>
                    </div>
                  </div>
                </td>
                <td>
                  <span class="badge bg-light text-dark border" style="font-size:.78rem">
                    <i class="bi bi-calendar me-1"></i>${rx.appointmentDate}
                  </span>
                </td>
                <td class="small text-secondary">
                  <c:choose>
                    <c:when test="${not empty rx.finalDiagnosis}">
                      ${fn:substring(rx.finalDiagnosis,0,55)}<c:if test="${fn:length(rx.finalDiagnosis) > 55}">…</c:if>
                    </c:when>
                    <c:otherwise><span class="text-muted">—</span></c:otherwise>
                  </c:choose>
                </td>
                <td class="text-center">
                  <span class="badge rounded-pill bg-primary-subtle text-primary fw-semibold px-3">${rx.itemCount} thuốc</span>
                </td>
                <td class="text-center">
                  <c:choose>
                    <c:when test="${rx.status == 'issued'}">
                      <span class="badge rx-badge-issued rounded-pill px-3">Đã kê</span>
                    </c:when>
                    <c:when test="${rx.status == 'dispensed'}">
                      <span class="badge rx-badge-dispensed rounded-pill px-3">Đã cấp</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge rx-badge-other rounded-pill px-3"><c:out value="${rx.status}"/></span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="text-center pe-4">
                  <button type="button" class="btn btn-sm btn-outline-primary rounded-3 px-3"
                          onclick="openRxDetail(${rx.id},'${fn:escapeXml(rx.code)}','${fn:escapeXml(rx.patientName)}','${rx.appointmentDate}','${fn:escapeXml(rx.finalDiagnosis)}','${rx.createdAt}')">
                    <i class="bi bi-eye me-1"></i>Chi tiết
                  </button>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>

      <%-- Phân trang --%>
      <div class="p-3 border-top d-flex align-items-center justify-content-between flex-wrap gap-2 bg-light rounded-bottom-3">
        <div class="text-muted small">
          Hiển thị <strong>${fn:length(prescriptions)}</strong> / <strong>${totalRecords}</strong> đơn thuốc
        </div>
        <c:if test="${totalPages > 1}">
          <nav>
            <ul class="pagination pagination-sm mb-0">
              <c:set var="qp" value=""/>
              <c:if test="${not empty keyword}"><c:set var="qp" value="${qp}&keyword=${fn:escapeXml(keyword)}"/></c:if>
              <c:if test="${not empty statusFilter}"><c:set var="qp" value="${qp}&status=${fn:escapeXml(statusFilter)}"/></c:if>
              <c:if test="${not empty dateFrom}"><c:set var="qp" value="${qp}&dateFrom=${fn:escapeXml(dateFrom)}"/></c:if>
              <c:if test="${not empty dateTo}"><c:set var="qp" value="${qp}&dateTo=${fn:escapeXml(dateTo)}"/></c:if>
              <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                <a class="page-link" href="?page=${currentPage - 1}${qp}"><i class="bi bi-chevron-left"></i></a>
              </li>
              <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${i == currentPage ? 'active' : ''}">
                  <a class="page-link" href="?page=${i}${qp}">${i}</a>
                </li>
              </c:forEach>
              <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                <a class="page-link" href="?page=${currentPage + 1}${qp}"><i class="bi bi-chevron-right"></i></a>
              </li>
            </ul>
          </nav>
        </c:if>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%-- ── Modal chi tiết đơn thuốc ───────────────────────────────────────── --%>
<div class="modal fade" id="rxDetailModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
    <div class="modal-content border-0 rounded-4 shadow-lg overflow-hidden">

      <%-- Header --%>
      <div class="modal-header rx-modal-header border-0 py-4 px-4">
        <div>
          <div class="text-white opacity-75 small mb-1"><i class="bi bi-prescription2 me-1"></i>Đơn Thuốc</div>
          <h5 class="modal-title fw-bold text-white mb-0">
            <span id="rxModalCode" class="font-monospace"></span>
          </h5>
        </div>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>

      <%-- Body --%>
      <div class="modal-body p-4">
        <%-- Thông tin bệnh nhân --%>
        <div class="p-3 rounded-3 bg-light border mb-4">
          <div class="rx-info-row">
            <span class="rx-info-label"><i class="bi bi-person me-1"></i>Bệnh nhân</span>
            <span class="rx-info-value" id="rxModalPatient"></span>
          </div>
          <div class="rx-info-row">
            <span class="rx-info-label"><i class="bi bi-calendar me-1"></i>Ngày khám</span>
            <span class="rx-info-value" id="rxModalDate"></span>
          </div>
          <div class="rx-info-row">
            <span class="rx-info-label"><i class="bi bi-clock me-1"></i>Ngày kê</span>
            <span class="rx-info-value" id="rxModalCreated"></span>
          </div>
          <div class="rx-info-row border-0" id="rxDiagRow">
            <span class="rx-info-label"><i class="bi bi-clipboard2-pulse me-1"></i>Chẩn đoán</span>
            <span class="rx-info-value text-secondary" id="rxModalDiagnosis"></span>
          </div>
        </div>

        <%-- Danh sách thuốc --%>
        <div class="d-flex align-items-center justify-content-between mb-3">
          <h6 class="fw-bold mb-0"><i class="bi bi-capsule me-1 text-primary"></i>Danh sách thuốc được kê</h6>
          <span class="badge bg-primary-subtle text-primary rounded-pill px-3" id="rxMedCount"></span>
        </div>
        <div id="rxMedList">
          <div class="text-center text-muted py-3">
            <div class="spinner-border spinner-border-sm text-primary me-2"></div>Đang tải...
          </div>
        </div>
      </div>

      <%-- Footer --%>
      <div class="modal-footer border-0 bg-light px-4 py-3">
        <button type="button" class="btn btn-secondary rounded-3 px-4" data-bs-dismiss="modal">
          <i class="bi bi-x-lg me-1"></i>Đóng
        </button>
      </div>
    </div>
  </div>
</div>

<script>
const RX_API = '${pageContext.request.contextPath}/doctor/prescriptions-list';

function openRxDetail(rxId, code, patientName, date, diagnosis, createdAt) {
    document.getElementById('rxModalCode').textContent     = code;
    document.getElementById('rxModalPatient').textContent  = patientName;
    document.getElementById('rxModalDate').textContent     = date;
    document.getElementById('rxModalCreated').textContent  = (createdAt || '').substring(0, 16);
    document.getElementById('rxModalDiagnosis').textContent = diagnosis || '—';
    document.getElementById('rxMedCount').textContent = 'Đang tải...';

    const medList = document.getElementById('rxMedList');
    medList.innerHTML = '<div class="text-center text-muted py-3"><div class="spinner-border spinner-border-sm text-primary me-2"></div>Đang tải dữ liệu...</div>';

    new bootstrap.Modal(document.getElementById('rxDetailModal')).show();

    fetch(RX_API + '?action=detail&id=' + rxId)
        .then(r => r.ok ? r.json() : Promise.reject(r.status))
        .then(items => {
            document.getElementById('rxMedCount').textContent = (items ? items.length : 0) + ' thuốc';
            if (!items || items.length === 0) {
                medList.innerHTML = '<div class="text-center text-muted py-3">Không có thông tin thuốc.</div>';
                return;
            }
            medList.innerHTML = items.map((it, i) =>
              '<div class="med-row">' +
                '<span class="med-num">' + (i + 1) + '</span>' +
                '<div class="flex-grow-1">' +
                  '<div class="d-flex align-items-center justify-content-between gap-2 flex-wrap">' +
                    '<span class="med-name">' + esc(it.medicineName) + '</span>' +
                    '<span class="med-qty">' + it.quantity + ' đơn vị</span>' +
                  '</div>' +
                  '<div class="med-dosage"><i class="bi bi-info-circle me-1"></i>' + (esc(it.dosage) || '—') + '</div>' +
                '</div>' +
              '</div>'
            ).join('');
        })
        .catch(() => {
            medList.innerHTML = '<div class="text-center text-danger py-3"><i class="bi bi-exclamation-triangle me-1"></i>Không thể tải chi tiết đơn thuốc.</div>';
            document.getElementById('rxMedCount').textContent = 'Lỗi';
        });
}

function esc(text) {
    if (!text) return '';
    return text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
</script>

<%@ include file="../common/footer.jsp" %>
