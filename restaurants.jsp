
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
    --bg-page: #e8e6e1;
    --bg-card-dark: #f5f3ef;
    --bg-card-bottom: #f0eee9;
    --text-main: #2b2d30;
    --text-muted: #62656a;
    --text-bottom-main: #2b2d30;
    --text-bottom-sub: #53565b;
    --nav-bg: rgba(232, 230, 225, 0.95);
    --nav-border: rgba(0, 0, 0, 0.08);
    --panel-border: rgba(0, 0, 0, 0.08);
    --metric-bg: rgba(0, 0, 0, 0.04);
    --shadow: 0 8px 20px rgba(0, 0, 0, 0.04);
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

/* Navbar */
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

.nav-links > a:not(.profile-avatar) {
    text-decoration: none;
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 6px;
}

.nav-links > a:not(.profile-avatar):hover,
.nav-links > a.active {
    color: var(--accent);
}

/* Profile icon matches Cart page */
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

/* Theme and brightness controls matching Cart page */
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
    transition: color 0.18s ease;
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
    opacity: 0.7;
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

/* Brightness applies to page content, not navbar controls */
#smartbite-page-content {
    filter: brightness(1);
    transition: filter 0.12s ease;
}

/* Restaurant Grid */
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

/* Restaurant card top section */
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

/* Restaurant card bottom section */
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
    box-shadow: var(--shadow);
    width: 100%;
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
    .nav-container {
        padding: 12px 16px;
        flex-wrap: wrap;
        gap: 12px;
    }

    .nav-links {
        gap: 14px;
        flex-wrap: wrap;
    }

    .restaurant-square-card { width: 50%; }
}

@media (max-width: 600px) {
    .nav-container {
        align-items: flex-start;
    }

    .logo {
        font-size: 23px;
    }

    .nav-links {
        width: 100%;
        justify-content: space-between;
        gap: 8px;
    }

    .nav-links > a:not(.profile-avatar) {
        font-size: 12px;
    }

    .controls-box {
        gap: 5px;
    }

    .brightness-slider {
        flex-basis: 42px;
        width: 42px;
    }

    .restaurant-square-card { width: 100%; }

    .main-container {
        margin-top: 28px;
        padding: 0 16px;
    }

    .section-header h2 {
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
                <a href="restaurants" class="active">Restaurants</a>
                <a href="orders.jsp" title="Orders">Orders</a>
                <a href="cart.jsp" title="Cart">🛒 Cart</a>
                <a href="profile.jsp" class="profile-avatar" title="Profile" aria-label="Profile">👤</a>

                <div class="controls-box" aria-label="Theme and brightness controls">
                    <button type="button"
                            class="theme-mode-btn"
                            id="lightModeBtn"
                            onclick="setThemeMode('light')"
                            title="Light Mode"
                            aria-label="Switch to Light Mode"
                            aria-pressed="false">☀</button>

                    <div class="brightness-slider"
                         id="brightnessSlider"
                         role="slider"
                         tabindex="0"
                         aria-label="Adjust screen brightness"
                         aria-valuemin="0.5"
                         aria-valuemax="1.5"
                         aria-valuenow="1"
                         title="Drag to adjust brightness">
                        <span class="brightness-track" aria-hidden="true"></span>
                        <span class="brightness-fill" id="brightnessFill" aria-hidden="true"></span>
                        <span class="brightness-thumb" id="brightnessThumb" aria-hidden="true"></span>
                    </div>

                    <button type="button"
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

    <!-- Main Container -->
    <main class="main-container" id="smartbite-page-content">

        <div class="section-header">
            <div>
                <h2>Restaurants <span>Near You</span></h2>
                <p>Discover delicious food from your favourite local kitchens.</p>
            </div>
        </div>

        <!-- Restaurant Grid -->
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

                <div class="card-part-top-black">
                    <div class="card-img-box">
                        <img src="<%= restaurantImage %>"
                             alt="<%= restaurant.getName() %>"
                             onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80';">

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
    (function () {
        const THEME_KEY = "smartbite_theme";
        const BRIGHTNESS_KEY = "smartbite_brightness";
        const MIN_BRIGHTNESS = 0.5;
        const MAX_BRIGHTNESS = 1.5;

        const slider = document.getElementById("brightnessSlider");
        const fill = document.getElementById("brightnessFill");
        const thumb = document.getElementById("brightnessThumb");
        const content = document.getElementById("smartbite-page-content");

        let brightness = 1;
        let dragging = false;

        function clamp(value, min, max) {
            return Math.min(max, Math.max(min, value));
        }

        function updateBrightnessUI() {
            const percentage =
                ((brightness - MIN_BRIGHTNESS) /
                (MAX_BRIGHTNESS - MIN_BRIGHTNESS)) * 100;

            if (fill) {
                fill.style.width = percentage + "%";
            }

            if (thumb) {
                thumb.style.left = percentage + "%";
            }

            if (slider) {
                slider.setAttribute("aria-valuenow", brightness.toFixed(2));
            }

            if (content) {
                content.style.filter = "brightness(" + brightness + ")";
            }
        }

        function saveBrightness() {
            try {
                localStorage.setItem(BRIGHTNESS_KEY, String(brightness));
            } catch (error) {
                console.warn("Unable to save brightness preference.");
            }
        }

        function setBrightness(value, save) {
            const parsedValue = Number(value);

            if (!Number.isFinite(parsedValue)) {
                return;
            }

            brightness = clamp(parsedValue, MIN_BRIGHTNESS, MAX_BRIGHTNESS);
            updateBrightnessUI();

            if (save) {
                saveBrightness();
            }
        }

        function setBrightnessFromPointer(event) {
            if (!slider) {
                return;
            }

            const rect = slider.getBoundingClientRect();
            if (rect.width <= 0) {
                return;
            }

            const percentage = clamp(
                (event.clientX - rect.left) / rect.width,
                0,
                1
            );

            const value =
                MIN_BRIGHTNESS +
                percentage * (MAX_BRIGHTNESS - MIN_BRIGHTNESS);

            setBrightness(value, true);
        }

        window.setThemeMode = function (mode) {
            const isLight = mode === "light";

            document.body.classList.toggle("light-mode", isLight);

            try {
                localStorage.setItem(THEME_KEY, isLight ? "light" : "dark");
            } catch (error) {
                console.warn("Unable to save theme preference.");
            }

            updateThemeButtonUI();
        };

        window.toggleTheme = function () {
            const isLight = document.body.classList.contains("light-mode");
            window.setThemeMode(isLight ? "dark" : "light");
        };

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

        function handleBrightnessKeydown(event) {
            let nextValue = brightness;

            switch (event.key) {
                case "ArrowLeft":
                case "ArrowDown":
                    nextValue -= 0.05;
                    break;
                case "ArrowRight":
                case "ArrowUp":
                    nextValue += 0.05;
                    break;
                case "Home":
                    nextValue = MIN_BRIGHTNESS;
                    break;
                case "End":
                    nextValue = MAX_BRIGHTNESS;
                    break;
                default:
                    return;
            }

            event.preventDefault();
            setBrightness(nextValue, true);
        }

        function loadPreferences() {
            try {
                const savedTheme = localStorage.getItem(THEME_KEY);
                if (savedTheme === "light" || savedTheme === "dark") {
                    document.body.classList.toggle(
                        "light-mode",
                        savedTheme === "light"
                    );
                }

                const savedBrightness = localStorage.getItem(BRIGHTNESS_KEY);
                if (savedBrightness !== null) {
                    setBrightness(savedBrightness, false);
                } else {
                    setBrightness(1, false);
                }
            } catch (error) {
                setBrightness(1, false);
            }

            updateThemeButtonUI();
        }

        if (slider) {
            slider.addEventListener("pointerdown", function (event) {
                dragging = true;
                slider.setPointerCapture(event.pointerId);
                setBrightnessFromPointer(event);
            });

            slider.addEventListener("pointermove", function (event) {
                if (dragging) {
                    setBrightnessFromPointer(event);
                }
            });

            slider.addEventListener("pointerup", function () {
                dragging = false;
            });

            slider.addEventListener("pointercancel", function () {
                dragging = false;
            });

            slider.addEventListener("keydown", handleBrightnessKeydown);
        }

        window.addEventListener("storage", function (event) {
            if (event.key === THEME_KEY) {
                if (event.newValue === "light" || event.newValue === "dark") {
                    document.body.classList.toggle(
                        "light-mode",
                        event.newValue === "light"
                    );
                    updateThemeButtonUI();
                }
            }

            if (event.key === BRIGHTNESS_KEY && event.newValue !== null) {
                setBrightness(event.newValue, false);
            }
        });

        loadPreferences();
    })();
    </script>

</body>
</html>
