<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Lấy dữ liệu từ servlet
    Map<String, Object> nhanVienInfo = (Map<String, Object>) request.getAttribute("nhanVienInfo");
    List<Map<String, Object>> lichSuChamCong = (List<Map<String, Object>>) request.getAttribute("lichSuChamCong");
    Map<String, Object> thongKeChamCong = (Map<String, Object>) request.getAttribute("thongKeChamCong");
    Map<String, Object> chamCongHomNay = (Map<String, Object>) request.getAttribute("chamCongHomNay");
    String thangHienTai = (String) request.getAttribute("thangHienTai");
    String namHienTai = (String) request.getAttribute("namHienTai");
    
    // Set default values nếu null hoặc rỗng
    if (nhanVienInfo == null) nhanVienInfo = new HashMap<>();
    if (lichSuChamCong == null) lichSuChamCong = new ArrayList<>();
    if (thongKeChamCong == null) thongKeChamCong = new HashMap<>();
    if (chamCongHomNay == null) chamCongHomNay = new HashMap<>();
    
    // Xử lý tháng/năm an toàn
    int thangInt = 1;
    int namInt = 2024;
    try {
        if (thangHienTai != null && !thangHienTai.trim().isEmpty()) {
            thangInt = Integer.parseInt(thangHienTai);
        } else {
            thangInt = java.util.Calendar.getInstance().get(java.util.Calendar.MONTH) + 1;
        }
        if (namHienTai != null && !namHienTai.trim().isEmpty()) {
            namInt = Integer.parseInt(namHienTai);
        } else {
            namInt = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
        }
    } catch (NumberFormatException e) {
        thangInt = java.util.Calendar.getInstance().get(java.util.Calendar.MONTH) + 1;
        namInt = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
    }
    
    if (thangHienTai == null || thangHienTai.trim().isEmpty()) {
        thangHienTai = String.valueOf(thangInt);
    }
    if (namHienTai == null || namHienTai.trim().isEmpty()) {
        namHienTai = String.valueOf(namInt);
    }
%>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <title>Chấm công</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            html,
            body {
                font-family: 'Inter', 'Roboto', Arial, sans-serif !important;
                background: #f4f6fa;
                color: #23272f;
            }

            .sidebar,
            .sidebar * {
                font-family: inherit !important;
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

            .sidebar-nav a .fa-solid,
            .sidebar-nav a .fa-regular,
            .sidebar-nav a .fa {
                width: 26px;
                text-align: center;
                font-size: 1.25rem;
                min-width: 26px;
            }

            .sidebar-nav a span {
                display: inline;
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

            .main-content {
                padding: 36px 36px 24px 36px;
                min-height: 100vh;
                margin-left: 240px;
            }

            .header {
                background: #fff;
                border-bottom: 1px solid #dee2e6;
                min-height: 64px;
                box-shadow: 0 2px 8px #0001;
                margin-left: 240px;
            }

            .avatar {
                width: 38px;
                height: 38px;
                border-radius: 50%;
                object-fit: cover;
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

            .stat-card {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-radius: 12px;
                padding: 20px;
                margin-bottom: 15px;
            }

            .stat-card h5 {
                margin: 0;
                font-size: 2rem;
                font-weight: bold;
            }

            .stat-card p {
                margin: 5px 0 0 0;
                opacity: 0.9;
            }

            @media (max-width: 768px) {
                .main-box {
                    padding: 10px 2px;
                }

                .main-content {
                    padding: 10px 2px;
                    margin-left: 60px;
                }

                .header {
                    margin-left: 60px;
                }

                .table-responsive {
                    font-size: 0.95rem;
                }
            }

            .sidebar i {
                font-family: "Font Awesome 6 Free" !important;
                font-weight: 900;
            }
        </style>
        <script>
            var USER_PAGE_TITLE = '<i class="fa-solid fa-calendar-check me-2"></i>Chấm công';
        </script>
    </head>

    <body>
        <nav class="sidebar p-0">
            <div class="sidebar-title text-center py-4 border-bottom border-secondary" style="cursor:pointer;"
                onclick="location.href='user_dashboard.jsp'">
                <i class="fa-solid fa-user me-2"></i>ICSS
            </div>
            <ul class="sidebar-nav mt-3">
                <li>
                    <a href="user_dashboard.jsp"><i class="fa-solid fa-chart-line"></i><span>Dashboard</span></a>
                </li>
                <li>
                    <a href="./dsCongviecNV"><i class="fa-solid fa-tasks"></i><span>Công việc của tôi</span></a>
                </li>
                <li>
                    <a href="./userChamCong" class="active"><i class="fa-solid fa-calendar-check"></i><span>Chấm
                            công</span></a>
                </li>
                <li>
                    <a href="./userLuong"><i class="fa-solid fa-money-bill"></i><span>Lương & KPI</span></a>
                </li>
                
            </ul>
        </nav>
        <%@ include file="user_header.jsp" %>
            <div class="main-content">
                <!-- Thống kê tổng quan -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h5><%=thongKeChamCong.get("tong_ngay_cham") != null ? thongKeChamCong.get("tong_ngay_cham") : 0%></h5>
                            <p>Ngày đã chấm công</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                            <h5><%=thongKeChamCong.get("ngay_di_tre") != null ? thongKeChamCong.get("ngay_di_tre") : 0%></h5>
                            <p>Ngày đi trễ</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                            <h5><%=thongKeChamCong.get("tong_gio_lam") != null ? String.format("%.1f", thongKeChamCong.get("tong_gio_lam")) : "0.0"%></h5>
                            <p>Tổng giờ làm việc</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);">
                            <h5><%=thongKeChamCong.get("ngay_du_cong") != null ? thongKeChamCong.get("ngay_du_cong") : 0%></h5>
                            <p>Ngày đủ công</p>
                        </div>
                    </div>
                </div>

                <div class="main-box mb-3">
                    <h3 class="mb-4"><i class="fa-solid fa-calendar-check me-2"></i>Chấm công tháng <%=thangHienTai%>/<%=namHienTai%></h3>
                    
                    <!-- Nút chấm công -->
                    <div class="d-flex align-items-center mb-4">
                        <button class="btn btn-success me-2" id="btnCheckIn" 
                                <%=chamCongHomNay.get("da_check_in") != null && (Boolean)chamCongHomNay.get("da_check_in") ? "disabled" : ""%>>
                            <i class="fa-solid fa-sign-in-alt"></i> Check-in
                        </button>
                        <button class="btn btn-danger me-3" id="btnCheckOut"
                                <%=chamCongHomNay.get("da_check_out") != null && (Boolean)chamCongHomNay.get("da_check_out") ? "disabled" : ""%>>
                            <i class="fa-solid fa-sign-out-alt"></i> Check-out
                        </button>
                        
                        <!-- Hiển thị trạng thái hôm nay -->
                        <div class="ms-3">
                            <% if (chamCongHomNay.get("check_in") != null) { %>
                                <span class="badge bg-success me-2">Check-in: <%=chamCongHomNay.get("check_in")%></span>
                            <% } %>
                            <% if (chamCongHomNay.get("check_out") != null) { %>
                                <span class="badge bg-danger">Check-out: <%=chamCongHomNay.get("check_out")%></span>
                            <% } %>
                        </div>
                    </div>

                    <!-- Filter tháng/năm -->
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="d-flex gap-2">
                                <select class="form-select" id="filterThang" style="width: 120px;">
                                    <% for(int i = 1; i <= 12; i++) { %>
                                        <option value="<%=i%>" <%=i == thangInt ? "selected" : ""%>>Tháng <%=i%></option>
                                    <% } %>
                                </select>
                                <select class="form-select" id="filterNam" style="width: 120px;">
                                    <% 
                                        int currentYear = Calendar.getInstance().get(Calendar.YEAR);
                                        for(int year = currentYear - 2; year <= currentYear + 1; year++) { 
                                    %>
                                        <option value="<%=year%>" <%=year == namInt ? "selected" : ""%>><%=year%></option>
                                    <% } %>
                                </select>
                                <button class="btn btn-primary" onclick="filterByMonth()">
                                    <i class="fa-solid fa-filter"></i> Lọc
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="table table-bordered align-middle table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>Ngày</th>
                                    <th>Check-in</th>
                                    <th>Check-out</th>
                                    <th>Số giờ</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (lichSuChamCong != null && !lichSuChamCong.isEmpty()) { %>
                                    <% for (Map<String, Object> record : lichSuChamCong) { %>
                                        <tr>
                                            <td><%=record.get("ngay")%></td>
                                            <td><%=record.get("check_in") != null ? record.get("check_in") : "-"%></td>
                                            <td><%=record.get("check_out") != null ? record.get("check_out") : "-"%></td>
                                            <td><%=record.get("so_gio_lam") != null ? String.format("%.1f", record.get("so_gio_lam")) : "0"%> giờ</td>
                                            <td>
                                                <% 
                                                    String trangThai = (String) record.get("trang_thai");
                                                    String badgeClass = "bg-secondary";
                                                    if ("Đủ công".equals(trangThai)) badgeClass = "bg-success";
                                                    else if ("Đi trễ".equals(trangThai)) badgeClass = "bg-warning";
                                                    else if ("Vắng mặt".equals(trangThai)) badgeClass = "bg-danger";
                                                    else if ("Thiếu giờ".equals(trangThai)) badgeClass = "bg-info";
                                                %>
                                                <span class="badge <%=badgeClass%>"><%=trangThai%></span>
                                            </td>
                                        </tr>
                                    <% } %>
                                <% } else { %>
                                    <tr>
                                        <td colspan="5" class="text-center text-muted">
                                            <i class="fa-solid fa-inbox"></i> Chưa có dữ liệu chấm công tháng này
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <script>
                $(document).ready(function() {
                    // Xử lý check-in
                    $('#btnCheckIn').click(function() {
                        $.ajax({
                            url: './userChamCong',
                            type: 'POST',
                            data: {action: 'checkin'},
                            success: function(response) {
                                if (response.success) {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Thành công!',
                                        text: response.message,
                                        showConfirmButton: false,
                                        timer: 1500
                                    }).then(() => {
                                        location.reload();
                                    });
                                } else {
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Lỗi!',
                                        text: response.message
                                    });
                                }
                            },
                            error: function() {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Lỗi!',
                                    text: 'Không thể kết nối đến server'
                                });
                            }
                        });
                    });

                    // Xử lý check-out
                    $('#btnCheckOut').click(function() {
                        $.ajax({
                            url: './userChamCong',
                            type: 'POST',
                            data: {action: 'checkout'},
                            success: function(response) {
                                if (response.success) {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Thành công!',
                                        text: response.message,
                                        showConfirmButton: false,
                                        timer: 1500
                                    }).then(() => {
                                        location.reload();
                                    });
                                } else {
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Lỗi!',
                                        text: response.message
                                    });
                                }
                            },
                            error: function() {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Lỗi!',
                                    text: 'Không thể kết nối đến server'
                                });
                            }
                        });
                    });
                });

                // Hàm lọc theo tháng
                function filterByMonth() {
                    const thang = document.getElementById('filterThang').value;
                    const nam = document.getElementById('filterNam').value;
                    window.location.href = './userChamCong?thang=' + thang + '&nam=' + nam;
                }
            </script>
    </body>

    </html>