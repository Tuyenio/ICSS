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

public class dsCongviecDuan extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        try {
            KNCSDL kn = new KNCSDL();
            HttpSession session = req.getSession();
            String email = (String) session.getAttribute("userEmail");
            String chucVu = (String) session.getAttribute("chucVu");
            String projectIdStr = req.getParameter("projectId");
            String trangThai = req.getParameter("trangThai");
            String tinhTrang = req.getParameter("tinhTrang");

            if (projectIdStr == null) {
                resp.sendRedirect("dsDuan"); // không có ID thì quay lại danh sách dự án
                return;
            }

            int projectId = Integer.parseInt(projectIdStr);
            String tenDuan = kn.getTenDuanById(projectId);

            // 🟢 Danh sách công việc chính
            List<Map<String, Object>> taskList;

            if (trangThai != null && !trangThai.trim().isEmpty()) {
                taskList = kn.getTasksByStatus(email, projectId, trangThai);
            } else {
                taskList = kn.getAllTasksByProject(email, projectId);
            }

            // 🟢 Các danh sách phụ: archived, deleted
            List<Map<String, Object>> archivedTaskList = kn.getTasksByTinhTrang(email, projectId, "Lưu trữ");
            List<Map<String, Object>> deletedTaskList = kn.getTasksByTinhTrang(email, projectId, "Đã xóa");

            // 🟢 Cập nhật trạng thái từ tiến độ
            for (Map<String, Object> task : taskList) {
                String tt = (String) task.get("tinh_trang");
                if (tt == null || !tt.equalsIgnoreCase("Lưu trữ")) {
                    int congViecId = (int) task.get("id");
                    kn.capNhatTrangThaiTuTienDo(congViecId);
                }
            }

            // 🟢 Nhãn trạng thái
            LinkedHashMap<String, String> trangThaiLabels = new LinkedHashMap<>();
            trangThaiLabels.put("Chưa bắt đầu", "Chưa bắt đầu");
            trangThaiLabels.put("Đang thực hiện", "Đang thực hiện");
            trangThaiLabels.put("Đã hoàn thành", "Đã hoàn thành");
            trangThaiLabels.put("Trễ hạn", "Trễ hạn");

            // 🟢 Gửi dữ liệu sang JSP
            req.setAttribute("taskList", taskList);
            req.setAttribute("tenDuan", tenDuan);
            req.setAttribute("projectId", projectId);
            req.setAttribute("trangThaiLabels", trangThaiLabels);
            req.setAttribute("archivedTaskList", archivedTaskList);
            req.setAttribute("deletedTaskList", deletedTaskList);
            req.setAttribute("selectedTrangThai", trangThai);
            req.setAttribute("selectedTinhTrang", tinhTrang);

            // 🟢 Forward theo chức vụ
            if ("Nhân viên".equalsIgnoreCase(chucVu) || "Thực tập sinh".equalsIgnoreCase(chucVu)) {
                req.getRequestDispatcher("project_tasknv.jsp").forward(req, resp);
            } else {
                req.getRequestDispatcher("project_task.jsp").forward(req, resp);
            }

        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(dsCongviecDuan.class.getName()).log(Level.SEVERE, null, ex);
            throw new ServletException(ex);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi load công việc dự án");
        }
    }

    @Override
    public String getServletInfo() {
        return "Hiển thị danh sách công việc theo dự án, cho phép lọc trạng thái và tình trạng";
    }
}
