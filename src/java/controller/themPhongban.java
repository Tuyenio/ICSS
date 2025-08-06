package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class themPhongban extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        PrintWriter out = response.getWriter();

        try {
            String tenPhong = request.getParameter("ten_phong");
            String truongPhongIdStr = request.getParameter("truong_phong_id");
            
            Integer truongPhongId = null;
            if (truongPhongIdStr != null && !truongPhongIdStr.trim().isEmpty() && !truongPhongIdStr.equals("0")) {
                truongPhongId = Integer.parseInt(truongPhongIdStr);
            }

            KNCSDL kn = new KNCSDL();
            boolean success = kn.themPhongBan(tenPhong, truongPhongId);

            if (success) {
                out.print("{\"status\":\"success\", \"message\": \"Thêm phòng ban thành công!\"}");
            } else {
                out.print("{\"status\":\"error\", \"message\": \"Không thể thêm phòng ban!\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\", \"message\": \"" + e.getMessage() + "\"}");
        }
    }

    @Override
    public String getServletInfo() {
        return "Thêm phòng ban mới";
    }
}
