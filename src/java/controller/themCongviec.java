package controller;

import java.io.*;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

@MultipartConfig
public class themCongviec extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        PrintWriter out = response.getWriter();

        String duan = getValue(request, "du_an_id");
        String ten = getValue(request, "ten_cong_viec");
        String moTa = getValue(request, "mo_ta");
        String han = getValue(request, "han_hoan_thanh");
        String uuTien = getValue(request, "muc_do_uu_tien");
        String tenNguoiGiao = getValue(request, "ten_nguoi_giao"); 
        String dsNguoiNhan = getValue(request, "ten_nguoi_nhan");  
        String tenPhong = getValue(request, "ten_phong_ban");
        String trangThai = "Chưa bắt đầu";
        String tailieu = getValue(request, "tai_lieu_cv"); // link driver

        try {
            KNCSDL db = new KNCSDL();
            int giaoId = Integer.parseInt(tenNguoiGiao);
            int phongId = Integer.parseInt(tenPhong);
            int duanid = Integer.parseInt(duan);

            if (giaoId == -1 || phongId == -1) {
                out.print("{\"success\": false, \"message\": \"Không tìm thấy ID cho người giao hoặc phòng ban.\"}");
                return;
            }

            // === 1. Lưu file đính kèm ===
            String uploadPath = System.getenv("ICSS_UPLOAD_DIR");
            if (uploadPath == null || uploadPath.trim().isEmpty()) {
                uploadPath = "D:/uploads"; // fallback khi local
            }

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            List<String> filePaths = new ArrayList<>();
            for (Part part : request.getParts()) {
                if ("files".equals(part.getName()) && part.getSize() > 0) {
                    String fileName = part.getSubmittedFileName();
                    String fullPath = uploadPath + File.separator + fileName;

                    try (InputStream fileContent = part.getInputStream();
                         FileOutputStream fos = new FileOutputStream(fullPath)) {
                        byte[] buffer = new byte[1024];
                        int bytesRead;
                        while ((bytesRead = fileContent.read(buffer)) != -1) {
                            fos.write(buffer, 0, bytesRead);
                        }
                    }

                    // Lưu đường dẫn tuyệt đối
                    filePaths.add(fullPath);
                }
            }

            // Ghép nhiều file bằng dấu ;
            String fileDinhKem = String.join(";", filePaths);

            // === 2. Thêm công việc mới (DB phải có thêm cột file_dinh_kem) ===
            int taskId = db.insertTask(duanid,ten, moTa, han, uuTien, giaoId, phongId, trangThai, tailieu, fileDinhKem);
            if (taskId <= 0) {
                out.print("{\"success\": false, \"message\": \"Không thể thêm công việc.\"}");
                return;
            }

            // === 3. Thêm người nhận + thông báo ===
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
        Part part = request.getPart(fieldName);
        if (part != null && part.getSize() > 0) {
            return new String(part.getInputStream().readAllBytes(), "UTF-8");
        }
        return null;
    }
}
