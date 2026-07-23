package com.clinic.controller;

import com.clinic.dao.InvoiceDAO;
import com.clinic.dao.PrescriptionDAO;
import com.clinic.model.Invoice;
import com.clinic.model.Prescription;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/patient/invoices")
public class PatientInvoicesServlet extends HttpServlet {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final PrescriptionDAO prescriptionDAO = new PrescriptionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (user.getRoleId() != 5) { // Patient
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập.");
            return;
        }

        try {
            List<Invoice> invoices = invoiceDAO.getInvoicesByPatientUserId(user.getId());
            List<Prescription> prescriptionChoices =
                    prescriptionDAO.getPatientPurchaseChoices(user.getId());
            request.setAttribute("invoices", invoices);
            request.setAttribute("prescriptionChoices", prescriptionChoices);
            moveFlash(session, request, "purchaseSuccess");
            moveFlash(session, request, "purchaseError");
            request.getRequestDispatcher("/views/patient/invoices.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi tải hóa đơn.");
        }
    }

    private void moveFlash(HttpSession session, HttpServletRequest request, String key) {
        Object value = session.getAttribute(key);
        if (value != null) {
            request.setAttribute(key, value);
            session.removeAttribute(key);
        }
    }
}
