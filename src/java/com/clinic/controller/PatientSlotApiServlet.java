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
 * → [{"id":1,"time":"08:00","label":"08:00 - 08:20"}, ...]
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
        if (user.getRoleId() != 5 && user.getRoleId() != 1) {
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

        List<TimeSlot> slots = bookingService.getAvailableSlots(doctorId, date);

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < slots.size(); i++) {
            TimeSlot s = slots.get(i);
            if (i > 0) json.append(",");
            json.append("{")
                .append("\"id\":").append(s.getId()).append(",")
                .append("\"time\":\"").append(s.getStartTime().toLocalTime().toString().substring(0, 5)).append("\",")
                .append("\"label\":\"").append(s.getTimeLabel()).append("\"")
                .append("}");
        }
        json.append("]");

        try (PrintWriter out = response.getWriter()) {
            out.write(json.toString());
        }
    }
}
