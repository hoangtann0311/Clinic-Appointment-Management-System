package com.clinic.service;

import com.clinic.dao.DoctorDAO;
import com.clinic.dao.UserDAO;
import com.clinic.model.Doctor;
import com.clinic.model.User;
import com.clinic.model.enums.UserStatus;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import com.clinic.config.DatabaseConfig;

/**
 * Service xử lý nghiệp vụ quản lý người dùng cho Admin.
 * Bao gồm: CRUD tài khoản nhân viên, soft delete, validate.
 */
public class UserService {

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    /** Lấy danh sách user có phân trang + filter (roleIds = NULL → tất cả role) */
    public List<User> getUsers(int page, int pageSize,
                               String search, java.util.List<Integer> roleIds, String statusFilter,
                               boolean includeDeleted) {
        int offset = (page - 1) * pageSize;
        try {
            return userDAO.findAll(offset, pageSize, search, roleIds, statusFilter, includeDeleted);
        } catch (Exception e) {
            System.err.println("[UserService] getUsers ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            return Collections.emptyList();
        }
    }

    /** Tổng số user (để tính số trang) */
    public int getTotalUsers(String search, java.util.List<Integer> roleIds, String statusFilter, boolean includeDeleted) {
        try {
            return userDAO.countAll(search, roleIds, statusFilter, includeDeleted);
        } catch (Exception e) {
            System.err.println("[UserService] getTotalUsers ERROR: " + e.getMessage());
            e.printStackTrace(System.err);
            return 0;
        }
    }

    public Map<Integer, Integer> countUsersByRole(String search, String statusFilter, boolean includeDeleted) {
        try {
            return userDAO.countGroupedByRole(search, statusFilter, includeDeleted);
        } catch (Exception e) {
            System.err.println("[UserService] countUsersByRole ERROR: " + e.getMessage());
            return Collections.emptyMap();
        }
    }

    /** Cập nhật trạng thái user */
    public boolean updateStatus(int userId, String newStatus) {
        return userDAO.updateStatus(userId, newStatus);
    }

    /** Xóa user (hard delete — giữ lại cho tương thích ngược) */
    public boolean deleteUser(int userId) {
        return userDAO.delete(userId);
    }

    /** Soft delete user — vô hiệu hóa tài khoản, giữ nguyên dữ liệu liên quan */
    public boolean softDeleteUser(int userId) {
        return userDAO.softDelete(userId);
    }

    /**
     * Tạo user mới (admin side).
     * Username được tự động sinh từ phần trước @ của email,
     * nhất quán với luồng đăng ký public (AuthService.register).
     * Nếu username trùng, thêm hậu tố số (VD: ten.ten → ten.ten1).
     */
    public boolean createUser(String fullName, String email,
                              String password, String phone, int roleId, String status,
                              Map<String, String> errors) {
        // ── Validate họ tên (chuẩn tiếng Việt, giống các trang web phòng khám) ──
        if (fullName == null || fullName.trim().isEmpty()) {
            errors.put("fullName", "Vui lòng nhập họ và tên.");
            return false;
        }
        String trimmedName = fullName.trim();
        // Kiểm tra độ dài tối thiểu
        if (trimmedName.length() < 6) {
            errors.put("fullName", "Họ và tên phải có ít nhất 6 ký tự (bao gồm họ và tên).");
            return false;
        }
        // Kiểm tra độ dài tối đa
        if (trimmedName.length() > 100) {
            errors.put("fullName", "Họ và tên không được vượt quá 100 ký tự.");
            return false;
        }
        // Chỉ cho phép chữ cái tiếng Việt và khoảng trắng
        if (!trimmedName.matches("^[a-zA-Zàáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ"
                + "ÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ"
                + "\\s]+$")) {
            errors.put("fullName", "Họ và tên chỉ được chứa chữ cái và khoảng trắng, không được chứa số hoặc ký tự đặc biệt.");
            return false;
        }
        // Phải có ít nhất 2 từ (họ + tên), mỗi từ ít nhất 2 ký tự
        String[] words = trimmedName.split("\\s+");
        if (words.length < 2) {
            errors.put("fullName", "Vui lòng nhập đầy đủ họ và tên (ít nhất 2 từ).");
            return false;
        }
        for (String word : words) {
            if (word.length() < 1) {
                errors.put("fullName", "Vui lòng nhập đầy đủ họ và tên, không để trống từ nào.");
                return false;
            }
        }
        // Không được có nhiều khoảng trắng liên tiếp (đã xử lý bởi split ở trên, kiểm tra double space)
        if (trimmedName.contains("  ")) {
            errors.put("fullName", "Họ và tên không được chứa nhiều khoảng trắng liên tiếp.");
            return false;
        }
        if (email == null || !email.matches("^[-A-Za-z0-9+_.]+@[-A-Za-z0-9.]+\\.[A-Za-z]{2,}$")) {
            errors.put("email", "Email không hợp lệ.");
            return false;
        }
        if (password == null || password.length() < 6) {
            errors.put("password", "Mật khẩu ít nhất 6 ký tự.");
            return false;
        }
        // ── Validate số điện thoại ──
        String trimmedPhone = (phone != null) ? phone.trim() : "";
        if (trimmedPhone.isEmpty()) {
            errors.put("phone", "Vui lòng nhập số điện thoại.");
            return false;
        }
        if (!trimmedPhone.matches("^0(?:3|5|7|8|9)[0-9]{8}$")) {
            errors.put("phone", "Số điện thoại không hợp lệ (10 chữ số, bắt đầu 03, 05, 07, 08 hoặc 09).");
            return false;
        }

        String trimmedEmail = email.trim().toLowerCase();

        // Kiểm tra email trùng
        if (userDAO.findByEmail(trimmedEmail) != null) {
            errors.put("email", "Email đã tồn tại.");
            return false;
        }

        // Kiểm tra số điện thoại trùng
        if (userDAO.findByPhone(trimmedPhone) != null) {
            errors.put("phone", "Số điện thoại này đã được sử dụng bởi người dùng khác.");
            return false;
        }

        // ── Validate roleId: chỉ nhận 6 vai trò còn trong phạm vi hệ thống ──
        if (!isSupportedRoleId(roleId)) {
            errors.put("roleId", "Vai trò được chọn không hợp lệ (ID=" + roleId + "). Vui lòng chọn vai trò khác.");
            return false;
        }
        if (roleId == ROLE_DOCTOR) {
            errors.put("roleId", "Tài khoản Bác sĩ phải được tạo kèm hồ sơ chuyên môn.");
            return false;
        }

        // Tự động sinh username từ email (phần trước @) — nhất quán với AuthService
        String baseUsername = trimmedEmail.substring(0, trimmedEmail.indexOf('@'));
        // Dọn dẹu username: chỉ giữ chữ cái, số, gạch dưới, dấu chấm
        baseUsername = baseUsername.replaceAll("[^a-zA-Z0-9_.]", "");
        // Đảm bảo username có ít nhất 4 ký tự
        while (baseUsername.length() < 4) {
            baseUsername += "0";
        }
        String generatedUsername = baseUsername;
        int suffix = 1;
        while (userDAO.findByUsername(generatedUsername.toLowerCase()) != null) {
            generatedUsername = baseUsername + suffix;
            suffix++;
        }

        User u = new User();
        u.setFullName(trimmedName);
        u.setEmail(trimmedEmail);
        u.setUsername(generatedUsername.toLowerCase());
        u.setPasswordHash(com.clinic.utils.BCryptUtil.hashPassword(password));
        u.setPhone(trimmedPhone);
        u.setRoleId(roleId);
        u.setStatus(status != null ? status : UserStatus.ACTIVE.getValue());
        u.setVerified(true);          // admin tạo = auto verified
        u.setAuthProvider("local");

        System.out.println("[UserService] createUser: fullName=" + trimmedName
                + ", email=" + trimmedEmail + ", roleId=" + roleId
                + ", status=" + u.getStatus());

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            int newId = userDAO.insert(conn, u);
            System.out.println("[UserService] createUser SUCCESS: id=" + newId
                    + ", username=" + generatedUsername + ", roleId=" + roleId);

            // ── Tự động tạo record cho Patient nếu tạo từ luồng chung ──
            if (roleId == ROLE_PATIENT) {
                insertPatient(conn, newId, trimmedName, trimmedPhone);
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) { }
            }
            System.err.println("[UserService] createUser FAILED: " + e.getMessage());
            errors.put("general", "Không thể tạo đầy đủ tài khoản và hồ sơ vai trò.");
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) { }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════
    // ROLE-SPECIFIC TABLE INSERT
    // ═══════════════════════════════════════════════════════════

    /** Role ID hằng số — đồng bộ với seed data roles */
    private static final int ROLE_DOCTOR  = 2;
    private static final int ROLE_PATIENT = 5;
    private static final int MAX_SUPPORTED_ROLE_ID = 6;

    /** The Laboratory Technician role was removed from the product scope. */
    private static boolean isSupportedRoleId(int roleId) {
        return roleId >= 1 && roleId <= MAX_SUPPORTED_ROLE_ID;
    }

    /**
     * Tạo tài khoản Bác sĩ trong cùng 1 Database Transaction (users + doctors).
     * Đảm bảo không tồn tại Bác sĩ mồ côi (users.role_id = 2 nhưng không có doctors record).
     */
    public boolean createDoctorAccount(String fullName, String email, String password, String phone,
                                      String specialization, String degree, int experienceYears,
                                      String status, Map<String, String> errors) {
        if (specialization == null || specialization.trim().isEmpty()) {
            errors.put("specialization", "Vui lòng nhập chuyên khoa cho Bác sĩ.");
            return false;
        }
        if (experienceYears < 0) {
            errors.put("experienceYears", "Số năm kinh nghiệm không được là số âm.");
            return false;
        }

        String trimmedName = (fullName != null) ? fullName.trim() : "";
        if (trimmedName.length() < 6 || trimmedName.length() > 100) {
            errors.put("fullName", "Họ và tên Bác sĩ phải từ 6 đến 100 ký tự.");
            return false;
        }

        String trimmedEmail = (email != null) ? email.trim().toLowerCase() : "";
        if (!trimmedEmail.matches("^[-A-Za-z0-9+_.]+@[-A-Za-z0-9.]+\\.[A-Za-z]{2,}$")) {
            errors.put("email", "Email không hợp lệ.");
            return false;
        }
        if (userDAO.findByEmail(trimmedEmail) != null) {
            errors.put("email", "Email đã tồn tại.");
            return false;
        }

        String trimmedPhone = (phone != null) ? phone.trim() : "";
        if (!trimmedPhone.isEmpty() && !trimmedPhone.matches("^0(?:3|5|7|8|9)[0-9]{8}$")) {
            errors.put("phone", "Số điện thoại không hợp lệ (10 chữ số, bắt đầu 03|05|07|08|09).");
            return false;
        }
        if (!trimmedPhone.isEmpty() && userDAO.findByPhone(trimmedPhone) != null) {
            errors.put("phone", "Số điện thoại này đã được sử dụng.");
            return false;
        }

        if (password == null || password.length() < 6) {
            errors.put("password", "Mật khẩu phải từ 6 ký tự trở lên.");
            return false;
        }

        String baseUsername = trimmedEmail.substring(0, trimmedEmail.indexOf('@')).replaceAll("[^a-zA-Z0-9_.]", "");
        while (baseUsername.length() < 4) baseUsername += "0";
        String generatedUsername = baseUsername;
        int suffix = 1;
        while (userDAO.findByUsername(generatedUsername.toLowerCase()) != null) {
            generatedUsername = baseUsername + suffix;
            suffix++;
        }

        User u = new User();
        u.setFullName(trimmedName);
        u.setEmail(trimmedEmail);
        u.setUsername(generatedUsername.toLowerCase());
        u.setPasswordHash(com.clinic.utils.BCryptUtil.hashPassword(password));
        u.setPhone(trimmedPhone);
        u.setRoleId(ROLE_DOCTOR);
        u.setStatus(status != null ? status : "Active");
        u.setVerified(true);
        u.setAuthProvider("local");

        String trimmedSpec = specialization.trim();
        String trimmedDegree = (degree != null && !degree.isBlank()) ? degree.trim() : "Bác sĩ";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            int newUserId = userDAO.insert(conn, u);

            Doctor doctor = new Doctor();
            doctor.setUserId(newUserId);
            doctor.setFullName(trimmedName);
            doctor.setPhoneNumber(trimmedPhone);
            doctor.setSpecialization(trimmedSpec);
            doctor.setDegree(trimmedDegree);
            doctor.setExperienceYears(experienceYears);

            DoctorDAO doctorDAO = new DoctorDAO();
            int newDoctorId = doctorDAO.insert(conn, doctor);
            if (newDoctorId <= 0) {
                throw new SQLException("Không thể khởi tạo hồ sơ Bác sĩ trong bảng doctors.");
            }

            conn.commit();
            System.out.println("[UserService] createDoctorAccount TRANSACTION SUCCESS: userId=" + newUserId + ", doctorId=" + newDoctorId);
            return true;

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            System.err.println("[UserService] createDoctorAccount TRANSACTION ROLLBACK: " + e.getMessage());
            errors.put("general", "Lỗi tạo tài khoản Bác sĩ: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }

    /**
     * Đổi vai trò tài khoản từ Staff/Manager sang Bác sĩ trong cùng 1 Database Transaction.
     */
    public boolean changeUserRoleToDoctor(int userId, String specialization, String degree, int experienceYears,
                                         String status, Map<String, String> errors) {
        if (specialization == null || specialization.trim().isEmpty()) {
            errors.put("specialization", "Vui lòng nhập chuyên khoa khi chuyển tài khoản sang vai trò Bác sĩ.");
            return false;
        }
        if (experienceYears < 0) {
            errors.put("experienceYears", "Số năm kinh nghiệm không được là số âm.");
            return false;
        }

        User existingUser = userDAO.findById(userId);
        if (existingUser == null) {
            errors.put("general", "Không tìm thấy người dùng.");
            return false;
        }

        String trimmedSpec = specialization.trim();
        String trimmedDegree = (degree != null && !degree.isBlank()) ? degree.trim() : "Bác sĩ";
        DoctorDAO doctorDAO = new DoctorDAO();
        Doctor existingDoc = doctorDAO.findByUserId(userId);

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            boolean okUser = userDAO.updateRoleAndStatus(conn, userId, ROLE_DOCTOR, status);
            if (!okUser) {
                throw new SQLException("Cập nhật vai trò user thất bại.");
            }

            Doctor docData = new Doctor();
            docData.setUserId(userId);
            docData.setFullName(existingUser.getFullName());
            docData.setPhoneNumber(existingUser.getPhone());
            docData.setSpecialization(trimmedSpec);
            docData.setDegree(trimmedDegree);
            docData.setExperienceYears(experienceYears);

            if (existingDoc != null) {
                boolean okDoc = doctorDAO.updateProfile(conn, docData);
                if (!okDoc) {
                    throw new SQLException("Cập nhật hồ sơ Bác sĩ thất bại.");
                }
            } else {
                int doctorId = doctorDAO.insert(conn, docData);
                if (doctorId <= 0) {
                    throw new SQLException("Không khởi tạo được hồ sơ Bác sĩ.");
                }
            }

            conn.commit();
            System.out.println("[UserService] changeUserRoleToDoctor TRANSACTION SUCCESS for userId=" + userId);
            return true;

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            System.err.println("[UserService] changeUserRoleToDoctor ROLLBACK for userId=" + userId + ": " + e.getMessage());
            errors.put("general", "Không thể chuyển đổi vai trò Bác sĩ: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }

    /**
     * Chuyển Bác sĩ sang vai trò khác (Staff/Manager), kiểm tra và chặn nếu Bác sĩ còn công việc chưa hoàn tất.
     * Sử dụng 1 Database Transaction chung và xử lý lỗi SQL an toàn khi kiểm tra lịch làm việc.
     */
    public boolean changeDoctorRoleToOther(int userId, int newRoleId, String status, Map<String, String> errors) {
        DoctorDAO doctorDAO = new DoctorDAO();
        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            // 1. Tìm Doctor profile bằng cùng Connection transaction
            Doctor doctor;
            try {
                doctor = doctorDAO.findByUserId(conn, userId);
            } catch (SQLException e) {
                conn.rollback();
                errors.put("roleId", "Không thể kiểm tra lịch làm việc của Bác sĩ. Vui lòng thử lại.");
                return false;
            }

            // 2. Kiểm tra công việc/lịch khám chưa hoàn tất
            if (doctor != null) {
                try {
                    if (doctorDAO.hasActiveWorkOrAppointments(conn, doctor.getId())) {
                        errors.put("roleId", "Bác sĩ này còn lịch khám (Chờ xác nhận/Đã xác nhận/Chờ khám/Đang khám) hoặc lịch làm việc tương lai chưa hoàn tất. Không thể chuyển vai trò!");
                        conn.rollback();
                        return false;
                    }
                } catch (SQLException e) {
                    conn.rollback();
                    errors.put("roleId", "Không thể kiểm tra lịch làm việc của Bác sĩ. Vui lòng thử lại.");
                    return false;
                }
            }

            // 3. Cập nhật role_id trong bảng users
            boolean okUser = userDAO.updateRoleAndStatus(conn, userId, newRoleId, status);
            if (!okUser) {
                conn.rollback();
                errors.put("roleId", "Không thể cập nhật vai trò người dùng. Vui lòng thử lại.");
                return false;
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { }
            }
            errors.put("roleId", "Không thể cập nhật vai trò người dùng. Vui lòng thử lại.");
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { }
            }
        }
    }

    /**
     * Thêm bệnh nhân vào bảng patients.
     * Dùng SQL trực tiếp vì chưa có PatientDAO riêng.
     */
    private void insertPatient(Connection conn, int userId, String fullName, String phone)
            throws SQLException {
        String sql = "INSERT INTO patients (user_id, full_name, phone_number) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, fullName);
            ps.setString(3, phone);
            if (ps.executeUpdate() != 1) {
                throw new SQLException("Không tạo được patient profile.");
            }
        }
    }

    /**
     * Cập nhật user (admin side — không đổi password và username).
     * Username được tự sinh lúc tạo, không thay đổi về sau để đảm bảo nhất quán.
     */
    public boolean updateUser(int userId, String fullName,
                              String email, String phone, int roleId, String status,
                              Map<String, String> errors) {
        // ── Validate họ tên (chuẩn tiếng Việt) ──
        if (fullName == null || fullName.trim().isEmpty()) {
            errors.put("fullName", "Vui lòng nhập họ và tên.");
            return false;
        }
        String trimmedName = fullName.trim();
        if (trimmedName.length() < 6) {
            errors.put("fullName", "Họ và tên phải có ít nhất 6 ký tự (bao gồm họ và tên).");
            return false;
        }
        if (trimmedName.length() > 100) {
            errors.put("fullName", "Họ và tên không được vượt quá 100 ký tự.");
            return false;
        }
        if (!trimmedName.matches("^[a-zA-Zàáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ"
                + "ÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ"
                + "\\s]+$")) {
            errors.put("fullName", "Họ và tên chỉ được chứa chữ cái và khoảng trắng, không được chứa số hoặc ký tự đặc biệt.");
            return false;
        }
        String[] words = trimmedName.split("\\s+");
        if (words.length < 2) {
            errors.put("fullName", "Vui lòng nhập đầy đủ họ và tên (ít nhất 2 từ).");
            return false;
        }
        for (String word : words) {
            if (word.length() < 1) {
                errors.put("fullName", "Vui lòng nhập đầy đủ họ và tên, không để trống từ nào.");
                return false;
            }
        }
        if (trimmedName.contains("  ")) {
            errors.put("fullName", "Họ và tên không được chứa nhiều khoảng trắng liên tiếp.");
            return false;
        }

        // Load user hiện tại từ DB
        User u = userDAO.findById(userId);
        if (u == null) {
            errors.put("general", "User không tồn tại hoặc đã bị xóa.");
            return false;
        }

        // ── Validate email ──
        String newEmail = (email != null) ? email.trim().toLowerCase() : "";
        if (newEmail.isEmpty()) {
            errors.put("email", "Vui lòng nhập email.");
            return false;
        }
        if (!newEmail.matches("^[-A-Za-z0-9+_.]+@[-A-Za-z0-9.]+\\.[A-Za-z]{2,}$")) {
            errors.put("email", "Email không hợp lệ.");
            return false;
        }
        // Kiểm tra email trùng (ngoại trừ chính nó)
        User emailOwner = userDAO.findByEmail(newEmail);
        if (emailOwner != null && emailOwner.getId() != userId) {
            errors.put("email", "Email đã được sử dụng bởi người dùng khác.");
            return false;
        }
        // Cảnh báo nếu user Google bị đổi email (Google ID vẫn giữ nguyên)
        boolean emailChanged = (u.getEmail() == null) || !newEmail.equals(u.getEmail().toLowerCase());
        if (emailChanged && "google".equalsIgnoreCase(u.getAuthProvider())) {
            System.out.println("[UserService] WARNING: Thay đổi email của Google user #"
                    + userId + " từ " + u.getEmail() + " sang " + newEmail);
        }

        // ── Validate số điện thoại (nếu có nhập) ──
        String trimmedPhone = (phone != null) ? phone.trim() : "";
        if (!trimmedPhone.isEmpty()) {
            if (!trimmedPhone.matches("^0(?:3|5|7|8|9)[0-9]{8}$")) {
                errors.put("phone", "Số điện thoại không hợp lệ (10 chữ số, bắt đầu 03|05|07|08|09).");
                return false;
            }
            // Kiểm tra số điện thoại trùng (ngoại trừ chính nó)
            User phoneOwner = userDAO.findByPhone(trimmedPhone);
            if (phoneOwner != null && phoneOwner.getId() != userId) {
                errors.put("phone", "Số điện thoại này đã được sử dụng bởi người dùng khác.");
                return false;
            }
        }

        u.setFullName(trimmedName);
        u.setEmail(newEmail);
        // Username giữ nguyên — không cho phép chỉnh sửa để nhất quán với luồng tạo
        u.setPhone(trimmedPhone);
        u.setRoleId(roleId);
        u.setStatus(status);
        if (!userDAO.update(u)) {
            errors.put("general", "Cập nhật thất bại — có thể có lỗi cơ sở dữ liệu. Vui lòng thử lại.");
            return false;
        }
        return true;
    }

    /**
     * Cập nhật role, status, email, phone cho user (admin edit — phân quyền + thông tin liên hệ).
     * fullName không được phép sửa từ admin panel.
     */
    public boolean updateUserRoleAndStatus(int userId, int roleId, String status,
                                            String email, String phone,
                                            Map<String, String> errors) {
        // Validate roleId: Laboratory Technician (7) is no longer supported.
        if (!isSupportedRoleId(roleId)) {
            errors.put("roleId", "Vai trò được chọn không hợp lệ.");
            return false;
        }

        // Validate status
        if (status == null || status.trim().isEmpty()) {
            errors.put("status", "Vui lòng chọn trạng thái.");
            return false;
        }
        String trimmedStatus = status.trim();
        if (!trimmedStatus.equals("Active") && !trimmedStatus.equals("Inactive")
                && !trimmedStatus.equals("Locked") && !trimmedStatus.equals("Pending Verification")) {
            errors.put("status", "Trạng thái không hợp lệ.");
            return false;
        }

        // Validate email
        String trimmedEmail = (email != null) ? email.trim().toLowerCase() : "";
        if (trimmedEmail.isEmpty()) {
            errors.put("email", "Vui lòng nhập email.");
            return false;
        }
        if (!trimmedEmail.matches("^[-A-Za-z0-9+_.]+@[-A-Za-z0-9.]+\\.[A-Za-z]{2,}$")) {
            errors.put("email", "Email không hợp lệ.");
            return false;
        }

        // Validate số điện thoại (có thể để trống)
        String trimmedPhone = (phone != null) ? phone.trim() : "";
        if (!trimmedPhone.isEmpty()) {
            if (!trimmedPhone.matches("^0(?:3|5|7|8|9)[0-9]{8}$")) {
                errors.put("phone", "Số điện thoại không hợp lệ (10 chữ số, bắt đầu 03|05|07|08|09).");
                return false;
            }
        }

        // Kiểm tra user tồn tại
        User u = userDAO.findById(userId);
        if (u == null) {
            errors.put("general", "Người dùng không tồn tại hoặc đã bị xóa.");
            return false;
        }

        // A role change can orphan a patient/doctor profile and historical clinical
        // records. Create a new account instead; the existing one may be locked.
        if (u.getRoleId() != roleId) {
            errors.put("roleId", "Không thể đổi trực tiếp vai trò của tài khoản đang tồn tại. Hãy khóa tài khoản cũ và tạo tài khoản mới đúng vai trò để bảo toàn hồ sơ nghiệp vụ.");
            return false;
        }

        // Kiểm tra email trùng (ngoại trừ chính nó)
        User emailOwner = userDAO.findByEmail(trimmedEmail);
        if (emailOwner != null && emailOwner.getId() != userId) {
            errors.put("email", "Email đã được sử dụng bởi người dùng khác.");
            return false;
        }

        // Kiểm tra số điện thoại trùng (ngoại trừ chính nó, nếu có nhập)
        if (!trimmedPhone.isEmpty()) {
            User phoneOwner = userDAO.findByPhone(trimmedPhone);
            if (phoneOwner != null && phoneOwner.getId() != userId) {
                errors.put("phone", "Số điện thoại này đã được sử dụng bởi người dùng khác.");
                return false;
            }
        }

        if (!userDAO.updateRoleStatusAndContact(userId, roleId, trimmedStatus, trimmedEmail, trimmedPhone)) {
            errors.put("general", "Cập nhật thất bại — có thể có lỗi cơ sở dữ liệu. Vui lòng thử lại.");
            return false;
        }
        return true;
    }

    /** Reset mật khẩu cho user (admin side) */
    public boolean resetPassword(int userId, String newPassword, Map<String, String> errors) {
        if (newPassword == null || newPassword.length() < 6) {
            errors.put("password", "Mật khẩu ít nhất 6 ký tự.");
            return false;
        }
        return userDAO.updatePassword(userId,
                com.clinic.utils.BCryptUtil.hashPassword(newPassword));
    }

    /** Lấy user theo id */
    public User getUserById(int userId) {
        return userDAO.findById(userId);
    }

    /** Tìm user theo username */
    public User getUserByUsername(String username) {
        return userDAO.findByUsername(username);
    }
}
