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

        // Lấy tham số kiểu form-urlencoded
        String action = request.getParameter("action");       // archive | delete | restore | remind...
        String tinhTrang = request.getParameter("tinh_trang");   // "Lưu trữ" | "Đã xóa" | "NULL" (khi restore)
        String trangThai0 = request.getParameter("trang_thai");
        String nhacviec = request.getParameter("nhac_viec");
        String idParam = request.getParameter("task_id");

        // Với multipart parts (khi update nội dung/file), bạn vẫn đang dùng getValue(...)
        String id = (idParam != null) ? idParam : getValue(request, "task_id");

        try {
            if (id == null || id.trim().isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Thiếu ID để cập nhật.\"}");
                return;
            }
            int taskId = Integer.parseInt(id);
            KNCSDL db = new KNCSDL();

            // =========================
            // [A] NHÁNH XỬ LÝ HÀNH ĐỘNG NHANH (KHÔNG ĐỤNG TỚI UPLOAD)
            // =========================
            if (action != null && !action.trim().isEmpty()) {
                boolean ok = false;
                String msg = "Thao tác không hợp lệ";

                switch (action.toLowerCase()) {
                    case "archive": {
                        // tinh_trang = 'Lưu trữ'
                        ok = db.updateTinhTrang(taskId, "Lưu trữ");
                        msg = ok ? "Đã lưu trữ" : "Lưu trữ thất bại";
                        break;
                    }
                    case "delete": {
                        // tinh_trang = 'Đã xóa'
                        ok = db.updateTinhTrang(taskId, "Đã xóa");
                        msg = ok ? "Đã chuyển vào thùng rác" : "Xóa thất bại";
                        break;
                    }
                    case "restore": {
                        // tinh_trang = NULL, và set lại trạng_thái nghiệp vụ
                        ok = db.updateTinhTrang(taskId, null);
                        if (ok) {
                            String fallbackTrangThai = (trangThai0 != null && !trangThai0.isEmpty())
                                    ? trangThai0 : null; // VD: "Chưa bắt đầu"
                            if (fallbackTrangThai != null) {
                                ok = db.updateTrangThai(taskId, fallbackTrangThai);
                            }
                        }
                        msg = ok ? "Đã khôi phục" : "Khôi phục thất bại";
                        break;
                    }
                    case "remind": {
                        boolean okRemind = db.updateNhacViec(taskId, 1);
                        ok = okRemind;
                        msg = ok ? "Đã bật nhắc việc cho công việc này" : "Bật nhắc việc thất bại";
                        out.print("{\"success\":" + ok + ",\"message\":\"" + msg + "\"}");
                        return;
                    }
                    case "markremind": {
                        ok = db.updateNhacViec(taskId, 0);
                        msg = ok ? "Đã tắt nhắc việc cho công việc này" : "Tắt nhắc việc thất bại";
                        out.print("{\"success\":" + ok + ",\"message\":\"" + msg + "\"}");
                        return;
                    }
                }

                out.print("{\"success\":" + ok + ",\"message\":\"" + msg + "\"}");
                return; // ❗ KẾT THÚC ở đây, không đi tiếp xuống luồng upload/update
            }

            boolean chiUploadFile = (request.getParameter("chi_file") != null)
                    || (getValue(request, "ten_cong_viec") == null && getValue(request, "mo_ta") == null);

            String fileCu = db.getFileCongViec(taskId);
            if (fileCu == null) {
                fileCu = "";
            }

            // 1. Lưu file đính kèm
            String uploadPath = System.getenv("ICSS_UPLOAD_DIR");
            if (uploadPath == null || uploadPath.trim().isEmpty()) {
                uploadPath = "D:/uploads"; // fallback local
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
                    filePaths.add(fullPath.replace("\\", "/"));
                }
            }

            // 2. Nối file cũ và file mới
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
                String dsTenNguoiNhan = getValue(request, "ten_nguoi_nhan");
                String tenPhong = getValue(request, "ten_phong_ban");
                String trangThai = getValue(request, "trang_thai");
                String tailieu = getValue(request, "tai_lieu_cv");
                String file = getValue(request, "files");

                int giaoId = Integer.parseInt(tenNguoiGiao);
                int phongId = Integer.parseInt(tenPhong);

                // 2: Cập nhật task
                db.updateTask(taskId, ten, moTa, han, uuTien, giaoId, phongId, trangThai, tailieu, fileFinal);

                // 3: Cập nhật người nhận
                List<Integer> danhSachIdNhan = db.layIdTuDanhSachTen(dsTenNguoiNhan);
                db.capNhatDanhSachNguoiNhan(taskId, danhSachIdNhan);

                // 4: Gửi thông báo
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
