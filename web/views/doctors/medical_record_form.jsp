<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<style>
.step-card { border-radius:14px; border:1.5px solid #e9ecef; margin-bottom:1rem; overflow:hidden; }
.step-card .step-header { padding:.85rem 1.2rem; background:#f8f9fa; border-bottom:1px solid #dee2e6; display:flex; align-items:center; gap:.75rem; }
.step-card .step-body { padding:1.2rem; }
.step-num { width:34px;height:34px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:.95rem;color:#fff;background:#0d6efd;flex-shrink:0; }
.step-done .step-num { background:#198754; } .step-done { border-left:4px solid #198754; }
.step-active .step-num { background:#0d6efd; } .step-active { border-left:4px solid #0d6efd; box-shadow:0 2px 12px rgba(13,110,253,.15); }
.step-locked .step-num { background:#adb5bd; } .step-locked { border-left:4px solid #adb5bd; opacity:.7; }
.nav-tabs-custom .nav-link { font-size:.82rem; font-weight:600; color:#6c757d; border:none; padding:.5rem 1rem; }
.nav-tabs-custom .nav-link.active { color:#0d6efd; border-bottom:2px solid #0d6efd; background:transparent; }
.info-card { border-radius:14px; border:1.5px solid #e9ecef; position:sticky; top:5rem; }
.info-item { padding:.5rem 0; border-bottom:1px solid #f1f3f5; }
.info-item:last-child { border-bottom:0; }
.info-label { font-size:.7rem; text-transform:uppercase; color:#adb5bd; font-weight:600; letter-spacing:.05em; }
.info-value { font-size:.88rem; font-weight:500; color:#212529; }
.vital-row { display:flex; flex-wrap:wrap; gap:.5rem; }
.vital-chip { background:#f8f9fa; border:1px solid #e9ecef; border-radius:8px; padding:.35rem .65rem; font-size:.78rem; }
.risk-box { border:2px solid #f8d7da; background:#fff5f5; border-radius:12px; padding:1rem; }
.risk-box.active { border-color:#dc3545; background:#fff0f0; }
.doctor-action-bar { position:sticky; bottom:0; z-index:1020; background:#fff; border-top:1px solid #e9ecef; box-shadow:0 -4px 16px rgba(0,0,0,.08); padding:.75rem 1.5rem; border-radius:0 0 14px 14px; }
.clinical-value { white-space:pre-wrap;line-height:1.65; }
</style>

<%-- ═══════════ MODE: DANH SÁCH BỆNH NHÂN ═══════════ --%>
<c:if test="${mode == 'patients'}">
  <div class="row mb-4">
    <div class="col"><div class="card border-0 rounded-4 text-white" style="background:linear-gradient(135deg,#1a6b3c,#28a745);">
      <div class="card-body p-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div><h2 class="fw-bold mb-1"><i class="bi bi-journal-medical me-2"></i>Quản Lý Bệnh Án</h2><p class="mb-0 opacity-75">BS. ${doctorName} — danh sách bệnh nhân đã từng khám</p></div>
        <a href="${pageContext.request.contextPath}/doctor/dashboard" class="btn btn-light btn-sm rounded-pill px-3"><i class="bi bi-arrow-left me-1"></i>Tổng Quan</a>
      </div>
    </div></div>
  </div>
  <%-- Tìm kiếm --%>
  <div class="card rounded-4 border-0 shadow-sm mb-4"><div class="card-body p-3">
    <form method="get" class="d-flex gap-2 align-items-end flex-wrap">
      <div class="flex-grow-1"><label class="form-label fw-semibold small text-muted"><i class="bi bi-search me-1"></i>Tìm kiếm bệnh nhân</label>
      <input type="text" name="keyword" value="${fn:escapeXml(keyword)}" class="form-control rounded-3" placeholder="Tên hoặc số điện thoại…" style="max-width:300px;"></div>
      <div><label class="form-label fw-semibold small text-muted">Từ ngày</label>
      <input type="date" name="dateFrom" value="${dateFrom}" class="form-control rounded-3" style="width:150px;"></div>
      <div><label class="form-label fw-semibold small text-muted">Đến ngày</label>
      <input type="date" name="dateTo" value="${dateTo}" class="form-control rounded-3" style="width:150px;"></div>
      <div class="d-flex gap-2"><button class="btn btn-primary rounded-3"><i class="bi bi-search me-1"></i>Tìm</button><c:if test="${not empty keyword || not empty dateFrom || not empty dateTo}"><a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-outline-secondary rounded-3">Xoá lọc</a></c:if></div>
    </form>
  </div></div>
  <%-- Bảng bệnh nhân --%>
  <div class="card rounded-4 border-0 shadow-sm"><div class="card-body p-0">
    <c:choose><c:when test="${empty patientSummaries}"><div class="text-center py-5 text-muted"><i class="bi bi-person-x fs-1 d-block mb-3 opacity-25"></i><c:choose><c:when test="${not empty keyword || not empty dateFrom || not empty dateTo}">Không tìm thấy bệnh nhân nào với bộ lọc hiện tại.</c:when><c:otherwise>Chưa có bệnh nhân nào.</c:otherwise></c:choose></div></c:when><c:otherwise>
      <div class="table-responsive"><table class="table table-hover align-middle mb-0"><thead class="table-light"><tr><th class="ps-3">#</th><th>Bệnh Nhân</th><th>SĐT</th><th class="text-center">Số Lần Khám</th><th>Khám Gần Nhất</th><th>Chẩn Đoán Gần Nhất</th><th class="text-end pe-3">Thao Tác</th></tr></thead><tbody>
        <c:forEach var="p" items="${patientSummaries}" varStatus="lp">
          <tr>
            <td class="ps-3 text-muted small">${lp.index + 1 + (currentPage - 1) * 10}</td>
            <td><div class="d-flex align-items-center gap-2"><div class="rounded-circle bg-success bg-opacity-10 text-success d-flex align-items-center justify-content-center fw-bold" style="width:36px;height:36px;">${fn:toUpperCase(fn:substring(p.patientName, 0, 1))}</div><span class="fw-semibold">${p.patientName}</span></div><c:if test="${p.hasRisk}"><span class="badge bg-danger ms-5" style="font-size:.65rem;"><i class="bi bi-exclamation-triangle"></i> Rủi ro</span></c:if></td>
            <td class="small">${not empty p.patientPhone?p.patientPhone:'—'}</td>
            <td class="text-center"><span class="badge bg-primary rounded-pill">${p.totalVisits}</span></td>
            <td class="small"><fmt:formatDate value="${p.lastVisitDate}" pattern="dd/MM/yyyy"/></td>
            <td class="text-truncate small" style="max-width:160px;" title="${fn:escapeXml(p.lastDiagnosis)}">${not empty p.lastDiagnosis?p.lastDiagnosis:'—'}</td>
            <td class="text-end pe-3"><a href="?patientId=${p.patientId}" class="btn btn-sm btn-outline-info rounded-pill"><i class="bi bi-clock-history me-1"></i>Lịch Sử Khám</a></td>
          </tr>
        </c:forEach>
      </tbody></table></div>
    </c:otherwise></c:choose>
    <%-- Phân trang --%>
    <c:if test="${totalPages > 1}">
      <div class="card-footer bg-white p-3 border-top d-flex align-items-center justify-content-between flex-wrap gap-2">
        <div class="text-muted small">Hiển thị <strong>${fn:length(patientSummaries)}</strong> trên tổng <strong>${totalRecords}</strong> bệnh nhân</div>
        <nav><ul class="pagination pagination-sm mb-0">
          <c:set var="kwParam" value="${not empty keyword?'&keyword='.concat(fn:escapeXml(keyword)):''}"/>
          <li class="page-item ${currentPage==1?'disabled':''}"><a class="page-link" href="?page=${currentPage-1}${kwParam}">Trước</a></li>
          <c:forEach begin="1" end="${totalPages}" var="i"><li class="page-item ${i==currentPage?'active':''}"><a class="page-link" href="?page=${i}${kwParam}">${i}</a></li></c:forEach>
          <li class="page-item ${currentPage==totalPages?'disabled':''}"><a class="page-link" href="?page=${currentPage+1}${kwParam}">Sau</a></li>
        </ul></nav>
      </div>
    </c:if>
  </div></div>
</c:if>

<%-- ═══════════ MODE: LỊCH SỬ KHÁM BỆNH NHÂN ═══════════ --%>
<c:if test="${mode == 'history'}">
  <div class="row mb-4">
    <div class="col"><div class="card border-0 rounded-4 text-white" style="background:linear-gradient(135deg,#0d6efd,#0a58ca);">
      <div class="card-body p-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div><h2 class="fw-bold mb-1"><i class="bi bi-clock-history me-2"></i>Lịch Sử Khám Bệnh</h2><p class="mb-0 opacity-75">Bệnh nhân: <strong>${patientName}</strong> &mdash; Tổng <strong>${fn:length(records)}</strong> lần khám</p></div>
        <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-light btn-sm rounded-pill px-3"><i class="bi bi-arrow-left me-1"></i>Danh sách bệnh nhân</a>
      </div>
    </div></div>
  </div>
  <c:choose>
    <c:when test="${empty records}"><div class="card border-0 rounded-4"><div class="card-body text-center py-5 text-muted"><i class="bi bi-journal-x fs-1 d-block mb-3 opacity-25"></i><h5>Chưa có hồ sơ bệnh án nào cho bệnh nhân này.</h5></div></div></c:when>
    <c:otherwise>
      <div class="position-relative">
        <div class="position-absolute top-0 start-0 ms-3 h-100 border-start border-2 border-primary opacity-25" style="width:2px;margin-left:20px;"></div>
        <c:forEach var="rec" items="${records}" varStatus="st">
          <div class="d-flex gap-3 mb-4 position-relative">
            <div class="flex-shrink-0" style="width:42px;"><div class="rounded-circle d-flex align-items-center justify-content-center fw-bold text-white ${rec.hasRisk()?'bg-danger':'bg-primary'}" style="width:42px;height:42px;font-size:.85rem;">${st.index+1}</div></div>
            <div class="card border-0 rounded-4 flex-grow-1 ${rec.hasRisk()?'border-danger border':''}"><div class="card-body p-4">
              <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3">
                <div><h6 class="fw-bold mb-0"><i class="bi bi-calendar-event text-primary me-1"></i>${rec.appointmentDate}<c:if test="${not empty rec.timeSlot}"> &mdash; ${rec.timeSlot}</c:if></h6><small class="text-muted">Tạo lúc: ${rec.createdAt}</small></div>
                <div class="d-flex gap-2 flex-wrap">
                  <c:if test="${rec.hasRisk()}"><span class="badge bg-danger rounded-pill"><i class="bi bi-exclamation-triangle me-1"></i>Có rủi ro</span></c:if>
                  <c:if test="${not empty rec.gestationalAgeWeeks}"><span class="badge bg-light text-dark border rounded-pill"><i class="bi bi-clock me-1"></i>${rec.gestationalAgeDisplay}</span></c:if>
                  <%-- Ultrasound indicator --%>
                  <c:set var="hasUs" value="${hasUltrasoundMap[rec.id]}"/>
                  <c:if test="${hasUs}">
                    <c:choose>
                      <c:when test="${ultrasoundCompletedMap[rec.id]}"><span class="badge bg-success rounded-pill"><i class="bi bi-soundwave me-1"></i>Siêu âm: Đã có KQ</span></c:when>
                      <c:otherwise><span class="badge bg-warning text-dark rounded-pill"><i class="bi bi-hourglass-split me-1"></i>Siêu âm: Đang chờ</span></c:otherwise>
                    </c:choose>
                  </c:if>
                  <%-- Prescription indicator --%>
                  <c:set var="rx" value="${rxMap[rec.id]}"/>
                  <c:if test="${not empty rx}"><span class="badge bg-info rounded-pill"><i class="bi bi-prescription2 me-1"></i>${fn:length(rx.items)} thuốc</span></c:if>
                </div>
              </div>

              <%-- LMP & Clinical Notes --%>
              <c:if test="${not empty rec.lastMenstrualPeriod || not empty rec.clinicalNotes}">
              <div class="d-flex flex-wrap gap-2 mb-3">
                <c:if test="${not empty rec.lastMenstrualPeriod}"><span class="badge bg-light text-dark border"><i class="bi bi-calendar-heart me-1"></i>KCC: ${rec.lastMenstrualPeriod}</span></c:if>
                <c:if test="${not empty rec.clinicalNotes}"><span class="small text-muted text-truncate d-inline-block" style="max-width:400px;" title="${fn:escapeXml(rec.clinicalNotes)}"><i class="bi bi-journal-text me-1"></i>${fn:substring(rec.clinicalNotes, 0, 80)}${fn:length(rec.clinicalNotes) > 80 ? '…' : ''}</span></c:if>
              </div>
              </c:if>

              <div class="alert alert-light rounded-3 py-2 px-3 mb-3"><strong><i class="bi bi-stethoscope me-1 text-success"></i>Chẩn đoán:</strong> ${not empty rec.finalDiagnosis?rec.finalDiagnosis:'<span class="text-muted fst-italic">Chưa có chẩn đoán</span>'}</div>
              <div class="row g-3">
                <c:if test="${not empty rec.weightKg or not empty rec.heightCm or not empty rec.bloodPressure or not empty rec.pulseBpm or not empty rec.temperatureC}">
                  <div class="col-md-6"><div class="p-3 rounded-3 border h-100" style="background:#f8fafc;"><div class="fw-semibold small text-muted mb-2"><i class="bi bi-activity me-1 text-primary"></i>SINH HIỆU MẸ</div>
                    <div class="row g-2 small">
                      <c:if test="${not empty rec.weightKg}"><div class="col-6"><span class="text-muted">Cân nặng:</span> <strong>${rec.weightKg} kg</strong></div></c:if>
                      <c:if test="${not empty rec.heightCm}"><div class="col-6"><span class="text-muted">Chiều cao:</span> <strong>${rec.heightCm} cm</strong></div></c:if>
                      <c:if test="${not empty rec.weightKg && not empty rec.heightCm && rec.heightCm > 0}"><div class="col-6"><span class="text-muted">BMI:</span> <strong><fmt:formatNumber value="${rec.weightKg / (rec.heightCm * rec.heightCm / 10000)}" maxFractionDigits="1"/></strong></div></c:if>
                      <c:if test="${not empty rec.bloodPressure}"><div class="col-6"><span class="text-muted">Huyết áp:</span> <strong>${rec.bloodPressure} mmHg</strong></div></c:if>
                      <c:if test="${not empty rec.pulseBpm}"><div class="col-6"><span class="text-muted">Mạch:</span> <strong>${rec.pulseBpm} bpm</strong></div></c:if>
                      <c:if test="${not empty rec.temperatureC}"><div class="col-6"><span class="text-muted">Nhiệt độ:</span> <strong>${rec.temperatureC}°C</strong></div></c:if>
                    </div>
                  </div></div>
                </c:if>
                <c:if test="${not empty rec.fetalHeartRate or not empty rec.fundalHeightCm or not empty rec.fetalPresentation}">
                  <div class="col-md-6"><div class="p-3 rounded-3 border h-100" style="background:#f8fafc;"><div class="fw-semibold small text-muted mb-2"><i class="bi bi-heart-pulse me-1 text-danger"></i>THAI NHI</div>
                    <div class="row g-2 small"><c:if test="${not empty rec.fetalHeartRate}"><div class="col-6"><span class="text-muted">Tim thai:</span> <strong>${rec.fetalHeartRate} bpm</strong></div></c:if><c:if test="${not empty rec.fundalHeightCm}"><div class="col-6"><span class="text-muted">CCTC:</span> <strong>${rec.fundalHeightCm} cm</strong></div></c:if><c:if test="${not empty rec.fetalPresentation}"><div class="col-6"><span class="text-muted">Ngôi thai:</span> <strong>${rec.fetalPresentation}</strong></div></c:if></div>
                  </div></div>
                </c:if>
                <c:if test="${not empty rec.treatmentPlan}"><div class="col-12"><div class="small"><span class="text-muted fw-semibold"><i class="bi bi-clipboard2-pulse me-1"></i>Kế hoạch:</span> ${rec.treatmentPlan}</div></div></c:if>
                <%-- Đơn thuốc summary --%>
                <c:if test="${not empty rx}">
                <div class="col-12"><div class="small p-2 rounded-3 border" style="background:#f0fdf4;">
                  <span class="text-muted fw-semibold"><i class="bi bi-capsule me-1 text-success"></i>Đơn thuốc (${fn:length(rx.items)} thuốc):</span>
                  <c:forEach var="item" items="${rx.items}" varStatus="rxLoop">
                    <span class="badge bg-white text-dark border me-1 mb-1">${item.medicineName} x${item.quantity}</span>
                  </c:forEach>
                </div></div>
                </c:if>
              </div>
              <div class="d-flex gap-2 mt-3">
                <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${rec.appointmentId}" class="btn btn-sm btn-outline-primary rounded-pill"><i class="bi bi-eye me-1"></i>Xem Hồ Sơ</a>
              </div>
            </div></div>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</c:if>

<%-- ═══════════════════════════════════════════════ FORM TẠO/SỬA ═══════════════════════════════════════════════ --%>
<c:if test="${mode == 'form'}">
  <%-- Messages --%>
  <c:if test="${not empty errorMessage}"><div class="alert alert-danger rounded-3 mb-3" data-cams-toast><i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}</div></c:if>
  <c:if test="${param.saved=='1' && param.draft=='1'}"><div class="alert alert-success" data-cams-toast><i class="bi bi-check-circle-fill me-2"></i>Đã lưu nháp khám lâm sàng. Tiếp tục các bước kế tiếp.</div></c:if>
  <c:if test="${param.finalized=='1'}"><div class="alert alert-success" data-cams-toast><i class="bi bi-check-circle-fill me-2"></i>Đã chốt hồ sơ bệnh án và hoàn tất ca khám thành công!</div></c:if>
  <c:if test="${param.success=='requested'}"><div class="alert alert-info" data-cams-toast><i class="bi bi-send-check me-2"></i>Đã tạo chỉ định siêu âm. Chờ bệnh nhân thanh toán và BS siêu âm trả KQ.</div></c:if>
  <c:if test="${param.success=='cancelled'}"><div class="alert alert-warning" data-cams-toast><i class="bi bi-x-circle me-2"></i>Đã huỷ chỉ định siêu âm.</div></c:if>
  <c:if test="${param.error=='saveRecordFirst'}"><div class="alert alert-warning"><i class="bi bi-exclamation-triangle me-2"></i>Cần lưu nháp khám lâm sàng trước khi chỉ định siêu âm.</div></c:if>

  <%-- Hero --%>
  <div class="card border-0 rounded-4 text-white mb-3" style="background:linear-gradient(135deg,#0d6efd,#0a58ca);"><div class="card-body p-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
    <div><h5 class="fw-bold mb-0"><i class="bi bi-journal-plus me-2"></i>${record.id>0?'Hồ Sơ Khám #'.concat(record.id):'Tạo Hồ Sơ Bệnh Án Mới'}</h5><small class="opacity-75">BS. ${doctorName}</small></div>
    <div class="d-flex gap-2"><a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-light btn-sm rounded-pill px-3">Danh sách</a><a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-outline-light btn-sm rounded-pill px-3">Lịch hẹn</a></div>
  </div></div>

  <%-- Stage Indicator --%>
  <c:if test="${not empty examStageLabel}"><div class="alert border-0 shadow-sm d-flex align-items-center gap-2 mb-3 rounded-3" style="background:${examStage=='FINALIZED'?'#d1fae5':(examStage=='READY_TO_FINALIZE'?'#e0f2fe':'#f0f4ff')};border-left:4px solid ${examStage=='FINALIZED'?'#15803d':'#6366f1'};"><i class="bi ${examStage=='FINALIZED'?'bi-check-circle-fill text-success':'bi-stethoscope text-primary'} fs-4"></i><div><strong>${examStageLabel}</strong><c:if test="${examStage=='WAITING_PAYMENT'}"><div class="small text-danger">Bệnh nhân cần thanh toán dịch vụ tại quầy Lễ tân</div></c:if><c:if test="${examStage=='WAITING_ULTRASOUND'}"><div class="small text-warning">Đang chờ bác sĩ siêu âm trả kết quả</div></c:if></div></div></c:if>

  <div class="row g-4">
    <%-- ═══ LEFT: Patient Info ═══ --%>
    <div class="col-lg-3">
      <div class="info-card"><div class="card-body p-3">
        <h6 class="fw-bold mb-3 text-primary"><i class="bi bi-person-badge me-1"></i>Thông tin bệnh nhân</h6>
        <div class="info-item"><span class="info-label">Họ tên</span><span class="info-value">${not empty record.patientName ? record.patientName : (not empty patientName ? patientName : '—')}</span></div>
        <div class="info-item"><span class="info-label">Điện thoại</span><span class="info-value">${not empty patientPhone?patientPhone:'—'}</span></div>
        <div class="info-item"><span class="info-label">Ngày sinh</span><span class="info-value">${not empty patientDob?patientDob:'—'}</span></div>
        <div class="info-item"><span class="info-label">Ngày khám</span><span class="info-value"><i class="bi bi-calendar3 text-success me-1"></i>${record.appointmentDate}</span></div>
        <div class="info-item"><span class="info-label">Giờ khám</span><span class="info-value"><i class="bi bi-clock text-success me-1"></i>${not empty record.timeSlot?record.timeSlot:'—'}</span></div>
        <div class="info-item"><span class="info-label">Nguồn đặt</span><span class="info-value">
          <c:choose>
            <c:when test="${fn:toLowerCase(bookingSource) == 'staff' || fn:toLowerCase(bookingSource) == 'reception' || fn:toLowerCase(bookingSource) == 'counter'}">
              <span class="badge rounded-pill px-2 py-0.5" style="background:#e0e7ff; color:#3730a3; border:1px solid #c7d2fe; font-size:.65rem; font-weight:700;"><i class="bi bi-person-workspace me-1"></i>Tại quầy</span>
            </c:when>
            <c:otherwise>
              <span class="badge rounded-pill px-2 py-0.5" style="background:#e0f2fe; color:#0369a1; border:1px solid #bae6fd; font-size:.65rem; font-weight:700;"><i class="bi bi-globe me-1"></i>Đặt Online</span>
            </c:otherwise>
          </c:choose>
        </span></div>
        <div class="info-item"><span class="info-label">Kinh cuối (LMP)</span><span class="info-value" id="infoLmp">${not empty record.lastMenstrualPeriod?record.lastMenstrualPeriod:'—'}</span></div>
        <div class="info-item"><span class="info-label">Tuổi thai</span><span class="info-value" id="infoGa">${not empty record.gestationalAgeWeeks?record.gestationalAgeWeeks:'—'} tuần ${not empty record.gestationalAgeDays?record.gestationalAgeDays:'0'} ngày</span></div>
        <c:if test="${not empty record.weightKg}"><div class="info-item"><span class="info-label">Cân nặng</span><span class="info-value">${record.weightKg} kg</span></div></c:if>
        <c:if test="${not empty record.bloodPressure}"><div class="info-item"><span class="info-label">Huyết áp</span><span class="info-value">${record.bloodPressure}</span></div></c:if>
      </div></div>
    </div>

    <%-- ═══ RIGHT: Step-based Form ═══ --%>
    <div class="col-lg-9">
    <c:choose>
      <c:when test="${!canEditRecord && record.id > 0}">
        <%-- READ-ONLY: Hiển thị đầy đủ hồ sơ đã chốt --%>
        <%-- STEP 1: Khám lâm sàng --%>
        <div class="step-card step-done" id="step1">
          <div class="step-header"><span class="step-num"><i class="bi bi-check-lg"></i></span><h6 class="mb-0">Khám lâm sàng</h6><span class="badge bg-success ms-2">Đã hoàn thành</span></div>
          <div class="step-body">
            <div class="row g-3">
              <c:if test="${not empty record.weightKg}"><div class="col-md-3"><small class="text-muted d-block">Cân nặng</small><strong>${record.weightKg} kg</strong></div></c:if>
              <c:if test="${not empty record.heightCm}"><div class="col-md-3"><small class="text-muted d-block">Chiều cao</small><strong>${record.heightCm} cm</strong></div></c:if>
              <c:if test="${not empty record.weightKg && not empty record.heightCm && record.heightCm > 0}"><div class="col-md-3"><small class="text-muted d-block">BMI</small><strong><fmt:formatNumber value="${record.weightKg / (record.heightCm * record.heightCm / 10000)}" maxFractionDigits="1"/></strong></div></c:if>
              <c:if test="${not empty record.bloodPressure}"><div class="col-md-3"><small class="text-muted d-block">Huyết áp</small><strong>${record.bloodPressure} mmHg</strong></div></c:if>
              <c:if test="${not empty record.pulseBpm}"><div class="col-md-3"><small class="text-muted d-block">Mạch</small><strong>${record.pulseBpm} bpm</strong></div></c:if>
              <c:if test="${not empty record.temperatureC}"><div class="col-md-3"><small class="text-muted d-block">Nhiệt độ</small><strong>${record.temperatureC}°C</strong></div></c:if>
              <c:if test="${not empty record.lastMenstrualPeriod}"><div class="col-md-3"><small class="text-muted d-block">Kinh cuối (LMP)</small><strong>${record.lastMenstrualPeriod}</strong></div></c:if>
              <c:if test="${not empty record.gestationalAgeWeeks}"><div class="col-md-3"><small class="text-muted d-block">Tuổi thai</small><strong>${record.gestationalAgeWeeks} tuần ${not empty record.gestationalAgeDays ? record.gestationalAgeDays : '0'} ngày</strong></div></c:if>
              <c:if test="${not empty record.clinicalNotes}"><div class="col-12"><small class="text-muted d-block">Ghi chú khám lâm sàng</small><div class="clinical-value">${record.clinicalNotes}</div></div></c:if>
              <c:if test="${not empty record.treatmentPlan}"><div class="col-12"><small class="text-muted d-block">Điều trị / Hướng xử trí</small><div class="clinical-value">${record.treatmentPlan}</div></div></c:if>
            </div>
          </div>
        </div>

        <%-- STEP 2: Siêu âm --%>
        <c:if test="${existingUltrasoundOrders}">
          <div class="step-card step-done">
            <div class="step-header"><span class="step-num"><i class="bi bi-check-lg"></i></span><h6 class="mb-0">Siêu âm cận lâm sàng</h6><span class="badge bg-success ms-2">Đã thực hiện</span></div>
            <div class="step-body">
              <div class="d-flex align-items-center gap-3">
                <i class="bi bi-soundwave fs-2 text-primary"></i>
                <div>
                  <strong>Đã có kết quả siêu âm</strong>
                  <div class="small text-muted">Bấm nút bên dưới để xem hình ảnh và nhận xét chuyên môn.</div>
                </div>
                <button type="button" class="btn btn-sm btn-success rounded-pill px-3 ms-auto fw-semibold"
                        data-bs-toggle="modal" data-bs-target="#ultrasoundResultModal"
                        onclick="document.getElementById('usResultIframe').src='${pageContext.request.contextPath}/doctor/results?recordId=${record.id}&embed=true';">
                  <i class="bi bi-eye-fill me-1"></i>Xem kết quả siêu âm
                </button>
              </div>
            </div>
          </div>
        </c:if>

        <%-- STEP 3: Chẩn đoán & Kê đơn --%>
        <div class="step-card step-done">
          <div class="step-header"><span class="step-num"><i class="bi bi-check-lg"></i></span><h6 class="mb-0">Chẩn đoán &amp; Kê đơn</h6><span class="badge bg-success ms-2">Đã chốt</span></div>
          <div class="step-body">
            <%-- Diagnosis --%>
            <div class="mb-3">
              <small class="text-muted d-block fw-semibold"><i class="bi bi-stethoscope me-1 text-primary"></i>Chẩn đoán lâm sàng</small>
              <div class="p-2 rounded-3 bg-light border mt-1 clinical-value">${not empty record.finalDiagnosis ? record.finalDiagnosis : '<span class="text-muted fst-italic">Không có</span>'}</div>
            </div>
            <%-- Prescription --%>
            <div class="mb-3">
              <small class="text-muted d-block fw-semibold"><i class="bi bi-capsule me-1 text-primary"></i>Đơn thuốc</small>
              <c:choose>
                <c:when test="${not empty prescription && not empty prescription.items}">
                  <div class="table-responsive mt-1"><table class="table table-sm table-bordered mb-0"><thead class="table-light"><tr><th>#</th><th>Thuốc</th><th class="text-center">SL</th><th>Liều dùng</th></tr></thead><tbody>
                    <c:forEach var="item" items="${prescription.items}" varStatus="rxLoop">
                      <tr><td>${rxLoop.index+1}</td><td class="fw-medium">${item.medicineName}</td><td class="text-center">${item.quantity}</td><td>${item.dosage}</td></tr>
                    </c:forEach>
                  </tbody></table></div>
                </c:when>
                <c:otherwise><div class="text-muted fst-italic mt-1">Không kê đơn thuốc</div></c:otherwise>
              </c:choose>
            </div>
            <%-- Treatment Plan --%>
            <c:if test="${not empty record.treatmentPlan}">
              <div><small class="text-muted d-block fw-semibold"><i class="bi bi-clipboard2-pulse me-1 text-primary"></i>Kế hoạch điều trị</small><div class="clinical-value mt-1">${record.treatmentPlan}</div></div>
            </c:if>
          </div>
        </div>

        <div class="d-flex gap-2 mt-2">
          <a href="${pageContext.request.contextPath}/doctor/medical-records" class="btn btn-outline-secondary btn-sm rounded-pill"><i class="bi bi-arrow-left me-1"></i>Danh sách bệnh nhân</a>
          <a href="${pageContext.request.contextPath}/doctor/appointments" class="btn btn-outline-primary btn-sm rounded-pill"><i class="bi bi-calendar2-week me-1"></i>Lịch hẹn</a>
        </div>
      </c:when>
      <c:otherwise>
      <form method="post" action="${pageContext.request.contextPath}/doctor/medical-records" id="mainForm">
        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
        <input type="hidden" name="appointmentId" value="${apptId}">
        <input type="hidden" name="recordId" value="${record.id}">
        <input type="hidden" name="submitAction" id="submitAction" value="draft">

        <%-- ═══ STEP 1: Khám lâm sàng ═══ --%>
        <c:set var="step1Class" value="${record.id>0?'step-done':'step-active'}"/>
        <div class="step-card ${step1Class}" id="step1">
          <div class="step-header"><span class="step-num"><i class="bi bi-stethoscope"></i></span><h6 class="mb-0">Khám lâm sàng</h6><c:if test="${record.id>0}"><span class="badge bg-success ms-2">Đã lưu</span></c:if></div>
          <div class="step-body">
            <div class="row g-3">
              <%-- Hàng 1: Cân nặng, Chiều cao, BMI --%>
              <div class="col-md-4">
                <label class="form-label small fw-semibold">Cân nặng (kg)</label>
                <input type="number" step="0.1" name="weightKg" class="form-control form-control-sm" value="${record.weightKg}" onchange="calcBMI()" placeholder="VD: 55.0 (20–300 kg)">
                <div class="form-text text-muted" style="font-size:.7rem;">Gợi ý: nhập từ 20 đến 300 kg</div>
              </div>
              <div class="col-md-4">
                <label class="form-label small fw-semibold">Chiều cao (cm)</label>
                <input type="number" step="0.1" name="heightCm" class="form-control form-control-sm" value="${record.heightCm}" onchange="calcBMI()" placeholder="VD: 160.0 (100–250 cm)">
                <div class="form-text text-muted" style="font-size:.7rem;">Gợi ý: nhập từ 100 đến 250 cm</div>
              </div>
              <div class="col-md-4">
                <label class="form-label small fw-semibold">BMI</label>
                <input type="text" id="bmiDisplay" class="form-control form-control-sm" readonly placeholder="Tự động tính BMI">
                <div class="form-text text-muted" style="font-size:.7rem;">Tự động tính toán từ Cân nặng & Chiều cao</div>
              </div>

              <%-- Hàng 2: Huyết áp tâm thu, HA tâm trương, Mạch, Nhiệt độ --%>
              <div class="col-md-3">
                <label class="form-label small fw-semibold">HA tâm thu (mmHg)</label>
                <input type="number" name="systolicBP" class="form-control form-control-sm" value="${not empty record.bloodPressure?fn:split(record.bloodPressure,'/')[0]:''}" placeholder="VD: 120 (50–250)">
                <div class="form-text text-muted" style="font-size:.7rem;">Gợi ý: từ 50 đến 250 mmHg</div>
              </div>
              <div class="col-md-3">
                <label class="form-label small fw-semibold">HA tâm trương (mmHg)</label>
                <input type="number" name="diastolicBP" class="form-control form-control-sm" value="${not empty record.bloodPressure?fn:split(record.bloodPressure,'/')[1]:''}" placeholder="VD: 80 (30–150)">
                <div class="form-text text-muted" style="font-size:.7rem;">Gợi ý: từ 30 đến 150 mmHg</div>
              </div>
              <div class="col-md-3">
                <label class="form-label small fw-semibold">Mạch (bpm)</label>
                <input type="number" name="pulseBpm" class="form-control form-control-sm" value="${record.pulseBpm}" placeholder="VD: 80 (30–250)">
                <div class="form-text text-muted" style="font-size:.7rem;">Gợi ý: từ 30 đến 250 bpm</div>
              </div>
              <div class="col-md-3">
                <label class="form-label small fw-semibold">Nhiệt độ (°C)</label>
                <input type="number" step="0.1" name="temperatureC" class="form-control form-control-sm" value="${record.temperatureC}" placeholder="VD: 36.5 (34.0–43.0)">
                <div class="form-text text-muted" style="font-size:.7rem;">Gợi ý: từ 34.0 đến 43.0 °C</div>
              </div>

              <%-- Hàng 3: Kinh cuối (LMP), Tuổi thai tuần, Tuổi thai ngày --%>
              <div class="col-md-4">
                <label class="form-label small fw-semibold">Kinh cuối (LMP)</label>
                <input type="date" name="lastMenstrualPeriod" class="form-control form-control-sm" value="${record.lastMenstrualPeriod}">
                <div class="form-text text-muted" style="font-size:.7rem;">Gợi ý: chọn ngày trước hoặc bằng ngày khám</div>
              </div>
              <div class="col-md-4">
                <label class="form-label small fw-semibold">Tuổi thai (tuần)</label>
                <input type="number" name="gestationalAgeWeeks" class="form-control form-control-sm" value="${record.gestationalAgeWeeks}" placeholder="VD: 12 (0–44 tuần)">
                <div class="form-text text-muted" style="font-size:.7rem;">Gợi ý: từ 0 đến 44 tuần</div>
              </div>
              <div class="col-md-4">
                <label class="form-label small fw-semibold">Tuổi thai (ngày lẻ)</label>
                <input type="number" name="gestationalAgeDays" class="form-control form-control-sm" value="${record.gestationalAgeDays}" placeholder="VD: 3 (0–6 ngày)">
                <div class="form-text text-muted" style="font-size:.7rem;">Gợi ý: từ 0 đến 6 ngày lẻ</div>
              </div>

              <%-- Hàng 4: Ghi chú khám lâm sàng --%>
              <div class="col-12">
                <label class="form-label small fw-semibold">Ghi chú khám lâm sàng</label>
                <textarea name="clinicalNotes" class="form-control form-control-sm" rows="2" placeholder="VD: Bệnh nhân tỉnh táo, đau nhẹ vùng hạ vị, không có dấu hiệu bất thường...">${record.clinicalNotes}</textarea>
              </div>

              <%-- Hàng 5: Điều trị / Hướng xử trí --%>
              <div class="col-12">
                <label class="form-label small fw-semibold">Điều trị / Hướng xử trí</label>
                <textarea name="treatmentPlan" class="form-control form-control-sm" rows="2" placeholder="VD: Khám định kỳ, nghỉ ngơi, dặn dò chế độ dinh dưỡng...">${record.treatmentPlan}</textarea>
              </div>
            </div>
            <div class="d-flex justify-content-between align-items-center mt-3 pt-2 border-top">
              <c:if test="${record.id>0}"><span class="small text-success"><i class="bi bi-check-circle me-1"></i>Đã lưu nháp — có thể chỉnh sửa lại</span></c:if>
              <c:if test="${record.id==0}"><span class="small text-muted">Vui lòng điền thông tin và Lưu nháp</span></c:if>
              <button type="button" class="btn btn-primary btn-sm rounded-pill px-4" onclick="doSubmit('draft')"><i class="bi bi-save me-1"></i>Lưu nháp</button>
            </div>
          </div>
        </div>

        <%-- ═══ STEP 2: Chỉ định siêu âm (hiện sau khi lưu nháp) ═══ --%>
        <c:if test="${record.id > 0}">
          <c:choose>
            <c:when test="${hasBlockingUltrasound}">
              <%-- WAITING STATE --%>
              <div class="step-card step-locked" id="stepWait">
                <div class="step-header"><span class="step-num">⏳</span><h6 class="mb-0">Đang chờ kết quả siêu âm</h6></div>
                <div class="step-body text-center py-3">
                  <p class="text-warning mb-2"><i class="bi bi-hourglass-split me-1"></i>Bệnh nhân đã được chỉ định siêu âm. Vui lòng đợi bác sĩ siêu âm hoàn tất và trả kết quả.</p>
                  <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${apptId}" class="btn btn-outline-primary btn-sm"><i class="bi bi-arrow-clockwise me-1"></i>Tải lại kiểm tra</a>
                </div>
              </div>
            </c:when>
            <c:otherwise>
              <%-- DECISION --%>
              <c:set var="step2Class" value="${existingUltrasoundOrders?'step-done':'step-active'}"/>
              <div class="step-card ${step2Class}" id="step2">
                <div class="step-header"><span class="step-num"><i class="bi bi-ui-checks"></i></span><h6 class="mb-0">Chỉ định cận lâm sàng</h6><c:if test="${existingUltrasoundOrders}"><span class="badge bg-success ms-2">Đã chỉ định</span></c:if></div>
                <div class="step-body">
                  <c:if test="${existingUltrasoundOrders}">
                    <p class="small text-muted"><i class="bi bi-check-circle text-success me-1"></i>Đã tạo chỉ định siêu âm. Có thể huỷ nếu cần.</p>
                  </c:if>
                  <c:if test="${!existingUltrasoundOrders}">
                    <div class="alert alert-light border mb-2"><i class="bi bi-info-circle me-1"></i>Quyết định: Bệnh nhân có cần siêu âm không?</div>
                  </c:if>
                  <div class="d-flex flex-wrap gap-2">
                    <c:if test="${existingUltrasoundOrders}">
                      <button type="button" class="btn btn-sm btn-outline-danger" onclick="cancelUltrasound()">
                        <i class="bi bi-x-circle me-1"></i>Huỷ chỉ định siêu âm
                      </button>
                    </c:if>
                    <c:if test="${!existingUltrasoundOrders}">
                      <div class="d-flex gap-2 align-items-center">
                        <label class="form-check-label small me-2"><input type="checkbox" id="skipUltrasound" onchange="toggleUltrasoundForm()"> Không cần siêu âm</label>
                        <div id="ultrasoundForm" style="display:none;" class="d-flex flex-wrap gap-2 align-items-center">
                          <select name="ultrasoundServiceId" class="form-select form-select-sm" style="width:auto;">
                            <option value="">— Chọn dịch vụ —</option>
                            <c:forEach var="us" items="${ultrasoundServices}"><option value="${us.id}">${us.serviceName} — <fmt:formatNumber value="${us.price}" pattern="#,###"/>đ</option></c:forEach>
                          </select>
                          <input type="text" name="reorderReason" class="form-control form-control-sm" placeholder="Lý do chỉ định (≥5 ký tự)" style="width:220px;">
                          <button type="button" class="btn btn-sm btn-danger" onclick="submitUltrasound()"><i class="bi bi-send me-1"></i>Tạo chỉ định</button>
                        </div>
                      </div>
                      <input type="hidden" name="ultrasoundSkipped" id="ultrasoundSkipped" value="false">
                    </c:if>
                  </div>
                </div>
              </div>
            </c:otherwise>
          </c:choose>
        </c:if>

        <%-- ═══ STEP 4: Chẩn đoán & Kê đơn & Chốt (hiện sau khi siêu âm resolved hoặc skip) ═══ --%>
        <c:if test="${record.id > 0 && !hasBlockingUltrasound}">
          <div class="step-card ${step4Class}" id="step4" style="${!existingUltrasoundOrders ? 'display:none;' : ''}">
            <div class="step-header">
              <span class="step-num bg-primary text-white me-2"><i class="bi bi-prescription2 fs-5"></i></span>
              <h6 class="mb-0 fw-bold fs-6">Chẩn đoán &amp; Kê đơn</h6>
              <c:if test="${examStage=='READY_TO_FINALIZE'}"><span class="badge bg-success ms-2">Sẵn sàng chốt</span></c:if>
            </div>
            <div class="step-body">
              <%-- Ultrasound results banner & view modal button --%>
              <c:if test="${existingUltrasoundOrders}">
                <div class="alert alert-success d-flex justify-content-between align-items-center mb-3 py-2 px-3 rounded-3 shadow-sm">
                  <div class="d-flex align-items-center">
                    <i class="bi bi-check-circle-fill text-success fs-4 me-2"></i>
                    <div>
                      <strong class="text-success">Kết quả siêu âm đã hoàn thành!</strong>
                      <div class="small text-muted">Bác sĩ có thể xem hình ảnh &amp; nhận xét chuyên môn để đưa ra chẩn đoán.</div>
                    </div>
                  </div>
                  <button type="button" class="btn btn-sm btn-success rounded-pill px-3 flex-shrink-0 ms-3 fw-semibold shadow-sm"
                          data-bs-toggle="modal" data-bs-target="#ultrasoundResultModal"
                          onclick="document.getElementById('usResultIframe').src='${pageContext.request.contextPath}/doctor/results?recordId=${record.id}&amp;embed=true';">
                    <i class="bi bi-eye-fill me-1"></i>Xem kết quả siêu âm
                  </button>
                </div>
              </c:if>

              <%-- Diagnosis --%>
              <div class="mb-3">
                <label class="form-label small fw-bold text-dark"><i class="bi bi-stethoscope me-1 text-primary"></i>Chẩn đoán lâm sàng <span class="text-danger">*</span></label>
                <textarea name="finalDiagnosis" id="finalDiagnosis" class="form-control form-control-sm rounded-3" rows="3" required placeholder="VD: Viêm dạ dày cấp / Thai 12 tuần phát triển bình thường (tối đa 1000 ký tự)...">${record.finalDiagnosis}</textarea>
                <div class="form-text text-muted" style="font-size:.72rem;">Gợi ý: Nhập chẩn đoán lâm sàng của bác sĩ (bắt buộc khi chốt hồ sơ, tối đa 1000 ký tự)</div>
              </div>

              <%-- Prescription --%>
              <div class="mb-3">
                <label class="form-label small fw-bold text-dark"><i class="bi bi-capsule me-1 text-primary"></i>Kê đơn thuốc</label>
                <div id="rxContainer" class="p-3 bg-light rounded-3 border">
                  <div class="d-flex flex-column gap-2 mb-2" id="rxMedicineRows">
                    <c:if test="${not empty prescription}">
                      <c:forEach var="pi" items="${prescription.items}" varStatus="rxLoop">
                        <div class="rx-medicine-row d-flex gap-2 align-items-center w-100 p-2 bg-white rounded-3 border shadow-sm">
                          <div style="flex:4; min-width:200px;">
                            <select name="medicineId" class="form-select form-select-sm" required>
                              <option value="">— Chọn biệt dược / thuốc —</option>
                              <c:forEach var="m" items="${medicines}">
                                <option value="${m.id}" ${m.id==pi.medicineId?'selected':''}>${m.name} (${m.unit})</option>
                              </c:forEach>
                            </select>
                          </div>
                          <div style="flex:1.5; min-width:90px;">
                            <input type="number" name="quantity" class="form-control form-control-sm" placeholder="SL" min="1" max="9999" value="${pi.quantity}" required>
                          </div>
                          <div style="flex:5; min-width:220px;">
                            <input type="text" name="dosage" class="form-control form-control-sm" placeholder="Liều dùng (VD: 1 viên/lần, 2 lần/ngày sau ăn)" value="${pi.dosage}" required>
                          </div>
                          <div>
                            <button type="button" class="btn btn-sm btn-outline-danger border-0 rounded-circle" onclick="this.closest('.rx-medicine-row').remove()" title="Xóa thuốc này">
                              <i class="bi bi-x-circle-fill fs-6"></i>
                            </button>
                          </div>
                        </div>
                      </c:forEach>
                    </c:if>
                  </div>
                  <button type="button" class="btn btn-sm btn-outline-primary rounded-pill px-3" onclick="addRxRow()">
                    <i class="bi bi-plus-circle-fill me-1"></i>Thêm thuốc
                  </button>
                </div>
              </div>

              <%-- Finalize button --%>
              <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                <span class="small text-muted"><i class="bi bi-info-circle me-1"></i>Kiểm tra kỹ chẩn đoán và đơn thuốc trước khi chốt</span>
                <button type="button" class="btn btn-success btn-sm rounded-pill px-4 py-2 fw-bold shadow-sm" onclick="confirmFinalize()">
                  <i class="bi bi-check-circle-fill me-1"></i>Chốt hồ sơ &amp; Hoàn tất khám
                </button>
              </div>
            </div>
          </div>
        </c:if>

        <c:if test="${examStage == 'FINALIZED'}">
          <div class="step-card step-done"><div class="step-header"><span class="step-num bg-success text-white">✓</span><h6 class="mb-0 fw-bold">Đã hoàn tất</h6></div><div class="step-body"><p class="text-muted mb-0">Hồ sơ này đã được chốt. <a href="${pageContext.request.contextPath}/doctor/appointments">Quay lại lịch hẹn</a></p></div></div>
        </c:if>
      </form>
      </c:otherwise>
    </c:choose>
    </div>
  </div>
</c:if>

<%-- Modal Xem Kết Quả Siêu Âm Trực Tiếp Trên Tránh Chuyển Trang --%>
<div class="modal fade" id="ultrasoundResultModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl">
    <div class="modal-content rounded-4 border-0 shadow-lg overflow-hidden">
      <div class="modal-header border-0 bg-primary text-white py-2.5 px-3 d-flex align-items-center justify-content-between">
        <h6 class="modal-title fw-bold text-white mb-0 d-flex align-items-center">
          <i class="bi bi-soundwave me-2 fs-5"></i>KẾT QUẢ SIÊU ÂM CẬN LÂM SÀNG
        </h6>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0" style="background:#f8fafc;">
        <iframe id="usResultIframe" src="" style="width:100%;height:78vh;border:none;"></iframe>
      </div>
    </div>
  </div>
</div>

<%-- Template cho dòng kê đơn thuốc mới --%>
<template id="rxRowTemplate">
  <div class="rx-medicine-row d-flex gap-2 align-items-center w-100 p-2 bg-white rounded-3 border shadow-sm">
    <div style="flex:4; min-width:200px;">
      <select name="medicineId" class="form-select form-select-sm">
        <option value="">— Chọn biệt dược / thuốc —</option>
        <c:forEach var="m" items="${medicines}">
          <option value="${m.id}"><c:out value="${m.name}"/> (<c:out value="${m.unit}"/>)</option>
        </c:forEach>
      </select>
    </div>
    <div style="flex:1.5; min-width:90px;">
      <input type="number" name="quantity" class="form-control form-control-sm" placeholder="SL" min="1" max="9999">
    </div>
    <div style="flex:5; min-width:220px;">
      <input type="text" name="dosage" class="form-control form-control-sm" placeholder="Liều dùng (VD: 1 viên/lần, 2 lần/ngày sau ăn)">
    </div>
    <div>
      <button type="button" class="btn btn-sm btn-outline-danger border-0 rounded-circle" onclick="this.closest('.rx-medicine-row').remove()" title="Xóa thuốc này">
        <i class="bi bi-x-circle-fill fs-6"></i>
      </button>
    </div>
  </div>
</template>

<%-- ═══════ SCRIPTS ═══════ --%>
<c:if test="${mode == 'form' && canEditRecord}">
<script>
function calcBMI(){var w=parseFloat(document.querySelector('[name=weightKg]')?.value);var h=parseFloat(document.querySelector('[name=heightCm]')?.value);var el=document.getElementById('bmiDisplay');if(w&&h&&h>0){el.value=(w/((h/100)*(h/100))).toFixed(1);}else{el.value='';}}
function doSubmit(action){document.getElementById('submitAction').value=action;document.getElementById('mainForm').submit();}
function toggleUltrasoundForm(){var isSkipped=document.getElementById('skipUltrasound').checked;document.getElementById('ultrasoundForm').style.display=isSkipped?'none':'flex';document.getElementById('ultrasoundSkipped').value=isSkipped?'true':'false';var s4=document.getElementById('step4');if(s4){s4.style.display=isSkipped?'block':'none';}}
function submitUltrasound(){var sel=document.querySelector('[name=ultrasoundServiceId]');var reason=document.querySelector('[name=reorderReason]');if(!sel.value){alert('Vui lòng chọn dịch vụ siêu âm.');return;}if(!reason.value||reason.value.length<5){alert('Vui lòng nhập lý do chỉ định (ít nhất 5 ký tự).');return;}var f=document.createElement('form');f.method='POST';f.action='${pageContext.request.contextPath}/doctor/ultrasound-request';var csrf=document.createElement('input');csrf.type='hidden';csrf.name='_csrf';csrf.value='${sessionScope.csrfToken}';f.appendChild(csrf);['apptId=${apptId}','recordId=${record.id}','action=create'].forEach(function(p){var kv=p.split('=');var i=document.createElement('input');i.type='hidden';i.name=kv[0];i.value=kv[1];f.appendChild(i);});var sid=document.createElement('input');sid.type='hidden';sid.name='serviceId';sid.value=sel.value;f.appendChild(sid);var rr=document.createElement('input');rr.type='hidden';rr.name='reorderReason';rr.value=reason.value;f.appendChild(rr);document.body.appendChild(f);f.submit();}
function cancelUltrasound(){
    var r=prompt('Nhập lý do huỷ chỉ định siêu âm (10-500 ký tự):');
    if(!r||r.length<10){alert('Lý do phải từ 10 ký tự.');return;}
    if(!confirm('Bạn có chắc muốn HUỶ chỉ định siêu âm này? Hành động này không thể hoàn tác.')) return;
    var f=document.createElement('form');f.method='POST';f.action='${pageContext.request.contextPath}/doctor/ultrasound-request';
    var csrf=document.createElement('input');csrf.type='hidden';csrf.name='_csrf';csrf.value='${sessionScope.csrfToken}';f.appendChild(csrf);
    ['action=cancel','apptId=${apptId}','orderId=${record.id}','reason='+encodeURIComponent(r)].forEach(function(p){var kv=p.split('=');var i=document.createElement('input');i.type='hidden';i.name=kv[0];i.value=kv.slice(1).join('=');f.appendChild(i);});
    document.body.appendChild(f);f.submit();
}
function addRxRow(){
    var container = document.getElementById('rxMedicineRows');
    var tmpl = document.getElementById('rxRowTemplate');
    if (container && tmpl) {
        var clone = tmpl.content.cloneNode(true);
        container.appendChild(clone);
    }
}
function confirmFinalize(){
    var diagEl = document.getElementById('finalDiagnosis');
    var diag = diagEl ? diagEl.value.trim() : '';
    if(!diag){
        alert('Vui lòng nhập chẩn đoán trước khi chốt hồ sơ.');
        if (diagEl) diagEl.focus();
        return;
    }
    if(!confirm('Xác nhận CHỐT HỒ SƠ và HOÀN TẤT KHÁM? Hành động này không thể hoàn tác.')) return;
    doSubmit('final');
}
calcBMI();
document.querySelectorAll('.risk-check').forEach(function(cb){cb.addEventListener('change',function(){var box=document.getElementById('riskBox');var any=document.querySelectorAll('.risk-check:checked').length>0;box.className='risk-box'+(any?' active':'');});});
</script>
</c:if>

<%@ include file="../common/footer.jsp" %>
