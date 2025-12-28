package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

/**
 * Servlet xử lý tất cả các thao tác liên quan đến Thư viện tài liệu Bao gồm:
 * Xem danh sách, Thêm, Sửa, Xóa, Tải xuống, Tìm kiếm
 */
@WebServlet(name = "DocumentServlet", urlPatterns = {"/dsTailieu", "/uploadTailieu", "/downloadTailieu", "/deleteTailieu", "/updateTailieu"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 50, // 50MB
        maxRequestSize = 1024 * 1024 * 100 // 100MB
)
public class DocumentServlet extends HttpServlet {

    private static final long MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();

        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            switch (path) {
                case "/dsTailieu":
                    handleListDocuments(request, response);
                    break;
                case "/downloadTailieu":
                    handleDownloadDocument(request, response);
                    break;
                case "/deleteTailieu":
                    handleDeleteDocument(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("documents.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();

        // Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            switch (path) {
                case "/uploadTailieu":
                    handleUploadDocument(request, response);
                    break;
                case "/updateTailieu":
                    handleUpdateDocument(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("documents.jsp").forward(request, response);
        }
    }

    /**
     * Hiển thị danh sách tài liệu
     */
    private void handleListDocuments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {

        KNCSDL kn = new KNCSDL();

        try {
            String searchKeyword = request.getParameter("search");
            String nhomIdStr = request.getParameter("nhomId");
            
            // Kiểm tra cả request attribute (từ redirect sau khi xóa)
            if (nhomIdStr == null || nhomIdStr.isEmpty()) {
                Integer nhomIdAttr = (Integer) request.getAttribute("nhomId");
                if (nhomIdAttr != null) {
                    nhomIdStr = nhomIdAttr.toString();
                }
            }

            List<TaiLieu> danhSach;
            List<NhomTaiLieu> danhSachNhom = kn.getAllNhomTaiLieu();

            // Nếu có nhomId, chỉ lấy tài liệu trong nhóm đó
            if (nhomIdStr != null && !nhomIdStr.isEmpty()) {
                int nhomId = Integer.parseInt(nhomIdStr);
                
                if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                    danhSach = kn.searchTaiLieuInNhom(nhomId, searchKeyword.trim());
                } else {
                    danhSach = kn.getTaiLieuByNhomId(nhomId);
                }
                
                NhomTaiLieu nhomHienTai = kn.getNhomTaiLieuById(nhomId);
                request.setAttribute("nhomHienTai", nhomHienTai);
                request.setAttribute("nhomId", nhomId);
            } else {
                // Không có nhóm, hiển thị danh sách nhóm
                danhSach = null;
            }

            request.setAttribute("danhSachTaiLieu", danhSach);
            request.setAttribute("danhSachNhom", danhSachNhom);
            request.setAttribute("currentSearch", searchKeyword);

        } finally {
            kn.close();
        }

        request.getRequestDispatcher("documents.jsp").forward(request, response);
    }

    /**
     * Xử lý upload tài liệu mới
     */
    private void handleUploadDocument(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {

        HttpSession session = request.getSession();
        Object userIdObj = session.getAttribute("userId");

        if (userIdObj == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int nguoiTaoId;
        if (userIdObj instanceof Integer) {
            nguoiTaoId = (Integer) userIdObj;
        } else {
            nguoiTaoId = Integer.parseInt(userIdObj.toString());
        }

        // Lấy thông tin từ form
        String tenTaiLieu = request.getParameter("tenTaiLieu");
        String loaiTaiLieu = request.getParameter("loaiTaiLieu");
        String moTa = request.getParameter("moTa");
        String nhomIdStr = request.getParameter("nhomId");

        // Validate input
        if (tenTaiLieu == null || tenTaiLieu.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập tên tài liệu!");
            handleListDocuments(request, response);
            return;
        }

        if (nhomIdStr == null || nhomIdStr.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn nhóm tài liệu!");
            handleListDocuments(request, response);
            return;
        }

        int nhomId = Integer.parseInt(nhomIdStr);

        // Lấy file upload
        Part filePart = request.getPart("fileUpload");

        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("error", "Vui lòng chọn file để tải lên!");
            handleListDocuments(request, response);
            return;
        }

        // Kiểm tra kích thước file
        if (filePart.getSize() > MAX_FILE_SIZE) {
            request.setAttribute("error", "File quá lớn! Kích thước tối đa là 50MB.");
            handleListDocuments(request, response);
            return;
        }

        // Lấy tên file gốc
        String originalFileName = Paths
        .get(filePart.getSubmittedFileName())
        .getFileName()
        .toString();
        String fileExtension = getFileExtension(originalFileName);

        // Tạo tên file lưu: giữ tên gốc (còn dấu) nhưng loại bỏ ký tự bất hợp pháp
        String destFileName = sanitizeFileName(originalFileName);

        // Lấy thư mục upload giống các servlet khác (ICSS_UPLOAD_DIR) — fallback local
        String uploadPath = System.getenv("ICSS_UPLOAD_DIR");
        if (uploadPath == null || uploadPath.trim().isEmpty()) {
            uploadPath = "D:/uploads"; // fallback cho môi trường phát triển
        }

        // Tạo thư mục upload nếu chưa có
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // Lưu file (lưu theo tên file gốc đã được sanitize; nếu trùng tên thì thêm timestamp)
        File destFile = new File(uploadPath, destFileName);
        if (destFile.exists()) {
            String name = destFileName;
            String ext = "";
            int dot = destFileName.lastIndexOf('.');
            if (dot > 0) {
                name = destFileName.substring(0, dot);
                ext = destFileName.substring(dot);
            }
            destFileName = name + "_" + System.currentTimeMillis() + ext;
            destFile = new File(uploadPath, destFileName);
        }

        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, destFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }

        // Lưu thông tin vào database (lưu `filePath` là tên file trong thư mục upload)
        TaiLieu taiLieu = new TaiLieu();
        taiLieu.setNhomTaiLieuId(nhomId);
        taiLieu.setTenTaiLieu(tenTaiLieu.trim());
        taiLieu.setLoaiTaiLieu(loaiTaiLieu != null ? loaiTaiLieu.trim() : "Khác");
        taiLieu.setMoTa(moTa);
        taiLieu.setFileName(originalFileName);
        // Lưu filePath là tên file trong thư mục upload (không lưu đường dẫn tuyệt đối)
        taiLieu.setFilePath(destFileName);
        taiLieu.setFileSize(filePart.getSize());
        taiLieu.setFileType(filePart.getContentType());
        taiLieu.setNguoiTaoId(nguoiTaoId);

        KNCSDL kn = new KNCSDL();
        try {
            int result = kn.insertTaiLieu(taiLieu);
            if (result > 0) {
                request.setAttribute("success", "Tải lên tài liệu thành công!");
            } else {
                request.setAttribute("error", "Không thể lưu thông tin tài liệu!");
            }
        } finally {
            kn.close();
        }

        handleListDocuments(request, response);
    }

    /**
     * Xử lý cập nhật thông tin tài liệu
     */
    private void handleUpdateDocument(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {

        int id = Integer.parseInt(request.getParameter("id"));
        String tenTaiLieu = request.getParameter("tenTaiLieu");
        String loaiTaiLieu = request.getParameter("loaiTaiLieu");
        String moTa = request.getParameter("moTa");
        String nhomIdStr = request.getParameter("nhomId");

        TaiLieu taiLieu = new TaiLieu();
        taiLieu.setId(id);
        taiLieu.setTenTaiLieu(tenTaiLieu);
        taiLieu.setLoaiTaiLieu(loaiTaiLieu);
        taiLieu.setMoTa(moTa);

        KNCSDL kn = new KNCSDL();
        try {
            boolean success = kn.updateTaiLieu(taiLieu);
            if (success) {
                request.setAttribute("success", "Cập nhật tài liệu thành công!");
            } else {
                request.setAttribute("error", "Không thể cập nhật tài liệu!");
            }
        } finally {
            kn.close();
        }

        // Redirect về đúng nhóm nếu có
        if (nhomIdStr != null && !nhomIdStr.isEmpty()) {
            request.setAttribute("nhomId", Integer.parseInt(nhomIdStr));
        }
        handleListDocuments(request, response);
    }

    /**
     * Xử lý tải xuống tài liệu
     */
    private void handleDownloadDocument(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException, ClassNotFoundException {

        int id = Integer.parseInt(request.getParameter("id"));

        KNCSDL kn = new KNCSDL();
        try {
            TaiLieu taiLieu = kn.getTaiLieuById(id);

            if (taiLieu == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Tài liệu không tồn tại!");
                return;
            }

            // Tăng số lượt tải
            kn.incrementLuotTai(id);

            // Đường dẫn file thực tế: nếu DB lưu đường dẫn tuyệt đối thì dùng trực tiếp,
            // ngược lại kết hợp với biến môi trường ICSS_UPLOAD_DIR (như các servlet upload khác)
            String storedPath = taiLieu.getFilePath();
            File file = new File(storedPath);
            if (!file.isAbsolute()) {
                String uploadDir = System.getenv("ICSS_UPLOAD_DIR");
                if (uploadDir == null || uploadDir.trim().isEmpty()) {
                    uploadDir = "D:/uploads"; // fallback
                }
                file = new File(uploadDir, storedPath);
            }

            if (!file.exists()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File không tồn tại trên hệ thống!");
                return;
            }

                // Set response headers (support Unicode filenames)
                response.setContentType(taiLieu.getFileType());
                response.setContentLengthLong(file.length());
                String originalName = taiLieu.getFileName() != null ? taiLieu.getFileName() : file.getName();
                String asciiFallback = originalName.replaceAll("[\\\\\"\\/\\:\\*\\?\\<\\>\\|]", "_");
                String encoded = java.net.URLEncoder.encode(originalName, "UTF-8").replaceAll("\\+", "%20");
                String contentDisposition = "attachment; filename=\"" + asciiFallback + "\"; filename*=UTF-8''" + encoded;
                response.setHeader("Content-Disposition", contentDisposition);

            // Stream file to client
            try (FileInputStream in = new FileInputStream(file); OutputStream out = response.getOutputStream()) {

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
                out.flush();
            }

        } finally {
            kn.close();
        }
    }

    /**
     * Xử lý xóa tài liệu (soft delete)
     */
    private void handleDeleteDocument(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException, ClassNotFoundException, ServletException {

        int id = Integer.parseInt(request.getParameter("id"));
        String nhomIdStr = request.getParameter("nhomId");

        KNCSDL kn = new KNCSDL();
        try {
            // Lấy thông tin tài liệu để xóa file vật lý nếu có
            TaiLieu taiLieu = kn.getTaiLieuById(id);
            if (taiLieu != null) {
                String storedPath = taiLieu.getFilePath();
                File file = new File(storedPath);
                if (!file.isAbsolute()) {
                    String uploadDir = System.getenv("ICSS_UPLOAD_DIR");
                    if (uploadDir == null || uploadDir.trim().isEmpty()) {
                        uploadDir = "D:/uploads"; // fallback
                    }
                    file = new File(uploadDir, storedPath);
                }

                try {
                    if (file.exists()) {
                        file.delete();
                    }
                } catch (Exception ex) {
                    // Không dừng quá trình xóa DB nếu xóa file thất bại
                    ex.printStackTrace();
                }
            }

            boolean success = kn.deleteTaiLieu(id);
            if (success) {
                request.setAttribute("success", "Xóa tài liệu thành công!");
            } else {
                request.setAttribute("error", "Không thể xóa tài liệu!");
            }
        } finally {
            kn.close();
        }

        // Redirect về đúng nhóm nếu có
        if (nhomIdStr != null && !nhomIdStr.isEmpty()) {
            request.setAttribute("nhomId", Integer.parseInt(nhomIdStr));
        }
        handleListDocuments(request, response);
    }

    /**
     * Lấy tên file từ Part
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] items = contentDisposition.split(";");
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                return item.substring(item.indexOf("=") + 2, item.length() - 1);
            }
        }
        return "";
    }

    /**
     * Lấy extension của file
     */
    private String getFileExtension(String fileName) {
        int lastIndex = fileName.lastIndexOf('.');
        if (lastIndex > 0) {
            return fileName.substring(lastIndex);
        }
        return "";
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
}
