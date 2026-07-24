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
        border-color: #b86689;
        box-shadow: 0 0 0 3px rgba(184,102,137,0.12);
        transform: translateY(-2px);
    }
    .payment-method-card.selected {
        border-color: #b86689;
        background: #fff1f6;
    }
    .payment-method-card input[type="radio"] { display: none; }
    .invoice-hero {
        background: linear-gradient(135deg, #f8f9fa, #e9ecef);
        border-radius: 16px;
        padding: 24px;
        border: 1px solid #dee2e6;
    }
    .invoice-hero .amount {
        font-size: 2rem;
        font-weight: 800;
        color: #b86689;
    }
</style>

<div class="row justify-content-center">
    <div class="col-lg-10 col-xl-9">

        <%-- HEADER --%>
        <div class="d-flex align-items-center gap-3 mb-4">
            <div style="width:56px;height:56px;border-radius:50%;background:linear-gradient(135deg,#d27b9f,#a75e7d);
                        display:flex;align-items:center;justify-content:center;font-size:1.6rem;color:#fff;flex-shrink:0;">
                <i class="bi bi-credit-card-2-front-fill"></i>
            </div>
            <div>
                <h2 class="fw-bold mb-0">
                    <c:choose>
                    <c:when test="${invoiceType == 'POST_EXAM'}">Thanh Toán Chỉ Định Sau Khám</c:when>
                        <c:when test="${invoiceType == 'PRESCRIPTION'}">Thanh Toán Đơn Thuốc</c:when>
                        <c:otherwise>Thanh Toán Hóa Đơn Lâm Sàng</c:otherwise>
                    </c:choose>
                </h2>
                <p class="text-muted mb-0 small">Lịch hẹn ngày ${appointment.appointmentDate}</p>
            </div>
        </div>

        <%-- ALERTS --%>
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show">
                <i class="bi bi-check-circle-fill me-2"></i>
                <c:choose>
                    <c:when test="${success == 'ThanhToanChoXacNhan'}">
                        <c:choose>
                            <c:when test="${invoice.paymentMethod == 'Cash'}">Đã đăng ký thanh toán tiền mặt. Vui lòng đến quầy lễ tân để nộp tiền và nhận xác nhận.</c:when>
                            <c:otherwise>Đã gửi yêu cầu thanh toán chuyển khoản. Vui lòng chờ nhân viên xác nhận giao dịch.</c:otherwise>
                        </c:choose>
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

        <%-- ==================== PAID: chỉ hiện thông báo thành công ==================== --%>
        <c:if test="${invoice.status == 'Paid'}">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-5">
                    <i class="bi bi-check-circle-fill text-success" style="font-size:4rem;"></i>
                    <h3 class="fw-bold mt-3 text-success">Hóa Đơn Đã Được Thanh Toán</h3>
                    <p class="text-muted mb-3">Bạn đã thanh toán hóa đơn này thành công.</p>
                    <c:if test="${invoiceType == 'PRE_EXAM'}">
                    <div class="alert alert-light border py-2 px-3 small text-start mb-4 d-inline-block" style="border-radius:10px;max-width:460px;background:#fefce8;">
                        <i class="bi bi-lock-fill me-1 text-warning"></i>
                        Lịch hẹn đã được xác nhận. Nếu cần <strong>huỷ hoặc đổi lịch</strong>, vui lòng liên hệ <strong>lễ tân</strong> để được hỗ trợ hoàn tiền và sắp xếp lại.
                    </div>
                    </c:if>
                    <div class="invoice-hero d-inline-block text-start mb-4" style="min-width:320px;">
                        <div class="row g-3">
                            <div class="col-6"><span class="text-muted small">Bác sĩ lâm sàng</span><div class="fw-bold">BS. ${appointment.doctorName}</div></div>
                            <div class="col-6"><span class="text-muted small">Ngày khám</span><div class="fw-bold">${appointment.appointmentDate}</div></div>
                            <div class="col-6"><span class="text-muted small">Giờ khám</span><div class="fw-bold">${appointment.timeSlot}</div></div>
                            <div class="col-6"><span class="text-muted small">Dịch vụ</span><div class="fw-bold">${appointment.serviceName}</div></div>
                            <div class="col-6"><span class="text-muted small">Phương thức</span><div class="fw-bold">${invoice.paymentMethod == 'Cash' ? 'Tiền mặt' : 'Chuyển khoản'}</div></div>
                            <div class="col-6"><span class="text-muted small">Trạng thái</span><div><span class="badge bg-success">Đã thanh toán</span></div></div>
                            <c:if test="${not empty invoice.transactionCode}">
                                <div class="col-12"><span class="text-muted small">Mã giao dịch</span><div><code>${invoice.transactionCode}</code></div></div>
                            </c:if>
                            <c:if test="${invoiceType == 'PRESCRIPTION' && not empty prescriptionItems}">
                                <div class="col-12">
                                    <hr class="my-2">
                                    <span class="text-muted small fw-bold mb-2 d-block">DANH SÁCH THUỐC ĐÃ THANH TOÁN</span>
                                    <div class="table-responsive">
                                        <table class="table table-sm mb-0">
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Tên thuốc</th>
                                                    <th>Đơn vị</th>
                                                    <th class="text-center">Số lượng</th>
                                                    <th class="text-end">Đơn giá</th>
                                                    <th class="text-end">Thành tiền</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="item" items="${prescriptionItems}" varStatus="st">
                                                    <tr>
                                                        <td>${st.index + 1}</td>
                                                        <td>${item.medicineName}</td>
                                                        <td>${item.medicineUnit}</td>
                                                        <td class="text-center">${item.quantity}</td>
                                                        <td class="text-end"><fmt:formatNumber value="${item.price}" pattern="#,###"/>đ</td>
                                                        <td class="text-end"><fmt:formatNumber value="${item.price * item.quantity}" pattern="#,###"/>đ</td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </c:if>
                            <c:if test="${invoiceType == 'POST_EXAM' && not empty testOrders}">
                                <div class="col-12">
                                    <hr class="my-2">
                                    <span class="text-muted small fw-bold mb-2 d-block">DANH SÁCH CHỈ ĐỊNH PHÁT SINH</span>
                                    <div class="table-responsive">
                                        <table class="table table-sm mb-0">
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Tên dịch vụ</th>
                                                    <th>Mã dịch vụ</th>
                                                    <th class="text-end">Đơn giá</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="item" items="${testOrders}" varStatus="st">
                                                    <tr>
                                                        <td>${st.index + 1}</td>
                                                        <td>${item.serviceName}</td>
                                                        <td><code>${item.serviceCode}</code></td>
                                                        <td class="text-end"><fmt:formatNumber value="${item.servicePrice}" pattern="#,###"/>đ</td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                        <hr class="my-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="text-muted fw-semibold">TỔNG TIỀN</span>
                            <span class="amount"><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,###"/>đ</span>
                        </div>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/patient/invoices" class="btn btn-outline-primary">
                            <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách hóa đơn
                        </a>
                    </div>
                </div>
            </div>
        </c:if>

        <%-- ==================== PENDING CONFIRMATION: chỉ hiện thông báo chờ ==================== --%>
        <c:if test="${invoice.status == 'PendingConfirmation'}">
            <div class="card border-0 shadow-sm">
                <div class="card-body text-center py-5">
                    <i class="bi bi-hourglass-split text-warning" style="font-size:4rem;"></i>
                    <h3 class="fw-bold mt-3">
                        ${invoice.paymentMethod == 'Cash' ? 'Chờ Thanh Toán Tại Quầy' : 'Chờ Lễ Tân Xác Nhận Chuyển Khoản'}
                    </h3>
                    <p class="text-muted mb-3">
                        ${invoice.paymentMethod == 'Cash' ? 'Bạn đã đăng ký thanh toán tiền mặt. Vui lòng đến quầy lễ tân để nộp tiền; nhân viên sẽ xác nhận sau khi thu tiền.' : 'Yêu cầu chuyển khoản đã được ghi nhận. Nhân viên sẽ kiểm tra giao dịch và xác nhận sớm.'}
                    </p>
                    <div class="alert alert-info py-2 px-3 small text-start mb-4 d-inline-block" style="border-radius:10px;max-width:480px;">
                        <i class="bi bi-info-circle-fill me-1"></i>
                        <strong>Bạn vẫn có thể huỷ hoặc đổi lịch</strong> ở giai đoạn này (chưa bị thu tiền).
                        Sau khi lễ tân <strong>xác nhận đã thanh toán</strong>, bạn sẽ không thể tự huỷ/đổi được nữa mà cần liên hệ trực tiếp lễ tân.
                    </div>
                        <div class="invoice-hero d-inline-block text-start mb-4" style="min-width:320px;">
                            <div class="row g-3">
                                <div class="col-6"><span class="text-muted small">Bác sĩ lâm sàng</span><div class="fw-bold">BS. ${appointment.doctorName}</div></div>
                                <div class="col-6"><span class="text-muted small">Ngày khám</span><div class="fw-bold">${appointment.appointmentDate}</div></div>
                                <div class="col-6"><span class="text-muted small">Giờ khám</span><div class="fw-bold">${appointment.timeSlot}</div></div>
                                <div class="col-6"><span class="text-muted small">Dịch vụ</span><div class="fw-bold"><c:choose><c:when test="${not empty appointment.serviceName}">${appointment.serviceName}</c:when><c:otherwise>Khám lâm sàng<c:if test="${not empty appointment.doctor}"> (${appointment.doctor.specialization})</c:if></c:otherwise></c:choose></div></div>
                                <c:if test="${not empty invoice.transactionCode}">
                                    <div class="col-12"><span class="text-muted small">Mã giao dịch</span><div><code>${invoice.transactionCode}</code></div></div>
                                </c:if>
                            </div>
                            <c:if test="${invoiceType == 'PRESCRIPTION' && not empty prescriptionItems}">
                                <hr class="my-3">
                                <p class="text-muted small fw-bold mb-2">DANH SÁCH THUỐC ĐÃ KÊ</p>
                                <div class="table-responsive">
                                    <table class="table table-sm mb-0">
                                        <thead>
                                            <tr>
                                                <th>#</th>
                                                <th>Tên thuốc</th>
                                                <th>Đơn vị</th>
                                                <th class="text-center">Số lượng</th>
                                                <th class="text-end">Đơn giá</th>
                                                <th class="text-end">Thành tiền</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${prescriptionItems}" varStatus="st">
                                                <tr>
                                                    <td>${st.index + 1}</td>
                                                    <td>${item.medicineName}</td>
                                                    <td>${item.medicineUnit}</td>
                                                    <td class="text-center">${item.quantity}</td>
                                                    <td class="text-end"><fmt:formatNumber value="${item.price}" pattern="#,###"/>đ</td>
                                                    <td class="text-end"><fmt:formatNumber value="${item.price * item.quantity}" pattern="#,###"/>đ</td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:if>
                            <c:if test="${invoiceType == 'POST_EXAM' && not empty testOrders}">
                                <hr class="my-3">
                                <p class="text-muted small fw-bold mb-2">DANH SÁCH CHỈ ĐỊNH PHÁT SINH</p>
                                <div class="table-responsive">
                                    <table class="table table-sm mb-0">
                                        <thead>
                                            <tr>
                                                <th>#</th>
                                                <th>Tên dịch vụ</th>
                                                <th>Mã dịch vụ</th>
                                                <th class="text-end">Đơn giá</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${testOrders}" varStatus="st">
                                                <tr>
                                                    <td>${st.index + 1}</td>
                                                    <td>${item.serviceName}</td>
                                                    <td><code>${item.serviceCode}</code></td>
                                                    <td class="text-end"><fmt:formatNumber value="${item.servicePrice}" pattern="#,###"/>đ</td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:if>
                            <hr class="my-3">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted fw-semibold">TỔNG TIỀN</span>
                                <span class="amount"><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,###"/>đ</span>
                            </div>
                        </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/patient/invoices" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách hóa đơn
                        </a>
                    </div>
                </div>
            </div>
        </c:if>

        <%-- ==================== UNPAID: chi tiết rõ + form thanh toán ==================== --%>
        <c:if test="${invoice.status == 'Unpaid'}">
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-header bg-transparent border-0 pb-0 fw-bold">
                    <i class="bi bi-receipt me-2 text-primary"></i>Chi Tiết Hóa Đơn
                </div>
                <div class="card-body">
                        <div class="invoice-hero">
                            <div class="row g-3 mb-3">
                                <div class="col-md-6"><span class="text-muted small">Bác sĩ lâm sàng</span><div class="fw-bold">BS. ${appointment.doctorName}</div></div>
                                <div class="col-md-6"><span class="text-muted small">Ngày khám</span><div class="fw-bold">${appointment.appointmentDate}</div></div>
                                <div class="col-md-6"><span class="text-muted small">Giờ khám</span><div class="fw-bold">${appointment.timeSlot}</div></div>
                                <div class="col-md-6"><span class="text-muted small">Dịch vụ</span><div class="fw-bold"><c:choose><c:when test="${not empty appointment.serviceName}">${appointment.serviceName}</c:when><c:otherwise>Khám lâm sàng<c:if test="${not empty appointment.doctor}"> (${appointment.doctor.specialization})</c:if></c:otherwise></c:choose></div></div>
                            </div>
                            <c:if test="${invoiceType == 'PRESCRIPTION' && not empty prescriptionItems}">
                                <hr class="my-3">
                                <p class="text-muted small fw-bold mb-2">DANH SÁCH THUỐC ĐÃ KÊ</p>
                                <div class="table-responsive">
                                    <table class="table table-sm mb-0">
                                        <thead>
                                            <tr>
                                                <th>#</th>
                                                <th>Tên thuốc</th>
                                                <th>Đơn vị</th>
                                                <th class="text-center">Số lượng</th>
                                                <th class="text-end">Đơn giá</th>
                                                <th class="text-end">Thành tiền</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${prescriptionItems}" varStatus="st">
                                                <tr>
                                                    <td>${st.index + 1}</td>
                                                    <td>${item.medicineName}</td>
                                                    <td>${item.medicineUnit}</td>
                                                    <td class="text-center">${item.quantity}</td>
                                                    <td class="text-end"><fmt:formatNumber value="${item.price}" pattern="#,###"/>đ</td>
                                                    <td class="text-end"><fmt:formatNumber value="${item.price * item.quantity}" pattern="#,###"/>đ</td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:if>
                            <c:if test="${invoiceType == 'POST_EXAM' && not empty testOrders}">
                                <hr class="my-3">
                                <p class="text-muted small fw-bold mb-2">DANH SÁCH CHỈ ĐỊNH PHÁT SINH</p>
                                <div class="table-responsive">
                                    <table class="table table-sm mb-0">
                                        <thead>
                                            <tr>
                                                <th>#</th>
                                                <th>Tên dịch vụ</th>
                                                <th>Mã dịch vụ</th>
                                                <th class="text-end">Đơn giá</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${testOrders}" varStatus="st">
                                                <tr>
                                                    <td>${st.index + 1}</td>
                                                    <td>${item.serviceName}</td>
                                                    <td><code>${item.serviceCode}</code></td>
                                                    <td class="text-end"><fmt:formatNumber value="${item.servicePrice}" pattern="#,###"/>đ</td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:if>
                            <c:if test="${invoiceType == 'PRESCRIPTION' && not empty previousPrescriptionTotal && previousPrescriptionTotal > 0}">
                                <div class="alert alert-info mt-2 mb-0">
                                    <i class="bi bi-info-circle me-1"></i>
                                    Đơn thuốc đã được cập nhật. Bạn đã thanh toán <strong><fmt:formatNumber value="${previousPrescriptionTotal}" pattern="#,###"/>đ</strong> trước đó.
                                    Phần chênh lệch cần thanh toán thêm: <strong class="text-danger"><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,###"/>đ</strong>.
                                </div>
                            </c:if>
                            <hr class="my-3">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted fw-semibold">TỔNG TIỀN CẦN THANH TOÁN</span>
                                <span class="amount"><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,###"/>đ</span>
                            </div>
                        </div>
                </div>
            </div>

            <div class="card border-0 shadow-sm">
                <div class="card-header bg-transparent border-0 pb-0 fw-bold">
                    <i class="bi bi-wallet2 me-2 text-primary"></i>Chọn Phương Thức Thanh Toán
                </div>
                <div class="card-body">
                    <c:if test="${not empty holdExpiresAtMillis}">
                        <div id="holdCountdownBox" class="alert alert-warning d-flex align-items-center justify-content-between mb-3">
                            <span><i class="bi bi-hourglass-split me-2"></i>Khung giờ đang được giữ chỗ cho bạn, vui lòng gửi yêu cầu thanh toán trước khi hết thời gian:</span>
                            <strong id="holdCountdownText" class="fs-5">--:--</strong>
                        </div>
                        <div id="holdExpiredBox" class="alert alert-danger" style="display:none;">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i>
                            Đã hết thời gian giữ chỗ. Slot có thể đã được nhả cho người khác — vui lòng
                            <a href="${pageContext.request.contextPath}/patient/book">đặt lịch lại</a>.
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/patient/payment" id="paymentForm">
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
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

                        <div id="cashPanel" style="display:none;">
                            <div class="alert alert-info">
                                <i class="bi bi-info-circle-fill me-2"></i>
                                Vui lòng đến quầy lễ tân để thanh toán tiền mặt số tiền
                                <strong><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,###"/>đ</strong>.
                                Nhân viên sẽ xác nhận thanh toán sau.
                            </div>
                        </div>

                        <div id="bankPanel" style="display:none;">
                            <div class="border rounded-3 p-3 mb-3 bg-light">
                                <div class="fw-bold mb-2"><i class="bi bi-bank me-2"></i>Thông Tin Chuyển Khoản</div>
                                <table class="table table-sm mb-0 text-start">
                                    <tr><td class="text-muted">Ngân hàng</td><td><strong>MB Bank (Ngân hàng Quân đội)</strong></td></tr>
                                    <tr><td class="text-muted">Số tài khoản</td><td><strong>0967629020</strong></td></tr>
                                    <tr><td class="text-muted">Chủ tài khoản</td><td><strong>PHONG KHAM SAN PHU</strong></td></tr>
                                    <tr><td class="text-muted">Số tiền</td>
                                        <td><strong class="text-success"><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,###"/>đ</strong></td></tr>
                                </table>
                            </div>

                            <div class="alert alert-info mb-0 small">
                                Chuyển đúng số tiền, sau đó gửi yêu cầu. Không cần tải ảnh minh chứng; lễ tân sẽ đối chiếu và xác nhận.
                            </div>
                        </div>

                        <div id="submitArea" style="display:none;">
                            <button type="submit" id="paymentSubmitButton" class="btn btn-primary w-100 fw-semibold py-2">
                                <i class="bi bi-send-fill me-2"></i>Gửi Thông Tin Thanh Toán
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>

        <c:if test="${invoice.status != 'Paid' && invoice.status != 'PendingConfirmation' && invoice.status != 'Unpaid'}">
            <div class="alert alert-secondary">
                <i class="bi bi-info-circle me-2"></i>Hóa đơn này thuộc dữ liệu trạng thái cũ. Vui lòng liên hệ lễ tân để được hỗ trợ.
            </div>
        </c:if>

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

    var submitButton = document.getElementById('paymentSubmitButton');
    if (submitButton) {
        submitButton.innerHTML = method === 'cash'
            ? '<i class="bi bi-send-fill me-2"></i>Gửi yêu cầu thanh toán tiền mặt'
            : '<i class="bi bi-send-fill me-2"></i>Gửi yêu cầu thanh toán chuyển khoản';
    }
}

document.getElementById('paymentForm') && document.getElementById('paymentForm').addEventListener('submit', function(e) {
    var method = document.querySelector('input[name="paymentMethod"]:checked');
    if (!method) {
        e.preventDefault();
        alert('Vui lòng chọn phương thức thanh toán.');
        return;
    }
});

<c:if test="${not empty holdExpiresAtMillis}">
(function() {
    var expiresAt = ${holdExpiresAtMillis};
    var textEl = document.getElementById('holdCountdownText');
    var boxEl = document.getElementById('holdCountdownBox');
    var expiredEl = document.getElementById('holdExpiredBox');

    function tick() {
        var remainingMs = expiresAt - Date.now();
        if (remainingMs <= 0) {
            boxEl.style.display = 'none';
            expiredEl.style.display = 'block';
            clearInterval(timer);
            return;
        }
        var totalSec = Math.floor(remainingMs / 1000);
        var mm = Math.floor(totalSec / 60);
        var ss = totalSec % 60;
        textEl.textContent = (mm < 10 ? '0' : '') + mm + ':' + (ss < 10 ? '0' : '') + ss;
    }

    tick();
    var timer = setInterval(tick, 1000);
})();
</c:if>
</script>

<%@ include file="../common/footer.jsp" %>
