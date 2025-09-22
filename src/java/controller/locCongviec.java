package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

public class locCongviec extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String trangThai = request.getParameter("trang_thai");
        String projectIdStr = request.getParameter("projectId");
        Integer projectId = null;
        if (projectIdStr != null && !projectIdStr.trim().isEmpty()) {
            projectId = Integer.parseInt(projectIdStr);
        }

        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");

            KNCSDL db = new KNCSDL();
            String vaiTro = db.getVaiTroByEmail(email); // Lấy vai trò người dùng từ DB

            List<Map<String, Object>> taskList;

            if ("Admin".equalsIgnoreCase(vaiTro)) {
                String phong = request.getParameter("phong_ban");
                String phongban = null;

                if (phong != null && !phong.trim().isEmpty()) {
                    int idphong = Integer.parseInt(phong);
                    phongban = db.getPhongNameById(idphong);
                }

                taskList = db.locCongViec(keyword, phongban, trangThai, projectId);

                request.setAttribute("taskList", taskList);
                RequestDispatcher dispatcher = request.getRequestDispatcher("kanban-board.jsp");
                dispatcher.forward(request, response);

            } else if ("Quản lý".equalsIgnoreCase(vaiTro)) {
                taskList = db.locCongViecQL(keyword, trangThai, email, projectId);

                request.setAttribute("taskList", taskList);
                RequestDispatcher dispatcher = request.getRequestDispatcher("kanban-board.jsp");
                dispatcher.forward(request, response);

            } else {
                taskList = db.locCongViecNV(keyword, trangThai, email, projectId);

                request.setAttribute("taskList", taskList);
                RequestDispatcher dispatcher = request.getRequestDispatcher("kanban-board-nv.jsp");
                dispatcher.forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
        }
    }

    @Override
    public String getServletInfo() {
        return "Lọc công việc theo vai trò và trả HTML phù hợp";
    }
}
