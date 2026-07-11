-- ============================================================
-- Migration: Thêm cột created_at vào bảng users
-- Mục đích:   Lưu thời điểm tạo tài khoản để hiển thị
--             trong admin/users/ (cột "Ngày Tạo")
-- Ngày:       2026-07-02
-- ============================================================

USE [ObstetricsClinicDB]
GO

SET NOCOUNT ON;
GO

PRINT '=== Bắt đầu migration: Thêm cột created_at vào bảng users ===';

-- Bước 1: Kiểm tra cột đã tồn tại chưa
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('users')
      AND name = 'created_at'
)
BEGIN
    PRINT '>>> Bước 1: Thêm cột created_at DATETIME2 (cho phép NULL tạm thời)...';

    ALTER TABLE [dbo].[users]
    ADD [created_at] [datetime2](7) NULL;

    PRINT '>>> Đã thêm cột created_at.';
END
ELSE
BEGIN
    PRINT '>>> Cột created_at đã tồn tại, bỏ qua bước thêm cột.';
END
GO

-- Bước 2: Backfill dữ liệu cho các user hiện có
-- Ưu tiên dùng updated_at (nếu có), nếu không thì dùng
-- ngày mặc định 2026-06-07 (ngày sớm nhất có audit log)
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('users')
      AND name = 'created_at'
)
BEGIN
    PRINT '>>> Bước 2: Backfill created_at cho các user hiện có...';

    -- Cập nhật created_at từ updated_at nếu có,
    -- nếu updated_at cũng NULL thì dùng ngày mặc định
    UPDATE [dbo].[users]
    SET [created_at] = ISNULL([updated_at], CAST('2026-06-07' AS DATETIME2))
    WHERE [created_at] IS NULL;

    DECLARE @updatedCount INT = @@ROWCOUNT;
    PRINT '>>> Đã backfill ' + CAST(@updatedCount AS VARCHAR) + ' user(s).';
END
GO

-- Bước 3: Thêm DEFAULT constraint để tự động set GETDATE() cho user mới
-- (phòng hờ trường hợp code Java quên set — constraint này là safety net)
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('users')
      AND name = 'created_at'
)
AND NOT EXISTS (
    SELECT 1 FROM sys.default_constraints
    WHERE parent_object_id = OBJECT_ID('users')
      AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('users'), 'created_at', 'ColumnId')
)
BEGIN
    PRINT '>>> Bước 3: Thêm DEFAULT constraint GETDATE() cho created_at...';

    ALTER TABLE [dbo].[users]
    ADD CONSTRAINT [DF_users_created_at] DEFAULT GETDATE() FOR [created_at];

    PRINT '>>> Đã thêm DEFAULT constraint.';
END
ELSE
BEGIN
    PRINT '>>> DEFAULT constraint đã tồn tại hoặc cột chưa có, bỏ qua.';
END
GO

-- Bước 4: Kiểm tra kết quả
PRINT '=== Kiểm tra kết quả ===';
SELECT
    [id],
    [full_name],
    [username],
    [status],
    [created_at],
    [updated_at]
FROM [dbo].[users]
ORDER BY [id];

PRINT '=== Migration hoàn tất ===';
GO
