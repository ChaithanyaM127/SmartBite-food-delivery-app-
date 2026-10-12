package com.foodtap.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.foodtap.model.User;
import com.foodtap.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cancel-order")
public class CancelOrderServlet extends HttpServlet {


private static final long serialVersionUID = 1L;

@Override
protected void doGet(HttpServletRequest request,
                      HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession(false);

    if (session == null) {
        response.sendRedirect(
            request.getContextPath() + "/login.jsp"
        );
        return;
    }

    User user =
            (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect(
            request.getContextPath() + "/login.jsp"
        );
        return;
    }

    String orderIdParameter =
            request.getParameter("orderId");

    if (orderIdParameter == null
            || orderIdParameter.trim().isEmpty()) {

        response.sendRedirect(
            request.getContextPath() + "/orders"
        );
        return;
    }

    int orderId;

    try {
        orderId = Integer.parseInt(
            orderIdParameter.trim()
        );
    } catch (NumberFormatException e) {

        response.sendRedirect(
            request.getContextPath() + "/orders"
        );
        return;
    }

    String sql =
            "UPDATE orders "
            + "SET status = 'CANCELLED' "
            + "WHERE orderId = ? "
            + "AND userId = ? "
            + "AND status IN ('PLACED', 'CONFIRMED')";

    try (Connection connection =
                DBConnection.getConnection();
         PreparedStatement ps =
                connection.prepareStatement(sql)) {

        ps.setInt(1, orderId);
        ps.setInt(2, user.getUserId());

        ps.executeUpdate();

    } catch (Exception e) {

        e.printStackTrace();
    }

    response.sendRedirect(
        request.getContextPath() + "/orders"
    );
}

@Override
protected void doPost(HttpServletRequest request,
                       HttpServletResponse response)
        throws ServletException, IOException {

    doGet(request, response);
}


}
