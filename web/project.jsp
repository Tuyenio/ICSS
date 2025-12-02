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
            /* ============================
      PROJECT LIST VIEW (PREMIUM)
   ============================ */

            body {
                background: #f8fafc;
                font-family: 'Segoe UI', Roboto, sans-serif;
                color: #1e293b;
            }

            /* ----- MAIN CONTENT FADE IN ----- */
            .main-content {
                padding: 32px;
                min-height: 100vh;
                margin-left: 240px;
                animation: fadeIn 0.5s ease;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(12px);
                }
                to   {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* ===============================
               🔵 LIST VIEW BOX
               =============================== */
            .project-list-view .table {
                background: white;
                border-radius: 16px;
                overflow: hidden;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
            }

            /* ===============================
               🔵 HEADER (THEAD)
               =============================== */
            .project-list-view thead {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                color: white;
            }

            .project-list-view thead th {
                padding: 16px 12px;
                font-weight: 600;
                border: none;
                cursor: pointer;
                user-select: none;
                vertical-align: middle;
            }

            .project-list-view thead th:hover {
                background: rgba(255,255,255,0.1);
            }

            /* Sort icon style */
            .project-list-view thead th.sortable::after {
                content: "\f0dc";
                font-family: "Font Awesome 6 Free";
                font-weight: 900;
                margin-left: 6px;
                opacity: 0.5;
                font-size: 0.8em;
            }

            .project-list-view thead th.sort-asc::after {
                content: "\f0de";
                opacity: 1;
            }

            .project-list-view thead th.sort-desc::after {
                content: "\f0dd";
                opacity: 1;
            }

            /* ===============================
               🔵 TABLE BODY
               =============================== */
            .project-list-view tbody tr {
                border-bottom: 1px solid #f1f5f9;
                transition: all 0.2s ease;
            }

            .project-list-view tbody tr:hover {
                background: linear-gradient(90deg, rgba(13,202,240,0.05), rgba(79,70,229,0.05));
                transform: translateX(4px);
                cursor: pointer;
            }

            .project-list-view tbody td {
                padding: 14px 12px;
                vertical-align: middle;
            }

            .project-name {
                font-weight: 600;
                color: #1e293b;
            }

            /* ===============================
               🔵 BADGES (ƯU TIÊN)
               =============================== */
            .badge.priority-high {
                background: linear-gradient(135deg, #ef4444, #dc2626);
            }
            .badge.priority-medium {
                background: linear-gradient(135deg, #f59e0b, #d97706);
            }
            .badge.priority-low {
                background: linear-gradient(135deg, #10b981, #059669);
            }
            .badge.priority-none {
                background: #94a3b8;
            }

            /* Badge chung */
            .project-list-view .badge {
                padding: 6px 12px;
                border-radius: 10px;
                font-weight: 500;
                font-size: 0.85rem;
            }

            /* ===============================
               🔵 PROGRESS BAR (TIẾN ĐỘ)
               =============================== */
            .project-progress .progress {
                height: 7px;
                border-radius: 6px;
                background: #e5e7eb;
            }

            .project-progress .progress-bar {
                border-radius: 6px;
            }

            .project-progress .percent {
                margin-left: 8px;
                font-weight: 700;
                color: #1e293b;
            }

            /* ===============================
               🔵 PROJECT ACTION BUTTONS
               =============================== */
            .project-actions-wrapper {
                display: flex;
                gap: 8px;
                justify-content: center;
            }

            .project-actions-wrapper .btn {
                border-radius: 10px;
                padding: 6px 10px;
                color: #fff;
                transition: all 0.25s ease;
            }

            /* Xem */
            .btn-info {
                background: linear-gradient(135deg,#0dcaf0,#4f46e5);
                border: none;
            }
            .btn-info:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 16px rgba(79,70,229,0.4);
            }

            /* Sửa */
            .btn-warning {
                background: linear-gradient(135deg,#facc15,#eab308);
                border: none;
            }
            .btn-warning:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 16px rgba(250,204,21,0.4);
            }

            /* Xóa */
            .btn-danger {
                background: linear-gradient(135deg,#ef4444,#dc2626);
                border: none;
            }
            .btn-danger:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 16px rgba(220,38,38,0.4);
            }

            /* Avatar Lead */
            .project-lead img {
                border-radius: 50%;
                box-shadow: 0 3px 8px rgba(0,0,0,0.15);
            }

            /* ===============================
               🔔 ROW ALERT (DỰ ÁN CÓ NHẮC VIỆC)
               =============================== */
            .project-row--alert {
                animation: rowBlink 1.1s ease-in-out infinite;
                position: relative;
            }

            .project-row--alert::before {
                content: "🔔";
                position: absolute;
                left: 6px;
                top: 50%;
                transform: translateY(-50%);
                font-size: 1rem;
                animation: bellPulse 2s infinite;
            }

            .project-row--alert td:first-child {
                padding-left: 32px !important;
            }

            @keyframes rowBlink {
                0%, 100% {
                    background: rgba(220,53,69,0.05);
                }
                50% {
                    background: rgba(220,53,69,0.15);
                }
            }

            @keyframes bellPulse {
                0%,100% {
                    transform: translateY(-50%) rotate(0deg);
                }
                25% {
                    transform: translateY(-50%) rotate(10deg);
                }
                50% {
                    transform: translateY(-50%) rotate(-10deg);
                }
                75% {
                    transform: translateY(-50%) rotate(5deg);
                }
            }

            /* ===============================
               🔵 RESPONSIVE
               =============================== */
            @media (max-width: 992px) {
                .main-content {
                    margin-left: 60px;
                    padding: 20px;
                }
            }

            @media (max-width: 768px) {
                .project-list-view table {
                    font-size: 0.85rem;
                }
                .project-actions-wrapper .btn {
                    padding: 4px 8px;
                }
                .project-progress .percent {
                    font-size: 0.8rem;
                }
            }

            @media (max-width: 480px) {
                .project-list-view table thead {
                    font-size: 0.85rem;
                }
                .project-list-view tbody td {
                    padding: 10px 8px;
                }
            }

            .btn-add-project {
                background: linear-gradient(45deg, #0d6efd, #0dcaf0);
                border: none;
                color: #fff;
                font-weight: 500;
                border-radius: 50px;
                padding: 10px 20px;
                box-shadow: 0 4px 12px rgba(13,110,253,0.3);
                transition: all 0.3s ease;
            }
            .btn-add-project:hover {
                transform: translateY(-2px) scale(1.03);
                box-shadow: 0 6px 16px rgba(13,110,253,0.45);
            }

            /* ==============================
   BUTTON ACTIONS – PREMIUM STYLE
   ============================== */

            .action-btn {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 8px 14px;
                border-radius: 12px;
                font-weight: 600;
                font-size: 0.9rem;
                border: none;
                color: #fff !important;
                cursor: pointer;
                transition: all 0.25s ease;
                text-decoration: none;
                box-shadow: 0 4px 12px rgba(0,0,0,0.12);
            }

            /* VIEW BUTTON – Xanh tím */
            .action-view {
                background: linear-gradient(135deg,#0dcaf0,#4f46e5);
            }
            .action-view:hover {
                transform: translateY(-3px) scale(1.03);
                box-shadow: 0 6px 20px rgba(79,70,229,0.45);
            }

            /* EDIT BUTTON – Vàng cam */
            .action-edit {
                background: linear-gradient(135deg,#fbbf24,#f59e0b);
            }
            .action-edit:hover {
                transform: translateY(-3px) scale(1.03);
                box-shadow: 0 6px 20px rgba(245,158,11,0.45);
            }

            /* DELETE BUTTON – Đỏ */
            .action-delete {
                background: linear-gradient(135deg,#ef4444,#dc2626);
            }
            .action-delete:hover {
                transform: translateY(-3px) scale(1.03);
                box-shadow: 0 6px 20px rgba(220,38,38,0.45);
            }

            /* Icon style */
            .action-btn i {
                font-size: 0.85rem;
            }

            /* Khi bấm giữ */
            .action-btn:active {
                transform: translateY(-1px) scale(0.98);
                box-shadow: 0 3px 10px rgba(0,0,0,0.12);
            }
            .td-desc {
                max-width: 300px; /* chỉnh tùy ý 150–300px */
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            thead th.sortable::after {
                content: "\f0dc"; /* icon sort */
                font-family: "Font Awesome 6 Free";
                font-weight: 900;
                margin-left: 6px;
                opacity: 0.4;
            }

            thead th.sort-asc::after {
                content: "\f0de"; /* up arrow */
                opacity: 1;
            }

            thead th.sort-desc::after {
                content: "\f0dd"; /* down arrow */
                opacity: 1;
            }

        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án';
        </script>
    </head>
    <body>
        <div class="d-flex">
            <%@ include file="sidebar.jsp" %>
            <div class="flex-grow-1">
                <%@ include file="header.jsp" %>
                <div class="main-content">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3 class="mb-0"><i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án</h3>
                        <button class="btn btn-add-project" data-bs-toggle="modal" data-bs-target="#modalProject">
                            <i class="fa-solid fa-plus me-1"></i> Thêm dự án
                        </button>
                    </div>
                    <form class="row g-3 mb-4 align-items-end" method="get" action="dsDuan">

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
                                <option value="Cao" <%= "Cao".equals(request.getParameter("uuTien")) ? "selected" : "" %>>Cao</option>
                                <option value="Trung bình" <%= "Trung bình".equals(request.getParameter("uuTien")) ? "selected" : "" %>>Trung bình</option>
                                <option value="Thấp" <%= "Thấp".equals(request.getParameter("uuTien")) ? "selected" : "" %>>Thấp</option>
                            </select>
                        </div>

                        <input type="hidden" name="nhom_du_an" 
                               value="<%= request.getAttribute("nhomDuAnValue") != null ? request.getAttribute("nhomDuAnValue") : "" %>">

                        <!-- Nhóm dự án -->
                        <!--                        <div class="col-md-2">
                                                    <select name="nhom_du_an" class="form-select">
                                                        <option value="">Nhóm dự án (Tất cả)</option>
                                                        <option value="Dashboard">Dashboard</option>
                                                        <option value="An ninh bảo mật">An ninh bảo mật</option>
                                                        <option value="Oracle Cloud">Oracle Cloud</option>
                                                        <option value="Đào tạo">Đào tạo</option>
                                                        <option value="Khác">Khác</option>
                                                    </select>
                                                </div>-->

                        <!-- Lead -->
                        <div class="col-md-3">
                            <select name="leadId" class="form-select">
                                <option value="">Lead dự án (Tất cả)</option>

                                <%
                                    List<Map<String, Object>> dsNV = (List<Map<String, Object>>) request.getAttribute("dsNhanVien");
                                    String leadSelected = request.getParameter("leadId");

                                    if (dsNV != null) {
                                        for (Map<String, Object> nv : dsNV) {
                                            int id = (int) nv.get("id");
                                            String ten = (String) nv.get("ho_ten");
                                %>

                                <option value="<%= id %>" <%= (leadSelected != null && leadSelected.equals(String.valueOf(id))) ? "selected" : "" %>>
                                    <%= ten %>
                                </option>

                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <!-- Nút Lọc -->
                        <div class="col-md-1">
                            <button class="btn btn-primary w-100">
                                <i class="fa-solid fa-filter"></i> Lọc
                            </button>
                        </div>

                        <!-- Nút Reset -->
                        <div class="col-md-1">
                            <a href="dsDuan?nhom_du_an=<%= request.getParameter("nhom_du_an") %>" class="btn btn-secondary w-100">
                                <i class="fa-solid fa-rotate-left"></i>
                            </a>
                        </div>

                    </form>
                    <!-- ==================== PROJECT LIST VIEW ==================== -->
                    <div class="project-list-view mt-3">

                        <table class="table table-hover align-middle">
                            <thead>
                                <tr>
                                    <th class="sortable" data-sort="ten">Tên dự án</th>
                                    <th>Mô tả</th>
                                    <th>Lead</th>
                                    <th>Nhóm</th>
                                    <th>Phòng ban</th>
                                    <th>Trạng thái</th>
                                    <th class="sortable" data-sort="uutien">Ưu tiên</th>
                                    <th class="sortable" data-sort="ngaybatdau">Ngày bắt đầu</th>
                                    <th class="sortable" data-sort="ngayketthuc">Ngày kết thúc</th>
                                    <th>Tiến độ</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% 
                                    List<Map<String, Object>> projects = 
                                        (List<Map<String, Object>>) request.getAttribute("projects");

                                    if (projects != null) {
                                        for (Map<String, Object> p : projects) {
                        
                                            String priority = p.get("muc_do_uu_tien") != null 
                                                ? p.get("muc_do_uu_tien").toString() : "Không rõ";

                                            String priorityClass = "bg-secondary";
                                            if ("Cao".equals(priority)) priorityClass = "bg-danger";
                                            else if ("Trung bình".equals(priority)) priorityClass = "bg-warning";
                        
                                            // Tiến độ
                                            int td = 0;
                                            try { td = Integer.parseInt(p.get("tien_do").toString()); } 
                                            catch (Exception ex) {}

                                            String progressColor = td < 30 ? "bg-danger" 
                                                                : td < 70 ? "bg-warning" 
                                                                : "bg-success";
                                %>

                                <tr class="project-row"
                                    data-id="<%= p.get("id") %>"
                                    data-ten="<%= p.get("ten_du_an") %>"
                                    data-uutien="<%= p.get("muc_do_uu_tien") %>"
                                    data-phong-ban="<%= p.get("phong_ban") %>"
                                    data-ngaybatdau="<%= p.get("ngay_bat_dau") %>"
                                    data-ngayketthuc="<%= p.get("ngay_ket_thuc") %>">
                                    <td><strong><%= p.get("ten_du_an") %></strong></td>
                                    <td class="td-desc"><%= p.get("mo_ta") %></td>
                                    <td>
                                        <img src="<%= p.get("lead_avatar") %>" width="26" height="26"
                                             class="rounded-circle me-1">
                                        <%= p.get("lead_ten") != null ? p.get("lead_ten") : "Chưa có" %>
                                    </td>
                                    <td><%= p.get("nhom_du_an") %></td>
                                    <td><%= p.get("phong_ban") != null ? p.get("phong_ban") : "Chưa phân" %></td>
                                    <td>
                                        <%
                                            String status = p.get("trang_thai_duan") != null ? p.get("trang_thai_duan").toString() : "Đang thực hiện";
                                            String statusClass = "badge bg-secondary";
                                            if ("Chưa bắt đầu".equals(status)) statusClass = "badge bg-info";
                                            else if ("Đang thực hiện".equals(status)) statusClass = "badge bg-warning text-dark";
                                            else if ("Đã kết thúc".equals(status)) statusClass = "badge bg-success";
                                            else if ("Không thể thực hiện".equals(status)) statusClass = "badge bg-danger";
                                        %>
                                        <span class="<%= statusClass %>"><%= status %></span>
                                    </td>
                                    <td><span class="badge <%= priorityClass %>"><%= priority %></span></td>
                                    <td><%= p.get("ngay_bat_dau") %></td>
                                    <td><%= p.get("ngay_ket_thuc") %></td>

                                    <!-- Tiến độ -->
                                    <td style="min-width:160px;">
                                        <div class="d-flex align-items-center">
                                            <div class="progress flex-grow-1" style="height:6px;">
                                                <div class="progress-bar <%= progressColor %>"
                                                     style="width:<%= td %>%"></div>
                                            </div>
                                            <span class="ms-2 fw-bold"><%= td %>%</span>
                                        </div>
                                    </td>

                                    <td>
                                        <div class="btn-group">
                                            <button class="btn btn-sm btn-info" 
                                                    onclick="showProjectDetail(event, <%= p.get("id") %>)">
                                                <i class="fa-solid fa-eye"></i>
                                            </button>
                                            <button class="btn btn-sm btn-warning"
                                                    onclick="editProject(<%= p.get("id") %>); event.stopPropagation();">
                                                <i class="fa-solid fa-pen"></i>
                                            </button>
                                            <button class="btn btn-sm btn-danger delete-project-btn"
                                                    data-id="<%= p.get("id") %>">
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
                                <option value="">-- Chọn mức độ ưu tiên --</option>
                                <option value="Cao">Cao</option>
                                <option value="Trung bình">Trung bình</option>
                                <option value="Thấp">Thấp</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Trạng thái dự án</label>
                            <select class="form-select" name="trang_thai_duan" required>
                                <option value="Chưa bắt đầu">Chưa bắt đầu</option>
                                <option value="Đang thực hiện">Đang thực hiện</option>
                                <option value="Đã kết thúc">Đã kết thúc</option>
                                <option value="Không thể thực hiện">Không thể thực hiện</option>
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
                                <option value="">-- Chọn phòng ban --</option>
                                <option value="Phòng Kỹ Thuật">Phòng Kỹ Thuật</option>
                                <option value="Phòng Kinh Doanh">Phòng Kinh Doanh</option>
                            </select>
                        </div>

                        <!-- THÊM LEAD DỰ ÁN -->
                        <div class="mb-3">
                            <label class="form-label">Lead dự án</label>
                            <select class="form-select" name="lead_id" required>
                                <option value="">-- Chọn Lead --</option>

                                <% 
                                    List<Map<String, Object>> dsNV2 = (List<Map<String, Object>>) request.getAttribute("dsNhanVien");
                                    if (dsNV2 != null) {
                                        for (Map<String, Object> nv : dsNV2) {
                                            int id = (int) nv.get("id");
                                            String ten = (String) nv.get("ho_ten");
                                %>
                                <option value="<%= id %>"><%= ten %></option>
                                <% 
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Ngày bắt đầu</label>
                                <input type="date" class="form-control" name="ngay_bat_dau">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Ngày kết thúc</label>
                                <input type="date" class="form-control" name="ngay_ket_thuc">
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
                                <div class="mb-3">
                                    <label class="form-label"><strong>Tên dự án:</strong></label>
                                    <div id="detailTenDuAn" class="form-control-plaintext"></div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label"><strong>Mô tả:</strong></label>
                                    <div id="detailMoTa" class="form-control-plaintext"></div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label"><strong>Nhóm dự án:</strong></label>
                                    <div id="detailNhomDuAn" class="form-control-plaintext"></div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label"><strong>Phòng ban:</strong></label>
                                    <div id="detailPhongBan" class="form-control-plaintext"></div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label"><strong>Ngày bắt đầu:</strong></label>
                                        <div id="detailNgayBatDau" class="form-control-plaintext"></div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label"><strong>Ngày kết thúc:</strong></label>
                                        <div id="detailNgayKetThuc" class="form-control-plaintext"></div>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label"><strong>Ngày tạo:</strong></label>
                                    <div id="detailNgayTao" class="form-control-plaintext"></div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="card bg-light">
                                            <div class="card-body text-center">
                                                <h5 class="card-title text-primary">
                                                    <i class="fa-solid fa-tasks me-2"></i>
                                                    <span id="detailTongCongViec">0</span>
                                                </h5>
                                                <p class="card-text">Tổng số công việc đã giao</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="card bg-light">
                                            <div class="card-body text-center">
                                                <h5 class="card-title text-success">
                                                    <i class="fa-solid fa-users me-2"></i>
                                                    <span id="detailTongNguoi">0</span>
                                                </h5>
                                                <p class="card-text">Tổng số người trong dự án</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
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
        <script src="<%= request.getContextPath() %>/scripts/project.js?v=20251105"></script>
    </body>
</html>