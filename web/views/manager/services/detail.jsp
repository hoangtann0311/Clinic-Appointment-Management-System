<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Dịch Vụ — ${fn:escapeXml(detailService.serviceName)} — CAMS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        .detail-header {
            background: linear-gradient(135deg, #fff9fc 0%, #fff1f6 40%, #fff1f6 100%);
            border-radius: var(--r-lg); padding: 1.5rem 1.75rem;
            margin-bottom: 1.5rem; border: 1px solid var(--pink-200);
            display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem;
        }
        .detail-header h1 { font-family: var(--font-display); font-weight: 800; font-size: 1.4rem; color: var(--c-primary-dark); margin: 0; }
        .detail-card {
            background: var(--c-surface); border: 1px solid var(--c-outline-variant);
            border-radius: var(--r-lg); overflow: hidden; margin-bottom: 1.25rem;
        }
        .detail-card-header {
            background: var(--pink-50); padding: 0.8rem 1.2rem;
            border-bottom: 1px solid var(--pink-200);
            font-family: var(--font-display); font-weight: 700; color: var(--c-primary-dark); font-size: 0.95rem;
        }
        .detail-card-body { padding: 1.2rem; }
        .info-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1rem;
        }
        .info-item { display: flex; gap: 0.75rem; align-items: flex-start; }
        .info-icon {
            width: 40px; height: 40px; border-radius: var(--r-sm);
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem; color: #fff; flex-shrink: 0;
            background: linear-gradient(135deg, var(--pink-400), var(--pink-500));
        }
        .info-label { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--c-muted); }
        .info-value { font-weight: 600; color: var(--c-on-surface); font-size: 0.9rem; }
        .price-big { font-family: var(--font-display); font-size: 1.8rem; font-weight: 900; color: var(--c-primary); }

        /* Timeline */
        .timeline { position: relative; padding-left: 2rem; }
        .timeline::before { content: ''; position: absolute; left: 0.65rem; top: 0; bottom: 0; width: 2px; background: var(--pink-200); }
        .timeline-item { position: relative; margin-bottom: 1rem; padding-left: 1rem; }
        .timeline-item::before {
            content: ''; position: absolute; left: -1.65rem; top: 0.4rem;
            width: 12px; height: 12px; border-radius: 50%;
            background: var(--pink-500); border: 2px solid #fff;
            box-shadow: 0 0 0 2px var(--pink-300);
        }
        .timeline-item:first-child::before { background: var(--pink-600); box-shadow: 0 0 0 3px var(--pink-300); width: 14px; height: 14px; left: -1.7rem; }
        .timeline-body {
            background: var(--c-surface-variant); border-radius: var(--r-sm);
            padding: 0.7rem 1rem; border: 1px solid var(--c-outline-variant);
        }
        .timeline-header { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.5rem; }
        .timeline-date { font-size: 0.7rem; color: var(--c-muted); }
        .timeline-reason { font-size: 0.82rem; font-weight: 600; color: var(--c-on-surface); margin-top: 0.25rem; }
        .timeline-prices { display: flex; align-items: center; gap: 0.6rem; margin-top: 0.3rem; }
        .t-old { color: #c62828; text-decoration: line-through; font-weight: 700; font-size: 0.9rem; }
        .t-arrow { color: var(--pink-500); font-size: 0.9rem; }
        .t-new { color: #2e7d32; font-weight: 800; font-size: 0.95rem; }
        .t-init { background: var(--pink-100); color: var(--pink-700); font-size: 0.65rem; padding: 2px 8px; border-radius: var(--r-pill); font-weight: 700; }

        .btn-back {
            display: inline-flex; align-items: center; gap: 0.35rem;
            padding: 0.5rem 1rem; border-radius: var(--r-sm);
            background: var(--c-surface); border: 1px solid var(--c-outline);
            color: var(--c-on-surface-var); font-weight: 600; font-size: 0.85rem;
            text-decoration: none; transition: all var(--t-fast);
        }
        .btn-back:hover { background: var(--pink-50); border-color: var(--pink-300); color: var(--c-primary); }

        .badge-status-large { font-size: 0.85rem; padding: 0.4rem 1rem; border-radius: var(--r-pill); font-weight: 700; }
        .empty-state { text-align: center; padding: 3rem 1rem; color: var(--c-muted); }
    </style>
</head>
<body class="admin-body">

<nav class="admin-topbar">
    <div class="admin-topbar-left">
        <button class="admin-sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
            <i class="bi bi-list"></i>
        </button>
        <a href="${pageContext.request.contextPath}/manager/dashboard" class="admin-topbar-brand">
            <i class="bi bi-hospital-fill"></i> CAMS <span class="brand-badge">Quản Lý</span>
        </a>
    </div>
    <div class="admin-topbar-right">
        <div class="admin-topbar-user d-none d-md-flex">
            <div class="admin-avatar-sm">${fn:substring(sessionScope.user.fullName, 0, 1)}</div>
            <span>${sessionScope.user.fullName}</span>
            <span class="admin-topbar-role"><i class="bi bi-briefcase-fill me-1"></i>Quản Lý</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-topbar-logout"><i class="bi bi-box-arrow-right"></i></a>
    </div>
</nav>

<%@ include file="../layout/sidebar.jsp" %>

<main class="admin-main" id="adminMain">

    <%-- Back button --%>
    <a href="${pageContext.request.contextPath}/manager/services/" class="btn-back mb-3">
        <i class="bi bi-arrow-left"></i> Quay lại danh sách
    </a>

    <%-- Header --%>
    <div class="detail-header">
        <div>
            <h1>
                <i class="bi ${not empty detailService.categoryIcon ? detailService.categoryIcon : 'bi-clipboard2-heart'}" style="color:var(--pink-500);"></i>
                ${fn:escapeXml(detailService.serviceName)}
            </h1>
            <div style="font-size:0.85rem; color:var(--c-muted); margin-top:0.2rem;">
                Mã: <strong>${fn:escapeXml(detailService.serviceCode)}</strong> &mdash; ID: #${detailService.id}
            </div>
        </div>
        <div class="d-flex align-items-center gap-3">
            <c:choose>
                <c:when test="${detailService.active}">
                    <span class="badge-status-large" style="background:#e8f5e9;color:#2e7d32;border:1px solid #a5d6a7;">
                        <i class="bi bi-check-circle-fill me-1"></i>Đang hoạt động
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="badge-status-large" style="background:#f5f5f5;color:#757575;border:1px solid #e0e0e0;">
                        <i class="bi bi-slash-circle-fill me-1"></i>Ngừng hoạt động
                    </span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="row g-3">
        <%-- Left: Info --%>
        <div class="col-lg-7">
            <div class="detail-card">
                <div class="detail-card-header">
                    <i class="bi bi-info-circle me-2"></i>Thông tin dịch vụ
                </div>
                <div class="detail-card-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <div class="info-icon"><i class="bi bi-tag"></i></div>
                            <div>
                                <div class="info-label">Nhóm dịch vụ</div>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${not empty detailService.categoryName}">
                                            <i class="bi ${not empty detailService.categoryIcon ? detailService.categoryIcon : 'bi-folder'} me-1"></i>
                                            ${fn:escapeXml(detailService.categoryName)}
                                        </c:when>
                                        <c:otherwise><span style="color:var(--c-muted);">Chưa phân nhóm</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background: linear-gradient(135deg, #43a047, #2e7d32);">
                                <i class="bi bi-cash-stack"></i>
                            </div>
                            <div>
                                <div class="info-label">Đơn giá hiện tại</div>
                                <div class="price-big">
                                    <fmt:formatNumber value="${detailService.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                </div>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background: linear-gradient(135deg, #6366f1, #4f46e5);">
                                <i class="bi bi-clock"></i>
                            </div>
                            <div>
                                <div class="info-label">Thời gian thực hiện</div>
                                <div class="info-value">
                                    ${detailService.durationMins > 0 ? detailService.durationMins.toString().concat(' phút') : 'Chưa xác định'}
                                </div>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background: linear-gradient(135deg, #0891b2, #0e7490);">
                                <i class="bi bi-people"></i>
                            </div>
                            <div>
                                <div class="info-label">Lượt sử dụng</div>
                                <div class="info-value">${detailUsageCount} lượt</div>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background: linear-gradient(135deg, #e65100, #bf360c);">
                                <i class="bi bi-door-open"></i>
                            </div>
                            <div>
                                <div class="info-label">Phòng yêu cầu</div>
                                <div class="info-value">${not empty detailService.requiredRoomType ? fn:escapeXml(detailService.requiredRoomType) : 'Không yêu cầu'}</div>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background: linear-gradient(135deg, #d99ab4, #d27b9f);">
                                <i class="bi bi-heart-pulse"></i>
                            </div>
                            <div>
                                <div class="info-label">Chuyên khoa</div>
                                <div class="info-value">${not empty detailService.allowedSpecialties ? fn:escapeXml(detailService.allowedSpecialties) : 'Tất cả'}</div>
                            </div>
                        </div>
                    </div>

                    <%-- Requirements --%>
                    <div class="d-flex gap-2 mt-3 flex-wrap">
                        <c:if test="${detailService.requiresFasting}">
                            <span style="background:#fff3e0;color:#e65100;padding:4px 12px;border-radius:var(--r-pill);font-size:0.78rem;font-weight:700;">
                                <i class="bi bi-cup-hot me-1"></i>Yêu cầu nhịn ăn
                            </span>
                        </c:if>
                        <c:if test="${detailService.requiresFullBladder}">
                            <span style="background:#e3f2fd;color:#0d47a1;padding:4px 12px;border-radius:var(--r-pill);font-size:0.78rem;font-weight:700;">
                                <i class="bi bi-droplet-fill me-1"></i>Yêu cầu đầy bàng quang
                            </span>
                        </c:if>
                        <c:if test="${!detailService.requiresFasting && !detailService.requiresFullBladder}">
                            <span style="background:#f5f5f5;color:#757575;padding:4px 12px;border-radius:var(--r-pill);font-size:0.78rem;">
                                Không có yêu cầu đặc biệt
                            </span>
                        </c:if>
                    </div>

                    <%-- Description --%>
                    <c:if test="${not empty detailService.description}">
                        <div class="mt-3">
                            <div class="info-label mb-1">Mô tả</div>
                            <div style="color:var(--c-on-surface-var);font-size:0.85rem;line-height:1.6;background:var(--c-surface-variant);padding:0.75rem 1rem;border-radius:var(--r-sm);">
                                ${fn:escapeXml(detailService.description)}
                            </div>
                        </div>
                    </c:if>

                    <%-- Dates --%>
                    <div class="d-flex gap-4 mt-3" style="font-size:0.72rem;color:var(--c-muted);">
                        <span><i class="bi bi-calendar-plus me-1"></i>Tạo: <fmt:formatDate value="${detailService.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                        <span><i class="bi bi-calendar-check me-1"></i>Cập nhật: <fmt:formatDate value="${detailService.updatedAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Right: Price History --%>
        <div class="col-lg-5">
            <div class="detail-card">
                <div class="detail-card-header">
                    <i class="bi bi-clock-history me-2"></i>Lịch sử điều chỉnh giá
                    <span class="badge bg-white text-dark border ms-2" style="font-size:0.7rem;">${fn:length(priceHistory)} lần</span>
                </div>
                <div class="detail-card-body" style="max-height:500px;overflow-y:auto;">
                    <c:choose>
                        <c:when test="${not empty priceHistory}">
                            <div class="timeline">
                                <c:forEach var="ph" items="${priceHistory}">
                                    <div class="timeline-item">
                                        <div class="timeline-body">
                                            <div class="timeline-header">
                                                <span class="timeline-date">
                                                    <i class="bi bi-calendar-event me-1"></i>
                                                    <fmt:formatDate value="${ph.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </span>
                                                <c:choose>
                                                    <c:when test="${empty ph.oldPrice}">
                                                        <span class="t-init">KHỞI TẠO</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="font-size:0.7rem;color:var(--c-muted);">
                                                            <c:if test="${not empty ph.changedByName}">
                                                                <i class="bi bi-person me-1"></i>${fn:escapeXml(ph.changedByName)}
                                                            </c:if>
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="timeline-reason">
                                                ${not empty ph.changeReason ? fn:escapeXml(ph.changeReason) : 'Cập nhật giá'}
                                            </div>
                                            <div class="timeline-prices">
                                                <c:choose>
                                                    <c:when test="${empty ph.oldPrice}">
                                                        <span class="t-new">
                                                            <fmt:formatNumber value="${ph.newPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="t-old">
                                                            <fmt:formatNumber value="${ph.oldPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                        </span>
                                                        <span class="t-arrow"><i class="bi bi-arrow-right"></i></span>
                                                        <span class="t-new">
                                                            <fmt:formatNumber value="${ph.newPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                        </span>
                                                        <c:set var="diff" value="${ph.newPrice.subtract(ph.oldPrice)}"/>
                                                        <span style="font-size:0.72rem;color:${diff.signum() >= 0 ? '#2e7d32' : '#c62828'};font-weight:700;">
                                                            ${diff.signum() >= 0 ? '+' : ''}<fmt:formatNumber value="${diff}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="bi bi-clock-history" style="font-size:2.5rem;"></i>
                                <h6 class="mt-2">Chưa có lịch sử giá</h6>
                                <p style="font-size:0.8rem;">Dịch vụ này chưa từng được điều chỉnh giá.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
<script>
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });
(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    for (var i = 0; i < links.length; i++) {
        if (links[i].href && links[i].href.indexOf('/manager/services') !== -1) {
            links[i].classList.add('active');
        }
    }
})();
</script>

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
