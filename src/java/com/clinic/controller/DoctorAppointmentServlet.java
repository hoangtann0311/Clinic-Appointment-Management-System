package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.dao.AppointmentDAO;
import com.clinic.model.Appointment;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

@WebServlet("/doctor/appointments")
public class DoctorAppointmentServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Lấy doctorId từ bảng doctors dựa trên user.id
        Integer doctorId = getDoctorIdByUserId(user.getId());
        if (doctorId == null) {
            request.setAttribute("errorMessage",
                "Tài khoản này chưa được liên kết với hồ sơ bác sĩ. (userId=" + user.getId() + ")");
            request.getRequestDispatcher("/views/doctors/appointment_list.jsp")
                   .forward(request, response);
            return;
        }

        // Parse tham số ngày
        String dateParam   = request.getParameter("date");
        String fromParam   = request.getParameter("from");
        String toParam     = request.getParameter("to");
        String statusParam = request.getParameter("status");

        List<Appointment> appointments;
        LocalDate viewDate = null;
        LocalDate fromDate = null;
        LocalDate toDate   = null;
        String mode;

        if (fromParam != null && !fromParam.isBlank()
                && toParam != null && !toParam.isBlank()) {
            fromDate = parseDate(fromParam, LocalDate.now().withDayOfMonth(1));
            toDate   = parseDate(toParam, LocalDate.now());
            if (fromDate.isAfter(toDate)) {
                LocalDate tmp = fromDate; fromDate = toDate; toDate = tmp;
            }
            appointments = appointmentDAO.getByDoctorDateRange(doctorId, fromDate, toDate, statusParam);
            mode = "range";
        } else {
            viewDate     = parseDate(dateParam, LocalDate.now());
            appointments = appointmentDAO.getByDoctorAndDate(doctorId, viewDate);
            mode = "single";
        }

        // Thống kê theo ngày đang xem: single → viewDate, range → fromDate, fallback → hôm nay
        LocalDate countDate = (viewDate != null) ? viewDate : (fromDate != null ? fromDate : LocalDate.now());
        Map<String, Integer> todayCounts = appointmentDAO.countTodayByStatus(doctorId, countDate);

        request.setAttribute("appointments",  appointments);
        request.setAttribute("todayCounts",   todayCounts);
        request.setAttribute("viewDate",      viewDate);
        request.setAttribute("fromDate",      fromDate);
        request.setAttribute("toDate",        toDate);
        request.setAttribute("mode",          mode);
        request.setAttribute("statusFilter",  statusParam != null ? statusParam : "");
        request.setAttribute("doctorName",    user.getFullName());

        request.getRequestDispatcher("/views/doctors/appointment_list.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        Integer doctorId = getDoctorIdByUserId(user.getId());
        if (doctorId == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không tìm thấy hồ sơ bác sĩ.");
            return;
        }

        String action = request.getParameter("action");
        if ("updateStatus".equals(action)) {
            String appointmentIdStr = request.getParameter("appointmentId");
            String newStatus        = request.getParameter("newStatus");

            // Danh sách trạng thái hợp lệ theo BA §7.1 (bác sĩ không được chuyển trực tiếp sang Emergency_SOS)
            java.util.List<String> allowed = java.util.Arrays.asList(
                "Pending", "Confirmed", "Waiting", "InProgress",
                "SUCCESS", "Cancelled", "NoShow"
            );
            // So sánh không phân biệt hoa thường để tránh lỗi nhập liệu
            boolean validStatus = newStatus != null && allowed.stream()
                    .anyMatch(s -> s.equalsIgnoreCase(newStatus));
            // Tìm canonical form
            String canonicalStatus = validStatus
                    ? allowed.stream().filter(s -> s.equalsIgnoreCase(newStatus)).findFirst().orElse(newStatus)
                    : null;

            if (appointmentIdStr == null || !validStatus) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tham số không hợp lệ.");
                return;
            }

            int appointmentId = Integer.parseInt(appointmentIdStr);
            boolean ok = appointmentDAO.updateStatus(appointmentId, doctorId, canonicalStatus);

            // Redirect lại trang hiện tại (giữ nguyên bộ lọc)
            String referer = request.getHeader("Referer");
            if (referer != null && !referer.isBlank()) {
                response.sendRedirect(referer);
            } else {
                response.sendRedirect(request.getContextPath() + "/doctor/appointments");
            }
            return;
        }

        response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }

    /**
     * Query bảng doctors để lấy doctors.id từ users.id
     */
    private Integer getDoctorIdByUserId(int userId) {
        String sql = "SELECT id FROM doctors WHERE user_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private LocalDate parseDate(String value, LocalDate fallback) {
        if (value == null || value.isBlank()) return fallback;
        try { return LocalDate.parse(value); }
        catch (DateTimeParseException e) { return fallback; }
    }
}