package com.foodtap.servlet;

import java.io.IOException;

import com.foodtap.dao.HealthSummaryDAO;
import com.foodtap.daoimpl.HealthSummaryDAOImpl;
import com.foodtap.model.HealthSummary;
import com.foodtap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/HealthSummaryServlet")
public class HealthSummaryServlet extends HttpServlet {

private static final long serialVersionUID = 1L;

private HealthSummaryDAO healthSummaryDAO;

@Override
public void init() throws ServletException {
    healthSummaryDAO = new HealthSummaryDAOImpl();
}

@Override
protected void doGet(
        HttpServletRequest request,
        HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession();

    User loggedInUser =
            (User) session.getAttribute("loggedInUser");

    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = loggedInUser.getUserId();

    HealthSummary summary =
            healthSummaryDAO.getTodayHealthSummary(userId);

    request.setAttribute(
            "healthSummary",
            summary);

    request.getRequestDispatcher(
            "home.jsp")
            .forward(request, response);
}

@Override
protected void doPost(
        HttpServletRequest request,
        HttpServletResponse response)
        throws ServletException, IOException {

    doGet(request, response);
}

}