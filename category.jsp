<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.foodtap.model.Menu" %>
<%@ page import="com.foodtap.model.CartItem" %>

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
<title>SmartBite | Category</title>

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

/* Category Container */
.category-container {
    width: 92%;
    max-width: 1250px;
    margin: 0 auto;
    padding: 35px 0 60px;
}

.back-button {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: var(--accent);
    text-decoration: none;
    font-size: 14px;
    font-weight: 800;
    margin-bottom: 24px;
    background: var(--metric-bg);
    padding: 8px 16px;
    border-radius: 8px;
    border: 1px solid var(--panel-border);
    transition: background 0.2s ease;
}

.back-button:hover {
    background: rgba(226, 55, 68, 0.1);
}

.category-title {
    text-align: center;
    margin-bottom: 40px;
}

.category-title h1 {
    font-size: clamp(28px, 4vw, 40px);
    margin-bottom: 8px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.5px;
}

.category-title h1::after {
    content: "";
    display: block;
    width: 60px;
    height: 3px;
    background: var(--accent);
    border-radius: 10px;
    margin: 12px auto 0;
}

.category-title p {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
}

.food-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: 24px;
}

.food-card {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 12px;
    overflow: hidden;
    box-shadow: var(--shadow);
    transition: transform 0.2s ease, border-color 0.2s ease;
    display: flex;
    flex-direction: column;
}

.food-card:hover {
    transform: translateY(-4px);
    border-color: var(--accent);
}

.image-wrapper {
    width: 100%;
    height: 200px;
    overflow: hidden;
    background: #000;
    position: relative;
}

.food-image {
    width: 100%;
    height: 200px;
    object-fit: cover;
    display: block;
    transition: transform 0.4s ease;
}

.food-card:hover .food-image {
    transform: scale(1.05);
}

.image-fallback {
    width: 100%;
    height: 200px;
    background: var(--metric-bg);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
}

.food-content {
    padding: 20px;
    display: flex;
    flex-direction: column;
    flex: 1;
}

.food-content h3 {
    margin: 0 0 8px;
    color: var(--text-main);
    font-size: 17px;
    font-weight: 800;
}

.food-description {
    color: var(--text-muted);
    font-size: 13px;
    line-height: 1.45;
    margin-bottom: 16px;
    font-weight: 600;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.food-price {
    font-size: 18px;
    font-weight: 900;
    margin-bottom: 16px;
    color: #24963f;
    margin-top: auto;
}

.view-button {
    display: inline-block;
    padding: 10px 18px;
    background: var(--accent);
    color: white;
    text-decoration: none;
    border-radius: 6px;
    font-size: 13px;
    font-weight: 800;
    text-align: center;
    transition: background 0.2s ease;
}

.view-button:hover {
    background: #d12e3b;
}

.empty-message {
    grid-column: 1/-1;
    text-align: center;
    color: var(--text-muted);
    padding: 60px 20px;
    background: var(--bg-card-dark);
    border-radius: 12px;
    border: 1px solid var(--panel-border);
    box-shadow: var(--shadow);
}

.empty-message h2 {
    color: var(--text-main);
    font-size: 20px;
    font-weight: 800;
    margin-bottom: 8px;
}

.empty-message p {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
}

footer {
    background: var(--bg-card-dark);
    border-top: 1px solid var(--panel-border);
    color: var(--text-muted);
    text-align: center;
    padding: 20px 24px;
    margin-top: 60px;
    font-size: 12px;
    font-weight: 600;
}

@media (max-width: 700px) {
    .category-container { width: 94%; padding-top: 20px; }
    .food-grid { grid-template-columns: 1fr; gap: 18px; }
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

<div class="category-container">

<a href="home.jsp" class="back-button">&#8592; Back to Home</a>

<div class="category-title">
    <h1><%= request.getAttribute("selectedCategory") != null ? request.getAttribute("selectedCategory") : "Category Items" %></h1>
    <p>Delicious food from SmartBite</p>
</div>

<div class="food-grid">

    <%
        List<Menu> menuList = new ArrayList<>();
        Object menuObject = request.getAttribute("menuList");
        if (menuObject instanceof List<?>) {
            for (Object obj : (List<?>) menuObject) {
                if (obj instanceof Menu) menuList.add((Menu) obj);
            }
        }
        if (!menuList.isEmpty()) {
            for (Menu menu : menuList) {
                String image = menu.getImagePath();
    %>

    <div class="food-card">
        <div class="image-wrapper">
            <% if (image != null && !image.trim().isEmpty()) { %>
            <img src="<%= image %>" class="food-image" alt="<%= menu.getName() %>"
                onerror="this.style.display='none'; this.parentElement.querySelector('.image-fallback').style.display='flex';">
            <div class="image-fallback" style="display:none;">Image unavailable</div>
            <% } else { %>
            <div class="image-fallback">Image unavailable</div>
            <% } %>
        </div>
        <div class="food-content">
            <h3><%= menu.getName() %></h3>
            <div class="food-description"><%= menu.getDescription() != null ? menu.getDescription() : "Delicious food item prepared fresh for you." %></div>
            <div class="food-price">&#8377;<%= menu.getPrice() %></div>
            <a class="view-button" href="food-details?menuId=<%= menu.getMenuId() %>">View Food</a>
        </div>
    </div>

    <%
            }
        } else {
    %>

    <div class="empty-message">
        <h2>No food found</h2>
        <p>There are currently no available items in this category.</p>
    </div>

    <%
        }
    %>

</div>
</div>

<script>
// Theme & Brightness Management
(function() {
    const savedTheme = localStorage.getItem("smartbite_theme");
    if (savedTheme === "light") {
        document.body.classList.add("light-mode");
    }
    updateThemeButtonUI();

    // Sync cart badge count
    var count = <%= initialCartCount %>;
    var savedCount = localStorage.getItem("foodtap_cart_count");
    if (savedCount !== null) {
        count = parseInt(savedCount, 10) || count;
    }
    var b = document.getElementById('fta-cart-badge');
    if (b) b.textContent = count;
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