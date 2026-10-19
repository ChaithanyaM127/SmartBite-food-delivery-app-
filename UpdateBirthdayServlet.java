
package com.foodtap.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

import com.foodtap.dao.UserDAO;
import com.foodtap.daoimpl.UserDAOImpl;
import com.foodtap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/update-birthday")
public class UpdateBirthdayServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("loggedInUser") instanceof User)) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        User loggedInUser =
                (User) session.getAttribute("loggedInUser");

        String birthdayValue = request.getParameter("dateOfBirth");

        if (birthdayValue == null || birthdayValue.trim().isEmpty()) {
            response.sendRedirect(
                    contextPath + "/profile.jsp?birthdayStatus=invalid");
            return;
        }

        LocalDate dateOfBirth;

        try {
            dateOfBirth = LocalDate.parse(birthdayValue.trim());

            if (dateOfBirth.isAfter(LocalDate.now())) {
                response.sendRedirect(
                        contextPath + "/profile.jsp?birthdayStatus=invalid");
                return;
            }

        } catch (DateTimeParseException e) {
            response.sendRedirect(
                    contextPath + "/profile.jsp?birthdayStatus=invalid");
            return;
        }

        try {
            boolean updated = userDAO.updateDateOfBirth(
                    loggedInUser.getUserId(), dateOfBirth);

            if (updated) {
                loggedInUser.setDateOfBirth(dateOfBirth);
                session.setAttribute("loggedInUser", loggedInUser);

                response.sendRedirect(
                        contextPath + "/profile.jsp?birthdayStatus=success");
            } else {
                response.sendRedirect(
                        contextPath + "/profile.jsp?birthdayStatus=error");
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Unable to update birthday. Check the database connection and user table.",
                    e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath() + "/profile.jsp");
    }
}
