<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Lấy dữ liệu từ servlet
    Map<String, Object> nhanVienInfo = (Map<String, Object>) request.getAttribute("nhanVienInfo");
    Map<String, Object> thongTinLuong = (Map<String, Object>) request.getAttribute("thongTinLuong");
    List<Map<String, Object>> lichSuLuong = (List<Map<String, Object>>) request.getAttribute("lichSuLuong");
    List<Map<String, Object>> kpiList = (List<Map<String, Object>>) request.getAttribute("kpiList");
    Map<String, Object> tongHopKPI = (Map<String, Object>) request.getAttribute("tongHopKPI");
    List<Map<String, Object>> luongKPIList = (List<Map<String, Object>>) request.getAttribute("luongKPIList");
    String thangHienTai = (String) request.getAttribute("thangHienTai");
    String namHienTai = (String) request.getAttribute("namHienTai");
    
    // Set default values nếu null
    if (nhanVienInfo == null) nhanVienInfo = new HashMap<>();
    if (thongTinLuong == null) thongTinLuong = new HashMap<>();
    if (lichSuLuong == null) lichSuLuong = new ArrayList<>();
    if (kpiList == null) kpiList = new ArrayList<>();
    if (tongHopKPI == null) tongHopKPI = new HashMap<>();
    if (luongKPIList == null) luongKPIList = new ArrayList<>();
    
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
        <title>QLNS - Lương & KPI</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.ckeditor.com/4.22.1/standard/ckeditor.js"></script>
        <style>
            html, body {
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
                    padding: 18px 6px;
                    margin-left: 76px;
                }
            }
            @media (max-width: 576px) {
                .main-content {
                    padding: 8px 2px;
                    margin-left: 60px;
                }
                .main-box {
                    padding: 10px 2px;
                }
            }
            .salary-card {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-radius: 12px;
                padding: 25px;
                margin-bottom: 20px;
            }
            .salary-item {
                display: flex;
                justify-content: space-between;
                margin-bottom: 10px;
            }
            .salary-item:last-child {
                margin-bottom: 0;
                padding-top: 10px;
                border-top: 1px solid rgba(255,255,255,0.3);
                font-weight: bold;
                font-size: 1.2em;
            }
            .kpi-card {
                background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
                color: white;
                border-radius: 12px;
                padding: 25px;
                margin-bottom: 20px;
            }
            .kpi-score {
                font-size: 3rem;
                font-weight: bold;
                text-align: center;
                margin: 20px 0;
            }
            .nav-tabs .nav-link {
                border-radius: 12px 12px 0 0;
            }
            .nav-tabs .nav-link.active {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-color: transparent;
            }
        </style>
        <script>
            var USER_PAGE_TITLE = '<i class="fa-solid fa-money-bill me-2"></i>Lương & KPI';
        </script>
    </head>
    <body>
        <%@ include file="sidebarnv.jsp" %>
        <%@ include file="user_header.jsp" %>
        <div class="main-content">
            <!-- Thông tin lương tháng hiện tại -->
            <div class="row mb-4">
                <div class="col-md-8">
                    <div class="salary-card">
                        <h4><i class="fa-solid fa-money-bill me-2"></i>Lương tháng <%=thangHienTai%>/<%=namHienTai%></h4>
                        <% if (thongTinLuong != null && !thongTinLuong.isEmpty()) { %>
                        <div class="salary-item">
                            <span>Lương cơ bản:</span>
                            <span><fmt:formatNumber value="<%=thongTinLuong.get(\"luong_co_ban\")%>" type="number" pattern="#,###"/>₫</span>
                        </div>
                        <div class="salary-item">
                            <span>Phụ cấp:</span>
                            <span><fmt:formatNumber value="<%=thongTinLuong.get(\"phu_cap\")%>" type="number" pattern="#,###"/>₫</span>
                        </div>
                        <div class="salary-item">
                            <span>Thưởng:</span>
                            <span><fmt:formatNumber value="<%=thongTinLuong.get(\"thuong\")%>" type="number" pattern="#,###"/>₫</span>
                        </div>
                        <div class="salary-item">
                            <span>Phạt:</span>
                            <span>-<fmt:formatNumber value="<%=thongTinLuong.get(\"phat\")%>" type="number" pattern="#,###"/>₫</span>
                        </div>
                        <div class="salary-item">
                            <span>Bảo hiểm:</span>
                            <span>-<fmt:formatNumber value="<%=thongTinLuong.get(\"bao_hiem\")%>" type="number" pattern="#,###"/>₫</span>
                        </div>
                        <div class="salary-item">
                            <span>Thuế:</span>
                            <span>-<fmt:formatNumber value="<%=thongTinLuong.get(\"thue\")%>" type="number" pattern="#,###"/>₫</span>
                        </div>
                        <div class="salary-item">
                            <span>Thực lĩnh:</span>
                            <span><fmt:formatNumber value="<%=thongTinLuong.get(\"luong_thuc_te\")%>" type="number" pattern="#,###"/>₫</span>
                        </div>
                        <% 
                            String trangThaiLuong = (String) thongTinLuong.get("trang_thai");
                            String badgeClass = "Đã trả".equals(trangThaiLuong) ? "success" : "warning";
                        %>
                        <div class="mt-3">
                            <span class="badge bg-<%=badgeClass%> p-2"><%=trangThaiLuong%></span>
                            <% if (thongTinLuong.get("ngay_tra_luong") != null) { %>
                            <small class="ms-2">Ngày trả: <%=thongTinLuong.get("ngay_tra_luong")%></small>
                            <% } %>
                        </div>
                        <% if (thongTinLuong.get("ghi_chu") != null) { %>
                        <div class="mt-2">
                            <small><strong>Ghi chú:</strong> <%=thongTinLuong.get("ghi_chu")%></small>
                        </div>
                        <% } %>
                        <% } else { %>
                        <div class="text-center py-4">
                            <i class="fa-solid fa-inbox fa-2x mb-3"></i>
                            <p>Chưa có thông tin lương tháng này</p>
                        </div>
                        <% } %>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="kpi-card">
                        <h4 class="text-center"><i class="fa-solid fa-chart-line me-2"></i>KPI tháng <%=thangHienTai%>/<%=namHienTai%></h4>
                        <div class="kpi-score">
                            <%=tongHopKPI.get("diem_kpi_trung_binh") != null ? String.format("%.1f", tongHopKPI.get("diem_kpi_trung_binh")) : "0.0"%>
                        </div>
                        <div class="text-center">
                            <div class="mb-2">
                                <strong><%=tongHopKPI.get("so_chi_tieu") != null ? tongHopKPI.get("so_chi_tieu") : 0%></strong> chỉ tiêu
                            </div>
                            <div>
                                <strong><%=tongHopKPI.get("cong_viec_hoan_thanh") != null ? tongHopKPI.get("cong_viec_hoan_thanh") : 0%></strong> công việc hoàn thành
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="main-box">
                <ul class="nav nav-tabs mb-4" id="myTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="salary-tab" data-bs-toggle="tab" data-bs-target="#salary-pane" type="button" role="tab">
                            <i class="fa-solid fa-money-bill me-2"></i>Lịch sử lương
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="kpi-tab" data-bs-toggle="tab" data-bs-target="#kpi-pane" type="button" role="tab">
                            <i class="fa-solid fa-chart-bar me-2"></i>Chi tiết KPI
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="combined-tab" data-bs-toggle="tab" data-bs-target="#combined-pane" type="button" role="tab">
                            <i class="fa-solid fa-table me-2"></i>Tổng hợp
                        </button>
                    </li>
                </ul>

                <div class="tab-content" id="myTabContent">
                    <!-- Tab lịch sử lương -->
                    <div class="tab-pane fade show active" id="salary-pane" role="tabpanel">
                        <div class="table-responsive">
                            <table class="table table-bordered align-middle table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>Tháng/Năm</th>
                                        <th>Lương cơ bản</th>
                                        <th>Phụ cấp</th>
                                        <th>Thưởng</th>
                                        <th>Phạt</th>
                                        <th>Thực lĩnh</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (lichSuLuong != null && !lichSuLuong.isEmpty()) { %>
                                    <% for (Map<String, Object> luong : lichSuLuong) { %>
                                    <tr>
                                        <td><%=luong.get("thang")%>/<%=luong.get("nam")%></td>
                                        <td><fmt:formatNumber value="<%=luong.get(\"luong_co_ban\")%>" type="number" pattern="#,###"/>₫</td>
                                        <td><fmt:formatNumber value="<%=luong.get(\"phu_cap\")%>" type="number" pattern="#,###"/>₫</td>
                                        <td><fmt:formatNumber value="<%=luong.get(\"thuong\")%>" type="number" pattern="#,###"/>₫</td>
                                        <td><fmt:formatNumber value="<%=luong.get(\"phat\")%>" type="number" pattern="#,###"/>₫</td>
                                        <td><strong><fmt:formatNumber value="<%=luong.get(\"luong_thuc_te\")%>" type="number" pattern="#,###"/>₫</strong></td>
                                        <td>
                                            <% 
                                                String trangThai = (String) luong.get("trang_thai");
                                                String badgeClass = "Đã trả".equals(trangThai) ? "success" : "warning";
                                            %>
                                            <span class="badge bg-<%=badgeClass%>"><%=trangThai%></span>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% } else { %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted">
                                            <i class="fa-solid fa-inbox"></i> Chưa có lịch sử lương
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Tab chi tiết KPI -->
                    <div class="tab-pane fade" id="kpi-pane" role="tabpanel">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <div class="d-flex gap-2">
                                    <select class="form-select" id="filterThangKPI" style="width: 120px;">
                                        <% for(int i = 1; i <= 12; i++) { %>
                                        <option value="<%=i%>" <%=i == thangInt ? "selected" : ""%>>Tháng <%=i%></option>
                                        <% } %>
                                    </select>
                                    <select class="form-select" id="filterNamKPI" style="width: 120px;">
                                        <% 
                                            int currentYear = Calendar.getInstance().get(Calendar.YEAR);
                                            for(int year = currentYear - 2; year <= currentYear + 1; year++) { 
                                        %>
                                        <option value="<%=year%>" <%=year == namInt ? "selected" : ""%>><%=year%></option>
                                        <% } %>
                                    </select>
                                    <button class="btn btn-primary" onclick="loadKPIByMonth()">
                                        <i class="fa-solid fa-filter"></i> Lọc
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div id="kpiContent">
                            <% if (kpiList != null && !kpiList.isEmpty()) { %>
                            <% for (Map<String, Object> kpi : kpiList) { %>
                            <div class="card mb-3">
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-8">
                                            <h6 class="card-title"><%=kpi.get("chi_tieu")%></h6>
                                            <p class="card-text"><%=kpi.get("ket_qua")%></p>
                                            <% if (kpi.get("ghi_chu") != null) { %>
                                            <small class="text-muted"><%=kpi.get("ghi_chu")%></small>
                                            <% } %>
                                        </div>
                                        <div class="col-md-4 text-end">
                                            <h3 class="text-primary"><%=String.format("%.1f", kpi.get("diem_kpi"))%></h3>
                                            <small class="text-muted"><%=kpi.get("ngay_tao")%></small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                            <% } else { %>
                            <div class="text-center py-5">
                                <i class="fa-solid fa-chart-line fa-3x text-muted mb-3"></i>
                                <p class="text-muted">Chưa có dữ liệu KPI tháng này</p>
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Tab tổng hợp -->
                    <div class="tab-pane fade" id="combined-pane" role="tabpanel">
                        <div class="table-responsive">
                            <table class="table table-bordered align-middle table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>Tháng/Năm</th>
                                        <th>Tổng giờ làm</th>
                                        <th>Lương cơ bản</th>
                                        <th>Thưởng</th>
                                        <th>Phạt</th>
                                        <th>Tổng lương</th>
                                        <th>KPI</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (luongKPIList != null && !luongKPIList.isEmpty()) { %>
                                    <% for (Map<String, Object> item : luongKPIList) { %>
                                    <tr>
                                        <td><%=item.get("thang")%>/<%=item.get("nam")%></td>
                                        <td><%=String.format("%.1f", item.get("tong_gio_lam"))%>h</td>
                                        <td><fmt:formatNumber value="<%=item.get(\"luong_co_ban\")%>" type="number" pattern="#,###"/>₫</td>
                                        <td><fmt:formatNumber value="<%=item.get(\"thuong\")%>" type="number" pattern="#,###"/>₫</td>
                                        <td><fmt:formatNumber value="<%=item.get(\"phat\")%>" type="number" pattern="#,###"/>₫</td>
                                        <td><strong><fmt:formatNumber value="<%=item.get(\"luong_thuc_te\")%>" type="number" pattern="#,###"/>₫</strong></td>
                                        <td>
                                            <% 
                                                Double kpiScore = (Double) item.get("diem_kpi");
                                                if (kpiScore != null && kpiScore > 0) {
                                            %>
                                            <span class="badge bg-info"><%=String.format("%.1f", kpiScore)%></span>
                                            <% } else { %>
                                            <span class="text-muted">-</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <% 
                                                String trangThai = (String) item.get("trang_thai");
                                                String badgeClass = "Đã trả".equals(trangThai) ? "success" : "warning";
                                            %>
                                            <span class="badge bg-<%=badgeClass%>"><%=trangThai%></span>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% } else { %>
                                    <tr>
                                        <td colspan="8" class="text-center text-muted">
                                            <i class="fa-solid fa-inbox"></i> Chưa có dữ liệu
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="<%= request.getContextPath() %>/scripts/user_salary.obf.js?v=20251105"></script>
    </body>
</html>