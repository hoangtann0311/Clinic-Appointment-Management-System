-- ============================================================
-- ALTER SCRIPT: Thêm các cột hỗ trợ concurrency & booking
--                cho bảng time_slots và doctor_schedules
--
-- Mục đích:
--   1. Optimistic locking (ROWVERSION) — ngăn 2 transaction
--      cùng sửa 1 dòng dẫn đến mất dữ liệu.
--   2. booked_by / booked_at — truy vết ai đặt slot, khi nào.
--   3. version trên doctor_schedules — ngăn 2 Manager cùng
--      duyệt 1 lịch trực.
-- ============================================================

USE [ObstetricsClinicDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT '========================================';
PRINT 'ALTER: Thêm cột concurrency cho time_slots';
PRINT '========================================';

-- ── 1. time_slots: booked_by (ai đặt slot này) ──
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('time_slots') AND name = 'booked_by')
BEGIN
    ALTER TABLE [dbo].[time_slots]
    ADD [booked_by] INT NULL;
    PRINT '>>> Đã thêm cột [booked_by] vào time_slots';
END
ELSE
    PRINT '>>> Cột [booked_by] đã tồn tại, bỏ qua...';
GO

-- ── 2. time_slots: booked_at (thời điểm đặt) ──
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('time_slots') AND name = 'booked_at')
BEGIN
    ALTER TABLE [dbo].[time_slots]
    ADD [booked_at] DATETIME2 NULL;
    PRINT '>>> Đã thêm cột [booked_at] vào time_slots';
END
ELSE
    PRINT '>>> Cột [booked_at] đã tồn tại, bỏ qua...';
GO

-- ── 3. time_slots: version (ROWVERSION — optimistic lock) ──
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('time_slots') AND name = 'version')
BEGIN
    ALTER TABLE [dbo].[time_slots]
    ADD [version] ROWVERSION;
    PRINT '>>> Đã thêm cột [version] (ROWVERSION) vào time_slots';
END
ELSE
    PRINT '>>> Cột [version] đã tồn tại, bỏ qua...';
GO

-- ── 4. Index hỗ trợ đặt lịch: tìm slot trống nhanh ──
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_time_slots_booking' AND object_id = OBJECT_ID('time_slots'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_time_slots_booking]
        ON [dbo].[time_slots] ([doctor_id], [work_date], [status], [start_time])
        INCLUDE ([end_time], [schedule_id], [booked_by]);
    PRINT '>>> Index [IX_time_slots_booking] created.';
END
ELSE
    PRINT '>>> Index [IX_time_slots_booking] đã tồn tại, bỏ qua...';
GO

PRINT '========================================';
PRINT 'ALTER: Thêm cột version cho doctor_schedules';
PRINT '========================================';

-- ── 5. doctor_schedules: version (ROWVERSION — optimistic lock) ──
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'version')
BEGIN
    ALTER TABLE [dbo].[doctor_schedules]
    ADD [version] ROWVERSION;
    PRINT '>>> Đã thêm cột [version] (ROWVERSION) vào doctor_schedules';
END
ELSE
    PRINT '>>> Cột [version] đã tồn tại, bỏ qua...';
GO

-- ── 6. doctor_schedules: cancelled_by (ai hủy lịch trực) ──
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'cancelled_by')
BEGIN
    ALTER TABLE [dbo].[doctor_schedules]
    ADD [cancelled_by] INT NULL;
    PRINT '>>> Đã thêm cột [cancelled_by] vào doctor_schedules';
END
ELSE
    PRINT '>>> Cột [cancelled_by] đã tồn tại, bỏ qua...';
GO

-- ── 7. doctor_schedules: cancelled_at ──
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'cancelled_at')
BEGIN
    ALTER TABLE [dbo].[doctor_schedules]
    ADD [cancelled_at] DATETIME2 NULL;
    PRINT '>>> Đã thêm cột [cancelled_at] vào doctor_schedules';
END
ELSE
    PRINT '>>> Cột [cancelled_at] đã tồn tại, bỏ qua...';
GO

-- ── 8. doctor_schedules: cancellation_reason ──
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('doctor_schedules') AND name = 'cancellation_reason')
BEGIN
    ALTER TABLE [dbo].[doctor_schedules]
    ADD [cancellation_reason] NVARCHAR(500) NULL;
    PRINT '>>> Đã thêm cột [cancellation_reason] vào doctor_schedules';
END
ELSE
    PRINT '>>> Cột [cancellation_reason] đã tồn tại, bỏ qua...';
GO

-- ── 9. FK: time_slots.booked_by → users.id ──
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys
               WHERE name = 'FK_time_slots_booked_by' AND parent_object_id = OBJECT_ID('time_slots'))
BEGIN
    ALTER TABLE [dbo].[time_slots] WITH CHECK
        ADD CONSTRAINT [FK_time_slots_booked_by]
        FOREIGN KEY ([booked_by])
        REFERENCES [dbo].[users] ([id]);
    PRINT '>>> FK [FK_time_slots_booked_by] added.';
END
ELSE
    PRINT '>>> FK [FK_time_slots_booked_by] đã tồn tại, bỏ qua...';
GO

PRINT '========================================';
PRINT 'HOÀN THÀNH: ALTER concurrency columns';
PRINT '========================================';
GO

-- ============================================================
-- STORED PROCEDURE: Đặt slot nguyên tử (atomic booking)
-- Dùng UPDLOCK để đảm bảo chỉ 1 patient được đặt 1 slot.
-- Trả về: 0 = thành công, 1 = slot không tồn tại,
--          2 = slot đã bị đặt, 3 = lỗi khác
-- ============================================================
IF EXISTS (SELECT 1 FROM sys.objects
           WHERE object_id = OBJECT_ID('usp_BookTimeSlot') AND type = 'P')
    DROP PROCEDURE [dbo].[usp_BookTimeSlot];
GO

CREATE PROCEDURE [dbo].[usp_BookTimeSlot]
    @slot_id    INT,
    @patient_id INT,
    @result_code INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Rollback toàn bộ nếu có lỗi runtime

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Lock dòng ngay khi đọc để ngăn 2 patient đặt cùng slot
        DECLARE @current_status NVARCHAR(30);

        SELECT @current_status = [status]
        FROM [dbo].[time_slots] WITH (UPDLOCK, ROWLOCK, HOLDLOCK)
        WHERE [id] = @slot_id;

        IF @current_status IS NULL
        BEGIN
            SET @result_code = 1; -- Slot không tồn tại
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @current_status != 'AVAILABLE'
        BEGIN
            SET @result_code = 2; -- Slot đã được đặt hoặc không khả dụng
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Cập nhật slot → BOOKED
        UPDATE [dbo].[time_slots]
        SET [status]    = 'BOOKED',
            [booked_by] = @patient_id,
            [booked_at] = GETDATE(),
            [updated_at] = GETDATE()
        WHERE [id] = @slot_id
          AND [status] = 'AVAILABLE'; -- Double-check lần cuối

        COMMIT TRANSACTION;
        SET @result_code = 0; -- Thành công
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @result_code = 3; -- Lỗi hệ thống
        -- Có thể log lỗi vào bảng audit ở đây
    END CATCH
END
GO

PRINT '>>> Stored Procedure [usp_BookTimeSlot] created.';

-- ============================================================
-- STORED PROCEDURE: Hủy slot (cancellation) — chỉ slot BOOKED
-- ============================================================
IF EXISTS (SELECT 1 FROM sys.objects
           WHERE object_id = OBJECT_ID('usp_CancelTimeSlot') AND type = 'P')
    DROP PROCEDURE [dbo].[usp_CancelTimeSlot];
GO

CREATE PROCEDURE [dbo].[usp_CancelTimeSlot]
    @slot_id     INT,
    @cancelled_by INT,         -- patient_id hoặc system user
    @reason      NVARCHAR(500),
    @result_code INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @current_status NVARCHAR(30);

        SELECT @current_status = [status]
        FROM [dbo].[time_slots] WITH (UPDLOCK, ROWLOCK, HOLDLOCK)
        WHERE [id] = @slot_id;

        IF @current_status IS NULL
        BEGIN
            SET @result_code = 1; -- Không tồn tại
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @current_status != 'BOOKED'
        BEGIN
            SET @result_code = 2; -- Không phải trạng thái BOOKED
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Giải phóng slot → AVAILABLE
        UPDATE [dbo].[time_slots]
        SET [status]     = 'CANCELLED',
            [notes]      = ISNULL(@reason, N'Bệnh nhân hủy lịch'),
            [booked_by]  = NULL,
            [booked_at]  = NULL,
            [updated_at] = GETDATE()
        WHERE [id] = @slot_id
          AND [status] = 'BOOKED';

        COMMIT TRANSACTION;
        SET @result_code = 0; -- Thành công
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @result_code = 3;
    END CATCH
END
GO

PRINT '>>> Stored Procedure [usp_CancelTimeSlot] created.';

-- ============================================================
-- STORED PROCEDURE: Duyệt lịch trực với optimistic locking
-- Trả về: 0 = thành công, 1 = không tồn tại, 2 = không PENDING,
--          3 = conflict (đã bị duyệt bởi người khác)
-- ============================================================
IF EXISTS (SELECT 1 FROM sys.objects
           WHERE object_id = OBJECT_ID('usp_ApproveSchedule') AND type = 'P')
    DROP PROCEDURE [dbo].[usp_ApproveSchedule];
GO

CREATE PROCEDURE [dbo].[usp_ApproveSchedule]
    @schedule_id INT,
    @approved_by INT,
    @result_code INT OUTPUT,
    @slot_count  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- optimistic lock: chỉ UPDATE nếu status vẫn là PENDING
        UPDATE [dbo].[doctor_schedules]
        SET [status]      = 'APPROVED',
            [is_approved] = 1,
            [approved_by] = @approved_by,
            [approved_at] = GETDATE(),
            [updated_at]  = GETDATE()
        WHERE [id] = @schedule_id
          AND [status] = 'PENDING';

        IF @@ROWCOUNT = 0
        BEGIN
            -- Kiểm tra xem schedule có tồn tại không
            IF EXISTS (SELECT 1 FROM [dbo].[doctor_schedules] WHERE [id] = @schedule_id)
            BEGIN
                SET @result_code = 2; -- Đã bị xử lý (không còn PENDING)
            END
            ELSE
            BEGIN
                SET @result_code = 1; -- Không tồn tại
            END
            SET @slot_count = 0;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Lấy thông tin schedule để sinh slots
        DECLARE @doctor_id INT, @work_date DATE,
                @start_time TIME(7), @end_time TIME(7);

        SELECT @doctor_id  = [doctor_id],
               @work_date  = [work_date],
               @start_time = [start_time],
               @end_time   = [end_time]
        FROM [dbo].[doctor_schedules]
        WHERE [id] = @schedule_id;

        -- Sinh time slots (20 phút/slot)
        DECLARE @total_minutes INT, @slot_count_local INT, @i INT;
        DECLARE @current_minutes INT, @slot_start TIME(7), @slot_end TIME(7);

        SET @total_minutes = DATEDIFF(MINUTE, @start_time, @end_time);
        SET @slot_count_local = @total_minutes / 20;
        SET @i = 0;

        WHILE @i < @slot_count_local
        BEGIN
            SET @slot_start = DATEADD(MINUTE, @i * 20, @start_time);
            SET @slot_end   = DATEADD(MINUTE, (@i + 1) * 20, @start_time);

            INSERT INTO [dbo].[time_slots]
                ([schedule_id], [doctor_id], [work_date],
                 [start_time], [end_time], [status],
                 [created_at], [updated_at])
            VALUES
                (@schedule_id, @doctor_id, @work_date,
                 @slot_start, @slot_end, 'AVAILABLE',
                 GETDATE(), GETDATE());

            SET @i = @i + 1;
        END

        COMMIT TRANSACTION;
        SET @result_code = 0; -- Thành công
        SET @slot_count  = @slot_count_local;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @result_code = 3; -- Lỗi hệ thống
        SET @slot_count  = 0;
    END CATCH
END
GO

PRINT '>>> Stored Procedure [usp_ApproveSchedule] created.';
PRINT '========================================';
PRINT 'HOÀN THÀNH TẤT CẢ ALTER SCRIPTS';
PRINT '========================================';
GO
