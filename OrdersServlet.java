package com.foodtap.servlet;

import java.io.IOException;
import java.util.List;

import com.foodtap.dao.OrderDAO;
import com.foodtap.daoimpl.OrderDAOImpl;
import com.foodtap.model.Order;
import com.foodtap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orders")
public class OrdersServlet extends HttpServlet {


private static final long serialVersionUID = 1L;

private OrderDAO orderDAO;

@Override
public void init() throws ServletException {
    orderDAO = new OrderDAOImpl();
}

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

    List<Order> orderList = orderDAO.getOrdersByUserId(user.getUserId());

    request.setAttribute("orderList", orderList);

    request.getRequestDispatcher("/orders.jsp").forward(request, response);
}


}
