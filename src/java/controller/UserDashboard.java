package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

/**
 * Servlet xử lý Dashboard cho nhân viên
 * @author Admin
 */
public class UserDashboard extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");
            
            if (email == null || email.isEmpty()) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            KNCSDL kn = new KNCSDL();
            
            // 1. Lấy thông tin nhân viên hiện tại
            Map<String, Object> nhanVienInfo = kn.getNhanVienByEmail(email);
            if (nhanVienInfo.isEmpty()) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            int nhanVienId = (Integer) nhanVienInfo.get("id");
            String vaiTro = (String) nhanVienInfo.get("vai_tro");
            
            // 2. Lấy thống kê công việc của nhân viên
            Map<String, Integer> thongKeCongViec = kn.getThongKeCongViecTheoNhanVien(nhanVienId);
            
            // 3. Lấy thống kê chấm công tháng hiện tại
            Calendar cal = Calendar.getInstance();
            int thangHienTai = cal.get(Calendar.MONTH) + 1;
            int namHienTai = cal.get(Calendar.YEAR);
            
            Map<String, Object> thongKeChamCong = kn.getThongKeChamCongCaNhan(nhanVienId, thangHienTai, namHienTai);
            Map<String, Object> chamCongHomNay = kn.getChamCongHomNay(nhanVienId);
            
            // 4. Lấy thông tin lương tháng hiện tại
            Map<String, Object> thongTinLuong = kn.getThongTinLuongUser(nhanVienId, thangHienTai, namHienTai);
            
            // 5. Lấy thông tin KPI tháng hiện tại
            Map<String, Object> tongHopKPI = kn.getTongHopKPIUser(nhanVienId, thangHienTai, namHienTai);
            
            // 6. Lấy thông báo chưa đọc
            int soThongBaoChuaDoc = kn.getSoThongBaoChuaDoc(nhanVienId);
            
            // 7. Lấy công việc sắp đến hạn (trong 7 ngày tới)
            List<Map<String, Object>> congViecSapDenHan = kn.getCongViecSapDenHan(nhanVienId, 7);
            
            // 8. Lấy thống kê tổng quan công ty (nếu là admin/manager)
            Map<String, Object> thongKeTongQuan = new HashMap<>();
            if ("Admin".equals(vaiTro) || "Quản lý".equals(vaiTro)) {
                thongKeTongQuan = kn.getThongKeTongQuan();
            }
            
            // 9. Lấy thống kê phòng ban của nhân viên
            Integer phongBanId = (Integer) nhanVienInfo.get("phong_ban_id");
            Map<String, Object> thongKePhongBan = kn.getThongKePhongBanById(phongBanId != null ? phongBanId : 0);
            
            // Gửi dữ liệu tới JSP
            request.setAttribute("nhanVienInfo", nhanVienInfo);
            request.setAttribute("thongKeCongViec", thongKeCongViec);
            request.setAttribute("thongKeChamCong", thongKeChamCong);
            request.setAttribute("chamCongHomNay", chamCongHomNay);
            request.setAttribute("thongTinLuong", thongTinLuong);
            request.setAttribute("tongHopKPI", tongHopKPI);
            request.setAttribute("soThongBaoChuaDoc", soThongBaoChuaDoc);
            request.setAttribute("congViecSapDenHan", congViecSapDenHan);
            request.setAttribute("thongKeTongQuan", thongKeTongQuan);
            request.setAttribute("thongKePhongBan", thongKePhongBan);
            request.setAttribute("thangHienTai", thangHienTai);
            request.setAttribute("namHienTai", namHienTai);
            request.setAttribute("vaiTro", vaiTro);
            
            request.getRequestDispatcher("user_dashboard.jsp").forward(request, response);
            
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(UserDashboard.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("Lỗi kết nối cơ sở dữ liệu: " + ex.getMessage());
        }
    }

    public String getServletInfo() {
        return "Servlet xử lý Dashboard cho nhân viên";
    }
}
