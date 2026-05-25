package com.example.hello.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDateTime;

@Service
public class DatabaseConnectionService {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseConnectionService.class);

    private final DataSource dataSource;
    private volatile boolean databaseConnected = false;

    @Autowired
    public DatabaseConnectionService(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady() {
        tryConnectAndLog();
    }

    public void tryConnectAndLog() {
        try (Connection conn = dataSource.getConnection()) {
            // Create table if not exists
            createTableIfNotExists(conn);
            
            // Count existing rows
            long existingCount = countRows(conn);
            
            // Determine message
            String message;
            if (existingCount == 0) {
                message = "application connected";
            } else {
                message = "restarted " + existingCount;
            }

            // Insert new row
            insertLog(conn, message);
            
            databaseConnected = true;
            logger.info("Database connection logged: {}", message);

        } catch (Exception e) {
            databaseConnected = false;
            logger.warn("Database not available: {}. Application continues without DB.", e.getMessage());
        }
    }

    private void createTableIfNotExists(Connection conn) throws SQLException {
        String sql = """
            CREATE TABLE IF NOT EXISTS connection_log (
                id BIGSERIAL PRIMARY KEY,
                message VARCHAR(255) NOT NULL,
                timestamp TIMESTAMP NOT NULL
            )
        """;
        try (Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        }
    }

    private long countRows(Connection conn) throws SQLException {
        String sql = "SELECT COUNT(*) FROM connection_log";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getLong(1);
            }
            return 0;
        }
    }

    private void insertLog(Connection conn, String message) throws SQLException {
        String sql = "INSERT INTO connection_log (message, timestamp) VALUES (?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, message);
            pstmt.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            pstmt.executeUpdate();
        }
    }

    public boolean isDatabaseConnected() {
        return databaseConnected;
    }
}
