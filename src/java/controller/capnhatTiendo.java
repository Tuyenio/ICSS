/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Admin
 */
public class capnhatTiendo extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            KNCSDL kn = new KNCSDL();
            int taskId = Integer.parseInt(request.getParameter("cong_viec_id"));
            int percent = Integer.parseInt(request.getParameter("phan_tram"));
            
            boolean success = kn.capNhatTienDo(taskId, percent);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(capnhatTiendo.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SQLException ex) {
            Logger.getLogger(capnhatTiendo.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
