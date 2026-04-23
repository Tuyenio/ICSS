package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class dsTaiSan extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        List<Map<String, Object>> danhSach = new ArrayList<>();
        try {
            KNCSDL db = new KNCSDL();
            danhSach = db.getDanhSachTaiSan();
            db.close();
        } catch (ClassNotFoundException | SQLException e) {
            request.setAttribute("error", "Không tải được danh sách tài sản: " + e.getMessage());
        }

        request.setAttribute("danhSachTaiSan", danhSach);
        request.setAttribute("success", request.getParameter("success"));
        request.setAttribute("error", request.getAttribute("error") != null ? request.getAttribute("error") : request.getParameter("error"));
        request.getRequestDispatcher("asset.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        String vaiTro = (session != null && session.getAttribute("vaiTro") != null)
                ? session.getAttribute("vaiTro").toString()
                : "";

        if (!("Admin".equalsIgnoreCase(vaiTro) || "Quản lý".equalsIgnoreCase(vaiTro) || "Quan ly".equalsIgnoreCase(vaiTro))) {
            response.sendRedirect("404.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect("dsTaiSan?error=" + URLEncoder.encode("Thiếu thao tác", "UTF-8"));
            return;
        }

        try {
            KNCSDL db = new KNCSDL();

            if ("add".equalsIgnoreCase(action)) {
                String tenTaiSan = safe(request.getParameter("ten_tai_san"));
                int soLuong = parseInt(request.getParameter("so_luong"), 0);
                String tinhTrang = safe(request.getParameter("tinh_trang"));
                double giaCa = parseDouble(request.getParameter("gia_ca"), 0);
                String baoHanh = safe(request.getParameter("bao_hanh"));
                String moTa = safe(request.getParameter("mo_ta"));

                if (tenTaiSan.isEmpty()) {
                    response.sendRedirect("dsTaiSan?error=" + URLEncoder.encode("Tên tài sản không được để trống", "UTF-8"));
                    return;
                }

                db.themTaiSan(tenTaiSan, soLuong, tinhTrang, giaCa, baoHanh, moTa);
                db.close();
                response.sendRedirect("dsTaiSan?success=" + URLEncoder.encode("Đã thêm tài sản mới", "UTF-8"));
                return;
            }

            if ("update".equalsIgnoreCase(action)) {
                int id = parseInt(request.getParameter("id"), -1);
                String tenTaiSan = safe(request.getParameter("ten_tai_san"));
                int soLuong = parseInt(request.getParameter("so_luong"), 0);
                String tinhTrang = safe(request.getParameter("tinh_trang"));
                double giaCa = parseDouble(request.getParameter("gia_ca"), 0);
                String baoHanh = safe(request.getParameter("bao_hanh"));
                String moTa = safe(request.getParameter("mo_ta"));

                if (id <= 0 || tenTaiSan.isEmpty()) {
                    response.sendRedirect("dsTaiSan?error=" + URLEncoder.encode("Dữ liệu cập nhật không hợp lệ", "UTF-8"));
                    return;
                }

                db.capNhatTaiSan(id, tenTaiSan, soLuong, tinhTrang, giaCa, baoHanh, moTa);
                db.close();
                response.sendRedirect("dsTaiSan?success=" + URLEncoder.encode("Đã cập nhật tài sản", "UTF-8"));
                return;
            }

            if ("delete".equalsIgnoreCase(action)) {
                int id = parseInt(request.getParameter("id"), -1);
                if (id <= 0) {
                    response.sendRedirect("dsTaiSan?error=" + URLEncoder.encode("ID tài sản không hợp lệ", "UTF-8"));
                    return;
                }

                db.xoaTaiSan(id);
                db.close();
                response.sendRedirect("dsTaiSan?success=" + URLEncoder.encode("Đã xóa tài sản", "UTF-8"));
                return;
            }

            db.close();
            response.sendRedirect("dsTaiSan?error=" + URLEncoder.encode("Thao tác không hợp lệ", "UTF-8"));
        } catch (ClassNotFoundException | SQLException e) {
            response.sendRedirect("dsTaiSan?error=" + java.net.URLEncoder.encode("Lỗi xử lý tài sản: " + e.getMessage(), "UTF-8"));
        }
    }

    private static String safe(String s) {
        return s == null ? "" : s.trim();
    }

    private static int parseInt(String s, int dft) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return dft;
        }
    }

    private static double parseDouble(String s, double dft) {
        try {
            return Double.parseDouble(s);
        } catch (Exception e) {
            return dft;
        }
    }

    @Override
    public String getServletInfo() {
        return "Quản lý tài sản";
    }
}
