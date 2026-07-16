package controller;

import com.clinic.config.AuthorizationConfig;
import com.clinic.model.MedicalRecord;
import com.clinic.model.User;
import com.clinic.service.MedicalRecordService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

/**
 * Servlet xử lý sửa bệnh án cho Bác sĩ (Doctor).
 *
 * <p><b>URL:</b> /doctor/medical-records (GET & POST)
 *
 * <p><b>GET</b> (?id=X): Hiển thị form sửa bệnh án.
 * <br><b>POST</b>: Xử lý cập nhật bệnh án + ghi Audit Log.
 *
 * <p><b>Phân quyền:</b> AuthorizationFilter đảm bảo chỉ Doctor mới vào được
 * /doctor/*. Servlet này kiểm tra lại role như một lớp phòng thủ thứ hai.
 */
@WebServlet(urlPatterns = {"/doctor/medical-records", "/doctor/medical-records/"})
public class DoctorMedicalRecordServlet extends HttpServlet {

    private MedicalRecordService medicalRecordService;

    @Override
    public void init() throws ServletException {
        this.medicalRecordService = new MedicalRecordService();
    }

    // ══════════════════════════════════════════════════
    // GET — Hiển thị form sửa bệnh án
    // ══════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Kiểm tra session ──
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // ── Double-check role (defense in depth) ──
        if (currentUser.getRoleId() != AuthorizationConfig.ROLE_DOCTOR) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Bác sĩ mới có quyền sửa bệnh án.");
            return;
        }

        // ── Lấy ID từ query string ──
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn bệnh án cần sửa.");
            request.getRequestDispatcher("/views/errors/404.jsp").forward(request, response);
            return;
        }

        int recordId;
        try {
            recordId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID bệnh án không hợp lệ.");
            request.getRequestDispatcher("/views/errors/404.jsp").forward(request, response);
            return;
        }

        // ── Load bệnh án ──
        MedicalRecord record = medicalRecordService.getMedicalRecord(recordId);
        if (record == null) {
            request.setAttribute("error", "Không tìm thấy bệnh án #" + recordId);
            request.getRequestDispatcher("/views/errors/404.jsp").forward(request, response);
            return;
        }

        // ── Load thông tin bổ sung ──
        String patientName = medicalRecordService.getPatientName(recordId);
        Integer appointmentId = record.getAppointmentId();

        // ── Đọc flash message từ session (nếu có) ──
        String successMsg = (String) session.getAttribute("successMessage");
        if (successMsg != null) {
            request.setAttribute("successMessage", successMsg);
            session.removeAttribute("successMessage");
        }
        String errorMsg = (String) session.getAttribute("errorMessage");
        if (errorMsg != null) {
            request.setAttribute("errorMessage", errorMsg);
            session.removeAttribute("errorMessage");
        }

        // ── Set attributes cho JSP ──
        request.setAttribute("record", record);
        request.setAttribute("patientName", patientName != null ? patientName : "Không rõ");
        request.setAttribute("appointmentId", appointmentId);
        request.setAttribute("pageTitle", "Sửa bệnh án #" + recordId);

        request.getRequestDispatcher("/views/doctor/medical-record-edit.jsp").forward(request, response);
    }

    // ══════════════════════════════════════════════════
    // POST — Xử lý cập nhật bệnh án
    // ══════════════════════════════════════════════════
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Kiểm tra session ──
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // ── Double-check role ──
        if (currentUser.getRoleId() != AuthorizationConfig.ROLE_DOCTOR) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Bác sĩ mới có quyền sửa bệnh án.");
            return;
        }

        // ── Parse form data → MedicalRecord ──
        MedicalRecord record = parseForm(request);
        if (record == null) {
            session.setAttribute("errorMessage", "Dữ liệu form không hợp lệ.");
            String idParam = request.getParameter("id");
            response.sendRedirect(request.getContextPath() + "/doctor/medical-records?id="
                    + (idParam != null ? idParam : ""));
            return;
        }

        // ── Gọi service cập nhật (có audit log bên trong) ──
        MedicalRecordService.UpdateResult result =
                medicalRecordService.updateMedicalRecord(record, currentUser, request);

        // ── Set flash message + redirect ──
        if (result.isSuccess()) {
            session.setAttribute("successMessage", result.getMessage());
        } else {
            session.setAttribute("errorMessage", result.getMessage());
        }

        response.sendRedirect(request.getContextPath()
                + "/doctor/medical-records?id=" + record.getId());
    }

    // ══════════════════════════════════════════════════
    // PRIVATE — Parse form → MedicalRecord
    // ══════════════════════════════════════════════════

    /**
     * Parse toàn bộ form fields thành đối tượng MedicalRecord.
     *
     * @return MedicalRecord đã populate, hoặc null nếu thiếu ID.
     */
    private MedicalRecord parseForm(HttpServletRequest request) {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            return null;
        }

        MedicalRecord r = new MedicalRecord();
        r.setId(Integer.parseInt(idParam.trim()));

        // ── Dấu hiệu sinh tồn ──
        r.setWeightKg(parseBigDecimal(request.getParameter("weightKg")));
        r.setBloodPressure(trimToNull(request.getParameter("bloodPressure")));
        r.setPulseBpm(parseInteger(request.getParameter("pulseBpm")));
        r.setTemperatureC(parseBigDecimal(request.getParameter("temperatureC")));
        r.setHeightCm(parseBigDecimal(request.getParameter("heightCm")));

        // ── Thai kỳ ──
        r.setGestationalAgeWeeks(parseInteger(request.getParameter("gestationalAgeWeeks")));
        r.setGestationalAgeDays(parseInteger(request.getParameter("gestationalAgeDays")));
        r.setFundalHeightCm(parseBigDecimal(request.getParameter("fundalHeightCm")));
        r.setFetalHeartRate(parseInteger(request.getParameter("fetalHeartRate")));
        r.setFetalPresentation(trimToNull(request.getParameter("fetalPresentation")));
        r.setFetalPosition(trimToNull(request.getParameter("fetalPosition")));
        r.setFetalMovement(trimToNull(request.getParameter("fetalMovement")));

        // ── Cổ tử cung & Ối ──
        r.setCervicalDilationCm(parseBigDecimal(request.getParameter("cervicalDilationCm")));
        r.setCervicalEffacement(trimToNull(request.getParameter("cervicalEffacement")));
        r.setAmnioticFluid(trimToNull(request.getParameter("amnioticFluid")));
        r.setPresentationStation(trimToNull(request.getParameter("presentationStation")));

        // ── Triệu chứng ──
        r.setEdema(trimToNull(request.getParameter("edema")));
        r.setProteinuria(trimToNull(request.getParameter("proteinuria")));
        r.setVaginalBleeding(parseBoolean(request.getParameter("vaginalBleeding")));
        r.setUterineContractions(parseBoolean(request.getParameter("uterineContractions")));

        // ── Chẩn đoán & Điều trị (các field quan trọng nhất) ──
        r.setClinicalNotes(trimToNull(request.getParameter("clinicalNotes")));
        r.setFinalDiagnosis(trimToNull(request.getParameter("finalDiagnosis")));
        r.setRiskFlagsJson(trimToNull(request.getParameter("riskFlagsJson")));
        r.setTreatmentPlan(trimToNull(request.getParameter("treatmentPlan")));
        r.setNextAppointmentDate(parseDate(request.getParameter("nextAppointmentDate")));
        r.setReferredTo(trimToNull(request.getParameter("referredTo")));

        // ── Meta ──
        r.setStatus(trimToNull(request.getParameter("status")));
        if (r.getStatus() == null) {
            r.setStatus("final");
        }

        return r;
    }

    // ── Parse helpers ──

    private String trimToNull(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private Integer parseInteger(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return new BigDecimal(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Boolean parseBoolean(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        String v = value.trim().toLowerCase();
        if ("true".equals(v) || "1".equals(v) || "yes".equals(v) || "on".equals(v)) {
            return true;
        }
        if ("false".equals(v) || "0".equals(v) || "no".equals(v)) {
            return false;
        }
        return null;
    }

    private Date parseDate(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Date.valueOf(value.trim()); // yyyy-MM-dd
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
