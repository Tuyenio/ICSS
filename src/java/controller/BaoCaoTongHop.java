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
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author Admin
 */
public class BaoCaoTongHop extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            KNCSDL kn = new KNCSDL();
            
            // Lấy tham số lọc từ request
            String thang = request.getParameter("thang");
            String nam = request.getParameter("nam");
            String phongBan = request.getParameter("phong_ban");
            
            // Nếu không có tham số tháng/năm, sử dụng tháng hiện tại
            if (thang == null || thang.isEmpty()) {
                Calendar cal = Calendar.getInstance();
                thang = String.valueOf(cal.get(Calendar.MONTH) + 1);
                nam = String.valueOf(cal.get(Calendar.YEAR));
            }
            
            // Lấy dữ liệu báo cáo
            List<Map<String, Object>> baoCaoNhanVien = kn.getBaoCaoTongHopNhanVien(thang, nam, phongBan);
            List<Map<String, Object>> thongKePhongBan = kn.getThongKeTienDoTheoPhongBan();
            Map<String, Integer> thongKeTrangThai = kn.getThongKeCongViecTheoTrangThai();
            
            // Lấy danh sách phòng ban cho filter
            List<Map<String, Object>> danhSachPhongBan = kn.getAllPhongBan();
            
            // Gửi dữ liệu đến JSP
            request.setAttribute("baoCaoNhanVien", baoCaoNhanVien);
            request.setAttribute("thongKePhongBan", thongKePhongBan);
            request.setAttribute("thongKeTrangThai", thongKeTrangThai);
            request.setAttribute("danhSachPhongBan", danhSachPhongBan);
            request.setAttribute("thangHienTai", thang);
            request.setAttribute("namHienTai", nam);
            request.setAttribute("phongBanDaChon", phongBan);
            
            request.getRequestDispatcher("report.jsp").forward(request, response);
            
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(BaoCaoTongHop.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("<h3 style='color:red'>❌ Lỗi: " + ex.getMessage() + "</h3>");
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet xử lý báo cáo tổng hợp";
    }// </editor-fold>
}
