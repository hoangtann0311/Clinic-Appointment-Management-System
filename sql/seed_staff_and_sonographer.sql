-- ============================================================
-- SEED DATA: Nhân viên lễ tân & Kỹ thuật viên siêu âm mẫu
-- Script tạo tài khoản mẫu cho role Staff (role_id=4)
-- và Sonographer (role_id=6) để Admin/Manager có thể
-- phân công ca trực và quản lý nhân sự.
--
-- YÊU CẦU: ObstetricsClinicDB.sql đã được chạy TRƯỚC!
--          (cần bảng users và roles tồn tại)
-- ============================================================

USE [ObstetricsClinicDB]
GO

-- ============================================================
-- THÔNG TIN CHUNG
-- Mật khẩu mặc định: "123456"
-- BCrypt hash (sinh từ jbcrypt, workload=12):
--   "123456" → $2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS
--
-- Lưu ý: Cột email và phone trong bảng users được mã hóa
-- (varbinary). Script này dùng NULL cho 2 cột đó.
-- Admin có thể cập nhật email/phone qua giao diện quản lý sau.
-- ============================================================


-- ============================================================
-- BƯỚC 1: Seed tài khoản STAFF (role_id = 4 — Nhân viên lễ tân)
-- ============================================================

-- Staff 1: Nguyễn Ngọc Ánh — Lễ tân quầy 1 (tiếp nhận BN + thu ngân)
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'staff.anh')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Nguyễn Ngọc Ánh',
            NULL,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            NULL,
            4, N'Active', 1, N'local', N'staff.anh', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: staff.anh (NV. Nguyễn Ngọc Ánh — Lễ tân quầy 1)';
END
ELSE PRINT '>>> User staff.anh đã tồn tại, bỏ qua...';

-- Staff 2: Trần Thanh Bình — Lễ tân quầy 2 (đặt lịch hẹn + Zalo/điện thoại)
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'staff.binh')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Trần Thanh Bình',
            NULL,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            NULL,
            4, N'Active', 1, N'local', N'staff.binh', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: staff.binh (NV. Trần Thanh Bình — Lễ tân quầy 2)';
END
ELSE PRINT '>>> User staff.binh đã tồn tại, bỏ qua...';

-- Staff 3: Lê Thị Cúc — Lễ tân dự phòng (hỗ trợ giờ cao điểm)
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'staff.cuc')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Lê Thị Cúc',
            NULL,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            NULL,
            4, N'Inactive', 1, N'local', N'staff.cuc', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: staff.cuc (NV. Lê Thị Cúc — Lễ tân dự phòng, Inactive)';
END
ELSE PRINT '>>> User staff.cuc đã tồn tại, bỏ qua...';
GO


-- ============================================================
-- BƯỚC 2: Seed tài khoản SONOGRAPHER (role_id = 6 — KTV siêu âm)
-- ============================================================

-- Sonographer 1: Phạm Thị Linh — KTV siêu âm chính (4D, Doppler, đo NT)
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'sono.linh')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Phạm Thị Linh',
            NULL,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            NULL,
            6, N'Active', 1, N'local', N'sono.linh', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: sono.linh (KTV. Phạm Thị Linh — Siêu âm chính)';
END
ELSE PRINT '>>> User sono.linh đã tồn tại, bỏ qua...';

-- Sonographer 2: Nguyễn Văn Hải — KTV siêu âm phụ (2D thường quy, đầu dò)
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'sono.hai')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Nguyễn Văn Hải',
            NULL,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            NULL,
            6, N'Active', 1, N'local', N'sono.hai', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: sono.hai (KTV. Nguyễn Văn Hải — Siêu âm phụ)';
END
ELSE PRINT '>>> User sono.hai đã tồn tại, bỏ qua...';

-- Sonographer 3: Võ Thị Thanh — KTV siêu âm dự phòng (part-time)
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'sono.thanh')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Võ Thị Thanh',
            NULL,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            NULL,
            6, N'Active', 1, N'local', N'sono.thanh', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: sono.thanh (KTV. Võ Thị Thanh — Siêu âm part-time)';
END
ELSE PRINT '>>> User sono.thanh đã tồn tại, bỏ qua...';
GO


-- ============================================================
-- KIỂM TRA KẾT QUẢ
-- ============================================================
PRINT '========================================';
PRINT 'HOÀN THÀNH: Seed dữ liệu Staff & Sonographer';
PRINT '========================================';
PRINT '';

PRINT '=== DANH SÁCH TÀI KHOẢN VỪA TẠO ===';
SELECT
    u.id,
    u.username,
    u.full_name,
    r.role_name,
    u.status,
    u.is_verified,
    u.auth_provider,
    u.created_at
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.role_id IN (4, 6)          -- Staff + Sonographer
  AND u.auth_provider = 'local'     -- Chỉ lấy account local seed
  AND (u.username LIKE 'staff.%' OR u.username LIKE 'sono.%')
ORDER BY u.role_id, u.username;

PRINT '';
PRINT '=== THỐNG KÊ THEO ROLE ===';
SELECT
    r.role_name,
    COUNT(*) AS total_users,
    SUM(CASE WHEN u.status = 'Active'   THEN 1 ELSE 0 END) AS active,
    SUM(CASE WHEN u.status = 'Inactive' THEN 1 ELSE 0 END) AS inactive
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE r.id IN (4, 6)
GROUP BY r.role_name
ORDER BY r.role_name;

PRINT '';
PRINT '>>> THÔNG TIN ĐĂNG NHẬP:';
PRINT '    Staff:    staff.anh  / 123456  (Lễ tân quầy 1)';
PRINT '    Staff:    staff.binh / 123456  (Lễ tân quầy 2)';
PRINT '    Staff:    staff.cuc  / 123456  (Lễ tân dự phòng, Inactive)';
PRINT '    Sono:     sono.linh  / 123456  (KTV siêu âm chính)';
PRINT '    Sono:     sono.hai   / 123456  (KTV siêu âm phụ)';
PRINT '    Sono:     sono.thanh / 123456  (KTV siêu âm part-time)';
GO
