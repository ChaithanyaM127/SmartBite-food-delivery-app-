
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String error = request.getParameter("error");
    String requestedRedirect = request.getParameter("redirect");

    /*
     * Default: Profile icon -> Login -> Home page.
     * If the login page was opened directly from checkout.jsp,
     * preserve Checkout as the destination.
     */
    String loginRedirect = "home.jsp";

    if ("checkout.jsp".equals(requestedRedirect)) {
        loginRedirect = "checkout.jsp";
    } else if (requestedRedirect == null || requestedRedirect.trim().isEmpty()) {
        String referer = request.getHeader("Referer");

        if (referer != null) {
            try {
                java.net.URI refererUri = new java.net.URI(referer);
                String refererPath = refererUri.getPath();

                if (refererPath != null
                        && (refererPath.endsWith("/checkout.jsp")
                        || refererPath.equals("checkout.jsp"))) {
                    loginRedirect = "checkout.jsp";
                }
            } catch (java.net.URISyntaxException ignored) {
                // Keep the safe default destination.
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartBite | Welcome Back</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&amp;display=swap" rel="stylesheet">

    <style>
        :root {
            --bg-card: rgba(18, 19, 24, 0.95);
            --text-main: #ffffff;
            --text-muted: #a1a1aa;
            --panel-border: rgba(255, 255, 255, 0.1);
            --accent: #e23744;
            --accent-glow: rgba(226, 55, 68, 0.4);
            --shadow: 0 25px 60px rgba(0, 0, 0, 0.85);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background:
                linear-gradient(rgba(13, 13, 15, 0.78), rgba(13, 13, 15, 0.88)),
                url('https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1600&q=80');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            color: var(--text-main);
            overflow-x: hidden;
        }

        body.light-mode {
            --bg-card: rgba(255, 255, 255, 0.96);
            --text-main: #242424;
            --text-muted: #686868;
            --panel-border: rgba(0, 0, 0, 0.12);
            --shadow: 0 25px 60px rgba(0, 0, 0, 0.22);

            background:
                linear-gradient(rgba(255, 250, 246, 0.78), rgba(255, 250, 246, 0.88)),
                url('https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1600&q=80');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
        }

        /* Theme and brightness controls */
        .controls-box {
            position: fixed;
            top: 22px;
            right: 26px;
            z-index: 1000;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 0;
            margin: 0;
            background: transparent;
            border: none;
            box-shadow: none;
        }

        .theme-mode-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 16px;
            height: 18px;
            padding: 0;
            border: 0;
            border-radius: 0;
            background: transparent;
            color: var(--text-muted);
            font-family: inherit;
            font-size: 13px;
            line-height: 1;
            cursor: pointer;
            transition: color 0.18s ease;
        }

        .theme-mode-btn:hover,
        .theme-mode-btn.active {
            color: var(--accent);
        }

        .theme-mode-btn:focus-visible,
        .brightness-slider:focus-visible {
            outline: 2px solid var(--accent);
            outline-offset: 4px;
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
            pointer-events: none;
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
            transform: translate(-50%, -50%);
            pointer-events: none;
        }

        .login-page-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 50px;
            width: 100%;
            max-width: 1200px;
            padding: 60px 20px 20px;
            position: relative;
        }

        .chef-character {
            width: 220px;
            height: 280px;
            object-fit: contain;
            filter: drop-shadow(0 15px 30px rgba(0, 0, 0, 0.7));
        }

        .login-container {
            width: 100%;
            max-width: 420px;
            padding: 40px 36px;
            background: var(--bg-card);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid var(--panel-border);
            border-radius: 24px;
            box-shadow: var(--shadow);
            position: relative;
            z-index: 10;
        }

        .welcoming-chef-header {
            text-align: center;
            margin-bottom: -10px;
            position: relative;
            z-index: 15;
        }

        .welcoming-chef-header img {
            width: 90px;
            height: 90px;
            object-fit: contain;
            filter: drop-shadow(0 10px 20px rgba(0, 0, 0, 0.6));
        }

        .logo {
            text-align: center;
            font-size: 30px;
            font-weight: 800;
            color: var(--text-main);
            letter-spacing: -0.5px;
            margin-top: 4px;
            margin-bottom: 4px;
        }

        .logo span {
            color: var(--accent);
        }

        .subtitle {
            text-align: center;
            color: var(--text-muted);
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 24px;
        }

        label {
            display: block;
            margin-bottom: 6px;
            color: var(--text-muted);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.3px;
        }

        input:not([type="hidden"]) {
            width: 100%;
            padding: 13px 15px;
            margin-bottom: 18px;
            border: 1px solid var(--panel-border);
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-main);
            font-family: inherit;
            font-size: 14px;
            font-weight: 500;
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        body.light-mode input:not([type="hidden"]) {
            background: rgba(0, 0, 0, 0.035);
        }

        input:not([type="hidden"]):focus {
            border-color: var(--accent);
            box-shadow: 0 0 15px var(--accent-glow);
        }

        input::placeholder {
            color: var(--text-muted);
            opacity: 0.65;
        }

        .login-button {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 12px;
            background: var(--accent);
            color: #fff;
            font-family: inherit;
            font-size: 14px;
            font-weight: 800;
            cursor: pointer;
            box-shadow: 0 8px 25px var(--accent-glow);
            transition: transform 0.2s ease, background 0.2s ease;
        }

        .login-button:hover {
            background: #d12e3b;
            transform: translateY(-2px);
        }

        .error {
            background: rgba(226, 55, 68, 0.2);
            border: 1px solid rgba(226, 55, 68, 0.4);
            color: #ff949b;
            padding: 10px;
            border-radius: 10px;
            margin-bottom: 20px;
            text-align: center;
            font-size: 12px;
            font-weight: 700;
        }

        .signup-prompt {
            text-align: center;
            margin-top: 20px;
            font-size: 12px;
            color: var(--text-muted);
        }

        .signup-prompt a {
            color: var(--accent);
            text-decoration: none;
            font-weight: 800;
        }

        .signup-prompt a:hover {
            text-decoration: underline;
        }

        @media (max-width: 950px) {
            .chef-character {
                display: none;
            }

            .login-page-wrapper {
                gap: 0;
            }
        }

        @media (max-width: 480px) {
            .controls-box {
                top: 18px;
                right: 18px;
            }

            .login-page-wrapper {
                padding: 58px 16px 20px;
            }

            .login-container {
                padding: 32px 24px;
            }
        }
    </style>
</head>

<body>

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

    <div class="login-page-wrapper">

        <img
            src="https://images.vexels.com/media/users/3/143026/isolated/preview/10e9c8bc82798aa12fae2be52140134f-chef-cooking-cartoon-by-vexels.png"
            class="chef-character"
            alt="Chef Cooking">

        <div class="login-container">

            <div class="welcoming-chef-header">
                <img
                    src="https://images.vexels.com/media/users/3/129337/isolated/preview/26e382ff2f9540b615b3671a8f9fa4fa-chef-waving-cartoon-by-vexels.png"
                    alt="Welcoming Chef">
            </div>

            <div class="logo">Smart<span>Bite</span></div>
            <div class="subtitle">Welcome back! Please login to your account.</div>

            <% if (error != null) { %>
                <div class="error">
                    <% if ("empty".equals(error)) { %>
                        Please enter your email and password.
                    <% } else { %>
                        Unable to complete login. Please try again.
                    <% } %>
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/LoginServlet" method="post">

                <input
                    type="hidden"
                    name="redirect"
                    value="<%= loginRedirect %>">

                <label for="email">Email Address</label>
                <input
                    type="email"
                    id="email"
                    name="email"
                    placeholder="name@example.com"
                    autocomplete="email"
                    required>

                <label for="password">Password</label>
                <input
                    type="password"
                    id="password"
                    name="password"
                    placeholder="••••••••"
                    autocomplete="current-password"
                    required>

                <button type="submit" class="login-button">
                    Login to SmartBite →
                </button>
            </form>

            <div class="signup-prompt">
                Don't have an account?
                <a href="<%= request.getContextPath() %>/register.jsp">Sign up now</a>
            </div>

        </div>

        <img
            src="https://images.vexels.com/media/users/3/143029/isolated/preview/2866649f8549646b97607730e6659c23-chef-holding-dish-cartoon-by-vexels.png"
            class="chef-character"
            alt="Chef Serving Dish">

    </div>

    <script>
        function setThemeMode(mode) {
            const isLight = mode === "light";

            document.body.classList.toggle("light-mode", isLight);

            try {
                localStorage.setItem("smartbite_theme", isLight ? "light" : "dark");
            } catch (e) {
                console.log("Unable to save theme preference.");
            }

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

        let brightnessDragActive = false;

        function updateBrightnessSlider(value) {
            const parsed = parseFloat(value);
            const brightness = Math.min(
                1.5,
                Math.max(0.5, Number.isFinite(parsed) ? parsed : 1)
            );

            const percentage = ((brightness - 0.5) / 1.0) * 100;
            const slider = document.getElementById("brightnessSlider");
            const fill = document.getElementById("brightnessFill");
            const thumb = document.getElementById("brightnessThumb");

            if (fill) fill.style.width = percentage + "%";
            if (thumb) thumb.style.left = percentage + "%";

            if (slider) {
                slider.setAttribute("aria-valuenow", brightness.toFixed(2));
            }
        }

        function adjustBrightness(value) {
            const brightness = parseFloat(value);

            if (!Number.isFinite(brightness) ||
                    brightness < 0.5 || brightness > 1.5) {
                return;
            }

            document.documentElement.style.filter =
                "brightness(" + brightness + ")";

            updateBrightnessSlider(brightness);

            try {
                localStorage.setItem("smartbite_brightness", String(brightness));
            } catch (e) {
                console.log("Unable to save brightness preference.");
            }
        }

        function updateBrightnessFromPointer(event) {
            const slider = document.getElementById("brightnessSlider");
            if (!slider) return;

            const rect = slider.getBoundingClientRect();
            if (!rect.width) return;

            const percentage = Math.min(
                1,
                Math.max(0, (event.clientX - rect.left) / rect.width)
            );

            adjustBrightness(0.5 + percentage);
        }

        function startBrightnessDrag(event) {
            if (event.button !== undefined && event.button !== 0) return;

            brightnessDragActive = true;

            if (event.currentTarget &&
                    event.currentTarget.setPointerCapture &&
                    event.pointerId !== undefined) {
                try {
                    event.currentTarget.setPointerCapture(event.pointerId);
                } catch (e) {
                    // Pointer capture may be unavailable.
                }
            }

            updateBrightnessFromPointer(event);
            event.preventDefault();
        }

        function moveBrightnessDrag(event) {
            if (!brightnessDragActive) return;

            updateBrightnessFromPointer(event);
            event.preventDefault();
        }

        function stopBrightnessDrag() {
            brightnessDragActive = false;
        }

        function handleBrightnessKeydown(event) {
            const slider = document.getElementById("brightnessSlider");
            if (!slider) return;

            const current =
                parseFloat(slider.getAttribute("aria-valuenow")) || 1;

            let next = current;

            if (event.key === "ArrowLeft" || event.key === "ArrowDown") {
                next = current - 0.05;
            } else if (event.key === "ArrowRight" || event.key === "ArrowUp") {
                next = current + 0.05;
            } else if (event.key === "Home") {
                next = 0.5;
            } else if (event.key === "End") {
                next = 1.5;
            } else {
                return;
            }

            event.preventDefault();

            next = Math.min(
                1.5,
                Math.max(0.5, Math.round(next * 100) / 100)
            );

            adjustBrightness(next);
        }

        (function initializeAppearance() {
            let savedTheme = "dark";
            let savedBrightness = 1;

            try {
                const storedTheme = localStorage.getItem("smartbite_theme");

                if (storedTheme === "light" || storedTheme === "dark") {
                    savedTheme = storedTheme;
                }

                const storedBrightness = parseFloat(
                    localStorage.getItem("smartbite_brightness")
                );

                if (Number.isFinite(storedBrightness) &&
                        storedBrightness >= 0.5 &&
                        storedBrightness <= 1.5) {
                    savedBrightness = storedBrightness;
                }
            } catch (e) {
                console.log("Unable to load appearance preferences.");
            }

            document.body.classList.toggle(
                "light-mode",
                savedTheme === "light"
            );

            updateThemeButtonUI();
            adjustBrightness(savedBrightness);

            const slider = document.getElementById("brightnessSlider");

            if (slider) {
                slider.addEventListener("pointerdown", startBrightnessDrag);
                slider.addEventListener("pointermove", moveBrightnessDrag);
                slider.addEventListener("pointerup", stopBrightnessDrag);
                slider.addEventListener("pointercancel", stopBrightnessDrag);
                slider.addEventListener("lostpointercapture", stopBrightnessDrag);
                slider.addEventListener("keydown", handleBrightnessKeydown);
            }

            document.addEventListener("pointerup", stopBrightnessDrag);
        })();
    </script>

</body>
</html>
