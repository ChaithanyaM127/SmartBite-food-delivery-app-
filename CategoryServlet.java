package com.foodtap.servlet;

import java.io.IOException;
import java.util.List;

import com.foodtap.dao.CategoryDAO;
import com.foodtap.daoimpl.CategoryDAOImpl;
import com.foodtap.model.Menu;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/category")
public class CategoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private CategoryDAO categoryDAO;

    @Override
    public void init() {

        categoryDAO = new CategoryDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String category = request.getParameter("name");

        if (category == null || category.trim().isEmpty()) {

            response.sendRedirect("home.jsp");
            return;
        }

        List<Menu> menuList =
                categoryDAO.getMenuByCategory(category);

        request.setAttribute("menuList", menuList);
        request.setAttribute("selectedCategory", category);

        request.getRequestDispatcher("category.jsp")
               .forward(request, response);
    }
}