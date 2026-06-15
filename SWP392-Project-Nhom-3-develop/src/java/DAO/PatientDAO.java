/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;
import com.clinic.config.DatabaseConfig;
import java.sql.*;

/**
 *
 * @author ADMIN
 */
public class PatientDAO {
    public Integer getPatientIdByUserId(int userId) {

        String sql =
            "SELECT id FROM patients WHERE user_id=?";

        try(Connection con = DatabaseConfig.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1,userId);

            ResultSet rs = ps.executeQuery();

            if(rs.next()){
                return rs.getInt("id");
            }

        } catch(Exception e){
            e.printStackTrace();
        }

        return null;
    }
}
