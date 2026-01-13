/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 *
 * @author Admin
 */
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 50,
        maxRequestSize = 1024 * 1024 * 100
)
public class xoaQuytrinh extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // ✅ Set encoding TRƯỚC KHI đọc bất kỳ parameter nào
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            String stepIdStr = request.getParameter("step_id");
            try {
                KNCSDL db = new KNCSDL();
                int stepId = Integer.parseInt(stepIdStr);

                // Lấy thông tin tiến độ trước khi xóa
                Map<String, Object> stepInfo = db.getStepById(stepId);
                String tenBuoc = stepInfo != null ? (String) stepInfo.get("ten_buoc") : "Tiến độ";

                int congViecId = db.getCongViecIdByBuocId(stepId);
                String tencv = db.getTenCongViecById(congViecId);
                List<Integer> danhSachIdNhan = db.getDanhSachNguoiNhanId(congViecId);
                String tieuDeTB = "Xóa bỏ quy trình";
                String noiDungTB = "Công việc: " + tencv + " vừa xóa bỏ một quy trình";

                // --- NEW: xóa trước các liên kết người nhận của bước (nếu có) ---
                try {
                    db.deleteNguoiNhanByStepId(stepId);
                } catch (Exception ex) {
                    // nếu lỗi ở đây thì vẫn tiếp tục thử xóa bước chính (tùy DB FK)
                    ex.printStackTrace();
                }

                boolean deleted = db.deleteStepById(stepId);
                if (deleted) {
                    db = new KNCSDL();
                    for (int nhanId : danhSachIdNhan) {
                        String role = db.getVaiTroById(nhanId);
                        String link = "";

                        // 🔥 Nếu là Admin hoặc Quản lý → vào giao diện Admin
                        if (role != null && (role.equalsIgnoreCase("Admin") || role.equalsIgnoreCase("Quản lý"))) {
                            link = "dsCongviec?taskId=" + congViecId;
                        } else {
                            // 🔥 Ngược lại nhân viên dùng giao diện của NV
                            link = "dsCongviecNV?taskId=" + congViecId;
                        }
                        db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Cập nhật", link);
                    }

                    // Ghi log lịch sử CHI TIẾT
                    jakarta.servlet.http.HttpSession session = request.getSession(false);
                    int userId = 0;
                    if (session != null && session.getAttribute("userId") != null) {
                        try {
                            userId = Integer.parseInt(session.getAttribute("userId").toString());
                        } catch (Exception e) {
                        }
                    }
                    if (userId > 0) {
                        String logMsg = "🗑️ Xóa tiến độ: '" + tenBuoc + "'";
                        db.themLichSuCongViec(congViecId, userId, logMsg);
                    }

                    // Trả JSON xác nhận
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("{\"success\":true}");
                    db.close();
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy bước để xóa\"}");
                }
            } catch (NumberFormatException | SQLException e) {
                e.printStackTrace(); // Ghi log
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\":false,\"message\":\"Lỗi server khi xóa bước\"}");
            } catch (ClassNotFoundException ex) {
                ex.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\":false,\"message\":\"Lỗi server (Class not found)\"}");
            }
            return;
        }

        if ("add".equals(action)) {
            String congViecIdStr = request.getParameter("task_id");
            String tenBuoc = request.getParameter("name");
            String moTa = request.getParameter("desc");
            String trangThai = request.getParameter("stepStatus");  // ✅ Sửa: lấy từ stepStatus chứ không phải status
            String ngayBatDau = request.getParameter("start");
            String ngayKetThuc = request.getParameter("end");
            String linkTaiLieu = request.getParameter("link_tai_lieu");
            String nguoiNhanStr = request.getParameter("process_nguoi_nhan");

            // ✅ Xử lý multiple file upload
            String fileTaiLieu = "";
            List<Part> fileParts = new ArrayList<>();
            try {
                for (Part part : request.getParts()) {
                    if ("file_tai_lieu".equals(part.getName()) && part.getSize() > 0) {
                        fileParts.add(part);
                    }
                }
            } catch (Exception e) {
                // Không có file upload
            }

            if (!fileParts.isEmpty()) {
                String uploadPath = System.getenv("ICSS_UPLOAD_DIR");
                if (uploadPath == null || uploadPath.trim().isEmpty()) {
                    uploadPath = "D:/uploads";
                }

                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                // Xử lý từng file
                for (Part filePart : fileParts) {
                    String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    String destFileName = sanitizeFileName(originalFileName);

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

                    try (InputStream input = filePart.getInputStream()) {
                        Files.copy(input, destFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    }
                    
                    // Thêm vào danh sách file (cách nhau bởi ;)
                    if (!fileTaiLieu.isEmpty()) {
                        fileTaiLieu = fileTaiLieu + ";" + destFileName;
                    } else {
                        fileTaiLieu = destFileName;
                    }
                }
            }

            int congViecId = Integer.parseInt(congViecIdStr);

            try {
                KNCSDL db = new KNCSDL();
                int newId = db.insertStep(congViecId, tenBuoc, moTa, trangThai, ngayBatDau, ngayKetThuc);

                if (newId > 0) {
                    // Cập nhật link và file nếu có
                    if ((linkTaiLieu != null && !linkTaiLieu.isEmpty()) || !fileTaiLieu.isEmpty()) {
                        db.updateStepByIdWithDocuments(newId, tenBuoc, moTa, trangThai, ngayBatDau, ngayKetThuc, 
                            linkTaiLieu != null ? linkTaiLieu : "", fileTaiLieu);
                    }

                    // 🔹 Lưu danh sách người nhận (nếu có)
                    if (nguoiNhanStr != null && !nguoiNhanStr.isEmpty()) {
                        String[] ids = nguoiNhanStr.split(",");
                        for (String idStr : ids) {
                            try {
                                int nhanId = Integer.parseInt(idStr.trim());
                                db.insertNguoiNhanQuyTrinh(newId, nhanId);
                            } catch (NumberFormatException ex) {
                                // Bỏ qua id không hợp lệ
                            }
                        }
                    }
                    db.close();

                    // 🔹 Gửi thông báo
                    db = new KNCSDL();
                    List<Integer> danhSachIdNhan = db.getDanhSachNguoiNhanId(congViecId);
                    String tencv = db.getTenCongViecById(congViecId);
                    String tieuDeTB = "Thêm mới quy trình";
                    String noiDungTB = "Công việc: " + tencv + " vừa được thêm quy trình mới";

                    for (int nhanId : danhSachIdNhan) {
                        String duongDan = "dsCongviec?taskId=" + congViecId;
                        db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Cập nhật", duongDan);
                    }

                    // 🔹 Ghi log lịch sử chi tiết
                    jakarta.servlet.http.HttpSession session = request.getSession(false);
                    int userId = 0;
                    if (session != null && session.getAttribute("userId") != null) {
                        try {
                            userId = Integer.parseInt(session.getAttribute("userId").toString());
                        } catch (Exception e) {
                        }
                    }

                    if (userId > 0) {
                        StringBuilder logMsg = new StringBuilder("➕ Thêm tiến độ mới: '");
                        logMsg.append(tenBuoc != null ? tenBuoc : "");
                        logMsg.append("' | Trạng thái: ").append(trangThai != null ? trangThai : "");
                        if (ngayBatDau != null && !ngayBatDau.isEmpty()) {
                            logMsg.append(" | Ngày bắt đầu: ").append(ngayBatDau);
                        }
                        if (ngayKetThuc != null && !ngayKetThuc.isEmpty()) {
                            logMsg.append(" | Deadline: ").append(ngayKetThuc);
                        }
                        if (moTa != null && !moTa.isEmpty()) {
                            String moTaShort = moTa.length() > 50 ? moTa.substring(0, 50) + "..." : moTa;
                            logMsg.append(" | Mô tả: \"").append(moTaShort).append("\"");
                        }
                        db.themLichSuCongViec(congViecId, userId, logMsg.toString());
                    }

                    response.setStatus(HttpServletResponse.SC_OK);

                    String safeLink = (linkTaiLieu != null) ? linkTaiLieu : "";
                    String safeFile = (fileTaiLieu != null) ? fileTaiLieu : "";

                    StringBuilder sb = new StringBuilder();
                    sb.append('{');
                    sb.append("\"success\":true,");
                    sb.append("\"id\":").append(newId).append(',');
                    sb.append("\"fileTaiLieu\":\"").append(escapeJson(safeFile)).append("\",");
                    sb.append("\"name\":\"").append(escapeJson(tenBuoc != null ? tenBuoc : "")).append("\",");
                    sb.append("\"desc\":\"").append(escapeJson(moTa != null ? moTa : "")).append("\",");
                    sb.append("\"status\":\"").append(escapeJson(trangThai != null ? trangThai : "")).append("\",");
                    sb.append("\"start\":\"").append(escapeJson(ngayBatDau != null ? ngayBatDau : "")).append("\",");
                    sb.append("\"end\":\"").append(escapeJson(ngayKetThuc != null ? ngayKetThuc : "")).append("\",");
                    sb.append("\"linkTaiLieu\":\"").append(escapeJson(safeLink)).append("\"");
                    sb.append('}');
                    response.getWriter().write(sb.toString());
                    db.close();
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"success\":false,\"message\":\"Không thể thêm bước\"}");
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                e.printStackTrace();
                response.getWriter().write("{\"success\":false,\"message\":\"Lỗi máy chủ\"}");
            }
            return;
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }

    /**
     * Làm sạch tên file (loại bỏ ký tự đặc biệt)
     */
    private String sanitizeFileName(String fileName) {
        if (fileName == null) return "unnamed";
        String cleaned = fileName.replaceAll("[\\\\/:*?\"<>|\\p{Cntrl}]", "_");
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
    }// </editor-fold>

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
