-- ============================================================
-- Migration: Thêm các permission key còn thiếu cho phân quyền
-- ============================================================
-- Vấn đề: AuthorizationFilter whitelist tham chiếu đến các
-- permission key chưa tồn tại trong bảng permissions:
--   - schedule.view    → Manager: Duyệt lịch trực + Khung giờ khám
--   - report.view      → Admin/Manager: Xem báo cáo
--   - ultrasound.upload → Sonographer: Upload ảnh siêu âm
--
-- Yêu cầu: Chạy script này trước khi deploy AuthorizationFilter mới.
-- ============================================================

-- ═══ BƯỚC 1: Thêm permission keys còn thiếu ═══
-- schedule.view (id=38)
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_key = 'schedule.view')
BEGIN
    SET IDENTITY_INSERT permissions ON;
    INSERT INTO permissions (id, permission_key, permission_name, module, description, created_at)
    VALUES (38, N'schedule.view', N'Xem lịch trực & khung giờ', N'schedules',
            N'Xem danh sách lịch trực và khung giờ khám của bác sĩ', GETDATE());
    SET IDENTITY_INSERT permissions OFF;
    PRINT '>>> Đã thêm permission: schedule.view (id=38)';
END
ELSE
    PRINT '>>> schedule.view đã tồn tại, bỏ qua.';

-- schedule.approve (id=39) — cho chức năng Duyệt lịch trực
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_key = 'schedule.approve')
BEGIN
    SET IDENTITY_INSERT permissions ON;
    INSERT INTO permissions (id, permission_key, permission_name, module, description, created_at)
    VALUES (39, N'schedule.approve', N'Duyệt/Từ chối lịch trực', N'schedules',
            N'Phê duyệt hoặc từ chối lịch trực của bác sĩ', GETDATE());
    SET IDENTITY_INSERT permissions OFF;
    PRINT '>>> Đã thêm permission: schedule.approve (id=39)';
END
ELSE
    PRINT '>>> schedule.approve đã tồn tại, bỏ qua.';

-- schedule.create (id=40) — cho chức năng Tạo lịch trực
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_key = 'schedule.create')
BEGIN
    SET IDENTITY_INSERT permissions ON;
    INSERT INTO permissions (id, permission_key, permission_name, module, description, created_at)
    VALUES (40, N'schedule.create', N'Tạo lịch trực', N'schedules',
            N'Tạo lịch trực mới cho bác sĩ', GETDATE());
    SET IDENTITY_INSERT permissions OFF;
    PRINT '>>> Đã thêm permission: schedule.create (id=40)';
END
ELSE
    PRINT '>>> schedule.create đã tồn tại, bỏ qua.';

-- report.view (id=41) — permission tổng cho xem báo cáo
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_key = 'report.view')
BEGIN
    SET IDENTITY_INSERT permissions ON;
    INSERT INTO permissions (id, permission_key, permission_name, module, description, created_at)
    VALUES (41, N'report.view', N'Xem báo cáo tổng hợp', N'reports',
            N'Xem tất cả các loại báo cáo trong hệ thống', GETDATE());
    SET IDENTITY_INSERT permissions OFF;
    PRINT '>>> Đã thêm permission: report.view (id=41)';
END
ELSE
    PRINT '>>> report.view đã tồn tại, bỏ qua.';

-- ultrasound.upload (id=42) — permission tổng cho upload (alias của upload_image)
IF NOT EXISTS (SELECT 1 FROM permissions WHERE permission_key = 'ultrasound.upload')
BEGIN
    SET IDENTITY_INSERT permissions ON;
    INSERT INTO permissions (id, permission_key, permission_name, module, description, created_at)
    VALUES (42, N'ultrasound.upload', N'Tải lên ảnh siêu âm', N'ultrasound',
            N'Tải lên hình ảnh và kết quả siêu âm', GETDATE());
    SET IDENTITY_INSERT permissions OFF;
    PRINT '>>> Đã thêm permission: ultrasound.upload (id=42)';
END
ELSE
    PRINT '>>> ultrasound.upload đã tồn tại, bỏ qua.';

-- ═══ BƯỚC 2: Gán permission mới cho các role ═══

-- Gán schedule.* cho Manager (role_id=3)
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 3 AND permission_id = 38)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (3, 38, GETDATE());
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 3 AND permission_id = 39)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (3, 39, GETDATE());
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 3 AND permission_id = 40)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (3, 40, GETDATE());
PRINT '>>> Manager (role_id=3): đã gán schedule.view + schedule.approve + schedule.create';

-- Gán schedule.* cho Admin (role_id=1) — Admin có tất cả quyền
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 1 AND permission_id = 38)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (1, 38, GETDATE());
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 1 AND permission_id = 39)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (1, 39, GETDATE());
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 1 AND permission_id = 40)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (1, 40, GETDATE());
PRINT '>>> Admin (role_id=1): đã gán schedule.*';

-- Gán schedule.view cho Doctor (role_id=2) — Bác sĩ cần xem lịch của mình
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 2 AND permission_id = 38)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (2, 38, GETDATE());
PRINT '>>> Doctor (role_id=2): đã gán schedule.view';

-- Gán report.view cho Admin và Manager
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 1 AND permission_id = 41)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (1, 41, GETDATE());
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 3 AND permission_id = 41)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (3, 41, GETDATE());
PRINT '>>> Admin + Manager: đã gán report.view';

-- Gán ultrasound.upload cho Admin và Sonographer (role_id=6)
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 1 AND permission_id = 42)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (1, 42, GETDATE());
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = 6 AND permission_id = 42)
    INSERT INTO role_permissions (role_id, permission_id, created_at) VALUES (6, 42, GETDATE());
PRINT '>>> Admin + Sonographer: đã gán ultrasound.upload';

PRINT '';
PRINT '========================================';
PRINT 'MIGRATION HOÀN TẤT';
PRINT '========================================';
PRINT 'Permissions mới:';
PRINT '  38 = schedule.view       → Manager, Admin, Doctor';
PRINT '  39 = schedule.approve    → Manager, Admin';
PRINT '  40 = schedule.create     → Manager, Admin';
PRINT '  41 = report.view         → Manager, Admin';
PRINT '  42 = ultrasound.upload   → Sonographer, Admin';
PRINT '';
PRINT 'Sau khi chạy script, NGƯỜI DÙNG ĐANG ĐĂNG NHẬP';
PRINT 'PHẢI ĐĂNG NHẬP LẠI để load permission mới vào session.';
PRINT 'Hoặc Admin có thể bump permissions version để';
PRINT 'AuthorizationFilter tự động reload.';
PRINT '========================================';
