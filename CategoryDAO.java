package com.foodtap.dao;

import java.util.List;
import com.foodtap.model.Menu;

public interface CategoryDAO {

    List<Menu> getMenuByCategory(String category);

}