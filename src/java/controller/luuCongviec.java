package controller;

import java.io.*;
import java.sql.SQLException;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

@MultipartConfig
public class luuCongviec extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String id = getValue(request, "task_id");
        String ten = getValue(request, "ten_cong_viec");
        String moTa = getValue(request, "mo_ta");
        String han = getValue(request, "han_hoan_thanh");
        String uuTien = getValue(request, "muc_do_uu_tien");
        String tenNguoiGiao = getValue(request, "ten_nguoi_giao");
        String tenNguoiNhan = getValue(request, "ten_nguoi_nhan");
        String tenPhong = getValue(request, "ten_phong_ban");
        String trangThai = getValue(request, "trang_thai");
        String taiieu = getValue(request, "tai_lieu_cv");

        try {
            KNCSDL db = new KNCSDL();

            int giaoId = Integer.parseInt(tenNguoiGiao);
            int nhanId = Integer.parseInt(tenNguoiNhan);
            int phongId = Integer.parseInt(tenPhong);

            if (giaoId == -1 || nhanId == -1 || phongId == -1) {
                out.print("{\"success\": false, \"message\": \"Không tìm thấy ID cho người giao, người nhận hoặc nhóm.\"}");
                return;
            }

            if (id != null && !id.trim().isEmpty()) {
                db.updateTask(Integer.parseInt(id), ten, moTa, han, uuTien,
                        giaoId, nhanId, phongId, trangThai, taiieu);
                db.insertThongBao(nhanId, "Cập nhật công việc", "Công việc: " + ten + " vừa được cập nhật.", "Cập nhật");
            } else {
                db.insertTask(ten, moTa, han, uuTien,
                        giaoId, nhanId, phongId, trangThai, taiieu);
                db.insertThongBao(nhanId, "Công việc mới", "Bạn được giao công việc: " + ten + ". Hạn: " + han, "Công việc mới");
            }

            out.print("{\"success\": true}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    private String getValue(HttpServletRequest request, String fieldName) throws IOException, ServletException {
        Part part = request.getPart(fieldName);
        if (part != null) {
            return new String(part.getInputStream().readAllBytes(), "UTF-8");
        }
        return null;
    }
}
