<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Lấy dữ liệu từ servlet
    Map<String, Object> nhanVienInfo = (Map<String, Object>) request.getAttribute("nhanVienInfo");
    Map<String, Integer> thongKeCongViec = (Map<String, Integer>) request.getAttribute("thongKeCongViec");
    Map<String, Object> thongKeChamCong = (Map<String, Object>) request.getAttribute("thongKeChamCong");
    Map<String, Object> chamCongHomNay = (Map<String, Object>) request.getAttribute("chamCongHomNay");
    Map<String, Object> thongTinLuong = (Map<String, Object>) request.getAttribute("thongTinLuong");
    Map<String, Object> tongHopKPI = (Map<String, Object>) request.getAttribute("tongHopKPI");
    Integer soThongBaoChuaDoc = (Integer) request.getAttribute("soThongBaoChuaDoc");
    List<Map<String, Object>> congViecSapDenHan = (List<Map<String, Object>>) request.getAttribute("congViecSapDenHan");
    Map<String, Object> thongKeTongQuan = (Map<String, Object>) request.getAttribute("thongKeTongQuan");
    Map<String, Object> thongKePhongBan = (Map<String, Object>) request.getAttribute("thongKePhongBan");
    Integer thangHienTai = (Integer) request.getAttribute("thangHienTai");
    Integer namHienTai = (Integer) request.getAttribute("namHienTai");
    String vaiTro = (String) request.getAttribute("vaiTro");
    
    // Set default values nếu null
    if (nhanVienInfo == null) nhanVienInfo = new HashMap<>();
    if (thongKeCongViec == null) thongKeCongViec = new HashMap<>();
    if (thongKeChamCong == null) thongKeChamCong = new HashMap<>();
    if (chamCongHomNay == null) chamCongHomNay = new HashMap<>();
    if (thongTinLuong == null) thongTinLuong = new HashMap<>();
    if (tongHopKPI == null) tongHopKPI = new HashMap<>();
    if (soThongBaoChuaDoc == null) soThongBaoChuaDoc = 0;
    if (congViecSapDenHan == null) congViecSapDenHan = new ArrayList<>();
    if (thongKeTongQuan == null) thongKeTongQuan = new HashMap<>();
    if (thongKePhongBan == null) thongKePhongBan = new HashMap<>();
    if (thangHienTai == null) thangHienTai = Calendar.getInstance().get(Calendar.MONTH) + 1;
    if (namHienTai == null) namHienTai = Calendar.getInstance().get(Calendar.YEAR);
    if (vaiTro == null) vaiTro = "Nhân viên";
%>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <title>Dashboard Nhân viên</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
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

            .notification-bell {
                position: relative;
            }

            .notification-bell .badge {
                position: absolute;
                top: 0;
                right: 0;
            }

            .card-module {
                border: none;
                border-radius: 18px;
                box-shadow: 0 2px 16px #0002;
                transition: transform 0.12s;
                background: #fff;
            }

            .card-module:hover {
                transform: translateY(-4px) scale(1.03);
                box-shadow: 0 6px 24px #0002;
            }

            .card-module .card-title {
                font-size: 1.18rem;
                font-weight: 600;
            }

            .card-module .card-text {
                min-height: 48px;
                color: #6c757d;
            }

            .dashboard-row {
                display: flex;
                flex-wrap: wrap;
                gap: 32px 24px;
                justify-content: center;
            }

            .dashboard-row>div {
                flex: 1 1 220px;
                min-width: 220px;
                max-width: 320px;
            }

            @media (max-width: 992px) {
                .main-content {
                    padding: 18px 6px;
                    margin-left: 60px;
                }

                .header {
                    margin-left: 60px;
                }

                .dashboard-row {
                    gap: 18px 0;
                }
            }

            @media (max-width: 576px) {
                .main-content {
                    padding: 8px 2px;
                }

                .dashboard-row>div {
                    min-width: 100%;
                    max-width: 100%;
                }
            }

            .quick-report-box {
                background: #fff;
                border-radius: 12px;
                box-shadow: 0 1px 8px #0001;
                padding: 18px 20px;
            }

            .quick-report-box .d-flex {
                font-size: 1.08rem;
            }

            .sidebar i {
                font-family: "Font Awesome 6 Free" !important;
                font-weight: 900;
            }

            .stat-card {
                cursor: pointer;
                transition: all 0.3s ease;
                border: 1px solid #dee2e6;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }

            .stat-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.15);
                border-color: #007bff;
            }

            .stat-icon {
                transition: all 0.3s ease;
            }

            .stat-card:hover .stat-icon {
                transform: scale(1.1);
            }
        </style>
        <script>
            var USER_PAGE_TITLE = '<i class="fa-solid fa-chart-line me-2"></i>Dashboard';
        </script>
    </head>

    <body>
        <nav class="sidebar p-0">
            <div class="sidebar-title text-center py-4 border-bottom border-secondary" style="cursor:pointer;"
                 onclick="location.href = './userDashboard'">
                <i class="fa-solid fa-user me-2"></i>ICSS
            </div>
            <ul class="sidebar-nav mt-3">
                <li>
                    <a href="./userDashboard" class="active"><i
                            class="fa-solid fa-chart-line"></i><span>Dashboard</span></a>
                </li>
                <li>
                    <a href="./dsCongviecNV"><i class="fa-solid fa-tasks"></i><span>Công việc của tôi</span></a>
                </li>
                <li>
                    <a href="./userChamCong"><i class="fa-solid fa-calendar-check"></i><span>Chấm công</span></a>
                </li>
                <li>
                    <a href="./userLuong"><i class="fa-solid fa-money-bill"></i><span>Lương & KPI</span></a>
                </li>

            </ul>
        </nav>
        <%@ include file="user_header.jsp" %>
        <div class="main-content">
            <!-- Thống kê tổng quan công ty (chỉ cho Admin/Manager) -->
            <% if ("Admin".equals(vaiTro) || "Quản lý".equals(vaiTro)) { %>
            <div class="row mb-4">
                <div class="col-12">
                    <h5 class="mb-3"><i class="fa-solid fa-chart-bar me-2"></i>Thống kê tổng quan công ty</h5>
                </div>
                <div class="col-md-3">
                    <div class="card text-center border-0 shadow-sm">
                        <div class="card-body">
                            <i class="fa-solid fa-users fa-2x text-primary mb-2"></i>
                            <h3 class="text-primary"><%= thongKeTongQuan.getOrDefault("tong_nhan_vien", 0) %></h3>
                            <p class="text-muted mb-0">Tổng nhân viên</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center border-0 shadow-sm">
                        <div class="card-body">
                            <i class="fa-solid fa-building fa-2x text-info mb-2"></i>
                            <h3 class="text-info"><%= thongKeTongQuan.getOrDefault("tong_phong_ban", 0) %></h3>
                            <p class="text-muted mb-0">Tổng phòng ban</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center border-0 shadow-sm">
                        <div class="card-body">
                            <i class="fa-solid fa-tasks fa-2x text-success mb-2"></i>
                            <h3 class="text-success"><%= thongKeTongQuan.getOrDefault("tong_cong_viec", 0) %></h3>
                            <p class="text-muted mb-0">Tổng công việc</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-center border-0 shadow-sm">
                        <div class="card-body">
                            <i class="fa-solid fa-chart-line fa-2x text-warning mb-2"></i>
                            <h3 class="text-warning"><%= thongKeTongQuan.getOrDefault("ty_le_hoan_thanh", 0.0) %>%</h3>
                            <p class="text-muted mb-0">Tỷ lệ hoàn thành</p>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Thống kê phòng ban -->
            <div class="row mb-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="mb-0">
                        <i class="fa-solid fa-building me-2"></i>Thông tin phòng ban
                    </h5>
                    <div class="text-muted">
                        <i class="fas fa-calendar me-1"></i>
                        <span id="currentDate"></span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-body">
                            <h6 class="card-title text-primary">
                                <i class="fa-solid fa-building me-2"></i><%= thongKePhongBan.get("ten_phong") %>
                            </h6>
                            <p class="mb-1">
                                <strong>Trưởng phòng:</strong> 
                                <%= thongKePhongBan.get("truong_phong_ten") != null ? thongKePhongBan.get("truong_phong_ten") : "Chưa có" %>
                            </p>
                            <p class="mb-1">
                                <strong>Số nhân viên:</strong> <%= thongKePhongBan.getOrDefault("so_nhan_vien", 0) %> người
                            </p>
                            <p class="mb-0">
                                <strong>Số công việc:</strong> <%= thongKePhongBan.getOrDefault("so_cong_viec", 0) %> task
                            </p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-body">
                            <h6 class="card-title text-info">
                                <i class="fa-solid fa-calendar-check me-2"></i>Chấm công tháng <%= thangHienTai %>/<%= namHienTai %>
                            </h6>
                            <p class="mb-1">
                                <strong>Số ngày đã chấm:</strong> <%= thongKeChamCong.getOrDefault("tong_ngay_cham", 0) %> ngày
                            </p>
                            <p class="mb-1">
                                <strong>Số ngày đi trễ:</strong> <%= thongKeChamCong.getOrDefault("ngay_di_tre", 0) %> ngày
                            </p>
                            <p class="mb-0">
                                <strong>Tổng giờ làm:</strong> <%= thongKeChamCong.getOrDefault("tong_gio_lam", 0.0) %> giờ
                            </p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-body">
                            <h6 class="card-title text-success">
                                <i class="fa-solid fa-money-bill me-2"></i>Lương & KPI tháng <%= thangHienTai %>/<%= namHienTai %>
                            </h6>
                            <% if (!thongTinLuong.isEmpty()) { %>
                            <p class="mb-1">
                                <strong>Lương thực tế:</strong> 
                                <span class="text-success">
                                    <fmt:formatNumber value="${thongTinLuong.luong_thuc_te}" type="currency" currencySymbol="" pattern="#,##0" /> VNĐ
                                </span>
                            </p>
                            <p class="mb-1">
                                <strong>Trạng thái:</strong> 
                                <span class="badge <%= thongTinLuong.get("trang_thai").equals("Đã trả") ? "bg-success" : "bg-warning" %>">
                                    <%= thongTinLuong.get("trang_thai") %>
                                </span>
                            </p>
                            <% } else { %>
                            <p class="text-muted">Chưa có dữ liệu lương</p>
                            <% } %>
                            <% if (!tongHopKPI.isEmpty()) { %>
                            <p class="mb-0 mt-2">
                                <strong>Điểm KPI TB:</strong> 
                                <span class="text-primary"><%= tongHopKPI.getOrDefault("diem_kpi_trung_binh", 0.0) %>/10</span>
                            </p>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Công việc sắp đến hạn -->
            <% if (congViecSapDenHan != null && !congViecSapDenHan.isEmpty()) { %>
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header bg-warning text-dark">
                            <h6 class="mb-0"><i class="fa-solid fa-exclamation-triangle me-2"></i>Công việc sắp đến hạn (7 ngày tới)</h6>
                        </div>
                        <div class="card-body">
                            <% for (Map<String, Object> cv : congViecSapDenHan) { %>
                            <div class="d-flex justify-content-between align-items-center border-bottom py-2">
                                <div>
                                    <strong><%= cv.get("ten_cong_viec") %></strong>
                                    <br>
                                    <small class="text-muted">Người giao: <%= cv.get("nguoi_giao_ten") %></small>
                                </div>
                                <div class="text-end">
                                    <span class="badge <%= cv.get("muc_do_uu_tien").equals("Cao") ? "bg-danger" : 
                                                                cv.get("muc_do_uu_tien").equals("Trung bình") ? "bg-warning" : "bg-success" %>">
                                        <%= cv.get("muc_do_uu_tien") %>
                                    </span>
                                    <br>
                                    <small class="text-danger">Hạn: <%= cv.get("han_hoan_thanh") %></small>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Modules dashboard -->
            <div class="dashboard-row mb-5">
                <div>
                    <div class="card card-module text-center">
                        <div class="card-body">
                            <i class="fa-solid fa-tasks fa-2x text-success mb-2"></i>
                            <h5 class="card-title">Công việc của tôi</h5>
                            <p class="card-text">Xem, cập nhật tiến độ, tải file, nhận đánh giá công việc...</p>
                            <a href="./dsCongviecNV" class="btn btn-outline-success btn-sm rounded-pill px-3">Xem chi
                                tiết</a>
                        </div>
                    </div>
                </div>
                <div>
                    <div class="card card-module text-center">
                        <div class="card-body">
                            <i class="fa-solid fa-calendar-check fa-2x text-info mb-2"></i>
                            <h5 class="card-title">Chấm công</h5>
                            <p class="card-text">Chấm công, xem lịch sử, kiểm tra trạng thái ngày công...</p>
                            <a href="./userChamCong" class="btn btn-outline-info btn-sm rounded-pill px-3">Xem
                                chi tiết</a>
                        </div>
                    </div>
                </div>
                <div>
                    <div class="card card-module text-center">
                        <div class="card-body">
                            <i class="fa-solid fa-money-bill fa-2x text-warning mb-2"></i>
                            <h5 class="card-title">Lương & KPI</h5>
                            <p class="card-text">Xem bảng lương, thưởng, phạt, KPI cá nhân từng tháng...</p>
                            <a href="./userLuong" class="btn btn-outline-warning btn-sm rounded-pill px-3">Xem
                                chi tiết</a>
                        </div>
                    </div>
                </div>
                <div>
                    <div class="card card-module text-center">
                        <div class="card-body">
                            <i class="fa-solid fa-bell fa-2x text-danger mb-2"></i>
                            <h5 class="card-title">Thông báo</h5>
                            <p class="card-text">Nhận thông báo công việc, deadline, lương, khen thưởng...</p>
                            <a href="user_notification.jsp"
                               class="btn btn-outline-danger btn-sm rounded-pill px-3">Xem chi tiết</a>
                        </div>
                    </div>
                </div>
                <div>
                    <div class="card card-module text-center">
                        <div class="card-body">
                            <i class="fa-solid fa-user-circle fa-2x text-secondary mb-2"></i>
                            <h5 class="card-title">Hồ sơ cá nhân</h5>
                            <p class="card-text">Xem, cập nhật thông tin cá nhân, đổi mật khẩu, avatar...</p>
                            <a href="user_profile.jsp"
                               class="btn btn-outline-secondary btn-sm rounded-pill px-3">Xem chi tiết</a>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Quick report (doughnut giống admin) -->
            <div class="quick-report-box mt-4" id="userQuickReport"
                 data-ht="<%= thongKeCongViec.getOrDefault("Đã hoàn thành",0) %>"
                 data-th="<%= thongKeCongViec.getOrDefault("Đang thực hiện",0) %>"
                 data-tre="<%= thongKeCongViec.getOrDefault("Trễ hạn",0) %>"
                 data-cbd="<%= thongKeCongViec.getOrDefault("Chưa bắt đầu",0) %>">
                <div class="d-flex justify-content-start align-items-center flex-wrap mb-2">
                    <h5 class="mb-0"><i class="fa-solid fa-chart-pie me-2 text-primary"></i>Báo cáo nhanh - Công việc của tôi</h5>
                </div>
                <div class="row g-3 align-items-center">
                    <div class="col-md-5">
                        <div class="position-relative" style="height:210px;">
                            <canvas id="chartTrangThaiCaNhan"></canvas>
                        </div>
                    </div>
                    <div class="col-md-7">
                        <div class="row g-2 small">
                            <div class="col-6"><div class="p-2 rounded-3 d-flex align-items-center gap-2 bg-light border"><span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#198754;"></span><span>HT: <b><span id="cvHT"></span></b><br><small class="text-muted" id="pctHT"></small></span></div></div>
                            <div class="col-6"><div class="p-2 rounded-3 d-flex align-items-center gap-2 bg-light border"><span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#0d6efd;"></span><span>TH: <b><span id="cvTH"></span></b><br><small class="text-muted" id="pctTH"></small></span></div></div>
                            <div class="col-6"><div class="p-2 rounded-3 d-flex align-items-center gap-2 bg-light border"><span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#dc3545;"></span><span>Trễ: <b><span id="cvTre"></span></b><br><small class="text-muted" id="pctTre"></small></span></div></div>
                            <div class="col-6"><div class="p-2 rounded-3 d-flex align-items-center gap-2 bg-light border"><span class="d-inline-block rounded-circle" style="width:10px;height:10px;background:#6c757d;"></span><span>CBĐ: <b><span id="cvCBD"></span></b><br><small class="text-muted" id="pctCBD"></small></span></div></div>
                        </div>
                        <div class="mt-3 small text-muted">Tổng: <b><span id="cvTotal"></span></b> công việc</div>
                    </div>
                </div>
            </div>

            <!-- Thông báo -->
            <% if (soThongBaoChuaDoc > 0) { %>
            <div class="alert alert-info mt-4" role="alert">
                <i class="fa-solid fa-bell me-2"></i>
                Bạn có <strong><%= soThongBaoChuaDoc %></strong> thông báo chưa đọc. 
                <a href="user_notification.jsp" class="alert-link">Xem ngay</a>
            </div>
            <% } %>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
        <script>
            // Doughnut chart giống admin cho báo cáo nhanh cá nhân
            (function(){
                const box=document.getElementById('userQuickReport'); if(!box) return;
                const ht=parseInt(box.dataset.ht||'0');
                const th=parseInt(box.dataset.th||'0');
                const tre=parseInt(box.dataset.tre||'0');
                const cbd=parseInt(box.dataset.cbd||'0');
                const total=ht+th+tre+cbd;
                // cập nhật số
                const set=(id,val)=>{const el=document.getElementById(id); if(el) el.textContent=val;};
                set('cvHT',ht); set('cvTH',th); set('cvTre',tre); set('cvCBD',cbd); set('cvTotal',total);
                const pct=(v)=> total? Math.round(v*100/total)+'%':'0%';
                set('pctHT',pct(ht)); set('pctTH',pct(th)); set('pctTre',pct(tre)); set('pctCBD',pct(cbd));
                const ctx=document.getElementById('chartTrangThaiCaNhan'); if(!ctx) return;
                const data=[ht,th,tre,cbd]; const colors=['#198754','#0d6efd','#dc3545','#6c757d'];
                new Chart(ctx,{type:'doughnut',data:{labels:['Hoàn thành','Đang thực hiện','Trễ hạn','Chưa bắt đầu'],datasets:[{data,backgroundColor:colors,borderWidth:1}]},options:{cutout:'70%',plugins:{legend:{display:false},tooltip:{callbacks:{label:(c)=> c.label+': '+c.parsed+' ('+(total?Math.round(c.parsed*100/total):0)+'%)'}}}},plugins:[{id:'centerTxtUser',afterDraw(chart){const meta=chart.getDatasetMeta(0); if(!meta.data.length) return; const {ctx}=chart; const x=meta.data[0].x,y=meta.data[0].y; ctx.save(); ctx.font='600 16px system-ui'; ctx.fillStyle='#212529'; ctx.textAlign='center'; ctx.textBaseline='middle'; ctx.fillText(total+' CV',x,y-4); ctx.font='400 11px system-ui'; ctx.fillStyle='#6c757d'; ctx.fillText('Tổng',x,y+14); ctx.restore();}}]});
            })();
                     // Hàm check-in
                     function checkIn() {
                         fetch('./userChamCong', {
                             method: 'POST',
                             headers: {
                                 'Content-Type': 'application/x-www-form-urlencoded',
                             },
                             body: 'action=checkin'
                         })
                                 .then(response => response.json())
                                 .then(data => {
                                     if (data.success) {
                                         alert('Check-in thành công!');
                                         location.reload();
                                     } else {
                                         alert('Lỗi check-in: ' + data.message);
                                     }
                                 })
                                 .catch(error => {
                                     console.error('Error:', error);
                                     alert('Có lỗi xảy ra khi check-in');
                                 });
                     }

                     // Hàm check-out  
                     function checkOut() {
                         fetch('./userChamCong', {
                             method: 'POST',
                             headers: {
                                 'Content-Type': 'application/x-www-form-urlencoded',
                             },
                             body: 'action=checkout'
                         })
                                 .then(response => response.json())
                                 .then(data => {
                                     if (data.success) {
                                         alert('Check-out thành công!');
                                         location.reload();
                                     } else {
                                         alert('Lỗi check-out: ' + data.message);
                                     }
                                 })
                                 .catch(error => {
                                     console.error('Error:', error);
                                     alert('Có lỗi xảy ra khi check-out');
                                 });
                     }

                     // Auto-refresh mỗi 5 phút để cập nhật dữ liệu
                     setInterval(function () {
                         location.reload();
                     }, 300000); // 5 phút

                     // Hiển thị ngày hiện tại
                     document.addEventListener('DOMContentLoaded', function () {
                         const currentDateElement = document.getElementById('currentDate');
                         if (currentDateElement) {
                             const now = new Date();
                             const options = {
                                 weekday: 'long',
                                 year: 'numeric',
                                 month: 'long',
                                 day: 'numeric'
                             };
                             currentDateElement.textContent = now.toLocaleDateString('vi-VN', options);
                         }
                     });
        </script>

    </body>

</html>