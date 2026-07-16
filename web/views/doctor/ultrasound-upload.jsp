<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Ảnh Siêu Âm — CAMS Doctor</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">

    <style>
        :root {
            --sidebar-w: 260px;
            --topbar-h: 66px;
            --blue-50: #eff6ff;
        }
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Be Vietnam Pro', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .layout { display: flex; min-height: 100vh; }
        .sidebar { width: var(--sidebar-w); min-width: var(--sidebar-w); background: linear-gradient(180deg, #1565c0 0%, #0d47a1 100%); color: #fff; position: fixed; top: 0; left: 0; bottom: 0; overflow-y: auto; z-index: 1000; padding: 20px 0; }
        .sidebar .logo { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.2); margin-bottom: 10px; }
        .sidebar .logo h4 { font-size: 1.1rem; font-weight: 600; margin: 0; }
        .sidebar .nav-item a { display: flex; align-items: center; gap: 10px; padding: 12px 20px; color: rgba(255,255,255,0.85); text-decoration: none; font-size: 0.9rem; transition: all 0.2s; border-left: 3px solid transparent; }
        .sidebar .nav-item a:hover, .sidebar .nav-item a.active { background: rgba(255,255,255,0.12); color: #fff; border-left-color: #fff; }
        .main { margin-left: var(--sidebar-w); flex: 1; padding: 24px; background: var(--blue-50); min-height: 100vh; }
        .topbar { display: flex; justify-content: space-between; align-items: center; background: #fff; padding: 0 24px; height: var(--topbar-h); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,0.06); margin-bottom: 24px; }
        .content-card { background: #fff; border-radius: 12px; box-shadow: 0 1px 6px rgba(0,0,0,0.06); padding: 28px; margin-bottom: 24px; }
        .content-card h5 { font-weight: 600; color: #333; margin-bottom: 20px; }

        .upload-zone { border: 2px dashed #dee2e6; border-radius: 12px; padding: 40px 20px; text-align: center; cursor: pointer; transition: all 0.3s; background: #fafafa; }
        .upload-zone:hover, .upload-zone.dragover { border-color: #1565c0; background: var(--blue-50); }
        .upload-zone i { font-size: 3rem; color: #adb5bd; }
        .upload-zone p { margin: 10px 0 0; color: #6c757d; font-size: 0.9rem; }
        .upload-zone .allowed-types { font-size: 0.78rem; color: #adb5bd; margin-top: 6px; }

        .preview-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 16px; margin-top: 20px; }
        .preview-item { position: relative; border-radius: 8px; overflow: hidden; border: 1px solid #e9ecef; background: #f8f9fa; }
        .preview-item img { width: 100%; height: 140px; object-fit: cover; display: block; }
        .preview-item .preview-name { font-size: 0.75rem; padding: 6px 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .preview-item .preview-remove { position: absolute; top: 4px; right: 4px; width: 24px; height: 24px; background: rgba(220,53,69,0.9); color: #fff; border: none; border-radius: 50%; font-size: 0.85rem; cursor: pointer; display: flex; align-items: center; justify-content: center; }
        .existing-image-card { border-radius: 8px; overflow: hidden; border: 1px solid #e9ecef; transition: box-shadow 0.2s; }
        .existing-image-card:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .existing-image-card img { width: 100%; height: 120px; object-fit: cover; }
        .existing-image-card .img-info { padding: 8px; font-size: 0.78rem; }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="logo">
            <h4><i class="bi bi-heart-pulse-fill me-2"></i>CAMS</h4>
            <small>Doctor Portal</small>
        </div>
        <nav>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/doctor/dashboard"><i class="bi bi-speedometer2"></i> Dashboard</a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/doctor/medical-records"><i class="bi bi-file-medical-fill"></i> Bệnh Án</a>
            </div>
            <div class="nav-item">
                <a href="${pageContext.request.contextPath}/doctor/upload" class="active"><i class="bi bi-cloud-upload-fill"></i> Upload Ảnh Siêu Âm</a>
            </div>
        </nav>
    </aside>

    <main class="main">
        <div class="topbar">
            <nav class="breadcrumb">
                <span class="breadcrumb-item"><a href="${pageContext.request.contextPath}/doctor/dashboard">Dashboard</a></span>
                <span class="breadcrumb-item active">Upload Ảnh Siêu Âm</span>
            </nav>
            <div class="user-info">
                <c:if test="${not empty sessionScope.user}">
                    <i class="bi bi-person-circle"></i>
                    <span><c:out value="${sessionScope.user.fullName}"/></span>
                    <span class="badge bg-primary">Doctor</span>
                </c:if>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-secondary ms-2">
                    <i class="bi bi-box-arrow-right"></i>
                </a>
            </div>
        </div>

        <c:if test="${not empty param.success}">
            <div class="alert alert-success alert-dismissible fade show"><i class="bi bi-check-circle-fill me-2"></i><c:out value="${param.success}"/><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show"><i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${param.error}"/><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        </c:if>

        <div class="content-card">
            <h5><i class="bi bi-image-fill me-2"></i>Tải Ảnh Siêu Âm Lên</h5>
            <p class="text-muted small mb-4">
                <i class="bi bi-info-circle me-1"></i>
                Định dạng: <strong>JPG, JPEG, PNG</strong> &bull; Tối đa: <strong>10 MB/ảnh, 10 ảnh/lần</strong>
            </p>

            <form id="uploadForm" action="${pageContext.request.contextPath}/doctor/upload" method="post" enctype="multipart/form-data">
                <input type="hidden" name="testOrderId" value="<c:out value='${param.testOrderId}'/>">
                <input type="hidden" name="patientId" value="<c:out value='${param.patientId}'/>">
                <input type="hidden" name="appointmentId" value="<c:out value='${param.appointmentId}'/>">

                <div class="upload-zone" id="uploadZone" onclick="document.getElementById('fileInput').click()">
                    <i class="bi bi-cloud-arrow-up-fill"></i>
                    <p><strong>Kéo thả ảnh vào đây</strong> hoặc <span class="text-primary">nhấp để chọn file</span></p>
                    <div class="allowed-types">JPG, JPEG, PNG — Tối đa 10MB/file, 10 ảnh/lần</div>
                </div>
                <input type="file" id="fileInput" name="images" accept="image/jpeg,image/png,image/jpg" multiple style="display: none;" onchange="handleFiles(this.files)">
                <div class="preview-grid" id="previewGrid"></div>
                <div id="clientErrors" class="mt-3" style="display:none;"><div class="alert alert-warning"><ul class="mb-0" id="clientErrorList"></ul></div></div>
                <div class="mt-4 d-flex gap-3">
                    <button type="submit" class="btn btn-primary" id="submitBtn" disabled><i class="bi bi-cloud-upload-fill me-1"></i> Tải Lên</button>
                    <button type="button" class="btn btn-outline-secondary" onclick="resetForm()"><i class="bi bi-x-circle me-1"></i> Huỷ</button>
                </div>
            </form>
        </div>

        <c:if test="${not empty existingImages}">
            <div class="content-card">
                <h5><i class="bi bi-collection-fill me-2"></i>Ảnh Đã Upload (${fn:length(existingImages)} ảnh)</h5>
                <div class="row g-3">
                    <c:forEach var="img" items="${existingImages}">
                        <div class="col-6 col-md-3 col-lg-2">
                            <div class="existing-image-card">
                                <a href="${pageContext.request.contextPath}/<c:out value='${img.filePath}'/>" target="_blank">
                                    <img src="${pageContext.request.contextPath}/<c:out value='${img.filePath}'/>" alt="<c:out value='${img.originalFilename}'/>" loading="lazy" onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png'">
                                </a>
                                <div class="img-info">
                                    <div class="text-truncate" title="<c:out value='${img.originalFilename}'/>"><c:out value="${img.originalFilename}"/></div>
                                    <small class="text-muted"><c:out value="${img.uploaderName}"/></small>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>
<script>
    const MAX_FILES = 10, MAX_SIZE = 10*1024*1024, ALLOWED_TYPES = ['image/jpeg','image/png','image/jpg'];
    let selectedFiles = [];
    const uz = document.getElementById('uploadZone');
    uz.addEventListener('dragover',e=>{e.preventDefault();uz.classList.add('dragover')});
    uz.addEventListener('dragleave',e=>{e.preventDefault();uz.classList.remove('dragover')});
    uz.addEventListener('drop',e=>{e.preventDefault();uz.classList.remove('dragover');addFiles(e.dataTransfer.files)});
    function handleFiles(f){addFiles(f)}
    function addFiles(files){
        const el=document.getElementById('clientErrorList'),ed=document.getElementById('clientErrors');
        el.innerHTML='';let he=false;
        for(let i=0;i<files.length;i++){
            const f=files[i];
            if(!ALLOWED_TYPES.includes(f.type)){el.innerHTML+='<li>Định dạng không hỗ trợ: <strong>'+f.name+'</strong></li>';he=true;continue}
            if(f.size>MAX_SIZE){el.innerHTML+='<li>File >10MB: <strong>'+f.name+'</strong></li>';he=true;continue}
            if(selectedFiles.length>=MAX_FILES){el.innerHTML+='<li>Tối đa '+MAX_FILES+' ảnh. Bỏ qua: <strong>'+f.name+'</strong></li>';he=true;continue}
            if(selectedFiles.some(x=>x.name===f.name&&x.size===f.size)) continue;
            selectedFiles.push(f)
        }
        ed.style.display=he?'block':'none';updatePreview();syncFileInput()
    }
    function updatePreview(){
        const g=document.getElementById('previewGrid'),b=document.getElementById('submitBtn');g.innerHTML='';
        selectedFiles.forEach((f,i)=>{const r=new FileReader();r.onload=e=>{const d=document.createElement('div');d.className='preview-item';d.innerHTML='<img src="'+e.target.result+'" alt="'+f.name+'"><button class="preview-remove" onclick="removeFile('+i+')">×</button><div class="preview-name" title="'+f.name+'">'+f.name+'</div><div class="preview-size">'+(f.size<1048576?(f.size/1024).toFixed(1)+' KB':(f.size/1048576).toFixed(1)+' MB')+'</div>';g.appendChild(d)};r.readAsDataURL(f)});
        b.disabled=selectedFiles.length===0;b.innerHTML=selectedFiles.length?'<i class="bi bi-cloud-upload-fill me-1"></i> Tải Lên ('+selectedFiles.length+' ảnh)':'<i class="bi bi-cloud-upload-fill me-1"></i> Tải Lên'
    }
    function removeFile(i){selectedFiles.splice(i,1);updatePreview();syncFileInput()}
    function resetForm(){selectedFiles=[];updatePreview();syncFileInput();document.getElementById('clientErrors').style.display='none'}
    function syncFileInput(){const dt=new DataTransfer();selectedFiles.forEach(f=>dt.items.add(f));document.getElementById('fileInput').files=dt.files}
</script>
</body>
</html>
