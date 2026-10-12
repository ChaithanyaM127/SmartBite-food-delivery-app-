<%@ page import="java.util.List" %>
<%@ page import="com.foodtap.model.User" %>
<%@ page import="com.foodtap.model.CartItem" %>

<%
User ftUser = (User) session.getAttribute("loggedInUser");

String ftName = (ftUser != null &&
ftUser.getName() != null &&
!ftUser.getName().trim().isEmpty())
? ftUser.getName().trim()
: "Guest";

int ftCartCount = 0;
Object ftCartObj = session.getAttribute("cart");

if (ftCartObj instanceof List) {
for (Object o : (List<?>) ftCartObj) {
if (o instanceof CartItem) {
ftCartCount += ((CartItem) o).getQuantity();
}
}
}

String ftP = request.getServletPath();
%>

<style>
.ft-nav {
    width: 100%;
    min-height: 72px;
    box-sizing: border-box;
    background: rgba(17, 17, 17, 0.96);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 45px;
    position: sticky;
    top: 0;
    z-index: 1000;
    border-bottom: 1px solid rgba(255, 107, 0, 0.3);
    backdrop-filter: blur(14px);
    font-family: Arial, Helvetica, sans-serif;
    transition: background 0.25s ease, border-color 0.25s ease;
}

.ft-logo {
    color: #ff7618;
    font-size: 28px;
    font-weight: 900;
    letter-spacing: 0.5px;
    text-decoration: none;
    white-space: nowrap;
    transition: color 0.25s ease;
}

.ft-logo:hover {
    color: #ff984f;
}

.ft-links {
    display: flex;
    align-items: center;
    gap: 26px;
    flex-wrap: wrap;
}

.ft-links a {
    color: #e8e8e8;
    text-decoration: none;
    font-size: 15px;
    font-weight: 600;
    transition: color 0.25s ease;
}

.ft-links a:hover,
.ft-links a.ft-on {
    color: #ff7618;
}

.ft-theme {
    width: 38px;
    height: 38px;
    padding: 0;
    margin: 0;
    border: 1px solid rgba(255, 118, 24, 0.35);
    background: rgba(255, 255, 255, 0.06);
    color: #ff984f;
    border-radius: 11px;
    cursor: pointer;
    font-size: 18px;
    line-height: 38px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.25s ease, border-color 0.25s ease, transform 0.25s ease;
}

.ft-theme:hover {
    background: rgba(255, 118, 24, 0.12);
    border-color: #ff7618;
    transform: translateY(-1px);
}

.ft-right {
    display: flex;
    align-items: center;
    gap: 14px;
}

.ft-cart {
    position: relative;
    color: #f5f5f5;
    font-size: 23px;
    text-decoration: none;
    display: flex;
    align-items: center;
    transition: transform 0.25s ease, color 0.25s ease;
}

.ft-cart:hover {
    color: #ff7618;
    transform: scale(1.08);
}

.ft-badge {
    position: absolute;
    top: -8px;
    right: -11px;
    background: #ff7618;
    color: #fff;
    font-size: 10px;
    font-weight: 800;
    min-width: 18px;
    height: 18px;
    box-sizing: border-box;
    border-radius: 9px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 4px;
    border: 2px solid #171717;
}

.ft-user {
    position: relative;
    display: flex;
    align-items: center;
    cursor: pointer;
    padding: 5px;
    border-radius: 50%;
    transition: background 0.25s ease;
}

.ft-user:hover {
    background: rgba(255, 118, 24, 0.12);
}

.ft-icon {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #ffad52, #ff650d);
    border: 2px solid #ff7618;
    box-sizing: border-box;
    font-size: 18px;
}

.ft-drop {
    position: absolute;
    top: 52px;
    right: 0;
    background: #202020;
    border: 1px solid #383838;
    border-radius: 13px;
    min-width: 190px;
    padding: 6px;
    box-shadow: 0 14px 40px rgba(0, 0, 0, 0.35);
    display: none;
    flex-direction: column;
    z-index: 1001;
}

.ft-drop::before {
    content: "<%= ftName %>";
    display: block;
    color: #ff984f;
    font-size: 12px;
    font-weight: 700;
    padding: 8px 12px 10px;
    border-bottom: 1px solid #383838;
    margin-bottom: 4px;
    overflow-wrap: anywhere;
}

.ft-user:hover .ft-drop,
.ft-user:focus-within .ft-drop {
    display: flex;
}

.ft-drop a {
    color: #e5e5e5;
    text-decoration: none;
    font-size: 13.5px;
    padding: 10px 12px;
    border-radius: 8px;
    transition: background 0.2s ease, color 0.2s ease;
}

.ft-drop a:hover {
    background: rgba(255, 118, 24, 0.13);
    color: #ff984f;
}

body.light-mode .ft-nav {
    background: rgba(255, 250, 244, 0.97);
    border-bottom-color: #f0dfd0;
    box-shadow: 0 3px 16px rgba(70, 43, 20, 0.06);
}

body.light-mode .ft-logo {
    color: #e85d00;
}

body.light-mode .ft-links a {
    color: #38332f;
}

body.light-mode .ft-links a:hover,
body.light-mode .ft-links a.ft-on {
    color: #e85d00;
}

body.light-mode .ft-cart {
    color: #302b27;
}

body.light-mode .ft-cart:hover {
    color: #e85d00;
}

body.light-mode .ft-badge {
    border-color: #fffaf4;
}

body.light-mode .ft-theme {
    background: #fff3e8;
    color: #d95000;
    border-color: #f0d2bc;
}

body.light-mode .ft-theme:hover {
    background: #ffe8d5;
    border-color: #e85d00;
}

body.light-mode .ft-user:hover {
    background: rgba(232, 93, 0, 0.09);
}

body.light-mode .ft-drop {
    background: #fffdf9;
    border-color: #eadfd4;
    box-shadow: 0 14px 40px rgba(65, 43, 24, 0.15);
}

body.light-mode .ft-drop::before {
    color: #e85d00;
    border-bottom-color: #eadfd4;
}

body.light-mode .ft-drop a {
    color: #38332f;
}

body.light-mode .ft-drop a:hover {
    background: #fff0e5;
    color: #d95000;
}

@media (max-width: 768px) {
    .ft-nav {
        padding: 12px 16px;
        gap: 14px;
        flex-wrap: wrap;
    }
    .ft-logo { font-size: 24px; }
    .ft-links { gap: 14px; }
    .ft-links a { font-size: 14px; }
    .ft-right { gap: 10px; }
}

@media (max-width: 480px) {
    .ft-nav { padding: 12px; }
    .ft-links { gap: 12px; }
    .ft-links a { font-size: 13px; }
    .ft-right { gap: 8px; }
    .ft-drop { right: 0; }
}
</style>

<nav class="ft-nav">
    <a href="home.jsp" class="ft-logo">SmartBite</a>

    <div class="ft-links">
        <a href="home.jsp" class="<%= ftP.equals("/home.jsp") ? "ft-on" : "" %>">Home</a>
        <a href="restaurants" class="<%= ftP.equals("/restaurants") ? "ft-on" : "" %>">Restaurants</a>
        <a href="orders" class="<%= ftP.equals("/orders") ? "ft-on" : "" %>">Orders</a>
        <a href="health" class="<%= ftP.equals("/health") ? "ft-on" : "" %>">Health</a>
    </div>

    <div class="ft-right">
        <a class="ft-cart" href="cart" title="Cart" aria-label="Cart">
            &#128722;
            <span id="fta-cart-badge" class="ft-badge"><%= ftCartCount %></span>
        </a>

        <button class="ft-theme" type="button" onclick="ftToggleTheme()" title="Toggle light / dark mode" aria-label="Toggle light / dark mode">
            &#9728;
        </button>

        <div class="ft-user" title="<%= ftName %>" tabindex="0">
            <span class="ft-icon">&#128100;</span>
            <div class="ft-drop">
                <a href="profile.jsp">&#128100; My Profile</a>
                <a href="orders">&#128230; My Orders</a>
                <a href="health">&#127919; Health Goals</a>
                <a href="logout">&#128682; Logout</a>
            </div>
        </div>
    </div>
</nav>

<script>
function ftUpdateThemeButton() {
    var dark = !document.body.classList.contains("light-mode");
    var button = document.querySelector(".ft-theme");
    if (button) {
        button.innerHTML = dark ? "&#9728;" : "&#127769;";
    }
}

function ftToggleTheme() {
    document.body.classList.toggle("light-mode");
    var dark = !document.body.classList.contains("light-mode");
    localStorage.setItem("foodtapTheme", dark ? "dark" : "light");
    ftUpdateThemeButton();
}

if (localStorage.getItem("foodtapTheme") === "light") {
    document.body.classList.add("light-mode");
}

// Global cart badge synchronizer
function updateCartBadge(count) {
    var badge = document.getElementById("fta-cart-badge");
    if (badge) {
        badge.textContent = count;
        if (count > 0) {
            badge.style.display = "flex";
        } else {
            badge.style.display = "flex"; // Keeps 0 visible or set to "none" if preferred
        }
    }
    localStorage.setItem("foodtap_cart_count", count);
}

window.addEventListener("DOMContentLoaded", function() {
    ftUpdateThemeButton();
    var savedCount = localStorage.getItem("foodtap_cart_count");
    if (savedCount !== null && document.getElementById("fta-cart-badge")) {
        document.getElementById("fta-cart-badge").textContent = savedCount;
    }
});
</script>