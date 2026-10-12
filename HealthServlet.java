package com.foodtap.servlet;

import java.io.IOException;

import com.foodtap.dao.HealthGoalDAO;
import com.foodtap.daoimpl.HealthGoalDAOImpl;
import com.foodtap.model.HealthGoal;
import com.foodtap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/health")
public class HealthServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private HealthGoalDAO healthGoalDAO;

    @Override
    public void init() {

        healthGoalDAO = new HealthGoalDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        User user =
                (User) session.getAttribute("loggedInUser");

        // Check login
        if (user == null) {

            response.sendRedirect("login.jsp");
            return;
        }

        int userId = user.getUserId();

        // Get existing health goal
        HealthGoal healthGoal =
                healthGoalDAO.getHealthGoalByUserId(userId);

        // Create health goal if it does not exist
        if (healthGoal == null) {

            healthGoal = new HealthGoal(
                    userId,
                    1500,
                    0
            );

            boolean created =
                    healthGoalDAO.createHealthGoal(
                            healthGoal
                    );

            if (created) {

                healthGoal =
                        healthGoalDAO
                                .getHealthGoalByUserId(userId);
            }
        }

        // Send health data to JSP
        request.setAttribute(
                "healthGoal",
                healthGoal
        );

        request.getRequestDispatcher(
                "health.jsp"
        ).forward(request, response);
    }
}