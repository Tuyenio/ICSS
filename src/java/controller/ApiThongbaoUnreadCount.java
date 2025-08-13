package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

public class ApiThongbaoUnreadCount extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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

        try {
            KNCSDL db = new KNCSDL();
            int c = db.getSoThongBaoChuaDoc(userId);
            out.print(c); // chỉ in số
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("0");
        }
    }
}
