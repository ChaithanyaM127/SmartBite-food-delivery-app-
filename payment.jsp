
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="com.foodtap.util.DBConnection" %>
<%@ page import="com.foodtap.dao.HealthSummaryDAO" %>
<%@ page import="com.foodtap.daoimpl.HealthSummaryDAOImpl" %>
<%@ page import="com.foodtap.model.HealthSummary" %>
<%@ page import="com.foodtap.model.User" %>
<%@ page import="com.foodtap.model.CartItem" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User loggedInUser = (User) session.getAttribute("loggedInUser");

    HealthSummary healthSummary =
        (HealthSummary) request.getAttribute("healthSummary");

    if (healthSummary == null && loggedInUser != null
            && loggedInUser.getUserId() > 0) {
        try {
            HealthSummaryDAO healthDAO = new HealthSummaryDAOImpl();
            healthSummary =
                healthDAO.getTodayHealthSummary(loggedInUser.getUserId());
        } catch (Exception e) {
            application.log("Unable to load today's health summary.", e);
        }
    }

    if (healthSummary == null) {
        healthSummary = new HealthSummary();
        healthSummary.setCalorieGoal(1500);
        healthSummary.setCalories(0);
        healthSummary.setCaloriesRemaining(1500);
        healthSummary.setPercentageConsumed(0);
        healthSummary.setProtein(0);
        healthSummary.setCarbs(0);
        healthSummary.setFiber(0);
    }

    float healthCalories = healthSummary.getCalories();
    float healthGoal = healthSummary.getCalorieGoal();

    if (healthGoal <= 0) {
        healthGoal = 1500;
    }

    float healthRemaining = Math.max(0, healthGoal - healthCalories);
    float healthPercentage = Math.min(100,
        Math.max(0, (healthCalories / healthGoal) * 100));

    int circlePercentage = Math.round(healthPercentage);

    String healthQuote;

    if (healthCalories <= 0) {
        healthQuote = "🔥 Fuel your hustle! Pick a balanced meal to start your day.";
    } else if (healthCalories < healthGoal * 0.5f) {
        healthQuote = "⚡ You're making a start! Explore a nutrient-packed dish.";
    } else if (healthCalories < healthGoal * 0.85f) {
        healthQuote = "🎯 Great progress! Smart choices help keep you energized.";
    } else if (healthCalories <= healthGoal) {
        healthQuote = "✨ You're approaching your daily goal. Choose thoughtfully.";
    } else {
        healthQuote = "🏆 You've reached your calorie goal. Explore lighter options if suitable.";
    }

    ZoneId indiaZone = ZoneId.of("Asia/Kolkata");
    LocalTime now = LocalTime.now(indiaZone);
    LocalDate today = LocalDate.now(indiaZone);

    String todayLabel =
        today.format(DateTimeFormatter.ofPattern("EEE, dd MMM"));

    /*
     * DYNAMIC USER ORDER STREAK
     *
     * Uses the existing orders table.
     * Each distinct calendar day counts once.
     * Current streak remains active when the latest qualifying
     * order day is today or yesterday.
     *
     * Current qualifying status: PLACED.
     */

    int currentOrderStreak = 0;
    int nextStreakMilestone = 0;
    int[] streakMilestones = {1, 2, 3, 4, 5, 6, 7};

    if (loggedInUser != null && loggedInUser.getUserId() > 0) {
        List<LocalDate> orderDays = new ArrayList<>();

        String streakSQL =
            "SELECT DISTINCT DATE(orderDate) AS order_day " +
            "FROM orders " +
            "WHERE userId = ? " +
            "AND status = 'PLACED' " +
            "AND orderDate IS NOT NULL " +
            "ORDER BY order_day DESC";

        Connection streakCon = null;
        try {
            streakCon = DBConnection.getConnection();

            if (streakCon == null) {
                application.log("Unable to calculate SmartBite order streak: database connection is unavailable.");
            } else {
                try (PreparedStatement streakPS = streakCon.prepareStatement(streakSQL)) {
                    streakPS.setInt(1, loggedInUser.getUserId());

                    try (ResultSet streakRS = streakPS.executeQuery()) {
                        while (streakRS.next()) {
                            java.sql.Date orderDate = streakRS.getDate("order_day");

                            if (orderDate != null) {
                                LocalDate orderDay = orderDate.toLocalDate();
                                if (!orderDay.isAfter(today)) {
                                    orderDays.add(orderDay);
                                }
                            }
                        }
                    }
                }
            }

            if (!orderDays.isEmpty()) {
                LocalDate latestOrderDay = orderDays.get(0);

                if (!latestOrderDay.isBefore(today.minusDays(1))) {
                    currentOrderStreak = 1;
                    LocalDate previousDay = latestOrderDay;

                    for (int i = 1; i < orderDays.size(); i++) {
                        LocalDate orderDay = orderDays.get(i);

                        if (previousDay.minusDays(1).equals(orderDay)) {
                            currentOrderStreak++;
                            previousDay = orderDay;
                        } else {
                            break;
                        }
                    }
                }
            }

        } catch (Exception e) {
            application.log("Unable to calculate SmartBite order streak.", e);
        } finally {
            if (streakCon != null) {
                try {
                    streakCon.close();
                } catch (Exception closeException) {
                    application.log("Unable to close SmartBite streak database connection.", closeException);
                }
            }
        }
    }

    for (int milestone : streakMilestones) {
        if (currentOrderStreak < milestone) {
            nextStreakMilestone = milestone;
            break;
        }
    }

    boolean sevenDayMilestoneReached = currentOrderStreak >= 7;

    String[] streakRewardNames = {
        "5% OFF", "10% OFF", "15% OFF", "20% OFF",
        "25% OFF", "30% OFF", "40% OFF"
    };
    String[] streakCouponCodes = {
        "BITE5", "BITE10", "BITE15", "SMART20",
        "SMART25", "SMART30", "SMART40"
    };
    int[] streakRewardDays = {1, 2, 3, 4, 5, 6, 7};
    int activeRewardIndex = -1;
    if (loggedInUser != null && currentOrderStreak >= 1) {
        activeRewardIndex = Math.min(currentOrderStreak, 7) - 1;
    }

    /*
     * The current restaurant schema does not contain individual
     * opening and closing times, so the existing common schedule
     * is preserved.
     */
    LocalTime openTime = LocalTime.of(10, 0);
    LocalTime closeTime = LocalTime.of(23, 0);

    boolean isRestaurantOpen =
        !now.isBefore(openTime) && !now.isAfter(closeTime);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>SmartBite | Discover &amp; Order Food</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<style>
:root {
    --bg-page: #0d0d0f;
    --bg-card-dark: #121318;
    --bg-card-bottom: #1e1e24;
    --text-main: #ffffff;
    --text-muted: #a1a1aa;
    --text-bottom-main: #f4f4f5;
    --text-bottom-sub: #a1a1aa;
    --nav-bg: rgba(13,13,15,.90);
    --nav-border: rgba(255,255,255,.08);
    --panel-border: rgba(255,255,255,.08);
    --metric-bg: rgba(255,255,255,.04);
    --accent: #e23744;
    --accent-glow: rgba(226,55,68,.35);
    --accent-gradient: linear-gradient(135deg,#ff4757,#e23744);
    --green-badge: #24963f;
    --shadow: 0 16px 36px rgba(0,0,0,.4);
}

body.light-mode {
    --bg-page: #f1f3f5;
    --bg-card-dark: #ffffff;
    --bg-card-bottom: #ffffff;
    --text-main: #111827;
    --text-muted: #6b7280;
    --text-bottom-main: #111827;
    --text-bottom-sub: #4b5563;
    --nav-bg: rgba(255,255,255,.95);
    --nav-border: rgba(0,0,0,.08);
    --panel-border: rgba(0,0,0,.08);
    --metric-bg: rgba(0,0,0,.03);
    --shadow: 0 10px 25px rgba(0,0,0,.06);
}

* { box-sizing: border-box; }

html, body {
    margin: 0;
    padding: 0;
    min-height: 100vh;
    overflow-x: hidden;
    background: var(--bg-page);
    color: var(--text-main);
    font-family: 'Plus Jakarta Sans', sans-serif;
}

html { scroll-behavior: smooth; }

a, button, input { font-family: inherit; }

.navbar {
    background: var(--nav-bg);
    backdrop-filter: blur(12px);
    border-bottom: 1px solid var(--nav-border);
    position: sticky;
    top: 0;
    z-index: 1000;
    width: 100%;
}

.nav-container {
    max-width: 1320px;
    margin: auto;
    padding: 14px 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
}

.logo {
    font-size: 26px;
    font-weight: 800;
    color: var(--text-main);
    text-decoration: none;
    letter-spacing: -.5px;
}

.logo span { color: var(--accent); }

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

.nav-links a:hover,
.nav-links a.active { color: var(--accent); }

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

/* CINEMATIC HERO BACKGROUND */

.hero-section {
    position: relative;
    isolation: isolate;
    overflow: hidden;
    background:
        linear-gradient(90deg,
            rgba(8,7,8,.95) 0%,
            rgba(10,8,9,.84) 44%,
            rgba(10,8,9,.32) 100%),
        linear-gradient(0deg,rgba(13,13,15,.8),transparent 50%),
        url('https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=2000&q=90');
    background-size: cover;
    background-position: center 48%;
    color: white;
    padding: 100px 24px 90px;
    min-height: 470px;
    display: flex;
    align-items: center;
    border-bottom: 1px solid var(--panel-border);
}

.hero-section::after {
    content: "";
    position: absolute;
    z-index: -1;
    width: 420px;
    height: 420px;
    right: -130px;
    bottom: -240px;
    border-radius: 50%;
    background: rgba(226,55,68,.25);
    filter: blur(100px);
}

.hero-content {
    max-width: 1320px;
    width: 100%;
    margin: auto;
    position: relative;
    z-index: 1;
}

.hero-eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 9px;
    padding: 9px 14px;
    border: 1px solid rgba(255,255,255,.23);
    border-radius: 30px;
    background: rgba(255,255,255,.09);
    color: #fff;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    margin-bottom: 22px;
}

.hero-content h1 {
    max-width: 760px;
    font-size: clamp(38px,5.6vw,68px);
    font-weight: 800;
    margin: 0 0 18px;
    line-height: 1.08;
    letter-spacing: -2px;
    color: white;
}

.hero-content h1 span { color: #ff5969; }

.hero-content p {
    max-width: 600px;
    font-size: 15px;
    margin-bottom: 28px;
    color: #e2e8f0;
    line-height: 1.9;
}

 .hero-buttons {
    display: flex;
    gap: 14px;
    flex-wrap: wrap;
}

/* HOMEPAGE ORDER-STREAK CARD — compact SmartBite hero styling */
.hero-streak-card {
    width: min(100%, 590px);
    display: block;
    margin: 0 0 22px;
    padding: 14px 16px;
    border: 1px solid rgba(255,255,255,.16);
    border-radius: 16px;
    background: linear-gradient(115deg,rgba(18,18,22,.97),rgba(48,22,28,.94));
    color: #fff;
    text-align: left;
    box-shadow: 0 12px 30px rgba(0,0,0,.22);
    transition: border-color .2s ease,box-shadow .2s ease;
}

.hero-streak-card:hover {
    border-color: rgba(255,105,119,.55);
    box-shadow: 0 15px 32px rgba(0,0,0,.28),0 0 0 2px rgba(226,55,68,.08);
}

.hero-streak-top {
    display: flex;
    align-items: center;
    gap: 12px;
}

.hero-streak-flame {
    width: 38px;
    height: 38px;
    flex: 0 0 38px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    background: rgba(226,55,68,.2);
    border: 1px solid rgba(255,105,119,.3);
    font-size: 21px;
}

.hero-streak-summary { flex: 1; min-width: 0; }

.hero-streak-label {
    display: block;
    margin-bottom: 4px;
    color: #ffb6bd;
    font-size: 9px;
    font-weight: 800;
    letter-spacing: 1.35px;
    text-transform: uppercase;
}

.hero-streak-title {
    display: block;
    color: #fff;
    font-size: 16px;
    font-weight: 800;
    line-height: 1.4;
}

.hero-streak-subtitle {
    display: block;
    margin-top: 3px;
    color: rgba(255,255,255,.72);
    font-size: 11px;
    line-height: 1.6;
}

.hero-streak-arrow {
    flex: 0 0 auto;
    color: #ff9ba5;
    font-size: 22px;
    padding-left: 5px;
}

.hero-streak-days {
    display: grid;
    grid-template-columns: repeat(7,minmax(0,1fr));
    gap: 5px;
    margin-top: 12px;
}

.hero-streak-day { min-width: 0; text-align: center; }

.hero-streak-day-mark {
    display: flex;
    width: 31px;
    max-width: 31px;
    height: 31px;
    margin: 0 auto 5px;
    align-items: center;
    justify-content: center;
    border: 1px solid rgba(255,255,255,.2);
    border-radius: 50%;
    background: rgba(255,255,255,.07);
    color: rgba(255,255,255,.8);
    font-size: 15px;
    font-weight: 800;
}

.hero-streak-day-mark.completed {
    border-color: #e85d6b;
    background: #c82e40;
    color: #fff;
}

.hero-streak-day-mark.milestone:not(.completed) {
    border-color: rgba(255,191,113,.7);
    color: #ffd29a;
}

.hero-streak-day-label {
    color: rgba(255,255,255,.62);
    font-size: 9px;
    font-weight: 700;
}

.hero-streak-reward {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 12px;
    padding: 9px 10px;
    border: 1px solid rgba(255,190,111,.22);
    border-radius: 11px;
    background: rgba(255,190,111,.07);
    color: #fff;
    font-size: 11px;
    line-height: 1.5;
}

.hero-streak-reward-icon { color: #ffd08c; font-size: 16px; }
.hero-streak-reward strong { color: #ffd08c; }
.hero-streak-reward-copy { flex: 1 1 170px; min-width: 0; }
.hero-streak-coupon-code {
    display: inline-flex;
    align-items: center;
    margin: 4px 5px 0 0;
    padding: 4px 8px;
    border: 1px dashed rgba(255,155,165,.55);
    border-radius: 6px;
    background: rgba(15,15,19,.75);
    color: #fff;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .7px;
}
.hero-streak-copy-button {
    flex: 0 0 auto;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 8px 10px;
    border: 1px solid #e23744;
    border-radius: 8px;
    background: #e23744;
    color: #fff;
    font-family: inherit;
    font-size: 9px;
    font-weight: 800;
    letter-spacing: .55px;
    cursor: pointer;
    transition: background .2s ease,transform .2s ease;
}
.hero-streak-copy-button:hover:not(:disabled) { background: #c92b39; transform: translateY(-1px); }
.hero-streak-copy-button:focus-visible { outline: 2px solid #ff9ba5; outline-offset: 2px; }
.hero-streak-copy-button:disabled {
    opacity: .48;
    cursor: not-allowed;
    filter: grayscale(.25);
    box-shadow: none;
}
.hero-streak-reward-link {
    flex: 0 0 auto;
    padding: 0;
    border: 0;
    background: transparent;
    color: #ffb3bc;
    font: inherit;
    font-weight: 800;
    white-space: nowrap;
    cursor: pointer;
}
.hero-streak-reward-link:hover { color: #fff; }

.btn-primary, .btn-secondary {
    padding: 14px 24px;
    border-radius: 12px;
    font-weight: 800;
    font-size: 13px;
    text-decoration: none;
    cursor: pointer;
    border: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    transition: transform .2s ease,background .2s ease;
}

.btn-primary {
    background: var(--accent-gradient);
    color: white;
    box-shadow: 0 10px 25px var(--accent-glow);
}

.btn-secondary {
    background: rgba(0,0,0,.48);
    color: white;
    border: 1px solid rgba(255,255,255,.25);
}

.btn-primary:hover, .btn-secondary:hover {
    transform: translateY(-3px);
}

/* THREE-SLIDE CINEMATIC CAROUSEL */

.offers-section {
    max-width: 1320px;
    width: 100%;
    margin: 36px auto 42px;
    padding: 0 24px;
}

.offers-carousel {
    position: relative;
    overflow: hidden;
    isolation: isolate;
    min-height: 365px;
    border-radius: 24px;
    border: 1px solid rgba(255,255,255,.12);
    background: #100c0d;
    box-shadow: 0 25px 65px rgba(0,0,0,.45);
}

.offer-slide {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    min-height: 365px;
    padding: 48px 82px 66px;
    overflow: hidden;
    color: white;
    background-size: cover;
    background-position: center;
    opacity: 0;
    visibility: hidden;
    transform: scale(1.025);
    transition: opacity .65s ease, transform 1s ease, visibility .65s;
}

.offer-slide.active {
    position: relative;
    opacity: 1;
    visibility: visible;
    transform: scale(1);
}

.offer-slide::before {
    content: "";
    position: absolute;
    inset: 0;
    z-index: 0;
    background: linear-gradient(
        90deg,
        rgba(9,7,8,.97),
        rgba(12,7,9,.88) 38%,
        rgba(14,7,8,.35) 75%,
        rgba(10,6,7,.15)
    );
}

.offer-slide.offer-signature {
    background-image: url('https://images.unsplash.com/photo-1563379091339-03246963d96c?auto=format&fit=crop&w=1800&q=85');
}

.offer-slide.offer-discovery {
    background-image: url('https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1800&q=85');
}

.offer-slide.offer-rewards {
    background-image: url('https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=1800&q=85');
}

.offer-copy {
    position: relative;
    z-index: 2;
    max-width: 590px;
}

.offer-label {
    display: inline-flex;
    align-items: center;
    gap: 9px;
    padding: 9px 13px;
    border: 1px solid rgba(255,255,255,.23);
    border-radius: 30px;
    background: rgba(255,255,255,.085);
    color: white;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 1.5px;
    text-transform: uppercase;
}

.offer-copy h2 {
    margin: 22px 0 15px;
    font-size: clamp(35px,4.3vw,57px);
    font-weight: 800;
    line-height: 1.08;
    letter-spacing: -2px;
    color: white;
}

.offer-copy h2 span {
    color: #ff4b5d;
    display: block;
}

.offer-copy p {
    margin: 0;
    max-width: 470px;
    color: rgba(255,255,255,.8);
    font-size: 14px;
    line-height: 1.85;
}

.offer-actions {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 17px;
    margin-top: 27px;
}

.offer-cta {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 13px;
    min-height: 48px;
    padding: 0 21px;
    border-radius: 9px;
    border: 1px solid #ff4b5d;
    background: linear-gradient(135deg,#ff4b5d,#d81f38);
    color: white;
    font-size: 12px;
    font-weight: 800;
    text-decoration: none;
    transition: transform .2s ease;
}

.offer-cta:hover { transform: translateY(-3px); }

.offer-note {
    color: rgba(255,255,255,.8);
    font-size: 11px;
    font-weight: 700;
}

.offer-nav {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    z-index: 5;
    width: 42px;
    height: 42px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1px solid rgba(255,255,255,.28);
    border-radius: 50%;
    background: rgba(15,12,13,.58);
    color: white;
    font-size: 26px;
    cursor: pointer;
}

.offer-nav:hover { background: var(--accent); }
.offer-prev { left: 18px; }
.offer-next { right: 18px; }

.offer-bottom-row {
    position: absolute;
    z-index: 4;
    left: 82px;
    right: 82px;
    bottom: 23px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    pointer-events: none;
}

.offer-bottom-caption {
    color: rgba(255,255,255,.65);
    font-size: 9px;
    font-weight: 800;
    letter-spacing: 2px;
}

.offer-dots {
    display: flex;
    gap: 7px;
    pointer-events: auto;
}

.offer-dot {
    width: 7px;
    height: 7px;
    padding: 0;
    border: none;
    border-radius: 10px;
    background: rgba(255,255,255,.45);
    cursor: pointer;
}

.offer-dot.active {
    width: 27px;
    background: #ff4b5d;
}

.offer-counter {
    color: white;
    font-size: 11px;
    font-weight: 800;
}

.offer-counter span { color: #ff6876; }

/* OFFERS AND REWARDS */

.main-container {
    max-width: 1320px;
    margin: 40px auto;
    padding: 0 24px;
    width: 100%;
}

.rewards-section {
    display: none;
    position: relative;
    margin: 0 0 55px;
}

.rewards-section.rewards-visible {
    display: block;
}

.rewards-section::before {
    content: "";
    position: absolute;
    inset: -30px -24px;
    z-index: -1;
    pointer-events: none;
    background:
        radial-gradient(ellipse at 10% 15%,rgba(226,55,68,.13),transparent 45%),
        radial-gradient(ellipse at 90% 85%,rgba(255,126,45,.09),transparent 45%);
}

.rewards-intro {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    gap: 20px;
    margin-bottom: 22px;
}

.rewards-intro h2 {
    margin: 0 0 8px;
    font-size: clamp(23px,3vw,30px);
    font-weight: 800;
    letter-spacing: -.8px;
}

.rewards-intro p {
    margin: 0;
    color: var(--text-muted);
    font-size: 13px;
    line-height: 1.8;
}

.date-chip {
    white-space: nowrap;
    padding: 9px 13px;
    border: 1px solid var(--panel-border);
    border-radius: 25px;
    background: var(--metric-bg);
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 800;
}

.rewards-grid {
    display: grid;
    grid-template-columns: repeat(3,minmax(0,1fr));
    gap: 20px;
}

.reward-card {
    position: relative;
    min-height: 300px;
    overflow: hidden;
    isolation: isolate;
    padding: 25px;
    border: 1px solid rgba(255,255,255,.12);
    border-radius: 20px;
    background-color: #171419;
    background-size: cover;
    background-position: center;
    box-shadow: 0 18px 40px rgba(0,0,0,.24);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transition: transform .25s ease,border-color .25s ease;
}

.reward-card::before {
    content: "";
    position: absolute;
    inset: 0;
    z-index: -1;
    background: linear-gradient(
        155deg,
        rgba(12,12,15,.66),
        rgba(12,12,15,.94) 76%
    );
}

.reward-card:hover {
    transform: translateY(-5px);
    border-color: rgba(255,75,93,.7);
}

.reward-card.streak {
    background-image: url('https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=1000&q=85');
}

.reward-card.birthday {
    background-image: url('https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=1000&q=85');
}

.reward-card.restaurant-deals {
    background-image: url('https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1000&q=85');
}

.reward-card.weekly-deals {
    background-image: url('https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1000&q=85');
}

.reward-card.promotions {
    background-image: url('https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1000&q=85');
}

.reward-card.reward-challenges {
    background-image: url('https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=1000&q=85');
}

.reward-card-content,
.reward-card-footer {
    position: relative;
    z-index: 1;
}

.reward-icon {
    width: 50px;
    height: 50px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 15px;
    background: rgba(255,255,255,.13);
    border: 1px solid rgba(255,255,255,.2);
    font-size: 25px;
    margin-bottom: 18px;
}

.reward-status {
    display: inline-block;
    padding: 7px 10px;
    border-radius: 20px;
    background: rgba(226,55,68,.2);
    border: 1px solid rgba(255,110,120,.24);
    color: #ffb0b7;
    font-size: 9px;
    font-weight: 800;
    letter-spacing: 1px;
    text-transform: uppercase;
    margin-bottom: 12px;
}

.reward-card h3 {
    margin: 0 0 11px;
    font-size: 21px;
    line-height: 1.35;
    font-weight: 800;
    color: #fff;
}

.reward-card p {
    margin: 0;
    max-width: 380px;
    font-size: 12px;
    line-height: 1.85;
    color: rgba(255,255,255,.84);
}

.reward-card-footer {
    margin-top: 22px;
    padding-top: 15px;
    border-top: 1px solid rgba(255,255,255,.18);
    color: rgba(255,255,255,.76);
    font-size: 10px;
    line-height: 1.8;
    font-weight: 700;
}

.streak-progress {
    display: grid;
    grid-template-columns: repeat(7,minmax(0,1fr));
    gap: 5px;
    margin-top: 17px;
}

.streak-rewards-list {
    display: grid;
    gap: 8px;
    margin-top: 18px;
}

.streak-reward-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    padding: 10px 11px;
    border: 1px solid rgba(255,255,255,.16);
    border-radius: 10px;
    background: rgba(0,0,0,.24);
    color: rgba(255,255,255,.9);
    font-size: 11px;
    font-weight: 700;
}

.streak-reward-row .streak-reward-name { min-width: 0; }

.streak-reward-row .streak-reward-status {
    flex-shrink: 0;
    color: #ffb0b7;
    font-size: 9px;
    font-weight: 800;
    letter-spacing: .5px;
    text-transform: uppercase;
}

.streak-reward-row.earned {
    border-color: rgba(74,222,128,.42);
    background: rgba(36,150,63,.17);
}

.streak-reward-row.earned .streak-reward-status { color: #86efac; }

.streak-day {
    min-width: 0;
    text-align: center;
    color: rgba(255,255,255,.72);
    font-size: 9px;
    font-weight: 800;
}

.streak-day span {
    display: flex;
    min-height: 31px;
    align-items: center;
    justify-content: center;
    margin-bottom: 6px;
    border: 1px solid rgba(255,255,255,.2);
    border-radius: 8px;
    background: rgba(255,255,255,.08);
    color: #fff;
    font-size: 12px;
}

.streak-day span.milestone {
    border-color: rgba(255,116,65,.65);
    background: rgba(226,55,68,.22);
}

.streak-day span.completed {
    border-color: rgba(74,222,128,.65);
    background: rgba(36,150,63,.28);
    color: #86efac;
}

.reward-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-top: 17px;
    color: #ff9aa4;
    text-decoration: none;
    font-size: 12px;
    font-weight: 800;
}

.reward-link:hover { color: #fff; }

/* RESTAURANTS */

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    gap: 12px;
    margin-bottom: 20px;
}

.section-header h2 {
    font-size: 24px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -.5px;
    margin: 0;
}

.section-header a {
    color: var(--accent);
    text-decoration: none;
    font-weight: 800;
    font-size: 13px;
}

.restaurant-grid-wrapper {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
    margin: 0;
    padding: 0;
    gap: 0;
}

.restaurant-square-card {
    width: 25%;
    box-sizing: border-box;
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    overflow: hidden;
    background: var(--bg-card-dark);
    text-decoration: none;
    display: flex;
    flex-direction: column;
    cursor: pointer;
    transition: transform .2s ease,border-color .2s ease;
    box-shadow: var(--shadow);
}

.restaurant-square-card:hover {
    border-color: var(--accent);
    transform: translateY(-3px);
}

.card-part-top-black {
    background: #0d0d0f;
    color: white;
    padding-bottom: 12px;
    position: relative;
}

.card-img-box {
    position: relative;
    height: 180px;
    width: 100%;
    background: #000;
    overflow: hidden;
}

.card-img-box img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform .4s ease;
}

.restaurant-square-card:hover .card-img-box img {
    transform: scale(1.05);
}

.rating-badge {
    position: absolute;
    top: 10px;
    right: 10px;
    background: #24963f;
    color: white;
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
    color: white;
    text-transform: uppercase;
    letter-spacing: .5px;
}

.status-badge.open { background: #24963f; }
.status-badge.closed { background: #e23744; }

.restaurant-title-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 12px 14px 0;
}

.restaurant-title {
    font-size: 17px;
    font-weight: 800;
    color: white;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.card-part-bottom-charcoal {
    background: var(--bg-card-bottom);
    color: var(--text-bottom-main);
    padding: 12px 14px 14px;
    display: flex;
    flex-direction: column;
    flex: 1;
    border-top: 1px solid var(--panel-border);
}

.cuisine-text {
    font-size: 13px;
    color: var(--text-bottom-sub);
    margin: 0 0 8px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.timing-text {
    font-size: 12px;
    font-weight: 700;
    color: #059669;
    margin-bottom: 12px;
}

.meta-footer-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 8px;
    border-top: 1px solid var(--panel-border);
    padding-top: 10px;
    margin-top: auto;
}

.delivery-time {
    font-size: 12px;
    color: var(--text-bottom-sub);
    font-weight: 600;
}

.view-menu-btn-red {
    background: #e23744;
    color: white;
    padding: 7px 13px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 800;
    white-space: nowrap;
}

/* HEALTH DASHBOARD */

.health-weather-grid {
    display: grid;
    grid-template-columns: 1.8fr 1.2fr;
    gap: 24px;
    margin-top: 50px;
}

.panel-health {
    background:
        linear-gradient(rgba(13,13,15,.88),rgba(13,13,15,.96)),
        url('https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=1200&q=80');
    background-size: cover;
    background-position: center;
    border: 1px solid var(--panel-border);
    border-radius: 20px;
    padding: 26px;
    box-shadow: var(--shadow);
    position: relative;
    overflow: hidden;
}

body.light-mode .panel-health {
    background:
        linear-gradient(rgba(255,255,255,.92),rgba(248,250,252,.96)),
        url('https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=1200&q=80');
    background-size: cover;
}

.health-quote-banner {
    background: rgba(226,55,68,.15);
    border: 1px solid rgba(226,55,68,.35);
    border-radius: 12px;
    padding: 12px 16px;
    font-size: 13px;
    font-weight: 700;
    color: #e23744;
    margin-bottom: 22px;
}

.calorie-progress-container {
    display: flex;
    align-items: center;
    gap: 24px;
    margin-bottom: 24px;
}

.conic-ring-box {
    position: relative;
    width: 100px;
    height: 100px;
    flex-shrink: 0;
    border-radius: 50%;
    background: conic-gradient(
        var(--accent) <%= circlePercentage %>%,
        rgba(128,128,128,.18) 0
    );
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 0 18px var(--accent-glow);
}

.conic-ring-box::before {
    content: "";
    position: absolute;
    inset: 10px;
    background: var(--bg-card-dark);
    border-radius: 50%;
}

.conic-ring-text {
    position: relative;
    z-index: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
}

.conic-ring-text strong {
    font-size: 20px;
    font-weight: 800;
    color: var(--text-main);
}

.conic-ring-text span {
    font-size: 10px;
    color: var(--text-muted);
    font-weight: 700;
    text-transform: uppercase;
}

.nutrition-metrics {
    display: grid;
    grid-template-columns: repeat(3,minmax(0,1fr));
    gap: 12px;
}

.metric-card-enhanced {
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    padding: 14px 10px;
    border-radius: 14px;
    text-align: center;
}

.metric-card-enhanced span {
    font-size: 10px;
    color: var(--text-muted);
    font-weight: 800;
    letter-spacing: .8px;
    text-transform: uppercase;
    display: block;
    margin-bottom: 4px;
}

.metric-card-enhanced strong {
    font-size: 18px;
    font-weight: 800;
    color: var(--text-main);
}

/* LIVE BENGALURU WEATHER */

.panel-weather-animated {
    background:
        linear-gradient(rgba(15,23,42,.78),rgba(15,23,42,.96)),
        url('https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=1200&q=80');
    background-size: cover;
    background-position: center;
    border: 1px solid var(--panel-border);
    border-radius: 20px;
    padding: 26px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    box-shadow: var(--shadow);
    color: white;
    min-height: 280px;
}

.weather-live-indicator {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 1px;
    background: rgba(36,150,63,.25);
    color: #4ade80;
    padding: 5px 12px;
    border-radius: 20px;
    border: 1px solid rgba(74,222,128,.4);
}

.live-dot {
    width: 6px;
    height: 6px;
    background: #4ade80;
    border-radius: 50%;
    animation: liveBlink 1.5s infinite;
}

@keyframes liveBlink {
    0%,100% { opacity: 1; }
    50% { opacity: .3; }
}

.weather-temp-hero {
    font-size: 42px;
    font-weight: 800;
    color: white;
    margin: 12px 0 2px;
    letter-spacing: -1px;
    display: flex;
    align-items: center;
    gap: 14px;
}

.weather-icon-3d-animated {
    width: 58px;
    height: 58px;
    object-fit: contain;
    filter: drop-shadow(0 10px 15px rgba(255,184,0,.4));
    animation: float3DIcon 3.5s ease-in-out infinite;
}

@keyframes float3DIcon {
    0%,100% { transform: translateY(0); }
    50% { transform: translateY(-7px); }
}

.weather-condition-desc {
    font-size: 14px;
    font-weight: 600;
    color: #cbd5e1;
}

.weather-quote-box {
    background: rgba(255,255,255,.08);
    border-top: 1px solid rgba(255,255,255,.12);
    padding-top: 14px;
    margin-top: 20px;
    font-size: 13px;
    font-weight: 700;
    color: #f1f5f9;
    line-height: 1.6;
}

/* FOOTER */

footer {
    background: var(--bg-card-dark);
    border-top: 1px solid var(--panel-border);
    color: var(--text-muted);
    text-align: center;
    padding: 30px 24px;
    margin-top: 50px;
    font-size: 12px;
    font-weight: 600;
}

/* RESPONSIVE LAYOUT */

@media (max-width: 1200px) {
    .restaurant-square-card { width: 33.333%; }
}

@media (max-width: 900px) {
    .nav-container { flex-wrap: wrap; gap: 14px; }
    .nav-links { gap: 14px; flex-wrap: wrap; }
    .restaurant-square-card { width: 50%; }
    .health-weather-grid { grid-template-columns: 1fr; }
    .rewards-grid { grid-template-columns: repeat(2,minmax(0,1fr)); }
    .offer-slide { padding: 42px 60px 70px; }
    .offer-bottom-row { left: 60px; right: 60px; }
}

@media (max-width: 600px) {
    .nav-container { padding: 12px 14px; }
    .logo { font-size: 23px; }

    .nav-links {
        width: 100%;
        justify-content: space-between;
        gap: 8px;
    }

    .nav-links a { font-size: 12px; }
    .brightness-slider { width: 42px; }
    .controls-box { gap: 7px; padding: 5px 8px; }

    .hero-section {
        min-height: 410px;
        padding: 70px 18px 60px;
        background-position: 60% center;
    }

    .hero-content h1 {
        font-size: 35px;
        letter-spacing: -1.3px;
    }

    .hero-content p { font-size: 14px; }

    .hero-streak-card { padding: 12px; margin-bottom: 18px; }
    .hero-streak-title { font-size: 14px; }
    .hero-streak-subtitle { font-size: 10px; }
    .hero-streak-days { gap: 3px; }
    .hero-streak-day-mark { width: 27px; height: 27px; font-size: 13px; }
    .hero-streak-day-label { font-size: 8px; }
    .hero-streak-reward { align-items: center; font-size: 10px; }
    .hero-streak-copy-button { padding: 8px 9px; font-size: 8px; }
    .hero-streak-reward-link { white-space: normal; text-align: right; }

    .offers-section {
        margin: 22px auto 30px;
        padding: 0 14px;
    }

    .offers-carousel, .offer-slide { min-height: 390px; }
    .offers-carousel { border-radius: 18px; }

    .offer-slide {
        align-items: flex-start;
        padding: 42px 25px 72px;
        background-position: 60% center;
    }

    .offer-slide::before {
        background: linear-gradient(
            90deg,
            rgba(9,7,8,.95),
            rgba(12,7,9,.77) 70%,
            rgba(12,7,9,.5)
        );
    }

    .offer-copy h2 {
        font-size: clamp(31px,8.5vw,42px);
        line-height: 1.12;
        letter-spacing: -1.3px;
    }

    .offer-copy p { font-size: 12px; line-height: 1.8; }
    .offer-actions { gap: 12px; margin-top: 22px; }
    .offer-cta { min-height: 43px; padding: 0 15px; font-size: 10px; }

    .offer-nav {
        top: auto;
        bottom: 15px;
        transform: none;
        width: 31px;
        height: 31px;
        font-size: 20px;
    }

    .offer-prev { left: 15px; }
    .offer-next { right: 15px; }

    .offer-bottom-row {
        left: 58px;
        right: 58px;
        bottom: 25px;
        justify-content: center;
    }

    .offer-bottom-caption, .offer-counter { display: none; }

    .main-container { margin: 28px auto; padding: 0 14px; }
    .section-header h2 { font-size: 20px; }
    .section-header a { font-size: 11px; }

    .rewards-intro {
        align-items: flex-start;
        flex-direction: column;
    }

    .rewards-grid { grid-template-columns: 1fr; }
    .reward-card { min-height: 275px; padding: 22px; }

    .restaurant-square-card { width: 100%; }

    .panel-health, .panel-weather-animated { padding: 20px; }
    .calorie-progress-container { gap: 16px; }
    .nutrition-metrics { gap: 8px; }
    .metric-card-enhanced { padding: 12px 6px; }
    .metric-card-enhanced strong { font-size: 16px; }

    .hero-buttons { align-items: stretch; }

    .hero-buttons .btn-primary,
    .hero-buttons .btn-secondary {
        max-width: 100%;
    }
}

@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        animation-duration: .01ms !important;
        transition-duration: .01ms !important;
        scroll-behavior: auto !important;
    }
}


/* LIVE CART COUNT BADGE */
.cart-nav-link {
    display: inline-flex !important;
    align-items: center;
    gap: 7px;
    white-space: nowrap;
}
.cart-count-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 22px;
    height: 22px;
    padding: 0 6px;
    border-radius: 999px;
    background: #e23744;
    color: #ffffff;
    font-size: 11px;
    font-weight: 800;
    line-height: 1;
    box-shadow: 0 2px 8px rgba(226, 55, 68, .35);
}
</style>
</head>

<body>

<header class="navbar">
    <div class="nav-container">
        <a href="home.jsp" class="logo">Smart<span>Bite</span></a>

        <nav class="nav-links" aria-label="Main navigation">
            <a href="home.jsp" class="active">Home</a>
            <a href="restaurants">Restaurants</a>
            <a href="orders.jsp" title="Orders">Orders</a>
            <%
                int smartBiteCartBadgeTotal = 0;
                Object smartBiteCartBadgeObject = session.getAttribute("cart");
                if (smartBiteCartBadgeObject instanceof List<?>) {
                    for (Object smartBiteCartBadgeEntry : (List<?>) smartBiteCartBadgeObject) {
                        if (smartBiteCartBadgeEntry instanceof CartItem) {
                            CartItem smartBiteCartBadgeItem = (CartItem) smartBiteCartBadgeEntry;
                            if (smartBiteCartBadgeItem.getMenu() != null && smartBiteCartBadgeItem.getQuantity() > 0) {
                                smartBiteCartBadgeTotal += smartBiteCartBadgeItem.getQuantity();
                            }
                        }
                    }
                }
            %>
            <a href="<%= request.getContextPath() %>/cart.jsp" title="Cart" class="cart-nav-link" aria-label="Cart, <%= smartBiteCartBadgeTotal %> items">
                🛒 Cart <span class="cart-count-badge"><%= smartBiteCartBadgeTotal %></span>
            </a>
            <a href="profile.jsp" class="profile-avatar" title="Profile">👤</a>

            <div class="controls-box">
                <input type="range" min="0.5" max="1.5" step="0.05"
                       value="1" class="brightness-slider"
                       id="brightnessSlider"
                       oninput="adjustBrightness(this.value)"
                       title="Adjust Brightness"
                       aria-label="Adjust screen brightness">

                <button type="button" class="theme-toggle-btn"
                        id="themeToggleBtn" onclick="toggleTheme()"
                        title="Toggle Light/Dark Theme"
                        aria-label="Toggle light or dark theme">
                    <span id="themeIcon">🌙</span>
                </button>
            </div>
        </nav>
    </div>
</header>

<!-- CINEMATIC HERO -->

<section class="hero-section">
    <div class="hero-content">
        <div class="hero-eyebrow">✦ GOOD FOOD. SMARTER CHOICES.</div>

        <h1>
            Discover the best food
            <span>&amp; drinks in Bengaluru.</span>
        </h1>

        <p>
            Explore local kitchens, discover your next favourite meal,
            track your daily nutrition, and let BiteAI help you find
            something delicious for every craving.
        </p>

        <!-- YOUR STREAKS: compact hero card with visible earned-coupon copy action -->
        <div class="hero-streak-card" role="group" aria-label="Your Streaks and coupon rewards">
            <div class="hero-streak-top">
                <span class="hero-streak-flame" aria-hidden="true">🔥</span>
                <span class="hero-streak-summary">
                    <span class="hero-streak-label">Your Streaks</span>
                    <span class="hero-streak-title">
                        <% if (loggedInUser == null) { %>
                            Start your SmartBite streak
                        <% } else { %>
                            <%= currentOrderStreak %> <%= currentOrderStreak == 1 ? "Day" : "Days" %> in a row
                        <% } %>
                    </span>
                    <span class="hero-streak-subtitle">
                        <% if (loggedInUser == null) { %>
                            Sign in to track your order streak and unlock rewards.
                        <% } else if (currentOrderStreak == 0) { %>
                            Place your first order to begin your streak and unlock Day 1.
                        <% } else { %>
                            Keep ordering on consecutive days to unlock your next reward.
                        <% } %>
                    </span>
                </span>
            </div>

            <div class="hero-streak-days" aria-label="Seven-day order streak progress">
                <% for (int streakDay = 1; streakDay <= 7; streakDay++) {
                       boolean streakDayCompleted = loggedInUser != null && currentOrderStreak >= streakDay;
                       boolean streakDayMilestone = streakDay >= 1;
                %>
                    <div class="hero-streak-day">
                        <span class="hero-streak-day-mark <%= streakDayCompleted ? "completed" : (streakDayMilestone ? "milestone" : "") %>" aria-label="Day <%= streakDay %><%= streakDayCompleted ? ", completed" : ", not completed" %>">🔥</span>
                        <span class="hero-streak-day-label">Day <%= streakDay %></span>
                    </div>
                <% } %>
            </div>

            <div class="hero-streak-reward">
                <span class="hero-streak-reward-icon" aria-hidden="true">🎁</span>
                <span class="hero-streak-reward-copy">
                    <% if (loggedInUser == null) { %>
                        <strong>Rewards await.</strong> Sign in to view your streak rewards.
                    <% } else if (currentOrderStreak >= 1 && activeRewardIndex >= 0) { %>
                        <strong>Day <%= streakRewardDays[activeRewardIndex] %> reward unlocked!</strong>
                        <%= streakRewardNames[activeRewardIndex] %>
                        <span class="hero-streak-coupon-code"><%= streakCouponCodes[activeRewardIndex] %></span>
                    <% } else { %>
                        <strong>Start your streak today.</strong>
                        Place your first order to unlock Day 1: 5% OFF · BITE5.
                    <% } %>
                </span>
                <% if (loggedInUser != null && currentOrderStreak >= 1 && activeRewardIndex >= 0) { %>
                    <button type="button" class="hero-streak-copy-button"
                            data-coupon="<%= streakCouponCodes[activeRewardIndex] %>"
                            aria-label="Copy earned coupon <%= streakCouponCodes[activeRewardIndex] %>"
                            onclick="copyStreakCoupon(this)">▢ COPY COUPON</button>
                <% } else { %>
                    <button type="button" class="hero-streak-copy-button" disabled
                            aria-label="Copy coupon after a reward is unlocked"
                            title="Place an order to unlock a coupon">▢ COPY COUPON</button>
                <% } %>
                <button type="button" class="hero-streak-reward-link"
                        aria-controls="smartbite-rewards"
                        onclick="setRewardsVisibility(true, true)">View rewards →</button>
            </div>
        </div>

        <div class="hero-buttons">
            <a href="restaurants" class="btn-primary">
                Explore Restaurants →
            </a>

            <button type="button" class="btn-secondary"
                    onclick="ftaAsk('what should i eat')">
                Ask BiteAI ✳
            </button>

            <button type="button"
                    class="btn-secondary"
                    id="showRewardsButton"
                    aria-controls="smartbite-rewards"
                    aria-expanded="false"
                    onclick="toggleRewards()">
                Offers &amp; Rewards Zone ✦
            </button>
        </div>
    </div>
</section>

<!-- ORIGINAL THREE CINEMATIC CAROUSEL SLIDES -->

<section class="offers-section" aria-label="SmartBite featured highlights">
    <div class="offers-carousel" id="offersCarousel"
         aria-roledescription="carousel"
         aria-label="Featured SmartBite highlights">

        <article class="offer-slide offer-signature active"
                 role="group" aria-roledescription="slide"
                 aria-label="Highlight 1 of 3">
            <div class="offer-copy">
                <span class="offer-label">The SmartBite Selection</span>

                <h2>A feast worth <span>craving.</span></h2>

                <p>
                    From comforting biryani to unforgettable local
                    favourites, your next great meal is just a few taps away.
                </p>

                <div class="offer-actions">
                    <a href="restaurants" class="offer-cta">
                        EXPLORE RESTAURANTS <span aria-hidden="true">↗</span>
                    </a>
                    <span class="offer-note">✦ Discover your next favourite</span>
                </div>
            </div>
        </article>

        <article class="offer-slide offer-discovery"
                 role="group" aria-roledescription="slide"
                 aria-label="Highlight 2 of 3">
            <div class="offer-copy">
                <span class="offer-label">Your Next Food Adventure</span>

                <h2>Follow your <span>flavour.</span></h2>

                <p>
                    Explore menus, discover dishes, and find something
                    delicious for every kind of craving.
                </p>

                <div class="offer-actions">
                    <a href="restaurants" class="offer-cta">
                        FIND YOUR NEXT MEAL <span aria-hidden="true">↗</span>
                    </a>
                    <span class="offer-note">✦ Made for curious food lovers</span>
                </div>
            </div>
        </article>

        <article class="offer-slide offer-rewards"
                 role="group" aria-roledescription="slide"
                 aria-label="Highlight 3 of 3">
            <div class="offer-copy">
                <span class="offer-label">A Little More to Look Forward To</span>

                <h2>Good food. <span>Great moments.</span></h2>

                <p>
                    Discover SmartBite rewards, celebrate special occasions,
                    and work toward exciting food-ordering milestones.
                </p>

                <div class="offer-actions">
                    <a href="#smartbite-rewards"
                       class="offer-cta"
                       data-open-rewards>
                        EXPLORE REWARDS <span aria-hidden="true">↗</span>
                    </a>
                    <span class="offer-note">✦ Rewards for your journey</span>
                </div>
            </div>
        </article>

        <button type="button" class="offer-nav offer-prev"
                id="offerPrev" aria-label="Previous highlight">&#8249;</button>

        <button type="button" class="offer-nav offer-next"
                id="offerNext" aria-label="Next highlight">&#8250;</button>

        <div class="offer-bottom-row">
            <span class="offer-bottom-caption">GOOD TASTE STARTS HERE</span>

            <div class="offer-dots" id="offerDots" aria-label="Choose a highlight">
                <button type="button" class="offer-dot active"
                        aria-label="Show highlight 1" aria-current="true"></button>
                <button type="button" class="offer-dot"
                        aria-label="Show highlight 2"></button>
                <button type="button" class="offer-dot"
                        aria-label="Show highlight 3"></button>
            </div>

            <span class="offer-counter" id="offerCounter">
                <span>01</span> / 03
            </span>
        </div>
    </div>
</section>

<main class="main-container">

    <!-- OFFERS AND REWARDS: HIDDEN UNTIL REQUESTED -->

    <section class="rewards-section"
             id="smartbite-rewards"
             aria-label="SmartBite offers and rewards"
             aria-hidden="true">

        <div class="rewards-intro">
            <div>
                <h2>Offers &amp; Rewards</h2>
                <p>
                    Build your streak, celebrate special moments,
                    and discover SmartBite's restaurant promotions.
                </p>
            </div>

            <span class="date-chip">
                TODAY · <%= todayLabel %>
            </span>
        </div>

        <div class="rewards-grid">

            <!-- 1. DYNAMIC ORDER STREAK REWARDS -->

            <article class="reward-card streak">
                <div class="reward-card-content">
                    <div class="reward-icon">🔥</div>

                    <span class="reward-status">Your Order Streak</span>

                    <h3>
                        <%= currentOrderStreak %>
                        <%= currentOrderStreak == 1 ? "Day" : "Days" %>
                        in a Row!
                    </h3>

                    <p>
                        <% if (loggedInUser == null) { %>
                            Log in to see your personal order streak.
                        <% } else if (currentOrderStreak == 0) { %>
                            Start your streak by placing an order today.
                            Order on consecutive days to unlock milestones.
                        <% } else if (sevenDayMilestoneReached) { %>
                            Amazing consistency! Your seven-day streak
                            milestone has been reached. Keep going to
                            maintain your streak.
                        <% } else { %>
                            Great progress! Your next milestone is
                            <%= nextStreakMilestone %> consecutive days.
                            <%= nextStreakMilestone - currentOrderStreak %>
                            more
                            <%= nextStreakMilestone - currentOrderStreak == 1
                                ? "day" : "days" %>
                            to go.
                        <% } %>
                    </p>

                    <div class="streak-progress"
                         aria-label="Your seven-day streak progress">
                        <% for (int day = 1; day <= 7; day++) {
                               boolean completed = currentOrderStreak >= day;
                               boolean milestone =
                                   day >= 1 && day <= 7;
                        %>
                            <div class="streak-day">
                                <span class="<%= completed ? "completed" : (milestone ? "milestone" : "") %>">
                                    <%= completed ? "✓" : day %>
                                </span>
                                <%= day %> <%= day == 1 ? "day" : "days" %>
                            </div>
                        <% } %>
                    </div>

                    <div class="streak-rewards-list" aria-label="Streak milestone rewards">
                        <% for (int i = 0; i < streakRewardDays.length; i++) {
                               boolean rewardEarned = currentOrderStreak >= streakRewardDays[i];
                        %>
                            <div class="streak-reward-row <%= rewardEarned ? "earned" : "locked" %>">
                                <span class="streak-reward-name">
                                    Day <%= streakRewardDays[i] %> · <%= streakRewardNames[i] %> · <%= streakCouponCodes[i] %>
                                </span>
                                <span class="streak-reward-status">
                                    <%= rewardEarned ? "🎁 Earned" : "🔒 Locked" %>
                                </span>
                                <% if (rewardEarned) { %>
                                    <button type="button"
                                            class="btn-secondary streak-copy-button"
                                            data-coupon="<%= streakCouponCodes[i] %>"
                                            onclick="copyStreakCoupon(this)">
                                        Copy code
                                    </button>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>

                <div class="reward-card-footer">
                    <% if (loggedInUser == null) { %>
                        Sign in to track your own streak.
                    <% } else if (sevenDayMilestoneReached) { %>
                        Seven consecutive days reached. Keep the streak alive and enjoy your Day 7 reward: 40% OFF · SMART40.
                        Checkout must validate the coupon before any discount is applied.
                    <% } else { %>
                        Next milestone:
                        <%= nextStreakMilestone %> consecutive days.
                        Rewards: Day 1 BITE5, Day 2 BITE10, Day 3 BITE15, Day 4 SMART20, Day 5 SMART25, Day 6 SMART30 and Day 7 SMART40.
                        Checkout must validate the selected coupon before any discount is applied.
                    <% } %>
                </div>
            </article>

            <!-- 2. BIRTHDAY OFFERS -->

            <article class="reward-card birthday">
                <div class="reward-card-content">
                    <div class="reward-icon">🎂</div>

                    <span class="reward-status">Birthday Special</span>

                    <h3>Your Birthday, Your Treat</h3>

                    <p>
                        Celebrate your special day with a birthday reward.
                        Eligibility can be checked against your saved
                        date of birth.
                    </p>

                    <a href="profile.jsp" class="reward-link">
                        Check birthday details <span>↗</span>
                    </a>
                </div>

                <div class="reward-card-footer">
                    Proposed reward: BIRTHDAY20 — 20% off up to ₹150,
                    minimum order ₹299. This is a proposal, not an active
                    coupon until configured in the backend.
                </div>
            </article>

            <!-- 3. DAILY RESTAURANT DEALS -->

            <article class="reward-card restaurant-deals">
                <div class="reward-card-content">
                    <div class="reward-icon">🍽️</div>

                    <span class="reward-status">Daily Offers</span>

                    <h3>Today's Local Favourites</h3>

                    <p>
                        Discover limited-time restaurant deals, eligible
                        menu discounts, daily specials, and promotional
                        offers from participating restaurants.
                    </p>

                    <a href="restaurants" class="reward-link">
                        Explore restaurants <span>↗</span>
                    </a>
                </div>

                <div class="reward-card-footer">
                    Only offers verified as active in the backend should
                    be advertised as available today. No live discount is
                    claimed by this preview.
                </div>
            </article>

            <!-- 4. WEEKLY OFFERS -->

            <article class="reward-card weekly-deals">
                <div class="reward-card-content">
                    <div class="reward-icon">📅</div>

                    <span class="reward-status">Weekly Rewards</span>

                    <h3>A New Week, New Treats</h3>

                    <p>
                        Discover weekly restaurant promotions, reward
                        challenges, and milestones with clearly explained
                        eligibility requirements.
                    </p>

                    <a href="restaurants" class="reward-link">
                        Discover menus <span>↗</span>
                    </a>
                </div>

                <div class="reward-card-footer">
                    Weekly offers need configured start dates, expiry
                    dates, minimum order amounts, and redemption rules.
                </div>
            </article>

            <!-- 5. RESTAURANT PROMOTIONS -->

            <article class="reward-card promotions">
                <div class="reward-card-content">
                    <div class="reward-icon">📣</div>

                    <span class="reward-status">Restaurant Specials</span>

                    <h3>What's Happening Nearby?</h3>

                    <p>
                        Highlight restaurant anniversaries, newly launched
                        dishes, special events, limited-time menus, and
                        announcements from participating kitchens.
                    </p>

                    <a href="restaurants" class="reward-link">
                        Meet the restaurants <span>↗</span>
                    </a>
                </div>

                <div class="reward-card-footer">
                    Announcements should be published and maintained by
                    an authorized administrator or restaurant manager.
                </div>
            </article>

            <!-- 6. REWARD CHALLENGES -->

            <article class="reward-card reward-challenges">
                <div class="reward-card-content">
                    <div class="reward-icon">🏆</div>

                    <span class="reward-status">Reward Challenges</span>

                    <h3>Your Next Achievement</h3>

                    <p>
                        Track eligible challenges, work toward milestones,
                        and see what each achievement unlocks. Earned
                        rewards should be recorded in your account.
                    </p>

                    <a href="orders.jsp" class="reward-link">
                        View your orders <span>↗</span>
                    </a>
                </div>

                <div class="reward-card-footer">
                    Challenge progress, reward claims, and coupon
                    redemption must be verified by the SmartBite backend.
                </div>
            </article>

        </div>
    </section>

    <!-- RESTAURANT LISTINGS -->

    <section id="trending-restaurants">
        <div class="section-header">
            <h2>Trending Restaurants</h2>
            <a href="restaurants">See all restaurants →</a>
        </div>

        <div class="restaurant-grid-wrapper">
            <%
                Connection con = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                boolean foundRestaurants = false;

                try {
                    con = DBConnection.getConnection();

                    String sql =
                        "SELECT restaurantId, name, cuisineType, deliveryTime, rating, imagePath " +
                        "FROM restaurant ORDER BY restaurantId";

                    ps = con.prepareStatement(sql);
                    rs = ps.executeQuery();

                    while (rs.next()) {
                        foundRestaurants = true;

                        int restaurantId = rs.getInt("restaurantId");
                        String name = rs.getString("name");
                        String cuisine = rs.getString("cuisineType");
                        String image = rs.getString("imagePath");
                        int delivery = rs.getInt("deliveryTime");
                        double rating = rs.getDouble("rating");

                        if (name == null) name = "Restaurant";
                        if (cuisine == null) cuisine = "Local favourites";

                        if (image == null || image.trim().isEmpty()) {
                            image = "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80";
                        }

                        String safeName = name.replace("&", "&amp;")
                            .replace("<", "&lt;")
                            .replace(">", "&gt;")
                            .replace("\"", "&quot;")
                            .replace("'", "&#39;");

                        String safeCuisine = cuisine.replace("&", "&amp;")
                            .replace("<", "&lt;")
                            .replace(">", "&gt;")
                            .replace("\"", "&quot;")
                            .replace("'", "&#39;");

                        String safeImage = image.replace("&", "&amp;")
                            .replace("\"", "&quot;")
                            .replace("<", "&lt;")
                            .replace(">", "&gt;");
            %>

            <form action="menu" method="get" class="restaurant-square-card">
                <input type="hidden" name="restaurantId"
                       value="<%= restaurantId %>">

                <button type="submit"
                        style="border:0;padding:0;margin:0;text-align:left;background:transparent;color:inherit;display:flex;flex-direction:column;width:100%;height:100%;cursor:pointer;">

                    <div class="card-part-top-black">
                        <div class="card-img-box">
                            <img src="<%= safeImage %>"
                                 alt="<%= safeName %>">

                            <% if (isRestaurantOpen) { %>
                                <span class="status-badge open">OPEN</span>
                            <% } else { %>
                                <span class="status-badge closed">CLOSED</span>
                            <% } %>

                            <span class="rating-badge">
                                ★ <%= String.format(java.util.Locale.US, "%.1f", rating) %>
                            </span>
                        </div>

                        <div class="restaurant-title-row">
                            <div class="restaurant-title"><%= safeName %></div>
                        </div>
                    </div>

                    <div class="card-part-bottom-charcoal">
                        <div class="cuisine-text"><%= safeCuisine %></div>
                        <div class="timing-text">🕒 10:00 AM - 11:00 PM</div>

                        <div class="meta-footer-row">
                            <span class="delivery-time">◷ <%= delivery %> mins</span>
                            <span class="view-menu-btn-red">View Menu →</span>
                        </div>
                    </div>
                </button>
            </form>

            <%
                    }

                    if (!foundRestaurants) {
            %>
                <p style="padding:16px;color:var(--text-muted);">
                    No restaurants are available right now.
                </p>
            <%
                    }
                } catch (Exception e) {
                    application.log("Error loading restaurants", e);
            %>
                <p style="padding:16px;color:var(--text-muted);">
                    Restaurants are temporarily unavailable. Please try again.
                </p>
            <%
                } finally {
                    if (rs != null) try { rs.close(); } catch (Exception e) {}
                    if (ps != null) try { ps.close(); } catch (Exception e) {}
                    if (con != null) try { con.close(); } catch (Exception e) {}
                }
            %>
        </div>
    </section>

    <!-- HEALTH SUMMARY AND LIVE WEATHER -->

    <section class="health-weather-grid">

        <div class="panel-health">
            <div class="health-quote-banner"><%= healthQuote %></div>

            <div class="calorie-progress-container">
                <div class="conic-ring-box">
                    <div class="conic-ring-text">
                        <strong><%= circlePercentage %>%</strong>
                        <span>Goal</span>
                    </div>
                </div>

                <div>
                    <div style="font-size:24px;font-weight:800;color:var(--text-main);">
                        <%= String.format(java.util.Locale.US, "%.0f", healthCalories) %>
                        <span style="font-size:14px;color:var(--text-muted);">
                            / <%= String.format(java.util.Locale.US, "%.0f", healthGoal) %> kcal
                        </span>
                    </div>

                    <div style="font-size:13px;color:var(--text-muted);margin-top:4px;font-weight:600;">
                        <%= String.format(java.util.Locale.US, "%.0f", healthRemaining) %>
                        kcal remaining for today
                    </div>
                </div>
            </div>

            <div class="nutrition-metrics">
                <div class="metric-card-enhanced">
                    <span>Protein</span>
                    <strong><%= String.format(java.util.Locale.US, "%.1f", healthSummary.getProtein()) %>g</strong>
                </div>

                <div class="metric-card-enhanced">
                    <span>Carbs</span>
                    <strong><%= String.format(java.util.Locale.US, "%.1f", healthSummary.getCarbs()) %>g</strong>
                </div>

                <div class="metric-card-enhanced">
                    <span>Fiber</span>
                    <strong><%= String.format(java.util.Locale.US, "%.1f", healthSummary.getFiber()) %>g</strong>
                </div>
            </div>
        </div>

        <div class="panel-weather-animated">
            <div>
                <div class="weather-live-indicator">
                    <span class="live-dot"></span> BENGALURU • LIVE
                </div>

                <div class="weather-temp-hero">
                    <span id="weatherTemperature">--°C</span>
                    <img id="weatherIcon3D"
                         class="weather-icon-3d-animated"
                         src="https://cdn-icons-png.flaticon.com/512/1163/1163661.png"
                         alt="Live Weather">
                </div>

                <div class="weather-condition-desc" id="weatherCondition">
                    Fetching live weather...
                </div>
            </div>

            <div class="weather-quote-box" id="weatherRecommendation">
                🍽️ Find a meal that suits the weather and your cravings.
            </div>
        </div>

    </section>

</main>

<!-- PRESERVE EXISTING BITEAI ASSISTANT -->

<%@ include file="ai-assistant.jsp" %>

<footer>
    <p>&copy; 2026 SmartBite Delivery Platform. All rights reserved.</p>
</footer>

<script>
/* OFFERS AND REWARDS: REVEAL, HIDE AND SCROLL */

function setRewardsVisibility(visible, shouldScroll) {
    const rewardsSection = document.getElementById("smartbite-rewards");
    const rewardsButton = document.getElementById("showRewardsButton");

    if (!rewardsSection || !rewardsButton) return;

    rewardsSection.classList.toggle("rewards-visible", visible);
    rewardsSection.setAttribute("aria-hidden", visible ? "false" : "true");
    rewardsButton.setAttribute("aria-expanded", visible ? "true" : "false");

    rewardsButton.textContent = visible
        ? "Hide Offers & Rewards ✕"
        : "Offers & Rewards Zone ✦";

    if (visible && shouldScroll) {
        window.setTimeout(function () {
            rewardsSection.scrollIntoView({
                behavior: window.matchMedia("(prefers-reduced-motion: reduce)").matches
                    ? "auto"
                    : "smooth",
                block: "start"
            });
        }, 50);
    }
}

function toggleRewards() {
    const rewardsSection = document.getElementById("smartbite-rewards");

    if (!rewardsSection) return;

    const isVisible =
        rewardsSection.classList.contains("rewards-visible");

    setRewardsVisibility(!isVisible, !isVisible);
}

document.querySelectorAll("[data-open-rewards]").forEach(function (link) {
    link.addEventListener("click", function (event) {
        event.preventDefault();
        setRewardsVisibility(true, true);
    });
});

/* RESTORE SAVED THEME AND BRIGHTNESS SETTINGS */

(function () {
    try {
        const savedTheme = localStorage.getItem("smartbite_theme");
        const savedBrightness = localStorage.getItem("smartbite_brightness");

        if (savedTheme === "light") {
            document.body.classList.add("light-mode");
        }

        if (savedBrightness !== null) {
            const brightness = parseFloat(savedBrightness);

            if (!Number.isNaN(brightness) &&
                brightness >= 0.5 && brightness <= 1.5) {
                document.documentElement.style.filter =
                    "brightness(" + brightness + ")";

                const slider = document.getElementById("brightnessSlider");
                if (slider) slider.value = brightness;
            }
        }
    } catch (e) {
        console.log("Unable to restore saved display settings.");
    }

    updateThemeButtonUI();
})();

/* CINEMATIC THREE-SLIDE CAROUSEL */

(function () {
    const carousel = document.getElementById("offersCarousel");
    if (!carousel) return;

    const slides = Array.from(carousel.querySelectorAll(".offer-slide"));
    const dots = Array.from(carousel.querySelectorAll(".offer-dot"));
    const previous = document.getElementById("offerPrev");
    const next = document.getElementById("offerNext");
    const counter = document.getElementById("offerCounter");

    if (!slides.length || dots.length !== slides.length ||
        !previous || !next) {
        return;
    }

    let currentIndex = 0;
    let rotationTimer = null;
    const rotationDelay = 6000;
    const reducedMotion =
        window.matchMedia("(prefers-reduced-motion: reduce)");

    function showSlide(index) {
        currentIndex = (index + slides.length) % slides.length;

        slides.forEach(function (slide, i) {
            const active = i === currentIndex;
            slide.classList.toggle("active", active);
            slide.setAttribute("aria-hidden", active ? "false" : "true");
        });

        dots.forEach(function (dot, i) {
            const active = i === currentIndex;
            dot.classList.toggle("active", active);

            if (active) {
                dot.setAttribute("aria-current", "true");
            } else {
                dot.removeAttribute("aria-current");
            }
        });

        if (counter) {
            counter.innerHTML =
                "<span>" + String(currentIndex + 1).padStart(2, "0") +
                "</span> / " + String(slides.length).padStart(2, "0");
        }
    }

    function stopRotation() {
        if (rotationTimer !== null) {
            clearInterval(rotationTimer);
            rotationTimer = null;
        }
    }

    function startRotation() {
        stopRotation();

        if (reducedMotion.matches || document.hidden) return;

        rotationTimer = setInterval(function () {
            if (!carousel.matches(":hover") &&
                !carousel.contains(document.activeElement)) {
                showSlide(currentIndex + 1);
            }
        }, rotationDelay);
    }

    previous.addEventListener("click", function () {
        showSlide(currentIndex - 1);
        startRotation();
    });

    next.addEventListener("click", function () {
        showSlide(currentIndex + 1);
        startRotation();
    });

    dots.forEach(function (dot, index) {
        dot.addEventListener("click", function () {
            showSlide(index);
            startRotation();
        });
    });

    carousel.addEventListener("mouseenter", stopRotation);
    carousel.addEventListener("mouseleave", startRotation);
    carousel.addEventListener("focusin", stopRotation);

    carousel.addEventListener("focusout", function (event) {
        if (!carousel.contains(event.relatedTarget)) {
            startRotation();
        }
    });

    document.addEventListener("visibilitychange", function () {
        if (document.hidden) {
            stopRotation();
        } else {
            startRotation();
        }
    });

    if (typeof reducedMotion.addEventListener === "function") {
        reducedMotion.addEventListener("change", startRotation);
    }

    showSlide(0);
    startRotation();
})();

/* LIVE BENGALURU WEATHER */

window.addEventListener("load", function () {
    fetch("https://api.open-meteo.com/v1/forecast?latitude=12.9716&longitude=77.5946&current=temperature_2m,weather_code&timezone=Asia%2FKolkata")
        .then(function (response) {
            if (!response.ok) {
                throw new Error(
                    "Weather service returned HTTP " + response.status
                );
            }
            return response.json();
        })
        .then(function (data) {
            if (!data.current) return;

            const temp = Math.round(data.current.temperature_2m);
            const code = data.current.weather_code;

            document.getElementById("weatherTemperature").textContent =
                temp + "°C";

            let condition = "Pleasant Weather";
            let icon =
                "https://cdn-icons-png.flaticon.com/512/1163/1163661.png";
            let quote =
                "🍽️ Explore your favourite meals or refreshing drinks.";

            if (code >= 51 && code <= 99) {
                condition = "Rainy Vibes";
                icon =
                    "https://cdn-icons-png.flaticon.com/512/1163/1163657.png";
                quote =
                    "🌧️ Rainy weather calls for crispy starters, hot noodles and comforting bowls!";
            } else if (temp > 30) {
                condition = "Sunny & Warm";
                icon =
                    "https://cdn-icons-png.flaticon.com/512/869/869869.png";
                quote =
                    "🥤 Cool off with chilled beverages, fresh smoothies and light salads.";
            } else if (temp < 22) {
                condition = "Cool Breeze";
                icon =
                    "https://cdn-icons-png.flaticon.com/512/3054/3054889.png";
                quote =
                    "🍲 Cooler weather? Explore hot soups, biryani or steaming chai.";
            }

            document.getElementById("weatherCondition").textContent =
                condition;

            document.getElementById("weatherIcon3D").src = icon;

            document.getElementById("weatherRecommendation").textContent =
                quote;
        })
        .catch(function (error) {
            console.log("Unable to load live weather:", error);

            document.getElementById("weatherCondition").textContent =
                "Weather currently unavailable";

            document.getElementById("weatherRecommendation").textContent =
                "🍽️ Explore SmartBite and find a meal you'll love.";
        });
});

/* LIGHT/DARK THEME */

function toggleTheme() {
    document.body.classList.toggle("light-mode");

    const isLight =
        document.body.classList.contains("light-mode");

    try {
        localStorage.setItem(
            "smartbite_theme",
            isLight ? "light" : "dark"
        );
    } catch (e) {
        console.log("Unable to save theme preference.");
    }

    updateThemeButtonUI();
}

function updateThemeButtonUI() {
    const isLight =
        document.body.classList.contains("light-mode");

    const themeIcon = document.getElementById("themeIcon");

    if (themeIcon) {
        themeIcon.textContent = isLight ? "☀️" : "🌙";
    }
}

/* COPY STREAK COUPON */
function copyStreakCoupon(button) {
    if (!button) {
        return;
    }

    const coupon = (button.getAttribute("data-coupon") || "").trim();
    if (!coupon) {
        return;
    }

    function showCopiedMessage(success) {
        const originalText = button.textContent;
        button.textContent = success ? "Copied!" : "Copy manually: " + coupon;
        if (success) {
            button.setAttribute("aria-label", "Coupon " + coupon + " copied");
        }
        window.setTimeout(function () {
            button.textContent = originalText;
        }, 1800);
    }

    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(coupon)
            .then(function () {
                showCopiedMessage(true);
            })
            .catch(function () {
                copyStreakCouponFallback(coupon, button, showCopiedMessage);
            });
    } else {
        copyStreakCouponFallback(coupon, button, showCopiedMessage);
    }
}

function copyStreakCouponFallback(coupon, button, showCopiedMessage) {
    const field = document.createElement("textarea");
    field.value = coupon;
    field.setAttribute("readonly", "readonly");
    field.style.position = "fixed";
    field.style.left = "-9999px";
    document.body.appendChild(field);
    field.select();

    let copied = false;
    try {
        copied = document.execCommand("copy");
    } catch (error) {
        copied = false;
    } finally {
        document.body.removeChild(field);
    }

    if (copied) {
        showCopiedMessage(true);
    } else {
        const originalText = button.textContent;
        button.textContent = "Copy manually: " + coupon;
        window.setTimeout(function () {
            button.textContent = originalText;
        }, 2500);
    }
}

/* BRIGHTNESS CONTROL */

function adjustBrightness(value) {
    const brightness = parseFloat(value);

    if (Number.isNaN(brightness) ||
        brightness < 0.5 || brightness > 1.5) {
        return;
    }

    document.documentElement.style.filter =
        "brightness(" + brightness + ")";

    try {
        localStorage.setItem(
            "smartbite_brightness",
            String(brightness)
        );
    } catch (e) {
        console.log("Unable to save brightness preference.");
    }
}
</script>


<script>
/* Refresh the JSP-rendered cart badge when returning via browser history. */
window.addEventListener("pageshow", function (event) {
    if (event.persisted) {
        window.location.reload();
    }
});
</script>
</body>
</html>
