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

        if ("edit".equals(action)) {
            // Gọi xử lý sửa giờ chấm công
            handleEditAttendance(request, response);
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
            List<Map<String, Object>> danhSachChamCong = kn.getDanhSachChamCong(thang, nam, tenphong, keyword);

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

}
