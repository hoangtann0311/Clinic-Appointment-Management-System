-- ═══════════════════════════════════════════════════════════
-- Script chuẩn hóa bảng shifts — chỉ giữ 3 ca chuẩn
-- Database: ObstetricsClinicDB
-- Chạy trong SQL Server Management Studio (SSMS)
-- ═══════════════════════════════════════════════════════════

USE [ObstetricsClinicDB]
GO

PRINT N'>>> Bắt đầu chuẩn hóa bảng shifts...';
GO

-- ═══════════════════════════════════════════════════════════
-- Bước 1: Sửa tên sai (nếu có)
-- ═══════════════════════════════════════════════════════════
UPDATE [dbo].[shifts] SET [name] = N'Ca chiều', [updated_at] = GETDATE()
WHERE [name] IN (N'Ca 2') AND [start_time] = '13:00:00' AND [end_time] = '17:00:00';
GO

-- ═══════════════════════════════════════════════════════════
-- Bước 2: Vô hiệu hóa TẤT CẢ các ca
-- ═══════════════════════════════════════════════════════════
UPDATE [dbo].[shifts] SET [is_active] = 0, [updated_at] = GETDATE();
GO

-- ═══════════════════════════════════════════════════════════
-- Bước 3: Chọn và kích hoạt CHÍNH XÁC 1 ca cho mỗi khung giờ
--         Ưu tiên ca có tên đúng, rồi đến ID cao nhất (mới nhất)
-- ═══════════════════════════════════════════════════════════

DECLARE @morningId INT, @afternoonId INT, @eveningId INT;

-- Tìm ca sáng tốt nhất (07:00-11:00)
SELECT TOP 1 @morningId = [id]
FROM [dbo].[shifts]
WHERE [start_time] = '07:00:00' AND [end_time] = '11:00:00'
ORDER BY CASE WHEN [name] = N'Ca sáng' THEN 0 ELSE 1 END, [id] DESC;

-- Tìm ca chiều tốt nhất (13:00-17:00)
SELECT TOP 1 @afternoonId = [id]
FROM [dbo].[shifts]
WHERE [start_time] = '13:00:00' AND [end_time] = '17:00:00'
ORDER BY CASE WHEN [name] = N'Ca chiều' THEN 0 ELSE 1 END, [id] DESC;

-- Tìm ca tối tốt nhất (19:00-23:00)
SELECT TOP 1 @eveningId = [id]
FROM [dbo].[shifts]
WHERE [start_time] = '19:00:00' AND [end_time] = '23:00:00'
ORDER BY CASE WHEN [name] = N'Ca tối' THEN 0 ELSE 1 END, [id] DESC;

-- Kích hoạt và chuẩn hóa tên + mô tả
IF @morningId IS NOT NULL
    UPDATE [dbo].[shifts]
    SET [is_active] = 1,
        [name] = N'Ca sáng',
        [description] = N'Ca làm việc buổi sáng — 07:00 đến 11:00',
        [updated_at] = GETDATE()
    WHERE [id] = @morningId;

IF @afternoonId IS NOT NULL
    UPDATE [dbo].[shifts]
    SET [is_active] = 1,
        [name] = N'Ca chiều',
        [description] = N'Ca làm việc buổi chiều — 13:00 đến 17:00',
        [updated_at] = GETDATE()
    WHERE [id] = @afternoonId;

IF @eveningId IS NOT NULL
    UPDATE [dbo].[shifts]
    SET [is_active] = 1,
        [name] = N'Ca tối',
        [description] = N'Ca làm việc buổi tối — 19:00 đến 23:00',
        [updated_at] = GETDATE()
    WHERE [id] = @eveningId;
GO

-- ═══════════════════════════════════════════════════════════
-- Bước 4: Nếu thiếu ca nào, tạo mới
-- ═══════════════════════════════════════════════════════════
IF NOT EXISTS (SELECT 1 FROM [dbo].[shifts] WHERE [start_time] = '07:00:00' AND [end_time] = '11:00:00')
BEGIN
    INSERT INTO [dbo].[shifts] ([name], [start_time], [end_time], [description], [is_active], [created_at], [updated_at])
    VALUES (N'Ca sáng', '07:00:00', '11:00:00', N'Ca làm việc buổi sáng — 07:00 đến 11:00', 1, GETDATE(), GETDATE());
    PRINT N'>>> Đã tạo mới: Ca sáng (07:00-11:00)';
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[shifts] WHERE [start_time] = '13:00:00' AND [end_time] = '17:00:00')
BEGIN
    INSERT INTO [dbo].[shifts] ([name], [start_time], [end_time], [description], [is_active], [created_at], [updated_at])
    VALUES (N'Ca chiều', '13:00:00', '17:00:00', N'Ca làm việc buổi chiều — 13:00 đến 17:00', 1, GETDATE(), GETDATE());
    PRINT N'>>> Đã tạo mới: Ca chiều (13:00-17:00)';
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[shifts] WHERE [start_time] = '19:00:00' AND [end_time] = '23:00:00')
BEGIN
    INSERT INTO [dbo].[shifts] ([name], [start_time], [end_time], [description], [is_active], [created_at], [updated_at])
    VALUES (N'Ca tối', '19:00:00', '23:00:00', N'Ca làm việc buổi tối — 19:00 đến 23:00', 1, GETDATE(), GETDATE());
    PRINT N'>>> Đã tạo mới: Ca tối (19:00-23:00)';
END
GO

-- ═══════════════════════════════════════════════════════════
-- Kiểm tra kết quả
-- ═══════════════════════════════════════════════════════════
SELECT
    [id],
    [name]                                 AS [Tên Ca],
    CAST([start_time] AS CHAR(5))          AS [Giờ BĐ],
    CAST([end_time]   AS CHAR(5))          AS [Giờ KT],
    CASE WHEN [is_active] = 1 THEN N'✔️ Hoạt động' ELSE N'❌ Không hoạt động' END AS [Trạng Thái],
    [description]
FROM [dbo].[shifts]
ORDER BY [start_time];
GO

DECLARE @activeCount INT;
SELECT @activeCount = COUNT(*) FROM [dbo].[shifts] WHERE [is_active] = 1;
PRINT N'>>> Số ca đang hoạt động: ' + CAST(@activeCount AS NVARCHAR(10)) + N' (mong đợi: 3)';
GO

PRINT N'========================================';
PRINT N'Chuẩn hóa bảng shifts hoàn tất!';
PRINT N'3 ca chuẩn: Ca sáng (07-11), Ca chiều (13-17), Ca tối (19-23)';
PRINT N'Truy cập: http://localhost:8080/ClinicAppointmentManagementSystem/manager/schedules/';
PRINT N'========================================';
GO
