-- ============================================================
-- INDEXES CHO DASHBOARD PERFORMANCE
-- Các index này tối ưu correlated subquery trong DashboardDAO:
--   - getDoctorPerformance(from, to)
--   - getUltrasoundStats(from, to)
--
-- Khi scale lên hàng trăm bác sĩ / dịch vụ, mỗi subquery
-- quét toàn bộ appointments. Các index dưới đây giảm
-- thời gian query từ O(n) xuống O(log n).
--
-- CHẠY 1 LẦN SAU KHI ĐÃ CÓ DỮ LIỆU APPOINTMENTS.
-- ============================================================

USE [ObstetricsClinicDB]
GO

-- Index cho hiệu suất bác sĩ:
--   WHERE doctor_id = ? AND appointment_date >= ? AND <= ? AND status = 'completed'
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Appointments_DoctorDateStatus')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Appointments_DoctorDateStatus]
    ON [dbo].[appointments] ([doctor_id], [appointment_date], [status])
    INCLUDE ([id]);
    PRINT '>>> Created IX_Appointments_DoctorDateStatus';
END
ELSE
    PRINT '>>> IX_Appointments_DoctorDateStatus already exists.';
GO

-- Index cho thống kê siêu âm:
--   WHERE service_id = ? AND appointment_date >= ? AND <= ?
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Appointments_ServiceDate')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Appointments_ServiceDate]
    ON [dbo].[appointments] ([service_id], [appointment_date])
    INCLUDE ([id]);
    PRINT '>>> Created IX_Appointments_ServiceDate';
END
ELSE
    PRINT '>>> IX_Appointments_ServiceDate already exists.';
GO

-- Index cho revenue chart + invoice join:
--   WHERE a.appointment_date >= ? AND <= ? AND i.status = 'paid'
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Invoices_StatusAppointment')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Invoices_StatusAppointment]
    ON [dbo].[invoices] ([status], [appointment_id])
    INCLUDE ([total_amount]);
    PRINT '>>> Created IX_Invoices_StatusAppointment';
END
ELSE
    PRINT '>>> IX_Invoices_StatusAppointment already exists.';
GO

PRINT '';
PRINT '========================================';
PRINT 'HOÀN THÀNH: Indexes cho Dashboard';
PRINT '========================================';
GO
