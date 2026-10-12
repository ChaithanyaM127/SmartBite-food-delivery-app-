package com.foodtap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.foodtap.dao.MenuDAO;
import com.foodtap.model.Menu;
import com.foodtap.util.DBConnection;

public class MenuDAOImpl implements MenuDAO {

@Override
public List<Menu> getMenuByRestaurantId(int restaurantId) {

    List<Menu> menuList = new ArrayList<>();

    String sql =
            "SELECT menuId, restaurantId, name, description, price, isAvailable, imagePath "
            + "FROM ( "
            + "SELECT menuId, restaurantId, name, description, price, isAvailable, imagePath, "
            + "ROW_NUMBER() OVER (PARTITION BY restaurantId, name ORDER BY menuId) AS rn "
            + "FROM menu "
            + "WHERE restaurantId = ? "
            + "AND isAvailable = '1' "
            + ") AS filtered_menu "
            + "WHERE rn = 1 "
            + "ORDER BY menuId";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement ps = connection.prepareStatement(sql)) {

        ps.setInt(1, restaurantId);

        try (ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Menu menu = new Menu();

                menu.setMenuId(rs.getInt("menuId"));
                menu.setRestaurantId(rs.getInt("restaurantId"));
                menu.setName(rs.getString("name"));
                menu.setDescription(rs.getString("description"));
                menu.setPrice(rs.getFloat("price"));
                menu.setIsAvailable(rs.getString("isAvailable"));
                menu.setImagePath(rs.getString("imagePath"));

                menuList.add(menu);
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return menuList;
}

@Override
public Menu getMenuById(int menuId) {

    Menu menu = null;

    String sql =
            "SELECT menuId, restaurantId, name, description, price, isAvailable, imagePath "
            + "FROM menu "
            + "WHERE menuId = ?";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement ps = connection.prepareStatement(sql)) {

        ps.setInt(1, menuId);

        try (ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {

                menu = new Menu();

                menu.setMenuId(rs.getInt("menuId"));
                menu.setRestaurantId(rs.getInt("restaurantId"));
                menu.setName(rs.getString("name"));
                menu.setDescription(rs.getString("description"));
                menu.setPrice(rs.getFloat("price"));
                menu.setIsAvailable(rs.getString("isAvailable"));
                menu.setImagePath(rs.getString("imagePath"));
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return menu;
}

}