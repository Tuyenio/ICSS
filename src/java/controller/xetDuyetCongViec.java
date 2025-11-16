/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
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

public class xetDuyetCongViec extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        Map<String, Object> result = new HashMap<>();

        try (PrintWriter out = response.getWriter()) {
            int taskId = Integer.parseInt(request.getParameter("taskId"));
            String quyetDinh = request.getParameter("quyetDinh");
            String lyDo = request.getParameter("lyDo");

            // ✅ Lấy userId từ session an toàn
            HttpSession session = request.getSession(false);
            int userId = 0;
            if (session != null && session.getAttribute("userId") != null) {
                try {
                    userId = Integer.parseInt(session.getAttribute("userId").toString());
                } catch (Exception e) {
                    // Nếu có lỗi, userId = 0
                }
            }

            KNCSDL kn = new KNCSDL();
            result = kn.xetDuyetCongViec(taskId, quyetDinh, lyDo, userId);

            // ✅ Trả JSON thủ công (không dùng Gson)
            StringBuilder json = new StringBuilder("{");
            json.append("\"success\":").append(result.get("success")).append(",");
            json.append("\"message\":\"").append(result.get("message")).append("\"");
            json.append("}");

            out.print(json.toString());
        } catch (Exception ex) {
            Logger.getLogger(xetDuyetCongViec.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().print("{\"success\":false,\"message\":\"Lỗi xử lý yêu cầu: "
                    + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String text) {
        return text == null ? "" : text.replace("\"", "\\\"").replace("\n", "");
    }
}
