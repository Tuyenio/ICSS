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

            if (projectIdStr == null) {
                resp.sendRedirect("projects"); // quay lại danh sách nếu không có id
                return;
            }

            int projectId = Integer.parseInt(projectIdStr);
            String tenDuan = kn.getTenDuanById(projectId);

            // 1. Lấy danh sách công việc theo dự án
            List<Map<String, Object>> tasks = kn.getAllTasksByProject(email, projectId);

            // 2. Cập nhật trạng thái từng công việc trước khi render
            for (Map<String, Object> task : tasks) {
                int congViecId = (int) task.get("id");
                kn.capNhatTrangThaiTuTienDo(congViecId);
            }

            // 3. Map giữ nhãn trạng thái để JSP hiển thị có trật tự
            LinkedHashMap<String, String> trangThaiLabels = new LinkedHashMap<>();
            trangThaiLabels.put("Chưa bắt đầu", "Chưa bắt đầu");
            trangThaiLabels.put("Đang thực hiện", "Đang thực hiện");
            trangThaiLabels.put("Đã hoàn thành", "Đã hoàn thành");
            trangThaiLabels.put("Trễ hạn", "Trễ hạn");

            // 4. Gửi dữ liệu sang JSP
            req.setAttribute("taskList", tasks);
            req.setAttribute("tenDuan", tenDuan);
            req.setAttribute("projectId", projectId);
            req.setAttribute("trangThaiLabels", trangThaiLabels);

            // 5. Chuyển hướng theo chức vụ
            if ("Nhân viên".equalsIgnoreCase(chucVu)) {
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
        return "Hiển thị danh sách công việc theo dự án kèm trạng thái (theo chức vụ)";
    }
}
