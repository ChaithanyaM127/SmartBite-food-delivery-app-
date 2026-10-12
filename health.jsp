<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.foodtap.model.HealthGoal"%>
<%@ page import="com.foodtap.model.CartItem"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HealthGoal healthGoal = (HealthGoal) request.getAttribute("healthGoal");

    float dailyGoal = 1500;
    float consumed = 0;

    if (healthGoal != null) {
        dailyGoal = healthGoal.getDailyCalorieGoal();
        consumed = healthGoal.getCaloriesConsumed();
    }

    float percentage = 0;
    if (dailyGoal > 0) {
        percentage = (consumed / dailyGoal) * 100;
    }
    if (percentage > 100) {
        percentage = 100;
    }

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
<title>SmartBite | Health Dashboard</title>

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

/* Dashboard Layout */
.container {
    max-width: 1000px;
    margin: 45px auto 80px;
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

.health-card {
    max-width: 700px;
    margin: auto;
    padding: 40px;
    border-radius: 20px;
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    box-shadow: var(--shadow);
    text-align: center;
}

.circle {
    width: 230px;
    height: 230px;
    margin: 10px auto 30px;
    border-radius: 50%;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    background:
        radial-gradient(circle at center, var(--bg-card-dark) 60%, transparent 61%),
        conic-gradient(
            #24963f <%= percentage %>%,
            var(--metric-bg) 0
        );
}

.circle .calories {
    font-size: 38px;
    font-weight: 800;
    color: #24963f;
}

.circle .label {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
    margin-top: 4px;
}

.health-card h2 {
    color: var(--text-main);
    font-size: 20px;
    font-weight: 800;
    margin-bottom: 20px;
}

.stats {
    display: flex;
    justify-content: center;
    gap: 16px;
    flex-wrap: wrap;
    margin-top: 20px;
}

.stat {
    min-width: 180px;
    padding: 20px;
    border-radius: 12px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    transition: transform 0.2s ease, border-color 0.2s ease;
}

.stat:hover {
    border-color: var(--accent);
    transform: translateY(-2px);
}

.stat h3 {
    color: var(--accent);
    font-size: 24px;
    font-weight: 800;
}

.stat p {
    color: var(--text-muted);
    margin-top: 4px;
    font-size: 13px;
    font-weight: 600;
}

.message {
    margin-top: 30px;
    padding: 16px 20px;
    border-radius: 10px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    color: var(--text-main);
    font-size: 13.5px;
    font-weight: 600;
}

.back {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-top: 30px;
    padding: 12px 24px;
    border-radius: 10px;
    background: var(--accent);
    color: white;
    text-decoration: none;
    font-weight: 800;
    font-size: 14px;
    transition: background 0.2s ease, transform 0.1s ease;
    box-shadow: 0 8px 20px rgba(226, 55, 68, 0.25);
}

.back:hover {
    background: #d12e3b;
    transform: translateY(-2px);
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
    <h1>Your <span>Health</span> Dashboard</h1>
    <p>Track your daily calorie goal while enjoying your favourite food.</p>
</div>

<div class="health-card">

    <div class="circle">
        <div class="calories"><%= Math.round(consumed) %></div>
        <div class="label">Calories Consumed</div>
    </div>

    <h2>Daily Calorie Goal</h2>

    <div class="stats">

        <div class="stat">
            <h3><%= Math.round(dailyGoal) %></h3>
            <p>Daily Goal</p>
        </div>

        <div class="stat">
            <h3><%= Math.round(consumed) %></h3>
            <p>Consumed</p>
        </div>

        <div class="stat">
            <h3><%= Math.max(0, Math.round(dailyGoal - consumed)) %></h3>
            <p>Remaining</p>
        </div>

    </div>

    <div class="message">
        <% if (consumed == 0) { %>
            🍽️ Start exploring SmartBite and track your meals here.
        <% } else if (consumed < dailyGoal) { %>
            🟢 You're within your daily calorie goal. Keep going!
        <% } else { %>
            ⚠️ You've reached or exceeded your daily calorie goal for today.
        <% } %>
    </div>

    <a href="home.jsp" class="back">&#8592; Back to SmartBite</a>

</div>

</div>

<script>
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