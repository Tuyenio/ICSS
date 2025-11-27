package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;


public class dsLichtrinh extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            HttpSession session = req.getSession();
            String role = (String) session.getAttribute("vaiTro");
            KNCSDL kn = new KNCSDL();
            List<Map<String, Object>> ds = kn.layTatCaLichTrinh();

            // Gửi dữ liệu sang JSP
            req.setAttribute("lichTrinh", ds);

            if ("Nhân viên".equalsIgnoreCase(role)) {
                // Nhân viên
                req.getRequestDispatcher("calendarnv.jsp").forward(req, resp);
            } else {
                // Quản lý + Admin → dùng trang chấm công chính
                req.getRequestDispatcher("calendar.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "Lỗi load lịch trình");
        }
    }
}