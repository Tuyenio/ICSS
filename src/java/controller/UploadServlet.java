package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.sql.*;
import controller.KNCSDL;

@MultipartConfig
public class UploadServlet extends HttpServlet {

    // KHÔNG cần khai báo cố định thư mục uploads nữa

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy đường dẫn lưu file từ biến môi trường
        String uploadPath = System.getenv("ICSS_UPLOAD_DIR");

        // Nếu không có, mặc định dùng local
        if (uploadPath == null || uploadPath.trim().isEmpty()) {
            uploadPath = "D:/uploads";  // fallback cho môi trường phát triển
        }

        // Tạo thư mục nếu chưa có
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        StringBuilder result = new StringBuilder();

        try {
            // Kết nối DB qua KNCSDL
            KNCSDL kn = new KNCSDL();
            Connection conn = kn.cn;

            String sql = "INSERT INTO tep_dinh_kem (ten_file, duong_dan, nguoi_tai_len) VALUES (?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);

            for (Part part : request.getParts()) {
                if (part.getName().equals("files") && part.getSize() > 0) {
                    String originalName = part.getSubmittedFileName();

                    // ✅ Bảo mật: chặn path traversal + kiểm tra đuôi file (whitelist)
                    if (!UploadSecurity.extAllowed(originalName)) {
                        result.append("<li>")
                              .append(UploadSecurity.baseName(originalName))
                              .append(" ❌ bị từ chối: ")
                              .append(UploadSecurity.rejectMessage())
                              .append("</li>");
                        continue;
                    }

                    // Tên lưu trữ an toàn, duy nhất (chỉ basename, không traversal)
                    String storedName = UploadSecurity.safeStorageName(originalName);

                    // Lưu file vật lý
                    try (InputStream fileContent = part.getInputStream();
                         FileOutputStream fos = new FileOutputStream(uploadPath + File.separator + storedName)) {
                        byte[] buffer = new byte[1024];
                        int bytesRead;
                        while ((bytesRead = fileContent.read(buffer)) != -1) {
                            fos.write(buffer, 0, bytesRead);
                        }
                    }

                    // Lưu vào DB
                    String nguoiTaiLen = request.getRemoteUser(); // Hoặc request.getParameter(...)
                    String filePath = uploadPath + File.separator + storedName; // Đường dẫn tuyệt đối
                    String displayName = UploadSecurity.sanitizedOriginalName(originalName);

                    pstmt.setString(1, displayName);
                    pstmt.setString(2, filePath); // Hoặc chỉ lưu tên nếu muốn
                    pstmt.setString(3, (nguoiTaiLen != null) ? nguoiTaiLen : "anonymous");
                    pstmt.executeUpdate();

                    result.append("<li>")
                          .append(displayName)
                          .append(" ✅ đã được tải lên và lưu.</li>");
                }
            }

            pstmt.close();
            conn.close();

        } catch (Exception e) {
            throw new ServletException("Lỗi khi xử lý upload: " + e.getMessage(), e);
        }

        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().println("<h4>📁 Kết quả upload:</h4>");
        response.getWriter().println("<ul>" + result.toString() + "</ul>");
    }
}

