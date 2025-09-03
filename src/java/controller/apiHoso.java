/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class apiHoso extends HttpServlet {

    private static final SimpleDateFormat DF = new SimpleDateFormat("dd/MM/yyyy");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy email từ param hoặc session
        HttpSession session = request.getSession(false);
        String email = request.getParameter("email");
        if ((email == null || email.isBlank()) && session != null) {
            email = (String) session.getAttribute("userEmail");
        }

        // Nếu không có email -> báo lỗi và forward mặc định (user)
        if (email == null || email.isBlank()) {
            request.setAttribute("error", "Không xác định được email người dùng.");
            forwardTo(request, response, "/user_profile.jsp");
            return;
        }

        KNCSDL db = null;
        ResultSet rs = null;
        Statement st = null;

        String vaiTroFromDb = null;

        try {
            db = new KNCSDL();
            rs = db.layThongTinNhanVienTheoEmail(email);

            if (rs != null && rs.next()) {
                Map<String, Object> hs = new HashMap<>();

                Integer id = rs.getInt("id");
                String hoTen = rs.getString("ho_ten");
                String mail = rs.getString("email");
                String sdt = rs.getString("so_dien_thoai");
                String gioiTinh = rs.getString("gioi_tinh");
                java.sql.Date ngaySinh = rs.getDate("ngay_sinh");
                Integer phongBanId = (Integer) rs.getObject("phong_ban_id");
                String tenPhongBan = rs.getString("ten_phong_ban");
                String chucVu = rs.getString("chuc_vu");
                java.sql.Date ngayVaoLam = rs.getDate("ngay_vao_lam");
                String trangThaiLV = rs.getString("trang_thai_lam_viec");
                String vaiTro = rs.getString("vai_tro");
                String avatar = rs.getString("avatar_url");
                String ngayTao = null;
                try {
                    ngayTao = rs.getString("ngay_tao"); // nếu có cột này
                } catch (SQLException ignore) {
                }

                vaiTroFromDb = (vaiTro != null) ? vaiTro.trim() : null;

                // Format ngày
                String birthStr = (ngaySinh != null) ? DF.format(ngaySinh) : "";
                String startStr = (ngayVaoLam != null) ? DF.format(ngayVaoLam) : "";

                // Badge class
                String statusBadgeClass = "bg-secondary";
                if ("Đang làm".equalsIgnoreCase(trangThaiLV)) {
                    statusBadgeClass = "bg-success";
                } else if ("Tạm nghỉ".equalsIgnoreCase(trangThaiLV)) {
                    statusBadgeClass = "bg-warning";
                } else if ("Nghỉ việc".equalsIgnoreCase(trangThaiLV)) {
                    statusBadgeClass = "bg-danger";
                }

                String roleBadgeClass = "bg-info text-dark";
                if ("Admin".equalsIgnoreCase(vaiTroFromDb) || "Quản lý".equalsIgnoreCase(vaiTroFromDb)) {
                    roleBadgeClass = "bg-dark";
                }

                // Put attribute dùng chung cho cả 2 JSP
                hs.put("id", id);
                hs.put("ho_ten", hoTen);
                hs.put("email", mail);
                hs.put("so_dien_thoai", sdt);
                hs.put("gioi_tinh", gioiTinh);
                hs.put("ngay_sinh", birthStr);
                hs.put("phong_ban_id", phongBanId);
                hs.put("ten_phong_ban", tenPhongBan);
                hs.put("chuc_vu", chucVu);
                hs.put("ngay_vao_lam", startStr);
                hs.put("trang_thai_lam_viec", trangThaiLV);
                hs.put("vai_tro", vaiTroFromDb);
                hs.put("avatar_url", avatar);
                hs.put("ngay_tao", (ngayTao != null ? ngayTao : ""));

                hs.put("statusBadgeClass", statusBadgeClass);
                hs.put("roleBadgeClass", roleBadgeClass);

                request.setAttribute("hs", hs);
            } else {
                request.setAttribute("error", "Không tìm thấy nhân viên với email: " + email);
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Lỗi CSDL: " + e.getMessage());
        } catch (Exception e) {
            request.setAttribute("error", "Đã xảy ra lỗi: " + e.getMessage());
        } finally {
            try {
                if (rs != null) {
                    st = rs.getStatement();
                    rs.close();
                }
                if (st != null) {
                    st.close();
                }
            } catch (SQLException ignored) {
            }
            try {
                if (db != null) {
                    db.close();
                }
            } catch (Exception ignored) {
            }
        }

        // Quyết định trang đích theo vai trò
        String target = decideTargetByRole(vaiTroFromDb);
        forwardTo(request, response, target);
    }

    private String decideTargetByRole(String role) {
        if (role == null) {
            return "/user_profile.jsp";
        }
        String r = role.trim();
        // Admin hoặc Quản lý -> admin
        if ("Admin".equalsIgnoreCase(r) || "Quản lý".equalsIgnoreCase(r) || "Quan ly".equalsIgnoreCase(r)) {
            return "/admin_profile.jsp";
        }
        // Nhân viên -> user
        if ("Nhân viên".equalsIgnoreCase(r) || "Nhan vien".equalsIgnoreCase(r)) {
            return "/user_profile.jsp";
        }
        // Mặc định
        return "/user_profile.jsp";
    }

    private void forwardTo(HttpServletRequest request, HttpServletResponse response, String jspPath)
            throws ServletException, IOException {
        RequestDispatcher rd = request.getRequestDispatcher(jspPath);
        rd.forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "API Hồ sơ cá nhân - forward theo vai trò (Admin/Quản lý => admin, Nhân viên => user)";
    }
}
