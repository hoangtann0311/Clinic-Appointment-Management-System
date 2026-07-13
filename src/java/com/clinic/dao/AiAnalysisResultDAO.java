package com.clinic.dao;

import com.clinic.config.DatabaseConfig;
import com.clinic.model.AiAnalysisResult;

import java.sql.*;

/**
 * DAO cho bảng ai_analysis_results.
 */
public class AiAnalysisResultDAO {

    public int insert(AiAnalysisResult res) {
        String sql = "INSERT INTO ai_analysis_results (test_order_id, status, detected, confidence, message, input_image, result_image, mask_image, raw_mask_image, xmin, ymin, xmax, ymax, analyzed_at, error_message) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, res.getTestOrderId());
            ps.setString(2, res.getStatus());
            ps.setBoolean(3, res.isDetected());
            ps.setBigDecimal(4, res.getConfidence());
            ps.setString(5, res.getMessage());
            ps.setString(6, res.getInputImage());
            ps.setString(7, res.getResultImage());
            ps.setString(8, res.getMaskImage());
            ps.setString(9, res.getRawMaskImage());
            
            if (res.getXmin() != null) ps.setInt(10, res.getXmin()); else ps.setNull(10, Types.INTEGER);
            if (res.getYmin() != null) ps.setInt(11, res.getYmin()); else ps.setNull(11, Types.INTEGER);
            if (res.getXmax() != null) ps.setInt(12, res.getXmax()); else ps.setNull(12, Types.INTEGER);
            if (res.getymax() != null) ps.setInt(13, res.getymax()); else ps.setNull(13, Types.INTEGER);
            
            if (res.getAnalyzedAt() != null) {
                ps.setTimestamp(14, res.getAnalyzedAt());
            } else {
                ps.setTimestamp(14, new Timestamp(System.currentTimeMillis()));
            }
            ps.setString(15, res.getErrorMessage());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("[AiAnalysisResultDAO] insert ERROR: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return -1;
    }

    public AiAnalysisResult getByTestOrderId(int testOrderId) {
        String sql = "SELECT * FROM ai_analysis_results WHERE test_order_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, testOrderId);
            rs = ps.executeQuery();
            if (rs.next()) {
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
        } catch (SQLException e) {
            System.err.println("[AiAnalysisResultDAO] getByTestOrderId ERROR: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    public boolean deleteByTestOrderId(int testOrderId) {
        String sql = "DELETE FROM ai_analysis_results WHERE test_order_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DatabaseConfig.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, testOrderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[AiAnalysisResultDAO] deleteByTestOrderId ERROR: " + e.getMessage());
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) { try { rs.close(); } catch (SQLException e) { } }
        if (ps != null) { try { ps.close(); } catch (SQLException e) { } }
        DatabaseConfig.closeConnection(conn);
    }
}
