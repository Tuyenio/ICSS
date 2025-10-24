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
import java.util.List;
import java.util.Map;
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
                
                // Lấy thông tin tiến độ trước khi xóa
                Map<String, Object> stepInfo = db.getStepById(stepId);
                String tenBuoc = stepInfo != null ? (String) stepInfo.get("ten_buoc") : "Tiến độ";
                
                int congViecId = db.getCongViecIdByBuocId(stepId);
                String tencv = db.getTenCongViecById(congViecId);
                List<Integer> danhSachIdNhan = db.getDanhSachNguoiNhanId(congViecId);
                String tieuDeTB = "Xóa bỏ quy trình";
                String noiDungTB = "Công việc: " + tencv + " vừa xóa bỏ một quy trình";
                boolean deleted = db.deleteStepById(stepId);
                if (deleted) {
                    db = new KNCSDL();
                    for (int nhanId : danhSachIdNhan) {
                        db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Cập nhật");
                    }
                    
                    // Ghi log lịch sử CHI TIẾT
                    jakarta.servlet.http.HttpSession session = request.getSession(false);
                    int userId = 0;
                    if (session != null && session.getAttribute("userId") != null) {
                        try {
                            userId = Integer.parseInt(session.getAttribute("userId").toString());
                        } catch (Exception e) {}
                    }
                    if (userId > 0) {
                        String logMsg = "🗑️ Xóa tiến độ: '" + tenBuoc + "'";
                        db.themLichSuCongViec(congViecId, userId, logMsg);
                    }
                    
                    response.setStatus(HttpServletResponse.SC_OK);
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND); // Không tìm thấy để xóa
                }
            } catch (NumberFormatException | SQLException e) {
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
            int congViecId = Integer.parseInt(congViecIdStr);
            try {
                KNCSDL db = new KNCSDL();
                int newId = db.insertStep(congViecId, tenBuoc, moTa, trangThai, ngayBatDau, ngayKetThuc);
                if (newId > 0) {
                    db = new KNCSDL();
                    List<Integer> danhSachIdNhan = db.getDanhSachNguoiNhanId(congViecId);
                    String tencv = db.getTenCongViecById(congViecId);
                    String tieuDeTB = "Thêm mới quy trình";
                    String noiDungTB = "Công việc: " + tencv + " vừa được thêm quy trình mới";
                    for (int nhanId : danhSachIdNhan) {
                        db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Cập nhật");
                    }
                    
                    // Ghi log lịch sử CHI TIẾT
                    jakarta.servlet.http.HttpSession session = request.getSession(false);
                    int userId = 0;
                    if (session != null && session.getAttribute("userId") != null) {
                        try {
                            userId = Integer.parseInt(session.getAttribute("userId").toString());
                        } catch (Exception e) {}
                    }
                    if (userId > 0) {
                        StringBuilder logMsg = new StringBuilder("➕ Thêm tiến độ mới: '" + tenBuoc + "'");
                        logMsg.append(" | Trạng thái: ").append(trangThai);
                        if (ngayBatDau != null && !ngayBatDau.isEmpty()) {
                            logMsg.append(" | Ngày bắt đầu: ").append(ngayBatDau);
                        }
                        if (ngayKetThuc != null && !ngayKetThuc.isEmpty()) {
                            logMsg.append(" | Deadline: ").append(ngayKetThuc);
                        }
                        if (moTa != null && !moTa.isEmpty()) {
                            String moTaShort = moTa.length() > 50 ? moTa.substring(0, 50) + "..." : moTa;
                            logMsg.append(" | Mô tả: \"").append(moTaShort).append("\"");
                        }
                        db.themLichSuCongViec(congViecId, userId, logMsg.toString());
                    }
                    
                    response.setStatus(HttpServletResponse.SC_OK);
                    db.close();
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
