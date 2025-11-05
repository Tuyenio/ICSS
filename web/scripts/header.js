
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
        var bell = document.getElementById('adminNotificationBell');
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