package com.foodtap.dao;

import java.util.List;

import com.foodtap.model.OrderItem;

public interface OrderItemDAO {


List<OrderItem> getOrderItemsByOrderId(int orderId);


}
