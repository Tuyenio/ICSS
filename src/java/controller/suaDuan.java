package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;

public class suaDuan extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String idStr = req.getParameter("id");
        String tenDuAn = req.getParameter("ten_du_an");
        String moTa = req.getParameter("mo_ta");
        String ngayBatDauStr = req.getParameter("ngay_bat_dau");
        String ngayKetThucStr = req.getParameter("ngay_ket_thuc");

        try (PrintWriter out = resp.getWriter()) {
            if (idStr == null || idStr.isEmpty()) {
                out.print("{\"success\":false,\"message\":\"Thiếu ID dự án\"}");
                return;
            }

            int id = Integer.parseInt(idStr);
            java.sql.Date ngayBatDau = null, ngayKetThuc = null;
            if (ngayBatDauStr != null && !ngayBatDauStr.isEmpty())
                ngayBatDau = java.sql.Date.valueOf(ngayBatDauStr);
            if (ngayKetThucStr != null && !ngayKetThucStr.isEmpty())
                ngayKetThuc = java.sql.Date.valueOf(ngayKetThucStr);

            KNCSDL kn = new KNCSDL();
            boolean success = kn.updateProject(id, tenDuAn, moTa, ngayBatDau, ngayKetThuc);

            if (success) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Sửa dự án thất bại\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }
}
