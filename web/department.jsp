<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<Map<String, Object>> danhSachPhongBan = (List<Map<String, Object>>) request.getAttribute("danhSachPhongBan");
    if (danhSachPhongBan == null) {
        danhSachPhongBan = new ArrayList<>();
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Quản lý Phòng ban</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            /* ==== GLOBAL ==== */
            body {
                background: #f8fafc;
                font-family: 'Segoe UI', Roboto, sans-serif;
                color: #1e293b;
            }

            .header {
                background: #fff;
                border-bottom: 1px solid #e2e8f0;
                min-height: 64px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
                margin-left: 240px;
                position: sticky;
                top: 0;
                z-index: 20;
            }

            .main-content {
                padding: 32px;
                min-height: 100vh;
                margin-left: 240px;
                animation: fadeIn 0.4s ease;
            }

            .main-box {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 3px 14px rgba(0,0,0,0.08);
                padding: 28px 22px;
                animation: slideUp 0.5s ease;
            }

            /* ==== TABLE ==== */
            .table thead th {
                vertical-align: middle;
                font-weight: 600;
                font-size: 1rem;
            }
            .table-hover tbody tr:hover {
                background: #e0f2fe;
            }
            .table td, .table th {
                padding: 12px 14px;
            }

            /* ==== BADGES ==== */
            .badge {
                font-size: 0.85rem;
                border-radius: 10px;
                padding: 4px 8px;
            }

            /* ==== ACTION BUTTONS ==== */
            td .btn {
                border-radius: 50%;
                width: 34px;
                height: 34px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                transition: all 0.25s ease;
            }
            td .btn i {
                font-size: 0.9rem;
            }

            td .btn-warning {
                background: linear-gradient(90deg,#facc15,#eab308);
                border: none;
                color: #fff;
            }
            td .btn-warning:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(250, 204, 21, 0.4);
            }
            td .btn-danger {
                background: linear-gradient(90deg,#ef4444,#dc2626);
                border: none;
                color: #fff;
            }
            td .btn-danger:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(220, 38, 38, 0.4);
            }
            td .btn-info {
                background: linear-gradient(90deg,#0dcaf0,#4f46e5);
                border: none;
                color: #fff;
            }
            td .btn-info:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(79, 70, 229, 0.4);
            }

            /* ==== MODALS ==== */
            .modal-content {
                border-radius: 16px;
                box-shadow: 0 6px 22px rgba(0,0,0,0.2);
                animation: fadeIn 0.4s ease;
            }
            .modal-header, .modal-footer {
                border-color: #f1f5f9;
            }
            .btn-primary {
                background: linear-gradient(90deg,#0dcaf0,#4f46e5);
                border: none;
            }
            .btn-primary:hover {
                background: linear-gradient(90deg,#4f46e5,#0dcaf0);
            }

            /* ==== ANIMATIONS ==== */
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

            /* ==== RESPONSIVE ==== */
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
                .table-responsive {
                    font-size: 0.95rem;
                }
            }
        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-building me-2"></i>Quản lý Phòng ban';
        </script>
    </head>
    <body>
        <div class="d-flex">
            <%@ include file="sidebar.jsp" %>
            <!-- Main -->
            <div class="flex-grow-1">
                <!-- Header -->
                <%@ include file="header.jsp" %>
                <div class="main-content">
                    <div class="main-box">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h3 class="mb-0"><i class="fa-solid fa-building me-2"></i>Quản lý Phòng ban</h3>
                            <button class="btn btn-primary rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#modalDepartment">
                                <i class="fa-solid fa-plus"></i> Thêm mới
                            </button>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-bordered align-middle table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>#</th>
                                        <th>Tên phòng ban</th>
                                        <th>Trưởng phòng</th>
                                        <th>Nhân viên</th>
                                        <th>Ngày tạo</th>
                                        <th>Hành động</th>
                                    </tr>
                                </thead>
                                <tbody id="departmentTableBody">
                                    <%
                                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                                        if (danhSachPhongBan != null && !danhSachPhongBan.isEmpty()) {
                                            for (Map<String, Object> pb : danhSachPhongBan) {
                                    %>
                                    <tr>
                                        <td><%= pb.get("id") %></td>
                                        <td>
                                            <a href="dsCongviec?phongBanId=<%= pb.get("id") %>" 
                                               class="fw-bold text-primary" 
                                               style="text-decoration:none;">
                                                <%= pb.get("ten_phong") %>
                                            </a>
                                        </td>
                                        <td>
                                            <% if (pb.get("truong_phong_ten") != null) { %>
                                            <img src="<%= pb.get("truong_phong_avatar") %>" class="rounded-circle me-1" width="28">
                                            <span class="fw-semibold text-primary"><%= pb.get("truong_phong_ten") %></span>
                                            <span class="badge bg-info ms-1">Trưởng phòng</span>
                                            <% } else { %>
                                            <span class="text-muted">Chưa có trưởng phòng</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="badge bg-light text-dark">Tổng: <%= pb.get("so_nhan_vien") %> người</span>
                                        </td>
                                        <td>
                                            <% if (pb.get("ngay_tao") != null) { %>
                                            <%= sdf.format(pb.get("ngay_tao")) %>
                                            <% } %>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-warning edit-dept-btn" data-id="<%= pb.get("id") %>">
                                                <i class="fa-solid fa-pen"></i>
                                            </button>
                                            <button class="btn btn-sm btn-danger delete-dept-btn" data-id="<%= pb.get("id") %>">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                            <button class="btn btn-sm btn-info" data-bs-toggle="modal" data-bs-target="#modalDeptDetail" data-id="<%= pb.get("id") %>">
                                                <i class="fa-solid fa-eye"></i>
                                            </button>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <tr>
                                        <td colspan="6" class="text-center">Chưa có dữ liệu phòng ban</td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <!-- Modal Thêm/Sửa phòng ban -->
                    <div class="modal fade" id="modalDepartment" tabindex="-1">
                        <div class="modal-dialog">
                            <form class="modal-content" id="departmentForm">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-building"></i> Thông tin phòng ban</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <input type="hidden" id="deptId" name="id">
                                    <div class="mb-3">
                                        <label class="form-label">Tên phòng ban</label>
                                        <input type="text" class="form-control" id="deptName" name="ten_phong" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Trưởng phòng</label>
                                        <select class="form-select" id="deptLeader" name="truong_phong_id">
                                            <!-- AJAX load nhân viên -->
                                        </select>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="submit" class="btn btn-primary rounded-pill">Lưu</button>
                                    <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <!-- Modal chi tiết phòng ban với tab -->
                    <div class="modal fade" id="modalDeptDetail" tabindex="-1">
                        <div class="modal-dialog modal-lg">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-building"></i> Chi tiết phòng ban</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <ul class="nav nav-tabs mb-3" id="deptDetailTab" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active" id="tab-dept-info" data-bs-toggle="tab" data-bs-target="#tabDeptInfo" type="button" role="tab">Thông tin</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="tab-dept-history" data-bs-toggle="tab" data-bs-target="#tabDeptHistory" type="button" role="tab">Lịch sử thay đổi</button>
                                        </li>
                                    </ul>
                                    <div class="tab-content" id="deptDetailTabContent">
                                        <div class="tab-pane fade show active" id="tabDeptInfo" role="tabpanel">
                                            <b>Tên phòng ban:</b> Kỹ thuật<br>
                                            <b>Trưởng phòng:</b> Nguyễn Văn A<br>
                                            <b>Nhân viên:</b> Nguyễn Văn A, Trần Thị B<br>
                                            <b>Ngày tạo:</b> 01/06/2024<br>
                                            <b>Tổng nhân viên:</b> 2
                                        </div>
                                        <div class="tab-pane fade" id="tabDeptHistory" role="tabpanel">
                                            <ul>
                                                <li>01/06/2024: Tạo phòng ban</li>
                                                <li>05/06/2024: Thay đổi trưởng phòng</li>
                                                <!-- AJAX load từ nhan_su_lich_su -->
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Modal xuất báo cáo -->
                    <div class="modal fade" id="modalExportReport" tabindex="-1">
                        <div class="modal-dialog">
                            <form class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-file-export"></i> Xuất báo cáo phòng ban</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="mb-3">
                                        <label class="form-label">Chọn định dạng</label>
                                        <select class="form-select" name="exportType">
                                            <option value="excel">Excel (.xlsx)</option>
                                            <option value="pdf">PDF (.pdf)</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Khoảng thời gian</label>
                                        <input type="date" class="form-control mb-2" name="fromDate" placeholder="Từ ngày">
                                        <input type="date" class="form-control" name="toDate" placeholder="Đến ngày">
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="submit" class="btn btn-primary">Xuất file</button>
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Huỷ</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <!-- Modal thống kê phòng ban -->
                    <div class="modal fade" id="modalChart" tabindex="-1">
                        <div class="modal-dialog modal-lg">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-chart-pie"></i> Thống kê phòng ban</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <canvas id="pieChart"></canvas>
                                        </div>
                                        <div class="col-md-6">
                                            <canvas id="barChart"></canvas>
                                        </div>
                                    </div>
                                    <div class="mt-3 small text-muted">* Số liệu demo, sẽ cập nhật bằng AJAX thực tế.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Toast -->
        <div class="position-fixed bottom-0 end-0 p-3" style="z-index: 9999">
            <div id="toastSuccess" class="toast align-items-center text-bg-success border-0" role="alert">
                <div class="d-flex">
                    <div class="toast-body">
                        Thao tác thành công!
                    </div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
                </div>
            </div>
            <div id="toastError" class="toast align-items-center text-bg-danger border-0" role="alert">
                <div class="d-flex">
                    <div class="toast-body">
                        Đã xảy ra lỗi!
                    </div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
                </div>
            </div>
        </div>
        <script>
            const USER_PERMISSIONS = <%= session.getAttribute("quyen") %>;
        </script>
        <script src="<%= request.getContextPath() %>/scripts/department.js?v=20251106"></script>
    </body>
</html>