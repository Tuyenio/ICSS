package controller;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class dsnhanvien extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Map<String, Object>> danhSach = new ArrayList<>();

        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");
            KNCSDL kn = new KNCSDL(); // Lớp này đã bạn tạo trước rồi
            ResultSet rs = kn.laydl(email);

            while (rs.next()) {
                Map<String, Object> nv = new HashMap<>();
                nv.put("id", rs.getString("id"));
                nv.put("ho_ten", rs.getString("ho_ten"));
                nv.put("email", rs.getString("email"));
                nv.put("mat_khau", rs.getString("mat_khau"));
                nv.put("so_dien_thoai", rs.getString("so_dien_thoai"));
                nv.put("gioi_tinh", rs.getString("gioi_tinh"));
                nv.put("ngay_sinh", rs.getString("ngay_sinh"));
                nv.put("phong_ban_id", rs.getString("phong_ban_id"));
                nv.put("ten_phong_ban", rs.getString("ten_phong_ban"));
                nv.put("chuc_vu", rs.getString("chuc_vu"));
                nv.put("ngay_vao_lam", rs.getString("ngay_vao_lam"));
                nv.put("trang_thai_lam_viec", rs.getString("trang_thai_lam_viec"));
                nv.put("vai_tro", rs.getString("vai_tro"));
                nv.put("avatar_url", rs.getString("avatar_url"));
                danhSach.add(nv);
            }
            rs.close();

            // Gửi dữ liệu sang JSP
            request.setAttribute("danhSach", danhSach);
            request.getRequestDispatcher("employee.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<h3 style='color:red'>❌ Lỗi: " + e.getMessage() + "</h3>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");

        String id = request.getParameter("empId");
        String hoTen = request.getParameter("ho_ten");
        String email = request.getParameter("email");
        String matKhau = request.getParameter("mat_khau");
        String sdt = request.getParameter("so_dien_thoai");
        String gioiTinh = request.getParameter("gioi_tinh");
        String ngaySinh = request.getParameter("ngay_sinh");
        String ngayVaoLam = request.getParameter("ngay_vao_lam");
        String phongban = request.getParameter("ten_phong_ban");  // Gửi lên từ form select
        String chucVu = request.getParameter("chuc_vu");
        String trangThai = request.getParameter("trang_thai_lam_viec");
        String vaiTro = request.getParameter("vai_tro");
        String avatar = request.getParameter("avatar_url");

        int sophongban = Integer.parseInt(phongban);
        boolean success = false;

        try {
            KNCSDL kn = new KNCSDL(); // Khởi tạo lớp xử lý CSDL
            String tenPhongBan = kn.getPhongNameById(sophongban);
            if (id != null && !id.isEmpty()) {
                // Cập nhật nhân viên
                success = kn.capNhatNhanVien(Integer.parseInt(id), hoTen, email, matKhau, sdt, gioiTinh,
                        ngaySinh, ngayVaoLam, tenPhongBan, chucVu, trangThai, vaiTro, avatar);
            } else {
                // ❗ Nếu bạn muốn thêm mới thì cần viết thêm hàm `themNhanVien(...)` trong KNCSDL
                response.setStatus(400);
                response.getWriter().write("{\"status\":\"error\", \"message\":\"Chưa hỗ trợ thêm mới.\"}");
                return;
            }

            if (success) {
                response.getWriter().write("{\"status\":\"ok\"}");
            } else {
                response.setStatus(500);
                response.getWriter().write("{\"status\":\"error\"}");
            }
        } catch (Exception e) {
            response.setStatus(500);
            response.getWriter().write("{\"status\":\"error\", \"message\": \"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
}
