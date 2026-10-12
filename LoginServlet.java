package com.foodtap.servlet;

import java.io.IOException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import com.foodtap.model.User;
import com.foodtap.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")

public class LoginServlet extends HttpServlet {


private static final long serialVersionUID = 1L;

@Override
protected void doPost(HttpServletRequest request,
                       HttpServletResponse response)
        throws ServletException, IOException {

    String email = request.getParameter("email");
    String password = request.getParameter("password");

    if (email == null || password == null
            || email.trim().isEmpty()
            || password.trim().isEmpty()) {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp?error=empty"
        );

        return;
    }

    email = email.trim().toLowerCase();
    password = password.trim();

    Connection connection = null;

    try {

        connection = DBConnection.getConnection();

        if (connection == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp?error=error"
            );

            return;
        }

        User user = null;

        String selectSQL =
                "SELECT userId, name, email, password, phone, address, role "
                + "FROM user WHERE email = ?";

        try (PreparedStatement ps =
                connection.prepareStatement(selectSQL)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    user = new User();

                    user.setUserId(rs.getInt("userId"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setPhone(rs.getString("phone"));
                    user.setAddress(rs.getString("address"));
                    user.setRole(rs.getString("role"));
                }
            }
        }

        /*
         * If the email already exists,
         * allow login with the entered password.
         */

        if (user != null) {

            user.setPassword(password);

        } else {

            /*
             * If the email does not exist,
             * automatically create a FOODTAP customer account.
             */

            String name = email.substring(
                    0,
                    email.indexOf("@")
            );

            String insertSQL =
                    "INSERT INTO user "
                    + "(name, email, password, phone, address, role) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps =
                    connection.prepareStatement(
                            insertSQL,
                            Statement.RETURN_GENERATED_KEYS)) {

                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, password);
                ps.setString(4, "");
                ps.setString(5, "");
                ps.setString(6, "CUSTOMER");

                ps.executeUpdate();

                int userId = 0;

                try (ResultSet rs = ps.getGeneratedKeys()) {

                    if (rs.next()) {
                        userId = rs.getInt(1);
                    }
                }

                if (userId <= 0) {
                    throw new Exception("User ID was not generated.");
                }

                user = new User();

                user.setUserId(userId);
                user.setName(name);
                user.setEmail(email);
                user.setPassword(password);
                user.setPhone("");
                user.setAddress("");
                user.setRole("CUSTOMER");
            }
        }

        /*
         * Store the logged-in user in session.
         */

        HttpSession session = request.getSession();

        session.setAttribute("loggedInUser", user);

        /*
         * After login, go directly to CHECKOUT.
         */

        response.sendRedirect(
                request.getContextPath() + "/checkout.jsp"
        );

    } catch (Exception e) {

        e.printStackTrace();

        response.sendRedirect(
                request.getContextPath() + "/login.jsp?error=error"
        );

    } finally {

        try {

            if (connection != null) {
                connection.close();
            }

        } catch (Exception e) {

            e.printStackTrace();
        }
    }
}

@Override
protected void doGet(HttpServletRequest request,
                     HttpServletResponse response)
        throws ServletException, IOException {

    response.sendRedirect(
            request.getContextPath() + "/login.jsp"
    );
}


}
