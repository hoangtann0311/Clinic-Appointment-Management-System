<body class="patient-page">

<div class="container py-5">

    <div class="card patient-card">

        <div class="card-header">
            <h4>
                <i class="bi bi-calendar-heart me-2"></i>
                Book Appointment
            </h4>
        </div>

        <div class="card-body">

            <form class="patient-form"
                  method="post"
                  action="${pageContext.request.contextPath}/patient/book-appointment">

                <div class="row g-3">

                    <div class="col-md-6">
                        <label class="form-label">
                            Doctor
                        </label>

                        <select class="form-select"
                                name="doctorId"
                                required>
                            <option value="">
                                Select Doctor
                            </option>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label">
                            Service
                        </label>

                        <select class="form-select"
                                name="serviceId"
                                required>
                            <option value="">
                                Select Service
                            </option>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label">
                            Appointment Date
                        </label>

                        <input type="date"
                               class="form-control"
                               name="appointmentDate">
                    </div>

                    <div class="col-md-6">
                        <label class="form-label">
                            Time Slot
                        </label>

                        <input type="time"
                               class="form-control"
                               name="timeSlot">
                    </div>

                    <div class="col-12">
                        <label class="form-label">
                            Symptoms
                        </label>

                        <textarea
                            class="form-control"
                            rows="4"
                            name="symptoms"></textarea>
                    </div>

                    <div class="col-12">
                        <button class="btn btn-patient w-100">
                            Book Appointment
                        </button>
                    </div>

                </div>

            </form>

        </div>

    </div>

</div>

</body>