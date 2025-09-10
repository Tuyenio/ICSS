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
            var PAGE_TITLE = '<i class="fa-solid fa-tasks me-2"></i>Quản lý Công việc';
        </script>
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
                position: sticky;
                top: 0;
                z-index: 20;
            }

            .avatar {
                width: 38px;
                height: 38px;
                border-radius: 50%;
                object-fit: cover;
            }

            .main-content {
                padding: 36px 36px 24px 36px;
                min-height: 100vh;
                margin-left: 240px;
            }

            .main-box {
                background: #fff;
                border-radius: 14px;
                box-shadow: 0 2px 12px #0001;
                padding: 32px 24px;
            }

            .kanban-board {
                display: flex;
                gap: 24px;
                overflow-x: auto;
                min-height: 420px;
                margin-bottom: 32px;
            }

            .kanban-col {
                background: #f8fafd;
                border-radius: 18px;
                padding: 18px 12px;
                flex: 1 1 0;
                min-width: 270px;
                max-width: 340px;
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
                box-shadow: 0 4px 16px #0dcaf033;
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

            /* Màu sắc cho từng cột */
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

            /* Responsive */
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

                .main-content {
                    padding: 10px 2px;
                }
            }
        </style>
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
                        <a href="./dsCongviec" class="active"><i class="fa-solid fa-tasks"></i><span>Công việc</span></a>
                    </li>
                    <li>
                        <a href="./dsPhongban"><i class="fa-solid fa-building"></i><span>Phòng ban</span></a>
                    </li>
                    <li>
                        <a href="./dsChamCong"><i class="fa-solid fa-calendar-check"></i><span>Chấm công</span></a>
                    </li>
                    <li>
                        <a href="./svBaocao"><i class="fa-solid fa-chart-bar"></i><span>Báo cáo</span></a>
                    </li>
                </ul>
            </nav>
            <!-- Main -->
            <div class="flex-grow-1">
                <!-- Header -->
                <%@ include file="header.jsp" %>
                <div class="main-content">
                    <div class="main-box mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h3 class="mb-0"><i class="fa-solid fa-tasks me-2"></i>Quản lý Công việc</h3>
                            <button class="btn btn-primary rounded-pill px-3" data-bs-toggle="modal"
                                    data-bs-target="#modalTask">
                                <i class="fa-solid fa-plus"></i> Tạo công việc
                            </button>
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
                            <button class="btn btn-outline-secondary kanban-add-btn" data-bs-toggle="modal"
                                    data-bs-target="#modalTask">
                                <i class="fa-solid fa-plus"></i> Thêm task
                            </button>
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
                                 data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_id") %>"
                                 data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
                                 data-trang-thai="<%= task.get("trang_thai") %>"
                                 data-tai_lieu_cv="<%= task.get("tai_lieu_cv") %>">
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
                                <div class="task-actions">
                                    <form action="./xoaCongviec" method="post" onsubmit="return confirm('Bạn có chắc muốn xóa công việc này không?');">
                                        <input type="hidden" name="id" value="<%= task.get("id") %>">
                                        <button type="submit" class="btn btn-sm btn-danger">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </form>
                                </div>
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
                                        <label class="form-label">Tên công việc</label>
                                        <input type="text" class="form-control" name="ten_cong_viec" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Mô tả</label>
                                        <textarea class="form-control" name="mo_ta" id="taskMoTa"></textarea>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Hạn hoàn thành</label>
                                        <input type="date" class="form-control" name="han_hoan_thanh">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Mức độ ưu tiên</label>
                                        <select class="form-select" name="muc_do_uu_tien">
                                            <option value="Thấp" selected>Thấp</option>
                                            <option value="Trung bình">Trung bình</option>
                                            <option value="Cao">Cao</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Người giao</label>
                                        <select class="form-select" name="ten_nguoi_giao" id="nguoiGiaoSelect">
                                            <!-- AJAX load nhân viên -->
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Người nhận</label>
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
                                        <label class="form-label">Phòng ban</label>
                                        <select class="form-select" name="ten_phong_ban" id="phongSelect">
                                            <!-- Sẽ được load từ API -->
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Tài liệu công việc</label>
                                        <input type="text" class="form-control" name="tai_lieu_cv">
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
                                                    <label class="form-label"><b>Tên công việc:</b></label>
                                                    <input type="text" class="form-control" name="ten_cong_viec">
                                                </div>
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Mô tả:</b></label>
                                                    <textarea class="form-control" rows="3" name="mo_ta"></textarea>
                                                </div>
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Hạn hoàn thành:</b></label>
                                                    <input type="date" class="form-control" name="han_hoan_thanh">
                                                </div>
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Mức độ ưu tiên:</b></label>
                                                    <select class="form-select" name="muc_do_uu_tien">
                                                        <option>Cao</option>
                                                        <option>Trung bình</option>
                                                        <option>Thấp</option>
                                                    </select>
                                                </div>
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Người giao:</b></label>
                                                    <select class="form-select" name="ten_nguoi_giao"></select>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label">Người nhận</label>
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
                                                    <label for="taskAttachment" class="form-label"><b>Tài liệu công việc:</b></label>
                                                    <input type="text" class="form-control" name="tai_lieu_cv">
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
        //
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                var buttonsThemNguoiNhan = document.querySelectorAll("#btnThemNguoiNhan2");
                buttonsThemNguoiNhan.forEach(function (btnThem) {
                    btnThem.addEventListener("click", function () {
                        var container = btnThem.closest(".mb-3"); // nhóm đang thao tác
                        var selectNguoiNhan = container.querySelector("select");
                        var danhSachDiv = container.querySelector("#danhSachNguoiNhan2");
                        var hiddenInput = container.parentElement.querySelector("#nguoiNhanHidden2");

                        if (!selectNguoiNhan || !danhSachDiv || !hiddenInput)
                            return;

                        var selectedOption = selectNguoiNhan.options[selectNguoiNhan.selectedIndex];
                        if (!selectedOption || !selectedOption.value)
                            return;

                        var ten = selectedOption.text.trim();
                        var existing = danhSachDiv.querySelectorAll("span");
                        for (var i = 0; i < existing.length; i++) {
                            if (existing[i].dataset.ten === ten) {
                                showToast('info', 'Người này đã được thêm.');
                                return;
                            }
                        }

                        var tag = document.createElement("span");
                        tag.className = "badge bg-primary d-flex align-items-center me-2";
                        tag.style.padding = "0.5em 0.75em";
                        tag.dataset.ten = ten;
                        tag.innerHTML = ten +
                                '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';
                        tag.querySelector(".btn-close").addEventListener("click", function () {
                            tag.remove();
                            capNhatHiddenInput(danhSachDiv, hiddenInput);
                        });
                        danhSachDiv.appendChild(tag);

                        capNhatHiddenInput(danhSachDiv, hiddenInput);
                    });
                });

                function capNhatHiddenInput(danhSachDiv, hiddenInput) {
                    var values = [];
                    var badges = danhSachDiv.querySelectorAll("span");
                    for (var i = 0; i < badges.length; i++) {
                        values.push(badges[i].dataset.ten);
                    }
                    hiddenInput.value = values.join(",");
                }
            });
        </script>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                var buttonsThemNguoiNhan = document.querySelectorAll("#btnThemNguoiNhan");
                buttonsThemNguoiNhan.forEach(function (btnThem) {
                    btnThem.addEventListener("click", function () {
                        var container = btnThem.closest(".mb-3"); // nhóm đang thao tác
                        var selectNguoiNhan = container.querySelector("select");
                        var danhSachDiv = container.querySelector("#danhSachNguoiNhan");
                        var hiddenInput = container.parentElement.querySelector("#nguoiNhanHidden");

                        if (!selectNguoiNhan || !danhSachDiv || !hiddenInput)
                            return;

                        var selectedOption = selectNguoiNhan.options[selectNguoiNhan.selectedIndex];
                        if (!selectedOption || !selectedOption.value)
                            return;

                        var ten = selectedOption.text.trim();
                        var existing = danhSachDiv.querySelectorAll("span");
                        for (var i = 0; i < existing.length; i++) {
                            if (existing[i].dataset.ten === ten) {
                                showToast('info', 'Người này đã được thêm.');
                                return;
                            }
                        }

                        var tag = document.createElement("span");
                        tag.className = "badge bg-primary d-flex align-items-center me-2";
                        tag.style.padding = "0.5em 0.75em";
                        tag.dataset.ten = ten;
                        tag.innerHTML = ten +
                                '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';
                        tag.querySelector(".btn-close").addEventListener("click", function () {
                            tag.remove();
                            capNhatHiddenInput(danhSachDiv, hiddenInput);
                        });
                        danhSachDiv.appendChild(tag);

                        capNhatHiddenInput(danhSachDiv, hiddenInput);
                    });
                });

                function capNhatHiddenInput(danhSachDiv, hiddenInput) {
                    var values = [];
                    var badges = danhSachDiv.querySelectorAll("span");
                    for (var i = 0; i < badges.length; i++) {
                        values.push(badges[i].dataset.ten);
                    }
                    hiddenInput.value = values.join(",");
                }
            });
        </script>

        <script>
            // Hàm chọn option theo text
            function selectOptionByText(selectEl, targetText) {
                if (!selectEl || !targetText)
                    return;
                const normalizedTarget = targetText.trim().toLowerCase();
                const options = selectEl.options;
                for (let i = 0; i < options.length; i++) {
                    if (options[i].text.trim().toLowerCase() === normalizedTarget) {
                        selectEl.selectedIndex = i;
                        return;
                    }
                }
                selectEl.selectedIndex = -1; // Không tìm thấy
            }

            document.addEventListener("DOMContentLoaded", function () {
                // Load nhóm công việc
                fetch('./apiPhongban')
                        .then(res => res.text())
                        .then(html => {
                            const defaultOption = '<option value="" selected>Tất cả phòng ban</option>';
                            const finalHTML = defaultOption + html;
                            document.querySelector('#modalTaskDetail select[name="ten_phong_ban"]').innerHTML = finalHTML;
                            document.querySelector('#taskForm select[name="ten_phong_ban"]').innerHTML = finalHTML;
                            document.querySelector('#phongban select[name="ten_phong_ban"]').innerHTML = finalHTML;
                        });
                // Load danh sách nhân viên (giao & nhận)
                fetch('./apiNhanvien')
                        .then(res => res.text())
                        .then(html => {
                            document.querySelectorAll('#nguoiNhanSelect').forEach(el => el.innerHTML = html);
                            // (hoặc document.getElementById("nguoiNhanSelect").innerHTML = html;)
                        });
                fetch('./apiNhanvien')
                        .then(res => res.text())
                        .then(html => {
                            document.querySelectorAll('#nguoiNhanSelect2').forEach(el => el.innerHTML = html);
                            // (hoặc document.getElementById("nguoiNhanSelect").innerHTML = html;)
                        });
//                fetch('./apiNhanvien')
//                        .then(res => res.text())
//                        .then(html => {
//                            document.querySelector('#modalTaskDetail select[name="ten_nguoi_giao"]').innerHTML = html;
//                            document.querySelector('#modalTaskDetail select[name="ten_nguoi_nhan"]').innerHTML = html;
//                            document.querySelector('#modalTaskDetail select[name="ten_nguoi_danh_gia"]').innerHTML = html;
//                            document.querySelector('#taskForm select[name="ten_nguoi_giao"]').innerHTML = html;
//                            document.querySelector('#taskForm select[name="ten_nguoi_nhan"]').innerHTML = html;
//                        });
            });
            document.addEventListener("DOMContentLoaded", function () {
                const modal = document.getElementById("modalTaskDetail");
                modal.addEventListener("show.bs.modal", function (event) {
                    const button = event.relatedTarget;
                    if (!button)
                        return;
                    // Lấy dữ liệu từ nút
                    const id = button.getAttribute("data-id") || "";
                    const tenCV = button.getAttribute("data-ten") || "";
                    const moTa = button.getAttribute("data-mo-ta") || "";
                    const hanHT = button.getAttribute("data-han") || "";
                    const uuTien = button.getAttribute("data-uu-tien") || "";
                    const nguoiGiao = button.getAttribute("data-ten_nguoi_giao") || "";
                    const nguoiNhan = button.getAttribute("data-ten_nguoi_nhan") || "";
                    const phongban = button.getAttribute("data-ten_phong_ban") || "";
                    const trangthai = button.getAttribute("data-trang-thai") || "";
                    const tailieu = button.getAttribute("data-tai_lieu_cv") || "";
                    // Gán dữ liệu
                    modal.querySelector('[name="task_id"]').value = id;
                    modal.querySelector('[name="ten_cong_viec"]').value = tenCV;
                    modal.querySelector('[name="mo_ta"]').value = moTa;
                    modal.querySelector('[name="han_hoan_thanh"]').value = hanHT;
                    selectOptionByText(modal.querySelector('[name="muc_do_uu_tien"]'), uuTien);
                    selectOptionByText(modal.querySelector('[name="ten_nguoi_giao"]'), nguoiGiao);
                    selectOptionByText(modal.querySelector('[name="ten_nguoi_nhan"]'), nguoiNhan);
                    selectOptionByText(modal.querySelector('[name="ten_phong_ban"]'), phongban);
                    selectOptionByText(modal.querySelector('[name="trang_thai"]'), trangthai);
                    modal.querySelector('[name="tai_lieu_cv"]').value = tailieu;
                    // Mở lại tab đầu tiên khi show modal
                    const tabTrigger = modal.querySelector('#tab-task-info');
                    if (tabTrigger)
                        new bootstrap.Tab(tabTrigger).show();
                });
            });
        </script>
        <script>
            $('#taskForm').on('submit', function (e) {
                e.preventDefault(); // Ngăn form submit mặc định

                const taskId = $('#taskId').val(); // nếu có ID thì là sửa, không thì là thêm
                const formData = new FormData(this); // lấy dữ liệu form bao gồm cả file
                const url = taskId ? './capNhatCongviec' : './themCongviec';

                $.ajax({
                    url: url,
                    type: 'POST',
                    data: formData,
                    processData: false, // cần để gửi FormData
                    contentType: false, // cần để gửi FormData
                    success: function (response) {
                        if (response.success) {
                            $('#modalTask').modal('hide');
                            showToast('success', taskId ? 'Cập nhật thành công' : 'Thêm mới thành công');
                            location.reload();
                        } else {
                            showToast('error', response.message || (taskId ? 'Cập nhật thất bại' : 'Thêm mới thất bại'));
                        }
                    },
                    error: function () {
                        showToast('error', taskId ? 'Cập nhật thất bại' : 'Thêm mới thất bại');
                    }
                });
            });

        </script>
        <script>
            // ====== LƯU CÔNG VIỆC (SỬA) ======
            $('#btnSaveTask').on('click', function (e) {
                e.preventDefault();

                var $btn = $(this);
                var form = document.getElementById('formTaskDetail');
                var formData = new FormData(form);

                $.ajax({
                    url: './suaCongviec',
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    dataType: 'json',
                    beforeSend: function () {
                        $btn.prop('disabled', true).data('orig-text', $btn.html()).html('Đang lưu...');
                    },
                    success: function (response) {
                        var data = response;
                        if (typeof response === 'string') {
                            try {
                                data = JSON.parse(response);
                            } catch (e) {
                            }
                        }

                        if (data && data.success) {
                            $('#modalTaskDetail').modal && $('#modalTaskDetail').modal('hide');
                            showToast('success', 'Đã lưu thành công!');
                            location.reload();
                        } else {
                            var msg = (data && data.message) ? data.message : 'Lỗi khi lưu công việc';
                            showToast('error', msg);
                        }
                    },
                    error: function () {
                        showToast('error', 'Đã xảy ra lỗi kết nối máy chủ');
                    },
                    complete: function () {
                        $btn.prop('disabled', false).html($btn.data('orig-text') || 'Lưu');
                    }
                });
            });

            // ====== LỌC CÔNG VIỆC ======
            $('#btnFilter').on('click', function (e) {
                e.preventDefault();

                var $btn = $(this);
                var keyword = $('input[name="keyword"]').val() || '';
                var phongBan = $('select[name="ten_phong_ban"]').val() || '';
                var trangThai = $('select[name="trangThai"]').val() || '';

                $.ajax({
                    url: './locCongviec',
                    type: 'POST',
                    data: {
                        keyword: keyword,
                        phong_ban: phongBan,
                        trang_thai: trangThai
                    },
                    dataType: 'html',
                    beforeSend: function () {
                        $btn.prop('disabled', true).data('orig-text', $btn.html()).html('Đang lọc...');
                    },
                    success: function (html) {
                        if (html && $.trim(html).length > 0) {
                            $('.kanban-board').html(html);
                            showToast('success', 'Đã áp dụng bộ lọc.');
                        } else {
                            $('.kanban-board').html('<div class="text-center text-muted p-3">Không có dữ liệu phù hợp</div>');
                            showToast('info', 'Không tìm thấy kết quả phù hợp.');
                        }
                    },
                    error: function () {
                        $('.kanban-board').html('<div class="text-danger text-center p-3">Lỗi khi lọc công việc</div>');
                        showToast('error', 'Lỗi khi lọc công việc.');
                    },
                    complete: function () {
                        $btn.prop('disabled', false).html($btn.data('orig-text') || 'Lọc');
                    }
                });
            });

            // ====== HÀM TOAST DÙNG CHUNG ======
            function showToast(type, message) {
                var map = {
                    success: '#toastSuccess',
                    error: '#toastError',
                    info: '#toastInfo',
                    warning: '#toastWarning'
                };
                var toastId = map[type] || '#toastInfo';

                if ($(toastId).length === 0) {
                    var toastHtml =
                            '<div id="' + toastId.substring(1) + '" class="toast align-items-center border-0 position-fixed bottom-0 end-0 m-3" role="alert" aria-live="assertive" aria-atomic="true">' +
                            '<div class="d-flex">' +
                            '<div class="toast-body"></div>' +
                            '<button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>' +
                            '</div>' +
                            '</div>';
                    $('body').append(toastHtml);
                }

                $(toastId).find('.toast-body').text(message);
                var bsToast = new bootstrap.Toast($(toastId)[0], {delay: 2500, autohide: true});
                bsToast.show();
            }
        </script>
        <script>
            // Danh sách các bước quy trình (demo, nên dùng AJAX thực tế)
            var processSteps = [
                {
                    id: "12",
                    name: "Thiết kế UI",
                    desc: "Thiết kế giao diện người dùng",
                    status: "Hoàn thành",
                    start: "2024-06-01",
                    end: "2024-06-03"
                }
            ];

            function calcProgressPercent(list) {
                var steps = list || processSteps;
                if (!steps || steps.length === 0)
                    return 0;
                var done = steps.filter(function (s) {
                    return s.status === "Đã hoàn thành";
                }).length;
                return Math.round((done / steps.length) * 100);
            }

            // Hiển thị các bước quy trình với nút chỉnh sửa trạng thái (logic đẹp mắt, chỉ 1 nút)
            function renderProcessSteps() {
                var percent = calcProgressPercent();
                var barClass = percent === 100 ? "bg-success" : "bg-warning";
                $('#taskProgressBar')
                        .css('width', percent + '%')
                        .removeClass('bg-warning bg-success')
                        .addClass(barClass)
                        .text(percent + '%');

                // 👇 Gửi phần trăm về server
                var taskId = $('#taskId').val();
                if (taskId) {
                    $.ajax({
                        url: 'capnhatTiendo',
                        method: 'POST',
                        data: {cong_viec_id: taskId, phan_tram: percent},
                        success: function () {
                            showToast('success', 'Cập nhật tiến độ thành công');
                        },
                        error: function () {
                            showToast('error', 'Lỗi khi cập nhật tiến độ');
                        }
                    });
                }

                var list = $('#processStepList');
                list.empty();
                if (processSteps.length === 0) {
                    list.append('<li class="list-group-item text-muted">Chưa có bước quy trình nào.</li>');
                } else {
                    processSteps.forEach(function (step, idx) {
                        var badgeClass = "bg-secondary";
                        if (step.status === "Đã hoàn thành")
                            badgeClass = "bg-success";
                        else if (step.status === "Đang thực hiện")
                            badgeClass = "bg-warning text-dark";
                        else if (step.status === "Trễ hạn")
                            badgeClass = "bg-danger";

                        var editBtn =
                                '<button class="btn btn-sm btn-outline-secondary me-1" onclick="showEditStepModal(' + idx + ')">' +
                                '<i class="fa-solid fa-pen"></i> Chỉnh sửa</button>';
                        var deleteBtn =
                                '<button class="btn btn-sm btn-danger ms-1" onclick="removeProcessStep(' + idx + ')">' +
                                '<i class="fa-solid fa-trash"></i></button>';

                        var html = '<li class="list-group-item d-flex justify-content-between align-items-center">' +
                                '<div>' +
                                '<b>' + step.name + '</b> ' +
                                '<span class="badge ' + badgeClass + '">' + step.status + '</span><br>' +
                                '<small>' + (step.desc ? step.desc : '') + '</small>' +
                                '<div class="text-muted small">Từ ' + (step.start || '-') + ' đến ' + (step.end || '-') + '</div>' +
                                '</div>' +
                                '<div>' + editBtn + deleteBtn + '</div>' +
                                '</li>';
                        list.append(html);
                    });
                }
            }

            function renderTaskReviews(data) {
                var list = document.getElementById("taskReviewList");
                list.innerHTML = "";
                data.forEach(function (item) {
                    var li = document.createElement("li");
                    var html = "<b>Người đánh giá:</b> " + item.ten_nguoi_danh_gia + "<br>" +
                            "<b>Nhận xét:</b> " + item.nhan_xet + "<br>" +
                            "<i class='text-muted'>" + item.thoi_gian + "</i>";
                    li.innerHTML = html;
                    li.classList.add("mb-2", "border", "p-2", "rounded");
                    list.appendChild(li);
                });
            }

            function showEditStepModal(idx) {
                var step = processSteps[idx];
                var modalHtml =
                        '<div class="modal fade" id="modalEditStepStatus" tabindex="-1">' +
                        '<div class="modal-dialog">' +
                        '<form class="modal-content" id="formEditStepStatus">' +
                        '<input type="hidden" name="stepid" value="' + step.id + '">' +
                        '<div class="modal-header">' +
                        '<h5 class="modal-title"><i class="fa-solid fa-pen"></i> Chỉnh sửa bước quy trình</h5>' +
                        '<button type="button" class="btn-close" data-bs-dismiss="modal"></button>' +
                        '</div>' +
                        '<div class="modal-body">' +
                        '<div class="mb-2">' +
                        '<label class="form-label">Tên bước/giai đoạn</label>' +
                        '<input type="text" class="form-control" name="stepName" value="' + step.name + '" required>' +
                        '</div>' +
                        '<div class="mb-2">' +
                        '<label class="form-label">Mô tả</label>' +
                        '<textarea class="form-control" name="stepDesc" rows="2">' + (step.desc || '') + '</textarea>' +
                        '</div>' +
                        '<div class="mb-2">' +
                        '<label class="form-label">Trạng thái</label>' +
                        '<select class="form-select" name="stepStatus">' +
                        '<option value="Chưa bắt đầu"' + (step.status === "Chưa bắt đầu" ? " selected" : "") + '>Chưa bắt đầu</option>' +
                        '<option value="Đang thực hiện"' + (step.status === "Đang thực hiện" ? " selected" : "") + '>Đang thực hiện</option>' +
                        '<option value="Đã hoàn thành"' + (step.status === "Đã hoàn thành" ? " selected" : "") + '>Đã hoàn thành</option>' +
                        '</select>' +
                        '</div>' +
                        '<div class="mb-2 row">' +
                        '<div class="col"><label class="form-label">Ngày bắt đầu</label>' +
                        '<input type="date" class="form-control" name="stepStart" value="' + (step.start || '') + '"></div>' +
                        '<div class="col"><label class="form-label">Ngày kết thúc</label>' +
                        '<input type="date" class="form-control" name="stepEnd" value="' + (step.end || '') + '"></div>' +
                        '</div>' +
                        '</div>' +
                        '<div class="modal-footer">' +
                        '<button type="submit" class="btn btn-primary rounded-pill">Cập nhật</button>' +
                        '<button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>' +
                        '</div>' +
                        '</form>' +
                        '</div>' +
                        '</div>';
                $('#modalEditStepStatus').remove();
                $('body').append(modalHtml);
                var modal = new bootstrap.Modal(document.getElementById('modalEditStepStatus'));
                modal.show();

                $('#formEditStepStatus').on('submit', function (e) {
                    e.preventDefault();
                    processSteps[idx] = {
                        id: $(this).find('[name="stepid"]').val(),
                        name: $(this).find('[name="stepName"]').val(),
                        desc: $(this).find('[name="stepDesc"]').val(),
                        status: $(this).find('[name="stepStatus"]').val(),
                        start: $(this).find('[name="stepStart"]').val(),
                        end: $(this).find('[name="stepEnd"]').val()
                    };
                    renderProcessSteps();
                    modal.hide();
                    $('#modalEditStepStatus').remove();
                    var taskId = document.getElementById("taskId").value;
                    $.ajax({
                        url: './apiTaskSteps',
                        method: 'POST',
                        data: {
                            step_id: processSteps[idx].id,
                            name: processSteps[idx].name,
                            desc: processSteps[idx].desc,
                            status: processSteps[idx].status,
                            start: processSteps[idx].start,
                            end: processSteps[idx].end
                        },
                        success: function () {
                            showToast('success', 'Cập nhật bước thành công');
                        },
                        error: function () {
                            showToast('error', 'Cập nhật bước thất bại');
                        }
                    });
                });
                $('#modalEditStepStatus').on('hidden.bs.modal', function () {
                    $('#modalEditStepStatus').remove();
                });
            }

            window.removeProcessStep = function (idx) {
                var step = processSteps[idx];
                if (!step || !step.id) {
                    showToast('error', 'Không thể xác định bước cần xóa.');
                    return;
                }
                if (confirm("Bạn có chắc chắn muốn xóa bước này không?")) {
                    $.ajax({
                        url: './xoaQuytrinh',
                        method: 'POST',
                        data: {action: 'delete', step_id: step.id},
                        success: function () {
                            processSteps.splice(idx, 1);
                            renderProcessSteps();
                            showToast('success', 'Đã xóa bước thành công.');
                        },
                        error: function () {
                            showToast('error', 'Xóa thất bại. Vui lòng thử lại.');
                        }
                    });
                }
            };

            $('#btnAddProcessStep').on('click', function () {
                $('#formAddProcessStep')[0].reset();
                $('#modalAddProcessStep').modal('show');
            });
            $('#formAddProcessStep').on('submit', function (e) {
                e.preventDefault();
                var taskId = document.getElementById("taskId").value;
                var step = {
                    name: $(this).find('[name="stepName"]').val(),
                    desc: $(this).find('[name="stepDesc"]').val(),
                    status: $(this).find('[name="stepStatus"]').val(),
                    start: $(this).find('[name="stepStart"]').val(),
                    end: $(this).find('[name="stepEnd"]').val()
                };
                $.ajax({
                    url: './xoaQuytrinh',
                    method: 'POST',
                    data: {
                        action: 'add',
                        task_id: taskId,
                        name: step.name,
                        desc: step.desc,
                        status: step.status,
                        start: step.start,
                        end: step.end
                    },
                    success: function (newStepId) {
                        step.id = newStepId;
                        processSteps.push(step);
                        renderProcessSteps();
                        $('#modalAddProcessStep').modal('hide');
                        showToast('success', 'Thêm bước thành công');
                    },
                    error: function () {
                        showToast('error', 'Thêm bước thất bại');
                    }
                });
            });

            $('#modalTaskDetail').on('show.bs.modal', function () {
                renderProcessSteps();
            });

            document.addEventListener("DOMContentLoaded", function () {
                var tabProgress = document.getElementById("tab-task-progress");
                tabProgress.addEventListener("shown.bs.tab", function () {
                    var taskId = document.getElementById("taskId").value;
                    $.ajax({
                        url: './apiTaskSteps?task_id=' + taskId,
                        method: 'GET',
                        success: function (data) {
                            processSteps = data;
                            renderProcessSteps();
                        },
                        error: function () {
                            showToast('error', 'Không thể tải quy trình.');
                        }
                    });
                });

                var tabReview = document.getElementById("tab-task-review");
                if (tabReview) {
                    tabReview.addEventListener("shown.bs.tab", function () {
                        var taskId = document.getElementById("taskId").value;
                        $.ajax({
                            url: './apiDanhgiaCV?taskId=' + taskId,
                            method: 'GET',
                            success: function (data) {
                                renderTaskReviews(data);
                            },
                            error: function () {
                                showToast('error', 'Không thể tải đánh giá.');
                            }
                        });
                    });
                }
            });

            document.getElementById("btnAddReview").addEventListener("click", function () {
                var taskId = document.getElementById("taskId").value;
                var reviewerSelect = document.querySelector('select[name="ten_nguoi_danh_gia"]');
                var reviewerId = reviewerSelect.value;
                var comment = document.getElementById("reviewComment").value.trim();

                if (!reviewerId || !comment) {
                    showToast('error', 'Vui lòng chọn người đánh giá và nhập nhận xét.');
                    return;
                }
                if (!confirm("Bạn có chắc chắn muốn thêm đánh giá này không?")) {
                    return;
                }
                var formData = new URLSearchParams();
                formData.append("cong_viec_id", taskId);
                formData.append("nguoi_danh_gia_id", reviewerId);
                formData.append("nhan_xet", comment);

                fetch("./apiDanhgiaCV", {
                    method: "POST",
                    headers: {"Content-Type": "application/x-www-form-urlencoded"},
                    body: formData.toString()
                })
                        .then(function (res) {
                            return res.json();
                        })
                        .then(function (data) {
                            if (data.success) {
                                showToast('success', 'Thêm đánh giá thành công!');
                                document.getElementById("reviewComment").value = "";
                                setTimeout(function () {
                                    loadTaskReviews(taskId);
                                }, 300);
                            } else {
                                showToast('error', 'Thêm thất bại: ' + (data.message || ''));
                            }
                        })
                        .catch(function () {
                            showToast('error', 'Đã xảy ra lỗi khi thêm đánh giá.');
                        });
            });

            function loadTaskReviews(taskId) {
                fetch("./apiDanhgiaCV?taskId=" + encodeURIComponent(taskId))
                        .then(function (res) {
                            return res.json();
                        })
                        .then(function (data) {
                            renderTaskReviews(data);
                        })
                        .catch(function () {
                            showToast('error', 'Không thể tải lại danh sách đánh giá.');
                        });
            }

            function updateAllTaskProgressBars() {
                document.querySelectorAll('.task-progress-bar').forEach(function (bar) {
                    var taskId = bar.getAttribute('data-task-id');
                    fetch('./apiTaskSteps?task_id=' + encodeURIComponent(taskId))
                            .then(function (res) {
                                return res.json();
                            })
                            .then(function (steps) {
                                var percent = calcProgressPercent(steps);
                                var barClass = "bg-warning";
                                if (percent === 100)
                                    barClass = "bg-success";
                                else if (percent === 0)
                                    barClass = "bg-secondary";
                                bar.style.width = percent + "%";
                                bar.textContent = percent + "%";
                                bar.className = "progress-bar task-progress-bar " + barClass;
                            })
                            .catch(function () {
                                showToast('error', 'Lỗi khi tải bước quy trình');
                            });
                });
            }
            document.addEventListener("DOMContentLoaded", function () {
                updateAllTaskProgressBars();
            });
        </script>
    </body>
</html>
