/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

/**
 *
 * @author Admin
 */
public class capnhatChamCong extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        try {
            KNCSDL kn = new KNCSDL();
            
            // Lấy dữ liệu từ form
            String nhanVienId = request.getParameter("nhan_vien_id");
            String ngayCham = request.getParameter("ngay_cham");
            String gioVao = request.getParameter("gio_vao");
            String gioRa = request.getParameter("gio_ra");
            String ghiChu = request.getParameter("ghi_chu");
            String trangThai = request.getParameter("trang_thai");
            
            // Validate dữ liệu
            if (nhanVienId == null || nhanVienId.isEmpty() || 
                ngayCham == null || ngayCham.isEmpty()) {
                response.getWriter().println("<script>alert('Thiếu thông tin bắt buộc!'); history.back();</script>");
                return;
            }
            
            // Cập nhật chấm công  
            boolean success = kn.capNhatChamCong(
                Integer.parseInt(nhanVienId), 
                ngayCham, 
                gioVao, 
                gioRa
            );
            
            if (success) {
                response.getWriter().println("<script>alert('✅ Cập nhật chấm công thành công!'); window.location.href='dsChamCong';</script>");
            } else {
                response.getWriter().println("<script>alert('❌ Cập nhật chấm công thất bại!'); history.back();</script>");
            }
            
        } catch (ClassNotFoundException | SQLException | NumberFormatException ex) {
            Logger.getLogger(capnhatChamCong.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("<script>alert('❌ Lỗi: " + ex.getMessage() + "'); history.back();</script>");
        }
    }
}
