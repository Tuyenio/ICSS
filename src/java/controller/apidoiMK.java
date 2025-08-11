/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

// import dao.KNCSDL; // nếu KNCSDL ở package khác thì import cho đúng
public class apidoiMK extends HttpServlet {

    private void writeText(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("text/plain; charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(message != null ? message : "");
            out.flush();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        String email = (session != null) ? (String) session.getAttribute("userEmail") : null;

        String oldPass = request.getParameter("old_password");
        String newPass = request.getParameter("new_password");
        String confirm = request.getParameter("confirm_password");

        // Validate cơ bản
        if (email == null || email.trim().isEmpty()) {
            writeText(response, 401, "Phiên đăng nhập hết hạn hoặc chưa đăng nhập.");
            return;
        }
        if (oldPass == null || newPass == null || confirm == null
                || oldPass.isBlank() || newPass.isBlank() || confirm.isBlank()) {
            writeText(response, 400, "Vui lòng nhập đầy đủ thông tin.");
            return;
        }
        if (!newPass.equals(confirm)) {
            writeText(response, 422, "Mật khẩu mới và xác nhận không khớp.");
            return;
        }
        if (newPass.length() < 8) {
            writeText(response, 422, "Mật khẩu mới phải tối thiểu 8 ký tự.");
            return;
        }
        if (newPass.equals(oldPass)) {
            writeText(response, 422, "Mật khẩu mới không được trùng mật khẩu cũ.");
            return;
        }

        KNCSDL db = null;
        try {
            db = new KNCSDL();

            boolean ok = db.doiMatKhau(email, oldPass, newPass); // kiểm tra cũ + cập nhật mới
            if (ok) {
                writeText(response, 200, "Đổi mật khẩu thành công.");
            } else {
                writeText(response, 400, "Mật khẩu cũ không đúng hoặc không thể cập nhật.");
            }

        } catch (Exception e) {
            writeText(response, 500, "Lỗi máy chủ: " + e.getMessage());
        } finally {
            if (db != null) {
                try {
                    db.close();
                } catch (Exception ignore) {
                }
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        writeText(response, 405, "Chỉ hỗ trợ phương thức POST.");
    }

    @Override
    public String getServletInfo() {
        return "API đổi mật khẩu: trả về text/plain, dùng HTTP status để báo kết quả";
    }
}
