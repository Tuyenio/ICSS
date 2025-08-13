package controller;

import java.io.IOException;
import java.io.PrintWriter;
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
        String tenNguoiGiao = getValue(request, "ten_nguoi_giao");
        String tenNguoiNhan = getValue(request, "ten_nguoi_nhan");
        String tenPhong = getValue(request, "ten_phong_ban");
        String trangThai = "Chưa bắt đầu";

        try {
            KNCSDL db = new KNCSDL();
            int giaoId = Integer.parseInt(tenNguoiGiao);
            int nhanId = Integer.parseInt(tenNguoiNhan);
            int phongId = Integer.parseInt(tenPhong);

            if (giaoId == -1 || nhanId == -1 || phongId == -1) {
                out.print("{\"success\": false, \"message\": \"Không tìm thấy ID cho người giao, người nhận hoặc nhóm.\"}");
                return;
            }

            db.insertTask(ten, moTa, han, uuTien, giaoId, nhanId, phongId, trangThai);
            String tieuDeTB = "Công việc mới";
            String noiDungTB = "Bạn được giao công việc: "+ ten + ". Hạn: " + han + ".";
            db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Công việc mới");
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
