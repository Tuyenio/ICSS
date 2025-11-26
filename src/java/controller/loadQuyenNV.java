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
public class loadQuyenNV extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        try {
            
            int id = Integer.parseInt(req.getParameter("id"));
            
            KNCSDL kn = null;
            try {
                kn = new KNCSDL();
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(loadQuyenNV.class.getName()).log(Level.SEVERE, null, ex);
            } catch (SQLException ex) {
                Logger.getLogger(loadQuyenNV.class.getName()).log(Level.SEVERE, null, ex);
            }
            List<String> quyen = kn.getQuyenTheoNhanVien(id);
            
            resp.setContentType("application/json; charset=UTF-8");
            
            // Tự build JSON array
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < quyen.size(); i++) {
                json.append("\"").append(quyen.get(i)).append("\"");
                if (i < quyen.size() - 1) json.append(",");
            }
            json.append("]");
            
            resp.getWriter().write(json.toString());
        } catch (SQLException ex) {
            Logger.getLogger(loadQuyenNV.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
