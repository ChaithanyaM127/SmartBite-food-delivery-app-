package com.foodtap.dao;

import java.util.List;

import com.foodtap.model.Order;

public interface OrderDAO {

    List<Order> getOrdersByUserId(int userId);

    Order getOrderById(int orderId);
}