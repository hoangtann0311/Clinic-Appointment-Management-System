-- ============================================================
-- SEED DATA: Bác sĩ & Lịch trực mẫu
-- Script tạo dữ liệu mẫu để Manager có thể xem và thực hành
-- duyệt/từ chối lịch trực bác sĩ.
--
-- YÊU CẦU: Chạy alter_doctor_schedules.sql TRƯỚC script này!
-- ============================================================

USE [ObstetricsClinicDB]
GO

-- ============================================================
-- BƯỚC 1: Tạo User cho các bác sĩ (role_id = 2 = Doctor)
-- Mật khẩu mặc định: "123456"
-- BCrypt hash (sinh từ jbcrypt, workload=12):
--   "123456" → $2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS
-- ============================================================

-- Kiểm tra và chỉ INSERT nếu chưa tồn tại
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'doctor.huong')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Nguyễn Thị Mai Hương',
            0x02000000D0C1F2E3A4B5C6D7E8F9A0B1C2D3E4F5,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            0x02000000A1B2C3D4E5F60718293A4B5C6D7E8F90,
            2, N'Active', 1, N'local', N'doctor.huong', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: doctor.huong (BS. Nguyễn Thị Mai Hương)';
END
ELSE PRINT '>>> User doctor.huong đã tồn tại, bỏ qua...';

IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'doctor.hoang')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Trần Văn Hoàng',
            0x02000000D0C1F2E3A4B5C6D7E8F9A0B1C2D3E4F6,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            0x02000000B2C3D4E5F60718293A4B5C6D7E8F9001,
            2, N'Active', 1, N'local', N'doctor.hoang', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: doctor.hoang (BS. Trần Văn Hoàng)';
END
ELSE PRINT '>>> User doctor.hoang đã tồn tại, bỏ qua...';

IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'doctor.tam')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Lê Thị Thanh Tâm',
            0x02000000D0C1F2E3A4B5C6D7E8F9A0B1C2D3E4F7,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            0x02000000C3D4E5F60718293A4B5C6D7E8F900102,
            2, N'Active', 1, N'local', N'doctor.tam', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: doctor.tam (BS. Lê Thị Thanh Tâm)';
END
ELSE PRINT '>>> User doctor.tam đã tồn tại, bỏ qua...';

IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'doctor.tuan')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Phạm Minh Tuấn',
            0x02000000D0C1F2E3A4B5C6D7E8F9A0B1C2D3E4F8,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            0x02000000D4E5F60718293A4B5C6D7E8F90010203,
            2, N'Active', 1, N'local', N'doctor.tuan', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: doctor.tuan (BS. Phạm Minh Tuấn)';
END
ELSE PRINT '>>> User doctor.tuan đã tồn tại, bỏ qua...';

IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'doctor.anhh')
BEGIN
    INSERT INTO users (full_name, email, password_hash, phone, role_id, status, is_verified, auth_provider, username, is_deleted, created_at, updated_at)
    VALUES (N'Võ Thị Kim Anh',
            0x02000000D0C1F2E3A4B5C6D7E8F9A0B1C2D3E4F9,
            N'$2a$12$Uk17F3P.WgUbMx7CqFF3Geh4gULlaNY3ODghLQ72vdwpBmhBTH3uS',
            0x02000000E5F60718293A4B5C6D7E8F9001020304,
            2, N'Active', 1, N'local', N'doctor.anhh', 0, GETDATE(), GETDATE());
    PRINT '>>> Đã tạo user: doctor.anhh (BS. Võ Thị Kim Anh)';
END
ELSE PRINT '>>> User doctor.anhh đã tồn tại, bỏ qua...';
GO


-- ============================================================
-- BƯỚC 2: Tạo Doctor records (liên kết với users vừa tạo)
-- ============================================================

-- Lấy user_id vừa tạo (theo username) để map vào bảng doctors
DECLARE @userHuong INT = (SELECT id FROM users WHERE username = 'doctor.huong');
DECLARE @userHoang INT = (SELECT id FROM users WHERE username = 'doctor.hoang');
DECLARE @userTam   INT = (SELECT id FROM users WHERE username = 'doctor.tam');
DECLARE @userTuan  INT = (SELECT id FROM users WHERE username = 'doctor.tuan');
DECLARE @userAnh   INT = (SELECT id FROM users WHERE username = 'doctor.anhh');

-- Bác sĩ 1: Nguyễn Thị Mai Hương — Trưởng khoa Sản
IF NOT EXISTS (SELECT 1 FROM doctors WHERE user_id = @userHuong)
    INSERT INTO doctors (user_id, full_name, specialization, phone_number)
    VALUES (@userHuong, N'Nguyễn Thị Mai Hương', N'Sản khoa — Trưởng khoa', '0903-111-001');

-- Bác sĩ 2: Trần Văn Hoàng — Siêu âm thai
IF NOT EXISTS (SELECT 1 FROM doctors WHERE user_id = @userHoang)
    INSERT INTO doctors (user_id, full_name, specialization, phone_number)
    VALUES (@userHoang, N'Trần Văn Hoàng', N'Siêu âm thai — Chẩn đoán hình ảnh', '0903-111-002');

-- Bác sĩ 3: Lê Thị Thanh Tâm — Sản phụ khoa
IF NOT EXISTS (SELECT 1 FROM doctors WHERE user_id = @userTam)
    INSERT INTO doctors (user_id, full_name, specialization, phone_number)
    VALUES (@userTam, N'Lê Thị Thanh Tâm', N'Sản phụ khoa tổng quát', '0903-111-003');

-- Bác sĩ 4: Phạm Minh Tuấn — Hiếm muộn & IVF
IF NOT EXISTS (SELECT 1 FROM doctors WHERE user_id = @userTuan)
    INSERT INTO doctors (user_id, full_name, specialization, phone_number)
    VALUES (@userTuan, N'Phạm Minh Tuấn', N'Hiếm muộn & Hỗ trợ sinh sản (IVF)', '0903-111-004');

-- Bác sĩ 5: Võ Thị Kim Anh — Khám thai tổng quát
IF NOT EXISTS (SELECT 1 FROM doctors WHERE user_id = @userAnh)
    INSERT INTO doctors (user_id, full_name, specialization, phone_number)
    VALUES (@userAnh, N'Võ Thị Kim Anh', N'Khám thai tổng quát & Tư vấn dinh dưỡng', '0903-111-005');

PRINT '>>> Đã tạo 5 bác sĩ trong bảng doctors';
GO


-- ============================================================
-- BƯỚC 3: Tạo lịch trực mẫu (doctor_schedules)
--
-- Các ca trực quy ước:
--   Ca sáng:   07:00 - 12:00  (max_slots = 4)
--   Ca chiều:  13:00 - 17:00  (max_slots = 3)
--   Ca tối:    17:00 - 21:00  (max_slots = 2)
--
-- Ngày tham chiếu: hôm nay = 2026-06-15
-- ============================================================

DECLARE @doctorHuong INT = (SELECT id FROM doctors WHERE phone_number = '0903-111-001');
DECLARE @doctorHoang INT = (SELECT id FROM doctors WHERE phone_number = '0903-111-002');
DECLARE @doctorTam   INT = (SELECT id FROM doctors WHERE phone_number = '0903-111-003');
DECLARE @doctorTuan  INT = (SELECT id FROM doctors WHERE phone_number = '0903-111-004');
DECLARE @doctorAnh   INT = (SELECT id FROM doctors WHERE phone_number = '0903-111-005');

-- Manager user_id = 17 (khangnd) — dùng làm người duyệt
DECLARE @managerId INT = 17;

-- Chỉ INSERT nếu bảng doctor_schedules trống
IF (SELECT COUNT(*) FROM doctor_schedules) = 0
BEGIN

-- ═══════════════════════════════════════════════════════════
-- INSERT theo thứ tự NGÀY TRỰC TĂNG DẦN để ID tăng tự nhiên:
--   14/6 (đã qua) → 15/6 (hôm nay) → 16/6 (ngày mai)
--   → 17/6 → 18/6 → 19/6
-- Trong cùng 1 ngày: Ca sáng → Ca chiều → Ca tối
-- ═══════════════════════════════════════════════════════════

-- ========================================================
-- NGÀY 14/6 (Chủ Nhật — đã qua)
-- ========================================================

-- #1: BS Tâm — Ca sáng — APPROVED (đã duyệt từ 11/6)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, approved_by, approved_at, created_by, created_at, updated_at, notes)
VALUES (@doctorTam, '2026-06-14', '07:00', '12:00', 4, 'APPROVED', 1, @managerId, DATEADD(DAY, -3, GETDATE()), @doctorTam, DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -3, GETDATE()), NULL);

-- #2: BS Anh — Ca chiều — APPROVED (đã duyệt từ 10/6)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, approved_by, approved_at, created_by, created_at, updated_at, notes)
VALUES (@doctorAnh, '2026-06-14', '13:00', '17:00', 3, 'APPROVED', 1, @managerId, DATEADD(DAY, -4, GETDATE()), @doctorAnh, DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -4, GETDATE()), NULL);

-- #3: BS Hoàng — Ca tối — REJECTED (quá slots, đã từ chối 11/6)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, approved_by, approved_at, rejection_reason, created_by, created_at, updated_at, notes)
VALUES (@doctorHoang, '2026-06-14', '17:00', '21:00', 2, 'REJECTED', 0, @managerId, DATEADD(DAY, -3, GETDATE()), N'Ca tối đã đủ 2 bác sĩ (BS. Hương và BS. Anh đã được duyệt trước). Vui lòng chọn ca khác.', @doctorHoang, DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -3, GETDATE()), NULL);


-- ========================================================
-- NGÀY 15/6 (Thứ Hai — hôm nay)
-- ========================================================

-- #4: BS Hương — Ca sáng — APPROVED (đã duyệt hôm qua 14/6)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, approved_by, approved_at, created_by, created_at, updated_at, notes)
VALUES (@doctorHuong, '2026-06-15', '07:00', '12:00', 4, 'APPROVED', 1, @managerId, DATEADD(DAY, -1, GETDATE()), @doctorHuong, DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -1, GETDATE()), NULL);

-- #5: BS Tâm — Ca sáng — REJECTED (trùng lịch họp chuyên môn)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, approved_by, approved_at, rejection_reason, created_by, created_at, updated_at, notes)
VALUES (@doctorTam, '2026-06-15', '07:00', '12:00', 4, 'REJECTED', 0, @managerId, GETDATE(), N'Bác sĩ Tâm đã có lịch họp chuyên môn vào sáng thứ Hai. Vui lòng đăng ký ca chiều hoặc ngày khác.', @doctorTam, DATEADD(DAY, -3, GETDATE()), GETDATE(), NULL);

-- #6: BS Hoàng — Ca chiều — APPROVED (đã duyệt hôm qua 14/6)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, approved_by, approved_at, created_by, created_at, updated_at, notes)
VALUES (@doctorHoang, '2026-06-15', '13:00', '17:00', 3, 'APPROVED', 1, @managerId, DATEADD(DAY, -1, GETDATE()), @doctorHoang, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -1, GETDATE()), N'Đã xác nhận lịch chiều thứ Hai');

-- #7: BS Tuấn — Ca chiều — REJECTED (bảo trì máy siêu âm)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, approved_by, approved_at, rejection_reason, created_by, created_at, updated_at, notes)
VALUES (@doctorTuan, '2026-06-15', '13:00', '17:00', 3, 'REJECTED', 0, @managerId, GETDATE(), N'Phòng khám chiều thứ Hai đang bảo trì máy siêu âm, không thể tiếp nhận bệnh nhân siêu âm. Tạm hoãn lịch bác sĩ Tuấn.', @doctorTuan, DATEADD(DAY, -2, GETDATE()), GETDATE(), NULL);


-- ========================================================
-- NGÀY 16/6 (Thứ Ba — ngày mai)
-- ========================================================

-- #8: BS Hương — Ca sáng — PENDING (chờ duyệt)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, created_by, created_at, updated_at, notes)
VALUES (@doctorHuong, '2026-06-16', '07:00', '12:00', 4, 'PENDING', 0, @doctorHuong, GETDATE(), GETDATE(), N'Đăng ký trực sáng thứ Ba tuần này');

-- #9: BS Hoàng — Ca sáng — PENDING (chờ duyệt)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, created_by, created_at, updated_at, notes)
VALUES (@doctorHoang, '2026-06-16', '07:00', '12:00', 4, 'PENDING', 0, @doctorHoang, GETDATE(), GETDATE(), NULL);

-- #10: BS Tuấn — Ca sáng — APPROVED (duyệt từ tuần trước, lịch cố định thứ Ba)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, approved_by, approved_at, created_by, created_at, updated_at, notes)
VALUES (@doctorTuan, '2026-06-16', '07:00', '12:00', 4, 'APPROVED', 1, @managerId, DATEADD(DAY, -2, GETDATE()), @doctorTuan, DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -2, GETDATE()), N'Duyệt từ tuần trước, lịch cố định thứ Ba hàng tuần');

-- #11: BS Tâm — Ca chiều — PENDING (chờ duyệt)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, created_by, created_at, updated_at, notes)
VALUES (@doctorTam, '2026-06-16', '13:00', '17:00', 3, 'PENDING', 0, @doctorTam, GETDATE(), GETDATE(), N'Có thể về sớm 30 phút nếu hết bệnh nhân');


-- ========================================================
-- NGÀY 17/6 (Thứ Tư)
-- ========================================================

-- #12: BS Tuấn — Ca sáng — PENDING (chờ duyệt)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, created_by, created_at, updated_at, notes)
VALUES (@doctorTuan, '2026-06-17', '07:00', '12:00', 4, 'PENDING', 0, @doctorTuan, GETDATE(), GETDATE(), NULL);

-- #13: BS Anh — Ca tối — PENDING (chờ duyệt, có ca đặc biệt)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, created_by, created_at, updated_at, notes)
VALUES (@doctorAnh, '2026-06-17', '17:00', '21:00', 2, 'PENDING', 0, @doctorAnh, GETDATE(), GETDATE(), N'Đăng ký trực tối, phòng khám có ca đặc biệt');


-- ========================================================
-- NGÀY 18/6 (Thứ Năm)
-- ========================================================

-- #14: BS Hoàng — Ca chiều — PENDING (chờ duyệt)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, created_by, created_at, updated_at, notes)
VALUES (@doctorHoang, '2026-06-18', '13:00', '17:00', 3, 'PENDING', 0, @doctorHoang, GETDATE(), GETDATE(), NULL);


-- ========================================================
-- NGÀY 19/6 (Thứ Sáu)
-- ========================================================

-- #15: BS Hương — Ca sáng — PENDING (chờ duyệt)
INSERT INTO doctor_schedules (doctor_id, work_date, start_time, end_time, max_slots, status, is_approved, created_by, created_at, updated_at, notes)
VALUES (@doctorHuong, '2026-06-19', '07:00', '12:00', 4, 'PENDING', 0, @doctorHuong, GETDATE(), GETDATE(), N'Tuần sau đăng ký lịch đều đặn');

    PRINT '>>> Đã tạo 15 lịch trực mẫu (7 PENDING + 5 APPROVED + 3 REJECTED)';
END
ELSE
    PRINT '>>> Bảng doctor_schedules đã có dữ liệu, bỏ qua seed...';
GO


-- ============================================================
-- KIỂM TRA KẾT QUẢ
-- ============================================================
PRINT '========================================';
PRINT 'HOÀN THÀNH: Seed dữ liệu bác sĩ & lịch trực';
PRINT '========================================';
PRINT '';

PRINT '=== DANH SÁCH BÁC SĨ ===';
SELECT id, full_name, specialization, phone_number FROM doctors;

PRINT '';
PRINT '=== DANH SÁCH LỊCH TRỰC ===';
SELECT ds.id, d.full_name AS doctor_name, ds.work_date,
       CONCAT(ds.start_time, ' - ', ds.end_time) AS shift,
       ds.status, ds.max_slots,
       CASE WHEN ds.rejection_reason IS NOT NULL
            THEN LEFT(ds.rejection_reason, 60) + '...'
            ELSE NULL END AS rejection_reason_short
FROM doctor_schedules ds
JOIN doctors d ON ds.doctor_id = d.id
ORDER BY ds.work_date, ds.start_time;

PRINT '';
PRINT '=== THỐNG KÊ ===';
SELECT
    SUM(CASE WHEN status = 'PENDING'  THEN 1 ELSE 0 END) AS pending,
    SUM(CASE WHEN status = 'APPROVED' THEN 1 ELSE 0 END) AS approved,
    SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END) AS rejected,
    COUNT(*) AS total
FROM doctor_schedules;

PRINT '';
PRINT '>>> ĐĂNG NHẬP VỚI VAI TRÒ MANAGER ĐỂ XEM:';
PRINT '    URL:  http://localhost:8080/ClinicAppointmentManagementSystem/manager/schedules/';
PRINT '    User: khangnd / Mật khẩu của Manager';
GO
