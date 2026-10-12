package com.foodtap.servlet;

import java.io.IOException;
import java.util.List;

import com.foodtap.dao.RestaurantDAO;
import com.foodtap.daoimpl.RestaurantDAOImpl;
import com.foodtap.model.Restaurant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/restaurants")
public class RestaurantServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private RestaurantDAO restaurantDAO;

    @Override
    public void init() {
        restaurantDAO = new RestaurantDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        List<Restaurant> restaurants =
                restaurantDAO.getAllRestaurants();

        request.setAttribute("restaurants", restaurants);

        request.getRequestDispatcher("restaurants.jsp")
               .forward(request, response);
    }
}