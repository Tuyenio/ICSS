package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class dsPhongban extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Map<String, Object>> danhSach = new ArrayList<>();

        try {
            KNCSDL kn = new KNCSDL();
            danhSach = kn.getAllPhongBan();

            // Gửi dữ liệu sang JSP
            request.setAttribute("danhSachPhongBan", danhSach);
            request.getRequestDispatcher("department.jsp").forward(request, response);

        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            response.getWriter().println("<h3 style='color:red'>❌ Lỗi: " + e.getMessage() + "</h3>");
        }
    }

    @Override
    public String getServletInfo() {
        return "Hiển thị danh sách phòng ban";
    }
}
