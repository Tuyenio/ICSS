<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Lấy dữ liệu từ servlet
    List<Map<String, Object>> dsNhanVienPhep = (List<Map<String, Object>>) request.getAttribute("dsNhanVienPhep");
    Integer nam = (Integer) request.getAttribute("nam");
    Double tongPhepCapPhat = (Double) request.getAttribute("tongPhepCapPhat");
    Double tongPhepDaDung = (Double) request.getAttribute("tongPhepDaDung");
    Double tongPhepConLai = (Double) request.getAttribute("tongPhepConLai");
    Double tongPhepNamTruoc = (Double) request.getAttribute("tongPhepNamTruoc");
    Integer soLuongNhanVien = (Integer) request.getAttribute("soLuongNhanVien");
    
    String emailSession = (String) session.getAttribute("userEmail");
    String vaiTro = (String) session.getAttribute("vaiTro");
    
    // Set default values
    if (dsNhanVienPhep == null) dsNhanVienPhep = new ArrayList<>();
    if (nam == null) nam = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
    if (tongPhepCapPhat == null) tongPhepCapPhat = 0.0;
    if (tongPhepDaDung == null) tongPhepDaDung = 0.0;
    if (tongPhepConLai == null) tongPhepConLai = 0.0;
    if (tongPhepNamTruoc == null) tongPhepNamTruoc = 0.0;
    if (soLuongNhanVien == null) soLuongNhanVien = 0;
    
    DecimalFormat df = new DecimalFormat("#0.0");
%>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/png" href="Img/logoics.png">
    <title>Thống kê ngày phép - ICSS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --success-gradient: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            --warning-gradient: linear-gradient(135deg, #f5af19 0%, #f12711 100%);
            --info-gradient: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            --danger-gradient: linear-gradient(135deg, #ff416c 0%, #ff4b2b 100%);
        }

        html, body {
            background: linear-gradient(135deg, #f5f7fa 0%, #e4e8ec 100%);
            font-family: 'Inter', 'Segoe UI', Roboto, sans-serif;
            color: #1e293b;
            min-height: 100vh;
        }

        .main-content {
            padding: 36px 36px 24px 36px;
            min-height: 100vh;
            margin-left: 260px;
        }

        @media (max-width: 1200px) {
            .main-content { margin-left: 240px; }
        }
        @media (max-width: 992px) {
            .main-content { margin-left: 76px; padding: 20px 15px; }
        }
        @media (max-width: 576px) {
            .main-content { margin-left: 60px; padding: 15px 10px; }
        }

        /* ===== HEADER SECTION ===== */
        .page-header {
            background: var(--primary-gradient);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            color: white;
            box-shadow: 0 10px 40px rgba(102, 126, 234, 0.3);
            position: relative;
            overflow: hidden;
        }

        .page-header::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 100%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
        }

        .page-header h2 {
            font-weight: 700;
            margin: 0;
            position: relative;
            z-index: 1;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        /* ===== STAT CARDS ===== */
        .stat-card {
            border-radius: 16px;
            padding: 24px;
            color: white;
            text-align: center;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            cursor: pointer;
            height: 100%;
        }

        .stat-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 15px 45px rgba(0, 0, 0, 0.2);
        }

        .stat-card.total { background: var(--primary-gradient); }
        .stat-card.used { background: var(--danger-gradient); }
        .stat-card.remaining { background: var(--success-gradient); }
        .stat-card.previous { background: var(--info-gradient); }

        .stat-card .stat-icon { font-size: 2.5rem; margin-bottom: 10px; opacity: 0.9; }
        .stat-card .stat-value { font-size: 2.2rem; font-weight: 700; margin: 0; }
        .stat-card .stat-label { font-size: 0.95rem; opacity: 0.9; margin-top: 5px; }

        /* ===== MAIN BOX ===== */
        .main-box {
            background: white;
            border-radius: 20px;
            box-shadow: 0 5px 30px rgba(0, 0, 0, 0.08);
            padding: 30px;
            margin-bottom: 30px;
        }

        .main-box .box-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f1f5f9;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .main-box .box-title i {
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* ===== FILTER SECTION ===== */
        .filter-section {
            display: flex;
            gap: 15px;
            align-items: center;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }

        .filter-section select {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 10px 15px;
            font-size: 0.95rem;
            transition: all 0.3s;
        }

        .filter-section select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            outline: none;
        }

        /* ===== TABLE ===== */
        .table-responsive {
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .table {
            margin: 0;
        }

        .table thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .table thead th {
            border: none;
            padding: 16px 12px;
            font-weight: 600;
            font-size: 0.95rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            white-space: nowrap;
        }

        .table tbody td {
            padding: 14px 12px;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
        }

        .table tbody tr {
            transition: all 0.2s;
        }

        .table tbody tr:hover {
            background-color: #f8fafc;
            transform: scale(1.01);
        }

        .employee-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .employee-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #e2e8f0;
        }

        .employee-details h6 {
            margin: 0;
            font-size: 0.95rem;
            font-weight: 600;
            color: #1e293b;
        }

        .employee-details p {
            margin: 0;
            font-size: 0.85rem;
            color: #64748b;
        }

        .badge {
            padding: 6px 12px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.85rem;
        }

        .badge-primary {
            background: var(--primary-gradient);
            color: white;
        }

        .badge-success {
            background: var(--success-gradient);
            color: white;
        }

        .badge-danger {
            background: var(--danger-gradient);
            color: white;
        }

        .badge-info {
            background: var(--info-gradient);
            color: white;
        }

        .leave-detail {
            font-weight: 600;
            font-size: 1rem;
        }

        .leave-detail.positive {
            color: #10b981;
        }

        .leave-detail.negative {
            color: #ef4444;
        }

        .leave-detail.neutral {
            color: #64748b;
        }

        .year-selector {
            display: flex;
            align-items: center;
            gap: 10px;
            background: white;
            padding: 8px 16px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .year-selector label {
            margin: 0;
            font-weight: 600;
            color: #1e293b;
        }

        /* ===== RESPONSIVE ===== */
        /* ===== RESPONSIVE TABLE FIX ===== */
        @media (max-width: 1200px) {
            .hide-on-1200 { display: none !important; }
        }
        
        @media (max-width: 768px) {
            .stat-card .stat-value { font-size: 1.8rem; }
            .stat-card .stat-icon { font-size: 2rem; }
            .table thead th { font-size: 0.85rem; padding: 12px 8px; }
            .table tbody td { padding: 10px 8px; font-size: 0.9rem; }
            .hide-on-tablet { display: none !important; }
        }
        
        @media (max-width: 576px) {
            .hide-on-mobile { display: none !important; }
        }
    </style>
</head>

<body>
    <!-- Sidebar -->
    <jsp:include page="sidebar.jsp" />
    
    <!-- Header -->
    <jsp:include page="header.jsp" />

    <!-- Main Content -->
    <div class="main-content">
        <!-- Page Header -->
        <div class="page-header">
            <h2>
                <i class="fas fa-chart-bar"></i>
                Thống kê ngày phép nhân viên - Năm <%= nam %>
            </h2>
        </div>

        <!-- Statistics Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="stat-card total">
                    <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                    <h3 class="stat-value"><%= df.format(tongPhepCapPhat) %></h3>
                    <p class="stat-label">Tổng phép cấp phát</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card used">
                    <div class="stat-icon"><i class="fas fa-calendar-times"></i></div>
                    <h3 class="stat-value"><%= df.format(tongPhepDaDung) %></h3>
                    <p class="stat-label">Tổng phép đã dùng</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card remaining">
                    <div class="stat-icon"><i class="fas fa-calendar-plus"></i></div>
                    <h3 class="stat-value"><%= df.format(tongPhepConLai) %></h3>
                    <p class="stat-label">Tổng phép còn lại</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card previous">
                    <div class="stat-icon"><i class="fas fa-history"></i></div>
                    <h3 class="stat-value"><%= df.format(tongPhepNamTruoc) %></h3>
                    <p class="stat-label">Phép năm <%= (nam - 1) %> chuyển sang</p>
                </div>
            </div>
        </div>

        <!-- Main Table Box -->
        <div class="main-box">
            <div class="box-title">
                <i class="fas fa-table"></i>
                Chi tiết ngày phép từng nhân viên (<%= soLuongNhanVien %> người)
            </div>

            <!-- Year Filter -->
            <div class="filter-section">
                <div class="year-selector">
                    <label for="yearSelect"><i class="fas fa-calendar-alt"></i> Năm:</label>
                    <select id="yearSelect" class="form-select form-select-sm" style="width: auto;">
                        <% 
                        int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                        for (int y = currentYear + 1; y >= currentYear - 5; y--) { 
                        %>
                            <option value="<%= y %>" <%= (y == nam) ? "selected" : "" %>><%= y %></option>
                        <% } %>
                    </select>
                </div>
                <div class="ms-auto">
                    <span class="badge badge-primary"><i class="fas fa-users"></i> <%= soLuongNhanVien %> nhân viên</span>
                </div>
            </div>

            <!-- Table -->
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Nhân viên</th>
                            <th>Phòng ban</th>
                            <th class="hide-on-tablet">Ngày vào làm</th>
                            <th class="text-center">Tổng phép <%= nam %></th>
                            <th class="text-center hide-on-1200">Đã dùng</th>
                            <th class="text-center">Phép <%= nam %></th>
                            <th class="text-center">Còn lại <%= (nam - 1) %></th>
                            <th class="text-center">Tổng còn</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        if (dsNhanVienPhep != null && !dsNhanVienPhep.isEmpty()) {
                            int stt = 1;
                            for (Map<String, Object> nv : dsNhanVienPhep) {
                                String avatarUrl = (String) nv.get("avatar_url");
                                if (avatarUrl == null || avatarUrl.trim().isEmpty()) {
                                    avatarUrl = "Img/default-avatar.png";
                                }
                                
                                double tongPhep = ((Number) nv.getOrDefault("tong_ngay_phep", 0)).doubleValue();
                                double daDung = ((Number) nv.getOrDefault("ngay_phep_da_dung", 0)).doubleValue();
                                double conLai = ((Number) nv.getOrDefault("ngay_phep_con_lai", 0)).doubleValue();
                                double namTruoc = ((Number) nv.getOrDefault("ngay_phep_nam_truoc", 0)).doubleValue();
                                double tongCon = conLai + namTruoc;
                        %>
                        <tr>
                            <td><%= stt++ %></td>
                            <td>
                                <div class="employee-info">
                                    <img src="<%= avatarUrl %>" alt="Avatar" class="employee-avatar" onerror="this.src='Img/default-avatar.png'">
                                    <div class="employee-details">
                                        <h6><%= nv.get("ho_ten") %></h6>
                                        <p><%= nv.get("email") %></p>
                                    </div>
                                </div>
                            </td>
                            <td><%= nv.get("ten_phong_ban") != null ? nv.get("ten_phong_ban") : "Chưa có" %></td>
                            <td class="hide-on-tablet">
                                <%
                                    Object ngayVaoLamObj = nv.get("ngay_vao_lam");
                                    if (ngayVaoLamObj != null) {
                                        if (ngayVaoLamObj instanceof java.sql.Date) {
                                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                                            out.print(sdf.format((java.sql.Date) ngayVaoLamObj));
                                        } else {
                                            out.print(ngayVaoLamObj.toString());
                                        }
                                    } else {
                                        out.print("-");
                                    }
                                %>
                            </td>
                            <td class="text-center">
                                <span class="badge badge-primary"><%= df.format(tongPhep) %> ngày</span>
                            </td>
                            <td class="text-center hide-on-1200">
                                <span class="leave-detail <%= (daDung > 0) ? "negative" : "neutral" %>">
                                    <%= df.format(daDung) %> ngày
                                </span>
                            </td>
                            <td class="text-center">
                                <span class="leave-detail <%= (conLai > 0) ? "positive" : "neutral" %>">
                                    <%= df.format(conLai) %> ngày
                                </span>
                            </td>
                            <td class="text-center">
                                <% if (namTruoc > 0) { %>
                                    <span class="badge badge-info"><%= df.format(namTruoc) %> ngày</span>
                                <% } else { %>
                                    <span class="text-muted">0 ngày</span>
                                <% } %>
                            </td>
                            <td class="text-center">
                                <span class="badge badge-success" style="font-size: 1rem;">
                                    <strong><%= df.format(tongCon) %> ngày</strong>
                                </span>
                            </td>
                        </tr>
                        <% 
                            }
                        } else { 
                        %>
                        <tr>
                            <td colspan="9" class="text-center py-4">
                                <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                <p class="text-muted">Không có dữ liệu nhân viên</p>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function() {
            // Year filter change
            $('#yearSelect').on('change', function() {
                const year = $(this).val();
                window.location.href = 'adminLeaveStats?nam=' + year;
            });
        });
    </script>
</body>
</html>
