package com.foodtap.model;

public class Restaurant {

private int restaurantId;

private String name;

private String address;

private String cuisineType;

private int deliveryTime;

private float rating;

private String isActive;

private String imagePath;

public Restaurant() {

}

public Restaurant(int restaurantId, String name, String address,
                  String cuisineType, int deliveryTime,
                  float rating, String isActive) {

    this.restaurantId = restaurantId;

    this.name = name;

    this.address = address;

    this.cuisineType = cuisineType;

    this.deliveryTime = deliveryTime;

    this.rating = rating;

    this.isActive = isActive;

}

public Restaurant(int restaurantId, String name, String address,
                  String cuisineType, int deliveryTime,
                  float rating, String isActive, String imagePath) {

    this.restaurantId = restaurantId;

    this.name = name;

    this.address = address;

    this.cuisineType = cuisineType;

    this.deliveryTime = deliveryTime;

    this.rating = rating;

    this.isActive = isActive;

    this.imagePath = imagePath;

}

public int getRestaurantId() {

    return restaurantId;

}

public void setRestaurantId(int restaurantId) {

    this.restaurantId = restaurantId;

}

public String getName() {

    return name;

}

public void setName(String name) {

    this.name = name;

}

public String getAddress() {

    return address;

}

public void setAddress(String address) {

    this.address = address;

}

public String getCuisineType() {

    return cuisineType;

}

public void setCuisineType(String cuisineType) {

    this.cuisineType = cuisineType;

}

public int getDeliveryTime() {

    return deliveryTime;

}

public void setDeliveryTime(int deliveryTime) {

    this.deliveryTime = deliveryTime;

}

public float getRating() {

    return rating;

}

public void setRating(float rating) {

    this.rating = rating;

}

public String getIsActive() {

    return isActive;

}

public void setIsActive(String isActive) {

    this.isActive = isActive;

}

public String getImagePath() {

    return imagePath;

}

public void setImagePath(String imagePath) {

    this.imagePath = imagePath;

}

}