package com.clinic.controller;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.User;
import com.clinic.model.Doctor;
import com.clinic.dao.DoctorDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.Duration;
import java.util.Set;
import java.util.HashSet;
import java.util.Map;
import java.util.HashMap;
import java.util.Collections;

/**
 * API JSON trả về danh sách ca làm việc (doctor_schedules) còn trống
 * của 1 bác sĩ trong 1 ngày — dùng cho AJAX ở trang đặt lịch bệnh nhân.
 *
 * GET /patient/booking/slots?doctorId=X&date=YYYY-MM-DD
 * → chỉ trả ca còn slot trống (booked_count < max_slots)
 *
 * GET /patient/booking/slots?doctorId=X&date=YYYY-MM-DD&all=1
 * → trả TẤT CẢ ca (cả đầy và trống) để UI hiển thị đầy đủ
 */
@WebServlet("/patient/booking/slots")
public class PatientSlotApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json; charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (user.getRoleId() != 5 && user.getRoleId() != 1 && user.getRoleId() != 4) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\":\"Không có quyền truy cập\"}");
            return;
        }

        int doctorId;
        LocalDate date;
        try {
            doctorId = Integer.parseInt(request.getParameter("doctorId"));
            date = LocalDate.parse(request.getParameter("date"));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Tham số doctorId/date không hợp lệ\"}");
            return;
        }

        boolean isStaff = (user.getRoleId() == 1 || user.getRoleId() == 4);
        boolean showAll = "1".equals(request.getParameter("all"));

        Doctor doctor = new DoctorDAO().findById(doctorId);
        double basePrice = 200000.00;
        if (doctor != null && doctor.getExperienceYears() > 0) {
            basePrice += (doctor.getExperienceYears() * 50000.00);
        }

        String sql;
        if (showAll) {
            sql = "SELECT ds.id, ds.work_date, ds.max_slots, ds.booked_count, ds.status, "
                + "s.name AS shift_name, s.start_time, s.end_time "
                + "FROM doctor_schedules ds "
                + "INNER JOIN shifts s ON ds.shift_id = s.id "
                + "WHERE ds.doctor_id = ? AND ds.work_date = ? AND ds.status = 'APPROVED' AND s.is_active = 1 "
                + "ORDER BY s.start_time";
        } else {
            sql = "SELECT ds.id, ds.work_date, ds.max_slots, ds.booked_count, ds.status, "
                + "s.name AS shift_name, s.start_time, s.end_time "
                + "FROM doctor_schedules ds "
                + "INNER JOIN shifts s ON ds.shift_id = s.id "
                + "WHERE ds.doctor_id = ? AND ds.work_date = ? AND ds.status = 'APPROVED' AND s.is_active = 1 "
                + "AND COALESCE(ds.booked_count, 0) < ds.max_slots "
                + "ORDER BY s.start_time";
        }

        StringBuilder json = new StringBuilder("[");
        boolean first = true;

        try (Connection conn = DatabaseConfig.getConnection()) {
            
            // 2. Fetch schedules
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, doctorId);
                ps.setDate(2, java.sql.Date.valueOf(date));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int id = rs.getInt("id");
                        int maxSlots = rs.getInt("max_slots");
                        int bookedCount = rs.getInt("booked_count");
                        String shiftName = rs.getString("shift_name");
                        
                        java.sql.Time sTimeSql = rs.getTime("start_time");
                        java.sql.Time eTimeSql = rs.getTime("end_time");
                        if (sTimeSql == null || eTimeSql == null || maxSlots <= 0) continue;
                        
                        LocalTime start = sTimeSql.toLocalTime();
                        LocalTime end = eTimeSql.toLocalTime();
                        String timeLabel = start.toString().substring(0, 5) + " - " + end.toString().substring(0, 5);
                        
                        boolean available = bookedCount < maxSlots;
                        if (!showAll && !available) continue; // Skip if showAll is false and it's booked
                        
                        if (!first) json.append(",");
                        first = false;
                        
                        String shiftCategory = "morning";
                        if (shiftName != null) {
                            if (shiftName.toLowerCase().contains("chiều")) {
                                shiftCategory = "afternoon";
                            } else if (shiftName.toLowerCase().contains("tối")) {
                                shiftCategory = "evening";
                            }
                        }

                        json.append("{")
                            .append("\"id\":").append(id).append(",")
                            .append("\"time\":\"").append(start.toString().substring(0, 5)).append("\",")
                            .append("\"endTime\":\"").append(end.toString().substring(0, 5)).append("\",")
                            .append("\"label\":\"").append(timeLabel).append("\",")
                            .append("\"shiftName\":\"").append(escapeJson(shiftName != null ? shiftName : "")).append("\",")
                            .append("\"shiftCategory\":\"").append(shiftCategory).append("\",")
                            .append("\"maxSlots\":").append(maxSlots).append(",")
                            .append("\"bookedCount\":").append(bookedCount).append(",")
                            .append("\"remaining\":").append(maxSlots - bookedCount).append(",")
                            .append("\"status\":\"").append(available ? "AVAILABLE" : "FULL").append("\",")
                            .append("\"statusLabel\":\"").append(available ? "Còn trống" : "Hết chỗ").append("\",")
                            .append("\"available\":").append(available).append(",")
                            .append("\"price\":").append(basePrice).append(",")
                            .append("\"mine\":false")
                            .append("}");
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[PatientSlotApiServlet] ERROR: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Lỗi truy vấn dữ liệu\"}");
            return;
        }

        json.append("]");
        try (PrintWriter out = response.getWriter()) {
            out.write(json.toString());
        }
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
