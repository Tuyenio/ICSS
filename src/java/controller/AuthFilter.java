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
            "/asset.jsp",
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
            "/dsTaiSan",
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

        // ✅ Set UTF-8 encoding TRƯỚC KHI xử lý bất kỳ request nào
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

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
                // ❌ Kiểm tra cookies trước khi redirect login
                if (!restoreSessionFromCookie(req, res)) {
                    res.sendRedirect(req.getContextPath() + "/login.jsp");
                    return;
                }
                // ✅ Session restored from cookie
                session = req.getSession(false);
            }
            
            if (session != null && session.getAttribute("vaiTro") != null) {
                // ✅ Đã đăng nhập → chuyển theo vai trò
                String role = ((String) session.getAttribute("vaiTro")).toLowerCase();
                if (role.equals("admin") || role.equals("quản lý")) {
                    res.sendRedirect(req.getContextPath() + "/index.jsp");
                    return;
                } else {
                    res.sendRedirect(req.getContextPath() + "/userDashboard");
                    return;
                }
            } else {
                res.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
        }

        // ✅ Nếu chưa đăng nhập
        if (session == null || session.getAttribute("vaiTro") == null) {
            // 🔄 Kiểm tra cookies để phục hồi session
            if (!restoreSessionFromCookie(req, res)) {
                res.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
            // ✅ Session restored from cookie
            session = req.getSession(false);
            
            if (session == null || session.getAttribute("vaiTro") == null) {
                res.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
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

    /**
     * Phục hồi session từ cookie nếu có sẵn và hợp lệ
     */
    private boolean restoreSessionFromCookie(HttpServletRequest req, HttpServletResponse res) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null) {
            return false;
        }
        
        for (Cookie cookie : cookies) {
            if ("ICSS_USER".equals(cookie.getName())) {
                try {
                    String decrypted = CookieUtil.decrypt(cookie.getValue());
                    if (decrypted != null && decrypted.contains("|")) {
                        String[] parts = decrypted.split("\\|");
                        if (parts.length == 6) {
                            String id = parts[0];
                            String email = parts[1];
                            String hoten = parts[2];
                            String vaiTro = parts[3];
                            String chucVu = parts[4];
                            String avatar = parts[5];
                            
                            // ✅ Tạo session mới từ cookie data
                            HttpSession session = req.getSession(true);
                            session.setAttribute("userId", id);
                            session.setAttribute("userEmail", email);
                            session.setAttribute("userName", hoten);
                            session.setAttribute("vaiTro", vaiTro);
                            session.setAttribute("chucVu", chucVu);
                            session.setAttribute("avatar", avatar);
                            
                            // ⚠️ Tải quyền từ database nếu cần
                            try {
                                int userIdInt = Integer.parseInt(id);
                                KNCSDL db = new KNCSDL();
                                List<String> quyenList = db.getQuyenTheoNhanVien(userIdInt);
                                db.close();
                                
                                StringBuilder json = new StringBuilder("[");
                                for (int i = 0; i < quyenList.size(); i++) {
                                    json.append("\"").append(quyenList.get(i)).append("\"");
                                    if (i < quyenList.size() - 1) json.append(",");
                                }
                                json.append("]");
                                session.setAttribute("quyen", json.toString());
                            } catch (Exception e) {
                                System.err.println("Error loading permissions from cookie: " + e.getMessage());
                            }
                            
                            return true;
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Error restoring session from cookie: " + e.getMessage());
                }
            }
        }
        
        return false;
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void destroy() {
    }
}
