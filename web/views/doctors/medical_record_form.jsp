<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<style>
/* ── Tab styling ──────────────────────────────────────────── */
.obs-nav .nav-link          { color:#6c757d; border-radius:10px 10px 0 0; font-weight:600; padding:.7rem 1.4rem; font-size:.92rem; }
.obs-nav .nav-link.active   { color:#0d6efd; background:#fff; border-bottom:3px solid #0d6efd; }
.obs-nav .nav-link:hover:not(.active) { background:#f8f9fa; }

/* ── Section card ──────────────────────────────────────────── */
.section-label { font-size:.75rem; font-weight:700; letter-spacing:.08em; text-transform:uppercase; color:#6c757d; margin-bottom:.75rem; }
.field-unit    { font-size:.8rem; color:#6c757d; font-weight:normal; }
.req-star      { color:#dc3545; font-weight:bold; margin-left:2px; }

/* ── Risk box & badges ─────────────────────────────────────── */
.risk-box { border:2px solid #f8d7da; background:#fff5f5; border-radius:14px; padding:1.25rem; }
.risk-box.active { border-color:#dc3545; background:#fff0f0; box-shadow:0 4px 12px rgba(220,53,69,.15); }

/* ── Sticky Action Bar ─────────────────────────────────────── */
.doctor-action-bar {
  position: sticky; bottom: 0; z-index: 1020;
  background: #ffffff; border-top: 1px solid #e9ecef;
  box-shadow: 0 -4px 16px rgba(0,0,0,.08); padding: .9rem 1.5rem;
  border-bottom-left-radius: 1rem; border-bottom-right-radius: 1rem;
}

/* ── Info panel ─────────────────────────────────────────────── */
.info-item { display:flex; flex-direction:column; margin-bottom:.75rem; }
.info-item .label { font-size:.7rem; text-transform:uppercase; color:#adb5bd; font-weight:600; letter-spacing:.05em; }
.info-item .value { font-size:.95rem; font-weight:500; color:#212529; }

/* ── Bảng kê thuốc ──────────────────────────────────────────── */
.rx-table th { font-size:.78rem; text-transform:uppercase; letter-spacing:.05em; color:#6c757d; }
.rx-table td { vertical-align:middle; }
</style>

<%-- ══════════════════════════════════════════════════════
     DANH SÁCH HỒ SƠ
     ══════════════════════════════════════════════════════ --%>
<c:if test="${mode == 'list'}">

  <div class="row mb-4">
    <div class="col">
      <div class="card border-0 rounded-4 text-white" style="background:linear-gradient(135deg,#1a6b3c,#28a745);">
        <div class="card-body p-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
          <div>
            <h2 class="fw-bold mb-1"><i class="bi bi-journal-medical me-2"></i>Hồ Sơ Bệnh Án</h2>
            <p class="mb-0 opacity-75">BS. ${doctorName} — Phụ Sản Khoa</p>
          </div>
          <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-light btn-sm rounded-pill px-3">
            <i class="bi bi-arrow-left me-1"></i>Lịch hẹn
          </a>
        </div>
      </div>
    </div>
  </div>

  <%-- Tìm kiếm --%>
  <div class="card rounded-4 border-0 shadow-sm mb-4">
    <div class="card-body p-3">
      <form method="get" action="${pageContext.request.contextPath}/doctor/medical-records" class="d-flex gap-2">
        <input type="text" name="keyword" value="${keyword}" class="form-control rounded-pill"
               placeholder="Tìm theo tên bệnh nhân hoặc chẩn đoán…" style="max-width:360px;">
        <button class="btn btn-primary rounded-pill px-4"><i class="bi bi-search me-1"></i>Tìm</button>
        <c:if test="${not empty keyword}">
          <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-outline-secondary rounded-pill">Xoá lọc</a>
        </c:if>
      </form>
    </div>
  </div>

  <div class="card rounded-4 border-0 shadow-sm">
    <div class="card-header bg-transparent border-0 p-4 pb-2 d-flex align-items-center gap-2">
      <i class="bi bi-list-ul text-success"></i>
      <h6 class="fw-semibold mb-0">Danh sách hồ sơ</h6>
      <span class="badge bg-success rounded-pill ms-1">${fn:length(records)}</span>
    </div>
    <div class="card-body p-0">
      <c:choose>
        <c:when test="${empty records}">
          <div class="text-center py-5">
            <i class="bi bi-journal-x text-muted" style="font-size:3rem;"></i>
            <p class="text-muted mt-3">Chưa có hồ sơ bệnh án nào.</p>
            <a href="${pageContext.request.contextPath}/doctor/appointments"
               class="btn btn-outline-success rounded-pill px-4">
              <i class="bi bi-calendar-check me-1"></i>Xem lịch hẹn để tạo bệnh án
            </a>
          </div>
        </c:when>
        <c:otherwise>
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th class="ps-4">#</th>
                  <th>Bệnh nhân</th>
                  <th>Ngày khám</th>
                  <th>Tuổi thai</th>
                  <th>Nhịp tim thai</th>
                  <th>Chẩn đoán</th>
                  <th>Nguy cơ</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="rec" items="${records}" varStatus="s">
                  <tr>
                    <td class="ps-4 text-muted small">${s.index+1}</td>
                    <td>
                      <div class="d-flex align-items-center gap-2">
                        <div class="rounded-circle bg-success bg-opacity-10 text-success fw-bold d-flex align-items-center justify-content-center"
                             style="width:36px;height:36px;min-width:36px;font-size:.85rem;">
                          ${fn:toUpperCase(fn:substring(rec.patientName,0,1))}
                        </div>
                        <span class="fw-medium">${rec.patientName}</span>
                      </div>
                    </td>
                    <td class="text-nowrap">${rec.appointmentDate}</td>
                    <td>${rec.gestationalAgeDisplay}</td>
                    <td>
                      <c:if test="${rec.fetalHeartRate != null}">
                        <span class="badge bg-light text-dark border">
                          <i class="bi bi-heart-pulse me-1 text-danger"></i>${rec.fetalHeartRate} bpm
                        </span>
                      </c:if>
                      <c:if test="${rec.fetalHeartRate == null}">—</c:if>
                    </td>
                    <td style="max-width:200px;">
                      <span class="text-truncate d-block" title="${rec.finalDiagnosis}">
                        ${not empty rec.finalDiagnosis ? rec.finalDiagnosis : '—'}
                      </span>
                    </td>
                    <td>
                      <c:if test="${rec.hasRisk()}">
                        <span class="badge bg-danger"><i class="bi bi-exclamation-triangle me-1"></i>Nguy cơ</span>
                      </c:if>
                      <c:if test="${!rec.hasRisk()}">
                        <span class="badge bg-success bg-opacity-10 text-success">Bình thường</span>
                      </c:if>
                    </td>
                    <td>
                      <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${rec.appointmentId}"
                         class="btn btn-sm btn-outline-success rounded-pill">
                        <i class="bi bi-pencil me-1"></i>Xem/Sửa
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

</c:if>

<%-- ══════════════════════════════════════════════════════
     FORM TẠO / SỬA HỒ SƠ (4 TAB)
     ══════════════════════════════════════════════════════ --%>
<c:if test="${mode == 'form'}">

  <%-- Thông báo lỗi / Thành công --%>
  <c:if test="${not empty errorMessage}">
    <div class="alert alert-danger rounded-3 mb-3"><i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}</div>
  </c:if>
  <c:if test="${param.saved == '1'}">
    <div class="alert alert-success rounded-3 mb-3 d-flex align-items-center gap-2">
      <i class="bi bi-check-circle-fill fs-5"></i><span>Hồ sơ bệnh án đã được lưu thành công!</span>
    </div>
  </c:if>

  <%-- Thông báo trạng thái Draft xuất hiện DUY NHẤT 1 LẦN tại đây --%>
  <c:if test="${record.id > 0 and record.status == 'draft'}">
    <div class="alert alert-warning rounded-3 mb-3 d-flex align-items-center gap-2">
      <i class="bi bi-hourglass-split fs-5"></i>
      <div>
        <strong>Hồ sơ chưa hoàn tất (Draft).</strong>
        Vui lòng kiểm tra kết quả cận lâm sàng, cập nhật chẩn đoán và bấm <strong>Chốt hồ sơ &amp; hoàn thành khám</strong> để kết thúc ca.
      </div>
    </div>
  </c:if>

  <c:if test="${param.success == 'requested'}">
    <div class="alert alert-success rounded-3 mb-3 d-flex align-items-center gap-2" role="alert">
      <i class="bi bi-check-circle-fill fs-5"></i>
      <c:choose>
        <c:when test="${param.billing == 'additional'}">
          <span><strong>Đã tạo chỉ định siêu âm bổ sung.</strong> Đã phát sinh hóa đơn sau khám; KTV sẽ thực hiện sau khi xác nhận thanh toán.</span>
        </c:when>
        <c:otherwise>
          <span><strong>Đã tạo chỉ định siêu âm.</strong> Dịch vụ đã nằm trong lịch hẹn (không phát sinh chi phí).</span>
        </c:otherwise>
      </c:choose>
      <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Đóng"></button>
    </div>
  </c:if>

  <c:if test="${param.reorderConflict == '1'}">
    <div class="alert alert-warning rounded-3 mb-3" role="alert">
      <div class="d-flex gap-2 align-items-start">
        <i class="bi bi-exclamation-triangle-fill fs-5"></i>
        <div class="flex-grow-1">
          <strong>Đã có chỉ định siêu âm đang xử lý cho ${param.conflictServiceName}.</strong>
          <div class="small mb-2">Nếu cần chỉ định lại, vui lòng nhập lý do lâm sàng:</div>
          <form method="post" action="${pageContext.request.contextPath}/doctor/ultrasound-request/create" class="row g-2 align-items-end">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"/>
            <input type="hidden" name="apptId" value="${param.apptId}">
            <input type="hidden" name="serviceId" value="${param.conflictServiceId}">
            <input type="hidden" name="force" value="1">
            <div class="col-md-9">
              <label class="form-label small mb-1" for="reorderReason">Lý do chỉ định lại <span class="req-star">*</span></label>
              <input id="reorderReason" class="form-control" name="reorderReason" required maxlength="1000"
                     placeholder="Ví dụ: Đánh giá lại do triệu chứng biến động">
            </div>
            <div class="col-md-3 d-grid">
              <button type="submit" class="btn btn-warning"><i class="bi bi-arrow-repeat me-1"></i>Chỉ định lại</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </c:if>

  <%-- Hero Banner --%>
  <div class="card border-0 rounded-4 text-white mb-4" style="background:linear-gradient(135deg,#0d6efd,#0a58ca);">
    <div class="card-body p-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
      <div>
        <h3 class="fw-bold mb-1">
          <i class="bi bi-journal-plus me-2"></i>
          <c:choose>
            <c:when test="${record.id > 0}">Hồ Sơ Khám Lâm Sàng #${record.id}</c:when>
            <c:otherwise>Tạo Hồ Sơ Bệnh Án Mới</c:otherwise>
          </c:choose>
        </h3>
        <p class="mb-0 opacity-75">Bác sĩ lâm sàng: ${doctorName} — Chuyên khoa Phụ Sản</p>
      </div>
      <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-light btn-sm rounded-pill px-3">
          <i class="bi bi-list me-1"></i>Danh sách hồ sơ
        </a>
        <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-outline-light btn-sm rounded-pill px-3">
          <i class="bi bi-arrow-left me-1"></i>Danh sách lịch hẹn
        </a>
      </div>
    </div>
  </div>

  <div class="row g-4">

    <%-- ════ CỘT TRÁI: THÔNG TIN BỆNH NHÂN & CHỈ ĐỊNH SIÊU ÂM ════ --%>
    <div class="col-lg-3">
      <div class="card rounded-4 border-0 shadow-sm mb-4">
        <div class="card-body p-4">
                              <div class="text-center mb-3">
            <div class="rounded-circle bg-success bg-opacity-10 text-success fw-bold d-flex align-items-center justify-content-center mx-auto mb-2"
                 style="width:56px;height:56px;font-size:1.3rem;">
              ${fn:toUpperCase(fn:substring(record.patientName,0,1))}
            </div>
            <h6 class="fw-bold mb-1">${record.patientName}</h6>
            <span class="badge bg-secondary-subtle text-secondary small px-2 py-1">Mã BN: #P-${record.patientId > 0 ? record.patientId : 'N/A'}</span>
          </div>
          <hr class="my-3 opacity-50">

          <div class="d-flex flex-column gap-2 mb-3">
            <div class="d-flex justify-content-between align-items-center py-1 border-bottom border-light">
              <span class="text-muted small fw-medium">Số điện thoại</span>
              <span class="fw-semibold text-dark small">${not empty patientPhone ? patientPhone : '—'}</span>
            </div>
            <div class="d-flex justify-content-between align-items-center py-1 border-bottom border-light">
              <span class="text-muted small fw-medium">Ngày sinh</span>
              <span class="fw-semibold text-dark small">${not empty patientDob ? patientDob : '—'}</span>
            </div>
            <div class="d-flex justify-content-between align-items-center py-1 border-bottom border-light">
              <span class="text-muted small fw-medium">Ngày khám</span>
              <span class="fw-semibold text-dark small"><i class="bi bi-calendar3 me-1 text-success"></i>${record.appointmentDate}</span>
            </div>
            <div class="d-flex justify-content-between align-items-center py-1 border-bottom border-light">
              <span class="text-muted small fw-medium">Giờ khám</span>
              <span class="fw-semibold text-dark small"><i class="bi bi-clock me-1 text-success"></i><c:out value="${not empty record.timeSlot ? record.timeSlot : '—'}"/></span>
            </div>
            <div class="d-flex justify-content-between align-items-center py-1 border-bottom border-light">
              <span class="text-muted small fw-medium">Kinh cuối (LMP)</span>
              <span class="fw-semibold text-dark small" id="lmpDisplay"><c:out value="${not empty record.lastMenstrualPeriod ? record.lastMenstrualPeriod : '—'}"/></span>
            </div>
            <div class="py-1 border-bottom border-light">
              <span class="text-muted small fw-medium d-block mb-1">Triệu chứng lúc đặt lịch</span>
              <div class="p-2 bg-light rounded text-dark small" style="white-space:pre-wrap; line-height: 1.4; text-align: left;">
                <c:out value="${not empty record.symptoms ? record.symptoms : '(không ghi nhận)'}"/>
              </div>
            </div>
            <c:if test="${record.id > 0}">
              <div class="d-flex justify-content-between align-items-center py-1">
                <span class="text-muted small fw-medium">Ngày tạo hồ sơ</span>
                <span class="text-muted small">
                  <c:choose>
                    <c:when test="${not empty record.createdAt}">
                      ${fn:substring(record.createdAt, 8, 10)}/${fn:substring(record.createdAt, 5, 7)}/${fn:substring(record.createdAt, 0, 4)} ${fn:substring(record.createdAt, 11, 16)}
                    </c:when>
                    <c:otherwise>—</c:otherwise>
                  </c:choose>
                </span>
              </div>
            </c:if>
          </div>

          <%-- Khối Chỉ định / Xem kết quả siêu âm --%>
          <hr class="my-3">
          <div class="d-grid gap-2">
            <c:choose>
              <c:when test="${canEditRecord}">
                <form action="${pageContext.request.contextPath}/doctor/ultrasound-request/create" method="POST" id="ultrasoundRequestForm">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"/>
                    <input type="hidden" name="apptId" value="${apptId}">
                    <label class="form-label small fw-bold mb-1"><i class="bi bi-soundwave me-1 text-primary"></i>CHỈ ĐỊNH SIÊU ÂM</label>
                    <select name="serviceId" class="form-select form-select-sm mb-2" required aria-label="Chọn dịch vụ siêu âm">
                        <option value="">-- Chọn dịch vụ siêu âm --</option>
                        <c:if test="${not empty bookedUltrasoundServices}">
                          <optgroup label="Dịch vụ trong lịch hẹn (không phát sinh phí)">
                            <c:forEach var="u" items="${bookedUltrasoundServices}">
                              <option value="${u.id}">${u.serviceName}</option>
                            </c:forEach>
                          </optgroup>
                        </c:if>
                        <c:if test="${not empty additionalUltrasoundServices}">
                          <optgroup label="Chỉ định bổ sung (phát sinh phí)">
                            <c:forEach var="u" items="${additionalUltrasoundServices}">
                              <option value="${u.id}">${u.serviceName} (<fmt:formatNumber value="${u.price}" pattern="#,###"/>đ)</option>
                            </c:forEach>
                          </optgroup>
                        </c:if>
                    </select>
                    <div class="mb-2">
                      <input type="text" name="additionalReason" class="form-control form-control-sm"
                             placeholder="Lý do chỉ định lâm sàng…" maxlength="500">
                    </div>
                    <div class="form-check mb-2 small">
                      <input class="form-check-input" type="checkbox" name="confirmAdditional" value="1" id="confirmAddCheck" checked>
                      <label class="form-check-label" for="confirmAddCheck">Đã giải thích chi phí phát sinh (nếu có)</label>
                    </div>
                    <button type="submit" class="btn btn-outline-primary w-100 rounded-pill fw-bold btn-sm" onclick="return confirm('Xác nhận tạo phiếu Chỉ định Siêu Âm?');">
                        <i class="bi bi-file-earmark-medical me-1"></i> Tạo Chỉ định Siêu âm
                    </button>
                </form>
              </c:when>
              <c:otherwise>
                <div class="alert alert-secondary small mb-0 rounded-3">
                  <i class="bi bi-lock-fill me-1"></i>Ca khám đã đóng. Hồ sơ ở chế độ Read-Only.
                </div>
              </c:otherwise>
            </c:choose>
          </div>

        </div>
      </div>

      <%-- Khối Xem kết quả siêu âm cận lâm sàng duy nhất --%>
      <c:if test="${record.id > 0}">
        <div class="card rounded-4 border-0 shadow-sm">
          <div class="card-body p-3">
            <div class="fw-semibold small text-uppercase text-muted mb-1"><i class="bi bi-soundwave me-1 text-primary"></i>Kết quả siêu âm</div>
            <p class="small text-muted mb-2">Xem hình ảnh siêu âm gốc và phân tích từ KTV/AI.</p>
            <a href="${pageContext.request.contextPath}/doctor/results?recordId=${record.id}"
               class="btn btn-outline-primary btn-sm rounded-pill w-100 fw-medium">
              <i class="bi bi-clipboard2-pulse me-1"></i>Xem kết quả siêu âm
            </a>
          </div>
        </div>
      </c:if>
    </div>

    <%-- ════ CỘT PHẢI: FORM NGHỆP VỤ 4 TAB ════ --%>
    <div class="col-lg-9">
      <form method="post" action="${pageContext.request.contextPath}/doctor/medical-records" id="obsForm" novalidate>
        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"/>
        <input type="hidden" name="appointmentId" value="${apptId}"/>
        <c:if test="${record.id > 0}">
          <input type="hidden" name="recordId" value="${record.id}"/>
        </c:if>

        <%-- Navigation 4 tab chuẩn hóa --%>
        <ul class="nav obs-nav border-bottom mb-0 bg-light rounded-top-4" id="obsTabs">
          <li class="nav-item">
            <button class="nav-link active" type="button" data-tab="tab1">
              <i class="bi bi-heart-pulse me-1"></i>1. Sinh hiệu mẹ &amp; Đánh giá thai
            </button>
          </li>
          <li class="nav-item">
            <button class="nav-link" type="button" data-tab="tab2">
              <i class="bi bi-activity me-1"></i>2. Khám sản khoa
            </button>
          </li>
          <li class="nav-item">
            <button class="nav-link" type="button" data-tab="tab3">
              <i class="bi bi-exclamation-triangle me-1"></i>3. Dấu hiệu nguy hiểm
            </button>
          </li>
          <li class="nav-item">
            <button class="nav-link" type="button" data-tab="tab4">
              <i class="bi bi-clipboard2-pulse me-1"></i>4. Chẩn đoán &amp; Kế hoạch
            </button>
          </li>
        </ul>

        <div class="card rounded-0 rounded-bottom-4 border-0 shadow-sm">
          <div class="card-body p-4">

            <%-- ═══ TAB 1: SINH HIỆU MẸ & ĐÁNH GIÁ THAI ═══ --%>
            <div id="tab1">

              <%-- Sinh hiệu mẹ --%>
              <div class="d-flex align-items-center justify-content-between mb-3">
                <p class="section-label mb-0"><i class="bi bi-person-heart me-1 text-primary"></i>Sinh hiệu mẹ</p>
                <div class="small text-muted">
                  Chỉ số BMI: <span id="bmiDisplay" class="badge bg-light text-dark border">
                    <c:choose>
                      <c:when test="${not empty record.weightKg and not empty record.heightCm}">
                        <fmt:formatNumber value="${record.weightKg / ((record.heightCm/100)*(record.heightCm/100))}" pattern="#0.0"/>
                      </c:when>
                      <c:otherwise>—</c:otherwise>
                    </c:choose>
                  </span>
                </div>
              </div>

              <div class="row g-3 mb-4">
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Cân nặng <span class="field-unit">(kg)</span></label>
                  <input type="number" name="weightKg" id="weightKg" step="0.1" min="20" max="300" class="form-control"
                         placeholder="vd: 58.5" value="${record.weightKg}" oninput="calcBMI()">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Chiều cao <span class="field-unit">(cm)</span></label>
                  <input type="number" name="heightCm" id="heightCm" step="0.1" min="100" max="250" class="form-control"
                         placeholder="vd: 158.0" value="${record.heightCm}" oninput="calcBMI()">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Mạch <span class="field-unit">(bpm)</span></label>
                  <input type="number" name="pulseBpm" min="30" max="250" class="form-control"
                         placeholder="vd: 80" value="${record.pulseBpm}">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Huyết áp tâm thu <span class="field-unit">(mmHg)</span></label>
                  <input type="number" name="systolicBP" min="50" max="250" class="form-control"
                         placeholder="vd: 120" value="${systolicBP}">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Huyết áp tâm trương <span class="field-unit">(mmHg)</span></label>
                  <input type="number" name="diastolicBP" min="30" max="150" class="form-control"
                         placeholder="vd: 80" value="${diastolicBP}">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Nhiệt độ <span class="field-unit">(°C)</span></label>
                  <input type="number" name="temperatureC" step="0.1" min="34" max="43" class="form-control"
                         placeholder="vd: 37.0" value="${record.temperatureC}">
                </div>
              </div>

              <%-- Đánh giá thai nhi --%>
              <div class="d-flex align-items-center justify-content-between mb-2">
                <p class="section-label mb-0"><i class="bi bi-person-standing me-1 text-primary"></i>Đánh giá thai nhi</p>
                <c:choose>
                  <c:when test="${not empty record.lastMenstrualPeriod}">
                    <span class="badge bg-info bg-opacity-10 text-info border">
                      <i class="bi bi-calendar-check me-1"></i>Nguồn: Tính tự động theo LMP (${record.lastMenstrualPeriod})
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge bg-light text-secondary border">
                      <i class="bi bi-pencil me-1"></i>Nguồn: Bác sĩ lâm sàng nhập thủ công
                    </span>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="row g-3">
                <div class="col-sm-3">
                  <label class="form-label fw-medium">Tuổi thai <span class="field-unit">(tuần)</span></label>
                  <input type="number" name="gestationalAgeWeeks" id="gestWeeks" min="0" max="44" class="form-control"
                         placeholder="0–44" value="${record.gestationalAgeWeeks}">
                </div>
                <div class="col-sm-3">
                  <label class="form-label fw-medium">Ngày lẻ <span class="field-unit">(ngày)</span></label>
                  <input type="number" name="gestationalAgeDays" id="gestDays" min="0" max="6" class="form-control"
                         placeholder="0–6" value="${record.gestationalAgeDays}">
                </div>
                <div class="col-sm-3">
                  <label class="form-label fw-medium">Chiều cao tử cung <span class="field-unit">(cm)</span></label>
                  <input type="number" name="fundalHeightCm" step="0.1" min="5" max="50" class="form-control"
                         placeholder="vd: 28.0" value="${record.fundalHeightCm}">
                </div>
                <div class="col-sm-3">
                  <label class="form-label fw-medium">Nhịp tim thai <span class="field-unit">(bpm)</span></label>
                  <input type="number" name="fetalHeartRate" min="60" max="220" class="form-control"
                         placeholder="vd: 140" value="${record.fetalHeartRate}">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Ngôi thai</label>
                  <select name="fetalPresentation" class="form-select">
                    <option value="">Chưa đánh giá</option>
                    <option value="Ngôi đầu"      <c:if test="${record.fetalPresentation == 'Ngôi đầu'}">selected</c:if>>Ngôi đầu</option>
                    <option value="Ngôi mông"      <c:if test="${record.fetalPresentation == 'Ngôi mông'}">selected</c:if>>Ngôi mông</option>
                    <option value="Ngôi ngang"     <c:if test="${record.fetalPresentation == 'Ngôi ngang'}">selected</c:if>>Ngôi ngang</option>
                    <option value="Chưa xác định"  <c:if test="${record.fetalPresentation == 'Chưa xác định'}">selected</c:if>>Chưa xác định</option>
                  </select>
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Thế thai</label>
                  <select name="fetalPosition" class="form-select">
                    <option value="">Chưa đánh giá</option>
                    <option value="Trái trước"    <c:if test="${record.fetalPosition == 'Trái trước'}">selected</c:if>>Trái trước</option>
                    <option value="Trái sau"      <c:if test="${record.fetalPosition == 'Trái sau'}">selected</c:if>>Trái sau</option>
                    <option value="Phải trước"    <c:if test="${record.fetalPosition == 'Phải trước'}">selected</c:if>>Phải trước</option>
                    <option value="Phải sau"      <c:if test="${record.fetalPosition == 'Phải sau'}">selected</c:if>>Phải sau</option>
                    <option value="Chưa xác định" <c:if test="${record.fetalPosition == 'Chưa xác định'}">selected</c:if>>Chưa xác định</option>
                  </select>
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Vận động thai</label>
                  <select name="fetalMovement" class="form-select">
                    <option value="">Chưa đánh giá</option>
                    <option value="Có"             <c:if test="${record.fetalMovement == 'Có'}">selected</c:if>>Có (Bình thường)</option>
                    <option value="Giảm"           <c:if test="${record.fetalMovement == 'Giảm'}">selected</c:if>>Giảm vận động</option>
                    <option value="Không cảm nhận" <c:if test="${record.fetalMovement == 'Không cảm nhận'}">selected</c:if>>Không cảm nhận</option>
                  </select>
                </div>
              </div>
            </div>

            <%-- ═══ TAB 2: KHÁM SẢN KHOA / CHUYỂN DẠ ═══ --%>
            <div id="tab2" style="display:none;">
              <div class="form-check form-switch mb-3 p-3 bg-light rounded-3 border">
                <input class="form-check-input" type="checkbox" id="enableLaborExamToggle"
                       onchange="toggleLaborExamSection(this.checked)"
                       <c:if test="${not empty record.cervicalDilationCm or not empty record.cervicalEffacement or not empty record.presentationStation}">checked</c:if>>
                <label class="form-check-label fw-bold text-primary" for="enableLaborExamToggle">
                  <i class="bi bi-stethoscope me-1"></i>Thực hiện khám chuyển dạ / khám sản khoa chuyên sâu
                </label>
              </div>

              <div id="laborExamContainer" style="display:${(not empty record.cervicalDilationCm or not empty record.cervicalEffacement or not empty record.presentationStation) ? 'block' : 'none'};">
                <div class="row g-3">
                  <div class="col-sm-4">
                    <label class="form-label fw-medium">Độ mở CTC <span class="field-unit">(cm)</span></label>
                    <input type="number" name="cervicalDilationCm" id="cervDilation" step="0.5" min="0" max="10" class="form-control"
                           placeholder="0–10" value="${record.cervicalDilationCm}">
                  </div>
                  <div class="col-sm-4">
                    <label class="form-label fw-medium">Độ xóa CTC</label>
                    <select name="cervicalEffacement" id="cervEffacement" class="form-select">
                      <option value="">Chưa đánh giá</option>
                      <option value="Chưa xóa" <c:if test="${record.cervicalEffacement == 'Chưa xóa'}">selected</c:if>>Chưa xóa</option>
                      <option value="25%" <c:if test="${record.cervicalEffacement == '25%'}">selected</c:if>>25%</option>
                      <option value="50%" <c:if test="${record.cervicalEffacement == '50%'}">selected</c:if>>50%</option>
                      <option value="75%" <c:if test="${record.cervicalEffacement == '75%'}">selected</c:if>>75%</option>
                      <option value="100%" <c:if test="${record.cervicalEffacement == '100%'}">selected</c:if>>100%</option>
                    </select>
                  </div>
                  <div class="col-sm-4">
                    <label class="form-label fw-medium">Mức độ lọt</label>
                    <select name="presentationStation" id="presStation" class="form-select">
                      <option value="">Chưa đánh giá</option>
                      <option value="-3" <c:if test="${record.presentationStation == '-3'}">selected</c:if>>-3 (Cao)</option>
                      <option value="-2" <c:if test="${record.presentationStation == '-2'}">selected</c:if>>-2</option>
                      <option value="-1" <c:if test="${record.presentationStation == '-1'}">selected</c:if>>-1</option>
                      <option value="0" <c:if test="${record.presentationStation == '0'}">selected</c:if>>0 (Lọt chặt)</option>
                      <option value="+1" <c:if test="${record.presentationStation == '+1'}">selected</c:if>>+1</option>
                      <option value="+2" <c:if test="${record.presentationStation == '+2'}">selected</c:if>>+2</option>
                      <option value="+3" <c:if test="${record.presentationStation == '+3'}">selected</c:if>>+3 (Thấp)</option>
                    </select>
                  </div>
                  <div class="col-sm-6">
                    <label class="form-label fw-medium">Tình trạng nước ối</label>
                    <select name="amnioticFluid" id="amniFluid" class="form-select">
                      <option value="">Chưa đánh giá</option>
                      <option value="Bình thường" <c:if test="${record.amnioticFluid == 'Bình thường'}">selected</c:if>>Bình thường (Còn nguyên)</option>
                      <option value="Thiểu ối" <c:if test="${record.amnioticFluid == 'Thiểu ối'}">selected</c:if>>Thiểu ối</option>
                      <option value="Đa ối" <c:if test="${record.amnioticFluid == 'Đa ối'}">selected</c:if>>Đa ối</option>
                      <option value="Vỡ ối" <c:if test="${record.amnioticFluid == 'Vỡ ối'}">selected</c:if>>Vỡ ối tự nhiên</option>
                      <option value="Ối màu xanh" <c:if test="${record.amnioticFluid == 'Ối màu xanh'}">selected</c:if>>Ối màu xanh/vàng</option>
                    </select>
                  </div>
                </div>
              </div>

              <div class="mt-4">
                <label class="form-label fw-medium"><i class="bi bi-pencil-square me-1 text-primary"></i>Ghi chú khám lâm sàng bổ sung</label>
                <textarea name="clinicalNotes" class="form-control" rows="5"
                          placeholder="Nhập ghi chú quan sát lâm sàng, triệu chứng chi tiết…">${record.clinicalNotes}</textarea>
              </div>
            </div>

            <%-- ═══ TAB 3: DẤU HIỆU NGUY HIỂM ═══ --%>
            <div id="tab3" style="display:none;">
              <div class="risk-box ${record.hasRisk() ? 'active' : ''} mb-4" id="riskBox">
                <h6 class="fw-bold text-danger mb-3"><i class="bi bi-exclamation-triangle-fill me-2"></i>Dấu hiệu nguy hiểm — Ghi nhận lâm sàng</h6>

                <div class="row g-3 mb-3">
                  <div class="col-sm-6">
                    <div class="form-check form-switch">
                      <input class="form-check-input risk-check" type="checkbox" id="vaginalBleeding" name="vaginalBleeding"
                             <c:if test="${record.vaginalBleeding}">checked</c:if>>
                      <label class="form-check-label fw-medium" for="vaginalBleeding">
                        <i class="bi bi-droplet-fill text-danger me-1"></i>Chảy máu âm đạo bất thường
                      </label>
                    </div>
                  </div>
                  <div class="col-sm-6">
                    <div class="form-check form-switch">
                      <input class="form-check-input risk-check" type="checkbox" id="uterineContractions" name="uterineContractions"
                             <c:if test="${record.uterineContractions}">checked</c:if>>
                      <label class="form-check-label fw-medium" for="uterineContractions">
                        <i class="bi bi-activity text-danger me-1"></i>Cơn co tử cung bất thường
                      </label>
                    </div>
                  </div>
                </div>

                <div class="row g-3">
                  <div class="col-sm-4">
                    <label class="form-label fw-medium">Phù</label>
                    <select name="edema" class="form-select risk-select">
                      <option value="Không" <c:if test="${record.edema == 'Không' || empty record.edema}">selected</c:if>>Không</option>
                      <option value="Chi dưới" <c:if test="${record.edema == 'Chi dưới'}">selected</c:if>>Chi dưới</option>
                      <option value="Toàn thân" <c:if test="${record.edema == 'Toàn thân'}">selected</c:if>>Toàn thân ⚠</option>
                    </select>
                  </div>
                  <div class="col-sm-4">
                    <label class="form-label fw-medium">Protein niệu</label>
                    <select name="proteinuria" class="form-select risk-select">
                      <option value="Âm tính" <c:if test="${record.proteinuria == 'Âm tính' || empty record.proteinuria}">selected</c:if>>Âm tính</option>
                      <option value="1+" <c:if test="${record.proteinuria == '1+'}">selected</c:if>>1+</option>
                      <option value="2+" <c:if test="${record.proteinuria == '2+'}">selected</c:if>>2+ ⚠</option>
                      <option value="3+" <c:if test="${record.proteinuria == '3+'}">selected</c:if>>3+ ⚠⚠</option>
                    </select>
                  </div>
                </div>
              </div>

              <div>
                <label class="form-label fw-medium">Ghi chú nguy cơ bổ sung</label>
                <input type="hidden" name="riskFlagsJson" id="riskFlagsJson" value="${record.riskFlagsJson}">
                <textarea id="riskNotesDisplay" class="form-control" rows="3"
                          placeholder="Nhập các dấu hiệu bất thường khác…"
                          oninput="document.getElementById('riskFlagsJson').value=this.value"
                          >${record.riskFlagsJson}</textarea>
              </div>
            </div>

            <%-- ═══ TAB 4: CHẨN ĐOÁN & KẾ HOẠCH ═══ --%>
            <div id="tab4" style="display:none;">

              <%-- Card A: Chẩn đoán --%>
              <div class="card border-0 bg-light rounded-3 mb-4">
                <div class="card-body">
                  <label class="form-label fw-bold text-primary mb-2">
                    <i class="bi bi-clipboard2-pulse me-1"></i>CHẨN ĐOÁN LÂM SÀNG — BẮT BUỘC KHl CHỐT HỒ SƠ
                    <span class="field-unit ms-2">(Nhập mã ICD-10 nếu có, vd: O34.2)</span>
                  </label>
                  <textarea name="finalDiagnosis" class="form-control" rows="3"
                            placeholder="Nhập kết luận chẩn đoán lâm sàng…">${record.finalDiagnosis}</textarea>
                </div>
              </div>

              <%-- Card B: Hướng xử trí & Kế hoạch điều trị --%>
              <div class="card border-0 bg-light rounded-3 mb-4">
                <div class="card-body">
                  <label class="form-label fw-bold text-primary mb-2">
                    <i class="bi bi-clipboard-check me-1"></i>HƯỚNG XỬ TRÍ &amp; KẾ HOẠCH ĐIỀU TRỊ
                  </label>
                  <textarea name="treatmentPlan" class="form-control mb-3" rows="3"
                            placeholder="Hướng xử trí, lời khuyên cho sản phụ, chế độ dinh dưỡng…">${record.treatmentPlan}</textarea>
                  <div class="row g-3">
                    <div class="col-sm-6">
                      <label class="form-label fw-medium"><i class="bi bi-calendar-plus me-1 text-primary"></i>Ngày tái khám</label>
                      <input type="date" name="nextAppointmentDate" id="nextApptDate" class="form-control"
                             value="${record.nextAppointmentDate}">
                    </div>
                    <div class="col-sm-6">
                      <label class="form-label fw-medium"><i class="bi bi-arrow-up-right-circle me-1 text-primary"></i>Chuyển viện / Chuyên khoa</label>
                      <input type="text" name="referredTo" class="form-control"
                             placeholder="Để trống nếu không chuyển" value="${record.referredTo}">
                    </div>
                  </div>
                </div>
              </div>

              <%-- Card C: Kê đơn thuốc (embedded) --%>
              <div class="card border-0 bg-light rounded-3 mb-3">
                <div class="card-body">
                  <div class="d-flex align-items-center justify-content-between mb-2">
                    <label class="form-label fw-bold text-primary mb-0">
                      <i class="bi bi-capsule me-1"></i>KÊ ĐƠN THUỐC
                    </label>
                    <span class="badge bg-primary rounded-pill" id="rxRowCount">
                      0 loại thuốc
                    </span>
                  </div>
                  <p class="text-muted small mb-2">Bỏ trống nếu không kê đơn. Bác sĩ lâm sàng chỉ thêm dòng thuốc khi thực sự cho đơn.</p>

                                    <div class="border rounded-3 p-3 bg-white mb-2" id="rxMedicineArea">
                    <!-- Header hàng (chỉ hiển thị trên desktop) -->
                    <div class="row g-2 mb-2 d-none d-md-flex fw-bold text-muted border-bottom pb-2 small">
                      <div class="col-md-5">Tên thuốc</div>
                      <div class="col-md-2">Số lượng</div>
                      <div class="col-md-4">Liều dùng / Hướng dẫn <span class="text-danger">*</span></div>
                      <div class="col-md-1 text-end">Xóa</div>
                    </div>

                    <div id="rxMedicineRows">
                      <c:choose>
                        <c:when test="${not empty prescription and not empty prescription.items}">
                          <c:forEach var="item" items="${prescription.items}">
                            <div class="rx-medicine-row border-bottom py-3 py-md-2">
                              <div class="row g-2 align-items-start">
                                <div class="col-md-5 col-12">
                                  <label class="form-label small fw-semibold text-muted d-md-none mb-1">Tên thuốc</label>
                                  <select name="medicineId[]"
                                          class="form-select form-select-sm rounded-3 rx-med-dropdown"
                                          <c:if test="${not canEditRecord}">disabled</c:if>>
                                    <option value="">— Chọn thuốc —</option>
                                    <c:forEach var="med" items="${medicines}">
                                      <option value="${med.id}"
                                              data-unit="${med.unit}"
                                              data-stock="${med.stockQuantity}"
                                              data-desc="${med.description}"
                                              <c:if test="${med.id == item.medicineId}">selected</c:if>>
                                        ${med.name}<c:if test="${not empty med.categoryName}"> [${med.categoryName}]</c:if>
                                      </option>
                                    </c:forEach>
                                  </select>
                                  <div class="rx-med-desc-hint text-muted small mt-1" style="font-size:.75rem;"></div>
                                </div>
                                <div class="col-md-2 col-6">
                                  <label class="form-label small fw-semibold text-muted d-md-none mb-1">Số lượng</label>
                                  <div class="input-group input-group-sm">
                                    <input type="number" name="quantity[]"
                                           class="form-control rounded-start-3 text-center"
                                           value="${item.quantity}" min="1" max="9999"
                                           <c:if test="${not canEditRecord}">disabled</c:if>>
                                    <span class="input-group-text rx-unit-suffix rounded-end-3 text-truncate" style="max-width: 60px;">${item.medicineUnit}</span>
                                  </div>
                                </div>
                                <div class="col-md-4 col-6">
                                  <label class="form-label small fw-semibold text-muted d-md-none mb-1">Liều dùng / Hướng dẫn *</label>
                                  <input type="text" name="dosage[]"
                                         class="form-control form-control-sm rounded-3"
                                         value="${item.dosage}"
                                         autocomplete="off"
                                         placeholder="VD: 2 viên/ngày, sáng-tối"
                                         <c:if test="${not canEditRecord}">disabled</c:if>>
                                </div>
                                <div class="col-md-1 col-12 align-self-start text-end pt-md-1">
                                  <c:if test="${canEditRecord}">
                                    <button type="button"
                                            class="btn btn-sm btn-outline-danger rounded-circle rx-remove-row"
                                            style="width:30px;height:30px;padding:0;">
                                      <i class="bi bi-x"></i>
                                    </button>
                                  </c:if>
                                </div>
                              </div>
                            </div>
                          </c:forEach>
                        </c:when>
                      </c:choose>
                    </div>
                  </div>

                  <c:if test="${canEditRecord}">
                    <button type="button" id="rxAddRowBtn" class="btn btn-sm btn-outline-primary rounded-pill px-3">
                      <i class="bi bi-plus-lg me-1"></i>Thêm thuốc
                    </button>
                  </c:if>
                </div>
              </div>

              <template id="rxRowTemplate">
                <div class="rx-medicine-row border-bottom py-3 py-md-2">
                  <div class="row g-2 align-items-start">
                    <div class="col-md-5 col-12">
                      <label class="form-label small fw-semibold text-muted d-md-none mb-1">Tên thuốc</label>
                      <select name="medicineId[]" class="form-select form-select-sm rounded-3 rx-med-dropdown">
                        <option value="">— Chọn thuốc —</option>
                        <c:forEach var="med" items="${medicines}">
                          <option value="${med.id}"
                                  data-unit="${med.unit}"
                                  data-stock="${med.stockQuantity}"
                                  data-desc="${med.description}">
                            ${med.name}<c:if test="${not empty med.categoryName}"> [${med.categoryName}]</c:if>
                          </option>
                        </c:forEach>
                      </select>
                      <div class="rx-med-desc-hint text-muted small mt-1" style="font-size:.75rem;"></div>
                    </div>
                    <div class="col-md-2 col-6">
                      <label class="form-label small fw-semibold text-muted d-md-none mb-1">Số lượng</label>
                      <div class="input-group input-group-sm">
                        <input type="number" name="quantity[]"
                               class="form-control rounded-start-3 text-center"
                               value="1" min="1" max="9999">
                        <span class="input-group-text rx-unit-suffix rounded-end-3 text-truncate" style="max-width: 60px;">—</span>
                      </div>
                    </div>
                    <div class="col-md-4 col-6">
                      <label class="form-label small fw-semibold text-muted d-md-none mb-1">Liều dùng / Hướng dẫn *</label>
                      <input type="text" name="dosage[]"
                             class="form-control form-control-sm rounded-3"
                             autocomplete="off"
                             placeholder="VD: 2 viên/ngày, sáng-tối">
                    </div>
                    <div class="col-md-1 col-12 align-self-start text-end pt-md-1">
                      <button type="button"
                              class="btn btn-sm btn-outline-danger rounded-circle rx-remove-row"
                              style="width:30px;height:30px;padding:0;">
                        <i class="bi bi-x"></i>
                      </button>
                    </div>
                  </div>
                </div>
              </template>

            </div>

          </div><%-- card-body --%>

          <%-- ════ THANH HÀNH ĐỘNG STICKY (ACTION BAR) ════ --%>
          <div class="doctor-action-bar">
            <c:choose>
              <c:when test="${canEditRecord}">
                <input type="hidden" name="submitAction" id="submitActionField" value="final">

                <div class="d-flex gap-3 align-items-center flex-wrap">
                  <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-outline-secondary rounded-3 px-4">
                    <i class="bi bi-arrow-left me-1"></i>Quay lại
                  </a>

                  <button type="button" onclick="doSubmit('draft')" id="btnDraft" class="btn btn-outline-warning rounded-3 px-4">
                    <i class="bi bi-file-earmark me-2"></i>Lưu nháp (Draft)
                  </button>

                  <button type="button" onclick="confirmAndSubmitFinal()" id="btnFinal" class="btn btn-success rounded-3 px-4 ms-auto fw-semibold">
                    <i class="bi bi-floppy me-2"></i>Chốt hồ sơ &amp; hoàn thành khám
                  </button>
                </div>
              </c:when>
              <c:otherwise>
                <div class="d-flex align-items-center justify-content-between">
                  <span class="text-muted small"><i class="bi bi-lock-fill me-1"></i>Ca khám đã hoàn thành hoặc ở chế độ Read-Only.</span>
                  <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-sm btn-outline-secondary rounded-3 px-4">
                    <i class="bi bi-arrow-left me-1"></i>Quay lại lịch hẹn
                  </a>
                </div>
              </c:otherwise>
            </c:choose>
          </div>

        </div><%-- card --%>
      </form>
    </div><%-- col --%>
  </div><%-- row --%>

  <%-- Modal Xác nhận Chốt Hồ Sơ --%>
  <div class="modal fade" id="finalConfirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content rounded-4 border-0 shadow">
        <div class="modal-header border-0 bg-success text-white rounded-top-4">
          <h5 class="modal-title fw-bold"><i class="bi bi-check-circle-fill me-2"></i>Xác Nhận Chốt Hồ Sơ &amp; Hoàn Thành Khám</h5>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body p-4">
          <p class="mb-2">Bạn có chắc chắn muốn chốt hồ sơ bệnh án cho bệnh nhân <strong>${record.patientName}</strong>?</p>
          <ul class="small text-muted mb-3">
            <li>Lịch hẹn sẽ chuyển sang trạng thái <strong>Hoàn thành (Completed)</strong>.</li>
            <li>Hồ sơ bệnh án sẽ đóng chỉnh sửa chính thức.</li>
          </ul>
          <div id="modalSummary" class="p-3 bg-light rounded-3 small"></div>
        </div>
        <div class="modal-footer border-0 p-3 bg-light rounded-bottom-4">
          <button type="button" class="btn btn-outline-secondary rounded-3" data-bs-dismiss="modal">Kiểm tra lại</button>
          <button type="button" class="btn btn-success rounded-3 fw-bold px-4" id="btnConfirmFinal" onclick="executeFinalSubmit()">
            <i class="bi bi-check2-circle me-1"></i>Xác nhận Chốt &amp; Hoàn thành
          </button>
        </div>
      </div>
    </div>
  </div>

  <script>
  let formDirty = false;

  // ── Tab switching ──────────────────────────────────────────────────────
  document.querySelectorAll('[data-tab]').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('[data-tab]').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      ['tab1','tab2','tab3','tab4'].forEach(id => {
        document.getElementById(id).style.display = (id === btn.dataset.tab) ? '' : 'none';
      });
    });
  });

  // ── Track form changes for beforeunload ────────────────────────────────
  document.querySelectorAll('#obsForm input, #obsForm select, #obsForm textarea').forEach(el => {
    el.addEventListener('change', () => { formDirty = true; });
  });

  window.addEventListener('beforeunload', (e) => {
    if (formDirty) {
      e.preventDefault();
      e.returnValue = '';
    }
  });

  // ── Auto Calculate BMI & LMP Gestational Age ───────────────────────────
  function calcBMI() {
    const w = parseFloat(document.getElementById('weightKg').value);
    const h = parseFloat(document.getElementById('heightCm').value);
    const el = document.getElementById('bmiDisplay');
    if (!el) return;
    if (!isNaN(w) && !isNaN(h) && h > 0 && w > 0) {
      const bmi = (w / Math.pow(h / 100, 2)).toFixed(1);
      let cat = 'Bình thường';
      if (bmi < 18.5) cat = 'Thiếu cân';
      else if (bmi >= 23 && bmi < 25) cat = 'Thừa cân';
      else if (bmi >= 25) cat = 'Béo phì';
      el.innerHTML = '<strong>' + bmi + '</strong> (' + cat + ')';
    } else {
      el.innerHTML = '—';
    }
  }

  // ── Labor Exam Section Toggle ──────────────────────────────────────────
  function toggleLaborExamSection(enabled) {
    const container = document.getElementById('laborExamContainer');
    if (!container) return;
    container.style.display = enabled ? 'block' : 'none';
    container.querySelectorAll('input, select').forEach(el => {
      el.disabled = !enabled;
      if (!enabled) el.value = '';
    });
  }

  // ── Risk box highlight ─────────────────────────────────────────────────
  function updateRiskBox() {
    const hasRisk = [...document.querySelectorAll('.risk-check')].some(c => c.checked) ||
                    ['edema','proteinuria'].some(n => {
                      const el = document.querySelector('[name="'+n+'"]');
                      return el && ['Toàn thân','2+','3+'].includes(el.value);
                    });
    document.getElementById('riskBox').classList.toggle('active', hasRisk);
  }
  document.querySelectorAll('.risk-check, .risk-select').forEach(el => el.addEventListener('change', updateRiskBox));

  // ── Validation & Submit Helper ─────────────────────────────────────────
  function showFieldError(fieldName, msg, tabId) {
    const el = document.querySelector('[name="' + fieldName + '"]');
    if (!el) return;
    el.classList.add('is-invalid');
    let fb = el.parentNode.querySelector('.invalid-feedback');
    if (!fb) {
      fb = document.createElement('div');
      fb.className = 'invalid-feedback';
      el.parentNode.appendChild(fb);
    }
    fb.textContent = msg;
    if (tabId) document.querySelector('[data-tab="' + tabId + '"]').click();
    el.focus();
  }

  function clearFieldError(fieldName) {
    const el = document.querySelector('[name="' + fieldName + '"]');
    if (el) {
      el.classList.remove('is-invalid');
      const fb = el.parentNode.querySelector('.invalid-feedback');
      if (fb) fb.textContent = '';
    }
  }

  function submitObsForm() {
    ['finalDiagnosis','weightKg','heightCm','pulseBpm','temperatureC',
     'systolicBP','diastolicBP','gestationalAgeWeeks','gestationalAgeDays',
     'fetalHeartRate','fundalHeightCm','cervicalDilationCm','nextAppointmentDate'].forEach(clearFieldError);

    let firstError = null;
    const isFinal = document.getElementById('submitActionField').value === 'final';

    // 1. Chẩn đoán (Bắt buộc khi final)
    const diag = document.querySelector('[name="finalDiagnosis"]');
    if (isFinal && (!diag || !diag.value.trim())) {
      showFieldError('finalDiagnosis', 'Vui lòng nhập chẩn đoán trước khi chốt hồ sơ.', 'tab4');
      return;
    }
    if (diag && diag.value.trim().length > 1000) {
      showFieldError('finalDiagnosis', 'Chẩn đoán không được vượt quá 1000 ký tự.', 'tab4');
      return;
    }

    // Helper kiểm tra range số
    function validateNum(name, min, max, label, tab) {
      const el = document.querySelector('[name="' + name + '"]');
      if (!el || el.value === '' || el.disabled) return true;
      const v = parseFloat(el.value);
      if (isNaN(v) || v < min || v > max) {
        if (!firstError) {
          showFieldError(name, label + ' phải từ ' + min + ' đến ' + max + '.', tab);
          firstError = name;
        }
        return false;
      }
      return true;
    }

    validateNum('weightKg',     20,  300, 'Cân nặng (kg)',          'tab1');
    validateNum('heightCm',    100,  250, 'Chiều cao (cm)',         'tab1');
    validateNum('pulseBpm',     30,  250, 'Mạch (bpm)',             'tab1');
    validateNum('temperatureC', 34,   43, 'Nhiệt độ (°C)',          'tab1');
    validateNum('systolicBP',   50,  250, 'Huyết áp tâm thu',       'tab1');
    validateNum('diastolicBP',  30,  150, 'Huyết áp tâm trương',    'tab1');

    validateNum('gestationalAgeWeeks',  4,  44, 'Tuổi thai (tuần)',        'tab1');
    validateNum('gestationalAgeDays',   0,   6, 'Ngày lẻ tuổi thai',      'tab1');
    validateNum('fetalHeartRate',      60, 220, 'Nhịp tim thai (bpm)',     'tab1');
    validateNum('fundalHeightCm',       5,  50, 'Chiều cao tử cung (cm)', 'tab1');

    validateNum('cervicalDilationCm', 0, 10, 'Độ mở CTC (cm)', 'tab2');

    // Ngày tái khám >= hôm nay
    if (!firstError) {
      const nadEl = document.querySelector('[name="nextAppointmentDate"]');
      if (nadEl && nadEl.value) {
        const today = new Date(); today.setHours(0,0,0,0);
        const picked = new Date(nadEl.value);
        if (picked < today) {
          showFieldError('nextAppointmentDate', 'Ngày tái khám phải từ hôm nay trở đi.', 'tab4');
          firstError = 'nextAppointmentDate';
        }
      }
    }

    // Đơn thuốc kèm theo
    if (!firstError) {
      const rxSelects = document.querySelectorAll('select[name="medicineId[]"]');
      const seenMed = new Set();
      rxSelects.forEach(sel => {
        if (firstError || !sel.value) return;
        const row = sel.closest('tr');
        const qtyEl = row.querySelector('input[name="quantity[]"]');
        const dosageEl = row.querySelector('input[name="dosage[]"]');
        const q = parseInt(qtyEl.value);
        if (!qtyEl.value || isNaN(q) || q < 1 || q > 9999) {
          qtyEl.classList.add('is-invalid');
          document.querySelector('[data-tab="tab4"]').click();
          qtyEl.focus();
          firstError = 'rxQuantity';
          return;
        }
        if (!dosageEl.value || !dosageEl.value.trim()) {
          dosageEl.classList.add('is-invalid');
          document.querySelector('[data-tab="tab4"]').click();
          dosageEl.focus();
          firstError = 'rxDosage';
          return;
        }
        if (seenMed.has(sel.value)) {
          sel.classList.add('is-invalid');
          document.querySelector('[data-tab="tab4"]').click();
          firstError = 'rxDuplicate';
          return;
        }
        seenMed.add(sel.value);
      });
    }

    if (firstError) return;

    formDirty = false;
    document.getElementById('btnFinal').disabled = true;
    document.getElementById('btnDraft').disabled = true;
    document.getElementById('obsForm').submit();
  }

  // ── Bảng kê đơn thuốc ──────────────────────────────────────────────────
  (function () {
    const tbody  = document.getElementById('rxMedicineRows');
    const addBtn = document.getElementById('rxAddRowBtn');
    const tpl    = document.getElementById('rxRowTemplate');
    if (!tbody || !tpl) return;

    function updateCount() {
      const n = tbody.querySelectorAll('.rx-medicine-row').length;
      document.getElementById('rxRowCount').textContent = n + ' loại thuốc';
    }
    updateCount();

        function bindDescHint(sel) {
      const row = sel.closest('.rx-medicine-row');

      function refresh() {
        const opt    = sel.options[sel.selectedIndex];
        const hint   = row.querySelector('.rx-med-desc-hint');
        const unitEl = row.querySelector('.rx-unit-suffix');
        const desc   = opt ? (opt.dataset.desc || '') : '';
        const unit   = opt ? (opt.dataset.unit || '') : '';
        if (unitEl) unitEl.textContent = unit || '—';
        if (hint) hint.textContent = desc;
        checkStock();
      }

      function checkStock() {
        const opt   = sel.options[sel.selectedIndex];
        const hint  = row.querySelector('.rx-med-desc-hint');
        const qtyEl = row.querySelector('input[name="quantity[]"]');
        if (!opt || !opt.value || !hint) return;
        const stock = parseInt(opt.dataset.stock);
        const qty   = parseInt(qtyEl.value);
        const desc  = opt.dataset.desc || '';
        if (!isNaN(stock) && !isNaN(qty) && qty > stock) {
          hint.innerHTML = '<span class="text-danger"><i class="bi bi-exclamation-triangle me-1"></i>Kho chỉ còn ' + stock + ' — kê vượt tồn kho.</span>';
        } else {
          hint.textContent = desc;
        }
      }

      sel.addEventListener('change', refresh);
      const qtyInput = row.querySelector('input[name="quantity[]"]');
      if (qtyInput) qtyInput.addEventListener('input', checkStock);
      refresh();
    }

    tbody.querySelectorAll('.rx-med-dropdown').forEach(bindDescHint);

    if (addBtn) {
      addBtn.addEventListener('click', () => {
        const clone = tpl.content.cloneNode(true);
        tbody.appendChild(clone);
        const newSel = tbody.lastElementChild.querySelector('.rx-med-dropdown');
        if (newSel) bindDescHint(newSel);
        updateCount();
      });
    }

    tbody.addEventListener('click', (e) => {
      const btn = e.target.closest('.rx-remove-row');
      if (!btn) return;
      btn.closest('.rx-medicine-row').remove();
      updateCount();
    });
  })();

  function doSubmit(action) {
    document.getElementById('submitActionField').value = action;
    submitObsForm();
  }

  function confirmAndSubmitFinal() {
    const diag = document.querySelector('[name="finalDiagnosis"]').value.trim();
    if (!diag) {
      showFieldError('finalDiagnosis', 'Vui lòng nhập chẩn đoán trước khi chốt hồ sơ.', 'tab4');
      return;
    }

    const rxCount = document.querySelectorAll('#rxMedicineRows .rx-medicine-row').length;
    const hasRisk = document.getElementById('riskBox').classList.contains('active');

    let summaryHtml = '<div><strong>Chẩn đoán:</strong> ' + diag + '</div>';
    summaryHtml += '<div><strong>Đơn thuốc:</strong> ' + rxCount + ' loại thuốc</div>';
    if (hasRisk) {
      summaryHtml += '<div class="text-danger mt-1"><i class="bi bi-exclamation-triangle-fill me-1"></i>Có ghi nhận yếu tố nguy cơ.</div>';
    }

    document.getElementById('modalSummary').innerHTML = summaryHtml;
    const modal = new bootstrap.Modal(document.getElementById('finalConfirmModal'));
    modal.show();
  }

  function executeFinalSubmit() {
    const btn = document.getElementById('btnConfirmFinal');
    if (btn) btn.disabled = true;
    doSubmit('final');
  }

  // Khởi tạo trạng thái ban đầu
  calcBMI();
  </script>

</c:if>

<%@ include file="../common/footer.jsp" %>
