<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Quản lý Dự án</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            body {
                background: #f4f6fa;
                transition: background 0.3s ease;
            }

            /* Hiệu ứng fade-in toàn trang */
            .main-content {
                padding: 36px 36px 24px 36px;
                min-height: 100vh;
                margin-left: 240px;
                animation: fadeIn 0.6s ease-in-out;
            }
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

            /* Nút thêm dự án */
            .btn-add-project {
                background: linear-gradient(45deg, #0d6efd, #0dcaf0);
                border: none;
                color: #fff;
                font-weight: 500;
                border-radius: 50px;
                padding: 10px 20px;
                box-shadow: 0 4px 12px rgba(13,110,253,0.3);
                transition: all 0.3s ease;
            }
            .btn-add-project:hover {
                transform: translateY(-2px) scale(1.03);
                box-shadow: 0 6px 16px rgba(13,110,253,0.45);
            }

            /* Card Dự án */
            .project-card {
                background: #fff;
                border-radius: 14px;
                box-shadow: 0 2px 12px rgba(0,0,0,0.08);
                padding: 20px 24px;
                margin-bottom: 18px;
                transition: all 0.3s ease;
                cursor: pointer;
            }
            .project-card:hover {
                box-shadow: 0 8px 24px rgba(0,0,0,0.15);
                transform: translateY(-3px);
            }

            /* Header trong card */
            .project-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .project-title {
                font-size: 1.3rem;
                font-weight: 600;
                color: #1e293b;
            }

            /* Các nút hành động trong card */
            .project-actions {
                display: flex;
                gap: 8px;
            }
            .project-actions .btn {
                border-radius: 50%;
                width: 36px;
                height: 36px;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: all 0.25s ease;
            }
            .project-actions .btn:hover {
                transform: scale(1.15) rotate(5deg);
            }

            /* Mô tả dự án */
            .project-desc {
                margin-top: 10px;
                color: #6c757d;
                font-size: 0.95rem;
            }

            /* Container nút hành động trong card dự án */
            .project-actions {
                display: flex;
                gap: 8px;
                justify-content: center;
                align-items: center;
            }

            /* Nút tròn đều */
            .project-actions .btn {
                border-radius: 50%;
                width: 36px;
                height: 36px;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 0;
                transition: all 0.25s ease;
            }
            .project-actions .btn i {
                font-size: 0.9rem;
            }

            /* Nút Xem */
            .project-actions .btn-info {
                background: linear-gradient(90deg,#0dcaf0,#4f46e5);
                border: none;
                color: #fff;
            }
            .project-actions .btn-info:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(79,70,229,0.4);
            }

            /* Nút Sửa */
            .project-actions .btn-warning {
                background: linear-gradient(90deg,#facc15,#eab308);
                border: none;
                color: #fff;
            }
            .project-actions .btn-warning:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(250,204,21,0.4);
            }

            /* Nút Xóa */
            .project-actions .btn-danger {
                background: linear-gradient(90deg,#ef4444,#dc2626);
                border: none;
                color: #fff;
            }
            .project-actions .btn-danger:hover {
                transform: scale(1.1);
                box-shadow: 0 2px 8px rgba(220,38,38,0.4);
            }

        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án';
        </script>
    </head>
    <body>
        <div class="d-flex">
            <%@ include file="sidebar.jsp" %>
            <div class="flex-grow-1">
                <%@ include file="header.jsp" %>
                <div class="main-content">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3 class="mb-0"><i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án</h3>
                        <button class="btn btn-add-project" data-bs-toggle="modal" data-bs-target="#modalProject">
                            <i class="fa-solid fa-plus me-1"></i> Thêm dự án
                        </button>
                    </div>
                    <form class="row g-3 mb-4 align-items-end" method="get" action="dsDuan">

                        <!-- Tìm theo tên dự án -->
                        <div class="col-md-3">
                            <input type="text" name="keyword" class="form-control"
                                   placeholder="Tìm theo tên dự án..."
                                   value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
                        </div>

                        <!-- Lọc theo mức độ ưu tiên -->
                        <div class="col-md-2">
                            <select name="uuTien" class="form-select">
                                <option value="">Ưu tiên (Tất cả)</option>
                                <option value="Cao" <%= "Cao".equals(request.getParameter("uuTien")) ? "selected" : "" %>>Cao</option>
                                <option value="Trung bình" <%= "Trung bình".equals(request.getParameter("uuTien")) ? "selected" : "" %>>Trung bình</option>
                                <option value="Thấp" <%= "Thấp".equals(request.getParameter("uuTien")) ? "selected" : "" %>>Thấp</option>
                            </select>
                        </div>

                        <!-- Nhóm dự án -->
                        <div class="col-md-2">
                            <select name="nhom_du_an" class="form-select">
                                <option value="">Nhóm dự án (Tất cả)</option>
                                <option value="Dashboard">Dashboard</option>
                                <option value="An ninh bảo mật">An ninh bảo mật</option>
                                <option value="Oracle Cloud">Oracle Cloud</option>
                                <option value="Đào tạo">Đào tạo</option>
                                <option value="Khác">Khác</option>
                            </select>
                        </div>

                        <!-- Lead -->
                        <div class="col-md-3">
                            <select name="leadId" class="form-select">
                                <option value="">Lead dự án (Tất cả)</option>

                                <%
                                    List<Map<String, Object>> dsNV = (List<Map<String, Object>>) request.getAttribute("dsNhanVien");
                                    String leadSelected = request.getParameter("leadId");

                                    if (dsNV != null) {
                                        for (Map<String, Object> nv : dsNV) {
                                            int id = (int) nv.get("id");
                                            String ten = (String) nv.get("ho_ten");
                                %>

                                <option value="<%= id %>" <%= (leadSelected != null && leadSelected.equals(String.valueOf(id))) ? "selected" : "" %>>
                                    <%= ten %>
                                </option>

                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <!-- Nút Lọc -->
                        <div class="col-md-1">
                            <button class="btn btn-primary w-100">
                                <i class="fa-solid fa-filter"></i> Lọc
                            </button>
                        </div>

                        <!-- Nút Reset -->
                        <div class="col-md-1">
                            <a href="dsDuan" class="btn btn-secondary w-100">
                                <i class="fa-solid fa-rotate-left"></i>
                            </a>
                        </div>

                    </form>
                    <div class="row project-list">
                        <%
                            List<Map<String, Object>> projects = (List<Map<String, Object>>) request.getAttribute("projects");
                            if (projects != null) {
                                for (Map<String, Object> project : projects) {
                        %>

                        <div class="col-md-6 mb-4">
                            <div class="project-card" data-id="<%= project.get("id") %>"
                                 onclick="goToProjectTask(<%= project.get("id") %>, event)">

                                <!-- HEADER -->
                                <div class="project-header d-flex justify-content-between align-items-center">
                                    <span class="project-title"><%= project.get("ten_du_an") %></span>

                                    <div class="project-actions">
                                        <button class="btn btn-info" onclick="showProjectDetail(event, <%= project.get("id") %>)">
                                            <i class="fa-solid fa-eye"></i>
                                        </button>
                                        <button class="btn btn-warning"
                                                onclick="editProject(<%= project.get("id") %>); event.stopPropagation();">
                                            <i class="fa-solid fa-pen"></i>
                                        </button>
                                        <button class="btn btn-danger delete-project-btn" data-id="<%= project.get("id") %>">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </div>
                                </div>

                                <!-- MÔ TẢ -->
                                <div class="project-desc mt-2 text-muted">
                                    Mô tả: <%= project.get("mo_ta") %>
                                </div>

                                <!-- LEAD + ƯU TIÊN -->
                                <div class="mt-2 d-flex justify-content-between align-items-center">
                                    <!-- Lead -->
                                    <div class="d-flex align-items-center">
                                        <span class="me-2 text-secondary fw-semibold">Lead dự án:</span>
                                        <% 
                                            String leadName = (String) project.get("lead_ten");
                                            String leadAvatar = (String) project.get("lead_avatar");
                                        %>

                                        <% if (leadAvatar != null && !leadAvatar.isEmpty()) { %>
                                        <img src="<%= leadAvatar %>" class="rounded-circle me-2" width="28" height="28">
                                        <% } %>

                                        <span class="fw-semibold text-primary">
                                            <%= leadName != null ? leadName : "Chưa có Lead" %>
                                        </span>
                                    </div>

                                    <!-- Mức độ ưu tiên -->
                                    <span class="badge 
                                          <%= "Cao".equals(project.get("muc_do_uu_tien")) ? "bg-danger" :
                                              "Trung bình".equals(project.get("muc_do_uu_tien")) ? "bg-warning" :
                                              "bg-secondary" %>">
                                        <%= project.get("muc_do_uu_tien") != null ? project.get("muc_do_uu_tien") : "Không rõ" %>
                                    </span>
                                </div>
                                <div class="mt-1 text-secondary">
                                    <small><strong>Nhóm dự án:</strong> <%= project.get("nhom_du_an") %></small>
                                </div>

                                <%
                                    // Tính phần trăm tiến độ
                                    Object tienDoObj = project.get("tien_do");
                                    int tienDo = 0;
                                    if (tienDoObj != null) {
                                        try {
                                            tienDo = Integer.parseInt(tienDoObj.toString());
                                        } catch (Exception e) {
                                            tienDo = 0;
                                        }
                                    }

                                    // Chọn màu thanh tiến độ
                                    String progressClass = "";
                                    if (tienDo < 30) progressClass = "bg-danger";
                                    else if (tienDo < 70) progressClass = "bg-warning";
                                    else progressClass = "bg-success";
                                %>

                                <!-- TIẾN ĐỘ -->
                                <div class="mt-3">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <small class="text-muted"><i class="fa-solid fa-tasks me-1"></i>Tiến độ dự án</small>
                                        <small class="fw-bold text-primary"><%= tienDo %>%</small>
                                    </div>

                                    <div class="progress" style="height: 8px; border-radius: 10px;">
                                        <div class="progress-bar <%= progressClass %>"
                                             role="progressbar"
                                             style="width: <%= tienDo %>%;"
                                             aria-valuenow="<%= tienDo %>"
                                             aria-valuemin="0"
                                             aria-valuemax="100">
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>

                        <%
                                }
                            }
                        %>
                    </div>
                </div>
            </div>
        </div>
        <!-- Modal Thêm/Sửa Dự án -->
        <div class="modal fade" id="modalProject" tabindex="-1">
            <div class="modal-dialog">
                <form class="modal-content" id="projectForm">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fa-solid fa-diagram-project"></i> Thông tin dự án</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="id">

                        <div class="mb-3">
                            <label class="form-label">Tên dự án</label>
                            <input type="text" class="form-control" name="ten_du_an" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Mô tả</label>
                            <textarea class="form-control" name="mo_ta" rows="3"></textarea>
                        </div>

                        <!-- THÊM MỨC ĐỘ ƯU TIÊN -->
                        <div class="mb-3">
                            <label class="form-label">Mức độ ưu tiên</label>
                            <select class="form-select" name="muc_do_uu_tien" required>
                                <option value="">-- Chọn mức độ ưu tiên --</option>
                                <option value="Cao">Cao</option>
                                <option value="Trung bình">Trung bình</option>
                                <option value="Thấp">Thấp</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Nhóm dự án</label>
                            <select class="form-select" name="nhom_du_an" required>
                                <option value="Dashboard">Dashboard</option>
                                <option value="An ninh bảo mật">An ninh bảo mật</option>
                                <option value="Oracle Cloud">Oracle Cloud</option>
                                <option value="Đào tạo">Đào tạo</option>
                                <option value="Khác">Khác</option>
                            </select>
                        </div>

                        <!-- THÊM LEAD DỰ ÁN -->
                        <div class="mb-3">
                            <label class="form-label">Lead dự án</label>
                            <select class="form-select" name="lead_id" required>
                                <option value="">-- Chọn Lead --</option>

                                <% 
                                    List<Map<String, Object>> dsNV2 = (List<Map<String, Object>>) request.getAttribute("dsNhanVien");
                                    if (dsNV2 != null) {
                                        for (Map<String, Object> nv : dsNV2) {
                                            int id = (int) nv.get("id");
                                            String ten = (String) nv.get("ho_ten");
                                %>
                                <option value="<%= id %>"><%= ten %></option>
                                <% 
                                        }
                                    }
                                %>
                            </select>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Ngày bắt đầu</label>
                                <input type="date" class="form-control" name="ngay_bat_dau">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Ngày kết thúc</label>
                                <input type="date" class="form-control" name="ngay_ket_thuc">
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn-primary rounded-pill">Lưu</button>
                        <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
                    </div>
                </form>
            </div>
        </div>
        <!-- Modal chi tiết dự án -->
        <div class="modal fade" id="modalProjectDetail" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fa-solid fa-info-circle"></i> Chi tiết dự án</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="mb-3">
                                    <label class="form-label"><strong>Tên dự án:</strong></label>
                                    <div id="detailTenDuAn" class="form-control-plaintext"></div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label"><strong>Mô tả:</strong></label>
                                    <div id="detailMoTa" class="form-control-plaintext"></div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label"><strong>Nhóm dự án:</strong></label>
                                    <div id="detailNhomDuAn" class="form-control-plaintext"></div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label"><strong>Ngày bắt đầu:</strong></label>
                                        <div id="detailNgayBatDau" class="form-control-plaintext"></div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label"><strong>Ngày kết thúc:</strong></label>
                                        <div id="detailNgayKetThuc" class="form-control-plaintext"></div>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label"><strong>Ngày tạo:</strong></label>
                                    <div id="detailNgayTao" class="form-control-plaintext"></div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="card bg-light">
                                            <div class="card-body text-center">
                                                <h5 class="card-title text-primary">
                                                    <i class="fa-solid fa-tasks me-2"></i>
                                                    <span id="detailTongCongViec">0</span>
                                                </h5>
                                                <p class="card-text">Tổng số công việc đã giao</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="card bg-light">
                                            <div class="card-body text-center">
                                                <h5 class="card-title text-success">
                                                    <i class="fa-solid fa-users me-2"></i>
                                                    <span id="detailTongNguoi">0</span>
                                                </h5>
                                                <p class="card-text">Tổng số người trong dự án</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>
        <script src="<%= request.getContextPath() %>/scripts/project.js?v=20251105"></script>
    </body>
</html>