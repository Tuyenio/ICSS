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
import java.util.*;

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
                json.append("\"end\":\"").append(escapeJson(rs.getString("ngay_ket_thuc"))).append("\",");

                // 🔹 Lấy danh sách người nhận cho step này
                int stepId = rs.getInt("id");
                List<Map<String, Object>> nguoiNhanList = new KNCSDL().getNguoiNhanByStepId(stepId);

                json.append("\"receivers\":[");
                for (int i = 0; i < nguoiNhanList.size(); i++) {
                    Map<String, Object> nguoi = nguoiNhanList.get(i);
                    if (i > 0) {
                        json.append(",");
                    }
                    json.append("{")
                            .append("\"id\":").append(nguoi.get("id")).append(",")
                            .append("\"name\":\"").append(escapeJson((String) nguoi.get("ten"))).append("\"")
                            .append("}");
                }
                json.append("]");

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

            // Lấy thông tin tiến độ cũ để so sánh
            Map<String, Object> stepCu = db.getStepById(stepId);

            boolean success = db.updateStepById(stepId, name, desc, status, start, end);

            if (success) {
                String processNguoiNhan = request.getParameter("process_nguoi_nhan");
                if (processNguoiNhan != null) {
                    KNCSDL dbNN = null;
                    try {
                        dbNN = new KNCSDL();
                        // xóa người nhận cũ của bước
                        dbNN.deleteNguoiNhanByStepId(stepId);

                        String[] arr = processNguoiNhan.split(",");
                        for (String sId : arr) {
                            sId = sId.trim();
                            if (sId.isEmpty()) {
                                continue;
                            }
                            try {
                                int nhanId = Integer.parseInt(sId);
                                dbNN.insertNguoiNhanQuyTrinh(stepId, nhanId);
                            } catch (NumberFormatException ex) {
                                // bỏ qua id không hợp lệ
                            }
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    } finally {
                        if (dbNN != null) {
                            try {
                                dbNN.close();
                            } catch (Exception ignore) {
                            }
                        }
                    }
                }

                db = new KNCSDL();
                int congviecId = db.getCongViecIdByBuocId(stepId);
                String tencv = db.getTenCongViecById(congviecId);
                List<Integer> danhSachNguoiNhan = db.getDanhSachNguoiNhanId(congviecId);

                String tieuDeTB = "Cập nhật quy trình";
                String noiDungTB = "Công việc: " + tencv + " vừa được cập nhật quy trình mới";

                for (int nhanId : danhSachNguoiNhan) {
                    String role = db.getVaiTroById(nhanId);
                    String link = "";

                    // 🔥 Nếu là Admin hoặc Quản lý → vào giao diện Admin
                    if (role != null && (role.equalsIgnoreCase("Admin") || role.equalsIgnoreCase("Quản lý"))) {
                        link = "dsCongviec?taskId=" + congviecId;
                    } else {
                        // 🔥 Ngược lại nhân viên dùng giao diện của NV
                        link = "dsCongviecNV?taskId=" + congviecId;
                    }
                    db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Cập nhật", link);
                }

                // Ghi log lịch sử CHI TIẾT từng trường
                jakarta.servlet.http.HttpSession session = request.getSession(false);
                int userId = 0;
                if (session != null && session.getAttribute("userId") != null) {
                    try {
                        userId = Integer.parseInt(session.getAttribute("userId").toString());
                    } catch (Exception e) {
                    }
                }

                if (userId > 0 && stepCu != null) {
                    java.util.List<String> thayDoiList = new java.util.ArrayList<>();

                    // So sánh tên tiến độ
                    String tenCu = (String) stepCu.get("ten_buoc");
                    if (!safeStringEquals(tenCu, name)) {
                        thayDoiList.add("📝 Đổi tên tiến độ: '" + (tenCu != null ? tenCu : "(trống)") + "' → '" + name + "'");
                    }

                    // So sánh mô tả
                    String moTaCu = (String) stepCu.get("mo_ta");
                    if (!safeStringEquals(moTaCu, desc)) {
                        thayDoiList.add("� Cập nhật mô tả tiến độ");
                    }

                    // So sánh trạng thái
                    String trangThaiCu = (String) stepCu.get("trang_thai");
                    if (!safeStringEquals(trangThaiCu, status)) {
                        thayDoiList.add("🔄 Đổi trạng thái tiến độ: '" + (trangThaiCu != null ? trangThaiCu : "?") + "' → '" + status + "'");
                    }

                    // So sánh ngày bắt đầu
                    String ngayBDCu = (String) stepCu.get("ngay_bat_dau");
                    if (!safeStringEquals(ngayBDCu, start)) {
                        thayDoiList.add("📅 Đổi ngày bắt đầu: '" + (ngayBDCu != null ? ngayBDCu : "(chưa có)") + "' → '" + (start != null && !start.isEmpty() ? start : "(chưa có)") + "'");
                    }

                    // So sánh ngày kết thúc
                    String ngayKTCu = (String) stepCu.get("ngay_ket_thuc");
                    if (!safeStringEquals(ngayKTCu, end)) {
                        thayDoiList.add("📅 Đổi deadline tiến độ: '" + (ngayKTCu != null ? ngayKTCu : "(chưa có)") + "' → '" + (end != null && !end.isEmpty() ? end : "(chưa có)") + "'");
                    }

                    // Ghi log nếu có thay đổi
                    if (!thayDoiList.isEmpty()) {
                        String logMsg = "🔧 [Tiến độ: " + name + "] " + String.join(" | ", thayDoiList);
                        db.themLichSuCongViec(congviecId, userId, logMsg);
                    }
                }

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

    // Helper method để so sánh an toàn 2 chuỗi
    private boolean safeStringEquals(String a, String b) {
        if (a == null && b == null) {
            return true;
        }
        if (a == null || b == null) {
            return false;
        }
        return a.trim().equals(b.trim());
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
