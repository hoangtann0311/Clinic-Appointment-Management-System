SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF COL_LENGTH('dbo.prescriptions', 'purchase_decision') IS NULL
BEGIN
    ALTER TABLE dbo.prescriptions
        ADD purchase_decision varchar(20) NOT NULL
            CONSTRAINT DF_prescriptions_purchase_decision DEFAULT ('Pending') WITH VALUES;
END;

IF COL_LENGTH('dbo.prescriptions', 'purchase_decided_at') IS NULL
BEGIN
    ALTER TABLE dbo.prescriptions ADD purchase_decided_at datetime2 NULL;
END;

IF COL_LENGTH('dbo.prescriptions', 'purchase_decided_by') IS NULL
BEGIN
    ALTER TABLE dbo.prescriptions ADD purchase_decided_by int NULL;
END;

GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_prescriptions_purchase_decision'
)
BEGIN
    ALTER TABLE dbo.prescriptions WITH CHECK
        ADD CONSTRAINT CK_prescriptions_purchase_decision
        CHECK (purchase_decision IN ('Pending', 'Accepted', 'Declined'));
END;

IF COL_LENGTH('dbo.appointments', 'priority_reason') IS NULL
BEGIN
    ALTER TABLE dbo.appointments ADD priority_reason nvarchar(500) NULL;
END;

IF COL_LENGTH('dbo.appointments', 'prioritized_at') IS NULL
BEGIN
    ALTER TABLE dbo.appointments ADD prioritized_at datetime2 NULL;
END;

IF COL_LENGTH('dbo.appointments', 'prioritized_by') IS NULL
BEGIN
    ALTER TABLE dbo.appointments ADD prioritized_by int NULL;
END;

GO

-- Chuyển dữ liệu từ luồng từ chối mua thuốc cũ: giữ nguyên chỉ định chuyên môn,
-- chỉ hủy hóa đơn phát sinh từ lựa chọn không mua.
UPDATE p
SET p.purchase_decision =
        CASE
            WHEN p.purchase_decision IN ('Accepted', 'Declined')
                THEN p.purchase_decision
            WHEN EXISTS (
                SELECT 1
                FROM dbo.medical_records mr
                JOIN dbo.invoices i ON i.appointment_id = mr.appointment_id
                WHERE mr.id = p.medical_record_id
                  AND UPPER(i.invoice_type) = 'PRESCRIPTION'
                  AND i.status IN ('Paid', 'PendingConfirmation')
            ) THEN 'Accepted'
            WHEN p.status = 'cancelled'
                 OR EXISTS (
                    SELECT 1
                    FROM dbo.medical_records mr
                    JOIN dbo.invoices i ON i.appointment_id = mr.appointment_id
                    WHERE mr.id = p.medical_record_id
                      AND UPPER(i.invoice_type) = 'PRESCRIPTION'
                      AND i.status = 'DeclinedPurchase'
                 ) THEN 'Declined'
            ELSE 'Pending'
        END,
    p.purchase_decided_at =
        CASE
            WHEN p.status = 'cancelled'
                 OR EXISTS (
                    SELECT 1
                    FROM dbo.medical_records mr
                    JOIN dbo.invoices i ON i.appointment_id = mr.appointment_id
                    WHERE mr.id = p.medical_record_id
                      AND UPPER(i.invoice_type) = 'PRESCRIPTION'
                      AND i.status IN ('Paid', 'PendingConfirmation', 'DeclinedPurchase')
                 ) THEN COALESCE(p.purchase_decided_at, GETDATE())
            ELSE p.purchase_decided_at
        END
FROM dbo.prescriptions p;

UPDATE dbo.prescriptions
SET status = 'issued'
WHERE status = 'cancelled'
  AND purchase_decision = 'Declined';

UPDATE dbo.invoices
SET status = 'Cancelled'
WHERE UPPER(invoice_type) = 'PRESCRIPTION'
  AND status = 'DeclinedPurchase';

-- Hóa đơn thuốc Unpaid kiểu cũ được tạo tự động khi bác sĩ chốt hồ sơ.
-- Hủy chúng để bệnh nhân phải đưa ra lựa chọn trước khi sinh hóa đơn mới.
UPDATE i
SET i.status = 'Cancelled'
FROM dbo.invoices i
JOIN dbo.medical_records mr ON mr.appointment_id = i.appointment_id
JOIN dbo.prescriptions p ON p.medical_record_id = mr.id
WHERE UPPER(i.invoice_type) = 'PRESCRIPTION'
  AND i.status = 'Unpaid'
  AND p.purchase_decision = 'Pending';

-- Chuyển trạng thái SOS cũ về vòng đời khám chuẩn; mức ưu tiên nằm ở is_emergency.
UPDATE dbo.appointments
SET is_emergency = 1,
    priority_reason = COALESCE(priority_reason, N'Ca ưu tiên được chuyển đổi từ dữ liệu SOS cũ'),
    prioritized_at = COALESCE(prioritized_at, GETDATE()),
    status = CASE
        WHEN EXISTS (
            SELECT 1 FROM dbo.medical_records mr
            WHERE mr.appointment_id = dbo.appointments.id
              AND LOWER(LTRIM(RTRIM(ISNULL(mr.status, '')))) = 'final'
        ) THEN 'SUCCESS'
        WHEN EXISTS (
            SELECT 1 FROM dbo.medical_records mr
            WHERE mr.appointment_id = dbo.appointments.id
              AND LOWER(LTRIM(RTRIM(ISNULL(mr.status, '')))) = 'draft'
        ) THEN 'InProgress'
        ELSE 'Waiting'
    END
WHERE status = 'Emergency_SOS';

UPDATE dbo.appointments
SET priority_reason = COALESCE(priority_reason, N'Ca khám được đánh dấu ưu tiên'),
    prioritized_at = COALESCE(prioritized_at, GETDATE())
WHERE ISNULL(is_emergency, 0) = 1;

UPDATE dbo.appointments
SET status = 'SUCCESS'
WHERE UPPER(LTRIM(RTRIM(ISNULL(status, '')))) = 'COMPLETED';

COMMIT TRANSACTION;
