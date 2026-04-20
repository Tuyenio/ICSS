<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*, java.util.*" %>
        <%@ page import="controller.KNCSDL" %>
            <%@ page import="controller.CookieUtil" %>

                <%! boolean loginSuccess=false; String redirectUrl="" ; %>
                    <% String errorMsg="" ; if ("POST".equalsIgnoreCase(request.getMethod())) { String
                        email=request.getParameter("email"); String password=request.getParameter("password"); try {
                        KNCSDL db=new KNCSDL(); Map<String, String> user = db.login(email, password);
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

                        String userDataEncrypted = CookieUtil.encrypt(id + "|" + email + "|" + hoten + "|" + vaiTro +
                        "|" + chucVu + "|" + avatar);

                        if (userDataEncrypted != null) {
                        Cookie userCookie = new Cookie("ICSS_USER", userDataEncrypted);
                        userCookie.setMaxAge(7 * 24 * 60 * 60);
                        userCookie.setHttpOnly(true);
                        userCookie.setSecure(false);
                        userCookie.setPath("/");
                        response.addCookie(userCookie);
                        }

                        int userIdInt = Integer.parseInt(id);

                        KNCSDL db2 = new KNCSDL();
                        List<String> quyenList = db2.getQuyenTheoNhanVien(userIdInt);
                            db2.close();

                            StringBuilder json = new StringBuilder("[");
                            for (int i = 0; i < quyenList.size(); i++) {
                                json.append("\"").append(quyenList.get(i)).append("\""); if (i < quyenList.size() - 1)
                                json.append(","); } json.append("]"); session.setAttribute("quyen", json.toString()); if
                                ("Admin".equalsIgnoreCase(vaiTro) || "Quản lý" .equalsIgnoreCase(vaiTro)) {
                                response.sendRedirect("index.jsp"); } else { response.sendRedirect("./userDashboard"); }
                                return; } else { errorMsg="Tài khoản hoặc mật khẩu không đúng!" ; } } catch (Exception
                                e) { errorMsg="Lỗi hệ thống: " + e.getMessage(); } } %>

                                <!DOCTYPE html>
                                <html lang="vi">

                                <head>
                                    <meta charset="UTF-8">
                                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                    <link rel="icon" type="image/png" href="Img/logoics.png">
                                    <title>Đăng nhập - ICS | Mùa Hè Vẫy Gọi</title>
                                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
                                        rel="stylesheet">
                                    <link
                                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"
                                        rel="stylesheet">
                                    <link rel="manifest" href="manifest.json">
                                    <meta name="theme-color" content="#0d3b66">
                                    <link rel="icon" href="icons/logoics.png">

                                    <style>
                                        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Outfit:wght@400;500;600;700;800&family=Roboto:wght@400;500;700&display=swap');

                                        * {
                                            margin: 0;
                                            padding: 0;
                                            box-sizing: border-box;
                                        }

                                        body {
                                            font-family: 'Inter', 'Segoe UI', sans-serif;
                                            min-height: 100vh;
                                            display: flex;
                                            align-items: center;
                                            justify-content: center;
                                            overflow-x: hidden;
                                            overflow-y: auto;
                                            padding: 20px;
                                            background: #0a1628;
                                            position: relative;
                                        }

                                        /* ===== VIDEO BACKGROUND ===== */
                                        .video-bg {
                                            position: fixed;
                                            top: 0;
                                            left: 0;
                                            width: 100vw;
                                            height: 100vh;
                                            object-fit: cover;
                                            z-index: 0;
                                            pointer-events: none;
                                        }

                                        /* Overlay tối nhẹ trên video để text dễ đọc */
                                        .video-overlay {
                                            position: fixed;
                                            top: 0;
                                            left: 0;
                                            width: 100vw;
                                            height: 100vh;
                                            background: rgba(0, 15, 40, 0.3);
                                            z-index: 1;
                                            pointer-events: none;
                                        }

                                        /* ===== GLASSMORPHISM LOGIN CONTAINER ===== */
                                        .login-container {
                                            position: relative;
                                            width: 100%;
                                            max-width: 920px;
                                            background: rgba(255, 255, 255, 0.1);
                                            backdrop-filter: blur(18px) saturate(1.3);
                                            -webkit-backdrop-filter: blur(18px) saturate(1.3);
                                            border: 1px solid rgba(255, 255, 255, 0.2);
                                            border-radius: 24px;
                                            overflow: hidden;
                                            display: flex;
                                            flex-direction: row;
                                            box-shadow:
                                                0 8px 40px rgba(0, 0, 0, 0.35),
                                                inset 0 1px 0 rgba(255, 255, 255, 0.15);
                                            z-index: 10;
                                            animation: containerAppear 0.8s cubic-bezier(0.16, 1, 0.3, 1) both;
                                        }

                                        .login-container::before {
                                            content: "";
                                            position: absolute;
                                            top: 0;
                                            left: 0;
                                            width: 100%;
                                            height: 100%;
                                            border-radius: 24px;
                                            padding: 2px;
                                            background: linear-gradient(90deg, #00d2ff, #3a7bd5, #00d2ff, #f5af19, #00d2ff);
                                            background-size: 400% 400%;
                                            animation: borderGlow 6s linear infinite;
                                            z-index: 11;
                                            mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
                                            -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
                                            mask-composite: exclude;
                                            -webkit-mask-composite: destination-out;
                                            pointer-events: none;
                                            box-sizing: border-box;
                                        }

                                        @keyframes borderGlow {
                                            0% {
                                                background-position: 0% 0%;
                                            }

                                            100% {
                                                background-position: 400% 0%;
                                            }
                                        }

                                        @keyframes containerAppear {
                                            from {
                                                opacity: 0;
                                                transform: translateY(30px) scale(0.96);
                                            }

                                            to {
                                                opacity: 1;
                                                transform: translateY(0) scale(1);
                                            }
                                        }

                                        /* ===== CỘT TRÁI ===== */
                                        .login-left,
                                        .login-right {
                                            flex: 1;
                                            padding: 40px;
                                            display: flex;
                                            flex-direction: column;
                                            justify-content: center;
                                            align-items: center;
                                        }

                                        .login-left {
                                            background: rgba(255, 255, 255, 0.05);
                                        }

                                        .login-left img {
                                            width: 240px;
                                            max-width: 90%;
                                            margin-bottom: 20px;
                                            animation: logoFloat 3s ease-in-out infinite;
                                            filter: drop-shadow(0 6px 16px rgba(0, 180, 255, 0.35));
                                        }

                                        @keyframes logoFloat {

                                            0%,
                                            100% {
                                                transform: translateY(0);
                                            }

                                            50% {
                                                transform: translateY(-8px);
                                            }
                                        }

                                        .info-section {
                                            display: flex;
                                            justify-content: space-between;
                                            margin-top: 20px;
                                            gap: 16px;
                                            width: 100%;
                                        }

                                        .info-box {
                                            flex: 1;
                                            background: rgba(255, 255, 255, 0.12);
                                            backdrop-filter: blur(10px);
                                            -webkit-backdrop-filter: blur(10px);
                                            border-radius: 12px;
                                            padding: 18px 14px;
                                            border: 1px solid rgba(255, 255, 255, 0.2);
                                            display: flex;
                                            justify-content: center;
                                            align-items: center;
                                            transition: transform 0.3s, box-shadow 0.3s, background 0.3s;
                                            cursor: pointer;
                                        }

                                        .info-box:hover {
                                            transform: translateY(-4px) scale(1.03);
                                            box-shadow: 0 8px 25px rgba(0, 180, 255, 0.35);
                                            background: rgba(0, 180, 255, 0.2);
                                        }

                                        .info-box h6 {
                                            font-weight: 600;
                                            margin: 0;
                                            color: #fff;
                                            text-align: center;
                                            font-size: 13px;
                                            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
                                        }

                                        /* ===== CỘT PHẢI ===== */
                                        .login-right {
                                            background: rgba(0, 40, 80, 0.25);
                                            color: white;
                                            align-items: stretch;
                                            border-left: 1px solid rgba(255, 255, 255, 0.1);
                                        }

                                        .login-right h3 {
                                            font-family: 'Roboto', sans-serif;
                                            font-weight: 700;
                                            margin-bottom: 6px;
                                            font-size: 22px;
                                            background: linear-gradient(135deg, #FFE066, #FF9F43, #FFE066);
                                            background-size: 200% auto;
                                            -webkit-background-clip: text;
                                            -webkit-text-fill-color: transparent;
                                            background-clip: text;
                                            animation: shimmerText 3s linear infinite;
                                        }

                                        @keyframes shimmerText {
                                            0% {
                                                background-position: 0% center;
                                            }

                                            100% {
                                                background-position: 200% center;
                                            }
                                        }

                                        .login-right p {
                                            font-size: 14px;
                                            margin-bottom: 22px;
                                            opacity: 0.85;
                                            color: rgba(255, 255, 255, 0.9);
                                        }

                                        /* ===== FORM INPUTS ===== */
                                        .form-label {
                                            color: rgba(255, 255, 255, 0.95);
                                            font-weight: 500;
                                            font-size: 14px;
                                            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
                                        }

                                        .form-control {
                                            border-radius: 12px;
                                            padding: 13px 16px;
                                            font-size: 15px;
                                            border: 2px solid rgba(255, 255, 255, 0.2);
                                            background: rgba(0, 20, 50, 0.45);
                                            color: #fff;
                                            backdrop-filter: blur(8px);
                                            -webkit-backdrop-filter: blur(8px);
                                            transition: all 0.3s ease;
                                        }

                                        .form-control::placeholder {
                                            color: rgba(255, 255, 255, 0.45);
                                        }

                                        .form-control:focus {
                                            border-color: #00d4ff;
                                            background: rgba(0, 20, 50, 0.6);
                                            color: #fff;
                                            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.3), 0 0 24px rgba(0, 212, 255, 0.2);
                                            transform: scale(1.01);
                                            outline: none;
                                        }

                                        .input-group-text {
                                            background: rgba(0, 20, 50, 0.45);
                                            border: 2px solid rgba(255, 255, 255, 0.2);
                                            border-left: none;
                                            color: rgba(255, 255, 255, 0.7);
                                            cursor: pointer;
                                            transition: all 0.3s;
                                            border-radius: 0 12px 12px 0 !important;
                                        }

                                        .input-group-text:hover {
                                            background: rgba(0, 212, 255, 0.2);
                                            color: #00d4ff;
                                        }

                                        .input-group .form-control {
                                            border-radius: 12px 0 0 12px !important;
                                        }

                                        /* ===== NÚT LOGIN ===== */
                                        .btn-login {
                                            background: linear-gradient(135deg, #FF9F43, #FFD700, #FF6348);
                                            background-size: 200% 200%;
                                            border: none;
                                            border-radius: 12px;
                                            padding: 14px;
                                            color: #1a1a2e;
                                            font-weight: 700;
                                            font-size: 16px;
                                            position: relative;
                                            overflow: hidden;
                                            transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.3s;
                                            box-shadow: 0 4px 18px rgba(255, 159, 67, 0.4);
                                            cursor: pointer;
                                        }

                                        .btn-login::before {
                                            content: '';
                                            position: absolute;
                                            top: 0;
                                            left: -100%;
                                            width: 100%;
                                            height: 100%;
                                            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
                                            transition: left 0.5s;
                                        }

                                        .btn-login:hover::before {
                                            left: 100%;
                                        }

                                        .btn-login:hover {
                                            transform: translateY(-3px) scale(1.03);
                                            box-shadow: 0 8px 30px rgba(255, 159, 67, 0.55);
                                        }

                                        .btn-login:active {
                                            transform: translateY(0) scale(0.98);
                                        }

                                        /* ===== REMEMBER / FORGOT ===== */
                                        .remember-forgot {
                                            display: flex;
                                            justify-content: space-between;
                                            align-items: center;
                                            font-size: 14px;
                                            color: rgba(255, 255, 255, 0.85);
                                        }

                                        .remember-forgot label {
                                            cursor: pointer;
                                        }

                                        .remember-forgot a {
                                            color: #FFE066;
                                            text-decoration: none;
                                            transition: color 0.3s;
                                        }

                                        .remember-forgot a:hover {
                                            color: #FFD700;
                                            text-decoration: underline;
                                        }

                                        .remember-forgot input[type="checkbox"] {
                                            accent-color: #00d4ff;
                                            margin-right: 6px;
                                        }

                                        /* ===== ALERT ===== */
                                        .alert-danger {
                                            background: rgba(220, 53, 69, 0.3);
                                            border: 1px solid rgba(220, 53, 69, 0.5);
                                            color: #ffbaba;
                                            backdrop-filter: blur(6px);
                                            border-radius: 10px;
                                        }

                                        /* ===== MODAL ===== */
                                        .modal-content {
                                            border-radius: 16px;
                                            background: rgba(255, 255, 255, 0.95);
                                            backdrop-filter: blur(10px);
                                        }

                                        .modal-body p {
                                            margin-bottom: 15px;
                                            line-height: 1.6;
                                            font-size: 16px;
                                            color: #374151;
                                        }

                                        .modal-body p b {
                                            color: #0077b6;
                                        }

                                        /* ===== RESPONSIVE ===== */
                                        @media (max-width: 768px) {
                                            body {
                                                padding: 15px 10px;
                                                align-items: flex-start;
                                            }

                                            .login-container {
                                                flex-direction: column !important;
                                                max-width: 100%;
                                                margin: 10px 0;
                                                border-radius: 18px;
                                                background: rgba(255, 255, 255, 0.12);
                                            }

                                            .login-container::before {
                                                border-radius: 18px;
                                                padding: 1px;
                                            }

                                            .login-left {
                                                padding: 25px 20px 15px;
                                            }

                                            .login-left img {
                                                width: 140px !important;
                                                margin-bottom: 10px;
                                            }

                                            .info-section {
                                                flex-direction: column !important;
                                                gap: 10px;
                                            }

                                            .login-right {
                                                padding: 25px 20px;
                                                border-left: none;
                                                border-top: 1px solid rgba(255, 255, 255, 0.1);
                                            }

                                            .login-right h3 {
                                                font-size: 20px;
                                                text-align: center;
                                            }

                                            .login-right p {
                                                text-align: center;
                                                font-size: 13px;
                                            }

                                            .form-control {
                                                font-size: 14px;
                                                padding: 12px;
                                            }

                                            .btn-login {
                                                padding: 12px;
                                                font-size: 15px;
                                            }

                                            .video-overlay {
                                                background: rgba(0, 15, 40, 0.45);
                                            }
                                        }
                                    </style>
                                </head>

                                <body>

                                    <!-- ====== VIDEO BACKGROUND ====== -->
                                    <video class="video-bg" autoplay muted loop playsinline>
                                        <source src="Img/sea.mp4" type="video/mp4">
                                    </video>
                                    <div class="video-overlay"></div>

                                    <!-- ====== TOGGLE PASSWORD ====== -->
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

                                    <!-- ====== LOGIN CONTAINER (Glassmorphism) ====== -->
                                    <div class="login-container">
                                        <div class="login-left">
                                            <img src="Img/logoics.png" alt="ICS Cyber Security Logo">
                                            <div class="info-section">
                                                <div class="info-box" data-bs-toggle="modal"
                                                    data-bs-target="#companyCultureModal">
                                                    <h6><i class="fas fa-building me-1"></i> Văn hóa doanh nghiệp ICS
                                                    </h6>
                                                </div>
                                                <div class="info-box" data-bs-toggle="modal"
                                                    data-bs-target="#websiteGuideModal">
                                                    <h6><i class="fas fa-book-open me-1"></i> Hướng dẫn sử dụng Website
                                                    </h6>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="login-right">
                                            <h3>🌊 Mùa Hè Vẫy Gọi Tới ICS 🌴</h3>
                                            <p>Chào mừng bạn trở lại – Hãy đăng nhập để tiếp tục!</p>

                                            <% if (!errorMsg.isEmpty()) { %>
                                                <div class="alert alert-danger py-2 mb-3" role="alert">
                                                    <%= errorMsg %>
                                                </div>
                                                <% } %>

                                                    <form action="login.jsp" method="post">
                                                        <div class="mb-3">
                                                            <label for="email" class="form-label"><i
                                                                    class="fas fa-envelope me-1"></i> Email</label>
                                                            <input type="text" class="form-control" id="email"
                                                                name="email" placeholder="Nhập email">
                                                        </div>
                                                        <div class="mb-3 position-relative">
                                                            <label for="password" class="form-label"><i
                                                                    class="fas fa-lock me-1"></i> Password</label>
                                                            <div class="input-group">
                                                                <input type="password" class="form-control"
                                                                    id="password" name="password"
                                                                    placeholder="Nhập mật khẩu">
                                                                <span class="input-group-text"
                                                                    onclick="togglePassword()" style="cursor: pointer;">
                                                                    <i class="fa fa-eye" id="togglePasswordIcon"></i>
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <div class="remember-forgot mb-3">
                                                            <div>
                                                                <input type="checkbox" id="remember"> <label
                                                                    for="remember">Remember me</label>
                                                            </div>
                                                            <a href="#">Forgot Password?</a>
                                                        </div>
                                                        <button type="submit" class="btn btn-login w-100">Login</button>
                                                    </form>
                                        </div>
                                    </div>

                                    <input type="hidden" id="loginSuccess" value="<%= loginSuccess %>">
                                    <input type="hidden" id="redirectUrl" value="<%= redirectUrl %>">

                                    <!-- Modal: Văn hóa doanh nghiệp -->
                                    <div class="modal fade" id="companyCultureModal" tabindex="-1"
                                        aria-labelledby="companyCultureModalLabel" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title" id="companyCultureModalLabel">Văn hóa ICS –
                                                        Nội quy cơ bản</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                                        aria-label="Close"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <p><b>1. Giờ giấc làm việc:</b> Làm việc từ Thứ 2 – Thứ 6, thời
                                                        gian: 08h00 – 17h00 (nghỉ trưa 12h00 – 13h00). Có mặt đúng giờ,
                                                        hạn chế đi muộn hoặc về sớm.</p>
                                                    <p><b>2. Trang phục:</b> Ăn mặc lịch sự, gọn gàng; ưu tiên áo sơ mi,
                                                        áo polo, quần/váy công sở.</p>
                                                    <p><b>3. Tác phong:</b> Giao tiếp văn minh, tôn trọng đồng nghiệp và
                                                        khách hàng. Thái độ chủ động, trách nhiệm.</p>
                                                    <p><b>4. An ninh – Bảo mật:</b> Không chia sẻ thông tin nội bộ ra
                                                        ngoài khi chưa được phép. Tuân thủ nghiêm ngặt quy định ATTT.
                                                    </p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Modal: Hướng dẫn sử dụng -->
                                    <div class="modal fade" id="websiteGuideModal" tabindex="-1"
                                        aria-labelledby="websiteGuideModalLabel" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title" id="websiteGuideModalLabel">Hướng dẫn sử
                                                        dụng Website</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                                        aria-label="Close"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <video controls width="100%">
                                                        <source src="http://localhost:8080/ICSS/Img/123a.mp4"
                                                            type="video/mp4">
                                                        Trình duyệt của bạn không hỗ trợ video.
                                                    </video>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <script
                                        src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
                                    <script>
                                        document.addEventListener("DOMContentLoaded", () => {
                                            const success = document.getElementById("loginSuccess").value === "true";
                                            const redirectUrl = document.getElementById("redirectUrl").value;
                                            if (success && redirectUrl) {
                                                window.location.href = redirectUrl;
                                            }
                                        });
                                    </script>
                                    <script>
                                        if ('serviceWorker' in navigator) {
                                            navigator.serviceWorker.register('sw.js', { scope: '/ICSS/' })
                                                .then(() => console.log('Service Worker registered'))
                                                .catch(err => console.error('Service Worker registration failed:', err));
                                        }
                                    </script>
                                    <script>
                                        window.__gim = window.__gim || {};
                                        window.__gim.licenseId = "586508500633432247";
                                        (function (c, o) {
                                            const e = [], n = {
                                                _handler: null, _version: "1.0", _queue: e, on: function () {
                                                    return e.push(["on", arguments]), n
                                                }, call: function () {
                                                    return e.push(["call", arguments]), n
                                                }, loadScript: function () {
                                                    const t = o.createElement("script");
                                                    t.async = !0, t.type = "text/javascript", t.src = "https://botsdk.stg.gim.beango.com/index.umd.js", o.head.appendChild(t)
                                                }
                                            };
                                            n.loadScript(), window.GIMBotTool = n
                                        })(window, document);
                                    </script>
                                </body>

                                </html>