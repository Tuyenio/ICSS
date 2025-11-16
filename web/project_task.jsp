<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Quản lý Công việc</title>
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.ckeditor.com/4.22.1/standard/ckeditor.js"></script>
        <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.css" rel="stylesheet">
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

            /* ========== PREMIUM CLEAR FILTER BUTTON STYLING ========== */
            .filter-actions {
                position: relative;
            }

            .clear-filter-btn {
                min-width: 42px;
                height: 42px;
                padding: 0;
                display: flex;
                align-items: center;
                justify-content: center;
                background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
                border: 1px solid #f87171;
                color: #dc2626;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
                overflow: hidden;
                box-shadow: 0 2px 8px rgba(248, 113, 113, 0.15);
            }

            .clear-filter-btn:hover {
                background: linear-gradient(135deg, #fecaca 0%, #f87171 100%);
                border-color: #dc2626;
                color: #fff;
                transform: translateY(-1px);
                box-shadow: 0 4px 16px rgba(248, 113, 113, 0.3);
            }

            .clear-filter-btn:active {
                transform: translateY(0);
                box-shadow: 0 2px 4px rgba(248, 113, 113, 0.2);
            }

            .clear-filter-btn i {
                font-size: 14px;
                transition: transform 0.2s ease;
            }

            .clear-filter-btn:hover i {
                transform: rotate(90deg);
            }

            /* Animation for show/hide */
            .clear-filter-btn.show {
                animation: slideInFade 0.4s cubic-bezier(0.4, 0, 0.2, 1);
                display: flex !important;
            }

            .clear-filter-btn.hide {
                animation: slideOutFade 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                animation-fill-mode: forwards;
            }

            @keyframes slideInFade {
                0% {
                    opacity: 0;
                    transform: translateX(10px) scale(0.9);
                }
                100% {
                    opacity: 1;
                    transform: translateX(0) scale(1);
                }
            }

            @keyframes slideOutFade {
                0% {
                    opacity: 1;
                    transform: translateX(0) scale(1);
                }
                100% {
                    opacity: 0;
                    transform: translateX(10px) scale(0.9);
                    display: none;
                }
            }

            /* Enhanced filter button styling */
            .filter-btn {
                position: relative;
                overflow: hidden;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            }

            .filter-btn:hover {
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            }

            .filter-btn.filtering {
                background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
                border-color: #1d4ed8;
                color: white;
            }

            .filter-btn.filtering i {
                animation: spin 1s linear infinite;
            }

            @keyframes spin {
                from {
                    transform: rotate(0deg);
                }
                to {
                    transform: rotate(360deg);
                }
            }

            /* ========== MODAL DETAIL SECTIONS ========== */
            .task-section {
                background: #f8fafc;
                border-radius: 12px;
                padding: 16px;
                border-left: 4px solid #0dcaf0;
            }

            .task-section .section-title {
                font-size: 1.1rem;
                font-weight: 700;
                margin-bottom: 16px;
                color: #1e293b;
            }

            /* Badge trạng thái duyệt */
            .badge-duyet {
                padding: 8px 14px;
                border-radius: 20px;
                font-weight: 600;
                font-size: 0.85rem;
            }

            .badge-chua-duyet {
                background: linear-gradient(135deg, #fbbf24, #f59e0b);
                color: #78350f;
            }

            .badge-da-duyet {
                background: linear-gradient(135deg, #22c55e, #16a34a);
                color: white;
            }

            .badge-tu-choi {
                background: linear-gradient(135deg, #ef4444, #dc2626);
                color: white;
            }

            /* Responsive adjustments */
            @media (max-width: 768px) {
                .filter-actions {
                    flex-direction: column;
                    gap: 8px;
                }

                .clear-filter-btn {
                    width: 100%;
                    min-width: auto;
                }
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

                                <!-- Nút thêm từ Excel -->
                                <!--                                <button class="btn btn-success rounded-pill px-3" data-bs-toggle="modal"
                                                                        data-bs-target="#modalExcel">
                                                                    <i class="fa-solid fa-file-excel"></i> Thêm việc từ Excel
                                                                </button>-->
                                <!-- Nút tạo công việc -->
                                <button class="btn btn-primary rounded-pill px-3" data-bs-toggle="modal"
                                        data-bs-target="#modalTask">
                                    <i class="fa-solid fa-plus"></i> Tạo công việc
                                </button>
                                <!-- Nút quay lại -->
                                <a href="./dsDuan" class="btn btn-secondary rounded-pill px-3">
                                    <i class="fa-solid fa-arrow-left"></i> Quay lại dự án
                                </a>
                            </div>
                        </div>
                        <div class="row mb-2 g-2" id="phongban">
                            <div class="col-md-3">
                                <input type="text" name="keyword" class="form-control" placeholder="Tìm kiếm tên công việc...">
                            </div>
                            <% 
                                String vaiTro = (String) session.getAttribute("vaiTro");
                                String selectedTrangThai = (String) request.getAttribute("selectedTrangThai");
                            %>
                            <div class="col-md-3">
                                <select class="form-select" name="ten_phong_ban" id="phongSelect"
                                        <%= !"Admin".equalsIgnoreCase(vaiTro) ? "disabled" : "" %>>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <select class="form-select" name="trangThai">
                                    <option value="" <%= (selectedTrangThai == null || selectedTrangThai.isEmpty()) ? "selected" : "" %>>Tất cả trạng thái</option>
                                    <option value="Chưa bắt đầu" <%= "Chưa bắt đầu".equals(selectedTrangThai) ? "selected" : "" %>>Chưa bắt đầu</option>
                                    <option value="Đang thực hiện" <%= "Đang thực hiện".equals(selectedTrangThai) ? "selected" : "" %>>Đang thực hiện</option>
                                    <option value="Đã hoàn thành" <%= "Đã hoàn thành".equals(selectedTrangThai) ? "selected" : "" %>>Đã hoàn thành</option>
                                    <option value="Trễ hạn" <%= "Trễ hạn".equals(selectedTrangThai) ? "selected" : "" %>>Trễ hạn</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <div class="filter-actions d-flex align-items-center gap-2">
                                    <button class="btn btn-outline-secondary flex-grow-1 rounded-pill filter-btn" id="btnFilter">
                                        <i class="fa-solid fa-filter me-1"></i> Lọc
                                    </button>
                                    <button class="btn btn-outline-danger rounded-pill clear-filter-btn" id="btnClearFilter" 
                                            style="display: none;" title="Hủy bộ lọc">
                                        <i class="fa-solid fa-times"></i>
                                    </button>
                                </div>
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
                                        
                                        // Trạng thái duyệt
                                        String trangThaiDuyet = task.get("trang_thai_duyet") != null ? task.get("trang_thai_duyet").toString() : "Chưa duyệt";
                                        String duyetBadgeClass = "badge-chua-duyet";
                                        if ("Đã duyệt".equals(trangThaiDuyet)) duyetBadgeClass = "badge-da-duyet";
                                        else if ("Từ chối".equals(trangThaiDuyet)) duyetBadgeClass = "badge-tu-choi";
                                    %>
                                    <div class="kanban-task <%= hasReminder ? "task--alert" : "" %>" data-task-id="<%= task.get("id") %>">
                                        <div class="task-content" 
                                             data-bs-toggle="modal" 
                                             data-bs-target="#modalTaskDetail"
                                             data-id="<%= task.get("id") %>"
                                             data-ten="<%= task.get("ten_cong_viec") %>"
                                             data-mo-ta="<%= task.get("mo_ta") %>"
                                             data-ngay-bat-dau="<%= task.get("ngay_bat_dau") %>"
                                             data-han="<%= task.get("han_hoan_thanh") %>"
                                             data-ngay-gia-han="<%= task.get("ngay_gia_han") %>"
                                             data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
                                             data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
                                             data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_ten") %>"
                                             data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
                                             data-trang-thai="<%= task.get("trang_thai") %>"
                                             data-trang-thai-duyet="<%= trangThaiDuyet %>"
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
                                            <span class="badge <%= duyetBadgeClass %> ms-1"><%= trangThaiDuyet %></span>
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
                                                <th class="sortable" data-sort="ngay_bat_dau">Ngày bắt đầu</th>
                                                <th class="sortable" data-sort="han_hoan_thanh">Hạn hoàn thành</th>
                                                <th class="sortable" data-sort="muc_do_uu_tien">Ưu tiên</th>
                                                <th class="sortable" data-sort="trang_thai">Trạng thái</th>
                                                <th class="sortable" data-sort="trang_thai_duyet">Trạng thái duyệt</th>
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
                                                
                                                // Trạng thái duyệt
                                                String trangThaiDuyet = task.get("trang_thai_duyet") != null ? task.get("trang_thai_duyet").toString() : "Chưa duyệt";
                                                String duyetBadgeClass = "badge-chua-duyet";
                                                if ("Đã duyệt".equals(trangThaiDuyet)) duyetBadgeClass = "badge-da-duyet";
                                                else if ("Từ chối".equals(trangThaiDuyet)) duyetBadgeClass = "badge-tu-choi";
                                                
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
                                                data-ngay-bat-dau="<%= task.get("ngay_bat_dau") %>"
                                                data-han="<%= task.get("han_hoan_thanh") %>"
                                                data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
                                                data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
                                                data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_ten") %>"
                                                data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
                                                data-trang-thai="<%= task.get("trang_thai") %>"
                                                data-trang-thai-duyet="<%= trangThaiDuyet %>"
                                                data-tai_lieu_cv="<%= task.get("tai_lieu_cv") %>"
                                                data-file_tai_lieu="<%= task.get("file_tai_lieu") %>">
                                                <td class="task-name"><%= task.get("ten_cong_viec") %></td>
                                                <td><%= task.get("nguoi_giao_id") %></td>
                                                <td><%= task.get("nguoi_nhan_ten") %></td>
                                                <td><%= task.get("phong_ban_id") %></td>
                                                <td><%= task.get("ngay_bat_dau") %></td>
                                                <td><%= task.get("han_hoan_thanh") %></td>
                                                <td><span class="badge <%= priorityClass %>"><%= task.get("muc_do_uu_tien") %></span></td>
                                                <td>
                                                    <span class="badge <%= statusClass %>"><%= task.get("trang_thai") %></span>
                                                </td>
                                                <td>
                                                    <span class="badge <%= duyetBadgeClass %>"><%= trangThaiDuyet %></span>
                                                </td>
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
                                         data-ngay-bat-dau="<%= task.get("ngay_bat_dau") %>"
                                         data-han="<%= task.get("han_hoan_thanh") %>"
                                         data-ngay-gia-han="<%= task.get("ngay_gia_han") %>"
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
                                         data-ngay-bat-dau="<%= task.get("ngay_bat_dau") %>"
                                         data-han="<%= task.get("han_hoan_thanh") %>"
                                         data-ngay-gia-han="<%= task.get("ngay_gia_han") %>"
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
                                            <label class="form-label"><b>Ngày bắt đầu</b></label>
                                            <input type="date" class="form-control" name="ngay_bat_dau">
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
                        <!-- Modal chi tiết task - Gộp tất cả thành 1 modal tổng -->
                        <div class="modal fade" id="modalTaskDetail" tabindex="-1">
                            <div class="modal-dialog modal-xl">
                                <div class="modal-content">
                                    <div class="modal-header bg-gradient" style="background: linear-gradient(135deg, #e0f2fe, #c7d2fe);">
                                        <h5 class="modal-title text-dark">
                                            <i class="fa-solid fa-info-circle text-primary"></i> Chi tiết công việc
                                        </h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body" style="max-height: 80vh; overflow-y: auto;">
                                        <!-- PHẦN 1: THÔNG TIN CÔNG VIỆC -->
                                        <div class="task-section mb-4">
                                            <h6 class="section-title">
                                                <i class="fa-solid fa-info-circle text-primary"></i> Thông tin công việc
                                            </h6>
                                            <form id="formTaskDetail" enctype="multipart/form-data">
                                                <input type="hidden" name="task_id" id="taskId">
                                                <div class="row">
                                                    <div class="col-md-6 mb-2">
                                                        <label class="form-label"><b>Tên công việc</b></label>
                                                        <input type="text" class="form-control" name="ten_cong_viec">
                                                    </div>
                                                    <div class="col-md-6 mb-2">
                                                        <label class="form-label"><b>Mức độ ưu tiên</b></label>
                                                        <select class="form-select" name="muc_do_uu_tien">
                                                            <option>Cao</option>
                                                            <option>Trung bình</option>
                                                            <option>Thấp</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="mb-2">
                                                    <label class="form-label"><b>Mô tả</b></label>
                                                    <textarea class="form-control" rows="3" name="mo_ta"></textarea>
                                                </div>
                                                <div class="row">
                                                    <div class="col-md-4 mb-2">
                                                        <label class="form-label"><b>Ngày bắt đầu</b></label>
                                                        <input type="date" class="form-control" name="ngay_bat_dau">
                                                    </div>
                                                    <div class="col-md-4 mb-2">
                                                        <label class="form-label"><b>Hạn hoàn thành</b></label>
                                                        <input type="date" class="form-control" name="han_hoan_thanh" id="hanHoanThanh">
                                                        <!-- Dòng hiển thị thông tin gia hạn -->
                                                        <small id="giaHanInfo" class="text-danger mt-1 d-block"></small>
                                                    </div>
                                                    <div class="col-md-4 mb-2">
                                                        <label class="form-label"><b>Trạng thái</b></label>
                                                        <select class="form-select" name="trang_thai">
                                                            <option>Chưa bắt đầu</option>
                                                            <option>Đang thực hiện</option>
                                                            <option>Đã hoàn thành</option>
                                                            <option>Trễ hạn</option>
                                                        </select>
                                                    </div>
                                                </div>

                                                <!-- Phần gia hạn công việc (hiển thị khi quá hạn) -->
                                                <div id="extensionSection" class="alert alert-warning mb-2" style="display: none;">
                                                    <div class="d-flex justify-content-between align-items-center">
                                                        <div>
                                                            <i class="fa-solid fa-exclamation-triangle"></i>
                                                            <strong>Công việc đã quá hạn!</strong>
                                                        </div>
                                                        <button type="button" class="btn btn-sm btn-warning" id="btnGiaHan">
                                                            <i class="fa-solid fa-clock"></i> Gia hạn công việc
                                                        </button>
                                                    </div>
                                                    <div id="giaHanForm" style="display: none;" class="mt-3">
                                                        <label class="form-label"><b>Ngày gia hạn mới</b></label>
                                                        <input type="date" class="form-control mb-2" id="ngayGiaHan">
                                                        <button type="button" class="btn btn-sm btn-success" id="btnXacNhanGiaHan">
                                                            <i class="fa-solid fa-check"></i> Xác nhận gia hạn
                                                        </button>
                                                    </div>
                                                </div>

                                                <div class="row">
                                                    <div class="col-md-4 mb-2">
                                                        <label class="form-label"><b>Người giao</b></label>
                                                        <select class="form-select" name="ten_nguoi_giao"></select>
                                                    </div>
                                                    <div class="col-md-4 mb-2">
                                                        <label class="form-label"><b>Phòng ban</b></label>
                                                        <select class="form-select" name="ten_phong_ban"></select>
                                                    </div>
                                                    <div class="col-md-4 mb-2">
                                                        <label class="form-label"><b>Trạng thái duyệt</b></label>
                                                        <input type="text" class="form-control" name="trang_thai_duyet" id="trangThaiDuyet" readonly>
                                                    </div>
                                                </div>

                                                <div class="mb-2">
                                                    <label class="form-label"><b>Người nhận</b></label>
                                                    <button type="button" class="btn btn-outline-primary btn-sm" id="btnOpenNguoiNhanDetail">
                                                        <i class="fa-solid fa-user-plus"></i> Thêm người nhận
                                                    </button>
                                                    <div id="danhSachNguoiNhan" class="d-flex flex-wrap gap-2 mt-2">
                                                        <!-- Tag tên người nhận sẽ hiển thị ở đây -->
                                                    </div>
                                                    <input type="hidden" name="ten_nguoi_nhan" id="nguoiNhanHidden">
                                                </div>

                                                <div class="mb-2">
                                                    <label class="form-label"><b>Tài liệu công việc (Link Driver)</b></label>
                                                    <input type="text" class="form-control" name="tai_lieu_cv">
                                                </div>
                                                <div class="mb-2">
                                                    <label class="form-label"><b>File công việc</b></label>
                                                    <input class="form-control" type="file" name="files" id="taskFiles2" multiple>
                                                    <div id="taskFileList2" class="form-text text-muted small mt-1"></div>
                                                </div>
                                            </form>
                                        </div>

                                        <hr>

                                        <!-- PHẦN 2: TIẾN ĐỘ -->
                                        <div class="task-section mb-4">
                                            <h6 class="section-title">
                                                <i class="fa-solid fa-chart-line text-success"></i> Tiến độ công việc
                                            </h6>
                                            <b>Tiến độ:</b>
                                            <div class="progress my-2" style="height: 25px;">
                                                <div class="progress-bar bg-success" style="width: 0%" id="taskProgressBar"></div>
                                            </div>
                                            <button class="btn btn-outline-primary btn-sm mb-2" id="btnAddProcessStep">
                                                <i class="fa-solid fa-plus"></i> Thêm quy trình
                                            </button>
                                            <ul id="processStepList" class="list-group"></ul>
                                        </div>

                                        <hr>

                                        <!-- PHẦN 3: LỊCH SỬ -->
                                        <div class="task-section mb-4">
                                            <h6 class="section-title">
                                                <i class="fa-solid fa-clock-rotate-left text-info"></i> Lịch sử công việc
                                            </h6>
                                            <div class="history-timeline" id="taskHistoryTimeline" style="max-height: 300px;">
                                                <div class="history-empty">
                                                    <i class="fa-solid fa-clock-rotate-left"></i>
                                                    <p>Đang tải lịch sử công việc...</p>
                                                </div>
                                            </div>
                                        </div>

                                        <hr>

                                        <!-- PHẦN 4: ĐÁNH GIÁ -->
                                        <div class="task-section mb-4">
                                            <h6 class="section-title">
                                                <i class="fa-solid fa-star text-warning"></i> Đánh giá công việc
                                            </h6>
                                            <form id="taskReviewForm" class="mb-3">
                                                <input type="hidden" id="taskReviewId" name="task_id" value="">
                                                <div class="row">
                                                    <div class="col-md-6 mb-2">
                                                        <label class="form-label">Người đánh giá:</label>
                                                        <select class="form-select" name="ten_nguoi_danh_gia"></select>
                                                    </div>
                                                    <div class="col-md-12 mb-2">
                                                        <label class="form-label">Nhận xét:</label>
                                                        <textarea class="form-control" id="reviewComment" rows="2" placeholder="Nhập nhận xét..."></textarea>
                                                    </div>
                                                </div>
                                                <button type="button" class="btn btn-success btn-sm" id="btnAddReview">
                                                    <i class="fa-solid fa-plus"></i> Thêm đánh giá
                                                </button>
                                            </form>
                                            <ul id="taskReviewList" class="list-group"></ul>
                                        </div>
                                    </div>

                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-warning" id="btnXetDuyet">
                                            <i class="fa-solid fa-check-circle"></i> Xét duyệt công việc
                                        </button>
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                        <button type="button" class="btn btn-primary" id="btnSaveTask">
                                            <i class="fa-solid fa-save"></i> Lưu thay đổi
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Modal Xét duyệt công việc -->
                        <div class="modal fade" id="modalXetDuyet" tabindex="-1">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title"><i class="fa-solid fa-gavel"></i> Xét duyệt công việc</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <input type="hidden" id="xetDuyetTaskId">
                                        <div class="mb-3">
                                            <label class="form-label"><b>Quyết định</b></label>
                                            <select class="form-select" id="quyetDinhDuyet">
                                                <option value="Đã duyệt">✅ Duyệt</option>
                                                <option value="Từ chối">❌ Từ chối</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label"><b>Lý do / Ghi chú</b></label>
                                            <textarea class="form-control" id="lyDoXetDuyet" rows="4" placeholder="Nhập lý do duyệt hoặc từ chối..."></textarea>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                        <button type="button" class="btn btn-success" id="btnXacNhanXetDuyet">
                                            <i class="fa-solid fa-check"></i> Xác nhận
                                        </button>
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
        <script src="<%= request.getContextPath() %>/scripts/project_task.js?v=<%= System.currentTimeMillis() %>"></script>
        <script src="<%= request.getContextPath() %>/scripts/task-approval.js?v=<%= System.currentTimeMillis() %>"></script>
        <%--FULLCALENDAR INITIALIZATION--%>
        <script>

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
                                                                    start: '<%= task.get("ngay_bat_dau") %>',
                                                                    end: '<%= task.get("han_hoan_thanh") %>',
                                                                    className: '<%= eventClass %>',
                                                                    extendedProps: {
                                                                        nguoiGiao: '<%= task.get("nguoi_giao_id") %>',
                                                                        nguoiNhan: '<%= task.get("nguoi_nhan_ten") %>',
                                                                        phongBan: '<%= task.get("phong_ban_id") %>',
                                                                        uuTien: '<%= task.get("muc_do_uu_tien") %>',
                                                                        trangThai: '<%= task.get("trang_thai") %>',
                                                                        trangThaiDuyet: '<%= task.get("trang_thai_duyet") != null ? task.get("trang_thai_duyet").toString() : "" %>',
                                                                        lyDoDuyet: '<%= task.get("ly_do_duyet") != null ? task.get("ly_do_duyet").toString().replace("'", "\\'") : "" %>',
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
                                                                        const event = info.event;
                                                                        const props = event.extendedProps;

                                                                        // 🔹 Tạo button tạm để bootstrap hiểu được trigger modal
                                                                        const tempBtn = document.createElement('button');
                                                                        tempBtn.type = 'button';
                                                                        tempBtn.dataset.bsToggle = 'modal';
                                                                        tempBtn.dataset.bsTarget = '#modalTaskDetail';

                                                                        // Gắn data attributes cho modal đọc
                                                                        tempBtn.setAttribute('data-id', event.id || '');
                                                                        tempBtn.setAttribute('data-ten', event.title || '');
                                                                        tempBtn.setAttribute('data-mo-ta', props.moTa || '');
                                                                        tempBtn.setAttribute('data-ngay-bat-dau', event.startStr || '');
                                                                        tempBtn.setAttribute('data-han', event.endStr || '');
                                                                        tempBtn.setAttribute('data-uu-tien', props.uuTien || '');
                                                                        tempBtn.setAttribute('data-ten_nguoi_giao', props.nguoiGiao || '');
                                                                        tempBtn.setAttribute('data-ten_nguoi_nhan', props.nguoiNhan || '');
                                                                        tempBtn.setAttribute('data-ten_phong_ban', props.phongBan || '');
                                                                        tempBtn.setAttribute('data-trang-thai', props.trangThai || '');
                                                                        tempBtn.setAttribute('data-tai_lieu_cv', props.taiLieu || '');
                                                                        tempBtn.setAttribute('data-file_tai_lieu', props.fileTaiLieu || '');
                                                                        tempBtn.setAttribute('data-trang-thai-duyet', props.trangThaiDuyet || 'Chưa duyệt');
                                                                        tempBtn.setAttribute('data-ly-do-duyet', props.lyDoDuyet || '');
                                                                        tempBtn.setAttribute('data-ngay-gia-han', props.ngayGiaHan || '');

                                                                        // 🔹 Phải gắn vào DOM thì bootstrap mới bắt được sự kiện click
                                                                        document.body.appendChild(tempBtn);

                                                                        // 🔹 Trigger click (Bootstrap tự mở modal và phát 'show.bs.modal')
                                                                        tempBtn.click();


                                                                        // 🔹 Dọn dẹp button tạm sau 200ms
                                                                        setTimeout(() => tempBtn.remove(), 200);

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
        </script>
    </body>
</html>
