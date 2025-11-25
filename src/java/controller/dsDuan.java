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
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class dsDuan extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        try {
            KNCSDL kn = new KNCSDL();

            // Lấy danh sách nhân viên (để hiện Lead)
            List<Map<String, Object>> dsNhanVien = kn.getAllNhanVien();
            req.setAttribute("dsNhanVien", dsNhanVien);

            // --- Lấy tham số lọc ---
            String keyword = req.getParameter("keyword");
            String uuTien = req.getParameter("uuTien");
            String leadIdParam = req.getParameter("leadId");
            HttpSession session = req.getSession();

            String nhom = req.getParameter("nhom_du_an");
            String phongBan = req.getParameter("phong_ban");
            if (nhom == null || nhom.equals("null")) {
                nhom = (String) session.getAttribute("nhom_du_an");
            }
            if (phongBan == null || phongBan.equals("null")) {
                phongBan = (String) session.getAttribute("phong_ban");
            }

            Integer leadId = null;
            if (leadIdParam != null && !leadIdParam.isEmpty()) {
                leadId = Integer.parseInt(leadIdParam);
            }

            List<Map<String, Object>> projects = kn.getAllProjects(keyword, uuTien, leadId, nhom, phongBan);

            // --- Gửi sang JSP ---
            session.setAttribute("nhom_du_an", nhom);
            session.setAttribute("phong_ban", phongBan);
            req.setAttribute("projects", projects);
            req.setAttribute("nhomDuAnValue", nhom);
            req.getRequestDispatcher("/project.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi load dự án");
        }
    }

}
