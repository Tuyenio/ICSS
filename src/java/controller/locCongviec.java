package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class locCongviec extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String trangThai = request.getParameter("trang_thai");

        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");

            KNCSDL db = new KNCSDL();
            String vaiTro = db.getVaiTroByEmail(email); // Lấy vai trò người dùng từ DB

            List<Map<String, Object>> taskList;

            if ("Quản lý".equalsIgnoreCase(vaiTro)) {
                // Lọc theo phòng ban (của quản lý)
                String phong = request.getParameter("phong_ban");
                String phongban = null;

                if (phong != null && !phong.trim().isEmpty()) {
                    int idphong = Integer.parseInt(phong);
                    phongban = db.getPhongNameById(idphong);
                }

                taskList = db.locCongViec(keyword, phongban, trangThai);

            } else {
                // Nhân viên: lọc theo email người nhận
                taskList = db.locCongViecNV(keyword, trangThai, email);
            }

            request.setAttribute("taskList", taskList);

            // Render partial HTML Kanban
            RequestDispatcher dispatcher = request.getRequestDispatcher("kanban-board.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
        }
    }

    @Override
    public String getServletInfo() {
        return "Lọc nhân viên và trả HTML thay vì JSON";
    }
}
