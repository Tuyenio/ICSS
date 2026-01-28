<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Lấy dữ liệu từ servlet
    Map<String, Object> nhanVienInfo = (Map<String, Object>) request.getAttribute("nhanVienInfo");
    List<Map<String, Object>> dsDonNghiPhep = (List<Map<String, Object>>) request.getAttribute("dsDonNghiPhep");
    Map<String, Object> ngayPhep = (Map<String, Object>) request.getAttribute("ngayPhep");
    Integer namHienTai = (Integer) request.getAttribute("namHienTai");
    String emailSession = (String) session.getAttribute("userEmail");
    
    // Set default values nếu null
    if (nhanVienInfo == null) nhanVienInfo = new HashMap<>();
    if (dsDonNghiPhep == null) dsDonNghiPhep = new ArrayList<>();
    if (ngayPhep == null) ngayPhep = new HashMap<>();
    if (namHienTai == null) namHienTai = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
    
    // Lấy nhanVienId từ nhanVienInfo
    Integer nhanVienId = (Integer) nhanVienInfo.get("id");
    if (nhanVienId == null) nhanVienId = 0;
    
    // Lấy thông tin ngày phép
    BigDecimal tongNgayPhep = (BigDecimal) ngayPhep.get("tong_ngay_phep");
    BigDecimal ngayPhepDaDung = (BigDecimal) ngayPhep.get("ngay_phep_da_dung");
    BigDecimal ngayPhepConLai = (BigDecimal) ngayPhep.get("ngay_phep_con_lai");
    BigDecimal ngayPhepNamTruoc = (BigDecimal) ngayPhep.get("ngay_phep_nam_truoc");
    
    if (tongNgayPhep == null) tongNgayPhep = new BigDecimal("0.0");
    if (ngayPhepDaDung == null) ngayPhepDaDung = new BigDecimal("0.0");
    if (ngayPhepConLai == null) ngayPhepConLai = new BigDecimal("0.0");
    if (ngayPhepNamTruoc == null) ngayPhepNamTruoc = new BigDecimal("0.0");
    
    BigDecimal tongPhepConLaiAll = ngayPhepConLai.add(ngayPhepNamTruoc);
    
    // Đếm số đơn theo trạng thái
    int donChoDuyet = 0, donDaDuyet = 0, donTuChoi = 0;
    for (Map<String, Object> don : dsDonNghiPhep) {
        String trangThai = (String) don.get("trang_thai");
        if ("cho_duyet".equals(trangThai)) donChoDuyet++;
        else if ("da_duyet".equals(trangThai)) donDaDuyet++;
        else if ("tu_choi".equals(trangThai)) donTuChoi++;
    }
%>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/png" href="Img/logoics.png">
    <title>Nghỉ phép - ICSS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --success-gradient: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            --warning-gradient: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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
            animation: pulse 4s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 0.5; }
            50% { transform: scale(1.1); opacity: 0.3; }
        }

        .page-header h2 {
            font-weight: 700;
            margin: 0;
            position: relative;
            z-index: 1;
        }

        .page-header p {
            opacity: 0.9;
            margin: 8px 0 0 0;
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
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0.2) 0%, transparent 50%);
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 15px 45px rgba(0, 0, 0, 0.2);
        }

        .stat-card:hover::before {
            opacity: 1;
        }

        .stat-card.remaining { background: var(--success-gradient); }
        .stat-card.used { background: var(--info-gradient); }
        .stat-card.pending { background: var(--warning-gradient); }
        .stat-card.approved { background: var(--primary-gradient); }

        .stat-card .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 10px;
            opacity: 0.9;
        }

        .stat-card .stat-value {
            font-size: 2.2rem;
            font-weight: 700;
            margin: 0;
            text-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }

        .stat-card .stat-label {
            font-size: 0.95rem;
            opacity: 0.9;
            margin-top: 5px;
        }

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

        .form-control::placeholder {
            color: #94a3b8;
        }

        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }

        /* ===== BUTTONS ===== */
        .btn-primary-gradient {
            background: var(--primary-gradient);
            border: none;
            color: white;
            padding: 14px 32px;
            border-radius: 12px;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-primary-gradient:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.5);
            color: white;
        }

        .btn-outline-danger {
            border-radius: 10px;
            font-weight: 500;
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
            font-size: 0.9rem;
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
            transform: scale(1.01);
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

        .empty-state h5 {
            color: #64748b;
            margin-bottom: 10px;
        }

        /* ===== ANIMATIONS ===== */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
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
                    <h2><i class="fa-solid fa-calendar-xmark me-3"></i>Nghỉ phép</h2>
                    <p><i class="fa-regular fa-clock me-2"></i>Tạo và quản lý đơn xin nghỉ phép của bạn</p>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3 col-sm-6">
                <div class="stat-card remaining animate-fadeInUp delay-1">
                    <div class="stat-icon"><i class="fa-solid fa-calendar-check"></i></div>
                    <div class="stat-value"><%= tongPhepConLaiAll %></div>
                    <div class="stat-label">
                        <% if (ngayPhepNamTruoc.compareTo(BigDecimal.ZERO) > 0) { %>
                            <%= ngayPhepConLai %> (<%= namHienTai %>) + <%= ngayPhepNamTruoc %> (<%= namHienTai - 1 %>)
                        <% } else { %>
                            Ngày phép còn lại (<%= namHienTai %>)
                        <% } %>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-card used animate-fadeInUp delay-2">
                    <div class="stat-icon"><i class="fa-solid fa-calendar-minus"></i></div>
                    <div class="stat-value"><%= ngayPhepDaDung %></div>
                    <div class="stat-label">Đã sử dụng / <%= tongNgayPhep %></div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-card pending animate-fadeInUp delay-3">
                    <div class="stat-icon"><i class="fa-solid fa-hourglass-half"></i></div>
                    <div class="stat-value"><%= donChoDuyet %></div>
                    <div class="stat-label">Đơn chờ duyệt</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-card approved animate-fadeInUp delay-4">
                    <div class="stat-icon"><i class="fa-solid fa-circle-check"></i></div>
                    <div class="stat-value"><%= donDaDuyet %></div>
                    <div class="stat-label">Đơn đã duyệt</div>
                </div>
            </div>
        </div>

        <!-- Form tạo đơn nhanh - Collapse -->
        <div class="main-box animate-fadeInUp">
            <button class="btn btn-link w-100 text-start p-0" type="button" data-bs-toggle="collapse" data-bs-target="#formTaoDonCollapse" aria-expanded="false" aria-controls="formTaoDonCollapse" style="text-decoration: none;">
                <div class="box-title mb-0">
                    <i class="fa-solid fa-file-signature"></i>
                    Tạo đơn xin nghỉ phép
                    <i class="fa-solid fa-chevron-down float-end transition-transform"></i>
                </div>
            </button>
            
            <div class="collapse" id="formTaoDonCollapse">
                <div class="pt-3 border-top">
                    <form id="formTaoDon">
                        <input type="hidden" name="nhanVienId" value="<%= nhanVienId %>">
                        <div class="row g-4">
                            <div class="col-md-4">
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
                                    <i class="fa-solid fa-hashtag me-2"></i>Số ngày nghỉ <span class="text-danger">*</span>
                                </label>
                                <input type="number" class="form-control" name="soNgay" step="0.5" min="0.5" max="30" 
                                       placeholder="VD: 1, 0.5, 2..." required>
                                <small class="text-muted">Nhập 0.5 nếu nghỉ nửa ngày</small>
                            </div>
                            <div class="col-md-12">
                                <label class="form-label">
                                    <i class="fa-solid fa-comment-dots me-2"></i>Lý do xin nghỉ <span class="text-danger">*</span>
                                </label>
                                <textarea class="form-control" name="lyDo" rows="3" 
                                          placeholder="Nhập lý do xin nghỉ phép chi tiết..." required></textarea>
                            </div>
                            <div class="col-12 mt-4">
                                <button type="submit" class="btn btn-primary-gradient btn-lg">
                                    <i class="fa-solid fa-paper-plane me-2"></i>Gửi đơn xin phép
                                </button>
                                <button type="reset" class="btn btn-outline-secondary btn-lg ms-2">
                                    <i class="fa-solid fa-rotate-left me-2"></i>Làm mới
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Lịch sử đơn nghỉ phép -->
        <div class="main-box animate-fadeInUp">
            <div class="box-title">
                <i class="fa-solid fa-clock-rotate-left"></i>
                Lịch sử đơn nghỉ phép của bạn
            </div>
            
            <% if (dsDonNghiPhep.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fa-solid fa-inbox"></i>
                    <h5>Chưa có đơn nghỉ phép nào</h5>
                    <p>Bạn chưa tạo đơn xin nghỉ phép. Hãy tạo đơn đầu tiên!</p>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table table-modern">
                        <thead>
                            <tr>
                                <th>#</th>
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
                                String lyDoTuChoi = (String) don.get("ly_do_tu_choi");
                                
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
                            <tr>
                                <td><strong><%= stt++ %></strong></td>
                                <td>
                                    <span class="leave-type-badge <%= leaveClass %>"><%= loaiPhep %></span>
                                </td>
                                <td>
                                    <i class="fa-regular fa-calendar text-primary me-2"></i>
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
                                        <i class="fa-solid fa-calendar-days me-1"></i><%= don.get("so_ngay") %> ngày
                                    </span>
                                </td>
                                <td style="max-width: 200px;">
                                    <span class="text-truncate d-inline-block" style="max-width: 180px;" 
                                          title="<%= lyDo %>"><%= lyDo %></span>
                                    <% if ("tu_choi".equals(trangThai) && lyDoTuChoi != null) { %>
                                        <br>
                                        <small class="text-danger">
                                            <i class="fa-solid fa-exclamation-circle me-1"></i>
                                            <%= lyDoTuChoi %>
                                        </small>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="badge-status <%= statusClass %>">
                                        <i class="fa-solid <%= statusIcon %>"></i>
                                        <%= statusText %>
                                    </span>
                                </td>
                                <td>
                                    <i class="fa-regular fa-clock text-muted me-1"></i>
                                    <small class="text-muted">
                                        <%
                                            java.sql.Timestamp taoTime = (java.sql.Timestamp) don.get("thoi_gian_tao");
                                            String taoStr = (taoTime != null) ? new java.text.SimpleDateFormat("dd/MM/yyyy - HH:mm:ss").format(taoTime) : "";
                                        %>
                                        <%= taoStr %>
                                    </small>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-outline-primary" 
                                            onclick="xemChiTiet('<%= don.get("id") %>')" 
                                            title="Xem chi tiết">
                                        <i class="fa-solid fa-eye"></i>
                                    </button>
                                    <% if ("cho_duyet".equals(trangThai)) { %>
                                        <button class="btn btn-sm btn-outline-danger" 
                                                onclick="xoaDon('<%= don.get("id") %>')" 
                                                title="Xóa đơn">
                                            <i class="fa-solid fa-trash"></i>
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
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set min date cho form
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date().toISOString().split('T')[0];
            document.querySelector('input[name="ngayBatDau"]').min = today;
            document.querySelector('input[name="ngayKetThuc"]').min = today;
            
            // Auto calculate ngày kết thúc
            document.querySelector('input[name="ngayBatDau"]').addEventListener('change', function() {
                document.querySelector('input[name="ngayKetThuc"]').min = this.value;
                if (!document.querySelector('input[name="ngayKetThuc"]').value) {
                    document.querySelector('input[name="ngayKetThuc"]').value = this.value;
                }
            });
            
            // Auto calculate số ngày
            const calcDays = () => {
                const start = document.querySelector('input[name="ngayBatDau"]').value;
                const end = document.querySelector('input[name="ngayKetThuc"]').value;
                if (start && end) {
                    const diffTime = new Date(end) - new Date(start);
                    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
                    if (diffDays > 0) {
                        document.querySelector('input[name="soNgay"]').value = diffDays;
                    }
                }
            };
            
            document.querySelector('input[name="ngayBatDau"]').addEventListener('change', calcDays);
            document.querySelector('input[name="ngayKetThuc"]').addEventListener('change', calcDays);
        });

        // Submit form tạo đơn
        document.getElementById('formTaoDon').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const loaiPhepSelect = document.querySelector('select[name="loaiPhep"]');
            const loaiPhep = loaiPhepSelect.value;
            const soNgay = parseFloat(document.querySelector('input[name="soNgay"]').value);
            const ngayBatDauInput = document.querySelector('input[name="ngayBatDau"]');
            const ngayKetThucInput = document.querySelector('input[name="ngayKetThuc"]');
            const ngayBatDau = ngayBatDauInput.value;
            const ngayKetThuc = ngayKetThucInput.value;
            const lyDo = document.querySelector('textarea[name="lyDo"]').value;
            
            // Kiểm tra các trường bắt buộc
            if (!loaiPhep || !ngayBatDau || !ngayKetThuc || !lyDo) {
                Swal.fire({
                    icon: 'error',
                    title: 'Thiếu thông tin!',
                    text: 'Vui lòng điền đầy đủ các trường bắt buộc.',
                    confirmButtonColor: '#667eea'
                });
                return;
            }
            
            // Hàm kiểm tra cuối tuần (Thứ 7 = 6, Chủ nhật = 0)
            function isCuoiTuan(dateStr) {
                const date = new Date(dateStr);
                const day = date.getDay();
                return day === 0 || day === 6; // 0 = Chủ nhật, 6 = Thứ 7
            }
            
            // Kiểm tra ngày bắt đầu có phải cuối tuần không
            if (isCuoiTuan(ngayBatDau)) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Ngày cuối tuần!',
                    text: 'Bạn đã chọn ngày thứ 7 hoặc chủ nhật. Không thể đăng ký nghỉ phép vào ngày này.',
                    confirmButtonColor: '#667eea'
                }).then(() => {
                    ngayBatDauInput.value = ''; // Reset về null
                    ngayBatDauInput.focus();
                });
                return;
            }
            
            // Kiểm tra ngày kết thúc có phải cuối tuần không
            if (isCuoiTuan(ngayKetThuc)) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Ngày cuối tuần!',
                    text: 'Bạn đã chọn ngày thứ 7 hoặc chủ nhật. Không thể đăng ký nghỉ phép vào ngày này.',
                    confirmButtonColor: '#667eea'
                }).then(() => {
                    ngayKetThucInput.value = ''; // Reset về null
                    ngayKetThucInput.focus();
                });
                return;
            }
            
            // Kiểm tra ngày hợp lệ
            const from = new Date(ngayBatDau);
            const to = new Date(ngayKetThuc);
            if (from > to) {
                Swal.fire({
                    icon: 'error',
                    title: 'Ngày không hợp lệ!',
                    text: 'Ngày bắt đầu phải trước ngày kết thúc.',
                    confirmButtonColor: '#667eea'
                });
                return;
            }
            
            // Nếu là phép năm, kiểm tra số phép còn lại
            if (loaiPhep === 'Phép năm') {
                fetch('apiNghiPhep?action=getNgayPhep&nhanVienId=<%= nhanVienId %>&nam=' + new Date().getFullYear())
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            const conLai = data.data.ngay_phep_con_lai || 12;
                            if (soNgay > conLai) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Không đủ phép năm!',
                                    text: 'Bạn chỉ còn ' + conLai + ' ngày phép. Vui lòng chọn loại phép khác.',
                                    confirmButtonColor: '#667eea'
                                });
                                return;
                            }
                            if (conLai <= 0) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Hết phép năm!',
                                    text: 'Bạn đã hết phép năm trong năm nay. Vui lòng chọn loại phép khác.',
                                    confirmButtonColor: '#667eea'
                                });
                                return;
                            }
                            submitForm();
                        } else {
                            submitForm();
                        }
                    })
                    .catch(err => {
                        console.error('Lỗi kiểm tra phép:', err);
                        submitForm();
                    });
            } else {
                submitForm();
            }
            
            function submitForm() {
                const formData = new FormData(document.getElementById('formTaoDon'));
                formData.append('action', 'taoDon');
                
                Swal.fire({
                    title: 'Xác nhận gửi đơn?',
                    text: 'Bạn có chắc muốn gửi đơn xin nghỉ phép này?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#667eea',
                    cancelButtonColor: '#94a3b8',
                    confirmButtonText: 'Gửi đơn',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        // Hiển thị loading
                        Swal.fire({
                            title: 'Đang xử lý...',
                            text: 'Vui lòng chờ',
                            icon: 'info',
                            allowOutsideClick: false,
                            allowEscapeKey: false,
                            didOpen: () => {
                                Swal.showLoading();
                            }
                        });
                        
                        const params = new URLSearchParams(formData);
                        console.log('Sending data:', params.toString());
                        
                        fetch('apiNghiPhep', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded'
                            },
                            body: params.toString()
                        })
                        .then(res => {
                            console.log('Response status:', res.status);
                            return res.json();
                        })
                        .then(data => {
                            console.log('Response data:', data);
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
                                    text: data.message || 'Không thể gửi đơn',
                                    confirmButtonColor: '#667eea'
                                });
                            }
                        })
                        .catch(err => {
                            console.error('Fetch error:', err);
                            Swal.fire({
                                icon: 'error',
                                title: 'Lỗi kết nối!',
                                text: 'Không thể gửi đơn. Vui lòng thử lại sau. Lỗi: ' + err.message,
                                confirmButtonColor: '#667eea'
                            });
                        });
                    }
                });
            }
        });

        // Xem chi tiết đơn
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
                        new bootstrap.Modal(document.getElementById('modalChiTiet')).show();
                    }
                });
        }

        // Xóa đơn
        function xoaDon(donId) {
            donId = parseInt(donId);
            Swal.fire({
                title: 'Xác nhận xóa?',
                text: 'Bạn có chắc muốn xóa đơn này? Hành động này không thể hoàn tác!',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#94a3b8',
                confirmButtonText: 'Xóa',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    const formData = new FormData();
                    formData.append('action', 'xoaDon');
                    formData.append('donId', donId);
                    formData.append('nhanVienId', '<%= nhanVienId %>');
                    
                    fetch('apiNghiPhep', {
                        method: 'POST',
                        body: new URLSearchParams(formData)
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            Swal.fire({
                                icon: 'success',
                                title: 'Đã xóa!',
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
    </script>
</body>
</html>
