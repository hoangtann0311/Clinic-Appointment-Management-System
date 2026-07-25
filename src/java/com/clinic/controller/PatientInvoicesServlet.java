package com.clinic.controller;

import com.clinic.dao.InvoiceDAO;
import com.clinic.dao.PatientDAO;
import com.clinic.model.Invoice;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * Hiển thị danh sách "Yêu cầu thanh toán" cho Bệnh nhân.
 * Danh sách phiếu thu chi phí chỉ định bởi Staff hoặc Bác sĩ.
 * Tất cả giao dịch thực tế được thu tại quầy Lễ tân/Thu ngân phòng khám.
 */
@WebServlet("/patient/invoices")
public class PatientInvoicesServlet extends HttpServlet {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final PatientDAO patientDAO = new PatientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        try {
            int patientId = patientDAO.getPatientIdByUserId(user.getId());
            List<Invoice> invoices = invoiceDAO.getInvoicesByPatientUserId(user.getId());
            request.setAttribute("invoices", invoices);
            request.getRequestDispatcher("/views/patient/invoices.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[PatientInvoicesServlet] doGet ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Không thể tải danh sách yêu cầu thanh toán.");
            request.getRequestDispatcher("/views/patient/invoices.jsp").forward(request, response);
        }
    }
}
