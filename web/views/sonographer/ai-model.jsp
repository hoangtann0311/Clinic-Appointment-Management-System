<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp" />

<style>
    .ai-page {
        --ai-950: #493840;
        --ai-900: #754b5d;
        --ai-700: #a9607e;
        --ai-600: #b86689;
        --ai-500: #c8759a;
        --ai-200: #f7dce7;
        --ai-100: #fff1f6;
        --ai-50: #fff9fc;
        --ai-ink: #21181d;
        --ai-muted: #70656b;
        --ai-line: #eee2e6;
        --ai-surface: #ffffff;
    }
    .ai-page *,
    .ai-page *::before,
    .ai-page *::after { min-width: 0; box-sizing: border-box; }
    .ai-hero {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 1.25rem;
        padding: 1.45rem 1.55rem;
        margin-bottom: 1rem;
        border: 1px solid var(--ai-200);
        border-radius: 18px;
        background: linear-gradient(135deg, #fff 0%, var(--ai-50) 100%);
        box-shadow: 0 8px 24px rgba(184, 102, 137, .08);
    }
    .ai-hero h1 {
        margin: 0 0 .4rem;
        color: var(--ai-ink);
        font-size: clamp(1.45rem, 3vw, 2rem);
        font-weight: 850;
    }
    .ai-hero p {
        max-width: 820px;
        margin: 0;
        color: var(--ai-muted);
        line-height: 1.6;
    }
    .ai-current {
        flex: 0 0 auto;
        display: inline-flex;
        align-items: center;
        gap: .5rem;
        max-width: 100%;
        padding: .7rem .95rem;
        border-radius: 999px;
        background: var(--ai-600);
        color: #fff;
        font-weight: 800;
        overflow-wrap: anywhere;
    }
    .ai-scope-note {
        display: flex;
        align-items: flex-start;
        gap: .7rem;
        padding: .85rem 1rem;
        margin-bottom: 1.5rem;
        border-left: 4px solid var(--ai-600);
        border-radius: 10px;
        background: var(--ai-50);
        color: var(--ai-900);
        font-size: .87rem;
        line-height: 1.55;
    }
    .ai-section-heading {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        gap: 1rem;
        margin: 1.65rem 0 .85rem;
    }
    .ai-section-heading h2 {
        margin: 0;
        color: var(--ai-ink);
        font-size: 1.18rem;
        font-weight: 850;
    }
    .ai-section-heading p {
        margin: .25rem 0 0;
        color: var(--ai-muted);
        font-size: .84rem;
    }
    .ai-section-tag {
        flex: 0 0 auto;
        padding: .35rem .65rem;
        border: 1px solid var(--ai-200);
        border-radius: 999px;
        background: var(--ai-50);
        color: var(--ai-900);
        font-size: .72rem;
        font-weight: 750;
    }
    .ai-card {
        height: 100%;
        border: 1px solid var(--ai-line);
        border-radius: 16px;
        background: var(--ai-surface);
        box-shadow: 0 5px 18px rgba(47, 27, 37, .055);
        overflow: hidden;
    }
    .ai-card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: .8rem;
        padding: .95rem 1.1rem;
        border-bottom: 1px solid var(--ai-line);
        background: #fffbfc;
    }
    .ai-card-title {
        display: flex;
        align-items: center;
        gap: .6rem;
    }
    .ai-card-title i { color: var(--ai-600); font-size: 1.1rem; }
    .ai-card-title h3 {
        margin: 0;
        color: var(--ai-ink);
        font-size: .98rem;
        font-weight: 825;
    }
    .ai-card-body { padding: 1.1rem; }

    /* Nhận dạng model */
    .model-summary {
        display: grid;
        grid-template-columns: 1.4fr repeat(3, minmax(0, 1fr));
        gap: .8rem;
    }
    .model-summary-item {
        padding: .9rem;
        border: 1px solid #f3dbe2;
        border-radius: 12px;
        background: #fff9fb;
    }
    .model-summary-item small {
        display: block;
        margin-bottom: .3rem;
        color: var(--ai-muted);
        font-size: .73rem;
        font-weight: 700;
    }
    .model-summary-item strong {
        display: block;
        color: var(--ai-ink);
        font-size: .9rem;
        overflow-wrap: anywhere;
    }
    .model-summary-item.primary {
        border-color: var(--ai-200);
        background: var(--ai-50);
    }
    .model-summary-item.primary strong { color: var(--ai-900); font-size: 1rem; }
    .runtime-row {
        display: grid;
        grid-template-columns: minmax(0, 1fr) auto;
        gap: .8rem;
        align-items: center;
        margin-top: .9rem;
        padding: .85rem .95rem;
        border: 1px solid #eee2e6;
        border-radius: 12px;
        background: #fff;
    }
    .runtime-main {
        display: flex;
        align-items: flex-start;
        gap: .65rem;
        color: var(--ai-ink);
    }
    .runtime-main > i { margin-top: .12rem; color: var(--ai-600); }
    .runtime-main strong { display: block; font-size: .86rem; }
    .runtime-main small { color: var(--ai-muted); line-height: 1.45; }
    .runtime-chip {
        padding: .38rem .65rem;
        border-radius: 999px;
        font-size: .72rem;
        font-weight: 800;
        white-space: nowrap;
    }
    .runtime-chip.ready { background: var(--ai-50); color: var(--ai-900); border: 1px solid var(--ai-200); }
    .runtime-chip.pending { background: #fffbeb; color: #92400e; border: 1px solid #fde68a; }

    /* Metrics */
    .training-metric-grid {
        display: flex;
        flex-wrap: wrap;
        gap: .75rem;
    }
    .training-metric {
        flex: 1 1 220px;
        padding: .9rem;
        border: 1px solid var(--ai-line);
        border-top: 3px solid var(--ai-500);
        border-radius: 13px;
        background: #fff;
    }
    .training-metric-head {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        gap: .5rem;
        min-height: 36px;
    }
    .training-metric-head span:first-child {
        color: var(--ai-ink);
        font-size: .78rem;
        font-weight: 750;
        line-height: 1.35;
    }
    .metric-pass {
        flex: 0 0 auto;
        display: inline-flex;
        align-items: center;
        gap: .2rem;
        padding: .2rem .4rem;
        border-radius: 999px;
        background: var(--ai-50);
        color: var(--ai-900);
        font-size: .65rem;
        font-weight: 800;
    }
    .training-metric-value {
        margin: .5rem 0 .1rem;
        color: var(--ai-900);
        font-size: 1.65rem;
        font-weight: 900;
        line-height: 1;
    }
    .training-metric-threshold { color: var(--ai-muted); font-size: .7rem; }
    .metric-track {
        height: 6px;
        margin: .65rem 0;
        border-radius: 999px;
        background: #f3e7eb;
        overflow: hidden;
    }
    .metric-track > span {
        display: block;
        height: 100%;
        border-radius: inherit;
        background: linear-gradient(90deg, var(--ai-700), var(--ai-500));
    }
    .training-metric-desc {
        min-height: 34px;
        color: var(--ai-muted);
        font-size: .7rem;
        line-height: 1.4;
    }

    /* Biểu đồ và cấu hình train */
    .training-figure { margin: 0; }
    .training-figure img {
        display: block;
        width: 100%;
        max-height: 520px;
        margin: 0 auto;
        object-fit: contain;
        border: 1px solid var(--ai-line);
        border-radius: 12px;
        background: #fff;
    }
    .training-figure figcaption {
        margin-top: .65rem;
        color: var(--ai-muted);
        font-size: .76rem;
        line-height: 1.5;
    }
    .train-config-list {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: .65rem;
        margin-bottom: 1rem;
    }
    .train-config {
        padding: .72rem;
        border: 1px solid var(--ai-line);
        border-radius: 10px;
        background: #fffafb;
    }
    .train-config small { display: block; color: var(--ai-muted); font-size: .68rem; }
    .train-config strong { color: var(--ai-ink); font-size: .82rem; }
    .subheading {
        margin: 1rem 0 .55rem;
        color: var(--ai-ink);
        font-size: .82rem;
        font-weight: 825;
    }
    .dataset-bar {
        display: flex;
        width: 100%;
        height: 12px;
        margin-bottom: .75rem;
        border-radius: 999px;
        overflow: hidden;
        background: #f3e7eb;
    }
    .dataset-bar .train { width: 80%; background: var(--ai-700); }
    .dataset-bar .validation { width: 10%; background: var(--ai-500); }
    .dataset-bar .test { width: 10%; background: var(--ai-200); }
    .dataset-legend { display: grid; gap: .45rem; }
    .dataset-row {
        display: grid;
        grid-template-columns: minmax(0, 1fr) auto;
        align-items: center;
        gap: .7rem;
        font-size: .76rem;
    }
    .dataset-label { display: flex; align-items: center; gap: .45rem; color: var(--ai-muted); }
    .dataset-label i {
        width: 9px;
        height: 9px;
        border-radius: 50%;
        background: var(--dot);
    }
    .dataset-row strong { color: var(--ai-ink); }
    .augmentation-list { display: flex; flex-wrap: wrap; gap: .4rem; }
    .augmentation-list span {
        padding: .3rem .52rem;
        border: 1px solid var(--ai-200);
        border-radius: 999px;
        background: var(--ai-50);
        color: var(--ai-900);
        font-size: .68rem;
        font-weight: 700;
    }

    /* Usage */
    .usage-grid {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: .75rem;
    }
    .usage-item {
        display: flex;
        align-items: center;
        gap: .75rem;
        padding: .9rem;
        border: 1px solid var(--ai-line);
        border-radius: 12px;
        background: #fff;
    }
    .usage-icon {
        flex: 0 0 40px;
        width: 40px;
        height: 40px;
        display: grid;
        place-items: center;
        border-radius: 11px;
        background: var(--ai-50);
        color: var(--ai-700);
        font-size: 1.05rem;
    }
    .usage-value {
        display: block;
        color: var(--ai-900);
        font-size: 1.25rem;
        font-weight: 900;
        line-height: 1.2;
    }
    .usage-value.date { font-size: .88rem; }
    .usage-label { color: var(--ai-muted); font-size: .7rem; line-height: 1.35; }

    /* Process */
    .process-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: .75rem;
    }
    .process-step {
        display: flex;
        align-items: flex-start;
        gap: .7rem;
        padding: .9rem;
        border: 1px solid var(--ai-line);
        border-radius: 12px;
        background: #fff;
    }
    .process-number {
        flex: 0 0 31px;
        width: 31px;
        height: 31px;
        display: grid;
        place-items: center;
        border-radius: 50%;
        background: var(--ai-600);
        color: #fff;
        font-size: .75rem;
        font-weight: 850;
    }
    .process-step strong { display: block; margin-bottom: .15rem; color: var(--ai-ink); font-size: .8rem; }
    .process-step span { color: var(--ai-muted); font-size: .72rem; line-height: 1.45; }
    .pipeline-grid {
        display: flex;
        flex-wrap: wrap;
        gap: .65rem;
    }
    .pipeline-step {
        flex: 1 1 125px;
        padding: .9rem .65rem;
        border: 1px solid #f3dbe2;
        border-radius: 12px;
        background: #fff9fb;
        text-align: center;
    }
    .pipeline-step i {
        display: block;
        margin-bottom: .4rem;
        color: var(--ai-600);
        font-size: 1.25rem;
    }
    .pipeline-step strong { display: block; color: var(--ai-ink); font-size: .77rem; }
    .pipeline-step small { color: var(--ai-muted); font-size: .66rem; line-height: 1.35; }

    details.code-proof {
        border: 1px solid var(--ai-line);
        border-radius: 11px;
        overflow: hidden;
        background: #fff;
    }
    details.code-proof + details.code-proof { margin-top: .7rem; }
    details.code-proof summary {
        cursor: pointer;
        padding: .8rem .95rem;
        background: #fffafb;
        color: var(--ai-ink);
        font-size: .8rem;
        font-weight: 800;
    }
    details.code-proof pre {
        max-height: 340px;
        margin: 0;
        padding: 1rem;
        overflow: auto;
        background: #211a1e;
        color: #fce7f3;
        font-size: .75rem;
        white-space: pre;
    }
    @media (max-width: 1199.98px) {
        .model-summary { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .usage-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    }
    @media (max-width: 991.98px) {
        .ai-hero { align-items: flex-start; flex-direction: column; }
        .process-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    }
    @media (max-width: 767.98px) {
        .runtime-row { grid-template-columns: 1fr; }
        .runtime-chip { justify-self: start; }
    }
    @media (max-width: 575.98px) {
        .ai-hero { padding: 1.1rem; }
        .ai-current { border-radius: 12px; }
        .ai-section-heading { align-items: flex-start; flex-direction: column; }
        .model-summary,
        .usage-grid,
        .process-grid { grid-template-columns: 1fr; }
        .training-metric,
        .pipeline-step { flex-basis: 100%; }
        .training-metric-desc { min-height: 0; }
    }
</style>

<div class="ai-page">
    <header class="ai-hero">
        <div>
            <h1><i class="bi bi-cpu-fill me-2"></i>Hồ Sơ Mô Hình AI</h1>
            <p>
                Thông tin minh chứng cho model hỗ trợ phân tích ảnh siêu âm:
                model hiện hành, dữ liệu huấn luyện, kết quả đánh giá và mức độ sử dụng trong hệ thống.
            </p>
        </div>
        <div class="ai-current">
            <i class="bi bi-patch-check-fill"></i>
            <span><c:out value="${modelVersion}" /></span>
        </div>
    </header>

    <div class="ai-scope-note">
        <i class="bi bi-info-circle-fill"></i>
        <div>
            Trang này chỉ dùng để xem và đối chiếu hồ sơ kỹ thuật. AI không tự đưa ra kết luận lâm sàng;
            Bác sĩ siêu âm phải kiểm tra ảnh gốc, ảnh AI, chỉnh vùng khi cần và ký xác nhận kết quả.
        </div>
    </div>

    <section class="ai-card">
        <div class="ai-card-header">
            <div class="ai-card-title">
                <i class="bi bi-box-seam-fill"></i>
                <h3>Model Hiện Hành</h3>
            </div>
            <span class="ai-section-tag">Chỉ đọc</span>
        </div>
        <div class="ai-card-body">
            <div class="model-summary">
                <div class="model-summary-item primary">
                    <small>Tên mô hình</small>
                    <strong><c:out value="${modelName}" /></strong>
                </div>
                <div class="model-summary-item">
                    <small>Kiến trúc</small>
                    <strong>YOLOv3 + U-Net Small</strong>
                </div>
                <div class="model-summary-item">
                    <small>Mã lần huấn luyện</small>
                    <strong><c:out value="${trainingRunId}" /></strong>
                </div>
                <div class="model-summary-item">
                    <small>Nhiệm vụ</small>
                    <strong>Phát hiện và phân vùng vùng nghi ngờ u xơ</strong>
                </div>
            </div>

            <div class="runtime-row">
                <div class="runtime-main">
                    <i class="bi bi-terminal-fill"></i>
                    <div>
                        <strong>
                            Tệp suy luận: <c:out value="${inferenceScript}" />
                            · Đầu vào 512 × 512 px · Timeout ${processTimeoutSeconds} giây
                        </strong>
                        <small>
                            Model nhận ảnh siêu âm, tạo bounding box và mask để bác sĩ đối chiếu.
                        </small>
                    </div>
                </div>
                <c:choose>
                    <c:when test="${runtimeReady}">
                        <span class="runtime-chip ready"><i class="bi bi-check-circle me-1"></i>Đã cấu hình thực thi</span>
                    </c:when>
                    <c:otherwise>
                        <span class="runtime-chip pending"><i class="bi bi-exclamation-triangle me-1"></i>Thiếu đường dẫn Python</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <c:if test="${not runtimeReady}">
                <div class="text-muted small mt-2">
                    Máy chủ chưa tìm thấy cấu hình <code>ai.python.script</code>.
                    Cần trỏ khóa này tới <c:out value="${inferenceScript}" /> khi triển khai model thật.
                </div>
            </c:if>
        </div>
    </section>

    <div class="ai-section-heading">
        <div>
            <h2>1. Kết Quả Đánh Giá Model</h2>
            <p>Các chỉ số trên tập đánh giá của hồ sơ <c:out value="${trainingRunId}" />.</p>
        </div>
        <span class="ai-section-tag">5/5 chỉ số đạt ngưỡng</span>
    </div>

    <div class="training-metric-grid">
        <article class="training-metric">
            <div class="training-metric-head">
                <span>Dice / F1 phân vùng</span>
                <span class="metric-pass"><i class="bi bi-check"></i>Đạt</span>
            </div>
            <div class="training-metric-value">0,8942</div>
            <div class="training-metric-threshold">Ngưỡng chấp nhận &gt; 0,80</div>
            <div class="metric-track"><span style="width:89.42%"></span></div>
            <div class="training-metric-desc">Độ tương đồng giữa mask AI và mask gán nhãn.</div>
        </article>
        <article class="training-metric">
            <div class="training-metric-head">
                <span>Mean IoU</span>
                <span class="metric-pass"><i class="bi bi-check"></i>Đạt</span>
            </div>
            <div class="training-metric-value">0,8125</div>
            <div class="training-metric-threshold">Ngưỡng chấp nhận &gt; 0,75</div>
            <div class="metric-track"><span style="width:81.25%"></span></div>
            <div class="training-metric-desc">Phần giao trên phần hợp của vùng phân đoạn.</div>
        </article>
        <article class="training-metric">
            <div class="training-metric-head">
                <span>YOLO mAP@0.5</span>
                <span class="metric-pass"><i class="bi bi-check"></i>Đạt</span>
            </div>
            <div class="training-metric-value">0,9105</div>
            <div class="training-metric-threshold">Ngưỡng chấp nhận &gt; 0,85</div>
            <div class="metric-track"><span style="width:91.05%"></span></div>
            <div class="training-metric-desc">Độ chính xác trung bình của hộp định vị.</div>
        </article>
        <article class="training-metric">
            <div class="training-metric-head">
                <span>Precision</span>
                <span class="metric-pass"><i class="bi bi-check"></i>Đạt</span>
            </div>
            <div class="training-metric-value">0,8876</div>
            <div class="training-metric-threshold">Ngưỡng chấp nhận &gt; 0,80</div>
            <div class="metric-track"><span style="width:88.76%"></span></div>
            <div class="training-metric-desc">Tỷ lệ vùng AI dự đoán đúng trên tổng dự đoán.</div>
        </article>
        <article class="training-metric">
            <div class="training-metric-head">
                <span>Recall</span>
                <span class="metric-pass"><i class="bi bi-check"></i>Đạt</span>
            </div>
            <div class="training-metric-value">0,9012</div>
            <div class="training-metric-threshold">Ngưỡng chấp nhận &gt; 0,85</div>
            <div class="metric-track"><span style="width:90.12%"></span></div>
            <div class="training-metric-desc">Khả năng phát hiện, hạn chế bỏ sót vùng nghi ngờ.</div>
        </article>
    </div>

    <div class="ai-section-heading">
        <div>
            <h2>2. Dữ Liệu Và Quá Trình Huấn Luyện</h2>
            <p>Biểu đồ được đặt cạnh cấu hình để dễ đối chiếu loss, metrics và dữ liệu đầu vào.</p>
        </div>
        <span class="ai-section-tag">80 epoch</span>
    </div>

    <div class="row g-4">
        <div class="col-xl-8">
            <section class="ai-card">
                <div class="ai-card-header">
                    <div class="ai-card-title">
                        <i class="bi bi-graph-up-arrow"></i>
                        <h3>Đường Học Của Model</h3>
                    </div>
                    <span class="ai-section-tag">Train vs Validation</span>
                </div>
                <div class="ai-card-body">
                    <figure class="training-figure">
                        <img src="${pageContext.request.contextPath}/assets/images/ai-metrics/training_curves.png"
                             alt="Biểu đồ Training Loss, Validation Loss, Dice và IoU qua 80 epoch">
                        <figcaption>
                            Trái: Training Loss và Validation Loss giảm ổn định.
                            Phải: Dice đạt khoảng 0,89 và IoU đạt khoảng 0,81 ở cuối quá trình train.
                            Khoảng cách train–validation nhỏ cho thấy chưa có dấu hiệu overfitting lớn trên hồ sơ này.
                        </figcaption>
                    </figure>
                </div>
            </section>
        </div>

        <div class="col-xl-4">
            <section class="ai-card">
                <div class="ai-card-header">
                    <div class="ai-card-title">
                        <i class="bi bi-sliders"></i>
                        <h3>Cấu Hình Lần Train</h3>
                    </div>
                </div>
                <div class="ai-card-body">
                    <div class="train-config-list">
                        <div class="train-config"><small>Mã lần train</small><strong><c:out value="${trainingRunId}" /></strong></div>
                        <div class="train-config"><small>Số epoch</small><strong>80</strong></div>
                        <div class="train-config"><small>Kích thước ảnh</small><strong>512 × 512 px</strong></div>
                        <div class="train-config"><small>Loss U-Net</small><strong>BCE + Dice</strong></div>
                        <div class="train-config"><small>Ngưỡng YOLO</small><strong>0,30</strong></div>
                        <div class="train-config"><small>Ngưỡng mask</small><strong>0,65</strong></div>
                    </div>

                    <div class="subheading">Phân chia dataset — tổng 1.280 ảnh</div>
                    <div class="dataset-bar" aria-label="Train 80%, Validation 10%, Test 10%">
                        <span class="train"></span>
                        <span class="validation"></span>
                        <span class="test"></span>
                    </div>
                    <div class="dataset-legend">
                        <div class="dataset-row">
                            <span class="dataset-label"><i style="--dot:var(--ai-700)"></i>Train — 80%</span>
                            <strong>1.024 ảnh</strong>
                        </div>
                        <div class="dataset-row">
                            <span class="dataset-label"><i style="--dot:var(--ai-500)"></i>Validation — 10%</span>
                            <strong>128 ảnh</strong>
                        </div>
                        <div class="dataset-row">
                            <span class="dataset-label"><i style="--dot:var(--ai-200)"></i>Test — 10%</span>
                            <strong>128 ảnh</strong>
                        </div>
                    </div>

                    <div class="subheading">Tăng cường dữ liệu</div>
                    <div class="augmentation-list">
                        <span>Lật ngang</span>
                        <span>Lật dọc</span>
                        <span>Xoay ngẫu nhiên</span>
                        <span>Chỉnh độ sáng</span>
                    </div>
                </div>
            </section>
        </div>
    </div>

    <div class="ai-section-heading">
        <div>
            <h2>3. Minh Chứng Sử Dụng Trong Hệ Thống</h2>
            <p>Số liệu lấy trực tiếp từ bảng kết quả AI, không chứa thông tin định danh bệnh nhân.</p>
        </div>
        <span class="ai-section-tag">Dữ liệu thời gian thực</span>
    </div>

    <section class="ai-card">
        <div class="ai-card-body">
            <div class="usage-grid">
                <div class="usage-item">
                    <div class="usage-icon"><i class="bi bi-cpu"></i></div>
                    <div><span class="usage-value">${usageStats.totalRuns}</span><span class="usage-label">Lượt AI đã ghi nhận</span></div>
                </div>
                <div class="usage-item">
                    <div class="usage-icon"><i class="bi bi-check2-circle"></i></div>
                    <div><span class="usage-value">${usageStats.successfulRuns}</span><span class="usage-label">Lượt phân tích thành công</span></div>
                </div>
                <div class="usage-item">
                    <div class="usage-icon"><i class="bi bi-bounding-box"></i></div>
                    <div><span class="usage-value">${usageStats.detectedRuns}</span><span class="usage-label">Lượt có vùng nghi ngờ</span></div>
                </div>
                <div class="usage-item">
                    <div class="usage-icon"><i class="bi bi-clock-history"></i></div>
                    <div>
                        <span class="usage-value date">
                            <c:choose>
                                <c:when test="${not empty usageStats.latestRun}">
                                    <fmt:formatDate value="${usageStats.latestRun}" pattern="dd/MM/yyyy HH:mm" />
                                </c:when>
                                <c:otherwise>Chưa có dữ liệu</c:otherwise>
                            </c:choose>
                        </span>
                        <span class="usage-label">Lần phân tích gần nhất</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <div class="ai-section-heading">
        <div>
            <h2>4. Quy Trình Tạo Và Sử Dụng Model</h2>
            <p>Tách rõ quy trình huấn luyện offline và pipeline suy luận trong nghiệp vụ siêu âm.</p>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-xl-7">
            <section class="ai-card">
                <div class="ai-card-header">
                    <div class="ai-card-title">
                        <i class="bi bi-list-check"></i>
                        <h3>Quy Trình Huấn Luyện Offline</h3>
                    </div>
                </div>
                <div class="ai-card-body">
                    <div class="process-grid">
                        <div class="process-step"><span class="process-number">1</span><div><strong>Thu thập và gắn nhãn</strong><span>Tạo bounding box và mask vùng nghi ngờ trên ảnh siêu âm.</span></div></div>
                        <div class="process-step"><span class="process-number">2</span><div><strong>Chia dataset</strong><span>Tách Train 80%, Validation 10% và Test 10%.</span></div></div>
                        <div class="process-step"><span class="process-number">3</span><div><strong>Augmentation</strong><span>Lật, xoay và thay đổi độ sáng để tăng khả năng tổng quát hóa.</span></div></div>
                        <div class="process-step"><span class="process-number">4</span><div><strong>Huấn luyện</strong><span>YOLOv3 học bounding box; U-Net Small học mask phân vùng.</span></div></div>
                        <div class="process-step"><span class="process-number">5</span><div><strong>Đánh giá checkpoint</strong><span>So sánh loss, Dice, IoU, mAP, Precision và Recall.</span></div></div>
                        <div class="process-step"><span class="process-number">6</span><div><strong>Đóng gói model</strong><span>Chọn checkpoint đạt ngưỡng và tích hợp vào pipeline web.</span></div></div>
                    </div>
                </div>
            </section>
        </div>

        <div class="col-xl-5">
            <section class="ai-card">
                <div class="ai-card-header">
                    <div class="ai-card-title">
                        <i class="bi bi-diagram-3-fill"></i>
                        <h3>Pipeline Khi Phân Tích</h3>
                    </div>
                </div>
                <div class="ai-card-body">
                    <div class="pipeline-grid">
                        <div class="pipeline-step"><i class="bi bi-image"></i><strong>Ảnh gốc</strong><small>Kiểm tra đầu vào</small></div>
                        <div class="pipeline-step"><i class="bi bi-bounding-box"></i><strong>YOLOv3</strong><small>Định vị vùng</small></div>
                        <div class="pipeline-step"><i class="bi bi-grid-3x3-gap"></i><strong>U-Net</strong><small>Tạo mask</small></div>
                        <div class="pipeline-step"><i class="bi bi-layers"></i><strong>Hậu xử lý</strong><small>Lọc nhiễu</small></div>
                        <div class="pipeline-step"><i class="bi bi-person-check-fill"></i><strong>Bác sĩ</strong><small>Kiểm tra và ký</small></div>
                    </div>
                </div>
            </section>
        </div>
    </div>

    <div class="ai-section-heading">
        <div>
            <h2>5. Mã Nguồn Minh Chứng</h2>
            <p>Thu gọn mặc định để không làm rối trang; mở khi cần trình bày kỹ thuật.</p>
        </div>
    </div>

    <section class="ai-card">
        <div class="ai-card-body">
            <details class="code-proof">
                <summary><i class="bi bi-chevron-right me-2"></i>Kiến trúc U-Net Small dùng khi huấn luyện</summary>
                <pre><code>class UNetSmall(nn.Module):
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
            <details class="code-proof">
                <summary><i class="bi bi-chevron-right me-2"></i>Thông số pipeline suy luận</summary>
                <pre><code>MIN_DETECTION_CONFIDENCE = 0.30
BOX_PADDING_RATIO = 0.05
SEG_THRESHOLD = 0.65
MIN_SEG_AREA = 500
IMAGE_SIZE = 512

# YOLOv3 tìm bounding box có confidence cao nhất.
# U-Net dự đoán mask trên ảnh chuẩn hóa 512 x 512.
# Hậu xử lý giữ vùng hợp lệ và tạo ảnh lớp phủ.
# Bác sĩ siêu âm kiểm tra, chỉnh tay khi cần và ký xác nhận.</code></pre>
            </details>
        </div>
    </section>
</div>

<jsp:include page="../common/footer.jsp" />
