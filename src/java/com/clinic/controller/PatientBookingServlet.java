package com.clinic.controller;

import com.clinic.model.Appointment;
import com.clinic.model.Doctor;
import com.clinic.model.User;
import com.clinic.service.PatientBookingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Chức năng "Đặt lịch khám" cho Patient — mục 4.2 BA (Đặt lịch khám),
 * chức năng trung tâm của toàn hệ thống OCSS.
 *
 * URL patterns:
 *   GET  /patient/booking   → hiển thị danh sách bác sĩ + dịch vụ (khung giờ tải qua AJAX, xem PatientSlotApiServlet)
 *   POST /patient/booking   → xác nhận đặt lịch (slotId lấy từ khung giờ đã chọn)
 */
@WebServlet("/patient/booking")
public class PatientBookingServlet extends HttpServlet {

    private final PatientBookingService bookingService = new PatientBookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = requireLogin(request, response);
        if (user == null) return;

        try {
            String rescheduleId = request.getParameter("rescheduleId");
            if (rescheduleId != null) {
                request.setAttribute("rescheduleId", rescheduleId);
            }

            int page = 1;
            int pageSize = 10;
            String keyword = request.getParameter("keyword");

            if (request.getParameter("page") != null) {
                try {
                    page = Integer.parseInt(request.getParameter("page"));
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            List<Doctor> doctors = bookingService.getDoctorsPaginated(keyword, page, pageSize);
            int totalDoctors = bookingService.countDoctors(keyword);
            int totalPages = (int) Math.ceil((double) totalDoctors / pageSize);

            request.setAttribute("doctors", doctors);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("keyword", keyword);
            request.setAttribute("today", LocalDate.now().toString());

            request.getRequestDispatcher("/views/patient/booking.jsp").forward(request, response);
        } catch (Exception ex) {
            System.err.println("[PatientBookingServlet] doGet ERROR: " + ex.getMessage());
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Không thể tải trang. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/views/patient/booking.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User user = requireLogin(request, response);
        if (user == null) return;

        String slotIdParam = request.getParameter("slotId");
        String timeSlotParam = request.getParameter("timeSlot");
        String symptoms = request.getParameter("symptoms");
        String lmp = request.getParameter("lastMenstrualPeriod");
        String rescheduleIdParam = request.getParameter("rescheduleId");

        boolean isReschedule = (rescheduleIdParam != null && !rescheduleIdParam.trim().isEmpty());
        Map<String, String> errors = new HashMap<>();
        int slotId = 0;
        try {
            slotId = Integer.parseInt(slotIdParam);
        } catch (Exception e) {
            errors.put("general", isReschedule ? "Vui lòng chọn khung giờ hợp lệ." : "Vui lòng chọn khung giờ hợp lệ.");
        }

        Appointment appointment = null;
        if (errors.isEmpty()) {
            if (isReschedule) {
                try {
                    int rescheduleId = Integer.parseInt(rescheduleIdParam);
                    boolean ok = bookingService.rescheduleAppointment(user.getId(), rescheduleId, slotId, timeSlotParam, errors);
                    if (ok) {
                        HttpSession session = request.getSession();
                        session.setAttribute("bookingSuccess", "Đổi lịch khám thành công! Lịch hẹn mới đã được ghi nhận.");
                        response.sendRedirect(request.getContextPath() + "/patient/appointments");
                        return;
                    }
                } catch (NumberFormatException e) {
                    errors.put("general", "Mã lịch hẹn cần đổi không hợp lệ.");
                }
            } else {
                // serviceId = 0: bệnh nhân không chọn dịch vụ khi đặt lịch.
                // Dịch vụ cụ thể (siêu âm, xét nghiệm...) do bác sĩ chỉ định sau khi khám.
                appointment = bookingService.bookAppointment(
                        user.getId(), slotId, timeSlotParam, 0, symptoms, lmp, errors
                );
                if (appointment != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("bookingSuccess", "Đã đăng ký lịch khám thành công! Vui lòng có mặt tại quầy Lễ tân để check-in chậm nhất 15 phút trước giờ hẹn. Nếu đến muộn hơn, lịch hẹn sẽ không thể check-in.");
                    response.sendRedirect(request.getContextPath() + "/patient/appointments");
                    return;
                }
            }
        }

        // Đặt lịch hoặc đổi lịch thất bại — hiển thị lại form với lỗi
        request.setAttribute("errors", errors);
        if (isReschedule) {
            request.setAttribute("rescheduleId", rescheduleIdParam);
        }
        request.setAttribute("doctors", bookingService.getAllDoctors());
        request.setAttribute("today", LocalDate.now().toString());
        request.getRequestDispatcher("/views/patient/booking.jsp").forward(request, response);
    }

    private User requireLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return (User) session.getAttribute("user");
    }
}
