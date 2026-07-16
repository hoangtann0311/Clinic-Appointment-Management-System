-- ============================================================
-- TẠO BẢNG time_slots + SINH SLOT CHO LỊCH ĐÃ APPROVED
-- Chạy trong database: ObstetricsClinicDB2
-- ============================================================

USE [ObstetricsClinicDB2]
GO

-- ── 1. Tạo bảng time_slots nếu chưa có ──────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[time_slots]') AND type = 'U'
)
BEGIN
    CREATE TABLE [dbo].[time_slots] (
        [id]          INT IDENTITY(1,1)   NOT NULL,
        [schedule_id] INT                 NOT NULL,   -- FK -> doctor_schedules.id
        [doctor_id]   INT                 NOT NULL,   -- FK -> doctors.id
        [work_date]   DATE                NOT NULL,
        [start_time]  TIME(0)             NOT NULL,
        [end_time]    TIME(0)             NOT NULL,
        [status]      NVARCHAR(20)        NOT NULL DEFAULT 'AVAILABLE',
                                                   -- AVAILABLE | BOOKED | CANCELLED
        [notes]       NVARCHAR(500)       NULL,
        [booked_by]   INT                 NULL,   -- FK -> users.id
        [booked_at]   DATETIME            NULL,
        [version]     ROWVERSION          NOT NULL,   -- optimistic locking
        [created_at]  DATETIME            NOT NULL DEFAULT GETDATE(),
        [updated_at]  DATETIME            NOT NULL DEFAULT GETDATE(),

        CONSTRAINT [PK_time_slots] PRIMARY KEY CLUSTERED ([id] ASC),
        CONSTRAINT [FK_time_slots_schedule]
            FOREIGN KEY ([schedule_id]) REFERENCES [dbo].[doctor_schedules]([id]),
        CONSTRAINT [FK_time_slots_doctor]
            FOREIGN KEY ([doctor_id])   REFERENCES [dbo].[doctors]([id]),
        CONSTRAINT [FK_time_slots_booked_by]
            FOREIGN KEY ([booked_by])   REFERENCES [dbo].[users]([id]),
        CONSTRAINT [CK_time_slots_status]
            CHECK ([status] IN ('AVAILABLE','BOOKED','CANCELLED'))
    );

    -- Index tìm slot theo bác sĩ + ngày (dùng nhiều nhất ở booking page)
    CREATE NONCLUSTERED INDEX [IX_time_slots_doctor_date]
        ON [dbo].[time_slots] ([doctor_id], [work_date], [status]);

    -- Index tìm slot theo schedule (dùng khi hủy schedule)
    CREATE NONCLUSTERED INDEX [IX_time_slots_schedule]
        ON [dbo].[time_slots] ([schedule_id]);

    PRINT N'>>> Đã tạo bảng [time_slots] và các index.';
END
ELSE
    PRINT N'>>> Bảng [time_slots] đã tồn tại, bỏ qua tạo bảng.';
GO

-- ── 2. Sinh time_slots cho TẤT CẢ lịch đã APPROVED mà chưa có slot ──
--      Mỗi slot = 20 phút, từ start_time đến end_time
DECLARE @scheduleId INT, @doctorId INT, @workDate DATE,
        @startTime  TIME(0), @endTime TIME(0);
DECLARE @slotStart TIME(0), @slotEnd TIME(0);
DECLARE @inserted INT = 0;
DECLARE @totalInserted INT = 0;

DECLARE schedule_cursor CURSOR FOR
    SELECT ds.id, ds.doctor_id,
           CAST(ds.work_date  AS DATE),
           CAST(ds.start_time AS TIME(0)),
           CAST(ds.end_time   AS TIME(0))
    FROM   doctor_schedules ds
    WHERE  ds.status = 'APPROVED'
      AND  NOT EXISTS (
               SELECT 1 FROM time_slots ts
               WHERE  ts.schedule_id = ds.id
           );

OPEN schedule_cursor;
FETCH NEXT FROM schedule_cursor
    INTO @scheduleId, @doctorId, @workDate, @startTime, @endTime;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @slotStart = @startTime;
    SET @inserted  = 0;

    WHILE DATEADD(MINUTE, 20, CAST(@slotStart AS DATETIME)) <= CAST(@endTime AS DATETIME)
    BEGIN
        SET @slotEnd = CAST(DATEADD(MINUTE, 20, CAST(@slotStart AS DATETIME)) AS TIME(0));

        INSERT INTO [dbo].[time_slots]
            (schedule_id, doctor_id, work_date, start_time, end_time, status)
        VALUES
            (@scheduleId, @doctorId, @workDate, @slotStart, @slotEnd, 'AVAILABLE');

        SET @slotStart = @slotEnd;
        SET @inserted  = @inserted + 1;
    END;

    PRINT N'>>> scheduleId=' + CAST(@scheduleId AS NVARCHAR)
        + N', date=' + CONVERT(NVARCHAR,@workDate,120)
        + N', slots inserted=' + CAST(@inserted AS NVARCHAR);

    SET @totalInserted = @totalInserted + @inserted;

    FETCH NEXT FROM schedule_cursor
        INTO @scheduleId, @doctorId, @workDate, @startTime, @endTime;
END;

CLOSE schedule_cursor;
DEALLOCATE schedule_cursor;

PRINT N'>>> HOÀN THÀNH. Tổng số slot đã sinh: ' + CAST(@totalInserted AS NVARCHAR);
GO
