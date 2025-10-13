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

            // 🟢 Tham số lọc
            String trangThai = request.getParameter("trangThai");   // trạng_thái công việc (đang thực hiện/hoàn thành/…)
            String tinhTrang = request.getParameter("tinhTrang");   // tình_trạng (archived/active/…)

            System.out.println("🟢 [DEBUG] TrangThai: " + trangThai + " | TinhTrang: " + tinhTrang);

            // 🟢 Lấy danh sách công việc
            List<Map<String, Object>> taskList;
            List<Map<String, Object>> archivedTaskList;
            List<Map<String, Object>> deletedTaskList;

            if (trangThai != null && !trangThai.trim().isEmpty()) {
                // Lọc theo TRẠNG THÁI
                taskList = kn.getTasksByStatus(email, 1, trangThai);
            } else {
                // Không truyền filter → lấy tất cả
                taskList = kn.getAllTasksByProject(email, 1);
            }

            archivedTaskList = kn.getTasksByTinhTrang(email, 1, "Lưu trữ");
            deletedTaskList = kn.getTasksByTinhTrang(email, 1, "Đã xóa");

            // 🟢 Cập nhật trạng thái từ tiến độ (không đụng đến task archived)
            for (Map<String, Object> task : taskList) {
                String tt = (String) task.get("tinh_trang"); // field này được select trong getTasksByTinhTrang / getAll...
                if (tt == null || !tt.equalsIgnoreCase("archived")) {
                    int congViecId = (int) task.get("id");
                    kn.capNhatTrangThaiTuTienDo(congViecId);
                }
            }

            // 🟢 Nhãn lọc trạng thái (business status)
            LinkedHashMap<String, String> trangThaiLabels = new LinkedHashMap<>();
            trangThaiLabels.put("Chưa bắt đầu", "Chưa bắt đầu");
            trangThaiLabels.put("Đang thực hiện", "Đang thực hiện");
            trangThaiLabels.put("Đã hoàn thành", "Đã hoàn thành");
            trangThaiLabels.put("Trễ hạn", "Trễ hạn");

            // 🟢 Gửi dữ liệu ra JSP
            request.setAttribute("taskList", taskList);
            request.setAttribute("trangThaiLabels", trangThaiLabels);
            request.setAttribute("archivedTaskList", archivedTaskList);    
            request.setAttribute("deletedTaskList", deletedTaskList);
            request.setAttribute("selectedTrangThai", trangThai);
            request.setAttribute("selectedTinhTrang", tinhTrang); // để JSP tick đúng “archived” nếu có

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
