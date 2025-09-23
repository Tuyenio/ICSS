<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="header d-flex align-items-center justify-content-between px-4 py-2 shadow-sm"
     style="min-height:72px; position:sticky; top:0; z-index:999; margin-left:260px;
            background: linear-gradient(135deg,
                rgba(255, 255, 255, 0.25) 0%,
                rgba(255, 255, 255, 0.15) 100%
            );
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);">
    <div class="d-flex align-items-center gap-3">
        <span class="fs-4 fw-bold" id="pageTitle"
              style="background: linear-gradient(135deg, #667eea, #764ba2);
                     -webkit-background-clip: text;
                     background-clip: text;
                     -webkit-text-fill-color: transparent;
                     text-shadow: 0 0 30px rgba(102, 126, 234, 0.3);"></span>
    </div>
    <div class="d-flex align-items-center gap-4">
        <!-- Notification Bell -->
        <div class="notification-bell position-relative" id="notificationBell"
             style="cursor:pointer; padding: 12px; border-radius: 50%;
                    background: rgba(255, 255, 255, 0.1);
                    backdrop-filter: blur(10px);
                    transition: all 0.3s ease;
                    border: 1px solid rgba(255, 255, 255, 0.2);"
             onmouseover="this.style.background='rgba(102, 126, 234, 0.2)'; this.style.transform='scale(1.05)'"
             onmouseout="this.style.background='rgba(255, 255, 255, 0.1)'; this.style.transform='scale(1)';">
            <i class="fa-solid fa-bell fs-4" style="color: #667eea;"></i>
            <span class="badge rounded-pill" id="notiCount"
                  style="font-size:0.7em; display:none; position:absolute; top:5px; right:5px;
                         background: linear-gradient(45deg, #ff6b6b, #ee5a24);
                         animation: pulse 2s infinite;">0</span>
        </div>
        <!-- Dropdown user menu -->
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle"
               id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false"
               style="padding: 8px 16px; border-radius: 25px;
                      background: rgba(255, 255, 255, 0.15);
                      backdrop-filter: blur(10px);
                      border: 1px solid rgba(255, 255, 255, 0.2);
                      transition: all 0.3s ease;"
               onmouseover="this.style.background='rgba(255, 255, 255, 0.25)'; this.style.transform='translateY(-2px)'"
               onmouseout="this.style.background='rgba(255, 255, 255, 0.15)'; this.style.transform='translateY(0)';">
                <%
                    String userName = (String) session.getAttribute("userName");
                    String useAvatar = (String) session.getAttribute("avatar");
                    if (userName == null || userName.isEmpty()) {
                        userName = "Người dùng";
                    }
                %>
                <img src="<%= useAvatar %>" alt="avatar" class="avatar"
                     style="width:42px; height:42px; border-radius:50%; object-fit:cover;
                            border: 2px solid rgba(255, 255, 255, 0.3);
                            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);">
                <span class="fw-bold ms-2" style="color: #334155; text-shadow: 0 1px 2px rgba(255, 255, 255, 0.8);"><%= userName %></span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown"
                style="background: rgba(255, 255, 255, 0.95);
                       backdrop-filter: blur(20px);
                       border: 1px solid rgba(255, 255, 255, 0.2);
                       border-radius: 16px;
                       box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
                       padding: 8px;">
                <li><a class="dropdown-item" href="./apiHoso"
                       style="border-radius: 12px; padding: 12px 16px; transition: all 0.3s ease;"
                       onmouseover="this.style.background='rgba(102, 126, 234, 0.1)'"
                       onmouseout="this.style.background='transparent'">
                    <i class="fa-solid fa-user-circle me-2" style="color: #667eea;"></i>Hồ sơ cá nhân</a></li>
                <li><a class="dropdown-item" href="user_change_password.jsp"
                       style="border-radius: 12px; padding: 12px 16px; transition: all 0.3s ease;"
                       onmouseover="this.style.background='rgba(102, 126, 234, 0.1)'"
                       onmouseout="this.style.background='transparent'">
                    <i class="fa-solid fa-key me-2" style="color: #667eea;"></i>Đổi mật khẩu</a></li>
                <li><hr class="dropdown-divider" style="margin: 8px 0; border-color: rgba(0, 0, 0, 0.1);"></li>
                <li><a class="dropdown-item text-danger" href="logout.jsp"
                       style="border-radius: 12px; padding: 12px 16px; transition: all 0.3s ease;"
                       onmouseover="this.style.background='rgba(255, 107, 107, 0.1)'"
                       onmouseout="this.style.background='transparent'">
                    <i class="fa-solid fa-sign-out-alt me-2"></i>Đăng xuất</a></li>
            </ul>
        </div>
    </div>
</div>

<script>
    // PREMIUM HEADER ANIMATIONS
    document.addEventListener('DOMContentLoaded', function() {
        // Pulse animation for notification badge
        const style = document.createElement('style');
        style.textContent = `
            @keyframes pulse {
                0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(255, 107, 107, 0.7); }
                70% { transform: scale(1.05); box-shadow: 0 0 0 10px rgba(255, 107, 107, 0); }
                100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(255, 107, 107, 0); }
            }

            /* Responsive header */
            @media (max-width: 1200px) {
                .header { margin-left: 240px !important; }
            }

            @media (max-width: 992px) {
                .header {
                    margin-left: 76px !important;
                    transition: margin-left 0.3s ease;
                }
                .header:hover { margin-left: 260px !important; }
            }

            @media (max-width: 576px) {
                .header {
                    margin-left: 60px !important;
                    padding: 0 16px !important;
                }
                .header:hover { margin-left: 240px !important; }

                .header #pageTitle {
                    font-size: 1.2rem !important;
                }

                .header .dropdown a span {
                    display: none;
                }

                .header .dropdown a img {
                    width: 36px !important;
                    height: 36px !important;
                }
            }
        `;
        document.head.appendChild(style);
    });

    // Đặt tiêu đề động cho từng trang
    if (typeof PAGE_TITLE !== 'undefined') {
        var pageTitleEl = document.getElementById('pageTitle');
        if (pageTitleEl)
            pageTitleEl.innerHTML = PAGE_TITLE;
    }

    // Nhảy sang trang thông báo khi bấm chuông
    (function () {
        var bell = document.getElementById('notificationBell');
        if (bell) {
            bell.onclick = function () {
                window.location.href = './apiThongbao';
            };
        }
    })();

    // ====== CẬP NHẬT SỐ THÔNG BÁO CHƯA ĐỌC TRÊN CHUÔNG ======
    (function () {
        var badge = document.getElementById('notiCount');
        if (!badge)
            return;

        function setBadge(n) {
            if (isNaN(n) || n < 0)
                n = 0;
            badge.textContent = n;
            badge.style.display = (n > 0) ? 'inline-block' : 'none';
        }

        function fetchUnreadCount() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', '<%= request.getContextPath() %>/ApiThongbaoUnreadCount', true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        var n = parseInt(xhr.responseText, 10);
                        setBadge(isNaN(n) ? 0 : n);
                    }
                }
            };
            xhr.send();
        }

        window.updateNotifyBadgeCount = fetchUnreadCount;

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', fetchUnreadCount);
        } else {
            fetchUnreadCount();
        }
    })();
</script>
