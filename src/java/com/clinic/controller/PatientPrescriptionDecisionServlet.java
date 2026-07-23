package com.clinic.controller;

import com.clinic.model.User;
import com.clinic.service.PrescriptionPurchaseService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/patient/prescription-decision")
public class PatientPrescriptionDecisionServlet extends HttpServlet {

    private final PrescriptionPurchaseService purchaseService =
            new PrescriptionPurchaseService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Chỉ bệnh nhân được xác nhận lựa chọn mua thuốc.");
            return;
        }

        try {
            int prescriptionId = Integer.parseInt(
                    request.getParameter("prescriptionId"));
            PrescriptionPurchaseService.DecisionResult result =
                    purchaseService.decide(user.getId(), prescriptionId,
                            request.getParameter("decision"), getClientIp(request));

            if ("Accepted".equals(result.getDecision())) {
                session.setAttribute("purchaseSuccess",
                        "Đã chọn mua thuốc tại phòng khám. Hóa đơn thuốc đã được tạo.");
            } else {
                session.setAttribute("purchaseSuccess",
                        "Đã ghi nhận không mua thuốc tại phòng khám. "
                        + "Đơn thuốc vẫn được lưu trong hồ sơ bệnh án.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("purchaseError", "Mã đơn thuốc không hợp lệ.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("purchaseError", e.getMessage());
        }

        response.sendRedirect(request.getContextPath()
                + "/patient/invoices#prescription-decisions");
    }

    private String getClientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
