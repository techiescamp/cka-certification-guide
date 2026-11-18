package com.example.staffregistry.service;

import com.example.staffregistry.model.ConnectionLog;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class DatabaseConnectionService {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseConnectionService.class);
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

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

    // initialDelay prevents double-fire with onApplicationReady
    @Scheduled(fixedDelay = 5000, initialDelay = 10000)
    public void refreshDatabaseStatus() {
        if (!databaseConnected) {
            tryConnectAndLog();
        } else {
            try (Connection conn = dataSource.getConnection()) {
                // connection ok
            } catch (Exception e) {
                databaseConnected = false;
                logger.warn("Lost database connection: {}", e.getMessage());
            }
        }
    }

    public void tryConnectAndLog() {
        try (Connection conn = dataSource.getConnection()) {
            createTableIfNotExists(conn);

            long existingCount = countRows(conn);
            String message = existingCount == 0 ? "application connected" : "restarted " + existingCount;

            insertLog(conn, message);

            databaseConnected = true;
            logger.info("Database connection logged: {}", message);

        } catch (Exception e) {
            databaseConnected = false;
            logger.warn("Database not available: {}. Application continues without DB.", e.getMessage());
        }
    }

    public List<ConnectionLog> getConnectionLogs() {
        if (!databaseConnected) return List.of();
        try (Connection conn = dataSource.getConnection()) {
            String sql = "SELECT id, message, timestamp FROM connection_log ORDER BY id DESC LIMIT 20";
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(sql)) {
                List<ConnectionLog> logs = new ArrayList<>();
                while (rs.next()) {
                    logs.add(new ConnectionLog(
                        rs.getLong("id"),
                        rs.getString("message"),
                        rs.getTimestamp("timestamp").toLocalDateTime().format(FMT)
                    ));
                }
                return logs;
            }
        } catch (Exception e) {
            logger.warn("Failed to fetch connection logs: {}", e.getMessage());
            return List.of();
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
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM connection_log")) {
            return rs.next() ? rs.getLong(1) : 0;
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
