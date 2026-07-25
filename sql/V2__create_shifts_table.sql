-- ============================================================
-- V2: Create shifts table — Quản lý ca làm việc
-- ============================================================
-- Run this script manually against ObstetricsClinicDB before
-- deploying the updated application.
-- ============================================================

CREATE TABLE shifts (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(100) NOT NULL,
    start_time  TIME NOT NULL,
    end_time    TIME NOT NULL,
    description NVARCHAR(500) NULL,
    is_active   BIT NOT NULL DEFAULT 1,
    created_at  DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at  DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE NONCLUSTERED INDEX IX_shifts_is_active
    ON shifts(is_active)
    INCLUDE (name, start_time, end_time);

-- Seed data — 3 ca làm việc mặc định
INSERT INTO shifts (name, start_time, end_time, description) VALUES
    (N'Ca sáng',  '07:00', '11:00', N'Ca làm việc buổi sáng'),
    (N'Ca chiều', '13:00', '17:00', N'Ca làm việc buổi chiều'),
    (N'Ca tối',   '17:00', '21:00', N'Ca làm việc buổi tối');
