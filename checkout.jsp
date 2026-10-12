<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.foodtap.model.CartItem" %>
<%@ page import="com.foodtap.model.User" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?next=checkout.jsp");
        return;
    }

    List<CartItem> cart = new ArrayList<CartItem>();
    Object cartObject = session.getAttribute("cart");

    if (cartObject instanceof List<?>) {
        for (Object obj : (List<?>) cartObject) {
            if (obj instanceof CartItem) {
                cart.add((CartItem) obj);
            }
        }
    }

    double foodTotal = 0;
    for (CartItem item : cart) {
        foodTotal += item.getItemTotal();
    }

    double deliveryFee = 40;
    double platformFee = 20;
    double grandTotal = foodTotal + deliveryFee + platformFee;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Checkout</title>

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
    max-width: 1320px;
    margin: 40px auto 80px;
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

/* Checkout Layout */
.checkout-layout {
    display: grid;
    grid-template-columns: 1fr 380px;
    gap: 24px;
    align-items: start;
}

.left-section {
    display: flex;
    flex-direction: column;
    gap: 24px;
}

.card {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    padding: 24px;
    box-shadow: var(--shadow);
}

.card h2 {
    color: var(--text-main);
    font-size: 18px;
    font-weight: 800;
    margin-bottom: 18px;
}

.form-group {
    margin-bottom: 16px;
}

.form-group label {
    display: block;
    margin-bottom: 6px;
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 700;
}

.form-group input,
.form-group textarea,
.card-input,
.card-select {
    width: 100%;
    padding: 12px 14px;
    border: 1px solid var(--panel-border);
    background: var(--metric-bg);
    color: var(--text-main);
    border-radius: 6px;
    outline: none;
    font-size: 13px;
    font-weight: 500;
}

.form-group input:focus,
.form-group textarea:focus,
.card-input:focus,
.card-select:focus {
    border-color: var(--accent);
}

.form-group textarea {
    min-height: 90px;
    resize: vertical;
}

.location-button {
    width: 100%;
    margin-top: 10px;
    padding: 11px 15px;
    background: rgba(226, 55, 68, 0.1);
    color: var(--accent);
    border: 1px solid var(--accent);
    border-radius: 6px;
    font-size: 13px;
    font-weight: 800;
    cursor: pointer;
    transition: 0.2s;
}

.location-button:hover {
    background: var(--accent);
    color: white;
}

.location-button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.location-status {
    margin-top: 8px;
    font-size: 11px;
    color: var(--text-muted);
    min-height: 18px;
    font-weight: 600;
}

.location-status.success {
    color: #24963f;
}

.location-status.error {
    color: var(--accent);
}

.payment-option {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    border-radius: 6px;
    margin-bottom: 10px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 700;
}

.payment-option:hover {
    border-color: var(--accent);
}

.payment-option input {
    accent-color: var(--accent);
}

.payment-option span {
    color: var(--text-main);
}

.upi-section {
    display: none;
    margin-top: 16px;
    padding: 16px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    border-radius: 6px;
}

.upi-section h3 {
    color: var(--text-main);
    font-size: 14px;
    font-weight: 800;
    margin-bottom: 12px;
}

.upi-apps {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    margin-bottom: 16px;
}

.upi-app {
    padding: 10px 6px;
    border: 1px solid var(--panel-border);
    border-radius: 6px;
    text-align: center;
    color: var(--text-muted);
    cursor: pointer;
    background: var(--bg-card-dark);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 6px;
    transition: 0.2s;
}

.upi-app:hover {
    border-color: var(--accent);
}

.upi-app.selected {
    border-color: var(--accent);
    color: var(--accent);
    background: rgba(226, 55, 68, 0.1);
}

.upi-app input {
    display: none;
}

.upi-logo {
    width: 36px;
    height: 36px;
    border-radius: 6px;
    object-fit: contain;
    background: #fff;
    padding: 4px;
}

.upi-app-name {
    font-size: 11px;
    font-weight: 700;
    color: var(--text-main);
}

.upi-app.selected .upi-app-name {
    color: var(--accent);
}

.upi-selected-text {
    margin-top: 4px;
    margin-bottom: 12px;
    text-align: center;
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 600;
}

.card-section {
    display: none;
    margin-top: 16px;
    padding: 16px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    border-radius: 6px;
}

.card-section h3 {
    color: var(--text-main);
    font-size: 14px;
    font-weight: 800;
    margin-bottom: 14px;
}

.card-number-wrapper {
    position: relative;
}

.card-number-icon {
    position: absolute;
    right: 12px;
    top: 11px;
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 800;
}

.card-security-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
}

.card-hint {
    color: var(--text-muted);
    font-size: 10px;
    margin-top: 4px;
}

.card-select option {
    background: var(--bg-card-dark);
    color: var(--text-main);
}

.order-summary {
    position: sticky;
    top: 90px;
}

.citem {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid var(--panel-border);
}

.citem-img {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 6px;
    background: #000;
}

.citem-d {
    flex: 1;
}

.citem-d h3 {
    color: var(--text-main);
    font-size: 13px;
    font-weight: 800;
    margin-bottom: 4px;
}

.citem-d p {
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 600;
}

.citem-p {
    color: #24963f;
    font-weight: 800;
    font-size: 13px;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    margin: 12px 0;
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 600;
}

.summary-row span:last-child {
    color: var(--text-main);
    font-weight: 700;
}

.summary-row.total {
    border-top: 1px solid var(--panel-border);
    padding-top: 14px;
    margin-top: 16px;
    color: var(--text-main);
    font-size: 16px;
    font-weight: 800;
}

.summary-row.total span:last-child {
    color: #24963f;
    font-size: 18px;
    font-weight: 900;
}

.place-order-btn {
    width: 100%;
    margin-top: 20px;
    padding: 13px;
    background: var(--accent);
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 800;
    cursor: pointer;
    transition: background 0.2s;
}

.place-order-btn:hover {
    background: #d12e3b;
}

.empty-cart {
    max-width: 600px;
    margin: 50px auto;
    padding: 50px 20px;
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    text-align: center;
    box-shadow: var(--shadow);
}

.empty-cart h2 {
    color: var(--text-main);
    font-size: 20px;
    font-weight: 800;
    margin-bottom: 10px;
}

.empty-cart p {
    color: var(--text-muted);
    font-size: 13px;
    margin-bottom: 20px;
}

.browse-btn {
    display: inline-block;
    background: var(--accent);
    color: white;
    text-decoration: none;
    padding: 10px 24px;
    border-radius: 6px;
    font-weight: 800;
    font-size: 13px;
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

@media (max-width: 900px) {
    .checkout-layout { grid-template-columns: 1fr; }
    .order-summary { position: static; }
    .upi-apps { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 600px) {
    .page-container { width: 94%; margin-top: 25px; }
    .page-title h1 { font-size: 24px; }
    .card { padding: 18px; }
    .card-security-row { grid-template-columns: 1fr; }
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

<div class="page-title">
    <h1>Checkout</h1>
    <p>Complete your order and enjoy your meal</p>
</div>

<% if (cart.isEmpty()) { %>

    <div class="empty-cart">
        <h2>Your Cart is Empty</h2>
        <p>Add some delicious food before proceeding to checkout.</p>
        <a href="restaurants" class="browse-btn">Browse Restaurants</a>
    </div>

<% } else { %>

    <form id="orderForm" action="payment.jsp" method="post">

        <div class="checkout-layout">

            <div class="left-section">

                <div class="card">
                    <h2>Delivery Details</h2>

                    <div class="form-group">
                        <label for="customerName">Full Name</label>
                        <input
                            type="text"
                            id="customerName"
                            name="customerName"
                            value="<%= user.getName() != null ? user.getName() : "" %>"
                            placeholder="Enter your full name"
                            required>
                    </div>

                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input
                            type="text"
                            id="phone"
                            name="phone"
                            value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                            placeholder="Enter your phone number"
                            required>
                    </div>

                    <div class="form-group">
                        <label for="address">Delivery Address</label>
                        <textarea
                            id="address"
                            name="address"
                            placeholder="Enter your full delivery address"
                            required><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>

                        <button
                            type="button"
                            class="location-button"
                            id="locationButton"
                            onclick="getLiveLocation()">
                            Use My Live Location
                        </button>

                        <div id="locationStatus" class="location-status">
                            Allow location access to automatically use your current location.
                        </div>
                    </div>
                </div>

                <div class="card">
                    <h2>Payment Method</h2>

                    <label class="payment-option">
                        <input
                            type="radio"
                            name="paymentOption"
                            value="COD"
                            checked
                            onchange="showPaymentMethod()">
                        <span>Cash on Delivery</span>
                    </label>

                    <label class="payment-option">
                        <input
                            type="radio"
                            name="paymentOption"
                            value="UPI"
                            onchange="showPaymentMethod()">
                        <span>UPI Payment</span>
                    </label>

                    <label class="payment-option">
                        <input
                            type="radio"
                            name="paymentOption"
                            value="CARD"
                            onchange="showPaymentMethod()">
                        <span>Credit / Debit Card</span>
                    </label>

                    <div class="upi-section" id="upiSection">
                        <h3>Select UPI App</h3>

                        <div class="upi-apps">
                            <label class="upi-app">
                                <input
                                    type="radio"
                                    name="upiMethod"
                                    value="Google Pay"
                                    onchange="selectUpiApp(this)">
                                <img
                                    class="upi-logo"
                                    src="https://cdn.simpleicons.org/googlepay"
                                    alt="Google Pay">
                                <span class="upi-app-name">Google Pay</span>
                            </label>

                            <label class="upi-app">
                                <input
                                    type="radio"
                                    name="upiMethod"
                                    value="PhonePe"
                                    onchange="selectUpiApp(this)">
                                <img
                                    class="upi-logo"
                                    src="https://cdn.simpleicons.org/phonepe"
                                    alt="PhonePe">
                                <span class="upi-app-name">PhonePe</span>
                            </label>

                            <label class="upi-app">
                                <input
                                    type="radio"
                                    name="upiMethod"
                                    value="Paytm"
                                    onchange="selectUpiApp(this)">
                                <img
                                    class="upi-logo"
                                    src="https://cdn.simpleicons.org/paytm"
                                    alt="Paytm">
                                <span class="upi-app-name">Paytm</span>
                            </label>

                            <label class="upi-app">
                                <input
                                    type="radio"
                                    name="upiMethod"
                                    value="BHIM UPI"
                                    onchange="selectUpiApp(this)">
                                <img
                                    class="upi-logo"
                                    src="https://cdn.simpleicons.org/bhim"
                                    alt="BHIM UPI">
                                <span class="upi-app-name">BHIM UPI</span>
                            </label>
                        </div>

                        <div class="upi-selected-text" id="upiSelectedText">
                            Select a UPI app
                        </div>

                        <div class="form-group">
                            <label for="upiId">UPI ID</label>
                            <input
                                type="text"
                                id="upiId"
                                name="upiId"
                                placeholder="example@upi">
                        </div>
                    </div>

                    <div class="card-section" id="cardSection">
                        <h3>Card Details</h3>

                        <div class="form-group">
                            <label for="cardType">Card Type</label>
                            <select
                                class="card-select"
                                id="cardType"
                                name="cardType">
                                <option value="">Select Card Type</option>
                                <option value="Credit Card">Credit Card</option>
                                <option value="Debit Card">Debit Card</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="cardNumber">Card Number</label>
                            <div class="card-number-wrapper">
                                <input
                                    class="card-input"
                                    type="text"
                                    id="cardNumber"
                                    name="cardNumber"
                                    maxlength="19"
                                    placeholder="1234 5678 9012 3456"
                                    inputmode="numeric">
                                <span class="card-number-icon">CARD</span>
                            </div>
                            <div class="card-hint">
                                Enter your 16-digit card number
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="cardHolderName">Cardholder Name</label>
                            <input
                                class="card-input"
                                type="text"
                                id="cardHolderName"
                                name="cardHolderName"
                                placeholder="Name as shown on card">
                        </div>

                        <div class="card-security-row">
                            <div class="form-group">
                                <label for="expiryDate">Expiry Date</label>
                                <input
                                    class="card-input"
                                    type="text"
                                    id="expiryDate"
                                    name="expiryDate"
                                    maxlength="5"
                                    placeholder="MM/YY"
                                    inputmode="numeric">
                            </div>

                            <div class="form-group">
                                <label for="cvv">CVV</label>
                                <input
                                    class="card-input"
                                    type="password"
                                    id="cvv"
                                    name="cvv"
                                    maxlength="3"
                                    placeholder="123"
                                    inputmode="numeric">
                            </div>
                        </div>
                    </div>
                </div>

            </div>

            <div class="card order-summary">
                <h2>Order Summary</h2>

                <% for (CartItem item : cart) { %>
                    <div class="citem">
                        <img
                            class="citem-img"
                            src="<%= item.getMenu().getImagePath() %>"
                            alt="<%= item.getMenu().getName() %>"
                            onerror="this.style.display='none';">

                        <div class="citem-d">
                            <h3><%= item.getMenu().getName() %></h3>
                            <p>Qty: <%= item.getQuantity() %></p>
                        </div>

                        <div class="citem-p">
                            &#8377;<%= String.format("%.2f", item.getItemTotal()) %>
                        </div>
                    </div>
                <% } %>

                <div class="summary-row">
                    <span>Food Total</span>
                    <span>&#8377;<%= String.format("%.2f", foodTotal) %></span>
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

                <input
                    type="hidden"
                    name="totalAmount"
                    value="<%= grandTotal %>">

                <button
                    type="submit"
                    class="place-order-btn">
                    Proceed to Payment &#8377;<%= String.format("%.0f", grandTotal) %>
                </button>
            </div>

        </div>

    </form>

<% } %>

</div>

<script>
function getLiveLocation() {
    var button = document.getElementById("locationButton");
    var status = document.getElementById("locationStatus");
    var address = document.getElementById("address");

    if (!navigator.geolocation) {
        status.textContent = "Live location is not supported by this browser.";
        status.className = "location-status error";
        return;
    }

    button.disabled = true;
    button.textContent = "Getting Your Location...";
    status.textContent = "Please allow location access in your browser.";
    status.className = "location-status";

    navigator.geolocation.getCurrentPosition(
        function(position) {
            var latitude = position.coords.latitude;
            var longitude = position.coords.longitude;

            address.value = "Live Location: Latitude " + latitude.toFixed(6) + ", Longitude " + longitude.toFixed(6);
            status.textContent = "Live location captured successfully.";
            status.className = "location-status success";

            button.disabled = false;
            button.textContent = "Location Captured";
        },
        function(error) {
            button.disabled = false;
            button.textContent = "Use My Live Location";
            status.className = "location-status error";

            if (error.code === 1) {
                status.textContent = "Location permission was denied. Please allow location access.";
            } else if (error.code === 2) {
                status.textContent = "Your location could not be determined. Please try again.";
            } else if (error.code === 3) {
                status.textContent = "Location request timed out. Please try again.";
            } else {
                status.textContent = "Unable to get your location. Please try again.";
            }
        },
        { enableHighAccuracy: true, timeout: 15000, maximumAge: 0 }
    );
}

function showPaymentMethod() {
    var selected = document.querySelector('input[name="paymentOption"]:checked');
    var upiSection = document.getElementById("upiSection");
    var cardSection = document.getElementById("cardSection");

    if (!selected) return;

    upiSection.style.display = "none";
    cardSection.style.display = "none";

    if (selected.value === "UPI") {
        upiSection.style.display = "block";
    }

    if (selected.value === "CARD") {
        cardSection.style.display = "block";
    }

    if (selected.value !== "UPI") {
        document.querySelectorAll('input[name="upiMethod"]').forEach(function(input) { input.checked = false; });
        document.querySelectorAll(".upi-app").forEach(function(app) { app.classList.remove("selected"); });
        document.getElementById("upiId").value = "";
        document.getElementById("upiSelectedText").textContent = "Select a UPI app";
    }

    if (selected.value !== "CARD") {
        document.getElementById("cardType").value = "";
        document.getElementById("cardNumber").value = "";
        document.getElementById("cardHolderName").value = "";
        document.getElementById("expiryDate").value = "";
        document.getElementById("cvv").value = "";
    }
}

function selectUpiApp(input) {
    document.querySelectorAll(".upi-app").forEach(function(app) { app.classList.remove("selected"); });
    var app = input.closest(".upi-app");
    if (app) {
        app.classList.add("selected");
        document.getElementById("upiSelectedText").textContent = "Selected: " + input.value;
    }
}

var cardNumber = document.getElementById("cardNumber");
if (cardNumber) {
    cardNumber.addEventListener("input", function() {
        var value = this.value.replace(/\D/g, "").substring(0, 16);
        var formatted = "";
        for (var i = 0; i < value.length; i++) {
            if (i > 0 && i % 4 === 0) formatted += " ";
            formatted += value[i];
        }
        this.value = formatted;
    });
}

var expiryDate = document.getElementById("expiryDate");
if (expiryDate) {
    expiryDate.addEventListener("input", function() {
        var value = this.value.replace(/\D/g, "").substring(0, 4);
        this.value = value.length >= 3 ? value.substring(0, 2) + "/" + value.substring(2) : value;
    });
}

var cvv = document.getElementById("cvv");
if (cvv) {
    cvv.addEventListener("input", function() {
        this.value = this.value.replace(/\D/g, "").substring(0, 3);
    });
}

var orderForm = document.getElementById("orderForm");
if (orderForm) {
    orderForm.addEventListener("submit", function(event) {
        var selected = document.querySelector('input[name="paymentOption"]:checked');
        if (!selected) {
            event.preventDefault();
            alert("Please select a payment method.");
            return;
        }

        if (selected.value === "UPI") {
            var upiMethod = document.querySelector('input[name="upiMethod"]:checked');
            if (!upiMethod) {
                event.preventDefault();
                alert("Please select a UPI payment method.");
                return;
            }
            var upiId = document.getElementById("upiId").value.trim();
            if (upiId === "" || !upiId.includes("@")) {
                event.preventDefault();
                alert("Please enter a valid UPI ID.");
                return;
            }
        }

        if (selected.value === "CARD") {
            var cardType = document.getElementById("cardType").value;
            var cardNumberValue = document.getElementById("cardNumber").value.replace(/\s/g, "");
            var cardHolderName = document.getElementById("cardHolderName").value.trim();
            var expiry = document.getElementById("expiryDate").value.trim();
            var cvvValue = document.getElementById("cvv").value.trim();

            if (cardType === "") {
                event.preventDefault();
                alert("Please select Credit Card or Debit Card.");
                return;
            }
            if (!/^\d{16}$/.test(cardNumberValue)) {
                event.preventDefault();
                alert("Please enter a valid 16-digit card number.");
                return;
            }
            if (cardHolderName === "") {
                event.preventDefault();
                alert("Please enter the cardholder name.");
                return;
            }
            if (!/^\d{2}\/\d{2}$/.test(expiry)) {
                event.preventDefault();
                alert("Please enter the expiry date in MM/YY format.");
                return;
            }
            if (!/^\d{3}$/.test(cvvValue)) {
                event.preventDefault();
                alert("Please enter a valid 3-digit CVV.");
                return;
            }
        }
    });
}

showPaymentMethod();

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