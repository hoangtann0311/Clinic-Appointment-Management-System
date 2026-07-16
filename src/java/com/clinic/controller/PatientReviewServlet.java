package com.clinic.controller;

import com.clinic.dao.AppointmentDAO;
import com.clinic.dao.ReviewDAO;
import com.clinic.model.Appointment;
import com.clinic.model.Review;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/patient/review")
public class PatientReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        String appointmentIdStr = request.getParameter("appointmentId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");

        if (appointmentIdStr == null || ratingStr == null) {
            response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=ThieuThongTinDanhGia");
            return;
        }

        try {
            int appointmentId = Integer.parseInt(appointmentIdStr);
            int rating = Integer.parseInt(ratingStr);

            Appointment appt = appointmentDAO.findAppointmentById(appointmentId);
            if (appt == null) {
                response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=LichHenKhongTonTai");
                return;
            }

            // Security check
            int patientId = new com.clinic.dao.PatientDAO().getPatientIdByUserId(user.getId());
            if (appt.getPatientId() != patientId) {
                response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=KhongCoQuyenDanhGia");
                return;
            }

            // Status check
            if (!"SUCCESS".equalsIgnoreCase(appt.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=LichHenChuaHoanThanh");
                return;
            }

            // Double review check
            if (reviewDAO.hasReviewed(appointmentId)) {
                response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=LichHenDaDuocDanhGia");
                return;
            }

            if (rating < 1 || rating > 5) {
                response.sendRedirect(request.getContextPath() + "/patient/appointments?bookingError=DiemDanhGiaKhongHopLe");
                return;
            }

            Review review = new Review();
            review.setAppointmentId(appointmentId);
            review.setRating(rating);
            review.setComment(comment != null ? comment.trim() : "");
            
            boolean ok = reviewDAO.insert(review);
            if (ok) {
                // Log action
                new com.clinic.dao.AuditLogDAO().logAction(
                        "Đánh giá Bác sĩ cho cuộc hẹn #" + appointmentId + " (Đánh giá: " + rating + " sao)",
                        "Patient",
                        "reviews",
                        "-",
                        String.valueOf(rating)
                );

                session.setAttribute("bookingSuccess", "Cảm ơn bạn đã gửi đánh giá bác sĩ!");
            } else {
                session.setAttribute("bookingError", "Lỗi lưu đánh giá. Vui lòng thử lại.");
            }

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("bookingError", "Thông tin đánh giá không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/patient/appointments");
    }
}
