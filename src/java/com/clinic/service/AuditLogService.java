package com.clinic.service;

import com.clinic.dao.AuditLogDAO;
import com.clinic.model.AuditLog;

import java.time.LocalDate;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý nghiệp vụ nhật ký hoạt động.
 * Cung cấp dữ liệu cho AdminAuditLogServlet.
 */
public class AuditLogService {

    private final AuditLogDAO auditLogDAO;

    /** Map ánh xạ table_name → tên tiếng Việt hiển thị cho filter dropdown. */
    private static final Map<String, String> TABLE_NAME_LABELS = new LinkedHashMap<>();
    static {
        TABLE_NAME_LABELS.put("users", "Người Dùng");
        TABLE_NAME_LABELS.put("roles", "Vai Trò");
        TABLE_NAME_LABELS.put("doctors", "Bác Sĩ");
        TABLE_NAME_LABELS.put("patients", "Bệnh Nhân");
        TABLE_NAME_LABELS.put("services", "Dịch Vụ");
        TABLE_NAME_LABELS.put("medicines", "Thuốc");
        TABLE_NAME_LABELS.put("appointments", "Lịch Hẹn");
        TABLE_NAME_LABELS.put("doctor_schedules", "Lịch Trực");
        TABLE_NAME_LABELS.put("time_slots", "Khung Giờ");
        TABLE_NAME_LABELS.put("medical_records", "Bệnh Án");
        TABLE_NAME_LABELS.put("prescriptions", "Đơn Thuốc");
        TABLE_NAME_LABELS.put("invoices", "Hoá Đơn");
        TABLE_NAME_LABELS.put("notifications", "Thông Báo");
        TABLE_NAME_LABELS.put("reviews", "Đánh Giá");
        TABLE_NAME_LABELS.put("ultrasound_images", "Ảnh Siêu Âm");
        TABLE_NAME_LABELS.put("system_settings", "Cài Đặt");
        TABLE_NAME_LABELS.put("access_control", "Kiểm Soát Truy Cập");
        TABLE_NAME_LABELS.put("security", "Bảo Mật");
        TABLE_NAME_LABELS.put("reports", "Báo Cáo");
        TABLE_NAME_LABELS.put("audit_logs", "Nhật Ký Hệ Thống");
        TABLE_NAME_LABELS.put("test_orders", "Chỉ Định Siêu Âm");
        TABLE_NAME_LABELS.put("ai_analysis_results", "Kết Quả AI");
        TABLE_NAME_LABELS.put("pregnancies", "Thai Kỳ");
        TABLE_NAME_LABELS.put("sonographers", "Bác Sĩ Siêu Âm");
        TABLE_NAME_LABELS.put("prescription_items", "Chi Tiết Đơn Thuốc");
        TABLE_NAME_LABELS.put("invoice_items", "Chi Tiết Hoá Đơn");
        TABLE_NAME_LABELS.put("medicine_categories", "Danh Mục Thuốc");
        TABLE_NAME_LABELS.put("service_categories", "Danh Mục Dịch Vụ");
        TABLE_NAME_LABELS.put("price_history", "Lịch Sử Giá Dịch Vụ");
        TABLE_NAME_LABELS.put("medicine_price_history", "Lịch Sử Giá Thuốc");
        TABLE_NAME_LABELS.put("role_permissions", "Phân Quyền Vai Trò");
        TABLE_NAME_LABELS.put("permissions", "Quyền Hệ Thống");
        TABLE_NAME_LABELS.put("password_reset_tokens", "Token Đặt Lại Mật Khẩu");
    }

    public AuditLogService() {
        this.auditLogDAO = new AuditLogDAO();
    }

    /**
     * Lấy danh sách audit log có phân trang + filter.
     */
    public List<AuditLog> getAuditLogs(int page, int pageSize,
                                        String search, String tableName,
                                        Integer userId, Integer roleId,
                                        LocalDate dateFrom, LocalDate dateTo) {
        int offset = (page - 1) * pageSize;
        try {
            return auditLogDAO.findAll(offset, pageSize, search, tableName, userId, roleId, dateFrom, dateTo);
        } catch (Exception e) {
            System.err.println("[AuditLogService] getAuditLogs ERROR: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Tổng số bản ghi audit log (để tính số trang).
     */
    public int getTotalAuditLogs(String search, String tableName,
                                  Integer userId, Integer roleId,
                                  LocalDate dateFrom, LocalDate dateTo) {
        try {
            return auditLogDAO.countAll(search, tableName, userId, roleId, dateFrom, dateTo);
        } catch (Exception e) {
            System.err.println("[AuditLogService] getTotalAuditLogs ERROR: " + e.getMessage());
            return 0;
        }
    }

    /**
     * Lấy chi tiết một audit log theo id.
     */
    public AuditLog getAuditLogById(int id) {
        try {
            return auditLogDAO.findById(id);
        } catch (Exception e) {
            System.err.println("[AuditLogService] getAuditLogById ERROR: " + e.getMessage());
            return null;
        }
    }

    /**
     * Lấy danh sách các bảng distinct cho filter dropdown.
     * Kèm theo tên tiếng Việt nếu có.
     */
    public Map<String, String> getTableNameOptions() {
        Map<String, String> options = new LinkedHashMap<>();
        List<String> tables = auditLogDAO.getDistinctTables();
        for (String table : tables) {
            String label = TABLE_NAME_LABELS.getOrDefault(table, table);
            options.put(table, label);
        }
        return options;
    }

    /**
     * Lấy danh sách user distinct trong audit log cho filter dropdown.
     */
    public List<AuditLog> getUserOptions() {
        return auditLogDAO.getDistinctUsers();
    }

    /**
     * Lấy danh sách TẤT CẢ vai trò (7 role) từ bảng roles cho filter dropdown "Vai trò".
     * Không phụ thuộc vào audit_logs — luôn hiển thị đủ role ngay cả khi chưa có log.
     */
    public List<AuditLog> getRoleOptions() {
        return auditLogDAO.getAllRoles();
    }

    /**
     * Dọn dẹp audit log cũ — xoá các bản ghi quá hạn.
     *
     * @param retentionDays số ngày giữ lại
     * @return số bản ghi đã xoá
     */
    public int cleanupOldLogs(int retentionDays) {
        if (retentionDays <= 0) return 0;
        return auditLogDAO.deleteOlderThan(retentionDays);
    }

    /**
     * Map table_name → tên tiếng Việt (dùng trong JSP).
     */
    public static String getTableDisplayName(String tableName) {
        if (tableName == null) return "—";
        return TABLE_NAME_LABELS.getOrDefault(tableName, tableName);
    }
}
