-- ============================================================
-- ALTER SCRIPT: Thêm các cột còn thiếu cho bảng doctor_schedules
-- Code Java dùng các cột: status, rejection_reason, approved_by,
--   approved_at, created_by, created_at, updated_at, notes
-- Nhưng schema gốc chỉ có: id, doctor_id, work_date, start_time,
--   end_time, is_approved, max_slots
-- ============================================================

USE [ObstetricsClinicDB]
GO

-- 1. Thêm cột status (thay thế BIT is_approved bằng enum rõ ràng)
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'status')
BEGIN
    ALTER TABLE doctor_schedules
    ADD [status] NVARCHAR(30) NOT NULL DEFAULT 'PENDING';

    -- Đồng bộ dữ liệu cũ: nếu is_approved=1 thì status='APPROVED'
    -- Dùng dynamic SQL để tránh lỗi biên dịch (cột status chưa tồn tại lúc compile)
    EXEC sp_executesql N'UPDATE doctor_schedules SET status = ''APPROVED'' WHERE is_approved = 1';

    PRINT '>>> Đã thêm cột [status] vào doctor_schedules';
END
ELSE
    PRINT '>>> Cột [status] đã tồn tại, bỏ qua...';
GO

-- 2. Thêm cột rejection_reason
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'rejection_reason')
BEGIN
    ALTER TABLE doctor_schedules
    ADD [rejection_reason] NVARCHAR(500) NULL;
    PRINT '>>> Đã thêm cột [rejection_reason]';
END
ELSE
    PRINT '>>> Cột [rejection_reason] đã tồn tại, bỏ qua...';
GO

-- 3. Thêm cột approved_by (FK đến users.id)
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'approved_by')
BEGIN
    ALTER TABLE doctor_schedules
    ADD [approved_by] INT NULL;
    PRINT '>>> Đã thêm cột [approved_by]';
END
ELSE
    PRINT '>>> Cột [approved_by] đã tồn tại, bỏ qua...';
GO

-- 4. Thêm cột approved_at
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'approved_at')
BEGIN
    ALTER TABLE doctor_schedules
    ADD [approved_at] DATETIME2 NULL;
    PRINT '>>> Đã thêm cột [approved_at]';
END
ELSE
    PRINT '>>> Cột [approved_at] đã tồn tại, bỏ qua...';
GO

-- 5. Thêm cột created_by
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'created_by')
BEGIN
    ALTER TABLE doctor_schedules
    ADD [created_by] INT NULL;
    PRINT '>>> Đã thêm cột [created_by]';
END
ELSE
    PRINT '>>> Cột [created_by] đã tồn tại, bỏ qua...';
GO

-- 6. Thêm cột created_at
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'created_at')
BEGIN
    ALTER TABLE doctor_schedules
    ADD [created_at] DATETIME2 DEFAULT GETDATE();
    PRINT '>>> Đã thêm cột [created_at]';
END
ELSE
    PRINT '>>> Cột [created_at] đã tồn tại, bỏ qua...';
GO

-- 7. Thêm cột updated_at
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'updated_at')
BEGIN
    ALTER TABLE doctor_schedules
    ADD [updated_at] DATETIME2 DEFAULT GETDATE();
    PRINT '>>> Đã thêm cột [updated_at]';
END
ELSE
    PRINT '>>> Cột [updated_at] đã tồn tại, bỏ qua...';
GO

-- 8. Thêm cột notes
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'notes')
BEGIN
    ALTER TABLE doctor_schedules
    ADD [notes] NVARCHAR(MAX) NULL;
    PRINT '>>> Đã thêm cột [notes]';
END
ELSE
    PRINT '>>> Cột [notes] đã tồn tại, bỏ qua...';
GO

PRINT '========================================';
PRINT 'HOÀN THÀNH: ALTER TABLE doctor_schedules';
PRINT '========================================';
GO
