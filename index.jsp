<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartBite - Home</title>
    <!-- Google Fonts & Design System Styles -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css"> <!-- Replace with your actual stylesheet path if different -->
</head>
<body class="dark-theme">

    <!-- Top Navigation Bar -->
    <header class="navbar">
        <div class="logo">Smart<span>Bite</span></div>
        <nav class="nav-links">
            <a href="index.jsp" class="active">Home</a>
            <a href="restaurants.jsp">Restaurants</a>
            <a href="weather.jsp">Weather Specials</a>
            <a href="health.jsp">Health Dashboard</a>
        </nav>
        <div class="nav-actions">
            <a href="cart.jsp" class="cart-btn">🛒 Cart</a>
        </div>
    </header>

    <!-- Main Homepage Content -->
    <main class="main-container">
        <section class="hero-section">
            <h1>Discover Great Food Tailored For You</h1>
            <p>Explore top-rated restaurants, weather-based cravings, and smart calorie tracking.</p>
            <a href="restaurants.jsp" class="cta-primary-btn">Explore Restaurants Now</a>
        </section>
    </main>

    <!-- Footer -->
    <footer class="footer">
        <p>&copy; 2026 SmartBite Inc. All rights reserved.</p>
    </footer>

    <!-- Include BiteAI Floating Assistant -->
    <jsp:include page="ai-assistant.jsp" />

</body>
</html>