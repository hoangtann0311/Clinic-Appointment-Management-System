<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<style>
/* ── Tab styling ──────────────────────────────────────────── */
.obs-nav .nav-link          { color:#6c757d; border-radius:10px 10px 0 0; font-weight:500; padding:.6rem 1.2rem; }
.obs-nav .nav-link.active   { color:#0d6efd; background:#fff; border-bottom:3px solid #0d6efd; }
.obs-nav .nav-link:hover:not(.active) { background:#f8f9fa; }

/* ── Section card ──────────────────────────────────────────── */
.section-label { font-size:.7rem; font-weight:700; letter-spacing:.08em;
                 text-transform:uppercase; color:#6c757d; margin-bottom:.5rem; }
.field-unit    { font-size:.8rem; color:#6c757d; }

/* ── Risk badge ────────────────────────────────────────────── */
.risk-box { border:2px solid #f8d7da; background:#fff5f5; border-radius:12px; padding:1rem; }
.risk-box.active { border-color:#dc3545; background:#fff0f0; }

/* ── Status dropdown ───────────────────────────────────────── */
.status-dropdown { appearance:auto; -webkit-appearance:auto;
  border:2px solid transparent; border-radius:20px; padding:.3rem .9rem;
  font-size:.8rem; font-weight:600; cursor:pointer; min-width:150px; }
.status-pending   { background:#fef3c7; color:#92400e; border-color:#fcd34d; }
.status-confirmed { background:#d1fae5; color:#065f46; border-color:#6ee7b7; }
.status-completed { background:#ede9fe; color:#5b21b6; border-color:#c4b5fd; }
.status-cancelled { background:#fee2e2; color:#991b1b; border-color:#fca5a5; }

/* ── Info panel ─────────────────────────────────────────────── */
.info-item { display:flex; flex-direction:column; margin-bottom:.75rem; }
.info-item .label { font-size:.7rem; text-transform:uppercase; color:#adb5bd; font-weight:600; letter-spacing:.05em; }
.info-item .value { font-size:.95rem; font-weight:500; color:#212529; }
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

  <c:if test="${not empty errorMessage}">
    <div class="alert alert-danger rounded-3 mb-3"><i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}</div>
  </c:if>
  <c:if test="${param.saved == '1'}">
    <div class="alert alert-success rounded-3 mb-3 d-flex align-items-center gap-2">
      <i class="bi bi-check-circle-fill"></i>Hồ sơ đã lưu thành công!
    </div>
  </c:if>

  <%-- Banner --%>
  <div class="card border-0 rounded-4 text-white mb-4" style="background:linear-gradient(135deg,#1a6b3c,#28a745);">
    <div class="card-body p-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
      <div>
        <h2 class="fw-bold mb-1">
          <i class="bi bi-journal-plus me-2"></i>
          <c:choose>
            <c:when test="${record.id > 0}">Cập nhật hồ sơ bệnh án</c:when>
            <c:otherwise>Tạo hồ sơ bệnh án mới</c:otherwise>
          </c:choose>
        </h2>
        <p class="mb-0 opacity-75">BS. ${doctorName} — Phụ Sản Khoa</p>
      </div>
      <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-light btn-sm rounded-pill px-3">
          <i class="bi bi-list me-1"></i>Danh sách
        </a>
        <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-outline-light btn-sm rounded-pill px-3">
          <i class="bi bi-arrow-left me-1"></i>Lịch hẹn
        </a>
      </div>
    </div>
  </div>

  <div class="row g-4">

    <%-- Cột trái: Thông tin bệnh nhân (chỉ đọc) --%>
    <div class="col-lg-3">
      <div class="card rounded-4 border-0 shadow-sm">
        <div class="card-body p-4">
          <div class="text-center mb-3">
            <div class="rounded-circle bg-success bg-opacity-10 text-success fw-bold d-flex align-items-center justify-content-center mx-auto mb-2"
                 style="width:56px;height:56px;font-size:1.3rem;">
              ${fn:toUpperCase(fn:substring(record.patientName,0,1))}
            </div>
            <h6 class="fw-bold mb-0">${record.patientName}</h6>
          </div>
          <hr class="my-2">
          <div class="info-item">
            <span class="label">Ngày hẹn</span>
            <span class="value"><i class="bi bi-calendar3 me-1 text-success"></i>${record.appointmentDate}</span>
          </div>
          <div class="info-item">
            <span class="label">Giờ khám</span>
            <span class="value"><i class="bi bi-clock me-1 text-success"></i>
              <c:out value="${not empty record.timeSlot ? record.timeSlot : '—'}"/>
            </span>
          </div>
          <div class="info-item">
            <span class="label">Kinh cuối (LMP)</span>
            <span class="value">
              <c:out value="${not empty record.lastMenstrualPeriod ? record.lastMenstrualPeriod : '—'}"/>
            </span>
          </div>
          <div class="info-item">
            <span class="label">Triệu chứng báo cáo</span>
            <span class="value small" style="white-space:pre-wrap;">
              <c:out value="${not empty record.symptoms ? record.symptoms : '(không có)'}"/>
            </span>
          </div>
          <c:if test="${record.pregnancyId != null}">
            <div class="info-item">
              <span class="label">Mã thai kỳ</span>
              <span class="value">#${record.pregnancyId}</span>
            </div>
          </c:if>
          <c:if test="${record.id > 0}">
            <hr class="my-2">
            <div class="info-item">
              <span class="label">Ngày tạo hồ sơ</span>
              <span class="value small text-muted">${record.createdAt}</span>
            </div>
            <c:if test="${record.hasRisk()}">
              <div class="alert alert-danger py-2 px-3 rounded-3 mt-2 mb-0 small">
                <i class="bi bi-exclamation-triangle-fill me-1"></i><strong>Có dấu hiệu nguy cơ!</strong>
              </div>
            </c:if>
          </c:if>
        </div>
      </div>
    </div>

    <%-- Cột phải: Form 4 tab --%>
    <div class="col-lg-9">
      <form method="post" action="${pageContext.request.contextPath}/doctor/medical-records" id="obsForm" novalidate>
        <input type="hidden" name="appointmentId" value="${apptId}"/>
        <c:if test="${record.id > 0}">
          <input type="hidden" name="recordId" value="${record.id}"/>
        </c:if>

        <%-- Tab navigation --%>
        <ul class="nav obs-nav border-bottom mb-0" id="obsTabs">
          <li class="nav-item">
            <button class="nav-link active" type="button" data-tab="tab1">
              <i class="bi bi-heart-pulse me-1"></i>Sinh hiệu & Thai
            </button>
          </li>
          <li class="nav-item">
            <button class="nav-link" type="button" data-tab="tab2">
              <i class="bi bi-activity me-1"></i>Khám sản khoa
            </button>
          </li>
          <li class="nav-item">
            <button class="nav-link" type="button" data-tab="tab3">
              <i class="bi bi-exclamation-triangle me-1"></i>Dấu hiệu nguy hiểm
            </button>
          </li>
          <li class="nav-item">
            <button class="nav-link" type="button" data-tab="tab4">
              <i class="bi bi-clipboard2-pulse me-1"></i>Chẩn đoán & Kế hoạch
            </button>
          </li>
        </ul>

        <div class="card rounded-0 rounded-bottom-4 rounded-end-4 border-0 shadow-sm">
          <div class="card-body p-4">

            <%-- ═══ TAB 1: SINH HIỆU & THAI ═══ --%>
            <div id="tab1">

              <%-- Sinh hiệu mẹ --%>
              <p class="section-label"><i class="bi bi-person-heart me-1"></i>Sinh hiệu mẹ</p>
              <div class="row g-3 mb-4">
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Cân nặng <span class="field-unit">(kg)</span></label>
                  <input type="number" name="weightKg" step="0.1" class="form-control"
                         placeholder="vd: 58.5" value="${record.weightKg}">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Chiều cao <span class="field-unit">(cm)</span></label>
                  <input type="number" name="heightCm" step="0.1" class="form-control"
                         placeholder="vd: 158.0" value="${record.heightCm}">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Huyết áp</label>
                  <input type="text" name="bloodPressure" class="form-control"
                         placeholder="vd: 120/80" value="${record.bloodPressure}">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Mạch <span class="field-unit">(bpm)</span></label>
                  <input type="number" name="pulseBpm" class="form-control"
                         placeholder="vd: 80" value="${record.pulseBpm}">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Nhiệt độ <span class="field-unit">(°C)</span></label>
                  <input type="number" name="temperatureC" step="0.1" class="form-control"
                         placeholder="vd: 37.0" value="${record.temperatureC}">
                </div>
              </div>

              <%-- Thai nhi --%>
              <p class="section-label"><i class="bi bi-person-standing me-1"></i>Thai nhi</p>
              <div class="row g-3">
                <div class="col-sm-3">
                  <label class="form-label fw-medium">Tuổi thai <span class="field-unit">(tuần)</span></label>
                  <input type="number" name="gestationalAgeWeeks" min="4" max="44" class="form-control"
                         placeholder="0–44" value="${record.gestationalAgeWeeks}">
                </div>
                <div class="col-sm-3">
                  <label class="form-label fw-medium">Ngày lẻ</label>
                  <input type="number" name="gestationalAgeDays" min="0" max="6" class="form-control"
                         placeholder="0–6" value="${record.gestationalAgeDays}">
                </div>
                <div class="col-sm-3">
                  <label class="form-label fw-medium">Chiều cao TC <span class="field-unit">(cm)</span></label>
                  <input type="number" name="fundalHeightCm" step="0.1" class="form-control"
                         placeholder="vd: 28.0" value="${record.fundalHeightCm}">
                </div>
                <div class="col-sm-3">
                  <label class="form-label fw-medium">Nhịp tim thai <span class="field-unit">(bpm)</span></label>
                  <input type="number" name="fetalHeartRate" min="80" max="200" class="form-control"
                         placeholder="vd: 140" value="${record.fetalHeartRate}">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Ngôi thai</label>
                  <select name="fetalPresentation" class="form-select">
                    <option value="">-- Chọn --</option>
                    <option value="Ngôi đầu"      <c:if test="${record.fetalPresentation == 'Ngôi đầu'}">selected</c:if>>Ngôi đầu</option>
                    <option value="Ngôi mông"      <c:if test="${record.fetalPresentation == 'Ngôi mông'}">selected</c:if>>Ngôi mông</option>
                    <option value="Ngôi ngang"     <c:if test="${record.fetalPresentation == 'Ngôi ngang'}">selected</c:if>>Ngôi ngang</option>
                    <option value="Chưa xác định"  <c:if test="${record.fetalPresentation == 'Chưa xác định'}">selected</c:if>>Chưa xác định</option>
                  </select>
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Thế thai</label>
                  <select name="fetalPosition" class="form-select">
                    <option value="">-- Chọn --</option>
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
                    <option value="">-- Chọn --</option>
                    <option value="Có"             <c:if test="${record.fetalMovement == 'Có'}">selected</c:if>>Có</option>
                    <option value="Giảm"           <c:if test="${record.fetalMovement == 'Giảm'}">selected</c:if>>Giảm</option>
                    <option value="Không cảm nhận" <c:if test="${record.fetalMovement == 'Không cảm nhận'}">selected</c:if>>Không cảm nhận</option>
                  </select>
                </div>
              </div>
            </div>

            <%-- ═══ TAB 2: KHÁM SẢN KHOA ═══ --%>
            <div id="tab2" style="display:none;">
              <p class="section-label"><i class="bi bi-stethoscope me-1"></i>Khám sản khoa chuyên sâu</p>
              <div class="row g-3">
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Độ mở CTC <span class="field-unit">(cm)</span></label>
                  <input type="number" name="cervicalDilationCm" step="0.5" min="0" max="10" class="form-control"
                         placeholder="0–10" value="${record.cervicalDilationCm}">
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Độ xóa CTC</label>
                  <select name="cervicalEffacement" class="form-select">
                    <option value="">-- Chọn --</option>
                                        <option value="Chưa xóa" <c:if test="${record.cervicalEffacement == 'Chưa xóa'}">selected</c:if>>Chưa xóa</option>
                    <option value="25%" <c:if test="${record.cervicalEffacement == '25%'}">selected</c:if>>25%</option>
                    <option value="50%" <c:if test="${record.cervicalEffacement == '50%'}">selected</c:if>>50%</option>
                    <option value="75%" <c:if test="${record.cervicalEffacement == '75%'}">selected</c:if>>75%</option>
                    <option value="100%" <c:if test="${record.cervicalEffacement == '100%'}">selected</c:if>>100%</option>
                  </select>
                </div>
                <div class="col-sm-4">
                  <label class="form-label fw-medium">Mức độ lọt</label>
                  <select name="presentationStation" class="form-select">
                    <option value="">-- Chọn --</option>
                                        <option value="-3" <c:if test="${record.presentationStation == '-3'}">selected</c:if>>-3</option>
                    <option value="-2" <c:if test="${record.presentationStation == '-2'}">selected</c:if>>-2</option>
                    <option value="-1" <c:if test="${record.presentationStation == '-1'}">selected</c:if>>-1</option>
                    <option value="0" <c:if test="${record.presentationStation == '0'}">selected</c:if>>0</option>
                    <option value="+1" <c:if test="${record.presentationStation == '+1'}">selected</c:if>>+1</option>
                    <option value="+2" <c:if test="${record.presentationStation == '+2'}">selected</c:if>>+2</option>
                    <option value="+3" <c:if test="${record.presentationStation == '+3'}">selected</c:if>>+3</option>
                  </select>
                </div>
                <div class="col-sm-6">
                  <label class="form-label fw-medium">Nước ối</label>
                  <select name="amnioticFluid" class="form-select">
                    <option value="">-- Chọn --</option>
                                        <option value="Bình thường" <c:if test="${record.amnioticFluid == 'Bình thường'}">selected</c:if>>Bình thường</option>
                    <option value="Thiểu ối" <c:if test="${record.amnioticFluid == 'Thiểu ối'}">selected</c:if>>Thiểu ối</option>
                    <option value="Đa ối" <c:if test="${record.amnioticFluid == 'Đa ối'}">selected</c:if>>Đa ối</option>
                    <option value="Vỡ ối" <c:if test="${record.amnioticFluid == 'Vỡ ối'}">selected</c:if>>Vỡ ối</option>
                    <option value="Ối màu xanh" <c:if test="${record.amnioticFluid == 'Ối màu xanh'}">selected</c:if>>Ối màu xanh</option>
                  </select>
                </div>
              </div>

              <div class="mt-4">
                <label class="form-label fw-medium"><i class="bi bi-pencil-square me-1"></i>Ghi chú lâm sàng</label>
                <textarea name="clinicalNotes" class="form-control" rows="6"
                          placeholder="Kết quả thăm khám, bổ sung chi tiết lâm sàng…">${record.clinicalNotes}</textarea>
              </div>
            </div>

            <%-- ═══ TAB 3: DẤU HIỆU NGUY HIỂM ═══ --%>
            <div id="tab3" style="display:none;">
              <div class="risk-box ${record.hasRisk() ? 'active' : ''} mb-4" id="riskBox">
                <h6 class="fw-bold text-danger mb-3"><i class="bi bi-exclamation-triangle-fill me-2"></i>Dấu hiệu nguy hiểm — đánh dấu nếu có</h6>

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

              <%-- Thêm ghi chú nguy cơ tự do --%>
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
              <div class="mb-4">
                <label class="form-label fw-medium">
                  <i class="bi bi-clipboard2-pulse me-1 text-primary"></i>Chẩn đoán
                  <span class="text-danger">*</span>
                  <span class="field-unit ms-2">(ghi mã ICD-10 nếu có, vd: O34.2)</span>
                </label>
                <textarea name="finalDiagnosis" class="form-control" rows="4"
                          placeholder="Nhập chẩn đoán lâm sàng…">${record.finalDiagnosis}</textarea>
              </div>

              <div class="mb-4">
                <label class="form-label fw-medium">
                  <i class="bi bi-clipboard-check me-1 text-primary"></i>Hướng xử trí & Kế hoạch điều trị
                </label>
                <textarea name="treatmentPlan" class="form-control" rows="5"
                          placeholder="Thuốc, chỉ định xét nghiệm, chỉ định siêu âm, lời khuyên cho mẹ…">${record.treatmentPlan}</textarea>
              </div>

              <div class="row g-3">
                <div class="col-sm-6">
                  <label class="form-label fw-medium"><i class="bi bi-calendar-plus me-1"></i>Ngày tái khám</label>
                  <input type="date" name="nextAppointmentDate" class="form-control"
                         value="${record.nextAppointmentDate}">
                </div>
                <div class="col-sm-6">
                  <label class="form-label fw-medium"><i class="bi bi-arrow-up-right-circle me-1"></i>Chuyển viện / Chuyên khoa</label>
                  <input type="text" name="referredTo" class="form-control"
                         placeholder="Để trống nếu không chuyển" value="${record.referredTo}">
                </div>
              </div>
            </div>

            <%-- Nút lưu (luôn hiện) --%>
            <hr class="mt-4">
            <div class="d-flex gap-3 align-items-center flex-wrap">
              <button type="button" onclick="submitObsForm()" class="btn btn-success rounded-3 px-4">
                <i class="bi bi-floppy me-2"></i>
                <c:choose>
                  <c:when test="${record.id > 0}">Cập nhật hồ sơ</c:when>
                  <c:otherwise>Lưu hồ sơ</c:otherwise>
                </c:choose>
              </button>
              <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-outline-secondary rounded-3">Huỷ</a>
              <span class="ms-auto text-muted small">
                <c:if test="${record.id == 0}">
                  <i class="bi bi-info-circle me-1"></i>Lưu lần đầu sẽ tự chuyển lịch hẹn sang <strong>Hoàn thành</strong>.
                </c:if>
              </span>
            </div>

          </div><%-- card-body --%>
        </div><%-- card --%>

            <%-- Điều hướng sang đơn thuốc --%>
            <c:if test="${record.id > 0}">
                <div class="card rounded-4 border-0 shadow-sm mt-3">
                    <div class="card-body p-3 d-flex align-items-center justify-content-between">
                        <div>
                            <span class="fw-medium">Bước tiếp theo</span>
                            <span class="text-muted small ms-2">Kê đơn thuốc cho bệnh nhân này</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/doctor/prescriptions?recordId=${record.id}"
                           class="btn btn-outline-primary btn-sm rounded-pill px-3">
                            <i class="bi bi-prescription2 me-1"></i>Kê đơn thuốc
                        </a>
                    </div>
                </div>
            </c:if>

      </form>
    </div><%-- col --%>
  </div><%-- row --%>

  <script>
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

  // ── Submit với validation đầy đủ ──────────────────────────────────────
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
    // Xóa lỗi cũ
    ['finalDiagnosis','weightKg','heightCm','bloodPressure','pulseBpm','temperatureC',
     'gestationalAgeWeeks','gestationalAgeDays','fetalHeartRate','fundalHeightCm',
     'cervicalDilationCm','nextAppointmentDate'].forEach(clearFieldError);

    let firstError = null;

    // 1. Chẩn đoán bắt buộc
    const diag = document.querySelector('[name="finalDiagnosis"]');
    if (!diag.value.trim()) {
      showFieldError('finalDiagnosis', 'Vui lòng nhập chẩn đoán trước khi lưu.', 'tab4');
      return;
    }
    if (diag.value.trim().length > 1000) {
      showFieldError('finalDiagnosis', 'Chẩn đoán không được vượt quá 1000 ký tự.', 'tab4');
      return;
    }

    // Helper kiểm tra range số
    function validateNum(name, min, max, label, tab) {
      const el = document.querySelector('[name="' + name + '"]');
      if (!el || el.value === '') return true;
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

    // 2. Sinh hiệu mẹ (tab1)
    validateNum('weightKg',     20,  300, 'Cân nặng (kg)',      'tab1');
    validateNum('heightCm',    100,  250, 'Chiều cao (cm)',     'tab1');
    validateNum('pulseBpm',     30,  250, 'Mạch (bpm)',         'tab1');
    validateNum('temperatureC', 34,   43, 'Nhiệt độ (°C)',      'tab1');

    // 3. Huyết áp định dạng (tab1)
    if (!firstError) {
      const bpEl = document.querySelector('[name="bloodPressure"]');
      if (bpEl && bpEl.value.trim()) {
        const bpMatch = bpEl.value.trim().match(/^(\d{2,3})\/(\d{2,3})$/);
        if (!bpMatch) {
          showFieldError('bloodPressure', 'Huyết áp không đúng định dạng (vd: 120/80).', 'tab1');
          firstError = 'bloodPressure';
        } else {
          const sys = parseInt(bpMatch[1]), dia = parseInt(bpMatch[2]);
          if (sys < 50 || sys > 250 || dia < 30 || dia > 150) {
            showFieldError('bloodPressure', 'Huyết áp ngoài phạm vi hợp lệ (tâm thu 50–250, tâm trương 30–150).', 'tab1');
            firstError = 'bloodPressure';
          }
        }
      }
    }

    // 4. Thai nhi (tab1)
    validateNum('gestationalAgeWeeks',  4,  44, 'Tuổi thai (tuần)',        'tab1');
    validateNum('gestationalAgeDays',   0,   6, 'Ngày lẻ tuổi thai',      'tab1');
    validateNum('fetalHeartRate',      60, 220, 'Nhịp tim thai (bpm)',     'tab1');
    validateNum('fundalHeightCm',       5,  50, 'Chiều cao tử cung (cm)', 'tab1');

    // 5. Độ mở CTC (tab2)
    validateNum('cervicalDilationCm', 0, 10, 'Độ mở CTC (cm)', 'tab2');

    // 6. Ngày tái khám >= hôm nay (tab4)
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

    if (firstError) return;

    document.getElementById('obsForm').submit();
  }
  </script>

</c:if>

<%@ include file="../common/footer.jsp" %>
