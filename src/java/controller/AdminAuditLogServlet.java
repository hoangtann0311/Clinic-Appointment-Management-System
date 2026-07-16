package controller;

import com.clinic.model.AuditLog;
import com.clinic.service.AuditLogService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

/**
 * Servlet quản lý Lịch Sử Hoạt Động cho Admin.
 *
 * <p>GET → hiển thị danh sách audit log có filter + phân trang.
 * <p>POST → (dự phòng cho export Excel/CSV trong tương lai).
 *
 * <p>URL Patterns: /admin/audit-logs/ và /admin/audit-logs
 * <p>Permission required: system.view_audit_logs
 */
@WebServlet(urlPatterns = {"/admin/audit-logs/", "/admin/audit-logs"})
public class AdminAuditLogServlet extends HttpServlet {

    private static final int PAGE_SIZE = 20;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private AuditLogService auditLogService;

    @Override
    public void init() throws ServletException {
        auditLogService = new AuditLogService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── AJAX: trả về JSON chi tiết một audit log ──
        String action = request.getParameter("action");
        if ("detail".equals(action)) {
            handleDetailRequest(request, response);
            return;
        }

        // ── Đọc tham số filter từ query string ──
        String search    = request.getParameter("search");
        String tableName = request.getParameter("tableName");
        String userIdStr = request.getParameter("userId");
        String roleIdStr = request.getParameter("roleId");
        String dateFromStr = request.getParameter("dateFrom");
        String dateToStr   = request.getParameter("dateTo");
        String pageStr     = request.getParameter("page");

        Integer userId = null;
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try { userId = Integer.parseInt(userIdStr); } catch (NumberFormatException e) { /* bỏ qua */ }
        }

        Integer roleId = null;
        if (roleIdStr != null && !roleIdStr.isEmpty()) {
            try { roleId = Integer.parseInt(roleIdStr); } catch (NumberFormatException e) { /* bỏ qua */ }
        }

        LocalDate dateFrom = null;
        LocalDate dateTo   = null;
        if (dateFromStr != null && !dateFromStr.isEmpty()) {
            try { dateFrom = LocalDate.parse(dateFromStr, DATE_FORMATTER); } catch (DateTimeParseException e) { /* bỏ qua */ }
        }
        if (dateToStr != null && !dateToStr.isEmpty()) {
            try { dateTo = LocalDate.parse(dateToStr, DATE_FORMATTER); } catch (DateTimeParseException e) { /* bỏ qua */ }
        }

        int page = 1;
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) { /* giữ page = 1 */ }
        }

        // ── Lấy dữ liệu từ Service ──
        List<AuditLog> logs = auditLogService.getAuditLogs(page, PAGE_SIZE,
                search, tableName, userId, roleId, dateFrom, dateTo);
        int totalLogs = auditLogService.getTotalAuditLogs(search, tableName, userId, roleId, dateFrom, dateTo);
        int totalPages = (int) Math.ceil((double) totalLogs / PAGE_SIZE);

        // ── Lấy dữ liệu cho filter dropdown ──
        Map<String, String> tableOptions = auditLogService.getTableNameOptions();
        List<AuditLog> userOptions = auditLogService.getUserOptions();
        List<AuditLog> roleOptions = auditLogService.getRoleOptions();

        // ── Set attributes cho JSP ──
        request.setAttribute("auditLogs", logs);
        request.setAttribute("totalLogs", totalLogs);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", PAGE_SIZE);

        // Filter state (giữ lại giá trị đã chọn để render lại form)
        request.setAttribute("filterSearch", search);
        request.setAttribute("filterTableName", tableName);
        request.setAttribute("filterUserId", userId);
        request.setAttribute("filterRoleId", roleId);
        request.setAttribute("filterDateFrom", dateFromStr);
        request.setAttribute("filterDateTo", dateToStr);

        // Dropdown options
        request.setAttribute("tableOptions", tableOptions);
        request.setAttribute("userOptions", userOptions);
        request.setAttribute("roleOptions", roleOptions);

        // Page title
        request.setAttribute("pageTitle", "Lịch Sử Hoạt Động");

        // ── Forward đến JSP ──
        request.getRequestDispatcher("/views/admin/audit-logs/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Xử lý export CSV
        String action = request.getParameter("action");
        if ("export-csv".equals(action)) {
            handleExportCsv(request, response);
            return;
        }
        doGet(request, response);
    }

    /**
     * Xuất audit log ra CSV (tương thích Excel với BOM UTF-8).
     * Xuất tối đa 1000 bản ghi gần nhất theo filter hiện tại.
     */
    private void handleExportCsv(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        // ── Đọc tham số filter ──
        String search    = request.getParameter("search");
        String tableName = request.getParameter("tableName");
        String userIdStr = request.getParameter("userId");
        String roleIdStr = request.getParameter("roleId");
        String dateFromStr = request.getParameter("dateFrom");
        String dateToStr   = request.getParameter("dateTo");

        Integer userId = null;
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try { userId = Integer.parseInt(userIdStr); } catch (NumberFormatException e) { /* bỏ qua */ }
        }
        Integer roleId = null;
        if (roleIdStr != null && !roleIdStr.isEmpty()) {
            try { roleId = Integer.parseInt(roleIdStr); } catch (NumberFormatException e) { /* bỏ qua */ }
        }

        LocalDate dateFrom = null;
        LocalDate dateTo = null;
        if (dateFromStr != null && !dateFromStr.isEmpty()) {
            try { dateFrom = LocalDate.parse(dateFromStr, DATE_FORMATTER); } catch (DateTimeParseException e) { /* bỏ qua */ }
        }
        if (dateToStr != null && !dateToStr.isEmpty()) {
            try { dateTo = LocalDate.parse(dateToStr, DATE_FORMATTER); } catch (DateTimeParseException e) { /* bỏ qua */ }
        }

        // Lấy tối đa 1000 bản ghi
        List<AuditLog> logs = auditLogService.getAuditLogs(1, 1000,
                search, tableName, userId, roleId, dateFrom, dateTo);

        // Ghi audit log cho hành động export
        try {
            com.clinic.utils.AuditUtil.log(request,
                "Xuất CSV audit log (" + logs.size() + " bản ghi)",
                "audit_logs", null, null);
        } catch (Exception e) { /* ignore */ }

        // ── Response ──
        String fileName = "AuditLog_" + LocalDate.now().format(DATE_FORMATTER) + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        response.setCharacterEncoding("UTF-8");

        java.io.PrintWriter out = response.getWriter();
        // BOM cho Excel
        out.print('﻿');

        // Header
        out.println("ID,Thời Gian,Người Dùng,Vai Trò,Hành Động,Phân Hệ,Loại,Địa Chỉ IP");

        DateTimeFormatter dtFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

        for (AuditLog log : logs) {
            String time = log.getCreatedAt() != null
                    ? log.getCreatedAt().toLocalDateTime().format(dtFmt) : "";
            String ip = log.getIpAddress() != null ? log.getIpAddress() : "";

            out.println(log.getId() + ","
                + "\"" + time + "\","
                + "\"" + csvEscape(log.getUserName()) + "\","
                + "\"" + csvEscape(log.getRoleNameDisplay()) + "\","
                + "\"" + csvEscape(log.getAction()) + "\","
                + "\"" + csvEscape(log.getTableName()) + "\","
                + log.getActionTypeDisplay() + ","
                + "\"" + ip + "\"");
        }

        out.println();
        out.println("\"Tổng số bản ghi: " + logs.size() + "\",,,,,\"Xuất bởi CAMS\",,,");
    }

    /** Escape CSV field. */
    private String csvEscape(String value) {
        if (value == null) return "";
        return value.replace("\"", "\"\"");
    }

    /**
     * Xử lý AJAX request: trả về JSON chi tiết một audit log.
     * Endpoint: GET /admin/audit-logs/?action=detail&id=123
     */
    private void handleDetailRequest(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("id");
        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"error\":\"ID không hợp lệ.\"}");
            return;
        }

        AuditLog log = auditLogService.getAuditLogById(id);
        if (log == null) {
            response.getWriter().write("{\"error\":\"Không tìm thấy bản ghi #" + id + ".\"}");
            return;
        }

        // Format thời gian để dễ parse bên JS
        String createdAtStr = "—";
        if (log.getCreatedAt() != null) {
            createdAtStr = log.getCreatedAt().toLocalDateTime()
                    .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
        }

        // Build JSON thủ công (không cần thư viện JSON)
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"id\":").append(log.getId()).append(",");
        json.append("\"userName\":\"").append(escapeJson(log.getUserName())).append("\",");
        json.append("\"roleName\":\"").append(escapeJson(log.getRoleNameDisplay())).append("\",");
        json.append("\"action\":\"").append(escapeJson(log.getAction())).append("\",");
        json.append("\"tableName\":\"").append(escapeJson(log.getTableName())).append("\",");
        json.append("\"oldValue\":\"").append(escapeJson(log.getOldValue())).append("\",");
        json.append("\"newValue\":\"").append(escapeJson(log.getNewValue())).append("\",");
        json.append("\"ipAddress\":\"").append(escapeJson(log.getIpAddress())).append("\",");
        json.append("\"createdAtDisplay\":\"").append(createdAtStr).append("\",");
        json.append("\"actionType\":\"").append(escapeJson(log.getActionType())).append("\",");
        json.append("\"actionTypeDisplay\":\"").append(escapeJson(log.getActionTypeDisplay())).append("\"");
        json.append("}");

        response.getWriter().write(json.toString());
    }

    /** Escape ký tự đặc biệt để an toàn trong JSON string. */
    private String escapeJson(String value) {
        if (value == null) return "";
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
