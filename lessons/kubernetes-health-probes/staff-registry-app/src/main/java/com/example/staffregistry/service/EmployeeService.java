package com.example.staffregistry.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class EmployeeService {

    private static final Logger logger = LoggerFactory.getLogger(EmployeeService.class);
    private final DataSource dataSource;

    @Autowired
    public EmployeeService(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void init() {
        try (Connection conn = dataSource.getConnection()) {
            ensureTable(conn);
            logger.info("Successfully checked/created 'employees' table.");
        } catch (Exception e) {
            logger.warn("Could not create employees table (will retry on next request): {}", e.getMessage());
        }
    }

    // Idempotent; called on every access so a DB that came up after app start still gets its table.
    private void ensureTable(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS employees (
                    id                  BIGSERIAL PRIMARY KEY,
                    name                VARCHAR(100) NOT NULL,
                    work_mode           VARCHAR(50),
                    years_of_experience INT,
                    hire_date           DATE,
                    office_location     VARCHAR(100),
                    primary_skill       VARCHAR(100),
                    slack_username      VARCHAR(100),
                    corporate_email     VARCHAR(200),
                    job_title           VARCHAR(100),
                    submitted_at        TIMESTAMP DEFAULT NOW()
                )
            """);
        }
    }

    public long count() {
        try (Connection conn = dataSource.getConnection()) {
            ensureTable(conn);
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM employees")) {
                return rs.next() ? rs.getLong(1) : 0;
            }
        } catch (Exception e) {
            logger.warn("Could not count employees: {}", e.getMessage());
            return 0;
        }
    }

    public void save(String name, String workMode, String yearsOfExperience, String hireDate,
                     String officeLocation, String primarySkill, String slackUsername,
                     String corporateEmail, String jobTitle) throws SQLException {
        String sql = """
            INSERT INTO employees (name, work_mode, years_of_experience, hire_date, office_location,
                primary_skill, slack_username, corporate_email, job_title)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;
        validate(name, yearsOfExperience, hireDate);
        try (Connection conn = dataSource.getConnection()) {
            ensureTable(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, workMode);
            ps.setInt(3, yearsOfExperience.isBlank() ? 0 : Integer.parseInt(yearsOfExperience));
            ps.setDate(4, hireDate.isBlank() ? null : java.sql.Date.valueOf(hireDate));
            ps.setString(5, officeLocation);
            ps.setString(6, primarySkill);
            ps.setString(7, slackUsername);
            ps.setString(8, corporateEmail);
            ps.setString(9, jobTitle);
            ps.executeUpdate();
            }
        }
    }

    private static void validate(String name, String yearsOfExperience, String hireDate) {
        if (name == null || name.isBlank() || name.length() > 100) {
            throw new IllegalArgumentException("name must be 1-100 characters");
        }
        try {
            if (!yearsOfExperience.isBlank() && Integer.parseInt(yearsOfExperience) < 0) {
                throw new IllegalArgumentException("yearsOfExperience must be >= 0");
            }
            if (!hireDate.isBlank()) java.sql.Date.valueOf(hireDate);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("yearsOfExperience must be a number");
        }
    }

    public List<Map<String, String>> getAll() {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = """
            SELECT id, name, work_mode, years_of_experience, hire_date, office_location,
                   primary_skill, slack_username, corporate_email, job_title
            FROM employees ORDER BY id DESC
        """;
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("id",                String.valueOf(rs.getLong("id")));
                row.put("name",              str(rs, "name"));
                row.put("workMode",          str(rs, "work_mode"));
                row.put("yearsOfExperience", String.valueOf(rs.getInt("years_of_experience")));
                row.put("hireDate",          rs.getDate("hire_date") != null ? rs.getDate("hire_date").toString() : "");
                row.put("officeLocation",    str(rs, "office_location"));
                row.put("primarySkill",      str(rs, "primary_skill"));
                row.put("slackUsername",     str(rs, "slack_username"));
                row.put("corporateEmail",    str(rs, "corporate_email"));
                row.put("jobTitle",          str(rs, "job_title"));
                list.add(row);
            }
        } catch (Exception e) {
            logger.warn("Could not fetch employees: {}", e.getMessage());
        }
        return list;
    }

    private String str(ResultSet rs, String col) throws SQLException {
        String v = rs.getString(col);
        return v != null ? v : "";
    }
}
