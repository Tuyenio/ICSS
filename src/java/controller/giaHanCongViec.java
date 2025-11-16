

package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class giaHanCongViec extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        try (PrintWriter out = response.getWriter()) {
            int taskId = Integer.parseInt(request.getParameter("taskId"));
            String ngayGiaHan = request.getParameter("ngayGiaHan");

            // ✅ Lấy userId từ session
            HttpSession session = request.getSession(false);
            int userId = 0;
            if (session != null && session.getAttribute("userId") != null) {
                try {
                    userId = Integer.parseInt(session.getAttribute("userId").toString());
                } catch (Exception e) {
                    // Nếu có lỗi thì giữ mặc định = 0
                }
            }

            KNCSDL kn = new KNCSDL();
            result = kn.giaHanCongViec(taskId, ngayGiaHan, userId);

            // ✅ Trả JSON thủ công
            StringBuilder json = new StringBuilder("{");
            json.append("\"success\":").append(result.get("success")).append(",");
            json.append("\"message\":\"").append(result.get("message")).append("\"");

            if (result.containsKey("ngayGiaHan")) {
                json.append(",\"ngayGiaHan\":\"").append(result.get("ngayGiaHan")).append("\"");
            }

            json.append("}");
            out.print(json.toString());

        } catch (Exception ex) {
            Logger.getLogger(giaHanCongViec.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().print("{\"success\":false,\"message\":\"Lỗi xử lý yêu cầu: "
                    + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String text) {
        return text == null ? "" : text.replace("\"", "\\\"").replace("\n", "");
    }
}
