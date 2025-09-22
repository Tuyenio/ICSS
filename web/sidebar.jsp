<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String uri = request.getRequestURI(); // ví dụ: /ICSS/dsnhanvien
    String currentPath = uri.substring(uri.lastIndexOf("/") + 1); // ví dụ: dsnhanvien
%>

<style>
    /* PREMIUM SIDEBAR DESIGN */
    .sidebar {
        min-height: 100vh;
        background: linear-gradient(145deg, 
            rgba(15, 23, 42, 0.95) 0%,
            rgba(30, 41, 59, 0.95) 35%, 
            rgba(51, 65, 85, 0.95) 70%,
            rgba(30, 41, 59, 0.95) 100%
        );
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border-right: 1px solid rgba(255, 255, 255, 0.1);
        color: #fff;
        width: 260px;
        transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
        box-shadow: 
            0 25px 50px rgba(0, 0, 0, 0.25),
            inset 0 1px 0 rgba(255, 255, 255, 0.1),
            0 0 0 1px rgba(255, 255, 255, 0.05);
        position: fixed;
        top: 0;
        left: 0;
        bottom: 0;
        z-index: 1000;
        overflow: hidden;
    }

    .sidebar::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: url('data:image/svg+xml,<svg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd"><g fill="%23ffffff" fill-opacity="0.02"><circle cx="30" cy="30" r="1"/></g></svg>');
        pointer-events: none;
    }

    .sidebar:hover {
        background: linear-gradient(145deg, 
            rgba(30, 41, 59, 0.98) 0%,
            rgba(51, 65, 85, 0.98) 35%, 
            rgba(71, 85, 105, 0.98) 70%,
            rgba(51, 65, 85, 0.98) 100%
        );
        box-shadow: 
            0 30px 60px rgba(0, 0, 0, 0.3),
            inset 0 1px 0 rgba(255, 255, 255, 0.15),
            0 0 0 1px rgba(255, 255, 255, 0.1);
    }

    .sidebar .sidebar-title {
        font-size: 1.8rem;
        font-weight: 800;
        letter-spacing: 2px;
        background: linear-gradient(135deg, #60a5fa, #34d399, #a855f7);
        -webkit-background-clip: text;
        background-clip: text;
        -webkit-text-fill-color: transparent;
        padding: 24px 0;
        background-color: rgba(15, 23, 42, 0.6);
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        transition: all 0.4s ease;
        cursor: pointer;
        position: relative;
        text-shadow: 0 0 30px rgba(96, 165, 250, 0.3);
    }

    .sidebar .sidebar-title::before {
        content: '';
        position: absolute;
        bottom: 0;
        left: 50%;
        width: 0;
        height: 2px;
        background: linear-gradient(90deg, #60a5fa, #34d399);
        transition: all 0.4s ease;
        transform: translateX(-50%);
    }

    .sidebar .sidebar-title:hover::before {
        width: 80px;
    }

    .sidebar .sidebar-title:hover {
        text-shadow: 
            0 0 20px rgba(96, 165, 250, 0.6),
            0 0 40px rgba(52, 211, 153, 0.4),
            0 0 60px rgba(168, 85, 247, 0.3);
    }

    .sidebar-nav {
        padding: 16px 0;
        margin: 0;
        list-style: none;
    }

    .sidebar-nav li {
        margin: 8px 0;
        position: relative;
    }

    .sidebar-nav a {
        color: rgba(226, 232, 240, 0.9);
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 16px 24px;
        border-radius: 16px;
        font-size: 1.05rem;
        font-weight: 600;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        position: relative;
        overflow: hidden;
        margin: 0 12px;
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
    }

    .sidebar-nav a::before {
        content: "";
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, 
            rgba(96, 165, 250, 0.3) 0%,
            rgba(52, 211, 153, 0.2) 50%,
            rgba(168, 85, 247, 0.3) 100%
        );
        transition: left 0.6s cubic-bezier(0.23, 1, 0.320, 1);
        border-radius: 16px;
    }

    .sidebar-nav a::after {
        content: "";
        position: absolute;
        top: 50%;
        right: 16px;
        width: 4px;
        height: 0;
        background: linear-gradient(to bottom, #60a5fa, #34d399);
        transition: height 0.3s ease;
        transform: translateY(-50%);
        border-radius: 2px;
    }

    .sidebar-nav a:hover::before {
        left: 0;
    }

    .sidebar-nav a:hover::after {
        height: 20px;
    }

    .sidebar-nav a:hover {
        background: linear-gradient(135deg, 
            rgba(255, 255, 255, 0.15) 0%,
            rgba(255, 255, 255, 0.05) 100%
        );
        color: #ffffff;
        transform: translateX(8px) scale(1.02);
        box-shadow: 
            0 10px 25px rgba(0, 0, 0, 0.15),
            inset 0 1px 0 rgba(255, 255, 255, 0.2);
    }

    .sidebar-nav a.active {
        background: linear-gradient(135deg, 
            rgba(96, 165, 250, 0.3) 0%,
            rgba(52, 211, 153, 0.2) 50%,
            rgba(168, 85, 247, 0.3) 100%
        );
        color: #ffffff;
        font-weight: 700;
        box-shadow: 
            0 15px 35px rgba(96, 165, 250, 0.2),
            inset 0 1px 0 rgba(255, 255, 255, 0.3);
        border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .sidebar-nav a.active::after {
        height: 24px;
        background: linear-gradient(to bottom, #ffffff, #60a5fa);
    }

    .sidebar-nav a .fa-solid {
        width: 28px;
        text-align: center;
        font-size: 1.3rem;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        filter: drop-shadow(0 0 5px rgba(255, 255, 255, 0.1));
    }

    .sidebar-nav a:hover .fa-solid {
        transform: rotate(5deg) scale(1.15);
        filter: drop-shadow(0 0 15px rgba(96, 165, 250, 0.4));
    }

    .sidebar-nav a.active .fa-solid {
        transform: scale(1.1);
        filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.3));
    }

    /* PREMIUM HOVER EFFECTS */
    .sidebar-nav li:hover {
        filter: brightness(1.1);
    }

    /* RESPONSIVE DESIGN */
    @media (max-width: 1200px) {
        .sidebar {
            width: 240px;
        }
    }

    @media (max-width: 992px) {
        .sidebar {
            width: 76px;
            transition: width 0.3s ease;
        }

        .sidebar:hover {
            width: 260px;
        }

        .sidebar .sidebar-title {
            font-size: 1.4rem;
            padding: 18px 0;
            overflow: hidden;
            white-space: nowrap;
        }

        .sidebar-nav a span {
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .sidebar:hover .sidebar-nav a span {
            opacity: 1;
        }

        .sidebar-nav a {
            justify-content: flex-start;
            padding: 16px 12px;
            margin: 0 8px;
        }

        .sidebar:hover .sidebar-nav a {
            padding: 16px 24px;
            margin: 0 12px;
        }
    }

    @media (max-width: 576px) {
        .sidebar {
            width: 60px;
        }

        .sidebar:hover {
            width: 240px;
        }
    }
</style>

<nav class="sidebar p-0">
    <div class="sidebar-title text-center py-4 border-bottom border-secondary" style="cursor:pointer;"
         onclick="location.href = 'index.jsp'">
        <i class="fa-solid fa-cube me-2"></i>ICSS
    </div>

    <ul class="sidebar-nav mt-3">
        <li><a href="index.jsp" class="<%= currentPath.equals("index.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-chart-line"></i><span>Dashboard</span></a></li>

        <li><a href="dsnhanvien" class="<%= currentPath.equals("employee.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-users-gear"></i><span>Nhân sự</span></a></li>

        <li><a href="dsDuan" class="<%= currentPath.equals("project.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-diagram-project"></i><span>Dự án</span></a></li>

        <li><a href="dsCongviec" class="<%= currentPath.equals("task.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-list-check"></i><span>Công việc</span></a></li>

        <li><a href="dsPhongban" class="<%= currentPath.equals("department.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-building-user"></i><span>Phòng ban</span></a></li>

        <li><a href="dsChamCong" class="<%= currentPath.equals("attendance.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-calendar-check"></i><span>Chấm công</span></a></li>

        <li><a href="calendar.jsp" class="<%= currentPath.equals("calendar.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-calendar-days"></i><span>Lịch trình</span></a></li>

        <li><a href="svBaocao" class="<%= currentPath.equals("report.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-chart-column"></i><span>Báo cáo</span></a></li>
    </ul>
</nav>
