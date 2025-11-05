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
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án: <%= request.getAttribute("tenDuan") %>';
            var PROJECT_ID = <%= request.getAttribute("projectId") %>;
        </script>
        <style>
            /* BODY + MAIN CONTENT */
            body {
                background: #f8fafc;
                font-family: 'Segoe UI', Roboto, sans-serif;
                color: #1e293b;
            }
            .header {
                background: #fff;
                border-bottom: 1px solid #e2e8f0;
                min-height: 64px;
                box-shadow: 0 2px 6px rgba(0,0,0,0.05);
                margin-left: 240px;
                position: sticky;
                top: 0;
                z-index: 20;
            }
            .main-content {
                padding: 32px;
                min-height: 100vh;
                margin-left: 240px;
                animation: fadeIn 0.5s ease;
            }
            .main-box {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 3px 12px rgba(0,0,0,0.08);
                padding: 28px 22px;
            }

            /* KANBAN BOARD */
            .kanban-board {
                display: flex;
                gap: 20px;
                overflow-x: auto;
                padding-bottom: 12px;
            }
            .kanban-col {
                background: #fff;
                border-radius: 16px;
                padding: 18px 14px;
                flex: 1 1 0;
                min-width: 260px;
                max-width: 340px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.06);
                border-top: 5px solid #e2e8f0;
                animation: slideUp 0.4s ease;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
            .kanban-col:hover {
                transform: translateY(-4px);
                box-shadow: 0 6px 20px rgba(0,0,0,0.12);
            }
            .kanban-col h5 {
                font-size: 1.1rem;
                font-weight: 600;
                margin-bottom: 16px;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            /* Column colors */
            .kanban-col.not-started {
                border-color: #94a3b8;
            }
            .kanban-col.in-progress {
                border-color: #facc15;
            }
            .kanban-col.completed   {
                border-color: #22c55e;
            }
            .kanban-col.late        {
                border-color: #ef4444;
            }

            .kanban-col.not-started h5 {
                color: #64748b;
            }
            .kanban-col.in-progress h5 {
                color: #eab308;
            }
            .kanban-col.completed h5   {
                color: #16a34a;
            }
            .kanban-col.late h5        {
                color: #dc2626;
            }

            /* TASK CARDS */
            .kanban-task {
                background: #fff;
                border-radius: 12px;
                padding: 14px;
                margin-bottom: 14px;
                box-shadow: 0 1px 6px rgba(0,0,0,0.08);
                border-left: 6px solid #0dcaf0;
                cursor: pointer;
                transition: transform 0.15s ease, box-shadow 0.15s ease;
            }
            .kanban-task:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 14px rgba(0,0,0,0.12);
                border-color: #4f46e5;
            }
            .task-title {
                font-weight: 600;
                font-size: 1rem;
                margin-bottom: 4px;
            }
            .task-meta {
                font-size: 0.9rem;
                color: #6b7280;
                margin-bottom: 6px;
            }
            .progress {
                height: 7px;
                border-radius: 6px;
            }

            /* TASK ACTIONS */
            .task-actions .btn {
                border-radius: 50px;
                padding: 4px 8px;
                transition: all 0.2s ease;
            }
            .task-actions .btn-danger {
                background: linear-gradient(90deg,#ef4444,#dc2626);
                border: none;
                color: #fff;
            }
            .task-actions .btn-danger:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(220,38,38,0.4);
            }

            /* MODALS */
            .modal-content {
                border-radius: 16px;
                box-shadow: 0 6px 22px rgba(0,0,0,0.2);
                animation: fadeIn 0.4s ease;
            }
            .modal-header {
                border-bottom: 1px solid #f1f5f9;
            }
            .modal-footer {
                border-top: 1px solid #f1f5f9;
            }
            .btn-primary {
                background: linear-gradient(90deg,#0dcaf0,#4f46e5);
                border: none;
            }
            .btn-primary:hover {
                background: linear-gradient(90deg,#4f46e5,#0dcaf0);
            }

            /* ==== FIX BUTTON XÓA ==== */
            .kanban-task {
                position: relative; /* để absolute của task-actions ăn theo */
            }

            .task-actions {
                position: absolute;
                top: 8px;
                right: 8px;
                display: flex;
                gap: 6px;
            }

            .task-actions .btn {
                border-radius: 50%;
                width: 28px;
                height: 28px;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 0;
                font-size: 0.85rem;
                transition: transform 0.2s, box-shadow 0.2s;
            }

            .task-actions .btn-danger {
                background: linear-gradient(90deg, #ef4444, #dc2626);
                border: none;
                color: #fff;
            }
            .task-actions .btn-danger:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(220,38,38,0.4);
            }

            /* ==== FIX NÚT + THÊM TASK ==== */
            .kanban-col .kanban-add-btn {
                margin-bottom: 16px; /* tạo khoảng cách với task */
                border-radius: 20px;
                font-size: 0.95rem;
                background: #f9fafb;
                border: 1px dashed #cbd5e1;
                transition: background 0.2s, border 0.2s;
            }

            .kanban-col .kanban-add-btn:hover {
                background: #e0f2fe;
                border-color: #0dcaf0;
            }

            /* ==== NÚT + THÊM TASK (đẹp hơn) ==== */
            .kanban-col .kanban-add-btn {
                margin-bottom: 18px;
                border: none;
                border-radius: 12px;
                font-size: 0.95rem;
                font-weight: 500;
                color: #fff;
                background: linear-gradient(90deg, #0dcaf0, #4f46e5);
                box-shadow: 0 3px 10px rgba(13, 202, 240, 0.3);
                padding: 10px 14px;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
                transition: all 0.25s ease;
            }

            .kanban-col .kanban-add-btn i {
                font-size: 1rem;
            }

            .kanban-col .kanban-add-btn:hover {
                background: linear-gradient(90deg, #4f46e5, #0dcaf0);
                transform: translateY(-2px) scale(1.03);
                box-shadow: 0 6px 18px rgba(79, 70, 229, 0.35);
            }

            /* ANIMATIONS */
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(8px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* RESPONSIVE */
            @media (max-width: 992px) {
                .main-content {
                    margin-left: 60px;
                    padding: 20px;
                }
            }
            @media (max-width: 768px) {
                .main-box {
                    padding: 16px;
                }
                .main-content {
                    padding: 12px;
                }
                .kanban-board {
                    flex-direction: column;
                    gap: 16px;
                }
            }

            /* ==== CHỮ TRONG TASK ==== */
            .task-title {
                font-weight: 600;
                font-size: 1.1rem; /* trước ~1rem, tăng 2 size */
                margin-bottom: 6px;
            }

            .task-meta {
                font-size: 0.95rem; /* trước ~0.9rem, tăng 2 size */
                color: #4b5563;
                margin-bottom: 8px;
            }

            .task-priority,
            .task-status {
                font-size: 0.9rem; /* trước ~0.85-0.9rem */
                padding: 4px 8px;
                border-radius: 8px;
            }

            /* Progress bar trong task */
            .kanban-task .progress {
                height: 7px;
                border-radius: 6px;
                margin-top: 10px;      /* tạo khoảng cách phía trên */
                margin-bottom: 6px;    /* tạo khoảng cách phía dưới */
                background-color: #e5e7eb; /* nền xám nhạt để nhìn rõ */
            }
            .kanban-task .progress-bar {
                border-radius: 6px;
            }

        </style>
    </head>

    <body>
        <div class="d-flex">
            <%@ include file="sidebarnv.jsp" %>
            <!-- Main -->
            <div class="flex-grow-1">
                <!-- Header -->
                <%@ include file="header.jsp" %>
                <div class="main-content">
                    <div class="main-box mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h3 class="mb-0"><i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án: <%= request.getAttribute("tenDuan") %></h3>
                            <a href="./dsDuannv" class="btn btn-secondary rounded-pill px-3"><i class="fa-solid fa-arrow-left"></i> Quay lại dự án</a>
                        </div>
                        <div class="row mb-2 g-2" id="phongban">
                            <div class="col-md-3">
                                <input type="text" name="keyword" class="form-control" placeholder="Tìm kiếm tên công việc...">
                            </div>
                            <% String vaiTro = (String) session.getAttribute("vaiTro"); %>
                            <div class="col-md-3">
                                <select class="form-select" name="ten_phong_ban" id="phongSelect"
                                        <%= !"Admin".equalsIgnoreCase(vaiTro) ? "disabled" : "" %>>
                                </select>
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
                    </div>

                    <!-- Kanban board -->
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
                            <h5><i  class="fa-solid fa-hourglass-start"></i><%= trangThaiLabels.get(status) %></h5>
                                <% }else if("Đang thực hiện".equals(status)) { %>
                            <h5><i class="fa-solid fa-hourglass-start"></i><%= trangThaiLabels.get(status) %></h5>
                                <% }else if("Đã hoàn thành".equals(status)) { %>
                            <h5><i class="fa-solid fa-check-circle"></i><%= trangThaiLabels.get(status) %></h5> 
                                <% }else if("Trễ hạn".equals(status)) { %>
                            <h5><i class="fa-solid fa-exclamation-circle"></i><%= trangThaiLabels.get(status) %></h5>
                                <% } %>   
                                <% if ("Chưa bắt đầu".equals(status)) { %>
                            <% } %>
                            <% for (Map<String, Object> task : taskList) {
                                   if (status.equals(task.get("trang_thai"))) {
                            %>
                            <div class="kanban-task" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"
                                 data-id="<%= task.get("id") %>"
                                 data-ten="<%= task.get("ten_cong_viec") %>"
                                 data-mo-ta="<%= task.get("mo_ta") %>"
                                 data-han="<%= task.get("han_hoan_thanh") %>"
                                 data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
                                 data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
                                 data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_ten") %>"
                                 data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
                                 data-trang-thai="<%= task.get("trang_thai") %>"
                                 data-tai_lieu_cv="<%= task.get("tai_lieu_cv") %>"
                                 data-file_tai_lieu="<%= task.get("file_tai_lieu") %>">
                                <div class="task-title"><%= task.get("ten_cong_viec") %></div>
                                <div class="task-meta">Người giao: <b><%= task.get("nguoi_giao_id") %></b> <br>Người nhận: <b><%= task.get("nguoi_nhan_ten") %></b></div>
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
                                <!-- Nút xóa công việc đã bị ẩn cho nhân viên -->
                            </div>
                            <% }} %>
                        </div>
                        <% } %>
                    </div>
                    <!-- Modal tạo/sửa task -->
                    <div class="modal fade" id="modalTask" tabindex="-1">
                        <div class="modal-dialog">
                            <form class="modal-content" id="taskForm" enctype="multipart/form-data">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-tasks"></i> Thông tin công việc
                                    </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <input type="hidden" name="id">
                                    <div class="mb-3">
                                        <label class="form-label"><b>Tên công việc</b></label>
                                        <input type="text" class="form-control" name="ten_cong_viec" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label"><b>Mô tả</b></label>
                                        <textarea class="form-control" name="mo_ta" id="taskMoTa"></textarea>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label"><b>Hạn hoàn thành</b></label>
                                        <input type="date" class="form-control" name="han_hoan_thanh">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label"><b>Mức độ ưu tiên</b></label>
                                        <select class="form-select" name="muc_do_uu_tien">
                                            <option value="Thấp" selected>Thấp</option>
                                            <option value="Trung bình">Trung bình</option>
                                            <option value="Cao">Cao</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label"><b>Người giao</b></label>
                                        <select class="form-select" name="ten_nguoi_giao" id="nguoiGiaoSelect">
                                            <!-- AJAX load nhân viên -->
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label"><b>Người nhận</b></label>
                                        <div class="input-group mb-2">
                                            <select class="form-select" id="nguoiNhanSelect2">
                                                <!-- Dữ liệu nhân viên load bằng AJAX -->
                                            </select>
                                            <button type="button" class="btn btn-outline-primary" id="btnThemNguoiNhan2">
                                                <i class="fa-solid fa-user-plus"></i> Thêm
                                            </button>
                                        </div>
                                        <div id="danhSachNguoiNhan2" class="d-flex flex-wrap gap-2">
                                            <!-- Tag tên người nhận sẽ hiển thị ở đây -->
                                        </div>
                                        <input type="hidden" name="ten_nguoi_nhan" id="nguoiNhanHidden2">
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label"><b>Phòng ban</b></label>
                                        <select class="form-select" name="ten_phong_ban" id="phongSelect">
                                            <!-- Sẽ được load từ API -->
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label"><b>Tài liệu công việc (Link Driver)</b></label>
                                        <input type="text" class="form-control" name="tai_lieu_cv">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label"><b>File công việc</b></label>
                                        <input class="form-control" type="file" name="files" id="taskFiles" multiple>
                                        <div id="taskFileList" class="form-text text-muted small mt-1">
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="submit" class="btn btn-primary rounded-pill " id="btnInsertTask">Lưu</button>
                                    <button type="button" class="btn btn-secondary rounded-pill"
                                            data-bs-dismiss="modal">Huỷ</button>
                                </div>
                            </form>
                        </div>
                    </div>
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
                                            <button class="nav-link" id="tab-task-history" data-bs-toggle="tab"
                                                    data-bs-target="#tabTaskHistory" type="button" role="tab">Lịch sử</button>
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
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Tên công việc</b></label>
                                                    <input type="text" class="form-control" name="ten_cong_viec">
                                                </div>
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Mô tả</b></label>
                                                    <textarea class="form-control" rows="3" name="mo_ta"></textarea>
                                                </div>
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Hạn hoàn thành</b></label>
                                                    <input type="date" class="form-control" name="han_hoan_thanh">
                                                </div>
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Mức độ ưu tiên</b></label>
                                                    <select class="form-select" name="muc_do_uu_tien">
                                                        <option>Cao</option>
                                                        <option>Trung bình</option>
                                                        <option>Thấp</option>
                                                    </select>
                                                </div>
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Người giao</b></label>
                                                    <select class="form-select" name="ten_nguoi_giao"></select>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label"><b>Người nhận</b></label>
                                                    <div class="input-group mb-2">
                                                        <select class="form-select" id="nguoiNhanSelect">
                                                            <!-- Dữ liệu nhân viên load bằng AJAX -->
                                                        </select>
                                                        <button type="button" class="btn btn-outline-primary" id="btnThemNguoiNhan">
                                                            <i class="fa-solid fa-user-plus"></i> Thêm
                                                        </button>
                                                    </div>
                                                    <div id="danhSachNguoiNhan" class="d-flex flex-wrap gap-2">
                                                        <!-- Tag tên người nhận sẽ hiển thị ở đây -->
                                                    </div>
                                                </div>
                                                <input type="hidden" name="ten_nguoi_nhan" id="nguoiNhanHidden">
                                                <!-- Input ẩn để lưu danh sách -->
                                                <input type="hidden" name="ten_nguoi_nhan" id="nguoiNhanHidden">
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Phòng ban:</b></label>
                                                    <select class="form-select" name="ten_phong_ban"></select>
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
                                                    <label for="taskAttachment" class="form-label"><b>Tài liệu công việc (Link Driver)</b></label>
                                                    <input type="text" class="form-control" name="tai_lieu_cv">
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label"><b>File công việc</b></label>
                                                    <input class="form-control" type="file" name="files" id="taskFiles2" multiple>
                                                    <div id="taskFileList2" class="form-text text-muted small mt-1">
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
                                            <button class="btn btn-outline-primary btn-sm mb-3" id="btnAddProcessStep">
                                                <i class="fa-solid fa-plus"></i> Thêm quy trình
                                            </button>
                                            <ul id="processStepList" class="list-group mb-2"></ul>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                            </div>
                                        </div>

                                        <div class="tab-pane fade" id="tabTaskHistory" role="tabpanel">
                                            <ul id="taskHistoryList">
                                                <li>09/06/2024: Tạo công việc</li>
                                                <li>10/06/2024: Cập nhật tiến độ 50%</li>
                                            </ul>
                                        </div>

                                        <div class="tab-pane fade" id="tabTaskReview" role="tabpanel">
                                            <form id="taskReviewForm" class="mb-3">
                                                <input type="hidden" id="taskId" name="task_id" value="">
                                                <div class="mb-2">
                                                    <label for="reviewerName" class="form-label">Người đánh giá:</label>
                                                    <select class="form-select" name="ten_nguoi_danh_gia"></select>
                                                    <!--                                                    <input type="text" class="form-control" id="reviewerName"
                                                                                                               placeholder="Nhập tên người đánh giá">-->
                                                </div>
                                                <div class="mb-2">
                                                    <label for="reviewComment" class="form-label">Nhận xét:</label>
                                                    <textarea class="form-control" id="reviewComment" rows="3"
                                                              placeholder="Nhập nhận xét..."></textarea>
                                                </div>
                                                <button type="button" class="btn btn-success" id="btnAddReview">
                                                    <i class="fa-solid fa-plus"></i> Thêm đánh giá
                                                </button>
                                            </form>
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
                    <!-- Modal thêm quy trình/giai đoạn -->
                    <div class="modal fade" id="modalAddProcessStep" tabindex="-1">
                        <div class="modal-dialog">
                            <form class="modal-content" id="formAddProcessStep">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-list-check"></i> Thêm bước quy
                                        trình</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="mb-2">
                                        <input type="hidden" name="stepid">
                                        <label class="form-label">Tên bước/giai đoạn</label>
                                        <input type="text" class="form-control" name="stepName" required>
                                    </div>
                                    <div class="mb-2">
                                        <label class="form-label">Mô tả</label>
                                        <textarea class="form-control" name="stepDesc" rows="2"></textarea>
                                    </div>
                                    <div class="mb-2">
                                        <label class="form-label">Trạng thái</label>
                                        <select class="form-select" name="stepStatus">
                                            <option value="Chưa bắt đầu">Chưa bắt đầu</option>
                                            <option value="Đang thực hiện">Đang thực hiện</option>
                                            <option value="Đã hoàn thành">Đã hoàn thành</option>
                                        </select>
                                    </div>
                                    <div class="mb-2 row">
                                        <div class="col">
                                            <label class="form-label">Ngày bắt đầu</label>
                                            <input type="date" class="form-control" name="stepStart">
                                        </div>
                                        <div class="col">
                                            <label class="form-label">Ngày kết thúc</label>
                                            <input type="date" class="form-control" name="stepEnd">
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="submit" class="btn btn-primary rounded-pill">Thêm bước</button>
                                    <button type="button" class="btn btn-secondary rounded-pill"
                                            data-bs-dismiss="modal">Huỷ</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="<%= request.getContextPath() %>/scripts/project_tasknv.obf.js?v=20251105"></script>

    </body>
</html>
