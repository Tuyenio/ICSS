<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <link rel="icon" type="image/png" href="Img/logoics.png">
    <title>Quản lý Công việc dự án</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.ckeditor.com/4.22.1/standard/ckeditor.js"></script>
    <style>
        body { background: #f4f6fa; }
        .sidebar { min-height: 100vh; background: linear-gradient(180deg, #23272f 0%, #343a40 100%); color: #fff; width: 240px; transition: width 0.2s; box-shadow: 2px 0 8px #0001; z-index: 10; position: fixed; top: 0; left: 0; bottom: 0; }
        .sidebar .sidebar-title { font-size: 1.7rem; font-weight: bold; letter-spacing: 1px; color: #0dcaf0; background: #23272f; }
        .sidebar-nav { padding: 0; margin: 0; list-style: none; }
        .sidebar-nav li { margin-bottom: 2px; }
        .sidebar-nav a { color: #fff; text-decoration: none; display: flex; align-items: center; gap: 14px; padding: 14px 28px; border-radius: 8px; font-size: 1.08rem; font-weight: 500; transition: background 0.15s, color 0.15s; }
        .sidebar-nav a.active, .sidebar-nav a:hover { background: #0dcaf0; color: #23272f; }
        .sidebar-nav a .fa-solid { width: 26px; text-align: center; font-size: 1.25rem; }
        @media (max-width: 992px) { .sidebar { width: 60px; } .sidebar .sidebar-title { font-size: 1.1rem; padding: 12px 0; } .sidebar-nav a span { display: none; } .sidebar-nav a { justify-content: center; padding: 14px 0; } }
        .main-content { padding: 36px 36px 24px 36px; min-height: 100vh; margin-left: 240px; }
        .main-box { background: #fff; border-radius: 14px; box-shadow: 0 2px 12px #0001; padding: 32px 24px; }
        .kanban-board { display: flex; gap: 24px; overflow-x: auto; min-height: 420px; margin-bottom: 32px; }
        .kanban-col { background: #f8fafd; border-radius: 18px; padding: 18px 12px; flex: 1 1 0; min-width: 270px; max-width: 340px; box-shadow: 0 2px 12px #0001; border: 2px solid #e9ecef; display: flex; flex-direction: column; min-height: 420px; transition: box-shadow 0.2s, border-color 0.2s; }
        .kanban-col:hover { box-shadow: 0 6px 24px #0002; border-color: #0dcaf0; }
        .kanban-col.not-started { border-top: 5px solid #adb5bd; }
        .kanban-col.in-progress { border-top: 5px solid #ffc107; }
        .kanban-col.completed { border-top: 5px solid #198754; }
        .kanban-col.late { border-top: 5px solid #dc3545; }
        .kanban-col.not-started h5 { color: #6c757d; }
        .kanban-col.in-progress h5 { color: #ffc107; }
        .kanban-col.completed h5 { color: #198754; }
        .kanban-col.late h5 { color: #dc3545; }
        .kanban-col h5 { font-size: 1.15rem; font-weight: bold; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; letter-spacing: 0.5px; }
        .kanban-col .kanban-add-btn { width: 100%; margin-bottom: 12px; border-radius: 20px; font-size: 0.98rem; }
        .kanban-task { background: #fff; border-radius: 12px; padding: 14px 12px; margin-bottom: 16px; box-shadow: 0 1px 8px #0001; cursor: pointer; border-left: 5px solid #0dcaf0; transition: box-shadow 0.15s, border-color 0.15s; position: relative; }
        .kanban-task:hover { box-shadow: 0 4px 16px #0d6efd; }
        .kanban-task .task-title { font-weight: 600; font-size: 1.08rem; margin-bottom: 2px; }
        .kanban-task .task-meta { font-size: 0.97em; color: #888; margin-bottom: 4px; }
        .kanban-task .task-priority, .kanban-task .task-status { display: inline-block; margin-right: 6px; font-size: 0.95em; }
        .kanban-task .progress { height: 7px; margin: 7px 0; border-radius: 6px; }
        .kanban-task .task-actions { position: absolute; top: 10px; right: 10px; display: flex; gap: 4px; }
        @media (max-width: 1200px) { .kanban-board { gap: 12px; } .kanban-col { min-width: 220px; } }
        @media (max-width: 900px) { .kanban-board { flex-direction: column; gap: 18px; } .kanban-col { min-width: 100%; max-width: 100%; } }
        @media (max-width: 768px) { .main-box { padding: 10px 2px; } .main-content { padding: 10px 2px; } }
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
            <li><a href="calendar.jsp"><i class="fa-solid fa-calendar-days"></i><span>Lịch trình</span></a></li>
            <li><a href="./svBaocao"><i class="fa-solid fa-chart-bar"></i><span>Báo cáo</span></a></li>
        </ul>
    </nav>
    <div class="flex-grow-1">
        <%@ include file="header.jsp" %>
        <div class="main-content">
            <div class="main-box mb-3">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <h3 class="mb-0"><i class="fa-solid fa-tasks me-2"></i>Quản lý Công việc dự án</h3>
                    <a href="project.jsp" class="btn btn-secondary rounded-pill px-3"><i class="fa-solid fa-arrow-left"></i> Quay lại dự án</a>
                </div>
                <div class="row mb-2 g-2" id="phongban">
                    <div class="col-md-3">
                        <input type="text" name="keyword" class="form-control" placeholder="Tìm kiếm tên công việc...">
                    </div>
                    <div class="col-md-3">
                        <select class="form-select" name="ten_phong_ban" id="phongSelect">
                            <option value="">Tất cả phòng ban</option>
                            <option>Phòng Marketing & Sales</option>
                            <option>Phòng Kỹ thuật</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select class="form-select" name="trangThai">
                            <option value="">Tất cả trạng thái</option>
                            <option value="Chưa bắt đầu">Chưa bắt đầu</option>
                            <option value="Đang thực hiện">Đang thực hiện</option>
                            <option value="Đã hoàn thành">Đã hoàn thành</option>
                            <option value="Trễ hạn">Trễ hạn</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <button class="btn btn-outline-secondary w-100 rounded-pill" id="btnFilter"><i class="fa-solid fa-filter"></i> Lọc</button>
                    </div>
                </div>
            </div>

            <!-- Kanban board -->
            <div class="kanban-board">
                <div class="kanban-col not-started">
                    <h5><i class="fa-solid fa-hourglass-start"></i>Chưa bắt đầu</h5>
                    <button class="btn btn-outline-secondary kanban-add-btn" data-bs-toggle="modal" data-bs-target="#modalTask">
                        <i class="fa-solid fa-plus"></i> Thêm task
                    </button>
                    <div class="kanban-task" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"
                         data-id="1" data-ten="chính sách giá sản phẩm" data-mo-ta=""
                         data-han="12/09/2025" data-uu-tien="Trung bình"
                         data-ten_nguoi_giao="Nguyễn Đức Dương" data-ten_nguoi_nhan="Phạm Minh Thắng"
                         data-ten_phong_ban="Phòng Marketing & Sales" data-trang-thai="Chưa bắt đầu" data-tai_lieu_cv="">
                        <div class="task-title">chính sách giá sản phẩm</div>
                        <div class="task-meta">Người giao: <b>Nguyễn Đức Dương</b><br>Người nhận: <b>Phạm Minh Thắng</b></div>
                        <span class="task-priority badge bg-warning text-dark">Trung bình</span>
                        <span class="task-status badge bg-secondary">Chưa bắt đầu</span>
                        <div class="progress">
                            <div class="progress-bar bg-secondary" style="width: 0%;"></div>
                        </div>
                        <div class="task-actions">
                            <form action="./xoaCongviec" method="post" onsubmit="return confirm('Bạn có chắc muốn xóa công việc này không?');">
                                <input type="hidden" name="id" value="1">
                                <button type="submit" class="btn btn-sm btn-danger">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="kanban-col in-progress">
                    <h5><i class="fa-solid fa-hourglass-start"></i>Đang thực hiện</h5>
                    <div class="kanban-task" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"
                         data-id="2" data-ten="Thiết kế Template" data-mo-ta="Thiết kế các template cho công ty."
                         data-han="15/09/2025" data-uu-tien="Cao"
                         data-ten_nguoi_giao="Nguyễn Đức Dương" data-ten_nguoi_nhan="Nguyễn Văn A"
                         data-ten_phong_ban="Phòng Kỹ thuật" data-trang-thai="Đang thực hiện" data-tai_lieu_cv="">
                        <div class="task-title">Thiết kế Template</div>
                        <div class="task-meta">Người giao: <b>Nguyễn Đức Dương</b><br>Người nhận: <b>Nguyễn Văn A</b></div>
                        <span class="task-priority badge bg-danger">Cao</span>
                        <span class="task-status badge bg-warning text-dark">Đang thực hiện</span>
                        <div class="progress">
                            <div class="progress-bar bg-warning text-dark" style="width: 40%;"></div>
                        </div>
                        <div class="task-actions">
                            <form action="./xoaCongviec" method="post" onsubmit="return confirm('Bạn có chắc muốn xóa công việc này không?');">
                                <input type="hidden" name="id" value="2">
                                <button type="submit" class="btn btn-sm btn-danger">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="kanban-col completed">
                    <h5><i class="fa-solid fa-check-circle"></i>Đã hoàn thành</h5>
                    <div class="kanban-task" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"
                         data-id="3" data-ten="Gửi lại bảng lương T8.2025" data-mo-ta=""
                         data-han="09/09/2025" data-uu-tien="Thấp"
                         data-ten_nguoi_giao="Nguyễn Đức Dương" data-ten_nguoi_nhan="Phạm Minh Thắng"
                         data-ten_phong_ban="Phòng Marketing & Sales" data-trang-thai="Đã hoàn thành" data-tai_lieu_cv="">
                        <div class="task-title">Gửi lại bảng lương T8.2025</div>
                        <div class="task-meta">Người giao: <b>Nguyễn Đức Dương</b><br>Người nhận: <b>Phạm Minh Thắng</b></div>
                        <span class="task-priority badge bg-success">Thấp</span>
                        <span class="task-status badge bg-success">Đã hoàn thành</span>
                        <div class="progress">
                            <div class="progress-bar bg-success" style="width: 100%;"></div>
                        </div>
                        <div class="task-actions">
                            <form action="./xoaCongviec" method="post" onsubmit="return confirm('Bạn có chắc muốn xóa công việc này không?');">
                                <input type="hidden" name="id" value="3">
                                <button type="submit" class="btn btn-sm btn-danger">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="kanban-col late">
                    <h5><i class="fa-solid fa-exclamation-circle"></i>Trễ hạn</h5>
                    <div class="kanban-task" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"
                         data-id="4" data-ten="Kế hoạch đăng bài" data-mo-ta="Lên kế hoạch đăng bài và đăng bài cho tuần này."
                         data-han="09/09/2025" data-uu-tien="Cao"
                         data-ten_nguoi_giao="Nguyễn Đức Dương" data-ten_nguoi_nhan="Nguyễn Văn B"
                         data-ten_phong_ban="Phòng Marketing & Sales" data-trang-thai="Trễ hạn" data-tai_lieu_cv="">
                        <div class="task-title">Kế hoạch đăng bài</div>
                        <div class="task-meta">Người giao: <b>Nguyễn Đức Dương</b><br>Người nhận: <b>Nguyễn Văn B</b></div>
                        <span class="task-priority badge bg-danger">Cao</span>
                        <span class="task-status badge bg-danger">Trễ hạn</span>
                        <div class="progress">
                            <div class="progress-bar bg-danger" style="width: 10%;"></div>
                        </div>
                        <div class="task-actions">
                            <form action="./xoaCongviec" method="post" onsubmit="return confirm('Bạn có chắc muốn xóa công việc này không?');">
                                <input type="hidden" name="id" value="4">
                                <button type="submit" class="btn btn-sm btn-danger">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Modal tạo/sửa task -->
            <div class="modal fade" id="modalTask" tabindex="-1">
                <div class="modal-dialog">
                    <form class="modal-content" id="taskForm" enctype="multipart/form-data">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="fa-solid fa-tasks"></i> Thông tin công việc</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="du_an_id" value="${param.du_an_id}">
                            <input type="hidden" name="id">
                            <div class="mb-3">
                                <label class="form-label">Tên công việc</label>
                                <input type="text" class="form-control" name="ten_cong_viec" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Mô tả</label>
                                <textarea class="form-control" name="mo_ta" id="taskMoTa"></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Hạn hoàn thành</label>
                                <input type="date" class="form-control" name="han_hoan_thanh">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Mức độ ưu tiên</label>
                                <select class="form-select" name="muc_do_uu_tien">
                                    <option value="Thấp" selected>Thấp</option>
                                    <option value="Trung bình">Trung bình</option>
                                    <option value="Cao">Cao</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Người giao</label>
                                <select class="form-select" name="ten_nguoi_giao" id="nguoiGiaoSelect">
                                    <!-- AJAX load nhân viên -->
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Người nhận</label>
                                <div class="input-group mb-2">
                                    <select class="form-select" id="nguoiNhanSelect2">
                                        <!-- Dữ liệu nhân viên load bằng AJAX -->
                                    </select>
                                    <button type="button" class="btn btn-outline-primary" id="btnThemNguoiNhan2">
                                        <i class="fa-solid fa-user-plus"></i> Thêm
                                    </button>
                                </div>
                                <div id="danhSachNguoiNhan2" class="d-flex flex-wrap gap-2">
                                    <!-- Tag tên người nhận sẽ hiển thị ở đây -->
                                </div>
                                <input type="hidden" name="ten_nguoi_nhan" id="nguoiNhanHidden2">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Phòng ban</label>
                                <select class="form-select" name="ten_phong_ban" id="phongSelect">
                                    <!-- Sẽ được load từ API -->
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Tài liệu công việc</label>
                                <input type="text" class="form-control" name="tai_lieu_cv">
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="submit" class="btn btn-primary rounded-pill " id="btnInsertTask">Lưu</button>
                            <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Modal chi tiết task với tab -->
            <div class="modal fade" id="modalTaskDetail" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="fa-solid fa-info-circle"></i> Chi tiết công việc</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <ul class="nav nav-tabs mb-3" id="taskDetailTab" role="tablist">
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link active" id="tab-task-info" data-bs-toggle="tab"
                                            data-bs-target="#tabTaskInfo" type="button" role="tab">Thông tin</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="tab-task-progress" data-bs-toggle="tab"
                                            data-bs-target="#tabTaskProgress" type="button" role="tab">Tiến độ</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="tab-task-history" data-bs-toggle="tab"
                                            data-bs-target="#tabTaskHistory" type="button" role="tab">Lịch sử</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="tab-task-review" data-bs-toggle="tab"
                                            data-bs-target="#tabTaskReview" type="button" role="tab">Đánh giá</button>
                                </li>
                            </ul>

                            <div class="tab-content" id="taskDetailTabContent">
                                <div class="tab-pane fade show active" id="tabTaskInfo" role="tabpanel">
                                    <form id="formTaskDetail" enctype="multipart/form-data">
                                        <input type="hidden" name="task_id" id="taskId">
                                        <div class="mb-2">
                                            <label class="form-label"><b>Tên công việc:</b></label>
                                            <input type="text" class="form-control" name="ten_cong_viec">
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Mô tả:</b></label>
                                            <textarea class="form-control" rows="3" name="mo_ta"></textarea>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Hạn hoàn thành:</b></label>
                                            <input type="date" class="form-control" name="han_hoan_thanh">
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Mức độ ưu tiên:</b></label>
                                            <select class="form-select" name="muc_do_uu_tien">
                                                <option>Cao</option>
                                                <option>Trung bình</option>
                                                <option>Thấp</option>
                                            </select>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Người giao:</b></label>
                                            <select class="form-select" name="ten_nguoi_giao"></select>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Người nhận</label>
                                            <div class="input-group mb-2">
                                                <select class="form-select" id="nguoiNhanSelect">
                                                    <!-- Dữ liệu nhân viên load bằng AJAX -->
                                                </select>
                                                <button type="button" class="btn btn-outline-primary" id="btnThemNguoiNhan">
                                                    <i class="fa-solid fa-user-plus"></i> Thêm
                                                </button>
                                            </div>
                                            <div id="danhSachNguoiNhan" class="d-flex flex-wrap gap-2">
                                                <!-- Tag tên người nhận sẽ hiển thị ở đây -->
                                            </div>
                                        </div>
                                        <input type="hidden" name="ten_nguoi_nhan" id="nguoiNhanHidden">
                                        <div class="mb-2">
                                            <label class="form-label"><b>Phòng ban:</b></label>
                                            <select class="form-select" name="ten_phong_ban"></select>
                                        </div>
                                        <div class="mb-2">
                                            <label class="form-label"><b>Trạng thái:</b></label>
                                            <select class="form-select" name="trang_thai">
                                                <option>Chưa bắt đầu</option>
                                                <option>Đang thực hiện</option>
                                                <option>Đã hoàn thành</option>
                                                <option>Trễ hạn</option>
                                            </select>
                                        </div>
                                        <div class="mb-2">
                                            <label for="taskAttachment" class="form-label"><b>Tài liệu công việc:</b></label>
                                            <input type="text" class="form-control" name="tai_lieu_cv">
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                            <button type="button" class="btn btn-primary" id="btnSaveTask">
                                                <i class="fa-solid fa-save"></i> Lưu
                                            </button>
                                        </div>
                                    </form>
                                </div>

                                <div class="tab-pane fade" id="tabTaskProgress" role="tabpanel">
                                    <b>Tiến độ:</b>
                                    <div class="progress my-3">
                                        <div class="progress-bar bg-warning" style="width: 0%" id="taskProgressBar">0%</div>
                                    </div>
                                    <button class="btn btn-outline-primary btn-sm mb-3" id="btnAddProcessStep" data-bs-toggle="modal" data-bs-target="#modalAddProcessStep">
                                        <i class="fa-solid fa-plus"></i> Thêm quy trình
                                    </button>
                                    <ul id="processStepList" class="list-group mb-2"></ul>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                    </div>
                                </div>

                                <div class="tab-pane fade" id="tabTaskHistory" role="tabpanel">
                                    <ul id="taskHistoryList">
                                        <li>09/06/2024: Tạo công việc</li>
                                        <li>10/06/2024: Cập nhật tiến độ 50%</li>
                                    </ul>
                                </div>

                                <div class="tab-pane fade" id="tabTaskReview" role="tabpanel">
                                    <form id="taskReviewForm" class="mb-3">
                                        <input type="hidden" id="taskIdReview" name="task_id" value="">
                                        <div class="mb-2">
                                            <label for="reviewerName" class="form-label">Người đánh giá:</label>
                                            <select class="form-select" name="ten_nguoi_danh_gia"></select>
                                        </div>
                                        <div class="mb-2">
                                            <label for="reviewComment" class="form-label">Nhận xét:</label>
                                            <textarea class="form-control" id="reviewComment" rows="3"
                                                      placeholder="Nhập nhận xét..."></textarea>
                                        </div>
                                        <button type="button" class="btn btn-success" id="btnAddReview">
                                            <i class="fa-solid fa-plus"></i> Thêm đánh giá
                                        </button>
                                    </form>
                                    <ul id="taskReviewList" class="list-group mb-2"></ul>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Modal thêm quy trình/giai đoạn (nested modal, không đóng modal cha) -->
            <div class="modal fade" id="modalAddProcessStep" tabindex="-1" data-bs-backdrop="false" data-bs-keyboard="false" style="z-index: 1060;">
                <div class="modal-dialog">
                    <form class="modal-content" id="formAddProcessStep">
                        <div class="modal-header">
                            <h5 class="modal-title"><i class="fa-solid fa-list-check"></i> Thêm bước quy trình</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="mb-2">
                                <input type="hidden" name="stepid">
                                <label class="form-label">Tên bước/giai đoạn</label>
                                <input type="text" class="form-control" name="stepName" required>
                            </div>
                            <div class="mb-2">
                                <label class="form-label">Mô tả</label>
                                <textarea class="form-control" name="stepDesc" rows="2"></textarea>
                            </div>
                            <div class="mb-2">
                                <label class="form-label">Trạng thái</label>
                                <select class="form-select" name="stepStatus">
                                    <option value="Chưa bắt đầu">Chưa bắt đầu</option>
                                    <option value="Đang thực hiện">Đang thực hiện</option>
                                    <option value="Đã hoàn thành">Đã hoàn thành</option>
                                </select>
                            </div>
                            <div class="mb-2 row">
                                <div class="col">
                                    <label class="form-label">Ngày bắt đầu</label>
                                    <input type="date" class="form-control" name="stepStart">
                                </div>
                                <div class="col">
                                    <label class="form-label">Ngày kết thúc</label>
                                    <input type="date" class="form-control" name="stepEnd">
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="submit" class="btn btn-primary rounded-pill" id="btnAddStepAndContinue">Thêm & tiếp tục</button>
                            <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Đóng</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Global variables for process steps management
var currentTaskId = null;
var processSteps = {};

document.addEventListener("DOMContentLoaded", function () {
    // Xử lý modal chi tiết công việc
    $('#modalTaskDetail').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget);
        var taskId = button.data('id');
        currentTaskId = taskId; // Set current task ID
        var taskName = button.data('ten');
        var taskDesc = button.data('mo-ta');
        var taskDeadline = button.data('han');
        var taskPriority = button.data('uu-tien');
        var taskAssigner = button.data('ten_nguoi_giao');
        var taskAssignee = button.data('ten_nguoi_nhan');
        var taskDepartment = button.data('ten_phong_ban');
        var taskStatus = button.data('trang-thai');
        var taskDocument = button.data('tai_lieu_cv');

        var modal = $(this);
        modal.find('#taskId').val(taskId);
        modal.find('input[name="ten_cong_viec"]').val(taskName);
        modal.find('textarea[name="mo_ta"]').val(taskDesc);
        modal.find('input[name="han_hoan_thanh"]').val(taskDeadline);
        modal.find('select[name="muc_do_uu_tien"]').val(taskPriority);
        modal.find('select[name="ten_nguoi_giao"]').val(taskAssigner);
        modal.find('select[name="ten_phong_ban"]').val(taskDepartment);
        modal.find('select[name="trang_thai"]').val(taskStatus);
        modal.find('input[name="tai_lieu_cv"]').val(taskDocument);
        
        // Load and display process steps for this task
        renderProcessSteps();
    });

    // Add backdrop for nested modal
    $('#modalAddProcessStep').on('show.bs.modal', function() {
        if (!document.querySelector('.nested-modal-backdrop')) {
            var backdrop = document.createElement('div');
            backdrop.className = 'modal-backdrop fade show nested-modal-backdrop';
            backdrop.style.zIndex = '1055';
            backdrop.style.backgroundColor = 'rgba(0,0,0,0.3)';
            document.body.appendChild(backdrop);
        }
    });

    $('#modalAddProcessStep').on('hidden.bs.modal', function() {
        var backdrop = document.querySelector('.nested-modal-backdrop');
        if (backdrop) {
            backdrop.remove();
        }
    });

    // Function to render process steps
    function renderProcessSteps() {
        var stepsList = document.getElementById('processStepList');
        if (!stepsList || !currentTaskId) return;
        
        stepsList.innerHTML = '';
        var steps = processSteps[currentTaskId] || [];
        
        steps.forEach(function(step, index) {
            var li = document.createElement('li');
            li.className = 'list-group-item d-flex justify-content-between align-items-center';
            
            var statusBadge = '';
            if (step.status === 'Đã hoàn thành') {
                statusBadge = '<span class="badge bg-success">Đã hoàn thành</span>';
            } else if (step.status === 'Đang thực hiện') {
                statusBadge = '<span class="badge bg-warning text-dark">Đang thực hiện</span>';
            } else {
                statusBadge = '<span class="badge bg-secondary">Chưa bắt đầu</span>';
            }
            
            li.innerHTML = 
                '<div>' +
                    '<strong>' + step.name + '</strong><br>' +
                    '<small class="text-muted">' + (step.desc || '') + '</small><br>' +
                    '<small>Từ: ' + (step.start || 'N/A') + ' - Đến: ' + (step.end || 'N/A') + '</small>' +
                '</div>' +
                '<div>' + statusBadge + '</div>';
            
            stepsList.appendChild(li);
        });
        
        // Update progress bar
        updateProgressBar();
    }

    function updateProgressBar() {
        if (!currentTaskId) return;
        
        var steps = processSteps[currentTaskId] || [];
        var completedSteps = steps.filter(function(step) {
            return step.status === 'Đã hoàn thành';
        }).length;
        
        var progress = steps.length > 0 ? Math.round((completedSteps / steps.length) * 100) : 0;
        var progressBar = document.getElementById('taskProgressBar');
        if (progressBar) {
            progressBar.style.width = progress + '%';
            progressBar.textContent = progress + '%';
        }
    }

    // Function to show toast messages
    function showToast(type, message) {
        // Simple alert for now, can be enhanced with proper toast
        alert(message);
    }

    // Xử lý thêm người nhận trong modal chi tiết
    var buttonsThemNguoiNhan = document.querySelectorAll("#btnThemNguoiNhan");
    buttonsThemNguoiNhan.forEach(function (btnThem) {
        btnThem.addEventListener("click", function () {
            var container = btnThem.closest(".mb-3");
            var selectNguoiNhan = container.querySelector("select");
            var danhSachDiv = container.querySelector("#danhSachNguoiNhan");
            var hiddenInput = container.parentElement.querySelector("#nguoiNhanHidden");

            if (!selectNguoiNhan || !danhSachDiv || !hiddenInput) return;

            var selectedOption = selectNguoiNhan.options[selectNguoiNhan.selectedIndex];
            if (!selectedOption || !selectedOption.value) return;

            var ten = selectedOption.text.trim();
            var existing = danhSachDiv.querySelectorAll("span");
            for (var i = 0; i < existing.length; i++) {
                if (existing[i].dataset.ten === ten) {
                    alert('Người này đã được thêm.');
                    return;
                }
            }

            var tag = document.createElement("span");
            tag.className = "badge bg-primary d-flex align-items-center me-2";
            tag.style.padding = "0.5em 0.75em";
            tag.dataset.ten = ten;
            tag.innerHTML = ten + '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';
            tag.querySelector(".btn-close").addEventListener("click", function () {
                tag.remove();
                capNhatHiddenInput(danhSachDiv, hiddenInput);
            });
            danhSachDiv.appendChild(tag);
            capNhatHiddenInput(danhSachDiv, hiddenInput);
        });
    });

    // Xử lý thêm người nhận trong modal tạo task
    var buttonsThemNguoiNhan2 = document.querySelectorAll("#btnThemNguoiNhan2");
    buttonsThemNguoiNhan2.forEach(function (btnThem) {
        btnThem.addEventListener("click", function () {
            var container = btnThem.closest(".mb-3");
            var selectNguoiNhan = container.querySelector("select");
            var danhSachDiv = container.querySelector("#danhSachNguoiNhan2");
            var hiddenInput = container.parentElement.querySelector("#nguoiNhanHidden2");

            if (!selectNguoiNhan || !danhSachDiv || !hiddenInput) return;

            var selectedOption = selectNguoiNhan.options[selectNguoiNhan.selectedIndex];
            if (!selectedOption || !selectedOption.value) return;

            var ten = selectedOption.text.trim();
            var existing = danhSachDiv.querySelectorAll("span");
            for (var i = 0; i < existing.length; i++) {
                if (existing[i].dataset.ten === ten) {
                    alert('Người này đã được thêm.');
                    return;
                }
            }

            var tag = document.createElement("span");
            tag.className = "badge bg-primary d-flex align-items-center me-2";
            tag.style.padding = "0.5em 0.75em";
            tag.dataset.ten = ten;
            tag.innerHTML = ten + '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';
            tag.querySelector(".btn-close").addEventListener("click", function () {
                tag.remove();
                capNhatHiddenInput(danhSachDiv, hiddenInput);
            });
            danhSachDiv.appendChild(tag);
            capNhatHiddenInput(danhSachDiv, hiddenInput);
        });
    });

    function capNhatHiddenInput(danhSachDiv, hiddenInput) {
        var values = [];
        var badges = danhSachDiv.querySelectorAll("span");
        for (var i = 0; i < badges.length; i++) {
            values.push(badges[i].dataset.ten);
        }
        hiddenInput.value = values.join(",");
    }

    // Sửa lại sự kiện submit để không đóng modal, chỉ reset form để tiện thêm tiếp
    $('#formAddProcessStep').off('submit').on('submit', function(e) {
        e.preventDefault();
        if (!currentTaskId) {
            showToast('error', 'Không thể xác định công việc');
            return;
        }
        var newStep = {
            id: Date.now().toString(),
            name: $(this).find('[name="stepName"]').val(),
            desc: $(this).find('[name="stepDesc"]').val(),
            status: $(this).find('[name="stepStatus"]').val(),
            start: $(this).find('[name="stepStart"]').val(),
            end: $(this).find('[name="stepEnd"]').val()
        };
        if (!processSteps[currentTaskId]) {
            processSteps[currentTaskId] = [];
        }
        processSteps[currentTaskId].push(newStep);
        renderProcessSteps();
        // Reset form để tiện thêm tiếp
        this.reset();
        showToast('success', 'Thêm bước thành công! Bạn có thể tiếp tục thêm.');
    });
});
</script>
</body>
</html>
