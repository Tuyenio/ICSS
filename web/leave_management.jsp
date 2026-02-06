<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Lấy dữ liệu từ servlet
    List<Map<String, Object>> dsDonNghiPhep = (List<Map<String, Object>>) request.getAttribute("dsDonNghiPhep");
    Map<String, Integer> thongKe = (Map<String, Integer>) request.getAttribute("thongKe");
    List<Map<String, Object>> dsNhanVien = (List<Map<String, Object>>) request.getAttribute("dsNhanVien");
    String trangThaiFilter = (String) request.getAttribute("trangThaiFilter");
    Integer thangFilter = (Integer) request.getAttribute("thangFilter");
    Integer namFilter = (Integer) request.getAttribute("namFilter");
    String emailSession = (String) session.getAttribute("userEmail");
    String vaiTro = (String) session.getAttribute("vaiTro");
    
    // Set default values
    if (dsDonNghiPhep == null) dsDonNghiPhep = new ArrayList<>();
    if (thongKe == null) thongKe = new HashMap<>();
    if (dsNhanVien == null) dsNhanVien = new ArrayList<>();
    if (namFilter == null) namFilter = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
    
    int choDuyet = thongKe.getOrDefault("cho_duyet", 0);
    int daDuyet = thongKe.getOrDefault("da_duyet", 0);
    int tuChoi = thongKe.getOrDefault("tu_choi", 0);
    int tongDon = choDuyet + daDuyet + tuChoi;
%>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/png" href="Img/logoics.png">
    <title>Quản lý nghỉ phép - ICSS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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
        }

        .stat-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 15px 45px rgba(0, 0, 0, 0.2);
        }

        .stat-card.total { background: var(--primary-gradient); }
        .stat-card.pending { background: var(--warning-gradient); }
        .stat-card.approved { background: var(--success-gradient); }
        .stat-card.rejected { background: var(--danger-gradient); }

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
            font-size: 1.4rem;
        }

        /* ===== FILTER ROW ===== */
        .filter-row {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 25px;
        }

        .filter-row .form-select, .filter-row .form-control {
            border-radius: 10px;
            border: 2px solid #e2e8f0;
            padding: 10px 15px;
        }

        .filter-row .form-select:focus, .filter-row .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.15);
        }

        /* ===== TABLE STYLES ===== */
        .table-modern {
            border-collapse: separate;
            border-spacing: 0;
        }

        .table-modern thead th {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border: none;
            padding: 16px 12px;
            font-weight: 600;
            color: #475569;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .table-modern tbody td {
            padding: 16px 12px;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
        }

        .table-modern tbody tr {
            transition: all 0.2s ease;
        }

        .table-modern tbody tr:hover {
            background: linear-gradient(135deg, #f8fafc 0%, #fff 100%);
        }

        /* ===== AVATAR ===== */
        .avatar-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #e2e8f0;
        }

        .employee-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .employee-info .info {
            line-height: 1.3;
        }

        .employee-info .name {
            font-weight: 600;
            color: #1e293b;
        }

        .employee-info .dept {
            font-size: 0.85rem;
            color: #64748b;
        }

        /* ===== STATUS BADGES ===== */
        .badge-status {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.85rem;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .badge-status.pending {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            color: #92400e;
        }

        .badge-status.approved {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            color: #065f46;
        }

        .badge-status.rejected {
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
            color: #991b1b;
        }

        /* ===== LEAVE TYPE BADGE ===== */
        .leave-type-badge {
            padding: 6px 14px;
            border-radius: 8px;
            font-weight: 500;
            font-size: 0.85rem;
        }

        .leave-type-badge.annual { background: #dbeafe; color: #1e40af; }
        .leave-type-badge.sick { background: #fce7f3; color: #9d174d; }
        .leave-type-badge.unpaid { background: #f3f4f6; color: #374151; }
        .leave-type-badge.maternity { background: #ede9fe; color: #5b21b6; }
        .leave-type-badge.personal { background: #fef3c7; color: #92400e; }

        /* ===== ACTION BUTTONS ===== */
        .btn-action {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: none;
            transition: all 0.3s ease;
            margin: 2px;
        }

        .btn-action.approve {
            background: #d1fae5;
            color: #065f46;
        }

        .btn-action.approve:hover {
            background: #10b981;
            color: white;
            transform: scale(1.1);
        }

        .btn-action.reject {
            background: #fee2e2;
            color: #991b1b;
        }

        .btn-action.reject:hover {
            background: #ef4444;
            color: white;
            transform: scale(1.1);
        }

        .btn-action.view {
            background: #dbeafe;
            color: #1e40af;
        }

        .btn-action.view:hover {
            background: #3b82f6;
            color: white;
            transform: scale(1.1);
        }

        /* ===== MODAL STYLES ===== */
        .modal-content {
            border-radius: 20px;
            border: none;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.2);
        }

        .modal-header {
            background: var(--primary-gradient);
            color: white;
            border-radius: 20px 20px 0 0;
            padding: 20px 25px;
        }

        .modal-header .btn-close {
            filter: brightness(0) invert(1);
        }

        .modal-body {
            padding: 25px;
        }

        .modal-footer {
            padding: 15px 25px 25px;
            border: none;
        }

        /* ===== FORM STYLES ===== */
        .form-label {
            font-weight: 600;
            color: #475569;
            margin-bottom: 8px;
        }

        .form-control, .form-select {
            border-radius: 12px;
            border: 2px solid #e2e8f0;
            padding: 12px 16px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-control:focus, .form-select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
        }

        /* ===== BUTTONS ===== */
        .btn-primary-gradient {
            background: var(--primary-gradient);
            border: none;
            color: white;
            padding: 12px 28px;
            border-radius: 12px;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-primary-gradient:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.5);
            color: white;
        }

        .btn-success-gradient {
            background: var(--success-gradient);
            border: none;
            color: white;
        }

        .btn-danger-gradient {
            background: var(--danger-gradient);
            border: none;
            color: white;
        }

        /* ===== EMPTY STATE ===== */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #94a3b8;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        /* ===== ANIMATIONS ===== */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .animate-fadeInUp {
            animation: fadeInUp 0.5s ease forwards;
        }

        .delay-1 { animation-delay: 0.1s; }
        .delay-2 { animation-delay: 0.2s; }
        .delay-3 { animation-delay: 0.3s; }
        .delay-4 { animation-delay: 0.4s; }

        /* ===== COLLAPSE BUTTON STYLES ===== */
        .btn-link {
            transition: all 0.3s ease;
        }

        .btn-link:hover {
            transform: none !important;
            color: inherit !important;
        }

        .btn-link .fa-chevron-down {
            transition: transform 0.3s ease;
        }

        .btn-link[aria-expanded="true"] .fa-chevron-down {
            transform: rotate(-180deg);
        }

        .collapse {
            transition: all 0.3s ease;
        }

        /* ===== TRANSITION TRANSFORM ===== */
        .transition-transform {
            transition: transform 0.3s ease;
        }
    </style>
</head>

<body>
    <%@ include file="sidebar.jsp" %>
    <%@ include file="header.jsp" %>

    <div class="main-content">
        <!-- Page Header -->
        <div class="page-header animate-fadeInUp">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h2><i class="fa-solid fa-calendar-xmark me-3"></i>Quản lý nghỉ phép</h2>
                    <p class="mb-0 mt-2 opacity-75">
                        <i class="fa-regular fa-clock me-2"></i>Duyệt và quản lý đơn xin nghỉ phép của nhân viên
                    </p>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3 col-sm-6">
                <div class="stat-card total animate-fadeInUp delay-1" onclick="filterByStatus('all')">
                    <div class="stat-icon"><i class="fa-solid fa-file-alt"></i></div>
                    <div class="stat-value"><%= tongDon %></div>
                    <div class="stat-label">Tổng số đơn</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-card pending animate-fadeInUp delay-2" onclick="filterByStatus('cho_duyet')">
                    <div class="stat-icon"><i class="fa-solid fa-hourglass-half"></i></div>
                    <div class="stat-value"><%= choDuyet %></div>
                    <div class="stat-label">Chờ duyệt</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-card approved animate-fadeInUp delay-3" onclick="filterByStatus('da_duyet')">
                    <div class="stat-icon"><i class="fa-solid fa-circle-check"></i></div>
                    <div class="stat-value"><%= daDuyet %></div>
                    <div class="stat-label">Đã duyệt</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-card rejected animate-fadeInUp delay-4" onclick="filterByStatus('tu_choi')">
                    <div class="stat-icon"><i class="fa-solid fa-circle-xmark"></i></div>
                    <div class="stat-value"><%= tuChoi %></div>
                    <div class="stat-label">Từ chối</div>
                </div>
            </div>
        </div>

        <!-- Add New Leave Button -->
        <% if ("Admin".equals(vaiTro) || "Quản lý".equals(vaiTro)) { %>
        <div class="mb-3">
            <button type="button" class="btn" onclick="openModalThemMoi()" style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 14px;">
                <i class="fa-solid fa-plus me-2"></i>Thêm mới đơn
            </button>
        </div>
        <% } %>

        <!-- Filter & Table -->
        <div class="main-box animate-fadeInUp">
            <div class="box-title">
                <i class="fa-solid fa-list-check"></i>
                Danh sách đơn nghỉ phép
            </div>
            
            <!-- Filter Row -->
            <div class="filter-row">
                <form method="GET" action="dsNghiPhep" class="row g-3 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label small">Trạng thái</label>
                        <select name="trangThai" class="form-select">
                            <option value="all" <%= "all".equals(trangThaiFilter) || trangThaiFilter == null ? "selected" : "" %>>Tất cả</option>
                            <option value="cho_duyet" <%= "cho_duyet".equals(trangThaiFilter) ? "selected" : "" %>>Chờ duyệt</option>
                            <option value="da_duyet" <%= "da_duyet".equals(trangThaiFilter) ? "selected" : "" %>>Đã duyệt</option>
                            <option value="tu_choi" <%= "tu_choi".equals(trangThaiFilter) ? "selected" : "" %>>Từ chối</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small">Tháng</label>
                        <select name="thang" class="form-select">
                            <option value="0">Tất cả</option>
                            <% for (int i = 1; i <= 12; i++) { %>
                                <option value="<%= i %>" <%= thangFilter != null && thangFilter == i ? "selected" : "" %>>Tháng <%= i %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small">Năm</label>
                        <select name="nam" class="form-select">
                            <% int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                               for (int y = currentYear - 2; y <= currentYear + 1; y++) { %>
                                <option value="<%= y %>" <%= namFilter == y ? "selected" : "" %>><%= y %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small">Tìm kiếm</label>
                        <input type="text" class="form-control" id="searchInput" placeholder="Tìm theo tên nhân viên...">
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary-gradient w-100">
                            <i class="fa-solid fa-filter me-2"></i>Lọc
                        </button>
                    </div>
                </form>
            </div>

            <!-- Table -->
            <% if (dsDonNghiPhep.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fa-solid fa-inbox"></i>
                    <h5>Không có đơn nghỉ phép nào</h5>
                    <p>Chưa có đơn xin nghỉ phép nào trong hệ thống</p>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table table-modern" id="tableNghiPhep">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Nhân viên</th>
                                <th>Loại phép</th>
                                <th>Thời gian nghỉ</th>
                                <th>Số ngày</th>
                                <th>Lý do</th>
                                <th>Trạng thái</th>
                                <th>Ngày tạo</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            int stt = 1;
                            for (Map<String, Object> don : dsDonNghiPhep) { 
                                String trangThai = (String) don.get("trang_thai");
                                String loaiPhep = (String) don.get("loai_phep");
                                String lyDo = (String) don.get("ly_do");
                                String tenNV = (String) don.get("ten_nhan_vien");
                                String tenPB = (String) don.get("ten_phong_ban");
                                String avatarUrl = (String) don.get("avatar_url");
                                
                                if (avatarUrl == null || avatarUrl.isEmpty()) {
                                    avatarUrl = "Img/default-avatar.png";
                                }
                                
                                // Badge class cho loại phép
                                String leaveClass = "personal";
                                if ("Phép năm".equals(loaiPhep)) leaveClass = "annual";
                                else if ("Nghỉ khám nghĩa vụ quân sự".equals(loaiPhep)) leaveClass = "military";
                                else if ("Nghỉ không lương".equals(loaiPhep)) leaveClass = "unpaid";
                                else if ("Nghỉ thai sản".equals(loaiPhep)) leaveClass = "maternity";
                                
                                // Badge class cho trạng thái
                                String statusClass = "pending";
                                String statusText = "Chờ duyệt";
                                String statusIcon = "fa-hourglass-half";
                                if ("da_duyet".equals(trangThai)) {
                                    statusClass = "approved";
                                    statusText = "Đã duyệt";
                                    statusIcon = "fa-circle-check";
                                } else if ("tu_choi".equals(trangThai)) {
                                    statusClass = "rejected";
                                    statusText = "Từ chối";
                                    statusIcon = "fa-circle-xmark";
                                }
                            %>
                            <tr data-name="<%= tenNV != null ? tenNV.toLowerCase() : "" %>">
                                <td><strong><%= stt++ %></strong></td>
                                <td>
                                    <div class="employee-info">
                                        <img src="<%= avatarUrl %>" alt="Avatar" class="avatar-circle">
                                        <div class="info">
                                            <div class="name"><%= tenNV %></div>
                                            <div class="dept"><%= tenPB != null ? tenPB : "Chưa xác định" %></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="leave-type-badge <%= leaveClass %>"><%= loaiPhep %></span>
                                </td>
                                <td>
                                    <i class="fa-regular fa-calendar text-primary me-1"></i>
                                    <%
                                        java.sql.Date ngayBatDau = (java.sql.Date) don.get("ngay_bat_dau");
                                        java.sql.Date ngayKetThuc = (java.sql.Date) don.get("ngay_ket_thuc");
                                        String ngayBD = (ngayBatDau != null) ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(ngayBatDau) : "";
                                        String ngayKT = (ngayKetThuc != null) ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(ngayKetThuc) : "";
                                    %>
                                    <small><%= ngayBD %></small>
                                    <span class="text-muted mx-1">→</span>
                                    <small><%= ngayKT %></small>
                                </td>
                                <td>
                                    <span class="badge bg-primary rounded-pill px-3 py-2">
                                        <%= don.get("so_ngay") %> ngày
                                    </span>
                                </td>
                                <td style="max-width: 180px;">
                                    <span class="text-truncate d-inline-block" style="max-width: 160px;" 
                                          title="<%= lyDo %>"><%= lyDo %></span>
                                </td>
                                <td>
                                    <span class="badge-status <%= statusClass %>">
                                        <i class="fa-solid <%= statusIcon %>"></i>
                                        <%= statusText %>
                                    </span>
                                </td>
                                <td>
                                    <small class="text-muted">
                                        <%
                                            java.sql.Timestamp thoiGianTao = (java.sql.Timestamp) don.get("thoi_gian_tao");
                                            String tgtStr = (thoiGianTao != null) ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(thoiGianTao) : "";
                                        %>
                                        <%= tgtStr %>
                                    </small>
                                </td>
                                <td>
                                    <button class="btn-action view" onclick="xemChiTiet('<%= don.get("id") %>')" 
                                            title="Xem chi tiết">
                                        <i class="fa-solid fa-eye"></i>
                                    </button>
                                    <% if ("cho_duyet".equals(trangThai)) { %>
                                        <button class="btn-action approve" onclick="duyetDon('<%= don.get("id") %>')" 
                                                title="Duyệt đơn">
                                            <i class="fa-solid fa-check"></i>
                                        </button>
                                        <button class="btn-action reject" onclick="tuChoiDon('<%= don.get("id") %>')" 
                                                title="Từ chối">
                                            <i class="fa-solid fa-xmark"></i>
                                        </button>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>

    <!-- Modal xem chi tiết -->
    <div class="modal fade" id="modalChiTiet" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-file-lines me-2"></i>Chi tiết đơn nghỉ phép</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="chiTietDonContent">
                    <!-- Content loaded via AJAX -->
                </div>
                <div class="modal-footer" id="chiTietDonFooter">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal từ chối -->
    <div class="modal fade" id="modalTuChoi" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header" style="background: var(--danger-gradient);">
                    <h5 class="modal-title"><i class="fa-solid fa-ban me-2"></i>Từ chối đơn nghỉ phép</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="tuChoiDonId">
                    <div class="mb-3">
                        <label class="form-label">
                            <i class="fa-solid fa-comment-dots me-2"></i>Lý do từ chối <span class="text-danger">*</span>
                        </label>
                        <textarea class="form-control" id="lyDoTuChoi" rows="4" 
                                  placeholder="Nhập lý do từ chối đơn này..." required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-danger" onclick="xacNhanTuChoi()">
                        <i class="fa-solid fa-ban me-2"></i>Xác nhận từ chối
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal tạo đơn cho nhân viên -->
    <div class="modal fade" id="modalTaoDonHo" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fa-solid fa-file-signature me-2"></i>Tạo đơn nghỉ phép cho nhân viên</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="formTaoDonHo">
                        <div class="row g-4">
                            <div class="col-md-6">
                                <label class="form-label">
                                    <i class="fa-solid fa-user me-2"></i>Chọn nhân viên <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" name="nhanVienId" required>
                                    <option value="">-- Chọn nhân viên --</option>
                                    <% for (Map<String, Object> nv : dsNhanVien) { %>
                                        <option value="<%= nv.get("id") %>"><%= nv.get("ho_ten") %> - <%= nv.get("ten_phong_ban") %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">
                                    <i class="fa-solid fa-tags me-2"></i>Loại nghỉ phép <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" name="loaiPhep" required>
                                    <option value="Phép năm" selected>🌴 Phép năm</option>
                                    <option value="Nghỉ khám nghĩa vụ quân sự">⚔️ Nghỉ khám nghĩa vụ quân sự</option>
                                    <option value="Nghỉ không lương">💰 Nghỉ không lương</option>
                                    <option value="Nghỉ thai sản">👶 Nghỉ thai sản</option>
                                    <option value="Việc riêng">🏠 Việc riêng</option>
                                    <option value="Khác">📋 Khác</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">
                                    <i class="fa-solid fa-calendar-day me-2"></i>Từ ngày <span class="text-danger">*</span>
                                </label>
                                <input type="date" class="form-control" name="ngayBatDau" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">
                                    <i class="fa-solid fa-calendar-week me-2"></i>Đến ngày <span class="text-danger">*</span>
                                </label>
                                <input type="date" class="form-control" name="ngayKetThuc" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">
                                    <i class="fa-solid fa-hashtag me-2"></i>Số ngày <span class="text-danger">*</span>
                                </label>
                                <input type="number" class="form-control" name="soNgay" step="0.5" min="0.5" required>
                            </div>
                            <div class="col-12">
                                <label class="form-label">
                                    <i class="fa-solid fa-comment-dots me-2"></i>Lý do <span class="text-danger">*</span>
                                </label>
                                <textarea class="form-control" name="lyDo" rows="3" 
                                          placeholder="Nhập lý do xin nghỉ phép..." required></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label">
                                    <i class="fa-solid fa-sticky-note me-2"></i>Ghi chú
                                </label>
                                <input type="text" class="form-control" name="ghiChu" placeholder="Ghi chú thêm...">
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary-gradient" onclick="submitTaoDonHo()">
                        <i class="fa-solid fa-paper-plane me-2"></i>Tạo đơn
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Search filter
        document.getElementById('searchInput').addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const rows = document.querySelectorAll('#tableNghiPhep tbody tr');
            
            rows.forEach(row => {
                const name = row.getAttribute('data-name') || '';
                if (name.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });

        // Filter by status
        function filterByStatus(status) {
            window.location.href = 'dsNghiPhep?trangThai=' + status;
        }

        // Xem chi tiết
        function xemChiTiet(donId) {
            donId = parseInt(donId);
            fetch('apiNghiPhep?action=getDonById&id=' + donId)
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        const don = data.data;
                        let statusBadge = '';
                        if (don.trang_thai === 'cho_duyet') {
                            statusBadge = '<span class="badge-status pending"><i class="fa-solid fa-hourglass-half"></i> Chờ duyệt</span>';
                        } else if (don.trang_thai === 'da_duyet') {
                            statusBadge = '<span class="badge-status approved"><i class="fa-solid fa-circle-check"></i> Đã duyệt</span>';
                        } else if (don.trang_thai === 'tu_choi') {
                            statusBadge = '<span class="badge-status rejected"><i class="fa-solid fa-circle-xmark"></i> Từ chối</span>';
                        } else {
                            statusBadge = '<span class="badge-status pending"><i class="fa-solid fa-question"></i> ' + don.trang_thai + '</span>';
                        }
                        
                        // Format dates
                        const formatDate = (dateStr) => {
                            if (!dateStr) return 'N/A';
                            const date = new Date(dateStr);
                            return date.toLocaleDateString('vi-VN', { year: 'numeric', month: '2-digit', day: '2-digit' });
                        };
                        
                        const formatDateTime = (dateStr) => {
                            if (!dateStr) return 'N/A';
                            const date = new Date(dateStr);
                            return date.toLocaleDateString('vi-VN', { year: 'numeric', month: '2-digit', day: '2-digit' }) + 
                                   ' - ' + date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
                        };
                        
                        // Phần lý do từ chối
                        let lyDoTuChoiHtml = '';
                        if (don.ly_do_tu_choi) {
                            lyDoTuChoiHtml = `
                                <div class="col-12 mt-2">
                                    <div class="p-3 bg-danger bg-opacity-10 rounded border border-danger border-opacity-25">
                                        <p class="mb-0"><strong><i class="fa-solid fa-exclamation-triangle me-2 text-danger"></i>Lý do từ chối:</strong></p>
                                        <p class="mb-0 text-danger mt-2">\${don.ly_do_tu_choi}</p>
                                    </div>
                                </div>
                            `;
                        }
                        
                        // Phần người duyệt và ngày duyệt
                        let thongTinDuyetHtml = '';
                        if ((don.trang_thai === 'da_duyet' || don.trang_thai === 'tu_choi') && don.ten_nguoi_duyet) {
                            const trangThaiDuyet = don.trang_thai === 'da_duyet' ? 'primary' : 'danger';
                            const textAction = don.trang_thai === 'da_duyet' ? 'duyệt' : 'từ chối';
                            thongTinDuyetHtml = `
                                <div class="col-12 mt-2">
                                    <div class="p-3 bg-\${trangThaiDuyet} bg-opacity-10 rounded border border-\${trangThaiDuyet} border-opacity-25">
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <p class="mb-0"><strong><i class="fa-solid fa-user-check me-2 text-\${trangThaiDuyet}"></i>Người \${textAction}:</strong></p>
                                                <p class="mb-0 mt-2"><span class="badge bg-\${trangThaiDuyet}">\${don.ten_nguoi_duyet}</span></p>
                                            </div>
                                            <div class="col-md-6">
                                                <p class="mb-0"><strong><i class="fa-solid fa-calendar-check me-2 text-\${trangThaiDuyet}"></i>Ngày \${textAction}:</strong></p>
                                                <p class="mb-0 mt-2"><i class="fa-regular fa-clock me-2"></i>\${formatDateTime(don.thoi_gian_duyet)}</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            `;
                        }
                        
                        document.getElementById('chiTietDonContent').innerHTML = `
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <p><strong><i class="fa-solid fa-user me-2 text-primary"></i>Nhân viên:</strong></p>
                                    <div class="p-2 bg-light rounded">\${don.ten_nhan_vien || 'N/A'}</div>
                                </div>
                                <div class="col-md-6">
                                    <p><strong><i class="fa-solid fa-building me-2 text-primary"></i>Phòng ban:</strong></p>
                                    <div class="p-2 bg-light rounded">\${don.ten_phong_ban || 'Chưa xác định'}</div>
                                </div>
                                <div class="col-md-6">
                                    <p><strong><i class="fa-solid fa-tags me-2 text-primary"></i>Loại phép:</strong></p>
                                    <div class="p-2 bg-light rounded">\${don.loai_phep || 'N/A'}</div>
                                </div>
                                <div class="col-md-6">
                                    <p><strong><i class="fa-solid fa-info-circle me-2 text-primary"></i>Trạng thái:</strong></p>
                                    <div>\${statusBadge}</div>
                                </div>
                                <div class="col-12 mt-3">
                                    <p><strong><i class="fa-regular fa-calendar me-2 text-primary"></i>Thời gian nghỉ:</strong></p>
                                    <div class="p-3 bg-light rounded">
                                        <i class="fa-solid fa-calendar-days me-2 text-primary"></i>
                                        Từ <strong>\${formatDate(don.ngay_bat_dau)}</strong> đến <strong>\${formatDate(don.ngay_ket_thuc)}</strong>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <p><strong><i class="fa-solid fa-hashtag me-2 text-primary"></i>Số ngày:</strong></p>
                                    <span class="badge bg-primary px-3 py-2" style="font-size: 1rem;">\${don.so_ngay} ngày</span>
                                </div>
                                <div class="col-md-6">
                                    <p><strong><i class="fa-solid fa-calendar-plus me-2 text-primary"></i>Ngày tạo đơn:</strong></p>
                                    <div class="p-2 bg-light rounded">
                                        <small><i class="fa-regular fa-clock me-2"></i>\${formatDateTime(don.thoi_gian_tao)}</small>
                                    </div>
                                </div>
                                <div class="col-12">
                                    <p><strong><i class="fa-solid fa-comment me-2 text-primary"></i>Lý do:</strong></p>
                                    <div class="p-3 bg-light rounded">\${don.ly_do || 'Không có'}</div>
                                </div>
                                \${lyDoTuChoiHtml}
                                \${thongTinDuyetHtml}
                            </div>
                        `;
                        
                        // Show/hide action buttons based on status
                        let footer = '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>';
                        if (don.trang_thai === 'cho_duyet') {
                            footer = `
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                <button type="button" class="btn btn-danger" onclick="tuChoiDon(${don.id})" data-bs-dismiss="modal">
                                    <i class="fa-solid fa-ban me-2"></i>Từ chối
                                </button>
                                <button type="button" class="btn btn-success" onclick="duyetDon(${don.id})" data-bs-dismiss="modal">
                                    <i class="fa-solid fa-check me-2"></i>Duyệt đơn
                                </button>
                            `;
                        }
                        document.getElementById('chiTietDonFooter').innerHTML = footer;
                        
                        new bootstrap.Modal(document.getElementById('modalChiTiet')).show();
                    }
                });
        }

        // Duyệt đơn
        function duyetDon(donId) {
            donId = parseInt(donId);
            Swal.fire({
                title: 'Xác nhận duyệt đơn?',
                text: 'Bạn có chắc muốn duyệt đơn nghỉ phép này?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#10b981',
                cancelButtonColor: '#94a3b8',
                confirmButtonText: 'Duyệt đơn',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    const formData = new FormData();
                    formData.append('action', 'duyetDon');
                    formData.append('donId', donId);
                    
                    fetch('apiNghiPhep', {
                        method: 'POST',
                        body: new URLSearchParams(formData)
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            Swal.fire({
                                icon: 'success',
                                title: 'Thành công!',
                                text: data.message,
                                confirmButtonColor: '#667eea'
                            }).then(() => {
                                location.reload();
                            });
                        } else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Lỗi!',
                                text: data.message,
                                confirmButtonColor: '#667eea'
                            });
                        }
                    });
                }
            });
        }

        // Từ chối đơn - mở modal
        function tuChoiDon(donId) {
            donId = parseInt(donId);
            document.getElementById('tuChoiDonId').value = donId;
            document.getElementById('lyDoTuChoi').value = '';
            new bootstrap.Modal(document.getElementById('modalTuChoi')).show();
        }

        // Xác nhận từ chối
        function xacNhanTuChoi() {
            const donId = document.getElementById('tuChoiDonId').value;
            const lyDo = document.getElementById('lyDoTuChoi').value;
            
            if (!lyDo.trim()) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Thiếu thông tin!',
                    text: 'Vui lòng nhập lý do từ chối',
                    confirmButtonColor: '#667eea'
                });
                return;
            }
            
            const formData = new FormData();
            formData.append('action', 'tuChoiDon');
            formData.append('donId', donId);
            formData.append('lyDoTuChoi', lyDo);
            
            fetch('apiNghiPhep', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(res => res.json())
            .then(data => {
                bootstrap.Modal.getInstance(document.getElementById('modalTuChoi')).hide();
                if (data.success) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Đã từ chối!',
                        text: data.message,
                        confirmButtonColor: '#667eea'
                    }).then(() => {
                        location.reload();
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Lỗi!',
                        text: data.message,
                        confirmButtonColor: '#667eea'
                    });
                }
            });
        }

        // Tạo đơn cho nhân viên
        function submitTaoDonHo() {
            const form = document.getElementById('formTaoDonHo');
            const formData = new FormData(form);
            formData.append('action', 'taoDon');
            
            // Validate
            if (!formData.get('nhanVienId') || !formData.get('loaiPhep') || 
                !formData.get('ngayBatDau') || !formData.get('ngayKetThuc') || 
                !formData.get('soNgay') || !formData.get('lyDo')) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Thiếu thông tin!',
                    text: 'Vui lòng điền đầy đủ các trường bắt buộc',
                    confirmButtonColor: '#667eea'
                });
                return;
            }
            
            fetch('apiNghiPhep', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(res => res.json())
            .then(data => {
                bootstrap.Modal.getInstance(document.getElementById('modalTaoDonHo')).hide();
                if (data.success) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Thành công!',
                        text: data.message,
                        confirmButtonColor: '#667eea'
                    }).then(() => {
                        location.reload();
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Lỗi!',
                        text: data.message,
                        confirmButtonColor: '#667eea'
                    });
                }
            });
        }

        /**
         * Mở modal thêm mới đơn nghỉ phép (Admin/Quản lý)
         */
        function openModalThemMoi() {
            // Reset form
            document.getElementById('formThemMoi').reset();
            
            // Mở modal
            let modal = new bootstrap.Modal(document.getElementById('modalThemMoi'));
            modal.show();
        }

        /**
         * Submit form thêm mới đơn
         */
        function submitThemMoiDon() {
            let nhanVienId = document.getElementById('selectNhanVien').value;
            let loaiPhep = document.getElementById('selectLoaiPhep').value;
            let ngayBatDau = document.getElementById('inputNgayBatDau').value;
            let ngayKetThuc = document.getElementById('inputNgayKetThuc').value;
            let soNgay = document.getElementById('inputSoNgay').value;
            let lyDo = document.getElementById('inputLyDo').value;

            let formData = new FormData();
            formData.append('nhanVienId', nhanVienId);
            formData.append('loaiPhep', loaiPhep);
            formData.append('ngayBatDau', ngayBatDau);
            formData.append('ngayKetThuc', ngayKetThuc);
            formData.append('soNgay', soNgay);
            formData.append('lyDo', lyDo);
            formData.append('action', 'themNghiPhepMoi');

            // Validate
            if (!nhanVienId || !loaiPhep || !ngayBatDau || !ngayKetThuc || !soNgay || !lyDo) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Thiếu thông tin!',
                    text: 'Vui lòng điền đầy đủ các trường bắt buộc',
                    confirmButtonColor: '#667eea'
                });
                return;
            }

            // Gửi request
            fetch('apiNghiPhep', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(res => res.json())
            .then(data => {
                bootstrap.Modal.getInstance(document.getElementById('modalThemMoi')).hide();
                if (data.success) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Thành công!',
                        text: 'Thêm mới đơn nghỉ phép thành công',
                        confirmButtonColor: '#667eea'
                    }).then(() => {
                        location.reload();
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Lỗi!',
                        text: data.message,
                        confirmButtonColor: '#667eea'
                    });
                }
            })
            .catch(error => {
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi!',
                    text: 'Có lỗi xảy ra: ' + error,
                    confirmButtonColor: '#667eea'
                });
            });
        }

        /**
         * Tính tự động số ngày từ ngày bắt đầu và kết thúc
         */
        document.addEventListener('DOMContentLoaded', function() {
            const inputNgayBatDau = document.getElementById('inputNgayBatDau');
            const inputNgayKetThuc = document.getElementById('inputNgayKetThuc');
            const inputSoNgay = document.getElementById('inputSoNgay');

            if (inputNgayBatDau && inputNgayKetThuc && inputSoNgay) {
                [inputNgayBatDau, inputNgayKetThuc].forEach(elem => {
                    elem.addEventListener('change', function() {
                        const start = new Date(inputNgayBatDau.value);
                        const end = new Date(inputNgayKetThuc.value);
                        
                        if (start && end && start <= end) {
                            const diffTime = Math.abs(end - start);
                            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
                            inputSoNgay.value = diffDays;
                        }
                    });
                });
            }
        });
    </script>

    <!-- Modal Thêm Mới Đơn Nghỉ Phép -->
    <div class="modal fade" id="modalThemMoi" tabindex="-1" aria-labelledby="modalThemMoiLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-gradient text-white" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                    <h5 class="modal-title" id="modalThemMoiLabel">
                        <i class="fa-solid fa-plus-circle me-2"></i>Thêm mới đơn nghỉ phép
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="formThemMoi">
                        <!-- Chọn nhân viên -->
                        <div class="mb-3">
                            <label for="selectNhanVien" class="form-label fw-6">Chọn nhân viên <span class="text-danger">*</span></label>
                            <select id="selectNhanVien" class="form-select" required>
                                <option value="">-- Chọn nhân viên --</option>
                                <% for (Map<String, Object> nv : dsNhanVien) { %>
                                    <option value="<%= nv.get("id") %>">
                                        <%= nv.get("ho_ten") %> - <%= nv.get("ten_phong") %>
                                    </option>
                                <% } %>
                            </select>
                        </div>

                        <!-- Loại phép -->
                        <div class="mb-3">
                            <label for="selectLoaiPhep" class="form-label fw-6">Loại phép <span class="text-danger">*</span></label>
                            <select id="selectLoaiPhep" class="form-select" required>
                                <option value="">-- Chọn loại phép --</option>
                                <option value="Phép năm">Phép năm</option>
                                <option value="Phép không lương">Phép không lương</option>
                                <option value="Phép bệnh">Phép bệnh</option>
                                <option value="Phép lễ">Phép lễ</option>
                                <option value="Khác">Khác</option>
                            </select>
                        </div>

                        <!-- Ngày bắt đầu -->
                        <div class="mb-3">
                            <label for="inputNgayBatDau" class="form-label fw-6">Ngày bắt đầu <span class="text-danger">*</span></label>
                            <input type="date" id="inputNgayBatDau" class="form-control" required>
                        </div>

                        <!-- Ngày kết thúc -->
                        <div class="mb-3">
                            <label for="inputNgayKetThuc" class="form-label fw-6">Ngày kết thúc <span class="text-danger">*</span></label>
                            <input type="date" id="inputNgayKetThuc" class="form-control" required>
                        </div>

                        <!-- Số ngày -->
                        <div class="mb-3">
                            <label for="inputSoNgay" class="form-label fw-6">Số ngày <span class="text-danger">*</span></label>
                            <input type="number" id="inputSoNgay" class="form-control" placeholder="Tự động tính" step="0.5" required>
                            <small class="form-text text-muted">Sẽ tự động tính dựa trên ngày bắt đầu và kết thúc</small>
                        </div>

                        <!-- Lý do -->
                        <div class="mb-3">
                            <label for="inputLyDo" class="form-label fw-6">Lý do <span class="text-danger">*</span></label>
                            <textarea id="inputLyDo" class="form-control" rows="3" placeholder="Nhập lý do yêu cầu cấp phép..." required></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-success" onclick="submitThemMoiDon()">
                        <i class="fa-solid fa-save me-2"></i>Thêm mới
                    </button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
