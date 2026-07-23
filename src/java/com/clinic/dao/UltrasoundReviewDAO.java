package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.AiAnalysisResult;
import com.clinic.model.UltrasoundAnnotation;
import com.clinic.model.UltrasoundReport;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;

/** Persistence boundary for the reviewed annotation and signed ultrasound report. */
public class UltrasoundReviewDAO {

    private static volatile Boolean schemaSupported;

    public boolean isSchemaSupported() {
        Boolean cached = schemaSupported;
        if (cached != null) return cached;
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT CASE WHEN OBJECT_ID(N'dbo.ultrasound_annotations', N'U') IS NOT NULL "
                             + "AND OBJECT_ID(N'dbo.ultrasound_reports', N'U') IS NOT NULL THEN 1 ELSE 0 END");
             ResultSet rs = ps.executeQuery()) {
            schemaSupported = rs.next() && rs.getInt(1) == 1;
        } catch (SQLException e) {
            schemaSupported = false;
        }
        return schemaSupported;
    }

    public UltrasoundAnnotation getCurrentAnnotation(int orderId) {
        if (!isSchemaSupported()) return null;
        String sql = "SELECT TOP 1 * FROM ultrasound_annotations WHERE order_id = ? AND is_current = 1 ORDER BY version DESC, id DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapAnnotation(rs) : null;
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundReviewDAO] Không thể đọc vùng duyệt siêu âm: " + e.getMessage());
            return null;
        }
    }

    public UltrasoundReport getCurrentReport(int orderId) {
        if (!isSchemaSupported()) return null;
        String sql = "SELECT TOP 1 * FROM ultrasound_reports WHERE test_order_id = ? AND is_current = 1 ORDER BY version DESC, id DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapReport(rs) : null;
            }
        } catch (SQLException e) {
            System.err.println("[UltrasoundReviewDAO] Không thể đọc phiếu siêu âm: " + e.getMessage());
            return null;
        }
    }

    /**
     * Stores a new immutable review/report version. A signed save atomically moves
     * the order Uploaded -> Completed; a draft leaves the clinical state unchanged.
     */
    public boolean saveReviewAndReport(int orderId, int actorUserId, String signedName,
                                       int imageId, String annotationSource, String annotationType,
                                       String annotationData, Integer acceptedAiResultId,
                                       int imageWidth, int imageHeight,
                                       String reviewStatus, String rejectionReason,
                                       String imageDescription, String professionalFindings,
                                       String conclusion, boolean sign) {
        if (!isSchemaSupported()) return false;

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            String state = lockOwnedOrder(conn, orderId, actorUserId);
            if (!"Uploaded".equalsIgnoreCase(state)) {
                conn.rollback();
                return false;
            }
            StoredImageBinding storedImage = getImageForOrder(conn, imageId, orderId);
            if (storedImage == null || storedImage.width <= 0 || storedImage.height <= 0) {
                conn.rollback();
                return false;
            }
            imageWidth = storedImage.width;
            imageHeight = storedImage.height;

            if ("Accepted".equals(reviewStatus)) {
                AiAnalysisResult ai = new AiAnalysisResultDAO()
                        .getSuccessfulByImagePath(conn, orderId, storedImage.filePath);
                if (!"AI".equals(annotationSource) || acceptedAiResultId == null
                        || ai == null || ai.getId() != acceptedAiResultId
                        || !hasValidBoundingBox(ai, imageWidth, imageHeight)) {
                    conn.rollback();
                    return false;
                }
                // The accepted annotation is rebuilt from the locked AI row, never from client data.
                annotationSource = "AI";
                annotationType = "BoundingBox";
                annotationData = normalizedBoundingBox(ai, imageWidth, imageHeight);
            }

            int annotationVersion = nextVersion(conn, "ultrasound_annotations", orderId);
            int reportVersion = nextVersion(conn, "ultrasound_reports", orderId);
            clearCurrent(conn, "ultrasound_annotations", orderId);
            clearCurrent(conn, "ultrasound_reports", orderId);

            String annotationSql = "INSERT INTO ultrasound_annotations "
                    + "(order_id, image_id, annotation_source, annotation_type, annotation_data, "
                    + "image_width, image_height, review_status, rejection_reason, version, is_current, created_by, "
                    + "reviewed_by, reviewed_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, SYSUTCDATETIME())";
            try (PreparedStatement ps = conn.prepareStatement(annotationSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, imageId);
                ps.setString(3, annotationSource);
                ps.setString(4, annotationType);
                ps.setString(5, annotationData);
                ps.setInt(6, imageWidth);
                ps.setInt(7, imageHeight);
                ps.setString(8, reviewStatus);
                ps.setString(9, rejectionReason);
                ps.setInt(10, annotationVersion);
                ps.setInt(11, actorUserId);
                ps.setInt(12, actorUserId);
                if (ps.executeUpdate() != 1) throw new SQLException("Không lưu được vùng duyệt.");
            }

            String reportSql = "INSERT INTO ultrasound_reports "
                    + "(test_order_id, version, image_description, professional_findings, conclusion, report_status, "
                    + "is_current, created_by, signed_by_user_id, signed_name, signed_at) "
                    + "VALUES (?, ?, ?, ?, ?, ?, 1, ?, ?, ?, CASE WHEN ? = 1 THEN SYSUTCDATETIME() ELSE NULL END)";
            try (PreparedStatement ps = conn.prepareStatement(reportSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, reportVersion);
                ps.setString(3, imageDescription);
                ps.setString(4, professionalFindings);
                ps.setString(5, conclusion);
                ps.setString(6, sign ? "Signed" : "Draft");
                ps.setInt(7, actorUserId);
                if (sign) ps.setInt(8, actorUserId); else ps.setNull(8, java.sql.Types.INTEGER);
                ps.setString(9, sign ? signedName : null);
                ps.setInt(10, sign ? 1 : 0);
                if (ps.executeUpdate() != 1) throw new SQLException("Không lưu được phiếu kết quả.");
            }

            if (sign) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE test_orders SET status = 'Completed' WHERE id = ? AND sonographer_user_id = ? "
                                + "AND UPPER(LTRIM(RTRIM(ISNULL(status, '')))) = 'UPLOADED'")) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, actorUserId);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) { }
            System.err.println("[UltrasoundReviewDAO] Không thể lưu duyệt/phiếu siêu âm: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) { }
            }
            DatabaseConfig.closeConnection(conn);
        }
    }

    /** Doctor confirmation is allowed only for a signed current report on a Completed order. */
    public boolean confirmSignedReport(int orderId, int doctorUserId, String doctorNotes) {
        if (!isSchemaSupported()) return false;
        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            String lockSql = "SELECT o.status FROM test_orders o WITH (UPDLOCK, ROWLOCK) "
                    + "JOIN doctors d ON d.id = o.doctor_id WHERE o.id = ? AND d.user_id = ?";
            String status = null;
            try (PreparedStatement ps = conn.prepareStatement(lockSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, doctorUserId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) status = rs.getString(1); }
            }
            if (!"Completed".equalsIgnoreCase(status)) {
                conn.rollback();
                return false;
            }

            String reportSql = "UPDATE ultrasound_reports SET doctor_confirmed_by = ?, "
                    + "doctor_confirmed_at = SYSUTCDATETIME(), doctor_review_notes = ? "
                    + "WHERE test_order_id = ? AND is_current = 1 AND report_status = 'Signed' "
                    + "AND doctor_confirmed_at IS NULL";
            try (PreparedStatement ps = conn.prepareStatement(reportSql)) {
                ps.setInt(1, doctorUserId);
                ps.setString(2, doctorNotes);
                ps.setInt(3, orderId);
                if (ps.executeUpdate() != 1) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE test_orders SET status = 'Confirmed' WHERE id = ? "
                            + "AND UPPER(LTRIM(RTRIM(ISNULL(status, '')))) = 'COMPLETED'")) {
                ps.setInt(1, orderId);
                if (ps.executeUpdate() != 1) {
                    conn.rollback();
                    return false;
                }
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) { }
            System.err.println("[UltrasoundReviewDAO] Không thể xác nhận phiếu siêu âm: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); } catch (SQLException ignored) { }
            DatabaseConfig.closeConnection(conn);
        }
    }

    private String lockOwnedOrder(Connection conn, int orderId, int actorUserId) throws SQLException {
        String sql = "SELECT status FROM test_orders WITH (UPDLOCK, ROWLOCK) WHERE id = ? AND sonographer_user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, actorUserId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getString(1) : null; }
        }
    }

    private StoredImageBinding getImageForOrder(Connection conn, int imageId, int orderId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT file_path, image_width, image_height FROM ultrasound_images WITH (UPDLOCK, HOLDLOCK) "
                        + "WHERE id = ? AND test_order_id = ?")) {
            ps.setInt(1, imageId);
            ps.setInt(2, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                int width = rs.getInt("image_width");
                if (rs.wasNull()) return null;
                int height = rs.getInt("image_height");
                if (rs.wasNull()) return null;
                return new StoredImageBinding(rs.getString("file_path"), width, height);
            }
        }
    }

    private boolean hasValidBoundingBox(AiAnalysisResult ai, int width, int height) {
        Integer x1 = ai.getXmin(), y1 = ai.getYmin(), x2 = ai.getXmax(), y2 = ai.getymax();
        return ai.isDetected() && x1 != null && y1 != null && x2 != null && y2 != null
                && x1 >= 0 && y1 >= 0 && x2 > x1 && y2 > y1
                && x2 <= width && y2 <= height;
    }

    private String normalizedBoundingBox(AiAnalysisResult ai, int width, int height) {
        return String.format(java.util.Locale.ROOT,
                "{\"xMin\":%.6f,\"yMin\":%.6f,\"xMax\":%.6f,\"yMax\":%.6f}",
                ai.getXmin() / (double) width, ai.getYmin() / (double) height,
                ai.getXmax() / (double) width, ai.getymax() / (double) height);
    }

    private static final class StoredImageBinding {
        private final String filePath;
        private final int width;
        private final int height;

        private StoredImageBinding(String filePath, int width, int height) {
            this.filePath = filePath;
            this.width = width;
            this.height = height;
        }
    }

    private int nextVersion(Connection conn, String table, int orderId) throws SQLException {
        if (!"ultrasound_annotations".equals(table) && !"ultrasound_reports".equals(table)) {
            throw new IllegalArgumentException("Bảng phiên bản không hợp lệ.");
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT ISNULL(MAX(version), 0) + 1 FROM " + table + " WITH (UPDLOCK, HOLDLOCK) WHERE "
                        + ("ultrasound_annotations".equals(table) ? "order_id" : "test_order_id") + " = ?")) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) { rs.next(); return rs.getInt(1); }
        }
    }

    private void clearCurrent(Connection conn, String table, int orderId) throws SQLException {
        if (!"ultrasound_annotations".equals(table) && !"ultrasound_reports".equals(table)) {
            throw new IllegalArgumentException("Bảng phiên bản không hợp lệ.");
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE " + table + " SET is_current = 0"
                        + ("ultrasound_annotations".equals(table) ? ", updated_at = SYSUTCDATETIME()" : "")
                        + " WHERE " + ("ultrasound_annotations".equals(table) ? "order_id" : "test_order_id")
                        + " = ? AND is_current = 1")) {
            ps.setInt(1, orderId);
            ps.executeUpdate();
        }
    }

    private UltrasoundAnnotation mapAnnotation(ResultSet rs) throws SQLException {
        UltrasoundAnnotation a = new UltrasoundAnnotation();
        a.setId(rs.getLong("id"));
        a.setTestOrderId(rs.getInt("order_id"));
        a.setUltrasoundImageId(rs.getInt("image_id"));
        a.setAnnotationSource(rs.getString("annotation_source"));
        a.setAnnotationType(rs.getString("annotation_type"));
        a.setAnnotationData(rs.getString("annotation_data"));
        a.setImageWidth(rs.getInt("image_width"));
        a.setImageHeight(rs.getInt("image_height"));
        a.setReviewStatus(rs.getString("review_status"));
        a.setRejectionReason(rs.getString("rejection_reason"));
        a.setVersion(rs.getInt("version"));
        a.setCurrent(rs.getBoolean("is_current"));
        a.setCreatedBy(rs.getInt("created_by"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        int reviewed = rs.getInt("reviewed_by");
        a.setReviewedBy(rs.wasNull() ? null : reviewed);
        a.setReviewedAt(rs.getTimestamp("reviewed_at"));
        return a;
    }

    private UltrasoundReport mapReport(ResultSet rs) throws SQLException {
        UltrasoundReport r = new UltrasoundReport();
        r.setId(rs.getLong("id"));
        r.setTestOrderId(rs.getInt("test_order_id"));
        r.setVersion(rs.getInt("version"));
        r.setImageDescription(rs.getString("image_description"));
        r.setProfessionalFindings(rs.getString("professional_findings"));
        r.setConclusion(rs.getString("conclusion"));
        r.setReportStatus(rs.getString("report_status"));
        r.setCurrent(rs.getBoolean("is_current"));
        r.setCreatedBy(rs.getInt("created_by"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        int signedBy = rs.getInt("signed_by_user_id");
        r.setSignedByUserId(rs.wasNull() ? null : signedBy);
        r.setSignedName(rs.getString("signed_name"));
        r.setSignedAt(rs.getTimestamp("signed_at"));
        int confirmedBy = rs.getInt("doctor_confirmed_by");
        r.setDoctorConfirmedBy(rs.wasNull() ? null : confirmedBy);
        r.setDoctorConfirmedAt(rs.getTimestamp("doctor_confirmed_at"));
        r.setDoctorReviewNotes(rs.getString("doctor_review_notes"));
        return r;
    }
}
