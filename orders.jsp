<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.foodtap.model.Order" %>
<%@ page import="com.foodtap.model.User" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("loggedInUser");
    List<Order> orderList = new ArrayList<>();
    Object orderObject = request.getAttribute("orderList");

    if (orderObject instanceof List<?>) {
        for (Object obj : (List<?>) orderObject) {
            if (obj instanceof Order) {
                orderList.add((Order) obj);
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | My Orders</title>

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
    font-size: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0;
    color: var(--text-main);
}

/* Container */
.container {
    width: 92%;
    max-width: 1000px;
    margin: 40px auto 80px;
}

.page-title {
    font-size: 28px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.5px;
    margin-bottom: 6px;
}

.welcome {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 28px;
}

.welcome strong {
    color: var(--accent);
}

.order-card {
    background: var(--bg-card-dark);
    border-radius: 8px;
    padding: 24px;
    margin-bottom: 20px;
    border: 1px solid var(--panel-border);
    border-left: 4px solid var(--accent);
    box-shadow: var(--shadow);
    transition: transform 0.2s ease;
}

.order-card:hover {
    transform: translateY(-2px);
    border-color: var(--accent);
}

.order-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 18px;
}

.order-id {
    font-size: 18px;
    font-weight: 800;
    color: var(--text-main);
}

.status {
    padding: 6px 14px;
    border-radius: 20px;
    background: rgba(36, 150, 63, 0.1);
    border: 1px solid rgba(36, 150, 63, 0.3);
    color: #24963f;
    font-size: 12px;
    font-weight: 800;
    text-transform: uppercase;
}

.status.cancelled {
    background: rgba(226, 55, 68, 0.1);
    border-color: rgba(226, 55, 68, 0.3);
    color: var(--accent);
}

.order-details {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    border-top: 1px solid var(--panel-border);
    padding-top: 18px;
}

.detail-label {
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 6px;
}

.detail-value {
    color: var(--text-main);
    font-weight: 800;
    font-size: 14px;
}

.amount {
    color: #24963f;
    font-size: 16px;
    font-weight: 900;
}

.order-actions {
    display: flex;
    gap: 10px;
    margin-top: 20px;
    border-top: 1px solid var(--panel-border);
    padding-top: 18px;
}

.action-btn {
    display: inline-block;
    padding: 10px 18px;
    border-radius: 6px;
    text-decoration: none;
    font-size: 13px;
    font-weight: 800;
    transition: background 0.2s;
}

.view-btn {
    background: var(--accent);
    color: #fff;
}

.view-btn:hover {
    background: #d12e3b;
}

.cancel-btn {
    background: rgba(226, 55, 68, 0.1);
    border: 1px solid rgba(226, 55, 68, 0.3);
    color: var(--accent);
}

.cancel-btn:hover {
    background: rgba(226, 55, 68, 0.2);
}

.empty-card {
    background: var(--bg-card-dark);
    border-radius: 8px;
    padding: 50px 20px;
    text-align: center;
    border: 1px solid var(--panel-border);
    box-shadow: var(--shadow);
}

.empty-icon {
    font-size: 48px;
    margin-bottom: 16px;
}

.empty-card h2 {
    font-size: 20px;
    font-weight: 800;
    color: var(--text-main);
    margin-bottom: 8px;
}

.empty-card p {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 20px;
}

.btn {
    display: inline-block;
    text-decoration: none;
    background: var(--accent);
    color: white;
    padding: 11px 22px;
    border-radius: 6px;
    font-weight: 800;
    font-size: 13px;
    transition: background 0.2s;
}

.btn:hover {
    background: #d12e3b;
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
    .container { width: 94%; margin-top: 25px; }
    .page-title { font-size: 24px; }
    .order-details { grid-template-columns: repeat(2, 1fr); }
    .order-top { align-items: flex-start; gap: 12px; }
}

@media (max-width: 480px) {
    .order-details { grid-template-columns: 1fr; }
    .order-top { flex-direction: column; align-items: flex-start; }
    .order-card { padding: 18px; }
    .order-actions { flex-direction: column; }
    .action-btn { text-align: center; width: 100%; }
}
</style>
</head>
<body>

    <!-- Navbar -->
    <header class="navbar">
        <div class="nav-container">
            <a href="home.jsp" class="logo">Smart<span>Bite</span></a>
            <nav class="nav-links">
                <a href="home.jsp">Home</a>
                <a href="restaurants">Restaurants</a>
                <a href="orders.jsp" title="Orders" class="active">Orders</a>
                <a href="cart.jsp" title="Cart">🛒 Cart</a>
                <a href="profile.jsp" class="profile-avatar" title="Profile">👤</a>
                
                <div class="controls-box">
                    <input type="range" min="0.5" max="1.5" step="0.05" value="1" class="brightness-slider" id="brightnessSlider" oninput="adjustBrightness(this.value)" title="Adjust Brightness">
                    <button class="theme-toggle-btn" id="themeToggleBtn" onclick="toggleTheme()" title="Toggle Light/Dark Theme">
                        <span id="themeIcon">☀️</span>
                    </button>
                </div>
            </nav>
        </div>
    </header>

<div class="container">

<h1 class="page-title">My Orders</h1>
<p class="welcome">Hello, <strong><%= user != null ? user.getName() : "User" %></strong> — here are your recent orders.</p>

<% if (!orderList.isEmpty()) {
    for (Order order : orderList) {
        String status = order.getStatus();
        boolean cancelled = status != null && status.equalsIgnoreCase("CANCELLED");
        boolean canCancel = !cancelled && status != null && (status.equalsIgnoreCase("PLACED") || status.equalsIgnoreCase("CONFIRMED"));
%>

<div class="order-card">
    <div class="order-top">
        <div class="order-id">Order #<%= order.getOrderId() %></div>
        <div class="status <%= cancelled ? "cancelled" : "" %>">
            <%= status != null ? status : "PLACED" %>
        </div>
    </div>

    <div class="order-details">
        <div>
            <div class="detail-label">Order Date</div>
            <div class="detail-value"><%= order.getOrderDate() %></div>
        </div>
        <div>
            <div class="detail-label">Restaurant</div>
            <div class="detail-value">#<%= order.getRestaurantId() %></div>
        </div>
        <div>
            <div class="detail-label">Payment</div>
            <div class="detail-value"><%= order.getPaymentOption() %></div>
        </div>
        <div>
            <div class="detail-label">Total Amount</div>
            <div class="detail-value amount">&#8377;<%= String.format("%.2f", order.getTotalAmount()) %></div>
        </div>
    </div>

    <div class="order-actions">
        <a href="order-details?orderId=<%= order.getOrderId() %>" class="action-btn view-btn">View Details</a>
        <a href="track-order?orderId=<%= order.getOrderId() %>" class="action-btn view-btn" style="background:#24963f;">Track Order</a>
        <% if (canCancel) { %>
            <a href="cancel-order?orderId=<%= order.getOrderId() %>" class="action-btn cancel-btn" onclick="return confirm('Are you sure you want to cancel this order?');">Cancel Order</a>
        <% } %>
    </div>
</div>

<% }
} else { %>

<div class="empty-card">
    <div class="empty-icon">🍽️</div>
    <h2>No Orders Yet</h2>
    <p>Looks like you haven't ordered anything yet. Let's find something delicious!</p>
    <a href="restaurants" class="btn">Browse Restaurants</a>
</div>

<% } %>

</div>

<script>
// Theme & Brightness Management
(function() {
    const savedTheme = localStorage.getItem("smartbite_theme");
    if (savedTheme === "light") {
        document.body.classList.add("light-mode");
    }
    updateThemeButtonUI();
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