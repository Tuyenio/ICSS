package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

/**
 * Servlet hiển thị thống kê ngày phép của tất cả nhân viên cho Admin
 * @author ICSS
 */
@WebServlet(name = "adminLeaveStats", urlPatterns = {"/adminLeaveStats"})
public class adminLeaveStats extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");
            String role = (String) session.getAttribute("vaiTro");
            
            // Kiểm tra đăng nhập
            if (email == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Chỉ Admin và Quản lý mới được truy cập
            if (!"Admin".equalsIgnoreCase(role) && !"Quản lý".equalsIgnoreCase(role)) {
                response.sendRedirect("index.jsp");
                return;
            }
            
            KNCSDL kn = new KNCSDL();
            
            // Lấy năm từ tham số, mặc định là năm hiện tại
            String namStr = request.getParameter("nam");
            int nam = Calendar.getInstance().get(Calendar.YEAR);
            if (namStr != null && !namStr.isEmpty()) {
                try {
                    nam = Integer.parseInt(namStr);
                } catch (NumberFormatException e) {
                    // Giữ nguyên năm hiện tại nếu parse lỗi
                }
            }
            
            // Lấy thống kê ngày phép của tất cả nhân viên
            List<Map<String, Object>> dsNhanVienPhep = kn.getThongKeNgayPhepAllNhanVien(nam);
            
            // Tính toán thống kê tổng hợp
            double tongPhepCapPhat = 0.0;
            double tongPhepDaDung = 0.0;
            double tongPhepConLai = 0.0;
            double tongPhepNamTruoc = 0.0;
            
            for (Map<String, Object> nv : dsNhanVienPhep) {
                tongPhepCapPhat += ((Number) nv.getOrDefault("tong_ngay_phep", 0)).doubleValue();
                tongPhepDaDung += ((Number) nv.getOrDefault("ngay_phep_da_dung", 0)).doubleValue();
                tongPhepConLai += ((Number) nv.getOrDefault("ngay_phep_con_lai", 0)).doubleValue();
                tongPhepNamTruoc += ((Number) nv.getOrDefault("ngay_phep_nam_truoc", 0)).doubleValue();
            }
            
            // Gửi dữ liệu đến JSP
            request.setAttribute("dsNhanVienPhep", dsNhanVienPhep);
            request.setAttribute("nam", nam);
            request.setAttribute("tongPhepCapPhat", tongPhepCapPhat);
            request.setAttribute("tongPhepDaDung", tongPhepDaDung);
            request.setAttribute("tongPhepConLai", tongPhepConLai);
            request.setAttribute("tongPhepNamTruoc", tongPhepNamTruoc);
            request.setAttribute("soLuongNhanVien", dsNhanVienPhep.size());
            
            request.getRequestDispatcher("admin_leave_statistics.jsp").forward(request, response);
            
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(adminLeaveStats.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("<h3 style='color:red'>❌ Lỗi: " + ex.getMessage() + "</h3>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
