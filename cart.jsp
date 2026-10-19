
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.foodtap.model.CartItem" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    List<CartItem> cart = new ArrayList<>();
    Object cartObject = session.getAttribute("cart");

    if (cartObject instanceof List<?>) {
        for (Object obj : (List<?>) cartObject) {
            if (obj instanceof CartItem) {
                CartItem cartItem = (CartItem) obj;
                if (cartItem.getQuantity() > 0) {
                    cart.add(cartItem);
                }
            }
        }
    }

    int cartCount = 0;
    float grandTotal = 0;

    for (CartItem item : cart) {
        cartCount += item.getQuantity();
        if (item.getMenu() != null) {
            grandTotal += item.getItemTotal();
        }
    }
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

<style>
:root {
    color-scheme: dark;
    --bg-page: #0d0d0f;
    --bg-card-dark: #121318;
    --bg-card-bottom: #1e1e24;
    --text-main: #ffffff;
    --text-muted: #a1a1aa;
    --text-bottom-main: #f4f4f5;
    --text-bottom-sub: #a1a1aa;
    --nav-bg: rgba(13,13,15,.90);
    --nav-border: rgba(255,255,255,.08);
    --panel-border: rgba(255,255,255,.08);
    --metric-bg: rgba(255,255,255,.04);
    --accent: #e23744;
    --accent-glow: rgba(226,55,68,.35);
    --shadow: 0 16px 36px rgba(0,0,0,.6);
}

body.light-mode {
    color-scheme: light;
    --bg-page: #f1f3f5;
    --bg-card-dark: #ffffff;
    --bg-card-bottom: #ffffff;
    --text-main: #111827;
    --text-muted: #6b7280;
    --text-bottom-main: #111827;
    --text-bottom-sub: #4b5563;
    --nav-bg: rgba(255,255,255,.95);
    --nav-border: rgba(0,0,0,.08);
    --panel-border: rgba(0,0,0,.08);
    --metric-bg: rgba(0,0,0,.03);
    --shadow: 0 10px 25px rgba(0,0,0,.06);
}

* { box-sizing: border-box; }

html {
    min-height: 100%;
}

html, body {
    margin: 0 !important;
    padding: 0 !important;
    background: linear-gradient(rgba(13,13,15,.90),rgba(13,13,15,.95)),
        url('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1600&q=80') center / cover fixed !important;
    color: var(--text-main) !important;
    font-family: 'Plus Jakarta Sans',-apple-system,BlinkMacSystemFont,sans-serif !important;
    min-height: 100vh;
    overflow-x: hidden;
    transition: background-color .3s ease,color .3s ease;
}

body.light-mode {
    background: linear-gradient(rgba(241,243,245,.92),rgba(241,243,245,.96)),
        url('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1600&q=80') center / cover fixed !important;
}

/* NAVBAR */
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
    letter-spacing: -.5px;
}

.logo span { color: var(--accent); }

.nav-links {
    display: flex;
    gap: 22px;
    align-items: center;
}

.nav-links > a:not(.profile-avatar) {
    text-decoration: none;
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 6px;
}

.nav-links > a:hover,
.nav-links > a.active { color: var(--accent); }

/* PROFILE ICON */
.nav-links > a.profile-avatar {
    width: 28px !important;
    height: 28px !important;
    min-width: 28px !important;
    min-height: 28px !important;
    max-width: 28px !important;
    max-height: 28px !important;
    flex: 0 0 28px !important;
    padding: 0 !important;
    margin: 0;
    box-sizing: border-box !important;
    flex-shrink: 0 !important;
    border-radius: 50%;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    display: inline-flex !important;
    align-items: center;
    justify-content: center;
    font-size: 12px !important;
    line-height: 1 !important;
    text-decoration: none;
    transition: transform .2s ease,border-color .2s ease;
}

.nav-links > a.profile-avatar:hover {
    transform: scale(1.04);
    border-color: var(--accent);
}

/* CART BADGE */
.cart-nav-link { position: relative; }

.cart-count-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 18px;
    height: 18px;
    padding: 0 5px;
    border-radius: 999px;
    background: var(--accent);
    color: #fff;
    font-size: 10px;
    font-weight: 800;
    line-height: 1;
}

.cart-count-badge[hidden] { display: none !important; }

/* THEME CONTROLS — MATCH HOME PAGE */
.controls-box {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 0;
    margin-left: 2px;
    background: transparent;
    border: none;
    border-radius: 0;
    box-shadow: none;
    flex-shrink: 0;
}

.theme-mode-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 16px;
    height: 18px;
    padding: 0;
    margin: 0;
    border: 0;
    border-radius: 0;
    background: transparent;
    box-shadow: none;
    color: var(--text-muted);
    font-size: 13px;
    line-height: 1;
    cursor: pointer;
    transition: color .18s ease;
}

.theme-mode-btn:hover,
.theme-mode-btn.active {
    color: var(--accent);
}

.theme-mode-btn:focus-visible,
.brightness-slider:focus-visible {
    outline: 2px solid var(--accent);
    outline-offset: 3px;
}

.brightness-slider {
    position: relative;
    display: block;
    flex: 0 0 54px;
    width: 54px;
    height: 12px;
    margin: 0;
    padding: 0;
    border: 0;
    background: transparent;
    box-shadow: none;
    cursor: ew-resize;
    touch-action: none;
    user-select: none;
    -webkit-user-select: none;
    outline-offset: 3px;
}

.brightness-track,
.brightness-fill {
    position: absolute;
    top: 50%;
    left: 0;
    height: 1px;
    border-radius: 0;
    transform: translateY(-50%);
    pointer-events: none;
}

.brightness-track {
    width: 100%;
    background: var(--text-muted);
    opacity: .7;
}

.brightness-fill {
    width: 50%;
    background: var(--accent);
}

.brightness-thumb {
    position: absolute;
    top: 50%;
    left: 50%;
    width: 7px;
    height: 7px;
    border: 0;
    border-radius: 50%;
    background: var(--accent);
    box-shadow: none;
    transform: translate(-50%,-50%);
    pointer-events: none;
}

/* PAGE CONTAINER */
.page-container {
    max-width: 1320px;
    margin: 40px auto 70px;
    padding: 0 24px;
}

.page-title { margin-bottom: 28px; }

.page-title h1 {
    font-size: 28px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -.5px;
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
    grid-template-columns: minmax(0,1fr) 380px;
    gap: 24px;
    align-items: start;
}

.cart-items {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    padding: 20px;
    box-shadow: var(--shadow);
    min-width: 0;
}

.cart-item {
    display: grid;
    grid-template-columns: 110px minmax(0,1fr) auto;
    gap: 20px;
    align-items: center;
    padding: 16px 0;
    border-bottom: 1px solid var(--panel-border);
}

.cart-item:last-child { border-bottom: none; }

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
    margin: 0 0 6px;
}

.description {
    color: var(--text-bottom-sub);
    font-size: 12px;
    line-height: 1.4;
    margin: 0 0 10px;
}

.item-price {
    color: #24963f !important;
    font-weight: 800;
    font-size: 15px !important;
    margin: 0 0 8px;
}

/* QUANTITY */
.quantity-box {
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
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

.quantity-btn:hover { background: rgba(0,0,0,.15); }

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

.remove-btn:hover { color: var(--accent); }

.remove-btn:disabled,
.quantity-btn:disabled {
    opacity: .6;
    cursor: wait;
}

/* ITEM TOTAL */
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
    letter-spacing: .5px;
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
    transition: background .2s ease;
}

.primary-btn:hover { background: #d12e3b; }

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
    margin: 0 0 16px;
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

.continue-shopping:hover { color: var(--accent); }

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
@media (max-width:1000px) {
    .nav-container {
        flex-wrap: wrap;
        gap: 14px;
    }

    .nav-links {
        gap: 14px;
        flex-wrap: wrap;
    }

    .cart-wrapper {
        grid-template-columns: minmax(0,1fr);
    }

    .summary { position: static; }
}

@media (max-width:600px) {
    .nav-container { padding: 12px 16px; }
    .logo { font-size: 23px; }
    .nav-links { gap: 12px; }

    .nav-links > a:not(.profile-avatar) {
        font-size: 12px;
    }

    .nav-links > a.profile-avatar {
        width: 28px !important;
        height: 28px !important;
        min-width: 28px !important;
        min-height: 28px !important;
        max-width: 28px !important;
        max-height: 28px !important;
        flex: 0 0 28px !important;
        font-size: 12px !important;
    }

    .controls-box { gap: 8px; }
    .brightness-slider { width: 54px; min-width: 54px; }

    .page-container {
        margin-top: 28px;
        padding: 0 14px;
    }

    .page-title h1 { font-size: 24px; }
    .cart-items { padding: 12px; }

    .cart-item {
        grid-template-columns: 80px minmax(0,1fr);
        gap: 12px;
    }

    .food-image {
        width: 80px;
        height: 70px;
    }

    .item-total {
        grid-column: 2;
        text-align: left;
        margin-top: 0;
    }

    .quantity-box { gap: 8px; }
    .remove-btn { margin-left: 0; }
}
</style>
</head>

<body>

<header class="navbar">
    <div class="nav-container">
        <a href="home.jsp" class="logo">Smart<span>Bite</span></a>

        <nav class="nav-links">
            <a href="home.jsp">Home</a>
            <a href="restaurants">Restaurants</a>
            <a href="orders.jsp" title="Orders">Orders</a>

            <a href="cart.jsp" class="active cart-nav-link" title="Cart">
                🛒 Cart
                <span id="fta-cart-badge"
                      class="cart-count-badge"
                      <%= cartCount == 0 ? "hidden" : "" %>><%= cartCount > 0 ? cartCount : "" %></span>
            </a>

            <a href="profile.jsp" class="profile-avatar"
               title="Profile" aria-label="Profile">👤</a>

            <div class="controls-box" aria-label="Theme and brightness controls">
                <button type="button" class="theme-mode-btn" id="lightModeBtn"
                        onclick="setThemeMode('light')" title="Light Mode"
                        aria-label="Switch to Light Mode" aria-pressed="false">☀</button>

                <div class="brightness-slider" id="brightnessSlider"
                     role="slider" tabindex="0"
                     aria-label="Adjust screen brightness"
                     aria-valuemin="0.5" aria-valuemax="1.5"
                     aria-valuenow="1" title="Drag to adjust brightness">
                    <span class="brightness-track" aria-hidden="true"></span>
                    <span class="brightness-fill" id="brightnessFill" aria-hidden="true"></span>
                    <span class="brightness-thumb" id="brightnessThumb" aria-hidden="true"></span>
                </div>

                <button type="button" class="theme-mode-btn" id="darkModeBtn"
                        onclick="setThemeMode('dark')" title="Dark Mode"
                        aria-label="Switch to Dark Mode" aria-pressed="true">☾</button>
            </div>
        </nav>
    </div>
</header>

<main class="page-container" id="smartbite-page-content">
    <div class="page-title">
        <h1>Your Cart</h1>
        <p>Review your selected food items before checkout</p>
    </div>

    <div class="cart-wrapper">
        <div class="cart-items">
            <%
            boolean hasDisplayableItems = false;

            for (CartItem item : cart) {
                if (item.getMenu() == null) continue;

                hasDisplayableItems = true;

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
                <img src="<%= imagePath %>"
                     alt="<%= item.getMenu().getName() %>"
                     class="food-image"
                     onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=500&q=80';">

                <div class="item-info">
                    <h3><%= item.getMenu().getName() %></h3>
                    <p class="description"><%= description %></p>
                    <p class="item-price">Price: &#8377;<%= String.format("%.2f", item.getMenu().getPrice()) %></p>

                    <div class="quantity-box">
                        <span class="quantity-label">Quantity:</span>

                        <div class="quantity-control">
                            <button type="button" class="quantity-btn"
                                    onclick="changeQuantity(<%= item.getMenu().getMenuId() %>,'decrease')"
                                    aria-label="Decrease quantity">&#8722;</button>

                            <span class="quantity-number"
                                  id="quantity-<%= item.getMenu().getMenuId() %>"><%= item.getQuantity() %></span>

                            <button type="button" class="quantity-btn"
                                    onclick="changeQuantity(<%= item.getMenu().getMenuId() %>,'increase')"
                                    aria-label="Increase quantity">+</button>
                        </div>

                        <button type="button" class="remove-btn"
                                onclick="removeItem(<%= item.getMenu().getMenuId() %>)">Remove</button>
                    </div>
                </div>

                <div class="item-total">
                    <span class="total-label">TOTAL</span>
                    <span class="total-price">&#8377;<%= String.format("%.2f", item.getItemTotal()) %></span>
                </div>
            </div>

            <% } if (!hasDisplayableItems) { %>

            <div class="empty-cart">
                <h2>Your cart is empty</h2>
                <p>Add some delicious food to your cart and come back here.</p>
                <a href="restaurants" class="primary-btn">Browse Restaurants</a>
            </div>

            <% } %>
        </div>

        <% if (hasDisplayableItems) {
            float deliveryFee = 40;
            float platformFee = 20;
            float finalTotal = grandTotal + deliveryFee + platformFee;
        %>

        <div class="summary">
            <h2>Order Summary</h2>

            <div class="summary-row">
                <span>Items</span><span><%= cartCount %></span>
            </div>

            <div class="summary-row">
                <span>Subtotal</span>
                <span>&#8377;<%= String.format("%.2f", grandTotal) %></span>
            </div>

            <div class="summary-row">
                <span>Delivery Fee</span><span>&#8377;40.00</span>
            </div>

            <div class="summary-row">
                <span>Platform Fee</span><span>&#8377;20.00</span>
            </div>

            <div class="summary-divider"></div>

            <div class="grand-total">
                <span>Total</span>
                <span>&#8377;<%= String.format("%.2f", finalTotal) %></span>
            </div>

            <a href="checkout.jsp" class="primary-btn checkout-btn">Proceed to Checkout</a>
            <a href="restaurants" class="continue-shopping">&#8592; Continue Shopping</a>
        </div>

        <% } %>
    </div>
</main>

<script>
/* CART BADGE */
(function () {
    "use strict";

    const CART_COUNT_KEY = "smartBit_cart_Count";
    const serverCartCount = <%= cartCount %>;
    const badge = document.getElementById("fta-cart-badge");

    function updateCartBadge(count) {
        const safeCount = Math.max(0, parseInt(count, 10) || 0);

        if (badge) {
            badge.textContent = safeCount > 0 ? String(safeCount) : "";
            badge.hidden = safeCount === 0;
        }

        try {
            localStorage.setItem(CART_COUNT_KEY, String(safeCount));
        } catch (error) {}
    }

    updateCartBadge(serverCartCount);
    window.updateCartBadge = updateCartBadge;

    window.addEventListener("storage", function (event) {
        if (event.key === CART_COUNT_KEY && event.newValue !== null && badge) {
            const count = Math.max(0, parseInt(event.newValue, 10) || 0);
            badge.textContent = count > 0 ? String(count) : "";
            badge.hidden = count === 0;
        }
    });
})();

/* CART ACTIONS */
function setCartButtonsDisabled(disabled) {
    document.querySelectorAll(".quantity-btn,.remove-btn").forEach(function (button) {
        button.disabled = disabled;
    });
}

function performCartAction(url) {
    setCartButtonsDisabled(true);

    fetch(url, {
        method: "GET",
        credentials: "same-origin",
        cache: "no-store"
    })
    .then(function (response) {
        if (!response.ok) {
            throw new Error("Cart update failed. HTTP " + response.status);
        }
        return response.text();
    })
    .then(function () {
        window.location.reload();
    })
    .catch(function (error) {
        console.error(error);
        window.location.reload();
    });
}

function changeQuantity(menuId, action) {
    performCartAction(
        "cart?action=" + encodeURIComponent(action) +
        "&menuId=" + encodeURIComponent(menuId)
    );
}

function removeItem(menuId) {
    performCartAction(
        "cart?action=remove&menuId=" + encodeURIComponent(menuId)
    );
}

/* THEME AND BRIGHTNESS — HOME PAGE BEHAVIOR */
(function () {
    "use strict";

    const THEME_KEY = "smartbite_theme";
    const BRIGHTNESS_KEY = "smartbite_brightness";

    const MIN_BRIGHTNESS = 0.5;
    const MAX_BRIGHTNESS = 1.5;
    const DEFAULT_BRIGHTNESS = 1;

    const slider = document.getElementById("brightnessSlider");
    const fill = document.getElementById("brightnessFill");
    const thumb = document.getElementById("brightnessThumb");
    const lightButton = document.getElementById("lightModeBtn");
    const darkButton = document.getElementById("darkModeBtn");
    const content = document.getElementById("smartbite-page-content");

    let brightness = DEFAULT_BRIGHTNESS;
    let dragging = false;
    let activePointerId = null;

    function readSetting(key) {
        try {
            return localStorage.getItem(key);
        } catch (error) {
            return null;
        }
    }

    function saveSetting(key, value) {
        try {
            localStorage.setItem(key, value);
        } catch (error) {}
    }

    function clampBrightness(value) {
        const number = Number.parseFloat(value);

        if (!Number.isFinite(number)) return DEFAULT_BRIGHTNESS;

        return Math.max(MIN_BRIGHTNESS, Math.min(MAX_BRIGHTNESS, number));
    }

    function updateThemeButtonUI() {
        const isLight = document.body.classList.contains("light-mode");

        if (lightButton) {
            lightButton.classList.toggle("active", isLight);
            lightButton.setAttribute("aria-pressed", String(isLight));
        }

        if (darkButton) {
            darkButton.classList.toggle("active", !isLight);
            darkButton.setAttribute("aria-pressed", String(!isLight));
        }
    }

    function setThemeMode(mode, shouldSave) {
        const isLight = mode === "light";

        document.body.classList.toggle("light-mode", isLight);
        document.documentElement.style.colorScheme = isLight ? "light" : "dark";

        if (shouldSave !== false) {
            saveSetting(THEME_KEY, isLight ? "light" : "dark");
        }

        updateThemeButtonUI();
    }

    window.setThemeMode = function (mode) {
        setThemeMode(mode, true);
    };

    window.toggleTheme = function () {
        const isLight = document.body.classList.contains("light-mode");
        setThemeMode(isLight ? "dark" : "light", true);
    };

    function updateSliderUI() {
        const percent = ((brightness - MIN_BRIGHTNESS) /
            (MAX_BRIGHTNESS - MIN_BRIGHTNESS)) * 100;

        if (fill) fill.style.width = percent + "%";
        if (thumb) thumb.style.left = percent + "%";

        if (slider) {
            slider.setAttribute("aria-valuenow", brightness.toFixed(2));
        }
    }

    function adjustBrightness(value, shouldSave) {
        brightness = clampBrightness(value);

        /*
         * Brightness affects the cart content only, leaving the navbar
         * and its controls fully visible and usable.
         */
        if (content) {
            content.style.filter = "brightness(" + brightness + ")";
        }

        updateSliderUI();

        if (shouldSave !== false) {
            saveSetting(BRIGHTNESS_KEY, String(brightness));
        }
    }

    window.adjustBrightness = function (value) {
        adjustBrightness(value, true);
    };

    function setBrightnessFromPointer(event) {
        const rect = slider.getBoundingClientRect();

        if (!rect.width) return;

        const percentage = Math.max(
            0,
            Math.min(1, (event.clientX - rect.left) / rect.width)
        );

        adjustBrightness(
            MIN_BRIGHTNESS + percentage * (MAX_BRIGHTNESS - MIN_BRIGHTNESS),
            true
        );
    }

    if (slider) {
        slider.addEventListener("pointerdown", function (event) {
            if (event.button !== undefined && event.button !== 0) return;

            dragging = true;
            activePointerId = event.pointerId;

            try {
                slider.setPointerCapture(event.pointerId);
            } catch (error) {}

            setBrightnessFromPointer(event);
            event.preventDefault();
        });

        window.addEventListener("pointermove", function (event) {
            if (
                dragging &&
                (activePointerId === null || event.pointerId === activePointerId)
            ) {
                setBrightnessFromPointer(event);
            }
        });

        function stopDragging(event) {
            if (
                activePointerId !== null &&
                event &&
                event.pointerId !== undefined &&
                event.pointerId !== activePointerId
            ) {
                return;
            }

            dragging = false;
            activePointerId = null;
        }

        window.addEventListener("pointerup", stopDragging);
        window.addEventListener("pointercancel", stopDragging);

        slider.addEventListener("keydown", function (event) {
            let next = brightness;

            switch (event.key) {
                case "ArrowLeft":
                case "ArrowDown":
                    next -= 0.05;
                    break;
                case "ArrowRight":
                case "ArrowUp":
                    next += 0.05;
                    break;
                case "Home":
                    next = MIN_BRIGHTNESS;
                    break;
                case "End":
                    next = MAX_BRIGHTNESS;
                    break;
                default:
                    return;
            }

            event.preventDefault();
            adjustBrightness(next, true);
        });
    }

    /* Restore saved Home page settings. */
    const savedTheme = readSetting(THEME_KEY);
    const savedBrightness = readSetting(BRIGHTNESS_KEY);

    setThemeMode(savedTheme === "light" ? "light" : "dark", false);

    adjustBrightness(
        savedBrightness !== null ? savedBrightness : DEFAULT_BRIGHTNESS,
        false
    );

    /* Keep settings synchronized between open tabs. */
    window.addEventListener("storage", function (event) {
        if (event.key === THEME_KEY && event.newValue !== null) {
            setThemeMode(event.newValue === "light" ? "light" : "dark", false);
        }

        if (event.key === BRIGHTNESS_KEY) {
            adjustBrightness(
                event.newValue !== null ? event.newValue : DEFAULT_BRIGHTNESS,
                false
            );
        }
    });
})();
</script>

<%@ include file="ai-assistant.jsp" %>

<footer>
    <p>&copy; 2026 SmartBite Delivery Platform. All rights reserved.</p>
</footer>

</body>
</html>
