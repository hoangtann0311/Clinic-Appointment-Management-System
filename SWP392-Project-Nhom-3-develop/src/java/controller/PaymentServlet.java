/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import DAO.InvoiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 *
 * @author ADMIN
 */
@WebServlet("/patient/payment")
public class PaymentServlet extends HttpServlet {

    private InvoiceDAO invoiceDAO
            = new InvoiceDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException, ServletException {

        int invoiceId
                = Integer.parseInt(
                        request.getParameter(
                                "invoiceId"));

        invoiceDAO.payInvoice(invoiceId);

        request.getRequestDispatcher(
                "/views/patient/paymentSuccess.jsp"
        ).forward(request, response);
    }
}
