package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.Connection;

public class xoaDuan extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String idRaw = request.getParameter("id");

        try {
            int id = Integer.parseInt(idRaw);

            KNCSDL kn = new KNCSDL();

            boolean success = kn.deleteProject(id);

            try (PrintWriter out = response.getWriter()) {
                if (success) {
                    out.print("{\"success\":true}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Xóa thất bại\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"success\":false, \"message\":\"Lỗi khi xóa dự án: " + e.getMessage() + "\"}");
            }
        }
    }
}
