-- ============================================================
-- Script gop cac hoa don POST_EXAM trung lap cho cung 1 lich hen
-- (Chay 1 lan de don du lieu cu)
-- ============================================================

-- Buoc 1: Giu lai 1 hoa don (id nho nhat) va cong don tong tien vao do.
UPDATE invoices
SET total_amount = (
    SELECT SUM(total_amount)
    FROM invoices i2
    WHERE i2.appointment_id = invoices.appointment_id
      AND i2.invoice_type = 'POST_EXAM'
      AND i2.status &lt;&gt; 'Paid'
)
WHERE id IN (
    SELECT MIN(id)
    FROM invoices
    WHERE invoice_type = 'POST_EXAM'
      AND status &lt;&gt; 'Paid'
    GROUP BY appointment_id
    HAVING COUNT(*) > 1
);

-- Buoc 2: Xoa cac ban ghi POST_EXAM trung (giu lai id nho nhat moi nhom)
DELETE FROM invoices
WHERE invoice_type = 'POST_EXAM'
  AND status &lt;&gt; 'Paid'
  AND id NOT IN (
      SELECT MIN(id)
      FROM invoices
      WHERE invoice_type = 'POST_EXAM'
        AND status &lt;&gt; 'Paid'
      GROUP BY appointment_id
  );

-- Kiem tra ket qua sau khi gop:
SELECT appointment_id, COUNT(*) AS so_hoa_don, SUM(total_amount) AS tong_tien
FROM invoices
WHERE invoice_type = 'POST_EXAM'
GROUP BY appointment_id
ORDER BY appointment_id;
