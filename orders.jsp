
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.foodtap.model.Order" %>
<%@ page import="com.foodtap.model.User" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("loggedInUser");
    List<Order> orderList = new ArrayList<>();
    Object orderObject = request.getAttribute("orderList");

    if (orderObject instanceof List<?>) {
        for (Object obj : (List<?>) orderObject) {
            if (obj instanceof Order) {
                orderList.add((Order) obj);
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | My Orders</title>

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

/* Profile icon matches the Cart and Restaurants pages */
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

/* Theme and brightness controls match the Cart page */
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

/* Brightness affects page content, not navbar or its controls */
#smartbite-page-content {
    filter: brightness(1);
    transition: filter 0.12s ease;
}

/* Orders container */
.container {
    width: 92%;
    max-width: 1000px;
    margin: 40px auto 80px;
}

.page-title {
    font-size: 28px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.5px;
    margin-bottom: 6px;
}

.welcome {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 28px;
}

.welcome strong {
    color: var(--accent);
}

.order-card {
    background: var(--bg-card-dark);
    border-radius: 8px;
    padding: 24px;
    margin-bottom: 20px;
    border: 1px solid var(--panel-border);
    border-left: 4px solid var(--accent);
    box-shadow: var(--shadow);
    transition: transform 0.2s ease;
}

.order-card:hover {
    transform: translateY(-2px);
    border-color: var(--accent);
}

.order-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 18px;
}

.order-id {
    font-size: 18px;
    font-weight: 800;
    color: var(--text-main);
}

.status {
    padding: 6px 14px;
    border-radius: 20px;
    background: rgba(36, 150, 63, 0.1);
    border: 1px solid rgba(36, 150, 63, 0.3);
    color: #24963f;
    font-size: 12px;
    font-weight: 800;
    text-transform: uppercase;
}

.status.cancelled {
    background: rgba(226, 55, 68, 0.1);
    border-color: rgba(226, 55, 68, 0.3);
    color: var(--accent);
}

.order-details {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    border-top: 1px solid var(--panel-border);
    padding-top: 18px;
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
    font-weight: 800;
    font-size: 14px;
}

.amount {
    color: #24963f;
    font-size: 16px;
    font-weight: 900;
}

.order-actions {
    display: flex;
    gap: 10px;
    margin-top: 20px;
    border-top: 1px solid var(--panel-border);
    padding-top: 18px;
}

.action-btn {
    display: inline-block;
    padding: 10px 18px;
    border-radius: 6px;
    text-decoration: none;
    font-size: 13px;
    font-weight: 800;
    transition: background 0.2s;
}

.view-btn {
    background: var(--accent);
    color: #fff;
}

.view-btn:hover {
    background: #d12e3b;
}

.cancel-btn {
    background: rgba(226, 55, 68, 0.1);
    border: 1px solid rgba(226, 55, 68, 0.3);
    color: var(--accent);
}

.cancel-btn:hover {
    background: rgba(226, 55, 68, 0.2);
}

.empty-card {
    background: var(--bg-card-dark);
    border-radius: 8px;
    padding: 50px 20px;
    text-align: center;
    border: 1px solid var(--panel-border);
    box-shadow: var(--shadow);
}

.empty-icon {
    font-size: 48px;
    margin-bottom: 16px;
}

.empty-card h2 {
    font-size: 20px;
    font-weight: 800;
    color: var(--text-main);
    margin-bottom: 8px;
}

.empty-card p {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 20px;
}

.btn {
    display: inline-block;
    text-decoration: none;
    background: var(--accent);
    color: white;
    padding: 11px 22px;
    border-radius: 6px;
    font-weight: 800;
    font-size: 13px;
    transition: background 0.2s;
}

.btn:hover {
    background: #d12e3b;
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
        flex-wrap: wrap;
        gap: 12px;
    }

    .nav-links {
        gap: 14px;
        flex-wrap: wrap;
    }
}

@media (max-width: 700px) {
    .container {
        width: 94%;
        margin-top: 25px;
    }

    .page-title {
        font-size: 24px;
    }

    .order-details {
        grid-template-columns: repeat(2, 1fr);
    }

    .order-top {
        align-items: flex-start;
        gap: 12px;
    }
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
}

@media (max-width: 480px) {
    .order-details {
        grid-template-columns: 1fr;
    }

    .order-top {
        flex-direction: column;
        align-items: flex-start;
    }

    .order-card {
        padding: 18px;
    }

    .order-actions {
        flex-direction: column;
    }

    .action-btn {
        text-align: center;
        width: 100%;
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
                <a href="orders.jsp" title="Orders" class="active">Orders</a>
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

    <main class="container" id="smartbite-page-content">

        <h1 class="page-title">My Orders</h1>
        <p class="welcome">Hello, <strong><%= user != null ? user.getName() : "User" %></strong> — here are your recent orders.</p>

        <% if (!orderList.isEmpty()) {
            for (Order order : orderList) {
                String status = order.getStatus();
                boolean cancelled = status != null && status.equalsIgnoreCase("CANCELLED");
                boolean canCancel = !cancelled && status != null &&
                    (status.equalsIgnoreCase("PLACED") || status.equalsIgnoreCase("CONFIRMED"));
        %>

        <div class="order-card">
            <div class="order-top">
                <div class="order-id">Order #<%= order.getOrderId() %></div>
                <div class="status <%= cancelled ? "cancelled" : "" %>">
                    <%= status != null ? status : "PLACED" %>
                </div>
            </div>

            <div class="order-details">
                <div>
                    <div class="detail-label">Order Date</div>
                    <div class="detail-value"><%= order.getOrderDate() %></div>
                </div>
                <div>
                    <div class="detail-label">Restaurant</div>
                    <div class="detail-value">#<%= order.getRestaurantId() %></div>
                </div>
                <div>
                    <div class="detail-label">Payment</div>
                    <div class="detail-value"><%= order.getPaymentOption() %></div>
                </div>
                <div>
                    <div class="detail-label">Total Amount</div>
                    <div class="detail-value amount">&#8377;<%= String.format("%.2f", order.getTotalAmount()) %></div>
                </div>
            </div>

            <div class="order-actions">
                <a href="order-details?orderId=<%= order.getOrderId() %>" class="action-btn view-btn">View Details</a>
                <a href="track-order?orderId=<%= order.getOrderId() %>" class="action-btn view-btn" style="background:#24963f;">Track Order</a>
                <% if (canCancel) { %>
                    <a href="cancel-order?orderId=<%= order.getOrderId() %>" class="action-btn cancel-btn" onclick="return confirm('Are you sure you want to cancel this order?');">Cancel Order</a>
                <% } %>
            </div>
        </div>

        <% }
        } else { %>

        <div class="empty-card">
            <div class="empty-icon">🍽️</div>
            <h2>No Orders Yet</h2>
            <p>Looks like you haven't ordered anything yet. Let's find something delicious!</p>
            <a href="restaurants" class="btn">Browse Restaurants</a>
        </div>

        <% } %>

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

        function setBrightness(value, save) {
            const parsedValue = Number(value);

            if (!Number.isFinite(parsedValue)) {
                return;
            }

            brightness = clamp(parsedValue, MIN_BRIGHTNESS, MAX_BRIGHTNESS);
            updateBrightnessUI();

            if (save) {
                try {
                    localStorage.setItem(BRIGHTNESS_KEY, String(brightness));
                } catch (error) {
                    console.warn("Unable to save brightness preference.");
                }
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

                if (slider.setPointerCapture) {
                    slider.setPointerCapture(event.pointerId);
                }

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
