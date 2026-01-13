package controller;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class dsNhomduan extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");
        
        // Kiểm tra nếu là request API (JSON)
        String format = req.getParameter("format");

        try {
            KNCSDL kn = new KNCSDL();
            
            if ("json".equals(format)) {
                // Trả về JSON cho API
                resp.setContentType("application/json; charset=UTF-8");
                List<Map<String, Object>> duAnList = kn.getAllDuAnWithTasks();
                
                Gson gson = new Gson();
                String json = gson.toJson(duAnList);
                
                PrintWriter out = resp.getWriter();
                out.print(json);
                out.flush();
            } else {
                // Trả về JSP
                List<Map<String, Object>> duAnList = kn.getAllDuAnWithTasks();
                req.setAttribute("duAnList", duAnList);
                req.getRequestDispatcher("/nhomDuan.jsp").forward(req, resp);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(500, "Lỗi lấy danh sách dự án: " + e.getMessage());
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(dsNhomduan.class.getName()).log(Level.SEVERE, null, ex);
            resp.sendError(500, "Lỗi kết nối database");
        }
    }
}

