package com.foodtap.servlet;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.foodtap.dao.MenuDAO;
import com.foodtap.dao.OrderDAO;
import com.foodtap.dao.OrderItemDAO;
import com.foodtap.daoimpl.MenuDAOImpl;
import com.foodtap.daoimpl.OrderDAOImpl;
import com.foodtap.daoimpl.OrderItemDAOImpl;
import com.foodtap.model.Menu;
import com.foodtap.model.Order;
import com.foodtap.model.OrderItem;
import com.foodtap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/order-details")
public class OrderDetailsServlet extends HttpServlet {

private static final long serialVersionUID = 1L;

private OrderDAO orderDAO;
private OrderItemDAO orderItemDAO;
private MenuDAO menuDAO;

@Override
public void init() {
    orderDAO = new OrderDAOImpl();
    orderItemDAO = new OrderItemDAOImpl();
    menuDAO = new MenuDAOImpl();
}

@Override
protected void doGet(HttpServletRequest request,
                      HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession();

    User user = (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String orderIdParameter = request.getParameter("orderId");

    if (orderIdParameter == null || orderIdParameter.trim().isEmpty()) {
        response.sendRedirect("orders");
        return;
    }

    int orderId;

    try {
        orderId = Integer.parseInt(orderIdParameter);
    } catch (NumberFormatException e) {
        response.sendRedirect("orders");
        return;
    }

    Order order = orderDAO.getOrderById(orderId);

    if (order == null) {
        response.sendRedirect("orders");
        return;
    }

    if (order.getUserId() != user.getUserId()) {
        response.sendRedirect("orders");
        return;
    }

    List<OrderItem> orderItems =
            orderItemDAO.getOrderItemsByOrderId(orderId);

    Map<Integer, Menu> menuMap = new HashMap<>();

    for (OrderItem orderItem : orderItems) {

        Menu menu = menuDAO.getMenuById(orderItem.getMenuId());

        if (menu != null) {
            menuMap.put(orderItem.getMenuId(), menu);
        }
    }

    request.setAttribute("order", order);
    request.setAttribute("orderItems", orderItems);
    request.setAttribute("menuMap", menuMap);

    request.getRequestDispatcher("order-details.jsp")
           .forward(request, response);
}

}