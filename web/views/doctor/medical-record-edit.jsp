<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} — CAMS Doctor</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <style>
        :root {
            --sidebar-w: 260px;
            --topbar-h: 66px;
            --blue-50: #eff6ff;
        }
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Be Vietnam Pro', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .layout { display: flex; min-height: 100vh; }

        /* ── Sidebar ── */
        .sidebar { width: var(--sidebar-w); min-width: var(--sidebar-w); background: linear-gradient(180deg, #1565c0 0%, #0d47a1 100%); color: #fff; position: fixed; top: 0; left: 0; bottom: 0; overflow-y: auto; z-index: 1000; padding: 20px 0; }
        .sidebar .logo { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 10px; }
        .sidebar .logo h4 { font-size: 1.1rem; font-weight: 600; margin: 0; }
        .sidebar .nav-item a { display: flex; align-items: center; gap: 10px; padding: 12px 20px; color: rgba(255,255,255,0.85); text-decoration: none; font-size: 0.9rem; transition: all 0.2s; border-left: 3px solid transparent; }
        .sidebar .nav-item a:hover, .sidebar .nav-item a.active { background: rgba(255,255,255,0.12); color: #fff; border-left-color: #fff; }

        /* ── Main ── */
        .main { margin-left: var(--sidebar-w); flex: 1; padding: 24px; background: var(--blue-50); min-height: 100vh; }
        .topbar { display: flex; justify-content: space-between; align-items: center; background: #fff; padding: 0 24px; height: var(--topbar-h); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,0.06); margin-bottom: 24px; }
        .content-card { background: #fff; border-radius: 12px; box-shadow: 0 1px 6px rgba(0,0,0,0.06); padding: 28px; margin-bottom: 24px; }

        /* ── Form ── */
        .section-title { font-weight: 600; font-size: 1rem; color: #1565c0; border-bottom: 2px solid #1565c0; padding-bottom: 8px; margin-bottom: 16px; margin-top: 24px; }
        .section-title:first-child { margin-top: 0; }
        .section-title i { margin-right: 8px; }
        .form-label { font-weight: 500; font-size: 0.85rem; color: #495057; margin-bottom: 4px; }
        .form-control:focus, .form-select:focus { border-color: #1565c0; box-shadow: 0 0 0 0.2rem rgba(21,101,192,0.15); }
        .info-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-weight: 500; font-size: 0.8rem; }
        .info-badge.patient { background: #e3f2fd; color: #1565c0; }
        .info-badge.appointment { background: #e8f5e9; color: #2e7d32; }
        .info-badge.record { background: #fff3e0; color: #e65100; }

        /* ── Toolbar ── */
        .toolbar { display: flex; gap: 10px; justify-content: flex-end; margin-top: 24px; padding-top: 20px; border-top: 1px solid #e9ecef; }
        .toolbar .btn { min-width: 140px; }
        .char-counter { font-size: 0.75rem; color: #6c757d; text-align: right; margin-top: 2px; }

        @media (max-width: 768px) {
            .sidebar { width: 100%; min-width: 100%; position: relative; height: auto; }
            .main { margin-left: 0; }
            .row-cols-md-2 > * { width: 100%; }
        }
    </style>
</head>
<body>
<div class="layout">

    <!-- ═══════════════ SIDEBAR ═══════════════ -->
    <aside class="sidebar">
        <div class="logo">
            <h4><i class="bi bi-heart-pulse"></i> CAMS Doctor</h4>
        </div>
        <nav>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/doctor/dashboard">
                    <i class="bi bi-speedometer2"></i> Dashboard
                </a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/doctor/medical-records" class="active">
                    <i class="bi bi-file-medical"></i> Bệnh Án
                </a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/doctor/prescriptions">
                    <i class="bi bi-prescription2"></i> Đơn Thuốc
                </a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/doctor/upload">
                    <i class="bi bi-camera"></i> Upload Siêu Âm
                </a>
            </div>
            <div class="nav-item mt-4">
                <a href="${pageContext.request.contextPath}/logout">
                    <i class="bi bi-box-arrow-right"></i> Đăng Xuất
                </a>
            </div>
        </nav>
    </aside>

    <!-- ═══════════════ MAIN ═══════════════ -->
    <main class="main">

        <!-- Top Bar -->
        <div class="topbar">
            <div>
                <h5 class="mb-0 fw-bold">${pageTitle}</h5>
            </div>
            <div class="d-flex align-items-center gap-3">
                <span class="text-muted small">
                    <i class="bi bi-person-circle"></i> ${sessionScope.user.fullName}
                </span>
            </div>
        </div>

        <!-- Flash Messages -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> ${successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle"></i> ${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Record Info Header -->
        <div class="content-card">
            <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
                <span class="info-badge record">
                    <i class="bi bi-file-medical"></i> Bệnh án #${record.id}
                </span>
                <span class="info-badge patient">
                    <i class="bi bi-person"></i> BN: ${fn:escapeXml(patientName)}
                </span>
                <c:if test="${not empty appointmentId}">
                    <span class="info-badge appointment">
                        <i class="bi bi-calendar-check"></i> Lịch hẹn #${appointmentId}
                    </span>
                </c:if>
                <c:if test="${not empty record.createdAt}">
                    <span class="text-muted small ms-auto">
                        <i class="bi bi-clock"></i> Tạo: ${record.createdAt}
                    </span>
                </c:if>
            </div>
        </div>

        <!-- ═══════════════ EDIT FORM ═══════════════ -->
        <form method="POST" action="${pageContext.request.contextPath}/doctor/medical-records" id="medicalRecordForm">
            <input type="hidden" name="id" value="${record.id}">

            <div class="content-card">

                <!-- ── SECTION 1: DẤU HIỆU SINH TỒN ── -->
                <h6 class="section-title"><i class="bi bi-heart-pulse"></i> Dấu hiệu sinh tồn</h6>
                <div class="row g-3">
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Cân nặng (kg)</label>
                        <input type="number" step="0.1" class="form-control form-control-sm"
                               name="weightKg" value="${record.weightKg}"
                               placeholder="VD: 62.5" data-field="weightKg">
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Huyết áp</label>
                        <input type="text" class="form-control form-control-sm"
                               name="bloodPressure" value="${fn:escapeXml(record.bloodPressure)}"
                               placeholder="VD: 120/80" data-field="bloodPressure">
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Mạch (bpm)</label>
                        <input type="number" class="form-control form-control-sm"
                               name="pulseBpm" value="${record.pulseBpm}"
                               placeholder="VD: 80" data-field="pulseBpm">
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Nhiệt độ (°C)</label>
                        <input type="number" step="0.1" class="form-control form-control-sm"
                               name="temperatureC" value="${record.temperatureC}"
                               placeholder="VD: 37.0" data-field="temperatureC">
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Chiều cao (cm)</label>
                        <input type="number" step="0.1" class="form-control form-control-sm"
                               name="heightCm" value="${record.heightCm}"
                               placeholder="VD: 160" data-field="heightCm">
                    </div>
                </div>

                <!-- ── SECTION 2: THAI KỲ ── -->
                <h6 class="section-title"><i class="bi bi-people"></i> Thai kỳ</h6>
                <div class="row g-3">
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Tuổi thai (tuần)</label>
                        <input type="number" class="form-control form-control-sm"
                               name="gestationalAgeWeeks" value="${record.gestationalAgeWeeks}"
                               placeholder="VD: 32" data-field="gestationalAgeWeeks">
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Ngày lẻ</label>
                        <input type="number" class="form-control form-control-sm"
                               name="gestationalAgeDays" value="${record.gestationalAgeDays}"
                               placeholder="VD: 3" data-field="gestationalAgeDays">
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Cao tử cung (cm)</label>
                        <input type="number" step="0.1" class="form-control form-control-sm"
                               name="fundalHeightCm" value="${record.fundalHeightCm}"
                               placeholder="VD: 30" data-field="fundalHeightCm">
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Tim thai (bpm)</label>
                        <input type="number" class="form-control form-control-sm"
                               name="fetalHeartRate" value="${record.fetalHeartRate}"
                               placeholder="VD: 140" data-field="fetalHeartRate">
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Ngôi thai</label>
                        <select class="form-select form-select-sm" name="fetalPresentation" data-field="fetalPresentation">
                            <option value="">-- Chọn --</option>
                            <option value="Ngôi đầu" ${record.fetalPresentation == 'Ngôi đầu' ? 'selected' : ''}>Ngôi đầu</option>
                            <option value="Ngôi mông" ${record.fetalPresentation == 'Ngôi mông' ? 'selected' : ''}>Ngôi mông</option>
                            <option value="Ngôi ngang" ${record.fetalPresentation == 'Ngôi ngang' ? 'selected' : ''}>Ngôi ngang</option>
                        </select>
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Vị trí thai</label>
                        <select class="form-select form-select-sm" name="fetalPosition" data-field="fetalPosition">
                            <option value="">-- Chọn --</option>
                            <option value="Trái" ${record.fetalPosition == 'Trái' ? 'selected' : ''}>Trái</option>
                            <option value="Phải" ${record.fetalPosition == 'Phải' ? 'selected' : ''}>Phải</option>
                            <option value="Trung tâm" ${record.fetalPosition == 'Trung tâm' ? 'selected' : ''}>Trung tâm</option>
                        </select>
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Cử động thai</label>
                        <select class="form-select form-select-sm" name="fetalMovement" data-field="fetalMovement">
                            <option value="">-- Chọn --</option>
                            <option value="Bình thường" ${record.fetalMovement == 'Bình thường' ? 'selected' : ''}>Bình thường</option>
                            <option value="Nhiều" ${record.fetalMovement == 'Nhiều' ? 'selected' : ''}>Nhiều</option>
                            <option value="Ít" ${record.fetalMovement == 'Ít' ? 'selected' : ''}>Ít</option>
                            <option value="Không rõ" ${record.fetalMovement == 'Không rõ' ? 'selected' : ''}>Không rõ</option>
                        </select>
                    </div>
                </div>

                <!-- ── SECTION 3: CỔ TỬ CUNG & ỐI ── -->
                <h6 class="section-title"><i class="bi bi-gender-female"></i> Cổ tử cung &amp; Ối</h6>
                <div class="row g-3">
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Độ mở CTC (cm)</label>
                        <input type="number" step="0.1" class="form-control form-control-sm"
                               name="cervicalDilationCm" value="${record.cervicalDilationCm}"
                               placeholder="VD: 3.0" data-field="cervicalDilationCm">
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Độ xóa CTC</label>
                        <select class="form-select form-select-sm" name="cervicalEffacement" data-field="cervicalEffacement">
                            <option value="">-- Chọn --</option>
                            <option value="0%" ${record.cervicalEffacement == '0%' ? 'selected' : ''}>0%</option>
                            <option value="25%" ${record.cervicalEffacement == '25%' ? 'selected' : ''}>25%</option>
                            <option value="50%" ${record.cervicalEffacement == '50%' ? 'selected' : ''}>50%</option>
                            <option value="75%" ${record.cervicalEffacement == '75%' ? 'selected' : ''}>75%</option>
                            <option value="100%" ${record.cervicalEffacement == '100%' ? 'selected' : ''}>100%</option>
                        </select>
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Nước ối</label>
                        <select class="form-select form-select-sm" name="amnioticFluid" data-field="amnioticFluid">
                            <option value="">-- Chọn --</option>
                            <option value="Bình thường" ${record.amnioticFluid == 'Bình thường' ? 'selected' : ''}>Bình thường</option>
                            <option value="Thiểu ối" ${record.amnioticFluid == 'Thiểu ối' ? 'selected' : ''}>Thiểu ối</option>
                            <option value="Đa ối" ${record.amnioticFluid == 'Đa ối' ? 'selected' : ''}>Đa ối</option>
                        </select>
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Lọt ngôi</label>
                        <select class="form-select form-select-sm" name="presentationStation" data-field="presentationStation">
                            <option value="">-- Chọn --</option>
                            <option value="-3" ${record.presentationStation == '-3' ? 'selected' : ''}>-3 (Cao)</option>
                            <option value="-2" ${record.presentationStation == '-2' ? 'selected' : ''}>-2</option>
                            <option value="-1" ${record.presentationStation == '-1' ? 'selected' : ''}>-1</option>
                            <option value="0" ${record.presentationStation == '0' ? 'selected' : ''}>0 (Ngang gai)</option>
                            <option value="+1" ${record.presentationStation == '+1' ? 'selected' : ''}>+1</option>
                            <option value="+2" ${record.presentationStation == '+2' ? 'selected' : ''}>+2</option>
                            <option value="+3" ${record.presentationStation == '+3' ? 'selected' : ''}>+3 (Thấp)</option>
                        </select>
                    </div>
                </div>

                <!-- ── SECTION 4: TRIỆU CHỨNG ── -->
                <h6 class="section-title"><i class="bi bi-clipboard2-pulse"></i> Triệu chứng</h6>
                <div class="row g-3">
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Phù</label>
                        <select class="form-select form-select-sm" name="edema" data-field="edema">
                            <option value="">-- Chọn --</option>
                            <option value="Không" ${record.edema == 'Không' ? 'selected' : ''}>Không</option>
                            <option value="Nhẹ" ${record.edema == 'Nhẹ' ? 'selected' : ''}>Nhẹ</option>
                            <option value="Vừa" ${record.edema == 'Vừa' ? 'selected' : ''}>Vừa</option>
                            <option value="Nặng" ${record.edema == 'Nặng' ? 'selected' : ''}>Nặng</option>
                        </select>
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Protein niệu</label>
                        <select class="form-select form-select-sm" name="proteinuria" data-field="proteinuria">
                            <option value="">-- Chọn --</option>
                            <option value="Âm tính" ${record.proteinuria == 'Âm tính' ? 'selected' : ''}>Âm tính (-)</option>
                            <option value="Vết" ${record.proteinuria == 'Vết' ? 'selected' : ''}>Vết (±)</option>
                            <option value="1+" ${record.proteinuria == '1+' ? 'selected' : ''}>1+</option>
                            <option value="2+" ${record.proteinuria == '2+' ? 'selected' : ''}>2+</option>
                            <option value="3+" ${record.proteinuria == '3+' ? 'selected' : ''}>3+</option>
                            <option value="4+" ${record.proteinuria == '4+' ? 'selected' : ''}>4+</option>
                        </select>
                    </div>
                    <div class="col-md-2 col-sm-4 d-flex align-items-end">
                        <div class="form-check mb-2">
                            <input class="form-check-input" type="checkbox" id="vaginalBleeding"
                                   name="vaginalBleeding" value="true"
                                   ${record.vaginalBleeding ? 'checked' : ''} data-field="vaginalBleeding">
                            <label class="form-check-label" for="vaginalBleeding">Chảy máu âm đạo</label>
                        </div>
                    </div>
                    <div class="col-md-2 col-sm-4 d-flex align-items-end">
                        <div class="form-check mb-2">
                            <input class="form-check-input" type="checkbox" id="uterineContractions"
                                   name="uterineContractions" value="true"
                                   ${record.uterineContractions ? 'checked' : ''} data-field="uterineContractions">
                            <label class="form-check-label" for="uterineContractions">Co thắt tử cung</label>
                        </div>
                    </div>
                </div>

                <!-- ── SECTION 5: CHẨN ĐOÁN & ĐIỀU TRỊ (QUAN TRỌNG NHẤT) ── -->
                <h6 class="section-title"><i class="bi bi-journal-medical"></i> Chẩn đoán &amp; Điều trị
                    <small class="text-danger fw-normal">(Các trường quan trọng — Audit Log sẽ ghi chi tiết)</small>
                </h6>
                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label">Ghi chú lâm sàng <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="clinicalNotes" rows="4"
                                  placeholder="Nhập ghi chú lâm sàng chi tiết..."
                                  data-field="clinicalNotes" id="clinicalNotes"
                        ><c:out value="${record.clinicalNotes}"/></textarea>
                        <div class="char-counter"><span id="clinicalNotesCount">0</span> ký tự</div>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Chẩn đoán cuối cùng <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="finalDiagnosis" rows="3"
                                  placeholder="Nhập chẩn đoán cuối cùng..."
                                  data-field="finalDiagnosis" id="finalDiagnosis"
                        ><c:out value="${record.finalDiagnosis}"/></textarea>
                        <div class="char-counter"><span id="finalDiagnosisCount">0</span> ký tự</div>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Kế hoạch điều trị</label>
                        <textarea class="form-control" name="treatmentPlan" rows="3"
                                  placeholder="Nhập kế hoạch điều trị..."
                                  data-field="treatmentPlan" id="treatmentPlan"
                        ><c:out value="${record.treatmentPlan}"/></textarea>
                        <div class="char-counter"><span id="treatmentPlanCount">0</span> ký tự</div>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Cờ nguy cơ (JSON)</label>
                        <textarea class="form-control" name="riskFlagsJson" rows="2"
                                  placeholder='VD: {"pre_eclampsia":true,"gestational_diabetes":false}'
                                  data-field="riskFlagsJson" id="riskFlagsJson"
                        ><c:out value="${record.riskFlagsJson}"/></textarea>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <label class="form-label">Ngày hẹn tái khám</label>
                        <input type="date" class="form-control form-control-sm"
                               name="nextAppointmentDate" value="${record.nextAppointmentDate}"
                               data-field="nextAppointmentDate">
                    </div>
                    <div class="col-md-4 col-sm-6">
                        <label class="form-label">Giới thiệu đến</label>
                        <input type="text" class="form-control form-control-sm"
                               name="referredTo" value="${fn:escapeXml(record.referredTo)}"
                               placeholder="VD: BV Phụ Sản Trung Ương"
                               data-field="referredTo">
                    </div>
                    <div class="col-md-2 col-sm-4">
                        <label class="form-label">Trạng thái</label>
                        <select class="form-select form-select-sm" name="status" data-field="status">
                            <option value="draft" ${record.status == 'draft' ? 'selected' : ''}>Nháp</option>
                            <option value="final" ${record.status == 'final' || empty record.status ? 'selected' : ''}>Hoàn thiện</option>
                        </select>
                    </div>
                </div>

                <!-- ── Toolbar ── -->
                <div class="toolbar">
                    <button type="button" class="btn btn-outline-secondary"
                            onclick="history.back()">
                        <i class="bi bi-arrow-left"></i> Quay lại
                    </button>
                    <button type="reset" class="btn btn-outline-warning">
                        <i class="bi bi-arrow-counterclockwise"></i> Hoàn tác thay đổi
                    </button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-lg"></i> Lưu bệnh án
                    </button>
                </div>

            </div><!-- /content-card -->
        </form>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous">
</script>

<script>
    // ── Character counters cho textarea ──
    document.addEventListener('DOMContentLoaded', function() {
        const textareas = ['clinicalNotes', 'finalDiagnosis', 'treatmentPlan'];
        textareas.forEach(function(id) {
            const el = document.getElementById(id);
            const counter = document.getElementById(id + 'Count');
            if (el && counter) {
                counter.textContent = el.value.length;
                el.addEventListener('input', function() {
                    counter.textContent = this.value.length;
                });
            }
        });
    });

    // ── Confirm khi có thay đổi chưa lưu ──
    (function() {
        let formChanged = false;
        const form = document.getElementById('medicalRecordForm');
        const fields = form.querySelectorAll('[data-field]');

        // Track changes
        fields.forEach(function(field) {
            field.addEventListener('change', function() { formChanged = true; });
            field.addEventListener('input', function() { formChanged = true; });
        });

        // Reset button clears the flag
        form.addEventListener('reset', function() { formChanged = false; });

        // Confirm before leaving
        window.addEventListener('beforeunload', function(e) {
            if (formChanged) {
                e.preventDefault();
                e.returnValue = 'Bạn có thay đổi chưa lưu. Bạn có chắc muốn rời khỏi trang?';
                return e.returnValue;
            }
        });

        // Don't confirm on form submit
        form.addEventListener('submit', function() { formChanged = false; });

        // Don't confirm on sidebar links
        document.querySelectorAll('.sidebar a, .topbar a').forEach(function(link) {
            link.addEventListener('click', function() { formChanged = false; });
        });
    })();

    // ── Auto-resize textarea ──
    document.querySelectorAll('textarea').forEach(function(textarea) {
        textarea.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = (this.scrollHeight) + 'px';
        });
    });
</script>

</body>
</html>
