package com.foodtap.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.foodtap.model.CartItem;
import com.foodtap.model.User;
import com.foodtap.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/place-order")
public class PlaceOrderServlet extends HttpServlet {

private static final long serialVersionUID = 1L;

@Override
protected void doPost(HttpServletRequest request,
                      HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession();

    User user = (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
        return;
    }

    List<CartItem> cart = new ArrayList<>();

    Object cartObject = session.getAttribute("cart");

    if (cartObject instanceof List<?>) {
        for (Object item : (List<?>) cartObject) {
            if (item instanceof CartItem) {
                cart.add((CartItem) item);
            }
        }
    }

    if (cart.isEmpty()) {
        response.sendRedirect(
                request.getContextPath() + "/cart"
        );
        return;
    }

    String paymentOption = request.getParameter("paymentOption");
    String upiMethod = request.getParameter("upiMethod");
    String upiId = request.getParameter("upiId");

    if (paymentOption == null || paymentOption.trim().isEmpty()) {
        paymentOption = "Cash on Delivery";
    } else {
        paymentOption = paymentOption.trim();
    }

    /*
     * UPI PAYMENT
     */
    if (paymentOption.equalsIgnoreCase("UPI")) {

        if (upiMethod == null || upiMethod.trim().isEmpty()) {
            showMessage(
                    response,
                    "Please select a UPI payment method."
            );
            return;
        }

        upiMethod = upiMethod.trim();

        if (upiMethod.equalsIgnoreCase("UPI ID")) {

            if (upiId == null || upiId.trim().isEmpty()) {
                showMessage(
                        response,
                        "Please enter your UPI ID."
                );
                return;
            }

            upiId = upiId.trim();

            if (!upiId.matches(
                    "^[A-Za-z0-9._-]+@[A-Za-z0-9._-]+$")) {

                showMessage(
                        response,
                        "Please enter a valid UPI ID."
                );
                return;
            }

            paymentOption = "UPI - UPI ID";

        } else if (
                upiMethod.equalsIgnoreCase("Google Pay") ||
                upiMethod.equalsIgnoreCase("PhonePe") ||
                upiMethod.equalsIgnoreCase("Paytm") ||
                upiMethod.equalsIgnoreCase("BHIM UPI")) {

            paymentOption = "UPI - " + upiMethod;

        } else {

            showMessage(
                    response,
                    "Invalid UPI payment method."
            );
            return;
        }

    }

    /*
     * CARD PAYMENT
     */
    else if (
            paymentOption.equalsIgnoreCase("CARD") ||
            paymentOption.equalsIgnoreCase("Credit / Debit Card")) {

        paymentOption = "Credit / Debit Card";
    }

    /*
     * CASH ON DELIVERY
     */
    else {
        paymentOption = "Cash on Delivery";
    }

    /*
     * CALCULATE TOTAL
     */
    double foodTotal = 0;

    for (CartItem item : cart) {
        foodTotal += item.getItemTotal();
    }

    double deliveryFee = 40.0;
    double platformFee = 20.0;

    double totalAmount =
            foodTotal + deliveryFee + platformFee;

    /*
     * RESTAURANT ID
     */
    int restaurantId =
            cart.get(0)
                .getMenu()
                .getRestaurantId();

    Connection connection = null;

    try {

        connection = DBConnection.getConnection();

        if (connection == null) {
            throw new Exception(
                    "Database connection failed."
            );
        }

        connection.setAutoCommit(false);

        /*
         * INSERT ORDER
         */
        String orderSQL =
                "INSERT INTO orders " +
                "(userId, restaurantId, totalAmount, status, paymentOption) " +
                "VALUES (?, ?, ?, ?, ?)";

        int orderId = 0;

        try (PreparedStatement ps =
                connection.prepareStatement(
                        orderSQL,
                        java.sql.Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, user.getUserId());
            ps.setInt(2, restaurantId);
            ps.setDouble(3, totalAmount);
            ps.setString(4, "PLACED");
            ps.setString(5, paymentOption);

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {

                if (rs.next()) {
                    orderId = rs.getInt(1);
                }
            }
        }

        if (orderId <= 0) {
            throw new Exception(
                    "Order ID was not generated."
            );
        }

        /*
         * INSERT ORDER ITEMS
         */
        String itemSQL =
                "INSERT INTO orderitem " +
                "(orderId, menuId, quantity, itemTotal) " +
                "VALUES (?, ?, ?, ?)";

        try (PreparedStatement ps =
                connection.prepareStatement(itemSQL)) {

            for (CartItem item : cart) {

                ps.setInt(
                        1,
                        orderId
                );

                ps.setInt(
                        2,
                        item.getMenu().getMenuId()
                );

                ps.setInt(
                        3,
                        item.getQuantity()
                );

                ps.setDouble(
                        4,
                        item.getItemTotal()
                );

                ps.addBatch();
            }

            ps.executeBatch();
        }

        /*
         * COMMIT ORDER
         */
        connection.commit();

        /*
         * SAVE ORDER DETAILS IN SESSION
         */
        session.setAttribute(
                "lastOrderId",
                Integer.valueOf(orderId)
        );

        session.setAttribute(
                "lastOrderTotal",
                Double.valueOf(totalAmount)
        );

        session.setAttribute(
                "lastPaymentOption",
                paymentOption
        );

        session.setAttribute(
                "lastOrderStatus",
                "PLACED"
        );

        /*
         * CLEAR CART AFTER SUCCESSFUL ORDER
         */
        session.removeAttribute("cart");

        /*
         * RESPOND WITH SCRIPT TO CLEAR LOCALSTORAGE CART COUNT & REDIRECT
         */
        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().println(
            "<html>" +
            "<head><title>Order Success</title></head>" +
            "<body>" +
            "<script>" +
            "localStorage.setItem('foodtap_cart_count', '0');" +
            "localStorage.setItem('smartbite_cart_count', '0');" +
            "window.location.href = '" + request.getContextPath() + "/order-success.jsp?popup=1';" +
            "</script>" +
            "</body>" +
            "</html>"
        );

    } catch (Exception e) {

        e.printStackTrace();

        try {
            if (connection != null) {
                connection.rollback();
            }
        } catch (Exception rollbackException) {
            rollbackException.printStackTrace();
        }

        response.setContentType(
                "text/html;charset=UTF-8"
        );

        response.getWriter().println(
                "<html>" +
                "<head>" +
                "<title>FOODTAP Error</title>" +
                "</head>" +
                "<body style='font-family:Arial;padding:40px;'>" +

                "<h2>Order Processing Failed</h2>" +

                "<p>Please try placing the order again.</p>" +

                "<p><b>Payment Method:</b> " +
                escapeHtml(paymentOption) +
                "</p>" +

                "<p><b>Error:</b> " +
                escapeHtml(e.getMessage()) +
                "</p>" +

                "<br>" +

                "<a href='" +
                request.getContextPath() +
                "/checkout.jsp'>" +
                "Back to Checkout" +
                "</a>" +

                "</body>" +
                "</html>"
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

private void showMessage(
        HttpServletResponse response,
        String message)
        throws IOException {

    response.setContentType(
            "text/html;charset=UTF-8"
    );

    response.getWriter().println(
            "<html>" +
            "<head>" +
            "<title>FOODTAP</title>" +
            "</head>" +

            "<body style='font-family:Arial;padding:40px;'>" +

            "<h2>" +
            escapeHtml(message) +
            "</h2>" +

            "<br>" +

            "<a href='checkout.jsp'>" +
            "Back to Checkout" +
            "</a>" +

            "</body>" +
            "</html>"
    );
}

private String escapeHtml(String value) {

    if (value == null) {
        return "";
    }

    return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
}

}