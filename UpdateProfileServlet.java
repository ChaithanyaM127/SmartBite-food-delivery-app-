
package com.foodtap.servlet;

import java.io.IOException;

import com.foodtap.dao.UserDAO;
import com.foodtap.daoimpl.UserDAOImpl;
import com.foodtap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/update-profile")
public class UpdateProfileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(contextPath + "/login.jsp?redirect=home.jsp");
            return;
        }

        User loggedInUser = (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(contextPath + "/login.jsp?redirect=home.jsp");
            return;
        }

        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        name = name == null ? "" : name.trim();
        phone = phone == null ? "" : phone.trim();
        address = address == null ? "" : address.trim();

        if (name.isEmpty()
                || name.length() > 100
                || phone.length() > 20
                || address.length() > 500) {

            response.sendRedirect(contextPath + "/profile.jsp?profileStatus=invalid");
            return;
        }

        /*
         * Update only the editable profile fields.
         * Keep the user's ID, email, role, password, and birthday unchanged.
         */
        loggedInUser.setName(name);
        loggedInUser.setPhone(phone);
        loggedInUser.setAddress(address);

        boolean updated = userDAO.updateProfile(loggedInUser);

        if (updated) {
            session.setAttribute("loggedInUser", loggedInUser);
            response.sendRedirect(contextPath + "/profile.jsp?profileStatus=success");
        } else {
            response.sendRedirect(contextPath + "/profile.jsp?profileStatus=error");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(request.getContextPath() + "/profile.jsp");
    }
}
