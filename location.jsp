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
<title>SmartBite | Location</title>

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

.location-card {
    max-width: 650px;
    margin: auto;
    padding: 40px;
    border-radius: 20px;
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    box-shadow: var(--shadow);
    text-align: center;
}

.location-icon {
    font-size: 64px;
    margin-bottom: 16px;
}

.location-button {
    border: none;
    padding: 12px 24px;
    border-radius: 10px;
    background: var(--accent);
    color: white;
    font-size: 14px;
    font-weight: 800;
    cursor: pointer;
    margin-bottom: 20px;
    transition: background 0.2s ease, transform 0.1s ease;
    box-shadow: 0 8px 20px rgba(226, 55, 68, 0.25);
}

.location-button:hover {
    background: #d12e3b;
    transform: translateY(-2px);
}

.status {
    min-height: 24px;
    color: var(--text-muted);
    font-size: 13.5px;
    font-weight: 600;
    margin-bottom: 24px;
}

.divider-text {
    color: var(--text-muted);
    font-size: 12.5px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 16px;
}

.search-box {
    display: flex;
    justify-content: center;
    gap: 10px;
    flex-wrap: wrap;
    margin-top: 10px;
}

.search-box input {
    width: 280px;
    padding: 12px 16px;
    border-radius: 10px;
    border: 1px solid var(--panel-border);
    background: var(--metric-bg);
    color: var(--text-main);
    outline: none;
    font-size: 14px;
    font-family: 'Plus Jakarta Sans', sans-serif;
}

.search-box input::placeholder {
    color: var(--text-muted);
}

.search-box input:focus {
    border-color: var(--accent);
}

.search-box button {
    padding: 12px 22px;
    border: none;
    border-radius: 10px;
    background: var(--accent);
    color: white;
    font-weight: 800;
    font-size: 14px;
    cursor: pointer;
    transition: background 0.2s ease;
}

.search-box button:hover {
    background: #d12e3b;
}

.result {
    display: none;
    margin-top: 25px;
    padding: 20px;
    border-radius: 12px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    text-align: left;
}

.result h2 {
    color: var(--accent);
    font-size: 16px;
    font-weight: 800;
    margin-bottom: 8px;
}

.result p {
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
    <h1>Discover <span>Near You</span></h1>
    <p>Find your location and explore SmartBite around you.</p>
</div>

<div class="location-card">
    <div class="location-icon">&#128205;</div>

    <button class="location-button" onclick="getLocation()">&#128205; Use My Location</button>

    <div class="status" id="status">Click the button to detect your location.</div>

    <div class="divider-text">OR search your city manually</div>

    <div class="search-box">
        <input type="text" id="cityInput" placeholder="Enter city name">
        <button onclick="searchCity()">Search</button>
    </div>

    <div class="result" id="result">
        <h2 id="resultTitle">&#128205; Your Location</h2>
        <p id="resultMessage"></p>
    </div>

    <a href="home.jsp" class="back">&#8592; Back to SmartBite</a>
</div>
</div>

<script>
function getLocation() {
    const status = document.getElementById("status");
    if (!navigator.geolocation) { status.innerText = "Geolocation is not supported by your browser."; return; }
    status.innerText = "Detecting your location...";
    navigator.geolocation.getCurrentPosition(
        function(position) {
            const latitude = position.coords.latitude;
            const longitude = position.coords.longitude;
            status.innerText = "Location detected successfully!";
            showResult("\uD83D\uDCCD Location Detected", "Your current coordinates are " + latitude.toFixed(4) + ", " + longitude.toFixed(4) + ". SmartBite can use this location to provide nearby food recommendations.");
        },
        function(error) {
            if (error.code === 1) { status.innerText = "Location permission was denied. Please search your city manually."; }
            else { status.innerText = "Unable to detect your location. Please search manually."; }
        }
    );
}

function searchCity() {
    const city = document.getElementById("cityInput").value.trim();
    if (city === "") { document.getElementById("status").innerText = "Please enter a city name."; return; }
    document.getElementById("status").innerText = "Location selected.";
    showResult("\uD83D\uDCCD " + city, "SmartBite is ready to help you discover delicious food near " + city + ". You can explore restaurants, categories and meals from the SmartBite homepage.");
}

function showResult(title, message) {
    document.getElementById("resultTitle").innerText = title;
    document.getElementById("resultMessage").innerText = message;
    document.getElementById("result").style.display = "block";
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