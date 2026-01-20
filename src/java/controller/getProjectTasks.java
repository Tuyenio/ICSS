package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.List;
import java.util.Map;
import com.google.gson.Gson;

@WebServlet(name = "getProjectTasks", urlPatterns = {"/getProjectTasks"})
public class getProjectTasks extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            String projectName = req.getParameter("projectName");
            String status = req.getParameter("status");
            String tuNgay = req.getParameter("tu_ngay");
            String denNgay = req.getParameter("den_ngay");
            
            KNCSDL kn = new KNCSDL();
            
            // Lấy chi tiết công việc của dự án theo trạng thái
            List<Map<String, Object>> tasks = kn.getProjectTasksByStatus(projectName, status, tuNgay, denNgay);
            
            // Chuyển đổi thành JSON
            Gson gson = new Gson();
            String json = gson.toJson(tasks);
            
            PrintWriter out = resp.getWriter();
            out.print(json);
            out.flush();
            
        } catch (Exception e) {
            resp.setStatus(500);
            PrintWriter out = resp.getWriter();
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
            out.flush();
            e.printStackTrace();
        }
    }
}
