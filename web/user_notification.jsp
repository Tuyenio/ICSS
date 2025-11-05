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
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Thông báo</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            html, body {
                font-family: 'Inter', 'Roboto', Arial, sans-serif !important;
                background: #f4f6fa;
                color: #23272f;
            }
            /* Responsive styles for included sidebar */
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
                margin-left: 260px;
            }
            .avatar {
                width: 38px;
                height: 38px;
                border-radius: 50%;
                object-fit: cover;
            }
            @media (max-width: 1200px) {
                .main-content {
                    margin-left: 240px;
                }
            }
            @media (max-width: 992px) {
                .main-content {
                    margin-left: 76px;
                }
            }
            @media (max-width: 576px) {
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
            /* Cải thiện icon và badge căn giữa */
            .d-flex.align-items-center > div > i {
                vertical-align: middle;
                font-size: 1.15em;
            }
            .badge {
                vertical-align: middle;
            }
            /* Responsive nâng cao */
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
            /* Hiệu ứng badge trạng thái */
            .badge-status {
                box-shadow: 0 1px 4px #0001;
                border: 1px solid #e9ecef;
            }
            /* Hiệu ứng hover cho từng thông báo chưa đọc */
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
        </style>
        <script>
            var USER_PAGE_TITLE = '<i class="fa-solid fa-bell me-2"></i>Thông báo';
        </script>
    </head>
    <body>
        <%@ include file="sidebarnv.jsp" %>
        <%@ include file="user_header.jsp" %>
        <div class="main-content">
            <div class="main-box mb-3">
                <h3 class="mb-0"><i class="fa-solid fa-bell me-2"></i>Thông báo</h3>
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
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="<%= request.getContextPath() %>/scripts/user_noti.obf.js?v=20251105"></script>
    </body>
</html>