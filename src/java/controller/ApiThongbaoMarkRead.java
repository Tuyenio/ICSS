package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

public class ApiThongbaoMarkRead extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        Integer userId = null;
        try {
            HttpSession session = request.getSession(false);
            if (session != null) {
                String idStr = (String) session.getAttribute("userId");
                if (idStr != null && !idStr.trim().isEmpty()) {
                    userId = Integer.parseInt(idStr.trim());
                }
            }
        } catch (Exception ignored) {}

        // Lấy id thông báo
        int tbId = -1;
        try { tbId = Integer.parseInt(request.getParameter("id")); } catch (Exception ignored) {}

        if (tbId <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("INVALID_ID");
            return;
        }

        try {
            KNCSDL db = new KNCSDL();
            int n = db.markThongBaoDaDoc(tbId, userId);
            if (n > 0) {
                out.print("OK");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("NOT_FOUND");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("ERROR");
        }
    }
}
