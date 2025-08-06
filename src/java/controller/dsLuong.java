/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

/**
 *
 * @author Admin
 */
public class dsLuong extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            KNCSDL kn = new KNCSDL();
            
            // Lấy tham số lọc từ request
            String thang = request.getParameter("thang");
            String nam = request.getParameter("nam");
            String phongBan = request.getParameter("phong_ban");
            String keyword = request.getParameter("keyword");
            
            // Nếu không có tham số tháng/năm, sử dụng tháng hiện tại
            if (thang == null || thang.isEmpty()) {
                Calendar cal = Calendar.getInstance();
                thang = String.valueOf(cal.get(Calendar.MONTH) + 1);
                nam = String.valueOf(cal.get(Calendar.YEAR));
            }
            
            // Lấy dữ liệu lương
            List<Map<String, Object>> danhSachLuong = kn.getDanhSachLuong(thang, nam, phongBan, keyword);
            
            // Lấy danh sách phòng ban cho filter
            List<Map<String, Object>> danhSachPhongBan = kn.getAllPhongBan();
            
            // Gửi dữ liệu đến JSP
            request.setAttribute("danhSachLuong", danhSachLuong);
            request.setAttribute("danhSachPhongBan", danhSachPhongBan);
            request.setAttribute("thangHienTai", thang);
            request.setAttribute("namHienTai", nam);
            request.setAttribute("phongBanDaChon", phongBan);
            request.setAttribute("keywordDaChon", keyword);
            
            request.getRequestDispatcher("attendance.jsp").forward(request, response);
            
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(dsLuong.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("<h3 style='color:red'>❌ Lỗi: " + ex.getMessage() + "</h3>");
        }
    }
}
