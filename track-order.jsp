<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Integer orderIdObj = (Integer) request.getAttribute("orderId");
    java.sql.Timestamp orderDate = (java.sql.Timestamp) request.getAttribute("orderDate");
    Float totalAmountObj = (Float) request.getAttribute("totalAmount");
    String statusObj = (String) request.getAttribute("status");
    String paymentOptionObj = (String) request.getAttribute("paymentOption");

    boolean orderFound = orderIdObj != null;
    int orderId = orderFound ? orderIdObj : 0;
    float totalAmount = totalAmountObj != null ? totalAmountObj : 0.0f;

    String status = statusObj != null && !statusObj.trim().isEmpty() ? statusObj.trim() : "PLACED";
    String paymentOption = paymentOptionObj != null && !paymentOptionObj.trim().isEmpty() ? paymentOptionObj.trim() : "Not Available";

    String displayStatus = status.replace("_", " ");
    int progress = 1;
    String currentStatus = status.toUpperCase();

    if ("PLACED".equals(currentStatus)) {
        progress = 1;
    } else if ("CONFIRMED".equals(currentStatus) || "ACCEPTED".equals(currentStatus)) {
        progress = 2;
    } else if ("PREPARING".equals(currentStatus)) {
        progress = 3;
    } else if ("OUT_FOR_DELIVERY".equals(currentStatus) || "OUT FOR DELIVERY".equals(currentStatus)) {
        progress = 4;
    } else if ("DELIVERED".equals(currentStatus)) {
        progress = 5;
    } else if ("CANCELLED".equals(currentStatus)) {
        progress = 0;
        displayStatus = "Order Cancelled";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Track Order</title>

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

.nav-links a:hover,
.nav-links a.active {
    color: var(--accent);
}

/* Profile icon: compact SmartBite navbar size */
.profile-avatar {
    width: 30px;
    height: 30px;
    min-width: 30px;
    flex: 0 0 30px;
    border-radius: 50%;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    text-decoration: none;
    transition: transform 0.2s ease, border-color 0.2s ease;
}

.profile-avatar:hover {
    transform: scale(1.08);
    border-color: var(--accent);
}

/* SmartBite dark/light controls */
.controls-box {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    padding: 5px 9px;
    border-radius: 30px;
    flex-shrink: 0;
}

.theme-mode-btn {
    width: 25px;
    height: 25px;
    min-width: 25px;
    padding: 0;
    border: 1px solid transparent;
    border-radius: 50%;
    background: transparent;
    color: var(--text-muted);
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 15px;
    line-height: 1;
    flex-shrink: 0;
    transition:
        background 0.2s ease,
        color 0.2s ease,
        border-color 0.2s ease,
        transform 0.2s ease;
}

.theme-mode-btn:hover {
    color: var(--text-main);
    transform: scale(1.08);
}

.theme-mode-btn.active {
    color: var(--accent);
    background: rgba(226, 55, 68, 0.10);
    border-color: rgba(226, 55, 68, 0.25);
}

/* Ultra-thin custom brightness slider */
.brightness-slider {
    position: relative;
    width: 58px;
    min-width: 58px;
    height: 16px;
    flex-shrink: 0;
    cursor: pointer;
    touch-action: none;
    outline: none;
    -webkit-tap-highlight-color: transparent;
}

.brightness-track {
    position: absolute;
    top: 50%;
    left: 0;
    width: 100%;
    height: 2px;
    transform: translateY(-50%);
    border-radius: 10px;
    background: var(--text-muted);
    opacity: 0.55;
}

.brightness-fill {
    position: absolute;
    top: 50%;
    left: 0;
    width: 50%;
    height: 2px;
    transform: translateY(-50%);
    border-radius: 10px;
    background: var(--accent);
    pointer-events: none;
}

.brightness-thumb {
    position: absolute;
    top: 50%;
    left: 50%;
    width: 8px;
    height: 8px;
    transform: translate(-50%, -50%);
    border-radius: 50%;
    background: var(--accent);
    border: 1px solid var(--accent);
    box-shadow: 0 0 0 2px var(--nav-bg);
    pointer-events: none;
    transition: box-shadow 0.15s ease;
}

.brightness-slider:hover .brightness-thumb,
.brightness-slider:focus-visible .brightness-thumb {
    box-shadow: 0 0 0 3px var(--accent-glow);
}

.brightness-slider:focus-visible {
    outline: none;
}

/* Container */
.container {
    width: 92%;
    max-width: 950px;
    margin: 40px auto 80px;
}

.heading {
    text-align: center;
    margin-bottom: 28px;
}

.heading h1 {
    font-size: 28px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.5px;
    margin-bottom: 6px;
}

.heading p {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
}

.card {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    box-shadow: var(--shadow);
}

.order-card {
    padding: 24px;
    margin-bottom: 20px;
}

.order-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
    padding-bottom: 20px;
    border-bottom: 1px solid var(--panel-border);
}

.small-title {
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}

.order-number {
    font-size: 22px;
    font-weight: 800;
    color: var(--text-main);
}

.status {
    padding: 8px 16px;
    border-radius: 20px;
    background: rgba(226, 55, 68, 0.1);
    border: 1px solid rgba(226, 55, 68, 0.3);
    color: var(--accent);
    font-size: 12px;
    font-weight: 800;
    text-transform: uppercase;
}

.status.cancelled {
    background: rgba(220, 50, 50, 0.1);
    border-color: rgba(220, 50, 50, 0.3);
    color: #ff7777;
}

.details {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    margin-top: 20px;
}

.detail {
    padding: 16px;
    border-radius: 6px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
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
    font-size: 15px;
    font-weight: 800;
}

.tracking-card {
    padding: 30px 24px;
}

.tracking-title {
    text-align: center;
    font-size: 18px;
    font-weight: 800;
    color: var(--text-main);
    margin-bottom: 35px;
}

.tracking {
    position: relative;
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
}

.line {
    position: absolute;
    top: 20px;
    left: 10%;
    width: 80%;
    height: 3px;
    background: var(--panel-border);
    border-radius: 2px;
    z-index: 0;
}

.progress {
    position: absolute;
    top: 20px;
    left: 10%;
    height: 3px;
    width: <%= Math.max(0, (progress - 1) * 20) %>%;
    max-width: 80%;
    background: #24963f;
    border-radius: 2px;
    z-index: 1;
}

.step {
    width: 20%;
    text-align: center;
    position: relative;
    z-index: 2;
}

.circle {
    width: 40px;
    height: 40px;
    margin: 0 auto 12px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--metric-bg);
    border: 2px solid var(--panel-border);
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 800;
}

.step.completed .circle {
    background: #24963f;
    border-color: #24963f;
    color: white;
}

.step-title {
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 600;
    line-height: 1.3;
}

.step.completed .step-title {
    color: var(--text-main);
    font-weight: 800;
}

.message {
    margin-top: 30px;
    padding: 16px;
    text-align: center;
    border-radius: 6px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    color: var(--text-main);
    font-size: 13px;
    font-weight: 600;
    line-height: 1.5;
}

.cancelled-message {
    background: rgba(220, 50, 50, 0.1);
    border-color: rgba(220, 50, 50, 0.3);
    color: #ff8080;
}

.error {
    padding: 40px;
    text-align: center;
}

.error h2 {
    color: var(--text-main);
    font-size: 20px;
    font-weight: 800;
    margin-bottom: 10px;
}

.error p {
    color: var(--text-muted);
    font-size: 13px;
    margin-bottom: 20px;
}

.button {
    display: inline-block;
    padding: 12px 22px;
    border-radius: 6px;
    background: var(--accent);
    color: white;
    text-decoration: none;
    font-weight: 800;
    font-size: 13px;
    transition: background 0.2s;
    border: none;
    cursor: pointer;
}

.button:hover {
    background: #d12e3b;
}

.action-area {
    display: flex;
    justify-content: center;
    gap: 12px;
    margin-top: 24px;
}

.secondary-button {
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    color: var(--text-main);
}

.secondary-button:hover {
    border-color: var(--accent);
    background: var(--metric-bg);
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
    .nav-container {
        padding: 12px 16px;
    }

    .nav-links {
        gap: 14px;
    }

    .nav-links a {
        font-size: 13px;
    }
}

@media (max-width: 700px) {
    .nav-container {
        flex-wrap: wrap;
        gap: 12px;
    }

    .nav-links {
        flex-wrap: wrap;
        justify-content: flex-end;
        gap: 12px;
    }

    .container {
        width: 94%;
        margin-top: 25px;
    }

    .order-card,
    .tracking-card {
        padding: 18px;
    }

    .order-header {
        flex-direction: column;
        align-items: flex-start;
    }

    .details {
        grid-template-columns: 1fr;
    }

    .tracking {
        flex-direction: column;
        gap: 20px;
    }

    .line,
    .progress {
        display: none;
    }

    .step {
        width: 100%;
        display: flex;
        align-items: center;
        gap: 14px;
        text-align: left;
    }

    .circle {
        flex-shrink: 0;
        margin: 0;
    }

    .action-area {
        flex-direction: column;
    }

    .button {
        width: 100%;
        text-align: center;
    }
}

@media (max-width: 480px) {
    .nav-container {
        align-items: flex-start;
    }

    .logo {
        font-size: 23px;
    }

    .nav-links {
        gap: 9px;
    }

    .nav-links a {
        font-size: 12px;
    }

    .controls-box {
        gap: 6px;
        padding: 4px 6px;
    }

    .brightness-slider {
        width: 46px;
        min-width: 46px;
    }

    .heading h1 {
        font-size: 24px;
    }
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
                <a href="profile.jsp" class="profile-avatar" title="Profile" aria-label="Profile">👤</a>

                <div class="controls-box" aria-label="Theme and brightness controls">

                    <button
                        type="button"
                        class="theme-mode-btn"
                        id="lightModeBtn"
                        onclick="setThemeMode('light')"
                        title="Light Mode"
                        aria-label="Switch to Light Mode"
                        aria-pressed="false">☀</button>

                    <div
                        class="brightness-slider"
                        id="brightnessSlider"
                        role="slider"
                        tabindex="0"
                        aria-label="Adjust screen brightness"
                        aria-valuemin="0.5"
                        aria-valuemax="1.5"
                        aria-valuenow="1"
                        aria-valuetext="100 percent brightness"
                        title="Drag to adjust brightness"
                        onkeydown="handleBrightnessKeydown(event)">

                        <span class="brightness-track" aria-hidden="true"></span>
                        <span class="brightness-fill" id="brightnessFill" aria-hidden="true"></span>
                        <span class="brightness-thumb" id="brightnessThumb" aria-hidden="true"></span>
                    </div>

                    <button
                        type="button"
                        class="theme-mode-btn"
                        id="darkModeBtn"
                        onclick="setThemeMode('dark')"
                        title="Dark Mode"
                        aria-label="Switch to Dark Mode"
                        aria-pressed="true">☾</button>

                </div>
            </nav>
        </div>
    </header>

<main class="container">

<div class="heading">
    <h1>Track Your Order</h1>
    <p>Follow your SmartBite order from the kitchen to your doorstep.</p>
</div>

<% if (!orderFound) { %>

    <div class="card error">
        <h2>Order Not Found</h2>
        <p>We could not find the requested order.</p>
        <a href="<%= request.getContextPath() %>/orders" class="button">View My Orders</a>
    </div>

<% } else { %>

    <div class="card order-card">
        <div class="order-header">
            <div>
                <div class="small-title">Order ID</div>
                <div class="order-number">#<%= orderId %></div>
            </div>

            <div class="status <%= "CANCELLED".equalsIgnoreCase(status) ? "cancelled" : "" %>">
                <%= displayStatus %>
            </div>
        </div>

        <div class="details">
            <div class="detail">
                <div class="detail-label">Order Status</div>
                <div class="detail-value"><%= displayStatus %></div>
            </div>

            <div class="detail">
                <div class="detail-label">Payment</div>
                <div class="detail-value"><%= paymentOption %></div>
            </div>

            <div class="detail">
                <div class="detail-label">Total Amount</div>
                <div class="detail-value">&#8377;<%= String.format("%.2f", totalAmount) %></div>
            </div>

            <div class="detail">
                <div class="detail-label">Order Date</div>
                <div class="detail-value"><%= orderDate != null ? orderDate : "Not Available" %></div>
            </div>
        </div>
    </div>

    <div class="card tracking-card">
        <div class="tracking-title">Order Progress</div>

        <% if ("CANCELLED".equalsIgnoreCase(status)) { %>
            <div class="message cancelled-message">
                This order has been cancelled.
            </div>
        <% } else { %>
            <div class="tracking">
                <div class="line"></div>
                <div class="progress"></div>

                <div class="step <%= progress >= 1 ? "completed" : "" %>">
                    <div class="circle">P</div>
                    <div class="step-title">Order<br>Placed</div>
                </div>

                <div class="step <%= progress >= 2 ? "completed" : "" %>">
                    <div class="circle">A</div>
                    <div class="step-title">Order<br>Accepted</div>
                </div>

                <div class="step <%= progress >= 3 ? "completed" : "" %>">
                    <div class="circle">K</div>
                    <div class="step-title">Preparing<br>Food</div>
                </div>

                <div class="step <%= progress >= 4 ? "completed" : "" %>">
                    <div class="circle">D</div>
                    <div class="step-title">Out For<br>Delivery</div>
                </div>

                <div class="step <%= progress >= 5 ? "completed" : "" %>">
                    <div class="circle">&#10003;</div>
                    <div class="step-title">Order<br>Delivered</div>
                </div>
            </div>

            <div class="message">
                <% if ("DELIVERED".equalsIgnoreCase(status)) { %>
                    Your order has been delivered. Enjoy your meal!
                <% } else if ("OUT_FOR_DELIVERY".equalsIgnoreCase(status) || "OUT FOR DELIVERY".equalsIgnoreCase(status)) { %>
                    Your food is on the way. It will reach you soon.
                <% } else if ("PREPARING".equalsIgnoreCase(status)) { %>
                    Your food is being freshly prepared by the restaurant.
                <% } else if ("CONFIRMED".equalsIgnoreCase(status) || "ACCEPTED".equalsIgnoreCase(status)) { %>
                    The restaurant has accepted your order and will start preparing it shortly.
                <% } else { %>
                    Your order has been placed successfully and is waiting for restaurant confirmation.
                <% } %>
            </div>
        <% } %>
    </div>

    <div class="action-area">
        <a href="<%= request.getContextPath() %>/orders" class="button">My Orders</a>
        <a href="<%= request.getContextPath() %>/restaurants" class="button secondary-button">Order More Food</a>
        <a href="<%= request.getContextPath() %>/order-success.jsp" class="button secondary-button">Back to Confirmation</a>
    </div>

<% } %>

</main>

<script>
/* SmartBite theme and custom brightness slider */
(function() {
    const savedTheme = localStorage.getItem("smartbite_theme");
    const savedBrightness = localStorage.getItem("smartbite_brightness");

    document.body.classList.toggle("light-mode", savedTheme === "light");

    let brightness = 1;

    if (savedBrightness !== null) {
        const parsedBrightness = parseFloat(savedBrightness);

        if (Number.isFinite(parsedBrightness)) {
            brightness = Math.min(1.5, Math.max(0.5, parsedBrightness));
        }
    }

    updateBrightnessSlider(brightness, false);
    updateThemeButtonUI();

    const slider = document.getElementById("brightnessSlider");

    if (slider) {
        let isDragging = false;

        slider.addEventListener("pointerdown", function(event) {
            isDragging = true;

            if (slider.setPointerCapture) {
                slider.setPointerCapture(event.pointerId);
            }

            updateBrightnessFromPointer(event);
            event.preventDefault();
        });

        slider.addEventListener("pointermove", function(event) {
            if (!isDragging) {
                return;
            }

            updateBrightnessFromPointer(event);
        });

        slider.addEventListener("pointerup", function(event) {
            isDragging = false;

            if (slider.hasPointerCapture &&
                slider.hasPointerCapture(event.pointerId)) {
                slider.releasePointerCapture(event.pointerId);
            }
        });

        slider.addEventListener("pointercancel", function() {
            isDragging = false;
        });

        slider.addEventListener("click", function(event) {
            updateBrightnessFromPointer(event);
        });
    }
})();

function setThemeMode(mode) {
    if (mode !== "light" && mode !== "dark") {
        return;
    }

    const isLight = mode === "light";

    document.body.classList.toggle("light-mode", isLight);
    localStorage.setItem("smartbite_theme", mode);

    updateThemeButtonUI();
}

function toggleTheme() {
    const isLight = document.body.classList.contains("light-mode");
    setThemeMode(isLight ? "dark" : "light");
}

function updateThemeButtonUI() {
    const isLight = document.body.classList.contains("light-mode");
    const lightButton = document.getElementById("lightModeBtn");
    const darkButton = document.getElementById("darkModeBtn");

    if (lightButton) {
        lightButton.classList.toggle("active", isLight);
        lightButton.setAttribute("aria-pressed", String(isLight));
    }

    if (darkButton) {
        darkButton.classList.toggle("active", !isLight);
        darkButton.setAttribute("aria-pressed", String(!isLight));
    }
}

function updateBrightnessFromPointer(event) {
    const slider = document.getElementById("brightnessSlider");

    if (!slider) {
        return;
    }

    const rect = slider.getBoundingClientRect();

    if (rect.width <= 0) {
        return;
    }

    const position = Math.min(
        1,
        Math.max(0, (event.clientX - rect.left) / rect.width)
    );

    const brightness = 0.5 + position;

    updateBrightnessSlider(brightness, true);
}

function updateBrightnessSlider(value, savePreference) {
    const brightness = Math.min(1.5, Math.max(0.5, Number(value)));
    const slider = document.getElementById("brightnessSlider");
    const fill = document.getElementById("brightnessFill");
    const thumb = document.getElementById("brightnessThumb");

    const percentage = ((brightness - 0.5) / (1.5 - 0.5)) * 100;

    if (slider) {
        slider.setAttribute("aria-valuenow", brightness.toFixed(2));
        slider.setAttribute(
            "aria-valuetext",
            Math.round(brightness * 100) + " percent brightness"
        );
    }

    if (fill) {
        fill.style.width = percentage + "%";
    }

    if (thumb) {
        thumb.style.left = percentage + "%";
    }

    document.documentElement.style.filter = "brightness(" + brightness + ")";

    if (savePreference) {
        localStorage.setItem("smartbite_brightness", String(brightness));
    }
}

function adjustBrightness(value) {
    updateBrightnessSlider(value, true);
}

function handleBrightnessKeydown(event) {
    const slider = document.getElementById("brightnessSlider");

    if (!slider) {
        return;
    }

    let currentValue = parseFloat(slider.getAttribute("aria-valuenow"));

    if (!Number.isFinite(currentValue)) {
        currentValue = 1;
    }

    let newValue = currentValue;
    const step = event.shiftKey ? 0.10 : 0.05;

    switch (event.key) {
        case "ArrowLeft":
        case "ArrowDown":
            newValue = currentValue - step;
            break;

        case "ArrowRight":
        case "ArrowUp":
            newValue = currentValue + step;
            break;

        case "Home":
            newValue = 0.5;
            break;

        case "End":
            newValue = 1.5;
            break;

        default:
            return;
    }

    event.preventDefault();
    updateBrightnessSlider(newValue, true);
}
</script>

<%@ include file="ai-assistant.jsp" %>

<footer>
    <p>&copy; 2026 SmartBite Delivery Platform. All rights reserved.</p>
</footer>

</body>
</html>
