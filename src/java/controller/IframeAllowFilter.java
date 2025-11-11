package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class IframeAllowFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletResponse res = (HttpServletResponse) response;
        res.setHeader("X-Frame-Options", "ALLOWALL");
        res.setHeader("Content-Security-Policy", "frame-ancestors https://*.zalo.me https://h5.zdn.vn https://zalo.me;");
        chain.doFilter(request, response);
    }
}
