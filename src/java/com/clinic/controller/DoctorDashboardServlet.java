package com.clinic.controller;


import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.DoctorDAO;
import com.clinic.dao.MedicalRecordDAO;
import com.clinic.utils.NotificationHelper;
import com.clinic.model.Appointment;
import com.clinic.model.MedicalRecord;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Dashboard ri�ng cho b�c s?.
 * GET /doctor/dashboard
 */
@WebServlet("/doctor/dashboard")
public class DoctorDashboardServlet extends HttpServlet {

    private final AppointmentDAO   appointmentDAO   = new AppointmentDAO();
    private final MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            User user = (User) session.getAttribute("user");
            Integer doctorId = DoctorDAO.getDoctorIdByUserId(user.getId());
            if (doctorId == null) {
                req.setAttribute("errorMessage", "Tài khoản chưa được liên kết hồ sơ bác sĩ.");
                req.getRequestDispatcher("/views/doctors/dashboard.jsp").forward(req, resp);
                return;
            }

            LocalDate today = LocalDate.now();

            // Th?ng k� l?ch h?n h�m nay
            Map<String, Integer> todayCounts = appointmentDAO.countTodayByStatus(doctorId, today);
            int totalToday = todayCounts.values().stream().mapToInt(Integer::intValue).sum();

            // Danh s�ch l?ch h?n h�m nay (t?i ?a 5 c�i g?n nh?t)
            List<Appointment> todayAppointments = appointmentDAO.getByDoctorAndDate(doctorId, today);

            // Th?ng k� b?nh �n: t?ng s? h? s? b�c s? ?� t?o
            int totalRecords = medicalRecordDAO.countByDoctorId(doctorId);

            // 5 h? s? b?nh �n g?n nh?t
            List<MedicalRecord> recentRecords = medicalRecordDAO.getRecentByDoctorId(doctorId, 5);

            // Đếm số ca ưu tiên đang chờ hôm nay (chỉ đếm Waiting + isPriority)
            int priorityCount = 0;
            for (Appointment a : todayAppointments) {
                if (a.isPriority() && "Waiting".equalsIgnoreCase(a.getStatus())) {
                    priorityCount++;
                }
            }

            req.setAttribute("doctorName",        user.getFullName());
            req.setAttribute("todayCounts",       todayCounts);
            req.setAttribute("totalToday",        totalToday);
            req.setAttribute("todayAppointments", todayAppointments);
            req.setAttribute("totalRecords",      totalRecords);
            req.setAttribute("recentRecords",     recentRecords);
            req.setAttribute("today",             today);
            req.setAttribute("priorityCount",     priorityCount);

            // Kiểm tra và tạo nhắc nhở cho hồ sơ draft chờ > 24h
            try { NotificationHelper.checkDraftReminders(doctorId, user.getId()); }
            catch (Exception ignored) {}

            req.getRequestDispatcher("/views/doctors/dashboard.jsp").forward(req, resp);
        } catch (Exception ex) {
            System.err.println("[DoctorDashboardServlet] doGet ERROR: " + ex.getMessage());
            ex.printStackTrace();
            req.setAttribute("errorMessage", "Không thể tải trang. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/views/doctors/dashboard.jsp").forward(req, resp);
        }
    }

}