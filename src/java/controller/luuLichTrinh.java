package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;

public class luuLichTrinh extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String idStr = req.getParameter("id");
        String tieuDe = req.getParameter("title");
        String ngayBatDauStr = req.getParameter("start");
        String ngayKetThucStr = req.getParameter("end");
        String moTa = req.getParameter("description");

        try (PrintWriter out = resp.getWriter()) {
            java.sql.Date ngayBatDau = (ngayBatDauStr != null && !ngayBatDauStr.isEmpty())
                    ? java.sql.Date.valueOf(ngayBatDauStr) : null;
            java.sql.Date ngayKetThuc = (ngayKetThucStr != null && !ngayKetThucStr.isEmpty())
                    ? java.sql.Date.valueOf(ngayKetThucStr) : null;

            KNCSDL kn = new KNCSDL();
            boolean thanhCong;

            if (idStr == null || idStr.isEmpty()) {
                // thêm mới
                thanhCong = kn.themLichTrinh(tieuDe, ngayBatDau, ngayKetThuc, moTa);
            } else {
                // cập nhật
                int id = Integer.parseInt(idStr);
                thanhCong = kn.capNhatLichTrinh(id, tieuDe, ngayBatDau, ngayKetThuc, moTa);
            }

            if (thanhCong) {
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Lưu lịch trình thất bại\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().print("{\"success\":false,\"message\":\"Lỗi: " + e.getMessage() + "\"}");
        }
    }
}
