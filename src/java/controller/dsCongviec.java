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
            String taskIdStr = request.getParameter("taskId");
            Integer taskId = null;
            if (taskIdStr != null && !taskIdStr.trim().isEmpty()) {
                taskId = Integer.parseInt(taskIdStr);
            }

            // 🟢 Tham số lọc
            String trangThai = request.getParameter("trangThai");
            String tinhTrang = request.getParameter("tinhTrang");
            String phongBanStr = request.getParameter("phongBanId");

            Integer phongBanId = null;
            if (phongBanStr != null && !phongBanStr.trim().isEmpty()) {
                phongBanId = Integer.parseInt(phongBanStr);
            }

            // 🟢 Danh sách trả về
            List<Map<String, Object>> taskList;
            List<Map<String, Object>> archivedTaskList;
            List<Map<String, Object>> deletedTaskList;
            if (taskId != null) {

                // Trả về list<map> giống hệt lấy theo phòng ban
                taskList = kn.getTaskByIdLikeList(taskId);

                // Lưu trữ & thùng rác không cần khi mở theo ID
                archivedTaskList = new ArrayList<>();
                deletedTaskList = new ArrayList<>();

                request.setAttribute("taskList", taskList);
                request.setAttribute("archivedTaskList", archivedTaskList);
                request.setAttribute("deletedTaskList", deletedTaskList);
                request.setAttribute("selectedTrangThai", null);
                request.setAttribute("selectedPhongBan", null);

                request.getRequestDispatcher("/task.jsp").forward(request, response);
                return;
            }

            // 🟢 Ưu tiên lọc theo PHÒNG BAN
            if (phongBanId != null) {
                taskList = kn.getTasksByDepartment(email, phongBanId);
            } // 🔹 Nếu lọc theo TRẠNG THÁI
            else if (trangThai != null && !trangThai.trim().isEmpty()) {
                taskList = kn.getTasksByStatus(email, 0, trangThai);
            } // 🔹 Không filter → lấy tất cả
            else {
                taskList = kn.getAllTasksByProject(email, 0);
            }

            archivedTaskList = kn.getTasksByTinhTrang(email, 0, "Lưu trữ");
            deletedTaskList = kn.getTasksByTinhTrang(email, 0, "Đã xóa");

            // 🟢 Cập nhật trạng thái từ tiến độ
            for (Map<String, Object> task : taskList) {
                String tt = (String) task.get("tinh_trang");
                if (tt == null || !tt.equalsIgnoreCase("archived")) {
                    kn.capNhatTrangThaiTuTienDo((int) task.get("id"));
                }
            }

            // 🟢 Nhãn lọc trạng thái
            LinkedHashMap<String, String> trangThaiLabels = new LinkedHashMap<>();
            trangThaiLabels.put("Chưa bắt đầu", "Chưa bắt đầu");
            trangThaiLabels.put("Đang thực hiện", "Đang thực hiện");
            trangThaiLabels.put("Đã hoàn thành", "Đã hoàn thành");
            trangThaiLabels.put("Trễ hạn", "Trễ hạn");

            // 🟢 Gửi dữ liệu về JSP
            request.setAttribute("taskList", taskList);
            request.setAttribute("trangThaiLabels", trangThaiLabels);
            request.setAttribute("archivedTaskList", archivedTaskList);
            request.setAttribute("deletedTaskList", deletedTaskList);
            request.setAttribute("selectedTrangThai", trangThai);
            request.setAttribute("selectedTinhTrang", tinhTrang);
            request.setAttribute("selectedPhongBan", phongBanId); // ⚡ Gửi phòng ban đã chọn

            request.getRequestDispatcher("/task.jsp").forward(request, response);

        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(dsCongviec.class.getName()).log(Level.SEVERE, null, ex);
            throw new ServletException(ex);
        }
    }

    @Override
    public String getServletInfo() {
        return "Hiển thị danh sách công việc, có thể lọc theo trạng thái hoặc phòng ban";
    }
}