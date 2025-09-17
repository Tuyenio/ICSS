<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <link rel="icon" type="image/png" href="Img/logoics.png">
    <title>Lịch trình công tác</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
    <style>
        body { background: #f4f6fa; }
        .main-content { padding: 36px 36px 24px 36px; min-height: 100vh; margin-left: 240px; }
        .sidebar { min-height: 100vh; background: linear-gradient(180deg, #23272f 0%, #343a40 100%); color: #fff; width: 240px; position: fixed; top: 0; left: 0; bottom: 0; }
        .sidebar .sidebar-title { font-size: 1.7rem; font-weight: bold; color: #0dcaf0; background: #23272f; }
        .sidebar-nav { padding: 0; margin: 0; list-style: none; }
        .sidebar-nav a { color: #fff; text-decoration: none; display: flex; align-items: center; gap: 14px; padding: 14px 28px; border-radius: 8px; font-size: 1.08rem; font-weight: 500; }
        .sidebar-nav a.active, .sidebar-nav a:hover { background: #0dcaf0; color: #23272f; }
        @media (max-width: 992px) { .sidebar { width: 60px; } .main-content { margin-left: 60px; padding: 18px 6px; } }
        #calendar { background: #fff; border-radius: 16px; box-shadow: 0 2px 12px #0001; padding: 18px; }
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
                <h3 class="mb-0"><i class="fa-solid fa-calendar-days me-2"></i>Lịch trình công tác</h3>
                <button class="btn btn-primary rounded-pill px-3" id="btnAddSchedule">
                    <i class="fa-solid fa-plus"></i> Thêm lịch trình
                </button>
            </div>
            <div id="calendar"></div>
        </div>
    </div>
</div>
<!-- Modal Thêm/Sửa Lịch trình -->
<div class="modal fade" id="modalEvent" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" id="eventForm">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fa-solid fa-calendar-plus"></i> Thông tin lịch trình</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="id">
                <div class="mb-3">
                    <label class="form-label">Tiêu đề</label>
                    <input type="text" class="form-control" name="title" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Ngày bắt đầu</label>
                    <input type="date" class="form-control" name="start" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Ngày kết thúc</label>
                    <input type="date" class="form-control" name="end">
                </div>
                <div class="mb-3">
                    <label class="form-label">Mô tả</label>
                    <textarea class="form-control" name="description"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="submit" class="btn btn-primary rounded-pill">Lưu</button>
                <button type="button" class="btn btn-danger rounded-pill" id="btnDeleteEvent" style="display:none">Xóa</button>
                <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
            </div>
        </form>
    </div>
</div>

<%
    // Lấy ngày hiện tại để set mặc định
    LocalDate today = LocalDate.now();
    String todayStr = today.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
%>

<script>
// Demo dữ liệu lịch trình
var demoEvents = [
    { id: 1, title: 'Công tác Hà Nội', start: '2025-09-18', end: '2025-09-20', description: 'Đi công tác gặp đối tác.' },
    { id: 2, title: 'Họp dự án', start: '2025-09-22', description: 'Họp với team dự án Web.' }
];

// Ngày hiện tại từ server
var todayDate = '<%= todayStr %>';

document.addEventListener('DOMContentLoaded', function() {
    var calendarEl = document.getElementById('calendar');
    var calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        locale: 'vi',
        height: 650,
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,timeGridWeek,timeGridDay'
        },
        events: demoEvents,
        eventClick: function(info) {
            var event = info.event;
            $("#eventForm")[0].reset();
            $("#eventForm input[name='id']").val(event.id);
            $("#eventForm input[name='title']").val(event.title);
            $("#eventForm input[name='start']").val(event.startStr);
            $("#eventForm input[name='end']").val(event.endStr ? event.endStr.split('T')[0] : '');
            $("#eventForm textarea[name='description']").val(event.extendedProps.description || '');
            $('#btnDeleteEvent').show();
            $("#modalEvent").modal("show");
        },
        dateClick: function(info) {
            $("#eventForm")[0].reset();
            $("#eventForm input[name='start']").val(info.dateStr);
            $('#btnDeleteEvent').hide();
            $("#modalEvent").modal("show");
        }
    });
    calendar.render();

    // Xử lý nút "Thêm lịch trình" - set ngày hiện tại và ẩn nút xóa
    $('#btnAddSchedule').on('click', function() {
        $("#eventForm")[0].reset();
        $("#eventForm input[name='start']").val(todayDate);
        $('#btnDeleteEvent').hide();
        $("#modalEvent").modal("show");
    });

    // Lưu lịch trình (demo, thực tế sẽ gọi AJAX)
    $("#eventForm").on("submit", function(e) {
        e.preventDefault();
        var id = $(this).find("[name='id']").val();
        var title = $(this).find("[name='title']").val();
        var start = $(this).find("[name='start']").val();
        var end = $(this).find("[name='end']").val();
        var desc = $(this).find("[name='description']").val();
        if(id) {
            var event = calendar.getEventById(id);
            if(event) {
                event.setProp('title', title);
                event.setStart(start);
                event.setEnd(end);
                event.setExtendedProp('description', desc);
            }
        } else {
            var newId = Date.now();
            calendar.addEvent({ id: newId, title: title, start: start, end: end, description: desc });
        }
        $("#modalEvent").modal("hide");
    });

    // Xóa lịch trình
    $('#btnDeleteEvent').off('click').on('click', function() {
        var id = $("#eventForm input[name='id']").val();
        if(id) {
            if(confirm('Bạn có chắc chắn muốn xóa lịch trình này?')) {
                var event = calendar.getEventById(id);
                if(event) event.remove();
                $("#modalEvent").modal("hide");
            }
        }
    });
});
</script>
</body>
</html>