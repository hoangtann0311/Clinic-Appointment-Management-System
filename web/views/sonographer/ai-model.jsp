<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Model AI - CAMS</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Prism.js Tomorrow Night Theme for premium code highlighting -->
    <link href="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/themes/prism-tomorrow.min.css" rel="stylesheet" />
    <!-- Theme CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        /* Fix horizontal scrollbar and optimize responsiveness */
        html, body {
            max-width: 100%;
            overflow-x: hidden;
        }
        .admin-main {
            max-width: 100%;
            overflow-x: hidden !important;
        }
        .admin-card {
            min-width: 0;
            max-width: 100%;
            overflow: hidden;
        }
        .code-container {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            background: #1d1f21;
            max-width: 100%;
        }
        .btn-copy {
            position: absolute;
            top: 10px;
            right: 15px;
            z-index: 10;
            background: rgba(255, 255, 255, 0.1);
            color: #ddd;
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 4px 10px;
            font-size: 0.75rem;
            border-radius: 4px;
            transition: all 0.2s;
        }
        .btn-copy:hover {
            background: rgba(255, 255, 255, 0.25);
            color: #fff;
            border-color: #fff;
        }
        pre[class*="language-"] {
            margin: 0 !important;
            padding: 1.5rem !important;
            max-height: 600px;
            overflow: auto !important;
            max-width: 100% !important;
        }
        .badge-ai {
            background: linear-gradient(135deg, #7b1fa2, #e91e63);
            color: #fff;
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
    </style>
</head>
<body class="admin-body">

<jsp:include page="../common/header.jsp" />

<div class="admin-page-header">
    <div class="admin-page-header-left">
        <h1 class="admin-page-title">Cấu Hình & Mã Nguồn Model AI</h1>
        <div class="admin-page-subtitle">
            Tổng quan &gt; Pipeline tích hợp nhận diện & phân vùng u xơ tử cung
        </div>
    </div>
    <div>
        <span class="badge-ai"><i class="bi bi-robot"></i> YOLOv3 & U-Net Hybrid</span>
    </div>
</div>

<!-- Welcome/Overview Banner -->
<div class="admin-welcome-banner mb-4">
    <div>
        <h2>
            <i class="bi bi-cpu-fill"></i>
            Hệ Thống Phân Tích Hình Ảnh Siêu Âm CAMS AI
        </h2>
        <p>Hệ thống sử dụng mô hình kết hợp (Hybrid Model): <strong>YOLOv3</strong> định vị vùng nghi ngờ u xơ tử cung (Bounding Box) và <strong>U-Net</strong> phân vùng chi tiết tế bào (Segmentation Mask) nhằm hỗ trợ bác sĩ chẩn đoán chính xác.</p>
    </div>
</div>

<div class="row g-4">
    <!-- Left Column: Explanation and Flowchart (balanced proportions) -->
    <div class="col-xl-5 col-lg-6">
        <div class="admin-card mb-4">
            <div class="card-header">
                <h5><i class="bi bi-diagram-3-fill"></i> Sơ Đồ Hoạt Động (Pipeline)</h5>
            </div>
            <div class="card-body">
                <ol class="list-group list-group-numbered list-group-flush mb-0">
                    <li class="list-group-item d-flex justify-content-between align-items-start py-3">
                        <div class="ms-2 me-auto">
                            <div class="fw-bold">Tải ảnh siêu âm đầu vào</div>
                            Ảnh siêu âm tử cung được KTV tải lên hệ thống chẩn đoán.
                        </div>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-start py-3">
                        <div class="ms-2 me-auto">
                            <div class="fw-bold">Nhận diện bằng YOLOv3</div>
                            Định vị vùng nghi ngờ chứa u xơ với độ tin cậy tối thiểu <code>0.30</code>.
                        </div>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-start py-3">
                        <div class="ms-2 me-auto">
                            <div class="fw-bold">Mở rộng Bounding Box (Padding)</div>
                            Mở rộng hộp giới hạn ra thêm <code>5%</code> để tránh mất rìa tổn thương.
                        </div>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-start py-3">
                        <div class="ms-2 me-auto">
                            <div class="fw-bold">Phân vùng bằng U-Net</div>
                            Đưa ảnh về kích thước <code>512x512</code>, chạy mô hình U-Net dự đoán xác suất và lọc qua ngưỡng <code>0.65</code>.
                        </div>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-start py-3">
                        <div class="ms-2 me-auto">
                            <div class="fw-bold">Hậu xử lý mặt nạ (Post-process)</div>
                            Chỉ giữ lại vùng mặt nạ nằm trong Bounding Box của YOLO, lọc nhiễu bằng thuật toán Connected Components để giữ lại vùng có diện tích lớn nhất.
                        </div>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-start py-3">
                        <div class="ms-2 me-auto">
                            <div class="fw-bold">Vẽ đè kết quả chẩn đoán</div>
                            Vẽ hộp YOLO (màu xanh lá) và tô màu vùng u xơ (màu đỏ trong suốt) đè lên ảnh gốc để hiển thị cho bác sĩ.
                        </div>
                    </li>
                </ol>
            </div>
        </div>

        <div class="admin-card">
            <div class="card-header">
                <h5><i class="bi bi-gear-wide-connected"></i> Thông Số Siêu Tham Số</h5>
            </div>
            <div class="card-body">
                <table class="table table-sm table-striped mb-0 small">
                    <thead>
                        <tr>
                            <th>Tham số</th>
                            <th>Giá trị</th>
                            <th>Ý nghĩa</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><code>MIN_DETECTION_CONFIDENCE</code></td>
                            <td><strong>0.30</strong></td>
                            <td>Độ tin cậy tối thiểu của YOLO</td>
                        </tr>
                        <tr>
                            <td><code>BOX_PADDING_RATIO</code></td>
                            <td><strong>0.05 (5%)</strong></td>
                            <td>Tỷ lệ mở rộng khung nhận diện</td>
                        </tr>
                        <tr>
                            <td><code>SEG_THRESHOLD</code></td>
                            <td><strong>0.65</strong></td>
                            <td>Ngưỡng nhị phân hóa mặt nạ U-Net</td>
                        </tr>
                        <tr>
                            <td><code>MIN_SEG_AREA</code></td>
                            <td><strong>500 pixels</strong></td>
                            <td>Diện tích mặt nạ tối thiểu tránh nhiễu</td>
                        </tr>
                        <tr>
                            <td><code>IMAGE_SIZE</code></td>
                            <td><strong>512 x 512</strong></td>
                            <td>Đầu vào chuẩn của mô hình U-Net</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Right Column: Code Tabs (balanced proportions) -->
    <div class="col-xl-7 col-lg-6">
        <div class="admin-card">
            <div class="card-header p-2 bg-light">
                <ul class="nav nav-pills" id="codeTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="metrics-tab" data-bs-toggle="tab" data-bs-target="#metrics" type="button" role="tab" aria-controls="metrics" aria-selected="true">
                            <i class="bi bi-graph-up-arrow"></i> Chỉ Số Đánh Giá & Huấn Luyện
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="predict-tab" data-bs-toggle="tab" data-bs-target="#predict" type="button" role="tab" aria-controls="predict" aria-selected="false">
                            <i class="bi bi-filetype-py"></i> predict_for_web.py (Pipeline)
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="unet-tab" data-bs-toggle="tab" data-bs-target="#unet" type="button" role="tab" aria-controls="unet" aria-selected="false">
                            <i class="bi bi-filetype-py"></i> train_unet_approved37.py (U-Net)
                        </button>
                    </li>
                </ul>
            </div>
            <div class="card-body p-0">
                <div class="tab-content" id="codeTabsContent">
                    <!-- Tab 1: Metrics & Evaluation -->
                    <div class="tab-pane fade show active" id="metrics" role="tabpanel" aria-labelledby="metrics-tab">
                        <div class="p-4 bg-white rounded-bottom">
                            <div class="row g-4">
                                <div class="col-lg-6">
                                    <h5 class="fw-bold text-primary mb-3">
                                        <i class="bi bi-graph-up"></i> Đồ Thị Huấn Luyện (Loss & Metrics Curves)
                                    </h5>
                                    <div class="border rounded p-2 text-center bg-light">
                                        <img src="${pageContext.request.contextPath}/assets/images/ai-metrics/training_curves.png" 
                                             alt="Đồ thị huấn luyện AI" 
                                             class="img-fluid rounded" 
                                             style="max-height: 380px;">
                                    </div>
                                    <p class="text-muted small mt-2 text-center">
                                        *Hình: Đồ thị BCE+Dice Loss giảm dần và chỉ số Dice/IoU tăng dần qua 80 epochs.
                                    </p>
                                </div>
                                <div class="col-lg-6">
                                    <h5 class="fw-bold text-primary mb-3">
                                        <i class="bi bi-shield-check"></i> Chỉ Số Đánh Giá Mô Hình (Evaluation Metrics)
                                    </h5>
                                    <div class="table-responsive">
                                        <table class="table table-bordered table-striped align-middle small mb-4">
                                            <thead class="table-dark">
                                                <tr>
                                                    <th>Tên Chỉ Số</th>
                                                    <th>Giá trị</th>
                                                    <th>Ngưỡng Đạt</th>
                                                    <th>Giải Thích Ý Nghĩa</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr>
                                                    <td><strong>Dice Coefficient (F1-Score)</strong></td>
                                                    <td><span class="badge bg-success">0.8942</span></td>
                                                    <td>&gt; 0.80</td>
                                                    <td>Đánh giá độ tương đồng diện tích phân vùng u xơ.</td>
                                                </tr>
                                                <tr>
                                                    <td><strong>Mean IoU (Jaccard Index)</strong></td>
                                                    <td><span class="badge bg-success">0.8125</span></td>
                                                    <td>&gt; 0.75</td>
                                                    <td>Tỷ lệ phần giao trên phần hợp giữa dự đoán và thực tế.</td>
                                                </tr>
                                                <tr>
                                                    <td><strong>YOLO mAP@0.5</strong></td>
                                                    <td><span class="badge bg-primary">0.9105</span></td>
                                                    <td>&gt; 0.85</td>
                                                    <td>Độ chính xác trung bình của định vị hộp giới hạn.</td>
                                                </tr>
                                                <tr>
                                                    <td><strong>Precision (Độ chính xác)</strong></td>
                                                    <td><span class="badge bg-primary">0.8876</span></td>
                                                    <td>&gt; 0.80</td>
                                                    <td>Tỷ lệ dự đoán u xơ đúng trên tổng số ca báo phát hiện.</td>
                                                </tr>
                                                <tr>
                                                    <td><strong>Recall (Độ nhạy)</strong></td>
                                                    <td><span class="badge bg-primary">0.9012</span></td>
                                                    <td>&gt; 0.85</td>
                                                    <td>Tỷ lệ phát hiện thành công u xơ tránh bỏ sót ca bệnh.</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                    
                                    <h5 class="fw-bold text-primary mb-2">
                                        <i class="bi bi-database-fill"></i> Tập Dữ Liệu Huấn Luyện (Dataset)
                                    </h5>
                                    <p class="small mb-0">
                                        Mô hình được huấn luyện trên tập dữ liệu siêu âm tử cung đã được gán nhãn thủ công (Ground Truth) bởi các chuyên gia sản phụ khoa hàng đầu:
                                    </p>
                                    <ul class="small mt-1 text-muted">
                                        <li><strong>Tổng số ảnh siêu âm:</strong> 1,280 ảnh.</li>
                                        <li><strong>Phân chia tập dữ liệu:</strong> Train (80% ~ 1,024 ảnh) | Val (10% ~ 128 ảnh) | Test (10% ~ 128 ảnh).</li>
                                        <li><strong>Augmentation (Tăng cường dữ liệu):</strong> H-Flip, V-Flip, Xoay góc ngẫu nhiên, Điều chỉnh độ sáng tối để tăng tính tổng quát hóa cho mô hình.</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tab 2: Pipeline Code -->
                    <div class="tab-pane fade" id="predict" role="tabpanel" aria-labelledby="predict-tab">
                        <div class="code-container">
                            <button class="btn btn-copy" onclick="copyCode('predict-code')"><i class="bi bi-copy"></i> Sao chép</button>
                            <pre><code id="predict-code" class="language-python"># predict_for_web.py — Tích hợp YOLOv3 và U-Net phân tích u xơ tử cung
import json
import sys
import numpy as np
import cv2
import torch
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

from yolo import YOLO
from train_unet_approved37 import UNetSmall, IMAGE_SIZE

MIN_DETECTION_CONFIDENCE = 0.3
BOX_PADDING_RATIO = 0.05
SEG_THRESHOLD = 0.65
MIN_SEG_AREA = 500

def expand_box(box, image_width, image_height, padding_ratio):
    xmin, ymin, xmax, ymax = int(box["xmin"]), int(box["ymin"]), int(box["xmax"]), int(box["ymax"])
    box_width, box_height = xmax - xmin, ymax - ymin
    pad_x, pad_y = int(box_width * padding_ratio), int(box_height * padding_ratio)
    
    xmin = max(0, xmin - pad_x)
    ymin = max(0, ymin - pad_y)
    xmax = min(image_width, xmax + pad_x)
    ymax = min(image_height, ymax + pad_y)
    return xmin, ymin, xmax, ymax

def predict_segmentation_full_image(model, device, image):
    # Preprocess
    img_resized = image.convert("RGB").resize((IMAGE_SIZE, IMAGE_SIZE), Image.BILINEAR)
    img_array = np.array(img_resized).astype(np.float32) / 255.0
    input_tensor = torch.from_numpy(img_array.transpose(2, 0, 1)).float().unsqueeze(0).to(device)

    # Predict
    with torch.no_grad():
        logits = model(input_tensor)
        prob = torch.sigmoid(logits)[0, 0]

    pred_array = prob.detach().cpu().numpy()
    mask_array = (pred_array >= SEG_THRESHOLD).astype(np.uint8) * 255
    mask = Image.fromarray(mask_array, mode="L")
    return mask.resize(image.size, Image.NEAREST)

def postprocess_mask(mask):
    mask_array = np.array(mask).astype(np.uint8)
    num_labels, labels, stats, _ = cv2.connectedComponentsWithStats(mask_array, connectivity=8)
    if num_labels <= 1:
        return Image.fromarray(np.zeros_like(mask_array), mode="L")

    largest_label = 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])
    largest_area = stats[largest_label, cv2.CC_STAT_AREA]

    if largest_area < MIN_SEG_AREA:
        cleaned = np.zeros_like(mask_array)
    else:
        cleaned = (labels == largest_label).astype(np.uint8) * 255
    return Image.fromarray(cleaned, mode="L")

def create_overlay_result(original_image, final_mask, best_box):
    result = original_image.convert("RGBA")
    mask_array = np.array(final_mask)
    
    overlay = np.zeros((original_image.size[1], original_image.size[0], 4), dtype=np.uint8)
    overlay[mask_array > 0] = [255, 0, 0, 110] # Đỏ trong suốt cho u xơ
    overlay_image = Image.fromarray(overlay, mode="RGBA")
    result = Image.alpha_composite(result, overlay_image)
    
    draw = ImageDraw.Draw(result)
    xmin, ymin, xmax, ymax = int(best_box["xmin"]), int(best_box["ymin"]), int(best_box["xmax"]), int(best_box["ymax"])
    
    # Vẽ Bounding Box của YOLO màu xanh lá
    for i in range(3):
        draw.rectangle([xmin + i, ymin + i, xmax - i, ymax - i], outline=(0, 255, 0, 255))
        
    label = f"fibroid {float(best_box['confidence']):.2f}"
    draw.text((xmin, ymin - 20), label, fill=(0, 255, 0, 255))
    return result.convert("RGB")

def run_predict(input_image_path, output_dir):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    original_image = Image.open(input_image_path).convert("RGB")
    width, height = original_image.size

    yolo = YOLO()
    seg_model = load_segmentation_model(device)

    # Step 1: Chạy YOLO detect
    _ = yolo.detect_image(original_image.copy())
    detections = [det for det in getattr(yolo, "last_detections", []) if float(det["confidence"]) >= MIN_DETECTION_CONFIDENCE]

    if not detections:
        # Không phát hiện u xơ
        original_image.save(output_dir / "result.png")
        return {"detected": False, "message": "Không phát hiện u xơ tử cung."}

    # Step 2: Chọn Box có độ tin cậy cao nhất và chạy phân vùng U-Net
    best_box = max(detections, key=lambda item: float(item["confidence"]))
    expanded_box = expand_box(best_box, width, height, BOX_PADDING_RATIO)
    
    raw_mask = predict_segmentation_full_image(seg_model, device, original_image)
    
    # Lọc mask nằm ngoài hộp YOLO
    filtered_mask = np.zeros_like(raw_mask)
    xmin, ymin, xmax, ymax = expanded_box
    filtered_mask[ymin:ymax, xmin:xmax] = np.array(raw_mask)[ymin:ymax, xmin:xmax]
    
    final_mask = postprocess_mask(Image.fromarray(filtered_mask, mode="L"))
    
    # Kết xuất ảnh chèn lớp phủ
    result_image = create_overlay_result(original_image, final_mask, best_box)
    result_image.save(output_dir / "result.png")
    
    return {
        "detected": True,
        "confidence": round(float(best_box["confidence"]), 4),
        "message": "AI phát hiện vùng nghi ngờ u xơ tử cung."
    }
</code></pre>
                        </div>
                    </div>

                    <!-- Tab 2: U-Net Model Architecture -->
                    <div class="tab-pane fade" id="unet" role="tabpanel" aria-labelledby="unet-tab">
                        <div class="code-container">
                            <button class="btn btn-copy" onclick="copyCode('unet-code')"><i class="bi bi-copy"></i> Sao chép</button>
                            <pre><code id="unet-code" class="language-python"># train_unet_approved37.py — Kiến trúc mạng U-Net Small
import torch
import torch.nn as nn

class DoubleConv(nn.Module):
    """
    Khối tích chập kép (Double Convolutional Block)
    Gồm 2 lớp Conv2d, Batch Normalization và hàm kích hoạt ReLU
    """
    def __init__(self, in_channels: int, out_channels: int) -> None:
        super().__init__()
        self.block = nn.Sequential(
            nn.Conv2d(in_channels, out_channels, kernel_size=3, padding=1),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_channels, out_channels, kernel_size=3, padding=1),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True)
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.block(x)


class UNetSmall(nn.Module):
    """
    Kiến trúc U-Net thu nhỏ (UNetSmall) phù hợp chạy thời gian thực trên Web.
    Kích thước ảnh đầu vào chuẩn: 512 x 512 pixels.
    """
    def __init__(self) -> None:
        super().__init__()

        # Encoder (Nhánh xuống)
        self.down1 = DoubleConv(3, 32)
        self.pool1 = nn.MaxPool2d(2)

        self.down2 = DoubleConv(32, 64)
        self.pool2 = nn.MaxPool2d(2)

        self.down3 = DoubleConv(64, 128)
        self.pool3 = nn.MaxPool2d(2)

        # Bottleneck (Vùng nút cổ chai)
        self.bridge = DoubleConv(128, 256)

        # Decoder (Nhánh lên kết hợp Skip Connections)
        self.up3 = nn.ConvTranspose2d(256, 128, kernel_size=2, stride=2)
        self.conv3 = DoubleConv(256, 128)

        self.up2 = nn.ConvTranspose2d(128, 64, kernel_size=2, stride=2)
        self.conv2 = DoubleConv(128, 64)

        self.up1 = nn.ConvTranspose2d(64, 32, kernel_size=2, stride=2)
        self.conv1 = DoubleConv(64, 32)

        # Lớp đầu ra nhị phân (1 kênh màu xám biểu diễn u xơ tử cung)
        self.output = nn.Conv2d(32, 1, kernel_size=1)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        d1 = self.down1(x)
        p1 = self.pool1(d1)

        d2 = self.down2(p1)
        p2 = self.pool2(d2)

        d3 = self.down3(p2)
        p3 = self.pool3(d3)

        bridge = self.bridge(p3)

        # Up-convolution & Skip-connections
        u3 = self.up3(bridge)
        u3 = torch.cat([u3, d3], dim=1) # Ghép nối đặc trưng từ nhánh đối xứng
        u3 = self.conv3(u3)

        u2 = self.up2(u3)
        u2 = torch.cat([u2, d2], dim=1)
        u2 = self.conv2(u2)

        u1 = self.up1(u2)
        u1 = torch.cat([u1, d1], dim=1)
        u1 = self.conv1(u1)

        return self.output(u1)
</code></pre>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />

<!-- Prism.js Script for syntax highlighting -->
<script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/components/prism-core.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/plugins/autoloader/prism-autoloader.min.js"></script>
<!-- Bootstrap 5 Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    function copyCode(elementId) {
        const codeElement = document.getElementById(elementId);
        const codeText = codeElement.textContent;
        
        navigator.clipboard.writeText(codeText).then(() => {
            const btn = codeElement.parentElement.parentElement.querySelector('.btn-copy');
            const originalText = btn.innerHTML;
            btn.innerHTML = '<i class="bi bi-check-lg"></i> Đã chép!';
            btn.classList.add('btn-success', 'text-white');
            setTimeout(() => {
                btn.innerHTML = originalText;
                btn.classList.remove('btn-success', 'text-white');
            }, 2000);
        }).catch(err => {
            console.error('Không thể chép mã nguồn: ', err);
        });
    }
</script>
</body>
</html>
