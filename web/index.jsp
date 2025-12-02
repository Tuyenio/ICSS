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
    
    // Dữ liệu cho biểu đồ tiến độ dự án theo nhóm dự án
    Map<String, Object> tienDoKyThuat = new HashMap<>();
    Map<String, Object> tienDoKinhDoanh = new HashMap<>();
    
    KNCSDL kn = null;
    try {
        kn = new KNCSDL();
        thongKeTongQuan = kn.getThongKeTongQuan(sess); // {tong_nhan_vien, tong_phong_ban, tong_cong_viec, ty_le_hoan_thanh}
    thongKeTrangThai = kn.getThongKeCongViecTheoTrangThai(sess); // Map trạng thái
    barTienDoPhongBan = kn.getDataForBarChart2(sess);
    
    // Lấy dữ liệu tiến độ dự án cho từng nhóm
    tienDoKyThuat = kn.getTienDoDuAnTheoPhongBan("Phòng Kỹ Thuật");
    tienDoKinhDoanh = kn.getTienDoDuAnTheoPhongBan("Phòng Kinh Doanh");
    
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
            /* BODY + MAIN CONTENT - MODERN WHITE THEME */
            body {
                background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 30%, #cbd5e1 70%, #94a3b8 100%);
                min-height: 100vh;
                font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
                color: #1e293b;
                position: relative;
                overflow-x: hidden;
                font-weight: 500;
                letter-spacing: 0.025em;
            }

            body::before {
                content: '';
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background:
                    radial-gradient(circle at 20% 80%, rgba(59, 130, 246, 0.08) 0%, transparent 50%),
                    radial-gradient(circle at 80% 20%, rgba(139, 92, 246, 0.06) 0%, transparent 50%),
                    radial-gradient(circle at 40% 40%, rgba(16, 185, 129, 0.05) 0%, transparent 50%),
                    url('data:image/svg+xml,<svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse"><path d="M 20 0 L 0 0 0 20" fill="none" stroke="%23e2e8f0" stroke-width="0.5" opacity="0.4"/></pattern></defs><rect width="100%" height="100%" fill="url(%23grid)"/></svg>');
                pointer-events: none;
                z-index: 0;
                animation: subtleGrid 40s ease-in-out infinite alternate;
            }

            @keyframes subtleGrid {
                0% {
                    opacity: 0.6;
                    transform: translateX(0px) translateY(0px);
                }
                100% {
                    opacity: 0.8;
                    transform: translateX(-5px) translateY(-5px);
                }
            }

            .header {
                background: rgba(255, 255, 255, 0.98);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-bottom: 1px solid rgba(226, 232, 240, 0.6);
                min-height: 64px;
                box-shadow:
                    0 4px 24px rgba(0, 0, 0, 0.04),
                    0 1px 3px rgba(0, 0, 0, 0.08);
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

            /* PREMIUM CARD MODULES - MODERN WHITE STYLE */
            .card-module {
                border: none;
                border-radius: 20px;
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border: 1px solid rgba(226, 232, 240, 0.8);
                box-shadow:
                    0 8px 32px rgba(0, 0, 0, 0.08),
                    0 2px 8px rgba(0, 0, 0, 0.04),
                    inset 0 1px 0 rgba(255, 255, 255, 0.8);
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
                    rgba(59, 130, 246, 0.08),
                    transparent
                    );
                transition: left 0.6s ease;
            }

            .card-module:hover::before {
                left: 100%;
            }

            .card-module:hover {
                transform: translateY(-12px) scale(1.05);
                border-color: rgba(59, 130, 246, 0.3);
                box-shadow:
                    0 20px 60px rgba(0, 0, 0, 0.12),
                    0 8px 32px rgba(59, 130, 246, 0.15),
                    inset 0 1px 0 rgba(255, 255, 255, 0.9);
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
                background: linear-gradient(135deg, #3b82f6, #8b5cf6, #10b981);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
                filter: contrast(1.2) brightness(1.1);
            }

            .card-module .card-text {
                color: #64748b;
                font-size: 0.95rem;
                min-height: 48px;
                line-height: 1.6;
                font-weight: 500;
                letter-spacing: 0.01em;
            }

            .card-module i {
                background: linear-gradient(135deg, #3b82f6, #8b5cf6);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
                filter: contrast(1.3) brightness(1.2);
                transition: all 0.3s ease;
            }

            .card-module:hover i {
                transform: scale(1.1) rotate(5deg);
                filter: contrast(1.4) brightness(1.3) drop-shadow(0 2px 8px rgba(59, 130, 246, 0.3));
            }

            .card-module .btn {
                background: linear-gradient(135deg, #3b82f6, #1d4ed8);
                border: none;
                border-radius: 50px;
                padding: 10px 24px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                transition: all 0.3s ease;
                box-shadow:
                    0 4px 15px rgba(59, 130, 246, 0.25),
                    inset 0 1px 0 rgba(255, 255, 255, 0.3);
                color: #ffffff;
                position: relative;
                overflow: hidden;
                text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
            }

            .card-module .btn::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
                transition: left 0.5s ease;
            }

            .card-module .btn:hover::before {
                left: 100%;
            }

            .card-module .btn:hover {
                transform: translateY(-2px);
                box-shadow:
                    0 8px 25px rgba(59, 130, 246, 0.35),
                    0 0 20px rgba(59, 130, 246, 0.2);
            }

            /* DASHBOARD GRID */
            .dashboard-row {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 2rem;
                margin-bottom: 3rem;
            }

            /* PREMIUM STAT CARDS - MODERN WHITE STYLE */
            .stat-card-eq .card {
                border: none;
                border-radius: 20px;
                background: rgba(255, 255, 255, 0.98);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border: 1px solid rgba(226, 232, 240, 0.8);
                box-shadow:
                    0 8px 32px rgba(0, 0, 0, 0.08),
                    0 2px 8px rgba(0, 0, 0, 0.04),
                    inset 0 1px 0 rgba(255, 255, 255, 0.9);
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
                height: 3px;
                background: linear-gradient(90deg, #3b82f6, #8b5cf6, #10b981, #f59e0b);
                background-size: 300% 300%;
                animation: modernGlow 3s ease infinite;
            }

            @keyframes modernGlow {
                0%, 100% {
                    background-position: 0% 50%;
                    filter: brightness(1.0);
                }
                50% {
                    background-position: 100% 50%;
                    filter: brightness(1.2);
                }
            }

            .stat-card-eq .card:hover {
                transform: translateY(-8px) scale(1.03);
                border-color: rgba(59, 130, 246, 0.4);
                box-shadow:
                    0 20px 60px rgba(0, 0, 0, 0.12),
                    0 8px 32px rgba(59, 130, 246, 0.2),
                    inset 0 1px 0 rgba(255, 255, 255, 0.95);
            }

            .stat-card-eq h3 {
                font-size: 2.8rem;
                font-weight: 900;
                background: linear-gradient(135deg, #1e40af, #7c3aed);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
                filter: contrast(1.3) brightness(1.1);
                transition: all 0.3s ease;
                letter-spacing: -0.02em;
            }

            /* ANIMATION STYLES FOR COUNTING NUMBERS */
            .stat-number {
                display: inline-block;
                position: relative;
            }

            .stat-number.counting {
                animation: modernPulse 0.3s ease-in-out;
            }

            @keyframes modernPulse {
                0% {
                    transform: scale(1);
                }
                50% {
                    transform: scale(1.05);
                    filter: contrast(1.2) brightness(1.1);
                }
                100% {
                    transform: scale(1);
                }
            }

            @keyframes countUp {
                0% {
                    opacity: 0.7;
                    transform: translateY(10px);
                }
                100% {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .stat-card-eq h3.animating {
                animation: countUp 0.6s ease-out;
            }

            .stat-card-eq .card-body {
                position: relative;
                z-index: 2;
            }

            .stat-card-eq i {
                color: #3b82f6;
                filter: contrast(1.2) brightness(1.1);
                transition: all 0.3s ease;
            }

            .stat-card-eq .card:hover i {
                transform: scale(1.1);
                filter: contrast(1.3) brightness(1.2) drop-shadow(0 2px 8px rgba(59, 130, 246, 0.3));
            }

            .stat-card-eq p, .stat-card-eq small {
                color: #64748b;
                font-weight: 500;
            }

            .stat-card-eq small b {
                color: #1e40af;
                font-weight: 600;
            }

            /* PREMIUM REPORT BOX - MODERN WHITE STYLE */
            .quick-report-box {
                background: rgba(255, 255, 255, 0.98);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-radius: 20px;
                border: 1px solid rgba(226, 232, 240, 0.8);
                box-shadow:
                    0 8px 32px rgba(0, 0, 0, 0.08),
                    0 2px 8px rgba(0, 0, 0, 0.04),
                    inset 0 1px 0 rgba(255, 255, 255, 0.9);
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
                height: 3px;
                background: linear-gradient(90deg, #3b82f6, #8b5cf6);
                filter: brightness(1.1);
            }

            .quick-report-box h5 {
                font-weight: 700;
                margin-bottom: 1.5rem;
                background: linear-gradient(135deg, #1e40af, #7c3aed);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
                filter: contrast(1.2) brightness(1.1);
                letter-spacing: 0.01em;
            }

            .quick-report-box i {
                color: #3b82f6;
                filter: contrast(1.2) brightness(1.1);
            }

            /* PREMIUM CHART CARDS - MODERN WHITE */
            .chart-card {
                background: rgba(255, 255, 255, 0.98);
                backdrop-filter: blur(20px);
                -webkit-backdrop-filter: blur(20px);
                border-radius: 20px;
                border: 1px solid rgba(226, 232, 240, 0.8);
                box-shadow:
                    0 8px 32px rgba(0, 0, 0, 0.08),
                    0 2px 8px rgba(0, 0, 0, 0.04),
                    inset 0 1px 0 rgba(255, 255, 255, 0.9);
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
                height: 3px;
                background: linear-gradient(90deg, #3b82f6, #8b5cf6);
                filter: brightness(1.1);
            }

            .chart-card h6 {
                font-size: 0.9rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 1rem;
                background: linear-gradient(135deg, #1e40af, #059669);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
                filter: contrast(1.2) brightness(1.1);
            }

            .chart-card i {
                color: #3b82f6;
                filter: contrast(1.2) brightness(1.1);
            }

            .chart-card .small {
                color: #64748b;
                font-weight: 500;
            }

            .chart-card .small b {
                color: #1e40af;
                font-weight: 600;
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

            /* SPECIAL EFFECTS FOR DIFFERENT MODULES - MODERN COLORS */
            .card-module:nth-child(1) .card-title {
                background: linear-gradient(135deg, #3b82f6, #1d4ed8);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            .card-module:nth-child(2) .card-title {
                background: linear-gradient(135deg, #10b981, #059669);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            .card-module:nth-child(3) .card-title {
                background: linear-gradient(135deg, #8b5cf6, #7c3aed);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            .card-module:nth-child(4) .card-title {
                background: linear-gradient(135deg, #f59e0b, #d97706);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            .card-module:nth-child(5) .card-title {
                background: linear-gradient(135deg, #06b6d4, #0891b2);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            .card-module:nth-child(6) .card-title {
                background: linear-gradient(135deg, #ef4444, #dc2626);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            .card-module:nth-child(7) .card-title {
                background: linear-gradient(135deg, #6366f1, #4f46e5);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            /* GLASSMORPHISM ENHANCEMENTS - MODERN WHITE */
            .card-module:hover,
            .stat-card-eq .card:hover,
            .quick-report-box:hover,
            .chart-card:hover {
                background: rgba(255, 255, 255, 0.99);
                border-color: rgba(59, 130, 246, 0.3);
            }

            /* STATUS INDICATOR BOXES - MODERN STYLE */
            .quick-report-box .col-6 > div {
                background: rgba(248, 250, 252, 0.8) !important;
                border: 1px solid rgba(226, 232, 240, 0.8) !important;
                transition: all 0.3s ease;
            }

            .quick-report-box .col-6 > div:hover {
                background: rgba(255, 255, 255, 0.95) !important;
                border-color: rgba(59, 130, 246, 0.3) !important;
                box-shadow: 0 4px 15px rgba(59, 130, 246, 0.15);
            }

            .quick-report-box .small {
                color: #64748b !important;
                font-weight: 500;
            }

            /* ENHANCED TEXT CONTRAST */
            .card-module:hover .card-title,
            .stat-card-eq .card:hover h3,
            .quick-report-box:hover h5,
            .chart-card:hover h6 {
                filter: contrast(1.3) brightness(1.1);
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
                    <!-- Thống kê tổng quan -->
                    <div class="row mb-4">
                        <div class="col-md-3 mb-3 stat-card-eq">
                            <div class="card text-center border-0 shadow-sm h-100 clickable-card" onclick="window.location.href = 'dsnhanvien'">
                                <div class="card-body">
                                    <i class="fa-solid fa-users fa-2x text-primary mb-2"></i>
                                    <h3 class="text-primary mb-1 stat-number" data-target="<%= thongKeTongQuan.getOrDefault("tong_nhan_vien", 0) %>">0</h3>
                                    <p class="text-muted mb-1">Tổng nhân viên</p>
                                    <small class="text-secondary d-block">Đang làm: <b class="stat-number" data-target="<%= thongKeTongQuan.getOrDefault("nv_dang_lam",0) %>">0</b> | Tạm nghỉ: <b class="stat-number" data-target="<%= thongKeTongQuan.getOrDefault("nv_tam_nghi",0) %>">0</b> | Nghỉ việc: <b class="stat-number" data-target="<%= thongKeTongQuan.getOrDefault("nv_nghi_viec",0) %>">0</b></small>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3 stat-card-eq">
                            <div class="card text-center border-0 shadow-sm h-100 clickable-card" onclick="window.location.href = 'dsPhongban'">
                                <div class="card-body">
                                    <i class="fa-solid fa-building fa-2x text-info mb-2"></i>
                                    <h3 class="text-info stat-number" data-target="<%= thongKeTongQuan.getOrDefault("tong_phong_ban", 0) %>">0</h3>
                                    <p class="text-muted mb-0">Phòng ban</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3 stat-card-eq">
                            <div class="card text-center border-0 shadow-sm h-100 clickable-card" onclick="window.location.href = 'dsCongviec'">
                                <div class="card-body">
                                    <i class="fa-solid fa-tasks fa-2x text-success mb-2"></i>
                                    <h3 class="text-success stat-number" data-target="<%= thongKeTongQuan.getOrDefault("tong_cong_viec", 0) %>">0</h3>
                                    <p class="text-muted mb-0">Công việc</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 mb-3 stat-card-eq">
                            <div class="card text-center border-0 shadow-sm h-100">
                                <div class="card-body">
                                    <i class="fa-solid fa-chart-line fa-2x text-warning mb-2"></i>
                                    <h3 class="text-warning stat-number" data-target="<%= Math.round((Double)thongKeTongQuan.getOrDefault("ty_le_hoan_thanh", 0.0)) %>" data-suffix="%">0%</h3>
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
                                        <div class="p-2 rounded-3 d-flex align-items-center gap-2 shadow-sm status-card" 
                                             onclick="window.location.href = 'dsCongviec?trangThai=' + encodeURIComponent('Đã hoàn thành')"
                                             style="cursor:pointer;background:rgba(16,185,129,0.1);border:1px solid rgba(16,185,129,0.3);">
                                            <span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#10b981;box-shadow:0 0 8px rgba(16,185,129,0.4);"></span>
                                            <span style="color:#1e293b;font-weight:600;">
                                                Đã hoàn thành: <b style="color:#059669;" class="stat-number" data-target="<%= daHoanThanh %>">0</b><br>
                                                <small style="color:#64748b;" class="stat-number" data-target="<%= pctHoanThanhInt %>" data-suffix="%">0%</small>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="p-2 rounded-3 d-flex align-items-center gap-2 shadow-sm status-card" 
                                             onclick="window.location.href = 'dsCongviec?trangThai=' + encodeURIComponent('Đang thực hiện')"
                                             style="cursor:pointer;background:rgba(59,130,246,0.1);border:1px solid rgba(59,130,246,0.3);">
                                            <span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#3b82f6;box-shadow:0 0 8px rgba(59,130,246,0.4);"></span>
                                            <span style="color:#1e293b;font-weight:600;">
                                                Đang thực hiện: <b style="color:#1d4ed8;" class="stat-number" data-target="<%= dangThucHien %>">0</b><br>
                                                <small style="color:#64748b;" class="stat-number" data-target="<%= pctDangTHInt %>" data-suffix="%">0%</small>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="p-2 rounded-3 d-flex align-items-center gap-2 shadow-sm status-card" 
                                             onclick="window.location.href = 'dsCongviec?trangThai=' + encodeURIComponent('Trễ hạn')"
                                             style="cursor:pointer;background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.3);">
                                            <span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#ef4444;box-shadow:0 0 8px rgba(239,68,68,0.4);"></span>
                                            <span style="color:#1e293b;font-weight:600;">
                                                Trễ hạn: <b style="color:#dc2626;" class="stat-number" data-target="<%= treHan %>">0</b><br>
                                                <small style="color:#64748b;" class="stat-number" data-target="<%= pctTreHanInt %>" data-suffix="%">0%</small>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="p-2 rounded-3 d-flex align-items-center gap-2 shadow-sm status-card" 
                                             onclick="window.location.href = 'dsCongviec?trangThai=' + encodeURIComponent('Chưa bắt đầu')"
                                             style="cursor:pointer;background:rgba(100,116,139,0.1);border:1px solid rgba(100,116,139,0.3);">
                                            <span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#64748b;"></span>
                                            <span style="color:#1e293b;font-weight:600;">
                                                Chưa bắt đầu: <b style="color:#475569;" class="stat-number" data-target="<%= chuaBatDau %>">0</b><br>
                                                <small style="color:#64748b;" class="stat-number" data-target="<%= pctChuaBDInt %>" data-suffix="%">0%</small>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div class="mt-3 small d-flex justify-content-between align-items-center"
                                     style="color:#64748b;font-weight:500;">

                                    <span>Phân bố trạng thái công việc</span>

                                    <!-- ICON CHUÔNG -->
                                    <button id="btnNhacViecAll" 
                                            class="btn btn-sm btn-outline-warning"
                                            style="border-radius: 50%; width: 32px; height: 32px;">
                                        <i class="fa-solid fa-bell"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Biểu đồ tiến độ dự án theo phòng ban -->
                    <div class="quick-report-box mt-4">
                        <div class="d-flex justify-content-start align-items-center flex-wrap mb-2">
                            <h5 class="mb-0"><i class="fa-solid fa-chart-bar me-2 text-success"></i>Tiến độ dự án theo nhóm</h5>
                        </div>
                        <div class="row g-3 align-items-center">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="nhomDuAnSelect" class="form-label" style="color:#1e293b;font-weight:600;">Chọn nhóm dự án:</label>
                                    <select id="phongBanSelect" class="form-select">
                                        <option value="kyThuat" selected>Phòng Kỹ Thuật</option>
                                        <option value="kinhDoanh">Phòng Kinh Doanh</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-8">
                                <div style="height: 600px; overflow-y: auto; padding-right: 20px;">
                                    <canvas id="chartTienDoDuAn"></canvas>
                                </div>
                                <div class="small text-muted mt-2 d-flex justify-content-between align-items-center">
                                    <span id="projectCountInfo">Hiển thị tiến độ các dự án</span>
                                    <span class="text-success" style="font-weight:600;">
                                        <i class="fa-solid fa-info-circle me-1"></i>
                                        Tiến độ tính theo % hoàn thành
                                    </span>
                                </div>
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
            
            // Dữ liệu cho biểu đồ tiến độ dự án
            List<String> dashboardProjectNames = (List<String>) tienDoKyThuat.getOrDefault("projectNames", Collections.emptyList());
            List<Double> dashboardProgressValues = (List<Double>) tienDoKyThuat.getOrDefault("progressValues", Collections.emptyList());
            List<String> dashboardEndDates = (List<String>) tienDoKyThuat.getOrDefault("endDates", Collections.emptyList());
            List<Integer> dashboardDaysLeft = (List<Integer>) tienDoKyThuat.getOrDefault("daysLeft", Collections.emptyList());
            List<Integer> dashboardProjectIds = (List<Integer>) tienDoKyThuat.getOrDefault("projectIds", Collections.emptyList());

            List<String> anNinhEndDates = (List<String>) tienDoKinhDoanh.getOrDefault("endDates", Collections.emptyList());
            List<Integer> anNinhDaysLeft = (List<Integer>) tienDoKinhDoanh.getOrDefault("daysLeft", Collections.emptyList());
            
            List<String> anNinhProjectNames = (List<String>) tienDoKinhDoanh.getOrDefault("projectNames", Collections.emptyList());
            List<Double> anNinhProgressValues = (List<Double>) tienDoKinhDoanh.getOrDefault("progressValues", Collections.emptyList());
            List<Integer> anNinhProjectIds = (List<Integer>) tienDoKinhDoanh.getOrDefault("projectIds", Collections.emptyList());

            String dashboardProjectNamesAttr = String.join("|", dashboardProjectNames);
            StringBuilder dashboardProgressAttr = new StringBuilder();
            for(int i=0;i<dashboardProgressValues.size();i++){ 
                if(i>0) dashboardProgressAttr.append(','); 
                dashboardProgressAttr.append(dashboardProgressValues.get(i)); 
            }
            
            String anNinhProjectNamesAttr = String.join("|", anNinhProjectNames);
            StringBuilder anNinhProgressAttr = new StringBuilder();
            for(int i=0;i<anNinhProgressValues.size();i++){ 
                if(i>0) anNinhProgressAttr.append(','); 
                anNinhProgressAttr.append(anNinhProgressValues.get(i)); 
            }

            StringBuilder dashboardProjectIdsAttr = new StringBuilder();
            for (int i = 0; i < dashboardProjectIds.size(); i++) {
                if (i > 0) dashboardProjectIdsAttr.append(',');
                dashboardProjectIdsAttr.append(dashboardProjectIds.get(i));
            }

            StringBuilder anNinhProjectIdsAttr = new StringBuilder();
            for (int i = 0; i < anNinhProjectIds.size(); i++) {
                if (i > 0) anNinhProjectIdsAttr.append(',');
                anNinhProjectIdsAttr.append(anNinhProjectIds.get(i));
            }
            
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
             data-di-muon="<%= soLanDiMuon %>"
             data-kt-project-names="<%= dashboardProjectNamesAttr %>"
             data-kt-progress="<%= dashboardProgressAttr.toString() %>"
             data-kt-project-ids="<%= dashboardProjectIdsAttr.toString() %>"
             data-kd-project-names="<%= anNinhProjectNamesAttr %>"
             data-kd-project-ids="<%= anNinhProjectIdsAttr.toString() %>"
             data-kt-end-dates="<%= String.join("|", dashboardEndDates) %>"
             data-kt-days-left="<%= dashboardDaysLeft.toString() %>"
             data-kd-end-dates="<%= String.join("|", anNinhEndDates) %>"
             data-kd-days-left="<%= anNinhDaysLeft.toString() %>"
             data-kd-progress="<%= anNinhProgressAttr.toString() %>"></div>

        <script>
            const attHolder = document.createElement('div');
            attHolder.id = 'attDataHolder';
            attHolder.dataset.days = "<%= daysStr.toString() %>";
            attHolder.dataset.du = "<%= jsDuCong.toString() %>";
            attHolder.dataset.muon = "<%= jsDiMuon.toString() %>";
            attHolder.dataset.thieu = "<%= jsThieuGio.toString() %>";
            attHolder.dataset.vang = "<%= jsVang.toString() %>";
            attHolder.dataset.ot = "<%= jsLamThem.toString() %>";
            document.body.appendChild(attHolder);
        </script>

        <script src="<%= request.getContextPath() %>/scripts/index.js?v=<%= System.currentTimeMillis() %>"></script>

        <!-- PROFESSIONAL NUMBER COUNTER ANIMATION -->
        <script>
            class PremiumCounter {
                constructor() {
                    this.numbers = [];
                    this.isAnimating = false;
                    this.init();
                }

                init() {
                    // Collect all stat numbers
                    document.querySelectorAll('.stat-number').forEach(element => {
                        const target = parseInt(element.getAttribute('data-target')) || 0;
                        const suffix = element.getAttribute('data-suffix') || '';

                        this.numbers.push({
                            element: element,
                            target: target,
                            current: 0,
                            suffix: suffix
                        });
                    });

                    // Start initial animation after page load
                    setTimeout(() => {
                        this.animateAll();
                    }, 1000);

                    // Set interval for periodic animation every 8 seconds
                    setInterval(() => {
                        if (!this.isAnimating) {
                            this.animateAll();
                        }
                    }, 8000);
                }

                animateAll() {
                    this.isAnimating = true;

                    // Add subtle glow effect to cards
                    document.querySelectorAll('.stat-card-eq .card').forEach(card => {
                        card.style.transition = 'all 0.6s ease';
                        card.style.boxShadow = '0 20px 60px rgba(0, 0, 0, 0.15), 0 8px 32px rgba(59, 130, 246, 0.2)';
                    });

                    this.numbers.forEach((num, index) => {
                        setTimeout(() => {
                            this.animateNumber(num);
                        }, index * 200); // Stagger animations
                    });

                    // Reset card glow after animation
                    setTimeout(() => {
                        document.querySelectorAll('.stat-card-eq .card').forEach(card => {
                            card.style.boxShadow = '';
                        });
                        this.isAnimating = false;
                    }, 3000);
                }

                animateNumber(num) {
                    const duration = 1500; // 1.5 seconds
                    const startTime = Date.now();
                    const startValue = 0;

                    // Add animation class
                    num.element.classList.add('animating');

                    const animate = () => {
                        const elapsed = Date.now() - startTime;
                        const progress = Math.min(elapsed / duration, 1);

                        // Easing function for smooth acceleration/deceleration
                        const easeOutCubic = 1 - Math.pow(1 - progress, 3);

                        const currentValue = Math.round(startValue + (num.target - startValue) * easeOutCubic);
                        num.element.textContent = currentValue + num.suffix;

                        // Add subtle pulsing effect during animation
                        if (progress < 1) {
                            const intensity = 10 + Math.sin(progress * Math.PI * 4) * 5;
                            num.element.style.filter = `contrast(1.2) brightness(${1.1 + Math.sin(progress * Math.PI * 4) * 0.1})`;
                            requestAnimationFrame(animate);
                        } else {
                            num.element.style.filter = '';
                            num.element.classList.remove('animating');
                        }
                    };

                    animate();
                }

                // Method to manually trigger animation (for testing)
                trigger() {
                    if (!this.isAnimating) {
                        this.animateAll();
                    }
                }
            }

            // Initialize the counter system
            const premiumCounter = new PremiumCounter();

            // Expose to global scope for testing
            window.premiumCounter = premiumCounter;
        </script>
    </body>
</html>