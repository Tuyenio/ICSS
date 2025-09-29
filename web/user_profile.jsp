<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>QLNS - Hồ sơ cá nhân</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            html, body {
                font-family: 'Inter', 'Roboto', Arial, sans-serif !important;
                background: #f4f6fa;
                color: #23272f;
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
            }
            .profile-label {
                min-width: 120px;
                display: inline-block;
                font-weight: 500;
                color: #495057;
            }
            .profile-value {
                font-weight: 400;
            }
            .profile-section {
                background: #f8fafc;
                border-radius: 10px;
                padding: 18px 18px 10px 18px;
                margin-bottom: 12px;
            }
        </style>
        <script>
            var USER_PAGE_TITLE = '<i class="fa-solid fa-user-circle me-2"></i>Hồ sơ cá nhân';
        </script>
    </head>

    <%
    // Lấy dữ liệu từ Servlet
    Map<String,Object> hs = (Map<String,Object>) request.getAttribute("hs");
    String error = (String) request.getAttribute("error");

    String avatarUrl = (hs != null && hs.get("avatar_url") != null) ? hs.get("avatar_url").toString() : "https://ui-avatars.com/api/?name=User";    String hoTen = (hs != null && hs.get("ho_ten") != null) ? hs.get("ho_ten").toString() : "Chưa cập nhật";
    String email = (hs != null && hs.get("email") != null) ? hs.get("email").toString() : "";
    String soDienThoai = (hs != null && hs.get("so_dien_thoai") != null) ? hs.get("so_dien_thoai").toString() : "";
    String gioiTinh = (hs != null && hs.get("gioi_tinh") != null) ? hs.get("gioi_tinh").toString() : "";
    String ngaySinh = (hs != null && hs.get("ngay_sinh") != null) ? hs.get("ngay_sinh").toString() : "";
    String tenPhongBan = (hs != null && hs.get("ten_phong_ban") != null) ? hs.get("ten_phong_ban").toString() : "";
    String chucVu = (hs != null && hs.get("chuc_vu") != null) ? hs.get("chuc_vu").toString() : "";
    String ngayVaoLam = (hs != null && hs.get("ngay_vao_lam") != null) ? hs.get("ngay_vao_lam").toString() : "";
    String trangThaiLV = (hs != null && hs.get("trang_thai_lam_viec") != null) ? hs.get("trang_thai_lam_viec").toString() : "";
    String vaiTro = (hs != null && hs.get("vai_tro") != null) ? hs.get("vai_tro").toString() : "";
    String statusBadgeClass = (hs != null && hs.get("statusBadgeClass") != null) ? hs.get("statusBadgeClass").toString() : "bg-secondary";
    String roleBadgeClass = (hs != null && hs.get("roleBadgeClass") != null) ? hs.get("roleBadgeClass").toString() : "bg-info text-dark";
    String ngayTao = (hs != null && hs.get("ngay_tao") != null) ? hs.get("ngay_tao").toString() : "";
    %>

    <body>
        <%@ include file="sidebarnv.jsp" %>
        <%@ include file="user_header.jsp" %>

        <div class="main-content">
            <div class="main-box mb-3">
                <div class="d-flex justify-content-between align-items-center">
                    <h3 class="mb-0"><i class="fa-solid fa-user-circle me-2"></i>Hồ sơ cá nhân</h3>
                    <button class="btn btn-primary" id="btnEditProfile" type="button" onclick="enableEdit()"><i class="fa fa-pen"></i> Chỉnh sửa</button>
                </div>

                <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger mt-3"><%= error %></div>
                <% } %>
                <% String success = (String) request.getAttribute("success"); %>
                <% if (success != null && !success.isEmpty()) { %>
                <div class="alert alert-success mt-3"><%= success %></div>
                <% } %>

                <form id="profileForm" class="row mt-2" method="post" action="apiHoso" autocomplete="off">
                    <!-- Avatar + tên + email -->
                    <div class="col-md-3 text-center">
                        <div id="avatarView">
                            <img src="<%= avatarUrl %>" class="rounded-circle mb-2" width="220" id="profileAvatar" alt="Avatar">
                        </div>
                        <div id="avatarEdit" style="display:none;">
                            <img src="<%= avatarUrl %>" class="rounded-circle mb-2" width="220" id="avatarPreview" alt="Avatar">
                            <input type="url" class="form-control mt-2" name="avatar_url" id="avatarUrlInput" 
                                   placeholder="Nhập URL ảnh (VD: https://i.postimg.cc/FsFtLgZ4/DSC-0130.jpg)" 
                                   value="<%= avatarUrl != null ? avatarUrl : "" %>">
                            <small class="text-muted">Hỗ trợ: Postimg, Imgur, Google Drive, v.v.</small>
                        </div>
                        <div class="fw-bold fs-5" id="profileNameView"><%= hoTen %></div>
                        <input type="text" class="form-control fw-bold fs-5 mb-2" name="ho_ten" id="profileNameEdit" value="<%= hoTen %>" style="display:none;">
                        <div class="text-muted small" id="profileEmail"><%= email %></div>
                    </div>

                    <div class="col-md-9">
                        <div class="profile-section">
                            <span class="profile-label">SĐT:</span>
                            <span class="profile-value" id="profilePhoneView"><%= soDienThoai %></span>
                            <input type="text" class="form-control mb-2" name="so_dien_thoai" id="profilePhoneEdit" value="<%= soDienThoai %>" style="display:none;">
                            <br>

                            <span class="profile-label">Giới tính:</span>
                            <span class="profile-value" id="profileGenderView"><%= gioiTinh %></span>
                            <select class="form-select mb-2" name="gioi_tinh" id="profileGenderEdit" style="display:none;">
                                <option value="Nam" <%= "Nam".equals(gioiTinh)?"selected":"" %>>Nam</option>
                                <option value="Nữ" <%= "Nữ".equals(gioiTinh)?"selected":"" %>>Nữ</option>
                                <option value="Khác" <%= "Khác".equals(gioiTinh)?"selected":"" %>>Khác</option>
                            </select>
                            <br>

                            <span class="profile-label">Ngày sinh:</span>
                            <span class="profile-value" id="profileBirthView">
                                <%= (ngaySinh != null && !ngaySinh.isEmpty() && !"null".equals(ngaySinh)) ? ngaySinh : "Chưa cập nhật" %>
                            </span>
                            <input type="date" class="form-control mb-2" name="ngay_sinh" id="profileBirthEdit" value="<%= (ngaySinh!=null && !ngaySinh.isEmpty() && ngaySinh.matches("\\d{2}/\\d{2}/\\d{4}")) ? (ngaySinh.substring(6,10)+"-"+ngaySinh.substring(3,5)+"-"+ngaySinh.substring(0,2)) : "" %>" style="display:none;">
                            <br>

                            <span class="profile-label">Phòng ban:</span>
                            <span class="profile-value" id="profileDept"><%= tenPhongBan %></span><br>

                            <span class="profile-label">Chức vụ:</span>
                            <span class="profile-value" id="profilePosition"><%= chucVu %></span><br>

                            <span class="profile-label">Ngày vào làm:</span>
                            <span class="profile-value" id="profileStart"><%= ngayVaoLam %></span><br>

                            <span class="profile-label">Trạng thái:</span>
                            <span class="profile-value" id="profileStatus">
                                <span class="badge <%= statusBadgeClass %>"><%= trangThaiLV %></span>
                            </span><br>

                            <span class="profile-label">Vai trò:</span>
                            <span class="profile-value" id="profileRole">
                                <span class="badge <%= roleBadgeClass %>"><%= vaiTro %></span>
                            </span>
                        </div>

                        <div class="profile-section">
                            <span class="profile-label">Ngày tạo tài khoản:</span>
                            <span class="profile-value" id="profileCreated"><%= ngayTao %></span><br>
                        </div>

                        <div id="editBtnGroup" style="display:none;">
                            <button type="submit" class="btn btn-success me-2"><i class="fa fa-save"></i> Lưu</button>
                            <button type="button" class="btn btn-secondary" onclick="disableEdit()">Hủy</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
        function enableEdit() {
            document.getElementById('btnEditProfile').style.display = 'none';
            document.getElementById('editBtnGroup').style.display = '';
            // Avatar
            document.getElementById('avatarView').style.display = 'none';
            document.getElementById('avatarEdit').style.display = '';
            // Họ tên
            document.getElementById('profileNameView').style.display = 'none';
            document.getElementById('profileNameEdit').style.display = '';
            // SĐT
            document.getElementById('profilePhoneView').style.display = 'none';
            document.getElementById('profilePhoneEdit').style.display = '';
            // Giới tính
            document.getElementById('profileGenderView').style.display = 'none';
            document.getElementById('profileGenderEdit').style.display = '';
            // Ngày sinh
            document.getElementById('profileBirthView').style.display = 'none';
            document.getElementById('profileBirthEdit').style.display = '';
        }
        function disableEdit() {
            document.getElementById('btnEditProfile').style.display = '';
            document.getElementById('editBtnGroup').style.display = 'none';
            document.getElementById('avatarView').style.display = '';
            document.getElementById('avatarEdit').style.display = 'none';
            document.getElementById('profileNameView').style.display = '';
            document.getElementById('profileNameEdit').style.display = 'none';
            document.getElementById('profilePhoneView').style.display = '';
            document.getElementById('profilePhoneEdit').style.display = 'none';
            document.getElementById('profileGenderView').style.display = '';
            document.getElementById('profileGenderEdit').style.display = 'none';
            document.getElementById('profileBirthView').style.display = '';
            document.getElementById('profileBirthEdit').style.display = 'none';
        }
        // Xem trước avatar khi nhập URL
        document.addEventListener('DOMContentLoaded', function() {
            var avatarUrlInput = document.getElementById('avatarUrlInput');
            if (avatarUrlInput) {
                avatarUrlInput.addEventListener('input', function(e) {
                    var url = e.target.value.trim();
                    if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
                        document.getElementById('avatarPreview').src = url;
                    }
                });
            }
        });
        </script>
    </body>
</html>