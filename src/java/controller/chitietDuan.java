package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.Connection;
import java.util.Map;

public class chitietDuan extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            int id = Integer.parseInt(req.getParameter("id"));
            KNCSDL kn = new KNCSDL();
            Map<String, Object> project = kn.getProjectById(id);

            if (project != null) {
                // Tạo JSON thủ công
                StringBuilder json = new StringBuilder("{");
                json.append("\"id\":").append(project.get("id")).append(",");
                json.append("\"ten_du_an\":\"").append(escapeJson(project.get("ten_du_an"))).append("\",");
                json.append("\"mo_ta\":\"").append(escapeJson(project.get("mo_ta"))).append("\",");
                json.append("\"muc_do_uu_tien\":\"").append(project.get("muc_do_uu_tien")).append("\",");
                json.append("\"lead_id\":").append(project.get("lead_id")).append(",");
                json.append("\"nhom_du_an\":\"").append(project.get("nhom_du_an")).append("\",");
                json.append("\"ngay_bat_dau\":\"").append(project.get("ngay_bat_dau")).append("\",");
                json.append("\"ngay_ket_thuc\":\"").append(project.get("ngay_ket_thuc")).append("\",");
                json.append("\"ngay_tao\":\"").append(project.get("ngay_tao")).append("\",");
                json.append("\"tong_cong_viec\":").append(project.get("tong_cong_viec")).append(",");
                json.append("\"tong_nguoi\":").append(project.get("tong_nguoi"));
                json.append("}");

                out.write(json.toString());
            } else {
                out.write("{\"error\":\"Không tìm thấy dự án\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"error\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }

    // Hàm escape để tránh lỗi JSON khi có ký tự đặc biệt
    private String escapeJson(Object value) {
        if (value == null) {
            return "";
        }
        return value.toString()
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
