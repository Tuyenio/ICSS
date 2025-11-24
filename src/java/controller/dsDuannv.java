/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class dsDuannv extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        try {
            KNCSDL kn = new KNCSDL();
            HttpSession session = req.getSession();
            String email = (String) session.getAttribute("userEmail");

            // ========== Lấy danh sách nhân viên để lọc Lead ==========
            List<Map<String, Object>> dsNhanVien = kn.getAllNhanVien();
            req.setAttribute("dsNhanVien", dsNhanVien);

            // ========== Nhận tham số lọc ==========
            String keyword = req.getParameter("keyword");
            String uuTien = req.getParameter("uuTien");
            String nhom = req.getParameter("nhom_du_an");
            String leadParam = req.getParameter("leadId");

            Integer leadId = null;
            if (leadParam != null && !leadParam.isEmpty()) {
                leadId = Integer.parseInt(leadParam);
            }

            // ========== Gọi hàm lấy dự án có lọc ==========
            List<Map<String, Object>> projects = kn.getProjectsByNhanVienFilter(email, keyword, uuTien, leadId, nhom);

            req.setAttribute("projects", projects);

            // Gửi filter đang chọn về JSP
            req.setAttribute("keyword", keyword);
            req.setAttribute("uuTien", uuTien);
            req.setAttribute("nhom_du_an", nhom);
            req.setAttribute("leadId", leadId);

            req.getRequestDispatcher("projectnv.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi load dự án");
        }
    }
}
