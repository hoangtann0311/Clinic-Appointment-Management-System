package com.clinic.service;

import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.DoctorDAO;
import com.clinic.dao.ServiceDAO;
import com.clinic.config.DatabaseConfig;
import com.clinic.model.Appointment;
import com.clinic.model.Doctor;
import com.clinic.model.ServiceItem;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.Period;
import java.util.ArrayList;
import java.util.List;

/**
 * Service tập trung validation đặt lịch, chỉnh sửa và đổi lịch khám.
 * Đảm bảo mọi entry point (Patient Booking, Staff Booking, Staff Edit, Reschedule)
 * áp dụng cùng một tập quy tắc nghiệp vụ chuẩn mực.
 */
public class AppointmentValidationService {

    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    public List<String> validateAppointmentInput(
            String name,
            String phone,
            String dob,
            String doctorId,
            String serviceId,
            String appointmentDate,
            String timeSlotLabel,
            String symptoms,
            String lmpStr
    ) {
        List<String> errors = new ArrayList<>();

        if (isEmpty(name)) {
            errors.add("Họ tên bệnh nhân không được để trống.");
        }

        if (isEmpty(phone)) {
            errors.add("Số điện thoại không được để trống.");
        } else if (!phone.matches("^0\\d{9,10}$")) {
            errors.add("Số điện thoại phải bắt đầu bằng 0 và có 10-11 chữ số.");
        }

        if (!isEmpty(dob)) {
            try {
                LocalDate birthDate = LocalDate.parse(dob);
                LocalDate today = LocalDate.now();

                if (birthDate.isAfter(today)) {
                    errors.add("Ngày sinh bệnh nhân không được lớn hơn ngày hiện tại.");
                } else {
                    int age = Period.between(birthDate, today).getYears();
                    if (age < 10) {
                        errors.add("Tuổi bệnh nhân phải từ 10 tuổi trở lên.");
                    }
                    if (age > 65) {
                        errors.add("Tuổi bệnh nhân không được vượt quá 65 tuổi. Vui lòng liên hệ bác sĩ để được tư vấn riêng.");
                    }
                }
            } catch (Exception e) {
                errors.add("Ngày sinh bệnh nhân không hợp lệ.");
            }
        }

        if (isEmpty(doctorId)) {
            errors.add("Vui lòng chọn bác sĩ.");
        }

        if (isEmpty(appointmentDate)) {
            errors.add("Vui lòng chọn ngày khám.");
        } else {
            try {
                LocalDate appDate = LocalDate.parse(appointmentDate);
                if (appDate.isBefore(LocalDate.now())) {
                    errors.add("Không được đặt lịch trong quá khứ.");
                }
            } catch (Exception e) {
                errors.add("Ngày khám không hợp lệ.");
            }
        }

        // Slot là bắt buộc cho tất cả các đối tượng (không có ngoại lệ bypass cho Staff)
        if (isEmpty(timeSlotLabel)) {
            errors.add("Vui lòng chọn khung giờ khám.");
        }

        if (isEmpty(symptoms)) {
            errors.add("Vui lòng nhập triệu chứng hoặc lý do khám.");
        } else {
            String cleanSymptoms = symptoms.trim();
            if (cleanSymptoms.length() < 10) {
                errors.add("Triệu chứng/lý do khám quá ngắn. Vui lòng nhập tối thiểu 10 ký tự.");
            }
            if (cleanSymptoms.length() > 500) {
                errors.add("Triệu chứng/lý do khám không được vượt quá 500 ký tự.");
            }
            if (cleanSymptoms.matches("^[0-9\\s]+$")) {
                errors.add("Triệu chứng/lý do khám không được chỉ chứa số.");
            }
            if (!cleanSymptoms.matches("^[\\p{L}0-9\\s,.()/-]+$")) {
                errors.add("Triệu chứng/lý do khám chứa ký tự không hợp lệ.");
            }
            if (cleanSymptoms.toLowerCase().matches(".*(.)\\1{5,}.*")) {
                errors.add("Triệu chứng/lý do khám không hợp lệ. Vui lòng nhập nội dung rõ ràng hơn.");
            }
            if (cleanSymptoms.split("\\s+").length < 2) {
                errors.add("Triệu chứng/lý do khám cần có ít nhất 2 từ.");
            }
        }

        if (!isEmpty(lmpStr) && !isEmpty(appointmentDate)) {
            try {
                LocalDate lmp = LocalDate.parse(lmpStr);
                LocalDate appDate = LocalDate.parse(appointmentDate);

                long totalDays = java.time.temporal.ChronoUnit.DAYS.between(lmp, appDate);
                if (totalDays > 294) {
                    errors.add("Ngày kinh cuối quá xa ngày khám. Tuổi thai vượt quá 42 tuần, vui lòng kiểm tra lại LMP.");
                }
                if (lmp.isAfter(appDate)) {
                    errors.add("Ngày kinh cuối không được sau ngày khám.");
                }
                if (lmp.isAfter(LocalDate.now())) {
                    errors.add("Ngày kinh cuối không được lớn hơn ngày hiện tại.");
                }
            } catch (Exception e) {
                errors.add("Ngày kinh cuối không hợp lệ.");
            }
        }

        return errors;
    }

    /**
     * Kiểm tra slot khả dụng cho đặt lịch / chỉnh sửa.
     */
    public String validateSlotAvailability(int doctorId, LocalDate date, int scheduleId, Integer currentScheduleId) {
        // Kiểm tra doctor_schedule thay vì time_slots
        String sql = "SELECT ds.doctor_id, ds.work_date, ds.status, ds.booked_count, ds.max_slots "
                + "FROM doctor_schedules ds WHERE ds.id = ?";
        try (java.sql.Connection conn = DatabaseConfig.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return "Ca khám không tồn tại.";
                if (rs.getInt("doctor_id") != doctorId) return "Ca khám không thuộc bác sĩ đã chọn.";
                if (!rs.getDate("work_date").toLocalDate().equals(date)) return "Ca khám không khớp ngày.";
                if (!"APPROVED".equals(rs.getString("status"))) return "Ca khám chưa được duyệt.";
                // Nếu không phải schedule đang giữ thì phải còn chỗ
                if (currentScheduleId == null || scheduleId != currentScheduleId) {
                    if (rs.getInt("booked_count") >= rs.getInt("max_slots")) {
                        return "Ca khám này đã hết chỗ.";
                    }
                }
                if (rs.getDate("work_date").toLocalDate().isBefore(LocalDate.now())) {
                    return "Không thể chọn ca khám đã trôi qua.";
                }
            }
        } catch (Exception e) {
            return "Lỗi kiểm tra ca khám: " + e.getMessage();
        }
        return null;
    }

    /**
     * Kiểm tra một bệnh nhân chỉ có 1 lịch khám ngoại trú còn hiệu lực trong cùng 1 ngày.
     * Trạng thái active: Pending, Confirmed, Waiting, InProgress.
     * Trạng thái kết thúc: Cancelled, NoShow, SUCCESS, Completed.
     *
     * @param patientId      ID bệnh nhân
     * @param date           Ngày khám
     * @param excludeApptId ID lịch hẹn hiện tại (khi edit/reschedule)
     * @param isStaff        Thao tác bởi Staff
     * @param overrideReason Lý do override của Staff (nếu có)
     * @return Thông báo lỗi nếu vi phạm, hoặc null nếu hợp lệ
     */
    public String validateSameDayActiveAppointment(int patientId, LocalDate date, Integer excludeApptId, boolean isStaff, String overrideReason) {
        if (patientId <= 0 || date == null) return null;

        List<Appointment> existing = appointmentDAO.getByPatientId(patientId);
        boolean hasConflict = false;
        for (Appointment a : existing) {
            if (excludeApptId != null && a.getId() == excludeApptId) {
                continue;
            }
            if (a.getAppointmentDate() != null && a.getAppointmentDate().equals(date)) {
                String st = a.getStatus();
                if (st != null && (st.equalsIgnoreCase("Pending")
                        || st.equalsIgnoreCase("Confirmed")
                        || st.equalsIgnoreCase("Waiting")
                        || st.equalsIgnoreCase("InProgress"))) {
                    hasConflict = true;
                    break;
                }
            }
        }

        if (hasConflict) {
            return "Bệnh nhân đã có 1 lịch khám ngoại trú còn hiệu lực trong ngày " + date + ". Không thể đặt thêm lịch mới cùng ngày.";
        }

        return null;
    }

    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}
