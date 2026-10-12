<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Object orderIdObj = session.getAttribute("lastOrderId");
    Object totalObj = session.getAttribute("lastOrderTotal");
    Object paymentObj = session.getAttribute("lastPaymentOption");
    Object statusObj = session.getAttribute("lastOrderStatus");

    String orderId = orderIdObj != null ? String.valueOf(orderIdObj) : "N/A";

    double totalAmount = 0.0;
    if (totalObj instanceof Number) {
        totalAmount = ((Number) totalObj).doubleValue();
    } else if (totalObj != null) {
        try {
            totalAmount = Double.parseDouble(String.valueOf(totalObj));
        } catch (Exception e) {
            totalAmount = 0.0;
        }
    }

    String paymentOption = paymentObj != null ? String.valueOf(paymentObj) : "N/A";
    String status = statusObj != null ? String.valueOf(statusObj) : "PLACED";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Order Confirmation</title>

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

/* Page Container */
.page-container {
    max-width: 850px;
    margin: 50px auto 80px;
    padding: 0 24px;
}

.success-card {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 12px;
    padding: 40px;
    text-align: center;
    box-shadow: var(--shadow);
}

.success-icon {
    width: 70px;
    height: 70px;
    margin: 0 auto 20px;
    border-radius: 50%;
    background: #24963f;
    color: #ffffff;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 34px;
    font-weight: 800;
}

h1 {
    color: var(--text-main);
    font-size: 28px;
    font-weight: 800;
    letter-spacing: -0.5px;
    margin-bottom: 8px;
}

.message {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 30px;
}

.order-details {
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 24px;
    text-align: left;
}

.detail-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid var(--panel-border);
}

.detail-row:last-child {
    border-bottom: none;
}

.detail-label {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 700;
}

.detail-value {
    color: var(--text-main);
    font-size: 14px;
    font-weight: 800;
}

.status {
    color: #24963f;
}

.cancel-zone {
    margin: 24px 0;
    padding: 18px;
    background: rgba(226, 55, 68, 0.08);
    border: 1px solid rgba(226, 55, 68, 0.25);
    border-radius: 8px;
}

.cancel-zone p {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 12px;
}

.cancel-btn {
    display: inline-block;
    padding: 10px 20px;
    background: var(--accent);
    color: #ffffff;
    text-decoration: none;
    border-radius: 6px;
    font-weight: 800;
    font-size: 13px;
    transition: background 0.2s;
}

.cancel-btn:hover {
    background: #d12e3b;
}

.quote {
    margin: 24px 0 28px;
    padding: 18px;
    background: var(--metric-bg);
    border-left: 4px solid var(--accent);
    border-radius: 6px;
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
    font-style: italic;
}

.buttons {
    display: flex;
    justify-content: center;
    gap: 12px;
    flex-wrap: wrap;
}

.btn {
    display: inline-block;
    min-width: 160px;
    padding: 12px 20px;
    border-radius: 6px;
    text-decoration: none;
    font-size: 13px;
    font-weight: 800;
    transition: background 0.2s;
}

.track-btn {
    background: #24963f;
    color: #ffffff;
}

.track-btn:hover {
    background: #1e7e34;
}

.secondary {
    background: var(--metric-bg);
    color: var(--text-main);
    border: 1px solid var(--panel-border);
}

.secondary:hover {
    border-color: var(--accent);
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

@media (max-width: 600px) {
    .page-container { padding: 30px 15px; }
    .success-card { padding: 24px 16px; }
    h1 { font-size: 24px; }
    .buttons { flex-direction: column; }
    .btn { width: 100%; }
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

<div class="page-container">

<div class="success-card">
    <div class="success-icon">✓</div>

    <h1>Order Confirmation</h1>
    <p class="message">Thank you for ordering with SmartBite. Your order has been placed successfully!</p>

    <div class="order-details">
        <div class="detail-row">
            <span class="detail-label">Order ID</span>
            <span class="detail-value">#<%= orderId %></span>
        </div>

        <div class="detail-row">
            <span class="detail-label">Total Amount</span>
            <span class="detail-value">&#8377;<%= String.format("%.2f", totalAmount) %></span>
        </div>

        <div class="detail-row">
            <span class="detail-label">Payment</span>
            <span class="detail-value"><%= paymentOption %></span>
        </div>

        <div class="detail-row">
            <span class="detail-label">Status</span>
            <span class="detail-value status"><%= status %></span>
        </div>
    </div>

    <div class="cancel-zone">
        <p>Need to cancel your order?</p>
        <a href="<%= request.getContextPath() %>/cancel-order?orderId=<%= orderId %>" class="cancel-btn">
            Cancel This Order
        </a>
    </div>

    <div class="quote">
        “Good food makes every moment better — enjoy your meal!”
    </div>

    <div class="buttons">
        <a href="<%= request.getContextPath() %>/track-order?orderId=<%= orderId %>" class="btn track-btn">
            Track Order
        </a>

        <a href="<%= request.getContextPath() %>/orders" class="btn secondary">
            Order History
        </a>

        <a href="<%= request.getContextPath() %>/restaurants" class="btn secondary">
            Continue Shopping
        </a>
    </div>
</div>

</div>

<script>
// Clear cart count in localStorage immediately when landing on order success
localStorage.setItem('foodtap_cart_count', '0');
localStorage.setItem('smartbite_cart_count', '0');

// Update badge in navbar to 0
var badge = document.getElementById('fta-cart-badge');
if (badge) {
    badge.textContent = '0';
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