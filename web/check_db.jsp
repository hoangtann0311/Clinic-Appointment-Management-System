<%@ page import="java.sql.*, com.clinic.config.DatabaseConfig" %>
<%
    try (Connection c = DatabaseConfig.getConnection();
         PreparedStatement ps = c.prepareStatement("SELECT TOP 1 * FROM users");
         ResultSet rs = ps.executeQuery()) {
        ResultSetMetaData meta = rs.getMetaData();
        int count = meta.getColumnCount();
        for (int i = 1; i <= count; i++) {
            out.print(meta.getColumnName(i) + " ");
        }
    } catch (Exception e) {
        out.print("ERROR: " + e.getMessage());
    }
%>
