package com.foodtap.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.foodtap.dao.MenuDAO;
import com.foodtap.daoimpl.MenuDAOImpl;
import com.foodtap.model.CartItem;
import com.foodtap.model.Menu;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

private static final long serialVersionUID = 1L;
private MenuDAO menuDAO;

@Override
public void init() {
    menuDAO = new MenuDAOImpl();
}

@Override
protected void doGet(
        HttpServletRequest request,
        HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession();
    Object cartObject = session.getAttribute("cart");

    List<CartItem> cart = new ArrayList<>();
    if (cartObject instanceof List<?>) {
        for (Object obj : (List<?>) cartObject) {
            if (obj instanceof CartItem) {
                cart.add((CartItem) obj);
            }
        }
    }

    String action = request.getParameter("action");
    String menuIdParameter = request.getParameter("menuId");
    String mode = request.getParameter("mode"); // 'continue', 'cancelNew', 'cancelPrev'

    if (action == null && menuIdParameter != null && !menuIdParameter.trim().isEmpty()) {
        try {
            int menuId = Integer.parseInt(menuIdParameter);
            Menu menu = menuDAO.getMenuById(menuId);

            if (menu != null) {
                int existingRestaurantId = -1;
                for (CartItem item : cart) {
                    if (item.getMenu() != null) {
                        existingRestaurantId = item.getMenu().getRestaurantId();
                        break;
                    }
                }

                if (existingRestaurantId != -1 && existingRestaurantId != menu.getRestaurantId() && mode == null) {
                    response.setContentType("application/json");
                    response.getWriter().write("{\"status\": \"restaurantMismatch\", \"existingRestaurantId\": " + existingRestaurantId + ", \"newRestaurantId\": " + menu.getRestaurantId() + "}");
                    return;
                }

                if ("cancelNew".equals(mode)) {
                    response.setContentType("application/json");
                    int totalCount = calculateTotalQuantity(cart);
                    response.getWriter().write("{\"status\": \"cancelledNew\", \"cartCount\": " + totalCount + "}");
                    return;
                } else if ("cancelPrev".equals(mode)) {
                    cart.clear();
                }

                boolean alreadyExists = false;
                for (CartItem item : cart) {
                    if (item.getMenu() != null && item.getMenu().getMenuId() == menuId) {
                        item.setQuantity(item.getQuantity() + 1);
                        alreadyExists = true;
                        break;
                    }
                }

                if (!alreadyExists && !"cancelNew".equals(mode)) {
                    cart.add(new CartItem(menu, 1));
                }
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
    } else if ("increase".equals(action) && menuIdParameter != null) {
        int menuId = Integer.parseInt(menuIdParameter);
        for (CartItem item : cart) {
            if (item.getMenu() != null && item.getMenu().getMenuId() == menuId) {
                item.setQuantity(item.getQuantity() + 1);
                break;
            }
        }
    } else if ("decrease".equals(action) && menuIdParameter != null) {
        int menuId = Integer.parseInt(menuIdParameter);
        for (int i = 0; i < cart.size(); i++) {
            CartItem item = cart.get(i);
            if (item.getMenu() != null && item.getMenu().getMenuId() == menuId) {
                int newQty = item.getQuantity() - 1;
                if (newQty <= 0) cart.remove(i);
                else item.setQuantity(newQty);
                break;
            }
        }
    }

    session.setAttribute("cart", cart);
    
    int totalCount = calculateTotalQuantity(cart);
    response.setContentType("application/json");
    response.getWriter().write("{\"status\": \"success\", \"cartCount\": " + totalCount + "}");
}

private int calculateTotalQuantity(List<CartItem> cart) {
    int total = 0;
    for (CartItem item : cart) {
        total += item.getQuantity();
    }
    return total;
}
}