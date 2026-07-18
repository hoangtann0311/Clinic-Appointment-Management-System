/*
  Removes the retired Lab Technician role and laboratory-test feature.
  Scope: ObstetricsClinicDB only. Ultrasound continues to use test_orders,
  so the shared test_orders table is intentionally retained.
*/
USE [ObstetricsClinicDB];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @LabServices TABLE (id INT NOT NULL PRIMARY KEY);
    INSERT INTO @LabServices (id)
    SELECT s.id
    FROM dbo.services AS s
    INNER JOIN dbo.service_categories AS c ON c.id = s.category_id
    WHERE c.category_name = N'Xét nghiệm'
       OR s.service_code LIKE N'SVC-XN-%';

    DECLARE @LabAppointments TABLE (id INT NOT NULL PRIMARY KEY);
    INSERT INTO @LabAppointments (id)
    SELECT a.id
    FROM dbo.appointments AS a
    INNER JOIN @LabServices AS s ON s.id = a.service_id;

    DECLARE @LabInvoices TABLE (id INT NOT NULL PRIMARY KEY);
    INSERT INTO @LabInvoices (id)
    SELECT i.id
    FROM dbo.invoices AS i
    INNER JOIN @LabAppointments AS a ON a.id = i.appointment_id;

    DECLARE @LabOrders TABLE (id INT NOT NULL PRIMARY KEY);
    INSERT INTO @LabOrders (id)
    SELECT t.id
    FROM dbo.test_orders AS t
    INNER JOIN @LabServices AS s ON s.id = t.service_id;

    /* Delete dependent records before their parent appointment/order/service. */
    DELETE ii
    FROM dbo.invoice_items AS ii
    INNER JOIN @LabInvoices AS i ON i.id = ii.invoice_id;

    DELETE i
    FROM dbo.invoices AS i
    INNER JOIN @LabInvoices AS li ON li.id = i.id;

    DELETE r
    FROM dbo.reviews AS r
    INNER JOIN @LabAppointments AS a ON a.id = r.appointment_id;

    DELETE air
    FROM dbo.ai_analysis_results AS air
    INNER JOIN @LabOrders AS o ON o.id = air.test_order_id;

    DELETE ui
    FROM dbo.ultrasound_images AS ui
    INNER JOIN @LabOrders AS o ON o.id = ui.test_order_id;

    IF OBJECT_ID(N'dbo.lab_results', N'U') IS NOT NULL
    BEGIN
        DELETE lr
        FROM dbo.lab_results AS lr
        INNER JOIN @LabOrders AS o ON o.id = lr.test_order_id;
    END;

    DELETE t
    FROM dbo.test_orders AS t
    INNER JOIN @LabOrders AS o ON o.id = t.id;

    DELETE ph
    FROM dbo.price_history AS ph
    INNER JOIN @LabServices AS s ON s.id = ph.service_id;

    DELETE a
    FROM dbo.appointments AS a
    INNER JOIN @LabAppointments AS la ON la.id = a.id;

    DELETE n
    FROM dbo.notifications AS n
    WHERE n.title LIKE N'%Xét nghiệm%'
       OR n.content LIKE N'%Xét nghiệm%';

    DELETE al
    FROM dbo.audit_logs AS al
    WHERE al.table_name = N'lab_results'
       OR al.old_value LIKE N'%Lab Technician%'
       OR al.new_value LIKE N'%Lab Technician%'
       OR al.old_value LIKE N'%Xét nghiệm%'
       OR al.new_value LIKE N'%Xét nghiệm%';

    DELETE s
    FROM dbo.services AS s
    INNER JOIN @LabServices AS ls ON ls.id = s.id;

    DELETE FROM dbo.service_categories
    WHERE category_name = N'Xét nghiệm'
      AND NOT EXISTS (
          SELECT 1 FROM dbo.services AS s
          WHERE s.category_id = dbo.service_categories.id
      );

    DELETE rp
    FROM dbo.role_permissions AS rp
    INNER JOIN dbo.roles AS r ON r.id = rp.role_id
    WHERE r.role_name = N'Lab Technician';

    IF EXISTS (
        SELECT 1
        FROM dbo.users AS u
        INNER JOIN dbo.roles AS r ON r.id = u.role_id
        WHERE r.role_name = N'Lab Technician'
    )
    BEGIN
        THROW 51000, 'Lab Technician users still exist. Move or remove those users explicitly before removing the role.', 1;
    END;

    DELETE FROM dbo.roles WHERE role_name = N'Lab Technician';

    IF OBJECT_ID(N'dbo.lab_results', N'U') IS NOT NULL
        DROP TABLE dbo.lab_results;

    IF EXISTS (SELECT 1 FROM dbo.roles WHERE role_name = N'Lab Technician')
        THROW 51001, 'Lab Technician role cleanup failed.', 1;

    IF EXISTS (SELECT 1 FROM dbo.services WHERE service_code LIKE N'SVC-XN-%')
        THROW 51002, 'Laboratory service cleanup failed.', 1;

    IF EXISTS (SELECT 1 FROM dbo.service_categories WHERE category_name = N'Xét nghiệm')
        THROW 51003, 'Laboratory category cleanup failed.', 1;

    COMMIT TRANSACTION;

    SELECT
        (SELECT COUNT(*) FROM dbo.roles WHERE role_name = N'Lab Technician') AS remaining_lab_roles,
        (SELECT COUNT(*) FROM dbo.services WHERE service_code LIKE N'SVC-XN-%') AS remaining_lab_services,
        (SELECT COUNT(*) FROM dbo.service_categories WHERE category_name = N'Xét nghiệm') AS remaining_lab_categories,
        (SELECT COUNT(*) FROM dbo.appointments) AS final_appointments,
        (SELECT COUNT(*) FROM dbo.invoices) AS final_invoices;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

/* The OCDB baseline assigns the retired laboratory category ID 3. */
IF EXISTS (SELECT 1 FROM dbo.services WHERE category_id = 3)
    THROW 51004, 'Retired category ID 3 still has services; cleanup stopped.', 1;
DELETE FROM dbo.service_categories WHERE id = 3;
IF EXISTS (SELECT 1 FROM dbo.service_categories WHERE id = 3)
    THROW 51005, 'Retired laboratory category ID 3 cleanup failed.', 1;
GO
