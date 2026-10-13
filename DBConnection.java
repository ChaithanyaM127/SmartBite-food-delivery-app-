package com.foodtap.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL = System.getenv("DB_URL");
    private static final String USER = System.getenv("DB_USER");
    private static final String PASSWORD = System.getenv("DB_PASSWORD");

    public static Connection getConnection() {

        try {

            if (URL == null || URL.isBlank()
                    || USER == null || USER.isBlank()
                    || PASSWORD == null || PASSWORD.isBlank()) {

                System.err.println(
                    "Database connection failed: DB_URL, DB_USER, or DB_PASSWORD is missing."
                );

                return null;
            }

            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection connection = DriverManager.getConnection(
                URL,
                USER,
                PASSWORD
            );

            System.out.println("Database connected successfully!");

            return connection;

        } catch (ClassNotFoundException e) {

            System.err.println("MySQL JDBC Driver not found.");
            e.printStackTrace();

        } catch (SQLException e) {

            System.err.println("Database connection failed.");
            e.printStackTrace();
        }

        return null;
    }
}
