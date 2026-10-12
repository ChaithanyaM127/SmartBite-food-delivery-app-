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

@media(max-width:1200px){ .g-card{ width: calc(33.333% - 8px); } }
@media(max-width:900px){ .g-card{ width: calc(50% - 6px); } }
@media(max-width:700px){ .g-card{ width: 100%; } }
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

<div class="container">

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

    <!-- TOP DEEP BLACK SECTION -->
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

    <!-- BOTTOM ADAPTIVE SECTION -->
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

</div>

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
var FTCART_INFO = {};
<%
if (!menuList.isEmpty()) {
    for (Menu menu : menuList) {
        String n = menu.getName() == null ? "" : menu.getName().replace("\\", "").replace("'", "").replace("\"", "");
        String im = menu.getImagePath() == null ? "" : menu.getImagePath().replace("'", "").replace("\"", "");
%>
FTCART_INFO[<%= menu.getMenuId() %>] = { name: "<%= n %>", price: <%= menu.getPrice() %>, img: "<%= im %>" };
<%
    }
}
%>

function updateBadgeCount(count) {
    var b = document.getElementById('fta-cart-badge');
    if (b) {
        b.textContent = count;
        localStorage.setItem("foodtap_cart_count", count);
        localStorage.setItem("smartbite_cart_count", count);
    }
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

            // 1. Yes, continue adding items from different restaurants
            newYesBtn.addEventListener("click", function() {
                modal.style.display = "none";
                addToCart(menuId, 'continue');
            });

            // 2. No, cancel this item which I am adding now
            newCancelNewBtn.addEventListener("click", function() {
                modal.style.display = "none";
                addToCart(menuId, 'cancelNew');
            });

            // 3. No, cancel the previous item which I have added to the cart
            newCancelPrevBtn.addEventListener("click", function() {
                modal.style.display = "none";
                addToCart(menuId, 'cancelPrev');
            });
        } else if (data.status === "cancelledNew") {
            // Do nothing, item not added
        } else {
            showQuantityControl(menuId, 1);
            if (typeof data.cartCount !== 'undefined') {
                updateBadgeCount(data.cartCount);
            }
        }
    })
    .catch(function(error) { console.error(error); });
}

function changeQuantity(menuId, action) {
    fetch('cart?action=' + action + '&menuId=' + menuId, { method: 'GET', credentials: 'same-origin' })
    .then(function(response) {
        var contentType = response.headers.get("content-type");
        if (contentType && contentType.includes("application/json")) {
            return response.json();
        }
        return { status: "success", cartCount: 0 };
    })
    .then(function(data) {
        var q = document.getElementById('quantity-' + menuId);
        if (q) {
            var n = parseInt(q.textContent.trim(), 10);
            if (action === 'increase') {
                n++;
                q.textContent = n;
            } else {
                n--;
                if (n <= 0) {
                    showAddButton(menuId);
                } else {
                    q.textContent = n;
                }
            }
        }
        if (typeof data.cartCount !== 'undefined') {
            updateBadgeCount(data.cartCount);
        }
    })
    .catch(function(error) { console.error(error); });
}

function showQuantityControl(menuId, quantity) {
    var c = document.getElementById('cart-control-' + menuId);
    c.innerHTML = '<div class="quantity-control">'
        + '<button type="button" onclick="changeQuantity(' + menuId + ', \'decrease\')">&#8722;</button>'
        + '<span class="quantity-number" id="quantity-' + menuId + '">' + quantity + '</span>'
        + '<button type="button" onclick="changeQuantity(' + menuId + ', \'increase\')">+</button>'
        + '</div>';
}

function showAddButton(menuId) {
    var c = document.getElementById('cart-control-' + menuId);
    c.innerHTML = '<button type="button" class="add-button" onclick="addToCart(' + menuId + ')">Add to Cart</button>';
}

// Theme & Brightness Management
(function() {
    const savedTheme = localStorage.getItem("smartbite_theme");
    if (savedTheme === "light") {
        document.body.classList.add("light-mode");
    }
    updateThemeButtonUI();

    // Set initial badge count from server JSP render
    updateBadgeCount(<%= initialCartCount %>);
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