<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<style>
    .doctor-card { border: 1.5px solid var(--pt-outline, #f0dae5) !important; }
    .doctor-avatar-circle {
        width: 48px; height: 48px; border-radius: 50%;
        background: var(--pt-pink-50, #fff9fc);
        color: var(--pt-pink-600, #b86689);
        border: 1.5px solid var(--pt-pink-200, #f7dce7);
        display: flex; align-items: center; justify-content: center;
        font-weight: 700; font-size: 1.1rem; flex-shrink: 0;
    }
    .summary-card { position: sticky; top: 5rem; }
    .slot-btn { min-width: 76px; }
    .slot-btn.active {
        background: var(--pt-pink-600, #b86689) !important;
        color: #fff !important;
        border-color: var(--pt-pink-600, #b86689) !important;
        box-shadow: 0 3px 10px rgba(184,102,137,0.22);
    }
    .slot-period-row {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 8px;
        flex-wrap: nowrap;
        overflow-x: auto;
    }
    .slot-period-label {
        font-weight: 700;
        color: var(--pt-muted, #8a5e74);
        font-size: .78rem;
        letter-spacing: .04em;
        text-transform: uppercase;
        white-space: nowrap;
        min-width: 80px;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .slot-period-label.morning { color: #d97706; }
    .slot-period-label.afternoon { color: #0ea5e9; }
    .slot-period-label.evening { color: #7c3aed; }
    .slot-period-slots { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
    .slot-btn.slot-locked {
        min-width: 70px;
        background: var(--pt-surface-var, #f4f4f6) !important;
        color: #9a9aa2 !important;
        border-color: #e2e2e6 !important;
        cursor: pointer;
        opacity: .85;
    }
    .slot-btn.slot-locked:hover { background: #ebebef !important; }
    .doctor-panel { display: none; border-top: 1.5px solid var(--pt-outline, #f0dae5); background: var(--pt-surface-var, #fff6fb); border-radius: 0 0 14px 14px; }
    .toggle-doctor-btn.expanded { background: var(--pt-pink-600, #b86689) !important; border-color: var(--pt-pink-600, #b86689) !important; }
</style>

<c:if test="${not empty existingAppointments}">
    <div class="alert border-0 shadow-sm d-flex align-items-center gap-3 mb-4 rounded-3" role="alert"
         style="background: #f0f4ff; color: #3730a3; border-left: 4px solid #6366f1;">
        <i class="bi bi-info-circle fs-5 flex-shrink-0"></i>
        <div class="small">
            <strong>Bạn đã có lịch hôm nay:</strong>
            <c:forEach var="ea" items="${existingAppointments}" varStatus="est">
                <span class="badge bg-primary bg-opacity-75 me-1">#APT-${ea.id}</span>
                BS. ${ea.doctorName} — ${ea.displayStatus}
                <c:if test="${!est.last}"> &middot; </c:if>
            </c:forEach>
            &mdash; Có thể <a href="${pageContext.request.contextPath}/patient/appointments" class="fw-bold" style="color:#3730a3;">đổi lịch</a> hoặc chọn ngày khác bên dưới.
        </div>
    </div>
</c:if>

<div class="row mb-4">
    <div class="col-12">
        <div class="card border-0 patient-hero-card rounded-4">
            <div class="card-body p-4">
                <c:choose>
                    <c:when test="${not empty rescheduleId}">
                        <div class="d-flex align-items-center gap-3 mb-1">
                            <h2 class="fw-bold mb-0"><i class="bi bi-arrow-repeat me-2"></i>Đổi Lịch Khám</h2>
                            <span class="badge bg-warning text-dark fs-6">Chế độ đổi lịch</span>
                        </div>
                        <p class="mb-0 opacity-75">Chọn bác sĩ, ngày và khung giờ mới để đổi lịch hẹn <strong>#${rescheduleId}</strong>.</p>
                        <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-sm btn-light text-pink-theme mt-2">
                            <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách
                        </a>
                    </c:when>
                    <c:otherwise>
                        <h2 class="fw-bold mb-1"><i class="bi bi-calendar-plus me-2"></i>Đặt Lịch Khám</h2>
                        <p class="mb-0 opacity-75">Tìm bác sĩ, chọn ngày và khung giờ phù hợp để đặt lịch khám cho chính bạn.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<c:if test="${not empty errors.general}">
    <div class="alert alert-danger alert-dismissible fade show" data-cams-toast role="alert"><i class="bi bi-exclamation-triangle-fill me-2"></i>${errors.general}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
</c:if>
<c:if test="${not empty errors.slotId}">
    <div class="alert alert-danger" data-cams-toast>
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <c:out value="${errors.slotId}"/>
    </div>
</c:if>

<div class="row g-4">
    <%-- ══════════ CỘT TRÁI: bộ lọc + danh sách bác sĩ ══════════ --%>
    <div class="col-lg-8">
        <div class="card mb-3">
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <div class="col-md-7">
                        <label class="form-label fw-semibold small">Tìm theo tên Bác sĩ lâm sàng</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
                            <input type="text" id="doctorSearchInput" class="form-control"
                                   placeholder="Gõ tên Bác sĩ lâm sàng hoặc chuyên khoa...">
                        </div>
                    </div>
                    <div class="col-md-5">
                        <label class="form-label fw-semibold small">Chọn ngày khám</label>
                        <input type="date" id="examDateInput" class="form-control" min="${today}" value="${today}">
                    </div>
                </div>
                <div class="form-text mt-2">
                    <i class="bi bi-info-circle me-1"></i>Gõ tên bác sĩ để lọc ngay • Bấm "Chọn" để xem khung giờ trống trong ngày đã chọn.
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
                                         onerror="this.parentElement.style.padding='';this.parentElement.innerHTML='${not empty d.fullName ? fn:substring(d.fullName, 0, 1) : "?"}'">
                                </c:when>
                                <c:otherwise>
                                    ${not empty d.fullName ? fn:substring(d.fullName, 0, 1) : '?'}
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
                            <div class="small fw-bold mt-1 doctor-price-range" id="price-range-${d.id}"
                                 style="color: var(--bs-primary, #d6336c); min-height: 1.1em;">
                                <span class="spinner-border spinner-border-sm" style="width:0.7rem;height:0.7rem;"></span>
                            </div>
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
        <c:if test="${empty doctors}">
            <div id="noDoctorFound" class="text-center text-muted py-4">
                Không tìm thấy Bác sĩ lâm sàng phù hợp.
            </div>
        </c:if>

        <c:if test="${totalPages > 1}">
            <nav aria-label="Page navigation" class="mt-4">
                <ul class="pagination justify-content-center mb-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage - 1}&keyword=${fn:escapeXml(keyword)}">Trước</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="?page=${i}&keyword=${fn:escapeXml(keyword)}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage + 1}&keyword=${fn:escapeXml(keyword)}">Sau</a>
                    </li>
                </ul>
            </nav>
        </c:if>
    </div>

    <%-- ══════════ CỘT PHẢI: tóm tắt lịch khám ══════════ --%>
    <div class="col-lg-4">
        <div class="card summary-card">
            <div class="card-body">
                <h5 class="card-title mb-3"><i class="bi bi-clipboard-check me-2"></i>Tóm Tắt Lịch Khám</h5>

                <c:choose>
                    <c:when test="${not empty existingAppointments && empty rescheduleId}">
                        <%-- Block booking: đã có lịch hôm nay --%>
                        <div id="summaryBlocked" class="text-center py-4">
                            <i class="bi bi-calendar-check d-block mb-2" style="font-size:2.5rem;color:#6366f1;"></i>
                            <p class="fw-semibold mb-2">Bạn đã có lịch khám hôm nay</p>
                            <p class="text-muted small mb-3">Mỗi bệnh nhân chỉ được <strong>1 lịch khám/ngày</strong>.</p>
                            <div class="d-flex flex-column gap-2">
                                <a href="${pageContext.request.contextPath}/patient/appointments"
                                   class="btn btn-primary btn-sm rounded-pill">
                                    <i class="bi bi-arrow-repeat me-1"></i>Đổi lịch hiện tại
                                </a>
                                <span class="text-muted small">hoặc chọn <strong>ngày khác</strong> ở bộ lọc bên trái</span>
                            </div>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/patient/booking" id="bookingForm" style="display:none;">
                    </c:when>
                    <c:otherwise>
                <div id="summaryEmpty" class="text-center text-muted py-4">
                    <i class="bi bi-calendar3 d-block mb-2" style="font-size:2rem;opacity:.3;"></i>
                    Vui lòng chọn Bác sĩ lâm sàng và giờ khám để xem chi tiết.
                </div>

                <form method="post" action="${pageContext.request.contextPath}/patient/booking" id="bookingForm" style="display:none;">
                    </c:otherwise>
                </c:choose>
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="slotId" id="hiddenSlotId" required>
                    <input type="hidden" name="timeSlot" id="hiddenTimeSlot" required>
                    <c:if test="${not empty rescheduleId}">
                        <input type="hidden" name="rescheduleId" value="${rescheduleId}">
                    </c:if>

                    <ul class="list-unstyled small mb-3">
                        <li class="d-flex justify-content-between py-1 border-bottom">
                            <span class="text-muted">Bác sĩ lâm sàng</span>
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
                        <ul class="list-unstyled small mb-3">
                            <li class="d-flex justify-content-between py-1 border-bottom">
                                <span class="text-muted">Phí khám lâm sàng</span>
                                <strong id="summaryBasePrice" style="color:#d6336c;">—</strong>
                            </li>
                        </ul>

                        <div class="mb-3">
                            <label class="form-label fw-semibold small">Triệu chứng <span class="text-danger">*</span></label>
                            <textarea name="symptoms" class="form-control form-control-sm" rows="3" required
                                      placeholder="Mô tả triệu chứng của bạn...">${param.symptoms}</textarea>
                            <c:if test="${not empty errors.symptoms}">
                                <div class="text-danger small mt-1">${errors.symptoms}</div>
                            </c:if>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Ngày đầu kỳ kinh cuối (LMP) <span class="text-muted fw-normal" style="font-size: 0.85em;">(Tùy chọn - Bỏ qua nếu không nhớ)</span></label>
                            <input type="date" name="lastMenstrualPeriod" class="form-control form-control-sm" max="${today}" value="${param.lastMenstrualPeriod}">
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
                            <div class="p-2 mb-2 rounded-2 small text-center" style="background:#fef3c7;color:#92400e;">
                                <i class="bi bi-cash-stack me-1"></i>Thanh toán <strong>tiền mặt</strong> tại quầy Lễ tân trước giờ khám
                            </div>
                            <button type="submit" class="btn btn-success w-100">
                                <i class="bi bi-check-circle me-1"></i>Xác Nhận Đặt Lịch
                            </button>
                        </c:otherwise>
                    </c:choose>

                    <div class="mt-3 p-3 rounded-3 small" style="background:#f8fafc;border:1px dashed #cbd5e1;line-height:1.6;">
                        <i class="bi bi-info-circle me-1 text-primary"></i>
                        <strong>Quy trình đặt khám & tiếp nhận:</strong>
                        <ul class="mb-2 mt-1 ps-3">
                            <li><strong>Bước 1 - Đặt lịch:</strong> Bạn chọn bác sĩ, ngày và khung giờ phù hợp. Lịch hẹn được tạo với trạng thái <em>Chờ duyệt</em>.</li>
                            <li><strong>Bước 2 - Phòng khám duyệt lịch:</strong> Nhân viên Lễ tân sẽ xem xét và duyệt lịch của bạn, đồng thời tạo hóa đơn phí khám.</li>
                            <li><strong>Bước 3 - Đến phòng khám:</strong> Bạn đến quầy Lễ tân để nộp tiền khám và check-in <strong>trước giờ hẹn ít nhất 15 phút</strong>.</li>
                            <li><strong>Bước 4 - Vào khám:</strong> Sau khi check-in, bạn được xếp số thứ tự và chờ bác sĩ gọi vào khám.</li>
                        </ul>
                        <i class="bi bi-arrow-repeat me-1 text-primary"></i>
                        <strong>Chính sách huỷ / đổi lịch:</strong>
                        <ul class="mb-0 mt-1 ps-3">
                            <li>Có thể huỷ hoặc đổi lịch khi lịch đang ở trạng thái <em>Chờ duyệt</em> hoặc <em>Đã xác nhận</em> và <strong>còn ít nhất 2 giờ</strong> trước giờ khám.</li>
                            <li>Không thể tự huỷ/đổi lịch sau khi đã nộp tiền khám tại quầy — vui lòng liên hệ Lễ tân.</li>
                            <li>Trong vòng 2 giờ trước giờ khám, vui lòng liên hệ trực tiếp Lễ tân để được hỗ trợ.</li>
                        </ul>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
(function () {
    const contextPath = "${pageContext.request.contextPath}";
    const dateInput = document.getElementById('examDateInput');
    const searchInput = document.getElementById('doctorSearchInput');
    const doctorCards = document.querySelectorAll('.doctor-card-wrapper');
    const noDoctorFound = document.getElementById('noDoctorFound');

    // ── Lọc Bác sĩ lâm sàng real-time theo tên/chuyên khoa (client-side) ──
    if (searchInput) {
        searchInput.addEventListener('input', function () {
            const kw = this.value.trim().toLowerCase();
            let visible = 0;
            doctorCards.forEach(function (card) {
                const match = card.dataset.name.includes(kw);
                card.style.display = match ? '' : 'none';
                if (match) visible++;
            });
            if (noDoctorFound) noDoctorFound.style.display = visible === 0 ? '' : 'none';
        });
    }

    // ── Xổ / ẩn khung giờ của 1 Bác sĩ lâm sàng ──
    document.querySelectorAll('.toggle-doctor-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
            const doctorId = this.dataset.doctorId;
            const panel = document.getElementById('panel-doctor-' + doctorId);
            const isOpen = panel.style.display === 'block';

            // Đóng tất cả panel khác đang mở (chỉ mở 1 Bác sĩ lâm sàng tại 1 thời điểm)
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

        fetch(contextPath + '/patient/booking/slots?doctorId=' + doctorId + '&date=' + date + '&all=1')
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
            container.innerHTML = '<div class="text-muted small">Bác sĩ lâm sàng không còn khung giờ trống vào ngày này. Vui lòng chọn ngày khác.</div>';
            return;
        }

        // Xác định ngày hôm nay và giờ hiện tại theo giờ client
        const now = new Date();
        const yyyy = now.getFullYear();
        const mm = String(now.getMonth() + 1).padStart(2, '0');
        const dd = String(now.getDate()).padStart(2, '0');
        const todayStr = yyyy + '-' + mm + '-' + dd;
        
        const isToday = (date === todayStr);
        const nowTimeStr = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');

        let html = '<div class="d-grid gap-2 mb-3" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">';
        slots.forEach(s => {
            html += slotButtonHtml(s, isToday, nowTimeStr);
        });
        html += '</div>';
        
        if (slots.length === 0) {
            html = '<div class="text-muted small">Bác sĩ lâm sàng không còn ca khám trống vào ngày này. Vui lòng chọn ngày khác.</div>';
        }
        
        html += '<div class="slot-notice mt-2" style="display:none;"></div>';
        container.innerHTML = html;

        container.querySelectorAll('.slot-btn:not(.slot-locked):not(.slot-disabled)').forEach(function (btn) {
            btn.addEventListener('click', function () {
                container.querySelectorAll('.slot-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                hideSlotNotice(container);
                // Giá khám = giá riêng của khung giờ này (theo ngày/giờ cụ thể); nếu chưa set thì 0 -> "Liên hệ"
                const slotPrice = (this.dataset.price && this.dataset.price !== 'null' && this.dataset.price !== '')
                    ? parseFloat(this.dataset.price) : 0;
                selectSlot(this.dataset.slotId, this.dataset.label, doctorName, date, slotPrice);
            });
        });

        container.querySelectorAll('.slot-btn.slot-locked:not(.slot-disabled)').forEach(function (btn) {
            btn.addEventListener('click', function () {
                const mine = this.dataset.mine === 'true';
                showSlotNotice(container, this.dataset.status, this.textContent.trim(), mine);
            });
        });
    }

    // Nhãn hiển thị khi khung giờ bị khóa — theo đúng trạng thái thật của slot.
    // Nếu chính bệnh nhân đang đăng nhập là người giữ/đặt khung giờ đó thì ghi rõ
    // "Bạn đã..." thay vì nói chung chung như đang bị người khác chiếm mất.
    function slotStatusText(status, mine) {
        if (mine) {
            switch (status) {
                case 'HELD': return 'Bạn đã đặt lịch ca này nhưng chưa thanh toán. Vui lòng có mặt tại quầy lễ tân để hoàn tất thủ tục tối thiểu 15 phút trước giờ bắt đầu ca khám.';
                case 'WAITING_VERIFICATION': return 'Bạn đã hoàn tất thanh toán ca này.';
                case 'BOOKED': return 'Bạn đã đặt thành công ca khám này.';
                default: return 'Khung giờ này thuộc về bạn nhưng hiện không thể chọn lại.';
            }
        }
        switch (status) {
            case 'HELD': return 'Ca khám này đang được một bệnh nhân khác giữ chỗ, vui lòng chọn ca khác.';
            case 'WAITING_VERIFICATION': return 'Ca khám này đã có bệnh nhân khác gửi thanh toán và đang chờ lễ tân xác nhận, vui lòng chọn ca khác.';
            case 'BOOKED': return 'Ca khám này đã được đặt kín, vui lòng chọn ca khác.';
            default: return 'Ca khám này hiện không thể đặt, vui lòng chọn ca khác.';
        }
    }

    // Hiện thông báo NGAY BÊN DƯỚI lưới khung giờ của bác sĩ đang mở, khi bệnh nhân
    // bấm vào 1 khung giờ đang bị khóa — thay vì chỉ dựa vào màu sắc.
    function showSlotNotice(container, status, time, mine) {
        const notice = container.querySelector('.slot-notice');
        if (!notice) return;
        const box = document.createElement('div');
        box.className = 'alert ' + (mine ? 'alert-info' : 'alert-warning') + ' d-flex align-items-center gap-2 mb-0 py-2 px-3 small';
        const icon = document.createElement('i');
        icon.className = 'bi bi-lock-fill';
        const text = document.createElement('span');
        const strong = document.createElement('strong');
        strong.textContent = time;
        text.append(strong, document.createTextNode(' — ' + slotStatusText(status, mine)));
        box.append(icon, text);
        notice.replaceChildren(box);
        notice.style.display = 'block';
    }

    function hideSlotNotice(container) {
        const notice = container.querySelector('.slot-notice');
        if (notice) notice.style.display = 'none';
    }

    function slotButtonHtml(s, isToday, nowTimeStr) {
        let titleText = s.statusLabel || 'Khung giờ này hiện không khả dụng';

        // Slot thuộc về chính bệnh nhân đang đăng nhập → hiển thị đặc biệt, vẫn cho bấm để xem thông tin
        if (s.mine === true) {
            return '<button type="button" class="btn btn-sm slot-btn slot-locked" '
                 + 'style="background: #e8f5e9 !important; color: #2e7d32 !important; border-color: #a5d6a7 !important; cursor: pointer;" '
                 + 'title="Bạn đã đặt lịch này. Nhấn để xem chi tiết." '
                 + 'data-status="' + s.status + '" data-mine="true">'
                 + '<i class="bi bi-check-circle-fill me-1"></i>' + s.shiftName + ' (' + s.label + ')'
                 + '</button>';
        }

        // available === false → làm mờ, vẫn cho bấm để hiện thông báo lý do
        if (s.available === false) {
            return '<button type="button" class="btn btn-outline-secondary btn-sm slot-btn slot-locked" '
                 + 'title="' + titleText + '" '
                 + 'data-status="' + s.status + '" data-mine="false">'
                 + s.shiftName + ' (' + s.label + ')'
                 + '</button>';
        }
        if (s.price === null || s.price === undefined || s.price === '') {
            return '<button type="button" class="btn btn-outline-secondary btn-sm slot-btn" disabled '
                 + 'title="Gia kham chua duoc cong bo">'
                 + s.shiftName + ' (' + s.label + ')'
                 + '</button>';
        }
        return '<button type="button" class="btn btn-outline-primary btn-sm slot-btn w-100" '
             + 'data-slot-id="' + s.id + '" data-label="' + s.label + '" data-price="' + (s.price !== null ? s.price : '') + '">'
             + s.shiftName + ' (' + s.label + ')'
             + '</button>';
    }

    // ── Cập nhật tóm tắt bên phải khi chọn 1 khung giờ ──
    function selectSlot(slotId, label, doctorName, date, basePrice) {
        var emptyEl = document.getElementById('summaryEmpty');
        if (emptyEl) emptyEl.style.display = 'none';
        var blockedEl = document.getElementById('summaryBlocked');
        if (blockedEl) blockedEl.style.display = 'none';
        var formEl = document.getElementById('bookingForm');
        if (formEl) formEl.style.display = 'block';
        document.getElementById('hiddenSlotId').value = slotId;
        document.getElementById('hiddenTimeSlot').value = label;
        document.getElementById('summaryDoctorName').textContent = doctorName;
        document.getElementById('summaryDate').textContent = date;
        document.getElementById('summaryTime').textContent = label;

        const fee = Number.isFinite(Number(basePrice)) ? Number(basePrice) : 0;
        const basePriceEl = document.getElementById('summaryBasePrice');
        if (basePriceEl) {
            basePriceEl.textContent = fee > 0
                ? new Intl.NumberFormat('vi-VN').format(fee) + 'đ'
                : 'Liên hệ phòng khám';
        }
    }

    // ── Nếu đổi ngày sau khi đã mở 1 Bác sĩ lâm sàng -> tải lại slot cho ngày mới ──
    dateInput.addEventListener('change', function () {
        const openPanel = document.querySelector('.doctor-panel[style*="block"]');
        if (openPanel) {
            const doctorId = openPanel.id.replace('panel-doctor-', '');
            const btn = document.querySelector('.toggle-doctor-btn[data-doctor-id="' + doctorId + '"]');
            loadSlots(doctorId, btn.dataset.doctorName, openPanel);
        }
        loadAllDoctorPriceRanges();
    });

    // ── Hiển thị "Từ X - Yđ" dưới tên mỗi Bác sĩ lâm sàng theo ngày đang chọn ──
    function loadAllDoctorPriceRanges() {
        const date = dateInput.value;
        document.querySelectorAll('.toggle-doctor-btn').forEach(function (btn) {
            const doctorId = btn.dataset.doctorId;
            const el = document.getElementById('price-range-' + doctorId);
            if (!el || !date) return;

            el.innerHTML = '<span class="spinner-border spinner-border-sm" style="width:0.7rem;height:0.7rem;"></span>';

            fetch(contextPath + '/patient/booking/slots?doctorId=' + doctorId + '&date=' + date)
                .then(function (res) { return res.json(); })
                .then(function (slots) {
                    if (!slots || slots.length === 0) {
                        el.innerHTML = '<span class="text-muted fw-normal">Không còn khung giờ trống</span>';
                        return;
                    }
                    const prices = slots
                        .map(s => s.price)
                        .filter(p => p !== null && p !== undefined && p >= 0);

                    if (prices.length === 0) {
                        el.innerHTML = '<span class="text-muted fw-normal">Chưa công bố giá</span>';
                        return;
                    }
                    const min = Math.min.apply(null, prices);
                    const max = Math.max.apply(null, prices);
                    const fmt = n => new Intl.NumberFormat('vi-VN').format(n) + 'đ';
                    el.innerHTML = '<i class="bi bi-tag me-1"></i>' +
                        (min === max ? fmt(min) : fmt(min) + ' - ' + fmt(max));
                })
                .catch(function () {
                    el.innerHTML = '<span class="text-muted fw-normal">—</span>';
                });
        });
    }

    loadAllDoctorPriceRanges();
})();
</script>

<%@ include file="../common/footer.jsp" %>
