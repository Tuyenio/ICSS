package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class apiChiTietPhongban extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Thiếu tham số id\"}");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            KNCSDL kn = new KNCSDL();
            
            // Lấy thông tin phòng ban
            Map<String, Object> phongBan = kn.getPhongBanById(id);
            
            if (phongBan.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Không tìm thấy phòng ban\"}");
                return;
            }
            
            // Lấy danh sách nhân viên trong phòng ban
            List<Map<String, Object>> nhanVienList = kn.getNhanVienByPhongBan(id);
            phongBan.put("nhan_vien_list", nhanVienList);
            
            // Chuyển đổi sang JSON
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"id\":").append(phongBan.get("id")).append(",");
            json.append("\"ten_phong\":\"").append(escapeJson(String.valueOf(phongBan.get("ten_phong")))).append("\",");
            json.append("\"truong_phong_id\":").append(phongBan.get("truong_phong_id")).append(",");
            json.append("\"truong_phong_ten\":\"").append(escapeJson(String.valueOf(phongBan.get("truong_phong_ten")))).append("\",");
            json.append("\"ngay_tao\":\"").append(phongBan.get("ngay_tao")).append("\",");
            json.append("\"nhan_vien_list\":[");
            
            for (int i = 0; i < nhanVienList.size(); i++) {
                Map<String, Object> nv = nhanVienList.get(i);
                json.append("{");
                json.append("\"id\":").append(nv.get("id")).append(",");
                json.append("\"ho_ten\":\"").append(escapeJson(String.valueOf(nv.get("ho_ten")))).append("\",");
                json.append("\"email\":\"").append(escapeJson(String.valueOf(nv.get("email")))).append("\",");
                json.append("\"chuc_vu\":\"").append(escapeJson(String.valueOf(nv.get("chuc_vu")))).append("\",");
                json.append("\"vai_tro\":\"").append(escapeJson(String.valueOf(nv.get("vai_tro")))).append("\"");
                json.append("}");
                if (i < nhanVienList.size() - 1) {
                    json.append(",");
                }
            }
            
            json.append("]}");
            out.print(json.toString());

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID không hợp lệ\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Lỗi khi truy vấn dữ liệu\"}");
        }
    }

    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    @Override
    public String getServletInfo() {
        return "API lấy chi tiết phòng ban";
    }
}
