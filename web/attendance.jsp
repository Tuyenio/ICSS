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

            .table thead th {
                vertical-align: middle;
            }

            .table-hover tbody tr:hover {
                background: #eaf6ff;
            }

            .filter-row .form-select,
            .filter-row .form-control {
                border-radius: 20px;
            }

            .modal-content {
                border-radius: 14px;
            }

            .modal-header,
            .modal-footer {
                border-color: #e9ecef;
            }

            .badge-status {
                font-size: 0.95em;
            }

            @media (max-width: 768px) {
                .main-box {
                    padding: 10px 2px;
                }

                .main-content {
                    padding: 10px 2px;
                }

                .table-responsive {
                    font-size: 0.95rem;
                }
            }
        </style>
    </head>

    <body>
        <div class="d-flex">
            <!-- Sidebar -->
            <nav class="sidebar p-0">
                <div class="sidebar-title text-center py-4 border-bottom border-secondary" style="cursor:pointer;"
                    onclick="location.href='index.jsp'">
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
                        <a href="./dsCongviec"><i class="fa-solid fa-tasks"></i><span>Công việc</span></a>
                    </li>
                    <li>
                        <a href="./dsPhongban"><i class="fa-solid fa-building"></i><span>Phòng ban</span></a>
                    </li>
                    <li>
                        <a href="./dsChamCong" class="active"><i class="fa-solid fa-calendar-check"></i><span>Chấm
                                công</span></a>
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
                        <div class="main-box">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h3 class="mb-0"><i class="fa-solid fa-calendar-check me-2"></i>Chấm công & Lương</h3>
                                <div>
                                    <button class="btn btn-outline-primary rounded-pill px-3 me-2" data-bs-toggle="modal"
                                        data-bs-target="#modalAddAttendance">
                                        <i class="fa-solid fa-plus"></i> Thêm chấm công
                                    </button>
                                    <button class="btn btn-outline-success rounded-pill px-3" data-bs-toggle="modal"
                                        data-bs-target="#modalExportPayroll">
                                        <i class="fa-solid fa-file-export"></i> Xuất phiếu lương
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
                                            <th>Lương ngày</th>
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
                                                        <% 
                                                        Object luongNgay = item.get("luong_ngay");
                                                        if (luongNgay != null) {
                                                            double luong = ((Number) luongNgay).doubleValue();
                                                        %>
                                                            <%= String.format("%,.0fđ", luong) %>
                                                        <% } else { %>
                                                            0đ
                                                        <% } %>
                                                    </td>
                                                    <td>
                                                        <button class="btn btn-sm btn-info rounded-circle"
                                                            data-bs-toggle="modal" data-bs-target="#modalDetailAttendance"
                                                            data-id="<%= item.get("nhan_vien_id") %>"><i
                                                                class="fa-solid fa-eye"></i></button>
                                                        <button class="btn btn-sm btn-warning rounded-circle"
                                                            data-bs-toggle="modal" data-bs-target="#modalEditAttendance"
                                                            data-id="<%= item.get("nhan_vien_id") %>"><i
                                                                class="fa-solid fa-pen"></i></button>
                                                        <button class="btn btn-sm btn-danger rounded-circle"
                                                            onclick="deleteAttendance('<%= item.get("nhan_vien_id") %>');"><i
                                                                class="fa-solid fa-trash"></i></button>
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
                                <form class="modal-content" action="addAttendance" method="post">
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
                                            <input type="time" class="form-control" name="checkInTime">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Giờ check-out</label>
                                            <input type="time" class="form-control" name="checkOutTime">
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
                        <div class="modal fade" id="modalExportPayroll" tabindex="-1">
                            <div class="modal-dialog">
                                <form class="modal-content" action="exportPayroll" method="post">
                                    <div class="modal-header">
                                        <h5 class="modal-title"><i class="fa-solid fa-file-export"></i> Xuất phiếu lương</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="mb-3">
                                            <label class="form-label">Chọn tháng</label>
                                            <input type="month" class="form-control" name="month" required>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Chọn nhân viên</label>
                                            <select class="form-select" name="employeeId">
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
                                <form class="modal-content" action="editAttendance" method="post">
                                    <div class="modal-header">
                                        <h5 class="modal-title"><i class="fa-solid fa-pen"></i> Sửa chấm công</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <input type="hidden" name="attendanceId" id="editAttendanceId">
                                        <div class="mb-3">
                                            <label class="form-label">Ngày chấm công</label>
                                            <input type="date" class="form-control" name="attendanceDate" required>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Giờ check-in</label>
                                            <input type="time" class="form-control" name="checkInTime">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Giờ check-out</label>
                                            <input type="time" class="form-control" name="checkOutTime">
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
                }).then((result) => {
                    if (result.isConfirmed) {
                        fetch(`dsChamCong?id=${attendanceId}`, {
                            method: 'DELETE'
                        })
                        .then(response => {
                            if (response.ok) {
                                Swal.fire('Đã xóa!', 'Chấm công đã được xóa.', 'success').then(() => {
                                    location.reload();
                                });
                            } else {
                                Swal.fire('Lỗi!', 'Không thể xóa chấm công.', 'error');
                            }
                        })
                        .catch(error => {
                            Swal.fire('Lỗi!', 'Đã xảy ra lỗi khi xóa.', 'error');
                        });
                    }
                });
            }

            // Hiển thị dữ liệu trong modal sửa chấm công
            $(document).on('show.bs.modal', '#modalEditAttendance', function (event) {
                const button = $(event.relatedTarget); // Nút kích hoạt modal
                const attendanceId = button.data('id');
                const row = button.closest('tr');

                // Lấy dữ liệu từ hàng tương ứng
                const date = row.find('td:nth-child(6)').text().trim();
                const checkIn = row.find('td:nth-child(7)').text().trim();
                const checkOut = row.find('td:nth-child(8)').text().trim();

                // Đặt dữ liệu vào modal
                $(this).find('#editAttendanceId').val(attendanceId);
                $(this).find('input[name="attendanceDate"]').val(date);
                $(this).find('input[name="checkInTime"]').val(checkIn !== '-' ? checkIn : '');
                $(this).find('input[name="checkOutTime"]').val(checkOut !== '-' ? checkOut : '');
            });
        </script>
    </body>

    </html>

