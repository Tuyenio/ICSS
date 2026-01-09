package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet xử lý tất cả các thao tác liên quan đến Nhóm Tài Liệu Bao gồm: Xem
 * danh sách, Thêm, Sửa, Xóa nhóm tài liệu
 */
@WebServlet(name = "GroupDocumentServlet", urlPatterns = {"/dsNhomTailieu", "/themNhomTailieu", "/suaNhomTailieu", "/xoaNhomTailieu"})
public class GroupDocumentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();

        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            switch (path) {
                case "/dsNhomTailieu":
                    handleListGroups(request, response);
                    break;
                case "/xoaNhomTailieu":
                    handleDeleteGroup(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("documents.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();

        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            switch (path) {
                case "/themNhomTailieu":
                    handleAddGroup(request, response);
                    break;
                case "/suaNhomTailieu":
                    handleUpdateGroup(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("documents.jsp").forward(request, response);
        }
    }

    /**
     * Xử lý hiển thị danh sách nhóm tài liệu
     */
    private void handleListGroups(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        try {
            KNCSDL db = new KNCSDL();

            // Lấy danh sách tất cả nhóm tài liệu
            List<NhomTaiLieu> danhSachNhom = db.getAllNhomTaiLieu();

            request.setAttribute("danhSachNhom", danhSachNhom);
            request.getRequestDispatcher("documents.jsp").forward(request, response);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(GroupDocumentServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * Xử lý thêm nhóm tài liệu mới
     */
    private void handleAddGroup(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        try {

            HttpSession session = request.getSession();
            // Thử cả userID và userId
            Object userIdObj = session.getAttribute("userId");
            if (userIdObj == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            int userId;
            if (userIdObj instanceof Integer) {
                userId = (Integer) userIdObj;
            } else {
                userId = Integer.parseInt(userIdObj.toString());
            }

            // Lấy dữ liệu từ form
            String tenNhom = request.getParameter("tenNhom");
            String moTa = request.getParameter("moTa");
            String icon = request.getParameter("icon");
            String mauSac = request.getParameter("mauSac");
            String thuTuStr = request.getParameter("thuTu");
            String doiTuongXem = request.getParameter("doiTuongXem");

            int thuTu = 0;
            try {
                if (thuTuStr != null && !thuTuStr.isEmpty()) {
                    thuTu = Integer.parseInt(thuTuStr);
                }
            } catch (NumberFormatException e) {
                thuTu = 0;
            }

            // Validate
            if (tenNhom == null || tenNhom.trim().isEmpty()) {
                request.setAttribute("error", "Tên nhóm không được để trống!");
                handleListGroups(request, response);
                return;
            }

            // Tạo object NhomTaiLieu
            NhomTaiLieu ntl = new NhomTaiLieu();
            ntl.setTenNhom(tenNhom);
            ntl.setMoTa(moTa);
            ntl.setIcon(icon != null && !icon.isEmpty() ? icon : "fa-folder");
            ntl.setMauSac(mauSac != null && !mauSac.isEmpty() ? mauSac : "#3b82f6");
            ntl.setNguoiTaoId(userId);
            ntl.setThuTu(thuTu);
            ntl.setDoiTuongXem(doiTuongXem != null && !doiTuongXem.isEmpty() ? doiTuongXem : "Tất cả");

            // Lưu vào database
            KNCSDL db = new KNCSDL();
            int result = db.insertNhomTaiLieu(ntl);

            if (result > 0) {
                request.setAttribute("success", "Thêm nhóm tài liệu thành công!");
            } else {
                request.setAttribute("error", "Không thể thêm nhóm tài liệu!");
            }

            handleListGroups(request, response);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(GroupDocumentServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * Xử lý cập nhật nhóm tài liệu
     */
    private void handleUpdateGroup(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        try {

            // Lấy dữ liệu từ form
            String idStr = request.getParameter("id");
            String tenNhom = request.getParameter("tenNhom");
            String moTa = request.getParameter("moTa");
            String icon = request.getParameter("icon");
            String mauSac = request.getParameter("mauSac");
            String thuTuStr = request.getParameter("thuTu");
            String doiTuongXem = request.getParameter("doiTuongXem");

            // Validate
            if (idStr == null || tenNhom == null || tenNhom.trim().isEmpty()) {
                request.setAttribute("error", "Dữ liệu không hợp lệ!");
                handleListGroups(request, response);
                return;
            }

            int id = Integer.parseInt(idStr);
            int thuTu = 0;
            try {
                if (thuTuStr != null && !thuTuStr.isEmpty()) {
                    thuTu = Integer.parseInt(thuTuStr);
                }
            } catch (NumberFormatException e) {
                thuTu = 0;
            }

            // Tạo object NhomTaiLieu
            NhomTaiLieu ntl = new NhomTaiLieu();
            ntl.setId(id);
            ntl.setTenNhom(tenNhom);
            ntl.setMoTa(moTa);
            ntl.setIcon(icon);
            ntl.setMauSac(mauSac);
            ntl.setDoiTuongXem(doiTuongXem != null && !doiTuongXem.isEmpty() ? doiTuongXem : "Tất cả");
            ntl.setThuTu(thuTu);

            // Cập nhật database
            KNCSDL db = new KNCSDL();
            boolean success = db.updateNhomTaiLieu(ntl);

            if (success) {
                request.setAttribute("success", "Cập nhật nhóm tài liệu thành công!");
            } else {
                request.setAttribute("error", "Không thể cập nhật nhóm tài liệu!");
            }

            handleListGroups(request, response);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(GroupDocumentServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * Xử lý xóa nhóm tài liệu
     */
    private void handleDeleteGroup(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        try {
            String idStr = request.getParameter("id");

            if (idStr == null) {
                request.setAttribute("error", "ID nhóm không hợp lệ!");
                handleListGroups(request, response);
                return;
            }

            int id = Integer.parseInt(idStr);

            KNCSDL db = new KNCSDL();
            boolean success = db.deleteNhomTaiLieu(id);

            if (success) {
                request.setAttribute("success", "Xóa nhóm tài liệu thành công!");
            } else {
                request.setAttribute("error", "Không thể xóa nhóm tài liệu!");
            }

            handleListGroups(request, response);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(GroupDocumentServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
