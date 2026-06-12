package com.clinic.config;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * DBContext wrapper class that delegates connection retrieval
 * to the project's centralized DatabaseConfig.
 */
public class DBContext {

    /**
     * Obtains a database connection from DatabaseConfig.
     * 
     * @return Connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        return DatabaseConfig.getConnection();
    }
}
