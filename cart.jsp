<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.foodtap.model.CartItem" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Your Cart</title>

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

/* PAGE CONTAINER */
.page-container {
    max-width: 1320px;
    margin: 40px auto 70px;
    padding: 0 24px;
}

.page-title {
    margin-bottom: 28px;
}

.page-title h1 {
    font-size: 28px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.5px;
    margin-bottom: 6px;
}

.page-title p {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
}

/* CART LAYOUT */
.cart-wrapper {
    display: grid;
    grid-template-columns: 1fr 380px;
    gap: 24px;
    align-items: start;
}

.cart-items {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    padding: 20px;
    box-shadow: var(--shadow);
}

.cart-item {
    display: grid;
    grid-template-columns: 110px 1fr auto;
    gap: 20px;
    align-items: center;
    padding: 16px 0;
    border-bottom: 1px solid var(--panel-border);
}

.cart-item:last-child {
    border-bottom: none;
}

.food-image {
    width: 110px;
    height: 90px;
    object-fit: cover;
    border-radius: 6px;
    background: #000;
    display: block;
}

.item-info h3 {
    color: var(--text-main);
    font-size: 17px;
    font-weight: 800;
    margin-bottom: 6px;
}

.description {
    color: var(--text-bottom-sub);
    font-size: 12px;
    line-height: 1.4;
    margin-bottom: 10px;
}

.item-price {
    color: #24963f !important;
    font-weight: 800;
    font-size: 15px !important;
    margin-bottom: 8px;
}

/* QUANTITY */
.quantity-box {
    display: flex;
    align-items: center;
    gap: 12px;
}

.quantity-label {
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 700;
}

.quantity-control {
    display: inline-flex;
    align-items: center;
    background: var(--accent);
    border-radius: 6px;
    overflow: hidden;
    height: 32px;
}

.quantity-btn {
    width: 32px;
    height: 32px;
    border: none;
    background: transparent;
    color: #fff;
    font-size: 18px;
    font-weight: 800;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
}

.quantity-btn:hover {
    background: rgba(0, 0, 0, 0.15);
}

.quantity-number {
    min-width: 32px;
    text-align: center;
    color: #fff;
    font-size: 13px;
    font-weight: 800;
}

.remove-btn {
    margin-left: 10px;
    border: none;
    background: transparent;
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    text-decoration: underline;
}

.remove-btn:hover {
    color: var(--accent);
}

/* TOTAL */
.item-total {
    text-align: right;
    min-width: 100px;
}

.item-total .total-label {
    display: block;
    color: var(--text-muted);
    font-size: 10px;
    font-weight: 800;
    margin-bottom: 4px;
    letter-spacing: 0.5px;
}

.item-total .total-price {
    color: #24963f;
    font-size: 17px;
    font-weight: 800;
}

/* EMPTY CART */
.empty-cart {
    text-align: center;
    padding: 60px 20px;
}

.empty-cart h2 {
    color: var(--text-main);
    font-size: 22px;
    font-weight: 800;
    margin-bottom: 10px;
}

.empty-cart p {
    color: var(--text-muted);
    font-size: 14px;
    margin-bottom: 20px;
}

/* BUTTON */
.primary-btn {
    display: inline-block;
    text-decoration: none;
    background: var(--accent);
    color: #fff;
    border: none;
    border-radius: 6px;
    padding: 10px 20px;
    font-size: 13px;
    font-weight: 800;
    cursor: pointer;
    transition: background 0.2s ease;
}

.primary-btn:hover {
    background: #d12e3b;
}

/* SUMMARY */
.summary {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    padding: 20px;
    position: sticky;
    top: 90px;
    box-shadow: var(--shadow);
}

.summary h2 {
    color: var(--text-main);
    font-size: 18px;
    font-weight: 800;
    margin-bottom: 16px;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    color: var(--text-muted);
    margin-bottom: 12px;
    font-size: 13px;
    font-weight: 600;
}

.summary-row span:last-child {
    color: var(--text-main);
    font-weight: 700;
}

.summary-divider {
    height: 1px;
    background: var(--panel-border);
    margin: 16px 0;
}

.grand-total {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.grand-total span:first-child {
    color: var(--text-main);
    font-size: 15px;
    font-weight: 800;
}

.grand-total span:last-child {
    color: #24963f;
    font-size: 20px;
    font-weight: 900;
}

.checkout-btn {
    width: 100%;
    text-align: center;
    padding: 12px;
}

.continue-shopping {
    display: block;
    text-align: center;
    margin-top: 14px;
    color: var(--text-muted);
    text-decoration: none;
    font-size: 12px;
    font-weight: 700;
}

.continue-shopping:hover {
    color: var(--accent);
}

/* FOOTER */
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

/* RESPONSIVE */
@media (max-width: 850px) {
    .cart-wrapper { grid-template-columns: 1fr; }
    .summary { position: static; }
}

@media (max-width: 600px) {
    .cart-item { grid-template-columns: 80px 1fr; gap: 12px; }
    .food-image { width: 80px; height: 70px; }
    .item-total { grid-column: 2; text-align: left; margin-top: 8px; }
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
                <a href="orders.jsp" title="Orders">Orders</a>
                <a href="cart.jsp" class="active" title="Cart">🛒 Cart</a>
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

<div class="page-container">

<div class="page-title">
    <h1>Your Cart</h1>
    <p>Review your selected food items before checkout</p>
</div>

<div class="cart-wrapper">

<div class="cart-items">

    <%
    List<CartItem> cart = new ArrayList<>();
    Object cartObject = session.getAttribute("cart");

    if (cartObject instanceof List<?>) {
        for (Object obj : (List<?>) cartObject) {
            if (obj instanceof CartItem) {
                cart.add((CartItem) obj);
            }
        }
    }

    float grandTotal = 0;

    if (!cart.isEmpty()) {
        for (CartItem item : cart) {
            if (item.getMenu() == null) continue;

            grandTotal += item.getItemTotal();

            String description = item.getMenu().getDescription();
            if (description == null || description.trim().isEmpty()) {
                description = "Delicious " + item.getMenu().getName() + " prepared fresh for you.";
            }

            String imagePath = item.getMenu().getImagePath();
            if (imagePath == null || imagePath.trim().isEmpty()) {
                imagePath = "https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=500&q=80";
            }
    %>

    <div class="cart-item">
        <img src="<%= imagePath %>" alt="<%= item.getMenu().getName() %>" class="food-image"
            onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=500&q=80';">

        <div class="item-info">
            <h3><%= item.getMenu().getName() %></h3>
            <p class="description"><%= description %></p>
            <p class="item-price">Price: &#8377;<%= String.format("%.2f", item.getMenu().getPrice()) %></p>

            <div class="quantity-box">
                <span class="quantity-label">Quantity:</span>
                <div class="quantity-control">
                    <button type="button" class="quantity-btn" onclick="changeQuantity(<%= item.getMenu().getMenuId() %>, 'decrease')">&#8722;</button>
                    <span class="quantity-number" id="quantity-<%= item.getMenu().getMenuId() %>"><%= item.getQuantity() %></span>
                    <button type="button" class="quantity-btn" onclick="changeQuantity(<%= item.getMenu().getMenuId() %>, 'increase')">+</button>
                </div>
                <button type="button" class="remove-btn" onclick="removeItem(<%= item.getMenu().getMenuId() %>)">Remove</button>
            </div>
        </div>

        <div class="item-total">
            <span class="total-label">TOTAL</span>
            <span class="total-price">&#8377;<%= String.format("%.2f", item.getItemTotal()) %></span>
        </div>
    </div>

    <%
        }
    } else {
    %>

    <div class="empty-cart">
        <h2>Your cart is empty</h2>
        <p>Add some delicious food to your cart and come back here.</p>
        <a href="restaurants" class="primary-btn">Browse Restaurants</a>
    </div>

    <%
    }
    %>

</div>

<%
if (!cart.isEmpty()) {
    float deliveryFee = 40;
    float platformFee = 20;
    float finalTotal = grandTotal + deliveryFee + platformFee;
%>

<div class="summary">
    <h2>Order Summary</h2>

    <div class="summary-row">
        <span>Items</span>
        <span><%= cart.size() %></span>
    </div>

    <div class="summary-row">
        <span>Subtotal</span>
        <span>&#8377;<%= String.format("%.2f", grandTotal) %></span>
    </div>

    <div class="summary-row">
        <span>Delivery Fee</span>
        <span>&#8377;40.00</span>
    </div>

    <div class="summary-row">
        <span>Platform Fee</span>
        <span>&#8377;20.00</span>
    </div>

    <div class="summary-divider"></div>

    <div class="grand-total">
        <span>Total</span>
        <span>&#8377;<%= String.format("%.2f", finalTotal) %></span>
    </div>

    <a href="checkout.jsp" class="primary-btn checkout-btn">Proceed to Checkout</a>
    <a href="restaurants" class="continue-shopping">&#8592; Continue Shopping</a>
</div>

<%
}
%>

</div>

</div>

<script>
function changeQuantity(menuId, action) {
    fetch("cart?action=" + action + "&menuId=" + menuId, {
        method: "GET",
        credentials: "same-origin"
    })
    .then(function(response) {
        if (!response.ok) throw new Error("Cart update failed");
        return response.text();
    })
    .then(function() {
        window.location.reload();
    })
    .catch(function(error) {
        console.error(error);
        window.location.reload();
    });
}

function removeItem(menuId) {
    fetch("cart?action=remove&menuId=" + menuId, {
        method: "GET",
        credentials: "same-origin"
    })
    .then(function(response) {
        if (!response.ok) throw new Error("Remove failed");
        return response.text();
    })
    .then(function() {
        window.location.reload();
    })
    .catch(function(error) {
        console.error(error);
        window.location.reload();
    });
}

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