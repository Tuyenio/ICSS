<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="controller.KNCSDL" %>

<%! 
    boolean loginSuccess = false;
    String redirectUrl = "";
%>
<%
    String errorMsg = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            KNCSDL db = new KNCSDL();
            Map<String, String> user = db.login(email, password);
            db.close();

            if (user != null) {
                String id = user.get("id");
                String hoten = user.get("ho_ten");
                String vaiTro = user.get("vai_tro");
                String chucVu = user.get("chuc_vu");
                String avatar = user.get("avatar_url");
                session.setAttribute("userId", id);
                session.setAttribute("userEmail", email);
                session.setAttribute("userName", hoten);
                session.setAttribute("vaiTro", vaiTro);
                session.setAttribute("chucVu", chucVu);
                session.setAttribute("avatar", avatar);
                int userIdInt = Integer.parseInt(id);
                
                KNCSDL db2 = new KNCSDL();
                List<String> quyenList = db2.getQuyenTheoNhanVien(userIdInt);
                db2.close();
                
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < quyenList.size(); i++) {
                    json.append("\"").append(quyenList.get(i)).append("\"");
                    if (i < quyenList.size() - 1) json.append(",");
                }
                json.append("]");
                session.setAttribute("quyen", json.toString());

                if ("Admin".equalsIgnoreCase(vaiTro) || "Quản lý".equalsIgnoreCase(vaiTro)) {
                    response.sendRedirect("index.jsp");
                } else {
                    response.sendRedirect("./userDashboard");
                }
                return;
            } else {
                errorMsg = "Tài khoản hoặc mật khẩu không đúng!";
            }
        } catch (Exception e) {
            errorMsg = "Lỗi hệ thống: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Đăng nhập - ICS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
        <link rel="manifest" href="manifest.json">
        <meta name="theme-color" content="#1a73e8">
        <link rel="icon" href="icons/logoics.png">

        <style>
            body {
                background: linear-gradient(135deg, #1e293b, #0f172a);
                font-family: 'Segoe UI', sans-serif;
                height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0;
                padding: 10px;
            }

            .login-container {
                position: relative;
                width: 100%;
                max-width: 900px;
                background-color: #fff;
                border-radius: 20px;
                overflow: hidden;
                display: flex;
                flex-direction: row;
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
                z-index: 1;
            }

            .login-container::before {
                content: "";
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                border-radius: 20px;
                padding: 2px;
                background: linear-gradient(90deg, #ff7e5f, #feb47b, #86a8e7, #7f7fd5);
                background-size: 400% 400%;
                animation: moveBorder 6s linear infinite;
                z-index: 2;
                mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
                -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
                mask-composite: exclude;
                -webkit-mask-composite: destination-out;
                pointer-events: none;
                box-sizing: border-box;
            }
            @keyframes moveBorder {
                0% {
                    background-position: 0% 0%;
                }
                100% {
                    background-position: 400% 0%;
                }
            }

            .login-left, .login-right {
                flex: 1;
                padding: 40px;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
            }

            .login-left img {
                width: 250px;
                max-width: 90%;
                margin-bottom: 20px;
                animation: float 3s ease-in-out infinite;
            }

            @keyframes float {
                0%, 100% {
                    transform: translateY(0);
                }
                50% {
                    transform: translateY(-10px);
                }
            }

            .info-section {
                display: flex;
                justify-content: space-between;
                margin-top: 20px;
                gap: 20px;
            }

            .info-box {
                flex: 1;
                background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
                border-radius: 10px;
                padding: 20px;
                box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
                display: flex;
                justify-content: center;
                align-items: center;
                transition: transform 0.3s, box-shadow 0.3s;
                cursor: pointer;
            }

            .info-box:hover {
                transform: scale(1.05);
                box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2);
            }

            .info-box h6 {
                font-weight: bold;
                margin: 0;
                color: #4f46e5;
                text-align: center;
            }

            .modal-content {
                border-radius: 10px;
            }

            .modal-body p {
                margin-bottom: 15px;
                line-height: 1.6;
                font-size: 16px;
                color: #374151;
            }

            .modal-body p b {
                color: #1e40af;
            }

            .login-right {
                background: linear-gradient(145deg, #4f46e5, #0ea5e9);
                color: white;
                align-items: stretch;
            }

            .login-right h3 {
                font-weight: bold;
                margin-bottom: 10px;
            }

            .login-right p {
                font-size: 14px;
                margin-bottom: 25px;
                opacity: 0.9;
            }

            .form-control {
                border-radius: 10px;
                padding: 14px;
                font-size: 16px;
                transition: box-shadow 0.3s;
            }

            .form-control:focus {
                box-shadow: 0 0 10px rgba(78, 115, 223, 0.5);
            }

            .btn-login {
                background: #ffffff;
                border: none;
                border-radius: 10px;
                padding: 14px;
                color: #0ea5e9;
                font-weight: bold;
                transition: background 0.3s, transform 0.2s;
            }
            .btn-login:hover {
                background: #38bdf8;
                color: white;
                transform: scale(1.05);
            }

            .remember-forgot {
                display: flex;
                justify-content: space-between;
                font-size: 14px;
                color: #fff;
            }

            .remember-forgot a {
                color: #fff;
                text-decoration: underline;
            }

            /* Responsive cho mobile */
            @media (max-width: 768px) {
                body {
                    padding: 0;
                    background: #0f172a !important;
                }

                .login-container {
                    flex-direction: column !important;
                    max-width: 100%;
                    margin: 0 10px;
                    border-radius: 14px;
                    box-shadow: none !important;
                }

                .login-container::before {
                    padding: 1px; /* viền mỏng hơn giúp nhẹ mắt */
                    border-radius: 14px;
                }

                .login-left {
                    padding: 25px 20px 10px;
                    align-items: center;
                    text-align: center;
                }

                .login-left img {
                    width: 150px !important;
                    margin-bottom: 10px;
                }

                .info-section {
                    flex-direction: column !important;
                    gap: 10px;
                    width: 100%;
                }

                .info-box {
                    padding: 14px;
                }

                .login-right {
                    padding: 25px;
                    border-radius: 0 0 14px 14px;
                }

                .login-right h3 {
                    font-size: 22px;
                    text-align: center;
                }

                .login-right p {
                    text-align: center;
                    font-size: 13px;
                    margin-bottom: 20px;
                }

                .form-control {
                    font-size: 15px;
                    padding: 12px;
                }

                .btn-login {
                    padding: 12px;
                    font-size: 15px;
                }

                /* Giảm độ phô hiệu ứng giáng sinh trên mobile */
                .santa-flight,
                .xmas-tree,
                .santa-hat,
                .snowman,
                .gift {
                    transform: scale(0.7) !important;
                    opacity: 0.8;
                }

                /* tránh che nội dung */
                .snowman {
                    bottom: 4px !important;
                    right: 4px !important;
                }
            }
        </style>
        <style>
            /* gentle snowy background overlay (subtle) */
            .xmas-theme body,
            body.xmas {
                background: linear-gradient(135deg, #071129 10%, #08293a 60%);
            }

            /* overlay container for decorations */
            #xmasOverlay {
                pointer-events: none;
                position: fixed;
                inset: 0;
                z-index: 1050; /* above page but below any modal (modal z-index > 1050) */
            }

            /* falling snowflakes */
            .snowflake {
                position: absolute;
                top: -10%;
                color: rgba(255,255,255,0.9);
                font-size: 12px;
                user-select: none;
                will-change: transform, opacity;
                animation: fall linear infinite;
                text-shadow: 0 1px 2px rgba(0,0,0,0.2);
            }
            @keyframes fall {
                to {
                    transform: translateY(120vh) rotate(360deg);
                }
            }

            /* subtle bokeh lights top-right */
            .xmas-lights {
                position: absolute;
                top: 8px;
                right: 8px;
                display:flex;
                gap: 6px;
                z-index: 1060;
                pointer-events: none;
            }
            .xmas-lights .bulb {
                width: 10px;
                height: 10px;
                border-radius: 50%;
                box-shadow: 0 0 8px rgba(0,0,0,0.25);
                opacity: 0.95;
                animation: blink 2s infinite ease-in-out;
            }
            .xmas-lights .bulb:nth-child(1){
                background:#ff4d4f;
                animation-delay:0s;
            }
            .xmas-lights .bulb:nth-child(2){
                background:#ffd666;
                animation-delay:0.3s;
            }
            .xmas-lights .bulb:nth-child(3){
                background:#73d13d;
                animation-delay:0.6s;
            }
            .xmas-lights .bulb:nth-child(4){
                background:#69c0ff;
                animation-delay:0.9s;
            }
            @keyframes blink {
                0%,100%{
                    transform: scale(0.9);
                    opacity:0.7
                }
                50%{
                    transform: scale(1.15);
                    opacity:1
                }
            }

            /* small floating ornament near logo */
            .xmas-ornament {
                position: absolute;
                left: calc(50% - 460px);
                top: calc(50% - 230px);
                width: 60px;
                height: 60px;
                border-radius: 50%;
                background: radial-gradient(circle at 30% 25%, #fff8, #ff6b6b 40%, #c53d3d 100%);
                box-shadow: 0 6px 18px rgba(0,0,0,0.25), inset 0 -6px 18px rgba(255,255,255,0.08);
                display:flex;
                align-items:center;
                justify-content:center;
                transform-origin: center;
                animation: sway 4s ease-in-out infinite;
                z-index: 1060;
                pointer-events: none;
            }
            @keyframes sway {
                0%{
                    transform: translateY(0) rotate(-6deg);
                }
                50%{
                    transform: translateY(6px) rotate(6deg);
                }
                100%{
                    transform: translateY(0) rotate(-6deg);
                }
            }

            /* toggle control (bottom-left) to disable decorations */
            #xmasToggle {
                position: fixed;
                left: 12px;
                bottom: 12px;
                z-index: 20000;
                background: rgba(255,255,255,0.93);
                border-radius: 24px;
                padding: 6px 10px;
                box-shadow: 0 6px 18px rgba(0,0,0,0.12);
                cursor: pointer;
                font-size: 13px;
                display:flex;
                gap: 8px;
                align-items: center;
            }
            #xmasToggle .dot {
                width: 10px;
                height: 10px;
                border-radius: 50%;
                background: #ff6b6b;
                box-shadow: 0 0 6px #ff6b6b;
            }

            /* ==== NEW: trees, santa, snowman, gifts ==== */
            .xmas-tree {
                position: fixed;
                bottom: 10px;
                width: 90px;
                height: 130px;
                z-index: 1060;
                pointer-events: none;
                transform-origin: bottom center;
                animation: treeSway 6s ease-in-out infinite;
                filter: drop-shadow(0 6px 10px rgba(0,0,0,0.35));
            }
            .xmas-tree.small {
                width: 60px;
                height: 90px;
                bottom: 20px;
            }
            .tree-graphic {
                width:100%;
                height:100%;
                background: linear-gradient(#0b6623, #1b8c47);
                clip-path: polygon(50% 0%, 62% 19%, 80% 24%, 65% 40%, 78% 55%, 58% 52%, 68% 72%, 50% 62%, 32% 72%, 42% 52%, 22% 55%, 35% 40%, 20% 24%, 38% 19%);
                border-radius: 8px;
                position: relative;
                overflow: visible;
            }
            .tree-graphic::after{
                content:'';
                position:absolute;
                bottom:-12px;
                left:44%;
                width:12%;
                height:18px;
                background:#6b3e1d;
                border-radius:3px;
            }
            @keyframes treeSway {
                0%,100%{
                    transform: rotate(-2deg);
                }
                50%{
                    transform: rotate(2deg);
                }
            }

            /* twinkling lights on trees */
            .tree-lights {
                position:absolute;
                inset:10% 5% 20% 5%;
                pointer-events:none;
            }
            .tree-lights span {
                position:absolute;
                width:8px;
                height:8px;
                border-radius:50%;
                box-shadow: 0 0 8px currentColor;
                animation: twinkle 2.5s infinite ease-in-out;
                opacity: 0.95;
            }
            @keyframes twinkle {
                0%,100%{
                    transform: scale(0.8);
                    opacity:0.6
                }
                50%{
                    transform: scale(1.2);
                    opacity:1
                }
            }

            /* Santa sleigh flying across */
            .santa-flight {
                position: fixed;
                top: 12%;
                right: -20%;
                z-index: 1070;
                width: 220px;
                height: 80px;
                pointer-events: none;
                transform: translateX(0);
                animation: flyAcross 18s linear infinite;
                filter: drop-shadow(0 8px 18px rgba(0,0,0,0.45));
            }
            @keyframes flyAcross {
                0% {
                    right: -30%;
                    transform: translateY(0) rotate(-6deg)
                }
                50% {
                    right: 60%;
                    transform: translateY(-18px) rotate(0deg)
                }
                100% {
                    right: 110%;
                    transform: translateY(0) rotate(6deg)
                }
            }

            /* Santa hat on logo (small, positioned near .login-left img) */
            .santa-hat {
                position: absolute;
                width: 48px;
                height: 48px;
                z-index: 1075;
                pointer-events: none;
                transform-origin: bottom left;
                animation: hatBounce 3.2s ease-in-out infinite;
                left: calc(50% - 525px); /* tuned to where logo appears; adjust if needed */
                top: calc(50% - 290px);
            }
            @keyframes hatBounce {
                0%,100%{
                    transform: translateY(0)
                }
                50%{
                    transform: translateY(-6px)
                }
            }

            /* snowman */
            .snowman {
                position: fixed;
                bottom: 14px;
                right: 18px;
                width: 92px;
                height: 140px;
                z-index: 1060;
                pointer-events: none;
                animation: snowmanBob 4s ease-in-out infinite;
                filter: drop-shadow(0 6px 12px rgba(0,0,0,0.4));
            }
            @keyframes snowmanBob {
                0%,100%{
                    transform: translateY(0)
                }
                50%{
                    transform: translateY(-8px)
                }
            }

            /* small gift boxes */
            .gift {
                position: fixed;
                bottom: 8px;
                width: 46px;
                height: 40px;
                z-index: 1060;
                pointer-events: none;
                animation: giftBounce 3.6s ease-in-out infinite;
            }
            .gift.g1 {
                left: 16%;
                animation-delay: 0s;
            }
            .gift.g2 {
                left: 26%;
                animation-delay: 0.5s;
            }
            .gift.g3 {
                right: 14%;
                animation-delay: 0.2s;
            }
            @keyframes giftBounce {
                0%,100%{
                    transform: translateY(0)
                }
                50%{
                    transform: translateY(-6px)
                }
            }

            /* ensure overlay decorations are hidden when xmas disabled */
            body:not(.xmas) #xmasOverlay > .decoration {
                display: none;
            }
        </style>
        <!-- ====== end festive ====== -->
    </head>
    <body>
        <!-- Xmas overlay and controls -->
        <div id="xmasOverlay" aria-hidden="true">
            <div class="xmas-lights" aria-hidden="true">
                <div class="bulb"></div><div class="bulb"></div><div class="bulb"></div><div class="bulb"></div>
            </div>
            <div class="xmas-ornament" aria-hidden="true" title="Merry Christmas">
                <!-- simple SVG snowflake icon -->
                <svg width="36" height="36" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                <path d="M12 2v4M12 18v4M4.2 6.2l2.8 2.8M17 15l2.8 2.8M2 12h4M18 12h4M4.2 17.8L7 15M17 9l2.8-2.8" stroke="#fff" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </div>

            <!-- ==== NEW DECORATIONS (decorations have class .decoration so toggle CSS can hide them) ==== -->
            <div class="decoration santa-flight" aria-hidden="true" title="Santa is coming">
                <!-- simple Santa + sleigh SVG -->
                <svg viewBox="0 0 640 240" width="100%" height="100%" fill="none" aria-hidden="true">
                <g transform="scale(0.3)">
                <path d="M870 140c-40-10-90-30-130-50-40-20-80-45-120-60-30-12-60-20-90-25" stroke="#222" stroke-width="6" fill="none"/>
                <g transform="translate(350,30)">
                <circle cx="80" cy="40" r="28" fill="#fff"/>
                <path d="M20 90c70-10 160-10 230 0" stroke="#b33" stroke-width="18" stroke-linecap="round"/>
                <rect x="-10" y="100" width="300" height="24" rx="10" fill="#6b3e1d"/>
                <!-- sleigh hint -->
                <path d="M-20 132 q40 20 120 20" stroke="#222" stroke-width="10" fill="none" stroke-linecap="round"/>
                </g>
                </g>
                </svg>
            </div>

            <div class="decoration xmas-tree" style="left:18px;" aria-hidden="true">
                <div class="tree-graphic">
                    <div class="tree-lights">
                        <span style="left:18%; top:8%; color:#ffd700; animation-delay:0.1s"></span>
                        <span style="left:58%; top:20%; color:#ff4d4f; animation-delay:0.6s"></span>
                        <span style="left:34%; top:38%; color:#69c0ff; animation-delay:1.1s"></span>
                        <span style="left:64%; top:56%; color:#73d13d; animation-delay:1.8s"></span>
                    </div>
                </div>
            </div>

            <div class="decoration xmas-tree small" style="left:120px;" aria-hidden="true">
                <div class="tree-graphic">
                    <div class="tree-lights">
                        <span style="left:28%; top:12%; color:#ffd666; animation-delay:0.2s"></span>
                        <span style="left:52%; top:40%; color:#ff6b6b; animation-delay:0.9s"></span>
                    </div>
                </div>
            </div>

            <div class="decoration snowman" aria-hidden="true" title="Snowman">
                <!-- simple snowman SVG -->
                <svg viewBox="0 0 120 180" width="100%" height="100%" aria-hidden="true">
                <g transform="translate(10,10)">
                <circle cx="50" cy="120" r="30" fill="#fff" stroke="#ddd"/>
                <circle cx="50" cy="80" r="22" fill="#fff" stroke="#ddd"/>
                <circle cx="50" cy="48" r="16" fill="#fff" stroke="#ddd"/>
                <rect x="18" y="44" width="64" height="10" rx="2" fill="#b33"/>
                <circle cx="44" cy="46" r="2" fill="#000"/>
                <circle cx="56" cy="46" r="2" fill="#000"/>
                <path d="M50 54 q6 6 12 0" stroke="#000" stroke-width="2" fill="none"/>
                <line x1="28" y1="80" x2="10" y2="70" stroke="#6b3e1d" stroke-width="3"/>
                <line x1="72" y1="80" x2="90" y2="70" stroke="#6b3e1d" stroke-width="3"/>
                </g>
                </svg>
            </div>

            <div class="decoration gift g1" aria-hidden="true" title="Gift 1">
                <svg viewBox="0 0 80 72" width="100%" height="100%">
                <rect x="8" y="18" width="64" height="44" rx="4" fill="#ff7eb6" stroke="#d33"/>
                <rect x="36" y="6" width="8" height="56" fill="#fff2" />
                <rect x="8" y="28" width="64" height="8" fill="#fff4"/>
                </svg>
            </div>

            <div class="decoration gift g2" aria-hidden="true" title="Gift 2">
                <svg viewBox="0 0 80 72" width="100%" height="100%">
                <rect x="8" y="18" width="64" height="44" rx="4" fill="#69c0ff" stroke="#0a7"/>
                <rect x="36" y="6" width="8" height="56" fill="#fff2" />
                </svg>
            </div>

            <div class="decoration gift g3" aria-hidden="true" title="Gift 3">
                <svg viewBox="0 0 80 72" width="100%" height="100%">
                <rect x="8" y="18" width="64" height="44" rx="4" fill="#ffd666" stroke="#b96"/>
                <rect x="36" y="6" width="8" height="56" fill="#fff2" />
                </svg>
            </div>

            <!-- small Santa hat sitting near the logo -->
            <div class="decoration santa-hat" aria-hidden="true" title="Santa hat">
                <svg viewBox="0 0 64 64" width="100%" height="100%" aria-hidden="true">
                <path d="M6 30 q10 -18 26 -18 q12 0 26 18 q-20 6 -52 0z" fill="#d33"/>
                <path d="M4 32 q28 14 56 0" fill="#fff"/>
                <circle cx="56" cy="12" r="6" fill="#fff"/>
                </svg>
            </div>

        </div>

        <button id="xmasToggle" title="Bật/Tắt hiệu ứng Giáng sinh" aria-pressed="true">
            <span class="dot"></span><span style="font-weight:600;">Giáng sinh</span>
        </button>
        <script>
            (function () {
                const overlay = document.getElementById('xmasOverlay');
                const toggle = document.getElementById('xmasToggle');
                const htmlEl = document.documentElement;
                const bodyEl = document.body || htmlEl;
                let enabled = true;

                // create snowflakes
                function createSnowflakes(count) {
                    overlay.querySelectorAll('.snowflake').forEach(n => n.remove());
                    const vw = Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0);
                    for (let i = 0; i < count; i++) {
                        const s = document.createElement('div');
                        s.className = 'snowflake';
                        s.style.left = Math.random() * 100 + '%';
                        const size = 8 + Math.random() * 16;
                        s.style.fontSize = size + 'px';
                        const delay = Math.random() * -20;
                        const dur = 8 + Math.random() * 18;
                        s.style.animationDuration = dur + 's';
                        s.style.animationDelay = delay + 's';
                        s.style.opacity = 0.6 + Math.random() * 0.4;
                        s.innerHTML = '❄';
                        overlay.appendChild(s);
                    }
                }

                // make small random twinkles for tree-lights (in case some browsers remove CSS animation)
                function reviveTreeLights() {
                    overlay.querySelectorAll('.tree-lights span').forEach((el, idx) => {
                        el.style.animationDelay = (idx * 0.3 + Math.random()).toFixed(2) + 's';
                    });
                }

                // optional: reposition santa-hat to sit above actual logo on different viewport sizes
                function positionHatNearLogo() {
                    const logo = document.querySelector('.login-left img');
                    const hat = document.querySelector('.santa-hat');
                    if (!logo || !hat)
                        return;
                    const r = logo.getBoundingClientRect();
                    hat.style.left = (r.left + r.width * 0.62) + 'px';
                    hat.style.top = (r.top - r.height * 0.18) + 'px';
                    hat.style.width = Math.max(36, Math.min(64, r.width * 0.24)) + 'px';
                }

                function setEnabled(v) {
                    enabled = !!v;
                    if (enabled) {
                        // add class to both body and html to match CSS selectors
                        htmlEl.classList.add('xmas');
                        bodyEl.classList.add('xmas');
                        createSnowflakes(36);
                        reviveTreeLights();
                        positionHatNearLogo();
                        toggle.setAttribute('aria-pressed', 'true');
                        toggle.querySelector('.dot').style.background = '#ff6b6b';
                    } else {
                        htmlEl.classList.remove('xmas');
                        bodyEl.classList.remove('xmas');
                        overlay.querySelectorAll('.snowflake').forEach(n => n.remove());
                        toggle.setAttribute('aria-pressed', 'false');
                        toggle.querySelector('.dot').style.background = '#999';
                    }
                }

                toggle.addEventListener('click', function () {
                    setEnabled(!enabled);
                    try {
                        localStorage.setItem('xmasEnabled', enabled ? '1' : '0');
                    } catch (e) {
                    }
                });

                // restore preference
                try {
                    const pref = localStorage.getItem('xmasEnabled');
                    if (pref !== null)
                        setEnabled(pref === '1');
                    else
                        setEnabled(true);
                } catch (e) {
                    setEnabled(true);
                }

                // recreate when resize for better distribution
                window.addEventListener('resize', function () {
                    if (enabled) {
                        createSnowflakes(36);
                        positionHatNearLogo();
                    }
                });
                // initial position
                window.addEventListener('load', positionHatNearLogo);
            })();
        </script>
        <script>
            if ('serviceWorker' in navigator) {
                navigator.serviceWorker.register('sw.js', {scope: '/ICSS/'})
                        .then(() => console.log('✅ Service Worker registered'))
                        .catch(err => console.error('❌ Service Worker registration failed:', err));
            }
        </script>
        <script>
            function togglePassword() {
                const passwordField = document.getElementById('password');
                const toggleIcon = document.getElementById('togglePasswordIcon');
                if (passwordField.type === 'password') {
                    passwordField.type = 'text';
                    toggleIcon.classList.remove('fa-eye');
                    toggleIcon.classList.add('fa-eye-slash');
                } else {
                    passwordField.type = 'password';
                    toggleIcon.classList.remove('fa-eye-slash');
                    toggleIcon.classList.add('fa-eye');
                }
            }
        </script>
        <div class="login-container">
            <div class="login-left">
                <img src="Img/logoics.png" alt="Logo">
                <div class="info-section">
                    <div class="info-box" data-bs-toggle="modal" data-bs-target="#companyCultureModal">
                        <h6>Văn hóa doanh nghiệp ICS</h6>
                    </div>
                    <div class="info-box" data-bs-toggle="modal" data-bs-target="#websiteGuideModal">
                        <h6>Hướng dẫn sử dụng Website</h6>
                    </div>
                </div>
            </div>
            <div class="login-right">
                <h3>Welcome ICS HRM</h3>
                <p class="text-muted">Sign in to continue</p>
                <% if (!errorMsg.isEmpty()) { %>
                <div class="alert alert-danger py-2 mb-3" role="alert">
                    <%= errorMsg %>
                </div>
                <% } %>
                <form action="login.jsp" method="post">
                    <div class="mb-3">
                        <label for="email" class="form-label">Email</label>
                        <input type="text" class="form-control" id="email" name="email" placeholder="Nhập email">
                    </div>
                    <div class="mb-3 position-relative">
                        <label for="password" class="form-label">Password</label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="password" name="password" placeholder="Nhập mật khẩu">
                            <span class="input-group-text" onclick="togglePassword()" style="cursor: pointer;">
                                <i class="fa fa-eye" id="togglePasswordIcon"></i>
                            </span>
                        </div>
                    </div>
                    <div class="remember-forgot mb-3">
                        <div>
                            <input type="checkbox" id="remember"> <label for="remember">Remember me</label>
                        </div>
                        <a href="#">Forgot Password?</a>
                    </div>
                    <button type="submit" class="btn btn-login w-100">Login</button>
                </form>
            </div>
        </div>

        <input type="hidden" id="loginSuccess" value="<%= loginSuccess %>">
        <input type="hidden" id="redirectUrl" value="<%= redirectUrl %>">

        <!-- Modal for Company Culture -->
        <div class="modal fade" id="companyCultureModal" tabindex="-1" aria-labelledby="companyCultureModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="companyCultureModalLabel">Văn hóa ICS – Nội quy cơ bản</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p><b>1. Giờ giấc làm việc:</b> Làm việc từ Thứ 2 – Thứ 6, thời gian: 08h00 – 17h00 (nghỉ trưa 12h00 – 13h00). Có mặt đúng giờ, hạn chế đi muộn hoặc về sớm.</p>
                        <p><b>2. Trang phục:</b> Ăn mặc lịch sự, gọn gàng; ưu tiên áo sơ mi, áo polo, quần/váy công sở. Không mặc trang phục phản cảm hoặc không phù hợp môi trường làm việc.</p>
                        <p><b>3. Tác phong:</b> Giao tiếp văn minh, tôn trọng đồng nghiệp và khách hàng. Giữ bàn làm việc gọn gàng, hạn chế gây ồn ào. Thái độ chủ động, trách nhiệm với công việc được giao.</p>
                        <p><b>4. An ninh – Bảo mật:</b> Không chia sẻ thông tin nội bộ ra ngoài khi chưa được phép. Tuân thủ nghiêm ngặt quy định an toàn thông tin và an ninh mạng. Sử dụng tài nguyên công ty (máy tính, email, mạng nội bộ) đúng mục đích.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal for Website Guide -->
        <div class="modal fade" id="websiteGuideModal" tabindex="-1" aria-labelledby="websiteGuideModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="websiteGuideModalLabel">Hướng dẫn sử dụng Website</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <video controls width="100%">
                            <source src="http://localhost:8080/ICSS/Img/123a.mp4
                                    " type="video/mp4">
                            Trình duyệt của bạn không hỗ trợ video.
                        </video>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                document.addEventListener("DOMContentLoaded", () => {
                                    const success = document.getElementById("loginSuccess").value === "true";
                                    const redirectUrl = document.getElementById("redirectUrl").value;
                                    if (success && redirectUrl) {
                                        // Chuyển trang client-side, an toàn cho Mini App Zalo
                                        window.location.href = redirectUrl;
                                    }
                                });
        </script>
        <script>
            window.__gim = window.__gim || {};
            window.__gim.licenseId = "586508500633432247";
            (function (c, o) {
                const e = [], n = {_handler: null, _version: "1.0", _queue: e, on: function () {
                        return e.push(["on", arguments]), n
                    }, call: function () {
                        return e.push(["call", arguments]), n
                    }, loadScript: function () {
                        const t = o.createElement("script");
                        t.async = !0, t.type = "text/javascript", t.src = "https://botsdk.stg.gim.beango.com/index.umd.js", o.head.appendChild(t)
                    }};
                n.loadScript(), window.GIMBotTool = n
            })(window, document);
        </script>
    </body>
</html>