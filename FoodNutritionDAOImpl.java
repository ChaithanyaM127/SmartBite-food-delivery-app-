package com.foodtap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.foodtap.dao.FoodNutritionDAO;
import com.foodtap.model.FoodNutrition;
import com.foodtap.util.DBConnection;

public class FoodNutritionDAOImpl implements FoodNutritionDAO {

    @Override
    public FoodNutrition getNutritionByMenuId(int menuId) {

        FoodNutrition nutrition = null;

        String sql = "SELECT * FROM foodnutrition WHERE menuId = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, menuId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                nutrition = new FoodNutrition();

                nutrition.setNutritionId(
                        rs.getInt("nutritionId"));

                nutrition.setMenuId(
                        rs.getInt("menuId"));

                nutrition.setProtein(
                        rs.getFloat("protein"));

                nutrition.setCarbs(
                        rs.getFloat("carbs"));

                nutrition.setCalories(
                        rs.getFloat("calories"));

                nutrition.setFiber(
                        rs.getFloat("fiber"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return nutrition;
    }
}