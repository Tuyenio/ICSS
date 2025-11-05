<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Quản lý Công việc</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.ckeditor.com/4.22.1/standard/ckeditor.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            html,
            body {
                font-family: 'Inter', 'Roboto', Arial, sans-serif !important;
                background: #f4f6fa;
                color: #23272f;
            }

            .sidebar,
            .sidebar * {
                font-family: inherit !important;
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
                font-family: inherit !important;
            }

            .sidebar-nav a.active,
            .sidebar-nav a:hover {
                background: #0dcaf0;
                color: #23272f;
            }

            .sidebar-nav a .fa-solid,
            .sidebar-nav a .fa-regular,
            .sidebar-nav a .fa {
                width: 26px;
                text-align: center;
                font-size: 1.25rem;
                min-width: 26px;
            }

            .sidebar-nav a span {
                display: inline;
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

            .main-content {
                padding: 36px 36px 24px 36px;
                min-height: 100vh;
                margin-left: 240px;
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
            }

            .kanban-board {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 20px;
                min-height: 420px;
                margin-bottom: 32px;
            }

            .kanban-col {
                background: #f8fafd;
                border-radius: 18px;
                padding: 18px 16px;
                box-shadow: 0 2px 12px #0001;
                border: 2px solid #e9ecef;
                display: flex;
                flex-direction: column;
                min-height: 420px;
                transition: box-shadow 0.2s, border-color 0.2s;
            }

            .kanban-col:hover {
                box-shadow: 0 6px 24px #0002;
                border-color: #0dcaf0;
            }

            .kanban-col h5 {
                font-size: 1.15rem;
                font-weight: bold;
                margin-bottom: 18px;
                display: flex;
                align-items: center;
                gap: 8px;
                letter-spacing: 0.5px;
            }

            .kanban-col .kanban-add-btn {
                width: 100%;
                margin-bottom: 12px;
                border-radius: 20px;
                font-size: 0.98rem;
            }

            .kanban-task {
                background: #fff;
                border-radius: 12px;
                padding: 14px 12px;
                margin-bottom: 16px;
                box-shadow: 0 1px 8px #0001;
                cursor: pointer;
                border-left: 5px solid #0dcaf0;
                transition: box-shadow 0.15s, border-color 0.15s;
                position: relative;
            }

            .kanban-task:hover {
                box-shadow: 0 4px 16px #0d6efd33;
                border-color: #0d6efd;
            }

            .kanban-task .task-title {
                font-weight: 600;
                font-size: 1.08rem;
                margin-bottom: 2px;
            }

            .kanban-task .task-meta {
                font-size: 0.97em;
                color: #888;
                margin-bottom: 4px;
            }

            .kanban-task .task-priority,
            .kanban-task .task-status {
                display: inline-block;
                margin-right: 6px;
                font-size: 0.95em;
            }

            .kanban-task .progress {
                height: 7px;
                margin: 7px 0;
                border-radius: 6px;
            }

            .kanban-task .task-actions {
                position: absolute;
                top: 10px;
                right: 10px;
                display: flex;
                gap: 4px;
            }

            /* Khi task đang được nhắc nhở */
            .kanban-task.task--alert {
                border-left-color: #dc3545;                 /* đỏ */
                animation: taskBlink 1.1s ease-in-out infinite;
            }

            /* Không đổi sang xanh khi hover nếu đang alert */
            .kanban-task.task--alert:hover {
                border-color: #dc3545;
            }

            /* Hiệu ứng nhấp nháy đỏ (viền + glow + chút nền) */
            @keyframes taskBlink {
                0%, 100% {
                    box-shadow: 0 1px 8px #0001, 0 0 0 0 rgba(220,53,69,0);
                    background-image: none;
                }
                50% {
                    box-shadow: 0 1px 8px #0001, 0 0 0 4px rgba(220,53,69,0.18),
                        0 6px 18px rgba(220,53,69,0.35);
                    background-image: linear-gradient(0deg, rgba(220,53,69,0.06), rgba(220,53,69,0));
                }
            }

            .kanban-col.not-started {
                border-top: 5px solid #adb5bd;
            }

            .kanban-col.in-progress {
                border-top: 5px solid #ffc107;
            }

            .kanban-col.completed {
                border-top: 5px solid #198754;
            }

            .kanban-col.late {
                border-top: 5px solid #dc3545;
            }

            .kanban-col.not-started h5 {
                color: #6c757d;
            }

            .kanban-col.in-progress h5 {
                color: #ffc107;
            }

            .kanban-col.completed h5 {
                color: #198754;
            }

            .kanban-col.late h5 {
                color: #dc3545;
            }

            @media (max-width: 1200px) {
                .kanban-board {
                    gap: 12px;
                }

                .kanban-col {
                    min-width: 220px;
                }
            }

            @media (max-width: 900px) {
                .kanban-board {
                    flex-direction: column;
                    gap: 18px;
                }

                .kanban-col {
                    min-width: 100%;
                    max-width: 100%;
                }
            }

            @media (max-width: 768px) {
                .main-box {
                    padding: 10px 2px;
                }

                .header {
                    margin-left: 60px;
                }

                .main-content {
                    padding: 10px 2px;
                }
            }

            .sidebar i {
                font-family: "Font Awesome 6 Free" !important;
                font-weight: 900;
            }

            /* REMINDER BELL NOTIFICATION */
            .task-reminder-bell {
                position: absolute;
                top: 6px;
                right: 6px;
                background: linear-gradient(135deg, #f59e0b, #fbbf24);
                color: white;
                border-radius: 50%;
                width: 24px;
                height: 24px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 0.75rem;
                box-shadow: 0 2px 8px rgba(245, 158, 11, 0.4);
                z-index: 5;
                opacity: 0.95;
                animation: bellPulse 2s infinite, bellBlink 1.2s infinite alternate;
            }

            /* Hiệu ứng rung nhẹ */
            @keyframes bellPulse {
                0%, 100% {
                    transform: rotate(0deg);
                }
                25% {
                    transform: rotate(10deg);
                }
                50% {
                    transform: rotate(-10deg);
                }
                75% {
                    transform: rotate(5deg);
                }
            }

            /* Hiệu ứng nhấp nháy ánh sáng */
            @keyframes bellBlink {
                0% {
                    box-shadow: 0 0 8px rgba(245, 158, 11, 0.6);
                    filter: brightness(0.9);
                }
                50% {
                    box-shadow: 0 0 16px rgba(245, 158, 11, 1);
                    filter: brightness(1.2);
                }
                100% {
                    box-shadow: 0 0 8px rgba(245, 158, 11, 0.6);
                    filter: brightness(0.9);
                }
            }

            /* Ẩn chuông khi task có class 'reminder-read' */
            .kanban-task.reminder-read .task-reminder-bell {
                display: none;
            }

            /* TASK NAVIGATION TABS */
            .task-nav-tabs .nav-link {
                background: transparent;
                border: 2px solid transparent;
                border-radius: 25px;
                color: #64748b;
                font-weight: 500;
                padding: 8px 16px;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
                overflow: hidden;
                font-size: 0.95rem;
            }

            .task-nav-tabs .nav-link:before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
                transition: left 0.5s;
            }

            .task-nav-tabs .nav-link:hover:before {
                left: 100%;
            }

            .task-nav-tabs .nav-link:hover {
                color: #0dcaf0;
                border-color: rgba(13, 202, 240, 0.3);
                background: rgba(13, 202, 240, 0.05);
                transform: translateY(-2px);
            }

            .task-nav-tabs .nav-link.active {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                border-color: #0dcaf0;
                color: white;
                box-shadow: 0 4px 15px rgba(13, 202, 240, 0.4);
                transform: translateY(-1px);
            }

            .task-nav-tabs .nav-link.active:hover {
                background: linear-gradient(135deg, #4f46e5, #0dcaf0);
                transform: translateY(-3px);
                box-shadow: 0 6px 20px rgba(13, 202, 240, 0.5);
            }

            .task-nav-tabs .nav-link i {
                font-size: 0.9rem;
            }

            /* ARCHIVED & DELETED TASKS STYLING */
            .archived-col, .deleted-col {
                border-top: 5px solid #f59e0b !important;
                background: linear-gradient(145deg, #fffbeb, #fef3c7);
            }

            .deleted-col {
                border-top-color: #ef4444 !important;
                background: linear-gradient(145deg, #fef2f2, #fee2e2);
            }

            .archived-col h5 {
                color: #92400e;
            }

            .deleted-col h5 {
                color: #dc2626;
            }

            .archived-task, .deleted-task {
                background: white;
                border-left-color: #f59e0b;
                opacity: 0.85;
                transition: all 0.2s ease;
            }

            .deleted-task {
                border-left-color: #ef4444;
            }

            .archived-task:hover, .deleted-task:hover {
                opacity: 1;
                transform: translateY(-2px);
            }

            /* Cân đối layout Kanban */

            @media (max-width: 1200px) {
                .kanban-board {
                    grid-template-columns: repeat(2, 1fr);
                    gap: 16px;
                }
            }

            @media (max-width: 768px) {
                .kanban-board {
                    grid-template-columns: 1fr;
                    gap: 12px;
                }

                .task-nav-tabs {
                    flex-wrap: wrap;
                    gap: 8px;
                }

                .task-nav-tabs .nav-link {
                    padding: 6px 12px;
                    font-size: 0.9rem;
                }
            }
        </style>
        <script>
            var USER_PAGE_TITLE = '<i class="fa-solid fa-tasks me-2"></i>Công việc của tôi';
        </script>
    </head>

    <body>
        <%@ include file="sidebarnv.jsp" %>
        <%@ include file="user_header.jsp" %>
        <div class="main-content">
            <div class="main-box mb-3">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3 class="mb-0"><i class="fa-solid fa-tasks me-2"></i>Công việc của tôi</h3>

                    <!-- Tab Navigation -->
                    <ul class="nav nav-pills task-nav-tabs" id="taskViewTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="active-tasks-tab" data-bs-toggle="pill" 
                                    data-bs-target="#active-tasks" type="button" role="tab">
                                <i class="fa-solid fa-play me-1"></i>Hoạt động
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="archived-tasks-tab" data-bs-toggle="pill" 
                                    data-bs-target="#archived-tasks" type="button" role="tab">
                                <i class="fa-solid fa-archive me-1"></i>Lưu trữ
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="deleted-tasks-tab" data-bs-toggle="pill" 
                                    data-bs-target="#deleted-tasks" type="button" role="tab">
                                <i class="fa-solid fa-trash me-1"></i>Thùng rác
                            </button>
                        </li>
                    </ul>
                </div>
                <div class="row mb-2 g-2">
                    <div class="col-md-3">
                        <input type="text" name="keyword" class="form-control" placeholder="Tìm kiếm tên công việc...">
                    </div>
                    <div class="col-md-3">
                        <select class="form-select" name="trangThai">
                            <option value="">Tất cả trạng thái</option>
                            <option value="Chưa bắt đầu">Chưa bắt đầu</option>
                            <option value="Đang thực hiện">Đang thực hiện</option>
                            <option value="Đã hoàn thành">Đã hoàn thành</option>
                            <option value="Trễ hạn">Trễ hạn</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <button class="btn btn-outline-secondary w-100 rounded-pill" id="btnFilter"><i
                                class="fa-solid fa-filter"></i> Lọc</button>
                    </div>
                </div>
                <!-- Tab Content -->
                <div class="tab-content" id="taskViewTabContent">
                    <!-- Tab Công việc hoạt động -->
                    <div class="tab-pane fade show active" id="active-tasks" role="tabpanel">
                        <%
                            List<Map<String, Object>> taskList = (List<Map<String, Object>>) request.getAttribute("taskList");

                            Map<String, String> trangThaiLabels = new LinkedHashMap<>();
                            trangThaiLabels.put("Chưa bắt đầu", "Chưa bắt đầu");
                            trangThaiLabels.put("Đang thực hiện", "Đang thực hiện");
                            trangThaiLabels.put("Đã hoàn thành", "Đã hoàn thành");
                            trangThaiLabels.put("Trễ hạn", "Trễ hạn");

                            Map<String, String> badgeClass = new HashMap<>();
                            badgeClass.put("Chưa bắt đầu", "bg-secondary");
                            badgeClass.put("Đang thực hiện", "bg-warning text-dark");
                            badgeClass.put("Đã hoàn thành", "bg-success");
                            badgeClass.put("Trễ hạn", "bg-danger");

                            Map<String, String> priorityBadge = new HashMap<>();
                            priorityBadge.put("Cao", "bg-danger");
                            priorityBadge.put("Trung bình", "bg-warning text-dark");
                            priorityBadge.put("Thấp", "bg-success");
                        %>

                        <div class="kanban-board">
                            <% for (String status : trangThaiLabels.keySet()) { 
                                   String columnClass = "";
                                   if ("Chưa bắt đầu".equals(status)) columnClass = "not-started";
                                   else if ("Đang thực hiện".equals(status)) columnClass = "in-progress";
                                   else if ("Đã hoàn thành".equals(status)) columnClass = "completed";
                                   else if ("Trễ hạn".equals(status)) columnClass = "late";
                            %>
                            <div class="kanban-col <%= columnClass %>">
                                <% if ("Chưa bắt đầu".equals(status)) { %>
                                <h5><i class="fa-solid fa-hourglass-start"></i> <%= trangThaiLabels.get(status) %></h5>
                                <% }else if("Đang thực hiện".equals(status)) { %>
                                <h5><i class="fa-solid fa-spinner"></i> <%= trangThaiLabels.get(status) %></h5>
                                <% }else if("Đã hoàn thành".equals(status)) { %>
                                <h5><i class="fa-solid fa-check-circle"></i> <%= trangThaiLabels.get(status) %></h5> 
                                <% }else if("Trễ hạn".equals(status)) { %>
                                <h5><i class="fa-solid fa-exclamation-triangle"></i> <%= trangThaiLabels.get(status) %></h5>
                                <% } %>   
                                <% for (Map<String, Object> task : taskList) {
                                       if (status.equals(task.get("trang_thai"))) {
                                        // Kiểm tra xem task có được nhắc nhở hay không
                                        Object nhacNho = task.get("nhac_viec");
                                        boolean hasReminder = false;

                                        if (nhacNho != null) {
                                            try {
                                                int value = Integer.parseInt(nhacNho.toString());
                                                hasReminder = (value == 1);
                                            } catch (NumberFormatException e) {
                                                hasReminder = false;
                                            }
                                        }
                                %>
                                <div class="kanban-task <%= hasReminder ? "task--alert" : "" %>" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"
                                     data-id="<%= task.get("id") %>"
                                     data-ten="<%= task.get("ten_cong_viec") %>"
                                     data-mo-ta="<%= task.get("mo_ta") %>"
                                     data-han="<%= task.get("han_hoan_thanh") %>"
                                     data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
                                     data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
                                     data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_id") %>"
                                     data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
                                     data-trang-thai="<%= task.get("trang_thai") %>"
                                     data-tai_lieu_cv="<%= task.get("tai_lieu_cv") %>"
                                     data-file_tai_lieu="<%= task.get("file_tai_lieu") %>">
                                    <% if (hasReminder) { %>
                                    <div class="task-reminder-bell" title="Công việc đang được nhắc nhở">
                                        <i class="fa-solid fa-bell"></i>
                                    </div>
                                    <% } %>
                                    <div class="task-title"><%= task.get("ten_cong_viec") %></div>
                                    <div class="task-meta">Người giao: <b><%= task.get("nguoi_giao_id") %></b> <br>Người nhận: <b><%= task.get("nguoi_nhan_id") %></b></div>
                                    <span class="task-priority badge <%= priorityBadge.getOrDefault(task.get("muc_do_uu_tien"), "bg-secondary") %>">
                                        <%= task.get("muc_do_uu_tien") %>
                                    </span>
                                    <span class="task-status badge <%= badgeClass.getOrDefault(status, "bg-secondary") %>">
                                        <%= trangThaiLabels.get(status) %>
                                    </span>
                                    <%
                                        Object p = task.get("phan_tram");
                                        int percent = 0;
                                        if (p != null) {
                                            try {
                                                percent = Integer.parseInt(p.toString());
                                            } catch (NumberFormatException e) {
                                                percent = 0;
                                            }
                                        }
                                    %>
                                    <div class="progress">
                                        <div class="progress-bar <%= badgeClass.getOrDefault(status, "bg-secondary") %>" style="width: <%= percent %>%;"></div>
                                    </div>
                                </div>
                                <% }} %>
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Tab Công việc lưu trữ -->
                    <div class="tab-pane fade" id="archived-tasks" role="tabpanel">
                        <div class="archived-tasks-container">
                            <div class="kanban-board">
                                <div class="kanban-col not-started archived-col">
                                    <h5><i class="fa-solid fa-hourglass-start"></i> Chưa bắt đầu</h5>
                                    <div class="text-center text-muted py-3">
                                        <i class="fa-solid fa-inbox fa-2x mb-2"></i>
                                        <p>Chưa có công việc lưu trữ</p>
                                    </div>
                                </div>
                                <div class="kanban-col in-progress archived-col">
                                    <h5><i class="fa-solid fa-spinner"></i> Đang thực hiện</h5>
                                    <div class="text-center text-muted py-3">
                                        <i class="fa-solid fa-inbox fa-2x mb-2"></i>
                                        <p>Chưa có công việc lưu trữ</p>
                                    </div>
                                </div>
                                <div class="kanban-col completed archived-col">
                                    <h5><i class="fa-solid fa-check-circle"></i> Đã hoàn thành</h5>
                                    <div class="text-center text-muted py-3">
                                        <i class="fa-solid fa-inbox fa-2x mb-2"></i>
                                        <p>Chưa có công việc lưu trữ</p>
                                    </div>
                                </div>
                                <div class="kanban-col late archived-col">
                                    <h5><i class="fa-solid fa-exclamation-triangle"></i> Trễ hạn</h5>
                                    <div class="text-center text-muted py-3">
                                        <i class="fa-solid fa-inbox fa-2x mb-2"></i>
                                        <p>Chưa có công việc lưu trữ</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tab Thùng rác -->
                    <div class="tab-pane fade" id="deleted-tasks" role="tabpanel">
                        <div class="deleted-tasks-container">
                            <div class="kanban-board">
                                <div class="kanban-col not-started deleted-col">
                                    <h5><i class="fa-solid fa-hourglass-start"></i> Chưa bắt đầu</h5>
                                    <div class="text-center text-muted py-3">
                                        <i class="fa-solid fa-trash fa-2x mb-2"></i>
                                        <p>Thùng rác trống</p>
                                    </div>
                                </div>
                                <div class="kanban-col in-progress deleted-col">
                                    <h5><i class="fa-solid fa-spinner"></i> Đang thực hiện</h5>
                                    <div class="text-center text-muted py-3">
                                        <i class="fa-solid fa-trash fa-2x mb-2"></i>
                                        <p>Thùng rác trống</p>
                                    </div>
                                </div>
                                <div class="kanban-col completed deleted-col">
                                    <h5><i class="fa-solid fa-check-circle"></i> Đã hoàn thành</h5>
                                    <div class="text-center text-muted py-3">
                                        <i class="fa-solid fa-trash fa-2x mb-2"></i>
                                        <p>Thùng rác trống</p>
                                    </div>
                                </div>
                                <div class="kanban-col late deleted-col">
                                    <h5><i class="fa-solid fa-exclamation-triangle"></i> Trễ hạn</h5>
                                    <div class="text-center text-muted py-3">
                                        <i class="fa-solid fa-trash fa-2x mb-2"></i>
                                        <p>Thùng rác trống</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Modal tạo/sửa task -->

            <!-- Modal chi tiết task với tab -->
            <div class="modal fade" id="modalTaskDetail" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="fa-solid fa-info-circle"></i> Chi tiết công việc</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <ul class="nav nav-tabs mb-3" id="taskDetailTab" role="tablist">
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link active" id="tab-task-info" data-bs-toggle="tab"
                                            data-bs-target="#tabTaskInfo" type="button" role="tab">Thông tin</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="tab-task-progress" data-bs-toggle="tab"
                                            data-bs-target="#tabTaskProgress" type="button" role="tab">Tiến độ</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="tab-task-review" data-bs-toggle="tab"
                                            data-bs-target="#tabTaskReview" type="button" role="tab">Đánh giá</button>
                                </li>
                            </ul>

                            <div class="tab-content" id="taskDetailTabContent">
                                <div class="tab-pane fade show active" id="tabTaskInfo" role="tabpanel">
                                    <form id="formTaskDetail" enctype="multipart/form-data">
                                        <input type="hidden" name="task_id" id="taskId">
                                        <input type="hidden" name="chi_file" value="true">
                                        <div class="mb-2">
                                            <label class="form-label"><b>Tên công việc:</b></label>
                                            <input type="text" class="form-control" name="ten_cong_viec" disabled>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Mô tả:</b></label>
                                            <textarea class="form-control" rows="3" name="mo_ta" disabled></textarea>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Hạn hoàn thành:</b></label>
                                            <input type="date" class="form-control" name="han_hoan_thanh" disabled>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Mức độ ưu tiên:</b></label>
                                            <select class="form-select" name="muc_do_uu_tien" disabled>
                                                <option>Cao</option>
                                                <option>Trung bình</option>
                                                <option>Thấp</option>
                                            </select>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Người giao:</b></label>
                                            <input type="text" class="form-control" name="ten_nguoi_giao" disabled>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Người nhận:</b></label>
                                            <input type="text" class="form-control" name="ten_nguoi_nhan" disabled>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Phòng ban:</b></label>
                                            <select class="form-select" name="ten_phong_ban" disabled></select>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Trạng thái:</b></label>
                                            <select class="form-select" name="trang_thai">
                                                <option>Chưa bắt đầu</option>
                                                <option>Đang thực hiện</option>
                                                <option>Đã hoàn thành</option>
                                                <option>Trễ hạn</option>
                                            </select>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Tài liệu công việc (Link Driver)</b></label>
                                            <input type="text" class="form-control" name="tai_lieu_cv" disabled>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label"><b>File công việc</b></label>
                                            <input class="form-control" type="file" name="files" id="taskFiles" multiple>
                                            <div id="taskFileList" class="form-text text-muted small mt-1">
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                            <button type="button" class="btn btn-primary" id="btnSaveTask">
                                                <i class="fa-solid fa-save"></i> Lưu
                                            </button>
                                        </div>
                                    </form>
                                </div>

                                <div class="tab-pane fade" id="tabTaskProgress" role="tabpanel">
                                    <b>Tiến độ:</b>
                                    <div class="progress my-1">
                                        <div class="progress-bar bg-warning" style="width: 0%" id="taskProgressBar"></div>
                                    </div>
                                    <ul id="processStepList" class="list-group mb-2"></ul>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                    </div>
                                </div>

                                <div class="tab-pane fade" id="tabTaskReview" role="tabpanel">
                                    <ul id="taskReviewList" class="list-group mb-2"></ul>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="<%= request.getContextPath() %>/scripts/usertask.obf.js?v=20251105"></script>
    </body>

</html>
