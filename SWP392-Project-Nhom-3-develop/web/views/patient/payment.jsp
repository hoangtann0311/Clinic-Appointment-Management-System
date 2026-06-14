<body class="patient-page">

<div class="container py-5">

    <div class="card invoice-card mx-auto"
         style="max-width:700px;">

        <div class="card-header invoice-header p-4">

            <div class="d-flex justify-content-between align-items-center">

                <div>
                    <h3 class="mb-1 text-dark">
                        Medical Invoice
                    </h3>

                    <small class="text-muted">
                        Invoice #${invoice.id}
                    </small>
                </div>

                <div>
                    <i class="bi bi-receipt-cutoff"
                       style="font-size:3rem;color:#ec4899;">
                    </i>
                </div>

            </div>

        </div>

        <div class="card-body p-4">

            <div class="row mb-4">

                <div class="col-md-6">
                    <h6 class="text-muted">
                        Patient
                    </h6>

                    <p class="fw-semibold">
                        ${sessionScope.user.fullName}
                    </p>
                </div>

                <div class="col-md-6 text-md-end">
                    <h6 class="text-muted">
                        Status
                    </h6>

                    <span class="status-unpaid">
                        ${invoice.status}
                    </span>
                </div>

            </div>

            <hr>

            <div class="d-flex justify-content-between mb-3">

                <span>Appointment ID</span>

                <strong>
                    #${invoice.appointmentId}
                </strong>

            </div>

            <div class="d-flex justify-content-between mb-3">

                <span>Total Amount</span>

                <span class="patient-price">
                    ${invoice.totalAmount} VND
                </span>

            </div>

            <div class="patient-summary mt-4">

                <div class="d-flex justify-content-between">

                    <span>
                        Amount Due
                    </span>

                    <strong class="patient-price">
                        ${invoice.totalAmount} VND
                    </strong>

                </div>

            </div>

            <form method="post"
                  action="${pageContext.request.contextPath}/patient/payment">

                <input type="hidden"
                       name="invoiceId"
                       value="${invoice.id}">

                <button type="submit"
                        class="btn btn-patient w-100 mt-4">

                    <i class="bi bi-credit-card me-2"></i>
                    Pay Now

                </button>

            </form>

        </div>

    </div>

</div>

</body>