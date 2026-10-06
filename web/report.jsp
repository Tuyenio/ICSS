<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="controller.apiBaoCao" %>
<%@ page import="controller.KNCSDL" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    HttpSession ssis = request.getSession();
    
    // Lấy tham số từ request
    String tuNgayParam = request.getParameter("tu_ngay");
    String denNgayParam = request.getParameter("den_ngay");
    String thangParam = request.getParameter("thang");
    String namParam = request.getParameter("nam");
    String phongBanParam = request.getParameter("phong_ban");
    
    List<Map<String, Object>> baoCaoNhanVien = null;
    List<Map<String, Object>> baoCaoDuAn = null;
    String displayDateRange = "";
    
    // Xác định kiểu lọc: date range hoặc tháng/năm
    if (tuNgayParam != null && denNgayParam != null && !tuNgayParam.isEmpty() && !denNgayParam.isEmpty()) {
        // Lọc theo khoảng thời gian
        baoCaoNhanVien = apiBaoCao.getBaoCaoNhanVienByDateRange(tuNgayParam, denNgayParam, phongBanParam);
        baoCaoDuAn = apiBaoCao.getBaoCaoDuAnByDateRange(tuNgayParam, denNgayParam, phongBanParam);
        
        // Format hiển thị đẹp
        DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        LocalDate tuNgay = LocalDate.parse(tuNgayParam, inputFormatter);
        LocalDate denNgay = LocalDate.parse(denNgayParam, inputFormatter);
        displayDateRange = tuNgay.format(outputFormatter) + " - " + denNgay.format(outputFormatter);
    } else {
        // Lọc theo tháng/năm (mặc định)
        if (thangParam == null || thangParam.isEmpty()) {
            Calendar cal = Calendar.getInstance();
            thangParam = String.valueOf(cal.get(Calendar.MONTH) + 1);
            namParam = String.valueOf(cal.get(Calendar.YEAR));
        }
        baoCaoNhanVien = apiBaoCao.getBaoCaoNhanVien(thangParam, namParam, phongBanParam);
        // Tính toán date range cho báo cáo dự án
        java.time.YearMonth ym = java.time.YearMonth.of(Integer.parseInt(namParam), Integer.parseInt(thangParam));
        String startOfMonth = ym.atDay(1).toString();
        String endOfMonth = ym.atEndOfMonth().toString();
        baoCaoDuAn = apiBaoCao.getBaoCaoDuAnByDateRange(startOfMonth, endOfMonth, phongBanParam);
        displayDateRange = "Tháng " + thangParam + "/" + namParam;
    }
    
    // Lấy dữ liệu biểu đồ
    Map<String, Object> pieChartData;
    Map<String, Object> barChartData;

    if (tuNgayParam != null && !tuNgayParam.isEmpty() && denNgayParam != null && !denNgayParam.isEmpty()) {
        // Khi người dùng chọn khoảng thời gian
        pieChartData = apiBaoCao.getDataForPieChart(tuNgayParam, denNgayParam, phongBanParam);
        barChartData = apiBaoCao.getDataForBarChart(ssis, tuNgayParam, denNgayParam, phongBanParam);
    } else {
        // Khi không chọn khoảng thời gian, dùng tháng/năm
        java.time.YearMonth ym = java.time.YearMonth.of(Integer.parseInt(namParam), Integer.parseInt(thangParam));
        String startOfMonth = ym.atDay(1).toString();
        String endOfMonth = ym.atEndOfMonth().toString();

        pieChartData = apiBaoCao.getDataForPieChart(startOfMonth, endOfMonth, phongBanParam);
        barChartData = apiBaoCao.getDataForBarChart(ssis, startOfMonth, endOfMonth, phongBanParam);
    }
    
    // Lấy danh sách phòng ban cho filter
    List<Map<String, Object>> danhSachPhongBan = new ArrayList<>();
    try {
        KNCSDL kn = new KNCSDL();
        danhSachPhongBan = kn.getAllPhongBan();
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Tạo JSON data cho JavaScript
    String pieChartJson = apiBaoCao.convertToJson(pieChartData);
    String barChartJson = apiBaoCao.convertToJson(barChartData);
%>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <%@ include file="pwa_head.jspf" %>
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Báo cáo tổng hợp</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
        <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
        <style>
            /* ==== GLOBAL ==== */
            body {
                background: #f8fafc;
                font-family: 'Segoe UI', Roboto, sans-serif;
                color: #1e293b;
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
                padding: 24px;
            }

            /* ==== BUTTONS ==== */
            .btn-action {
                border-radius: 50px;
                font-weight: 500;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 8px 18px;
                transition: all 0.2s ease-in-out;
            }

            .btn-action:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            }

            /* Primary */
            .btn-action-primary {
                background: linear-gradient(45deg,#0d6efd,#0dcaf0);
                color: #fff;
                border: none;
            }
            .btn-action-primary:hover {
                background: linear-gradient(45deg,#0b5ed7,#0bb3e6);
            }

            /* Success */
            .btn-action-success {
                background: linear-gradient(45deg,#198754,#20c997);
                color: #fff;
                border: none;
            }
            .btn-action-success:hover {
                background: linear-gradient(45deg,#157347,#17a589);
            }

            /* ==== CHARTS ==== */
            .chart-box {
                background: #fff;
                border-radius: 14px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.06);
                padding: 20px;
                transition: transform 0.2s ease;
            }
            .chart-box:hover {
                transform: translateY(-3px);
            }

            /* ==== TABLE ==== */
            .table-hover tbody tr:hover {
                background: #f1f5f9;
            }
            .table .badge {
                font-size: 0.95rem;
                padding: 6px 10px;
                border-radius: 20px;
            }

            /* ==== MODAL ==== */
            .modal-content {
                border-radius: 16px;
                box-shadow: 0 6px 20px rgba(0,0,0,0.2);
                animation: fadeIn 0.3s ease;
            }
            .modal-header, .modal-footer {
                border-color: #f1f5f9;
            }
            .form-control, .form-select {
                border-radius: 10px;
            }

            /* ==== ANIMATION ==== */
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* ==== FILTER BAR STYLING ==== */
            .card.border-light {
                border-color: #e9ecef !important;
                background-color: #f8f9fa;
            }

            .form-label.fw-semibold {
                font-size: 0.9rem;
                color: #495057;
                margin-bottom: 0.5rem;
            }

            #keywordFilter, #phongBanFilter, #dateRangeFilter, #keywordProjectFilter {
                border-color: #ced4da;
                transition: border-color 0.3s, box-shadow 0.3s;
            }

            #keywordFilter:focus, #phongBanFilter:focus, #dateRangeFilter:focus, #keywordProjectFilter:focus {
                border-color: #0d6efd;
                box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25);
            }

            #resetFilter {
                padding: 0.35rem 0.75rem;
                font-size: 0.875rem;
                white-space: nowrap;
            }

            /* ==== PROJECT CARD & STATUS BOX ==== */
            .project-card {
                transition: all 0.3s ease;
            }

            .project-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 16px rgba(0,0,0,0.15) !important;
            }

            .status-box .hover-lift {
                transition: all 0.3s ease;
            }

            .status-box:hover .hover-lift {
                transform: translateY(-4px);
                box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
            }

            /* ==== DATE RANGE PICKER ==== */
            #dateRangeFilter {
                cursor: pointer;
                background-color: #fff;
            }

            .daterangepicker {
                border-radius: 12px !important;
                box-shadow: 0 6px 20px rgba(0,0,0,0.15) !important;
            }

            .daterangepicker .calendar-table {
                border-radius: 8px;
            }

            .daterangepicker td.active,
            .daterangepicker td.active:hover {
                background-color: #0d6efd !important;
            }

            .daterangepicker td.in-range {
                background-color: rgba(13, 110, 253, 0.1) !important;
            }

            .daterangepicker .ranges li:hover {
                background-color: #f8f9fa;
            }

            .daterangepicker .ranges li.active {
                background-color: #0d6efd;
                color: white;
            }

            @media (max-width: 991.98px) {
                .main-content {
                    margin-left: 70px !important;
                    padding: 16px;
                }

                /* Nếu sidebar đang là dạng fixed hoặc width lớn */
                .sidebar {
                    width: 70px !important; /* hoặc 0 nếu muốn ẩn */
                }

                .card.border-light {
                    margin-bottom: 1rem !important;
                }
            }
        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-tasks me-2"></i>Báo cáo tổng hợp';
        </script>
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
                            <h3 class="mb-0"><i class="fa-solid fa-chart-bar me-2"></i>Báo cáo tổng hợp</h3>
                            <div>
                                <button class="btn btn-action btn-action-primary me-2" id="refreshData">
                                    <i class="fa-solid fa-refresh"></i> Làm mới
                                </button>
                                <button class="btn btn-action btn-action-success" data-bs-toggle="modal"
                                        data-bs-target="#modalExportReport">
                                    <i class="fa-solid fa-file-export"></i> Xuất báo cáo
                                </button>
                            </div>
                        </div>
                        <!-- Bộ lọc báo cáo -->
                        <div class="card border-light shadow-sm mb-4">
                            <div class="card-body">
                                <div class="row g-3 align-items-end">
                                    <div class="col-12 col-md-4 col-lg-3">
                                        <label class="form-label fw-semibold text-secondary">
                                            <i class="fa-solid fa-magnifying-glass me-2"></i>Tìm kiếm
                                        </label>
                                        <input type="text" class="form-control form-control-sm" id="keywordFilter"
                                               placeholder="Tìm nhân viên, dự án, phòng ban..."">
                                    </div>
                                    <div class="col-12 col-md-4 col-lg-3">
                                        <label class="form-label fw-semibold text-secondary">
                                            <i class="fa-solid fa-building me-2"></i>Phòng ban
                                        </label>
                                        <select class="form-select form-select-sm" id="phongBanFilter">
                                            <option value="">— Tất cả phòng ban —</option>
                                            <%
                                                for (Map<String, Object> pb : danhSachPhongBan) {
                                                    String id = String.valueOf(pb.get("id"));
                                                    String tenPhong = (String) pb.get("ten_phong");
                                                    String selected = "";
                                                    if (phongBanParam != null && phongBanParam.equals(id)) {
                                                        selected = "selected";
                                                    }
                                            %>
                                            <option value="<%= id %>" <%= selected %>><%= tenPhong %></option>
                                            <%
                                                }
                                            %>
                                        </select>
                                    </div>
                                    <div class="col-12 col-md-4 col-lg-4">
                                        <label class="form-label fw-semibold text-secondary">
                                            <i class="fa-solid fa-calendar-range me-2"></i>Khoảng thời gian
                                        </label>
                                        <input type="text" class="form-control form-control-sm" id="dateRangeFilter" 
                                               placeholder="Chọn từ ngày - đến ngày" 
                                               value="<%= displayDateRange %>" readonly>
                                        <input type="hidden" id="tuNgayHidden" value="<%= tuNgayParam != null ? tuNgayParam : "" %>">
                                        <input type="hidden" id="denNgayHidden" value="<%= denNgayParam != null ? denNgayParam : "" %>">
                                    </div>
                                    <div class="col-12 col-lg-2">
                                        <button type="button" class="btn btn-sm btn-outline-primary w-100" id="resetFilter">
                                            <i class="fa-solid fa-arrow-rotate-right me-1"></i>Đặt lại
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row g-4">
                            <div class="col-md-6">
                                <div class="chart-box">
                                    <h6 class="mb-3"><i class="fa-solid fa-chart-pie me-2 text-primary"></i>Pie
                                        Chart: Trạng thái công việc</h6>
                                    <canvas id="pieChart"></canvas>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="chart-box">
                                    <h6 class="mb-3"><i class="fa-solid fa-chart-bar me-2 text-success"></i>Bar
                                        Chart: Tiến độ phòng ban</h6>
                                    <canvas id="barChart"></canvas>
                                </div>
                            </div>
                        </div>

                        <!-- Tabs phân chia báo cáo -->
                        <ul class="nav nav-tabs mt-4" id="reportTabs" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active" id="nhanvien-tab" data-bs-toggle="tab" data-bs-target="#nhanvien" type="button" role="tab">
                                    <i class="fa-solid fa-users me-2"></i>Báo cáo Nhân viên
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="duan-tab" data-bs-toggle="tab" data-bs-target="#duan" type="button" role="tab">
                                    <i class="fa-solid fa-diagram-project me-2"></i>Báo cáo Dự án
                                </button>
                            </li>
                        </ul>

                        <div class="tab-content mt-3" id="reportTabContent">
                            <!-- Tab Báo cáo Nhân viên -->
                            <div class="tab-pane fade show active" id="nhanvien" role="tabpanel">
                        <div class="table-responsive mt-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5><i class="fa-solid fa-table me-2"></i>Chi tiết báo cáo nhân viên</h5>
                                <small class="text-muted">
                                    Hiển thị <strong><%= baoCaoNhanVien != null ? baoCaoNhanVien.size() : 0 %></strong> nhân viên
                                    - <%= displayDateRange %>
                                </small>
                            </div>
                            <table class="table table-bordered align-middle table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th style="width: 5%">#</th>
                                        <th style="width: 20%">Nhân viên</th>
                                        <th style="width: 15%">Phòng ban</th>
                                        <th style="width: 10%">Số task</th>
                                        <th style="width: 12%">Đã hoàn thành</th>
                                        <th style="width: 12%">Đang thực hiện</th>
                                        <th style="width: 10%">Trễ hạn</th>
                                        <th style="width: 10%">Chưa bắt đầu</th>
                                    </tr>
                                </thead>
                                <tbody id="reportTableBody">
                                    <%
                                    if (baoCaoNhanVien != null && !baoCaoNhanVien.isEmpty()) {
                                        int stt = 1;
                                        for (Map<String, Object> nv : baoCaoNhanVien) {
                                            // Tính tỷ lệ hoàn thành
                                            int soTask = nv.get("so_task") != null ? (Integer)nv.get("so_task") : 0;
                                            int daHoanThanh = nv.get("da_hoan_thanh") != null ? (Integer)nv.get("da_hoan_thanh") : 0;
                                            int dangThucHien = nv.get("dang_thuc_hien") != null ? (Integer)nv.get("dang_thuc_hien") : 0;
                                            int treHan = nv.get("tre_han") != null ? (Integer)nv.get("tre_han") : 0;
                                                
                                            String tyLeHoanThanh = soTask > 0 ? 
                                                String.format("%.1f%%", (double)daHoanThanh * 100 / soTask) : "0%";
                                    %>
                                    <tr>
                                        <td class="text-center"><%= stt++ %></td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <img src="<%= nv.get("avatar_url") %>"
                                                     class="rounded-circle me-2" width="36">
                                                <strong><%= nv.get("ho_ten") != null ? nv.get("ho_ten") : "N/A" %></strong>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge bg-light text-dark">
                                                <%= nv.get("ten_phong") != null ? nv.get("ten_phong") : "N/A" %>
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-primary"><%= soTask %></span>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-success task-detail"
                                                  data-nvid="<%= nv.get("id") %>"
                                                  data-tennv="<%= nv.get("ho_ten") %>"
                                                  data-status="Đã hoàn thành"
                                                  data-sotask="<%= daHoanThanh %>"><%= daHoanThanh %></span>

                                            <small class="d-block text-muted"><%= tyLeHoanThanh %></small>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-warning task-detail"
                                                  data-nvid="<%= nv.get("id") %>"
                                                  data-tennv="<%= nv.get("ho_ten") %>"
                                                  data-status="Đang thực hiện"
                                                  data-sotask="<%= dangThucHien %>"><%= dangThucHien %></span>

                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-danger task-detail"
                                                  data-nvid="<%= nv.get("id") %>"
                                                  data-tennv="<%= nv.get("ho_ten") %>"
                                                  data-status="Trễ hạn"
                                                  data-sotask="<%= treHan %>"><%= treHan %></span>

                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-secondary task-detail"
                                                  data-nvid="<%= nv.get("id") %>"
                                                  data-tennv="<%= nv.get("ho_ten") %>"
                                                  data-status="Chưa bắt đầu"
                                                  data-sotask="<%= nv.get("chua_bat_dau") != null ? nv.get("chua_bat_dau") : 0 %>"><%= nv.get("chua_bat_dau") != null ? nv.get("chua_bat_dau") : 0 %></span>                                 
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <tr>
                                        <td colspan="9" class="text-center py-5">
                                            <i class="fa-solid fa-inbox fa-3x text-muted mb-3"></i>
                                            <br>
                                            <span class="text-muted">Không có dữ liệu báo cáo cho thời gian đã chọn</span>
                                            <br>
                                            <small class="text-muted">Vui lòng chọn tháng/năm khác hoặc thêm dữ liệu</small>
                                        </td>
                                    </tr>
                                    <%
                                    }
                                    %>
                                </tbody>
                            </table>
                        </div>
                            </div>
                            <!-- End Tab Báo cáo Nhân viên -->

                            <!-- Tab Báo cáo Dự án -->
                            <div class="tab-pane fade" id="duan" role="tabpanel">
                                <div class="mb-3">
                                    <small class="text-muted">
                                        Hiển thị <strong><%= baoCaoDuAn != null ? baoCaoDuAn.size() : 0 %></strong> dự án - <%= displayDateRange %>
                                    </small>
                                </div>
                                        </button>
                                    </div>
                                </div>

                            <!-- Báo cáo chi tiết dự án -->
                        <div class="mt-3">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5><i class="fa-solid fa-diagram-project me-2 text-primary"></i>Chi tiết báo cáo dự án</h5>
                                <small class="text-muted">
                                    Hiển thị <strong><%= baoCaoDuAn != null ? baoCaoDuAn.size() : 0 %></strong> dự án
                                    - <%= displayDateRange %>
                                </small>
                            </div>

                            <!-- Filter dự án -->
                            <div class="mb-3">
                                <input type="text" class="form-control form-control-sm" id="keywordProjectFilter"
                                       placeholder="🔍 Tìm kiếm theo tên dự án hoặc leader...">
                            </div>

                            <%
                            if (baoCaoDuAn != null && !baoCaoDuAn.isEmpty()) {
                                for (Map<String, Object> da : baoCaoDuAn) {
                                    String tenDuAn = (String) da.get("ten_du_an");
                                    String trangThaiDuAn = (String) da.get("trang_thai_duan");
                                    String nhomDuAn = (String) da.get("nhom_du_an");
                                    String phongBanDA = (String) da.get("phong_ban");
                                    String leadName = (String) da.get("lead_name");
                                    String mucDoUuTien = (String) da.get("muc_do_uu_tien");
                                    Double tienDo = (Double) da.get("tien_do");
                                    
                                    int tongCV = (Integer) da.get("tong_cong_viec");
                                    int cvHoanThanh = (Integer) da.get("cv_hoan_thanh");
                                    int cvDangThucHien = (Integer) da.get("cv_dang_thuc_hien");
                                    int cvTreHan = (Integer) da.get("cv_tre_han");
                                    int cvChuaBatDau = (Integer) da.get("cv_chua_bat_dau");
                                    int cvQuaHan = (Integer) da.get("cv_qua_han");
                                    int cvSapHetHan = (Integer) da.get("cv_sap_het_han");
                                    
                                    java.sql.Date ngayKetThuc = (java.sql.Date) da.get("ngay_ket_thuc");
                                    
                                    // Xác định màu badge theo trạng thái
                                    String statusBadgeClass = "";
                                    if ("Đang thực hiện".equals(trangThaiDuAn)) statusBadgeClass = "bg-info";
                                    else if ("Đã hoàn thành".equals(trangThaiDuAn)) statusBadgeClass = "bg-success";
                                    else if ("Tạm ngưng".equals(trangThaiDuAn)) statusBadgeClass = "bg-warning";
                                    else statusBadgeClass = "bg-secondary";
                                    
                                    // Màu progress bar
                                    String progressColor = "";
                                    if (tienDo >= 80) progressColor = "bg-success";
                                    else if (tienDo >= 50) progressColor = "bg-info";
                                    else if (tienDo >= 30) progressColor = "bg-warning";
                                    else progressColor = "bg-danger";
                                    
                                    // Icon cảnh báo
                                    String alertIcon = "";
                                    String alertClass = "";
                                    if (cvQuaHan > 0) {
                                        alertIcon = "<i class='fa-solid fa-triangle-exclamation text-danger'></i>";
                                        alertClass = "border-danger";
                                    } else if (cvSapHetHan > 0) {
                                        alertIcon = "<i class='fa-solid fa-clock text-warning'></i>";
                                        alertClass = "border-warning";
                                    }
                            %>
                            <div class="card mb-3 shadow-sm <%= alertClass %> project-card" 
                                 data-project-name="<%= tenDuAn %>"
                                 data-project-lead="<%= leadName != null ? leadName : "" %>"
                                 style="border-left: 4px solid; cursor: pointer;">
                                <div class="card-body">
                                    <div class="row align-items-center">
                                        <!-- Cột 1: Thông tin dự án -->
                                        <div class="col-md-5">
                                            <h6 class="mb-2">
                                                <%= alertIcon %>
                                                <strong><%= tenDuAn %></strong>
                                                <span class="badge <%= statusBadgeClass %> ms-2"><%= trangThaiDuAn %></span>
                                            </h6>
                                            <div class="small text-muted mb-2">
                                                <span class="me-3">
                                                    <i class="fa-solid fa-layer-group"></i> <%= nhomDuAn %>
                                                </span>
                                                <span class="me-3">
                                                    <i class="fa-solid fa-building"></i> <%= phongBanDA %>
                                                </span>
                                                <% if (leadName != null) { %>
                                                <span>
                                                    <i class="fa-solid fa-user-tie"></i> <%= leadName %>
                                                </span>
                                                <% } %>
                                            </div>
                                            <% if (ngayKetThuc != null) { %>
                                            <div class="small">
                                                <i class="fa-solid fa-calendar-days"></i>
                                                Deadline: <strong><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(ngayKetThuc) %></strong>
                                            </div>
                                            <% } %>
                                        </div>

                                        <!-- Cột 2: Tiến độ -->
                                        <div class="col-md-3">
                                            <div class="text-center">
                                                <div class="mb-2">
                                                    <span class="badge bg-light text-dark fs-5"><%= String.format("%.0f", tienDo) %>%</span>
                                                </div>
                                                <div class="progress" style="height: 20px;">
                                                    <div class="progress-bar <%= progressColor %> progress-bar-striped" 
                                                         role="progressbar" 
                                                         style="width: <%= tienDo %>%" 
                                                         aria-valuenow="<%= tienDo %>" 
                                                         aria-valuemin="0" 
                                                         aria-valuemax="100">
                                                        <%= String.format("%.0f", tienDo) %>%
                                                    </div>
                                                </div>
                                                <small class="text-muted"><%= cvHoanThanh %>/<%= tongCV %> công việc</small>
                                            </div>
                                        </div>

                                        <!-- Cột 3: Thống kê công việc - Clickable -->
                                        <div class="col-md-4">
                                            <div class="row g-2 text-center">
                                                <div class="col-6 status-box" 
                                                     data-project="<%= tenDuAn %>"
                                                     data-status="Đã hoàn thành"
                                                     data-count="<%= cvHoanThanh %>"
                                                     data-bs-toggle="tooltip" 
                                                     title="Nhấp để xem chi tiết"
                                                     style="cursor: pointer;">
                                                    <div class="border rounded p-2 hover-lift" style="background: rgba(40, 167, 69, 0.05); border-color: #28a745; transition: all 0.3s;">
                                                        <div class="text-success fs-5"><strong><%= cvHoanThanh %></strong></div>
                                                        <small class="text-muted">Hoàn thành</small>
                                                    </div>
                                                </div>
                                                <div class="col-6 status-box" 
                                                     data-project="<%= tenDuAn %>"
                                                     data-status="Đang thực hiện"
                                                     data-count="<%= cvDangThucHien %>"
                                                     data-bs-toggle="tooltip" 
                                                     title="Nhấp để xem chi tiết"
                                                     style="cursor: pointer;">
                                                    <div class="border rounded p-2 hover-lift" style="background: rgba(23, 162, 184, 0.05); border-color: #17a2b8; transition: all 0.3s;">
                                                        <div class="text-info fs-5"><strong><%= cvDangThucHien %></strong></div>
                                                        <small class="text-muted">Đang làm</small>
                                                    </div>
                                                </div>
                                                <div class="col-6 status-box" 
                                                     data-project="<%= tenDuAn %>"
                                                     data-status="Quá hạn"
                                                     data-count="<%= cvQuaHan %>"
                                                     data-bs-toggle="tooltip" 
                                                     title="Nhấp để xem chi tiết"
                                                     style="cursor: pointer;">
                                                    <div class="border rounded p-2 hover-lift" style="background: rgba(220, 53, 69, 0.05); border-color: #dc3545; transition: all 0.3s;">
                                                        <div class="text-danger fs-5"><strong><%= cvQuaHan %></strong></div>
                                                        <small class="text-muted">Quá hạn</small>
                                                    </div>
                                                </div>
                                                <div class="col-6 status-box" 
                                                     data-project="<%= tenDuAn %>"
                                                     data-status="Chưa bắt đầu"
                                                     data-count="<%= cvChuaBatDau %>"
                                                     data-bs-toggle="tooltip" 
                                                     title="Nhấp để xem chi tiết"
                                                     style="cursor: pointer;">
                                                    <div class="border rounded p-2 hover-lift" style="background: rgba(108, 117, 125, 0.05); border-color: #6c757d; transition: all 0.3s;">
                                                        <div class="text-secondary fs-5"><strong><%= cvChuaBatDau %></strong></div>
                                                        <small class="text-muted">Chưa bắt đầu</small>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Hiển thị cảnh báo nếu có vấn đề -->
                                    <% if (cvQuaHan > 0 || cvSapHetHan > 0) { %>
                                    <div class="alert alert-<%= cvQuaHan > 0 ? "danger" : "warning" %> mt-3 mb-0 py-2">
                                        <small>
                                            <i class="fa-solid fa-exclamation-circle"></i>
                                            <strong>Cần chú ý:</strong>
                                            <% if (cvQuaHan > 0) { %>
                                                <%= cvQuaHan %> công việc đã quá hạn!
                                            <% } %>
                                            <% if (cvSapHetHan > 0) { %>
                                                <%= cvSapHetHan %> công việc sắp hết hạn (trong 3 ngày tới)!
                                            <% } %>
                                        </small>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                            <%
                                }
                            } else {
                            %>
                            <div class="text-center py-5 bg-light rounded">
                                <i class="fa-solid fa-folder-open fa-3x text-muted mb-3"></i>
                                <br>
                                <span class="text-muted">Không có dữ liệu báo cáo dự án cho thời gian đã chọn</span>
                                <br>
                                <small class="text-muted">Vui lòng chọn khoảng thời gian khác</small>
                            </div>
                            <%
                            }
                            %>
                        </div>
                            </div>
                            <!-- End Tab Báo cáo Dự án -->
                        </div>
                        <!-- End Tab Content -->

                        <!-- Modal xuất báo cáo nhân viên -->
                        <div class="modal fade" id="modalExportReport" tabindex="-1">
                            <div class="modal-dialog modal-lg">
                                <form class="modal-content" id="formExportReport" action="./exportReport" method="post">
                                    <input type="hidden" name="reportType" id="reportTypeInput" value="summary">
                                    <div class="modal-header bg-primary text-white">
                                        <h5 class="modal-title"><i class="fa-solid fa-file-export me-2"></i>Xuất báo cáo tổng hợp</h5>
                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                    </div>

                                    <div class="modal-body">
                                        <!-- Chọn loại báo cáo -->
                                        <div class="mb-3">
                                            <label class="form-label fw-bold">
                                                <i class="fa-solid fa-clipboard-list me-1"></i>Chọn loại báo cáo
                                            </label>
                                            <select class="form-select" id="reportTypeSelector" required>
                                                <option value="summary">Báo cáo Nhân viên</option>
                                                <option value="project">Báo cáo Dự án</option>
                                            </select>
                                        </div>

                                        <div class="mb-3">
                                            <label class="form-label fw-bold">
                                                <i class="fa-solid fa-file-alt me-1"></i>Chọn định dạng
                                            </label>
                                            <select class="form-select" name="exportType" required>
                                                <option value="Excel">Excel (.xlsx) - Phù hợp với phân tích dữ liệu</option>
                                                <option value="PDF">PDF (.pdf) - Phù hợp với in ấn, trình bày</option>
                                            </select>
                                        </div>

                                        <!-- Trường cho báo cáo nhân viên -->
                                        <div id="employeeReportFields">
                                            <div class="mb-3">
                                                <label class="form-label fw-bold">
                                                    <i class="fa-solid fa-building me-1"></i>Chọn phòng ban
                                                </label>
                                                <select class="form-select" name="departmentTask">
                                                    <option value="">Tất cả phòng ban</option>
                                                    <% for (Map<String, Object> pb : danhSachPhongBan) { %>
                                                    <option value="<%= pb.get("id") %>"><%= pb.get("ten_phong") %></option>
                                                    <% } %>
                                                </select>
                                            </div>
                                        </div>

                                        <!-- Trường cho báo cáo dự án -->
                                        <div id="projectReportFields" style="display: none;">
                                            <div class="alert alert-info">
                                                <i class="fa-solid fa-info-circle me-2"></i>
                                                Báo cáo sẽ bao gồm: <strong>Dự án, Leader, Công việc, Người nhận, Trạng thái, Hạn hoàn thành</strong>
                                            </div>
                                            
                                            <div class="mb-3">
                                                <label class="form-label fw-bold">
                                                    <i class="fa-solid fa-building me-1"></i>Chọn phòng ban
                                                </label>
                                                <select class="form-select" name="departmentProject">
                                                    <option value="">Tất cả phòng ban</option>
                                                    <% for (Map<String, Object> pb : danhSachPhongBan) { %>
                                                    <option value="<%= pb.get("ten_phong") %>"><%= pb.get("ten_phong") %></option>
                                                    <% } %>
                                                </select>
                                            </div>

                                            <div class="mb-3">
                                                <label class="form-label fw-bold">
                                                    <i class="fa-solid fa-filter me-1"></i>Lọc theo trạng thái dự án
                                                </label>
                                                <select class="form-select" name="projectStatus">
                                                    <option value="">Tất cả trạng thái</option>
                                                    <option value="Đang thực hiện">Đang thực hiện</option>
                                                    <option value="Tạm ngưng">Tạm ngưng</option>
                                                    <option value="Đã hoàn thành">Đã hoàn thành</option>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="mb-3">
                                            <label class="form-label fw-bold">
                                                <i class="fa-solid fa-calendar me-1"></i>Chọn khoảng thời gian
                                            </label>
                                            <input type="text" class="form-control" id="dateRangeExport" 
                                                   placeholder="Chọn từ ngày - đến ngày" readonly required>
                                            <input type="hidden" id="exportTuNgay" name="tu_ngay">
                                            <input type="hidden" id="exportDenNgay" name="den_ngay">
                                        </div>
                                    </div>

                                    <div class="modal-footer">
                                        <button type="submit" class="btn btn-primary rounded-pill">
                                            <i class="fa-solid fa-download me-1"></i>Xuất báo cáo
                                        </button>
                                        <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
                                    </div>
                                </form>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <!-- Modal chi tiết công việc theo trạng thái dự án -->
        <div class="modal fade" id="modalProjectTaskDetail" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title">
                            <i class="fa-solid fa-list-check me-2"></i>
                            <span id="projectDetailTitle">Chi tiết công việc</span>
                        </h5>
                        <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <strong>Dự án:</strong> <span id="projectName" class="badge bg-info"></span>
                            <strong class="ms-3">Trạng thái:</strong> <span id="projectTaskStatus" class="badge"></span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-sm table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th><i class="fa-solid fa-hashtag"></i> STT</th>
                                        <th><i class="fa-solid fa-tasks"></i> Tên công việc</th>
                                        <th><i class="fa-solid fa-user"></i> Người nhận</th>
                                        <th><i class="fa-solid fa-calendar"></i> Ngày bắt đầu</th>
                                        <th><i class="fa-solid fa-hourglass-end"></i> Hạn hoàn thành</th>
                                        <th><i class="fa-solid fa-check-circle"></i> Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody id="projectTaskTableBody">
                                    <tr><td colspan="6" class="text-center text-muted py-3">Đang tải dữ liệu...</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal detail Task cũ (cho nhân viên) -->
        <div class="modal fade" id="modalTaskDetail" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Danh sách công việc</h5>
                        <button class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p><strong>Nhân viên:</strong> <span id="modalTenNV"></span></p>
                        <p><strong>Trạng thái:</strong> <span id="modalTrangThai"></span></p>

                        <table class="table table-bordered">
                            <thead>
                                <tr>
                                    <th>Tên công việc</th>
                                    <th>Tên dự án</th>
                                    <th>Ngày bắt đầu</th>
                                    <th>Hạn</th>
                                    <th>Ngày hoàn thành</th>
                                </tr>
                            </thead>
                            <tbody id="modalTaskTable">
                                <tr><td colspan="3" class="text-center text-muted">Đang tải...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <script>
            // Dữ liệu từ backend
            <%
            // Tạo dữ liệu JSON trực tiếp trong JSP
            out.println("var pieChartData = " + pieChartJson + ";");
            out.println("var barChartData = " + barChartJson + ";");
            %>
        </script>
        <script>
            const USER_PERMISSIONS = <%= session.getAttribute("quyen") %>;
        </script>
        <script src="<%= request.getContextPath() %>/scripts/report.js?v=<%= System.currentTimeMillis() %>"></script>
    </body>
</html>