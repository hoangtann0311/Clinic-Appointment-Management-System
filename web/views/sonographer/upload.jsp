<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Ảnh Siêu Âm — CAMS Sonographer</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Admin CSS (dùng chung nền) -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <style>
        :root {
            --sidebar-w: 260px;
            --topbar-h: 66px;
            --pink-50: #fff0f6;
            --pink-100: #ffe0ef;
            --pink-200: #ffb3d1;
        }
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Be Vietnam Pro', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        .layout { display: flex; min-height: 100vh; }

        /* ── Sidebar ── */
        .sidebar {
            width: var(--sidebar-w); min-width: var(--sidebar-w);
            background: linear-gradient(180deg, #e91e63 0%, #ad1457 100%);
            color: #fff; position: fixed; top: 0; left: 0; bottom: 0;
            overflow-y: auto; z-index: 1000; padding: 20px 0;
        }
        .sidebar .logo { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 10px; }
        .sidebar .logo h4 { font-size: 1.1rem; font-weight: 600; margin: 0; color: #fff; }
        .sidebar .logo small { font-size: 0.75rem; opacity: 0.8; }
        .sidebar .nav-item a {
            display: flex; align-items: center; gap: 10px; padding: 12px 20px;
            color: rgba(255,255,255,0.85); text-decoration: none; font-size: 0.9rem;
            transition: all 0.2s; border-left: 3px solid transparent;
        }
        .sidebar .nav-item a:hover, .sidebar .nav-item a.active {
            background: rgba(255,255,255,0.12); color: #fff; border-left-color: #fff;
        }

        /* ── Main ── */
        .main {
            margin-left: var(--sidebar-w); flex: 1; padding: 24px;
            background: var(--pink-50); min-height: 100vh;
        }

        /* ── Topbar ── */
        .topbar {
            display: flex; justify-content: space-between; align-items: center;
            background: #fff; padding: 0 24px; height: var(--topbar-h);
            border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,0.06); margin-bottom: 24px;
        }
        .topbar .breadcrumb { margin: 0; font-size: 0.85rem; }
        .topbar .user-info { display: flex; align-items: center; gap: 10px; font-size: 0.9rem; }

        /* ── Content Card ── */
        .content-card {
            background: #fff; border-radius: 12px; box-shadow: 0 1px 6px rgba(0,0,0,0.06);
            padding: 28px; margin-bottom: 24px;
        }
        .content-card h5 { font-weight: 600; color: #333; margin-bottom: 20px; }

        /* ── Upload Zone ── */
        .upload-zone {
            border: 2px dashed #dee2e6; border-radius: 12px; padding: 40px 20px;
            text-align: center; cursor: pointer; transition: all 0.3s; background: #fafafa;
        }
        .upload-zone:hover, .upload-zone.dragover {
            border-color: #e91e63; background: var(--pink-50);
        }
        .upload-zone i { font-size: 3rem; color: #adb5bd; }
        .upload-zone p { margin: 10px 0 0; color: #6c757d; font-size: 0.9rem; }
        .upload-zone .allowed-types { font-size: 0.78rem; color: #adb5bd; margin-top: 6px; }

        /* ── Preview Grid ── */
        .preview-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            gap: 16px; margin-top: 20px;
        }
        .preview-item {
            position: relative; border-radius: 8px; overflow: hidden;
            border: 1px solid #e9ecef; background: #f8f9fa;
        }
        .preview-item img { width: 100%; height: 140px; object-fit: cover; display: block; }
        .preview-item .preview-name {
            font-size: 0.75rem; padding: 6px 8px; white-space: nowrap;
            overflow: hidden; text-overflow: ellipsis;
        }
        .preview-item .preview-remove {
            position: absolute; top: 4px; right: 4px;
            width: 24px; height: 24px; background: rgba(220,53,69,0.9); color: #fff;
            border: none; border-radius: 50%; font-size: 0.85rem; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: background 0.2s;
        }
        .preview-item .preview-remove:hover { background: #dc3545; }
        .preview-item .preview-size { font-size: 0.7rem; padding: 0 8px 6px; color: #adb5bd; }

        /* ── Existing Images ── */
        .existing-image-card {
            border-radius: 8px; overflow: hidden; border: 1px solid #e9ecef;
            transition: box-shadow 0.2s;
        }
        .existing-image-card:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .existing-image-card img { width: 100%; height: 120px; object-fit: cover; }
        .existing-image-card .img-info { padding: 8px; font-size: 0.78rem; }

        /* ── Alerts ── */
        .alert { border-radius: 10px; }
    </style>
</head>
<body>

<div class="layout">

    <!-- ═════════════ SIDEBAR ═════════════ -->
    <aside class="sidebar">
        <div class="logo">
            <h4><i class="bi bi-heart-pulse-fill me-2"></i>CAMS</h4>
            <small>Sonographer Portal</small>
        </div>
        <nav>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/sonographer/dashboard">
                    <i class="bi bi-speedometer2"></i> Dashboard
                </a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/sonographer/upload" class="active">
                    <i class="bi bi-cloud-upload-fill"></i> Upload Ảnh Siêu Âm
                </a>
            </div>
        </nav>
    </aside>

    <!-- ═════════════ MAIN CONTENT ═════════════ -->
    <main class="main">

        <!-- Topbar -->
        <div class="topbar">
            <nav class="breadcrumb">
                <span class="breadcrumb-item"><a href="${pageContext.request.contextPath}/sonographer/dashboard">Dashboard</a></span>
                <span class="breadcrumb-item active">Upload Ảnh Siêu Âm</span>
            </nav>
            <div class="user-info">
                <c:if test="${not empty sessionScope.user}">
                    <i class="bi bi-person-circle"></i>
                    <span><c:out value="${sessionScope.user.fullName}"/></span>
                    <span class="badge bg-pink">Sonographer</span>
                </c:if>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-secondary ms-2">
                    <i class="bi bi-box-arrow-right"></i>
                </a>
            </div>
        </div>

        <!-- ═════════════ THÔNG BÁO ═════════════ -->
        <c:if test="${not empty param.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>
                <c:out value="${param.success}"/>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                <c:out value="${param.error}"/>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- ═════════════ FORM UPLOAD ═════════════ -->
        <div class="content-card">
            <h5><i class="bi bi-image-fill me-2"></i>Tải Ảnh Siêu Âm Lên</h5>
            <p class="text-muted small mb-4">
                <i class="bi bi-info-circle me-1"></i>
                Định dạng hỗ trợ: <strong>JPG, JPEG, PNG</strong> &bull;
                Dung lượng tối đa: <strong>10 MB / ảnh</strong> &bull;
                Số lượng tối đa: <strong>10 ảnh / lần upload</strong>
            </p>

            <form id="uploadForm"
                  action="${pageContext.request.contextPath}/sonographer/upload"
                  method="post"
                  enctype="multipart/form-data">

                <!-- Hidden fields — truyền context -->
                <input type="hidden" name="testOrderId" value="<c:out value='${param.testOrderId}'/>">
                <input type="hidden" name="patientId" value="<c:out value='${param.patientId}'/>">
                <input type="hidden" name="appointmentId" value="<c:out value='${param.appointmentId}'/>">

                <!-- Upload Zone -->
                <div class="upload-zone" id="uploadZone" onclick="document.getElementById('fileInput').click()">
                    <i class="bi bi-cloud-arrow-up-fill"></i>
                    <p><strong>Kéo thả ảnh vào đây</strong> hoặc <span class="text-primary">nhấp để chọn file</span></p>
                    <div class="allowed-types">JPG, JPEG, PNG — Tối đa 10MB/file, 10 ảnh/lần</div>
                </div>

                <input type="file" id="fileInput" name="images"
                       accept="image/jpeg,image/png,image/jpg"
                       multiple
                       style="display: none;"
                       onchange="handleFiles(this.files)">

                <!-- Preview Grid -->
                <div class="preview-grid" id="previewGrid"></div>

                <!-- Error list -->
                <div id="clientErrors" class="mt-3" style="display:none;">
                    <div class="alert alert-warning">
                        <ul class="mb-0" id="clientErrorList"></ul>
                    </div>
                </div>

                <!-- Submit -->
                <div class="mt-4 d-flex gap-3">
                    <button type="submit" class="btn btn-pink" id="submitBtn" disabled>
                        <i class="bi bi-cloud-upload-fill me-1"></i> Tải Lên
                    </button>
                    <button type="button" class="btn btn-outline-secondary" onclick="resetForm()">
                        <i class="bi bi-x-circle me-1"></i> Huỷ
                    </button>
                </div>
            </form>
        </div>

        <!-- ═════════════ ẢNH ĐÃ UPLOAD ═════════════ -->
        <c:if test="${not empty existingImages}">
            <div class="content-card">
                <h5><i class="bi bi-collection-fill me-2"></i>Ảnh Đã Upload (${fn:length(existingImages)} ảnh)</h5>
                <div class="row g-3">
                    <c:forEach var="img" items="${existingImages}">
                        <div class="col-6 col-md-3 col-lg-2">
                            <div class="existing-image-card">
                                <a href="${pageContext.request.contextPath}/<c:out value='${img.filePath}'/>"
                                   target="_blank" title="Xem ảnh gốc">
                                    <img src="${pageContext.request.contextPath}/<c:out value='${img.filePath}'/>"
                                         alt="<c:out value='${img.originalFilename}'/>"
                                         loading="lazy"
                                         onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png'">
                                </a>
                                <div class="img-info">
                                    <div class="text-truncate" title="<c:out value='${img.originalFilename}'/>">
                                        <c:out value="${img.originalFilename}"/>
                                    </div>
                                    <small class="text-muted">
                                        <c:choose>
                                            <c:when test="${img.fileSize >= 1048576}">
                                                <fmt:formatNumber value="${img.fileSize / 1048576.0}" maxFractionDigits="1"/> MB
                                            </c:when>
                                            <c:otherwise>
                                                <fmt:formatNumber value="${img.fileSize / 1024.0}" maxFractionDigits="1"/> KB
                                            </c:otherwise>
                                        </c:choose>
                                        &bull; <c:out value="${img.uploaderName}"/>
                                    </small>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

    </main>
</div>

<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
    const MAX_FILES = 10;
    const MAX_SIZE = 10 * 1024 * 1024; // 10 MB
    const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/jpg'];
    let selectedFiles = [];

    // ── Drag & Drop ──
    const uploadZone = document.getElementById('uploadZone');
    uploadZone.addEventListener('dragover', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.add('dragover');
    });
    uploadZone.addEventListener('dragleave', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.remove('dragover');
    });
    uploadZone.addEventListener('drop', function(e) {
        e.preventDefault();
        e.stopPropagation();
        this.classList.remove('dragover');
        const files = e.dataTransfer.files;
        addFiles(files);
    });

    // ── File Input ──
    function handleFiles(files) {
        addFiles(files);
    }

    function addFiles(files) {
        const errorList = document.getElementById('clientErrorList');
        const errorDiv = document.getElementById('clientErrors');
        errorList.innerHTML = '';
        let hasErrors = false;

        for (let i = 0; i < files.length; i++) {
            const file = files[i];

            // Check type
            if (!ALLOWED_TYPES.includes(file.type)) {
                errorList.innerHTML += '<li>Định dạng không hỗ trợ: <strong>' + file.name + '</strong> (chỉ JPG, JPEG, PNG)</li>';
                hasErrors = true;
                continue;
            }

            // Check size
            if (file.size > MAX_SIZE) {
                const sizeMB = (file.size / 1048576).toFixed(1);
                errorList.innerHTML += '<li>File vượt quá 10MB: <strong>' + file.name + '</strong> (' + sizeMB + ' MB)</li>';
                hasErrors = true;
                continue;
            }

            // Check max count
            if (selectedFiles.length >= MAX_FILES) {
                errorList.innerHTML += '<li>Đã đạt tối đa ' + MAX_FILES + ' ảnh. Bỏ qua: <strong>' + file.name + '</strong></li>';
                hasErrors = true;
                continue;
            }

            // Check duplicate
            if (selectedFiles.some(f => f.name === file.name && f.size === file.size)) {
                continue; // Bỏ qua duplicate (không báo lỗi)
            }

            selectedFiles.push(file);
        }

        if (hasErrors) {
            errorDiv.style.display = 'block';
        } else {
            errorDiv.style.display = 'none';
        }

        updatePreview();
        syncFileInput();
    }

    function updatePreview() {
        const grid = document.getElementById('previewGrid');
        const submitBtn = document.getElementById('submitBtn');
        grid.innerHTML = '';

        selectedFiles.forEach((file, index) => {
            const reader = new FileReader();
            reader.onload = function(e) {
                const div = document.createElement('div');
                div.className = 'preview-item';
                div.innerHTML =
                    '<img src="' + e.target.result + '" alt="' + file.name + '">' +
                    '<button class="preview-remove" onclick="removeFile(' + index + ')" title="Xoá">×</button>' +
                    '<div class="preview-name" title="' + file.name + '">' + file.name + '</div>' +
                    '<div class="preview-size">' + formatSize(file.size) + '</div>';
                grid.appendChild(div);
            };
            reader.readAsDataURL(file);
        });

        submitBtn.disabled = selectedFiles.length === 0;
        if (selectedFiles.length > 0) {
            submitBtn.innerHTML = '<i class="bi bi-cloud-upload-fill me-1"></i> Tải Lên (' + selectedFiles.length + ' ảnh)';
        } else {
            submitBtn.innerHTML = '<i class="bi bi-cloud-upload-fill me-1"></i> Tải Lên';
        }
    }

    function removeFile(index) {
        selectedFiles.splice(index, 1);
        updatePreview();
        syncFileInput();
    }

    function resetForm() {
        selectedFiles = [];
        updatePreview();
        syncFileInput();
        document.getElementById('clientErrors').style.display = 'none';
    }

    function syncFileInput() {
        // Tạo DataTransfer để gán lại files cho input
        const dt = new DataTransfer();
        selectedFiles.forEach(f => dt.items.add(f));
        document.getElementById('fileInput').files = dt.files;
    }

    function formatSize(bytes) {
        if (bytes < 1024) return bytes + ' B';
        if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
        return (bytes / 1048576).toFixed(1) + ' MB';
    }
</script>

</body>
</html>
