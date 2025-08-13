<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="header d-flex align-items-center justify-content-between px-4 py-2">
    <div>
        <span class="fs-5 fw-bold" id="pageTitle"></span>
    </div>
    <div class="d-flex align-items-center gap-3">
        <div class="notification-bell position-relative" id="adminNotificationBell" style="cursor:pointer;">
            <i class="fa-solid fa-bell fs-4"></i>
            <span class="badge bg-danger rounded-pill" id="notiCount" style="font-size:0.7em;display:none;position:absolute;top:0;right:0;">0</span>
        </div>
        <!-- Dropdown admin menu -->
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle" id="adminDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                <%
                    String userName = (String) session.getAttribute("userName");
                    if (userName == null || userName.isEmpty()) {
                        userName = "Ban quản lý"; // fallback nếu chưa đăng nhập
                    }
                %>
                <img src="https://ui-avatars.com/api/?name=Admin" alt="avatar" class="avatar">
                <span class="fw-semibold ms-2"><%= userName %></span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="adminDropdown">
                <li><a class="dropdown-item" href="./apiHoso"><i class="fa-solid fa-user-circle me-2"></i>Hồ sơ cá nhân</a></li>
                <li><a class="dropdown-item" href="admin_change_password.jsp"><i class="fa-solid fa-key me-2"></i>Đổi mật khẩu</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="logout.jsp"><i class="fa-solid fa-sign-out-alt me-2"></i>Đăng xuất</a></li>
            </ul>
        </div>
    </div>
</div>

<script>
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
                // Trang danh sách thông báo (servlet bạn đã dùng)
                window.location.href = './apiThongbao';
            };
        }
    })();

    // ====== CẬP NHẬT SỐ THÔNG BÁO CHƯA ĐỌC TRÊN CHUÔNG ======
    (function () {
        var badge = document.getElementById('notiCount');
        if (!badge)
            return; // không có badge thì bỏ qua

        function setBadge(n) {
            // n là số chưa đọc (int)
            if (isNaN(n) || n < 0)
                n = 0;
            badge.textContent = n;
            // Ẩn badge nếu = 0 (giữ nguyên CSS, chỉ thay display)
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
                    } else {
                        // lỗi thì không thay đổi
                    }
                }
            };
            xhr.send();
        }

        // Lộ ra hàm global để trang notification gọi lại sau khi mark read
        window.updateNotifyBadgeCount = fetchUnreadCount;

        // Gọi khi header load
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', fetchUnreadCount);
        } else {
            fetchUnreadCount();
        }

        // (tuỳ chọn) cập nhật định kỳ mỗi 60 giây
        // setInterval(fetchUnreadCount, 60000);
    })();
</script>

