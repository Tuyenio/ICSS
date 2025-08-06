/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Admin
 */
public class dsBaoCao {

    // Phương thức để lấy dữ liệu báo cáo tổng hợp
    public static void layDuLieuBaoCao(
            jakarta.servlet.http.HttpServletRequest request, 
            jakarta.servlet.http.HttpServletResponse response) {
        
        try {
            // Lấy tham số từ request
            String thangParam = request.getParameter("thang");
            String namParam = request.getParameter("nam");
            String phongBanParam = request.getParameter("phong_ban");
            
            // Nếu không có tham số, sử dụng tháng hiện tại
            if (thangParam == null || thangParam.isEmpty()) {
                Calendar cal = Calendar.getInstance();
                thangParam = String.valueOf(cal.get(Calendar.MONTH) + 1);
                namParam = String.valueOf(cal.get(Calendar.YEAR));
            }
            
            // Lấy dữ liệu báo cáo
            List<Map<String, Object>> baoCaoNhanVien = apiBaoCao.getBaoCaoNhanVien(thangParam, namParam, phongBanParam);
            Map<String, Object> pieChartData = apiBaoCao.getDataForPieChart();
            Map<String, Object> barChartData = apiBaoCao.getDataForBarChart();
            
            // Lấy danh sách phòng ban cho filter
            List<Map<String, Object>> danhSachPhongBan = new ArrayList<>();
            try {
                KNCSDL kn = new KNCSDL();
                danhSachPhongBan = kn.getAllPhongBan();
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            // Gửi dữ liệu đến JSP
            request.setAttribute("baoCaoNhanVien", baoCaoNhanVien);
            request.setAttribute("pieChartData", pieChartData);
            request.setAttribute("barChartData", barChartData);
            request.setAttribute("danhSachPhongBan", danhSachPhongBan);
            request.setAttribute("thangHienTai", thangParam);
            request.setAttribute("namHienTai", namParam);
            request.setAttribute("phongBanDaChon", phongBanParam);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
