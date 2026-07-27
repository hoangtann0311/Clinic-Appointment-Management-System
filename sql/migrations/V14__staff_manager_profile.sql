/* ============================================================================
   V14 — Hồ Sơ Cá Nhân cho vai trò Nhân viên lễ tân (role_id = 4)
         và Quản lý (role_id = 3)
   ----------------------------------------------------------------------------
   Hai vai trò này KHÔNG có bảng mở rộng riêng — toàn bộ dữ liệu nằm ở users.

   Cột đã có sẵn, dùng lại, KHÔNG tạo mới:
     users.full_name  → họ tên          (sửa được)
     users.phone      → số điện thoại   (sửa được)
     users.email      → email           (chỉ xem)
     users.role_id    → vai trò         (chỉ xem)

   Cột thêm mới ở script này (đều cho phép NULL):
     users.department  NVARCHAR(100)  → bộ phận. Nhân viên VÀ Quản lý dùng chung
                                        đúng cột này, không tách hai cột.
     users.job_title   NVARCHAR(100)  → chức danh. Chỉ Nhân viên dùng.

   Cả hai đều là trường CHỈ-XEM trên trang hồ sơ: người dùng không tự sửa được.
   Chạy lại nhiều lần vẫn an toàn (idempotent).
   ============================================================================ */

BEGIN TRANSACTION;

IF COL_LENGTH('users', 'department') IS NULL
    ALTER TABLE users ADD department NVARCHAR(100) NULL;

IF COL_LENGTH('users', 'job_title') IS NULL
    ALTER TABLE users ADD job_title NVARCHAR(100) NULL;

COMMIT;
GO

-- ── Kiểm chứng ─────────────────────────────────────────────────────────────
-- BẮT BUỘC nằm sau GO: SQL Server bind cả batch trước khi thực thi, nên câu
-- SELECT tham chiếu cột vừa ALTER TABLE ADD sẽ làm hỏng batch nếu ở chung.
SELECT id, role_id, full_name, department, job_title
FROM users
WHERE role_id IN (3, 4) AND ISNULL(is_deleted, 0) = 0
ORDER BY role_id, id;
GO
