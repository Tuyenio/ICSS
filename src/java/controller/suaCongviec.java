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

            // Lấy thông tin user từ session
            HttpSession session = request.getSession(false);
            int userId = 0;
            if (session != null && session.getAttribute("userId") != null) {
                try {
                    userId = Integer.parseInt(session.getAttribute("userId").toString());
                } catch (Exception e) {
                    // Nếu không lấy được userId, để mặc định là 0
                }
            }

            // =========================
            // [A] NHÁNH XỬ LÝ HÀNH ĐỘNG NHANH (KHÔNG ĐỤNG TỚI UPLOAD)
            // =========================
            if (action != null && !action.trim().isEmpty()) {
                boolean ok = false;
                String msg = "Thao tác không hợp lệ";
                String lichSuMoTa = "";

                switch (action.toLowerCase()) {
                    case "archive": {
                        // tinh_trang = 'Lưu trữ'
                        ok = db.updateTinhTrang(taskId, "Lưu trữ");
                        msg = ok ? "Đã lưu trữ" : "Lưu trữ thất bại";
                        lichSuMoTa = "Lưu trữ công việc";
                        break;
                    }
                    case "delete": {
                        // tinh_trang = 'Đã xóa'
                        ok = db.updateTinhTrang(taskId, "Đã xóa");
                        msg = ok ? "Đã chuyển vào thùng rác" : "Xóa thất bại";
                        lichSuMoTa = "Xóa công việc";
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
                        lichSuMoTa = "Khôi phục công việc";
                        break;
                    }
                    case "remind": {
                        boolean okRemind = db.updateNhacViec(taskId, 1);
                        ok = okRemind;
                        msg = ok ? "Đã bật nhắc việc cho công việc này" : "Bật nhắc việc thất bại";
                        lichSuMoTa = "Bật nhắc việc";
                        if (ok && userId > 0) {
                            db.themLichSuCongViec(taskId, userId, lichSuMoTa);
                        }
                        out.print("{\"success\":" + ok + ",\"message\":\"" + msg + "\"}");
                        return;
                    }
                    case "markremind": {
                        ok = db.updateNhacViec(taskId, 0);
                        msg = ok ? "Đã tắt nhắc việc cho công việc này" : "Tắt nhắc việc thất bại";
                        lichSuMoTa = "Tắt nhắc việc";
                        if (ok && userId > 0) {
                            db.themLichSuCongViec(taskId, userId, lichSuMoTa);
                        }
                        out.print("{\"success\":" + ok + ",\"message\":\"" + msg + "\"}");
                        return;
                    }
                    case "updatedeadline": {
                        String newDeadline = request.getParameter("han_hoan_thanh");
                        if (newDeadline != null && !newDeadline.trim().isEmpty()) {
                            ok = db.updateDeadline(taskId, newDeadline);
                            msg = ok ? "Đã cập nhật deadline" : "Cập nhật deadline thất bại";
                            lichSuMoTa = "Cập nhật deadline thành: " + newDeadline;
                            if (ok) {
                                try {
                                    db.capNhatTrangThaiTuTienDo(taskId);
                                } catch (Exception ex) {
                                    ex.printStackTrace();
                                }
                            }
                        } else {
                            ok = false;
                            msg = "Deadline không hợp lệ";
                        }
                        if (ok && userId > 0) {
                            db.themLichSuCongViec(taskId, userId, lichSuMoTa);
                        }
                        out.print("{\"success\":" + ok + ",\"message\":\"" + msg + "\"}");
                        return;
                    }
                    case "extend": {
                        String newGiaHan = request.getParameter("ngay_gia_han");
                        String lyDoGiaHan = request.getParameter("ly_do_gia_han");

                        Map<String, Object> taskInfo = db.getCongViecById(taskId);
                        String tenCV = taskInfo != null && taskInfo.get("ten_cong_viec") != null
                                ? taskInfo.get("ten_cong_viec").toString()
                                : ("#" + taskId);

                        // ❗ KHÔNG UPDATE deadline ở đây nữa
                        boolean updated = true; // chỉ để flow không lỗi

                        // Ghi lịch sử yêu cầu gia hạn
                        if (userId > 0) {
                            db.themLichSuCongViec(taskId, userId,
                                    "Yêu cầu gia hạn đến: " + newGiaHan
                                    + (lyDoGiaHan != null && !lyDoGiaHan.isEmpty() ? (" | Lý do: " + lyDoGiaHan) : "")
                            );
                        }

                        // Gửi thông báo tới user ID = 4 để DUYỆT
                        try {
                            String tieuDeTB = "Yêu cầu gia hạn: " + tenCV;
                            String noiDung = "Công việc \"" + tenCV + "\" yêu cầu gia hạn đến: " + newGiaHan;
                            if (lyDoGiaHan != null && !lyDoGiaHan.trim().isEmpty()) {
                                noiDung += " | Lý do: " + lyDoGiaHan;
                            }

                            // user 4 bấm duyệt → mở giao diện chi tiết để xử lý
                            String link = "dsCongviec?taskId=" + taskId + "&duyet_gia_han=1" + "&ngay_gia_han=" + newGiaHan;
                            db.insertThongBao(4, tieuDeTB, noiDung, "Gia hạn", link);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }

                        out.print("{\"success\": true, \"message\": \"Đã gửi yêu cầu gia hạn để duyệt\"}");
                        return;
                    }
                    case "approveextend": {
                        String newDeadline = request.getParameter("new_deadline");
                        boolean ok2 = db.updateDeadline(taskId, newDeadline);
                        db.giaHanCongViec(taskId, newDeadline, userId);

                        if (ok2 && userId > 0) {
                            db.themLichSuCongViec(taskId, userId, "Duyệt gia hạn đến: " + newDeadline);
                        }

                        out.print("{\"success\":" + ok2 + ",\"message\":\""
                                + (ok2 ? "Đã duyệt gia hạn" : "Duyệt thất bại")
                                + "\"}");
                        return;
                    }
                }

                // Ghi log lịch sử cho các action khác (archive, delete, restore)
                if (ok && userId > 0 && !lichSuMoTa.isEmpty()) {
                    db.themLichSuCongViec(taskId, userId, lichSuMoTa);
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
                // Cập nhật trạng thái ngay sau khi thay đổi file (nếu file ảnh hưởng tiến độ/hạn)
                try {
                    db.capNhatTrangThaiTuTienDo(taskId);
                } catch (Exception ex) {
                    // không block response nếu cập nhật trạng thái thất bại
                    ex.printStackTrace();
                }
                // Ghi log upload file
                if (userId > 0 && !filePaths.isEmpty()) {
                    String fileNames = filePaths.stream()
                            .map(p -> p.substring(p.lastIndexOf("/") + 1))
                            .reduce((a, b) -> a + ", " + b)
                            .orElse("");
                    db.themLichSuCongViec(taskId, userId, "Tải lên tài liệu: " + fileNames);
                }
            } else {
                // Lấy thông tin công việc cũ để so sánh
                Map<String, Object> taskCu = db.getCongViecById(taskId);
                String nguoiNhanCu = db.getDanhSachNguoiNhan(taskId);

                String ten = getValue(request, "ten_cong_viec");
                
                // ✅ VALIDATION: Tên công việc không được rỗng
                if (ten == null || ten.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"❌ Tên công việc không được để trống!\"}");
                    return;
                }
                
                String moTa = getValue(request, "mo_ta");
                String ngaybd = getValue(request, "ngay_bat_dau");
                String han = getValue(request, "han_hoan_thanh");
                String uuTien = getValue(request, "muc_do_uu_tien");
                String tenNguoiGiao = getValue(request, "ten_nguoi_giao");
                String dsTenNguoiNhan = getValue(request, "ten_nguoi_nhan");
                String dsTenNguoiTheoDoi = getValue(request, "ten_nguoi_theo_doi");
                String tenPhong = getValue(request, "ten_phong_ban");
                String trangThai = getValue(request, "trang_thai");
                String tailieu = getValue(request, "tai_lieu_cv");
                String file = getValue(request, "files");

                if (trangThai == null || trangThai.trim().isEmpty()) {
                    Object trangThaiCu = taskCu.get("trang_thai");
                    trangThai = (trangThaiCu == null) ? "Chưa bắt đầu" : String.valueOf(trangThaiCu);
                }

                int giaoId;
                if (isNumeric(tenNguoiGiao)) {
                    giaoId = Integer.parseInt(tenNguoiGiao);
                } else {
                    giaoId = db.getNhanVienIdByName(tenNguoiGiao);
                }

                int phongId;
                if (isNumeric(tenPhong)) {
                    phongId = Integer.parseInt(tenPhong);
                } else {
                    phongId = db.getPhongIdByName(tenPhong);
                }

                // 2: Cập nhật task
                db.updateTask(taskId, ten, moTa, ngaybd, han, uuTien, giaoId, phongId, trangThai, tailieu, fileFinal);
                // Cập nhật trạng thái dựa trên tiến độ/quy trình/hạn ngay sau khi update task
                try {
                    db.capNhatTrangThaiTuTienDo(taskId);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                // 3: Cập nhật người nhận
                List<Integer> danhSachIdNhan = db.layIdTuDanhSachTen(dsTenNguoiNhan);
                db.capNhatDanhSachNguoiNhan(taskId, danhSachIdNhan);

                // 4: Gửi thông báo
                for (int nhanId : danhSachIdNhan) {
                    String tieuDeTB = "Cập nhật công việc";
                    String noiDungTB = "Công việc: " + ten + " vừa được cập nhật mới";
                    String role = db.getVaiTroById(nhanId);
                    String link = "";

                    // 🔥 Nếu là Admin hoặc Quản lý → vào giao diện Admin
                    if (role != null && (role.equalsIgnoreCase("Admin") || role.equalsIgnoreCase("Quản lý"))) {
                        link = "dsCongviec?taskId=" + taskId;
                    } else {
                        // 🔥 Ngược lại nhân viên dùng giao diện của NV
                        link = "dsCongviecNV?taskId=" + taskId;
                    }
                    db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Cập nhật", link);
                }

                // 4b: Cập nhật người theo dõi + thông báo
                if (dsTenNguoiTheoDoi == null) dsTenNguoiTheoDoi = "";
                List<Integer> danhSachIdTheoDoi = db.layIdTuDanhSachTen(dsTenNguoiTheoDoi);
                db.capNhatDanhSachNguoiTheoDoi(taskId, danhSachIdTheoDoi);
                for (int theoId : danhSachIdTheoDoi) {
                    String tieuDeTBTheo = "Cập nhật công việc";
                    String noiDungTBTheo = "Công việc bạn đang theo dõi: " + ten + " vừa được cập nhật.";
                    String roleTheo = db.getVaiTroById(theoId);
                    String linkTheo = "";
                    if (roleTheo != null && (roleTheo.equalsIgnoreCase("Admin") || roleTheo.equalsIgnoreCase("Quản lý"))) {
                        linkTheo = "dsCongviec?taskId=" + taskId;
                    } else {
                        linkTheo = "dsCongviecNV?taskId=" + taskId;
                    }
                    db.insertThongBao(theoId, tieuDeTBTheo, noiDungTBTheo, "Cập nhật", linkTheo);
                }

                // 5: Ghi lịch sử thay đổi CHI TIẾT từng trường
                if (userId > 0 && taskCu != null) {
                    List<String> thayDoiList = new ArrayList<>();

                    // So sánh tên công việc
                    String tenCu = (String) taskCu.get("ten_cong_viec");
                    if (!safeStringEquals(tenCu, ten)) {
                        thayDoiList.add("📝 Đổi tên: '" + (tenCu != null ? tenCu : "(trống)") + "' → '" + ten + "'");
                    }

                    // So sánh mô tả
                    String moTaCu = (String) taskCu.get("mo_ta");
                    if (!safeStringEquals(moTaCu, moTa)) {
                        thayDoiList.add("📄 Cập nhật mô tả công việc");
                    }

                    String ngaybdCu = (String) taskCu.get("ngay_bat_dau");
                    if (!safeStringEquals(ngaybdCu, ngaybd)) {
                        thayDoiList.add("📅 Đổi ngày bắt đầu: '" + (ngaybdCu != null ? ngaybdCu : "(chưa có)") + "' → '" + ngaybd + "'");
                    }

                    // So sánh hạn hoàn thành
                    String hanCu = (String) taskCu.get("han_hoan_thanh");
                    if (!safeStringEquals(hanCu, han)) {
                        thayDoiList.add("📅 Đổi deadline: '" + (hanCu != null ? hanCu : "(chưa có)") + "' → '" + han + "'");
                    }

                    // So sánh mức độ ưu tiên
                    String uuTienCu = (String) taskCu.get("muc_do_uu_tien");
                    if (!safeStringEquals(uuTienCu, uuTien)) {
                        thayDoiList.add("⚡ Đổi độ ưu tiên: '" + (uuTienCu != null ? uuTienCu : "Không") + "' → '" + uuTien + "'");
                    }

                    // So sánh người giao
                    int giaoIdCu = taskCu.get("nguoi_giao_id") != null ? (Integer) taskCu.get("nguoi_giao_id") : 0;
                    if (giaoIdCu != giaoId) {
                        String tenGiaoCu = (String) taskCu.get("ten_nguoi_giao");
                        thayDoiList.add("👤 Đổi người giao: '" + (tenGiaoCu != null ? tenGiaoCu : "?") + "' → '" + tenNguoiGiao + "'");
                    }

                    // So sánh phòng ban
                    int phongIdCu = taskCu.get("phong_ban_id") != null ? (Integer) taskCu.get("phong_ban_id") : 0;
                    if (phongIdCu != phongId) {
                        String phongCu = (String) taskCu.get("ten_phong_ban");
                        thayDoiList.add("🏢 Đổi phòng ban: '" + (phongCu != null ? phongCu : "?") + "' → '" + tenPhong + "'");
                    }

                    // So sánh trạng thái
                    String trangThaiCu = (String) taskCu.get("trang_thai");
                    if (!safeStringEquals(trangThaiCu, trangThai)) {
                        thayDoiList.add("🔄 Đổi trạng thái: '" + (trangThaiCu != null ? trangThaiCu : "?") + "' → '" + trangThai + "'");
                    }

                    // So sánh người nhận
                    String nguoiNhanCuNorm = normalizeRecipientList(nguoiNhanCu);
                    String nguoiNhanMoiNorm = normalizeRecipientList(dsTenNguoiNhan);

                    if (!safeStringEquals(nguoiNhanCuNorm, nguoiNhanMoiNorm)) {
                        thayDoiList.add("👥 Đổi người nhận: '"
                                + (nguoiNhanCuNorm != null && !nguoiNhanCuNorm.isEmpty() ? nguoiNhanCuNorm : "(chưa có)")
                                + "' → '" + nguoiNhanMoiNorm + "'");
                    }

                    // So sánh tài liệu
                    String tailieuCu = (String) taskCu.get("tai_lieu_cv");
                    if (!safeStringEquals(tailieuCu, tailieu)) {
                        thayDoiList.add("📎 Cập nhật link tài liệu");
                    }

                    // Ghi log nếu có thay đổi
                    if (!thayDoiList.isEmpty()) {
                        String moTaLichSu = String.join(" | ", thayDoiList);
                        db.themLichSuCongViec(taskId, userId, moTaLichSu);
                    }

                    // Ghi log upload file mới
                    if (!filePaths.isEmpty()) {
                        String fileNames = filePaths.stream()
                                .map(p -> p.substring(p.lastIndexOf("/") + 1))
                                .reduce((a, b) -> a + ", " + b)
                                .orElse("");
                        db.themLichSuCongViec(taskId, userId, "📁 Tải lên file: " + fileNames);
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

    // Helper method để so sánh an toàn 2 chuỗi
    private boolean safeStringEquals(String a, String b) {
        if (a == null && b == null) {
            return true;
        }
        if (a == null || b == null) {
            return false;
        }
        return a.trim().equals(b.trim());
    }

    private String normalizeRecipientList(String s) {
        if (s == null) {
            return null;
        }
        return s.replaceAll("\\s*,\\s*", ",").trim();
    }

    private boolean isNumeric(String str) {
        if (str == null) {
            return false;
        }
        return str.matches("\\d+");
    }
}
