<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDate" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Offers &amp; Rewards | SmartBite</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<style>
:root {
    --bg: #0d0d0f;
    --surface: #121318;
    --surface-2: #1a1b22;
    --text: #f7f7f8;
    --muted: #a0a1ab;
    --accent: #e23744;
    --accent-2: #ff5360;
    --border: rgba(255,255,255,.09);
    --nav: rgba(13,13,15,.84);
    --shadow: 0 20px 60px rgba(0,0,0,.24);
}

* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

html {
    scroll-behavior: smooth;
}

body {
    font-family: 'Plus Jakarta Sans', sans-serif;
    background: var(--bg);
    color: var(--text);
    min-height: 100vh;
    transition: background .3s, color .3s;
}

body.light-mode {
    --bg: #f6f6f8;
    --surface: #ffffff;
    --surface-2: #f0f0f3;
    --text: #19191d;
    --muted: #696a74;
    --border: rgba(0,0,0,.09);
    --nav: rgba(255,255,255,.88);
    --shadow: 0 20px 60px rgba(30,30,40,.09);
}

a {
    color: inherit;
    text-decoration: none;
}

button,
input {
    font: inherit;
}

button {
    cursor: pointer;
}

.navbar {
    position: sticky;
    top: 0;
    z-index: 100;
    width: 100%;
    min-height: 76px;
    padding: 14px 5.5%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 24px;
    background: var(--nav);
    border-bottom: 1px solid var(--border);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
}

.brand {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 23px;
    font-weight: 800;
    letter-spacing: -1px;
    white-space: nowrap;
}

.brand-icon {
    width: 38px;
    height: 38px;
    border-radius: 12px;
    display: grid;
    place-items: center;
    color: #fff;
    background: linear-gradient(135deg, var(--accent), #a9192b);
    box-shadow: 0 7px 22px rgba(226,55,68,.25);
}

.brand span:last-child {
    color: var(--accent);
}

.nav-links {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 27px;
}

.nav-links a {
    color: var(--muted);
    font-size: 13px;
    font-weight: 600;
    transition: color .2s;
}

.profile-link {
    display: inline-flex !important;
    align-items: center;
    gap: 7px;
}

.profile-icon {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    display: inline-grid;
    place-items: center;
    color: #fff;
    background: linear-gradient(135deg, var(--accent), #a9192b);
    font-size: 12px;
    box-shadow: 0 5px 16px rgba(226,55,68,.22);
}

.nav-links a:hover,
.nav-links a.active {
    color: var(--text);
}

.nav-links a.active {
    position: relative;
}

.nav-links a.active::after {
    content: "";
    position: absolute;
    height: 2px;
    left: 0;
    right: 0;
    bottom: -10px;
    border-radius: 5px;
    background: var(--accent);
}

.nav-actions {
    display: flex;
    align-items: center;
    gap: 12px;
}

.icon-btn {
    width: 39px;
    height: 39px;
    display: grid;
    place-items: center;
    border: 1px solid var(--border);
    border-radius: 12px;
    color: var(--text);
    background: var(--surface);
    transition: .2s;
}

.icon-btn:hover {
    border-color: var(--accent);
    transform: translateY(-1px);
}

.brightness-wrapper {
    display: flex;
    align-items: center;
    gap: 7px;
}

.brightness-wrapper i {
    font-size: 12px;
    color: var(--muted);
}

.brightness-control {
    width: 76px;
    height: 3px;
    appearance: none;
    -webkit-appearance: none;
    background: #777;
    border-radius: 10px;
    outline: none;
    cursor: pointer;
}

.brightness-control::-webkit-slider-thumb {
    appearance: none;
    -webkit-appearance: none;
    width: 11px;
    height: 11px;
    border-radius: 50%;
    background: var(--accent);
    border: 0;
    box-shadow: 0 0 8px rgba(226,55,68,.75);
}

.brightness-control::-moz-range-thumb {
    width: 11px;
    height: 11px;
    border-radius: 50%;
    background: var(--accent);
    border: 0;
    box-shadow: 0 0 8px rgba(226,55,68,.75);
}

.mobile-menu {
    display: none;
}

.hero {
    position: relative;
    isolation: isolate;
    min-height: 390px;
    display: flex;
    align-items: center;
    overflow: hidden;
    padding: 65px 7%;
    background: #171114;
}

.hero::before {
    content: "";
    position: absolute;
    inset: 0;
    z-index: -2;
    background-image: url("https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=2000&q=90");
    background-size: cover;
    background-position: center 48%;
    transform: scale(1.02);
}

.hero::after {
    content: "";
    position: absolute;
    inset: 0;
    z-index: -1;
    background:
        linear-gradient(90deg, rgba(10,10,12,.96) 0%, rgba(10,10,12,.83) 42%, rgba(10,10,12,.3) 100%),
        linear-gradient(0deg, rgba(10,10,12,.62), transparent 55%);
}

.hero-content {
    max-width: 730px;
}

.eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 9px;
    padding: 8px 13px;
    margin-bottom: 23px;
    color: #ffb5ba;
    background: rgba(226,55,68,.15);
    border: 1px solid rgba(255,100,112,.3);
    border-radius: 30px;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 1.6px;
    text-transform: uppercase;
}

.eyebrow i {
    color: var(--accent-2);
}

.hero h1 {
    max-width: 700px;
    font-size: clamp(38px, 5.5vw, 68px);
    line-height: 1.08;
    letter-spacing: -3px;
    font-weight: 800;
}

.hero h1 span {
    color: var(--accent-2);
}

.hero p {
    max-width: 550px;
    margin-top: 20px;
    color: #d0cdd0;
    font-size: 15px;
    line-height: 1.9;
}

.hero-actions {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 13px;
    margin-top: 28px;
}

.btn {
    min-height: 46px;
    padding: 0 20px;
    border-radius: 12px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    border: 1px solid transparent;
    font-size: 13px;
    font-weight: 800;
    transition: transform .2s, background .2s;
}

.btn:hover {
    transform: translateY(-2px);
}

.btn-primary {
    color: #fff;
    background: linear-gradient(135deg, var(--accent), #c51f32);
    box-shadow: 0 10px 25px rgba(226,55,68,.22);
}

.btn-outline {
    color: #fff;
    background: rgba(255,255,255,.07);
    border-color: rgba(255,255,255,.2);
    backdrop-filter: blur(8px);
}

.page-content {
    max-width: 1440px;
    padding: 64px 5.5% 85px;
    margin: 0 auto;
}

.section-heading {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 20px;
    margin-bottom: 28px;
}

.section-kicker {
    color: var(--accent);
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 2px;
    text-transform: uppercase;
    margin-bottom: 11px;
}

.section-heading h2 {
    font-size: clamp(25px, 3vw, 36px);
    letter-spacing: -1.3px;
    font-weight: 800;
}

.section-heading p {
    color: var(--muted);
    font-size: 13px;
    line-height: 1.8;
    margin-top: 9px;
}

.date-chip {
    display: inline-flex;
    align-items: center;
    gap: 9px;
    color: var(--muted);
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 12px 15px;
    font-size: 12px;
    font-weight: 700;
}

.date-chip i {
    color: var(--accent);
}

.rewards-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 22px;
}

.reward-card {
    position: relative;
    min-height: 320px;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    overflow: hidden;
    isolation: isolate;
    padding: 25px;
    border-radius: 21px;
    border: 1px solid var(--border);
    background: var(--surface);
    box-shadow: var(--shadow);
    transition: transform .28s, border-color .28s;
}

.reward-card:hover {
    transform: translateY(-6px);
    border-color: rgba(226,55,68,.65);
}

.reward-card::before {
    content: "";
    position: absolute;
    inset: 0;
    z-index: -2;
    background-size: cover;
    background-position: center;
    transition: transform .5s;
}

.reward-card:hover::before {
    transform: scale(1.06);
}

.reward-card::after {
    content: "";
    position: absolute;
    inset: 0;
    z-index: -1;
    background: linear-gradient(180deg,
        rgba(9,9,11,.05) 0%,
        rgba(9,9,11,.25) 30%,
        rgba(9,9,11,.91) 72%,
        rgba(9,9,11,.98) 100%);
}

.reward-card.streak::before {
    background-image: url("https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=900&q=85");
}

.reward-card.birthday::before {
    background-image: url("https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=900&q=85");
}

.reward-card.daily::before {
    background-image: url("https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=85");
}

.reward-card.weekly::before {
    background-image: url("https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=85");
}

.reward-card.restaurant::before {
    background-image: url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=85");
}

.reward-card.challenge::before {
    background-image: url("https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=900&q=85");
}

.card-top {
    position: absolute;
    top: 18px;
    left: 18px;
    right: 18px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
}

.card-label {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    padding: 8px 11px;
    border-radius: 9px;
    color: #fff;
    background: rgba(13,13,15,.73);
    border: 1px solid rgba(255,255,255,.16);
    backdrop-filter: blur(10px);
    font-size: 10px;
    font-weight: 800;
    letter-spacing: .6px;
    text-transform: uppercase;
}

.card-label i {
    color: #ff6974;
}

.card-icon {
    width: 39px;
    height: 39px;
    display: grid;
    place-items: center;
    border-radius: 12px;
    color: #fff;
    background: rgba(226,55,68,.9);
    box-shadow: 0 7px 20px rgba(0,0,0,.2);
}

.reward-card h3 {
    color: #fff;
    font-size: 22px;
    font-weight: 800;
    letter-spacing: -.6px;
    margin-bottom: 10px;
}

.reward-card p {
    max-width: 360px;
    color: #d2d0d2;
    font-size: 12px;
    line-height: 1.8;
    margin-bottom: 20px;
}

.card-bottom {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
    padding-top: 15px;
    border-top: 1px solid rgba(255,255,255,.15);
}

.reward-value {
    color: #fff;
    font-size: 12px;
    font-weight: 800;
}

.reward-value span {
    color: #ff737d;
}

.card-link {
    color: #fff;
    font-size: 11px;
    font-weight: 800;
    display: inline-flex;
    align-items: center;
    gap: 7px;
}

.card-link i {
    color: #ff737d;
    transition: transform .2s;
}

.card-link:hover i {
    transform: translateX(4px);
}

.info-strip {
    display: flex;
    align-items: flex-start;
    gap: 14px;
    margin-top: 28px;
    padding: 20px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 15px;
}

.info-icon {
    width: 38px;
    height: 38px;
    flex-shrink: 0;
    display: grid;
    place-items: center;
    border-radius: 11px;
    color: #ff737d;
    background: rgba(226,55,68,.12);
}

.info-strip h4 {
    font-size: 13px;
    margin-bottom: 5px;
}

.info-strip p {
    color: var(--muted);
    font-size: 12px;
    line-height: 1.8;
}

.footer {
    padding: 28px 5.5%;
    border-top: 1px solid var(--border);
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 15px;
    color: var(--muted);
    font-size: 11px;
}

.footer strong {
    color: var(--accent);
}

.footer-links {
    display: flex;
    gap: 20px;
}

.footer-links a:hover {
    color: var(--text);
}

@media (max-width: 1050px) {
    .nav-links {
        gap: 15px;
    }

    .nav-links a {
        font-size: 12px;
    }

    .brightness-wrapper {
        display: none;
    }

    .rewards-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

@media (max-width: 720px) {
    .navbar {
        padding: 13px 5%;
    }

    .brand {
        font-size: 21px;
    }

    .nav-links {
        display: none;
        position: absolute;
        top: calc(100% + 1px);
        left: 0;
        right: 0;
        padding: 18px 5%;
        background: var(--nav);
        border-bottom: 1px solid var(--border);
        flex-direction: column;
        align-items: stretch;
        gap: 0;
        backdrop-filter: blur(20px);
    }

    .nav-links.open {
        display: flex;
    }

    .nav-links a {
        padding: 13px 0;
        font-size: 13px;
    }

    .nav-links a.active::after {
        display: none;
    }

    .mobile-menu {
        display: grid;
    }

    .hero {
        min-height: 390px;
        padding: 58px 6%;
    }

    .hero h1 {
        letter-spacing: -1.8px;
    }

    .hero p {
        font-size: 13px;
    }

    .page-content {
        padding: 45px 5% 60px;
    }

    .rewards-grid {
        gap: 15px;
    }

    .reward-card {
        min-height: 300px;
        padding: 19px;
        border-radius: 17px;
    }

    .reward-card h3 {
        font-size: 19px;
    }

    .card-top {
        top: 13px;
        left: 13px;
        right: 13px;
    }
}

@media (max-width: 520px) {
    .rewards-grid {
        grid-template-columns: 1fr;
    }

    .reward-card {
        min-height: 310px;
    }

    .hero-actions .btn {
        width: 100%;
    }

    .section-heading {
        align-items: flex-start;
    }

    .date-chip {
        width: 100%;
    }

    .footer {
        flex-direction: column;
        align-items: flex-start;
    }
}
</style>
</head>

<body>

<%
    String contextPath = request.getContextPath();
    LocalDate today = LocalDate.now();
%>

<nav class="navbar">

    <a class="brand" href="<%= contextPath %>/home.jsp">
        <span class="brand-icon"><i class="fa-solid fa-utensils"></i></span>
        <span>Smart<span>Bite</span></span>
    </a>

    <div class="nav-links" id="navLinks">
        <a href="<%= contextPath %>/home.jsp">Home</a>
        <a href="<%= contextPath %>/restaurants">Restaurants</a>
        <a href="<%= contextPath %>/orders.jsp">Orders</a>
        <a href="<%= contextPath %>/cart.jsp">Cart <i class="fa-solid fa-bag-shopping"></i></a>
        <a href="<%= contextPath %>/profile.jsp" class="profile-link">
            <span class="profile-icon"><i class="fa-solid fa-user"></i></span>Profile
        </a>
        <a href="<%= contextPath %>/Offers.jsp" class="active">Offers</a>
    </div>

    <div class="nav-actions">

        <div class="brightness-wrapper" aria-label="Adjust brightness">
            <i class="fa-solid fa-sun" aria-hidden="true"></i>
            <input class="brightness-control" type="range" min="70" max="120"
                   value="100" aria-label="Adjust brightness"
                   oninput="adjustBrightness(this.value)">
            <i class="fa-solid fa-moon" aria-hidden="true"></i>
        </div>

        <button class="icon-btn" type="button" onclick="toggleTheme()"
                aria-label="Toggle theme" title="Toggle theme">
            <i class="fa-solid fa-sun" id="themeIcon"></i>
        </button>

        <button class="icon-btn mobile-menu" type="button"
                onclick="toggleMenu()" aria-label="Open navigation">
            <i class="fa-solid fa-bars" id="menuIcon"></i>
        </button>

    </div>
</nav>

<header class="hero">
    <div class="hero-content">

        <div class="eyebrow">
            <i class="fa-solid fa-sparkles"></i>
            THE SMARTBITE PERKS CLUB
        </div>

        <h1>Good food.<br><span>Better rewards.</span></h1>

        <p>
            Your next delicious meal could come with something extra.
            Explore streak rewards, special occasions, weekly perks and
            restaurant promotions, all in one place.
        </p>

        <div class="hero-actions">

            <a class="btn btn-primary" href="#rewards">
                <i class="fa-solid fa-gift"></i> Explore Rewards
            </a>

            <a class="btn btn-outline" href="<%= contextPath %>/restaurants">
                <i class="fa-solid fa-utensils"></i> Order Something Good
            </a>

        </div>

    </div>
</header>

<main class="page-content" id="rewards">

    <div class="section-heading">

        <div>
            <div class="section-kicker">A little extra with every bite</div>
            <h2>Explore Offers &amp; Rewards</h2>
            <p>Discover the perks and promotions available in your SmartBite experience.</p>
        </div>

        <div class="date-chip">
            <i class="fa-regular fa-calendar"></i>
            <%= today.toString() %>
        </div>

    </div>

    <section class="rewards-grid">

        <article class="reward-card streak">

            <div class="card-top">
                <span class="card-label">
                    <i class="fa-solid fa-fire"></i> Build Your Streak
                </span>
                <span class="card-icon">
                    <i class="fa-solid fa-bolt"></i>
                </span>
            </div>

            <h3>Order Streak</h3>

            <p>
                Make ordering a delicious habit. Keep your streak going and work towards reward milestones.
            </p>

            <div class="card-bottom">
                <div class="reward-value">
                    Milestones <span>3 · 5 · 6 · 7 days</span>
                </div>

                <a class="card-link" href="<%= contextPath %>/orders.jsp">
                    View Orders <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>

        </article>

        <article class="reward-card birthday">

            <div class="card-top">
                <span class="card-label">
                    <i class="fa-solid fa-cake-candles"></i> Special Occasion
                </span>
                <span class="card-icon">
                    <i class="fa-solid fa-gift"></i>
                </span>
            </div>

            <h3>Birthday Special</h3>

            <p>
                Celebrate your special day with the idea of a birthday treat made just for you.
            </p>

            <div class="card-bottom">
                <div class="reward-value">
                    Birthday <span>Perk</span>
                </div>

                <span class="card-link">
                    Coming Soon <i class="fa-solid fa-heart"></i>
                </span>
            </div>

        </article>

        <article class="reward-card daily">

            <div class="card-top">
                <span class="card-label">
                    <i class="fa-solid fa-sun"></i> Everyday Perks
                </span>
                <span class="card-icon">
                    <i class="fa-solid fa-tag"></i>
                </span>
            </div>

            <h3>Daily Offers</h3>

            <p>
                Make everyday meals more exciting with daily deals and limited-time food promotions.
            </p>

            <div class="card-bottom">
                <div class="reward-value">
                    Daily <span>Deals</span>
                </div>

                <a class="card-link" href="<%= contextPath %>/restaurants">
                    Browse Food <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>

        </article>

        <article class="reward-card weekly">

            <div class="card-top">
                <span class="card-label">
                    <i class="fa-solid fa-calendar-week"></i> Weekly Perks
                </span>
                <span class="card-icon">
                    <i class="fa-solid fa-star"></i>
                </span>
            </div>

            <h3>Weekly Rewards</h3>

            <p>
                Look forward to weekly challenges and rewards designed to make your food journey more fun.
            </p>

            <div class="card-bottom">
                <div class="reward-value">
                    Every <span>Week</span>
                </div>

                <span class="card-link">
                    Coming Soon <i class="fa-solid fa-arrow-right"></i>
                </span>
            </div>

        </article>

        <article class="reward-card restaurant">

            <div class="card-top">
                <span class="card-label">
                    <i class="fa-solid fa-store"></i> Restaurant News
                </span>
                <span class="card-icon">
                    <i class="fa-solid fa-bullhorn"></i>
                </span>
            </div>

            <h3>Restaurant Specials</h3>

            <p>
                Discover the concept of restaurant anniversaries, new food launches and special event promotions.
            </p>

            <div class="card-bottom">
                <div class="reward-value">
                    Local <span>Highlights</span>
                </div>

                <a class="card-link" href="<%= contextPath %>/restaurants">
                    Explore Places <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>

        </article>

        <article class="reward-card challenge">

            <div class="card-top">
                <span class="card-label">
                    <i class="fa-solid fa-trophy"></i> Your Next Goal
                </span>
                <span class="card-icon">
                    <i class="fa-solid fa-medal"></i>
                </span>
            </div>

            <h3>Reward Challenges</h3>

            <p>
                Set yourself a goal, explore different meals and work towards future SmartBite reward challenges.
            </p>

            <div class="card-bottom">
                <div class="reward-value">
                    Your <span>Journey</span>
                </div>

                <a class="card-link" href="<%= contextPath %>/orders.jsp">
                    View Orders <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>

        </article>

    </section>

    <div class="info-strip">

        <div class="info-icon">
            <i class="fa-solid fa-circle-info"></i>
        </div>

        <div>
            <h4>About these rewards</h4>

            <p>
                This page currently presents the Offers &amp; Rewards UI.
                Birthday discounts, promotional codes, eligibility checks and reward redemption
                need to be connected to backend offer rules before they can be claimed.
            </p>
        </div>

    </div>

</main>

<footer class="footer">

    <div>Made with <strong>♥</strong> by SmartBite</div>

    <div class="footer-links">
        <a href="<%= contextPath %>/home.jsp">Home</a>
        <a href="<%= contextPath %>/restaurants">Restaurants</a>
        <a href="<%= contextPath %>/cart.jsp">Cart</a>
    </div>

    <div>&copy; <%= today.getYear() %> SmartBite</div>

</footer>

<script>

function toggleTheme() {
    const isLight = document.body.classList.toggle('light-mode');

    localStorage.setItem(
        'smartbite_theme',
        isLight ? 'light' : 'dark'
    );

    updateThemeButtonUI();
}

function updateThemeButtonUI() {

    const icon = document.getElementById('themeIcon');
    const isLight = document.body.classList.contains('light-mode');

    if (icon) {
        icon.className = isLight
            ? 'fa-solid fa-moon'
            : 'fa-solid fa-sun';
    }
}

function adjustBrightness(value) {

    document.body.style.filter =
        'brightness(' + (Number(value) / 100) + ')';

    localStorage.setItem(
        'smartbite_brightness',
        value
    );
}

function toggleMenu() {

    const links = document.getElementById('navLinks');
    const icon = document.getElementById('menuIcon');

    links.classList.toggle('open');

    if (icon) {
        icon.className = links.classList.contains('open')
            ? 'fa-solid fa-xmark'
            : 'fa-solid fa-bars';
    }
}

(function initialiseAppearance() {

    const savedTheme =
        localStorage.getItem('smartbite_theme');

    const savedBrightness =
        localStorage.getItem('smartbite_brightness');

    if (savedTheme === 'light') {
        document.body.classList.add('light-mode');
    }

    if (savedBrightness) {

        document.body.style.filter =
            'brightness(' + (Number(savedBrightness) / 100) + ')';

        const slider =
            document.querySelector('.brightness-control');

        if (slider) {
            slider.value = savedBrightness;
        }
    }

    updateThemeButtonUI();

})();

</script>

</body>
</html>