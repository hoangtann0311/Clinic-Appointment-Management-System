package com.clinic.dao;

import com.clinic.config.DatabaseConfig;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO tổng hợp dữ liệu cho Dashboard Admin.
 * Thực thi các query thống kê trực tiếp trên database.
 *
 * Tuân thủ: PreparedStatement, try-finally, closeResources.
 */
public class DashboardDAO {

    // ──────────────────────────────────────────────
    // 6 KPI CARDS
    // ──────────────────────────────────────────────

    /**
     * Tổng số bệnh nhân (user có role_id = 5).
     */
    public int countPatients() {
        String sql = "SELECT COUNT(*) AS total FROM users WHERE role_id = 5";
        return executeCount(sql);
    }

    /**
     * Số lịch hẹn trong ngày hôm nay.
     */
    public int countAppointmentsToday() {
        String sql = "SELECT COUNT(*) AS total FROM appointments "
                   + "WHERE appointment_date = CAST(GETDATE() AS DATE)";
        return executeCount(sql);
    }

    /**
     * Số bệnh nhân đang chờ khám (trạng thái waiting/confirmed/in_progress hôm nay).
     */
    public int countWaitingPatients() {
        String sql = "SELECT COUNT(*) AS total FROM appointments "
                   + "WHERE appointment_date = CAST(GETDATE() AS DATE) "
                   + "AND status IN ('waiting', 'confirmed', 'in_progress')";
        return executeCount(sql);
    }

    /**
     * Số bác sĩ đang làm việc hôm nay (có lịch được duyệt).
     */
    public int countDoctorsWorkingToday() {
        String sql = "SELECT COUNT(DISTINCT doctor_id) AS total FROM doctor_schedules "
                   + "WHERE work_date = CAST(GETDATE() AS DATE) AND is_approved = 1";
        return executeCount(sql);
    }

    /**
     * Số ca siêu âm trong ngày hôm nay.
     * Lọc appointment có service chứa từ khóa 'siêu âm' hoặc 'ultrasound'.
     */
    public int countUltrasoundToday() {
        String sql = "SELECT COUNT(*) AS total FROM appointments a "
                   + "INNER JOIN services s ON a.service_id = s.id "
                   + "WHERE a.appointment_date = CAST(GETDATE() AS DATE) "
                   + "AND (LOWER(s.service_name) LIKE N'%siêu âm%' "
                   + "     OR LOWER(s.service_name) LIKE '%ultrasound%')";
        return executeCount(sql);
    }

    /**
     * Doanh thu hôm nay (tổng invoice đã thanh toán cho lịch hẹn hôm nay).
     */
    public double sumRevenueToday() {
        String sql = "SELECT ISNULL(SUM(i.total_amount), 0) AS total FROM invoices i "
                   + "INNER JOIN appointments a ON i.appointment_id = a.id "
                   + "WHERE a.appointment_date = CAST(GETDATE() AS DATE) "
                   + "AND UPPER(LTRIM(RTRIM(i.status))) = 'PAID'";
        return executeSum(sql);
    }

    // Range and all-time variants used by the Manager dashboard; queries use existing schema only.
    public int countUsers(LocalDate from, LocalDate to) {
        return executeCount("SELECT COUNT(*) AS total FROM users WHERE created_at >= ? AND created_at < DATEADD(DAY, 1, ?)", from, to);
    }

    public int countDoctors(LocalDate from, LocalDate to) {
        return executeCount("SELECT COUNT(*) AS total FROM users WHERE role_id = 2 AND created_at >= ? AND created_at < DATEADD(DAY, 1, ?)", from, to);
    }

    public int countPatients(LocalDate from, LocalDate to) {
        return executeCount("SELECT COUNT(*) AS total FROM users WHERE role_id = 5 AND created_at >= ? AND created_at < DATEADD(DAY, 1, ?)", from, to);
    }

    public int countAppointmentsAll() {
        return executeCount("SELECT COUNT(*) AS total FROM appointments");
    }

    public int countAppointments(LocalDate from, LocalDate to) {
        return executeCount("SELECT COUNT(*) AS total FROM appointments WHERE appointment_date >= ? AND appointment_date <= ?", from, to);
    }

    public int countWaitingPatientsAll() {
        return executeCount("SELECT COUNT(*) AS total FROM appointments WHERE LOWER(status) IN ('waiting', 'confirmed', 'inprogress')");
    }

    public int countWaitingPatients(LocalDate from, LocalDate to) {
        return executeCount("SELECT COUNT(*) AS total FROM appointments WHERE appointment_date >= ? AND appointment_date <= ? AND LOWER(status) IN ('waiting', 'confirmed', 'inprogress')", from, to);
    }

    public int countDoctorsWorkingAll() {
        return executeCount("SELECT COUNT(DISTINCT doctor_id) AS total FROM doctor_schedules WHERE is_approved = 1");
    }

    public int countDoctorsWorking(LocalDate date) {
        return executeCount("SELECT COUNT(DISTINCT doctor_id) AS total FROM doctor_schedules WHERE work_date = ? AND is_approved = 1", date);
    }

    public int countUltrasoundAll() {
        return executeCount("SELECT COUNT(*) AS total FROM appointments a INNER JOIN services s ON a.service_id = s.id WHERE LOWER(s.service_name) LIKE N'%siêu âm%' OR LOWER(s.service_name) LIKE '%ultrasound%'");
    }

    public int countUltrasound(LocalDate from, LocalDate to) {
        return executeCount("SELECT COUNT(*) AS total FROM appointments a INNER JOIN services s ON a.service_id = s.id WHERE a.appointment_date >= ? AND a.appointment_date <= ? AND (LOWER(s.service_name) LIKE N'%siêu âm%' OR LOWER(s.service_name) LIKE '%ultrasound%')", from, to);
    }

    public double sumRevenueAll() {
        return executeSum("SELECT ISNULL(SUM(total_amount), 0) AS total FROM invoices WHERE UPPER(LTRIM(RTRIM(status))) = 'PAID'");
    }

    public double sumRevenue(LocalDate from, LocalDate to) {
        return executeSum("SELECT ISNULL(SUM(i.total_amount), 0) AS total FROM invoices i INNER JOIN appointments a ON i.appointment_id = a.id WHERE a.appointment_date >= ? AND a.appointment_date <= ? AND UPPER(LTRIM(RTRIM(i.status))) = 'PAID'", from, to);
    }

    /**
     * Tổng doanh thu ngày hôm qua từ tất cả hóa đơn đã thanh toán
     * (bao gồm cả dịch vụ và thuốc).
     */
    public double sumRevenueYesterday() {
        String sql = "SELECT ISNULL(SUM(i.total_amount), 0) AS total FROM invoices i "
                   + "INNER JOIN appointments a ON i.appointment_id = a.id "
                   + "WHERE a.appointment_date = DATEADD(DAY, -1, CAST(GETDATE() AS DATE)) "
                   + "AND UPPER(LTRIM(RTRIM(i.status))) = 'PAID'";
        return executeSum(sql);
    }

    public int countEmergencyToday() {
        return executeCount("SELECT COUNT(*) AS total FROM appointments WHERE appointment_date = CAST(GETDATE() AS DATE) AND ISNULL(is_emergency, 0) = 1");
    }

    public int countEmergencyAll() {
        return executeCount("SELECT COUNT(*) AS total FROM appointments WHERE ISNULL(is_emergency, 0) = 1");
    }

    public int countEmergency(LocalDate from, LocalDate to) {
        return executeCount("SELECT COUNT(*) AS total FROM appointments WHERE appointment_date >= ? AND appointment_date <= ? AND ISNULL(is_emergency, 0) = 1", from, to);
    }

    public int countCancelledToday() {
        return executeCount("SELECT COUNT(*) AS total FROM appointments WHERE appointment_date = CAST(GETDATE() AS DATE) AND LOWER(status) = 'cancelled'");
    }

    public int countCancelledAll() {
        return executeCount("SELECT COUNT(*) AS total FROM appointments WHERE LOWER(status) = 'cancelled'");
    }

    public int countCancelled(LocalDate from, LocalDate to) {
        return executeCount("SELECT COUNT(*) AS total FROM appointments WHERE appointment_date >= ? AND appointment_date <= ? AND LOWER(status) = 'cancelled'", from, to);
    }

    public int countSuccessfulCasesToday() {
        return executeCount("SELECT COUNT(*) AS total FROM appointments a WHERE a.appointment_date = CAST(GETDATE() AS DATE) AND UPPER(LTRIM(RTRIM(a.status))) IN ('COMPLETED', 'SUCCESS')");
    }

    public int countSuccessfulCasesAll() {
        return executeCount("SELECT COUNT(*) AS total FROM appointments a WHERE UPPER(LTRIM(RTRIM(a.status))) IN ('COMPLETED', 'SUCCESS')");
    }

    public int countSuccessfulCases(LocalDate from, LocalDate to) {
        return executeCount("SELECT COUNT(*) AS total FROM appointments a WHERE a.appointment_date >= ? AND a.appointment_date <= ? AND UPPER(LTRIM(RTRIM(a.status))) IN ('COMPLETED', 'SUCCESS')", from, to);
    }

    public Map<String, Integer> getAppointmentsChart(LocalDate from, LocalDate to) {
        Map<String, Integer> result = new LinkedHashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
        for (LocalDate date = from; !date.isAfter(to); date = date.plusDays(1)) {
            result.put(date.format(fmt), 0);
        }

        String sql = "SELECT appointment_date, COUNT(*) AS cnt FROM appointments "
                   + "WHERE appointment_date >= ? AND appointment_date <= ? "
                   + "GROUP BY appointment_date ORDER BY appointment_date";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.sql.Date date = rs.getDate("appointment_date");
                    if (date != null) {
                        result.put(date.toLocalDate().format(fmt), rs.getInt("cnt"));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: getAppointmentsChart failed - " + e.getMessage());
        }
        return result;
    }

    /**
     * Doanh thu theo từng ngày trong khoảng [startDate, endDate] từ invoices.total_amount
     * (bao gồm cả dịch vụ và thuốc).
     * Trả về Map<ngày (dd/MM), doanh thu> — tất cả các ngày trong khoảng đều có entry (zero-fill).
     */
    public Map<String, Double> getDailyRevenue(LocalDate startDate, LocalDate endDate) {
        Map<String, Double> result = new LinkedHashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            result.put(date.format(fmt), 0.0);
        }

        String sql = "SELECT a.appointment_date, ISNULL(SUM(i.total_amount), 0) AS total "
                   + "FROM invoices i "
                   + "INNER JOIN appointments a ON i.appointment_id = a.id "
                   + "WHERE UPPER(LTRIM(RTRIM(i.status))) = 'PAID' "
                   + "AND a.appointment_date >= ? AND a.appointment_date <= ? "
                   + "GROUP BY a.appointment_date "
                   + "ORDER BY a.appointment_date";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(startDate));
            ps.setDate(2, java.sql.Date.valueOf(endDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.sql.Date date = rs.getDate("appointment_date");
                    if (date != null) {
                        result.put(date.toLocalDate().format(fmt), rs.getDouble("total"));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: getDailyRevenue failed - " + e.getMessage());
        }
        return result;
    }

    public Map<String, Double> getRevenueChart(LocalDate endDate) {
        Map<String, Double> result = new LinkedHashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM/yyyy");
        LocalDate startDate = endDate.minusMonths(11).withDayOfMonth(1);
        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusMonths(1)) {
            result.put(date.format(fmt), 0.0);
        }

        String sql = "SELECT YEAR(a.appointment_date) AS yr, MONTH(a.appointment_date) AS mth, "
                   + "ISNULL(SUM(i.total_amount), 0) AS total FROM invoices i "
                   + "INNER JOIN appointments a ON i.appointment_id = a.id "
                   + "WHERE LOWER(i.status) = 'paid' AND a.appointment_date >= ? AND a.appointment_date <= ? "
                   + "GROUP BY YEAR(a.appointment_date), MONTH(a.appointment_date) ORDER BY yr, mth";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(startDate));
            ps.setDate(2, java.sql.Date.valueOf(endDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(String.format("%02d/%d", rs.getInt("mth"), rs.getInt("yr")), rs.getDouble("total"));
                }
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: getRevenueChart failed - " + e.getMessage());
        }
        return result;
    }


    // ──────────────────────────────────────────────
    // CHARTS DATA
    // ──────────────────────────────────────────────

    /**
     * Thống kê số lịch hẹn trong 7 ngày gần nhất.
     * Trả về Map<ngày (dd/MM), số lượng>.
     */
    public Map<String, Integer> getAppointmentsLast7Days() {
        String sql = "SELECT appointment_date, COUNT(*) AS cnt "
                   + "FROM appointments "
                   + "WHERE appointment_date >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) "
                   + "AND appointment_date <= CAST(GETDATE() AS DATE) "
                   + "GROUP BY appointment_date "
                   + "ORDER BY appointment_date";

        Map<String, Integer> result = new LinkedHashMap<>();
        // Khởi tạo 7 ngày với giá trị 0
        LocalDate today = LocalDate.now();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
        for (int i = 6; i >= 0; i--) {
            result.put(today.minusDays(i).format(fmt), 0);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                java.sql.Date date = rs.getDate("appointment_date");
                int count = rs.getInt("cnt");
                if (date != null) {
                    String key = date.toLocalDate().format(fmt);
                    result.put(key, count);
                }
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: Lỗi getAppointmentsLast7Days - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    /**
     * Thống kê doanh thu 12 tháng gần nhất.
     * Trả về Map<tháng (MM/yyyy), tổng doanh thu>.
     */
    public Map<String, Double> getRevenueLast12Months() {
        String sql = "SELECT YEAR(a.appointment_date) AS yr, MONTH(a.appointment_date) AS mth, "
                   + "ISNULL(SUM(i.total_amount), 0) AS total "
                   + "FROM invoices i "
                   + "INNER JOIN appointments a ON i.appointment_id = a.id "
                   + "WHERE i.status = 'paid' "
                   + "AND a.appointment_date >= DATEADD(MONTH, -11, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) "
                   + "GROUP BY YEAR(a.appointment_date), MONTH(a.appointment_date) "
                   + "ORDER BY yr, mth";

        Map<String, Double> result = new LinkedHashMap<>();
        // Khởi tạo 12 tháng với giá trị 0
        LocalDate now = LocalDate.now();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM/yyyy");
        for (int i = 11; i >= 0; i--) {
            result.put(now.minusMonths(i).format(fmt), 0.0);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                int yr = rs.getInt("yr");
                int mth = rs.getInt("mth");
                double total = rs.getDouble("total");
                String key = String.format("%02d/%d", mth, yr);
                result.put(key, total);
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: Lỗi getRevenueLast12Months - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return result;
    }

    // ──────────────────────────────────────────────
    // BẢNG HIỆU SUẤT BÁC SĨ
    // ──────────────────────────────────────────────

    /**
     * DTO cho hiệu suất bác sĩ.
     */
    public static class DoctorPerformance {
        private int doctorId;
        private String doctorName;
        private String specialization;
        private int totalPatients;
        private int appointmentsToday;
        private int completedCases;
        private int cancelledCases;
        private int emergencyCases;
        private int totalAppointments;
        private double revenueGenerated;

        public int getDoctorId() { return doctorId; }
        public void setDoctorId(int doctorId) { this.doctorId = doctorId; }
        public String getDoctorName() { return doctorName; }
        public void setDoctorName(String doctorName) { this.doctorName = doctorName; }
        public String getSpecialization() { return specialization; }
        public void setSpecialization(String specialization) { this.specialization = specialization; }
        public int getTotalPatients() { return totalPatients; }
        public void setTotalPatients(int totalPatients) { this.totalPatients = totalPatients; }
        public int getAppointmentsToday() { return appointmentsToday; }
        public void setAppointmentsToday(int appointmentsToday) { this.appointmentsToday = appointmentsToday; }
        public int getCompletedCases() { return completedCases; }
        public void setCompletedCases(int completedCases) { this.completedCases = completedCases; }
        public int getCancelledCases() { return cancelledCases; }
        public void setCancelledCases(int cancelledCases) { this.cancelledCases = cancelledCases; }
        public int getEmergencyCases() { return emergencyCases; }
        public void setEmergencyCases(int emergencyCases) { this.emergencyCases = emergencyCases; }
        public int getTotalAppointments() { return totalAppointments; }
        public void setTotalAppointments(int totalAppointments) { this.totalAppointments = totalAppointments; }
        public double getCompletionRate() { return totalAppointments == 0 ? 0.0 : completedCases * 100.0 / totalAppointments; }
        public double getRevenueGenerated() { return revenueGenerated; }
        public void setRevenueGenerated(double revenueGenerated) { this.revenueGenerated = revenueGenerated; }
    }

    /**
     * Lấy danh sách hiệu suất bác sĩ (tổng bệnh nhân đã khám + hôm nay + doanh thu).
     */
    public List<DoctorPerformance> getDoctorPerformance() {
        String sql = "SELECT "
                   + "  d.id AS doctor_id, "
                   + "  d.full_name AS doctor_name, "
                   + "  ISNULL(d.specialization, N'Chưa cập nhật') AS specialization, "
                   + "  (SELECT COUNT(*) FROM appointments a2 WHERE a2.doctor_id = d.id AND a2.status = 'completed') AS total_patients, "
                   + "  (SELECT COUNT(*) FROM appointments a3 WHERE a3.doctor_id = d.id "
                   + "     AND a3.appointment_date = CAST(GETDATE() AS DATE)) AS appointments_today, "
                   + "  ISNULL((SELECT SUM(i.total_amount) FROM invoices i "
                   + "     INNER JOIN appointments a4 ON i.appointment_id = a4.id "
                   + "     WHERE a4.doctor_id = d.id AND i.status = 'paid'), 0) AS revenue "
                   + "FROM doctors d "
                   + "ORDER BY total_patients DESC";

        List<DoctorPerformance> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                DoctorPerformance dp = new DoctorPerformance();
                dp.doctorId = rs.getInt("doctor_id");
                dp.doctorName = rs.getString("doctor_name");
                dp.specialization = rs.getString("specialization");
                dp.totalPatients = rs.getInt("total_patients");
                dp.appointmentsToday = rs.getInt("appointments_today");
                dp.revenueGenerated = rs.getDouble("revenue");
                list.add(dp);
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: Lỗi getDoctorPerformance - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }
    public List<DoctorPerformance> getDoctorPerformance(LocalDate from, LocalDate to) {
        String sql = "SELECT d.id AS doctor_id, d.full_name AS doctor_name, "
                   + "ISNULL(d.specialization, N'Chưa cập nhật') AS specialization, "
                   + "(SELECT COUNT(*) FROM appointments a WHERE a.doctor_id = d.id AND a.appointment_date >= ? AND a.appointment_date <= ? AND LOWER(a.status) = 'completed') AS completed_cases, "
                   + "(SELECT COUNT(*) FROM appointments a WHERE a.doctor_id = d.id AND a.appointment_date >= ? AND a.appointment_date <= ? AND LOWER(a.status) = 'cancelled') AS cancelled_cases, "
                   + "(SELECT COUNT(*) FROM appointments a WHERE a.doctor_id = d.id AND a.appointment_date >= ? AND a.appointment_date <= ? AND ISNULL(a.is_emergency, 0) = 1) AS emergency_cases, "
                   + "(SELECT COUNT(*) FROM appointments a WHERE a.doctor_id = d.id AND a.appointment_date >= ? AND a.appointment_date <= ?) AS total_appointments, "
                   + "ISNULL((SELECT SUM(i.total_amount) FROM invoices i INNER JOIN appointments a ON i.appointment_id = a.id "
                   + "WHERE a.doctor_id = d.id AND a.appointment_date >= ? AND a.appointment_date <= ? AND LOWER(i.status) = 'paid'), 0) AS revenue "
                   + "FROM doctors d ORDER BY completed_cases DESC, total_appointments DESC";

        List<DoctorPerformance> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int index = 1; index <= 10; index += 2) {
                ps.setDate(index, java.sql.Date.valueOf(from));
                ps.setDate(index + 1, java.sql.Date.valueOf(to));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DoctorPerformance dp = new DoctorPerformance();
                    dp.doctorId = rs.getInt("doctor_id");
                    dp.doctorName = rs.getString("doctor_name");
                    dp.specialization = rs.getString("specialization");
                    dp.completedCases = rs.getInt("completed_cases");
                    dp.cancelledCases = rs.getInt("cancelled_cases");
                    dp.emergencyCases = rs.getInt("emergency_cases");
                    dp.totalAppointments = rs.getInt("total_appointments");
                    dp.totalPatients = dp.completedCases;
                    dp.appointmentsToday = dp.totalAppointments;
                    dp.revenueGenerated = rs.getDouble("revenue");
                    list.add(dp);
                }
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: getDoctorPerformance(range) failed - " + e.getMessage());
        }
        return list;
    }


    // ──────────────────────────────────────────────
    // LỊCH LÀM VIỆC HÔM NAY
    // ──────────────────────────────────────────────

    /**
     * DTO cho lịch làm việc bác sĩ hôm nay.
     */
    public static class TodaySchedule {
        private int scheduleId;
        private String doctorName;
        private String specialization;
        private String startTime;
        private String endTime;
        private int maxSlots;
        private int bookedSlots;
        private boolean isApproved;

        public int getScheduleId() { return scheduleId; }
        public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }
        public String getDoctorName() { return doctorName; }
        public void setDoctorName(String doctorName) { this.doctorName = doctorName; }
        public String getSpecialization() { return specialization; }
        public void setSpecialization(String specialization) { this.specialization = specialization; }
        public String getStartTime() { return startTime; }
        public void setStartTime(String startTime) { this.startTime = startTime; }
        public String getEndTime() { return endTime; }
        public void setEndTime(String endTime) { this.endTime = endTime; }
        public int getMaxSlots() { return maxSlots; }
        public void setMaxSlots(int maxSlots) { this.maxSlots = maxSlots; }
        public int getBookedSlots() { return bookedSlots; }
        public void setBookedSlots(int bookedSlots) { this.bookedSlots = bookedSlots; }
        public boolean getIsApproved() { return isApproved; }
        public void setIsApproved(boolean isApproved) { this.isApproved = isApproved; }
    }

    /**
     * Lấy lịch làm việc của tất cả bác sĩ trong hôm nay.
     */
    public List<TodaySchedule> getTodaySchedules() {
        String sql = "SELECT "
                   + "  ds.id AS schedule_id, "
                   + "  d.full_name AS doctor_name, "
                   + "  ISNULL(d.specialization, N'Chưa cập nhật') AS specialization, "
                   + "  FORMAT(ds.start_time, 'HH:mm') AS start_time, "
                   + "  FORMAT(ds.end_time, 'HH:mm') AS end_time, "
                   + "  ds.max_slots, "
                   + "  ds.is_approved, "
                   + "  (SELECT COUNT(*) FROM appointments a "
                   + "     WHERE a.doctor_id = ds.doctor_id "
                   + "     AND a.appointment_date = ds.work_date) AS booked_slots "
                   + "FROM doctor_schedules ds "
                   + "INNER JOIN doctors d ON ds.doctor_id = d.id "
                   + "WHERE ds.work_date = CAST(GETDATE() AS DATE) "
                   + "ORDER BY ds.start_time";

        List<TodaySchedule> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                TodaySchedule ts = new TodaySchedule();
                ts.scheduleId = rs.getInt("schedule_id");
                ts.doctorName = rs.getString("doctor_name");
                ts.specialization = rs.getString("specialization");
                ts.startTime = rs.getString("start_time");
                ts.endTime = rs.getString("end_time");
                ts.maxSlots = rs.getInt("max_slots");
                ts.bookedSlots = rs.getInt("booked_slots");
                ts.isApproved = rs.getBoolean("is_approved");
                list.add(ts);
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: Lỗi getTodaySchedules - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }
    public List<TodaySchedule> getSchedules(LocalDate date) {
        String sql = "SELECT ds.id AS schedule_id, d.full_name AS doctor_name, "
                   + "ISNULL(d.specialization, N'Chưa cập nhật') AS specialization, "
                   + "FORMAT(ds.start_time, 'HH:mm') AS start_time, FORMAT(ds.end_time, 'HH:mm') AS end_time, "
                   + "ds.max_slots, ds.is_approved, "
                   + "(SELECT COUNT(*) FROM appointments a WHERE a.doctor_id = ds.doctor_id AND a.appointment_date = ds.work_date) AS booked_slots "
                   + "FROM doctor_schedules ds INNER JOIN doctors d ON ds.doctor_id = d.id "
                   + "WHERE ds.work_date = ? ORDER BY ds.start_time";

        List<TodaySchedule> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TodaySchedule schedule = new TodaySchedule();
                    schedule.scheduleId = rs.getInt("schedule_id");
                    schedule.doctorName = rs.getString("doctor_name");
                    schedule.specialization = rs.getString("specialization");
                    schedule.startTime = rs.getString("start_time");
                    schedule.endTime = rs.getString("end_time");
                    schedule.maxSlots = rs.getInt("max_slots");
                    schedule.bookedSlots = rs.getInt("booked_slots");
                    schedule.isApproved = rs.getBoolean("is_approved");
                    list.add(schedule);
                }
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: getSchedules failed - " + e.getMessage());
        }
        return list;
    }


    // ──────────────────────────────────────────────
    // THỐNG KÊ DỊCH VỤ SIÊU ÂM
    // ──────────────────────────────────────────────

    /**
     * DTO cho thống kê dịch vụ siêu âm.
     */
    public static class UltrasoundStat {
        private String serviceName;
        private int totalCases;
        private int casesToday;
        private double price;

        public String getServiceName() { return serviceName; }
        public void setServiceName(String serviceName) { this.serviceName = serviceName; }
        public int getTotalCases() { return totalCases; }
        public void setTotalCases(int totalCases) { this.totalCases = totalCases; }
        public int getCasesToday() { return casesToday; }
        public void setCasesToday(int casesToday) { this.casesToday = casesToday; }
        public double getPrice() { return price; }
        public void setPrice(double price) { this.price = price; }
    }

    /**
     * Thống kê số ca theo từng dịch vụ siêu âm.
     */
    public List<UltrasoundStat> getUltrasoundStats() {
        String sql = "SELECT "
                   + "  s.id, "
                   + "  s.service_name, "
                   + "  ISNULL(s.price, 0) AS price, "
                   + "  (SELECT COUNT(*) FROM appointments a "
                   + "     WHERE a.service_id = s.id) AS total_cases, "
                   + "  (SELECT COUNT(*) FROM appointments a "
                   + "     WHERE a.service_id = s.id "
                   + "     AND a.appointment_date = CAST(GETDATE() AS DATE)) AS cases_today "
                   + "FROM services s "
                   + "WHERE LOWER(s.service_name) LIKE N'%siêu âm%' "
                   + "   OR LOWER(s.service_name) LIKE '%ultrasound%' "
                   + "ORDER BY total_cases DESC";

        List<UltrasoundStat> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                UltrasoundStat us = new UltrasoundStat();
                us.serviceName = rs.getString("service_name");
                us.totalCases = rs.getInt("total_cases");
                us.casesToday = rs.getInt("cases_today");
                us.price = rs.getDouble("price");
                list.add(us);
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: Lỗi getUltrasoundStats - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }
    public List<UltrasoundStat> getUltrasoundStats(LocalDate from, LocalDate to) {
        String sql = "SELECT s.service_name, ISNULL(s.price, 0) AS price, "
                   + "(SELECT COUNT(*) FROM appointments a WHERE a.service_id = s.id AND a.appointment_date >= ? AND a.appointment_date <= ?) AS total_cases, "
                   + "(SELECT COUNT(*) FROM appointments a WHERE a.service_id = s.id AND a.appointment_date >= ? AND a.appointment_date <= ?) AS cases_today "
                   + "FROM services s WHERE LOWER(s.service_name) LIKE N'%siêu âm%' OR LOWER(s.service_name) LIKE '%ultrasound%' "
                   + "ORDER BY total_cases DESC";

        List<UltrasoundStat> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to));
            ps.setDate(3, java.sql.Date.valueOf(from));
            ps.setDate(4, java.sql.Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UltrasoundStat stat = new UltrasoundStat();
                    stat.serviceName = rs.getString("service_name");
                    stat.totalCases = rs.getInt("total_cases");
                    stat.casesToday = rs.getInt("cases_today");
                    stat.price = rs.getDouble("price");
                    list.add(stat);
                }
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: getUltrasoundStats(range) failed - " + e.getMessage());
        }
        return list;
    }


    // ──────────────────────────────────────────────
    // BỆNH NHÂN MỚI (Patient role, recent)
    // ──────────────────────────────────────────────

    /**
     * DTO cho bệnh nhân mới đăng ký.
     */
    public static class RecentPatient {
        private int id;
        private String fullName;
        private String email;
        private String phone;
        private String createdAt;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        public String getCreatedAt() { return createdAt; }
        public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    }

    /**
     * Lấy danh sách bệnh nhân mới đăng ký gần đây (role_id = 5).
     */
    public List<RecentPatient> getRecentPatients(int limit) {
        String sql = "SELECT TOP (?) id, full_name, email, phone, created_at "
                   + "FROM users WHERE role_id = 5 "
                   + "ORDER BY id DESC";

        List<RecentPatient> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) {
                RecentPatient rp = new RecentPatient();
                rp.id = rs.getInt("id");
                rp.fullName = rs.getString("full_name");
                rp.email = rs.getString("email");
                rp.phone = rs.getString("phone");
                try {
                    java.sql.Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        rp.createdAt = ts.toLocalDateTime()
                                .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
                    }
                } catch (SQLException e) {
                    rp.createdAt = "—";
                }
                list.add(rp);
            }
        } catch (SQLException e) {
            // Fallback: cột created_at có thể chưa tồn tại
            System.err.println("DashboardDAO: Lỗi getRecentPatients - " + e.getMessage());
            return getRecentPatientsFallback(limit);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }
    public List<RecentPatient> getRecentPatients(int limit, LocalDate from, LocalDate to) {
        String sql = "SELECT TOP (?) id, full_name, email, phone, created_at FROM users "
                   + "WHERE role_id = 5 AND created_at >= ? AND created_at < DATEADD(DAY, 1, ?) "
                   + "ORDER BY created_at DESC, id DESC";
        List<RecentPatient> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setDate(2, java.sql.Date.valueOf(from));
            ps.setDate(3, java.sql.Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RecentPatient patient = new RecentPatient();
                    patient.id = rs.getInt("id");
                    patient.fullName = rs.getString("full_name");
                    patient.email = rs.getString("email");
                    patient.phone = rs.getString("phone");
                    java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                    patient.createdAt = createdAt == null ? "—"
                            : createdAt.toLocalDateTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
                    list.add(patient);
                }
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: getRecentPatients(range) failed - " + e.getMessage());
        }
        return list;
    }


    private List<RecentPatient> getRecentPatientsFallback(int limit) {
        String sql = "SELECT TOP (?) id, full_name, email, phone "
                   + "FROM users WHERE role_id = 5 ORDER BY id DESC";
        List<RecentPatient> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) {
                RecentPatient rp = new RecentPatient();
                rp.id = rs.getInt("id");
                rp.fullName = rs.getString("full_name");
                rp.email = rs.getString("email");
                rp.phone = rs.getString("phone");
                rp.createdAt = "—";
                list.add(rp);
            }
        } catch (SQLException e2) {
            System.err.println("DashboardDAO: Fallback getRecentPatients cũng lỗi - " + e2.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    // ──────────────────────────────────────────────
    // NHẬT KÝ HỆ THỐNG (Audit Logs)
    // ──────────────────────────────────────────────

    /**
     * DTO cho audit log hiển thị dashboard.
     */
    public static class AuditLogEntry {
        private int id;
        private String userName;
        private String action;
        private String tableName;
        private String createdAt;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public String getUserName() { return userName; }
        public void setUserName(String userName) { this.userName = userName; }
        public String getAction() { return action; }
        public void setAction(String action) { this.action = action; }
        public String getTableName() { return tableName; }
        public void setTableName(String tableName) { this.tableName = tableName; }
        public String getCreatedAt() { return createdAt; }
        public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    }

    /**
     * Lấy N audit log gần nhất.
     */
    public List<AuditLogEntry> getRecentAuditLogs(int limit) {
        String sql = "SELECT TOP (?) al.id, al.action, al.table_name, al.created_at, "
                   + "ISNULL(u.full_name, 'System') AS user_name "
                   + "FROM audit_logs al "
                   + "LEFT JOIN users u ON al.user_id = u.id "
                   + "ORDER BY al.id DESC";

        List<AuditLogEntry> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) {
                AuditLogEntry entry = new AuditLogEntry();
                entry.id = rs.getInt("id");
                entry.userName = rs.getString("user_name");
                entry.action = rs.getString("action");
                entry.tableName = rs.getString("table_name");
                try {
                    java.sql.Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        entry.createdAt = ts.toLocalDateTime()
                                .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
                    }
                } catch (SQLException e) {
                    entry.createdAt = "—";
                }
                list.add(entry);
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: Lỗi getRecentAuditLogs - " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }
    public List<AuditLogEntry> getRecentAuditLogs(int limit, LocalDate from, LocalDate to) {
        String sql = "SELECT TOP (?) al.id, al.action, al.table_name, al.created_at, "
                   + "ISNULL(u.full_name, 'System') AS user_name "
                   + "FROM audit_logs al LEFT JOIN users u ON al.user_id = u.id "
                   + "WHERE al.created_at >= ? AND al.created_at < DATEADD(DAY, 1, ?) "
                   + "ORDER BY al.created_at DESC, al.id DESC";
        List<AuditLogEntry> list = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setDate(2, java.sql.Date.valueOf(from));
            ps.setDate(3, java.sql.Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLogEntry entry = new AuditLogEntry();
                    entry.id = rs.getInt("id");
                    entry.userName = rs.getString("user_name");
                    entry.action = rs.getString("action");
                    entry.tableName = rs.getString("table_name");
                    java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                    entry.createdAt = createdAt == null ? "—"
                            : createdAt.toLocalDateTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
                    list.add(entry);
                }
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO: getRecentAuditLogs(range) failed - " + e.getMessage());
        }
        return list;
    }


    // ──────────────────────────────────────────────
    // CẢNH BÁO (Alerts)
    // ──────────────────────────────────────────────

    /**
     * DTO cho một cảnh báo.
     */
    public static class Alert {
        private String type;       // warning, danger, info
        private String icon;        // bootstrap icon class
        private String title;
        private String message;
        private int count;

        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getIcon() { return icon; }
        public void setIcon(String icon) { this.icon = icon; }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        public int getCount() { return count; }
        public void setCount(int count) { this.count = count; }
    }

    /**
     * Lấy danh sách cảnh báo hệ thống.
     */
    public List<Alert> getSystemAlerts() {
        List<Alert> alerts = new ArrayList<>();

        // 1. Lịch hẹn chưa xác nhận
        int unconfirmed = executeCount(
            "SELECT COUNT(*) AS total FROM appointments "
            + "WHERE status = 'pending' AND appointment_date = CAST(GETDATE() AS DATE)");
        if (unconfirmed > 0) {
            Alert a = new Alert();
            a.type = "warning";
            a.icon = "bi-exclamation-triangle-fill";
            a.title = "Lịch hẹn chưa xác nhận";
            a.message = "Có " + unconfirmed + " lịch hẹn đang chờ xác nhận trong hôm nay.";
            a.count = unconfirmed;
            alerts.add(a);
        }

        // 2. Hóa đơn chưa thanh toán
        int unpaid = executeCount(
            "SELECT COUNT(*) AS total FROM invoices WHERE status IN ('pending', 'unpaid')");
        if (unpaid > 0) {
            Alert a = new Alert();
            a.type = "danger";
            a.icon = "bi-cash-stack";
            a.title = "Hóa đơn chưa thanh toán";
            a.message = "Có " + unpaid + " hóa đơn chưa được thanh toán.";
            a.count = unpaid;
            alerts.add(a);
        }

        // 3. Tài khoản bị khóa
        int locked = executeCount(
            "SELECT COUNT(*) AS total FROM users WHERE status = 'LOCKED'");
        if (locked > 0) {
            Alert a = new Alert();
            a.type = "danger";
            a.icon = "bi-lock-fill";
            a.title = "Tài khoản bị khóa";
            a.message = "Có " + locked + " tài khoản đang bị khóa, cần xem xét mở khóa.";
            a.count = locked;
            alerts.add(a);
        }

        // 4. Tài khoản chưa xác thực email
        int unverified = executeCount(
            "SELECT COUNT(*) AS total FROM users WHERE is_verified = 0 AND status = 'PENDING_VERIFICATION'");
        if (unverified > 0) {
            Alert a = new Alert();
            a.type = "info";
            a.icon = "bi-envelope-exclamation";
            a.title = "Tài khoản chưa xác thực";
            a.message = "Có " + unverified + " tài khoản đang chờ xác thực email.";
            a.count = unverified;
            alerts.add(a);
        }

        return alerts;
    }
    public List<Alert> getSystemAlerts(LocalDate from, LocalDate to) {
        List<Alert> alerts = new ArrayList<>();

        int pending = executeCount("SELECT COUNT(*) AS total FROM appointments WHERE appointment_date >= ? AND appointment_date <= ? AND LOWER(status) = 'pending'", from, to);
        if (pending > 0) {
            Alert alert = new Alert();
            alert.type = "warning";
            alert.icon = "bi-exclamation-triangle-fill";
            alert.title = "Lịch hẹn chờ xác nhận";
            alert.message = "Có " + pending + " lịch hẹn đang chờ xác nhận trong khoảng đã chọn.";
            alert.count = pending;
            alerts.add(alert);
        }

        int unpaid = executeCount("SELECT COUNT(*) AS total FROM invoices i INNER JOIN appointments a ON i.appointment_id = a.id WHERE a.appointment_date >= ? AND a.appointment_date <= ? AND LOWER(i.status) IN ('pending', 'unpaid')", from, to);
        if (unpaid > 0) {
            Alert alert = new Alert();
            alert.type = "danger";
            alert.icon = "bi-cash-stack";
            alert.title = "Hóa đơn chưa thanh toán";
            alert.message = "Có " + unpaid + " hóa đơn chưa thanh toán trong khoảng đã chọn.";
            alert.count = unpaid;
            alerts.add(alert);
        }

        int emergency = countEmergency(from, to);
        if (emergency > 0) {
            Alert alert = new Alert();
            alert.type = "warning";
            alert.icon = "bi-activity";
            alert.title = "Ca cấp cứu";
            alert.message = "Có " + emergency + " ca được đánh dấu ưu tiên trong khoảng đã chọn.";
            alert.count = emergency;
            alerts.add(alert);
        }
        return alerts;
    }


    // ──────────────────────────────────────────────
    // HELPER METHODS
    // ──────────────────────────────────────────────

    private int executeCount(String sql, LocalDate... dates) {
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int index = 0; index < dates.length; index++) {
                ps.setDate(index + 1, java.sql.Date.valueOf(dates[index]));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("total") : 0;
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO executeCount: " + e.getMessage());
            return 0;
        }
    }

    private double executeSum(String sql, LocalDate... dates) {
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int index = 0; index < dates.length; index++) {
                ps.setDate(index + 1, java.sql.Date.valueOf(dates[index]));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("total") : 0.0;
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO executeSum: " + e.getMessage());
            return 0.0;
        }
    }

    private int executeCount(String sql) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO executeCount: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    private double executeSum(String sql) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble("total");
            }
        } catch (SQLException e) {
            System.err.println("DashboardDAO executeSum: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0.0;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { /* ignore */ }
        }
        if (ps != null) {
            try { ps.close(); } catch (SQLException e) { /* ignore */ }
        }
        DatabaseConfig.closeConnection(conn);
    }
}
