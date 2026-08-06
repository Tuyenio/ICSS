/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import com.mysql.cj.xdevapi.DbDoc;
import java.io.IOException;
import java.sql.*;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;

/**
 *
 * @author Admin
 */
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 50, // 50MB
        maxRequestSize = 1024 * 1024 * 100 // 100MB
)
public class apiTaskSteps extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String taskId = request.getParameter("task_id");

        response.setContentType("application/json; charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (taskId == null || taskId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Missing task_id\"}");
            return;
        }

        try {
            KNCSDL db = new KNCSDL();
            ResultSet rs = db.getStepsRawByTaskId(taskId);

            StringBuilder json = new StringBuilder();
            json.append("[");

            boolean first = true;
            while (rs.next()) {
                if (!first) {
                    json.append(",");
                }
                json.append("{");

                json.append("\"id\":\"").append(escapeJson(rs.getString("id"))).append("\",");
                json.append("\"name\":\"").append(escapeJson(rs.getString("ten_buoc"))).append("\",");
                json.append("\"desc\":\"").append(escapeJson(rs.getString("mo_ta"))).append("\",");
                json.append("\"status\":\"").append(escapeJson(rs.getString("trang_thai"))).append("\",");
                json.append("\"start\":\"").append(escapeJson(rs.getString("ngay_bat_dau"))).append("\",");
                json.append("\"end\":\"").append(escapeJson(rs.getString("ngay_ket_thuc"))).append("\",");
                json.append("\"linkTaiLieu\":\"").append(escapeJson(rs.getString("tai_lieu_link"))).append("\",");
                json.append("\"fileTaiLieu\":\"").append(escapeJson(rs.getString("tai_lieu_file"))).append("\",");

                // 🔹 Lấy danh sách người nhận cho step này
                int stepId = rs.getInt("id");
                List<Map<String, Object>> nguoiNhanList = new KNCSDL().getNguoiNhanByStepId(stepId);

                json.append("\"receivers\":[");
                for (int i = 0; i < nguoiNhanList.size(); i++) {
                    Map<String, Object> nguoi = nguoiNhanList.get(i);
                    if (i > 0) {
                        json.append(",");
                    }
                    json.append("{")
                            .append("\"id\":").append(nguoi.get("id")).append(",")
                            .append("\"name\":\"").append(escapeJson((String) nguoi.get("ten"))).append("\"")
                            .append("}");
                }
                json.append("]");

                json.append("}");
                first = false;
            }

            json.append("]");
            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("[]");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        PrintWriter out = response.getWriter();

        String stepIdStr = request.getParameter("step_id");
        String name = request.getParameter("name");
        String desc = request.getParameter("desc");
        String status = request.getParameter("stepStatus");  // ✅ Sửa: lấy từ stepStatus thay vì status
        if (status == null || status.isEmpty()) {
            status = request.getParameter("status");  // Fallback: nếu stepStatus không có, thử status
        }
        String start = request.getParameter("start");
        String end = request.getParameter("end");
        String linkTaiLieu = request.getParameter("link_tai_lieu");
        String fileTaiLieuCu = request.getParameter("file_tai_lieu_cu"); // Danh sách file còn lại sau khi xóa
        
        // ✅ Xử lý multiple file upload
        String fileTaiLieu = fileTaiLieuCu != null ? fileTaiLieuCu : ""; // Bắt đầu từ danh sách file còn lại
        List<Part> fileParts = new ArrayList<>();
        try {
            // Lấy tất cả parts có tên "file_tai_lieu"
            for (Part part : request.getParts()) {
                if ("file_tai_lieu".equals(part.getName()) && part.getSize() > 0) {
                    fileParts.add(part);
                }
            }
        } catch (Exception e) {
            // Không có file upload
        }
        
        // Nếu có file mới upload
        if (!fileParts.isEmpty()) {
            String uploadPath = System.getenv("ICSS_UPLOAD_DIR");
            if (uploadPath == null || uploadPath.trim().isEmpty()) {
                uploadPath = "D:/uploads"; // fallback
            }
            
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // Xử lý từng file mới upload
            for (Part filePart : fileParts) {
                String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                // ✅ Bảo mật: chỉ chấp nhận đuôi file hợp lệ, bỏ qua file nguy hiểm (jsp/php/...)
                if (!UploadSecurity.extAllowed(originalFileName)) {
                    continue;
                }
                String destFileName = sanitizeFileName(originalFileName);
                
                // Thêm timestamp nếu file đã tồn tại
                File destFile = new File(uploadPath, destFileName);
                if (destFile.exists()) {
                    String name_part = destFileName;
                    String ext = "";
                    int dot = destFileName.lastIndexOf('.');
                    if (dot > 0) {
                        name_part = destFileName.substring(0, dot);
                        ext = destFileName.substring(dot);
                    }
                    destFileName = name_part + "_" + System.currentTimeMillis() + ext;
                    destFile = new File(uploadPath, destFileName);
                }
                
                // Lưu file
                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, destFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
                
                // Thêm vào danh sách file (cách nhau bởi ;)
                if (fileTaiLieu != null && !fileTaiLieu.isEmpty() && !fileTaiLieu.equals("null")) {
                    fileTaiLieu = fileTaiLieu + ";" + destFileName;
                } else {
                    fileTaiLieu = destFileName;
                }
            }
        }

        if (stepIdStr == null || name == null || status == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            // Debug: log tất cả parameter
            System.out.println("❌ DEBUG apiTaskSteps.doPost - Thiếu param:");
            System.out.println("  stepIdStr: " + stepIdStr);
            System.out.println("  name: " + name);
            System.out.println("  desc: " + desc);
            System.out.println("  status: " + status);
            System.out.println("  start: " + start);
            System.out.println("  end: " + end);
            System.out.println("  linkTaiLieu: " + linkTaiLieu);
            System.out.println("  fileTaiLieuCu: " + fileTaiLieuCu);
            out.print("{\"success\":false,\"message\":\"Thiếu thông tin bắt buộc: stepId=" + stepIdStr + ", name=" + name + ", status=" + status + "\"}");
            return;
        }

        try {
            // Validate và parse stepId
            if (stepIdStr.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Step ID không được rỗng.\"}");
                return;
            }
            int stepId = Integer.parseInt(stepIdStr.trim());

            KNCSDL db = new KNCSDL();

            // Lấy thông tin tiến độ cũ để so sánh
            Map<String, Object> stepCu = db.getStepById(stepId);
            
            // ✅ FIX: Nếu không có input mới, giữ nguyên dữ liệu cũ
            // Nếu linkTaiLieu rỗng/null, lấy giá trị cũ từ DB
            if ((linkTaiLieu == null || linkTaiLieu.trim().isEmpty())) {
                Object oldLink = stepCu != null ? stepCu.get("tai_lieu_link") : null;
                linkTaiLieu = (oldLink != null && !oldLink.toString().equals("null")) ? oldLink.toString() : "";
            }
            
            // Nếu không upload file mới, giữ nguyên fileTaiLieu (đã set từ fileTaiLieuCu hoặc file mới)
            // fileTaiLieu đã được xử lý từ fileParts ở trên, không cần kiểm tra thêm
            // Nếu fileTaiLieu vẫn rỗng và không có fileTaiLieuCu, lấy từ DB
            if ((fileTaiLieu == null || fileTaiLieu.isEmpty())) {
                Object oldFile = stepCu != null ? stepCu.get("tai_lieu_file") : null;
                fileTaiLieu = (oldFile != null && !oldFile.toString().equals("null")) ? oldFile.toString() : "";
            }

            boolean success = db.updateStepByIdWithDocuments(stepId, name, desc, status, start, end, linkTaiLieu, fileTaiLieu);

            if (success) {
                String processNguoiNhan = request.getParameter("process_nguoi_nhan");
                if (processNguoiNhan != null) {
                    KNCSDL dbNN = null;
                    try {
                        dbNN = new KNCSDL();
                        // xóa người nhận cũ của bước
                        dbNN.deleteNguoiNhanByStepId(stepId);

                        String[] arr = processNguoiNhan.split(",");
                        for (String sId : arr) {
                            sId = sId.trim();
                            if (sId.isEmpty()) {
                                continue;
                            }
                            try {
                                int nhanId = Integer.parseInt(sId);
                                dbNN.insertNguoiNhanQuyTrinh(stepId, nhanId);
                            } catch (NumberFormatException ex) {
                                // bỏ qua id không hợp lệ
                            }
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    } finally {
                        if (dbNN != null) {
                            try {
                                dbNN.close();
                            } catch (Exception ignore) {
                            }
                        }
                    }
                }

                db = new KNCSDL();
                int congviecId = db.getCongViecIdByBuocId(stepId);
                String tencv = db.getTenCongViecById(congviecId);
                List<Integer> danhSachNguoiNhan = db.getDanhSachNguoiNhanId(congviecId);

                String tieuDeTB = "Cập nhật quy trình";
                String noiDungTB = "Công việc: " + tencv + " vừa được cập nhật quy trình mới";

                for (int nhanId : danhSachNguoiNhan) {
                    String role = db.getVaiTroById(nhanId);
                    String link = "";

                    // 🔥 Nếu là Admin hoặc Quản lý → vào giao diện Admin
                    if (role != null && (role.equalsIgnoreCase("Admin") || role.equalsIgnoreCase("Quản lý"))) {
                        link = "dsCongviec?taskId=" + congviecId;
                    } else {
                        // 🔥 Ngược lại nhân viên dùng giao diện của NV
                        link = "dsCongviecNV?taskId=" + congviecId;
                    }
                    db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Cập nhật", link);
                }

                // Ghi log lịch sử CHI TIẾT từng trường
                jakarta.servlet.http.HttpSession session = request.getSession(false);
                int userId = 0;
                if (session != null && session.getAttribute("userId") != null) {
                    try {
                        userId = Integer.parseInt(session.getAttribute("userId").toString());
                    } catch (Exception e) {
                    }
                }

                if (userId > 0 && stepCu != null) {
                    java.util.List<String> thayDoiList = new java.util.ArrayList<>();

                    // So sánh tên tiến độ
                    String tenCu = (String) stepCu.get("ten_buoc");
                    if (!safeStringEquals(tenCu, name)) {
                        thayDoiList.add("📝 Đổi tên tiến độ: '" + (tenCu != null ? tenCu : "(trống)") + "' → '" + name + "'");
                    }

                    // So sánh mô tả
                    String moTaCu = (String) stepCu.get("mo_ta");
                    if (!safeStringEquals(moTaCu, desc)) {
                        thayDoiList.add("� Cập nhật mô tả tiến độ");
                    }

                    // So sánh trạng thái
                    String trangThaiCu = (String) stepCu.get("trang_thai");
                    if (!safeStringEquals(trangThaiCu, status)) {
                        thayDoiList.add("🔄 Đổi trạng thái tiến độ: '" + (trangThaiCu != null ? trangThaiCu : "?") + "' → '" + status + "'");
                    }

                    // So sánh ngày bắt đầu
                    String ngayBDCu = (String) stepCu.get("ngay_bat_dau");
                    if (!safeStringEquals(ngayBDCu, start)) {
                        thayDoiList.add("📅 Đổi ngày bắt đầu: '" + (ngayBDCu != null ? ngayBDCu : "(chưa có)") + "' → '" + (start != null && !start.isEmpty() ? start : "(chưa có)") + "'");
                    }

                    // So sánh ngày kết thúc
                    String ngayKTCu = (String) stepCu.get("ngay_ket_thuc");
                    if (!safeStringEquals(ngayKTCu, end)) {
                        thayDoiList.add("📅 Đổi deadline tiến độ: '" + (ngayKTCu != null ? ngayKTCu : "(chưa có)") + "' → '" + (end != null && !end.isEmpty() ? end : "(chưa có)") + "'");
                    }

                    // Ghi log nếu có thay đổi
                    if (!thayDoiList.isEmpty()) {
                        String logMsg = "🔧 [Tiến độ: " + name + "] " + String.join(" | ", thayDoiList);
                        db.themLichSuCongViec(congviecId, userId, logMsg);
                    }
                }

                response.setStatus(HttpServletResponse.SC_OK);
                // Trả về tên file mới nếu có upload
                if (fileTaiLieu != null && !fileTaiLieu.isEmpty()) {
                    out.print("{\"success\":true,\"fileTaiLieu\":\"" + escapeJson(fileTaiLieu) + "\"}");
                } else {
                    out.print("{\"success\":true}");
                }

            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Không tìm thấy bước để cập nhật.\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Lỗi máy chủ: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    // Escape chuỗi JSON thủ công
    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\"", "\\\"")
                .replace("\n", "")
                .replace("\r", "");
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

    /**
     * Làm sạch tên file (loại bỏ ký tự đặc biệt)
     */
    private String sanitizeFileName(String fileName) {
        if (fileName == null) return "unnamed";
        // Loại bỏ các ký tự cấm trên Windows/Linux và các control chars, giữ nguyên ký tự Unicode (tiếng Việt)
        String cleaned = fileName.replaceAll("[\\\\/:*?\"<>|\\p{Cntrl}]", "_");
        // Trim khoảng trắng đầu/cuối và giới hạn độ dài hợp lý
        cleaned = cleaned.trim();
        if (cleaned.length() > 250) {
            String ext = "";
            int dot = cleaned.lastIndexOf('.');
            if (dot > 0) {
                ext = cleaned.substring(dot);
                cleaned = cleaned.substring(0, Math.min(240, dot));
            } else {
                cleaned = cleaned.substring(0, 240);
            }
            cleaned = cleaned + ext;
        }
        return cleaned;
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
