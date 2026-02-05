package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

public class themNhanvien extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain");

        PrintWriter out = response.getWriter();

        try {
            // Lấy thông tin từ form
            String hoTen = request.getParameter("ho_ten");
            String email = request.getParameter("email");
            String matKhau = request.getParameter("mat_khau");
            String sdt = request.getParameter("so_dien_thoai");
            String gioiTinh = request.getParameter("gioi_tinh");
            String ngaySinh = request.getParameter("ngay_sinh");
            String ngayVaoLam = request.getParameter("ngay_vao_lam");
            String phongban = request.getParameter("ten_phong_ban");
            String chucVu = request.getParameter("chuc_vu");
            String trangThai = request.getParameter("trang_thai_lam_viec");
            String vaiTro = request.getParameter("vai_tro");

            // ✅ VALIDATION EMAIL
            String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
            if (email == null || email.trim().isEmpty() || !email.matches(emailRegex)) {
                out.print("error_email");
                return;
            }

            // ✅ VALIDATION SỐ ĐIỆN THOẠI (chỉ số, 10-11 chữ số)
            if (sdt != null && !sdt.trim().isEmpty()) {
                String phoneRegex = "^[0-9]{10,11}$";
                if (!sdt.matches(phoneRegex)) {
                    out.print("error_phone");
                    return;
                }
            }

            int sophongban = Integer.parseInt(phongban);

            KNCSDL kn = new KNCSDL();
            String tenPhongBan = kn.getPhongNameById(sophongban);

            // Thêm nhân viên
            boolean result = kn.themNhanVien(hoTen, email, matKhau, sdt, gioiTinh,
                    ngaySinh, ngayVaoLam, tenPhongBan, chucVu, trangThai, vaiTro, "null");

            // Lấy thông tin người đang đăng nhập (vai trò & chức vụ)
            HttpSession session = request.getSession();
            //String vaiTroDangNhap = (String) session.getAttribute("vaiTro");
            String vaiTroDangNhap = (String) session.getAttribute("vaiTro");

            String tieuDeTB = "Nhân viên mới";
            String noiDungTB = tenPhongBan + ": vừa thêm một nhân viên mới.";

            if ("Admin".equalsIgnoreCase(vaiTroDangNhap)) {
                // Nếu là Giám đốc -> gửi thông báo cho Trưởng phòng của phòng ban mới
                int truongPhongId = kn.getTruongPhongIdByTenPhong(tenPhongBan);
                if (truongPhongId > 0) {
                    String duongDan = "dsnhanvien";
                    kn.insertThongBao(truongPhongId, tieuDeTB, noiDungTB, "Nhân viên mới",duongDan);
                }
            } else if ("Quản lý".equalsIgnoreCase(vaiTroDangNhap)) {
                // Nếu là Quản lý -> gửi thông báo cho Giám đốc
                int giamDocId = kn.getGiamDocId(); // Bạn cần viết hàm này trong KNCSDL
                if (giamDocId > 0) {
                    String duongDan = "dsnhanvien";
                    kn.insertThongBao(giamDocId, tieuDeTB, noiDungTB, "Nhân viên mới",duongDan);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("error");
        }
    }
}
