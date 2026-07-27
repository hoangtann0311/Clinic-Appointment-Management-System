package com.clinic.model;

/**
 * Xác định giai đoạn khám của một lịch hẹn.
 * Dùng bởi getStage() — MỘT nguồn chân lý duy nhất cho cả UI và server validation.
 * KHÔNG lưu vào DB; suy ra từ dữ liệu gốc mỗi lần gọi.
 */
public enum ExamStage {

    /** Lịch chưa được bác sĩ tiếp nhận (không phải InProgress) hoặc đã hoàn tất */
    NOT_STARTED,

    /** Bác sĩ đã tiếp nhận (InProgress), chưa có bệnh án nháp */
    CLINICAL_EXAM,

    /** Đã có bệnh án nháp, có thể quyết định: không chỉ định / chỉ định siêu âm */
    ORDER_DECISION,

    /** Có chỉ định siêu âm, POST_EXAM chưa thanh toán */
    WAITING_PAYMENT,

    /** Có chỉ định đã thanh toán, đang chờ kết quả siêu âm */
    WAITING_ULTRASOUND,

    /** Tất cả siêu âm đã hoàn thành (hoặc không có chỉ định), sẵn sàng chẩn đoán */
    DIAGNOSIS,

    /** Đã nhập chẩn đoán + quyết định đơn thuốc, sẵn sàng chốt */
    READY_TO_FINALIZE,

    /** Hồ sơ đã chốt (medical_record.status = 'final') */
    FINALIZED;

    /** Tiếng Việt mô tả giai đoạn — dùng cho UI */
    public String toDisplayString() {
        switch (this) {
            case NOT_STARTED:        return "Chưa bắt đầu";
            case CLINICAL_EXAM:      return "Đang khám lâm sàng";
            case ORDER_DECISION:     return "Có thể chỉ định CLS";
            case WAITING_PAYMENT:    return "Chờ bệnh nhân thanh toán dịch vụ";
            case WAITING_ULTRASOUND: return "Chờ kết quả siêu âm";
            case DIAGNOSIS:          return "Sẵn sàng chẩn đoán";
            case READY_TO_FINALIZE:  return "Sẵn sàng chốt hồ sơ";
            case FINALIZED:          return "Đã hoàn tất";
            default:                 return name();
        }
    }
}
