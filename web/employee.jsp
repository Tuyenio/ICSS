<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>

<%
    List<Map<String, Object>> danhSach = (List<Map<String, Object>>) request.getAttribute("danhSach");
%>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Quản lý Nhân sự</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <script>
            const CURRENT_USER_CHUCVU = '<%= session.getAttribute("chucVu") != null ? session.getAttribute("chucVu") : "" %>';
        </script>
        <style>
            /* ==== GLOBAL MAIN CONTENT ==== */
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
                background: #f9fafb;
                transition: margin-left 0.3s ease;
            }

            .main-box {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.06);
                padding: 28px;
                animation: fadeIn 0.4s ease;
            }

            /* ==== TABLE ==== */
            .table thead {
                background: #f1f5f9;
                color: #1e293b;
                font-weight: 600;
            }
            .table-hover tbody tr:hover {
                background: #e0f2fe;
                transition: background 0.25s ease;
            }
            .table td, .table th {
                vertical-align: middle;
                text-align: center; /* căn giữa trong ô hành động */
            }

            /* ==== FILTER ROW ==== */
            .filter-row .form-select,
            .filter-row .form-control {
                border-radius: 20px;
                padding: 6px 14px;
                transition: box-shadow 0.2s;
            }
            .filter-row input:focus,
            .filter-row select:focus {
                box-shadow: 0 0 0 3px rgba(13,202,240,0.4);
            }

            /* ==== ACTION BUTTONS (chuẩn giống Phòng ban) ==== */
            /* Nút trong ô hành động */
            td .btn {
                border-radius: 50%;
                width: 34px;
                height: 34px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                vertical-align: middle;   /* 👈 giữ ngang hàng */
                margin: 0 2px;            /* 👈 tạo khoảng cách */
                border: none;
                color: #fff;
                transition: all 0.25s ease;
            }

            /* Icon trong nút */
            td .btn i {
                font-size: 0.9rem;
                line-height: 1; /* 👈 loại bỏ ảnh hưởng line-height của btn-sm */
            }

            /* Nút sửa */
            .edit-emp-btn {
                background: linear-gradient(90deg,#facc15,#eab308);
            }
            .edit-emp-btn:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(250,204,21,0.4);
            }

            /* Nút xóa */
            .delete-emp-btn {
                background: linear-gradient(90deg,#ef4444,#dc2626);
            }
            .delete-emp-btn:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(220,38,38,0.4);
            }

            /* ==== BADGES ==== */
            .badge-status {
                font-size: 0.9em;
                padding: 6px 12px;
                border-radius: 10px;
                animation: pulse 1.5s infinite;
            }
            .badge.bg-success {
                background: #16a34a !important;
            }
            .badge.bg-warning {
                background: #facc15 !important;
                color: #000 !important;
            }
            .badge.bg-danger {
                background: #dc2626 !important;
            }

            /* ==== MODALS ==== */
            .modal-content {
                border-radius: 16px;
                box-shadow: 0 6px 24px rgba(0,0,0,0.2);
                animation: slideUp 0.4s ease;
            }
            .modal-header {
                border-bottom: 1px solid #f1f5f9;
            }
            .modal-footer {
                border-top: 1px solid #f1f5f9;
            }

            /* ==== ANIMATIONS ==== */
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(30px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            @keyframes pulse {
                0%,100% {
                    transform: scale(1);
                }
                50% {
                    transform: scale(1.05);
                }
            }

            /* ==== PERMISSIONS TAB ==== */
            .permissions-container {
                max-height: 500px;
                overflow-y: auto;
                padding: 10px;
            }
            .permission-group {
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 16px;
                background: #f8fafc;
                transition: all 0.3s ease;
            }
            .permission-group:hover {
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
                transform: translateY(-1px);
            }
            .permission-group.has-permissions {
                border-color: #28a745;
                background: linear-gradient(135deg, #f8fff9 0%, #f8fafc 100%);
                box-shadow: 0 0 0 1px rgba(40, 167, 69, 0.2);
            }
            .permission-group-title {
                color: #1e293b;
                margin-bottom: 12px;
                padding-bottom: 8px;
                border-bottom: 2px solid #e2e8f0;
            }
            .form-check {
                transition: all 0.2s ease;
            }
            .form-check:hover {
                background: rgba(13, 110, 253, 0.05);
                border-radius: 6px;
                padding: 4px 8px;
            }
            .form-check.permission-checked {
                background: rgba(40, 167, 69, 0.1);
                border-radius: 6px;
                padding: 4px 8px;
                border-left: 3px solid #28a745;
            }
            .form-check-input {
                border-radius: 4px;
                border: 2px solid #cbd5e1;
                transition: all 0.2s ease;
            }
            .form-check-input:checked {
                background-color: #0d6efd;
                border-color: #0d6efd;
                box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.25);
            }
            .form-check-input:focus {
                box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.25);
            }
            .form-check-label {
                font-weight: 500;
                color: #475569;
                cursor: pointer;
            }
            .permission-actions {
                border-top: 2px solid #e2e8f0;
                padding-top: 16px;
                margin-top: 20px;
            }
            
            /* ==== RESPONSIVE ==== */
            @media (max-width: 992px) {
                .main-content {
                    margin-left: 70px;
                    padding: 20px;
                }
            }
            @media (max-width: 768px) {
                .main-box {
                    padding: 16px;
                }
                .table-responsive {
                    font-size: 0.9rem;
                }
                .permissions-container {
                    max-height: 400px;
                }
                .permission-group {
                    margin-bottom: 16px;
                }
            }

        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-users me-2"></i>Quản lý Nhân sự';
        </script>
    </head>

    <body>
        <div class="d-flex">
            <%@ include file="sidebar.jsp" %>
            <!-- Main -->
            <div class="flex-grow-1">
                <!-- Header -->
                <%@ include file="header.jsp" %>
                <!-- Main content -->
                <div class="main-content">
                    <div class="main-box">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h3 class="mb-0"><i class="fa-solid fa-users me-2"></i>Quản lý Nhân sự</h3>
                            <button class="btn btn-primary rounded-pill px-3" data-bs-toggle="modal"
                                    data-bs-target="#modalEmployee" onclick="openAddModal()">
                                <i class="fa-solid fa-plus"></i> Thêm mới
                            </button>
                        </div>
                        <!-- Bộ lọc tìm kiếm -->
                        <div class="row mb-3 filter-row g-2" id="menuloc">
                            <div class="col-md-3">
                                <input type="text" class="form-control" id="searchName"
                                       placeholder="Tìm kiếm tên, email...">
                            </div>
                            <% String vaiTro = (String) session.getAttribute("vaiTro"); %>
                            <div class="col-md-3">
                                <select class="form-select" name="ten_phong_ban" id="filterDepartment"
                                        <%= !"Admin".equalsIgnoreCase(vaiTro) ? "disabled" : "" %>>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <select class="form-select" id="filterStatus">
                                    <option value="">Tất cả trạng thái</option>
                                    <option value="Đang làm">Đang làm</option>
                                    <option value="Tạm nghỉ">Tạm nghỉ</option>
                                    <option value="Nghỉ việc">Nghỉ việc</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <select class="form-select" id="filterRole">
                                    <option value="">Tất cả quyền</option>
                                    <option value="Admin">Admin</option>
                                    <option value="Quản lý">Quản lý</option>
                                    <option value="Nhân viên">Nhân viên</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <button class="btn btn-outline-secondary w-100 rounded-pill" id="btnFilter">
                                    <i class="fa-solid fa-filter"></i> Lọc
                                </button>
                            </div>
                        </div>
                        <!-- Table nhân sự -->
                        <div class="table-responsive">
                            <table class="table table-bordered align-middle table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>#</th>
                                        <th>Avatar</th>
                                        <th>Họ tên</th>
                                        <th>Email</th>
                                        <th>SĐT</th>
                                        <th>Giới tính</th>
                                        <th>Ngày sinh</th>
                                        <th>Phòng ban</th>
                                        <th>Chức vụ</th>
                                        <th>Ngày vào làm</th>
                                        <th>Trạng thái</th>
                                        <th>Vai trò</th>
                                        <th>Hành động</th>
                                    </tr>
                                </thead>
                                <tbody id="employeeTableBody">
                                    <%
                                    if (danhSach != null && !danhSach.isEmpty()) {
                                        int stt = 1;
                                        for (Map<String, Object> nv : danhSach) {
                                    %>
                                    <tr>
                                        <td><%= stt++ %></td>
                                        <td><img src="<%= nv.get("avatar_url") %>" class="rounded-circle" width="36"></td>
                                        <td><a href="#" class="emp-detail-link fw-semibold text-primary" data-email="<%= nv.get("email") %>"> <%= nv.get("ho_ten") %></a></td>
                                        <td><%= nv.get("email") %></td>
                                        <td><%= nv.get("so_dien_thoai") %></td>
                                        <td><%= nv.get("gioi_tinh") %></td>
                                        <td><%= nv.get("ngay_sinh") %></td>
                                        <td><%= nv.get("ten_phong_ban") %></td>
                                        <td><%= nv.get("chuc_vu") %></td>
                                        <td><%= nv.get("ngay_vao_lam") %></td>
                                        <td><span class="badge bg-success"><%= nv.get("trang_thai_lam_viec") %></span></td>
                                        <td><span class="badge bg-info text-dark"><%= nv.get("vai_tro") %></span></td>
                                        <td>
                                            <button class="btn btn-sm btn-warning edit-emp-btn"
                                                    data-id="<%= nv.get("id") %>"
                                                    data-name="<%= nv.get("ho_ten") %>"
                                                    data-email="<%= nv.get("email") %>"
                                                    data-pass="<%= nv.get("mat_khau") %>"
                                                    data-phone="<%= nv.get("so_dien_thoai") %>"
                                                    data-gender="<%= nv.get("gioi_tinh") %>"
                                                    data-birth="<%= nv.get("ngay_sinh") %>"
                                                    data-startdate="<%= nv.get("ngay_vao_lam") %>"
                                                    data-phong-ban-id="<%= nv.get("phong_ban_id") %>"
                                                    data-position="<%= nv.get("chuc_vu") %>"
                                                    data-status="<%= nv.get("trang_thai_lam_viec") %>"
                                                    data-role="<%= nv.get("vai_tro") %>"
                                                    data-avatar="<%= nv.get("avatar_url") %>"><i class="fa-solid fa-pen"></i>
                                            </button>
                                            <button class="btn btn-sm btn-danger delete-emp-btn" data-id="<%= nv.get("id") %>"><i class="fa-solid fa-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <tr>
                                        <td colspan="10" style="text-align:center;">Không có dữ liệu</td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <!-- Modal Thêm/Sửa nhân viên -->
                    <div class="modal fade" id="modalEmployee" tabindex="-1">
                        <div class="modal-dialog">
                            <form class="modal-content" id="employeeForm">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-user-plus"></i> Thông tin nhân
                                        viên</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body row g-3" id="modalnhanvien">
                                    <input type="hidden" id="empId" name="empId">
                                    <div class="col-md-12 text-center mb-2">
                                        <img id="avatarPreview" src="https://ui-avatars.com/api/?name=Avatar"
                                             class="rounded-circle" width="70" alt="Avatar">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" title="Họ tên đầy đủ">Họ tên</label>
                                        <input type="text" class="form-control" id="empName" name="ho_ten" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" title="Email công việc">Email</label>
                                        <input type="email" class="form-control" id="empEmail" name="email"
                                               required>
                                    </div>
                                    <div class="col-md-6 position-relative">
                                        <label class="form-label" title="Mật khẩu đăng nhập">Mật khẩu</label>
                                        <input type="password" class="form-control" id="empPassword" name="mat_khau" required>
                                        <i class="fa-solid fa-eye position-absolute" id="togglePassword"
                                           style="top: 38px; right: 15px; cursor: pointer;"></i>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" title="Số điện thoại liên hệ">Số điện
                                            thoại</label>
                                        <input type="text" class="form-control" id="empPhone" name="so_dien_thoai">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" title="Giới tính">Giới tính</label>
                                        <select class="form-select" id="empGender" name="gioi_tinh">
                                            <option value="Nam">Nam</option>
                                            <option value="Nữ">Nữ</option>
                                            <option value="Khác">Khác</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" title="Ngày sinh">Ngày sinh</label>
                                        <input type="date" class="form-control" id="empBirth" name="ngay_sinh">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" title="Ngày vào làm">Ngày vào làm</label>
                                        <input type="date" class="form-control" id="empStartDate"
                                               name="ngay_vao_lam">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" title="Phòng ban">Phòng ban</label>
                                        <select class="form-select" id="empDepartment" name="ten_phong_ban">
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" title="Chức vụ">Chức vụ</label>
                                        <input type="text" class="form-control" id="empPosition" name="chuc_vu">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" title="Trạng thái làm việc">Trạng thái làm
                                            việc</label>
                                        <select class="form-select" id="empStatus" name="trang_thai_lam_viec">
                                            <option value="Đang làm" class="bg-success text-white">Đang làm</option>
                                            <option value="Tạm nghỉ" class="bg-warning text-dark">Tạm nghỉ</option>
                                            <option value="Nghỉ việc" class="bg-danger text-white">Nghỉ việc</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" title="Vai trò hệ thống">Vai trò</label>
                                        <select class="form-select" id="empRole" name="vai_tro">
                                            <option value="Admin" class="bg-danger text-white">Admin</option>
                                            <option value="Quản lý" class="bg-warning text-dark">Quản lý</option>
                                            <option value="Nhân viên" class="bg-info text-dark">Nhân viên</option>
                                        </select>
                                    </div>
                                    <div class="col-md-12">
                                        <label class="form-label" title="Link ảnh hoặc upload">Avatar</label>
                                        <input type="url" class="form-control" id="empAvatar" name="avatar_url"
                                               placeholder="Link ảnh hoặc upload">
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="submit" class="btn btn-primary rounded-pill">Lưu</button>
                                    <button type="button" class="btn btn-secondary rounded-pill"
                                            data-bs-dismiss="modal">Huỷ</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <!-- Modal chi tiết nhân viên với tab -->
                    <div class="modal fade" id="modalEmpDetail" tabindex="-1">
                        <div class="modal-dialog modal-lg">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-id-card"></i> Hồ sơ nhân viên</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <ul class="nav nav-tabs mb-3" id="empDetailTab" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active" id="tab-info" data-bs-toggle="tab"
                                                    data-bs-target="#tabInfo" type="button" role="tab">Thông
                                                tin</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="tab-task" data-bs-toggle="tab"
                                                    data-bs-target="#tabTask" type="button" role="tab">Lịch sử công
                                                việc</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="tab-permission" data-bs-toggle="tab"
                                                    data-bs-target="#tabPermission" type="button" role="tab">
                                                <i class="fa-solid fa-key me-1"></i>Phân quyền
                                            </button>
                                        </li>
                                    </ul>
                                    <div class="tab-content" id="empDetailTabContent">
                                        <div class="tab-pane fade show active" id="tabInfo" role="tabpanel">
                                            <div class="row">
                                                <div class="col-md-3 text-center">
                                                    <img id="avatarPreview" src="" class="rounded-circle mb-2" width="100">
                                                    <div class="fw-bold emp-name">Nguyễn Văn A</div>
                                                    <div class="text-muted small emp-email">nguyenvana@email.com</div>
                                                </div>
                                                <div class="col-md-9">
                                                    <b>SĐT:</b> <span class="emp-phone"></span><br>
                                                    <b>Giới tính:</b> <span class="emp-gender"></span><br>
                                                    <b>Ngày sinh:</b> <span class="emp-birth"></span><br>
                                                    <b>Phòng ban:</b> <span class="emp-dept"></span><br>
                                                    <b>Chức vụ:</b> <span class="emp-position"></span><br>
                                                    <b>Ngày vào làm:</b> <span class="emp-start"></span><br>
                                                    <b>Trạng thái:</b> <span class="emp-status badge"></span><br>
                                                    <b>Vai trò:</b> <span class="emp-role badge"></span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade" id="tabTask" role="tabpanel">
                                            <ul>
                                                <li>Task 1 - Đã hoàn thành</li>
                                                <li>Task 2 - Đang làm</li>
                                                <!-- AJAX load lịch sử công việc -->
                                            </ul>
                                        </div>
                                        <div class="tab-pane fade" id="tabPermission" role="tabpanel">
                                            <div class="permissions-container">
                                                <div class="alert alert-info mb-3">
                                                    <i class="fa-solid fa-info-circle me-2"></i>
                                                    <strong>Phân quyền chức năng:</strong> Thiết lập quyền truy cập các tính năng của nhân viên trong hệ thống.
                                                    <br><small class="text-muted mt-1 d-block">
                                                        <i class="fa-solid fa-lightbulb me-1"></i>
                                                        <strong>Mẹo:</strong> Click vào tên nhân viên để xem chi tiết và thiết lập phân quyền. Sử dụng nút "Sao chép từ vai trò" để áp dụng nhanh quyền chuẩn.
                                                    </small>
                                                </div>
                                                
                                                <!-- Quyền quản lý nhân sự -->
                                                <div class="permission-group mb-4">
                                                    <h6 class="permission-group-title">
                                                        <i class="fa-solid fa-users text-primary me-2"></i>
                                                        <strong>Quản lý Nhân sự</strong>
                                                    </h6>
                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_employee_view">
                                                                <label class="form-check-label" for="perm_employee_view">
                                                                    Xem danh sách nhân viên
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_employee_add">
                                                                <label class="form-check-label" for="perm_employee_add">
                                                                    Thêm nhân viên mới
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_employee_edit">
                                                                <label class="form-check-label" for="perm_employee_edit">
                                                                    Sửa thông tin nhân viên
                                                                </label>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_employee_delete">
                                                                <label class="form-check-label" for="perm_employee_delete">
                                                                    Xóa nhân viên
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_employee_permission">
                                                                <label class="form-check-label" for="perm_employee_permission">
                                                                    Phân quyền nhân viên
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Quyền quản lý phòng ban -->
                                                <div class="permission-group mb-4">
                                                    <h6 class="permission-group-title">
                                                        <i class="fa-solid fa-building text-success me-2"></i>
                                                        <strong>Quản lý Phòng ban</strong>
                                                    </h6>
                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_department_view">
                                                                <label class="form-check-label" for="perm_department_view">
                                                                    Xem danh sách phòng ban
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_department_add">
                                                                <label class="form-check-label" for="perm_department_add">
                                                                    Thêm phòng ban mới
                                                                </label>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_department_edit">
                                                                <label class="form-check-label" for="perm_department_edit">
                                                                    Sửa thông tin phòng ban
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_department_delete">
                                                                <label class="form-check-label" for="perm_department_delete">
                                                                    Xóa phòng ban
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Quyền quản lý dự án -->
                                                <div class="permission-group mb-4">
                                                    <h6 class="permission-group-title">
                                                        <i class="fa-solid fa-folder-open text-warning me-2"></i>
                                                        <strong>Quản lý Dự án</strong>
                                                    </h6>
                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_project_view">
                                                                <label class="form-check-label" for="perm_project_view">
                                                                    Xem danh sách dự án
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_project_add">
                                                                <label class="form-check-label" for="perm_project_add">
                                                                    Tạo dự án mới
                                                                </label>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_project_edit">
                                                                <label class="form-check-label" for="perm_project_edit">
                                                                    Sửa thông tin dự án
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_project_delete">
                                                                <label class="form-check-label" for="perm_project_delete">
                                                                    Xóa dự án
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Quyền quản lý công việc -->
                                                <div class="permission-group mb-4">
                                                    <h6 class="permission-group-title">
                                                        <i class="fa-solid fa-tasks text-info me-2"></i>
                                                        <strong>Quản lý Công việc</strong>
                                                    </h6>
                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_task_view">
                                                                <label class="form-check-label" for="perm_task_view">
                                                                    Xem danh sách công việc
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_task_add">
                                                                <label class="form-check-label" for="perm_task_add">
                                                                    Giao công việc mới
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_task_edit">
                                                                <label class="form-check-label" for="perm_task_edit">
                                                                    Sửa thông tin công việc
                                                                </label>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_task_delete">
                                                                <label class="form-check-label" for="perm_task_delete">
                                                                    Xóa công việc
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_task_approve">
                                                                <label class="form-check-label" for="perm_task_approve">
                                                                    Duyệt/đánh giá công việc
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_task_progress">
                                                                <label class="form-check-label" for="perm_task_progress">
                                                                    Cập nhật tiến độ
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Quyền chấm công và lương -->
                                                <div class="permission-group mb-4">
                                                    <h6 class="permission-group-title">
                                                        <i class="fa-solid fa-clock text-danger me-2"></i>
                                                        <strong>Chấm công & Lương</strong>
                                                    </h6>
                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_attendance_view">
                                                                <label class="form-check-label" for="perm_attendance_view">
                                                                    Xem dữ liệu chấm công
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_attendance_manage">
                                                                <label class="form-check-label" for="perm_attendance_manage">
                                                                    Quản lý chấm công
                                                                </label>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_salary_view">
                                                                <label class="form-check-label" for="perm_salary_view">
                                                                    Xem bảng lương
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_salary_manage">
                                                                <label class="form-check-label" for="perm_salary_manage">
                                                                    Quản lý lương
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Quyền báo cáo -->
                                                <div class="permission-group mb-4">
                                                    <h6 class="permission-group-title">
                                                        <i class="fa-solid fa-chart-bar text-secondary me-2"></i>
                                                        <strong>Báo cáo & Thống kê</strong>
                                                    </h6>
                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_report_view">
                                                                <label class="form-check-label" for="perm_report_view">
                                                                    Xem báo cáo tổng hợp
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_report_export">
                                                                <label class="form-check-label" for="perm_report_export">
                                                                    Xuất báo cáo
                                                                </label>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_analytics_view">
                                                                <label class="form-check-label" for="perm_analytics_view">
                                                                    Xem phân tích dữ liệu
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Quyền hệ thống -->
                                                <div class="permission-group mb-4">
                                                    <h6 class="permission-group-title">
                                                        <i class="fa-solid fa-cogs text-dark me-2"></i>
                                                        <strong>Cấu hình Hệ thống</strong>
                                                    </h6>
                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_system_config">
                                                                <label class="form-check-label" for="perm_system_config">
                                                                    Cấu hình hệ thống
                                                                </label>
                                                            </div>
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_backup_restore">
                                                                <label class="form-check-label" for="perm_backup_restore">
                                                                    Sao lưu & Khôi phục
                                                                </label>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-check mb-2">
                                                                <input class="form-check-input" type="checkbox" id="perm_audit_log">
                                                                <label class="form-check-label" for="perm_audit_log">
                                                                    Xem nhật ký hệ thống
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Nút hành động -->
                                                <div class="permission-actions text-center mt-4">
                                                    <button type="button" class="btn btn-success rounded-pill me-2" id="btnSavePermissions">
                                                        <i class="fa-solid fa-save me-1"></i>Lưu phân quyền
                                                    </button>
                                                    <button type="button" class="btn btn-outline-primary rounded-pill me-2" id="btnResetPermissions">
                                                        <i class="fa-solid fa-undo me-1"></i>Khôi phục mặc định
                                                    </button>
                                                    <button type="button" class="btn btn-outline-warning rounded-pill" id="btnCopyPermissions">
                                                        <i class="fa-solid fa-copy me-1"></i>Sao chép từ vai trò
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
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
                    <button type="button" class="btn-close btn-close-white me-2 m-auto"
                            data-bs-dismiss="toast"></button>
                </div>
            </div>
            <div id="toastError" class="toast align-items-center text-bg-danger border-0" role="alert">
                <div class="d-flex">
                    <div class="toast-body">
                        Đã xảy ra lỗi!
                    </div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto"
                            data-bs-dismiss="toast"></button>
                </div>
            </div>
        </div>
        <script src="<%= request.getContextPath() %>/scripts/employee.obf.js?v=20251105"></script>
    </body>

</html>

