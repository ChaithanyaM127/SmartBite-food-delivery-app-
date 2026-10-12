package com.foodtap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.foodtap.dao.OrderDAO;
import com.foodtap.model.Order;
import com.foodtap.util.DBConnection;

public class OrderDAOImpl implements OrderDAO {

    @Override
    public List<Order> getOrdersByUserId(int userId) {

        List<Order> orderList = new ArrayList<>();

        String sql = "SELECT * FROM orders "
                   + "WHERE userId = ? "
                   + "ORDER BY orderDate DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Order order = new Order();

                order.setOrderId(
                        rs.getInt("orderId"));

                order.setUserId(
                        rs.getInt("userId"));

                order.setRestaurantId(
                        rs.getInt("restaurantId"));

                order.setOrderDate(
                        rs.getTimestamp("orderDate"));

                order.setTotalAmount(
                        rs.getFloat("totalAmount"));

                order.setStatus(
                        rs.getString("status"));

                order.setPaymentOption(
                        rs.getString("paymentOption"));

                orderList.add(order);
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return orderList;
    }

    @Override
    public Order getOrderById(int orderId) {

        Order order = null;

        String sql = "SELECT * FROM orders "
                   + "WHERE orderId = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, orderId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                order = new Order();

                order.setOrderId(
                        rs.getInt("orderId"));

                order.setUserId(
                        rs.getInt("userId"));

                order.setRestaurantId(
                        rs.getInt("restaurantId"));

                order.setOrderDate(
                        rs.getTimestamp("orderDate"));

                order.setTotalAmount(
                        rs.getFloat("totalAmount"));

                order.setStatus(
                        rs.getString("status"));

                order.setPaymentOption(
                        rs.getString("paymentOption"));
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return order;
    }
}