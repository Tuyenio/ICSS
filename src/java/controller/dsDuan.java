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
        try {
            KNCSDL kn = new KNCSDL();

            // Lấy danh sách nhân viên (để hiện Lead)
            List<Map<String, Object>> dsNhanVien = kn.getAllNhanVien();
            req.setAttribute("dsNhanVien", dsNhanVien);

            // --- Lấy tham số lọc ---
            String keyword = req.getParameter("keyword");
            String uuTien = req.getParameter("uuTien");
            String leadIdParam = req.getParameter("leadId");
            String nhom = req.getParameter("nhom_du_an");

            Integer leadId = null;
            if (leadIdParam != null && !leadIdParam.isEmpty()) {
                leadId = Integer.parseInt(leadIdParam);
            }

            List<Map<String, Object>> projects = kn.getAllProjects(keyword, uuTien, leadId, nhom);

            // --- Gửi sang JSP ---
            req.setAttribute("projects", projects);

            req.getRequestDispatcher("/project.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi load dự án");
        }
    }

}
