package com.clinic.controller;

import com.clinic.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/patient/notifications")
public class PatientNotificationServlet extends HttpServlet {

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
            com.clinic.dao.NotificationDAO notifDAO = new com.clinic.dao.NotificationDAO();
            List<com.clinic.model.Notification> notifications = notifDAO.getByUserId(user.getId());
            long unreadCount = notifications.stream().filter(n -> !n.isRead()).count();

            // Mark all as read
            notifDAO.markAllRead(user.getId());

            request.setAttribute("notifications", notifications);
            request.setAttribute("unreadCount", unreadCount);
            request.getRequestDispatcher("/views/patient/notifications.jsp").forward(request, response);

        } catch (Exception e) {
            // If notification table/DAO doesn't exist yet, show empty page
            request.setAttribute("notifications", java.util.Collections.emptyList());
            request.setAttribute("unreadCount", 0L);
            request.getRequestDispatcher("/views/patient/notifications.jsp").forward(request, response);
        }
    }
}
