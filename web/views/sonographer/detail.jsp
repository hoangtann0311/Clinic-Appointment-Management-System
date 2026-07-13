<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi Tiết Chỉ Định Siêu Âm #SA-${order.orderId} - CAMS</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        .timeline-wrapper {
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
            margin: 20px 0 40px;
        }
        .timeline-line {
            position: absolute;
            top: 50%;
            left: 5%;
            right: 5%;
            height: 4px;
            background-color: #dee2e6;
            z-index: 1;
            transform: translateY(-50%);
        }
        .timeline-progress {
            position: absolute;
            top: 50%;
            left: 5%;
            width: 0%;
            height: 4px;
            background-color: var(--rose-500);
            z-index: 2;
            transform: translateY(-50%);
            transition: width 0.4s ease;
        }
        .timeline-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            z-index: 3;
            width: 18%;
        }
        .step-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #fff;
            border: 3px solid #dee2e6;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: #6c757d;
            transition: all 0.3s ease;
        }
        .timeline-step.active .step-icon {
            border-color: var(--rose-500);
            color: var(--rose-500);
            box-shadow: 0 0 0 4px var(--rose-100);
        }
        .timeline-step.completed .step-icon {
            background-color: var(--rose-500);
            border-color: var(--rose-500);
            color: #fff;
        }
        .step-label {
            margin-top: 8px;
            font-size: 13px;
            font-weight: 600;
            color: #6c757d;
            text-align: center;
        }
        .timeline-step.active .step-label,
        .timeline-step.completed .step-label {
            color: var(--rose-700);
        }
        .preview-img-container {
            position: relative;
            display: inline-block;
            border-radius: 12px;
            overflow: hidden;
            border: 2px solid #dee2e6;
            margin-top: 15px;
        }
        .preview-img {
            max-width: 100%;
            max-height: 350px;
            display: block;
        }
        /* Fullscreen Image Viewer Modal Styles */
        #imageViewerModal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(15, 23, 42, 0.95);
            z-index: 10000;
            overflow: hidden;
            user-select: none;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            cursor: pointer;
        }
        .viewer-img {
            max-width: 90vw;
            max-height: 80vh;
            box-shadow: 0 10px 40px rgba(0,0,0,0.5);
            border-radius: 8px;
            cursor: default;
            object-fit: contain;
        }
        .ai-pulse-bar {
            height: 6px;
            background-color: var(--rose-500);
            width: 100%;
            animation: pulse-width 2s infinite ease-in-out;
            border-radius: 3px;
        }
        @keyframes pulse-width {
            0% { width: 0%; margin-left: 0%; }
            50% { width: 80%; margin-left: 10%; }
            100% { width: 0%; margin-left: 100%; }
        }
    </style>
</head>
<body class="admin-body">

<jsp:include page="../common/header.jsp" />

<!-- Page Header with Back Button -->
<div class="admin-page-header">
    <div class="admin-page-header-left">
        <div class="d-flex align-items-center gap-3">
            <a href="${pageContext.request.contextPath}/sonographer/waiting-list" class="btn btn-outline-secondary btn-sm" title="Quay lại danh sách">
                <i class="bi bi-arrow-left"></i> Quay lại
            </a>
            <h1 class="admin-page-title">Chi Tiết Yêu Cầu Siêu Âm</h1>
        </div>
        <div class="admin-page-subtitle ms-5">
            Quản lý siêu âm &gt; Chi tiết ca chỉ định #SA-${order.orderId}
        </div>
    </div>
</div>

<!-- Alerts -->
<c:if test="${not empty param.success}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>
        <c:choose>
            <c:when test="${param.success == 'started'}">Đã chuyển trạng thái sang "Đang tiến hành siêu âm".</c:when>
            <c:when test="${param.success == 'uploaded'}">Tải hình ảnh siêu âm lên thành công!</c:when>
            <c:when test="${param.success == 'analyzed'}">AI Engine đã phân tích hình ảnh thành công!</c:when>
            <c:otherwise>Thực hiện thao tác thành công!</c:otherwise>
        </c:choose>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
<c:if test="${not empty param.error}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <c:out value="${param.error}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<!-- Progress Timeline -->
<div class="admin-card mb-4 p-4">
    <div class="timeline-wrapper">
        <div class="timeline-line"></div>
        <div class="timeline-progress" id="timelineProgress"></div>

        <!-- STEP 1: Pending -->
        <div class="timeline-step" id="stepPending">
            <div class="step-icon"><i class="bi bi-clipboard"></i></div>
            <div class="step-label">Chờ tiếp nhận</div>
        </div>

        <!-- STEP 2: InProgress -->
        <div class="timeline-step" id="stepInProgress">
            <div class="step-icon"><i class="bi bi-play-fill"></i></div>
            <div class="step-label">Đang siêu âm</div>
        </div>

        <!-- STEP 3: Uploaded -->
        <div class="timeline-step" id="stepUploaded">
            <div class="step-icon"><i class="bi bi-image"></i></div>
            <div class="step-label">Đã tải ảnh</div>
        </div>

        <!-- STEP 4: Analyzing -->
        <div class="timeline-step" id="stepAnalyzing">
            <div class="step-icon"><i class="bi bi-cpu"></i></div>
            <div class="step-label">AI phân tích</div>
        </div>

        <!-- STEP 5: Completed -->
        <div class="timeline-step" id="stepCompleted">
            <div class="step-icon"><i class="bi bi-check-lg"></i></div>
            <div class="step-label">Hoàn thành</div>
        </div>
    </div>
</div>

<div class="row">
    <!-- LEFT SIDE: Patient & Order Details -->
    <div class="col-lg-5">
        <div class="admin-card mb-4">
            <div class="card-header bg-white py-3">
                <h5 class="m-0 fw-bold text-dark"><i class="bi bi-person-lines-fill text-primary"></i> Thông Tin Chỉ Định</h5>
            </div>
            <div class="card-body">
                <table class="table table-borderless m-0">
                    <tr>
                        <td class="text-muted w-40 small fw-bold">SẢN PHỤ</td>
                        <td class="fw-bold text-dark"><c:out value="${order.patientName}"/></td>
                    </tr>
                    <tr>
                        <td class="text-muted small fw-bold">NGÀY SINH</td>
                        <td class="text-dark"><c:out value="${order.dateOfBirth}"/></td>
                    </tr>
                    <tr>
                        <td class="text-muted small fw-bold">SỐ ĐIỆN THOẠI</td>
                        <td class="text-dark"><c:out value="${order.phoneNumber}"/></td>
                    </tr>
                    <tr>
                        <td class="text-muted small fw-bold">DỊCH VỤ SIÊU ÂM</td>
                        <td class="fw-bold text-primary"><c:out value="${order.serviceName}"/></td>
                    </tr>
                    <tr>
                        <td class="text-muted small fw-bold">GIÁ TIỀN</td>
                        <td class="text-danger fw-bold"><c:out value="${String.format('%,.0f', order.price)}"/>đ</td>
                    </tr>
                    <tr>
                        <td class="text-muted small fw-bold">YÊU CẦU ĐẶC BIỆT</td>
                        <td>
                            <c:if test="${order.requiresFasting}">
                                <span class="badge bg-warning text-dark me-1"><i class="bi bi-exclamation-triangle"></i> Nhịn ăn</span>
                            </c:if>
                            <c:if test="${order.requiresFullBladder}">
                                <span class="badge bg-info text-dark"><i class="bi bi-droplet-fill"></i> Nhịn tiểu/Bàng quang căng</span>
                            </c:if>
                            <c:if test="${!order.requiresFasting && !order.requiresFullBladder}">
                                <span class="text-muted small">Không có yêu cầu đặc biệt</span>
                            </c:if>
                        </td>
                    </tr>
                    <tr>
                        <td class="text-muted small fw-bold">BÁC SĨ CHỈ ĐỊNH</td>
                        <td class="text-dark">BS. <c:out value="${order.doctorName}"/></td>
                    </tr>
                    <tr>
                        <td class="text-muted small fw-bold">MỨC ƯU TIÊN</td>
                        <td>
                            <c:choose>
                                <c:when test="${order.emergency}">
                                    <span class="badge bg-danger text-white fw-bold"><i class="bi bi-exclamation-triangle-fill"></i> KHẨN CẤP (SOS)</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-light text-muted border">Thường</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                    <tr>
                        <td class="text-muted small fw-bold">THỜI GIAN TẠO</td>
                        <td class="text-dark"><c:out value="${order.createdAt}"/></td>
                    </tr>
                    <tr>
                        <td class="text-muted small fw-bold">TRIỆU CHỨNG KHÁM</td>
                        <td class="text-dark-emphasis italic"><c:out value="${order.symptoms != null ? order.symptoms : 'Không có'}"/></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

    <!-- RIGHT SIDE: Actions & AI Analysis results -->
    <div class="col-lg-7">
        <!-- Actions based on status -->
        <div class="admin-card mb-4">
            <div class="card-header bg-white py-3">
                <h5 class="m-0 fw-bold text-dark"><i class="bi bi-activity text-primary"></i> Tiến Trình Nghiệp Vụ</h5>
            </div>
            <div class="card-body">
                <!-- 1. PENDING: Button to start ultrasound -->
                <c:if test="${fn:toLowerCase(order.status) == 'pending' || fn:toLowerCase(order.status) == 'waiting' || fn:toLowerCase(order.status) == 'ordered'}">
                    <div class="text-center py-4">
                        <i class="bi bi-hospital fs-1 text-secondary mb-3 d-block"></i>
                        <p class="text-muted mb-4">Ca siêu âm đang ở trạng thái chờ tiếp nhận. Vui lòng nhấn nút bên dưới để chuyển sang trạng thái đang thực hiện.</p>
                        <a href="${pageContext.request.contextPath}/sonographer/detail?orderId=${order.orderId}&action=start" class="btn btn-success fw-bold px-4 py-2">
                            <i class="bi bi-play-fill fs-5"></i> Bắt đầu làm siêu âm
                        </a>
                    </div>
                </c:if>

                <!-- 2. IN PROGRESS / UPLOADED: Upload images form -->
                <c:if test="${fn:toLowerCase(order.status) == 'inprogress' || fn:toLowerCase(order.status) == 'uploaded'}">
                    <div>
                        <h6 class="fw-bold text-dark mb-3"><i class="bi bi-upload text-rose"></i> Tải hình ảnh siêu âm lên hệ thống</h6>
                        
                        <!-- Uploaded Images List (if any) -->
                        <c:if test="${not empty images}">
                            <div class="mb-4">
                                <label class="text-muted small fw-bold mb-2">ẢNH ĐÃ TẢI LÊN</label>
                                <div class="row g-2">
                                    <c:forEach var="img" items="${images}">
                                        <div class="col-md-4">
                                            <div class="border rounded p-2 text-center bg-light">
                                                <img src="${pageContext.request.contextPath}/${img.filePath}" class="img-fluid rounded mb-2 border" style="max-height: 100px; object-fit: cover; cursor: zoom-in;" onclick="openViewer(this.src, 'Ảnh siêu âm tải lên: ${fn:escapeXml(img.originalFilename)}')">
                                                <div class="small text-truncate" title="${img.originalFilename}">${img.originalFilename}</div>
                                                <div class="text-muted" style="font-size: 10px;">${String.format('%,.1f KB', img.fileSize / 1024.0)}</div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>

                        <form method="POST" action="${pageContext.request.contextPath}/sonographer/upload" enctype="multipart/form-data" class="border p-3 rounded bg-light">
                            <input type="hidden" name="orderId" value="${order.orderId}">
                            <div class="mb-3">
                                <label for="fileUpload" class="form-label fw-bold text-dark">Chọn file ảnh siêu âm (JPG, JPEG, PNG, Tối đa 10MB)</label>
                                <input class="form-control" type="file" id="fileUpload" name="file" onchange="previewImage(event)" required>
                            </div>
                            <!-- Image Preview Container -->
                            <div id="imagePreviewContainer" style="display: none;" class="text-center mb-3">
                                <div class="preview-img-container">
                                    <img id="imagePreview" class="preview-img" alt="Xem trước ảnh siêu âm">
                                </div>
                            </div>
                            <button type="submit" class="btn btn-primary fw-bold w-100">
                                <i class="bi bi-cloud-arrow-up-fill"></i> Tải ảnh lên máy chủ
                            </button>
                        </form>

                        <!-- If Uploaded, allow sending to AI -->
                        <c:if test="${fn:toLowerCase(order.status) == 'uploaded'}">
                            <hr class="my-4">
                            <div class="text-center bg-info-subtle border border-info rounded p-3">
                                <h6 class="fw-bold text-info-emphasis"><i class="bi bi-cpu"></i> Tích Hợp AI Engine Hỗ Trợ Chẩn Đoán</h6>
                                <p class="small text-muted mb-3">Hình ảnh siêu âm đã sẵn sàng. Nhấn nút bên dưới để gửi phân tích tới AI Engine chẩn đoán tự động.</p>
                                
                                <form method="POST" action="${pageContext.request.contextPath}/sonographer/analyze" onsubmit="showAiLoading()">
                                    <input type="hidden" name="orderId" value="${order.orderId}">
                                    <button type="submit" class="btn btn-info text-white fw-bold px-4 py-2 w-100">
                                        <i class="bi bi-robot"></i> Gửi phân tích AI
                                    </button>
                                </form>
                            </div>
                        </c:if>
                    </div>
                </c:if>

                <!-- 3. ANALYZING: Loading spinner -->
                <c:if test="${fn:toLowerCase(order.status) == 'analyzing'}">
                    <div class="text-center py-5" id="aiLoadingSection">
                        <div class="spinner-border text-info mb-3" style="width: 3rem; height: 3rem;" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <h5 class="fw-bold text-info-emphasis"><i class="bi bi-cpu"></i> AI Engine đang xử lý hình ảnh...</h5>
                        <p class="text-muted small">Quá trình này có thể mất từ 5-15 giây để vẽ mask phân tích và nhận diện túi thai / vùng tổn thương.</p>
                        <div class="ai-pulse-bar mt-3"></div>
                    </div>
                </c:if>

                <!-- 4. COMPLETED: Display AI Results -->
                <c:if test="${fn:toLowerCase(order.status) == 'completed'}">
                    <div>
                        <h6 class="fw-bold text-success mb-3"><i class="bi bi-check-circle-fill"></i> Kết quả siêu âm đã hoàn thành</h6>
                        
                        <c:if test="${not empty aiResult}">
                            <!-- KPI AI results -->
                            <div class="row g-2 mb-4">
                                <div class="col-md-6">
                                    <div class="border rounded p-3 bg-light text-center">
                                        <div class="text-muted small fw-bold">CHẨN ĐOÁN GỢI Ý (AI)</div>
                                        <div class="fs-5 fw-bold mt-1 ${aiResult.detected ? 'text-danger' : 'text-success'}">
                                            ${aiResult.detected ? 'PHÁT HIỆN BẤT THƯỜNG' : 'BÌNH THƯỜNG'}
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="border rounded p-3 bg-light text-center">
                                        <div class="text-muted small fw-bold">ĐỘ TIN CẬY (CONFIDENCE)</div>
                                        <div class="fs-5 fw-bold text-rose mt-1">
                                            <c:out value="${aiResult.confidence}"/>%
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Description -->
                            <div class="alert alert-light border mb-4">
                                <strong class="text-dark small d-block mb-1">MÔ TẢ CHI TIẾT CỦA AI:</strong>
                                <span class="text-dark"><c:out value="${aiResult.message}"/></span>
                            </div>

                            <!-- Side-by-side images -->
                            <div class="mb-4">
                                <label class="text-muted small fw-bold mb-2">HÌNH ẢNH PHÂN TÍCH (ĐẦU VÀO VÀ ĐẦU RA CỦA AI)</label>
                                <div class="row g-2">
                                    <div class="col-md-6">
                                        <div class="border rounded p-2 text-center bg-light">
                                            <small class="text-muted d-block mb-1 fw-bold">Ảnh siêu âm gốc (Click to zoom)</small>
                                            <img src="${pageContext.request.contextPath}/${aiResult.inputImage}" class="img-fluid rounded border" style="max-height: 250px; object-fit: contain; cursor: zoom-in;" onclick="openViewer(this.src, 'Ảnh gốc đầu vào')">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="border rounded p-2 text-center bg-light">
                                            <small class="text-rose d-block mb-1 fw-bold">Ảnh kết quả phân tách (AI overlay - Click to zoom)</small>
                                            <img src="${pageContext.request.contextPath}/${aiResult.resultImage}" class="img-fluid rounded border" style="max-height: 250px; object-fit: contain; cursor: zoom-in;" onclick="openViewer(this.src, 'Ảnh AI phân tích')">
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Disclaimer Box -->
                            <div class="alert alert-warning border border-warning shadow-sm" role="alert">
                                <h6 class="alert-heading fw-bold d-flex align-items-center gap-1 text-warning-emphasis">
                                    <i class="bi bi-info-circle-fill"></i> Khuyến cáo y khoa quan trọng
                                </h6>
                                <p class="m-0 small text-warning-emphasis">
                                    Kết quả phân tích hình ảnh siêu âm bằng trí tuệ nhân tạo (AI Engine) chỉ mang tính chất tham khảo học thuật hỗ trợ. Quyết định chẩn đoán lâm sàng và phác đồ xử trí y tế cuối cùng thuộc về Bác sĩ chuyên môn sản khoa.
                                </p>
                            </div>
                        </c:if>
                        <c:if test="${empty aiResult}">
                            <div class="text-center py-4 bg-light rounded border text-muted">
                                Không tìm thấy dữ liệu phân tích AI chi tiết cho chỉ định này.
                            </div>
                        </c:if>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<!-- Hidden Form for AI loading spinner -->
<div id="loadingOverlay" style="display: none; position: fixed; top:0; left:0; width:100vw; height:100vh; background: rgba(0,0,0,0.5); z-index: 9999; justify-content: center; align-items: center; flex-direction: column;" class="text-white">
    <div class="spinner-border text-light mb-3" style="width: 3rem; height: 3rem;" role="status">
        <span class="visually-hidden">Loading...</span>
    </div>
    <h5 class="fw-bold">Đang gửi yêu cầu và chạy phân tích ảnh siêu âm qua AI...</h5>
    <p class="small text-light-emphasis">Vui lòng không tắt trình duyệt hoặc tải lại trang.</p>
</div>

<jsp:include page="../common/footer.jsp" />

<!-- Timeline progress script and image preview -->
<script>
    // 1. Update timeline UI states based on order status
    const status = "${order.status}".toLowerCase();
    const steps = ["pending", "inprogress", "uploaded", "analyzing", "completed"];
    
    let activeIdx = steps.indexOf(status);
    if (activeIdx === -1) {
        // Fallbacks
        if (status === "waiting" || status === "ordered") activeIdx = 0;
    }

    const timelineProgress = document.getElementById("timelineProgress");
    if (activeIdx !== -1) {
        // Calculate progress line width
        const widthPercent = (activeIdx / (steps.length - 1)) * 90;
        timelineProgress.style.width = widthPercent + "%";
        
        // Add completed class
        for (let i = 0; i <= activeIdx; i++) {
            const stepId = "step" + steps[i];
            const elem = document.getElementById(stepId);
            if (elem) {
                if (i === activeIdx) {
                    elem.classList.add("active");
                } else {
                    elem.classList.add("completed");
                }
            }
        }
    }

    // 2. Image Upload Preview
    function previewImage(event) {
        const reader = new FileReader();
        reader.onload = function() {
            const output = document.getElementById('imagePreview');
            output.src = reader.result;
            document.getElementById('imagePreviewContainer').style.display = 'block';
        };
        reader.readAsDataURL(event.target.files[0]);
    }

    // 3. Show loading screen when AI starts
    function showAiLoading() {
        document.getElementById("loadingOverlay").style.display = "flex";
    }
</script>

<!-- Fullscreen Image Viewer Modal -->
<div id="imageViewerModal" onclick="closeViewer()">
    <!-- Header bar with image name -->
    <div style="position: absolute; top: 0; left: 0; width: 100%; padding: 15px 30px; background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(5px); display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid rgba(255,255,255,0.08); z-index: 10001;">
        <span id="viewerTitle" style="color: white; font-family: 'Nunito', sans-serif; font-weight: 700; font-size: 1.1rem; letter-spacing: 0.5px;">Ảnh siêu âm</span>
        <button onclick="closeViewer()" style="background: none; border: none; color: rgba(255,255,255,0.7); font-size: 1.5rem; cursor: pointer; padding: 0; line-height: 1; transition: color 0.2s;" onmouseover="this.style.color='#e11d48'" onmouseout="this.style.color='rgba(255,255,255,0.7)'" title="Đóng (Esc)">
            <i class="bi bi-x-lg"></i>
        </button>
    </div>
    
    <div style="max-width: 90%; max-height: 80%; display: flex; align-items: center; justify-content: center; margin-top: 60px;">
        <img id="viewerImage" src="" class="viewer-img" alt="Phóng to ảnh siêu âm" onclick="event.stopPropagation();">
    </div>
    
    <div class="text-white-50 small mt-3" style="z-index: 10001;"><i class="bi bi-info-circle me-1"></i> Nhấp bất kỳ đâu bên ngoài để đóng</div>
</div>

<script>
    const viewerImage = document.getElementById('viewerImage');
    const imageViewerModal = document.getElementById('imageViewerModal');
    const viewerTitle = document.getElementById('viewerTitle');

    function openViewer(src, title) {
        viewerImage.src = src;
        viewerTitle.innerText = title || 'Ảnh siêu âm';
        imageViewerModal.style.display = 'flex';
        
        document.addEventListener('keydown', handleEscKey);
    }

    function closeViewer() {
        imageViewerModal.style.display = 'none';
        document.removeEventListener('keydown', handleEscKey);
    }

    function handleEscKey(e) {
        if (e.key === 'Escape') {
            closeViewer();
        }
    }
</script>
</body>
</html>
