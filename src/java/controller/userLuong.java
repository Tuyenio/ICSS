package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

/**
 * Servlet xử lý lương & KPI cho nhân viên
 * @author Admin
 */
public class userLuong extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("email");
            
            if (email == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            KNCSDL kn = new KNCSDL();
            
            // Lấy thông tin nhân viên
            Map<String, Object> nhanVienInfo = kn.getNhanVienByEmail(email);
            if (nhanVienInfo == null) {
                response.getWriter().println("<h3 style='color:red'>❌ Không tìm thấy thông tin nhân viên!</h3>");
                return;
            }
            
            int nhanVienId = (Integer) nhanVienInfo.get("id");
            
            // Lấy tham số tháng/năm
            String thang = request.getParameter("thang");
            String nam = request.getParameter("nam");
            
            if (thang == null || thang.isEmpty()) {
                Calendar cal = Calendar.getInstance();
                thang = String.valueOf(cal.get(Calendar.MONTH) + 1);
                nam = String.valueOf(cal.get(Calendar.YEAR));
            }
            
            // Lấy thông tin lương tháng hiện tại
            Map<String, Object> thongTinLuong = kn.getThongTinLuongUser(nhanVienId, Integer.parseInt(thang), Integer.parseInt(nam));
            
            // Lấy lịch sử lương 12 tháng gần nhất
            List<Map<String, Object>> lichSuLuong = kn.getLichSuLuongUser(nhanVienId);
            
            // Lấy thông tin KPI tháng hiện tại
            List<Map<String, Object>> kpiList = kn.getKPIUser(nhanVienId, Integer.parseInt(thang), Integer.parseInt(nam));
            
            // Lấy tổng hợp KPI
            Map<String, Object> tongHopKPI = kn.getTongHopKPIUser(nhanVienId, Integer.parseInt(thang), Integer.parseInt(nam));
            
            // Lấy danh sách lương & KPI kết hợp
            List<Map<String, Object>> luongKPIList = kn.getLuongKPIUser(nhanVienId);
            
            // Gửi dữ liệu đến JSP
            request.setAttribute("nhanVienInfo", nhanVienInfo);
            request.setAttribute("thongTinLuong", thongTinLuong);
            request.setAttribute("lichSuLuong", lichSuLuong);
            request.setAttribute("kpiList", kpiList);
            request.setAttribute("tongHopKPI", tongHopKPI);
            request.setAttribute("luongKPIList", luongKPIList);
            request.setAttribute("thangHienTai", thang);
            request.setAttribute("namHienTai", nam);
            
            request.getRequestDispatcher("user_salary.jsp").forward(request, response);
            
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(userLuong.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("<h3 style='color:red'>❌ Lỗi: " + ex.getMessage() + "</h3>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        
        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("email");
            
            if (email == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Chưa đăng nhập\"}");
                return;
            }
            
            KNCSDL kn = new KNCSDL();
            
            // Lấy thông tin nhân viên
            Map<String, Object> nhanVienInfo = kn.getNhanVienByEmail(email);
            if (nhanVienInfo == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Không tìm thấy thông tin nhân viên\"}");
                return;
            }
            
            int nhanVienId = (Integer) nhanVienInfo.get("id");
            String action = request.getParameter("action");
            
            if ("getLuongByMonth".equals(action)) {
                // Lấy thông tin lương theo tháng
                String thang = request.getParameter("thang");
                String nam = request.getParameter("nam");
                
                Map<String, Object> luongInfo = kn.getThongTinLuongUser(nhanVienId, Integer.parseInt(thang), Integer.parseInt(nam));
                
                if (luongInfo.isEmpty()) {
                    response.getWriter().write("{\"success\": false, \"message\": \"Không có dữ liệu lương tháng này\"}");
                } else {
                    // Convert Map to JSON manually (simple approach)
                    StringBuilder json = new StringBuilder();
                    json.append("{\"success\": true, \"data\": {");
                    
                    boolean first = true;
                    for (Map.Entry<String, Object> entry : luongInfo.entrySet()) {
                        if (!first) json.append(",");
                        json.append("\"").append(entry.getKey()).append("\":");
                        
                        Object value = entry.getValue();
                        if (value instanceof String) {
                            json.append("\"").append(escapeJson(value.toString())).append("\"");
                        } else if (value == null) {
                            json.append("null");
                        } else {
                            json.append(value.toString());
                        }
                        first = false;
                    }
                    
                    json.append("}}");
                    response.getWriter().write(json.toString());
                }
                
            } else if ("getKPIByMonth".equals(action)) {
                // Lấy thông tin KPI theo tháng
                String thang = request.getParameter("thang");
                String nam = request.getParameter("nam");
                
                List<Map<String, Object>> kpiList = kn.getKPIUser(nhanVienId, Integer.parseInt(thang), Integer.parseInt(nam));
                Map<String, Object> tongHopKPI = kn.getTongHopKPIUser(nhanVienId, Integer.parseInt(thang), Integer.parseInt(nam));
                
                StringBuilder json = new StringBuilder();
                json.append("{\"success\": true, \"kpiList\": [");
                
                for (int i = 0; i < kpiList.size(); i++) {
                    if (i > 0) json.append(",");
                    Map<String, Object> kpi = kpiList.get(i);
                    json.append("{");
                    
                    boolean first = true;
                    for (Map.Entry<String, Object> entry : kpi.entrySet()) {
                        if (!first) json.append(",");
                        json.append("\"").append(entry.getKey()).append("\":");
                        
                        Object value = entry.getValue();
                        if (value instanceof String) {
                            json.append("\"").append(escapeJson(value.toString())).append("\"");
                        } else if (value == null) {
                            json.append("null");
                        } else {
                            json.append(value.toString());
                        }
                        first = false;
                    }
                    json.append("}");
                }
                
                json.append("], \"tongHop\": {");
                
                boolean first = true;
                for (Map.Entry<String, Object> entry : tongHopKPI.entrySet()) {
                    if (!first) json.append(",");
                    json.append("\"").append(entry.getKey()).append("\":");
                    
                    Object value = entry.getValue();
                    if (value instanceof String) {
                        json.append("\"").append(escapeJson(value.toString())).append("\"");
                    } else if (value == null) {
                        json.append("null");
                    } else {
                        json.append(value.toString());
                    }
                    first = false;
                }
                
                json.append("}}");
                response.getWriter().write(json.toString());
                
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Hành động không hợp lệ\"}");
            }
            
        } catch (Exception ex) {
            Logger.getLogger(userLuong.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().write("{\"success\": false, \"message\": \"Lỗi hệ thống: " + ex.getMessage() + "\"}");
        }
    }

    // Hàm escape JSON đơn giản
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    @Override
    public String getServletInfo() {
        return "Servlet xử lý lương & KPI cho nhân viên";
    }
}
