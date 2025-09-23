package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;

public class DeleteFileServlet extends HttpServlet {

    // Hàm tiện ích: lấy thư mục upload
    private static String getUploadDir() {
        String dir = System.getenv("ICSS_UPLOAD_DIR");
        if (dir == null || dir.trim().isEmpty()) {
            dir = "D:/uploads"; // fallback local
        }
        return dir;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String fileName = request.getParameter("file");
        String taskIdStr = request.getParameter("taskId");

        PrintWriter out = response.getWriter();

        if (fileName == null || taskIdStr == null) {
            out.print("{\"success\": false, \"message\": \"Thiếu tham số file hoặc taskId.\"}");
            return;
        }

        try {
            int taskId = Integer.parseInt(taskIdStr);
            KNCSDL db = new KNCSDL();

            // 1. Lấy danh sách file hiện tại từ DB (đang lưu full path dạng "…/uploads/abc.docx")
            List<String> danhSach = db.getDanhSachTaiLieuByTaskId(taskId);

            // 2. Xóa file khỏi danh sách
            List<String> dsConLai = new ArrayList<>();
            boolean found = false;

            for (String path : danhSach) {
                if (path.endsWith(fileName)) {
                    found = true;

                    // Nếu path trong DB đã là full path thì dùng luôn, nếu chỉ là tên file thì nối lại
                    File file;
                    if (new File(path).isAbsolute()) {
                        file = new File(path);
                    } else {
                        file = new File(getUploadDir(), path);
                    }

                    if (file.exists()) {
                        if (!file.delete()) {
                            out.print("{\"success\": false, \"message\": \"Không thể xóa file vật lý.\"}");
                            return;
                        }
                    }
                } else {
                    dsConLai.add(path);
                }
            }

            if (!found) {
                out.print("{\"success\": false, \"message\": \"Không tìm thấy file cần xóa.\"}");
                return;
            }

            // 3. Cập nhật lại danh sách file trong DB
            db.capNhatTaiLieuCongViec(taskId, dsConLai);

            int projectId = Integer.parseInt(request.getParameter("projectId"));
            out.print("{\"success\": true, \"projectId\": " + projectId + "}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
}
