package com.foodtap.model;

public class HealthSummary {

private float calories;
private float protein;
private float carbs;
private float fiber;
private float calorieGoal;
private float caloriesRemaining;
private float percentageConsumed;

public HealthSummary() {

}

public float getCalories() {
    return calories;
}

public void setCalories(float calories) {
    this.calories = calories;
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

public float getFiber() {
    return fiber;
}

public void setFiber(float fiber) {
    this.fiber = fiber;
}

public float getCalorieGoal() {
    return calorieGoal;
}

public void setCalorieGoal(float calorieGoal) {
    this.calorieGoal = calorieGoal;
}

public float getCaloriesRemaining() {
    return caloriesRemaining;
}

public void setCaloriesRemaining(float caloriesRemaining) {
    this.caloriesRemaining = caloriesRemaining;
}

public float getPercentageConsumed() {
    return percentageConsumed;
}

public void setPercentageConsumed(float percentageConsumed) {
    this.percentageConsumed = percentageConsumed;
}

}