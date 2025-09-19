<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Calendar" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Lấy dữ liệu từ servlet
    List<Map<String, Object>> danhSachChamCong = (List<Map<String, Object>>) request.getAttribute("danhSachChamCong");
    List<Map<String, Object>> danhSachPhongBan = (List<Map<String, Object>>) request.getAttribute("danhSachPhongBan");
    Map<String, Object> thongKe = (Map<String, Object>) request.getAttribute("thongKe");
    String thangHienTai = (String) request.getAttribute("thangHienTai");
    String namHienTai = (String) request.getAttribute("namHienTai");
    String phongBanDaChon = (String) request.getAttribute("phongBanDaChon");
    String keywordDaChon = (String) request.getAttribute("keywordDaChon");
    
    // Set default values nếu null
    if (danhSachChamCong == null) danhSachChamCong = new ArrayList<>();
    if (danhSachPhongBan == null) danhSachPhongBan = new ArrayList<>();
    if (thongKe == null) thongKe = new HashMap<>();
    if (thangHienTai == null) thangHienTai = "";
    if (namHienTai == null) namHienTai = "";
    if (phongBanDaChon == null) phongBanDaChon = "";
    if (keywordDaChon == null) keywordDaChon = "";
%>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Chấm công & Lương</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-calendar-check me-2"></i>Chấm công & Lương';
        </script>
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

            /* ==== FILTER ROW ==== */
            .filter-row .form-select,
            .filter-row .form-control {
                border-radius: 20px;
                padding: 8px 14px;
            }
            .filter-row button {
                transition: all 0.25s ease;
            }
            .filter-row button:hover {
                transform: scale(1.05);
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
                vertical-align: middle;
            }

            /* ==== BADGES ==== */
            .badge-status {
                font-size: 0.85rem;
                border-radius: 8px;
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

            td .btn-info {
                background: linear-gradient(90deg,#0dcaf0,#4f46e5);
                border: none;
                color: #fff;
            }
            td .btn-info:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(79,70,229,0.4);
            }
            td .btn-warning {
                background: linear-gradient(90deg,#facc15,#eab308);
                border: none;
                color: #fff;
            }
            td .btn-warning:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(250,204,21,0.4);
            }
            td .btn-danger {
                background: linear-gradient(90deg,#ef4444,#dc2626);
                border: none;
                color: #fff;
            }
            td .btn-danger:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(220,38,38,0.4);
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

            /* ==== EMPTY STATE ==== */
            .table .text-center i {
                font-size: 2.2rem;
            }
            .table .text-center p {
                font-size: 1rem;
                margin-top: 6px;
            }

            /* Container của các nút hành động */
            td .action-buttons {
                display: flex;
                gap: 6px;
                justify-content: center; /* căn giữa trong ô */
                align-items: center;
            }

            /* Nút tròn đều */
            td .action-buttons .btn {
                border-radius: 50%;
                width: 36px;   /* bằng nhau */
                height: 36px;  /* bằng nhau */
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 0;
            }

            td .action-buttons .btn i {
                font-size: 0.9rem; /* icon đều */
            }

            /* Nút hành động chính */
            .btn-action {
                border-radius: 50px;
                font-weight: 500;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 8px 18px;
                box-shadow: 0 2px 6px rgba(0,0,0,0.08);
                transition: all 0.2s ease-in-out;
            }

            /* Hover: sáng màu + nổi khối */
            .btn-action:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            }

            /* Primary – Thêm mới */
            .btn-action-primary {
                background: linear-gradient(45deg, #0d6efd, #0dcaf0);
                color: #fff;
                border: none;
            }
            .btn-action-primary:hover {
                background: linear-gradient(45deg, #0b5ed7, #0bb3e6);
                color: #fff;
            }

            /* Success – Xuất file */
            .btn-action-success {
                background: linear-gradient(45deg, #198754, #20c997);
                color: #fff;
                border: none;
            }
            .btn-action-success:hover {
                background: linear-gradient(45deg, #157347, #1ba87a);
                color: #fff;
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
                            <h3 class="mb-0"><i class="fa-solid fa-calendar-check me-2"></i>Chấm công & Lương</h3>
                            <div>
                                <button class="btn btn-action btn-action-primary me-2" data-bs-toggle="modal"
                                        data-bs-target="#modalAddAttendance">
                                    <i class="fa-solid fa-plus"></i> Thêm chấm công
                                </button>
                                <button class="btn btn-action btn-action-success" data-bs-toggle="modal"
                                        data-bs-target="#modalExportPayroll">
                                    <i class="fa-solid fa-file-export"></i> Xuất phiếu chấm công
                                </button>
                            </div>
                        </div>
                        <form method="post" action="dsChamCong">
                            <div class="row mb-3 filter-row g-2">
                                <div class="col-md-3">
                                    <input type="text" name="keyword" class="form-control" 
                                           placeholder="Tìm kiếm theo tên, email..." 
                                           value="<%= keywordDaChon %>">
                                </div>
                                <div class="col-md-3">
                                    <select name="phong_ban" class="form-select">
                                        <option value="">Tất cả phòng ban</option>
                                        <% for (Map<String, Object> pb : danhSachPhongBan) { %>
                                        <option value="<%= pb.get("id") %>" 
                                                <%= String.valueOf(pb.get("id")).equals(phongBanDaChon) ? "selected" : "" %>>
                                            <%= pb.get("ten_phong") %>
                                        </option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <% 
                                    String currentMonth = "";
                                    if (thangHienTai != null && !thangHienTai.isEmpty() && 
                                        namHienTai != null && !namHienTai.isEmpty()) {
                                        currentMonth = namHienTai + "-" + String.format("%02d", Integer.parseInt(thangHienTai));
                                    } else {
                                        Calendar cal = Calendar.getInstance();
                                        currentMonth = cal.get(Calendar.YEAR) + "-" + String.format("%02d", cal.get(Calendar.MONTH) + 1);
                                    }
                                    %>
                                    <input type="month" name="month_filter" class="form-control" 
                                           value="<%= currentMonth %>" 
                                           onchange="this.form.submit()">
                                </div>
                                <div class="col-md-3">
                                    <button type="submit" class="btn btn-outline-secondary w-100 rounded-pill">
                                        <i class="fa-solid fa-filter"></i> Lọc
                                    </button>
                                </div>
                            </div>
                        </form>
                        <div class="table-responsive">
                            <table class="table table-bordered align-middle table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>#</th>
                                        <th>Avatar</th>
                                        <th>Họ tên</th>
                                        <th>Phòng ban</th>
                                        <th>Ngày vào</th>
                                        <th>Ngày</th>
                                        <th>Check-in</th>
                                        <th>Check-out</th>
                                        <th>Số giờ</th>
                                        <th>Trạng thái</th>
                                        <th>Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (danhSachChamCong != null && !danhSachChamCong.isEmpty()) { %>
                                    <% 
                                    int stt = 1;
                                    for (Map<String, Object> item : danhSachChamCong) { 
                                    %>
                                    <tr>
                                        <td><%= stt++ %></td>
                                        <td><img src="<%= item.get("avatar_url") %>" class="rounded-circle" width="36"></td>
                                        <td>
                                            <span class="fw-semibold text-primary attendance-emp-detail"
                                                  style="cursor:pointer;" data-bs-toggle="modal"
                                                  data-bs-target="#modalDetailAttendance"
                                                  data-id="<%= item.get("nhan_vien_id") %>"><%= item.get("ho_ten") %></span>
                                        </td>
                                        <td><%= item.get("ten_phong") %></td>
                                        <td><%= item.get("ngay_vao_lam") %></td>
                                        <td><%= item.get("ngay") %></td>
                                        <td><%= item.get("check_in") != null ? item.get("check_in") : "-" %></td>
                                        <td><%= item.get("check_out") != null ? item.get("check_out") : "-" %></td>
                                        <td><%= item.get("so_gio_lam") != null ? String.format("%.1f", item.get("so_gio_lam")) : "0" %></td>
                                        <td>
                                            <% 
                                            String trangThai = (String) item.get("trang_thai");
                                            String badgeClass = "bg-secondary";
                                            if ("Đi trễ".equals(trangThai)) badgeClass = "bg-warning text-dark";
                                            else if ("Vắng".equals(trangThai)) badgeClass = "bg-danger";
                                            else if ("Đủ công".equals(trangThai)) badgeClass = "bg-success";
                                            %>
                                            <span class="badge <%= badgeClass %> badge-status"><%= trangThai %></span>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <button class="btn btn-sm btn-info rounded-circle"
                                                        data-bs-toggle="modal" data-bs-target="#modalDetailAttendance"
                                                        data-id="<%= item.get("nhan_vien_id") %>"><i
                                                        class="fa-solid fa-eye"></i></button>
                                                <button class="btn btn-sm btn-warning rounded-circle"
                                                        data-bs-toggle="modal" data-bs-target="#modalEditAttendance"
                                                        data-id="<%= item.get("id") %>"><i
                                                        class="fa-solid fa-pen"></i></button>
                                                <button class="btn btn-sm btn-danger rounded-circle"
                                                        onclick="deleteAttendance('<%= item.get("id") %>');"><i
                                                        class="fa-solid fa-trash"></i></button>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% } else { %>
                                    <tr>
                                        <td colspan="12" class="text-center py-4">
                                            <i class="fa-solid fa-inbox text-muted fs-1"></i>
                                            <p class="text-muted mt-2">Không có dữ liệu chấm công</p>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <!-- Modal chi tiết chấm công với tab -->
                    <div class="modal fade" id="modalDetailAttendance" tabindex="-1">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-calendar-day"></i> Chi tiết chấm
                                        công</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <ul class="nav nav-tabs mb-3" id="attendanceDetailTab" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active" id="tab-att-info" data-bs-toggle="tab"
                                                    data-bs-target="#tabAttInfo" type="button" role="tab">Thông
                                                tin</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="tab-att-history" data-bs-toggle="tab"
                                                    data-bs-target="#tabAttHistory" type="button" role="tab">Lịch sử
                                                chấm công</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="tab-att-kpi" data-bs-toggle="tab"
                                                    data-bs-target="#tabAttKPI" type="button" role="tab">Lương &
                                                KPI</button>
                                        </li>
                                    </ul>
                                    <div class="tab-content" id="attendanceDetailTabContent">
                                        <div class="tab-pane fade show active" id="tabAttInfo" role="tabpanel">
                                            <div class="row">
                                                <div class="col-md-3 text-center">
                                                    <img src="https://i.pravatar.cc/100?img=1"
                                                         class="rounded-circle mb-2" width="80">
                                                    <div class="fw-bold">Nguyễn Văn A</div>
                                                    <div class="text-muted small">Kỹ thuật</div>
                                                </div>
                                                <div class="col-md-9">
                                                    <b>Ngày:</b> 10/06/2024<br>
                                                    <b>Check-in:</b> 08:00<br>
                                                    <b>Check-out:</b> 17:00<br>
                                                    <b>Số giờ:</b> 8<br>
                                                    <b>Trạng thái:</b> <span class="badge bg-success">Đủ
                                                        công</span><br>
                                                    <b>Lương ngày:</b> 350,000đ
                                                </div>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade" id="tabAttHistory" role="tabpanel">
                                            <ul id="attendanceHistoryList">
                                                <li>09/06/2024: Đủ công</li>
                                                <li>10/06/2024: Đi trễ</li>
                                                <!-- AJAX load từ bảng cham_cong -->
                                            </ul>
                                        </div>
                                        <div class="tab-pane fade" id="tabAttKPI" role="tabpanel">
                                            <ul id="attendanceSalaryKPI">
                                                <li>Lương tháng 6: 7,800,000đ</li>
                                                <li>KPI: 8.5</li>
                                                <!-- AJAX load từ bảng luong và luu_kpi -->
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Modal thêm chấm công -->
                    <div class="modal fade" id="modalAddAttendance" tabindex="-1">
                        <div class="modal-dialog">
                            <form class="modal-content" action="./dsChamCong" method="post">
                                <input type="hidden" name="action" value="add">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-plus"></i> Thêm chấm công</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="mb-3">
                                        <label class="form-label">Chọn nhân viên</label>
                                        <select class="form-select" name="employeeId" required>
                                            <% for (Map<String, Object> nv : danhSachChamCong) { %>
                                            <option value="<%= nv.get("nhan_vien_id") %>"><%= nv.get("ho_ten") %></option>
                                            <% } %>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Ngày chấm công</label>
                                        <input type="date" class="form-control" name="attendanceDate" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Giờ check-in</label>
                                        <input type="time" class="form-control" name="checkInTime" step="60">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Giờ check-out</label>
                                        <input type="time" class="form-control" name="checkOutTime" step="60">
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="submit" class="btn btn-primary rounded-pill">Lưu</button>
                                    <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <!-- Modal xuất phiếu lương -->
                    <!-- Modal xuất phiếu chấm công -->
                    <div class="modal fade" id="modalExportPayroll" tabindex="-1">
                        <div class="modal-dialog">
                            <form class="modal-content" action="./exportAttendance" method="post">
                                <input type="hidden" name="reportType" value="attendance">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-file-export"></i> Xuất phiếu chấm công</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="mb-3">
                                        <label class="form-label">Định dạng xuất</label>
                                        <select class="form-select" name="exportType" required>
                                            <option value="Excel">Excel (.xlsx)</option>
                                            <option value="PDF">PDF (.pdf)</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Tháng - Năm</label>
                                        <input type="month" class="form-control" name="thangNam" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Nhân viên</label>
                                        <select class="form-select" name="employeeId" required>
                                            <option value="all">Tất cả nhân viên</option>
                                            <% for (Map<String, Object> nv : danhSachChamCong) { %>
                                            <option value="<%= nv.get("nhan_vien_id") %>"><%= nv.get("ho_ten") %></option>
                                            <% } %>
                                        </select>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="submit" class="btn btn-primary rounded-pill">Xuất file</button>
                                    <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <!-- Modal sửa chấm công -->
                    <div class="modal fade" id="modalEditAttendance" tabindex="-1">
                        <div class="modal-dialog">
                            <form class="modal-content" action="./dsChamCong" method="post">
                                <div class="modal-header">
                                    <h5 class="modal-title"><i class="fa-solid fa-pen"></i> Sửa chấm công</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="attendanceId" id="editAttendanceId">
                                    <div class="mb-3">
                                        <label class="form-label">Giờ check-in</label>
                                        <input type="time" class="form-control" name="checkInTime" step="60">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Giờ check-out</label>
                                        <input type="time" class="form-control" name="checkOutTime" step="60">
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="submit" class="btn btn-primary rounded-pill">Lưu</button>
                                    <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
            // Hàm xóa chấm công
            function deleteAttendance(attendanceId) {
                Swal.fire({
                    title: 'Bạn có chắc chắn muốn xóa?',
                    text: 'Hành động này không thể hoàn tác!',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Xóa',
                    cancelButtonText: 'Hủy'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        fetch("dsChamCong?id=" + attendanceId, {
                            method: 'DELETE'
                        })
                                .then(function (response) {
                                    if (response.ok) {
                                        Swal.fire('Đã xóa!', 'Chấm công đã được xóa.', 'success').then(function () {
                                            location.reload();
                                        });
                                    } else {
                                        Swal.fire('Lỗi!', 'Không thể xóa chấm công.', 'error');
                                    }
                                })
                                .catch(function (error) {
                                    Swal.fire('Lỗi!', 'Đã xảy ra lỗi khi xóa.', 'error');
                                });
                    }
                });
            }

            // Hiển thị dữ liệu trong modal sửa chấm công
            $(document).on('show.bs.modal', '#modalEditAttendance', function (event) {
                var button = $(event.relatedTarget);
                var attendanceId = button.data('id');
                var row = button.closest('tr');

                // Lấy dữ liệu từ bảng
                var date = row.find('td:nth-child(6)').text().trim();       // Ngày
                var checkIn = row.find('td:nth-child(7)').text().trim();    // Check-in
                var checkOut = row.find('td:nth-child(8)').text().trim();   // Check-out

                // Gán vào modal
                const formatTime = time => time !== '-' ? time.substring(0, 5) : '';

                $(this).find('#editAttendanceId').val(attendanceId);
                $(this).find('input[name="checkInTime"]').val(formatTime(checkIn));
                $(this).find('input[name="checkOutTime"]').val(formatTime(checkOut));
            });

        </script>

    </body>

</html>

