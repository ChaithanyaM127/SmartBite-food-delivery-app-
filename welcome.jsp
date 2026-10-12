<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Welcome</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&amp;display=swap" rel="stylesheet">

<style type="text/css">
:root {
    --bg-page: #0d0d0f;
    --text-main: #ffffff;
    --text-muted: #a1a1aa;
    --panel-border: rgba(255, 255, 255, 0.08);
    --accent: #e23744;
    --accent-glow: rgba(226, 55, 68, 0.35);
    --shadow: 0 16px 36px rgba(0, 0, 0, 0.6);
}

body.light-mode {
    --bg-page: #f1f3f5;
    --text-main: #111827;
    --text-muted: #6b7280;
    --panel-border: rgba(0, 0, 0, 0.08);
    --shadow: 0 10px 25px rgba(0, 0, 0, 0.06);
}

* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

html, body {
    background: linear-gradient(rgba(13, 13, 15, 0.88), rgba(13, 13, 15, 0.94)), url('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1600&q=80');
    background-size: cover;
    background-position: center;
    color: var(--text-main);
    font-family: 'Plus Jakarta Sans', sans-serif;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.hero-container {
    max-width: 420px;
    margin: auto;
    text-align: center;
    width: 100%;
    padding: 24px;
}

.brand-title {
    font-size: 38px;
    font-weight: 800;
    margin-bottom: 24px;
}

.brand-title span {
    color: var(--accent);
}

.hero-subtitle {
    font-size: 15px;
    color: var(--text-muted);
    line-height: 1.6;
    margin-bottom: 32px;
    font-weight: 600;
}

.cta-button {
    display: block;
    width: 100%;
    padding: 15px;
    background: var(--accent);
    color: white;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 800;
    text-decoration: none;
    box-shadow: 0 8px 25px var(--accent-glow);
    transition: transform 0.2s ease;
}

.cta-button:hover {
    transform: translateY(-2px);
}

footer {
    text-align: center;
    padding: 20px;
    color: var(--text-muted);
    font-size: 12px;
}
</style>
</head>
<body>

<div class="hero-container">
    <div class="brand-title">Smart<span>Bite</span></div>
    <div class="hero-subtitle">Fresh meals, instant tracking, and lightning-fast delivery right to your doorstep.</div>

    <a href="${pageContext.request.contextPath}/home.jsp" class="cta-button">
        Get Started →
    </a>
</div>

<footer>
    <p>&copy; 2026 SmartBite Delivery Platform. All rights reserved.</p>
</footer>

</body>
</html>