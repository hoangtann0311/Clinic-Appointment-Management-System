public class CheckSchedules {
    public static void main(String[] args) {
        try {
            java.sql.Connection conn = com.clinic.config.DatabaseConfig.getConnection();
            java.sql.Statement stmt = conn.createStatement();
            java.sql.ResultSet rs = stmt.executeQuery("SELECT ds.id, ds.shift_id, ds.work_date, s.name, s.start_time, s.end_time FROM doctor_schedules ds JOIN shifts s ON ds.shift_id = s.id");
            while (rs.next()) {
                System.out.println(rs.getInt("id") + " | " + rs.getString("name") + " | " + rs.getString("start_time") + " | " + rs.getString("end_time"));
            }
        } catch(Exception e) { e.printStackTrace(); }
    }
}
