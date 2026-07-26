public class CheckDB {
    public static void main(String[] args) {
        try {
            java.sql.Connection conn = com.clinic.config.DatabaseConfig.getConnection();
            java.sql.Statement stmt = conn.createStatement();
            
            stmt.executeUpdate("DELETE FROM doctor_schedules WHERE shift_id NOT IN (SELECT id FROM shifts WHERE name IN (N'Ca sáng', N'Ca chiều', N'Ca tối'))");
            stmt.executeUpdate("DELETE FROM shifts WHERE name NOT IN (N'Ca sáng', N'Ca chiều', N'Ca tối')");
            stmt.executeUpdate("UPDATE shifts SET name=N'Ca sáng', start_time='07:00', end_time='11:00' WHERE name=N'Ca sáng'");
            stmt.executeUpdate("UPDATE shifts SET name=N'Ca chiều', start_time='13:00', end_time='17:00' WHERE name=N'Ca chiều'");
            stmt.executeUpdate("UPDATE shifts SET name=N'Ca tối', start_time='19:00', end_time='23:00' WHERE name=N'Ca tối'");
            
            System.out.println("Cleaned shifts");
        } catch(Exception e) { e.printStackTrace(); }
    }
}
