<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="vi">

    <%!
        // Escape HTML đơn giản
        private String esc(Object o) {
            if (o == null) return "";
            String s = String.valueOf(o);
            return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                    .replace("\"","&quot;").replace("'","&#39;");
        }
    %>
    <head>
        <meta charset="UTF-8">
        <title>Thông báo quản lý</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body {
                background: #f4f6fa;
            }

            .sidebar {
                min-height: 100vh;
                background: linear-gradient(180deg, #23272f 0%, #343a40 100%);
                color: #fff;
                width: 240px;
                transition: width 0.2s;
                box-shadow: 2px 0 8px #0001;
                z-index: 10;
                position: fixed;
                top: 0;
                left: 0;
                bottom: 0;
            }

            .sidebar .sidebar-title {
                font-size: 1.7rem;
                font-weight: bold;
                letter-spacing: 1px;
                color: #0dcaf0;
                background: #23272f;
            }

            .sidebar-nav {
                padding: 0;
                margin: 0;
                list-style: none;
            }

            .sidebar-nav li {
                margin-bottom: 2px;
            }

            .sidebar-nav a {
                color: #fff;
                text-decoration: none;
                display: flex;
                align-items: center;
                gap: 14px;
                padding: 14px 28px;
                border-radius: 8px;
                font-size: 1.08rem;
                font-weight: 500;
                transition: background 0.15s, color 0.15s;
            }

            .sidebar-nav a.active,
            .sidebar-nav a:hover {
                background: #0dcaf0;
                color: #23272f;
            }

            .sidebar-nav a .fa-solid {
                width: 26px;
                text-align: center;
                font-size: 1.25rem;
            }

            @media (max-width: 992px) {
                .sidebar {
                    width: 60px;
                }

                .sidebar .sidebar-title {
                    font-size: 1.1rem;
                    padding: 12px 0;
                }

                .sidebar-nav a span {
                    display: none;
                }

                .sidebar-nav a {
                    justify-content: center;
                    padding: 14px 0;
                }
            }

            .header {
                background: #fff;
                border-bottom: 1px solid #dee2e6;
                min-height: 64px;
                box-shadow: 0 2px 8px #0001;
                margin-left: 240px;
            }

            .avatar {
                width: 38px;
                height: 38px;
                border-radius: 50%;
                object-fit: cover;
            }

            .main-box {
                background: #fff;
                border-radius: 14px;
                box-shadow: 0 2px 12px #0001;
                padding: 32px 24px;
                margin: 0 auto;
                max-width: 800px;
            }

            .main-content {
                padding: 36px 0 24px 0;
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: flex-start;
                margin-left: 240px;
            }


            @media (max-width: 992px) {
                .main-content {
                    margin-left: 60px;
                }
            }

            @media (max-width: 600px) {
                .main-box {
                    padding: 8px 0;
                }

                .main-content {
                    padding: 8px 0;
                }
            }

            .list-group-item {
                border: none;
                border-bottom: 1px solid #e9ecef;
                padding: 18px 24px 14px 24px;
                transition: background 0.15s;
                background: transparent;
                font-family: inherit;
            }

            .list-group-item:last-child {
                border-bottom: none;
            }

            .list-group-item:hover {
                background: #f1f3f5;
            }

            .badge-status {
                font-size: 0.95em;
                min-width: 80px;
                text-align: center;
            }

            .fw-semibold {
                font-weight: 600 !important;
            }

            .text-muted.small {
                font-size: 0.97em;
            }

            h3.mb-0 {
                font-weight: 700;
                letter-spacing: 0.5px;
            }

            .d-flex.align-items-center>div>i {
                vertical-align: middle;
                font-size: 1.15em;
            }

            .badge {
                vertical-align: middle;
            }

            @media (max-width: 900px) {
                .main-box {
                    padding: 18px 4px;
                }
            }

            @media (max-width: 600px) {
                .main-box {
                    padding: 8px 0;
                }

                .main-content {
                    padding: 8px 0;
                }

                .list-group-item {
                    padding: 12px 8px 10px 8px;
                }

                h3.mb-0 {
                    font-size: 1.2rem;
                }
            }

            .badge-status {
                box-shadow: 0 1px 4px #0001;
                border: 1px solid #e9ecef;
            }

            .list-group-item .badge.bg-danger,
            .list-group-item .badge.bg-warning {
                animation: pulse 1.2s infinite alternate;
            }

            @keyframes pulse {
                0% {
                    filter: brightness(1);
                }

                100% {
                    filter: brightness(1.2);
                }
            }

            .sidebar i {
                font-family: "Font Awesome 6 Free" !important;
                font-weight: 900;
            }
        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-bell me-2"></i>Thông báo quản lý';
        </script>
    </head>

    <body>
        <div class="d-flex">
            <!-- Sidebar -->
            <nav class="sidebar p-0">
                <div class="sidebar-title text-center py-4 border-bottom border-secondary" style="cursor:pointer;"
                     onclick="location.href = 'index.jsp'">
                    <i class="fa-solid fa-people-group me-2"></i>ICS
                </div>
                <ul class="sidebar-nav mt-3">
                    <li>
                        <a href="index.jsp"><i class="fa-solid fa-chart-line"></i><span>Dashboard</span></a>
                    </li>
                    <li>
                        <a href="./dsnhanvien"><i class="fa-solid fa-users"></i><span>Nhân sự</span></a>
                    </li>
                    <li>
                        <a href="./dsCongviec"><i class="fa-solid fa-tasks"></i><span>Công việc</span></a>
                    </li>
                    <li>
                        <a href="./dsPhongban"><i class="fa-solid fa-building"></i><span>Phòng ban</span></a>
                    </li>
                    <li>
                        <a href="attendance.jsp"><i class="fa-solid fa-calendar-check"></i><span>Chấm công</span></a>
                    </li>
                    <li>
                        <a href="report.jsp"><i class="fa-solid fa-chart-bar"></i><span>Báo cáo</span></a>
                    </li>
                    <!-- <li>
                        <a href="notification.jsp" class="active"><i class="fa-solid fa-bell"></i><span>Thông
                                báo</span></a>
                    </li> -->
                </ul>
            </nav>
            <!-- Main -->
            <div class="flex-grow-1">
                <%@ include file="header.jsp" %>
                <div class="main-content">
                    <div class="main-box mb-3">
                        <h3 class="mb-0"><i class="fa-solid fa-bell me-2"></i>Thông báo quản lý</h3>
                        <ul class="list-group" id="notificationList">
                            <%
                                List ds = (List) request.getAttribute("dsThongBao");
                                if (ds != null && !ds.isEmpty()) {
                                    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                                    for (Object it : ds) {
                                        Map row = (Map) it;
                                        String tieuDe = esc(row.get("tieu_de"));
                                        String noiDung = esc(row.get("noi_dung"));
                                        String loai = esc(row.get("loai_thong_bao"));
                                        Boolean daDoc = (Boolean) row.get("da_doc");
                                        java.util.Date ngayTao = (java.util.Date) row.get("ngay_tao");
                                        String timeStr = (ngayTao != null) ? fmt.format(ngayTao) : "";
                
                                        // icon theo loại (nếu chưa chắc dữ liệu, dùng chuông mặc định)
                                        String iconClass = "fa-regular fa-bell text-primary";
                                        if (loai != null) {
                                            String l = loai.toLowerCase();
                                            if (l.contains("nhân") || l.contains("nhan")) iconClass = "fa-solid fa-user-plus text-success";
                                            else if (l.contains("phòng") || l.contains("phong")) iconClass = "fa-solid fa-building text-secondary";
                                            else if (l.contains("báo cáo") || l.contains("bao cao")) iconClass = "fa-solid fa-chart-line text-primary";
                                            else if (l.contains("hệ thống") || l.contains("he thong")) iconClass = "fa-solid fa-info-circle text-primary";
                                        }
                            %>
                            <%
                        // --- bổ sung ngay trước <li> ---
                        int idTB = ((Number) row.get("id")).intValue();
                        String itemClass = (daDoc != null && daDoc) ? "is-read" : "is-unread";
                            %>
                            <li class="list-group-item <%= itemClass %>" data-id="<%= idTB %>">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <i class="<%= iconClass %> me-2"></i>
                                        <span class="fw-semibold"><%= tieuDe %></span>
                                        <div class="text-muted small">
                                            <%= noiDung %><br>
                                            <span class="badge bg-light text-dark me-1"><%= loai %></span>
                                            <i class="fa-regular fa-clock me-1"></i><%= esc(timeStr) %>
                                        </div>
                                    </div>
                                    <span class="badge <%= (daDoc != null && daDoc) ? "bg-success" : "bg-danger" %> rounded-pill badge-status">
                                        <%= (daDoc != null && daDoc) ? "Đã đọc" : "Mới" %>
                                    </span>
                                </div>
                            </li>

                            <%
                                    } // end for
                                } else {
                            %>
                            <li class="list-group-item text-center text-muted">Chưa có thông báo</li>
                                <%
                                    }
                                %>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                         (function () {
                             var list = document.getElementById('notificationList');
                             if (!list)
                                 return;

                             list.addEventListener('click', function (e) {
                                 var li = e.target.closest('li.list-group-item');
                                 if (!li)
                                     return;

                                 if (li.classList.contains('is-unread')) {
                                     var id = li.getAttribute('data-id');
                                     if (!id)
                                         return;

                                     var xhr = new XMLHttpRequest();
                                     xhr.open('POST', '<%= request.getContextPath() %>/ApiThongbaoMarkRead', true);
                                     xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');

                                     xhr.onreadystatechange = function () {
                                         if (xhr.readyState === 4) {
                                             console.log('MarkRead status=', xhr.status, 'resp=', (xhr.responseText || '').slice(0, 120));
                                             if (xhr.status >= 200 && xhr.status < 300) {
                                                 var body = (xhr.responseText || '').trim();
                                                 if (body === 'OK') {
                                                     li.classList.remove('is-unread');
                                                     li.classList.add('is-read');
                                                     var badge = li.querySelector('.badge-status');
                                                     if (badge) {
                                                         badge.classList.remove('bg-danger');
                                                         badge.classList.add('bg-success');
                                                         badge.textContent = 'Đã đọc';
                                                     }
                                                     if (window.updateNotifyBadgeCount)
                                                         window.updateNotifyBadgeCount();
                                                 } else {
                                                     // Nếu body KHÔNG phải 'OK', khả năng bị redirect sang trang đăng nhập (HTML)
                                                     console.warn('MarkRead returned non-OK body.');
                                                 }
                                             } else {
                                                 console.error('MarkRead HTTP error:', xhr.status);
                                             }
                                         }
                                     };

                                     xhr.send('id=' + encodeURIComponent(id));
                                 }
                             });
                         })();
        </script>
    </body>

</html>