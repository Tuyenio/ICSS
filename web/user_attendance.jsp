<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Lấy dữ liệu từ servlet
    Map<String, Object> nhanVienInfo = (Map<String, Object>) request.getAttribute("nhanVienInfo");
    List<Map<String, Object>> lichSuChamCong = (List<Map<String, Object>>) request.getAttribute("lichSuChamCong");
    Map<String, Object> thongKeChamCong = (Map<String, Object>) request.getAttribute("thongKeChamCong");
    Map<String, Object> chamCongHomNay = (Map<String, Object>) request.getAttribute("chamCongHomNay");
    String thangHienTai = (String) request.getAttribute("thangHienTai");
    String namHienTai = (String) request.getAttribute("namHienTai");
    String emailSession = (String) session.getAttribute("userEmail");
    
    // Set default values nếu null hoặc rỗng
    if (nhanVienInfo == null) nhanVienInfo = new HashMap<>();
    if (lichSuChamCong == null) lichSuChamCong = new ArrayList<>();
    if (thongKeChamCong == null) thongKeChamCong = new HashMap<>();
    if (chamCongHomNay == null) chamCongHomNay = new HashMap<>();
    
    // Xử lý tháng/năm an toàn
    int thangInt = 1;
    int namInt = 2024;
    try {
        if (thangHienTai != null && !thangHienTai.trim().isEmpty()) {
            thangInt = Integer.parseInt(thangHienTai);
        } else {
            thangInt = java.util.Calendar.getInstance().get(java.util.Calendar.MONTH) + 1;
        }
        if (namHienTai != null && !namHienTai.trim().isEmpty()) {
            namInt = Integer.parseInt(namHienTai);
        } else {
            namInt = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
        }
    } catch (NumberFormatException e) {
        thangInt = java.util.Calendar.getInstance().get(java.util.Calendar.MONTH) + 1;
        namInt = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
    }
    
    if (thangHienTai == null || thangHienTai.trim().isEmpty()) {
        thangHienTai = String.valueOf(thangInt);
    }
    if (namHienTai == null || namHienTai.trim().isEmpty()) {
        namHienTai = String.valueOf(namInt);
    }
%>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Chấm công</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.ckeditor.com/4.22.1/standard/ckeditor.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            html,
            body {
                background: #f8fafc;
                font-family: 'Segoe UI', Roboto, sans-serif;
                color: #1e293b;
            }

            /* Responsive styles for included sidebar */

            .main-content {
                padding: 36px 36px 24px 36px;
                min-height: 100vh;
                margin-left: 260px;
            }
            .avatar {
                width: 38px;
                height: 38px;
                border-radius: 50%;
                object-fit: cover;
            }
            .main-box {
                background: #fff;
                border-radius: 14px;
                box-shadow: 0 2px 12px #0001;
                padding: 32px 24px;
            }
            @media (max-width: 1200px) {
                .main-content {
                    margin-left: 240px;
                }
            }
            @media (max-width: 992px) {
                .main-content {
                    margin-left: 76px;
                }
            }
            @media (max-width: 768px) {
                .main-box {
                    padding: 10px 2px;
                }
                .main-content {
                    padding: 10px 2px;
                }
            }
            @media (max-width: 576px) {
                .main-content {
                    margin-left: 60px;
                }
            }

            .table thead th {
                vertical-align: middle;
            }

            .table-hover tbody tr:hover {
                background: #eaf6ff;
            }

            .filter-row .form-select,
            .filter-row .form-control {
                border-radius: 20px;
            }

            .modal-content {
                border-radius: 14px;
            }

            .modal-header,
            .modal-footer {
                border-color: #e9ecef;
            }

            .badge-status {
                font-size: 0.95em;
            }

            .stat-card {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-radius: 12px;
                padding: 20px;
                margin-bottom: 15px;
                text-align: center;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            }

            .stat-card h5 {
                margin: 0;
                font-size: 1.8rem;
                font-weight: bold;
            }

            .stat-card p {
                margin: 5px 0 0 0;
                opacity: 0.9;
                font-size: 1rem;
            }

            @media (max-width: 768px) {
                .main-box {
                    padding: 10px 2px;
                }

                .main-content {
                    padding: 10px 2px;
                    margin-left: 60px;
                }

                .header {
                    margin-left: 60px;
                }

                .table-responsive {
                    font-size: 0.9rem;
                }
            }

            .sidebar i {
                font-family: "Font Awesome 6 Free" !important;
                font-weight: 900;
            }

            /* Cải tiến hiển thị nút chấm công */
            .btn {
                border-radius: 8px;
                font-weight: 500;
                transition: all 0.3s ease;
                font-size: 1rem;
                padding: 10px 20px;
            }

            .btn:hover {
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            }

            .btn:disabled {
                transform: none;
                box-shadow: none;
            }

            /* Style cho badge trạng thái */
            .badge {
                font-size: 0.85rem;
                padding: 6px 12px;
                border-radius: 20px;
            }

            /* Hiệu ứng loading */
            .loading-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.5);
                display: none;
                justify-content: center;
                align-items: center;
                z-index: 9999;
            }

            .loading-spinner {
                width: 50px;
                height: 50px;
                border: 4px solid #f3f3f3;
                border-top: 4px solid #007bff;
                border-radius: 50%;
                animation: spin 1s linear infinite;
            }

            @keyframes spin {
                0% {
                    transform: rotate(0deg);
                }
                100% {
                    transform: rotate(360deg);
                }
            }

            /* Responsive cho mobile */
            @media (max-width: 768px) {
                .btn {
                    font-size: 0.9rem;
                    padding: 8px 16px;
                }

                .badge {
                    font-size: 0.75rem;
                    padding: 4px 8px;
                }

                .stat-card {
                    padding: 15px;
                    margin-bottom: 10px;
                }

                .stat-card h5 {
                    font-size: 1.5rem;
                }

                .stat-card p {
                    font-size: 0.9rem;
                }

                .main-content {
                    padding: 20px 10px;
                }

                .table-responsive {
                    font-size: 0.9rem;
                }
            }

            @media (max-width: 576px) {
                .stat-card {
                    padding: 10px;
                }

                .stat-card h5 {
                    font-size: 1.2rem;
                }

                .stat-card p {
                    font-size: 0.8rem;
                }

                .btn {
                    font-size: 0.8rem;
                    padding: 6px 12px;
                }

                .badge {
                    font-size: 0.7rem;
                    padding: 4px 8px;
                }
            }

            /* ==== MODAL STYLES ==== */
            .modal-content {
                border-radius: 8px;
                border: 1px solid #dee2e6;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            }

            .modal-header {
                background: #fff;
                border-bottom: 1px solid #dee2e6;
            }

            .modal-header .btn-close {
                background: transparent;
                border: none;
                opacity: 0.6;
            }

            .modal-header .btn-close:hover {
                opacity: 1;
            }

            .modal-body {
                padding: 20px 24px;
            }

            .modal-footer {
                background: #f8f9fa;
                border-top: 1px solid #dee2e6;
                padding: 16px 24px;
            }

            .form-control {
                border: 1px solid #dee2e6;
                border-radius: 4px;
                padding: 8px 12px;
                font-size: 14px;
            }

            .form-control:focus {
                border-color: #0d6efd;
                box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25);
            }

            .btn {
                border-radius: 4px;
                font-size: 14px;
                font-weight: 500;
                padding: 8px 16px;
            }

            .btn-primary {
                background-color: #0d6efd;
                border-color: #0d6efd;
            }

            .btn-primary:hover {
                background-color: #0b5ed7;
                border-color: #0a58ca;
            }

            .btn-light {
                background-color: #f8f9fa;
                border-color: #f8f9fa;
                color: #6c757d;
            }

            .btn-light:hover {
                background-color: #e9ecef;
                border-color: #dae0e5;
                color: #6c757d;
            }

            /* Report button styles */
            .btn-report {
                background-color: #198754;
                border-color: #198754;
                color: #fff;
                padding: 4px 8px;
                font-size: 12px;
                border-radius: 4px;
            }

            .btn-report:hover {
                background-color: #157347;
                border-color: #146c43;
                color: #fff;
            }
        </style>
        <script>
            var USER_PAGE_TITLE = '<i class="fa-solid fa-calendar-check me-2"></i>Chấm công';
        </script>
    </head>

    <body>
        <!-- Loading overlay -->
        <div class="loading-overlay" id="loadingOverlay">
            <div class="loading-spinner"></div>
        </div>
        <%@ include file="sidebarnv.jsp" %>
        <%@ include file="user_header.jsp" %>
        <div class="main-content">
            <!-- Thống kê tổng quan -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="stat-card">
                        <h5><%=thongKeChamCong.get("tong_ngay_cham") != null ? thongKeChamCong.get("tong_ngay_cham") : 0%></h5>
                        <p>Ngày đã chấm công</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                        <h5><%=thongKeChamCong.get("ngay_di_tre") != null ? thongKeChamCong.get("ngay_di_tre") : 0%></h5>
                        <p>Ngày đi trễ</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                        <h5><%=thongKeChamCong.get("tong_gio_lam") != null ? String.format("%.1f", thongKeChamCong.get("tong_gio_lam")) : "0.0"%></h5>
                        <p>Tổng giờ làm việc</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);">
                        <h5><%=thongKeChamCong.get("ngay_du_cong") != null ? thongKeChamCong.get("ngay_du_cong") : 0%></h5>
                        <p>Ngày đủ công</p>
                    </div>
                </div>
            </div>

            <div class="main-box mb-3">
                <h3 class="mb-4"><i class="fa-solid fa-calendar-check me-2"></i>Chấm công tháng <%=thangHienTai%>/<%=namHienTai%></h3>

                <!-- Nút chấm công và trạng thái -->
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="d-flex align-items-center">
                            <button class="btn btn-success me-2" id="btnCheckIn" 
                                    <%=chamCongHomNay.get("da_check_in") != null && (Boolean)chamCongHomNay.get("da_check_in") ? "disabled" : ""%>>
                                <i class="fa-solid fa-sign-in-alt"></i> Check-in
                            </button>
                            <button class="btn btn-danger me-3" id="btnCheckOut"
                                    <%=chamCongHomNay.get("da_check_out") != null && (Boolean)chamCongHomNay.get("da_check_out") ? "disabled" : ""%>>
                                <i class="fa-solid fa-sign-out-alt"></i> Check-out
                            </button>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <!-- Hiển thị trạng thái hôm nay -->
                        <div class="d-flex align-items-center justify-content-end">
                            <div class="me-3">
                                <strong>Trạng thái hôm nay:</strong>
                            </div>
                            <div>
                                <% if (chamCongHomNay.get("check_in") != null) { %>
                                <span class="badge bg-success me-2">
                                    <i class="fa-solid fa-clock"></i> Check-in: <%=chamCongHomNay.get("check_in")%>
                                </span>
                                <% } else { %>
                                <span class="badge bg-secondary me-2">
                                    <i class="fa-solid fa-clock"></i> Chưa check-in
                                </span>
                                <% } %>

                                <% if (chamCongHomNay.get("check_out") != null) { %>
                                <span class="badge bg-danger">
                                    <i class="fa-solid fa-clock"></i> Check-out: <%=chamCongHomNay.get("check_out")%>
                                </span>
                                <% } else { %>
                                <span class="badge bg-secondary">
                                    <i class="fa-solid fa-clock"></i> Chưa check-out
                                </span>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filter tháng/năm -->
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="d-flex gap-2">
                            <select class="form-select" id="filterThang" style="width: 120px;">
                                <% for(int i = 1; i <= 12; i++) { %>
                                <option value="<%=i%>" <%=i == thangInt ? "selected" : ""%>>Tháng <%=i%></option>
                                <% } %>
                            </select>
                            <select class="form-select" id="filterNam" style="width: 120px;">
                                <% 
                                    int currentYear = Calendar.getInstance().get(Calendar.YEAR);
                                    for(int year = currentYear - 2; year <= currentYear + 1; year++) { 
                                %>
                                <option value="<%=year%>" <%=year == namInt ? "selected" : ""%>><%=year%></option>
                                <% } %>
                            </select>
                            <button class="btn btn-primary" onclick="filterByMonth()">
                                <i class="fa-solid fa-filter"></i> Lọc
                            </button>
                        </div>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table table-bordered align-middle table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>Ngày</th>
                                <th>Check-in</th>
                                <th>Check-out</th>
                                <th>Số giờ</th>
                                <th>Trạng thái</th>
                                <th>Báo cáo</th>
                            </tr>
                        </thead>
                        <tbody id="attendanceTableBody">
                            <% if (lichSuChamCong != null && !lichSuChamCong.isEmpty()) { %>
                            <% for (Map<String, Object> record : lichSuChamCong) { %>
                            <tr>
                                <td><%=record.get("ngay")%></td>
                                <td><%=record.get("check_in") != null ? record.get("check_in") : "-"%></td>
                                <td><%=record.get("check_out") != null ? record.get("check_out") : "-"%></td>
                                <td><%=record.get("so_gio_lam") != null ? String.format("%.1f", record.get("so_gio_lam")) : "0"%> giờ</td>
                                <td>
                                    <% 
                                        String trangThai = (String) record.get("trang_thai");
                                        String badgeClass = "bg-secondary";
                                        if ("Đủ công".equals(trangThai) || "Đúng giờ".equals(trangThai)) badgeClass = "bg-success";
                                        else if ("Đi trễ".equals(trangThai)) badgeClass = "bg-warning";
                                        else if ("Vắng mặt".equals(trangThai)) badgeClass = "bg-danger";
                                        else if ("Thiếu giờ".equals(trangThai)) badgeClass = "bg-info";
                                    %>
                                    <span class="badge <%=badgeClass%>"><%=trangThai%></span>
                                </td>
                                <td class="text-center">
                                    <%
                                        Integer attendanceId = (Integer) record.get("id");
                                        String baoCao = (String) record.get("bao_cao");
                                        if (baoCao != null && !baoCao.trim().isEmpty()) {
                                    %>
                                        <button type="button" class="btn btn-sm btn-success" disabled title="Đã gửi báo cáo">
                                            <i class="fas fa-check me-1"></i> Đã gửi
                                        </button>
                                    <% } else { %>
                                        <button type="button" class="btn btn-sm btn-primary btn-report" 
                                                data-attendance-id="<%= attendanceId %>" 
                                                data-bs-toggle="modal" 
                                                data-bs-target="#modalSendReport"
                                                title="Gửi báo cáo">
                                            <i class="fas fa-paper-plane me-1"></i> Gửi báo cáo
                                        </button>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                            <% } else { %>
                            <tr>
                                <td colspan="6" class="text-center text-muted">
                                    <i class="fa-solid fa-inbox"></i> Chưa có dữ liệu chấm công tháng này
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Modal Gửi Báo cáo -->
        <div class="modal fade" id="modalSendReport" tabindex="-1" aria-labelledby="modalSendReportLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header border-0 pb-0">
                        <h5 class="modal-title fw-bold text-dark" id="modalSendReportLabel">
                            <i class="fas fa-paper-plane me-2 text-primary" aria-hidden="true"></i>Gửi báo cáo
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form id="formSendReport">
                        <div class="modal-body pt-2">
                            <input type="hidden" id="reportAttendanceId" name="attendanceId">
                            <div class="mb-4">
                                <label for="reportContent" class="form-label text-secondary fw-medium">
                                    Nội dung báo cáo
                                </label>
                                <textarea class="form-control border-1" id="reportContent" name="reportContent" 
                                          rows="6" placeholder="Nhập nội dung báo cáo của bạn..." required
                                          style="resize: none; border-color: #dee2e6;"></textarea>
                                <div class="form-text text-muted">
                                    <i class="fas fa-info-circle me-1"></i>
                                    Mô tả chi tiết tình huống hoặc lý do cần báo cáo
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer border-0 pt-0">
                            <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">
                                Đóng
                            </button>
                            <button type="submit" class="btn btn-primary px-4" id="btnSubmitReport">
                                Gửi báo cáo
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="<%= request.getContextPath() %>/scripts/user_attendance.js?v=20251105"></script>
    </body>
</html>