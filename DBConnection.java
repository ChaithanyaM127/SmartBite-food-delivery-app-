package com.foodtap.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/foodtapdb" +
            "?connectTimeout=5000" +
            "&socketTimeout=5000" +
            "&tcpKeepAlive=true" +
            "&useUnicode=true" +
            "&characterEncoding=UTF-8" +
            "&serverTimezone=Asia/Kolkata";

    public static Connection getConnection() {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            String url = System.getenv("DB_URL");
            String user = System.getenv("DB_USER");
            String password = System.getenv("DB_PASSWORD");

            if (url == null || url.trim().isEmpty()) {
                url = DEFAULT_URL;
            }

            if (user == null || user.trim().isEmpty()) {
                user = "root";
            }

            if (password == null) {
                password = "";
            }

            Connection connection = DriverManager.getConnection(
                    url,
                    user,
                    password
            );

            return connection;

        } catch (ClassNotFoundException e) {

            System.out.println("MySQL JDBC Driver not found.");
            e.printStackTrace();

        } catch (SQLException e) {

            System.out.println("Database connection failed.");
            e.printStackTrace();
        }

        return null;
    }
}
