<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartBite | Welcome Back</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&amp;display=swap" rel="stylesheet">

<style type="text/css">
:root {
    --bg-page: #0d0d0f;
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
    background: linear-gradient(rgba(13, 13, 15, 0.78), rgba(13, 13, 15, 0.88)), url('https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1600&q=80');
    background-size: cover;
    background-position: center;
    color: var(--text-main);
    overflow-x: hidden;
}

/* Page Wrapper placing Left, Center, and Right elements stably */
.login-page-wrapper {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 50px;
    width: 100%;
    max-width: 1200px;
    padding: 20px;
    position: relative;
}

/* Side Chef Characters (Realistic static illustrations) */
.chef-character {
    width: 220px;
    height: 280px;
    object-fit: contain;
    filter: drop-shadow(0 15px 30px rgba(0,0,0,0.7));
}

/* Center Login Box Container */
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

/* Top Welcoming Chef Character positioned right above the login box */
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
    filter: drop-shadow(0 10px 20px rgba(0,0,0,0.6));
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

input {
    width: 100%;
    padding: 13px 15px;
    margin-bottom: 18px;
    border: 1px solid var(--panel-border);
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.05);
    color: var(--text-main);
    font-size: 14px;
    font-weight: 500;
    outline: none;
    transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

input:focus {
    border-color: var(--accent);
    box-shadow: 0 0 15px var(--accent-glow);
}

input::placeholder {
    color: rgba(161, 161, 170, 0.4);
}

.login-button {
    width: 100%;
    padding: 14px;
    border: none;
    border-radius: 12px;
    background: var(--accent);
    color: #fff;
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
    .chef-character { display: none; }
    .login-page-wrapper { gap: 0; }
}
</style>
</head>
<body>

    <div class="login-page-wrapper">
        <!-- Left Side: Chef Cooking Food -->
        <img src="https://images.vexels.com/media/users/3/143026/isolated/preview/10e9c8bc82798aa12fae2be52140134f-chef-cooking-cartoon-by-vexels.png" class="chef-character" alt="Chef Cooking">

        <!-- Center Login Card with Top Welcoming Chef -->
        <div class="login-container">
            <div class="welcoming-chef-header">
                <img src="https://images.vexels.com/media/users/3/129337/isolated/preview/26e382ff2f9540b615b3671a8f9fa4fa-chef-waving-cartoon-by-vexels.png" alt="Welcoming Chef">
            </div>

            <div class="logo">Smart<span>Bite</span></div>
            <div class="subtitle">Welcome back! Please login to your account.</div>

            <% 
                String error = request.getParameter("error");
                if (error != null) {
            %>
                <div class="error">
                    <% if ("empty".equals(error)) { %>
                        Please enter your email and password.
                    <% } else { %>
                        Invalid email or password. Please try again.
                    <% } %>
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/LoginServlet" method="post">
                <label for="email">Email Address</label>
                <input
                    type="email"
                    id="email"
                    name="email"
                    placeholder="name@example.com"
                    required
                >

                <label for="password">Password</label>
                <input
                    type="password"
                    id="password"
                    name="password"
                    placeholder="••••••••"
                    required
                >

                <button type="submit" class="login-button">
                    Login to SmartBite →
                </button>
            </form>

            <div class="signup-prompt">
                Don't have an account? <a href="register.jsp">Sign up now</a>
            </div>
        </div>

        <!-- Right Side: Chef holding a bowl of food/noodles -->
        <img src="https://images.vexels.com/media/users/3/143029/isolated/preview/2866649f8549646b97607730e6659c23-chef-holding-dish-cartoon-by-vexels.png" class="chef-character" alt="Chef Serving Dish">
    </div>

</body>
</html>