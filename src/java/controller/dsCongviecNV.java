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
import jakarta.servlet.http.HttpSession;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Admin
 */
public class dsCongviecNV extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            KNCSDL kn = new KNCSDL();
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");

            // Lấy công việc hiện tại của nhân viên
            List<Map<String, Object>> taskList = kn.getAllTasksNV(email, 0);

            // Lấy công việc lưu trữ
            List<Map<String, Object>> archivedTaskList
                    = kn.getTasksByTinhTrang(email, 0, "Lưu trữ");

            // Lấy công việc đã xoá
            List<Map<String, Object>> deletedTaskList
                    = kn.getTasksByTinhTrang(email, 0, "Đã xóa");

            // Nhãn trạng thái như cũ
            LinkedHashMap<String, String> trangThaiLabels = new LinkedHashMap<>();
            trangThaiLabels.put("Chưa bắt đầu", "Chưa bắt đầu");
            trangThaiLabels.put("Đang thực hiện", "Đang thực hiện");
            trangThaiLabels.put("Đã hoàn thành", "Đã hoàn thành");
            trangThaiLabels.put("Trễ hạn", "Trễ hạn");

            // Gửi sang JSP
            request.setAttribute("taskList", taskList);
            request.setAttribute("archivedTaskList", archivedTaskList);
            request.setAttribute("deletedTaskList", deletedTaskList);
            request.setAttribute("trangThaiLabels", trangThaiLabels);

            request.getRequestDispatcher("/user_task.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
