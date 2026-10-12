<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.foodtap.model.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    List<CartItem> cartList = new ArrayList<>();
    Object cartObject = session.getAttribute("cart");
    int initialCartCount = 0;
    if (cartObject instanceof List<?>) {
        for (Object obj : (List<?>) cartObject) {
            if (obj instanceof CartItem) {
                CartItem ci = (CartItem) obj;
                cartList.add(ci);
                initialCartCount += ci.getQuantity();
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Weather</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&amp;display=swap" rel="stylesheet">

<style type="text/css">
:root {
    --bg-page: #0d0d0f;
    --bg-card-dark: #121318;
    --text-main: #ffffff;
    --text-muted: #a1a1aa;
    --nav-bg: rgba(13, 13, 15, 0.90);
    --nav-border: rgba(255, 255, 255, 0.08);
    --panel-border: rgba(255, 255, 255, 0.08);
    --metric-bg: rgba(255, 255, 255, 0.04);
    --accent: #e23744;
    --accent-glow: rgba(226, 55, 68, 0.35);
    --shadow: 0 16px 36px rgba(0, 0, 0, 0.6);
}

body.light-mode {
    --bg-page: #f1f3f5;
    --bg-card-dark: #ffffff;
    --text-main: #111827;
    --text-muted: #6b7280;
    --nav-bg: rgba(255, 255, 255, 0.95);
    --nav-border: rgba(0, 0, 0, 0.08);
    --panel-border: rgba(0, 0, 0, 0.08);
    --metric-bg: rgba(0, 0, 0, 0.03);
    --shadow: 0 10px 25px rgba(0, 0, 0, 0.06);
}

html, body {
    margin: 0 !important;
    padding: 0 !important;
    background: linear-gradient(rgba(13, 13, 15, 0.90), rgba(13, 13, 15, 0.95)), url('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1600&q=80') !important;
    background-size: cover !important;
    background-attachment: fixed !important;
    background-position: center !important;
    color: var(--text-main) !important;
    font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif !important;
    min-height: 100vh;
    overflow-x: hidden;
    transition: background-color 0.3s ease, color 0.3s ease;
}

body.light-mode {
    background: linear-gradient(rgba(241, 243, 245, 0.92), rgba(241, 243, 245, 0.96)), url('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1600&q=80') !important;
    background-size: cover !important;
    background-attachment: fixed !important;
    background-position: center !important;
}

* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

/* Glassmorphism Sticky Navbar */
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
}

.theme-toggle-btn {
    background: transparent;
    border: none;
    cursor: pointer;
    font-size: 15px;
    color: var(--text-main);
}

/* Page Layout */
.container {
    max-width: 950px;
    margin: 50px auto 80px;
    padding: 0 20px;
}

.heading {
    text-align: center;
    margin-bottom: 35px;
}

.heading h1 {
    font-size: clamp(30px, 4.5vw, 40px);
    margin-bottom: 10px;
    font-weight: 800;
    letter-spacing: -0.5px;
    color: var(--text-main);
}

.heading h1 span {
    color: var(--accent);
}

.heading p {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
}

.weather-card {
    max-width: 650px;
    margin: auto;
    padding: 40px;
    border-radius: 20px;
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    box-shadow: var(--shadow);
    text-align: center;
}

.city-box {
    display: flex;
    gap: 10px;
    justify-content: center;
    margin-bottom: 30px;
    flex-wrap: wrap;
}

.city-box select {
    width: 250px;
    padding: 12px 16px;
    border-radius: 10px;
    border: 1px solid var(--panel-border);
    background: var(--metric-bg);
    color: var(--text-main);
    font-size: 14px;
    font-weight: 600;
    outline: none;
    font-family: 'Plus Jakarta Sans', sans-serif;
}

.city-box select:focus {
    border-color: var(--accent);
}

.city-box button {
    padding: 12px 22px;
    border: none;
    border-radius: 10px;
    background: var(--accent);
    color: white;
    font-weight: 800;
    font-size: 14px;
    cursor: pointer;
    transition: background 0.2s ease, transform 0.1s ease;
    box-shadow: 0 8px 20px rgba(226, 55, 68, 0.25);
}

.city-box button:hover {
    background: #d12e3b;
    transform: translateY(-2px);
}

.weather-icon {
    font-size: 64px;
    margin-bottom: 14px;
}

.temperature {
    font-size: 48px;
    font-weight: 800;
    margin-bottom: 4px;
    color: var(--text-main);
}

.condition {
    font-size: 18px;
    color: var(--accent);
    font-weight: 800;
    margin-bottom: 8px;
}

.city-name {
    color: var(--text-muted);
    font-size: 15px;
    font-weight: 600;
    margin-bottom: 25px;
}

.food-tip {
    margin-top: 25px;
    padding: 20px;
    border-radius: 12px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    text-align: left;
}

.food-tip h3 {
    color: var(--accent);
    font-size: 16px;
    font-weight: 800;
    margin-bottom: 6px;
}

.food-tip p {
    color: var(--text-muted);
    font-size: 13px;
    line-height: 1.5;
    font-weight: 600;
}

.back {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-top: 30px;
    padding: 12px 24px;
    border-radius: 10px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    color: var(--text-main);
    text-decoration: none;
    font-weight: 800;
    font-size: 14px;
    transition: border-color 0.2s ease, background 0.2s ease;
}

.back:hover {
    border-color: var(--accent);
    color: var(--accent);
}

footer {
    background: var(--bg-card-dark);
    border-top: 1px solid var(--panel-border);
    color: var(--text-muted);
    text-align: center;
    padding: 20px 24px;
    margin-top: 80px;
    font-size: 12px;
    font-weight: 600;
}
</style>
</head>
<body>

<%@ include file="animated-bg.jsp" %>

<!-- Navbar -->
<header class="navbar">
    <div class="nav-container">
        <a href="home.jsp" class="logo">Smart<span>Bite</span></a>
        <nav class="nav-links">
            <a href="home.jsp">Home</a>
            <a href="restaurants">Restaurants</a>
            <a href="orders.jsp" title="Orders">Orders</a>
            <a href="cart.jsp" title="Cart">🛒 Cart <span id="fta-cart-badge" style="background:#e23744; color:#fff; font-size:10px; font-weight:800; padding:2px 6px; border-radius:10px; margin-left:4px;">0</span></a>
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

<div class="container">
<div class="heading">
    <h1>SmartBite <span>Weather</span></h1>
    <p>Check the weather and discover what food matches your mood.</p>
</div>

<div class="weather-card">
    <div class="city-box">
        <select id="city">
            <option value="Bangalore">Bangalore</option>
            <option value="Mumbai">Mumbai</option>
            <option value="Delhi">Delhi</option>
            <option value="Chennai">Chennai</option>
            <option value="Hyderabad">Hyderabad</option>
            <option value="Kolkata">Kolkata</option>
        </select>
        <button onclick="showWeather()">Check Weather</button>
    </div>

    <div class="weather-icon" id="weatherIcon">🌧️</div>
    <div class="temperature" id="temperature">24°C</div>
    <div class="condition" id="condition">Rainy</div>
    <div class="city-name" id="cityName">Bangalore</div>

    <div class="food-tip">
        <h3 id="foodTitle">🌧️ Rainy in Bangalore?</h3>
        <p id="foodMessage">Perfect time for hot soups, biryani and delicious comfort food from SmartBite!</p>
    </div>

    <a href="home.jsp" class="back">&#8592; Back to SmartBite</a>
</div>
</div>

<script>
function showWeather() {
    const city = document.getElementById("city").value;
    const icon = document.getElementById("weatherIcon");
    const temperature = document.getElementById("temperature");
    const condition = document.getElementById("condition");
    const cityName = document.getElementById("cityName");
    const foodTitle = document.getElementById("foodTitle");
    const foodMessage = document.getElementById("foodMessage");
    
    cityName.innerText = city;
    if (city === "Bangalore") {
        icon.innerText = "🌧️"; temperature.innerText = "24°C"; condition.innerText = "Rainy";
        foodTitle.innerText = "🌧️ Rainy in Bangalore?"; foodMessage.innerText = "Perfect time for hot soups, biryani and delicious comfort food from SmartBite!";
    } else if (city === "Mumbai") {
        icon.innerText = "☁️"; temperature.innerText = "28°C"; condition.innerText = "Cloudy";
        foodTitle.innerText = "☁️ Cloudy in Mumbai?"; foodMessage.innerText = "Try some spicy street food, rolls or a delicious biryani.";
    } else if (city === "Delhi") {
        icon.innerText = "☀️"; temperature.innerText = "32°C"; condition.innerText = "Sunny";
        foodTitle.innerText = "☀️ Sunny in Delhi?"; foodMessage.innerText = "Cool down with fresh juices, shakes and refreshing beverages.";
    } else if (city === "Chennai") {
        icon.innerText = "🌤️"; temperature.innerText = "30°C"; condition.innerText = "Warm";
        foodTitle.innerText = "🌤️ Warm in Chennai?"; foodMessage.innerText = "Enjoy refreshing drinks, ice cream and South Indian favourites.";
    } else if (city === "Hyderabad") {
        icon.innerText = "☀️"; temperature.innerText = "31°C"; condition.innerText = "Sunny";
        foodTitle.innerText = "☀️ Sunny in Hyderabad?"; foodMessage.innerText = "How about some delicious biryani with a refreshing drink?";
    } else if (city === "Kolkata") {
        icon.innerText = "🌦️"; temperature.innerText = "27°C"; condition.innerText = "Light Rain";
        foodTitle.innerText = "🌦️ Rainy in Kolkata?"; foodMessage.innerText = "Enjoy hot snacks, momos, chai and comforting meals.";
    }
}

function updateBadgeCount(count) {
    var b = document.getElementById('fta-cart-badge');
    if (b) {
        b.textContent = count;
        localStorage.setItem("foodtap_cart_count", count);
        localStorage.setItem("smartbite_cart_count", count);
    }
}

// Theme & Brightness Management
(function() {
    const savedTheme = localStorage.getItem("smartbite_theme");
    if (savedTheme === "light") {
        document.body.classList.add("light-mode");
    }
    updateThemeButtonUI();

    var count = <%= initialCartCount %>;
    var savedCount = localStorage.getItem("foodtap_cart_count");
    if (savedCount !== null) {
        count = parseInt(savedCount, 10) || count;
    }
    updateBadgeCount(count);
})();

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

<%@ include file="ai-assistant.jsp" %>

<footer>
    <p>&copy; 2026 SmartBite Delivery Platform. All rights reserved.</p>
</footer>

</body>
</html>