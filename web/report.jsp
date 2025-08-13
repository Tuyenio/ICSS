<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="controller.apiBaoCao" %>
<%@ page import="controller.KNCSDL" %>
<%
    // Lấy tham số từ request
    String thangParam = request.getParameter("thang");
    String namParam = request.getParameter("nam");
    String phongBanParam = request.getParameter("phong_ban");
    
    // Nếu không có tham số, sử dụng tháng hiện tại
    if (thangParam == null || thangParam.isEmpty()) {
        Calendar cal = Calendar.getInstance();
        thangParam = String.valueOf(cal.get(Calendar.MONTH) + 1);
        namParam = String.valueOf(cal.get(Calendar.YEAR));
    }
    
    // Lấy dữ liệu báo cáo
    List<Map<String, Object>> baoCaoNhanVien = apiBaoCao.getBaoCaoNhanVien(thangParam, namParam, phongBanParam);
    Map<String, Object> pieChartData = apiBaoCao.getDataForPieChart();
    Map<String, Object> barChartData = apiBaoCao.getDataForBarChart();
    
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
        <title>Báo cáo tổng hợp</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
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

            .filter-row .form-select,
            .filter-row .form-control {
                border-radius: 20px;
            }

            .chart-box {
                background: #f8fafc;
                border-radius: 12px;
                box-shadow: 0 1px 8px #0001;
                padding: 18px 20px;
            }

            @media (max-width: 768px) {
                .main-box {
                    padding: 10px 2px;
                }

                .main-content {
                    padding: 10px 2px;
                }
            }
        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-chart-bar me-2"></i>Báo cáo tổng hợp';
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
                        <a href="./dsChamCong"><i class="fa-solid fa-calendar-check"></i><span>Chấm công</span></a>
                    </li>
                    <li>
                        <a href="report.jsp" class="active"><i class="fa-solid fa-chart-bar"></i><span>Báo
                                cáo</span></a>
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
                                <h3 class="mb-0"><i class="fa-solid fa-chart-bar me-2"></i>Báo cáo tổng hợp</h3>
                                <div>
                                    <button class="btn btn-outline-primary rounded-pill px-3 me-2" id="refreshData">
                                        <i class="fa-solid fa-refresh"></i> Làm mới
                                    </button>
                                    <button class="btn btn-outline-success rounded-pill px-3" data-bs-toggle="modal"
                                        data-bs-target="#modalExportReport">
                                        <i class="fa-solid fa-file-export"></i> Xuất báo cáo
                                    </button>
                                </div>
                            </div>
                            <div class="row mb-3 filter-row g-2">
                                <div class="col-md-3">
                                    <input type="text" class="form-control" id="keywordFilter"
                                        placeholder="Tìm kiếm theo tên, phòng ban...">
                                </div>
                                <div class="col-md-3">
                                    <select class="form-select" id="phongBanFilter">
                                        <option value="">Tất cả phòng ban</option>
                                        <%
                                        for (Map<String, Object> pb : danhSachPhongBan) {
                                            String selected = "";
                                            if (phongBanParam != null && phongBanParam.equals(pb.get("ten_phong"))) {
                                                selected = "selected";
                                            }
                                        %>
                                        <option value="<%= pb.get("ten_phong") %>" <%= selected %>><%= pb.get("ten_phong") %></option>
                                        <%
                                        }
                                        %>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <select class="form-select" id="trangThaiFilter">
                                        <option>Tất cả trạng thái</option>
                                        <option value="DangThucHien">Đang thực hiện</option>
                                        <option value="DaHoanThanh">Đã hoàn thành</option>
                                        <option value="TreHan">Trễ hạn</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <input type="month" class="form-control" id="thangFilter" 
                                           value="<%= namParam %>-<%= String.format("%02d", Integer.parseInt(thangParam)) %>">
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
                            <div class="table-responsive mt-4">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5><i class="fa-solid fa-table me-2"></i>Chi tiết báo cáo nhân viên</h5>
                                    <small class="text-muted">
                                        Hiển thị <%= baoCaoNhanVien != null ? baoCaoNhanVien.size() : 0 %> nhân viên
                                        <%= thangParam != null ? "- Tháng " + thangParam + "/" + namParam : "" %>
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
                                            <th style="width: 10%">KPI</th>
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
                                                    <img src="https://i.pravatar.cc/32?img=<%= stt %>" 
                                                         class="rounded-circle me-2" width="32" height="32">
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
                                                <span class="badge bg-success"><%= daHoanThanh %></span>
                                                <small class="d-block text-muted"><%= tyLeHoanThanh %></small>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge bg-warning"><%= dangThucHien %></span>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge bg-danger"><%= treHan %></span>
                                            </td>
                                            <td class="text-center">
                                                <%
                                                Object kpi = nv.get("diem_kpi");
                                                if (kpi != null && !kpi.toString().equals("null")) {
                                                    double kpiValue = Double.parseDouble(kpi.toString());
                                                    String kpiClass = "bg-secondary";
                                                    if (kpiValue >= 9.0) kpiClass = "bg-success";
                                                    else if (kpiValue >= 7.0) kpiClass = "bg-primary";
                                                    else if (kpiValue >= 5.0) kpiClass = "bg-warning";
                                                    else if (kpiValue > 0) kpiClass = "bg-danger";
                                                %>
                                                <span class="badge <%= kpiClass %>"><%= String.format("%.1f", kpiValue) %></span>
                                                <%
                                                } else {
                                                %>
                                                <span class="badge bg-secondary">N/A</span>
                                                <%
                                                }
                                                %>
                                            </td>
                                        </tr>
                                        <%
                                            }
                                        } else {
                                        %>
                                        <tr>
                                            <td colspan="8" class="text-center py-5">
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
                            <!-- Modal xuất báo cáo với tab -->
                            <div class="modal fade" id="modalExportReport" tabindex="-1">
                                <div class="modal-dialog">
                                    <form class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title"><i class="fa-solid fa-file-export"></i> Xuất báo cáo
                                            </h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <ul class="nav nav-tabs mb-3" id="reportExportTab" role="tablist">
                                                <li class="nav-item" role="presentation">
                                                    <button class="nav-link active" id="tab-export-summary"
                                                        data-bs-toggle="tab" data-bs-target="#tabExportSummary"
                                                        type="button" role="tab">Tổng hợp</button>
                                                </li>
                                                <li class="nav-item" role="presentation">
                                                    <button class="nav-link" id="tab-export-kpi" data-bs-toggle="tab"
                                                        data-bs-target="#tabExportKPI" type="button"
                                                        role="tab">KPI</button>
                                                </li>
                                                <li class="nav-item" role="presentation">
                                                    <button class="nav-link" id="tab-export-task" data-bs-toggle="tab"
                                                        data-bs-target="#tabExportTask" type="button" role="tab">Công
                                                        việc</button>
                                                </li>
                                            </ul>
                                            <div class="tab-content" id="reportExportTabContent">
                                                <div class="tab-pane fade show active" id="tabExportSummary"
                                                    role="tabpanel">
                                                    <div class="mb-3">
                                                        <label class="form-label">Chọn định dạng</label>
                                                        <select class="form-select" name="exportType">
                                                            <option value="Excel">Excel (.xlsx)</option>
                                                            <option value="PDF">PDF (.pdf)</option>
                                                        </select>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">Khoảng thời gian</label>
                                                        <input type="date" class="form-control mb-2" name="fromDate"
                                                            placeholder="Từ ngày">
                                                        <input type="date" class="form-control" name="toDate"
                                                            placeholder="Đến ngày">
                                                    </div>
                                                </div>
                                                <div class="tab-pane fade" id="tabExportKPI" role="tabpanel">
                                                    <div class="mb-3">
                                                        <label class="form-label">Chọn nhân viên</label>
                                                        <select class="form-select" name="employeeKPI">
                                                            <option value="">Tất cả nhân viên</option>
                                                            <%
                                                            try {
                                                                KNCSDL kn2 = new KNCSDL();
                                                                java.sql.ResultSet rsNV = kn2.layNhanVien();
                                                                while (rsNV.next()) {
                                                            %>
                                                            <option value="<%= rsNV.getInt("id") %>"><%= rsNV.getString("ho_ten") %></option>
                                                            <%
                                                                }
                                                                rsNV.close();
                                                            } catch (Exception e) {
                                                                e.printStackTrace();
                                                            }
                                                            %>
                                                        </select>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">Tháng/Năm</label>
                                                        <input type="month" class="form-control" name="monthKPI">
                                                    </div>
                                                </div>
                                                <div class="tab-pane fade" id="tabExportTask" role="tabpanel">
                                                    <div class="mb-3">
                                                        <label class="form-label">Chọn phòng ban</label>
                                                        <select class="form-select" name="departmentTask">
                                                            <option value="">Tất cả phòng ban</option>
                                                            <%
                                                            for (Map<String, Object> pb : danhSachPhongBan) {
                                                            %>
                                                            <option value="<%= pb.get("ten_phong") %>"><%= pb.get("ten_phong") %></option>
                                                            <%
                                                            }
                                                            %>
                                                        </select>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">Trạng thái công việc</label>
                                                        <select class="form-select" name="taskStatus">
                                                            <option value="DangThucHien">Đang thực hiện</option>
                                                            <option value="DaHoanThanh">Đã hoàn thành</option>
                                                            <option value="TreHan">Trễ hạn</option>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="submit" class="btn btn-primary rounded-pill">Xuất
                                                file</button>
                                            <button type="button" class="btn btn-secondary rounded-pill"
                                                data-bs-dismiss="modal">Huỷ</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
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
            
            // Debug dữ liệu
            console.log('Pie Chart Data:', pieChartData);
            console.log('Bar Chart Data:', barChartData);
            
            // Chart.js implementation
            $(function () {
                // Pie Chart - Trạng thái công việc
                if (pieChartData && pieChartData.labels && pieChartData.labels.length > 0) {
                    new Chart(document.getElementById('pieChart'), {
                        type: 'pie',
                        data: {
                            labels: pieChartData.labels,
                            datasets: [{
                                data: pieChartData.data,
                                backgroundColor: ['#198754', '#ffc107', '#dc3545', '#0d6efd']
                            }]
                        },
                        options: { 
                            responsive: true,
                            plugins: {
                                legend: {
                                    position: 'bottom'
                                }
                            }
                        }
                    });
                } else {
                    // Hiển thị thông báo khi không có dữ liệu
                    document.getElementById('pieChart').parentElement.innerHTML = 
                        '<div class="text-center p-4"><i class="fa-solid fa-chart-pie fa-3x text-muted mb-3"></i><br><span class="text-muted">Không có dữ liệu để hiển thị</span></div>';
                }
                
                // Bar Chart - Tiến độ phòng ban
                if (barChartData && barChartData.labels && barChartData.labels.length > 0) {
                    new Chart(document.getElementById('barChart'), {
                        type: 'bar',
                        data: {
                            labels: barChartData.labels,
                            datasets: [{
                                label: 'Tiến độ (%)',
                                data: barChartData.data,
                                backgroundColor: ['#0d6efd', '#198754', '#ffc107', '#dc3545', '#6f42c1', '#20c997']
                            }]
                        },
                        options: { 
                            responsive: true, 
                            plugins: { 
                                legend: { display: false } 
                            },
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    max: 100,
                                    ticks: {
                                        callback: function(value) {
                                            return value + '%';
                                        }
                                    }
                                }
                            }
                        }
                    });
                } else {
                    // Hiển thị thông báo khi không có dữ liệu
                    document.getElementById('barChart').parentElement.innerHTML = 
                        '<div class="text-center p-4"><i class="fa-solid fa-chart-bar fa-3x text-muted mb-3"></i><br><span class="text-muted">Không có dữ liệu để hiển thị</span></div>';
                }
            });
            
            // Filter functionality
            $('#thangFilter, #phongBanFilter').change(function() {
                var thang = $('#thangFilter').val();
                var phongBan = $('#phongBanFilter').val();
                
                if (thang) {
                    var parts = thang.split('-');
                    var url = window.location.pathname + '?nam=' + parts[0] + '&thang=' + parseInt(parts[1]);
                    if (phongBan) {
                        url += '&phong_ban=' + encodeURIComponent(phongBan);
                    }
                    window.location.href = url;
                }
            });
            
            // Refresh button functionality
            $('#refreshData').click(function() {
                window.location.reload();
            });
            
            // Xuất báo cáo Excel
            function exportToExcel() {
                var table = document.getElementById('reportTable');
                var workbook = XLSX.utils.table_to_book(table, {sheet: "Báo cáo nhân viên"});
                XLSX.writeFile(workbook, 'bao_cao_nhan_vien_' + new Date().toISOString().slice(0,10) + '.xlsx');
            }
            
            // Xuất báo cáo PDF
            function exportToPDF() {
                window.print();
            }
            
            // Refresh data
            function refreshData() {
                window.location.reload();
            }
            
            // Xuất báo cáo
            $('form.modal-content').submit(function(e) {
                e.preventDefault();
                alert('Chức năng xuất báo cáo đang được phát triển!');
            });
            
            // Enhanced filter table với cập nhật số lượng
            $('#keywordFilter').on('input', function() {
                var keyword = $(this).val().toLowerCase();
                var visibleRows = 0;
                var totalRows = 0;
                
                $('#reportTableBody tr').each(function() {
                    // Bỏ qua các row thông báo "không có dữ liệu"
                    if ($(this).find('td').length < 8) return;
                    
                    totalRows++;
                    var text = $(this).text().toLowerCase();
                    var visible = text.indexOf(keyword) > -1;
                    $(this).toggle(visible);
                    if (visible) visibleRows++;
                });
                
                // Cập nhật số lượng hiển thị
                $('.text-muted strong').text(visibleRows);
                
                // Show/hide "no data" message
                if (visibleRows === 0 && keyword !== '' && totalRows > 0) {
                    if ($('#no-data-row').length === 0) {
                        $('#reportTableBody').append(
                            '<tr id="no-data-row"><td colspan="8" class="text-center text-muted py-4">' +
                            '<i class="fa-solid fa-search fa-2x mb-2"></i><br>' +
                            'Không tìm thấy kết quả cho từ khóa "<strong>' + keyword + '</strong>"</td></tr>'
                        );
                    }
                } else {
                    $('#no-data-row').remove();
                }
            });
            
            // Status filter
            $('#trangThaiFilter').change(function() {
                var selectedStatus = $(this).val();
                if (selectedStatus === 'Tất cả trạng thái') {
                    // Show all rows
                    $('#reportTableBody tr').show();
                } else {
                    // Filter based on status
                    // This would need to be implemented based on your data structure
                    console.log('Status filter not yet implemented for:', selectedStatus);
                }
            });
        </script>
    </body>
    </html>