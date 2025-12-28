package controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final List<String> ADMIN_PAGES = Arrays.asList(
            "/index.jsp",
            "/attendance.jsp",
            "/calendar.jsp",
            "/department.jsp",
            "/notification.jsp",
            "/project.jsp",
            "/project_task.jsp",
            "/report.jsp",
            "/sidebar.jsp",
            "/header.jsp",
            "/delete-kanban-board.jsp",
            "/archived-kanban-board.jsp",
            "/admin_profile.jsp",
            "/admin_change_password.jsp",
            "/xoaLichTrinh",
            "/xoaCongviec",
            "/themPhongban",
            "dsCongviecDuan",
            "/locNhanvien",
            "/dsnhanvien",
            "dsCongviec",
            "dsNhomduan",
            "/dsPhongban",
            "/dsDuan",
            "/dsChamCong",
            "/xoaNhanvien",
            "/luuLichTrinh",
            "/svBaocao",
            "/suaPhongban",
            "/themNhanvien",
            "/xoaPhongban"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        HttpSession session = req.getSession(false);

        if (uri.startsWith(req.getContextPath() + "/api/")) {
            chain.doFilter(request, response);
            return;
        }

        // ✅ Bỏ qua kiểm tra login, file tĩnh
        boolean isLoginPage = uri.endsWith("login.jsp") || uri.contains("/Dangnhap") || uri.contains("/LoginServlet")|| uri.contains("/home");
        boolean isResource = uri.contains("/assets/") || uri.contains("/css/") || uri.contains("/js/") || uri.contains("/images/");
        boolean isStatic = uri.matches(".*(\\.css|\\.js|\\.png|\\.jpg|\\.jpeg|\\.gif|\\.ico|\\.json|\\.webmanifest|\\.svg|\\.mp4|\\.woff2?)$");

        if (isLoginPage || isResource || isStatic) {
            chain.doFilter(request, response);
            return;
        }

        // 🟡 Nếu truy cập root (ví dụ /ICSS/ không có gì sau)
        if (uri.equals(req.getContextPath() + "/") || uri.equals(req.getContextPath())) {
            if (session == null || session.getAttribute("vaiTro") == null) {
                // ❌ Chưa đăng nhập → về login.jsp
                res.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            } else {
                // ✅ Đã đăng nhập → chuyển theo vai trò
                String role = ((String) session.getAttribute("vaiTro")).toLowerCase();
                if (role.equals("admin") || role.equals("quản lý")) {
                    res.sendRedirect(req.getContextPath() + "/index.jsp");
                    return;
                } else {
                    res.sendRedirect(req.getContextPath() + "/userDashboard");
                    return;
                }
            }
        }

        // ✅ Nếu chưa đăng nhập
        if (session == null || session.getAttribute("vaiTro") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // ✅ Nếu đã đăng nhập
        String role = ((String) session.getAttribute("vaiTro")).toLowerCase();

        // ✅ Nếu là nhân viên, chặn truy cập vào các trang admin
        String cleanUri = uri.split("\\?")[0]; // Bỏ query string

        if (!"admin".equalsIgnoreCase(role) && !"quản lý".equalsIgnoreCase(role)) {
            for (String page : ADMIN_PAGES) {
                if (cleanUri.endsWith(page) || cleanUri.equals(req.getContextPath() + page)) {
                    res.sendRedirect(req.getContextPath() + "/404.jsp");
                    return;
                }
            }
        }
        chain.doFilter(request, response);
    }
}
