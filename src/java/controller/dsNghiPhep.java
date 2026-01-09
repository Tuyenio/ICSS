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
 * Servlet hiển thị trang quản lý nghỉ phép cho Admin
 * @author ICSS
 */
@WebServlet(name = "dsNghiPhep", urlPatterns = {"/dsNghiPhep"})
public class dsNghiPhep extends HttpServlet {

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
                response.sendRedirect("userNghiPhep");
                return;
            }
            
            KNCSDL kn = new KNCSDL();
            
            // Lấy tham số lọc
            String trangThai = request.getParameter("trangThai");
            String thangStr = request.getParameter("thang");
            String namStr = request.getParameter("nam");
            
            int thang = 0, nam = 0;
            if (thangStr != null && !thangStr.isEmpty()) {
                thang = Integer.parseInt(thangStr);
            }
            if (namStr != null && !namStr.isEmpty()) {
                nam = Integer.parseInt(namStr);
            } else {
                nam = Calendar.getInstance().get(Calendar.YEAR);
            }
            
            // Lấy danh sách đơn nghỉ phép
            List<Map<String, Object>> dsDon = kn.getAllDonNghiPhep(trangThai, thang, nam);
            
            // Lấy thống kê
            Map<String, Integer> thongKe = kn.thongKeDonNghiPhep();
            
            // Lấy danh sách nhân viên để tạo đơn hộ
            List<Map<String, Object>> dsNhanVien = kn.getAllNhanVien();
            
            // Gửi dữ liệu đến JSP
            request.setAttribute("dsDonNghiPhep", dsDon);
            request.setAttribute("thongKe", thongKe);
            request.setAttribute("dsNhanVien", dsNhanVien);
            request.setAttribute("trangThaiFilter", trangThai);
            request.setAttribute("thangFilter", thang);
            request.setAttribute("namFilter", nam);
            
            request.getRequestDispatcher("leave_management.jsp").forward(request, response);
            
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(dsNghiPhep.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("<h3 style='color:red'>❌ Lỗi: " + ex.getMessage() + "</h3>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
