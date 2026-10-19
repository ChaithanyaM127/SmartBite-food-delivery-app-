<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.foodtap.model.User" %>
<%@ page import="com.foodtap.model.CartItem" %>

<%!
    private String profileEscape(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");

    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String ctx = request.getContextPath();

    String customerName = loggedInUser.getName() == null
            ? "SmartBite Member" : loggedInUser.getName();

    String customerEmail = loggedInUser.getEmail() == null
            ? "" : loggedInUser.getEmail();

    String customerPhone = loggedInUser.getPhone() == null
            ? "" : loggedInUser.getPhone();

    String customerAddress = loggedInUser.getAddress() == null
            ? "" : loggedInUser.getAddress();

    String customerRole = loggedInUser.getRole() == null
            ? "Customer" : loggedInUser.getRole();

    LocalDate dateOfBirth = loggedInUser.getDateOfBirth();

    String birthdayValue = dateOfBirth == null
            ? "" : dateOfBirth.toString();

    String birthdayDisplay = dateOfBirth == null
            ? "Add your birthday"
            : dateOfBirth.format(DateTimeFormatter.ofPattern("dd MMMM yyyy"));

    List<CartItem> cartItems = new ArrayList<>();
    Object cartObject = session.getAttribute("cart");

    if (cartObject instanceof List<?>) {
        for (Object item : (List<?>) cartObject) {
            if (item instanceof CartItem) {
                cartItems.add((CartItem) item);
            }
        }
    }

    int cartCount = 0;

    for (CartItem item : cartItems) {
        if (item != null && item.getQuantity() > 0) {
            cartCount += item.getQuantity();
        }
    }

    String profileStatus = request.getParameter("profileStatus");
    String birthdayStatus = request.getParameter("birthdayStatus");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="theme-color" content="#0d0d0f">

<title>My Profile | SmartBite</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<style>
:root {
    color-scheme: dark;
    --bg-page: #0d0d0f;
    --bg-card-dark: #121318;
    --bg-card-bottom: #1e1e24;
    --text-main: #ffffff;
    --text-muted: #a1a1aa;
    --text-soft: #777781;
    --nav-bg: rgba(13,13,15,.90);
    --nav-border: rgba(255,255,255,.08);
    --panel-border: rgba(255,255,255,.08);
    --metric-bg: rgba(255,255,255,.04);
    --accent: #e23744;
    --accent-hover: #c92e3a;
    --accent-soft: rgba(226,55,68,.12);
    --accent-glow: rgba(226,55,68,.25);
    --accent-gradient: linear-gradient(135deg,#ff4757,#e23744);
    --shadow: 0 16px 36px rgba(0,0,0,.4);
}

body.light-mode {
    color-scheme: light;
    --bg-page: #f1f3f5;
    --bg-card-dark: #ffffff;
    --bg-card-bottom: #ffffff;
    --text-main: #111827;
    --text-muted: #6b7280;
    --text-soft: #858b96;
    --nav-bg: rgba(255,255,255,.95);
    --nav-border: rgba(0,0,0,.08);
    --panel-border: rgba(0,0,0,.08);
    --metric-bg: rgba(0,0,0,.03);
    --accent: #e23744;
    --accent-hover: #c92e3a;
    --accent-soft: rgba(226,55,68,.08);
    --accent-glow: rgba(226,55,68,.13);
    --accent-gradient: linear-gradient(135deg,#ff4757,#e23744);
    --shadow: 0 10px 25px rgba(0,0,0,.06);
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
    min-height: 100vh;
    background: var(--bg-page);
    color: var(--text-main);
    font-family: 'Plus Jakarta Sans', sans-serif;
    -webkit-font-smoothing: antialiased;
    transition: background .25s ease, color .25s ease;
}

a {
    color: inherit;
    text-decoration: none;
}

button, input, textarea {
    font: inherit;
}

button, a, input {
    -webkit-tap-highlight-color: transparent;
}

button:focus-visible,
a:focus-visible,
input:focus-visible,
textarea:focus-visible {
    outline: 2px solid var(--accent);
    outline-offset: 3px;
}

/* Navbar */
.navbar {
    min-height: 72px;
    padding: 14px 24px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
    position: sticky;
    top: 0;
    z-index: 100;
    background: var(--nav-bg);
    border-bottom: 1px solid var(--nav-border);
    backdrop-filter: blur(18px);
    -webkit-backdrop-filter: blur(18px);
}

.logo {
    font-size: 26px;
    font-weight: 800;
    letter-spacing: -1.3px;
    white-space: nowrap;
    flex-shrink: 0;
}

.logo span {
    color: var(--accent);
}

/* Home, Restaurants, Orders, Cart, Profile and theme controls
   all stay together in the same navbar group. */
.nav-actions {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 13px;
    min-width: 0;
}

.nav-links {
    display: flex;
    align-items: center;
    gap: 22px;
}

.nav-links a {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 700;
    white-space: nowrap;
    transition: color .2s ease;
}

.nav-links a:hover,
.nav-links a.active {
    color: var(--accent);
}

.nav-icon {
    min-width: 42px;
    min-height: 42px;
    padding: 0 12px;
    display: inline-flex;
    justify-content: center;
    align-items: center;
    gap: 7px;
    border: 1px solid var(--panel-border);
    border-radius: 12px;
    background: var(--metric-bg);
    color: var(--text-main);
    cursor: pointer;
    font-size: 13px;
    font-weight: 700;
    transition: border-color .2s ease, color .2s ease, background .2s ease;
}

.nav-icon:hover {
    border-color: var(--accent);
    color: var(--accent);
}

.cart-count {
    min-width: 19px;
    height: 19px;
    padding: 0 5px;
    display: inline-flex;
    justify-content: center;
    align-items: center;
    border-radius: 20px;
    background: var(--accent);
    color: #fff;
    font-size: 10px;
    font-weight: 800;
}

.cart-nav-button {
    white-space: nowrap;
    flex-shrink: 0;
}

/* Profile icon: 30 x 30px */
.profile-icon-button {
    width: 30px;
    height: 30px;
    min-width: 30px;
    min-height: 30px;
    flex: 0 0 30px;
    padding: 0;
    border-radius: 50%;
    font-size: 14px;
}

/* Same Home page theme-control layout */
.controls-box {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    padding: 5px 9px;
    border-radius: 30px;
    flex-shrink: 0;
}

.theme-mode-btn {
    width: 25px;
    height: 25px;
    min-width: 25px;
    min-height: 25px;
    padding: 0;
    border: 1px solid transparent;
    border-radius: 50%;
    background: transparent;
    color: var(--text-muted);
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 15px;
    line-height: 1;
    flex-shrink: 0;
    transition:
        background .2s ease,
        color .2s ease,
        border-color .2s ease,
        transform .2s ease;
}

.theme-mode-btn:hover {
    color: var(--text-main);
    transform: scale(1.06);
}

.theme-mode-btn.active {
    color: var(--accent);
    background: rgba(226,55,68,.10);
    border-color: rgba(226,55,68,.25);
}

/* Ultra-thin draggable brightness slider */
.brightness-slider {
    position: relative;
    width: 58px;
    min-width: 58px;
    height: 16px;
    flex-shrink: 0;
    cursor: pointer;
    touch-action: none;
    outline: none;
    -webkit-tap-highlight-color: transparent;
    user-select: none;
}

.brightness-track {
    position: absolute;
    top: 50%;
    left: 0;
    width: 100%;
    height: 2px;
    transform: translateY(-50%);
    border-radius: 10px;
    background: var(--text-muted);
    opacity: .55;
    pointer-events: none;
}

.brightness-fill {
    position: absolute;
    top: 50%;
    left: 0;
    width: 50%;
    height: 2px;
    transform: translateY(-50%);
    border-radius: 10px;
    background: var(--accent);
    pointer-events: none;
}

.brightness-thumb {
    position: absolute;
    top: 50%;
    left: 50%;
    width: 8px;
    height: 8px;
    transform: translate(-50%, -50%);
    border-radius: 50%;
    background: var(--accent);
    border: 1px solid var(--accent);
    box-shadow: 0 0 0 2px var(--nav-bg);
    pointer-events: none;
    transition: box-shadow .15s ease;
}

.brightness-slider:hover .brightness-thumb,
.brightness-slider:focus-visible .brightness-thumb {
    box-shadow: 0 0 0 3px var(--accent-glow);
}

.brightness-slider:focus-visible {
    outline: none;
}

.page-shell {
    width: min(1120px, calc(100% - 48px));
    margin: 38px auto 70px;
}

.page-heading {
    margin-bottom: 25px;
}

.eyebrow {
    margin-bottom: 12px;
    color: var(--accent);
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 1.8px;
    text-transform: uppercase;
}

.page-heading h1 {
    margin-bottom: 11px;
    font-size: clamp(30px, 4vw, 43px);
    font-weight: 800;
    letter-spacing: -1.7px;
    line-height: 1.2;
}

.page-heading p {
    max-width: 620px;
    color: var(--text-muted);
    font-size: 14px;
    line-height: 1.8;
}

.profile-cover {
    min-height: 275px;
    position: relative;
    overflow: hidden;
    margin-bottom: 24px;
    border: 1px solid var(--panel-border);
    border-radius: 20px;
    background-color: #18181d;
    background-image:
        linear-gradient(90deg,rgba(13,13,15,.94) 0%,
        rgba(13,13,15,.78) 48%,rgba(13,13,15,.34) 100%),
        url('https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1800&q=85');
    background-size: cover;
    background-position: center 52%;
    box-shadow: var(--shadow);
}

.cover-content {
    min-height: 275px;
    padding: 36px 38px;
    display: flex;
    align-items: center;
    gap: 27px;
    position: relative;
    z-index: 1;
}

.avatar-wrap {
    width: 124px;
    height: 124px;
    position: relative;
    flex-shrink: 0;
}

.avatar {
    width: 124px;
    height: 124px;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    border: 3px solid var(--accent);
    border-radius: 50%;
    background: #24242a;
    box-shadow: 0 8px 32px rgba(0,0,0,.35);
}

.avatar img {
    display: none;
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.avatar-fallback {
    color: #fff;
    font-size: 48px;
    font-weight: 700;
}

.camera-button {
    width: 39px;
    height: 39px;
    position: absolute;
    right: 0;
    bottom: 1px;
    display: flex;
    justify-content: center;
    align-items: center;
    border: 3px solid #17171b;
    border-radius: 50%;
    background: var(--accent);
    color: white;
    cursor: pointer;
    font-size: 16px;
    transition: transform .2s ease, background .2s ease;
}

.camera-button:hover {
    transform: scale(1.07);
    background: var(--accent-hover);
}

.cover-copy {
    min-width: 0;
    color: #fff;
}

.cover-label {
    margin-bottom: 11px;
    color: #ffb8be;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 1.8px;
}

.cover-copy h2 {
    margin-bottom: 9px;
    font-size: clamp(25px, 3vw, 34px);
    font-weight: 800;
    letter-spacing: -1px;
    overflow-wrap: anywhere;
}

.member-label {
    margin-bottom: 15px;
    color: #e4dfe0;
    font-size: 13px;
}

.photo-action {
    padding: 10px 13px;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    border: 1px solid rgba(255,255,255,.22);
    border-radius: 10px;
    background: rgba(255,255,255,.07);
    color: white;
    cursor: pointer;
    font-size: 12px;
    font-weight: 700;
    transition: .2s ease;
}

.photo-action:hover {
    border-color: var(--accent);
    background: rgba(226,55,68,.18);
}

.cover-tagline {
    max-width: 190px;
    margin-left: auto;
    align-self: flex-end;
    color: rgba(255,255,255,.82);
    font-size: 13px;
    line-height: 1.8;
    text-align: right;
}

.card {
    min-width: 0;
    padding: 27px;
    border: 1px solid var(--panel-border);
    border-radius: 18px;
    background: var(--bg-card-dark);
    box-shadow: var(--shadow);
    transition: background .25s ease, border-color .25s ease;
}

.card-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    margin-bottom: 24px;
}

.card-heading h2 {
    font-size: 19px;
    font-weight: 800;
    letter-spacing: -.5px;
}

.card-heading p {
    margin-top: 7px;
    color: var(--text-muted);
    font-size: 12px;
    line-height: 1.7;
}

.btn {
    padding: 11px 16px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    border: 1px solid transparent;
    border-radius: 12px;
    cursor: pointer;
    font-size: 12px;
    font-weight: 800;
    transition: transform .2s ease, background .2s ease, border-color .2s ease;
}

.btn:hover {
    transform: translateY(-1px);
}

.btn-primary {
    border-color: transparent;
    background: var(--accent-gradient);
    color: #fff;
    box-shadow: 0 5px 15px var(--accent-glow);
}

.btn-primary:hover {
    background: linear-gradient(135deg,#ed3e4c,#c92e3a);
}

.btn-secondary {
    border-color: var(--panel-border);
    background: var(--metric-bg);
    color: var(--text-main);
}

.btn-secondary:hover {
    border-color: var(--accent);
    color: var(--accent);
}

.btn-text {
    border-color: var(--panel-border);
    background: transparent;
    color: var(--text-main);
}

.btn-text:hover {
    border-color: var(--accent);
    color: var(--accent);
}

.notice {
    padding: 14px 16px;
    margin-bottom: 20px;
    border: 1px solid var(--panel-border);
    border-radius: 12px;
    background: var(--bg-card-dark);
    font-size: 13px;
    line-height: 1.7;
}

.notice.success {
    border-color: rgba(64,180,110,.35);
    color: #64d995;
}

.notice.error {
    border-color: rgba(255,100,100,.35);
    color: #ff9292;
}

.notice.info {
    color: var(--text-muted);
}

.info-grid {
    display: grid;
    grid-template-columns: repeat(2,minmax(0,1fr));
    gap: 0 30px;
}

.info-item {
    min-width: 0;
    padding: 19px 0;
    display: flex;
    align-items: flex-start;
    gap: 14px;
    border-bottom: 1px solid var(--panel-border);
}

.info-icon {
    width: 42px;
    height: 42px;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 13px;
    background: var(--accent-soft);
    color: var(--accent);
    font-size: 18px;
}

.info-copy {
    min-width: 0;
}

.info-label {
    margin: 2px 0 8px;
    color: var(--text-soft);
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 1.2px;
}

.info-value {
    color: var(--text-main);
    font-size: 14px;
    line-height: 1.8;
    overflow-wrap: anywhere;
}

.info-sub {
    margin-top: 4px;
    color: var(--text-muted);
    font-size: 11px;
}

.edit-form {
    display: none;
    margin-top: 24px;
    padding-top: 23px;
    border-top: 1px solid var(--panel-border);
}

.edit-form.visible {
    display: block;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(2,minmax(0,1fr));
    gap: 18px;
}

.form-group {
    min-width: 0;
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.form-group.full-width {
    grid-column: 1 / -1;
}

.form-group label {
    color: var(--text-muted);
    font-size: 12px;
    font-weight: 700;
}

.form-group input,
.form-group textarea {
    width: 100%;
    min-width: 0;
    padding: 13px 14px;
    border: 1px solid var(--panel-border);
    border-radius: 12px;
    background: var(--bg-page);
    color: var(--text-main);
    font-size: 13px;
    transition: border-color .2s ease, background .2s ease;
}

.form-group textarea {
    min-height: 92px;
    resize: vertical;
}

.form-group input:focus,
.form-group textarea:focus {
    outline: none;
    border-color: var(--accent);
}

.form-group input[readonly] {
    opacity: .7;
    cursor: not-allowed;
}

.form-group input[type="date"] {
    color-scheme: inherit;
}

.form-actions {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
    margin-top: 20px;
}

.lower-grid {
    display: grid;
    grid-template-columns: 1.15fr .85fr;
    gap: 24px;
    margin-top: 24px;
}

.birthday-card {
    position: relative;
    overflow: hidden;
}

.birthday-card::before {
    content: "";
    width: 150px;
    height: 150px;
    position: absolute;
    top: -50px;
    right: -45px;
    border-radius: 50%;
    background: var(--accent-soft);
    pointer-events: none;
}

.birthday-icon {
    width: 47px;
    height: 47px;
    margin-bottom: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 14px;
    background: var(--accent-soft);
    color: var(--accent);
    font-size: 22px;
}

.birthday-date {
    margin: 11px 0;
    font-size: 19px;
    font-weight: 800;
    overflow-wrap: anywhere;
}

.card-description {
    margin-bottom: 19px;
    color: var(--text-muted);
    font-size: 12px;
    line-height: 1.9;
}

.quick-links {
    display: flex;
    flex-direction: column;
    gap: 11px;
}

.quick-link {
    min-height: 61px;
    padding: 13px 14px;
    display: flex;
    align-items: center;
    gap: 13px;
    border: 1px solid var(--panel-border);
    border-radius: 12px;
    background: var(--bg-card-bottom);
    transition: border-color .2s ease, transform .2s ease, background .2s ease;
}

.quick-link:hover {
    transform: translateY(-1px);
    border-color: var(--accent);
}

.quick-link-icon {
    width: 37px;
    height: 37px;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 11px;
    background: var(--accent-soft);
    color: var(--accent);
    font-size: 17px;
}

.quick-link-copy {
    min-width: 0;
    flex: 1;
    display: flex;
    flex-direction: column;
}

.quick-link-copy strong {
    display: block;
    margin-bottom: 4px;
    font-size: 12px;
    font-weight: 800;
}

.quick-link-copy > span {
    display: block;
    color: var(--text-muted);
    font-size: 11px;
    line-height: 1.6;
}

.quick-arrow {
    color: var(--text-soft);
    font-size: 18px;
}

.footer {
    padding: 27px 5%;
    border-top: 1px solid var(--panel-border);
    color: var(--text-soft);
    font-size: 11px;
    line-height: 1.9;
    text-align: center;
}

.footer strong {
    color: var(--accent);
    font-size: 14px;
    font-weight: 800;
}

#photoInput {
    display: none;
}

.photo-message {
    display: none;
    margin-top: 12px;
    color: #f1c1c5;
    font-size: 12px;
    line-height: 1.7;
}

.photo-message.visible {
    display: block;
}

/* Responsive navbar */
@media (max-width: 1200px) {
    .navbar {
        padding-right: 18px;
        padding-left: 18px;
        gap: 14px;
    }

    .nav-actions {
        gap: 10px;
    }

    .nav-links {
        gap: 15px;
    }

    .nav-links a {
        font-size: 12px;
    }
}

@media (max-width: 980px) {
    .navbar {
        flex-wrap: wrap;
    }

    .nav-actions {
        flex-wrap: wrap;
        justify-content: flex-end;
        flex: 1 1 auto;
    }

    .nav-links {
        gap: 12px;
    }

    .cover-tagline {
        display: none;
    }

    .lower-grid {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 700px) {
    .navbar {
        padding: 11px 14px;
        gap: 10px;
    }

    .logo {
        font-size: 22px;
    }

    .nav-actions {
        width: 100%;
        justify-content: flex-end;
        gap: 8px;
    }

    .nav-links {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
        margin-right: auto;
    }

    .nav-links a {
        font-size: 12px;
    }

    .nav-icon {
        min-width: 36px;
        min-height: 36px;
        padding: 0 8px;
        border-radius: 10px;
        font-size: 11px;
    }

    .profile-icon-button {
        width: 30px;
        height: 30px;
        min-width: 30px;
        min-height: 30px;
        padding: 0;
        border-radius: 50%;
        font-size: 14px;
    }

    .controls-box {
        gap: 6px;
        padding: 4px 6px;
    }

    .brightness-slider {
        width: 46px;
        min-width: 46px;
    }

    .page-shell {
        width: calc(100% - 28px);
        margin: 27px auto 45px;
    }

    .page-heading h1 {
        font-size: 31px;
        letter-spacing: -1.2px;
    }

    .page-heading p {
        font-size: 13px;
    }

    .profile-cover,
    .cover-content {
        min-height: 0;
    }

    .cover-content {
        padding: 27px 20px;
        flex-direction: column;
        align-items: flex-start;
        gap: 19px;
    }

    .avatar-wrap,
    .avatar {
        width: 105px;
        height: 105px;
    }

    .avatar-fallback {
        font-size: 40px;
    }

    .cover-copy h2 {
        font-size: 26px;
    }

    .card {
        padding: 20px;
        border-radius: 15px;
    }

    .card-heading {
        align-items: flex-start;
        margin-bottom: 17px;
    }

    .card-heading h2 {
        font-size: 17px;
    }

    .info-grid,
    .form-grid {
        grid-template-columns: 1fr;
    }

    .form-group.full-width {
        grid-column: auto;
    }

    .info-item {
        padding: 15px 0;
    }

    .form-actions .btn {
        flex: 1;
    }
}

@media (max-width: 480px) {
    .navbar {
        padding-right: 10px;
        padding-left: 10px;
    }

    .nav-actions {
        gap: 6px;
    }

    .nav-links {
        gap: 9px;
    }

    .nav-links a {
        font-size: 11px;
    }

    .controls-box {
        gap: 5px;
        padding: 4px 5px;
    }

    .brightness-slider {
        width: 40px;
        min-width: 40px;
    }
}

@media (max-width: 380px) {
    .nav-actions {
        justify-content: flex-start;
    }

    .nav-links {
        width: 100%;
        margin: 0;
        justify-content: space-between;
    }
}

@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        transition-duration: .01ms !important;
        scroll-behavior: auto !important;
    }
}
</style>
</head>

<body>

<header class="navbar">
    <a href="<%= ctx %>/home.jsp" class="logo">Smart<span>Bite</span></a>

    <div class="nav-actions">

        <nav class="nav-links" aria-label="Main navigation">
            <a href="<%= ctx %>/home.jsp">Home</a>
            <a href="<%= ctx %>/restaurants">Restaurants</a>
            <a href="<%= ctx %>/orders.jsp">Orders</a>
        </nav>

        <a class="nav-icon cart-nav-button"
           href="<%= ctx %>/cart.jsp"
           aria-label="Shopping cart">
            🛒 Cart <span class="cart-count"><%= cartCount %></span>
        </a>

        <a class="nav-icon profile-icon-button"
           href="<%= ctx %>/profile.jsp"
           aria-label="My profile"
           title="My profile">👤</a>

        <div class="controls-box" aria-label="Theme and brightness controls">

            <button
                type="button"
                class="theme-mode-btn"
                id="lightModeBtn"
                onclick="setThemeMode('light')"
                title="Light Mode"
                aria-label="Switch to Light Mode"
                aria-pressed="false">☀</button>

            <div
                class="brightness-slider"
                id="brightnessSlider"
                role="slider"
                tabindex="0"
                aria-label="Adjust screen brightness"
                aria-valuemin="0.5"
                aria-valuemax="1.5"
                aria-valuenow="1"
                aria-valuetext="100 percent brightness"
                title="Drag to adjust brightness"
                onkeydown="handleBrightnessKeydown(event)">

                <span class="brightness-track" aria-hidden="true"></span>
                <span class="brightness-fill" id="brightnessFill" aria-hidden="true"></span>
                <span class="brightness-thumb" id="brightnessThumb" aria-hidden="true"></span>
            </div>

            <button
                type="button"
                class="theme-mode-btn"
                id="darkModeBtn"
                onclick="setThemeMode('dark')"
                title="Dark Mode"
                aria-label="Switch to Dark Mode"
                aria-pressed="true">☾</button>

        </div>
    </div>
</header>

<main class="page-shell">

    <section class="page-heading">
        <div class="eyebrow">✦ YOUR SMARTBITE ACCOUNT</div>
        <h1>Your profile, <span style="color:var(--accent)">your way.</span></h1>
        <p>
            Manage your personal details, keep your birthday updated,
            and make every SmartBite order feel a little more personal.
        </p>
    </section>

    <% if ("success".equals(profileStatus)) { %>
        <div class="notice success" role="status">
            ✓ Your profile details have been updated successfully.
        </div>
    <% } else if ("invalid".equals(profileStatus)) { %>
        <div class="notice error" role="alert">
            Please check your name, phone number, and address, then try again.
        </div>
    <% } else if ("error".equals(profileStatus)) { %>
        <div class="notice error" role="alert">
            We could not save your profile details. Please try again.
        </div>
    <% } %>

    <% if ("success".equals(birthdayStatus)) { %>
        <div class="notice success" role="status">
            ✓ Your birthday has been saved successfully.
        </div>
    <% } else if ("invalid".equals(birthdayStatus)) { %>
        <div class="notice error" role="alert">
            Please choose a valid birthday that is not in the future.
        </div>
    <% } else if ("error".equals(birthdayStatus)) { %>
        <div class="notice error" role="alert">
            Your birthday could not be saved. Please try again.
        </div>
    <% } %>

    <section class="profile-cover" aria-label="Customer profile">
        <div class="cover-content">
            <div class="avatar-wrap">
                <div class="avatar">
                    <span class="avatar-fallback" id="avatarFallback">👤</span>
                    <img id="profilePhoto" alt="Your profile photo">
                </div>

                <button class="camera-button" type="button"
                        onclick="document.getElementById('photoInput').click()"
                        aria-label="Choose profile photo" title="Choose profile photo">
                    📷
                </button>
            </div>

            <div class="cover-copy">
                <div class="cover-label">YOUR ACCOUNT</div>
                <h2><%= profileEscape(customerName) %></h2>
                <div class="member-label">
                    ✦ <%= profileEscape(customerRole) %> · SmartBite Member
                </div>

                <button type="button" class="photo-action"
                        onclick="document.getElementById('photoInput').click()">
                    📷 Change profile photo
                </button>

                <input type="file" id="photoInput" accept="image/*">

                <div class="photo-message" id="photoMessage" aria-live="polite">
                    Your photo preview is ready.
                    Select Save Photo to keep it in this browser.
                </div>

                <div class="form-actions" id="photoActions" style="display:none">
                    <button type="button" class="btn btn-primary"
                            onclick="savePhotoLocally()">Save Photo</button>
                    <button type="button" class="btn btn-secondary"
                            onclick="cancelPhotoChange()">Cancel</button>
                </div>
            </div>

            <p class="cover-tagline">
                Your food journey,<br>
                your preferences.
            </p>
        </div>
    </section>

    <section class="card" id="personalInformation">
        <div class="card-heading">
            <div>
                <h2>Personal information</h2>
                <p>Your account details and delivery information.</p>
            </div>

            <button class="btn btn-secondary" type="button"
                    id="editButton" onclick="showEditForm()">
                ✎ Edit Profile
            </button>
        </div>

        <div class="info-grid" id="profileDetails">
            <div class="info-item">
                <div class="info-icon">♙</div>
                <div class="info-copy">
                    <div class="info-label">FULL NAME</div>
                    <div class="info-value"><%= profileEscape(customerName) %></div>
                </div>
            </div>

            <div class="info-item">
                <div class="info-icon">✉</div>
                <div class="info-copy">
                    <div class="info-label">EMAIL ADDRESS</div>
                    <div class="info-value"><%= profileEscape(customerEmail) %></div>
                    <div class="info-sub">Your registered email</div>
                </div>
            </div>

            <div class="info-item">
                <div class="info-icon">☎</div>
                <div class="info-copy">
                    <div class="info-label">PHONE NUMBER</div>
                    <div class="info-value">
                        <%= customerPhone.trim().isEmpty()
                            ? "Add your phone number"
                            : profileEscape(customerPhone) %>
                    </div>
                </div>
            </div>

            <div class="info-item">
                <div class="info-icon">⌖</div>
                <div class="info-copy">
                    <div class="info-label">DELIVERY ADDRESS</div>
                    <div class="info-value">
                        <%= customerAddress.trim().isEmpty()
                            ? "Add your delivery address"
                            : profileEscape(customerAddress) %>
                    </div>
                </div>
            </div>
        </div>

        <form class="edit-form" id="editForm"
              action="<%= ctx %>/update-profile" method="post">
            <div class="form-grid">
                <div class="form-group">
                    <label for="name">Full name</label>
                    <input id="name" name="name" type="text"
                           value="<%= profileEscape(customerName) %>"
                           maxlength="100" autocomplete="name" required>
                </div>

                <div class="form-group">
                    <label for="email">Email address</label>
                    <input id="email" type="email"
                           value="<%= profileEscape(customerEmail) %>"
                           autocomplete="email" readonly>
                </div>

                <div class="form-group">
                    <label for="phone">Phone number</label>
                    <input id="phone" name="phone" type="tel"
                           value="<%= profileEscape(customerPhone) %>"
                           maxlength="20" autocomplete="tel">
                </div>

                <div class="form-group full-width">
                    <label for="address">Delivery address</label>
                    <textarea id="address" name="address"
                              maxlength="500" autocomplete="street-address"
                              placeholder="Enter your delivery address"><%= profileEscape(customerAddress) %></textarea>
                </div>
            </div>

            <div class="form-actions">
                <button class="btn btn-primary" type="submit">Save Changes →</button>
                <button class="btn btn-secondary" type="button"
                        onclick="hideEditForm()">Cancel</button>
            </div>
        </form>
    </section>

    <div class="lower-grid">
        <section class="card birthday-card">
            <div class="birthday-icon">🎂</div>

            <div class="eyebrow">A LITTLE SOMETHING SPECIAL</div>
            <h2 style="font-size:21px;font-weight:800;">Your birthday</h2>

            <div class="birthday-date"><%= profileEscape(birthdayDisplay) %></div>

            <p class="card-description">
                Keep your birthday up to date so SmartBite can recognise
                your special day and check eligibility for birthday offers.
            </p>

            <form action="<%= ctx %>/update-birthday" method="post">
                <div class="form-group">
                    <label for="dateOfBirth">Date of birth</label>
                    <input id="dateOfBirth" name="dateOfBirth" type="date"
                           value="<%= birthdayValue %>"
                           max="<%= LocalDate.now() %>" required>
                </div>

                <div class="form-actions">
                    <button class="btn btn-primary" type="submit">Save Birthday →</button>
                </div>
            </form>
        </section>

        <section class="card">
            <div class="card-heading">
                <div>
                    <h2>Your SmartBite</h2>
                    <p>Everything you need, just a tap away.</p>
                </div>
            </div>

            <div class="quick-links">
                <a class="quick-link" href="<%= ctx %>/orders">
                    <span class="quick-link-icon">▤</span>
                    <span class="quick-link-copy">
                        <strong>My Orders</strong>
                        <span>View your food-order history</span>
                    </span>
                    <span class="quick-arrow">›</span>
                </a>

                <a class="quick-link" href="<%= ctx %>/cart.jsp">
                    <span class="quick-link-icon">🛒</span>
                    <span class="quick-link-copy">
                        <strong>My Cart</strong>
                        <span><%= cartCount %> item(s) in your cart</span>
                    </span>
                    <span class="quick-arrow">›</span>
                </a>

                <a class="quick-link" href="<%= ctx %>/home.jsp">
                    <span class="quick-link-icon">♡</span>
                    <span class="quick-link-copy">
                        <strong>My Wellness</strong>
                        <span>Explore food and nutrition</span>
                    </span>
                    <span class="quick-arrow">›</span>
                </a>

                <a class="quick-link" href="<%= ctx %>/home.jsp">
                    <span class="quick-link-icon">✦</span>
                    <span class="quick-link-copy">
                        <strong>Explore SmartBite</strong>
                        <span>Discover restaurants and BiteAI</span>
                    </span>
                    <span class="quick-arrow">›</span>
                </a>

                <a class="quick-link" href="<%= ctx %>/logout">
                    <span class="quick-link-icon">⇥</span>
                    <span class="quick-link-copy">
                        <strong>Log out</strong>
                        <span>Sign out of your account</span>
                    </span>
                    <span class="quick-arrow">›</span>
                </a>
            </div>
        </section>
    </div>
</main>

<footer class="footer">
    <strong>SmartBite</strong><br>
    Good food. Smarter choices.<br>
    © 2026 SmartBite Delivery Platform. All rights reserved.
</footer>

<jsp:include page="ai-assistant.jsp" />

<script>
/* SmartBite theme and brightness preferences */
(function () {
    let savedTheme = "dark";
    let savedBrightness = 1;

    try {
        savedTheme = localStorage.getItem("smartbite_theme") || "dark";

        const storedBrightness = localStorage.getItem("smartbite_brightness");

        if (storedBrightness !== null) {
            const parsedBrightness = parseFloat(storedBrightness);

            if (Number.isFinite(parsedBrightness)) {
                savedBrightness = Math.min(1.5, Math.max(0.5, parsedBrightness));
            }
        }
    } catch (e) {
        // Keep defaults if browser storage is unavailable.
    }

    document.body.classList.toggle("light-mode", savedTheme === "light");

    updateBrightnessSlider(savedBrightness, false);
    updateThemeButtonUI();

    const slider = document.getElementById("brightnessSlider");

    if (slider) {
        let isDragging = false;

        slider.addEventListener("pointerdown", function (event) {
            isDragging = true;

            if (slider.setPointerCapture) {
                slider.setPointerCapture(event.pointerId);
            }

            updateBrightnessFromPointer(event);
            event.preventDefault();
        });

        slider.addEventListener("pointermove", function (event) {
            if (isDragging) {
                updateBrightnessFromPointer(event);
            }
        });

        function stopDragging(event) {
            isDragging = false;

            if (event && slider.hasPointerCapture &&
                slider.hasPointerCapture(event.pointerId)) {
                slider.releasePointerCapture(event.pointerId);
            }
        }

        slider.addEventListener("pointerup", stopDragging);
        slider.addEventListener("pointercancel", stopDragging);
    }
})();

function setThemeMode(mode) {
    if (mode !== "light" && mode !== "dark") {
        return;
    }

    document.body.classList.toggle("light-mode", mode === "light");

    try {
        localStorage.setItem("smartbite_theme", mode);
    } catch (e) {
        // Keep the selected theme for this page even if storage is blocked.
    }

    updateThemeButtonUI();
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

function updateBrightnessFromPointer(event) {
    const slider = document.getElementById("brightnessSlider");

    if (!slider) {
        return;
    }

    const rect = slider.getBoundingClientRect();

    if (rect.width <= 0) {
        return;
    }

    const position = Math.min(
        1,
        Math.max(0, (event.clientX - rect.left) / rect.width)
    );

    updateBrightnessSlider(0.5 + position, true);
}

function updateBrightnessSlider(value, savePreference) {
    const parsedValue = Number(value);

    if (!Number.isFinite(parsedValue)) {
        return;
    }

    const brightness = Math.min(1.5, Math.max(0.5, parsedValue));
    const slider = document.getElementById("brightnessSlider");
    const fill = document.getElementById("brightnessFill");
    const thumb = document.getElementById("brightnessThumb");

    const percentage = ((brightness - 0.5) / (1.5 - 0.5)) * 100;

    if (slider) {
        slider.setAttribute("aria-valuenow", brightness.toFixed(2));
        slider.setAttribute(
            "aria-valuetext",
            Math.round(brightness * 100) + " percent brightness"
        );
    }

    if (fill) {
        fill.style.width = percentage + "%";
    }

    if (thumb) {
        thumb.style.left = percentage + "%";
    }

    document.documentElement.style.filter = "brightness(" + brightness + ")";

    if (savePreference) {
        try {
            localStorage.setItem("smartbite_brightness", String(brightness));
        } catch (e) {
            // Brightness still works for the current page.
        }
    }
}

function handleBrightnessKeydown(event) {
    const slider = document.getElementById("brightnessSlider");

    if (!slider) {
        return;
    }

    let currentValue = parseFloat(slider.getAttribute("aria-valuenow"));

    if (!Number.isFinite(currentValue)) {
        currentValue = 1;
    }

    const step = event.shiftKey ? 0.10 : 0.05;
    let newValue = currentValue;

    switch (event.key) {
        case "ArrowLeft":
        case "ArrowDown":
            newValue = currentValue - step;
            break;

        case "ArrowRight":
        case "ArrowUp":
            newValue = currentValue + step;
            break;

        case "Home":
            newValue = 0.5;
            break;

        case "End":
            newValue = 1.5;
            break;

        default:
            return;
    }

    event.preventDefault();
    updateBrightnessSlider(newValue, true);
}

function showEditForm() {
    const form = document.getElementById("editForm");

    form.classList.add("visible");
    document.getElementById("profileDetails").style.display = "none";
    document.getElementById("editButton").style.display = "none";
    document.getElementById("name").focus();

    form.scrollIntoView({ behavior: "smooth", block: "center" });
}

function hideEditForm() {
    document.getElementById("editForm").classList.remove("visible");
    document.getElementById("profileDetails").style.display = "";
    document.getElementById("editButton").style.display = "";
}

const photoInput = document.getElementById("photoInput");
const photoImage = document.getElementById("profilePhoto");
const photoFallback = document.getElementById("avatarFallback");
const photoMessage = document.getElementById("photoMessage");
const photoActions = document.getElementById("photoActions");

let pendingPhotoData = null;
let previousPhotoData = null;

const photoStorageKey =
    "smartbite-profile-photo-<%= loggedInUser.getUserId() %>";

function displayPhoto(data) {
    if (data) {
        photoImage.src = data;
        photoImage.style.display = "block";
        photoFallback.style.display = "none";
    } else {
        photoImage.removeAttribute("src");
        photoImage.style.display = "none";
        photoFallback.style.display = "block";
    }
}

try {
    previousPhotoData = localStorage.getItem(photoStorageKey);
    displayPhoto(previousPhotoData);
} catch (e) {
    displayPhoto(null);
}

photoInput.addEventListener("change", function () {
    const file = photoInput.files && photoInput.files[0];

    if (!file) {
        return;
    }

    if (!file.type || !file.type.startsWith("image/")) {
        alert("Please choose an image file.");
        photoInput.value = "";
        return;
    }

    if (file.size > 8 * 1024 * 1024) {
        alert("Please choose an image smaller than 8 MB.");
        photoInput.value = "";
        return;
    }

    const reader = new FileReader();

    reader.onload = function (event) {
        const source = new Image();

        source.onload = function () {
            const canvas = document.createElement("canvas");
            const maxDimension = 400;

            const scale = Math.min(
                1,
                maxDimension / Math.max(source.width, source.height)
            );

            canvas.width = Math.max(1, Math.round(source.width * scale));
            canvas.height = Math.max(1, Math.round(source.height * scale));

            const context = canvas.getContext("2d");

            if (!context) {
                alert("Your browser could not process this image.");
                return;
            }

            context.drawImage(source, 0, 0, canvas.width, canvas.height);

            pendingPhotoData = canvas.toDataURL("image/jpeg", 0.82);
            displayPhoto(pendingPhotoData);

            photoMessage.textContent =
                "Preview ready. Select Save Photo to keep this picture in this browser.";

            photoMessage.classList.add("visible");
            photoActions.style.display = "flex";
        };

        source.onerror = function () {
            alert("This image could not be opened. Please choose another.");
        };

        source.src = event.target.result;
    };

    reader.onerror = function () {
        alert("The selected image could not be read.");
    };

    reader.readAsDataURL(file);
});

function savePhotoLocally() {
    if (!pendingPhotoData) {
        alert("Please choose a photo first.");
        return;
    }

    try {
        localStorage.setItem(photoStorageKey, pendingPhotoData);
        previousPhotoData = pendingPhotoData;
        pendingPhotoData = null;
        photoInput.value = "";
        photoActions.style.display = "none";

        photoMessage.textContent = "✓ Your photo is saved in this browser.";
        photoMessage.classList.add("visible");
    } catch (e) {
        alert("The photo could not be saved in this browser. Try a smaller image.");
    }
}

function cancelPhotoChange() {
    pendingPhotoData = null;
    photoInput.value = "";
    displayPhoto(previousPhotoData);
    photoActions.style.display = "none";
    photoMessage.classList.remove("visible");
}
</script>

</body>
</html>
