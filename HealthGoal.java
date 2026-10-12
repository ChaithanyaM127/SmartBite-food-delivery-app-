package com.foodtap.model;

public class HealthGoal {

    private int healthGoalId;
    private int userId;
    private float dailyCalorieGoal;
    private float caloriesConsumed;

    public HealthGoal() {
    }

    public HealthGoal(int healthGoalId,
                      int userId,
                      float dailyCalorieGoal,
                      float caloriesConsumed) {

        this.healthGoalId = healthGoalId;
        this.userId = userId;
        this.dailyCalorieGoal = dailyCalorieGoal;
        this.caloriesConsumed = caloriesConsumed;
    }

    public HealthGoal(int userId,
                      float dailyCalorieGoal,
                      float caloriesConsumed) {

        this.userId = userId;
        this.dailyCalorieGoal = dailyCalorieGoal;
        this.caloriesConsumed = caloriesConsumed;
    }

    public int getHealthGoalId() {
        return healthGoalId;
    }

    public void setHealthGoalId(int healthGoalId) {
        this.healthGoalId = healthGoalId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public float getDailyCalorieGoal() {
        return dailyCalorieGoal;
    }

    public void setDailyCalorieGoal(float dailyCalorieGoal) {
        this.dailyCalorieGoal = dailyCalorieGoal;
    }

    public float getCaloriesConsumed() {
        return caloriesConsumed;
    }

    public void setCaloriesConsumed(float caloriesConsumed) {
        this.caloriesConsumed = caloriesConsumed;
    }
}