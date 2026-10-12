package com.foodtap.dao;

import com.foodtap.model.User;

public interface UserDAO {

    boolean registerUser(User user);

    User loginUser(String email, String password);
}