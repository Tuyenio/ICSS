<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, controller.TaiLieu, controller.NhomTaiLieu, jakarta.servlet.http.HttpSession" %>
<%
    // Kiểm tra đăng nhập
    HttpSession sess = request.getSession(false);
    String email = (session != null) ? (String) session.getAttribute("userEmail") : null;
    if (email == null || email.isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<NhomTaiLieu> danhSachNhom = (List<NhomTaiLieu>) request.getAttribute("danhSachNhom");
    List<TaiLieu> danhSachTaiLieu = (List<TaiLieu>) request.getAttribute("danhSachTaiLieu");
    NhomTaiLieu nhomHienTai = (NhomTaiLieu) request.getAttribute("nhomHienTai");
    Integer nhomId = (Integer) request.getAttribute("nhomId");
    
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    String currentSearch = (String) request.getAttribute("currentSearch");
    
    if (danhSachNhom == null) danhSachNhom = new ArrayList<>();
    if (danhSachTaiLieu == null) danhSachTaiLieu = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>QLNS - Thư viện tài liệu</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <style>
            body {
                background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 30%, #cbd5e1 70%, #94a3b8 100%);
                min-height: 100vh;
                font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
                position: relative;
            }

            body::before {
                content: '';
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: url('data:image/svg+xml,<svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse"><path d="M 20 0 L 0 0 0 20" fill="none" stroke="%23e2e8f0" stroke-width="0.5" opacity="0.4"/></pattern></defs><rect width="100%" height="100%" fill="url(%23grid)"/></svg>');
                pointer-events: none;
                z-index: 0;
            }

            .header {
                background: rgba(255, 255, 255, 0.98);
                backdrop-filter: blur(20px);
                border-bottom: 1px solid rgba(226, 232, 240, 0.6);
                min-height: 64px;
                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
                margin-left: 260px;
                position: sticky;
                top: 0;
                z-index: 100;
            }

            .main-content {
                padding: 40px;
                min-height: 100vh;
                margin-left: 260px;
                position: relative;
                z-index: 1;
            }

            .page-header {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                border-radius: 20px;
                padding: 2rem;
                margin-bottom: 2rem;
                border: 1px solid rgba(226, 232, 240, 0.8);
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
            }

            .page-header h2 {
                font-size: 2rem;
                font-weight: 700;
                background: linear-gradient(135deg, #3b82f6, #8b5cf6);
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
                margin-bottom: 0.5rem;
            }

            .btn-primary-custom {
                background: linear-gradient(135deg, #3b82f6, #1d4ed8);
                border: none;
                border-radius: 12px;
                padding: 12px 28px;
                font-weight: 600;
                color: white;
                transition: all 0.3s ease;
                box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
            }

            .btn-primary-custom:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
            }

            /* Group Card Styles */
            .group-card {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                border-radius: 16px;
                padding: 2rem;
                margin-bottom: 1.5rem;
                border: 1px solid rgba(226, 232, 240, 0.8);
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
                transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                cursor: pointer;
                position: relative;
                overflow: hidden;
            }

            .group-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(59, 130, 246, 0.1), transparent);
                transition: left 0.6s ease;
            }

            .group-card:hover {
                transform: translateY(-8px) scale(1.02);
                box-shadow: 0 12px 32px rgba(0, 0, 0, 0.12);
            }

            .group-card:hover::before {
                left: 100%;
            }

            .group-icon-box {
                width: 80px;
                height: 80px;
                border-radius: 16px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 2.5rem;
                flex-shrink: 0;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            }

            .group-title {
                font-size: 1.5rem;
                font-weight: 700;
                color: #1e293b;
                margin-bottom: 0.5rem;
            }

            .group-meta {
                font-size: 1rem;
                color: #64748b;
            }

            /* Document Card Styles */
            .document-card {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                border-radius: 16px;
                padding: 1.5rem;
                margin-bottom: 1.5rem;
                border: 1px solid rgba(226, 232, 240, 0.8);
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
                transition: all 0.3s ease;
            }

            .document-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
            }

            .file-icon-box {
                width: 60px;
                height: 60px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 2rem;
                flex-shrink: 0;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            }

            .doc-title {
                font-size: 1.15rem;
                font-weight: 600;
                color: #1e293b;
                margin-bottom: 0.5rem;
            }

            .doc-meta {
                font-size: 0.9rem;
                color: #64748b;
            }

            .badge-custom {
                padding: 6px 14px;
                border-radius: 8px;
                font-weight: 600;
                font-size: 0.85rem;
            }

            .btn-action {
                padding: 8px 16px;
                border-radius: 10px;
                font-size: 0.9rem;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .btn-action:hover {
                transform: translateY(-2px);
            }

            .search-box {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                border-radius: 16px;
                padding: 1.5rem;
                margin-bottom: 2rem;
                border: 1px solid rgba(226, 232, 240, 0.8);
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
            }

            .breadcrumb-custom {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(20px);
                border-radius: 12px;
                padding: 1rem 1.5rem;
                margin-bottom: 1.5rem;
                border: 1px solid rgba(226, 232, 240, 0.8);
            }

            .breadcrumb-custom a {
                color: #3b82f6;
                text-decoration: none;
                font-weight: 500;
            }

            .breadcrumb-custom a:hover {
                text-decoration: underline;
            }

            .modal-content {
                border-radius: 20px;
                border: none;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
            }

            .modal-header {
                background: linear-gradient(135deg, #3b82f6, #8b5cf6);
                color: white;
                border-radius: 20px 20px 0 0;
                padding: 1.5rem 2rem;
            }

            .modal-body {
                padding: 2rem;
            }

            .form-label {
                font-weight: 600;
                color: #334155;
                margin-bottom: 0.5rem;
            }

            .form-control, .form-select {
                border-radius: 12px;
                border: 2px solid #e2e8f0;
                padding: 12px 16px;
                transition: all 0.3s ease;
            }

            .form-control:focus, .form-select:focus {
                border-color: #3b82f6;
                box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
            }

            .empty-state {
                text-align: center;
                padding: 4rem 2rem;
                background: rgba(255, 255, 255, 0.95);
                border-radius: 20px;
                border: 1px solid rgba(226, 232, 240, 0.8);
            }

            .empty-state i {
                font-size: 5rem;
                color: #cbd5e1;
                margin-bottom: 1.5rem;
            }

            @media (max-width: 992px) {
                .main-content {
                    margin-left: 76px;
                    padding: 24px;
                }
                .header {
                    margin-left: 76px;
                }
            }

            @media (max-width: 576px) {
                .main-content {
                    margin-left: 60px;
                    padding: 16px;
                }
                .header {
                    margin-left: 60px;
                }
            }
        </style>

        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-folder-open me-2"></i>Thư viện tài liệu';
        </script>
    </head>

    <body>
        <%@ include file="sidebar.jsp" %>
        <%@ include file="header.jsp" %>

        <div class="main-content">
            <!-- Page Header -->
            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2><i class="fa-solid fa-folder-open me-2"></i>Thư viện tài liệu</h2>
                        <p class="text-muted mb-0">Quản lý tài liệu theo nhóm chuyên biệt</p>
                    </div>
                    <% if (nhomId == null) { %>
                    <button class="btn btn-primary-custom" data-bs-toggle="modal" data-bs-target="#addGroupModal">
                        <i class="fa-solid fa-plus me-2"></i>Thêm nhóm tài liệu
                    </button>
                    <% } else { %>
                    <button class="btn btn-primary-custom" data-bs-toggle="modal" data-bs-target="#uploadModal">
                        <i class="fa-solid fa-cloud-arrow-up me-2"></i>Tải lên tài liệu
                    </button>
                    <% } %>
                </div>
            </div>

            <!-- Success/Error Messages -->
            <% if (success != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i><%= success %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-exclamation me-2"></i><%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <!-- Breadcrumb -->
            <% if (nhomId != null && nhomHienTai != null) { %>
            <div class="breadcrumb-custom">
                <a href="dsTailieu"><i class="fa-solid fa-home me-2"></i>Trang chủ</a>
                <span class="mx-2">/</span>
                <span class="text-muted"><%= nhomHienTai.getTenNhom() %></span>
            </div>

            <!-- Search trong nhóm -->
            <div class="search-box">
                <form action="dsTailieu" method="get" class="row g-3">
                    <input type="hidden" name="nhomId" value="<%= nhomId %>">
                    <div class="col-md-10">
                        <input type="text" name="search" class="form-control" 
                               placeholder="Tìm kiếm tài liệu trong <%= nhomHienTai.getTenNhom() %>..." 
                               value="<%= currentSearch != null ? currentSearch : "" %>">
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary-custom w-100">
                            <i class="fa-solid fa-magnifying-glass me-2"></i>Tìm
                        </button>
                    </div>
                </form>
            </div>
            <% } %>

            <!-- Nội dung chính -->
            <% if (nhomId == null) { %>
                <!-- Hiển thị danh sách nhóm tài liệu -->
                <% if (danhSachNhom.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fa-solid fa-folder-open"></i>
                    <h4 class="text-muted mb-2">Chưa có nhóm tài liệu nào</h4>
                    <p class="text-muted">Bắt đầu bằng cách tạo nhóm tài liệu đầu tiên</p>
                </div>
                <% } else { %>
                <div class="row">
                    <% for (NhomTaiLieu nhom : danhSachNhom) { %>
                    <div class="col-md-6 col-lg-4">
                        <div class="group-card" onclick="window.location.href='dsTailieu?nhomId=<%= nhom.getId() %>'">
                            <div class="d-flex align-items-start">
                                <div class="group-icon-box me-3" style="background: <%= nhom.getMauSac() %>15;">
                                    <i class="fa-solid <%= nhom.getIcon() %>" style="color: <%= nhom.getMauSac() %>"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="group-title"><%= nhom.getTenNhom() %></div>
                                    <% if (nhom.getMoTa() != null && !nhom.getMoTa().isEmpty()) { %>
                                    <p class="text-muted small mb-2"><%= nhom.getMoTa() %></p>
                                    <% } %>
                                    <div class="group-meta">
                                        <span class="badge bg-primary"><%= nhom.getSoLuongTaiLieu() %> tài liệu</span>
                                    </div>
                                </div>
                                <div class="dropdown" onclick="event.stopPropagation()">
                                    <button class="btn btn-sm btn-light" data-bs-toggle="dropdown">
                                        <i class="fa-solid fa-ellipsis-vertical"></i>
                                    </button>
                                    <ul class="dropdown-menu">
                                        <li><a class="dropdown-item" href="#" onclick="editGroup(<%= nhom.getId() %>, '<%= nhom.getTenNhom().replace("'", "\\'") %>', '<%= nhom.getMoTa() != null ? nhom.getMoTa().replace("'", "\\'") : "" %>', '<%= nhom.getIcon() %>', '<%= nhom.getMauSac() %>', <%= nhom.getThuTu() %>); return false;">
                                            <i class="fa-solid fa-pen-to-square me-2"></i>Sửa
                                        </a></li>
                                        <li><a class="dropdown-item text-danger" href="#" onclick="confirmDeleteGroup(<%= nhom.getId() %>, '<%= nhom.getTenNhom() %>'); return false;">
                                            <i class="fa-solid fa-trash me-2"></i>Xóa
                                        </a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>

            <% } else { %>
                <!-- Hiển thị danh sách tài liệu trong nhóm -->
                <% if (danhSachTaiLieu.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fa-solid fa-file"></i>
                    <h4 class="text-muted mb-2">Chưa có tài liệu nào trong nhóm này</h4>
                    <p class="text-muted">Bắt đầu bằng cách tải lên tài liệu đầu tiên</p>
                </div>
                <% } else { %>
                <div class="row">
                    <% for (TaiLieu doc : danhSachTaiLieu) { %>
                    <div class="col-12">
                        <div class="document-card">
                            <div class="row align-items-center">
                                <div class="col-auto">
                                    <div class="file-icon-box" style="background: <%= doc.getFileIconColor() %>15;">
                                        <i class="fa-solid <%= doc.getFileIcon() %>" style="color: <%= doc.getFileIconColor() %>"></i>
                                    </div>
                                </div>
                                <div class="col">
                                    <div class="doc-title"><%= doc.getTenTaiLieu() %></div>
                                    <div class="doc-meta">
                                        <% if (doc.getLoaiTaiLieu() != null) { %>
                                        <span class="badge-custom bg-primary me-2"><%= doc.getLoaiTaiLieu() %></span>
                                        <% } %>
                                        <i class="fa-solid fa-user me-1"></i><%= doc.getTenNguoiTao() != null ? doc.getTenNguoiTao() : "Không rõ" %>
                                        <span class="mx-2">•</span>
                                        <i class="fa-solid fa-calendar me-1"></i><%= doc.getNgayTao() %>
                                    </div>
                                    <% if (doc.getMoTa() != null && !doc.getMoTa().isEmpty()) { %>
                                    <p class="text-muted small mt-2 mb-0"><%= doc.getMoTa() %></p>
                                    <% } %>
                                    <div class="mt-2">
                                        <small class="text-muted">
                                            <i class="fa-solid fa-database me-1"></i><%= doc.getFileSizeFormatted() %>
                                            <span class="mx-2">•</span>
                                            <i class="fa-solid fa-eye me-1"></i><%= doc.getLuotXem() %> lượt xem
                                            <span class="mx-2">•</span>
                                            <i class="fa-solid fa-download me-1"></i><%= doc.getLuotTai() %> lượt tải
                                        </small>
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <div class="btn-group" role="group">
                                        <a href="downloadTailieu?id=<%= doc.getId() %>" 
                                           class="btn btn-action btn-success" title="Tải xuống">
                                            <i class="fa-solid fa-download"></i>
                                        </a>
                                        <button type="button" class="btn btn-action btn-warning" 
                                                onclick="editDocument(<%= doc.getId() %>, '<%= doc.getTenTaiLieu().replace("'", "\\'") %>', '<%= doc.getLoaiTaiLieu() != null ? doc.getLoaiTaiLieu() : "" %>', '<%= doc.getMoTa() != null ? doc.getMoTa().replace("'", "\\'") : "" %>')"
                                                title="Chỉnh sửa">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </button>
                                        <button type="button" class="btn btn-action btn-danger" 
                                                onclick="confirmDelete(<%= doc.getId() %>, '<%= doc.getTenTaiLieu() %>', <%= nhomId %>)"
                                                title="Xóa">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            <% } %>
        </div>

        <!-- Modal thêm nhóm tài liệu -->
        <div class="modal fade" id="addGroupModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fa-solid fa-folder-plus me-2"></i>Thêm nhóm tài liệu mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <form action="themNhomTailieu" method="post">
                        <div class="modal-body">
                            <div class="mb-3">
                                <label class="form-label">Tên nhóm <span class="text-danger">*</span></label>
                                <input type="text" name="tenNhom" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Mô tả</label>
                                <textarea name="moTa" class="form-control" rows="3"></textarea>
                            </div>
                            <div class="row">
                                <div class="col-md-4">
                                    <label class="form-label">Icon</label>
                                    <div class="d-flex align-items-center mb-2">
                                        <div class="icon-preview me-2" id="iconPreview" style="font-size: 2rem; width: 50px; height: 50px; display: flex; align-items: center; justify-content: center; border: 2px solid #e2e8f0; border-radius: 8px;">
                                            <i class="fa-solid fa-folder" style="color: #3b82f6;"></i>
                                        </div>
                                        <small class="text-muted">Xem trước</small>
                                    </div>
                                    <select name="icon" id="iconSelect" class="form-select" onchange="updateIconPreview('iconSelect', 'iconPreview')">
                                        <option value="fa-folder">📁 Thư mục</option>
                                        <option value="fa-chart-line">📈 Biểu đồ</option>
                                        <option value="fa-file-lines">📄 Tài liệu</option>
                                        <option value="fa-scale-balanced">⚖️ Luật</option>
                                        <option value="fa-file-contract">📜 Hợp đồng</option>
                                        <option value="fa-book">📖 Sách</option>
                                        <option value="fa-money-check-dollar">💵 Tiền</option>
                                        <option value="fa-folder-open">📂 Thư mục mở</option>
                                        <option value="fa-file-pdf">📝 PDF</option>
                                        <option value="fa-file-word">📄 Word</option>
                                        <option value="fa-file-excel">📊 Excel</option>
                                        <option value="fa-briefcase">💼 Cặp</option>
                                        <option value="fa-clipboard">📋 Bảng ghi</option>
                                        <option value="fa-certificate">🎖️ Chứng chỉ</option>
                                        <option value="fa-stamp">✅ Con dấu</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Màu sắc</label>
                                    <input type="color" name="mauSac" class="form-control" value="#3b82f6">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Thứ tự</label>
                                    <input type="number" name="thuTu" class="form-control" value="0" min="0">
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-primary-custom">
                                <i class="fa-solid fa-plus me-2"></i>Thêm nhóm
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Modal sửa nhóm tài liệu -->
        <div class="modal fade" id="editGroupModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fa-solid fa-pen-to-square me-2"></i>Chỉnh sửa nhóm tài liệu</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <form action="suaNhomTailieu" method="post">
                        <input type="hidden" name="id" id="editGroupId">
                        <div class="modal-body">
                            <div class="mb-3">
                                <label class="form-label">Tên nhóm <span class="text-danger">*</span></label>
                                <input type="text" name="tenNhom" id="editGroupTen" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Mô tả</label>
                                <textarea name="moTa" id="editGroupMoTa" class="form-control" rows="3"></textarea>
                            </div>
                            <div class="row">
                                <div class="col-md-4">
                                    <label class="form-label">Icon</label>
                                    <div class="d-flex align-items-center mb-2">
                                        <div class="icon-preview me-2" id="iconPreviewEdit" style="font-size: 2rem; width: 50px; height: 50px; display: flex; align-items: center; justify-content: center; border: 2px solid #e2e8f0; border-radius: 8px;">
                                            <i class="fa-solid fa-folder" id="editIconPreviewIcon" style="color: #3b82f6;"></i>
                                        </div>
                                        <small class="text-muted">Xem trước</small>
                                    </div>
                                    <select name="icon" id="editGroupIcon" class="form-select" onchange="updateIconPreview('editGroupIcon', 'iconPreviewEdit', 'editGroupMauSac')">
                                        <option value="fa-folder">📁 Thư mục</option>
                                        <option value="fa-chart-line">📈 Biểu đồ</option>
                                        <option value="fa-file-lines">📄 Tài liệu</option>
                                        <option value="fa-scale-balanced">⚖️ Luật</option>
                                        <option value="fa-file-contract">📜 Hợp đồng</option>
                                        <option value="fa-book">📖 Sách</option>
                                        <option value="fa-money-check-dollar">💵 Tiền</option>
                                        <option value="fa-folder-open">📂 Thư mục mở</option>
                                        <option value="fa-file-pdf">📝 PDF</option>
                                        <option value="fa-file-word">📄 Word</option>
                                        <option value="fa-file-excel">📊 Excel</option>
                                        <option value="fa-briefcase">💼 Cặp</option>
                                        <option value="fa-clipboard">📋 Bảng ghi</option>
                                        <option value="fa-certificate">🎖️ Chứng chỉ</option>
                                        <option value="fa-stamp">✅ Con dấu</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Màu sắc</label>
                                    <input type="color" name="mauSac" id="editGroupMauSac" class="form-control">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Thứ tự</label>
                                    <input type="number" name="thuTu" id="editGroupThuTu" class="form-control" min="0">
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-primary-custom">
                                <i class="fa-solid fa-floppy-disk me-2"></i>Lưu thay đổi
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Modal tải lên tài liệu -->
        <% if (nhomId != null) { %>
        <div class="modal fade" id="uploadModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fa-solid fa-cloud-arrow-up me-2"></i>Tải lên tài liệu mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <form action="uploadTailieu" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="nhomId" value="<%= nhomId %>">
                        <div class="modal-body">
                            <div class="mb-3">
                                <label class="form-label">Tên tài liệu <span class="text-danger">*</span></label>
                                <input type="text" name="tenTaiLieu" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Loại tài liệu</label>
                                <select name="loaiTaiLieu" class="form-select">
                                    <option value="Báo cáo">Báo cáo</option>
                                    <option value="Mẫu đơn">Mẫu đơn</option>
                                    <option value="Quy định">Quy định</option>
                                    <option value="Chính sách">Chính sách</option>
                                    <option value="Hướng dẫn">Hướng dẫn</option>
                                    <option value="Đề nghị thanh toán">Đề nghị thanh toán</option>
                                    <option value="Đề xuất thanh toán">Đề xuất thanh toán</option>
                                    <option value="Hợp đồng">Hợp đồng</option>
                                    <option value="MOU">MOU</option>
                                    <option value="Quyết định">Quyết định</option>
                                    <option value="Thông báo">Thông báo</option>
                                    <option value="Khác">Khác</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Mô tả</label>
                                <textarea name="moTa" class="form-control" rows="3"></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Chọn file <span class="text-danger">*</span></label>
                                <input type="file" name="fileUpload" class="form-control" required>
                                <small class="text-muted">Kích thước tối đa: 50MB</small>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-primary-custom">
                                <i class="fa-solid fa-upload me-2"></i>Tải lên
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Modal sửa tài liệu -->
        <div class="modal fade" id="editModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fa-solid fa-pen-to-square me-2"></i>Chỉnh sửa tài liệu</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <form action="updateTailieu" method="post">
                        <input type="hidden" name="id" id="editId">
                        <% if (nhomId != null) { %>
                        <input type="hidden" name="nhomId" value="<%= nhomId %>">
                        <% } %>
                        <div class="modal-body">
                            <div class="mb-3">
                                <label class="form-label">Tên tài liệu <span class="text-danger">*</span></label>
                                <input type="text" name="tenTaiLieu" id="editTenTaiLieu" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Loại tài liệu</label>
                                <select name="loaiTaiLieu" id="editLoaiTaiLieu" class="form-select">
                                    <option value="Báo cáo">Báo cáo</option>
                                    <option value="Mẫu đơn">Mẫu đơn</option>
                                    <option value="Quy định">Quy định</option>
                                    <option value="Chính sách">Chính sách</option>
                                    <option value="Hướng dẫn">Hướng dẫn</option>
                                    <option value="Đề nghị thanh toán">Đề nghị thanh toán</option>
                                    <option value="Đề xuất thanh toán">Đề xuất thanh toán</option>
                                    <option value="Hợp đồng">Hợp đồng</option>
                                    <option value="MOU">MOU</option>
                                    <option value="Quyết định">Quyết định</option>
                                    <option value="Thông báo">Thông báo</option>
                                    <option value="Khác">Khác</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Mô tả</label>
                                <textarea name="moTa" id="editMoTa" class="form-control" rows="3"></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-primary-custom">
                                <i class="fa-solid fa-floppy-disk me-2"></i>Lưu thay đổi
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script>
            // Update icon preview function
            function updateIconPreview(selectId, previewId, colorId) {
                const select = document.getElementById(selectId);
                const preview = document.getElementById(previewId);
                const iconClass = select.value;
                
                // Get color
                let color = '#3b82f6';
                if (colorId) {
                    const colorInput = document.getElementById(colorId);
                    if (colorInput) {
                        color = colorInput.value;
                    }
                }
                
                // Update preview
                preview.innerHTML = '<i class="fa-solid ' + iconClass + '" style="color: ' + color + ';"></i>';
            }

            // Update icon preview when color changes
            $('#iconSelect').parent().parent().find('input[type="color"]').on('change', function() {
                updateIconPreview('iconSelect', 'iconPreview');
            });

            // Edit group function
            function editGroup(id, ten, moTa, icon, mauSac, thuTu) {
                $('#editGroupId').val(id);
                $('#editGroupTen').val(ten);
                $('#editGroupMoTa').val(moTa);
                $('#editGroupIcon').val(icon);
                $('#editGroupMauSac').val(mauSac);
                $('#editGroupThuTu').val(thuTu);
                
                // Update icon preview
                updateIconPreview('editGroupIcon', 'iconPreviewEdit', 'editGroupMauSac');
                
                $('#editGroupModal').modal('show');
            }

            // Update preview when color changes in edit modal
            $('#editGroupMauSac').on('change', function() {
                updateIconPreview('editGroupIcon', 'iconPreviewEdit', 'editGroupMauSac');
            });

            // Confirm delete group
            function confirmDeleteGroup(id, ten) {
                Swal.fire({
                    title: 'Xác nhận xóa?',
                    html: 'Bạn có chắc muốn xóa nhóm <strong>"' + ten + '"</strong>?<br><small class="text-muted">Các tài liệu trong nhóm sẽ không bị xóa</small>',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#dc3545',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Xóa',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = 'xoaNhomTailieu?id=' + id;
                    }
                });
            }

            // Edit document function
            function editDocument(id, ten, loai, moTa) {
                $('#editId').val(id);
                $('#editTenTaiLieu').val(ten);
                $('#editLoaiTaiLieu').val(loai);
                $('#editMoTa').val(moTa);
                $('#editModal').modal('show');
            }

            // Confirm delete document
            function confirmDelete(id, ten, nhomId) {
                Swal.fire({
                    title: 'Xác nhận xóa?',
                    html: 'Bạn có chắc muốn xóa tài liệu <strong>"' + ten + '"</strong>?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#dc3545',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Xóa',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = 'deleteTailieu?id=' + id + '&nhomId=' + nhomId;
                    }
                });
            }

            // Auto-dismiss alerts
            $(function () {
                setTimeout(function () {
                    $('.alert').fadeOut('slow');
                }, 5000);
            });
        </script>
    </body>
</html>
