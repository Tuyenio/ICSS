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
 * API thông tin - chỉ hỗ trợ GET request
 * Endpoint: GET /api/execute-sql
 * Response: JSON thông tin API
 */
@WebServlet(name = "apiExecuteSQL", urlPatterns = {"/api/execute-sql"})
public class apiExecuteSQL extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        Map<String, Object> info = new HashMap<>();
        info.put("endpoint", "/api/execute-sql");
        info.put("method", "GET");
        info.put("status", "Chỉ hỗ trợ GET request");
        info.put("description", "API thông tin - chỉ hỗ trợ phương thức GET. POST và các phương thức khác sẽ bị từ chối.");
        info.put("note", "API không cho phép POST, PUT, DELETE hoặc các phương thức HTTP khác.");
        
        Gson gson = new Gson();
        out.print(gson.toJson(info));
        out.flush();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        response.setHeader("Allow", "GET");
        PrintWriter out = response.getWriter();
        
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", "Phương thức POST không được phép. Chỉ hỗ trợ GET.");
        
        Gson gson = new Gson();
        out.print(gson.toJson(error));
        out.flush();
    
    @Override
    public String getServletInfo() {
        return "API thực thi SQL động và trả về JSON";
    }
}
