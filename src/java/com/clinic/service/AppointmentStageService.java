package com.clinic.service;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.ExamStage;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Xác định giai đoạn khám của một lịch hẹn.
 * MỘT nguồn chân lý duy nhất — dùng cho cả UI (ẩn/hiện nút) và server (chặn action sai bước).
 * KHÔNG lưu vào DB; suy ra từ dữ liệu gốc mỗi lần gọi.
 */
public class AppointmentStageService {

    /**
     * Xác định giai đoạn khám hiện tại của lịch hẹn.
     * Logic khớp với đặc tả P5 trong cams-prompt.md.
     */
    /**
     * Xác định giai đoạn khám — 1 query duy nhất thay vì 5 query riêng lẻ.
     */
    public ExamStage getStage(int appointmentId) {
        String sql = "SELECT a.status AS appt_status, mr.id AS mr_id, mr.status AS mr_status, "
                + "mr.final_diagnosis, mr.treatment_plan, "
                + "(SELECT COUNT(*) FROM test_orders o WHERE o.medical_record_id = mr.id "
                + " AND LOWER(LTRIM(RTRIM(ISNULL(o.status, '')))) NOT IN ('completed','confirmed','cancelled')) AS active_orders, "
                + "(SELECT COUNT(*) FROM invoices i WHERE i.appointment_id = a.id "
                + " AND UPPER(i.invoice_type) = 'POST_EXAM' AND UPPER(i.status) != 'Paid') AS unpaid_post, "
                + "(SELECT COUNT(*) FROM prescriptions rx WHERE rx.medical_record_id = mr.id) AS rx_count "
                + "FROM appointments a "
                + "LEFT JOIN medical_records mr ON mr.appointment_id = a.id "
                + "WHERE a.id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return ExamStage.NOT_STARTED;
                String status = rs.getString("appt_status");
                if (status == null) return ExamStage.NOT_STARTED;
                String s = status.trim();

                if ("SUCCESS".equalsIgnoreCase(s) || "Completed".equalsIgnoreCase(s)) {
                    return ExamStage.FINALIZED;
                }
                if (!"InProgress".equalsIgnoreCase(s)) {
                    return ExamStage.NOT_STARTED;
                }

                int mrId = rs.getInt("mr_id");
                boolean wasNull = rs.wasNull();
                String mrStatus = rs.getString("mr_status");

                if (!wasNull && "final".equalsIgnoreCase(mrStatus != null ? mrStatus.trim() : "")) {
                    return ExamStage.FINALIZED;
                }
                if (wasNull) {
                    return ExamStage.CLINICAL_EXAM;
                }

                int activeOrders = rs.getInt("active_orders");
                if (activeOrders > 0) {
                    int unpaidPost = rs.getInt("unpaid_post");
                    return unpaidPost > 0 ? ExamStage.WAITING_PAYMENT : ExamStage.WAITING_ULTRASOUND;
                }

                String diag = rs.getString("final_diagnosis");
                boolean hasDiagnosis = (diag != null && !diag.trim().isEmpty());
                boolean hasRx = rs.getInt("rx_count") > 0;
                String plan = rs.getString("treatment_plan");
                if (plan != null && !plan.trim().isEmpty()) hasRx = true;

                if (hasDiagnosis && hasRx) return ExamStage.READY_TO_FINALIZE;
                if (hasDiagnosis) return ExamStage.DIAGNOSIS;
                return ExamStage.ORDER_DECISION;
            }
        } catch (SQLException e) {
            System.err.println("[AppointmentStageService] getStage ERROR: " + e.getMessage());
            return ExamStage.NOT_STARTED;
        }
    }

    /**
     * Kiểm tra bác sĩ có được phép thực hiện action trên lịch hẹn này không.
     * @return null nếu được phép, hoặc thông báo lỗi tiếng Việt nếu bị chặn.
     */
    public String checkActionAllowed(int appointmentId, int doctorId, String action) {
        ExamStage stage = getStage(appointmentId);

        switch (action) {
            case "startConsultation":
                if (stage == ExamStage.NOT_STARTED) return null; // cho phép với điều kiện status=Waiting
                return "Không thể tiếp nhận ca: lịch hẹn đang ở giai đoạn «" + stage.toDisplayString() + "».";

            case "saveClinicalExam":
                if (stage == ExamStage.CLINICAL_EXAM || stage == ExamStage.ORDER_DECISION) return null;
                return "Không thể lưu khám lâm sàng: giai đoạn hiện tại là «" + stage.toDisplayString() + "».";

            case "orderUltrasound":
                if (stage == ExamStage.ORDER_DECISION) return null;
                if (stage == ExamStage.CLINICAL_EXAM)
                    return "Cần lưu bệnh án nháp trước khi chỉ định siêu âm.";
                return "Không thể chỉ định siêu âm: giai đoạn hiện tại là «" + stage.toDisplayString() + "».";

            case "cancelUltrasound":
                if (stage == ExamStage.WAITING_PAYMENT) return null;
                return "Chỉ có thể huỷ chỉ định khi đang chờ thanh toán. Giai đoạn hiện tại: «" + stage.toDisplayString() + "».";

            case "saveDiagnosis":
                if (stage == ExamStage.DIAGNOSIS || stage == ExamStage.READY_TO_FINALIZE) return null;
                if (stage == ExamStage.WAITING_ULTRASOUND)
                    return "Đang chờ kết quả siêu âm. Vui lòng đợi bác sĩ siêu âm hoàn tất.";
                if (stage == ExamStage.WAITING_PAYMENT)
                    return "Bệnh nhân chưa thanh toán dịch vụ siêu âm. Không thể chẩn đoán.";
                return "Không thể chẩn đoán: giai đoạn hiện tại là «" + stage.toDisplayString() + "».";

            case "finalizeRecord":
                if (stage == ExamStage.WAITING_ULTRASOUND)
                    return "Không thể chốt hồ sơ: còn kết quả siêu âm chưa có.";
                if (stage == ExamStage.WAITING_PAYMENT)
                    return "Không thể chốt hồ sơ: bệnh nhân chưa thanh toán dịch vụ.";
                if (stage == ExamStage.NOT_STARTED)
                    return "Ca khám chưa được tiếp nhận.";
                return null;

            default:
                return null;
        }
    }
}
