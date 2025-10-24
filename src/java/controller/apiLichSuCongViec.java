package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;

public class apiLichSuCongViec extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String taskIdStr = request.getParameter("taskId");
        
        if (taskIdStr == null || taskIdStr.trim().isEmpty()) {
            out.print("[]");
            return;
        }

        try {
            int taskId = Integer.parseInt(taskIdStr);
            KNCSDL db = new KNCSDL();
            List<Map<String, Object>> history = db.getLichSuCongViec(taskId);
            
            // Convert to JSON
            out.print(convertToJson(history));
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
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
        return "API lấy lịch sử công việc";
    }
}
