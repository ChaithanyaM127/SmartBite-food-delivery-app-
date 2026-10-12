package com.foodtap.util;

import java.sql.Connection;

public class TestConnection {

    public static void main(String[] args) {

        Connection connection = DBConnection.getConnection();

        if (connection != null) {
            System.out.println("================================");
            System.out.println("DATABASE CONNECTION SUCCESSFUL!");
            System.out.println("================================");
        } else {
            System.out.println("================================");
            System.out.println("DATABASE CONNECTION FAILED!");
            System.out.println("================================");
        }
    }
}