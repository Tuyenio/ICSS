<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String uri = request.getRequestURI(); // ví dụ: /ICSS/dsnhanvien
    String currentPath = uri.substring(uri.lastIndexOf("/") + 1); // ví dụ: dsnhanvien
%>

<style>
    /* sidebar.css */
    .sidebar {
        min-height: 100vh;
        background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
        color: #fff;
        width: 240px;
        transition: width 0.25s ease, background 0.3s ease;
        box-shadow: 4px 0 15px rgba(0, 0, 0, 0.25);
        position: fixed;
        top: 0;
        left: 0;
        bottom: 0;
        z-index: 100;
        overflow: hidden;
    }

    .sidebar:hover {
        background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
    }

    .sidebar .sidebar-title {
        font-size: 1.6rem;
        font-weight: bold;
        letter-spacing: 1px;
        color: #38bdf8;
        padding: 20px 0;
        background: rgba(15, 23, 42, 0.9);
        transition: color 0.3s;
        cursor: pointer;
    }

    .sidebar .sidebar-title:hover {
        color: #facc15;
    }

    .sidebar-nav {
        padding: 12px 0;
        margin: 0;
        list-style: none;
    }

    .sidebar-nav li {
        margin: 6px 0;
    }

    .sidebar-nav a {
        color: #e2e8f0;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 14px;
        padding: 12px 20px;
        border-radius: 12px;
        font-size: 1.05rem;
        font-weight: 500;
        transition: all 0.25s ease;
        position: relative;
        overflow: hidden;
    }

    .sidebar-nav a::before {
        content: "";
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, rgba(56,189,248,0.3), rgba(56,189,248,0));
        transition: left 0.4s ease;
    }

    .sidebar-nav a:hover::before {
        left: 0;
    }

    .sidebar-nav a:hover {
        background: #38bdf8;
        color: #0f172a;
        transform: translateX(4px);
    }

    .sidebar-nav a.active {
        background: #facc15;
        color: #0f172a;
        font-weight: 600;
    }

    .sidebar-nav a .fa-solid {
        width: 26px;
        text-align: center;
        font-size: 1.25rem;
        transition: transform 0.25s ease;
    }

    .sidebar-nav a:hover .fa-solid {
        transform: rotate(8deg) scale(1.1);
    }

    /* Responsive */
    @media (max-width: 992px) {
        .sidebar {
            width: 70px;
        }

        .sidebar .sidebar-title {
            font-size: 1.2rem;
            padding: 14px 0;
        }

        .sidebar-nav a span {
            display: none;
        }

        .sidebar-nav a {
            justify-content: center;
            padding: 14px 0;
        }
    }
</style>

<nav class="sidebar p-0">
    <div class="sidebar-title text-center py-4 border-bottom border-secondary" style="cursor:pointer;"
         onclick="location.href = 'userDashboard'">
        <i class="fa-solid fa-people-group me-2"></i>ICS
    </div>

    <ul class="sidebar-nav mt-3">
        <li><a href="userDashboard" class="<%= currentPath.equals("user_dashboard.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-chart-line"></i><span>Dashboard</span></a></li>

        <li><a href="dsDuannv" class="<%= currentPath.equals("projectnv.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-diagram-project"></i><span>Dự án</span></a></li>

        <li><a href="dsCongviecNV" class="<%= currentPath.equals("user_task.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-tasks"></i><span>Công việc</span></a></li>

        <li><a href="userChamCong" class="<%= currentPath.equals("user_attendance.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-calendar-check"></i><span>Chấm công</span></a></li>

        <li><a href="calendarnv.jsp" class="<%= currentPath.equals("calendarnv.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-calendar-days"></i><span>Lịch trình</span></a></li>

        <li><a href="userLuong" class="<%= currentPath.equals("user_salary.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-money-bill"></i><span>Lương & KPI</span></a></li>
    </ul>
</nav>
