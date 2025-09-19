<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="controller.apiBaoCao" %>
<%@ page import="controller.KNCSDL" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession ssis = request.getSession();
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
    Map<String, Object> barChartData = apiBaoCao.getDataForBarChart(ssis);
    
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
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Báo cáo tổng hợp</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
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

        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-tasks me-2"></i>Báo cáo tổng hợp';
        </script>
    </head>

    <body>
        <%= "DEBUG: phongBanParam = " + phongBanParam %>
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
                                        String tenPhong = (String) pb.get("ten_phong");
                                        String selected = "";
                                        if (phongBanParam != null && phongBanParam.equals(tenPhong)) {
                                            selected = "selected";
                                        }
                                    %>
                                    <option value="<%= tenPhong %>" <%= selected %>><%= tenPhong %></option>
                                    <% } %>
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
                                            <span class="badge bg-success"><%= daHoanThanh %></span>
                                            <small class="d-block text-muted"><%= tyLeHoanThanh %></small>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-warning"><%= dangThucHien %></span>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-danger"><%= treHan %></span>
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
                                <form class="modal-content" id="formExportReport" action="./exportReport" method="post">
                                    <div class="modal-header">
                                        <h5 class="modal-title"><i class="fa-solid fa-file-export"></i> Xuất báo cáo</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>

                                    <div class="modal-body">
                                        <div class="mb-3">
                                            <label class="form-label">Chọn định dạng</label>
                                            <select class="form-select" name="exportType">
                                                <option value="Excel">Excel (.xlsx)</option>
                                                <option value="PDF">PDF (.pdf)</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Chọn phòng ban</label>
                                            <select class="form-select" name="departmentTask">
                                                <option value="">Tất cả phòng ban</option>
                                                <% for (Map<String, Object> pb : danhSachPhongBan) { %>
                                                <option value="<%= pb.get("ten_phong") %>"><%= pb.get("ten_phong") %></option>
                                                <% } %>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="month" class="form-label">Tháng làm việc</label>
                                            <input type="month" class="form-control" id="month" name="thangNam" required>
                                        </div>
                                    </div>

                                    <div class="modal-footer">
                                        <button type="submit" class="btn btn-primary rounded-pill">Xuất file</button>
                                        <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            // Gắn reportType theo tab đang active & kiểm tra đơn giản
            (function () {
                var form = document.getElementById('formExportReport');
                form.addEventListener('submit', function (e) {
                    var activePane = document.querySelector('#reportExportTabContent .tab-pane.active');
                    var reportType = 'summary';
                    if (activePane && activePane.id === 'tabExportKPI')
                        reportType = 'kpi';
                    if (activePane && activePane.id === 'tabExportTask')
                        reportType = 'task';
                    document.getElementById('reportTypeHidden').value = reportType;

                    // Validate tối thiểu (ví dụ cho Summary)
                    if (reportType === 'summary') {
                        var fromDate = form.querySelector('input[name="fromDate"]').value;
                        var toDate = form.querySelector('input[name="toDate"]').value;
                        if (!fromDate || !toDate) {
                            e.preventDefault();
                            showToast('error', 'Vui lòng chọn đầy đủ khoảng thời gian.');
                            return;
                        }
                    }
                    // KPI có thể kiểm tra monthKPI nếu bạn muốn bắt buộc
                    // Task không bắt buộc (đã có mặc định)
                    // Không dùng AJAX để trình duyệt nhận stream file tải về
                });
            })();

            // Hàm showToast bạn đang dùng (giả sử đã có)
            function showToast(type, message) {
                var map = {success: '#toastSuccess', error: '#toastError', info: '#toastInfo', warning: '#toastWarning'};
                var id = map[type] || '#toastInfo';
                if (!$(id).length) {
                    var html = '<div id="' + id.substring(1) + '" class="toast align-items-center border-0 position-fixed bottom-0 end-0 m-3" role="alert" aria-live="assertive" aria-atomic="true"><div class="d-flex"><div class="toast-body"></div><button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast"></button></div></div>';
                    $('body').append(html);
                }
                $(id).find('.toast-body').text(message);
                new bootstrap.Toast($(id)[0], {delay: 2500, autohide: true}).show();
            }
        </script>
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
                                legend: {display: false}
                            },
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    max: 100,
                                    ticks: {
                                        callback: function (value) {
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
            $('#thangFilter, #phongBanFilter').change(function () {
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
            $('#refreshData').click(function () {
                window.location.reload();
            });

            // Xuất báo cáo Excel
            function exportToExcel() {
                var table = document.getElementById('reportTable');
                var workbook = XLSX.utils.table_to_book(table, {sheet: "Báo cáo nhân viên"});
                XLSX.writeFile(workbook, 'bao_cao_nhan_vien_' + new Date().toISOString().slice(0, 10) + '.xlsx');
            }

            // Xuất báo cáo PDF
            function exportToPDF() {
                window.print();
            }

            // Refresh data
            function refreshData() {
                window.location.reload();
            }

            // Enhanced filter table với cập nhật số lượng
            $('#keywordFilter').on('input', function () {
                var keyword = $(this).val().toLowerCase();
                var visibleRows = 0;
                var totalRows = 0;

                $('#reportTableBody tr').each(function () {
                    // Bỏ qua các row thông báo "không có dữ liệu"
                    if ($(this).find('td').length < 8)
                        return;

                    totalRows++;
                    var text = $(this).text().toLowerCase();
                    var visible = text.indexOf(keyword) > -1;
                    $(this).toggle(visible);
                    if (visible)
                        visibleRows++;
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
            $('#trangThaiFilter').change(function () {
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