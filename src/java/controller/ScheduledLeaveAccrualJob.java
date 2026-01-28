package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

/**
 * Scheduled Job để tự động cộng ngày phép cho nhân viên
 * - Đầu năm: Cộng 12 ngày cho nhân viên làm >12 tháng
 * - Đầu tháng: Cộng 1 ngày cho nhân viên mới (chưa đủ 12 tháng)
 * - Đầu quý 2: Xóa ngày phép năm cũ
 * 
 * Servlet này nên được gọi bởi scheduled task (cron job/task scheduler)
 * hoặc có thể tích hợp với Quartz Scheduler
 * 
 * @author ICSS
 */
@WebServlet(name = "ScheduledLeaveAccrualJob", urlPatterns = {"/scheduledLeaveAccrual"})
public class ScheduledLeaveAccrualJob extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        
        // Kiểm tra quyền truy cập - chỉ cho phép từ localhost hoặc có key bảo mật
        String securityKey = request.getParameter("key");
        String expectedKey = "ICSS_LEAVE_ACCRUAL_2026"; // Nên lưu trong config file
        
        if (securityKey == null || !securityKey.equals(expectedKey)) {
            response.getWriter().println("{\"success\":false,\"message\":\"Unauthorized access\"}");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            if (action == null) action = "auto";
            
            KNCSDL kn = new KNCSDL();
            Calendar cal = Calendar.getInstance();
            int currentYear = cal.get(Calendar.YEAR);
            int currentMonth = cal.get(Calendar.MONTH) + 1; // 0-based
            int currentDay = cal.get(Calendar.DAY_OF_MONTH);
            
            StringBuilder result = new StringBuilder();
            result.append("{\"success\":true,\"jobs\":[");
            boolean hasJob = false;
            
            switch (action) {
                case "yearStart":
                    // Chạy job đầu năm
                    kn.congPhepDauNam(currentYear);
                    result.append("{\"job\":\"yearStart\",\"year\":").append(currentYear).append(",\"status\":\"completed\"}");
                    hasJob = true;
                    break;
                    
                case "monthStart":
                    // Chạy job đầu tháng - cộng phép của tháng trước
                    int prevMonthForCase = currentMonth - 1;
                    int prevYearForCase = currentYear;
                    if (prevMonthForCase == 0) {
                        prevMonthForCase = 12;
                        prevYearForCase = currentYear - 1;
                    }
                    kn.congPhepHangThang(prevYearForCase, prevMonthForCase);
                    result.append("{\"job\":\"monthStart\",\"year\":").append(prevYearForCase)
                          .append(",\"month\":").append(prevMonthForCase).append(",\"status\":\"completed\"}");
                    hasJob = true;
                    break;
                    
                case "q2Start":
                    // Xóa phép năm cũ khi bắt đầu quý 2
                    kn.xoaPhepNamCu(currentYear);
                    result.append("{\"job\":\"q2Start\",\"year\":").append(currentYear).append(",\"status\":\"completed\"}");
                    hasJob = true;
                    break;
                    
                case "auto":
                default:
                    // Tự động kiểm tra và chạy job phù hợp
                    
                    // Ngày 1/1: Cộng phép đầu năm
                    if (currentMonth == 1 && currentDay == 1) {
                        kn.congPhepDauNam(currentYear);
                        result.append("{\"job\":\"yearStart\",\"year\":").append(currentYear).append(",\"status\":\"completed\"}");
                        hasJob = true;
                    }
                    
                    // Ngày 1 hàng tháng: Cộng phép của tháng trước
                    if (currentDay == 1) {
                        if (hasJob) result.append(",");
                        int prevMonthAuto = currentMonth - 1;
                        int prevYearAuto = currentYear;
                        if (prevMonthAuto == 0) {
                            prevMonthAuto = 12;
                            prevYearAuto = currentYear - 1;
                        }
                        kn.congPhepHangThang(prevYearAuto, prevMonthAuto);
                        result.append("{\"job\":\"monthStart\",\"year\":").append(prevYearAuto)
                              .append(",\"month\":").append(prevMonthAuto).append(",\"status\":\"completed\"}");
                        hasJob = true;
                    }
                    
                    // Ngày 1/4: Xóa phép năm cũ
                    if (currentMonth == 4 && currentDay == 1) {
                        if (hasJob) result.append(",");
                        kn.xoaPhepNamCu(currentYear);
                        result.append("{\"job\":\"q2Start\",\"year\":").append(currentYear).append(",\"status\":\"completed\"}");
                        hasJob = true;
                    }
                    
                    if (!hasJob) {
                        result.append("{\"job\":\"none\",\"message\":\"No scheduled job to run today\"}");
                        hasJob = true;
                    }
                    break;
            }
            
            result.append("],\"timestamp\":\"").append(new java.util.Date()).append("\"}");
            response.getWriter().println(result.toString());
            
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(ScheduledLeaveAccrualJob.class.getName()).log(Level.SEVERE, null, ex);
            response.getWriter().println("{\"success\":false,\"message\":\"Error: " + ex.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
