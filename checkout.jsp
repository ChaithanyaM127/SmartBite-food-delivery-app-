<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.foodtap.model.CartItem" %>
<%@ page import="com.foodtap.model.User" %>
<%@ page import="com.foodtap.util.DBConnection" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("loggedInUser");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=checkout.jsp");
        return;
    }

    List<CartItem> cart = new ArrayList<CartItem>();
    Object cartObject = session.getAttribute("cart");

    if (cartObject instanceof List<?>) {
        for (Object obj : (List<?>) cartObject) {
            if (obj instanceof CartItem) {
                cart.add((CartItem) obj);
            }
        }
    }

    double foodTotal = 0;
    int initialCartCount = 0;

    for (CartItem item : cart) {
        if (item.getMenu() != null && item.getQuantity() > 0) {
            foodTotal += item.getItemTotal();
            initialCartCount += item.getQuantity();
        }
    }

    double deliveryFee = 40;
    double platformFee = 20;
    double grandTotal = foodTotal + deliveryFee + platformFee;

    /*
     * CHECK CURRENT ORDER STREAK
     * Uses the same PLACED-order streak rule as the SmartBite homepage.
     */
    LocalDate couponToday = LocalDate.now(ZoneId.of("Asia/Kolkata"));
    int currentOrderStreak = 0;

    if (user.getUserId() > 0) {
        List<LocalDate> orderDays = new ArrayList<LocalDate>();

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

            if (streakCon != null) {
                try (PreparedStatement streakPS = streakCon.prepareStatement(streakSQL)) {
                    streakPS.setInt(1, user.getUserId());

                    try (ResultSet streakRS = streakPS.executeQuery()) {
                        while (streakRS.next()) {
                            java.sql.Date orderDate = streakRS.getDate("order_day");

                            if (orderDate != null) {
                                LocalDate orderDay = orderDate.toLocalDate();

                                if (!orderDay.isAfter(couponToday)) {
                                    orderDays.add(orderDay);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            application.log("Unable to check SmartBite streak coupon eligibility.", e);
        } finally {
            if (streakCon != null) {
                try {
                    streakCon.close();
                } catch (Exception e) {
                    application.log("Unable to close streak coupon database connection.", e);
                }
            }
        }

        if (!orderDays.isEmpty()) {
            LocalDate latestOrderDay = orderDays.get(0);

            if (!latestOrderDay.isBefore(couponToday.minusDays(1))) {
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
    }

    /*
     * CHECK BIRTHDAY COUPON ELIGIBILITY.
     * If the optional dateOfBirth column is not available,
     * the rest of checkout continues normally.
     */
    boolean birthdayCouponEligible = false;
    Connection birthdayCon = null;

    try {
        birthdayCon = DBConnection.getConnection();

        if (birthdayCon != null) {
            String birthdaySQL =
                "SELECT dateOfBirth FROM `user` WHERE userId = ?";

            try (PreparedStatement birthdayPS = birthdayCon.prepareStatement(birthdaySQL)) {
                birthdayPS.setInt(1, user.getUserId());

                try (ResultSet birthdayRS = birthdayPS.executeQuery()) {
                    if (birthdayRS.next()) {
                        java.sql.Date birthdayDate = birthdayRS.getDate("dateOfBirth");

                        birthdayCouponEligible =
                            birthdayDate != null
                            && birthdayDate.toLocalDate().getMonthValue() == couponToday.getMonthValue()
                            && birthdayDate.toLocalDate().getDayOfMonth() == couponToday.getDayOfMonth();
                    }
                }
            }
        }
    } catch (Exception e) {
        application.log(
            "Unable to check SmartBite birthday coupon eligibility. Verify that user.dateOfBirth exists.",
            e
        );
    } finally {
        if (birthdayCon != null) {
            try {
                birthdayCon.close();
            } catch (Exception e) {
                application.log("Unable to close birthday coupon database connection.", e);
            }
        }
    }

    String[] streakCouponCodes = {
        "BITE5", "BITE10", "BITE15", "SMART20",
        "SMART25", "SMART30", "SMART40"
    };

    String[] streakRewardNames = {
        "5% OFF", "10% OFF", "15% OFF", "20% OFF",
        "25% OFF", "30% OFF", "40% OFF"
    };

    int[] streakRewardDays = {1, 2, 3, 4, 5, 6, 7};
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Checkout</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&amp;display=swap" rel="stylesheet">

<style>
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

html {
    min-height: 100%;
    background: #0d0d0f;
}

body {
    margin: 0 !important;
    padding: 0 !important;
    min-height: 100vh;
    overflow-x: hidden;
    background: linear-gradient(rgba(13, 13, 15, 0.90), rgba(13, 13, 15, 0.95)),
                url('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1600&q=80');
    background-size: cover;
    background-attachment: fixed;
    background-position: center;
    color: var(--text-main) !important;
    font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif !important;
    transition: color 0.3s ease, background-color 0.3s ease;
}

body.light-mode {
    background: linear-gradient(rgba(241, 243, 245, 0.92), rgba(241, 243, 245, 0.96)),
                url('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1600&q=80');
    background-size: cover;
    background-attachment: fixed;
    background-position: center;
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
    white-space: nowrap;
}

.logo span {
    color: var(--accent);
}

.nav-links {
    display: flex;
    gap: 22px;
    align-items: center;
}

.nav-links > a {
    text-decoration: none;
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 6px;
}

.nav-links > a:hover,
.nav-links > a.active {
    color: var(--accent);
}

/* Cart badge */
#fta-cart-badge {
    background: #e23744;
    color: #ffffff;
    font-size: 10px;
    font-weight: 800;
    padding: 2px 6px;
    border-radius: 10px;
    margin-left: 4px;
    line-height: 1.4;
}

.profile-avatar {
    width: 28px;
    height: 28px;
    min-width: 28px;
    border-radius: 50%;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    text-decoration: none;
    transition: transform 0.2s ease, border-color 0.2s ease;
}

.profile-avatar:hover {
    transform: scale(1.08);
    border-color: var(--accent);
}

/* Theme and brightness controls — matching home.jsp */
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

.theme-mode-btn:focus-visible {
    outline: 2px solid var(--accent);
    outline-offset: 3px;
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
    -webkit-user-select: none;
    outline-offset: 3px;
}

.brightness-slider:focus-visible {
    outline: 2px solid var(--accent);
    border-radius: 5px;
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
    box-shadow: none;
    transform: translate(-50%, -50%);
    pointer-events: none;
}

.brightness-slider:active .brightness-thumb {
    box-shadow: 0 0 0 3px var(--accent-glow);
}

/* Page container */
.page-container {
    max-width: 1320px;
    margin: 40px auto 80px;
    padding: 0 24px;
}

.page-title {
    margin-bottom: 28px;
}

.page-title h1 {
    font-size: 28px;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.5px;
    margin-bottom: 6px;
}

.page-title p {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
}

/* Checkout layout */
.checkout-layout {
    display: grid;
    grid-template-columns: 1fr 380px;
    gap: 24px;
    align-items: start;
}

.left-section {
    display: flex;
    flex-direction: column;
    gap: 24px;
}

.card {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    padding: 24px;
    box-shadow: var(--shadow);
}

.card h2 {
    color: var(--text-main);
    font-size: 18px;
    font-weight: 800;
    margin-bottom: 18px;
}

.form-group {
    margin-bottom: 16px;
}

.form-group label {
    display: block;
    margin-bottom: 6px;
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 700;
}

.form-group input,
.form-group textarea,
.card-input,
.card-select {
    width: 100%;
    padding: 12px 14px;
    border: 1px solid var(--panel-border);
    background: var(--metric-bg);
    color: var(--text-main);
    border-radius: 6px;
    outline: none;
    font-size: 13px;
    font-weight: 500;
}

.form-group input:focus,
.form-group textarea:focus,
.card-input:focus,
.card-select:focus {
    border-color: var(--accent);
}

.form-group textarea {
    min-height: 90px;
    resize: vertical;
}

.location-button {
    width: 100%;
    margin-top: 10px;
    padding: 11px 15px;
    background: rgba(226, 55, 68, 0.1);
    color: var(--accent);
    border: 1px solid var(--accent);
    border-radius: 6px;
    font-size: 13px;
    font-weight: 800;
    cursor: pointer;
    transition: 0.2s;
}

.location-button:hover {
    background: var(--accent);
    color: white;
}

.location-button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.location-status {
    margin-top: 8px;
    font-size: 11px;
    color: var(--text-muted);
    min-height: 18px;
    font-weight: 600;
}

.location-status.success {
    color: #24963f;
}

.location-status.error {
    color: var(--accent);
}

.payment-option {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    border-radius: 6px;
    margin-bottom: 10px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 700;
}

.payment-option:hover {
    border-color: var(--accent);
}

.payment-option input {
    accent-color: var(--accent);
}

.payment-option span {
    color: var(--text-main);
}

.upi-section {
    display: none;
    margin-top: 16px;
    padding: 16px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    border-radius: 6px;
}

.upi-section h3 {
    color: var(--text-main);
    font-size: 14px;
    font-weight: 800;
    margin-bottom: 12px;
}

.upi-apps {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    margin-bottom: 16px;
}

.upi-app {
    padding: 10px 6px;
    border: 1px solid var(--panel-border);
    border-radius: 6px;
    text-align: center;
    color: var(--text-muted);
    cursor: pointer;
    background: var(--bg-card-dark);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 6px;
    transition: 0.2s;
}

.upi-app:hover {
    border-color: var(--accent);
}

.upi-app.selected {
    border-color: var(--accent);
    color: var(--accent);
    background: rgba(226, 55, 68, 0.1);
}

.upi-app input {
    display: none;
}

.upi-logo {
    width: 36px;
    height: 36px;
    border-radius: 6px;
    object-fit: contain;
    background: #ffffff;
    padding: 4px;
}

.upi-app-name {
    font-size: 11px;
    font-weight: 700;
    color: var(--text-main);
}

.upi-app.selected .upi-app-name {
    color: var(--accent);
}

.upi-selected-text {
    margin-top: 4px;
    margin-bottom: 12px;
    text-align: center;
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 600;
}

.card-section {
    display: none;
    margin-top: 16px;
    padding: 16px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    border-radius: 6px;
}

.card-section h3 {
    color: var(--text-main);
    font-size: 14px;
    font-weight: 800;
    margin-bottom: 14px;
}

.card-number-wrapper {
    position: relative;
}

.card-number-icon {
    position: absolute;
    right: 12px;
    top: 11px;
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 800;
}

.card-security-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
}

.card-hint {
    color: var(--text-muted);
    font-size: 10px;
    margin-top: 4px;
}

.card-select option {
    background: var(--bg-card-dark);
    color: var(--text-main);
}

/* COUPON SECTION */
.coupon-box {
    margin: 18px 0 22px;
    padding: 16px;
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    background: var(--metric-bg);
}

.coupon-heading {
    display: flex;
    align-items: center;
    gap: 9px;
    margin-bottom: 6px;
    color: var(--text-main);
    font-size: 14px;
    font-weight: 800;
}

.coupon-heading-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 31px;
    height: 31px;
    flex: 0 0 31px;
    border-radius: 8px;
    background: rgba(226, 55, 68, 0.12);
    color: var(--accent);
    font-size: 17px;
}

.coupon-description {
    margin: 0 0 12px;
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 600;
    line-height: 1.5;
}

.coupon-input-row {
    display: flex;
    align-items: stretch;
    gap: 8px;
}

.coupon-input {
    min-width: 0;
    flex: 1;
    width: 100%;
    height: 42px;
    padding: 0 12px;
    border: 1px solid var(--panel-border);
    border-radius: 6px;
    outline: none;
    background: var(--bg-card-dark);
    color: var(--text-main);
    font-family: inherit;
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
}

.coupon-input:focus {
    border-color: var(--accent);
}

.coupon-input::placeholder {
    color: var(--text-muted);
    opacity: .8;
    text-transform: none;
}

.coupon-action-btn {
    min-height: 42px;
    padding: 0 13px;
    border: 1px solid var(--accent);
    border-radius: 6px;
    background: var(--accent);
    color: #ffffff;
    font-family: inherit;
    font-size: 11px;
    font-weight: 800;
    cursor: pointer;
    transition: background .2s ease, transform .2s ease;
}

.coupon-action-btn:hover {
    background: #c92836;
}

.coupon-action-btn:active {
    transform: scale(.98);
}

.coupon-remove-btn {
    display: none;
    width: 100%;
    margin-top: 8px;
    padding: 8px 10px;
    border: 1px solid var(--panel-border);
    border-radius: 6px;
    background: transparent;
    color: var(--text-muted);
    font-family: inherit;
    font-size: 11px;
    font-weight: 800;
    cursor: pointer;
}

.coupon-remove-btn:hover {
    border-color: var(--accent);
    color: var(--accent);
}

.coupon-status {
    margin-top: 10px;
    min-height: 17px;
    font-size: 11px;
    font-weight: 700;
    line-height: 1.5;
    overflow-wrap: anywhere;
}

.coupon-status.success {
    color: #24963f;
}

.coupon-status.error {
    color: var(--accent);
}

.eligible-coupons {
    display: flex;
    flex-wrap: wrap;
    gap: 7px;
    margin-top: 12px;
}

.eligible-coupon-btn {
    padding: 7px 9px;
    border: 1px dashed rgba(226, 55, 68, .55);
    border-radius: 6px;
    background: rgba(226, 55, 68, .07);
    color: var(--text-main);
    font-family: inherit;
    font-size: 10px;
    font-weight: 800;
    cursor: pointer;
    transition: border-color .2s ease, background .2s ease;
}

.eligible-coupon-btn:hover {
    border-color: var(--accent);
    background: rgba(226, 55, 68, .15);
}

.eligible-coupon-note {
    margin: 10px 0 0;
    color: var(--text-muted);
    font-size: 10px;
    line-height: 1.5;
}

/* Order summary */
.order-summary {
    position: sticky;
    top: 90px;
}

.citem {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid var(--panel-border);
}

.citem-img {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 6px;
    background: #000000;
}

.citem-d {
    flex: 1;
    min-width: 0;
}

.citem-d h3 {
    color: var(--text-main);
    font-size: 13px;
    font-weight: 800;
    margin-bottom: 4px;
}

.citem-d p {
    color: var(--text-muted);
    font-size: 11px;
    font-weight: 600;
}

.citem-p {
    color: #24963f;
    font-weight: 800;
    font-size: 13px;
    white-space: nowrap;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    margin: 12px 0;
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 600;
}

.summary-row span:last-child {
    color: var(--text-main);
    font-weight: 700;
    text-align: right;
}

.summary-row.discount-row {
    color: #24963f;
}

.summary-row.discount-row span:last-child {
    color: #24963f;
}

.summary-row.total {
    border-top: 1px solid var(--panel-border);
    padding-top: 14px;
    margin-top: 16px;
    color: var(--text-main);
    font-size: 16px;
    font-weight: 800;
}

.summary-row.total span:last-child {
    color: #24963f;
    font-size: 18px;
    font-weight: 900;
}

.place-order-btn {
    width: 100%;
    margin-top: 20px;
    padding: 13px;
    background: var(--accent);
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 800;
    cursor: pointer;
    transition: background 0.2s;
}

.place-order-btn:hover {
    background: #d12e3b;
}

.empty-cart {
    max-width: 600px;
    margin: 50px auto;
    padding: 50px 20px;
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    text-align: center;
    box-shadow: var(--shadow);
}

.empty-cart h2 {
    color: var(--text-main);
    font-size: 20px;
    font-weight: 800;
    margin-bottom: 10px;
}

.empty-cart p {
    color: var(--text-muted);
    font-size: 13px;
    margin-bottom: 20px;
}

.browse-btn {
    display: inline-block;
    background: var(--accent);
    color: white;
    text-decoration: none;
    padding: 10px 24px;
    border-radius: 6px;
    font-weight: 800;
    font-size: 13px;
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
    .checkout-layout {
        grid-template-columns: 1fr;
    }

    .order-summary {
        position: static;
    }

    .upi-apps {
        grid-template-columns: repeat(2, 1fr);
    }

    .nav-container {
        flex-wrap: wrap;
        gap: 12px;
    }

    .nav-links {
        flex-wrap: wrap;
        gap: 14px;
    }
}

@media (max-width: 600px) {
    .page-container {
        width: 94%;
        margin-top: 25px;
        padding: 0;
    }

    .page-title h1 {
        font-size: 24px;
    }

    .card {
        padding: 18px;
    }

    .card-security-row {
        grid-template-columns: 1fr;
    }

    .nav-container {
        padding: 12px 14px;
    }

    .nav-links {
        gap: 12px;
    }

    .nav-links > a {
        font-size: 12px;
    }

    .controls-box {
        gap: 8px;
        padding: 0;
    }

    .brightness-slider {
        width: 46px;
        flex-basis: 46px;
    }

    .coupon-box {
        padding: 12px;
    }

    .coupon-input-row {
        gap: 6px;
    }

    .coupon-action-btn {
        padding: 0 10px;
    }

    .eligible-coupons {
        gap: 6px;
    }

    .eligible-coupon-btn {
        font-size: 9px;
    }
}
</style>
</head>

<body>

<header class="navbar">
    <div class="nav-container">
        <a href="home.jsp" class="logo">Smart<span>Bite</span></a>

        <nav class="nav-links" aria-label="Main navigation">
            <a href="home.jsp">Home</a>
            <a href="restaurants">Restaurants</a>
            <a href="orders.jsp" title="Orders">Orders</a>

            <a href="cart.jsp" title="Cart">
                🛒 Cart
                <span id="fta-cart-badge"
                      style="display:none;background:#e23744;color:#fff;font-size:10px;font-weight:800;padding:2px 6px;border-radius:10px;margin-left:4px;">0</span>
            </a>

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
                     aria-valuetext="100% brightness"
                     title="Drag to adjust brightness"
                     onkeydown="handleBrightnessKeydown(event)">
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

<div class="page-container">
    <div class="page-title">
        <h1>Checkout</h1>
        <p>Complete your order and enjoy your meal</p>
    </div>

    <% if (cart.isEmpty()) { %>
        <div class="empty-cart">
            <h2>Your Cart is Empty</h2>
            <p>Add some delicious food before proceeding to checkout.</p>
            <a href="restaurants" class="browse-btn">Browse Restaurants</a>
        </div>
    <% } else { %>
        <form id="orderForm"
              action="${pageContext.request.contextPath}/place-order"
              method="post">

            <div class="checkout-layout">
                <div class="left-section">
                    <div class="card">
                        <h2>Delivery Details</h2>

                        <div class="form-group">
                            <label for="customerName">Full Name</label>
                            <input type="text"
                                   id="customerName"
                                   name="customerName"
                                   value="<%= user.getName() != null ? user.getName() : "" %>"
                                   placeholder="Enter your full name"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="phone">Phone Number</label>
                            <input type="text"
                                   id="phone"
                                   name="phone"
                                   value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                                   placeholder="Enter your phone number"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="address">Delivery Address</label>
                            <textarea id="address"
                                      name="address"
                                      placeholder="Enter your full delivery address"
                                      required><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>

                            <button type="button"
                                    class="location-button"
                                    id="locationButton"
                                    onclick="getLiveLocation()">Use My Live Location</button>

                            <div id="locationStatus" class="location-status">
                                Allow location access to automatically use your current location.
                            </div>
                        </div>
                    </div>

                    <div class="card">
                        <h2>Payment Method</h2>

                        <label class="payment-option">
                            <input type="radio" name="paymentOption" value="COD" checked onchange="showPaymentMethod()">
                            <span>Cash on Delivery</span>
                        </label>

                        <label class="payment-option">
                            <input type="radio" name="paymentOption" value="UPI" onchange="showPaymentMethod()">
                            <span>UPI Payment</span>
                        </label>

                        <label class="payment-option">
                            <input type="radio" name="paymentOption" value="CARD" onchange="showPaymentMethod()">
                            <span>Credit / Debit Card</span>
                        </label>

                        <div class="upi-section" id="upiSection">
                            <h3>Select UPI App</h3>

                            <div class="upi-apps">
                                <label class="upi-app">
                                    <input type="radio" name="upiMethod" value="Google Pay" onchange="selectUpiApp(this)">
                                    <img class="upi-logo" src="https://cdn.simpleicons.org/googlepay" alt="Google Pay">
                                    <span class="upi-app-name">Google Pay</span>
                                </label>

                                <label class="upi-app">
                                    <input type="radio" name="upiMethod" value="PhonePe" onchange="selectUpiApp(this)">
                                    <img class="upi-logo" src="https://cdn.simpleicons.org/phonepe" alt="PhonePe">
                                    <span class="upi-app-name">PhonePe</span>
                                </label>

                                <label class="upi-app">
                                    <input type="radio" name="upiMethod" value="Paytm" onchange="selectUpiApp(this)">
                                    <img class="upi-logo" src="https://cdn.simpleicons.org/paytm" alt="Paytm">
                                    <span class="upi-app-name">Paytm</span>
                                </label>

                                <label class="upi-app">
                                    <input type="radio" name="upiMethod" value="BHIM UPI" onchange="selectUpiApp(this)">
                                    <img class="upi-logo" src="https://cdn.simpleicons.org/bhim" alt="BHIM UPI">
                                    <span class="upi-app-name">BHIM UPI</span>
                                </label>
                            </div>

                            <div class="upi-selected-text" id="upiSelectedText">Select a UPI app</div>

                            <div class="form-group">
                                <label for="upiId">UPI ID</label>
                                <input type="text" id="upiId" name="upiId" placeholder="example@upi">
                            </div>
                        </div>

                        <div class="card-section" id="cardSection">
                            <h3>Card Details</h3>

                            <div class="form-group">
                                <label for="cardType">Card Type</label>
                                <select class="card-select" id="cardType" name="cardType">
                                    <option value="">Select Card Type</option>
                                    <option value="Credit Card">Credit Card</option>
                                    <option value="Debit Card">Debit Card</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="cardNumber">Card Number</label>
                                <div class="card-number-wrapper">
                                    <input class="card-input" type="text" id="cardNumber" name="cardNumber" maxlength="19" placeholder="1234 5678 9012 3456" inputmode="numeric">
                                    <span class="card-number-icon">CARD</span>
                                </div>
                                <div class="card-hint">Enter your 16-digit card number</div>
                            </div>

                            <div class="form-group">
                                <label for="cardHolderName">Cardholder Name</label>
                                <input class="card-input" type="text" id="cardHolderName" name="cardHolderName" placeholder="Name as shown on card">
                            </div>

                            <div class="card-security-row">
                                <div class="form-group">
                                    <label for="expiryDate">Expiry Date</label>
                                    <input class="card-input" type="text" id="expiryDate" name="expiryDate" maxlength="5" placeholder="MM/YY" inputmode="numeric">
                                </div>

                                <div class="form-group">
                                    <label for="cvv">CVV</label>
                                    <input class="card-input" type="password" id="cvv" name="cvv" maxlength="3" placeholder="123" inputmode="numeric">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card order-summary"
                     id="couponCheckoutBox"
                     data-food-total="<%= String.format(java.util.Locale.US, "%.2f", foodTotal) %>"
                     data-delivery-fee="<%= String.format(java.util.Locale.US, "%.2f", deliveryFee) %>"
                     data-platform-fee="<%= String.format(java.util.Locale.US, "%.2f", platformFee) %>"
                     data-current-streak="<%= currentOrderStreak %>"
                     data-birthday-eligible="<%= birthdayCouponEligible %>">

                    <h2>Order Summary</h2>

                    <% for (CartItem item : cart) {
                           if (item.getMenu() == null || item.getQuantity() <= 0) {
                               continue;
                           }
                    %>
                        <div class="citem">
                            <img class="citem-img"
                                 src="<%= item.getMenu().getImagePath() %>"
                                 alt="<%= item.getMenu().getName() %>"
                                 onerror="this.style.display='none';">

                            <div class="citem-d">
                                <h3><%= item.getMenu().getName() %></h3>
                                <p>Qty: <%= item.getQuantity() %></p>
                            </div>

                            <div class="citem-p">
                                &#8377;<%= String.format(java.util.Locale.US, "%.2f", item.getItemTotal()) %>
                            </div>
                        </div>
                    <% } %>

                    <!-- APPLY COUPON BEFORE PAYMENT -->
                    <section class="coupon-box" aria-label="Apply Offers and Rewards coupon">
                        <div class="coupon-heading">
                            <span class="coupon-heading-icon" aria-hidden="true">%</span>
                            <span>Offers &amp; Rewards</span>
                        </div>

                        <p class="coupon-description">
                            Enter a coupon from your SmartBite streak rewards or birthday offer.
                        </p>

                        <div class="coupon-input-row">
                            <input type="text"
                                   class="coupon-input"
                                   id="couponInput"
                                   placeholder="Enter coupon code"
                                   maxlength="30"
                                   autocomplete="off"
                                   aria-label="Coupon code">

                            <button type="button"
                                    class="coupon-action-btn"
                                    id="applyCouponBtn"
                                    onclick="applyCoupon()">Apply Coupon</button>
                        </div>

                        <button type="button"
                                class="coupon-remove-btn"
                                id="removeCouponBtn"
                                onclick="removeCoupon()">Remove Applied Coupon</button>

                        <div class="coupon-status"
                             id="couponStatus"
                             role="status"
                             aria-live="polite"></div>

                        <div class="eligible-coupons">
                            <% for (int i = 0; i < streakCouponCodes.length; i++) {
                                   if (currentOrderStreak >= streakRewardDays[i]) {
                            %>
                                <button type="button"
                                        class="eligible-coupon-btn"
                                        data-coupon="<%= streakCouponCodes[i] %>"
                                        onclick="quickApplyCoupon('<%= streakCouponCodes[i] %>')">
                                    <%= streakCouponCodes[i] %> · <%= streakRewardNames[i] %>
                                </button>
                            <%     }
                               }
                               if (birthdayCouponEligible) {
                            %>
                                <button type="button"
                                        class="eligible-coupon-btn"
                                        data-coupon="BIRTHDAY20"
                                        onclick="quickApplyCoupon('BIRTHDAY20')">
                                    BIRTHDAY20 · 20% OFF
                                </button>
                            <% } %>
                        </div>

                        <p class="eligible-coupon-note">
                            <% if (currentOrderStreak > 0 || birthdayCouponEligible) { %>
                                Tap one of your eligible coupons above, or enter the code manually.
                            <% } else { %>
                                Your eligible reward coupons will appear here when unlocked. Birthday coupon eligibility is checked from your saved profile birthday.
                            <% } %>
                            Discount is calculated on food items; delivery and platform fees remain unchanged.
                        </p>
                    </section>

                    <div class="summary-row">
                        <span>Food Total</span>
                        <span>&#8377;<%= String.format(java.util.Locale.US, "%.2f", foodTotal) %></span>
                    </div>

                    <div class="summary-row discount-row" id="couponDiscountRow" style="display:none;">
                        <span id="couponDiscountLabel">Coupon Discount</span>
                        <span id="couponDiscountValue">-&#8377;0.00</span>
                    </div>

                    <div class="summary-row">
                        <span>Delivery Fee</span>
                        <span>&#8377;<%= String.format(java.util.Locale.US, "%.2f", deliveryFee) %></span>
                    </div>

                    <div class="summary-row">
                        <span>Platform Fee</span>
                        <span>&#8377;<%= String.format(java.util.Locale.US, "%.2f", platformFee) %></span>
                    </div>

                    <div class="summary-row total">
                        <span>Grand Total</span>
                        <span id="grandTotalValue">&#8377;<%= String.format(java.util.Locale.US, "%.2f", grandTotal) %></span>
                    </div>

                    <input type="hidden"
                           name="totalAmount"
                           id="checkoutTotalAmount"
                           value="<%= String.format(java.util.Locale.US, "%.2f", grandTotal) %>">

                    <input type="hidden"
                           name="couponCode"
                           id="checkoutCouponCode"
                           value="">

                    <input type="hidden"
                           name="discountAmount"
                           id="checkoutDiscountAmount"
                           value="0.00">

                    <button type="submit" class="place-order-btn" id="proceedToPaymentBtn">
                        Proceed to Payment &#8377;<%= String.format(java.util.Locale.US, "%.2f", grandTotal) %>
                    </button>
                </div>
            </div>
        </form>
    <% } %>
</div>

<footer>
    <p>&copy; 2026 SmartBite Delivery Platform. All rights reserved.</p>
</footer>

<script>
/* Live location */
function getLiveLocation() {
    var button = document.getElementById("locationButton");
    var status = document.getElementById("locationStatus");
    var address = document.getElementById("address");

    if (!navigator.geolocation) {
        status.textContent = "Live location is not supported by this browser.";
        status.className = "location-status error";
        return;
    }

    button.disabled = true;
    button.textContent = "Getting Your Location...";
    status.textContent = "Please allow location access in your browser.";
    status.className = "location-status";

    navigator.geolocation.getCurrentPosition(
        function(position) {
            var latitude = position.coords.latitude;
            var longitude = position.coords.longitude;

            address.value = "Live Location: Latitude " + latitude.toFixed(6) +
                ", Longitude " + longitude.toFixed(6);

            status.textContent = "Live location captured successfully.";
            status.className = "location-status success";
            button.disabled = false;
            button.textContent = "Location Captured";
        },
        function(error) {
            button.disabled = false;
            button.textContent = "Use My Live Location";
            status.className = "location-status error";

            if (error.code === 1) {
                status.textContent = "Location permission was denied. Please allow location access.";
            } else if (error.code === 2) {
                status.textContent = "Your location could not be determined. Please try again.";
            } else if (error.code === 3) {
                status.textContent = "Location request timed out. Please try again.";
            } else {
                status.textContent = "Unable to get your location. Please try again.";
            }
        },
        { enableHighAccuracy: true, timeout: 15000, maximumAge: 0 }
    );
}

/* Payment selection */
function showPaymentMethod() {
    var selected = document.querySelector('input[name="paymentOption"]:checked');
    var upiSection = document.getElementById("upiSection");
    var cardSection = document.getElementById("cardSection");

    if (!selected || !upiSection || !cardSection) {
        return;
    }

    upiSection.style.display = "none";
    cardSection.style.display = "none";

    if (selected.value === "UPI") {
        upiSection.style.display = "block";
    }

    if (selected.value === "CARD") {
        cardSection.style.display = "block";
    }

    if (selected.value !== "UPI") {
        document.querySelectorAll('input[name="upiMethod"]').forEach(function(input) {
            input.checked = false;
        });

        document.querySelectorAll(".upi-app").forEach(function(app) {
            app.classList.remove("selected");
        });

        document.getElementById("upiId").value = "";
        document.getElementById("upiSelectedText").textContent = "Select a UPI app";
    }

    if (selected.value !== "CARD") {
        document.getElementById("cardType").value = "";
        document.getElementById("cardNumber").value = "";
        document.getElementById("cardHolderName").value = "";
        document.getElementById("expiryDate").value = "";
        document.getElementById("cvv").value = "";
    }
}

function selectUpiApp(input) {
    document.querySelectorAll(".upi-app").forEach(function(app) {
        app.classList.remove("selected");
    });

    var app = input.closest(".upi-app");

    if (app) {
        app.classList.add("selected");
        document.getElementById("upiSelectedText").textContent = "Selected: " + input.value;
    }
}

/* Card input formatting */
var cardNumber = document.getElementById("cardNumber");

if (cardNumber) {
    cardNumber.addEventListener("input", function() {
        var value = this.value.replace(/\D/g, "").substring(0, 16);
        var formatted = "";

        for (var i = 0; i < value.length; i++) {
            if (i > 0 && i % 4 === 0) {
                formatted += " ";
            }
            formatted += value[i];
        }

        this.value = formatted;
    });
}

var expiryDate = document.getElementById("expiryDate");

if (expiryDate) {
    expiryDate.addEventListener("input", function() {
        var value = this.value.replace(/\D/g, "").substring(0, 4);

        this.value = value.length >= 3
            ? value.substring(0, 2) + "/" + value.substring(2)
            : value;
    });
}

var cvv = document.getElementById("cvv");

if (cvv) {
    cvv.addEventListener("input", function() {
        this.value = this.value.replace(/\D/g, "").substring(0, 3);
    });
}

/* COUPON APPLICATION */
(function initialiseCheckoutCoupons() {
    var checkoutBox = document.getElementById("couponCheckoutBox");

    if (!checkoutBox) {
        return;
    }

    var foodTotal = parseFloat(checkoutBox.getAttribute("data-food-total")) || 0;
    var deliveryFee = parseFloat(checkoutBox.getAttribute("data-delivery-fee")) || 0;
    var platformFee = parseFloat(checkoutBox.getAttribute("data-platform-fee")) || 0;
    var currentStreak = parseInt(checkoutBox.getAttribute("data-current-streak"), 10) || 0;
    var birthdayEligible = checkoutBox.getAttribute("data-birthday-eligible") === "true";

    var couponInput = document.getElementById("couponInput");
    var couponStatus = document.getElementById("couponStatus");
    var couponDiscountRow = document.getElementById("couponDiscountRow");
    var couponDiscountLabel = document.getElementById("couponDiscountLabel");
    var couponDiscountValue = document.getElementById("couponDiscountValue");
    var grandTotalValue = document.getElementById("grandTotalValue");
    var totalAmountField = document.getElementById("checkoutTotalAmount");
    var couponCodeField = document.getElementById("checkoutCouponCode");
    var discountAmountField = document.getElementById("checkoutDiscountAmount");
    var removeCouponBtn = document.getElementById("removeCouponBtn");
    var applyCouponBtn = document.getElementById("applyCouponBtn");
    var proceedButton = document.getElementById("proceedToPaymentBtn");

    var originalGrandTotal = foodTotal + deliveryFee + platformFee;
    var appliedCouponCode = "";
    var appliedDiscount = 0;

    var couponRules = {
        BITE5:      { percent: 5,  streakDay: 1, label: "Day 1 reward · 5% OFF" },
        BITE10:     { percent: 10, streakDay: 2, label: "Day 2 reward · 10% OFF" },
        BITE15:     { percent: 15, streakDay: 3, label: "Day 3 reward · 15% OFF" },
        SMART20:    { percent: 20, streakDay: 4, label: "Day 4 reward · 20% OFF" },
        SMART25:    { percent: 25, streakDay: 5, label: "Day 5 reward · 25% OFF" },
        SMART30:    { percent: 30, streakDay: 6, label: "Day 6 reward · 30% OFF" },
        SMART40:    { percent: 40, streakDay: 7, label: "Day 7 reward · 40% OFF" },
        BIRTHDAY20: { percent: 20, birthdayOnly: true, label: "Birthday reward · 20% OFF" }
    };

    function money(value) {
        return "\u20B9" + Number(value).toLocaleString("en-IN", {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    function showCouponMessage(message, type) {
        couponStatus.textContent = message;
        couponStatus.className = "coupon-status" + (type ? " " + type : "");
    }

    function clearAppliedCoupon(clearInput) {
        appliedCouponCode = "";
        appliedDiscount = 0;

        couponCodeField.value = "";
        discountAmountField.value = "0.00";
        totalAmountField.value = originalGrandTotal.toFixed(2);

        couponDiscountRow.style.display = "none";
        couponDiscountLabel.textContent = "Coupon Discount";
        couponDiscountValue.textContent = "-" + money(0);
        grandTotalValue.textContent = money(originalGrandTotal);
        proceedButton.textContent = "Proceed to Payment " + money(originalGrandTotal);

        removeCouponBtn.style.display = "none";
        applyCouponBtn.textContent = "Apply Coupon";

        if (clearInput) {
            couponInput.value = "";
        }
    }

    function applyCouponCode(code) {
        var normalizedCode = String(code || "").trim().toUpperCase();

        if (!normalizedCode) {
            clearAppliedCoupon(false);
            showCouponMessage("Please enter a coupon code.", "error");
            couponInput.focus();
            return false;
        }

        var rule = couponRules[normalizedCode];

        if (!rule) {
            clearAppliedCoupon(false);
            showCouponMessage("This coupon code is invalid. Please check the code in Offers & Rewards.", "error");
            return false;
        }

        if (rule.streakDay && currentStreak < rule.streakDay) {
            clearAppliedCoupon(false);
            showCouponMessage(
                "This reward is not unlocked yet. Continue your order streak to unlock it.",
                "error"
            );
            return false;
        }

        if (rule.birthdayOnly && !birthdayEligible) {
            clearAppliedCoupon(false);
            showCouponMessage(
                "BIRTHDAY20 is available only on the birthday saved in your SmartBite profile.",
                "error"
            );
            return false;
        }

        var discount = Math.round(foodTotal * rule.percent) / 100;
        discount = Math.min(foodTotal, Math.max(0, discount));

        appliedCouponCode = normalizedCode;
        appliedDiscount = discount;

        var payableTotal = Math.max(
            0,
            foodTotal - appliedDiscount + deliveryFee + platformFee
        );

        couponInput.value = normalizedCode;
        couponCodeField.value = normalizedCode;
        discountAmountField.value = appliedDiscount.toFixed(2);
        totalAmountField.value = payableTotal.toFixed(2);

        couponDiscountRow.style.display = "flex";
        couponDiscountLabel.textContent = normalizedCode + " (" + rule.percent + "% OFF)";
        couponDiscountValue.textContent = "-" + money(appliedDiscount);
        grandTotalValue.textContent = money(payableTotal);
        proceedButton.textContent = "Proceed to Payment " + money(payableTotal);

        removeCouponBtn.style.display = "block";
        applyCouponBtn.textContent = "Applied ✓";

        showCouponMessage(
            normalizedCode + " applied successfully! You saved " + money(appliedDiscount) + ".",
            "success"
        );

        return true;
    }

    window.applyCoupon = function() {
        applyCouponCode(couponInput.value);
    };

    window.quickApplyCoupon = function(code) {
        applyCouponCode(code);
    };

    window.removeCoupon = function() {
        clearAppliedCoupon(true);
        showCouponMessage("Coupon removed. Your original total has been restored.", "");
    };

    couponInput.addEventListener("input", function() {
        this.value = this.value.toUpperCase();

        if (appliedCouponCode && this.value.trim() !== appliedCouponCode) {
            clearAppliedCoupon(false);
            showCouponMessage("Apply the new coupon code to update your total.", "");
        } else if (!appliedCouponCode) {
            showCouponMessage("", "");
        }
    });

    couponInput.addEventListener("keydown", function(event) {
        if (event.key === "Enter") {
            event.preventDefault();
            applyCouponCode(couponInput.value);
        }
    });

    clearAppliedCoupon(false);
})();

/* Checkout validation */
var orderForm = document.getElementById("orderForm");

if (orderForm) {
    orderForm.addEventListener("submit", function(event) {
        var selected = document.querySelector('input[name="paymentOption"]:checked');

        if (!selected) {
            event.preventDefault();
            alert("Please select a payment method.");
            return;
        }

        if (selected.value === "UPI") {
            var upiMethod = document.querySelector('input[name="upiMethod"]:checked');

            if (!upiMethod) {
                event.preventDefault();
                alert("Please select a UPI payment method.");
                return;
            }

            var upiId = document.getElementById("upiId").value.trim();

            if (upiId === "" || !upiId.includes("@")) {
                event.preventDefault();
                alert("Please enter a valid UPI ID.");
                return;
            }
        }

        if (selected.value === "CARD") {
            var cardType = document.getElementById("cardType").value;
            var cardNumberValue = document.getElementById("cardNumber").value.replace(/\s/g, "");
            var cardHolderName = document.getElementById("cardHolderName").value.trim();
            var expiry = document.getElementById("expiryDate").value.trim();
            var cvvValue = document.getElementById("cvv").value.trim();

            if (cardType === "") {
                event.preventDefault();
                alert("Please select Credit Card or Debit Card.");
                return;
            }

            if (!/^\d{16}$/.test(cardNumberValue)) {
                event.preventDefault();
                alert("Please enter a valid 16-digit card number.");
                return;
            }

            if (cardHolderName === "") {
                event.preventDefault();
                alert("Please enter the cardholder name.");
                return;
            }

            if (!/^\d{2}\/\d{2}$/.test(expiry)) {
                event.preventDefault();
                alert("Please enter the expiry date in MM/YY format.");
                return;
            }

            if (!/^\d{3}$/.test(cvvValue)) {
                event.preventDefault();
                alert("Please enter a valid 3-digit CVV.");
                return;
            }
        }
    });
}

showPaymentMethod();

/* Cart badge synchronization */
function updateCartBadge(count, updateStorage) {
    count = Math.max(0, parseInt(count, 10) || 0);

    var badge = document.getElementById("fta-cart-badge");

    if (badge) {
        badge.textContent = count;
        badge.style.display = count > 0 ? "inline-block" : "none";
    }

    if (updateStorage) {
        localStorage.setItem("smartbite_cart_count", String(count));
        localStorage.setItem("foodtap_cart_count", String(count));
    }
}

updateCartBadge(<%= initialCartCount %>, true);

window.addEventListener("storage", function(event) {
    if (event.key === "smartbite_cart_count" || event.key === "foodtap_cart_count") {
        updateCartBadge(event.newValue === null ? 0 : event.newValue, false);
    }
});

/* THEME AND BRIGHTNESS CONTROLS — MATCHING HOME.JSP */
var brightnessDragActive = false;
var currentBrightness = 1;
var brightnessMinimum = 0.5;
var brightnessMaximum = 1.5;

function setThemeMode(mode) {
    var isLight = mode === "light";

    document.body.classList.toggle("light-mode", isLight);

    try {
        localStorage.setItem("smartbite_theme", isLight ? "light" : "dark");
    } catch (e) {
        console.log("Unable to save theme preference.");
    }

    updateThemeButtonUI();
}

function toggleTheme() {
    var isLight = document.body.classList.contains("light-mode");
    setThemeMode(isLight ? "dark" : "light");
}

function updateThemeButtonUI() {
    var isLight = document.body.classList.contains("light-mode");
    var lightButton = document.getElementById("lightModeBtn");
    var darkButton = document.getElementById("darkModeBtn");

    if (lightButton) {
        lightButton.classList.toggle("active", isLight);
        lightButton.setAttribute("aria-pressed", String(isLight));
    }

    if (darkButton) {
        darkButton.classList.toggle("active", !isLight);
        darkButton.setAttribute("aria-pressed", String(!isLight));
    }
}

function updateBrightnessSlider(value) {
    var brightness = Math.min(1.5, Math.max(0.5, parseFloat(value) || 1));
    var percentage = ((brightness - 0.5) / 1.0) * 100;

    var slider = document.getElementById("brightnessSlider");
    var fill = document.getElementById("brightnessFill");
    var thumb = document.getElementById("brightnessThumb");

    if (fill) {
        fill.style.width = percentage + "%";
    }

    if (thumb) {
        thumb.style.left = percentage + "%";
    }

    if (slider) {
        slider.setAttribute("aria-valuenow", brightness.toFixed(2));
        slider.setAttribute("aria-valuetext", Math.round(brightness * 100) + "% brightness");
    }
}

function adjustBrightness(value) {
    var brightness = parseFloat(value);

    if (Number.isNaN(brightness) || brightness < brightnessMinimum || brightness > brightnessMaximum) {
        return;
    }

    currentBrightness = brightness;
    document.documentElement.style.filter = "brightness(" + brightness + ")";
    updateBrightnessSlider(brightness);

    try {
        localStorage.setItem("smartbite_brightness", String(brightness));
    } catch (e) {
        console.log("Unable to save brightness preference.");
    }
}

function attachBrightnessPointerEvents() {
    var slider = document.getElementById("brightnessSlider");

    if (!slider) {
        return;
    }

    slider.addEventListener("pointerdown", startBrightnessDrag);
    slider.addEventListener("pointermove", moveBrightnessDrag);
    slider.addEventListener("pointerup", stopBrightnessDrag);
    slider.addEventListener("pointercancel", stopBrightnessDrag);
    slider.addEventListener("lostpointercapture", stopBrightnessDrag);
}

function startBrightnessDrag(event) {
    if (event.button !== undefined && event.button !== 0) {
        return;
    }

    brightnessDragActive = true;

    if (event.currentTarget &&
        event.currentTarget.setPointerCapture &&
        event.pointerId !== undefined) {
        try {
            event.currentTarget.setPointerCapture(event.pointerId);
        } catch (e) {
            /* Pointer capture may be unavailable. */
        }
    }

    updateBrightnessFromPointer(event);
    event.preventDefault();
}

function moveBrightnessDrag(event) {
    if (!brightnessDragActive) {
        return;
    }

    updateBrightnessFromPointer(event);
    event.preventDefault();
}

function stopBrightnessDrag() {
    brightnessDragActive = false;
}

function updateBrightnessFromPointer(event) {
    var slider = document.getElementById("brightnessSlider");

    if (!slider) {
        return;
    }

    var rect = slider.getBoundingClientRect();

    if (!rect.width) {
        return;
    }

    var percentage = Math.min(1, Math.max(0, (event.clientX - rect.left) / rect.width));
    var brightness = 0.5 + percentage;

    adjustBrightness(brightness);
}

function handleBrightnessKeydown(event) {
    var slider = document.getElementById("brightnessSlider");

    if (!slider) {
        return;
    }

    var current = parseFloat(slider.getAttribute("aria-valuenow")) || 1;
    var next = current;

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

    next = Math.min(1.5, Math.max(0.5, Math.round(next * 100) / 100));
    adjustBrightness(next);
}

/* Restore saved theme and brightness settings */
(function initialiseThemeAndBrightness() {
    var savedTheme = null;
    var savedBrightness = 1;

    try {
        savedTheme = localStorage.getItem("smartbite_theme");

        var parsedBrightness = parseFloat(localStorage.getItem("smartbite_brightness"));

        if (Number.isFinite(parsedBrightness)) {
            savedBrightness = parsedBrightness;
        }
    } catch (e) {
        console.log("Unable to read saved theme preferences.");
    }

    setThemeMode(savedTheme === "light" ? "light" : "dark");

    savedBrightness = Math.min(1.5, Math.max(0.5, savedBrightness));
    currentBrightness = savedBrightness;

    document.documentElement.style.filter = "brightness(" + savedBrightness + ")";
    updateBrightnessSlider(savedBrightness);
    attachBrightnessPointerEvents();
})();
</script>

</body>
</html>
