package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

/**
 * Filter tự động kiểm tra và chạy các job cộng phép khi cần thiết
 * - Chạy vào đầu tháng: cộng phép hàng tháng
 * - Chạy vào đầu năm: cộng phép đầu năm
 * - Chạy vào đầu quý 2: xóa phép năm cũ
 * 
 * Filter này sẽ chạy mỗi khi có request đến các trang chính
 * Sử dụng session để tránh chạy lại nhiều lần trong cùng 1 ngày
 * 
 * @author ICSS
 */
@WebFilter(filterName = "LeaveAccrualAutoFilter", urlPatterns = {
    "/index.jsp",
    "/userNghiPhep",
    "/adminNghiPhep",
    "/dsNghiPhep",
    "/user_dashboard.jsp"
})
public class LeaveAccrualAutoFilter implements Filter {
    
    private static final Logger LOGGER = Logger.getLogger(LeaveAccrualAutoFilter.class.getName());
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("LeaveAccrualAutoFilter initialized - Tự động cộng phép khi cần thiết");
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession();
        
        // Lấy ngày hôm nay
        Calendar cal = Calendar.getInstance();
        int currentYear = cal.get(Calendar.YEAR);
        int currentMonth = cal.get(Calendar.MONTH) + 1; // 0-based
        int currentDay = cal.get(Calendar.DAY_OF_MONTH);
        
        // Tạo key để lưu vào session, tránh chạy lại nhiều lần trong ngày
        String todayKey = currentYear + "-" + currentMonth + "-" + currentDay;
        String lastRunKey = "leaveAccrualLastRun";
        String lastRun = (String) session.getAttribute(lastRunKey);
        
        // Nếu chưa chạy hôm nay hoặc chưa có session
        if (lastRun == null || !lastRun.equals(todayKey)) {
            try {
                KNCSDL kn = new KNCSDL();
                boolean hasRun = false;
                
                // Job 1: Đầu năm (1/1) - Cộng 12 ngày cho NV > 12 tháng
                if (currentMonth == 1 && currentDay == 1) {
                    LOGGER.info("🎉 Đầu năm " + currentYear + " - Đang cộng phép đầu năm...");
                    try {
                        kn.congPhepDauNam(currentYear);
                        LOGGER.info("✅ Đã cộng phép đầu năm thành công cho " + currentYear);
                        hasRun = true;
                    } catch (SQLException ex) {
                        LOGGER.log(Level.SEVERE, "❌ Lỗi cộng phép đầu năm: " + ex.getMessage(), ex);
                    }
                }
                
                // Job 2: Đầu tháng (ngày 1) - Cộng phép của tháng trước vào ngày 1 tháng mới
                if (currentDay == 1) {
                    // Tính tháng trước
                    int previousMonth = currentMonth - 1;
                    int previousYear = currentYear;
                    if (previousMonth == 0) {
                        previousMonth = 12;
                        previousYear = currentYear - 1;
                    }
                    
                    LOGGER.info("📅 Ngày 1/" + currentMonth + "/" + currentYear + " - Đang cộng phép của tháng " + previousMonth + "/" + previousYear + "...");
                    try {
                        // Gọi với tháng trước (tháng vừa kết thúc) để cộng phép cho tháng đó
                        kn.congPhepHangThang(previousYear, previousMonth);
                        LOGGER.info("✅ Đã cộng phép hàng tháng thành công cho tháng " + previousMonth + "/" + previousYear);
                        hasRun = true;
                    } catch (SQLException ex) {
                        LOGGER.log(Level.SEVERE, "❌ Lỗi cộng phép hàng tháng: " + ex.getMessage(), ex);
                    }
                }
                
                // Job 3: Đầu quý 2 (1/4) - Xóa phép năm cũ
                if (currentMonth == 4 && currentDay == 1) {
                    LOGGER.info("🗑️ Đầu quý 2 năm " + currentYear + " - Đang xóa phép năm cũ...");
                    try {
                        kn.xoaPhepNamCu(currentYear);
                        LOGGER.info("✅ Đã xóa phép năm cũ thành công");
                        hasRun = true;
                    } catch (SQLException ex) {
                        LOGGER.log(Level.SEVERE, "❌ Lỗi xóa phép năm cũ: " + ex.getMessage(), ex);
                    }
                }
                
                // Lưu vào session để không chạy lại trong ngày
                if (hasRun) {
                    session.setAttribute(lastRunKey, todayKey);
                    LOGGER.info("💾 Đã lưu session - Không chạy lại cho đến ngày mai");
                }
                
            } catch (ClassNotFoundException | SQLException ex) {
                LOGGER.log(Level.SEVERE, "❌ Lỗi khởi tạo KNCSDL: " + ex.getMessage(), ex);
            }
        }
        
        // Tiếp tục chain
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        LOGGER.info("LeaveAccrualAutoFilter destroyed");
    }
}
