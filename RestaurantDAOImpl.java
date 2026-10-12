package com.foodtap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.foodtap.dao.RestaurantDAO;
import com.foodtap.model.Restaurant;
import com.foodtap.util.DBConnection;

public class RestaurantDAOImpl implements RestaurantDAO {

@Override
public List<Restaurant> getAllRestaurants() {

    List<Restaurant> restaurants = new ArrayList<>();

    String sql = "SELECT restaurantId, name, address, cuisineType, deliveryTime, rating, isActive, imagePath "
               + "FROM restaurant ORDER BY restaurantId";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement ps = connection.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {

            Restaurant restaurant = new Restaurant();

            restaurant.setRestaurantId(rs.getInt("restaurantId"));
            restaurant.setName(rs.getString("name"));
            restaurant.setAddress(rs.getString("address"));
            restaurant.setCuisineType(rs.getString("cuisineType"));
            restaurant.setDeliveryTime(rs.getInt("deliveryTime"));
            restaurant.setRating(rs.getFloat("rating"));
            restaurant.setIsActive(rs.getString("isActive"));
            restaurant.setImagePath(rs.getString("imagePath"));

            restaurants.add(restaurant);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return restaurants;
}

@Override
public Restaurant getRestaurantById(int restaurantId) {

    Restaurant restaurant = null;

    String sql = "SELECT restaurantId, name, address, cuisineType, deliveryTime, rating, isActive, imagePath "
               + "FROM restaurant WHERE restaurantId = ?";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement ps = connection.prepareStatement(sql)) {

        ps.setInt(1, restaurantId);

        try (ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {

                restaurant = new Restaurant();

                restaurant.setRestaurantId(rs.getInt("restaurantId"));
                restaurant.setName(rs.getString("name"));
                restaurant.setAddress(rs.getString("address"));
                restaurant.setCuisineType(rs.getString("cuisineType"));
                restaurant.setDeliveryTime(rs.getInt("deliveryTime"));
                restaurant.setRating(rs.getFloat("rating"));
                restaurant.setIsActive(rs.getString("isActive"));
                restaurant.setImagePath(rs.getString("imagePath"));
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return restaurant;
}

}