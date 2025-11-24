package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;

public class getTaskDetail extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        PrintWriter out = response.getWriter();

        try {
            KNCSDL kn = new KNCSDL();
            String nvIdStr = request.getParameter("nvId");
            String status = request.getParameter("status");
            String tu = request.getParameter("tu");
            String den = request.getParameter("den");

            if (nvIdStr == null || status == null || tu == null || den == null) {
                out.print("[]");
                return;
            }

            int nvId = Integer.parseInt(nvIdStr);

            List<Map<String, Object>> list = kn.getTaskDetailByStatus(nvId, status, tu, den);

            // ===== TỰ TẠO JSON =====
            StringBuilder json = new StringBuilder();
            json.append("[");

            for (int i = 0; i < list.size(); i++) {
                Map<String, Object> task = list.get(i);

                json.append("{");
                json.append("\"id\":").append(task.get("id")).append(",");
                json.append("\"ten_cong_viec\":\"").append(escapeJson(task.get("ten_cong_viec"))).append("\",");
                json.append("\"trang_thai\":\"").append(escapeJson(task.get("trang_thai"))).append("\",");
                json.append("\"ten_du_an\":\"").append(escapeJson(task.get("ten_du_an"))).append("\",");
                json.append("\"ngay_bat_dau\":\"").append(escapeJson(task.get("ngay_bat_dau"))).append("\",");
                json.append("\"han_hoan_thanh\":\"").append(escapeJson(task.get("han_hoan_thanh"))).append("\",");
                json.append("\"ngay_hoan_thanh\":\"").append(escapeJson(task.get("ngay_hoan_thanh"))).append("\"");
                json.append("}");

                if (i < list.size() - 1)
                    json.append(",");
            }

            json.append("]");

            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
        }
    }

    // Hàm escape JSON để tránh lỗi chuỗi
    private String escapeJson(Object value) {
        if (value == null) return "";
        return value.toString()
                .replace("\\", "\\\\")
                .replace("\"", "\\\"");
    }
}
