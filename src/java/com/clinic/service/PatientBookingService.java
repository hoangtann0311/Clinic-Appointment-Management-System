package com.clinic.service;

import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.DoctorDAO;
import com.clinic.dao.PatientDAO;
import com.clinic.dao.ServiceDAO;
import com.clinic.dao.TimeSlotDAO;
import com.clinic.model.Appointment;
import com.clinic.model.Doctor;
import com.clinic.model.Patient;
import com.clinic.model.ServiceItem;
import com.clinic.model.TimeSlot;
import com.clinic.model.enums.SlotStatus;

import java.sql.Connection;
import java.sql.PreparedStatement;
import com.clinic.config.DatabaseConfig;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Service cho nghiệp vụ "Đặt lịch khám" của Patient (BA mục 4.2, 4.3)
 * — chức năng trung tâm của toàn hệ thống OCSS.
 *
 * <p>Quy tắc nghiệp vụ áp dụng (theo BA mục 6):
 * <ul>
 *   <li>Mỗi time-slot của một Doctor chỉ được đặt một lần (đảm bảo bởi
 *       {@link TimeSlotService#bookSlot} — atomic booking, chống double-booking).</li>
 *   <li>Chỉ lịch làm việc đã được Manager duyệt mới có time_slots (sinh tự động
 *       khi duyệt), nên Patient chỉ có thể chọn slot AVAILABLE — không cần
 *       kiểm tra lại điều kiện duyệt ở đây.</li>
 *   <li>Patient không được chọn thời gian trong quá khứ.</li>
 *   <li>Patient chỉ được huỷ lịch trước giờ khám tối thiểu 30 phút.</li>
 * </ul>
 *
 * <p><strong>Lưu ý về ID:</strong> {@code time_slots.booked_by} tham chiếu
 * {@code users.id} (theo FK_time_slots_booked_by), trong khi
 * {@code appointments.patient_id} tham chiếu {@code patients.id}. Hai giá trị
 * này KHÔNG giống nhau — service này luôn tách biệt rõ {@code userId} và
 * {@code patientId}, tránh lặp lại lỗi nhầm lẫn đã gặp ở nhiều chỗ khác
 * trong hệ thống (xem báo cáo validate trước đó).
 */
public class PatientBookingService {

    private final PatientDAO patientDAO = new PatientDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final TimeSlotDAO timeSlotDAO = new TimeSlotDAO();
    private final TimeSlotService timeSlotService = new TimeSlotService();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    // ── Dữ liệu tra cứu cho form đặt lịch ──────────────────────────────

    public List<Doctor> getAllDoctors() {
        return doctorDAO.getAllDoctors();
    }

    public List<ServiceItem> getAllServices() {
        return serviceDAO.getAllServices();
    }

    /**
     * Danh sách time-slot còn trống (AVAILABLE) của 1 bác sĩ trong 1 ngày.
     * Không trả slot của ngày quá khứ.
     */
    public List<TimeSlot> getAvailableSlots(int doctorId, LocalDate date) {
        if (doctorId <= 0 || date == null || date.isBefore(LocalDate.now())) {
            return List.of();
        }
        List<TimeSlot> slots = timeSlotDAO.findByDoctorAndDateWithPrice(doctorId, Date.valueOf(date), SlotStatus.AVAILABLE);

        LinkedHashMap<LocalTime, TimeSlot> unique = new LinkedHashMap<>();
        for (TimeSlot slot : slots) {
            unique.putIfAbsent(slot.getStartTime().toLocalTime(), slot);
        }
        return new ArrayList<>(unique.values());
    }

    /**
     * Danh sách TẤT CẢ time-slot (mọi trạng thái, trừ COMPLETED/CANCELLED) của 1 bác sĩ
     * trong 1 ngày — dùng để hiển thị đầy đủ lưới giờ khám cho bệnh nhân, trong đó slot
     * không phải AVAILABLE vẫn hiển thị nhưng bị khóa (disable), thay vì ẩn hoàn toàn.
     *
     * <p>Lý do nghiệp vụ: nếu chỉ trả AVAILABLE, bệnh nhân sẽ tưởng nhầm hệ thống bị lỗi
     * "tự dưng mất mất 1 khung giờ" khi thực ra khung giờ đó đang được người khác giữ chỗ/
     * chờ duyệt/đã đặt. Hiển thị rõ trạng thái giúp bệnh nhân yên tâm và hiểu đúng lý do.
     */
    public List<TimeSlot> getSlotsForDisplay(int doctorId, LocalDate date) {
        if (doctorId <= 0 || date == null || date.isBefore(LocalDate.now())) {
            return List.of();
        }
        List<TimeSlot> slots = timeSlotDAO.findByDoctorAndDateWithPrice(doctorId, Date.valueOf(date), null);

        LinkedHashMap<LocalTime, TimeSlot> unique = new LinkedHashMap<>();
        for (TimeSlot slot : slots) {
            if (slot.getStatus() == SlotStatus.COMPLETED || slot.getStatus() == SlotStatus.CANCELLED) {
                continue;
            }
            unique.putIfAbsent(slot.getStartTime().toLocalTime(), slot);
        }
        return new ArrayList<>(unique.values());
    }

    // ── Đặt lịch khám ───────────────────────────────────────────────────

    /**
     * Đặt lịch khám cho bệnh nhân đang đăng nhập.
     *
     * @param userId     users.id của tài khoản đang đăng nhập (dùng để book slot)
     * @param slotId     time_slots.id được chọn
     * @param serviceId  một dịch vụ chính mà bệnh nhân chủ động chọn.
     *                   Phí khám bác sĩ (base fee) vẫn được tính riêng từ slot/doctor.
     * @param symptoms   triệu chứng (bắt buộc — theo BA 4.2)
     * @param lmpStr     ngày kinh cuối cùng, định dạng yyyy-MM-dd (có thể rỗng)
     * @param errors     map lỗi để trả về cho UI (key -&gt; message)
     * @return Appointment vừa tạo, hoặc {@code null} nếu thất bại (xem errors)
     */
    public Appointment bookAppointment(int userId, int slotId, int serviceId,
                                        String symptoms, String lmpStr,
                                        Map<String, String> errors) {

        // 1. Bệnh nhân phải có hồ sơ patients liên kết với tài khoản
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) {
            com.clinic.model.User currentUser = new com.clinic.dao.UserDAO().findById(userId);
            if (currentUser != null) {
                com.clinic.model.Patient created = patientDAO.createPatientWithUserId(
                        currentUser.getFullName(),
                        currentUser.getPhone(),
                        null,
                        userId
                );
                if (created != null) {
                    patientId = created.getId();
                }
            }
        }
        if (patientId <= 0) {
            errors.put("general", "Tài khoản của bạn chưa có hồ sơ bệnh nhân. Vui lòng liên hệ lễ tân để được hỗ trợ.");
            return null;
        }

        // 2. Dịch vụ khám (serviceId) — không bắt buộc khi đặt lịch.
        // Bệnh nhân chỉ đặt lịch khám với bác sĩ; các dịch vụ cụ thể
        // (siêu âm, xét nghiệm...) do bác sĩ chỉ định sau khi khám lâm sàng.
        // serviceId = 0 → dùng dịch vụ mặc định "Khám lâm sàng".
        int actualServiceId = serviceId;
        if (actualServiceId <= 0) {
            actualServiceId = serviceDAO.getDefaultExaminationServiceId();
        }
        if (serviceDAO.findServiceById(actualServiceId) == null) {
            errors.put("general", "Hệ thống chưa cấu hình dịch vụ khám mặc định. Vui lòng liên hệ quản trị viên.");
            return null;
        }

        // 3. Triệu chứng bắt buộc (BA 4.2: "Patient nhập triệu chứng và ngày kinh cuối")
        if (symptoms == null || symptoms.trim().isEmpty()) {
            errors.put("symptoms", "Vui lòng mô tả triệu chứng.");
            return null;
        }
        if (symptoms.trim().length() > 500) {
            errors.put("symptoms", "Triệu chứng không được vượt quá 500 ký tự.");
            return null;
        }

        // 4. Ngày kinh cuối — không bắt buộc, nhưng nếu có phải hợp lệ, không ở tương lai
        LocalDate lmp = null;
        if (lmpStr != null && !lmpStr.isBlank()) {
            try {
                lmp = LocalDate.parse(lmpStr.trim());
            } catch (Exception e) {
                errors.put("lmp", "Ngày kinh cuối không hợp lệ.");
                return null;
            }
            if (lmp.isAfter(LocalDate.now())) {
                errors.put("lmp", "Ngày kinh cuối không được ở tương lai.");
                return null;
            }
        }

        // 5. Kiểm tra slot tồn tại và hợp lệ
        TimeSlot slot = timeSlotDAO.findById(slotId);
        if (slot == null) {
            errors.put("slotId", "Khung giờ khám không tồn tại.");
            return null;
        }
        if (!slot.isAvailable()) {
            errors.put("slotId", "Khung giờ khám này đã bị người khác đặt.");
            return null;
        }

        // 6. Chống trường hợp đặt lịch vào thời gian đã qua
        LocalDate workDate = slot.getWorkDate().toLocalDate();
        LocalTime startTime = slot.getStartTime().toLocalTime();
        if (workDate.isBefore(LocalDate.now())
                || (workDate.isEqual(LocalDate.now()) && startTime.isBefore(LocalTime.now()))) {
            errors.put("general", "Không thể đặt lịch vào thời điểm đã qua. Vui lòng chọn khung giờ khác.");
            return null;
        }

        // 7. Tính phí khám bác sĩ (base fee): lấy từ giá riêng của slot (theo ngày/giờ cụ thể).
        //    Nếu slot chưa được thiết lập giá thì basePrice = 0 (hiển thị "Liên hệ" ở UI).
        // Never turn an unpublished fee into a zero-value PRE_EXAM invoice.
        // A deliberate fee of 0 remains valid because its value is not null.
        if (slot.getPrice() == null) {
            errors.put("slotId", "Gi\u00e1 kh\u00e1m c\u1ee7a khung gi\u1edd n\u00e0y ch\u01b0a \u0111\u01b0\u1ee3c c\u00f4ng b\u1ed1. Vui l\u00f2ng ch\u1ecdn khung gi\u1edd kh\u00e1c ho\u1eb7c li\u00ean h\u1ec7 ph\u00f2ng kh\u00e1m.");
            return null;
        }
        double basePrice = slot.getPrice();

        // 8. Thực hiện đặt slot và tạo appointment trong cùng một transaction
        String gestationalAge = AppointmentDAO.calculateGestationalAge(lmp, workDate);
        boolean success = appointmentDAO.bookSlotAndCreateAppointment(
                userId, patientId, slotId, actualServiceId, basePrice, symptoms.trim(), lmp, gestationalAge, errors
        );

        if (!success) {
            return null;
        }

        // Truy vấn lịch hẹn vừa tạo để trả về đối tượng đầy đủ.
        // QUAN TRỌNG: loại trừ appointment đã Cancelled — nếu bệnh nhân
        // hủy rồi rebook cùng slot, appointment cũ (Cancelled) vẫn có
        // cùng slot_id, gây trả nhầm ID → invoice cũ Cancelled → lỗi
        // "Hóa đơn này thuộc dữ liệu trạng thái cũ".
        List<Appointment> appts = appointmentDAO.getByPatientId(patientId);
        for (Appointment a : appts) {
            if (a.getSlotId() != null && a.getSlotId() == slotId
                    && a.getStatus() != null
                    && !"Cancelled".equalsIgnoreCase(a.getStatus())
                    && !"NoShow".equalsIgnoreCase(a.getStatus())) {
                return a;
            }
        }
        return null;
    }

    // ── Xem / huỷ lịch hẹn của bệnh nhân ────────────────────────────────

    public List<Appointment> getMyAppointments(int userId) {
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) {
            com.clinic.model.User currentUser = new com.clinic.dao.UserDAO().findById(userId);
            if (currentUser != null) {
                com.clinic.model.Patient created = patientDAO.createPatientWithUserId(
                        currentUser.getFullName(),
                        currentUser.getPhone(),
                        null,
                        userId
                );
                if (created != null) {
                    patientId = created.getId();
                }
            }
        }
        if (patientId <= 0) return List.of();
        return appointmentDAO.getByPatientId(patientId);
    }

    /**
     * Huỷ lịch hẹn của bệnh nhân đang đăng nhập.
     *
     * <p>Quy tắc thời gian (theo thực tế phòng khám):
     * <ol>
     *   <li><b>Grace period 15 phút:</b> trong vòng 15 phút sau khi đặt lịch,
     *       được phép huỷ ngay (phòng trường hợp đặt nhầm).</li>
     *   <li><b>Trước giờ khám 2 tiếng:</b> nếu ngoài grace period, phải huỷ
     *       trước giờ khám ít nhất 2 tiếng để phòng khám kịp xếp bệnh nhân khác.</li>
     * </ol>
     */
    public boolean cancelAppointment(int userId, int appointmentId, Map<String, String> errors) {
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) {
            errors.put("general", "Tài khoản của bạn chưa có hồ sơ bệnh nhân.");
            return false;
        }

        Appointment appt = appointmentDAO.findAppointmentById(appointmentId);
        if (appt == null) {
            errors.put("general", "Lịch hẹn không tồn tại.");
            return false;
        }

        // Bảo mật: chỉ được huỷ lịch hẹn của chính mình
        if (appt.getPatientId() != patientId) {
            errors.put("general", "Bạn không có quyền huỷ lịch hẹn này.");
            return false;
        }

        if (!"Pending".equalsIgnoreCase(appt.getStatus()) && !"Confirmed".equalsIgnoreCase(appt.getStatus())) {
            errors.put("general", "Chỉ có thể huỷ lịch hẹn đang ở trạng thái Chờ xác nhận hoặc Đã xác nhận.");
            return false;
        }

        // A collected PRE_EXAM payment must never disappear behind a normal
        // patient cancellation.
        if (appointmentDAO.isPreExamPaid(appointmentId)) {
            errors.put("general", "Lịch hẹn đã thanh toán. Vui lòng liên hệ lễ tân để được hỗ trợ hủy và hoàn tiền theo quy trình.");
            return false;
        }

        // ── Time-based cancel policy ──
        String timeError = validateCancelOrRescheduleTime(appt, userId);
        if (timeError != null) {
            errors.put("general", timeError);
            return false;
        }

        boolean success = appointmentDAO.cancelAppointmentAndReleaseSlot(appointmentId, userId, "Bệnh nhân huỷ lịch hẹn");
        if (!success) {
            errors.put("general", "Không thể huỷ lịch hẹn hoặc lịch hẹn đã hoàn thành/đang tiến hành.");
            return false;
        }
        return true;
    }

    /**
     * Đổi lịch khám (reschedule) của bệnh nhân.
     * Giải phóng slot cũ và đặt slot mới.
     *
     * <p>Quy tắc thời gian: giống như huỷ lịch —
     * xem {@link #validateCancelOrRescheduleTime(Appointment, int)}.
     */
    public boolean rescheduleAppointment(int userId, int appointmentId, int newSlotId, Map<String, String> errors) {
        int patientId = patientDAO.getPatientIdByUserId(userId);
        if (patientId <= 0) {
            errors.put("general", "Tài khoản của bạn chưa có hồ sơ bệnh nhân.");
            return false;
        }

        Appointment appt = appointmentDAO.findAppointmentById(appointmentId);
        if (appt == null) {
            errors.put("general", "Lịch hẹn không tồn tại.");
            return false;
        }

        if (appt.getPatientId() != patientId) {
            errors.put("general", "Bạn không có quyền đổi lịch hẹn này.");
            return false;
        }

        if (!"Pending".equalsIgnoreCase(appt.getStatus()) && !"Confirmed".equalsIgnoreCase(appt.getStatus())) {
            errors.put("general", "Chỉ có thể đổi lịch hẹn đang ở trạng thái Chờ xác nhận hoặc Đã xác nhận.");
            return false;
        }

        // ── Time-based reschedule policy (giống cancel) ──
        String timeError = validateCancelOrRescheduleTime(appt, userId);
        if (timeError != null) {
            errors.put("general", timeError);
            return false;
        }

        // Kiểm tra slot mới tồn tại và hợp lệ
        TimeSlot newSlot = timeSlotDAO.findById(newSlotId);
        if (newSlot == null) {
            errors.put("slotId", "Khung giờ khám mới không tồn tại.");
            return false;
        }
        if (!newSlot.isAvailable()) {
            errors.put("slotId", "Khung giờ khám mới đã bị người khác đặt.");
            return false;
        }
        LocalDate workDate = newSlot.getWorkDate().toLocalDate();
        LocalTime startTime = newSlot.getStartTime().toLocalTime();
        if (workDate.isBefore(LocalDate.now())
                || (workDate.isEqual(LocalDate.now()) && startTime.isBefore(LocalTime.now()))) {
            errors.put("general", "Không thể đổi lịch sang thời điểm đã qua. Vui lòng chọn khung giờ khác.");
            return false;
        }

        // Lấy slot cũ
        Integer oldSlotId = appointmentDAO.getSlotIdByAppointmentId(appointmentId);
        if (oldSlotId == null) {
            errors.put("general", "Lịch hẹn cũ không có liên kết khung giờ khám.");
            return false;
        }

        // Thực hiện đổi lịch nguyên tử trong transaction
        boolean ok = appointmentDAO.rescheduleAppointmentTransaction(
                appointmentId, oldSlotId, newSlotId, userId,
                java.sql.Date.valueOf(workDate), java.sql.Time.valueOf(startTime), errors
        );

        if (ok) {
            // Log hành động
            com.clinic.dao.AuditLogDAO auditLogDAO = new com.clinic.dao.AuditLogDAO();
            auditLogDAO.logAction(
                    "Đổi lịch hẹn sang ngày " + newSlot.getWorkDate() + " slot " + newSlot.getTimeLabel(),
                    "Patient",
                    "appointments",
                    String.valueOf(oldSlotId),
                    String.valueOf(newSlotId)
            );
            return true;
        }
        return false;
    }

    /**
     * Kiểm tra thời gian huỷ/đổi lịch có hợp lệ không.
     *
     * <p>Chính sách thời gian (theo thực tế phòng khám sản phụ khoa):
     * <ol>
     *   <li><b>Luôn phải trước giờ khám ≥ 2 tiếng:</b> đây là nguyên tắc cứng —
     *       phòng khám cần ít nhất 2 tiếng để xếp bệnh nhân khác vào slot trống.
     *       Nếu còn dưới 2 tiếng là đến giờ khám → KHÔNG được huỷ/đổi (kể cả
     *       vừa đặt xong), phải liên hệ lễ tân.</li>
     *   <li><b>Grace period 15 phút sau khi đặt:</b> trong vòng 15 phút sau khi
     *       đặt lịch VÀ lịch vẫn còn cách ≥ 2 tiếng → cho phép huỷ/đổi ngay
     *       (đặt nhầm bác sĩ, nhầm giờ…).</li>
     * </ol>
     *
     * @return thông báo lỗi nếu KHÔNG được phép, hoặc {@code null} nếu hợp lệ
     */
    private String validateCancelOrRescheduleTime(Appointment appt, int userId) {
        // 1. Tính thời gian còn lại đến giờ khám
        java.time.LocalDateTime apptDateTime = null;
        if (appt.getTimeSlot() != null && appt.getTimeSlot().contains("-")) {
            try {
                java.time.LocalTime time = java.time.LocalTime.parse(
                        appt.getTimeSlot().split("-")[0].trim());
                apptDateTime = java.time.LocalDateTime.of(
                        appt.getAppointmentDate(), time);
            } catch (Exception ignored) {
                // Không parse được giờ — vẫn cho phép
                return null;
            }
        }

        // 2. Nguyên tắc cứng: phải còn ≥ 2 tiếng trước giờ khám.
        //    Nếu slot sắp đến giờ (dưới 2 tiếng), không ai được huỷ/đổi —
        //    kể cả vừa đặt xong, vì phòng khám không kịp lấp slot.
        if (apptDateTime != null
                && apptDateTime.isBefore(java.time.LocalDateTime.now().plusHours(2))) {
            return "Chỉ được huỷ/đổi lịch trước giờ khám tối thiểu 2 tiếng. "
                    + "Nếu cần gấp, vui lòng liên hệ lễ tân.";
        }

        // 3. Grace period 15 phút: nếu vừa đặt trong 15 phút và lịch còn ≥ 2 tiếng
        //    → cho phép huỷ/đổi ngay (đặt nhầm).
        Integer slotId = appointmentDAO.getSlotIdByAppointmentId(appt.getId());
        if (slotId != null) {
            TimeSlot slot = timeSlotDAO.findById(slotId);
            if (slot != null && slot.getBookedAt() != null) {
                java.time.LocalDateTime bookedAt = slot.getBookedAt()
                        .toLocalDateTime();
                if (bookedAt.isAfter(java.time.LocalDateTime.now().minusMinutes(15))) {
                    return null;
                }
            }
        }

        // 4. Đã quá grace period nhưng còn ≥ 2 tiếng → vẫn cho phép
        return null;
    }
}
