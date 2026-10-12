package com.foodtap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.foodtap.dao.OrderItemDAO;
import com.foodtap.model.OrderItem;
import com.foodtap.util.DBConnection;

public class OrderItemDAOImpl implements OrderItemDAO {


@Override
public List<OrderItem> getOrderItemsByOrderId(int orderId) {

    List<OrderItem> orderItemList = new ArrayList<>();

    String sql = "SELECT orderItemId, orderId, menuId, quantity, itemTotal "
               + "FROM orderitem "
               + "WHERE orderId = ? "
               + "ORDER BY orderItemId";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement ps = connection.prepareStatement(sql)) {

        ps.setInt(1, orderId);

        try (ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                OrderItem orderItem = new OrderItem();

                orderItem.setOrderItemId(
                        rs.getInt("orderItemId"));

                orderItem.setOrderId(
                        rs.getInt("orderId"));

                orderItem.setMenuId(
                        rs.getInt("menuId"));

                orderItem.setQuantity(
                        rs.getInt("quantity"));

                orderItem.setItemTotal(
                        rs.getFloat("itemTotal"));

                orderItemList.add(orderItem);
            }
        }

    } catch (Exception e) {

        e.printStackTrace();
    }

    return orderItemList;
}


}
