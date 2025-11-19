package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.Date;

public class themDuan extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String tenDuAn = req.getParameter("ten_du_an");
        String moTa = req.getParameter("mo_ta");
        String uuTien = req.getParameter("muc_do_uu_tien");
        String leadIdStr = req.getParameter("lead_id");
        String nhomDuAn = req.getParameter("nhom_du_an");

        int leadId = (leadIdStr != null && !leadIdStr.isEmpty()) ? Integer.parseInt(leadIdStr) : 0;

        String ngayBatDauStr = req.getParameter("ngay_bat_dau");
        String ngayKetThucStr = req.getParameter("ngay_ket_thuc");

        Date ngayBatDau = null, ngayKetThuc = null;
        try {
            if (ngayBatDauStr != null && !ngayBatDauStr.isEmpty())
                ngayBatDau = Date.valueOf(ngayBatDauStr);
            if (ngayKetThucStr != null && !ngayKetThucStr.isEmpty())
                ngayKetThuc = Date.valueOf(ngayKetThucStr);
        } catch (Exception e) {
            e.printStackTrace();
        }

        try (PrintWriter out = resp.getWriter()) {
            KNCSDL kn = new KNCSDL();
            boolean success = kn.insertDuAn(tenDuAn, moTa, uuTien, leadId, nhomDuAn, ngayBatDau, ngayKetThuc);

            if (success) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Thêm dự án thất bại\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }
}
