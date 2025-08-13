package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

public class apiThongbao extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lọc thông báo theo người nhận từ session userId (giữ nguyên)
        Integer userId = null;
        try {
            Object uid = request.getSession().getAttribute("userId");
            if (uid != null) userId = Integer.parseInt(uid.toString());
        } catch (Exception ignored) {}

        // Phân trang đơn giản
        int page = 1;
        try {
            String p = request.getParameter("page");
            if (p != null && !p.trim().isEmpty()) page = Integer.parseInt(p.trim());
        } catch (Exception ignored) {}
        if (page < 1) page = 1;

        int size = DEFAULT_PAGE_SIZE;
        int offset = (page - 1) * size;

        try {
            KNCSDL db = new KNCSDL();
            List<Map<String, Object>> ds = db.getDanhSachThongBao(
                    (userId != null && userId > 0) ? userId : null,
                    size,
                    offset
            );
            request.setAttribute("dsThongBao", ds);
        } catch (Exception e) {
            request.setAttribute("dsThongBao", null);
            request.setAttribute("tbError", "Không tải được danh sách thông báo: " + e.getMessage());
        }

        // ---- Chọn view theo vai trò (dạng bạn yêu cầu) ----
        HttpSession session = request.getSession();
        String vaitro = (String) session.getAttribute("vaiTro");

        String view = "/notification.jsp"; // mặc định cho Quản lý/Admin
        if (vaitro != null) {
            String r = vaitro.trim();
            if (r.equalsIgnoreCase("Nhân viên") || r.equalsIgnoreCase("Nhan vien") || r.equalsIgnoreCase("NhanVien")) {
                view = "/user_notification.jsp";
            } else if (r.equalsIgnoreCase("Quản lý") || r.equalsIgnoreCase("Quan ly")
                       || r.equalsIgnoreCase("QuanLy") || r.equalsIgnoreCase("Manager")
                       || r.equalsIgnoreCase("Admin")) {
                view = "/notification.jsp";
            }
        }

        request.getRequestDispatcher(view).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "apiThongbao - load danh sách thông báo và forward theo vai trò (vaiTro từ session)";
    }
}
