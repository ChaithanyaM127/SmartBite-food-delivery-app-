<%-- ============================================================
     SMARTBITE ORANGE UNIVERSAL BACKGROUND (Modernized UI)
     Include after <body> on EVERY page:
        <%@ include file="animated-bg.jsp" %>
     Video pages add BEFORE the include:
        <% request.setAttribute("ftBgVideo","videos/food-bg.mp4"); %>
     ============================================================ --%>
<%
String ftBgV = (String) request.getAttribute("ftBgVideo");
boolean ftHasVideo = (ftBgV != null && !ftBgV.trim().isEmpty());
%>
<style>
/* 1) Reset old page backgrounds */
body {
    background: #0d0d0f !important;
    background-image: none !important;
    background-attachment: scroll !important;
}
body::before, body::after {
    content: none !important;
    display: none !important;
}
.video-container, .background, .background-video, .background-overlay,
.orange-overlay, .overlay, .overlay-bottom {
    display: none !important;
}

/* 2) Video layer (opt-in pages only) */
#ftbg-v {
    position: fixed;
    inset: 0;
    z-index: -6;
    display: none;
    background: #0d0d0f;
}
<% if (ftHasVideo) { %>
#ftbg-v { display: block; }
<% } %>
#ftbg-v video {
    width: 100%;
    height: 100%;
    object-fit: cover;
    opacity: 0.25;
    filter: saturate(1.15) contrast(1.05);
}
#ftbg-veil {
    position: absolute;
    inset: 0;
    background: linear-gradient(180deg, rgba(13, 13, 15, 0.65), rgba(13, 13, 15, 0.45) 40%, rgba(13, 13, 15, 0.95)),
                radial-gradient(1200px 700px at 75% -5%, rgba(226, 55, 68, 0.15), transparent 60%);
}

/* 3) Modern Glowing Ambient Blooms */
#ftbg-bloom {
    position: fixed;
    width: 520px;
    height: 520px;
    border-radius: 50%;
    pointer-events: none;
    z-index: -5;
    background: radial-gradient(circle, rgba(226, 55, 68, 0.22), transparent 70%);
    filter: blur(80px);
    top: -150px;
    right: -120px;
    animation: ftbg-bl 20s ease-in-out infinite alternate;
}
#ftbg-bloom2 {
    position: fixed;
    width: 460px;
    height: 460px;
    border-radius: 50%;
    pointer-events: none;
    z-index: -5;
    background: radial-gradient(circle, rgba(255, 107, 0, 0.18), transparent 70%);
    filter: blur(90px);
    bottom: -140px;
    left: -100px;
    animation: ftbg-bl 25s ease-in-out infinite alternate-reverse;
}
@keyframes ftbg-bl {
    from { transform: translate(0, 0) scale(1); }
    to { transform: translate(-60px, 50px) scale(1.12); }
}

/* 4) Floating Food Elements (Refined shadow & smoothness) */
.ffood {
    position: fixed;
    bottom: -140px;
    pointer-events: none;
    z-index: -4;
    border-radius: 50%;
    object-fit: cover;
    box-shadow: 0 12px 35px rgba(0, 0, 0, 0.5), 0 0 25px rgba(226, 55, 68, 0.2);
    animation: ftbg-frise linear infinite;
    will-change: transform, opacity;
}
@keyframes ftbg-frise {
    0% { transform: translateY(0) translateX(0) rotate(-6deg) scale(0.85); opacity: 0; }
    8% { opacity: 0.75; }
    30% { transform: translateY(-32vh) translateX(20px) rotate(5deg) scale(1); }
    55% { transform: translateY(-58vh) translateX(-15px) rotate(-4deg) scale(0.96); opacity: 0.6; }
    80% { opacity: 0.3; }
    100% { transform: translateY(-112vh) translateX(12px) rotate(6deg) scale(0.88); opacity: 0; }
}

/* 5) Light-mode adaptation */
body.light-mode #ftbg-v video { opacity: 0.15; }
body.light-mode #ftbg-veil {
    background: linear-gradient(180deg, rgba(241, 243, 245, 0.6), rgba(241, 243, 245, 0.9));
}
body.light-mode #ftbg-bloom {
    background: radial-gradient(circle, rgba(226, 55, 68, 0.1), transparent 70%);
}
body.light-mode .ffood {
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.12), 0 0 20px rgba(226, 55, 68, 0.15);
}
</style>

<div id="ftbg-v" aria-hidden="true">
  <% if (ftHasVideo) { %>
  <video autoplay muted loop src="<%= ftBgV %>"></video>
  <% } %>
  <div id="ftbg-veil"></div>
</div>
<div id="ftbg-bloom" aria-hidden="true"></div>
<div id="ftbg-bloom2" aria-hidden="true"></div>

<script>
(function(){
  var foods = [
   'https://images.unsplash.com/photo-1563379091339-03246963d96c?auto=format&fit=crop&w=200&q=70',
   'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=200&q=70',
   'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=200&q=70',
   'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&w=200&q=70',
   'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=200&q=70',
   'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=200&q=70',
   'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=70',
   'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=200&q=70',
   'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&w=200&q=70',
   'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=200&q=70'
  ];

  for(var i = 0; i < 10; i++){
    var img = document.createElement('img');
    img.className = 'ffood';
    img.src = foods[i % foods.length];
    img.alt = '';
    img.onerror = function(){ this.remove(); };
    
    var size = (48 + Math.random() * 48);
    img.style.width = size + 'px';
    img.style.height = size + 'px';
    img.style.left = (Math.random() * 92 + 2) + '%';
    img.style.animationDuration = (22 + Math.random() * 16) + 's';
    img.style.animationDelay = (-Math.random() * 28) + 's';
    
    if(i % 3 === 0){
      img.style.filter = 'blur(2px)';
      img.style.opacity = '0.45';
    } else if(i % 3 === 1){
      img.style.filter = 'blur(0.8px)';
    }
    document.body.appendChild(img);
  }

  var v = document.querySelector('#ftbg-v video');
  if(v){
    v.muted = true;
    var p = v.play();
    if(p && p.catch) {
      p.catch(function(){
        document.addEventListener('click', function(){ v.play(); }, {once: true});
      });
    }
  }
})();
</script>