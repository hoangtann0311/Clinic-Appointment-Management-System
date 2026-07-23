/*
 * V13 - Quy trình duyệt AI và ký phiếu kết quả siêu âm.
 *
 * Script có tính idempotent và chỉ dùng cho bước triển khai có kiểm soát.
 * Không chạy trực tiếp trên CSDL production khi chưa sao lưu và kiểm thử.
 */
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

BEGIN TRY
BEGIN TRANSACTION;

IF COL_LENGTH(N'dbo.ultrasound_images', N'image_width') IS NULL
    EXEC sys.sp_executesql N'ALTER TABLE dbo.ultrasound_images ADD image_width INT NULL;';
IF COL_LENGTH(N'dbo.ultrasound_images', N'image_height') IS NULL
    EXEC sys.sp_executesql N'ALTER TABLE dbo.ultrasound_images ADD image_height INT NULL;';

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints
               WHERE name = N'CK_ultrasound_images_dimensions'
                 AND parent_object_id = OBJECT_ID(N'dbo.ultrasound_images'))
    EXEC sys.sp_executesql N'ALTER TABLE dbo.ultrasound_images
        ADD CONSTRAINT CK_ultrasound_images_dimensions
        CHECK ((image_width IS NULL AND image_height IS NULL)
            OR (image_width > 0 AND image_height > 0));';

IF OBJECT_ID(N'dbo.ultrasound_annotations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ultrasound_annotations (
        id                  BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        order_id            INT NOT NULL,
        image_id            INT NOT NULL,
        annotation_source   NVARCHAR(30) NOT NULL,
        annotation_type     NVARCHAR(30) NOT NULL,
        annotation_data     NVARCHAR(MAX) NULL,
        image_width         INT NOT NULL,
        image_height        INT NOT NULL,
        review_status       NVARCHAR(30) NOT NULL,
        rejection_reason    NVARCHAR(500) NULL,
        version             INT NOT NULL,
        is_current          BIT NOT NULL CONSTRAINT DF_ultrasound_annotations_is_current DEFAULT (1),
        created_by          INT NOT NULL,
        created_at          DATETIME2(0) NOT NULL CONSTRAINT DF_ultrasound_annotations_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at          DATETIME2(0) NOT NULL CONSTRAINT DF_ultrasound_annotations_updated_at DEFAULT (SYSUTCDATETIME()),
        reviewed_by         INT NULL,
        reviewed_at         DATETIME2(0) NULL,
        CONSTRAINT FK_ultrasound_annotations_order FOREIGN KEY (order_id) REFERENCES dbo.test_orders(id),
        CONSTRAINT FK_ultrasound_annotations_image FOREIGN KEY (image_id) REFERENCES dbo.ultrasound_images(id),
        CONSTRAINT FK_ultrasound_annotations_created_by FOREIGN KEY (created_by) REFERENCES dbo.users(id),
        CONSTRAINT FK_ultrasound_annotations_reviewed_by FOREIGN KEY (reviewed_by) REFERENCES dbo.users(id),
        CONSTRAINT CK_ultrasound_annotations_source CHECK (annotation_source IN (N'AI', N'Sonographer')),
        CONSTRAINT CK_ultrasound_annotations_type CHECK (annotation_type IN (N'BoundingBox', N'Polygon', N'None')),
        CONSTRAINT CK_ultrasound_annotations_review CHECK (review_status IN (N'PendingReview', N'Accepted', N'Corrected', N'Rejected')),
        CONSTRAINT CK_ultrasound_annotations_dimensions CHECK (image_width > 0 AND image_height > 0),
        CONSTRAINT CK_ultrasound_annotations_json CHECK (annotation_data IS NULL OR ISJSON(annotation_data) = 1)
    );
END;

IF OBJECT_ID(N'dbo.ultrasound_reports', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ultrasound_reports (
        id                    BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        test_order_id         INT NOT NULL,
        version               INT NOT NULL,
        image_description     NVARCHAR(MAX) NOT NULL,
        professional_findings NVARCHAR(MAX) NOT NULL,
        conclusion            NVARCHAR(MAX) NOT NULL,
        report_status         NVARCHAR(20) NOT NULL,
        is_current            BIT NOT NULL CONSTRAINT DF_ultrasound_reports_is_current DEFAULT (1),
        created_by            INT NOT NULL,
        created_at            DATETIME2(0) NOT NULL CONSTRAINT DF_ultrasound_reports_created_at DEFAULT (SYSUTCDATETIME()),
        signed_by_user_id     INT NULL,
        signed_name           NVARCHAR(200) NULL,
        signed_at             DATETIME2(0) NULL,
        doctor_confirmed_by   INT NULL,
        doctor_confirmed_at   DATETIME2(0) NULL,
        doctor_review_notes   NVARCHAR(2000) NULL,
        CONSTRAINT FK_ultrasound_reports_order FOREIGN KEY (test_order_id) REFERENCES dbo.test_orders(id),
        CONSTRAINT FK_ultrasound_reports_created_by FOREIGN KEY (created_by) REFERENCES dbo.users(id),
        CONSTRAINT FK_ultrasound_reports_signed_by FOREIGN KEY (signed_by_user_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_ultrasound_reports_confirmed_by FOREIGN KEY (doctor_confirmed_by) REFERENCES dbo.users(id),
        CONSTRAINT CK_ultrasound_reports_status CHECK (report_status IN (N'Draft', N'Signed', N'Amended'))
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_ultrasound_annotations_current' AND object_id = OBJECT_ID(N'dbo.ultrasound_annotations'))
    EXEC sys.sp_executesql N'CREATE UNIQUE INDEX UX_ultrasound_annotations_current
        ON dbo.ultrasound_annotations(order_id) WHERE is_current = 1;';

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ultrasound_annotations_image_version' AND object_id = OBJECT_ID(N'dbo.ultrasound_annotations'))
    EXEC sys.sp_executesql N'CREATE INDEX IX_ultrasound_annotations_image_version
        ON dbo.ultrasound_annotations(image_id, version DESC);';

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_ultrasound_reports_current' AND object_id = OBJECT_ID(N'dbo.ultrasound_reports'))
    EXEC sys.sp_executesql N'CREATE UNIQUE INDEX UX_ultrasound_reports_current
        ON dbo.ultrasound_reports(test_order_id) WHERE is_current = 1;';

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ai_analysis_results_order' AND object_id = OBJECT_ID(N'dbo.ai_analysis_results'))
    EXEC sys.sp_executesql N'CREATE INDEX IX_ai_analysis_results_order
        ON dbo.ai_analysis_results(test_order_id, analyzed_at DESC);';

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ultrasound_images_order_uploaded' AND object_id = OBJECT_ID(N'dbo.ultrasound_images'))
    EXEC sys.sp_executesql N'CREATE INDEX IX_ultrasound_images_order_uploaded
        ON dbo.ultrasound_images(test_order_id, uploaded_at, id);';

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_test_orders_record_service_status' AND object_id = OBJECT_ID(N'dbo.test_orders'))
    EXEC sys.sp_executesql N'CREATE INDEX IX_test_orders_record_service_status
        ON dbo.test_orders(medical_record_id, service_id, status, id);';

IF EXISTS (SELECT appointment_id FROM dbo.medical_records GROUP BY appointment_id HAVING COUNT(*) > 1)
    THROW 51013, N'Không thể tạo ràng buộc hồ sơ: một appointment đang có nhiều medical record.', 1;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_medical_records_appointment' AND object_id = OBJECT_ID(N'dbo.medical_records'))
    EXEC sys.sp_executesql N'CREATE UNIQUE INDEX UX_medical_records_appointment
        ON dbo.medical_records(appointment_id);';

/* Đưa dữ liệu trạng thái từ luồng cũ về máy trạng thái chính thức. */
UPDATE dbo.test_orders SET status = 'Pending'
WHERE UPPER(LTRIM(RTRIM(ISNULL(status, '')))) IN ('WAITING', 'ORDERED');
UPDATE dbo.test_orders SET status = 'Uploaded'
WHERE UPPER(LTRIM(RTRIM(ISNULL(status, '')))) IN ('ANALYZING', 'FAILED');

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
