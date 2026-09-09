package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class locNhanvien extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String keyword = request.getParameter("keyword");
        String phong = request.getParameter("phong_ban");   // id phòng (dành cho admin)
        String trangThai = request.getParameter("trang_thai");
        String vaiTroFlt = request.getParameter("vai_tro");     // filter vai trò NV (không phải vai trò người xem)

        // Lấy info người đang đăng nhập
        HttpSession session = request.getSession(false);
        String currentEmail = (session != null) ? (String) session.getAttribute("userEmail") : null;
        String currentRole = (session != null) ? (String) session.getAttribute("vaiTro") : null;

        try (PrintWriter out = response.getWriter()) {

            if (currentRole == null || currentEmail == null) {
                out.println("<tr><td colspan='13' class='text-center text-danger'>Phiên đăng nhập hết hạn</td></tr>");
                return;
            }

            KNCSDL db = new KNCSDL();
            List<Map<String, Object>> danhSach;

            if ("Admin".equalsIgnoreCase(currentRole)) {
                // --- CHẾ ĐỘ ADMIN ---
                String phongbanName = null;
                if (phong != null && !phong.trim().isEmpty()) {
                    int idPhong = Integer.parseInt(phong);
                    phongbanName = db.getPhongNameById(idPhong);
                }
                danhSach = db.locNhanVien(keyword, phongbanName, trangThai, vaiTroFlt);

            } else {
                // --- CHẾ ĐỘ TRƯỞNG PHÒNG (QUẢN LÝ) ---
                // Bỏ qua tham số "phong_ban" từ form, fix theo phòng của người đang đăng nhập
                danhSach = db.locNhanVienQL(keyword, trangThai, currentEmail,vaiTroFlt);
            }

            if (danhSach != null && !danhSach.isEmpty()) {
                int stt = 1;
                for (Map<String, Object> nv : danhSach) {
                    String hoTen = str(nv.get("ho_ten"));
                    String trangThaiNV = str(nv.get("trang_thai_lam_viec"));
                    String vaiTroNV = str(nv.get("vai_tro"));

                    out.println("<tr>");
                    out.println("<td>" + (stt++) + "</td>");
                    out.println("<td><img src='" + esc(avatarOf(nv)) + "' class='rounded-circle' width='36' alt='avatar'></td>");
                    out.println("<td><a href='#' class='emp-detail-link fw-semibold text-primary' data-email='" + esc(str(nv.get("email"))) + "'>" + esc(hoTen) + "</a></td>");
                    out.println("<td>" + esc(str(nv.get("email"))) + "</td>");
                    out.println("<td>" + esc(str(nv.get("so_dien_thoai"))) + "</td>");
                    out.println("<td>" + esc(str(nv.get("gioi_tinh"))) + "</td>");
                    out.println("<td>" + esc(str(nv.get("ngay_sinh"))) + "</td>");
                    out.println("<td>" + esc(str(nv.get("ten_phong_ban"))) + "</td>");
                    out.println("<td>" + esc(str(nv.get("chuc_vu"))) + "</td>");
                    out.println("<td>" + esc(str(nv.get("ngay_vao_lam"))) + "</td>");
                    out.println("<td><span class='badge " + badgeTrangThai(trangThaiNV) + "'>" + esc(trangThaiNV) + "</span></td>");
                    out.println("<td><span class='badge " + badgeVaiTro(vaiTroNV) + "'>" + esc(vaiTroNV) + "</span></td>");
                    out.println("<td class='action-btns'>");
                    out.println("<button class='btn btn-sm btn-warning edit-emp-btn' data-id='" + esc(str(nv.get("id"))) + "'"
                            + " data-name='" + esc(hoTen) + "'"
                            + " data-email='" + esc(str(nv.get("email"))) + "'"
                            + " data-pass='" + esc(str(nv.get("mat_khau"))) + "'"
                            + " data-phone='" + esc(str(nv.get("so_dien_thoai"))) + "'"
                            + " data-gender='" + esc(str(nv.get("gioi_tinh"))) + "'"
                            + " data-birth='" + esc(str(nv.get("ngay_sinh"))) + "'"
                            + " data-startdate='" + esc(str(nv.get("ngay_vao_lam"))) + "'"
                            + " data-phong-ban-id='" + esc(str(nv.get("phong_ban_id"))) + "'"
                            + " data-position='" + esc(str(nv.get("chuc_vu"))) + "'"
                            + " data-status='" + esc(trangThaiNV) + "'"
                            + " data-role='" + esc(vaiTroNV) + "'"
                            + " data-avatar='" + esc(str(nv.get("avatar_url"))) + "'>");
                    out.println("<i class='fa-solid fa-pen'></i></button>");
                    out.println("<button class='btn btn-sm btn-danger delete-emp-btn' data-id='" + esc(str(nv.get("id"))) + "'>");
                    out.println("<i class='fa-solid fa-trash'></i></button>");
                    out.println("</td>");
                    out.println("</tr>");
                }
            } else {
                out.println("<tr><td colspan='13' class='text-center'>Không có dữ liệu phù hợp</td></tr>");
            }

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            response.getWriter().write("<tr><td colspan='13' class='text-center text-danger'>Lỗi hệ thống</td></tr>");
        }
    }

    private static String str(Object o) {
        return o == null ? "" : o.toString();
    }

    // Escape để tránh XSS / vỡ HTML khi dữ liệu chứa dấu nháy, dấu <>
    private static String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    // Avatar thật của từng nhân viên, fallback sang ảnh chữ cái nếu chưa có
    private static String avatarOf(Map<String, Object> nv) {
        String avatar = str(nv.get("avatar_url")).trim();
        if (!avatar.isEmpty()) {
            return avatar;
        }
        String hoTen = str(nv.get("ho_ten")).trim();
        if (hoTen.isEmpty()) {
            hoTen = "User";
        }
        try {
            return "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(hoTen, "UTF-8");
        } catch (java.io.UnsupportedEncodingException e) {
            return "https://ui-avatars.com/api/?name=User";
        }
    }

    // Màu badge phải khớp với employee.jsp và getBadgeClass() trong employee.js
    private static String badgeTrangThai(String trangThai) {
        if ("Đang làm".equals(trangThai)) {
            return "bg-success";
        } else if ("Tạm nghỉ".equals(trangThai)) {
            return "bg-warning text-dark";
        } else if ("Nghỉ việc".equals(trangThai)) {
            return "bg-danger";
        }
        return "bg-secondary";
    }

    private static String badgeVaiTro(String vaiTro) {
        if ("Admin".equals(vaiTro)) {
            return "bg-danger";
        } else if ("Quản lý".equals(vaiTro)) {
            return "bg-warning text-dark";
        } else if ("Nhân viên".equals(vaiTro)) {
            return "bg-info text-dark";
        }
        return "bg-secondary";
    }

    @Override
    public String getServletInfo() {
        return "Lọc nhân viên cho Admin (toàn cục) và Trưởng phòng (theo phòng ban của chính họ)";
    }
}
