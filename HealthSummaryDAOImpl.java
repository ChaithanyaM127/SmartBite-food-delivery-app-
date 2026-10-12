package com.foodtap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.foodtap.dao.HealthSummaryDAO;
import com.foodtap.model.HealthSummary;
import com.foodtap.util.DBConnection;

public class HealthSummaryDAOImpl implements HealthSummaryDAO {

@Override
public HealthSummary getTodayHealthSummary(int userId) {

    HealthSummary summary = new HealthSummary();

    float calories = 0;
    float protein = 0;
    float carbs = 0;
    float fiber = 0;
    float calorieGoal = 1500;

    String nutritionSql =
            "SELECT " +
            "COALESCE(SUM(fn.calories * oi.quantity), 0) AS calories, " +
            "COALESCE(SUM(fn.protein * oi.quantity), 0) AS protein, " +
            "COALESCE(SUM(fn.carbs * oi.quantity), 0) AS carbs, " +
            "COALESCE(SUM(fn.fiber * oi.quantity), 0) AS fiber " +
            "FROM orders o " +
            "JOIN orderitem oi ON o.orderId = oi.orderId " +
            "JOIN foodnutrition fn ON oi.menuId = fn.menuId " +
            "WHERE o.userId = ? " +
            "AND DATE(o.orderDate) = CURDATE() " +
            "AND (o.status IS NULL OR o.status <> 'CANCELLED')";

    String goalSql =
            "SELECT dailyCalorieGoal " +
            "FROM healthgoal " +
            "WHERE userId = ?";

    try (Connection connection = DBConnection.getConnection()) {

        try (PreparedStatement ps =
                     connection.prepareStatement(nutritionSql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    calories = rs.getFloat("calories");
                    protein = rs.getFloat("protein");
                    carbs = rs.getFloat("carbs");
                    fiber = rs.getFloat("fiber");
                }
            }
        }

        try (PreparedStatement ps =
                     connection.prepareStatement(goalSql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    float databaseGoal =
                            rs.getFloat("dailyCalorieGoal");

                    if (databaseGoal > 0) {
                        calorieGoal = databaseGoal;
                    }
                }
            }
        }

    } catch (Exception e) {

        e.printStackTrace();
    }

    float caloriesRemaining =
            calorieGoal - calories;

    if (caloriesRemaining < 0) {
        caloriesRemaining = 0;
    }

    float percentageConsumed = 0;

    if (calorieGoal > 0) {

        percentageConsumed =
                (calories / calorieGoal) * 100;
    }

    summary.setCalories(calories);
    summary.setProtein(protein);
    summary.setCarbs(carbs);
    summary.setFiber(fiber);
    summary.setCalorieGoal(calorieGoal);
    summary.setCaloriesRemaining(caloriesRemaining);
    summary.setPercentageConsumed(percentageConsumed);

    return summary;
}

}