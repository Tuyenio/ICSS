package controller;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Admin
 */
public class luuQuyenNV extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        try {
            req.setCharacterEncoding("UTF-8");
            resp.setContentType("application/json; charset=UTF-8");
            
            int id = Integer.parseInt(req.getParameter("id"));
            String[] quyen = req.getParameterValues("quyen[]");
            
            KNCSDL kn = new KNCSDL();
            boolean ok = kn.luuPhanQuyenNhanVien(id, quyen);
            
            String json = ok ? "{\"status\":\"ok\"}" : "{\"status\":\"error\"}";
            
            resp.getWriter().write(json);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(luuQuyenNV.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SQLException ex) {
            Logger.getLogger(luuQuyenNV.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
