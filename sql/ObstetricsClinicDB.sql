USE [master]
GO
/****** Object:  Database [ObstetricsClinicDB]    Script Date: 6/14/2026 10:28:52 PM ******/
CREATE DATABASE [ObstetricsClinicDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ObstetricsClinicDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ObstetricsClinicDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ObstetricsClinicDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ObstetricsClinicDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [ObstetricsClinicDB] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ObstetricsClinicDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ObstetricsClinicDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [ObstetricsClinicDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ObstetricsClinicDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ObstetricsClinicDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [ObstetricsClinicDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ObstetricsClinicDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [ObstetricsClinicDB] SET  MULTI_USER 
GO
ALTER DATABASE [ObstetricsClinicDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ObstetricsClinicDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ObstetricsClinicDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ObstetricsClinicDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ObstetricsClinicDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ObstetricsClinicDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [ObstetricsClinicDB] SET QUERY_STORE = ON
GO
ALTER DATABASE [ObstetricsClinicDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [ObstetricsClinicDB]
GO
/****** Object:  Table [dbo].[appointments]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[appointments](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NULL,
	[doctor_id] [int] NULL,
	[pregnancy_id] [int] NULL,
	[appointment_date] [date] NULL,
	[booking_source] [nvarchar](50) NULL,
	[symptoms] [nvarchar](max) NULL,
	[last_menstrual_period] [date] NULL,
	[is_emergency] [bit] NULL,
	[status] [nvarchar](30) NULL,
	[service_id] [int] NULL,
	[time_slot] [time](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[audit_logs]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[audit_logs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NULL,
	[action] [nvarchar](255) NULL,
	[table_name] [nvarchar](100) NULL,
	[old_value] [nvarchar](max) NULL,
	[new_value] [nvarchar](max) NULL,
	[ip_address] [varchar](50) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doctor_schedules]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doctor_schedules](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[doctor_id] [int] NULL,
	[work_date] [date] NULL,
	[start_time] [time](7) NULL,
	[end_time] [time](7) NULL,
	[is_approved] [bit] NULL,
	[max_slots] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doctors]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doctors](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NULL,
	[full_name] [nvarchar](100) NULL,
	[specialization] [nvarchar](100) NULL,
	[phone_number] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[invoice_items]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[invoice_items](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[invoice_id] [int] NULL,
	[item_type] [varchar](50) NULL,
	[item_id] [int] NULL,
	[quantity] [int] NULL,
	[unit_price] [decimal](18, 2) NULL,
	[subtotal] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[invoices]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[invoices](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[appointment_id] [int] NULL,
	[total_amount] [decimal](18, 2) NULL,
	[status] [varchar](30) NULL,
	[transaction_code] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[lab_results]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[lab_results](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[test_order_id] [int] NULL,
	[service_id] [int] NULL,
	[result_details] [nvarchar](max) NULL,
	[image_url] [varchar](255) NULL,
	[lab_technician_id] [int] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[medical_records]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[medical_records](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[appointment_id] [int] NULL,
	[clinical_notes] [nvarchar](max) NULL,
	[final_diagnosis] [nvarchar](max) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[medicine_categories]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[medicine_categories](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[category_name] [nvarchar](100) NOT NULL,
	[description] [nvarchar](500) NULL,
	[icon] [varchar](50) NULL,
	[sort_order] [int] NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NULL,
	[updated_at] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[medicine_price_history]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[medicine_price_history](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[medicine_id] [int] NOT NULL,
	[old_price] [decimal](18, 2) NULL,
	[new_price] [decimal](18, 2) NOT NULL,
	[change_reason] [nvarchar](500) NULL,
	[changed_by] [int] NULL,
	[created_at] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[medicines]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[medicines](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](150) NULL,
	[price] [decimal](18, 2) NULL,
	[unit] [nvarchar](50) NULL,
	[medicine_code] [varchar](50) NULL,
	[dosage] [nvarchar](100) NULL,
	[stock_quantity] [int] NULL,
	[description] [nvarchar](max) NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NULL,
	[updated_at] [datetime2](7) NULL,
	[category_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[notifications]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[notifications](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NULL,
	[title] [varchar](255) NULL,
	[content] [nvarchar](max) NOT NULL,
	[channel] [varchar](50) NULL,
	[is_read] [bit] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[password_reset_tokens]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[password_reset_tokens](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[token] [varchar](255) NOT NULL,
	[expires_at] [datetime2](7) NOT NULL,
	[is_used] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[patients]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[patients](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NULL,
	[full_name] [nvarchar](100) NULL,
	[phone_number] [varchar](20) NULL,
	[date_of_birth] [date] NULL,
	[zalo_user_id] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[permissions]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[permissions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[permission_key] [varchar](100) NOT NULL,
	[permission_name] [nvarchar](200) NOT NULL,
	[module] [varchar](50) NOT NULL,
	[description] [nvarchar](500) NULL,
	[created_at] [datetime2](7) NULL,
 CONSTRAINT [PK_permissions] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[pregnancies]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pregnancies](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NULL,
	[start_date] [date] NULL,
	[estimated_due_date] [date] NULL,
	[actual_delivery_date] [date] NULL,
	[pregnancy_status] [nvarchar](50) NULL,
	[fetus_count] [int] NULL,
	[notes] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[prescription_items]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[prescription_items](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[medicine_id] [int] NULL,
	[prescription_id] [int] NULL,
	[quantity] [int] NULL,
	[dosage] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[prescriptions]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[prescriptions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[medical_record_id] [int] NULL,
	[prescription_code] [varchar](50) NULL,
	[status] [varchar](30) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[price_history]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[price_history](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[service_id] [int] NOT NULL,
	[old_price] [decimal](18, 2) NULL,
	[new_price] [decimal](18, 2) NOT NULL,
	[change_reason] [nvarchar](500) NULL,
	[changed_by] [int] NULL,
	[created_at] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[reviews]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reviews](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[appointment_id] [int] NULL,
	[rating] [int] NULL,
	[comment] [nvarchar](max) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[role_permissions]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[role_permissions](
	[role_id] [int] NOT NULL,
	[permission_id] [int] NOT NULL,
	[created_at] [datetime2](7) NULL,
 CONSTRAINT [PK_role_permissions] PRIMARY KEY CLUSTERED 
(
	[role_id] ASC,
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[roles]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[roles](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[role_name] [nvarchar](50) NOT NULL,
	[description] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[service_categories]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[service_categories](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[category_name] [nvarchar](100) NOT NULL,
	[description] [nvarchar](500) NULL,
	[icon] [varchar](50) NULL,
	[sort_order] [int] NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NULL,
	[updated_at] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[services]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[services](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[category_id] [int] NULL,
	[duration_mins] [int] NULL,
	[requires_fasting] [bit] NULL,
	[requires_full_bladder] [bit] NULL,
	[required_room_type] [nvarchar](50) NULL,
	[allowed_specialties] [nvarchar](255) NULL,
	[service_name] [nvarchar](150) NOT NULL,
	[price] [decimal](18, 2) NULL,
	[service_code] [varchar](50) NULL,
	[description] [nvarchar](max) NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NULL,
	[updated_at] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sonographers]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sonographers](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NULL,
	[experience_years] [int] NULL,
	[qualification] [varchar](100) NULL,
	[room_no] [varchar](20) NULL,
	[status] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[test_orders]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[test_orders](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[medical_record_id] [int] NULL,
	[doctor_id] [int] NULL,
	[status] [varchar](30) NULL,
	[created_at] [datetime] NULL,
	[service_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ultrasound_results]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ultrasound_results](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[medical_record_id] [int] NULL,
	[sonographer_id] [int] NULL,
	[raw_image_url] [varchar](255) NULL,
	[ai_processed_image_url] [varchar](255) NULL,
	[ai_suggested_label] [varchar](255) NULL,
	[ai_confidence_score] [decimal](5, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[users]    Script Date: 6/14/2026 10:28:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[full_name] [nvarchar](255) NULL,
	[email] [varbinary](256) NULL,
	[password_hash] [varchar](255) NULL,
	[phone] [varbinary](256) NULL,
	[role_id] [int] NULL,
	[status] [varchar](30) NULL,
	[verification_token] [varchar](255) NULL,
	[is_verified] [bit] NULL,
	[google_id] [varchar](255) NULL,
	[auth_provider] [varchar](20) NOT NULL,
	[username] [nvarchar](50) NULL,
	[is_deleted] [bit] NOT NULL,
	[updated_at] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[audit_logs] ON 

INSERT [dbo].[audit_logs] ([id], [user_id], [action], [table_name], [old_value], [new_value], [ip_address], [created_at]) VALUES (1, NULL, N'T?o m?i h? so b?nh nhân Hoàng Th? My', N'patients', N'-', N'4', N'Staff', CAST(N'2026-06-07T03:49:48.250' AS DateTime))
INSERT [dbo].[audit_logs] ([id], [user_id], [action], [table_name], [old_value], [new_value], [ip_address], [created_at]) VALUES (2, NULL, N'T?o l?ch h?n th? công cho s?n ph? Hoàng Th? My', N'appointments', N'-', N'7', N'Staff', CAST(N'2026-06-07T03:49:48.727' AS DateTime))
SET IDENTITY_INSERT [dbo].[audit_logs] OFF
GO
SET IDENTITY_INSERT [dbo].[medicine_categories] ON 

INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (1, N'Sắt & Acid Folic', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-droplet-fill', 1, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (2, N'Canxi & Vitamin D', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-bounding-box', 2, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (3, N'Vitamin tổng hợp', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-capsule', 3, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (4, N'Nội tiết tố nữ', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-gender-female', 4, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (5, N'Thuốc tránh thai', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-shield-check', 5, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (6, N'Kháng sinh', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-virus', 6, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (7, N'Thuốc đặt phụ khoa', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-cursor-fill', 7, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (8, N'Thuốc co hồi tử cung', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-arrow-repeat', 8, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (9, N'Thuốc chống nôn', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-cup-hot', 9, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (10, N'Thuốc tiểu đường', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-graph-down-arrow', 10, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (11, N'Thuốc huyết áp', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-heart-pulse', 11, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (12, N'Dung dịch vệ sinh', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-moisture', 12, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
INSERT [dbo].[medicine_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (13, N'Thuốc khác', N'Dung dịch vệ sinh phụ nữ, duy trì pH âm đạo', N'bi-grid', 13, 1, CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2), CAST(N'2026-06-14T21:09:58.0533333' AS DateTime2))
SET IDENTITY_INSERT [dbo].[medicine_categories] OFF
GO
SET IDENTITY_INSERT [dbo].[medicines] ON 

INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (1, N'Ferrovit', CAST(120000.00 AS Decimal(18, 2)), N'Hộp', N'DK-01', N'Sắt fumarat + Acid Folic', 50, N'Bổ sung sắt và acid folic, hỗ trợ phòng thiếu máu thiếu sắt thai kỳ', 1, CAST(N'2026-06-07T22:15:40.3400000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), NULL)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (3, N'Ferrous Sulfate 200mg', CAST(2000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-SAT-02', N'Sắt (II) sulfat 200mg', 150, N'Điều trị thiếu máu thiếu sắt', 1, CAST(N'2026-06-14T21:09:58.4166667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 1)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (4, N'Tardyferon B9', CAST(5500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-SAT-03', N'Sắt (II) sulfat 256.3mg + Acid Folic 0.35mg', 180, N'Dự phòng và điều trị thiếu máu thai kỳ', 1, CAST(N'2026-06-14T21:09:58.4166667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 1)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (5, N'Ferricure', CAST(4500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-SAT-04', N'Sắt (III) hydroxide polymaltose 100mg', 120, N'Thiếu máu thiếu sắt, ít gây táo bón hơn sắt II', 1, CAST(N'2026-06-14T21:09:58.4166667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 1)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (6, N'Acid Folic 5mg', CAST(1500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-SAT-05', N'Acid Folic 5mg', 300, N'Dự phòng dị tật ống thần kinh thai nhi', 1, CAST(N'2026-06-14T21:09:58.4166667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 1)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (7, N'Ferinject 500mg', CAST(450000.00 AS Decimal(18, 2)), N'Ống', N'THUOC-SAT-06', N'Sắt carboxymaltose 500mg/10ml', 20, N'Thiếu máu nặng cần bổ sung sắt đường tĩnh mạch', 1, CAST(N'2026-06-14T21:09:58.4166667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 1)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (8, N'Canxi Corbiere 500mg', CAST(3000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-CANXI-01', N'Canxi carbonat 500mg + Vitamin D3 200IU', 250, N'Bổ sung canxi thai kỳ, dự phòng tiền sản giật', 1, CAST(N'2026-06-14T21:09:58.4166667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 2)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (9, N'Calcium D3 Stada', CAST(3500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-CANXI-02', N'Canxi carbonat 600mg + Vitamin D3 400IU', 200, N'Bổ sung canxi, phòng loãng xương', 1, CAST(N'2026-06-14T21:09:58.4200000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 2)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (10, N'Calci-D 500mg', CAST(4000.00 AS Decimal(18, 2)), N'Viên sủi', N'THUOC-CANXI-03', N'Canxi carbonat 500mg + Vitamin D3 200IU', 180, N'Bổ sung canxi, dễ uống và hấp thu nhanh', 1, CAST(N'2026-06-14T21:09:58.4200000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 2)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (11, N'Osteocare', CAST(6500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-CANXI-04', N'Canxi + Magie + Kẽm + Vitamin D3', 150, N'Bổ sung canxi toàn diện cho mẹ và bé', 1, CAST(N'2026-06-14T21:09:58.4200000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 2)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (12, N'Elevit Pronatal', CAST(12500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-VIT-01', N'12 vitamin + 7 khoáng chất + Acid Folic 0.8mg', 100, N'Vitamin tổng hợp toàn diện cho thai kỳ', 1, CAST(N'2026-06-14T21:09:58.4200000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 3)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (13, N'Pregnacare Original', CAST(9000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-VIT-02', N'19 dưỡng chất + Acid Folic 0.4mg', 80, N'Vitamin tổng hợp thai kỳ của Anh', 1, CAST(N'2026-06-14T21:09:58.4200000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 3)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (14, N'Obimin Plus', CAST(5500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-VIT-03', N'10 vitamin + Acid Folic + DHA + EPA', 120, N'Vitamin tổng hợp thai kỳ', 1, CAST(N'2026-06-14T21:09:58.4200000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 3)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (15, N'Procare', CAST(4000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-VIT-04', N'12 vitamin + DHA 100mg + Acid Folic 0.4mg', 200, N'Vitamin thai kỳ tiết kiệm', 1, CAST(N'2026-06-14T21:09:58.4200000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 3)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (16, N'DHA 200mg', CAST(3500.00 AS Decimal(18, 2)), N'Viên nang', N'THUOC-VIT-05', N'DHA từ dầu cá 200mg', 180, N'Hỗ trợ phát triển não bộ và thị giác thai nhi', 1, CAST(N'2026-06-14T21:09:58.4200000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 3)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (17, N'Omega-3 Fish Oil 1000mg', CAST(4000.00 AS Decimal(18, 2)), N'Viên nang', N'THUOC-VIT-06', N'Dầu cá 1000mg (DHA 120mg + EPA 180mg)', 150, N'Bổ sung Omega-3 thai kỳ', 1, CAST(N'2026-06-14T21:09:58.4200000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 3)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (18, N'Utrogestan 100mg', CAST(12000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-NT-01', N'Progesterone vi hạt 100mg', 80, N'Điều trị dọa sảy thai, hỗ trợ hoàng thể', 1, CAST(N'2026-06-14T21:09:58.4200000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 4)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (19, N'Utrogestan 200mg', CAST(20000.00 AS Decimal(18, 2)), N'Viên đặt', N'THUOC-NT-02', N'Progesterone vi hạt 200mg', 60, N'Điều trị dọa sảy thai, hỗ trợ pha hoàng thể IVF', 1, CAST(N'2026-06-14T21:09:58.4233333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 4)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (20, N'Cyclogest 400mg', CAST(35000.00 AS Decimal(18, 2)), N'Viên đặt', N'THUOC-NT-03', N'Progesterone 400mg', 50, N'Hỗ trợ hoàng thể, dọa sảy thai', 1, CAST(N'2026-06-14T21:09:58.4233333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 4)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (21, N'Duphaston 10mg', CAST(15000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-NT-04', N'Dydrogesterone 10mg', 70, N'Dọa sảy thai, rối loạn kinh nguyệt, lạc nội mạc tử cung', 1, CAST(N'2026-06-14T21:09:58.4233333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 4)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (22, N'Estrofem 2mg', CAST(8000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-NT-05', N'Estradiol 2mg', 90, N'Liệu pháp hormone thay thế, rối loạn mãn kinh', 1, CAST(N'2026-06-14T21:09:58.4233333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 4)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (23, N'Progesterone 25mg/ml', CAST(8000.00 AS Decimal(18, 2)), N'Ống', N'THUOC-NT-06', N'Progesterone 25mg/ml', 100, N'Dọa sảy thai, hỗ trợ hoàng thể đường tiêm', 1, CAST(N'2026-06-14T21:09:58.4233333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 4)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (24, N'Marvelon 28 viên', CAST(65000.00 AS Decimal(18, 2)), N'Vỉ', N'THUOC-TT-01', N'Desogestrel 0.15mg + Ethinylestradiol 0.03mg', 40, N'Tránh thai hằng ngày liều thấp', 1, CAST(N'2026-06-14T21:09:58.4266667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 5)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (25, N'Yaz 28 viên', CAST(180000.00 AS Decimal(18, 2)), N'Vỉ', N'THUOC-TT-02', N'Drospirenone 3mg + Ethinylestradiol 0.02mg', 30, N'Tránh thai, điều trị mụn, giảm giữ nước', 1, CAST(N'2026-06-14T21:09:58.4266667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 5)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (26, N'Mercilon 21 viên', CAST(55000.00 AS Decimal(18, 2)), N'Vỉ', N'THUOC-TT-03', N'Desogestrel 0.15mg + Ethinylestradiol 0.02mg', 35, N'Tránh thai hằng ngày siêu liều thấp', 1, CAST(N'2026-06-14T21:09:58.4266667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 5)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (27, N'Implanon NXT', CAST(2200000.00 AS Decimal(18, 2)), N'Que', N'THUOC-TT-04', N'Etonogestrel 68mg (que cấy)', 5, N'Tránh thai 3 năm bằng que cấy dưới da', 1, CAST(N'2026-06-14T21:09:58.4266667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 5)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (28, N'Mirena IUS', CAST(3500000.00 AS Decimal(18, 2)), N'Dụng cụ', N'THUOC-TT-05', N'Levonorgestrel 52mg (dụng cụ tử cung)', 3, N'Tránh thai 5 năm và hỗ trợ điều trị rong kinh', 1, CAST(N'2026-06-14T21:09:58.4266667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 5)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (29, N'Postinor-1', CAST(25000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-TT-06', N'Levonorgestrel 1.5mg', 50, N'Tránh thai khẩn cấp, một viên duy nhất', 1, CAST(N'2026-06-14T21:09:58.4266667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 5)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (30, N'Depo-Provera 150mg/ml', CAST(60000.00 AS Decimal(18, 2)), N'Ống', N'THUOC-TT-07', N'Medroxyprogesterone acetate 150mg/ml', 25, N'Tránh thai 3 tháng bằng đường tiêm bắp', 1, CAST(N'2026-06-14T21:09:58.4300000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 5)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (31, N'Amoxicillin 500mg', CAST(2500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-KS-01', N'Amoxicillin 500mg', 200, N'Nhiễm khuẩn đường niệu, viêm âm đạo', 1, CAST(N'2026-06-14T21:09:58.4300000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 6)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (32, N'Metronidazole 250mg', CAST(1500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-KS-02', N'Metronidazole 250mg', 250, N'Viêm âm đạo do Trichomonas, vi khuẩn kỵ khí', 1, CAST(N'2026-06-14T21:09:58.4300000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 6)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (33, N'Cefuroxime 500mg', CAST(8000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-KS-03', N'Cefuroxime axetil 500mg', 150, N'Nhiễm khuẩn đường niệu nặng, viêm vùng chậu', 1, CAST(N'2026-06-14T21:09:58.4333333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 6)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (34, N'Azithromycin 500mg', CAST(12000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-KS-04', N'Azithromycin 500mg', 100, N'Nhiễm Chlamydia, viêm cổ tử cung', 1, CAST(N'2026-06-14T21:09:58.4333333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 6)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (35, N'Clindamycin 300mg', CAST(4000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-KS-05', N'Clindamycin 300mg', 120, N'Viêm âm đạo do vi khuẩn (Bacterial Vaginosis)', 1, CAST(N'2026-06-14T21:09:58.4333333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 6)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (36, N'Doxycycline 100mg', CAST(1500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-KS-06', N'Doxycycline 100mg', 180, N'Nhiễm Chlamydia, viêm vùng chậu', 1, CAST(N'2026-06-14T21:09:58.4366667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 6)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (37, N'Canesten 500mg', CAST(45000.00 AS Decimal(18, 2)), N'Viên đặt', N'THUOC-DAT-01', N'Clotrimazole 500mg', 60, N'Nấm Candida âm đạo, một liều duy nhất', 1, CAST(N'2026-06-14T21:09:58.4366667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 7)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (38, N'Gyno-Daktarin 1200mg', CAST(55000.00 AS Decimal(18, 2)), N'Viên đặt', N'THUOC-DAT-02', N'Miconazole nitrat 1200mg', 50, N'Nấm âm đạo, nấm âm hộ, một liều duy nhất', 1, CAST(N'2026-06-14T21:09:58.4366667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 7)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (39, N'Neo-Penotran Forte', CAST(65000.00 AS Decimal(18, 2)), N'Viên đặt', N'THUOC-DAT-03', N'Metronidazole 750mg + Miconazole 200mg', 45, N'Viêm âm đạo hỗn hợp gồm nấm, vi khuẩn và Trichomonas', 1, CAST(N'2026-06-14T21:09:58.4366667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 7)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (40, N'Gynevax', CAST(35000.00 AS Decimal(18, 2)), N'Ống', N'THUOC-DAT-04', N'Lactobacillus acidophilus (men vi sinh)', 70, N'Phục hồi hệ vi sinh âm đạo, phòng tái phát', 1, CAST(N'2026-06-14T21:09:58.4366667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 7)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (41, N'Polygynax', CAST(38000.00 AS Decimal(18, 2)), N'Viên đặt', N'THUOC-DAT-05', N'Neomycin + Polymyxin B + Nystatin', 55, N'Viêm âm đạo do vi khuẩn và nấm', 1, CAST(N'2026-06-14T21:09:58.4366667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 7)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (42, N'Oxytocin 5UI/ml', CAST(5000.00 AS Decimal(18, 2)), N'Ống', N'THUOC-CTC-01', N'Oxytocin 5UI/ml', 100, N'Kích thích co bóp tử cung, cầm máu sau sinh', 1, CAST(N'2026-06-14T21:09:58.4366667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 8)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (43, N'Misoprostol 200mcg', CAST(3500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-CTC-02', N'Misoprostol 200mcg', 80, N'Co hồi tử cung sau sinh, đình chỉ thai lưu', 1, CAST(N'2026-06-14T21:09:58.4400000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 8)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (44, N'Methylergometrine 0.2mg/ml', CAST(6000.00 AS Decimal(18, 2)), N'Ống', N'THUOC-CTC-03', N'Methylergometrine maleat 0.2mg/ml', 60, N'Cầm máu sau sinh, co hồi tử cung', 1, CAST(N'2026-06-14T21:09:58.4400000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 8)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (45, N'Tranexamic Acid 500mg', CAST(4000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-CTC-04', N'Acid tranexamic 500mg', 90, N'Cầm máu rong kinh, băng huyết sau sinh', 1, CAST(N'2026-06-14T21:09:58.4400000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 8)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (46, N'Nautamine 90mg', CAST(3000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-NON-01', N'Dimenhydrinate 90mg', 150, N'Chống nôn, say tàu xe, nghén thai kỳ nhẹ', 1, CAST(N'2026-06-14T21:09:58.4400000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 9)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (47, N'Diclegis', CAST(8000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-NON-02', N'Doxylamine 10mg + Pyridoxine 10mg', 100, N'Điều trị nghén thai kỳ, thuốc đặc hiệu đã được FDA phê duyệt', 1, CAST(N'2026-06-14T21:09:58.4400000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 9)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (48, N'Vitamin B6 50mg', CAST(1500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-NON-03', N'Pyridoxine HCl 50mg', 200, N'Giảm buồn nôn thai kỳ, bổ trợ cùng Diclegis', 1, CAST(N'2026-06-14T21:09:58.4400000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 9)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (49, N'Metformin 500mg', CAST(1500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-TD-01', N'Metformin HCl 500mg', 200, N'Tiểu đường thai kỳ (GDM), điều trị đầu tay', 1, CAST(N'2026-06-14T21:09:58.4433333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 10)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (50, N'Metformin 850mg', CAST(2000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-TD-02', N'Metformin HCl 850mg', 150, N'Tiểu đường thai kỳ, liều cao hơn', 1, CAST(N'2026-06-14T21:09:58.4433333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 10)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (51, N'NovoRapid Insulin', CAST(180000.00 AS Decimal(18, 2)), N'Bút tiêm', N'THUOC-TD-03', N'Insulin Aspart 100UI/ml', 15, N'Tiểu đường thai kỳ kháng Metformin', 1, CAST(N'2026-06-14T21:09:58.4433333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 10)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (52, N'Methyldopa 250mg', CAST(3000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-HA-01', N'Methyldopa 250mg', 120, N'Tăng huyết áp thai kỳ, an toàn cho thai nhi', 1, CAST(N'2026-06-14T21:09:58.4433333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 11)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (53, N'Nifedipine 10mg', CAST(1500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-HA-02', N'Nifedipine 10mg', 150, N'Dọa sinh non, tăng huyết áp thai kỳ', 1, CAST(N'2026-06-14T21:09:58.4433333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 11)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (54, N'Magnesium Sulfate 15%', CAST(15000.00 AS Decimal(18, 2)), N'Ống', N'THUOC-HA-03', N'MgSO4 15% - 10ml', 40, N'Dự phòng và điều trị sản giật', 1, CAST(N'2026-06-14T21:09:58.4466667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 11)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (55, N'Gynofar', CAST(35000.00 AS Decimal(18, 2)), N'Chai', N'THUOC-VS-01', N'Dung dịch vệ sinh phụ nữ 150ml', 60, N'Ve sinh hằng ngày, phòng viêm nhiễm', 1, CAST(N'2026-06-14T21:09:58.4466667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 12)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (56, N'Saforelle', CAST(65000.00 AS Decimal(18, 2)), N'Chai', N'THUOC-VS-02', N'Dung dịch vệ sinh dịu nhẹ 200ml', 40, N'Ve sinh phụ nữ, chiết xuất ngưu bàng', 1, CAST(N'2026-06-14T21:09:58.4466667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 12)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (57, N'Lactacyd Femina', CAST(45000.00 AS Decimal(18, 2)), N'Chai', N'THUOC-VS-03', N'Dung dịch vệ sinh 250ml (acid lactic)', 50, N'Duy trì pH acid âm đạo, phòng viêm', 1, CAST(N'2026-06-14T21:09:58.4466667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 12)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (58, N'Gynepro V-Basic', CAST(55000.00 AS Decimal(18, 2)), N'Chai', N'THUOC-VS-04', N'Gel vệ sinh phụ nữ 200ml', 45, N'Ve sinh hằng ngày, phục hồi niêm mạc âm đạo', 1, CAST(N'2026-06-14T21:09:58.4466667' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 12)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (59, N'Aspirin 81mg', CAST(1000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-KHAC-01', N'Acid Acetylsalicylic 81mg', 300, N'Dự phòng tiền sản giật ở thai phụ nguy cơ cao', 1, CAST(N'2026-06-14T21:09:58.4500000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 13)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (60, N'Crinone Gel 8%', CAST(55000.00 AS Decimal(18, 2)), N'Ống bơm', N'THUOC-KHAC-02', N'Progesterone 90mg/liều gel', 30, N'Hỗ trợ pha hoàng thể IVF', 1, CAST(N'2026-06-14T21:09:58.4500000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 13)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (61, N'Parlodel 2.5mg', CAST(9000.00 AS Decimal(18, 2)), N'Viên', N'THUOC-KHAC-03', N'Bromocriptine mesylate 2.5mg', 40, N'Ức chế tiết sữa, điều trị u tuyến yên do tăng prolactin', 1, CAST(N'2026-06-14T21:09:58.4500000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 13)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (62, N'Paracetamol 500mg', CAST(500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-KHAC-04', N'Paracetamol 500mg', 500, N'Giảm đau, hạ sốt, an toàn cho thai kỳ', 1, CAST(N'2026-06-14T21:09:58.4500000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 13)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (63, N'Heparin 5000UI/ml', CAST(25000.00 AS Decimal(18, 2)), N'Ống', N'THUOC-KHAC-05', N'Heparin natri 5000UI/ml', 30, N'Dự phòng huyết khối sau mổ lấy thai, sản giật', 1, CAST(N'2026-06-14T21:09:58.4500000' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 13)
INSERT [dbo].[medicines] ([id], [name], [price], [unit], [medicine_code], [dosage], [stock_quantity], [description], [is_active], [created_at], [updated_at], [category_id]) VALUES (64, N'Ferrovit', CAST(3500.00 AS Decimal(18, 2)), N'Viên', N'THUOC-SAT-01', N'Sắt (II) fumarat 200mg + Acid Folic 0.4mg', 200, N'Dự phòng thiếu máu thiếu sắt thai kỳ', 1, CAST(N'2026-06-14T21:11:43.5733333' AS DateTime2), CAST(N'2026-06-14T22:12:30.2290710' AS DateTime2), 1)
SET IDENTITY_INSERT [dbo].[medicines] OFF
GO
SET IDENTITY_INSERT [dbo].[notifications] ON 

INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [channel], [is_read], [created_at]) VALUES (1, NULL, N'Hoàng Th? My', N'L?ch h?n khám s?n c?a b?n lúc 09:00 - 09:20 ngày 2026-06-07 dã du?c dang ký. Vui lòng d?n dúng gi? d? ti?n hành khám.', N'Zalo', 0, CAST(N'2026-06-07T03:49:48.980' AS DateTime))
SET IDENTITY_INSERT [dbo].[notifications] OFF
GO
SET IDENTITY_INSERT [dbo].[password_reset_tokens] ON 

INSERT [dbo].[password_reset_tokens] ([id], [user_id], [token], [expires_at], [is_used], [created_at]) VALUES (1, 1, N'bf9faea2-1334-4925-8662-6309d51a78ce', CAST(N'2026-05-30T23:38:22.1031459' AS DateTime2), 1, CAST(N'2026-05-30T22:38:22.1300000' AS DateTime2))
INSERT [dbo].[password_reset_tokens] ([id], [user_id], [token], [expires_at], [is_used], [created_at]) VALUES (2, 1, N'398111b7-414f-4cf1-91bf-9b4ad95877fc', CAST(N'2026-05-30T23:45:02.4064302' AS DateTime2), 1, CAST(N'2026-05-30T22:45:02.4366667' AS DateTime2))
INSERT [dbo].[password_reset_tokens] ([id], [user_id], [token], [expires_at], [is_used], [created_at]) VALUES (3, 1, N'9159a85f-6934-4971-877c-95b5098f6864', CAST(N'2026-05-30T23:46:45.0206174' AS DateTime2), 1, CAST(N'2026-05-30T22:46:45.0500000' AS DateTime2))
INSERT [dbo].[password_reset_tokens] ([id], [user_id], [token], [expires_at], [is_used], [created_at]) VALUES (1002, 1, N'9772abe1-d439-43dc-86eb-bbe2e9942e34', CAST(N'2026-06-01T17:06:33.6222169' AS DateTime2), 1, CAST(N'2026-06-01T16:06:33.7300000' AS DateTime2))
INSERT [dbo].[password_reset_tokens] ([id], [user_id], [token], [expires_at], [is_used], [created_at]) VALUES (1003, 16, N'e8c27e3d-536e-4e9d-ab79-9ae22677e5a4', CAST(N'2026-06-01T17:31:25.2254990' AS DateTime2), 1, CAST(N'2026-06-01T16:31:25.2666667' AS DateTime2))
SET IDENTITY_INSERT [dbo].[password_reset_tokens] OFF
GO
SET IDENTITY_INSERT [dbo].[patients] ON 

INSERT [dbo].[patients] ([id], [user_id], [full_name], [phone_number], [date_of_birth], [zalo_user_id]) VALUES (1, 4, N'Nguy?n Th? Lan', N'0911111111', CAST(N'1996-05-12' AS Date), N'zalo_001')
INSERT [dbo].[patients] ([id], [user_id], [full_name], [phone_number], [date_of_birth], [zalo_user_id]) VALUES (2, 5, N'Tr?n Th? Mai', N'0922222222', CAST(N'1994-08-21' AS Date), N'zalo_002')
INSERT [dbo].[patients] ([id], [user_id], [full_name], [phone_number], [date_of_birth], [zalo_user_id]) VALUES (3, 6, N'Lê Th? Hoa', N'0933333333', CAST(N'1998-11-10' AS Date), N'zalo_003')
INSERT [dbo].[patients] ([id], [user_id], [full_name], [phone_number], [date_of_birth], [zalo_user_id]) VALUES (4, NULL, N'Hoàng Th? My', N'0392783212', CAST(N'2002-06-10' AS Date), N'zalo_0392783212')
SET IDENTITY_INSERT [dbo].[patients] OFF
GO
SET IDENTITY_INSERT [dbo].[permissions] ON 

INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (1, N'user.view', N'Xem danh sách người dùng', N'users', N'Xem danh sách và thông tin chi tiết người dùng', CAST(N'2026-06-01T22:50:52.3133333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (2, N'user.create', N'Tạo người dùng mới', N'users', N'Tạo tài khoản người dùng mới trong hệ thống', CAST(N'2026-06-01T22:50:52.3166667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (3, N'user.edit', N'Chỉnh sửa thông tin người dùng', N'users', N'Cập nhật thông tin cá nhân và vai trò của người dùng', CAST(N'2026-06-01T22:50:52.3166667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (4, N'user.delete', N'Xóa người dùng', N'users', N'Xóa tài khoản người dùng khỏi hệ thống', CAST(N'2026-06-01T22:50:52.3166667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (5, N'user.toggle_status', N'Khóa/Mở khóa người dùng', N'users', N'Thay đổi trạng thái kích hoạt của tài khoản', CAST(N'2026-06-01T22:50:52.3166667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (6, N'appointment.view', N'Xem lịch hẹn', N'appointments', N'Xem danh sách và chi tiết lịch hẹn', CAST(N'2026-06-01T22:50:52.3166667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (7, N'appointment.create', N'Tạo lịch hẹn', N'appointments', N'Đặt lịch hẹn mới cho bệnh nhân', CAST(N'2026-06-01T22:50:52.3166667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (8, N'appointment.edit', N'Chỉnh sửa lịch hẹn', N'appointments', N'Thay đổi thông tin lịch hẹn đã đặt', CAST(N'2026-06-01T22:50:52.3166667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (9, N'appointment.cancel', N'Hủy lịch hẹn', N'appointments', N'Hủy bỏ lịch hẹn đã được đặt', CAST(N'2026-06-01T22:50:52.3200000' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (10, N'medical_record.view', N'Xem bệnh án', N'medical_records', N'Xem hồ sơ bệnh án của bệnh nhân', CAST(N'2026-06-01T22:50:52.3200000' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (11, N'medical_record.create', N'Tạo bệnh án', N'medical_records', N'Tạo hồ sơ bệnh án mới cho bệnh nhân', CAST(N'2026-06-01T22:50:52.3200000' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (12, N'medical_record.edit', N'Cập nhật bệnh án', N'medical_records', N'Chỉnh sửa và cập nhật thông tin bệnh án', CAST(N'2026-06-01T22:50:52.3200000' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (13, N'prescription.view', N'Xem đơn thuốc', N'prescriptions', N'Xem danh sách và chi tiết đơn thuốc', CAST(N'2026-06-01T22:50:52.3200000' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (14, N'prescription.create', N'Tạo đơn thuốc', N'prescriptions', N'Kê đơn thuốc mới cho bệnh nhân', CAST(N'2026-06-01T22:50:52.3200000' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (15, N'prescription.edit', N'Chỉnh sửa đơn thuốc', N'prescriptions', N'Điều chỉnh đơn thuốc đã kê', CAST(N'2026-06-01T22:50:52.3200000' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (16, N'ultrasound.view', N'Xem kết quả siêu âm', N'ultrasound', N'Xem hình ảnh và kết quả siêu âm', CAST(N'2026-06-01T22:50:52.3200000' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (17, N'ultrasound.perform', N'Thực hiện siêu âm', N'ultrasound', N'Tiến hành siêu âm cho bệnh nhân', CAST(N'2026-06-01T22:50:52.3200000' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (18, N'ultrasound.upload_image', N'Tải ảnh siêu âm', N'ultrasound', N'Tải lên hình ảnh siêu âm của bệnh nhân', CAST(N'2026-06-01T22:50:52.3233333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (19, N'ultrasound.update_result', N'Cập nhật kết quả siêu âm', N'ultrasound', N'Ghi nhận và cập nhật kết quả siêu âm', CAST(N'2026-06-01T22:50:52.3233333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (20, N'payment.view', N'Xem thanh toán', N'payments', N'Xem danh sách và chi tiết giao dịch thanh toán', CAST(N'2026-06-01T22:50:52.3233333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (21, N'payment.create', N'Tạo thanh toán', N'payments', N'Tạo hóa đơn và xử lý thanh toán', CAST(N'2026-06-01T22:50:52.3233333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (22, N'payment.process_refund', N'Xử lý hoàn tiền', N'payments', N'Hoàn trả tiền cho bệnh nhân khi cần', CAST(N'2026-06-01T22:50:52.3233333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (23, N'report.view_dashboard', N'Xem bảng điều khiển', N'reports', N'Xem tổng quan hệ thống và thống kê', CAST(N'2026-06-01T22:50:52.3233333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (24, N'report.view_revenue', N'Xem báo cáo doanh thu', N'reports', N'Xem báo cáo doanh thu chi tiết theo thời gian', CAST(N'2026-06-01T22:50:52.3233333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (25, N'report.view_appointments', N'Xem báo cáo lịch hẹn', N'reports', N'Xem thống kê và báo cáo lịch hẹn', CAST(N'2026-06-01T22:50:52.3233333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (26, N'system.manage_roles', N'Quản lý vai trò & phân quyền', N'system', N'Xem và chỉnh sửa vai trò cùng quyền hạn', CAST(N'2026-06-01T22:50:52.3266667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (27, N'system.manage_permissions', N'Quản lý quyền hệ thống', N'system', N'Thêm, sửa, xóa quyền trong hệ thống', CAST(N'2026-06-01T22:50:52.3266667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (28, N'system.view_audit_logs', N'Xem lịch sử hoạt động', N'system', N'Xem nhật ký thao tác của người dùng', CAST(N'2026-06-01T22:50:52.3266667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (29, N'system.manage_settings', N'Quản lý cài đặt hệ thống', N'system', N'Thay đổi cấu hình và cài đặt hệ thống', CAST(N'2026-06-01T22:50:52.3266667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (30, N'service.view', N'Xem danh sách dịch vụ', N'services', N'Xem danh sách và chi tiết các dịch vụ y tế', CAST(N'2026-06-04T16:06:12.1033333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (31, N'service.create', N'Tạo dịch vụ mới', N'services', N'Thêm dịch vụ y tế mới vào hệ thống', CAST(N'2026-06-04T16:06:12.1033333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (32, N'service.edit', N'Chỉnh sửa dịch vụ', N'services', N'Cập nhật thông tin và giá dịch vụ', CAST(N'2026-06-04T16:06:12.1033333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (33, N'service.delete', N'Xóa/Vô hiệu dịch vụ', N'services', N'Vô hiệu hóa dịch vụ không còn sử dụng', CAST(N'2026-06-04T16:06:12.1033333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (34, N'medicine.view', N'Xem danh sách thuốc', N'medicines', N'Xem danh sách và chi tiết các loại thuốc', CAST(N'2026-06-04T16:06:12.1033333' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (35, N'medicine.create', N'Tạo thuốc mới', N'medicines', N'Thêm thuốc mới vào danh mục', CAST(N'2026-06-04T16:06:12.1066667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (36, N'medicine.edit', N'Chỉnh sửa thuốc', N'medicines', N'Cập nhật thông tin và giá thuốc', CAST(N'2026-06-04T16:06:12.1066667' AS DateTime2))
INSERT [dbo].[permissions] ([id], [permission_key], [permission_name], [module], [description], [created_at]) VALUES (37, N'medicine.delete', N'Xóa/Vô hiệu thuốc', N'medicines', N'Vô hiệu hóa thuốc không còn sử dụng', CAST(N'2026-06-04T16:06:12.1066667' AS DateTime2))
SET IDENTITY_INSERT [dbo].[permissions] OFF
GO
SET IDENTITY_INSERT [dbo].[pregnancies] ON 

INSERT [dbo].[pregnancies] ([id], [patient_id], [start_date], [estimated_due_date], [actual_delivery_date], [pregnancy_status], [fetus_count], [notes]) VALUES (1, 1, CAST(N'2026-01-10' AS Date), CAST(N'2026-10-17' AS Date), NULL, N'ONGOING', 1, N'Thai k? bình thu?ng')
INSERT [dbo].[pregnancies] ([id], [patient_id], [start_date], [estimated_due_date], [actual_delivery_date], [pregnancy_status], [fetus_count], [notes]) VALUES (2, 2, CAST(N'2026-02-01' AS Date), CAST(N'2026-11-08' AS Date), NULL, N'ONGOING', 1, N'C?n theo dõi huy?t áp')
INSERT [dbo].[pregnancies] ([id], [patient_id], [start_date], [estimated_due_date], [actual_delivery_date], [pregnancy_status], [fetus_count], [notes]) VALUES (3, 3, CAST(N'2026-03-05' AS Date), CAST(N'2026-12-10' AS Date), NULL, N'ONGOING', 2, N'Thai dôi')
SET IDENTITY_INSERT [dbo].[pregnancies] OFF
GO
SET IDENTITY_INSERT [dbo].[price_history] ON 

INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (1, 2, NULL, CAST(500000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T13:23:47.7633333' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (2, 3, NULL, CAST(400000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T13:24:56.9733333' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (3, 4, NULL, CAST(200000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T13:26:26.4566667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (4, 5, NULL, CAST(72000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T13:36:32.6333333' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (5, 1, CAST(220000.00 AS Decimal(18, 2)), CAST(200000.00 AS Decimal(18, 2)), N'Cập nhật giá dịch vụ', 17, CAST(N'2026-06-14T19:24:34.3000000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (6, 6, NULL, CAST(250000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:29:31.5166667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (7, 7, NULL, CAST(300000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:32:42.1466667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (8, 8, NULL, CAST(200000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:33:51.2366667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (9, 9, NULL, CAST(350000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:38:32.7566667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (10, 10, NULL, CAST(200000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:41:38.8600000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (11, 11, NULL, CAST(280000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:43:03.6666667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (12, 12, NULL, CAST(200000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:48:00.0533333' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (13, 13, NULL, CAST(500000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:50:00.8400000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (14, 14, NULL, CAST(300000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:51:32.7066667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (15, 15, NULL, CAST(400000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:52:43.2166667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (16, 16, NULL, CAST(300000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:54:06.3666667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (17, 17, NULL, CAST(250000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:56:20.9866667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (18, 18, NULL, CAST(350000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:58:05.6433333' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (19, 19, NULL, CAST(600000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T19:59:11.8200000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (20, 20, NULL, CAST(150000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:01:45.1600000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (21, 21, NULL, CAST(250000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:03:32.6533333' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (22, 22, NULL, CAST(100000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:05:00.1600000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (23, 23, NULL, CAST(300000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:06:30.2600000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (24, 24, NULL, CAST(500000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:09:02.9733333' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (25, 25, NULL, CAST(450000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:10:17.8366667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (26, 26, NULL, CAST(2500000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:11:27.4100000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (27, 27, NULL, CAST(200000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:12:42.9466667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (28, 28, NULL, CAST(250000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:13:53.4900000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (29, 29, NULL, CAST(150000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:14:57.0266667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (30, 30, NULL, CAST(100000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:16:14.9800000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (31, 31, NULL, CAST(180000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:19:36.8733333' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (32, 32, NULL, CAST(200000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:21:34.2266667' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (33, 33, NULL, CAST(150000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:22:49.7133333' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (34, 34, NULL, CAST(200000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:24:05.3933333' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (35, 35, NULL, CAST(150000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:25:04.1700000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (36, 36, NULL, CAST(250000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:26:15.6200000' AS DateTime2))
INSERT [dbo].[price_history] ([id], [service_id], [old_price], [new_price], [change_reason], [changed_by], [created_at]) VALUES (37, 37, NULL, CAST(350000.00 AS Decimal(18, 2)), N'Khởi tạo dịch vụ mới', 17, CAST(N'2026-06-14T20:27:29.1600000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[price_history] OFF
GO
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 1, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 2, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 3, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 4, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 5, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 6, CAST(N'2026-06-09T18:59:31.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 7, CAST(N'2026-06-09T18:59:31.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 8, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 9, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 10, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 11, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 12, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 13, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 14, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 15, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 16, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 17, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 18, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 19, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 20, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 21, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 22, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 23, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 24, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 25, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 26, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 27, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 28, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 29, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 30, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 31, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 32, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 33, CAST(N'2026-06-09T18:59:31.4866667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 34, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 35, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 36, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (1, 37, CAST(N'2026-06-09T18:59:31.4833333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 1, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 6, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 7, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 8, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 9, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 10, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 11, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 12, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 13, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 14, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 15, CAST(N'2026-06-01T22:50:52.4633333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 16, CAST(N'2026-06-01T22:50:52.4666667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 23, CAST(N'2026-06-01T22:50:52.4666667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 24, CAST(N'2026-06-01T22:50:52.4666667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 25, CAST(N'2026-06-01T22:50:52.4666667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 30, CAST(N'2026-06-04T16:06:12.1500000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (2, 34, CAST(N'2026-06-04T16:06:12.1500000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 1, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 6, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 7, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 8, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 9, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 10, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 20, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 21, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 22, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 23, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 24, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 25, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 28, CAST(N'2026-06-01T22:50:52.5000000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 30, CAST(N'2026-06-04T16:06:12.1400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 31, CAST(N'2026-06-04T16:06:12.1400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 32, CAST(N'2026-06-04T16:06:12.1400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 34, CAST(N'2026-06-04T16:06:12.1400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 35, CAST(N'2026-06-04T16:06:12.1400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (3, 36, CAST(N'2026-06-04T16:06:12.1400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (4, 1, CAST(N'2026-06-01T22:50:52.5266667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (4, 2, CAST(N'2026-06-01T22:50:52.5266667' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (4, 6, CAST(N'2026-06-01T22:50:52.5300000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (4, 7, CAST(N'2026-06-01T22:50:52.5300000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (4, 8, CAST(N'2026-06-01T22:50:52.5300000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (4, 9, CAST(N'2026-06-01T22:50:52.5300000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (4, 20, CAST(N'2026-06-01T22:50:52.5300000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (4, 21, CAST(N'2026-06-01T22:50:52.5300000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (4, 22, CAST(N'2026-06-01T22:50:52.5300000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (4, 23, CAST(N'2026-06-01T22:50:52.5300000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (5, 6, CAST(N'2026-06-01T22:50:52.5400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (5, 7, CAST(N'2026-06-01T22:50:52.5400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (5, 10, CAST(N'2026-06-01T22:50:52.5400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (5, 13, CAST(N'2026-06-01T22:50:52.5400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (5, 16, CAST(N'2026-06-01T22:50:52.5400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (5, 20, CAST(N'2026-06-01T22:50:52.5400000' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (6, 1, CAST(N'2026-06-01T22:50:52.5533333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (6, 6, CAST(N'2026-06-01T22:50:52.5533333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (6, 10, CAST(N'2026-06-01T22:50:52.5533333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (6, 16, CAST(N'2026-06-01T22:50:52.5533333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (6, 17, CAST(N'2026-06-01T22:50:52.5533333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (6, 18, CAST(N'2026-06-01T22:50:52.5533333' AS DateTime2))
INSERT [dbo].[role_permissions] ([role_id], [permission_id], [created_at]) VALUES (6, 19, CAST(N'2026-06-01T22:50:52.5533333' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[roles] ON 

INSERT [dbo].[roles] ([id], [role_name], [description]) VALUES (1, N'Admin', N'Quản trị viên hệ thống — có toàn quyền truy cập và quản lý tất cả chức năng.')
INSERT [dbo].[roles] ([id], [role_name], [description]) VALUES (2, N'Doctor', N'Bác sĩ — khám bệnh, xem và cập nhật bệnh án, kê đơn thuốc, xem kết quả siêu âm.')
INSERT [dbo].[roles] ([id], [role_name], [description]) VALUES (3, N'Manager', N'Quản lý phòng khám — giám sát hoạt động, xem báo cáo, quản lý thanh toán.')
INSERT [dbo].[roles] ([id], [role_name], [description]) VALUES (4, N'Staff', N'Nhân viên lễ tân — đăng ký bệnh nhân, tạo lịch hẹn, xử lý thanh toán và in hóa đơn.')
INSERT [dbo].[roles] ([id], [role_name], [description]) VALUES (5, N'Patient', N'Bệnh nhân — đặt lịch hẹn, xem bệnh án, đơn thuốc và kết quả siêu âm của bản thân.')
INSERT [dbo].[roles] ([id], [role_name], [description]) VALUES (6, N'Sonographer', N'Kỹ thuật viên siêu âm — thực hiện siêu âm, tải ảnh và cập nhật kết quả siêu âm.')
INSERT [dbo].[roles] ([id], [role_name], [description]) VALUES (7, N'Lab Technician', NULL)
SET IDENTITY_INSERT [dbo].[roles] OFF
GO
SET IDENTITY_INSERT [dbo].[service_categories] ON 

INSERT [dbo].[service_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (1, N'Khám sản', N'Dịch vụ khám thai, khám sản phụ khoa định kỳ', N'bi-clipboard2-heart', 1, 1, NULL, NULL)
INSERT [dbo].[service_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (2, N'Siêu âm', N'Siêu âm 2D, 4D, đầu dò chẩn đoán hình ảnh', N'bi-soundwave', 2, 1, NULL, NULL)
INSERT [dbo].[service_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (3, N'Xét nghiệm', N'Xét nghiệm tiền sản, sàng lọc, máu, nước tiểu', N'bi-droplet', 3, 1, NULL, NULL)
INSERT [dbo].[service_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (4, N'Tư vấn', N'Tư vấn tiền sản, kế hoạch hóa gia đình, dinh dưỡng', N'bi-chat-heart', 4, 1, NULL, NULL)
INSERT [dbo].[service_categories] ([id], [category_name], [description], [icon], [sort_order], [is_active], [created_at], [updated_at]) VALUES (5, N'Thủ thuật', N'Thủ thuật sản phụ khoa, soi cổ tử cung, đo tim thai', N'bi-heart-pulse', 5, 1, CAST(N'2026-06-14T12:52:45.1000000' AS DateTime2), CAST(N'2026-06-14T22:23:03.7096571' AS DateTime2))
SET IDENTITY_INSERT [dbo].[service_categories] OFF
GO
SET IDENTITY_INSERT [dbo].[services] ON 

INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (1, 1, 20, 0, 0, N'Phòng khám sản', N'Sản phụ khoa', N'Khám thai định kì', CAST(200000.00 AS Decimal(18, 2)), N'SVC-KHAM-THAI', N'Khám, theo dõi sức khỏe thai phụ và sự phát triển của thai nhi theo từng giai đoạn thai kỳ. Bao gồm đo huyết áp, cân nặng, kiểm tra tim thai, bề cao tử cung và tư vấn xét nghiệm', 1, CAST(N'2026-06-07T22:15:40.5066667' AS DateTime2), CAST(N'2026-06-14T19:24:34.2600000' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (2, 5, 45, 0, 0, NULL, NULL, N'Soi cổ tử cung', CAST(500000.00 AS Decimal(18, 2)), N'COLPO', N'Soi tươi cổ tử cung để phát hiện viêm nhiễm, tổn thương tiền ung thư', 1, CAST(N'2026-06-14T13:23:47.7266667' AS DateTime2), CAST(N'2026-06-14T13:23:47.7266667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (3, 5, 30, 0, 0, NULL, NULL, N'Đo tim thai (NST)', CAST(400000.00 AS Decimal(18, 2)), N'NST', N'Non-Stress Test — theo dõi nhịp tim thai nhi trong 20-30 phút', 1, CAST(N'2026-06-14T13:24:56.9400000' AS DateTime2), CAST(N'2026-06-14T13:24:56.9400000' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (4, 5, 25, 0, 0, NULL, NULL, N'Đặt vòng tránh thai', CAST(200000.00 AS Decimal(18, 2)), N'FP-IUD-01', N'Thủ thuật kế hoạch hóa gia đình', 1, CAST(N'2026-06-14T13:26:26.4266667' AS DateTime2), CAST(N'2026-06-14T13:26:26.4266667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (5, 5, 30, 0, 0, N'Phòng thủ thuật Sản khoa', N'Sản phụ khoa', N'Chọc ối', CAST(72000.00 AS Decimal(18, 2)), N'18.0626.0608', N'Thủ thuật xâm lấn sử dụng kim nhỏ rút một lượng nước ối từ buồng tử cung dưới định vị của siêu âm để làm các xét nghiệm chẩn đoán di truyền trước sinh', 1, CAST(N'2026-06-14T13:36:32.6033333' AS DateTime2), CAST(N'2026-06-14T13:36:32.6033333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (6, 1, 25, 0, 0, N'Phòng khám sản', N'Sản phụ khoa', N'Khám phụ khoa tổng quát', CAST(250000.00 AS Decimal(18, 2)), N'SVC-KHAM-PHU-KHOA', N'Khám phụ khoa định kỳ: khám vú, khám bụng, khám mỏ vịt, soi tươi dịch âm đạo', 1, CAST(N'2026-06-14T19:29:31.4866667' AS DateTime2), CAST(N'2026-06-14T19:29:31.4866667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (7, 1, 30, 0, 0, N'Phòng Khám Sản 1', N'Sản khoa', N'Khám tiền sản', CAST(300000.00 AS Decimal(18, 2)), N'SVC-KHAM-TIEN-SAN', N'Khám sàng lọc trước khi mang thai: đánh giá sức khỏe tổng quát, tiền sử bệnh lý, tư vấn tiêm phòng', 1, CAST(N'2026-06-14T19:32:42.1100000' AS DateTime2), CAST(N'2026-06-14T19:32:42.1100000' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (8, 1, 20, 0, 0, N'Phòng siêu âm 2', N'Sản khoa', N'Khám hậu sản', CAST(200000.00 AS Decimal(18, 2)), N'SVC-KHAM-HAU-SAN', N'Khám sau sinh: kiểm tra co hồi tử cung, vết may tầng sinh môn, tư vấn cho con bú và kế hoạch hóa gia đình', 1, CAST(N'2026-06-14T19:33:51.2033333' AS DateTime2), CAST(N'2026-06-14T19:33:51.2033333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (9, 1, 35, 0, 0, N'Phòng Khám Hiếm Muộn', N'Sản phụ khoa', N'Khám hiếm muộn', CAST(350000.00 AS Decimal(18, 2)), N'SVC-KHAM-VO-SINH', N'Khám và tư vấn ban đầu cho các cặp vợ chồng hiếm muộn: đánh giá nguyên nhân, định hướng điều trị', 1, CAST(N'2026-06-14T19:38:32.7200000' AS DateTime2), CAST(N'2026-06-14T19:38:32.7200000' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (10, 1, 15, 0, 0, N'Phòng Khám Tầm Soát', N'Sản phụ khoa', N'Khám tầm soát ung thư vú', CAST(200000.00 AS Decimal(18, 2)), N'SVC-KHAM-TUYEN-VU', N'Khám lâm sàng tuyến vú, hướng dẫn tự khám vú tại nhà, chỉ định siêu âm vú nếu cần', 1, CAST(N'2026-06-14T19:41:38.8266667' AS DateTime2), CAST(N'2026-06-14T19:41:38.8266667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (11, 1, 20, 0, 0, N'Phòng Khám Tầm Soát', N'Sản phụ khoa', N'Khám tầm soát ung thư cổ tử cung', CAST(280000.00 AS Decimal(18, 2)), N'SVC-KHAM-CTC', N'Khám mỏ vịt, làm Pap smear (phết tế bào cổ tử cung), tư vấn tiêm vaccine HPV', 1, CAST(N'2026-06-14T19:43:03.6333333' AS DateTime2), CAST(N'2026-06-14T19:43:03.6333333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (12, 2, 20, 0, 1, N'Phòng siêu âm 1', N'Sản khoa, Chẩn đoán hình ảnh', N'Siêu âm 2D thai kỳ', CAST(200000.00 AS Decimal(18, 2)), N'SVC-SA-2D', N'Siêu âm đen trắng đánh giá: vị trí thai, số lượng thai, tuổi thai, nhịp tim thai, bánh nhau(nhau thai), nước ối', 1, CAST(N'2026-06-14T19:48:00.0233333' AS DateTime2), CAST(N'2026-06-14T19:48:00.0233333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (13, 2, 30, 0, 0, N'Phòng siêu âm 2', N'Sản khoa, Chẩn đoán hình ảnh', N'Siêu âm 4D thai kỳ', CAST(500000.00 AS Decimal(18, 2)), N'SVC-SA-4D', N'Siêu âm màu 4D giúp quan sát hình thái thai nhi rõ nét, phát hiện dị tật bên ngoài, in ảnh màu tặng mẹ', 1, CAST(N'2026-06-14T19:50:00.8066667' AS DateTime2), CAST(N'2026-06-14T19:50:00.8066667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (14, 2, 15, 0, 0, N'Phòng siêu âm 1', N'Sản khoa, Phụ khoa, Chẩn đoán hình ảnh', N'Siêu âm đầu dò âm đạo', CAST(300000.00 AS Decimal(18, 2)), N'SVC-SA-DAU-DO', N'Siêu âm qua đường âm đạo để đánh giá tử cung, buồng trứng, niêm mạc tử cung, phát hiện thai sớm', 1, CAST(N'2026-06-14T19:51:32.6766667' AS DateTime2), CAST(N'2026-06-14T19:51:32.6766667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (15, 2, 25, 0, 0, N'Phòng siêu âm 1', N'Sản khoa, Chẩn đoán hình ảnh', N'Siêu âm Doppler thai kỳ', CAST(400000.00 AS Decimal(18, 2)), N'SVC-SA-DOPPLER', N'Đo lưu lượng máu qua động mạch tử cung, động mạch rốn, động mạch não giữa thai nhi để đánh giá sức khỏe thai', 1, CAST(N'2026-06-14T19:52:43.1833333' AS DateTime2), CAST(N'2026-06-14T19:52:43.1833333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (16, 2, 20, 0, 0, N'Phòng Siêu âm 1', N'Phụ khoa, Ung bướu, Chẩn đoán hình ảnh', N'Siêu âm tuyến vú', CAST(300000.00 AS Decimal(18, 2)), N'SVC-SA-VU', N'Siêu âm hai bên tuyến vú phát hiện u, nang, bất thường mô tuyến vú', 1, CAST(N'2026-06-14T19:54:06.3366667' AS DateTime2), CAST(N'2026-06-14T19:54:06.3366667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (17, 2, 20, 1, 0, N'Phòng Siêu âm 1', N'Sản khoa, Chẩn đoán hình ảnh', N'Siêu âm bụng tổng quát', CAST(250000.00 AS Decimal(18, 2)), N'SVC-SA-BUNG', N'Siêu âm đánh giá gan, thận, tụy, lách, bàng quang cho phụ nữ mang thai', 1, CAST(N'2026-06-14T19:56:20.9566667' AS DateTime2), CAST(N'2026-06-14T19:56:20.9566667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (18, 2, 20, 0, 0, N'Phòng Siêu âm 2', N'Sản khoa, Chẩn đoán hình ảnh', N'Siêu âm đo độ mờ da gáy', CAST(350000.00 AS Decimal(18, 2)), N'SVC-SA-DO-NANG', N'Siêu âm đo khoảng sáng sau gáy thai nhi tuần 11-13, sàng lọc hội chứng Down', 1, CAST(N'2026-06-14T19:58:05.6133333' AS DateTime2), CAST(N'2026-06-14T19:58:05.6133333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (19, 2, 35, 0, 0, N'Phòng Siêu âm 2', N'Sản khoa, Tim mạch, Chẩn đoán hình ảnh', N'Siêu âm tim thai', CAST(600000.00 AS Decimal(18, 2)), N'SVC-SA-TIM-THAI', N'Siêu âm chuyên sâu cấu trúc tim thai: 4 buồng tim, van tim, mạch máu lớn', 1, CAST(N'2026-06-14T19:59:11.7900000' AS DateTime2), CAST(N'2026-06-14T19:59:11.7900000' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (20, 3, 10, 1, 0, N'Phòng Xét nghiệm', N'Sản khoa, Huyết học', N'Xét nghiệm máu tổng quát', CAST(150000.00 AS Decimal(18, 2)), N'SVC-XN-MAU', N'Tổng phân tích tế bào máu: hồng cầu, bạch cầu, tiểu cầu, hemoglobin, hematocrit', 1, CAST(N'2026-06-14T20:01:45.1266667' AS DateTime2), CAST(N'2026-06-14T20:01:45.1266667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (21, 3, 15, 1, 0, N'Phòng Xét nghiệm', N'Sản khoa, Hoá sinh', N'Xét nghiệm sinh hóa máu', CAST(250000.00 AS Decimal(18, 2)), N'SVC-XN-SINH-HOA', N'Đường huyết, men gan (AST/ALT), chức năng thận (ure/creatinin), acid uric, lipid máu', 1, CAST(N'2026-06-14T20:03:32.6233333' AS DateTime2), CAST(N'2026-06-14T20:03:32.6233333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (22, 3, 10, 0, 0, N'Phòng Xét nghiệm', N'Sản khoa, Hóa sinh', N'Xét nghiệm nước tiểu 10 thông số', CAST(100000.00 AS Decimal(18, 2)), N'SVC-XN-NUOC-TIEU', N'Tổng phân tích nước tiểu: đường, đạm, hồng cầu, bạch cầu, nitrit, pH, tỷ trọng', 1, CAST(N'2026-06-14T20:05:00.1133333' AS DateTime2), CAST(N'2026-06-14T20:05:00.1133333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (23, 3, 120000, 1, 0, N'Phòng Xét nghiệm', N'Sản khoa, Nội tiết', N'Nghiệm pháp dung nạp đường huyết', CAST(300000.00 AS Decimal(18, 2)), N'SVC-XN-DUONG-HUYET', N'Xét nghiệm tầm soát tiểu đường thai kỳ: uống 75g glucose, đo đường huyết tại 3 thời điểm', 1, CAST(N'2026-06-14T20:06:30.2333333' AS DateTime2), CAST(N'2026-06-14T20:06:30.2333333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (24, 3, 15, 0, 0, N'Phòng Xét nghiệm', N'Sản khoa, Di truyền', N'Xét nghiệm Triple Test', CAST(500000.00 AS Decimal(18, 2)), N'SVC-XN-TRIPL', N'Sàng lọc hội chứng Down, Edwards, dị tật ống thần kinh (tuần 15-20 thai kỳ)', 1, CAST(N'2026-06-14T20:09:02.9333333' AS DateTime2), CAST(N'2026-06-14T20:09:02.9333333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (25, 3, 15, 0, 0, N'Phòng Xét nghiệm', N'Sản khoa, Di truyền', N'Xét nghiệm Double Test', CAST(450000.00 AS Decimal(18, 2)), N'SVC-XN-DOUBLE', N'Sàng lọc hội chứng Down, Edwards (tuần 11-13 thai kỳ), kết hợp với siêu âm đo độ mờ da gáy', 1, CAST(N'2026-06-14T20:10:17.8066667' AS DateTime2), CAST(N'2026-06-14T20:10:17.8066667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (26, 3, 20, 0, 0, N'Phòng Xét nghiệm', N'Sản khoa, Di truyền', N'Xét nghiệm NIPT', CAST(2500000.00 AS Decimal(18, 2)), N'SVC-XN-NIPT', N'Sàng lọc trước sinh không xâm lấn: phân tích DNA thai nhi tự do trong máu mẹ, phát hiện lệch bội NST 13, 18, 21', 1, CAST(N'2026-06-14T20:11:27.3800000' AS DateTime2), CAST(N'2026-06-14T20:11:27.3800000' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (27, 3, 10, 0, 0, N'Phòng Xét nghiệm', N'Sản khoa, Truyền nhiễm', N'Xét nghiệm viêm gan B, C', CAST(200000.00 AS Decimal(18, 2)), N'SVC-XN-VIEM-GAN', N'HBsAg, Anti-HCV sàng lọc viêm gan siêu vi B và C cho phụ nữ mang thai', 1, CAST(N'2026-06-14T20:12:42.9100000' AS DateTime2), CAST(N'2026-06-14T20:12:42.9100000' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (28, 3, 10, 0, 0, N'Phòng Xét nghiệm', N'Sản khoa, Miễn dịch, Truyền nhiễm', N'Xét nghiệm Rubella IgM/IgG', CAST(250000.00 AS Decimal(18, 2)), N'SVC-XN-RUBELLA', N'Sàng lọc miễn dịch virus Rubella — nguy cơ gây dị tật thai nhi nếu mẹ nhiễm trong 3 tháng đầu', 1, CAST(N'2026-06-14T20:13:53.4566667' AS DateTime2), CAST(N'2026-06-14T20:13:53.4566667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (29, 3, 10, 0, 0, N'Phòng Xét nghiệm', N'Sản khoa, Truyền nhiễm', N'Xét nghiệm giang mai (Syphilis)', CAST(150000.00 AS Decimal(18, 2)), N'SVC-XN-GIANG-MAI', N'Xét nghiệm VDRL/RPR sàng lọc bệnh giang mai cho phụ nữ mang thai', 1, CAST(N'2026-06-14T20:14:56.9966667' AS DateTime2), CAST(N'2026-06-14T20:14:56.9966667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (30, 3, 10, 0, 0, N'Phòng Xét nghiệm', N'Sản khoa, Truyền nhiễm', N'Xét nghiệm HIV test nhanh', CAST(100000.00 AS Decimal(18, 2)), N'SVC-XN-HIV', N'Test nhanh HIV cho phụ nữ mang thai, dự phòng lây truyền mẹ-con', 1, CAST(N'2026-06-14T20:16:14.9533333' AS DateTime2), CAST(N'2026-06-14T20:16:14.9533333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (31, 3, 15, 0, 0, N'Phòng Xét nghiệm', N'Phụ khoa, Vi sinh', N'Xét nghiệm dịch âm đạo', CAST(180000.00 AS Decimal(18, 2)), N'SVC-XN-DICH-AM-DAOSVC-XN-DICH-AM-DAO', N'Soi tươi + nhuộm Gram dịch âm đạo, phát hiện viêm nhiễm: nấm Candida, Trichomonas, vi khuẩn', 1, CAST(N'2026-06-14T20:19:36.8400000' AS DateTime2), CAST(N'2026-06-14T20:19:36.8400000' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (32, 4, 30, 0, 0, N'Phòng Tư vấn 1', N'Sản khoa', N'Tư vấn tiền sản', CAST(200000.00 AS Decimal(18, 2)), N'SVC-TV-TIEN-SAN', N'Tư vấn chuẩn bị mang thai: tiêm phòng, bổ sung acid folic, dinh dưỡng, lối sống lành mạnh', 1, CAST(N'2026-06-14T20:21:34.1966667' AS DateTime2), CAST(N'2026-06-14T20:21:34.1966667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (33, 4, 25, 0, 0, N'Phòng Tư vấn 1', N'Sản khoa, Phụ khoa', N'Tư vấn kế hoạch hóa gia đình', CAST(150000.00 AS Decimal(18, 2)), N'SVC-TV-KHHGD', N'Tư vấn các biện pháp tránh thai: thuốc uống, que cấy, vòng tránh thai, bao cao su, triệt sản', 1, CAST(N'2026-06-14T20:22:49.6766667' AS DateTime2), CAST(N'2026-06-14T20:22:49.6766667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (34, 4, 30, 0, 0, N'Phòng Tư vấn 1', N'Sản khoa, Dinh dưỡng', N'Tư vấn dinh dưỡng thai kỳ', CAST(200000.00 AS Decimal(18, 2)), N'SVC-TV-DINH-DUONG', N'Tư vấn chế độ ăn uống theo từng giai đoạn thai kỳ, kiểm soát cân nặng, bổ sung vi chất', 1, CAST(N'2026-06-14T20:24:05.3666667' AS DateTime2), CAST(N'2026-06-14T20:24:05.3666667' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (35, 4, 25, 0, 0, N'Phòng tư vấn 1', N'Sản khoa', N'Tư vấn chăm sóc sau sinh', CAST(150000.00 AS Decimal(18, 2)), N'SVC-TV-SAU-SINH', N'Hướng dẫn chăm sóc vết may, cho con bú đúng cách, chế độ dinh dưỡng sau sinh, nhận biết dấu hiệu bất thường', 1, CAST(N'2026-06-14T20:25:04.1433333' AS DateTime2), CAST(N'2026-06-14T20:25:04.1433333' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (36, 4, 45, 0, 0, N'Phòng Tư vấn 2', N'Sản khoa, Tâm lí', N'Tư vấn tâm lý thai kỳ', CAST(250000.00 AS Decimal(18, 2)), N'SVC-TV-TAM-LY', N'Hỗ trợ tâm lý cho phụ nữ mang thai: lo âu, trầm cảm thai kỳ, stress, thay đổi tâm sinh lý', 1, CAST(N'2026-06-14T20:26:15.5900000' AS DateTime2), CAST(N'2026-06-14T20:26:15.5900000' AS DateTime2))
INSERT [dbo].[services] ([id], [category_id], [duration_mins], [requires_fasting], [requires_full_bladder], [required_room_type], [allowed_specialties], [service_name], [price], [service_code], [description], [is_active], [created_at], [updated_at]) VALUES (37, 4, 40, 0, 0, N'Phòng Tư vấn 2', N'Sản khoa, Di truyền', N'Tư vấn di truyền', CAST(350000.00 AS Decimal(18, 2)), N'SVC-TV-DI-TRUYEN', N'Tư vấn về nguy cơ bệnh di truyền, kết quả xét nghiệm sàng lọc, các lựa chọn chẩn đoán trước sinh', 1, CAST(N'2026-06-14T20:27:29.1300000' AS DateTime2), CAST(N'2026-06-14T20:27:29.1300000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[services] OFF
GO
SET IDENTITY_INSERT [dbo].[users] ON 

INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (1, N'Hieu pham', 0x0200000039624F01A3AFB18A00100432B093635D88A32E0ED3CBCA0F012E9AE790ABAF9294CD15B8E03E3ADB97ADAD7478C89E735603559F10C1B481594B2915D5827BE1, N'$2a$12$hpPU0iUu3XUVr4OO8bZotOQvemB07CFZyWGdn1KDCMbT0ZAI8G5Ui', 0x02000000DB1B6E10351DC6C800D4C1F1DDC9AECFE1C885DFDA42E5C5BA0716F2C5FEA9DD2006542396FF55A6D3B96B9D27CEC4D7, 5, N'Active', NULL, 1, NULL, N'local', N'duct7578@gmail.com', 0, NULL)
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (2, N'Hieu pham', 0x02000000D6D93716E6F3355C5067444792ED4C5158D5A89329E6075E2C98504BD08590807C7916C1C0833EEB09E8CB5852069DFD71EB47EF91FC0DEB0DE7BEA6B80D075B, N'$2a$12$PZ3jz4Mq6yOzdVX40snhxOPfzKLvtgIa8kYH09LkcbIaqckBQLYoS', 0x02000000DC2F016C2D74B87CEF036A232168C5CAB2A0059D6AC046611FE24274C89449442C517A11B58A9B9A4761A64A1BA1F4B1, 5, N'Pending Verification', N'0e4e9d72-7b2d-42f5-9a67-b88a77d8bb96', 0, NULL, N'local', N'duct4500@gmail.com', 0, NULL)
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (3, N'Hieu pham', 0x020000001BEAC7970E6B96ED572B208B336952251FE052BA915862C7723B55503BC1853B6A8F7483CDA05C8486197B6C04A13ED223FCA7819FAE72EBF55B72053A20A41B, N'$2a$12$NXZwpFqJjOKiNIwqAmcbIOyCbGwz9IWjuJpc.NMwDhwlLas2Ee4w6', 0x020000005631AA7FC3402C63121DADB29662924EEB484C92F41AE8DAC7A52F7E113F4E039BFE8DC82FCD94C65168CB7EB30E2CC4, 5, N'Pending Verification', N'df927683-d8d7-469c-bdc2-d1e90d56b429', 0, NULL, N'local', N'duct4500@gmail.com_2', 0, NULL)
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (4, N'Hieu pham', 0x02000000F930B46241DAE9CE0572015625E014548A96CE6CCDB233A6478C0EE44D6FB2E51BDCE7A811DC84147121D57EB509B02256C88BE2A64735C7BC8E626EC32A7FC5, N'$2a$12$WvObkVjMTELL2PXLMNxlzOxxl3gBRNcNcvrnB1mlaI1PryZzdvrfm', 0x02000000C864677414211FA0C589AFA6D31F12F53BAB926106639E827F72AA9753E43E7A75E8F2F9B57FE869BDB76CFB1B24D2E0, 5, N'Pending Verification', N'4adb2d7e-95bb-4994-9dfe-3eb659a1a50f', 0, NULL, N'local', N'xfv85662@laoia.com', 0, NULL)
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (5, N'Hieu pham', 0x020000008B2D9E10C097C48013EC1CD809C48F51D2DB06FDEC94420B24809E3429AEA9D1F696BB62457900A570C38B3A99B61C77BAF837A1E94CD169D1C2CF600C8FB917, N'$2a$12$iVhwVzkf4XeBc97/tDd1OOJZT9N8LrjnNsSFl1si9kFlemex7A4Oy', 0x02000000BCDE543FAAFDEA63B5F79AA3AF1A20F624F40D9FAA5AE4E38361FEEA7D8AE4357FE2BB7F5A61C33E5B5B048109E9CAC4, 5, N'Pending Verification', N'dca15094-273f-4fb0-a32c-7030d621101f', 0, NULL, N'local', N'knz28931@laoia.com', 0, NULL)
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (6, N'Lê Thị Hoa', 0x02000000010A8B63EC764677106E1D5809656C0B035CC6FE4DAC8DFC6E64D233566406F6F66AB7F9B7F6001CFC532976296BF4169C91058855D40152F05E06550A9499E1, N'123456', 0x02000000059A0BFBE38E7EF856FE3BA9C6D0661B29443337BADE7AF0F8055568DFC5CA4576B54E0D76859B5723F92ED094F7B0A6, 5, N'Active', NULL, 0, NULL, N'local', NULL, 0, CAST(N'2026-06-07T22:15:40.5433333' AS DateTime2))
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (7, N'Hieu pham', 0x020000003D2DE052AABDE0F401AB18FA62D3FC066078647E2732593A086D3ED0CBE72CA80D748F1B04409DC747FD67839E64D0055E1F651B7AEBF53D9ADBADF2FF7DE90B, N'$2a$12$FCs66/5HqmEqmhKndIqyfuYq84cF3dghG4829.v3CK43trGI9z.Qm', 0x02000000BC986540ADEEF8C42A124EF9ED62B208747C8ECB31628751B0BD6B5F9EFA1638F1458B72B1559598EF8BCD8A843EDBF4, 5, N'Pending Verification', N'f7f9a9a7-abcc-486c-8ae7-e3f146af5ee7', 0, NULL, N'local', N'emr22979@laoia.com', 0, NULL)
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (8, N'Hieu pham', 0x02000000282CA9520295908BC82A93AD12510FDDA3BDDEBE337D5A3D56B05D1AAEC6368D838D2ED0580BA90191439FB8B78F5C5AD74FA63BFD3922285445B6ABB315629C, N'$2a$12$LBWJrrc0wkHFyLjbTCBPC.ey0wVOaqCZCrv.XvAGaO5Dl1PY7lEYC', 0x02000000DDCC65550BAC9A280CDCE8ECD6B2D7A86383AF62413EDA055B7960E5AA34CC69350D21C2A08BEDDE30338214AECD19BD, 5, N'Pending Verification', N'0770a934-5d2e-4e91-aba8-2741f392deb1', 0, NULL, N'local', N'hdc44439@laoia.com', 0, NULL)
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (9, N'Hieu pham', 0x02000000D4CF8C92D9F2E042CC67E6E3712BC69B6BA4DEAED006C6302237544CAD49095D6C8E3ECA94E73B0B0DD52610E2386181C70F2A1574E61B44E999F8F7FA335F7C, N'$2a$12$OKPTdHyVkpL31uPHFM5L4.WngxVVY9kd4srzXMytBlUoTKl5pdQye', 0x02000000D3F02AD32E5670E2361E5973B106D4B53A8A9A680544C5CBF36C5376405F5798DF996656AAEA345D7830F32532EF6EEF, 5, N'Active', N'1864aa1c-690d-43b5-b103-8cb2d38c5da0', 0, NULL, N'local', N'gen10682@laoia.com', 0, NULL)
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (10, N'Hieu pham', 0x0200000040144545D7F83EFCF2E804034C459EA1AAD6FD3ED399A2B9B155EAA330B627BF6466C56428918454DFAA2D3E3E37FB1414DF76A185E346DE7AB53A7EE9A19327, N'$2a$12$1gN/HQC4I84YFKDyPwaahOa4a5LgPbFbmtm5ZR5v0ZQfAaxRgqE4S', 0x02000000AFD10BED4D99CC3BD35AB1004E19DC5871ED3B43209B31292CB95E71207CD9BB71C614A6D64424D7E4DA8F59BB0CD268, 5, N'Active', N'a81007c0-c069-44c5-bfe6-2467392d0310', 0, NULL, N'local', N'lzm11035@laoia.com', 0, NULL)
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (11, N'Hieu pham', 0x02000000B801475C370E3BF0C78C1732B59CF4C8792E4C86D7869161492B5D78CFD6FE2D5F1F5254E4FD2F2A62D86E065BC9B03257FE97465A547A2D9CB0768F71406995, N'$2a$12$3s/AzT8eGwyCQvOVwRLa1.ex...yTTqIhcdHvw7qmiYpH7NwJcpK.', 0x020000001635863A0D64E2DAD998106CDD0E43D5753D57D4A652317EE78693300E9D6FB224AC8925AC484ADA42B18B8CE787825F, 5, N'Active', NULL, 1, NULL, N'local', N'trw35401@laoia.com', 0, NULL)
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (12, N'Ph?m Trung Hi?u', 0x02000000216B093948438DE36F4278E2892C008DA2FE3B031E51F110AE43A2CF5FCF273615649B65CC2E98E7F316B51CE4936083D2EAE4023F9133ED2143ADC2AFABDE9E, N'$2a$12$nNttMsVkR/EWPtjw1xxOie1j.ibGKe6LoyW.OXVyKm709PLQQzpei', 0x0200000065529AC8AA9F58D56A39DEF76EDCA42B4BC303F54E270A6301E5711206964FC1F783B23411CFED3C1F4CA15C3A24FFF0, 5, N'Inactive', N'7f3362d3-9e97-42dd-a13e-696d4f98d76e', 0, NULL, N'local', N'hdc44438@laoia.com', 1, CAST(N'2026-06-08T03:02:39.8766667' AS DateTime2))
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (13, N'Hieu pham', 0x0200000060949EE0EAE059359234FDA32F0685876F2872F89751BF465FE4C5F9EF2DD10BED63F17457DF476DAAAACAE558F3F2645A41BD48CC6594D3D0FD5E9DF57CF173, N'$2a$12$irGZuGehMx73Vj6w.9kRaO/XhHMWHmO4gNfGi6y0XwvD/1gGT.1gi', 0x020000000FB5F51B2D8D54F13EB21FE545D653255123B80D33A20166F95FA2DDAE0D30714EED4703E3F132455B2BBF11C7164324, 5, N'Inactive', NULL, 1, NULL, N'local', N'rgy75796@laoia.com', 1, CAST(N'2026-06-10T11:19:24.3466667' AS DateTime2))
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (14, N'thuy bui', 0x02000000F91788F6D330BBE20FE51DBCBF246CB9E6E248821C8F34E536C9D1087B16F854D799FB8CAA2E01F9821F713CF2119403F734B156B1AAB2AD96547D6B75664A3B, N'$2a$12$wm0aX1SRAYuTxtmETzYKhuZ2l5ZJ5BtQEFXoT7WvU3M.ZeQVZ9PZG', 0x02000000454B1F4621FF300A05A0D225B9DDE6861408E78B2DDA4DD27121050EA9414704D767198A9AE76172C07F8505E5F0A674, 5, N'Active', N'866f894c-1cc6-4157-9931-47298a68a521', 0, NULL, N'local', N'rgy757965@laoia.com', 0, CAST(N'2026-06-09T19:08:29.5566667' AS DateTime2))
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (15, N'Tran Quang Duc (K18 HL)', 0x02000000A931D1E99A38128453EF493DFE55CF5475D4CD67838E2158E11E2B71972E36C2C0B33B04A7C1D64D8844B85E18BC4AEEE7D9848E5FFEEFE40087294AF8695BDB112D63975022F68168A67FEB2971B354, NULL, 0x0200000069531C254A3D2B73E0BF72C4639CFE74B4A9AF40ECBFCC47F330D25FC3EFB6231D1CAC40C1BA95AAE326DC3AB6C1CF92, 2, N'Inactive', NULL, 1, N'114690907459202692756', N'google', N'ductqhe181164@fpt.edu.vn', 1, CAST(N'2026-06-10T11:25:51.7400000' AS DateTime2))
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (16, N'Phạm Trung Hiếu', 0x02000000FB4B7D021B11380E530364C1F9A5254BC8285DD3D67C2640F1AC3F18B111CE4630F12BB43FCCD99665DBC6DCE1F99A762FFF511F11C72DB4667F69BDF282285971B80599E39B70A6BACED79230CC555D, N'$2a$12$EEMO7pEblXxRp2KnOHEp7O5wYH0lfIyAt.ie699nc.tDGTwuAtt0.', 0x0200000055673BA86D102A145E9B0898316D9EC3A0DA723D110FF2DC144C5AF1401926D78CF66D8401DB060F738A17198910A50B, 1, N'Active', NULL, 1, N'101199833005616986329', N'google', N'hieupthe182418@fpt.edu.vn', 0, CAST(N'2026-06-10T10:52:45.0566667' AS DateTime2))
INSERT [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role_id], [status], [verification_token], [is_verified], [google_id], [auth_provider], [username], [is_deleted], [updated_at]) VALUES (17, N'khangnd', 0x02000000E8B3690DF9C66077768B4CCF9DFA45599682BAA7E5C90B07880A6143CE4FFC37B3697712D615C6542D984B977FF74FB9F4910FF92266A413EDD334B2AFFEBDA39403E0B38132C1230277C9B47F6DE619, N'$2a$12$bpy52KJs0/rX6h/jAjwBfu1ddjQzMi0I99RuVAgJzUltV6M.FNe76', 0x02000000FED9EF57AB2FD6D5CF1F28476577CE89785F200343D11BA1983B43044FED6250B5293A6CF0F433D05A0D4B96467DC216, 3, N'Active', NULL, 1, NULL, N'local', N'nguyendangkheng@gmail.com', 0, CAST(N'2026-06-14T11:28:00.4700000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[users] OFF
GO
/****** Object:  Index [UQ__doctors__B9BE370E1435ABC2]    Script Date: 6/14/2026 10:28:53 PM ******/
ALTER TABLE [dbo].[doctors] ADD UNIQUE NONCLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_medicines_code]    Script Date: 6/14/2026 10:28:53 PM ******/
ALTER TABLE [dbo].[medicines] ADD  CONSTRAINT [UQ_medicines_code] UNIQUE NONCLUSTERED 
(
	[medicine_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_password_reset_tokens_token]    Script Date: 6/14/2026 10:28:53 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_password_reset_tokens_token] ON [dbo].[password_reset_tokens]
(
	[token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__patients__B9BE370E81220E32]    Script Date: 6/14/2026 10:28:53 PM ******/
ALTER TABLE [dbo].[patients] ADD UNIQUE NONCLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_permissions_key]    Script Date: 6/14/2026 10:28:53 PM ******/
ALTER TABLE [dbo].[permissions] ADD  CONSTRAINT [UQ_permissions_key] UNIQUE NONCLUSTERED 
(
	[permission_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_roles_role_name]    Script Date: 6/14/2026 10:28:53 PM ******/
ALTER TABLE [dbo].[roles] ADD  CONSTRAINT [UQ_roles_role_name] UNIQUE NONCLUSTERED 
(
	[role_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_service_categories_category_name]    Script Date: 6/14/2026 10:28:53 PM ******/
ALTER TABLE [dbo].[service_categories] ADD  CONSTRAINT [UQ_service_categories_category_name] UNIQUE NONCLUSTERED 
(
	[category_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_services_code]    Script Date: 6/14/2026 10:28:53 PM ******/
ALTER TABLE [dbo].[services] ADD  CONSTRAINT [UQ_services_code] UNIQUE NONCLUSTERED 
(
	[service_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__sonograp__B9BE370EC5379943]    Script Date: 6/14/2026 10:28:53 PM ******/
ALTER TABLE [dbo].[sonographers] ADD UNIQUE NONCLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_users_username]    Script Date: 6/14/2026 10:28:53 PM ******/
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [UQ_users_username] UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_users_google_id]    Script Date: 6/14/2026 10:28:53 PM ******/
CREATE NONCLUSTERED INDEX [IX_users_google_id] ON [dbo].[users]
(
	[google_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_users_google_id]    Script Date: 6/14/2026 10:28:53 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_users_google_id] ON [dbo].[users]
(
	[google_id] ASC
)
WHERE ([google_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[audit_logs] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[lab_results] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[medical_records] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[medicine_categories] ADD  DEFAULT ((0)) FOR [sort_order]
GO
ALTER TABLE [dbo].[medicine_categories] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[medicine_categories] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[medicine_categories] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[medicine_price_history] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[medicines] ADD  DEFAULT ((0)) FOR [stock_quantity]
GO
ALTER TABLE [dbo].[medicines] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[medicines] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[medicines] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[notifications] ADD  DEFAULT ((0)) FOR [is_read]
GO
ALTER TABLE [dbo].[notifications] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[password_reset_tokens] ADD  DEFAULT ((0)) FOR [is_used]
GO
ALTER TABLE [dbo].[password_reset_tokens] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[permissions] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[prescriptions] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[price_history] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[reviews] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[role_permissions] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[service_categories] ADD  DEFAULT ((0)) FOR [sort_order]
GO
ALTER TABLE [dbo].[service_categories] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[service_categories] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[service_categories] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[services] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[services] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[services] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[test_orders] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ((0)) FOR [is_verified]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ('local') FOR [auth_provider]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ((0)) FOR [is_deleted]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([id])
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([id])
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD FOREIGN KEY([pregnancy_id])
REFERENCES [dbo].[pregnancies] ([id])
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD FOREIGN KEY([service_id])
REFERENCES [dbo].[services] ([id])
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [fk_appointments_doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([id])
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [fk_appointments_doctor]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [fk_appointments_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([id])
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [fk_appointments_patient]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [fk_appointments_pregnancy] FOREIGN KEY([pregnancy_id])
REFERENCES [dbo].[pregnancies] ([id])
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [fk_appointments_pregnancy]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [fk_appointments_service] FOREIGN KEY([service_id])
REFERENCES [dbo].[services] ([id])
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [fk_appointments_service]
GO
ALTER TABLE [dbo].[audit_logs]  WITH CHECK ADD  CONSTRAINT [FK_audit_logs_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[audit_logs] CHECK CONSTRAINT [FK_audit_logs_users]
GO
ALTER TABLE [dbo].[doctor_schedules]  WITH CHECK ADD FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([id])
GO
ALTER TABLE [dbo].[doctor_schedules]  WITH CHECK ADD  CONSTRAINT [fk_doctor_schedules_doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([id])
GO
ALTER TABLE [dbo].[doctor_schedules] CHECK CONSTRAINT [fk_doctor_schedules_doctor]
GO
ALTER TABLE [dbo].[doctors]  WITH CHECK ADD  CONSTRAINT [FK_doctors_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[doctors] CHECK CONSTRAINT [FK_doctors_users]
GO
ALTER TABLE [dbo].[invoice_items]  WITH CHECK ADD FOREIGN KEY([invoice_id])
REFERENCES [dbo].[invoices] ([id])
GO
ALTER TABLE [dbo].[invoice_items]  WITH CHECK ADD  CONSTRAINT [fk_invoice_items_invoice] FOREIGN KEY([invoice_id])
REFERENCES [dbo].[invoices] ([id])
GO
ALTER TABLE [dbo].[invoice_items] CHECK CONSTRAINT [fk_invoice_items_invoice]
GO
ALTER TABLE [dbo].[invoices]  WITH CHECK ADD FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([id])
GO
ALTER TABLE [dbo].[invoices]  WITH CHECK ADD  CONSTRAINT [fk_invoices_appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([id])
GO
ALTER TABLE [dbo].[invoices] CHECK CONSTRAINT [fk_invoices_appointment]
GO
ALTER TABLE [dbo].[lab_results]  WITH CHECK ADD FOREIGN KEY([service_id])
REFERENCES [dbo].[services] ([id])
GO
ALTER TABLE [dbo].[lab_results]  WITH CHECK ADD FOREIGN KEY([test_order_id])
REFERENCES [dbo].[test_orders] ([id])
GO
ALTER TABLE [dbo].[lab_results]  WITH CHECK ADD  CONSTRAINT [fk_lab_results_service] FOREIGN KEY([service_id])
REFERENCES [dbo].[services] ([id])
GO
ALTER TABLE [dbo].[lab_results] CHECK CONSTRAINT [fk_lab_results_service]
GO
ALTER TABLE [dbo].[lab_results]  WITH CHECK ADD  CONSTRAINT [fk_lab_results_test_order] FOREIGN KEY([test_order_id])
REFERENCES [dbo].[test_orders] ([id])
GO
ALTER TABLE [dbo].[lab_results] CHECK CONSTRAINT [fk_lab_results_test_order]
GO
ALTER TABLE [dbo].[medical_records]  WITH CHECK ADD FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([id])
GO
ALTER TABLE [dbo].[medical_records]  WITH CHECK ADD  CONSTRAINT [fk_medical_records_appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([id])
GO
ALTER TABLE [dbo].[medical_records] CHECK CONSTRAINT [fk_medical_records_appointment]
GO
ALTER TABLE [dbo].[medicine_price_history]  WITH CHECK ADD  CONSTRAINT [FK_medprice_history_medicine] FOREIGN KEY([medicine_id])
REFERENCES [dbo].[medicines] ([id])
GO
ALTER TABLE [dbo].[medicine_price_history] CHECK CONSTRAINT [FK_medprice_history_medicine]
GO
ALTER TABLE [dbo].[medicine_price_history]  WITH CHECK ADD  CONSTRAINT [FK_medprice_history_user] FOREIGN KEY([changed_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[medicine_price_history] CHECK CONSTRAINT [FK_medprice_history_user]
GO
ALTER TABLE [dbo].[medicines]  WITH CHECK ADD  CONSTRAINT [FK_medicines_category] FOREIGN KEY([category_id])
REFERENCES [dbo].[medicine_categories] ([id])
GO
ALTER TABLE [dbo].[medicines] CHECK CONSTRAINT [FK_medicines_category]
GO
ALTER TABLE [dbo].[notifications]  WITH CHECK ADD  CONSTRAINT [FK_notifications_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[notifications] CHECK CONSTRAINT [FK_notifications_users]
GO
ALTER TABLE [dbo].[password_reset_tokens]  WITH CHECK ADD  CONSTRAINT [FK_password_reset_tokens_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[password_reset_tokens] CHECK CONSTRAINT [FK_password_reset_tokens_users]
GO
ALTER TABLE [dbo].[patients]  WITH CHECK ADD  CONSTRAINT [FK_patients_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[patients] CHECK CONSTRAINT [FK_patients_users]
GO
ALTER TABLE [dbo].[pregnancies]  WITH CHECK ADD FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([id])
GO
ALTER TABLE [dbo].[pregnancies]  WITH CHECK ADD  CONSTRAINT [fk_pregnancies_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([id])
GO
ALTER TABLE [dbo].[pregnancies] CHECK CONSTRAINT [fk_pregnancies_patient]
GO
ALTER TABLE [dbo].[prescription_items]  WITH CHECK ADD FOREIGN KEY([medicine_id])
REFERENCES [dbo].[medicines] ([id])
GO
ALTER TABLE [dbo].[prescription_items]  WITH CHECK ADD FOREIGN KEY([prescription_id])
REFERENCES [dbo].[prescriptions] ([id])
GO
ALTER TABLE [dbo].[prescription_items]  WITH CHECK ADD  CONSTRAINT [fk_prescription_items_medicine] FOREIGN KEY([medicine_id])
REFERENCES [dbo].[medicines] ([id])
GO
ALTER TABLE [dbo].[prescription_items] CHECK CONSTRAINT [fk_prescription_items_medicine]
GO
ALTER TABLE [dbo].[prescription_items]  WITH CHECK ADD  CONSTRAINT [fk_prescription_items_prescription] FOREIGN KEY([prescription_id])
REFERENCES [dbo].[prescriptions] ([id])
GO
ALTER TABLE [dbo].[prescription_items] CHECK CONSTRAINT [fk_prescription_items_prescription]
GO
ALTER TABLE [dbo].[prescriptions]  WITH CHECK ADD FOREIGN KEY([medical_record_id])
REFERENCES [dbo].[medical_records] ([id])
GO
ALTER TABLE [dbo].[prescriptions]  WITH CHECK ADD  CONSTRAINT [fk_prescriptions_medical_record] FOREIGN KEY([medical_record_id])
REFERENCES [dbo].[medical_records] ([id])
GO
ALTER TABLE [dbo].[prescriptions] CHECK CONSTRAINT [fk_prescriptions_medical_record]
GO
ALTER TABLE [dbo].[price_history]  WITH CHECK ADD  CONSTRAINT [FK_price_history_service] FOREIGN KEY([service_id])
REFERENCES [dbo].[services] ([id])
GO
ALTER TABLE [dbo].[price_history] CHECK CONSTRAINT [FK_price_history_service]
GO
ALTER TABLE [dbo].[price_history]  WITH CHECK ADD  CONSTRAINT [FK_price_history_user] FOREIGN KEY([changed_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[price_history] CHECK CONSTRAINT [FK_price_history_user]
GO
ALTER TABLE [dbo].[reviews]  WITH CHECK ADD FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([id])
GO
ALTER TABLE [dbo].[reviews]  WITH CHECK ADD  CONSTRAINT [fk_reviews_appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([id])
GO
ALTER TABLE [dbo].[reviews] CHECK CONSTRAINT [fk_reviews_appointment]
GO
ALTER TABLE [dbo].[role_permissions]  WITH CHECK ADD  CONSTRAINT [FK_role_permissions_perm] FOREIGN KEY([permission_id])
REFERENCES [dbo].[permissions] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[role_permissions] CHECK CONSTRAINT [FK_role_permissions_perm]
GO
ALTER TABLE [dbo].[role_permissions]  WITH CHECK ADD  CONSTRAINT [FK_role_permissions_role] FOREIGN KEY([role_id])
REFERENCES [dbo].[roles] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[role_permissions] CHECK CONSTRAINT [FK_role_permissions_role]
GO
ALTER TABLE [dbo].[services]  WITH CHECK ADD FOREIGN KEY([category_id])
REFERENCES [dbo].[service_categories] ([id])
GO
ALTER TABLE [dbo].[services]  WITH CHECK ADD  CONSTRAINT [fk_services_category] FOREIGN KEY([category_id])
REFERENCES [dbo].[service_categories] ([id])
GO
ALTER TABLE [dbo].[services] CHECK CONSTRAINT [fk_services_category]
GO
ALTER TABLE [dbo].[sonographers]  WITH CHECK ADD  CONSTRAINT [FK_sonographers_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[sonographers] CHECK CONSTRAINT [FK_sonographers_users]
GO
ALTER TABLE [dbo].[test_orders]  WITH CHECK ADD FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([id])
GO
ALTER TABLE [dbo].[test_orders]  WITH CHECK ADD FOREIGN KEY([medical_record_id])
REFERENCES [dbo].[medical_records] ([id])
GO
ALTER TABLE [dbo].[test_orders]  WITH CHECK ADD FOREIGN KEY([service_id])
REFERENCES [dbo].[services] ([id])
GO
ALTER TABLE [dbo].[test_orders]  WITH CHECK ADD  CONSTRAINT [fk_test_orders_doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([id])
GO
ALTER TABLE [dbo].[test_orders] CHECK CONSTRAINT [fk_test_orders_doctor]
GO
ALTER TABLE [dbo].[test_orders]  WITH CHECK ADD  CONSTRAINT [fk_test_orders_medical_record] FOREIGN KEY([medical_record_id])
REFERENCES [dbo].[medical_records] ([id])
GO
ALTER TABLE [dbo].[test_orders] CHECK CONSTRAINT [fk_test_orders_medical_record]
GO
ALTER TABLE [dbo].[test_orders]  WITH CHECK ADD  CONSTRAINT [fk_test_orders_service] FOREIGN KEY([service_id])
REFERENCES [dbo].[services] ([id])
GO
ALTER TABLE [dbo].[test_orders] CHECK CONSTRAINT [fk_test_orders_service]
GO
ALTER TABLE [dbo].[ultrasound_results]  WITH CHECK ADD FOREIGN KEY([medical_record_id])
REFERENCES [dbo].[medical_records] ([id])
GO
ALTER TABLE [dbo].[ultrasound_results]  WITH CHECK ADD FOREIGN KEY([sonographer_id])
REFERENCES [dbo].[sonographers] ([id])
GO
ALTER TABLE [dbo].[ultrasound_results]  WITH CHECK ADD  CONSTRAINT [fk_ultrasound_results_medical_record] FOREIGN KEY([medical_record_id])
REFERENCES [dbo].[medical_records] ([id])
GO
ALTER TABLE [dbo].[ultrasound_results] CHECK CONSTRAINT [fk_ultrasound_results_medical_record]
GO
ALTER TABLE [dbo].[ultrasound_results]  WITH CHECK ADD  CONSTRAINT [fk_ultrasound_results_sonographer] FOREIGN KEY([sonographer_id])
REFERENCES [dbo].[sonographers] ([id])
GO
ALTER TABLE [dbo].[ultrasound_results] CHECK CONSTRAINT [fk_ultrasound_results_sonographer]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD FOREIGN KEY([role_id])
REFERENCES [dbo].[roles] ([id])
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [fk_users_role] FOREIGN KEY([role_id])
REFERENCES [dbo].[roles] ([id])
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [fk_users_role]
GO
USE [master]
GO
ALTER DATABASE [ObstetricsClinicDB] SET  READ_WRITE 
GO
