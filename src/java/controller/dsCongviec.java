package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class dsCongviec extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            KNCSDL kn = new KNCSDL();
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");

            // 🟢 Nhận tham số lọc trạng thái (từ dashboard)
            String trangThai = request.getParameter("trangThai");
            System.out.println("🟢 [DEBUG] TrangThai được truyền vào: " + trangThai);

            // 🟢 Lấy danh sách công việc có thể lọc theo trạng thái
            List<Map<String, Object>> taskList;
            if (trangThai != null && !trangThai.trim().isEmpty()) {
                // Gọi hàm lọc theo trạng thái (bạn cần thêm vào KNCSDL nếu chưa có)
                taskList = kn.getTasksByStatus(email, 1, trangThai);
            } else {
                // Mặc định lấy tất cả công việc
                taskList = kn.getAllTasksByProject(email, 1);
            }

            // 🟢 Cập nhật trạng thái từng công việc trước khi render
            for (Map<String, Object> task : taskList) {
                int congViecId = (int) task.get("id");
                kn.capNhatTrangThaiTuTienDo(congViecId);
            }

            // 🟢 Map giữ thứ tự hiển thị các cột
            LinkedHashMap<String, String> trangThaiLabels = new LinkedHashMap<>();
            trangThaiLabels.put("Chưa bắt đầu", "Chưa bắt đầu");
            trangThaiLabels.put("Đang thực hiện", "Đang thực hiện");
            trangThaiLabels.put("Đã hoàn thành", "Đã hoàn thành");
            trangThaiLabels.put("Trễ hạn", "Trễ hạn");

            // 🟢 Gửi dữ liệu ra JSP
            request.setAttribute("taskList", taskList);
            request.setAttribute("trangThaiLabels", trangThaiLabels);
            request.setAttribute("selectedTrangThai", trangThai); // để JSP chọn đúng trạng thái

            // 🟢 Chuyển trang
            request.getRequestDispatcher("/task.jsp").forward(request, response);

        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(dsCongviec.class.getName()).log(Level.SEVERE, null, ex);
            throw new ServletException(ex);
        }
    }

    @Override
    public String getServletInfo() {
        return "Hiển thị danh sách công việc, có thể lọc theo trạng thái";
    }
}
