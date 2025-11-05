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
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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

            /* Primary – thêm mới */
            .btn-action-primary {
                background: linear-gradient(45deg,#0d6efd,#0dcaf0);
                color: #fff;
                border: none;
            }
            .btn-action-primary:hover {
                background: linear-gradient(45deg,#0b5ed7,#0bb3e6);
                color: #fff;
            }

            /* Danger – xóa */
            .btn-action-danger {
                background: linear-gradient(45deg,#ef4444,#dc2626);
                color: #fff;
                border: none;
            }
            .btn-action-danger:hover {
                background: linear-gradient(45deg,#dc2626,#b91c1c);
                color: #fff;
            }

            /* ==== FULLCALENDAR ==== */
            #calendar {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 2px 12px rgba(0,0,0,0.06);
                padding: 18px;
            }

            /* Event style */
            .fc-event {
                border-radius: 8px;
                padding: 4px 6px;
                font-size: 0.95rem;
            }
            .fc-event:hover {
                box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            }

            /* Header toolbar */
            .fc .fc-toolbar-title {
                font-size: 1.3rem;
                font-weight: 600;
                color: #334155;
            }
            .fc .fc-button-primary {
                background: linear-gradient(45deg,#0d6efd,#0dcaf0);
                border: none;
            }
            .fc .fc-button-primary:hover {
                background: linear-gradient(45deg,#0bb3e6,#0b5ed7);
            }

            /* ==== MODALS ==== */
            .modal-content {
                border-radius: 16px;
                box-shadow: 0 6px 22px rgba(0,0,0,0.2);
                animation: fadeIn 0.3s ease;
            }
            .modal-header, .modal-footer {
                border-color: #f1f5f9;
            }
            .form-control, .form-select, textarea {
                border-radius: 10px;
            }

            /* ==== ANIMATIONS ==== */
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

            /* ==== RESPONSIVE ==== */
            @media (max-width: 992px) {
                .main-content {
                    margin-left: 60px;
                    padding: 20px;
                }
            }
            @media (max-width: 768px) {
                .main-content {
                    padding: 12px;
                }
            }

        </style>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-calendar-days me-2"></i>Lịch trình công tác';
        </script>
    </head>
    <body>
        <div class="d-flex">
            <%@ include file="sidebar.jsp" %>
            <div class="flex-grow-1">
                <%@ include file="header.jsp" %>
                <div class="main-content">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3 class="mb-0"><i class="fa-solid fa-calendar-days me-2"></i>Lịch trình công tác</h3>
                        <button class="btn btn-action btn-action-primary" id="btnAddSchedule">
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

        <script src="<%= request.getContextPath() %>/scripts/calendar.obf.js?v=20251105"></script>
    </body>
</html>