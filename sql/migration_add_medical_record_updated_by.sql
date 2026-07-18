-- ============================================================================
-- Migration: Thêm cột updated_at & updated_by cho bảng medical_records
-- Mục đích: Hỗ trợ Audit Log khi Bác sĩ sửa bệnh án
-- Ngày: 2026-07-17
-- ============================================================================

USE [ObstetricsClinicDB]
GO

-- Kiểm tra và thêm cột updated_at nếu chưa tồn tại
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('medical_records') AND name = 'updated_at'
)
BEGIN
    ALTER TABLE [dbo].[medical_records] ADD [updated_at] DATETIME NULL;
    PRINT '[OK] Đã thêm cột updated_at vào bảng medical_records.';
END
ELSE
BEGIN
    PRINT '[SKIP] Cột updated_at đã tồn tại trong bảng medical_records.';
END
GO

-- Kiểm tra và thêm cột updated_by nếu chưa tồn tại
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('medical_records') AND name = 'updated_by'
)
BEGIN
    ALTER TABLE [dbo].[medical_records] ADD [updated_by] INT NULL;
    PRINT '[OK] Đã thêm cột updated_by vào bảng medical_records.';
END
ELSE
BEGIN
    PRINT '[SKIP] Cột updated_by đã tồn tại trong bảng medical_records.';
END
GO

-- Thêm foreign key constraint nếu chưa tồn tại
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_medical_records_updated_by'
)
BEGIN
    -- Xóa các bản ghi có updated_by không hợp lệ (nếu có) trước khi tạo FK
    -- Trường hợp này chỉ xảy ra nếu có dữ liệu test không chuẩn

    ALTER TABLE [dbo].[medical_records]
    ADD CONSTRAINT [FK_medical_records_updated_by]
    FOREIGN KEY ([updated_by]) REFERENCES [dbo].[users] ([id]);

    PRINT '[OK] Đã thêm khóa ngoại FK_medical_records_updated_by.';
END
ELSE
BEGIN
    PRINT '[SKIP] Khóa ngoại FK_medical_records_updated_by đã tồn tại.';
END
GO

PRINT '========================================';
PRINT 'Migration hoàn tất thành công!';
PRINT '========================================';
GO
