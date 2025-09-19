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
                    <div class="project-list">
                        <!-- Lặp lại cho các dự án khác -->
                        <%
                            List<Map<String, Object>> projects = (List<Map<String, Object>>) request.getAttribute("projects");
                            if (projects != null) {
                                for (Map<String, Object> project : projects) {
                        %>
                        <div class="project-card" data-id="<%= project.get("id") %>" onclick="goToProjectTask(<%= project.get("id") %>, event)">
                            <div class="project-header d-flex justify-content-between align-items-center">
                                <span class="project-title"><%= project.get("ten_du_an") %></span>
                                <div class="project-actions">
                                    <button class="btn btn-info" onclick="showProjectDetail(event, <%= project.get("id") %>)">
                                        <i class="fa-solid fa-eye"></i>
                                    </button>
                                    <button class="btn btn-warning" onclick="editProject(<%= project.get("id") %>); event.stopPropagation();">
                                        <i class="fa-solid fa-pen"></i>
                                    </button>
                                    <button class="btn btn-danger delete-project-btn" data-id="<%= project.get("id") %>">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="project-desc mt-2 text-muted">Mô tả: <%= project.get("mo_ta") %></div>
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
                        <button type="button" class="btn btn-primary" onclick="editProjectFromDetail()">
                            <i class="fa-solid fa-edit"></i> Chỉnh sửa
                        </button>
                    </div>
                </div>
            </div>
        </div>
        <script>
            function goToProjectTask(projectId, event) {
                // Ngăn click vào nút Xem/Sửa/Xóa bị trigger
                if (event.target.tagName.toLowerCase() === 'button' ||
                        event.target.closest('button')) {
                    return;
                }
                // Chuyển hướng sang servlet khác
                window.location.href = "dsCongviecDuan?projectId=" + projectId;
            }

            $(document).on('click', '.delete-project-btn', function () {
                let id = $(this).data('id');
                Swal.fire({
                    title: 'Xác nhận xóa?',
                    text: 'Bạn có chắc chắn muốn xóa dự án này?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Xóa',
                    cancelButtonText: 'Hủy',
                    confirmButtonColor: '#dc3545'
                }).then((result) => {
                    if (result.isConfirmed) {
                        $.post('./projectDelete', {id: id}, function (response) {
                            if (response.success) {
                                showToast('success', 'Đã xóa dự án thành công!');
                                setTimeout(function () {
                                    location.reload();
                                }, 1500);
                            } else {
                                showToast('error', response.message || 'Xóa thất bại!');
                            }
                        }, 'json').fail(function () {
                            showToast('error', 'Lỗi khi xóa dự án!');
                        });
                    }
                });
            });
        </script>
        <script>
            // Dữ liệu mẫu cho dự án (thay thế bằng dữ liệu thực từ backend)
            const sampleProjects = {
                '1': {
                    id: 1,
                    ten_du_an: 'Dự án code Web',
                    mo_ta: 'Xây dựng website quản lý nhân sự',
                    ngay_bat_dau: '2025-01-15',
                    ngay_ket_thuc: '2025-12-31',
                    ngay_tao: '2025-01-10',
                    tong_cong_viec: 8,
                    tong_nguoi: 12
                }
            };

            let currentProjectId = null;

            function showProjectDetail(event, projectId) {
                event.stopPropagation();
                currentProjectId = projectId;

                // Lấy thông tin dự án từ dữ liệu mẫu (thay thế bằng AJAX call thực tế)
                const project = sampleProjects[projectId];

                if (project) {
                    document.getElementById('detailTenDuAn').textContent = project.ten_du_an;
                    document.getElementById('detailMoTa').textContent = project.mo_ta || 'Chưa có mô tả';
                    document.getElementById('detailNgayBatDau').textContent = formatDate(project.ngay_bat_dau);
                    document.getElementById('detailNgayKetThuc').textContent = formatDate(project.ngay_ket_thuc);
                    document.getElementById('detailNgayTao').textContent = formatDate(project.ngay_tao);
                    document.getElementById('detailTongCongViec').textContent = project.tong_cong_viec;
                    document.getElementById('detailTongNguoi').textContent = project.tong_nguoi;
                }

                $("#modalProjectDetail").modal("show");
            }

            function editProject(id) {
                currentProjectId = id;
                // Load dữ liệu dự án lên modal để sửa
                const project = sampleProjects[id];

                $("#projectForm")[0].reset();
                $("#projectForm input[name='id']").val(id);

                if (project) {
                    $("#projectForm input[name='ten_du_an']").val(project.ten_du_an);
                    $("#projectForm textarea[name='mo_ta']").val(project.mo_ta);
                    $("#projectForm input[name='ngay_bat_dau']").val(project.ngay_bat_dau);
                    $("#projectForm input[name='ngay_ket_thuc']").val(project.ngay_ket_thuc);
                }

                $("#modalProject").modal("show");
            }

            function editProjectFromDetail() {
                $("#modalProjectDetail").modal("hide");
                setTimeout(() => {
                    editProject(currentProjectId);
                }, 300);
            }

            function formatDate(dateString) {
                if (!dateString)
                    return 'Chưa xác định';
                const date = new Date(dateString);
                return date.toLocaleDateString('vi-VN');
            }

            // Validation cho form dự án
            $("#projectForm").on("submit", function (e) {
                e.preventDefault();

                const startDate = new Date($("#projectForm input[name='ngay_bat_dau']").val());
                const endDate = new Date($("#projectForm input[name='ngay_ket_thuc']").val());

                if (startDate && endDate && startDate > endDate) {
                    alert("Ngày bắt đầu không thể sau ngày kết thúc!");
                    return;
                }

                // Gửi AJAX thêm/sửa dự án
                $("#modalProject").modal("hide");
                alert("Đã lưu dự án thành công!");

                // Thực tế: gửi dữ liệu đến server và reload trang
            });

            // Set ngày tối thiểu là hôm nay cho các trường ngày
            document.addEventListener('DOMContentLoaded', function () {
                const today = new Date().toISOString().split('T')[0];
                const startDateInput = document.querySelector('input[name="ngay_bat_dau"]');
                const endDateInput = document.querySelector('input[name="ngay_ket_thuc"]');

                if (startDateInput)
                    startDateInput.setAttribute('min', today);
                if (endDateInput)
                    endDateInput.setAttribute('min', today);

                // Khi thay đổi ngày bắt đầu, update ngày kết thúc tối thiểu
                if (startDateInput) {
                    startDateInput.addEventListener('change', function () {
                        if (endDateInput) {
                            endDateInput.setAttribute('min', this.value);
                        }
                    });
                }
            });
        </script>
    </body>
</html>