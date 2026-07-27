/* ============================================================================
   V14 — HOÀN TÁC
   ----------------------------------------------------------------------------
   CẢNH BÁO: hai câu DROP COLUMN sẽ xoá vĩnh viễn dữ liệu bộ phận và chức danh
   của mọi tài khoản. Sao lưu trước khi chạy.

   Script này KHÔNG xoá dòng users nào — V14 chỉ thêm cột, không thêm dòng.
   ============================================================================ */

BEGIN TRANSACTION;

IF COL_LENGTH('users', 'job_title')  IS NOT NULL
    ALTER TABLE users DROP COLUMN job_title;

IF COL_LENGTH('users', 'department') IS NOT NULL
    ALTER TABLE users DROP COLUMN department;

COMMIT;
GO
