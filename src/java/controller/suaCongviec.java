package controller;

import java.io.*;
import java.sql.SQLException;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

@MultipartConfig
public class suaCongviec extends HttpServlet {

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
            int nhomId = Integer.parseInt(tenPhong);

            if (id == null || id.trim().isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Thiếu ID để cập nhật.\"}");
                return;
            }

            db.updateTask(Integer.parseInt(id), ten, moTa, han, uuTien,
                    giaoId, nhanId, nhomId, trangThai, taiieu);

            String tieuDeTB = "Cập nhật công việc";
            String noiDungTB = "Công việc: " + ten + " vừa được cập nhật mới";
            db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Cập nhật");

            out.print("{\"success\": true}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    private String getValue(HttpServletRequest request, String fieldName) throws IOException, ServletException {
        if (request.getPart(fieldName) != null) {
            return new String(request.getPart(fieldName).getInputStream().readAllBytes(), "UTF-8");
        }
        return null;
    }
}
