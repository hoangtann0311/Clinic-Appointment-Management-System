package com.clinic.controller;

import com.clinic.model.TimeSlot;
import com.clinic.model.User;
import com.clinic.service.PatientBookingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

/**
 * API nội bộ (JSON) trả về danh sách time-slot còn trống của 1 bác sĩ
 * trong 1 ngày — dùng cho AJAX ở trang đặt lịch (booking.jsp), cho phép
 * mở/đóng lịch trống ngay tại thẻ bác sĩ mà không cần load lại trang.
 *
 * GET /patient/booking/slots?doctorId=X&date=YYYY-MM-DD
 * → [{"id":1,"time":"08:00","label":"08:00 - 08:20"}, ...]   (mặc định: chỉ AVAILABLE)
 *
 * GET /patient/booking/slots?doctorId=X&date=YYYY-MM-DD&all=1
 * → trả về TẤT CẢ slot (trừ COMPLETED/CANCELLED), kèm status/available/statusLabel,
 *   để giao diện hiển thị đầy đủ khung giờ nhưng khóa (disable) các slot không phải
 *   AVAILABLE — tránh gây hiểu lầm "hệ thống lỗi mất khung giờ".
 *
 * Không dùng thư viện JSON ngoài (project chưa có Jackson/Gson) — dữ liệu
 * trả về chỉ gồm số nguyên và chuỗi giờ (HH:mm) nên tự dựng JSON thủ công
 * là an toàn, không cần escape phức tạp.
 */
@WebServlet("/patient/booking/slots")
public class PatientSlotApiServlet extends HttpServlet {

    private final PatientBookingService bookingService = new PatientBookingService();

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

        boolean showAll = "1".equals(request.getParameter("all")) || "true".equalsIgnoreCase(request.getParameter("all"));
        List<TimeSlot> slots = showAll
                ? bookingService.getSlotsForDisplay(doctorId, date)
                : bookingService.getAvailableSlots(doctorId, date);

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < slots.size(); i++) {
            TimeSlot s = slots.get(i);
            if (i > 0) json.append(",");
            json.append("{")
                .append("\"id\":").append(s.getId()).append(",")
                .append("\"time\":\"").append(s.getStartTime().toLocalTime().toString().substring(0, 5)).append("\",")
                .append("\"label\":\"").append(s.getTimeLabel()).append("\",")
                .append("\"price\":").append(s.getPrice() != null ? s.getPrice() : "null").append(",")
                .append("\"status\":\"").append(s.getStatus().name()).append("\",")
                .append("\"statusLabel\":\"").append(escapeJson(s.getStatus().getLabel())).append("\",")
                .append("\"available\":").append(s.isSelectable()).append(",")
                .append("\"mine\":").append(s.getBookedBy() != null && s.getBookedBy() == user.getId())
                .append("}");
        }
        json.append("]");

        try (PrintWriter out = response.getWriter()) {
            out.write(json.toString());
        }
    }

    /**
     * Escape tối thiểu cho chuỗi label (chỉ chứa chữ cái tiếng Việt, không có dấu
     * ngoặc kép), nhưng vẫn escape phòng hờ để tránh lỗi JSON nếu label thay đổi sau này.
     */
    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}