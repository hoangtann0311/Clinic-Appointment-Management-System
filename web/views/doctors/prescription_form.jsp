<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="../common/header.jsp" %>

<style>
.rx-table th  { font-size:.78rem; text-transform:uppercase; letter-spacing:.05em; color:#6c757d; }
.rx-table td  { vertical-align:middle; }
.med-select   { min-width:220px; }
.cat-badge    { font-size:.7rem; padding:.15rem .45rem; border-radius:20px;
                background:#e9ecef; color:#495057; white-space:nowrap; }
.info-label   { font-size:.7rem; text-transform:uppercase; color:#adb5bd;
                font-weight:600; letter-spacing:.05em; }
.info-val     { font-size:.95rem; font-weight:500; }
</style>

<%-- Thông báo lỗi --%>
<c:if test="${not empty errorMessage}">
    <div class="alert alert-danger rounded-3 mb-3">
        <i class="bi bi-exclamation-triangle me-2"></i>${errorMessage}
    </div>
</c:if>
<c:if test="${param.saved == '1'}">
    <div class="alert alert-success rounded-3 mb-3 d-flex align-items-center gap-2 alert-dismissible fade show">
        <i class="bi bi-check-circle-fill"></i>Đơn thuốc đã được lưu thành công!
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<%-- Banner --%>
<div class="card border-0 rounded-4 text-white mb-4" style="background:linear-gradient(135deg,#1565C0,#1976D2);">
    <div class="card-body p-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h2 class="fw-bold mb-1">
                <i class="bi bi-prescription2 me-2"></i>
                <c:choose>
                    <c:when test="${not empty prescription}">Cập nhật đơn thuốc</c:when>
                    <c:otherwise>Kê đơn thuốc mới</c:otherwise>
                </c:choose>
            </h2>
            <p class="mb-0 opacity-75">
                BS. ${doctorName}
                <c:if test="${not empty record}">
                    &mdash; Bệnh nhân: <strong>${record.patientName}</strong>
                    &mdash; Ngày khám: ${record.appointmentDate}
                </c:if>
            </p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${record.appointmentId}"
               class="btn btn-light btn-sm rounded-pill px-3">
                <i class="bi bi-journal-medical me-1"></i>Hồ sơ bệnh án
            </a>
            <a href="${pageContext.request.contextPath}/doctor/medical-records"
               class="btn btn-outline-light btn-sm rounded-pill px-3">
                <i class="bi bi-list me-1"></i>Danh sách
            </a>
        </div>
    </div>
</div>

<div class="row g-4">

    <%-- Cột trái: thông tin bệnh nhân & đơn --%>
    <div class="col-lg-3">
        <div class="card rounded-4 border-0 shadow-sm">
            <div class="card-body p-4">
                <div class="text-center mb-3">
                    <div class="rounded-circle bg-primary bg-opacity-10 text-primary fw-bold
                                d-flex align-items-center justify-content-center mx-auto mb-2"
                         style="width:52px;height:52px;font-size:1.2rem;">
                        ${fn:toUpperCase(fn:substring(record.patientName,0,1))}
                    </div>
                    <h6 class="fw-bold mb-0">${record.patientName}</h6>
                </div>
                <hr class="my-2">

                <div class="d-flex flex-column gap-2">
                    <div>
                        <div class="info-label">Ngày khám</div>
                        <div class="info-val"><i class="bi bi-calendar3 me-1 text-primary"></i>${record.appointmentDate}</div>
                    </div>
                    <div>
                        <div class="info-label">Giờ khám</div>
                        <div class="info-val"><i class="bi bi-clock me-1 text-primary"></i>
                            <c:out value="${not empty record.timeSlot ? record.timeSlot : '—'}"/>
                        </div>
                    </div>
                    <div>
                        <div class="info-label">Chẩn đoán</div>
                        <div class="p-2 rounded-3 small" style="background:#f0f4ff;">
                            <c:out value="${not empty record.finalDiagnosis ? record.finalDiagnosis : '(chưa có)'}"/>
                        </div>
                    </div>

                    <c:if test="${not empty prescription}">
                        <hr class="my-1">
                        <div>
                            <div class="info-label">Mã đơn thuốc</div>
                            <code class="small">${prescription.prescriptionCode}</code>
                        </div>
                        <div>
                            <div class="info-label">Trạng thái</div>
                            <span class="badge rounded-pill
                                <c:choose>
                                    <c:when test='${prescription.status == "issued"}'>bg-success</c:when>
                                    <c:when test='${prescription.status == "cancelled"}'>bg-danger</c:when>
                                    <c:otherwise>bg-secondary</c:otherwise>
                                </c:choose>">
                                <c:choose>
                                    <c:when test="${prescription.status == 'issued'}">Đã kê</c:when>
                                    <c:when test="${prescription.status == 'cancelled'}">Đã huỷ</c:when>
                                    <c:otherwise>${prescription.status}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div>
                            <div class="info-label">Ngày tạo</div>
                            <div class="small text-muted">${prescription.createdAt}</div>
                        </div>
                        <div>
                            <div class="info-label">Số loại thuốc</div>
                            <div class="info-val">${fn:length(prescription.items)} loại</div>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <%-- Cột phải: form kê đơn --%>
    <div class="col-lg-9">
        <div class="card rounded-4 border-0 shadow-sm">
            <div class="card-body p-4">
                <div class="d-flex align-items-center justify-content-between mb-4">
                    <h6 class="fw-semibold mb-0">
                        <i class="bi bi-capsule me-2 text-primary"></i>Danh sách thuốc kê đơn
                    </h6>
                    <%-- Thống kê nhanh --%>
                    <span class="badge bg-primary bg-opacity-10 text-primary rounded-pill" id="rowCount">
                        0 loại thuốc
                    </span>
                </div>

                <form method="post"
                      action="${pageContext.request.contextPath}/doctor/prescriptions"
                      id="prescriptionForm" novalidate>

                    <input type="hidden" name="recordId" value="${record.id}"/>
                    <c:if test="${not empty prescription}">
                        <input type="hidden" name="prescriptionId" value="${prescription.id}"/>
                    </c:if>

                    <%-- Bảng thuốc --%>
                    <div class="table-responsive mb-3">
                        <table class="table rx-table align-middle mb-0" id="medicineTable">
                            <thead class="table-light">
                                <tr>
                                    <th style="min-width:240px;">Tên thuốc</th>
                                    <th style="width:110px;">Số lượng</th>
                                    <th style="min-width:200px;">Liều dùng / Hướng dẫn</th>
                                    <th style="width:44px;"></th>
                                </tr>
                            </thead>
                            <tbody id="medicineRows">

                                <c:choose>
                                    <c:when test="${not empty prescription and not empty prescription.items}">
                                        <c:forEach var="item" items="${prescription.items}">
                                            <tr class="medicine-row">
                                                <td>
                                                    <select name="medicineId[]"
                                                            class="form-select form-select-sm rounded-3 med-select med-dropdown">
                                                        <option value="">— Chọn thuốc —</option>
                                                        <c:forEach var="med" items="${medicines}">
                                                            <option value="${med.id}"
                                                                    data-cat="${med.categoryName}"
                                                                    data-unit="${med.unit}"
                                                                    data-stock="${med.stockQuantity}"
                                                                    data-desc="${med.description}"
                                                                    <c:if test="${med.id == item.medicineId}">selected</c:if>>
                                                                ${med.name}<c:if test="${not empty med.categoryName}"> [${med.categoryName}]</c:if>
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                    <div class="med-desc-hint text-muted small mt-1" style="font-size:.75rem;"></div>
                                                </td>
                                                <td>
                                                    <div class="input-group input-group-sm">
                                                        <input type="number" name="quantity[]"
                                                               class="form-control rounded-start-3 text-center"
                                                               value="${item.quantity}" min="1" max="9999">
                                                        <span class="input-group-text unit-suffix rounded-end-3">${item.medicineUnit}</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <input type="text" name="dosage[]"
                                                           class="form-control form-control-sm rounded-3"
                                                           value="${item.dosage}"
                                                           placeholder="VD: 2 viên/ngày, sáng-tối">
                                                </td>
                                                <td class="text-center">
                                                    <button type="button"
                                                            class="btn btn-sm btn-outline-danger rounded-circle remove-row"
                                                            style="width:30px;height:30px;padding:0;">
                                                        <i class="bi bi-x"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <%-- Dòng rỗng mặc định --%>
                                        <tr class="medicine-row">
                                            <td>
                                                <select name="medicineId[]"
                                                        class="form-select form-select-sm rounded-3 med-select med-dropdown">
                                                    <option value="">— Chọn thuốc —</option>
                                                    <c:forEach var="med" items="${medicines}">
                                                        <option value="${med.id}"
                                                                data-cat="${med.categoryName}"
                                                                data-unit="${med.unit}"
                                                                data-stock="${med.stockQuantity}"
                                                                data-desc="${med.description}">
                                                            ${med.name}<c:if test="${not empty med.categoryName}"> [${med.categoryName}]</c:if>
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                                <div class="med-desc-hint text-muted small mt-1" style="font-size:.75rem;"></div>
                                            </td>
                                            <td>
                                                <div class="input-group input-group-sm">
                                                    <input type="number" name="quantity[]"
                                                           class="form-control rounded-start-3 text-center"
                                                           value="1" min="1" max="9999">
                                                    <span class="input-group-text unit-suffix rounded-end-3">—</span>
                                                </div>
                                            </td>
                                            <td>
                                                <input type="text" name="dosage[]"
                                                       class="form-control form-control-sm rounded-3"
                                                       placeholder="VD: 2 viên/ngày, sáng-tối">
                                            </td>
                                            <td class="text-center">
                                                <button type="button"
                                                        class="btn btn-sm btn-outline-danger rounded-circle remove-row"
                                                        style="width:30px;height:30px;padding:0;">
                                                    <i class="bi bi-x"></i>
                                                </button>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>

                            </tbody>
                        </table>
                    </div>

                    <button type="button" class="btn btn-outline-primary btn-sm rounded-3 mb-4" id="addRowBtn">
                        <i class="bi bi-plus-circle me-1"></i>Thêm thuốc
                    </button>

                    <div class="d-flex gap-3 align-items-center border-top pt-3 flex-wrap">
                        <button type="button" onclick="submitRx()" class="btn btn-primary rounded-3 px-4">
                            <i class="bi bi-floppy me-2"></i>
                            <c:choose>
                                <c:when test="${not empty prescription}">Cập nhật đơn thuốc</c:when>
                                <c:otherwise>Lưu đơn thuốc</c:otherwise>
                            </c:choose>
                        </button>
                        <a href="${pageContext.request.contextPath}/doctor/medical-records?apptId=${record.appointmentId}"
                           class="btn btn-outline-secondary rounded-3">Huỷ</a>
                        <span class="ms-auto text-muted small">
                            <i class="bi bi-info-circle me-1"></i>Lưu sẽ ghi đè toàn bộ danh sách thuốc hiện tại.
                        </span>
                    </div>

                </form>
            </div>
        </div>
    </div>
</div>

<%-- Template dòng thuốc (ẩn) — options được render server-side --%>
<template id="rowTemplate">
    <tr class="medicine-row">
        <td>
            <select name="medicineId[]" class="form-select form-select-sm rounded-3 med-select med-dropdown">
                <option value="">— Chọn thuốc —</option>
                <c:forEach var="med" items="${medicines}">
                    <option value="${med.id}"
                            data-cat="${med.categoryName}"
                            data-unit="${med.unit}"
                            data-stock="${med.stockQuantity}"
                            data-desc="${med.description}">
                        ${med.name}<c:if test="${not empty med.categoryName}"> [${med.categoryName}]</c:if>
                    </option>
                </c:forEach>
            </select>
            <div class="med-desc-hint text-muted small mt-1" style="font-size:.75rem;"></div>
        </td>
        <td>
            <div class="input-group input-group-sm">
                <input type="number" name="quantity[]"
                       class="form-control rounded-start-3 text-center"
                       value="1" min="1" max="9999">
                <span class="input-group-text unit-suffix rounded-end-3">—</span>
            </div>
        </td>
        <td>
            <input type="text" name="dosage[]"
                   class="form-control form-control-sm rounded-3"
                   placeholder="VD: 2 viên/ngày, sáng-tối">
        </td>
        <td class="text-center">
            <button type="button"
                    class="btn btn-sm btn-outline-danger rounded-circle remove-row"
                    style="width:30px;height:30px;padding:0;">
                <i class="bi bi-x"></i>
            </button>
        </td>
    </tr>
</template>

<script>
(function () {
    const tbody  = document.getElementById('medicineRows');
    const addBtn = document.getElementById('addRowBtn');
    const tpl    = document.getElementById('rowTemplate');

    // ── Cập nhật đếm số dòng ────────────────────────────────────────────────
    function updateCount() {
        const n = tbody.querySelectorAll('.medicine-row').length;
        document.getElementById('rowCount').textContent = n + ' loại thuốc';
    }
    updateCount();

    // ── Hiện đơn vị tính + mô tả + cảnh báo tồn kho khi chọn thuốc ───────────
    function bindDescHint(sel) {
        const row = sel.closest('tr');

        function refresh() {
            const opt  = sel.options[sel.selectedIndex];
            const hint = row.querySelector('.med-desc-hint');
            const unitEl = row.querySelector('.unit-suffix');
            const qtyEl  = row.querySelector('input[name="quantity[]"]');

            const desc  = opt ? (opt.dataset.desc || '') : '';
            const unit  = opt ? (opt.dataset.unit || '') : '';
            const stock = opt ? parseInt(opt.dataset.stock) : NaN;

            if (unitEl) unitEl.textContent = unit || '—';
            if (hint) hint.textContent = desc;

            checkStock();
        }

        function checkStock() {
            const opt   = sel.options[sel.selectedIndex];
            const hint  = row.querySelector('.med-desc-hint');
            const qtyEl = row.querySelector('input[name="quantity[]"]');
            if (!opt || !opt.value || !hint) return;

            const stock = parseInt(opt.dataset.stock);
            const qty   = parseInt(qtyEl.value);
            const desc  = opt.dataset.desc || '';

            if (!isNaN(stock) && !isNaN(qty) && qty > stock) {
                hint.innerHTML = '<span class="text-danger"><i class="bi bi-exclamation-triangle me-1"></i>' +
                    'Kho chỉ còn ' + stock + ' — số lượng kê vượt tồn kho.</span>';
            } else {
                hint.textContent = desc;
            }
        }

        sel.addEventListener('change', refresh);
        const qtyInput = row.querySelector('input[name="quantity[]"]');
        if (qtyInput) qtyInput.addEventListener('input', checkStock);

        // Trigger ngay để hiện thông tin cho dòng đã có sẵn (không ghi đè lựa chọn cũ)
        refresh();
    }

    // Bind cho tất cả dropdown đã có
    tbody.querySelectorAll('.med-dropdown').forEach(bindDescHint);

    // ── Thêm dòng mới ────────────────────────────────────────────────────────
    addBtn.addEventListener('click', () => {
        const clone = tpl.content.cloneNode(true);
        const row   = clone.querySelector('tr');
        tbody.appendChild(clone);
        // Bind description hint cho dòng mới
        const newSel = tbody.lastElementChild.querySelector('.med-dropdown');
        if (newSel) bindDescHint(newSel);
        updateCount();
    });

    // ── Xoá dòng ────────────────────────────────────────────────────────────
    tbody.addEventListener('click', (e) => {
        const btn = e.target.closest('.remove-row');
        if (!btn) return;
        if (tbody.querySelectorAll('.medicine-row').length <= 1) {
            showErr('Đơn thuốc cần có ít nhất một dòng thuốc.'); return;
        }
        btn.closest('tr').remove();
        clearErr();
        updateCount();
    });

    // ── Validate & submit ────────────────────────────────────────────────────
    window.submitRx = function () {
        clearErr();
        const selects = tbody.querySelectorAll('select[name="medicineId[]"]');
        const rows    = tbody.querySelectorAll('.medicine-row');

        const hasSelected = [...selects].some(s => s.value !== '');
        if (!hasSelected) { showErr('Vui lòng chọn ít nhất một thuốc.'); return; }

        let err = null;
        rows.forEach((row, i) => {
            if (err) return;
            const sel = row.querySelector('select[name="medicineId[]"]');
            const qty = row.querySelector('input[name="quantity[]"]');
            if (!sel.value) return;
            const q = parseInt(qty.value);
            if (!qty.value || isNaN(q) || q < 1 || q > 9999) {
                qty.classList.add('is-invalid');
                err = 'Số lượng ở dòng ' + (i + 1) + ' không hợp lệ (1–9999).';
            } else { qty.classList.remove('is-invalid'); }
        });
        if (err) { showErr(err); return; }

        // Kiểm tra trùng
        const seen = new Set(); let dup = false;
        selects.forEach(s => {
            if (!s.value) return;
            if (seen.has(s.value)) { s.classList.add('is-invalid'); dup = true; }
            else { s.classList.remove('is-invalid'); seen.add(s.value); }
        });
        if (dup) { showErr('Có thuốc bị trùng lặp trong đơn.'); return; }

        document.getElementById('prescriptionForm').submit();
    };

    function showErr(msg) {
        let box = document.getElementById('rxErr');
        if (!box) {
            box = document.createElement('div');
            box.id = 'rxErr';
            box.className = 'alert alert-danger rounded-3 mb-3';
            document.getElementById('prescriptionForm').prepend(box);
        }
        box.innerHTML = '<i class="bi bi-exclamation-triangle me-2"></i>' + msg;
        box.style.display = '';
        box.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }

    function clearErr() {
        const b = document.getElementById('rxErr');
        if (b) b.style.display = 'none';
    }
})();
</script>

<%@ include file="../common/footer.jsp" %>
