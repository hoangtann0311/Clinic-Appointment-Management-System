-- ============================================================
-- SEED DATA: Appointments & Invoices mẫu
-- Script tạo dữ liệu lịch hẹn và hóa đơn mẫu để Dashboard
-- có dữ liệu hiển thị (biểu đồ doanh thu, KPI, hiệu suất BS).
--
-- YÊU CẦU TIÊN QUYẾT (chạy theo thứ tự):
--   1. ObstetricsClinicDB.sql           — schema + services + roles + 4 patients
--   2. seed_doctors_and_schedules.sql   — 5 bác sĩ + 15 lịch trực
--   3. seed_staff_and_sonographer.sql   — Staff & Sonographer
--   4. Script này                       — appointments + invoices
--
-- DỮ LIỆU TẠO RA:
--   • ~14 patients (mở rộng từ các user role_id=5 có sẵn)
--   • ~120 appointments (12 tháng, ~10/tháng)
--   • ~85  invoices (cho các appointment completed/confirmed)
--
-- PHÂN BỔ APPOINTMENT STATUS:  completed 50% | confirmed 20%
--                               cancelled 17% | pending   13%
-- PHÂN BỔ INVOICE STATUS:      paid 82% | pending 14% | cancelled 4%
-- ============================================================

USE [ObstetricsClinicDB]
GO

-- ============================================================
-- PRE-CHECK: Đảm bảo dữ liệu phụ thuộc đã sẵn sàng
-- ============================================================
DECLARE @doctorCount  INT = (SELECT COUNT(*) FROM doctors);
DECLARE @serviceCount INT = (SELECT COUNT(*) FROM services WHERE is_active = 1);
DECLARE @patientCount INT = (SELECT COUNT(*) FROM patients);

IF @doctorCount = 0
BEGIN
    RAISERROR(N'>>> [CẢNH BÁO] Bảng doctors trống! Hãy chạy seed_doctors_and_schedules.sql trước.', 10, 1) WITH NOWAIT;
    PRINT '>>> Script sẽ tiếp tục nhưng appointments sẽ có doctor_id = NULL.';
END

IF @serviceCount = 0
BEGIN
    RAISERROR(N'>>> [LỖI] Bảng services trống! Hãy chạy ObstetricsClinicDB.sql trước.', 16, 1);
    RETURN;
END

PRINT '>>> Pre-check OK: ' + CAST(@doctorCount AS VARCHAR) + ' doctors, '
      + CAST(@serviceCount AS VARCHAR) + ' services, '
      + CAST(@patientCount AS VARCHAR) + ' patients.';
GO


-- ============================================================
-- BƯỚC 1: Mở rộng bảng patients
-- Tận dụng các user có role_id=5 (Patient) đã có trong DB
-- nhưng chưa có bản ghi tương ứng trong bảng patients.
--
-- Lưu ý: Cột user_id trong patients có UNIQUE constraint.
-- SQL Server chỉ cho phép 1 giá trị NULL trong cột UNIQUE,
-- do đó walk-in patients có user_id=NULL chỉ được 1 bản ghi.
-- DB đã có sẵn patient "Hoàng Thị My" (user_id=NULL) nên
-- script này KHÔNG thêm walk-in patients mới.
-- ============================================================
DECLARE @patientsAdded INT = 0;

-- Gộp tất cả user Patient chưa có patient record vào 1 câu INSERT
INSERT INTO patients (user_id, full_name, phone_number, date_of_birth, zalo_user_id)
SELECT u.id, u.full_name, NULL, NULL, NULL
FROM users u
WHERE u.role_id = 5
  AND u.is_deleted = 0
  AND NOT EXISTS (SELECT 1 FROM patients p WHERE p.user_id = u.id);

SET @patientsAdded = @@ROWCOUNT;

DECLARE @totalPatientsNow INT = (SELECT COUNT(*) FROM patients);
PRINT '>>> Đã thêm ' + CAST(@patientsAdded AS VARCHAR) + ' patients. Tổng: '
      + CAST(@totalPatientsNow AS VARCHAR) + ' patients.';
GO


-- ============================================================
-- BƯỚC 2: Tạo appointments (12 tháng, ~120 bản ghi)
--
-- Quy ước status:
--   completed  — đã khám xong, có kết quả
--   confirmed  — đã xác nhận lịch, chưa đến ngày khám
--   cancelled  — bệnh nhân hủy hoặc không đến
--   pending    — chờ xác nhận từ lễ tân
--
-- Phân bố: 50% completed, 20% confirmed, 17% cancelled, 13% pending
-- ============================================================

-- Chỉ seed nếu bảng appointments còn trống (hoặc mới có vài dòng sót từ lần chạy lỗi trước)
IF (SELECT COUNT(*) FROM appointments) < 10
BEGIN

    -- Lấy danh sách ID để tham chiếu
    DECLARE @pIDs TABLE (pid INT);
    INSERT INTO @pIDs SELECT id FROM patients;

    DECLARE @dIDs TABLE (did INT);
    INSERT INTO @dIDs SELECT id FROM doctors;

    DECLARE @sIDs TABLE (sid INT);
    INSERT INTO @sIDs SELECT id FROM services WHERE is_active = 1;

    DECLARE @totalPatients INT = (SELECT COUNT(*) FROM @pIDs);
    DECLARE @totalDoctors  INT = (SELECT COUNT(*) FROM @dIDs);
    DECLARE @totalServices INT = (SELECT COUNT(*) FROM @sIDs);

    -- Biến đếm
    DECLARE @counter   INT = 0;
    DECLARE @maxAppts  INT = 120;
    DECLARE @daysBack  INT;
    DECLARE @apptDate  DATE;
    DECLARE @patId     INT;
    DECLARE @docId     INT;
    DECLARE @svcId     INT;
    DECLARE @status    NVARCHAR(30);
    DECLARE @timeSlot  TIME;
    DECLARE @lmp       DATE;
    DECLARE @symptoms  NVARCHAR(MAX);
    DECLARE @source    NVARCHAR(50);
    DECLARE @emergency BIT;
    DECLARE @rnd       INT;
    DECLARE @monthBucket INT;
    DECLARE @slotHour  INT;
    DECLARE @slotMin   INT;
    DECLARE @symIdx    INT;

    -- Bảng tạm lưu status + time_slot pattern
    -- Dùng modulo để phân bố đều

    WHILE @counter < @maxAppts
    BEGIN
        -- ── Ngày hẹn: phân bố đều 12 tháng (365 ngày) ──
        -- Mỗi tháng ~10 appointments
        -- @counter / 10 → tháng offset (0-11), cộng thêm jitter 0-28 ngày trong tháng
        SET @monthBucket = @counter / 10;                      -- 0..11
        SET @daysBack = (@monthBucket * 30)                    -- ~30 ngày/tháng
                      + (ABS(CHECKSUM(NEWID())) % 28);         -- jitter trong tháng
        SET @apptDate = DATEADD(DAY, -@daysBack, GETDATE());

        -- Đảm bảo không vượt quá hôm nay
        IF @apptDate > GETDATE()
            SET @apptDate = GETDATE();

        -- ── Status: phân bố theo modulo ──
        SET @rnd = ABS(CHECKSUM(NEWID())) % 100;
        SET @status = CASE
            WHEN @rnd < 50 THEN 'completed'
            WHEN @rnd < 70 THEN 'confirmed'
            WHEN @rnd < 87 THEN 'cancelled'
            ELSE                'pending'
        END;

        -- Appointment tương lai không thể "completed"
        IF @apptDate >= CAST(GETDATE() AS DATE) AND @status = 'completed'
            SET @status = 'confirmed';

        -- ── Doctor, Patient, Service: ngẫu nhiên ──
        SET @patId = (SELECT TOP 1 pid FROM @pIDs ORDER BY NEWID());
        SET @docId = (SELECT TOP 1 did FROM @dIDs ORDER BY NEWID());
        SET @svcId = (SELECT TOP 1 sid FROM @sIDs ORDER BY NEWID());

        -- ── Time slot: giờ hành chính (7h-11h40, 13h-16h40) ──
        SET @rnd = ABS(CHECKSUM(NEWID())) % 100;
        IF @rnd < 55  -- Ca sáng
        BEGIN
            SET @slotHour = 7 + (ABS(CHECKSUM(NEWID())) % 5);  -- 7..11
            SET @slotMin  = (ABS(CHECKSUM(NEWID())) % 3) * 20; -- 0, 20, 40
        END
        ELSE           -- Ca chiều
        BEGIN
            SET @slotHour = 13 + (ABS(CHECKSUM(NEWID())) % 4); -- 13..16
            SET @slotMin  = (ABS(CHECKSUM(NEWID())) % 3) * 20; -- 0, 20, 40
        END;
        SET @timeSlot = TIMEFROMPARTS(@slotHour, @slotMin, 0, 0, 0);

        -- ── Last menstrual period: ~70% có (phòng khám sản) ──
        IF ABS(CHECKSUM(NEWID())) % 100 < 70
            SET @lmp = DATEADD(DAY, -(20 + ABS(CHECKSUM(NEWID())) % 280), @apptDate);
        ELSE
            SET @lmp = NULL;

        -- ── Symptoms: ~60% có mô tả triệu chứng ──
        SET @symptoms = NULL;
        IF ABS(CHECKSUM(NEWID())) % 100 < 60
        BEGIN
            SET @symIdx = ABS(CHECKSUM(NEWID())) % 10;
            SET @symptoms = CASE @symIdx
                WHEN 0 THEN N'Đau bụng dưới, ra huyết nhẹ'
                WHEN 1 THEN N'Nghén nặng, mệt mỏi, chóng mặt'
                WHEN 2 THEN N'Thai máy ít, lo lắng'
                WHEN 3 THEN N'Đau lưng, phù chân nhẹ'
                WHEN 4 THEN N'Ra khí hư bất thường, ngứa'
                WHEN 5 THEN N'Đau đầu, tăng huyết áp nhẹ'
                WHEN 6 THEN N'Không có triệu chứng bất thường — khám định kỳ'
                WHEN 7 THEN N'Sốt nhẹ, đau họng 2 ngày'
                WHEN 8 THEN N'Co thắt bụng từng cơn nhẹ'
                ELSE        N'Nôn nhiều sau ăn, không giữ được thức ăn'
            END;
        END

        -- ── Booking source ──
        SET @source = CASE ABS(CHECKSUM(NEWID())) % 5
            WHEN 0 THEN 'website'
            WHEN 1 THEN 'zalo'
            WHEN 2 THEN 'phone'
            WHEN 3 THEN 'walk-in'
            ELSE        'referral'
        END;

        -- ── Emergency: hiếm (5%) ──
        SET @emergency = CASE WHEN ABS(CHECKSUM(NEWID())) % 100 < 5 THEN 1 ELSE 0 END;

        -- ── INSERT ──
        INSERT INTO appointments (
            patient_id, doctor_id, pregnancy_id,
            appointment_date, booking_source,
            symptoms, last_menstrual_period,
            is_emergency, status, service_id, time_slot
        ) VALUES (
            @patId, @docId, NULL,
            @apptDate, @source,
            @symptoms, @lmp,
            @emergency, @status, @svcId, @timeSlot
        );

        SET @counter += 1;
    END

    PRINT '>>> Đã tạo ' + CAST(@counter AS VARCHAR) + ' appointments.';
END
ELSE
BEGIN
    DECLARE @existingApptCount INT = (SELECT COUNT(*) FROM appointments);
    PRINT '>>> Bảng appointments đã có dữ liệu (' + CAST(@existingApptCount AS VARCHAR) + ' records), bỏ qua seed...';
END
GO


-- ============================================================
-- BƯỚC 3: Tạo invoices từ appointments
--
-- Logic:
--   - completed appointment → luôn có invoice
--   - confirmed appointment → có invoice nếu đã thanh toán trước
--   - cancelled/pending    → không có invoice
--
-- Invoice status:
--   - paid     (~82%) — đã thanh toán
--   - pending  (~14%) — chưa thanh toán
--   - cancelled (~4%) — đã hủy hóa đơn
-- ============================================================

-- Chỉ seed nếu bảng invoices còn trống (hoặc mới có vài dòng sót từ lần chạy lỗi trước)
IF (SELECT COUNT(*) FROM invoices) < 5
BEGIN

    DECLARE @invCounter INT = 0;

    -- Cursor duyệt qua các appointment cần tạo invoice
    DECLARE @apptId      INT;
    DECLARE @apptStatus  NVARCHAR(30);
    DECLARE @apptDate    DATE;
    DECLARE @svcPrice    DECIMAL(18,2);
    DECLARE @invStatus   VARCHAR(30);
    DECLARE @invAmount   DECIMAL(18,2);
    DECLARE @txnCode     VARCHAR(100);
    DECLARE @rndInv      INT;
    DECLARE @variation   DECIMAL(18,2);

    DECLARE appt_cursor CURSOR FOR
        SELECT a.id, a.status, a.appointment_date,
               ISNULL(s.price, 200000) AS service_price
        FROM appointments a
        LEFT JOIN services s ON a.service_id = s.id
        WHERE a.status IN ('completed', 'confirmed')    -- Chỉ 2 trạng thái này có invoice
          AND NOT EXISTS (SELECT 1 FROM invoices i WHERE i.appointment_id = a.id);  -- Tránh trùng lặp

    OPEN appt_cursor;
    FETCH NEXT FROM appt_cursor INTO @apptId, @apptStatus, @apptDate, @svcPrice;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- ── Invoice status ──
        SET @rndInv = ABS(CHECKSUM(NEWID())) % 100;

        -- Appointment tương lai (confirmed) → đa số pending (chưa khám nên chưa thu tiền)
        IF @apptDate >= CAST(GETDATE() AS DATE)
        BEGIN
            SET @invStatus = CASE
                WHEN @rndInv < 30 THEN 'paid'      -- 30% đã thanh toán trước
                WHEN @rndInv < 95 THEN 'pending'
                ELSE                   'cancelled'
            END;
        END
        ELSE
        BEGIN
            -- Appointment quá khứ → đa số đã paid
            SET @invStatus = CASE
                WHEN @rndInv < 82 THEN 'paid'
                WHEN @rndInv < 96 THEN 'pending'
                ELSE                   'cancelled'
            END;
        END

        -- ── Invoice amount: service price + biến động ±15% ──
        SET @variation = (ABS(CHECKSUM(NEWID())) % 31) - 15;  -- -15 .. +15 (%)
        SET @invAmount = @svcPrice * (1.0 + @variation / 100.0);

        -- ── Transaction code: INV-YYYYMMDD-XXXX ──
        SET @invCounter += 1;
        SET @txnCode = 'INV-'
                     + FORMAT(@apptDate, 'yyyyMMdd')
                     + '-'
                     + RIGHT('0000' + CAST(@invCounter AS VARCHAR), 4);

        -- ── INSERT invoice ──
        INSERT INTO invoices (appointment_id, total_amount, status, transaction_code)
        VALUES (@apptId, @invAmount, @invStatus, @txnCode);

        FETCH NEXT FROM appt_cursor INTO @apptId, @apptStatus, @apptDate, @svcPrice;
    END

    CLOSE appt_cursor;
    DEALLOCATE appt_cursor;

    PRINT '>>> Đã tạo ' + CAST(@invCounter AS VARCHAR) + ' invoices.';
END
ELSE
BEGIN
    DECLARE @existingInvCount INT = (SELECT COUNT(*) FROM invoices);
    PRINT '>>> Bảng invoices đã có dữ liệu (' + CAST(@existingInvCount AS VARCHAR) + ' records), bỏ qua seed...';
END
GO


-- ============================================================
-- BƯỚC 4: Đảm bảo có dữ liệu cho HÔM NAY
-- Dashboard KPI "Doanh Thu Hôm Nay" cần ít nhất 1 appointment
-- hôm nay có invoice paid.
-- ============================================================
DECLARE @today DATE = CAST(GETDATE() AS DATE);
DECLARE @todayAppts INT = (SELECT COUNT(*) FROM appointments WHERE appointment_date = @today);

IF @todayAppts < 3
BEGIN
    PRINT '>>> Bổ sung appointments cho hôm nay (' + FORMAT(@today, 'dd/MM/yyyy') + ')...';

    DECLARE @pId INT = (SELECT TOP 1 id FROM patients     ORDER BY NEWID());
    DECLARE @dId INT = (SELECT TOP 1 id FROM doctors      ORDER BY NEWID());
    DECLARE @sId INT = (SELECT TOP 1 id FROM services WHERE is_active = 1 ORDER BY NEWID());
    DECLARE @sPrice DECIMAL(18,2);

    -- Appointment 1: Completed + Paid (hiện trong doanh thu hôm nay)
    IF NOT EXISTS (SELECT 1 FROM appointments WHERE appointment_date = @today AND status = 'completed')
    BEGIN
        SELECT @sPrice = ISNULL(price, 200000) FROM services WHERE id = @sId;

        INSERT INTO appointments (patient_id, doctor_id, pregnancy_id, appointment_date,
            booking_source, symptoms, last_menstrual_period, is_emergency, status, service_id, time_slot)
        VALUES (@pId, @dId, NULL, @today, 'website',
                N'Khám thai định kỳ tháng thứ 7', DATEADD(DAY, -210, @today),
                0, 'completed', @sId, '08:00');

        DECLARE @newApptId INT = SCOPE_IDENTITY();

        INSERT INTO invoices (appointment_id, total_amount, status, transaction_code)
        VALUES (@newApptId, @sPrice, 'paid',
                'INV-' + FORMAT(@today, 'yyyyMMdd') + '-T01');

        PRINT '    + 1 completed appointment + paid invoice (doanh thu hôm nay)';
    END

    -- Appointment 2: Confirmed + Pending invoice
    IF NOT EXISTS (SELECT 1 FROM appointments WHERE appointment_date = @today AND status = 'confirmed')
    BEGIN
        SET @pId = (SELECT TOP 1 id FROM patients     ORDER BY NEWID());
        SET @dId = (SELECT TOP 1 id FROM doctors      ORDER BY NEWID());
        SET @sId = (SELECT TOP 1 id FROM services WHERE is_active = 1 ORDER BY NEWID());

        INSERT INTO appointments (patient_id, doctor_id, pregnancy_id, appointment_date,
            booking_source, status, service_id, time_slot)
        VALUES (@pId, @dId, NULL, @today, 'phone', 'confirmed', @sId, '14:00');

        SET @newApptId = SCOPE_IDENTITY();

        INSERT INTO invoices (appointment_id, total_amount, status, transaction_code)
        VALUES (@newApptId, (SELECT ISNULL(price, 200000) FROM services WHERE id = @sId),
                'pending', 'INV-' + FORMAT(@today, 'yyyyMMdd') + '-T02');

        PRINT '    + 1 confirmed appointment + pending invoice';
    END

    -- Appointment 3: Pending (chưa xác nhận, chưa có invoice)
    IF NOT EXISTS (SELECT 1 FROM appointments WHERE appointment_date = @today AND status = 'pending')
    BEGIN
        SET @pId = (SELECT TOP 1 id FROM patients     ORDER BY NEWID());
        SET @dId = (SELECT TOP 1 id FROM doctors      ORDER BY NEWID());
        SET @sId = (SELECT TOP 1 id FROM services WHERE is_active = 1 ORDER BY NEWID());

        INSERT INTO appointments (patient_id, doctor_id, pregnancy_id, appointment_date,
            booking_source, symptoms, status, service_id, time_slot)
        VALUES (@pId, @dId, NULL, @today, 'zalo',
                N'Muốn đặt lịch siêu âm 4D — chưa rõ thời gian', 'pending', @sId, NULL);

        PRINT '    + 1 pending appointment (chưa có invoice)';
    END

    PRINT '>>> Hoàn tất bổ sung appointments hôm nay.';
END
ELSE
    PRINT '>>> Hôm nay đã có ' + CAST(@todayAppts AS VARCHAR) + ' appointments, không cần bổ sung.';
GO


-- ============================================================
-- KIỂM TRA KẾT QUẢ
-- ============================================================
PRINT '';
PRINT '========================================';
PRINT 'HOÀN THÀNH: Seed appointments & invoices';
PRINT '========================================';
PRINT '';

-- Tổng quan
PRINT '=== TỔNG QUAN ===';
SELECT
    (SELECT COUNT(*) FROM patients)     AS total_patients,
    (SELECT COUNT(*) FROM doctors)      AS total_doctors,
    (SELECT COUNT(*) FROM appointments) AS total_appointments,
    (SELECT COUNT(*) FROM invoices)     AS total_invoices;

-- Phân bố appointment theo status
PRINT '';
PRINT '=== APPOINTMENTS THEO STATUS ===';
SELECT
    status,
    COUNT(*)                             AS count,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,1)) AS pct
FROM appointments
GROUP BY status
ORDER BY COUNT(*) DESC;

-- Phân bố invoice theo status
PRINT '';
PRINT '=== INVOICES THEO STATUS ===';
SELECT
    status,
    COUNT(*)                             AS count,
    ISNULL(SUM(total_amount), 0)         AS total_revenue,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,1)) AS pct
FROM invoices
GROUP BY status
ORDER BY COUNT(*) DESC;

-- Doanh thu 12 tháng gần nhất (để so sánh với Dashboard query)
PRINT '';
PRINT '=== DOANH THU 12 THÁNG GẦN NHẤT ===';
SELECT
    YEAR(a.appointment_date)  AS nam,
    MONTH(a.appointment_date) AS thang,
    COUNT(DISTINCT a.id)      AS so_luot_kham,
    ISNULL(SUM(i.total_amount), 0) AS doanh_thu
FROM appointments a
LEFT JOIN invoices i ON i.appointment_id = a.id AND i.status = 'paid'
GROUP BY YEAR(a.appointment_date), MONTH(a.appointment_date)
ORDER BY nam, thang;

-- Doanh thu hôm nay
PRINT '';
PRINT '=== DOANH THU HÔM NAY (' + FORMAT(GETDATE(), 'dd/MM/yyyy') + ') ===';
SELECT
    ISNULL(SUM(i.total_amount), 0) AS doanh_thu_hom_nay,
    COUNT(DISTINCT a.id)           AS so_luot_kham_hom_nay
FROM appointments a
INNER JOIN invoices i ON i.appointment_id = a.id
WHERE a.appointment_date = CAST(GETDATE() AS DATE)
  AND i.status = 'paid';

-- Top bác sĩ theo doanh thu
PRINT '';
PRINT '=== TOP BÁC SĨ THEO DOANH THU ===';
SELECT TOP 5
    d.full_name           AS bac_si,
    d.specialization      AS chuyen_khoa,
    COUNT(DISTINCT a.id)  AS so_luot_kham,
    ISNULL(SUM(i.total_amount), 0) AS tong_doanh_thu
FROM doctors d
LEFT JOIN appointments a ON a.doctor_id = d.id AND a.status = 'completed'
LEFT JOIN invoices i    ON i.appointment_id = a.id AND i.status = 'paid'
GROUP BY d.id, d.full_name, d.specialization
ORDER BY tong_doanh_thu DESC;

PRINT '';
PRINT '>>> TRUY CẬP DASHBOARD ĐỂ XEM DỮ LIỆU:';
PRINT '    Admin:     http://localhost:8080/ClinicAppointmentManagementSystem/admin/dashboard';
PRINT '    Manager:   http://localhost:8080/ClinicAppointmentManagementSystem/manager/dashboard';
PRINT '    Doctor:    http://localhost:8080/ClinicAppointmentManagementSystem/doctor/dashboard';
GO
