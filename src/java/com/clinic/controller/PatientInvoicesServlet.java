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
            
            int offset = (page - 1) * pageSize;
            List<Invoice> invoices = invoiceDAO.getInvoicesByPatientUserIdPaginated(user.getId(), keyword, offset, pageSize);
            int totalInvoices = invoiceDAO.countInvoicesByPatientUserId(user.getId(), keyword);
            int totalPages = (int) Math.ceil((double) totalInvoices / pageSize);

            request.setAttribute("invoices", invoices);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("keyword", keyword);
            
            request.getRequestDispatcher("/views/patient/invoices.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[PatientInvoicesServlet] doGet ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Không thể tải danh sách yêu cầu thanh toán.");
            request.getRequestDispatcher("/views/patient/invoices.jsp").forward(request, response);
        }
    }
}
