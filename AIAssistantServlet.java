package com.foodtap.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * FOODTAP AI Assistant "Tapu" — MULTILINGUAL (11 languages).
 * en/hi/kn/te/ta/mr/bn/gu/pa/ml/ur
 * Auto-detects the user's script, understands native dish words,
 * Hinglish, and answers from FOODTAP's own MySQL database.
 */
@WebServlet("/ai-assistant")
public class AIAssistantServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Random RND = new Random();

    /* ---------- script detection ---------- */
    private static final Pattern P_DEV   = Pattern.compile("[\\u0900-\\u097F]"); // Devanagari: hi mr
    private static final Pattern P_BENG  = Pattern.compile("[\\u0980-\\u09FF]"); // Bengali: bn
    private static final Pattern P_GURU  = Pattern.compile("[\\u0A00-\\u0A7F]"); // Gurmukhi: pa
    private static final Pattern P_GUJ   = Pattern.compile("[\\u0A80-\\u0AFF]"); // Gujarati: gu
    private static final Pattern P_URDU  = Pattern.compile("[\\u0600-\\u06FF]"); // Arabic script: ur
    private static final Pattern P_TAML  = Pattern.compile("[\\u0B80-\\u0BFF]"); // Tamil: ta
    private static final Pattern P_TELU  = Pattern.compile("[\\u0C00-\\u0C7F]"); // Telugu: te
    private static final Pattern P_KNDA  = Pattern.compile("[\\u0C80-\\u0CFF]"); // Kannada: kn
    private static final Pattern P_MLM   = Pattern.compile("[\\u0D00-\\u0D7F]"); // Malayalam: ml

    /* ============================ TRANSLATIONS ============================ */
    private static final Map<String, String> EN = new HashMap<>();
    private static final Map<String, Map<String, String>> L = new HashMap<>();
    private static void p(Map<String, String> m, String k, String v) { m.put(k, v); }

    static {
        /* ===== ENGLISH ===== */
        p(EN, "greet", "Hey! I'm <b>Tapu</b> 🍊 — your food buddy. Ask me for dishes, calories, or say \"help\".");
        p(EN, "help", "I can find food, watch calories, track orders & more! Try:");
        p(EN, "found", "Found these for you 😍");
        p(EN, "look", "Look what I discovered 🍽️");
        p(EN, "choice", "Great choice! 🔥");
        p(EN, "kitchen", "Fresh from the kitchen 👨‍🍳");
        p(EN, "budget", "Here's what fits your budget 🪙");
        p(EN, "healthy", "Fresh & light options, lowest calories first 🥗");
        p(EN, "protein", "Protein power-ups 💪 highest protein first:");
        p(EN, "nutri", "Nutrition breakdown 📊");
        p(EN, "nothing", "<i>Nothing found 😕 try another dish</i>");
        p(EN, "goalset", "Done ✅ Daily goal is now <b>{0}</b> kcal!");
        p(EN, "goalnone", "You haven't set a goal yet — say <b>\"set my goal to 1800\"</b> 🎯");
        p(EN, "goallogin", "Log in first and I'll track your calories 🔐");
        p(EN, "goalstat", "🎯 <b>Goal: {0} kcal</b><br>Consumed: {1} kcal<br>Remaining: {2} kcal<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(EN, "gsspare", "Nice, {0} kcal to spare!");
        p(EN, "gsover", "Limit reached — keep tonight light! 🥗");
        p(EN, "tracknone", "No orders yet — hungry? Say \"show me biryani\" 🍛");
        p(EN, "tr_head", "Latest order <b>#{0}</b> from {1}<br>");
        p(EN, "tr_status", "Status: {0}<br>");
        p(EN, "tr_amt", "Amount: ₹{0}<br>");
        p(EN, "tr_time", "Placed: {0}");
        p(EN, "added", "Added <b>{0}</b> to your cart 🛒✨");
        p(EN, "addfail", "Couldn't find \"{0}\" on any menu 😕");
        p(EN, "addempty", "Which dish should I add? Name it 🛒");
        p(EN, "spots", "Top-rated spots for you 🍴");
        p(EN, "spotsfor", "Best {0} places 🍴");
        p(EN, "fallback", "Hmm, couldn't find that 🤔 Try \"biryani\", \"pizza\", \"momos\" or say \"help\".");
        p(EN, "moodwet", "It's {0} in Bangalore 🌧️ — hot comfort food fits perfectly");
        p(EN, "moodhot", "It's {0} outside ☀️ — keeping it cool and light");
        p(EN, "moodok", "Pleasant weather 🌤️ — here's what suits the mood");
        p(EN, "spleft", " • you have <b>{0} kcal</b> left today:");
        p(EN, "splow", "You've nearly used today's calorie budget 🔔 — go for a salad or green tea (say \"healthy food\").");
        p(EN, "tryh", "<i>try \"healthy food\"</i>");

        /* ===== HINDI ===== */
        Map<String, String> hi = new HashMap<>();
        p(hi, "greet", "नमस्ते! मैं <b>टैपू</b> 🍊 हूँ — आपका फूड बड्डी। डिश, कैलोरी पूछो या \"help\" लिखो।");
        p(hi, "help", "मैं खाना ढूँढ सकता हूँ, कैलोरी गिन सकता हूँ, ऑर्डर ट्रैक कर सकता हूँ! आज़माओ:");
        p(hi, "found", "आपके लिए ये मिले 😍");
        p(hi, "look", "ये देखो, क्या मिला 🍽️");
        p(hi, "choice", "वाह, बढ़िया चुनाव! 🔥");
        p(hi, "kitchen", "रसोई से ताज़ा 👨‍🍳");
        p(hi, "budget", "आपके बजट में ये है 🪙");
        p(hi, "healthy", "हल्के-ताज़े विकल्प, कम कैलोरी पहले 🥗");
        p(hi, "protein", "प्रोटीन पावर 💪 ज़्यादा प्रोटीन पहले:");
        p(hi, "nutri", "पोषण जानकारी 📊");
        p(hi, "nothing", "<i>कुछ नहीं मिला 😕 दूसरी डिश आज़माओ</i>");
        p(hi, "goalset", "हो गया ✅ डेली गोल अब <b>{0}</b> कैलोरी है!");
        p(hi, "goalnone", "गोल सेट नहीं है — लिखो <b>\"set my goal to 1800\"</b> 🎯");
        p(hi, "goallogin", "पहले लॉगिन करो, फिर मैं कैलोरी गिनूँगा 🔐");
        p(hi, "goalstat", "🎯 <b>गोल: {0} कैलोरी</b><br>खाया: {1} कैलोरी<br>बचा: {2} कैलोरी<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(hi, "gsspare", "शाबाश, {0} कैलोरी बची है!");
        p(hi, "gsover", "आज की लिमिट पार — शाम हल्का रखो! 🥗");
        p(hi, "tracknone", "अभी कोई ऑर्डर नहीं — भूख लगी? लिखो \"show me biryani\" 🍛");
        p(hi, "tr_head", "नवीनतम ऑर्डर <b>#{0}</b> — {1}<br>");
        p(hi, "tr_status", "स्थिति: {0}<br>");
        p(hi, "tr_amt", "राशि: ₹{0}<br>");
        p(hi, "tr_time", "समय: {0}");
        p(hi, "added", "<b>{0}</b> कार्ट में डाल दिया 🛒✨");
        p(hi, "addfail", "\"{0}\" मेन्यू में नहीं मिला 😕");
        p(hi, "addempty", "कौन सी डिश डालूँ? नाम बताओ 🛒");
        p(hi, "spots", "आपके लिए टॉप जगहें 🍴");
        p(hi, "spotsfor", "{0} के लिए बेस्ट जगहें 🍴");
        p(hi, "fallback", "समझ नहीं आया 🤔 \"biryani\", \"pizza\", \"momos\" आज़माओ या \"help\" लिखो।");
        p(hi, "moodwet", "बाहर {0} है 🌧️ — गरम आराम वाला खाना बेस्ट");
        p(hi, "moodhot", "बाहर {0} है ☀️ — कुछ ठंडा-हल्का सही रहेगा");
        p(hi, "moodok", "मौसम सुहावना है 🌤️ — ये देखो");
        p(hi, "spleft", " • आज <b>{0} कैलोरी</b> बची हैं:");
        p(hi, "splow", "आज की कैलोरी लगभग खत्म 🔔 — सलाद या ग्रीन टी लो (\"healthy food\" लिखो)।");
        p(hi, "tryh", "<i>\"healthy food\" आज़माओ</i>");
        L.put("hi", hi);

        /* ===== KANNADA ===== */
        Map<String, String> kn = new HashMap<>();
        p(kn, "greet", "ನಮಸ್ಕಾರ! ನಾನು <b>ಟಾಪು</b> 🍊 — ನಿಮ್ಮ ಫುಡ್ ಬಡ್ಡಿ. ಖಾದ್ಯ, ಕ್ಯಾಲೊರಿ ಕೇಳಿ ಅಥವಾ \"help\" ಬರೆಯಿರಿ.");
        p(kn, "help", "ಖಾದ್ಯ ಹುಡುಕಬಲ್ಲೆ, ಕ್ಯಾಲೊರಿ ಎಣಿಸಬಲ್ಲೆ, ಆರ್ಡರ್ ಟ್ರ್ಯಾಕ್ ಮಾಡಬಲ್ಲೆ! ಪ್ರಯತ್ನಿಸಿ:");
        p(kn, "found", "ನಿಮಗಾಗಿ ಇವು ಸಿಕ್ಕಿವೆ 😍");
        p(kn, "look", "ಇವನ್ನು ನೋಡಿ 🍽️");
        p(kn, "choice", "ಸೂಪರ್ ಚಾಯ್ಸ್! 🔥");
        p(kn, "kitchen", "ಅಡುಗೆಮನೆಯಿಂದ ತಾಜಾ 👨‍🍳");
        p(kn, "budget", "ನಿಮ್ಮ ಬಜೆಟ್‌ಗೆ ಇವು 🪙");
        p(kn, "healthy", "ಹಗುರ ತಾಜಾ ಆಯ್ಕೆ, ಕಡಿಮೆ ಕ್ಯಾಲೊರಿ ಮೊದಲು 🥗");
        p(kn, "protein", "ಪ್ರೋಟೀನ್ ಪವರ್ 💪 ಹೆಚ್ಚು ಪ್ರೋಟೀನ್ ಮೊದಲು:");
        p(kn, "nutri", "ಪೋಷಣೆ ಮಾಹಿತಿ 📊");
        p(kn, "nothing", "<i>ಏನೂ ಸಿಗಲಿಲ್ಲ 😕 ಬೇರೆ ಖಾದ್ಯ ಪ್ರಯತ್ನಿಸಿ</i>");
        p(kn, "goalset", "ಆಯಿತು ✅ ದೈನಂದಿನ ಗುರಿ ಈಗ <b>{0}</b> ಕ್ಯಾಲೊರಿ!");
        p(kn, "goalnone", "ಗುರಿ ಇಲ್ಲ — ಬರೆಯಿರಿ <b>\"set my goal to 1800\"</b> 🎯");
        p(kn, "goallogin", "ಮೊದಲು ಲಾಗಿನ್ ಮಾಡಿ, ನಂತರ ಕ್ಯಾಲೊರಿ ಎಣಿಸುವೆ 🔐");
        p(kn, "goalstat", "🎯 <b>ಗುರಿ: {0} ಕ್ಯಾಲೊರಿ</b><br>ತೆಗೆದುಕೊಂಡ: {1}<br>ಉಳಿದಿದೆ: {2}<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(kn, "gsspare", "ಸೂಪರ್, {0} ಕ್ಯಾಲೊರಿ ಉಳಿದಿದೆ!");
        p(kn, "gsover", "ಇಂದಿನ ಮಿತಿ ಮುಗಿಯಿತು — ಸಂಜೆ ಹಗುರವಾಗಿ ತಿನ್ನಿ! 🥗");
        p(kn, "tracknone", "ಇನ್ನೂ ಆರ್ಡರ್ ಇಲ್ಲ — ಹಸಿವಾ? ಬರೆಯಿರಿ \"show me biryani\" 🍛");
        p(kn, "tr_head", "ಇತ್ತೀಚಿನ ಆರ್ಡರ್ <b>#{0}</b> — {1}<br>");
        p(kn, "tr_status", "ಸ್ಥಿತಿ: {0}<br>");
        p(kn, "tr_amt", "ಮೊತ್ತ: ₹{0}<br>");
        p(kn, "tr_time", "ಸಮಯ: {0}");
        p(kn, "added", "<b>{0}</b> ಕಾರ್ಟ್‌ಗೆ ಸೇರಿಸಿದೆ 🛒✨");
        p(kn, "addfail", "\"{0}\" ಮೆನುವಿನಲ್ಲಿ ಇಲ್ಲ 😕");
        p(kn, "addempty", "ಯಾವ ಖಾದ್ಯ ಸೇರಿಸಲಿ? ಹೆಸರು ಹೇಳಿ 🛒");
        p(kn, "spots", "ನಿಮಗಾಗಿ ಟಾಪ್ ಹೋಟೆಲ್‌ಗಳು 🍴");
        p(kn, "spotsfor", "{0} ಗೆ ಬೆಸ್ಟ್ ಸ್ಥಳಗಳು 🍴");
        p(kn, "fallback", "ಅರ್ಥವಾಗಲಿಲ್ಲ 🤔 \"biryani\", \"pizza\", \"momos\" ಪ್ರಯತ್ನಿಸಿ ಅಥವಾ \"help\" ಬರೆಯಿರಿ.");
        p(kn, "moodwet", "ಹೊರಗೆ {0} 🌧️ — ಬಿಸಿ ಊಟ ಸೂಪರ್");
        p(kn, "moodhot", "ಹೊರಗೆ {0} ☀️ — ತಂಪು ಹಗುರ ಊಟ ಸರಿ");
        p(kn, "moodok", "ವಾತಾವರಣ ಚೆನ್ನಾಗಿದೆ 🌤️ — ಇವನ್ನು ನೋಡಿ");
        p(kn, "spleft", " • ಇಂದು <b>{0} ಕ್ಯಾಲೊರಿ</b> ಉಳಿದಿದೆ:");
        p(kn, "splow", "ಇಂದಿನ ಕ್ಯಾಲೊರಿ ಮುಗಿಯಿತು 🔔 — ಸಲಾಡ್ ಅಥವಾ ಗ್ರೀನ್ ಟೀ ತೆಗೆದುಕೊಳ್ಳಿ (\"healthy food\" ಬರೆಯಿರಿ).");
        p(kn, "tryh", "<i>\"healthy food\" ಪ್ರಯತ್ನಿಸಿ</i>");
        L.put("kn", kn);

        /* ===== TELUGU ===== */
        Map<String, String> te = new HashMap<>();
        p(te, "greet", "నమస్కారం! నేను <b>టాపు</b> 🍊 — మీ ఫుడ్ బడ్డీ. వంటకాలు, కేలరీలు అడగండి లేదా \"help\" రాయండి.");
        p(te, "help", "వంటకాలు వెతకగలను, కేలరీలు లెక్కించగలను, ఆర్డర్ ట్రాక్ చేయగలను! ప్రయత్నించండి:");
        p(te, "found", "మీ కోసం ఇవి దొరికాయి 😍");
        p(te, "look", "ఇవి చూడండి 🍽️");
        p(te, "choice", "సూపర్ ఛాయ్స్! 🔥");
        p(te, "kitchen", "వంటగది నుండి తాజాగా 👨‍🍳");
        p(te, "budget", "మీ బడ్జెట్‌లో ఇవి 🪙");
        p(te, "healthy", "తేలికపాటి ఎంపికలు, తక్కువ కేలరీలు ముందు 🥗");
        p(te, "protein", "ప్రోటీన్ పవర్ 💪 ఎక్కువ ప్రోటీన్ ముందు:");
        p(te, "nutri", "పోషక వివరాలు 📊");
        p(te, "nothing", "<i>ఏమీ దొరకలేదు 😕 వేరే వంటకం ప్రయత్నించండి</i>");
        p(te, "goalset", "అయింది ✅ రోజువారీ లక్ష్యం ఇప్పుడు <b>{0}</b> కేలరీలు!");
        p(te, "goalnone", "లక్ష్యం లేదు — రాయండి <b>\"set my goal to 1800\"</b> 🎯");
        p(te, "goallogin", "ముందు లాగిన్ అవ్వండి, తర్వాత కేలరీలు లెక్కిస్తాను 🔐");
        p(te, "goalstat", "🎯 <b>లక్ష్యం: {0} కేలరీలు</b><br>తీసుకున్న: {1}<br>మిగిలింది: {2}<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(te, "gsspare", "సూపర్, {0} కేలరీలు మిగిలాయి!");
        p(te, "gsover", "ఈరోజు లిమిట్ అయింది — సాయంత్రం తేలికగా ఉండండి! 🥗");
        p(te, "tracknone", "ఇన్ను ఆర్డర్ లేదు — ఆకలిగా? రాయండి \"show me biryani\" 🍛");
        p(te, "tr_head", "చివరి ఆర్డర్ <b>#{0}</b> — {1}<br>");
        p(te, "tr_status", "స్థితి: {0}<br>");
        p(te, "tr_amt", "మొత్తం: ₹{0}<br>");
        p(te, "tr_time", "సమయం: {0}");
        p(te, "added", "<b>{0}</b> కార్ట్‌లో వేశాను 🛒✨");
        p(te, "addfail", "\"{0}\" మెనూలో లేదు 😕");
        p(te, "addempty", "ఏ వంటకం వేయాలి? పేరు చెప్పండి 🛒");
        p(te, "spots", "మీ కోసం టాప్ రెస్టారెంట్లు 🍴");
        p(te, "spotsfor", "{0} కి బెస్ట్ చోట్లు 🍴");
        p(te, "fallback", "అర్థం కాలేదు 🤔 \"biryani\", \"pizza\", \"momos\" ప్రయత్నించండి లేదా \"help\" రాయండి.");
        p(te, "moodwet", "బయట {0} 🌧️ — వేడి భోజనం సూపర్");
        p(te, "moodhot", "బయట {0} ☀️ — చల్లగా, తేలికగా ఉండాలి");
        p(te, "moodok", "వాతావరణం బాగుంది 🌤️ — ఇవి చూడండి");
        p(te, "spleft", " • ఈరోజు <b>{0} కేలరీలు</b> మిగిలాయి:");
        p(te, "splow", "ఈరోజు కేలరీలు దాదాపు అయిపోయాయి 🔔 — సలడ్ లేదా గ్రీన్ టీ తీసుకోండి (\"healthy food\" రాయండి).");
        p(te, "tryh", "<i>\"healthy food\" ప్రయత్నించండి</i>");
        L.put("te", te);

        /* ===== TAMIL ===== */
        Map<String, String> ta = new HashMap<>();
        p(ta, "greet", "வணக்கம்! நான் <b>டாப்பு</b> 🍊 — உங்கள் ஃபுட் பட்டி. உணவு, கலோரி கேளுங்கள் அல்லது \"help\" எழுதுங்கள்.");
        p(ta, "help", "உணவு தேடக்கூடியது, கலோரி கணக்கிடக்கூடியது, ஆர்டர் கண்காணிக்கக்கூடியது! முயற்சிக்கவும்:");
        p(ta, "found", "உங்களுக்காக இவை கிடைத்தன 😍");
        p(ta, "look", "இதைப் பாருங்கள் 🍽️");
        p(ta, "choice", "சூப்பர் சாய்ஸ்! 🔥");
        p(ta, "kitchen", "சமையலறையிலிருந்து புதியதாக 👨‍🍳");
        p(ta, "budget", "உங்கள் பட்ஜெட்டுக்கு இவை 🪙");
        p(ta, "healthy", "லேசான விருப்பங்கள், குறைந்த கலோரி முதலில் 🥗");
        p(ta, "protein", "புரத சக்தி 💪 அதிக புரதம் முதலில்:");
        p(ta, "nutri", "ஊட்டச்சத்து விவரம் 📊");
        p(ta, "nothing", "<i>எதுவும் கிடைக்கவில்லை 😕 வேறு உணவை முயற்சிக்கவும்</i>");
        p(ta, "goalset", "முடிந்தது ✅ தினசரி இலக்கு இப்போது <b>{0}</b> கலோரி!");
        p(ta, "goalnone", "இலக்கு இல்லை — எழுதுங்கள் <b>\"set my goal to 1800\"</b> 🎯");
        p(ta, "goallogin", "முதலில் உள்நுழையுங்கள், பிறகு கலோரி கணக்கிடுவேன் 🔐");
        p(ta, "goalstat", "🎯 <b>இலக்கு: {0} கலோரி</b><br>எடுத்தது: {1}<br>மீதம்: {2}<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(ta, "gsspare", "சூப்பர், {0} கலோரி மீதம்!");
        p(ta, "gsover", "இன்றைய வரம்பு முடிந்தது — இன்று மாலை லேசாக இருங்கள்! 🥗");
        p(ta, "tracknone", "இன்னும் ஆர்டர் இல்லை — பசியா? எழுதுங்கள் \"show me biryani\" 🍛");
        p(ta, "tr_head", "சமீபத்திய ஆர்டர் <b>#{0}</b> — {1}<br>");
        p(ta, "tr_status", "நிலை: {0}<br>");
        p(ta, "tr_amt", "தொகை: ₹{0}<br>");
        p(ta, "tr_time", "நேரம்: {0}");
        p(ta, "added", "<b>{0}</b> கார்ட்டில் சேர்க்கப்பட்டது 🛒✨");
        p(ta, "addfail", "\"{0}\" மெனுவில் இல்லை 😕");
        p(ta, "addempty", "எந்த உணவு சேர்க்கவேண்டும்? பெயர் சொல்லுங்கள் 🛒");
        p(ta, "spots", "உங்களுக்கான சிறந்த இடங்கள் 🍴");
        p(ta, "spotsfor", "{0} க்கு சிறந்த இடங்கள் 🍴");
        p(ta, "fallback", "புரியவில்லை 🤔 \"biryani\", \"pizza\", \"momos\" முயற்சிக்கவும் அல்லது \"help\" எழுதுங்கள்.");
        p(ta, "moodwet", "வெளியே {0} 🌧️ — சூடான உணவு சூப்பர்");
        p(ta, "moodhot", "வெளியே {0} ☀️ — குளிர்ச்சியாக, லேசாக இருப்போம்");
        p(ta, "moodok", "வானிலை இனிமையாக உள்ளது 🌤️ — இதைப் பாருங்கள்");
        p(ta, "spleft", " • இன்று <b>{0} கலோரி</b> மீதம்:");
        p(ta, "splow", "இன்றைய கலோரி கிட்டத்தட்ட முடிந்தது 🔔 — சாலட் அல்லது கிரீன் டீ எடுங்கள் (\"healthy food\" எழுதுங்கள்).");
        p(ta, "tryh", "<i>\"healthy food\" முயற்சிக்கவும்</i>");
        L.put("ta", ta);

        /* ===== MARATHI ===== */
        Map<String, String> mr = new HashMap<>();
        p(mr, "greet", "नमस्कार! मी <b>टापू</b> 🍊 — तुमचा फूड बड्डी. पदार्थ, कॅलरी विचारा किंवा \"help\" लिहा.");
        p(mr, "help", "मी खाणे शोधू शकतो, कॅलरी मोजू शकतो, ऑर्डर ट्रॅक करू शकतो! वापरून पहा:");
        p(mr, "found", "तुमच्यासाठी हे सापडले 😍");
        p(mr, "look", "हे पहा 🍽️");
        p(mr, "choice", "छान निवड! 🔥");
        p(mr, "kitchen", "स्वयंपाकघरातून ताजे 👨‍🍳");
        p(mr, "budget", "तुमच्या बजेटमध्ये हे 🪙");
        p(mr, "healthy", "हलके ताजे पर्याय, कमी कॅलरी आधी 🥗");
        p(mr, "protein", "प्रोटीन पावर 💪 जास्त प्रोटीन आधी:");
        p(mr, "nutri", "पोषण माहिती 📊");
        p(mr, "nothing", "<i>काही सापडले नाही 😕 दुसरा पदार्थ वापरून पहा</i>");
        p(mr, "goalset", "झाले ✅ रोजचे लक्ष्य आता <b>{0}</b> कॅलरी!");
        p(mr, "goalnone", "लक्ष्य नाही — लिहा <b>\"set my goal to 1800\"</b> 🎯");
        p(mr, "goallogin", "आधी लॉगिन करा, मग कॅलरी मोजेन 🔐");
        p(mr, "goalstat", "🎯 <b>लक्ष्य: {0} कॅलरी</b><br>खाल्ले: {1}<br>शिल्लक: {2}<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(mr, "gsspare", "छान, {0} कॅलरी शिल्लक!");
        p(mr, "gsover", "आजची मर्यादा संपली — संध्याकाळ हलकी ठेवा! 🥗");
        p(mr, "tracknone", "अजून ऑर्डर नाही — भूक लागली? लिहा \"show me biryani\" 🍛");
        p(mr, "tr_head", "अलीकडची ऑर्डर <b>#{0}</b> — {1}<br>");
        p(mr, "tr_status", "स्थिती: {0}<br>");
        p(mr, "tr_amt", "रक्कम: ₹{0}<br>");
        p(mr, "tr_time", "वेळ: {0}");
        p(mr, "added", "<b>{0}</b> कार्टमध्ये टाकले 🛒✨");
        p(mr, "addfail", "\"{0}\" मेनूमध्ये नाही 😕");
        p(mr, "addempty", "कोणता पदार्थ टाकू? नाव सांगा 🛒");
        p(mr, "spots", "तुमच्यासाठी टॉप ठिकाणे 🍴");
        p(mr, "spotsfor", "{0} साठी बेस्ट ठिकाणे 🍴");
        p(mr, "fallback", "समजले नाही 🤔 \"biryani\", \"pizza\", \"momos\" वापरून पहा किंवा \"help\" लिहा.");
        p(mr, "moodwet", "बाहेर {0} 🌧️ — गरम जेवण सुपर");
        p(mr, "moodhot", "बाहेर {0} ☀️ — थंड हलके जेवण बरोबर");
        p(mr, "moodok", "हवा सुखद आहे 🌤️ — हे पहा");
        p(mr, "spleft", " • आज <b>{0} कॅलरी</b> शिल्लक:");
        p(mr, "splow", "आजच्या कॅलरी जवळपास संपल्या 🔔 — सलाड किंवा ग्रीन टी घ्या (\"healthy food\" लिहा).");
        p(mr, "tryh", "<i>\"healthy food\" वापरून पहा</i>");
        L.put("mr", mr);

        /* ===== BENGALI ===== */
        Map<String, String> bn = new HashMap<>();
        p(bn, "greet", "নমস্কার! আমি <b>টাপু</b> 🍊 — আপনার ফুড বাডি। খাবার, ক্যালরি জিজ্ঞাসা করুন বা \"help\" লিখুন।");
        p(bn, "help", "আমি খাবার খুঁজে দিতে পারি, ক্যালরি গুনতে পারি, অর্ডার ট্র্যাক করতে পারি! চেষ্টা করুন:");
        p(bn, "found", "আপনার জন্য এগুলো পেলাম 😍");
        p(bn, "look", "এগুলো দেখুন 🍽️");
        p(bn, "choice", "দারুণ চয়েস! 🔥");
        p(bn, "kitchen", "রান্নাঘর থেকে টাটকা 👨‍🍳");
        p(bn, "budget", "আপনার বাজেটে এগুলো 🪙");
        p(bn, "healthy", "হালকা তাজা অপশন, কম ক্যালরি আগে 🥗");
        p(bn, "protein", "প্রোটিন পাওয়ার 💪 বেশি প্রোটিন আগে:");
        p(bn, "nutri", "পুষ্টি তথ্য 📊");
        p(bn, "nothing", "<i>কিছু পাওয়া যায়নি 😕 অন্য খাবার চেষ্টা করুন</i>");
        p(bn, "goalset", "হয়ে গেছে ✅ দৈনিক লক্ষ্য এখন <b>{0}</b> ক্যালরি!");
        p(bn, "goalnone", "লক্ষ্য নেই — লিখুন <b>\"set my goal to 1800\"</b> 🎯");
        p(bn, "goallogin", "আগে লগইন করুন, তারপর ক্যালরি গুনব 🔐");
        p(bn, "goalstat", "🎯 <b>লক্ষ্য: {0} ক্যালরি</b><br>খেয়েছেন: {1}<br>বাকি: {2}<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(bn, "gsspare", "দারুণ, {0} ক্যালরি বাকি!");
        p(bn, "gsover", "আজকের সীমা শেষ — সন্ধ্যায় হালকা খান! 🥗");
        p(bn, "tracknone", "এখনও অর্ডার নেই — ক্ষুধা? লিখুন \"show me biryani\" 🍛");
        p(bn, "tr_head", "সর্বশেষ অর্ডার <b>#{0}</b> — {1}<br>");
        p(bn, "tr_status", "অবস্থা: {0}<br>");
        p(bn, "tr_amt", "পরিমাণ: ₹{0}<br>");
        p(bn, "tr_time", "সময়: {0}");
        p(bn, "added", "<b>{0}</b> কার্টে যোগ হয়েছে 🛒✨");
        p(bn, "addfail", "\"{0}\" মেনুতে নেই 😕");
        p(bn, "addempty", "কোন খাবার যোগ করব? নাম বলুন 🛒");
        p(bn, "spots", "আপনার জন্য টপ জায়গা 🍴");
        p(bn, "spotsfor", "{0} এর জন্য বেস্ট জায়গা 🍴");
        p(bn, "fallback", "বুঝতে পারিনি 🤔 \"biryani\", \"pizza\", \"momos\" চেষ্টা করুন বা \"help\" লিখুন।");
        p(bn, "moodwet", "বাইরে {0} 🌧️ — গরম খাবার সুপার");
        p(bn, "moodhot", "বাইরে {0} ☀️ — ঠান্ডা হালকা খাবার ঠিক");
        p(bn, "moodok", "আবহাওয়া ভালো 🌤️ — এগুলো দেখুন");
        p(bn, "spleft", " • আজ <b>{0} ক্যালরি</b> বাকি:");
        p(bn, "splow", "আজকের ক্যালরি প্রায় শেষ 🔔 — সালাদ বা গ্রিন টি নিন (\"healthy food\" লিখুন)।");
        p(bn, "tryh", "<i>\"healthy food\" চেষ্টা করুন</i>");
        L.put("bn", bn);

        /* ===== GUJARATI ===== */
        Map<String, String> gu = new HashMap<>();
        p(gu, "greet", "નમસ્તે! હું <b>ટાપુ</b> 🍊 — તમારો ફૂડ બડી. વાનગીઓ, કેલરી પૂછો અથવા \"help\" લખો.");
        p(gu, "help", "હું ખોરાક શોધી શકું, કેલરી ગણી શકું, ઓર્ડર ટ્રેક કરી શકું! પ્રયાસ કરો:");
        p(gu, "found", "તમારા માટે આ મળ્યું 😍");
        p(gu, "look", "આ જુઓ 🍽️");
        p(gu, "choice", "શાનદાર પસંદ! 🔥");
        p(gu, "kitchen", "રસોડામાંથી તાજું 👨‍🍳");
        p(gu, "budget", "તમારા બજેટમાં આ 🪙");
        p(gu, "healthy", "હલકા તાજા વિકલ્પો, ઓછી કેલરી પહેલા 🥗");
        p(gu, "protein", "પ્રોટીન પાવર 💪 વધુ પ્રોટીન પહેલા:");
        p(gu, "nutri", "પોષણ માહિતી 📊");
        p(gu, "nothing", "<i>કંઈ મળ્યું નહીં 😕 બીજી વાનગી પ્રયાસ કરો</i>");
        p(gu, "goalset", "થઈ ગયું ✅ રોજનું લક્ષ્ય હવે <b>{0}</b> કેલરી!");
        p(gu, "goalnone", "લક્ષ્ય નથી — લખો <b>\"set my goal to 1800\"</b> 🎯");
        p(gu, "goallogin", "પહેલા લોગિન કરો, પછી કેલરી ગણીશ 🔐");
        p(gu, "goalstat", "🎯 <b>લક્ષ્ય: {0} કેલરી</b><br>ખાધું: {1}<br>બાકી: {2}<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(gu, "gsspare", "સરસ, {0} કેલરી બાકી!");
        p(gu, "gsover", "આજની મર્યાદા પૂરી — સાંજ હલકી રાખો! 🥗");
        p(gu, "tracknone", "હજુ ઓર્ડર નથી — ભૂખ લાગે? લખો \"show me biryani\" 🍛");
        p(gu, "tr_head", "તાજો ઓર્ડર <b>#{0}</b> — {1}<br>");
        p(gu, "tr_status", "સ્થિતિ: {0}<br>");
        p(gu, "tr_amt", "રકમ: ₹{0}<br>");
        p(gu, "tr_time", "સમય: {0}");
        p(gu, "added", "<b>{0}</b> કાર્ટમાં નાખ્યું 🛒✨");
        p(gu, "addfail", "\"{0}\" મેનૂમાં નથી 😕");
        p(gu, "addempty", "કઈ વાનગી નાખું? નામ કહો 🛒");
        p(gu, "spots", "તમારા માટે ટોપ જગ્યાઓ 🍴");
        p(gu, "spotsfor", "{0} માટે બેસ્ટ જગ્યાઓ 🍴");
        p(gu, "fallback", "સમજાયું નહીં 🤔 \"biryani\", \"pizza\", \"momos\" પ્રયાસ કરો અથવા \"help\" લખો.");
        p(gu, "moodwet", "બહાર {0} 🌧️ — ગરમ ખોરાક સરસ");
        p(gu, "moodhot", "બહાર {0} ☀️ — ઠંડુ હલકું ખાવાય");
        p(gu, "moodok", "મૌસમ સરસ 🌤️ — આ જુઓ");
        p(gu, "spleft", " • આજે <b>{0} કેલરી</b> બાકી:");
        p(gu, "splow", "આજની કેલરી લગભગ પૂરી 🔔 — સલાડ કે ગ્રીન ટી લો (\"healthy food\" લખો).");
        p(gu, "tryh", "<i>\"healthy food\" પ્રયાસ કરો</i>");
        L.put("gu", gu);

        /* ===== PUNJABI ===== */
        Map<String, String> pa = new HashMap<>();
        p(pa, "greet", "ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ <b>ਟਾਪੂ</b> 🍊 — ਤੁਹਾਡਾ ਫੂਡ ਬੱਡੀ। ਪਕਵਾਨ, ਕੈਲੋਰੀ ਪੁੱਛੋ ਜਾਂ \"help\" ਲਿਖੋ।");
        p(pa, "help", "ਮੈਂ ਖਾਣਾ ਲੱਭ ਸਕਦਾ, ਕੈਲੋਰੀ ਗਿਣ ਸਕਦਾ, ਆਰਡਰ ਟ੍ਰੈਕ ਕਰ ਸਕਦਾ! ਕੋਸ਼ਿਸ਼ ਕਰੋ:");
        p(pa, "found", "ਤੁਹਾਡੇ ਲਈ ਇਹ ਮਿਲੇ 😍");
        p(pa, "look", "ਇਹ ਵੇਖੋ 🍽️");
        p(pa, "choice", "ਸ਼ਾਨਦਾਰ ਚੋਣ! 🔥");
        p(pa, "kitchen", "ਰਸੋਈ ਤੋਂ ਤਾਜ਼ਾ 👨‍🍳");
        p(pa, "budget", "ਤੁਹਾਡੇ ਬਜਟ ਵਿੱਚ ਇਹ 🪙");
        p(pa, "healthy", "ਹਲਕੇ ਤਾਜ਼ੇ ਵਿਕਲਪ, ਘੱਟ ਕੈਲੋਰੀ ਪਹਿਲਾਂ 🥗");
        p(pa, "protein", "ਪ੍ਰੋਟੀਨ ਪਾਵਰ 💪 ਵੱਧ ਪ੍ਰੋਟੀਨ ਪਹਿਲਾਂ:");
        p(pa, "nutri", "ਪੋਸ਼ਣ ਜਾਣਕਾਰੀ 📊");
        p(pa, "nothing", "<i>ਕੁਝ ਨਹੀਂ ਮਿਲਿਆ 😕 ਹੋਰ ਪਕਵਾਨ ਵੇਖੋ</i>");
        p(pa, "goalset", "ਹੋ ਗਿਆ ✅ ਰੋਜ਼ਾਨਾ ਲਕੜ ਹੁਣ <b>{0}</b> ਕੈਲੋਰੀ!");
        p(pa, "goalnone", "ਲਕੜ ਨਹੀਂ — ਲਿਖੋ <b>\"set my goal to 1800\"</b> 🎯");
        p(pa, "goallogin", "ਪਹਿਲਾਂ ਲੌਗਿਨ ਕਰੋ, ਫਿਰ ਕੈਲੋਰੀ ਗਿਣਾਂਗਾ 🔐");
        p(pa, "goalstat", "🎯 <b>ਲਕੜ: {0} ਕੈਲੋਰੀ</b><br>ਖਾਧਾ: {1}<br>ਬਾਕੀ: {2}<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(pa, "gsspare", "ਵਧੀਆ, {0} ਕੈਲੋਰੀ ਬਾਕੀ!");
        p(pa, "gsover", "ਅੱਜ ਦੀ ਲਿਮਟ ਖਤਮ — ਸ਼ਾਮ ਹਲਕੀ ਰੱਖੋ! 🥗");
        p(pa, "tracknone", "ਹਾਲੇ ਆਰਡਰ ਨਹੀਂ — ਭੁੱਖ ਲੱਗੀ? ਲਿਖੋ \"show me biryani\" 🍛");
        p(pa, "tr_head", "ਤਾਜ਼ਾ ਆਰਡਰ <b>#{0}</b> — {1}<br>");
        p(pa, "tr_status", "ਸਥਿਤੀ: {0}<br>");
        p(pa, "tr_amt", "ਰਕਮ: ₹{0}<br>");
        p(pa, "tr_time", "ਸਮਾਂ: {0}");
        p(pa, "added", "<b>{0}</b> ਕਾਰਟ ਵਿੱਚ ਪਾ ਦਿੱਤਾ 🛒✨");
        p(pa, "addfail", "\"{0}\" ਮੀਨੂ ਵਿੱਚ ਨਹੀਂ 😕");
        p(pa, "addempty", "ਕਿਹੜਾ ਪਕਵਾਨ ਪਾਵਾਂ? ਨਾਮ ਦੱਸੋ 🛒");
        p(pa, "spots", "ਤੁਹਾਡੇ ਲਈ ਟਾਪ ਥਾਵਾਂ 🍴");
        p(pa, "spotsfor", "{0} ਲਈ ਬੈਸਟ ਥਾਵਾਂ 🍴");
        p(pa, "fallback", "ਸਮਝ ਨਹੀਂ ਆਇਆ 🤔 \"biryani\", \"pizza\", \"momos\" ਵੇਖੋ ਜਾਂ \"help\" ਲਿਖੋ।");
        p(pa, "moodwet", "ਬਾਹਰ {0} 🌧️ — ਗਰਮ ਖਾਣਾ ਸ਼ਾਨਦਾਰ");
        p(pa, "moodhot", "ਬਾਹਰ {0} ☀️ — ਠੰਡਾ ਹਲਕਾ ਖਾਣਾ ਠੀਕ");
        p(pa, "moodok", "ਮੌਸਮ ਵਧੀਆ 🌤️ — ਇਹ ਵੇਖੋ");
        p(pa, "spleft", " • ਅੱਜ <b>{0} ਕੈਲੋਰੀ</b> ਬਾਕੀ:");
        p(pa, "splow", "ਅੱਜ ਦੀਆਂ ਕੈਲੋਰੀ ਲਗਭਗ ਖਤਮ 🔔 — ਸਲਾਦ ਜਾਂ ਗ੍ਰੀਨ ਟੀ ਲਵੋ (\"healthy food\" ਲਿਖੋ)।");
        p(pa, "tryh", "<i>\"healthy food\" ਵੇਖੋ</i>");
        L.put("pa", pa);

        /* ===== MALAYALAM ===== */
        Map<String, String> ml = new HashMap<>();
        p(ml, "greet", "നമസ്കാരം! ഞാൻ <b>ടാപ്പു</b> 🍊 — നിങ്ങളുടെ ഫുഡ് ബഡ്ഡി. വിഭവങ്ങൾ, കലോറി ചോദിക്കൂ അല്ലെങ്കിൽ \"help\" എഴുതൂ.");
        p(ml, "help", "ഭക്ഷണം കണ്ടെത്താം, കലോറി കണക്കാക്കാം, ഓർഡർ ട്രാക്ക് ചെയ്യാം! ശ്രമിക്കൂ:");
        p(ml, "found", "നിങ്ങൾക്കായി ഇവ കിട്ടി 😍");
        p(ml, "look", "ഇവ നോക്കൂ 🍽️");
        p(ml, "choice", "സൂപ്പർ ചോയ്സ്! 🔥");
        p(ml, "kitchen", "അടുക്കളയിൽ നിന്ന് പുതിയത് 👨‍🍳");
        p(ml, "budget", "നിങ്ങളുടെ ബജറ്റിൽ ഇവ 🪙");
        p(ml, "healthy", "ഭാരം കുറഞ്ഞ തിരഞ്ഞെടുപ്പുകൾ, കുറഞ്ഞ കലോറി ആദ്യം 🥗");
        p(ml, "protein", "പ്രോട്ടീൻ പവർ 💪 കൂടുതൽ പ്രോട്ടീൻ ആദ്യം:");
        p(ml, "nutri", "പോഷക വിവരം 📊");
        p(ml, "nothing", "<i>ഒന്നും കിട്ടിയില്ല 😕 മറ്റൊരു വിഭവം ശ്രമിക്കൂ</i>");
        p(ml, "goalset", "കഴിഞ്ഞു ✅ ദിവസ ലക്ഷ്യം ഇപ്പോൾ <b>{0}</b> കലോറി!");
        p(ml, "goalnone", "ലക്ഷ്യമില്ല — എഴുതൂ <b>\"set my goal to 1800\"</b> 🎯");
        p(ml, "goallogin", "ആദ്യം ലോഗിൻ ചെയ്യൂ, പിന്നെ കലോറി കണക്കാക്കാം 🔐");
        p(ml, "goalstat", "🎯 <b>ലക്ഷ്യം: {0} കലോറി</b><br>കഴിച്ചത്: {1}<br>ബാക്കി: {2}<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(ml, "gsspare", "സൂപ്പർ, {0} കലോറി ബാക്കി!");
        p(ml, "gsover", "ഇന്നത്തെ ലിമിറ്റ് കഴിഞ്ഞു — ഇന്ന് രാത്രി ഭാരം കുറച്ച് തിന്നൂ! 🥗");
        p(ml, "tracknone", "ഇതുവരെ ഓർഡർ ഇല്ല — വിശപ്പോ? എഴുതൂ \"show me biryani\" 🍛");
        p(ml, "tr_head", "ഏറ്റവും പുതിയ ഓർഡർ <b>#{0}</b> — {1}<br>");
        p(ml, "tr_status", "നില: {0}<br>");
        p(ml, "tr_amt", "തുക: ₹{0}<br>");
        p(ml, "tr_time", "സമയം: {0}");
        p(ml, "added", "<b>{0}</b> കാർട്ടിൽ ചേർത്തു 🛒✨");
        p(ml, "addfail", "\"{0}\" മെനുവിൽ ഇല്ല 😕");
        p(ml, "addempty", "ഏത് വിഭവം ചേർക്കണം? പേര് പറയൂ 🛒");
        p(ml, "spots", "നിങ്ങൾക്കുള്ള ടോപ്പ് സ്ഥലങ്ങൾ 🍴");
        p(ml, "spotsfor", "{0} ന് ബെസ്റ്റ് സ്ഥലങ്ങൾ 🍴");
        p(ml, "fallback", "മനസ്സിലായില്ല 🤔 \"biryani\", \"pizza\", \"momos\" ശ്രമിക്കൂ അല്ലെങ്കിൽ \"help\" എഴുതൂ.");
        p(ml, "moodwet", "പുറത്ത് {0} 🌧️ — ചൂടുള്ള ഭക്ഷണം സൂപ്പർ");
        p(ml, "moodhot", "പുറത്ത് {0} ☀️ — തണുത്ത ലഘു ഭക്ഷണം നല്ലത്");
        p(ml, "moodok", "കാലാവസ്ഥ സുഖകരം 🌤️ — ഇവ നോക്കൂ");
        p(ml, "spleft", " • ഇന്ന് <b>{0} കലോറി</b> ബാക്കി:");
        p(ml, "splow", "ഇന്നത്തെ കലോറി ഏകദേശം കഴിഞ്ഞു 🔔 — സലാഡ് അല്ലെങ്കിൽ ഗ്രീൻ ടീ എടുക്കൂ (\"healthy food\" എഴുതൂ).");
        p(ml, "tryh", "<i>\"healthy food\" ശ്രമിക്കൂ</i>");
        L.put("ml", ml);

        /* ===== URDU ===== */
        Map<String, String> ur = new HashMap<>();
        p(ur, "greet", "سلام! میں <b>ٹاپو</b> 🍊 ہوں — آپ کا فوڈ بدی。 ڈشز، کیلوریز پوچھیں یا \"help\" لکھیں۔");
        p(ur, "help", "میں کھانا ڈھونڈ سکتا ہوں، کیلوریز گن سکتا ہوں، آرڈر ٹریک کر سکتا ہوں! آزمائیں:");
        p(ur, "found", "آپ کے لیے یہ ملے 😍");
        p(ur, "look", "یہ دیکھیں 🍽️");
        p(ur, "choice", "زبردست انتخاب! 🔥");
        p(ur, "kitchen", "باورچی خانے سے تازہ 👨‍🍳");
        p(ur, "budget", "آپ کے بجٹ میں یہ 🪙");
        p(ur, "healthy", "ہلکے تازہ آپشن، کم کیلوریز پہلے 🥗");
        p(ur, "protein", "پروٹین پاور 💪 زیادہ پروٹین پہلے:");
        p(ur, "nutri", "غذائیت کی معلومات 📊");
        p(ur, "nothing", "<i>کچھ نہیں ملا 😕 دوسری ڈش آزمائیں</i>");
        p(ur, "goalset", "ہو گیا ✅ روزانہ کا ہدف اب <b>{0}</b> کیلوریز ہے!");
        p(ur, "goalnone", "ہدف نہیں — لکھیں <b>\"set my goal to 1800\"</b> 🎯");
        p(ur, "goallogin", "پہلے لاگ اِن کریں، پھر کیلوریز گنیں گے 🔐");
        p(ur, "goalstat", "🎯 <b>ہدف: {0} کیلوریز</b><br>کھایا: {1}<br>باقی: {2}<div class='fta-bar'><div class='fta-fill' style='width:{3}%'></div></div>");
        p(ur, "gsspare", "شاباش، {0} کیلوریز باقی!");
        p(ur, "gsover", "آج کی حد ختم — شام ہلکی رکھیں! 🥗");
        p(ur, "tracknone", "ابھی کوئی آرڈر نہیں — بھوک لگی؟ لکھیں \"show me biryani\" 🍛");
        p(ur, "tr_head", "تازہ ترین آرڈر <b>#{0}</b> — {1}<br>");
        p(ur, "tr_status", "حالت: {0}<br>");
        p(ur, "tr_amt", "رقم: ₹{0}<br>");
        p(ur, "tr_time", "وقت: {0}");
        p(ur, "added", "<b>{0}</b> کارٹ میں ڈال دیا 🛒✨");
        p(ur, "addfail", "\"{0}\" مینو میں نہیں 😕");
        p(ur, "addempty", "کون سی ڈش ڈالوں؟ نام بتائیں 🛒");
        p(ur, "spots", "آپ کے لیے ٹاپ جگہیں 🍴");
        p(ur, "spotsfor", "{0} کے لیے بہترین جگہیں 🍴");
        p(ur, "fallback", "سمجھ نہیں آیا 🤔 \"biryani\", \"pizza\", \"momos\" آزمائیں یا \"help\" لکھیں۔");
        p(ur, "moodwet", "باہر {0} 🌧️ — گرم کھانا بہترین");
        p(ur, "moodhot", "باہر {0} ☀️ — ٹھنڈا ہلکا کھانا ٹھیک");
        p(ur, "moodok", "موسم خوشگوار 🌤️ — یہ دیکھیں");
        p(ur, "spleft", " • آج <b>{0} کیلوریز</b> باقی:");
        p(ur, "splow", "آج کی کیلوریز تقریباً ختم 🔔 — سلاد یا گرین ٹی لیں (\"healthy food\" لکھیں)۔");
        p(ur, "tryh", "<i>\"healthy food\" آزمائیں</i>");
        L.put("ur", ur);
    }

    /* native dish words -> English keywords */
    private static final String[][] DISHWORDS = {
        {"बिरयानी","biryani"},{"पिज़्ज़ा","pizza"},{"पिज़्जा","pizza"},{"मोमो","momos"},{"डोसा","dosa"},
        {"सलाद","salad"},{"सूप","soup"},{"कॉफ़ी","coffee"},{"कॉफी","coffee"},{"चाय","tea"},
        {"ಬಿರಿಯಾನಿ","biryani"},{"ಪಿಜ್ಜಾ","pizza"},{"ಮೋಮೋ","momos"},{"ದೋಸೆ","dosa"},{"ಸಲಾಡ್","salad"},{"ಸೂಪ್","soup"},{"ಕಾಫಿ","coffee"},
        {"బిరియానీ","biryani"},{"పిజ్జా","pizza"},{"మోమో","momos"},{"దోస","dosa"},{"సలాడ్","salad"},{"సూప్","soup"},{"కాఫీ","coffee"},
        {"பிரியாணி","biryani"},{"பீட்சா","pizza"},{"மோமோ","momos"},{"தோசை","dosa"},{"சாலட்","salad"},{"சூப்","soup"},{"காபி","coffee"},
        {"বিরিয়ানি","biryani"},{"পিৎজা","pizza"},{"মোমো","momos"},{"সালাদ","salad"},{"স্যুপ","soup"},
        {"બિરયાની","biryani"},{"પિઝા","pizza"},{"સલાડ","salad"},{"સૂપ","soup"},
        {"ਬਿਰਿਆਨੀ","biryani"},{"ਪਿੱਜ਼ਾ","pizza"},{"ਸਲਾਦ","salad"},{"ਸੂਪ","soup"},
        {"ബിരിയാണി","biryani"},{"പിസ്സ","pizza"},{"മോമോ","momos"},{"സലാഡ്","salad"},{"സൂപ്പ്","soup"},
        {"بریانی","biryani"},{"پیزا","pizza"},{"مومو","momos"},{"چائے","tea"} };

    /* ============================ HTTP ============================ */

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String msg = nz(req.getParameter("message")).toLowerCase().trim();
        String weather = nz(req.getParameter("weather"));
        String lg = normLang(req.getParameter("lang"));

        /* SIRI MAGIC: reply in whatever script the user typed in */
        if (P_DEV.matcher(msg).find())  lg = "hi";
        if (P_BENG.matcher(msg).find()) lg = "bn";
        if (P_GURU.matcher(msg).find()) lg = "pa";
        if (P_GUJ.matcher(msg).find())  lg = "gu";
        if (P_URDU.matcher(msg).find()) lg = "ur";
        if (P_TAML.matcher(msg).find()) lg = "ta";
        if (P_TELU.matcher(msg).find()) lg = "te";
        if (P_KNDA.matcher(msg).find()) lg = "kn";
        if (P_MLM.matcher(msg).find())  lg = "ml";

        /* understand native dish words regardless of language */
        for (String[] d : DISHWORDS) {
            if (msg.contains(d[0])) msg = msg.replace(d[0], " " + d[1] + " ");
        }
        /* Hinglish / Marathi-English mix support */
        msg = msg.replaceAll("\\b(dikhao|dikha do|dikha|dakho|dekhao|batavo|bata)\\b", "show")
                 .replaceAll("\\b(sasta|sasti|sasta mal)\\b", "cheap")
                 .replaceAll("\\b(khana|khaana|khaadya)\\b", "food")
                 .replaceAll("\\b(bhookh|bhook|kshudha)\\b", "hungry");

        int userId = resolveUserId(req);

        String reply, html = "", action = "", url = "";
        int menuId = 0;

        try (Connection c = com.foodtap.util.DBConnection.getConnection()) {
            String[] r = brain(c, msg, userId, weather, lg);
            reply = r[0]; html = r[1];
            if (reply.startsWith("ADDCART:")) {
                String[] pa2 = reply.split(":", 3);
                action = "addCart"; menuId = Integer.parseInt(pa2[1]); reply = pa2[2];
            } else if (reply.startsWith("NAV:")) {
                String[] pa2 = reply.split(":", 3);
                action = "navigate"; url = pa2[1]; reply = pa2[2];
            }
        } catch (Exception e) {
            e.printStackTrace();
            reply = "My brain is offline 😅 (DB problem). Please try again.";
        }

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter w = resp.getWriter();
        w.print("{\"reply\":\"" + jesc(reply) + "\",\"html\":\"" + jesc(html)
              + "\",\"action\":\"" + action + "\",\"url\":\"" + url
              + "\",\"menuId\":" + menuId + "}");
        w.flush();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException { doPost(req, resp); }

    private int resolveUserId(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return 0;
        Object u = s.getAttribute("loggedInUser");
        if (u instanceof com.foodtap.model.User) return ((com.foodtap.model.User) u).getUserId();
        return 0;
    }

    /* ============================ BRAIN ============================ */

    private String[] brain(Connection c, String m, int userId, String weather, String lg) throws SQLException {

        if (m.equals("__welcome__") || m.isEmpty()) return new String[]{ t(lg, "greet"), "" };

        if (m.length() <= 30 && m.matches(".*\\b(hi+|hello|hey|namaste|namaskara|namaskaram|vanakkam|namaskar|sat sri akal|good (morning|afternoon|evening))\\b.*"))
            return new String[]{ t(lg, "greet"), "" };

        if (m.matches(".*(help|what can you do|commands|options|features).*"))
            return new String[]{ t(lg, "help"), chipsHtml() };

        if (m.matches(".*(set|change|update).*(goal|target).*") || (m.contains("goal") && m.matches(".*(\\d{3,5}).*"))) {
            Matcher mm = Pattern.compile("(\\d{3,5})").matcher(m);
            if (mm.find()) return new String[]{ setGoal(c, userId, Integer.parseInt(mm.group(1)), lg), "" };
        }

        Matcher nut = Pattern.compile("(calories|calorie|protein|carbs|carbohydrates|fiber|fibre|nutrition)\\s*(in|of|for|value)?\\s*(.+)").matcher(m);
        if (nut.find()) {
            String[] r = nutrition(c, nut.group(3), lg);
            if (r != null) return r;
        }

        if (m.matches(".*(goal|target|consumed|remaining|calories left).*")) {
            String g = goalStatus(c, userId, lg);
            if (g != null) return new String[]{ g, "" };
        }

        if (m.matches(".*(track|status|where).*(order).*") || m.matches(".*\\b(order status|my order)\\b.*"))
            return new String[]{ trackOrder(c, userId, lg), "" };

        if (m.matches(".*(add|put).*(cart|order).*")) {
            String item = m.replaceFirst(".*(add|put)", "").replaceFirst("(to|in|my)?\\s*(cart|order).*", "").trim();
            return new String[]{ findAndAdd(c, item, lg), "" };
        }

        if (m.matches(".*(open|show|go to|take me).*(cart|home|orders?|menu|health).*")) {
            if (m.contains("cart"))   return new String[]{ "NAV:cart:🛒", "" };
            if (m.contains("order"))  return new String[]{ "NAV:orders:📦", "" };
            if (m.contains("health")) return new String[]{ "NAV:health:🎯", "" };
            if (m.contains("menu"))   return new String[]{ "NAV:menu:🍽️", "" };
            if (m.contains("home"))   return new String[]{ "NAV:home.jsp:🏠", "" };
        }

        int budget = -1;
        Matcher price = Pattern.compile("(?:under|below|less than|cheaper than|within)\\s*₹?\\s*(\\d{2,5})").matcher(m);
        if (price.find()) budget = Integer.parseInt(price.group(1));
        else if (m.matches(".*(budget|cheap|affordable).*")) {
            Matcher n2 = Pattern.compile("(\\d{2,5})").matcher(m);
            if (n2.find()) budget = Integer.parseInt(n2.group(1));
        }
        if (budget > 0)
            return new String[]{ t(lg, "budget"),
                itemsHtml(c, "m.price <= " + budget + " AND m.isAvailable='1'", "m.price ASC", 6, lg) };

        if (m.matches(".*(healthy|light|low cal|diet|salad|fit).*"))
            return new String[]{ t(lg, "healthy"),
                itemsHtml(c, "m.isAvailable='1'", "n.calories ASC", 5, lg) };
        if (m.matches(".*(protein|muscle|gym|bulk).*"))
            return new String[]{ t(lg, "protein"),
                itemsHtml(c, "m.isAvailable='1'", "n.protein DESC", 5, lg) };

        if (m.matches(".*(suggest|what should i eat|what to eat|recommend me|decide for me|confused).*"))
            return new String[]{ smartPick(c, userId, weather, lg), "" };

        String[] CUISINES = {"punjabi","kerala","andhra","coastal","seafood","rajasthani","mughlai","maharashtrian",
                             "hyderabadi","karnataka","continental","grill","bbq","tandoori","north indian",
                             "south indian","chinese","italian","cafe"};
        for (String cui : CUISINES) {
            if (m.contains(cui)) {
                String h = restaurantsHtml(c, cui);
                if (!h.isEmpty()) return new String[]{ fmt(t(lg, "spotsfor"), cui), h };
            }
        }
        if (m.matches(".*(restaurant|places?|where to eat|dine).*")) {
            String h = restaurantsHtml(c, stripFluff(m));
            if (!h.isEmpty()) return new String[]{ t(lg, "spots"), h };
        }

        String[] cat = categoryHit(m);
        if (cat != null)
            return new String[]{ pick(t(lg, "choice"), t(lg, "kitchen")),
                itemsHtml(c, "(m.category LIKE '" + escSql(cat[1]) + "%' OR m.name LIKE '%" + escSql(cat[1]) + "%') AND m.isAvailable='1'", "m.price ASC", 6, lg) };

        String[] r = searchItems(c, stripFluff(m), lg);
        if (r != null) return r;

        return new String[]{ t(lg, "fallback"), "" };
    }

    /* ============================ QUERIES ============================ */

    private String itemsHtml(Connection c, String where, String order, int limit, String lg) throws SQLException {
        StringBuilder sb = new StringBuilder();
        String sql = "SELECT m.menuId, m.name, m.price, m.imagePath, r.name AS rname, n.calories "
                   + "FROM menu m JOIN restaurant r ON m.restaurantId=r.restaurantId "
                   + "LEFT JOIN foodnutrition n ON n.menuId=m.menuId WHERE " + where + " ORDER BY " + order + " LIMIT " + limit;
        try (Statement st = c.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            int n = 0;
            while (rs.next()) {
                Double cal = rs.getObject(6) == null ? null : rs.getDouble(6);
                sb.append(itemCard(rs.getInt(1), rs.getString(2), rs.getString(5), rs.getDouble(3), cal, rs.getString(4)));
                n++;
            }
            if (n == 0) return t(lg, "nothing");
        }
        return sb.toString();
    }

    private String[] searchItems(Connection c, String q, String lg) throws SQLException {
        q = q.replaceAll("[^a-z0-9 ]", " ").trim();
        if (q.length() < 3) return null;
        String sql = "SELECT m.menuId, m.name, m.price, m.imagePath, r.name, n.calories FROM menu m "
                   + "JOIN restaurant r ON m.restaurantId=r.restaurantId LEFT JOIN foodnutrition n ON n.menuId=m.menuId "
                   + "WHERE (m.name LIKE ? OR m.description LIKE ? OR m.category LIKE ?) AND m.isAvailable='1' LIMIT 6";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            String like = "%" + q + "%";
            ps.setString(1, like); ps.setString(2, like); ps.setString(3, like);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                StringBuilder sb = new StringBuilder();
                do {
                    Double cal = rs.getObject(6) == null ? null : rs.getDouble(6);
                    sb.append(itemCard(rs.getInt(1), rs.getString(2), rs.getString(5), rs.getDouble(3), cal, rs.getString(4)));
                } while (rs.next());
                return new String[]{ pick(t(lg, "found"), t(lg, "look")), sb.toString() };
            }
        }
    }

    private String[] nutrition(Connection c, String item, String lg) throws SQLException {
        String like = "%" + item.replaceAll("[?.!]", "").trim() + "%";
        String sql = "SELECT m.name, n.calories, n.protein, n.carbs, n.fiber FROM menu m "
                   + "JOIN foodnutrition n ON n.menuId=m.menuId WHERE m.name LIKE ? LIMIT 3";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, like);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                StringBuilder sb = new StringBuilder();
                do {
                    sb.append("<div class='fta-i' style='display:block;padding:6px 0'><b>").append(aesc(rs.getString(1)))
                      .append("</b><span>🔥 ").append(rs.getDouble(2)).append(" kcal • 🥩 ").append(rs.getDouble(3))
                      .append("g • 🍞 ").append(rs.getDouble(4)).append("g • 🌾 ").append(rs.getDouble(5))
                      .append("g</span></div>");
                } while (rs.next());
                return new String[]{ t(lg, "nutri"), sb.toString() };
            }
        }
    }

    private String goalStatus(Connection c, int userId, String lg) throws SQLException {
        if (userId == 0) return t(lg, "goallogin");
        try (PreparedStatement ps = c.prepareStatement("SELECT dailyCalorieGoal, caloriesConsumed FROM healthgoal WHERE userId=?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return t(lg, "goalnone");
                double goal = rs.getDouble(1), used = rs.getDouble(2);
                int pct = goal > 0 ? (int) Math.min(100, Math.round(used / goal * 100)) : 0;
                double left = Math.max(0, goal - used);
                String out = fmt(t(lg, "goalstat"), (int) goal, (int) used, (int) left, pct);
                out += left <= 0 ? " " + t(lg, "gsover") : " " + fmt(t(lg, "gsspare"), (int) left);
                return out;
            }
        }
    }

    private String setGoal(Connection c, int userId, int goal, String lg) throws SQLException {
        if (userId == 0) return t(lg, "goallogin");
        try (PreparedStatement ps = c.prepareStatement("SELECT healthGoalId FROM healthgoal WHERE userId=?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) exec(c, "UPDATE healthgoal SET dailyCalorieGoal=" + goal + " WHERE userId=" + userId);
                else exec(c, "INSERT INTO healthgoal (userId, dailyCalorieGoal, caloriesConsumed) VALUES (" + userId + "," + goal + ",0)");
            }
        }
        return fmt(t(lg, "goalset"), goal);
    }

    private String trackOrder(Connection c, int userId, String lg) throws SQLException {
        if (userId == 0) return t(lg, "goallogin");
        String sql = "SELECT o.orderId, o.status, o.totalAmount, o.orderDate, r.name FROM orders o "
                   + "JOIN restaurant r ON o.restaurantId=r.restaurantId WHERE o.userId=? ORDER BY o.orderDate DESC LIMIT 1";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return t(lg, "tracknone");
                String st = rs.getString(2) == null ? "" : rs.getString(2).toLowerCase();
                String emoji = st.contains("deliver") ? "✅" : st.contains("transit") || st.contains("way") ? "🛵"
                             : st.contains("prepar") || st.contains("cooking") ? "👨‍🍳" : "📦";
                return fmt(t(lg, "tr_head"), rs.getInt(1), aesc(rs.getString(5)))
                     + fmt(t(lg, "tr_status"), emoji + " " + aesc(rs.getString(2)))
                     + fmt(t(lg, "tr_amt"), (int) rs.getDouble(3))
                     + fmt(t(lg, "tr_time"), rs.getTimestamp(4));
            }
        }
    }

    private String findAndAdd(Connection c, String item, String lg) throws SQLException {
        if (item.isEmpty()) return t(lg, "addempty");
        try (PreparedStatement ps = c.prepareStatement("SELECT menuId, name FROM menu WHERE name LIKE ? AND isAvailable='1' LIMIT 1")) {
            ps.setString(1, "%" + escSql(item) + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return fmt(t(lg, "addfail"), aesc(item));
                return "ADDCART:" + rs.getInt(1) + ":" + fmt(t(lg, "added"), aesc(rs.getString(2)));
            }
        }
    }

    private String restaurantsHtml(Connection c, String word) throws SQLException {
        StringBuilder sb = new StringBuilder();
        String where = (word == null || word.isEmpty()) ? "isActive='Yes'"
                     : "(name LIKE '%" + escSql(word) + "%' OR cuisineType LIKE '%" + escSql(word) + "%')";
        String sql = "SELECT restaurantId, name, cuisineType, rating, deliveryTime FROM restaurant WHERE " + where
                   + " ORDER BY rating DESC LIMIT 6";
        try (Statement st = c.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            int n = 0;
            while (rs.next()) {
                sb.append("<div class='fta-item'><div class='fta-i' style='display:block'><b>").append(aesc(rs.getString(2)))
                  .append("</b><span>").append(aesc(rs.getString(3))).append(" • ⭐ ").append(rs.getFloat(4))
                  .append(" • 🛵 ").append(rs.getInt(5)).append(" min</span></div>")
                  .append("<a class='fta-add' href='menu?restaurantId=").append(rs.getInt(1)).append("'>➜</a></div>");
                n++;
            }
            if (n == 0) return "";
        }
        return sb.toString();
    }

    private String smartPick(Connection c, int userId, String weather, String lg) throws SQLException {
        double remaining = 1500;
        try (PreparedStatement ps = c.prepareStatement(
                "SELECT COALESCE(SUM(fn.calories*oi.quantity),0) FROM orders o "
              + "JOIN orderitem oi ON o.orderId=oi.orderId JOIN foodnutrition fn ON oi.menuId=fn.menuId "
              + "WHERE o.userId=? AND DATE(o.orderDate)=CURDATE() AND (o.status IS NULL OR o.status<>'CANCELLED')")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                double goal = 1500;
                try (PreparedStatement g = c.prepareStatement("SELECT dailyCalorieGoal FROM healthgoal WHERE userId=?")) {
                    g.setInt(1, userId);
                    ResultSet gr = g.executeQuery();
                    if (gr.next() && gr.getDouble(1) > 0) goal = gr.getDouble(1);
                }
                remaining = goal - rs.getDouble(1);
            }
        }
        if (remaining < 120) return t(lg, "splow");

        String w = (weather == null) ? "" : weather.toLowerCase();
        boolean hot = w.contains("clear") || w.contains("sun") || w.contains("warm");
        boolean wet = w.contains("rain") || w.contains("fog") || w.contains("cloud") || w.contains("storm");
        String cats = wet ? "('Soup','Biryani','South Indian','Tea')"
                  : hot ? "('Beverage','Healthy','Dessert','Coffee')"
                        : "('Biryani','North Indian','Momos','Wraps')";
        String mood = wet ? fmt(t(lg, "moodwet"), weather)
                  : hot ? fmt(t(lg, "moodhot"), weather)
                        : t(lg, "moodok");

        String sql = "SELECT m.menuId, m.name, m.price, m.imagePath, r.name, n.calories FROM menu m "
               + "JOIN restaurant r ON m.restaurantId=r.restaurantId JOIN foodnutrition n ON n.menuId=m.menuId "
               + "WHERE m.category IN " + cats + " AND n.calories <= " + (int) remaining + " AND m.isAvailable='1' "
               + "ORDER BY n.calories DESC LIMIT 5";
        StringBuilder sb = new StringBuilder();
        try (Statement st = c.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next())
                sb.append(itemCard(rs.getInt(1), rs.getString(2), rs.getString(5), rs.getDouble(3),
                        rs.getObject(6) == null ? null : rs.getDouble(6), rs.getString(4)));
        }
        return mood + fmt(t(lg, "spleft"), (int) remaining)
             + (sb.length() == 0 ? t(lg, "tryh") : sb.toString());
    }

    /* ============================ HELPERS ============================ */

    private static final String[][] CATS = {
        {"biryani","Biryani"},{"dosa","Dosa"},{"pizza","Pizza"},{"pasta","Pasta"},{"burger","Burger"},
        {"momos","Momos"},{"soup","Soup"},{"chai","Tea"},{"tea","Tea"},{"coffee","Coffee"},
        {"dessert","Dessert"},{"sweet","Dessert"},{"salad","Healthy"},{"fries","Fries"},
        {"wrap","Wraps"},{"shawarma","Wraps"},{"breakfast","Breakfast"},{"pancake","Breakfast"},
        {"paratha","Breakfast"},{"idli","South Indian"},{"vada","South Indian"},
        {"chicken","Chicken"},{"paneer","Paneer"},{"fish","Seafood"},{"prawn","Seafood"},{"mutton","Mutton"} };

    private String[] categoryHit(String m) {
        for (String[] p : CATS) if (m.contains(p[0])) return p;
        return null;
    }

    private String itemCard(int id, String name, String rname, double price, Double cal, String img) {
        return "<div class='fta-item'><img src='" + aesc(img) + "' onerror=\"this.style.display='none'\"><div class='fta-i'><b>"
             + aesc(name) + "</b><span>" + aesc(rname) + " • ₹" + (int) price
             + (cal != null ? " • " + Math.round(cal) + " kcal" : "")
             + "</span></div><button class='fta-add' data-id='" + id + "' title='Add to cart'>+</button></div>";
    }

    private String chipsHtml() {
        String[] chips = {"Show me biryani","Healthy food","Under ₹150","Protein rich food",
            "Calories in chicken biryani","My calorie goal","Set my goal to 2000",
            "Track my order","Chinese restaurants","Add paneer momos to cart","Open cart"};
        StringBuilder sb = new StringBuilder();
        for (String s : chips)
            sb.append("<div class='fta-item' style='justify-content:center'><span style='color:#ffd9b8;font-size:12px'>")
              .append(aesc(s)).append("</span></div>");
        return sb.toString();
    }

    private String stripFluff(String m) {
        return m.replaceAll("\\b(show|me|find|some|want|i|the|a|an|for|food|eat|best|good|nice|suggest|recommendation|recommendations|nearby|near|any|please|restaurant|restaurants|places?|list|top|give|get|order|hungry|dine|where|to)\\b", " ")
                .replaceAll("\\s+", " ").trim();
    }

    private String pick(String a, String b) { return RND.nextBoolean() ? a : b; }
    private String nz(String s) { return s == null ? "" : s; }
    private String normLang(String s) {
        if (s == null) return "en";
        s = s.trim().toLowerCase();
        return (s.equals("hi")||s.equals("kn")||s.equals("te")||s.equals("ta")||s.equals("mr")||s.equals("bn")
              ||s.equals("gu")||s.equals("pa")||s.equals("ml")||s.equals("ur")) ? s : "en";
    }
    private String t(String lg, String key) {
        Map<String, String> d = L.get(lg);
        if (d != null) { String v = d.get(key); if (v != null) return v; }
        String v = EN.get(key);
        return v != null ? v : key;
    }
    private String fmt(String s, Object... a) {
        for (int i = 0; i < a.length; i++) s = s.replace("{" + i + "}", String.valueOf(a[i]));
        return s;
    }
    private String aesc(String s) { if (s == null) return ""; return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); }
    private String escSql(String s) { return s == null ? "" : s.replace("'", "''"); }
    private String jesc(String s) { if (s == null) return ""; return s.replace("\\","\\\\").replace("\"","\\\"").replace("\r","").replace("\n"," ").replace("\t"," "); }
    private void exec(Connection c, String sql) throws SQLException { try (Statement st = c.createStatement()) { st.executeUpdate(sql); } }
}