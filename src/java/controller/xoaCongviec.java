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

/**
 *
 * @author Admin
 */
public class xoaCongviec extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idRaw = request.getParameter("id");

        try {
            int id = Integer.parseInt(idRaw);
            KNCSDL db = new KNCSDL();
            db.xoaCongViec(id); // Hàm này bạn đã viết

            response.sendRedirect("./dsCongviec"); // Chuyển hướng sau khi xóa
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Lỗi khi xóa công việc");
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
