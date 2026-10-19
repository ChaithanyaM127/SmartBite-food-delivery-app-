<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.foodtap.model.Menu" %>
<%@ page import="com.foodtap.model.CartItem" %>
<%@ page import="com.foodtap.util.DBConnection" %>

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
<title>SmartBite | Menu</title>

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
    gap: 16px;
}

.logo {
    font-size: 26px;
    font-weight: 800;
    color: var(--text-main);
    text-decoration: none;
    letter-spacing: -0.5px;
    flex-shrink: 0;
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
    white-space: nowrap;
}

.nav-links a:hover,
.nav-links a.active {
    color: var(--accent);
}

/* Small profile avatar matching the other SmartBite pages */
.nav-links > a.profile-avatar {
    width: 28px;
    min-width: 28px;
    height: 28px;
    min-height: 28px;
    padding: 0;
    margin: 0;
    border-radius: 50%;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    color: var(--text-main);
    font-size: 14px;
    line-height: 1;
    text-decoration: none;
    flex-shrink: 0;
    transition: transform 0.2s ease, border-color 0.2s ease;
}

.nav-links > a.profile-avatar:hover {
    transform: scale(1.06);
    border-color: var(--accent);
}

/* Theme and brightness controls matching Cart and Orders */
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
    cursor: pointer;
    touch-action: none;
    user-select: none;
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
    transform: translate(-50%, -50%);
    pointer-events: none;
}

/* Main Layout */
.container {
    max-width: 1320px;
    margin: 30px auto;
    padding: 0 24px;
    width: 100%;
}

.back-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: var(--accent);
    text-decoration: none;
    font-size: 14px;
    font-weight: 800;
    margin-bottom: 16px;
    background: var(--metric-bg);
    padding: 8px 16px;
    border-radius: 8px;
    border: 1px solid var(--panel-border);
    transition: background 0.2s ease;
}

.back-link:hover {
    background: rgba(226, 55, 68, 0.1);
}

.heading {
    margin-bottom: 20px;
}

.heading h1 {
    font-size: 26px;
    font-weight: 800;
    letter-spacing: -0.5px;
    margin-bottom: 4px;
    color: var(--text-main);
}

.heading p {
    color: var(--text-muted);
    font-size: 14px;
}

/* TIGHT GRID SPACING */
.menu-grid {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
    margin: 0;
    padding: 0;
    gap: 12px;
}

.g-card {
    width: calc(25% - 9px);
    box-sizing: border-box;
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    overflow: hidden;
    background: var(--bg-card-dark);
    display: flex;
    flex-direction: column;
    transition: transform 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
    box-shadow: var(--shadow);
    margin-bottom: 12px;
}

.g-card:hover {
    border-color: var(--accent);
    transform: translateY(-3px);
}

/* PART 1: TOP DEEP BLACK SECTION */
.card-part-top-black {
    background: #0d0d0f !important;
    color: #ffffff !important;
    padding-bottom: 10px;
    position: relative;
}

.cimg {
    position: relative;
    height: 150px;
    width: 100%;
    background: #000000;
    overflow: hidden;
}

.cimg img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
    transition: transform .45s ease;
}

.g-card:hover .cimg img {
    transform: scale(1.06);
}

.item-title-row {
    margin: 10px 12px 0 12px;
}

.ci h2 {
    font-size: 16px;
    font-weight: 800;
    color: #ffffff !important;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    margin: 0;
}

/* PART 2: BOTTOM ADAPTIVE SECTION */
.ci {
    background: var(--bg-card-bottom) !important;
    color: var(--text-bottom-main) !important;
    padding: 10px 12px 12px 12px;
    display: flex;
    flex-direction: column;
    flex: 1;
    border-top: 1px solid var(--panel-border);
}

.description {
    color: var(--text-bottom-sub) !important;
    font-size: 12px;
    line-height: 1.35;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    margin-bottom: 10px;
}

.nutrition-box {
    margin-top: auto;
    margin-bottom: 10px;
    padding: 6px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    border-radius: 6px;
}

.nutrition-title {
    color: var(--accent);
    font-size: 10px;
    font-weight: 800;
    margin-bottom: 4px;
}

.nutrition-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 4px;
}

.nutrition-item {
    text-align: center;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 4px;
    padding: 3px 2px;
}

.nutrition-value {
    display: block;
    color: var(--text-main);
    font-size: 11px;
    font-weight: 800;
}

.nutrition-label {
    display: block;
    color: var(--text-bottom-sub);
    font-size: 8px;
}

.bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid var(--panel-border);
    padding-top: 8px;
    margin-top: auto;
    gap: 8px;
}

.price {
    color: #24963f !important;
    font-size: 15px;
    font-weight: 800;
}

.add-button {
    background: var(--accent) !important;
    color: #fff;
    border: none;
    padding: 6px 12px;
    border-radius: 6px;
    cursor: pointer;
    font-weight: 800;
    font-size: 12px;
    transition: background 0.2s ease;
    display: inline-flex;
    align-items: center;
    justify-content: center;
}

.add-button:hover {
    background: #d12e3b !important;
}

.quantity-control {
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--accent);
    border-radius: 6px;
    overflow: hidden;
}

.quantity-control button {
    width: 26px;
    height: 28px;
    border: none;
    background: transparent;
    color: #fff;
    font-size: 15px;
    font-weight: 800;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
}

.quantity-control button:hover {
    background: rgba(0, 0, 0, 0.15);
}

.quantity-number {
    width: 26px;
    height: 28px;
    color: #fff;
    font-size: 12px;
    font-weight: 800;
    display: flex;
    align-items: center;
    justify-content: center;
}

.empty {
    grid-column: 1/-1;
    text-align: center;
    background: var(--bg-card-dark);
    padding: 50px;
    border-radius: 16px;
    border: 1px solid var(--panel-border);
    box-shadow: var(--shadow);
}

.empty h2 {
    font-size: 22px;
    font-weight: 800;
    margin-bottom: 10px;
    color: var(--text-main);
}

.empty p {
    color: var(--text-muted);
    font-size: 14px;
}

/* CENTERED CUSTOM MODAL POPUP STYLES WITH 3 BUTTONS */
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.75);
    backdrop-filter: blur(5px);
    display: none;
    align-items: center;
    justify-content: center;
    z-index: 9999;
}

.modal-box {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 14px;
    padding: 30px;
    max-width: 440px;
    width: 90%;
    text-align: center;
    box-shadow: var(--shadow);
    animation: modalScaleIn 0.25s ease;
}

@keyframes modalScaleIn {
    from { transform: scale(0.9); opacity: 0; }
    to { transform: scale(1); opacity: 1; }
}

.modal-title {
    font-size: 18px;
    font-weight: 800;
    color: var(--text-main);
    margin-bottom: 12px;
}

.modal-desc {
    font-size: 13px;
    color: var(--text-muted);
    line-height: 1.5;
    margin-bottom: 24px;
    font-weight: 600;
}

.modal-actions {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.modal-btn {
    width: 100%;
    padding: 12px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 800;
    cursor: pointer;
    border: none;
    transition: background 0.2s ease, transform 0.1s ease;
}

.modal-btn:active {
    transform: scale(0.98);
}

.modal-btn-yes {
    background: #24963f;
    color: #fff;
}

.modal-btn-yes:hover {
    background: #1e7e34;
}

.modal-btn-cancel-new {
    background: var(--accent);
    color: #fff;
}

.modal-btn-cancel-new:hover {
    background: #d12e3b;
}

.modal-btn-cancel-prev {
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    color: var(--text-main);
}

.modal-btn-cancel-prev:hover {
    border-color: var(--accent);
}

footer {
    background: var(--bg-card-dark);
    border-top: 1px solid var(--panel-border);
    color: var(--text-muted);
    text-align: center;
    padding: 20px 24px;
    margin-top: 50px;
    font-size: 12px;
}

@media(max-width:1200px) {
    .g-card { width: calc(33.333% - 8px); }
}

@media(max-width:900px) {
    .g-card { width: calc(50% - 6px); }

    .nav-container {
        padding: 12px 18px;
        flex-wrap: wrap;
    }

    .nav-links {
        gap: 14px;
        flex-wrap: wrap;
        justify-content: flex-end;
    }
}

@media(max-width:700px) {
    .g-card { width: 100%; }

    .nav-container {
        padding: 12px 14px;
    }

    .logo {
        font-size: 23px;
    }

    .nav-links {
        width: 100%;
        justify-content: flex-start;
        gap: 14px;
    }

    .nav-links a {
        font-size: 12px;
    }

    .container {
        padding: 0 14px;
        margin-top: 22px;
    }

    .heading h1 {
        font-size: 23px;
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
                <a href="cart.jsp" title="Cart">🛒 Cart <span id="fta-cart-badge" style="display:none; background:#e23744; color:#fff; font-size:10px; font-weight:800; padding:2px 6px; border-radius:10px; margin-left:4px;">0</span></a>
                <a href="profile.jsp" class="profile-avatar" title="Profile" aria-label="Profile">👤</a>

                <div class="controls-box" aria-label="Theme and brightness controls">
                    <button type="button" class="theme-mode-btn" id="lightModeBtn"
                            onclick="setThemeMode('light')" title="Light Mode"
                            aria-label="Switch to Light Mode" aria-pressed="false">☀</button>

                    <div class="brightness-slider" id="brightnessSlider"
                         role="slider" tabindex="0" aria-label="Adjust screen brightness"
                         aria-valuemin="0.5" aria-valuemax="1.5" aria-valuenow="1"
                         title="Drag to adjust brightness">
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

<main class="container" id="smartbite-page-content">

    <div class="heading">
        <a href="restaurants" class="back-link">← Back to Restaurants</a>
        <h1>Delicious Menu</h1>
        <p>Choose your favourite food and enjoy your meal.</p>
    </div>

    <div class="menu-grid">

<%
List<Menu> menuList = new ArrayList<>();

Object menuObject = request.getAttribute("menuList");

if (menuObject instanceof List<?>) {
    for (Object obj : (List<?>) menuObject) {
        if (obj instanceof Menu) menuList.add((Menu) obj);
    }
}

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

if (!menuList.isEmpty()) {

    for (Menu menu : menuList) {

        String foodName = menu.getName();
        if (foodName == null) foodName = "";

        String foodNameLower = foodName.toLowerCase();

        String foodImage = menu.getImagePath();

        if (foodImage == null || foodImage.trim().isEmpty()) {
            if (foodNameLower.contains("chicken biryani")) {
                foodImage = "https://images.unsplash.com/photo-1563379091339-03246963d96c?auto=format&fit=crop&w=900&q=90";
            } else if (foodNameLower.contains("egg biryani")) {
                foodImage = "https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=900&q=90";
            } else if (foodNameLower.contains("tandoori")) {
                foodImage = "https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=900&q=90";
            } else if (foodNameLower.contains("seekh") || foodNameLower.contains("kebab") || foodNameLower.contains("kababs")) {
                foodImage = "https://images.unsplash.com/photo-1628294895950-9805252327bc?auto=format&fit=crop&w=900&q=90";
            } else if (foodNameLower.contains("biryani")) {
                foodImage = "https://images.unsplash.com/photo-1631515242808-497c3fbd3972?auto=format&fit=crop&w=900&q=90";
            } else {
                foodImage = "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=90";
            }
        }

        String description = menu.getDescription();
        if (description == null || description.trim().isEmpty()) {
            description = "Delicious " + foodName + " prepared fresh for you.";
        }

        float protein = 0;
        float carbs = 0;
        float calories = 0;
        float fiber = 0;

        String nutritionSql =
            "SELECT protein, carbs, calories, fiber " +
            "FROM foodnutrition " +
            "WHERE menuId = ? " +
            "LIMIT 1";

        try (
            Connection nutritionConnection = DBConnection.getConnection();
            PreparedStatement nutritionStatement =
                nutritionConnection.prepareStatement(nutritionSql)
        ) {
            nutritionStatement.setInt(1, menu.getMenuId());
            try (ResultSet nutritionResult = nutritionStatement.executeQuery()) {
                if (nutritionResult.next()) {
                    protein = nutritionResult.getFloat("protein");
                    carbs = nutritionResult.getFloat("carbs");
                    calories = nutritionResult.getFloat("calories");
                    fiber = nutritionResult.getFloat("fiber");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        int quantity = 0;
        for (CartItem item : cartList) {
            if (item.getMenu() != null && item.getMenu().getMenuId() == menu.getMenuId()) {
                quantity = item.getQuantity();
                break;
            }
        }
%>

        <div class="g-card">

            <div class="card-part-top-black">
                <div class="cimg">
                    <img src="<%= foodImage %>" alt="<%= foodName %>"
                         onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=90';">
                </div>

                <div class="item-title-row">
                    <div class="ci" style="padding:0; background:transparent !important; border:none;">
                        <h2><%= foodName %></h2>
                    </div>
                </div>
            </div>

            <div class="ci">
                <p class="description"><%= description %></p>

                <div class="nutrition-box">
                    <div class="nutrition-title">Nutrition</div>
                    <div class="nutrition-grid">
                        <div class="nutrition-item">
                            <span class="nutrition-value"><%= String.format("%.1f", protein) %> g</span>
                            <span class="nutrition-label">Protein</span>
                        </div>
                        <div class="nutrition-item">
                            <span class="nutrition-value"><%= String.format("%.1f", carbs) %> g</span>
                            <span class="nutrition-label">Carbs</span>
                        </div>
                        <div class="nutrition-item">
                            <span class="nutrition-value"><%= String.format("%.1f", calories) %> kcal</span>
                            <span class="nutrition-label">Calories</span>
                        </div>
                        <div class="nutrition-item">
                            <span class="nutrition-value"><%= String.format("%.1f", fiber) %> g</span>
                            <span class="nutrition-label">Fiber</span>
                        </div>
                    </div>
                </div>

                <div class="bottom">
                    <span class="price">&#8377;<%= menu.getPrice() %></span>

                    <div class="cart-control" id="cart-control-<%= menu.getMenuId() %>">
                    <% if (quantity > 0) { %>
                        <div class="quantity-control">
                            <button type="button" onclick="changeQuantity(<%= menu.getMenuId() %>, 'decrease')">&#8722;</button>
                            <span class="quantity-number" id="quantity-<%= menu.getMenuId() %>"><%= quantity %></span>
                            <button type="button" onclick="changeQuantity(<%= menu.getMenuId() %>, 'increase')">+</button>
                        </div>
                    <% } else { %>
                        <button type="button" class="add-button" onclick="addToCart(<%= menu.getMenuId() %>)">Add to Cart</button>
                    <% } %>
                    </div>
                </div>
            </div>
        </div>

<%
    }

} else {
%>

        <div class="empty">
            <h2>No food available</h2>
            <p>This restaurant doesn't have menu items yet.</p>
        </div>

<%
}
%>

    </div>
</main>

<!-- CENTERED MULTI-RESTAURANT CONFIRMATION MODAL WITH 3 OPTIONS -->
<div class="modal-overlay" id="restaurantMismatchModal">
    <div class="modal-box">
        <div class="modal-title">Items From Another Restaurant</div>
        <div class="modal-desc">You are ordering food from a different restaurant. Your cart already contains items from another restaurant. How would you like to proceed?</div>
        <div class="modal-actions">
            <button type="button" class="modal-btn modal-btn-yes" id="modalYesBtn">Yes, continue adding items from different restaurants</button>
            <button type="button" class="modal-btn modal-btn-cancel-new" id="modalCancelNewBtn">No, cancel this item which I am adding now</button>
            <button type="button" class="modal-btn modal-btn-cancel-prev" id="modalCancelPrevBtn">No, cancel the previous item which I have added to the cart</button>
        </div>
    </div>
</div>

<script>
/* Cart information */
var FTCART_INFO = {};
<%
if (!menuList.isEmpty()) {
    for (Menu menu : menuList) {
        String n = menu.getName() == null ? "" : menu.getName().replace("\\", "").replace("'", "").replace("\"", "");
        String im = menu.getImagePath() == null ? "" : menu.getImagePath().replace("'", "").replace("\"", "");
%>
FTCart_INFO[<%= menu.getMenuId() %>] = { name: "<%= n %>", price: <%= menu.getPrice() %>, img: "<%= im %>" };
<%
    }
}
%>

function updateBadgeCount(count) {
    var badge = document.getElementById('fta-cart-badge');
    count = Math.max(0, parseInt(count, 10) || 0);

    if (badge) {
        badge.textContent = count;
        badge.style.display = count > 0 ? 'inline-block' : 'none';
    }

    localStorage.setItem("foodtap_cart_count", count);
    localStorage.setItem("smartbite_cart_count", count);
}

function addToCart(menuId, mode = '') {
    var url = 'cart?menuId=' + menuId;

    if (mode) {
        url += '&mode=' + mode;
    }

    fetch(url, { method: 'GET', credentials: 'same-origin' })
    .then(function(response) {
        var contentType = response.headers.get("content-type");

        if (contentType && contentType.includes("application/json")) {
            return response.json();
        }

        return { status: "success", cartCount: 0 };
    })
    .then(function(data) {
        if (data.status === "restaurantMismatch") {
            var modal = document.getElementById("restaurantMismatchModal");
            modal.style.display = "flex";

            var yesBtn = document.getElementById("modalYesBtn");
            var cancelNewBtn = document.getElementById("modalCancelNewBtn");
            var cancelPrevBtn = document.getElementById("modalCancelPrevBtn");

            var newYesBtn = yesBtn.cloneNode(true);
            var newCancelNewBtn = cancelNewBtn.cloneNode(true);
            var newCancelPrevBtn = cancelPrevBtn.cloneNode(true);

            yesBtn.parentNode.replaceChild(newYesBtn, yesBtn);
            cancelNewBtn.parentNode.replaceChild(newCancelNewBtn, cancelNewBtn);
            cancelPrevBtn.parentNode.replaceChild(newCancelPrevBtn, cancelPrevBtn);

            newYesBtn.addEventListener("click", function() {
                modal.style.display = "none";
                addToCart(menuId, 'continue');
            });

            newCancelNewBtn.addEventListener("click", function() {
                modal.style.display = "none";
                addToCart(menuId, 'cancelNew');
            });

            newCancelPrevBtn.addEventListener("click", function() {
                modal.style.display = "none";
                addToCart(menuId, 'cancelPrev');
            });

        } else if (data.status === "cancelledNew") {
            // Item was cancelled and was not added.
        } else {
            showQuantityControl(menuId, 1);

            if (typeof data.cartCount !== 'undefined') {
                updateBadgeCount(data.cartCount);
            }
        }
    })
    .catch(function(error) {
        console.error(error);
    });
}

function changeQuantity(menuId, action) {
    fetch('cart?action=' + action + '&menuId=' + menuId, {
        method: 'GET',
        credentials: 'same-origin'
    })
    .then(function(response) {
        var contentType = response.headers.get("content-type");

        if (contentType && contentType.includes("application/json")) {
            return response.json();
        }

        return { status: "success", cartCount: 0 };
    })
    .then(function(data) {
        var quantityElement = document.getElementById('quantity-' + menuId);

        if (quantityElement) {
            var quantity = parseInt(quantityElement.textContent.trim(), 10);

            if (action === 'increase') {
                quantity++;
                quantityElement.textContent = quantity;
            } else {
                quantity--;

                if (quantity <= 0) {
                    showAddButton(menuId);
                } else {
                    quantityElement.textContent = quantity;
                }
            }
        }

        if (typeof data.cartCount !== 'undefined') {
            updateBadgeCount(data.cartCount);
        }
    })
    .catch(function(error) {
        console.error(error);
    });
}

function showQuantityControl(menuId, quantity) {
    var control = document.getElementById('cart-control-' + menuId);

    if (!control) return;

    control.innerHTML =
        '<div class="quantity-control">' +
            '<button type="button" onclick="changeQuantity(' + menuId + ', \'decrease\')">&#8722;</button>' +
            '<span class="quantity-number" id="quantity-' + menuId + '">' + quantity + '</span>' +
            '<button type="button" onclick="changeQuantity(' + menuId + ', \'increase\')">+</button>' +
        '</div>';
}

function showAddButton(menuId) {
    var control = document.getElementById('cart-control-' + menuId);

    if (!control) return;

    control.innerHTML =
        '<button type="button" class="add-button" onclick="addToCart(' + menuId + ')">Add to Cart</button>';
}

/* Theme and brightness settings */
(function() {
    var savedTheme = localStorage.getItem("smartbite_theme");
    var savedBrightness = parseFloat(localStorage.getItem("smartbite_brightness"));

    if (savedTheme === "light") {
        document.body.classList.add("light-mode");
    } else {
        document.body.classList.remove("light-mode");
    }

    if (!Number.isFinite(savedBrightness)) {
        savedBrightness = 1;
    }

    savedBrightness = Math.max(0.5, Math.min(1.5, savedBrightness));

    applyBrightness(savedBrightness);
    updateThemeButtonUI();

    updateBadgeCount(<%= initialCartCount %>);
})();

function setThemeMode(mode) {
    var isLight = mode === "light";

    document.body.classList.toggle("light-mode", isLight);
    localStorage.setItem("smartbite_theme", isLight ? "light" : "dark");

    updateThemeButtonUI();
}

function toggleTheme() {
    var isLight = !document.body.classList.contains("light-mode");
    setThemeMode(isLight ? "light" : "dark");
}

function updateThemeButtonUI() {
    var isLight = document.body.classList.contains("light-mode");
    var lightButton = document.getElementById("lightModeBtn");
    var darkButton = document.getElementById("darkModeBtn");

    if (lightButton) {
        lightButton.classList.toggle("active", isLight);
        lightButton.setAttribute("aria-pressed", String(isLight));
    }

    if (darkButton) {
        darkButton.classList.toggle("active", !isLight);
        darkButton.setAttribute("aria-pressed", String(!isLight));
    }
}

function applyBrightness(value) {
    var brightness = Math.max(0.5, Math.min(1.5, Number(value) || 1));
    var content = document.getElementById("smartbite-page-content");
    var slider = document.getElementById("brightnessSlider");
    var fill = document.getElementById("brightnessFill");
    var thumb = document.getElementById("brightnessThumb");

    if (content) {
        content.style.filter = "brightness(" + brightness + ")";
    }

    var percentage = ((brightness - 0.5) / 1.0) * 100;

    if (fill) {
        fill.style.width = percentage + "%";
    }

    if (thumb) {
        thumb.style.left = percentage + "%";
    }

    if (slider) {
        slider.setAttribute("aria-valuenow", brightness.toFixed(2));
    }

    localStorage.setItem("smartbite_brightness", String(brightness));
}

function setBrightnessFromPointer(event) {
    var slider = document.getElementById("brightnessSlider");
    if (!slider) return;

    var rect = slider.getBoundingClientRect();
    if (rect.width <= 0) return;

    var percentage = (event.clientX - rect.left) / rect.width;
    percentage = Math.max(0, Math.min(1, percentage));

    var brightness = 0.5 + percentage;
    applyBrightness(brightness);
}

(function() {
    var slider = document.getElementById("brightnessSlider");
    if (!slider) return;

    var dragging = false;

    slider.addEventListener("pointerdown", function(event) {
        dragging = true;

        if (slider.setPointerCapture) {
            slider.setPointerCapture(event.pointerId);
        }

        setBrightnessFromPointer(event);
        event.preventDefault();
    });

    slider.addEventListener("pointermove", function(event) {
        if (dragging) {
            setBrightnessFromPointer(event);
        }
    });

    slider.addEventListener("pointerup", function() {
        dragging = false;
    });

    slider.addEventListener("pointercancel", function() {
        dragging = false;
    });

    slider.addEventListener("keydown", function(event) {
        var current = parseFloat(localStorage.getItem("smartbite_brightness")) || 1;
        var step = 0.05;

        if (event.key === "ArrowRight" || event.key === "ArrowUp") {
            current += step;
        } else if (event.key === "ArrowLeft" || event.key === "ArrowDown") {
            current -= step;
        } else if (event.key === "Home") {
            current = 0.5;
        } else if (event.key === "End") {
            current = 1.5;
        } else {
            return;
        }

        event.preventDefault();
        applyBrightness(current);
    });
})();

window.addEventListener("storage", function(event) {
    if (event.key === "smartbite_theme") {
        if (event.newValue === "light") {
            document.body.classList.add("light-mode");
        } else {
            document.body.classList.remove("light-mode");
        }

        updateThemeButtonUI();
    }

    if (event.key === "smartbite_brightness") {
        applyBrightness(parseFloat(event.newValue) || 1);
    }

    if (event.key === "smartbite_cart_count" || event.key === "foodtap_cart_count") {
        var count = parseInt(event.newValue, 10);
        updateBadgeCount(Number.isFinite(count) ? count : 0);
    }
});
</script>

<%@ include file="ai-assistant.jsp" %>

<footer>
    <p>&copy; 2026 SmartBite Delivery Platform. All rights reserved.</p>
</footer>

</body>
</html>
