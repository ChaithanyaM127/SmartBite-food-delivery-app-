<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="com.foodtap.model.Restaurant" %>

<%
    LocalTime now = LocalTime.now(ZoneId.of("Asia/Kolkata"));
    LocalTime openTime = LocalTime.of(10, 0);
    LocalTime closeTime = LocalTime.of(23, 0);
    boolean isRestaurantOpen = !now.isBefore(openTime) && !now.isAfter(closeTime);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Restaurants Near You</title>

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
    --bg-page: #e8e6e1 !important;
    --bg-card-dark: #f5f3ef !important;
    --bg-card-bottom: #f0eee9 !important;
    --text-main: #2b2d30 !important;
    --text-muted: #62656a !important;
    --text-bottom-main: #2b2d30 !important;
    --text-bottom-sub: #53565b !important;
    --nav-bg: rgba(232, 230, 225, 0.95) !important;
    --nav-border: rgba(0, 0, 0, 0.08) !important;
    --panel-border: rgba(0, 0, 0, 0.08) !important;
    --metric-bg: rgba(0, 0, 0, 0.04) !important;
    --shadow: 0 8px 20px rgba(0, 0, 0, 0.04) !important;
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

/* Main Container Layout */
.main-container {
    max-width: 1320px;
    margin: 40px auto;
    padding: 0 24px;
    width: 100%;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    margin-bottom: 24px;
}

.section-header h2 {
    font-size: 28px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.5px;
    margin: 0;
}

.section-header p {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
    margin-top: 6px;
}

/* ZERO GAP WRAPPER MATCHING HOME PAGE */
.restaurant-grid-wrapper {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
    margin: 0;
    padding: 0;
}

.restaurant-square-card {
    width: 25%;
    box-sizing: border-box;
    border: 1px solid var(--panel-border);
    border-radius: 0;
    overflow: hidden;
    background: var(--bg-card-dark);
    text-decoration: none;
    display: flex;
    flex-direction: column;
    cursor: pointer;
    transition: transform 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease;
    box-shadow: var(--shadow);
}

.restaurant-square-card:hover {
    border-color: var(--accent);
    transform: translateY(-2px);
    z-index: 2;
}

/* PART 1: TOP DEEP BLACK SECTION */
.card-part-top-black {
    background: #0d0d0f !important;
    color: #ffffff !important;
    padding-bottom: 12px;
    position: relative;
}

.card-img-box {
    position: relative;
    height: 160px;
    width: 100%;
    background: #000000;
    overflow: hidden;
}

.card-img-box img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.rating-badge {
    position: absolute;
    top: 10px;
    right: 10px;
    background: #24963f;
    color: #ffffff;
    font-size: 11px;
    font-weight: 800;
    padding: 4px 8px;
    border-radius: 6px;
}

.status-badge {
    position: absolute;
    top: 10px;
    left: 10px;
    font-size: 11px;
    font-weight: 800;
    padding: 4px 10px;
    border-radius: 6px;
    color: #ffffff;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.4);
}

.status-badge.open {
    background: #24963f;
}

.status-badge.closed {
    background: #e23744;
}

.restaurant-title-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 12px 14px 0 14px;
}

.restaurant-title {
    font-size: 17px;
    font-weight: 800;
    color: #ffffff !important;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    flex: 1;
}

/* PART 2: BOTTOM ADAPTIVE SECTION */
.card-part-bottom-charcoal {
    background: var(--bg-card-bottom) !important;
    color: var(--text-bottom-main) !important;
    padding: 12px 14px 14px 14px;
    display: flex;
    flex-direction: column;
    flex: 1;
    border-top: 1px solid var(--panel-border);
}

.cuisine-text {
    font-size: 13px;
    color: var(--text-bottom-sub) !important;
    margin: 0 0 8px 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.timing-text {
    font-size: 12px;
    font-weight: 700;
    color: #059669 !important;
    margin-bottom: 12px;
}

body.light-mode .timing-text {
    color: #047857 !important;
}

.meta-footer-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid var(--panel-border);
    padding-top: 10px;
    margin-top: auto;
}

.delivery-time {
    font-size: 12px;
    color: var(--text-bottom-sub) !important;
    font-weight: 600;
}

.view-menu-btn-red {
    background: #e23744 !important;
    color: #ffffff !important;
    padding: 7px 13px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 800;
    text-decoration: none;
    display: inline-block;
}

.empty {
    text-align: center;
    background: var(--bg-card-dark);
    padding: 50px;
    border-radius: 16px;
    border: 1px solid var(--panel-border);
    grid-column: 1 / -1;
    box-shadow: var(--shadow);
}

.empty h2 {
    margin-bottom: 10px;
    color: var(--text-main);
    font-size: 22px;
    font-weight: 800;
}

.empty p {
    color: var(--text-muted);
    font-size: 14px;
}

/* Footer */
footer {
    background: var(--bg-card-dark);
    border-top: 1px solid var(--panel-border);
    color: var(--text-muted);
    text-align: center;
    padding: 30px 24px;
    margin-top: 60px;
    font-size: 12px;
    font-weight: 600;
}

@media (max-width: 1200px) {
    .restaurant-square-card { width: 33.333%; }
}

@media (max-width: 900px) {
    .restaurant-square-card { width: 50%; }
}

@media (max-width: 600px) {
    .restaurant-square-card { width: 100%; }
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
                <a href="restaurants" class="active">Restaurants</a>
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

    <!-- Main Container -->
    <main class="main-container">

        <div class="section-header">
            <div>
                <h2>Restaurants <span>Near You</span></h2>
                <p>Discover delicious food from your favourite local kitchens.</p>
            </div>
        </div>

        <!-- Zero Gap 4-Column Square Grid -->
        <div class="restaurant-grid-wrapper">
            <%
                Object restaurantObject = request.getAttribute("restaurants");

                if (restaurantObject instanceof List<?>) {

                    List<?> restaurantList = (List<?>) restaurantObject;

                    if (!restaurantList.isEmpty()) {

                        for (Object obj : restaurantList) {

                            if (!(obj instanceof Restaurant)) {
                                continue;
                            }

                            Restaurant restaurant = (Restaurant) obj;
                            String restaurantImage = restaurant.getImagePath();

                            if (restaurantImage == null || restaurantImage.trim().isEmpty()) {
                                restaurantImage = "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80";
                            }
            %>

            <form action="menu" method="get" onclick="this.submit();" class="restaurant-square-card">
                <input type="hidden" name="restaurantId" value="<%= restaurant.getRestaurantId() %>">
                
                <!-- PART 1: TOP BLACK SECTION -->
                <div class="card-part-top-black">
                    <div class="card-img-box">
                        <img src="<%= restaurantImage %>" alt="<%= restaurant.getName() %>" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80';">
                        
                        <% if (isRestaurantOpen) { %>
                            <span class="status-badge open">OPEN</span>
                        <% } else { %>
                            <span class="status-badge closed">CLOSED</span>
                        <% } %>

                        <span class="rating-badge">★ <%= restaurant.getRating() %></span>
                    </div>
                    
                    <div class="restaurant-title-row">
                        <div class="restaurant-title"><%= restaurant.getName() %></div>
                    </div>
                </div>

                <!-- PART 2: BOTTOM ADAPTIVE SECTION -->
                <div class="card-part-bottom-charcoal">
                    <div class="cuisine-text"><%= restaurant.getCuisineType() %></div>
                    <div class="timing-text">🕒 10:00 AM - 11:00 PM</div>
                    <div class="meta-footer-row">
                        <span class="delivery-time">◷ <%= restaurant.getDeliveryTime() %> mins</span>
                        <span class="view-menu-btn-red">View Menu →</span>
                    </div>
                </div>
            </form>

            <%
                        }

                    } else {
            %>

                <div class="empty">
                    <h2>No restaurants available</h2>
                    <p>Please add restaurants to the database.</p>
                </div>

            <%
                    }

                } else {
            %>

                <div class="empty">
                    <h2>No restaurants available</h2>
                    <p>Restaurant data could not be loaded.</p>
                </div>

            <%
                }
            %>
        </div>

    </main>

    <%@ include file="ai-assistant.jsp" %>

    <footer>
        <p>&copy; 2026 SmartBite Delivery Platform. All rights reserved.</p>
    </footer>

    <script>
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

</body>
</html>