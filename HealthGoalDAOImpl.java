package com.foodtap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.foodtap.dao.HealthGoalDAO;
import com.foodtap.model.HealthGoal;
import com.foodtap.util.DBConnection;

public class HealthGoalDAOImpl implements HealthGoalDAO {

    @Override
    public HealthGoal getHealthGoalByUserId(int userId) {

        HealthGoal healthGoal = null;

        String sql = "SELECT * FROM healthgoal WHERE userId = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                healthGoal = new HealthGoal();

                healthGoal.setHealthGoalId(
                        rs.getInt("healthGoalId"));

                healthGoal.setUserId(
                        rs.getInt("userId"));

                healthGoal.setDailyCalorieGoal(
                        rs.getFloat("dailyCalorieGoal"));

                healthGoal.setCaloriesConsumed(
                        rs.getFloat("caloriesConsumed"));
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return healthGoal;
    }

    @Override
    public boolean createHealthGoal(HealthGoal healthGoal) {

        String sql = "INSERT INTO healthgoal "
                   + "(userId, dailyCalorieGoal, caloriesConsumed) "
                   + "VALUES (?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(
                    1,
                    healthGoal.getUserId());

            ps.setFloat(
                    2,
                    healthGoal.getDailyCalorieGoal());

            ps.setFloat(
                    3,
                    healthGoal.getCaloriesConsumed());

            int rows = ps.executeUpdate();

            return rows > 0;

        } catch (Exception e) {

            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateCaloriesConsumed(
            int userId,
            float caloriesConsumed) {

        String sql = "UPDATE healthgoal "
                   + "SET caloriesConsumed = ? "
                   + "WHERE userId = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setFloat(
                    1,
                    caloriesConsumed);

            ps.setInt(
                    2,
                    userId);

            int rows = ps.executeUpdate();

            return rows > 0;

        } catch (Exception e) {

            e.printStackTrace();
            return false;
        }
    }
}