package com.foodtap.dao;

import java.util.List;

import com.foodtap.model.Restaurant;

public interface RestaurantDAO {

    List<Restaurant> getAllRestaurants();

    Restaurant getRestaurantById(int restaurantId);
}