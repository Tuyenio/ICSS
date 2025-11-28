package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.sql.SQLException;

public class ApiThongbaoLatest extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession(false);
        Integer userId = null;
        if (session != null && session.getAttribute("userId") != null) {
            try {
                userId = Integer.parseInt(session.getAttribute("userId").toString());
            } catch (Exception ignored) {}
        }

        int limit = 10;
        String limitParam = req.getParameter("limit");
        if (limitParam != null) {
            try { limit = Integer.parseInt(limitParam); } catch (Exception ignored) {}
        }

        try (PrintWriter out = resp.getWriter()) {
            KNCSDL kn = new KNCSDL();
            // getDanhSachThongBao(userId, size, offset) đã tồn tại trong project
            List<Map<String, Object>> list = kn.getDanhSachThongBao((userId != null && userId > 0) ? userId : null, limit, 0);

            // build JSON simple (id, title, body, created_at, is_read)
            StringBuilder sb = new StringBuilder();
            sb.append("[");
            for (int i = 0; i < list.size(); i++) {
                Map<String, Object> it = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"id\":").append(it.getOrDefault("id", 0)).append(",");
                sb.append("\"title\":\"").append(escape(it.get("tieu_de"))).append("\",");
                sb.append("\"body\":\"").append(escape(it.get("noi_dung"))).append("\",");
                sb.append("\"created_at\":\"").append(escape(it.get("ngay_tao"))).append("\",");
                // try common key names for read flag
                Object daDoc = it.get("da_doc");
                if (daDoc == null) daDoc = it.get("is_read");
                sb.append("\"is_read\":").append( (daDoc != null && ("1".equals(daDoc.toString()) || "true".equalsIgnoreCase(daDoc.toString()))) ? "true" : "false");
                sb.append("}");
            }
            sb.append("]");
            out.print(sb.toString());
            kn.close();
        } catch (ClassNotFoundException | SQLException ex) {
            ex.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().print("[]");
        }
    }

    private String escape(Object o) {
        if (o == null) return "";
        String s = o.toString();
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}