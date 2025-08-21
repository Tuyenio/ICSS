/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import com.mysql.cj.xdevapi.DbDoc;
import java.io.IOException;
import java.sql.*;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author Admin
 */
public class apiTaskSteps extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String taskId = request.getParameter("task_id");

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (taskId == null || taskId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Missing task_id\"}");
            return;
        }

        try {
            KNCSDL db = new KNCSDL();
            ResultSet rs = db.getStepsRawByTaskId(taskId);

            StringBuilder json = new StringBuilder();
            json.append("[");

            boolean first = true;
            while (rs.next()) {
                if (!first) {
                    json.append(",");
                }
                json.append("{");

                json.append("\"id\":\"").append(escapeJson(rs.getString("id"))).append("\",");
                json.append("\"name\":\"").append(escapeJson(rs.getString("ten_buoc"))).append("\",");
                json.append("\"desc\":\"").append(escapeJson(rs.getString("mo_ta"))).append("\",");
                json.append("\"status\":\"").append(escapeJson(rs.getString("trang_thai"))).append("\",");
                json.append("\"start\":\"").append(escapeJson(rs.getString("ngay_bat_dau"))).append("\",");
                json.append("\"end\":\"").append(escapeJson(rs.getString("ngay_ket_thuc"))).append("\"");

                json.append("}");
                first = false;
            }

            json.append("]");
            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("[]");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain; charset=UTF-8");

        PrintWriter out = response.getWriter();

        String stepIdStr = request.getParameter("step_id");
        String name = request.getParameter("name");
        String desc = request.getParameter("desc");
        String status = request.getParameter("status");
        String start = request.getParameter("start");
        String end = request.getParameter("end");

        if (stepIdStr == null || name == null || status == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("Thiếu thông tin bắt buộc.");
            return;
        }

        try {
            int stepId = Integer.parseInt(stepIdStr);

            KNCSDL db = new KNCSDL();
            boolean success = db.updateStepById(stepId, name, desc, status, start, end);

            if (success) {
                db = new KNCSDL();
                int congviecId = db.getCongViecIdByBuocId(stepId);
                int nhanId = db.getNguoiNhanIdByCongViecId(congviecId);
                String tencv = db.getTenCongViecById(congviecId);
                String tieuDeTB = "Cập nhật quy trình";
                String noiDungTB = "Công việc: "+ tencv + " vừa được cập nhật quy trình mới";
                db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Cập nhật");
                response.setStatus(HttpServletResponse.SC_OK);
                
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("Không tìm thấy bước để cập nhật.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("Lỗi máy chủ: " + e.getMessage());
        }
        
    }

    // Escape chuỗi JSON thủ công
    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\"", "\\\"")
                .replace("\n", "")
                .replace("\r", "");
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
