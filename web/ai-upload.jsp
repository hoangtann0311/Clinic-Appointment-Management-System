<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phân Tích Siêu Âm AI - CAMS</title>
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
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .ai-card {
            background: #ffffff;
            border: none;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(225, 29, 72, 0.08);
            width: 100%;
            max-width: 620px;
            overflow: hidden;
            transition: transform 0.3s ease;
        }
        .ai-card-header {
            background: linear-gradient(135deg, #fda4af 0%, #f43f5e 100%);
            padding: 35px 30px;
            text-align: center;
            color: #ffffff;
        }
        .ai-card-title {
            font-family: 'Nunito', sans-serif;
            font-weight: 800;
            font-size: 1.5rem;
            margin-bottom: 8px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .ai-card-subtitle {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        .ai-card-body {
            padding: 40px 30px;
        }
        .upload-zone {
            border: 2px dashed var(--border-rose);
            border-radius: 16px;
            padding: 40px 20px;
            text-align: center;
            background-color: var(--bg-rose);
            cursor: pointer;
            transition: all 0.25s ease;
            position: relative;
        }
        .upload-zone:hover {
            border-color: var(--primary-rose);
            background-color: #ffe4e6;
        }
        .upload-icon {
            font-size: 3.5rem;
            color: var(--primary-rose);
            margin-bottom: 15px;
            display: inline-block;
            transition: transform 0.3s ease;
        }
        .upload-zone:hover .upload-icon {
            transform: translateY(-8px);
        }
        .upload-text-main {
            font-weight: 600;
            font-size: 1.1rem;
            color: #475569;
            margin-bottom: 6px;
        }
        .upload-text-sub {
            font-size: 0.85rem;
            color: #94a3b8;
        }
        .btn-ai-submit {
            background: linear-gradient(135deg, #f43f5e 0%, #be123c 100%);
            border: none;
            color: #ffffff;
            font-weight: 700;
            padding: 14px 28px;
            border-radius: 12px;
            width: 100%;
            font-size: 1.1rem;
            box-shadow: 0 4px 15px rgba(225, 29, 72, 0.25);
            transition: all 0.2s ease;
        }
        .btn-ai-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(225, 29, 72, 0.35);
            background: linear-gradient(135deg, #be123c 0%, #be123c 100%);
        }
        .btn-ai-submit:active {
            transform: translateY(0);
        }
        .preview-container {
            margin-top: 25px;
            text-align: center;
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
            background: #f1f5f9;
            padding: 10px;
            display: none;
        }
        .preview-image {
            max-width: 100%;
            max-height: 280px;
            border-radius: 8px;
            object-fit: contain;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }
        .back-link {
            display: inline-flex;
            align-items: center;
            color: #64748b;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 600;
            margin-top: 25px;
            transition: color 0.2s;
        }
        .back-link:hover {
            color: var(--primary-rose);
        }
        .back-link i {
            margin-right: 6px;
            transition: transform 0.2s;
        }
        .back-link:hover i {
            transform: translateX(-4px);
        }
    </style>
</head>
<body>

<div class="ai-card">
    <div class="ai-card-header">
        <div class="ai-card-title">
            <i class="bi bi-robot me-2"></i>CAMS AI Ultrasound Assistant
        </div>
        <div class="ai-card-subtitle">
            Phân tích tự động hình ảnh siêu âm tử cung chẩn đoán U xơ
        </div>
    </div>
    
    <div class="ai-card-body">
        <form action="${pageContext.request.contextPath}/ai/analyze" method="POST" enctype="multipart/form-data" id="uploadForm" onsubmit="showLoading()">
            <!-- Drop Zone -->
            <div class="upload-zone" onclick="document.getElementById('imageInput').click()">
                <div class="upload-icon">
                    <i class="bi bi-cloud-arrow-up-fill"></i>
                </div>
                <div class="upload-text-main">Nhấp để chọn ảnh siêu âm</div>
                <div class="upload-text-sub">Hỗ trợ các định dạng JPEG, JPG, PNG (Tối đa 20MB)</div>
                <input type="file" id="imageInput" name="image" required accept="image/*" style="display: none;" onchange="handleFileSelect(event)">
            </div>
            
            <!-- Preview image -->
            <div class="preview-container" id="previewContainer">
                <div class="text-muted small fw-bold mb-2 text-start"><i class="bi bi-image-fill me-1 text-secondary"></i>XEM TRƯỚC HÌNH ẢNH:</div>
                <img id="previewImage" class="preview-image" alt="Xem trước hình ảnh">
            </div>
            
            <div class="mt-4">
                <button type="submit" class="btn btn-ai-submit" id="submitBtn">
                    <i class="bi bi-cpu me-1"></i> Bắt đầu phân tích AI
                </button>
            </div>
        </form>
        
        <div class="text-center">
            <a href="${pageContext.request.contextPath}/home" class="back-link">
                <i class="bi bi-arrow-left"></i> Trở về Trang chủ CAMS
            </a>
        </div>
    </div>
</div>

<!-- Fullscreen Loading Overlay -->
<div id="loadingOverlay" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(30, 41, 59, 0.85); z-index: 9999; justify-content: center; align-items: center; flex-direction: column;" class="text-white">
    <div class="spinner-border text-danger mb-3" style="width: 3.5rem; height: 3.5rem;" role="status">
        <span class="visually-hidden">Đang xử lý...</span>
    </div>
    <h5 class="fw-bold mb-2">Đang tải ảnh và thực thi thuật toán AI...</h5>
    <p class="small text-light-emphasis">Kịch bản Python đang được khởi tạo cục bộ. Vui lòng đợi trong giây lát.</p>
</div>

<script>
    function handleFileSelect(event) {
        const input = event.target;
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const previewImg = document.getElementById('previewImage');
                previewImg.src = e.target.result;
                document.getElementById('previewContainer').style.display = 'block';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    function showLoading() {
        document.getElementById('loadingOverlay').style.display = 'flex';
        document.getElementById('submitBtn').disabled = true;
    }
</script>
</body>
</html>
