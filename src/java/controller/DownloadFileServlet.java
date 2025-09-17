package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.net.URLDecoder;

public class DownloadFileServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "D:/uploads"; // đổi theo server nếu cần

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Đảm bảo nhận UTF-8 từ query string
        req.setCharacterEncoding("UTF-8");

        // Lấy tên file từ request và decode UTF-8
        String rawFileName = req.getParameter("file");
        if (rawFileName == null || rawFileName.trim().isEmpty()) {
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().println("❌ Tên file không hợp lệ.");
            return;
        }

        // Decode UTF-8 tên file từ URL
        String fileName = URLDecoder.decode(rawFileName, "UTF-8");

        // Tạo file object
        File file = new File(UPLOAD_DIR, fileName);

        if (!file.exists() || !file.isFile()) {
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().println("❌ File không tồn tại: " + file.getAbsolutePath());
            return;
        }

        // Thiết lập response header
        resp.setContentType("application/octet-stream");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + file.getName() + "\"");
        resp.setContentLengthLong(file.length());

        // Truyền file về client
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
