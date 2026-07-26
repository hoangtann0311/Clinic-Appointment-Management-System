public class UpdateShifts {
    public static void main(String[] args) {
        try {
            java.sql.Connection conn = com.clinic.config.DatabaseConfig.getConnection();
            java.sql.Statement stmt = conn.createStatement();
            stmt.executeUpdate("UPDATE shifts SET start_time='19:00', end_time='23:00' WHERE name=N'Ca tối'");
            System.out.println("Updated successfully");
        } catch(Exception e) { e.printStackTrace(); }
    }
}
