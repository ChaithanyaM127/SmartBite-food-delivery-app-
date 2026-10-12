package com.foodtap.servlet;

import java.io.IOException;

import com.foodtap.dao.MenuDAO;
import com.foodtap.dao.FoodNutritionDAO;
import com.foodtap.daoimpl.MenuDAOImpl;
import com.foodtap.daoimpl.FoodNutritionDAOImpl;
import com.foodtap.model.Menu;
import com.foodtap.model.FoodNutrition;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;	

@WebServlet("/food-details")
public class FoodDetailsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private MenuDAO menuDAO;
    private FoodNutritionDAO nutritionDAO;

    @Override
    public void init() {

        menuDAO = new MenuDAOImpl();
        nutritionDAO = new FoodNutritionDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String menuIdParameter =
                request.getParameter("menuId");

        if (menuIdParameter == null ||
            menuIdParameter.trim().isEmpty()) {

            response.sendRedirect("restaurants");
            return;
        }

        try {

            int menuId =
                    Integer.parseInt(menuIdParameter);

            Menu menu =
                    menuDAO.getMenuById(menuId);

            if (menu == null) {

                response.sendRedirect("restaurants");
                return;
            }

            FoodNutrition nutrition =
                    nutritionDAO.getNutritionByMenuId(menuId);

            request.setAttribute("menu", menu);
            request.setAttribute("nutrition", nutrition);

            request.getRequestDispatcher("food-details.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {

            response.sendRedirect("restaurants");
        }
    }
}