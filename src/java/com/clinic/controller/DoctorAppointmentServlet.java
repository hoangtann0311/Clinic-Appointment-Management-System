package com.clinic.controller;

import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.DoctorDAO;
import com.clinic.model.Appointment;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
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

        try {
            User user = (User) session.getAttribute("user");

            // Lấy doctorId từ bảng doctors dựa trên user.id
            Integer doctorId = DoctorDAO.getDoctorIdByUserId(user.getId());
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
                appointments = appointmentDAO.getByDoctorAndDate(doctorId, viewDate, statusParam);
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
        } catch (Exception ex) {
            System.err.println("[DoctorAppointmentServlet] doGet ERROR: " + ex.getMessage());
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Không thể tải trang. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/views/doctors/appointment_list.jsp").forward(request, response);
        }
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
        Integer doctorId = DoctorDAO.getDoctorIdByUserId(user.getId());
        if (doctorId == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không tìm thấy hồ sơ bác sĩ.");
            return;
        }

        String action = request.getParameter("action");
        if ("startConsultation".equals(action)) {
            String appointmentIdStr = request.getParameter("appointmentId");

            if (appointmentIdStr == null || appointmentIdStr.isBlank()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tham số không hợp lệ.");
                return;
            }

            int appointmentId;
            try {
                appointmentId = Integer.parseInt(appointmentIdStr);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã lịch hẹn không hợp lệ.");
                return;
            }
            boolean ok = appointmentDAO.startConsultation(appointmentId, doctorId);

            // Redirect an toàn về trang appointments (không dùng Referer — tránh open redirect)
            String dateParam = request.getParameter("date");
            String fromParam = request.getParameter("from");
            String toParam = request.getParameter("to");
            String statusParam = request.getParameter("status");
            StringBuilder qs = new StringBuilder("?");
            if (dateParam != null && !dateParam.isBlank()) qs.append("date=").append(java.net.URLEncoder.encode(dateParam, "UTF-8")).append("&");
            if (fromParam != null && !fromParam.isBlank()) qs.append("from=").append(java.net.URLEncoder.encode(fromParam, "UTF-8")).append("&");
            if (toParam != null && !toParam.isBlank()) qs.append("to=").append(java.net.URLEncoder.encode(toParam, "UTF-8")).append("&");
            if (statusParam != null && !statusParam.isBlank()) qs.append("status=").append(java.net.URLEncoder.encode(statusParam, "UTF-8")).append("&");
            qs.append(ok ? "success=consultationStarted" : "error=cannotStartConsultation");
            response.sendRedirect(request.getContextPath() + "/doctor/appointments" + qs.toString());
            return;
        }

        response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }

    private LocalDate parseDate(String value, LocalDate fallback) {
        if (value == null || value.isBlank()) return fallback;
        try { return LocalDate.parse(value); }
        catch (DateTimeParseException e) { return fallback; }
    }
}
