package com.foodtap.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.foodtap.dao.UserDAO;
import com.foodtap.daoimpl.UserDAOImpl;
import com.foodtap.model.User;
import com.foodtap.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {


private static final long serialVersionUID = 1L;

@Override
protected void doPost(HttpServletRequest request,
                       HttpServletResponse response)
        throws ServletException, IOException {

    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");
    String phone = request.getParameter("phone");
    String address = request.getParameter("address");
    String next = request.getParameter("next");

    if (name == null || email == null || password == null
            || phone == null || address == null
            || name.trim().isEmpty()
            || email.trim().isEmpty()
            || password.trim().isEmpty()
            || phone.trim().isEmpty()
            || address.trim().isEmpty()) {

        response.sendRedirect(
                request.getContextPath() + "/register.jsp?error=empty"
        );
        return;
    }

    if (confirmPassword == null || !password.equals(confirmPassword)) {

        response.sendRedirect(
                request.getContextPath() + "/register.jsp?error=match"
        );
        return;
    }

    if (password.length() < 6) {

        response.sendRedirect(
                request.getContextPath() + "/register.jsp?error=short"
        );
        return;
    }

    email = email.trim().toLowerCase();
    name = name.trim();
    phone = phone.trim();
    address = address.trim();

    Connection connection = null;

    try {

        connection = DBConnection.getConnection();

        if (connection == null) {

            response.sendRedirect(
                    request.getContextPath() + "/register.jsp?error=error"
            );
            return;
        }

        String checkSql =
                "SELECT userId FROM user WHERE email = ?";

        try (PreparedStatement checkPs =
                     connection.prepareStatement(checkSql)) {

            checkPs.setString(1, email);

            try (ResultSet rs = checkPs.executeQuery()) {

                if (rs.next()) {

                    response.sendRedirect(
                            request.getContextPath()
                            + "/register.jsp?error=email"
                    );
                    return;
                }
            }
        }

        User user = new User(
                name,
                email,
                password,
                phone,
                address,
                "CUSTOMER"
        );

        UserDAO userDAO = new UserDAOImpl();

        boolean registered = userDAO.registerUser(user);

        if (registered) {

            User loggedIn = new User();

            loggedIn.setName(name);
            loggedIn.setEmail(email);
            loggedIn.setPassword(password);
            loggedIn.setPhone(phone);
            loggedIn.setAddress(address);
            loggedIn.setRole("CUSTOMER");

            String idSql =
                    "SELECT userId FROM user WHERE email = ?";

            try (PreparedStatement idPs =
                         connection.prepareStatement(idSql)) {

                idPs.setString(1, email);

                try (ResultSet idRs = idPs.executeQuery()) {

                    if (idRs.next()) {
                        loggedIn.setUserId(
                                idRs.getInt("userId")
                        );
                    }
                }
            }

            HttpSession session = request.getSession(true);

            session.setAttribute(
                    "loggedInUser",
                    loggedIn
            );

            if (next != null) {

                next = next.trim();

                if (next.equals("checkout.jsp")
                        || next.equals("cart")
                        || next.equals("orders")) {

                    response.sendRedirect(
                            request.getContextPath() + "/" + next
                    );
                    return;
                }
            }

            response.sendRedirect(
                    request.getContextPath() + "/home.jsp"
            );

        } else {

            response.sendRedirect(
                    request.getContextPath() + "/register.jsp?error=error"
            );
        }

    } catch (Exception e) {

        e.printStackTrace();

        response.sendRedirect(
                request.getContextPath() + "/register.jsp?error=error"
        );

    } finally {

        if (connection != null) {

            try {
                connection.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

@Override
protected void doGet(HttpServletRequest request,
                     HttpServletResponse response)
        throws ServletException, IOException {

    response.sendRedirect(
            request.getContextPath() + "/register.jsp"
    );
}


}
