-- SQL Migration Script for Sonographer, AI Analysis, and Staff Payment Confirmation
-- Target database: ObstetricsClinicDB (SQL Server)

-- 1. Cập nhật bảng invoices nếu thiếu các trường cần thiết
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[dbo].[invoices]') AND name = 'invoice_type')
BEGIN
    ALTER TABLE [dbo].[invoices] ADD [invoice_type] [varchar](30) NULL DEFAULT 'PRE_EXAM';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[dbo].[invoices]') AND name = 'payment_method')
BEGIN
    ALTER TABLE [dbo].[invoices] ADD [payment_method] [varchar](30) NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[dbo].[invoices]') AND name = 'confirmed_by')
BEGIN
    ALTER TABLE [dbo].[invoices] ADD [confirmed_by] [int] NULL;
    ALTER TABLE [dbo].[invoices] ADD CONSTRAINT [FK_invoices_confirmed_by] FOREIGN KEY ([confirmed_by]) REFERENCES [dbo].[users]([id]);
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[dbo].[invoices]') AND name = 'confirmed_at')
BEGIN
    ALTER TABLE [dbo].[invoices] ADD [confirmed_at] [datetime] NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[dbo].[invoices]') AND name = 'payment_note')
BEGIN
    ALTER TABLE [dbo].[invoices] ADD [payment_note] [nvarchar](500) NULL;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[dbo].[invoices]') AND name = 'created_at')
BEGIN
    ALTER TABLE [dbo].[invoices] ADD [created_at] [datetime] NULL DEFAULT getdate();
END
GO


-- 2. Tạo bảng ultrasound_images để lưu nhiều hình ảnh siêu âm cho mỗi chỉ định
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ultrasound_images]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ultrasound_images](
        [id] [int] IDENTITY(1,1) NOT NULL,
        [test_order_id] [int] NOT NULL,
        [original_filename] [nvarchar](255) NULL,
        [stored_filename] [nvarchar](255) NULL,
        [file_path] [nvarchar](500) NULL,
        [file_size] [bigint] NULL,
        [content_type] [varchar](100) NULL,
        [uploaded_by] [int] NULL,
        [uploaded_at] [datetime] NULL DEFAULT getdate(),
     PRIMARY KEY CLUSTERED ([id] ASC)
    );

    ALTER TABLE [dbo].[ultrasound_images] WITH CHECK ADD FOREIGN KEY([test_order_id])
    REFERENCES [dbo].[test_orders] ([id]) ON DELETE CASCADE;

    ALTER TABLE [dbo].[ultrasound_images] WITH CHECK ADD FOREIGN KEY([uploaded_by])
    REFERENCES [dbo].[users] ([id]);
END
GO


-- 3. Tạo bảng ai_analysis_results để lưu kết quả phân tích hình ảnh siêu âm từ AI Engine
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ai_analysis_results]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ai_analysis_results](
        [id] [int] IDENTITY(1,1) NOT NULL,
        [test_order_id] [int] NOT NULL,
        [status] [varchar](30) NULL, -- 'Success', 'Failed'
        [detected] [bit] NULL, -- 1: Phát hiện bất thường, 0: Bình thường
        [confidence] [decimal](5, 2) NULL, -- Độ tin cậy (%)
        [message] [nvarchar](max) NULL,
        [input_image] [varchar](255) NULL,
        [result_image] [varchar](255) NULL,
        [mask_image] [varchar](255) NULL,
        [raw_mask_image] [varchar](255) NULL,
        [xmin] [int] NULL,
        [ymin] [int] NULL,
        [xmax] [int] NULL,
        [ymax] [int] NULL,
        [analyzed_at] [datetime] NULL DEFAULT getdate(),
        [error_message] [nvarchar](max) NULL,
     PRIMARY KEY CLUSTERED ([id] ASC)
    );

    ALTER TABLE [dbo].[ai_analysis_results] WITH CHECK ADD FOREIGN KEY([test_order_id])
    REFERENCES [dbo].[test_orders] ([id]) ON DELETE CASCADE;
END
GO
