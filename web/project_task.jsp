<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Quản lý Công việc</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.ckeditor.com/4.22.1/standard/ckeditor.js"></script>
        <!-- FullCalendar CSS -->
        <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.ckeditor.com/4.22.1/standard/ckeditor.js"></script>
        <!-- FullCalendar JS -->
        <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án: <%= request.getAttribute("tenDuan") %>';
            var PROJECT_ID = <%= request.getAttribute("projectId") %>;
        </script>
        <style>
            /* BODY + MAIN CONTENT */
            body {
                background: #f8fafc;
                font-family: 'Segoe UI', Roboto, sans-serif;
                color: #1e293b;
            }
            .header {
                background: #fff;
                border-bottom: 1px solid #e2e8f0;
                min-height: 64px;
                box-shadow: 0 2px 6px rgba(0,0,0,0.05);
                margin-left: 240px;
                position: sticky;
                top: 0;
                z-index: 20;
            }
            .main-content {
                padding: 32px;
                min-height: 100vh;
                margin-left: 240px;
                animation: fadeIn 0.5s ease;
            }
            .main-box {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 3px 12px rgba(0,0,0,0.08);
                padding: 28px 22px;
            }

            /* KANBAN BOARD */
            .kanban-board {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 20px;
                min-height: 420px;
                margin-bottom: 32px;
            }
            .kanban-col {
                background: linear-gradient(145deg, #ffffff, #f8fafc);
                border-radius: 20px;
                padding: 20px 16px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.08);
                border-top: 6px solid #e2e8f0;
                animation: slideUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                min-height: 420px;
            }

            .kanban-col::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
                transition: left 0.6s;
            }

            .kanban-col:hover::before {
                left: 100%;
            }

            .kanban-col:hover {
                transform: translateY(-6px) scale(1.02);
                box-shadow: 0 12px 30px rgba(0,0,0,0.15);
                background: linear-gradient(145deg, #ffffff, #f1f5f9);
            }
            .kanban-col h5 {
                font-size: 1.1rem;
                font-weight: 600;
                margin-bottom: 16px;
                display: flex;
                align-items: center;
                gap: 6px;
            }

            /* Column colors */
            .kanban-col.not-started {
                border-color: #94a3b8;
            }
            .kanban-col.in-progress {
                border-color: #facc15;
            }
            .kanban-col.completed   {
                border-color: #22c55e;
            }
            .kanban-col.late        {
                border-color: #ef4444;
            }

            .kanban-col.not-started h5 {
                color: #64748b;
            }
            .kanban-col.in-progress h5 {
                color: #eab308;
            }
            .kanban-col.completed h5   {
                color: #16a34a;
            }
            .kanban-col.late h5        {
                color: #dc2626;
            }

            /* TASK CARDS */
            .kanban-task {
                background: linear-gradient(135deg, #ffffff, #fafbff);
                border-radius: 16px;
                padding: 16px;
                margin-bottom: 16px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
                border: 1px solid rgba(226, 232, 240, 0.5);
                border-left: 5px solid #0dcaf0;
                cursor: pointer;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
                overflow: hidden;
            }

            .kanban-task::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 2px;
                background: linear-gradient(90deg, #0dcaf0, #4f46e5);
                transition: left 0.4s ease;
            }

            .kanban-task:hover::before {
                left: 0;
            }

            .kanban-task:hover {
                transform: translateY(-4px) scale(1.02);
                box-shadow: 0 8px 25px rgba(13, 202, 240, 0.2);
                border-left-color: #4f46e5;
                background: linear-gradient(135deg, #ffffff, #f0f9ff);
            }

            .kanban-task:active {
                transform: translateY(-2px) scale(1.01);
            }
            .task-title {
                font-weight: 600;
                font-size: 1rem;
                margin-bottom: 4px;
            }
            .task-meta {
                font-size: 0.9rem;
                color: #6b7280;
                margin-bottom: 6px;
            }
            .progress {
                height: 7px;
                border-radius: 6px;
            }

            /* ========== FIXED DROPDOWN CHO TASK ACTIONS ========== */
            .task-actions {
                position: absolute;
                top: 8px;
                right: 8px;
                z-index: 10;
            }

            .task-dots-btn {
                background: rgba(255,255,255,0.95);
                border: 1px solid #e2e8f0;
                border-radius: 50%;
                width: 28px;
                height: 28px;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 0;
                cursor: pointer;
                transition: all 0.2s ease;
            }

            .task-dots-btn i {
                color: #64748b;
                font-size: 0.9rem;
            }

            .task-dots-btn:hover {
                background: rgba(13, 202, 240, 0.1);
                border-color: #0dcaf0;
                transform: scale(1.05);
            }

            .task-actions-dropdown {
                position: absolute;
                top: 34px;
                right: 0;
                min-width: 160px;
                background: #fff;
                border: 1px solid #e2e8f0;
                border-radius: 10px;
                box-shadow: 0 8px 20px rgba(0,0,0,0.15);
                padding: 6px 0;
                z-index: 100;
                display: none;
                opacity: 0;
                visibility: hidden;
                transform: translateY(-10px);
                transition: all 0.25s ease;
            }

            .task-actions-dropdown.show {
                display: block;
                opacity: 1;
                visibility: visible;
                transform: translateY(0);
            }

            .task-actions-dropdown .task-action-item {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 8px 14px;
                width: 100%;
                border: none;
                background: transparent;
                font-size: 14px;
                color: #333;
                text-align: left;
                cursor: pointer;
                transition: background 0.15s ease;
            }

            .task-actions-dropdown .task-action-item:hover {
                background-color: #f1f5f9;
            }

            .task-action-item {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 10px 14px;
                border: none;
                background: transparent;
                width: 100%;
                text-align: left;
                font-size: 0.9rem;
                color: #374151;
                transition: all 0.15s ease;
                border-radius: 0;
                text-decoration: none;
                cursor: pointer;
                user-select: none;
            }

            .task-action-item:focus {
                outline: 2px solid #0dcaf0;
                outline-offset: -2px;
            }

            .task-action-item:first-child {
                border-radius: 12px 12px 0 0;
            }

            .task-action-item:last-child {
                border-radius: 0 0 12px 12px;
            }

            .task-action-item:only-child {
                border-radius: 12px;
            }

            .task-action-item:hover {
                background: #f8fafc;
                color: #1e293b;
                transform: translateX(2px);
            }

            .task-action-item.archive:hover {
                background: linear-gradient(90deg, #f59e0b, #fbbf24);
                color: white;
            }

            .task-action-item.remind:hover {
                background: linear-gradient(90deg, #0ea5e9, #38bdf8);
                color: white;
            }

            .task-action-item.delete:hover {
                background: linear-gradient(90deg, #ef4444, #f87171);
                color: white;
            }

            .task-action-item i {
                width: 16px;
                font-size: 0.85rem;
            }

            /* TASK NAVIGATION TABS */
            .task-nav-tabs .nav-link {
                background: transparent;
                border: 2px solid transparent;
                border-radius: 25px;
                color: #64748b;
                font-weight: 500;
                padding: 8px 16px;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
                overflow: hidden;
            }

            /* VIEW MODE TOGGLE BUTTONS */
            .view-mode-toggle .btn {
                border-radius: 12px;
                font-weight: 600;
                padding: 8px 16px;
                transition: all 0.3s ease;
                border: 2px solid #0dcaf0;
            }

            .view-mode-toggle .btn:not(.active) {
                background: transparent;
                color: #0dcaf0;
            }

            .view-mode-toggle .btn.active {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                color: white;
                box-shadow: 0 4px 15px rgba(13, 202, 240, 0.4);
            }

            .view-mode-toggle .btn:hover:not(.active) {
                background: rgba(13, 202, 240, 0.1);
                transform: translateY(-2px);
            }

            .view-mode-toggle .btn i {
                font-size: 0.9rem;
            }

            /* LIST VIEW STYLES */
            .list-view-container {
                display: none;
                animation: fadeIn 0.5s ease;
            }

            .list-view-container.active {
                display: block;
            }

            .task-table {
                background: white;
                border-radius: 16px;
                overflow: hidden;
                box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            }

            .task-table table {
                margin-bottom: 0;
            }

            .task-table thead {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                color: white;
            }

            .task-table thead th {
                padding: 16px 12px;
                font-weight: 600;
                border: none;
                vertical-align: middle;
                cursor: pointer;
                user-select: none;
                position: relative;
            }

            .task-table thead th:hover {
                background: rgba(255, 255, 255, 0.1);
            }

            .task-table thead th.sortable::after {
                content: '\f0dc';
                font-family: 'Font Awesome 6 Free';
                font-weight: 900;
                margin-left: 8px;
                opacity: 0.5;
                font-size: 0.8em;
            }

            .task-table thead th.sort-asc::after {
                content: '\f0de';
                opacity: 1;
            }

            .task-table thead th.sort-desc::after {
                content: '\f0dd';
                opacity: 1;
            }

            .task-table tbody tr {
                border-bottom: 1px solid #f1f5f9;
                transition: all 0.2s ease;
            }

            .task-table tbody tr:hover {
                background: linear-gradient(90deg, rgba(13, 202, 240, 0.05), rgba(79, 70, 229, 0.05));
                transform: translateX(4px);
                cursor: pointer;
            }

            .task-table tbody td {
                padding: 14px 12px;
                vertical-align: middle;
            }

            .task-table .task-name {
                font-weight: 600;
                color: #1e293b;
            }

            .task-table .badge {
                padding: 6px 12px;
                border-radius: 8px;
                font-weight: 500;
                font-size: 0.85rem;
            }

            .task-table .badge.priority-high {
                background: linear-gradient(135deg, #ef4444, #dc2626);
            }

            .task-table .badge.priority-medium {
                background: linear-gradient(135deg, #f59e0b, #d97706);
            }

            .task-table .badge.priority-low {
                background: linear-gradient(135deg, #10b981, #059669);
            }

            .task-table .badge.status-not-started {
                background: #94a3b8;
            }

            .task-table .badge.status-in-progress {
                background: #facc15;
                color: #78350f;
            }

            .task-table .badge.status-completed {
                background: #22c55e;
            }

            .task-table .badge.status-late {
                background: #ef4444;
            }

            .task-table .action-btns {
                display: flex;
                gap: 8px;
                justify-content: center;
            }

            .task-table .action-btns .btn {
                padding: 6px 10px;
                border-radius: 8px;
                transition: all 0.2s ease;
            }

            .task-table .action-btns .btn:hover {
                transform: translateY(-2px);
            }

            /* Hiệu ứng nhấp nháy đỏ cho task có nhắc nhở trong List View */
            .task-table tbody tr.task-row--alert {
                animation: rowBlink 1.1s ease-in-out infinite;
                position: relative;
            }

            .task-table tbody tr.task-row--alert::before {
                content: '🔔';
                position: absolute;
                left: 8px;
                top: 50%;
                transform: translateY(-50%);
                font-size: 1rem;
                animation: bellPulse 2s infinite;
                z-index: 1;
            }

            .task-table tbody tr.task-row--alert td:first-child {
                padding-left: 35px;
            }

            @keyframes rowBlink {
                0%, 100% {
                    background: rgba(220, 53, 69, 0.05);
                    box-shadow: inset 0 0 0 1px rgba(220, 53, 69, 0);
                }
                50% {
                    background: rgba(220, 53, 69, 0.12);
                    box-shadow: inset 0 0 0 2px rgba(220, 53, 69, 0.3),
                        0 4px 12px rgba(220, 53, 69, 0.2);
                }
            }

            /* CALENDAR VIEW STYLES */
            .calendar-view-container {
                display: none;
                animation: fadeIn 0.5s ease;
            }

            .calendar-view-container.active {
                display: block;
            }

            #taskCalendar {
                background: white;
                border-radius: 16px;
                padding: 20px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.08);
                min-height: 600px;
            }

            /* FullCalendar custom styling */
            .fc {
                font-family: 'Segoe UI', Roboto, sans-serif;
            }

            .fc .fc-button {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                border: none;
                border-radius: 10px;
                padding: 8px 16px;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .fc .fc-button:hover {
                background: linear-gradient(135deg, #4f46e5, #0dcaf0);
                transform: translateY(-2px);
            }

            .fc .fc-button:disabled {
                opacity: 0.5;
            }

            .fc .fc-toolbar-title {
                font-size: 1.5rem;
                font-weight: 700;
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }

            .fc-event {
                border-radius: 8px;
                padding: 4px 8px;
                border: none;
                cursor: pointer;
                transition: all 0.2s ease;
            }

            .fc-event:hover {
                transform: scale(1.05);
                box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            }

            .fc-event.event-not-started {
                background: #94a3b8;
            }

            .fc-event.event-in-progress {
                background: #facc15;
                color: #78350f;
            }

            .fc-event.event-completed {
                background: #22c55e;
            }

            .fc-event.event-late {
                background: #ef4444;
            }

            .kanban-view-container {
                display: block;
            }

            .kanban-view-container.active {
                display: block;
            }

            .kanban-view-container:not(.active) {
                display: none;
            }

            .task-nav-tabs .nav-link:before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
                transition: left 0.5s;
            }

            .task-nav-tabs .nav-link:hover:before {
                left: 100%;
            }

            .task-nav-tabs .nav-link:hover {
                color: #0dcaf0;
                border-color: rgba(13, 202, 240, 0.3);
                background: rgba(13, 202, 240, 0.05);
                transform: translateY(-2px);
            }

            .task-nav-tabs .nav-link.active {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                border-color: #0dcaf0;
                color: white;
                box-shadow: 0 4px 15px rgba(13, 202, 240, 0.4);
                transform: translateY(-1px);
            }

            .task-nav-tabs .nav-link.active:hover {
                background: linear-gradient(135deg, #4f46e5, #0dcaf0);
                transform: translateY(-3px);
                box-shadow: 0 6px 20px rgba(13, 202, 240, 0.5);
            }

            .task-nav-tabs .nav-link i {
                font-size: 0.9rem;
            }

            /* ARCHIVED & DELETED TASKS STYLING */
            .archived-col, .deleted-col {
                border-top: 5px solid #f59e0b !important;
                background: #fef3c7;
            }

            .deleted-col {
                border-top-color: #ef4444 !important;
                background: #fee2e2;
            }

            .archived-col h5, .deleted-col h5 {
                color: #92400e;
            }

            .deleted-col h5 {
                color: #dc2626;
            }

            .archived-task, .deleted-task {
                background: white;
                border-left-color: #f59e0b;
                opacity: 0.85;
                transition: all 0.2s ease;
            }

            .deleted-task {
                border-left-color: #ef4444;
            }

            .archived-task:hover, .deleted-task:hover {
                opacity: 1;
                transform: translateY(-2px);
            }

            /* Special actions for archived/deleted tasks */
            .restore-action:hover {
                background: linear-gradient(90deg, #10b981, #34d399);
                color: white;
            }

            .permanent-delete-action:hover {
                background: linear-gradient(90deg, #dc2626, #ef4444);
                color: white;
            }

            /* MODALS */
            .modal-content {
                border-radius: 20px;
                box-shadow: 0 10px 40px rgba(0,0,0,0.15);
                animation: modalSlideIn 0.4s cubic-bezier(0.4, 0, 0.2, 1);
                border: 1px solid rgba(226, 232, 240, 0.3);
                backdrop-filter: blur(10px);
            }

            @keyframes modalSlideIn {
                from {
                    opacity: 0;
                    transform: translateY(-30px) scale(0.95);
                }
                to {
                    opacity: 1;
                    transform: translateY(0) scale(1);
                }
            }

            .modal-header {
                border-bottom: 1px solid rgba(241, 245, 249, 0.5);
                background: linear-gradient(135deg, #f8fafc, #ffffff);
                border-radius: 20px 20px 0 0;
            }

            .modal-footer {
                border-top: 1px solid rgba(241, 245, 249, 0.5);
                background: linear-gradient(135deg, #ffffff, #f8fafc);
                border-radius: 0 0 20px 20px;
            }

            .btn-primary {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                border: none;
                border-radius: 12px;
                font-weight: 600;
                padding: 10px 20px;
                transition: all 0.3s ease;
                box-shadow: 0 4px 15px rgba(13, 202, 240, 0.3);
            }

            .btn-primary:hover {
                background: linear-gradient(135deg, #4f46e5, #0dcaf0);
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(79, 70, 229, 0.4);
            }

            .btn-success {
                background: linear-gradient(135deg, #10b981, #34d399);
                border: none;
                border-radius: 12px;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .btn-success:hover {
                background: linear-gradient(135deg, #059669, #10b981);
                transform: translateY(-2px);
            }

            /* ==== FIX BUTTON XÓA ==== */
            .kanban-task {
                position: relative; /* để absolute của task-actions ăn theo */
            }

            /* ==== FIX NÚT + THÊM TASK ==== */
            .kanban-col .kanban-add-btn {
                margin-bottom: 16px; /* tạo khoảng cách với task */
                border-radius: 20px;
                font-size: 0.95rem;
                background: #f9fafb;
                border: 1px dashed #cbd5e1;
                transition: background 0.2s, border 0.2s;
            }

            .kanban-col .kanban-add-btn:hover {
                background: #e0f2fe;
                border-color: #0dcaf0;
            }

            /* ==== NÚT + THÊM TASK (đẹp hơn) ==== */
            .kanban-col .kanban-add-btn {
                margin-bottom: 20px;
                border: none;
                border-radius: 16px;
                font-size: 0.95rem;
                font-weight: 600;
                color: #fff;
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                box-shadow: 0 4px 15px rgba(13, 202, 240, 0.3);
                padding: 12px 16px;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
                overflow: hidden;
            }

            .kanban-col .kanban-add-btn::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
                transition: left 0.5s;
            }

            .kanban-col .kanban-add-btn:hover::before {
                left: 100%;
            }

            .kanban-col .kanban-add-btn i {
                font-size: 1rem;
                transition: transform 0.3s ease;
            }

            .kanban-col .kanban-add-btn:hover {
                background: linear-gradient(135deg, #4f46e5, #0dcaf0);
                transform: translateY(-3px) scale(1.05);
                box-shadow: 0 8px 25px rgba(79, 70, 229, 0.4);
            }

            .kanban-col .kanban-add-btn:hover i {
                transform: rotate(180deg) scale(1.1);
            }

            .kanban-col .kanban-add-btn:active {
                transform: translateY(-1px) scale(1.02);
            }

            /* Progress bar trong task */
            .kanban-task .progress {
                height: 7px;
                border-radius: 6px;
                margin-top: 10px;      /* tạo khoảng cách phía trên */
                margin-bottom: 6px;    /* tạo khoảng cách phía dưới */
                background-color: #e5e7eb; /* nền xám nhạt để nhìn rõ */
            }
            .kanban-task .progress-bar {
                border-radius: 6px;
            }

            /* Khi task đang được nhắc nhở */
            .kanban-task.task--alert {
                border-left-color: #dc3545;                 /* đỏ */
                animation: taskBlink 1.1s ease-in-out infinite;
            }

            /* Không đổi sang xanh khi hover nếu đang alert */
            .kanban-task.task--alert:hover {
                border-color: #dc3545;
            }

            /* Hiệu ứng nhấp nháy đỏ (viền + glow + chút nền) */
            @keyframes taskBlink {
                0%, 100% {
                    box-shadow: 0 1px 8px #0001, 0 0 0 0 rgba(220,53,69,0);
                    background-image: none;
                }
                50% {
                    box-shadow: 0 1px 8px #0001, 0 0 0 4px rgba(220,53,69,0.18),
                        0 6px 18px rgba(220,53,69,0.35);
                    background-image: linear-gradient(0deg, rgba(220,53,69,0.06), rgba(220,53,69,0));
                }
            }

            .task-reminder-bell {
                position: absolute;
                top: 6px;
                right: 50px;
                background: linear-gradient(135deg, #f59e0b, #fbbf24);
                color: white;
                border-radius: 50%;
                width: 30px;
                height: 30px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 0.75rem;
                box-shadow: 0 2px 8px rgba(245, 158, 11, 0.4);
                z-index: 5;
                opacity: 0.95;
                animation: bellPulse 2s infinite, bellBlink 1.2s infinite alternate;
            }

            /* ANIMATIONS */
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(12px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* Hiệu ứng rung nhẹ */
            @keyframes bellPulse {
                0%, 100% {
                    transform: rotate(0deg);
                }
                25% {
                    transform: rotate(10deg);
                }
                50% {
                    transform: rotate(-10deg);
                }
                75% {
                    transform: rotate(5deg);
                }
            }

            /* Hiệu ứng nhấp nháy ánh sáng */
            @keyframes bellBlink {
                0% {
                    box-shadow: 0 0 8px rgba(245, 158, 11, 0.6);
                    filter: brightness(0.9);
                }
                50% {
                    box-shadow: 0 0 16px rgba(245, 158, 11, 1);
                    filter: brightness(1.2);
                }
                100% {
                    box-shadow: 0 0 8px rgba(245, 158, 11, 0.6);
                    filter: brightness(0.9);
                }
            }

            /* Ẩn chuông khi task có class 'reminder-read' */
            .kanban-task.reminder-read .task-reminder-bell {
                display: none;
            }

            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(30px) scale(0.95);
                }
                to {
                    opacity: 1;
                    transform: translateY(0) scale(1);
                }
            }

            @keyframes pulse {
                0%, 100% {
                    opacity: 1;
                    transform: scale(1);
                }
                50% {
                    opacity: 0.8;
                    transform: scale(1.02);
                }
            }

            @keyframes glow {
                0%, 100% {
                    box-shadow: 0 0 10px rgba(13, 202, 240, 0.3);
                }
                50% {
                    box-shadow: 0 0 20px rgba(79, 70, 229, 0.5);
                }
            }

            .loading-spinner {
                display: inline-block;
                width: 20px;
                height: 20px;
                border: 2px solid rgba(255,255,255,0.3);
                border-radius: 50%;
                border-top-color: #fff;
                animation: spin 0.8s ease-in-out infinite;
            }

            @keyframes spin {
                to {
                    transform: rotate(360deg);
                }
            }

            /* RESPONSIVE */
            @media (max-width: 1200px) {
                .kanban-board {
                    grid-template-columns: repeat(2, 1fr);
                    gap: 16px;
                }

                .task-nav-tabs {
                    flex-wrap: wrap;
                    gap: 8px;
                }
            }

            @media (max-width: 992px) {
                .main-content {
                    margin-left: 60px;
                    padding: 20px;
                }

                .d-flex.justify-content-between.align-items-center {
                    flex-direction: column;
                    align-items: flex-start !important;
                    gap: 16px;
                }

                .task-nav-tabs {
                    order: 2;
                }

                .d-flex.gap-2 {
                    order: 1;
                    align-self: flex-end;
                }
            }

            @media (max-width: 768px) {
                .main-box {
                    padding: 12px;
                    margin: 8px;
                }

                .main-content {
                    padding: 8px;
                    margin-left: 60px;
                }

                .kanban-board {
                    grid-template-columns: 1fr;
                    gap: 12px;
                }

                .task-actions-dropdown {
                    min-width: 140px;
                    right: -10px;
                }

                .task-nav-tabs .nav-link {
                    padding: 6px 12px;
                    font-size: 0.9rem;
                }

                .d-flex.gap-2 {
                    flex-direction: column;
                    width: 100%;
                }

                .btn {
                    width: 100%;
                }
            }

            @media (max-width: 480px) {
                .main-content {
                    padding: 4px;
                    margin-left: 0;
                }

                .main-box {
                    margin: 4px;
                    padding: 8px;
                    border-radius: 12px;
                }

                .kanban-col {
                    padding: 12px;
                    border-radius: 12px;
                }

                .kanban-task {
                    padding: 12px;
                    margin-bottom: 12px;
                }

                .task-title {
                    font-size: 0.95rem;
                }

                .task-meta {
                    font-size: 0.85rem;
                }
            }

            /* ========== LỊCH SỬ CÔNG VIỆC TIMELINE ========== */
            .history-timeline {
                position: relative;
                padding: 20px 0;
                max-height: 500px;
                overflow-y: auto;
            }

            .history-timeline::-webkit-scrollbar {
                width: 6px;
            }

            .history-timeline::-webkit-scrollbar-track {
                background: #f1f5f9;
                border-radius: 10px;
            }

            .history-timeline::-webkit-scrollbar-thumb {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                border-radius: 10px;
            }

            .history-timeline::before {
                content: '';
                position: absolute;
                left: 40px;
                top: 0;
                bottom: 0;
                width: 3px;
                background: linear-gradient(180deg, #0dcaf0, #4f46e5);
                border-radius: 2px;
            }

            .history-item {
                position: relative;
                padding-left: 80px;
                margin-bottom: 24px;
                animation: slideInLeft 0.5s ease;
            }

            @keyframes slideInLeft {
                from {
                    opacity: 0;
                    transform: translateX(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }

            .history-item:last-child {
                margin-bottom: 0;
            }

            .history-number {
                position: absolute;
                left: 0;
                top: 5px;
                width: 32px;
                height: 32px;
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                color: white;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: 0.85rem;
                box-shadow: 0 3px 10px rgba(13, 202, 240, 0.3);
                z-index: 2;
            }

            .history-avatar {
                position: absolute;
                left: 58px;
                top: 0;
                width: 45px;
                height: 45px;
                border-radius: 50%;
                overflow: hidden;
                border: 3px solid white;
                box-shadow: 0 3px 10px rgba(0,0,0,0.15);
                background: linear-gradient(135deg, #f8fafc, #e2e8f0);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 2;
            }

            .history-avatar img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .history-avatar-placeholder {
                width: 100%;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                color: white;
                font-weight: 700;
                font-size: 1.1rem;
            }

            .history-content {
                background: white;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 16px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
                transition: all 0.3s ease;
                position: relative;
            }

            .history-content:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 15px rgba(13, 202, 240, 0.2);
                border-color: #0dcaf0;
            }

            .history-content::before {
                content: '';
                position: absolute;
                left: -8px;
                top: 20px;
                width: 0;
                height: 0;
                border-top: 8px solid transparent;
                border-bottom: 8px solid transparent;
                border-right: 8px solid #e2e8f0;
            }

            .history-content::after {
                content: '';
                position: absolute;
                left: -7px;
                top: 20px;
                width: 0;
                height: 0;
                border-top: 8px solid transparent;
                border-bottom: 8px solid transparent;
                border-right: 8px solid white;
            }

            .history-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 10px;
            }

            .history-user {
                font-weight: 600;
                color: #1e293b;
                font-size: 0.95rem;
            }

            .history-time {
                color: #64748b;
                font-size: 0.85rem;
                display: flex;
                align-items: center;
                gap: 4px;
            }

            .history-time i {
                font-size: 0.75rem;
            }

            .history-description {
                color: #475569;
                font-size: 0.9rem;
                line-height: 1.6;
                padding: 8px 12px;
                background: #f8fafc;
                border-radius: 8px;
                border-left: 3px solid #0dcaf0;
            }

            .history-empty {
                text-align: center;
                padding: 40px 20px;
                color: #94a3b8;
            }

            .history-empty i {
                font-size: 3rem;
                margin-bottom: 12px;
                opacity: 0.5;
            }

            .history-empty p {
                margin: 0;
                font-size: 0.95rem;
            }

            /* ==== CHỮ TRONG TASK ==== */
            .task-title {
                font-weight: 600;
                font-size: 1.1rem; /* trước ~1rem, tăng 2 size */
                margin-bottom: 6px;
            }

            .task-meta {
                font-size: 0.95rem; /* trước ~0.9rem, tăng 2 size */
                color: #4b5563;
                margin-bottom: 8px;
            }

            .task-priority,
            .task-status {
                font-size: 0.9rem; /* trước ~0.85-0.9rem */
                padding: 4px 8px;
                border-radius: 8px;
            }

            /* ========== LỊCH SỬ CÔNG VIỆC TIMELINE ========== */
            .history-timeline {
                position: relative;
                padding: 20px 0;
                max-height: 500px;
                overflow-y: auto;
            }

            .history-timeline::-webkit-scrollbar {
                width: 6px;
            }

            .history-timeline::-webkit-scrollbar-track {
                background: #f1f5f9;
                border-radius: 10px;
            }

            .history-timeline::-webkit-scrollbar-thumb {
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                border-radius: 10px;
            }

            .history-timeline::before {
                content: '';
                position: absolute;
                left: 40px;
                top: 0;
                bottom: 0;
                width: 3px;
                background: linear-gradient(180deg, #0dcaf0, #4f46e5);
                border-radius: 2px;
            }

            .history-item {
                position: relative;
                padding-left: 80px;
                margin-bottom: 24px;
                animation: slideInLeft 0.5s ease;
            }

            @keyframes slideInLeft {
                from {
                    opacity: 0;
                    transform: translateX(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }

            .history-item:last-child {
                margin-bottom: 0;
            }

            .history-number {
                position: absolute;
                left: 0;
                top: 5px;
                width: 32px;
                height: 32px;
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                color: white;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: 0.85rem;
                box-shadow: 0 3px 10px rgba(13, 202, 240, 0.3);
                z-index: 2;
            }

            .history-avatar {
                position: absolute;
                left: 58px;
                top: 0;
                width: 45px;
                height: 45px;
                border-radius: 50%;
                overflow: hidden;
                border: 3px solid white;
                box-shadow: 0 3px 10px rgba(0,0,0,0.15);
                background: linear-gradient(135deg, #f8fafc, #e2e8f0);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 2;
            }

            .history-avatar img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .history-avatar-placeholder {
                width: 100%;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                background: linear-gradient(135deg, #0dcaf0, #4f46e5);
                color: white;
                font-weight: 700;
                font-size: 1.1rem;
            }

            .history-content {
                background: white;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 16px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
                transition: all 0.3s ease;
                position: relative;
            }

            .history-content:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 15px rgba(13, 202, 240, 0.2);
                border-color: #0dcaf0;
            }

            .history-content::before {
                content: '';
                position: absolute;
                left: -8px;
                top: 20px;
                width: 0;
                height: 0;
                border-top: 8px solid transparent;
                border-bottom: 8px solid transparent;
                border-right: 8px solid #e2e8f0;
            }

            .history-content::after {
                content: '';
                position: absolute;
                left: -7px;
                top: 20px;
                width: 0;
                height: 0;
                border-top: 8px solid transparent;
                border-bottom: 8px solid transparent;
                border-right: 8px solid white;
            }

            .history-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 10px;
            }

            .history-user {
                font-weight: 600;
                color: #1e293b;
                font-size: 0.95rem;
            }

            .history-time {
                color: #64748b;
                font-size: 0.85rem;
                display: flex;
                align-items: center;
                gap: 4px;
            }

            .history-time i {
                font-size: 0.75rem;
            }

            .history-description {
                color: #475569;
                font-size: 0.9rem;
                line-height: 1.6;
                padding: 8px 12px;
                background: #f8fafc;
                border-radius: 8px;
                border-left: 3px solid #0dcaf0;
            }

            .history-empty {
                text-align: center;
                padding: 40px 20px;
                color: #94a3b8;
            }

            .history-empty i {
                font-size: 3rem;
                margin-bottom: 12px;
                opacity: 0.5;
            }

            .history-empty p {
                margin: 0;
                font-size: 0.95rem;
            }
        </style>
    </head>

    <body>
        <div class="d-flex">
            <%@ include file="sidebar.jsp" %>
            <!-- Main -->
            <div class="flex-grow-1">
                <!-- Header -->
                <%@ include file="header.jsp" %>
                <div class="main-content">
                    <div class="main-box mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div class="d-flex align-items-center gap-3">
                                <h3 class="mb-0"><i class="fa-solid fa-diagram-project me-2"></i>Quản lý Dự án: <%= request.getAttribute("tenDuan") %></h3>

                                <!-- Các tab điều hướng -->
                                <ul class="nav nav-pills task-nav-tabs" id="taskViewTabs" role="tablist">
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link active" id="active-tasks-tab" data-bs-toggle="pill" 
                                                data-bs-target="#active-tasks" type="button" role="tab">
                                            <i class="fa-solid fa-list-check me-1"></i>Công việc
                                        </button>
                                    </li>
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link" id="archived-tasks-tab" data-bs-toggle="pill" 
                                                data-bs-target="#archived-tasks" type="button" role="tab">
                                            <i class="fa-solid fa-archive me-1"></i>Lưu trữ
                                        </button>
                                    </li>
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link" id="deleted-tasks-tab" data-bs-toggle="pill" 
                                                data-bs-target="#deleted-tasks" type="button" role="tab">
                                            <i class="fa-solid fa-trash me-1"></i>Thùng rác
                                        </button>
                                    </li>
                                </ul>
                            </div>

                            <div class="d-flex gap-2 align-items-center">
                                <!-- Toggle View Mode -->
                                <div class="btn-group view-mode-toggle" role="group">
                                    <button type="button" class="btn btn-outline-primary active" id="viewKanban" 
                                            onclick="switchView('kanban')" title="Xem dạng bảng">
                                        <i class="fa-solid fa-grip-vertical"></i> Kanban
                                    </button>
                                    <button type="button" class="btn btn-outline-primary" id="viewList" 
                                            onclick="switchView('list')" title="Xem dạng danh sách">
                                        <i class="fa-solid fa-list"></i> Danh sách
                                    </button>
                                    <button type="button" class="btn btn-outline-primary" id="viewCalendar" 
                                            onclick="switchView('calendar')" title="Xem dạng lịch">
                                        <i class="fa-solid fa-calendar"></i> Lịch
                                    </button>
                                </div>
                            </div>
                            <a href="./dsDuan" class="btn btn-secondary rounded-pill px-3"><i class="fa-solid fa-arrow-left"></i> Quay lại dự án</a>
                        </div>
                        <div class="row mb-2 g-2" id="phongban">
                            <div class="col-md-3">
                                <input type="text" name="keyword" class="form-control" placeholder="Tìm kiếm tên công việc...">
                            </div>
                            <% String vaiTro = (String) session.getAttribute("vaiTro"); %>
                            <div class="col-md-3">
                                <select class="form-select" name="ten_phong_ban" id="phongSelect"
                                        <%= !"Admin".equalsIgnoreCase(vaiTro) ? "disabled" : "" %>>
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
                                <button class="btn btn-outline-secondary w-100 rounded-pill" id="btnFilter"><i
                                        class="fa-solid fa-filter"></i> Lọc</button>
                            </div>
                        </div>
                    </div>

                    <!-- Tab Content -->
                    <div class="tab-content" id="taskViewTabContent">
                        <!-- Tab Công việc hoạt động -->
                        <div class="tab-pane fade show active" id="active-tasks" role="tabpanel">
                            <%
                                List<Map<String, Object>> taskList = (List<Map<String, Object>>) request.getAttribute("taskList");

                                Map<String, String> trangThaiLabels = new LinkedHashMap<>();
                                trangThaiLabels.put("Chưa bắt đầu", "Chưa bắt đầu");
                                trangThaiLabels.put("Đang thực hiện", "Đang thực hiện");
                                trangThaiLabels.put("Đã hoàn thành", "Đã hoàn thành");
                                trangThaiLabels.put("Trễ hạn", "Trễ hạn");

                                Map<String, String> badgeClass = new HashMap<>();
                                badgeClass.put("Chưa bắt đầu", "bg-secondary");
                                badgeClass.put("Đang thực hiện", "bg-warning text-dark");
                                badgeClass.put("Đã hoàn thành", "bg-success");
                                badgeClass.put("Trễ hạn", "bg-danger");

                                Map<String, String> priorityBadge = new HashMap<>();
                                priorityBadge.put("Cao", "bg-danger");
                                priorityBadge.put("Trung bình", "bg-warning text-dark");
                                priorityBadge.put("Thấp", "bg-success");
                            %>

                            <div class="kanban-board">
                                <% for (String status : trangThaiLabels.keySet()) { 
                                       String columnClass = "";
                                       if ("Chưa bắt đầu".equals(status)) columnClass = "not-started";
                                       else if ("Đang thực hiện".equals(status)) columnClass = "in-progress";
                                       else if ("Đã hoàn thành".equals(status)) columnClass = "completed";
                                       else if ("Trễ hạn".equals(status)) columnClass = "late";
                                %>
                                <div class="kanban-col <%= columnClass %>">
                                    <% if ("Chưa bắt đầu".equals(status)) { %>
                                    <h5><i class="fa-solid fa-hourglass-start"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% }else if("Đang thực hiện".equals(status)) { %>
                                    <h5><i class="fa-solid fa-spinner"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% }else if("Đã hoàn thành".equals(status)) { %>
                                    <h5><i class="fa-solid fa-check-circle"></i> <%= trangThaiLabels.get(status) %></h5> 
                                    <% }else if("Trễ hạn".equals(status)) { %>
                                    <h5><i class="fa-solid fa-exclamation-triangle"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% } %>   
                                    <% if ("Chưa bắt đầu".equals(status)) { %>
                                    <button class="btn btn-outline-secondary kanban-add-btn" data-bs-toggle="modal"
                                            data-bs-target="#modalTask">
                                        <i class="fa-solid fa-plus"></i> Thêm task
                                    </button>
                                    <% } %>
                                    <% for (Map<String, Object> task : taskList) {
                                           if (status.equals(task.get("trang_thai"))) {
                                           // Kiểm tra xem task có được nhắc nhở hay không
                                        Object nhacNho = task.get("nhac_viec");
                                        boolean hasReminder = false;

                                        if (nhacNho != null) {
                                            try {
                                                int value = Integer.parseInt(nhacNho.toString());
                                                hasReminder = (value == 1);
                                            } catch (NumberFormatException e) {
                                                hasReminder = false;
                                            }
                                        }
                                    %>
                                    <div class="kanban-task <%= hasReminder ? "task--alert" : "" %>" data-task-id="<%= task.get("id") %>">
                                        <div class="task-content" 
                                             data-bs-toggle="modal" 
                                             data-bs-target="#modalTaskDetail"

                                             data-id="<%= task.get("id") %>"
                                             data-ten="<%= task.get("ten_cong_viec") %>"
                                             data-mo-ta="<%= task.get("mo_ta") %>"
                                             data-han="<%= task.get("han_hoan_thanh") %>"
                                             data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
                                             data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
                                             data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_ten") %>"
                                             data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
                                             data-trang-thai="<%= task.get("trang_thai") %>"
                                             data-tai_lieu_cv="<%= task.get("tai_lieu_cv") %>"
                                             data-file_tai_lieu="<%= task.get("file_tai_lieu") %>">
                                            <% if (hasReminder) { %>
                                            <div class="task-reminder-bell" title="Công việc đang được nhắc nhở">
                                                <i class="fa-solid fa-bell"></i>
                                            </div>
                                            <% } %>
                                            <div class="task-title"><%= task.get("ten_cong_viec") %></div>
                                            <div class="task-meta">Người giao: <b><%= task.get("nguoi_giao_id") %></b><br>Người nhận: <b><%= task.get("nguoi_nhan_ten") %></b></div>
                                            <span class="task-priority badge <%= priorityBadge.getOrDefault(task.get("muc_do_uu_tien"), "bg-secondary") %>"><%= task.get("muc_do_uu_tien") %></span>
                                            <span class="task-status badge <%= badgeClass.getOrDefault(status, "bg-secondary") %>"><%= trangThaiLabels.get(status) %></span>
                                            <%
                                                Object p = task.get("phan_tram");
                                                int percent = 0;
                                                if (p != null) {
                                                    try {
                                                        percent = Integer.parseInt(p.toString());
                                                    } catch (NumberFormatException e) {
                                                        percent = 0;
                                                    }
                                                }
                                            %>
                                            <div class="progress">
                                                <div class="progress-bar <%= badgeClass.getOrDefault(status, "bg-secondary") %>"
                                                     style="width: <%= percent %>%;">
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Nút 3 chấm -->
                                        <div class="task-actions">
                                            <button class="task-dots-btn" type="button" data-stop-modal="true">
                                                <i class="fa-solid fa-ellipsis-vertical"></i>
                                            </button>
                                            <div class="task-actions-dropdown">
                                                <button class="task-action-item archive" data-task-id="<%= task.get("id") %>" data-action="archive"><i class="fa-solid fa-archive"></i> Lưu trữ</button>
                                                <button class="task-action-item remind" data-task-id="<%= task.get("id") %>" data-action="remind"><i class="fa-solid fa-bell"></i> Nhắc việc</button>
                                                <button class="task-action-item delete" data-task-id="<%= task.get("id") %>" data-action="delete"><i class="fa-solid fa-trash"></i> Xóa</button>
                                            </div>
                                        </div>
                                    </div>
                                    <% }} %>
                                </div>
                                <% } %>
                            </div>

                            <!-- ==================== LIST VIEW ==================== -->
                            <div class="list-view-container" id="listView">
                                <div class="task-table">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th class="sortable" data-sort="ten_cong_viec">Tên công việc</th>
                                                <th class="sortable" data-sort="nguoi_giao_id">Người giao</th>
                                                <th class="sortable" data-sort="nguoi_nhan_ten">Người nhận</th>
                                                <th class="sortable" data-sort="phong_ban_id">Phòng ban</th>
                                                <th class="sortable" data-sort="han_hoan_thanh">Hạn hoàn thành</th>
                                                <th class="sortable" data-sort="muc_do_uu_tien">Ưu tiên</th>
                                                <th class="sortable" data-sort="trang_thai">Trạng thái</th>
                                                <th style="min-width: 120px;">Hành động</th>
                                            </tr>
                                        </thead>
                                        <tbody id="taskListTableBody">
                                            <% for (Map<String, Object> task : taskList) { 
                                                String priorityClass = "priority-low";
                                                if ("Cao".equals(task.get("muc_do_uu_tien"))) priorityClass = "priority-high";
                                                else if ("Trung bình".equals(task.get("muc_do_uu_tien"))) priorityClass = "priority-medium";
                                                
                                                String statusClass = "status-not-started";
                                                if ("Đang thực hiện".equals(task.get("trang_thai"))) statusClass = "status-in-progress";
                                                else if ("Đã hoàn thành".equals(task.get("trang_thai"))) statusClass = "status-completed";
                                                else if ("Trễ hạn".equals(task.get("trang_thai"))) statusClass = "status-late";
                                                
                                                // Kiểm tra xem task có được nhắc nhở hay không
                                                Object nhacNho = task.get("nhac_viec");
                                                boolean hasReminder = false;
                                                if (nhacNho != null) {
                                                    try {
                                                        int value = Integer.parseInt(nhacNho.toString());
                                                        hasReminder = (value == 1);
                                                    } catch (NumberFormatException e) {
                                                        hasReminder = false;
                                                    }
                                                }
                                            %>
                                            <tr class="task-row <%= hasReminder ? "task-row--alert" : "" %>" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"
                                                data-id="<%= task.get("id") %>"
                                                data-ten="<%= task.get("ten_cong_viec") %>"
                                                data-mo-ta="<%= task.get("mo_ta") %>"
                                                data-han="<%= task.get("han_hoan_thanh") %>"
                                                data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
                                                data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
                                                data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_ten") %>"
                                                data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
                                                data-trang-thai="<%= task.get("trang_thai") %>"
                                                data-tai_lieu_cv="<%= task.get("tai_lieu_cv") %>"
                                                data-file_tai_lieu="<%= task.get("file_tai_lieu") %>">
                                                <td class="task-name"><%= task.get("ten_cong_viec") %></td>
                                                <td><%= task.get("nguoi_giao_id") %></td>
                                                <td><%= task.get("nguoi_nhan_ten") %></td>
                                                <td><%= task.get("phong_ban_id") %></td>
                                                <td><%= task.get("han_hoan_thanh") %></td>
                                                <td><span class="badge <%= priorityClass %>"><%= task.get("muc_do_uu_tien") %></span></td>
                                                <td><span class="badge <%= statusClass %>"><%= task.get("trang_thai") %></span></td>
                                                <td>
                                                    <div class="action-btns" onclick="event.stopPropagation();">
                                                        <button class="btn btn-sm btn-warning" title="Lưu trữ" onclick="archiveTask('<%= task.get("id") %>')">
                                                            <i class="fa-solid fa-archive"></i>
                                                        </button>
                                                        <button class="btn btn-sm btn-info" title="Nhắc việc" onclick="remindTask('<%= task.get("id") %>')">
                                                            <i class="fa-solid fa-bell"></i>
                                                        </button>
                                                        <button class="btn btn-sm btn-danger" title="Xóa" onclick="deleteTask('<%= task.get("id") %>')">
                                                            <i class="fa-solid fa-trash"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- ==================== CALENDAR VIEW ==================== -->
                            <div class="calendar-view-container" id="calendarView">
                                <div id="taskCalendar"></div>
                            </div>
                        </div>

                        <!-- Tab Lưu trữ -->
                        <div class="tab-pane fade" id="archived-tasks" role="tabpanel">
                            <%
                              List<Map<String, Object>> archivedTaskList =
                                  (List<Map<String, Object>>) request.getAttribute("archivedTaskList");
                              if (archivedTaskList == null) archivedTaskList = new ArrayList<>();
                            %>

                            <div class="kanban-board">
                                <% for (String status : trangThaiLabels.keySet()) {
                                     String columnClass = "";
                                     if ("Chưa bắt đầu".equals(status)) columnClass = "not-started";
                                     else if ("Đang thực hiện".equals(status)) columnClass = "in-progress";
                                     else if ("Đã hoàn thành".equals(status)) columnClass = "completed";
                                     else if ("Trễ hạn".equals(status)) columnClass = "late";
                                %>
                                <div class="kanban-col <%= columnClass %> archived-col">
                                    <% if ("Chưa bắt đầu".equals(status)) { %>
                                    <h5><i class="fa-solid fa-hourglass-start"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% } else if ("Đang thực hiện".equals(status)) { %>
                                    <h5><i class="fa-solid fa-spinner"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% } else if ("Đã hoàn thành".equals(status)) { %>
                                    <h5><i class="fa-solid fa-check-circle"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% } else { %>
                                    <h5><i class="fa-solid fa-exclamation-triangle"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% } %>

                                    <%
                                      boolean hasAny = false;
                                      for (Map<String, Object> task : archivedTaskList) {
                                          String tStatus = (String) task.get("trang_thai");
                                          String tTinhTrang = (String) task.get("tinh_trang"); // phải có trong SELECT
                                          if (status.equals(tStatus) && "Lưu trữ".equalsIgnoreCase(tTinhTrang)) {
                                              hasAny = true;
                                    %>
                                    <div class="kanban-task archived-task"
                                         data-id="<%= task.get("id") %>"
                                         data-ten="<%= task.get("ten_cong_viec") %>"
                                         data-mo-ta="<%= task.get("mo_ta") %>"
                                         data-han="<%= task.get("han_hoan_thanh") %>"
                                         data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
                                         data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
                                         data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_ten") %>"
                                         data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
                                         data-trang-thai="<%= task.get("trang_thai") %>"
                                         data-tai_lieu_cv="<%= task.get("tai_lieu_cv") %>"
                                         data-file_tai_lieu="<%= task.get("file_tai_lieu") %>">
                                        <div class="task-title"><%= task.get("ten_cong_viec") %></div>
                                        <div class="task-meta">Người giao: <b><%= task.get("nguoi_giao_id") %></b><br>
                                            Người nhận: <b><%= task.get("nguoi_nhan_ten") %></b></div>

                                        <span class="task-priority badge <%= priorityBadge.getOrDefault(task.get("muc_do_uu_tien"), "bg-secondary") %>">
                                            <%= task.get("muc_do_uu_tien") %>
                                        </span>

                                        <!-- Gắn nhãn Lưu trữ -->
                                        <span class="task-status badge bg-secondary">Lưu trữ</span>

                                        <%
                                          Object p = task.get("phan_tram");
                                          int percent = 0;
                                          if (p != null) { try { percent = Integer.parseInt(p.toString()); } catch (NumberFormatException e) { percent = 0; } }
                                        %>
                                        <div class="progress">
                                            <div class="progress-bar bg-secondary" style="width:<%= percent %>%"></div>
                                        </div>

                                        <div class="task-actions">
                                            <button class="task-dots-btn" type="button">
                                                <i class="fa-solid fa-ellipsis-vertical"></i>
                                            </button>
                                            <div class="task-actions-dropdown">
                                                <button class="task-action-item restore-action" type="button"
                                                        data-task-id="<%= task.get("id") %>" data-action="restore">
                                                    <i class="fa-solid fa-undo"></i><span>Khôi phục</span>
                                                </button>
                                                <button class="task-action-item permanent-delete-action" type="button"
                                                        data-task-id="<%= task.get("id") %>" data-action="permanent-delete">
                                                    <i class="fa-solid fa-trash-can"></i><span>Xóa vĩnh viễn</span>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <%
                                          } 
                                      }   
                                      if (!hasAny) {
                                    %>
                                    <div class="text-center text-muted py-3">
                                        <i class="fa-solid fa-inbox fa-2x mb-2"></i>
                                        <p>Chưa có công việc lưu trữ</p>
                                    </div>
                                    <% } %>
                                </div>
                                <% } // end for status %>
                            </div>
                        </div>

                        <!-- Tab Thùng rác -->
                        <div class="tab-pane fade" id="deleted-tasks" role="tabpanel">
                            <%
                              List<Map<String, Object>> deletedTaskList =
                                  (List<Map<String, Object>>) request.getAttribute("deletedTaskList");
                              if (deletedTaskList == null) deletedTaskList = new ArrayList<>();
                            %>

                            <div class="kanban-board">
                                <% for (String status : trangThaiLabels.keySet()) {
                                     String columnClass = "";
                                     if ("Chưa bắt đầu".equals(status)) columnClass = "not-started";
                                     else if ("Đang thực hiện".equals(status)) columnClass = "in-progress";
                                     else if ("Đã hoàn thành".equals(status)) columnClass = "completed";
                                     else if ("Trễ hạn".equals(status)) columnClass = "late";
                                %>
                                <div class="kanban-col <%= columnClass %> deleted-col">
                                    <% if ("Chưa bắt đầu".equals(status)) { %>
                                    <h5><i class="fa-solid fa-hourglass-start"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% } else if ("Đang thực hiện".equals(status)) { %>
                                    <h5><i class="fa-solid fa-spinner"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% } else if ("Đã hoàn thành".equals(status)) { %>
                                    <h5><i class="fa-solid fa-check-circle"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% } else { %>
                                    <h5><i class="fa-solid fa-exclamation-triangle"></i> <%= trangThaiLabels.get(status) %></h5>
                                    <% } %>

                                    <%
                                      boolean hasAny = false;
                                      for (Map<String, Object> task : deletedTaskList) {
                                          String tStatus = (String) task.get("trang_thai");
                                          String tTinhTrang = (String) task.get("tinh_trang");
                                          if (status.equals(tStatus) && "Đã xóa".equalsIgnoreCase(tTinhTrang)) {
                                              hasAny = true;
                                    %>
                                    <div class="kanban-task deleted-task"
                                         data-id="<%= task.get("id") %>"
                                         data-ten="<%= task.get("ten_cong_viec") %>"
                                         data-mo-ta="<%= task.get("mo_ta") %>"
                                         data-han="<%= task.get("han_hoan_thanh") %>"
                                         data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
                                         data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
                                         data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_ten") %>"
                                         data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
                                         data-trang-thai="<%= task.get("trang_thai") %>"
                                         data-tai_lieu_cv="<%= task.get("tai_lieu_cv") %>"
                                         data-file_tai_lieu="<%= task.get("file_tai_lieu") %>">

                                        <div class="task-title"><%= task.get("ten_cong_viec") %></div>
                                        <div class="task-meta">
                                            Người giao: <b><%= task.get("nguoi_giao_id") %></b><br>
                                            Người nhận: <b><%= task.get("nguoi_nhan_ten") %></b>
                                        </div>

                                        <span class="task-priority badge <%= priorityBadge.getOrDefault(task.get("muc_do_uu_tien"), "bg-secondary") %>">
                                            <%= task.get("muc_do_uu_tien") %>
                                        </span>
                                        <span class="task-status badge bg-danger">Đã xóa</span>

                                        <%
                                          Object p = task.get("phan_tram");
                                          int percent = 0;
                                          if (p != null) { try { percent = Integer.parseInt(p.toString()); } catch (NumberFormatException e) { percent = 0; } }
                                        %>
                                        <div class="progress">
                                            <div class="progress-bar bg-danger" style="width:<%= percent %>%"></div>
                                        </div>

                                        <div class="task-actions">
                                            <button class="task-dots-btn" type="button">
                                                <i class="fa-solid fa-ellipsis-vertical"></i>
                                            </button>
                                            <div class="task-actions-dropdown">
                                                <button class="task-action-item restore-action" type="button"
                                                        data-task-id="<%= task.get("id") %>" data-action="restore">
                                                    <i class="fa-solid fa-undo"></i><span>Khôi phục</span>
                                                </button>
                                                <button class="task-action-item permanent-delete-action" type="button"
                                                        data-task-id="<%= task.get("id") %>" data-action="permanent-delete">
                                                    <i class="fa-solid fa-trash-can"></i><span>Xóa vĩnh viễn</span>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <%
                                          }
                                      } // end for task
                                      if (!hasAny) {
                                    %>
                                    <div class="text-center text-muted py-3">
                                        <i class="fa-solid fa-trash fa-2x mb-2"></i>
                                        <p>Thùng rác trống</p>
                                    </div>
                                    <% } %>
                                </div>
                                <% } // end for status %>
                            </div>
                        </div>

                        <!-- Modal tạo/sửa task -->
                        <div class="modal fade" id="modalTask" tabindex="-1">
                            <div class="modal-dialog">
                                <form class="modal-content" id="taskForm" enctype="multipart/form-data">
                                    <div class="modal-header">
                                        <h5 class="modal-title"><i class="fa-solid fa-tasks"></i> Thông tin công việc
                                        </h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <input type="hidden" name="id">
                                        <div class="mb-3">
                                            <label class="form-label"><b>Tên công việc</b></label>
                                            <input type="text" class="form-control" name="ten_cong_viec" required>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label"><b>Mô tả</b></label>
                                            <textarea class="form-control" name="mo_ta" id="taskMoTa"></textarea>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label"><b>Hạn hoàn thành</b></label>
                                            <input type="date" class="form-control" name="han_hoan_thanh">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label"><b>Mức độ ưu tiên</b></label>
                                            <select class="form-select" name="muc_do_uu_tien">
                                                <option value="Thấp" selected>Thấp</option>
                                                <option value="Trung bình">Trung bình</option>
                                                <option value="Cao">Cao</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label"><b>Người giao</b></label>
                                            <select class="form-select" name="ten_nguoi_giao" id="nguoiGiaoSelect">
                                                <!-- AJAX load nhân viên -->
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label"><b>Người nhận</b></label>
                                            <button type="button" class="btn btn-outline-primary" id="btnOpenNguoiNhanCreate">
                                                <i class="fa-solid fa-user-plus"></i> Thêm người nhận
                                            </button>
                                            <div id="danhSachNguoiNhan2" class="d-flex flex-wrap gap-2 mt-2">
                                                <!-- Tag tên người nhận sẽ hiển thị ở đây -->
                                            </div>
                                            <input type="hidden" name="ten_nguoi_nhan" id="nguoiNhanHidden2">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label"><b>Phòng ban</b></label>
                                            <select class="form-select" name="ten_phong_ban" id="phongSelect">
                                                <!-- Sẽ được load từ API -->
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label"><b>Tài liệu công việc (Link Driver)</b></label>
                                            <input type="text" class="form-control" name="tai_lieu_cv">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label"><b>File công việc</b></label>
                                            <input class="form-control" type="file" name="files" id="taskFiles" multiple>
                                            <div id="taskFileList" class="form-text text-muted small mt-1">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="submit" class="btn btn-primary rounded-pill " id="btnInsertTask">Lưu</button>
                                        <button type="button" class="btn btn-secondary rounded-pill"
                                                data-bs-dismiss="modal">Huỷ</button>
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
                                                        <label class="form-label"><b>Tên công việc</b></label>
                                                        <input type="text" class="form-control" name="ten_cong_viec">
                                                    </div>
                                                    <div class="mb-2">
                                                        <label class="form-label"><b>Mô tả</b></label>
                                                        <textarea class="form-control" rows="3" name="mo_ta"></textarea>
                                                    </div>
                                                    <div class="mb-2">
                                                        <label class="form-label"><b>Hạn hoàn thành</b></label>
                                                        <input type="date" class="form-control" name="han_hoan_thanh">
                                                    </div>
                                                    <div class="mb-2">
                                                        <label class="form-label"><b>Mức độ ưu tiên</b></label>
                                                        <select class="form-select" name="muc_do_uu_tien">
                                                            <option>Cao</option>
                                                            <option>Trung bình</option>
                                                            <option>Thấp</option>
                                                        </select>
                                                    </div>
                                                    <div class="mb-2">
                                                        <label class="form-label"><b>Người giao</b></label>
                                                        <select class="form-select" name="ten_nguoi_giao"></select>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label"><b>Người nhận</b></label>
                                                        <button type="button" class="btn btn-outline-primary" id="btnOpenNguoiNhanDetail">
                                                            <i class="fa-solid fa-user-plus"></i> Thêm người nhận
                                                        </button>
                                                        <div id="danhSachNguoiNhan" class="d-flex flex-wrap gap-2 mt-2">
                                                            <!-- Tag tên người nhận sẽ hiển thị ở đây -->
                                                        </div>
                                                        <input type="hidden" name="ten_nguoi_nhan" id="nguoiNhanHidden">
                                                    </div>
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
                                                        <label for="taskAttachment" class="form-label"><b>Tài liệu công việc (Link Driver)</b></label>
                                                        <input type="text" class="form-control" name="tai_lieu_cv">
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label"><b>File công việc</b></label>
                                                        <input class="form-control" type="file" name="files" id="taskFiles2" multiple>
                                                        <div id="taskFileList2" class="form-text text-muted small mt-1">
                                                        </div>
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
                                                <div class="progress my-1">
                                                    <div class="progress-bar bg-warning" style="width: 0%" id="taskProgressBar"></div>
                                                </div>
                                                <button class="btn btn-outline-primary btn-sm mb-3" id="btnAddProcessStep">
                                                    <i class="fa-solid fa-plus"></i> Thêm quy trình
                                                </button>
                                                <ul id="processStepList" class="list-group mb-2"></ul>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                                </div>
                                            </div>

                                            <div class="tab-pane fade" id="tabTaskHistory" role="tabpanel">
                                                <div class="history-timeline" id="taskHistoryTimeline">
                                                    <!-- Lịch sử sẽ được load qua AJAX -->
                                                    <div class="history-empty">
                                                        <i class="fa-solid fa-clock-rotate-left"></i>
                                                        <p>Đang tải lịch sử công việc...</p>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="tab-pane fade" id="tabTaskReview" role="tabpanel">
                                                <form id="taskReviewForm" class="mb-3">
                                                    <input type="hidden" id="taskId" name="task_id" value="">
                                                    <div class="mb-2">
                                                        <label for="reviewerName" class="form-label">Người đánh giá:</label>
                                                        <select class="form-select" name="ten_nguoi_danh_gia"></select>
                                                        <!--                                                    <input type="text" class="form-control" id="reviewerName"
                                                                                                                   placeholder="Nhập tên người đánh giá">-->
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
                        <!-- Modal chọn nhiều người -->
                        <div class="modal fade" id="modalChonNguoiNhan" tabindex="-1">
                            <div class="modal-dialog modal-lg">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title"><i class="fa-solid fa-users"></i> Chọn người nhận</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <div id="listNguoiNhanCheckbox" class="row"></div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" id="btnXacNhanNguoiNhan" class="btn btn-primary">
                                            <i class="fa-solid fa-check"></i> Xác nhận
                                        </button>
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Modal Upload Excel -->
                        <div class="modal fade" id="modalExcel" tabindex="-1">
                            <div class="modal-dialog">
                                <form class="modal-content" action="UploadExcelServlet" method="post" enctype="multipart/form-data">
                                    <div class="modal-header">
                                        <h5 class="modal-title"><i class="fa-solid fa-file-excel"></i> Upload Excel công việc</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="mb-3">
                                            <label class="form-label">Chọn file Excel</label>
                                            <input type="file" name="excelFile" accept=".xls,.xlsx" class="form-control" required>
                                        </div>
                                        <p class="text-muted small">File phải có cột trùng với cấu trúc bảng <code>cong_viec</code></p>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="submit" class="btn btn-success">Upload & Import</button>
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                        <!-- Modal thêm quy trình/giai đoạn -->
                        <div class="modal fade" id="modalAddProcessStep" tabindex="-1">
                            <div class="modal-dialog">
                                <form class="modal-content" id="formAddProcessStep">
                                    <div class="modal-header">
                                        <h5 class="modal-title"><i class="fa-solid fa-list-check"></i> Thêm bước quy
                                            trình</h5>
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
                                        <button type="submit" class="btn btn-primary rounded-pill">Thêm bước</button>
                                        <button type="button" class="btn btn-secondary rounded-pill"
                                                data-bs-dismiss="modal">Huỷ</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            // Hiển thị danh sách file ngay khi chọn
            document.getElementById('taskFiles').addEventListener('change', function () {
                let files = this.files;
                let list = "";
                for (let i = 0; i < files.length; i++) {
                    list += "📄 " + files[i].name + "<br>";
                }
                document.getElementById('taskFileList').innerHTML = list || "Chưa có file nào được chọn";
            });
            document.getElementById('taskFiles2').addEventListener('change', function () {
                let files = this.files;
                let list = "";
                for (let i = 0; i < files.length; i++) {
                    list += "📄 " + files[i].name + "<br>";
                }
                document.getElementById('taskFileList2').innerHTML = list || "Chưa có file nào được chọn";
            });
        </script>
        <script>

            // ====== LƯU CÔNG VIỆC (SỬA) ======
            document.getElementById('btnSaveTask').addEventListener('click', function () {
                const form = document.getElementById('formTaskDetail');
                const formData = new FormData(form); // tự động lấy tất cả input, bao gồm cả file

                fetch('./suaCongviec', {
                    method: 'POST',
                    body: formData
                })
                        .then(res => res.json())
                        .then(data => {
                            if (data.success) {
                                showToast('success', '✅ Cập nhật công việc thành công!');
                                // Ẩn modal và làm mới danh sách (tuỳ theo bạn xử lý)
                                bootstrap.Modal.getInstance(document.getElementById('modalTaskDetail')).hide();
                                location.reload();
                            } else {
                                showToast('error', data.message || '❌ Lỗi khi cập nhật');
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            showToast('error', '❌ Lỗi kết nối server');
                        });
            });

            document.addEventListener("DOMContentLoaded", function () {
                var buttonsThemNguoiNhan = document.querySelectorAll("#btnThemNguoiNhan2");
                buttonsThemNguoiNhan.forEach(function (btnThem) {
                    btnThem.addEventListener("click", function () {
                        var container = btnThem.closest(".mb-3"); // nhóm đang thao tác
                        var selectNguoiNhan = container.querySelector("select");
                        var danhSachDiv = container.querySelector("#danhSachNguoiNhan2");
                        var hiddenInput = container.parentElement.querySelector("#nguoiNhanHidden2");

                        if (!selectNguoiNhan || !danhSachDiv || !hiddenInput)
                            return;

                        var selectedOption = selectNguoiNhan.options[selectNguoiNhan.selectedIndex];
                        if (!selectedOption || !selectedOption.value)
                            return;

                        var ten = selectedOption.text.trim();
                        var existing = danhSachDiv.querySelectorAll("span");
                        for (var i = 0; i < existing.length; i++) {
                            if (existing[i].dataset.ten === ten) {
                                showToast('info', 'Người này đã được thêm.');
                                return;
                            }
                        }

                        var tag = document.createElement("span");
                        tag.className = "badge bg-primary d-flex align-items-center me-2";
                        tag.style.padding = "0.5em 0.75em";
                        tag.dataset.ten = ten;
                        tag.innerHTML = ten +
                                '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';
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
            });
        </script>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                var buttonsThemNguoiNhan = document.querySelectorAll("#btnThemNguoiNhan");
                buttonsThemNguoiNhan.forEach(function (btnThem) {
                    btnThem.addEventListener("click", function () {
                        var container = btnThem.closest(".mb-3"); // nhóm đang thao tác
                        var selectNguoiNhan = container.querySelector("select");
                        var danhSachDiv = container.querySelector("#danhSachNguoiNhan");
                        var hiddenInput = container.parentElement.querySelector("#nguoiNhanHidden");

                        if (!selectNguoiNhan || !danhSachDiv || !hiddenInput)
                            return;

                        var selectedOption = selectNguoiNhan.options[selectNguoiNhan.selectedIndex];
                        if (!selectedOption || !selectedOption.value)
                            return;

                        var ten = selectedOption.text.trim();
                        var existing = danhSachDiv.querySelectorAll("span");
                        for (var i = 0; i < existing.length; i++) {
                            if (existing[i].dataset.ten === ten) {
                                showToast('info', 'Người này đã được thêm.');
                                return;
                            }
                        }

                        var tag = document.createElement("span");
                        tag.className = "badge bg-primary d-flex align-items-center me-2";
                        tag.style.padding = "0.5em 0.75em";
                        tag.dataset.ten = ten;
                        tag.innerHTML = ten +
                                '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';
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
            });
        </script>

        <script>
            // Hàm chọn option theo text
            function selectOptionByText(selectEl, targetText) {
                if (!selectEl || !targetText)
                    return;
                const normalizedTarget = targetText.trim().toLowerCase();
                const options = selectEl.options;
                for (let i = 0; i < options.length; i++) {
                    if (options[i].text.trim().toLowerCase() === normalizedTarget) {
                        selectEl.selectedIndex = i;
                        return;
                    }
                }
                selectEl.selectedIndex = -1; // Không tìm thấy
            }

            document.addEventListener("DOMContentLoaded", function () {
                // Load nhóm công việc
                fetch('./apiPhongban')
                        .then(res => res.text())
                        .then(html => {
                            const defaultOption = '<option value="" selected>Tất cả phòng ban</option>';
                            const finalHTML = defaultOption + html;
                            document.querySelector('#modalTaskDetail select[name="ten_phong_ban"]').innerHTML = finalHTML;
                            document.querySelector('#taskForm select[name="ten_phong_ban"]').innerHTML = finalHTML;
                            document.querySelector('#phongban select[name="ten_phong_ban"]').innerHTML = finalHTML;
                        });
                // Load danh sách nhân viên (giao & nhận)
                fetch('./apiNhanvien')
                        .then(function (res) {
                            return res.text();
                        })
                        .then(function (html) {
                            var container = document.getElementById("listNguoiNhanCheckbox");
                            container.innerHTML = "";

                            // Tạo thẻ div để parse chuỗi option thành DOM
                            var temp = document.createElement("div");
                            temp.innerHTML = "<select>" + html + "</select>";
                            var options = temp.querySelectorAll("option");

                            for (var i = 0; i < options.length; i++) {
                                var opt = options[i];
                                if (!opt.value)
                                    continue;
                                var col = document.createElement("div");
                                col.className = "col-md-4";
                                col.innerHTML =
                                        '<div class="form-check">' +
                                        '<input class="form-check-input nguoiNhanItem" type="checkbox" value="' + opt.text + '" id="nv_' + opt.value + '">' +
                                        '<label class="form-check-label" for="nv_' + opt.value + '">' + opt.text + '</label>' +
                                        '</div>';
                                container.appendChild(col);
                            }
                        });
                fetch('./apiNhanvien')
                        .then(res => res.text())
                        .then(html => {
                            document.querySelector('#modalTaskDetail select[name="ten_nguoi_giao"]').innerHTML = html;
                            //document.querySelector('#modalTaskDetail select[name="ten_nguoi_nhan"]').innerHTML = html;
                            document.querySelector('#modalTaskDetail select[name="ten_nguoi_danh_gia"]').innerHTML = html;
                            document.querySelector('#taskForm select[name="ten_nguoi_giao"]').innerHTML = html;
                            //document.querySelector('#taskForm select[name="ten_nguoi_nhan"]').innerHTML = html;
                        });
            });
            document.addEventListener("DOMContentLoaded", function () {
                const modal = document.getElementById("modalTaskDetail");
                modal.addEventListener("show.bs.modal", function (event) {
                    const button = event.relatedTarget;
                    if (!button)
                        return;

                    // Lấy dữ liệu từ nút
                    const id = button.getAttribute("data-id") || "";
                    const tenCV = button.getAttribute("data-ten") || "";
                    const moTa = button.getAttribute("data-mo-ta") || "";
                    const hanHT = button.getAttribute("data-han") || "";
                    const uuTien = button.getAttribute("data-uu-tien") || "";
                    const nguoiGiao = button.getAttribute("data-ten_nguoi_giao") || "";
                    const nguoiNhan = button.getAttribute("data-ten_nguoi_nhan") || ""; // nhiều tên, ngăn cách dấu phẩy
                    const phongban = button.getAttribute("data-ten_phong_ban") || "";
                    const trangthai = button.getAttribute("data-trang-thai") || "";
                    const tailieu = button.getAttribute("data-tai_lieu_cv") || "";

                    // Gán dữ liệu cơ bản
                    modal.querySelector('[name="task_id"]').value = id;
                    modal.querySelector('[name="ten_cong_viec"]').value = tenCV;
                    modal.querySelector('[name="mo_ta"]').value = moTa;
                    modal.querySelector('[name="han_hoan_thanh"]').value = hanHT;
                    selectOptionByText(modal.querySelector('[name="muc_do_uu_tien"]'), uuTien);
                    selectOptionByText(modal.querySelector('[name="ten_nguoi_giao"]'), nguoiGiao);
                    // ❌ bỏ dòng selectOptionByText cho người nhận
                    selectOptionByText(modal.querySelector('[name="ten_phong_ban"]'), phongban);
                    selectOptionByText(modal.querySelector('[name="trang_thai"]'), trangthai);
                    modal.querySelector('[name="tai_lieu_cv"]').value = tailieu;

                    let fileTaiLieu = button.getAttribute("data-file_tai_lieu") || "";
                    if (fileTaiLieu.toLowerCase() === "null") {
                        fileTaiLieu = "";
                    }

                    const fileListDiv = modal.querySelector("#taskFileList2");
                    if (!fileTaiLieu && taskFiles2.files.length === 0) {
                        fileListDiv.innerHTML = "Chưa có file nào được đính kèm";
                    }

                    if (fileTaiLieu) {
                        const files = fileTaiLieu.split(";").map(x => x.trim()).filter(Boolean);
                        const taskId = modal.querySelector('[name="task_id"]').value;

                        files.forEach(path => {
                            const tenFile = path.substring(path.lastIndexOf("/") + 1).split("\\").pop();

                            const fileItem = document.createElement("div");
                            fileItem.className = "d-flex align-items-center mb-1";

                            const link = document.createElement("a");
                            link.href = "downloadFile?file=" + encodeURIComponent(tenFile);
                            link.className = "flex-grow-1 text-decoration-none";
                            link.innerHTML = "📄 " + tenFile + " <i class='fa-solid fa-download'></i>";

                            const delBtn = document.createElement("button");
                            delBtn.className = "btn btn-sm btn-outline-danger ms-2";
                            delBtn.innerHTML = "<i class='fa-solid fa-times'></i>";

                            // 👉 KHÔNG cần confirm, gửi luôn full path
                            delBtn.addEventListener("click", function () {
                                fetch("deleteFile", {
                                    method: "POST",
                                    headers: {
                                        "Content-Type": "application/x-www-form-urlencoded"
                                    },
                                    body: "file=" + encodeURIComponent(path) + "&taskId=" + encodeURIComponent(taskId)
                                })
                                        .then(res => res.json())
                                        .then(data => {
                                            if (data.success) {
                                                fileItem.remove();

                                                if (fileListDiv.children.length === 0) {
                                                    fileListDiv.innerHTML = "Chưa có file nào được đính kèm";
                                                }

                                                showToast('success', '🗑️ File đã được xoá');
                                            } else {
                                                showToast('error', "❌ Lỗi xoá file: " + (data.message || "Không rõ nguyên nhân"));
                                            }
                                        })
                                        .catch(err => {
                                            console.error(err);
                                            showToast('error', '❌ Lỗi kết nối server.');
                                        });
                            });

                            fileItem.appendChild(link);
                            fileItem.appendChild(delBtn);
                            fileListDiv.appendChild(fileItem);
                        });
                    } else {
                        fileListDiv.innerHTML = "Chưa có file nào được đính kèm";
                    }


                    // --- Xử lý nhiều người nhận ---
                    const danhSachDiv = modal.querySelector("#danhSachNguoiNhan");
                    const hiddenInput = modal.querySelector("#nguoiNhanHidden");
                    danhSachDiv.innerHTML = "";
                    hiddenInput.value = "";

                    const tenArray = nguoiNhan.split(",").map(x => x.trim()).filter(Boolean);
                    function capNhatHiddenInput() {
                        const tags = danhSachDiv.querySelectorAll("span[data-ten]");
                        const values = [];
                        tags.forEach(tag => values.push(tag.getAttribute("data-ten")));
                        hiddenInput.value = values.join(",");
                    }

                    tenArray.forEach(function (ten) {
                        const tag = document.createElement("span");
                        tag.className = "badge bg-primary d-flex align-items-center me-2";
                        tag.style.padding = "0.5em 0.75em";
                        tag.setAttribute("data-ten", ten);

                        // Tạo phần text
                        const tenNode = document.createElement("span");
                        tenNode.textContent = ten;

                        // Tạo nút xoá
                        const closeBtn = document.createElement("button");
                        closeBtn.type = "button";
                        closeBtn.className = "btn btn-sm btn-close ms-2";
                        closeBtn.setAttribute("aria-label", "Xoá");

                        // Sự kiện xoá
                        closeBtn.addEventListener("click", function () {
                            tag.remove();
                            capNhatHiddenInput();
                        });

                        // Gắn phần text và nút xoá vào thẻ
                        tag.appendChild(tenNode);
                        tag.appendChild(closeBtn);

                        // Thêm tag vào danh sách
                        danhSachDiv.appendChild(tag);
                    });

                    capNhatHiddenInput();

                    // Mở lại tab đầu tiên khi show modal
                    const tabTrigger = modal.querySelector('#tab-task-info');
                    if (tabTrigger)
                        new bootstrap.Tab(tabTrigger).show();
                });
            });
        </script>

        <script>
            var currentTarget = null;

            // Tick lại checkbox theo hidden input hiện tại
            function syncNguoiNhanCheckboxes(hiddenId) {
                var hidden = document.getElementById(hiddenId);
                var selected = (hidden.value || "").split(",").map(function (s) {
                    return s.trim();
                }).filter(function (s) {
                    return s.length > 0;
                });

                var boxes = document.querySelectorAll(".nguoiNhanItem");
                for (var i = 0; i < boxes.length; i++) {
                    boxes[i].checked = selected.indexOf(boxes[i].value) !== -1;
                }
            }

            // Nút trong modal tạo mới
            document.getElementById("btnOpenNguoiNhanCreate").addEventListener("click", function () {
                currentTarget = "create";
                syncNguoiNhanCheckboxes("nguoiNhanHidden2"); // tick theo hidden của form tạo
                new bootstrap.Modal(document.getElementById("modalChonNguoiNhan")).show();
            });

            // Nút trong modal chi tiết
            document.getElementById("btnOpenNguoiNhanDetail").addEventListener("click", function () {
                currentTarget = "detail";
                syncNguoiNhanCheckboxes("nguoiNhanHidden"); // tick theo hidden của form chi tiết
                new bootstrap.Modal(document.getElementById("modalChonNguoiNhan")).show();
            });

            // Xác nhận chọn người nhận
            document.getElementById("btnXacNhanNguoiNhan").addEventListener("click", function () {
                var checked = document.querySelectorAll(".nguoiNhanItem:checked");

                var danhSachDiv, hiddenInput;
                if (currentTarget === "create") {
                    danhSachDiv = document.getElementById("danhSachNguoiNhan2");
                    hiddenInput = document.getElementById("nguoiNhanHidden2");
                } else {
                    danhSachDiv = document.getElementById("danhSachNguoiNhan");
                    hiddenInput = document.getElementById("nguoiNhanHidden");
                }

                danhSachDiv.innerHTML = "";
                var values = [];

                for (var i = 0; i < checked.length; i++) {
                    var ten = checked[i].value;
                    values.push(ten);

                    var tag = document.createElement("span");
                    tag.className = "badge bg-primary d-flex align-items-center me-2";
                    tag.style.padding = "0.5em 0.75em";
                    tag.setAttribute("data-ten", ten);
                    tag.innerHTML = ten +
                            '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';

                    tag.querySelector(".btn-close").addEventListener("click", function () {
                        this.parentElement.remove();
                        capNhatHiddenInput(danhSachDiv, hiddenInput);
                    });

                    danhSachDiv.appendChild(tag);
                }

                hiddenInput.value = values.join(",");

                bootstrap.Modal.getInstance(document.getElementById("modalChonNguoiNhan")).hide();
            });

            function capNhatHiddenInput(danhSachDiv, hiddenInput) {
                var badges = danhSachDiv.querySelectorAll("span[data-ten]");
                var arr = [];
                for (var i = 0; i < badges.length; i++) {
                    arr.push(badges[i].getAttribute("data-ten"));
                }
                hiddenInput.value = arr.join(",");
            }
        </script>
        <script>
            $('#taskForm').on('submit', function (e) {
                e.preventDefault(); // Ngăn form submit mặc định

                const taskId = $('#taskId').val(); // nếu có ID thì là sửa, không thì là thêm
                const formData = new FormData(this); // lấy dữ liệu form bao gồm cả file

                formData.append("du_an_id", PROJECT_ID);

                const url = taskId ? './capNhatCongviec' : './themCongviec';

                $.ajax({
                    url: url,
                    type: 'POST',
                    data: formData,
                    processData: false, // cần để gửi FormData
                    contentType: false, // cần để gửi FormData
                    success: function (response) {
                        if (response.success) {
                            $('#modalTask').modal('hide');
                            showToast('success', taskId ? 'Cập nhật thành công' : 'Thêm mới thành công');
                            location.reload();
                        } else {
                            showToast('error', response.message || (taskId ? 'Cập nhật thất bại' : 'Thêm mới thất bại'));
                        }
                    },
                    error: function () {
                        showToast('error', taskId ? 'Cập nhật thất bại' : 'Thêm mới thất bại');
                    }
                });
            });
        </script>
        <script>
            // ====== LỌC CÔNG VIỆC ======
            $('#btnFilter').on('click', function (e) {
                e.preventDefault();

                var $btn = $(this);
                var keyword = $('input[name="keyword"]').val() || '';
                var phongBan = $('select[name="ten_phong_ban"]').val() || '';
                var trangThai = $('select[name="trangThai"]').val() || '';

                $.ajax({
                    url: './locCongviec',
                    type: 'POST',
                    data: {
                        keyword: keyword,
                        phong_ban: phongBan,
                        trang_thai: trangThai,
                        projectId: PROJECT_ID,
                        returnJson: (currentView === 'list' || currentView === 'calendar') ? 'true' : 'false'
                    },
                    dataType: (currentView === 'list' || currentView === 'calendar') ? 'json' : 'html',
                    beforeSend: function () {
                        $btn.prop('disabled', true).data('orig-text', $btn.html()).html('<i class="fa fa-spinner fa-spin"></i> Đang lọc...');
                    },
                    success: function (response) {
                        if (currentView === 'kanban') {
                            // Kanban view - nhận HTML
                            if (response && $.trim(response).length > 0) {
                                $('.kanban-board').replaceWith(response);
                                showToast('success', 'Đã áp dụng bộ lọc.');
                            } else {
                                $('.kanban-board').html('<div class="text-center text-muted p-3">Không có dữ liệu phù hợp</div>');
                                showToast('info', 'Không tìm thấy kết quả phù hợp.');
                            }
                        } else if (currentView === 'list') {
                            // List view - nhận JSON và render
                            renderListViewFromJson(response);
                            showToast('success', 'Đã áp dụng bộ lọc cho danh sách.');
                        } else if (currentView === 'calendar') {
                            // Calendar view - nhận JSON và render
                            renderCalendarViewFromJson(response);
                            showToast('success', 'Đã áp dụng bộ lọc cho lịch.');
                        }
                    },
                    error: function () {
                        if (currentView === 'kanban') {
                            $('.kanban-board').html('<div class="text-danger text-center p-3">Lỗi khi lọc công việc</div>');
                        }
                        showToast('error', 'Lỗi khi lọc công việc.');
                    },
                    complete: function () {
                        $btn.prop('disabled', false).html($btn.data('orig-text') || '<i class="fa-solid fa-filter"></i> Lọc');
                    }
                });
            });

            // ====== RENDER LIST VIEW TỪ JSON ======
            function renderListViewFromJson(tasks) {
                var tbody = $('#taskListTableBody');
                tbody.empty();

                if (!tasks || tasks.length === 0) {
                    tbody.html('<tr><td colspan="8" class="text-center text-muted py-4">Không tìm thấy công việc phù hợp</td></tr>');
                    return;
                }

                tasks.forEach(function (task) {
                    var priorityClass = (task.muc_do_uu_tien === 'Cao') ? 'priority-high' :
                            (task.muc_do_uu_tien === 'Trung bình') ? 'priority-medium' : 'priority-low';

                    var statusClass = (task.trang_thai === 'Đang thực hiện') ? 'status-in-progress' :
                            (task.trang_thai === 'Đã hoàn thành') ? 'status-completed' :
                            (task.trang_thai === 'Trễ hạn') ? 'status-late' : 'status-not-started';

                    var hasReminder = (task.nhac_viec == 1);
                    var alertClass = hasReminder ? 'task-row--alert' : '';

                    var row = ''
                            + '<tr class="task-row ' + alertClass + '" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"'
                            + ' data-id="' + (task.id || '') + '"'
                            + ' data-ten="' + (task.ten_cong_viec || '') + '"'
                            + ' data-mo-ta="' + (task.mo_ta || '') + '"'
                            + ' data-han="' + (task.han_hoan_thanh || '') + '"'
                            + ' data-uu-tien="' + (task.muc_do_uu_tien || '') + '"'
                            + ' data-ten_nguoi_giao="' + (task.nguoi_giao_id || '') + '"'
                            + ' data-ten_nguoi_nhan="' + (task.nguoi_nhan_ten || '') + '"'
                            + ' data-ten_phong_ban="' + (task.phong_ban_id || '') + '"'
                            + ' data-trang-thai="' + (task.trang_thai || '') + '"'
                            + ' data-tai_lieu_cv="' + (task.tai_lieu_cv || '') + '"'
                            + ' data-file_tai_lieu="' + (task.file_tai_lieu || '') + '">'
                            + '    <td class="task-name">' + (task.ten_cong_viec || '') + '</td>'
                            + '    <td>' + (task.nguoi_giao_id || '') + '</td>'
                            + '    <td>' + (task.nguoi_nhan_ten || '') + '</td>'
                            + '    <td>' + (task.phong_ban_id || '') + '</td>'
                            + '    <td>' + (task.han_hoan_thanh || '') + '</td>'
                            + '    <td><span class="badge ' + priorityClass + '">' + (task.muc_do_uu_tien || '') + '</span></td>'
                            + '    <td><span class="badge ' + statusClass + '">' + (task.trang_thai || '') + '</span></td>'
                            + '    <td>'
                            + '        <div class="action-btns" onclick="event.stopPropagation();">'
                            + '            <button class="btn btn-sm btn-warning" title="Lưu trữ" onclick="archiveTask(' + "'" + task.id + "'" + ')">'
                            + '                <i class="fa-solid fa-archive"></i>'
                            + '            </button>'
                            + '            <button class="btn btn-sm btn-info" title="Nhắc việc" onclick="remindTask(' + "'" + task.id + "'" + ')">'
                            + '                <i class="fa-solid fa-bell"></i>'
                            + '            </button>'
                            + '            <button class="btn btn-sm btn-danger" title="Xóa" onclick="deleteTask(' + "'" + task.id + "'" + ')">'
                            + '                <i class="fa-solid fa-trash"></i>'
                            + '            </button>'
                            + '        </div>'
                            + '    </td>'
                            + '</tr>';

                    tbody.append(row);
                });
            }

            // ====== RENDER CALENDAR VIEW TỪ JSON ======
            function renderCalendarViewFromJson(tasks) {
                if (!calendar) {
                    initCalendar();
                }

                // Xóa tất cả events hiện tại
                calendar.removeAllEvents();

                if (!tasks || tasks.length === 0) {
                    showToast('info', 'Không tìm thấy công việc phù hợp');
                    return;
                }

                // Thêm events mới từ kết quả lọc
                tasks.forEach(function (task) {
                    const eventClass = task.trang_thai === 'Đang thực hiện' ? 'event-in-progress' :
                            task.trang_thai === 'Đã hoàn thành' ? 'event-completed' :
                            task.trang_thai === 'Trễ hạn' ? 'event-late' : 'event-not-started';

                    calendar.addEvent({
                        id: task.id,
                        title: task.ten_cong_viec || '',
                        start: task.han_hoan_thanh,
                        className: eventClass,
                        extendedProps: {
                            nguoiGiao: task.nguoi_giao_id || '',
                            nguoiNhan: task.nguoi_nhan_ten || '',
                            phongBan: task.phong_ban_id || '',
                            uuTien: task.muc_do_uu_tien || '',
                            trangThai: task.trang_thai || '',
                            moTa: task.mo_ta || '',
                            taiLieu: task.tai_lieu_cv || '',
                            fileTaiLieu: task.file_tai_lieu || ''
                        }
                    });
                });
            }

            // ====== HÀM TOAST DÙNG CHUNG ======
            function showToast(type, message) {
                var map = {
                    success: '#toastSuccess',
                    error: '#toastError',
                    info: '#toastInfo',
                    warning: '#toastWarning'
                };
                var toastId = map[type] || '#toastInfo';

                if ($(toastId).length === 0) {
                    var toastHtml =
                            '<div id="' + toastId.substring(1) + '" class="toast align-items-center border-0 position-fixed bottom-0 end-0 m-3" role="alert" aria-live="assertive" aria-atomic="true">' +
                            '<div class="d-flex">' +
                            '<div class="toast-body"></div>' +
                            '<button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>' +
                            '</div>' +
                            '</div>';
                    $('body').append(toastHtml);
                }

                $(toastId).find('.toast-body').text(message);
                var bsToast = new bootstrap.Toast($(toastId)[0], {delay: 2500, autohide: true});
                bsToast.show();
            }
        </script>
        <script>
            // Danh sách các bước quy trình (demo, nên dùng AJAX thực tế)
            var processSteps = [
                {
                    id: "12",
                    name: "Thiết kế UI",
                    desc: "Thiết kế giao diện người dùng",
                    status: "Hoàn thành",
                    start: "2024-06-01",
                    end: "2024-06-03"
                }
            ];

            function calcProgressPercent(list) {
                var steps = list || processSteps;
                if (!steps || steps.length === 0)
                    return 0;
                var done = steps.filter(function (s) {
                    return s.status === "Đã hoàn thành";
                }).length;
                return Math.round((done / steps.length) * 100);
            }

            // Hiển thị các bước quy trình với nút chỉnh sửa trạng thái (logic đẹp mắt, chỉ 1 nút)
            function renderProcessSteps() {
                var percent = calcProgressPercent();
                var barClass = percent === 100 ? "bg-success" : "bg-warning";
                $('#taskProgressBar')
                        .css('width', percent + '%')
                        .removeClass('bg-warning bg-success')
                        .addClass(barClass)
                        .text(percent + '%');

                // 👇 Gửi phần trăm về server
                var taskId = $('#taskId').val();
                if (taskId) {
                    $.ajax({
                        url: 'capnhatTiendo',
                        method: 'POST',
                        data: {cong_viec_id: taskId, phan_tram: percent},
                        success: function () {
                            showToast('success', 'Cập nhật tiến độ thành công');
                        },
                        error: function () {
                            showToast('error', 'Lỗi khi cập nhật tiến độ');
                        }
                    });
                }

                var list = $('#processStepList');
                list.empty();
                if (processSteps.length === 0) {
                    list.append('<li class="list-group-item text-muted">Chưa có bước quy trình nào.</li>');
                } else {
                    processSteps.forEach(function (step, idx) {
                        var badgeClass = "bg-secondary";
                        if (step.status === "Đã hoàn thành")
                            badgeClass = "bg-success";
                        else if (step.status === "Đang thực hiện")
                            badgeClass = "bg-warning text-dark";
                        else if (step.status === "Trễ hạn")
                            badgeClass = "bg-danger";

                        var editBtn =
                                '<button class="btn btn-sm btn-outline-secondary me-1" onclick="showEditStepModal(' + idx + ')">' +
                                '<i class="fa-solid fa-pen"></i> Chỉnh sửa</button>';
                        var deleteBtn =
                                '<button class="btn btn-sm btn-danger ms-1" onclick="removeProcessStep(' + idx + ')">' +
                                '<i class="fa-solid fa-trash"></i></button>';

                        var html = '<li class="list-group-item d-flex justify-content-between align-items-center">' +
                                '<div>' +
                                '<b>' + step.name + '</b> ' +
                                '<span class="badge ' + badgeClass + '">' + step.status + '</span><br>' +
                                '<small>' + (step.desc ? step.desc : '') + '</small>' +
                                '<div class="text-muted small">Từ ' + (step.start || '-') + ' đến ' + (step.end || '-') + '</div>' +
                                '</div>' +
                                '<div>' + editBtn + deleteBtn + '</div>' +
                                '</li>';
                        list.append(html);
                    });
                }
            }

            function renderTaskReviews(data) {
                var list = document.getElementById("taskReviewList");
                list.innerHTML = "";
                data.forEach(function (item) {
                    var li = document.createElement("li");
                    var html = "<b>Người đánh giá:</b> " + item.ten_nguoi_danh_gia + "<br>" +
                            "<b>Nhận xét:</b> " + item.nhan_xet + "<br>" +
                            "<i class='text-muted'>" + item.thoi_gian + "</i>";
                    li.innerHTML = html;
                    li.classList.add("mb-2", "border", "p-2", "rounded");
                    list.appendChild(li);
                });
            }

            function showEditStepModal(idx) {
                var step = processSteps[idx];
                var modalHtml =
                        '<div class="modal fade" id="modalEditStepStatus" tabindex="-1">' +
                        '<div class="modal-dialog">' +
                        '<form class="modal-content" id="formEditStepStatus">' +
                        '<input type="hidden" name="stepid" value="' + step.id + '">' +
                        '<div class="modal-header">' +
                        '<h5 class="modal-title"><i class="fa-solid fa-pen"></i> Chỉnh sửa bước quy trình</h5>' +
                        '<button type="button" class="btn-close" data-bs-dismiss="modal"></button>' +
                        '</div>' +
                        '<div class="modal-body">' +
                        '<div class="mb-2">' +
                        '<label class="form-label">Tên bước/giai đoạn</label>' +
                        '<input type="text" class="form-control" name="stepName" value="' + step.name + '" required>' +
                        '</div>' +
                        '<div class="mb-2">' +
                        '<label class="form-label">Mô tả</label>' +
                        '<textarea class="form-control" name="stepDesc" rows="2">' + (step.desc || '') + '</textarea>' +
                        '</div>' +
                        '<div class="mb-2">' +
                        '<label class="form-label">Trạng thái</label>' +
                        '<select class="form-select" name="stepStatus">' +
                        '<option value="Chưa bắt đầu"' + (step.status === "Chưa bắt đầu" ? " selected" : "") + '>Chưa bắt đầu</option>' +
                        '<option value="Đang thực hiện"' + (step.status === "Đang thực hiện" ? " selected" : "") + '>Đang thực hiện</option>' +
                        '<option value="Đã hoàn thành"' + (step.status === "Đã hoàn thành" ? " selected" : "") + '>Đã hoàn thành</option>' +
                        '</select>' +
                        '</div>' +
                        '<div class="mb-2 row">' +
                        '<div class="col"><label class="form-label">Ngày bắt đầu</label>' +
                        '<input type="date" class="form-control" name="stepStart" value="' + (step.start || '') + '"></div>' +
                        '<div class="col"><label class="form-label">Ngày kết thúc</label>' +
                        '<input type="date" class="form-control" name="stepEnd" value="' + (step.end || '') + '"></div>' +
                        '</div>' +
                        '</div>' +
                        '<div class="modal-footer">' +
                        '<button type="submit" class="btn btn-primary rounded-pill">Cập nhật</button>' +
                        '<button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>' +
                        '</div>' +
                        '</form>' +
                        '</div>' +
                        '</div>';
                $('#modalEditStepStatus').remove();
                $('body').append(modalHtml);
                var modal = new bootstrap.Modal(document.getElementById('modalEditStepStatus'));
                modal.show();

                $('#formEditStepStatus').on('submit', function (e) {
                    e.preventDefault();
                    processSteps[idx] = {
                        id: $(this).find('[name="stepid"]').val(),
                        name: $(this).find('[name="stepName"]').val(),
                        desc: $(this).find('[name="stepDesc"]').val(),
                        status: $(this).find('[name="stepStatus"]').val(),
                        start: $(this).find('[name="stepStart"]').val(),
                        end: $(this).find('[name="stepEnd"]').val()
                    };
                    renderProcessSteps();
                    modal.hide();
                    $('#modalEditStepStatus').remove();
                    var taskId = document.getElementById("taskId").value;
                    $.ajax({
                        url: './apiTaskSteps',
                        method: 'POST',
                        data: {
                            step_id: processSteps[idx].id,
                            name: processSteps[idx].name,
                            desc: processSteps[idx].desc,
                            status: processSteps[idx].status,
                            start: processSteps[idx].start,
                            end: processSteps[idx].end
                        },
                        success: function () {
                            showToast('success', 'Cập nhật bước thành công');
                        },
                        error: function () {
                            showToast('error', 'Cập nhật bước thất bại');
                        }
                    });
                });
                $('#modalEditStepStatus').on('hidden.bs.modal', function () {
                    $('#modalEditStepStatus').remove();
                });
            }

            window.removeProcessStep = function (idx) {
                var step = processSteps[idx];
                if (!step || !step.id) {
                    showToast('error', 'Không thể xác định bước cần xóa.');
                    return;
                }
                if (confirm("Bạn có chắc chắn muốn xóa bước này không?")) {
                    $.ajax({
                        url: './xoaQuytrinh',
                        method: 'POST',
                        data: {action: 'delete', step_id: step.id},
                        success: function () {
                            processSteps.splice(idx, 1);
                            renderProcessSteps();
                            showToast('success', 'Đã xóa bước thành công.');
                        },
                        error: function () {
                            showToast('error', 'Xóa thất bại. Vui lòng thử lại.');
                        }
                    });
                }
            };

            $('#btnAddProcessStep').on('click', function () {
                $('#formAddProcessStep')[0].reset();
                $('#modalAddProcessStep').modal('show');
            });
            $('#formAddProcessStep').on('submit', function (e) {
                e.preventDefault();
                var taskId = document.getElementById("taskId").value;
                var step = {
                    name: $(this).find('[name="stepName"]').val(),
                    desc: $(this).find('[name="stepDesc"]').val(),
                    status: $(this).find('[name="stepStatus"]').val(),
                    start: $(this).find('[name="stepStart"]').val(),
                    end: $(this).find('[name="stepEnd"]').val()
                };
                $.ajax({
                    url: './xoaQuytrinh',
                    method: 'POST',
                    data: {
                        action: 'add',
                        task_id: taskId,
                        name: step.name,
                        desc: step.desc,
                        status: step.status,
                        start: step.start,
                        end: step.end
                    },
                    success: function (newStepId) {
                        step.id = newStepId;
                        processSteps.push(step);
                        renderProcessSteps();
                        $('#modalAddProcessStep').modal('hide');
                        showToast('success', 'Thêm bước thành công');
                    },
                    error: function () {
                        showToast('error', 'Thêm bước thất bại');
                    }
                });
            });

            $('#modalTaskDetail').on('show.bs.modal', function () {
                renderProcessSteps();
            });

            document.addEventListener("DOMContentLoaded", function () {
                var tabProgress = document.getElementById("tab-task-progress");
                tabProgress.addEventListener("shown.bs.tab", function () {
                    var taskId = document.getElementById("taskId").value;
                    $.ajax({
                        url: './apiTaskSteps?task_id=' + taskId,
                        method: 'GET',
                        success: function (data) {
                            processSteps = data;
                            renderProcessSteps();
                        },
                        error: function () {
                            showToast('error', 'Không thể tải quy trình.');
                        }
                    });
                });

                var tabReview = document.getElementById("tab-task-review");
                if (tabReview) {
                    tabReview.addEventListener("shown.bs.tab", function () {
                        var taskId = document.getElementById("taskId").value;
                        $.ajax({
                            url: './apiDanhgiaCV?taskId=' + taskId,
                            method: 'GET',
                            success: function (data) {
                                renderTaskReviews(data);
                            },
                            error: function () {
                                showToast('error', 'Không thể tải đánh giá.');
                            }
                        });
                    });
                }
            });

            document.getElementById("btnAddReview").addEventListener("click", function () {
                var taskId = document.getElementById("taskId").value;
                var reviewerSelect = document.querySelector('select[name="ten_nguoi_danh_gia"]');
                var reviewerId = reviewerSelect.value;
                var comment = document.getElementById("reviewComment").value.trim();

                if (!reviewerId || !comment) {
                    showToast('error', 'Vui lòng chọn người đánh giá và nhập nhận xét.');
                    return;
                }
                if (!confirm("Bạn có chắc chắn muốn thêm đánh giá này không?")) {
                    return;
                }
                var formData = new URLSearchParams();
                formData.append("cong_viec_id", taskId);
                formData.append("nguoi_danh_gia_id", reviewerId);
                formData.append("nhan_xet", comment);

                fetch("./apiDanhgiaCV", {
                    method: "POST",
                    headers: {"Content-Type": "application/x-www-form-urlencoded"},
                    body: formData.toString()
                })
                        .then(function (res) {
                            return res.json();
                        })
                        .then(function (data) {
                            if (data.success) {
                                showToast('success', 'Thêm đánh giá thành công!');
                                document.getElementById("reviewComment").value = "";
                                setTimeout(function () {
                                    loadTaskReviews(taskId);
                                }, 300);
                            } else {
                                showToast('error', 'Thêm thất bại: ' + (data.message || ''));
                            }
                        })
                        .catch(function () {
                            showToast('error', 'Đã xảy ra lỗi khi thêm đánh giá.');
                        });
            });

            function loadTaskReviews(taskId) {
                fetch("./apiDanhgiaCV?taskId=" + encodeURIComponent(taskId))
                        .then(function (res) {
                            return res.json();
                        })
                        .then(function (data) {
                            renderTaskReviews(data);
                        })
                        .catch(function () {
                            showToast('error', 'Không thể tải lại danh sách đánh giá.');
                        });
            }

            function updateAllTaskProgressBars() {
                document.querySelectorAll('.task-progress-bar').forEach(function (bar) {
                    var taskId = bar.getAttribute('data-task-id');
                    fetch('./apiTaskSteps?task_id=' + encodeURIComponent(taskId))
                            .then(function (res) {
                                return res.json();
                            })
                            .then(function (steps) {
                                var percent = calcProgressPercent(steps);
                                var barClass = "bg-warning";
                                if (percent === 100)
                                    barClass = "bg-success";
                                else if (percent === 0)
                                    barClass = "bg-secondary";
                                bar.style.width = percent + "%";
                                bar.textContent = percent + "%";
                                bar.className = "progress-bar task-progress-bar " + barClass;
                            })
                            .catch(function () {
                                showToast('error', 'Lỗi khi tải bước quy trình');
                            });
                });
            }
            document.addEventListener("DOMContentLoaded", function () {
                updateAllTaskProgressBars();
            });
        </script>
        <script>
            // ====== TAB NAVIGATION ======
            document.addEventListener('DOMContentLoaded', function () {
                // Xử lý click tab để load dữ liệu
                const archivedTab = document.getElementById('archived-tasks-tab');
                const deletedTab = document.getElementById('deleted-tasks-tab');

                if (archivedTab) {
                    archivedTab.addEventListener('shown.bs.tab', function () {
                        loadArchivedTasks();
                    });
                }

                if (deletedTab) {
                    deletedTab.addEventListener('shown.bs.tab', function () {
                        loadDeletedTasks();
                    });
                }

                // Thêm keyboard navigation cho tabs
                document.addEventListener('keydown', function (e) {
                    if (e.key === 'Tab' && e.target.classList.contains('nav-link')) {
                        e.target.focus();
                    }
                });
            });

            // ====== LOAD ARCHIVED TASKS ======
            function loadArchivedTasks() {
                const container = document.querySelector('.archived-tasks-container');
                container.innerHTML = '<div class="text-center py-3"><i class="fa-solid fa-spinner fa-spin"></i> Đang tải...</div>';

                fetch('./locCongviec', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'tinh_trang=Lưu trữ&view=archived'
                })
                        .then(res => res.text())
                        .then(html => {
                            if (html.trim()) {
                                renderArchivedTasks(html);
                            } else {
                                container.innerHTML = '<div class="text-muted text-center py-4"><i class="fa-solid fa-archive fa-2x mb-2"></i><br>Chưa có công việc nào được lưu trữ</div>';
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            container.innerHTML = '<div class="text-danger text-center py-3">Lỗi khi tải dữ liệu</div>';
                        });
            }

            // ====== LOAD DELETED TASKS ======
            function loadDeletedTasks() {
                const container = document.querySelector('.deleted-tasks-container');
                container.innerHTML = '<div class="text-center py-3"><i class="fa-solid fa-spinner fa-spin"></i> Đang tải...</div>';

                fetch('./locCongviec', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'tinh_trang=Đã xóa&view=deleted'
                })
                        .then(res => res.text())
                        .then(html => {
                            if (html.trim()) {
                                renderDeletedTasks(html);
                            } else {
                                container.innerHTML = '<div class="text-muted text-center py-4"><i class="fa-solid fa-trash fa-2x mb-2"></i><br>Thùng rác trống</div>';
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            container.innerHTML = '<div class="text-danger text-center py-3">Lỗi khi tải dữ liệu</div>';
                        });
            }

            // ====== RENDER ARCHIVED TASKS ======
            function renderArchivedTasks(html) {
                // Tạm thời tạo HTML mẫu cho archived task
                const container = document.querySelector('.archived-tasks-container');
                container.innerHTML = `
                            <div class="archived-task kanban-task">
                                <div class="task-title">Mẫu công việc đã lưu trữ</div>
                                <div class="task-meta">Người giao: <b>Admin</b><br>Người nhận: <b>User</b></div>
                                <span class="task-priority badge bg-warning text-dark">Trung bình</span>
                                <span class="task-status badge bg-secondary">Lưu trữ</span>
                                <div class="progress">
                                    <div class="progress-bar bg-secondary" style="width: 75%;"></div>
                                </div>
                                <div class="task-actions">
                                    <button class="task-dots-btn" type="button">
                                        <i class="fa-solid fa-ellipsis-vertical"></i>
                                    </button>
                                    <div class="task-actions-dropdown">
                                        <button class="task-action-item restore-action" type="button" data-task-id="1" data-action="restore">
                                            <i class="fa-solid fa-undo"></i>
                                            <span>Khôi phục</span>
                                        </button>
                                        <button class="task-action-item permanent-delete-action" type="button" data-task-id="1" data-action="permanent-delete">
                                            <i class="fa-solid fa-trash-can"></i>
                                            <span>Xóa vĩnh viễn</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        `;
            }

            // ====== RENDER DELETED TASKS ======
            function renderDeletedTasks(html) {
                // Tạm thời tạo HTML mẫu cho deleted task  
                const container = document.querySelector('.deleted-tasks-container');
                container.innerHTML = `
                            <div class="deleted-task kanban-task">
                                <div class="task-title">Mẫu công việc đã xóa</div>
                                <div class="task-meta">Người giao: <b>Admin</b><br>Người nhận: <b>User</b></div>
                                <span class="task-priority badge bg-danger">Cao</span>
                                <span class="task-status badge bg-danger">Đã xóa</span>
                                <div class="progress">
                                    <div class="progress-bar bg-danger" style="width: 30%;"></div>
                                </div>
                                <div class="task-actions">
                                    <button class="task-dots-btn" type="button">
                                        <i class="fa-solid fa-ellipsis-vertical"></i>
                                    </button>
                                    <div class="task-actions-dropdown">
                                        <button class="task-action-item restore-action" type="button" data-task-id="2" data-action="restore">
                                            <i class="fa-solid fa-undo"></i>
                                            <span>Khôi phục</span>
                                        </button>
                                        <button class="task-action-item permanent-delete-action" type="button" data-task-id="2" data-action="permanent-delete">
                                            <i class="fa-solid fa-trash-can"></i>
                                            <span>Xóa vĩnh viễn</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        `;
            }

            // ====== TASK ACTIONS - NÚT 3 CHẤM ======
            document.addEventListener('DOMContentLoaded', function () {
                // Xử lý click cho các action item
                document.addEventListener('click', function (e) {
                    if (e.target.closest('.task-action-item')) {
                        const item = e.target.closest('.task-action-item');

                        // Lấy từ chính button, fallback từ thẻ .kanban-task gần nhất
                        const taskId =
                                item.dataset.taskId ||
                                item.closest('.kanban-task')?.dataset.id;

                        if (!taskId) {
                            console.error('Không tìm thấy task_id trên phần tử');
                            showToast('error', 'Không tìm thấy ID công việc');
                            return;
                        }

                        const action = item.dataset.action;
                        e.stopPropagation();
                        e.preventDefault();

                        switch (action) {
                            case 'archive':
                                archiveTask(taskId);
                                break;
                            case 'remind':
                                remindTask(taskId);
                                break;
                            case 'delete':
                                deleteTask(taskId);
                                break;
                            case 'restore':
                                restoreTask(taskId);
                                break;
                            case 'permanent-delete':
                                permanentDeleteTask(taskId);
                                break;
                        }
                    }
                });

                // Ngăn dropdown đóng khi click vào
                document.addEventListener('click', function (e) {
                    if (e.target.closest('.task-actions-dropdown')) {
                        e.stopPropagation();
                    }
                });
            });

            // ====== CÁC HÀM XỬ LÝ ACTION ======
            function archiveTask(taskId) {
                Swal.fire({
                    title: 'Lưu trữ công việc?',
                    text: 'Bạn có chắc chắn muốn lưu trữ công việc này không?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Lưu trữ',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        showToast('info', '📁 Đang lưu trữ công việc...');

                        fetch('./suaCongviec', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                            body: new URLSearchParams({
                                task_id: String(taskId),
                                action: 'archive',
                                tinh_trang: 'Lưu trữ'
                            })
                        })
                                .then(res => res.json())
                                .then(data => {
                                    if (data.success) {
                                        Swal.fire('Thành công!', 'Công việc đã được lưu trữ.', 'success');
                                        setTimeout(() => location.reload(), 1200);
                                    } else {
                                        Swal.fire('Lỗi!', data.message || 'Lưu trữ thất bại.', 'error');
                                    }
                                })
                                .catch(err => {
                                    console.error(err);
                                    Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
                                });
                    }
                });
            }

            function remindTask(taskId) {
                fetch('./suaCongviec', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: new URLSearchParams({
                        task_id: String(taskId),
                        action: 'remind',
                        nhac_viec: '1'
                    })
                })
                        .then(res => res.json())
                        .then(data => {
                            if (data.success) {
                                Swal.fire('Thành công!', 'Nhắc việc thành công.', 'success');
                                setTimeout(() => location.reload(), 1200);
                            } else {
                                Swal.fire('Lỗi!', data.message || 'Lưu trữ thất bại.', 'error');
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
                        });
            }

            function deleteTask(taskId) {
                Swal.fire({
                    title: 'Xác nhận xóa?',
                    text: 'Bạn có chắc chắn muốn xóa công việc này? (Sẽ được chuyển vào thùng rác)',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Xóa',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        showToast('info', '🗑️ Đang chuyển vào thùng rác...');

                        fetch('./suaCongviec', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                            body: new URLSearchParams({
                                task_id: String(taskId),
                                action: 'delete',
                                tinh_trang: 'Đã xóa'
                            })
                        })
                                .then(res => res.json())
                                .then(data => {
                                    if (data.success) {
                                        Swal.fire('Đã xóa!', 'Công việc đã được chuyển vào thùng rác.', 'success');
                                        setTimeout(() => location.reload(), 1200);
                                    } else {
                                        Swal.fire('Lỗi!', data.message || 'Xóa thất bại.', 'error');
                                    }
                                })
                                .catch(err => {
                                    console.error(err);
                                    Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
                                });
                    }
                });
            }


            // ====== KHÔI PHỤC CÔNG VIỆC ======
            function restoreTask(taskId) {
                Swal.fire({
                    title: 'Khôi phục công việc?',
                    text: 'Bạn có muốn khôi phục công việc này không?',
                    icon: 'info',
                    showCancelButton: true,
                    confirmButtonColor: '#28a745',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Khôi phục',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        showToast('info', '🔄 Đang khôi phục công việc...');

                        fetch('./suaCongviec', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                            body: new URLSearchParams({
                                task_id: String(taskId),
                                action: 'restore',
                                trang_thai: 'Chưa bắt đầu'
                            })
                        })
                                .then(res => res.json())
                                .then(data => {
                                    if (data.success) {
                                        Swal.fire('Thành công!', 'Công việc đã được khôi phục.', 'success');
                                        setTimeout(() => location.reload(), 1200);
                                    } else {
                                        Swal.fire('Lỗi!', data.message || 'Khôi phục thất bại.', 'error');
                                    }
                                })
                                .catch(err => {
                                    console.error(err);
                                    Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
                                });
                    }
                });
            }

            // ====== XÓA VĨNH VIỄN CÔNG VIỆC ======
            function permanentDeleteTask(taskId) {
                Swal.fire({
                    title: 'Xác nhận xóa vĩnh viễn?',
                    text: '⚠️ Hành động này không thể hoàn tác. Công việc sẽ bị xóa hoàn toàn khỏi hệ thống!',
                    icon: 'error',
                    showCancelButton: true,
                    confirmButtonColor: '#d33', // đỏ đậm
                    cancelButtonColor: '#6c757d', // xám
                    confirmButtonText: 'Xóa vĩnh viễn',
                    cancelButtonText: 'Hủy',
                    reverseButtons: true
                }).then((result) => {
                    if (result.isConfirmed) {
                        Swal.fire({
                            title: 'Đang xóa...',
                            text: 'Vui lòng chờ trong giây lát',
                            allowOutsideClick: false,
                            didOpen: () => Swal.showLoading()
                        });

                        fetch('./xoaCongviec', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                            body: new URLSearchParams({id: String(taskId), task_id: String(taskId), permanent: 'true'})
                        })
                                .then(async (res) => {
                                    const text = await res.text();            // lấy text thuần
                                    let data;
                                    try {
                                        data = text ? JSON.parse(text) : {success: res.ok, message: ''};
                                    } catch {
                                        data = {success: res.ok, message: text};
                                    } // nếu không phải JSON, vẫn coi là ok nếu res.ok

                                    if (data.success) {
                                        Swal.fire({icon: 'success', title: 'Đã xóa vĩnh viễn!', showConfirmButton: false, timer: 1400});
                                        setTimeout(() => {
                                            const tab = document.querySelector('.nav-link.active');
                                            if (tab?.id === 'deleted-tasks-tab')
                                                loadDeletedTasks();
                                            else
                                                location.reload();
                                        }, 1400);
                                    } else {
                                        Swal.fire('Lỗi!', data.message || 'Xóa vĩnh viễn thất bại.', 'error');
                                    }
                                })
                                .catch((err) => {
                                    console.error('Network/parse error:', err);
                                    Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
                                });
                    }
                });
            }

            // ====== TAB NAVIGATION ======
            document.addEventListener('DOMContentLoaded', function () {
                // Xử lý click tab để load dữ liệu
                const archivedTab = document.getElementById('archived-tasks-tab');
                const deletedTab = document.getElementById('deleted-tasks-tab');

                if (archivedTab) {
                    archivedTab.addEventListener('shown.bs.tab', function () {
                        loadArchivedTasks();
                    });
                }

                if (deletedTab) {
                    deletedTab.addEventListener('shown.bs.tab', function () {
                        loadDeletedTasks();
                    });
                }
            });

            // ====== LOAD ARCHIVED TASKS ======
            function loadArchivedTasks() {
                const container = document.querySelector('.archived-tasks-container');
                const kanbanBoard = container.querySelector('.kanban-board');

                // Hiển thị loading
                kanbanBoard.querySelectorAll('.kanban-col').forEach(col => {
                    const placeholder = col.querySelector('.text-center');
                    if (placeholder) {
                        placeholder.innerHTML = '<i class="fa-solid fa-spinner fa-spin fa-2x mb-2"></i><p>Đang tải...</p>';
                    }
                });

                fetch('./locCongviec', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'tinh_trang=Lưu trữ&view=archived'
                })
                        .then(res => res.text())
                        .then(html => {
                            if (html.trim()) {
                                renderArchivedTasks(html);
                            } else {
                                resetArchivedPlaceholders();
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            kanbanBoard.querySelectorAll('.kanban-col').forEach(col => {
                                const placeholder = col.querySelector('.text-center');
                                if (placeholder) {
                                    placeholder.innerHTML = '<i class="fa-solid fa-exclamation-triangle fa-2x mb-2 text-danger"></i><p class="text-danger">Lỗi khi tải dữ liệu</p>';
                                }
                            });
                        });
            }

            // ====== LOAD DELETED TASKS ======
            function loadDeletedTasks() {
                const container = document.querySelector('.deleted-tasks-container');
                const kanbanBoard = container.querySelector('.kanban-board');

                // Hiển thị loading
                kanbanBoard.querySelectorAll('.kanban-col').forEach(col => {
                    const placeholder = col.querySelector('.text-center');
                    if (placeholder) {
                        placeholder.innerHTML = '<i class="fa-solid fa-spinner fa-spin fa-2x mb-2"></i><p>Đang tải...</p>';
                    }
                });

                fetch('./locCongviec', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'tinh_trang=Đã xóa&view=deleted'
                })
                        .then(res => res.text())
                        .then(html => {
                            if (html.trim()) {
                                renderDeletedTasks(html);
                            } else {
                                resetDeletedPlaceholders();
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            kanbanBoard.querySelectorAll('.kanban-col').forEach(col => {
                                const placeholder = col.querySelector('.text-center');
                                if (placeholder) {
                                    placeholder.innerHTML = '<i class="fa-solid fa-exclamation-triangle fa-2x mb-2 text-danger"></i><p class="text-danger">Lỗi khi tải dữ liệu</p>';
                                }
                            });
                        });
            }

            // ====== RENDER ARCHIVED TASKS ======
            function renderArchivedTasks(html) {
                // Placeholder cho việc render archived tasks
                resetArchivedPlaceholders();
                showToast('info', 'Đã tải công việc lưu trữ');
            }

            // ====== RENDER DELETED TASKS ======
            function renderDeletedTasks(html) {
                // Placeholder cho việc render deleted tasks
                resetDeletedPlaceholders();
                showToast('info', 'Đã tải thùng rác');
            }

            // ====== RESET PLACEHOLDERS ======
            function resetArchivedPlaceholders() {
                document.querySelectorAll('.archived-col .text-center').forEach(placeholder => {
                    placeholder.innerHTML = '<i class="fa-solid fa-inbox fa-2x mb-2"></i><p>Chưa có công việc lưu trữ</p>';
                });
            }

            function resetDeletedPlaceholders() {
                document.querySelectorAll('.deleted-col .text-center').forEach(placeholder => {
                    placeholder.innerHTML = '<i class="fa-solid fa-trash fa-2x mb-2"></i><p>Thùng rác trống</p>';
                });
            }
        </script>
        <script>
            document.addEventListener('click', function (e) {
                const btn = e.target.closest('.task-dots-btn');
                const dropdown = btn?.nextElementSibling;

                // Nếu click vào nút 3 chấm
                if (btn && dropdown) {
                    e.stopPropagation();
                    e.preventDefault(); // 🔥 ngăn Bootstrap modal trigger
                    document.querySelectorAll('.task-actions-dropdown.show').forEach(d => {
                        if (d !== dropdown)
                            d.classList.remove('show');
                    });
                    dropdown.classList.toggle('show');
                    return;
                }

                // Nếu click ra ngoài thì ẩn tất cả menu
                if (!e.target.closest('.task-actions-dropdown')) {
                    document.querySelectorAll('.task-actions-dropdown.show').forEach(d => d.classList.remove('show'));
                }
            }, true);
        </script>

        <script>
            // ====== XỬ LÝ NHẮC NHỞ CÔNG VIỆC ======
            document.addEventListener('DOMContentLoaded', function () {
                // Xử lý khi người dùng click vào task có chuông nhắc nhở
                document.addEventListener('click', function (e) {
                    const taskCard = e.target.closest('.kanban-task');
                    if (taskCard && taskCard.querySelector('.task-reminder-bell')) {
                        const taskId = taskCard.getAttribute('data-task-id');

                        // Đánh dấu đã đọc nhắc nhở
                        markReminderAsRead(taskId);

                        // Ẩn chuông ngay lập tức để UX tốt hơn
                        const bell = taskCard.querySelector('.task-reminder-bell');
                        if (bell) {
                            bell.style.opacity = '0';
                            bell.style.transform = 'scale(0)';
                            setTimeout(() => {
                                bell.style.display = 'none';
                            }, 200);
                        }
                    }
                });
            });

            function markReminderAsRead(taskId) {
                fetch('./suaCongviec', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: new URLSearchParams({
                        task_id: String(taskId),
                        action: 'markRemind',
                        nhac_viec: '0'
                    })
                })
                        .then(res => res.json())
                        .then(data => {
                            if (data.success) {
                                Swal.fire('Đã đọc!', 'Đã tắt nhắc việc.', 'success');
                                setTimeout(() => location.reload(), 1200);
                            } else {
                                Swal.fire('Lỗi!', data.message || 'Đọc thất bại.', 'error');
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
                        });
            }
        </script>

        <script>
            // ====== VIEW SWITCHING (KANBAN / LIST / CALENDAR) ======
            let currentView = 'kanban';
            let calendar = null;

            function switchView(viewType) {
                currentView = viewType;

                // Update button states
                document.querySelectorAll('.view-mode-toggle .btn').forEach(btn => btn.classList.remove('active'));

                if (viewType === 'kanban') {
                    document.getElementById('viewKanban').classList.add('active');
                    document.querySelector('.kanban-board').style.display = 'grid';
                    document.getElementById('listView').classList.remove('active');
                    document.getElementById('calendarView').classList.remove('active');
                } else if (viewType === 'list') {
                    document.getElementById('viewList').classList.add('active');
                    document.querySelector('.kanban-board').style.display = 'none';
                    document.getElementById('listView').classList.add('active');
                    document.getElementById('calendarView').classList.remove('active');
                    initTableSorting();
                } else if (viewType === 'calendar') {
                    document.getElementById('viewCalendar').classList.add('active');
                    document.querySelector('.kanban-board').style.display = 'none';
                    document.getElementById('listView').classList.remove('active');
                    document.getElementById('calendarView').classList.add('active');
                    initCalendar();
                }
            }

            // ====== TABLE SORTING ======
            function initTableSorting() {
                const headers = document.querySelectorAll('.task-table thead th.sortable');
                headers.forEach(header => {
                    header.addEventListener('click', function () {
                        const sortField = this.dataset.sort;
                        const currentSort = this.classList.contains('sort-asc') ? 'asc' :
                                this.classList.contains('sort-desc') ? 'desc' : 'none';

                        // Remove sort classes from all headers
                        headers.forEach(h => h.classList.remove('sort-asc', 'sort-desc'));

                        // Apply new sort
                        let newSort = currentSort === 'none' ? 'asc' : currentSort === 'asc' ? 'desc' : 'asc';
                        this.classList.add('sort-' + newSort);

                        sortTable(sortField, newSort);
                    });
                });
            }

            function sortTable(field, order) {
                const tbody = document.getElementById('taskListTableBody');
                const rows = Array.from(tbody.querySelectorAll('tr'));

                rows.sort((a, b) => {
                    let aVal = a.dataset[field.replace(/_/g, '')] || '';
                    let bVal = b.dataset[field.replace(/_/g, '')] || '';

                    // Handle dates
                    if (field === 'han_hoan_thanh') {
                        aVal = new Date(aVal);
                        bVal = new Date(bVal);
                    }

                    if (aVal < bVal)
                        return order === 'asc' ? -1 : 1;
                    if (aVal > bVal)
                        return order === 'asc' ? 1 : -1;
                    return 0;
                });

                rows.forEach(row => tbody.appendChild(row));
            }

            // ====== FULLCALENDAR INITIALIZATION ======
            function initCalendar() {
                if (calendar) {
                    calendar.render();
                    return;
                }

                const calendarEl = document.getElementById('taskCalendar');

                // Prepare events from task list
                const events = [];
            <% for (Map<String, Object> task : taskList) { 
                    String eventClass = "event-not-started";
                    if ("Đang thực hiện".equals(task.get("trang_thai"))) eventClass = "event-in-progress";
                    else if ("Đã hoàn thành".equals(task.get("trang_thai"))) eventClass = "event-completed";
                    else if ("Trễ hạn".equals(task.get("trang_thai"))) eventClass = "event-late";
            %>
                events.push({
                    id: '<%= task.get("id") %>',
                    title: '<%= task.get("ten_cong_viec") != null ? task.get("ten_cong_viec").toString().replace("'", "\\'") : "" %>',
                    start: '<%= task.get("han_hoan_thanh") %>',
                    className: '<%= eventClass %>',
                    extendedProps: {
                        nguoiGiao: '<%= task.get("nguoi_giao_id") %>',
                        nguoiNhan: '<%= task.get("nguoi_nhan_ten") %>',
                        phongBan: '<%= task.get("phong_ban_id") %>',
                        uuTien: '<%= task.get("muc_do_uu_tien") %>',
                        trangThai: '<%= task.get("trang_thai") %>',
                        moTa: '<%= task.get("mo_ta") != null ? task.get("mo_ta").toString().replace("'", "\\'").replace("\n", " ") : "" %>',
                        taiLieu: '<%= task.get("tai_lieu_cv") %>',
                        fileTaiLieu: '<%= task.get("file_tai_lieu") %>'
                    }
                });
            <% } %>

                calendar = new FullCalendar.Calendar(calendarEl, {
                    initialView: 'dayGridMonth',
                    headerToolbar: {
                        left: 'prev,next today',
                        center: 'title',
                        right: 'dayGridMonth,timeGridWeek,timeGridDay'
                    },
                    locale: 'vi',
                    buttonText: {
                        today: 'Hôm nay',
                        month: 'Tháng',
                        week: 'Tuần',
                        day: 'Ngày'
                    },
                    events: events,
                    editable: true,
                    eventClick: function (info) {
                        // Open task detail modal
                        const event = info.event;
                        const props = event.extendedProps;

                        const modal = document.getElementById('modalTaskDetail');
                        const button = document.createElement('button');
                        button.setAttribute('data-id', event.id);
                        button.setAttribute('data-ten', event.title);
                        button.setAttribute('data-mo-ta', props.moTa);
                        button.setAttribute('data-han', event.startStr);
                        button.setAttribute('data-uu-tien', props.uuTien);
                        button.setAttribute('data-ten_nguoi_giao', props.nguoiGiao);
                        button.setAttribute('data-ten_nguoi_nhan', props.nguoiNhan);
                        button.setAttribute('data-ten_phong_ban', props.phongBan);
                        button.setAttribute('data-trang-thai', props.trangThai);
                        button.setAttribute('data-tai_lieu_cv', props.taiLieu);
                        button.setAttribute('data-file_tai_lieu', props.fileTaiLieu);

                        const modalEvent = new Event('show.bs.modal');
                        modalEvent.relatedTarget = button;
                        modal.dispatchEvent(modalEvent);

                        new bootstrap.Modal(modal).show();
                    },
                    eventDrop: function (info) {
                        // Update deadline when event is dragged
                        const newDate = info.event.start.toISOString().split('T')[0];
                        updateTaskDeadline(info.event.id, newDate);
                    },
                    eventResize: function (info) {
                        const newDate = info.event.end ? info.event.end.toISOString().split('T')[0] :
                                info.event.start.toISOString().split('T')[0];
                        updateTaskDeadline(info.event.id, newDate);
                    }
                });

                calendar.render();
            }

            function updateTaskDeadline(taskId, newDeadline) {
                fetch('./suaCongviec', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: new URLSearchParams({
                        task_id: taskId,
                        han_hoan_thanh: newDeadline,
                        action: 'updateDeadline'
                    })
                })
                        .then(res => res.json())
                        .then(data => {
                            if (data.success) {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Đã cập nhật!',
                                    text: 'Deadline đã được thay đổi',
                                    timer: 1500,
                                    showConfirmButton: false
                                });
                            } else {
                                Swal.fire('Lỗi!', data.message || 'Cập nhật thất bại', 'error');
                                calendar.refetchEvents();
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            Swal.fire('Lỗi!', 'Không thể kết nối server', 'error');
                            calendar.refetchEvents();
                        });
            }

            // Initialize default view on page load
            document.addEventListener('DOMContentLoaded', function () {
                switchView('kanban');
            });

            // ====== XỬ LÝ LOAD LỊCH SỬ CÔNG VIỆC ======
            let currentTaskIdForHistory = null;
            let historyLoaded = false;

            // Lắng nghe sự kiện mở modal để lấy task ID
            document.addEventListener('click', function (e) {
                const taskContent = e.target.closest('.task-content');
                if (taskContent) {
                    currentTaskIdForHistory = taskContent.dataset.id;
                    historyLoaded = false; // Reset khi mở modal mới
                }
            });

            // Lắng nghe sự kiện click vào tab Lịch sử
            document.addEventListener('click', function (e) {
                const historyTab = e.target.closest('[data-bs-target="#tabTaskHistory"]');
                if (historyTab && !historyLoaded && currentTaskIdForHistory) {
                    loadTaskHistory(currentTaskIdForHistory);
                }
            });

            // Hàm load lịch sử công việc
            function loadTaskHistory(taskId) {
                const timeline = document.getElementById('taskHistoryTimeline');
                if (!timeline)
                    return;

                // Hiển thị loading
                timeline.innerHTML = `
        <div class="history-empty">
            <i class="fa-solid fa-spinner fa-spin"></i>
            <p>Đang tải lịch sử công việc...</p>
        </div>
    `;

                // Gọi API
                fetch('./apiLichSuCongViec?taskId=' + taskId)
                        .then(res => res.json())
                        .then(data => {
                            historyLoaded = true;
                            renderTaskHistory(data);
                        })
                        .catch(err => {
                            console.error('Lỗi khi tải lịch sử:', err);
                            timeline.innerHTML = `
            <div class="history-empty">
                <i class="fa-solid fa-circle-exclamation"></i>
                <p>Không thể tải lịch sử công việc. Vui lòng thử lại.</p>
            </div>
        `;
                        });
            }

            // Hàm render lịch sử công việc
            function renderTaskHistory(historyData) {
                const timeline = document.getElementById('taskHistoryTimeline');
                if (!timeline)
                    return;

                // Nếu không có dữ liệu
                if (!historyData || historyData.length === 0) {
                    timeline.innerHTML = `
        <div class="history-empty">
            <i class="fa-solid fa-clock-rotate-left"></i>
            <p>Chưa có lịch sử thay đổi nào</p>
        </div>
    `;
                    return;
                }

                // Render danh sách lịch sử
                let html = '';
                historyData.forEach((item, index) => {
                    // Xử lý avatar
                    const avatarSrc = item.anh_dai_dien && item.anh_dai_dien.trim() !== ''
                            ? item.anh_dai_dien
                            : 'https://ui-avatars.com/api/?name=' + encodeURIComponent(item.ten_nhan_vien || 'User') + '&background=007bff&color=fff';

                    // Format thời gian
                    let timeStr = '';
                    if (item.thoi_gian) {
                        const date = new Date(item.thoi_gian);
                        const day = String(date.getDate()).padStart(2, '0');
                        const month = String(date.getMonth() + 1).padStart(2, '0');
                        const year = date.getFullYear();
                        const hours = String(date.getHours()).padStart(2, '0');
                        const minutes = String(date.getMinutes()).padStart(2, '0');
                        timeStr = day + '/' + month + '/' + year + ' ' + hours + ':' + minutes;
                    }

                    html += `
        <div class="history-item" style="animation-delay: ` + (index * 0.1) + `s">
            <div class="history-number">` + (index + 1) + `</div>
            <div class="history-avatar">
                <img src="` + avatarSrc + `" alt="Avatar" onerror="this.src='https://ui-avatars.com/api/?name=User&background=007bff&color=fff'">
            </div>
            <div class="history-content">
                <div class="history-user">` + (item.ten_nhan_vien || 'Không rõ') + `</div>
                <div class="history-description">` + (item.mo_ta_thay_doi || '') + `</div>
                <div class="history-time">
                    <i class="fa-solid fa-clock"></i> ` + timeStr + `
                </div>
            </div>
        </div>
    `;
                });

                timeline.innerHTML = html;
            }
        </script> 
    </body>
</html>
