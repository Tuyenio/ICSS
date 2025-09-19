package controller;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Arrays;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class xoaCongviec extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idRaw = request.getParameter("id");

        try {
            int id = Integer.parseInt(idRaw);
            KNCSDL db = new KNCSDL();

            // === Lấy danh sách đường dẫn file từ DB ===
            String duongDan = db.getFileCongViec(id); // ví dụ: D:/uploads\abc.docx;D:/uploads\def.jpg

            if (duongDan != null && !duongDan.trim().isEmpty()) {
                String[] files = duongDan.split(";");
                for (String path : files) {
                    File file = new File(path.trim());
                    if (file.exists() && file.isFile()) {
                        file.delete();
                    }
                }
            }

            // === Xoá công việc trong DB (bao gồm xoá người nhận phụ nếu cần) ===
            db.xoaCongViec(id);

            response.sendRedirect("./dsCongviec"); // Chuyển hướng sau khi xoá
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Lỗi khi xoá công việc: " + e.getMessage());
        }
    }

    @Override
    public String getServletInfo() {
        return "Xoá công việc và file đính kèm";
    }
}
