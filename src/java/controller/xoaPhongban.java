package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class xoaPhongban extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        PrintWriter out = response.getWriter();

        try {
            int id = Integer.parseInt(request.getParameter("id"));

            KNCSDL kn = new KNCSDL();
            boolean success = kn.xoaPhongBan(id);

            if (success) {
                out.print("{\"status\":\"success\", \"message\": \"Xóa phòng ban thành công!\"}");
            } else {
                out.print("{\"status\":\"error\", \"message\": \"Không thể xóa phòng ban! Vui lòng kiểm tra lại có nhân viên trong phòng ban không.\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\", \"message\": \"" + e.getMessage() + "\"}");
        }
    }

    @Override
    public String getServletInfo() {
        return "Xóa phòng ban";
    }
}
