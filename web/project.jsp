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
    <style>
        body { background: #f4f6fa; }
        .main-content { padding: 36px 36px 24px 36px; min-height: 100vh; margin-left: 240px; }
        .project-card { background: #fff; border-radius: 14px; box-shadow: 0 2px 12px #0001; padding: 24px; margin-bottom: 18px; cursor: pointer; }
        .project-title { font-size: 1.25rem; font-weight: bold; }
        .project-actions { float: right; }
        .project-list { margin-top: 24px; }
        .sidebar { min-height: 100vh; background: linear-gradient(180deg, #23272f 0%, #343a40 100%); color: #fff; width: 240px; position: fixed; top: 0; left: 0; bottom: 0; }
        .sidebar .sidebar-title { font-size: 1.7rem; font-weight: bold; color: #0dcaf0; background: #23272f; }
        .sidebar-nav { padding: 0; margin: 0; list-style: none; }
        .sidebar-nav a { color: #fff; text-decoration: none; display: flex; align-items: center; gap: 14px; padding: 14px 28px; border-radius: 8px; font-size: 1.08rem; font-weight: 500; }
        .sidebar-nav a.active, .sidebar-nav a:hover { background: #0dcaf0; color: #23272f; }
        @media (max-width: 992px) { .sidebar { width: 60px; } .main-content { margin-left: 60px; padding: 18px 6px; } }
    </style>
</head>
<body>
<div class="d-flex">
    <nav class="sidebar p-0">
        <div class="sidebar-title text-center py-4 border-bottom border-secondary" style="cursor:pointer;" onclick="location.href='index.jsp'">
            <i class="fa-solid fa-people-group me-2"></i>ICS
        </div>
        <ul class="sidebar-nav mt-3">
            <li><a href="index.jsp"><i class="fa-solid fa-chart-line"></i><span>Dashboard</span></a></li>
            <li><a href="./dsnhanvien"><i class="fa-solid fa-users"></i><span>Nhân sự</span></a></li>
            <li><a href="project.jsp"><i class="fa-solid fa-diagram-project"></i><span>Dự án</span></a></li>
            <li><a href="./dsCongviec"><i class="fa-solid fa-tasks"></i><span>Công việc</span></a></li>
            <li><a href="./dsPhongban"><i class="fa-solid fa-building"></i><span>Phòng ban</span></a></li>
            <li><a href="./dsChamCong"><i class="fa-solid fa-calendar-check"></i><span>Chấm công</span></a></li>
            <li><a href="calendar.jsp" class="active"><i class="fa-solid fa-calendar-days"></i><span>Lịch trình</span></a></li>
            <li><a href="./svBaocao"><i class="fa-solid fa-chart-bar"></i><span>Báo cáo</span></a></li>
        </ul>
    </nav>
    <div class="flex-grow-1">
        <%@ include file="header.jsp" %>
        <div class="main-content">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h3 class="mb-0"><i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án</h3>
                <button class="btn btn-primary rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#modalProject">
                    <i class="fa-solid fa-plus"></i> Thêm dự án
                </button>
            </div>
            <div class="project-list">
                <!-- Danh sách dự án sẽ được load ở đây bằng AJAX hoặc JSTL -->
                <div class="project-card mb-3" data-id="1" onclick="goToProjectTask(1, event)">
                    <span class="project-title">Dự án code Web</span>
                    <div class="project-actions">
                        <button class="btn btn-sm btn-info" onclick="showProjectDetail(event, 1)"><i class="fa-solid fa-eye"></i> Xem</button>
                        <button class="btn btn-sm btn-warning" onclick="editProject(1); event.stopPropagation();"><i class="fa-solid fa-pen"></i> Sửa</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteProject(1); event.stopPropagation();"><i class="fa-solid fa-trash"></i> Xóa</button>
                    </div>
                    <div class="mt-2 text-muted">Mô tả: Xây dựng website quản lý nhân sự</div>
                </div>
                <!-- Lặp lại cho các dự án khác -->
                <c:forEach var="project" items="${projects}">
                    <div class="project-card mb-3" data-id="${project.id}" onclick="goToProjectTask(${project.id}, event)">
                        <span class="project-title">${project.ten_du_an}</span>
                        <div class="project-actions">
                            <button class="btn btn-sm btn-info" onclick="showProjectDetail(event, ${project.id})"><i class="fa-solid fa-eye"></i> Xem</button>
                            <button class="btn btn-sm btn-warning" onclick="editProject(${project.id}); event.stopPropagation();"><i class="fa-solid fa-pen"></i> Sửa</button>
                            <button class="btn btn-sm btn-danger" onclick="deleteProject(${project.id}); event.stopPropagation();"><i class="fa-solid fa-trash"></i> Xóa</button>
                        </div>
                        <div class="mt-2 text-muted">Mô tả: ${project.mo_ta}</div>
                    </div>
                </c:forEach>
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

function goToProjectTask(projectId, event) {
    // Ngăn click vào nút không chuyển trang
    if(event.target.closest('.project-actions')) return;
    window.location.href = 'project_task.jsp?du_an_id=' + projectId;
}

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

function deleteProject(id) {
    if(confirm("Bạn có chắc muốn xóa dự án này không?")) {
        // Gọi AJAX xóa dự án
        alert("Đã xóa dự án " + id + " (demo)");
        // Thực tế: reload trang hoặc remove element
    }
}

function formatDate(dateString) {
    if (!dateString) return 'Chưa xác định';
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN');
}

// Validation cho form dự án
$("#projectForm").on("submit", function(e) {
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
document.addEventListener('DOMContentLoaded', function() {
    const today = new Date().toISOString().split('T')[0];
    const startDateInput = document.querySelector('input[name="ngay_bat_dau"]');
    const endDateInput = document.querySelector('input[name="ngay_ket_thuc"]');

    if (startDateInput) startDateInput.setAttribute('min', today);
    if (endDateInput) endDateInput.setAttribute('min', today);

    // Khi thay đổi ngày bắt đầu, update ngày kết thúc tối thiểu
    if (startDateInput) {
        startDateInput.addEventListener('change', function() {
            if (endDateInput) {
                endDateInput.setAttribute('min', this.value);
            }
        });
    }
});
</script>
</body>
</html>