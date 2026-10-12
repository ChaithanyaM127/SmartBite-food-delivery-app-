<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.foodtap.model.Menu" %>
<%@ page import="com.foodtap.model.FoodNutrition" %>
<%@ page import="com.foodtap.model.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Menu menu = (Menu) request.getAttribute("menu");
    FoodNutrition nutrition = (FoodNutrition) request.getAttribute("nutrition");

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
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= menu != null ? menu.getName() : "Food Details" %> | SmartBite</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&amp;display=swap" rel="stylesheet">

<style type="text/css">
:root {
    --bg-page: #0d0d0f;
    --bg-card-dark: #121318;
    --text-main: #ffffff;
    --text-muted: #a1a1aa;
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
    --text-main: #111827;
    --text-muted: #6b7280;
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

/* Container & Food Card Layout */
.container {
    width: 90%;
    max-width: 1100px;
    margin: 45px auto 80px;
}

.food-card {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 16px;
    overflow: hidden;
    box-shadow: var(--shadow);
}

.food-top {
    display: grid;
    grid-template-columns: 1fr 1fr;
}

.food-image-container {
    min-height: 420px;
    background: #000;
    overflow: hidden;
    position: relative;
}

.food-image {
    width: 100%;
    height: 420px;
    object-fit: cover;
    display: block;
    transition: transform 0.45s ease;
}

.food-image:hover {
    transform: scale(1.04);
}

.food-image-fallback {
    width: 100%;
    height: 420px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--metric-bg);
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
}

.food-info {
    padding: 45px;
    display: flex;
    flex-direction: column;
    justify-content: center;
}

.food-info h1 {
    font-size: clamp(26px, 3.5vw, 38px);
    line-height: 1.2;
    margin-bottom: 14px;
    color: var(--text-main);
    font-weight: 800;
    letter-spacing: -0.5px;
}

.description {
    color: var(--text-muted);
    line-height: 1.6;
    margin-bottom: 24px;
    font-size: 14px;
    font-weight: 600;
}

.price {
    font-size: 26px;
    font-weight: 900;
    color: #24963f;
    margin-bottom: 24px;
}

.add-button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background: var(--accent);
    color: white;
    padding: 12px 24px;
    border-radius: 8px;
    text-decoration: none;
    font-weight: 800;
    font-size: 14px;
    width: fit-content;
    border: none;
    cursor: pointer;
    transition: background 0.2s ease, transform 0.1s ease;
    box-shadow: 0 8px 20px rgba(226, 55, 68, 0.25);
}

.add-button:hover {
    background: #d12e3b;
    transform: translateY(-2px);
}

/* Nutrition Section */
.nutrition {
    padding: 35px;
    border-top: 1px solid var(--panel-border);
    background: rgba(0, 0, 0, 0.02);
}

.nutrition h2 {
    margin-bottom: 20px;
    font-size: 20px;
    color: var(--text-main);
    font-weight: 800;
    letter-spacing: -0.3px;
}

.nutrition-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
}

.nutrition-box {
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    border-radius: 12px;
    padding: 18px;
    text-align: center;
    transition: border-color 0.2s ease, transform 0.2s ease;
}

.nutrition-box:hover {
    border-color: var(--accent);
    transform: translateY(-3px);
}

.nutrition-box .value {
    display: block;
    font-size: 22px;
    font-weight: 800;
    margin-bottom: 6px;
    color: var(--text-main);
}

.nutrition-box .label {
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 600;
}

.no-nutrition {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
    padding: 10px 0;
}

.food-not-found {
    padding: 60px 30px;
    text-align: center;
}

.food-not-found h2 {
    color: var(--text-main);
    margin-bottom: 20px;
    font-size: 24px;
    font-weight: 800;
}

/* CENTERED MULTI-RESTAURANT CONFIRMATION MODAL WITH 3 OPTIONS */
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

.modal-btn:active { transform: scale(0.98); }
.modal-btn-yes { background: #24963f; color: #fff; }
.modal-btn-yes:hover { background: #1e7e34; }
.modal-btn-cancel-new { background: var(--accent); color: #fff; }
.modal-btn-cancel-new:hover { background: #d12e3b; }
.modal-btn-cancel-prev { background: var(--metric-bg); border: 1px solid var(--panel-border); color: var(--text-main); }
.modal-btn-cancel-prev:hover { border-color: var(--accent); }

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

@media(max-width: 850px) {
    .food-top { grid-template-columns: 1fr; }
    .food-image-container, .food-image, .food-image-fallback { min-height: 320px; height: 320px; }
    .nutrition-grid { grid-template-columns: repeat(2, 1fr); }
    .food-info { padding: 32px 24px; }
}
@media(max-width: 600px) {
    .container { width: 94%; margin: 25px auto 60px; }
    .food-info h1 { font-size: 26px; }
    .price { font-size: 24px; }
    .add-button { width: 100%; }
    .nutrition { padding: 25px 20px; }
}
</style>
</head>
<body>

<%@ include file="animated-bg.jsp" %>

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

<% if (menu != null) {
    String image = menu.getImagePath();
%>

<div class="food-card">
<div class="food-top">
    <div class="food-image-container">
    <% if (image != null && !image.trim().isEmpty()) { %>
        <img src="<%= image %>" class="food-image" alt="<%= menu.getName() %>" onerror="showImageFallback(this);">
        <div class="food-image-fallback" style="display:none;">Image unavailable</div>
    <% } else { %>
        <div class="food-image-fallback">Image unavailable</div>
    <% } %>
    </div>

    <div class="food-info">
        <h1><%= menu.getName() %></h1>
        <p class="description"><%= menu.getDescription() != null ? menu.getDescription() : "Delicious food prepared fresh for you." %></p>
        <div class="price">&#8377;<%= menu.getPrice() %></div>
        <button type="button" class="add-button" onclick="addToCart(<%= menu.getMenuId() %>)">Add to Cart</button>
    </div>
</div>

<div class="nutrition">
    <h2>Nutrition Information</h2>
    <% if (nutrition != null) { %>
    <div class="nutrition-grid">
        <div class="nutrition-box"><span class="value"><%= nutrition.getProtein() %>g</span><span class="label">Protein</span></div>
        <div class="nutrition-box"><span class="value"><%= nutrition.getCarbs() %>g</span><span class="label">Carbs</span></div>
        <div class="nutrition-box"><span class="value"><%= nutrition.getCalories() %></span><span class="label">Calories</span></div>
        <div class="nutrition-box"><span class="value"><%= nutrition.getFiber() %>g</span><span class="label">Fiber</span></div>
    </div>
    <% } else { %>
    <p class="no-nutrition">Nutrition information is not available for this food yet.</p>
    <% } %>
</div>
</div>

<% } else { %>

<div class="food-card food-not-found">
    <h2>Food item not found</h2>
    <a href="restaurants" class="add-button" style="text-decoration:none;">Back to Restaurants</a>
</div>

<% } %>

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
function showImageFallback(image){
    image.style.display="none";
    var fallback=image.parentElement.querySelector(".food-image-fallback");
    if(fallback){fallback.style.display="flex";}
}

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
            // Cancelled adding new item
        } else {
            if (typeof data.cartCount !== 'undefined') {
                updateBadgeCount(data.cartCount);
            }
            alert("Item added to cart successfully!");
        }
    })
    .catch(function(error) { console.error(error); });
}

// Theme & Brightness Management
(function() {
    const savedTheme = localStorage.getItem("smartbite_theme");
    if (savedTheme === "light") {
        document.body.classList.add("light-mode");
    }
    updateThemeButtonUI();

    var count = <%= initialCartCount %>;
    var savedCount = localStorage.getItem("foodtap_cart_count");
    if (savedCount !== null) {
        count = parseInt(savedCount, 10) || count;
    }
    updateBadgeCount(count);
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