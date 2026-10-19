
package com.foodtap.dao;

import java.time.LocalDate;
import com.foodtap.model.User;

public interface UserDAO {

    boolean registerUser(User user);

    User loginUser(String email, String password);

    boolean updateDateOfBirth(int userId, LocalDate dateOfBirth);

    boolean updateProfile(User user);
}
