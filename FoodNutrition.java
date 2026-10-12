package com.foodtap.model;

public class FoodNutrition {

    private int nutritionId;
    private int menuId;
    private float protein;
    private float carbs;
    private float calories;
    private float fiber;

    public FoodNutrition() {
    }

    public FoodNutrition(int nutritionId, int menuId,
                         float protein, float carbs,
                         float calories, float fiber) {

        this.nutritionId = nutritionId;
        this.menuId = menuId;
        this.protein = protein;
        this.carbs = carbs;
        this.calories = calories;
        this.fiber = fiber;
    }

    public FoodNutrition(int menuId,
                         float protein, float carbs,
                         float calories, float fiber) {

        this.menuId = menuId;
        this.protein = protein;
        this.carbs = carbs;
        this.calories = calories;
        this.fiber = fiber;
    }

    public int getNutritionId() {
        return nutritionId;
    }

    public void setNutritionId(int nutritionId) {
        this.nutritionId = nutritionId;
    }

    public int getMenuId() {
        return menuId;
    }

    public void setMenuId(int menuId) {
        this.menuId = menuId;
    }

    public float getProtein() {
        return protein;
    }

    public void setProtein(float protein) {
        this.protein = protein;
    }

    public float getCarbs() {
        return carbs;
    }

    public void setCarbs(float carbs) {
        this.carbs = carbs;
    }

    public float getCalories() {
        return calories;
    }

    public void setCalories(float calories) {
        this.calories = calories;
    }

    public float getFiber() {
        return fiber;
    }

    public void setFiber(float fiber) {
        this.fiber = fiber;
    }
}