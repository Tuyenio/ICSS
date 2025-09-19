package controller;

import java.io.*;
import java.nio.file.*;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;
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
        try {
            KNCSDL db = new KNCSDL();
            int taskId = Integer.parseInt(id);

            if (id == null || id.trim().isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Thiếu ID để cập nhật.\"}");
                return;
            }

            boolean chiUploadFile = (request.getParameter("chi_file") != null)
                    || (getValue(request, "ten_cong_viec") == null && getValue(request, "mo_ta") == null);

            String fileCu = db.getFileCongViec(taskId);
            if (fileCu == null) {
                fileCu = "";
            }

            // === 1. Lưu file đính kèm ===
            String uploadPath = System.getenv("ICSS_UPLOAD_DIR");
            if (uploadPath == null || uploadPath.trim().isEmpty()) {
                uploadPath = "D:/uploads"; // fallback khi local
            }

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            List<String> filePaths = new ArrayList<>();
            for (Part part : request.getParts()) {
                if ("files".equals(part.getName()) && part.getSize() > 0) {
                    String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                    String fullPath = uploadPath + File.separator + fileName;

                    try (InputStream fileContent = part.getInputStream(); FileOutputStream fos = new FileOutputStream(fullPath)) {
                        byte[] buffer = new byte[1024];
                        int bytesRead;
                        while ((bytesRead = fileContent.read(buffer)) != -1) {
                            fos.write(buffer, 0, bytesRead);
                        }
                    }

                    filePaths.add(fullPath.replace("\\", "/")); // Lưu path dùng dấu / để đồng nhất
                }
            }

            // === 2. Nối file cũ và file mới ===
            String fileFinal = fileCu;
            if (!filePaths.isEmpty()) {
                String moi = String.join(";", filePaths);
                if (!fileFinal.isEmpty()) {
                    fileFinal += ";" + moi;
                } else {
                    fileFinal = moi;
                }
            }

            if (chiUploadFile) {
                db.updateFileCongViec(taskId, fileFinal);
            } else {
                String ten = getValue(request, "ten_cong_viec");
                String moTa = getValue(request, "mo_ta");
                String han = getValue(request, "han_hoan_thanh");
                String uuTien = getValue(request, "muc_do_uu_tien");
                String tenNguoiGiao = getValue(request, "ten_nguoi_giao");
                String dsTenNguoiNhan = getValue(request, "ten_nguoi_nhan"); // danh sách tên, phân cách dấu ,
                String tenPhong = getValue(request, "ten_phong_ban");
                String trangThai = getValue(request, "trang_thai");
                String tailieu = getValue(request, "tai_lieu_cv");
                String file = getValue(request, "files");

                int giaoId = Integer.parseInt(tenNguoiGiao);
                int phongId = Integer.parseInt(tenPhong);
                // --- BƯỚC 2: CẬP NHẬT TASK ---
                db.updateTask(taskId, ten, moTa, han, uuTien, giaoId, phongId, trangThai, tailieu, fileFinal);

                // --- BƯỚC 3: XỬ LÝ NGƯỜI NHẬN ---
                List<Integer> danhSachIdNhan = db.layIdTuDanhSachTen(dsTenNguoiNhan);  // tên → list id
                db.capNhatDanhSachNguoiNhan(taskId, danhSachIdNhan);

                // --- BƯỚC 4: GỬI THÔNG BÁO ---
                for (int nhanId : danhSachIdNhan) {
                    String tieuDeTB = "Cập nhật công việc";
                    String noiDungTB = "Công việc: " + ten + " vừa được cập nhật mới";
                    db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Cập nhật");
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
