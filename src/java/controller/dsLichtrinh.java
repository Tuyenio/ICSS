package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;
import java.sql.Date;

public class dsLichtrinh extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest yeuCau, HttpServletResponse phanHoi)
            throws ServletException, IOException {
        phanHoi.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = phanHoi.getWriter()) {
            KNCSDL kn = new KNCSDL();
            List<Map<String, Object>> dsLichTrinh = kn.layTatCaLichTrinh();

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < dsLichTrinh.size(); i++) {
                Map<String, Object> lich = dsLichTrinh.get(i);
                json.append("{")
                    .append("\"id\":").append(lich.get("id")).append(",")
                    .append("\"title\":\"").append(escapeJson(lich.get("tieu_de"))).append("\",")
                    .append("\"start\":\"").append(lich.get("ngay_bat_dau")).append("\",")
                    .append("\"end\":\"").append(lich.get("ngay_ket_thuc") == null ? "" : lich.get("ngay_ket_thuc")).append("\",")
                    .append("\"description\":\"").append(escapeJson(lich.get("mo_ta"))).append("\"")
                    .append("}");
                if (i < dsLichTrinh.size() - 1) json.append(",");
            }
            json.append("]");
            out.print(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            phanHoi.getWriter().print("[]");
        }
    }

    private String escapeJson(Object giaTri) {
        if (giaTri == null) return "";
        return giaTri.toString().replace("\"", "\\\"");
    }
}
