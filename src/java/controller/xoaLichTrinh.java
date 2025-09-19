package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;

public class xoaLichTrinh extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            int id = Integer.parseInt(req.getParameter("id"));
            KNCSDL kn = new KNCSDL();
            boolean success = kn.xoaLichTrinh(id);

            if (success) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Xóa lịch trình thất bại\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().print("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }
}
