<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Object orderIdObj = session.getAttribute("lastOrderId");
    Object totalObj = session.getAttribute("lastOrderTotal");
    Object paymentObj = session.getAttribute("lastPaymentOption");
    Object statusObj = session.getAttribute("lastOrderStatus");

    String orderId = orderIdObj != null ? String.valueOf(orderIdObj) : "N/A";

    double totalAmount = 0.0;
    if (totalObj instanceof Number) {
        totalAmount = ((Number) totalObj).doubleValue();
    } else if (totalObj != null) {
        try {
            totalAmount = Double.parseDouble(String.valueOf(totalObj));
        } catch (Exception e) {
            totalAmount = 0.0;
        }
    }

    String paymentOption = paymentObj != null ? String.valueOf(paymentObj) : "N/A";
    String status = statusObj != null ? String.valueOf(statusObj) : "PLACED";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SmartBite | Order Confirmation</title>

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

html, body {
    margin: 0 !important;
    padding: 0 !important;
    min-height: 100vh;
    overflow-x: hidden;
    color: var(--text-main) !important;
    font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif !important;
    background: linear-gradient(rgba(13, 13, 15, 0.90), rgba(13, 13, 15, 0.95)), url('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1600&q=80') center / cover fixed !important;
    transition: background-color 0.3s ease, color 0.3s ease;
}

body.light-mode {
    background: linear-gradient(rgba(241, 243, 245, 0.92), rgba(241, 243, 245, 0.96)), url('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1600&q=80') center / cover fixed !important;
}

* {
    box-sizing: border-box;
}

/* NAVBAR */
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
    gap: 16px;
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
    gap: 18px;
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
    white-space: nowrap;
}

.nav-links > a:hover,
.nav-links > a.active {
    color: var(--accent);
}

/* SMALL PROFILE ICON */
.profile-avatar {
    width: 30px;
    height: 30px;
    flex: 0 0 30px;
    border-radius: 50%;
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    color: var(--text-main);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    text-decoration: none;
    transition: transform 0.2s ease, border-color 0.2s ease;
}

.profile-avatar:hover {
    transform: scale(1.06);
    border-color: var(--accent);
}

/* SAME MINIMAL THEME AND BRIGHTNESS CONTROL AS HOME PAGE */
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
    transition: color .18s ease;
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
    opacity: .7;
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

/* ORDER CONFIRMATION PAGE */
.page-container {
    max-width: 850px;
    margin: 50px auto 80px;
    padding: 0 24px;
    position: relative;
    z-index: 2;
}

.success-card {
    background: var(--bg-card-dark);
    border: 1px solid var(--panel-border);
    border-radius: 12px;
    padding: 40px;
    text-align: center;
    box-shadow: var(--shadow);
    position: relative;
    z-index: 3;
}

.success-icon {
    width: 70px;
    height: 70px;
    margin: 0 auto 20px;
    border-radius: 50%;
    background: #24963f;
    color: #ffffff;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 34px;
    font-weight: 800;
}

h1 {
    color: var(--text-main);
    font-size: 28px;
    font-weight: 800;
    letter-spacing: -0.5px;
    margin-bottom: 8px;
}

.message {
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 30px;
}

.order-details {
    background: var(--metric-bg);
    border: 1px solid var(--panel-border);
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 24px;
    text-align: left;
}

.detail-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid var(--panel-border);
}

.detail-row:last-child {
    border-bottom: none;
}

.detail-label {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 700;
}

.detail-value {
    color: var(--text-main);
    font-size: 14px;
    font-weight: 800;
    text-align: right;
    overflow-wrap: anywhere;
}

.status {
    color: #24963f;
}

.cancel-zone {
    margin: 24px 0;
    padding: 18px;
    background: rgba(226, 55, 68, 0.08);
    border: 1px solid rgba(226, 55, 68, 0.25);
    border-radius: 8px;
}

.cancel-zone p {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 12px;
}

.cancel-btn {
    display: inline-block;
    padding: 10px 20px;
    background: var(--accent);
    color: #ffffff;
    text-decoration: none;
    border-radius: 6px;
    font-weight: 800;
    font-size: 13px;
    transition: background 0.2s;
}

.cancel-btn:hover {
    background: #d12e3b;
}

.quote {
    margin: 24px 0 28px;
    padding: 18px;
    background: var(--metric-bg);
    border-left: 4px solid var(--accent);
    border-radius: 6px;
    color: var(--text-muted);
    font-size: 14px;
    font-weight: 600;
    font-style: italic;
}

.buttons {
    display: flex;
    justify-content: center;
    gap: 12px;
    flex-wrap: wrap;
}

.btn {
    display: inline-block;
    min-width: 160px;
    padding: 12px 20px;
    border-radius: 6px;
    text-decoration: none;
    font-size: 13px;
    font-weight: 800;
    transition: background 0.2s;
}

.track-btn {
    background: #24963f;
    color: #ffffff;
}

.track-btn:hover {
    background: #1e7e34;
}

.secondary {
    background: var(--metric-bg);
    color: var(--text-main);
    border: 1px solid var(--panel-border);
}

.secondary:hover {
    border-color: var(--accent);
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
    position: relative;
    z-index: 2;
}

/* CELEBRATION BLAST */
.celebration-layer {
    position: fixed;
    inset: 0;
    z-index: 2000;
    pointer-events: none;
    overflow: hidden;
    perspective: 700px;
}

.celebration-layer.is-hidden,
.delivery-rider-layer.is-hidden {
    display: none;
}

.blast-flash {
    position: absolute;
    left: 50%;
    top: 44%;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    opacity: 0;
    transform: translate(-50%, -50%) scale(0);
    background: radial-gradient(circle, #ffffff 0%, #fff6a8 15%, #ffb52e 35%, rgba(255, 72, 105, 0.55) 58%, transparent 72%);
    filter: blur(1px);
}

.celebration-layer.play .blast-flash {
    animation: blastFlash 850ms ease-out both;
}

.blast-ring {
    position: absolute;
    left: 50%;
    top: 44%;
    width: 24px;
    height: 24px;
    border: 4px solid #ffce4a;
    border-radius: 50%;
    opacity: 0;
    transform: translate(-50%, -50%) scale(0.1);
    box-shadow: 0 0 18px rgba(255, 206, 74, 0.75), inset 0 0 10px rgba(255, 255, 255, 0.5);
}

.celebration-layer.play .blast-ring {
    animation: blastRing 1.2s cubic-bezier(.12,.65,.2,1) both;
}

.blast-ring.ring-two {
    border-color: #ff5d83;
    animation-delay: 120ms;
}

.blast-ring.ring-three {
    border-color: #5de6ff;
    animation-delay: 230ms;
}

.blast-ray {
    position: absolute;
    left: 50%;
    top: 44%;
    width: 5px;
    height: clamp(55px, 10vw, 135px);
    border-radius: 10px;
    opacity: 0;
    transform-origin: 50% 0%;
    transform: rotate(var(--angle)) translateY(-10px) scaleY(0);
    background: linear-gradient(to bottom, #fff8cc, var(--ray-color), transparent);
    filter: drop-shadow(0 0 7px var(--ray-color));
}

.celebration-layer.play .blast-ray {
    animation: rayBurst 950ms cubic-bezier(.1,.75,.2,1) both;
    animation-delay: var(--delay, 0ms);
}

.confetti-piece {
    position: absolute;
    top: 43%;
    left: 50%;
    width: var(--piece-width, 9px);
    height: var(--piece-height, 16px);
    background: var(--piece-color);
    opacity: 0;
    border-radius: var(--piece-radius, 2px);
    transform: translate(-50%, -50%) rotate(0deg);
    box-shadow: 0 0 5px rgba(255,255,255,0.12);
}

.confetti-piece.is-circle {
    border-radius: 50%;
}

.confetti-piece.is-ribbon {
    width: 5px;
    height: 35px;
    border-radius: 5px;
}

.celebration-layer.play .confetti-piece {
    animation: confettiBlast var(--duration, 2.8s) cubic-bezier(.12,.62,.2,1) var(--delay, 0ms) both;
}

.celebration-layer.play .confetti-piece.rain {
    animation-name: confettiRain;
    animation-timing-function: cubic-bezier(.18,.55,.25,1);
}

.party-popper {
    position: absolute;
    top: 45%;
    font-size: clamp(38px, 5vw, 66px);
    line-height: 1;
    opacity: 0;
    filter: drop-shadow(0 5px 12px rgba(0,0,0,.3));
}

.party-popper.left {
    left: 4%;
    transform: rotate(-35deg) scale(.3);
}

.party-popper.right {
    right: 4%;
    transform: rotate(35deg) scale(.3) scaleX(-1);
}

.celebration-layer.play .party-popper.left {
    animation: popperLeft 1.3s ease-out both;
}

.celebration-layer.play .party-popper.right {
    animation: popperRight 1.3s ease-out 100ms both;
}

/* ORDER SUCCESS MESSAGE */
.celebration-caption {
    position: absolute;
    top: 19%;
    left: 50%;
    transform: translate(-50%, 15px) scale(.75);
    max-width: calc(100% - 32px);
    padding: 12px 22px;
    border-radius: 999px;
    color: #ffffff;
    background: linear-gradient(110deg, #e23744, #a855f7, #f59e0b);
    font-size: clamp(13px, 2vw, 18px);
    font-weight: 800;
    letter-spacing: .4px;
    text-align: center;
    white-space: nowrap;
    opacity: 0;
    box-shadow: 0 10px 35px rgba(226,55,68,.35);
}

.celebration-layer.play .celebration-caption {
    animation: captionPop 7s ease both;
}

@keyframes blastFlash {
    0% { opacity: 0; transform: translate(-50%,-50%) scale(0); }
    18% { opacity: .95; transform: translate(-50%,-50%) scale(9); }
    100% { opacity: 0; transform: translate(-50%,-50%) scale(25); }
}

@keyframes blastRing {
    0% { opacity: .95; transform: translate(-50%,-50%) scale(.1); }
    80% { opacity: .75; }
    100% { opacity: 0; transform: translate(-50%,-50%) scale(25); }
}

@keyframes rayBurst {
    0% { opacity: 0; transform: rotate(var(--angle)) translateY(-8px) scaleY(0); }
    15% { opacity: 1; }
    100% { opacity: 0; transform: rotate(var(--angle)) translateY(-45px) scaleY(1); }
}

@keyframes confettiBlast {
    0% {
        opacity: 0;
        transform: translate(-50%,-50%) rotate(0deg) scale(.2);
    }
    10% { opacity: 1; }
    65% { opacity: 1; }
    100% {
        opacity: 0;
        transform: translate(calc(-50% + var(--travel-x)), calc(-50% + var(--travel-y))) rotate(var(--spin)) scale(.9);
    }
}

@keyframes confettiRain {
    0% {
        opacity: 0;
        transform: translate(-50%,-50%) rotate(0deg);
    }
    12% { opacity: 1; }
    75% { opacity: 1; }
    100% {
        opacity: 0;
        transform: translate(calc(-50% + var(--travel-x)), calc(-50% + var(--travel-y))) rotate(var(--spin));
    }
}

@keyframes popperLeft {
    0% { opacity: 0; transform: rotate(-35deg) scale(.3); }
    20% { opacity: 1; transform: rotate(-18deg) scale(1.15); }
    55% { opacity: 1; transform: rotate(-28deg) scale(1); }
    100% { opacity: 0; transform: rotate(-45deg) scale(.75); }
}

@keyframes popperRight {
    0% { opacity: 0; transform: rotate(35deg) scale(.3) scaleX(-1); }
    20% { opacity: 1; transform: rotate(18deg) scale(1.15) scaleX(-1); }
    55% { opacity: 1; transform: rotate(28deg) scale(1) scaleX(-1); }
    100% { opacity: 0; transform: rotate(45deg) scale(.75) scaleX(-1); }
}

@keyframes captionPop {
    0% {
        opacity: 0;
        transform: translate(-50%, 15px) scale(.75);
    }
    8% {
        opacity: 1;
        transform: translate(-50%, 0) scale(1);
    }
    14% {
        opacity: 1;
        transform: translate(-50%, 0) scale(1.04);
    }
    88% {
        opacity: 1;
        transform: translate(-50%, 0) scale(1);
    }
    100% {
        opacity: 0;
        transform: translate(-50%, 15px) scale(.75);
    }
}

/* =========================================================
   SMARTBITE SCOOTER DELIVERY RIDER
   Clearly visible rider, scooter wheels, handlebar and food bag.
   The scooter is not a car-shaped body.
   ========================================================= */

.delivery-rider-layer {
    position: fixed;
    inset: 0;
    z-index: 1500;
    pointer-events: none;
    overflow: hidden;
}

.rider-road-glow {
    position: absolute;
    left: -10%;
    bottom: 4%;
    width: 120%;
    height: 3px;
    opacity: 0;
    background: linear-gradient(90deg, transparent, rgba(226,55,68,.65), rgba(255,195,76,.6), transparent);
    filter: blur(2px);
}

.delivery-rider-layer.play .rider-road-glow {
    animation: roadGlow 5.2s ease-in-out both;
}

.scooty-rider {
    position: absolute;
    left: -230px;
    top: -180px;
    width: clamp(175px, 22vw, 250px);
    height: clamp(155px, 19vw, 215px);
    opacity: 0;
    transform-origin: center;
    filter: drop-shadow(0 10px 10px rgba(0,0,0,.32));
}

.delivery-rider-layer.play .scooty-rider {
    animation: riderDiagonal 5.2s cubic-bezier(.25,.65,.35,1) 250ms both;
}

.rider-illustration {
    position: relative;
    width: 100%;
    height: 100%;
}

/* Speed streaks behind the scooter */
.rider-speed {
    position: absolute;
    height: 3px;
    border-radius: 5px;
    background: linear-gradient(90deg, transparent, #ff6675);
    opacity: .9;
    z-index: 1;
}

.speed-one {
    left: 0;
    bottom: 24%;
    width: 22%;
}

.speed-two {
    left: 5%;
    bottom: 17%;
    width: 15%;
}

.speed-three {
    left: 1%;
    bottom: 32%;
    width: 11%;
    height: 2px;
}

/* Wheels are two separate, round scooter wheels */
.scooter-wheel {
    position: absolute;
    bottom: 8%;
    width: 25%;
    aspect-ratio: 1;
    border-radius: 50%;
    background: radial-gradient(circle,
        #d7dee8 0 9%,
        #596474 10% 16%,
        #1c222d 17% 26%,
        #07090d 27% 70%,
        #3b4452 71% 80%,
        #090b10 81% 100%);
    border: 3px solid #080a0e;
    box-shadow: inset 0 0 0 2px #333b47, 0 4px 6px rgba(0,0,0,.35);
    z-index: 3;
}

.scooter-wheel::before {
    content: "";
    position: absolute;
    inset: 25%;
    border: 2px solid #8d98a8;
    border-radius: 50%;
}

.scooter-wheel::after {
    content: "";
    position: absolute;
    left: 42%;
    top: 42%;
    width: 16%;
    height: 16%;
    border-radius: 50%;
    background: #e9edf3;
}

.scooter-wheel.rear-wheel {
    left: 12%;
}

.scooter-wheel.front-wheel {
    right: 8%;
}

.delivery-rider-layer.play .scooter-wheel {
    animation: wheelSpin .55s linear infinite;
}

/* Slim scooter floorboard, not a large enclosed vehicle body */
.scooter-frame {
    position: absolute;
    left: 27%;
    bottom: 22%;
    width: 43%;
    height: 7%;
    border-radius: 6px;
    background: linear-gradient(180deg, #555e6b, #252b36 55%, #0e1118);
    border: 2px solid #171b23;
    transform: rotate(-1deg);
    z-index: 4;
}

.scooter-frame::after {
    content: "";
    position: absolute;
    left: 12%;
    right: 12%;
    top: 2px;
    height: 2px;
    background: rgba(255,255,255,.22);
    border-radius: 2px;
}

/* Red scooter footwell/body panel */
.scooter-body {
    position: absolute;
    left: 23%;
    bottom: 24%;
    width: 48%;
    height: 22%;
    background: linear-gradient(145deg, #ff7580 0%, #ed3345 45%, #a91529 100%);
    clip-path: polygon(5% 12%, 46% 0%, 77% 12%, 100% 63%, 80% 93%, 18% 100%, 0 65%);
    border-radius: 8px;
    z-index: 5;
}

.scooter-body::after {
    content: "";
    position: absolute;
    left: 12%;
    right: 21%;
    top: 25%;
    height: 5px;
    background: linear-gradient(90deg, rgba(255,255,255,.6), rgba(255,255,255,0));
    transform: rotate(-7deg);
    border-radius: 5px;
}

/* Front leg shield — upright and narrow like a scooty */
.scooter-front-panel {
    position: absolute;
    right: 12%;
    bottom: 25%;
    width: 20%;
    height: 43%;
    background: linear-gradient(130deg, #ff8690, #ec3043 48%, #b5192f);
    clip-path: polygon(20% 0, 90% 7%, 100% 66%, 69% 100%, 0 83%, 7% 26%);
    z-index: 6;
}

.scooter-front-panel::after {
    content: "";
    position: absolute;
    left: 27%;
    top: 26%;
    width: 53%;
    height: 8%;
    background: rgba(255,255,255,.5);
    border-radius: 5px;
    transform: rotate(9deg);
}

/* Front mudguard follows the front wheel */
.scooter-front-fender {
    position: absolute;
    right: 3%;
    bottom: 7%;
    width: 29%;
    height: 17%;
    border-top: 6px solid #e23744;
    border-radius: 60% 60% 0 0;
    transform: rotate(-7deg);
    z-index: 7;
}

/* Rear wheel fender */
.scooter-rear-fender {
    position: absolute;
    left: 6%;
    bottom: 7%;
    width: 34%;
    height: 18%;
    border-top: 6px solid #e23744;
    border-radius: 60% 60% 0 0;
    transform: rotate(2deg);
    z-index: 7;
}

/* Scooter headlight */
.scooter-headlight {
    position: absolute;
    right: 10%;
    bottom: 50%;
    width: 10%;
    height: 7%;
    background: #fff7cd;
    border: 2px solid #ffffff;
    border-radius: 4px 8px 8px 4px;
    box-shadow: 0 0 12px rgba(255,244,194,.85);
    transform: rotate(8deg);
    z-index: 8;
}

/* Front steering column and handlebar */
.scooter-steering {
    position: absolute;
    right: 17%;
    top: 29%;
    width: 5%;
    height: 37%;
    border-radius: 5px;
    background: linear-gradient(90deg, #202632, #8992a0, #262d38);
    transform: rotate(-9deg);
    transform-origin: bottom center;
    z-index: 8;
}

.scooter-handlebar {
    position: absolute;
    right: 8%;
    top: 26%;
    width: 25%;
    height: 4%;
    border-radius: 5px;
    background: linear-gradient(180deg, #9ca6b4, #29313d);
    transform: rotate(-5deg);
    z-index: 12;
}

.scooter-handlebar::before,
.scooter-handlebar::after {
    content: "";
    position: absolute;
    top: -25%;
    width: 22%;
    height: 150%;
    border-radius: 4px;
    background: #141922;
}

.scooter-handlebar::before {
    left: -5%;
}

.scooter-handlebar::after {
    right: -5%;
}

.scooter-mirror-stem {
    position: absolute;
    right: 23%;
    top: 14%;
    width: 2px;
    height: 14%;
    background: #aeb7c4;
    transform: rotate(10deg);
    z-index: 8;
}

.scooter-mirror {
    position: absolute;
    right: 18%;
    top: 10%;
    width: 10%;
    height: 8%;
    background: linear-gradient(135deg, #ffffff, #b4bfcd);
    border: 2px solid #434c59;
    border-radius: 60% 45% 50% 45%;
    transform: rotate(9deg);
    z-index: 9;
}

/* Scooter seat with a visible front/back silhouette */
.scooter-seat {
    position: absolute;
    left: 31%;
    bottom: 47%;
    width: 29%;
    height: 7%;
    border-radius: 12px 12px 5px 5px;
    background: linear-gradient(180deg, #414754, #11151e);
    border: 2px solid #78818e;
    transform: rotate(-5deg);
    z-index: 9;
}

.scooter-seat::after {
    content: "";
    position: absolute;
    right: -14%;
    top: 40%;
    width: 20%;
    height: 70%;
    background: #252b36;
    border-radius: 4px;
}

/* DELIVERY PERSON */
.rider-person {
    position: absolute;
    left: 36%;
    top: 5%;
    width: 39%;
    height: 66%;
    z-index: 10;
}

/* Rider jacket/torso, leaning forward while riding */
.rider-torso {
    position: absolute;
    left: 20%;
    top: 24%;
    width: 38%;
    height: 40%;
    background: linear-gradient(120deg, #ff7b85 0%, #e23744 52%, #99162a 100%);
    border: 2px solid #a81e30;
    border-radius: 42% 35% 25% 28%;
    transform: rotate(-24deg);
    box-shadow: inset 3px 2px 2px rgba(255,255,255,.2);
    z-index: 3;
}

.rider-torso::after {
    content: "";
    position: absolute;
    left: 38%;
    top: 12%;
    width: 3px;
    height: 72%;
    background: rgba(255,255,255,.35);
    transform: rotate(-1deg);
    border-radius: 3px;
}

/* Neck */
.rider-neck {
    position: absolute;
    left: 51%;
    top: 22%;
    width: 12%;
    height: 16%;
    background: #c98968;
    border-radius: 5px;
    transform: rotate(-15deg);
    z-index: 4;
}

/* Face is visible below the helmet */
.rider-face {
    position: absolute;
    left: 43%;
    top: 4%;
    width: 29%;
    height: 23%;
    border-radius: 48% 48% 44% 44%;
    background: linear-gradient(135deg, #f2c09c, #c98968);
    border: 2px solid #a96c4c;
    transform: rotate(-12deg);
    z-index: 5;
}

/* Small face details point toward the direction of travel */
.rider-face::after {
    content: "";
    position: absolute;
    right: 7%;
    top: 47%;
    width: 22%;
    height: 9%;
    background: #302a2a;
    border-radius: 4px;
}

/* White helmet */
.rider-helmet {
    position: absolute;
    left: 38%;
    top: 0;
    width: 39%;
    height: 21%;
    border-radius: 65% 60% 26% 28%;
    background: linear-gradient(140deg, #ffffff 0%, #edf1f6 52%, #a7b2c2 100%);
    border: 2px solid #657181;
    transform: rotate(-12deg);
    box-shadow: inset 0 3px 2px rgba(255,255,255,.95), 0 2px 5px rgba(0,0,0,.2);
    z-index: 6;
}

.rider-helmet::before {
    content: "";
    position: absolute;
    right: -12%;
    bottom: 7%;
    width: 60%;
    height: 15%;
    background: #26303d;
    border-radius: 0 6px 6px 0;
}

.rider-helmet::after {
    content: "";
    position: absolute;
    left: 18%;
    top: 10%;
    width: 42%;
    height: 3px;
    background: #c3cbd5;
    border-radius: 4px;
}

/* Rider's upper arm reaches toward the handlebar */
.rider-arm-front {
    position: absolute;
    left: 47%;
    top: 34%;
    width: 37%;
    height: 9%;
    border-radius: 10px;
    background: linear-gradient(180deg, #ff6877, #cf273b);
    border: 2px solid #a91f32;
    transform: rotate(-7deg);
    transform-origin: left center;
    z-index: 7;
}

.rider-forearm {
    position: absolute;
    left: 72%;
    top: 26%;
    width: 25%;
    height: 7%;
    border-radius: 8px;
    background: #dca17f;
    border: 1px solid #a66b4b;
    transform: rotate(13deg);
    transform-origin: left center;
    z-index: 11;
}

.rider-glove {
    position: absolute;
    right: -2%;
    top: 24%;
    width: 13%;
    height: 9%;
    border-radius: 5px;
    background: #202630;
    border: 1px solid #586170;
    z-index: 13;
}

/* Rider's bent legs show a seated riding position */
.rider-thigh {
    position: absolute;
    left: 29%;
    top: 57%;
    width: 37%;
    height: 13%;
    border-radius: 10px;
    background: linear-gradient(180deg, #485161, #202633);
    border: 1px solid #171b25;
    transform: rotate(13deg);
    z-index: 4;
}

.rider-shin {
    position: absolute;
    left: 55%;
    top: 60%;
    width: 12%;
    height: 23%;
    border-radius: 7px;
    background: linear-gradient(90deg, #313947, #151922);
    transform: rotate(-13deg);
    transform-origin: top center;
    z-index: 4;
}

.rider-boot {
    position: absolute;
    left: 49%;
    top: 78%;
    width: 23%;
    height: 9%;
    border-radius: 4px 10px 5px 5px;
    background: linear-gradient(180deg, #353d49, #10141b);
    border: 1px solid #080a0d;
    transform: rotate(-2deg);
    z-index: 9;
}

/* Food delivery backpack, clearly separate from scooter */
.delivery-bag {
    position: absolute;
    left: 20%;
    top: 25%;
    width: 25%;
    height: 31%;
    border-radius: 8px 8px 6px 6px;
    background: linear-gradient(135deg, #ff596b 0%, #e23744 56%, #a8172c 100%);
    border: 2px solid #ff9ba4;
    box-shadow: inset 3px 2px 4px rgba(255,255,255,.25), 0 5px 10px rgba(0,0,0,.3);
    transform: rotate(-10deg);
    z-index: 8;
}

.delivery-bag::before {
    content: "";
    position: absolute;
    left: 20%;
    top: -13%;
    width: 58%;
    height: 15%;
    border: 3px solid #343b47;
    border-bottom: 0;
    border-radius: 8px 8px 0 0;
}

.delivery-bag::after {
    content: "";
    position: absolute;
    top: 17%;
    left: 0;
    width: 100%;
    height: 2px;
    background: rgba(255,255,255,.35);
}

.delivery-bag-label {
    position: absolute;
    inset: 28% 0 auto;
    color: #ffffff;
    font-size: clamp(7px, .9vw, 10px);
    font-weight: 800;
    letter-spacing: -.4px;
    line-height: 1.05;
    text-align: center;
    text-shadow: 0 1px 2px rgba(0,0,0,.25);
}

/* Scooter motion from off-screen top-left to bottom-right */
@keyframes riderDiagonal {
    0% {
        left: -230px;
        top: -180px;
        opacity: 0;
        transform: rotate(-8deg) scale(.62);
    }
    8% {
        opacity: 1;
    }
    24% {
        left: 14%;
        top: 12%;
        transform: rotate(-4deg) scale(.78);
    }
    48% {
        left: 37%;
        top: 34%;
        transform: rotate(-1deg) scale(.92);
    }
    70% {
        left: 60%;
        top: 56%;
        transform: rotate(2deg) scale(1);
    }
    88% {
        left: 81%;
        top: 76%;
        opacity: 1;
        transform: rotate(5deg) scale(1.04);
    }
    100% {
        left: calc(100% + 35px);
        top: calc(100% + 25px);
        opacity: 0;
        transform: rotate(7deg) scale(1.06);
    }
}

@keyframes wheelSpin {
    to {
        transform: rotate(360deg);
    }
}

@keyframes roadGlow {
    0%, 100% {
        opacity: 0;
    }
    20%, 75% {
        opacity: .8;
    }
}

@media (max-width: 900px) {
    .scooty-rider {
        width: clamp(150px, 26vw, 205px);
        height: clamp(140px, 23vw, 185px);
    }

    @keyframes riderDiagonal {
        0% { left: -190px; top: -145px; opacity: 0; transform: rotate(-8deg) scale(.6); }
        8% { opacity: 1; }
        24% { left: 10%; top: 12%; transform: rotate(-4deg) scale(.72); }
        48% { left: 32%; top: 34%; transform: rotate(-1deg) scale(.86); }
        70% { left: 55%; top: 57%; transform: rotate(2deg) scale(.95); }
        88% { left: 77%; top: 76%; opacity: 1; transform: rotate(5deg) scale(1); }
        100% { left: calc(100% + 25px); top: calc(100% + 20px); opacity: 0; transform: rotate(7deg) scale(1.03); }
    }
}

@media (max-width: 600px) {
    .nav-container {
        gap: 10px;
        flex-wrap: wrap;
        justify-content: center;
        padding: 12px 14px;
    }

    .logo {
        font-size: 24px;
    }

    .nav-links {
        gap: 10px;
        flex-wrap: wrap;
        justify-content: center;
    }

    .nav-links > a:not(.profile-avatar) {
        font-size: 12px;
    }

    .profile-avatar {
        width: 28px;
        height: 28px;
        flex-basis: 28px;
        font-size: 13px;
    }

    .controls-box {
        gap: 6px;
        padding: 0;
    }

    .brightness-slider {
        flex-basis: 46px;
        width: 46px;
    }

    .page-container {
        margin-top: 25px;
        padding: 0 15px;
    }

    .success-card {
        padding: 24px 16px;
    }

    h1 {
        font-size: 24px;
    }

    .buttons {
        flex-direction: column;
    }

    .btn {
        width: 100%;
    }

    .celebration-caption {
        top: 13%;
        white-space: normal;
        width: max-content;
        max-width: calc(100% - 30px);
    }

    .party-popper {
        top: 40%;
        font-size: 40px;
    }

    .party-popper.left {
        left: 1%;
    }

    .party-popper.right {
        right: 1%;
    }
}

@media (prefers-reduced-motion: reduce) {
    .celebration-layer.play *,
    .delivery-rider-layer.play * {
        animation-duration: 1ms !important;
        animation-iteration-count: 1 !important;
    }
}
</style>
</head>

<body>

<!-- COLORFUL CELEBRATION OVERLAY -->
<div class="celebration-layer is-hidden" id="celebrationLayer" aria-hidden="true">
    <div class="blast-flash"></div>
    <div class="blast-ring"></div>
    <div class="blast-ring ring-two"></div>
    <div class="blast-ring ring-three"></div>
    <div class="party-popper left">🎉</div>
    <div class="party-popper right">🎊</div>
    <div class="celebration-caption">🎉 ORDER PLACED SUCCESSFULLY! 🎉</div>
    <div id="blastRays"></div>
    <div id="confettiContainer"></div>
</div>

<!-- SMARTBITE DELIVERY RIDER ON A SCOOTER -->
<div class="delivery-rider-layer is-hidden" id="deliveryRiderLayer" aria-hidden="true">
    <div class="rider-road-glow"></div>

    <div class="scooty-rider">
        <div class="rider-illustration">

            <span class="rider-speed speed-one"></span>
            <span class="rider-speed speed-two"></span>
            <span class="rider-speed speed-three"></span>

            <!-- Delivery backpack -->
            <div class="delivery-bag">
                <span class="delivery-bag-label">Smart<br>Bite</span>
            </div>

            <!-- Seated delivery rider -->
            <div class="rider-person">
                <span class="rider-thigh"></span>
                <span class="rider-shin"></span>
                <span class="rider-boot"></span>

                <span class="rider-torso"></span>
                <span class="rider-neck"></span>
                <span class="rider-face"></span>
                <span class="rider-helmet"></span>

                <span class="rider-arm-front"></span>
                <span class="rider-forearm"></span>
                <span class="rider-glove"></span>
            </div>

            <!-- Two separate scooter wheels -->
            <span class="scooter-wheel rear-wheel"></span>
            <span class="scooter-wheel front-wheel"></span>

            <span class="scooter-rear-fender"></span>
            <span class="scooter-front-fender"></span>

            <!-- Slim scooter body and step-through floorboard -->
            <span class="scooter-frame"></span>
            <span class="scooter-body"></span>
            <span class="scooter-front-panel"></span>
            <span class="scooter-headlight"></span>

            <!-- Visible handlebar and mirror -->
            <span class="scooter-steering"></span>
            <span class="scooter-handlebar"></span>
            <span class="scooter-mirror-stem"></span>
            <span class="scooter-mirror"></span>
            <span class="scooter-seat"></span>
        </div>
    </div>
</div>

<header class="navbar">
    <div class="nav-container">
        <a href="home.jsp" class="logo">Smart<span>Bite</span></a>

        <nav class="nav-links" aria-label="Main navigation">
            <a href="home.jsp">Home</a>
            <a href="restaurants">Restaurants</a>
            <a href="orders.jsp" title="Orders">Orders</a>
            <a href="cart.jsp" title="Cart">🛒 Cart</a>

            <a href="profile.jsp" class="profile-avatar" title="Profile" aria-label="Profile">👤</a>

            <div class="controls-box" aria-label="Theme and brightness controls">
                <button type="button" class="theme-mode-btn" id="lightModeBtn"
                        onclick="setThemeMode('light')" title="Light Mode"
                        aria-label="Switch to Light Mode" aria-pressed="false">☀</button>

                <div class="brightness-slider" id="brightnessSlider"
                     role="slider" tabindex="0" aria-label="Adjust screen brightness"
                     aria-valuemin="0.5" aria-valuemax="1.5" aria-valuenow="1"
                     title="Drag to adjust brightness"
                     onkeydown="handleBrightnessKeydown(event)">
                    <span class="brightness-track" aria-hidden="true"></span>
                    <span class="brightness-fill" id="brightnessFill" aria-hidden="true"></span>
                    <span class="brightness-thumb" id="brightnessThumb" aria-hidden="true"></span>
                </div>

                <button type="button" class="theme-mode-btn" id="darkModeBtn"
                        onclick="setThemeMode('dark')" title="Dark Mode"
                        aria-label="Switch to Dark Mode" aria-pressed="true">☾</button>
            </div>
        </nav>
    </div>
</header>

<div class="page-container">
    <div class="success-card" id="successCard">
        <div class="success-icon">✓</div>

        <h1>Order Confirmation</h1>
        <p class="message">Thank you for ordering with SmartBite. Your order has been placed successfully!</p>

        <div class="order-details">
            <div class="detail-row">
                <span class="detail-label">Order ID</span>
                <span class="detail-value">#<%= orderId %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Total Amount</span>
                <span class="detail-value">&#8377;<%= String.format("%.2f", totalAmount) %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Payment</span>
                <span class="detail-value"><%= paymentOption %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Status</span>
                <span class="detail-value status"><%= status %></span>
            </div>
        </div>

        <div class="cancel-zone">
            <p>Need to cancel your order?</p>
            <a href="<%= request.getContextPath() %>/cancel-order?orderId=<%= orderId %>" class="cancel-btn">
                Cancel This Order
            </a>
        </div>

        <div class="quote">
            “Good food makes every moment better — enjoy your meal!”
        </div>

        <div class="buttons">
            <a href="<%= request.getContextPath() %>/track-order?orderId=<%= orderId %>" class="btn track-btn">
                Track Order
            </a>

            <a href="<%= request.getContextPath() %>/orders" class="btn secondary">
                Order History
            </a>

            <a href="<%= request.getContextPath() %>/restaurants" class="btn secondary">
                Continue Shopping
            </a>
        </div>
    </div>
</div>

<script>
/* RESTORE AND SAVE THE SAME THEME AND BRIGHTNESS SETTINGS AS HOME PAGE */

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

/* ULTRA-SLIM LINE BRIGHTNESS CONTROL */

let brightnessDragActive = false;

function updateBrightnessSlider(value) {
    const numericValue = parseFloat(value);
    const brightness = Math.min(1.5, Math.max(0.5,
        Number.isFinite(numericValue) ? numericValue : 1));

    const percentage = ((brightness - 0.5) / 1.0) * 100;
    const slider = document.getElementById("brightnessSlider");
    const fill = document.getElementById("brightnessFill");
    const thumb = document.getElementById("brightnessThumb");

    if (fill) {
        fill.style.width = percentage + "%";
    }

    if (thumb) {
        thumb.style.left = percentage + "%";
    }

    if (slider) {
        slider.setAttribute("aria-valuenow", brightness.toFixed(2));
    }
}

function adjustBrightness(value) {
    const brightness = parseFloat(value);

    if (Number.isNaN(brightness) || brightness < 0.5 || brightness > 1.5) {
        return;
    }

    document.documentElement.style.filter = "brightness(" + brightness + ")";
    updateBrightnessSlider(brightness);

    try {
        localStorage.setItem("smartbite_brightness", String(brightness));
    } catch (e) {
        console.log("Unable to save brightness preference.");
    }
}

(function attachBrightnessPointerEvents() {
    const slider = document.getElementById("brightnessSlider");
    if (!slider) return;

    slider.addEventListener("pointerdown", startBrightnessDrag);
    slider.addEventListener("pointermove", moveBrightnessDrag);
    slider.addEventListener("pointerup", stopBrightnessDrag);
    slider.addEventListener("pointercancel", stopBrightnessDrag);
    slider.addEventListener("lostpointercapture", stopBrightnessDrag);
})();

function startBrightnessDrag(event) {
    if (event.button !== undefined && event.button !== 0) return;

    brightnessDragActive = true;

    if (event.currentTarget &&
        event.currentTarget.setPointerCapture &&
        event.pointerId !== undefined) {
        try {
            event.currentTarget.setPointerCapture(event.pointerId);
        } catch (e) {
            // Pointer capture may not be available in every browser.
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

function updateBrightnessFromPointer(event) {
    const slider = document.getElementById("brightnessSlider");
    if (!slider) return;

    const rect = slider.getBoundingClientRect();
    if (!rect.width) return;

    const percentage = Math.min(1, Math.max(0,
        (event.clientX - rect.left) / rect.width));

    const brightness = 0.5 + percentage;
    adjustBrightness(brightness);
}

function handleBrightnessKeydown(event) {
    const slider = document.getElementById("brightnessSlider");
    if (!slider) return;

    const current = parseFloat(slider.getAttribute("aria-valuenow")) || 1;
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
    adjustBrightness(Math.min(1.5, Math.max(0.5,
        Math.round(next * 100) / 100)));
}

/* RESTORE SAVED DISPLAY SETTINGS */
(function restoreThemeAndBrightness() {
    try {
        const savedTheme = localStorage.getItem("smartbite_theme");
        const savedBrightness = localStorage.getItem("smartbite_brightness");

        document.body.classList.toggle("light-mode", savedTheme === "light");

        if (savedBrightness !== null) {
            const brightness = parseFloat(savedBrightness);

            if (!Number.isNaN(brightness) &&
                brightness >= 0.5 && brightness <= 1.5) {
                adjustBrightness(brightness);
            } else {
                updateBrightnessSlider(1);
            }
        } else {
            updateBrightnessSlider(1);
        }
    } catch (e) {
        updateBrightnessSlider(1);
        console.log("Unable to restore saved display settings.");
    }

    updateThemeButtonUI();
})();

/* CLEAR SMARTBITE CART COUNT AFTER ORDER CONFIRMATION */
localStorage.setItem("smartbite_cart_count", "0");

const cartBadge = document.getElementById("fta-cart-badge");
if (cartBadge) {
    cartBadge.textContent = "0";
}

/* COLORFUL CELEBRATION AND DIAGONAL RIDER */
(function () {
    const celebrationLayer = document.getElementById("celebrationLayer");
    const confettiContainer = document.getElementById("confettiContainer");
    const blastRays = document.getElementById("blastRays");
    const riderLayer = document.getElementById("deliveryRiderLayer");

    const orderKey = "smartbite_celebrated_order_" +
        "<%= orderId.replace("\\", "\\\\").replace("\"", "\\\"") %>";

    try {
        if (sessionStorage.getItem(orderKey) === "1") {
            return;
        }

        sessionStorage.setItem(orderKey, "1");
    } catch (e) {
        // Continue if sessionStorage is unavailable.
    }

    const colors = [
        "#ff3f68", "#ffcc33", "#38d9ff", "#9b5cff",
        "#4ade80", "#ff8a3d", "#ff65d4", "#ffffff",
        "#00e5a8", "#5c7cfa"
    ];

    for (let i = 0; i < 28; i++) {
        const ray = document.createElement("span");
        ray.className = "blast-ray";
        ray.style.setProperty("--angle", (i * (360 / 28)) + "deg");
        ray.style.setProperty("--ray-color", colors[i % colors.length]);
        ray.style.setProperty("--delay", (Math.random() * 180) + "ms");
        blastRays.appendChild(ray);
    }

    for (let i = 0; i < 150; i++) {
        const piece = document.createElement("span");
        const roll = Math.random();

        piece.className = "confetti-piece";

        if (roll < 0.18) {
            piece.classList.add("is-circle");
        } else if (roll > 0.82) {
            piece.classList.add("is-ribbon");
        } else if (Math.random() > 0.5) {
            piece.classList.add("rain");
        }

        const angle = Math.random() * Math.PI * 2;
        const distance = 120 + Math.random() *
            Math.max(window.innerWidth, window.innerHeight) * 0.7;

        const travelX = Math.cos(angle) * distance;
        const travelY = Math.sin(angle) * distance + 90 + Math.random() * 260;

        piece.style.setProperty("--piece-color",
            colors[Math.floor(Math.random() * colors.length)]);
        piece.style.setProperty("--travel-x", travelX.toFixed(0) + "px");
        piece.style.setProperty("--travel-y", travelY.toFixed(0) + "px");
        piece.style.setProperty("--spin",
            (Math.random() * 1800 - 900).toFixed(0) + "deg");
        piece.style.setProperty("--piece-width",
            (5 + Math.random() * 9).toFixed(0) + "px");
        piece.style.setProperty("--piece-height",
            (9 + Math.random() * 15).toFixed(0) + "px");
        piece.style.setProperty("--duration",
            (2.2 + Math.random() * 2.2).toFixed(2) + "s");
        piece.style.setProperty("--delay",
            (Math.random() * 450).toFixed(0) + "ms");
        piece.style.setProperty("--piece-radius",
            Math.random() > 0.5 ? "2px" : "0");

        confettiContainer.appendChild(piece);
    }

    celebrationLayer.classList.remove("is-hidden");
    riderLayer.classList.remove("is-hidden");

    requestAnimationFrame(function () {
        celebrationLayer.classList.add("play");
        riderLayer.classList.add("play");
    });

    /* Keep the celebration message visible for 7.6 seconds. */
    window.setTimeout(function () {
        celebrationLayer.classList.remove("play");
        celebrationLayer.classList.add("is-hidden");
    }, 7600);

    /* Let the scooter complete its diagonal trip before hiding it. */
    window.setTimeout(function () {
        riderLayer.classList.remove("play");
        riderLayer.classList.add("is-hidden");
    }, 5600);
})();
</script>

<%@ include file="ai-assistant.jsp" %>

<footer>
    <p>&copy; 2026 SmartBite Delivery Platform. All rights reserved.</p>
</footer>

</body>
</html>
