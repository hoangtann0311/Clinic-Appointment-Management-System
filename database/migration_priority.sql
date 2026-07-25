-- ============================================================================
-- Migration: Add is_priority column and transfer legacy is_emergency data
-- Database: SQL Server (Idempotent execution)
-- ============================================================================

-- 1. Add is_priority column to appointments table if not exists
IF NOT EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[appointments]') 
      AND name = N'is_priority'
)
BEGIN
    ALTER TABLE [dbo].[appointments] ADD [is_priority] BIT NOT NULL DEFAULT 0;
END;
GO

-- 2. Backfill is_priority from legacy is_emergency column if it exists
IF EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[appointments]') 
      AND name = N'is_emergency'
)
BEGIN
    EXEC sp_executesql N'UPDATE [dbo].[appointments] SET [is_priority] = ISNULL([is_emergency], 0) WHERE [is_priority] = 0 AND [is_emergency] IS NOT NULL;';
END;
GO

-- 3. Add permission 'queue.priority' to permissions table if not exists
IF NOT EXISTS (
    SELECT 1 FROM [dbo].[permissions] WHERE [permission_key] = N'queue.priority'
)
BEGIN
    INSERT INTO [dbo].[permissions] ([permission_key], [permission_name], [module], [description], [created_at])
    VALUES (N'queue.priority', N'Đánh dấu / Bỏ ưu tiên tiếp nhận ca khám', N'Reception', N'Quyền kích hoạt và hủy bỏ mức ưu tiên tiếp nhận cho bệnh nhân đang chờ', GETDATE());
END;
GO

-- 4. Assign queue.priority permission to Staff (role_id = 4)
IF EXISTS (SELECT 1 FROM [dbo].[permissions] WHERE [permission_key] = N'queue.priority')
BEGIN
    DECLARE @perm_id INT;
    SELECT @perm_id = [id] FROM [dbo].[permissions] WHERE [permission_key] = N'queue.priority';
    
    IF NOT EXISTS (SELECT 1 FROM [dbo].[role_permissions] WHERE [role_id] = 4 AND [permission_id] = @perm_id)
    BEGIN
        INSERT INTO [dbo].[role_permissions] ([role_id], [permission_id]) VALUES (4, @perm_id);
    END;
END;
GO
