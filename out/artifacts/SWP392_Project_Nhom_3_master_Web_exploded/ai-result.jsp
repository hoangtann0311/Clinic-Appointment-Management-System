<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%!
    // Helper to extract JSON fields using regex without external dependencies
    private String extractJsonField(String json, String fieldName) {
        if (json == null) return null;
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\"" + fieldName + "\"\\s*:\\s*(?:\"([^\"]*)\"|([^,}\\s]*))");
        java.util.regex.Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            if (matcher.group(1) != null) {
                return matcher.group(1);
            } else if (matcher.group(2) != null) {
                String val = matcher.group(2).trim();
                if ("null".equalsIgnoreCase(val)) return null;
                return val;
            }
        }
        return null;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết Quả Phân Tích AI - CAMS</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary-rose: #e11d48;
            --hover-rose: #be123c;
            --bg-rose: #fff1f2;
            --border-rose: #fda4af;
            --text-dark: #1e293b;
        }
        body {
            background-color: #f8fafc;
            font-family: 'Inter', 'Nunito', sans-serif;
            color: var(--text-dark);
            min-height: 100vh;
            padding: 30px 15px;
        }
        .ai-result-container {
            max-width: 960px;
            margin: 0 auto;
        }
        .ai-header-section {
            background: linear-gradient(135deg, #fda4af 0%, #f43f5e 100%);
            border-radius: 16px;
            padding: 25px;
            color: #ffffff;
            margin-bottom: 25px;
            box-shadow: 0 4px 20px rgba(225, 29, 72, 0.1);
        }
        .ai-card {
            background: #ffffff;
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
            margin-bottom: 25px;
            overflow: hidden;
        }
        .ai-card-title {
            font-family: 'Nunito', sans-serif;
            font-weight: 700;
            font-size: 1.1rem;
            color: #334155;
            border-bottom: 1px solid #f1f5f9;
            padding: 16px 20px;
            background: #fafafb;
        }
        .ai-card-body {
            padding: 20px;
        }
        .img-card {
            text-align: center;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            background: #f8fafc;
            padding: 12px;
            height: 100%;
        }
        .img-display {
            max-width: 100%;
            max-height: 320px;
            border-radius: 8px;
            object-fit: contain;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            cursor: zoom-in;
            transition: transform 0.2s ease;
        }
        .img-display:hover {
            transform: scale(1.02);
        }
        .json-box {
            background-color: #1e293b;
            color: #f8fafc;
            padding: 15px;
            border-radius: 0;
            font-family: 'Courier New', Courier, monospace;
            font-size: 0.85rem;
            max-height: 250px;
            overflow-y: auto;
            margin-bottom: 0;
        }
        .disclaimer-box {
            border-left: 5px solid #eab308;
            background-color: #fef9c3;
            color: #713f12;
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
    </style>
</head>
<body>

<div class="ai-result-container">
    <!-- Header -->
    <div class="ai-header-section d-flex align-items-center justify-content-between">
        <div>
            <h4 class="m-0 fw-bold"><i class="bi bi-cpu-fill"></i> Kết Quả Chẩn Đoán AI</h4>
            <small class="opacity-90">Báo cáo phân tách hình ảnh siêu âm u xơ tử cung tự động</small>
        </div>
        <a href="${pageContext.request.contextPath}/ai-upload.jsp" class="btn btn-light btn-sm fw-bold text-danger border">
            <i class="bi bi-plus-lg"></i> Upload ảnh khác
        </a>
    </div>

    <!-- Extraction and Validation Layer -->
    <%
        String error = (String) request.getAttribute("error");
        String originalImageUrl = (String) request.getAttribute("originalImageUrl");
        String resultImageUrl = (String) request.getAttribute("resultImageUrl");
        String jsonContent = (String) request.getAttribute("jsonContent");

        // Parse fields
        boolean detected = false;
        double confidence = 0.0;
        String aiMessage = "";
        String bboxStr = "";
        String maskAreaStr = "";

        if (jsonContent != null && !jsonContent.trim().isEmpty()) {
            try {
                String successVal = extractJsonField(jsonContent, "success");
                String detectedVal = extractJsonField(jsonContent, "detected");
                String confidenceVal = extractJsonField(jsonContent, "confidence");
                aiMessage = extractJsonField(jsonContent, "message");
                
                detected = "true".equalsIgnoreCase(detectedVal);
                if (confidenceVal != null) {
                    confidence = Double.parseDouble(confidenceVal);
                }
                
                String xmin = extractJsonField(jsonContent, "xmin");
                String ymin = extractJsonField(jsonContent, "ymin");
                String xmax = extractJsonField(jsonContent, "xmax");
                String ymax = extractJsonField(jsonContent, "ymax");
                if (xmin != null && ymin != null && xmax != null && ymax != null) {
                    bboxStr = "[" + xmin + ", " + ymin + ", " + xmax + ", " + ymax + "]";
                }
                
                String finalArea = extractJsonField(jsonContent, "finalMaskArea");
                if (finalArea != null) {
                    maskAreaStr = finalArea + " px";
                }
            } catch (Exception ex) {
                // Parsing fallback
            }
        }
    %>
    
    <% if (error != null || jsonContent == null || jsonContent.trim().isEmpty()) { %>
        <div class="alert alert-danger border-2 d-flex align-items-center gap-2 mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill fs-4"></i>
            <div>
                <strong class="d-block">Không thể phân tích ảnh bằng AI:</strong>
                Vui lòng thử lại hoặc kiểm tra cấu hình AI Engine. 
                <% if (error != null) { %>
                    <br><span class="small text-danger-emphasis">Chi tiết: <%= error.replaceAll("(?i)[a-z]:\\\\[^\\s]*", "[Đường dẫn nội bộ]") %></span>
                <% } %>
            </div>
        </div>
    <% } else { %>
        <!-- Summary Cards Dashboard -->
        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="ai-card h-100 m-0">
                    <div class="ai-card-title bg-white pb-1 border-0"><i class="bi bi-activity text-rose"></i> Trạng thái kết quả</div>
                    <div class="ai-card-body pt-0 text-center">
                        <c:choose>
                            <c:when test="<%= detected %>">
                                <span class="badge bg-danger fs-6 py-2 px-3 rounded-pill"><i class="bi bi-exclamation-circle-fill me-1"></i> Phát hiện vùng nghi ngờ u xơ</span>
                                <p class="text-muted small mt-3 mb-0">AI phát hiện vùng bất thường trên cấu trúc tử cung.</p>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary fs-6 py-2 px-3 rounded-pill"><i class="bi bi-check-circle-fill me-1"></i> Chưa phát hiện vùng nghi ngờ rõ ràng</span>
                                <p class="text-muted small mt-3 mb-0">AI chưa phát hiện vùng nghi ngờ u xơ rõ ràng trên ảnh này.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="ai-card h-100 m-0">
                    <div class="ai-card-title bg-white pb-1 border-0"><i class="bi bi-shield-check text-success"></i> Chỉ số độ tin cậy</div>
                    <div class="ai-card-body pt-0">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="small text-muted fw-bold">ĐỘ TIN CẬY (CONFIDENCE):</span>
                            <span class="fs-4 fw-bold text-rose"><%= Math.round(confidence * 100) %>%</span>
                        </div>
                        <div class="progress" style="height: 10px; border-radius: 5px;">
                            <div class="progress-bar bg-danger" role="progressbar" style="width: <%= Math.round(confidence * 100) %>%;" aria-valuenow="<%= Math.round(confidence * 100) %>" aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- AI Details Card -->
        <div class="ai-card mb-4">
            <div class="ai-card-title"><i class="bi bi-info-square-fill me-1 text-info"></i> Mô tả phân tích của AI</div>
            <div class="ai-card-body">
                <div class="mb-3">
                    <strong class="text-muted small d-block mb-1">MESSAGES AI CHẨN ĐOÁN:</strong>
                    <span class="fs-5 text-dark fw-semibold">
                        <%= (aiMessage != null && !aiMessage.trim().isEmpty()) ? aiMessage : (detected ? "AI phát hiện vùng nghi ngờ u xơ." : "AI chưa phát hiện vùng nghi ngờ u xơ rõ ràng trên ảnh này.") %>
                    </span>
                </div>
                
                <% if (detected) { %>
                    <div class="row pt-2 border-top">
                        <% if (!bboxStr.isEmpty()) { %>
                            <div class="col-6">
                                <span class="text-muted small d-block">TỌA ĐỘ BBOX:</span>
                                <code class="text-dark fw-bold"><%= bboxStr %></code>
                            </div>
                        <% } %>
                        <% if (!maskAreaStr.isEmpty()) { %>
                            <div class="col-6">
                                <span class="text-muted small d-block">DIỆN TÍCH MASK U XƠ:</span>
                                <span class="text-danger fw-bold"><%= maskAreaStr %></span>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>
    <% } %>

    <!-- Side-by-side Images -->
    <% if (originalImageUrl != null || resultImageUrl != null) { %>
        <div class="ai-card">
            <div class="ai-card-title d-flex justify-content-between align-items-center">
                <span><i class="bi bi-images me-1 text-primary"></i> So Sánh Hình Ảnh Siêu Âm</span>
                <span class="badge bg-light text-dark border small"><i class="bi bi-search me-1 text-danger"></i> Click vào ảnh để xem chi tiết</span>
            </div>
            <div class="ai-card-body">
                <div class="row g-3">
                    <% if (originalImageUrl != null) { %>
                        <div class="col-md-6">
                            <div class="img-card">
                                <span class="badge bg-secondary mb-2">Ảnh gốc đầu vào</span>
                                <div class="d-flex align-items-center justify-content-center" style="height: 320px;">
                                    <img src="<%= originalImageUrl %>" class="img-display" alt="Ảnh gốc siêu âm" onclick="openViewer(this.src, 'Ảnh gốc đầu vào')">
                                </div>
                            </div>
                        </div>
                    <% } %>
                    <% if (resultImageUrl != null) { %>
                        <div class="col-md-6">
                            <div class="img-card">
                                <span class="badge bg-danger mb-2">Ảnh AI phân tách (Result)</span>
                                <div class="d-flex align-items-center justify-content-center" style="height: 320px;">
                                    <img src="<%= resultImageUrl %>" class="img-display" alt="Ảnh kết quả phân tích" onclick="openViewer(this.src, 'Ảnh AI phân tích')">
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    <% } %>

    <!-- Accordion Metadata JSON (Collapsed by Default) -->
    <% if (jsonContent != null && !jsonContent.trim().isEmpty()) { %>
        <div class="accordion mb-4" id="accordionMetadata">
            <div class="accordion-item border rounded-3 overflow-hidden shadow-sm" style="border: 1px solid #e2e8f0 !important;">
                <h2 class="accordion-header" id="headingMetadata">
                    <button class="accordion-button collapsed fw-bold bg-light" type="button" data-bs-toggle="collapse" data-bs-target="#collapseMetadata" aria-expanded="false" aria-controls="collapseMetadata" style="font-size: 0.95rem;">
                        <i class="bi bi-code-slash me-2 text-secondary"></i> Xem metadata kỹ thuật JSON
                    </button>
                </h2>
                <div id="collapseMetadata" class="accordion-collapse collapse" aria-labelledby="headingMetadata" data-bs-parent="#accordionMetadata">
                    <div class="accordion-body p-0">
                        <pre class="json-box"><%= jsonContent %></pre>
                    </div>
                </div>
            </div>
        </div>
    <% } %>

    <!-- Disclaimer warning -->
    <div class="alert disclaimer-box p-3 rounded-3 shadow-sm mb-4" role="alert">
        <h6 class="fw-bold mb-1"><i class="bi bi-info-circle-fill"></i> Khuyến cáo y khoa quan trọng</h6>
        <p class="m-0 small">
            Kết quả tính toán và vẽ phân tách hình ảnh (segmask overlay) bằng trí tuệ nhân tạo (AI Engine) chỉ mang tính chất tham khảo học thuật bổ trợ. Mọi quyết định chẩn đoán và hướng xử lý y tế cuối cùng phải do Bác sĩ phụ trách chuyên môn trực tiếp kiểm tra và kết luận.
        </p>
    </div>

    <!-- Bottom Actions -->
    <div class="text-center d-flex justify-content-center gap-3">
        <a href="${pageContext.request.contextPath}/ai-upload.jsp" class="btn btn-outline-danger fw-bold px-4">
            <i class="bi bi-arrow-repeat"></i> Phân tích ảnh khác
        </a>
        <a href="${pageContext.request.contextPath}/sonographer/dashboard" class="btn btn-secondary border fw-bold px-4">
            <i class="bi bi-house"></i> Về Dashboard Sonographer
        </a>
    </div>
</div>

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

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- Simple Viewer Script -->
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
