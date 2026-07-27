<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Giao Dịch #${invoice.id} — CAMS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css?v=202" rel="stylesheet">

    <style>
        .detail-header {
            background: linear-gradient(135deg, #F0F7FF 0%, #E0EFFF 40%, #E0EFFF 100%);
            border-radius: var(--r-lg); padding: 1.5rem 1.75rem;
            margin-bottom: 1.5rem; border: 1px solid var(--pink-200);
            display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem;
        }
        .detail-header h1 {
            font-family: 'Nunito','Be Vietnam Pro',sans-serif;
            font-weight: 800; font-size: 1.4rem; color: var(--c-primary-dark); margin: 0;
        }
        .detail-card {
            background: var(--c-surface); border: 1px solid var(--c-outline-variant);
            border-radius: var(--r-lg); overflow: hidden; margin-bottom: 1.25rem;
        }
        .detail-card-header {
            background: var(--pink-50); padding: 0.8rem 1.2rem;
            border-bottom: 1px solid var(--pink-200);
            font-family: 'Nunito','Be Vietnam Pro',sans-serif;
            font-weight: 700; color: var(--c-primary-dark); font-size: 0.95rem;
            display: flex; align-items: center; gap: 0.5rem;
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
        .price-big {
            font-family: 'Nunito','Be Vietnam Pro',sans-serif;
            font-size: 1.8rem; font-weight: 900; color: #059669;
        }
        .btn-back {
            display: inline-flex; align-items: center; gap: 0.35rem;
            padding: 0.5rem 1rem; border-radius: var(--r-sm);
            background: var(--c-surface); border: 1px solid var(--c-outline);
            color: var(--c-on-surface-var); font-weight: 600; font-size: 0.85rem;
            text-decoration: none; transition: all var(--t-fast);
        }
        .btn-back:hover { background: var(--c-surface-variant); }
        .status-badge-lg {
            display: inline-block; padding: 4px 14px; border-radius: var(--r-pill);
            font-size: 0.78rem; font-weight: 700;
        }
        .status-paid { background: #D1FAE5; color: #065F46; }
        .status-pending { background: #FEF3C7; color: #92400E; }
        .status-cancelled { background: #FEE2E2; color: #991B1B; }
        .status-unpaid { background: #F3F4F6; color: #6B7280; }
    </style>
</head>
<body class="admin-body">

<%-- TOP BAR --%>
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
        <div class="dropdown admin-topbar-dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle"
               id="adminUserDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="admin-avatar-sm me-2">
                    ${not empty sessionScope.user.fullName ? fn:substring(sessionScope.user.fullName, 0, 1) : '?'}
                </div>
                <span class="d-none d-md-inline fw-semibold text-dark">${sessionScope.user.fullName}</span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg rounded-3" aria-labelledby="adminUserDropdown">
                <li class="dropdown-header">
                    <h6 class="text-dark mb-0 fw-bold">${sessionScope.user.fullName}</h6>
                    <small class="text-muted">Quản lý</small>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/manager/profile"><i class="bi bi-person-circle me-2 text-muted"></i>Hồ Sơ Cá Nhân</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i>Đăng Xuất</a></li>
            </ul>
        </div>
    </div>
</nav>

<%-- SIDEBAR --%>
<%@ include file="../layout/sidebar.jsp" %>

<%-- MAIN CONTENT --%>
<main class="admin-main" id="adminMain">

    <div class="detail-header">
        <div>
            <h1><i class="bi bi-receipt me-2"></i>Chi Tiết Giao Dịch #${invoice.id}</h1>
            <p class="mb-0 mt-1" style="font-size:0.85rem;color:var(--c-on-surface-var);">
                <i class="bi bi-calendar-check me-1"></i>
                Ngày tạo: <fmt:formatDate value="${invoice.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/manager/revenue/" class="btn-back">
            <i class="bi bi-arrow-left"></i> Quay lại danh sách
        </a>
    </div>

    <%-- Thông tin thanh toán --%>
    <div class="detail-card">
        <div class="detail-card-header">
            <i class="bi bi-credit-card"></i> Thông Tin Thanh Toán
        </div>
        <div class="detail-card-body">
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-hash"></i></div>
                    <div>
                        <div class="info-label">Mã Hóa Đơn</div>
                        <div class="info-value">#${invoice.id}</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-upc-scan"></i></div>
                    <div>
                        <div class="info-label">Mã Giao Dịch</div>
                        <div class="info-value">${not empty invoice.transactionCode ? fn:escapeXml(invoice.transactionCode) : '—'}</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-tag-fill"></i></div>
                    <div>
                        <div class="info-label">Loại Hóa Đơn</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${invoice.invoiceType == 'PRE_EXAM'}">Khám lâm sàng</c:when>
                                <c:when test="${invoice.invoiceType == 'POST_EXAM'}">Xét nghiệm / Siêu âm</c:when>
                                <c:when test="${invoice.invoiceType == 'PRESCRIPTION'}">Đơn thuốc</c:when>
                                <c:otherwise>${fn:escapeXml(invoice.invoiceType)}</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-wallet2"></i></div>
                    <div>
                        <div class="info-label">Phương Thức Thanh Toán</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${invoice.paymentMethod == 'Cash'}">Tiền mặt</c:when>
                                <c:when test="${invoice.paymentMethod == 'BankTransfer'}">Chuyển khoản</c:when>
                                <c:otherwise>${not empty invoice.paymentMethod ? fn:escapeXml(invoice.paymentMethod) : '—'}</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-check-circle"></i></div>
                    <div>
                        <div class="info-label">Trạng Thái</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${invoice.status == 'Paid'}"><span class="status-badge-lg status-paid">Đã thanh toán</span></c:when>
                                <c:when test="${invoice.status == 'PendingConfirmation'}"><span class="status-badge-lg status-pending">Chờ xác nhận</span></c:when>
                                <c:when test="${invoice.status == 'Cancelled'}"><span class="status-badge-lg status-cancelled">Đã hủy</span></c:when>
                                <c:otherwise><span class="status-badge-lg status-unpaid">${fn:escapeXml(invoice.status)}</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-calendar-check"></i></div>
                    <div>
                        <div class="info-label">Ngày Xác Nhận</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${not empty invoice.confirmedAt}">
                                    <fmt:formatDate value="${invoice.confirmedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                </c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-person-check"></i></div>
                    <div>
                        <div class="info-label">Xác Nhận Bởi</div>
                        <div class="info-value">${not empty invoice.confirmedByName ? fn:escapeXml(invoice.confirmedByName) : '—'}</div>
                    </div>
                </div>
            </div>

            <c:if test="${not empty invoice.paymentNote}">
                <div class="mt-3 p-2 rounded" style="background:var(--c-surface-variant);font-size:0.85rem;">
                    <strong><i class="bi bi-chat-left-text me-1"></i>Ghi chú:</strong>
                    ${fn:escapeXml(invoice.paymentNote)}
                </div>
            </c:if>
        </div>
    </div>

    <%-- Thông tin lịch hẹn & bệnh nhân --%>
    <div class="detail-card">
        <div class="detail-card-header">
            <i class="bi bi-calendar-heart"></i> Thông Tin Lịch Hẹn & Bệnh Nhân
        </div>
        <div class="detail-card-body">
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-person-fill"></i></div>
                    <div>
                        <div class="info-label">Bệnh Nhân</div>
                        <div class="info-value">${not empty invoice.patientName ? fn:escapeXml(invoice.patientName) : '—'}</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-telephone-fill"></i></div>
                    <div>
                        <div class="info-label">SĐT Bệnh Nhân</div>
                        <div class="info-value">${not empty invoice.patientPhone ? fn:escapeXml(invoice.patientPhone) : '—'}</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-calendar-date"></i></div>
                    <div>
                        <div class="info-label">Ngày Lịch Hẹn</div>
                        <div class="info-value">${not empty invoice.appointmentDate ? invoice.appointmentDate : '—'}</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-person-badge"></i></div>
                    <div>
                        <div class="info-label">Bác Sĩ Phụ Trách</div>
                        <div class="info-value">${not empty invoice.doctorName ? fn:escapeXml(invoice.doctorName) : '—'}</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-clipboard2-pulse"></i></div>
                    <div>
                        <div class="info-label">Dịch Vụ</div>
                        <div class="info-value">${not empty invoice.serviceName ? fn:escapeXml(invoice.serviceName) : '—'}</div>
                    </div>
                </div>
                <c:if test="${not empty invoice.appointmentId}">
                <div class="info-item">
                    <div class="info-icon"><i class="bi bi-link-45deg"></i></div>
                    <div>
                        <div class="info-label">Mã Lịch Hẹn</div>
                        <div class="info-value">#${invoice.appointmentId}</div>
                    </div>
                </div>
                </c:if>
            </div>
        </div>
    </div>

    <%-- Số tiền --%>
    <div class="detail-card">
        <div class="detail-card-header">
            <i class="bi bi-cash-stack"></i> Số Tiền
        </div>
        <div class="detail-card-body text-center">
            <div style="font-size:0.75rem;font-weight:700;text-transform:uppercase;letter-spacing:0.05em;color:var(--c-muted);margin-bottom:0.5rem;">
                Tổng Số Tiền Thanh Toán
            </div>
            <div class="price-big">
                <fmt:formatNumber value="${invoice.totalAmount}" pattern="#,###"/> VNĐ
            </div>
        </div>
    </div>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
var toggleBtn = document.getElementById('sidebarToggle');
if (toggleBtn) toggleBtn.addEventListener('click', toggleSidebar);
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeSidebar(); });
</script>

<%@ include file="../../common/standalone-footer.jsp" %>
</body>
</html>
