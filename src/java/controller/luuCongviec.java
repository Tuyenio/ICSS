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
        String danhSachNguoiNhan = getValue(request, "ten_nguoi_nhan"); // chuỗi "1,2,3"
        String tenPhong = getValue(request, "ten_phong_ban");
        String trangThai = getValue(request, "trang_thai");
        String taiLieu = getValue(request, "tai_lieu_cv");

        try {
            KNCSDL db = new KNCSDL();

            int giaoId = Integer.parseInt(tenNguoiGiao);
            int phongId = Integer.parseInt(tenPhong);

            if (giaoId == -1 || phongId == -1) {
                out.print("{\"success\": false, \"message\": \"Không tìm thấy ID cho người giao hoặc phòng ban.\"}");
                return;
            }

            // Danh sách người nhận
            List<Integer> listNguoiNhan = new ArrayList<>();
            if (danhSachNguoiNhan != null && !danhSachNguoiNhan.trim().isEmpty()) {
                for (String s : danhSachNguoiNhan.split(",")) {
                    try {
                        int idNhan = Integer.parseInt(s.trim());
                        listNguoiNhan.add(idNhan);
                    } catch (NumberFormatException ex) {
                        // Nếu dữ liệu không phải số thì bỏ qua
                    }
                }
            }

            if (id != null && !id.trim().isEmpty()) {
                // === Update task ===
                int taskId = Integer.parseInt(id);
//                db.updateTask(taskId, ten, moTa, han, uuTien,
//                        giaoId, phongId, trangThai, taiLieu);

                // Xoá người nhận cũ và thêm lại
                db.clearNguoiNhan(taskId);
                for (int nhanId : listNguoiNhan) {
                    db.addNguoiNhan(taskId, nhanId);
                    db.insertThongBao(nhanId, "Cập nhật công việc", "Công việc: " + ten + " vừa được cập nhật.", "Cập nhật");
                }

            } else {
                // === Insert task mới ===
                int taskId = db.insertTask(ten, moTa, han, uuTien,
                        giaoId, phongId, trangThai, taiLieu);

                for (int nhanId : listNguoiNhan) {
                    db.addNguoiNhan(taskId, nhanId);
                    db.insertThongBao(nhanId, "Công việc mới", "Bạn được giao công việc: " + ten + ". Hạn: " + han, "Công việc mới");
                }
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
