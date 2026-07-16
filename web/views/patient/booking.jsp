<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<style>
    .doctor-card { border: 1px solid #e5e7eb; }
    .doctor-avatar-circle {
        width: 48px; height: 48px; border-radius: 50%;
        background: #e7f0ff; color: #0d6efd;
        display: flex; align-items: center; justify-content: center;
        font-weight: 700; font-size: 1.1rem; flex-shrink: 0;
    }
    .summary-card { position: sticky; top: 1rem; }
    .slot-btn { min-width: 76px; }
    .slot-btn.active { background: #0d6efd; color: #fff; border-color: #0d6efd; }
    .slot-period-label { font-weight: 600; color: #6c757d; font-size: .85rem; }
    .doctor-panel { display: none; border-top: 1px solid #eee; background: #fafbfc; }
    .toggle-doctor-btn.expanded { background: #6c757d; border-color: #6c757d; }
</style>

<div class="row mb-4">
    <div class="col-12">
        <c:choose>
            <c:when test="${not empty rescheduleId}">
                <div class="d-flex align-items-center gap-3 mb-2">
                    <h2 class="fw-bold mb-0"><i class="bi bi-arrow-repeat text-warning me-2"></i>Đổi Lịch Khám</h2>
                    <span class="badge bg-warning text-dark fs-6">Chế độ đổi lịch</span>
                </div>
                <p class="text-muted mb-0">Chọn bác sĩ, ngày và khung giờ mới để đổi lịch hẹn <strong>#${rescheduleId}</strong>.</p>
                <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-sm btn-outline-secondary mt-2">
                    <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách
                </a>
            </c:when>
            <c:otherwise>
                <h2 class="fw-bold"><i class="bi bi-calendar-plus text-primary me-2"></i>Đặt Lịch Khám</h2>
                <p class="text-muted mb-0">Tìm bác sĩ, chọn ngày và khung giờ phù hợp để đặt lịch khám cho chính bạn.</p>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<c:if test="${not empty errors.general}">
    <div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i>${errors.general}</div>
</c:if>

<div class="row g-4">
    <%-- ══════════ CỘT TRÁI: bộ lọc + danh sách bác sĩ ══════════ --%>
    <div class="col-lg-8">
        <div class="card mb-3">
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <div class="col-md-7">
                        <label class="form-label fw-semibold small">Tìm theo tên bác sĩ</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
                            <input type="text" id="doctorSearchInput" class="form-control"
                                   placeholder="Nhập tên bác sĩ hoặc chuyên khoa...">
                        </div>
                    </div>
                    <div class="col-md-5">
                        <label class="form-label fw-semibold small">Chọn ngày khám</label>
                        <input type="date" id="examDateInput" class="form-control" min="${today}" value="${today}">
                    </div>
                </div>
                <div class="form-text mt-2">
                    <i class="bi bi-info-circle me-1"></i>Bấm "Chọn" ở thẻ bác sĩ để xem khung giờ trống trong ngày đã chọn.
                </div>
            </div>
        </div>

        <div id="doctorListContainer" class="d-flex flex-column gap-3">
            <c:forEach var="d" items="${doctors}">
                <div class="card doctor-card doctor-card-wrapper"
                     data-name="${fn:toLowerCase(d.fullName)} ${fn:toLowerCase(d.specialization)}">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="doctor-avatar-circle" style="${not empty d.avatarUrl ? 'padding:0;overflow:hidden;' : ''}">
                            <c:choose>
                                <c:when test="${not empty d.avatarUrl}">
                                    <img src="${d.avatarUrl}" alt="BS. ${d.fullName}"
                                         style="width:100%;height:100%;object-fit:cover;border-radius:50%;"
                                         onerror="this.parentElement.style.padding='';this.parentElement.innerHTML='${fn:substring(d.fullName, 0, 1)}'">
                                </c:when>
                                <c:otherwise>
                                    ${fn:substring(d.fullName, 0, 1)}
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="flex-grow-1">
                            <h6 class="mb-1 fw-bold">BS. ${d.fullName}</h6>
                            <div class="text-muted small">${d.specialization}</div>
                            <c:if test="${d.experienceYears > 0}">
                                <div class="text-muted small">
                                    <i class="bi bi-award me-1"></i>${d.experienceYears} năm kinh nghiệm
                                </div>
                            </c:if>
                        </div>
                        <button type="button"
                                class="btn btn-sm btn-primary toggle-doctor-btn"
                                data-doctor-id="${d.id}"
                                data-doctor-name="BS. ${d.fullName}">
                            Chọn
                        </button>
                    </div>

                    <%-- Panel xổ khung giờ — nạp bằng AJAX khi bấm "Chọn" --%>
                    <div class="doctor-panel p-3" id="panel-doctor-${d.id}">
                        <div class="slot-loading text-muted small">
                            <span class="spinner-border spinner-border-sm me-1"></span>Đang tải khung giờ trống...
                        </div>
                        <div class="slot-content" style="display:none;"></div>
                    </div>
                </div>
            </c:forEach>
        </div>
        <div id="noDoctorFound" class="text-center text-muted py-4" style="display:none;">
            Không tìm thấy bác sĩ phù hợp.
        </div>
    </div>

    <%-- ══════════ CỘT PHẢI: tóm tắt lịch khám ══════════ --%>
    <div class="col-lg-4">
        <div class="card summary-card">
            <div class="card-body">
                <h5 class="card-title mb-3"><i class="bi bi-clipboard-check me-2"></i>Tóm Tắt Lịch Khám</h5>

                <div id="summaryEmpty" class="text-center text-muted py-4">
                    <i class="bi bi-calendar3 d-block mb-2" style="font-size:2rem;opacity:.3;"></i>
                    Vui lòng chọn bác sĩ và giờ khám để xem chi tiết.
                </div>

                <form method="post" action="${pageContext.request.contextPath}/patient/booking" id="bookingForm" style="display:none;">
                    <input type="hidden" name="slotId" id="hiddenSlotId" required>
                    <c:if test="${not empty rescheduleId}">
                        <input type="hidden" name="rescheduleId" value="${rescheduleId}">
                    </c:if>

                    <ul class="list-unstyled small mb-3">
                        <li class="d-flex justify-content-between py-1 border-bottom">
                            <span class="text-muted">Bác sĩ</span>
                            <strong id="summaryDoctorName">—</strong>
                        </li>
                        <li class="d-flex justify-content-between py-1 border-bottom">
                            <span class="text-muted">Ngày khám</span>
                            <strong id="summaryDate">—</strong>
                        </li>
                        <li class="d-flex justify-content-between py-1 border-bottom">
                            <span class="text-muted">Giờ khám</span>
                            <strong id="summaryTime">—</strong>
                        </li>
                    </ul>

                    <%-- Ẩn dịch vụ & triệu chứng khi đang đổi lịch (chỉ cần chọn slot mới) --%>
                    <c:if test="${empty rescheduleId}">
                        <div class="mb-3">
                            <label class="form-label fw-semibold small">Dịch vụ khám <span class="text-danger">*</span></label>
                            <select name="serviceId" class="form-select form-select-sm" required>
                                <option value="">-- Chọn dịch vụ --</option>
                                <c:forEach var="s" items="${services}">
                                    <option value="${s.id}">
                                        ${s.serviceName} (<fmt:formatNumber value="${s.price}" pattern="#,###"/>đ)
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty errors.serviceId}">
                                <div class="text-danger small mt-1">${errors.serviceId}</div>
                            </c:if>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold small">Triệu chứng <span class="text-danger">*</span></label>
                            <textarea name="symptoms" class="form-control form-control-sm" rows="3" required
                                      placeholder="Mô tả triệu chứng của bạn...">${param.symptoms}</textarea>
                            <c:if test="${not empty errors.symptoms}">
                                <div class="text-danger small mt-1">${errors.symptoms}</div>
                            </c:if>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold small">Ngày kinh cuối (nếu có)</label>
                            <input type="date" name="lastMenstrualPeriod" class="form-control form-control-sm" max="${today}">
                            <c:if test="${not empty errors.lmp}">
                                <div class="text-danger small mt-1">${errors.lmp}</div>
                            </c:if>
                        </div>
                    </c:if>

                    <c:choose>
                        <c:when test="${not empty rescheduleId}">
                            <button type="submit" class="btn btn-warning w-100 fw-semibold">
                                <i class="bi bi-arrow-repeat me-1"></i>Xác Nhận Đổi Lịch
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="submit" class="btn btn-success w-100">
                                <i class="bi bi-check-circle me-1"></i>Xác Nhận Đặt Lịch
                            </button>
                        </c:otherwise>
                    </c:choose>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
(function () {
    const contextPath = "${pageContext.request.contextPath}";
    const searchInput = document.getElementById('doctorSearchInput');
    const dateInput = document.getElementById('examDateInput');
    const doctorCards = document.querySelectorAll('.doctor-card-wrapper');
    const noDoctorFound = document.getElementById('noDoctorFound');

    // ── Lọc bác sĩ theo tên/chuyên khoa (client-side) ──
    searchInput.addEventListener('input', function () {
        const kw = this.value.trim().toLowerCase();
        let visible = 0;
        doctorCards.forEach(function (card) {
            const match = card.dataset.name.includes(kw);
            card.style.display = match ? '' : 'none';
            if (match) visible++;
        });
        noDoctorFound.style.display = visible === 0 ? '' : 'none';
    });

    // ── Xổ / ẩn khung giờ của 1 bác sĩ ──
    document.querySelectorAll('.toggle-doctor-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
            const doctorId = this.dataset.doctorId;
            const panel = document.getElementById('panel-doctor-' + doctorId);
            const isOpen = panel.style.display === 'block';

            // Đóng tất cả panel khác đang mở (chỉ mở 1 bác sĩ tại 1 thời điểm)
            document.querySelectorAll('.doctor-panel').forEach(p => p.style.display = 'none');
            document.querySelectorAll('.toggle-doctor-btn').forEach(b => {
                b.textContent = 'Chọn';
                b.classList.remove('expanded');
            });

            if (isOpen) return; // vừa đóng xong -> dừng

            panel.style.display = 'block';
            this.textContent = 'Ẩn lịch';
            this.classList.add('expanded');

            loadSlots(doctorId, this.dataset.doctorName, panel);
        });
    });

    function loadSlots(doctorId, doctorName, panel) {
        const date = dateInput.value;
        const loadingEl = panel.querySelector('.slot-loading');
        const contentEl = panel.querySelector('.slot-content');

        if (!date) {
            loadingEl.style.display = 'none';
            contentEl.style.display = 'block';
            contentEl.innerHTML = '<div class="text-warning small">Vui lòng chọn ngày khám ở phía trên.</div>';
            return;
        }

        loadingEl.style.display = 'block';
        contentEl.style.display = 'none';
        contentEl.innerHTML = '';

        fetch(contextPath + '/patient/booking/slots?doctorId=' + doctorId + '&date=' + date)
            .then(function (res) { return res.json(); })
            .then(function (slots) {
                loadingEl.style.display = 'none';
                contentEl.style.display = 'block';
                renderSlots(slots, doctorId, doctorName, date, contentEl);
            })
            .catch(function () {
                loadingEl.style.display = 'none';
                contentEl.style.display = 'block';
                contentEl.innerHTML = '<div class="text-danger small">Không tải được khung giờ. Vui lòng thử lại.</div>';
            });
    }

    function renderSlots(slots, doctorId, doctorName, date, container) {
        if (!slots || slots.length === 0) {
            container.innerHTML = '<div class="text-muted small">Bác sĩ không còn khung giờ trống vào ngày này. Vui lòng chọn ngày khác.</div>';
            return;
        }

        const morning = slots.filter(s => s.time < '12:00');
        const afternoon = slots.filter(s => s.time >= '12:00');

        let html = '';
        if (morning.length > 0) {
            html += '<div class="slot-period-label mb-2"><i class="bi bi-sun me-1"></i>Sáng</div>';
            html += '<div class="d-flex flex-wrap gap-2 mb-3">' + morning.map(s => slotButtonHtml(s)).join('') + '</div>';
        }
        if (afternoon.length > 0) {
            html += '<div class="slot-period-label mb-2"><i class="bi bi-moon me-1"></i>Chiều</div>';
            html += '<div class="d-flex flex-wrap gap-2">' + afternoon.map(s => slotButtonHtml(s)).join('') + '</div>';
        }
        container.innerHTML = html;

        container.querySelectorAll('.slot-btn').forEach(function (btn) {
            btn.addEventListener('click', function () {
                container.querySelectorAll('.slot-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                selectSlot(this.dataset.slotId, this.dataset.label, doctorName, date);
            });
        });
    }

    function slotButtonHtml(s) {
        return '<button type="button" class="btn btn-outline-primary btn-sm slot-btn" '
             + 'data-slot-id="' + s.id + '" data-label="' + s.label + '">' + s.time + '</button>';
    }

    // ── Cập nhật tóm tắt bên phải khi chọn 1 khung giờ ──
    function selectSlot(slotId, label, doctorName, date) {
        document.getElementById('summaryEmpty').style.display = 'none';
        document.getElementById('bookingForm').style.display = 'block';
        document.getElementById('hiddenSlotId').value = slotId;
        document.getElementById('summaryDoctorName').textContent = doctorName;
        document.getElementById('summaryDate').textContent = date;
        document.getElementById('summaryTime').textContent = label;
    }

    // ── Nếu đổi ngày sau khi đã mở 1 bác sĩ -> tải lại slot cho ngày mới ──
    dateInput.addEventListener('change', function () {
        const openPanel = document.querySelector('.doctor-panel[style*="block"]');
        if (openPanel) {
            const doctorId = openPanel.id.replace('panel-doctor-', '');
            const btn = document.querySelector('.toggle-doctor-btn[data-doctor-id="' + doctorId + '"]');
            loadSlots(doctorId, btn.dataset.doctorName, openPanel);
        }
    });
})();
</script>

<%@ include file="../common/footer.jsp" %>
