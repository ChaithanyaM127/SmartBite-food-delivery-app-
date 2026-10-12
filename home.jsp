<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.time.ZonedDateTime" %>
<%@ page import="com.foodtap.util.DBConnection" %>
<%@ page import="com.foodtap.dao.HealthSummaryDAO" %>
<%@ page import="com.foodtap.daoimpl.HealthSummaryDAOImpl" %>
<%@ page import="com.foodtap.model.HealthSummary" %>
<%@ page import="com.foodtap.model.User" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HealthSummary healthSummary = (HealthSummary) request.getAttribute("healthSummary");

    if (healthSummary == null) {
        try {
            User loggedInUser = (User) session.getAttribute("loggedInUser");
            if (loggedInUser != null && loggedInUser.getUserId() > 0) {
                HealthSummaryDAO healthSummaryDAO = new HealthSummaryDAOImpl();
                healthSummary = healthSummaryDAO.getTodayHealthSummary(loggedInUser.getUserId());
            }
        } catch (Exception e) {
            application.log("Unable to load today's health summary.", e);
        }
    }

    if (healthSummary == null) {
        healthSummary = new HealthSummary();
        healthSummary.setCalorieGoal(1500);
        healthSummary.setCalories(0);
        healthSummary.setCaloriesRemaining(1500);
        healthSummary.setPercentageConsumed(0);
        healthSummary.setProtein(0);
        healthSummary.setCarbs(0);
        healthSummary.setFiber(0);
    }

    float healthCalories = healthSummary.getCalories();
    float healthGoal = healthSummary.getCalorieGoal();
    if (healthGoal <= 0) healthGoal = 1500;

    float healthRemaining = Math.max(0, healthGoal - healthCalories);
    float healthPercentage = Math.min(100, Math.max(0, (healthCalories / healthGoal) * 100));
    int circlePercentage = Math.round(healthPercentage);

    String healthQuote;
    if (healthCalories <= 0) {
        healthQuote = "🔥 Fuel your hustle! Pick a balanced meal to conquer your daily goals.";
    } else if (healthCalories < healthGoal * 0.5f) {
        healthQuote = "⚡ You're in the sweet spot! Treat yourself to a delicious, nutrient-packed dish.";
    } else if (healthCalories < healthGoal * 0.85f) {
        healthQuote = "🎯 Perfect progress today! Smart choices lead to great energy.";
    } else if (healthCalories <= healthGoal) {
        healthQuote = "✨ Almost at your daily goal! Fuel up with high-protein or lighter bites.";
    } else {
        healthQuote = "🏆 Goal achieved! Explore lightweight salads, green juices, or healthy desserts.";
    }

    LocalTime now = LocalTime.now(ZoneId.of("Asia/Kolkata"));
    LocalTime openTime = LocalTime.of(10, 0);
    LocalTime closeTime = LocalTime.of(23, 0);
    boolean isRestaurantOpen = !now.isBefore(openTime) && !now.isAfter(closeTime);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Discover &amp; Order Food</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&amp;display=swap" rel="stylesheet">

<style type="text/css">
:root {
    --bg-page: #0d0d0f;
    --bg-card-dark: #121318;
    --bg-card-bottom: #1e1e24; 
    --text-main: #ffffff;
    --text-muted: #a1a1aa;
    --text-bottom-main: #f4f4f5;
    --text-bottom-sub: #a1a1aa;
    --nav-bg: rgba(13, 13, 15, 0.90);
    --nav-border: rgba(255, 255, 255, 0.08);
    --panel-border: rgba(255, 255, 255, 0.08);
    --metric-bg: rgba(255, 255, 255, 0.04);
    --accent: #e23744;
    --accent-glow: rgba(226, 55, 68, 0.35);
    --accent-gradient: linear-gradient(135deg, #ff4757 0%, #e23744 100%);
    --green-badge: #24963f;
    --shadow: 0 16px 36px rgba(0, 0, 0, 0.6);
}

body.light-mode {
    --bg-page: #f1f3f5;
    --bg-card-dark: #ffffff;
    --bg-card-bottom: #ffffff;
    --text-main: #111827;
    --text-muted: #6b7280;
    --text-bottom-main: #111827;
    --text-bottom-sub: #4b5563;
    --nav-bg: rgba(255, 255, 255, 0.95);
    --nav-border: rgba(0, 0, 0, 0.08);
    --panel-border: rgba(0, 0, 0, 0.08);
    --metric-bg: rgba(0, 0, 0, 0.03);
    --shadow: 0 10px 25px rgba(0, 0, 0, 0.06);
}

html, body {
    margin: 0 !important;
    padding: 0 !important;
    background-color: var(--bg-page) !important;
    color: var(--text-main) !important;
    font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif !important;
    min-height: 100vh;
    overflow-x: hidden;
}

* {
    box-sizing: border-box;
}

.navbar {
    background: var(--nav-bg);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border-bottom: 1px solid var(--nav-border);
    position: sticky;
    top: 0;
    z-index: 1000;
    width: 100%;
}

.nav-container {
    max-width: 1320px;
    margin: 0 auto;
    padding: 14px 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo {
    font-size: 26px;
    font-weight: 800;
    color: var(--text-main);
    text-decoration: none;
    letter-spacing: -0.5px;
}

.logo span {
    color: var(--accent);
}

.nav-links {
    display: flex;
    gap: 22px;
    align-items: center;
}

.nav-links a {
    text-decoration: none;
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 6px;
}

.nav-links a:hover, .nav-links a.active {
    color: var(--accent);
}

.profile-avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    text-decoration: none;
    transition: transform 0.2s ease, border-color 0.2s ease;
}

.profile-avatar:hover {
    transform: scale(1.08);
    border-color: var(--accent);
}

.controls-box {
    display: flex;
    align-items: center;
    gap: 10px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    padding: 5px 12px;
    border-radius: 30px;
}

.brightness-slider {
    width: 60px;
    height: 3px;
    accent-color: var(--accent);
    cursor: pointer;
    background: var(--text-muted);
    border-radius: 2px;
    appearance: none;
}

.brightness-slider::-webkit-slider-thumb {
    appearance: none;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: var(--accent);
    cursor: pointer;
}

.theme-toggle-btn {
    background: transparent;
    border: none;
    cursor: pointer;
    font-size: 15px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0;
    color: var(--text-main);
}

.hero-section {
    background: linear-gradient(rgba(13, 13, 15, 0.75), rgba(13, 13, 15, 0.85)), url('https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1600&q=80');
    background-size: cover;
    background-position: center;
    color: white;
    padding: 100px 24px 90px;
    text-align: center;
    position: relative;
    border-bottom: 1px solid var(--panel-border);
}

.hero-content {
    max-width: 760px;
    margin: 0 auto;
    position: relative;
    z-index: 2;
}

.hero-content h1 {
    font-size: clamp(36px, 5vw, 54px);
    font-weight: 800;
    margin-bottom: 16px;
    line-height: 1.15;
    letter-spacing: -1px;
    color: #ffffff;
    text-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);
}

.hero-content p {
    font-size: 16px;
    margin-bottom: 28px;
    color: #e2e8f0;
    line-height: 1.6;
}

.hero-buttons {
    display: flex;
    gap: 14px;
    justify-content: center;
    flex-wrap: wrap;
}

.btn-primary, .btn-secondary {
    padding: 14px 28px;
    border-radius: 12px;
    font-weight: 800;
    font-size: 14px;
    text-decoration: none;
    cursor: pointer;
    border: none;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

.btn-primary {
    background: var(--accent-gradient);
    color: white;
    box-shadow: 0 10px 25px var(--accent-glow);
}

.btn-secondary {
    background: rgba(0, 0, 0, 0.5);
    color: white;
    border: 1px solid rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(10px);
}

.main-container {
    max-width: 1320px;
    margin: 40px auto;
    padding: 0 24px;
    width: 100%;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    margin-bottom: 20px;
}

.section-header h2 {
    font-size: 24px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.5px;
}

.section-header a {
    color: var(--accent);
    text-decoration: none;
    font-weight: 800;
    font-size: 13px;
}

.restaurant-grid-wrapper {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
    margin: 0;
    padding: 0;
}

.restaurant-square-card {
    width: 25%;
    box-sizing: border-box;
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    overflow: hidden;
    background: var(--bg-card-dark);
    text-decoration: none;
    display: flex;
    flex-direction: column;
    cursor: pointer;
    transition: transform 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
    box-shadow: var(--shadow);
}

.restaurant-square-card:hover {
    border-color: var(--accent);
    transform: translateY(-3px);
}

.card-part-top-black {
    background: #0d0d0f !important;
    color: #ffffff !important;
    padding-bottom: 12px;
    position: relative;
}

.card-img-box {
    position: relative;
    height: 160px;
    width: 100%;
    background: #000000;
    overflow: hidden;
}

.card-img-box img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.rating-badge {
    position: absolute;
    top: 10px;
    right: 10px;
    background: #24963f;
    color: #ffffff;
    font-size: 11px;
    font-weight: 800;
    padding: 4px 8px;
    border-radius: 6px;
}

.status-badge {
    position: absolute;
    top: 10px;
    left: 10px;
    font-size: 11px;
    font-weight: 800;
    padding: 4px 10px;
    border-radius: 6px;
    color: #ffffff;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.4);
}

.status-badge.open {
    background: #24963f;
}

.status-badge.closed {
    background: #e23744;
}

.restaurant-title-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 12px 14px 0 14px;
}

.restaurant-title {
    font-size: 17px;
    font-weight: 800;
    color: #ffffff !important;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    flex: 1;
}

.card-part-bottom-charcoal {
    background: var(--bg-card-bottom) !important;
    color: var(--text-bottom-main) !important;
    padding: 12px 14px 14px 14px;
    display: flex;
    flex-direction: column;
    flex: 1;
    border-top: 1px solid var(--panel-border);
}

.cuisine-text {
    font-size: 13px;
    color: var(--text-bottom-sub) !important;
    margin: 0 0 8px 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.timing-text {
    font-size: 12px;
    font-weight: 700;
    color: #059669 !important;
    margin-bottom: 12px;
}

body.light-mode .timing-text {
    color: #047857 !important;
}

.meta-footer-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid var(--panel-border);
    padding-top: 10px;
    margin-top: auto;
}

.delivery-time {
    font-size: 12px;
    color: var(--text-bottom-sub) !important;
    font-weight: 600;
}

.view-menu-btn-red {
    background: #e23744 !important;
    color: #ffffff !important;
    padding: 7px 13px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 800;
    text-decoration: none;
    display: inline-block;
}

.health-weather-grid {
    display: grid;
    grid-template-columns: 1.8fr 1.2fr;
    gap: 24px;
    margin-top: 50px;
}

.panel-health {
    background: linear-gradient(rgba(13, 13, 15, 0.88), rgba(13, 13, 15, 0.96)), url('https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=1200&q=80');
    background-size: cover;
    background-position: center;
    border: 1px solid var(--panel-border);
    border-radius: 20px;
    padding: 26px;
    box-shadow: var(--shadow);
    position: relative;
    overflow: hidden;
}

body.light-mode .panel-health {
    background: linear-gradient(rgba(255, 255, 255, 0.92), rgba(248, 250, 252, 0.96)), url('https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=1200&q=80');
    background-size: cover;
    background-position: center;
}

.health-quote-banner {
    background: rgba(226, 55, 68, 0.15);
    border: 1px solid rgba(226, 55, 68, 0.35);
    border-radius: 12px;
    padding: 12px 16px;
    font-size: 13px;
    font-weight: 700;
    color: #e23744;
    margin-bottom: 22px;
    display: flex;
    align-items: center;
    gap: 8px;
    backdrop-filter: blur(8px);
}

.calorie-progress-container {
    display: flex;
    align-items: center;
    gap: 24px;
    margin-bottom: 24px;
}

.conic-ring-box {
    position: relative;
    width: 100px;
    height: 100px;
    border-radius: 50%;
    background: conic-gradient(var(--accent) <%= circlePercentage %>%, rgba(0, 0, 0, 0.08) 0%);
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 0 18px var(--accent-glow);
}

.conic-ring-box::before {
    content: "";
    position: absolute;
    inset: 10px;
    background: var(--bg-card-dark);
    border-radius: 50%;
}

.conic-ring-text {
    position: relative;
    z-index: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}

.conic-ring-text strong {
    font-size: 20px;
    font-weight: 800;
    color: var(--text-main);
}

.conic-ring-text span {
    font-size: 10px;
    color: var(--text-muted);
    font-weight: 700;
    text-transform: uppercase;
}

.nutrition-metrics {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
}

.metric-card-enhanced {
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    padding: 14px 10px;
    border-radius: 14px;
    text-align: center;
    backdrop-filter: blur(6px);
    transition: transform 0.2s ease, border-color 0.2s ease;
}

.metric-card-enhanced:hover {
    transform: translateY(-3px);
    border-color: rgba(226, 55, 68, 0.5);
}

.metric-card-enhanced span {
    font-size: 10px;
    color: var(--text-muted);
    font-weight: 800;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    display: block;
    margin-bottom: 4px;
}

.metric-card-enhanced strong {
    font-size: 18px;
    font-weight: 800;
    color: var(--text-main);
}

.panel-weather-animated {
    background: linear-gradient(rgba(15, 23, 42, 0.88), rgba(15, 23, 42, 0.96)), url('https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=1200&q=80');
    background-size: cover;
    background-position: center;
    border: 1px solid var(--panel-border);
    border-radius: 20px;
    padding: 26px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    box-shadow: var(--shadow);
    position: relative;
    overflow: hidden;
    color: #ffffff;
}

.weather-live-indicator {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 1px;
    text-transform: uppercase;
    background: rgba(36, 150, 63, 0.25);
    color: #4ade80;
    padding: 5px 12px;
    border-radius: 20px;
    border: 1px solid rgba(74, 222, 128, 0.4);
    backdrop-filter: blur(6px);
}

.live-dot {
    width: 6px;
    height: 6px;
    background: #4ade80;
    border-radius: 50%;
    animation: liveBlink 1.5s infinite;
}

@keyframes liveBlink {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.3; }
}

.weather-temp-hero {
    font-size: 42px;
    font-weight: 800;
    color: #ffffff;
    margin: 12px 0 2px 0;
    letter-spacing: -1px;
    display: flex;
    align-items: center;
    gap: 14px;
}

.weather-icon-3d-animated {
    width: 58px;
    height: 58px;
    object-fit: contain;
    filter: drop-shadow(0 10px 15px rgba(255, 184, 0, 0.4));
    animation: float3DIcon 3.5s ease-in-out infinite;
}

@keyframes float3DIcon {
    0%, 100% {
        transform: translateY(0px) rotate(0deg);
        filter: drop-shadow(0 10px 15px rgba(255, 184, 0, 0.4));
    }
    50% {
        transform: translateY(-8px) rotate(3deg);
        filter: drop-shadow(0 18px 25px rgba(255, 184, 0, 0.6));
    }
}

.weather-condition-desc {
    font-size: 14px;
    font-weight: 600;
    color: #cbd5e1;
}

.weather-quote-box {
    background: rgba(255, 255, 255, 0.08);
    border-top: 1px solid rgba(255, 255, 255, 0.12);
    padding-top: 14px;
    margin-top: 20px;
    font-size: 13px;
    font-weight: 700;
    color: #f1f5f9;
    line-height: 1.5;
    backdrop-filter: blur(6px);
}

footer {
    background: var(--bg-card-dark);
    border-top: 1px solid var(--panel-border);
    color: var(--text-muted);
    text-align: center;
    padding: 30px 24px;
    margin-top: 50px;
    font-size: 12px;
    font-weight: 600;
}

@media (max-width: 1200px) {
    .restaurant-square-card { width: 33.333%; }
}

@media (max-width: 900px) {
    .restaurant-square-card { width: 50%; }
    .health-weather-grid { grid-template-columns: 1fr; }
}

@media (max-width: 600px) {
    .restaurant-square-card { width: 100%; }
}
</style>
</head>
<body>

    <header class="navbar">
        <div class="nav-container">
            <a href="home.jsp" class="logo">Smart<span>Bite</span></a>
            <nav class="nav-links">
                <a href="home.jsp" class="active">Home</a>
                <a href="restaurants">Restaurants</a>
                <a href="orders.jsp" title="Orders">Orders</a>
                <a href="cart.jsp" title="Cart">🛒 Cart</a>
                <a href="profile.jsp" class="profile-avatar" title="Profile">👤</a>
                
                <div class="controls-box">
                    <input type="range" min="0.5" max="1.5" step="0.05" value="1" class="brightness-slider" id="brightnessSlider" oninput="adjustBrightness(this.value)" title="Adjust Brightness">
                    <button class="theme-toggle-btn" id="themeToggleBtn" onclick="toggleTheme()" title="Toggle Light/Dark Theme">
                        <span id="themeIcon">🌙</span>
                    </button>
                </div>
            </nav>
        </div>
    </header>

    <section class="hero-section">
        <div class="hero-content">
            <h1>Discover the best food &amp; drinks in Bengaluru</h1>
            <p>Explore elite local kitchens, track your nutrition effortlessly, and let Tapu AI curate your next meal.</p>
            <div class="hero-buttons">
                <a href="restaurants" class="btn-primary">Explore Restaurants →</a>
                <button type="button" class="btn-secondary" onclick="ftaAsk('what should i eat')">Ask Tapu AI ✳</button>
            </div>
        </div>
    </section>

    <main class="main-container">

        <section>
            <div class="section-header">
                <h2>Trending Restaurants</h2>
                <a href="restaurants">See all restaurants →</a>
            </div>

            <div class="restaurant-grid-wrapper">
                <%
                    Connection con = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;

                    try {
                        con = DBConnection.getConnection();
                        String sql = "SELECT restaurantId, name, cuisineType, deliveryTime, rating, imagePath FROM restaurant ORDER BY restaurantId";
                        ps = con.prepareStatement(sql);
                        rs = ps.executeQuery();

                        while (rs.next()) {
                            int restaurantId = rs.getInt("restaurantId");
                            String name = rs.getString("name");
                            String cuisine = rs.getString("cuisineType");
                            String image = rs.getString("imagePath");
                            int delivery = rs.getInt("deliveryTime");
                            double rating = rs.getDouble("rating");

                            if (name == null) name = "Biryani House";
                            if (cuisine == null) cuisine = "Indian, Biryani";
                            if (image == null) image = "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80";
                %>

                <form action="menu" method="get" onclick="this.submit();" class="restaurant-square-card">
                    <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                    
                    <div class="card-part-top-black">
                        <div class="card-img-box">
                            <img src="<%= image %>" alt="<%= name %>">
                            
                            <% if (isRestaurantOpen) { %>
                                <span class="status-badge open">OPEN</span>
                            <% } else { %>
                                <span class="status-badge closed">CLOSED</span>
                            <% } %>

                            <span class="rating-badge">★ <%= String.format("%.1f", rating) %></span>
                        </div>
                        
                        <div class="restaurant-title-row">
                            <div class="restaurant-title"><%= name %></div>
                        </div>
                    </div>

                    <div class="card-part-bottom-charcoal">
                        <div class="cuisine-text"><%= cuisine %></div>
                        <div class="timing-text">🕒 10:00 AM - 11:00 PM</div>
                        <div class="meta-footer-row">
                            <span class="delivery-time">◷ <%= delivery %> mins</span>
                            <span class="view-menu-btn-red">View Menu →</span>
                        </div>
                    </div>
                </form>

                <%
                        }
                    } catch (Exception e) {
                        application.log("Error loading restaurants", e);
                    } finally {
                        if (rs != null) try { rs.close(); } catch(Exception e){}
                        if (ps != null) try { ps.close(); } catch(Exception e){}
                        if (con != null) try { con.close(); } catch(Exception e){}
                    }
                %>
            </div>
        </section>

        <section class="health-weather-grid">
            
            <div class="panel-health">
                <div class="health-quote-banner">
                    <%= healthQuote %>
                </div>

                <div class="calorie-progress-container">
                    <div class="conic-ring-box">
                        <div class="conic-ring-text">
                            <strong><%= circlePercentage %>%</strong>
                            <span>Goal</span>
                        </div>
                    </div>

                    <div>
                        <div style="font-size: 24px; font-weight: 800; color: var(--text-main);"><%= String.format("%.0f", healthCalories) %> <span style="font-size: 14px; color: var(--text-muted);">/ <%= String.format("%.0f", healthGoal) %> kcal</span></div>
                        <div style="font-size: 13px; color: var(--text-muted); margin-top: 4px; font-weight: 600;"><%= String.format("%.0f", healthRemaining) %> kcal remaining for today</div>
                    </div>
                </div>

                <div class="nutrition-metrics">
                    <div class="metric-card-enhanced">
                        <span>Protein</span>
                        <strong><%= String.format("%.1f", healthSummary.getProtein()) %>g</strong>
                    </div>
                    <div class="metric-card-enhanced">
                        <span>Carbs</span>
                        <strong><%= String.format("%.1f", healthSummary.getCarbs()) %>g</strong>
                    </div>
                    <div class="metric-card-enhanced">
                        <span>Fiber</span>
                        <strong><%= String.format("%.1f", healthSummary.getFiber()) %>g</strong>
                    </div>
                </div>
            </div>

            <div class="panel-weather-animated">
                <div>
                    <div class="weather-live-indicator">
                        <span class="live-dot"></span> BENGALURU • LIVE
                    </div>
                    
                    <div class="weather-temp-hero">
                        <span id="weatherTemperature">--°C</span>
                        <img id="weatherIcon3D" class="weather-icon-3d-animated" src="https://cdn-icons-png.flaticon.com/512/1163/1163661.png" alt="Live Weather">
                    </div>
                    
                    <div class="weather-condition-desc" id="weatherCondition">Fetching live weather...</div>
                </div>

                <div class="weather-quote-box" id="weatherRecommendation">
                    🍽️ Perfect weather to pair your favorite dishes with hot beverages or fresh bowls!
                </div>
            </div>

        </section>

    </main>

    <%@ include file="ai-assistant.jsp" %>

    <footer>
        <p>&copy; 2026 SmartBite Delivery Platform. All rights reserved.</p>
    </footer>

    <script>
        (function() {
            const savedTheme = localStorage.getItem("smartbite_theme");
            if (savedTheme === "light") {
                document.body.classList.add("light-mode");
            }
            updateThemeButtonUI();
        })();

        window.addEventListener("load", function () {
            fetch("https://api.open-meteo.com/v1/forecast?latitude=12.9716&longitude=77.5946&current=temperature_2m,weather_code&timezone=Asia%2FKolkata")
                .then(res => res.json())
                .then(data => {
                    if (!data.current) return;
                    const temp = Math.round(data.current.temperature_2m);
                    const code = data.current.weather_code;

                    document.getElementById("weatherTemperature").textContent = temp + "°C";

                    let condition = "Pleasant Weather";
                    let icon3D = "https://cdn-icons-png.flaticon.com/512/1163/1163661.png";
                    let quote = "🍽️ Perfect weather for ordering your favorite hot meals or refreshing drinks!";

                    if (temp > 30) {
                        condition = "Sunny & Warm";
                        icon3D = "https://cdn-icons-png.flaticon.com/512/869/869869.png";
                        quote = "🥤 It's warm outside! Cool off with chilled beverages, fresh smoothies & light salads.";
                    } else if (temp < 22) {
                        condition = "Cool Breeze";
                        icon3D = "https://cdn-icons-png.flaticon.com/512/3054/3054889.png";
                        quote = "🍲 Chilly weather vibes! Treat yourself to hot soups, biryani, or steaming chai.";
                    } else if (code >= 51) {
                        condition = "Rainy Vibes";
                        icon3D = "https://cdn-icons-png.flaticon.com/512/1163/1163657.png";
                        quote = "🌧️ Rainy weather calls for crispy starters, hot noodles & comforting bowls!";
                    }

                    document.getElementById("weatherCondition").textContent = condition;
                    document.getElementById("weatherIcon3D").src = icon3D;
                    document.getElementById("weatherRecommendation").textContent = quote;
                })
                .catch(err => console.log(err));
        });

        function toggleTheme() {
            document.body.classList.toggle("light-mode");
            const isLight = document.body.classList.contains("light-mode");
            localStorage.setItem("smartbite_theme", isLight ? "light" : "dark");
            updateThemeButtonUI();
        }

        function updateThemeButtonUI() {
            const isLight = document.body.classList.contains("light-mode");
            const themeIcon = document.getElementById("themeIcon");
            if (themeIcon) {
                themeIcon.textContent = isLight ? "☀️" : "🌙";
            }
        }

        function adjustBrightness(val) {
            document.documentElement.style.filter = "brightness(" + val + ")";
            localStorage.setItem("smartbite_brightness", val);
        }
    </script>

</body>
</html>