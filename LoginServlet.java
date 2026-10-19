
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

        // Preserve the requested destination.
        String redirect = request.getParameter("redirect");

        // Allow only the two intended internal destinations.
        if (!"home.jsp".equals(redirect)
                && !"checkout.jsp".equals(redirect)) {
            redirect = "home.jsp";
        }

        String contextPath = request.getContextPath();

        if (email == null || password == null
                || email.trim().isEmpty()
                || password.trim().isEmpty()) {

            response.sendRedirect(
                    contextPath + "/login.jsp?error=empty&redirect="
                            + redirect);
            return;
        }

        email = email.trim().toLowerCase();
        password = password.trim();

        Connection connection = null;

        try {
            connection = DBConnection.getConnection();

            if (connection == null) {
                response.sendRedirect(
                        contextPath + "/login.jsp?error=error&redirect="
                                + redirect);
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

            // Preserve the original existing-account behavior.
            if (user != null) {

                user.setPassword(password);

            } else {

                // Preserve the original new-account creation behavior.
                String name = email.substring(0, email.indexOf("@"));

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
                        throw new Exception(
                                "User ID was not generated.");
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

            // Store the user in the session, as before.
            HttpSession session = request.getSession(true);
            session.setAttribute("loggedInUser", user);

            // Redirect to the requested page.
            response.sendRedirect(contextPath + "/" + redirect);

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    contextPath + "/login.jsp?error=error&redirect="
                            + redirect);

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
                request.getContextPath() + "/login.jsp?redirect=home.jsp");
    }
}
