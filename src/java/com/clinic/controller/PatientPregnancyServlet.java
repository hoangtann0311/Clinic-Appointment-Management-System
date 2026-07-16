package com.clinic.controller;

import com.clinic.dao.PatientDAO;
import com.clinic.dao.PregnancyDAO;
import com.clinic.model.Pregnancy;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;

/**
 * Servlet cho bệnh nhân xem tiến trình thai kỳ của bản thân (Theo dõi thai kỳ).
 * Đường dẫn: GET /patient/pregnancy
 */
@WebServlet("/patient/pregnancy")
public class PatientPregnancyServlet extends HttpServlet {

    private final PatientDAO patientDAO = new PatientDAO();
    private final PregnancyDAO pregnancyDAO = new PregnancyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRoleId() != 5) { // Bệnh nhân
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        int patientId = patientDAO.getPatientIdByUserId(user.getId());
        if (patientId <= 0) {
            request.setAttribute("errorMessage", "Tài khoản của bạn chưa được liên kết với hồ sơ bệnh nhân.");
            request.getRequestDispatcher("/views/patient/pregnancy_tracker.jsp").forward(request, response);
            return;
        }

        // Lấy thai kỳ active
        Pregnancy pregnancy = pregnancyDAO.getActiveByPatientId(patientId);

        if (pregnancy != null) {
            // Tính số tuần + ngày chi tiết
            LocalDate start = pregnancy.getStartDate();
            int currentWeeks = 0;
            int currentDays = 0;
            if (start != null) {
                long totalDays = ChronoUnit.DAYS.between(start, LocalDate.now());
                if (totalDays >= 0) {
                    currentWeeks = (int) (totalDays / 7);
                    currentDays = (int) (totalDays % 7);
                }
            }

            // Đếm ngược ngày sinh
            Long daysLeft = pregnancy.getDaysUntilDueDate();

            // Lấy dòng thời gian các mốc khám thai
            List<Map<String, Object>> timeline = pregnancyDAO.getTimelineByPregnancyId(pregnancy.getId());

            request.setAttribute("pregnancy", pregnancy);
            request.setAttribute("currentWeeks", currentWeeks);
            request.setAttribute("currentDays", currentDays);
            request.setAttribute("daysLeft", daysLeft);
            request.setAttribute("timeline", timeline);
        }

        request.getRequestDispatcher("/views/patient/pregnancy_tracker.jsp").forward(request, response);
    }
}
