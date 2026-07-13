package com.clinic.controller;

import com.clinic.dao.NotificationDAO;
import com.clinic.model.Notification;
import com.clinic.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * API thông báo cho bác sĩ (trả JSON).
 *
 * GET  /doctor/notifications          → danh sách + số chưa đọc (JSON)
 * GET  /doctor/notifications?count=1  → chỉ trả số chưa đọc (JSON nhẹ cho polling)
 * POST /doctor/notifications?action=read&id=X      → đánh dấu 1 thông báo đã đọc
 * POST /doctor/notifications?action=readAll        → đánh dấu tất cả đã đọc
 */
@WebServlet("/doctor/notifications")
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notifDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getUser(req, resp);
        if (user == null) return;

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        // Chỉ trả số chưa đọc (cho polling nhẹ mỗi 30 giây)
        if ("1".equals(req.getParameter("count"))) {
            int unread = notifDAO.countUnread(user.getId());
            out.print("{\"unread\":" + unread + "}");
            return;
        }

        // Trả danh sách đầy đủ
        List<Notification> list = notifDAO.getByUserId(user.getId());
        int unread = 0;
        StringBuilder sb = new StringBuilder();
        sb.append("{\"unread\":");
        // đếm unread
        for (Notification n : list) if (!n.isRead()) unread++;
        sb.append(unread).append(",\"items\":[");
        for (int i = 0; i < list.size(); i++) {
            Notification n = list.get(i);
            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"id\":").append(n.getId()).append(",")
              .append("\"title\":\"").append(escJson(n.getTitle())).append("\",")
              .append("\"content\":\"").append(escJson(n.getContent())).append("\",")
              .append("\"timeAgo\":\"").append(escJson(n.getTimeAgo())).append("\",")
              .append("\"isRead\":").append(n.isRead())
              .append("}");
        }
        sb.append("]}");
        out.print(sb);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getUser(req, resp);
        if (user == null) return;

        String action = req.getParameter("action");
        resp.setContentType("application/json;charset=UTF-8");

        if ("readAll".equals(action)) {
            notifDAO.markAllRead(user.getId());
            resp.getWriter().print("{\"ok\":true}");
        } else if ("read".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                notifDAO.markRead(id, user.getId());
                resp.getWriter().print("{\"ok\":true}");
            } catch (NumberFormatException e) {
                resp.setStatus(400);
                resp.getWriter().print("{\"ok\":false}");
            }
        } else {
            resp.setStatus(400);
            resp.getWriter().print("{\"ok\":false}");
        }
    }

    private User getUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().print("{\"error\":\"unauthorized\"}");
            return null;
        }
        return (User) s.getAttribute("user");
    }

    private String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}