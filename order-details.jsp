<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.foodtap.model.Order" %>
<%@ page import="com.foodtap.model.OrderItem" %>
<%@ page import="com.foodtap.model.Menu" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Order order = (Order) request.getAttribute("order");
    Object orderItemsObject = request.getAttribute("orderItems");
    Object menuMapObject = request.getAttribute("menuMap");

    float foodSubtotal = 0.0f;
    if (orderItemsObject instanceof List<?>) {
        for (Object obj : (List<?>) orderItemsObject) {
            if (obj instanceof OrderItem) {
                OrderItem item = (OrderItem) obj;
                foodSubtotal += item.getItemTotal();
            }
        }
    }

    float deliveryFee = 40.0f;
    float platformFee = 20.0f;
    float grandTotal = order != null ? order.getTotalAmount() : 0.0f;
    String status = order != null ? order.getStatus() : "PLACED";
    boolean cancelled = status != null && status.equalsIgnoreCase("CANCELLED");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Order Details</title>

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

.back-link {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: var(--accent);
    text-decoration: none;
    font-size: 13px;
    font-weight: 800;
    margin-bottom: 16px;
    background: var(--metric-bg);
    padding: 8px 14px;
    border-radius: 6px;
    border: 1px solid var(--panel-border);
}

.back-link:hover {
    background: rgba(226, 55, 68, 0.1);
}

.page-title {
    font-size: 28px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.5px;
    margin-bottom: 6px;
}

.order-subtitle {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 24px;
}

.order-card {
    background: var(--bg-card-dark);
    border-radius: 8px;
    padding: 24px;
    margin-bottom: 20px;
    border: 1px solid var(--panel-border);
    border-left: 4px solid var(--accent);
    box-shadow: var(--shadow);
}

.order-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 18px;
}

.order-id {
    font-size: 20px;
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

.order-info {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
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
    font-size: 14px;
    font-weight: 800;
}

.items-title {
    font-size: 18px;
    font-weight: 800;
    color: var(--text-main);
    margin-bottom: 16px;
}

.food-item {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px 0;
    border-bottom: 1px solid var(--panel-border);
}

.food-item:last-child {
    border-bottom: none;
}

.food-image {
    width: 75px;
    height: 75px;
    object-fit: cover;
    border-radius: 6px;
    border: 1px solid var(--panel-border);
    background: #000;
}

.food-info {
    flex: 1;
}

.food-name {
    font-size: 15px;
    font-weight: 800;
    color: var(--text-main);
    margin-bottom: 4px;
}

.food-description {
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 600;
    line-height: 1.4;
}

.food-quantity {
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 700;
    margin-top: 6px;
}

.food-total {
    color: #24963f;
    font-size: 16px;
    font-weight: 900;
    white-space: nowrap;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
}

.summary-row span:last-child {
    color: var(--text-main);
    font-weight: 700;
}

.summary-row.total {
    border-top: 1px solid var(--panel-border);
    margin-top: 8px;
    padding-top: 16px;
    color: var(--text-main);
    font-size: 16px;
    font-weight: 800;
}

.summary-row.total span:last-child {
    color: #24963f;
    font-size: 18px;
    font-weight: 900;
}

.action-area {
    display: flex;
    gap: 12px;
    margin-top: 24px;
}

.action-btn {
    display: inline-block;
    padding: 12px 20px;
    border-radius: 6px;
    text-decoration: none;
    font-size: 13px;
    font-weight: 800;
    transition: background 0.2s;
}

.back-btn {
    background: var(--accent);
    color: #fff;
}

.back-btn:hover {
    background: #d12e3b;
}

.restaurant-btn {
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    color: var(--text-main);
}

.restaurant-btn:hover {
    border-color: var(--accent);
}

.no-items {
    color: var(--text-muted);
    padding: 20px 0;
    text-align: center;
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
    .container { width: 94%; margin-top: 25px; }
    .page-title { font-size: 24px; }
    .order-info { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 480px) {
    .order-info { grid-template-columns: 1fr; }
    .order-header { flex-direction: column; align-items: flex-start; gap: 12px; }
    .order-card { padding: 18px; }
    .food-item { align-items: flex-start; }
    .food-image { width: 60px; height: 60px; }
    .food-total { font-size: 14px; }
    .action-area { flex-direction: column; }
    .action-btn { width: 100%; text-align: center; }
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

    <a href="orders" class="back-link">&#8592; Back to My Orders</a>

    <h1 class="page-title">Order Details</h1>
    <p class="order-subtitle">Complete information about your order.</p>

    <% if (order != null) { %>

        <div class="order-card">
            <div class="order-header">
                <div class="order-id">Order #<%= order.getOrderId() %></div>
                <div class="status <%= cancelled ? "cancelled" : "" %>">
                    <%= status != null ? status : "PLACED" %>
                </div>
            </div>

            <div class="order-info">
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
                    <div class="detail-value"><%= order.getPaymentOption() != null ? order.getPaymentOption() : "COD" %></div>
                </div>
            </div>
        </div>

        <div class="order-card">
            <h2 class="items-title">Ordered Food</h2>

            <% if (orderItemsObject instanceof List<?> && !((List<?>) orderItemsObject).isEmpty()) {
                List<?> itemList = (List<?>) orderItemsObject;
                for (Object obj : itemList) {
                    if (!(obj instanceof OrderItem)) continue;
                    OrderItem item = (OrderItem) obj;
                    Menu menu = null;

                    if (menuMapObject instanceof Map<?, ?>) {
                        Map<?, ?> menuMap = (Map<?, ?>) menuMapObject;
                        Object menuObject = menuMap.get(item.getMenuId());
                        if (menuObject instanceof Menu) {
                            menu = (Menu) menuObject;
                        }
                    }

                    String foodName = menu != null ? menu.getName() : "Food Item";
                    String description = menu != null && menu.getDescription() != null ? menu.getDescription() : "Food item details";
                    String imagePath = menu != null ? menu.getImagePath() : "";
            %>

                    <div class="food-item">
                        <% if (imagePath != null && !imagePath.trim().isEmpty()) { %>
                            <img src="<%= imagePath %>" alt="<%= foodName %>" class="food-image" onerror="this.style.display='none';">
                        <% } else { %>
                            <div class="food-image"></div>
                        <% } %>

                        <div class="food-info">
                            <div class="food-name"><%= foodName %></div>
                            <div class="food-description"><%= description %></div>
                            <div class="food-quantity">Quantity: <%= item.getQuantity() %></div>
                        </div>

                        <div class="food-total">&#8377;<%= String.format("%.2f", item.getItemTotal()) %></div>
                    </div>

            <% }
            } else { %>
                <div class="no-items">No food items found for this order.</div>
            <% } %>
        </div>

        <div class="order-card">
            <h2 class="items-title">Bill Summary</h2>

            <div class="summary">
                <div class="summary-row">
                    <span>Food Subtotal</span>
                    <span>&#8377;<%= String.format("%.2f", foodSubtotal) %></span>
                </div>

                <div class="summary-row">
                    <span>Delivery Fee</span>
                    <span>&#8377;<%= String.format("%.2f", deliveryFee) %></span>
                </div>

                <div class="summary-row">
                    <span>Platform Fee</span>
                    <span>&#8377;<%= String.format("%.2f", platformFee) %></span>
                </div>

                <div class="summary-row total">
                    <span>Grand Total</span>
                    <span>&#8377;<%= String.format("%.2f", grandTotal) %></span>
                </div>
            </div>
        </div>

        <div class="action-area">
            <a href="orders" class="action-btn back-btn">&#8592; My Orders</a>
            <a href="restaurants" class="action-btn restaurant-btn">Order More Food</a>
        </div>

    <% } else { %>

        <div class="order-card">
            <div class="no-items">Order details could not be found.</div>
        </div>

        <div class="action-area">
            <a href="orders" class="action-btn back-btn">&#8592; My Orders</a>
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