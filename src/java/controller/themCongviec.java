package controller;

import java.io.*;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 20 * 1024 * 1024, // 20MB
        maxRequestSize = 100 * 1024 * 1024 // 100MB
)
public class themCongviec extends HttpServlet {

    private static final long MAX_FILE_BYTES = 20L * 1024L * 1024L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        PrintWriter out = response.getWriter();

        String duan = getValue(request, "du_an_id");
        String ten = getValue(request, "ten_cong_viec");
        String moTa = getValue(request, "mo_ta");
        String ngaybd = getValue(request, "ngay_bat_dau");
        String han = getValue(request, "han_hoan_thanh");
        String uuTien = getValue(request, "muc_do_uu_tien");
        String tenNguoiGiao = getValue(request, "ten_nguoi_giao");
        String dsNguoiNhan = getValue(request, "ten_nguoi_nhan");
        String dsNguoiTheoDoi = getValue(request, "ten_nguoi_theo_doi");
        String tenPhong = getValue(request, "ten_phong_ban");
        String trangThai = "Chưa bắt đầu";
        String tailieu = getValue(request, "tai_lieu_cv"); // link driver

        try {
            KNCSDL db = new KNCSDL();

            if (duan == null) {
                duan = request.getParameter("du_an_id");
            }
            if (ten == null) {
                ten = request.getParameter("ten_cong_viec");
            }
            if (moTa == null) {
                moTa = request.getParameter("mo_ta");
            }
            if (ngaybd == null) {
                ngaybd = request.getParameter("ngay_bat_dau");
            }
            if (han == null) {
                han = request.getParameter("han_hoan_thanh");
            }
            if (uuTien == null) {
                uuTien = request.getParameter("muc_do_uu_tien");
            }
            if (tenNguoiGiao == null) {
                tenNguoiGiao = request.getParameter("ten_nguoi_giao");
            }
            if (dsNguoiNhan == null) {
                dsNguoiNhan = request.getParameter("ten_nguoi_nhan");
            }
            if (dsNguoiTheoDoi == null) {
                dsNguoiTheoDoi = request.getParameter("ten_nguoi_theo_doi");
            }
            if (tenPhong == null) {
                tenPhong = request.getParameter("ten_phong_ban");
            }
            if (tailieu == null) {
                tailieu = request.getParameter("tai_lieu_cv");
            }

            // Kiểm tra trường bắt buộc
            List<String> missing = new ArrayList<>();
            if (ten == null || ten.trim().isEmpty()) {
                missing.add("Tên công việc");
            }
            if (duan == null || duan.trim().isEmpty()) {
                missing.add("Dự án");
            }
            if (tenNguoiGiao == null || tenNguoiGiao.trim().isEmpty()) {
                missing.add("Người giao");
            }
            if (tenPhong == null || tenPhong.trim().isEmpty()) {
                missing.add("Phòng ban");
            }

            if (!missing.isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Vui lòng nhập: " + String.join(", ", missing) + "\"}");
                return;
            }

            int giaoId;
            int phongId;
            int duanid;
            try {
                giaoId = Integer.parseInt(tenNguoiGiao);
            } catch (NumberFormatException ex) {
                out.print("{\"success\": false, \"message\": \"Người giao không hợp lệ. Vui lòng chọn lại.\"}");
                return;
            }
            try {
                phongId = Integer.parseInt(tenPhong);
            } catch (NumberFormatException ex) {
                out.print("{\"success\": false, \"message\": \"Phòng ban không hợp lệ. Vui lòng chọn lại.\"}");
                return;
            }
            try {
                duanid = Integer.parseInt(duan);
            } catch (NumberFormatException ex) {
                out.print("{\"success\": false, \"message\": \"Dự án không hợp lệ. Vui lòng chọn lại.\"}");
                return;
            }

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
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            List<String> filePaths = new ArrayList<>();

            try {
                Collection<Part> parts = request.getParts();
                for (Part part : parts) {
                    // chỉ xử lý các input có name="files"
                    if (!"files".equals(part.getName()) || part.getSize() <= 0) {
                        continue;
                    }

                    // kiểm tra kích thước file trước khi lưu
                    if (part.getSize() > MAX_FILE_BYTES) {
                        out.print("{\"success\": false, \"message\": \"Kích thước file quá lớn. Tối đa 10MB cho mỗi file.\"}");
                        return;
                    }

                    String origName = part.getSubmittedFileName();
                    String safeName = makeSafeFileName(origName);
                    // đảm bảo tên duy nhất tránh đè
                    String uniqueName = System.currentTimeMillis() + "_" + UUID.randomUUID().toString() + "_" + safeName;
                    String fullPath = uploadPath + File.separator + uniqueName;

                    try (InputStream fileContent = part.getInputStream(); FileOutputStream fos = new FileOutputStream(fullPath)) {
                        byte[] buffer = new byte[8192];
                        int bytesRead;
                        while ((bytesRead = fileContent.read(buffer)) != -1) {
                            fos.write(buffer, 0, bytesRead);
                        }
                    }

                    // Lưu đường dẫn tuyệt đối
                    filePaths.add(fullPath);
                }
            } catch (IllegalStateException ex) {
                // Có thể do vượt giới hạn multipart
                ex.printStackTrace();
                out.print("{\"success\": false, \"message\": \"Yêu cầu upload vượt quá giới hạn cho phép (10MB/file).\"}");
                return;
            }

            // Ghép nhiều file bằng dấu ;
            String fileDinhKem = String.join(";", filePaths);

            // === 2. Thêm công việc mới (DB phải có thêm cột file_dinh_kem) ===
            int taskId = db.insertTask(duanid, ten, moTa, ngaybd, han, uuTien, giaoId, phongId, trangThai, tailieu, fileDinhKem);
            if (taskId <= 0) {
                out.print("{\"success\": false, \"message\": \"Không thể thêm công việc.\"}");
                return;
            }

            // === 3. Thêm người nhận + thông báo ===
            if (dsNguoiNhan != null && !dsNguoiNhan.trim().isEmpty()) {
                for (String tenNhan : dsNguoiNhan.split(",")) {
                    tenNhan = tenNhan.trim();
                    if (tenNhan.isEmpty()) {
                        continue;
                    }
                    int nhanId = db.getNhanVienIdByName(tenNhan);
                    if (nhanId > 0) {
                        db.addNguoiNhan(taskId, nhanId);
                        String tieuDeTB = "Công việc mới";
                        String noiDungTB = "Bạn được giao công việc: " + ten + ". Hạn: " + han + ".";
                        String role = db.getVaiTroById(nhanId);
                        String link = "";
                        if (role != null && (role.equalsIgnoreCase("Admin") || role.equalsIgnoreCase("Quản lý"))) {
                            link = "dsCongviec?taskId=" + taskId;
                        } else {
                            link = "dsCongviecNV?taskId=" + taskId;
                        }
                        db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Công việc mới", link);
                    }
                }
            }

            // === 4. Thêm người theo dõi + thông báo ===
            if (dsNguoiTheoDoi != null && !dsNguoiTheoDoi.trim().isEmpty()) {
                for (String tenTheo : dsNguoiTheoDoi.split(",")) {
                    tenTheo = tenTheo.trim();
                    if (tenTheo.isEmpty()) {
                        continue;
                    }
                    int theoId = db.getNhanVienIdByName(tenTheo);
                    if (theoId > 0) {
                        db.addNguoiTheoDoi(taskId, theoId);
                        String tieuDeTB = "Công việc mới cần theo dõi";
                        String noiDungTB = "Bạn đang theo dõi công việc: " + ten + ". Hạn: " + han + ".";
                        String role = db.getVaiTroById(theoId);
                        String link = "";
                        if (role != null && (role.equalsIgnoreCase("Admin") || role.equalsIgnoreCase("Quản lý"))) {
                            link = "dsCongviec?taskId=" + taskId;
                        } else {
                            link = "dsCongviecNV?taskId=" + taskId;
                        }
                        db.insertThongBao(theoId, tieuDeTB, noiDungTB, "Công việc mới", link);
                    }
                }
            }

            // === 5. Ghi log lịch sử tạo công việc ===
            HttpSession session = request.getSession(false);
            int userId = 0;
            if (session != null && session.getAttribute("userId") != null) {
                try {
                    userId = Integer.parseInt(session.getAttribute("userId").toString());
                } catch (Exception e) {
                }
            }
            if (userId > 0) {
                String logMsg = "🆕 Tạo mới công việc: '" + ten + "' | Deadline: " + han + " | Độ ưu tiên: " + uuTien;
                if (dsNguoiNhan != null && !dsNguoiNhan.trim().isEmpty()) {
                    logMsg += " | Người nhận: " + dsNguoiNhan;
                }
                if (dsNguoiTheoDoi != null && !dsNguoiTheoDoi.trim().isEmpty()) {
                    logMsg += " | Người theo dõi: " + dsNguoiTheoDoi;
                }
                db.themLichSuCongViec(taskId, userId, logMsg);
            }

            out.print("{\"success\": true}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    private String getValue(HttpServletRequest request, String fieldName) throws IOException, ServletException {
        try {
            Part part = request.getPart(fieldName);
            if (part != null && part.getSize() > 0) {
                return new String(part.getInputStream().readAllBytes(), "UTF-8");
            }
        } catch (IllegalStateException | IOException | ServletException ignored) {
            // nếu không lấy được Part thì fallback xuống parameter
        }
        String param = request.getParameter(fieldName);
        return param != null ? param : null;
    }

    // sanitize filename: remove path, invalid chars, trailing dots/spaces
    private String makeSafeFileName(String filename) {
        if (filename == null || filename.trim().isEmpty()) {
            return "file";
        }
        // lấy tên base
        String name = new File(filename).getName();

        // thay ký tự bất hợp lệ trên Windows/Unix thành _
        name = name.replaceAll("[\\\\/:*?\"<>|]", "_");

        // loại bỏ dấu chấm hoặc khoảng trắng ở cuối (Windows không cho phép)
        while (name.endsWith(".") || name.endsWith(" ")) {
            name = name.substring(0, name.length() - 1);
            if (name.isEmpty()) {
                break;
            }
        }

        // nếu sau sanitize rỗng -> đặt tên mặc định
        if (name.isEmpty()) {
            name = "file";
        }

        return name;
    }
}
