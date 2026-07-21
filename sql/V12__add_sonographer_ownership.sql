-- Idempotent Migration script for adding Sonographer ownership columns to test_orders table
-- Safe to execute multiple times on SQL Server without errors.

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Add sonographer_user_id column if not exists
    IF NOT EXISTS (
        SELECT 1 FROM sys.columns 
        WHERE object_id = OBJECT_ID(N'dbo.test_orders') 
          AND name = N'sonographer_user_id'
    )
    BEGIN
        ALTER TABLE dbo.test_orders ADD sonographer_user_id INT NULL;
        PRINT 'Added column test_orders.sonographer_user_id';
    END

    -- 2. Add accepted_at column if not exists
    IF NOT EXISTS (
        SELECT 1 FROM sys.columns 
        WHERE object_id = OBJECT_ID(N'dbo.test_orders') 
          AND name = N'accepted_at'
    )
    BEGIN
        ALTER TABLE dbo.test_orders ADD accepted_at DATETIME2 NULL;
        PRINT 'Added column test_orders.accepted_at';
    END

    -- 3. Add Foreign Key FK_test_orders_sonographer if not exists
    IF NOT EXISTS (
        SELECT 1 FROM sys.foreign_keys 
        WHERE object_id = OBJECT_ID(N'dbo.FK_test_orders_sonographer')
    )
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID(N'dbo.users'))
        BEGIN
            ALTER TABLE dbo.test_orders ADD CONSTRAINT FK_test_orders_sonographer 
            FOREIGN KEY (sonographer_user_id) REFERENCES dbo.users(id);
            PRINT 'Added Foreign Key FK_test_orders_sonographer';
        END
    END

    -- 4. Add Index IX_test_orders_sonographer if not exists
    IF NOT EXISTS (
        SELECT 1 FROM sys.indexes 
        WHERE object_id = OBJECT_ID(N'dbo.test_orders') 
          AND name = N'IX_test_orders_sonographer'
    )
    BEGIN
        CREATE INDEX IX_test_orders_sonographer ON dbo.test_orders(sonographer_user_id);
        PRINT 'Created Index IX_test_orders_sonographer';
    END

    COMMIT TRANSACTION;
    PRINT 'Migration V12 completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSeverity INT = ERROR_SEVERITY();
    RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO
