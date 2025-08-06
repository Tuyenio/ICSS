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

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String phong = request.getParameter("phong_ban");
        String trangThai = request.getParameter("trang_thai");

        String phongban = null; // Tên phòng ban, truyền vào locCongViec

        try {
            if (phong != null && !phong.trim().isEmpty()) {
                int idphong = Integer.parseInt(phong);
                KNCSDL db = new KNCSDL();
                phongban = db.getPhongNameById(idphong); // Chỉ khi có ID hợp lệ mới gọi
            }

            KNCSDL db = new KNCSDL();
            List<Map<String, Object>> taskList = db.locCongViec(keyword, phongban, trangThai);
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
