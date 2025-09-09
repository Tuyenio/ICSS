package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

/**
 * Servlet xử lý chấm công cho nhân viên
 *
 * @author Admin
 */
public class userChamCong extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");

            if (email == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            KNCSDL kn = new KNCSDL();

            // Lấy thông tin nhân viên
            Map<String, Object> nhanVienInfo = kn.getNhanVienByEmail(email);
            if (nhanVienInfo == null) {
                response.getWriter().println("<h3 style='color:red'>❌ Không tìm thấy thông tin nhân viên!</h3>");
                return;
            }

            int nhanVienId = (Integer) nhanVienInfo.get("id");

            // Lấy tham số tháng/năm
            String thang = request.getParameter("thang");
            String nam = request.getParameter("nam");

            if (thang == null || thang.isEmpty()) {
                Calendar cal = Calendar.getInstance();
                thang = String.valueOf(cal.get(Calendar.MONTH) + 1);
                nam = String.valueOf(cal.get(Calendar.YEAR));
            }

            // Lấy lịch sử chấm công của nhân viên
            List<Map<String, Object>> lichSuChamCong = kn.getLichSuChamCongUser(nhanVienId, Integer.parseInt(thang), Integer.parseInt(nam));

            // Lấy thống kê chấm công cá nhân
            Map<String, Object> thongKeChamCong = kn.getThongKeChamCongCaNhan(nhanVienId, Integer.parseInt(thang), Integer.parseInt(nam));

            // Kiểm tra trạng thái chấm công hôm nay
            Map<String, Object> chamCongHomNay = kn.getChamCongHomNay(nhanVienId);

            // Gửi dữ liệu đến JSP
            request.setAttribute("nhanVienInfo", nhanVienInfo);
            request.setAttribute("lichSuChamCong", lichSuChamCong);
            request.setAttribute("thongKeChamCong", thongKeChamCong);
            request.setAttribute("chamCongHomNay", chamCongHomNay);
            request.setAttribute("thangHienTai", thang);
            request.setAttribute("namHienTai", nam);

            request.getRequestDispatcher("user_attendance.jsp").forward(request, response);

        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(userChamCong.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("<h3 style='color:red'>❌ Lỗi: " + ex.getMessage() + "</h3>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");

            if (email == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Chưa đăng nhập\"}");
                return;
            }

            KNCSDL kn = new KNCSDL();

            // Lấy thông tin nhân viên
            Map<String, Object> nhanVienInfo = kn.getNhanVienByEmail(email);
            if (nhanVienInfo == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Không tìm thấy thông tin nhân viên\"}");
                return;
            }

            int nhanVienId = (Integer) nhanVienInfo.get("id");
            String action = request.getParameter("action");

            if ("checkin".equals(action)) {
                // Kiểm tra đã check-in hôm nay chưa
                Map<String, Object> chamCongHomNay = kn.getChamCongHomNay(nhanVienId);
                Boolean daCheckIn = (Boolean) chamCongHomNay.get("da_check_in");

                if (daCheckIn != null && daCheckIn) {
                    response.getWriter().write("{\"success\": false, \"message\": \"Bạn đã check-in hôm nay rồi!\"}");
                    return;
                }

                // Thực hiện check-in
                boolean success = kn.checkIn(nhanVienId);
                if (success) {
                    // Lấy thời gian check-in vừa thực hiện
                    java.time.ZonedDateTime now = java.time.ZonedDateTime.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh"));
                    String checkInTime = now.toLocalTime().toString();

                    response.getWriter().write("{\"success\": true, \"message\": \"Check-in thành công lúc " + checkInTime + "!\"}");
                } else {
                    response.getWriter().write("{\"success\": false, \"message\": \"Lỗi check-in, vui lòng thử lại!\"}");
                }

            } else if ("checkout".equals(action)) {
                // Kiểm tra đã check-in chưa
                Map<String, Object> chamCongHomNay = kn.getChamCongHomNay(nhanVienId);
                Boolean daCheckIn = (Boolean) chamCongHomNay.get("da_check_in");
                Boolean daCheckOut = (Boolean) chamCongHomNay.get("da_check_out");

                if (daCheckIn == null || !daCheckIn) {
                    response.getWriter().write("{\"success\": false, \"message\": \"Bạn chưa check-in hôm nay!\"}");
                    return;
                }

                if (daCheckOut != null && daCheckOut) {
                    response.getWriter().write("{\"success\": false, \"message\": \"Bạn đã check-out hôm nay rồi!\"}");
                    return;
                }

                // Thực hiện check-out
                boolean success = kn.checkOut(nhanVienId);
                if (success) {
                    // Lấy thời gian check-out vừa thực hiện
                    java.time.ZonedDateTime now = java.time.ZonedDateTime.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh"));
                    String checkOutTime = now.toLocalTime().toString();

                    response.getWriter().write("{\"success\": true, \"message\": \"Check-out thành công lúc " + checkOutTime + "!\"}");
                } else {
                    response.getWriter().write("{\"success\": false, \"message\": \"Lỗi check-out, vui lòng thử lại!\"}");
                }

            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Hành động không hợp lệ\"}");
            }

        } catch (Exception ex) {
            Logger.getLogger(userChamCong.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().write("{\"success\": false, \"message\": \"Lỗi hệ thống: " + ex.getMessage() + "\"}");
        }
    }

    public String getServletInfo() {
        return "Servlet xử lý chấm công cho nhân viên";
    }
}
