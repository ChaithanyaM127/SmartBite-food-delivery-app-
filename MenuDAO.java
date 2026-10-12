package com.foodtap.dao;

import java.util.List;

import com.foodtap.model.Menu;

public interface MenuDAO {

    List<Menu> getMenuByRestaurantId(int restaurantId);

    Menu getMenuById(int menuId);
}