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
    String displayDateRange = "";
    
    // Xác định kiểu lọc: date range hoặc tháng/năm
    if (tuNgayParam != null && denNgayParam != null && !tuNgayParam.isEmpty() && !denNgayParam.isEmpty()) {
        // Lọc theo khoảng thời gian
        baoCaoNhanVien = apiBaoCao.getBaoCaoNhanVienByDateRange(tuNgayParam, denNgayParam, phongBanParam);
        
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

            /* ==== Clear Button ==== */
            #clearDateRange {
                transition: all 0.2s ease;
            }

            #clearDateRange:hover {
                background-color: #dc3545;
                color: white;
                border-color: #dc3545;
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
                            <div class="col-md-4">
                                <input type="text" class="form-control" id="dateRangeFilter" 
                                       placeholder="Chọn khoảng thời gian" 
                                       value="<%= displayDateRange %>" readonly>
                                <input type="hidden" id="tuNgayHidden" value="<%= tuNgayParam != null ? tuNgayParam : "" %>">
                                <input type="hidden" id="denNgayHidden" value="<%= denNgayParam != null ? denNgayParam : "" %>">
                            </div>
                            <div class="col-md-2">
                                <button class="btn btn-outline-secondary w-100" id="clearDateRange">
                                    <i class="fa-solid fa-times me-1"></i> Xóa lọc
                                </button>
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