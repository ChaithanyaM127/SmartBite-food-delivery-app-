<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
/* BiteAI Floating Assistant Widget Styles - Guaranteed High Z-Index */
.biteai-floating-btn {
    position: fixed !important;
    bottom: 25px !important;
    right: 25px !important;
    width: 60px !important;
    height: 60px !important;
    background: linear-gradient(135deg, #e23744, #b21e2b) !important;
    color: white !important;
    border-radius: 50% !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    font-size: 26px !important;
    box-shadow: 0 10px 25px rgba(226, 55, 68, 0.5) !important;
    cursor: pointer !important;
    z-index: 99999 !important;
    transition: transform 0.3s ease, box-shadow 0.3s ease !important;
    border: 2px solid rgba(255, 255, 255, 0.3) !important;
}

.biteai-floating-btn:hover {
    transform: scale(1.08);
    box-shadow: 0 14px 30px rgba(226, 55, 68, 0.7);
}

.biteai-modal {
    position: fixed !important;
    bottom: 95px !important;
    right: 25px !important;
    width: 380px !important;
    max-height: 600px !important;
    background: var(--bg-card-dark, #121318) !important;
    border: 1px solid var(--panel-border, rgba(255, 255, 255, 0.08)) !important;
    border-radius: 20px !important;
    box-shadow: var(--shadow, 0 20px 50px rgba(0,0,0,0.6)) !important;
    display: none;
    flex-direction: column !important;
    overflow: hidden !important;
    z-index: 100000 !important;
    backdrop-filter: blur(15px);
    -webkit-backdrop-filter: blur(15px);
    animation: biteAiSlideUp 0.3s ease;
}

@keyframes biteAiSlideUp {
    from { opacity: 0; transform: translateY(15px) scale(0.95); }
    to { opacity: 1; transform: translateY(0) scale(1); }
}

.biteai-header {
    background: var(--metric-bg, rgba(255, 255, 255, 0.04));
    padding: 14px 18px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid var(--panel-border, rgba(255, 255, 255, 0.08));
}

.biteai-title {
    font-size: 15px;
    font-weight: 800;
    color: var(--text-main, #fff);
    display: flex;
    align-items: center;
    gap: 8px;
}

.biteai-status-dot {
    width: 8px;
    height: 8px;
    background: #22c55e;
    border-radius: 50%;
    box-shadow: 0 0 8px #22c55e;
}

.biteai-header-controls {
    display: flex;
    align-items: center;
    gap: 8px;
}

.biteai-lang-select {
    background: var(--bg-page, #0d0d0f);
    border: 1px solid var(--panel-border, rgba(255, 255, 255, 0.08));
    color: var(--text-main, #fff);
    font-size: 11px;
    padding: 4px 6px;
    border-radius: 6px;
    outline: none;
    font-family: 'Plus Jakarta Sans', sans-serif;
    cursor: pointer;
}

.biteai-mute-btn {
    background: transparent;
    border: none;
    font-size: 14px;
    cursor: pointer;
    padding: 2px;
}

.biteai-close {
    background: transparent;
    border: none;
    color: var(--text-muted, #a1a1aa);
    font-size: 18px;
    cursor: pointer;
    font-weight: 800;
}

.biteai-close:hover {
    color: var(--text-main, #fff);
}

.biteai-body {
    padding: 16px;
    overflow-y: auto;
    flex-grow: 1;
    max-height: 400px;
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.biteai-msg {
    padding: 12px 14px;
    border-radius: 12px;
    font-size: 13.5px;
    line-height: 1.5;
    max-width: 88%;
    font-weight: 600;
}

.biteai-msg.bot {
    background: var(--metric-bg, rgba(255, 255, 255, 0.04));
    border: 1px solid var(--panel-border, rgba(255, 255, 255, 0.08));
    color: var(--text-main, #fff);
    align-self: flex-start;
}

.biteai-msg.user {
    background: #e23744;
    color: #fff;
    align-self: flex-end;
}

/* Interactive Drill-Down Suggestion Chips */
.biteai-suggestions {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-top: 8px;
}

.biteai-chip {
    background: var(--metric-bg, rgba(255, 255, 255, 0.06));
    border: 1px solid var(--panel-border, rgba(255, 255, 255, 0.1));
    color: var(--text-main, #fff);
    font-size: 11.5px;
    padding: 6px 10px;
    border-radius: 16px;
    cursor: pointer;
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-weight: 600;
    transition: background 0.2s ease, border-color 0.2s ease, transform 0.1s ease;
}

.biteai-chip:hover {
    background: #e23744;
    border-color: #e23744;
    color: white;
    transform: translateY(-1px);
}

.biteai-footer {
    padding: 12px 16px;
    background: var(--metric-bg, rgba(255, 255, 255, 0.04));
    border-top: 1px solid var(--panel-border, rgba(255, 255, 255, 0.08));
    display: flex;
    gap: 8px;
    align-items: center;
}

.biteai-input {
    flex-grow: 1;
    background: var(--bg-page, #0d0d0f);
    border: 1px solid var(--panel-border, rgba(255, 255, 255, 0.08));
    border-radius: 10px;
    padding: 10px 14px;
    color: var(--text-main, #fff);
    font-size: 13.5px;
    outline: none;
    font-family: 'Plus Jakarta Sans', sans-serif;
}

.biteai-input:focus {
    border-color: #e23744;
}

.biteai-action-btn {
    background: #e23744;
    color: white;
    border: none;
    border-radius: 10px;
    width: 38px;
    height: 38px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    font-size: 15px;
    transition: background 0.2s ease;
}

.biteai-action-btn:hover {
    background: #d12e3b;
}

.biteai-mic-btn.listening {
    background: #22c55e;
    animation: pulseMic 1.2s infinite;
}

@keyframes pulseMic {
    0% { box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.4); }
    70% { box-shadow: 0 0 0 10px rgba(34, 197, 94, 0); }
    100% { box-shadow: 0 0 0 0 rgba(34, 197, 94, 0); }
}

@media(max-width: 480px) {
    .biteai-modal {
        width: 92% !important;
        right: 4% !important;
        bottom: 85px !important;
    }
}
</style>

<!-- Floating Toggle Button -->
<div class="biteai-floating-btn" onclick="toggleBiteAI()" title="Chat with BiteAI">
    🤖
</div>

<!-- Chat Modal Panel -->
<div class="biteai-modal" id="biteAiModal">
    <div class="biteai-header">
        <div class="biteai-title">
            <div class="biteai-status-dot"></div>
            BiteAI Assistant
        </div>
        <div class="biteai-header-controls">
            <!-- 11 Languages Support -->
            <select class="biteai-lang-select" id="biteAiLangSelect" title="Select Voice/Speech Language">
                <option value="en-US">English</option>
                <option value="hi-IN">हिंदी (Hindi)</option>
                <option value="kn-IN">ಕನ್ನಡ (Kannada)</option>
                <option value="te-IN">తెలుగు (Telugu)</option>
                <option value="ta-IN">தமிழ் (Tamil)</option>
                <option value="ml-IN">മലയാളം (Malayalam)</option>
                <option value="bn-IN">বাংলা (Bengali)</option>
                <option value="mr-IN">मराठी (Marathi)</option>
                <option value="gu-IN">ગુજરાતી (Gujarati)</option>
                <option value="es-ES">Español</option>
                <option value="fr-FR">Français</option>
            </select>
            <!-- Voice Mute / Unmute Button -->
            <button class="biteai-mute-btn" id="biteAiMuteBtn" onclick="toggleBiteAiMute()" title="Mute/Unmute Voice">🔊</button>
            <button class="biteai-close" onclick="toggleBiteAI()">&times;</button>
        </div>
    </div>
    
    <div class="biteai-body" id="biteAiChatBody">
        <div class="biteai-msg bot">
            Hello! I'm <strong>BiteAI</strong>, your personal SmartBite concierge. What would you like to explore today?
            <div class="biteai-suggestions">
                <button class="biteai-chip" onclick="handleCategoryClick('weather')">🌤️ Weather Specials</button>
                <button class="biteai-chip" onclick="handleCategoryClick('mood')">😌 Mood Cravings</button>
                <button class="biteai-chip" onclick="handleCategoryClick('price')">💰 Price &amp; Budget</button>
                <button class="biteai-chip" onclick="handleCategoryClick('health')">🥗 Health &amp; Calories</button>
            </div>
        </div>
    </div>
    
    <div class="biteai-footer">
        <input type="text" class="biteai-input" id="biteAiUserInput" placeholder="Ask BiteAI or type a craving..." onkeydown="handleBiteAiKey(event)">
        <button class="biteai-action-btn biteai-mic-btn" id="biteAiMicBtn" onclick="toggleBiteAiVoice()" title="Voice Command">🎙️</button>
        <button class="biteai-action-btn" onclick="sendBiteAiMessage()" title="Send">➤</button>
    </div>
</div>

<script>
let biteAiMuted = false;

function toggleBiteAI() {
    var modal = document.getElementById("biteAiModal");
    if (modal.style.display === "flex") {
        modal.style.display = "none";
    } else {
        modal.style.display = "flex";
        document.getElementById("biteAiUserInput").focus();
    }
}

function toggleBiteAiMute() {
    biteAiMuted = !biteAiMuted;
    var muteBtn = document.getElementById("biteAiMuteBtn");
    if (muteBtn) {
        muteBtn.textContent = biteAiMuted ? "🔇" : "🔊";
    }
    if (biteAiMuted && 'speechSynthesis' in window) {
        window.speechSynthesis.cancel();
    }
}

function appendBiteAiMessage(text, sender) {
    var body = document.getElementById("biteAiChatBody");
    var div = document.createElement("div");
    div.className = "biteai-msg " + sender;
    div.innerHTML = text;
    body.appendChild(div);
    body.scrollTop = body.scrollHeight;
}

// Multi-step drill-down options handler with direct restaurant action cards
function handleCategoryClick(category) {
    var userChoiceText = "";
    var botReplyText = "";
    var subChipsHtml = "";

    if (category === 'weather') {
        userChoiceText = "Show food based on weather";
        botReplyText = "How is the weather looking right now where you are?";
        subChipsHtml = `
            <div class="biteai-suggestions">
                <button class="biteai-chip" onclick="handleSubChoice('Rainy / Monsoon: Hot Samosas, Chai, and Creamy Soup')">🌧️ Rainy &amp; Cold</button>
                <button class="biteai-chip" onclick="handleSubChoice('Sunny / Hot: Ice Creams, Fresh Juices, and Salads')">☀️ Sunny &amp; Hot</button>
                <button class="biteai-chip" onclick="handleSubChoice('Breezy / Pleasant: Wood-fired Pizza and Garlic Bread')">🍃 Pleasant / Breezy</button>
            </div>`;
    } else if (category === 'mood') {
        userChoiceText = "Recommend food for my mood";
        botReplyText = "How are you feeling right now? Pick your current vibe:";
        subChipsHtml = `
            <div class="biteai-suggestions">
                <button class="biteai-chip" onclick="handleSubChoice('Comfort Food: Hyderabadi Dum Biryani and Butter Chicken')">🛋️ Comfort &amp; Cozy</button>
                <button class="biteai-chip" onclick="handleSubChoice('Party / Celebration: Extra Cheese Pizza and Choco Lava Cake')">🎉 Party &amp; Cheerful</button>
                <button class="biteai-chip" onclick="handleSubChoice('Stressed / Late-Night Coding: Spicy Noodles and Cold Coffee')">💻 Late-Night Grind</button>
            </div>`;
    } else if (category === 'price') {
        userChoiceText = "Show budget friendly meals";
        botReplyText = "Select your desired price range or budget:";
        subChipsHtml = `
            <div class="biteai-suggestions">
                <button class="biteai-chip" onclick="handleSubChoice('Under ₹150: Masala Dosa, Veg Roll, and Samosa Chaat')">🪙 Under ₹150</button>
                <button class="biteai-chip" onclick="handleSubChoice('₹150 - ₹350: Paneer Butter Masala Combo and Burger Meals')">💵 ₹150 - ₹350</button>
                <button class="biteai-chip" onclick="handleSubChoice('Premium Feasts (₹350+): Gourmet Biryani Buckets and Platters')">👑 Premium Feasts</button>
            </div>`;
    } else if (category === 'health') {
        userChoiceText = "Track my calories and health";
        botReplyText = "What health goal are you focusing on today?";
        subChipsHtml = `
            <div class="biteai-suggestions">
                <button class="biteai-chip" onclick="handleSubChoice('Low Calorie: Grilled Chicken Salad and Green Smoothies')">🥗 Low Calorie &amp; Fit</button>
                <button class="biteai-chip" onclick="handleSubChoice('High Protein: Paneer Tikka Wrap and Protein Oats Shake')">💪 High Protein</button>
                <button class="biteai-chip" onclick="handleSubChoice('Check Health Dashboard: Head over to your Health tab')">📊 Open Health Dashboard</button>
            </div>`;
    }

    appendBiteAiMessage(userChoiceText, "user");
    setTimeout(function() {
        appendBiteAiMessage(botReplyText + subChipsHtml, "bot");
        speakBiteAiResponse(botReplyText);
    }, 400);
}

function handleSubChoice(foodRecommendation) {
    appendBiteAiMessage(foodRecommendation, "user");
    setTimeout(function() {
        var replyHtml = `
            Great choice! Here are the top matching options on SmartBite for: <strong>` + foodRecommendation + `</strong>
            <div style="margin-top: 10px; display: flex; flex-direction: column; gap: 8px;">
                <div style="background: var(--bg-page, #0d0d0f); border: 1px solid var(--panel-border, rgba(255,255,255,0.1)); padding: 10px; border-radius: 10px; display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <div style="font-weight: 700; color: var(--text-main, #fff); font-size: 13px;">Spice Route Kitchen</div>
                        <div style="font-size: 11.5px; color: var(--text-muted, #a1a1aa);">` + foodRecommendation + ` • ₹240</div>
                    </div>
                    <a href="food-details.jsp?restaurant=spice-route" style="background: #e23744; color: white; text-decoration: none; padding: 6px 12px; border-radius: 6px; font-size: 11.5px; font-weight: 700;">View Menu ➔</a>
                </div>
                <div style="background: var(--bg-page, #0d0d0f); border: 1px solid var(--panel-border, rgba(255,255,255,0.1)); padding: 10px; border-radius: 10px; display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <div style="font-weight: 700; color: var(--text-main, #fff); font-size: 13px;">Urban Tadka Diner</div>
                        <div style="font-size: 11.5px; color: var(--text-muted, #a1a1aa);">Chef's Special Variant • ₹195</div>
                    </div>
                    <a href="food-details.jsp?restaurant=urban-tadka" style="background: #e23744; color: white; text-decoration: none; padding: 6px 12px; border-radius: 6px; font-size: 11.5px; font-weight: 700;">View Menu ➔</a>
                </div>
            </div>`;
        
        appendBiteAiMessage(replyHtml, "bot");
        speakBiteAiResponse("Here are the top restaurants matching your selection. Tap View Menu to order.");
    }, 400);
}

function sendBiteAiMessage() {
    var input = document.getElementById("biteAiUserInput");
    var query = input.value.trim();
    if (!query) return;

    appendBiteAiMessage(query, "user");
    input.value = "";

    // Intelligent local response generation for SmartBite context
    setTimeout(function() {
        var lower = query.toLowerCase();
        var reply = "I can help you explore restaurants, check your health dashboard, or find weather-based meal suggestions on SmartBite!";
        
        if (lower.includes("weather") || lower.includes("rain") || lower.includes("sunny")) {
            reply = "Check out our Weather page in the navigation menu to get tailored food pairings for your city's current climate!";
        } else if (lower.includes("mood") || lower.includes("cravings") || lower.includes("feeling")) {
            reply = "Feeling a certain way? How about some comforting biryani, hot soup, or sweet treats from our top-rated restaurants?";
        } else if (lower.includes("price") || lower.includes("budget") || lower.includes("cheap") || lower.includes("under 200")) {
            reply = "We have amazing budget-friendly options starting under ₹150! Head over to the Restaurants section and filter by price.";
        } else if (lower.includes("calorie") || lower.includes("health") || lower.includes("diet")) {
            reply = "You can track your daily intake and remaining calories anytime over at your Health Dashboard.";
        } else if (lower.includes("cart") || lower.includes("order")) {
            reply = "You can view your active cart items and checkout seamlessly right from the top navigation bar.";
        } else if (lower.includes("hello") || lower.includes("hi")) {
            reply = "Hi there! Ready to explore some amazing dishes on SmartBite?";
        }
        
        appendBiteAiMessage(reply, "bot");
        speakBiteAiResponse(reply);
    }, 500);
}

function handleBiteAiKey(e) {
    if (e.key === "Enter") {
        sendBiteAiMessage();
    }
}

// Native Web Speech API Integration with Multi-language support
let recognition = null;
let isListening = false;

function initSpeechRecognition() {
    if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        recognition = new SpeechRecognition();
        recognition.continuous = false;
        recognition.interimResults = false;

        recognition.onresult = function(event) {
            const transcript = event.results[0][0].transcript;
            document.getElementById("biteAiUserInput").value = transcript;
            stopBiteAiVoice();
            sendBiteAiMessage();
        };

        recognition.onerror = function(event) {
            stopBiteAiVoice();
        };

        recognition.onend = function() {
            stopBiteAiVoice();
        };
    }
}

initSpeechRecognition();

function toggleBiteAiVoice() {
    if (!recognition) {
        alert("Speech recognition is not supported by your browser. Please try Chrome or Edge.");
        return;
    }

    const selectedLang = document.getElementById("biteAiLangSelect").value;
    recognition.lang = selectedLang;

    if (isListening) {
        recognition.stop();
        stopBiteAiVoice();
    } else {
        try {
            recognition.start();
            isListening = true;
            document.getElementById("biteAiMicBtn").classList.add("listening");
            document.getElementById("biteAiUserInput").placeholder = "Listening...";
        } catch (e) {
            stopBiteAiVoice();
        }
    }
}

function stopBiteAiVoice() {
    isListening = false;
    var micBtn = document.getElementById("biteAiMicBtn");
    if (micBtn) micBtn.classList.remove("listening");
    var input = document.getElementById("biteAiUserInput");
    if (input) input.placeholder = "Ask BiteAI or type a craving...";
}

function speakBiteAiResponse(text) {
    if (biteAiMuted) return;
    if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();
        var utterance = new SpeechSynthesisUtterance(text);
        var selectedLang = document.getElementById("biteAiLangSelect").value;
        utterance.lang = selectedLang;
        utterance.rate = 1.0;
        utterance.pitch = 1.0;
        window.speechSynthesis.speak(utterance);
    }
}
</script>