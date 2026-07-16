<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<div class="py-2">
    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 patient-hero-card rounded-4">
                <div class="card-body p-4">
                    <h2 class="fw-bold mb-1"><i class="bi bi-heart-pulse-fill me-2"></i>Theo Dõi Thai Kỳ</h2>
                    <p class="mb-0 opacity-75">Hành trình phát triển của bé yêu qua từng tuần tuổi.</p>
                </div>
            </div>
        </div>
    </div>

    <c:choose>
        <%-- TRƯỜNG HỢP: KHÔNG CÓ THAI KỲ HOẠT ĐỘNG --%>
        <c:when test="${empty pregnancy}">
            <div class="card border-0 shadow-sm rounded-4 text-center py-5">
                <div class="card-body">
                    <div class="pregnancy-female-icon mx-auto mb-4 rounded-circle d-flex align-items-center justify-content-center"
                         style="width: 100px; height: 100px;">
                        <i class="bi bi-gender-female" style="font-size: 3rem;"></i>
                    </div>
                    <h4 class="fw-bold mb-2">Chưa kích hoạt hồ sơ thai sản</h4>
                    <p class="text-muted mx-auto" style="max-width: 500px;">
                        Tài khoản của bạn hiện tại chưa có thai kỳ nào đang hoạt động. 
                        Vui lòng liên hệ với Bác sĩ sản khoa trong lần khám tới để được tạo hồ sơ thai kỳ và kích hoạt tính năng theo dõi thông minh này nhé!
                    </p>
                    <div class="mt-4">
                        <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-primary rounded-pill px-4">
                            <i class="bi bi-calendar-plus me-2"></i>Đặt lịch khám sản khoa
                        </a>
                    </div>
                </div>
            </div>
        </c:when>

        <%-- TRƯỜNG HỢP: CÓ THAI KỲ HOẠT ĐỘNG --%>
        <c:otherwise>
            <div class="row g-4">
                <%-- Cột bên trái: Thông tin tổng quan và sự phát triển của em bé --%>
                <div class="col-lg-5">
                    <%-- Card tuổi thai & đếm ngược --%>
                    <div class="card border-0 shadow-sm rounded-4 text-white mb-4" 
                         style="background: linear-gradient(135deg, #ff758c 0%, #ff7eb3 100%);">
                        <div class="card-body p-4 text-center">
                            <span class="badge bg-white text-danger fw-semibold px-3 py-2 rounded-pill mb-3">
                                <i class="bi bi-calendar-check me-1"></i>Thai kỳ đang hoạt động
                            </span>
                            
                            <h5 class="opacity-75 fw-medium mb-1">Bé yêu của bạn đã được</h5>
                            <h1 class="display-4 fw-bold mb-2">
                                ${currentWeeks} <span class="fs-3 fw-normal">tuần</span>
                                <c:if test="${currentDays > 0}">
                                    ${currentDays} <span class="fs-3 fw-normal">ngày</span>
                                </c:if>
                            </h1>

                            <div class="my-4 border-top border-white border-opacity-25 pt-3">
                                <div class="row">
                                    <div class="col-6 border-end border-white border-opacity-25">
                                        <small class="d-block opacity-75">Ngày dự sinh (EDD)</small>
                                        <strong class="fs-6">${pregnancy.estimatedDueDate}</strong>
                                    </div>
                                    <div class="col-6">
                                        <small class="d-block opacity-75">Đếm ngược chào đời</small>
                                        <strong class="fs-6">
                                            <c:choose>
                                                <c:when test="${daysLeft > 0}">Còn ${daysLeft} ngày</c:when>
                                                <c:when test="${daysLeft == 0}">Hôm nay là ngày dự sinh! 🎉</c:when>
                                                <c:otherwise>Quá ngày dự sinh ${fn:substring(daysLeft, 1, 10)} ngày</c:otherwise>
                                            </c:choose>
                                        </strong>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Card so sánh kích thước em bé --%>
                    <div class="card rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3" style="color: var(--pt-pink-700);"><i class="bi bi-compass me-2" style="color: var(--pt-pink-500);"></i>Kích Thước Em Bé</h5>
                            <div class="d-flex align-items-center gap-3 p-3 rounded-3" style="background: var(--pt-surface-var, #fff6fb); border: 1px solid var(--pt-outline, #f0dae5);">
                                <div class="fs-1 px-3 py-2 rounded-circle bg-white" id="babyFruitIcon"
                                     style="box-shadow: 0 4px 12px rgba(194,24,91,0.12);">
                                    🍎
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1" id="babyFruitTitle" style="color: var(--pt-pink-700);">Đang tính toán...</h6>
                                    <p class="small mb-0" id="babyFruitDesc" style="color: var(--pt-muted);">Đang tải mô tả phát triển thai nhi...</p>
                                </div>
                            </div>
                            <div class="mt-3">
                                <div class="progress rounded-pill" style="height: 10px; background: var(--pt-pink-100, #ffe0ef);">
                                    <c:set var="pct" value="${(currentWeeks * 100) / 40}"/>
                                    <div class="progress-bar progress-bar-striped progress-bar-animated"
                                         role="progressbar" style="width: ${pct > 100 ? 100 : pct}%; background: linear-gradient(90deg, var(--pt-pink-600), var(--pt-pink-500));"
                                         aria-valuenow="${pct}" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                                <div class="d-flex justify-content-between small mt-2" style="color: var(--pt-muted);">
                                    <span>Bắt đầu</span>
                                    <span>Tuần thứ <strong>${currentWeeks}</strong>/40</span>
                                    <span>Ngày sinh</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Cột bên phải: Chỉ số sức khỏe & Timeline khám thai --%>
                <div class="col-lg-7">
                    <%-- Card chỉ số sức khỏe gần nhất --%>
                    <div class="card rounded-4 mb-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3" style="color: var(--pt-pink-700);">
                                <i class="bi bi-activity me-2" style="color: var(--pt-pink-500);"></i>Chỉ Số Sức Khỏe Gần Nhất
                            </h5>
                            
                            <c:choose>
                                <c:when test="${empty timeline}">
                                    <p class="text-center py-3 mb-0" style="color: var(--pt-muted);">Chưa có chỉ số sức khỏe nào được ghi nhận.</p>
                                </c:when>
                                <c:otherwise>
                                    <c:set var="lastVisit" value="${timeline[fn:length(timeline)-1]}"/>
                                    <div class="row g-3">
                                        <div class="col-6 col-sm-3">
                                            <div class="p-3 rounded-3 text-center" style="background: var(--pt-pink-50); border: 1px solid var(--pt-outline);">
                                                <i class="bi bi-speedometer fs-4" style="color: var(--pt-pink-500);"></i>
                                                <small class="d-block mt-1" style="color: var(--pt-muted);">Cân nặng mẹ</small>
                                                <strong class="fs-5">${not empty lastVisit.weight_kg ? lastVisit.weight_kg += ' kg' : '—'}</strong>
                                            </div>
                                        </div>
                                        <div class="col-6 col-sm-3">
                                            <div class="p-3 rounded-3 text-center" style="background: var(--pt-pink-50); border: 1px solid var(--pt-outline);">
                                                <i class="bi bi-heart-pulse-fill fs-4" style="color: var(--pt-pink-500);"></i>
                                                <small class="d-block mt-1" style="color: var(--pt-muted);">Tim thai</small>
                                                <strong class="fs-5">${not empty lastVisit.fetal_heart_rate ? lastVisit.fetal_heart_rate += ' nhịp/p' : '—'}</strong>
                                            </div>
                                        </div>
                                        <div class="col-6 col-sm-3">
                                            <div class="p-3 rounded-3 text-center" style="background: var(--pt-pink-50); border: 1px solid var(--pt-outline);">
                                                <i class="bi bi-droplet-half fs-4" style="color: var(--pt-pink-400);"></i>
                                                <small class="d-block mt-1" style="color: var(--pt-muted);">Huyết áp</small>
                                                <strong class="fs-5 text-truncate d-block">${not empty lastVisit.blood_pressure ? lastVisit.blood_pressure : '—'}</strong>
                                            </div>
                                        </div>
                                        <div class="col-6 col-sm-3">
                                            <div class="p-3 rounded-3 text-center" style="background: var(--pt-pink-50); border: 1px solid var(--pt-outline);">
                                                <i class="bi bi-rulers fs-4" style="color: var(--pt-pink-600);"></i>
                                                <small class="d-block mt-1" style="color: var(--pt-muted);">Bề cao tử cung</small>
                                                <strong class="fs-5">${not empty lastVisit.fundal_height_cm ? lastVisit.fundal_height_cm += ' cm' : '—'}</strong>
                                            </div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%-- Card Dòng thời gian khám thai --%>
                    <div class="card rounded-4">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-4" style="color: var(--pt-pink-700);">
                                <i class="bi bi-bezier2 me-2" style="color: var(--pt-pink-500);"></i>Dòng Thời Gian Lần Khám
                            </h5>
                            
                            <c:choose>
                                <c:when test="${empty timeline}">
                                    <div class="text-center py-5 text-muted">
                                        <i class="bi bi-journal-x fs-1 d-block mb-2 opacity-25"></i>
                                        Chưa ghi nhận lịch sử lần khám nào cho thai kỳ này.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="position-relative ps-3" style="border-left: 2px solid var(--pt-pink-200, #ffb3d1);">
                                        <c:forEach var="item" items="${timeline}" varStatus="loop">
                                            <div class="mb-4 position-relative">
                                                <%-- Dot mốc --%>
                                                <div class="position-absolute rounded-circle border-white"
                                                     style="width: 12px; height: 12px; left: -20px; top: 6px; background: var(--pt-pink-500); border: 2px solid white; box-shadow: 0 0 0 2px var(--pt-pink-200);"></div>
                                                
                                                <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-1">
                                                    <h6 class="fw-bold mb-0" style="color: var(--pt-on-surface);">
                                                        Lần khám thai lúc ${item.gestational_age_weeks} tuần ${item.gestational_age_days} ngày
                                                    </h6>
                                                    <span class="badge" style="background: var(--pt-pink-50); color: var(--pt-pink-700); border: 1px solid var(--pt-pink-200); font-weight: 600;">${item.appointment_date}</span>
                                                </div>
                                                <p class="small mb-2" style="color: var(--pt-muted);">Bác sĩ khám: <strong style="color: var(--pt-pink-700);">BS. ${item.doctor_name}</strong></p>
                                                <div class="p-3 rounded-3" style="background: var(--pt-surface-var, #fff6fb); border: 1px solid var(--pt-outline, #f0dae5);">
                                                    <div class="row g-2 small mb-2" style="color: var(--pt-on-var);">
                                                        <c:if test="${not empty item.weight_kg}">
                                                            <div class="col-sm-6"><i class="bi bi-check-circle-fill me-1" style="color: #22c55e;"></i>Cân nặng mẹ: ${item.weight_kg} kg</div>
                                                        </c:if>
                                                        <c:if test="${not empty item.fetal_heart_rate}">
                                                            <div class="col-sm-6"><i class="bi bi-check-circle-fill me-1" style="color: #22c55e;"></i>Nhịp tim thai: ${item.fetal_heart_rate} nhịp/phút</div>
                                                        </c:if>
                                                        <c:if test="${not empty item.blood_pressure}">
                                                            <div class="col-sm-6"><i class="bi bi-check-circle-fill me-1" style="color: #22c55e;"></i>Huyết áp: ${item.blood_pressure}</div>
                                                        </c:if>
                                                        <c:if test="${not empty item.fundal_height_cm}">
                                                            <div class="col-sm-6"><i class="bi bi-check-circle-fill me-1" style="color: #22c55e;"></i>Chiều cao tử cung: ${item.fundal_height_cm} cm</div>
                                                        </c:if>
                                                    </div>
                                                    <div class="border-top pt-2" style="border-color: var(--pt-outline) !important;">
                                                        <span class="d-block fw-semibold small mb-1" style="color: var(--pt-pink-700);">Chẩn đoán lâm sàng:</span>
                                                        <p class="mb-0 small" style="color: var(--pt-muted);">${not empty item.final_diagnosis ? item.final_diagnosis : 'Không có'}</p>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%-- Script so sánh kích thước em bé --%>
<script>
document.addEventListener("DOMContentLoaded", function() {
    var weeks = parseInt("${currentWeeks}");
    if (isNaN(weeks)) return;

    var babyInfo = {
        icon: "🍎",
        title: "Đang tính toán...",
        desc: "..."
    };

    if (weeks <= 4) {
        babyInfo = { icon: "🌱", title: "Hạt vừng", desc: "Phôi thai nhỏ bằng hạt vừng và đang bắt đầu hình thành các tế bào quan trọng." };
    } else if (weeks <= 8) {
        babyInfo = { icon: "🍇", title: "Quả mâm xôi", desc: "Bé đã lớn bằng quả mâm xôi, các ngón tay và chân đang dần xuất hiện." };
    } else if (weeks <= 12) {
        babyInfo = { icon: "🍋", title: "Quả chanh", desc: "Kích thước bé bằng quả chanh. Bé đã bắt đầu có các phản xạ cử động ngón tay." };
    } else if (weeks <= 16) {
        babyInfo = { icon: "🥑", title: "Quả bơ", desc: "Bé to bằng quả bơ. Xương của bé đang dần cứng cáp hơn." };
    } else if (weeks <= 20) {
        babyInfo = { icon: "🍌", title: "Quả chuối", desc: "Bé bằng quả chuối. Mẹ có thể bắt đầu cảm nhận được những cú máy thai nhẹ nhàng." };
    } else if (weeks <= 24) {
        babyInfo = { icon: "🍈", title: "Quả dưa lưới nhỏ", desc: "Bé có kích thước bằng quả dưa lưới nhỏ, các giác quan phát triển mạnh mẽ." };
    } else if (weeks <= 28) {
        babyInfo = { icon: "🥦", title: "Cây súp lơ", desc: "Kích thước bé bằng cây súp lơ. Mắt bé đã có thể nhắm mở." };
    } else if (weeks <= 32) {
        babyInfo = { icon: "🎃", title: "Quả bí ngô nhỏ", desc: "Bé bằng quả bí ngô nhỏ. Bé đang tích tụ lớp mỡ dưới da để giữ ấm cơ thể." };
    } else if (weeks <= 36) {
        babyInfo = { icon: "🍈", title: "Quả đu đủ lớn", desc: "Bé bằng quả đu đủ lớn. Bé dần quay đầu xuống phía dưới để chuẩn bị sinh." };
    } else {
        babyInfo = { icon: "🍉", title: "Quả dưa hấu", desc: "Bé yêu đã phát triển hoàn thiện như quả dưa hấu và sẵn sàng chào đời bất cứ lúc nào!" };
    }

    document.getElementById("babyFruitIcon").textContent = babyInfo.icon;
    document.getElementById("babyFruitTitle").textContent = "Bé bằng " + babyInfo.title;
    document.getElementById("babyFruitDesc").textContent = babyInfo.desc;
});
</script>

<%@ include file="../common/footer.jsp" %>
