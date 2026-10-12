package com.foodtap.dao;

import com.foodtap.model.FoodNutrition;

public interface FoodNutritionDAO {

    FoodNutrition getNutritionByMenuId(int menuId);
}