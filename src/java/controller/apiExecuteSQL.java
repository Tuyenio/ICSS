package controller;

import com.google.gson.Gson;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

/**
 * ⛔ ĐÃ VÔ HIỆU HÓA TẠM THỜI (2026-06-09) vì lý do bảo mật.
 *
 * Endpoint cũ `POST /api/execute-sql` cho phép thực thi câu lệnh SQL tùy ý
 * và KHÔNG yêu cầu đăng nhập (AuthFilter bỏ qua mọi đường dẫn /api/*).
 * Đây là lỗ hổng CRITICAL: bất kỳ ai cũng có thể đọc toàn bộ database.
 *
 * Toàn bộ logic thực thi SQL đã được gỡ bỏ. Endpoint nay luôn trả về 403.
 * Lịch sử mã nguồn gốc còn trong git nếu cần tham khảo.
 *
 * KHÔNG bật lại nếu chưa: (1) bắt buộc xác thực + phân quyền admin,
 * (2) bỏ nhánh bypass /api/ trong AuthFilter, (3) giới hạn whitelist truy vấn.
 */
@WebServlet(name = "apiExecuteSQL", urlPatterns = {"/api/execute-sql"})
public class apiExecuteSQL extends HttpServlet {

    private void deny(HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.setContentType("application/json; charset=UTF-8");
        Map<String, Object> body = new HashMap<>();
        body.put("success", false);
        body.put("error", "Endpoint đã bị vô hiệu hóa vì lý do bảo mật.");
        try (PrintWriter out = response.getWriter()) {
            out.print(new Gson().toJson(body));
            out.flush();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        deny(response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        deny(response);
    }

    @Override
    public String getServletInfo() {
        return "apiExecuteSQL — đã vô hiệu hóa tạm thời (bảo mật)";
    }
}
