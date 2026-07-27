<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp" />

<%-- ── Header ──────────────────────────────────────────────────────────── --%>
<div class="admin-page-header d-flex justify-content-between align-items-start gap-3 mb-4">
  <div>
    <h1 class="admin-page-title mb-1"><i class="bi bi-cpu me-2 text-primary"></i>Hồ Sơ Mô Hình AI</h1>
    <div class="admin-page-subtitle">
      Thông tin về model hỗ trợ phân tích ảnh siêu âm đang được sử dụng trong hệ thống.
    </div>
  </div>
  <span class="badge bg-primary-subtle text-primary px-3 py-2 rounded-3 fs-6">
    <i class="bi bi-patch-check-fill me-1"></i><c:out value="${modelVersion}" />
  </span>
</div>

<div class="alert alert-info d-flex gap-2 mb-4">
  <i class="bi bi-info-circle-fill flex-shrink-0 mt-1"></i>
  <div>
    Trang này chỉ dùng để xem và đối chiếu hồ sơ kỹ thuật. AI không tự đưa ra kết luận lâm sàng —
    bác sĩ siêu âm phải kiểm tra ảnh gốc, ảnh AI và ký xác nhận kết quả.
  </div>
</div>

<%-- ── 1. Model hiện hành ─────────────────────────────────────────────── --%>
<div class="admin-card mb-4">
  <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
    <h5 class="mb-0 fw-bold"><i class="bi bi-box-seam me-2 text-primary"></i>1. Model Hiện Hành</h5>
    <c:choose>
      <c:when test="${runtimeReady}">
        <span class="badge bg-success-subtle text-success"><i class="bi bi-check-circle me-1"></i>Đã cấu hình thực thi</span>
      </c:when>
      <c:otherwise>
        <span class="badge bg-warning-subtle text-warning"><i class="bi bi-exclamation-triangle me-1"></i>Thiếu đường dẫn Python</span>
      </c:otherwise>
    </c:choose>
  </div>
  <div class="card-body">
    <div class="row g-3">
      <div class="col-md-3 col-6">
        <div class="text-muted small mb-1">Tên mô hình</div>
        <div class="fw-semibold"><c:out value="${modelName}" /></div>
      </div>
      <div class="col-md-3 col-6">
        <div class="text-muted small mb-1">Kiến trúc</div>
        <div class="fw-semibold">YOLOv3 + U-Net Small</div>
      </div>
      <div class="col-md-3 col-6">
        <div class="text-muted small mb-1">Mã lần huấn luyện</div>
        <div class="fw-semibold font-monospace"><c:out value="${trainingRunId}" /></div>
      </div>
      <div class="col-md-3 col-6">
        <div class="text-muted small mb-1">Nhiệm vụ</div>
        <div class="fw-semibold">Phát hiện & phân vùng u xơ</div>
      </div>
      <div class="col-12 pt-2 border-top">
        <div class="text-muted small mb-1"><i class="bi bi-terminal me-1"></i>Tệp suy luận</div>
        <code class="text-dark"><c:out value="${inferenceScript}" /></code>
        <span class="text-muted ms-3">· Đầu vào 512 × 512 px · Timeout ${processTimeoutSeconds}s</span>
      </div>
      <c:if test="${not runtimeReady}">
        <div class="col-12">
          <div class="alert alert-warning py-2 mb-0 small">
            Máy chủ chưa tìm thấy cấu hình <code>ai.python.script</code>. Cần trỏ khóa này tới
            <c:out value="${inferenceScript}" /> khi triển khai model thật.
          </div>
        </div>
      </c:if>
    </div>
  </div>
</div>

<%-- ── 2. Kết quả đánh giá ────────────────────────────────────────────── --%>
<div class="admin-card mb-4">
  <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
    <h5 class="mb-0 fw-bold"><i class="bi bi-bar-chart me-2 text-primary"></i>2. Kết Quả Đánh Giá Model</h5>
    <span class="badge bg-success-subtle text-success">5/5 chỉ số đạt ngưỡng</span>
  </div>
  <div class="card-body">
    <p class="text-muted small mb-3">Các chỉ số trên tập đánh giá của hồ sơ <strong><c:out value="${trainingRunId}" /></strong>.</p>
    <div class="table-responsive">
      <table class="table table-bordered align-middle mb-0" style="font-size:.9rem">
        <thead class="table-light">
          <tr>
            <th>Chỉ số</th>
            <th class="text-center">Giá trị</th>
            <th class="text-center">Ngưỡng</th>
            <th class="text-center">Kết quả</th>
            <th>Ý nghĩa</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="fw-semibold">YOLO Precision</td>
            <td class="text-center fw-bold text-primary">90,28%</td>
            <td class="text-center text-muted">&gt; 80%</td>
            <td class="text-center"><span class="badge bg-success">Đạt</span></td>
            <td class="text-muted small">Tỷ lệ vùng AI định vị chính xác trên tổng dự đoán.</td>
          </tr>
          <tr>
            <td class="fw-semibold">YOLO Recall</td>
            <td class="text-center fw-bold text-primary">83,33%</td>
            <td class="text-center text-muted">&gt; 80%</td>
            <td class="text-center"><span class="badge bg-success">Đạt</span></td>
            <td class="text-muted small">Khả năng phát hiện, hạn chế bỏ sót tổn thương.</td>
          </tr>
          <tr>
            <td class="fw-semibold">YOLO F1-Score</td>
            <td class="text-center fw-bold text-primary">86,67%</td>
            <td class="text-center text-muted">&gt; 80%</td>
            <td class="text-center"><span class="badge bg-success">Đạt</span></td>
            <td class="text-muted small">Cân bằng giữa Precision và Recall của YOLOv3.</td>
          </tr>
          <tr>
            <td class="fw-semibold">U-Net Val Dice</td>
            <td class="text-center fw-bold text-primary">0,7073</td>
            <td class="text-center text-muted">Epoch 70 (Approved37)</td>
            <td class="text-center"><span class="badge bg-success">Đạt</span></td>
            <td class="text-muted small">Độ tương đồng phân vùng mask U-Net trên tập validation.</td>
          </tr>
          <tr>
            <td class="fw-semibold">Giảm báo động giả</td>
            <td class="text-center fw-bold text-primary">&gt; 84%</td>
            <td class="text-center text-muted">So với baseline</td>
            <td class="text-center"><span class="badge bg-success">Đạt</span></td>
            <td class="text-muted small">Giảm False Positive trên ảnh siêu âm âm tính.</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</div>

<%-- ── 3. Dữ liệu & quá trình huấn luyện ─────────────────────────────── --%>
<div class="row g-4 mb-4">
  <%-- Biểu đồ đường học --%>
  <div class="col-xl-8">
    <div class="admin-card h-100">
      <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
        <h5 class="mb-0 fw-bold"><i class="bi bi-graph-up me-2 text-primary"></i>3. Đường Học Của Model</h5>
        <span class="badge bg-secondary-subtle text-secondary">80 epoch</span>
      </div>
      <div class="card-body text-center">
        <img src="${pageContext.request.contextPath}/assets/images/ai-metrics/training_curves.png"
             alt="Biểu đồ Training Loss, Validation Loss, Dice và IoU qua 80 epoch"
             class="img-fluid rounded-3 border"
             style="max-height:340px;object-fit:contain;">
        <p class="text-muted small mt-2 mb-0">
          Trái: Training Loss và Validation Loss giảm ổn định qua 80 epoch.
          Phải: Validation Dice đạt đỉnh <strong>0,7073</strong> ở epoch 70 (Approved37).
          Khoảng cách train–validation nhỏ cho thấy mô hình tổng quát hóa tốt.
        </p>
      </div>
    </div>
  </div>

  <%-- Cấu hình & Dataset --%>
  <div class="col-xl-4">
    <div class="admin-card h-100">
      <div class="card-header bg-white py-3 border-bottom">
        <h5 class="mb-0 fw-bold"><i class="bi bi-sliders me-2 text-primary"></i>Cấu Hình Huấn Luyện</h5>
      </div>
      <div class="card-body">
        <table class="table table-sm mb-3">
          <tbody>
            <tr><td class="text-muted">Mã lần train</td><td class="fw-semibold font-monospace"><c:out value="${trainingRunId}" /></td></tr>
            <tr><td class="text-muted">Số epoch</td><td class="fw-semibold">80</td></tr>
            <tr><td class="text-muted">Kích thước ảnh</td><td class="fw-semibold">512 × 512 px</td></tr>
            <tr><td class="text-muted">Loss U-Net</td><td class="fw-semibold">BCE + Dice</td></tr>
            <tr><td class="text-muted">Ngưỡng YOLO</td><td class="fw-semibold">0,20</td></tr>
            <tr><td class="text-muted">Ngưỡng mask</td><td class="fw-semibold">0,65</td></tr>
          </tbody>
        </table>

        <div class="small fw-semibold text-muted mb-2">Phân chia dataset — tổng 1.280 ảnh</div>
        <div class="progress mb-2" style="height:10px;border-radius:6px">
          <div class="progress-bar bg-primary" style="width:80%" title="Train 80%"></div>
          <div class="progress-bar bg-info" style="width:10%" title="Validation 10%"></div>
          <div class="progress-bar bg-secondary" style="width:10%" title="Test 10%"></div>
        </div>
        <div class="d-flex gap-3 small text-muted mb-3">
          <span><span class="badge bg-primary me-1">●</span>Train 80% — 1.024 ảnh</span>
          <span><span class="badge bg-info me-1">●</span>Val 10% — 128 ảnh</span>
          <span><span class="badge bg-secondary me-1">●</span>Test 10% — 128 ảnh</span>
        </div>

        <div class="small fw-semibold text-muted mb-2">Tăng cường dữ liệu (Augmentation)</div>
        <div class="d-flex flex-wrap gap-1">
          <span class="badge bg-light text-dark border">Lật ngang</span>
          <span class="badge bg-light text-dark border">Lật dọc</span>
          <span class="badge bg-light text-dark border">Xoay ngẫu nhiên</span>
          <span class="badge bg-light text-dark border">Chỉnh độ sáng</span>
        </div>
      </div>
    </div>
  </div>
</div>

<%-- ── 4. Quy trình huấn luyện & pipeline suy luận ───────────────────── --%>
<div class="row g-4 mb-4">
  <div class="col-xl-7">
    <div class="admin-card h-100">
      <div class="card-header bg-white py-3 border-bottom">
        <h5 class="mb-0 fw-bold"><i class="bi bi-list-ol me-2 text-primary"></i>4. Quy Trình Huấn Luyện Offline</h5>
      </div>
      <div class="card-body p-0">
        <ol class="list-group list-group-flush list-group-numbered">
          <li class="list-group-item py-3">
            <div class="fw-semibold">Thu thập và gắn nhãn</div>
            <div class="text-muted small">Tạo bounding box và mask vùng nghi ngờ trên 1.280 ảnh siêu âm.</div>
          </li>
          <li class="list-group-item py-3">
            <div class="fw-semibold">Chia dataset</div>
            <div class="text-muted small">Tách Train 80% (1.024 ảnh), Validation 10% (128), Test 10% (128).</div>
          </li>
          <li class="list-group-item py-3">
            <div class="fw-semibold">Augmentation</div>
            <div class="text-muted small">Lật, xoay và thay đổi độ sáng để tăng khả năng tổng quát hóa.</div>
          </li>
          <li class="list-group-item py-3">
            <div class="fw-semibold">Huấn luyện song song</div>
            <div class="text-muted small">YOLOv3 học bounding box; U-Net Small học mask phân vùng qua 80 epoch.</div>
          </li>
          <li class="list-group-item py-3">
            <div class="fw-semibold">Đánh giá checkpoint</div>
            <div class="text-muted small">So sánh loss, Dice, IoU, mAP, Precision và Recall sau mỗi epoch.</div>
          </li>
          <li class="list-group-item py-3">
            <div class="fw-semibold">Đóng gói model</div>
            <div class="text-muted small">Chọn checkpoint epoch 70 (Approved37) đạt ngưỡng và tích hợp vào pipeline web.</div>
          </li>
        </ol>
      </div>
    </div>
  </div>

  <div class="col-xl-5">
    <div class="admin-card h-100">
      <div class="card-header bg-white py-3 border-bottom">
        <h5 class="mb-0 fw-bold"><i class="bi bi-diagram-3 me-2 text-primary"></i>Pipeline Suy Luận</h5>
      </div>
      <div class="card-body p-0">
        <ul class="list-group list-group-flush">
          <li class="list-group-item d-flex align-items-start gap-3 py-3">
            <span class="badge bg-primary-subtle text-primary rounded-3 px-2 py-1 flex-shrink-0 mt-1">1</span>
            <div><div class="fw-semibold"><i class="bi bi-image me-1"></i>Nhận ảnh đầu vào</div>
              <div class="text-muted small">Kiểm tra định dạng, resize về 512×512 px.</div></div>
          </li>
          <li class="list-group-item d-flex align-items-start gap-3 py-3">
            <span class="badge bg-primary-subtle text-primary rounded-3 px-2 py-1 flex-shrink-0 mt-1">2</span>
            <div><div class="fw-semibold"><i class="bi bi-bounding-box me-1"></i>YOLOv3 định vị vùng</div>
              <div class="text-muted small">Tìm bounding box có confidence ≥ 0,20.</div></div>
          </li>
          <li class="list-group-item d-flex align-items-start gap-3 py-3">
            <span class="badge bg-primary-subtle text-primary rounded-3 px-2 py-1 flex-shrink-0 mt-1">3</span>
            <div><div class="fw-semibold"><i class="bi bi-grid-3x3-gap me-1"></i>U-Net tạo mask</div>
              <div class="text-muted small">Phân vùng nghi ngờ trong bounding box, ngưỡng mask 0,65.</div></div>
          </li>
          <li class="list-group-item d-flex align-items-start gap-3 py-3">
            <span class="badge bg-primary-subtle text-primary rounded-3 px-2 py-1 flex-shrink-0 mt-1">4</span>
            <div><div class="fw-semibold"><i class="bi bi-layers me-1"></i>Hậu xử lý</div>
              <div class="text-muted small">Lọc nhiễu, loại vùng nhỏ (diện tích &lt; 500 px²), tạo ảnh lớp phủ.</div></div>
          </li>
          <li class="list-group-item d-flex align-items-start gap-3 py-3">
            <span class="badge bg-success-subtle text-success rounded-3 px-2 py-1 flex-shrink-0 mt-1">5</span>
            <div><div class="fw-semibold"><i class="bi bi-person-check me-1"></i>Bác sĩ kiểm tra và ký</div>
              <div class="text-muted small">AI chỉ hỗ trợ tham khảo, kết luận chính thức do bác sĩ ký.</div></div>
          </li>
        </ul>
      </div>
    </div>
  </div>
</div>

<%-- ── 5. Sử dụng trong hệ thống ─────────────────────────────────────── --%>
<div class="admin-card mb-4">
  <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
    <h5 class="mb-0 fw-bold"><i class="bi bi-activity me-2 text-primary"></i>5. Sử Dụng Trong Hệ Thống</h5>
    <span class="badge bg-secondary-subtle text-secondary">Dữ liệu thời gian thực</span>
  </div>
  <div class="card-body">
    <div class="row g-3 text-center">
      <div class="col-6 col-md-3">
        <div class="border rounded-3 p-3">
          <div class="fs-3 fw-bold text-primary">${usageStats.totalRuns}</div>
          <div class="text-muted small">Lượt AI đã ghi nhận</div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="border rounded-3 p-3">
          <div class="fs-3 fw-bold text-success">${usageStats.successfulRuns}</div>
          <div class="text-muted small">Lượt phân tích thành công</div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="border rounded-3 p-3">
          <div class="fs-3 fw-bold text-info">${usageStats.detectedRuns}</div>
          <div class="text-muted small">Lượt có vùng nghi ngờ</div>
        </div>
      </div>
      <div class="col-6 col-md-3">
        <div class="border rounded-3 p-3">
          <div class="fw-semibold text-secondary" style="font-size:.95rem">
            <c:choose>
              <c:when test="${not empty usageStats.latestRun}">
                <fmt:formatDate value="${usageStats.latestRun}" pattern="dd/MM/yyyy HH:mm" />
              </c:when>
              <c:otherwise>—</c:otherwise>
            </c:choose>
          </div>
          <div class="text-muted small">Lần phân tích gần nhất</div>
        </div>
      </div>
    </div>
  </div>
</div>

<%-- ── 6. Mã nguồn minh chứng ────────────────────────────────────────── --%>
<div class="admin-card mb-4">
  <div class="card-header bg-white py-3 border-bottom">
    <h5 class="mb-0 fw-bold"><i class="bi bi-code-slash me-2 text-primary"></i>6. Mã Nguồn Minh Chứng</h5>
  </div>
  <div class="card-body d-grid gap-2">
    <details class="border rounded-3 overflow-hidden">
      <summary class="p-3 bg-light fw-semibold" style="cursor:pointer;list-style:none">
        <i class="bi bi-chevron-right me-2"></i>Kiến trúc U-Net Small dùng khi huấn luyện
      </summary>
      <pre class="p-3 mb-0 bg-dark text-white" style="font-size:.8rem;max-height:300px;overflow:auto"><code>class UNetSmall(nn.Module):
    def __init__(self):
        super().__init__()
        self.down1 = DoubleConv(3, 32)
        self.down2 = DoubleConv(32, 64)
        self.down3 = DoubleConv(64, 128)
        self.bridge = DoubleConv(128, 256)
        self.up3 = nn.ConvTranspose2d(256, 128, 2, 2)
        self.up2 = nn.ConvTranspose2d(128, 64, 2, 2)
        self.up1 = nn.ConvTranspose2d(64, 32, 2, 2)
        self.output = nn.Conv2d(32, 1, kernel_size=1)

    def forward(self, x):
        # Encoder -> bottleneck -> decoder + skip connections
        return self.output(decoded_features)</code></pre>
    </details>

    <details class="border rounded-3 overflow-hidden">
      <summary class="p-3 bg-light fw-semibold" style="cursor:pointer;list-style:none">
        <i class="bi bi-chevron-right me-2"></i>Thông số pipeline suy luận
      </summary>
      <pre class="p-3 mb-0 bg-dark text-white" style="font-size:.8rem;max-height:300px;overflow:auto"><code>MIN_DETECTION_CONFIDENCE = 0.20
BOX_PADDING_RATIO        = 0.05
SEG_THRESHOLD            = 0.65
MIN_SEG_AREA             = 500
IMAGE_SIZE               = 512

# YOLOv3 tìm bounding box có confidence cao nhất.
# U-Net dự đoán mask trên ảnh chuẩn hóa 512 x 512.
# Hậu xử lý giữ vùng hợp lệ và tạo ảnh lớp phủ.
# Bác sĩ siêu âm kiểm tra, chỉnh tay khi cần và ký xác nhận.</code></pre>
    </details>
  </div>
</div>

<jsp:include page="../common/footer.jsp" />
