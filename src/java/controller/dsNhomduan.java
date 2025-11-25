package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class dsNhomduan extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");

        try {
            KNCSDL kn = new KNCSDL();

            // Lấy map số lượng dự án theo nhóm
            Map<String, Integer> soLuongMap = kn.getSoLuongDuAnTheoNhom();
            Map<String, Map<String, Integer>> soLuongTheoPB = kn.getSoLuongDuAnTheoNhomVaPhongBan();

            // Gửi sang JSP
            req.setAttribute("mapSoLuongNhom", soLuongMap);
            req.setAttribute("mapSoLuongPB", soLuongTheoPB);

            req.getRequestDispatcher("/nhomDuan.jsp").forward(req, resp);

        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(500, "Lỗi lấy số lượng dự án theo nhóm");
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(dsNhomduan.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
