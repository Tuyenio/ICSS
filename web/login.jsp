<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="controller.KNCSDL" %>
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
                .login-container {
                    flex-direction: column;
                }
                .login-left, .login-right {
                    padding: 20px;
                }
                .login-left img {
                    width: 200px;
                }
                .info-section {
                    flex-direction: column;
                }
            }
        </style>
        <script>
            if ('serviceWorker' in navigator) {
                navigator.serviceWorker.register('sw.js')
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
    </head>
    <body>
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
