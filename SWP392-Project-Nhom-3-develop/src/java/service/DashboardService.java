package com.clinic.service;

import com.clinic.dao.UserDAO;
import com.clinic.model.User;

import java.util.Collections;
import java.util.List;

/**
 * Service tổng hợp dữ liệu cho Dashboard Admin.
 * Gọi các DAO để lấy thống kê và danh sách hiển thị.
 *
 * Tuân thủ kiến trúc: Controller → Service → DAO → Database
 */
public class DashboardService {

    private final UserDAO userDAO;

    public DashboardService() {
        this.userDAO = new UserDAO();
    }

    /**
     * Lấy tổng số người dùng trong hệ thống.
     * @return tổng số user, 0 nếu lỗi
     */
    public int getTotalUsers() {
        try {
            int total = userDAO.getTotalUsers();
            return Math.max(total, 0); // Trả về 0 nếu DB lỗi (-1)
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi lấy tổng users - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Lấy tổng số bác sĩ (user có role_id = 2).
     * @return tổng số bác sĩ, 0 nếu lỗi
     */
    public int getTotalDoctors() {
        try {
            int total = userDAO.getTotalDoctors();
            return Math.max(total, 0);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi lấy tổng bác sĩ - " + e.getMessage());
            return 0;
        }
    }

    /**
     * Lấy số lịch hẹn trong ngày hôm nay.
     * TODO: Tích hợp AppointmentDAO khi được tạo (Phase 9).
     * @return số lịch hẹn hôm nay (hiện tại trả về 0)
     */
    public int getTotalAppointmentsToday() {
        // TODO Phase 9: Gọi appointmentDAO.countByDate(LocalDate.now())
        return 0;
    }

    /**
     * Lấy tổng doanh thu tháng hiện tại.
     * TODO: Tích hợp InvoiceDAO khi được tạo (Phase 10).
     * @return tổng doanh thu tháng dạng VND (hiện tại trả về "0 VND")
     */
    public String getMonthlyRevenue() {
        // TODO Phase 10: Gọi invoiceDAO.sumByMonth(YearMonth.now())
        return "0 VND";
    }

    /**
     * Lấy danh sách N người dùng mới nhất (có kèm tên vai trò).
     * @param limit số lượng tối đa
     * @return danh sách User, rỗng nếu lỗi hoặc không có dữ liệu
     */
    public List<User> getRecentUsers(int limit) {
        try {
            return userDAO.getRecentUsers(limit);
        } catch (Exception e) {
            System.err.println("DashboardService: Lỗi lấy recent users - " + e.getMessage());
            return Collections.emptyList();
        }
    }
}
