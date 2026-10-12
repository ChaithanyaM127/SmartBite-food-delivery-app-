<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.foodtap.model.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String error = request.getParameter("error");
    String next = request.getParameter("next");
    if (next == null) next = "";

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
<title>SmartBite | Login</title>

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

/* Login Card Layout */
.auth-container {
    max-width: 440px;
    width: 92%;
    margin: 50px auto 80px;
    padding: 40px 32px;
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 20px;
    box-shadow: var(--shadow);
}

.auth-header {
    text-align: center;
    margin-bottom: 28px;
}

.auth-header h1 {
    font-size: 26px;
    font-weight: 800;
    color: var(--text-main);
    margin-bottom: 6px;
    letter-spacing: -0.5px;
}

.auth-header p {
    color: var(--text-muted);
    font-size: 13.5px;
    font-weight: 600;
}

.error-msg {
    background: rgba(226, 55, 68, 0.12);
    border: 1px solid rgba(226, 55, 68, 0.3);
    color: var(--accent);
    padding: 12px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 20px;
}

.form-group {
    margin-bottom: 18px;
}

.form-group label {
    display: block;
    color: var(--text-main);
    font-size: 13px;
    font-weight: 700;
    margin-bottom: 8px;
}

.form-group input {
    width: 100%;
    padding: 12px 16px;
    border-radius: 10px;
    border: 1px solid var(--panel-border);
    background: var(--metric-bg);
    color: var(--text-main);
    font-size: 14px;
    outline: none;
    font-family: 'Plus Jakarta Sans', sans-serif;
    transition: border-color 0.2s ease;
}

.form-group input:focus {
    border-color: var(--accent);
}

.form-group input::placeholder {
    color: var(--text-muted);
}

.auth-btn {
    width: 100%;
    padding: 13px;
    border-radius: 10px;
    background: var(--accent);
    color: #fff;
    border: none;
    font-size: 14px;
    font-weight: 800;
    cursor: pointer;
    transition: background 0.2s ease, transform 0.1s ease;
    box-shadow: 0 8px 20px rgba(226, 55, 68, 0.25);
    margin-top: 10px;
}

.auth-btn:hover {
    background: #d12e3b;
    transform: translateY(-1px);
}

.auth-footer {
    text-align: center;
    margin-top: 24px;
    font-size: 13px;
    color: var(--text-muted);
    font-weight: 600;
}

.auth-footer a {
    color: var(--accent);
    text-decoration: none;
    font-weight: 800;
}

.auth-footer a:hover {
    text-decoration: underline;
}

footer {
    background: var(--bg-card-dark);
    border-top: 1px solid var(--panel-border);
    color: var(--text-muted);
    text-align: center;
    padding: 20px 24px;
    margin-top: auto;
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

<div class="auth-container">
    <div class="auth-header">
        <h1>Welcome Back</h1>
        <p>Login to your SmartBite account</p>
    </div>

    <% if (error != null) { %>
        <div class="error-msg">
            <% if (error.equals("empty")) { %>
                Please enter both email and password.
            <% } else if (error.equals("invalid")) { %>
                Invalid email or password. Please try again.
            <% } else { %>
                An error occurred. Please try again later.
            <% } %>
        </div>
    <% } %>

    <form action="LoginServlet" method="POST">
        <input type="hidden" name="next" value="<%= next %>">
        
        <div class="form-group">
            <label for="email">Email Address</label>
            <input type="email" id="email" name="email" required placeholder="name@example.com">
        </div>

        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required placeholder="Enter your password">
        </div>

        <button type="submit" class="auth-btn">Sign In</button>
    </form>

    <div class="auth-footer">
        Don't have an account? <a href="register.jsp">Register here</a>
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