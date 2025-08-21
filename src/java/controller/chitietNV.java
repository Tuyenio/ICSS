package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class chitietNV extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json");

        String email = req.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Thiếu email\"}");
            return;
        }

        try {
            KNCSDL db = new KNCSDL();
            ResultSet rs = db.layThongTinNhanVienTheoEmail(email);

            if (rs != null && rs.next()) {
                String json = "{"
                        + "\"id\":" + rs.getInt("id") + ","
                        + "\"ho_ten\":\"" + escapeJson(rs.getString("ho_ten")) + "\","
                        + "\"email\":\"" + escapeJson(rs.getString("email")) + "\","
                        + "\"so_dien_thoai\":\"" + escapeJson(rs.getString("so_dien_thoai")) + "\","
                        + "\"gioi_tinh\":\"" + escapeJson(rs.getString("gioi_tinh")) + "\","
                        + "\"ngay_sinh\":\"" + rs.getString("ngay_sinh") + "\","
                        + "\"phong_ban_id\":" + rs.getInt("phong_ban_id") + ","
                        + "\"ten_phong_ban\":\"" + escapeJson(rs.getString("ten_phong_ban")) + "\","
                        + "\"chuc_vu\":\"" + escapeJson(rs.getString("chuc_vu")) + "\","
                        + "\"ngay_vao_lam\":\"" + rs.getString("ngay_vao_lam") + "\","
                        + "\"trang_thai_lam_viec\":\"" + escapeJson(rs.getString("trang_thai_lam_viec")) + "\","
                        + "\"vai_tro\":\"" + escapeJson(rs.getString("vai_tro")) + "\""
                        + "}";

                resp.getWriter().write(json);
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"error\":\"Không tìm thấy nhân viên\"}");
            }

            db.close();

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"Lỗi máy chủ\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\b", "\\b").replace("\f", "\\f")
                .replace("\n", "\\n").replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
