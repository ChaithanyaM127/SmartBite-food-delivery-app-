<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
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

    String po = request.getParameter("paymentOption");
    String um = request.getParameter("upiMethod");
    String ui = request.getParameter("upiId");

    String customerName = request.getParameter("customerName");
    String phone = request.getParameter("phone");
    String address = request.getParameter("address");

    if (customerName == null || customerName.trim().isEmpty()) {
        customerName = user.getName();
    }

    if (phone == null || phone.trim().isEmpty()) {
        phone = user.getPhone();
    }

    if (address == null || address.trim().isEmpty()) {
        address = user.getAddress();
    }

    List<CartItem> cart = new java.util.ArrayList<>();
    Object ob = session.getAttribute("cart");

    if (ob instanceof List<?>) {
        for (Object x : (List<?>) ob) {
            if (x instanceof CartItem) {
                cart.add((CartItem) x);
            }
        }
    }

    if (cart.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/cart");
        return;
    }

    double food = 0;
    for (CartItem it : cart) {
        food += it.getItemTotal();
    }

    double deliveryFee = 40;
    double platformFee = 20;
    double total = food + deliveryFee + platformFee;

    String label = (po == null || po.trim().isEmpty())
            ? "Cash on Delivery"
            : po.trim();

    if ("UPI".equalsIgnoreCase(label)
            && um != null
            && !um.trim().isEmpty()) {
        label = "UPI - " + um.trim();
    }

    String btnText = label.toLowerCase().contains("cash")
            ? "Confirm Order (Cash on Delivery)"
            : "Pay Rs." + String.format("%.2f", total);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Secure Payment</title>

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

/* Wrap Container */
.wrap {
    width: 90%;
    max-width: 640px;
    margin: 40px auto 80px;
}

.pcard {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    padding: 30px;
    box-shadow: var(--shadow);
}

h1 {
    font-size: 26px;
    font-weight: 800;
    color: var(--text-main);
    text-align: center;
    margin-bottom: 6px;
    letter-spacing: -0.5px;
}

p.sub {
    text-align: center;
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 24px;
}

.customer-box {
    margin-bottom: 20px;
    padding: 16px;
    border-radius: 6px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
}

.customer-box h3 {
    color: var(--text-main);
    font-size: 14px;
    font-weight: 800;
    margin-bottom: 8px;
}

.customer-box p {
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 600;
    line-height: 1.5;
}

.row {
    display: flex;
    justify-content: space-between;
    padding: 11px 0;
    border-bottom: 1px solid var(--panel-border);
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
}

.row span:last-child {
    color: var(--text-main);
    font-weight: 700;
}

.row.t {
    border: none;
    font-weight: 800;
    font-size: 16px;
    color: var(--text-main);
    padding-top: 16px;
}

.row.t span:last-child {
    color: #24963f;
    font-size: 18px;
    font-weight: 900;
}

.method {
    margin: 18px 0 6px;
    padding: 12px;
    border-radius: 6px;
    background: rgba(226, 55, 68, 0.1);
    border: 1px solid rgba(226, 55, 68, 0.3);
    color: var(--accent);
    font-weight: 800;
    text-align: center;
    font-size: 14px;
}

.pay {
    width: 100%;
    margin-top: 18px;
    background: var(--accent);
    color: #fff;
    border: none;
    padding: 14px;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 800;
    cursor: pointer;
    transition: background 0.2s;
}

.pay:hover {
    background: #d12e3b;
}

.back {
    display: block;
    text-align: center;
    margin-top: 14px;
    color: var(--text-muted);
    text-decoration: none;
    font-size: 12px;
    font-weight: 700;
}

.back:hover {
    color: var(--accent);
}

.secure {
    text-align: center;
    color: var(--text-muted);
    font-size: 10px;
    font-weight: 800;
    margin-top: 14px;
    letter-spacing: 0.8px;
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
    .wrap { width: 94%; margin-top: 25px; }
    .pcard { padding: 18px; }
    .row { font-size: 12px; }
    .row.t { font-size: 15px; }
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

<div class="wrap">

<div class="pcard">

    <h1>Secure Payment</h1>
    <p class="sub">Review and confirm your SmartBite order</p>

    <div class="customer-box">
        <h3>Delivery Details</h3>
        <p><strong>Name:</strong> <%= customerName != null ? customerName : "" %></p>
        <p><strong>Phone:</strong> <%= phone != null ? phone : "" %></p>
        <p><strong>Address:</strong> <%= address != null ? address : "" %></p>
    </div>

    <% for (CartItem it : cart) { %>
        <div class="row">
            <span><%= it.getMenu().getName() %> &#215; <%= it.getQuantity() %></span>
            <span>&#8377;<%= String.format("%.2f", it.getItemTotal()) %></span>
        </div>
    <% } %>

    <div class="row">
        <span>Delivery Fee</span>
        <span>&#8377;40.00</span>
    </div>

    <div class="row">
        <span>Platform Fee</span>
        <span>&#8377;20.00</span>
    </div>

    <div class="row t">
        <span>Amount Payable</span>
        <span>&#8377;<%= String.format("%.2f", total) %></span>
    </div>

    <div class="method">
        &#128179; <%= label %>
    </div>

    <form action="<%= request.getContextPath() %>/place-order" method="post">
        <input type="hidden" name="paymentOption" value="<%= po != null ? po : "COD" %>">
        <input type="hidden" name="upiMethod" value="<%= um != null ? um : "" %>">
        <input type="hidden" name="upiId" value="<%= ui != null ? ui : "" %>">
        <input type="hidden" name="customerName" value="<%= customerName != null ? customerName : "" %>">
        <input type="hidden" name="phone" value="<%= phone != null ? phone : "" %>">
        <input type="hidden" name="address" value="<%= address != null ? address : "" %>">
        <input type="hidden" name="totalAmount" value="<%= total %>">

        <button type="submit" class="pay">
            <%= btnText %> &#128664;
        </button>
    </form>

    <a class="back" href="<%= request.getContextPath() %>/checkout.jsp">
        &#8592; Back to Checkout
    </a>

    <div class="secure">
        &#128274; DEMO GATEWAY &#8212; NO REAL MONEY IS CHARGED
    </div>

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