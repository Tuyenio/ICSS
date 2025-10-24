package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

public class locCongviec extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String trangThai = request.getParameter("trang_thai");
        String projectIdStr = request.getParameter("projectId");
        String returnJson = request.getParameter("returnJson"); // "true" nếu cần JSON
        
        Integer projectId = null;
        if (projectIdStr != null && !projectIdStr.trim().isEmpty()) {
            projectId = Integer.parseInt(projectIdStr);
        }

        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");

            KNCSDL db = new KNCSDL();
            String vaiTro = db.getVaiTroByEmail(email); // Lấy vai trò người dùng từ DB

            List<Map<String, Object>> taskList;

            if ("Admin".equalsIgnoreCase(vaiTro)) {
                String phong = request.getParameter("phong_ban");
                String phongban = null;

                if (phong != null && !phong.trim().isEmpty()) {
                    int idphong = Integer.parseInt(phong);
                    phongban = db.getPhongNameById(idphong);
                }

                taskList = db.locCongViec(keyword, phongban, trangThai, projectId);

            } else if ("Quản lý".equalsIgnoreCase(vaiTro)) {
                taskList = db.locCongViecQL(keyword, trangThai, email, projectId);

            } else {
                taskList = db.locCongViecNV(keyword, trangThai, email, projectId);
            }

            // Kiểm tra xem cần trả về JSON hay HTML
            if ("true".equalsIgnoreCase(returnJson)) {
                // Trả về JSON cho List View và Calendar View
                response.setContentType("application/json;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.print(convertToJson(taskList));
                out.flush();
            } else {
                // Trả về HTML cho Kanban View (giữ nguyên logic cũ)
                request.setAttribute("taskList", taskList);
                
                if ("Admin".equalsIgnoreCase(vaiTro) || "Quản lý".equalsIgnoreCase(vaiTro)) {
                    RequestDispatcher dispatcher = request.getRequestDispatcher("kanban-board.jsp");
                    dispatcher.forward(request, response);
                } else {
                    RequestDispatcher dispatcher = request.getRequestDispatcher("kanban-board-nv.jsp");
                    dispatcher.forward(request, response);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            
            // Trả về error message tùy theo format được yêu cầu
            if ("true".equalsIgnoreCase(returnJson)) {
                response.setContentType("application/json;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.print("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
            }
        }
    }
    
    /**
     * Chuyển đổi List<Map> thành JSON string
     */
    private String convertToJson(List<Map<String, Object>> list) {
        if (list == null || list.isEmpty()) {
            return "[]";
        }
        
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            Map<String, Object> map = list.get(i);
            json.append("{");
            
            int j = 0;
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                
                json.append("\"").append(key).append("\":");
                
                if (value == null) {
                    json.append("null");
                } else if (value instanceof Number) {
                    json.append(value);
                } else {
                    json.append("\"").append(escapeJson(value.toString())).append("\"");
                }
                
                if (j < map.size() - 1) {
                    json.append(",");
                }
                j++;
            }
            
            json.append("}");
            if (i < list.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        
        return json.toString();
    }
    
    /**
     * Escape các ký tự đặc biệt trong JSON
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }

    @Override
    public String getServletInfo() {
        return "Lọc công việc theo vai trò và trả HTML hoặc JSON";
    }
}
