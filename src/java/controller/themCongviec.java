package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.MultipartConfig;

@MultipartConfig
public class themCongviec extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        PrintWriter out = response.getWriter();

        String ten = getValue(request, "ten_cong_viec");
        String moTa = getValue(request, "mo_ta");
        String han = getValue(request, "han_hoan_thanh");
        String uuTien = getValue(request, "muc_do_uu_tien");
        String tenNguoiGiao = getValue(request, "ten_nguoi_giao"); // đây là id
        String dsNguoiNhan = getValue(request, "ten_nguoi_nhan");  // danh sách tên: "Nguyễn Văn A,Trần Thị B"
        String tenPhong = getValue(request, "ten_phong_ban");
        String trangThai = "Chưa bắt đầu";
        String tailieu = getValue(request, "tai_lieu_cv");

        try {
            KNCSDL db = new KNCSDL();
            int giaoId = Integer.parseInt(tenNguoiGiao);
            int phongId = Integer.parseInt(tenPhong);

            if (giaoId == -1 || phongId == -1) {
                out.print("{\"success\": false, \"message\": \"Không tìm thấy ID cho người giao hoặc phòng ban.\"}");
                return;
            }

            // === 1. Thêm công việc mới ===
            int taskId = db.insertTask(ten, moTa, han, uuTien, giaoId, phongId, trangThai, tailieu);
            if (taskId <= 0) {
                out.print("{\"success\": false, \"message\": \"Không thể thêm công việc.\"}");
                return;
            }

            // === 2. Xử lý danh sách người nhận (theo tên) ===
            if (dsNguoiNhan != null && !dsNguoiNhan.trim().isEmpty()) {
                for (String tenNhan : dsNguoiNhan.split(",")) {
                    tenNhan = tenNhan.trim();
                    if (tenNhan.isEmpty()) continue;

                    int nhanId = db.getNhanVienIdByName(tenNhan);
                    if (nhanId > 0) {
                        db.addNguoiNhan(taskId, nhanId);
                        String tieuDeTB = "Công việc mới";
                        String noiDungTB = "Bạn được giao công việc: " + ten + ". Hạn: " + han + ".";
                        db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Công việc mới");
                    }
                }
            }

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
