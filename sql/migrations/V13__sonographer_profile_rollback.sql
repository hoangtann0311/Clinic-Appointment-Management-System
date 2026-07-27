/* ============================================================================
   V13 — HOÀN TÁC
   ----------------------------------------------------------------------------
   CẢNH BÁO: 4 câu DROP COLUMN sẽ xoá vĩnh viễn dữ liệu chuyên khoa / học vị /
   giới thiệu / ảnh đại diện mà bác sĩ siêu âm đã nhập. Sao lưu trước khi chạy.

   Dòng sonographers do V13 sinh ra chỉ bị xoá khi vẫn còn rỗng hoàn toàn.
   user_id được ghim cứng để script không bao giờ chạm vào dòng của người khác.
   ============================================================================ */

BEGIN TRANSACTION;

-- ── 1. Xoá đúng dòng do backfill V13 sinh ra, và chỉ khi chưa ai nhập gì ──
-- Bọc trong sp_executesql để hoãn việc bind tên cột: nếu 4 cột của V13 chưa
-- tồn tại (hoàn tác một lần chạy dở), câu này vẫn không làm hỏng cả batch.
IF COL_LENGTH('sonographers', 'specialization') IS NOT NULL
   AND COL_LENGTH('sonographers', 'degree')     IS NOT NULL
   AND COL_LENGTH('sonographers', 'bio')        IS NOT NULL
   AND COL_LENGTH('sonographers', 'avatar_url') IS NOT NULL
BEGIN
    EXEC sp_executesql N'
        DELETE FROM sonographers
        WHERE user_id = 88
          AND status = ''Active''
          AND experience_years IS NULL
          AND qualification    IS NULL
          AND room_no          IS NULL
          AND specialization   IS NULL
          AND degree           IS NULL
          AND bio              IS NULL
          AND avatar_url       IS NULL;';
END

-- ── 2. Gỡ 4 cột đã thêm (thứ tự ngược với lúc tạo) ────────────────────────
IF COL_LENGTH('sonographers', 'avatar_url')     IS NOT NULL
    ALTER TABLE sonographers DROP COLUMN avatar_url;

IF COL_LENGTH('sonographers', 'bio')            IS NOT NULL
    ALTER TABLE sonographers DROP COLUMN bio;

IF COL_LENGTH('sonographers', 'degree')         IS NOT NULL
    ALTER TABLE sonographers DROP COLUMN degree;

IF COL_LENGTH('sonographers', 'specialization') IS NOT NULL
    ALTER TABLE sonographers DROP COLUMN specialization;

COMMIT;
