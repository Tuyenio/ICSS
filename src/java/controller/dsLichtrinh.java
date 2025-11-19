package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

public class dsLichtrinh extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            KNCSDL kn = new KNCSDL();
            List<Map<String, Object>> ds = kn.layTatCaLichTrinh();

            // Gửi dữ liệu sang JSP
            req.setAttribute("lichTrinh", ds);

            RequestDispatcher rd = req.getRequestDispatcher("calendar.jsp");
            rd.forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "Lỗi load lịch trình");
        }
    }
}