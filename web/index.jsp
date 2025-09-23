<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="controller.KNCSDL" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    // Kiểm tra đăng nhập (dựa trên session giống userDashboard)
    HttpSession sess = request.getSession(false);
    String email = (sess != null) ? (String) sess.getAttribute("userEmail") : null;
    if (email == null || email.isEmpty()) {
        response.sendRedirect("login.jsp");
        return; // Ngừng render tiếp
    }

    Map<String, Object> thongKeTongQuan = new HashMap<>();
    Map<String, Integer> thongKeTrangThai = new HashMap<>();
    Map<String, Object> barTienDoPhongBan = new HashMap<>();
    Map<String, Object> chamCongThang = new HashMap<>();
    Map<String, Object> chamCongNgay = new HashMap<>();
    KNCSDL kn = null;
    try {
        kn = new KNCSDL();
        thongKeTongQuan = kn.getThongKeTongQuan(sess); // {tong_nhan_vien, tong_phong_ban, tong_cong_viec, ty_le_hoan_thanh}
    thongKeTrangThai = kn.getThongKeCongViecTheoTrangThai(sess); // Map trạng thái
    barTienDoPhongBan = kn.getDataForBarChart(sess);
    // Thống kê chấm công tháng hiện tại (dùng lại getThongKeChamCong)
    Calendar cal = Calendar.getInstance();
    int thangNow = cal.get(Calendar.MONTH) + 1;
    int namNow = cal.get(Calendar.YEAR);
    // Thống kê chấm công toàn bộ nhân viên thường (loại trừ Admin / Quản lý / Trưởng phòng)
    chamCongThang = kn.getThongKeChamCongNhanVienThuong(thangNow, namNow);
    chamCongNgay = kn.getChamCongTheoNgayNhanVienThuong(thangNow, namNow);
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (kn != null) try { kn.close(); } catch (Exception ignore) {}
    }

    // Lấy số liệu trạng thái (gán 0 nếu thiếu)
    int daHoanThanh = thongKeTrangThai.getOrDefault("Đã hoàn thành", 0);
    int dangThucHien = thongKeTrangThai.getOrDefault("Đang thực hiện", 0);
    int treHan = thongKeTrangThai.getOrDefault("Trễ hạn", 0);
    int chuaBatDau = thongKeTrangThai.getOrDefault("Chưa bắt đầu", 0);
    int tongCongViec = daHoanThanh + dangThucHien + treHan + chuaBatDau;
    double pctHoanThanh = tongCongViec > 0 ? daHoanThanh * 100.0 / tongCongViec : 0;
    double pctDangTH = tongCongViec > 0 ? dangThucHien * 100.0 / tongCongViec : 0;
    double pctTreHan = tongCongViec > 0 ? treHan * 100.0 / tongCongViec : 0;
    double pctChuaBD = tongCongViec > 0 ? chuaBatDau * 100.0 / tongCongViec : 0;
            int pctHoanThanhInt = (int)Math.round(pctHoanThanh);
            int pctDangTHInt = (int)Math.round(pctDangTH);
            int pctTreHanInt = (int)Math.round(pctTreHan);
            int pctChuaBDInt = (int)Math.round(pctChuaBD);
            String pctHoanThanhStr = pctHoanThanhInt + "%";
            String pctDangTHStr = pctDangTHInt + "%";
            String pctTreHanStr = pctTreHanInt + "%";
            String pctChuaBDStr = pctChuaBDInt + "%";
            request.setAttribute("pctHoanThanh", pctHoanThanhInt);
            request.setAttribute("pctDangTH", pctDangTHInt);
            request.setAttribute("pctTreHan", pctTreHanInt);
            request.setAttribute("pctChuaBD", pctChuaBDInt);
%>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>QLNS - Dashboard</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            /* BODY + MAIN CONTENT */
            body {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
                color: #1e293b;
                position: relative;
            }

            body::before {
                content: '';
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: url('data:image/svg+xml,<svg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd"><g fill="%23ffffff" fill-opacity="0.03"><circle cx="30" cy="30" r="2"/></g></svg>');
                pointer-events: none;
                z-index: 0;
            }

            .header {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-bottom: 1px solid rgba(255, 255, 255, 0.2);
                min-height: 64px;
                box-shadow: 0 8px 32px rgba(31, 38, 135, 0.15);
                margin-left: 260px;
                position: sticky;
                top: 0;
                z-index: 100;
            }

            .main-content {
                padding: 40px;
                min-height: 100vh;
                margin-left: 260px;
                animation: fadeIn 0.8s ease;
                position: relative;
                z-index: 1;
            }

            /* PREMIUM CARD MODULES */
            .card-module {
                border: none;
                border-radius: 24px;
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                box-shadow: 
                    0 8px 32px rgba(31, 38, 135, 0.15),
                    0 2px 16px rgba(0, 0, 0, 0.1),
                    inset 0 1px 0 rgba(255, 255, 255, 0.2);
                transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                position: relative;
                overflow: hidden;
            }

            .card-module::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(
                    90deg,
                    transparent,
                    rgba(255, 255, 255, 0.3),
                    transparent
                );
                transition: left 0.6s ease;
            }

            .card-module:hover::before {
                left: 100%;
            }

            .card-module:hover {
                transform: translateY(-12px) scale(1.05);
                box-shadow: 
                    0 20px 60px rgba(31, 38, 135, 0.25),
                    0 8px 32px rgba(0, 0, 0, 0.15),
                    inset 0 1px 0 rgba(255, 255, 255, 0.3);
            }

            .card-module .card-body {
                padding: 2rem;
                position: relative;
                z-index: 2;
            }

            .card-module .card-title {
                font-size: 1.25rem;
                font-weight: 700;
                margin-bottom: 8px;
                background: linear-gradient(135deg, #667eea, #764ba2);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            .card-module .card-text {
                color: #64748b;
                font-size: 0.95rem;
                min-height: 48px;
                line-height: 1.6;
            }

            .card-module i {
                background: linear-gradient(135deg, #667eea, #764ba2);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
                filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
                transition: transform 0.3s ease;
            }

            .card-module:hover i {
                transform: scale(1.1) rotate(5deg);
            }

            .card-module .btn {
                background: linear-gradient(135deg, #667eea, #764ba2);
                border: none;
                border-radius: 50px;
                padding: 8px 20px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                transition: all 0.3s ease;
                box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            }

            .card-module .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
            }

            /* DASHBOARD GRID */
            .dashboard-row {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 2rem;
                margin-bottom: 3rem;
            }

            /* PREMIUM STAT CARDS */
            .stat-card-eq .card {
                border: none;
                border-radius: 20px;
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                box-shadow: 
                    0 8px 32px rgba(31, 38, 135, 0.15),
                    inset 0 1px 0 rgba(255, 255, 255, 0.2);
                transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                position: relative;
                overflow: hidden;
            }

            .stat-card-eq .card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, #667eea, #764ba2, #f093fb, #f5576c);
                background-size: 300% 300%;
                animation: gradient 3s ease infinite;
            }

            @keyframes gradient {
                0% { background-position: 0% 50%; }
                50% { background-position: 100% 50%; }
                100% { background-position: 0% 50%; }
            }

            .stat-card-eq .card:hover {
                transform: translateY(-8px) scale(1.02);
                box-shadow: 
                    0 20px 60px rgba(31, 38, 135, 0.2),
                    inset 0 1px 0 rgba(255, 255, 255, 0.3);
            }

            .stat-card-eq h3 {
                font-size: 2.5rem;
                font-weight: 800;
                background: linear-gradient(135deg, #667eea, #764ba2);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
                text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }

            /* PREMIUM REPORT BOX */
            .quick-report-box {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-radius: 24px;
                box-shadow: 
                    0 8px 32px rgba(31, 38, 135, 0.15),
                    inset 0 1px 0 rgba(255, 255, 255, 0.2);
                padding: 2rem;
                animation: slideUp 0.6s ease;
                position: relative;
                overflow: hidden;
            }

            .quick-report-box::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, #667eea, #764ba2);
            }

            .quick-report-box h5 {
                font-weight: 700;
                margin-bottom: 1.5rem;
                background: linear-gradient(135deg, #667eea, #764ba2);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            /* PREMIUM CHART CARDS */
            .chart-card {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-radius: 24px;
                box-shadow: 
                    0 8px 32px rgba(31, 38, 135, 0.15),
                    inset 0 1px 0 rgba(255, 255, 255, 0.2);
                padding: 2rem;
                display: flex;
                flex-direction: column;
                animation: fadeIn 0.8s ease;
                position: relative;
                overflow: hidden;
            }

            .chart-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, #667eea, #764ba2);
            }

            .chart-card h6 {
                font-size: 0.9rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: #475569;
                margin-bottom: 1rem;
                background: linear-gradient(135deg, #667eea, #764ba2);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            .chart-wrapper {
                position: relative;
                flex: 1;
            }

            /* ENHANCED ANIMATIONS */
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(20px) scale(0.95);
                }
                to {
                    opacity: 1;
                    transform: translateY(0) scale(1);
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

            /* RESPONSIVE DESIGN */
            @media (max-width: 1200px) {
                .main-content {
                    margin-left: 240px;
                }
                .header {
                    margin-left: 240px;
                }
            }

            @media (max-width: 992px) {
                .main-content {
                    margin-left: 76px;
                    padding: 24px;
                }
                .header {
                    margin-left: 76px;
                }
                .dashboard-row {
                    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
                    gap: 1.5rem;
                }
            }

            @media (max-width: 576px) {
                .main-content {
                    padding: 16px;
                    margin-left: 60px;
                }
                .header {
                    margin-left: 60px;
                }
                .dashboard-row {
                    grid-template-columns: 1fr;
                    gap: 1rem;
                }
                .card-module .card-body {
                    padding: 1.5rem;
                }
            }

            /* SPECIAL EFFECTS FOR DIFFERENT MODULES */
            .card-module:nth-child(1) .card-title { color: #3b82f6; }
            .card-module:nth-child(2) .card-title { color: #10b981; }
            .card-module:nth-child(3) .card-title { color: #8b5cf6; }
            .card-module:nth-child(4) .card-title { color: #f59e0b; }
            .card-module:nth-child(5) .card-title { color: #06b6d4; }
            .card-module:nth-child(6) .card-title { color: #ef4444; }
            .card-module:nth-child(7) .card-title { color: #6366f1; }

            /* GLASSMORPHISM ENHANCEMENTS */
            .card-module:hover,
            .stat-card-eq .card:hover,
            .quick-report-box:hover,
            .chart-card:hover {
                background: rgba(255, 255, 255, 0.98);
            }
        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-chart-line"></i> Dashboard';
        </script>
    </head>

    <body>
        <div class="d-flex">
            <%@ include file="sidebar.jsp" %>
            <!-- Main -->
            <div class="flex-grow-1">
                <!-- Header -->
                <%@ include file="header.jsp" %>
                <!-- Main Content -->
                <div class="main-content">
                    <!-- Module shortcuts: 2 rows, 4 columns first row, 3 columns second row -->
                    <div class="dashboard-row mb-5" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 2rem;">
                        <div>
                            <div class="card card-module text-center">
                                <div class="card-body">
                                    <i class="fa-solid fa-users fa-3x mb-3"></i>
                                    <h5 class="card-title">Nhân sự</h5>
                                    <p class="card-text">Quản lý thông tin nhân viên, phân quyền, tìm kiếm và đánh giá hiệu suất làm việc.</p>
                                    <a href="./dsnhanvien" class="btn btn-primary btn-sm rounded-pill px-4">Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                        <div>
                            <div class="card card-module text-center">
                                <div class="card-body">
                                    <i class="fa-solid fa-diagram-project fa-3x mb-3"></i>
                                    <h5 class="card-title">Dự án</h5>
                                    <p class="card-text">Quản lý dự án, phân chia công việc, theo dõi tiến độ và báo cáo kết quả.</p>
                                    <a href="./dsDuan" class="btn btn-primary btn-sm rounded-pill px-4">Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                        <div>
                            <div class="card card-module text-center">
                                <div class="card-body">
                                    <i class="fa-solid fa-list-check fa-3x mb-3"></i>
                                    <h5 class="card-title">Công việc</h5>
                                    <p class="card-text">Tạo, phân công, theo dõi tiến độ, báo cáo công việc và đánh giá kết quả.</p>
                                    <a href="./dsCongviec" class="btn btn-primary btn-sm rounded-pill px-4">Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                        <div>
                            <div class="card card-module text-center">
                                <div class="card-body">
                                    <i class="fa-solid fa-building-user fa-3x mb-3"></i>
                                    <h5 class="card-title">Phòng ban</h5>
                                    <p class="card-text">Quản lý phòng ban, trưởng phòng, gán nhân viên và theo dõi hiệu suất.</p>
                                    <a href="./dsPhongban" class="btn btn-primary btn-sm rounded-pill px-4">Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="dashboard-row mb-5" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 2rem;">
                        <div>
                            <div class="card card-module text-center">
                                <div class="card-body">
                                    <i class="fa-solid fa-calendar-check fa-3x mb-3"></i>
                                    <h5 class="card-title">Chấm công</h5>
                                    <p class="card-text">Chấm công, check-in/out, xem lịch sử, xuất phiếu lương và thống kê.</p>
                                    <a href="./dsChamCong" class="btn btn-primary btn-sm rounded-pill px-4">Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                        <div>
                            <div class="card card-module text-center">
                                <div class="card-body">
                                    <i class="fa-solid fa-calendar-days fa-3x mb-3"></i>
                                    <h5 class="card-title">Lịch trình</h5>
                                    <p class="card-text">Lên lịch họp, sự kiện, deadline dự án và nhắc nhở công việc quan trọng.</p>
                                    <a href="calendar.jsp" class="btn btn-primary btn-sm rounded-pill px-4">Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                        <div>
                            <div class="card card-module text-center">
                                <div class="card-body">
                                    <i class="fa-solid fa-chart-column fa-3x mb-3"></i>
                                    <h5 class="card-title">Báo cáo</h5>
                                    <p class="card-text">Báo cáo tổng hợp, xuất file, biểu đồ tiến độ, xem KPI và phân tích dữ liệu.</p>
                                    <a href="./svBaocao" class="btn btn-primary btn-sm rounded-pill px-4">Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Thống kê tổng quan -->
                    <div class="row mb-4">
                        <div class="col-md-3 mb-3 stat-card-eq">
                            <div class="card text-center border-0 shadow-sm h-100">
                                <div class="card-body">
                                    <i class="fa-solid fa-users fa-2x text-primary mb-2"></i>
                                    <h3 class="text-primary mb-1"><%= thongKeTongQuan.getOrDefault("tong_nhan_vien", 0) %></h3>
                                    <p class="text-muted mb-1">Tổng nhân viên</p>
                                    <small class="text-secondary d-block">Đang làm: <b><%= thongKeTongQuan.getOrDefault("nv_dang_lam",0) %></b> | Tạm nghỉ: <b><%= thongKeTongQuan.getOrDefault("nv_tam_nghi",0) %></b> | Nghỉ việc: <b><%= thongKeTongQuan.getOrDefault("nv_nghi_viec",0) %></b></small>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3 stat-card-eq">
                            <div class="card text-center border-0 shadow-sm h-100">
                                <div class="card-body">
                                    <i class="fa-solid fa-building fa-2x text-info mb-2"></i>
                                    <h3 class="text-info"><%= thongKeTongQuan.getOrDefault("tong_phong_ban", 0) %></h3>
                                    <p class="text-muted mb-0">Phòng ban</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3 stat-card-eq">
                            <div class="card text-center border-0 shadow-sm h-100">
                                <div class="card-body">
                                    <i class="fa-solid fa-tasks fa-2x text-success mb-2"></i>
                                    <h3 class="text-success"><%= thongKeTongQuan.getOrDefault("tong_cong_viec", 0) %></h3>
                                    <p class="text-muted mb-0">Công việc</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3 stat-card-eq">
                            <div class="card text-center border-0 shadow-sm h-100">
                                <div class="card-body">
                                    <i class="fa-solid fa-chart-line fa-2x text-warning mb-2"></i>
                                    <h3 class="text-warning"><%= thongKeTongQuan.getOrDefault("ty_le_hoan_thanh", 0.0) %>%</h3>
                                    <p class="text-muted mb-0">Tỷ lệ hoàn thành</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Quick report (reworked as doughnut chart) -->
                    <div class="quick-report-box mt-4">
                        <div class="d-flex justify-content-start align-items-center flex-wrap mb-2">
                            <h5 class="mb-0"><i class="fa-solid fa-chart-pie me-2 text-primary"></i>Báo cáo nhanh</h5>
                        </div>
                        <div class="row g-3 align-items-center">
                            <div class="col-md-5">
                                <div class="position-relative" style="height:220px;">
                                    <canvas id="chartTrangThaiCV"></canvas>
                                </div>
                            </div>
                            <div class="col-md-7">
                                <div class="row g-2 small" style="--bs-gutter-x:0.75rem;">
                                    <div class="col-6">
                                        <div class="p-2 rounded-3 d-flex align-items-center gap-2 shadow-sm" style="background:#f1f8f4;">
                                            <span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#198754;"></span>
                                            <span>Đã hoàn thành: <b><%= daHoanThanh %></b><br><small class="text-muted"><%= pctHoanThanhInt %>%</small></span>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="p-2 rounded-3 d-flex align-items-center gap-2 shadow-sm" style="background:#fff9e6;">
                                            <span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#ffc107;"></span>
                                            <span>Đang thực hiện: <b><%= dangThucHien %></b><br><small class="text-muted"><%= pctDangTHInt %>%</small></span>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="p-2 rounded-3 d-flex align-items-center gap-2 shadow-sm" style="background:#fdecec;">
                                            <span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#dc3545;"></span>
                                            <span>Trễ hạn: <b><%= treHan %></b><br><small class="text-muted"><%= pctTreHanInt %>%</small></span>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="p-2 rounded-3 d-flex align-items-center gap-2 shadow-sm" style="background:#f2f3f5;">
                                            <span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#6c757d;"></span>
                                            <span>Chưa bắt đầu: <b><%= chuaBatDau %></b><br><small class="text-muted"><%= pctChuaBDInt %>%</small></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="mt-3 small text-muted">Phân bố trạng thái công việc</div>
                            </div>
                        </div>
                    </div>
                    <!-- Biểu đồ -->
                    <div class="row mt-5 g-4 align-items-stretch">
                        <!-- Chấm công theo ngày -->
                        <div class="col-lg-6 col-md-12">
                            <div class="chart-card h-100">
                                <h6><i class="fa-solid fa-calendar-check me-2 text-info"></i>Chấm công tháng (NV thường) - Theo ngày</h6>
                                <div class="chart-wrapper" style="height:360px;">
                                    <canvas id="chartChamCongNgay"></canvas>
                                </div>
                                <div class="small text-muted mt-3 d-flex flex-wrap gap-3">
                                    <span>NV tham gia: <b><%= chamCongThang.getOrDefault("so_nv",0) %></b></span>
                                    <span>Tổng lượt: <b><%= chamCongThang.getOrDefault("tong_luot",0) %></b></span>
                                    <span>Đi muộn: <b><%= chamCongThang.getOrDefault("di_muon",0) %></b></span>
                                    <span>TL đi muộn: <b><%= chamCongThang.getOrDefault("ty_le_di_muon",0.0) %>%</b></span>
                                </div>
                            </div>
                        </div>
                        <!-- Tiến độ phòng ban riêng -->
                        <div class="col-lg-6 col-md-12">
                            <div class="chart-card h-100 d-flex flex-column">
                                <h6 class="mb-2"><i class="fa-solid fa-building me-2 text-warning"></i>Tiến độ phòng ban</h6>
                                <div style="flex:1;position:relative;min-height:340px;">
                                    <canvas id="chartTienDoPB"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
            // Ví dụ toast khi đăng nhập thành công
            $(function () {
                // Swal.fire({icon:'success',title:'Đăng nhập thành công!',toast:true,position:'top-end',timer:2000,showConfirmButton:false});
            });
        </script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
        <%
            List<String> pbLabels = (List<String>) barTienDoPhongBan.getOrDefault("labels", Collections.emptyList());
            List<Double> pbValues = (List<Double>) barTienDoPhongBan.getOrDefault("data", Collections.emptyList());
            int tongNgayLam = (int) chamCongThang.getOrDefault("tong_luot",0);
            int soLanDiMuon = (int) chamCongThang.getOrDefault("di_muon",0);
            // dữ liệu chấm công theo ngày
            List<Integer> ccDays = (List<Integer>) chamCongNgay.getOrDefault("days", Collections.emptyList());
            List<Integer> ccDuCong = (List<Integer>) chamCongNgay.getOrDefault("du_cong", Collections.emptyList());
            List<Integer> ccDiMuon = (List<Integer>) chamCongNgay.getOrDefault("di_muon", Collections.emptyList());
            List<Integer> ccThieuGio = (List<Integer>) chamCongNgay.getOrDefault("thieu_gio", Collections.emptyList());
            List<Integer> ccVang = (List<Integer>) chamCongNgay.getOrDefault("vang", Collections.emptyList());
            List<Integer> ccLamThem = (List<Integer>) chamCongNgay.getOrDefault("lam_them", Collections.emptyList());
            StringBuilder daysStr=new StringBuilder(); for(int i=0;i<ccDays.size();i++){ if(i>0) daysStr.append(','); daysStr.append(ccDays.get(i)); }
            StringBuilder jsDuCong=new StringBuilder(); for(int i=0;i<ccDuCong.size();i++){ if(i>0) jsDuCong.append(','); jsDuCong.append(ccDuCong.get(i)); }
            StringBuilder jsDiMuon=new StringBuilder(); for(int i=0;i<ccDiMuon.size();i++){ if(i>0) jsDiMuon.append(','); jsDiMuon.append(ccDiMuon.get(i)); }
            StringBuilder jsThieuGio=new StringBuilder(); for(int i=0;i<ccThieuGio.size();i++){ if(i>0) jsThieuGio.append(','); jsThieuGio.append(ccThieuGio.get(i)); }
            StringBuilder jsVang=new StringBuilder(); for(int i=0;i<ccVang.size();i++){ if(i>0) jsVang.append(','); jsVang.append(ccVang.get(i)); }
            StringBuilder jsLamThem=new StringBuilder(); for(int i=0;i<ccLamThem.size();i++){ if(i>0) jsLamThem.append(','); jsLamThem.append(ccLamThem.get(i)); }
            String pbLabelsAttr = String.join("|", pbLabels);
            StringBuilder pbValsAttr = new StringBuilder();
            for(int i=0;i<pbValues.size();i++){ if(i>0) pbValsAttr.append(','); pbValsAttr.append(pbValues.get(i)); }
            // (Removed personnel composition chart)
        %>
        <div id="chartDataHolder" style="display:none"
             data-pb-labels="<%= pbLabelsAttr %>"
             data-pb-values="<%= pbValsAttr.toString() %>"
             data-cc-labels=""
             data-cc-values=""
             data-st-ht="<%= daHoanThanh %>"
             data-st-th="<%= dangThucHien %>"
             data-st-tre="<%= treHan %>"
             data-st-cbd="<%= chuaBatDau %>"
             data-tong-ngay="<%= tongNgayLam %>"
             data-di-muon="<%= soLanDiMuon %>"></div>
        <script>
            (function () {
                const h = document.getElementById('chartDataHolder');
                if (!h)
                    return;
                const pbLabels = h.dataset.pbLabels ? h.dataset.pbLabels.split('|').filter(v => v) : [];
                const pbValues = h.dataset.pbValues ? h.dataset.pbValues.split(',').map(Number) : [];
                const ccLabels = h.dataset.ccLabels ? h.dataset.ccLabels.split('|').filter(v => v) : [];
                const ccValues = h.dataset.ccValues ? h.dataset.ccValues.split(',').map(Number) : [];
                const tongNgay = parseInt(h.dataset.tongNgay || '0');
                const diMuon = parseInt(h.dataset.diMuon || '0');
                // Tiến độ phòng ban (horizontal bar for better balance)
                const ctxPB = document.getElementById('chartTienDoPB');
                if (ctxPB) {
                    // sort phòng ban theo % giảm dần để trực quan
                    const pbPairs = pbLabels.map((l, i) => ({label: l, val: pbValues[i] || 0})).sort((a, b) => b.val - a.val);
                    const sortedLabels = pbPairs.map(p => p.label);
                    const sortedVals = pbPairs.map(p => p.val);
                    const colorScale = v => {
                        if (v >= 90)
                            return '#198754';
                        if (v >= 70)
                            return '#0d6efd';
                        if (v >= 50)
                            return '#ffc107';
                        if (v >= 30)
                            return '#fd7e14';
                        return '#dc3545';
                    };
                    const barColors = sortedVals.map(colorScale);
                    new Chart(ctxPB, {type: 'bar', data: {labels: sortedLabels, datasets: [{label: '% Hoàn thành', data: sortedVals, backgroundColor: barColors, borderWidth: 0, barPercentage: 0.55, categoryPercentage: 0.55}]}, options: {indexAxis: 'y', responsive: true, plugins: {legend: {display: false}, tooltip: {callbacks: {label: (c) => c.parsed.x + '%'}}}, scales: {x: {beginAtZero: true, max: 100, ticks: {callback: (v) => v + '%'}}, y: {ticks: {autoSkip: false}}}}});
                }
                // Trạng thái công việc - Doughnut
                const ctxTT = document.getElementById('chartTrangThaiCV');
                if (ctxTT) {
                    const trangThaiData = [parseInt(h.dataset.stHt || '0'), parseInt(h.dataset.stTh || '0'), parseInt(h.dataset.stTre || '0'), parseInt(h.dataset.stCbd || '0')];
                    const colorsTT = ['#198754', '#0d6efd', '#dc3545', '#6c757d']; // xanh lá, xanh dương, đỏ, xám
                    const labelsTT = ['Hoàn thành', 'Đang thực hiện', 'Trễ hạn', 'Chưa bắt đầu'];
                    const totalTT = trangThaiData.reduce((a, b) => a + b, 0);
                    const centerText = totalTT + " CV";
                    new Chart(ctxTT, {type: 'doughnut', data: {labels: labelsTT, datasets: [{data: trangThaiData, backgroundColor: colorsTT, borderWidth: 1}]}, options: {cutout: '70%', plugins: {legend: {display: false}, tooltip: {callbacks: {label: (ctx) => ctx.label + ': ' + ctx.parsed + ' (' + (totalTT ? Math.round(ctx.parsed * 100 / totalTT) : 0) + '%)'}}}}, plugins: [{id: 'centerText', afterDraw(chart, args, opts) {
                                    const {ctx} = chart;
                                    const meta = chart.getDatasetMeta(0);
                                    if (!meta || !meta.data || !meta.data.length)
                                        return;
                                    ctx.save();
                                    ctx.font = '600 17px system-ui';
                                    ctx.fillStyle = '#212529';
                                    ctx.textAlign = 'center';
                                    ctx.textBaseline = 'middle';
                                    const x = meta.data[0].x, y = meta.data[0].y;
                                    ctx.fillText(centerText, x, y - 4);
                                    ctx.font = '400 11px system-ui';
                                    ctx.fillStyle = '#6c757d';
                                    ctx.fillText('Tổng', x, y + 16);
                                    ctx.restore();
                                }}]});
                }
                // (Removed personnel composition chart)
                // Chuyển dữ liệu chấm công theo ngày sang data-* để tránh lỗi JSP parser
                const attHolder = document.createElement('div');
                attHolder.id = 'attDataHolder';
                attHolder.dataset.days = "<%= daysStr.toString() %>";
                attHolder.dataset.du = "<%= jsDuCong.toString() %>";
                attHolder.dataset.muon = "<%= jsDiMuon.toString() %>";
                attHolder.dataset.thieu = "<%= jsThieuGio.toString() %>";
                attHolder.dataset.vang = "<%= jsVang.toString() %>";
                attHolder.dataset.ot = "<%= jsLamThem.toString() %>";
                document.body.appendChild(attHolder);
                const ctxCCongNgay = document.getElementById('chartChamCongNgay');
                if (ctxCCongNgay) {
                    const h2 = document.getElementById('attDataHolder');
                    const parseArr = s => s ? s.split(',').map(Number) : [];
                    const days = h2.dataset.days ? h2.dataset.days.split(',') : [];
                    const ds = [
                        {label: 'Đủ công', data: parseArr(h2.dataset.du), backgroundColor: '#198754', stack: 'att'},
                        {label: 'Đi muộn', data: parseArr(h2.dataset.muon), backgroundColor: '#0d6efd', stack: 'att'},
                        {label: 'Thiếu giờ', data: parseArr(h2.dataset.thieu), backgroundColor: '#ffc107', stack: 'att'},
                        {label: 'Vắng', data: parseArr(h2.dataset.vang), backgroundColor: '#dc3545', stack: 'att'},
                        {label: 'OT/WFH', data: parseArr(h2.dataset.ot), backgroundColor: '#20c997', stack: 'att'}
                    ];
                    new Chart(ctxCCongNgay, {type: 'bar', data: {labels: days, datasets: ds}, options: {responsive: true, plugins: {legend: {position: 'bottom'}, tooltip: {mode: 'index', intersect: false}}, scales: {x: {stacked: true}, y: {stacked: true, beginAtZero: true}}}});
                }
            })();
        </script>
    </body>
</html>

