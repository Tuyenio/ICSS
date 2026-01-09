package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.net.URLDecoder;
import java.net.URLEncoder;

public class DownloadFileServlet extends HttpServlet {

    private static String getUploadDir() {
        // Ưu tiên lấy từ biến môi trường (server)
        String dir = System.getenv("ICSS_UPLOAD_DIR");
        if (dir == null || dir.trim().isEmpty()) {
            dir = "D:/uploads"; // fallback local
        }
        return dir;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // Lấy tên file từ request
        String rawFileName = req.getParameter("file");
        if (rawFileName == null || rawFileName.trim().isEmpty()) {
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().println("❌ Tên file không hợp lệ.");
            return;
        }

        // Decode UTF-8 tên file từ URL
        String fileName = URLDecoder.decode(rawFileName, "UTF-8");

        // Lấy thư mục upload đúng theo môi trường
        String uploadDir = getUploadDir();

        // Tạo file object
        File file = new File(uploadDir, fileName);

        if (!file.exists() || !file.isFile()) {
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().println("❌ File không tồn tại: " + file.getAbsolutePath());
            return;
        }

        // Thiết lập header tải file (giữ nguyên dấu tiếng Việt)
        resp.setContentType("application/octet-stream");
        String utf8Name = file.getName();
        String encodedName = java.net.URLEncoder.encode(utf8Name, "UTF-8").replaceAll("\\+", "%20");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + utf8Name + "\"; filename*=UTF-8''" + encodedName);
        resp.setContentLengthLong(file.length());

        try (BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
             BufferedOutputStream bos = new BufferedOutputStream(resp.getOutputStream())) {

            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = bis.read(buffer)) != -1) {
                bos.write(buffer, 0, bytesRead);
            }
        }
    }
}
