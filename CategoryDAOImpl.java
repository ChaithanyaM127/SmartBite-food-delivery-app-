package com.foodtap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.foodtap.dao.CategoryDAO;
import com.foodtap.model.Menu;
import com.foodtap.util.DBConnection;

public class CategoryDAOImpl implements CategoryDAO {

    @Override
    public List<Menu> getMenuByCategory(String category) {

        List<Menu> menuList = new ArrayList<>();

        String sql = "SELECT * FROM menu WHERE category = ? AND UPPER(isAvailable) = 'YES'";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)
        ) {

            ps.setString(1, category);

            ResultSet rs = ps.executeQuery();

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

        } catch (Exception e) {
            e.printStackTrace();
        }

        return menuList;
    }
}