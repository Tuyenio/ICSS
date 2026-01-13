<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Nhóm Dự án</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <style>
            body {
                background: #f4f7fb;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .main-content {
                padding: 30px;
                margin-left: 240px;
                min-height: 100vh;
            }

            /* Tree View Styles */
            .project-tree {
                background: white;
                border-radius: 12px;
                padding: 0;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
                margin-bottom: 20px;
            }

            .tree-item {
                border-bottom: 1px solid #f0f0f0;
                transition: all 0.3s ease;
            }

            .tree-item:last-child {
                border-bottom: none;
            }

            .tree-item:hover {
                background: #f8f9ff;
            }

            .tree-header {
                padding: 20px 24px;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 16px;
                user-select: none;
            }

            .tree-icon {
                width: 48px;
                height: 48px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 20px;
                flex-shrink: 0;
            }

            .tree-icon.project {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }

            .tree-icon.task {
                background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                color: white;
            }

            .tree-icon.step {
                background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
                color: white;
            }

            .tree-content {
                flex: 1;
                min-width: 0;
            }

            .tree-title {
                font-size: 16px;
                font-weight: 600;
                color: #1e293b;
                margin-bottom: 6px;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .tree-meta {
                display: flex;
                align-items: center;
                gap: 16px;
                flex-wrap: wrap;
                font-size: 13px;
                color: #64748b;
            }

            .tree-meta-item {
                display: flex;
                align-items: center;
                gap: 6px;
            }

            .progress-section {
                flex-shrink: 0;
                text-align: right;
                min-width: 120px;
            }

            .progress-bar-wrapper {
                width: 100px;
                height: 8px;
                background: #e2e8f0;
                border-radius: 10px;
                overflow: hidden;
                margin-bottom: 4px;
            }

            .progress-bar-fill {
                height: 100%;
                border-radius: 10px;
                transition: width 0.4s ease;
            }

            .progress-text {
                font-size: 14px;
                font-weight: 600;
                color: #334155;
            }

            .expand-icon {
                width: 32px;
                height: 32px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                background: #f1f5f9;
                color: #64748b;
                transition: all 0.3s ease;
                flex-shrink: 0;
            }

            .expand-icon:hover {
                background: #e2e8f0;
            }

            .expand-icon i {
                transition: transform 0.3s ease;
            }

            .tree-item.expanded .expand-icon i {
                transform: rotate(90deg);
            }

            .tree-children {
                display: none;
                background: #f8fafc;
                padding: 0;
                margin: 0;
                border-top: 1px solid #e2e8f0;
            }

            .tree-item.expanded > .tree-children {
                display: block;
            }

            .tree-children .tree-item {
                border-left: 3px solid #e2e8f0;
                margin-left: 24px;
            }

            .tree-children .tree-children .tree-item {
                border-left-color: #cbd5e1;
                margin-left: 48px;
            }

            .status-badge {
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 600;
                white-space: nowrap;
            }

            .status-badge.dang-thuc-hien {
                background: #dbeafe;
                color: #1e40af;
            }

            .status-badge.chua-bat-dau {
                background: #f3f4f6;
                color: #6b7280;
            }

            .status-badge.da-hoan-thanh {
                background: #d1fae5;
                color: #065f46;
            }

            .status-badge.tre-han {
                background: #fee2e2;
                color: #991b1b;
            }

            .status-badge.tam-ngung {
                background: #fef3c7;
                color: #92400e;
            }

            .priority-badge {
                padding: 3px 10px;
                border-radius: 6px;
                font-size: 11px;
                font-weight: 600;
            }

            .priority-badge.cao {
                background: #fee2e2;
                color: #991b1b;
            }

            .priority-badge.trung-binh {
                background: #fef3c7;
                color: #92400e;
            }

            .priority-badge.thap {
                background: #dbeafe;
                color: #1e40af;
            }

            .empty-state {
                text-align: center;
                padding: 60px 20px;
                color: #94a3b8;
            }

            .empty-state i {
                font-size: 64px;
                margin-bottom: 20px;
                color: #cbd5e1;
            }

            @media (max-width: 991.98px) {
                .main-content {
                    margin-left: 70px !important;
                    padding: 16px;
                }
                
                .tree-header {
                    flex-wrap: wrap;
                }
                
                .progress-section {
                    width: 100%;
                    text-align: left;
                    margin-top: 10px;
                }
            }

            /* Loading Skeleton */
            .skeleton {
                background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
                background-size: 200% 100%;
                animation: loading 1.5s infinite;
                border-radius: 8px;
            }

            @keyframes loading {
                0% { background-position: 200% 0; }
                100% { background-position: -200% 0; }
            }

            .filter-bar {
                background: white;
                padding: 20px;
                border-radius: 12px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
                margin-bottom: 20px;
                display: flex;
                gap: 15px;
                flex-wrap: wrap;
                align-items: center;
            }

            .filter-item {
                flex: 1;
                min-width: 200px;
            }

            .filter-item select,
            .filter-item input {
                width: 100%;
                padding: 10px 15px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                font-size: 14px;
            }

            .page-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 24px;
            }

            .page-title {
                font-size: 28px;
                font-weight: 700;
                color: #1e293b;
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .stats-cards {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 16px;
                margin-bottom: 24px;
            }

            .stat-card {
                background: white;
                padding: 20px;
                border-radius: 12px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
                display: flex;
                align-items: center;
                gap: 16px;
            }

            .stat-icon {
                width: 56px;
                height: 56px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 24px;
            }

            .stat-content h3 {
                font-size: 28px;
                font-weight: 700;
                margin: 0;
                color: #1e293b;
            }

            .stat-content p {
                font-size: 13px;
                color: #64748b;
                margin: 0;
            }

            .detail-modal .modal-content {
                border-radius: 16px;
                border: none;
            }

            .detail-row {
                padding: 12px 0;
                border-bottom: 1px solid #f0f0f0;
            }

            .detail-row:last-child {
                border-bottom: none;
            }

            .detail-label {
                font-weight: 600;
                color: #475569;
                margin-bottom: 6px;
            }

            .detail-value {
                color: #1e293b;
            }

            .deadline-badge {
                padding: 4px 10px;
                border-radius: 6px;
                font-size: 11px;
                font-weight: 600;
                display: inline-flex;
                align-items: center;
                gap: 4px;
            }

            .deadline-badge.success {
                background: #d1fae5;
                color: #065f46;
            }

            .deadline-badge.warning {
                background: #fef3c7;
                color: #92400e;
            }

            .deadline-badge.danger {
                background: #fee2e2;
                color: #991b1b;
            }

            .deadline-badge.info {
                background: #dbeafe;
                color: #1e40af;
            }

            .action-buttons {
                display: flex;
                gap: 8px;
                align-items: center;
            }

            .btn-action {
                width: 32px;
                height: 32px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                border: none;
                cursor: pointer;
                transition: all 0.3s ease;
                font-size: 14px;
            }

            .btn-action.btn-add {
                background: #10b981;
                color: white;
            }

            .btn-action.btn-add:hover {
                background: #059669;
                transform: scale(1.1);
            }

            .btn-action.btn-edit {
                background: #3b82f6;
                color: white;
            }

            .btn-action.btn-edit:hover {
                background: #2563eb;
                transform: scale(1.1);
            }

            .btn-action.btn-delete {
                background: #ef4444;
                color: white;
            }

            .btn-action.btn-delete:hover {
                background: #dc2626;
                transform: scale(1.1);
            }

            .btn-action.btn-view {
                background: #8b5cf6;
                color: white;
            }

            .btn-action.btn-view:hover {
                background: #7c3aed;
                transform: scale(1.1);
            }

            .task-clickable {
                cursor: pointer;
            }

            .task-clickable:hover {
                background: #f0f9ff !important;
            }
        </style>

        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-layer-group me-2"></i>Nhóm Dự án';
        </script>
    </head>
    <body>
        <div class="d-flex">
            <%@ include file="sidebar.jsp" %>
            <div class="flex-grow-1">
                <%@ include file="header.jsp" %>
                <div class="main-content">
                    <div class="page-header">
                        <h3 class="page-title">
                            <i class="fa-solid fa-layer-group"></i>
                            Tất cả Dự án
                        </h3>
                        <div class="action-buttons">
                            <button class="btn-action btn-add" onclick="window.location.href='dsDuan'" title="Quản lý dự án">
                                <i class="fa-solid fa-diagram-project"></i>
                            </button>
                        </div>
                    </div>

                    <%
                        List<Map<String, Object>> duAnList = (List<Map<String, Object>>) request.getAttribute("duAnList");
                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                        java.util.Date today = new java.util.Date();
                        
                        // Thống kê
                        int tongDuAn = 0;
                        int duAnDangThucHien = 0;
                        int duAnHoanThanh = 0;
                        int tongCongViec = 0;
                        
                        if (duAnList != null) {
                            tongDuAn = duAnList.size();
                            for (Map<String, Object> da : duAnList) {
                                String trangThai = (String) da.get("trang_thai_duan");
                                if ("Đang thực hiện".equals(trangThai)) duAnDangThucHien++;
                                if ("Đã hoàn thành".equals(trangThai)) duAnHoanThanh++;
                                
                                List<Map<String, Object>> cvList = (List<Map<String, Object>>) da.get("cong_viec");
                                if (cvList != null) tongCongViec += cvList.size();
                            }
                        }
                    %>
                    <%!
                    // Helper method to calculate days difference
                    private long calculateDaysDiff(java.util.Date deadline, java.util.Date today) {
                        if (deadline == null) return 0;
                        long diff = deadline.getTime() - today.getTime();
                        return diff / (1000 * 60 * 60 * 24);
                    }
                    
                    // Helper method to generate deadline badge HTML
                    private String generateDeadlineBadge(java.util.Date deadline, java.util.Date today) {
                        if (deadline == null) return "";
                        
                        long days = calculateDaysDiff(deadline, today);
                        String badgeClass = "";
                        String icon = "";
                        String text = "";
                        
                        if (days < 0) {
                            badgeClass = "danger";
                            icon = "<i class='fa-solid fa-exclamation-circle'></i>";
                            text = "Quá hạn " + Math.abs(days) + " ngày";
                        } else if (days == 0) {
                            badgeClass = "warning";
                            icon = "<i class='fa-solid fa-clock'></i>";
                            text = "Hạn hôm nay";
                        } else if (days <= 3) {
                            badgeClass = "warning";
                            icon = "<i class='fa-solid fa-bell'></i>";
                            text = "Còn " + days + " ngày";
                        } else if (days <= 7) {
                            badgeClass = "info";
                            icon = "<i class='fa-solid fa-calendar'></i>";
                            text = "Còn " + days + " ngày";
                        } else {
                            badgeClass = "success";
                            icon = "<i class='fa-solid fa-calendar-check'></i>";
                            text = "Còn " + days + " ngày";
                        }
                        
                        return "<span class='deadline-badge " + badgeClass + "'>" + icon + " " + text + "</span>";
                    }
                    %>

                    <!-- Stats Cards -->
                    <div class="stats-cards">
                        <div class="stat-card">
                            <div class="stat-icon" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
                                <i class="fa-solid fa-folder-open"></i>
                            </div>
                            <div class="stat-content">
                                <h3><%= tongDuAn %></h3>
                                <p>Tổng dự án</p>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white;">
                                <i class="fa-solid fa-spinner"></i>
                            </div>
                            <div class="stat-content">
                                <h3><%= duAnDangThucHien %></h3>
                                <p>Đang thực hiện</p>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white;">
                                <i class="fa-solid fa-check-circle"></i>
                            </div>
                            <div class="stat-content">
                                <h3><%= duAnHoanThanh %></h3>
                                <p>Đã hoàn thành</p>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon" style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); color: white;">
                                <i class="fa-solid fa-tasks"></i>
                            </div>
                            <div class="stat-content">
                                <h3><%= tongCongViec %></h3>
                                <p>Tổng công việc</p>
                            </div>
                        </div>
                    </div>

                    <!-- Filter Bar -->
                    <div class="filter-bar">
                        <div class="filter-item">
                            <input type="text" id="searchInput" class="form-control" placeholder="🔍 Tìm kiếm dự án...">
                        </div>
                        <div class="filter-item">
                            <select id="statusFilter" class="form-select">
                                <option value="">Tất cả trạng thái</option>
                                <option value="Đang thực hiện">Đang thực hiện</option>
                                <option value="Tạm ngưng">Tạm ngưng</option>
                                <option value="Đã hoàn thành">Đã hoàn thành</option>
                            </select>
                        </div>
                        <div class="filter-item">
                            <select id="groupFilter" class="form-select">
                                <option value="">Tất cả nhóm</option>
                                <option value="Dashboard">Dashboard</option>
                                <option value="An ninh bảo mật">An ninh bảo mật</option>
                                <option value="Oracle Cloud">Oracle Cloud</option>
                                <option value="Đào tạo">Đào tạo</option>
                                <option value="Chuyển đổi số">Chuyển đổi số</option>
                                <option value="Khác">Khác</option>
                            </select>
                        </div>
                    </div>

                    <!-- Project Tree -->
                    <div id="projectContainer">
                        <%
                            if (duAnList != null && !duAnList.isEmpty()) {
                                SimpleDateFormat sdf2 = new SimpleDateFormat("dd/MM/yyyy");
                                
                                for (Map<String, Object> duAn : duAnList) {
                                    int duAnId = (Integer) duAn.get("id");
                                    String tenDuAn = (String) duAn.get("ten_du_an");
                                    String trangThaiDuAn = (String) duAn.get("trang_thai_duan");
                                    String nhomDuAn = (String) duAn.get("nhom_du_an");
                                    String phongBan = (String) duAn.get("phong_ban");
                                    String leadName = (String) duAn.get("lead_name");
                                    Double tienDoDuAn = (Double) duAn.get("tien_do");
                                    java.sql.Date ngayKetThuc = (java.sql.Date) duAn.get("ngay_ket_thuc");
                                    List<Map<String, Object>> congViecList = (List<Map<String, Object>>) duAn.get("cong_viec");
                                    
                                    String statusClass = "";
                                    if ("Đang thực hiện".equals(trangThaiDuAn)) statusClass = "dang-thuc-hien";
                                    else if ("Đã hoàn thành".equals(trangThaiDuAn)) statusClass = "da-hoan-thanh";
                                    else if ("Tạm ngưng".equals(trangThaiDuAn)) statusClass = "tam-ngung";
                                    else statusClass = "chua-bat-dau";
                                    
                                    String progressColor = "";
                                    if (tienDoDuAn >= 80) progressColor = "#10b981";
                                    else if (tienDoDuAn >= 50) progressColor = "#3b82f6";
                                    else if (tienDoDuAn >= 20) progressColor = "#f59e0b";
                                    else progressColor = "#ef4444";
                        %>
                        <div class="project-tree tree-item" data-status="<%= trangThaiDuAn %>" data-group="<%= nhomDuAn %>" data-name="<%= tenDuAn %>">
                            <div class="tree-header">
                                <div class="tree-icon project">
                                    <i class="fa-solid fa-folder-open"></i>
                                </div>
                                <div class="tree-content">
                                    <div class="tree-title">
                                        <%= tenDuAn %>
                                        <span class="status-badge <%= statusClass %>"><%= trangThaiDuAn %></span>
                                        <%= generateDeadlineBadge(ngayKetThuc, today) %>
                                    </div>
                                    <div class="tree-meta">
                                        <span class="tree-meta-item">
                                            <i class="fa-solid fa-layer-group"></i>
                                            <%= nhomDuAn %>
                                        </span>
                                        <span class="tree-meta-item">
                                            <i class="fa-solid fa-building"></i>
                                            <%= phongBan %>
                                        </span>
                                        <% if (leadName != null) { %>
                                        <span class="tree-meta-item">
                                            <i class="fa-solid fa-user-tie"></i>
                                            <%= leadName %>
                                        </span>
                                        <% } %>
                                        <% if (ngayKetThuc != null) { %>
                                        <span class="tree-meta-item">
                                            <i class="fa-solid fa-calendar-days"></i>
                                            Hạn: <%= sdf2.format(ngayKetThuc) %>
                                        </span>
                                        <% } %>
                                        <span class="tree-meta-item">
                                            <i class="fa-solid fa-list-check"></i>
                                            <%= congViecList != null ? congViecList.size() : 0 %> công việc
                                        </span>
                                    </div>
                                </div>
                                <div class="progress-section">
                                    <div class="progress-bar-wrapper">
                                        <div class="progress-bar-fill" style="width: <%= tienDoDuAn %>%; background: <%= progressColor %>;"></div>
                                    </div>
                                    <div class="progress-text"><%= String.format("%.0f", tienDoDuAn) %>% Hoàn thành</div>
                                </div>
                                <% if (congViecList != null && !congViecList.isEmpty()) { %>
                                <div class="expand-icon">
                                    <i class="fa-solid fa-chevron-right"></i>
                                </div>
                                <% } %>
                            </div>
                            
                            <% if (congViecList != null && !congViecList.isEmpty()) { %>
                            <div class="tree-children">
                                <% for (Map<String, Object> congViec : congViecList) {
                                    int cvId = (Integer) congViec.get("id");
                                    String tenCV = (String) congViec.get("ten_cong_viec");
                                    String trangThaiCV = (String) congViec.get("trang_thai");
                                    String mucDoUuTien = (String) congViec.get("muc_do_uu_tien");
                                    String nguoiNhanNames = (String) congViec.get("nguoi_nhan_names");
                                    Double tienDoCV = (Double) congViec.get("tien_do");
                                    java.sql.Date hanHoanThanh = (java.sql.Date) congViec.get("han_hoan_thanh");
                                    List<Map<String, Object>> quyTrinhList = (List<Map<String, Object>>) congViec.get("quy_trinh");
                                    
                                    String cvStatusClass = "";
                                    if ("Đang thực hiện".equals(trangThaiCV)) cvStatusClass = "dang-thuc-hien";
                                    else if ("Đã hoàn thành".equals(trangThaiCV)) cvStatusClass = "da-hoan-thanh";
                                    else if ("Trễ hạn".equals(trangThaiCV)) cvStatusClass = "tre-han";
                                    else cvStatusClass = "chua-bat-dau";
                                    
                                    String priorityClass = "";
                                    if ("Cao".equals(mucDoUuTien)) priorityClass = "cao";
                                    else if ("Trung bình".equals(mucDoUuTien)) priorityClass = "trung-binh";
                                    else priorityClass = "thap";
                                    
                                    String cvProgressColor = "";
                                    if (tienDoCV >= 80) cvProgressColor = "#10b981";
                                    else if (tienDoCV >= 50) cvProgressColor = "#3b82f6";
                                    else if (tienDoCV >= 20) cvProgressColor = "#f59e0b";
                                    else cvProgressColor = "#ef4444";
                                %>
                                <div class="tree-item task-clickable" data-task-id="<%= cvId %>">
                                    <div class="tree-header">
                                        <div class="tree-icon task">
                                            <i class="fa-solid fa-tasks"></i>
                                        </div>
                                        <div class="tree-content">
                                            <div class="tree-title">
                                                <%= tenCV %>
                                                <span class="status-badge <%= cvStatusClass %>"><%= trangThaiCV %></span>
                                                <span class="priority-badge <%= priorityClass %>"><%= mucDoUuTien %></span>
                                                <%= generateDeadlineBadge(hanHoanThanh, today) %>
                                            </div>
                                            <div class="tree-meta">
                                                <% if (nguoiNhanNames != null && !nguoiNhanNames.isEmpty()) { %>
                                                <span class="tree-meta-item">
                                                    <i class="fa-solid fa-users"></i>
                                                    <%= nguoiNhanNames %>
                                                </span>
                                                <% } %>
                                                <% if (hanHoanThanh != null) { %>
                                                <span class="tree-meta-item">
                                                    <i class="fa-solid fa-calendar-days"></i>
                                                    Hạn: <%= sdf2.format(hanHoanThanh) %>
                                                </span>
                                                <% } %>
                                                <% if (quyTrinhList != null && !quyTrinhList.isEmpty()) { %>
                                                <span class="tree-meta-item">
                                                    <i class="fa-solid fa-sitemap"></i>
                                                    <%= quyTrinhList.size() %> quy trình
                                                </span>
                                                <% } %>
                                            </div>
                                        </div>
                                        <div class="progress-section">
                                            <div class="progress-bar-wrapper">
                                                <div class="progress-bar-fill" style="width: <%= tienDoCV %>%; background: <%= cvProgressColor %>;"></div>
                                            </div>
                                            <div class="progress-text"><%= String.format("%.0f", tienDoCV) %>%</div>
                                        </div>
                                        <% if (quyTrinhList != null && !quyTrinhList.isEmpty()) { %>
                                        <div class="expand-icon">
                                            <i class="fa-solid fa-chevron-right"></i>
                                        </div>
                                        <% } %>
                                    </div>
                                    
                                    <% if (quyTrinhList != null && !quyTrinhList.isEmpty()) { %>
                                    <div class="tree-children">
                                        <% for (Map<String, Object> quyTrinh : quyTrinhList) {
                                            String tenBuoc = (String) quyTrinh.get("ten_buoc");
                                            String trangThaiQT = (String) quyTrinh.get("trang_thai");
                                            Double tienDoQT = (Double) quyTrinh.get("tien_do");
                                            java.sql.Date ngayKetThucQT = (java.sql.Date) quyTrinh.get("ngay_ket_thuc");
                                            
                                            String qtStatusClass = "";
                                            if ("Đang thực hiện".equals(trangThaiQT)) qtStatusClass = "dang-thuc-hien";
                                            else if ("Đã hoàn thành".equals(trangThaiQT)) qtStatusClass = "da-hoan-thanh";
                                            else qtStatusClass = "chua-bat-dau";
                                            
                                            String qtProgressColor = "";
                                            if (tienDoQT >= 80) qtProgressColor = "#10b981";
                                            else if (tienDoQT >= 50) qtProgressColor = "#3b82f6";
                                            else qtProgressColor = "#94a3b8";
                                        %>
                                        <div class="tree-item">
                                            <div class="tree-header">
                                                <div class="tree-icon step">
                                                    <i class="fa-solid fa-list-check"></i>
                                                </div>
                                                <div class="tree-content">
                                                    <div class="tree-title">
                                                        <%= tenBuoc %>
                                                        <span class="status-badge <%= qtStatusClass %>"><%= trangThaiQT %></span>
                                                        <%= generateDeadlineBadge(ngayKetThucQT, today) %>
                                                    </div>
                                                    <div class="tree-meta">
                                                        <% if (nguoiNhanNames != null && !nguoiNhanNames.isEmpty()) { %>
                                                        <span class="tree-meta-item">
                                                            <i class="fa-solid fa-user"></i>
                                                            <%= nguoiNhanNames %>
                                                        </span>
                                                        <% } %>
                                                        <% if (ngayKetThucQT != null) { %>
                                                        <span class="tree-meta-item">
                                                            <i class="fa-solid fa-calendar-days"></i>
                                                            Hạn: <%= sdf2.format(ngayKetThucQT) %>
                                                        </span>
                                                        <% } %>
                                                    </div>
                                                </div>
                                                <div class="progress-section">
                                                    <div class="progress-bar-wrapper">
                                                        <div class="progress-bar-fill" style="width: <%= tienDoQT %>%; background: <%= qtProgressColor %>;"></div>
                                                    </div>
                                                    <div class="progress-text"><%= String.format("%.0f", tienDoQT) %>%</div>
                                                </div>
                                            </div>
                                        </div>
                                        <% } %>
                                    </div>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                        <%
                                }
                            } else {
                        %>
                        <div class="empty-state">
                            <i class="fa-solid fa-folder-open"></i>
                            <h4>Chưa có dự án nào</h4>
                            <p>Hệ thống chưa có dự án nào được tạo</p>
                        </div>
                        <%
                            }
                        %>
                    </div>
                </div>
            </div>
        </div>

        <script>
            $(document).ready(function() {
                // Toggle expand/collapse
                $('.expand-icon').on('click', function(e) {
                    e.stopPropagation();
                    $(this).closest('.tree-item').toggleClass('expanded');
                });

                // Click on header to expand/collapse
                $('.tree-header').on('click', function() {
                    var $expandIcon = $(this).find('.expand-icon');
                    if ($expandIcon.length > 0) {
                        $(this).closest('.tree-item').toggleClass('expanded');
                    }
                });

                // Search filter
                $('#searchInput').on('keyup', function() {
                    filterProjects();
                });

                // Status filter
                $('#statusFilter').on('change', function() {
                    filterProjects();
                });

                // Group filter
                $('#groupFilter').on('change', function() {
                    filterProjects();
                });

                function filterProjects() {
                    var searchText = $('#searchInput').val().toLowerCase();
                    var statusFilter = $('#statusFilter').val();
                    var groupFilter = $('#groupFilter').val();

                    $('.project-tree').each(function() {
                        var $project = $(this);
                        var projectName = $project.data('name').toLowerCase();
                        var projectStatus = $project.data('status');
                        var projectGroup = $project.data('group');

                        var matchSearch = searchText === '' || projectName.includes(searchText);
                        var matchStatus = statusFilter === '' || projectStatus === statusFilter;
                        var matchGroup = groupFilter === '' || projectGroup === groupFilter;

                        if (matchSearch && matchStatus && matchGroup) {
                            $project.show();
                        } else {
                            $project.hide();
                        }
                    });
                }

                // Click vào công việc để mở trang dsCongviec với taskId
                $('.task-clickable').on('click', function(e) {
                    // Chặn sự kiện expand/collapse của tree
                    e.stopPropagation();
                    
                    var taskId = $(this).data('task-id');
                    
                    // Redirect sang trang dsCongviec với taskId
                    window.location.href = 'dsCongviec?taskId=' + taskId;
                });
            });
        </script>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-layer-group me-2"></i>Nhóm Dự án';

            function handleDepartmentClick(element) {
                var nhomDuAn = element.getAttribute('data-group');
                var phongBan = element.getAttribute('data-dept');

                // Chuyển đổi tên phòng ban từ viết tắt sang đầy đủ
                var fullPhongBan = '';
                if (phongBan === 'KY_THUAT') {
                    fullPhongBan = 'Phòng Kỹ Thuật';
                } else if (phongBan === 'KINH_DOANH') {
                    fullPhongBan = 'Phòng Kinh Doanh';
                }

                window.location.href = 'dsDuan?nhom_du_an=' + encodeURIComponent(nhomDuAn) + '&phong_ban=' + encodeURIComponent(fullPhongBan);
            }
        </script>
    </body>
</html>