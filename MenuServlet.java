package com.foodtap.servlet;

import java.io.IOException;
import java.util.List;

import com.foodtap.dao.MenuDAO;
import com.foodtap.daoimpl.MenuDAOImpl;
import com.foodtap.model.Menu;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/menu")
public class MenuServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private MenuDAO menuDAO;

    @Override
    public void init() {
        menuDAO = new MenuDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String restaurantIdParameter =
                request.getParameter("restaurantId");

        if (restaurantIdParameter == null ||
            restaurantIdParameter.trim().isEmpty()) {

            response.sendRedirect("restaurants");
            return;
        }

        try {

            int restaurantId =
                    Integer.parseInt(restaurantIdParameter);

            List<Menu> menuList =
                    menuDAO.getMenuByRestaurantId(restaurantId);

            request.setAttribute("menuList", menuList);
            request.setAttribute("restaurantId", restaurantId);

            request.getRequestDispatcher("menu.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {

            response.sendRedirect("restaurants");
        }
    }
}