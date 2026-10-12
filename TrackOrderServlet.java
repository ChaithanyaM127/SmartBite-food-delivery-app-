package com.foodtap.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.foodtap.model.User;
import com.foodtap.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/track-order")
public class TrackOrderServlet extends HttpServlet {


private static final long serialVersionUID = 1L;

@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession(false);

    if (session == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    User user = (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String orderIdParameter = request.getParameter("orderId");

    if (orderIdParameter == null || orderIdParameter.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/orders");
        return;
    }

    int orderId;

    try {
        orderId = Integer.parseInt(orderIdParameter.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect(request.getContextPath() + "/orders");
        return;
    }

    String sql =
            "SELECT orderId, orderDate, totalAmount, status, paymentOption " +
            "FROM orders " +
            "WHERE orderId = ? AND userId = ?";

    try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)
    ) {

        ps.setInt(1, orderId);
        ps.setInt(2, user.getUserId());

        try (ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {

                request.setAttribute("orderId", rs.getInt("orderId"));
                request.setAttribute("orderDate", rs.getTimestamp("orderDate"));
                request.setAttribute("totalAmount", rs.getFloat("totalAmount"));
                request.setAttribute("status", rs.getString("status"));
                request.setAttribute("paymentOption", rs.getString("paymentOption"));

                request.getRequestDispatcher("/track-order.jsp")
                       .forward(request, response);

                return;
            }
        }

    } catch (Exception e) {
        e.printStackTrace();

        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().println("<h2>Unable to track order.</h2>");
        return;
    }

    response.sendRedirect(request.getContextPath() + "/orders");
}


}
