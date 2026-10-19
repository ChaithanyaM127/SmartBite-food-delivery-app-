
package com.foodtap.daoimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;

import java.time.LocalDate;

import com.foodtap.dao.UserDAO;
import com.foodtap.model.User;
import com.foodtap.util.DBConnection;

public class UserDAOImpl implements UserDAO {

    @Override
    public boolean registerUser(User user) {

        String sql = "INSERT INTO `user` "
                   + "(name, email, password, phone, address, role) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getRole());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public User loginUser(String email, String password) {

        String sql = "SELECT * FROM `user` "
                   + "WHERE email = ? AND password = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    User user = new User();

                    user.setUserId(rs.getInt("userId"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setPhone(rs.getString("phone"));
                    user.setAddress(rs.getString("address"));
                    user.setRole(rs.getString("role"));

                    Date dob = rs.getDate("dateOfBirth");

                    if (dob != null) {
                        user.setDateOfBirth(dob.toLocalDate());
                    }

                    return user;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public boolean updateDateOfBirth(int userId, LocalDate dateOfBirth) {

        String sql = "UPDATE `user` SET dateOfBirth = ? WHERE userId = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            if (dateOfBirth == null) {
                ps.setNull(1, java.sql.Types.DATE);
            } else {
                ps.setDate(1, Date.valueOf(dateOfBirth));
            }

            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateProfile(User user) {

        String sql = "UPDATE `user` "
                   + "SET name = ?, email = ?, phone = ?, address = ? "
                   + "WHERE userId = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getAddress());
            ps.setInt(5, user.getUserId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
