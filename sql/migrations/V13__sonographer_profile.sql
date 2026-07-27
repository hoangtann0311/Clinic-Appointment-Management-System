/* ============================================================================
   V13 — Hồ Sơ Cá Nhân cho vai trò Bác sĩ siêu âm (role_id = 6)
   ----------------------------------------------------------------------------
   Phương án PA-2: dùng bảng sonographers đã có sẵn, KHÔNG dùng bảng doctors.
   Lý do: tránh làm bác sĩ siêu âm lọt vào danh sách bác sĩ khám của lễ tân
   (DoctorDAO.getAllDoctors / getDoctorsPaginated / countDoctors không lọc role_id).

   Cột đã có sẵn, KHÔNG tạo lại:
     sonographers.qualification     NVARCHAR(100)  → chứng chỉ siêu âm
     sonographers.experience_years  INT            → số năm kinh nghiệm
     users.full_name / users.phone                 → họ tên, số điện thoại

   Cột thêm mới ở script này (tất cả đều cho phép NULL):
     sonographers.specialization    NVARCHAR(100)
     sonographers.degree            NVARCHAR(100)
     sonographers.bio               NVARCHAR(MAX)
     sonographers.avatar_url        NVARCHAR(500)

   KHÔNG đụng tới: room_no, status (ngoài phạm vi đã duyệt).
   Chạy lại nhiều lần vẫn an toàn (idempotent).
   ============================================================================ */

BEGIN TRANSACTION;

-- ── 1. Bốn cột mới, đều NULL được ──────────────────────────────────────────
IF COL_LENGTH('sonographers', 'specialization') IS NULL
    ALTER TABLE sonographers ADD specialization NVARCHAR(100) NULL;

IF COL_LENGTH('sonographers', 'degree') IS NULL
    ALTER TABLE sonographers ADD degree NVARCHAR(100) NULL;

IF COL_LENGTH('sonographers', 'bio') IS NULL
    ALTER TABLE sonographers ADD bio NVARCHAR(MAX) NULL;

IF COL_LENGTH('sonographers', 'avatar_url') IS NULL
    ALTER TABLE sonographers ADD avatar_url NVARCHAR(500) NULL;

-- ── 2. Cấp dòng sonographers cho tài khoản vai trò 6 chưa có ───────────────
-- Màn Quản Lý Người Dùng (UserService.createUser) không tạo dòng mở rộng cho
-- role 6, nên các tài khoản tạo trước đây bị thiếu. UNIQUE trên user_id đã tồn
-- tại sẵn (UQ__sonograp__B9BE370E708195D7) nên câu này chạy lại vẫn an toàn.
INSERT INTO sonographers (user_id, status)
SELECT u.id, 'Active'
FROM users u
WHERE u.role_id = 6
  AND ISNULL(u.is_deleted, 0) = 0
  AND NOT EXISTS (SELECT 1 FROM sonographers s WHERE s.user_id = u.id);

COMMIT;
GO

-- ── Kiểm chứng sau khi chạy ────────────────────────────────────────────────
-- BẮT BUỘC nằm sau GO. SQL Server bind toàn bộ một batch trước khi thực thi,
-- nên nếu câu SELECT này ở chung batch với ALTER TABLE ở trên, nó sẽ báo
-- "Invalid column name" và làm hỏng cả batch — không cột nào được thêm.
SELECT u.id AS user_id, u.role_id, s.id AS sonographer_id,
       s.qualification, s.specialization, s.degree, s.avatar_url
FROM users u
LEFT JOIN sonographers s ON s.user_id = u.id
WHERE u.role_id = 6;
GO
