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
        <script>

            function openAddModal() {
                $('#employeeForm')[0].reset();              // Xóa trắng tất cả field
                $('#empId').val('');                        // Gán ID rỗng => thêm mới
                $('#avatarPreview').attr('src', 'https://ui-avatars.com/api/?name=Avatar');
                $('#modalEmployee').modal('show');          // Mở modal
            }

            document.addEventListener("DOMContentLoaded", function () {
                // Load nhóm công việc
                fetch('./apiPhongban')
                        .then(res => res.text())
                        .then(html => {
                            const defaultOption = '<option value="" selected>Tất cả phòng ban</option>';
                            const finalHTML = defaultOption + html;

                            // Gán cho cả bộ lọc và modal
                            $('#menuloc select[name="ten_phong_ban"]').html(finalHTML);
                            $('#modalnhanvien select[name="ten_phong_ban"]').html(html);

                            // Gán flag đã load xong
                            window.phongBanLoaded = true;
                        });
            });

            //AJAX loc
            $('#btnFilter').on('click', function () {
                const keyword = $('#searchName').val();
                const phongBan = $('#filterDepartment').val();
                const trangThai = $('#filterStatus').val();
                const vaiTro = $('#filterRole').val();

                $.ajax({
                    url: './locNhanvien',
                    type: 'POST',
                    data: {
                        keyword: keyword,
                        phong_ban: phongBan,
                        trang_thai: trangThai,
                        vai_tro: vaiTro
                    },
                    success: function (html) {
                        $('#employeeTableBody').html(html);
                    },
                    error: function () {
                        $('#employeeTableBody').html("<tr><td colspan='13' class='text-danger text-center'>Lỗi khi lọc dữ liệu</td></tr>");
                    }
                });
            });
            // AJAX tìm kiếm realtime
            $('#searchName, #filterDepartment, #filterStatus, #filterRole').on('input change', function () {
                // TODO: AJAX load lại bảng nhân viên theo filter
                // $.get('api/employee', {...}, function(data){ ... });
            });

            function getBadgeClass(status) {
                switch (status) {
                    case 'Đang làm':
                        return 'bg-success';
                    case 'Tạm nghỉ':
                        return 'bg-warning text-dark';
                    case 'Nghỉ việc':
                        return 'bg-danger';
                    default:
                        return 'bg-secondary';
                }
            }

            function getRoleClass(role) {
                switch (role) {
                    case 'Admin':
                        return 'bg-danger text-white';
                    case 'Quản lý':
                        return 'bg-warning text-dark';
                    case 'Nhân viên':
                        return 'bg-info text-dark';
                    default:
                        return 'bg-secondary';
                }
            }
            // Nút xem chi tiết
            $(document).on('click', '.emp-detail-link', function (e) {
                e.preventDefault();

                const email = $(this).data('email');

                $.ajax({
                    url: './chitietNV',
                    method: 'GET',
                    data: {email: email},
                    dataType: 'json',
                    success: function (data) {
                        // Gán dữ liệu vào modal
                        $('#modalEmpDetail .emp-name').text(data.ho_ten);
                        $('#modalEmpDetail .emp-email').text(data.email);
                        $('#modalEmpDetail .emp-phone').text(data.so_dien_thoai);
                        $('#modalEmpDetail .emp-gender').text(data.gioi_tinh);
                        $('#modalEmpDetail .emp-birth').text(data.ngay_sinh);
                        $('#modalEmpDetail .emp-dept').text(data.ten_phong_ban);
                        $('#modalEmpDetail .emp-position').text(data.chuc_vu);
                        $('#modalEmpDetail .emp-start').text(data.ngay_vao_lam);

                        const avatarUrl = data.avatar_url && data.avatar_url.trim() !== ''
                                ? data.avatar_url
                                : 'https://ui-avatars.com/api/?name=' + encodeURIComponent(data.ho_ten || 'User');

                        $('#modalEmpDetail #avatarPreview').attr('src', avatarUrl);

                        // Xử lý badge màu trạng thái
                        const statusClass = getBadgeClass(data.trang_thai_lam_viec);
                        $('#modalEmpDetail .emp-status')
                                .text(data.trang_thai_lam_viec)
                                .removeClass('bg-success bg-warning bg-danger bg-secondary')
                                .addClass(statusClass);

                        // Xử lý badge màu vai trò
                        const roleClass = getRoleClass(data.vai_tro);
                        $('#modalEmpDetail .emp-role')
                                .text(data.vai_tro)
                                .removeClass('bg-danger bg-warning bg-info bg-secondary text-white text-dark')
                                .addClass(roleClass);

                        // Reset tab về tab đầu tiên
                        $('#empDetailTab .nav-link').removeClass('active');
                        $('#empDetailTabContent .tab-pane').removeClass('show active');
                        $('#tab-info').addClass('active');
                        $('#tabInfo').addClass('show active');

                        // Hiển thị modal
                        const modal = new bootstrap.Modal(document.getElementById('modalEmpDetail'));
                        modal.show();
                    },
                    error: function () {
                        showToast('error', 'Không thể tải chi tiết nhân viên');
                    }
                });
            });

            // Xem password
            $(document).on('click', '#togglePassword', function () {
                const input = $('#empPassword');
                const type = input.attr('type') === 'password' ? 'text' : 'password';
                input.attr('type', type);

                // Toggle icon
                $(this).toggleClass('fa-eye fa-eye-slash');
            });
            // Nút sửa
            $(document).on('click', '.edit-emp-btn', function () {
                const button = $(this);
                const phongBanId = button.data('phong-ban-id');

                function fillForm() {
                    $('#empId').val(button.data('id'));
                    $('#empName').val(button.data('name'));
                    $('#empEmail').val(button.data('email'));
                    $('#empPassword').val(button.data('pass'));
                    $('#empPhone').val(button.data('phone'));
                    $('#empGender').val(button.data('gender'));
                    $('#empBirth').val(button.data('birth'));
                    $('#empStartDate').val(button.data('startdate'));

                    // ✅ Gán đúng phòng ban theo ID (ví dụ: <option value="2">Phòng Kỹ thuật</option>)
                    $('#empDepartment').val(phongBanId);

                    $('#empPosition').val(button.data('position'));
                    $('#empStatus').val(button.data('status'));
                    $('#empRole').val(button.data('role'));
                    $('#empAvatar').val(button.data('avatar'));

                    // Avatar preview
                    const avatarUrl = button.data('avatar') || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(button.data('name'));
                    $('#avatarPreview').attr('src', avatarUrl);

                    // Hiển thị modal
                    $('#modalEmployee').modal('show');
                }

                if (CURRENT_USER_CHUCVU.toLowerCase().includes('trưởng phòng')) {
                    $('#empRole').prop('disabled', true); // Không cho chỉnh vai trò nếu người đăng nhập là Trưởng phòng
                } else {
                    $('#empRole').prop('disabled', false);
                }

                // Nếu phòng ban đã load, thì điền luôn
                if (window.phongBanLoaded) {
                    fillForm();
                } else {
                    // Nếu chưa load xong, chờ rồi điền
                    const interval = setInterval(() => {
                        if (window.phongBanLoaded) {
                            clearInterval(interval);
                            fillForm();
                        }
                    }, 100);
                }
            });

            // Nút xoá
            $(document).on('click', '.delete-emp-btn', function () {
                const id = $(this).data('id');
                const row = $(this).closest('tr');

                Swal.fire({
                    title: 'Xác nhận xoá?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Xoá',
                    cancelButtonText: 'Huỷ'
                }).then((result) => {
                    if (result.isConfirmed) {
                        // Gửi AJAX POST đến Servlet
                        $.ajax({
                            url: './xoaNhanvien',
                            method: 'POST',
                            data: {id: id},
                            success: function (res) {
                                if (res.status === 'ok') {
                                    $('#toastSuccess').toast('show');
                                    row.remove(); // Xoá dòng khỏi bảng
                                } else {
                                    $('#toastError').toast('show');
                                }
                            },
                            error: function () {
                                $('#toastError').toast('show');
                            }
                        });
                    }
                });
            });

            // Submit form thêm/sửa
            $('#employeeForm').on('submit', function (e) {
                e.preventDefault();
                // TODO: AJAX submit form
                $('#modalEmployee').modal('hide');
                $('#toastSuccess').toast('show');
            });

            // Toast init
            $('.toast').toast({delay: 2000});

            // TODO: AJAX load phòng ban cho filter và form
            // TODO: AJAX load phân quyền động cho vai trò từ bảng phan_quyen_chuc_nang
            // TODO: AJAX load lịch sử thay đổi nhân sự cho modalEmpDetail

            // Avatar preview
            $('#empAvatar').on('input', function () {
                $('#avatarPreview').attr('src', $(this).val() || 'https://ui-avatars.com/api/?name=Avatar');
            });

        </script>
        <script>
            $('#employeeForm').on('submit', function (e) {
                e.preventDefault(); // Ngăn form gửi mặc định

                const empId = $('#empId').val(); // Dùng empId để phân biệt thêm/sửa
                const formData = $(this).serialize(); // Lấy toàn bộ dữ liệu form

                const url = empId ? './dsnhanvien' : './themNhanvien';

                $.ajax({
                    url: url,
                    type: 'POST',
                    data: formData,
                    success: function (response) {
                        $('#modalEmployee').modal('hide');
                        showToast('success', empId ? 'Cập nhật thành công' : 'Thêm mới thành công');
                        location.reload(); // Hoặc cập nhật bảng bằng JS
                    },
                    error: function () {
                        showToast('error', empId ? 'Cập nhật thất bại' : 'Thêm mới thất bại');
                    }
                });
            });



            function showToast(type, message) {
                const toastId = type === 'success' ? '#toastSuccess' : '#toastError';
                $(toastId).find('.toast-body').text(message);
                new bootstrap.Toast($(toastId)).show();
            }
        </script>

    </body>

</html>

