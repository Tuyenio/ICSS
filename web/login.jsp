<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="controller.KNCSDL" %>
<%@ page import="controller.CookieUtil" %>

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
                
                // ✅ Lưu thông tin người dùng vào cookies (7 ngày = 604800 giây)
                // Mã hóa thông tin người dùng để bảo mật
                String userDataEncrypted = CookieUtil.encrypt(id + "|" + email + "|" + hoten + "|" + vaiTro + "|" + chucVu + "|" + avatar);
                
                if (userDataEncrypted != null) {
                    Cookie userCookie = new Cookie("ICSS_USER", userDataEncrypted);
                    userCookie.setMaxAge(7 * 24 * 60 * 60); // 7 ngày
                    userCookie.setHttpOnly(true); // Không cho JavaScript truy cập (bảo mật)
                    userCookie.setSecure(false); // Đặt true nếu sử dụng HTTPS
                    userCookie.setPath("/");
                    response.addCookie(userCookie);
                }
                
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
                background: linear-gradient(135deg, #8B0000, #DC143C, #FF6347);
                font-family: 'Segoe UI', sans-serif;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0;
                padding: 10px;
                overflow-y: auto;
                overflow-x: hidden;
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
                background: linear-gradient(90deg, #FFD700, #FF0000, #FFD700, #FF6347, #FFD700);
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
                animation: float 3s ease-in-out infinite, glow 2s ease-in-out infinite;
                filter: drop-shadow(0 4px 12px rgba(255, 215, 0, 0.5));
            }

            @keyframes float {
                0%, 100% {
                    transform: translateY(0);
                }
                50% {
                    transform: translateY(-10px);
                }
            }

            @keyframes glow {
                0%, 100% {
                    filter: drop-shadow(0 4px 12px rgba(255, 215, 0, 0.5));
                }
                50% {
                    filter: drop-shadow(0 8px 20px rgba(220, 20, 60, 0.6));
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
                background: linear-gradient(135deg, #FFE5E5, #FFD6D6);
                border-radius: 10px;
                padding: 20px;
                box-shadow: 0 4px 10px rgba(220, 20, 60, 0.2);
                display: flex;
                justify-content: center;
                align-items: center;
                transition: transform 0.3s, box-shadow 0.3s;
                cursor: pointer;
                border: 2px solid #FFD700;
            }

            .info-box:hover {
                transform: scale(1.05) translateY(-5px);
                box-shadow: 0 8px 25px rgba(220, 20, 60, 0.4);
                background: linear-gradient(135deg, #FFD700, #FFA500);
            }

            .info-box h6 {
                font-weight: bold;
                margin: 0;
                color: #DC143C;
                text-align: center;
            }

            .info-box:hover h6 {
                color: #8B0000;
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
                background: linear-gradient(145deg, #DC143C, #FF6347, #FF4500);
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
                transition: box-shadow 0.3s, transform 0.2s, border-color 0.3s;
                border: 2px solid rgba(255, 215, 0, 0.3);
                background: rgba(255, 255, 255, 0.95);
            }

            .form-control:focus {
                box-shadow: 0 0 15px rgba(255, 215, 0, 0.6), 0 0 25px rgba(220, 20, 60, 0.3);
                border-color: #FFD700;
                transform: scale(1.02);
                background: #fff;
            }

            .btn-login {
                background: #FFD700;
                border: none;
                border-radius: 10px;
                padding: 14px;
                color: #DC143C;
                font-weight: bold;
                transition: background 0.3s, transform 0.2s;
                box-shadow: 0 4px 15px rgba(255, 215, 0, 0.4);
            }
            .btn-login:hover {
                background: #FFA500;
                color: white;
                transform: scale(1.05);
                box-shadow: 0 6px 20px rgba(255, 165, 0, 0.6);
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
                    padding: 20px 0;
                    background: linear-gradient(135deg, #8B0000, #DC143C, #FF6347) !important;
                    min-height: 100vh;
                    height: auto;
                    align-items: flex-start;
                }

                .login-container {
                    flex-direction: column !important;
                    max-width: 100%;
                    margin: 20px 10px;
                    border-radius: 14px;
                    box-shadow: none !important;
                    min-height: auto;
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

                /* Giảm độ phô hiệu ứng tết trên mobile */
                .tet-lantern,
                .tet-peach-blossom,
                .tet-envelope,
                .tet-horse,
                .tet-couplet {
                    transform: scale(0.6) !important;
                    opacity: 0.7;
                }

                /* tránh che nội dung */
                .tet-horse {
                    bottom: 8% !important;
                }

                .tet-couplet {
                    font-size: 12px !important;
                    width: 50px !important;
                    height: 200px !important;
                    padding: 10px 5px !important;
                }
            }
        </style>
        <style>
            /* ========== TẾT NGUYÊN ĐÁN 2026 THEME ========== */

            /* Nền gradient đỏ vàng cho không khí tết */
            .tet-theme body,
            body.tet {
                background: linear-gradient(135deg, #8B0000 0%, #DC143C 50%, #FF6347 100%);
                position: relative;
            }

            /* Overlay container for decorations */
            #tetOverlay {
                pointer-events: none;
                position: fixed;
                inset: 0;
                z-index: 1050;
            }

            /* ===== HOA ĐÀO / HOA MAI RƠI ===== */
            .peach-blossom {
                position: absolute;
                top: -10%;
                font-size: 20px;
                user-select: none;
                will-change: transform, opacity;
                animation: fallBlossom linear infinite;
                filter: drop-shadow(0 2px 4px rgba(0,0,0,0.2));
            }
            @keyframes fallBlossom {
                to {
                    transform: translateY(120vh) rotate(720deg);
                    opacity: 0;
                }
            }

            /* ===== PHÁO HOA ===== */
            .firework {
                position: absolute;
                width: 4px;
                height: 4px;
                border-radius: 50%;
                animation: explode 2s ease-out infinite;
            }
            @keyframes explode {
                0% {
                    transform: translate(0, 0) scale(1);
                    opacity: 1;
                }
                100% {
                    transform: translate(var(--tx), var(--ty)) scale(0);
                    opacity: 0;
                }
            }

            /* ===== ĐÈN LỒNG ĐỎ ===== */
            .tet-lanterns {
                position: absolute;
                top: 8px;
                right: 8px;
                display: flex;
                gap: 20px;
                z-index: 1060;
                pointer-events: none;
            }
            .lantern {
                width: 40px;
                height: 60px;
                background: linear-gradient(180deg, #FF0000, #8B0000);
                border-radius: 8px 8px 12px 12px;
                position: relative;
                animation: swingLantern 3s ease-in-out infinite;
                box-shadow: 0 4px 15px rgba(255, 0, 0, 0.5),
                    inset 0 -10px 20px rgba(0, 0, 0, 0.3);
            }
            .lantern::before {
                content: attr(data-text);
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);

                font-family: "KaiTi", "STKaiti", "SimSun", serif;
                font-size: 26px;
                font-weight: bold;

                color: #FFD700;
                text-shadow:
                    0 2px 4px rgba(0,0,0,.6),
                    0 0 8px rgba(255,215,0,.6);
            }
            .lantern::after {
                content: '';
                position: absolute;
                bottom: -15px;
                left: 50%;
                transform: translateX(-50%);
                width: 2px;
                height: 15px;
                background: #FFD700;
            }
            .lantern-tassel {
                position: absolute;
                bottom: -25px;
                left: 50%;
                transform: translateX(-50%);
                width: 8px;
                height: 10px;
                background: #FFD700;
                clip-path: polygon(50% 0%, 0% 100%, 100% 100%);
            }
            @keyframes swingLantern {
                0%, 100% {
                    transform: rotate(-8deg);
                }
                50% {
                    transform: rotate(8deg);
                }
            }

            /* ===== CÂU ĐỐI TẾT ===== */
            .tet-couplet {
                position: fixed;
                width: 65px;
                height: 260px;
                background: linear-gradient(180deg, #DC143C, #8B0000);
                border: 3px solid #FFD700;
                border-radius: 4px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 18px;
                color: #FFD700;
                font-weight: bold;
                writing-mode: vertical-lr;   /* TRÁI → PHẢI */
                text-orientation: upright;
                padding: 20px 10px;
                box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
                z-index: 1060;
                pointer-events: none;
                animation: coupletSway 4s ease-in-out infinite;
                letter-spacing: 8px;
                line-height: 1.2;
            }
            .tet-couplet.left {
                left: 20px;
                top: 15%;
            }
            .tet-couplet.right {
                right: 20px;
                top: 15%;
            }
            @keyframes coupletSway {
                0%, 100% {
                    transform: rotate(-2deg);
                }
                50% {
                    transform: rotate(2deg);
                }
            }

            /* ===== HOA ĐÀO / HOA MAI - CÂY ===== */
            .tet-peach-blossom {
                position: fixed;
                width: 120px;
                height: 180px;
                z-index: 1060;
                pointer-events: none;
                animation: treeSway 5s ease-in-out infinite;
                filter: drop-shadow(0 4px 10px rgba(0,0,0,0.3));
            }
            .tet-peach-blossom.left {
                bottom: 20px;
                left: 30px;
            }
            .tet-peach-blossom.right {
                bottom: 20px;
                right: 30px;
            }
            @keyframes treeSway {
                0%, 100% {
                    transform: rotate(-3deg);
                }
                50% {
                    transform: rotate(3deg);
                }
            }

            /* ===== LÌ XÌ / BAO LÌ XÌ ===== */
            .tet-envelope {
                position: fixed;
                width: 70px;
                height: 45px;
                background: linear-gradient(135deg, #FF0000, #DC143C);
                border: 2px solid #FFD700;
                border-radius: 4px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 14px;
                color: #FFD700;
                font-weight: bold;
                box-shadow: 0 4px 15px rgba(255, 0, 0, 0.4);
                z-index: 1060;
                pointer-events: none;
                animation: envelopeBounce 3s ease-in-out infinite;
            }
            .tet-envelope::before {
                content: 'Lì Xì';
            }
            .tet-envelope.e1 {
                left: 15%;
                bottom: 30px;
                animation-delay: 0s;
            }
            .tet-envelope.e2 {
                left: 25%;
                bottom: 50px;
                animation-delay: 0.5s;
            }
            .tet-envelope.e3 {
                right: 20%;
                bottom: 40px;
                animation-delay: 0.3s;
            }
            @keyframes envelopeBounce {
                0%, 100% {
                    transform: translateY(0) rotate(-5deg);
                }
                50% {
                    transform: translateY(-12px) rotate(5deg);
                }
            }

            /* ===== CON NGỰA (NĂM NGỌA 2026) CHẠY ===== */
            .tet-horse {
                position: fixed;
                bottom: 15%;
                right: -25%;
                width: 200px;
                height: 150px;
                z-index: 1070;
                pointer-events: none;
                animation: horseRun 15s linear infinite;
                filter: drop-shadow(0 8px 20px rgba(0,0,0,0.4));
            }
            @keyframes horseRun {
                0% {
                    right: -30%;
                    transform: translateY(0) scaleX(1);
                }
                50% {
                    right: 60%;
                    transform: translateY(-15px) scaleX(1);
                }
                100% {
                    right: 115%;
                    transform: translateY(0) scaleX(1);
                }
            }

            /* ===== CONFETTI VÀNG ĐỎ ===== */
            .confetti {
                position: absolute;
                width: 10px;
                height: 10px;
                background: #FFD700;
                top: -10%;
                animation: confettiFall linear infinite;
            }
            .confetti:nth-child(odd) {
                background: #FF0000;
            }
            @keyframes confettiFall {
                to {
                    transform: translateY(120vh) rotate(360deg);
                    opacity: 0;
                }
            }

            /* ===== TOGGLE BUTTON ===== */
            #tetToggle {
                position: fixed;
                left: 12px;
                bottom: 12px;
                z-index: 20000;
                background: linear-gradient(135deg, #FFD700, #FFA500);
                border-radius: 24px;
                padding: 8px 14px;
                box-shadow: 0 6px 20px rgba(255, 215, 0, 0.4);
                cursor: pointer;
                font-size: 13px;
                display: flex;
                gap: 8px;
                align-items: center;
                font-weight: 600;
                color: #8B0000;
                border: 2px solid #FF0000;
            }
            #tetToggle .dot {
                width: 12px;
                height: 12px;
                border-radius: 50%;
                background: #FF0000;
                box-shadow: 0 0 8px #FF0000;
                animation: pulse 2s infinite;
            }
            @keyframes pulse {
                0%, 100% {
                    transform: scale(1);
                    opacity: 1;
                }
                50% {
                    transform: scale(1.2);
                    opacity: 0.8;
                }
            }

            /* Hide decorations when disabled */
            body:not(.tet) #tetOverlay > .decoration {
                display: none;
            }
        </style>
        <!-- ====== end festive ====== -->
    </head>
    <body>
        <!-- Tet overlay and controls -->
        <div id="tetOverlay" aria-hidden="true">
            <!-- Đèn lồng đỏ -->
            <div class="tet-lanterns" aria-hidden="true">
                <div class="lantern" data-text="Phúc">
                    <div class="lantern-tassel"></div>
                </div>
                <div class="lantern" style="animation-delay: 0.5s;" data-text="Lộc">
                    <div class="lantern-tassel"></div>
                </div>
                <div class="lantern" style="animation-delay: 1s;" data-text="Thọ">
                    <div class="lantern-tassel"></div>
                </div>
            </div>

            <!-- Câu đối tết -->
            <div class="decoration tet-couplet left" aria-hidden="true">2026</div>
            <div class="decoration tet-couplet right" aria-hidden="true">2026</div>

            <!-- Cây hoa đào / mai -->
            <div class="decoration tet-peach-blossom left" aria-hidden="true">
                <svg viewBox="0 0 120 180" width="100%" height="100%" aria-hidden="true">
                <!-- Thân cây -->
                <path d="M60 180 L60 40 Q58 35 62 30 L58 25" stroke="#5D4037" stroke-width="6" fill="none"/>
                <path d="M60 100 L75 90" stroke="#5D4037" stroke-width="4" fill="none"/>
                <path d="M60 80 L45 70" stroke="#5D4037" stroke-width="4" fill="none"/>
                <path d="M60 50 L70 45" stroke="#5D4037" stroke-width="3" fill="none"/>

                <!-- Hoa đào -->
                <circle cx="45" cy="70" r="8" fill="#FFB3BA" opacity="0.9"/>
                <circle cx="43" cy="68" r="3" fill="#FF69B4"/>
                <circle cx="75" cy="90" r="7" fill="#FFB3BA" opacity="0.9"/>
                <circle cx="74" cy="88" r="3" fill="#FF1493"/>
                <circle cx="70" cy="45" r="9" fill="#FFB3BA" opacity="0.9"/>
                <circle cx="68" cy="43" r="3" fill="#FF69B4"/>
                <circle cx="62" cy="30" r="10" fill="#FFB3BA" opacity="0.9"/>
                <circle cx="60" cy="28" r="4" fill="#FF1493"/>
                <circle cx="58" cy="25" r="8" fill="#FFB3BA" opacity="0.9"/>
                <circle cx="56" cy="23" r="3" fill="#FF69B4"/>
                </svg>
            </div>

            <div class="decoration tet-peach-blossom right" aria-hidden="true">
                <svg viewBox="0 0 120 180" width="100%" height="100%" aria-hidden="true">
                <!-- Thân cây mai -->
                <path d="M60 180 L60 40 Q62 35 58 30 L62 25" stroke="#8B7355" stroke-width="6" fill="none"/>
                <path d="M60 100 L45 90" stroke="#8B7355" stroke-width="4" fill="none"/>
                <path d="M60 80 L75 70" stroke="#8B7355" stroke-width="4" fill="none"/>
                <path d="M60 50 L50 45" stroke="#8B7355" stroke-width="3" fill="none"/>

                <!-- Hoa mai vàng -->
                <g transform="translate(45, 90)">
                <circle r="10" fill="#FFD700" opacity="0.9"/>
                <circle cx="-6" cy="-6" r="3" fill="#FFA500"/>
                <circle cx="6" cy="-6" r="3" fill="#FFA500"/>
                <circle cx="-6" cy="6" r="3" fill="#FFA500"/>
                <circle cx="6" cy="6" r="3" fill="#FFA500"/>
                <circle cx="0" cy="0" r="2" fill="#FF8C00"/>
                </g>
                <g transform="translate(75, 70)">
                <circle r="9" fill="#FFD700" opacity="0.9"/>
                <circle cx="-5" cy="-5" r="2.5" fill="#FFA500"/>
                <circle cx="5" cy="-5" r="2.5" fill="#FFA500"/>
                <circle cx="-5" cy="5" r="2.5" fill="#FFA500"/>
                <circle cx="5" cy="5" r="2.5" fill="#FFA500"/>
                </g>
                <g transform="translate(50, 45)">
                <circle r="11" fill="#FFD700" opacity="0.9"/>
                <circle cx="-6" cy="-6" r="3" fill="#FFA500"/>
                <circle cx="6" cy="-6" r="3" fill="#FFA500"/>
                <circle cx="-6" cy="6" r="3" fill="#FFA500"/>
                <circle cx="6" cy="6" r="3" fill="#FFA500"/>
                <circle cx="0" cy="0" r="2" fill="#FF8C00"/>
                </g>
                <g transform="translate(62, 30)">
                <circle r="10" fill="#FFD700" opacity="0.9"/>
                <circle cx="-5" cy="-5" r="3" fill="#FFA500"/>
                <circle cx="5" cy="-5" r="3" fill="#FFA500"/>
                <circle cx="-5" cy="5" r="3" fill="#FFA500"/>
                <circle cx="5" cy="5" r="3" fill="#FFA500"/>
                </g>
                </svg>
            </div>

            <!-- Bao lì xì -->
            <div class="decoration tet-envelope e1" aria-hidden="true"></div>
            <div class="decoration tet-envelope e2" aria-hidden="true"></div>
            <div class="decoration tet-envelope e3" aria-hidden="true"></div>
        </div>

        <button id="tetToggle" title="Bật/Tắt hiệu ứng Tết" aria-pressed="true">
            <span class="dot"></span><span>Tết Nguyên Đán 2026</span>
        </button>

        <script>
            (function () {
                const overlay = document.getElementById('tetOverlay');
                const toggle = document.getElementById('tetToggle');
                const htmlEl = document.documentElement;
                const bodyEl = document.body || htmlEl;
                let enabled = true;

                // Tạo hoa đào/mai rơi
                function createBlossoms(count) {
                    overlay.querySelectorAll('.peach-blossom').forEach(n => n.remove());
                    const blossoms = ['🌸', '🌺', '🏵️', '💮'];
                    for (let i = 0; i < count; i++) {
                        const b = document.createElement('div');
                        b.className = 'peach-blossom';
                        b.style.left = Math.random() * 100 + '%';
                        const size = 16 + Math.random() * 12;
                        b.style.fontSize = size + 'px';
                        const delay = Math.random() * -15;
                        const dur = 10 + Math.random() * 15;
                        b.style.animationDuration = dur + 's';
                        b.style.animationDelay = delay + 's';
                        b.style.opacity = 0.7 + Math.random() * 0.3;
                        b.innerHTML = blossoms[Math.floor(Math.random() * blossoms.length)];
                        overlay.appendChild(b);
                    }
                }

                // Tạo confetti vàng đỏ
                function createConfetti(count) {
                    overlay.querySelectorAll('.confetti').forEach(n => n.remove());
                    for (let i = 0; i < count; i++) {
                        const c = document.createElement('div');
                        c.className = 'confetti';
                        c.style.left = Math.random() * 100 + '%';
                        const delay = Math.random() * -10;
                        const dur = 5 + Math.random() * 10;
                        c.style.animationDuration = dur + 's';
                        c.style.animationDelay = delay + 's';
                        overlay.appendChild(c);
                    }
                }

                // Tạo pháo hoa
                function createFireworks() {
                    const colors = ['#FFD700', '#FF0000', '#FF6347', '#FFA500', '#FF1493'];
                    setInterval(() => {
                        if (!enabled)
                            return;
                        const container = document.createElement('div');
                        container.style.position = 'absolute';
                        container.style.left = (20 + Math.random() * 60) + '%';
                        container.style.top = (10 + Math.random() * 30) + '%';
                        overlay.appendChild(container);

                        for (let i = 0; i < 30; i++) {
                            const particle = document.createElement('div');
                            particle.className = 'firework';
                            const angle = (Math.PI * 2 * i) / 30;
                            const velocity = 50 + Math.random() * 50;
                            particle.style.setProperty('--tx', Math.cos(angle) * velocity + 'px');
                            particle.style.setProperty('--ty', Math.sin(angle) * velocity + 'px');
                            particle.style.background = colors[Math.floor(Math.random() * colors.length)];
                            container.appendChild(particle);
                        }

                        setTimeout(() => container.remove(), 2000);
                    }, 3000);
                }

                function setEnabled(v) {
                    enabled = !!v;
                    if (enabled) {
                        htmlEl.classList.add('tet');
                        bodyEl.classList.add('tet');
                        createBlossoms(25);
                        createConfetti(20);
                        createFireworks();
                        toggle.setAttribute('aria-pressed', 'true');
                        toggle.querySelector('.dot').style.background = '#FF0000';
                    } else {
                        htmlEl.classList.remove('tet');
                        bodyEl.classList.remove('tet');
                        overlay.querySelectorAll('.peach-blossom').forEach(n => n.remove());
                        overlay.querySelectorAll('.confetti').forEach(n => n.remove());
                        toggle.setAttribute('aria-pressed', 'false');
                        toggle.querySelector('.dot').style.background = '#999';
                    }
                }

                toggle.addEventListener('click', function () {
                    setEnabled(!enabled);
                    try {
                        localStorage.setItem('tetEnabled', enabled ? '1' : '0');
                    } catch (e) {
                    }
                });

                // Restore preference
                try {
                    const pref = localStorage.getItem('tetEnabled');
                    if (pref !== null)
                        setEnabled(pref === '1');
                    else
                        setEnabled(true);
                } catch (e) {
                    setEnabled(true);
                }

                window.addEventListener('resize', function () {
                    if (enabled) {
                        createBlossoms(25);
                        createConfetti(20);
                    }
                });
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
                <h3>🎊 Chúc Mừng Năm Mới 2026 🎊</h3>
                <p class="text-muted">Vạn sự như ý - An khang thịnh vượng</p>
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