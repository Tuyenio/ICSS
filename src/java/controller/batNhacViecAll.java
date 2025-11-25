package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

public class batNhacViecAll extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String states = req.getParameter("states"); // "Chưa bắt đầu,Đang thực hiện"

        if (states == null || states.isEmpty()) {
            resp.getWriter().print("ERROR");
            return;
        }

        KNCSDL kn = null;
        try {
            kn = new KNCSDL();

            int updated = kn.batNhacViecTheoTrangThai(states);

            if (updated > 0) {
                resp.getWriter().print("OK");
            } else {
                resp.getWriter().print("NO_UPDATE");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().print("ERROR");

        }
    }
}
