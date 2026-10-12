package com.foodtap.dao;

import com.foodtap.model.HealthGoal;

public interface HealthGoalDAO {

    HealthGoal getHealthGoalByUserId(int userId);

    boolean createHealthGoal(HealthGoal healthGoal);

    boolean updateCaloriesConsumed(int userId, float caloriesConsumed);
}