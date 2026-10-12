package com.foodtap.dao;

import com.foodtap.model.HealthSummary;

public interface HealthSummaryDAO {

HealthSummary getTodayHealthSummary(int userId);

}