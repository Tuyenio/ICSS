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
 * Servlet hiển thị trang xin nghỉ phép cho Admin
 * Admin có thể tạo đơn nghỉ phép cho chính mình từ giao diện admin
 * @author ICSS
 */
@WebServlet(name = "adminNghiPhep", urlPatterns = {"/adminNghiPhep"})
public class adminNghiPhep extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");
            String vaiTro = (String) session.getAttribute("vaiTro");
            
            // Kiểm tra đăng nhập
            if (email == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Kiểm tra vai trò: chỉ Admin, Quản lý, Trưởng phòng, Giám đốc mới được vào
            if (vaiTro == null || (!vaiTro.equalsIgnoreCase("admin") && 
                !vaiTro.equalsIgnoreCase("Quản lý") && 
                !vaiTro.equalsIgnoreCase("Trưởng phòng") &&
                !vaiTro.equalsIgnoreCase("Giám đốc"))) {
                response.sendRedirect("index.jsp");
                return;
            }
            
            KNCSDL kn = new KNCSDL();
            
            // Lấy thông tin nhân viên (admin cũng là một nhân viên)
            Map<String, Object> nhanVienInfo = kn.getNhanVienByEmail(email);
            if (nhanVienInfo == null) {
                response.getWriter().println("<h3 style='color:red'>❌ Không tìm thấy thông tin nhân viên!</h3>");
                return;
            }
            
            int nhanVienId = (Integer) nhanVienInfo.get("id");
            int namHienTai = Calendar.getInstance().get(Calendar.YEAR);
            
            // Lấy danh sách đơn nghỉ phép của admin
            List<Map<String, Object>> dsDon = kn.getDonNghiPhepByNhanVien(nhanVienId);
            
            // Lấy thông tin ngày phép còn lại
            Map<String, Object> ngayPhep = kn.getNgayPhepNam(nhanVienId, namHienTai);
            
            // Gửi dữ liệu đến JSP
            request.setAttribute("nhanVienInfo", nhanVienInfo);
            request.setAttribute("dsDonNghiPhep", dsDon);
            request.setAttribute("ngayPhep", ngayPhep);
            request.setAttribute("namHienTai", namHienTai);
            
            request.getRequestDispatcher("admin_leave.jsp").forward(request, response);
            
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(adminNghiPhep.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("<h3 style='color:red'>❌ Lỗi: " + ex.getMessage() + "</h3>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
