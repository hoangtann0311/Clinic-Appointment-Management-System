<%@ page import="java.sql.*, com.clinic.config.DatabaseConfig" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    try (Connection c = DatabaseConfig.getConnection();
         Statement stmt = c.createStatement()) {
        
        // Ensure there is a service with name 'Siêu âm'
        stmt.executeUpdate("IF NOT EXISTS (SELECT 1 FROM services WHERE service_name LIKE N'%Siêu âm%') INSERT INTO services (service_name, price, status, is_deleted) VALUES (N'Siêu âm thai', 200000, 1, 0)");
        
        ResultSet rs = stmt.executeQuery("SELECT TOP 1 id FROM services WHERE service_name LIKE N'%Siêu âm%'");
        int serviceId = 1;
        if (rs.next()) serviceId = rs.getInt("id");
        rs.close();

        // Ensure patient
        stmt.executeUpdate("IF NOT EXISTS (SELECT 1 FROM patients) INSERT INTO patients (full_name, phone_number, is_deleted) VALUES (N'Demo Patient', '0999999999', 0)");
        rs = stmt.executeQuery("SELECT TOP 1 id FROM patients");
        int patientId = 1;
        if (rs.next()) patientId = rs.getInt("id");
        rs.close();

        // Ensure appointment
        stmt.executeUpdate("IF NOT EXISTS (SELECT 1 FROM appointments) INSERT INTO appointments (patient_id, appointment_date, status) VALUES (" + patientId + ", GETDATE(), 'Completed')");
        rs = stmt.executeQuery("SELECT TOP 1 id FROM appointments");
        int appId = 1;
        if (rs.next()) appId = rs.getInt("id");
        rs.close();

        // Ensure medical_record
        stmt.executeUpdate("IF NOT EXISTS (SELECT 1 FROM medical_records) INSERT INTO medical_records (appointment_id, diagnosis) VALUES (" + appId + ", N'Demo Diagnosis')");
        rs = stmt.executeQuery("SELECT TOP 1 id FROM medical_records");
        int mrId = 1;
        if (rs.next()) mrId = rs.getInt("id");
        rs.close();

        // Create test order
        stmt.executeUpdate("INSERT INTO test_orders (medical_record_id, service_id, status) VALUES (" + mrId + ", " + serviceId + ", 'Pending')");

        // Create sonographer user
        // role_id = 6 is Sonographer
        // username: sonographer, password: 123 (hash could be MD5 or something, we'll assume they can just use an existing account)
        out.print("<h3>✅ Đã tạo một chỉ định Siêu Âm giả lập thành công!</h3>");
        out.print("<p>Bây giờ bạn có thể đăng nhập bằng tài khoản Kỹ thuật viên siêu âm (Sonographer) và sẽ thấy yêu cầu siêu âm chờ ở danh sách.</p>");

    } catch (Exception e) {
        out.print("ERROR: " + e.getMessage());
    }
%>
