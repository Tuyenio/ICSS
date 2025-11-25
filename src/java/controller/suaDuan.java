package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.Date;

public class suaDuan extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Thiếu ID dự án\"}");
            return;
        }

        int id = Integer.parseInt(idStr);

        String tenDuAn = req.getParameter("ten_du_an");
        String moTa = req.getParameter("mo_ta");
        String uuTien = req.getParameter("muc_do_uu_tien");
        String leadIdStr = req.getParameter("lead_id");
        String nhomDuAn = req.getParameter("nhom_du_an");
        String phongBan = req.getParameter("phong_ban");

        int leadId = (leadIdStr != null && !leadIdStr.isEmpty()) ? Integer.parseInt(leadIdStr) : 0;

        String ngayBatDauStr = req.getParameter("ngay_bat_dau");
        String ngayKetThucStr = req.getParameter("ngay_ket_thuc");

        Date ngayBatDau = null, ngayKetThuc = null;
        if (ngayBatDauStr != null && !ngayBatDauStr.isEmpty())
            ngayBatDau = Date.valueOf(ngayBatDauStr);
        if (ngayKetThucStr != null && !ngayKetThucStr.isEmpty())
            ngayKetThuc = Date.valueOf(ngayKetThucStr);

        try (PrintWriter out = resp.getWriter()) {
            KNCSDL kn = new KNCSDL();
            boolean success = kn.updateProject(id, tenDuAn, moTa, uuTien, leadId, nhomDuAn, phongBan, ngayBatDau, ngayKetThuc);

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
