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
 * Filter tự động kiểm tra và cộng phép khi có request
 * - Khi user truy cập index.jsp hoặc user_dashboard.jsp
 * - Kiểm tra tháng trước: nếu chưa cộng phép cho nhân viên < 12 tháng thì cộng +1
 * - Kiểm tra anniversary: nếu hôm nay là ngày anniversary (12 tháng) thì cộng phép còn lại
 * 
 * Sử dụng session để tránh chạy lại nhiều lần trong cùng 1 ngày
 * 
 * @author ICSS
 */
@WebFilter(filterName = "LeaveAccrualAutoFilter", urlPatterns = {
    "/index.jsp",
    "/user_dashboard.jsp"
})
public class LeaveAccrualAutoFilter implements Filter {
    
    private static final Logger LOGGER = Logger.getLogger(LeaveAccrualAutoFilter.class.getName());
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("✅ LeaveAccrualAutoFilter initialized - Tự động cộng phép khi user truy cập trang");
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession();
        
        // Lấy ngày hiện tại
        Calendar cal = Calendar.getInstance();
        int currentYear = cal.get(Calendar.YEAR);
        int currentMonth = cal.get(Calendar.MONTH) + 1;
        int currentDay = cal.get(Calendar.DAY_OF_MONTH);
        
        // Tạo key để lưu vào session, tránh chạy lại nhiều lần trong ngày
        String todayKey = currentYear + "-" + currentMonth + "-" + currentDay;
        String lastRunKey = "leaveAccrualLastRun";
        String lastRun = (String) session.getAttribute(lastRunKey);
        
        LOGGER.info("🔵 [LeaveAccrualAutoFilter] Request: " + httpRequest.getRequestURI() + ", Ngày: " + currentDay + "/" + currentMonth + "/" + currentYear);
        
        // Nếu chưa chạy hôm nay
        if (lastRun == null || !lastRun.equals(todayKey)) {
            LOGGER.info("📋 [LeaveAccrualAutoFilter] Chưa chạy hôm nay, bắt đầu xử lý...");
            
            try {
                KNCSDL kn = new KNCSDL();
                
                try {
                    LOGGER.info("📋 Gọi congPhepTheoThang()...");
                    kn.congPhepTheoThang();
                    LOGGER.info("✅ congPhepTheoThang() hoàn tất");
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "❌ Lỗi trong congPhepTheoThang(): " + ex.getMessage(), ex);
                }
                
                try {
                    LOGGER.info("📋 Gọi congPhepAnniversary()...");
                    kn.congPhepAnniversary();
                    LOGGER.info("✅ congPhepAnniversary() hoàn tất");
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "❌ Lỗi trong congPhepAnniversary(): " + ex.getMessage(), ex);
                }
                
                // Lưu vào session để không chạy lại trong ngày
                session.setAttribute(lastRunKey, todayKey);
                LOGGER.info("💾 Đã lưu session - Không chạy lại cho đến ngày mai");
                
            } catch (ClassNotFoundException | SQLException ex) {
                LOGGER.log(Level.SEVERE, "❌ Lỗi khởi tạo KNCSDL: " + ex.getMessage(), ex);
            } catch (Exception ex) {
                LOGGER.log(Level.SEVERE, "❌ Lỗi bất ngờ: " + ex.getMessage(), ex);
            }
        } else {
            LOGGER.info("⏭️ Đã chạy hôm nay rồi, bỏ qua");
        }
        
        // Tiếp tục chain
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        LOGGER.info("❌ LeaveAccrualAutoFilter destroyed");
    }
}
