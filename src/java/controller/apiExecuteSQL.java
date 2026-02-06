package controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * API để thực thi câu lệnh SQL động và trả về kết quả dưới dạng JSON
 * Endpoint: POST /api/execute-sql
 * Request Body: {"command": "SELECT * FROM table_name"}
 * Response: JSON array của kết quả query
 */
@WebServlet(name = "apiExecuteSQL", urlPatterns = {"/api/execute-sql"})
public class apiExecuteSQL extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Thiết lập encoding và content type
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        
        try {
            // Đọc request body
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            
            String requestBody = sb.toString();
            System.out.println("[apiExecuteSQL] Request body: " + requestBody);
            
            // Parse JSON để lấy command
            JsonObject jsonRequest = JsonParser.parseString(requestBody).getAsJsonObject();
            
            if (!jsonRequest.has("command")) {
                // Thiếu trường command
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("error", "Thiếu trường 'command' trong request");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(gson.toJson(errorResponse));
                out.flush();
                return;
            }
            
            String sqlCommand = jsonRequest.get("command").getAsString();
            System.out.println("[apiExecuteSQL] SQL Command: " + sqlCommand);
            
            // Kiểm tra command không rỗng
            if (sqlCommand == null || sqlCommand.trim().isEmpty()) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("error", "Câu lệnh SQL không được để trống");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(gson.toJson(errorResponse));
                out.flush();
                return;
            }
            
            // ✅ Kiểm tra chỉ cho phép SELECT (bảo mật)
            String trimmedCommand = sqlCommand.trim().toUpperCase();
            if (!trimmedCommand.startsWith("SELECT") && !trimmedCommand.startsWith("SHOW") 
                    && !trimmedCommand.startsWith("DESCRIBE") && !trimmedCommand.startsWith("DESC")) {
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("success", false);
                errorResponse.put("error", "❌ Chỉ cho phép câu lệnh SELECT. INSERT, UPDATE, DELETE, DROP không được phép!");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print(gson.toJson(errorResponse));
                return;
            }
            
            // Thực thi SQL
            List<Map<String, Object>> resultList = executeSQL(sqlCommand);
            
            // Tạo response thành công
            Map<String, Object> successResponse = new HashMap<>();
            successResponse.put("success", true);
            successResponse.put("data", resultList);
            successResponse.put("rowCount", resultList.size());
            
            response.setStatus(HttpServletResponse.SC_OK);
            out.print(gson.toJson(successResponse));
            out.flush();
            
        } catch (com.google.gson.JsonSyntaxException e) {
            // Lỗi parse JSON
            System.err.println("[apiExecuteSQL] JSON Syntax Error: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "JSON không hợp lệ: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print(gson.toJson(errorResponse));
            out.flush();
            
        } catch (SQLException e) {
            // Lỗi SQL
            System.err.println("[apiExecuteSQL] SQL Error: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Lỗi SQL: " + e.getMessage());
            errorResponse.put("sqlState", e.getSQLState());
            errorResponse.put("errorCode", e.getErrorCode());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(errorResponse));
            out.flush();
            
        } catch (Exception e) {
            // Lỗi khác
            System.err.println("[apiExecuteSQL] System Error: " + e.getMessage());
            e.printStackTrace();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Lỗi hệ thống: " + e.getMessage());
            errorResponse.put("exceptionType", e.getClass().getName());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(errorResponse));
            out.flush();
            
        } finally {
            out.flush();
        }
    }
    
    /**
     * Thực thi câu lệnh SQL và chuyển đổi ResultSet thành List<Map>
     * @param sqlCommand Câu lệnh SQL cần thực thi
     * @return List các bản ghi dưới dạng Map
     * @throws SQLException
     * @throws ClassNotFoundException
     */
    private List<Map<String, Object>> executeSQL(String sqlCommand) 
            throws SQLException, ClassNotFoundException {
        
        List<Map<String, Object>> resultList = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            // Kết nối database qua KNCSDL
            System.out.println("[executeSQL] Tạo kết nối KNCSDL...");
            KNCSDL kn = null;
            try {
                kn = new KNCSDL();
                System.out.println("[executeSQL] KNCSDL khởi tạo thành công");
            } catch (ClassNotFoundException e) {
                System.err.println("[executeSQL] Lỗi ClassNotFoundException: " + e.getMessage());
                throw e;
            } catch (SQLException e) {
                System.err.println("[executeSQL] Lỗi SQLException khi kết nối DB: " + e.getMessage());
                throw e;
            }
            
            if (kn == null) {
                System.err.println("[executeSQL] KNCSDL is null!");
                throw new SQLException("Không thể khởi tạo KNCSDL");
            }
            
            conn = kn.cn;
            if (conn == null) {
                System.err.println("[executeSQL] Connection is null!");
                throw new SQLException("Kết nối database là null");
            }
            System.out.println("[executeSQL] Kết nối database thành công");
            
            // Tạo statement và thực thi
            stmt = conn.createStatement();
            
            // Kiểm tra loại câu lệnh (chỉ cho SELECT)
            String commandType = sqlCommand.trim().toUpperCase();
            
            if (commandType.startsWith("SELECT") || commandType.startsWith("SHOW") 
                    || commandType.startsWith("DESCRIBE") || commandType.startsWith("DESC")) {
                // Câu lệnh SELECT - trả về ResultSet
                rs = stmt.executeQuery(sqlCommand);
                
                // Lấy metadata để biết số cột và tên cột
                ResultSetMetaData metaData = rs.getMetaData();
                int columnCount = metaData.getColumnCount();
                
                // Duyệt qua từng dòng kết quả
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    
                    // Duyệt qua từng cột
                    for (int i = 1; i <= columnCount; i++) {
                        String columnName = metaData.getColumnLabel(i);
                        Object value = rs.getObject(i);
                        
                        // Xử lý các kiểu dữ liệu đặc biệt
                        if (value instanceof Date) {
                            value = value.toString();
                        } else if (value instanceof Time) {
                            value = value.toString();
                        } else if (value instanceof Timestamp) {
                            value = value.toString();
                        } else if (value instanceof Blob) {
                            value = "[BLOB]";
                        } else if (value instanceof Clob) {
                            value = "[CLOB]";
                        }
                        
                        row.put(columnName, value);
                    }
                    
                    resultList.add(row);
                }
                
            } else {
                // ❌ Không cho phép các câu lệnh khác ngoài SELECT
                throw new SQLException("❌ Chỉ cho phép câu lệnh SELECT!");
            }
            
        } finally {
            // Đóng tài nguyên
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { /* ignored */ }
            }
            if (stmt != null) {
                try { stmt.close(); } catch (SQLException e) { /* ignored */ }
            }
            // Lưu ý: Connection được quản lý bởi KNCSDL, không đóng ở đây
        }
        
        return resultList;
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        Map<String, Object> info = new HashMap<>();
        info.put("endpoint", "/apiExecuteSQL");
        info.put("method", "POST");
        info.put("description", "API để thực thi câu lệnh SQL và trả về kết quả JSON");
        info.put("requestFormat", Map.of("command", "SELECT * FROM table_name"));
        info.put("example", Map.of(
            "url", "POST /apiExecuteSQL",
            "body", Map.of("command", "SELECT * FROM user")
        ));
        
        Gson gson = new Gson();
        out.print(gson.toJson(info));
        out.flush();
    }
    
    @Override
    public String getServletInfo() {
        return "API thực thi SQL động và trả về JSON";
    }
}
