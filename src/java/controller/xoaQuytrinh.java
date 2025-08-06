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
public class xoaQuytrinh extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            String stepIdStr = request.getParameter("step_id");
            try {
                KNCSDL db = new KNCSDL();
                int stepId = Integer.parseInt(stepIdStr);
                boolean deleted = db.deleteStepById(stepId);
                if (deleted) {
                    response.setStatus(HttpServletResponse.SC_OK);
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND); // Không tìm thấy để xóa
                }
            } catch (NumberFormatException | SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                e.printStackTrace(); // Ghi log hoặc log ra file
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(xoaQuytrinh.class.getName()).log(Level.SEVERE, null, ex);
            }
            return;
        }

        if ("add".equals(action)) {
            String congViecIdStr = request.getParameter("task_id"); // frontend vẫn gửi là task_id
            String tenBuoc = request.getParameter("name");
            String moTa = request.getParameter("desc");
            String trangThai = request.getParameter("status");
            String ngayBatDau = request.getParameter("start");
            String ngayKetThuc = request.getParameter("end");

            try {
                int congViecId = Integer.parseInt(congViecIdStr);
                KNCSDL db = new KNCSDL();
                int newId = db.insertStep(congViecId, tenBuoc, moTa, trangThai, ngayBatDau, ngayKetThuc);

                if (newId > 0) {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write(String.valueOf(newId));
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("Không thể thêm bước.");
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                e.printStackTrace();
                response.getWriter().write("Lỗi máy chủ");
            }
            return;
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
