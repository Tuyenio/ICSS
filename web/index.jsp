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
            .chart-card{background:#fff;border-radius:20px;box-shadow:0 4px 18px -4px rgba(0,0,0,.08);padding:20px 22px;height:100%;display:flex;flex-direction:column;}
            .chart-card h6{font-weight:600;font-size:0.82rem;text-transform:uppercase;letter-spacing:1px;margin:0 0 10px;color:#495057;}
            .chart-card .sub-chart h6{font-size:0.78rem;letter-spacing:.8px;margin-bottom:4px;}
            .sub-chart + .sub-chart{border-top:1px dashed #e3e6ea;padding-top:8px;margin-top:4px;}
            .chart-wrapper{position:relative;}
            canvas{max-height:none !important;}
            @media (max-width: 992px){ .chart-card{padding:16px 16px;} }
            .stat-card-eq .card-body{display:flex;flex-direction:column;justify-content:center;min-height:140px;}
            .stat-card-eq h3{font-size:1.9rem;font-weight:600;}
        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-chart-line"></i> Dashboard';
        </script>
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
                        <a href="index.jsp" class="active"><i
                                class="fa-solid fa-chart-line"></i><span>Dashboard</span></a>
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
                        <a href="./dsChamCong"><i class="fa-solid fa-calendar-check"></i><span>Chấm công</span></a>
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
                    <!-- Main Content -->
                    <div class="main-content">
                        <!-- Module shortcuts moved to top -->
                        <div class="dashboard-row mb-5">
                            <div>
                                <div class="card card-module text-center">
                                    <div class="card-body">
                                        <i class="fa-solid fa-users fa-2x text-primary mb-2"></i>
                                        <h5 class="card-title">Nhân sự</h5>
                                        <p class="card-text">Quản lý thông tin nhân viên, phân quyền, tìm kiếm...</p>
                                        <a href="./dsnhanvien" class="btn btn-outline-primary btn-sm rounded-pill px-3">Xem chi tiết</a>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <div class="card card-module text-center">
                                    <div class="card-body">
                                        <i class="fa-solid fa-tasks fa-2x text-success mb-2"></i>
                                        <h5 class="card-title">Công việc</h5>
                                        <p class="card-text">Tạo, phân công, theo dõi tiến độ, báo cáo công việc...</p>
                                        <a href="./dsCongviec" class="btn btn-outline-success btn-sm rounded-pill px-3">Xem chi tiết</a>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <div class="card card-module text-center">
                                    <div class="card-body">
                                        <i class="fa-solid fa-building fa-2x text-warning mb-2"></i>
                                        <h5 class="card-title">Phòng ban</h5>
                                        <p class="card-text">Quản lý phòng ban, trưởng phòng, gán nhân viên...</p>
                                        <a href="./dsPhongban" class="btn btn-outline-warning btn-sm rounded-pill px-3">Xem chi tiết</a>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <div class="card card-module text-center">
                                    <div class="card-body">
                                        <i class="fa-solid fa-calendar-check fa-2x text-info mb-2"></i>
                                        <h5 class="card-title">Chấm công</h5>
                                        <p class="card-text">Chấm công, check-in/out, xem lịch sử, xuất phiếu lương...</p>
                                        <a href="./dsChamCong" class="btn btn-outline-info btn-sm rounded-pill px-3">Xem chi tiết</a>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <div class="card card-module text-center">
                                    <div class="card-body">
                                        <i class="fa-solid fa-chart-bar fa-2x text-secondary mb-2"></i>
                                        <h5 class="card-title">Báo cáo</h5>
                                        <p class="card-text">Báo cáo tổng hợp, xuất file, biểu đồ tiến độ, xem KPI...</p>
                                        <a href="report.jsp" class="btn btn-outline-secondary btn-sm rounded-pill px-3">Xem chi tiết</a>
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
            (function(){
                const h = document.getElementById('chartDataHolder'); if(!h) return;
                const pbLabels = h.dataset.pbLabels? h.dataset.pbLabels.split('|').filter(v=>v):[];
                const pbValues = h.dataset.pbValues? h.dataset.pbValues.split(',').map(Number):[];
                const ccLabels = h.dataset.ccLabels? h.dataset.ccLabels.split('|').filter(v=>v):[];
                const ccValues = h.dataset.ccValues? h.dataset.ccValues.split(',').map(Number):[];
                const tongNgay = parseInt(h.dataset.tongNgay||'0');
                const diMuon = parseInt(h.dataset.diMuon||'0');
                // Tiến độ phòng ban (horizontal bar for better balance)
                const ctxPB = document.getElementById('chartTienDoPB');
                if(ctxPB){
                    // sort phòng ban theo % giảm dần để trực quan
                    const pbPairs = pbLabels.map((l,i)=>({label:l,val:pbValues[i]||0})).sort((a,b)=>b.val-a.val);
                    const sortedLabels = pbPairs.map(p=>p.label);
                    const sortedVals = pbPairs.map(p=>p.val);
                    const colorScale = v=>{
                        if(v>=90) return '#198754';
                        if(v>=70) return '#0d6efd';
                        if(v>=50) return '#ffc107';
                        if(v>=30) return '#fd7e14';
                        return '#dc3545';
                    };
                    const barColors = sortedVals.map(colorScale);
                    new Chart(ctxPB,{type:'bar',data:{labels:sortedLabels,datasets:[{label:'% Hoàn thành',data:sortedVals,backgroundColor:barColors,borderWidth:0,barPercentage:0.55,categoryPercentage:0.55} ]},options:{indexAxis:'y',responsive:true,plugins:{legend:{display:false},tooltip:{callbacks:{label:(c)=>c.parsed.x+'%'}}},scales:{x:{beginAtZero:true,max:100,ticks:{callback:(v)=>v+'%'}},y:{ticks:{autoSkip:false}}}}});
                }
                // Trạng thái công việc - Doughnut
                const ctxTT = document.getElementById('chartTrangThaiCV');
                if(ctxTT){
                    const trangThaiData = [parseInt(h.dataset.stHt||'0'),parseInt(h.dataset.stTh||'0'),parseInt(h.dataset.stTre||'0'),parseInt(h.dataset.stCbd||'0')];
                    const colorsTT = ['#198754','#0d6efd','#dc3545','#6c757d']; // xanh lá, xanh dương, đỏ, xám
                    const labelsTT = ['Hoàn thành','Đang thực hiện','Trễ hạn','Chưa bắt đầu'];
                    const totalTT = trangThaiData.reduce((a,b)=>a+b,0);
                    const centerText = totalTT+" CV";
                    new Chart(ctxTT,{type:'doughnut',data:{labels:labelsTT,datasets:[{data:trangThaiData,backgroundColor:colorsTT,borderWidth:1} ]},options:{cutout:'70%',plugins:{legend:{display:false},tooltip:{callbacks:{label:(ctx)=> ctx.label+': '+ctx.parsed+ ' ('+ (totalTT? Math.round(ctx.parsed*100/totalTT):0)+'%)'}}}},plugins:[{id:'centerText',afterDraw(chart,args,opts){const {ctx}=chart; const meta=chart.getDatasetMeta(0); if(!meta||!meta.data||!meta.data.length) return; ctx.save(); ctx.font='600 17px system-ui'; ctx.fillStyle='#212529'; ctx.textAlign='center'; ctx.textBaseline='middle'; const x=meta.data[0].x, y=meta.data[0].y; ctx.fillText(centerText, x, y-4); ctx.font='400 11px system-ui'; ctx.fillStyle='#6c757d'; ctx.fillText('Tổng', x, y+16); ctx.restore();}}]});
                }
                // (Removed personnel composition chart)
                // Chuyển dữ liệu chấm công theo ngày sang data-* để tránh lỗi JSP parser
                const attHolder = document.createElement('div');
                attHolder.id='attDataHolder';
                attHolder.dataset.days="<%= daysStr.toString() %>";
                attHolder.dataset.du="<%= jsDuCong.toString() %>";
                attHolder.dataset.muon="<%= jsDiMuon.toString() %>";
                attHolder.dataset.thieu="<%= jsThieuGio.toString() %>";
                attHolder.dataset.vang="<%= jsVang.toString() %>";
                attHolder.dataset.ot="<%= jsLamThem.toString() %>";
                document.body.appendChild(attHolder);
                const ctxCCongNgay = document.getElementById('chartChamCongNgay');
                if(ctxCCongNgay){
                    const h2=document.getElementById('attDataHolder');
                    const parseArr = s=> s? s.split(',').map(Number):[];
                    const days = h2.dataset.days? h2.dataset.days.split(','):[];
                    const ds=[
                        {label:'Đủ công', data: parseArr(h2.dataset.du), backgroundColor:'#198754', stack:'att'},
                        {label:'Đi muộn', data: parseArr(h2.dataset.muon), backgroundColor:'#0d6efd', stack:'att'},
                        {label:'Thiếu giờ', data: parseArr(h2.dataset.thieu), backgroundColor:'#ffc107', stack:'att'},
                        {label:'Vắng', data: parseArr(h2.dataset.vang), backgroundColor:'#dc3545', stack:'att'},
                        {label:'OT/WFH', data: parseArr(h2.dataset.ot), backgroundColor:'#20c997', stack:'att'}
                    ];
                    new Chart(ctxCCongNgay,{type:'bar',data:{labels:days,datasets:ds},options:{responsive:true,plugins:{legend:{position:'bottom'},tooltip:{mode:'index',intersect:false}},scales:{x:{stacked:true},y:{stacked:true,beginAtZero:true}}}});
                }
            })();
        </script>
    </body>
</html>