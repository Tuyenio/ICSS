package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

public class dsChamCong extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            handleAddAttendance(request, response);
            return;
        }

        if ("edit".equals(action)) {
            // Gọi xử lý sửa giờ chấm công
            handleEditAttendance(request, response);
            return;
        }

        if ("getReports".equals(action)) {
            // Xử lý lấy báo cáo của nhân viên
            handleGetReports(request, response);
            return;
        }

        if ("getReportByAttendance".equals(action)) {
            // Xử lý lấy báo cáo theo ID chấm công cụ thể
            handleGetReportByAttendance(request, response);
            return;
        }

        try {
            KNCSDL kn = new KNCSDL();

            // Lấy tham số lọc từ request
            String thang = request.getParameter("thang");
            String nam = request.getParameter("nam");
            String monthFilter = request.getParameter("month_filter");
            String phongBan = request.getParameter("phong_ban");
            String keyword = request.getParameter("keyword");
            String tenphong = null;

            if (phongBan != null && !phongBan.trim().isEmpty()) {
                int sophong = Integer.parseInt(phongBan);
                tenphong = kn.getPhongNameById(sophong); // chỉ khi có ID mới gọi DB
            }

            // Xử lý month_filter (format: YYYY-MM)
            if (monthFilter != null && !monthFilter.isEmpty()) {
                String[] parts = monthFilter.split("-");
                if (parts.length == 2) {
                    nam = parts[0];
                    thang = parts[1];
                }
            }

            // Nếu không có tham số tháng/năm, sử dụng tháng hiện tại
            if (thang == null || thang.isEmpty()) {
                Calendar cal = Calendar.getInstance();
                thang = String.valueOf(cal.get(Calendar.MONTH) + 1);
                nam = String.valueOf(cal.get(Calendar.YEAR));
            }

            // Lấy dữ liệu chấm công
            List<Map<String, Object>> danhSachChamCong = kn.getDanhSachChamCong(thang, nam, tenphong, keyword, null);

            // Lấy danh sách phòng ban cho filter
            List<Map<String, Object>> danhSachPhongBan = kn.getAllPhongBan();

            // Lấy thống kê tổng quan
            Map<String, Object> thongKe = kn.getThongKeChamCongTongQuan(Integer.parseInt(thang), Integer.parseInt(nam));

            // Gửi dữ liệu đến JSP
            request.setAttribute("danhSachChamCong", danhSachChamCong);
            request.setAttribute("danhSachPhongBan", danhSachPhongBan);
            request.setAttribute("thongKe", thongKe);
            request.setAttribute("thangHienTai", thang);
            request.setAttribute("namHienTai", nam);
            request.setAttribute("phongBanDaChon", phongBan);
            request.setAttribute("keywordDaChon", keyword);

            request.getRequestDispatcher("attendance.jsp").forward(request, response);

        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(dsChamCong.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("<h3 style='color:red'>❌ Lỗi: " + ex.getMessage() + "</h3>");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            KNCSDL db = new KNCSDL();
            boolean success = db.xoaChamCongTheoId(id); // bạn cần viết hàm này trong DAO

            if (success) {
                resp.setStatus(HttpServletResponse.SC_OK);
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void handleEditAttendance(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("attendanceId"));
            String checkIn = req.getParameter("checkInTime");
            String checkOut = req.getParameter("checkOutTime");

            KNCSDL kn = new KNCSDL();
            boolean updated = kn.capNhatChamCong(id, checkIn, checkOut);

            if (updated) {
                resp.sendRedirect("dsChamCong");
            } else {
                resp.getWriter().println("<h3 style='color:red'>❌ Không thể cập nhật chấm công</h3>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().println("<h3 style='color:red'>❌ Lỗi khi cập nhật: " + e.getMessage() + "</h3>");
        }
    }

    private void handleAddAttendance(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        try {
            int nhanVienId = Integer.parseInt(req.getParameter("employeeId"));
            String ngay = req.getParameter("attendanceDate");
            String checkIn = req.getParameter("checkInTime");
            String checkOut = req.getParameter("checkOutTime");
            String trangThai = req.getParameter("trangThai");

            KNCSDL kn = new KNCSDL();

            boolean success = kn.themChamCong(nhanVienId, ngay, checkIn, checkOut, trangThai);

            if (success) {
                resp.sendRedirect("dsChamCong"); // load lại danh sách
            } else {
                resp.getWriter().println("<h3 style='color:red'>❌ Không thể thêm chấm công (đã tồn tại?)</h3>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().println("<h3 style='color:red'>❌ Lỗi thêm chấm công: " + e.getMessage() + "</h3>");
        }
    }

    private void handleGetReports(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        
        try {
            String nhanVienIdStr = req.getParameter("nhanVienId");
            if (nhanVienIdStr == null || nhanVienIdStr.trim().isEmpty()) {
                resp.getWriter().write("{\"success\": false, \"message\": \"Thiếu ID nhân viên\"}");
                return;
            }
            
            int nhanVienId = Integer.parseInt(nhanVienIdStr);
            KNCSDL kn = new KNCSDL();
            
            // Lấy danh sách báo cáo của nhân viên
            List<Map<String, Object>> reports = kn.getBaoCaoChamCongByNhanVien(nhanVienId);
            
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"reports\": [");
            
            for (int i = 0; i < reports.size(); i++) {
                if (i > 0) json.append(",");
                Map<String, Object> report = reports.get(i);
                
                // Format ngày
                String ngayStr = "";
                Object ngayObj = report.get("ngay");
                if (ngayObj instanceof java.sql.Date) {
                    java.sql.Date sqlDate = (java.sql.Date) ngayObj;
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                    ngayStr = sdf.format(sqlDate);
                } else {
                    ngayStr = ngayObj != null ? ngayObj.toString() : "";
                }
                
                // Escape JSON
                String baoCaoStr = report.get("bao_cao") != null ? report.get("bao_cao").toString() : "";
                baoCaoStr = baoCaoStr.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
                
                json.append("{");
                json.append("\"ngay\": \"").append(ngayStr).append("\",");
                json.append("\"bao_cao\": \"").append(baoCaoStr).append("\"");
                json.append("}");
            }
            
            json.append("]}");
            resp.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\": false, \"message\": \"Lỗi server: " + e.getMessage() + "\"}");
        }
    }

    private void handleGetReportByAttendance(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        
        try {
            String attendanceIdStr = req.getParameter("attendanceId");
            
            if (attendanceIdStr == null || attendanceIdStr.trim().isEmpty()) {
                resp.getWriter().write("{\"success\": false, \"message\": \"Thiếu ID chấm công\"}");
                return;
            }
            
            int attendanceId = Integer.parseInt(attendanceIdStr);
            KNCSDL kn = new KNCSDL();
            
            // Lấy báo cáo của chấm công cụ thể
            Map<String, Object> report = kn.getBaoCaoChamCongByAttendanceId(attendanceId);
            
            if (report != null) {
                // Format ngày
                String ngayStr = "";
                Object ngayObj = report.get("ngay");
                if (ngayObj instanceof java.sql.Date) {
                    java.sql.Date sqlDate = (java.sql.Date) ngayObj;
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                    ngayStr = sdf.format(sqlDate);
                } else {
                    ngayStr = ngayObj != null ? ngayObj.toString() : "";
                }
                
                // Escape JSON
                String baoCaoStr = report.get("bao_cao") != null ? report.get("bao_cao").toString() : "";
                
                String hoTenStr = report.get("ho_ten") != null ? report.get("ho_ten").toString() : "";
                hoTenStr = hoTenStr.replace("\"", "\\\"");
                
                StringBuilder json = new StringBuilder();
                json.append("{\"success\": true, \"report\": {");
                json.append("\"ngay\": \"").append(ngayStr).append("\",");
                json.append("\"ho_ten\": \"").append(hoTenStr).append("\",");
                
                if (baoCaoStr != null && !baoCaoStr.trim().isEmpty()) {
                    baoCaoStr = baoCaoStr.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
                    json.append("\"bao_cao\": \"").append(baoCaoStr).append("\",");
                    json.append("\"has_report\": true");
                } else {
                    json.append("\"bao_cao\": \"\",");
                    json.append("\"has_report\": false");
                }
                
                json.append("}}");
                
                resp.getWriter().write(json.toString());
            } else {
                resp.getWriter().write("{\"success\": false, \"message\": \"Không tìm thấy record chấm công này\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\": false, \"message\": \"Lỗi server: " + e.getMessage() + "\"}");
        }
    }

}
