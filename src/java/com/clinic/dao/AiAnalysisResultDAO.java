package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.AiAnalysisResult;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng ai_analysis_results.
 */
public class AiAnalysisResultDAO {

    /** Starts one AI run while holding the order row lock to reject duplicate submits. */
    public int beginRun(int orderId, String inputImage, long staleAfterMillis) {
        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement lock = conn.prepareStatement(
                    "SELECT status FROM test_orders WITH (UPDLOCK, ROWLOCK) WHERE id = ?")) {
                lock.setInt(1, orderId);
                try (ResultSet rs = lock.executeQuery()) {
                    if (!rs.next() || !"Uploaded".equalsIgnoreCase(rs.getString(1))) {
                        conn.rollback();
                        return -1;
                    }
                }
            }
            try (PreparedStatement latest = conn.prepareStatement(
                    "SELECT TOP 1 id, status, analyzed_at FROM ai_analysis_results "
                            + "WHERE test_order_id = ? ORDER BY analyzed_at DESC, id DESC")) {
                latest.setInt(1, orderId);
                try (ResultSet rs = latest.executeQuery()) {
                    if (rs.next() && "Analyzing".equalsIgnoreCase(rs.getString("status"))) {
                        Timestamp analyzedAt = rs.getTimestamp("analyzed_at");
                        long cutoff = System.currentTimeMillis() - Math.max(staleAfterMillis, 60_000L);
                        if (analyzedAt != null && analyzedAt.getTime() >= cutoff) {
                            conn.rollback();
                            return -1;
                        }
                        try (PreparedStatement stale = conn.prepareStatement(
                                "UPDATE ai_analysis_results SET status = 'Failed', "
                                        + "error_message = N'Phiên AI trước đã hết thời gian xử lý.', analyzed_at = CURRENT_TIMESTAMP "
                                        + "WHERE id = ? AND status = 'Analyzing'")) {
                            stale.setInt(1, rs.getInt("id"));
                            stale.executeUpdate();
                        }
                    }
                }
            }
            String sql = "INSERT INTO ai_analysis_results (test_order_id, status, detected, confidence, input_image, analyzed_at) "
                    + "VALUES (?, 'Analyzing', 0, 0, ?, CURRENT_TIMESTAMP)";
            try (PreparedStatement insert = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                insert.setInt(1, orderId);
                insert.setString(2, inputImage);
                if (insert.executeUpdate() != 1) {
                    conn.rollback();
                    return -1;
                }
                try (ResultSet keys = insert.getGeneratedKeys()) {
                    if (!keys.next()) {
                        conn.rollback();
                        return -1;
                    }
                    int id = keys.getInt(1);
                    conn.commit();
                    return id;
                }
            }
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) { }
            System.err.println("[AiAnalysisResultDAO] beginRun ERROR: " + e.getMessage());
            return -1;
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); } catch (SQLException ignored) { }
            DatabaseConfig.closeConnection(conn);
        }
    }

    public AiAnalysisResult getByTestOrderId(int testOrderId) {
        String sql = "SELECT TOP 1 * FROM ai_analysis_results WHERE test_order_id = ? "
                + "ORDER BY analyzed_at DESC, id DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, testOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapResult(rs) : null;
            }
        } catch (SQLException e) {
            System.err.println("[AiAnalysisResultDAO] getByTestOrderId ERROR: " + e.getMessage());
        }
        return null;
    }

    /**
     * Returns the latest successful AI run whose database input path identifies
     * exactly the selected ultrasound image path.
     */
    public AiAnalysisResult getSuccessfulByImagePath(int testOrderId, String imagePath) {
        try (Connection conn = DatabaseConfig.getConnection()) {
            return getSuccessfulByImagePath(conn, testOrderId, imagePath);
        } catch (SQLException e) {
            System.err.println("[AiAnalysisResultDAO] getSuccessfulByImagePath ERROR: " + e.getMessage());
            return null;
        }
    }

    /** Same lookup using the caller's transaction and locks. */
    AiAnalysisResult getSuccessfulByImagePath(Connection conn, int testOrderId,
                                               String imagePath) throws SQLException {
        String normalizedImagePath = normalizeRelativeImagePath(imagePath);
        if (conn == null || normalizedImagePath == null) return null;

        String sql = "SELECT * FROM ai_analysis_results WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE test_order_id = ? ORDER BY analyzed_at DESC, id DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, testOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AiAnalysisResult result = mapResult(rs);
                    String normalizedInput = normalizeRelativeImagePath(result.getInputImage());
                    if (normalizedImagePath.equals(normalizedInput)) {
                        return "Success".equalsIgnoreCase(result.getStatus()) ? result : null;
                    }
                }
            }
        }
        return null;
    }

    /**
     * Canonicalizes a database-controlled relative image path. Traversal,
     * absolute paths and URI/drive prefixes are rejected instead of resolved.
     */
    static String normalizeRelativeImagePath(String value) {
        if (value == null) return null;
        String path = value.trim().replace('\\', '/');
        if (path.isEmpty() || path.length() > 1000 || path.startsWith("/")
                || path.indexOf('\0') >= 0 || path.indexOf(':') >= 0) return null;

        List<String> segments = new ArrayList<>();
        for (String segment : path.split("/", -1)) {
            if (segment.isEmpty() || ".".equals(segment)) continue;
            if ("..".equals(segment)) return null;
            segments.add(segment);
        }
        return segments.isEmpty() ? null : String.join("/", segments);
    }

    /** Updates one immutable AI run record without touching review/report data. */
    public boolean update(AiAnalysisResult res) {
        String sql = "UPDATE ai_analysis_results SET status = ?, detected = ?, confidence = ?, message = ?, "
                + "input_image = ?, result_image = ?, mask_image = ?, raw_mask_image = ?, xmin = ?, ymin = ?, "
                + "xmax = ?, ymax = ?, analyzed_at = ?, error_message = ? WHERE id = ? AND test_order_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, res.getStatus());
            ps.setBoolean(2, res.isDetected());
            ps.setBigDecimal(3, res.getConfidence());
            ps.setString(4, res.getMessage());
            ps.setString(5, res.getInputImage());
            ps.setString(6, res.getResultImage());
            ps.setString(7, res.getMaskImage());
            ps.setString(8, res.getRawMaskImage());
            setNullableInt(ps, 9, res.getXmin());
            setNullableInt(ps, 10, res.getYmin());
            setNullableInt(ps, 11, res.getXmax());
            setNullableInt(ps, 12, res.getymax());
            ps.setTimestamp(13, res.getAnalyzedAt() == null
                    ? new Timestamp(System.currentTimeMillis()) : res.getAnalyzedAt());
            ps.setString(14, res.getErrorMessage());
            ps.setInt(15, res.getId());
            ps.setInt(16, res.getTestOrderId());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[AiAnalysisResultDAO] update ERROR: " + e.getMessage());
            return false;
        }
    }

    private AiAnalysisResult mapResult(ResultSet rs) throws SQLException {
        AiAnalysisResult res = new AiAnalysisResult();
        res.setId(rs.getInt("id"));
        res.setTestOrderId(rs.getInt("test_order_id"));
        res.setStatus(rs.getString("status"));
        res.setDetected(rs.getBoolean("detected"));
        res.setConfidence(rs.getBigDecimal("confidence"));
        res.setMessage(rs.getString("message"));
        res.setInputImage(rs.getString("input_image"));
        res.setResultImage(rs.getString("result_image"));
        res.setMaskImage(rs.getString("mask_image"));
        res.setRawMaskImage(rs.getString("raw_mask_image"));

        int xmin = rs.getInt("xmin");
        res.setXmin(rs.wasNull() ? null : xmin);
        int ymin = rs.getInt("ymin");
        res.setYmin(rs.wasNull() ? null : ymin);
        int xmax = rs.getInt("xmax");
        res.setXmax(rs.wasNull() ? null : xmax);
        int ymax = rs.getInt("ymax");
        res.setymax(rs.wasNull() ? null : ymax);

        res.setAnalyzedAt(rs.getTimestamp("analyzed_at"));
        res.setErrorMessage(rs.getString("error_message"));
        return res;
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) ps.setNull(index, Types.INTEGER); else ps.setInt(index, value);
    }
}
