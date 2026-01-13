<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Quản lý Dự án</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            /* ===================================
               MODERN CARD-BASED DESIGN - RESPONSIVE
               =================================== */
            body {
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                font-family: 'Segoe UI', Roboto, sans-serif;
                color: #1e293b;
            }

            .main-content {
                padding: 20px;
                min-height: 100vh;
                margin-left: 240px;
                animation: fadeIn 0.5s ease;
            }

            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(12px); }
                to { opacity: 1; transform: translateY(0); }
            }

            /* ===================================
               PROJECT CARDS GRID
               =================================== */
            .projects-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
                gap: 20px;
                margin-top: 20px;
            }

            .project-card {
                background: white;
                border-radius: 16px;
                padding: 20px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.08);
                transition: all 0.3s ease;
                cursor: pointer;
                position: relative;
                overflow: hidden;
            }

            .project-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 4px;
                background: linear-gradient(90deg, #0dcaf0, #4f46e5);
            }

            .project-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 24px rgba(0,0,0,0.15);
            }

            .project-card-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                margin-bottom: 15px;
            }

            .project-title {
                font-size: 1.15rem;
                font-weight: 700;
                color: #1e293b;
                margin: 0;
                flex: 1;
                line-height: 1.4;
            }

            .project-priority {
                margin-left: 10px;
                flex-shrink: 0;
            }

            .badge {
                padding: 5px 12px;
                border-radius: 20px;
                font-weight: 600;
                font-size: 0.75rem;
                text-transform: uppercase;
            }

            .badge.bg-danger { background: linear-gradient(135deg, #ef4444, #dc2626) !important; }
            .badge.bg-warning { background: linear-gradient(135deg, #f59e0b, #d97706) !important; color: white !important; }
            .badge.bg-success { background: linear-gradient(135deg, #10b981, #059669) !important; }
            .badge.bg-info { background: linear-gradient(135deg, #0dcaf0, #06b6d4) !important; }
            .badge.bg-secondary { background: #94a3b8 !important; }

            .project-desc {
                color: #64748b;
                font-size: 0.9rem;
                margin-bottom: 15px;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
                min-height: 40px;
            }

            .project-meta {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 10px;
                margin-bottom: 15px;
                padding-top: 15px;
                border-top: 1px solid #e2e8f0;
            }

            .meta-item {
                display: flex;
                align-items: center;
                font-size: 0.85rem;
                color: #475569;
            }

            .meta-item i {
                width: 20px;
                color: #0dcaf0;
                margin-right: 8px;
            }

            .meta-item strong {
                color: #1e293b;
                margin-left: 4px;
            }

            .project-lead {
                display: flex;
                align-items: center;
                padding: 10px;
                background: #f8fafc;
                border-radius: 10px;
                margin-bottom: 15px;
            }

            .project-lead img {
                width: 32px;
                height: 32px;
                border-radius: 50%;
                margin-right: 10px;
                border: 2px solid #0dcaf0;
            }

            .project-lead-info {
                flex: 1;
            }

            .project-lead-label {
                font-size: 0.7rem;
                color: #94a3b8;
                text-transform: uppercase;
            }

            .project-lead-name {
                font-weight: 600;
                color: #1e293b;
                font-size: 0.9rem;
            }

            .project-progress-section {
                margin-bottom: 15px;
            }

            .progress {
                height: 8px;
                border-radius: 10px;
                background: #e2e8f0;
                overflow: hidden;
            }

            .progress-bar {
                border-radius: 10px;
                transition: width 0.6s ease;
            }

            .progress-label {
                display: flex;
                justify-content: space-between;
                font-size: 0.75rem;
                margin-bottom: 6px;
                color: #64748b;
            }

            .progress-percent {
                font-weight: 700;
                color: #1e293b;
            }

            .project-actions {
                display: flex;
                gap: 8px;
                padding-top: 15px;
                border-top: 1px solid #e2e8f0;
            }

            .btn-action {
                flex: 1;
                padding: 8px;
                border-radius: 10px;
                border: none;
                font-weight: 600;
                font-size: 0.85rem;
                cursor: pointer;
                transition: all 0.2s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
            }

            .btn-action:hover {
                transform: translateY(-2px);
            }

            .btn-view {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                color: white;
            }

            .btn-edit {
                background: linear-gradient(135deg, #fbbf24, #f59e0b);
                color: white;
            }

            .btn-delete {
                background: linear-gradient(135deg, #ef4444, #dc2626);
                color: white;
            }

            .btn-add-project {
                background: linear-gradient(135deg, #0d6efd, #0dcaf0);
                border: none;
                color: #fff;
                font-weight: 600;
                border-radius: 50px;
                padding: 12px 24px;
                box-shadow: 0 4px 12px rgba(13,110,253,0.3);
                transition: all 0.3s ease;
            }

            .btn-add-project:hover {
                transform: translateY(-3px) scale(1.05);
                box-shadow: 0 6px 20px rgba(13,110,253,0.5);
            }

            /* ===================================
               VIEW TOGGLE BUTTONS
               =================================== */
            .view-toggle {
                display: flex;
                gap: 10px;
                background: white;
                padding: 6px;
                border-radius: 50px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }

            .view-toggle-btn {
                padding: 8px 16px;
                border: none;
                background: transparent;
                border-radius: 50px;
                cursor: pointer;
                font-weight: 600;
                font-size: 0.85rem;
                color: #64748b;
                transition: all 0.2s ease;
            }

            .view-toggle-btn.active {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                color: white;
                box-shadow: 0 2px 8px rgba(13,202,240,0.3);
            }

            .view-toggle-btn:hover:not(.active) {
                background: #f1f5f9;
                color: #1e293b;
            }

            /* ===================================
               COMPACT TABLE VIEW (OPTIONAL)
               =================================== */
            .table-view {
                background: white;
                border-radius: 16px;
                padding: 20px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.08);
                overflow-x: auto;
            }

            .table-view table {
                width: 100%;
                border-collapse: collapse;
            }

            .table-view thead {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                color: white;
            }

            .table-view th {
                padding: 14px 12px;
                text-align: left;
                font-weight: 600;
                font-size: 0.85rem;
                white-space: nowrap;
            }

            .table-view td {
                padding: 12px;
                border-bottom: 1px solid #f1f5f9;
                font-size: 0.9rem;
            }

            .table-view tbody tr {
                transition: background 0.2s ease;
            }

            .table-view tbody tr:hover {
                background: #f8fafc;
            }

            /* ===================================
               RESPONSIVE DESIGN
               =================================== */
            @media (max-width: 1400px) {
                .projects-grid {
                    grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
                }
            }

            @media (max-width: 1200px) {
                .projects-grid {
                    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                }
            }

            @media (max-width: 992px) {
                .main-content {
                    margin-left: 60px;
                    padding: 15px;
                }
                .projects-grid {
                    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                    gap: 15px;
                }
            }

            @media (max-width: 768px) {
                .main-content {
                    margin-left: 0;
                    padding: 10px;
                }
                .projects-grid {
                    grid-template-columns: 1fr;
                    gap: 15px;
                }
                .project-meta {
                    grid-template-columns: 1fr;
                }
                .project-actions {
                    flex-direction: column;
                }
            }

            @media (max-width: 576px) {
                .project-card {
                    padding: 15px;
                }
                .project-title {
                    font-size: 1rem;
                }
                h3 {
                    font-size: 1.3rem !important;
                }
                .btn-add-project {
                    padding: 10px 16px;
                    font-size: 0.85rem;
                }
            }

            /* Empty state */
            .empty-state {
                text-align: center;
                padding: 60px 20px;
                color: #94a3b8;
            }

            .empty-state i {
                font-size: 4rem;
                margin-bottom: 20px;
                opacity: 0.3;
            }

        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án';
        </script>
    </head>
    <body>
        <div class="d-flex">
            <%@ include file="sidebarnv.jsp" %>
            <div class="flex-grow-1">
                <%@ include file="user_header.jsp" %>
                <div class="main-content">
                    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                        <h3 class="mb-0"><i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án</h3>
                        <div class="d-flex gap-2 align-items-center flex-wrap">
                            <div class="view-toggle">
                                <button class="view-toggle-btn active" data-view="card">
                                    <i class="fa-solid fa-grip"></i> Card
                                </button>
                                <button class="view-toggle-btn" data-view="table">
                                    <i class="fa-solid fa-table"></i> Table
                                </button>
                            </div>
                            <button class="btn btn-add-project" data-bs-toggle="modal" data-bs-target="#modalProject">
                                <i class="fa-solid fa-plus me-1"></i> Thêm dự án
                            </button>
                        </div>
                    </div>
                    <form class="row g-3 mb-4 align-items-end" method="get" action="dsDuannv">

                        <!-- Tìm theo tên dự án -->
                        <div class="col-md-3">
                            <input type="text" name="keyword" class="form-control"
                                   placeholder="Tìm theo tên dự án..."
                                   value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
                        </div>

                        <!-- Lọc theo mức độ ưu tiên -->
                        <div class="col-md-2">
                            <select name="uuTien" class="form-select">
                                <option value="">Ưu tiên (Tất cả)</option>
                                <option value="Cao">Cao</option>
                                <option value="Trung bình">Trung bình</option>
                                <option value="Thấp">Thấp</option>
                            </select>
                        </div>

                        <!-- Lead -->
                        <div class="col-md-3">
                            <select name="leadId" class="form-select">
                                <option value="">Lead dự án (Tất cả)</option>
                                <c:if test="${not empty employeeList}">
                                    <c:forEach var="emp" items="${employeeList}">
                                        <option value="${emp.id}"
                                                <%= request.getParameter("leadId") != null &&
                                                    request.getParameter("leadId").equals(String.valueOf(((java.util.Map)pageContext.findAttribute("emp")).get("id")))
                                                    ? "selected" : "" %>>
                                            ${emp.ho_ten}
                                        </option>
                                    </c:forEach>
                                </c:if>
                            </select>
                        </div>

                        <!-- Nút Lọc -->
                        <div class="col-md-1">
                            <button class="btn btn-primary w-100">
                                <i class="fa-solid fa-filter"></i>
                            </button>
                        </div>

                        <!-- Nút Reset -->
                        <div class="col-md-1">
                            <a href="dsDuannv" class="btn btn-secondary w-100">
                                <i class="fa-solid fa-rotate-left"></i>
                            </a>
                        </div>

                    </form>
                    
                    <!-- ==================== CARD VIEW (DEFAULT) ==================== -->
                    <div class="projects-grid" id="cardView">
                        <% 
                            List<Map<String, Object>> projects = 
                                (List<Map<String, Object>>) request.getAttribute("projects");

                            if (projects != null && !projects.isEmpty()) {
                                for (Map<String, Object> p : projects) {
                    
                                    String priority = p.get("muc_do_uu_tien") != null 
                                        ? p.get("muc_do_uu_tien").toString() : "Không rõ";
                                    String priorityClass = "bg-secondary";
                                    if ("Cao".equals(priority)) priorityClass = "bg-danger";
                                    else if ("Trung bình".equals(priority)) priorityClass = "bg-warning";
                                    else if ("Thấp".equals(priority)) priorityClass = "bg-success";
                    
                                    // Tiến độ
                                    int td = 0;
                                    try { td = Integer.parseInt(p.get("tien_do").toString()); } 
                                    catch (Exception ex) {}

                                    String progressColor = td < 30 ? "bg-danger" 
                                                        : td < 70 ? "bg-warning" 
                                                        : "bg-success";
                                                        
                                    String status = p.get("trang_thai_duan") != null ? p.get("trang_thai_duan").toString() : "Đang thực hiện";
                                    String statusClass = "bg-secondary";
                                    if ("Tạm ngưng".equals(status)) statusClass = "bg-warning";
                                    else if ("Đang thực hiện".equals(status)) statusClass = "bg-info";
                                    else if ("Đã hoàn thành".equals(status)) statusClass = "bg-success";
                                    else if ("Đóng dự án".equals(status)) statusClass = "bg-danger";
                        %>
                        
                        <div class="project-card" data-id="<%= p.get("id") %>" onclick="window.location.href='dsCongviecDuanNV?projectId=<%= p.get("id") %>';" style="cursor:pointer;">
                            <div class="project-card-header" onclick="event.stopPropagation();">
                                <h4 class="project-title"><%= p.get("ten_du_an") %></h4>
                                <span class="badge <%= priorityClass %> project-priority"><%= priority %></span>
                            </div>
                            
                            <div class="project-desc">
                                <%= p.get("mo_ta") != null ? p.get("mo_ta") : "Không có mô tả" %>
                            </div>
                            
                            <div class="project-lead">
                                <img src="<%= p.get("lead_avatar") %>" alt="Lead">
                                <div class="project-lead-info">
                                    <div class="project-lead-label">Lead dự án</div>
                                    <div class="project-lead-name"><%= p.get("lead_ten") != null ? p.get("lead_ten") : "Chưa có" %></div>
                                </div>
                            </div>
                            
                            <div class="project-meta">
                                <div class="meta-item">
                                    <i class="fa-solid fa-layer-group"></i>
                                    <span><%= p.get("nhom_du_an") %></span>
                                </div>
                                <div class="meta-item">
                                    <i class="fa-solid fa-building"></i>
                                    <span><%= p.get("phong_ban") != null ? p.get("phong_ban") : "Chưa phân" %></span>
                                </div>
                                <div class="meta-item">
                                    <i class="fa-solid fa-calendar-check"></i>
                                    <span><strong><%= p.get("ngay_bat_dau") %></strong></span>
                                </div>
                                <div class="meta-item">
                                    <i class="fa-solid fa-calendar-xmark"></i>
                                    <span><strong><%= p.get("ngay_ket_thuc") %></strong></span>
                                </div>
                            </div>
                            
                            <div class="project-progress-section">
                                <div class="progress-label">
                                    <span>Tiến độ</span>
                                    <span class="progress-percent"><%= td %>%</span>
                                </div>
                                <div class="progress">
                                    <div class="progress-bar <%= progressColor %>" style="width:<%= td %>%"></div>
                                </div>
                            </div>
                            
                            <div class="mb-2">
                                <span class="badge <%= statusClass %> w-100"><%= status %></span>
                            </div>
                            
                            <div class="project-actions">
                                <button class="btn-action btn-view" onclick="event.stopPropagation(); showProjectDetail(event, <%= p.get("id") %>);">
                                    <i class="fa-solid fa-eye"></i> Xem
                                </button>
                                <button class="btn-action btn-edit" onclick="event.stopPropagation(); editProject(<%= p.get("id") %>);">
                                    <i class="fa-solid fa-pen"></i> Sửa
                                </button>
                                <button class="btn-action btn-delete delete-project-btn" data-id="<%= p.get("id") %>" onclick="event.stopPropagation();">
                                    <i class="fa-solid fa-trash"></i> Xóa
                                </button>
                            </div>
                        </div>
                        
                        <% 
                                } 
                            } else {
                        %>
                        <div class="empty-state" style="grid-column: 1/-1;">
                            <i class="fa-solid fa-inbox"></i>
                            <h4>Không có dự án nào</h4>
                            <p>Hãy thêm dự án mới để bắt đầu</p>
                        </div>
                        <% } %>
                    </div>
                    
                    <!-- ==================== TABLE VIEW (OPTIONAL) ==================== -->
                    <div class="table-view" id="tableView" style="display: none;">
                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th>Tên dự án</th>
                                    <th>Lead</th>
                                    <th>Nhóm</th>
                                    <th>Trạng thái</th>
                                    <th>Ưu tiên</th>
                                    <th>Tiến độ</th>
                                    <th>Hạn</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    if (projects != null && !projects.isEmpty()) {
                                        for (Map<String, Object> p : projects) {
                                            String priority = p.get("muc_do_uu_tien") != null ? p.get("muc_do_uu_tien").toString() : "Không rõ";
                                            String priorityClass = "bg-secondary";
                                            if ("Cao".equals(priority)) priorityClass = "bg-danger";
                                            else if ("Trung bình".equals(priority)) priorityClass = "bg-warning";
                                            else if ("Thấp".equals(priority)) priorityClass = "bg-success";
                                            
                                            int td = 0;
                                            try { td = Integer.parseInt(p.get("tien_do").toString()); } catch (Exception ex) {}
                                            String progressColor = td < 30 ? "bg-danger" : td < 70 ? "bg-warning" : "bg-success";
                                            
                                            String status = p.get("trang_thai_duan") != null ? p.get("trang_thai_duan").toString() : "Đang thực hiện";
                                            String statusClass = "bg-secondary";
                                            if ("Tạm ngưng".equals(status)) statusClass = "bg-warning";
                                            else if ("Đang thực hiện".equals(status)) statusClass = "bg-info";
                                            else if ("Đã hoàn thành".equals(status)) statusClass = "bg-success";
                                            else if ("Đóng dự án".equals(status)) statusClass = "bg-danger";
                                %>
                                <tr onclick="window.location.href='dsCongviecDuanNV?projectId=<%= p.get("id") %>';" style="cursor:pointer;">
                                    <td><strong><%= p.get("ten_du_an") %></strong></td>
                                    <td>
                                        <img src="<%= p.get("lead_avatar") %>" width="24" height="24" class="rounded-circle me-1">
                                        <%= p.get("lead_ten") != null ? p.get("lead_ten") : "Chưa có" %>
                                    </td>
                                    <td><%= p.get("nhom_du_an") %></td>
                                    <td>
                                        <span class="badge <%= statusClass %>"><%= status %></span>
                                    </td>
                                    <td>
                                        <span class="badge <%= priorityClass %>"><%= priority %></span>
                                    </td>
                                    <td style="min-width:140px;">
                                        <div class="d-flex align-items-center">
                                            <div class="progress flex-grow-1" style="height:6px;">
                                                <div class="progress-bar <%= progressColor %>" style="width:<%= td %>%"></div>
                                            </div>
                                            <span class="ms-2 fw-bold" style="font-size:0.85rem;"><%= td %>%</span>
                                        </div>
                                    </td>
                                    <td><small><%= p.get("ngay_ket_thuc") %></small></td>
                                    <td onclick="event.stopPropagation();">
                                        <div class="btn-group">
                                            <button class="btn btn-sm btn-info" onclick="showProjectDetail(event, <%= p.get("id") %>)">
                                                <i class="fa-solid fa-eye"></i>
                                            </button>
                                            <button class="btn btn-sm btn-warning" onclick="event.stopPropagation(); editProject(<%= p.get("id") %>);">
                                                <i class="fa-solid fa-pen"></i>
                                            </button>
                                            <button class="btn btn-sm btn-danger delete-project-btn" data-id="<%= p.get("id") %>">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                <% 
                                        } 
                                    } 
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <!-- Modal Thêm/Sửa Dự án -->
        <div class="modal fade" id="modalProject" tabindex="-1">
            <div class="modal-dialog">
                <form class="modal-content" id="projectForm">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fa-solid fa-diagram-project"></i> Thông tin dự án</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="id">

                        <div class="mb-3">
                            <label class="form-label">Tên dự án</label>
                            <input type="text" class="form-control" name="ten_du_an" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Mô tả</label>
                            <textarea class="form-control" name="mo_ta" rows="3"></textarea>
                        </div>

                        <!-- THÊM MỨC ĐỘ ƯU TIÊN -->
                        <div class="mb-3">
                            <label class="form-label">Mức độ ưu tiên</label>
                            <select class="form-select" name="muc_do_uu_tien" required>
                                <option value="Cao">Cao</option>
                                <option value="Trung bình" selected>Trung bình</option>
                                <option value="Thấp">Thấp</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Nhóm dự án</label>
                            <select class="form-select" name="nhom_du_an" required>
                                <option value="Dashboard">Dashboard</option>
                                <option value="An ninh bảo mật">An ninh bảo mật</option>
                                <option value="Oracle Cloud">Oracle Cloud</option>
                                <option value="Đào tạo">Đào tạo</option>
                                <option value="Chuyển đổi số">Chuyển đổi số</option>
                                <option value="Khác">Khác</option>
                            </select>
                        </div>

                        <!-- THÊM PHÒNG BAN -->
                        <div class="mb-3">
                            <label class="form-label">Phòng ban</label>
                            <select class="form-select" name="phong_ban" required>
                                <option value="Phòng Kinh Doanh">Phòng Kinh Doanh</option>
                                <option value="Phòng Kỹ Thuật">Phòng Kỹ Thuật</option>
                                <option value="Phòng Nhân Sự">Phòng Nhân Sự</option>
                            </select>
                        </div>

                        <!-- THÊM LEAD DỰ ÁN -->
                        <div class="mb-3">
                            <label class="form-label">Lead dự án</label>
                            <select class="form-select" name="lead_id" required>
                                <option value="">-- Chọn Lead --</option>
                                <c:if test="${not empty employeeList}">
                                    <c:forEach var="emp" items="${employeeList}">
                                        <option value="${emp.id}">${emp.ho_ten}</option>
                                    </c:forEach>
                                </c:if>
                            </select>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Ngày bắt đầu</label>
                                <input type="date" class="form-control" name="ngay_bat_dau" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Ngày kết thúc</label>
                                <input type="date" class="form-control" name="ngay_ket_thuc" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn-primary rounded-pill">Lưu</button>
                        <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
                    </div>
                </form>
            </div>
        </div>
        <!-- Modal chi tiết dự án -->
        <div class="modal fade" id="modalProjectDetail" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fa-solid fa-info-circle"></i> Chi tiết dự án</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-12">
                                <p><strong>Tên dự án:</strong> <span id="detail_ten_du_an"></span></p>
                                <p><strong>Mô tả:</strong> <span id="detail_mo_ta"></span></p>
                                <p><strong>Lead:</strong> <span id="detail_lead"></span></p>
                                <p><strong>Nhóm:</strong> <span id="detail_nhom"></span></p>
                                <p><strong>Phòng ban:</strong> <span id="detail_phong_ban"></span></p>
                                <p><strong>Trạng thái:</strong> <span id="detail_trang_thai"></span></p>
                                <p><strong>Ưu tiên:</strong> <span id="detail_uu_tien"></span></p>
                                <p><strong>Ngày bắt đầu:</strong> <span id="detail_ngay_bat_dau"></span></p>
                                <p><strong>Ngày kết thúc:</strong> <span id="detail_ngay_ket_thuc"></span></p>
                                <p><strong>Tiến độ:</strong> <span id="detail_tien_do"></span>%</p>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>
        <script>
            const USER_PERMISSIONS = <%= session.getAttribute("quyen") %>;
        </script>
        <script>
            // View Toggle Script
            document.addEventListener('DOMContentLoaded', function() {
                const viewToggles = document.querySelectorAll('.view-toggle-btn');
                const cardView = document.getElementById('cardView');
                const tableView = document.getElementById('tableView');
                
                viewToggles.forEach(btn => {
                    btn.addEventListener('click', function() {
                        const view = this.getAttribute('data-view');
                        
                        // Update active state
                        viewToggles.forEach(b => b.classList.remove('active'));
                        this.classList.add('active');
                        
                        // Toggle views
                        if (view === 'card') {
                            cardView.style.display = 'grid';
                            tableView.style.display = 'none';
                        } else {
                            cardView.style.display = 'none';
                            tableView.style.display = 'block';
                        }
                    });
                });
            });
        </script>
        <script src="<%= request.getContextPath() %>/scripts/project_nv.js?v=<%= System.currentTimeMillis() %>"></script>
    </body>
</html>
