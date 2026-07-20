package com.clinic.controller;

import com.clinic.model.Patient;
import com.clinic.model.User;
import com.clinic.service.StaffReceptionService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Internal receptionist lookup used before a manual booking.  It prevents the
 * screen from suggesting fake sample profiles and preserves an existing
 * patient's identity when staff enters their phone number.
 */
@WebServlet("/admin/reception/patient-lookup")
public class StaffPatientLookupServlet extends HttpServlet {
    private final StaffReceptionService receptionService = new StaffReceptionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 4)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\":\"forbidden\"}");
            return;
        }

        String phone = request.getParameter("phone");
        if (phone == null || !phone.matches("^0\\d{9,10}$")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"invalid_phone\"}");
            return;
        }

        Patient patient = receptionService.findPatientByPhone(phone);
        if (patient == null) {
            response.getWriter().write("{\"exists\":false}");
            return;
        }

        String fullName = escapeJson(patient.getFullName());
        String dateOfBirth = patient.getDateOfBirth() == null ? "" : patient.getDateOfBirth().toString();
        response.getWriter().write("{\"exists\":true,\"fullName\":\"" + fullName
                + "\",\"dateOfBirth\":\"" + dateOfBirth + "\"}");
    }

    private static String escapeJson(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
