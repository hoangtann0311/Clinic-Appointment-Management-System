<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ include file="../common/header.jsp" %>

<style>
    .payment-method-card {
        border: 2px solid #dee2e6;
        border-radius: 12px;
        cursor: pointer;
        transition: border-color 0.2s, box-shadow 0.2s, transform 0.1s;
    }
    .payment-method-card:hover {
        border-color: #0d6efd;
        box-shadow: 0 0 0 3px rgba(13,110,253,0.12);
        transform: translateY(-2px);
    }
    .payment-method-card.selected {
        border-color: #0d6efd;
        background: #f0f6ff;
    }
    .payment-method-card input[type="radio"] { display: none; }
    .invoice-status-badge { font-size: 0.9rem; padding: 6px 14px; }
    .qr-box {
        background: #fff;
        border: 2px dashed #0d6efd;
        border-radius: 12px;
        padding: 20px;
        text-align: center;
    }
</style>

<div class="row justify-content-center">
    <div class="col-lg-9 col-xl-8">

        <div class="d-flex align-items-center gap-3 mb-4">
            <div style="width:56px;height:56px;border-radius:50%;background:linear-gradient(135deg,#11998e,#38ef7d);
                        display:flex;align-items:center;justify-content:center;font-size:1.6rem;color:#fff;flex-shrink:0;">
                <i class="bi bi-credit-card-2-front-fill"></i>
            </div>
            <div>
                <h2 class="fw-bold mb-0">Thanh Toán Hóa Đơn</h2>
                <p class="text-muted mb-0 small">Lịch hẹn #${appointment.id} — ${appointment.appointmentDate}</p>
            </div>
        </div>

        <%-- Alert --%>
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show">
                <i class="bi bi-check-circle-fill me-2"></i>
                <c:choose>
                    <c:when test="${success == 'ThanhToanChoXacNhan'}">
                        Thông tin thanh toán đã được ghi nhận. Vui lòng chờ nhân viên xác nhận!
                    </c:when>
                    <c:otherwise>${success}</c:otherwise>
                </c:choose>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="row g-4">
            <%-- Cột trái: thông tin lịch hẹn & hóa đơn --%>
            <div class="col-md-5">
                <div class="card h-100">
                    <div class="card-header fw-bold bg-transparent border-0 pb-0">
                        <i class="bi bi-receipt me-2 text-primary"></i>Chi Tiết Hóa Đơn
                    </div>
                    <div class="card-body">
                        <ul class="list-unstyled small mb-0">
                            <li class="d-flex justify-content-between py-2 border-bottom">
                                <span class="text-muted">Bác sĩ</span>
                                <strong>BS. ${appointment.doctorName}</strong>
                            </li>
                            <li class="d-flex justify-content-between py-2 border-bottom">
                                <span class="text-muted">Ngày khám</span>
                                <strong>${appointment.appointmentDate}</strong>
                            </li>
                            <li class="d-flex justify-content-between py-2 border-bottom">
                                <span class="text-muted">Giờ khám</span>
                                <strong>${appointment.timeSlot}</strong>
                            </li>
                            <li class="d-flex justify-content-between py-2 border-bottom">
                                <span class="text-muted">Dịch vụ</span>
                                <strong>${appointment.serviceName}</strong>
                            </li>
                            <c:if test="${not empty invoice}">
                                <li class="d-flex justify-content-between py-2 border-bottom">
                                    <span class="text-muted">Loại hóa đơn</span>
                                    <span class="badge bg-info text-dark">${invoice.invoiceType}</span>
                                </li>
                                <li class="d-flex justify-content-between py-2 border-bottom">
                                    <span class="text-muted">Số tiền</span>
                                    <strong class="text-success fs-6">
                                        <fmt:formatNumber value="${invoice.totalAmount}" pattern="#,###"/>đ
                                    </strong>
                                </li>
                                <li class="d-flex justify-content-between py-2">
                                    <span class="text-muted">Trạng thái</span>
                                    <c:choose>
                                        <c:when test="${invoice.status == 'Paid'}">
                                            <span class="badge bg-success invoice-status-badge">Đã thanh toán</span>
                                        </c:when>
                                        <c:when test="${invoice.status == 'PendingConfirmation'}">
                                            <span class="badge bg-warning text-dark invoice-status-badge">Chờ xác nhận</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary invoice-status-badge">Chưa thanh toán</span>
                                        </c:otherwise>
                                    </c:choose>
                                </li>
                            </c:if>
                        </ul>
                    </div>
                </div>
            </div>

            <%-- Cột phải: form chọn phương thức thanh toán --%>
            <div class="col-md-7">
                <c:choose>
                    <c:when test="${invoice.status == 'Paid'}">
                        <div class="card text-center py-5">
                            <div class="card-body">
                                <i class="bi bi-check-circle-fill text-success" style="font-size:3rem;"></i>
                                <h5 class="fw-bold mt-3">Hóa Đơn Đã Được Thanh Toán</h5>
                                <p class="text-muted">Phương thức: <strong>${invoice.paymentMethod}</strong></p>
                                <c:if test="${not empty invoice.transactionCode}">
                                    <p class="text-muted">Mã GD: <code>${invoice.transactionCode}</code></p>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/patient/appointments"
                                   class="btn btn-outline-primary mt-2">
                                    <i class="bi bi-arrow-left me-1"></i>Quay lại lịch hẹn
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:when test="${invoice.status == 'PendingConfirmation'}">
                        <div class="card text-center py-5">
                            <div class="card-body">
                                <i class="bi bi-hourglass-split text-warning" style="font-size:3rem;"></i>
                                <h5 class="fw-bold mt-3">Đang Chờ Xác Nhận</h5>
                                <p class="text-muted">Thông tin thanh toán đã gửi. Nhân viên sẽ xác nhận sớm.</p>
                                <c:if test="${not empty invoice.transactionCode}">
                                    <p class="text-muted">Mã giao dịch: <code>${invoice.transactionCode}</code></p>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/patient/appointments"
                                   class="btn btn-outline-secondary mt-2">
                                    <i class="bi bi-arrow-left me-1"></i>Quay lại lịch hẹn
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="card">
                            <div class="card-header fw-bold bg-transparent border-0 pb-0">
                                <i class="bi bi-wallet2 me-2 text-primary"></i>Chọn Phương Thức Thanh Toán
                            </div>
                            <div class="card-body">
                                <form method="post" action="${pageContext.request.contextPath}/patient/payment" id="paymentForm">
                                    <input type="hidden" name="invoiceId" value="${invoice.id}">

                                    <div class="row g-3 mb-4">
                                        <div class="col-6">
                                            <label class="payment-method-card d-block p-3 text-center" id="cashCard">
                                                <input type="radio" name="paymentMethod" value="Cash" id="cashRadio" onchange="showMethod('cash')">
                                                <div class="fs-1 mb-2">💵</div>
                                                <div class="fw-bold">Tiền mặt</div>
                                                <div class="text-muted small mt-1">Thanh toán tại quầy lễ tân</div>
                                            </label>
                                        </div>
                                        <div class="col-6">
                                            <label class="payment-method-card d-block p-3 text-center" id="bankCard">
                                                <input type="radio" name="paymentMethod" value="BankTransfer" id="bankRadio" onchange="showMethod('bank')">
                                                <div class="fs-1 mb-2">🏦</div>
                                                <div class="fw-bold">Chuyển khoản</div>
                                                <div class="text-muted small mt-1">Chuyển khoản ngân hàng</div>
                                            </label>
                                        </div>
                                    </div>

                                    <%-- Panel tiền mặt --%>
                                    <div id="cashPanel" style="display:none;">
                                        <div class="alert alert-info">
                                            <i class="bi bi-info-circle-fill me-2"></i>
                                            Vui lòng đến quầy lễ tân để thanh toán tiền mặt số tiền
                                            <strong><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,###"/>đ</strong>.
                                            Nhân viên sẽ xác nhận thanh toán sau.
                                        </div>
                                    </div>

                                    <%-- Panel chuyển khoản --%>
                                    <div id="bankPanel" style="display:none;">
                                        <div class="qr-box mb-3">
                                            <div class="fw-bold mb-2"><i class="bi bi-qr-code me-2"></i>Thông tin chuyển khoản</div>
                                            <table class="table table-sm mb-2 text-start">
                                                <tr><td class="text-muted">Ngân hàng</td><td><strong>Vietcombank</strong></td></tr>
                                                <tr><td class="text-muted">Số tài khoản</td><td><strong>1234567890</strong></td></tr>
                                                <tr><td class="text-muted">Chủ tài khoản</td><td><strong>PHONG KHAM SAN PHU</strong></td></tr>
                                                <tr><td class="text-muted">Số tiền</td>
                                                    <td><strong class="text-success"><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,###"/>đ</strong></td></tr>
                                                <tr><td class="text-muted">Nội dung CK</td>
                                                    <td><strong>CAMSHD${appointment.id}</strong></td></tr>
                                            </table>
                                        </div>

                                        <div class="mb-3">
                                            <label for="transactionCode" class="form-label fw-semibold">
                                                Mã giao dịch <span class="text-danger">*</span>
                                            </label>
                                            <input type="text" id="transactionCode" name="transactionCode"
                                                   class="form-control"
                                                   placeholder="Nhập mã giao dịch sau khi chuyển khoản">
                                            <div class="form-text">Nhập mã giao dịch từ ứng dụng ngân hàng để nhân viên xác nhận.</div>
                                        </div>
                                    </div>

                                    <div id="submitArea" style="display:none;">
                                        <button type="submit" class="btn btn-primary w-100 fw-semibold py-2">
                                            <i class="bi bi-send-fill me-2"></i>Gửi Thông Tin Thanh Toán
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <%-- Hóa đơn sau khám (POST_EXAM) nếu có --%>
        <c:if test="${not empty postInvoice}">
            <div class="card mt-4">
                <div class="card-header fw-bold bg-light border-0">
                    <i class="bi bi-receipt-cutoff me-2 text-success"></i>Hóa Đơn Sau Khám (POST_EXAM)
                </div>
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        Số tiền: <strong class="text-success">
                            <fmt:formatNumber value="${postInvoice.totalAmount}" pattern="#,###"/>đ
                        </strong>
                        &nbsp;|&nbsp; Trạng thái:
                        <c:choose>
                            <c:when test="${postInvoice.status == 'Paid'}">
                                <span class="badge bg-success">Đã thanh toán</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-warning text-dark">${postInvoice.status}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </c:if>

        <div class="mt-3">
            <a href="${pageContext.request.contextPath}/patient/appointments"
               class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left me-1"></i>Quay lại lịch hẹn
            </a>
        </div>

    </div>
</div>

<script>
function showMethod(method) {
    document.getElementById('cashPanel').style.display = 'none';
    document.getElementById('bankPanel').style.display = 'none';
    document.getElementById('submitArea').style.display = 'none';

    document.querySelectorAll('.payment-method-card').forEach(c => c.classList.remove('selected'));

    if (method === 'cash') {
        document.getElementById('cashPanel').style.display = 'block';
        document.getElementById('cashCard').classList.add('selected');
    } else {
        document.getElementById('bankPanel').style.display = 'block';
        document.getElementById('bankCard').classList.add('selected');
    }
    document.getElementById('submitArea').style.display = 'block';
}

document.getElementById('paymentForm') && document.getElementById('paymentForm').addEventListener('submit', function(e) {
    var method = document.querySelector('input[name="paymentMethod"]:checked');
    if (!method) {
        e.preventDefault();
        alert('Vui lòng chọn phương thức thanh toán.');
        return;
    }
    if (method.value === 'BankTransfer') {
        var txCode = document.getElementById('transactionCode').value.trim();
        if (!txCode) {
            e.preventDefault();
            alert('Vui lòng nhập mã giao dịch chuyển khoản.');
            document.getElementById('transactionCode').focus();
        }
    }
});
</script>

<%@ include file="../common/footer.jsp" %>
