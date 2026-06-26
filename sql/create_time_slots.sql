-- ============================================================
-- CREATE TABLE: time_slots — khung giờ khám bệnh 20 phút
-- Tự động sinh từ lịch trực bác sĩ sau khi được Admin/Manager duyệt.
-- Mỗi slot = 20 phút, trạng thái mặc định AVAILABLE.
-- ============================================================

USE [ObstetricsClinicDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.objects
               WHERE object_id = OBJECT_ID('time_slots') AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[time_slots](
        [id]          INT IDENTITY(1,1) NOT NULL,
        [schedule_id] INT NOT NULL,                     -- FK → doctor_schedules.id
        [doctor_id]   INT NOT NULL,                     -- FK → doctors.id (denormalized cho query nhanh)
        [work_date]   DATE NOT NULL,                    -- Ngày khám (denormalized)
        [start_time]  TIME(7) NOT NULL,                 -- Giờ bắt đầu slot (VD: 07:00)
        [end_time]    TIME(7) NOT NULL,                 -- Giờ kết thúc slot (VD: 07:20)
        [status]      NVARCHAR(30) NOT NULL DEFAULT 'AVAILABLE', -- AVAILABLE/BOOKED/COMPLETED/CANCELLED
        [notes]       NVARCHAR(500) NULL,
        [created_at]  DATETIME2 NOT NULL DEFAULT GETDATE(),
        [updated_at]  DATETIME2 NOT NULL DEFAULT GETDATE(),

        CONSTRAINT [PK_time_slots] PRIMARY KEY CLUSTERED ([id] ASC)
    );

    PRINT '>>> [time_slots] table created.';

    -- Index #1: Tra cứu slot trống theo bác sĩ + ngày (dùng cho đặt lịch - Phase 9)
    CREATE NONCLUSTERED INDEX [IX_time_slots_doctor_date]
        ON [dbo].[time_slots] ([doctor_id], [work_date], [start_time])
        INCLUDE ([status], [end_time]);

    PRINT '>>> Index [IX_time_slots_doctor_date] created.';

    -- Index #2: Tìm / xóa slot theo schedule_id
    CREATE NONCLUSTERED INDEX [IX_time_slots_schedule]
        ON [dbo].[time_slots] ([schedule_id]);

    PRINT '>>> Index [IX_time_slots_schedule] created.';

    -- FK: schedule_id → doctor_schedules.id
    ALTER TABLE [dbo].[time_slots] WITH CHECK
        ADD CONSTRAINT [FK_time_slots_schedule]
        FOREIGN KEY ([schedule_id])
        REFERENCES [dbo].[doctor_schedules] ([id]);

    PRINT '>>> FK [FK_time_slots_schedule] added.';

    -- FK: doctor_id → doctors.id
    ALTER TABLE [dbo].[time_slots] WITH CHECK
        ADD CONSTRAINT [FK_time_slots_doctor]
        FOREIGN KEY ([doctor_id])
        REFERENCES [dbo].[doctors] ([id]);

    PRINT '>>> FK [FK_time_slots_doctor] added.';
    PRINT '>>> [time_slots] CREATE COMPLETE.';
END
ELSE
BEGIN
    PRINT '>>> Bảng [time_slots] đã tồn tại, bỏ qua...';
END
GO
